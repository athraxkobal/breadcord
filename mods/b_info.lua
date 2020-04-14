local discordia = require('discordia'); 

-- Only accepts objects, also accepts members
-- Expects the user object to be non-nil
function getUserInfo(Client,user,guild)
	local userInfo = {};
	if type(user) == 'string' then
		print('B_INFO | Getting user info for '..user);
		if guild ~= nil then
			user = guild:getMember(user);
		else
			user = Client:getUser(user);
		end;
		if user == nil then
			return nil;
		end;
	else
		print('B_INFO | Getting user info for '..user.id);
	end;
	if user.mutualGuilds == nil then
		print('B_INFO | User.mutualGuilds can be nil');
		table.insert(userInfo,'User has no guilds shared with the bot, information may be old');
	elseif #user.mutualGuilds == 0 then
		table.insert(userInfo,'User has no guilds shared with the bot, information may be old');
	else
		table.insert(userInfo,tostring('User shares '..#user.mutualGuilds..' guilds with the bot'));
	end;
	if user.bot then
		table.insert(userInfo,tostring('Tag/Snowflake: BOT '..user.tag..' | '..user.id));
	else
		table.insert(userInfo,tostring('Tag/Snowflake: '..user.tag..' | '..user.id));
		if user.id == Client.owner.id then
			table.insert(userInfo,tostring('This user created me!'));
		end;
	end;
	if user.avatar == nil then
		table.insert(userInfo,tostring('User has a default avatar ('..discordia.enums.defaultAvatar(user.defaultAvatar)));
	end;
	if user.guild ~= nil then
		table.insert(userInfo,tostring('Guild membership context: '..user.guild.name..' | '..user.guild.id));
		if user.guild.owner.id == user.id then
			table.insert(userInfo,tostring('User is the owner of this guild'));
		end;
	end;
	if user.premiumSince ~= nil then
		table.insert(userInfo,tostring('User boosted at: '..discordia.Data.fromISO(user.premiumSince):toString()));
	end;
	if user.nickname ~= nil then
		table.insert(userInfo,tostring('Nickname: '..user.nickname));
	end;
	table.insert(userInfo,tostring('Creation Date: '..discordia.Date.fromSnowflake(user.id):toString()));
	if user.joinedAt ~= nil then
		table.insert(userInfo,tostring('Joined at: '..discordia.Date.fromISO(user.joinedAt):toString()));
	end;
	if user.roles ~= nil then
		table.insert(userInfo,tostring('Number of roles: '..#user.roles));
	end;
	if user.status ~= nil then
		table.insert(userInfo,tostring('Status: '..user.status));
	end;
	--[[
	if user.activity ~= nil then
		if user.activity.name ~= nil and user.activity.type ~= nil then
			if user.activity.type == discordia.enums.activityType.default then
				table.insert(userInfo,tostring('Playing '..user.activity.name));
			elseif user.activity.type == discordia.enums.activityType.listening then
				table.insert(userInfo,tostring('Listening to '..user.activity.name));
			elseif user.activity.type == discordia.enums.activityType.streaming and user.activty.url ~= nil then
				table.insert(userInfo,tostring('Streaming '..user.activity.name..' at '..user.activity.url));
			end;
		else
			table.insert(userInfo,'User has an invalid activity');
		end;
	end;
	]]--
	if user.voiceChannel ~= nil then
		if user.voiceChannel.guild.id ~= user.guild.id then
			table.insert(userInfo,'Connected to an external VC');
		elseif user.voiceChannel.id == user.guild.afkChannelId then
				table.insert(userInfo,'Connected to the AFK VC');
		else
			if user.muted and user.deafened then
				table.insert(userInfo,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..'), but is both muted and deafened.'));
			elseif user.muted and (not user.deafened) then
				table.insert(userInfo,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..'), but is muted'));
			elseif (not user.muted) and user.deafened then
				table.insert(userInfo,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..'), but is deafened'));
			elseif not (user.muted and user.deafened) then
				table.insert(userInfo,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..')'));
			end;
		end;
	end;
	print('B_INFO | Done getting user info for '..user.id);
	return userInfo;
end;

