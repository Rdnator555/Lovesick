local rd = require("lovesick-src.RickHelper")
local enums = require("lovesick-src.LovesickEnums")
local getData = require("lovesick-src.getData")
local Faithfull = {}

function Faithfull:postPlayerUpdate(player)
    if player:GetPlayerType() ~= enums.PlayerType.Rick then return end
    --local p = rd.GetPlayerId(player)
    --local data = getData:GetPlayerData(player)
    --print(data.BaseRick.Pulse.Sprite:GetAnimation())

end

function Faithfull:postPlayerInit(player)
    player:SetPocketActiveItem(Isaac.GetItemIdByName("Locked Heart"), SLOT_POCKET, false)
    player:AddSmeltedTrinket(TrinketType.TRINKET_CROW_HEART, false)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA, 1)
end

---@param player EntityPlayer
---@param Offset Vector
function Faithfull:postPlayerRender(player, Offset)
    if player:GetPlayerType() ~= enums.PlayerType.Rick then return end
    local data = getData:GetPlayerData((player))
    local Pulse = data.BaseRick.Pulse.Sprite
    local Shield = data.BaseRick.Shield.Sprite
    local RickValues = data.BaseRick
    local defaultDMG
    local renderPos
    local HasSpiderMod = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_SPIDER_MOD)
    if LOVESICK.room:IsMirrorWorld() then 
        renderPos = Vector(480-Isaac.WorldToScreen(player.Position).X,Isaac.WorldToScreen(player.Position).Y) 
    else
        renderPos = Isaac.WorldToScreen(player.Position) 
    end
    Pulse:Render(Vector(renderPos.X,renderPos.Y + 9 ), Vector(0,0), Vector(0,0))
    if data.BaseRick.LockShield > 0 then 
        Faithfull.shielSpriteUpdate(player)
        Shield:Render(Vector(renderPos.X,renderPos.Y -24 ), Vector(0,0), Vector(0,0)) 
        Shield:Update()
    end

    if LOVESICK.level:GetStage() >= 7 and LOVESICK.persistentGameData:Unlocked(enums.Achievement.LOCKED_HEART_UPGRADE) == true then 
        defaultDMG = 2 else defaultDMG = 1 
    end
    
    if RickValues.Pulse.Time%30 == 0 and Game():GetFrameCount() ~= RickValues.Pulse.Time then
        if RickValues.CalmDelay > 0 then RickValues.CalmDelay = math.max(0,RickValues.CalmDelay - 1) end
        if RickValues.ShowPulseTime and RickValues.ShowPulseTime < 50 then RickValues.ShowPulseTime = math.max(0,RickValues.ShowPulseTime - 1) end
        if RickValues.CalmDelay <=0 and RickValues.LockShield == 0 then
            if RickValues.LockShield > 7.5*defaultDMG then RickValues.LockShield = RickValues.LockShield -1 end
            if RickValues.Stress > RickValues.StressMax/2 then
                if (RickValues.Stress - math.max(1/math.abs(player.Luck),player.Luck) ) < RickValues.StressMax/2 then 
                    RickValues.Stress = RickValues.StressMax/2
                else 
                    RickValues.Stress = math.floor(RickValues.Stress - math.max(1/math.abs(player.Luck),player.Luck)) 
                end                        
            else
                if (RickValues.Stress + math.max(1/math.abs(player.Luck),player.Luck) ) > RickValues.StressMax/2 then 
                    RickValues.Stress = RickValues.StressMax/2
                else 
                    RickValues.Stress = math.floor(RickValues.Stress + math.max(1/math.abs(player.Luck),player.Luck))
                end
            end
        end
        if RickValues.IsAdrenalineActive then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE,true)
            RickValues.Adrenaline = math.max(RickValues.Adrenaline -10,0)
            if RickValues.Adrenaline <= 0 then RickValues.IsAdrenalineActive = false end
        end
    end
    RickValues.Pulse.Time = Game():GetFrameCount()
    RickValues.FPS.Current = (30/(RickValues.Stress/3) ) 
    RickValues.FPS.New = math.floor(RickValues.Pulse.Time/RickValues.FPS.Current)
    --RickValues.Color = 
    if not Game():IsPaused() then
        if RickValues.FPS.New ~= RickValues.FPS.Old then
            Faithfull.heartBeat(player)
            RickValues.FPS.Old = RickValues.FPS.New
            Pulse:Update()
        end
    end
    if not LOVESICK.game:IsPaused() and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then 
        RickValues.ShowPulseTime = math.max(RickValues.ShowPulseTime, 15)
    end
    if not LOVESICK.game:IsPaused() and ((RickValues.ShowPulseTime > 0) ) then --[[not Game():IsPaused() and]]
        if RickValues.LockShield > 0 then
            if HasSpiderMod then --or (not settings.HideBPM and settings.ShieldNumberAlways)
                Isaac.RenderText(tostring(math.ceil(RickValues.LockShield)),renderPos.X+4.5,renderPos.Y+8, 0 , 0 ,0.5 ,0.8)
                Isaac.RenderText(tostring(math.floor(RickValues.Stress)),renderPos.X-14.5,renderPos.Y+8, RickValues.Color.R, RickValues.Color.G, RickValues.Color.B ,0.8)
            elseif false then  --settings.HideBPM and (not HasSpiderMod and settings.ShieldNumberAlways) then
                --print("2")
                Isaac.RenderText(tostring(math.ceil(RickValues.LockShield)),renderPos.X-8.5,renderPos.Y+8, 0 , 0 ,0.5 ,0.8)
            end
        elseif HasSpiderMod then   --HasSpiderMod or not settings.HideBPM)
                --print("3")
                Isaac.RenderText(tostring((math.floor(RickValues.Stress))),renderPos.X-8.5,renderPos.Y+8, RickValues.Color.R, RickValues.Color.G, RickValues.Color.B ,0.8)
            --[[if notsettings.HideBPM and (HasSpiderMod or not settings.HideBPM) then
                print("1")
                Isaac.RenderText(tostring(math.floor(RickValues.Stress)),renderPos.X-7,renderPos.Y+8, r ,g ,b ,0.8)
            elseif not settings.ShieldNumberAlways and (HasSpiderMod or not ) then
                print("2")
                Isaac.RenderText(tostring(math.floor(RickValues.Stress)),renderPos.X-16,renderPos.Y+8, r ,g ,b ,0.8)
            end
            print("3")
            Isaac.RenderText(tostring((math.floor(RickValues.Stress))),renderPos.X-7,renderPos.Y+8, r ,g ,b ,0.8)]]
        end
    end
