local Groups = {}
local MAX_DISTANCE_PER_GROUP = 1000 -- 2000 if using the functions (deprecate)
local BOUNDING_BOX_OFFSET = 0

function GetBoundingBox(group, collider, offset)
    local min_x, max_x, min_y, max_y = math.huge, -math.huge, math.huge, -math.huge

    for _, collider in pairs(group) do
        local x, y = collider.Object.X, collider.Object.Y
        min_x = math.min(min_x, x)
        max_x = math.max(max_x, x)
        min_y = math.min(min_y, y)
        max_y = math.max(max_y, y)
    end

    min_x = min_x - offset
    max_x = max_x + offset
    min_y = min_y - offset
    max_y = max_y + offset

    return min_x, max_x, min_y, max_y
end

function CheckDistanceToOutside(group, collider)
    local min_x, max_x, min_y, max_y = GetBoundingBox(group, collider, BOUNDING_BOX_OFFSET)

    -- Calculate the distance to the closest point on the outside of the bounding box
    local closest_x = math.max(min_x, math.min(max_x, collider.Object.X))
    local closest_y = math.max(min_y, math.min(max_y, collider.Object.Y))
    local distance = math.sqrt((closest_x - collider.Object.X) ^ 2 + (closest_y - collider.Object.Y) ^ 2)

    return distance
end

function RefreshGroups(colliders)
    Groups = {}

    for _, collider in pairs(colliders) do
        local success = false
        for _, group in pairs(Groups) do
            -- local x, y = group[1].Object.X, group[1].Object.Y
            -- local distance = math.sqrt((collider.Object.X - x) ^ 2 + (collider.Object.Y - y) ^ 2)
            -- local distance = CheckDistanceToOutside(group, collider)

            local avgX, avgY = 0, 0
            for _, collider in pairs(group) do
                avgX = avgX + collider.Object.X
                avgY = avgY + collider.Object.Y
            end
            avgX = avgX / #group
            avgY = avgY / #group

            local distance = math.sqrt((collider.Object.X - avgX) ^ 2 + (collider.Object.Y - avgY) ^ 2)
            
            -- print(distance)
            if distance < MAX_DISTANCE_PER_GROUP then
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