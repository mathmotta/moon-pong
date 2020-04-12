push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.conf(t)
 	t.console = true
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Moon Pong')

    math.randomseed(os.time())

    scoreFont = love.graphics.newFont('font.ttf', 32)

    fpsFont = love.graphics.newFont('font.ttf', 8)

    love.graphics.setFont(scoreFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })



    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'

    
end

function love.update(dt)
    if gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.02
            ball.x = player1.x + 5

            
             if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
             else
                ball.dy = mathews.random(10, 150)
             end
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.02
            ball.x = player2.x - 4

             if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
             else
                ball.dy = mathews.random(10, 150)
             end
        end
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end
    end

    if love.keyboard.isDown("w") then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown("up") then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
    
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40, 45, 52, 0, 0)

    if gameState == 'start' then
        love.graphics.printf('Start', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Play', 0, 20, VIRTUAL_WIDTH, 'center')
    end

    player1:render()
    player2:render()
    ball:render()

    --displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(fpsFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'

            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2

            ballDX = math.random(2) == 1 and 100 or -100
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end