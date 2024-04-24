local BaseGui = require("classes/gui/BaseGui")
local Vector2 = require("classes/vector2")
local Object = require("classes/object")

local BillboardGui = setmetatable({}, BaseGui)
BillboardGui.__index = BillboardGui

function BillboardGui.new(game)
    local self = setmetatable(BaseGui.new(), BillboardGui)

    self.Game = game

    self.size = Vector2.new(0,0)
    self.position = Vector2.new(0, 0)
    self.offset = Vector2.new(0, 0)

    self.children = {}
    self.object = Object.new()
    self.adornee = nil

    self.object.HUD = false
    self.object.AlwaysVisible = true
    self.object.ZIndex = 1000000

    self.connection = game.ObjectService:Add(self.object)
    game.ObjectService:Sort()

    self.object.Function = function()
        self:Render()
    end

    return self
end

function BillboardGui:Render()
    if not self:IsVisible() or not self.adornee or not self.adornee.X then
        return
    end

    --// Set self.position based on the adornee object
    self.position.x = self.adornee.X + self.offset.x - self.size.x / 2
    self.position.y = self.adornee.Y + self.offset.y - self.size.y / 2
    
    love.graphics.translate(self.position.x, self.position.y)

    for _, child in ipairs(self.children) do
        child:Render()
    end

    love.graphics.translate(-self.position.x, -self.position.y)
end

function BillboardGui:GetAbsoluteSize()
    return self.size
end

return BillboardGui