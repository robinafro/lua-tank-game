return {init = function(game)
    game.RunService:Connect("RenderStepped", function(dt)
        print("RenderStepped", dt)

        love.graphics.print("RenderStepped, delta: "..tostring(dt), 10, 10)

        for i, v in ipairs(game.Paths.TestObjects) do
            love.graphics.print(v, 10, 10 + i * 20)
        end
    end)
end}