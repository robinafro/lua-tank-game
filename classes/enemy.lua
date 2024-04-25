Controller = require("classes.controller")
luafinding = require("lib.luafinding.luafinding")
vector = require("lib.luafinding.vector")
raycast = require("lib.luafinding.raycast")

local function _sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

local Enemy = setmetatable({}, Controller)
Enemy.__index = Enemy

Enemy.MinAggressivity = 0.12
Enemy.MaxAggressivity = 0.4

function Enemy.new(game)
    local self = setmetatable({}, Enemy)

    self.Game = game
    self.Target = nil
    self.TargetPos = nil
    self.TargetPath = nil
    self.CurrentWaypoint = 1
    self.WaypointReachedDistance = 100
    self.UpdatePathDebounce = 0.5
    self.LastUpdatedPath = 0
    self.ShootDistance = 2000
    self.ShootAngle = 25
    self.ShootWillingness = 0
    self.Aggressivity = math.random() * (Enemy.MaxAggressivity - Enemy.MinAggressivity) + Enemy.MinAggressivity
    self.StandAngle = 45
    self.MinGoDistance = 100
    self.SpeedUpDistance = 700 * math.max(love.graphics.getWidth(), love.graphics.getHeight()) / 1920

    self.raycast = raycast.new()
    self.raycast:Initialize(self.Game, "Include", {"structure"})

    return self
end

function Enemy:OnDestroy()
    self.raycast:Destroy()
end

function Enemy:Update(dt)
    if not self.Target or not self.Game.Paths.Map then
        return
    end

    local angle = self:CalculateShootWillingness()
    
    if self.ShootWillingness > 1 - self.Aggressivity then
        self.TargetPath = nil

        self.Controlling:Move(0, angle)

        if angle < self.ShootAngle then
            self.Controlling:Shoot({"localplayer"}, {"enemyplayer"})
        end
    else
        self.TargetPos = {X = self.Target.X, Y = self.Target.Y}

        if os.clock() - self.LastUpdatedPath >= self.UpdatePathDebounce then
            self.LastUpdatedPath = os.clock()
    
            coroutine.wrap(function()
                self:UpdatePath()
            end)()
        end

        if self.TargetPath then
            local waypoint = self.TargetPath[self.CurrentWaypoint]
    
            if waypoint then
                self:MoveTowards(self.TargetPath[self.CurrentWaypoint])
                
                if self:Reached(self.TargetPath[self.CurrentWaypoint]) then
                    self.CurrentWaypoint = self.CurrentWaypoint + 1
                end
    
                if self.Game.Paths.Debug then
                    self:VisualizePath()
                end
            end
        end
    
        local distanceToTarget = math.sqrt((self.Target.X - self.Controlling.X) ^ 2 + (self.Target.Y - self.Controlling.Y) ^ 2)
    
        if not self.DefaultSpeed then
            self.DefaultSpeed = self.Controlling.ForwSpeed
        end
        
        self.Controlling.ForwSpeed = self.DefaultSpeed * math.max(distanceToTarget / self.SpeedUpDistance, 1)
    end

    self.Controlling:Update(dt)
end

function Enemy:CalculateShootWillingness()
    local reachable = self.raycast:Compute(vector(self.Controlling.X, self.Controlling.Y), vector(self.Target.X, self.Target.Y), self.Game.Paths.Renderables, "structure")

    if not reachable then
        self.ShootWillingness = 0
        return 0
    end

    local distance = math.sqrt((self.Target.X - self.Controlling.X) ^ 2 + (self.Target.Y - self.Controlling.Y) ^ 2)
    local angle = math.deg(math.atan2(self.Target.Y - self.Controlling.Y, self.Target.X - self.Controlling.X) - self.Controlling.Rotation)
    angle = math.abs(angle) % 180 * _sign(angle)

    self.ShootWillingness = (distance < self.ShootDistance) and ((1 - math.abs(angle) / 180) + (1 - distance / self.ShootDistance)) / 2 or 0

    return angle
end

function Enemy:Reached(waypoint)
    local waypointMappedX, waypointMappedY = self.Game.Paths.Map:MapCellToPoint(waypoint.x, waypoint.y)

    local distance = math.sqrt((waypointMappedX - self.Controlling.X) ^ 2 + (waypointMappedY - self.Controlling.Y) ^ 2)

    return distance < self.WaypointReachedDistance
end

function Enemy:MoveTowards(waypoint)
    local waypointMappedX, waypointMappedY = self.Game.Paths.Map:MapCellToPoint(waypoint.x, waypoint.y)

    local vectorToWaypoint = {
        X = waypointMappedX - self.Controlling.X,
        Y = waypointMappedY - self.Controlling.Y
    }

    local vectorToWaypointRelative = {
        X = vectorToWaypoint.X * math.cos(self.Controlling.Rotation) + vectorToWaypoint.Y * math.sin(self.Controlling.Rotation),
        Y = vectorToWaypoint.Y * math.cos(self.Controlling.Rotation) - vectorToWaypoint.X * math.sin(self.Controlling.Rotation)
    }

    local distance = math.sqrt((waypointMappedX - self.Controlling.X) ^ 2 + (waypointMappedY - self.Controlling.Y) ^ 2)
    local angle = math.deg(math.atan2(vectorToWaypointRelative.Y, vectorToWaypointRelative.X))

    self.Controlling:Move((distance > self.MinGoDistance and math.abs(angle) < self.StandAngle) and 1 or 0, math.min(math.max(angle, -1), 1))
