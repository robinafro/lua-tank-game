local game

function OnPlayerDied(player)
    if player == game.Paths.LocalPlayer then
        
    end
end

return {init = function(g)
    game = g

    while not game.Paths.Events or not game.Paths.Events.PlayerDied do
        game.RunService:Wait()
    end

    local disconnect
    disconnect = game.Paths.Events.PlayerDied:Connect(function(player)
        if player == game.Paths.LocalPlayer then
            disconnect()
        end

        OnPlayerDied(player)
    end)
end}