function getGuildInfo(Client,guild)
	if type(guild) == 'string' then
		print('B_INFO | Getting guild info for '..guild);
		guild = Client:getGuild(guild);
		if guild == nil then
			return nil;
		end;
	else
		print('B_INFO | Getting guild info for '..guild.id);
	end;
	if not Client.user.bot then guild:sync(); end;
	local reqMemBool = guild:requestMembers();
	local guildInfo = {}; -- adding shit to this table since guilds can be unavailable
	if guild.unavailable then
		table.insert(guildInfo,tostring('The guild specified ('..guild.id..') is unavailable. Some information may be obsolete and/or unknown.'));
	end;
	if guild.reqMemBool == false then
		table.insert(guildInfo,tostring('Failed to get all members in guild specified ('..guild.id..')'));
	end;
	table.insert(guildInfo,'Creation Date: '..discordia.Date.fromSnowflake(guild.id):toString());
	if guild.name ~= nil then
		table.insert(guildInfo,tostring('Name/Snowflake: '..guild.name..' | '..guild.id));
	end;
	if guild.owner ~= nil then
		table.insert(guildInfo,tostring('Owner/Snowflake: '..guild.owner.tag..' | '..guild.owner.id));
	elseif guild.ownerId ~= nil then
		local owner = guild:getMember(guild.ownerId);
		table.insert(guildInfo,tostring('Owner/Snowflake: '..owner.tag..' | '..owner.id));
	end;
	if guild.members ~= nil then
		local botCount,humanCount,totalCount = 0,0,0;
		for h,o in pairs(guild.members) do
			if o.bot then
				botCount = botCount + 1;
			else
				humanCount = humanCount + 1;
			end;
		end;
		totalCount = botCount+humanCount;
		table.insert(guildInfo,tostring('Members (Cached): '..totalCount..' (Humans:'..humanCount..', Bots:'..botCount..')'));
	end;
	if guild.totalMemberCount ~= nil then
		table.insert(guildInfo,tostring('Maximum members: '..guild.totalMemberCount));
	end;
	if guild.verificationLevel ~= nil then
		table.insert(guildInfo,tostring('Verification Level: '..discordia.enums.verificationLevel(guild.verificationLevel)));
	end;
	if guild.explicitContentSetting ~= nil then
		table.insert(guildInfo,tostring('Explicit content setting: '..discordia.enums.explicitContentLevel(guild.explicitContentSetting)));
	end;
	if guild.region ~= nil then
		table.insert(guildInfo,tostring('Voice Region: '..guild.region));
	end;
	if guild.premiumTier ~= nil and guild.premiumSubscriptionCount ~= nil then
		if guild.premiumSubscriptionCount ~= 1 then
			table.insert(guildInfo,tostring('Boost Tier: '..discordia.enums.premiumTier(guild.premiumTier)..' ('..guild.premiumSubscriptionCount..' boosters)'));
		else
			table.insert(guildInfo,tostring('Boost Tier: '..discordia.enums.premiumTier(guild.premiumTier)..' (1 booster)'));
		end;
	end;
	if guild.categories ~= nil then
		table.insert(guildInfo,tostring('Categories (Cached): '..#guild.categories));
	end;
	if guild.textChannels ~= nil then
		local publicCount = 0;
		for h,o in pairs(guild.textChannels) do
			if not o.private then
				publicCount = publicCount + 1;
			end;
		end;
		table.insert(guildInfo,tostring('Text Channels (Cached): '..#guild.textChannels..' ('..publicCount..' public)'));
	end;
	if guild.voiceChannels ~= nil then
		local publicCount,connectedMembers = 0,0;
		for h,o in pairs(guild.voiceChannels) do
			if not o.private then
				publicCount = publicCount + 1;
				connectedMembers = connectedMembers + #o.connectedMembers;
			end;
		end;
		table.insert(guildInfo,tostring('Voice Channels (Cached): '..#guild.voiceChannels..' ('..publicCount..' public, '..connectedMembers..' connected)'));
	end;
	print('B_INFO | Done getting guild info for '..guild.id);
	return guildInfo;
end;

return function(Commandments,Client)
	Commandments:addCmd('snowflakedate','Calculate date from a snowflake',function(msgObj,Parameter)
		if msgObj.author.id == Client.owner.id then msgObj:reply(discordia.Date.fromSnowflake(Parameter):toString()..', jackass'); end;
	end,'info');
	Commandments:addCmd('guildinfo','Get info of this guild',function(msgObj,Parameter)
		if msgObj.author.id ~= Client.owner.id then
			if msgObj.guild ~= nil then
				msgObj:reply("```http\n"..table.concat(getGuildInfo(Client,msgObj.guild),'\n').."\n```");
			else
				msgObj:reply('Sorry, this commandment can only be ran in servers');
			end;
		else
			if Parameter == '' then
				if msgObj.guild ~= nil then
					msgObj:reply("```http\n"..table.concat(getGuildInfo(Client,msgObj.guild),'\n').."\n```");
				else
					msgObj:reply('If you\'re not going to supply a parameter, then don\'t run this you dip');
				end;
			else
				local guildInfo = getGuildInfo(Client,Parameter);
				if guildInfo == nil then
					local author = msgObj.author;
					msgObj:delete(); -- hide secret
					author:send('Invalid snowflake, sorry');
				else
					msgObj:reply("```http\n"..table.concat(guildInfo,'\n').."\n```");
				end;
			end;
		end;
	end,'info');
	Commandments:addCmd('userinfo','Get info of yourself or another user',function(msgObj,Parameter)
		if Parameter == '' then
			if msgObj.guild == nil then
				msgObj:reply("```http\n"..table.concat(getUserInfo(Client,msgObj.author),'\n').."\n```");
			else
				msgObj:reply("```http\n"..table.concat(getUserInfo(Client,msgObj.member),'\n').."\n```");
			end;
		else
			if msgObj.guild ~= nil then
				if Parameter:sub(1,2) == '<@' then
					local fSub,sSub = Parameter:find('%b<>');
					Parameter = Parameter:sub(3,sSub-1);
				end;
				local userInfo = getUserInfo(Client,Parameter,msgObj.guild);
				if userInfo == nil then
					msgObj:reply('Invalid user');
				else
					msgObj:reply("```http\n"..table.concat(userInfo,'\n').."\n```");
				end;
			else
				if Parameter:sub(1,2) == '<@' then
					local fSub,sSub = Parameter:find('%b<>');
					Parameter = Parameter:sub(3,sSub-1);
				end;
				local userInfo = getUserInfo(Client,Parameter);
				if userInfo == nil then
					msgObj:reply('Invalid user');
				else
					msgObj:reply("```http\n"..table.concat(userInfo,'\n').."\n```");
				end;
			end;
		end;
	end,'info');
end;