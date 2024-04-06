SAT = require("lib.sat")

Collider = {}
Collider.__index = Collider

local function _find(t, v)
    for i, _v in ipairs(t) do
        if _v == v then
            return i
        end
    end

    return nil
end

function Collider.new(paths)
    if not paths then return end

    local self = setmetatable({}, Collider)

    self.Object = nil

    self.Static = false
    self.CanCollide = true
    self.CollisionFilterType = {}
    self.CollisionFilter = {}
    self.CollisionName = ""

    paths.Colliders = paths.Colliders or {}
    table.insert(paths.Colliders, self)

    return self
end

function Collider:Collides(collider)
    if collider.CanCollide and self.CanCollide then
        if collider.CollisionFilterType == "Include" and _find(collider.CollisionFilter, self.CollisionName)
        or collider.CollisionFilterType == "Exclude" and not _find(collider.CollisionFilter, self.CollisionName) then
            if self.CollisionFilterType == "Include" and _find(self.CollisionFilter, collider.CollisionName)
            or self.CollisionFilterType == "Exclude" and not _find(self.CollisionFilter, collider.CollisionName) then
                return true
            end
        end
    end

    return false
end

function Collider:CheckCollisionAABB(collider)
    if self.Object and collider.Object then
        local selfX, selfY, selfWidth, selfHeight = self.Object:GetBoundingBox()
        local colliderX, colliderY, colliderWidth, colliderHeight = collider.Object:GetBoundingBox()

        return selfX < colliderX + colliderWidth and
               selfX + selfWidth > colliderX and
               selfY < colliderY + colliderHeight and
               selfY + selfHeight > colliderY
    end

    return false
end

function Collider:CheckCollisionSAT(collider)
    if self.Object and collider.Object then
        local selfX, selfY, selfWidth, selfHeight = self.Object:GetBoundingBox()
        local colliderX, colliderY, colliderWidth, colliderHeight = collider.Object:GetBoundingBox()

        local selfPoints = {
            {x = selfX, y = selfY},
            {x = selfX + selfWidth, y = selfY},
            {x = selfX + selfWidth, y = selfY + selfHeight},
            {x = selfX, y = selfY + selfHeight}
        }

        local colliderPoints = {
            {x = colliderX, y = colliderY},
            {x = colliderX + colliderWidth, y = colliderY},
            {x = colliderX + colliderWidth, y = colliderY + colliderHeight},
            {x = colliderX, y = colliderY + colliderHeight}
        }

        local selfCenterX = selfX + selfWidth / 2
        local selfCenterY = selfY + selfHeight / 2

        local colliderCenterX = colliderX + colliderWidth / 2
        local colliderCenterY = colliderY + colliderHeight / 2

        local selfHalfWidth = selfWidth / 2
        local selfHalfHeight = selfHeight / 2

        local colliderHalfWidth = colliderWidth / 2
        local colliderHalfHeight = colliderHeight / 2

        -- Apply rotation to self points
        local selfRotation = math.rad(self.Object.Rotation or 0)
        for i, point in ipairs(selfPoints) do
            local rotatedX = selfX + (point.x - selfCenterX) * math.cos(selfRotation) - (point.y - selfCenterY) * math.sin(selfRotation)
            local rotatedY = selfY + (point.x - selfCenterX) * math.sin(selfRotation) + (point.y - selfCenterY) * math.cos(selfRotation)
            selfPoints[i].x = rotatedX + selfHalfWidth
            selfPoints[i].y = rotatedY + selfHalfHeight
        end

        -- Apply rotation to collider points
        local colliderRotation = math.rad(collider.Object.Rotation or 0)
        for i, point in ipairs(colliderPoints) do
            local rotatedX = colliderX + (point.x - colliderCenterX) * math.cos(colliderRotation) - (point.y - colliderCenterY) * math.sin(colliderRotation)
            local rotatedY = colliderY + (point.x - colliderCenterX) * math.sin(colliderRotation) + (point.y - colliderCenterY) * math.cos(colliderRotation)
            colliderPoints[i].x = rotatedX + colliderHalfWidth
            colliderPoints[i].y = rotatedY + colliderHalfHeight
        end


        return SAT.Collide(selfPoints, colliderPoints)
    end
end

function Collider:ComputeCollision(collider, min_penetration_axis, overlap)
    -- Move the objects so that they no longer collide
    if min_penetration_axis and overlap then
        local penetrationVector = {
            x = min_penetration_axis.x * overlap,
            y = min_penetration_axis.y * overlap
        }

        if not self.Static then
            self.Object.X = self.Object.X + penetrationVector.x
            self.Object.Y = self.Object.Y + penetrationVector.y
        end

        if not collider.Static then
            collider.Object.X = collider.Object.X - penetrationVector.x
            collider.Object.Y = collider.Object.Y - penetrationVector.y
        end
    end
end

function Collider:Collide(colliders, dt)
    print("-------")
    for _, collider in ipairs(colliders) do
        if collider ~= self then
            local min_penetration_axis, overlap = self:CheckCollisionSAT(collider) 
            if self:Collides(collider) and min_penetration_axis then
                self:ComputeCollision(collider, min_penetration_axis, overlap)
                -- collider.Object.Color = {1, 0, 0, 1}
                print("Collides")
            else
                -- collider.Object.Color = {1, 1, 1, 1}
                print("Doesn't collide")
            end
        end
    end
end

return Collider