local Controls = require "scripts.controls"

local M = {}

function M.new(x, y, width, height, control_type, max_speed)
	return {
		x = x,
		y = y,
		width = width,
		height = height,

		speed = 0,
		acceleration = 0.2,
		max_speed = max_speed or 3,
		friction = 0.05,
		angle = 0,

		controls = Controls.new(control_type or "KEYS"),
		damaged = false,
		polygon = nil
	}
end

function M.move(car)
	if car.controls.forward then
		car.speed = car.speed + car.acceleration
	end

	if car.controls.reverse then
		car.speed = car.speed - car.acceleration
	end

	if car.speed > car.max_speed then
		car.speed = car.max_speed
	end

	if car.speed < -car.max_speed / 2 then
		car.speed = -car.max_speed / 2
	end

	if car.speed > 0 then
		car.speed = car.speed - car.friction
	end

	if car.speed < 0 then
		car.speed = car.speed + car.friction
	end

	if math.abs(car.speed) < car.friction then
		car.speed = 0
	end

	if car.speed ~= 0 then
		local flip = car.speed > 0 and 1 or -1

		if car.controls.left then
			car.angle = car.angle - 0.03 * flip
		end

		if car.controls.right then
			car.angle = car.angle + 0.03 * flip
		end
	end

	car.x = car.x + math.sin(car.angle) * car.speed
	car.y = car.y + math.cos(car.angle) * car.speed
end

return M