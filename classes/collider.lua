SAT = require("lib.sat")

Collider = {}
Collider.__index = Collider

local function _find(t, v)
    for i, _v in ipairs(t) do
        if _v == v or _v == "*" then
            return i
        end
    end

    return nil
end

function Collider.new(paths, object)
    if not paths then return end

    local self = setmetatable({}, Collider)

    self.Object = object

    self.MaxDistance = 200

    self.Static = false
    self.CanCollide = true
    self.CanTouch = true
    self.CollisionFilterType = {}
    self.CollisionFilter = {}
    self.CollisionName = ""
    self.CollisionFunction = nil

    self.Paths = paths

    paths.Colliders = paths.Colliders or {}
    table.insert(paths.Colliders, self)

    return self
end

function Collider:Destroy()
    local i = _find(self.Paths.Colliders, self)

    if not i then return end
    
    self.Paths.Colliders[i] = nil
end

function Collider:Collides(collider)
    local maxDistance = math.max(self.MaxDistance, collider.MaxDistance)
    local distance = math.min(math.abs(self.Object.X + self.Object.Width / 2 - collider.Object.X - collider.Object.Width / 2), math.abs(self.Object.Y + self.Object.Height / 2 - collider.Object.Y - collider.Object.Height / 2))

    if distance > maxDistance then
        return false
    end

    if (collider.CanCollide or collider.CanTouch) and (self.CanCollide or self.CanTouch) then
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

        -- Adjust the positions of the objects to prevent them from overlapping
        local separationVector = {
            x = penetrationVector.x / 2,
            y = penetrationVector.y / 2
        }

        if not self.Static then
            self.Object.X = self.Object.X - separationVector.x
            self.Object.Y = self.Object.Y - separationVector.y
        end

        if not collider.Static then
            collider.Object.X = collider.Object.X + separationVector.x
            collider.Object.Y = collider.Object.Y + separationVector.y
        end
    end
end

function Collider:Collide(colliders, dt)
    if not self.Object then
        self:Destroy()
    end

    for i, collider in ipairs(colliders) do
        if collider.Object then
            if collider ~= self then
                if self:Collides(collider) then
                    local min_penetration_axis, overlap = self:CheckCollisionSAT(collider) 
                    if min_penetration_axis then
                        if self.CanTouch and collider.CanTouch and self.CollisionFunction then
                            self.CollisionFunction(self, collider)
                        end

                        if self.CanCollide and collider.CanCollide then
                            self:ComputeCollision(collider, min_penetration_axis, overlap)
                        end
                    end
                end
            end
        else
            colliders[i] = nil
        end
    end
end

return Collider