local Enemy = require("classes.enemy")
local Tank = require("classes.tank")
local Collider = require("classes.collider")

local WAVE_ENEMY_MULTIPLIER = 1 / 2
local ENEMY_SPAWN_DISTANCE = 1500 * math.max(love.graphics.getWidth(), love.graphics.getHeight()) / 1920
local ENEMY_SPAWN_INTERVAL = 1

local PERFTEST = false

local CurrentWave = 0

local game = {}

local function spawnEnemy()
    local enemy = require("classes.enemy").new(game)
    local enemyTank = require("classes.tank").new(game)
    local enemyCollider = require("classes.collider").new(game.Paths)

    enemyTank.RotSpeed = 1
    enemyTank.ForwSpeed = 100 + math.random(-10, 10)
    enemyTank.Firerate = math.random(1, 2) / 5 + (CurrentWave - 1) * 0.1
    enemyTank.BulletForce = math.random(2000, 3000)
    enemyTank.MaxHealth = ((CurrentWave - 1) * 60 + 80) + math.random(1, 30)
    enemyTank.DefaultDamage = (CurrentWave - 1) * 4 + math.random(1, 10) + 3
    enemyTank.Health = enemyTank.MaxHealth
    enemyTank.RecoilMultiplier = 0.01
    enemyTank.Ammo = math.huge

    enemyCollider.Object = enemyTank
    enemyCollider.CollisionName = "enemyplayer"
    enemyCollider.CollisionFilterType = "Include"
    enemyCollider.CollisionFilter = {"*"}

    local playerX, playerY = game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y
    local angle = math.random() * math.pi * 2

    local mapSize = (game.Paths.Map.Size - 1) * game.Paths.Map.ChunkSize
    
    enemyTank.X = playerX + math.cos(angle) * ENEMY_SPAWN_DISTANCE
    enemyTank.Y = playerY + math.sin(angle) * ENEMY_SPAWN_DISTANCE

    enemyTank.X = math.min(math.max(enemyTank.X, game.Paths.Map.ChunkSize / 2), mapSize)
    enemyTank.Y = math.min(math.max(enemyTank.Y, game.Paths.Map.ChunkSize / 2), mapSize)

    local connection = game.RunService:Connect("Stepped", enemy:Control(enemyTank))

    game.ObjectService:Add(enemy.Controlling)

    enemy.Target = game.Paths.LocalPlayer.Controlling

    return {Enemy = enemy, Tank = enemyTank, Collider = enemyCollider, Connection = connection}
end

local function nextWave()
    CurrentWave = CurrentWave + 1

    game.Signal:send("waveChanged", CurrentWave)
    for i = 1, math.ceil(CurrentWave * WAVE_ENEMY_MULTIPLIER) do
        local enemy = spawnEnemy()

        game.Signal:send("enemySpawned", enemy.Enemy)

        enemy.Tank.OnDeath = function()
            local tookHits = enemy.Tank.TookHits

            game.RunService:Disconnect("Stepped", enemy.Connection)

            enemy.Enemy:Destroy()
            enemy.Collider:Destroy()

            for i, v in ipairs(game.Paths.Enemies) do
                if v == enemy then
                    table.remove(game.Paths.Enemies, i)
                    break
                end
            end

            game.Paths.LocalPlayer.Score = game.Paths.LocalPlayer.Score + game.Paths.LocalPlayer.GainScorePerKill

            local upgrade = game.Paths.LocalPlayer.Controlling:Upgrade()
            game.Paths.LocalPlayer.Controlling.Ammo = game.Paths.LocalPlayer.Controlling.Ammo + tookHits

            game.Signal:send("enemyKilled", enemy.Enemy)
            game.Signal:send("playerUpgraded", upgrade)
            game.Signal:send("ammoChanged", game.Paths.LocalPlayer.Controlling.Ammo)
        end

        table.insert(game.Paths.Enemies, enemy)

        game.RunService:Wait(ENEMY_SPAWN_INTERVAL)
    end
end

local function avgFPS()
    local sum = 0
    local iter = 20

    for i = 1, iter do
        sum = sum + love.timer.getFPS()
        game.RunService:Wait(0.25)
    end

    return sum / iter
end


return {init = function(g)
    game = g

    CurrentWave = 0

    if not PERFTEST then
        if game.Paths.Debug then
            WAVE_ENEMY_MULTIPLIER = 1
            ENEMY_SPAWN_DISTANCE = 500
        end

        while not game.Paths.Map or not game.Paths.LocalPlayer do
            game.RunService:Wait()
        end

        local justStarted = true

        game.Paths.Enemies = {}

        game.RunService:Connect("Heartbeat", function()
            if #game.Paths.Enemies == 0 then
                if not justStarted then
                    game.Paths.LocalPlayer.Score = game.Paths.LocalPlayer.Score + game.Paths.LocalPlayer.GainScorePerWave
                end

                justStarted = false

                nextWave()
            end
        end)
    else
        while not game.Paths.Map or not game.Paths.LocalPlayer do
            game.RunService:Wait()
        end

        game.Paths.Enemies = {}

        game.RunService:Wait(2)

        print("FPS before spawning:", avgFPS())

        for i = 1, 100 do
            table.insert(game.Paths.Enemies, spawnEnemy())
            game.RunService:Wait(0.1)
        end

        print("FPS after spawning:", avgFPS())

        game.RunService:Wait(2)

        for i, v in ipairs(game.Paths.Enemies) do
            game.RunService:Disconnect("Stepped", v.Connection)
            
            v.Enemy:Destroy()
            v.Collider:Destroy()

            game.Paths.Enemies[i] = nil
        end

        game.RunService:Wait(2)

        print("FPS after destroying:", avgFPS())
    end
end
}