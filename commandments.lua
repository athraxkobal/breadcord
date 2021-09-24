print'Commandments: Yeah, I got the picture';
-- commandments.lua: Command handler

-- holds the modules lol
---@type table[]
Commandments.Modules = {};
Commandments._Commands = {}; -- Array of references to all commands in all modules for simplicity
--[[Flags you will be allowed to use (case-insensitive).
Just have an array of strings (again, case-insensitive) called Flags in your command obj and it will be taken care of by the handler.

You can use permission names as flags, see discordia\libs\enums.lua [enums.permission wiki link](https://github.com/SinisterRectus/Discordia/wiki/Enumerations#permission)

Note: Will error if you have both indm and inguild cause I don't like your humor]]
---@type table<string, function>
Commandments.Flags = {
	['botowner'] = function(msgObj) return msgObj.author.id == Client.owner.id; end,
	['indm'] = function(msgObj) return msgObj.guild == nil; end,['inguild'] = function(msgObj) return msgObj.guild ~= nil end,
	['guildowner'] = function(msgObj)
		if msgObj.guild and not msgObj.guild.unavailable then return msgObj.author.id == msgObj.guild.ownerId; end;
		return false;
	end,
};
for enum,v in pairs(discordia.enums.permission) do
	Commandments.Flags[enum:lower()] = function(msgObj)
		if msgObj.guild then
			local memberRoles = msgObj.member.roles;
			for ii,role in pairs(memberRoles) do
				if msgObj.author.id == msgObj.guild.owner.id then return true; end;
				local Permissions = role:getPermissions();
				if Permissions:has(enum) or Permissions:has('administrator') then return true; end;
			end;return false;
		end;
	end;
end;

-- To be used with splitParam (or anything else if you want).
-- Uses string.match, not gmatch, be wary
---@param text string The text to check for mention
---@param guild table|nil Discord Guild
---@return table|nil obj The object
---@return string|nil type The object type (member, user, role, channel)
---@return string|nil snowflake
function Commandments:getMentionObj(text, guild)
	local snowflake;
	if text then
		snowflake = text:match'<@!?(%d+)>';
		if snowflake then
			if guild then return guild:getMember(snowflake),'member',snowflake; else
			return Client:getUser(snowflake),'user',snowflake; end;
		else
			snowflake = text:match'<@&(%d+)>';
			if snowflake then
				if guild then return guild:getRole(snowflake),'role',snowflake; else
				return Client:getRole(snowflake),'role',snowflake; end;
			else
				snowflake = text:match'<@#(%d+)>';
				if snowflake then
					if guild then return guild:getChannel(snowflake),'channel',snowflake; else
					return Client:getChannel(snowflake),'channel',snowflake; end;
				end;
			end;
		end;
	end;
end;

-- To be used with splitParam
--
-- Complimentary with getMentionObj, useful for when the object is not necessarily needed immediately or required
---@param text string The text to check for mention
---@return string|nil snowflake The snowflake id
---@return string|nil type The mention type (member, user, role, channel)
function Commandments:getMentionId(text)
	local snowflake;
	if text then
		snowflake = text:match'<@!?(%d+)>';
		if snowflake then
			return snowflake,'user';
		else
			snowflake = text:match'<@&(%d+)>';
			if snowflake then
				return snowflake,'role';
			else
				snowflake = text:match'<@#(%d+)>';
				if snowflake then
					return snowflake,'channel';
				end;
			end;
		end;
	end;
end;

function Commandments:messageCreate(msgObj,Parameter)
	local wasHandled = false;
	local extranousInfo,ourCommand,cmdstr;
	if msgObj.member then print'valid member'; end;
	if msgObj.author then print'valid author'; end;
	if msgObj.content then print'valid content'; end;
	if msgObj.channel then print'valid channel'; end;
	print('Commandments attempting to check '..msgObj.author.tag..'\'s request to execute \''..Parameter..'\'');
	-- init already checks prefix
	for i,cmd in ipairs(Commandments._Commands) do
		-- print('Checking cmd '..i.. ' | '..cmd.Name..' from '..cmd._Module.Info.shortName);
		if Parameter:sub(1,#cmd.Name) == cmd.Name then
			local spaceCheck = Parameter:sub(#cmd.Name+1,#cmd.Name+1);
			if spaceCheck == '' then
				ourCommand = cmd; Parameter = ''; cmdstr = cmd.Name; break;
			elseif spaceCheck == ' ' then
				ourCommand = cmd; Parameter = Parameter:sub(#cmd.Name+2); cmdstr = cmd.Name; break;
			end;
		end;
		if not ourCommand then
			if cmd.Aliases then
				for ii,alias in ipairs(cmd.Aliases) do
					if Parameter:sub(1,#alias) == #alias then
						local spaceCheck = Parameter:sub(#alias+1,#alias+1);
						if spaceCheck == '' then
							ourCommand = cmd; Parameter = ''; cmdstr = alias; break;
						elseif spaceCheck == ' ' then
							ourCommand = cmd; Parameter = Parameter:sub(#alias+2); cmdstr = alias; break;
						end;
					end;
				end;
			end;
		end;
	end;
	if ourCommand then
		print('Our command is '..ourCommand.Name..' | Parameter: ('..Parameter..')');
		-- check flags
		local cappedFlag,sadFlag = true,'';
		if ourCommand.Flags then
			for i,flag in ipairs(ourCommand.Flags) do
				cappedFlag = self.Flags[flag](msgObj);
				if not cappedFlag then sadFlag = flag; break; end;
			end;
		end;
		if not cappedFlag then
			msgObj:reply('<@'..msgObj.author.id..'>, you can\'t run because flag '..sadFlag..' isn\'t satisfied!');
		else
			local splitParam = {};
			for i in string.gmatch(Parameter,'[%w%p]+') do table.insert(splitParam,i); end;
			local usedCorrectly = ourCommand.Function(msgObj,Parameter,splitParam);
			if usedCorrectly == false and ourCommand.Usage then
				local funnyBone,strCount = {},0;
				for i in string.gmatch(ourCommand.Usage,'%%s') do strCount = strCount+1; end;
				if strCount > 0 then
					for i=1,strCount do
						funnyBone[i] = cmdstr;
					end;
				end;
				msgObj:reply('Usage: '..string.format(ourCommand.Usage,unpack(funnyBone)));
			end;
			wasHandled = true; extranousInfo = {
				modName = ourCommand._Module.Info.Name,
				modShortName = ourCommand._Module.Info.shortName,
				cmdName = ourCommand.Name,
				mod = ourCommand._Module,
				cmd = ourCommand,
			};
		end;
	end;
	return wasHandled,extranousInfo;
end;

function Commandments:lessgooo(msgObj,wasHandled,extranousInfo)
	for i,v in ipairs(self.Modules) do
		if v.messageCreate then
			local s,er = pcall(function() v.messageCreate(v,msgObj,wasHandled,extranousInfo) end);
			if not s then print('Commandments: Module '..v.Info.Name..' ('..v.Info.fileName..')\'s messageCreate function errored: '..er); end;
		end;
	end;
end;

for modFName,typelol in fs.scandirSync'./breadcord/mods/' do
	print('Iterating '..tostring(modFName)..' ('..tostring(typelol)..')');
	if modFName and typelol == 'file' then
		if modFName:sub(-4) == '.lua' then
			print('Commandments loading '..modFName);
			local Environment = setmetatable({
				Config = Config, discordia = discordia, Client = Client, Commandments = Commandments, json = json, fs = fs
			},{__index = _G});
			local modCode = assert(fs.readFileSync('./breadcord/mods/'..modFName));
			local modFunc = assert(loadstring(modCode,'MODULE '..modFName,'t',Environment));
			local ourMod = modFunc(); table.insert(Commandments.Modules,ourMod);
			local oMI = ourMod.Info; oMI.fileName = modFName; oMI.Index = #Commandments.Modules; oMI.shortName = oMI.shortName:lower();
			print('Commandments loaded '..modFName..' : \"'..oMI.Name..'\" ('..oMI.shortName..') #'..oMI.Index..' | '..#ourMod.Commands..' commands');
			for ii,command in ipairs(ourMod.Commands) do
				command.Name = command.Name:lower(); command._Module = ourMod;
				assert(command.Name ~= 'module','This module has a command named \'module\' that is a reserve name!');
				if command.Aliases then
					for iii,v in ipairs(command.Aliases) do
						v = v:lower();
						command.Aliases[iii] = v;
						assert(v ~= 'module','This module lists a command named '..command.Name..' with an alias named \'module\', this is a reserved name!');
					end;
				end;
				if command.Flags then
					for iii,v in ipairs(command.Flags) do
						local indm,inguild = false,false;
						v = v:lower();
						command.Flags[iii] = v;
						if v == 'indm' then indm = true; end;
						if v == 'inguild' then inguild = true; end;
						assert(not (indm and inguild),'This module has a command named '..command.Name..' with opposing flags indm and inguild!')
					end;
				end;
				table.insert(Commandments._Commands,command);
			end;
		end;
	end;
end;

do
	local cmdstr = {};
	local cmdCount = 0;
	print('listing '..#Commandments._Commands);
	for i,v in ipairs(Commandments._Commands) do
		print(i.. ' | '..v.Name..' from '..v._Module.Info.shortName);
	end;
end;

-- very dirty and a gut feeling this is a bit memory intensive, i dont know how this could be done any better for now
do
	---@type table<number, table[]>
	local repeatedNames = {};
	for i,command in ipairs(Commandments._Commands) do
		if not repeatedNames[command.Name] then repeatedNames[command.Name] = {command};
		else
			table.insert(repeatedNames[command.Name],command);
		end;
		if command.Aliases then
			for ii,vv in command.Aliases do
				if not repeatedNames[vv] then
					repeatedNames[vv] = {command};
				else
					table.insert(repeatedNames[vv],command);
				end;
			end;
		end;
	end;
	-- My original intent was to remove any duplicates at runtime, but I realize its probably easier for me to want to do, so
	-- I decided on just letting the user (at least i hope theres a user) know what went wrong
	-- Will also write the grievances to breadcord_bad_repeatedcommands.txt (feel free to delete when the issues are resolved)
	local poundTheAlarm = 0; local theMagicFileman = '';
	local function Append(text)
		theMagicFileman = theMagicFileman..''..text..'\n';
	end;
	local function isCmdAliasOf(command,text)
		if command.Aliases == nil then return false; end;
		for i,v in ipairs(command.Aliases) do
			if v == text then return true; end;
		end;
		return false;
	end;
	for i,v in pairs(repeatedNames) do
		if #v > 1 then -- we got a winner(s)!
			poundTheAlarm = poundTheAlarm+1;
			print('Commandments: '..i..' is a repeated command with '..#v..' duplicates!')
			Append('Repeated command \"'..i..'\" '..#v..' times!');
			local offendingModules = {};
			for ii,entry in ipairs(v) do
				if isCmdAliasOf(entry,i) then -- Command objects don't have numbered keys
					table.insert(offendingModules,entry._Mod.Info.Name..' ('..entry._Mod.Info.fileName..', Aliased!)');
				else
					table.insert(offendingModules,entry._Mod.Info.Name..' ('..entry._Mod.Info.fileName..')');
				end;
			end;
			offendingModules = table.concat(offendingModules,', ');
			print('offendingModules = '..offendingModules);
			Append('Offending modules for \"'..i..'\": '..offendingModules);
		end;
	end;
	if poundTheAlarm > 0 then
		Append(poundTheAlarm..' repeated commands');
		Append('\n\nPlease rectify these issues, and feel free to ask for help, never hurts to just ask!');
		fs.writeFileSync('breadcord_bad_repeatedcommands.txt',theMagicFileman);
		print'Please rectify these issues, feel free to seek help, it never hurts to ask!\nThe information has also been dumped to breadcord_bad_repeatedcommands.txt\nPress any key to exit';
		os.execute'pause'; -- evil :P
		os.exit(1); -- i love you
	end;
	print'repeatedNames check pass';
end;