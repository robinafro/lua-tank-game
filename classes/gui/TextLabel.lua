local BaseFrame = require("classes/gui/BaseFrame")
local BaseButton = require("classes/gui/BaseButton")

local Vector2 = require("classes/vector2")
local Color3 = require("classes/color3")

local TextLabel = setmetatable({}, BaseFrame)
TextLabel.__index = function(table, key)
    return TextLabel[key] or table.Button[key]
end

function TextLabel.new()
    local self = setmetatable({}, TextLabel)

    self.Visible = true

    self.position = Vector2.new(0, 0)
    self.size = Vector2.new(0, 0)
    self.anchorPoint = Vector2.new(0, 0)

    self.backgroundColor3 = Color3.new(1, 1, 1)
    self.backgroundTransparency = 0

    self.text = ""
    self.font = ""
    self.textColor3 = Color3.new(0, 0, 0)
    self.textTransparency = 0
    self.textSize = 12
    self.textFont = love.graphics.newFont(self.textSize)
    self.textAlign = "center"
    self.textVerticalAlign = "center"

    self.Frame = BaseFrame.new()
    self.Button = BaseButton.new()

    return self
end

function TextLabel:SetFont(size, font)
    self.textSize = size or 12

    if font then
        self.textFont = love.graphics.newFont(font, size)
        self.font = font
    else
        self.textFont = love.graphics.newFont(size)
    end
end

function TextLabel:Render()
    if not self:IsVisible() then
        return
    end

    self.Frame.position = self.position
    self.Frame.size = self.size
    self.Frame.anchorPoint = self.anchorPoint
    self.Frame.color = self.backgroundColor3
    self.Frame.parent = self.parent

    local absPos, absSize = self.Frame:Render()

    self.Button:Check(absPos, absSize)

    love.graphics.setColor(self.backgroundColor3.r, self.backgroundColor3.g, self.backgroundColor3.b, 1 - self.backgroundTransparency)
    love.graphics.rectangle("fill", absPos.x, absPos.y, absSize.x, absSize.y)

    love.graphics.setColor(self.textColor3.r, self.textColor3.g, self.textColor3.b, 1 - self.textTransparency)
    love.graphics.setFont(self.textFont)

    local fontHeight = self.textFont:getHeight()
    local fontWidth = self.textFont:getWidth(self.text)

    local x, y = absPos.x, absPos.y

    if self.textVerticalAlign == "center" then
        y = y + (absSize.y - fontHeight) / 2
    elseif self.textVerticalAlign == "bottom" then
        y = y + absSize.y - fontHeight
    end

    love.graphics.printf(self.text, x, y, absSize.x, self.textAlign)
end

return TextLabel
