
local postUpdate = {}

local Faithfull = require("lovesick-src.characters.Faithfull")

function postUpdate:main()
    for n=0, LOVESICK.game:GetNumPlayers()-1 do
        local player= Isaac.GetPlayer(n)
        Faithfull:postUpdate(player)
    end
end

function postUpdate:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate.main)
end

return postUpdate
--[[
function postUpdate.MC_POST_UPDATE()
    local saveData = save.GetData()
    local persistent = saveData.run.persistent
    local run = saveData.run
    if run.level.SunsetClockSleep and run.level.SunsetClockSleep > 0  and Game():GetFrameCount()%30 == 0 then
        run.level.SunsetClockSleep = math.max(run.level.SunsetClockSleep -1,0)
        save.EditData(run,"run")
        if run.level.SunsetClockSleep == 0 then
            for n = 0, Game():GetNumPlayers()-1 do
                local player = Isaac.GetPlayer(n)
                if player:HasCollectible(Item.SunsetClock) then
                    player:UseCard(Card.CARD_SUN,UseFlag.USE_NOANIM|UseFlag.USE_NOANNOUNCER|UseFlag.USE_NOHUD)
                    player:AddCacheFlags(CacheFlag.CACHE_ALL)
                    player:EvaluateItems()
                end
            end
        end
    end
    for n = 0, Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(n)
        local p = util.getPlayerIndex(player)
        if persistent.PaintingValue and player:HasCollectible(Item.PaintingKit,true) and Game():GetFrameCount()%150 == 0 then 
            persistent.PaintingValue[p]= (persistent.PaintingValue[p]+1)%5
            print(persistent.PaintingValue[p])
            save.EditData(persistent,"persistent") 
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY|CacheFlag.CACHE_TEARFLAG)
            player:EvaluateItems()
        end
        if persistent.LoveLetterShame and persistent.LoveLetterShame[p] > 0 and Game():GetFrameCount()%10 == 0 then 
            persistent.LoveLetterShame[p]=math.max(0,persistent.LoveLetterShame[p]-0.1) 
            save.EditData(persistent,"persistent") 
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
        if persistent.MorphineTime and persistent.MorphineTime[p] > 0 and Game():GetFrameCount()%30 == 0 then 
            persistent.MorphineTime[p]=math.max(0,persistent.MorphineTime[p]-1) 
            save.EditData(persistent,"persistent")
        end
        if persistent.MorphineDebuff and persistent.MorphineDebuff[p] > 0 and Game():GetFrameCount()%10 == 0 then 
            persistent.MorphineDebuff[p]=math.max(0,persistent.MorphineDebuff[p]-0.05) 
            save.EditData(persistent,"persistent") 
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
        
        if persistent.MorphineDebuff and persistent.MorphineDebuff[p] > 0 and Game():GetFrameCount()%10 == 0 then 
            persistent.MorphineDebuff[p]=math.max(0,persistent.MorphineDebuff[p]-0.05) 
            save.EditData(persistent,"persistent") 
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
        --achievements.post_update(player,n)
        if player:GetPlayerType() == PlayerType.Faithfull then
            PlayerCode.Faithfull.post_update(player)
        end
    end
end
]]