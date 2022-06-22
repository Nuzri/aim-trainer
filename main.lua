require 'target'
require 'menu-button'

function love.load()
    love.filesystem.setIdentity('aim-trainer')
	math.randomseed(os.time())

	--cursor
    local cursorImg = love.graphics.newImage('gfx/cursor.png')
    cursor = love.mouse.newCursor('gfx/cursor.png', cursorImg:getWidth() / 2, cursorImg:getHeight() / 2)

	--images
    heart = love.graphics.newImage('gfx/heart.png')

	--fonts
    LargeFont = love.graphics.newFont('fonts/Poppins-Regular.ttf', 43)
    MediumFont = love.graphics.newFont('fonts/Poppins-Regular.ttf', 30)
    SmallFont = love.graphics.newFont('fonts/Poppins-Regular.ttf', 20)

	--audios
    ScoreAudio = love.audio.newSource('sounds/score.mp3', 'static')
    MissAudio = love.audio.newSource('sounds/miss.wav', 'static')
    MisclickAudio = love .audio.newSource('sounds/misclick.mp3', 'static')
    ButtonAudio = love.audio.newSource('sounds/button-press.wav', 'static')

	--initialising variables
	w, h = love.graphics.getDimensions()
	InitLineWidth = love.graphics.getLineWidth()
	GameState = 'start'
	Score = 0
	Highscore = 0
	Lives = 3
	Miss = 0
	Try = 0
	t = math.random(0.8, 1)
	ButtonWidth = 270
	TitleY = (h / 2) - 130
	ScoreY = 0
	targetIndex = 0
	targetsEliminated = 0
	totalPlayTime = 0
	white = {1, 1, 1}
	transparent = {1, 1, 1, 0}
	orange = {1.00000000000, 0.34117647059, 0.13333333333}

	--initialise menu buttons
	startMenuButton =
	newMenuButton({'start game', 'sound', 'quit'},
	{function()
		ButtonAudio:play()
		targetIndex = 1
		target:new(targetIndex)
		initPlayTime = love.timer.getTime()
		Try = Try + 1
		GameState = 'play'
	end,
    function ()
		ButtonAudio:play()
		prevGameState = GameState
	end,
    function ()
		love.event.quit()
	end},
	'center', (h / 2) - 55, ButtonWidth, 55, 26, 12, white, transparent, orange, orange)

	GameOverMenuButton =
	newMenuButton({'play again', 'sound', 'quit'},
    {function ()
		if Score > Highscore then
			Highscore = Score
		end
		ButtonAudio:play()
    	Score = 0
		Lives = 3
		initPlayTime = love.timer.getTime()
		Miss = 0
		Try = Try + 1
		targetsEliminated = 0
		targetIndex = 1
		target:new(targetIndex)
		t = math.random(0.8, 1)
		GameState = 'play'
    end,
    function ()
		ButtonAudio:play()
		prevGameState = GameState
    end,
    function ()
    	love.event.quit()
    end},
	'center', (h / 2) - 25, ButtonWidth, 55, 26, 12, white, transparent, orange, orange)

	love.mouse.setCursor(cursor)
	love.audio.setVolume(0.8)
end

function love.update(dt)
	if GameState == 'play' then
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

local function drawHearts()
	local heartWidth = heart:getWidth()
    local heartPadding = 5

	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, Lives do
		love.graphics.draw(heart, w - (heartWidth + 10) * i + 10 - heartPadding, heartPadding)
	end
end

local function scoreboardVertical(leftColumn, rightColumn, gap, x, y, width, leftTextColor, rightTextColor)
	local fontHeight = love.graphics.getFont():getHeight()
	for i = 1, #leftColumn do
		love.graphics.setColor(leftTextColor[1], leftTextColor[2], leftTextColor[3], leftTextColor[4])
		love.graphics.print(leftColumn[i], x, y + ((i - 1) * (fontHeight +gap)))

		love.graphics.setColor(rightTextColor[1], rightTextColor[2], rightTextColor[3], rightTextColor[4])
		love.graphics.print(rightColumn[i], x + width - (love.graphics.getFont():getWidth(rightColumn[i])), y + ((i - 1) * (fontHeight + gap)))
	end
end

local function scoreboardHorizontal(left, right, gap, x, y, leftTextColor, rightTextColor)
	for i = 1, #left do
		X = 0
		for j = 1, i do
			if j ~= 1 then
				X = X + love.graphics.getFont():getWidth(left[j - 1])
			end
		end

		love.graphics.setColor(leftTextColor[1], leftTextColor[2], leftTextColor[3])
		love.graphics.print(left[i], x + X + gap * (i - 1), y)

		love.graphics.setColor(rightTextColor[1], rightTextColor[2], rightTextColor[3])
		love.graphics.print(right[i], x + X + gap * (i - 1) + love.graphics.getFont():getWidth(left[i]), y)
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.00000000000, 0.07450980392, 0.12156862745)

	if GameState == "start" then
		love.graphics.setLineWidth(InitLineWidth)

		love.graphics.setFont(LargeFont)
		local titleLen = LargeFont:getWidth('Aim Trainer')
		local x = (w / 2) - (titleLen / 2)

		love.graphics.setColor(1, 1, 1)
		love.graphics.print('Aim ', x, TitleY)
		love.graphics.setColor(1.00000000000, 0.34117647059, 0.13333333333)
		love.graphics.print('Trainer', x + LargeFont:getWidth('Aim '), TitleY)

		love.graphics.setFont(MediumFont)
		startMenuButton:draw()

	elseif GameState == "play" then
		love.graphics.setLineWidth(InitLineWidth)

		target:draw()
		drawHearts()

		playTime = string.format('%.1f', (love.timer.getTime() - initPlayTime))

		love.graphics.setFont(SmallFont)
		scoreboardHorizontal({"Hits: ", "Highscore: ", "Time: "}, {Score, Highscore, playTime.."s"}, 60, 5, 0, white, orange)

	elseif GameState == "over" then
		love.graphics.setLineWidth(InitLineWidth)

		target:draw()

		love.graphics.setColor(0.00000000000, 0.07450980392, 0.12156862745, 0.9)
		love.graphics.rectangle('fill', 0, 0, w, h)

		love.graphics.setFont(MediumFont)
		love.graphics.setColor(1.00000000000, 0.34117647059, 0.13333333333)
		love.graphics.printf('Stats:', 0, 70, w, 'center')

		love.graphics.setFont(love.graphics.newFont('fonts/Poppins-Regular.ttf', 22))
		scoreboardVertical({'Hit Targets:', 'Accuracy:', 'Avg. Time:'}, {Score.."/"..targetIndex, accuracy, avgTime}, 0, (w / 2) - ((ButtonWidth - 37) / 2), 115, ButtonWidth - 37, white, orange)

		love.graphics.setFont(SmallFont)
		scoreboardHorizontal({"Hits: ", "Highscore: ", "Time: "}, {Score, Highscore, playTime.."s"}, 60, 5, 0, white, orange)

		love.graphics.setFont(MediumFont)
		GameOverMenuButton:draw()
	end
end

function love.mousepressed(x, y, button)
	if GameState == 'play' then
		target:mousepressed(x, y, button)
	end
end

function love.keypressed(key)
	if key=="rctrl" then
		debug.debug() -- game crashes
	end
end

function distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 )
end