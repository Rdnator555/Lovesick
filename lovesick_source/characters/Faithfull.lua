local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local achievements = require("lovesick_source.achievements")
local Item = enums.Item
local Trinket = enums.Trinket
local PlayerType = enums.PlayerType
local Faithfull = {}
local Monitor = {}
local Shield = {}
local saveData
local oldSecs = {}

function Faithfull.post_player_update(player,saveData,data)
    local p = util.getPlayerIndex(player)
    local data = save.GetData()
    if p and data.run.persistent.Init and data.run.persistent.Init[p]== nil then
        Faithfull.sprite_preload(p)
        saveData.run.persistent.Init[p]= true
        local Base = {
            StressMax={},
            Stress={},
            ShowPulseTime={},
            CalmDelay={},
            LockShield={},
            FPS = {},
            OldFPS = {},
            NewFPS = {},
            HitCharge = {},
            Adrenaline = {},
            Tired = {},
            Color =  {},
        }
        if saveData.run.persistent.RickValues == nil then
            saveData.run.persistent.RickValues = Base
            local RickValues = saveData.run.persistent.RickValues
            if p then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then 
                    RickValues.StressMax[p] = 360 else RickValues.StressMax[p] = 240 
                end
                RickValues.Stress[p] = RickValues.StressMax[p]/2
                RickValues.ShowPulseTime[p] = 12
                RickValues.CalmDelay[p] = 5
                if RickValues.LockShield[p] == nil then
                    RickValues.LockShield[p] = 0
                end
                RickValues.FPS[p] = 0
                RickValues.OldFPS[p] = 0
                RickValues.NewFPS[p] = nil
                if RickValues.HitCharge[p] == nil then
                    RickValues.HitCharge[p] = 0
                end
                if RickValues.Adrenaline[p] == nil then
                    RickValues.Adrenaline[p] = 0
                end
                if RickValues.Tired[p] == nil then
                    RickValues.Tired[p] = 0
                end
                if RickValues.Color[p] == nil then RickValues.Color[p] = 2 end
            end
            saveData.run.persistent.RickValues = RickValues
        end
        save.SaveModData()
    end
end

function Faithfull.sprite_preload(p)
    if p then
        if Monitor[p]==nil then
            Monitor[p] = Sprite()
            Monitor[p]:Load("gfx/ui/other/heartbeatsprite.anm2", true) --resources\gfx\ui\other\Shield.anm2
            Monitor[p]:Play("Low Stress", true)
            --print(p,"Monitor",Monitor[p])
        end
        if Shield[p]== nil then
            Shield[p] = Sprite()
            Shield[p]:Load("gfx/ui/other/Shield.anm2", true)
            Shield[p]:Play("1", true)
            --print(p,"Shield",Shield[p])
        end
    end
end

function Faithfull.post_player_init(data,player)
    player:SetPocketActiveItem(Isaac.GetItemIdByName("Locked Heart"), SLOT_POCKET, false)
    player:AddBoneHearts(1)
    player:AddHearts(2)
    player:AddSoulHearts(2)
    player:AddTrinket(TrinketType.TRINKET_CROW_HEART, false)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false, ActiveSlot.SLOT_PRIMARY)
    util.addItem(CollectibleType.COLLECTIBLE_GLAUCOMA, false, true, player)
end

function Faithfull.on_player_render(player)
    --saveData = save.GetData()
    --local p = util.getPlayerIndex(player)
    --if p and not player:IsCoopGhost() then
    --    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then saveData.run.persistent.RickValues.StressMax[p] = 360 else saveData.run.persistent.RickValues.StressMax[p] = 240 end
    --end
    --save.EditData(saveData)
end

