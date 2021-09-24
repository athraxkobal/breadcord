local mod = {};
-- Table of information for your module
-- Extranous information will be added to this table at runtime (like filename, order loaded, etc) for debugging
-- Please use unique Name and shortName values
---@type table<string, string>
mod.Info = {
	Name = 'Template', Author = 'your funny alter ego name',
	shortName = 'templ', Version = '0.0.0', Url = 'github.com/yourfunnyalteregoname',
	Description = 'Module template and list of all available features'
};

--[[
	Things to note:
	-	If you have a duplicated command that has the same name as another module and you have no unique aliases,
	the command will be deleted and a warning will be output to the console that contains
		The names, shortnames, and filename of the modules
		The names, aliases, and flags of the 2 (or more) offending commands
	The module that was registered first will have it's command kept
	Same with duplicated aliases, but will simply have the offending alias logged and removed
	-	Commandments, discordia, Client, Config (as of writing it only contains Prefix), fs, and json are defined globals
]]

-- Place your commands in this table
---@type table<string, any>
mod.Commands = {};
table.insert(mod.Commands,{
	-- Main name of the command
	---@type string
	Name = 'testcmd',
	-- Any alternative names for this command, is restricted to 3, don't make too long
	---@type string[]|nil
	Aliases = {'examplecmd','tackycmdsys'},
	-- A description of the command, don't make too long
	---@type string
	Description = 'Example command',
	-- Will display when a command returns false for it's usage, all occurrences of %s will be replaced by the name of the command
	-- or alias used. If you return false (not nil!) and this field exists, it will be used to display a simple "Usage: ..." msg
	Usage = '',
	-- Flags (found in Commandments) for this command to even be called
	---@type string[]|nil
	Flags = {
		'inguild'
	},
	---@type function
	---@param msgObj table The Discord message
	---@param Parameter string Message text (raw) with command trimmed out
	---@param splitParam string[] The Parameter but all words (or s h i t  l i k e  t h i s) split into a table
	Function = function(msgObj,Parameter,splitParam)
		-- do stuff
	end;
});


-- Note: other than messageCreate (for obvious reasons), feel free to use Client's Emmitter functions here

-- If you define messageCreate, Commandments will call this function after command handling
---@param msgObj table the discordia Message
---@param wasHandled boolean|nil if a module handled this msg as a command, this will be true
---@param extranousInfo? table if wasHandled, this will have mod name, mod shortname, and the cmd name
function mod:messageCreate(msgObj,wasHandled,extranousInfo)
	-- do stuff with msg (expectedly, if wasHandled is false, of course)
end;

return mod;