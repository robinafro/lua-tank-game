local Frame = require "Frame"
local ImageLabel = require "ImageLabel"
local TextLabel = require "TextLabel"

local ScreenGui = require "test_ScreenGui"
local Vector2 = require "classes/vector2"
local Color3 = require "classes/color3"

local frames = {}

local horizontal, vertical = 0, 0

function love.load()
    screenGui = ScreenGui.new()

    local prev = screenGui
    for i = 1, 1 do
        local frame = Frame.new()
        frame.anchorPoint = Vector2.new(0.5, 0.5)
        frame.position = Vector2.new(0.5,0.5)
        frame.size = Vector2.new(0.95, 0.95)
        frame.color = Color3.new(math.random(), math.random(), math.random())

        -- prev:Insert(frame)
        prev = frame

        table.insert(frames, frame)
    end

    imageLabel = ImageLabel.new()
    imageLabel.anchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.position = Vector2.new(0.5, 0.5)
    imageLabel.size = Vector2.new(0.5, 0.1)
    imageLabel.backgroundColor3 = Color3.new(1, 0, 1)
    imageLabel.backgroundTransparency = 1

    imageLabel.image = love.graphics.newImage("roblox.png")
    imageLabel.scaleType = "fit"

    -- screenGui:Insert(imageLabel)

    textLabel = TextLabel.new()
    textLabel.anchorPoint = Vector2.new(0.5, 0.5)
    textLabel.position = Vector2.new(0.5, 0.5)
    textLabel.size = Vector2.new(0.5, 0.1)
    textLabel.backgroundColor3 = Color3.new(1, 0, 1)
    textLabel.backgroundTransparency = 0
    textLabel.text = "Hello, World!"
    textLabel:SetFont(24)

    screenGui:Insert(textLabel)
end

function love.update(dt)
    horizontal = love.keyboard.isDown("d") and 1 or love.keyboard.isDown("a") and -1 or 0
    vertical = love.keyboard.isDown("s") and 1 or love.keyboard.isDown("w") and -1 or 0

    local spd = 1 * dt

    -- for i, frame in pairs(frames) do
    --     frame.position = frame.position + Vector2.new(horizontal * spd, vertical * spd)
    -- end

    textLabel.size = textLabel.size + Vector2.new(horizontal * spd, vertical * spd)
end

function love.draw()
    screenGui:Render()

    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, love.graphics.getHeight() - 20)
end