local enums = require("lovesick_source.enums")
local Item = enums.Item
local Treat = {}

function Treat.onNewFloor(player)
    if player:HasCollectible(Item.SnowballTreat) then
        player:UsePill(PillEffect.PILLEFFECT_SEE_FOREVER, PillColor.PILL_NULL, UseFlag.USE_NOANIM|UseFlag.USE_NOANNOUNCER)
        SFXManager():Stop(SoundEffect.SOUND_THUMBSUP)
    end
end

return Treat
