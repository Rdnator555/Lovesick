local enums = require("lovesick-src.LovesickEnums")
local getData = require("lovesick-src.getData")
local rd = require("lovesick-src.RickHelper")

local LockedHeart = {}


function LockedHeart:useItem(item, itemRNG, player, flags, slot, varData)
    if item ~= enums.CollectibleType.LOCKED_HEART then return end
    local data = getData:GetPlayerData(player)
    local RickValues = data.BaseRick
    local stage = LOVESICK.level:GetStage()
    local defaultDMG
    local playerNum
    for n=0, LOVESICK.game:GetNumPlayers()-1 do
        local indexedPlayer = Isaac.GetPlayer(n)
        if indexedPlayer.DropSeed == player.DropSeed then
            playerNum = n + 1
        end
    end
    if stage >= 7 and LOVESICK.persistentGameData:Unlocked(enums.Achievement.LOCKED_HEART_UPGRADE) then defaultDMG = 2 else defaultDMG = 1 end
    if player:GetPlayerType() == enums.PlayerType.Rick then
        local multiplier
        local stressDMG = (math.max(0,math.floor(10+RickValues.Stress-RickValues.StressMax/2)/20))*defaultDMG    
        local ActiveEnemies = 0
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if ent:IsActiveEnemy(false) then
                ActiveEnemies = ActiveEnemies + 1
            end
        end
        if (player:GetNumKeys() > 0  or player:HasGoldenKey()) and  ActiveEnemies>0 and RickValues.Adrenaline>150 then
            if not player:HasGoldenKey() then player:AddKeys(-1) end
            LOVESICK.HUD:ShowItemText(tostring("The heart of player "..(playerNum+1).." rushes"), "Pulse Breakdown!", false)
            local charge=player:GetActiveCharge(ActiveSlot.SLOT_POCKET)        
            local subcharge = player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY,true) and player:GetNumKeys() > 2 then 
                multiplier = 0.60 else multiplier = 1 
            end
            RickValues.LockShield = math.floor(math.max(0,RickValues.LockShield) + multiplier*(math.max(charge,subcharge)/2)*defaultDMG)
            RickValues.Stress = RickValues.StressMax
            RickValues.IsAdrenalineActive = true
            SFXManager():Play(SoundEffect.SOUND_GOLDENKEY, 0.5, 0, false, Options.SFXVolume)
            RickValues.CalmDelay = 5
            if subcharge == 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT,true) then
                player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_POCKET)+7, ActiveSlot.SLOT_POCKET)
            end
        else
            SFXManager():Play(Isaac.GetSoundIdByName("Shield_Up"), 15,  8, false, 1)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY,true) then multiplier = 0.75 else multiplier = 1 end
            RickValues.LockShield = math.floor(math.max(0,RickValues.LockShield)) + math.max(1+stressDMG,defaultDMG)*multiplier
            if player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT,true) then
                player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_POCKET)+7, ActiveSlot.SLOT_POCKET)
            end
        end
    end
    return true
end

return LockedHeart