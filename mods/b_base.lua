local discordia = require('discordia');

return function(Commandments,Client)
	--[[TODO
			Make a help command haha
	]]--
	Commandments:addCmd({'stop','dip'},'Shuts down the bot',function(msgObj,Parameter)
		if msgObj.author.id == Client.owner.id then
			msgObj:reply('Shutting down...'); Client:setGame(nil); Client:setStatus(discordia.enums.status.invisible); Client:stop();
		else
			msgObj:reply('YOU CAN\'T KILL ME!');
		end;
	end,'base');	
	Commandments:addCmd('setname','Changes the name of the bot',function(msgObj,Parameter)
		local Success = Client:setUsername(Parameter);
		if Success then
			msgObj:reply('Changed username to '..Parameter);
			print('B_BASE | Username changed to '..Parameter);
		else
			msgObj:reply('Failed to change username');
		end;
	end,'base','owneronly');
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
	end,'base','owneronly');
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
	end,'base','owneronly');
end;