local postPlayerUpdate = {}
local Faithfull = require("lovesick-src.characters.Faithfull")
---@param player EntityPlayer
function postPlayerUpdate:main(player)
	Faithfull:postPlayerUpdate(player)
end

function postPlayerUpdate:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate.main)
end

return postPlayerUpdate
