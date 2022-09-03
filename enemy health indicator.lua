-- play_ghost.lua
-- by aperturegrillz

Triggers = {}

OFFSET = 1.0
DIGIT_SPACE = 0.05
SEQ_IDX = 34

function Triggers.init()
	Game.restore_passed()
end

function Triggers.idle()
  for m in Monsters() do
    if m.visible and not m.player then
      if m._label == nil and m.life > 0 then
        m._lifelabel = m.life
        local life_str = string.format("%d", m.life)
        
        -- create label
        local h = MonsterTypes[m.type.mnemonic].height + OFFSET
        m._labellen = #life_str
        m._label = {}
        for i = 1, #life_str do
          local seq = SEQ_IDX + tonumber(life_str:sub(i, i))
          m._label[i] = Ephemera.new(m.x - (i-1)*DIGIT_SPACE, m.y, m.z + OFFSET, m.polygon, 7, seq, m.facing)
        end
        --m._label = {
        --  Ephemera.new(m.x, m.y, m.z + OFFSET, m.polygon, 7, 35, m.facing),
        --  Ephemera.new(m.x - DIGIT_SPACE, m.y, m.z + OFFSET, m.polygon, 7, 34, m.facing)
        --}
      end
      if m._label ~= nil then
        for i = 1, m._labellen do
          m._label[i]:position(m.x - (i-1)*DIGIT_SPACE, m.y, m.z + OFFSET, m.polygon)
          m._label[i].facing = m.facing
        end
      end
    end
  end
end