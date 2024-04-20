local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    local self = setmetatable({}, Vector2)
    self.x = x or 0
    self.y = y or 0
    return self
end

function Vector2:toTable()
    return {self.x, self.y}
end

function Vector2.__add(self, other)
    return Vector2.new(self.x + other.x, self.y + other.y)
end

function Vector2.__sub(self, other)
    return Vector2.new(self.x - other.x, self.y - other.y)
end

function Vector2.__mul(self, other)
    if type(other) == "number" then
        return Vector2.new(self.x * other, self.y * other)
    else
        return Vector2.new(self.x * other.x, self.y * other.y)
    end
end

function Vector2.__div(self, other)
    return Vector2.new(self.x / other.x, self.y / other.y)
end

function Vector2.__eq(self, other)
    return self.x == other.x and self.y == other.y
end

function Vector2.__tostring(self)
    return "Vector2: (" .. self.x .. ", " .. self.y .. ")"
end

return Vector2