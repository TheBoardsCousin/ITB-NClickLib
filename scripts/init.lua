local mod = {
	id = "TBC_NClick",
	name = "NClickLib",
	icon = "icon.png",
	description = "A library allowing for the creation of NClick weapons",
	version = "1.0",
	modApiVersion = "2.8.3",
	gameVersion = "1.2.88",
}

function mod:init()
	require(self.scriptPath .."libs/NClickLib")
end

function mod:load(options, version)
end

return mod