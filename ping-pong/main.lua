-- Importing necessary libraries
push = require 'push'
class = require 'class'
require 'Paddle'
require 'Ball'

-- Global constant variables
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200
WINNINGSCORE = 10

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.window.setTitle('Ping-Pong baby')
	math.randomseed(os.time())
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, 
	{
		fullscreen = false,
		resizable = true,
		vsync = true,
		canvas = false
	})

	smallFont = love.graphics.newFont('font.ttf', 8)
	largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)

	sounds = 
	{
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static')
	}

	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)
	ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)
	servingPlayer = 1
	winner = 0
	gamestate = 'start'
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.update(dt)
	if gamestate == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif gamestate == 'play' then
		if ball:collides(player1) then
			sounds['paddle_hit']:play()
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5
			verticalBounce()
		elseif ball:collides(player2) then
			sounds['paddle_hit']:play()
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4
			verticalBounce()
		end

		if ball.y <= 0 then
			sounds['wall_hit']:play()
			ball.y = 0
			ball.dy = -ball.dy
		elseif ball.y + ball.height >= VIRTUAL_HEIGHT then
			sounds['wall_hit']:play()
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
		end

		if ball.x < -3 then
			sounds['score']:play()
			player2.score = player2.score + 1
			servingPlayer = 2
			-- This is not best practice
			if player2.score == WINNINGSCORE then
				winner = 2
				gamestate = 'done'
			else
				ball:reset()
				gamestate = 'serve'
			end
		elseif ball.x + ball.width > VIRTUAL_WIDTH + 3 then
			sounds['score']:play()
			player1.score = player1.score + 1
			servingPlayer = 1
			-- This is not best practice
			if player1.score == WINNINGSCORE then
				winner = 1
				gamestate = 'done'
			else
				ball:reset()
				gamestate = 'serve'
			end
		end
	end

	-- Can this be improved??
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	player1:update(dt)
	player2:update(dt)
	if(gamestate == 'play') then
		ball:update(dt)
	end
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif	key == 'enter' or key == 'return' then
		if gamestate == 'start' then
			gamestate = 'serve'
		elseif gamestate == 'serve' then
			gamestate = 'play'
		elseif gamestate == 'done' then
			gamestate = 'serve'
			ball:reset()
			player1.score = 0
			player2.score = 0
			if winner == 1 then
				servingPlayer = 1
			else 
				servingPlayer = 2
			end
		end
	end
end

function love.draw()
	push:start()

	love.graphics.clear(40, 45, 52, 255)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(smallFont)

	if gamestate == 'start' then
		love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'done' then
    	love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winner) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
	end

	displayScore()

	player1:render()
	player2:render()
	ball:render()

	displayFPS()

	push:finish()
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1.score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2.score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function displayFPS()
	love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function verticalBounce()
	if ball.dy < 0 then
		ball.dy = -math.random(10, 150)
	else
		ball.dy = math.random(10, 150)
	end
end