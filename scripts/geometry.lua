--Geometry Utilities

local M = {}

function M.lerp(a, b, t)
	return a + (b - a) * t
end

function M.get_intersection(a, b, c, d)
	local t_top =
	(d.x - c.x) * (a.y - c.y)
	- (d.y - c.y) * (a.x - c.x)

	local u_top =
	(c.y - a.y) * (a.x - b.x)
	- (c.x - a.x) * (a.y - b.y)

	local bottom =
	(d.y - c.y) * (b.x - a.x)
	- (d.x - c.x) * (b.y - a.y)

	if bottom ~= 0 then
		local t = t_top / bottom
		local u = u_top / bottom

		if t >= 0 and t <= 1
		and u >= 0 and u <= 1 then

			return {
				x = M.lerp(a.x, b.x, t),
				y = M.lerp(a.y, b.y, t),
				offset = t
			}
		end
	end

	return nil
end

function M.polys_intersect(poly1, poly2)
	for i = 1, #poly1 do
		local i2 = i + 1

		if i2 > #poly1 then
			i2 = 1
		end

		for j = 1, #poly2 do
			local j2 = j + 1

			if j2 > #poly2 then
				j2 = 1
			end

			if M.get_intersection(
			poly1[i],
			poly1[i2],
			poly2[j],
			poly2[j2]
		) then
			return true
		end
	end
end

return false
end

function M.random_weight()
	return math.random() * 2 - 1
end

return M