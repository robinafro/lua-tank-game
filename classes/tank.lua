Object = require("classes.object")
Bullet = require("classes.bullet")

local Tank = setmetatable({}, Object)
Tank.__index = Tank

function _clamp(val, min, max)
    if val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end

function _sign(val)
    if val < 0 then
        return -1
    elseif val > 0 then
        return 1
    else
        return 0
    end
end

--[[
    Some info about tank mechanics

    - Tank has a subtle acceleration/decceleration to both forward and rotation speeds
    - When shooting, tank has a recoil effect that affects both forward and rotation speeds
    - The recoil effect is proportional to the bullet force
    - The rotation of the recoil effect is random, but is greatly reduced when the tank is moving backwards
]]

function Tank.new(game)
    local self = setmetatable(Object.new(), Tank)

    self.Game = game

    self.ForwSpeed = 150
    self.RotSpeed = 2
    self.ForwAccel = self.ForwSpeed * 10
    self.RotAccel = self.RotSpeed * 10
    self.RotDeccel = self.RotSpeed * 5
    self.ForwDeccel = self.ForwSpeed * 2
    self.ForwVelocity = 0
    self.RotVelocity = 0

    self.Width = 35
    self.Height = 50

    self.Input = {
        Z = 0,
        X = 0
    }

    self.MinSortInterval = 0.2
    self.DefaultBulletForce = 3000
    self.RecoilMultiplier = 0.07
    self.RecoilRotationMultiplier = 5
    self.LastShot = 0
    self.Firerate = 2
    self.Ammo = 1000000000000
    self.BulletForce = self.DefaultBulletForce

    self.Health = 100
    
    self.Function = function(dt)
        self:Render()
    end

    self.Controller = nil

    self.ZIndex = 100

    self:SetImage("assets/tanks/tank"..math.random(1, 4)..".png")
    
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
    self.RotVelocity = _clamp(self.RotVelocity + self.Input.X * self.RotAccel * dt - math.min(self.RotDeccel * dt * _sign(self.RotVelocity), math.abs(self.RotSpeed)), -self.RotSpeed, self.RotSpeed)
    self.ForwVelocity = _clamp(self.ForwVelocity + self.Input.Z * self.ForwAccel * dt - math.min(self.ForwDeccel * dt * _sign(self.ForwVelocity), math.abs(self.ForwSpeed)), -self.ForwSpeed, self.ForwSpeed)
    self.Rotation = self.Rotation + self.RotVelocity * dt
    
    self.X = self.X + math.cos(self.Rotation) * self.ForwVelocity * dt
    self.Y = self.Y + math.sin(self.Rotation) * self.ForwVelocity * dt
end

function Tank:Shoot(enemies, friendlies)
    local time = love.timer.getTime()
    if self.Ammo > 0 and time - self.LastShot > 1 / self.Firerate then
        self.Ammo = self.Ammo - 1
        self.LastShot = time
       
        local bullet = Bullet.new(self.X + self.Width / 2, self.Y + self.Height / 2, self.Rotation, self.Game)

        bullet.Force = self.BulletForce
        bullet.Damage = 100
        bullet.Whitelist = enemies
        bullet.Blacklist = friendlies
        bullet.Controller = self.Controller

        bullet:Fire()

        self.Game.ObjectService:Add(bullet)
        -- self.Game.ObjectService:Sort()

        self.RotVelocity = self.RotVelocity + bullet.Force * self.RecoilRotationMultiplier * (math.random() - 0.5) * 2 * math.max(-self.ForwSpeed / 1000000, self.ForwVelocity / self.ForwSpeed)
        self.ForwVelocity = self.ForwVelocity - bullet.Force * self.RecoilMultiplier

        if self.Ammo == 0 then
            self.BulletForce = self.DefaultBulletForce
        end

        if self.OnFired then
            self.OnFired(bullet)
        end
    end
end

function Tank:TakeDamage(dmg)
    self.Health = self.Health - dmg

    if self.Health <= 0 and self.OnDeath then
        self.OnDeath()
    end
end

function Tank:Destroy()
    if self.ID == nil then return end

    self.Game.ObjectService:Remove(self)

    if self.Controller then
        self.Controller:Destroy()
    end

    for i, v in pairs(self) do
        self[i] = nil
    end
end

function Tank:Move(z, x)
    self.Input.Z = z
    self.Input.X = x
end

return Tank