Controller = require("classes.controller")
NeuralNetwork = require("classes.neuralnetwork")

local Enemy = setmetatable({}, Controller)
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)

    -- if not network then
    --     self.NeuralNetwork = NeuralNetwork.new(4, 4, 3, 0.1)
    -- else
    --     self.NeuralNetwork = network:mutate(mutrate or 0.1)
    -- end
    
    -- self.Fitness = 0
    self.Target = nil

    -- self.NeuralNetwork:printWeights()

    self.ShootDistance = 2000
    self.ShootAngle = 10
    self.StandAngle = 45
    self.MinGoDistance = 100

    return self
end

function Enemy:UpdateAI(dt)
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

    local distance = math.sqrt(vectorToTarget.X ^ 2 + vectorToTarget.Y ^ 2)

    local angleDifference = self.Controlling.Rotation - self.Target.Rotation

    local inputs = {
        vectorToTargetRelative.X,
        vectorToTargetRelative.Y,
        -- distance,
        angleDifference,
        self.Target.ForwVelocity
    }

    local outputs = self.NeuralNetwork:feedforward(inputs)

    local forward = outputs[1]
    local angular = outputs[2]
    local shoot = outputs[3]

    self.Controlling:Move(forward, angular)
    self.Controlling:Update(dt)

    if shoot > 0.5 then
        self.Controlling:Shoot({"localplayer"})
    end
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