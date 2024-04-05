return {init = function(game)
    map = require("classes.map").new()

    map:Generate()
    map:PrepareToRender(function(c) game.ObjectService:Add(c) end)
end}