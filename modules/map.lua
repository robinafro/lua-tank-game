Map, Structure = require("classes.map"), require("classes.structure")

CHUNK_SIZE = 200
-- STRUCTURES = 60
STRUCTURES = 10

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

    map:SpawnObject(game.Paths.LocalPlayer.Controlling, 500)
    game.Paths.LocalPlayer.Camera:SetPosition(game.Paths.LocalPlayer.Controlling.X, game.Paths.LocalPlayer.Controlling.Y)

    map:RefreshGrid()

    local Object = require("classes.object")

    -- game.RunService:Connect("RenderStepped", function()
        for x = 0, map.Size * map.ChunkSize, map.GridSize do
            for y = 0, map.Size * map.ChunkSize, map.GridSize do
                local x, y = map:MapPointToCell(x, y)
                local occupied = map:IsCellOccupiedAABB(x, y, true)

                -- love.graphics.setColor(map:IsCellOccupied(x,y) and 1 or 0, (not map:IsCellOccupied(x,y)) and 1 or 0, 0, 0.5)
                -- love.graphics.rectangle("fill", x * map.GridSize, y * map.GridSize, map.GridSize, map.GridSize)
                -- print(x, y, map:IsCellOccupied(x,y))

                local x, y = map:MapCellToPoint(x, y)

                local object = Object.new()

                object.X = x
                object.Y = y
                object.Width = map.GridSize
                object.Height = map.GridSize
                object.Color = {occupied and 1 or 0, (not occupied) and 1 or 0, 0, 0.2}
                object.ZIndex = 100000

                game.ObjectService:Add(object)
            end
        end
    --     print("----")
    -- end)
end}