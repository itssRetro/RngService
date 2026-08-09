--[[
	RngService - A Roblox Luau service module for calculating rewards and odds
	
	Usage:
	local Rng = require(game:GetService("ReplicatedStorage"):WaitForChild("RngService")).new()
	
	local chances = {
	    Common = Rng:oneIn(2, 1),
	    Rare = Rng:oneIn(10, 1),
	    Legendary = Rng:odd(1, 1)
	}
	
	-- Single fire
	Button.MouseButton1Click:Connect(function()
	    local result = Rng:Fire(chances)
	    print(result)
	end)
	
	-- Multiple fires, get best 2 out of 5 rolls
	local results = Rng:MultiFire(chances, 5, 2)
	-- results = {"Legendary", "Rare"} (the 2 best from 5 rolls)
]]

local RngService = {}
RngService.__index = RngService

--[[
	Initialize a new RngService instance
	Returns: RngService instance
]]
function RngService.new()
	local self = setmetatable({}, RngService)
	return self
end

--[[
	Create a percentage odds roll
	
	Usage: local RareChance = rng:odd(5, 1)
	
	Args:
		percentage (number): The percentage chance (0-100)
		multiplier (number): Multiplier for the odds
	
	Returns: OddObject
]]
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

--[[
	Create a 1 in X odds roll
	
	Usage: local CommonChance = rng:oneIn(2, 1)
	
	Args:
		chance (number): 1 in X (e.g., 1 in 2 = 50%)
		multiplier (number): Multiplier for the odds
	
	Returns: OddObject
]]
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

--[[
	Fire all odds in a table and return the first successful key
	If no odds succeed, keep rerolling until one does
	
	Usage: local result = rng:Fire(chances)
	
	Args:
		chancesTable (table): A table of odds with keys as names
	
	Returns: string - The key of the successful odd
]]
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

--[[
	Fire multiple times and return the best N results sorted by rarity
	
	Usage: local results = rng:MultiFire(chances, 5, 2)
	       -- Fires 5 times and returns the 2 best results
	       -- Results sorted by rarity (best/rarest first)
	
	Args:
		chancesTable (table): A table of odds with keys as names
		amount (number): How many times to fire
		resultCount (number): How many of the best results to return
	
	Returns: table - Array of the best results sorted by rarity (best first)
]]
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
