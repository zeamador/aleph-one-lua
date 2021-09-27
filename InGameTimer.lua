-- InGameTimer.lua
-- by aperturegrillz

-- In-game timer suitable for use when doing Marathon speedruns.
-- At the start of each new level, displays the time the previous level took
-- for a few seconds.
-- This script will output a file 'split.txt' with the split times of the last
-- game played.

Triggers = {}

function Triggers.idle()
  for p in Players() do
    -- show level split for 3 seconds
    if Players[0]._this_start ~= 0 and Game.ticks - Players[0]._this_start < 3*30 then
      p.overlays[0].text = game_time_str(Players[0]._this_start - Players[0]._last_start)
      p.overlays[0].color = "yellow"
    else
      p.overlays[0].text = game_time_str(Game.ticks)
      p.overlays[0].color = "white"
    end
  end
end

function Triggers.init()
  Game.restore_passed()
  if Players[0]._last_start == nil then
    Players[0]._last_start = 0
  end
  Players[0]._this_start = Game.ticks
end

-- Save the time of the start of this level
-- so we can restore it at the start of the next one.
function Triggers.cleanup()
  Players[0]._last_start = Players[0]._this_start
  local f
  if Players[0]._this_start == 0 then
    f = assert(io.open("split.txt", "w"))
  else
    f = assert(io.open("split.txt", "a"))
  end
  f:write(Game.ticks.." "..game_time_str(Game.ticks).."\t"..Level.name)
  if Level.completed then
    f:write("\tcompleted\n")
  else
    f:write("\tquit\n")
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

