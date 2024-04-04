Controller = require("classes.controller")

local Player = setmetatable({}, Controller)
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)

    self.Camera = nil

    return self
end

function Player:SetCamera(cam)
    self.Camera = cam
end

function Player:Update(dt)
    local x = (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0)
    local z = (love.keyboard.isDown("w") and 1 or 0) - (love.keyboard.isDown("s") and 1 or 0)

    self.Controlling:Move(z, x)
    self.Controlling:Update(dt)
end

return Player