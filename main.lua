LOVESICK = RegisterMod("Lovesick",1)
local Version = "1.0.a"

-- MAKE SURE TO REPLACE ALL INSTANCES OF "LOVESICK" WITH YOUR ACTUAL MOD REFERENCE
-- Made by Slugcat. Report any issues to her.
-- All credit to her, thanks for such is an awesome tool! --Rdnator55Dev

local json = require("json")
local dataCache = {}
local dataCacheBackup = {}
local shouldRestoreOnUse = false
local loadedData = false
local inRunButNotLoaded = true

local skipNextRoomClear = false
local skipNextLevelClear = false

---@class SaveData
---@field run RunSave @Data that is reset when the run ends. Using glowing hourglass restores data to the last backup.
---@field hourglassBackup table @The data that is restored when using glowing hourglass. Don't touch this.
---@field file FileSave @Data that is persistent between runs.

---@class RunSave
---@field persistent table @Things in this table will not be reset until the run ends.
---@field level table @Things in this table will not be reset until the level is changed.
---@field room table @Things in this table will not be reset until the room is changed.

---@class FileSave
---@field achievements table @Achievement related data.
---@field dss table @Dead Sea Scrolls related data.
---@field settings table @Setting related data.
---@field misc table @Miscellaneous stuff, you likely won't need to use this.

-- If you want to store default data, you must put it in this table.
---@return SaveData
function LOVESICK.DefaultSave()
    return {
        ---@type RunSave
        run = {
            persistent = {},
            level = {},
            room = {},
        },
        ---@type RunSave
        hourglassBackup = {
            persistent = {},
            level = {},
            room = {},
        },
        ---@type FileSave
        file = {
            achievements = {},
            dss = {}, -- Dead Sea Scrolls supremacy
            settings = {},
            misc = {},
        },
    }
end

---@return RunSave
function LOVESICK.DefaultRunSave()
    return {
        persistent = {},
        level = {},
        room = {},
    }
end

function LOVESICK.DeepCopy(tab)
    local copy = {}
    for k, v in pairs(tab) do
        if type(v) == 'table' then
            copy[k] = LOVESICK.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---@return boolean
function LOVESICK.IsDataLoaded()
    return loadedData
end

function LOVESICK.PatchSaveTable(deposit, source)
    source = source or LOVESICK.DefaultSave()

    for i, v in pairs(source) do
        if deposit[i] ~= nil then
            if type(v) == "table" then
                if type(deposit[i]) ~= "table" then
                    deposit[i] = {}
                end

                deposit[i] = LOVESICK.PatchSaveTable(deposit[i], v)
            else
                deposit[i] = v
            end
        else
            if type(v) == "table" then
                if type(deposit[i]) ~= "table" then
                    deposit[i] = {}
                end

                deposit[i] = LOVESICK.PatchSaveTable({}, v)
            else
                deposit[i] = v
            end
        end
    end

    return deposit
end

function LOVESICK.SaveModData()
    if not loadedData then
        return
    end

    -- Save backup
    local backupData = LOVESICK.DeepCopy(dataCacheBackup)
    dataCache.hourglassBackup = LOVESICK.PatchSaveTable(backupData, LOVESICK.DefaultRunSave())

    local finalData = LOVESICK.DeepCopy(dataCache)
    finalData = LOVESICK.PatchSaveTable(finalData, LOVESICK.DefaultSave())

    LOVESICK:SaveData(json.encode(finalData))
end

function LOVESICK.RestoreModData()
    if shouldRestoreOnUse then
        skipNextRoomClear = true
        local newData = LOVESICK.DeepCopy(dataCacheBackup)
        dataCache.run = LOVESICK.PatchSaveTable(newData, LOVESICK.DefaultRunSave())
        dataCache.hourglassBackup = LOVESICK.PatchSaveTable(newData, LOVESICK.DefaultRunSave())
    end
end

function LOVESICK.LoadModData()
    if loadedData then
        return
    end

    local saveData = LOVESICK.DefaultSave()

    if LOVESICK:HasData() then
        local data = json.decode(LOVESICK:LoadData())
        saveData = LOVESICK.PatchSaveTable(data, LOVESICK.DefaultSave())
    end

    dataCache = saveData
    dataCacheBackup = dataCache.hourglassBackup
    loadedData = true
    inRunButNotLoaded = false
end

---@return table?
function LOVESICK.GetRunPersistentSave()
    if not loadedData then
        return
    end

    return dataCache.run.persistent
end

---@return table?
function LOVESICK.GetLevelSave()
    if not loadedData then
        return
    end

    return dataCache.run.level
end

---@return table?
function LOVESICK.GetRoomSave()
    if not loadedData then
        return
    end

    return dataCache.run.room
end

---@return table?
function LOVESICK.GetFileSave()
    if not loadedData then
        return
    end

    return dataCache.file
end

local function ResetRunSave()
    dataCache.run = LOVESICK.DefaultRunSave()
    dataCache.hourglassBackup = LOVESICK.DefaultRunSave()
    dataCacheBackup = LOVESICK.DefaultRunSave()

    LOVESICK.SaveModData()
end

LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.RestoreModData, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

LOVESICK:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    local newGame = Game():GetFrameCount() == 0

    skipNextLevelClear = true
    skipNextRoomClear = true

    LOVESICK.LoadModData()

    if newGame then
        ResetRunSave()
        shouldRestoreOnUse = false
    end
end)

LOVESICK:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
    local game = Game()
    if game:GetFrameCount() > 0 then
        if not loadedData and inRunButNotLoaded then
            LOVESICK.LoadModData()
            inRunButNotLoaded = false
            shouldRestoreOnUse = true
        end
    end
end)

--- Replace YOUR_MOD_NAME with the name of your mod, as defined in RegisterMod!
--- This handles the "luamod" command!
LOVESICK:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function(_, mod)
    if mod == LOVESICK and Isaac.GetPlayer() ~= nil then
        if loadedData then
            LOVESICK.SaveModData()
        end
    end
end)

LOVESICK:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if not skipNextRoomClear then
        dataCacheBackup.persistent = LOVESICK.DeepCopy(dataCache.run.persistent)
        dataCacheBackup.room = LOVESICK.DeepCopy(dataCache.run.room)
        dataCache.run.room = LOVESICK.DeepCopy(LOVESICK.DefaultRunSave().room)
        LOVESICK.SaveModData()
        shouldRestoreOnUse = true
    end

    skipNextRoomClear = false
end)

LOVESICK:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    if not skipNextLevelClear then
        dataCacheBackup.persistent = LOVESICK.DeepCopy(dataCache.run.persistent)
        dataCacheBackup.level = LOVESICK.DeepCopy(dataCache.run.level)
        dataCache.run.level = LOVESICK.DeepCopy(LOVESICK.DefaultRunSave().level)
        LOVESICK.SaveModData()
        shouldRestoreOnUse = true
    end

    skipNextLevelClear = false
end)

LOVESICK:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
    LOVESICK.SaveModData()
    loadedData = false
    inRunButNotLoaded = false
    shouldRestoreOnUse = false
end)


-- postUpdate = require("Lovesick_src.callbacks.post_update")

--LOVESICK:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)



local game = Game()
local sfxManager = SFXManager()
local level = Game():GetLevel()
local stage = level:GetStage()
local curTime = 0
local Secs
local oldSecs
local oldDecs
local _120BPM
local _140BPM
local _130BPM
local _190BPM
local old120BPM
local old140BPM
local old130BPM
local old190BPM
local IsMines = false
local HasFixes = false
local maxShieldNumber=-1
local preload = false
local HasSpiderMod =  false
local HasSunsetClock = false
local newRoomDelay = 0
local monitor = {} --heartbeatsprite
local shield = {} --shieldsprite
local beat = {} --beatsprite
local note1 = {} --note1
local note2 = {} --note2
local note3 = {} --note3
local note4 = {} --note4
local tune = {} --Save Notes Here
local settings = {}
local achievements = {}
local runSave = {}
local achievement = Sprite()
local idle_timer = 0
achievement:Load("gfx/ui/achievement/achievements.anm2", true)
local rickId = Isaac.GetPlayerTypeByName("Rick")
local rickbId = Isaac.GetPlayerTypeByName("Rick_b",true)
--FIltered callback for NPCUpdate
local DELIRIUM_EX_TYPE = Isaac.GetEntityTypeByName("Delirium_EX")
local DELIRIUM_EX_VARIANT = Isaac.GetEntityVariantByName("Delirium_EX")
local debugText = "no thing"

local UnlockQueue = {}
local BossQueue = {}
local Rick =
{
    Range = 50,
    ShotSpeed = 0.2,
    Speed = 0.2,
    Damage = -2.2,
    Luck = 0.7,
    Firedelay = 1,


}
local RickB =
{
    Range = -40,
    ShotSpeed = -1.2,
    Speed = -0.1,
    Damage = 1.2,
    Luck = -1,
    Firedelay = 3,


}
local PaintKit =
{
    Firedelay = 0.5,
    ShotSpeed = 0.2,
}
local SunsetClock =
{
    Multiplier = 0.8,
    Buff = 1.1,
}
local NeckGaiter = {
    Damage = 0.75,
    Speed = 0.1,
}
local PaperRose = {
    Multiplier = 2.5/10
}
local RickValues =
{
    StressMax = {},
    Stress = {},
    ShowPulseTime = {},
    CalmDelay = {},
    LockShield = {},
    Preload = false,
    IsRick = {},
    newFPS = {},
    oldFPS = {},
    FPS = {},
    HitCharge = {},
    IsAlive = {},
    Color = {},
    Adrenaline = {},
    Tired = {},
}

local SevenValues = {
    delay = {}
}




if RDFIXES ~= nil then
    HasFixes = true
end

function LOVESICK:onStart(_,bool)
    
    LOVESICK.LoadModData()
    if not bool then
        LOVESICK:CheckSaveUnlocks()
        LOVESICK.CheckSettings()
    end
    
    if preload == false then
        HeartbeatSpritePreload()
        preload = true
    end     
    settings = dataCache.file.settings
    if not settings.QueueList == nil then UnlockQueue = settings.QueueList end
    achievements = dataCache.file.achievements
    runSave = dataCache.run
    for p=0, game:GetNumPlayers()-1 do
        local player= Isaac.GetPlayer(p)
        if player:GetPlayerType() == rickId and not player:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA,true) then
            RickSetup(p)
        end
        LOVESICK:UpdateCache(player)
    end
end
LOVESICK:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LOVESICK.onStart)

function LOVESICK:CheckSaveUnlocks()
    if dataCache.file.achievements.Faith == nil then
        dataCache.file.achievements.Faith = {
            Isaac = false,
            BlueBaby =  false,
            Satan =  false,
            TheLamb =  false,
            BossRush =  false,
            Hush =  false,
            MegaSatan =  false,
            Delirium =  false,
            Mother =  false,
            Beast =  false,
            Greed =  false,
            Greedier =  false,
        }
    elseif dataCache.file.achievements.Fate == nil then
        dataCache.file.achievements.Fate = {
                Isaac = false,
                BlueBaby =  false,
                Satan =  false,
                TheLamb =  false,
                BossRush =  false,
                Hush =  false,
                MegaSatan =  false,
                Delirium =  false,
                Mother =  false,
                Beast =  false,
                Greed =  false,
                Greedier =  false,
            }
    elseif dataCache.file.achievements.Fault == nil then
        dataCache.file.achievements.Fault = {
                Isaac = false,
                BlueBaby =  false,
                Satan =  false,
                TheLamb =  false,
                BossRush =  false,
                Hush =  false,
                MegaSatan =  false,
                Delirium =  false,
                Mother =  false,
                Beast =  false,
                Greed =  false,
                Greedier =  false,
            }
    elseif dataCache.file.achievements.Fortune == nil then
        dataCache.file.achievements.Fortune = {
                Isaac = false,
                BlueBaby =  false,
                Satan =  false,
                TheLamb =  false,
                BossRush =  false,
                Hush =  false,
                MegaSatan =  false,
                Delirium =  false,
                Mother =  false,
                Beast =  false,
                Greed =  false,
                Greedier =  false,
            }
    elseif dataCache.file.achievements.MissFortune == nil then
        dataCache.file.achievements.MissFortune = {
                Isaac = false,
                BlueBaby =  false,
                Satan =  false,
                TheLamb =  false,
                BossRush =  false,
                Hush =  false,
                MegaSatan =  false,
                Delirium =  false,
                Mother =  false,
                Beast =  false,
                Greed =  false,
                Greedier =  false,
            }
    elseif dataCache.file.achievements.Karma == nil then
        dataCache.file.achievements.Karma = {
                Isaac = false,
                BlueBaby =  false,
                Satan =  false,
                TheLamb =  false,
                BossRush =  false,
                Hush =  false,
                MegaSatan =  false,
                Delirium =  false,
                Mother =  false,
                Beast =  false,
                Greed =  false,
                Greedier =  false,
            }
    end
    LOVESICK.SaveModData()
end

function LOVESICK.CheckSettings()
    if dataCache.file.settings.TimeBPM == nil then dataCache.file.settings.TimeBPM = 15 end
    if dataCache.file.settings.HideBPM == nil then dataCache.file.settings.HideBPM = true end
    if dataCache.file.settings.DeliRework == nil then dataCache.file.settings.DeliRework = false end
    if dataCache.file.settings.ShieldNumberAlways == nil then dataCache.file.settings.ShieldNumberAlways = false end
    if dataCache.file.settings.VoidProbability == nil then dataCache.file.settings.VoidProbability = 50 end
    if dataCache.file.settings.UseWorkaroundMegasatan == nil then dataCache.file.settings.UseWorkaroundMegasatan = false end
    LOVESICK.SaveModData()
end
function LOVESICK.SaveSettings()
    dataCache.file.settings = settings
    LOVESICK.SaveModData()
end

function LOVESICK:onExit(_,bool)
    if settings.QueueList == nil and UnlockQueue then settings.QueueList = UnlockQueue end
    if runSave.persistent.BossQueue == nil and BossQueue then runSave.persistent.BossQueue = BossQueue end
    LOVESICK.SaveSettings()
    if bool == false then
        for p=0, game:GetNumPlayers()-1 do
            ReNil(p)
        end
    end
end
LOVESICK:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, LOVESICK.onExit)

function LOVESICK:UpdateCache(playerToUpdate)
    --print("Update the cache of ", playerToUpdate.ControllerIndex,playerToUpdate:GetPlayerType())
    for p=0, game:GetNumPlayers()-1 do
        local player= Isaac.GetPlayer(p)
        local number = p
        --print(playerToUpdate.Position,player.Position)
        if player.Position.X==playerToUpdate.Position.X and player.Position.Y==playerToUpdate.Position.Y then 
            --print("Player n: ",number) 
            local player= Isaac.GetPlayer(number)    
            playerToUpdate:AddCacheFlags(CacheFlag.CACHE_ALL) --CacheFlag.CACHE_DAMAGE,
            playerToUpdate:EvaluateItems() -- The "MC_EVALUATE_CACHE" callback will now fire.
            --print(number,RickValues.StressMax[number],RickValues.Stress[number],RickValues.ShowPulseTime[number],RickValues.CalmDelay[number],RickValues.LockShield[number],RickValues.IsRick[number])
        end
    end
end

