local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local achievements = require("lovesick_source.achievements")
local PlayerCode = require("lovesick_source.player_scripts")
local Item = enums.Item
local Trinket = enums.Trinket
local PlayerType = enums.PlayerType
local render = {}

local function post_render()
    achievements.render_achievement()
    achievements.displayQueue()
    for n=0, Game():GetNumPlayers()-1 do
        local player= Isaac.GetPlayer(n)
        --local p = util.getPlayerIndex(player)
        if player:GetPlayerType()==PlayerType.Faithfull then
            PlayerCode.Faithfull.post_render(player)
        end
        PlayerCode.Faithfull.morphine_update(player)
    end
end

return post_render