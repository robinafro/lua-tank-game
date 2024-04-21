local BaseGui = require("classes/gui/BaseGui")
local Vector2 = require("classes/vector2")

local ScreenGui = {}
ScreenGui.__index = ScreenGui

function ScreenGui.new(game)
    local self = setmetatable(BaseGui.new(), ScreenGui)

    self.Game = game

    self.size = Vector2.new(love.graphics.getWidth(), love.graphics.getHeight())
    self.position = Vector2.new(0, 0)

    self.children = {}
    self.object = Object.new()

    self.object.HUD = true

    game.ObjectService:Add(self.object)

    return self
end

function ScreenGui:Render()
    if not self:IsVisible() then
        return
    end

    for _, child in ipairs(self.children) do
        child:Render()
    end
end

function ScreenGui:GetAbsoluteSize()
    return self.size
end

return ScreenGui