--// Top class for all renderable objects

local Object = {}
Object.__index = Object

function Object.new(fnc)
    local self = setmetatable({
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        Rotation = 0,
        ZIndex = 0,
        Color = {1, 1, 1, 1},
        Function = fnc,
        HUD = false,
        AlwaysVisible = false,
        Image = ""
    }, Object)

    self.__index = self

    return self
end

function Object:SetImage(image)
    self.Image = love.graphics.newImage(image)
end

function Object:GetBoundingBox()
    return self.X, self.Y, self.Width, self.Height
end

function Object:CollidesWith(x, y, width, height, objectAddX, objectAddY)
    local x1, y1, w1, h1 = self:GetBoundingBox()
    local x2, y2, w2, h2 = x, y, width, height

    x1, y1, w1, h1 = x1 - (objectAddX or 0) / 2, y1 - (objectAddY or 0) / 2, w1 + (objectAddX or 0), h1 + (objectAddY or 0)

    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

return Object