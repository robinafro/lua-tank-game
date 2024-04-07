Object = require("classes.object")
Map = require("classes.map")

Chunk = setmetatable({}, Map)
Chunk.__index = Chunk

function Chunk.new(x, y, size)
    local self = setmetatable({}, Chunk)
    self.Object = Object.new()

    self.Xnum = x
    self.Ynum = y

    self.ChunkSize = size
    
    self.X = self.Xnum * self.ChunkSize
    self.Y = self.Ynum * self.ChunkSize

    self.Object.X = self.X
    self.Object.Y = self.Y
    self.Object.Width = self.ChunkSize
    self.Object.Height = self.ChunkSize

    self.Object.Function = function()
        self:Render()
    end

    return self
end

function Chunk:Render()
    if self.Image == nil then
        return
    end
    
    love.graphics.setColor(self.Color)
    love.graphics.draw(self.Image, self.Xnum * self.ChunkSize, self.Ynum * self.ChunkSize, 0, self.ChunkSize / self.Image:getWidth(), self.ChunkSize / self.Image:getHeight())
end

function Chunk:SetImage(image)
    self.Image = image
end

return Chunk