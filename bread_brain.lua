print('B_BRAIN | Go Go Go');

--[[
						|******************************|
						|		 Codename BREAD:	   |
						|		 The Very Shitty	   |
						|	  	 Lua Discord Bot	   |
						|******************************|
	
	This is rewrite #3 (technically)
	This version will be the master and the one to be publicized to Github.
	
	This version is probably the most competent looking one. Gives me a damn headache.
	
	This expects to be installed in in a subdirectory in luvit's folder
	Installed under system32 or some shit? Damn.
	Not like you'd want to run this shit anyway
	
	TODO
		do shit when i feel like it
]]--

local fs = require('fs');
local json = require('json');
local discordia = require('discordia');
local Client = discordia.Client();

local Config = {};
do
	local Success, errorMsg = fs.existsSync('./breadcord/bread_config.json');
	if not Success then
		error('B_BRAIN | Config file missing from directory, errorMsg '..tostring(errorMsg));
	else
		Config = json.decode(fs.readFileSync('./breadcord/bread_config.json'));
	end;
end;
local Commandments = require('./bread_commandments.lua')(Client);
Commandments.Prefix = Config.Prefix;

Client:on('ready',function()
	print('B_BRAIN | Logged in as '..Client.user.tag);
	Client:setStatus(discordia.enums.status.online);
	-- do other things
end);

Client:on('messageCreate',function(msgObj)
	if msgObj.author.id ~= Client.user.id then
		if msgObj.guild == nil then
			if msgObj.author.bot then -- this is purely for fun cause im bored lmao
				print('B_BRAIN | DM BOT '..msgObj.author.name..'#'..msgObj.author.discriminator..': '..msgObj.content);
				Client.owner:send('BOT '..msgObj.author.name..'#'..msgObj.author.discriminator..': '..msgObj.content);
			else
				-- print('B_BRAIN | DM '..msgObj.author.name..'#'..msgObj.author.discriminator..': '..msgObj.content); -- i aint gonna judge you if you gonna use my damn bot's dm as storage for your pron you filthy animal
				msgObj:reply('What the hell are you doing?');
			end;
		end;
		
		if msgObj.content:sub(1,#('<@!'..Client.user.id..'>')) == '<@!'..Client.user.id..'>' or msgObj.content:sub(1,#('<@'..Client.user.id..'>')) == '<@'..Client.user.id..'>' then
			print('got mention');
			msgObj:reply('<@'..msgObj.author.id..'>, my prefix is `'..Config.Prefix..'` Start getting that bread.');
		else
			Commandments.messageCreate(msgObj);
		end;
	end;
end);

Client:run('Bot '..Config.Token);