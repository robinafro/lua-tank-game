local Classes = {
    Frame = require("classes/gui/Frame"),
    TextLabel = require("classes/gui/TextLabel"),
    ImageLabel = require("classes/gui/ImageLabel"),
}

local GuiLoader = {}
GuiLoader.__index = GuiLoader

function GuiLoader.new(game, name)
    local self = setmetatable({}, GuiLoader)

    self.Game = game
    self.ScreenGui = require("classes/gui/ScreenGui").new(game)

    if not game.Paths.UIs then
        game.Paths.UIs = {}
    end

    if name then
        game.Paths.UIs[name] = self.ScreenGui
    end

    return self
end

function GuiLoader:Insert(className, gui)
    if type(className) == "string" then
        className = Classes[className].new()
    end

    (gui or self.ScreenGui):Insert(className)

    return className
end

return GuiLoader