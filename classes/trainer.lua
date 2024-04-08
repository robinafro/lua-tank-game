Enemy = require("classes.enemy")
Tank = require("classes.tank")
Collider = require("classes.collider")

Trainer = {}
Trainer.__index = Trainer

function Trainer.new(game)
    local self = setmetatable({}, Trainer)

    self.Population = {}
    self.Remaining = 0
    self.Size = 4
    self.nParents = 2
    self.MutationRate = 0.4
    self.Generation = 0
    self.BestFitness = 0
    self.BestTank = nil

    self.FitnessScores = {
        Hit = 1,
        Miss = -1,
        Death = -5,
        TooFar = -0.5
    }

    self.Game = game

    return self
end

function Trainer:NewGeneration(crossovernn)
    self.Generation = self.Generation + 1
    self.Population = {}
    self.Remaining = self.Size

    for i = 1, self.Size do
        local enemy = Enemy.new(crossovernn, self.MutationRate)
        local tank = Tank.new(self.Game)

        tank.X = math.random(0, 600) + 100
        tank.Y = math.random(0, 600) + 100

        local tankCollider = Collider.new(self.Game.Paths)
        tankCollider.Object = tank
        tankCollider.CollisionName = "enemyplayer"
        tankCollider.CollisionFilterType = "Exclude"
        tankCollider.CollisionFilter = {"enemyplayer"}

        tank.OnDeath = function()
            self.Population[i] = {Fitness = enemy.Fitness, NeuralNetwork = enemy.NeuralNetwork} --// We will destroy the enemy object, so we need to save the fitness score
            self.Remaining = self.Remaining - 1

            tankCollider:Destroy()
            enemy:Destroy()
            
            if self.Remaining == 0 then
                self:Reproduce()
            end
        end

        tank.OnFired = function(bullet)
            coroutine.wrap(function()
                self.Game.RunService:Wait(2)

                if bullet.Active then
                    enemy.Fitness = enemy.Fitness + self.FitnessScores.Miss
                else
                    enemy.Fitness = enemy.Fitness + self.FitnessScores.Hit
                end
            end)()
        end

        local fnc = enemy:Control(tank)
        
        self.Game.RunService:Connect("Stepped", function(dt)
            if tank.Target then
                local distance = math.sqrt((tank.X - tank.Target.X) ^ 2 + (tank.Y - tank.Target.Y) ^ 2)

                if distance > 500 then
                    tank.Fitness = tank.Fitness + self.FitnessScores.TooFar * dt
                end
            end

            fnc(dt)
        end)
        self.Game.ObjectService:Add(tank)

        enemy.Target = self.Game.Paths.LocalPlayer.Controlling

        self.Population[i] = enemy
    end
end

function Trainer:Reproduce()
    local best = self:GetBest(self.nParents)

    local found = false; do
        for _, enemy in pairs(best) do
            if enemy.NeuralNetwork then
                found = true
            end
        end
    end

    if not found then best = {Enemy.new(nil, self.MutationRate)} end

    local firstParent = best[1]
    local remainingParents = {}; do
        for i = 2, #best do
            table.insert(remainingParents, best[i])
        end
    end

    local new = firstParent.NeuralNetwork:crossover(remainingParents)
    
    self:NewGeneration(new)
end

function Trainer:GetBest(n)
    table.sort(self.Population, function(a, b)
        return (a.Fitness or 0) > (b.Fitness or 0)
    end)

    local best = {}

    for i = 1, n do
        table.insert(best, self.Population[i])
    end

    return best
end

function Trainer:UpdateBestFitness()
    for i, enemy in ipairs(self.Population) do
        if enemy.Fitness > self.BestFitness then
            self.BestFitness = enemy.Fitness
            self.BestTank = enemy
        end
    end
end

function Trainer:Clear()
    for i, enemy in ipairs(self.Population) do
        if enemy.Destroy then
            enemy:Destroy()
        end
    end

    self.Population = {}
end

return Trainer