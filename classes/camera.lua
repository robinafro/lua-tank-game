local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)

    self.RenderDistanceScreenMultiplier = 1

    self.X = 0
    self.Y = 0
    self.RenderDistance = 0
    self.MaxTweenSpeed = 1

    self.Target = nil
    self.TargetPosition = {X = 0, Y = 0}

    return self
end

function Camera:SetPosition(x, y)
    self.X = x
    self.Y = y
end

function Camera:MoveTo(x, y)
    local goalX = x - love.graphics.getWidth() / 2
    local goalY = y - love.graphics.getHeight() / 2

    self.X = self.X + (goalX - self.X) * self.MaxTweenSpeed * love.timer.getDelta()
    self.Y = self.Y + (goalY - self.Y) * self.MaxTweenSpeed * love.timer.getDelta()
end

function Camera:Render(renderables, dt)
    self.RenderDistance = math.max(love.graphics.getWidth(), love.graphics.getHeight()) * self.RenderDistanceScreenMultiplier

    if self.Target then
        self.TargetPosition.X = self.Target.X
        self.TargetPosition.Y = self.Target.Y

        self:MoveTo(self.TargetPosition.X, self.TargetPosition.Y)
    end

    for _, renderable in ipairs(renderables) do
        local distanceFromCenter = math.min(math.abs(self.X - (renderable.X + renderable.Width / 2)), math.abs(self.Y - (renderable.Y + renderable.Height / 2)))

        if distanceFromCenter < self.RenderDistance or renderable.AlwaysVisible == true then
            love.graphics.setColor(unpack(renderable.Color or {1, 1, 1, 1}))

            love.graphics.push()

            if not renderable.HUD then
                love.graphics.translate(-self.X, -self.Y)
            end
            
            if renderable.Function and type(renderable.Function) == "function" then
                renderable.Function(dt)
            else
                love.graphics.push()
                love.graphics.translate(renderable.X + renderable.Width / 2, renderable.Y + renderable.Height / 2)
                love.graphics.rotate(math.rad(renderable.Rotation or 0))

                if renderable.Image and renderable.Image ~= "" then
                    love.graphics.draw(renderable.Image, renderable.X, renderable.Y, 0, renderable.Width / renderable.Image:getWidth(), renderable.Height / renderable.Image:getHeight())
                else
                    love.graphics.rectangle("fill", -renderable.Width / 2, -renderable.Height / 2, renderable.Width, renderable.Height)
                end

                love.graphics.pop()
            end

            love.graphics.pop()
        end
    end
end

return Camera