end
---@param player EntityPlayer
---@param cacheFlag CacheFlag
---@param itemStats ItemStats
function Faithfull:AdrenalineDMG(player,cacheFlag,itemStats)
    if player:GetPlayerType() ~= enums.PlayerType.Rick 
    or not getData:GetPlayerData(player).BaseRick.IsAdrenalineActive then return end
    if rd.HasBitFlags(cacheFlag, CacheFlag.CACHE_DAMAGE) then
        itemStats.DAMAGE = itemStats.DAMAGE + math.floor(getData:GetPlayerData(player).BaseRick.Stress/100)
	end
end

function Faithfull:postUpdate(player)
    if player:GetPlayerType() ~= enums.PlayerType.Rick then return end
    local curTime = LOVESICK.game:GetFrameCount()

    local maxCharge = player:GetActiveMaxCharge(ActiveSlot.SLOT_POCKET)
    local minCharge = player:GetActiveMinUsableCharge(ActiveSlot.SLOT_POCKET)
    local charge = player:GetActiveCharge(ActiveSlot.SLOT_POCKET)  

    if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == enums.CollectibleType.LOCKED_HEART then
        local RickValues = getData:GetPlayerData(player).BaseRick
        local activeThreat = 0
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            local distance = math.floor(player.Position:Distance(ent.Position))
            if ent:IsActiveEnemy(false) then
                if distance < 100 then
                    activeThreat = activeThreat + 1
                end
            elseif ent.Type == EntityType.ENTITY_PROJECTILE then
                if distance < 100 then
                    activeThreat = activeThreat + 1
                end
            end
        end
        if activeThreat > 0 then
            RickValues.CalmDelay = math.max(5,RickValues.CalmDelay)
        end
        if charge < minCharge then
            RickValues.Adrenaline = RickValues.Adrenaline + activeThreat
        elseif maxCharge < charge then
            RickValues.Adrenaline = RickValues.Adrenaline + activeThreat*0.5
        end
        if RickValues.Pulse.Time%30 == 0 and Game():GetFrameCount() ~= RickValues.Pulse.Time then
            RickValues.Stress = math.min((RickValues.Stress + activeThreat * 0.5),RickValues.StressMax)
        end
    end
