local LooseThread = require("lovesick_source.items.loose_thread")
local LockedHeart = require("lovesick_source.items.locked_heart")
local SleepingPills = require("lovesick_source.items.sleeping_pills")
local LoveLetter = require("lovesick_source.items.love_letter")

local function MC_USE_ITEM(_, itemID, itemRNG, player, useFlags, activeSlot, customVarData)
    local returned
    returned = LooseThread.useItem(itemID, itemRNG, player, useFlags, activeSlot)
    if returned ~= nil then return returned end
    returned = LockedHeart.useItem(itemID, itemRNG, player, useFlags, activeSlot)
    if returned ~= nil then return returned end
    returned = SleepingPills.useItem(itemID, itemRNG, player, useFlags, activeSlot)
    if returned ~= nil then return returned end
    returned = LoveLetter.useItem(itemID, itemRNG, player, useFlags, activeSlot)
    if returned ~= nil then return returned end
end

return MC_USE_ITEM