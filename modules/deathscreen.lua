local GuiLoader = require("classes/guiloader")
local Vector2 = require("classes/vector2")
local Color3  = require("classes/color3")

local game, gui

function Respawn()
    game.Signal:send("pause")
    game.Signal:send("restart")
end

function OnPlayerDied(player)
    if player == game.Paths.LocalPlayer then
        game.Paths.UIs.Healthbars.Visible = false

        game.Signal:send("pause")
        gui.Visible = true
    end
end

function InitializeGui()
    local guiLoader = GuiLoader.new(game)
    
    local fullscreenFrame = guiLoader:Insert("Frame")

    fullscreenFrame.size = Vector2.new(1, 1)
    fullscreenFrame.position = Vector2.new(0, 0)
    fullscreenFrame.color = Color3.new(0, 0)
    fullscreenFrame.transparency = 0.4

    local youDiedText = guiLoader:Insert("TextLabel", fullscreenFrame)
    youDiedText.text = "You died"
    youDiedText:SetFont(78, "assets/fonts/Pixeboy.ttf")
    youDiedText.textColor3 = Color3.new(1, 1, 1)
    youDiedText.size = Vector2.new(0.5, 0.1)
    youDiedText.anchorPoint = Vector2.new(0.5, 0)
    youDiedText.position = Vector2.new(0.5, 0.1)
    youDiedText.backgroundTransparency = 1

    local scoreContainer = guiLoader:Insert("Frame", fullscreenFrame)
    scoreContainer.anchorPoint = Vector2.new(0.5, 0.5)
    scoreContainer.position = Vector2.new(0.5, 0.5)
    scoreContainer.size = Vector2.new(0.6, 0.4)

    local playAgainButton = guiLoader:Insert("ImageLabel", fullscreenFrame)
    playAgainButton.image = love.graphics.newImage("assets/ui/button_restart.png")
    playAgainButton.scaleType = "stretch"
    playAgainButton.backgroundTransparency = 1

    playAgainButton.size = Vector2.new(0.25, 0.1)
    playAgainButton.anchorPoint = Vector2.new(0.5, 1)
    playAgainButton.position = Vector2.new(0.5, 0.9)

    local disconnect
    disconnect = playAgainButton.Button.MouseClick:Connect(function()
        disconnect()
        Respawn()
    end)

    guiLoader.Gui.Visible = false

    return guiLoader.Gui
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