local BaseGui = {}
BaseGui.__index = BaseGui

function BaseGui.new()
    local self = setmetatable({}, BaseGui)

    self.children = {}

    return self
end

function BaseGui:Insert(child)
    child.parent = self
    table.insert(self.children, child)
end

return BaseGui