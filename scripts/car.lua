local Controls = require "scripts.controls"
local Geometry = require "scripts.geometry"
local Sensor = require "scripts.sensors"
local NeuralNetwork = require "scripts.neural_network"

local M = {}

-- function M.new(x, y, width, height, control_type, max_speed)
--   return {
--     x = x,
--     y = y,
--     width = width,
--     height = height,
-- 
--     speed = 0,
--     acceleration = 0.2,
--     max_speed = max_speed or 3,
--     friction = 0.05,
--     angle = 0,
-- 
--     controls = Controls.new(control_type or "KEYS"),
--     damaged = false,
--     polygon = nil
--   }
-- end

function M.new(x, y, width, height, control_type, max_speed)
    local car = {
        x = x,
        y = y,
        width = width,
        height = height,

        speed = 0,
        acceleration = 0.2,
        max_speed = max_speed or 3,
        friction = 0.05,
        angle = 0,

        damaged = false,
        polygon = nil,

        controls = Controls.new(control_type or "KEYS")
    }

    if control_type ~= "DUMMY" then
        car.sensor =
        Sensor.new(car)

        car.brain = NeuralNetwork.new({
            car.sensor.ray_count,
            4
        })

        car.use_brain =
            control_type == "AI"
    end

    return car
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

function M.update(car, road_borders, traffic)

    print("=== CAR.UPDATE() ===")
    
    if not car.damaged then
        M.move(car)

        car.polygon =
        M.create_polygon(car)

        car.damaged =
        M.assess_damage(car, road_borders, traffic)
    end

    if car.sensor then

        print("CAR.UPDATE SENSOR:", #car.sensor.rays)

        Sensor.update(car.sensor, road_borders, traffic)

        print("READINGS:", #car.sensor.readings)

        local offsets = {}

        for i = 1, car.sensor.ray_count do
            local reading = car.sensor.readings[i]
                
            if reading == nil then
                offsets[i] = 0
            else
                offsets[i] = 1 - reading.offset
            end
        end

        print(
        "AI INPUTS:",
        offsets[1],
        offsets[2],
        offsets[3],
        offsets[4],
        offsets[5]
        ) 

        print(
        "BIASES:",
        car.brain.levels[1].biases[1],
        car.brain.levels[1].biases[2],
        car.brain.levels[1].biases[3],
        car.brain.levels[1].biases[4]
        )

    print("WEIGHTS:")

    for i = 1, #car.brain.levels[1].weights do

        print(
        "INPUT",
        i,
        "WEIGHTS:",
        car.brain.levels[1].weights[i][1],
        car.brain.levels[1].weights[i][2],
        car.brain.levels[1].weights[i][3],
        car.brain.levels[1].weights[i][4]
        )

    end 

    -- local test_inputs = {
    --     1,
    --     1,
    --     1,
    --     1,
    --     1
    -- }

    -- local inputs = {
    --     0.0,
    --     0.25,
    --     0.5,
    --     0.75,
    --     1.0
    -- }

    local outputs = NeuralNetwork.feed_forward(offsets, car.brain)
    --local outputs = NeuralNetwork.feed_forward(inputs, car.brain)  

        print("AI OUTPUTS:",
        outputs[1],
        outputs[2],
        outputs[3],
        outputs[4]
        )

        if car.use_brain then 

            print(
            "AI CONTROLS:",
            "F:", car.controls.forward,
            "L:", car.controls.left,
            "R:", car.controls.right,
            "B:", car.controls.reverse
            )
            car.controls.forward = 
                outputs[1] == 1

            car.controls.left =
                outputs[2] == 1

            car.controls.right =
                outputs[3] == 1

            car.controls.reverse =
            outputs[4] == 1

            print(
            "AI CONTROLS 2:",
            "F:", car.controls.forward,
            "L:", car.controls.left,
            "R:", car.controls.right,
            "B:", car.controls.reverse
        )    
        end

       

            
    end
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