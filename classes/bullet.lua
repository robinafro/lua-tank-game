Object = require("classes.object")
Collider = require("classes.collider")

Bullet = setmetatable({}, Object)
Bullet.__index = Bullet

function Bullet.new(x, y, rot, game)
    local self = setmetatable(Object.new(), Bullet)

    self.Game = game

    self.X = x
    self.Y = y
    self.Rotation = rot
    self.Width = 25
    self.Height = 8
    self.Force = 1
    self.ZIndex = 3
    self.AlwaysVisible = true

    self.Collider = Collider.new(self.Game.Paths, self)
    self.Collider.CanCollide = false
    self.Collider.CollisionName = "bullet"
    self.Collider.CollisionFilterType = "Exclude"
    self.Collider.CollisionFilter = {"localplayer", "bullet"}
    self.Collider.CollisionFunction = function(selfCollider, other)
        if other.CollisionName == "enemyplayer" then
            other:TakeDamage(10)
        end

        self:Destroy()
    end

    return self
end

function Bullet:Fire()
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
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", -self.Width / 2, -self.Height / 2, self.Width, self.Height)
    love.graphics.pop()
end

function Bullet:Destroy()
    for i, v in pairs(self.Game) do print(i, v) end
    self.Collider:Destroy()
    self.Game.ObjectService:Remove(self.id)
end

return Bullet