local screen = require("screen")
local gameState = require("gameState")
local grid = require("grid")

function love.load()
  screen.load()
  grid.load()
end

function love.update()
  grid.update()
end

function love.draw()
  grid.draw()
end

function love.keypressed(key)
  grid.keypressed(key)
end

function love.mousepressed(x, y, button)
  grid.mousepressed(x, y, button)
end
