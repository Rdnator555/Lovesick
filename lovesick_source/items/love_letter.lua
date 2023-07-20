local enums = require("lovesick_source.enums")
local save = require("lovesick_source.save_manager")
local utility = require("lovesick_source.utility")

local love_letter = {}

function love_letter.useItem(item, itemRNG, EntityPlayer, useFlags, activeSlot)
    if item ~= enums.Item.LoveLetter then return end
    local saveData = save.GetData()
    local settings = saveData.file.settings
    local persistent = saveData.run.persistent
    local p = utility.getPlayerIndex(EntityPlayer)
    if settings.LovePoints == nil then
        settings.LovePoints = 1
    else 
        settings.LovePoints = settings.LovePoints + 1
    end
    save.EditData(settings,"settings")
    if persistent.LoveLetterShame == nil then persistent.LoveLetterShame = {} end
    if persistent.LoveLetterShame[p] == nil then 
        persistent.LoveLetterShame[p] = 0
    end
    if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        persistent.LoveLetterShame[p] = persistent.LoveLetterShame[p] + 15
    else
        persistent.LoveLetterShame[p] = persistent.LoveLetterShame[p] + 10
    end
    save.EditData(persistent,"persistent")
    EntityPlayer:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    EntityPlayer:EvaluateItems()
    return {
        Remove = true,
        ShowAnim = true,
    }
end

function  love_letter.onCache(player,cache)
    if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        local saveData = save.GetData()
        local p = utility.getPlayerIndex(player)
        if saveData.run.persistent.LoveLetterShame and saveData.run.persistent.LoveLetterShame[p] and saveData.run.persistent.LoveLetterShame[p] > 0 then
            player.MaxFireDelay = utility.AddTears(player.MaxFireDelay,saveData.run.persistent.LoveLetterShame[p])
        end
    end
end

return love_letter