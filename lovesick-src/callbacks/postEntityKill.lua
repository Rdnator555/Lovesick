local postEntityKill = {}


---@param npc EntityNPC
function postEntityKill:OnNPCDeath(npc)

end

---@param familiar EntityFamiliar
function postEntityKill:OnFamiliarDeath(familiar)
end

---@param ent Entity
function postEntityKill:main(ent)
	if ent:ToNPC() then
		local npc = ent:ToNPC()
		---@cast npc EntityNPC
		postEntityKill:OnNPCDeath(npc)
	elseif ent:ToFamiliar() then
		local familiar = ent:ToFamiliar()
		---@cast familiar EntityFamiliar
		postEntityKill:OnFamiliarDeath(familiar)
	end
end

function postEntityKill:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, postEntityKill.main)
end

return postEntityKill