end

function Faithfull.shielSpriteUpdate(player)
    local data = getData:GetPlayerData(player)
    local RickValues = data.BaseRick
    local Morphine = data.Morphine
    local Shield = RickValues.Shield.Sprite
    if Morphine.Time == 0 then
        if math.ceil(RickValues.LockShield) >=15 then
            Shield:Play("15", true)
        elseif math.ceil(RickValues.LockShield) >= 14 then
            Shield:Play("14", true)
        elseif math.ceil(RickValues.LockShield) >= 13 then
            Shield:Play("13", true)
        elseif math.ceil(RickValues.LockShield) >= 12 then
            Shield:Play("12", true)
        elseif math.ceil(RickValues.LockShield) >= 11 then
            Shield:Play("11", true)
        elseif math.ceil(RickValues.LockShield) >= 10 then
            Shield:Play("10", true)
        elseif math.ceil(RickValues.LockShield) >= 9 then
            Shield:Play("9", true)
        elseif math.ceil(RickValues.LockShield) >= 8 then
            Shield:Play("8", true)
        elseif math.ceil(RickValues.LockShield) >= 7 then
            Shield:Play("7", true)
        elseif math.ceil(RickValues.LockShield) >= 6 then
            Shield:Play("6", true)
        elseif math.ceil(RickValues.LockShield) >= 5 then
            Shield:Play("5", true)
        elseif math.ceil(RickValues.LockShield) >= 4 then
            Shield:Play("4", true)
        elseif math.ceil(RickValues.LockShield) >= 3 then
            Shield:Play("3", true)
        elseif math.ceil(RickValues.LockShield) >= 2 then
            Shield:Play("2", true)
        elseif math.ceil(RickValues.LockShield) >= 1 then
            Shield:Play("1", true)
        end
    end
end

function Faithfull.heartBeat(player)
    local data = getData:GetPlayerData(player)
    local RickValues = data.BaseRick
    local Pulse = RickValues.Pulse.Sprite
            if player:HasCollectible(Isaac.GetItemIdByName("Locked Heart"), true) and RickValues.LockShield <= 0 and RickValues.CalmDelay <= 0 then
                --print("Charge heart")Pulse
                local charge=player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
                local subcharge = player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
                --print(charge,subcharge)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false) then
                    if subcharge < 15 then
                        player:SetActiveCharge(charge+subcharge+1, ActiveSlot.SLOT_POCKET)
                    end
                else
                    if charge < 15 then
                        player:SetActiveCharge(charge+1, ActiveSlot.SLOT_POCKET)
                    end
                end
            end
            if Pulse:IsFinished(Pulse:GetAnimation()) then
            if RickValues.Stress >=(5*RickValues.StressMax/6) then
                RickValues.Color = Color(1,0,0)
                Pulse:Play("High Stress", true)
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT_FASTER, Options.SFXVolume*1.2,  4, false, 1)
            elseif RickValues.Stress >=(4*RickValues.StressMax/6) then
                RickValues.Color = Color(0.5,0.5,0)
                Pulse:Play("Mid Stress", true) 
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT_FASTER, Options.SFXVolume,  4, false, 1)
            elseif RickValues.Stress >=(3*RickValues.StressMax/6) then
                RickValues.Color = Color(0,1,0)
                Pulse:Play("Low Stress", true)               
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT_FASTER, Options.SFXVolume,  4, false, 1)
            elseif RickValues.Stress >=(2*RickValues.StressMax/6) then
                RickValues.Color = Color(0,0.75,0.25)
                Pulse:Play("Normal", true)
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT, Options.SFXVolume*0.9,  4, false, 1)
            elseif RickValues.Stress >=(RickValues.StressMax/6) then
                RickValues.Color = Color(0,0.5,0.5)
                Pulse:Play("Low Pulse", true) 
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT, Options.SFXVolume*0.8,  4, false, 1)
            else
                RickValues.Color = Color(0,0.25,0.75)
                Pulse:Play("Lowest Pulse", true)
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT, Options.SFXVolume*0.6, 4, false, 1)
            end
    end
