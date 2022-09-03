-- play_ghost.lua
-- by aperturegrillz

Triggers = {}

OFFSET = 0.3
DIGIT_SPACE = 0.07
COLLECTION = 7
SEQ_IDX = 34

function Triggers.init()
	Game.restore_passed()
end

function Triggers.idle()
  for m in Monsters() do
    if m.visible and not m.player then
      local theta = angle_between_points(
        {x = m.x, y = m.y},
        {x = Players[0].x, y = Players[0].y}
      )
      local x_offset = DIGIT_SPACE * math.sin(theta)
      local y_offset = DIGIT_SPACE * math.cos(theta)
    
      if m.life > 0 then
        if m._label == nil then
          -- initialize monster's label variables
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
          
          -- create new ephemera
          m._lifelabel = m.life
          local life_str = string.format("%d", m.life)
          m._labellen = #life_str
          for i = 1, m._labellen do
            local seq = SEQ_IDX + tonumber(life_str:sub(i, i))
            m._label[i] = Ephemera.new(0, 0, 0, 0, COLLECTION, seq, m.facing)
          end
        end
        
        if m._label ~= nil then
          -- relocate label
          local h = MonsterTypes[m.type.mnemonic].height + OFFSET
          for i = 1, m._labellen do
            m._label[i]:position(m.x - (i-m._labellen/2)*x_offset, m.y - (i-m._labellen/2)*y_offset, m.z + h, m.polygon)
            m._label[i].facing = m.facing
          end
        end
      else
        if m._label ~= nil then
          for i = 1, m._labellen do
            m._label[i]:delete()
          end
          m._labellen = 0
        end
      end
    end
  end
end

---- The following functions taken from
---- https://gist.github.com/kirubz/fa84375008d376a2d695618e0ae3aed8/9812f1407136ca1ef795d484162d05ad2c7eb2b8
function angleOfPoint(pt, allow_negatives)
    local x, y = pt.x, pt.y
    local radian = math.atan2(y, x)
    return radian
    --local angle = radian * 180 / math.pi
    --if not allow_negatives and angle < 0 then
    --    angle = 360 + angle
    --end
    --return angle
end

-- returns the degrees between two points (note: 0 degrees is 'east')
function angle_between_points(a, b)
    local x, y = b.x - a.x, b.y - a.y
    return angleOfPoint({x = x, y = y})
end
---- end cribbed bit