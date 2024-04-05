local game

local function init(g)
    game = g

    local cam = require("classes.camera").new()
    local localPlayer = require("classes.localplayer").new()

    localPlayer:SetCamera(cam)

    game.RunService:Connect("Stepped", localPlayer:Control(require("classes.tank").new()))
    
    game.ObjectService:SetCamera(cam)
    game.ObjectService:Add(localPlayer.Controlling)

    do
        -- print(os.time())
        -- math.randomseed(os.time())
        -- game.RunService:Wait(1)
        -- math.randomseed(os.time())
        localPlayer.Controlling:SetImage("assets/tanks/tank"..math.random(1, 4)..".png")
    end
end

return {init = init}