function Faithfull.post_render(player)
    local curTime = Game():GetFrameCount()
    local renderPos 
    local p = util.getPlayerIndex(player)
    saveData = save.GetData()
    local RickValues = saveData.run.persistent.RickValues
    local settings = saveData.file.settings
    local HasSpiderMod = util.AnyHasCollectible(CollectibleType.COLLECTIBLE_SPIDER_MOD,true)
    if Game():GetRoom():IsMirrorWorld() then 
        renderPos = Vector(480-Isaac.WorldToScreen(player.Position).X,Isaac.WorldToScreen(player.Position).Y) 
    else
        renderPos = Isaac.WorldToScreen(player.Position) 
    end
    if oldSecs[p] == nil then oldSecs[p] = Game():GetFrameCount() end
    if Game():GetFrameCount()%30 == 0 and Game():GetFrameCount() ~= oldSecs[p] then
        local defaultDMG
        local stage = Game():GetLevel():GetStage()
        if saveData.file.misc.UnlockQueue == nil then saveData.file.misc.UnlockQueue = {} end
        local unlocks = saveData.file.misc.UnlockQueue
        if stage >= 7 and unlocks.LockedHeart1 == true then defaultDMG = 2 else defaultDMG = 1 end
        oldSecs[p] = Game():GetFrameCount()
        if RickValues.CalmDelay[p] then RickValues.CalmDelay[p] = math.max(0,RickValues.CalmDelay[p] - 1) end
        if RickValues.ShowPulseTime[p] and RickValues.ShowPulseTime[p]< 50 then RickValues.ShowPulseTime[p] = math.max(0,RickValues.ShowPulseTime[p] - 1) end
        if RickValues.CalmDelay[p] <=0 and RickValues.LockShield[p] then
            if RickValues.LockShield[p]>7.5*defaultDMG then RickValues.LockShield[p] = RickValues.LockShield[p] -1 end
            if RickValues.Stress[p] > RickValues.StressMax[p]/2 then
                if (RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck) ) < RickValues.StressMax[p]/2 then 
                    RickValues.Stress[p] = RickValues.StressMax[p]/2
                    --print("1")
                else RickValues.Stress[p] = math.floor(RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck)) 
                    --print("2")
                end                        
            else
                if (RickValues.Stress[p] + math.max(1/math.abs(player.Luck),player.Luck) ) > RickValues.StressMax[p]/2 then 
                    RickValues.Stress[p] = RickValues.StressMax[p]/2
                    --print("3")
                else RickValues.Stress[p] = math.floor(RickValues.Stress[p] + math.max(1/math.abs(player.Luck),player.Luck))
                    --print("4",p, player.Position, player.Luck)
                end
            end
        end
    end
    if RickValues and achievements.idle_timer <= 0 then
        Faithfull.sprite_preload(p)
        if RickValues.ShowPulseTime and RickValues.ShowPulseTime[p]> 0 then 
            Monitor[p]:Render(Vector(renderPos.X,renderPos.Y + 9 ), Vector(0,0), Vector(0,0))
        end
        if RickValues.LockShield and RickValues.LockShield[p] > 0 then
            Shield[p]:Render(Vector(renderPos.X,renderPos.Y -24 ), Vector(0,0), Vector(0,0))                
        end
    end
    if p then 
        RickValues.FPS[p] = (30/(RickValues.Stress[p]/3) ) 
        RickValues.NewFPS[p] = math.floor(curTime/RickValues.FPS[p])
    end
    ----[[
    if not Game():IsPaused() then
        if RickValues.NewFPS[p] ~= RickValues.OldFPS[p] then
            Faithfull.heart_beat(player)
            RickValues.OldFPS[p] = RickValues.NewFPS[p]
            Monitor[p]:Update()
        end
    end
    --]] 
    local r = 0
    local g = 0
    local b = 0
    if RickValues.Color[p] == 5 then r=1 g=0 b=0 
    elseif RickValues.Color[p] == 4 then r=0.5 g=0.5 b=0
    elseif RickValues.Color[p] == 3 then r=0 g=1 b=0
    elseif RickValues.Color[p] == 2 then r=0 g=0.75 b=0.25
    elseif RickValues.Color[p] == 1 then r=0 g=0.5 b=0.5
    elseif RickValues.Color[p] == 0 then r=0 g=0.25 b=0.75
    else r=0 g=0 b=1 end
    if (RickValues.ShowPulseTime[p] > 0 or Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) and achievements.idle_timer <= 0 then
        if RickValues.LockShield[p]> 0 and (HasSpiderMod or settings.ShieldNumberAlways) then
        else
        end
        if RickValues.LockShield[p]> 0 and (HasSpiderMod or not settings.HideBPM) then

        end
    end
    if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then 
        RickValues.ShowPulseTime[p] = math.max(RickValues.ShowPulseTime[p],saveData.file.settings.TimeBPM)
    end
    if --[[not Game():IsPaused() and]] ((RickValues.ShowPulseTime[p] > 0) and achievements.idle_timer <= 0) then
        if RickValues.LockShield[p]> 0 then
            if HasSpiderMod or (not settings.HideBPM and settings.ShieldNumberAlways) then
                --print("1")
                Isaac.RenderText(tostring(math.ceil(RickValues.LockShield[p])),renderPos.X+4.5,renderPos.Y+8, 0 , 0 ,0.5 ,0.8)
                Isaac.RenderText(tostring(math.floor(RickValues.Stress[p])),renderPos.X-14.5,renderPos.Y+8, r ,g ,b ,0.8)
            elseif settings.HideBPM and (not HasSpiderMod and settings.ShieldNumberAlways) then
                --print("2")
                Isaac.RenderText(tostring(math.ceil(RickValues.LockShield[p])),renderPos.X-8.5,renderPos.Y+8, 0 , 0 ,0.5 ,0.8)
            end
        elseif (HasSpiderMod or not settings.HideBPM) then
                --print("3")
                Isaac.RenderText(tostring((math.floor(RickValues.Stress[p]))),renderPos.X-8.5,renderPos.Y+8, r ,g ,b ,0.8)
            --[[if notsettings.HideBPM and (HasSpiderMod or not settings.HideBPM) then
                print("1")
                Isaac.RenderText(tostring(math.floor(RickValues.Stress[p])),renderPos.X-7,renderPos.Y+8, r ,g ,b ,0.8)
            elseif not settings.ShieldNumberAlways and (HasSpiderMod or not ) then
                print("2")
                Isaac.RenderText(tostring(math.floor(RickValues.Stress[p])),renderPos.X-16,renderPos.Y+8, r ,g ,b ,0.8)
            end
            print("3")
            Isaac.RenderText(tostring((math.floor(RickValues.Stress[p]))),renderPos.X-7,renderPos.Y+8, r ,g ,b ,0.8)]]
        end
    end
    --saveData.run.persistent.RickValues = RickValues
    save.EditData(RickValues,"RickValues")
