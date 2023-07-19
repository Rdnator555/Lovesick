-- MAKE SURE TO REPLACE ALL INSTANCES OF "save" WITH YOUR ACTUAL save REFERENCE
-- Made by Slugcat. Report any issues to her.
-- All credit to her, thanks for such is an awesome tool! --Rdnator55Dev
local save = {}
save.mod=nil
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
function save.DefaultSave()
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
            achievements = {

            },
            dss = {},
            settings = {},
            misc = {},
        },
    }
end

---@return RunSave
function save.DefaultRunSave()
    return {
        persistent = {},
        level = {},
        room = {},
    }
end

function save.DeepCopy(tab)
    local copy = {}
    for k, v in pairs(tab) do
        if type(v) == 'table' then
            copy[k] = save.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---@return boolean
function save.IsDataLoaded()
    return loadedData
end

function save.PatchSaveTable(deposit, source)
    source = source or save.DefaultSave()

    for i, v in pairs(source) do
        if deposit[i] ~= nil then
            if type(v) == "table" then
                if type(deposit[i]) ~= "table" then
                    deposit[i] = {}
                end

                deposit[i] = save.PatchSaveTable(deposit[i], v)
            else
                deposit[i] = v
            end
        else
            if type(v) == "table" then
                if type(deposit[i]) ~= "table" then
                    deposit[i] = {}
                end

                deposit[i] = save.PatchSaveTable({}, v)
            else
                deposit[i] = v
            end
        end
    end

    return deposit
end

function save.SaveModData()
    if not loadedData then
        return
    end

    -- Save backup
    local backupData = save.DeepCopy(dataCacheBackup)
    dataCache.hourglassBackup = save.PatchSaveTable(backupData, save.DefaultRunSave())

    local finalData = save.DeepCopy(dataCache)
    finalData = save.PatchSaveTable(finalData, save.DefaultSave())

    save.mod:SaveData(json.encode(finalData))
end

function save.RestoreModData()
    if shouldRestoreOnUse then
        skipNextRoomClear = true
        local newData = save.DeepCopy(dataCacheBackup)
        dataCache.run = save.PatchSaveTable(newData, save.DefaultRunSave())
        dataCache.hourglassBackup = save.PatchSaveTable(newData, save.DefaultRunSave())
    end
end

function save.LoadModData()
    if loadedData then
        return
    end

    local saveData = save.DefaultSave()

    if save.mod:HasData() then
        local data = json.decode(save.mod:LoadData())
        saveData = save.PatchSaveTable(data, save.DefaultSave())
    end

    dataCache = saveData
    dataCacheBackup = dataCache.hourglassBackup
    loadedData = true
    inRunButNotLoaded = false
end

---@return table?
function save.GetRunPersistentSave()
    if not loadedData then
        return
    end

    return dataCache.run.persistent
end

---@return table?
function save.GetLevelSave()
    if not loadedData then
        return
    end

    return dataCache.run.level
end

---@return table?
function save.GetRoomSave()
    if not loadedData then
        return
    end

    return dataCache.run.room
end

---@return table?
function save.GetFileSave()
    if not loadedData then
        return
    end

    return dataCache.file
end

local function ResetRunSave()
    dataCache.run = save.DefaultRunSave()
    dataCache.hourglassBackup = save.DefaultRunSave()
    dataCacheBackup = save.DefaultRunSave()

    save.SaveModData()
end



function save.postPlayerInit()
    local newGame = Game():GetFrameCount() == 0

    skipNextLevelClear = true
    skipNextRoomClear = true

    save.LoadModData()

    if newGame then
        ResetRunSave()
        shouldRestoreOnUse = false
    end
end

function save.postUpdate()
    local game = Game()
    if game:GetFrameCount() > 0 then
        if not loadedData and inRunButNotLoaded then
            save.LoadModData()
            inRunButNotLoaded = false
            shouldRestoreOnUse = true
        end
    end
end

--- Replace YOUR_MOD_NAME with the name of your save, as defined in RegisterMod!
--- This handles the "luamod" command!
function save.modUnload(_, save)
    if save == save.mod and Isaac.GetPlayer() ~= nil then
        if loadedData then
            save.SaveModData()
        end
    end
end

function save.postNewRoom()
    if not skipNextRoomClear then
        dataCacheBackup.persistent = save.DeepCopy(dataCache.run.persistent)
        dataCacheBackup.room = save.DeepCopy(dataCache.run.room)
        dataCache.run.room = save.DeepCopy(save.DefaultRunSave().room)
        save.SaveModData()
        shouldRestoreOnUse = true
    end

    skipNextRoomClear = false
end

function save.postNewLevel()
    if not skipNextLevelClear then
        dataCacheBackup.persistent = save.DeepCopy(dataCache.run.persistent)
        dataCacheBackup.level = save.DeepCopy(dataCache.run.level)
        dataCache.run.level = save.DeepCopy(save.DefaultRunSave().level)
        save.SaveModData()
        shouldRestoreOnUse = true
    end

    skipNextLevelClear = false
end

function save.preGameExit(_, shouldSave)
    save.SaveModData()
    loadedData = false
    inRunButNotLoaded = false
    shouldRestoreOnUse = false
end

function save.GetData()
    save.SaveModData()
    save.LoadModData()
    return dataCache
end

---@param newData any
---@param typeData string|nil settings,achievements,run,RickValues,Achievements,BossQueue
function save.EditData(newData,typeData)
    --print("[Editing data!]")
    if typeData == "settings" then
    elseif typeData == "settings" then
        dataCache.file.settings = newData or dataCache.file.settings
    elseif typeData == "achievements" then
        dataCache.file.achievements = newData or dataCache.file.achievements
    elseif typeData == "run" then
        dataCache.run = newData or dataCache.run
    elseif typeData == "persistent" then
        dataCache.run.persistent = newData or dataCache.run.persistent
    elseif typeData == "RickValues" then
        dataCache.run.persistent.RickValues = newData or dataCache.run.persistent.RickValues
    elseif typeData == "UnlockQueue" then
        dataCache.file.misc.UnlockQueue = newData or dataCache.file.misc.UnlockQueue
    elseif typeData == "BossQueue" then
        dataCache.file.misc.BossQueue = newData or dataCache.file.misc.BossQueue
    elseif typeData == nil then 
        dataCache = newData
    end
    save.SaveModData()
end

return save