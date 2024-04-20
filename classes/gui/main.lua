local Frame = require "Frame"
local ScreenGui = require "test_ScreenGui"
local Vector2 = require "classes/vector2"
local Color3 = require "classes/color3"

local frames = {}

local horizontal, vertical = 0, 0

function love.load()
    screenGui = ScreenGui.new()

    local prev = screenGui
    for i = 1, 200 do
        local frame = Frame.new()
        frame.anchorPoint = Vector2.new(0.5, 0.5)
        frame.position = Vector2.new(0.5,0.5)
        frame.size = Vector2.new(0.95, 0.95)
        frame.color = Color3.new(math.random(), math.random(), math.random())

        prev:Insert(frame)
        prev = frame

        table.insert(frames, frame)
    end
end

function love.update(dt)
    horizontal = love.keyboard.isDown("d") and 1 or love.keyboard.isDown("a") and -1 or 0
    vertical = love.keyboard.isDown("s") and 1 or love.keyboard.isDown("w") and -1 or 0

    local spd = 0.01 * dt

    for i, frame in pairs(frames) do
        frame.position = frame.position + Vector2.new(horizontal * spd, vertical * spd)
    end
end

function love.draw()
    screenGui:Render()

    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, love.graphics.getHeight() - 20)
end