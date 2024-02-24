local getDataInit = {}
local getData = require("lovesick-src.getData")

---@param ent Entity
function getDataInit:main(ent)
	if ent:ToPlayer() then
		local player = ent:ToPlayer()
		---@cast player EntityPlayer
		local playerType = player:GetPlayerType()

		getData:InitData(player)
	else
		getData:InitData(ent)
	end
end

--Luamod helper
if Isaac.IsInGame() then
	for _, ent in ipairs(Isaac.GetRoomEntities()) do
		local data = getData:GetEntityData(ent)
		---@alias AllEntityClass EntityEffect | EntityPlayer | EntitySlot | EntityProjectile | Entity | EntityNPC
		---@type AllEntityClass
		local validEnt
		if ent:ToBomb() then
			local castEnt = ent:ToBomb()
			---@cast castEnt EntityBomb
			validEnt = castEnt
		elseif ent:ToKnife() then
			local castEnt = ent:ToKnife()
			---@cast castEnt EntityKnife
			validEnt = castEnt
		elseif ent:ToPlayer() then
			local castEnt = ent:ToPlayer()
			---@cast castEnt EntityPlayer
			validEnt = castEnt
		elseif ent:ToTear() then
			local castEnt = ent:ToTear()
			---@cast castEnt EntityTear
			validEnt = castEnt
		elseif ent:ToEffect() then
			local castEnt = ent:ToEffect()
			---@cast castEnt EntityEffect
			validEnt = castEnt
		elseif ent:ToLaser() then
			local castEnt = ent:ToLaser()
			---@cast castEnt EntityLaser
			validEnt = castEnt
		elseif ent:ToPickup() then
			local castEnt = ent:ToPickup()
			---@cast castEnt EntityPickup
			validEnt = castEnt
		elseif ent:ToNPC() then
			local castEnt = ent:ToNPC()
			---@cast castEnt EntityNPC
			validEnt = castEnt
		elseif ent:ToProjectile() then
			local castEnt = ent:ToProjectile()
			---@cast castEnt EntityProjectile
			validEnt = castEnt
		elseif ent:ToFamiliar() then
			local castEnt = ent:ToFamiliar()
			---@cast castEnt EntityFamiliar
			validEnt = castEnt
		elseif ent:ToSlot() then
			local castEnt = ent:ToSlot()
			---@cast castEnt EntitySlot
			validEnt = castEnt
		end
		if not data and validEnt then
			getDataInit:main(validEnt)
		end
	end
	print("[Lovesick] Temporary Data reloaded")
end


function getDataInit:init(mod)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_BOMB_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_LASER_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_KNIFE_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_SLOT_INIT, CallbackPriority.IMPORTANT, getDataInit.main)
end

return getDataInit
