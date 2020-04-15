local discordia = require('discordia');

return function(Commandments,Client)
	--[[TODO
			Add or create a real parser
	]]--
	Commandments:addCmd('ban','Ban a user',function(msgObj,Parameter)
		local msgPurgeDays = nil;
		local snowflake = '';
		if Parameter == '' then
			msgObj:reply('Usage: '..Commandments.Prefix..'ban <optional days> <snowflake or mention> <optional reason>');
			return nil;
		end;
		print('B_MOD | ban parameters: '..Parameter);
		if type(tonumber(Parameter:sub(1,1))) == 'number' then
			if Parameter:sub(2,2) == ' ' then
				msgPurgeDays = tonumber(Parameter:sub(1,1));
				Parameter = Parameter:sub(3); -- Cut the day arg
			elseif Parameter:sub(2,2) == '' then
				msgObj:reply('Usage: '..Commandments.Prefix..'ban <optional days> <snowflake or mention> <optional reason>');
				return nil;
			end;
		end;
		if Parameter:sub(1,2) == '<@' then
			local fSub,sSub = Parameter:find('%b<>');
			snowflake = Parameter:sub(3,sSub-1);
			Parameter = Parameter:sub(sSub+2);
		else
			local fSub,sSub = string.find(Parameter,'%d+');
			snowflake = Parameter:sub(1,sSub);
			Parameter = Parameter:sub(sSub+2);
		end;
		if Parameter == '' then
			Parameter = nil;
		end;
		
		local duelPurpose = msgObj.guild:getBan(snowflake);
		if duelPurpose ~= nil then
			msgObj:reply('The user specified '..duelPurpose.user.tag..' is already banned');
			return nil;
		else
			duelPurpose = msgObj.guild:getMember(snowflake);
		end;
		local succState,errMsg = msgObj.guild:banUser(snowflake,Parameter,msgPurgeDays);
		if succState then
			if duelPurpose == nil then
				msgObj:reply('Successfully banned user `'..snowflake..'`');
				print('B_MOD | ban success on id '..snowflake);
			else
				msgObj:reply('Successfully banned user '..duelPurpose.user.tag..' `'..snowflake..'`');
				print('B_MOD | ban success on '..duelPurpose.user.tag..' with id '..snowflake);
			end;
		else
			msgObj:reply('Ban failed');
			print('B_MOD | ban fail, reason: '..errMsg);
		end;
	end,'mod','serveronly');
	Commandments:addCmd('unban','Unban a user',function(msgObj,Parameter)	
		local snowflake = '';
		if Parameter == '' then
			msgObj:reply('Usage: '..Commandments.Prefix..'unban <snowflake or mention> <optional reason>');
			return nil;
		end;
		print('B_MOD | unban parameters: '..Parameter);
		if Parameter:sub(1,2) == '<@' then
			local fSub,sSub = Parameter:find('%b<>');
			snowflake = Parameter:sub(3,sSub-1);
			Parameter = Parameter:sub(sSub+2);
		else
			local fSub,sSub = string.find(Parameter,'%d+');
			snowflake = Parameter:sub(1,sSub);
			Parameter = Parameter:sub(sSub+2);
		end;
		if Parameter == '' then
			Parameter = nil;
		end;
		local banObj = msgObj.guild:getBan(snowflake);
		if banObj == nil then
			msgObj:reply('The user specified `'..snowflake..'` is not banned');
			return nil;
		end;
		local succState,errMsg = msgObj.guild:unbanUser(snowflake,Parameter);
		if succState then
			msgObj:reply('Successfully unbanned user '..banObj.user.tag..' `'..snowflake..'`');
			print('B_MOD | unban success on '..banObj.user.tag..' with id '..snowflake);
		else
			msgObj:reply('Unban failed');
			print('B_MOD | unban fail, reason: '..errMsg);
		end;
	end,'mod','serveronly');
	Commandments:addCmd('kick','Kick a user',function(msgObj,Parameter)
		local snowflake = '';
		if Parameter == '' then
			msgObj:reply('Usage: '..Commandments.Prefix..'kick <snowflake or mention> <optional reason>');
			return nil;
		end;
		print('B_MOD | kick parameters: '..Parameter);
		if Parameter:sub(1,2) == '<@' then
			local fSub,sSub = Parameter:find('%b<>');
			snowflake = Parameter:sub(3,sSub-1);
			Parameter = Parameter:sub(sSub+2);
		else
			local fSub,sSub = string.find(Parameter,'%d+');
			snowflake = Parameter:sub(1,sSub);
			Parameter = Parameter:sub(sSub+2);
		end;
		if Parameter == '' then
			Parameter = nil;
		end;
		local memberObj = msgObj.guild:getMember(snowflake);
		if memberObj == nil then
			msgObj:reply('The user specified `'..snowflake..'` is not a member of this guild');
			return nil;
		end;
		local succState,errMsg = msgObj.guild:kickUser(snowflake,Parameter);
		if succState then
			msgObj:reply('Successfully kicked user '..memberObj.user.tag..' `'..snowflake..'`');
			print('B_MOD | Kick success on '..memberObj.user.tag..' with id '..snowflake);
		else
			msgObj:reply(':Kick failed');
			print('B_MOD | Kick fail, reason: '..errMsg);
		end;
	end,'mod','serveronly');
end;