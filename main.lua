package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'

local monolith = require "monolith.core".new()
local rotateScreen = require "graphics.rotate_screen":new(128, 128)
local storage = require "util.storage":load("joystick_setting", true)

local Setting = require "joystick_setting"

local drawJoystick = require "draw_joystick"
local settings
local gameOver = false

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  love.graphics.setLineStyle('rough')

  love.graphics.setFont(love.graphics.newFont("assets/font/Chack'n-Pop.ttf", 8))

  settings = {
    Setting:new(),
    Setting:new(),
    Setting:new(),
    Setting:new(),
  }

end

local joystickCount = 0
function love.update(dt)
  if gameOver then return end

  joystickCount = love.joystick.getJoystickCount()

  local cantUseJoysticks = {}
  local isAllDone = true
  for _, setting in ipairs(settings) do
    local isDone = setting:isDone()
    if not isDone then setting:update(dt, cantUseJoysticks) end

    isAllDone = isAllDone and isDone
    if setting.joystick == nil then
      isAllDone = false
      break
    end

    table.insert(cantUseJoysticks, setting.joystick)
  end

  if isAllDone then
    gameOver = true
    for i, setting in ipairs(settings) do
      storage.data[i] = setting.data
    end
    storage:save()
  end
end

function love.draw()
  local rs = {0, -math.pi, -math.pi / 2, -math.pi / 2 * 3}

  monolith:beginDraw()
  if joystickCount < 4 then
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("joystick:"..joystickCount, 128 / 2 - 8 * 10 / 2, 128 /2 - 8 * 1 / 2)
  end

  local nowSetting = true
  for i, setting in ipairs(settings) do
    rotateScreen:beginDraw(rs[i])
    drawJoystick(setting, nowSetting)
    rotateScreen:endDraw()
    if setting.joystick == nil then
      nowSetting = false
    end
  end

  monolith:endDraw()
end


function love.quit()
end