function HeartbeatSpritePreload()
    for p=0, game:GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(p)
        if monitor[p]== nil and player:GetPlayerType() == rickId then
            monitor[p] = Sprite()
            monitor[p]:Load("gfx/others/heartbeatsprite.anm2", true)
            monitor[p]:Play("Low Stress", true)
            --print("loading monitor for ",p)
        end
        if shield[p]== nil then
            shield[p] = Sprite()
            shield[p]:Load("gfx/others/shield.anm2", true)
            shield[p]:Play("1", true)
            --print("loading shield for ",p)
        end
        if player:GetPlayerType() == rickbId then
            if beat[p]== nil then
                beat[p] = Sprite()
                beat[p]:Load("gfx/others/rythm_tempo.anm2", true)
                beat[p]:Play("Easy", true)
                --print("loading shield for ",p)
            end
            if note1[p]== nil then
                note1[p] = Sprite()
                note1[p]:Load("gfx/others/notes.anm2", true)
                note1[p]:Play("Space", true)
                --print("loading shield for ",p)
            end
            if note2[p]== nil then
                note2[p] = Sprite()
                note2[p]:Load("gfx/others/notes.anm2", true)
                note2[p]:Play("Space", true)
                --print("loading shield for ",p)
            end
            if note3[p]== nil then
                note3[p] = Sprite()
                note3[p]:Load("gfx/others/notes.anm2", true)
                note3[p]:Play("Space", true)
                --print("loading shield for ",p)
            end
            if note4[p]== nil then
                note4[p] = Sprite()
                note4[p]:Load("gfx/others/notes.anm2", true)
                note4[p]:Play("Space", true)
                --print("loading shield for ",p)
            end
        end
    end
end

function RickSetup(rickplayer)
    --print("Ricksetup",rickplayer)
    local player= Isaac.GetPlayer(rickplayer)
    player:SetPocketActiveItem(Isaac.GetItemIdByName("Locked Heart"), SLOT_POCKET, false)
    player:AddBoneHearts(1)
    player:AddHearts(2)
    player:AddSoulHearts(2) 
    --print("startup for player n:",rickplayer)
    player:AddTrinket(TrinketType.TRINKET_CROW_HEART, false)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false, -1, 0)           
    --local RickHair = Isaac.GetCostumeIdByPath("gfx/characters/character_rick_hair.anm2")
    --player:AddNullCostume(RickHair)
    RickValues.StressMax.Type = table
    RickValues.StressMax[rickplayer] = 240
    RickValues.Stress.Type = table
    RickValues.Stress[rickplayer] = RickValues.StressMax[rickplayer]/2
    RickValues.ShowPulseTime.Type = table
    RickValues.ShowPulseTime[rickplayer] = 12
    RickValues.CalmDelay.Type = table
    RickValues.CalmDelay[rickplayer] = 5
    RickValues.LockShield.Type = table
    RickValues.LockShield[rickplayer] = 0
    RickValues.IsRick.type = table
    RickValues.IsRick[rickplayer] = true
    RickValues.FPS.type = table
    RickValues.FPS[rickplayer] = nil
    RickValues.oldFPS.type = table
    RickValues.oldFPS[rickplayer] = nil
    RickValues.newFPS.type = table
    RickValues.newFPS[rickplayer] = nil
    RickValues.HitCharge.type = table
    RickValues.HitCharge[rickplayer] = 0
    RickValues.IsAlive.Type = table
    RickValues.IsAlive[rickplayer] = true
    RickValues.Color.type = table
    RickValues.Color[rickplayer] = 3
    RickValues.Adrenaline.Type = table
    RickValues.Adrenaline[rickplayer] = false
    RickValues.Tired.Type = table
    RickValues.Tired[rickplayer] = 0
    --print(RickValues.StressMax[rickplayer],RickValues.Stress[rickplayer],RickValues.ShowPulseTime[rickplayer],RickValues.CalmDelay[rickplayer],RickValues.LockShield[rickplayer],RickValues.IsRick[rickplayer])
    addItem(CollectibleType.COLLECTIBLE_GLAUCOMA, false, true, player)
    --local RickHair = Isaac.GetCostumeIdByPath("gfx/characters/character_rick_hair.anm2")
    --player:AddNullCostume(RickHair)
end

function addItem(item, costume, new, player)
    player:AddCollectible(item, 0, new, 0, 0)
    if costume == false then
        local itemConfig = Isaac.GetItemConfig()
        local itemConfigItem = itemConfig:GetCollectible(item)
        player:RemoveCostume(itemConfigItem)

    end
end

function unNil(p)
    local player = Isaac.GetPlayer(p)
        if player:GetPlayerType() == rickId then
            --print("UnNil:",p,RickValues.IsAlive[p])
            if RickValues.StressMax[p] == nil then RickValues.StressMax[p] = 240 RickSetup(p) end
            if RickValues.Stress[p] == nil then --print("unNil", p)
            RickValues.Stress[p] = RickValues.StressMax[p]/2 end
            if RickValues.ShowPulseTime[p] == nil then --print("unNil", p) 
                RickValues.ShowPulseTime[p] = 12 end
            if RickValues.CalmDelay[p] == nil then --print("unNil", p) 
                RickValues.CalmDelay[p] = 5 end
            if RickValues.LockShield[p] == nil then --print("unNil", p) 
                RickValues.LockShield[p] = 0 end
            if RickValues.IsRick[p] == nil then --print("unNil", p) 
                RickValues.IsRick[p] = true end
            if RickValues.newFPS[p] == nil then --print("unNil", p) 
                RickValues.newFPS[p] = 0 end
            if RickValues.FPS[p] == nil then --print("unNil", p) 
                RickValues.FPS[p] = 0 end
            if RickValues.HitCharge[p] == nil then --print("unNil", p) 
                RickValues.HitCharge[p] = 0 end
            if RickValues.IsAlive[p] == nil then --print("unNil", p) 
                --local RickHair = Isaac.GetCostumeIdByPath("gfx/characters/character_rick_hair.anm2")
                --print("hair")
                --player:AddNullCostume(RickHair)
                RickValues.IsAlive[p] = true end
            if RickValues.Color[p] == nil then --print("unNil", p) 
                RickValues.Color[p] = 3 end
            if RickValues.Tired[p] == nil then --print("unNil", p) 
                RickValues.Tired[p] = 0 end
            if RickValues.Adrenaline[p] == nil then --print("unNil", p) 
                RickValues.Adrenaline[p] = false end
        --print(p,RickValues.StressMax[p],RickValues.Stress[p],RickValues.ShowPulseTime[p],RickValues.CalmDelay[p],RickValues.LockShield[p],RickValues.IsRick[p])
    end    
end

function ReNil(p)
    local player = Isaac.GetPlayer(p)
    if player:GetPlayerType() == rickId then
        RickValues.StressMax[p] = nil
        RickValues.Stress[p] = nil
        RickValues.ShowPulseTime[p] = nil
        RickValues.CalmDelay[p] = nil
        RickValues.LockShield[p] = nil
        RickValues.IsRick[p] = nil
        RickValues.newFPS[p] = nil
        RickValues.FPS[p] = nil
        RickValues.HitCharge[p] = nil
        RickValues.IsAlive[p] = nil 
        RickValues.Color[p] = nil 
        RickValues.Adrenaline[p]=nil
        RickValues.Tired[p]=nil

    end    
end

function getPlayerId(playerToIndex, cache)
    if playerToIndex == nil then return nil end
    for p=0, game:GetNumPlayers()-1 do
        local player= Isaac.GetPlayer(p)
        local number = p
        --print(playerToUpdate.Position,player.Position)
        if player.Position.X==playerToIndex.Position.X and player.Position.Y==playerToIndex.Position.Y then 
            return number
        end
    end
end

