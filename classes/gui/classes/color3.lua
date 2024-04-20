local Color3 = {}
Color3.__index = Color3

function Color3.new(r, g, b)
    local self = setmetatable({}, Color3)
    self.r = r or 0
    self.g = g or 0
    self.b = b or 0
    return self
end

function Color3.fromRGB(r, g, b)
    return Color3.new(r / 255, g / 255, b / 255)
end

function Color3:toTable()
    return {self.r, self.g, self.b}
end

function Color3:__add(other)
    return Color3.new(self.r + other.r, self.g + other.g, self.b + other.b)
end

function Color3:__sub(other)
    return Color3.new(self.r - other.r, self.g - other.g, self.b - other.b)
end

function Color3:__mul(other)
    return Color3.new(self.r * other.r, self.g * other.g, self.b * other.b)
end

function Color3:__div(other)
    return Color3.new(self.r / other.r, self.g / other.g, self.b / other.b)
end

function Color3:__eq(other)
    return self.r == other.r and self.g == other.g and self.b == other.b
end

function Color3:__tostring()
    return "Color3: (" .. self.r .. ", " .. self.g .. ", " .. self.b .. ")"
end

return Color3