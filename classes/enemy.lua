Controller = require("classes.controller")
NeuralNetwork = require("classes.neuralnetwork")

local Enemy = setmetatable({}, Controller)
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)

    self.NeuralNetwork = NeuralNetwork.new(5, 4, 3, 0.1)
    self.Target = nil

    self.NeuralNetwork:printWeights()

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

    local distance = math.sqrt(vectorToTarget.X ^ 2 + vectorToTarget.Y ^ 2)

    local angleDifference = self.Controlling.Rotation - self.Target.Rotation

    local inputs = {
        vectorToTargetRelative.X,
        vectorToTargetRelative.Y,
        distance,
        angleDifference,
        self.Target.ForwVelocity
    }

    local outputs = self.NeuralNetwork:feedforward(inputs)

    local forward = outputs[1]
    local angular = outputs[2]
    local shoot = outputs[3]

    print(forward)

    self.Controlling:Move(forward, angular)
    self.Controlling:Update(dt)

    if shoot > 0.5 then
        self.Controlling:Shoot()
    end
end

return Enemy