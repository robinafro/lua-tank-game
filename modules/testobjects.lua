function addObjects()
    for i = 1, 10 do
        table.insert(game.Paths.TestObjects, "Object "..i)

        coroutine.yield()
    end
end

return {init = function(_game)
    game = _game

    game.Paths.TestObjects = {"Object 1"}
    
    local co = coroutine.create(addObjects)

    -- game.RunService:Connect("Heartbeat", function()
    --     coroutine.resume(co)
    -- end)

    local fnc
    fnc = function()
        coroutine.resume(co)

        game.RunService:Delay(1, fnc)
    end

    game.RunService:Delay(1, fnc)
end}