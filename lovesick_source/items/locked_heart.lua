local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local Item = enums.Item
local Trinket = enums.Trinket
local PlayerType = enums.PlayerType

local heart = {}

function heart.useItem(item, itemRNG, EntityPlayer, useFlags, activeSlot)
    if item ~= enums.Item.LockedHeart then return end
    local data = save.GetData()
    local RickValues = data.run.persistent.RickValues
    local p = util.getPlayerIndex(EntityPlayer)
    --ShieldSpriteSelect(p)
    local oldShield = RickValues.LockShield[p]
    local defaultDMG
    if data.file.misc.UnlockQueue == nil then data.file.misc.UnlockQueue = {} end
    local unlocks = data.file.misc.UnlockQueue
    local stage = Game():GetLevel():GetStage()
    if stage >= 7 and unlocks.LockedHeart1 == true then defaultDMG = 2 else defaultDMG = 1 end
    if EntityPlayer:GetPlayerType() == PlayerType.Faithfull then
        local multiplier
        local stressDMG = (math.max(0,math.floor(10+RickValues.Stress[util.getPlayerIndex(EntityPlayer)]-RickValues.StressMax[util.getPlayerIndex(EntityPlayer)]/2)/20))*defaultDMG    
        local ActiveEnemies = 0
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if ent:IsActiveEnemy(false) then
                ActiveEnemies = ActiveEnemies + 1
            end
        end
        if (EntityPlayer:GetNumKeys() > 0  or EntityPlayer:HasGoldenKey()) and  --[[achievements.Faith.Isaac]] false and ActiveEnemies>0 and RickValues.Tired[p]==0 then --oldShield < math.max(1,1+stressDMG) and
            if not EntityPlayer:HasGoldenKey() then EntityPlayer:AddKeys(-1) end
            Game():GetHUD():ShowItemText(tostring("The heart of player "..(p+1).." rushes"), "Pulse Breakdown!", false)
            local charge=EntityPlayer:GetActiveCharge(ActiveSlot.SLOT_POCKET)        
            local subcharge = EntityPlayer:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
            if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY,true) and EntityPlayer:GetNumKeys() > 2 then multiplier = 0.60 else multiplier = 1 end
            --print("chivato4", charge, subcharge, multiplier)
            --print(math.max(0,RickValues.LockShield[p]),multiplier*math.max(charge,subcharge))
            RickValues.LockShield[p] = math.floor(math.max(0,oldShield) + multiplier*(math.max(charge,subcharge)/2)*defaultDMG)
            RickValues.Stress[p] = RickValues.StressMax[p]
            RickValues.Adrenaline[p] = true
    
            SFXManager():Play(SoundEffect.SOUND_GOLDENKEY, 0.5, 0, false, 1.5)
            --print(RickValues.LockShield[p])
            RickValues.CalmDelay[p] = 5
            --print(RickValues.CalmDelay[p], p)
            if subcharge == 0 and EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT,true) then
                EntityPlayer:SetActiveCharge(EntityPlayer:GetActiveCharge(ActiveSlot.SLOT_POCKET)+7, ActiveSlot.SLOT_POCKET)
            end
        else
            --sfxManager:Play(SoundEffect.SOUND_WHISTLE, 0.5, 0, false, 1.7)
            SFXManager():Play(Isaac.GetSoundIdByName("Shield_Up"), 15,  8, false, 1)
            if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY,true) then multiplier = 0.75 else multiplier = 1 end
            RickValues.LockShield[p] = math.floor(math.max(0,oldShield)) + math.max(1+stressDMG,defaultDMG)*multiplier
            if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT,true) then
                EntityPlayer:SetActiveCharge(EntityPlayer:GetActiveCharge(ActiveSlot.SLOT_POCKET)+7, ActiveSlot.SLOT_POCKET)
            end
        end
    end
    return true
end


--LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.LockedHeartUse, Isaac.GetItemIdByName("Locked Heart"))


return heart