end

function Enemy:DistanceTo(waypoint)
    local waypointMappedX, waypointMappedY = self.Game.Paths.Map:MapCellToPoint(waypoint.x, waypoint.y)

    local dx = self.Controlling.X - waypointMappedX
    local dy = self.Controlling.Y - waypointMappedY

    return math.sqrt(dx * dx + dy * dy)
end

function Enemy:FindClosestReachablePoint(goalX, goalY)
    local free = self.Game.Paths.Map:IsCellOccupied(goalX, goalY, true)

    if free then
        return vector(goalX, goalY)
    end

    local subdivisions = 40
    local currentRadius = 0.5
    local radiusStep = 0.5

    local found = {}

    while currentRadius < 4 do
        for i = 1, subdivisions do
            local angle = 2 * math.pi / subdivisions * i
            local x = goalX + currentRadius * math.cos(angle)
            local y = goalY + currentRadius * math.sin(angle)

            if self.Game.Paths.Map:IsCellOccupied(x, y, true) then
                local pointMappedX, pointMappedY = self.Game.Paths.Map:MapCellToPoint(x, y)
                local goalMappedX, goalMappedY = self.Game.Paths.Map:MapCellToPoint(goalX, goalY)

                local reachable = self.raycast:Compute(vector(goalMappedX, goalMappedY), vector(pointMappedX, pointMappedY), self.Game.Paths.Renderables, "structure")
            
                if reachable then
                    table.insert(found, vector(x, y))
                end
            end
        end

        currentRadius = currentRadius + radiusStep
    end

    table.sort(found, function(a, b)
        local distanceA = math.sqrt((goalX - a.x) ^ 2 + (goalY - a.y) ^ 2) + self:DistanceTo(a)
        local distanceB = math.sqrt((goalX - b.x) ^ 2 + (goalY - b.y) ^ 2) + self:DistanceTo(b)
        return distanceA < distanceB
    end)

    if #found > 0 then
        return found[1]
    else
        return vector(goalX, goalY)
    end
end

function Enemy:UpdatePath()
    local selfMappedX, selfMappedY = self.Game.Paths.Map:MapPointToCell(self.Controlling.X, self.Controlling.Y)
    local targetMappedX, targetMappedY = self.Game.Paths.Map:MapPointToCell(self.Target.X, self.Target.Y)

    local start = vector(selfMappedX, selfMappedY)

    local goal = self:FindClosestReachablePoint(targetMappedX, targetMappedY)-- or vector(targetMappedX, targetMappedY)

    local path = luafinding(start, goal, self.Game.Paths.Map.Grid):GetPath()
    
    if path then
        local closestWaypointIndex = 1
        local closestWaypointDistance = self:DistanceTo(path[1])

        for i = 2, #path do
            local distance = self:DistanceTo(path[i])

            if distance < closestWaypointDistance and not self:Reached(path[i]) then
                closestWaypointIndex = i
                closestWaypointDistance = distance * i --// * i to make it more likely to choose the next waypoint (weighted)
            end
        end
        
        self.CurrentWaypoint = closestWaypointIndex
        self.TargetPath = path
    end
end

function Enemy:VisualizePath()
    if not self.TargetPath then
        return
    end

    if not self.Visualizers then self.Visualizers = {} end

    for i = 1, #self.TargetPath do
        local waypoint = self.TargetPath[i]
        local waypointMappedX, waypointMappedY = self.Game.Paths.Map:MapCellToPoint(waypoint.x, waypoint.y)

        local data = self.Visualizers and self.Visualizers[i]

        if not data then
            local obj = {
                X = waypointMappedX,
                Y = waypointMappedY,
                Width = 15,
                Height = 15,
                Color = {1, 0.03 * i, 0, 0.8},
                ZIndex = 200000
            }

            id = self.Game.ObjectService:Add(obj)

            self.Visualizers[i] = {Object = obj, ID = id}
        else
            data.Object.X = waypointMappedX
            data.Object.Y = waypointMappedY
        end
    end

    for i = #self.TargetPath + 1, #self.Visualizers do
        local data = self.Visualizers[i]

        self.Game.ObjectService:Remove(data.ID)
        self.Visualizers[i] = nil
    end
end

function Enemy:Update_old(dt)
    if not self.Target then
        return
    end

    local vectorToTarget = {
        X = self.Target.X - self.Controlling.X,
        Y = self.Target.Y - self.Controlling.Y
    }

    local vectorToTargetRelative = {
        X = vectorToTarget.X * math.cos(self.Controlling.Rotation) + vectorToTarget.Y * math.sin(self.Controlling.Rotation),
        Y = vectorToTarget.Y * math.cos(self.Controlling.Rotation) - vectorToTarget.X * math.sin(self.Controlling.Rotation)
    }

    local distance = math.sqrt((self.Target.X - self.Controlling.X) ^ 2 + (self.Target.Y - self.Controlling.Y) ^ 2)
    local angle = math.deg(math.atan2(vectorToTargetRelative.Y, vectorToTargetRelative.X))

    if distance < self.ShootDistance and math.abs(angle) < self.ShootAngle then
        self.Controlling:Shoot({"localplayer"}, {"enemyplayer"})
    end

    self.Controlling:Move((distance > self.MinGoDistance and math.abs(angle) < self.StandAngle) and 1 or 0, math.min(math.max(angle, -1), 1))
    self.Controlling:Update(dt)
end

return Enemy