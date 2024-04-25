Controller = require("classes.controller")

local Player = setmetatable({}, Controller)
Player.__index = Player

local function _sign(n)
    if n < 0 then return -1 elseif n == 0 then return 0 else return 1 end
end

function Player.new(game)
    local self = setmetatable({}, Player)

    self.Camera = nil
    self.Game = game

    self.Score = 0
    self.GainScorePerKill = 100
    self.GainScorePerWave = 1000

    self.AimAssistEnabled = true
    self.AimAssistCorrectionAngleThreshold = 25
    self.AimAssistShootAngleThreshold = 3
    self.AimAssistSpacePress = 0.1

    return self
end

function Player:SetCamera(cam)
    self.Camera = cam
end

function Player:Update(dt)
    local spaceDown = love.keyboard.isDown("space")

    local x = (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0)
    local z = (love.keyboard.isDown("w") and 1 or 0) - (love.keyboard.isDown("s") and 1 or 0)

    self.Controlling:Move(z, x)

    if spaceDown then
        if self.AimAssistEnabled then
            local closestAngle, closestMagnitude, closest = math.huge, math.huge, nil; do
                for _, enemy in pairs(self.Game.Paths.Enemies or {}) do
                    local enemyX, enemyY = enemy.Tank.X, enemy.Tank.Y
                    local selfX, selfY = self.Controlling.X, self.Controlling.Y

                    local angle = math.deg(math.atan2(enemyY - selfY, enemyX - selfX) - self.Controlling.Rotation)
                    local mappedAngle = math.abs(angle) % 180 * _sign(angle)

                    local magnitude = math.abs(math.min(enemyX - selfX, enemyY - selfY))

                    if math.abs(mappedAngle) < closestAngle and magnitude < closestMagnitude then
                        closestAngle = mappedAngle
                        closestMagnitude = magnitude
                        closest = enemy
                    end
                end
            end

            if math.abs(closestAngle) < self.AimAssistCorrectionAngleThreshold then
                self.Controlling:Move(z, closestAngle)
            end
        end
        
        self.Controlling:Shoot({"enemyplayer"}, {"localplayer"})
    end

    self.Controlling:Update(dt)
end

return Player