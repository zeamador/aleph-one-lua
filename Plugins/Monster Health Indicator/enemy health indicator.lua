-- play_ghost.lua
-- by aperturegrillz

Triggers = {}

OFFSET = 0.1
DIGIT_SPACE = 0.07
DIGIT_FORWARD = 0.1
DMG_FORWARD = 0.15
COLLECTION = 7
SEQ_IDX = 34
RED_SEQ_IDX = 44
DMG_OFFSET = 0.2
DMG_DELAY = 15
RAISE_PER_TICK = 0.01
CEILING_BUFFER = 0.1

PUNCH_THRESHOLD = 50

hit_labels = {}

function Triggers.init()
	Game.restore_passed()
  table.setn(hit_labels, 0)
end

function Triggers.idle()
  for m in Monsters() do
    if not m.player then    
      if m.life > 0 then
        local theta = math.pi - angle_between_points(
          {x = m.x, y = m.y},
          {x = Players[0].x, y = Players[0].y}
        )
        local x_offset = DIGIT_SPACE * math.sin(theta)
        local x_forward = DIGIT_FORWARD * math.sin(theta - math.pi/2)
        local y_offset = DIGIT_SPACE * math.cos(theta)
        local y_forward = DIGIT_FORWARD * math.cos(theta - math.pi/2)
        
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
          local h = MonsterTypes[m.type.mnemonic].height
          local z = m.z + h + OFFSET
          if z > m.polygon.ceiling.z - CEILING_BUFFER then
            z = m.polygon.ceiling.z - CEILING_BUFFER
          end
          for i = 1, m._labellen do
            m._label[i]:position(
              m.x + (i-1-m._labellen/2)*x_offset + x_forward,
              m.y + (i-1-m._labellen/2)*y_offset + y_forward,
              z,
              m.polygon
            )
            m._label[i].facing = m.facing
          end
        end
        --if m._hits ~= nil then
        --  local h = MonsterTypes[m.type.mnemonic].height + DMG_OFFSET
        --  for hit = 1, m._numhits do
        --    for i = 1, m._hits[hit].labellen do
        --      -- update hit position
        --      m._hits[hit].label[i]:position(
        --        m.x + (i-1-m._hits[hit].labellen/2)*x_offset,
        --        m.y + (i-1-m._hits[hit].labellen/2)*y_offset,
        --        m.z + h + (Game.ticks - m._hits[hit].tick)*RAISE_PER_TICK,
        --        m.polygon
        --      )
        --      m._label[i].facing = m.facing
        --    end
        --    
        --    if Game.ticks - m._hits[hit].tick > DMG_DELAY then
        --      for i = 1, m._hits[hit].labellen do
        --        m._hits[hit].label[i]:delete()
        --      end
        --      table.remove(m._hits, hit)
        --      hit = hit - 1
        --      m._numhits = m._numhits - 1
        --    end
        --  end
        --end
      else -- m.life < 0
        if m._label ~= nil then
          for i = 1, m._labellen do
            m._label[i]:delete()
          end
          m._labellen = 0
        end
        --if m._numhits ~= nil and m._numhits > 0 then
        --  for hit = 1, m._numhits do
        --    for i = 1, m._hits[hit].labellen do
        --      m._hits[hit].label[i]:delete()
        --    end
        --  end
        --  m._numhits = 0
        --end
      end
      
      for idx, hit in ipairs(hit_labels) do
        local label_len = #hit.label
        if label_len > 0 then
          local hit_loc = {
            x = hit.label[1].x,
            y = hit.label[1].y,
            z = hit.label[1].z,
            polygon = hit.label[1].polygon
          }
          
          if hit.monster ~= nil then
            -- update hit position
            local m = hit.monster
            local h = MonsterTypes[m.type.mnemonic].height
            
            hit_loc.x = m.x
            hit_loc.y = m.y
            hit_loc.z = m.z + h + DMG_OFFSET
            hit_loc.polygon = m.polygon
            
            if hit.monster.life < 0 then
              hit.monster = nil
            end
          end
          
          local theta = math.pi - angle_between_points(
            {x = hit_loc.x, y = hit_loc.y},
            {x = Players[0].x, y = Players[0].y}
          )
          local x_offset = DIGIT_SPACE * math.sin(theta)
          local x_forward = DMG_FORWARD * math.sin(theta - math.pi/2)
          local y_offset = DIGIT_SPACE * math.cos(theta)
          local y_forward = DMG_FORWARD * math.cos(theta - math.pi/2)
          
          local z = hit_loc.z + (Game.ticks - hit.tick)*RAISE_PER_TICK
          if z > hit_loc.polygon.ceiling.z - CEILING_BUFFER then
            z = hit_loc.polygon.ceiling.z - CEILING_BUFFER
          end
          for i = 1, label_len do
            hit.label[i]:position(
              hit_loc.x + (i-1-label_len/2)*x_offset + x_forward,
              hit_loc.y + (i-1-label_len/2)*y_offset + y_forward,
              z,
              hit_loc.polygon
            )
          end
          
          if Game.ticks - hit.tick > DMG_DELAY then
            for i = 1, label_len do
              hit.label[i]:delete()
            end
            table.remove(hit_labels, idx)
          end
        end
      end
    end
  end
end

function Triggers.monster_damaged(monster, aggressor_monster, damage_type, damage_amount, projectile)
  local dmg_str = string.format("%d", damage_amount)
  local dmg_label = {}
  local dmg_len = #dmg_str
  for i = 1, dmg_len do
    local seq = RED_SEQ_IDX + tonumber(dmg_str:sub(i, i))
    dmg_label[i] = Ephemera.new(0, 0, 0, 0, COLLECTION, seq, 0)
  end
  
  if projectile ~= nil and projectile.type == ProjectileTypes["fist"] and damage_amount >= PUNCH_THRESHOLD then
    monster:play_sound(Sounds["crushed"])
  end
  
  table.insert(hit_labels, {
    monster = monster,
    label = dmg_label,
    labellen = dmg_len,
    tick = Game.ticks
  })
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