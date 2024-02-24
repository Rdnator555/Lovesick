local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local oldTime
local Item = enums.Item
local Trinket = enums.Trinket
local Snowball = {}
---comment
---@param player EntityPlayer
---@param saveData table
---@param data table
function Snowball.post_player_update(player,saveData,data)
    local p = util.getPlayerIndex(player)
    local rng = player:GetDropRNG()
    if saveData.run.persistent.Patches == nil then
        saveData.run.persistent.Patches = {}
    end
    if p then saveData.run.persistent.Patches[p]={} end
    local nearbyPickups = Isaac.FindInRadius(player.Position, 24, EntityPartition.PICKUP)
    for _, pickup in ipairs(nearbyPickups) do
        if pickup:ToPickup() and not pickup:ToPickup():IsShopItem() and pickup.Type == 5 and pickup.Variant == 350 and (pickup.SubType ==Trinket.AimPatch or pickup.SubType ==Trinket.BlessedPatch or pickup.SubType ==Trinket.CloverPatch or pickup.SubType ==Trinket.CursedPatch or pickup.SubType ==Trinket.RagePatch or pickup.SubType ==Trinket.SorrowPatch or pickup.SubType ==Trinket.SpeedPatch or pickup.SubType ==Trinket.VelocityPatch) then
            if data.PatchQueue == nil then
                data.PatchQueue ={}
            elseif pickup:Exists() then
                util.QueueStore(pickup,data.PatchQueue)
                pickup:Remove()
            end
        end
    end
    if player:GetSprite():IsEventTriggered("DeathSound") then
        SFXManager():Stop(SoundEffect.SOUND_ISAACDIES)
    end
    local time = Game():GetFrameCount()
    if (oldTime~= time) then
        local NumPatches = player:GetTrinketMultiplier(enums.Trinket.SorrowPatch) + player:GetTrinketMultiplier(enums.Trinket.RagePatch) + player:GetTrinketMultiplier(enums.Trinket.AimPatch) + player:GetTrinketMultiplier(enums.Trinket.SpeedPatch) + player:GetTrinketMultiplier(enums.Trinket.VelocityPatch) + player:GetTrinketMultiplier(enums.Trinket.CloverPatch)
    if p and saveData.run.persistent.Init[p]== nil and NumPatches == 0 then
        saveData.run.persistent.Init[p]= true
        save.SaveModData()
        local trinketList = {Trinket.AimPatch,Trinket.CloverPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.SpeedPatch,Trinket.VelocityPatch}
        for n = 0, 4 do
        local type = rng:RandomInt(6) + 1
        if data.PatchQueue == nil then
            data.PatchQueue ={}
        end
        local patch = { SubType = trinketList[type] ,}
        util.QueueStore(patch,data.PatchQueue)
        end
        data.Init = true
        end
        local nextPatch
        if data.PatchQueue == nil then
            nextPatch = nil
        else
            oldTime = time
            nextPatch = util.QueueRemove(data.PatchQueue) 
        end
        if nextPatch ~= nil then
            util.addSmeltTrinket(player,nextPatch.SubType, true)
            local trinketList = {Trinket.AimPatch,Trinket.CloverPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.SpeedPatch,Trinket.VelocityPatch}
            SFXManager():Play(SoundEffect.SOUND_KNIFE_PULL,Options.SFXVolume,0,false,3)
            save.SaveModData()
        end
    end
    
end
---comment
---@param data table
---@param player EntityPlayer
function Snowball.post_player_init(data,player)
    data.Init = false
    player:SetPocketActiveItem(Item.LooseThread, SLOT_POCKET, false)
