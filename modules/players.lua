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

    if not game.Paths.Map then
        repeat
            game.RunService:Wait()
        until game.Paths.Map
    end

    game.Paths.Map:SpawnObject(game.Paths.LocalPlayer.Controlling, 500)
    game.Paths.LocalPlayer.Camera:SetPosition(game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y)
end

return {init = init}