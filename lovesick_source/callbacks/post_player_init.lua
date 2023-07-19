local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local PlayerType = enums.PlayerType
local Trinket = enums.Trinket
local Item = enums.Item
local PlayerCode = require("lovesick_source.player_scripts")

local function postPlayerInit(_,player)
    local rng = player:GetDropRNG()
    local data = player:GetData()
    if player:GetPlayerType() == PlayerType.Snowball then
        PlayerCode.Snowball.post_player_init(data,player)
    end
    if player:GetPlayerType() == PlayerType.Faithfull then
        PlayerCode.Faithfull.post_player_init(data,player)
    end
end
return postPlayerInit