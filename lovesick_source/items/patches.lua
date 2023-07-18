local enums = require("lovesick_source.enums")
local utility = require("lovesick_source.utility")
local trinket = enums.Trinket
local Patches = {}

function Patches.onCache(player,cache)
    local NumPatches = player:GetTrinketMultiplier(trinket.SorrowPatch) + player:GetTrinketMultiplier(trinket.RagePatch) + player:GetTrinketMultiplier(trinket.AimPatch) + player:GetTrinketMultiplier(trinket.SpeedPatch) + player:GetTrinketMultiplier(trinket.VelocityPatch) + player:GetTrinketMultiplier(trinket.CloverPatch)
    if (player.MaxFireDelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        if player:HasTrinket(trinket.SorrowPatch ,true) or player:GetTrinketMultiplier(trinket.SorrowPatch) > 0 then
            local num = player:GetTrinketMultiplier(trinket.SorrowPatch)
            --for i = 1, num, 1 do
            --    player.MaxFireDelay = player.MaxFireDelay - 0.3/math.max(i*0.2,1)
            --end
            player.MaxFireDelay = utility.AddTears(player.MaxFireDelay,num/10)
        end
    end
    if (player.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        if player:HasTrinket(trinket.RagePatch ,true) or player:GetTrinketMultiplier(trinket.RagePatch) > 0 then
            local num = player:GetTrinketMultiplier(trinket.RagePatch)
            --for i = 1, num, 1 do
            --    player.Damage = player.Damage + 0.8/math.max(i*0.25,1)
            --end
            player.Damage = player.Damage + num * 0.8
        end
    end
    if (player.TearRange and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        if player:HasTrinket(trinket.AimPatch ,true) or player:GetTrinketMultiplier(trinket.AimPatch) > 0 then
            local num = player:GetTrinketMultiplier(trinket.AimPatch)
            --for i = 1, num, 1 do
            --    player.TearRange = player.TearRange + 1/math.max(i*0.25,1)
            --end
            player.TearRange = player.TearRange + num * 3
        end
    end
    if (player.MoveSpeed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        if player:HasTrinket(trinket.SpeedPatch ,true) or player:GetTrinketMultiplier(trinket.SpeedPatch) > 0 then
            local num = player:GetTrinketMultiplier(trinket.SpeedPatch)
            --for i = 1, num, 1 do
            --    player.MoveSpeed = player.MoveSpeed + 0.1/math.max(i,1)
            --end
            player.MoveSpeed = player.MoveSpeed + num / 15
        end
    end
    if (player.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        if player:HasTrinket(trinket.VelocityPatch ,true) or player:GetTrinketMultiplier(trinket.VelocityPatch) > 0 then
            local num = player:GetTrinketMultiplier(trinket.VelocityPatch)
            --for i = 1, num, 1 do
            --    player.ShotSpeed = player.ShotSpeed + 0.2/math.max(i,1)
            --end
            player.ShotSpeed = player.ShotSpeed + num / 50
        end
    end
    if (player.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        if player:HasTrinket(trinket.CloverPatch ,true) or player:GetTrinketMultiplier(trinket.CloverPatch) > 0 then
            local num = player:GetTrinketMultiplier(trinket.CloverPatch)
            --for i = 1, num, 1 do
            --    player.Luck = player.Luck + 1/math.max(i*0.2,1)
            --end
            player.Luck = player.Luck + num
        end
    end
end
return Patches