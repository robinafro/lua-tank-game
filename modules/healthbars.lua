local GuiLoader = require("classes/guiloader")
local Vector2 = require("classes/vector2")
local Color3  = require("classes/color3")

function HealthHUD(guiLoader, adornee)
    local background = guiLoader:Insert("Frame")
    background.size = Vector2.new(0.8, 0.02)
    background.position = Vector2.new(0.5, 0.99)
    background.anchorPoint = Vector2.new(0.5, 1)
    background.color = Color3.new(0,0,0)

    local container = guiLoader:Insert("Frame", background)
    container.size = Vector2.new(0.992, 0.45)
    container.position = Vector2.new(0.5, 0.5)
    container.anchorPoint = Vector2.new(0.5, 0.5)
    container.color = Color3.new(0.1,0.1,0.1)

    local healthBar = guiLoader:Insert("Frame", container)
    healthBar.size = Vector2.new(0.5, 1)
    healthBar.color = Color3.new(1,0,0)

    return function(health, maxHealth)
        local ratio = adornee.Controlling.Health/adornee.Controlling.MaxHealth
        
        healthBar.size = Vector2.new(ratio, 1)
        healthBar.color = Color3.new(1 - ratio, ratio, 0)
    end
end

function HealthBillboard(guiLoader, adornee)
    local background = guiLoader:Insert("Frame")
    background.size = Vector2.new(1,1)
    background.position = Vector2.new(0.5, 0.5)
    background.anchorPoint = Vector2.new(0.5, 0.5)
    background.color = Color3.new(0,0,0)

    local container = guiLoader:Insert("Frame", background)
    container.size = Vector2.new(0.88, 0.45)
    container.position = Vector2.new(0.5, 0.5)
    container.anchorPoint = Vector2.new(0.5, 0.5)
    container.color = Color3.new(0.1,0.1,0.1)

    local healthBar = guiLoader:Insert("Frame", container)
    healthBar.size = Vector2.new(0.5, 1)
    healthBar.color = Color3.new(1,0,0)

    return function()
        if not adornee or not adornee.Controlling then
            return true
        end

        local ratio = adornee.Controlling.Health/adornee.Controlling.MaxHealth
        
        healthBar.size = Vector2.new(ratio, 1)
        healthBar.color = Color3.new(1 - ratio, ratio, 0)

        if ratio == 0 then
            guiLoader:Destroy()

            return true
        end
    end
end

return {init = function(game)
    local guiLoader = GuiLoader.new(game, "Healthbars")

    while not game.Paths.LocalPlayer do
        game.RunService:Wait()
    end

    local updateFunctions = {}

    table.insert(updateFunctions, HealthHUD(guiLoader, game.Paths.LocalPlayer))

    game.RunService:Connect("Heartbeat", function()
        for i, update in ipairs(updateFunctions) do
            local destroy = update()

            if destroy then
                table.remove(updateFunctions, i)
            end
        end
    end)

    local function addEnemy(enemy)
        while not enemy.Controlling do
            game.RunService:Wait()
        end

        local loader = GuiLoader.new(game, nil, "BillboardGui")
        loader.Gui.size = Vector2.new(90, 15)
        loader.Gui.adornee = enemy.Controlling

        table.insert(updateFunctions, HealthBillboard(loader, enemy))
    end

    game.Signal:connect("enemySpawned", addEnemy)

    for _, enemy in ipairs(game.Paths.Enemies) do
        addEnemy(enemy.Enemy)
    end
end}