Controller = require("classes.controller")
luafinding = require("lib.luafinding.luafinding")
vector = require("lib.luafinding.vector")

local Enemy = setmetatable({}, Controller)
Enemy.__index = Enemy

function Enemy.new(game)
    local self = setmetatable({}, Enemy)

    self.Game = game
    self.Target = nil
    self.TargetPos = vector(0,0)
    self.TargetPath = nil
    self.CurrentWaypoint = 1
    self.WaypointReachedDistance = 100
    self.UpdatePathDebounce = 0.5
    self.LastUpdatedPath = 0
    self.ShootDistance = 2000
    self.ShootAngle = 10
    self.StandAngle = 45
    self.MinGoDistance = 100

    return self
end

function Enemy:Update(dt)
    if not self.Target or not self.Game.Paths.Map then
        return
    end

    if os.time() - self.LastUpdatedPath >= self.UpdatePathDebounce then
        self.LastUpdatedPath = os.time()
        self:UpdatePath()
    end

    if not self.TargetPath then
        return
    end

    local waypoint = self.TargetPath[self.CurrentWaypoint]

    if not waypoint then
        return
    end

    self:MoveTowards(self.TargetPath[self.CurrentWaypoint])
    
    if self:Reached(self.TargetPath[self.CurrentWaypoint]) then
        self.CurrentWaypoint = self.CurrentWaypoint + 1
    end

    self.Controlling:Update(dt)

    if self.Game.Paths.Debug then
        self:VisualizePath()
    end
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

function Enemy:UpdatePath()
    local selfMappedX, selfMappedY = self.Game.Paths.Map:MapPointToCell(self.Controlling.X, self.Controlling.Y)
    local targetMappedX, targetMappedY = self.Game.Paths.Map:MapPointToCell(self.Target.X, self.Target.Y)

    local start = vector(selfMappedX, selfMappedY)
    local goal = vector(targetMappedX, targetMappedY)

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
                Width = 5,
                Height = 5,
                Color = {1, 0.2, 0, 0.5},
                ZIndex = 100000
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