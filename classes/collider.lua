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

function Collider.new()
    local self = setmetatable({}, Collider)

    self.Object = nil

    self.Static = false
    self.CanCollide = true
    self.CollisionFilterType = {}
    self.CollisionFilter = {}
    self.CollisionName = ""

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

function Collider:CheckCollision(collider)
    if self.Object and collider.Object then
        print(self.Object.Width, self.Object.Height, self.Object.Rotation)
        local selfX, selfY, selfWidth, selfHeight = self.Object:GetBoundingBox()
        local colliderX, colliderY, colliderWidth, colliderHeight = collider.Object:GetBoundingBox()

        return selfX < colliderX + colliderWidth and
               selfX + selfWidth > colliderX and
               selfY < colliderY + colliderHeight and
               selfY + selfHeight > colliderY
    else
        print("Object is nil")
    end

    return false
end

function Collider:ComputeCollision(collider)
    -- Change the X and Y objects' postions so that they no longer collide
    local selfX, selfY, selfWidth, selfHeight = self.Object:GetBoundingBox()
    local colliderX, colliderY, colliderWidth, colliderHeight = collider.Object:GetBoundingBox()

    local selfCenterX = selfX + selfWidth / 2
    local selfCenterY = selfY + selfHeight / 2

    local colliderCenterX = colliderX + colliderWidth / 2
    local colliderCenterY = colliderY + colliderHeight / 2

    local selfDistanceX = selfCenterX - colliderCenterX
    local selfDistanceY = selfCenterY - colliderCenterY

    local selfHalfWidth = selfWidth / 2
    local selfHalfHeight = selfHeight / 2

    local colliderHalfWidth = colliderWidth / 2
    local colliderHalfHeight = colliderHeight / 2

    local overlapX = selfHalfWidth + colliderHalfWidth - math.abs(selfDistanceX)
    local overlapY = selfHalfHeight + colliderHalfHeight - math.abs(selfDistanceY)

    if overlapX < overlapY then
        if selfDistanceX > 0 then
            self.Object.X = self.Object.X + overlapX
        else
            self.Object.X = self.Object.X - overlapX
        end
    else
        if selfDistanceY > 0 then
            self.Object.Y = self.Object.Y + overlapY
        else
            self.Object.Y = self.Object.Y - overlapY
        end
    end
end

function Collider:Collide(colliders)
    return function(dt)
        print("-------")
        for _, collider in ipairs(colliders) do
            if collider ~= self then
                if self:Collides(collider) and self:CheckCollision(collider) then
                    -- self:ComputeCollision(collider)
                    collider.Object.Color = {1, 0, 0, 1}
                    print("Collides")
                else
                    collider.Object.Color = {1, 1, 1, 1}
                    print("Doesn't collide")
                end
            end
        end
    end
end

return Collider