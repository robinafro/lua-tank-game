Object = require("classes.object")

local Tank = setmetatable({}, Object)
Tank.__index = Tank

function Tank.new()
    local self = setmetatable(Object.new(), Tank)

    self.ForwSpeed = 150
    self.RotSpeed = 2
    self.ForwVelocity = 0
    self.RotVelocity = 0
    self.Direction = 0

    self.Width = 35
    self.Length = 50

    self.Input = {
        Z = 0,
        X = 0
    }
    
    self.Function = function(dt)
        self:Render()
    end

    self.Controller = nil

    self.ZIndex = 100
    
    return self
end

function Tank:Render()
    love.graphics.push()
    love.graphics.translate(self.X, self.Y)
    love.graphics.rotate(self.Direction)

    if self.Image ~= "" and self.Image ~= nil then
        love.graphics.draw(self.Image, -self.Length / 2, -self.Width / 2, 0, self.Length / self.Image:getWidth(), self.Width / self.Image:getHeight())
    else
        love.graphics.setColor(self.Color)
        love.graphics.rectangle("fill", -self.Length / 2, -self.Width / 2, self.Length, self.Width)
    end
    
    love.graphics.pop()
end

function Tank:Update(dt)
    self.RotVelocity = self.Input.X * self.RotSpeed
    self.ForwVelocity = self.Input.Z * self.ForwSpeed
    self.Direction = self.Direction + self.RotVelocity * dt

    self.X = self.X + math.cos(self.Direction) * self.ForwVelocity * dt
    self.Y = self.Y + math.sin(self.Direction) * self.ForwVelocity * dt
end

function Tank:Move(z, x)
    self.Input.Z = z
    self.Input.X = x
end

return Tank