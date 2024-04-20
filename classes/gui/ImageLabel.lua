local BaseFrame = require("BaseFrame")

local Vector2 = require("classes/vector2")
local Color3 = require("classes/color3")

local ImageLabel = setmetatable({}, BaseFrame)
ImageLabel.__index = ImageLabel

function ImageLabel.new()
    local self = setmetatable({}, ImageLabel)

    self.position = Vector2.new(0, 0)
    self.size = Vector2.new(0, 0)
    self.anchorPoint = Vector2.new(0, 0)

    self.backgroundColor3 = Color3.new(1, 1, 1)
    self.backgroundTransparency = 0

    self.image = nil
    self.scaleType = "stretch"
    self.imageRectOffset = Vector2.new(0, 0)
    self.imageRectSize = Vector2.new(0, 0)
    self.imageColor3 = Color3.new(1, 1, 1)
    self.imageTransparency = 0

    self.Frame = BaseFrame.new()

    self.scaleX, self.scaleY = 1, 1
    self.offsetX, self.offsetY = 0, 0
    self.prevImage = nil
    self.prevScaleType = nil
    self.prevSize = nil

    return self
end

function ImageLabel:ComputeScale(size)
    if self.prevImage == self.image and self.scaleType == self.prevScaleType and size == self.prevSize then
        return
    end

    local function sign(x)
        return x > 0 and 1 or x < 0 and -1 or 0
    end

    self.prevImage = self.image
    self.prevScaleType = self.scaleType
    self.prevSize = size

    if self.scaleType == "stretch" then
        self.scaleX = size.x / self.image:getWidth()
        self.scaleY = size.y / self.image:getHeight()
        self.offsetX = 0
        self.offsetY = 0
    elseif self.scaleType == "fit" then
        local ratio = math.abs(size.x / size.y)

        self.scaleX = math.min(size.x / self.image:getWidth(), size.y / self.image:getHeight())
        self.scaleY = self.scaleX

        self.offsetX = math.max(1, ratio) * self.image:getWidth() / 2 - self.image:getWidth() / 2
        self.offsetY = math.max(1, 1 / ratio) * self.image:getHeight() / 2 - self.image:getHeight() / 2
    end
end

function ImageLabel:Render()
    if self.size.x < 0 then
        self.size = Vector2.new(0, self.size.y)
    end

    if self.size.y < 0 then
        self.size = Vector2.new(self.size.x, 0)
    end

    self.Frame.parent = self.parent

    self.Frame.position = self.position
    self.Frame.size = self.size
    self.Frame.anchorPoint = self.anchorPoint
    self.Frame.color = self.backgroundColor3
    self.Frame.transparency = self.backgroundTransparency

    local pos, size = self.Frame:Render()

    self:ComputeScale(size)

    love.graphics.setColor(self.imageColor3.r, self.imageColor3.g, self.imageColor3.b, 1 - self.imageTransparency)
    love.graphics.draw(self.image, pos.x, pos.y, 0, self.scaleX, self.scaleY, self.imageRectOffset.x - self.offsetX, self.imageRectOffset.y - self.offsetY)
end

return ImageLabel