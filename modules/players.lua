local game

local function init(g)
    game = g

    local cam = require("classes.camera").new()
    local localPlayer = require("classes.localplayer").new()

    localPlayer:SetCamera(cam)

    game.RunService:Connect("Stepped", localPlayer:Control(require("classes.tank").new(game)))
    
    game.ObjectService:SetCamera(cam)
    game.ObjectService:Add(localPlayer.Controlling)

    localPlayer.Controlling:SetImage("assets/tanks/tank"..math.random(1, 4)..".png")

    local tankCollider = require("classes.collider").new(game.Paths)
    tankCollider.Object = localPlayer.Controlling

    tankCollider.CollisionName = "localplayer"
    tankCollider.CollisionFilterType = "Include"
    tankCollider.CollisionFilter = {"*"}

    cam.Target = localPlayer.Controlling

    game.Paths.LocalPlayer = localPlayer

    local enemy = require("classes.enemy").new()

    game.RunService:Connect("Stepped", enemy:Control(require("classes.tank").new(game)))

    game.ObjectService:Add(enemy.Controlling)

    enemy.Controlling.X = 1000
    enemy.Controlling.Y = 1000
    enemy.Target = localPlayer.Controlling

    localPlayer.Controlling.X = 1050
    localPlayer.Controlling.Y = 1050
end

return {init = init}