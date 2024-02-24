local rd = require("lovesick-src.RickHelper")
local Faithfull = require("lovesick-src.characters.Faithfull")
local evaluateCache = {}


---@param player EntityPlayer
---@param cacheFlag CacheFlag
function evaluateCache:main(player, cacheFlag)
	---@class ItemStats
	---@field SPEED_MULT integer
	---@field FIREDELAY_MULT integer
	---@field DAMAGE_MULT integer
	---@field RANGE_MULT integer
	---@field SHOTSPEED_MULT integer
	---@field LUCK_MULT integer
	---@field SPEED integer
	---@field FIREDELAY integer
	---@field DAMAGE integer
	---@field RANGE integer
	---@field SHOTSPEED integer
	---@field LUCK integer
	---@field IS_FLYING boolean
	---@field TEARFLAGS TearFlags
	local itemStats = {
		SPEED_MULT = 1,
		FIREDELAY_MULT = 1,
		DAMAGE_MULT = 1,
		RANGE_MULT = 1,
		SHOTSPEED_MULT = 1,
		LUCK_MULT = 1,
		SPEED = 0,
		FIREDELAY = 0,
		DAMAGE = 0,
		RANGE = 0,
		SHOTSPEED = 0,
		LUCK = 0,
		IS_FLYING = false,
		TEARFLAGS = TearFlags.TEAR_NORMAL
	}

	--Player-specific stats
	Faithfull:AdrenalineDMG(player, cacheFlag, itemStats)
	--Item Stats

	--Put together all stats
	evaluateCache:OnCache(player, cacheFlag, itemStats)
end

---@param player EntityPlayer
function evaluateCache:OnFamiliarCache(player)
	for _, familiarTable in pairs(LOVESICK.ItemToFamiliarVariant) do
		local itemID = familiarTable[1]
		local familiarVariant = familiarTable[2]
		--familiarBasics:OnFamiliarCache(player, itemID, familiarVariant)
	end
end

---@param player EntityPlayer
---@param cacheflag CacheFlag
---@param stats ItemStats
function evaluateCache:OnCache(player, cacheflag, stats)
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_DAMAGE) then
		player.Damage = (player.Damage*stats.DAMAGE_MULT)+stats.DAMAGE
	end
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_FIREDELAY) then
		player.MaxFireDelay = (player.MaxFireDelay*stats.FIREDELAY_MULT)+stats.FIREDELAY
	end
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_FLYING) then
		player.CanFly = player.CanFly or stats.IS_FLYING
	end
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_LUCK) then
		player.Luck = (player.Luck*stats.LUCK_MULT)+stats.LUCK
	end
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_RANGE) then
		player.TearRange = (player.TearRange*stats.RANGE_MULT)+stats.RANGE
	end
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_SHOTSPEED) then
		player.ShotSpeed = (player.ShotSpeed*stats.SHOTSPEED_MULT)+stats.SHOTSPEED
	end
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_SPEED) then
		player.MoveSpeed = (player.MoveSpeed*stats.SPEED_MULT)+stats.SPEED
	end
	if rd.HasBitFlags(cacheflag, CacheFlag.CACHE_TEARFLAG) then
		player.TearFlags = player.TearFlags | stats.TEARFLAGS
	end
end

function evaluateCache:init(mod)
	mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evaluateCache.main)
	mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evaluateCache.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)
end

return evaluateCache