return {init = function(game)
    if not game.Paths.Colliders then
        game.Paths.Colliders = {}
    end

    game.RunService:Connect("Stepped", function(dt)
        for _, collider in ipairs(game.Paths.Colliders) do
            collider:Collide(game.Paths.Colliders, dt)
        end
    end)
end}