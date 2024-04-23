return function(a, b)
    local initialize, inherit = nil, nil

    if b then --// Parse arguments
        initialize, inherit = b, a
    else
        initialize = a
    end

    local class do
        if inherit then
            class = setmetatable({}, inherit)
        else
            class = {}
        end
    end

    class.__index = class

    initialize(class)

    local constructor = class.new

    function class.new(...)
        local self = {}

        if inherit then
            self = setmetatable(inherit.new and inherit.new(...) or inherit, class)
        else
            setmetatable(self, class)
        end

        self.__index = self

        if constructor then
            constructor(self, ...)
        end

        return self
    end

    return class
end