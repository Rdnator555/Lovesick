local sanguineCharge = require("lovesick-src.misc.sanguineCharge")

local prePickupCollision = {}

---@param pickup EntityPickup
---@param collider Entity
function prePickupCollision:main(pickup, collider)
	local val = nil
	sanguineCharge:prePickupCollision(pickup,collider)
	return val
end

function prePickupCollision:init(mod)
	mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision.main)
end

return prePickupCollision
