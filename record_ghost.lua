-- record_ghost.lua
-- by aperturegrillz
-- Records a "ghost" of a given play and outputs it as 'ghost.lua'

Triggers = {}

function Triggers.init()
	Game.restore_passed()
	if Players[0]._levels == nil then
		Players[0]._levels = 0
		
		f = assert(io.open("ghost.lua", "w"))
		f:write("-- Ghost exported by record_ghost.lua\n")
		f:write("ghost = {}\n")
	else
		Players[0]._levels = Players[0]._levels + 1
		f = assert(io.open("ghost.lua", "a"))
	end
	f:write("ghost[" .. Level.index .. "]={\n")
end

function Triggers.idle()
	f:write("["..Game.ticks.."]={"..
			"x="..Players[0].x..
			",y="..Players[0].y..
			",z="..Players[0].z..
			",p="..Players[0].polygon.index..
			",f="..Players[0].direction.."},\n")
end

function Triggers.cleanup()
	f:write("}\n")
end
