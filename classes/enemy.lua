Controller = require("classes.controller")
NeuralNetwork = require("classes.neuralnetwork")

local Enemy = setmetatable({}, Controller)
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)

    self.NeuralNetwork = NeuralNetwork.new(7, 0, 3, 0.1)
    self.Target = nil

    return self
end

function Enemy:Update(dt)
    if not self.Target then
        return
    end

    local inputs = {
        self.Controlling.X,
        self.Controlling.Y,
        self.Controlling.Rotation,
        self.Target.X,
        self.Target.Y,
        self.Target.Rotation,
        self.Target.ForwVelocity
    }

    print("-----INPUTS-----")
    for i = 1, #inputs do
        print(inputs[i])
    end

    local outputs = self.NeuralNetwork:feedforward(inputs)

    print("-----OUTPUTS-----")
    for i = 1, #outputs do
        print(outputs[i])
    end

    local forward = outputs[1]
    local angular = outputs[2]

    print("-----FORWARD-----")
    print(forward)
    print("-----ANGULAR-----")
    print(angular)

    self.Controlling:Move(forward, angular, true)
    self.Controlling:Update(dt)
end

return Enemy