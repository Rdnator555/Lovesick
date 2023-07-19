local enums = require("lovesick_source.enums")
local Item = enums.Item
local Trinket = enums.Trinket
local PlayerType = enums.PlayerType
local PlayerCode = require("lovesick_source.player_scripts")

local function post_npc_death(_,npc)
    for p = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(p)
        if player:GetPlayerType() == PlayerType.Faithfull then
            PlayerCode.Faithfull.unlocks_NPC(npc)
        elseif player:GetPlayerType() == PlayerType.Snowball then
            PlayerCode.Snowball.unlocks_NPC(npc)
        end
    end
end 

return post_npc_death
