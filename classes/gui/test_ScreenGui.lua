local BaseGui = require("BaseGui")
local Vector2 = require("classes/vector2")

local ScreenGui = setmetatable({}, BaseGui)
ScreenGui.__index = ScreenGui

function ScreenGui.new()
    local self = setmetatable(BaseGui.new(), ScreenGui)

    self.size = Vector2.new(love.graphics.getWidth(), love.graphics.getHeight())
    self.position = Vector2.new(0, 0)

    return self
end

function ScreenGui:Render()
    for _, child in ipairs(self.children) do
        child:Render()
    end
end

function ScreenGui:GetAbsoluteSize()
    return self.size
end

return ScreenGui