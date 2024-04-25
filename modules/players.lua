local game

local function init(g)
    game = g

    local cam = require("classes.camera").new()
    local localPlayer = require("classes.localplayer").new(game)

    localPlayer:SetCamera(cam)

    game.RunService:Connect("Stepped", localPlayer:Control(require("classes.tank").new(game)))

    localPlayer.Controlling.Firerate = 1
    localPlayer.Controlling.DefaultDamage = 80
    localPlayer.Controlling.DamageRandomness = 30
    localPlayer.Controlling.BulletForce = 3500
    
    game.ObjectService:SetCamera(cam)
    game.ObjectService:Add(localPlayer.Controlling)

    local tankCollider = require("classes.collider").new(game.Paths)
    tankCollider.Object = localPlayer.Controlling

    tankCollider.CollisionName = "localplayer"
    tankCollider.CollisionFilterType = "Include"
    tankCollider.CollisionFilter = {"*"}

    cam.Target = localPlayer.Controlling

    game.Paths.LocalPlayer = localPlayer

    if not game.Paths.Map then
        repeat
            game.RunService:Wait()
        until game.Paths.Map
    end

    game.Paths.Map:SpawnObject(game.Paths.LocalPlayer.Controlling, 500)
    game.Paths.LocalPlayer.Camera:SetPosition(game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y)

    localPlayer.Controlling.OnDeath = function()
        game.Paths.Events.PlayerDied:Fire(localPlayer)
    end
end

return {init = init}