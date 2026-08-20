local geometry = "scripts.geometry"

local M = {}

local function random_weight()
	return math.random()*2 - 1
end 

local function create_level(input_count, output_count)
	local level = {
		inputs = {},
		outputs = {},
		biases = {},
		weights = {}
	}

	for i = 1, input_count do
		level.inputs[i] = 0
		level.weights[i] = {}

		for j =1, output_count do
			level.weights[i][j] = random_weight()
		end
	end

	for i = 1, output_count do
		level.outputs[i] = 0
		level.biases[i] = random_weight()
	end 

	

	return level	
end 

local function feed_forward(given_inputs,level)
	
for i = 1, #level.inputs do
	level.inputs[i] =
	given_inputs[i] or 0
end

for i = 1, #level.outputs do
	local sum = 0

	for j = 1, #level.inputs do
		sum =
		sum
		+ level.inputs[j]
		* level.weights[j][i]
	end

	print(
	"NEURON",
	i,
	"SUM:",
	sum,
	"BIAS:",
	level.biases[i]
	)

	if sum > level.biases[i] then
		level.outputs[i] = 1
	else
		level.outputs[i] = 0
	end
end

return level.outputs
end


function M.new(neuron_counts)
	local network = { 
		levels = {}
	}

	for i = 1, #neuron_counts - 1 do
		table.insert(
			network.levels,
			create_level(
			neuron_counts[i],
			neuron_counts[i + 1]
			)

		)
	end

	return network

end 


function M.feed_forward(
	inputs,
	network
)
local outputs =
feed_forward(
inputs,
network.levels[1]
)

for i = 2, #network.levels do
outputs =
feed_forward(
outputs,
network.levels[i]
)
end

return outputs
end

return M