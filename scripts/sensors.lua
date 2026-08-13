local Geometry = require "scripts.geometry"

local M = {}

function M.new(car)
	return {
		car = car,

		ray_count = 5,
		ray_length = 150,
		ray_spread = math.pi / 2,

		rays = {},
		readings = {}
	}
end

function M.cast_rays(sensor)
	sensor.rays = {}

	for i = 0, sensor.ray_count - 1 do
		local t

		if sensor.ray_count == 1 then
			t = 0.5
		else
			t =
			i / (sensor.ray_count - 1)
		end

		local ray_angle =
		Geometry.lerp(
		sensor.ray_spread / 2,
		-sensor.ray_spread / 2,
		t
	) + sensor.car.angle

	local start = {
		x = sensor.car.x,
		y = sensor.car.y
	}

	local finish = {
		x = sensor.car.x
		+ math.sin(ray_angle)
		* sensor.ray_length,

		y = sensor.car.y
		+ math.cos(ray_angle)
		* sensor.ray_length
	}

	table.insert(
	sensor.rays,
	{ start, finish }
	)
	end
end

function M.get_reading(
	sensor,
	ray,
	road_borders,
	traffic
)
local touches = {}

for _, border in ipairs(road_borders) do
	local touch =
	Geometry.get_intersection(
	ray[1],
	ray[2],
	border[1],
	border[2]
)

if touch then
	table.insert(
	touches,
	touch
)
end
end

for _, traffic_car
in ipairs(traffic or {}) do

local poly =
traffic_car.polygon

if poly then
for j = 1, #poly do
	local j2 = j + 1

	if j2 > #poly then
		j2 = 1
	end

	local touch =
	Geometry.get_intersection(
	ray[1],
	ray[2],
	poly[j],
	poly[j2]
)

if touch then
	table.insert(
	touches,
	touch
)
end
end
end
end

if #touches == 0 then
return nil
end

local closest = touches[1]

for i = 2, #touches do
if touches[i].offset
< closest.offset then

closest = touches[i]
end
end

return closest

end

function M.update(sensor, road_borders, traffic)
	
	M.cast_rays(sensor)
	sensor.readings = {}

	for i, ray
		in ipairs(sensor.rays) do

		sensor.readings[i] =
			M.get_reading(
				sensor,
				ray,
				road_borders,
				traffic
			)
	end
end

function M.draw(sensor)
	for i, ray
	in ipairs(sensor.rays) do

		local endpoint = ray[2]

		if sensor.readings[i] then
			endpoint =
			sensor.readings[i]
		end

		msg.post(
		"@render:",
		"draw_line",
		{
			start_point =
			vmath.vector3(
			ray[1].x,
			ray[1].y,
			1
		),

		end_point =
		vmath.vector3(
		endpoint.x,
		endpoint.y,
		1
	),

	color =
	vmath.vector4(
	1, 1, 0, 1
)
}
)
end
end


return M