end

function Faithfull.post_update(player)
    local p = util.getPlayerIndex(player)
    if Shield[p] then Shield[p]:Update() end
    Faithfull.sprite_preload(p)
    Faithfull.shield_sprite_select(player)
    --Faithfull.heart_beat(player)
end

function Faithfull.morphine_update(player)
    local p = util.getPlayerIndex(player)
    saveData = save.GetData()
    local persistent = saveData.run.persistent
    local renderPos
    if Game():GetRoom():IsMirrorWorld() then 
        renderPos = Vector(480-Isaac.WorldToScreen(player.Position).X,Isaac.WorldToScreen(player.Position).Y) 
    else
        renderPos = Isaac.WorldToScreen(player.Position) 
    end
    if Shield[p]== nil then
        Shield[p] = Sprite()
        Shield[p]:Load("gfx/ui/other/Shield.anm2", true)
        Shield[p]:Play("6-b", true)
        --print(p,"Shield",Shield[p])
    end
    if persistent.MorphineTime and persistent.MorphineTime[p] > 0 then
        if achievements.idle_timer <= 0  then 
            Shield[p]:Render(Vector(renderPos.X,renderPos.Y -24 ), Vector(0,0), Vector(0,0)) 
    elseif not Game():IsPaused() and Game():GetFrameCount()%10==0 then
            Shield[p]:Update() 
        end
    end
    Faithfull.shield_sprite_select(player)
end

