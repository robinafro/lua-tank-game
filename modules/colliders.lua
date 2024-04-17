local Groups = {}
local MaxDistance = 1000

function RefreshGroups(colliders)
    Groups = {}

    for _, collider in pairs(colliders) do
        local success = false
        for _, group in pairs(Groups) do
            local x, y = group[1].Object.X, group[1].Object.Y
            local distance = math.sqrt((collider.Object.X - x) ^ 2 + (collider.Object.Y - y) ^ 2)

            if distance < MaxDistance then
                success = true
                table.insert(group, collider)
                break
            end
        end

        if not success then
            table.insert(Groups, {collider})
        end
    end
end

return {init = function(game)
    if not game.Paths.Colliders then
        game.Paths.Colliders = {}
    end

    if not game.Paths.Map then
        repeat game.RunService:Wait() until game.Paths.Map
    end

    local colliders = {}

    game.RunService:Connect("Stepped", function(dt)
        RefreshGroups(game.Paths.Colliders)

        local ignoreList = {}
        for _, group in pairs(Groups) do
            for _, collider in pairs(group) do
                collider:Collide(group, ignoreList)
                ignoreList[collider.ID] = true
            end
        end
    end)
end}