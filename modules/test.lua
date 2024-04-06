return {init = function(game)
    local object = require("classes.object").new()

    object.X = 100
    object.Y = 100
    object.Width = 50
    object.Height = 50
    object.Rotation = 90
    object.ZIndex = 2

    game.ObjectService:Add(object)

    local collider = require("classes.collider").new(game.Paths)

    collider.Static = false
    collider.CollisionName = "default"
    collider.CollisionFilterType = "Include"
    collider.CollisionFilter = {"default", "player"}

    collider.Object = object
end}