local function onCacheLovesick(_,player, cache)
    ---@param _ any
    ---@param player EntityPlayer
    ---@param cache CacheFlag | BitSet128
    --print(getPlayerId(player),RickValues.IsAlive[getPlayerId(player)])
    local p = getPlayerId(player)
    LOVESICK:ReloadDataNeeded()
    if (player:GetPlayerType() == rickId) then
        SetbaseStats(player,cache,Rick)
    end
    if (player:GetPlayerType() == rickbId)then
        SetbaseStats(player,cache,RickB)
    end
    if player:HasCollectible(Isaac.GetItemIdByName("Painting Kit")) then
        local Secs= math.floor(curTime/30)
        local tempo = math.floor((Secs)%5)
        --print(Secs,tempo)
        if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            if player.MaxFireDelay - PaintKit.Firedelay* player:GetCollectibleNum(Isaac.GetItemIdByName("Painting Kit"), true) <= 5 then player.MaxFireDelay = math.min(player.MaxFireDelay,5)
            else
                player.MaxFireDelay = player.MaxFireDelay - PaintKit.Firedelay * player:GetCollectibleNum(Isaac.GetItemIdByName("Painting Kit"), true)
            end
        end
        if (player.TearFlags and cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
            if tempo <=0 then
                --print("0t",tempo)
                player.TearFlags = player.TearFlags | TearFlags.TEAR_GISH
            elseif tempo <=1 then
                --print("1t",tempo)
                player.TearFlags = player.TearFlags | TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP
            elseif tempo <=2 then
                --print("2t",tempo)
                player.TearFlags = player.TearFlags | TearFlags.TEAR_TURN_HORIZONTAL
            elseif tempo <=3  then
                --print("3t",tempo)
                player.TearFlags = player.TearFlags | TearFlags.TEAR_BOUNCE
            else
                --print("4t",tempo)
                player.TearFlags = player.TearFlags | TearFlags.TEAR_HYDROBOUNCE
            end
        end
        if (player.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed + PaintKit.ShotSpeed
        end 
    end
    if player:HasCollectible(Isaac.GetItemIdByName("Sunset Clock")) then
        if runSave.level.SunsetClock == nil then LOVESICK:ReloadDataNeeded()   runSave.level.SunsetClock = 90 end
        --print(runSave.level.SunsetClock)
        if runSave.level.SunsetClock > 0 then
            if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
                player.Damage = player.Damage * SunsetClock.Multiplier
            end        
            if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
                player.MaxFireDelay = player.MaxFireDelay / SunsetClock.Multiplier
            end
            if (player.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
                player.ShotSpeed = player.ShotSpeed * SunsetClock.Multiplier
            end        
            if (player.TearRange and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
                player.TearRange = player.TearRange * SunsetClock.Multiplier
            end
            if (player.MoveSpeed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed * SunsetClock.Multiplier
            end        
            if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
                player.Luck = math.max(10,player.Luck)
            end
        else
            if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
                player.Damage = player.Damage + SunsetClock.Buff
            end        
            if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
                player.MaxFireDelay = player.MaxFireDelay / SunsetClock.Buff
            end
            if (player.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
                player.ShotSpeed = player.ShotSpeed * SunsetClock.Buff
            end        
            if (player.TearRange and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
                player.TearRange = player.TearRange * SunsetClock.Buff
            end
            if (player.MoveSpeed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed * SunsetClock.Buff
            end        
            if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
                player.Luck = player.Luck * SunsetClock.Buff
            end
        end
    end
    if player:HasCollectible(Isaac.GetItemIdByName("Neck Gaiter"), false) then
        if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage + NeckGaiter.Damage
        end 
        if (player.MoveSpeed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = math.min(player.MoveSpeed + NeckGaiter.Speed,2)
            --print("Speed")
        end 
    end
    if player:HasTrinket(Isaac.GetTrinketIdByName("Paper Rose")) then
        if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage * (1-PaperRose.Multiplier)
        end 
        if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck*(1+PaperRose.Multiplier) + (player.Damage * PaperRose.Multiplier) -1
        end
    end
    if player:HasCollectible(Isaac.GetItemIdByName("Kind Soul")) then
        if runSave.level.KindSoulDead == nil then runSave.level.KindSoulDead = {} end
        if runSave.level.KindSoulDead[p] == nil then runSave.level.KindSoulDead[p] = 0 end
        if cache & CacheFlag.CACHE_FAMILIARS == CacheFlag.CACHE_FAMILIARS then
            local boxUses = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
            local numItem = player:GetCollectibleNum(Isaac.GetItemIdByName("Kind Soul"))
            local numFamiliars = (numItem > 0 and (numItem + boxUses) or 0)- runSave.level.KindSoulDead[p]
            player:CheckFamiliar(Isaac.GetEntityVariantByName("Kind Soul"), numFamiliars, player:GetCollectibleRNG(Isaac.GetItemIdByName("Kind Soul")), Isaac.GetItemConfig():GetCollectible(Isaac.GetItemIdByName("Kind Soul")))
        end 
    end

    if runSave.persistent.MorphineDebuff then
        if runSave.persistent.MorphineDebuff[p] == nil then runSave.persistent.MorphineDebuff[p] = 0 else
            if runSave.persistent.MorphineDebuff[p] then 
                player.MaxFireDelay = player.MaxFireDelay + runSave.persistent.MorphineDebuff[p]
            end  
        end
    end
    if runSave.persistent.LoveLetterShame then
        if runSave.persistent.LoveLetterShame[p] == nil then runSave.persistent.LoveLetterShame[p] = 0 else
            if runSave.persistent.LoveLetterShame[p] then 
                player.MaxFireDelay = player.MaxFireDelay - runSave.persistent.LoveLetterShame[p]
            end  
        end
    end
    if RickValues.Adrenaline[p] == true then
        if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            if player.Damage > 10 then player.Damage = player.Damage *1.2
            elseif player.Damage > 1 then player.Damage = player.Damage*2
            else   player.Damage = player.Damage + 0.5  end
        end    
    end
end
LOVESICK:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheLovesick)

function SetbaseStats(player,cache,stats)
    --print(player:GetPlayerType().." "..player.ControllerIndex.." ".." ",hasParent," "..player.Damage)
    if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage + stats.Damage
        --print("Damage", player.Damage, getPlayerId(player))
    end        
    if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        --print("Tears1", player.MaxFireDelay )
        if player.MaxFireDelay - stats.Firedelay <= 5 then player.MaxFireDelay = player.MaxFireDelay
        else
            player.MaxFireDelay = player.MaxFireDelay - stats.Firedelay
        end
       --print("Tears2", player.MaxFireDelay )
    end
    if cache == CacheFlag.CACHE_SHOTSPEED  then
        player.ShotSpeed = player.ShotSpeed + stats.ShotSpeed
    end
    if (player.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed + stats.ShotSpeed
        --print("ShotSpeed")
    end        
    if (player.TearRange and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange + stats.Range
        --print("Range")
    end
    if (player.MoveSpeed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = math.min(2,player.MoveSpeed + stats.Speed)
        --print("Speed")
    end        
    if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + stats.Luck
        --print("Luck")
    end
end

local function onPlayerRender(_, player) 
    --LOVESICK:IsItemUnlocked()   
    if player:GetPlayerType()==rickId then
        if player:IsCoopGhost() then RickValues.IsAlive[getPlayerId(player)]=false end
        --print("ID de ",player," es ",getPlayerId(player))
        local p = getPlayerId(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then RickValues.StressMax[p] = 360 else RickValues.StressMax[p] = 240 end
        if RickValues.IsRick[p]~= true then
            unNil(getPlayerId(player))
            --print(RickValues.LockShield[getPlayerId(player)])
            LOVESICK:UpdateCache(player)
            if not player:HasCollectible(Isaac.GetItemIdByName("Locked Heart"),true) and not player:IsCoopGhost() then            
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA,true)then
                    player:SetPocketActiveItem(Isaac.GetItemIdByName("Locked Heart"), SLOT_POCKET, false)
                    player:AddBoneHearts(1)
                    player:AddHearts(2)
                    player:AddSoulHearts(2)
                    --print("Initialize stats for player n:",playerNum) 
                    player:AddTrinket(TrinketType.TRINKET_CROW_HEART, false)
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false, -1, 0)    
                    addItem(CollectibleType.COLLECTIBLE_GLAUCOMA, false, true, player)
                end
                       
                

            end 
        else
            --if not player:HasCollectible(Isaac.GetItemIdByName("Locked Heart"),true) then
        end
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, onPlayerRender ,0)

function LOVESICK.PostPeffectUpdate(_,player)
    LOVESICK:ReloadDataNeeded()
	if game:GetVictoryLap() > 0 then return end
    if achievements.Faith.Beast and achievements.Faith.BlueBaby and achievements.Faith.BossRush and achievements.Faith.Delirium 
    and achievements.Faith.Greed and achievements.Faith.Greedier and achievements.Faith.Hush and achievements.Faith.Isaac 
    and achievements.Faith.MegaSatan and achievements.Faith.Mother and achievements.Faith.Satan and achievements.Faith.TheLamb then
        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_13.png")
    end
	
	local playerType = player:GetPlayerType()

	if playerType ~= rickId  then return end --and playerType ~= rickbId
    LOVESICK:ReloadDataNeeded()

	local level = game:GetLevel()
	local levelStage = level:GetStage()
	local room = game:GetRoom()
			
	if game:GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE)
	and (levelStage == LevelStage.STAGE3_1 or levelStage == LevelStage.STAGE3_2)
	then
		if playerType == rickId
		and not achievements.Faith.BossRush
		then
            LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_9.png")
            achievements.Faith.BossRush = true
		end
	end
	
	if game:GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE)
	and levelStage == LevelStage.STAGE4_3
	then
		if playerType == rickId
		and not achievements.Faith.Hush
		then
            LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_7.png")
            achievements.Faith.Hush = true
		end
	end
	
	if game:IsGreedMode()
	and levelStage == LevelStage.STAGE7_GREED
	then
		if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2
		and room:IsClear()
		then
			if game.Difficulty == Difficulty.DIFFICULTY_GREED then
				if playerType == rickId
				and not achievements.Faith.Greed
				then
                    LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_11.png")
					achievements.Faith.Greed = true
                end
			elseif game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
				if playerType == rickId then
                    if not achievements.Faith.Greedier then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_12.png")
                        --print("1")
                        achievements.Faith.Greedier = true
                    elseif not achievements.Faith.Greed then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_11.png")
                        --print("2")
                        achievements.Faith.Greed = true
                    end
				end
			end
		end
	end
    dataCache.file.achievements = achievements
    LOVESICK.SaveModData()
end
LOVESICK:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LOVESICK.PostPeffectUpdate)

function LOVESICK:PreEndChestCollision(EntityPlayer, Collider, Low )
    if not runSave.persistent.MegasatanFix and runSave.persistent.MegasatanIsDead and Collider.Type == EntityType.ENTITY_PICKUP and Collider.Variant == PickupVariant.PICKUP_BIGCHEST then --and runSave.persistent.MegasatanIsDead == true 
        --print(runSave.persistent.MegasatanIsDead,runSave.persistent.MegasatanFix)
        game:ShowHallucination(30, 0)
        Isaac.ExecuteCommand("stage 11")
        Isaac.ExecuteCommand("goto s.boss.5000")
        Isaac.ExecuteCommand("cutscene 2")
        
        game:GetRoom():TriggerClear(true)
        local p = getPlayerId(EntityPlayer) --print(p,EntityPlayer.Position, EntityPlayer.Position + Vector(-200,0))
        EntityPlayer.Position = EntityPlayer.Position + Vector(-200,0)
        --game:StartStageTransition(true, RoomTransitionAnim.DEATH_CERTIFICATE , Isaac.GetPlayer(p))
        runSave.persistent.MegasatanFix = true 
        --print(EntityPlayer.Position)
        --game:ShowHallucination(30, 0)
        return false
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION,LOVESICK.PreEndChestCollision, 0)

function LOVESICK:PrePlayerChestCollision(EntityPickup, Collider, Low )

    if EntityPickup.Type == EntityType.ENTITY_PICKUP and EntityPickup.Variant == PickupVariant.PICKUP_BIGCHEST and Collider.Type == EntityType.ENTITY_PLAYER then --and runSave.persistent.MegasatanIsDead == true 
        EntityPickup.EntityCollisionClass = 3
        --print("collision2")
    end
end
LOVESICK:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION,LOVESICK.PrePlayerChestCollision, 0)

function LOVESICK:storeInQueue(_sprite) --Stuff to store a new achievement in queue to display (for when various characters and tainteds together.)
    if UnlockQueue[1] == nil then UnlockQueue[1] = _sprite else
    for i, v in ipairs(UnlockQueue) do 
        if UnlockQueue[i+1] == nil and UnlockQueue[i]~= nil then UnlockQueue[i+1] = _sprite return end
    end
    end
end

function LOVESICK:removeFromQueue() --Remove older achievement in queue to display (for when various characters and tainteds together.)
    if UnlockQueue[1] == nil then return  else
        local OldFirstValue = UnlockQueue[1]
    for i, v in ipairs(UnlockQueue) do 
        if UnlockQueue[i+1] == nil and UnlockQueue[i]~= nil then UnlockQueue[i] = UnlockQueue[i+1] return OldFirstValue 
        else
            UnlockQueue[i] = UnlockQueue[i+1]
        end
    end
    end
end

function MaxShieldPlayer()
    local charges = 0
    local shield = 0
    --print("updatemaxshield")
    ---@param charge number
    ---@param shield number
    for p = 0, game:GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(p)
        if player:GetPlayerType() == rickId then
            local number = p
            --print(RickValues.LockShield[number])
            if RickValues.LockShield[number]==nil then
                if maxShieldNumber == nil then maxShieldNumber = -1 end
            elseif (RickValues.LockShield[number]  > charges) then
                charges = RickValues.LockShield[number]  
                maxShieldNumber = number
                --print(RickValues.LockShield[number])
            else
                maxShieldNumber = -1
            end
        end
    end
    --print("MaxShieldPlayer:", maxShieldNumber," charges:",charges)
end

function LOVESICK:EntityHit(Entity, Amount, DamageFlags, Source, CountdownFrames)
    --print("AAA")
    ---@param DamageFlag CacheFlag | BitSet128
    MaxShieldPlayer()
    local shieldCharges = RickValues.LockShield[maxShieldNumber]
    if shieldCharges == nil then shieldCharges = 0 end 
    if Entity.Type == 1 then
        
        local player = Entity:ToPlayer()
        --player Stress DMG here
        if runSave.persistent.MorphineTime[getPlayerId(player)] > 0 then
            player:SetMinDamageCooldown(60) 
            player:AnimateSad()
            runSave.persistent.MorphineDebuff[getPlayerId(player)] = math.max (runSave.persistent.MorphineDebuff[getPlayerId(player)] + 0.25, 0.5)
            return false 
        end
        --print("maxShieldNumber",maxShieldNumber)
        if player: HasCollectible(Isaac.GetItemIdByName("Arrest Warrant"),true) then
            local amount = player:GetCollectibleNum(Isaac.GetItemIdByName("Arrest Warrant"),true)
            local keys = player:GetNumKeys() local coins = math.floor(player:GetNumCoins()/5) local bombs = player:GetNumBombs()
            if keys > (coins and bombs)then
                sfxManager:Play(SoundEffect.SOUND_KEY_DROP0, 0.5,  8, false, 1)
                player:AddKeys(-amount)
                player:AnimateSad()
            elseif bombs > (keys and coins)then
                sfxManager:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 0.5,  8, false, 1)
                player:AddBombs(-amount)
                player:AnimateSad()
            else
                sfxManager:Play(SoundEffect.SOUND_ULTRA_GREED_COINS_FALLING, 0.5,  8, false, 1)
                player:AddCoins(-amount*5)
                player:AnimateSad()
            end
        end
        local shieldCharges = RickValues.LockShield[maxShieldNumber]
        if shieldCharges == nil then shieldCharges = 0 end 
        local stressDMG 
        if RickValues.Stress[getPlayerId(player)] == nil then
            stressDMG = 0
        else
            stressDMG = math.max(math.floor((RickValues.Stress[getPlayerId(player)]-RickValues.StressMax[getPlayerId(player)]/2)/20),0)
        end
        --print(shieldCharges,Amount,stressDMG,(math.max(0,math.floor(10+RickValues.Stress[getPlayerId(player)]-RickValues.StressMax[getPlayerId(player)]/2)/20)))
        if shieldCharges > 0 then
            local shieldplayer = Isaac.GetPlayer(maxShieldNumber)
            if (DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES ~= 0 or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS ~= 0) and (player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())>Amount and DamageFlags & DamageFlag.DAMAGE_CURSED_DOOR == 0 then return nil end
            RickValues.LockShield[maxShieldNumber] = math.floor(math.max(RickValues.LockShield[maxShieldNumber] - (Amount+stressDMG),0)) --math.floor
            ShieldSpriteSelect(maxShieldNumber)
            sfxManager:Play(Isaac.GetSoundIdByName("Shield_Down"), 0.5,  8, false, 1)
            
            if getPlayerId(player) == maxShieldNumber then
                player:AnimateSad()
                --player:SetMinDamageCooldown(60) 
                if shieldCharges<(Amount+stressDMG) then
                    --player:TakeDamage((Amount+stressDMG)-shieldCharges, DamageFlag.DAMAGE_NO_PENALTIES,EntityRef(Entity), 0)
                    RickValues.Stress[maxShieldNumber] = math.max(15,math.floor(RickValues.Stress[maxShieldNumber]*2/3))
                    RickValues.CalmDelay[maxShieldNumber] = math.max(RickValues.CalmDelay[maxShieldNumber],5)
                end
                player:SetMinDamageCooldown(60) 
                if sfxManager:IsPlaying(SoundEffect.SOUND_THUMBS_DOWN)then 
                    sfxManager:Stop(SoundEffect.SOUND_THUMBS_DOWN)
                end
                if sfxManager:IsPlaying(SoundEffect.SOUND_THUMBSUP)then 
                    sfxManager:Stop(SoundEffect.SOUND_THUMBSUP)
                end
                return false
            else
                player:AnimateHappy()
                player:SetMinDamageCooldown(30) 
                shieldplayer:AnimateSad()
                shieldplayer:SetMinDamageCooldown(30) 
                if shieldCharges<(Amount+stressDMG) then
                    shieldplayer:TakeDamage(math.floor((Amount+stressDMG)-shieldCharges), DamageFlag.DAMAGE_NO_PENALTIES,EntityRef(Entity), 0)
                    RickValues.Stress[maxShieldNumber] = math.max(15,math.floor(RickValues.Stress[maxShieldNumber]*2/3))
                    RickValues.CalmDelay[maxShieldNumber] = math.max(RickValues.CalmDelay[maxShieldNumber],5)
                end
                if sfxManager:IsPlaying(SoundEffect.SOUND_THUMBS_DOWN)then 
                    sfxManager:Stop(SoundEffect.SOUND_THUMBS_DOWN)
                end
                if sfxManager:IsPlaying(SoundEffect.SOUND_THUMBSUP)then 
                    sfxManager:Stop(SoundEffect.SOUND_THUMBSUP)
                end
                return false
            end
        else
            if stressDMG >= 0 and Source.Type ~= Entity.Type and Source.SubType ~= Entity.SubType then 
                if RickValues.Stress[getPlayerId(player)] ~= nil then 
                    player:TakeDamage(math.floor(stressDMG), DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(Entity), 0) 
                    if RickValues.Stress[getPlayerId(player)] > 0 and not (DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES ~= 0 or DamageFlags & DamageFlag.DAMAGE_RED_HEARTS ~= 0) and (player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())>Amount and DamageFlags & DamageFlag.DAMAGE_CURSED_DOOR == 0 then
                        --print("help1",RickValues.Stress[getPlayerId(player)]) 
                        RickValues.Stress[getPlayerId(player)] = math.floor(RickValues.Stress[getPlayerId(player)]-math.max(15,RickValues.Stress[getPlayerId(player)]*1/3)) 
                        if RickValues.Stress[getPlayerId(player)] <=0 then RickValues.Stress[getPlayerId(player)] = 0 player:Die() end
                    end 
                end
            end
        end
    elseif Entity.Type == Source.Type then
        --print("Karma",shieldCharges,Amount,maxShieldNumber,getPlayerId(player))
    else
        local player
        --print(Entity.Type, Source.Type,Source.Entity.Parent) 
        if Source.Type==2 and Source.Entity and Source.Entity.Parent and Source.Entity.Parent.Type==1 then 
            player=Source.Entity.Parent:ToPlayer() 
        elseif Source.Type==1 then 
            player=Source.Entity:ToPlayer() 
        elseif Source.Entity and Source.Entity.Parent and Source.Entity.Parent.Type==1 then 
            player=Source.Entity.Parent:ToPlayer()
        end
        --print(player:GetPlayerType())
        if player == nil then
        else
            if player.Type == 1 and Entity.Parent == nil then
                if runSave.persistent.TotalDamage == nil then runSave.persistent.TotalDamage = math.min(Amount,Entity.HitPoints) else
                runSave.persistent.TotalDamage = runSave.persistent.TotalDamage + math.min(Amount,math.max(Entity.HitPoints,0)) end
            end
        end
        
        local p = getPlayerId(player)
        if RickValues.Stress[p] == nil then
        else 
            local pierceDMG = (math.floor(10+((RickValues.Stress[p]-RickValues.StressMax[p]/2)/6)))/10
            local stressDMG = math.max(0,(math.floor((RickValues.Stress[p])/6)/500) * (Entity.MaxHitPoints - Entity.HitPoints))
            local data = Entity:GetData()
            if data.Delay == nil then data.Delay = {} end   
            if data.Delay[p] == nil then data.Delay[p] = 0 end
            --print(data.Delay[p])
            if data.Frame == nil then data.Frame = {} end
            if data.Frame[p] == nil then data.Frame[p] = game:GetFrameCount() end
            if data.Delay[p] -(game:GetFrameCount()-data.Frame[p]) <=0  then  
                --print("Pierce")
                data.Delay[p] = 30 data.Frame[p] = game:GetFrameCount()       
                if Entity:IsVulnerableEnemy() and player:GetPlayerType() == rickId and not (DamageFlags & DamageFlag.DAMAGE_NOKILL ~= 0) 
                then
                local defaultDMG
                if stage >= 7 and achievements.Faith.BlueBaby then defaultDMG = 2 else defaultDMG = 1 end
                --print(maxShieldNumber)
                --print(pierceDMG, stressDMG)
                if Source.Type == 2 then
                    --print("Chivato normal 1",getPlayerId(player),player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true), pierceDMG,stressDMG,RickValues.Stress[p])
                    --print(p,RickValues.Stress[p],RickValues.StressMax[p],player.Luck, player:GetPlayerType())

                    --print("pierce")
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) and (maxShieldNumber == -1 or RickValues.LockShield[p]<=defaultDMG*5) then 
                        Entity:TakeDamage((Amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)
                        if Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG) then
                            local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 0, Entity.Position, Vector(0,0), nil)
                            heart:ToPickup().Timeout = 60 
                            Entity:BloodExplode()
                            game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                            --if newHeart ~= nil then newHeart:ToPickup().Timeout = 25 end
                        end
                    elseif (Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG)) and RickValues.Adrenaline[p] == true then
                            Entity:BloodExplode()
                            game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                    else
                        Entity:TakeDamage((Amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)
                    end
                elseif Source.Type == 1 then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) and (maxShieldNumber == -1 or RickValues.LockShield[p]<=defaultDMG*15)  then 
                        Entity:TakeDamage((Amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)
                        if Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG) then --
                            local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 0, Vector(Entity.Position.X,Entity.Position.Y), Vector(0,0), nil)
                            heart:ToPickup().Timeout = 60 
                            Entity:BloodExplode()
                            game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                            --if newHeart ~= nil then newHeart:ToPickup().Timeout = 25 end
                        end
                    elseif (Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG)) and RickValues.Adrenaline[p] == true then
                        Entity:BloodExplode()
                        game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                    else
                        Entity:TakeDamage((Amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)    
                    end
                else
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) and (maxShieldNumber == -1 or RickValues.LockShield[p]<=defaultDMG*15)  then 
                        Entity:TakeDamage((Amount * pierceDMG) + stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)
                        if Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG)then
                            local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 0, Vector(Entity.Position.X,Entity.Position.Y), Vector(0,0), nil)
                            heart:ToPickup().Timeout = 60 
                            Entity:BloodExplode()
                            game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                            --if newHeart ~= nil then newHeart:ToPickup().Timeout = 25 end
                        end
                    elseif (Entity:HasMortalDamage() or Entity.HitPoints <= ((Amount * pierceDMG) + stressDMG)) and RickValues.Adrenaline[p] == true then
                        Entity:BloodExplode()
                        game:BombDamage(Entity.Position, player.Damage/2, 45, true, player, player.TearFlags | TearFlags.TEAR_FEAR, DamageFlag.DAMAGE_NOKILL, false)
                    else
                        Entity:TakeDamage((Amount * pierceDMG/6) + stressDMG/6, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Entity), 0)    
                    end
                    --:TakeDamage(Damage, Flags, Source, DamageCountdown)
                --Entity:TakeDamage(stressDMG, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityType.ENTITY_NULL, 0)
                
                --Entity.HitPoints = Entity.HitPoints - (Amount * pierceDMG) - stressDMG
                --print(Entity.MaxHitPoints, Entity.HitPoints, Amount, pierceDMG, stressDMG)
                end
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
                end
            else
                data.Delay[p] = data.Delay[p] -(game:GetFrameCount()-data.Frame[p])
            end

        RickValues.CalmDelay[p]= math.max(RickValues.CalmDelay[p],5)
        RickValues.ShowPulseTime[p]= math.max(RickValues.ShowPulseTime[p],3)
        
        if player:HasCollectible(CollectibleType.COLLECTIBLE_4_5_VOLT,true) or RickValues.Adrenaline[p] == true then
            local charge=player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
            local subcharge = player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
            --print(charge,subcharge)
            RickValues.HitCharge[p] = math.max(0,RickValues.HitCharge[p]) + (Amount+pierceDMG)/(20*math.max((RickValues.LockShield[p]/10),1))
            --print(RickValues.HitCharge[p]>=10,RickValues.HitCharge[p],(Amount+pierceDMG)/(20*math.max((RickValues.LockShield[p]),1)))
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false)  and RickValues.HitCharge[p]>=1 then
                if subcharge < 15 then
                    player:SetActiveCharge(charge+subcharge+1, ActiveSlot.SLOT_POCKET)
                end
                RickValues.HitCharge[p] = 0
            elseif RickValues.HitCharge[p]>=1 then
                if charge < 15 then
                    player:SetActiveCharge(charge+1, ActiveSlot.SLOT_POCKET)
                end
                RickValues.HitCharge[p] = 0
            end
        end
       
        --print("ayuda",RickValues.LockShield[p])
        end
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LOVESICK.EntityHit)

