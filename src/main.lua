push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WWIDTH = 1280
WHEIGHT = 720

VWIDTH = 432
VHEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    gameVersion = 'desktop' -- 'mobile' or 'desktop'

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Moon Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['boop'] = love.audio.newSource('sfx/boop.wav', 'static'),
        ['score'] = love.audio.newSource('sfx/score.wav', 'static'),
        ['wallBoop'] = love.audio.newSource('sfx/wallBoop.wav', 'static')
    }

    push:setupScreen(VWIDTH, VHEIGHT, WWIDTH, WHEIGHT, {
        fullscreen = true,
        resizable = true,
        vsync = true
    })

    p1Score = 0
    p2Score = 0

    servingPlayer = 1

    if gameVersion == 'desktop' then
        p1 = Paddle(10, 30, 5, 20)  
        p2 = Paddle(VWIDTH - 10, VHEIGHT - 30, 5, 20)
    elseif gameVersion == 'mobile' then
        p1 = Paddle(50, 30, 5, 20)  
        p2 = Paddle(VWIDTH - 50, VHEIGHT - 30, 5, 20)
    end
    ball = Ball(VWIDTH / 2 - 2, VHEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
    gameMode = 'none'
end

function love.update(dt)
    if gameState == 'serve' then
        serveBall()
    elseif gameState == 'play' then
        detectPlayerCollision()
        detectWallBounce()
        detectScore()
    end

    detectPlayerMovement()

    if gameState == 'play' then
        ball:update(dt)
    end

    p1:update(dt)
    p2:update(dt)
end

function love.resize(w, h)
    push:resize(w, h)
end

function detectPlayerCollision()
    if ball:collides(p1) then
        ball.dx = -ball.dx * 1.03
        ball.x = p1.x + 5

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        sounds['boop']:play()
    end
    if ball:collides(p2) then
        ball.dx = -ball.dx * 1.03
        ball.x = p2.x - 4

        if ball.dy < 0 then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10, 150)
        end

        sounds['boop']:play()
    end
end

function detectWallBounce()
    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy
        sounds['wallBoop']:play()
    end

    if ball.y >= VHEIGHT - 4 then
        ball.y = VHEIGHT - 4
        ball.dy = -ball.dy
        sounds['wallBoop']:play()
    end
end

function detectScore()
    if ball.x < 0 then
        servingPlayer = 1
        p2Score = p2Score + 1
        sounds['score']:play()

        if p2Score == 10 then
            winningPlayer = 2
            gameState = 'done'
        else
            gameState = 'serve'
            ball:reset()
        end
    end

    if ball.x > VWIDTH then
        servingPlayer = 2
        p1Score = p1Score + 1
        sounds['score']:play()
        
        if p1Score == 10 then
            winningPlayer = 1
            gameState = 'done'
        else
            gameState = 'serve'
            ball:reset()
        end
    end
end

function serveBall()
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
        ball.dx = math.random(140, 200)
    else
        ball.dx = -math.random(140, 200)
    end
end

function detectPlayerMovement()
    if gameVersion == 'desktop' then
        if love.keyboard.isDown('w') then
            p1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            p1.dy = PADDLE_SPEED
        else
            p1.dy = 0
        end

        if gameMode == 'ai' then
            p2.y = ball.y
        else
            if love.keyboard.isDown('up') then
                p2.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('down') then
                p2.dy = PADDLE_SPEED
            else
                p2.dy = 0
            end
        end
    elseif gameVersion == 'mobile' then
        local touches = love.touch.getTouches()
 
        for i, id in ipairs(touches) do
            local wx, wy = love.touch.getPosition(id)
            local vx, vy = push:toGame(wx, wy)
            if vx ~= nil and vx < VWIDTH / 2 then
                p1.y = vy
            else 
                p2.y = vy
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == '1' then
        if gameState == 'start' then
            gameState = 'serve'
            gameMode = 'multiplayer'
        end
    elseif key == '2' then
        if gameState == 'start' then
            gameState = 'serve'
            gameMode = 'ai'
        end
    elseif key == 'enter' or key == 'return' then
        if gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            p1Score = 0
            p2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.touchpressed( id, x, y, dx, dy, pressure )
    if gameState == 'start' then
        gameState = 'serve'
    elseif gameState == 'serve' then
        gameState = 'play'
    elseif gameState == 'done' then
        gameState = 'serve'

        ball:reset()

        p1Score = 0
        p2Score = 0

        if winningPlayer == 1 then
            servingPlayer = 2
        else
            servingPlayer = 1
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40, 45, 52, 0,0)
    love.graphics.setFont(smallFont)

    displayScore()
    displayMessages()

    p1:render()
    p2:render()
    ball:render()

    push:apply('end')
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(p1Score), VWIDTH / 2 - 50, 
        VHEIGHT / 3)
    love.graphics.print(tostring(p2Score), VWIDTH / 2 + 30,
        VHEIGHT / 3)
end

function displayMessages()
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Moong Pong!', 0, 10, VWIDTH, 'center')
        love.graphics.printf('Press 1 for multiplayer', 0, 20, VWIDTH, 'center')
        love.graphics.printf('Press 2 for AI', 0, 30, VWIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VWIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VWIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VWIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VWIDTH, 'center')
    end
end