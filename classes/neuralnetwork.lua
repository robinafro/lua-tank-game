NeuralNetwork = {}
NeuralNetwork.__index = NeuralNetwork

function NeuralNetwork.new(input_nodes, hidden_nodes, output_nodes, learning_rate)
    local self = setmetatable({}, NeuralNetwork)

    self.InputNodes = input_nodes
    self.HiddenNodes = hidden_nodes
    self.OutputNodes = output_nodes
    self.LearningRate = learning_rate

    self.WeightsIH = {}
    self.WeightsHO = {}

    for i = 1, self.HiddenNodes do
        self.WeightsIH[i] = {}
        for j = 1, self.InputNodes do
            self.WeightsIH[i][j] = math.random() * 2 - 1
        end
    end

    for i = 1, self.OutputNodes do
        self.WeightsHO[i] = {}
        for j = 1, self.HiddenNodes do
            self.WeightsHO[i][j] = math.random() * 2 - 1
        end
    end

    return self
end

function NeuralNetwork:feedforward(inputs)
    local hidden = {}
    local output = {}

    for i = 1, self.HiddenNodes do
        local sum = 0
        for j = 1, self.InputNodes do
            sum = sum + self.WeightsIH[i][j] * inputs[j]
        end
        hidden[i] = 1 / (1 + math.exp(-sum))
    end

    for i = 1, self.OutputNodes do
        local sum = 0
        for j = 1, self.HiddenNodes do
            sum = sum + self.WeightsHO[i][j] * hidden[j]
        end
        output[i] = 1 / (1 + math.exp(-sum))
    end

    return output
end

return NeuralNetwork