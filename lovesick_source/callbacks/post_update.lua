local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local achievements = require("lovesick_source.achievements")
local PlayerType = enums.PlayerType
local PlayerCode = require("lovesick_source.player_scripts")
local postUpdate = {}

function postUpdate.MC_POST_UPDATE()
    for p = 0, Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(p)
        achievements.post_update(player,p)
        PlayerCode.Faithfull.post_update(player)
    end
end

return postUpdate