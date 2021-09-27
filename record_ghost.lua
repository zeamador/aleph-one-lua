Triggers = {}

function Triggers.init()
	Game.restore_passed()
	if Players[0]._ghosts == nil then
		Players[0]._ghosts = 0
		
		f = assert(io.open("ghost.lua", "w"))
		f:write("-- Ghost exported by record_ghost.lua\n")
		f:write("ghost = {\n")
	end
end

function Triggers.idle()
	if Players[0]._ghosts == 0 then
		if Game.ticks > 0 then
			f:write(",\n")
		end
		f:write("\t{x="..Players[0].x..
				",y="..Players[0].y..
				",z="..Players[0].z..
				",p="..Players[0].polygon.index..
				",f="..Players[0].direction.."}")
	end
end

function Triggers.cleanup()
	Players[0]._ghosts = 1
	f:write("\n}\n")
end
