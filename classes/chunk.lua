Object = require("classes.object")
Map = require("classes.map")

Chunk = setmetatable({}, {__index = Map})
Chunk.__index = Chunk   

function Chunk.new(x, y)
    local self = setmetatable({}, Chunk)

    self.Object = Object.new()

    self.X = x
    self.Y = y

    self.Size = 100

    self.Loaded = true

    return self
end

function Chunk:Render()
    if self.Loaded == false then
        return
    end
    
    love.graphics.setColor(self.Color)
    love.graphics.rectangle("fill", self.X * self.Size, self.Y * self.Size, self.Size, self.Size)
end

return Chunk