function LOVESICK:PickupKill(pickup) --from epiphany mod, thanks and all credit to them of this function
    pickup.EntityCollisionClass = 0
    pickup:PlayPickupSound()
    pickup:Remove()    
    pickup.Velocity = Vector(0, 0)    
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
    effect.Timeout = pickup.Timeout
    local sprite = effect:GetSprite()
    sprite:Load(pickup:GetSprite():GetFilename(), true)
    sprite:Play("Collect", true)
    pickup:Remove()
end

function  LOVESICK:OnNewRoom()
    if StageAPI.CustomStage("Limbo"):IsStage() then
        --print("Limbo")
    end
    for p = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(p)
        if RickValues.Tired[p] == 2 then 
            game:GetHUD():ShowItemText(tostring("Player "..(p+1).." is tired"), "Adrenaline rush ended", false) 
            RickValues.Tired[p] = RickValues.Tired[p] - 1
        end
        if runSave.persistent == nil then return end
        if runSave.persistent.MegasatanFix==true and runSave.persistent.MegasatanIsDead==true then
            player.Position = player.Position + Vector(0,-180)
            --local position
            if p == game:GetNumPlayers() - 1 then
                for _, ent in pairs(Isaac.GetRoomEntities()) do
                    --print(ent.Type,ent.Variant,ent.SubType)
                    if ent.Type == 274 and ent.SubType == 0 then -- position = ent.Position 
                        local Megasatan2 = Isaac.Spawn(275, 0, 0, player.Position, Vector(0,0), ent)
                        Megasatan2:Kill()
                    end
                    if ent.Type == 274 then ent:Remove() end
                end
            end
        end
    end
    newRoomDelay = 5
    --print("isnewroom")
    
    LOVESICK:IsItemUnlocked()
end
LOVESICK:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LOVESICK.OnNewRoom)

function LOVESICK:preHeartCollision(Pickup, Entity, Low)
    if Entity.Type == 1 then
        local player = Entity:ToPlayer()
        local number = getPlayerId(player)
        --print("colliding",(player:GetSoulHearts()+ player:GetEffectiveMaxHearts())>=(24-(player:GetBrokenHearts()*2)))
        if player:GetPlayerType() == rickId  then   --and RickValues.LockShield[number] > 0
            local charge=player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
            local subcharge = player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
            if Pickup.Variant == PickupVariant.PICKUP_HEART then
                if (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY,false)and subcharge < 15) or charge < 15 and not Pickup:IsShopItem() then
                    --print((player:GetSoulHearts()+ player:GetEffectiveMaxHearts())>=(24-(player:GetBrokenHearts()*2)))
                    if player:GetHearts() >= player:GetEffectiveMaxHearts() then
                        if Pickup.SubType == 1 then
                            LOVESICK:PickupKill(Pickup)
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
                            LOVESICK:PickupKill(Pickup)
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
                            LOVESICK:PickupKill(Pickup)
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
                            LOVESICK:PickupKill(Pickup)
                            sfxManager:Play(SoundEffect.SOUND_THE_FORSAKEN_SCREAM, 0.5,  8, false, 1)
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
                            LOVESICK:PickupKill(Pickup)
                            sfxManager:Play(SoundEffect.SOUND_PESTILENCE_COUGH, 0.6,  8, false, 1)
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
                            LOVESICK:PickupKill(Pickup)
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
                            LOVESICK:PickupKill(Pickup)
                            sfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 0.6,  8, false, 1)
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
                            LOVESICK:PickupKill(Pickup)
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
                            LOVESICK:PickupKill(Pickup)
                            sfxManager:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 0.5,  8, false, 1)
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
LOVESICK:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, LOVESICK.preHeartCollision)

function LOVESICK:HeartbeatVisibility(player)
    
    LOVESICK:ReloadDataNeeded()
    local player = player:ToPlayer()
    local p = getPlayerId(player)
    if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) and player:GetPlayerType() == rickId  then
        RickValues.ShowPulseTime[getPlayerId(player)] = math.max(settings.TimeBPM,RickValues.ShowPulseTime[getPlayerId(player)])
    end
    if player:HasCollectible(Isaac.GetItemIdByName("Painting Kit"), false) or player:HasCollectible(Isaac.GetItemIdByName("Kind Soul"), false) 
    or player:HasCollectible(Isaac.GetItemIdByName("Sunset Clock"), false) or player:HasTrinket(Isaac.GetTrinketIdByName("Paper Rose")) then
        LOVESICK:UpdateCache(player)
    end
    if runSave.persistent.MorphineDebuff[p] == nil then runSave.persistent.MorphineDebuff[p] = 0 end
    if runSave.persistent.LoveLetterShame[p] == nil then runSave.persistent.LoveLetterShame[p] = 0 end
    if runSave.persistent.MorphineDebuff[p]  > 0 or runSave.persistent.LoveLetterShame[p]  > 0 then
        --print(runSave.persistent.LoveLetterShame[p])
        LOVESICK:UpdateCache(player)
    end
    if RickValues.Adrenaline[p] == true then
        LOVESICK:UpdateCache(player)
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LOVESICK.HeartbeatVisibility)
function LOVESICK:ReloadDataNeeded()
    if settings.HideBPM == nil or achievements.Faith == nil then
        LOVESICK.LoadModData()
        settings = dataCache.file.settings  
        achievements = dataCache.file.achievements 
        runSave = dataCache.run
        runSave.persistent.MorphineTime = {}
        runSave.persistent.MorphineDebuff = {}
        runSave.persistent.LoveLetterShame = {}
    end
    if settings ~= dataCache.file.settings or achievements ~= dataCache.file.achievements  then 
        LOVESICK.LoadModData()
        settings = dataCache.file.settings  
        achievements = dataCache.file.achievements 
        runSave = dataCache.run
        runSave.persistent.MorphineTime = {}
        runSave.persistent.MorphineDebuff = {}
        runSave.persistent.LoveLetterShame = {}
    end 
end

function LOVESICK:IsItemUnlocked()
    LOVESICK:ReloadDataNeeded()
    --print("chechking")
    for i, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP then
            if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                if entity.SubType == Isaac.GetItemIdByName("Neck Gaiter") and not achievements.Faith.Satan then
                    LOVESICK:MorphCollectible(entity)
                    --print("1")
                end
                if entity.SubType == Isaac.GetItemIdByName("Painting Kit") and not achievements.Faith.TheLamb then
                    LOVESICK:MorphCollectible(entity)
                    --print("2")
                end
                if entity.SubType == Isaac.GetItemIdByName("Box of Leftovers") and not achievements.Faith.MegaSatan then
                    LOVESICK:MorphCollectible(entity)
                    --print("3")
                end
                if entity.SubType == Isaac.GetItemIdByName("Sunset Clock") and not achievements.Faith.Delirium then
                    LOVESICK:MorphCollectible(entity)
                    --print("4")
                end
                if entity.SubType == Isaac.GetItemIdByName("Birthday Cake") and not achievements.Faith.Mother then
                    LOVESICK:MorphCollectible(entity)
                    --print("5")
                end
                if entity.SubType == Isaac.GetItemIdByName("Arrest Warrant") and not achievements.Faith.Hush then
                    LOVESICK:MorphCollectible(entity)
                    --print("6")
                end
                if entity.SubType == Isaac.GetItemIdByName("Morphine") and not achievements.Faith.Beast then
                    LOVESICK:MorphCollectible(entity)
                    --print("7")
                end
                if entity.SubType == Isaac.GetItemIdByName("Kind Soul") and not achievements.Faith.Greed then
                    LOVESICK:MorphCollectible(entity)
                    --print("8")
                end
                if entity.SubType == Isaac.GetItemIdByName("Love Letter") and not achievements.Faith.Greedier then
                    LOVESICK:MorphCollectible(entity)
                    --print("9")
                end
                if entity.SubType == Isaac.GetItemIdByName("Sleeping Pills") and not (achievements.Faith.Beast and achievements.Faith.BlueBaby and achievements.Faith.BossRush and achievements.Faith.Delirium 
                and achievements.Faith.Greed and achievements.Faith.Greedier and achievements.Faith.Hush and achievements.Faith.Isaac 
                and achievements.Faith.MegaSatan and achievements.Faith.Mother and achievements.Faith.Satan and achievements.Faith.TheLamb) then
                    entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, false, true, true)
                    --print("10")
                end
            elseif entity.Variant == PickupVariant.PICKUP_TRINKET then
                if entity.SubType == Isaac.GetTrinketIdByName("Paper Rose") and not achievements.Faith.BossRush then
                    entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, false, true, true)
                    --print("11")
                    --entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, -1, false, true, true)
                end
            end
        end
    end
end

function LOVESICK:MorphCollectible(collectibleEntity)
    if not collectibleEntity:ToPickup():IsShopItem() then
        collectibleEntity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, false, true, true)
    else
        collectibleEntity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true, true, true)
        --print("heeelp")
    end
end

