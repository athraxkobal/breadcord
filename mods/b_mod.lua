local mod = {};
mod.Info = {
	Name = 'Moderation Commands', shortName = 'jannymod',
	Description = 'Too lazy to click the damn buttons?',
	Author = 'athraxkobal',Url = 'https://github.com/athraxkobal/breadcord',
	Version = 'Tied with Breadcord',
};

mod.Commands = {
	{
		Name = 'ban', Description = 'Ban a user, late or not',
		Usage = '%s <mention> <?msg purge days> <?reason, rest of line>',
		Flags = {'banmembers','inguild'},
		Function = function(msgObj,Parameter,splitParam)
			local msgPurgeDays,snowflake,reason;
			local id,type = Commandments:getMentionId(splitParam[1]);
			if Parameter == '' then return false; end;
			if id then
				if type == 'user' then
					snowflake = id;
				else
					msgObj:reply'A ***user*** mention, boss';
					return;
				end;
			else
				snowflake = splitParam[1]:match'%d+';
			end;
			if not snowflake then return false; end;
			
			local WhatAStory = msgObj.guild:getBan(snowflake);
			if WhatAStory then
				msgObj:reply('The user '..WhatAStory.user.tag..' is already banned');
				return;
			else
				WhatAStory = msgObj.guild:getMember(snowflake);
			end;
			if splitParam[2] then
				msgPurgeDays = tonumber(splitParam[2]);
				if not msgPurgeDays then msgPurgeDays = 0; end;
				if msgPurgeDays > 7 then msgPurgeDays = 7; end;
				reason = table.concat(splitParam,' ',3);
				if not splitParam[3] then reason = 'No reason given'; end;
				reason = 'Actor '..msgObj.author.tag..' ('..msgObj.author.id..'):'..reason; -- rest of the string
			end;
			local bannedTag;
			if WhatAStory then bannedTag = WhatAStory.user.tag; end;
			local s = msgObj.guild:banUser(snowflake,reason);
			if s then
				if WhatAStory then
					msgObj:reply('Successfully banned user '..bannedTag..' (`'..snowflake..'`)');
				else
					msgObj:reply('Successfully banned user `'..snowflake..'`');
				end;
			else
				msgObj:reply'Ban failed and I have no idea why :sunglasses:';
			end;
		end;
	},
	{
		Name = 'unban', Description = 'Unban a user',
		Usage = '% s <snowflake id> <?reason, rest of line>',
		Flags = {'banmembers','inguild'},
		Function = function(msgObj,Parameter,splitParam)
			local snowflake,reason;
			if Parameter == '' then return false; end;
			local id,type = Commandments:getMentionId(splitParam[1]);
			if Parameter == '' then return false; end;
			if id then
				if type == 'user' then
					snowflake = id;
				else
					msgObj:reply'A ***user*** mention, boss';
					return;
				end;
			else
				snowflake = splitParam[1]:match'%d+';
			end;
			if not snowflake then return false; end;
			local banObj = msgObj.guild:getBan(snowflake);
			if not banObj then
				msgObj:reply('The user specified `'..snowflake..'` is not banned'); return;
			end;
			reason = table.concat(splitParam,' ',2);
			if not splitParam[2] then reason = 'No reason given'; end;
			reason = 'Actor '..msgObj.author.tag..' ('..msgObj.author.id..'):'..reason; -- rest of the string
			local bannedTag = banObj.user.tag;
			local s = msgObj.guild:unbanUser(snowflake,reason);
			if s then
				msgObj:reply('Successfully unbanned user '..banObj.user.tag..' (`'..snowflake..'`)');
			else
				msgObj:reply'Unban failed and I have no idea why :sunglasses:';
			end;
		end;
	},
	{
		Name = 'kick', Description = 'Kick a user',
		Usage = '%s <mention/id> <?reason, rest of line>',
		Flags = {'kickmembers','inguild'},
		Function = function(msgObj,Parameter,splitParam)
			local snowflake,reason;
			local obj,type = Commandments:getMentionObj(splitParam[1],msgObj.guild);
			if obj then
				if type ~= 'member' then
					msgObj:reply('A user mention ***from this guild***, boss');
				else
					snowflake = obj.id;
				end;
			else
				snowflake = splitParam[1]:match'%d+';
				obj = msgObj.guild:getMember(snowflake);
			end;
			if not obj then
				msgObj:reply('The user specified `'..snowflake..'` is not a member of this guild'); return;
			end;
			reason = table.concat(splitParam,' ',2);
			if not splitParam[2] then reason = 'No reason given'; end;
			reason = 'Actor '..msgObj.author.tag..' ('..msgObj.author.id..'):'..reason; -- rest of the string

			local s = msgObj.guild:kickUser(snowflake,Parameter);
			local kickedTag = obj.tag;
			if s then
				msgObj:reply('Sucessfully kicked user '..kickedTag..' (`'..snowflake..'`)');
			else
				msgObj:reply'Kick failed and I have no idea why :sunglasses:';
			end;
		end;
	},
};

return mod;