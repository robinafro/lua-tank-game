local game

local function init(g)
    game = g

    local cam = require("classes.camera").new()
    local localPlayer = require("classes.localplayer").new()

    localPlayer:SetCamera(cam)

    game.RunService:Connect("Stepped", localPlayer:Control(require("classes.tank").new(game)))
    
    game.ObjectService:SetCamera(cam)
    game.ObjectService:Add(localPlayer.Controlling)

    local tankCollider = require("classes.collider").new(game.Paths)
    tankCollider.Object = localPlayer.Controlling

    tankCollider.CollisionName = "localplayer"
    tankCollider.CollisionFilterType = "Include"
    tankCollider.CollisionFilter = {"*"}

    cam.Target = localPlayer.Controlling

    game.Paths.LocalPlayer = localPlayer

    for i = 1,50 do
        local enemy = require("classes.enemy").new(game)
        local enemyTank = require("classes.tank").new(game)
        local enemyCollider = require("classes.collider").new(game.Paths)

        enemyTank.ForwSpeed = 100
        enemyTank.RotSpeed = 1

        enemyCollider.Object = enemyTank
        enemyCollider.CollisionName = "enemyplayer"
        enemyCollider.CollisionFilterType = "Include"
        enemyCollider.CollisionFilter = {"*"}

        game.RunService:Connect("Stepped", enemy:Control(enemyTank))

        game.ObjectService:Add(enemy.Controlling)

        enemy.Controlling.X = 500
        enemy.Controlling.Y = 500
        enemy.Target = localPlayer.Controlling

        game.RunService:Wait(1 / 15)
    end
end

return {init = init}