function HeartBeat()
    --print("Heartbeat of ",p)
    for p=0, game:GetNumPlayers()-1 do
        local p = p
        
        --print("heartbeat", p,RickValues.newFPS[p])
    local player= Isaac.GetPlayer(p)
    if player:GetPlayerType() == rickId  then
        if RickValues.newFPS[p]~=RickValues.oldFPS[p] then
            if player:HasCollectible(Isaac.GetItemIdByName("Locked Heart"), true) and RickValues.LockShield[p] <= 0 and RickValues.CalmDelay[p] <= 0 then
                --print("Charge heart")
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
            
            --print("latido",curTime)
            --print(RickValues.newFPS[p],RickValues.oldFPS[p])
            if monitor[p]:IsFinished("Normal") or monitor[p]:IsFinished("Low Stress") or monitor[p]:IsFinished("Mid Stress") or monitor[p]:IsFinished("Lowest Pulse") or monitor[p]:IsFinished("High Stress") or monitor[p]:IsFinished("Low Pulse") then
            if RickValues.Stress[p] >=(5*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 5
                monitor[p]:Play("High Stress", true)
                sfxManager:Play(SoundEffect.SOUND_HEARTBEAT_FASTER, 1.2,  1, false, 1)
            elseif RickValues.Stress[p] >=(4*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 4
                monitor[p]:Play("Mid Stress", true) 
                sfxManager:Play(SoundEffect.SOUND_HEARTBEAT_FASTER, 1,  5, false, 1)
            elseif RickValues.Stress[p] >=(3*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 3
                monitor[p]:Play("Low Stress", true)               
                sfxManager:Play(SoundEffect.SOUND_HEARTBEAT_FASTER, 1,  8, false, 1)
            elseif RickValues.Stress[p] >=(2*RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 2
                monitor[p]:Play("Normal", true)
                sfxManager:Play(SoundEffect.SOUND_HEARTBEAT, 0.9,  14, false, 1)
            elseif RickValues.Stress[p] >=(RickValues.StressMax[p]/6) then
                RickValues.Color[p] = 1
                monitor[p]:Play("Low Pulse", true) 
                sfxManager:Play(SoundEffect.SOUND_HEARTBEAT, 0.8,  16, false, 1)
            else
                RickValues.Color[p] = 0
                monitor[p]:Play("Lowest Pulse", true)
                sfxManager:Play(SoundEffect.SOUND_HEARTBEAT, 0.6, 18, false, 1)
            end
            end
        end
        end
    end
end

function ShieldSpriteSelect(p)
    --print("nune",runSave.persistent.MorphineTime[p])
    LOVESICK:ReloadDataNeeded()
    if runSave.persistent.MorphineTime[p] == nil then runSave.persistent.MorphineTime[p] = 0 end
    if runSave.persistent.MorphineTime[p] > 0 then
        if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
            shield[p]:Play("6-b", true)
        end
        if runSave.persistent.MorphineTime[p] >= 90 then 
            --print("chivato 15")
            if shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("90-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 84 then
            --print("chivato 14")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("84-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 78 then
            --print("chivato 13")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("78-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 72 then
            --print("chivato 12")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("72-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 66 then
            --print("chivato 11")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("66-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 60 then
            --print("chivato 10")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("60-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 54 then
            --print("chivato 9")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("54-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 48 then
            --print("chivato 8")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("48-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 42 then
            --print("chivato 7")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("42-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 36 then
            --print("chivato 6")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("36-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 30 then
            --print("chivato 5")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("30-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 24 then
            --print("chivato 4")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("24-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 18 then
            --print("chivato 3")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("18-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] >= 12 then
            --print("chivato 2")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("6-b") then
                shield[p]:Play("12-b", false)
            end
        elseif runSave.persistent.MorphineTime[p] > 0 then
            --print("chivato 1")
            if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b")then
                shield[p]:Play("6-b", false)
            end
        end
    elseif Isaac.GetPlayer(p):GetPlayerType() == Isaac.GetPlayerTypeByName("Rick") then
        if shield[p]:IsPlaying("90-b") or shield[p]:IsPlaying("84-b") or shield[p]:IsPlaying("78-b") or shield[p]:IsPlaying("72-b") or shield[p]:IsPlaying("66-b") or shield[p]:IsPlaying("60-b") or shield[p]:IsPlaying("54-b") or shield[p]:IsPlaying("48-b") or shield[p]:IsPlaying("42-b") or shield[p]:IsPlaying("36-b") or shield[p]:IsPlaying("30-b") or shield[p]:IsPlaying("24-b") or shield[p]:IsPlaying("18-b") or shield[p]:IsPlaying("12-b") or shield[p]:IsPlaying("6-b") then
            shield[p]:Play("1", false)
        end
        if RickValues.LockShield[p] >= 15 then
            --print("chivato 15")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("15", false)
            end
        elseif RickValues.LockShield[p] >= 14 then
            --print("chivato 14")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("14", false)
            end
        elseif RickValues.LockShield[p] >= 13 then
            --print("chivato 13")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("13", false)
            end
        elseif RickValues.LockShield[p] >= 12 then
            --print("chivato 12")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("12", false)
            end
        elseif RickValues.LockShield[p] >= 11 then
            --print("chivato 11")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("11", false)
            end
        elseif RickValues.LockShield[p] >= 10 then
            --print("chivato 10")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("10", false)
            end
        elseif RickValues.LockShield[p] >= 9 then
            --print("chivato 9")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("9", false)
            end
        elseif RickValues.LockShield[p] >= 8 then
            --print("chivato 8")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("8", false)
            end
        elseif RickValues.LockShield[p] >= 7 then
            --print("chivato 7")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("7", false)
            end
        elseif RickValues.LockShield[p] >= 6 then
            --print("chivato 6")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("6", false)
            end
        elseif RickValues.LockShield[p] >= 5 then
            --print("chivato 5")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("5", false)
            end
        elseif RickValues.LockShield[p] >= 4 then
            --print("chivato 4")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("4", false)
            end
        elseif RickValues.LockShield[p] >= 3 then
            --print("chivato 3")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("3", false)
            end
        elseif RickValues.LockShield[p] >= 2 then
            --print("chivato 2")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("2", false)
            end
        elseif RickValues.LockShield[p] >= 0 then
            --print("chivato 1")
            if shield[p]:IsPlaying("15") or shield[p]:IsPlaying("14") or shield[p]:IsPlaying("13") or shield[p]:IsPlaying("12") or shield[p]:IsPlaying("11") or shield[p]:IsPlaying("10") or shield[p]:IsPlaying("9") or shield[p]:IsPlaying("8") or shield[p]:IsPlaying("7") or shield[p]:IsPlaying("6") or shield[p]:IsPlaying("5") or shield[p]:IsPlaying("4") or shield[p]:IsPlaying("3") or shield[p]:IsPlaying("2") or shield[p]:IsPlaying("1") then
                shield[p]:Play("1", false)
            end
        end
    end 
end

--LOVESICK:AddCallback(ModCallbacks.MC_POST_UPDATE, HeartBeat)


function LOVESICK:Stress()
    --LOVESICK:Barehanded()
    LOVESICK:ReloadDataNeeded()
    --print(runSave.MegasatanIsDead)
    if true then --runSave.persistent.MegasatanIsDead == true
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            local class = ent.EntityCollisionClass
            if ent.Type == EntityType.ENTITY_PICKUP and ent.Variant == PickupVariant.PICKUP_BIGCHEST then
                --ent.EntityCollisionClass = 3
                if runSave.persistent.MegasatanIsDead and runSave.persistent.MegasatanFix then
                    --print("nowait")
                    ent:ToPickup().Wait = 0
                else
                    --print("wait")
                    --ent:ToPickup().Wait = 999
                end
                --Isaac.GetPlayer():PlayExtraAnimation("TeleportUp")            
            end
        end
    end 
    for p=0, game:GetNumPlayers()-1 do
        local p = p
        local player= Isaac.GetPlayer(p)
        local renderPos 
            if game:GetRoom():IsMirrorWorld() then 
                renderPos = Vector(480-Isaac.WorldToScreen(player.Position).X,Isaac.WorldToScreen(player.Position).Y) 
            else
                renderPos = Isaac.WorldToScreen(player.Position) 
            end

            --Isaac.RenderText(tostring(MegasatanFix),renderPos.X,renderPos.Y-28, 0 ,1 ,0 ,0.8)
        LOVESICK:renderAchievement()
        LOVESICK:displayQueue()
        HeartbeatSpritePreload()
        LOVESICK:ReloadDataNeeded()
        
        if runSave.persistent.MorphineTime[p] ~= nil then 
            if runSave.persistent.MorphineTime[p] > 0 then
                ShieldSpriteSelect(p)
                shield[p]:Render(Vector(renderPos.X,renderPos.Y -24 ), Vector(0,0), Vector(0,0))
            end             
        end
        if player:GetPlayerType() == rickbId and newRoomDelay<=0 then
            LOVESICK:RenderBeat(player,renderPos)
        end
        if player:GetPlayerType() == rickId and newRoomDelay<=0 then
            
            --print(player.ControllerIndex, p, player.Parent)
            if RickValues.IsRick[p] ~= true then
                unNil(p)
            end
            if monitor[p]== nil then HeartbeatSpritePreload() end
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
            --print(RickValues.StressMax[p], RickValues.Stress[p])
            
            --print(RickValues.ShowPulseTime[p],RickValues.CalmDelay[p],p)
            --print(renderPos)
            
            --Isaac.RenderText(tostring(monitor[p].Color.B),renderPos.X,renderPos.Y-48, 0 ,1 ,0 ,0.8)
            --Isaac.RenderText(r..g..b,renderPos.X,renderPos.Y-18, 0 ,1 ,0 ,0.8)
            if RickValues.ShowPulseTime[p]> 0 and idle_timer <= 0 then 
                monitor[p]:Render(Vector(renderPos.X,renderPos.Y + 9 ), Vector(0,0), Vector(0,0))
                
            end
            if RickValues.LockShield[p] > 0 and idle_timer <= 0 then
                shield[p]:Render(Vector(renderPos.X,renderPos.Y -24 ), Vector(0,0), Vector(0,0))                
            end
            -- Execute this function every POST_RENDER. For example in the MC_POST_RENDER callback.
            if RickValues.newFPS[p] ~= RickValues.oldFPS[p] then
                RickValues.oldFPS[p] = RickValues.newFPS[p]
                monitor[p]:Update()
                if runSave.persistent.MorphineTime[p] == 0 then shield[p]:Update() end
                --print("update shield")
            end
            --print(RickValues.FPS[p],"FPS de:",p,"old ",RickValues.oldFPS[p]," new ",RickValues.newFPS[p]) 
            
            if (RickValues.ShowPulseTime[p] > 0 or Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) and idle_timer <= 0 then
                if RickValues.LockShield[p]> 0 and (HasSpiderMod or settings.ShieldNumberAlways) then
                    if settings.HideBPM and not HasSpiderMod then
                        Isaac.RenderText(tostring(math.floor(RickValues.LockShield[p])),renderPos.X-2,renderPos.Y+8, 0 , 0 ,0.5 ,0.8)
                    elseif not settings.HideBPM and not HasSpiderMod then
                        Isaac.RenderText(tostring(math.floor(RickValues.LockShield[p])),renderPos.X+4,renderPos.Y+8, 0 , 0 ,0.5 ,0.8)
                    else
                        Isaac.RenderText(tostring(math.floor(RickValues.LockShield[p])),renderPos.X+4,renderPos.Y+8, 0 , 0 ,0.5 ,0.8)
                    end
                end
                if HasSpiderMod or not settings.HideBPM then
                    if RickValues.LockShield[p]> 0  then
                        if not settings.ShieldNumberAlways and not HasSpiderMod then
                            Isaac.RenderText(tostring(math.floor(RickValues.Stress[p])),renderPos.X-7,renderPos.Y+8, r ,g ,b ,0.8)
                        else
                            Isaac.RenderText(tostring(math.floor(RickValues.Stress[p])),renderPos.X-16,renderPos.Y+8, r ,g ,b ,0.8)
                        end
                    else
                        Isaac.RenderText(tostring((math.floor(RickValues.Stress[p]))),renderPos.X-7,renderPos.Y+8, r ,g ,b ,0.8)
                    end
                end
            end
        end
    end
end
LOVESICK:AddCallback(ModCallbacks.MC_POST_RENDER, LOVESICK.Stress) --MC_POST_UPDATE 


function LOVESICK:LockedHeartUse(_,RNG,EntityPlayer,UseFlags)
    --print("LockedUse")
    local p = getPlayerId(EntityPlayer)
    ShieldSpriteSelect(p)
    local oldShield = RickValues.LockShield[p]
    local defaultDMG
    LOVESICK.LoadModData() 
    achievements = dataCache.file.achievements 
    --print(achievements.Faith)
    if stage >= 7 and achievements.Faith.BlueBaby then defaultDMG = 2 else defaultDMG = 1 end
    if EntityPlayer:GetPlayerType() == rickId then
    local stressDMG = (math.max(0,math.floor(10+RickValues.Stress[getPlayerId(EntityPlayer)]-RickValues.StressMax[getPlayerId(EntityPlayer)]/2)/20))*defaultDMG    
    local ActiveEnemies = 0
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        if ent:IsActiveEnemy(false) then
            ActiveEnemies = ActiveEnemies + 1
        end
    end
    if (EntityPlayer:GetNumKeys() > 0  or EntityPlayer:HasGoldenKey()) and  achievements.Faith.Isaac and ActiveEnemies>0 and RickValues.Tired[p]==0 then --oldShield < math.max(1,1+stressDMG) and
        if not EntityPlayer:HasGoldenKey() then EntityPlayer:AddKeys(-1) end
        game:GetHUD():ShowItemText(tostring("The heart of player "..(p+1).." rushes"), "Pulse Breakdown!", false)
        local charge=EntityPlayer:GetActiveCharge(ActiveSlot.SLOT_POCKET)        
        local subcharge = EntityPlayer:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
        local multiplier
        if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY,true) and EntityPlayer:GetNumKeys() > 2 then multiplier = 0.60 else multiplier = 1 end
        --print("chivato4", charge, subcharge, multiplier)
        --print(math.max(0,RickValues.LockShield[p]),multiplier*math.max(charge,subcharge))
        RickValues.LockShield[p] = math.floor(math.max(0,oldShield) + multiplier*(math.max(charge,subcharge)/2)*defaultDMG)
        RickValues.Stress[p] = RickValues.StressMax[p]
        RickValues.Adrenaline[p] = true

        sfxManager:Play(SoundEffect.SOUND_GOLDENKEY, 0.5, 0, false, 1.5)
        --print(RickValues.LockShield[p])
        RickValues.CalmDelay[p] = 5
        --print(RickValues.CalmDelay[p], p)
        if subcharge == 0 and EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT,true) then
            EntityPlayer:SetActiveCharge(EntityPlayer:GetActiveCharge(ActiveSlot.SLOT_POCKET)+7, ActiveSlot.SLOT_POCKET)
        end
    else
        --sfxManager:Play(SoundEffect.SOUND_WHISTLE, 0.5, 0, false, 1.7)
        sfxManager:Play(Isaac.GetSoundIdByName("Shield_Up"), 15,  8, false, 1)
        if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY,true) then multiplier = 0.75 else multiplier = 1 end
        RickValues.LockShield[p] = math.floor(math.max(0,oldShield)) + math.max(1+stressDMG,defaultDMG)*multiplier
        if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT,true) then
            EntityPlayer:SetActiveCharge(EntityPlayer:GetActiveCharge(ActiveSlot.SLOT_POCKET)+7, ActiveSlot.SLOT_POCKET)
        end
    end
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.LockedHeartUse, Isaac.GetItemIdByName("Locked Heart"))

function LOVESICK:OnModifyAction()
    LOVESICK:IsItemUnlocked()
end

LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.OnModifyAction)
LOVESICK:AddCallback(ModCallbacks.MC_USE_PILL, LOVESICK.OnModifyAction)
LOVESICK:AddCallback(ModCallbacks.MC_USE_CARD, LOVESICK.OnModifyAction)

function LOVESICK:checkIfSpiderMod()
    local HasIt = false
    for p=0, game:GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(p)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_MOD, false) then
            HasIt = true
        end
    end
    --print(HasIt)
    HasSpiderMod = HasIt 
end
function LOVESICK:checkIfSunsetClock()
    local HasIt = false
    for p=0, game:GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(p)
        if player:HasCollectible(Isaac.GetItemIdByName("Sunset Clock"), false) then
            HasIt = true
        elseif p == game:GetNumPlayers()-1 then
            HasIt = false
        end
    end
    HasSunsetClock = HasIt 
end

function Timer()
    achievement:Update()
    if preload == false then
        HeartbeatSpritePreload()
        preload = true
    end
            --MaxShieldPlayer()
    curTime = Game():GetFrameCount()
    Secs= math.floor(curTime/30)
    _120BPM = math.floor(curTime/6.00*4)
    _140BPM = math.floor(curTime/5.14*4)
    _130BPM = math.floor(curTime/5.54*4)
    _190BPM = math.floor(curTime/3.78*4)

    
    
    
    for p=0, game:GetNumPlayers()-1 do
        local number = p     
        if math.floor(Secs/10) ~= oldDecs then
            ShieldSpriteSelect(p)
            if runSave.persistent.MorphineTime[p] == nil then runSave.persistent.MorphineTime[p] = 0 else
                if runSave.persistent.MorphineTime[p] > 0 then shield[p]:Update() end
                
            end
        end
        --print(Secs,_120BPM,old120BPM)
        local player = Isaac.GetPlayer(p) 
        if newRoomDelay > 0 then newRoomDelay = math.max(0, newRoomDelay-1) end
        
        if achievement:IsFinished("Appear") then 
            idle_timer = idle_timer - 1 
            if idle_timer <= 0 or Input.IsActionPressed(ButtonAction.ACTION_ITEM , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_LEFT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_DOWN , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_UP , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_RIGHT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_DROP , player.ControllerIndex)  then 
            idle_timer = 0 
            sfxManager:Play(SoundEffect.SOUND_MENU_NOTE_HIDE, 1,  8, false, 1)
            achievement:Play("Dissapear", false) end
        end    
        if RickValues.FPS[p] == nil then unNil(p) end
        if player:GetPlayerType() == rickId then
            LOVESICK:checkIfSpiderMod()
            --print(RickValues.FPS[p],RickValues.oldFPS[p],RickValues.newFPS[p])
            RickValues.FPS[p] = (30/(RickValues.Stress[p]/3) )
            RickValues.newFPS[p] = math.floor(curTime/RickValues.FPS[p]) 
            HeartBeat()
            --print ("Jugdor",number)
        end
        if runSave.persistent.MorphineDebuff[p] == nil then runSave.persistent.MorphineDebuff[p] = 0 end
        
        if Secs ~= oldSecs then
            --print("help2",RickValues.Stress[p]) 
            if runSave.persistent.MorphineDebuff[p] ~= nil then runSave.persistent.MorphineDebuff[p]=math.max(0,runSave.persistent.MorphineDebuff[p]-0.1)end
            if runSave.persistent.MorphineTime[p] > 0 then runSave.persistent.MorphineTime[p] = runSave.persistent.MorphineTime[p] - 1 end
            if runSave.persistent.LoveLetterShame[p] ~= (nil and 0) then runSave.persistent.LoveLetterShame[p]=math.max(0,runSave.persistent.LoveLetterShame[p]-0.1)end
            local defaultDMG
            local level = Game():GetLevel()
            local stage = level:GetStage()
            if stage >= 7 then 
                defaultDMG = 2 
            else 
                defaultDMG = 1 
            end
            if player:GetPlayerType() == rickId and RickValues.LockShield[number]~=15 and RickValues.LockShield[number]>15*defaultDMG then RickValues.LockShield[number] = math.floor(RickValues.LockShield[number] -1) 
            end
            
            if number == game:GetNumPlayers()-1 then
                oldSecs = Secs 
                --print("esto2",Secs,oldSecs)
            end 
            if player:GetPlayerType() == rickId then
                
                --Aqui ersa
                if RickValues.FPS[number]== nil then else RickValues.FPS[number] = 30/(RickValues.Stress[number]/3) end
                if RickValues.newFPS[number]== nil then else RickValues.newFPS[number] = math.floor(curTime/RickValues.FPS[number]) end
                --print(number,RickValues.FPS[number],RickValues.newFPS[number],RickValues.oldFPS[number]) 
                --print(RickValues.Stress[p],p,RickValues.StressMax[p],player.Luck, player:GetPlayerType())
                --print(p)
                if RickValues.ShowPulseTime[p] > 0 and settings.TimeBPM <50 then
                    --print("1",RickValues.ShowPulseTime[p])
                    RickValues.ShowPulseTime[p] = RickValues.ShowPulseTime[p] - 1
                    --print("2",RickValues.ShowPulseTime[p])
                end
                if RickValues.CalmDelay[p] > 0 and RickValues.LockShield[p] <= 0 then
                    RickValues.CalmDelay[p] = RickValues.CalmDelay[p] -1
                elseif RickValues.LockShield[p] == 0 and RickValues.Adrenaline[p] == false then
                    local entityStressfull = 0
                    --print("help6",RickValues.Stress[p]) 
                    for _, ent in pairs(Isaac.GetRoomEntities()) do
                        local distance = math.floor(player.Position:Distance(ent.Position))
                        if ent:IsActiveEnemy(false) then
                            if distance < 100 then
                                entityStressfull = entityStressfull +1
                                local nerves = 50*player.Damage/(distance*((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())/(player:GetSoulHearts()+player:GetEffectiveMaxHearts())))
                                local renderPos = Isaac.WorldToScreen(ent.Position)
                                --Isaac.RenderText(tostring(nerves),renderPos.X,renderPos.Y-28, 0 ,1 ,0 ,0.8)
                                RickValues.Stress[p] = math.min(RickValues.Stress[p] + nerves ,RickValues.StressMax[p])
                            end
                        elseif ent.Type == EntityType.ENTITY_PROJECTILE then
                            if distance < 100 then
                                entityStressfull = entityStressfull +1
                                local bravery = player.Damage/5
                                RickValues.Stress[p] = math.min(RickValues.Stress[p] + bravery ,RickValues.StressMax[p])
                            end
                        end
                    end
                    --print("help5",RickValues.Stress[p],1/math.abs(player.Luck),RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck) ) 

                    if RickValues.Stress[p] > RickValues.StressMax[p]/2 and entityStressfull == 0 then
                        if (RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck) ) < RickValues.StressMax[p]/2 then 
                            RickValues.Stress[p] = RickValues.StressMax[p]/2
                            --print("1")
                        else RickValues.Stress[p] = RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck) 
                            --print("2")
                        end                        
                    elseif entityStressfull == 0 then
                        if (RickValues.Stress[p] + math.max(1/math.abs(player.Luck),player.Luck) ) > RickValues.StressMax[p]/2 then 
                            RickValues.Stress[p] = RickValues.StressMax[p]/2
                            --print("3")
                        else RickValues.Stress[p] = RickValues.Stress[p] + math.max(1/math.abs(player.Luck),player.Luck) 
                            --print("4",p, player.Position, player.Luck)
                        end
                    end
                    --print("help4",RickValues.Stress[p]) 

                elseif RickValues.Adrenaline[p] == true then
                    local ActiveEnemies = 0
                    for _, ent in pairs(Isaac.GetRoomEntities()) do
                        if ent:IsActiveEnemy(false) then
                            ActiveEnemies = ActiveEnemies + 1
                        end
                    end
                    if RickValues.Stress[p] > 15 then
                        RickValues.Stress[p] = RickValues.Stress[p] - 15*(((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())/(player:GetSoulHearts()+player:GetEffectiveMaxHearts()))/math.max(ActiveEnemies,1))
                    else
                        RickValues.Adrenaline[p] = false
                        RickValues.Tired[p] = 2
                        RickValues.Stress[p] = RickValues.Stress[p] +  RickValues.LockShield[p]*10
                        RickValues.LockShield[p] = 0
                        player:AnimateSad()
                    end
                end
                --print("esto1",Secs,oldSecs,number,game:GetNumPlayers()-1)
                  
                --print("help3",RickValues.Stress[p]) 
            
        end
            --print(runSave.persistent.MorphineTime[p])
            
                
            
            
            LOVESICK:checkIfSunsetClock()
            if runSave.level.SunsetClock == nil then 
                LOVESICK:ReloadDataNeeded() 
            elseif 
                runSave.level.SunsetClock > 0 then runSave.level.SunsetClock = runSave.level.SunsetClock -1  
                if HasSunsetClock and runSave.level.SunsetClock==0 then
                    player:UseCard(Card.CARD_SUN,UseFlag.USE_NOANIM) end
            end 
        
        end
        if _120BPM ~= old120BPM  then
            if number == game:GetNumPlayers()-1 then
                if number == game:GetNumPlayers()-1 then 
                    old120BPM = _120BPM
                end
            end
        end    
        if _130BPM ~= old130BPM  then
            if number == game:GetNumPlayers()-1 then 
                --old120BPM = _120BPM
            end
        end   
        if _140BPM ~= old140BPM  then
            if number == game:GetNumPlayers()-1 then 
                --old120BPM = _120BPM
            end
        end   
        if _190BPM ~= old190BPM  then
            --if beat[number]:GetFrame() == 6 then
            --    sfxManager:Play(Isaac.GetSoundIdByName("Beat_1"), 1,  8, false, 1.1)
            --end
            --if beat[number]:IsFinished("Easy") then
            --    beat[number]:Play("Easy",true)
            --end
            --beat[number]:Update()
            --if number == game:GetNumPlayers()-1 then 
            --    old190BPM = _190BPM
            --end
        end   
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_POST_UPDATE, Timer)

local function postNPCDeath(_,npc)
	for p = 0, game:GetNumPlayers() - 1 do
         
        
		local player = Isaac.GetPlayer(p)
		local playerType = player:GetPlayerType()
		local level = game:GetLevel()
		local levelStage = level:GetStage()
        if player:HasCollectible(Isaac.GetItemIdByName("Arrest Warrant"), true) then LOVESICK:ArrestWarrant(npc, player) end
        if game:GetVictoryLap() > 0 then return end
		if (playerType == rickId) then -- or playerType == Isaac.GetPlayerTypeByName("Rickb")
			if levelStage == LevelStage.STAGE5 then
				if npc.Type == EntityType.ENTITY_ISAAC then
					if playerType == rickId
					and achievements.Faith.Isaac ~= true
					then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_2.png")
						achievements.Faith.Isaac = true
					end
				elseif npc.Type == EntityType.ENTITY_SATAN then
					if playerType == rickId
					and achievements.Faith.Satan ~= true
					then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_4.png")
						achievements.Faith.Satan = true
					end
				end
			elseif levelStage == LevelStage.STAGE6 then
				if npc.Type == EntityType.ENTITY_ISAAC
				and npc.Variant == 1
				then
					if playerType == rickId
					and achievements.Faith.BlueBaby ~= true
					then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_1.png")
						achievements.Faith.BlueBaby = true
					end
				elseif npc.Type == EntityType.ENTITY_THE_LAMB then
					if playerType == rickId
					and achievements.Faith.TheLamb ~= true
					then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_3.png")
						achievements.Faith.TheLamb = true
					end
				elseif npc.Type == EntityType.ENTITY_MEGA_SATAN_2 then
					if playerType == rickId
					and achievements.Faith.MegaSatan ~= true
					then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_10.png")
						achievements.Faith.MegaSatan = true
					end
				end
			elseif levelStage == LevelStage.STAGE7
			and npc.Type == EntityType.ENTITY_DELIRIUM
			then
				if playerType == rickId
				and achievements.Faith.Delirium ~= true
				then
                        LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_5.png")
                        achievements.Faith.Delirium = true
				end
			elseif (levelStage == LevelStage.STAGE4_1 or levelStage == LevelStage.STAGE4_2)
			and npc.Type == EntityType.ENTITY_MOTHER
			and npc.Variant == 10
			then
				if playerType == rickId
				and achievements.Faith.Mother ~= true
				then
                    LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_6.png")
					achievements.Faith.Mother = true
                end
			end
		end
	end
    if npc:ToNPC():IsBoss() then
        if dataCache.run.persistent.BossQueue ~= nil then
            BossQueue = dataCache.run.persistent.BossQueue
        end
        local bossData = {npc.Type, npc.SubType, npc.Variant,}
        local IsCustomDeliFight = false
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if ent.Type == DELIRIUM_EX_TYPE and ent.Variant == DELIRIUM_EX_VARIANT then
                IsCustomDeliFight = true
            end
        end
        if not IsCustomDeliFight and not(npc.Type == DELIRIUM_EX_TYPE and npc.Variant == DELIRIUM_EX_VARIANT ) and not (npc.Type == EntityType.ENTITY_DELIRIUM) then
            LOVESICK:storeBossInQueue(bossData)
        else
            if not npc.Type == DELIRIUM_EX_TYPE  and not npc.Variant == DELIRIUM_EX_VARIANT and not npc.Parent then
                for _, ent in pairs(Isaac.GetRoomEntities()) do
                    if ent.Type == DELIRIUM_EX_TYPE and ent.Variant == DELIRIUM_EX_VARIANT then
                        local data = ent:GetData()
                        data.defeatedFoes = data.defeatedFoes + 1
                    end
                end
            end
        end
        if dataCache.run.persistent.BossQueue == nil then
            dataCache.run.persistent.BossQueue = BossQueue
        end
        
        LOVESICK.SaveModData()
        if npc.Type == DELIRIUM_EX_TYPE and npc.Variant == DELIRIUM_EX_VARIANT then
            local Deli = Isaac.Spawn(EntityType.ENTITY_DELIRIUM,0,0,npc.Position,Vector.Zero,npc)
            Deli.Parent = npc
            npc:Remove()
            Deli.HitPoints = 1
            Deli:TakeDamage(999,DamageFlag.DAMAGE_IGNORE_ARMOR,EntityRef(npc),0)
            --Deli:ToNPC().State = NpcState.STATE_DEATH
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                --print(ent.Type,ent.Variant,ent.SubType)
                if ent:IsBoss() and not ent.Type==EntityType.ENTITY_DELIRIUM then -- position = ent.Position 
                    ent:Remove()
                end
            end 
        end
        if npc.Type == EntityType.ENTITY_DELIRIUM then
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                --print(ent.Type,ent.Variant,ent.SubType)
                if ent.Type == EntityType.ENTITY_EFFECT and ent.Variant == EffectVariant.OCCULT_TARGET and ent.SubType == 20 then -- position = ent.Position 
                    ent:Remove()
                end
            end    
        end
    end
    
end

LOVESICK:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNPCDeath)

local function postNPCInit(_,npc)
    LOVESICK.LoadModData()
    if dataCache.file.settings.DeliRework == true and npc.SpawnerEntity.Type == nil  then
        Isaac.Spawn(DELIRIUM_EX_TYPE,DELIRIUM_EX_VARIANT,0,npc.Position,Vector.Zero,npc)
        npc:Remove()
    end
end
LOVESICK:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNPCInit, EntityType.ENTITY_DELIRIUM)

local function postEntityKill(_, entity)
	if game:GetVictoryLap() > 0 then return end
	if entity.Type ~= EntityType.ENTITY_BEAST then return end
	if entity.Variant ~= 0 then return end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local playerType = player:GetPlayerType()
		
		if (playerType == rickId) --or playerType == rickbId
		then
			if playerType == rickId
			and not achievements.Faith.Beast
			then
                LOVESICK:storeInQueue("gfx/ui/achievement/achievement_Rick_8.png")
				achievements.Faith.Beast = true
            end
		end
	end
end

LOVESICK:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, postEntityKill)

function LOVESICK:renderAchievement()
    local room = game:GetRoom()
  	local center = room:GetCenterPos()
  	local topLeft = room:GetTopLeftPos()
  	local pos = Isaac.WorldToRenderPosition(center, true)

  	-- Adjust position depending on room size
  	if (room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIV) then
  		pos = Isaac.WorldToRenderPosition(Vector(center.X, topLeft.Y*2.0), true)
  	elseif (room:GetRoomShape() == RoomShape.ROOMSHAPE_2x1 or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIH) then
  		pos = Isaac.WorldToRenderPosition(Vector(topLeft.X*5.5, center.Y), true)
  	elseif (room:GetRoomShape() >= RoomShape.ROOMSHAPE_2x2) then
  		pos = Isaac.WorldToRenderPosition(Vector(topLeft.X*5.5, topLeft.Y*2.0), true)
  	end
	achievement:Render(pos, Vector(0, 0), Vector(0, 0))	
end

function LOVESICK:GetScreenSize() -- By Kilburn himself.
    local room = game:GetRoom()
    local pos = Isaac.WorldToScreen(Vector(0, 0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)
    return rx * 2 + 13 * 26, ry * 2 + 7 * 26
end

function LOVESICK:obtainedAchievement(_sprite)
    --print("achievement")
    idle_timer = 60
	achievement:ReplaceSpritesheet(3, _sprite) -- Set the spritesheet
	-- It is important you set the proper spritesheet if you have multiple achievements!
	achievement:LoadGraphics() -- Load graphics
	idle_timer = 60 -- Set timer (amount of time the Achievement Paper will stay active)
	achievement:Play("Appear", false) -- Play the appearing animation
    sfxManager:Play(SoundEffect.SOUND_MENU_NOTE_APPEAR, 1,  8, false, 1)
	-- was obtained
    dataCache.file.achievements = achievements
    LOVESICK.SaveModData()
end

function LOVESICK:displayQueue()
    local enemies = 0
    for i, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and not entity:HasMortalDamage() then enemies = enemies + 1 end
    end
    --print(Game():GetRoom():IsClear(),enemies==0)
    if Game():GetRoom():IsClear() or enemies==0 then
        if (enemies <=0 or idle_timer <= 0) and UnlockQueue[1] ~= nil then
            LOVESICK:obtainedAchievement(LOVESICK:removeFromQueue())
        end
    end
end

function LOVESICK:OnNewStage()
    LOVESICK:ReloadDataNeeded()
    for p = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(p)
        if player:HasCollectible(Isaac.GetItemIdByName("Box of Leftovers"),false) then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, true, false, -1, 0)    
        end
        runSave.level.SunsetClock = 90
        runSave.level.KindSoulDead = {}
        runSave.level.KindSoulDead[p] = 0
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, LOVESICK.OnNewStage)

function LOVESICK:OnRoomClear()
    for p = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(p)
        LOVESICK:CakeSpawnFrends(player)
        LOVESICK:RestForAdrenalineRush(player)
    end
    if Game():GetRoom():GetBossID() == 55 and not runSave.persistent.MegasatanIsDead and settings.UseWorkaroundMegasatan then
        --LOVESICK:MegaSatanNoCutscene()
        return LOVESICK:MegaSatanNoCutscene()
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, LOVESICK.OnRoomClear)

function LOVESICK:CakeSpawnFrends(player)
    if player:HasCollectible(Isaac.GetItemIdByName("Birthday Cake"),false) then
        local size = Game():GetRoom():GetRoomShape()
        local amount
        if size >= 9 then amount = 2 elseif size==8 then amount = 3 else amount = 1 end
        amount = amount * player:GetCollectibleNum(Isaac.GetItemIdByName("Birthday Cake"), true)
        for n = 1, amount do
            player:AddMinisaac(player.Position, true) 
        end
    end
end

function LOVESICK:RestForAdrenalineRush(player)
    local p = getPlayerId(player)
    if player:GetPlayerType() == rickId  then
        if RickValues.Tired[p] == nil then return end
            if RickValues.Tired[p] == 2 then 
                game:GetHUD():ShowItemText(tostring("Player "..(p+1).." is tired"), "Adrenaline rush ended", false) 
            end
            if RickValues.Tired[p] > 0 then RickValues.Tired[p] = RickValues.Tired[p] -1 
                if RickValues.Tired[p] == 0 and not RickValues.Adrenaline[p]  then
                    player:AnimateHappy()
                    game:GetHUD():ShowItemText(tostring("The heart of player "..(p+1).." Recovered"), "Adrenaline rush avaliable", false)
                    sfxManager:Play(SoundEffect.SOUND_THUMBSUP, 0.5,  8, false, 1)
                end
            end
        end
end

function LOVESICK:MegaSatanNoCutscene()
    --print("MegaSatan")
    LOVESICK:ReloadDataNeeded()
    if runSave.persistent.MegasatanIsDead ~= true and settings.UseWorkaroundMegasatan then 
        runSave.persistent.MegasatanIsDead = true
        dataCache.run = runSave
        LOVESICK.SaveModData()
        local room = Game():GetRoom()          
        local player = Isaac.GetPlayer()
        local collectibleRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SAD_ONION)
        local voidChances = collectibleRNG:RandomInt(101)
        if voidChances >=(100-settings.VoidProbability) then
            local spawnPos = room:GetGridPosition(157)
            local portalEntity = Isaac.GridSpawn(GridEntityType.GRID_TRAPDOOR, 17, spawnPos, true)
            
            portalEntity.VarData = 1 
        
            if REPENTANCE then
        
                portalEntity:GetSprite():Load("gfx/grid/voidtrapdoor.anm2", true)
        
            else
        
                local sprite = portalEntity.Sprite
                sprite:ReplaceSpritesheet(0, "gfx/grid/voidtrapdoor.png")
                sprite:LoadGraphics()
                sprite:Load("gfx/grid/voidtrapdoor.anm2", true)
                portalEntity.Sprite = sprite
        
            end
        else
            --print("no luck 1")
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BIGCHEST, 0, room:GetCenterPos(), Vector(0, 0), player)
        return true
    else
        local room = Game():GetRoom()
        local player = Isaac.GetPlayer()
        local collectibleRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SAD_ONION)
        local voidChances = collectibleRNG:RandomInt(101)
        --print(voidChances)
        if voidChances >=(100-settings.VoidProbability) then
            local spawnPos = room:GetGridPosition(157)
            local portalEntity = Isaac.GridSpawn(GridEntityType.GRID_TRAPDOOR, 17, spawnPos, true)
            
            portalEntity.VarData = 1 
        
            if REPENTANCE then
        
                portalEntity:GetSprite():Load("gfx/grid/voidtrapdoor.anm2", true)
        
            else
        
                local sprite = portalEntity.Sprite
                sprite:ReplaceSpritesheet(0, "gfx/grid/voidtrapdoor.png")
                sprite:LoadGraphics()
                sprite:Load("gfx/grid/voidtrapdoor.anm2", true)
                portalEntity.Sprite = sprite
        
            end
        else
            --print("no luck 2")
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BIGCHEST, 0, room:GetCenterPos(), Vector(0, 0), player)
        return true
    end
