--// TODO: This will be a class that creates an ObjectService object with HUD = true
local Object = require("classes/object")

local ScreenGui = {}
ScreenGui.__index = ScreenGui

function ScreenGui.new(game)
    local self = setmetatable({}, ScreenGui)

    self.Game = game

    self.children = {}
    self.object = Object.new()

    self.object.HUD = true

    game.ObjectService:Add(self.object)

    return self
end

function ScreenGui:Render()
    for _, child in ipairs(self.children) do
        child:Render()
    end
end

return ScreenGui