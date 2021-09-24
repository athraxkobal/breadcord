local mod = {};
mod.Info = {
	Name = 'Basic Commands', shortName = 'base',
	Description = 'Holds barebones commands for bot maintanance and help',
	Author = 'athraxkobal',Url = 'https://github.com/athraxkobal/breadcord',
	Version = 'Tied with Breadcord',
};

local insert,concat,sort = table.insert,table.concat,table.sort;

---@param user table Discord User, Member, or snowflake id (string)
---@param guild table|nil The guild the ID or user is from
---@return string[]|nil #An array of strings
local function getUserInfo(user,guild)
	local Info = {};
	if type(user) == 'string' then
		if guild then user = guild:getMember(user); else user = Client:getUser(user); end;
	elseif type(user) == 'table' then
		if not guild then guild = user.guild; end;
	else
		return;
	end;
	insert(Info,'Tag: '..user.tag..' ('..user.id..')\nIs Bot?: '..tostring(user.bot));
	insert(Info,'Creation Date: '..discordia.Date.fromSnowflake(user.id):toString());
	if user.status ~= nil then
		insert(Info,tostring('Status: '..user.status));
	end;
	if user.avatar == nil then
		insert(Info,tostring('User has a default avatar ('..discordia.enums.defaultAvatar(user.defaultAvatar)..')'));
	end;
	if user.nickname then table.insert(Info,tostring('Nickname: '..user.nickname)); end;
	if #user.mutualGuilds > 1 then insert(Info,tostring('User shares '..#user.mutualGuilds..' guilds with me')); end;
	if guild then if user.id == guild.owner.id then insert(Info,'Member is owner of this guild'); end; end;
	if user.joinedAt then insert(Info,tostring('Joined at: '..discordia.Date.fromISO(user.joinedAt):toString())); end;
	if user.roles  then insert(Info,tostring('Number of roles: '..#user.roles)); end;
	if user.premiumSince ~= nil then
		insert(Info,tostring('Member\'s a paypig; Boosted guild at: '..discordia.Data.fromISO(user.premiumSince):toString()));
	end;

	-- stinky mo minky
	if user.voiceChannel then
		if user.voiceChannel.guild.id ~= user.guild.id then
			table.insert(Info,'Connected to an external VC');
		elseif user.voiceChannel.id == user.guild.afkChannelId then
				table.insert(Info,'Connected to the AFK VC');
		else
			if user.muted and user.deafened then
				table.insert(Info,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..'), but is both muted and deafened.'));
			elseif user.muted and (not user.deafened) then
				table.insert(Info,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..'), but is muted'));
			elseif (not user.muted) and user.deafened then
				table.insert(Info,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..'), but is deafened'));
			elseif not (user.muted and user.deafened) then
				table.insert(Info,tostring('Connected to '..user.voiceChannel.name..' ('..user.voiceChannel.id..')'));
			end;
		end;
	end;
	return Info;
end;

