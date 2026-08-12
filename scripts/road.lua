local M = {}

function M.new(x, width, lane_count)
	local infinity = 1000000

	local road = {
		x = x,
		width = width,
		lane_count = lane_count or 3,

		left = x - width / 2,
		right = x + width / 2,

		top = -infinity,
		bottom = infinity
	}

	road.borders = {
		{
			{ x = road.left, y = road.top },
			{ x = road.left, y = road.bottom }
		},
		{
			{ x = road.right, y = road.top },
			{ x = road.right, y = road.bottom }
		}
	}

	return road
end

function M.get_lane_center(road, lane_index)
	local lane_width =
	road.width / road.lane_count

	return road.left
	+ lane_width / 2
	+ math.min(
	lane_index,
	road.lane_count - 1
) * lane_width
end

return M