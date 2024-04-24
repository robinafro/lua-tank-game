local GuiLoader = require("classes/guiloader")
local Vector2 = require("classes/vector2")
local Color3  = require("classes/color3")

function HealthHUD(guiLoader)
    local background = guiLoader:Insert("Frame")
    background.size = Vector2.new(0.8, 0.02)
    background.position = Vector2.new(0.5, 0.99)
    background.anchorPoint = Vector2.new(0.5, 1)
    background.color = Color3.new(0,0,0)

    local container = guiLoader:Insert("Frame", background)
    container.size = Vector2.new(0.992, 0.45)
    container.position = Vector2.new(0.5, 0.5)
    container.anchorPoint = Vector2.new(0.5, 0.5)
    container.color = Color3.new(0.1,0.1,0.1)

    local healthBar = guiLoader:Insert("Frame", container)
    healthBar.size = Vector2.new(0.5, 1)
    healthBar.color = Color3.new(1,0,0)

    return function(health, maxHealth)
        local ratio = health/maxHealth
        
        healthBar.size = Vector2.new(ratio, 1)
        healthBar.color = Color3.new(1 - ratio, ratio, 0)
    end
end

return {init = function(game)
    local guiLoader = GuiLoader.new(game, "Healthbars")

    local update = HealthHUD(guiLoader)

    game.RunService:Connect("Heartbeat", function()
        update(game.Paths.LocalPlayer.Controlling.Health, game.Paths.LocalPlayer.Controlling.MaxHealth)
    end)
end}