Object = require("classes.object")

Map = {}
Map.__index = Map

function Map.new(chunkSize)
    local self = setmetatable(Object.new(), {__index = Map})
    
    self.Density = 100
    self.Size = 50
    self.ChunkSize = chunkSize or 300
    self.nBiomes = 3

    self.Chunks = {}
    self.Image = love.graphics.newImage("assets/textures/grass.png")

    return self
end

function Map:Generate(game)
    local seed = math.random(-2147483640, 2147483640)

    for x = 0, self.Size - 1 do
        for y = 0, self.Size - 1 do
            local num = 0
            for i = 1, self.nBiomes - 1 do
                num = num + love.math.noise(x / self.Density, y / self.Density, i + seed)
            end

            num = math.min(math.max(num, 0), self.nBiomes - 1)
            color = {num / self.nBiomes * 0.2, num / self.nBiomes * 0.7, num / self.nBiomes * 0.2, 1}
            
            local chunk = require("classes.chunk").new(x, y, self.ChunkSize)
            
            chunk.BiomeNum = num
            chunk.Color = color

            if self.Chunks[x] == nil then
                self.Chunks[x] = {}
            end

            self.Chunks[x][y] = chunk

            chunk:SetImage(self.Image)
        end
    end

    local object = require("classes.object")
    local collider = require("classes.collider")

    -- Spawn walls on the edges of the map
    local width = 50
    local length = self.Size * self.ChunkSize
    local wallPositions = {
        {0,0, length, width},
        {0,0, width, length},
        {0,length, length + width, width},
        {length,0, width, length + width}
    }

    local walls = {}

    for _, wallPosition in ipairs(wallPositions) do
        local wall = object.new()
        wall.X = wallPosition[1]
        wall.Y = wallPosition[2]
        wall.Width = wallPosition[3]
        wall.Height = wallPosition[4]
        wall.Color = {0.2, 0.2, 0.2, 1}
        wall.ZIndex = 100
        wall.AlwaysVisible = true

        local collider = collider.new(game.Paths)
        collider.Static = true
        collider.Object = wall
        collider.CollisionName = "wall"
        collider.CollisionFilterType = "Include"
        collider.CollisionFilter = {"*"}

        game.ObjectService:Add(wall)
        
        table.insert(walls, {Wall = wall, Collider = collider})
    end

    return self.Chunks
end

function Map:SpawnStructureAtRandomPosition(structure)
    local x = math.random(1, self.Size - 1)
    local y = math.random(1, self.Size - 1)

    structure.Position = {X = x, Y = y}
    structure:Generate()

    return structure
end

function Map:SpawnObject(object, perimeter)
    if type(perimeter) == "number" then
        local realSize = self.Size * self.ChunkSize
        perimeter = {realSize/2 - perimeter/2, realSize/2 + perimeter/2, realSize/2 - perimeter/2, realSize/2 + perimeter/2}
    end
    
    local x = math.random(perimeter[1], perimeter[2])
    local y = math.random(perimeter[3], perimeter[4])

    object.X = x
    object.Y = y

    return object
end

function Map:GetChunkSize()
    return self.ChunkSize
end

return Map