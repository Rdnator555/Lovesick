local rd = require("lovesick-src.RickHelper")
local unlockManager = require("lovesick-src.unlockManager")

local postGameStarted = {}


---@param wasRunContinued boolean
function postGameStarted:main(wasRunContinued)
	LOVESICK.ShouldSaveData = true
	
	unlockManager:checkUnlocks(wasRunContinued)

	if wasRunContinued then
	else
		
	end
	if LOVESICK.debug then 
		rd:CheckLockedCollectible() 
	end
end

function postGameStarted:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted.main)
end

return postGameStarted
