Map, Structure = require("classes.map"), require("classes.structure")

CHUNK_SIZE = 200
-- STRUCTURES = 60
STRUCTURES = 0

return {init = function(game)
    game.Paths.ChunkSize = CHUNK_SIZE
    game.Paths.Structures = STRUCTURES

    --// Generate map
    map = Map.new(game.Paths.ChunkSize)

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

    -- map:SpawnObject(game.Paths.LocalPlayer.Controlling, 500)
    game.Paths.LocalPlayer.Camera:SetPosition(game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y)
end}