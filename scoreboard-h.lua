function scoreboardH(left, right, gap, x, y, leftTextColor, rightTextColor)
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