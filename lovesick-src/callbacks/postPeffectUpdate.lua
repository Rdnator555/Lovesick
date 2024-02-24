local rd = require("lovesick-src.RickHelper")


local postPeffectUpdate = {}

---@param player EntityPlayer
function postPeffectUpdate:main(player)
	
end

function postPeffectUpdate:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate.main)
end

return postPeffectUpdate
