function love.load()
    math.randomseed(os.time())
    
    local runservice = require("runservice")
    local objectservice = require("objectservice")

    RunService = runservice.new()
    RunService:SetDelta()

    ObjectService = objectservice.new()

    --// Set up path hierarchy
    local paths = {} --// This same table will be passed to all modules, so that they can interact by writing/reading objects.

    --// Load modules
    local modules = love.filesystem.getDirectoryItems("modules")

    for _, module in ipairs(modules) do
        local moduleName = module:sub(1, -5) -- remove the file extension (.lua)
        local module = require("modules." .. moduleName)

        if module["init"] ~= nil then
            local co = coroutine.create(function()
                local success, error = pcall(function()
                    module.init({RunService = RunService, ObjectService = ObjectService, Paths = paths})
                end)
                
                if not success then
                    print(error)
                end
            end)

            coroutine.resume(co)
        end
    end
end

function love.draw()
    RunService:Trigger("RenderStepped")

    ObjectService:Render(RunService:GetDelta("RenderStepped"))
end

function love.update(dt)
    -- trigger network event in the future
    RunService:Trigger("Stepped")

    --// Do something here

    RunService:Trigger("Heartbeat")
end