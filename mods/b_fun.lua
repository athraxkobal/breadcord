local discordia = require('discordia');
local thisMod = 'fun';
local eightBallQuotes = {'It is certain','It is decidedly so','Without a doubt','Yes definitely',' You may rely on it',
	'As I see it, yes','Most likely','Outlook good','Yes','Signs point to yes','Reply hazy try again',
	'Ask again later','Better not tell you now','Cannot predict now','Concentrate and ask again',
	"Don't count on it",'My reply is no','My sources say no','Outlook not so good','Very doubtful'
};

return function(Commandments,Client)
	Commandments:addCmd('f','Send F to pay respects.',function(msgObj,Parameter)
		if msgObj.guild ~= nil then
			msgObj:reply('*<@'..msgObj.author.id..'> __has paid their respects.__*');
		else
			msgObj:reply('Look at this fool, man. Get a grip of yourself.');
		end;
	end,thisMod);
	Commandments:addCmd('8ball','Just shake it. You know you want to.',function(msgObj,Parameter)
		if Parameter:match('%?$') == '?' then
			msgObj:reply('<@'..msgObj.author.id..'>'..'\n8Ball: `'..eightBallQuotes[math.random(1,#eightBallQuotes)]..'`');
		else
			msgObj:reply('That isn\'t a question!');
		end;
	end,thisMod);
	return thisMod;
end;