end

function LOVESICK:ArrestWarrant(npc, player)
    local amount = player:GetCollectibleNum(Isaac.GetItemIdByName("Arrest Warrant"),true)
        
    if npc:IsChampion() or npc:IsBoss() then
        if npc:IsBoss() then amount = amount * 2 end
        --print(amount)
        for p = 1 , amount do
            --print(p)
            Isaac.Spawn(EntityType.ENTITY_PICKUP,20,0,Isaac.GetFreeNearPosition(npc.Position, 1),Vector(0,0),npc)
        end
    end
end

function LOVESICK:MorphineUse(_,RNG,EntityPlayer,UseFlags)
    HeartbeatSpritePreload()
    EntityPlayer:RemoveCollectible(Isaac.GetItemIdByName("Morphine"), true, ActiveSlot.SLOT_PRIMARY , true)
    sfxManager:Play(SoundEffect.SOUND_MEGA_ADDICTED, 1.2,  8, false, 1)
    EntityPlayer:AnimateHappy()
    local p = getPlayerId(EntityPlayer)
    if runSave.persistent.MorphineTime == nil then
        LOVESICK:ReloadDataNeeded()
        runSave.persistent.MorphineTime = {}
        runSave.persistent.MorphineTime[p] = 0
    end
    if runSave.persistent.MorphineDebuff == nil then
        LOVESICK:ReloadDataNeeded()
        runSave.persistent.MorphineDebuff = {}
        runSave.persistent.MorphineDebuff[p] = 0
    end
    if runSave.persistent.MorphineTime[p] == nil then
        runSave.persistent.MorphineTime[p] = 90
    else
        runSave.persistent.MorphineTime[p] = math.max(runSave.persistent.MorphineTime[p]+45,90)
    end
    --print(p,runSave.persistent.MorphineTime[p])


    