end

---@param ent Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
function Faithfull:entityTakeDamage(ent, amount, flags, source, countdown, player)
    if not player or player:GetPlayerType() ~= enums.PlayerType.Rick then return end
    local data = getData:GetPlayerData(player)
    local RickValues = data.BaseRick
    RickValues.CalmDelay = math.max(5,RickValues.CalmDelay)
    if source.Type == 2 and (RickValues.LockShield <= 0 or RickValues.Adrenaline >= 0) then
        if RickValues.Stress < RickValues.StressMax then
            RickValues.Stress = RickValues.Stress +  player.Damage*0.8
        end
    elseif source.Type == 1 and (RickValues.LockShield <= 0 or RickValues.Adrenaline >= 0) then
        if RickValues.Stress < RickValues.StressMax then
            RickValues.Stress = RickValues.Stress +  player.Damage*0.6
        end
    elseif (RickValues.LockShield <= 0 or RickValues.Adrenaline == true) then
        if RickValues.Stress < RickValues.StressMax then
            RickValues.Stress = RickValues.Stress +  player.Damage*0.75
        end
    end    
    if RickValues.Stress > RickValues.StressMax then
        RickValues.Stress = RickValues.StressMax
    end
    local entityData = getData:GetEntityData(ent)
    local RickEntityData = entityData.BaseRick
    local pierceDMG = (math.floor(10+((RickValues.Stress-RickValues.StressMax/2)/6)))/10+(RickEntityData.Heartache/25)
    local stressDMG = math.max(0,(math.floor((RickValues.Stress)/6)/500) * (ent.MaxHitPoints - ent.HitPoints)/10)  
    if RickEntityData.Delay < ent.FrameCount then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then 
            ent:TakeDamage((amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(ent), 0)
            if ent:HasMortalDamage() or ent.HitPoints <= ((amount * pierceDMG) + stressDMG) then
                local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 0, ent.Position, Vector(0,0), nil)
                heart:ToPickup().Timeout = 60 
                ent:BloodExplode()
                --game:BombDamage(ent.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                local enemies = Isaac.FindInRadius(ent.Position, 40, EntityPartition.ENEMY)
                for _, enemy in ipairs(enemies) do
                    if enemy:IsVulnerableEnemy()then
                        enemy:TakeDamage(player.Damage, 0, EntityRef(ent), 0)
                    end
                end
                --if newHeart ~= nil then newHeart:ToPickup().Timeout = 25 end
            end
        elseif (ent:HasMortalDamage() or ent.HitPoints <= ((amount * pierceDMG) + stressDMG)) and RickValues.Adrenaline > 0 then
                ent:BloodExplode()
                --game:BombDamage(ent.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                local enemies = Isaac.FindInRadius(ent.Position, 40, EntityPartition.ENEMY)
                for _, enemy in ipairs(enemies) do
                    if enemy:IsVulnerableEnemy()then
                        enemy:TakeDamage(player.Damage, 0, EntityRef(ent), 0)    
                    end
                end                    
        else
            ent:TakeDamage((amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(ent), 0)
        end
        RickEntityData.Delay = ent.FrameCount + player.MaxFireDelay*5
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        RickEntityData.Heartache = ent.HitPoints/ent.MaxHitPoints*20
    else
        RickEntityData.Heartache = ent.HitPoints/ent.MaxHitPoints*10
    end
end

---@param ent Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
---@param player EntityPlayer
function Faithfull:playerTakeDamage(ent, amount, flags, source, countdown, player)
    local data = getData:GetPlayerData(player)
    ---@class RickPlayers
    ---@field Player EntityPlayer
    ---@field Shield integer
    ---@type RickPlayers[]
    local RickPlayers = {}
    local maxShield = 0
    local totalShield = 0
    local maxShieldPlayer = nil
    local val = nil
    local oldAmount = amount
    if player:GetPlayerType() == enums.PlayerType.Rick then
        print(rd.HasBitFlags(flags,DamageFlag.DAMAGE_CLONES))
        if rd.HasBitFlags(flags,DamageFlag.DAMAGE_CLONES) then print(amount,"IsCloneDMG") return end
        local stressDiff = math.abs(math.max(data.BaseRick.StressMax/2)-data.BaseRick.Stress,0)
        local multiplier = math.floor(stressDiff/30)
        amount = amount * multiplier
    end
    for n=0, LOVESICK.game:GetNumPlayers()-1 do
        local indexedplayer = Isaac.GetPlayer(n)
        local index = rd.GetPlayerId(indexedplayer)
        local indexedData = getData:GetPlayerData(indexedplayer)
        if player or player:GetPlayerType() == enums.PlayerType.Rick then
            local indexedRickData = indexedData.BaseRick
            if indexedRickData.LockShield > 0 then
                totalShield = totalShield + indexedRickData.LockShield
                if indexedRickData.LockShield > maxShield then 
                    maxShield = indexedRickData.LockShield 
                    maxShieldPlayer = indexedplayer
                    table.insert(RickPlayers, {Shield = indexedRickData.LockShield, Player = indexedplayer})
                end
            end
            print(#RickPlayers, maxShield, totalShield)
        end
    end
    
    if maxShieldPlayer 
    and ((not(rd.HasBitFlags(flags, DamageFlag.DAMAGE_NO_PENALTIES) or rd.HasBitFlags(flags, DamageFlag.DAMAGE_RED_HEARTS) 
    and ((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())>amount)))
    or ((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())<amount)
    or ((player:GetPlayerType()== PlayerType.PLAYER_KEEPER or player:GetPlayerType()==PlayerType.PLAYER_KEEPER_B)
    and totalShield > 0) or rd.HasBitFlags(flags, DamageFlag.DAMAGE_CURSED_DOOR)) then
        local shielderData = getData:GetPlayerData(maxShieldPlayer)
        local shielderRickValues = shielderData.BaseRick
        if math.ceil(maxShield) >= amount then
            player:SetMinDamageCooldown(math.max(player:GetDamageCooldown(),60))
            
            if player.DropSeed ~= maxShieldPlayer.DropSeed then
                player:AnimateSad()
                maxShieldPlayer:AnimateHappy()
                maxShieldPlayer:SetMinDamageCooldown(math.max(maxShieldPlayer:GetDamageCooldown(),30))
            else
                player:AnimateSad()
            end
            shielderRickValues.LockShield = math.max(0,shielderRickValues.LockShield - amount)
            val = val or false
        else
            player:SetMinDamageCooldown(math.max(player:GetDamageCooldown(),30))
            if player.DropSeed ~= maxShieldPlayer.DropSeed then
                player:AnimateSad()
                maxShieldPlayer:AnimateHappy()
                maxShieldPlayer:SetMinDamageCooldown(math.max(maxShieldPlayer:GetDamageCooldown(),15))
            else
                player:AnimateSad()
            end
            shielderRickValues.LockShield = 0
            val = val or false
        end
        shielderRickValues.CalmDelay = math.max(5,shielderRickValues.CalmDelay)
    end
    if player:GetPlayerType() == enums.PlayerType.Rick and (val == nil or val == true) then
        local RickValues = getData:GetPlayerData(player).BaseRick
        RickValues.Stress = math.max(0,RickValues.Stress - math.max(15,RickValues.Stress*1/3))
        RickValues.CalmDelay = math.max(5,RickValues.CalmDelay)
        if not rd.HasBitFlags(flags,DamageFlag.DAMAGE_CLONES) then
            print(amount)
            player:TakeDamage(amount,DamageFlag.DAMAGE_CLONES|flags,source,countdown)
            val = val or false
        end
        if RickValues.Stress<=0 then player:Die() end
    end
    return val
end

return Faithfull