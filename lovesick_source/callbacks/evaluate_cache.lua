local patches = require("lovesick_source.items.patches")
local save = require("lovesick_source.save_manager")
local utility = require("lovesick_source.utility")
local enum = require("lovesick_source.enums")
local function onCache(_,player, cache)
    patches.onCache(player,cache)
    if player:GetPlayerType()==enum.PlayerType.Snowball then
        utility.SetbaseStats(player,cache,enum.BaseStats.Snowball)
    elseif player:GetPlayerType()==enum.PlayerType.Faithfull then
        utility.SetbaseStats(player,cache,enum.BaseStats.Faithfull)
        local saveData = save.GetData()
        local RickValues = saveData.run.persistent.RickValues
        local p = utility.getPlayerIndex(player)
        if RickValues and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then 
            RickValues.StressMax[p] = 360 elseif RickValues then RickValues.StressMax[p] = 240 
        end
        saveData.run.persistent.RickValues = RickValues
        local run = saveData.run
        save.EditData(run,"run")
    end
end

return onCache