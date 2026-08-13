local Controls = require "scripts.controls"
local Geometry = require "scripts.geometry"

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

function M.create_polygon(car)
  local points = {}

  local radius =
      math.sqrt(
        car.width * car.width
        + car.height * car.height
      ) / 2

  local alpha =
      math.atan(
        car.width / car.height
      )

  points[1] = {
      x = car.x
          - math.sin(
              car.angle - alpha
          ) * radius,

      y = car.y
          - math.cos(
              car.angle - alpha
          ) * radius
  }

  points[2] = {
      x = car.x
          - math.sin(
              car.angle + alpha
          ) * radius,

      y = car.y
          - math.cos(
              car.angle + alpha
          ) * radius
  }

  points[3] = {
      x = car.x
          - math.sin(
              math.pi
              + car.angle
              - alpha
          ) * radius,

      y = car.y
          - math.cos(
              math.pi
              + car.angle
              - alpha
          ) * radius
  }

  points[4] = {
      x = car.x
          - math.sin(
              math.pi
              + car.angle
              + alpha
          ) * radius,

      y = car.y
          - math.cos(
              math.pi
              + car.angle
              + alpha
          ) * radius
  }

return points
end

function M.assess_damage(car, road_borders, traffic)
  
    for _, border in ipairs(road_borders) do
        if Geometry.polys_intersect(
            car.polygon,
            border
        ) then
          return true
        end
    end

    for _, other in ipairs(traffic) do
        if other.polygon
            and Geometry.polys_intersect(
                car.polygon,
                other.polygon
            ) then
            return true
        end
    end

    return false
end


return M