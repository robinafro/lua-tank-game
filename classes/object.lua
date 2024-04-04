--// Top class for all renderable objects

local Object = {}
Object.__index = Object

function Object.new(fnc)
    local self = setmetatable({
        X = 0,
        Y = 0,
        Width = 0,
        Height = 0,
        ZIndex = 0,
        Color = {1, 1, 1, 1},
        Function = fnc
    }, Object)

    self.__index = self

    return self
end

return Object