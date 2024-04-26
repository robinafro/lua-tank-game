Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)

    self.connections = {}

    return self
end

function Signal:send(key, ...)
    if not self.connections[key] then
        return
    end

    self.connections[key].callback(...)
end

function Signal:connect(key, callback)
    local connection = {
        callback = callback,
    }

    self.connections[key] = connection

    return connection
end

function Signal:disconnect(connection)
    for i, v in pairs(self.connections) do
        if v == connection then
            table.remove(self.connections, i)
            break
        end
    end
end

return Signal