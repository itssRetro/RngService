local RngService = {}
RngService.__index = RngService

function RngService.new()
	local self = setmetatable({}, RngService)
	return self
end


function RngService:odd(percentage: number, multiplier: number)
	if percentage < 0 or percentage > 100 then
		error("Percentage must be between 0 and 100, got: " .. percentage)
	end
	
	if multiplier <= 0 then
		error("Multiplier must be greater than 0, got: " .. multiplier)
	end
	
	local chance = percentage * multiplier
	chance = math.min(100, math.max(0, chance))
	
	local oddObject = {
		type = "percentage",
		value = percentage,
		multiplier = multiplier,
		chance = chance
	}
	
	return oddObject
end

function RngService:oneIn(chance: number, multiplier: number)
	if chance <= 0 then
		error("Chance must be greater than 0, got: " .. chance)
	end
	
	if multiplier <= 0 then
		error("Multiplier must be greater than 0, got: " .. multiplier)
	end
	
	local percentage = (1 / chance) * 100
	local finalChance = percentage * multiplier
	finalChance = math.min(100, math.max(0, finalChance))
	
	local oddObject = {
		type = "oneIn",
		value = chance,
		percentage = percentage,
		multiplier = multiplier,
		chance = finalChance
	}
	
	return oddObject
end

function RngService:Fire(chancesTable)
	if type(chancesTable) ~= "table" then
		error("Fire() expects a table of chances")
	end
	
	local result = nil
	
	while result == nil do
		for key, odd in pairs(chancesTable) do
			if type(odd) == "table" and odd.chance then
				local roll = math.random() * 100
				if roll <= odd.chance then
					result = key
					break
				end
			end
		end
	end
	
	return result
end

function RngService:MultiFire(chancesTable, amount, resultCount)
	if type(chancesTable) ~= "table" then
		error("MultiFire() expects a table of chances as first argument")
	end
	
	if type(amount) ~= "number" or amount <= 0 then
		error("MultiFire() expects a positive number as second argument")
	end
	
	if type(resultCount) ~= "number" or resultCount <= 0 then
		error("MultiFire() expects a positive number as third argument")
	end
	
	local rarityMap = {}
	for key, odd in pairs(chancesTable) do
		if type(odd) == "table" and odd.chance then
			rarityMap[key] = odd.chance
		end
	end
	
	local results = {}
	for i = 1, amount do
		local result = self:Fire(chancesTable)
		table.insert(results, result)
	end
	
	table.sort(results, function(a, b)
		return (rarityMap[a] or 0) < (rarityMap[b] or 0)
	end)
	
	local topResults = {}
	for i = 1, math.min(resultCount, #results) do
		table.insert(topResults, results[i])
	end
	
	return topResults
end

return RngService
