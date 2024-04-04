uuid = require("uuid")

ObjectService = {}
ObjectService.__index = ObjectService

function ObjectService.new()
    local self = setmetatable({}, ObjectService)

    self.Renderables = {}
    self.Camera = nil
    
    return self
end

function ObjectService:Add(renderable)
    if not renderable then return end
    if not renderable.Function and (not renderable.X or not renderable.Y or not renderable.Width or not renderable.Height) then return end
    if not renderable.ZIndex then renderable.ZIndex = 0 end
    
    local id = uuid()

    self.Renderables[id] = renderable

    return id
end

function ObjectService:Remove(id)
    if not self.Renderables[id] then return end

    self.Renderables[id] = nil
end

function ObjectService:Render(dt)
    local sortedRenderables = {}; do
        for _, renderable in pairs(self.Renderables) do
            table.insert(sortedRenderables, renderable)
        end
    end

    table.sort(sortedRenderables, function(a, b)
        return a.ZIndex < b.ZIndex
    end)
    
    if self.Camera then
        self.Camera:Render(sortedRenderables, dt)
    end
end

function ObjectService:SetCamera(camera)
    self.Camera = camera
end

return ObjectService