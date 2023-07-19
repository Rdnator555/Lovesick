local save = require("lovesick_source.save_manager")
local util = require("lovesick_source.utility")
local enums = require("lovesick_source.enums")
local PlayerCode = require("lovesick_source.player_scripts")
local PlayerType = enums.PlayerType
local Item = enums.Item
local Trinket = enums.Trinket

local function entityTakeDmg(_,Entity, Amount, DamageFlags, Source, CountdownFrames)
    local value = nil
    if Entity.Type == 1 then
        local player = Entity:ToPlayer()
        value = value or PlayerCode.Faithfull.entity_take_dmg(player,Amount,DamageFlags)
        if player:GetPlayerType() == PlayerType.Snowball then
            value = value or PlayerCode.Snowball.entity_take_dmg(player,Amount,DamageFlags)
        --elseif player:GetPlayerType() == PlayerType.Faithfull then
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