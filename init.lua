print'INIT Le-Let\'s Go!';
--[[
						|******************************|
						|			BREADCORD:		   |
						|		 The Very Shitty	   |
						|		Lua Discord Bot		   |
						|******************************|

		Rewrite 5, rewrite of a rewrite.
		Rewrite 4 belonged in the trash so I got rewrote most of this from scratch.
		I'm a lazy ass buster but I seek perfection (a joke coming from me)
		I moved from N++ to VSC with the Lua plugin by sumneko, you'll see *some* annotation here
		I hope Discordia 3.0 is baked pretty good
	~ athraxkobal

	This bot uses SinisterRectus/Discordia on github to run on the Luvit runtime.

	init.lua: Init bot and ready the command handler, currently reactionary only
	Note: Assumes luvit is ran in the same folder as breadcord!
]]

local fs = require'fs'; local json = require'json'; local discordia = require'discordia'; local Commandments = {};
local Client = discordia.Client(); local Config = {}; local Token = '';

local deRancho = 'si señor, yo soy';
do
	local configFile,erreerreahh = io.open('./breadcord/config.json','r');
	if configFile then
		Config = json.decode(configFile:read('*a')); configFile:close();
		Token = Config.Token; Config.Token = nil;
		assert(Token ~= 'YOUR_BOT_TOKEN_HERE' or Token ~= '' or Token ~= ' ','You must supply a valid token in config.json');
		assert(Config.Prefix ~= '' or Config.Prefix:sub(1,1) ~= ' ','Prefix can not be empty/begin with whitespace'); -- simple check too lazy
		Config.Token = nil;
		deRancho = setmetatable({
			Config = Config; discordia = discordia, Client = Client, Commandments = Commandments,
			fs = fs, json = json -- rather not potentially require these twice
		},{__index = _G});
		local comCode = assert(fs.readFileSync('./breadcord/commandments.lua'));
		local theInnerMechanismsOfMyMindAreAnEnigma = assert(loadstring(comCode,'commandments.lua','t',deRancho));
		theInnerMechanismsOfMyMindAreAnEnigma();
	else
		local whyDoYouDoThis = io.open('./breadcord/config.json','w');
		whyDoYouDoThis:write(json.encode({Prefix='bd_',Token='YOUR_BOT_TOKEN_HERE'}));
		whyDoYouDoThis:flush(); whyDoYouDoThis:close();
		error('config.json missing, supply a bot token in the created config.json file.');
	end;
end;

Client:on('ready',function()
	print('Main: Logged in as '..Client.user .tag); Client:setStatus(discordia.enums.status.online);
end);

Client:on('messageCreate',function(msgObj)
	local wasHandled,extranousInfo;
	if msgObj.author.id ~= Client.user.id then
		if msgObj.content:match'^<@!?(%d+)>' == Client.user.id then -- matches <@id> or <@!id>
			msgObj:reply('<@!'..msgObj.author.id..'>, my prefix is `'..Config.Prefix..'` Start getting that bread.');
		elseif msgObj.content:sub(1,#Config.Prefix) == Config.Prefix then -- bruh
			wasHandled,extranousInfo = Commandments:messageCreate(msgObj,msgObj.content:sub(#Config.Prefix+1));
			if not wasHandled then
				if msgObj.guild then -- Don't spit "That's not a command" as a reply as it can be spammed
					print('Main: Anon tried doing '..msgObj.content..' in a server');
				else print('Main: Anon tried doing '..msgObj.content..' in a DM'); end;
			end;
		else
			if msgObj.guild == nil then msgObj:reply'Why yes I\'m also a spastic, just like you.'; end;
		end;
	end;
	Commandments:lessgooo(msgObj,wasHandled,extranousInfo);
end);

Client:run('Bot '..Token);