local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)

    self.X = 0
    self.Y = 0
    self.FOV = 90

    return self
end

function Camera:MoveTo(x, y)
    self.X = x
    self.Y = y
end

function Camera:Render(renderables, dt)
    for _, renderable in ipairs(renderables) do
        love.graphics.setColor(unpack(renderable.Color or {1, 1, 1, 1}))

        love.graphics.push()
        love.graphics.translate(-self.X, -self.Y)

        if renderable.Function then
            renderable.Function(dt)
        else
            if renderable.Image then
                love.graphics.draw(renderable.Image, renderable.X, renderable.Y, 0, renderable.Width / renderable.Image:getWidth(), renderable.Height / renderable.Image:getHeight())
            else
                love.graphics.rectangle("fill", renderable.X, renderable.Y, renderable.Width, renderable.Height)
            end
        end

        love.graphics.pop()
    end
end

return Camera