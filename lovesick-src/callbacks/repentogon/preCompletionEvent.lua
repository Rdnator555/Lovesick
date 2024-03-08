local unlockManager = require("lovesick-src.unlockManager")

local preCompletionEvent = {}

---@param completionType CompletionType
function preCompletionEvent:main(completionType)
	unlockManager:checkUnlocks(nil,completionType)
end

function preCompletionEvent:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, preCompletionEvent.main)
end

return preCompletionEvent