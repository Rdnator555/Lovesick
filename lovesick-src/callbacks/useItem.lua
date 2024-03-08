local LockedHeart = require("lovesick-src.items.collectibles.LockedHeart")

local useItem = {}

---@param itemID CollectibleType
---@param itemRNG RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param varData integer
function useItem:main(itemID, itemRNG, player, flags, slot, varData)
	
	local functions = {
		LockedHeart:useItem(itemID, itemRNG, player, flags, slot, varData)
	}

	for _, func in pairs(functions) do
		if func ~= nil then return func end
	end
end

function useItem:init(mod)
	mod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem.main)
end

return useItem
