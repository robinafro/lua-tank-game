Object = require("classes.object")
Collider = require("classes.collider")

Bullet = setmetatable({}, Object)
Bullet.__index = Bullet

function Bullet.new(x, y, rot, game)
    local self = setmetatable(Object.new(), Bullet)

    self.Game = game
    self.Object = nil
    self.Active = false

    self.X = x
    self.Y = y
    self.Rotation = rot
    self.Width = 25
    self.Height = 8
    self.Force = 1
    self.Damage = 0
    self.Whitelist = {}
    self.ZIndex = 3
    self.AlwaysVisible = true

    self.Image = love.graphics.newImage("assets/objects/bullet.png")

    self.Collider = Collider.new(self.Game.Paths, self)
    self.Collider.CanCollide = false
    self.Collider.CollisionName = "bullet"
    self.Collider.CollisionFilterType = "Exclude"
    self.Collider.CollisionFilter = {"localplayer", "bullet"}
    self.Collider.CollisionFunction = function(selfCollider, other)
        for _, v in ipairs(self.Whitelist) do
            if other.CollisionName == v then
                other.Object:TakeDamage(self.Damage)
            end
        end

        self:Destroy()
    end

    return self
end

function Bullet:Fire()
    self.Active = true
    self.Function = function(dt)
        self:Update(dt)
        self:Render()
    end
end

function Bullet:Update(dt)
    self.X = self.X + math.cos(self.Rotation) * self.Force * dt
    self.Y = self.Y + math.sin(self.Rotation) * self.Force * dt
end

function Bullet:Render()
    love.graphics.push()
    love.graphics.translate(self.X, self.Y)
    love.graphics.rotate(self.Rotation)
    love.graphics.setColor(1, 200 / 255, 100 / 255)
    love.graphics.draw(self.Image, -self.Width / 2, -self.Height / 2, 0, self.Width / self.Image:getWidth(), self.Height / self.Image:getHeight())
    love.graphics.pop()
end

function Bullet:Destroy()
    self.Active = false
    
    self.Collider:Destroy()
    self.Game.ObjectService:Remove(self.id)
end

return Bullet