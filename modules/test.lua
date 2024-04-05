return {init = function(game)
    map = require("classes.map").new()

    for x, row in pairs(map:Generate()) do
        for y, chunk in pairs(row) do
            game.ObjectService:Add(chunk.Object)
        end
    end
end}