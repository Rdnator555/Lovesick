local prePickupCollision = {}

---@param pickup EntityPickup
---@param collider Entity
function prePickupCollision:main(pickup, collider)
	
	return --
end

function prePickupCollision:init(mod)
	mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision.main)
end

return prePickupCollision
