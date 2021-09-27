-- Marathon speedrunning practice script
-- by aperturegrillz

-- This script provides information readouts and helper functions for
-- practicing Marathon speedrunning (or Vidmastering, testing maps, etc).
-- Displays:
-- - in-game timer which will show the split time of the last level
-- - level requirement flags
--     Ext: Extermination
--     Exp: Exploration
--     Low: Low Gravity
--     Mag: Magnetic
--     Reb: Rebellion
--     Rep: Repair
--     Res: Rescue
--     Ret: Retrieval
--     Vac: Vacuum
-- - Player's external velocity (x, y, and z components)
-- - Player's exact health value
-- - Level completion state
-- - Count of monsters left alive (and how many are active now)

-- The game will be saved at each level transition.

-- The helper functions:
-- - s(): save the game
-- - k(): kill yourself so you can restart from a save quickly
-- - l(number): set life to <number>. 150 is 1X, 300 is 2X, and 450 is 3X.
-- - o(number): set oxygen to <number>, from 0 to 10800
-- - i(): set yourself to be invincible for a long time (note that k() will
--       still kill you, as will fusion bolts)
-- - l(): increase your life to the next full bar
-- - o2(): recharge oxygen to full
-- - bye(): get an invisibility item
-- - inv(): get an invincibility item
-- - wow(): get an extravision item
-- - mag(): get a pistol
-- - ar(): get an assault rifle
-- - spnkr(): get a missile launcher
-- - tozt(): get a flamethrower
-- - zeus(): get a fusion pistol
-- - wste(): get a shotgun
-- - smg(): get an SMG
-- - alien(): get an alien weapon
-- - ammo(): get more ammo for all weapons
-- - stuff(): get everything: full 3X health, all weapons, and ammo

Triggers = {}

function s()
  Game.save()
end

function k()
  Players[0]:damage(1000, "fusion")
end

function l(num)
  Players[0].life = num
end

function o(num)
   Players[0].oxygen = num
end

function i()
  Players[0].invincibility_duration = 32000
end

function Triggers.idle()
  for p in Players() do
    if Players[0]._this_start ~= 0 and Game.ticks - Players[0]._this_start < 3*30 then
      p.overlays[0].text = game_time_str(Players[0]._this_start - Players[0]._last_start)
      p.overlays[0].color = "yellow"
    else
      p.overlays[0].text = game_time_str(Game.ticks)
      p.overlays[0].color = "white"
    end
	--p.overlays[1].text = level_info()
	if p.weapons.current ~= nil then
	  p.overlays[1].text = string.format("%d %d", p.weapons.current.primary.rounds, p.weapons.current.secondary.rounds)
	end
    p.overlays[2].text = string.format("%.1f %.1f %.1f", p.external_velocity.x, p.external_velocity.y, p.external_velocity.z)
    if p.dead then
      p.overlays[3].text = "RIP"
    else
      p.overlays[3].text = string.format("%03d", p.life).."HP"
    end
    --p.overlays[3].color = life_color(p.life)
    local completion = Level.calculate_completion_state()
    p.overlays[4].text = completion_str(completion)
    p.overlays[4].color = completion_color(completion)
    p.overlays[3].text = monster_count()
  end
end

function monster_count()
  count = 0
  active = 0
  for m in Monsters() do
    if not m.player and m.type.enemies["player"] == true then
	  count = count + 1
	  if m.active then
	    active = active + 1
	  end
	end
  end
  return string.format("%d(%d)", count, active)
end

function Triggers.tag_switch(tag, player, side)
  Players.print("Tag switch")
end

function Triggers.light_switch(light, player, side)
  Players.print("Light switch")
end

function Triggers.platform_switch(polygon, player, side)
  Players.print("Platform switch")
end

function Triggers.projectile_switch(projectile, side)
  Players.print("Projectile switch")
end

function Triggers.monster_damaged(monster, aggressor_monster, damage_type, damage_amount, projectile)
  if projectile ~= nil then
    proj = projectile.type.mnemonic
  else
    proj = ""
  end
  Players.print(
    monster.type.class.mnemonic
    .." "
    ..damage_amount+monster.vitality
    .."-"
    ..damage_amount
    .." "
    ..proj)
end

function Triggers.player_damaged(victim, aggressor_player, aggressor_monster, damage_type, damage_amount, projectile)
  Players.print(victim.name.." -"..damage_amount)
end

function Triggers.init()
  Game.restore_passed()
  if Players[0]._last_start == nil then
    Players[0]._last_start = 0
  else
    Game.save()
  end
  Players[0]._this_start = Game.ticks
end

