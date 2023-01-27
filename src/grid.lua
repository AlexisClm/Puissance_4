local screen = require("screen")
local gameState = require("gameState")

local class = {}
local data = {}
local images = {}
local mouse = {}
local cell = {}
local nbLines
local nbColumns
local offsetX
local offsetY
local player
local backgroundImg
local gridImg
local font

local function getX(column)
  return offsetX + (column-1) * cell.w
end

local function getY(line)
  return offsetY + (line-1) * cell.h
end

local function getColumn(x)
  return math.floor((x - offsetX)/cell.w) + 1
end

local function getLine(y)
  return math.floor((y - offsetY)/cell.h) + 1
end

local function getLastFreeLine(column)
  for line = nbLines, 1, -1 do
    if (data[line][column] == 0) then
      return line
    end
  end
  return 0
end

local function loadImages()
  images.background = love.graphics.newImage("Assets/Images/Background.jpg")
  images.grid       = love.graphics.newImage("Assets/Images/Grid.png")
end

local function initSettings()
  gridImg       = images.grid
  backgroundImg = images.background
  font          = love.graphics.newFont("Assets/Font/Puissance 4.ttf", 50)
  offsetX       = 50
  offsetY       = 150
  cell.w        = 100
  cell.h        = 100
  mouse.x       = -cell.w
  mouse.y       = -cell.h
  nbLines       = 6
  nbColumns     = 7
  player        = 1
end

local function initGrid()
  for line = 1, nbLines do
    data[line] = {}
    for column = 1, nbColumns do
      data[line][column] = 0
    end
  end
end

local function cellIsAvailable(line, column)
  if (line < 1) or (line > nbLines) or (column < 1) or (column > nbColumns) then
    return false
  else
    return true
  end
end

local function updateMouse()
  local x      = love.mouse.getX()
  local y      = love.mouse.getY()
  local column = getColumn(x)
  local line   = getLastFreeLine(column)

  mouse.x2 = getColumn(x) * cell.w + offsetX - cell.w/2
  mouse.y2 = getLastFreeLine(column) * cell.h + offsetY - cell.h/2

  if cellIsAvailable(line, column) then
    mouse.x = mouse.x2
    mouse.y = mouse.y2
  end
end

local function drawBackground()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(backgroundImg)
end

local function drawGrid()
  for line = 1, nbLines do
    for column = 1, nbColumns do
      if (gameState.getState() == "game") then
        if (data[line][column] == 0) then
          love.graphics.setColor(1, 1, 1, 0)
        elseif (data[line][column] == 1) then
          love.graphics.setColor(1, 1, 0)
        elseif (data[line][column] == 2) then
          love.graphics.setColor(1, 0, 0)
        end
      elseif (gameState.getState() == "player1Win") then
        if (data[line][column] == 0) then
          love.graphics.setColor(1, 1, 1, 0)
        elseif (data[line][column] == 1) then
          love.graphics.setColor(1, 1, 0)
        elseif (data[line][column] == 2) then
          love.graphics.setColor(1, 0, 0, 0.5)
        end
      elseif (gameState.getState() == "player2Win") then
        if (data[line][column] == 0) then
          love.graphics.setColor(1, 1, 1, 0)
        elseif (data[line][column] == 1) then
          love.graphics.setColor(1, 1, 0, 0.5)
        elseif (data[line][column] == 2) then
          love.graphics.setColor(1, 0, 0)
        end
      end
      local x = getX(column)
      local y = getY(line)
      love.graphics.rectangle('fill', x+1, y+1, cell.w, cell.h)
    end
  end
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(gridImg)
end

local function drawCellPreShot()
  if (gameState.getState() == "game") then
    if (player == 1) then
      love.graphics.setColor(1, 1, 0, 0.7)
    elseif (player == 2) then
      love.graphics.setColor(1, 0, 0, 0.7)
    end
    love.graphics.circle("fill", mouse.x, mouse.y, (cell.w-2)/2)
  end
end

