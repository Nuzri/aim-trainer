target = {}

local maxRad = 30
local speed = 15

function target:new(n)
	self[n] = {}
	self[n].radInc = true
	self[n].rad = 1
	self[n].state = 'active'
	self[n].x = math.random(maxRad, w - maxRad)
	self[n].y = math.random(maxRad + scoreY + love.graphics.getFont():getHeight(), h - maxRad)
end

function target:draw()
	for i = 1, targetIndex do
		if target[i].state == 'active' then
			love.graphics.setColor(1, 1, 1)
			love.graphics.circle("fill", self[i].x, self[i].y, self[i].rad)
			love.graphics.circle("line", self[i].x, self[i].y, self[i].rad)

			love.graphics.setColor(1.00000000000, 0.34117647059, 0.13333333333)
			love.graphics.circle("fill", self[i].x, self[i].y, self[i].rad - (0.8 / 4) * self[i].rad)
			love.graphics.circle("line", self[i].x, self[i].y, self[i].rad - (0.8 / 4) * self[i].rad)

			love.graphics.setColor(1, 1, 1)
			love.graphics.circle("fill", self[i].x, self[i].y, self[i].rad - (1.8 / 4) * self[i].rad)
			love.graphics.circle("line", self[i].x, self[i].y, self[i].rad - (1.8 / 4) * self[i].rad)

			love.graphics.setColor(1.00000000000, 0.34117647059, 0.13333333333)
			love.graphics.circle("fill", self[i].x, self[i].y, self[i].rad - (2.8 / 4) * self[i].rad)
			love.graphics.circle("line", self[i].x, self[i].y, self[i].rad - (2.8 / 4) * self[i].rad)
		end
	end
end


function target:update(m, dt)
	if self[m].radInc == true then
        self[m].rad = self[m].rad + speed * dt
	elseif self[m].radInc == false then
        self[m].rad = self[m].rad - speed * dt
	end

	if self[m].rad >= maxRad then
		self[m].radInc = false
	end

	if self[m].rad <= 0 then
		self[m].state = 'eliminated'
		targetsEliminated = targetsEliminated + 1
		missAudio:play()
		lives = lives - 1

		if lives ~= 0 then
			targetIndex = targetIndex + 1
			target:new(targetIndex)
		else
			--[[totalPlayTime = totalPlayTime + playTime
			avgTime = try == 1 and 'N|A' or string.format('%.1f', totalPlayTime / try)..'s']]
			accuracy = ((score == 0) and (misses == 0)) and '--' or string.format('%.1f', (score / (score + misses)) * 100)..'%'
			gameState = 'over'
		end
	end
end


function target:mousepressed(x, y, button)
	targetDetected = false

	if gameState == 'play' and button == 1 then
		for i = targetIndex, 1, -1 do
			if self[i].state == 'active' and targetDetected == false then
				local mouse_to_target = distance(x, y, self[i].x, self[i].y)
				if mouse_to_target <= self[i].rad then
					score = score + 1
					scoreAudio:play()
					targetDetected = true
					targetIndex = targetIndex + 1
					target:new(targetIndex)
					self[i].state = 'eliminated'
					targetsEliminated = targetsEliminated + 1
				end
			end
			if i == 1 and targetDetected == false then
				misclickAudio:play()
				misses = misses + 1
			end
		end
	end
end