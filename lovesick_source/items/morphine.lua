local enums = require("lovesick_source.enums")
local save = require("lovesick_source.save_manager")
local utility = require("lovesick_source.utility")

local morphine = {}

function morphine.useItem(item, itemRNG, EntityPlayer, useFlags, activeSlot)
    if item ~= enums.Item.Morphine then return end
    local saveData = save.GetData()
    local settings = saveData.file.settings
    local persistent = saveData.run.persistent
    local p = utility.getPlayerIndex(EntityPlayer)
    if persistent.MorphineTime == nil then persistent.MorphineTime = {} end
    if persistent.MorphineTime[p] == nil then 
        persistent.MorphineTime[p] = 0
    end
    if persistent.MorphineDebuff == nil then persistent.MorphineDebuff = {} end
    if persistent.MorphineDebuff[p] == nil then 
        persistent.MorphineDebuff[p] = 0
    end
    if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
        persistent.MorphineTime[p] = persistent.MorphineTime[p] + 90
    else
        persistent.MorphineTime[p] = persistent.MorphineTime[p] + 60
    end
    save.EditData(persistent,"persistent")
    EntityPlayer:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    EntityPlayer:EvaluateItems()
    return {
        Remove = true,
        ShowAnim = true,
    }
end

function  morphine.onCache(player,cache)
    if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        local saveData = save.GetData()
        local p = utility.getPlayerIndex(player)
        if saveData.run.persistent.MorphineDebuff and saveData.run.persistent.MorphineDebuff[p] and saveData.run.persistent.MorphineDebuff[p] > 0 then
            player.MaxFireDelay = utility.AddTears(player.MaxFireDelay,-saveData.run.persistent.MorphineDebuff[p])
        end
    end
end

function morphine.entity_take_dmg(player,Amount,DamageFlags)
    local p = utility.getPlayerIndex(player)
    local saveData = save.GetData()
    local persistent = saveData.run.persistent
    if persistent.MorphineTime == nil then return end
    if persistent.MorphineTime[p] > 0 then
        player:SetMinDamageCooldown(60) 
        player:AnimateSad()
        persistent.MorphineDebuff[p] = math.max (math.min(persistent.MorphineDebuff[p] + 0.25,3), 0.5)
        return false 
    end
end

return morphine