local MAX_DISTANCE_FOR_AABB = 200

function raycast(start, goal, objects, include)
    --//TODO: potom mozna to udelej SAT kolizema

    -- Objects is a table of all objects, they all have .X, .Y, .Width, .Height

    local dx = goal.x - start.x
    local dy = goal.x - start.x

    local distance = math.sqrt(dx * dx + dy * dy)   

    if distance == 0 then
        return false
    end

    local angle = math.atan2(dy, dx)

    local step = 20
    local steps = distance / step
    
    for i = 1, steps do
        local x = start.x + step * i * math.cos(angle)
        local y = start.y + step * i * math.sin(angle)
        
        for _, object in pairs(objects) do
            local distance = math.min((object.X - x), (object.Y - y))

            if distance < MAX_DISTANCE_FOR_AABB then
                if object.RaycastName == include and object:CollidesWith(x, y, 5, 5) then
                    return false
                end
            end
        end
    end

    return true
end

return raycast