local function drawHUD()
  love.graphics.setFont(font)
  if (gameState.getState() == "game") then
    if (player == 1) then
      love.graphics.setColor(1, 1, 0)
      love.graphics.printf("Player "..player, 0, 50, screen.getWidth()/2, "center")
      love.graphics.setColor(1, 0, 0, 0.5)
      love.graphics.printf("Player "..player+1, screen.getWidth()/2, 50, screen.getWidth()/2, "center")

    elseif (player == 2) then
      love.graphics.setColor(1, 1, 0, 0.5)
      love.graphics.printf("Player "..player-1, 0, 50, screen.getWidth()/2, "center")
      love.graphics.setColor(1, 0, 0)
      love.graphics.printf("Player "..player, screen.getWidth()/2, 50, screen.getWidth()/2, "center")
    end

  elseif (gameState.getState() == "player1Win") then
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("Player 1   WIN !", 0, 50, screen.getWidth(), "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press <n> to restart", 0, screen.getHeight() - 55, screen.getWidth(), "center")

  elseif (gameState.getState() == "player2Win") then
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("Player 2   WIN !", 0, 50, screen.getWidth(), "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press <n> to restart", 0, screen.getHeight() - 55, screen.getWidth(), "center")
  end
end

local function checkHorizontalAlignement(line, column)
  local nbAligne    = 1
  local checkColumn = column - 1

  while (cellIsAvailable(line, checkColumn)) and (data[line][checkColumn] == player) do
    nbAligne    = nbAligne + 1
    checkColumn = checkColumn - 1
  end

  checkColumn = column + 1
  while (cellIsAvailable(line, checkColumn)) and (data[line][checkColumn] == player) do
    nbAligne    = nbAligne + 1
    checkColumn = checkColumn + 1
  end

  if (nbAligne >= 4) then
    if (player == 1) then
      gameState.setState("player1Win")
    else
      gameState.setState("player2Win")
    end
  end
end

local function checkVerticalAlignement(line, column)
  local nbAligne  = 1
  local checkLine = line + 1

  while (cellIsAvailable(checkLine, column)) and (data[checkLine][column] == player) do
    nbAligne  = nbAligne + 1
    checkLine = checkLine + 1
  end

  if (nbAligne >= 4) then
    if (player == 1) then
      gameState.setState("player1Win")
    else
      gameState.setState("player2Win")
    end
  end
end

local function checkLeftDiagonalAlignement(line, column)
  local nbAligne    = 1
  local checkLine   = line + 1
  local checkColumn = column + 1

  while (cellIsAvailable(checkLine, checkColumn)) and (data[checkLine][checkColumn] == player) do
    nbAligne = nbAligne + 1
    checkLine = checkLine + 1
    checkColumn = checkColumn + 1
  end

  checkLine   = line - 1
  checkColumn = column - 1
  while (cellIsAvailable(checkLine, checkColumn)) and (data[checkLine][checkColumn] == player) do
    nbAligne    = nbAligne + 1
    checkLine   = checkLine - 1
    checkColumn = checkColumn - 1
  end

  if (nbAligne >= 4) then
    if (player == 1) then
      gameState.setState("player1Win")
    else
      gameState.setState("player2Win")
    end
  end
end

local function checkRightDiagonalAlignement(line, column)
  local nbAligne    = 1
  local checkLine   = line - 1
  local checkColumn = column + 1

  while (cellIsAvailable(checkLine, checkColumn)) and (data[checkLine][checkColumn] == player) do
    nbAligne    = nbAligne + 1
    checkLine   = checkLine - 1
    checkColumn = checkColumn + 1
  end

  checkLine   = line + 1
  checkColumn = column - 1
  while (cellIsAvailable(checkLine, checkColumn)) and (data[checkLine][checkColumn] == player) do
    nbAligne    = nbAligne + 1
    checkLine   = checkLine + 1
    checkColumn = checkColumn - 1
  end

  if (nbAligne >= 4) then
    if (player == 1) then
      gameState.setState("player1Win")
    else
      gameState.setState("player2Win")
    end
  end
end

function class.load()
  gameState.setState("game")
  loadImages()
  initSettings()
  initGrid()
end

function class.update()
  updateMouse()
end

function class.draw()
  drawBackground()
  drawCellPreShot()
  drawGrid()
  drawHUD()
end

function class.keypressed(key)
  if (key == 'n') then
    gameState.setState("game")
    initSettings()
    initGrid()
  elseif (key == "escape") then
    love.event.quit()
  end
end

function class.mousepressed(x, y, button)
  if (gameState.getState() == "game") then
    if (button == 1) then
      local column = getColumn(x)
      local line = getLastFreeLine(column)
      if (cellIsAvailable(line, column)) then
        data[line][column] = player

        checkHorizontalAlignement(line, column)
        checkVerticalAlignement(line, column)
        checkLeftDiagonalAlignement(line, column)
        checkRightDiagonalAlignement(line, column)

        if (player == 1) then
          player = 2
        elseif (player == 2) then
          player = 1
        end
      end
    end
  end
end

return class