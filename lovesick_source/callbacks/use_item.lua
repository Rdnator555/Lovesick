local LooseThread = require("lovesick_source.items.loose_thread")
local LockedHeart = require("lovesick_source.items.locked_heart")

local function MC_USE_ITEM(_, itemID, itemRNG, player, useFlags, activeSlot, customVarData)
    local returned = LooseThread.useItem(itemID, itemRNG, player, useFlags, activeSlot)
    if returned ~= nil then return returned end
    local returned = LockedHeart.useItem(itemID, itemRNG, player, useFlags, activeSlot)
    if returned ~= nil then return returned end
end

return MC_USE_ITEM