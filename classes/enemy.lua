Controller = require("classes.controller")
luafinding = require("lib.luafinding.luafinding")

local Enemy = setmetatable({}, Controller)
Enemy.__index = Enemy

function Enemy.new(game)
    local self = setmetatable({}, Enemy)

    self.Game = game
    self.Target = nil

    self.ShootDistance = 2000
    self.ShootAngle = 10
    self.StandAngle = 45
    self.MinGoDistance = 100

    return self
end

function Enemy:Update(dt)
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