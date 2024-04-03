function love.load()
    local runservice = require("runservice")

    RunService = runservice.new()
    RunService:SetDelta()

    --// Load modules
    local modules = love.filesystem.getDirectoryItems("modules")

    for _, module in ipairs(modules) do
        local moduleName = module:sub(1, -5) -- remove the file extension (.lua)
        local module = require("modules." .. moduleName)

        if module.init then
            module.init({RunService = RunService})
        end
    end
end

function love.draw()
    RunService:Trigger("RenderStepped")
end

function love.update(dt)
    RunService:Trigger("Stepped")

    --// Do something here

    RunService:Trigger("Heartbeat")
end