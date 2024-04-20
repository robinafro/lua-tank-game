local BaseFrame = require("BaseFrame")

local Frame = setmetatable({}, BaseFrame)
Frame.__index = Frame

function Frame.new()
    local self = setmetatable(BaseFrame.new(), Frame)

    return self
end

return Frame