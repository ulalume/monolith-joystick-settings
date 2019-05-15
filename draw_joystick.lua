
local rainbow = require "graphics.rainbow":new(2/60)

local keys = {"up","down","left","right","a","b"}
local keyType = {now="now", set="set", none="none", ghost="ghost"}
local keyPos = {
  up={x=48,y=104},
  down={x=48,y=120},
  left={x=40,y=112},
  right={x=56,y=112},
  a={x=72,y=112},
  b={x=88-4,y=112},
}

local function drawKey(key, type)
  local pos = keyPos[key]

    love.graphics.setLineWidth( 0.5 )
  if type == keyType.ghost then

    love.graphics.setColor(0, 0, 1)
    love.graphics.circle("line", pos.x, pos.y, 4)
    return
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", pos.x, pos.y, 4)
  if type == keyType.now then
    love.graphics.setColor(rainbow:color():rgb())
    love.graphics.circle("fill", pos.x, pos.y, 4)
    love.graphics.setColor(rainbow:color(1):rgb())
    love.graphics.circle("fill", pos.x, pos.y, 3)
    love.graphics.setColor(rainbow:color(2):rgb())
    love.graphics.circle("fill", pos.x, pos.y, 2)
    love.graphics.setColor(rainbow:color(3):rgb())
    love.graphics.circle("fill", pos.x, pos.y, 1)
  elseif type == keyType.set then
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", pos.x, pos.y, 4)
  end

      love.graphics.setLineWidth( 1 )
end
return function (setting, nowSetting)
  local nowKey = setting:nowKey()
  for i, key in ipairs(keys) do
    if not nowSetting then
      drawKey(key, keyType.ghost)
    elseif key == nowKey then
      drawKey(key, keyType.now)
    elseif setting:buttonIsSet(key) then
      drawKey(key, keyType.set)
    else
      drawKey(key, keyType.none)
    end
  end
end
