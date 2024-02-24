local rd = require("lovesick-src.RickHelper")
local enums = require("lovesick-src.LovesickEnums")
local Faithfull = require("lovesick-src.characters.Faithfull")

local postPlayerRender = {}

---@param player EntityPlayer
---@param renderOffset Vector
function postPlayerRender:main(player,renderOffset)
	Faithfull:postPlayerRender(player,renderOffset)
end

---@param player EntityPlayer
---@param renderOffset Vector
function postPlayerRender:babyMain(player,renderOffset)
end

function postPlayerRender:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerRender.main,PlayerVariant.PLAYER)
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerRender.babyMain,PlayerVariant.CO_OP_BABY)
end

return postPlayerRender