end

LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.MorphineUse, Isaac.GetItemIdByName("Morphine"))

function LOVESICK:LoveLetterUse(_,RNG,EntityPlayer,UseFlags)
    EntityPlayer:RemoveCollectible(Isaac.GetItemIdByName("Love Letter"), true, ActiveSlot.SLOT_PRIMARY , true)
    sfxManager:Play(SoundEffect.SOUND_BIRD_FLAP, 1.2,  8, false, 1)
    EntityPlayer:AnimateHappy()
    local p = getPlayerId(EntityPlayer)
    if settings.LovePoints == nil then
        settings.LovePoints = 1
    else settings.LovePoints = settings.LovePoints + 1
    end
    dataCache.file.settings = settings
    LOVESICK.SaveModData()
    if runSave.persistent.LoveLetterShame == nil then
        LOVESICK:ReloadDataNeeded()
        runSave.persistent.LoveLetterShame = {}
        runSave.persistent.LoveLetterShame[p] = 0
    end
    if runSave.persistent.LoveLetterShame[p] == nil then
        runSave.persistent.LoveLetterShame[p] = 1
    else
        runSave.persistent.LoveLetterShame[p] = math.max(runSave.persistent.LoveLetterShame[p]+0.5,1)
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.LoveLetterUse, Isaac.GetItemIdByName("Love Letter"))

function LOVESICK:Kind_Soul(entity)
    if entity.Variant == Isaac.GetEntityVariantByName("Kind Soul") then
        if not Input.IsActionPressed(ButtonAction.ACTION_DROP, entity.Player.ControllerIndex)  then
            if entity.IsFollower then
                entity:FollowParent()
                if entity.Velocity:Length() > entity.Player.MoveSpeed*10 then 
                    entity.Velocity = entity.Velocity:Normalized()*entity.Player.MoveSpeed*10
                end
            else
                entity:FollowParent()
                entity:AddToFollowers()
            end
        else
            entity.Velocity = Vector(0,0)
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if ent.Type == EntityType.ENTITY_PICKUP and ent.Variant == PickupVariant.PICKUP_LOCKEDCHEST and ent.SubType == ChestSubType.CHEST_CLOSED and Game():GetRoom():IsClear() then
                    entity:RemoveFromFollowers()
                    entity:FollowPosition(ent.Position)
                    local distance = entity.Position:Distance(ent.Position)
                    --print(distance)
                    if distance <=24 then
                        LOVESICK:ReloadDataNeeded()
                        runSave.level.KindSoulDead[getPlayerId(entity.Player)] = runSave.level.KindSoulDead[getPlayerId(entity.Player)] + 1
                        entity:Die()
                        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CROSS_POOF,0,entity.Position,Vector(0,0), nil)
                        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CRACKED_ORB_POOF,0,ent.Position,Vector(0,0), nil)
                        sfxManager:Play(SoundEffect.SOUND_HOLY, 0.8,  8, false, 1)
                        ent:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_ETERNALCHEST, 1, false, true, true)
                    end
                end
            end
        end        
        
        
        local x = entity.Velocity.X
        if x >=0 then
            entity.SpriteScale = Vector(-1,1)
        end
      --entity:MoveDelayed(5)
    end
  end
LOVESICK:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LOVESICK.Kind_Soul)

function LOVESICK:FamiliarCollision(entity,collider,low)
    --print("colliding",collider.Type, EntityType.ENTITY_PICKUP, collider.Variant, PickupVariant.PICKUP_LOCKEDCHEST, collider.SubType, ChestSubType.CHEST_CLOSED)
    if collider.Type == EntityType.ENTITY_PROJECTILE and entity.Variant == Isaac.GetEntityVariantByName("Kind Soul") then
        collider:Die()
        entity:TakeDamage(1,0,EntityRef(collider),20)
        --print(entity.HitPoints)
        if entity:HasMortalDamage() then
            entity:Die()
            runSave.level.KindSoulDead[getPlayerId(entity.Player)] = runSave.level.KindSoulDead[getPlayerId(entity.Player)] + 1
            Game():GetRoom():MamaMegaExplosion(entity.Position)
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if ent.Type == EntityType.ENTITY_PROJECTILE then
                  ent:Die()
                end
            end
            
        end
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, LOVESICK.FamiliarCollision)

function LOVESICK:SleepingPillsUse(_,RNG,EntityPlayer,UseFlags)
    local multiplier
    if EntityPlayer:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)then
        multiplier = 2
    else
        multiplier = 1
    end
    Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,PillColor.PILL_GOLD,EntityPlayer.Position,Vector(0,0), EntityPlayer)
    EntityPlayer:UsePill(PillEffect.PILLEFFECT_IM_DROWSY, PillColor.PILL_GOLD, UseFlag.USE_NOANIM|UseFlag.USE_NOANNOUNCER)
end
LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.SleepingPillsUse, Isaac.GetItemIdByName("Sleeping Pills"))

function LOVESICK:RenderBeat(player,renderPos)
    local p =  getPlayerId(player)
    --LOVESICK:ReloadDataNeeded()
    --print("bfs")
    beat[p]:Render(Vector(renderPos.X,renderPos.Y), Vector(0,0), Vector(0,0))
    note1[p]:Render(Vector(renderPos.X,renderPos.Y-35), Vector(0,0), Vector(0,0))
end

function LOVESICK:RestoreHairOnDice(_,RNG,EntityPlayer,UseFlags)
    if EntityPlayer:GetPlayerType() == rickId then
        --local RickHair = Isaac.GetCostumeIdByPath("gfx/characters/character_rick_hair.anm2")
        --Entityplayer:AddNullCostume(RickHair)
    end
end

LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.RestoreHairOnDice, CollectibleType.COLLECTIBLE_D4)
LOVESICK:AddCallback(ModCallbacks.MC_USE_ITEM, LOVESICK.RestoreHairOnDice, CollectibleType.COLLECTIBLE_D100)




function GetCurrentDimension() -- KingBobson: (get room dimension)
    --- get current dimension of room
    local level = Game():GetLevel()
    local roomIndex = level:GetCurrentRoomIndex()
    local currentRoomDesc = level:GetCurrentRoomDesc()
    local currentRoomHash = GetPtrHash(currentRoomDesc)
    for dimension = 0, 2 do
        local dimensionRoomDesc = level:GetRoomByIdx(roomIndex, dimension)
        local dimensionRoomHash = GetPtrHash(dimensionRoomDesc)
        if (dimensionRoomHash == currentRoomHash) then
            return dimension
        end
    end
    return nil
end



local eid = require("Lovesick_src.mod_compat.eid")  --define and import eid file
eid.register()      --Execute EID command

local modConfigMenu = require("Lovesick_src.mod_compat.modconfigmenu")  --define and import ModCongifMenu file
LOVESICK.LoadModData()      --Preload data to load settings into modConfigMenu
modConfigMenu:AddModConfigOptions(dataCache.file.settings,HasFixes)     --Execute ModConfigMenu Function with the table of settings, and if it has Standalone Rick_Fixes

print("Lovesick Loaded, V.".. Version)

function LOVESICK:AfterTear()
    --HeartBeat()
    --print(FPS)
    for p=0, game:GetNumPlayers()-1 do
        local player= Isaac.GetPlayer(p)
        --if player:GetPlayerType() == rickId then
            local ActiveEnemies = 0
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if ent:IsActiveEnemy(false) then
                    ActiveEnemies = ActiveEnemies + 1
                end
            end
            if player:GetPlayerType() == rickId and SevenValues.delay[p] == (nil or 0) then
                SevenValues.delay[p] = player.MaxFireDelay*10
            end
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if ent.Type == EntityType.ENTITY_PROJECTILE then
                    --print(ent.Color.A,ent.Color.R,ent.Color.G,ent.Color.B)
                end
            end            
            --print("tear")
            --StageAPI.SpawnCustomTrapdoor(game:GetRoom():GetCenterPos(),StageAPI.CustomStage("Glacier"), "gfx/grid/limbo_trapdoor.anm2", 24, false)
            --StageAPI.GotoCustomStage(StageAPI.CustomStage("Limbo"), false)
            --local portal =StageAPI.SpawnCustomTrapdoor(game:GetRoom():GetCenterPos(),StageAPI.CustomStage("Limbo"), "gfx/grid/limbotrapdoor.anm2", 1, false)
            --portal:GetSprite():Play("Opened",true)     
            --LOVESICK.LoadModData()
            --print(LOVESICK:HowLongIs(dataCache.run.persistent.BossQueue))
            --print(BossQueue[1][1],BossQueue[1][2],BossQueue[1][3])
            --print(LOVESICK:HowLongIs(dataCache.run.persistent.BossQueue),LOVESICK:HowLongIs(BossQueue))
        --end
        --DELI SOUND DOWN HERE
        --sfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 5,  8, false,0.5)
        LOVESICK.LoadModData()
        --print(dataCache.file.settings.DeliRework)

    end
end
LOVESICK:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, LOVESICK.AfterTear)


function LOVESICK:Barehanded()
    for p=0, game:GetNumPlayers()-1 do
        local player= Isaac.GetPlayer(p)
        if player:GetPlayerType() == rickbId then
            
            --print(math.floor(player.Velocity:Length()))
            if SevenValues.delay[p] == nil  then    SevenValues.delay[p] = 0    end
            local IsShooting = (0~=(player:GetShootingInput().X and player:GetShootingJoystick().X) or 0~=(player:GetShootingInput().Y and player:GetShootingJoystick().Y))
            if SevenValues.delay[p] <= 0 and IsShooting and not game:IsPaused() then
                player.CollisionDamage = player.Damage
                local closerAngle = player:GetShootingJoystick():GetAngleDegrees()
                local dist = player.TearRange
                for _, ent in pairs(Isaac.GetRoomEntities()) do
                    --print(ent.Type,ent.Variant,ent.SubType)
                    if player.Position:Distance(ent.Position) < dist and ent:IsActiveEnemy(false) then
                        closerAngle = (ent.Position-player.Position):GetAngleDegrees()
                        dist = player.Position:Distance(ent.Position)
                    end
                end                
                --if not closerEnt==nil then closerAngle = (player.Position-closerEnt.Position):GetAngleDegrees() else closerAngle = player:GetShootingJoystick() end
                SevenValues.delay[p] = math.abs(player.MaxFireDelay)*10
                player:SetMinDamageCooldown(math.floor(player.MaxFireDelay*5)) 
                player.Velocity = player.Velocity + Vector.FromAngle(closerAngle)*player.MoveSpeed*5
                sfxManager:Play(SoundEffect.SOUND_PUNCH, 0.5,  8, false, 1)
                

            elseif not game:IsPaused() then
                SevenValues.delay[p] = math.max(SevenValues.delay[p]-1,0)
            end
        end
    end
