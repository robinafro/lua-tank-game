local Vector2 = require("classes/vector2")
local Color3 = require("classes/color3")

local BaseGui = require("classes/gui/BaseGui")

local BaseFrame = setmetatable({}, BaseGui)
BaseFrame.__index = BaseFrame

function BaseFrame.new()
    local self = setmetatable({}, BaseFrame)

    self.children = {}

    self.position = Vector2.new(0, 0)
    self.size = Vector2.new(0,0)
    self.anchorPoint = Vector2.new(0, 0)
    self.color = Color3.new(1, 1, 1)
    self.transparency = 0

    self.absoluteSize = nil
    self.previousSize = nil
    
    return self
end

function BaseFrame:GetAbsoluteSize()
    if self.absoluteSize and self.size == self.previousSize then
        return self.absoluteSize
    end

    local size = self.size
    local current = self

    while current.parent do
        size = size * current.parent.size
        current = current.parent
    end

    self.absoluteSize = size
    self.previousSize = self.size

    return size
end

function BaseFrame:GetAbsolutePosition()
    local position = self.position
    local current = self

    while current.parent do
        position = position + current.parent.position
        current = current.parent
    end

    return position
end

function BaseFrame:GetPixelRelativePosition()
    return self.position * self.parent:GetAbsoluteSize()
end

function BaseFrame:Render()
    if not self:IsVisible() then
        return
    end

    local size = self:GetAbsoluteSize()
    local pos = self:GetPixelRelativePosition() - size * self.anchorPoint

    local posX, posY = unpack(pos:toTable())

    local r, g, b = unpack(self.color:toTable())
    love.graphics.setColor(r, g, b, 1 - self.transparency)
    
    love.graphics.rectangle("fill", posX, posY, unpack(size:toTable()))
    love.graphics.translate(posX, posY)

    for _, child in ipairs(self.children) do
        child:Render()
    end

    love.graphics.origin()

    return pos, size
end

return BaseFrame