-- Car Controls
local M = {}

function M.new(control_type)
	local controls = {
		forward = false,
		left = false,
		right = false,
		reverse = false,
		type = control_type or "KEYS"
	}

	if controls.type == "DUMMY" then
		controls.forward = true
	end

	return controls
end

function M.apply_input(controls, action_id, action)
	if controls.type ~= "KEYS" then
		return
	end

	if action_id == hash("up") then
		controls.forward = true
	elseif action_id == hash("down") then
		controls.reverse = true
	elseif action_id == hash("left") then
		controls.left = true
	elseif action_id == hash("right") then
		controls.right = true
	end
end

function M.release_input(controls, action_id)
	if controls.type ~= "KEYS" then
		return
	end

	if action_id == hash("up") then
		controls.forward = false
	elseif action_id == hash("down") then
		controls.reverse = false
	elseif action_id == hash("left") then
		controls.left = false
	elseif action_id == hash("right") then
		controls.right = false
	end
end

return M
