return {init = function(game)
    map = require("classes.map").new()

    for x, row in pairs(map:Generate()) do
        for y, chunk in pairs(row) do
            game.ObjectService:Add(chunk.Object)
        end
    end

    game.Paths.Map = map
    if not game.Paths.LocalPlayer then
        repeat
            game.RunService:Wait()
        until game.Paths.LocalPlayer
    end

    -- map:SpawnObject(game.Paths.LocalPlayer.Controlling, 500)
    game.Paths.LocalPlayer.Camera:SetPosition(game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y)
end}