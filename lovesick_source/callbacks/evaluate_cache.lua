local patches = require("lovesick_source.items.patches")
local LoveLetter = require("lovesick_source.items.love_letter")
local Morphine = require("lovesick_source.items.morphine")
local save = require("lovesick_source.save_manager")
local utility = require("lovesick_source.utility")
local enum = require("lovesick_source.enums")
local Item = enum.Item
local ItemStats = enum.ItemStats
local Trinket = enum.Trinket
local function onCache(_,player, cache)
    local saveData = save.GetData()
    local run = saveData.run
    local p = utility.getPlayerIndex(player)
    patches.onCache(player,cache)
    LoveLetter.onCache(player,cache)
    if player:GetPlayerType()==enum.PlayerType.Snowball then
        utility.SetStats(player,cache,enum.BaseStats.Snowball)
    elseif player:GetPlayerType()==enum.PlayerType.Faithfull then
        utility.SetStats(player,cache,enum.BaseStats.Faithfull)
        local RickValues = saveData.run.persistent.RickValues
        if RickValues and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT,true) then 
            RickValues.StressMax[p] = 360 elseif RickValues then RickValues.StressMax[p] = 240 
        end
        saveData.run.persistent.RickValues = RickValues
        local run = saveData.run
        save.EditData(run,"run")
    end
    Morphine.onCache(player,cache)
    if player:HasCollectible(Item.PaintingKit) then
        if run.persistent.PaintingValue == nil then run.persistent.PaintingValue = {} save.EditData(run,"run") end
        if run.persistent.PaintingValue[p] == nil then 
            local rng = player:GetCollectibleRNG(Item.PaintingKit)
            run.persistent.PaintingValue[p] = rng:RandomInt(5) save.EditData(run,"run") end
        local num = player:GetCollectibleCount(Item.PaintingKit)
        utility.SetStats(player,cache,ItemStats.PaintingKit,num)
        if (player.TearFlags and cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
            player.TearFlags = player.TearFlags|enum.ItemStats.PaintingKit.TearFlagsRotating[run.persistent.PaintingValue[p]+1]
        end
    elseif player:HasCollectible(Item.NeckGaiter) then
        local num = player:GetCollectibleCount(Item.NeckGaiter)
        utility.SetStats(player,cache,ItemStats.NeckGaiter,num)
    elseif player:HasCollectible(Item.SunsetClock) then
        if run.level.SunsetClockSleep == nil then
            run.level.SunsetClockSleep = 120
            save.EditData(run,"run")
        end
        if run.level.SunsetClockSleep > 0 then
            if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
                player.Damage = player.Damage * ItemStats.SunsetClock.SleepMultiplier
            end        
            if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
                player.MaxFireDelay = utility.MultiplyTears(player.MaxFireDelay,ItemStats.SunsetClock.SleepMultiplier)
            end
            if (player.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
                player.ShotSpeed = player.ShotSpeed * ItemStats.SunsetClock.SleepMultiplier
            end        
            if (player.TearRange and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
                player.TearRange = player.TearRange * ItemStats.SunsetClock.SleepMultiplier
            end
            if (player.MoveSpeed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed * ItemStats.SunsetClock.SleepMultiplier
            end        
            if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
                player.Luck = math.max(10,player.Luck)
            end
        else
            if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
                player.Damage = player.Damage * ItemStats.SunsetClock.AwakeMultiplier
            end        
            if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
                player.MaxFireDelay = utility.MultiplyTears(player.MaxFireDelay,ItemStats.SunsetClock.AwakeMultiplier)
            end
            if (player.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
                player.ShotSpeed = player.ShotSpeed * ItemStats.SunsetClock.AwakeMultiplier
            end        
            if (player.TearRange and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
                player.TearRange = player.TearRange * ItemStats.SunsetClock.AwakeMultiplier
            end
            if (player.MoveSpeed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
                player.MoveSpeed = player.MoveSpeed * ItemStats.SunsetClock.AwakeMultiplier
            end        
            if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
                player.Luck = player.Luck * ItemStats.SunsetClock.AwakeMultiplier
            end
        end
    end
    if player:HasTrinket(Trinket.PaperRose) then
        local num = player:GetTrinketMultiplier(Trinket.PaperRose)
        if run.persistent.RoseValue == nil then run.persistent.RoseValue = {} save.EditData(run,"run") end
        if run.persistent.RoseValue[p] == nil then run.persistent.RoseValue[p] = 10 save.EditData(run,"run") end
        if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck + (run.persistent.RoseValue[p])*num
        end
        if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage + (0.25*(10-run.persistent.RoseValue[p]))*num
        end
    end
end

return onCache