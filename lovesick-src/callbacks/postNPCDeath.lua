

local postNPCDeath = {}

function postNPCDeath:main(npc)
	
end

function postNPCDeath:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNPCDeath.main)
end

return postNPCDeath