---@param guild table Guild object or snowflake id (string)
local function getGuildInfo(guild)
	local Info = {};
	print(tostring(guild));
	if type(guild) == 'string' then
		guild = Client:getGuild(guild);
	end;
	if not guild then return; end;
	insert(Info,'Guild snowflake: '..guild.id);
	insert(Info,'Creation Date: '..discordia.Date.fromSnowflake(guild.id):toString());
	if guild.unavailable then insert(Info,'Guild is unavailable; information may be obsolete and/or absent'); end;
	if guild.requestMembers then
		local reqMemBool = guild:requestMembers();
		if not reqMemBool then insert(Info,'I may not be able to obtain the full cached member count'); end;
	end;
	if guild.name then insert(Info,'Name: '..guild.name); end;
	if guild.owner then insert(Info,'Owner: '..guild.owner.tag..' ('..guild.owner.id..')'); end;
	if guild.ownerId then
		if not guild.owner then -- above if condition failed, lets try another way
			local owner = Client:getUser(guild.ownerId);
			if not owner then owner = guild:getMember(guild.ownerId); end;
			if owner then insert(Info,'Owner (Cached): '..owner.tag..' ('..owner.id..')');
			else insert(Info,'Could not get owner'); end;
		end;
		insert(Info,'Owner account creation date: '..discordia.Date.fromSnowflake(guild.ownerId):toString());
	end;
	if guild.joinedAt then
		insert(Info,'I was added at: '..discordia.Date.fromISO(guild.joinedAt):toString());
	end;
	if guild.members then
		local botCount,humanCount = 0,0;
		for i,v in pairs(guild.members) do if v.bot then botCount = botCount+1; else humanCount = humanCount+1; end; end;
		insert(Info,'Cached members: '..botCount+humanCount..' ('..humanCount..' human(s), '..botCount..' bot(s))');
	end;
	if guild.totalMemberCount then insert(Info,'True member count: '..guild.totalMemberCount); end;
	if guild.region then insert(Info,tostring('Voice Region: '..guild.region)); end;
	if guild.emojis then insert(Info,tostring('Custom emoji count: '..#guild.emojis)) end;
	if guild.verificationLevel then
		insert(Info,tostring('Verification Level: '..discordia.enums.verificationLevel(guild.verificationLevel)));
	end;
	if guild.explicitContentSetting then
		insert(Info,tostring('Explicit content setting: '..discordia.enums.explicitContentLevel(guild.explicitContentSetting)));
	end;
	if guild.premiumSubscriptionCount then
		if guild.premiumTier then
			insert(Info,'Boost Tier: '..discordia.enums.premiumTier(guild.premiumTier)..' ('..guild.premiumSubscriptionCount..' booster(s))')
		else insert(Info,'Boosters: '..guild.premiumSubscriptionCount); end;
	end;
	local totalCount,privateCount = 0,0; -- use for all 3, might as well count ourselves instead of using #
	if guild.categories then
		for i,v in pairs(guild.categories) do
			if v.private then privateCount = privateCount+1; end; totalCount = totalCount+1;
		end;
		insert(Info,'Cached categories: '..totalCount..' ('..totalCount-privateCount..' public)');
	end;
	if guild.textChannels then
		totalCount,privateCount = 0,0;
		for i,v in pairs(guild.textChannels) do
			if v.private then privateCount = privateCount+1; end;totalCount = totalCount+1;
		end;
		insert(Info,'Cached text channels: '..totalCount..' ('..totalCount-privateCount..' public)');
	end;
	if guild.voiceChannels then
		totalCount,privateCount = 0,0; local connectedMembers = 0;
		for i,v in pairs(guild.voiceChannels) do
			if v.private then privateCount = privateCount+1; end; totalCount = totalCount+1;
			connectedMembers = connectedMembers+#v.connectedMembers;
		end;
		insert(Info,'Cached voice channels: '..totalCount..' ('..totalCount-privateCount..' public, '..connectedMembers..' connected)');
	end;
	return Info;
end;

mod.Commands = {
	{
		Name = 'modulelist', Description = 'List all available modules',
		Function = function(msgObj,Parameter,splitParam)
			local modNames = {};
			for i,v in ipairs(Commandments.Modules) do
				insert(modNames,(v.Info.Name..' `'..v.Info.shortName..'` ('..#v.Commands..' cmds)'))
			end;
			sort(modNames); modNames = concat(modNames,', ');
			msgObj:reply('Current modules: '..modNames);
		end;
	},
	{
		Name = 'help', Description = 'Get help lol',
		Usage = '%s module <shortname> OR %s <command name/alias>',
		Function = function(msgObj,Parameter,splitParam)
			if Parameter == '' then
				return false;
			elseif splitParam[1] == 'module' then
				if splitParam[2] == nil then
					return false;
				else
					for i,v in pairs(Commandments.Modules) do
						if v.Info.shortName == splitParam[2] then
							local cmds = {};
							for ii,vv in pairs(v.Commands) do
								local Flags = vv.Flags;
								if not Flags then Flags = {'None'}; end;
								insert(cmds,'`'..vv.Name..'` : '..vv.Description..' | Flags: '..concat(Flags,', '))
							end;
							msgObj:reply('Commands for module '..v.Info.shortName..' ('..#cmds..' cmds):\n'..concat(cmds,'\n'));
						end;
					end;
				end;
			else
				local ourCommand,cmdstr;
				for i,cmd in pairs(Commandments._Commands) do -- copy paste le stuff from Commandments cmd search but better
					if splitParam[1] == cmd.Name then
						ourCommand = cmd; cmdstr = cmd.Name; break;
					end;
					if not ourCommand then
						if cmd.Aliases then
							for ii,alias in ipairs(cmd.Aliases) do
								if splitParam[1] == alias then
									ourCommand = cmd; cmdstr = alias; break;
								end;
							end;
						end;
					end;
				end;
				if ourCommand then
					local elTable = {};
					if ourCommand.Usage then
						local funnyBone,strCount = {},0;
						for i in string.gmatch(ourCommand.Usage,'%%s') do strCount = strCount+1; end;
						if strCount > 0 then
							for i=1,strCount do
								funnyBone[i] = ourCommand.Name;
							end;
						end;
						insert(elTable, 'Usage: '..string.format(ourCommand.Usage,unpack(funnyBone)));
					end;
					if ourCommand.Description then insert(elTable, 'Description: '..ourCommand.Description);
					else insert(elTable, 'No available description'); end;
					if ourCommand.Flags then insert(elTable,'Flags: '..concat(ourCommand.Flags,', ')); end;
					if ourCommand.Aliases then insert(elTable,'Available aliases: '..concat(ourCommand.Aliases,', ')); end;
					msgObj:reply('Command `'..ourCommand.Name..'`\n'..concat(elTable,'\n'));
				end;
			end;
		end;
	},
	{
		Name = 'stop', Description = 'Stop the bot',
		Flags = {'botowner'},
		Function = function(msgObj,Parameter,splitParam)
			msgObj:reply'Shutting down...'; Client:setGame(nil); Client:setStatus(discordia.enums.status.invisible); Client:stop();
		end;
	},
	{
		Name = 'setname', Description = 'Change bot name',
		Flags = {'botowner'},
		Function = function(msgObj,Parameter,splitParam)
			local Success = Client:setUsername(Parameter);
			if Success then
				msgObj:reply('Changed username to '..Parameter);
				print('base | Username changed to '..Parameter);
			else
				msgObj:reply'Failed to change username';
			end;
		end;
	},
	{
		Name = 'setgame', Description = 'Change bot\'s game',
		Flags = {'botowner'},
		Function = function(msgObj,Parameter,splitParam)
			if Parameter == '' then
				Client:setGame(nil);
				msgObj:reply'Removed game status';
			else
				if Parameter:sub(1,4) == '\\~_l' then
					Parameter = Parameter:sub(6);
					Client:setGame({name = Parameter,type = discordia.enums.activityType.listening});
					msgObj:reply('Set listening to '..Parameter);
				else
					Client:setGame(Parameter);
					msgObj:reply('Set game to '..Parameter);
				end;
			end;
		end;
	},
	{
		Name = 'exec', Description = 'Run some Lua',
		Flags = {'botowner'},
		Function = function(msgObj,Parameter,splitParam)
			local msgChannel = msgObj.channel; -- in case msgObj gets clapped
			local Environment = setmetatable({
				discordia = discordia;
				Client = Client;
				msgObj = msgObj;
				msgChannel = msgChannel;
				msgGuild = msgChannel.guild; -- in dms this is nil anyway
			},{__index = _G});
			function Environment.mprint(...) msgChannel:send(...); end;
			local function getReturns(Success,...)return Success,{...}; end;
			
			local chunkyFuncy,ldErr = loadstring('return '..Parameter,'botexec','t',Environment);
			if not chunkyFuncy then
				chunkyFuncy,ldErr = loadstring(Parameter,'botexec','t',Environment);
			end;
			if not chunkyFuncy then
				print('base | Syntax error:\n'..ldErr);
				if #ldErr <= 1986 then
					msgObj:reply('Syntax error:\n'..ldErr);
				else
					msgObj:reply('Syntax error:\n'..ldErr:sub(1,1986));
					msgObj:reply'Error truncated, check console for full';
				end;
			else
				local Success,Returns = getReturns(pcall(chunkyFuncy));
				if Success then
					print'base | Successfully ran exec';
					for i,v in pairs(Returns) do
						if type(v) == 'string' then 
							Returns[i] = '`\''..v..'\'`';
						elseif type(v) == 'number' then
							Returns[i] = '`'..v..'`';
						elseif type(v) ~= 'string' and type(v) ~= 'number' then
							Returns[i] = '`'..tostring(v)..'`';
						end;
					end;
					if #Returns >= 1 then
						msgChannel:send(concat(Returns,'	|	'));
					end;
				else
					print('base | exec error:\n'..Returns[1]);
					if #Returns[1] <= 1993 then
						msgChannel:send('Error:\n'..Returns[1]);
					else
						msgChannel:send('Error:\n'..Returns[1]:sub(1,1993));
						msgChannel:send'Error truncated, check console for full';
					end;
				end;
			end;
		end;
	},
	{
		Name = 'snowflakedate', Description = 'Calc date from snowflake id',
		Usage = '$s <snowflake or mention>',
		Function = function(msgObj,Parameter,splitParam)
			local id,type = Commandments:getMentionId(splitParam[1],msgObj);
			if id then
				msgObj:reply(discordia.Date.fromSnowflake(id):toString()..', jackass');
			else 
				local dateQM; local s,e = pcall(function() dateQM = discordia.Date.fromSnowflake(splitParam[1]:match('%d+')); end);
				if s then
					msgObj:reply(dateQM:toString()..', jackass');
				else
					msgObj:reply'That doesn\'t look like a valid snowflake';
				end;
			end;
		end;
	},
	{
		-- Comes with sneaky shizz!
		Name = 'guildinfo', Description = 'Get some info from the current guild',
		Function = function(msgObj,Parameter,splitParam)
			if msgObj.author.id == Client.owner.id then
				if Parameter == '' then
					if msgObj.guild then
						msgObj:reply("```http\n"..table.concat(getGuildInfo(msgObj.guild),'\n').."\n```");
					else
						msgObj:reply'Sorry, this commandment can only be ran in servers';
					end;
				else
					local Info = getGuildInfo(splitParam[1]);
					if not Info then
						local author = msgObj.author;
						msgObj:delete();
						author:send'Invalid snowflake, fucking idiot';
					else
						msgObj:reply('```\n'..table.concat(Info,'\n')..'\n```');
					end;
				end;
			else
				if msgObj.guild then
					msgObj:reply("```http\n"..table.concat(getGuildInfo(msgObj.guild),'\n').."\n```");
				else
					msgObj:reply('Sorry, this commandment can only be ran in servers');
				end;
			end;
		end;
	},
	{
		-- we both know you wanna stalk some people
		Name = 'userinfo', Description = 'Get some info of a user',
		Usage = '%s <mention>',
		Function = function(msgObj,Parameter,splitParam)
			if Parameter == '' then
				if msgObj.guild then
					msgObj:reply("```http\n"..table.concat(getUserInfo(msgObj.member),'\n').."\n```");
				else
					msgObj:reply("```http\n"..table.concat(getUserInfo(msgObj.author),'\n').."\n```");
				end;
			else
				local Info,user,type;
				user,type = Commandments:getMentionObj(splitParam[1],msgObj.guild); -- if not guild then itll just look for Client funcs
				if type == 'member' then -- not too necessary but why not
					Info = getUserInfo(user,msgObj.guild);
				elseif type == 'user' then
					Info = getUserInfo(user);
				else
					msgObj:reply'A ***user*** mention, boss'; return;
				end;
				if Info then
					msgObj:reply('```\n'..table.concat(Info,'\n')..'\n```');
				else
					msgObj:reply'Invalid user';
				end;
			end;
		end;
	},
};

function mod:messageCreate(msgObj,wasHandled,extranousInfo)
	if msgObj.content == 'IDQUIT' and msgObj.author.id == Client.owner.id then -- killswitch, just book it
		print'sad!';
		math.randomseed(os.time()); math.random(); math.random(); math.random();
		local quitmessages = { -- straight from the source lol, rip new lines
			"please don't leave, there's more demons to toast!",
			"let's beat it -- this is turning into a bloodbath!",
			"i wouldn't leave if i were you. dos is much worse.",
			"you're trying to say you like dos better than me, right?",
			"don't leave yet -- there's a demon around that corner!",
			"ya know, next time you come in here i'm gonna toast ya.",
			"go ahead and leave. see if i care.",
			"THIS IS NO MESSAGE! Page intentionally left blank."
		};
		local ourQuitMessage = quitmessages[math.random(1,#quitmessages)]:upper();
		msgObj:reply(ourQuitMessage..'\n(PRESS Y TO QUIT)\n:arrow_forward:	**YES**\n:stop_button:	NO'); -- dangerous tab characters
		Client:setGame(nil); Client:setStatus(discordia.enums.status.invisible); Client:stop();
	end;
end;


return mod;

