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

    game.RunService:Connect("RenderStepped", function()
        if os.clock() - self.LastSorted > self.SortInterval then
            self:Sort()
            self.LastSorted = os.clock()
        end

        self:Render(game.RunService:GetDelta("RenderStepped"))
    end)
    
    return self
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
    
    return id
end

function ObjectService:Remove(id)
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
    -- local sortedRenderables = {}; do
    --     for _, renderable in pairs(self.Renderables) do
    --         table.insert(sortedRenderables, renderable)
    --     end
    -- end

    -- table.sort(sortedRenderables, function(a, b)
    --     return a.ZIndex < b.ZIndex
    -- end)
    
    if self.Camera then
        self.Camera:Render(self.SortedRenderables, dt)
    end
end

function ObjectService:SetCamera(camera)
    self.Camera = camera
end

return ObjectService