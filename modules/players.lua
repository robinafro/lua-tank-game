local game

local function init(g)
    game = g

    local cam = require("classes.camera").new()
    local localPlayer = require("classes.localplayer").new()

    localPlayer:SetCamera(cam)

    game.RunService:Connect("Stepped", localPlayer:Control(require("classes.tank").new()))
    
    game.ObjectService:SetCamera(cam)
    game.ObjectService:Add(localPlayer.Controlling)

    localPlayer.Controlling:SetImage("assets/tanks/tank"..math.random(1, 4)..".png")

    local tankCollider = require("classes.collider").new()
    tankCollider.Object = localPlayer.Controlling

    if not game.Paths.Colliders then
        game.Paths.Colliders = {}
    end

    table.insert(game.Paths.Colliders, tankCollider)

    game.RunService:Connect("Stepped", tankCollider:Collide(game.Paths.Colliders))

    cam.Target = localPlayer.Controlling

    game.Paths.LocalPlayer = localPlayer
end

return {init = init}