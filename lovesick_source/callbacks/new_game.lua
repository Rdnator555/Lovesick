local save = require("lovesick_source.save_manager")
local newGame = {}
newGame.IsContinued = nil
newGame.IsInit = false

function newGame.MC_POST_GAME_STARTED(_,continued)
    newGame.IsContinued = continued
    newGame.IsInit = true
    newGame.CheckSettings()
end

function newGame.CheckSettings()
    local saveData = save.GetData()
    if saveData.file.settings.TimeBPM == nil then saveData.file.settings.TimeBPM = 15 end
    if saveData.file.settings.HideBPM == nil then saveData.file.settings.HideBPM = true end
    if saveData.file.settings.DeliRework == nil then saveData.file.settings.DeliRework = false end
    if saveData.file.settings.ShieldNumberAlways == nil then saveData.file.settings.ShieldNumberAlways = false end
    if saveData.file.settings.VoidProbability == nil then saveData.file.settings.VoidProbability = 50 end
    if saveData.file.settings.UseWorkaroundMegasatan == nil then saveData.file.settings.UseWorkaroundMegasatan = false end
    save.EditData(saveData,nil)
end


return newGame