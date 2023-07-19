local enums = require("lovesick_source.enums")
local Item = enums.Item
local Trinket = enums.Trinket
local PlayerType = enums.PlayerType
local PlayerCode = require("lovesick_source.player_scripts")

local function post_Peffect_Update(_,player)
    if Game():GetVictoryLap() > 0 then return end
    if player:GetPlayerType() == PlayerType.Faithfull then
        PlayerCode.Faithfull.post_peffect_update()
    elseif player:GetPlayerType() == PlayerType.Snowball then
        PlayerCode.Snowball.post_peffect_update()
    end
end

return post_Peffect_Update