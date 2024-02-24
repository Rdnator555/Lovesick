local Faithfull = require("lovesick-src.characters.Faithfull")

local entityTakeDamage = {}

---@param ent Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
function entityTakeDamage:OnNPCDamage(ent, amount, flags, source, countdown)
	if not ent:ToNPC() then return end
	local player
    if source.Type==2 and source.Entity and source.Entity.Parent and source.Entity.Parent.Type==1 then 
        player=source.Entity.Parent:ToPlayer() 
    elseif source.Type==1 then 
        player=source.Entity:ToPlayer() 
    elseif source.Entity and source.Entity.Parent and source.Entity.Parent.Type==1 then 
        player=source.Entity.Parent:ToPlayer()
    end
	local functions = {
		Faithfull:entityTakeDamage(ent, amount, flags, source, countdown, player)
    }
    for _, func in pairs(functions) do
		if func ~= nil then return func end
	end
end

---@param ent Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
function entityTakeDamage:OnFamiliarDamage(ent, amount, flags, source, countdown)
	local familiar = ent:ToFamiliar()
	---@cast familiar EntityFamiliar
    local functions = {

    }
    for _, func in pairs(functions) do
		if func ~= nil then return func end
	end
end

---@param ent Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
function entityTakeDamage:OnPlayerDamage(ent, amount, flags, source, countdown)
	local player = ent:ToPlayer()
	---@cast player EntityPlayer
	local functions = {
		Faithfull:playerTakeDamage(ent, amount, flags, source, countdown, player)
	}

	for _, func in pairs(functions) do
		if func ~= nil then return func end
	end
end

function entityTakeDamage:init(mod)
	mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage.OnNPCDamage)
	mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage.OnPlayerDamage, EntityType.ENTITY_PLAYER)
	mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage.OnFamiliarDamage, EntityType.ENTITY_FAMILIAR)
end

return entityTakeDamage
