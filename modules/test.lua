return {init = function(game)
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
end}