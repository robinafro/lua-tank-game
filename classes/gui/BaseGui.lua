-- local Classes = {
--     Frame = require("classes/gui/Frame"),
--     TextLabel = require("classes/gui/TextLabel"),
--     ImageLabel = require("classes/gui/ImageLabel"),
-- }

local BaseGui = {}
BaseGui.__index = BaseGui

function BaseGui.new()
    local self = setmetatable({}, BaseGui)

    self.children = {}
    self.Visible = true

    return self
end

function BaseGui:Insert(child)
    -- if type(child) == "string" then
    --     child = Classes[child].new()
    -- end

    child.parent = self
    table.insert(self.children, child)

    return child
end

function BaseGui:IsVisible()
    return self.Visible
end

return BaseGui