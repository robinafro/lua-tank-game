Object = require("classes.object")

Map = {}
Map.__index = Map

function Map.new()
    local self = setmetatable(Object.new(), {__index = Map})
    
    self.Size = 20
    self.nBiomes = 3

    self.Chunks = {}

    return self
end

function Map:Generate()
    local seed = math.random(-2147483640, 2147483640)

    for x = 0, self.Size - 1 do
        for y = 0, self.Size - 1 do
            local num = 0
            for i = 1, self.nBiomes - 1 do
                num = num + love.math.noise(x / self.Size, y / self.Size, i + seed)
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
        end
    end
end

function Map:PrepareToRender()
    self.Function = function()
        self:Render()
    end
end

function Map:Render()
    for x, row in pairs(self.Chunks) do
        for y, chunk in pairs(row) do
            chunk:Render()
        end
    end
end

return Map