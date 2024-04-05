Object = require("classes.object")
Map = require("classes.map")

Chunk = setmetatable({}, {__index = Map})
Chunk.__index = Chunk   

function Chunk.new(x, y)
    local self = setmetatable({}, Chunk)

    self.Object = Object.new()

    self.Xnum = x
    self.Ynum = y

    self.Size = 300
    
    self.X = self.Xnum * self.Size
    self.Y = self.Ynum * self.Size

    return self
end

function Chunk:Render()
    if self.Image == nil then
        return
    end
    
    love.graphics.setColor(self.Color)
    love.graphics.draw(self.Image, self.Xnum * self.Size, self.Ynum * self.Size)
end

function Chunk:SetImage(image)
    self.Image = image
end

return Chunk