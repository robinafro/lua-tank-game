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

return Object