function Faithfull.shield_sprite_select(player)
    local p = util.getPlayerIndex(player)
    saveData = save.GetData()
    local RickValues = saveData.run.persistent.RickValues
    local runSave = saveData.run
    if runSave then
        if runSave.persistent.MorphineTime == nil then runSave.persistent.MorphineTime = {} end
        if runSave.persistent.MorphineTime[p] == nil then runSave.persistent.MorphineTime[p] = 0 end
        if Shield[p] and Shield[p]:IsFinished(Shield[p]:GetAnimation()) then
            --print("IsFinished")
            if runSave.persistent.MorphineTime[p] and runSave.persistent.MorphineTime[p] > 0 then
            if runSave.persistent.MorphineTime[p] >= 90 then
                Shield[p]:Play("90-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 84 then
                Shield[p]:Play("84-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 78 then
                Shield[p]:Play("78-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 72 then
                Shield[p]:Play("72-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 66 then
                Shield[p]:Play("66-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 60 then
                Shield[p]:Play("60-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 54 then
                Shield[p]:Play("54-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 48 then
                Shield[p]:Play("48-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 42 then
                Shield[p]:Play("42-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 36 then
                Shield[p]:Play("36-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 30 then
                Shield[p]:Play("30-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 24 then
                Shield[p]:Play("24-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 18 then
                Shield[p]:Play("18-b", true)
            elseif runSave.persistent.MorphineTime[p] >= 12 then
                Shield[p]:Play("12-b", true)
            elseif runSave.persistent.MorphineTime[p] > 0 then
                Shield[p]:Play("6-b", true)
            end
            elseif player:GetPlayerType() == enums.PlayerType.Faithfull and RickValues then
                if math.ceil(RickValues.LockShield[p]) >=15 then
                    Shield[p]:Play("15", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 14 then
                    Shield[p]:Play("14", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 13 then
                    Shield[p]:Play("13", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 12 then
                    Shield[p]:Play("12", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 11 then
                    Shield[p]:Play("11", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 10 then
                    Shield[p]:Play("10", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 9 then
                    Shield[p]:Play("9", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 8 then
                    Shield[p]:Play("8", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 7 then
                    Shield[p]:Play("7", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 6 then
                    Shield[p]:Play("6", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 5 then
                    Shield[p]:Play("5", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 4 then
                    Shield[p]:Play("4", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 3 then
                    Shield[p]:Play("3", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 2 then
                    Shield[p]:Play("2", true)
                elseif math.ceil(RickValues.LockShield[p]) >= 1 then
                    Shield[p]:Play("1", true)
                end
            end
        end        
    end
end

function Faithfull.heart_beat(player)
    local p = util.getPlayerIndex(player)
    saveData = save.GetData()
    local RickValues = saveData.run.persistent.RickValues
        --print("heartbeat", p,RickValues.newFPS[p])
        if RickValues.NewFPS[p]~=RickValues.OldFPS[p] then
            --print("Heartbeat of ",p)
            if player:HasCollectible(Isaac.GetItemIdByName("Locked Heart"), true) and RickValues.LockShield[p] <= 0 and RickValues.CalmDelay[p] <= 0 then
                --print("Charge heart")Monitor
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
            if Monitor[p]:IsFinished(Monitor[p]:GetAnimation()) then
            if RickValues.Stress[p] >=(5*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 5
                Monitor[p]:Play("High Stress", true)
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT_FASTER, Options.SFXVolume*1.2,  4, false, 1)
            elseif RickValues.Stress[p] >=(4*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 4
                Monitor[p]:Play("Mid Stress", true) 
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT_FASTER, Options.SFXVolume,  4, false, 1)
            elseif RickValues.Stress[p] >=(3*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 3
                Monitor[p]:Play("Low Stress", true)               
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT_FASTER, Options.SFXVolume,  4, false, 1)
            elseif RickValues.Stress[p] >=(2*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 2
                Monitor[p]:Play("Normal", true)
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT, Options.SFXVolume*0.9,  4, false, 1)
            elseif RickValues.Stress[p] >=(RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 1
                Monitor[p]:Play("Low Pulse", true) 
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT, Options.SFXVolume*0.8,  4, false, 1)
            else
                RickValues.Color[p] = 0
                Monitor[p]:Play("Lowest Pulse", true)
                SFXManager():Play(SoundEffect.SOUND_HEARTBEAT, Options.SFXVolume*0.6, 4, false, 1)
            end
        end
    end
end

function Faithfull.on_dealt_dmg(Entity,Amount,DamageFlags,Source,player)
    local p = util.getPlayerIndex(player)
    saveData = save.GetData()
    local entityData = Entity:GetData()
    local RickValues = saveData.run.persistent.RickValues
    RickValues.CalmDelay[p] = math.max(5,RickValues.CalmDelay[p])
    if Source.Type == 2 and (RickValues.LockShield[p] <= 0 or RickValues.Adrenaline[p] == true) then
        if RickValues.Stress[p] < RickValues.StressMax[p] then
            RickValues.Stress[p] = RickValues.Stress[p] +  player.Damage*0.8
            if RickValues.Stress[p] > RickValues.StressMax[p] then
                RickValues.Stress[p] = RickValues.StressMax[p]
            end
        end
    elseif Source.Type == 1 and (RickValues.LockShield[p] <= 0 or RickValues.Adrenaline[p] == true) then
        if RickValues.Stress[p] < RickValues.StressMax[p] then
            RickValues.Stress[p] = RickValues.Stress[p] +  player.Damage*0.6
            if RickValues.Stress[p] > RickValues.StressMax[p] then
                RickValues.Stress[p] = RickValues.StressMax[p]
            end
        end
    elseif (RickValues.LockShield[p] <= 0 or RickValues.Adrenaline[p] == true) then
        if RickValues.Stress[p] < RickValues.StressMax[p] then
            RickValues.Stress[p] = RickValues.Stress[p] +  player.Damage*0.75
            if RickValues.Stress[p] > RickValues.StressMax[p] then
                RickValues.Stress[p] = RickValues.StressMax[p]
            end
        end
    end
    if entityData.Heartache == nil then entityData.Heartache = {} end
    if entityData.Delay == nil then entityData.Delay = {} end
    if RickValues.ShowPulseTime[p] then RickValues.ShowPulseTime[p] = math.max(RickValues.ShowPulseTime[p],saveData.file.settings.TimeBPM) end
    if entityData.Heartache[p] == nil then entityData.Heartache[p] = 0 end
    local pierceDMG = (math.floor(10+((RickValues.Stress[p]-RickValues.StressMax[p]/2)/6)))/10+(entityData.Heartache[p]/25)
    local stressDMG = math.max(0,(math.floor((RickValues.Stress[p])/6)/500) * (Entity.MaxHitPoints - Entity.HitPoints)/10)    
    if entityData.Heartache and entityData.Delay then
        if entityData.Delay[p] == nil then entityData.Delay[p] = 0 end
        --print(entityData.Delay[p] < Entity.FrameCount)
        if entityData.Delay[p] < Entity.FrameCount then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then 
                Entity:TakeDamage((Amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)
                if Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG) then
                    local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 0, Entity.Position, Vector(0,0), nil)
                    heart:ToPickup().Timeout = 60 
                    Entity:BloodExplode()
                    --game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                    local enemies = Isaac.FindInRadius(Entity.Position, 40, EntityPartition.ENEMY)
                    for _, enemy in ipairs(enemies) do
                        if enemy:IsVulnerableEnemy()then
                            enemy:TakeDamage(player.Damage, 0, EntityRef(Entity), 0)
                        end
                    end
                    --if newHeart ~= nil then newHeart:ToPickup().Timeout = 25 end
                end
            elseif (Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG)) and RickValues.Adrenaline[p] == true then
                    Entity:BloodExplode()
                    --game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                    local enemies = Isaac.FindInRadius(Entity.Position, 40, EntityPartition.ENEMY)
                    for _, enemy in ipairs(enemies) do
                        if enemy:IsVulnerableEnemy()then
                            enemy:TakeDamage(player.Damage, 0, EntityRef(Entity), 0)    
                        end
                    end                    
            else
                Entity:TakeDamage((Amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)
            end
            entityData.Delay[p] = Entity.FrameCount + player.MaxFireDelay*5
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
            entityData.Heartache[p] = Entity.HitPoints/Entity.MaxHitPoints*20
        else
            entityData.Heartache[p] = Entity.HitPoints/Entity.MaxHitPoints*10
        end
    end
    save.EditData(RickValues,"RickValues")
    --saveData.run.persistent.RickValues = RickValues
    --save.EditData(saveData)
end

function Faithfull.entity_take_dmg(player,Amount,DamageFlags)
    local p = util.getPlayerIndex(player)
    saveData = save.GetData()
    local RickValues = saveData.run.persistent.RickValues
    if RickValues == nil then return end
    local ShieldPlayerIndex = nil
    local ShieldPlayer = nil
    local ShieldValue = 0
    local value = nil
    for n=0, Game():GetNumPlayers()-1 do
        local index = util.getPlayerIndex(Isaac.GetPlayer(n))
        if RickValues.LockShield and RickValues.LockShield[index] then
            if RickValues.LockShield[index] > ShieldValue then
                ShieldPlayerIndex = index
                ShieldPlayer = Isaac.GetPlayer(n)
                ShieldValue = RickValues.LockShield[index]
            end
        end
    end
    if not (DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES ~= 0 or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS ~= 0) and ((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())>Amount or ((player:GetPlayerType()== PlayerType.PLAYER_KEEPER or player:GetPlayerType()==PlayerType.PLAYER_KEEPER_B)) and ShieldValue>0) and DamageFlags & DamageFlag.DAMAGE_CURSED_DOOR == 0  then
        if ShieldPlayerIndex then
            if math.ceil(RickValues.LockShield[ShieldPlayerIndex]) >= Amount then
                player:AnimateHappy()
                player:SetMinDamageCooldown(60)
                if player.DropSeed ~= ShieldPlayer.DropSeed then
                    ShieldPlayer:AnimateSad()
                    ShieldPlayer:SetMinDamageCooldown(30)
                end
                RickValues.LockShield[ShieldPlayerIndex] = math.max(0,RickValues.LockShield[ShieldPlayerIndex] - Amount)
                value = value or false
            else
                player:AnimateHappy()
                player:SetMinDamageCooldown(30)
                if player.DropSeed ~= ShieldPlayer.DropSeed then
                    ShieldPlayer:AnimateSad()
                    ShieldPlayer:SetMinDamageCooldown(15)
                end
                RickValues.LockShield[ShieldPlayerIndex] = 0
                value = value or false
            end
            RickValues.CalmDelay[ShieldPlayerIndex]=math.max(5,RickValues.CalmDelay[ShieldPlayerIndex])
        end
        if player:GetPlayerType() == enums.PlayerType.Faithfull and not value == false then
            RickValues.Stress[p] = math.max(0,RickValues.Stress[p] - math.max(15,RickValues.Stress[p]*1/3))
            RickValues.CalmDelay[p] = math.max(5,RickValues.CalmDelay[p])
            --RickValues.ShowPulseTime[p] = math.max(saveData.file.settings.TimeBPM,RickValues.ShowPulseTime[p])
            if RickValues.Stress[p]<=0 then player:Die() end
        end
    end
    --saveData.run.persistent.RickValues = RickValues
    --save.EditData(saveData)
    save.EditData(RickValues,"RickValues")
    return value
end

function Faithfull.unlocks_NPC(npc)
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
                if unlocks.LockedHeart1 ~= true then --Isaac/Cathedral
                    --LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_1.png")
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_1.png",unlockQueue)  --Lockedheart shield upgrade after womb Unlock
                    unlocks.LockedHeart1 = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            elseif npc.Type == EntityType.ENTITY_SATAN then
                if unlocks.NeckGaiter ~= true then
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_4.png",unlockQueue)  --Neck Gaiter Unlock
                    unlocks.NeckGaiter = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            end
        elseif levelStage == LevelStage.STAGE6 then
            if npc.Type == EntityType.ENTITY_ISAAC
            and npc.Variant == 1
            then
                if unlocks.LockedHeart2 ~= true then
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_1.png",unlockQueue)  --Adrenaline Rush Unlock
                    unlocks.LockedHeart2 = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            elseif npc.Type == EntityType.ENTITY_THE_LAMB then
                if unlocks.PaintingKit ~= true then
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_3.png",unlockQueue)  --Painting Kit Unlock
                    unlocks.PaintingKit = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            elseif npc.Type == EntityType.ENTITY_MEGA_SATAN_2 then
                if unlocks.BoxOfLeftovers ~= true then
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_10.png",unlockQueue)  --Box of Leftovers Unlock
                    unlocks.BoxOfLeftovers = true
                    save.EditData(unlocks,"Achievements")
                    save.EditData(unlockQueue,"UnlockQueue")
                end
            end
        elseif levelStage == LevelStage.STAGE7
        and npc.Type == EntityType.ENTITY_DELIRIUM
        then
            if unlocks.SunsetClock ~= true then
                util.QueueStore("gfx/ui/achievement/achievement_Rick_5.png",unlockQueue)  --Sunset Clock Unlock
                unlocks.SunsetClock = true
                save.EditData(unlocks,"Achievements")
                save.EditData(unlockQueue,"UnlockQueue")
            end
        elseif (levelStage == LevelStage.STAGE4_1 or levelStage == LevelStage.STAGE4_2)
        and npc.Type == EntityType.ENTITY_MOTHER
        and npc.Variant == 10
        then
            if unlocks.BirthdayCake ~= true then
                util.QueueStore("gfx/ui/achievement/achievement_Rick_6.png",unlockQueue)  --Birthday Cake Unlock
                unlocks.BirthdayCake = true
                save.EditData(unlocks,"Achievements")
                save.EditData(unlockQueue,"UnlockQueue")
            end
        end
    end
end

function Faithfull.post_entity_kill(entity)
	if Game():GetVictoryLap() > 0 then return end
	if entity.Type ~= EntityType.ENTITY_BEAST then return end
	if entity.Variant ~= 0 then return end
    local saveData = save.GetData()
    if saveData.file.misc.UnlockQueue == nil then saveData.file.misc.UnlockQueue = {} end
    local unlockQueue = saveData.file.misc.UnlockQueue
    local unlocks = saveData.file.achievements
    if unlocks.Morphine ~= true then
        util.QueueStore("gfx/ui/achievement/achievement_Rick_8.png",unlockQueue)  --Morphine Unlock
        unlocks.Morphine = true
        save.EditData(unlocks,"Achievements")
        save.EditData(unlockQueue,"UnlockQueue")
    end
end

function Faithfull.post_peffect_update()
    local saveData = save.GetData()
    if saveData.file.misc.UnlockQueue == nil then saveData.file.misc.UnlockQueue = {} end
    local unlockQueue = saveData.file.misc.UnlockQueue
    local unlocks = saveData.file.achievements
    local level = Game():GetLevel()
	local levelStage = level:GetStage()
	local room = Game():GetRoom()
    if unlocks.PaperRose ~= true and Game():GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE)
	and (levelStage == LevelStage.STAGE3_1 or levelStage == LevelStage.STAGE3_2)
	then
        util.QueueStore("gfx/ui/achievement/achievement_Rick_9.png",unlockQueue)  --Paper Rose Unlock
        unlocks.PaperRose = true
    end
    if unlocks.ArrestWarrant ~= true and Game():GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE)
	and levelStage == LevelStage.STAGE4_3
	then
        util.QueueStore("gfx/ui/achievement/achievement_Rick_7.png",unlockQueue)  --Arrest Warrant Unlock
        unlocks.ArrestWarrant = true
	end
    if Game():IsGreedMode()
	and levelStage == LevelStage.STAGE7_GREED
	then
		if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2
		and room:IsClear()
		then
			if unlocks.KindSoul ~= true and Game().Difficulty == Difficulty.DIFFICULTY_GREED then
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_11.png",unlockQueue)  --Kind Soul Unlock
					unlocks.KindSoul = true
                end
			elseif Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER then
                if unlocks.LoveLetter ~= true then
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_12.png",unlockQueue)  --Love Letter Unlock
					unlocks.LoveLetter = true
                elseif unlocks.KindSoul ~= true then
                    util.QueueStore("gfx/ui/achievement/achievement_Rick_11.png",unlockQueue)  --Kind Soul Unlock
					unlocks.KindSoul = true
                end
			end
		end
    if not unlocks.SleepingPills and unlocks.LockedHeart1 and unlocks.LockedHeart2 and unlocks.NeckGaiter and unlocks.PaintingKit and unlocks.BoxOfLeftovers and unlocks.SunsetClock and unlocks.BirthdayCake and unlocks.Morphine and unlocks.ArrestWarrant and unlocks.PaperRose and unlocks.KindSoul and unlocks.LoveLetter then
        util.QueueStore("gfx/ui/achievement/achievement_Rick_13.png",unlockQueue)  --SleepingPills Unlock
        unlocks.SleepingPills = true
    end
    save.EditData(unlocks,"Achievements")
    save.EditData(unlockQueue,"UnlockQueue")
end

return Faithfull