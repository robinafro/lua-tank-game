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

function NeuralNetwork:printWeights()
    print("-----IH-----")
    for i = 1, self.HiddenNodes do
        for j = 1, self.InputNodes do
            print(self.WeightsIH[i][j])
        end
    end

    print("-----HO-----")
    for i = 1, self.OutputNodes do
        for j = 1, self.HiddenNodes do
            print(self.WeightsHO[i][j])
        end
    end
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

function NeuralNetwork:crossover(parents)
    local child = NeuralNetwork.new(self.InputNodes, self.HiddenNodes, self.OutputNodes, self.LearningRate)

    for i = 1, self.HiddenNodes do
        for j = 1, self.InputNodes do
            child.WeightsIH[i][j] = parents[math.random(1, #parents)].NeuralNetwork.WeightsIH[i][j]
        end
    end

    for i = 1, self.OutputNodes do
        for j = 1, self.HiddenNodes do
            child.WeightsHO[i][j] = parents[math.random(1, #parents)].NeuralNetwork.WeightsHO[i][j]
        end
    end

    return child
end

function NeuralNetwork:mutate(mutrate)
    local child = NeuralNetwork.new(self.InputNodes, self.HiddenNodes, self.OutputNodes, self.LearningRate)

    for i = 1, self.HiddenNodes do
        for j = 1, self.InputNodes do
            if math.random() < mutrate then
                child.WeightsIH[i][j] = math.random() * 2 - 1
            else
                child.WeightsIH[i][j] = self.WeightsIH[i][j]
            end
        end
    end

    for i = 1, self.OutputNodes do
        for j = 1, self.HiddenNodes do
            if math.random() < mutrate then
                child.WeightsHO[i][j] = math.random() * 2 - 1
            else
                child.WeightsHO[i][j] = self.WeightsHO[i][j]
            end
        end
    end

    return child
end

return NeuralNetwork