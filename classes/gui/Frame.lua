local BaseFrame = require("classes/gui/BaseFrame")

local Frame = setmetatable({}, BaseFrame)
Frame.__index = Frame

function Frame.new()
    local self = setmetatable(BaseFrame.new(), Frame)

    self.Visible = true

    return self
end

return Frame