-- Save the time of the start of this level
-- so we can restore it at the start of the next one.
function Triggers.cleanup()
  Players[0]._last_start = Players[0]._this_start
end

function int_speed(vel)
  return math.sqrt(vel.forward*vel.forward + vel.perpendicular*vel.perpendicular)
end

function ext_speed(vel)
  return math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
end

function level_info()
  local info = ""
  if Level.extermination then
    info = info.."Ext"
  end
  if Level.exploration then
    info = info.."Exp"
  end
  if Level.low_gravity then
    info = info.."Low"
  end
  if Level.magnetic then
    info = info.."Mag"
  end
  if Level.rebellion then
    info = info.."Reb"
  end
  if Level.repair then
    info = info.."Rep"
  end
  if Level.rescue then
    info = info.."Res"
  end
  if Level.retrieval then
    info = info.."Ret"
  end
  if Level.vacuum then
    info = info.."Vac"
  end
  if info == "" then
    info = "None"
  end
  return info
end

function ammo_info()
  return 
end

function completion_str(state)
  if state == "unfinished" then
    return "Incomplete"
  elseif state == "finished" then
    return "Complete"
  elseif state == "failed" then
    return "Failed"
  end
end

function completion_color(state)
  if state == "unfinished" then
    return "white"
  elseif state == "finished" then
    return "green"
  elseif state == "failed" then
    return "red"
  end
end

function life_color(life)
  if life <= 150 then
    return "red"
  elseif life <= 300 then
    return "yellow"
  else
    return "blue"
  end
end

function game_time_str(ticks)
  if ticks <= 0 then
    return "0:00:00.000";
  else
    local ticks = tonumber(ticks)
    local sec = ticks / 30
    local remainder = ticks % 30

    hours = string.format("%01.f", math.floor(sec/3600))
    mins = string.format("%02.f", math.floor(sec/60 - (hours*60)))
    secs = string.format("%02.f", math.floor(sec - hours*3600 - mins *60))
    msecs = string.format("%03.0f", remainder*33.33)
    return hours..":"..mins..":"..secs.."."..msecs
  end
end

function l()
   if Players[0].life < 150 then 
      Players[0].life = 150
   elseif Players[0].life < 300 then
      Players[0].life = 300
   elseif Players[0].life < 450 then
      Players[0].life = 450
   end
end

function o2()
   Players[0].oxygen = 10800
end

function bye()
   Players[0].items["invisibility"] = 1
end

function inv()
   Players[0].items["invincibility"] = 1
end

function wow()
   Players[0].items["extravision"] = 1
end

function mag()
   local items = Players[0].items
   items["pistol"] = items["pistol"] + 1
   items["pistol ammo"] = items["pistol ammo"] + 10
end

function ar()
   local items = Players[0].items
   items["assault rifle"] = items["assault rifle"] + 1
   items["assault rifle ammo"] = items["assault rifle ammo"] + 10
   items["assault rifle grenades"] = items["assault rifle grenades"] + 10
end

function spnkr()
   local items = Players[0].items
   items["missile launcher"] = items["missile launcher"] + 1
   items["missile launcher ammo"] = items["missile launcher ammo"] + 10
end

function tozt()
   local items = Players[0].items
   items["flamethrower"] = items["flamethrower"] + 1
   items["flamethrower ammo"] = items["flamethrower ammo"] + 10
end

function zeus()
   local items = Players[0].items
   items["fusion pistol"] = items["fusion pistol"] + 1
   items["fusion pistol ammo"] = items["fusion pistol ammo"] + 10
end

function wste()
   local items = Players[0].items
   items["shotgun"] = items["shotgun"] + 1
   items["shotgun ammo"] = items["shotgun ammo"] + 10
end

function smg()
   local items = Players[0].items
   items["smg"] = items["smg"] + 1
   items["smg ammo"] = items["smg ammo"] + 10
end

function alien()
   local items = Players[0].items
   items["alien weapon"] = items["alien weapon"] + 1
end

function ammo()
   local items = { "pistol ammo", "fusion pistol ammo", "assault rifle ammo", "assault rifle grenades", "missile launcher ammo", "alien weapon ammo", "flamethrower ammo", "shotgun ammo", "smg ammo" }
   for _, item in pairs(items) do
      Players[0].items[item] = Players[0].items[item] + 10
   end
end

function stuff()
   ammo()
   local weapons = { "alien weapon", "pistol", "fusion pistol", "assault rifle", "missile launcher", "flamethrower", "shotgun", "shotgun", "smg" }
   for _, weapon in pairs(weapons) do
      Players[0].items[weapon] = Players[0].items[weapon] + 1
   end

   if Players[0].life < 450 then 
      Players[0].life = 450
   end
end
