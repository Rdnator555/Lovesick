local npcUpdate = {}

---@param npc EntityNPC
function npcUpdate:main(npc)

end

function npcUpdate:init(mod)
	mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate.main)
end

return npcUpdate
