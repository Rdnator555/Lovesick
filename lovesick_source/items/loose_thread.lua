local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local rolls = require("lovesick_source.rolls")
local save = require("lovesick_source.save_manager")
local Item = enums.Item
local Trinket = enums.Trinket

local functions = {}

function functions.useItem(item, rng, player, useFlags, activeSlot)
    if item ~= enums.Item.LooseThread then return end
    local data = save.GetData()
    local index = util.getPlayerIndex(player)
    if data.run.level.mimikyu == nil then
        data.run.level.mimikyu = {}
    end
    if index and data.run.level.mimikyu[index] == nil then
        data.run.level.mimikyu[index] = {}
    end
    local NumPatches = player:GetTrinketMultiplier(enums.Trinket.SorrowPatch) + player:GetTrinketMultiplier(enums.Trinket.RagePatch) + player:GetTrinketMultiplier(enums.Trinket.AimPatch) + player:GetTrinketMultiplier(enums.Trinket.SpeedPatch) + player:GetTrinketMultiplier(enums.Trinket.VelocityPatch) + player:GetTrinketMultiplier(enums.Trinket.CloverPatch)
	if item ~= Item.LooseThread then return end
    if NumPatches>=5 and data.run.level.mimikyu[index].Patches == nil then
        --print("es inicio")
        local mimikyu = Isaac.FindInRadius(player.Position,30,EntityPartition.ENEMY)
        local distance = 20
        local newMimikyu
        for i = 1,#mimikyu do
            local mimikyu = mimikyu[i]
            if mimikyu.Type == EntityType.ENTITY_SHOPKEEPER and mimikyu.Variant == 0 and mimikyu.SubType == 0 and NumPatches >= 5 then
                if player.Position:Distance(mimikyu.Position)< distance then
                    newMimikyu = mimikyu
                    distance = player.Position:Distance(mimikyu.Position)
                end
            end
            local trinketList = {Trinket.AimPatch,Trinket.CloverPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.SpeedPatch,Trinket.VelocityPatch}
            for p = 0, math.max(math.floor(NumPatches/2), 4) do
                local type = rng:RandomInt(6) + 1
                --print(type)
                while player:TryRemoveTrinket(trinketList[type]) == false do
                    type = type + 1
                    if type > 6 then type = 1 end
                end
                local patch = { SubType = trinketList[type] ,}
                if data.run.level.mimikyu[index].Patches == nil then data.run.level.mimikyu[index].Patches = {} end

                util.QueueStore(patch,data.run.level.mimikyu[index].Patches)
            end   
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MIST, 0, mimikyu.Position, Vector.Zero, nil):ToEffect()
            effect.Timeout = 10
            effect.Parent = player
            mimikyu:GetSprite():ReplaceSpritesheet(0, "gfx/mimikyu/mimikyu.png")
            mimikyu:GetSprite():LoadGraphics()
            --print(mimikyu.Position)
            if data.run.level.mimikyu[index].Index == nil then data.run.level.mimikyu[index].Index = Game():GetLevel():GetCurrentRoomIndex() end
            if data.run.level.mimikyu[index].Position == nil then data.run.level.mimikyu[index].Position = {mimikyu.Position.X,mimikyu.Position.Y}  end
            SFXManager():Play(SoundEffect.SOUND_DEVILROOM_DEAL,Options.SFXVolume,0,false,3)
        end
    end
    if player.QueuedItem.Item and player.QueuedItem.Item:IsCollectible() and NumPatches >= 5 then
        local position = Isaac.GetFreeNearPosition(player.Position, 1)
        local queue_item_id = player.QueuedItem.Item.ID
        local oldQuality = Isaac.GetItemConfig():GetCollectible(queue_item_id).Quality
        local NumPatches = player:GetTrinketMultiplier(enums.Trinket.SorrowPatch) + player:GetTrinketMultiplier(enums.Trinket.RagePatch) + player:GetTrinketMultiplier(enums.Trinket.AimPatch) + player:GetTrinketMultiplier(enums.Trinket.SpeedPatch) + player:GetTrinketMultiplier(enums.Trinket.VelocityPatch) + player:GetTrinketMultiplier(enums.Trinket.CloverPatch)
        local quality = oldQuality + math.floor((NumPatches-5)/5)
        local sorryQuality = 0
        --print(quality,oldQuality)
        local rollID = rolls.getItemFromRoomPool(Game():GetRoom(),true,math.min(oldQuality,4),false)
        if rollID == false then
            local limit = 3
            while rollID==false and limit > 0 do
                rollID = rolls.getItemFromRoomPool(Game():GetRoom(),true,math.min(oldQuality,4),true)
                limit = limit - 1
            end
            if limit <= 0 then
                rollID = CollectibleType.COLLECTIBLE_BREAKFAST
            end
        end
        --print(rollID)
        --print(queue_item_id," ",oldQuality," ",rollID," ",quality)
        --player:FlushQueueItem()
        --player:RemoveCollectible(queue_item_id)
        local pickups = Isaac.FindInRadius(player.Position,30,EntityPartition.PICKUP)
        for i = 1,#pickups do
            local pickup = pickups[i]
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
            and pickup.SubType == CollectibleType.COLLECTIBLE_NULL then
                pickup:Remove() 
                position = pickup.Position
                break
            end
        end
        if rollID and Isaac.GetItemConfig():GetCollectible(rollID).Quality > quality then
            local fail = 30 
            while Isaac.GetItemConfig():GetCollectible(rollID).Quality > quality and fail > 0 do
                rollID = rolls.getItemFromRoomPool(Game():GetRoom(),true,math.min(oldQuality,4),false)
                fail = fail-1
            end
        end
        if Isaac.GetItemConfig():GetCollectible(rollID).Quality < quality then
            player:FlushQueueItem()
            player:RemoveCollectible(queue_item_id)
            --print("fix")
            --fuuuuck my a is broken and codign is paaaain
            sorryQuality = quality - Isaac.GetItemConfig():GetCollectible(rollID).Quality
            local position = Isaac.GetFreeNearPosition(player.Position, 1)
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,rolls.getItemFromRoomPool(Game():GetRoom(),true,math.min(sorryQuality,4),false),position,Vector.Zero,player)
        end
        local removedPatchesNum = 5 + (quality - (oldQuality + sorryQuality))*10
        for p =  0, removedPatchesNum-1 do
            local trinketList = {Trinket.AimPatch,Trinket.BlessedPatch,Trinket.CloverPatch,Trinket.CursedPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.SpeedPatch,Trinket.VelocityPatch}
            local type = rng:RandomInt(8) + 1
            while player:TryRemoveTrinket(trinketList[type]) == false do
                type = type + 1
                if type > 8 then type = 1 end
            end
        end
        player:AddBrokenHearts(2)
        player:SetMinDamageCooldown(90)
        player:PlayExtraAnimation("Hit",true)
        SFXManager():Play(Isaac.GetSoundIdByName("Squeak"),Options.SFXVolume,0,false,1)
        Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,rollID,position,Vector.Zero,player)
    elseif player.QueuedItem.Item and player.QueuedItem.Item:IsCollectible() then
        --to do recycling code
    elseif NumPatches >= 2 and player:GetBrokenHearts() > 0 then
        player:AddBrokenHearts(-1)
        local removedPatchesNum = 2
        for p =  0, removedPatchesNum-1 do
            local trinketList = {Trinket.AimPatch,Trinket.BlessedPatch,Trinket.CloverPatch,Trinket.CursedPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.SpeedPatch,Trinket.VelocityPatch}
            local type = rng:RandomInt(8) + 1
            while player:TryRemoveTrinket(trinketList[type]) == false do
                type = type + 1
                if type > 8 then type = 1 end
            end
        end
    end
    player:AnimateCollectible(Item.LooseThread, "UseItem")
    local nearbyPickups = Isaac.FindInRadius(player.Position, 60, EntityPartition.PICKUP)
        for _, pickup in ipairs(nearbyPickups) do
        local probability = math.floor((NumPatches/(NumPatches+100))*90)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then probability = math.floor(probability/2) end
        if pickup.Type == 5 and pickup.Variant ~= 350 then
                if pickup.Variant == 10 then
                    local probability = rng:RandomInt(101) - probability
                    local patchType = rng:RandomInt(4) + 1
                    if probability > 0 then
                        local pickupList = {Trinket.RagePatch,Trinket.SorrowPatch,Trinket.AimPatch,Trinket.VelocityPatch}
                        if pickup.SubType == 1 or pickup.SubType == 2 or pickup.SubType == 3 or pickup.SubType == 8 or pickup.SubType == 12 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                        elseif pickup.SubType == 5 or pickup.SubType == 6 or pickup.SubType == 7 or pickup.SubType == 4 or pickup.SubType == 10 or pickup.SubType == 11 then    
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(4) + 1] , pickup.Position, Vector.Zero, pickup)
                        elseif pickup.SubType == 9 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                        else
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                        end
                    else
                        pickup:Remove()
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
                        effect.Timeout = 1
                    end
                    
                end
                if pickup.Variant == 1022 or pickup.Variant == 1022 or pickup.Variant == 1023 or pickup.Variant == 1024 or pickup.Variant == 1025 or pickup.Variant == 1026  then
                    local probability = rng:RandomInt(101) - probability
                    local patchType = rng:RandomInt(4) + 1
                    if probability > 0 then
                        local pickupList = {Trinket.RagePatch,Trinket.SorrowPatch,Trinket.AimPatch,Trinket.VelocityPatch}
                        pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                    else
                        pickup:Remove()
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
                        effect.Timeout = 1
                    end
                end
                if pickup.Variant == 20 then
                    local probability = rng:RandomInt(101) - probability
                    local patchType = rng:RandomInt(3) + 1
                    if probability > 0 then
                        local pickupList = {Trinket.CloverPatch,Trinket.SpeedPatch,Trinket.AimPatch}
                        if pickup.SubType == 1 or pickup.SubType == 2 or pickup.SubType == 6 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                        elseif pickup.SubType == 3 or pickup.SubType == 4 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(3) + 1] , pickup.Position, Vector.Zero, pickup)
                        elseif pickup.SubType == 5 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , pickup.Position, Vector.Zero, pickup)
                        elseif pickup.SubType == 7 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(3) + 1] , pickup.Position, Vector.Zero, pickup)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(3) + 1] , pickup.Position, Vector.Zero, pickup)
                        else
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                        end
                    else
                        pickup:Remove()
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
                        effect.Timeout = 1
                    end
                end
                if pickup.Variant == 30 then
                    local probability = rng:RandomInt(101) - probability
                    local patchType = rng:RandomInt(3) + 1
                    if probability > 0 then
                        local pickupList = {Trinket.CloverPatch,Trinket.SpeedPatch,Trinket.RagePatch}
                        if pickup.SubType == 1 or pickup.SubType == 179 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                        elseif pickup.SubType == 2 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , pickup.Position, Vector.Zero, pickup)
                        elseif pickup.SubType == 3 or pickup.SubType == 4 or pickup.SubType == 180 or pickup.SubType == 181 or pickup.SubType == 182 or pickup.SubType == 183 or pickup.SubType == 184 or pickup.SubType == 185 or pickup.SubType == 186 or pickup.SubType == 187 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[1] , true, true, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , pickup.Position, Vector.Zero, pickup)
                        else
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                        end
                    else
                        pickup:Remove()
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
                        effect.Timeout = 1
                    end
                end
                if pickup.Variant == 40 then
                    local probability = rng:RandomInt(101) - probability
                    local patchType = rng:RandomInt(3) + 1
                    if probability > 0 then
                        local pickupList = {Trinket.CloverPatch,Trinket.SorrowPatch,Trinket.RagePatch}
                        if pickup.SubType == 2 or pickup.SubType == 4 then
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(3) + 1] , pickup.Position, Vector.Zero, pickup)
                        else
                            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                        end
                    else
                        pickup:Remove()
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
                        effect.Timeout = 1
                    end
                end
                if pickup.Variant == 70 then
                    local patchType = rng:RandomInt(6) + 1
                    local pickupList = {Trinket.CloverPatch,Trinket.SpeedPatch,Trinket.AimPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.VelocityPatch}
                    if pickup.SubType == 14 then    
                        pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(3) + 1] , pickup.Position, Vector.Zero, pickup)
                    elseif pickup.SubType == 2062 then
                        pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(3) + 1] , pickup.Position, Vector.Zero, pickup)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[rng:RandomInt(3) + 1] , pickup.Position, Vector.Zero, pickup)
                    else
                        pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                    end
                end
                if pickup.Variant == 90 or pickup.Variant == 900 or pickup.Variant == 901 or pickup.Variant == 902 or pickup.Variant == 903 or pickup.Variant == 300 then
                    local patchType = rng:RandomInt(6) + 1
                    local pickupList = {Trinket.CloverPatch,Trinket.SpeedPatch,Trinket.AimPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.VelocityPatch}
                    pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, pickupList[patchType] , true, true, true)
                end
            end
        end
    save.SaveModData()
    return true
end
return functions