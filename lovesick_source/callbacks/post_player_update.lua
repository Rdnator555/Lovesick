local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local newGame = require("lovesick_source.callbacks.new_game")
local PlayerType = enums.PlayerType
local Trinket = enums.Trinket
local PlayerCode = require("lovesick_source.player_scripts")

local function post_player_update(_,player)
    local saveData = save.GetData()
    local rng = player:GetDropRNG()
    local data = player:GetData()
    local dataCache = save.GetData()
    local p = util.getPlayerIndex(player)
    if data.NoDeathAnim == true and player:GetSprite():IsPlaying("Death") then
        player:GetSprite():SetLastFrame()
        player:GetSprite():Update()
        if Game():GetLevel():GetCurrentRoomIndex() == dataCache.run.level.mimikyu[p].Index then
            player.Position = Vector(dataCache.run.level.mimikyu[p].Position[1],dataCache.run.level.mimikyu[p].Position[2])
            data.NoDeathAnim = false
            data.Yipee = false
            data.PatchQueue = dataCache.run.level.mimikyu[p].Patches
            local mimikyu = Isaac.FindInRadius(player.Position,30,EntityPartition.ENEMY)
            local distance = 20
            local newMimikyu
            for i = 1,#mimikyu do
                    if (mimikyu[i].Position.X == dataCache.run.level.mimikyu[p].Position[1]) and (mimikyu[i].Position.Y == dataCache.run.level.mimikyu[p].Position[2])  then
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                            if  rng:RandomInt(1) == 0 then mimikyu[i]:Remove() end
                        else
                            mimikyu[i]:Remove()
                        end
                    break
                end
            end
            dataCache.run.level.mimikyu[p] = nil
        end
    elseif data.Yipee == true then
        player:AnimateHappy()
        data.Yipee = false
    end
    if saveData.run.persistent.Init == nil then saveData.run.persistent.Init = {} end
    if player:GetPlayerType() == PlayerType.Snowball then
        PlayerCode.Snowball.post_player_update(player,saveData,data)
    elseif player:GetPlayerType() == PlayerType.Faithfull then
        PlayerCode.Faithfull.post_player_update(player,saveData,data)
    end

end
return post_player_update
--[[
    if player.QueuedItem.Item == nil then return 
    else
        if player.QueuedItem.Item.Type == 2 and (player.QueuedItem.Item.ID ==(enums.Trinket.SorrowPatch))then
            --player:GetSprite():SetLastFrame()                
            --player:GetSprite():SetOverlayAnimation("HeadDown")
            --player:FlushQueueItem()
            --player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER,false,false,false,false,-1,0)
        end
    end
]]--
