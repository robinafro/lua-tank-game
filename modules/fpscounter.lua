return {init = function(game)
    obj = require("classes.object").new(function(dt)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 7, love.graphics.getHeight() - 23)
        print(love.timer.getFPS())
    end)
    
    obj.ZIndex = 1000
    obj.AlwaysVisible = true
    obj.HUD = true

    game.ObjectService:Add(obj)
end}