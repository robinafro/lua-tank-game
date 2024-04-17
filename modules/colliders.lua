return {init = function(game)
    if not game.Paths.Colliders then
        game.Paths.Colliders = {}
    end

    game.RunService:Connect("Stepped", function(dt)
        local ignoreList = {}

        for _, collider in pairs(game.Paths.Colliders) do
            collider:Collide(game.Paths.Colliders, ignoreList)
            ignoreList[collider.ID] = true
        end
    end)
end}