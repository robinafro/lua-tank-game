--[[
    This module is responsible for defining the paths that the game will use.
    It will also define the events that will be used by the game.
    This module will be used to initialize the paths and events.
    This module will be used by the game module.

    Not all modules will use the paths and events, but they will be available for those who need them.
]]

local Event = require("classes.event")

return {init = function(game)
    game.Paths.Events = {
        PlayerDied = Event.new(),
    }
end}