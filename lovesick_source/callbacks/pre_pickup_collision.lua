local util = require("lovesick_source.utility")
local enums = require("lovesick_source.enums")
local PlayerType = enums.PlayerType
local functions = {}

local function prePickupCollision(_,Pickup, Entity, Low)
    functions.preHeartCollision(Pickup,Entity)
end

function functions.preHeartCollision(Pickup,Entity)
    if Entity.Type == 1 then
        local player = Entity:ToPlayer()
        --print("colliding",(player:GetSoulHearts()+ player:GetEffectiveMaxHearts())>=(24-(player:GetBrokenHearts()*2)))
        if player:GetPlayerType() == PlayerType.Faithfull  then   --and RickValues.LockShield[number] > 0
            local charge=player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
            local subcharge = player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
            if (Pickup.Variant == PickupVariant.PICKUP_HEART or Pickup.Variant == 1022 or Pickup.Variant == 1024 or Pickup.Variant == 1025 or Pickup.Variant == 1028 or Pickup.Variant == 1029 or Pickup.Variant == 1030)  then
               
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false)and subcharge < 15) or charge < 15 and not Pickup:IsShopItem() then
                    --print((player:GetSoulHearts()+ player:GetEffectiveMaxHearts())>=(24-(player:GetBrokenHearts()*2)))
                    if player:GetHearts() >= player:GetEffectiveMaxHearts() then
                        if Pickup.SubType == 1 then
                            util.PickupKill(Pickup)
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+4), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+4), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.SubType == 2 then
                            util.PickupKill(Pickup)
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+2), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+2), ActiveSlot.SLOT_POCKET)
                                end
                            end                    
                        elseif Pickup.SubType == 5 then
                            util.PickupKill(Pickup)
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+8), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+8), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.SubType == 9 then
                            util.PickupKill(Pickup)
                            SFXManager():Play(SoundEffect.SOUND_THE_FORSAKEN_SCREAM, Options.SFXVolume,  8, false, 1)
                            for _, ent in pairs(Isaac.GetRoomEntities()) do
                                if ent:IsVulnerableEnemy() then
                                  ent:AddFear(EntityRef(player), 150)
                                end
                            end
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+5), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+5), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.SubType == 12 then
                            util.PickupKill(Pickup)
                            SFXManager():Play(SoundEffect.SOUND_PESTILENCE_COUGH, Options.SFXVolume,  8, false, 1)
                            for _, ent in pairs(Isaac.GetRoomEntities()) do
                                if ent:IsVulnerableEnemy() then
                                  ent:AddPoison(EntityRef(player), 63, player.Damage)
                                  player:AddBlueFlies(1, player.Position, player)
                                end
                            end
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+5), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+5), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        end
                    end
                    if (player:GetSoulHearts()+ player:GetEffectiveMaxHearts())>=(24-(player:GetBrokenHearts()*2)) then
                        if Pickup.SubType == 3 then
                            util.PickupKill(Pickup)
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+5), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+5), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.SubType == 6 then
                            util.PickupKill(Pickup)
                            SFXManager():Play(SoundEffect.SOUND_DEATH_CARD, Options.SFXVolume,  8, false, 1)
                            for _, ent in pairs(Isaac.GetRoomEntities()) do
                                if ent:IsVulnerableEnemy() then
                                  ent:TakeDamage(player.Damage, DamageFlag.DAMAGE_SPAWN_TEMP_HEART, EntityRef(player), 0)
                                end
                            end
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+4), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+4), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.SubType == 8 then
                            util.PickupKill(Pickup)
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+2), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+2), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.Variant == 1022 then
                            --print("isblack")
                            util.PickupKill(Pickup)
                            SFXManager():Play(SoundEffect.SOUND_DEATH_CARD, Options.SFXVolume,  8, false, 1.3)
                            for _, ent in pairs(Isaac.GetRoomEntities()) do
                                if ent:IsVulnerableEnemy() then
                                  ent:AddPoison(EntityRef(player), 63, player.Damage)
                                  player:AddBlueFlies(1, player.Position, player)
                                end
                            end
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+2), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+2), ActiveSlot.SLOT_POCKET)
                                end
                            end
                            util.PickupKill(Pickup)
                            SFXManager():Play(SoundEffect.SOUND_DEATH_CARD, Options.SFXVolume,  8, false, 1)
                            for _, ent in pairs(Isaac.GetRoomEntities()) do
                                if ent:IsVulnerableEnemy() then
                                  ent:TakeDamage(player.Damage, DamageFlag.DAMAGE_SPAWN_TEMP_HEART, EntityRef(player), 0)
                                end
                            end
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+2), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+2), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.Variant == 1024 then
                            Isaac.Spawn(EntityType.ENTITY_EFFECT,1736,0,player.Position,Vector.Zero,player)
                            Isaac.Spawn(EntityType.ENTITY_EFFECT,1736,0,player.Position,Vector.Zero,player)
                            util.PickupKill(Pickup)
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+5), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+5), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        elseif Pickup.Variant == 1025 then
                            Isaac.Spawn(EntityType.ENTITY_EFFECT,1736,0,player.Position,Vector.Zero,player)
                            util.PickupKill(Pickup)
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+2), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+2), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        end
                    end
                    if player:GetGoldenHearts()>= ((player:GetSoulHearts()+ player:GetEffectiveMaxHearts())/2) then
                        if Pickup.SubType == 7 then
                            util.PickupKill(Pickup)
                            SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, Options.SFXVolume,  8, false, 1)
                            for _, ent in pairs(Isaac.GetRoomEntities()) do
                                if ent:IsVulnerableEnemy() then
                                  ent:AddMidasFreeze(EntityRef(player), 150)
                                end
                            end
                            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                if subcharge < 15 then
                                    player:SetActiveCharge(math.min(30,charge+subcharge+2), ActiveSlot.SLOT_POCKET)
                                end
                            else
                                if charge < 15 then
                                    player:SetActiveCharge(math.min(15,charge+2), ActiveSlot.SLOT_POCKET)
                                end
                            end
                        end
                    end

                end
            end
        end
    end
end     

return prePickupCollision