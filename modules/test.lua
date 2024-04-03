return {init = function(game)
    game.RunService:Connect("RenderStepped", function(dt)
        print("RenderStepped", dt)

        love.graphics.print("RenderStepped, delta: "..tostring(dt), 10, 10)
    end)
end}