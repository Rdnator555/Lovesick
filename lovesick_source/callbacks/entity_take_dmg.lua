local save = require("lovesick_source.save_manager")
local util = require("lovesick_source.utility")
local enums = require("lovesick_source.enums")
local Morphine = require("lovesick_source.items.morphine")
local PlayerCode = require("lovesick_source.player_scripts")
local PlayerType = enums.PlayerType
local Item = enums.Item
local Trinket = enums.Trinket

local function entityTakeDmg(_,Entity, Amount, DamageFlags, Source, CountdownFrames)
    local value = nil
    local saveData = save.GetData()
    local run = saveData.run
    if Entity.Type == 1 then
        local player = Entity:ToPlayer()
        local p = util.getPlayerIndex(player)
        value = value or PlayerCode.Faithfull.entity_take_dmg(player,Amount,DamageFlags)
        value = value or Morphine.entity_take_dmg(player,Amount,DamageFlags)
        if player:GetPlayerType() == PlayerType.Snowball then
            value = PlayerCode.Snowball.entity_take_dmg(player,Amount,DamageFlags) or value
        --elseif player:GetPlayerType() == PlayerType.Faithfull then
        end
        if player:HasTrinket(Trinket.PaperRose) then
            if (DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES == 0) then
                if run.persistent.RoseValue == nil then run.persistent.RoseValue = {} save.EditData(run,"run") end
                if run.persistent.RoseValue[p] == nil then run.persistent.RoseValue[p] = 10 save.EditData(run,"run") end
                run.persistent.RoseValue[p] = math.max(run.persistent.RoseValue[p]-1,0)
                save.EditData(run,"run")
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE|CacheFlag.CACHE_LUCK)
                player:EvaluateItems()
            end
        end
    end
    local player
    if Source.Type==2 and Source.Entity and Source.Entity.Parent and Source.Entity.Parent.Type==1 then 
        player=Source.Entity.Parent:ToPlayer() 
    elseif Source.Type==1 then 
        player=Source.Entity:ToPlayer() 
    elseif Source.Entity and Source.Entity.Parent and Source.Entity.Parent.Type==1 then 
        player=Source.Entity.Parent:ToPlayer()
    end
    if player and player:GetPlayerType() == PlayerType.Faithfull then
        PlayerCode.Faithfull.on_dealt_dmg(Entity,Amount,DamageFlags,Source,player)
    end
    --print(value)
    return value
end
return entityTakeDmg 