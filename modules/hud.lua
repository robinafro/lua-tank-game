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

local lastShownUI = 0
function Upgrades(game)
    local guiLoader = GuiLoader.new(game, "Upgrades")

    local text = guiLoader:Insert("TextLabel")
    text.position = Vector2.new(0.5, 0.3)
    text.size = Vector2.new(0.4, 0.15)
    text.anchorPoint = Vector2.new(0.5, 0.5)
    text.text = "Upgraded tank: UpgradeName"
    text:SetFont(48, "assets/fonts/Pixeboy.ttf")
    text.backgroundTransparency = 1
    text.textColor3 = Color3.new(1,1,1)
    text.Visible = false

    game.Signal:connect("playerUpgraded", function(upgrade)
        text.text = "Upgraded tank: "..upgrade
        text.Visible = true

        lastShownUI = love.timer.getTime()

        coroutine.wrap(function()
            game.RunService:Wait(2)

            if love.timer.getTime() - lastShownUI < 2 then
                return
            end

            text.Visible = false
        end)()
    end)
end

function Wave(game)
    local guiLoader = GuiLoader.new(game, "Upgrades")

    local text = guiLoader:Insert("TextLabel")
    text.position = Vector2.new(0.01, 0.0125)
    text.size = Vector2.new(0.4, 0.15)
    text.anchorPoint = Vector2.new(0, 0)
    text.text = "WAVE: 0"
    text.textAlign = "left"
    text.textVerticalAlign = "top"
    text:SetFont(36, "assets/fonts/Pixeboy.ttf")
    text.backgroundTransparency = 1
    text.textColor3 = Color3.new(1,1,1)

    game.Signal:connect("waveChanged", function(wave)
        text.text = "WAVE: "..wave
    end)
end

function AmmoAndFirerate(game)
    local guiLoader = GuiLoader.new(game, "AmmoAndFirerate")

    local text = guiLoader:Insert("TextLabel")
    text.position = Vector2.new(0.99, 0.99)
    text.size = Vector2.new(0.15, 0.1)
    text.anchorPoint = Vector2.new(1, 1)
    text.text = "Ammo: " .. game.Paths.LocalPlayer.Controlling.Ammo
    text.textAlign = "right"
    text.textVerticalAlign = "bottom"
    text:SetFont(24, "assets/fonts/Pixeboy.ttf")
    text.backgroundTransparency = 1
    text.textColor3 = Color3.new(1,1,1)

    game.Paths.LocalPlayer.Controlling.AmmoChanged:Connect(function(ammo)
        text.text = "Ammo: "..ammo
    end)

    local guiLoaderBillboard = GuiLoader.new(game, "Upgrades", "BillboardGui")
    guiLoaderBillboard.Gui.size = Vector2.new(90, 15)
    guiLoaderBillboard.Gui.adornee = game.Paths.LocalPlayer.Controlling
    guiLoaderBillboard.Gui.offset = Vector2.new(game.Paths.LocalPlayer.Controlling.Width / 2, game.Paths.LocalPlayer.Controlling.Height + 10)

    local background = guiLoaderBillboard:Insert("Frame")
    background.size = Vector2.new(1,1)
    background.position = Vector2.new(0.5, 0.5)
    background.anchorPoint = Vector2.new(0.5, 0.5)
    background.color = Color3.new(0,0,0)

    local container = guiLoaderBillboard:Insert("Frame", background)
    container.size = Vector2.new(0.88, 0.45)
    container.position = Vector2.new(0.5, 0.5)
    container.anchorPoint = Vector2.new(0.5, 0.5)
    container.color = Color3.new(0.1,0.1,0.1)

    local firerateBar = guiLoaderBillboard:Insert("Frame", container)
    firerateBar.size = Vector2.new(0.5, 1)
    firerateBar.color = Color3.new(0.8, 0.8, 0.8)

    game.RunService:Connect("RenderStepped", function()
        local ratio = (love.timer.getTime() - game.Paths.LocalPlayer.Controlling.LastShot) / (1 / game.Paths.LocalPlayer.Controlling.Firerate)
        
        firerateBar.size = Vector2.new(math.max(math.min(ratio, 1), 0), 1)
    end)
end

return {init = function(game)
    local guiLoader = GuiLoader.new(game, "Healthbars")

    while not game.Paths.LocalPlayer do
        game.RunService:Wait()
    end

    Upgrades(game)
    AmmoAndFirerate(game)
    Wave(game)

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

        local loader = GuiLoader.new(game, "Healthbars", "BillboardGui")
        loader.Gui.size = Vector2.new(90, 15)
        loader.Gui.offset = Vector2.new(enemy.Controlling.Width / 2, -10)
        loader.Gui.adornee = enemy.Controlling

        table.insert(updateFunctions, HealthBillboard(loader, enemy))
    end

    game.Signal:connect("enemySpawned", addEnemy)

    for _, enemy in ipairs(game.Paths.Enemies) do
        addEnemy(enemy.Enemy)
    end
end}