--// Top level class for controlling objects.

local Controller = {}
Controller.__index = Controller

function Controller.new()
    local self = setmetatable({}, Controller)

    self.Controlling = nil

    return self
end

function Controller:Control(controlling)
    self.Controlling = controlling

    return function(dt)
        self:Update(dt)
    end
end

function Controller:Update()
    print("Controller:Update() is a placeholder function. The class that inherits from Controller should override this function.")
end

return Controller