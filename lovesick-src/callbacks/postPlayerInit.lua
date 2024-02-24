local postPlayerInit = {}
local Faithfull = require("lovesick-src.characters.Faithfull")

---@param player EntityPlayer
function postPlayerInit:main(player)
	local seed = LOVESICK.game:GetSeeds():GetStartSeed()
	LOVESICK.RunSeededRNG:SetSeed(seed)

	Faithfull:postPlayerInit(player)
	
end

function postPlayerInit:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPlayerInit.main)
end

return postPlayerInit
