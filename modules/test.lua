camera = require("classes.camera")

return {init = function(game)
    local cam = camera.new()

    game.ObjectService:SetCamera(cam)

    local localPlayer = require("classes.localplayer").new()
    local tank = require("classes.tank").new()

    game.RunService:Connect("Stepped", localPlayer:Control(tank))

    game.ObjectService:Add(tank)
end}