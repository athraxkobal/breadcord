local mod = {};
mod.Info = {
	Name = 'Funnies', shortName = 'fun',
	Description = 'Impliments some fun/joke commands',
	Author = 'athraxkobal', Url = 'github.com/athraxkobal/breadcord',
	Version = 'Tied with Breadcord',
}

math.randomseed(os.time());

local eBallQuotes = {
	'It is certain','It is decidedly so','Without a doubt','Yes definitely','You may rely on it',
	'As I see it, yes','Most likely','Outlook good','Yes','Signs point to yes','Reply hazy try again',
	'Ask again later','Better not tell you now','Cannot predict now','Concentrate and ask again',
	'Don\'t count on it','My reply is no','My sources say no','Outlook not so good','Very doubtful'
};

local funniesPath = './breadcord/mods/funnies/';
local flashbangGifContent = fs.readFileSync(funniesPath..'flashbang.gif'); -- meh, its 360 kb, ill let it sit in memory for now

mod.Commands = {
	{
		Name = 'f', Description = 'Send F to pay respects.',
		Function = function(msgObj)
			if msgObj.guild == nil then msgObj:reply('Look at this fool, man. Get a grip of yourself.'); else
				if math.random(1,5) == 3 then msgObj.reply {
					content = ' > Using the F command\nngmi',
					reference = {message = msgObj, mention = false}
				};
				else msgObj:reply('*<@'..msgObj.author.id..'> __has paid their respects.__*'); end;
			end;
		end;
	},
	{
		Name = '8ball',Description = 'The 8 ball tells all',
		Usage = '%s <a question with ?>',
		Function = function(msgObj,Parameter)
			if Parameter:match('%?$') == '?' then
				msgObj:reply('<@'..msgObj.author.id..'>'..'\n8Ball: `'..eBallQuotes[math.random(1,#eBallQuotes)]..'`');
			else
				msgObj:reply('That isn\'t a question!');
			end;
		end;
	},
	{
		Name = 'flashbang', Description = 'Bang y\'er mates',
		Usage = 'Think fast.',
		Flags = {'inguild'},
		Function = function(msgObj)
			msgObj:reply {
				file = {'flashbang.gif',flashbangGifContent}
			};
		end;
	},
};

return mod;