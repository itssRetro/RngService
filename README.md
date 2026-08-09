```lua
-- commands:

Rng:odd(percentage, multiplier)
-- Creates a percentage‑based chance (e.g., 10% * multiplier)

Rng:oneIn(x, multiplier)
-- Creates a 1‑in‑X chance (e.g., 1 in 5 = 20%)

Rng:Fire(chancesTableOrSingleOdd)
-- Rolls once and returns the successful key
-- If you pass a single odd object, it returns TRUE or FALSE

Rng:MultiFire(chancesTable, amount, resultCount)
-- Rolls multiple times and returns the best N results sorted by rarity


-- Calling the Service:

local Rng = require(game:GetService("ReplicatedStorage"):WaitForChild("RngService")).new()
-- ^ Requires the module from ReplicatedStorage
-- ^ .new() creates a fresh RNG service instance


-- Usage:

-- Create a 1-in-X chance
local commonChance = Rng:oneIn(2, 1)
-- ^ 1 in 2 chance (50%), multiplier 1 keeps it the same

-- Create a percentage chance
local rareChance = Rng:odd(10, 1)
-- ^ 10% chance, multiplier 1 keeps it the same

-- Combine chances into a table
local chances = {
    Common = commonChance,
    Rare = rareChance,
}
-- ^ Keys are names, values are chance objects created above

-- Single roll (table)
local result = Rng:Fire(chances)
print(result)
-- ^ Prints whichever chance succeeded first

-- Single roll (single odd object)
local didHit = Rng:Fire(commonChance)
print(didHit)
-- ^ TRUE if the roll succeeded, FALSE if it failed

-- Multi-roll (best N out of X)
local bestResults = Rng:MultiFire(chances, 5, 2)
-- ^ Rolls 5 times, returns the 2 rarest results
```
