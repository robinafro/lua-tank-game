--// The problem: colliders can get assigned to a group that is too far away to a second collider, but that second collider is still close enough to the first collider to collide with it, resulting in the two colliders not being able to collide with each other
--// The solution: instead of checking distances between the colliders, assign them to groups based on a map grid

local Groups = {}

local GRID_SIZE = 1000
local SIZE_OFFSET = 50 --// Used to make sure the colliders are still in the same group when they are on the edge of the grid

function RefreshGroups(colliders)
    Groups = {}

    for _, collider in pairs(colliders) do
        local x, y = collider.Object.X - SIZE_OFFSET, collider.Object.Y - SIZE_OFFSET
        local x2, y2 = x + collider.Object.Width + SIZE_OFFSET, y + collider.Object.Height + SIZE_OFFSET
        local gridX, gridY = math.floor(x / GRID_SIZE), math.floor(y / GRID_SIZE)
        local gridX2, gridY2 = math.floor(x2 / GRID_SIZE), math.floor(y2 / GRID_SIZE)

        for i = gridX, gridX2 do
            for j = gridY, gridY2 do
                local key = i .. "," .. j

                if not Groups[key] then
                    Groups[key] = {}
                end

                table.insert(Groups[key], collider)
            end
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