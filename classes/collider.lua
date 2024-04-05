Collider = {}
Collider.__index = Collider

function Collider.new()
    local self = setmetatable({}, Collider)

    self.Object = nil

    self.CanCollide = true
    self.CollisionFilterType = {}
    self.CollisionFilter = {}
    self.CollisionName = ""

    return self
end

function Collider:Collides(collider)
    if collider.CanCollide and self.CanCollide then
        if collider.CollisionFilterType == "Include" and table.find(collider.CollisionFilter, self.CollisionName)
        or collider.CollisionFilterType == "Exclude" and not table.find(collider.CollisionFilter, self.CollisionName) then
            if self.CollisionFilterType == "Include" and table.find(self.CollisionFilter, collider.CollisionName)
            or self.CollisionFilterType == "Exclude" and not table.find(self.CollisionFilter, collider.CollisionName) then
                return true
            end
        end
    end

    return false
end

function Collider:CheckCollision(collider)
    
end

function Collider:Collide(colliders)
    return function(dt)
        for _, collider in pairs(colliders) do
            if self:Collides(collider) then

            end
        end
    end
end

return Collider