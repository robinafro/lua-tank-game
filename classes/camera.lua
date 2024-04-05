local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)

    self.RenderDistanceScreenMultiplier = 1.5

    self.X = 0
    self.Y = 0
    self.RenderDistance = 0
    self.MaxTweenSpeed = 2
    self.Target = nil

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
        self:MoveTo(self.Target.X, self.Target.Y)
    end

    for _, renderable in ipairs(renderables) do
        local distanceFromCenter = math.sqrt(math.abs(renderable.X - (self.X + love.graphics.getWidth() / 2)) ^ 2 + math.abs(renderable.Y - (self.Y + love.graphics.getHeight() / 2)) ^ 2)

        if distanceFromCenter < self.RenderDistance or renderable.AlwaysVisible == true then
            love.graphics.setColor(unpack(renderable.Color or {1, 1, 1, 1}))

            love.graphics.push()
            love.graphics.translate(-self.X, -self.Y)

            if renderable.Function then
                renderable.Function(dt)
            else    
                if renderable.Image and renderable.Image ~= "" then
                    love.graphics.draw(renderable.Image, renderable.X, renderable.Y, 0, renderable.Width / renderable.Image:getWidth(), renderable.Height / renderable.Image:getHeight())
                else
                    love.graphics.rectangle("fill", renderable.X, renderable.Y, renderable.Width, renderable.Height)
                end
            end

            love.graphics.pop()
        end
    end
end

return Camera