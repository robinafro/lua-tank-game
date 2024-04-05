return {init = function(game)
    local object = require("classes.object").new()

    object.X = 100
    object.Y = 100
    object.Width = 1000
    object.Height = 100
    object.ZIndex = 2

    game.ObjectService:Add(object)

    local collider = require("classes.collider").new()

    collider.Static = true
    collider.CollisionName = "default"
    collider.CollisionFilterType = "Include"
    collider.CollisionFilter = {"default", "player"}

    collider.Object = object

    if not game.Paths.Colliders then
        game.Paths.Colliders = {}
    end

    table.insert(game.Paths.Colliders, collider)

    game.RunService:Connect("Stepped", collider:Collide(game.Paths.Colliders))
end}