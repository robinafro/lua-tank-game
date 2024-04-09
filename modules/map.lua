Map, Structure = require("classes.map"), require("classes.structure")

CHUNK_SIZE = 200
CHUNK_SIZE = 250
MAP_SIZE = 70
STRUCTURES = 60

return {init = function(game)
    if game.Paths.Debug then
        STRUCTURES = 10
        MAP_SIZE = 10
    end

    game.Paths.MapSize = MAP_SIZE
    game.Paths.ChunkSize = CHUNK_SIZE
    game.Paths.Structures = STRUCTURES

    --// Generate map
    map = Map.new(game.Paths.ChunkSize)

    map.Size = game.Paths.MapSize

    for x, row in pairs(map:Generate(game)) do
        for y, chunk in pairs(row) do
            game.ObjectService:Add(chunk.Object)
        end
    end

    --// Generate structures
    for i = 1, game.Paths.Structures do
        local structure = Structure.new(game, Structure.ChooseRandom())
        map:SpawnStructureAtRandomPosition(structure)
    end

    game.Paths.Map = map
    if not game.Paths.LocalPlayer then
        repeat
            game.RunService:Wait()
        until game.Paths.LocalPlayer
    end

    map:SpawnObject(game.Paths.LocalPlayer.Controlling, 500)
    game.Paths.LocalPlayer.Camera:SetPosition(game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y)

    if game.Paths.Debug then
        local Object = require("classes.object")

        for x = 0, map.Size * map.ChunkSize, map.GridSize do
            for y = 0, map.Size * map.ChunkSize, map.GridSize do
                local object = Object.new()

                object.Function = function()
                    local occupied = map:IsCellOccupied(x, y)

                    object.X = x
                    object.Y = y
                    object.Width = map.GridSize
                    object.Height = map.GridSize
                    object.Color = {occupied and 1 or 0, (not occupied) and 1 or 0, 0, 0.2}
                    object.ZIndex = 100000

                    love.graphics.setColor(unpack(object.Color))
                    love.graphics.rectangle("fill", object.X, object.Y, object.Width, object.Height)
                end

                game.ObjectService:Add(object)
            end
        end
    end

    game.RunService:Connect("Heartbeat", function()
        if game.Paths.LocalPlayer then
            map:RefreshGrid(game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y)
        else
            map:RefreshGrid()
        end
    end)
end}