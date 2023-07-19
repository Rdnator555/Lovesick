local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local treat = require("lovesick_source.items.snowball_treat")
local PlayerType = enums.PlayerType
local Trinket = enums.Trinket
local Item = enums.Item
local game = Game()
local function newFloor()
    local saveData = save.GetData()
    local mimics = 15
    for p=0, game:GetNumPlayers()-1 do 
        local player = Isaac.GetPlayer(p)
        local data = player:GetData()
        local index = util.getPlayerIndex(player)
        treat.onNewFloor(player)
        if player:GetPlayerType() == PlayerType.Snowball then
            if saveData.hourglassBackup.level.mimikyu and saveData.hourglassBackup.level.mimikyu[index] and saveData.run.level.mimikyu[index].Patches then
                data.PatchQueue = saveData.run.level.mimikyu[index].Patches
            end
            mimics = mimics + 1
            local mimikyu = Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER,0,0,game:GetRoom():GetGridPosition(mimics),Vector.Zero,nil)
        end
    end
end

return newFloor