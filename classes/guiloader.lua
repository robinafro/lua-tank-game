local Classes = {
    Frame = require("classes/gui/Frame"),
    TextLabel = require("classes/gui/TextLabel"),
    ImageLabel = require("classes/gui/ImageLabel"),
}

local GuiLoader = {}
GuiLoader.__index = GuiLoader

function GuiLoader.new(game, name, type)
    local self = setmetatable({}, GuiLoader)

    self.Game = game
    self.Name = name
    self.Gui = require("classes/gui/"..(type or "ScreenGui")).new(game)

    if not game.Paths.UIs then
        game.Paths.UIs = {}
    end

    if name then
        if not game.Paths.UIs[name] then
            game.Paths.UIs[name] = {}
        end

        table.insert(game.Paths.UIs[name], self.Gui)
    end

    return self
end

function GuiLoader:Insert(className, gui)
    if type(className) == "string" then
        className = Classes[className].new()
    end

    (gui or self.Gui):Insert(className)

    return className
end

function GuiLoader:Destroy()
    if self.Name then
        local index = table.find(self.Game.Paths.UIs[self.Name], self.Gui)

        if index then
            table.remove(self.Game.Paths.UIs[self.Name], index)
        end
    end

    self.Game.ObjectService:Remove(self.Gui.connection)

    self.Gui.Visible = false
    self.Gui.children = {}

    self.Gui.Object:Destroy()
end

return GuiLoader