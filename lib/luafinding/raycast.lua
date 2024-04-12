Object = require("classes.object")
Collider = require("classes.collider")

local MAX_DISTANCE_FOR_AABB = 9999999

local raycast = {}

function raycast:Initialize(game, filterType, filter)
    self.Game = game

    self.RaycastObject = Object.new()
    self.RaycastObject.RaycastName = "Raycast"

    if self.Game.Debug then
        self.RaycastObject.Color = {1, 0, 0, 0.5}
        self.RaycastObject.ZIndex = 9999
        self.RaycastObject.AlwaysVisible = true
    end

    self.RaycastCollider = Collider.new(game.Paths, self.RaycastObject)
    self.RaycastCollider.Static = true
    self.RaycastCollider.CanCollide = false
    self.RaycastCollider.CanTouch = true
    self.RaycastCollider.CollisionName = "Raycast"
    self.RaycastCollider.CollisionFilterType = filterType
    self.RaycastCollider.CollisionFilter = filter

    self.Game.ObjectService:Add(self.RaycastObject)
end

function raycast:Compute(start, goal, objects, include)
    --//TODO: potom mozna to udelej SAT kolizema

    -- Objects is a table of all objects, they all have .X, .Y, .Width, .Height

    local dx = goal.x - start.x
    local dy = goal.x - start.x

    local distance = math.sqrt(dx * dx + dy * dy)   

    if distance == 0 then
        return false
    end

    local angle = math.deg(math.atan2(dy, dx))

    -- local step = 20
    -- local steps = distance / step
    
    -- for i = 1, steps do
    --     local x = start.x + step * i * math.cos(angle)
    --     local y = start.y + step * i * math.sin(angle)
        
    --     for _, object in pairs(objects) do
    --         local distance = math.min((object.X - x), (object.Y - y))

    --         if distance < MAX_DISTANCE_FOR_AABB then
    --             if object.RaycastName == include and object:CollidesWith(x, y, 5, 5) then
    --                 return false
    --             end
    --         end
    --     end
    -- end

    self.RaycastObject.Width = distance
    self.RaycastObject.Height = 5
    self.RaycastObject.Rotation = angle
    self.RaycastObject.X = start.x + distance / 2 * math.cos(angle)
    self.RaycastObject.Y = start.y + distance / 2 * math.sin(angle)

    local collides = false

    self.RaycastCollider.CollisionFunction = function(me, collider)
        if collider.Object.RaycastName == include then
            collides = true
        end
    end

    self.RaycastCollider:Collide(self.Game.Paths.Colliders, true)

    return not collides
end

return raycast