local save = require("lovesick_source.save_manager")
local util = require("lovesick_source.utility")
local enums = require("lovesick_source.enums")
local Morphine = require("lovesick_source.items.morphine")
local PlayerCode = require("lovesick_source.player_scripts")
local PlayerType = enums.PlayerType
local Item = enums.Item
local Trinket = enums.Trinket

local function entityTakeDmg(_,Entity, Amount, DamageFlags, Source, CountdownFrames)
    local value 
    local saveData = save.GetData()
    local run = saveData.run
    if Entity.Type == 1 then
        local player = Entity:ToPlayer()
        local p = util.getPlayerIndex(player)
        if value == nil then value = PlayerCode.Faithfull.entity_take_dmg(player,Amount,DamageFlags) end
        if value == nil then value = Morphine.entity_take_dmg(player,Amount,DamageFlags) end
        if player:GetPlayerType() == PlayerType.Snowball then
            if value == nil then value = PlayerCode.Snowball.entity_take_dmg(player,Amount,DamageFlags) end
        --elseif player:GetPlayerType() == PlayerType.Faithfull then
        end
        if player:HasCollectible(Item.ArrestWarrant) then
            local rng = player:GetCollectibleRNG(Item.ArrestWarrant)
            if (DamageFlags & DamageFlag.DAMAGE_NO_PENALTIES == 0) then
                local amount = player:GetCollectibleNum(Isaac.GetItemIdByName("Arrest Warrant"),true)
            local keys = player:GetNumKeys() local coins = math.floor(player:GetNumCoins()/5) local bombs = player:GetNumBombs()
            if keys > (coins and bombs)then
                SFXManager():Play(SoundEffect.SOUND_KEY_DROP0, Options.SFXVolume,  8, false, 1)
                player:AddKeys(-amount)
                player:AnimateSad()
                for p = 0, amount - 1 do
                    local loseProbability = rng:RandomInt(101)
                    if loseProbability > 20 then
                        local pickupLost = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY,1,player.Position,(Vector.FromAngle(rng:RandomInt(361))):Resized(player.MoveSpeed*3),player):ToPickup()
                        pickupLost.Timeout = 60
                    end
                end
            elseif bombs > (keys and coins)then
                SFXManager():Play(SoundEffect.SOUND_EXPLOSION_WEAK, Options.SFXVolume,  8, false, 1)
                player:AddBombs(-amount)
                player:AnimateSad()
                for p = 0, amount - 1 do
                    local loseProbability = rng:RandomInt(101)
                    if loseProbability > 20 then
                        local pickupLost = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BOMB,1,player.Position,(Vector.FromAngle(rng:RandomInt(361))):Resized(player.MoveSpeed*3),player):ToPickup()
                        pickupLost.Timeout = 60
                    end
                end
            else
                SFXManager():Play(SoundEffect.SOUND_ULTRA_GREED_COINS_FALLING, Options.SFXVolume,  8, false, 1)
                player:AddCoins(-amount*5)
                player:AnimateSad()
                for p = 0, amount*5 - 1 do
                    local loseProbability = rng:RandomInt(101)
                    if loseProbability > 20 then
                        local pickupLost = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,1,player.Position,(Vector.FromAngle(rng:RandomInt(361))):Resized(player.MoveSpeed*3),player):ToPickup()
                        pickupLost.Timeout = 60
                    end
                end
            end
            end
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
    return value
end
return entityTakeDmg 