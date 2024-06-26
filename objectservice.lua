uuid = require("uuid")

ObjectService = {}
ObjectService.__index = ObjectService

function ObjectService.new(game)
    local self = setmetatable({}, ObjectService)

    self.Game = game
    self.Renderables = {}
    self.SortedRenderables = {}
    self.LastSorted = 0
    self.SortInterval = 1
    self.Camera = nil

    self:SetRenderConnection()

    return self
end

function ObjectService:SetRenderConnection()
    self.RenderConnection = self.Game.RunService:Connect("RenderStepped", function()
        if os.time() - self.LastSorted > self.SortInterval then
            self:Sort()
            self.LastSorted = os.time()
        end

        self:Render(self.Game.RunService:GetDelta("RenderStepped"))
    end)
end

function ObjectService:Reset()
    self.Renderables = {}
    self.SortedRenderables = {}
    self.LastSorted = 0
    self.SortInterval = 1
    self.Camera = nil

    self:SetRenderConnection()
end

function ObjectService:Sort()
    table.sort(self.SortedRenderables, function(a, b)
        return a.ZIndex < b.ZIndex
    end)
end

function ObjectService:Add(renderable, sort)
    if not renderable then return end
    if not renderable.Function and (not renderable.X or not renderable.Y or not renderable.Width or not renderable.Height) then return end
    if not renderable.ZIndex then renderable.ZIndex = 0 end

    local id = uuid()

    renderable.ID = id

    self.Renderables[id] = renderable
    table.insert(self.SortedRenderables, renderable)

    if sort then
        self:Sort()
    end

    if not self.Game.Paths.Renderables then
        self.Game.Paths.Renderables = self.Renderables
    end

    return id
end

function ObjectService:Remove(id)
    if type(id) == "table" then
        id = id.ID
    end

    if not self.Renderables[id] then return end
    
    for i, renderable in ipairs(self.SortedRenderables) do
        if renderable.ID == id then
            table.remove(self.SortedRenderables, i)
            break
        end
    end

    self.Renderables[id] = nil
    
    self:Sort()
end

function ObjectService:Render(dt)    
    if self.Camera then
        self.Camera:Render(self.SortedRenderables, dt)
    end
end

function ObjectService:SetCamera(camera)
    self.Camera = camera
end

return ObjectService