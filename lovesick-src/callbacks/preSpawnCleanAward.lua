local preSpawnCleanAward = {}

---@param rng RNG
---@param spawnPos Vector
function preSpawnCleanAward:main(rng, spawnPos)
end

function preSpawnCleanAward:init(mod)
	mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanAward.main)
end

return preSpawnCleanAward
