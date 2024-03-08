local unlockManager = {}
local enums = require("lovesick-src.LovesickEnums")

---@param isContinued boolean|nil
---@param completionType CompletionType|nil
function unlockManager:checkUnlocks(isContinued, completionType)
    for name, PlayerType in pairs(enums.PlayerType) do
        if PlayerType > 0 and enums.CompletionTypeToAchievement[name] then
            if LOVESICK.debug then print("For the player",name," checking achievements values") end
            local completionToAchievement = enums.CompletionTypeToAchievement[name]
            for key, value in pairs(CompletionType) do
                local isCompleted = Isaac.GetCompletionMark(PlayerType, value)==2
                local achievementToCheck = completionToAchievement[value]
                if LOVESICK.debug then print(key,value,isCompleted,achievementToCheck) end
                if isCompleted and not LOVESICK.persistentGameData:Unlocked(achievementToCheck) then 
                    local val = LOVESICK.persistentGameData:TryUnlock(achievementToCheck)
                    if not val then
                        ImGui.PushNotification("Error, the achievement nº"..achievementToCheck.."couldn't unlock propperly, maybe is already unlocked?",ImGuiNotificationType.ERROR)
                    end
                elseif not isCompleted and LOVESICK.persistentGameData:Unlocked(achievementToCheck) then
                    local command = "lockachievement "..achievementToCheck
                    Isaac.ExecuteCommand(command)
                end
            end
        end
    end
end



return unlockManager