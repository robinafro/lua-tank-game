return {init = function(game)
    map = require("classes.map").new()

    map:Generate()
    map:PrepareToRender()
    
    game.ObjectService:Add(map)
end}