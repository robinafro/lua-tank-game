local BaseFrame = require("classes/gui/BaseFrame")
local Vector2 = require("classes/vector2")
local Event = require("classes/event")

local BaseButton = setmetatable({}, BaseFrame)
BaseButton.__index = BaseButton

function BaseButton.new()
    local self = setmetatable({}, BaseButton)

    self.MouseEnter = Event.new()
    self.MouseLeave = Event.new()
    self.MouseClick = Event.new()
    self.MouseDown = Event.new()
    self.MouseUp = Event.new()

    self.isHovered = false
    self.isPressed = false

    self._prevIsHovered = false
    self._prevIsPressed = false

    self._heldDownTracker = false

    return self
end

function BaseButton:Check(pos, size)
    local mousePos = Vector2.new(love.mouse.getX(), love.mouse.getY())

    self.isHovered = pos.x <= mousePos.x and mousePos.x <= pos.x + size.x and pos.y <= mousePos.y and mousePos.y <= pos.y + size.y
    self.isPressed = love.mouse.isDown(1)

    if self.isHovered and self.isPressed ~= self._prevIsPressed then
        if self.isPressed == true then
            self.MouseDown:Fire()

            self._heldDownTracker = true
        else
            self.MouseUp:Fire()

            if self._heldDownTracker == true then
                self.MouseClick:Fire()
            end

            self._heldDownTracker = false
        end
    end

    if self.isHovered ~= self._prevIsHovered then
        if self.isHovered == true then
            self.MouseEnter:Fire()
        else
            self.MouseLeave:Fire()

            self._heldDownTracker = false
        end
    end

    self._prevIsHovered = self.isHovered
    self._prevIsPressed = self.isPressed
end

return BaseButton