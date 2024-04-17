function graphics()
    love.window.setFullscreen(true)
end

function LoadModules(game)
    local runningModules = {}

    local modules = love.filesystem.getDirectoryItems("modules")

    for _, module in ipairs(modules) do
        local moduleName = module:sub(1, -5) -- remove the file extension (.lua)
        local module = require("modules." .. moduleName)

        if module["init"] ~= nil then
            local co = coroutine.create(function()
                local success, error = pcall(function()
                    module.init(game)
                end)
                
                if not success then
                    print(error)
                end
            end)

            table.insert(runningModules, module)

            coroutine.resume(co)
        end
    end

    return runningModules
end

function love.load(args)
    math.randomseed(os.time())

    graphics()
    
    local runservice = require("runservice")
    local objectservice = require("objectservice")

    local game = {
        RunService = nil,
        ObjectService = nil,
        Paths = nil
    }

    RunService = runservice.new()
    RunService:SetDelta()

    game.RunService = RunService

    ObjectService = objectservice.new(game)

    game.ObjectService = ObjectService

    local debug = false
    for _, arg in ipairs(args) do
        if arg == "--debug" then
            debug = true
        end
    end

    --// Set up path hierarchy
    local paths = {Debug = debug} --// This same table will be passed to all modules, so that they can interact by writing/reading objects.

    game.Paths = paths

    --// Load modules
    local runningModules = LoadModules(game)

    function love.keypressed(key)
        if key == "escape" then
            love.event.quit()
        elseif key == "r" then
            RunService:Trigger("Restart")

            RunService:Reset()
            ObjectService:Reset()

            game.Paths = {Debug = debug}

            for _, module in ipairs(runningModules) do
                local co = coroutine.create(function()
                    local success, error = pcall(function()
                        module.init(game)
                    end)
                    
                    if not success then
                        print(error)
                    end
                end)

                coroutine.resume(co)
            end
        end
    end
end

function love.draw()
    local success, err = pcall(function()
        RunService:Trigger("RenderStepped")
    end)

    if not success then
        print(err)
    end
end

function love.update(dt)
    local success, err = pcall(function()
        RunService:Trigger("Stepped")

        RunService:Trigger("Heartbeat")
    end)
end