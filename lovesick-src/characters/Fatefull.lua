local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local achievements = require("lovesick_source.achievements")
local PlayerType = enums.PlayerType
local Fatefull = {}
local Sheet = {}
local Notes = {}
local saveData
local oldSecs = {}

function Fatefull.post_player_update(player,saveData,data)
    local p = util.getPlayerIndex(player)
    local data = save.GetData()
    if p and data.run.persistent.Init and data.run.persistent.Init[p]== nil then
        Fatefull.sprite_preload(p)
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

function Fatefull.sprite_preload(p)
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

function Fatefull.post_player_init(data,player)
    player:SetPocketActiveItem(Isaac.GetItemIdByName("Locked Heart"), SLOT_POCKET, false)
    player:AddBoneHearts(1)
    player:AddHearts(2)
    player:AddSoulHearts(2)
    player:AddTrinket(TrinketType.TRINKET_CROW_HEART, false)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false, ActiveSlot.SLOT_PRIMARY)
    util.addItem(CollectibleType.COLLECTIBLE_GLAUCOMA, false, true, player)
end

function Fatefull.on_player_render(player)
    --saveData = save.GetData()
    --local p = util.getPlayerIndex(player)
    --if p and not player:IsCoopGhost() then
    --    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then saveData.run.persistent.RickValues.StressMax[p] = 360 else saveData.run.persistent.RickValues.StressMax[p] = 240 end
    --end
    --save.EditData(saveData)
end

function Fatefull.post_render(player)
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
    if RickValues  then --and achievements.idle_timer <= 0
        Fatefull.sprite_preload(p)
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
            Fatefull.heart_beat(player)
            RickValues.OldFPS[p] = RickValues.NewFPS[p]
            Monitor[p]:Update()
            --if saveData.persistent.MorphineTime[p] == 0 then Shield[p]:Update() end  --For the morphine active Shield sprite display.
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
    if (RickValues.ShowPulseTime[p] > 0 or Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex))  then   --and achievements.idle_timer <= 0
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

function Fatefull.post_update(player)
    local p = util.getPlayerIndex(player)
    if Shield[p] then Shield[p]:Update() end
    Fatefull.sprite_preload(p)
    Fatefull.shield_sprite_select(player)
    --Fatefull.heart_beat(player)
end

function Fatefull.shield_sprite_select(player)
    local p = util.getPlayerIndex(player)
    saveData = save.GetData()
    local RickValues = saveData.run.persistent.RickValues
    local runSave = saveData.run
    if RickValues and runSave then
        if runSave.persistent.MorphineTime == nil then runSave.persistent.MorphineTime = {} end
        if runSave.persistent.MorphineTime[p] == nil then runSave.persistent.MorphineTime[p] = 0 end
        if Shield[p] and Shield[p]:IsFinished(Shield[p]:GetAnimation()) then
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
            elseif player:GetPlayerType() == enums.PlayerType.Fatefull then
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

function Fatefull.heart_beat(player)
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

function Fatefull.on_dealt_dmg(Entity,Amount,DamageFlags,Source,player)
end

function Fatefull.entity_take_dmg(player,Amount,DamageFlags)
end

function Fatefull.unlocks_NPC(npc)
end

function Fatefull.post_entity_kill(entity)
end

function Fatefull.post_peffect_update()
end

return Fatefull