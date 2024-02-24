--local getData = require("src_eevee.getData2")

local postEntityRemove = {}

---@param tear EntityTear
function postEntityRemove:OnTearRemove(tear)
end

---@param familiar EntityFamiliar
function postEntityRemove:OnFamiliarRemove(familiar)
end

---@param effect EntityEffect
function postEntityRemove:OnEffectRemove(effect)
end

---@param ent Entity
function postEntityRemove:main(ent)
	if ent:ToTear() then
		local tear = ent:ToTear()
		---@cast tear EntityTear
		postEntityRemove:OnTearRemove(tear)
	elseif ent:ToFamiliar() then
		local familiar = ent:ToFamiliar()
		---@cast familiar EntityFamiliar
		postEntityRemove:OnFamiliarRemove(familiar)
	elseif ent:ToEffect() then
		local effect = ent:ToEffect()
		---@cast effect EntityEffect
		postEntityRemove:OnEffectRemove(effect)
	end
end

---@param mod ModReference
function postEntityRemove:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, postEntityRemove.main)
end

return postEntityRemove
