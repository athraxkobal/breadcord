local discordia = require('discordia');
local thisMod = 'base';

return function(Commandments,Client)
	--[[TODO
			Make a help command haha
				will list modules with no args
				will be able to list module commands (and maybe an alias if applicable) by using subcommand 'mod_<modName>'
				will show command info for commands by just typing the command name or any of its aliases 
	]]--
	Commandments:addCmd({'help'},'Get help for a command (WIP)',function(msgObj,Parameter) -- make this able to list commands
		if Parameter == '' then
			local modNames = {};
			for i,v in ipairs(Commandments.Modules) do
				table.insert(modNames,'`'..v..'`');
			end;
			table.sort(modNames);
			modNames = table.concat(modNames,',');
			msgObj:reply('Current modules: '..modNames);
		elseif Parameter:sub(1,4) == 'mod_' then
			--[[ list commands like this, owneronly commands will be skipped
				*<modName>* module commands:
				```http
				cmd: Description | flags
				cmd2,cmd2alias: Description | flags
				```
				EXAMPLE:
				*base* module commands:
				```http
				help: Get help for a command
				whydoiexist,ponderexistance: Ask why do we live | DM only
				```
			]]--
			msgObj:reply('Unimplemented, sorry');
		else
			for i,v in ipairs(Commandments) do
				for ai,av in ipairs(v[1]) do
					if Parameter:sub(1,#av):lower() == av then
						local cmdInfo = {'Command: '..v[1][1],'Module: '..v[4]};
						if #v[1] > 1 then
							local aliases = {};
							for ei,ev in ipairs(v[1]) do
								if ei > 1 then table.insert(aliases,ev); end;
							end;
							table.insert(cmdInfo,'Available aliases: '..table.concat(aliases,', '));
						end;
						table.insert(cmdInfo,'Description: '..v[2]);
						if v[5].dmonly then
							table.insert(cmdInfo,'This command is DM only');
						elseif v[5].serveronly then
							table.insert(cmdInfo,'This command can only be ran in a server');
						end;
						if v[5].owneronly then
							table.insert(cmdInfo,'This command is bot owner only');
						end;
						msgObj:reply('```http\n'..table.concat(cmdInfo,'\n')..'\n```');
						break;
					end;
				end;
			end;
		end;
	end,thisMod)
	Commandments:addCmd({'stop','dip'},'Shuts down the bot',function(msgObj,Parameter)
		if msgObj.author.id == Client.owner.id then
			msgObj:reply('Shutting down...'); Client:setGame(nil); Client:setStatus(discordia.enums.status.invisible); Client:stop();
		else
			msgObj:reply('YOU CAN\'T KILL ME!');
		end;
	end,thisMod);	
	Commandments:addCmd('setname','Changes the name of the bot',function(msgObj,Parameter)
		local Success = Client:setUsername(Parameter);
		if Success then
			msgObj:reply('Changed username to '..Parameter);
			print('B_BASE | Username changed to '..Parameter);
		else
			msgObj:reply('Failed to change username');
		end;
	end,thisMod,'owneronly');
	Commandments:addCmd('setgame','Changes the game of the bot',function(msgObj,Parameter)
		if Parameter == '' then
			Client:setGame(nil);
			msgObj:reply('Removed game status');
		else
			if Parameter:sub(1,3) == '~_l' then
				Parameter = Parameter:sub(5);
				Client:setGame({name = Parameter,type = discordia.enums.activityType.listening});
				msgObj:reply('Set listening to '..Parameter);
			else
				Client:setGame(Parameter);
				msgObj:reply('Set game to '..Parameter);
			end;
		end;
	end,thisMod,'owneronly');
	Commandments:addCmd('exec','Run some lua code',function(msgObj,Parameter)
		local msgChannel = msgObj.channel; -- in case msgObj gets clapped
		local Environment = setmetatable({
			discordia = discordia;
			Client = Client;
			msgObj = msgObj;
			msgChannel = msgChannel;
			msgGuild = msgObj.guild; -- in dms this is nil anyway
		},{__index = _G});
		
		function Environment.mprint(...) msgChannel:send(...); end;
		
		local chunkyFuncy,ldErr = loadstring(''..Parameter,'botexec','t',Environment);
		if not chunkyFuncy then
			print('B_BASE | Syntax error:\n'..ldErr);
			if #ldErr <= 1986 then
				msgObj:reply('Syntax error:\n'..ldErr);
			else
				msgObj:reply('Syntax error:\n'..ldErr:sub(1,1986));
				msgObj:reply('Error truncated, check console for full');
			end;
		else
			local Success,ldErr = pcall(chunkyFuncy);
			if Success then
				print('B_BASE | Successfully ran exec');
			else
				print('B_BASE | exec error:\n'..ldErr);
				if #ldErr <= 1993 then
					msgChannel:send('Error:\n'..ldErr);
				else
					msgChannel:send('Error:\n'..ldErr:sub(1,1993));
					msgChannel:send('Error truncated, check console for full');
				end;
			end;
		end;
	end,thisMod,'owneronly');
	return thisMod;
end;