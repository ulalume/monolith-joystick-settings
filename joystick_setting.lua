local table2 = require "util.table2"

local INPUT_UP    = 'up'
local INPUT_LEFT  = 'left'
local INPUT_DOWN  = 'down'
local INPUT_RIGHT = 'right'
local INPUT_A     = 'a'
local INPUT_B     = 'b'

local inputList = {INPUT_LEFT, INPUT_UP, INPUT_RIGHT, INPUT_DOWN, INPUT_A, INPUT_B}
local joystickSetting = {}

-- Default 値が 1 か -1 の Axis を無視する
local joysticks = {}
local cantUseJoystickAxis = {}
function addJoystick(joystick)
  table2.removeItem(joysticks, joystick)
  table.insert(joysticks, joystick)

  local guid = joystick:getGUID()
  cantUseJoystickAxis[guid] = cantUseJoystickAxis[guid] or {}

  for k=1, joystick:getAxisCount() do
    if joystick:getAxis(k) == 1 or joystick:getAxis(k) == -1 then
      table.insert(cantUseJoystickAxis[guid], k)
    end
  end
end
for _,joystick in ipairs(love.joystick.getJoysticks()) do
  addJoystick(joystick)
end
function joystickSetting:new()
  local t = setmetatable({}, {__index=self})
  t:reset()
  return t
end

function joystickSetting:reset()
  self.usedAxes = {}
  self.usedButtons = {}
  self.data = {
    type    = 'joystick',
    mapping = {
      [INPUT_UP]    = { index = nil, type = nil, reverse = nil },
      [INPUT_LEFT]  = { index = nil, type = nil, reverse = nil },
      [INPUT_DOWN]  = { index = nil, type = nil, reverse = nil },
      [INPUT_RIGHT] = { index = nil, type = nil, reverse = nil },
      [INPUT_A]     = { index = nil, type = nil, reverse = nil },
      [INPUT_B]     = { index = nil, type = nil, reverse = nil },
    },
    options = {
      guid = nil,
      name = nil,
    }
  }
end
function setAxis(self, i, reverse)
  local key = self:nowKey()
  self:setButton(key, i, "axis", reverse)
  if key == INPUT_UP then
    self:setButton(INPUT_DOWN, i, "axis", not reverse)
  elseif key == INPUT_DOWN then
    self:setButton(INPUT_UP, i, "axis", not reverse)
  elseif key == INPUT_LEFT then
    self:setButton(INPUT_RIGHT, i, "axis", not reverse)
  elseif key == INPUT_RIGHT then
    self:setButton(INPUT_LEFT, i, "axis", not reverse)
  end
end
function joystickSetting:watchInput(joystick, cantUseAxes)

  for i = 1, joystick:getAxisCount() do
    --print(joystick:getAxis(i))
    if table2.indexOf(self.usedAxes, i) == nil and table2.indexOf(cantUseAxes, i) == nil then
      if joystick:getAxis(i) < -0.5 then
        self:setJoystick(joystick)
        setAxis(self, i, true)
        table.insert(self.usedAxes, i)
        return true
      elseif joystick:getAxis(i) > 0.5 then
        self:setJoystick(joystick)
        local key = self:nowKey()
        setAxis(self, i, false)
        table.insert(self.usedAxes, i)
        return true
      end
    end
  end

  for i = 1, joystick:getButtonCount() do
    if table2.indexOf(self.usedButtons, i) == nil then
      --print("?",joystick:isDown(i))
      if joystick:isDown(i) then
        self:setJoystick(joystick)
        self:setButton(self:nowKey(), i, "button")
        table.insert(self.usedButtons, i)
        return true
      end
    end
  end
  return false
end

function joystickSetting:update(dt, cantUseJoysticks)
  if self:isDone() then return end
  if self.joystick ~= nil then
    self:watchInput(self.joystick, cantUseJoystickAxis[self.joystick:getGUID()])
  else
    for _, joystick in ipairs(love.joystick.getJoysticks()) do
      if table2.indexOf(joysticks, joystick) == nil then
        addJoystick(joystick)
      end
      if table2.indexOf(cantUseJoysticks, joystick) == nil then
        --print(3, joystick:getGUID(), cantUseJoystickAxis[joystick:getGUID()])
        if self:watchInput(joystick, cantUseJoystickAxis[joystick:getGUID()]) then return end
        --if self:watchInput(joystick, cantUseJoystickAxis[self.joystick:getGUID()]) then return end
      end
    end
  end
end

function joystickSetting:nowKey()
  for _,key in ipairs(inputList) do
    if not self:buttonIsSet(key) then
      return key
    end
  end
  return nil
end
function joystickSetting:isDone()
  return self:nowKey() == nil
end

function joystickSetting:setButton(key, index, type, reverse)
  --print(key, index, type, reverse)
  local button = self:getButton(key)
  button.index = index
  button.type = type
  button.reverse = reverse
end
function joystickSetting:getButton(key)
  return self.data.mapping[key]
end
function joystickSetting:buttonIsSet(key)
  return self.data.mapping[key].index ~= nil
end

function joystickSetting:getName()
  return self.data.options.name
end
function joystickSetting:getGUID()
  return self.data.options.guid
end
function joystickSetting:setJoystick(joystick)
  self.joystick = joystick
  self.data.options.name = joystick:getName()
  self.data.options.guid = joystick:getGUID()
end

return joystickSetting
