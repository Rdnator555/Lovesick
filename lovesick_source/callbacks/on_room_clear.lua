local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local treat = require("lovesick_source.items.snowball_treat")
local PlayerType = enums.PlayerType
local Trinket = enums.Trinket
local Item = enums.Item
local onRoomClear = {}
function onRoomClear.MC_PRE_SPAWN_CLEAN_AWARD()
    for p = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(p)
        onRoomClear.CakeSpawnFrends(player)
        onRoomClear.RestForAdrenalineRush(player)
    end
end

function onRoomClear.CakeSpawnFrends(player)
    if player:HasCollectible(Item.BirthdayCake,true) then
        local size = Game():GetRoom():GetRoomShape()
        local amount
        if size >= 9 then amount = 2 elseif size==8 then amount = 3 else amount = 1 end
        amount = amount * player:GetCollectibleNum(Item.BirthdayCake, true)
        for n = 1, amount do
            player:AddMinisaac(player.Position, true) 
        end
    end
end

function onRoomClear.RestForAdrenalineRush(player)
    local p = util.getPlayerIndex(player)
    local saveData = save.GetData()
    local RickValues = saveData.run.persistent.RickValues
    if RickValues == nil then return end
    if player:GetPlayerType() == PlayerType.Faithfull then
        if RickValues.Tired == nil then return end
        if RickValues.Tired[p] == nil then return end
        if RickValues.Tired[p] == 2 then 
            Game():GetHUD():ShowItemText(tostring("Player "..(p+1).." is tired"), "Adrenaline rush ended", false) 
        end
        if RickValues.Tired[p] > 0 then 
            RickValues.Tired[p] = RickValues.Tired[p] -1 
            if RickValues.Tired[p] == 0 and not RickValues.Adrenaline[p]  then
                player:AnimateHappy()
                Game():GetHUD():ShowItemText(tostring("The heart of player "..(p+1).." Recovered"), "Adrenaline rush avaliable", false)
                SFXManager():Play(SoundEffect.SOUND_THUMBSUP, Options.SFXVolume,  8, false, 1)
            end
        end
    end
    save.EditData(RickValues,"RickValues")
end
return onRoomClear