local Enemy = require("classes.enemy")
local Tank = require("classes.tank")
local Collider = require("classes.collider")

local WAVE_ENEMY_MULTIPLIER = 1
local ENEMY_SPAWN_DISTANCE = 1500 * math.max(love.graphics.getWidth(), love.graphics.getHeight()) / 1920
local ENEMY_SPAWN_INTERVAL = 1

local CurrentWave = 0
local Alive = {}

local game = nil

local function spawnEnemy()
    local enemy = require("classes.enemy").new(game)
    local enemyTank = require("classes.tank").new(game)
    local enemyCollider = require("classes.collider").new(game.Paths)

    enemyTank.ForwSpeed = 100
    enemyTank.RotSpeed = 1

    enemyCollider.Object = enemyTank
    enemyCollider.CollisionName = "enemyplayer"
    enemyCollider.CollisionFilterType = "Include"
    enemyCollider.CollisionFilter = {"*"}

    local playerX, playerY = game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y
    local angle = math.random() * math.pi * 2
    
    enemyTank.X = playerX + math.cos(angle) * ENEMY_SPAWN_DISTANCE
    enemyTank.Y = playerY + math.sin(angle) * ENEMY_SPAWN_DISTANCE

    game.RunService:Connect("Stepped", enemy:Control(enemyTank))

    game.ObjectService:Add(enemy.Controlling)

    enemy.Target = game.Paths.LocalPlayer.Controlling

    return {Enemy = enemy, Tank = enemyTank, Collider = enemyCollider}
end

local function nextWave()
    CurrentWave = CurrentWave + 1

    for i = 1, math.ceil(CurrentWave * WAVE_ENEMY_MULTIPLIER) do
        local enemy = spawnEnemy()

        enemy.Tank.OnDeath = function()
            enemy.Enemy:Destroy()
            enemy.Collider:Destroy()

            for i, v in ipairs(Alive) do
                if v == enemy then
                    table.remove(Alive, i)
                    break
                end
            end
        end

        table.insert(Alive, enemy)

        game.RunService:Wait(ENEMY_SPAWN_INTERVAL)
    end
end

return {init = function(g)
    game = g

    while not game.Paths.Map or not game.Paths.LocalPlayer do
        game.RunService:Wait()
    end

    while true do
        nextWave()

        repeat
            game.RunService:Wait()
        until #Alive == 0
    end
end}