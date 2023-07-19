local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local achievements = require("lovesick_source.achievements")
local PlayerType = enums.PlayerType
local PlayerCode = require("lovesick_source.player_scripts")
local save = require("lovesick_source.save_manager")
local postUpdate = {}

function postUpdate.MC_POST_UPDATE()
    for n = 0, Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(n)
        local p = util.getPlayerIndex(player)
        local saveData = save.GetData()
        local persistent = saveData.run.persistent
        if persistent.LoveLetterShame and persistent.LoveLetterShame[p] > 0 and Game():GetFrameCount()%30 == 0 then 
            persistent.LoveLetterShame[p]=math.max(0,persistent.LoveLetterShame[p]-0.1) 
            save.EditData(persistent,"persistent") 
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY) --CacheFlag.CACHE_DAMAGE,
            player:EvaluateItems()
        end
        achievements.post_update(player,n)
        PlayerCode.Faithfull.post_update(player)
    end
end

return postUpdate