end
---comment
---@param player EntityPlayer
---@param Amount number
---@param DamageFlags DamageFlag
---@return boolean
function Snowball.entity_take_dmg(player, Amount, DamageFlags)
    SFXManager():Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
    SFXManager():Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT, 0,  8, false, 1)
    local rng = player:GetCollectibleRNG(Item.LooseThread)
    local NumPatches = player:GetTrinketMultiplier(enums.Trinket.SorrowPatch) + player:GetTrinketMultiplier(enums.Trinket.RagePatch) + player:GetTrinketMultiplier(enums.Trinket.AimPatch) + player:GetTrinketMultiplier(enums.Trinket.SpeedPatch) + player:GetTrinketMultiplier(enums.Trinket.VelocityPatch) + player:GetTrinketMultiplier(enums.Trinket.CloverPatch)
    if NumPatches == 0 then 
        local dataCache =  save.GetData()
        local p = util.getPlayerIndex(player)
        --print((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())<=Amount,(DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES ~= 0 or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS ~= 0 or DamageFlags & DamageFlag.DAMAGE_CURSED_DOOR ~= 0))
        if dataCache.run.level.mimikyu and dataCache.run.level.mimikyu[p] and dataCache.run.level.mimikyu[p].Index and ((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts()<=Amount)
        or not(DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES ~= 0 or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS ~= 0 or DamageFlags & DamageFlag.DAMAGE_CURSED_DOOR ~= 0)) then
            local index = dataCache.run.level.mimikyu[p].Index
            local roomX = index%13
            local roomY = math.floor(index/13) 
            local gotoCommand = "goto "..tostring(roomX).." "..tostring(roomY).." 0"
            Game():ShowHallucination(10, 0)
            SFXManager():Stop(SoundEffect.SOUND_DEATH_CARD)
            Isaac.ExecuteCommand(gotoCommand)
            player:GetData().NoDeathAnim = true
            player:UseCard(Card.CARD_SOUL_LAZARUS,UseFlag.USE_NOANIM|UseFlag.USE_CARBATTERY|UseFlag.USE_NOANNOUNCER)
        elseif not(DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES ~= 0 or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS ~= 0 or DamageFlags & DamageFlag.DAMAGE_CURSED_DOOR ~= 0)  then
            SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
            player:Die()
        else
            SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
        end
        SFXManager():Stop(SoundEffect.SOUND_ISAACDIES)
        SFXManager():Play(SoundEffect.SOUND_ISAACDIES, 0,  8, false, 1)            
    elseif (DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES ~= 0 or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS ~= 0 or DamageFlags & DamageFlag.DAMAGE_CURSED_DOOR ~= 0) then 
        if (player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())<=Amount then
            local trinketList = {Trinket.AimPatch,Trinket.BlessedPatch,Trinket.CloverPatch,Trinket.CursedPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.SpeedPatch,Trinket.VelocityPatch}
            local type = rng:RandomInt(8) + 1
            if (NumPatches - Amount) >= 0 then
                for p = 0 ,math.max(math.min(NumPatches-1,(Amount-1)),0) do
                    if NumPatches == 0 then 
                        
                        SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
                    end
                    while player:TryRemoveTrinket(trinketList[type]) == false do
                        type = rng:RandomInt(8) + 1
                    end
                end
                SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
                return false
            elseif NumPatches > 0 then
                while player:TryRemoveTrinket(trinketList[type]) == false do
                    type = rng:RandomInt(8) + 1
                end
                player:AddBrokenHearts(1)
                SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
                return false
            else
                SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
            end
        else
            SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
        end
    else
        player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR,UseFlag.USE_NOANIM|UseFlag.USE_NOANNOUNCER,UseFlag.USE_CARBATTERY)
        player:SetMinDamageCooldown(90)
        player:PlayExtraAnimation("Hit")
        SFXManager():Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
        SFXManager():Play(Isaac.GetSoundIdByName("Squeak"),Options.SFXVolume,0,false,1)
        local removedPatchesNum
        if NumPatches > 100 then
            removedPatchesNum = NumPatches/2
        elseif NumPatches > 50 then
            removedPatchesNum = NumPatches/3
        else
            removedPatchesNum = math.min(10,NumPatches)
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then removedPatchesNum = math.floor(removedPatchesNum * 0.7) end
        for p =  0, removedPatchesNum-1 do
            local trinketList = {Trinket.AimPatch,Trinket.BlessedPatch,Trinket.CloverPatch,Trinket.CursedPatch,Trinket.RagePatch,Trinket.SorrowPatch,Trinket.SpeedPatch,Trinket.VelocityPatch}
            local type = rng:RandomInt(8) + 1
            while player:TryRemoveTrinket(trinketList[type]) == false do
                type = type + 1
                if type > 8 then type = 1 end
            end
            local loseProbability = rng:RandomInt(101)
            if loseProbability > 20 then
                local trinketLost = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,trinketList[type],player.Position,(Vector.FromAngle(rng:RandomInt(361))):Resized(player.MoveSpeed*3),player):ToPickup()
                trinketLost.Timeout = 60
            end
        end
        SFXManager():Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
        SFXManager():Play(Isaac.GetSoundIdByName("Squeak"), Options.SFXVolume,  8, false, 1)
        return false 
    end
end

