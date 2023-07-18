local enums = require("lovesick_source.enums")
local Item = enums.Item
local Trinket = enums.Trinket
local PlayerType = enums.PlayerType
local PlayerCode = require("lovesick_source.player_scripts")

local function post_Entity_Kill(_,entity)
    for p = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
        if player:GetPlayerType() == PlayerType.Faithfull then
            PlayerCode.Faithfull.post_entity_kill(entity)
        elseif player:GetPlayerType() == PlayerType.Snowball then
            PlayerCode.Snowball.post_entity_kill(entity)
        end
    end
end

return post_Entity_Kill