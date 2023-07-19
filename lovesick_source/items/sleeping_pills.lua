local enums = require("lovesick_source.enums")

local sleeping_pills = {}

function sleeping_pills.useItem(item, itemRNG, EntityPlayer, useFlags, activeSlot)
    if item ~= enums.Item.SleepingPills then return end
    
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,0,Isaac.GetFreeNearPosition(EntityPlayer.Position,1),Vector(0,0),EntityPlayer)
    else
        Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,PillColor.PILL_GOLD,Isaac.GetFreeNearPosition(EntityPlayer.Position,1),Vector(0,0),EntityPlayer)
        EntityPlayer:UsePill(PillEffect.PILLEFFECT_IM_DROWSY, PillColor.PILL_GOLD, UseFlag.USE_NOANIM|UseFlag.USE_NOANNOUNCER)
    end
end

return sleeping_pills