
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