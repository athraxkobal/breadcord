print('B_COMMANDMENTS | Move up');

local Commandments = {};
local fs = require('fs');
local discordia = require('discordia');
local Client;

--[[
	I'd get around to using a table for command f l a g s

	name, description, command function, group, optional boolean serveronly
	Set name as a table for aliases
	Function gets the message object and the message string with the command taken out
	Warning: other than the serveronly bool, commands themselves are expected to parse the arguments themselves and if the executor can actually use the command
	 Why? I don't have time to formulate a argument parsing tool, regardless of how easy it really is
	 I know this leads to commands being very large when having multiple arguments but for testing purposes I will not be having a parse system 
	 Eventually I will add a helper parse function that commands can call upon from the Commandments table, and convert commands that have their own legacy parsing to the new
]]--
function Commandments:addCmd(name,description,funciones,group,serveronly)
	if type(name) == 'table' then
		for i,v in ipairs(name) do
			name[i] = v:lower();
		end;
	else
		name = {name:lower()};
	end;
	if serveronly == nil then serveronly = false; end;
	table.insert(self,#self+1,{name,description,funciones,group,serveronly});
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
				if msgObj.guild ~= nil then
					print('B_COMMANDMENTS | Commandment '..msgObj.content..' by '..msgObj.author.tag..' is valid, executing');
					Commandment[3](msgObj,Parameter);
				else
					if Commandment[5] then
						msgObj:reply('Sorry, this commandment can only be ran in servers');
					else
						print('B_COMMANDMENTS | DM Commandment '..msgObj.content..' by '..msgObj.author.tag..' is valid, executing');
						Commandment[3](msgObj,Parameter);
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