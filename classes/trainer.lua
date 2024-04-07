Enemy = require("classes.enemy")
Tank = require("classes.tank")
Collider = require("classes.collider")

Trainer = {}
Trainer.__index = Trainer

function Trainer.new(game)
    local self = setmetatable({}, Trainer)

    self.Population = {}
    self.Size = 20
    self.Generation = 0
    self.BestFitness = 0
    self.BestTank = nil

    self.Game = game

    return self
end

function Trainer:NewGeneration()
    self.Generation = self.Generation + 1
    self.Population = {}

    for i = 1, self.Size do
        local enemy = Enemy.new()
        local tank = Tank.new(self.Game)

        tank.X = 1000
        tank.Y = 1000

        local tankCollider = Collider.new(self.Game.Paths)
        tankCollider.Object = tank
        tankCollider.CollisionName = "enemyplayer"
        tankCollider.CollisionFilterType = "Exclude"
        tankCollider.CollisionFilter = {"enemyplayer"}

        tank.OnDeath = function()
            tankCollider:Destroy()
            enemy:Destroy()
        end

        self.Game.RunService:Connect("Stepped", enemy:Control(tank))
        self.Game.ObjectService:Add(tank)

        enemy.Target = self.Game.Paths.LocalPlayer.Controlling

        self.Population[i] = enemy
    end
end

function Trainer:GetBestFitness()
    for i, enemy in ipairs(self.Population) do
        if enemy.Fitness > self.BestFitness then
            self.BestFitness = enemy.Fitness
            self.BestTank = enemy
        end
    end
end

function Trainer:Clear()
    for i, enemy in ipairs(self.Population) do
        enemy:Destroy()
    end

    self.Population = {}
end

return Trainer