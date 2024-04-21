local GuiLoader = require("classes/guiloader")
local Vector2 = require("classes/vector2")

local game, gui

function OnPlayerDied(player)
    if player == game.Paths.LocalPlayer then
        gui.Visible = true
    end
end

function InitializeGui()
    local guiLoader = GuiLoader.new(game)
    
    local text = guiLoader:Insert("TextLabel")
    text.text = "You died!"
    text.position = Vector2.new(0.5, 0.5)
    text.size = Vector2.new(0.5, 0.5)
    text.anchorPoint = Vector2.new(0.5, 0.5)

    guiLoader.ScreenGui.Visible = false

    return guiLoader.ScreenGui
end

return {init = function(g)
    game = g

    while not game.Paths.Events or not game.Paths.Events.PlayerDied do
        game.RunService:Wait()
    end

    gui = InitializeGui()

    local disconnect
    disconnect = game.Paths.Events.PlayerDied:Connect(function(player)
        if player == game.Paths.LocalPlayer then
            disconnect()
        end

        OnPlayerDied(player)
    end)
end}