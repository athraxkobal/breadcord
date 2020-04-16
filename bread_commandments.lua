print('B_COMMANDMENTS | Move up');

local Commandments = {};
local fs = require('fs');
local discordia = require('discordia');
local Client;

--[[
	name, description, command function, group, optional flags
	Set name as a table for aliases
	Function gets the message object and the message string with the command taken out
	Flags can be listed as extra arguments or in a table
	Available flags:
		none (everything else is ignored if none is in the flags table)
		serveronly
		dmonly
		owneronly
	
	Warning: Any "missing flags" are ones commands themselves are expected handle themselves, and for now, are also expected to parse arguments themselves
	 Why? I don't have time to formulate a argument parsing tool, regardless of how easy it really is
	 I know this leads to commands being very large when having multiple arguments but for testing purposes I will not be having a parse system 
	 Eventually I will add a helper parse function that commands can call upon from the Commandments table, and convert commands that have their own legacy parsing to the new
]]--
function Commandments:addCmd(name,description,funciones,group,...)
	local flags = {...};
	if type(name) == 'table' then
		for i,v in ipairs(name) do
			name[i] = v:lower();
		end;
	else
		name = {name:lower()};
	end;
	local fixedFlags = {};
	local flags = {...};
	if #flags == 0 then
		flags = {'none'};
	elseif type(flags[1]) == 'table' then
		flags = flags[1];
	end;
	for i,v in ipairs(flags) do
		fixedFlags[v:lower()] = true;
	end;
	assert(not (fixedFlags['dmonly'] and fixedFlags['serveronly']),'Commandment '..name[1]..'\'s has conflicting dm and server flags');
	table.insert(self,#self+1,{name,description,funciones,group,fixedFlags});
end;

function Commandments.messageCreate(msgObj)
	if msgObj.author.id ~= Client.user.id then
		if msgObj.content:sub(1,#Commandments.Prefix) == Commandments.Prefix then
			local Parameter = msgObj.content:sub(#Commandments.Prefix+1);
			print('B_COMMANDMENTS | Attempting to check '..msgObj.author.tag..'\'s request to execute '..Parameter);
			local Commandment = nil;
			for i,v in ipairs(Commandments) do
				local Namez = v[1];
				for ai,av in ipairs(Namez) do
					if Parameter:sub(1,#av):lower() == av then
						if Parameter:sub(#av+1,#av+1) == ' ' then
							Commandment = v; Parameter = Parameter:sub(#av+2); break;
						elseif Parameter:sub(#av+1,#av+1) == '' then
							Commandment = v; Parameter = ''; break;
						end;
					end;
				end;
				if Commandment ~= nil then break; end;
			end;
			if Commandment ~= nil then
				-- I feel like this is dirty, could be improved
				if Commandment[5]['none'] then
					print('B_COMMANDMENTS | Commandment '..msgObj.content..' by '..msgObj.author.tag..' is valid, executing');
					Commandment[3](msgObj,Parameter);
					return true;
				else
					if Commandment[5]['dmonly'] then
						if msgObj.guild then
							msgObj:reply('This command can only be ran in DM');
						else
							if Commandment[5]['owneronly'] then
								if msgObj.author.id == Client.owner.id then
									Commandment[3](msgObj,Parameter);
									print('B_COMMANDMENTS | DM Commandment '..msgObj.content..' by bot owner is valid, executing');
									return true;
								else
									msgObj:reply('This command is owner only');
								end;
							else
								Commandment[3](msgObj,Parameter);
								print('B_COMMANDMENTS | DM Commandment '..msgObj.content..' by '..msgObj.author.tag..' is valid, executing');
								return true;
							end;
						end;
					elseif Commandment[5]['serveronly'] then
						if not msgObj.guild then
							msgObj:reply('This command can only be ran in a server');
						else
							if Commandment[5]['owneronly'] then
								if msgObj.author.id == Client.owner.id then
									Commandment[3](msgObj,Parameter);
									print('B_COMMANDMENTS | Commandment '..msgObj.content..' by bot owner is valid, executing');
									return true;
								else
									msgObj:reply('This command is owner only');
								end;
							else
								Commandment[3](msgObj,Parameter);
								print('B_COMMANDMENTS | Commandment '..msgObj.content..' by '..msgObj.author.tag..' is valid, executing');
								return true;
							end;
						end;
					else
						if Commandment[5]['owneronly'] then
							if msgObj.author.id == Client.owner.id then
								Commandment[3](msgObj,Parameter);
								print('B_COMMANDMENTS | Commandment '..msgObj.content..' by bot owner is valid, executing');
								return true;
							else
								msgObj:reply('This command is owner only');
							end;
						else
							Commandment[3](msgObj,Parameter);
							print('B_COMMANDMENTS | Commandment '..msgObj.content..' by '..msgObj.author.tag..' is valid, executing');
							return true;
						end;
					end;
				end;
			end;
		end;
	end;
end;

return function(_Client)
	Client = _Client;
	-- Load them modules
	local modIter = fs.scandirSync('./breadcord/mods/');
	while true do
		local mod = modIter();
		if mod ~= nil then
			print('B_COMMANDMENTS | Loading '..mod);
			require('./mods/'..mod)(Commandments,Client);
		else
			break;
		end;
	end;
	return Commandments; -- We're done
end;