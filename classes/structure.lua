Object = require("classes.object")
Collider = require("classes.collider")

Structure = {}
Structure.__index = Structure

Structure.Templates = {
    Box = {
        {
            X = 0,
            Y = 0,
            Width = 10,
            Height = 2,
        },
        {
            X = 0,
            Y = 0,
            Width = 2,
            Height = 10,
        },
        {
            X = 10,
            Y = 0,
            Width = 2,
            Height = 12,
        },
    },

    Ruin = {
        {X = -20, Y = 10, Width = 30, Height = 2},
        {X = -5, Y = 15, Width = 26, Height = 2},
        {X = -23, Y = 15, Width = 9, Height = 2},
        {X = -14, Y = 15, Width = 2, Height = 17},
        {X = -5, Y = 15, Width = 2, Height = 15},
        {X = 10, Y = 0, Width = 2, Height = 12},
        {X = 19, Y = 0, Width = 2, Height = 15},
        {X = -10, Y = 5, Width = 5, Height = 2},
        {X = -8, Y = 20, Width = 3, Height = 2},
        -- {X = 5, Y = 10, Width = 2, Height = 8},
    }
    
}

Structure.ImageCache = {}

function Structure.new(game, template, position)
    local self = setmetatable({}, Structure)

    self.Position = position or {X = 0, Y = 0}
    self.Objects = {}
    self.CellSize = 20 * (0.9 + math.random() * 0.4)
    self.DefaultColor = {0.2, 0.2, 0.2, 1}
    self.DefaultZIndex = 5
    self.Game = game
    self.Template = template
    self.ChunkSize = game.Paths.ChunkSize or 300

    return self
end

function Structure:Generate()
    self:Destroy()

    for _, object in ipairs(Structure.Templates[self.Template]) do
        local obj = Object.new()
        obj.X = object.X * self.CellSize + self.Position.X * self.ChunkSize
        obj.Y = object.Y * self.CellSize + self.Position.Y * self.ChunkSize
        obj.Width = object.Width * self.CellSize
        obj.Height = object.Height * self.CellSize
        obj.Color = object.Color or self.DefaultColor
        obj.ZIndex = object.ZIndex or self.DefaultZIndex
        obj.RaycastName = "structure"

        local img = object.Image or "assets/textures/rock.png"

        -- obj:SetImage(img)

        if img then
            coroutine.wrap(function()
                if not Structure.ImageCache[img] then
                    -- Structure.ImageCache[img] = love.graphics.newImage(img)
                end

                -- obj.Image = Structure.ImageCache[img]
            end)()
        end
        
        local collider = Collider.new(self.Game.Paths)
        collider.Static = true
        collider.CanTouch = true
        collider.Object = obj
        collider.CollisionName = "structure"
        collider.CollisionFilterType = "Exclude"
        collider.CollisionFilter = {"structure"}

        local id = self.Game.ObjectService:Add(obj)
        self.Objects[id] = {Object = obj, Collider = collider}
    end
end

function Structure:Destroy()
    for id, object in pairs(self.Objects) do
        game.ObjectService:Remove(id)
        object.Collider:Destroy()

        self.Objects[id] = nil
    end
end

function Structure.ChooseRandom()
    local keys = {}

    for key, _ in pairs(Structure.Templates) do
        table.insert(keys, key)
    end

    return keys[math.random(1, #keys)]
end

return Structure