local prePlayerCollision = {}

---@param player EntityPlayer
---@param collider Entity
---@param low boolean
function prePlayerCollision:main(player, collider, low)
	
end

function prePlayerCollision:init(mod)
	mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, prePlayerCollision.main, 0)
end

return prePlayerCollision
