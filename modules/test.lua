camera = require("modules.camera")

return {init = function(game)
    local cam = camera.new()

    game.ObjectService:SetCamera(cam)

    game.ObjectService:Add({
        X = 0,
        Y = 0,
        Width = 150,
        Height = 150,
        ZIndex = 9,
        Color = {1, 0, 1, 1}
    })

    local x, y = 0, 0
    game.ObjectService:Add({
        ZIndex = 10,
        Function = function(dt)
            x = x + dt * 40
            love.graphics.setColor(1, 1, 0.5, 1)
            love.graphics.rectangle("fill", x, y, 50, 50)
        end
    })

    game.RunService:Connect("RenderStepped", function(dt)
        cam:MoveTo(math.random(-10, 10), math.random(-10, 10))
    end)
end}