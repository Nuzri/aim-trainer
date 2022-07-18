require 'target'
require 'menu-button'
require 'scoreboard-h'
require 'scoreboard-v'

function love.load()
	love.filesystem.setIdentity('aim-trainer')
	math.randomseed(os.time())

	--cursor
    local cursorImg = love.graphics.newImage('gfx/cursor.png')
    cursor = love.mouse.newCursor('gfx/cursor.png', cursorImg:getWidth() / 2, cursorImg:getHeight() / 2)

	--images
    heart = love.graphics.newImage('gfx/heart.png')

	--fonts
    largeFont = love.graphics.newFont('fonts/Poppins-Regular.ttf', 43)
    mediumFont = love.graphics.newFont('fonts/Poppins-Regular.ttf', 30)
    smallFont = love.graphics.newFont('fonts/Poppins-Regular.ttf', 20)

	--audios
    scoreAudio = love.audio.newSource('sounds/score.mp3', 'static')
    missAudio = love.audio.newSource('sounds/miss.wav', 'static')
    misclickAudio = love .audio.newSource('sounds/misclick.mp3', 'static')
    buttonAudio = love.audio.newSource('sounds/button-press.wav', 'static')

	--declaring variables
	w, h = love.graphics.getDimensions()
	initLineWidth = love.graphics.getLineWidth()
	gameState = 'start'
	score = 0
	best = 0
	lives = 3
	misses = 0
	try = 0
	t = math.random(0.8, 1)
	titleContent = 'Aim Trainer'
	buttonWidth = 270
	titleY = (h / 2) - 130
	scoreY = 0
	targetIndex = 0
	targetsEliminated = 0
	totalPlayTime = 0
	white = {1, 1, 1}
	transparent = {1, 1, 1, 0}
	orange = {1.00000000000, 0.34117647059, 0.13333333333}

	--initialising menu buttons
	startMenuButton =
	newMenuButton({'start game', 'sound', 'quit'},
	{function()
		buttonAudio:play()
		targetIndex = 1
		target:new(targetIndex)
		initPlayTime = love.timer.getTime()
		try = try + 1
		gameState = 'play'
	end,
    function ()
		buttonAudio:play()
		prevGameState = gameState
	end,
    function ()
		love.event.quit()
	end},
	'center', (h / 2) - 55, buttonWidth, 55, 26, 12, white, transparent, orange, orange)

	gameOverMenuButton =
	newMenuButton({'play again', 'sound', 'quit'},
    {function ()
		if score > best then
			best = score
		end
		buttonAudio:play()
    	score = 0
		lives = 3
		initPlayTime = love.timer.getTime()
		misses = 0
		try = try + 1
		targetsEliminated = 0
		targetIndex = 1
		target:new(targetIndex)
		t = math.random(0.8, 1)
		gameState = 'play'
    end,
    function ()
		buttonAudio:play()
		prevGameState = gameState
    end,
    function ()
    	love.event.quit()
    end},
	'center', (h / 2) - 25, buttonWidth, 55, 26, 12, white, transparent, orange, orange)

	love.mouse.setCursor(cursor)
	love.audio.setVolume(0.8)
end


function love.update(dt)
	if gameState == 'play' then
		for i = 1, targetIndex do
			if target[i].state == 'active' then
				target:update(i, dt)
			end
		end
		if targetIndex - targetsEliminated < 5 then
			t = t - dt
			if t <= 0 then
				targetIndex = targetIndex + 1
				target:new(targetIndex)
				if targetIndex - targetsEliminated < 5 then
					t = math.random(0.8, 1)
				end
			end
		end
	end
end


function love.draw()
	love.graphics.setBackgroundColor(0.00000000000, 0.07450980392, 0.12156862745)

	if gameState == "start" then
		love.graphics.setLineWidth(initLineWidth)

		love.graphics.setFont(largeFont)
		local titleLen = largeFont:getWidth('Aim Trainer')
		local x = (w / 2) - (titleLen / 2)

		love.graphics.setColor(1, 1, 1)
		love.graphics.print('Aim ', x, titleY)
		love.graphics.setColor(1.00000000000, 0.34117647059, 0.13333333333)
		love.graphics.print('Trainer', x + largeFont:getWidth('Aim '), titleY)

		love.graphics.setFont(mediumFont)
		startMenuButton:draw()

	elseif gameState == "play" then
		love.graphics.setLineWidth(initLineWidth)

		target:draw()
		hearts()

		playTime = string.format('%.1f', (love.timer.getTime() - initPlayTime))

		love.graphics.setFont(smallFont)
		scoreboardH({"Hits: ", "Best: ", "Time: "}, {score, best, playTime.."s"}, 60, 5, 0, white, orange)

	elseif gameState == "over" then
		love.graphics.setLineWidth(initLineWidth)

		target:draw()

		love.graphics.setColor(0.00000000000, 0.07450980392, 0.12156862745, 0.9)
		love.graphics.rectangle('fill', 0, 0, w, h)

		love.graphics.setFont(mediumFont)
		love.graphics.setColor(1.00000000000, 0.34117647059, 0.13333333333)
		love.graphics.printf('Stats:', 0, 70, w, 'center')

		love.graphics.setFont(love.graphics.newFont('fonts/Poppins-Regular.ttf', 22))
		scoreboardV({'Hit Targets:', 'Accuracy:', 'Speed:'}, {score.."/"..targetIndex, accuracy, string.format('%.1f', targetIndex / playTime)..' t/s'}, 0, (w / 2) - ((buttonWidth - 37) / 2), 115, buttonWidth - 37, white, orange)

		love.graphics.setFont(smallFont)
		scoreboardH({"Hits: ", "Best: ", "Time: "}, {score, best, playTime.."s"}, 60, 5, 0, white, orange)

		love.graphics.setFont(mediumFont)
		gameOverMenuButton:draw()
	end
end


function love.mousepressed(x, y, button)
	if gameState == 'start' then
		startMenuButton:mousepressed(button)
	elseif gameState == 'play' then
		target:mousepressed(x, y, button)
	elseif gameState == 'over' then
		gameOverMenuButton:mousepressed(button)
	end
end


function love.keypressed(key)
	if key=="rctrl" then
		debug.debug() --game freezes
	end
end


function distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 )
end


function hearts()
	local heartWidth = heart:getWidth()
    local heartPadding = 5

	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, lives do
		love.graphics.draw(heart, w - (heartWidth + 10) * i + 10 - heartPadding, heartPadding)
	end
end