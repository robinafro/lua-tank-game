local Event = {}
Event.__index = Event

function Event.new()
    local self = setmetatable({}, Event)

    self._connections = {}

    return self
end

function Event:Connect(callback)
    table.insert(self._connections, callback)

    return function()
        for i, connection in ipairs(self._connections) do
            if connection == callback then
                table.remove(self._connections, i)
            end
        end
    end
end

function Event:Fire(...)
    for _, connection in ipairs(self._connections) do
        connection(...)
    end
end

return Event