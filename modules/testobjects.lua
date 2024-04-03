return {init = function(_game)
    game = _game

    game.Paths.TestObjects = {}

    for i = 1, 10 do
        table.insert(game.Paths.TestObjects, "Object "..i)
        
        game.RunService:Wait(1)
    end
end}