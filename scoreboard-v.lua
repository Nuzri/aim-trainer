function scoreboardV(leftColumn, rightColumn, gap, x, y, width, leftTextColor, rightTextColor)
	local fontHeight = love.graphics.getFont():getHeight()
	for i = 1, #leftColumn do
		love.graphics.setColor(leftTextColor[1], leftTextColor[2], leftTextColor[3], leftTextColor[4])
		love.graphics.print(leftColumn[i], x, y + ((i - 1) * (fontHeight +gap)))

		love.graphics.setColor(rightTextColor[1], rightTextColor[2], rightTextColor[3], rightTextColor[4])
		love.graphics.print(rightColumn[i], x + width - (love.graphics.getFont():getWidth(rightColumn[i])), y + ((i - 1) * (fontHeight + gap)))
	end
end