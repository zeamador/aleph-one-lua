-- play_ghost.lua
-- by aperturegrillz

Triggers = {}

OFFSET = 0.5
DIGIT_SPACE = 0.07
COLLECTION = 7
SEQ_IDX = 34

function Triggers.init()
	Game.restore_passed()
end

function Triggers.idle()
  for m in Monsters() do
    if m.visible and not m.player then
      if m.life > 0 then
        if m._label == nil then
          m._label = {}
          m._lifelabel = 0
          m._labellen = 0
        end
        if m._lifelabel ~= m.life then
          -- label needs updating
          
          -- delete old ephemera
          for i = 1, m._labellen do
            m._label[i]:delete()
          end
          
          m._lifelabel = m.life
          
          local life_str = string.format("%d", m.life)
          
          -- create new ephemera
          m._labellen = #life_str
          for i = 1, #life_str do
            local seq = SEQ_IDX + tonumber(life_str:sub(i, i))
            m._label[i] = Ephemera.new(0, 0, 0, 0, COLLECTION, seq, m.facing)
          end
        end
        if m._label ~= nil then
          local h = MonsterTypes[m.type.mnemonic].height + OFFSET
          for i = 1, m._labellen do
            m._label[i]:position(m.x - (i-1)*DIGIT_SPACE, m.y, m.z + h, m.polygon)
            m._label[i].facing = m.facing
          end
        end
      end
    end
  end
end