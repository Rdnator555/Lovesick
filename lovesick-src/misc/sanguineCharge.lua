local rd = require("lovesick-src.RickHelper")
local enums = require("lovesick-src.LovesickEnums")

local sanguineCharge = {}

---@param pickup EntityPickup
---@param collider Entity
function sanguineCharge:prePickupCollision(pickup,collider)
    if collider.Type == 1 then
        local player = collider:ToPlayer()
        ---@type ActiveSlot[]
        local activeSlots = {
            ActiveSlot.SLOT_PRIMARY,
            ActiveSlot.SLOT_SECONDARY,
            ActiveSlot.SLOT_POCKET,
            ActiveSlot.SLOT_POCKET2,
        }
        for _,slotCharged in pairs(activeSlots) do
            if player:GetActiveItem(slotCharged)==enums.CollectibleType.LOCKED_HEART and
            player:GetActiveItem(slotCharged) > 0 then
                local charge=player:GetActiveCharge(slotCharged)
                local subcharge = player:GetBatteryCharge(slotCharged)
                local minActiveCharge = player:GetActiveMinUsableCharge(slotCharged)
                if (pickup.Variant == PickupVariant.PICKUP_HEART or pickup.Variant == 1022 or pickup.Variant == 1024 
                or pickup.Variant == 1025 or pickup.Variant == 1028 or pickup.Variant == 1029 or pickup.Variant == 1030)  then
                    if (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false)and subcharge < minActiveCharge) or charge < minActiveCharge and not pickup:IsShopItem() then
                        if LOVESICK.debug then print((player:GetSoulHearts()+ player:GetEffectiveMaxHearts())>=(24-(player:GetBrokenHearts()*2))) end
                        if player:GetHearts() >= player:GetEffectiveMaxHearts() then
                            if pickup.SubType == 1 then
                                rd.PickupKill(pickup)
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+4), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+4), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.SubType == 2 then
                                rd.PickupKill(pickup)
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+2), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+2), slotCharged)
                                    end
                                end                    
                                return
                            elseif pickup.SubType == 5 then
                                rd.PickupKill(pickup)
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+8), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+8), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.SubType == 9 then
                                rd.PickupKill(pickup)
                                SFXManager():Play(SoundEffect.SOUND_THE_FORSAKEN_SCREAM, Options.SFXVolume,  8, false, 1)
                                for _, ent in pairs(Isaac.GetRoomEntities()) do
                                    if ent:IsVulnerableEnemy() then
                                      ent:AddFear(EntityRef(player), 150)
                                    end
                                end
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+5), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+5), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.SubType == 12 then
                                rd.PickupKill(pickup)
                                SFXManager():Play(SoundEffect.SOUND_PESTILENCE_COUGH, Options.SFXVolume,  8, false, 1)
                                for _, ent in pairs(Isaac.GetRoomEntities()) do
                                    if ent:IsVulnerableEnemy() then
                                      ent:AddPoison(EntityRef(player), 63, player.Damage)
                                      player:AddBlueFlies(1, player.Position, player)
                                    end
                                end
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+5), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+5), slotCharged)
                                    end
                                end
                            end
                        end
                        if (player:GetSoulHearts()+ player:GetEffectiveMaxHearts())>=(24-(player:GetBrokenHearts()*2)) then
                            if pickup.SubType == 3 then
                                rd.PickupKill(pickup)
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+5), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+5), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.SubType == 6 then
                                rd.PickupKill(pickup)
                                SFXManager():Play(SoundEffect.SOUND_DEATH_CARD, Options.SFXVolume,  8, false, 1)
                                for _, ent in pairs(Isaac.GetRoomEntities()) do
                                    if ent:IsVulnerableEnemy() then
                                      ent:TakeDamage(player.Damage, DamageFlag.DAMAGE_SPAWN_TEMP_HEART, EntityRef(player), 0)
                                    end
                                end
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+4), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+4), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.SubType == 8 then
                                rd.PickupKill(pickup)
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+2), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+2), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.Variant == 1022 then
                                rd.PickupKill(pickup)
                                SFXManager():Play(SoundEffect.SOUND_DEATH_CARD, Options.SFXVolume,  8, false, 1.3)
                                for _, ent in pairs(Isaac.GetRoomEntities()) do
                                    if ent:IsVulnerableEnemy() then
                                      ent:AddPoison(EntityRef(player), 63, player.Damage)
                                      player:AddBlueFlies(1, player.Position, player)
                                    end
                                end
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+2), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+2), slotCharged)
                                    end
                                end
                                rd.PickupKill(pickup)
                                SFXManager():Play(SoundEffect.SOUND_DEATH_CARD, Options.SFXVolume,  8, false, 1)
                                for _, ent in pairs(Isaac.GetRoomEntities()) do
                                    if ent:IsVulnerableEnemy() then
                                      ent:TakeDamage(player.Damage, DamageFlag.DAMAGE_SPAWN_TEMP_HEART, EntityRef(player), 0)
                                    end
                                end
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+2), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+2), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.Variant == 1024 then
                                Isaac.Spawn(EntityType.ENTITY_EFFECT,1736,0,player.Position,Vector.Zero,player)
                                Isaac.Spawn(EntityType.ENTITY_EFFECT,1736,0,player.Position,Vector.Zero,player)
                                rd.PickupKill(pickup)
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+5), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+5), slotCharged)
                                    end
                                end
                                return
                            elseif pickup.Variant == 1025 then
                                Isaac.Spawn(EntityType.ENTITY_EFFECT,1736,0,player.Position,Vector.Zero,player)
                                rd.PickupKill(pickup)
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+2), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+2), slotCharged)
                                    end
                                end
                            end
                        end
                        if player:GetGoldenHearts()>= ((player:GetSoulHearts()+ player:GetEffectiveMaxHearts())/2) then
                            if pickup.SubType == 7 then
                                rd.PickupKill(pickup)
                                SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, Options.SFXVolume,  8, false, 1)
                                for _, ent in pairs(Isaac.GetRoomEntities()) do
                                    if ent:IsVulnerableEnemy() then
                                      ent:AddMidasFreeze(EntityRef(player), 150)
                                    end
                                end
                                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                                    if subcharge < minActiveCharge then
                                        player:SetActiveCharge(math.min(30,charge+subcharge+2), slotCharged)
                                    end
                                else
                                    if charge < minActiveCharge then
                                        player:SetActiveCharge(math.min(minActiveCharge,charge+2), slotCharged)
                                    end
                                end
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end  

return sanguineCharge