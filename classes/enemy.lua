Controller = require("classes.controller")
NeuralNetwork = require("classes.neuralnetwork")

local Enemy = setmetatable({}, Controller)
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)

    self.NeuralNetwork = NeuralNetwork.new(4, 4, 3, 0.1)
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

    local angleDifference = self.Controlling.Rotation - self.Target.Rotation


    local inputs = {
        vectorToTargetRelative.X,
        vectorToTargetRelative.Y,
        angleDifference,
        self.Target.ForwVelocity
    }

    local outputs = self.NeuralNetwork:feedforward(inputs)

    local forward = outputs[1]
    local angular = outputs[2]

    print(forward)

    self.Controlling:Move(forward, angular, true)
    self.Controlling:Update(dt)
end

return Enemy