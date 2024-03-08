local rd = require("lovesick-src.RickHelper")
local enums = require("lovesick-src.LovesickEnums")
local Faithfull = require("lovesick-src.characters.Faithfull")

local prePlayerRender = {}

---@param player EntityPlayer
---@param renderOffset Vector
function prePlayerRender:main(player,renderOffset)
	Faithfull:prePlayerRender(player,renderOffset)
end

---@param player EntityPlayer
---@param renderOffset Vector
function prePlayerRender:babyMain(player,renderOffset)
end

function prePlayerRender:init(mod)
	mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, prePlayerRender.main,PlayerVariant.PLAYER)
	mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, prePlayerRender.babyMain,PlayerVariant.CO_OP_BABY)
end

return prePlayerRender
