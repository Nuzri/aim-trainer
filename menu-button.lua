--issue: repeated button click detection

local function distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 )
end

local menuButton = {}
menuButton.__index = menuButton

function newMenuButton(contents, actions, x, y, width, height, borderRadius, gap, textColor, fillColor, lineColor, hoverColor)
	local b = {}
	b.contents = contents
	b.actions = actions
	b.x = x
	b.y = y
	b.width = width
	b.height = height
	b.borderRadius = borderRadius
	b.gap = gap
	b.textColor = textColor
	b.fillColor = fillColor
	b.lineColor = lineColor
	b.hoverColor = hoverColor

	local yTable = {}
	b.yTable = yTable

	b.fillColor[4] = b.fillColor[4] == nil and 1 or b.fillColor[4]
	b.hoverColor[4] = b.hoverColor[4] == nil and 1 or b.hoverColor[4]
	b.lineColor[4] = b.lineColor[4] == nil and 1 or b.lineColor[4]
	b.textColor[4] = b.textColor[4] == nil and 1 or b.textColor[4]

	local w = love.graphics.getWidth()
	b.x = b.x == 'center' and ((w / 2) - (b.width / 2)) or b.x
	b.borderRadius = b.borderRadius > (b.height / 2) and (b.height / 2) or b.borderRadius

	b.counter = 1

	return setmetatable(b, menuButton)
end

function menuButton:draw()
	local fontHeight = love.graphics.getFont():getHeight()
	local lineWidth = love.graphics.getLineWidth()
	local x, y = love.mouse.getPosition()

	if self.counter == 1 then
		self.gap = self.gap + lineWidth
		for i = 1, #self.contents do
			self.yTable[i] = self.y + (i - 1) * (self.height + self.gap)
		end
		self.counter = self.counter + 1
	end

	for i = 1, #self.contents do
	    local textWidth = love.graphics.getFont():getWidth(self.contents[i])

		love.graphics.setColor(self.fillColor[1], self.fillColor[2], self.fillColor[3], self.fillColor[4])
		love.graphics.rectangle('fill', self.x, self.y + (i - 1) * ( self.height + self.gap), self.width,  self.height, self.borderRadius, self.borderRadius)

		for k = 1, #self.contents do

			if y >= self.yTable[k] - (lineWidth / 2) and y <= self.yTable[k] + self.height + (lineWidth / 2) and x >= self.x - (lineWidth / 2) and x <= self.x + self.width + (lineWidth / 2) then

				if x <= self.x + self.borderRadius then
					if y <= self.yTable[k] + self.borderRadius then
						mouseToButton = distance(x, y, self.x + self.borderRadius, self.yTable[k] + self.borderRadius)
						if mouseToButton <= self.borderRadius + (lineWidth / 2) then
				            mouseOver(self.x, self.y, self.width, self.height, self.borderRadius, self.gap, self.hoverColor, i, k)
							mouseClick(self.actions, k)
						end
					elseif y >= self.yTable[k] + self.height - self.borderRadius then
						mouseToButton = distance(x, y, self.x + self.borderRadius, self.yTable[k] + self.height - self.borderRadius)
						if mouseToButton <= self.borderRadius + (lineWidth / 2) then
				            mouseOver(self.x, self.y, self.width, self.height, self.borderRadius, self.gap, self.hoverColor, i, k)
							mouseClick(self.actions, k)
						end
					end
				elseif x >= self.x + self.width - self.borderRadius then
					if y <= self.yTable[k] + self.borderRadius then
						mouseToButton = distance(x, y, self.x + self.width - self.borderRadius, self.yTable[k] + self.borderRadius)
						if mouseToButton <= self.borderRadius + (lineWidth / 2) then
				            mouseOver(self.x, self.y, self.width, self.height, self.borderRadius, self.gap, self.hoverColor, i, k)
							mouseClick(self.actions, k)
						end
					elseif y >= self.yTable[k] + self.height - self.borderRadius then
						mouseToButton = distance(x, y, self.x + self.width - self.borderRadius, self.yTable[k] + self.height - self.borderRadius)
						if mouseToButton <= self.borderRadius + (lineWidth / 2) then
				            mouseOver(self.x, self.y, self.width, self.height, self.borderRadius, self.gap, self.hoverColor, i, k)
						    mouseClick(self.actions, k)
						end
					end
				end

				if x >= self.x + self.borderRadius and x <= self.x + self.width - self.borderRadius then
					mouseOver(self.x, self.y, self.width, self.height, self.borderRadius, self.gap, self.hoverColor, i, k)
					mouseClick(self.actions, k)
				elseif y >= self.yTable[k] + self.borderRadius and y <= self.yTable[k] + self.height - self.borderRadius then
					mouseOver(self.x, self.y, self.width, self.height, self.borderRadius, self.gap, self.hoverColor, i, k)
					mouseClick(self.actions, k)
				end
			end
		end

		love.graphics.setColor(self.lineColor[1], self.lineColor[2], self.lineColor[3], self.lineColor[4])
	    love.graphics.rectangle('line', self.x, self.y + (i - 1) * ( self.height + self.gap), self.width,  self.height, self.borderRadius, self.borderRadius)

		love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3],  self.textColor[4])
	    love.graphics.print(self.contents[i], self.x + (self.width - textWidth) / 2, (((2 * (self.y + (i - 1) * ( self.height + self.gap))) +  self.height) / 2) - (fontHeight / 2))
	end
end

function mouseOver(x, y, width, height, borderRadius, gap, hoverColor, i, k)
	if k == i then
		love.graphics.setColor(hoverColor[1], hoverColor[2], hoverColor[3], hoverColor[4])
		love.graphics.rectangle('fill', x, y + (i - 1) * (height + gap), width,  height, borderRadius, borderRadius)
	end
end

function mouseClick(actions, k)
	if love.mouse.isDown(1) then
		actions[k]()
	end
end