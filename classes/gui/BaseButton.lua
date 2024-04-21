local BaseFrame = require("classes/gui/BaseFrame")
local Vector2 = require("classes/vector2")

local BaseButton = setmetatable({}, BaseFrame)
BaseButton.__index = BaseButton

function BaseButton.new()
    local self = setmetatable({}, BaseButton)

    self.MouseEnter = {} --// TODO: replace tables with Event objects
    self.MouseLeave = {}
    self.MouseClick = {}
    self.MouseDown = {}
    self.MouseUp = {}

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
            print("MouseDown")

            self._heldDownTracker = true
        else
            print("MouseUp")

            if self._heldDownTracker == true then
                print("MouseClick")
            end

            self._heldDownTracker = false
        end
    end

    if self.isHovered ~= self._prevIsHovered then
        if self.isHovered == true then
            print("MouseEnter")
        else
            print("MouseLeave")

            self._heldDownTracker = false
        end
    end

    self._prevIsHovered = self.isHovered
    self._prevIsPressed = self.isPressed
end

return BaseButton