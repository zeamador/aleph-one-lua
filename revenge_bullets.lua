-- revenge_bullets.lua
-- by aperturegrillz, 2021-08-15
-- Causes dying enemies to emit projectiles corresponding to their type.

Triggers = {}

PROJECTILE_COUNT = 7 -- number of projectiles
Z_JITTER = 0.5 -- range of Z randomization
PITCH_JITTER = 5 -- range of pitch randomization
YAW_JITTER = 10 -- range of yaw randomization

function Triggers.monster_killed(m, aggressor_player, projectile)
	Players.print("monster died "..m.type.mnemonic)
	local t = projType(m)
	if t ~= nil then
		local n = PROJECTILE_COUNT
		for i = 0, n, 1 do
			local zjitter = Z_JITTER/2 + math.random()*Z_JITTER
			local p = Projectiles.new(m.x, m.y, m.z+zjitter, m.polygon, t)
			p.target = aggressor_player
			local pitchjitter = math.random()*PITCH_JITTER - PITCH_JITTER/2
			-- make ballistics bias upwards
			if t == "trooper grenade" then
				pitchjitter = pitchjitter + 3
			end
			p.elevation = pitchjitter
			local yawjitter = math.random()*YAW_JITTER - YAW_JITTER/2
			p.facing = m.facing + yawjitter
		end
	end
end

do
	local proj
	function projType(monster)
		proj = proj or {
			["player"] = nil,
			["minor tick"] = nil,
			["major tick"] = nil,
			["minor compiler"] = "compiler bolt minor",
			["major compiler"] = "compiler bolt major",
			["minor invisible compiler"] = "compiler bolt minor",
			["major invisible compiler"] = "compiler bolt major",
			["minor fighter"] = nil,
			["major fighter"] = nil,
			["minor projectile fighter"] = "staff bolt",
			["major projectile fighter"] = "staff bolt",
			["green bob"] = "pistol bullet",
			["blue bob"] = "pistol bullet",
			["security bob"] = "pistol bullet",
			["explodabob"] = nil,
			["minor drone"] = "minor hummer",
			["major drone"] = "major hummer",
			["big minor drone"] = "minor hummer",
			["big major drone"] = "major hummer",
			["possessed drone"] = "durandal hummer",
			["minor cyborg"] = "minor cyborg ball",
			["major cyborg"] = "major cyborg ball",
			["minor flame cyborg"] = "minor cyborg ball",
			["major flame cyborg"] = "major cyborg ball",
			["minor enforcer"] = "alien weapon",
			["major enforcer"] = "alien weapon",
			["minor hunter"] = "hunter",
			["major hunter"] = "hunter",
			["minor trooper"] = "trooper grenade",
			["major trooper"] = "trooper grenade",
			["mother of all cyborgs"] = "major cyborg ball",
			["mother of all hunters"] = "hunter",
			["sewage yeti"] = "sewage yeti",
			["water yeti"] = nil,
			["lava yeti"] = "lava yeti",
			["minor defender"] = "minor defender",
			["major defender"] = "major defender",
			["minor juggernaut"] = "juggernaut missile",
			["major juggernaut"] = "juggernaut missile",
			["tiny pfhor"] = nil,
			["tiny bob"] = nil,
			["tiny yeti"] = nil,
			["green vacbob"] = "fusion bolt major",
			["blue vacbob"] = "fusion bolt major",
			["security vacbob"] = "fusion bolt major",
			["explodavacbob"] = nil
		}
		return proj[monster.type.mnemonic]
	end
end