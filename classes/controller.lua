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
    controlling.Controller = self

    return function(dt)
        self:Update(dt)
    end
end

function Controller:Update(dt)
    print("Controller:Update() is a placeholder function. The class that inherits from Controller should override this function.")
end

function Controller:Destroy()
    if self.OnDestroy then
        self:OnDestroy()
    end
    
    for i, v in pairs(self) do
        if i ~= "Controlling" then
            self[i] = nil
        end
    end

    self.Controlling.Controller = nil
    self.Controlling:Destroy()
    self.Controlling = nil
end

return Controller