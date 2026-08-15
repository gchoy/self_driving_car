local M = {}

M.cars = {}

function M.add(car)
	table.insert(M.cars, car)
end

function M.get_all()
	return M.cars
end

return M