function Snowball.unlocks_NPC(npc)
    local saveData = save.GetData()
    if saveData.file.misc.UnlockQueue == nil then saveData.file.misc.UnlockQueue = {} end
    local unlockQueue = saveData.file.misc.UnlockQueue
    local unlocks = saveData.file.achievements
    local level = Game():GetLevel()
    local levelStage = level:GetStage()
    if Game():GetVictoryLap() > 0 then return end
    if Game().Difficulty == Difficulty.DIFFICULTY_HARD then
        if levelStage == LevelStage.STAGE5 then
            if npc.Type == EntityType.ENTITY_ISAAC then
                if unlocks.Snowball ~= true then --Isaac/Cathedral
                    --LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_1.png")
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_1.png",unlockQueue)  --Lockedheart shield upgrade after womb Unlock
                    unlocks.Snowball = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            elseif npc.Type == EntityType.ENTITY_SATAN then
                if unlocks.LooseThread ~= true then
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_4.png",unlockQueue)  --Neck Gaiter Unlock
                    unlocks.LooseThread = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            end
        elseif levelStage == LevelStage.STAGE6 then
            if npc.Type == EntityType.ENTITY_ISAAC
            and npc.Variant == 1
            then
                if unlocks.SnowballTreat ~= true then
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_1.png",unlockQueue)  --Adrenaline Rush Unlock
                    unlocks.SnowballTreat = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            elseif npc.Type == EntityType.ENTITY_THE_LAMB then
                if unlocks.Patches ~= true then
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_3.png",unlockQueue)  --Painting Kit Unlock
                    unlocks.Patches = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            elseif npc.Type == EntityType.ENTITY_MEGA_SATAN_2 then
                if unlocks.SewingMachine ~= true then
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_10.png",unlockQueue)  --Box of Leftovers Unlock
                    unlocks.SewingMachine = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            end
        elseif levelStage == LevelStage.STAGE7
        and npc.Type == EntityType.ENTITY_DELIRIUM
        then
            if unlocks.OldDrawing ~= true then
                --util.QueueStore("gfx/ui/achievement/achievement_Rick_5.png",unlockQueue)  --Sunset Clock Unlock
                unlocks.OldDrawing = true
                save.EditData(unlocks,"Achievements")
                save.EditData(unlockQueue,"UnlockQueue")
            end
        elseif (levelStage == LevelStage.STAGE4_1 or levelStage == LevelStage.STAGE4_2)
        and npc.Type == EntityType.ENTITY_MOTHER
        and npc.Variant == 10
        then
            if unlocks.PinsAndNeedles ~= true then
                --util.QueueStore("gfx/ui/achievement/achievement_Rick_6.png",unlockQueue)  --Birthday Cake Unlock
                unlocks.PinsAndNeedles = true
                save.EditData(unlocks,"Achievements")
                save.EditData(unlockQueue,"UnlockQueue")
            end
        end
    end
end

function Snowball.post_entity_kill(entity)
	if Game():GetVictoryLap() > 0 then return end
	if entity.Type ~= EntityType.ENTITY_BEAST then return end
	if entity.Variant ~= 0 then return end
    local saveData = save.GetData()
    if saveData.file.misc.UnlockQueue == nil then saveData.file.misc.UnlockQueue = {} end
    local unlockQueue = saveData.file.misc.UnlockQueue
    local unlocks = saveData.file.achievements
    if unlocks.LostAndFound ~= true then
        --util.QueueStore("gfx/ui/achievement/achievement_Rick_8.png",unlockQueue)  --Morphine Unlock
        unlocks.LostAndFound = true
        save.EditData(unlocks,"Achievements")
        save.EditData(unlockQueue,"UnlockQueue")
    end
end

function Snowball.post_peffect_update()
    local saveData = save.GetData()
    if saveData.file.misc.UnlockQueue == nil then saveData.file.misc.UnlockQueue = {} end
    local unlockQueue = saveData.file.misc.UnlockQueue
    local unlocks = saveData.file.achievements
    local level = Game():GetLevel()
	local levelStage = level:GetStage()
	local room = Game():GetRoom()
    if unlocks.Scissors ~= true and Game():GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE)
	and (levelStage == LevelStage.STAGE3_1 or levelStage == LevelStage.STAGE3_2)
	then
        --util.QueueStore("gfx/ui/achievement/achievement_Rick_9.png",unlockQueue)  --Paper Rose Unlock
        unlocks.Scissors = true
    end
    if unlocks.RabbitFoot ~= true and Game():GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE)
	and levelStage == LevelStage.STAGE4_3
	then
        --util.QueueStore("gfx/ui/achievement/achievement_Rick_7.png",unlockQueue)  --Arrest Warrant Unlock
        unlocks.RabbitFoot = true
	end
    if Game():IsGreedMode()
	and levelStage == LevelStage.STAGE7_GREED
	then
		if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2
		and room:IsClear()
		then
			if unlocks.Buttons ~= true and Game().Difficulty == Difficulty.DIFFICULTY_GREED then
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_11.png",unlockQueue)  --Kind Soul Unlock
					unlocks.Buttons = true
                end
			elseif Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER then
                if unlocks.StitchUp ~= true then
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_12.png",unlockQueue)  --Love Letter Unlock
					unlocks.StitchUp = true
                elseif unlocks.Buttons ~= true then
                    --util.QueueStore("gfx/ui/achievement/achievement_Rick_11.png",unlockQueue)  --Kind Soul Unlock
					unlocks.Buttons = true
                end
			end
		end
    if not unlocks.Oblitus and unlocks.Snowball and unlocks.LooseThread and unlocks.SnowballTreat and unlocks.Patches and unlocks.SewingMachine and unlocks.OldDrawing and unlocks.PinsAndNeedles and unlocks.LostAndFound and unlocks.Scissors and unlocks.RabbitFoot and unlocks.StitchUp and unlocks.Buttons then
        util.QueueStore("gfx/ui/achievement/achievement_Rick_13.png",unlockQueue)  --SleepingPills Unlock
        unlocks.Oblitus = true
    end
    save.EditData(unlocks,"Achievements")
    save.EditData(unlockQueue,"UnlockQueue")
end

return Snowball