end





function LOVESICK:moveLogic(npc)

end

local state = NpcState.De

function LOVESICK:DeliExupdate(Delirium_EX)
    
    local RNG = Delirium_EX:GetDropRNG()
    local attackStyle
    local objetive
    local distanceObjetive = 999
    Delirium_EX.Velocity = Vector(0,0)
    --Delirium_EX.Acceleration = Vector(0,0)
    Delirium_EX.Position = Isaac.GetFreeNearPosition(Delirium_EX.Position, 1)
    local explodeContinuum = ProjectileParams()
        explodeContinuum.Spread = 90
        explodeContinuum.ChangeTimeout = 50
        explodeContinuum.BulletFlags = ProjectileFlags.EXPLODE | ProjectileFlags.SMART | ProjectileFlags.DECELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
        explodeContinuum.ChangeFlags = ProjectileFlags.CONTINUUM | ProjectileFlags.BURST
        explodeContinuum.Color = Color(0.8,1,1,1,1,1,1)
        explodeContinuum.Scale = 3
        explodeContinuum.ChangeVelocity = 12
        explodeContinuum.HomingStrength = 1
        explodeContinuum.FallingSpeedModifier = -40
    local flowerTears = ProjectileParams()
        flowerTears.Acceleration = 1.2
        flowerTears.WiggleFrameOffset = 100
        flowerTears.BulletFlags = ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CURVE_LEFT | ProjectileFlags.NO_WALL_COLLIDE
        flowerTears.ChangeFlags = ProjectileFlags.CURVE_RIGHT | ProjectileFlags.NO_WALL_COLLIDE
        flowerTears.ChangeTimeout = 15
        flowerTears.GridCollision = false
        flowerTears.Scale = 1.5
        flowerTears.Color = Color(0.8,1,1,1,1,1,1)
        flowerTears.HeightModifier = -1
        flowerTears.FallingSpeedModifier = -5
    local goofyAssTearRing = ProjectileParams()
        goofyAssTearRing.BulletFlags = ProjectileFlags.ORBIT_CW
        goofyAssTearRing.HeightModifier = 2
        goofyAssTearRing.FallingSpeedModifier = -5
        goofyAssTearRing.Color = Color(0.8,1,1,1,1,1,1)
        LOVESICK:LoadModData()
        local defeatedFoes = LOVESICK:HowLongIs(dataCache.run.persistent.BossQueue)
        local data = Delirium_EX:GetData()
        if data.MaxdefeatedFoes == nil then data.MaxdefeatedFoes = defeatedFoes end
        if data.defeatedFoes == nil then data.defeatedFoes = 0 end
        local targets = 0
    for p = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(p)
        local distance = Delirium_EX.Position:Distance(player.Position)
        
        if distance < distanceObjetive then
            distanceObjetive = distance
            objetive = player
        end
    end
    --print(Delirium_EX.Variant,Delirium_EX.SubType)
    if Delirium_EX.Variant == DELIRIUM_EX_VARIANT then
        if BossQueue == nil then 
            LOVESICK:LoadModData()
            BossQueue = dataCache.run.persistent.BossQueue
            if BossQueue == nil then Delirium_EX:Die()
            local Deli = Isaac.Spawn(EntityType.ENTITY_DELIRIUM,0,0,Delirium_EX.Position,Vector.Zero,Delirium_EX)
            Deli.Parent = Delirium_EX
            end
        end
        if dataCache.run.persistent.BossQueue ~= nil then BossQueue = dataCache.run.persistent.BossQueue end
        
        local player = Isaac.GetPlayer(0);
        local sprite = Delirium_EX:GetSprite()
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            --print(ent.Type,ent.Variant,ent.SubType)
            if ent:IsBoss() and (ent:IsVulnerableEnemy() or ent.Visible==true or ent:IsActiveEnemy(false)) then
                if ent.Type == DELIRIUM_EX_TYPE then
                    --print("IsDeli",targets)
                else
                targets = targets +1
                end
                if (ent:IsVulnerableEnemy()==false or ent.Visible==false) and ent.MaxHitPoints == ent.HitPoints and ent.FrameCount >=600 then
                    ent:Remove()
                end
            end
            if ent.Type == EntityType.ENTITY_EFFECT and ent.Variant == EffectVariant.OCCULT_TARGET and ent.SubType == 20 then -- position = ent.Position 
                ent.Color.A = ent.FrameCount/120
                --print(ent.FrameCount)
                if ent.FrameCount >= 120 then
                    ent:Remove()
                    local DefeatedFoe = LOVESICK:removeBossInQueue()
                    local minion = Isaac.Spawn(DefeatedFoe[1],DefeatedFoe[3],DefeatedFoe[2],ent.Position,Vector.Zero,Delirium_EX)
                    Delirium_EX.HitPoints = Delirium_EX.HitPoints - Delirium_EX.MaxHitPoints* (1/data.MaxdefeatedFoes)
                    data.defeatedFoes = data.defeatedFoes + 1
                    minion.MaxHitPoints = minion.MaxHitPoints + Delirium_EX.MaxHitPoints* (1/data.MaxdefeatedFoes)/2
                    minion.HitPoints = minion.MaxHitPoints
                    minion:GetSprite():Play("Appear",true)
                    minion.Parent = Delirium_EX
                    targets = targets + 1
                else
                    targets = targets + 1
                end
            end
        end
        if targets >= 3 then 
        else
            local freeSpace = Isaac.GetFreeNearPosition(Game():GetRoom():GetRandomPosition(20), 80)
            local mark =  Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.OCCULT_TARGET,20,freeSpace,Vector(0,0),Delirium_EX)
            mark.Color = Color(0,1,1,1,0.3,0.3,0)
            mark.SpriteScale = Vector(2,2)
        end
        debugText = debugText.." Targets:"..tostring(targets)
        --debugText = tostring(math.max((data.MaxdefeatedFoes-math.max(1,data.defeatedFoes))/data.MaxdefeatedFoes,0.9)).." "..tostring(data.defeatedFoes)
        if Delirium_EX.State == NpcState.STATE_INIT then
            debugText = "Init "
            sprite:Play("Scream",true) 
            sfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 5,  8, false,0.5)
            local MaxHp = math.max((runSave.persistent.TotalDamage / (runSave.persistent.TotalDamage + 80000)) * 40000,100)
            Delirium_EX.MaxHitPoints = math.max(math.min(math.floor(MaxHp),math.floor(runSave.persistent.TotalDamage)),1000)
            Delirium_EX.HitPoints = Delirium_EX.MaxHitPoints
            Delirium_EX.State = NpcState.STATE_IDLE           
        end
        if Delirium_EX.State == NpcState.STATE_IDLE then
            debugText = "Idle "..tostring(Delirium_EX.StateFrame).." "
            if sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink") then
                if Delirium_EX.StateFrame >= 60 then 
                    sprite:Play("Blink",true)
                    if RNG:RandomInt(3) == 0 then
                        sfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 5,  8, false,0.5)
                    end
                    Delirium_EX.StateFrame = 0
                    attackStyle = RNG:RandomInt(5)
                    if attackStyle == 0 then
                        Delirium_EX.State = NpcState.STATE_ATTACK2 
                    elseif attackStyle == 1 then
                        Delirium_EX.State = NpcState.STATE_ATTACK2
                    elseif attackStyle == 2 then
                        Delirium_EX.State = NpcState.STATE_MOVE
                    elseif attackStyle == 3 then
                        Delirium_EX.State = NpcState.STATE_ATTACK
                    elseif attackStyle == 4 then
                        Delirium_EX.State = NpcState.STATE_ATTACK
                    end 
                elseif sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink") then
                    sprite:Play("IdleNoLoop",true)
                end
                --debugText = (tostring(attackStyle).." DELI HP:"..math.floor(Delirium_EX.HitPoints).."/"..Delirium_EX.MaxHitPoints.." "..Delirium_EX.State)
            end
        end
        if Delirium_EX.State == NpcState.STATE_ATTACK then -- and Delirium_EX.StateFrame%60 == 0
            debugText = "Atk "
            if Delirium_EX.StateFrame >=80 then
                --change state here
                sprite:Play("Blink",true)
                if RNG:RandomInt(3) == 0 then
                    sfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 5,  8, false,0.5)
                end
                Delirium_EX.StateFrame = 0
                attackStyle = RNG:RandomInt(5)
                if attackStyle == 0 then
                    Delirium_EX.State = NpcState.STATE_IDLE 
                elseif attackStyle == 1 then
                    Delirium_EX.State = NpcState.STATE_IDLE
                elseif attackStyle == 2 then
                    Delirium_EX.State = NpcState.STATE_MOVE
                elseif attackStyle == 3 then
                    Delirium_EX.State = NpcState.STATE_ATTACK2
                elseif attackStyle == 4 then
                    Delirium_EX.State = NpcState.STATE_ATTACK2
                end 
            elseif Delirium_EX.StateFrame %30 == 0 then
                if Delirium_EX.ProjectileCooldown == 0 then
                    Delirium_EX:FireBossProjectiles(10, objetive.Position, 0.3 , explodeContinuum)
                    Delirium_EX.ProjectileCooldown = 20
                end    
            end
            if (sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink")) and Delirium_EX.StateFrame >= 40 then
                sprite:Play("Blink",true)
            elseif sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink") then
                sprite:Play("IdleNoLoop",true)
            end
        end
        if Delirium_EX.State == NpcState.STATE_ATTACK2 then -- and Delirium_EX.StateFrame%60 == 0
            debugText = "Atk2 "
            if Delirium_EX.StateFrame >= 60 then 
                sprite:Play("Blink",true)
                if RNG:RandomInt(3) == 0 then
                    sfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 5,  8, false,0.5)
                end
                Delirium_EX.StateFrame = 0
                attackStyle = RNG:RandomInt(5)
                if attackStyle == 0 then
                    Delirium_EX.State = NpcState.STATE_IDLE 
                elseif attackStyle == 1 then
                    Delirium_EX.State = NpcState.STATE_IDLE
                elseif attackStyle == 2 then
                    Delirium_EX.State = NpcState.STATE_MOVE
                elseif attackStyle == 3 then
                    Delirium_EX.State = NpcState.STATE_ATTACK
                elseif attackStyle == 4 then
                    Delirium_EX.State = NpcState.STATE_ATTACK
                end 
            end
            if Delirium_EX.StateFrame %20 == 0 then
                if Delirium_EX.ProjectileCooldown <= 0 then
                    Delirium_EX:FireProjectiles(Delirium_EX.Position, Vector(15,20), 9, flowerTears)
                end
                Delirium_EX.ProjectileCooldown = 10
            end
            if (sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink")) and Delirium_EX.StateFrame >= 100 then
                sprite:Play("Blink",true)
            elseif sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink") then
                sprite:Play("IdleNoLoop",true)
            end
            --debugText = (tostring(attackStyle).." DELI HP:"..math.floor(Delirium_EX.HitPoints).."/"..Delirium_EX.MaxHitPoints.." "..Delirium_EX.State)
        end
        if Delirium_EX.State == NpcState.STATE_MOVE then -- and Delirium_EX.StateFrame%60 == 0
            debugText = "Move "
            local freeSpace = Isaac.GetFreeNearPosition(Game():GetRoom():GetRandomPosition(20), 20)
            if Delirium_EX.Child == nil then
                Delirium_EX.Child = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.OCCULT_TARGET,20,freeSpace,Vector(0,0),Delirium_EX)
            else
                Delirium_EX.Child.SpriteScale = Vector(4,4)
                Delirium_EX.Child.Color = Color(0.8,1,1,1,250/250,235/250,215/250)
            end
            if (sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink")) and Delirium_EX.StateFrame >= 30 then
                Delirium_EX.StateFrame = 0
                Delirium_EX.Position = Delirium_EX.Child.Position
                Delirium_EX.Color = Color(1,1,1,1)
                sfxManager:Play(SoundEffect.SOUND_HELL_PORTAL1, 1,  8, false, 1)
                Delirium_EX.Child:Remove()
                attackStyle = RNG:RandomInt(5)
                --debugText = (tostring(attackStyle).." DELI HP:"..math.floor(Delirium_EX.HitPoints).."/"..Delirium_EX.MaxHitPoints.." "..Delirium_EX.State)
                if attackStyle == 0 then
                    Delirium_EX.State = NpcState.STATE_ATTACK 
                elseif attackStyle == 1 then
                    Delirium_EX.State = NpcState.STATE_ATTACK
                elseif attackStyle == 2 then
                    Delirium_EX.State = NpcState.STATE_ATTACK2
                elseif attackStyle == 3 then
                    Delirium_EX.State = NpcState.STATE_ATTACK2
                end 
                Delirium_EX.StateFrame = 0
            end
            if Delirium_EX.StateFrame %4 == 0 then
                Delirium_EX.Color = Color (1,1,1,(40-Delirium_EX.StateFrame)/40)
            end
            if sprite:IsFinished("Scream") or sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink") then
                if Delirium_EX.StateFrame >= 40 then 
                    sprite:Play("Blink",true)
                    if RNG:RandomInt(3) == 0 then
                        sfxManager:Play(SoundEffect.SOUND_DEATH_CARD, 5,  8, false,0.5)
                    end
                elseif sprite:IsFinished("IdleNoLoop") or sprite:IsFinished("Blink") then
                    sprite:Play("IdleNoLoop",true)
                end
            end
            --debugText = tostring(Delirium_EX.Child==nil)..tostring(Delirium_EX.StateFrame)
        end

    Delirium_EX.StateFrame = Delirium_EX.StateFrame +1
    Delirium_EX.ProjectileCooldown = math.max(Delirium_EX.ProjectileCooldown-1,0)
    debugText = debugText.." "..tostring(data.MaxdefeatedFoes).." "..tostring(data.defeatedFoes).." "
    debugText = debugText.."HP"..tostring(math.floor(Delirium_EX.HitPoints)).."/"..tostring(Delirium_EX.MaxHitPoints)
    end

end

function LOVESICK:debug_text()
    Isaac.RenderText(debugText, 100, 100, 255, 0, 0, 255)
    if runSave.persistent.TotalDamage == nil then runSave.persistent.TotalDamage = 0 end
    Isaac.RenderText(tostring(math.floor(runSave.persistent.TotalDamage*100)/100),40,80, 0 ,1 ,0 ,0.8)
end



LOVESICK:AddCallback(ModCallbacks.MC_NPC_UPDATE, LOVESICK.DeliExupdate, DELIRIUM_EX_TYPE);

function LOVESICK:storeBossInQueue(table) --Stuff to store a defeated boss
    if BossQueue[1] == nil then BossQueue[1] = table else
        for i, v in ipairs(BossQueue) do 
            if BossQueue[i][1] == table[1] and BossQueue[i][2] == table[2] and BossQueue[i][3] == table[3] then return 
            elseif BossQueue[i+1] == nil and BossQueue[i]~= nil then BossQueue[i+1] = table return end
        end
    end
end

function LOVESICK:removeBossInQueue() --Remove bosses in order of deffeat
    if BossQueue[1] == nil then return  else
            local OldFirstValue = BossQueue[1]
            for i, v in ipairs(BossQueue) do 
                if BossQueue[i+1] == nil and BossQueue[i]~= nil then BossQueue[i] = BossQueue[i+1] return OldFirstValue
            else
                BossQueue[i] = BossQueue[i+1]
            end
        end
    end
end

function LOVESICK:HowLongIs(_data)
    for i, v in ipairs(_data) do 
        if _data[i+1] == nil then return i end
    end
end

--LOVESICK:AddCallback(ModCallbacks.MC_POST_RENDER, LOVESICK.debug_text);