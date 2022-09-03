-- play_ghost.lua
-- by aperturegrillz

Triggers = {}

OFFSET = 1.0

function Triggers.init()
	Game.restore_passed()
end

function Triggers.idle()
  for m in Monsters() do
    if m.visible and not m.player then
      if m._label == nil and m.life ~= 0 then
        -- create label
        local h = MonsterTypes[m.type.mnemonic].height + OFFSET
        m._label = Ephemera.new(m.x, m.y, m.z + OFFSET, m.polygon, 7, 34, m.facing)
      end
      if m._label ~= nil then
        m._label:position(m.x, m.y, m.z + OFFSET, m.polygon)
        m._label.facing = m.facing
      end
    end
  end
end