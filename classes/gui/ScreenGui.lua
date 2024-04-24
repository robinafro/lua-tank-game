local BaseGui = require("classes/gui/BaseGui")
local Vector2 = require("classes/vector2")
local Object = require("classes/object")

local ScreenGui = setmetatable({}, BaseGui)
ScreenGui.__index = ScreenGui

function ScreenGui.new(game)
    local self = setmetatable(BaseGui.new(), ScreenGui)

    self.Game = game

    self.size = Vector2.new(love.graphics.getWidth(), love.graphics.getHeight())
    self.position = Vector2.new(0, 0)

    self.children = {}
    self.object = Object.new()

    self.object.HUD = true
    self.object.AlwaysVisible = true
    self.object.ZIndex = 1000000

    self.connection = game.ObjectService:Add(self.object)
    game.ObjectService:Sort()

    self.object.Function = function()
        self:Render()
    end

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