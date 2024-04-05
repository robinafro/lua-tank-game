Object = require("classes.object")

local Tank = setmetatable({}, Object)
Tank.__index = Tank

function Tank.new()
    local self = setmetatable(Object.new(), Tank)

    self.ForwSpeed = 150
    self.RotSpeed = 2
    self.ForwVelocity = 0
    self.RotVelocity = 0

    self.Width = 35
    self.Height = 50

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
    love.graphics.translate(self.X + self.Width / 2, self.Y + self.Height / 2)
    love.graphics.rotate(self.Rotation)

    if self.Image ~= "" and self.Image ~= nil then
        love.graphics.draw(self.Image, -self.Height / 2, -self.Width / 2, 0, self.Height / self.Image:getWidth(), self.Width / self.Image:getHeight())
    else
        love.graphics.setColor(self.Color)
        love.graphics.rectangle("fill", -self.Height / 2, -self.Width / 2, self.Height, self.Width)
    end
    
    love.graphics.pop()
end

function Tank:Update(dt)
    self.RotVelocity = self.Input.X * self.RotSpeed
    self.ForwVelocity = self.Input.Z * self.ForwSpeed
    self.Rotation = self.Rotation + self.RotVelocity * dt

    self.X = self.X + math.cos(self.Rotation) * self.ForwVelocity * dt
    self.Y = self.Y + math.sin(self.Rotation) * self.ForwVelocity * dt
end

function Tank:Move(z, x)
    self.Input.Z = z
    self.Input.X = x
end

return Tank