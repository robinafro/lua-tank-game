Object = require("classes.object")

Map = {}
Map.__index = Map

function Map.new()
    local self = setmetatable(Object.new(), {__index = Map})
    
    self.Density = 100
    self.Size = 100
    self.nBiomes = 3

    self.Chunks = {}
    self.Image = love.graphics.newImage("assets/textures/grass.png")

    return self
end

function Map:Generate()
    local seed = math.random(-2147483640, 2147483640)

    for x = 0, self.Size - 1 do
        for y = 0, self.Size - 1 do
            local num = 0
            for i = 1, self.nBiomes - 1 do
                num = num + love.math.noise(x / self.Density, y / self.Density, i + seed)
            end

            num = math.min(math.max(num, 0), self.nBiomes - 1)
            color = {num / self.nBiomes * 0.1, num / self.nBiomes * 0.7, num / self.nBiomes * 0.2, 1}
            
            local chunk = require("classes.chunk").new(x, y)

            chunk.BiomeNum = num
            chunk.Color = color

            if self.Chunks[x] == nil then
                self.Chunks[x] = {}
            end

            self.Chunks[x][y] = chunk

            chunk:SetImage(self.Image)
        end
    end
end

function Map:PrepareToRender(callback)
    for x, row in pairs(self.Chunks) do
        for y, chunk in pairs(row) do
            chunk.Function = function()
                chunk:Render()
            end

            callback(chunk)
        end
    end
end

return Map