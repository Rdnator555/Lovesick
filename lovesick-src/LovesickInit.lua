---@class ModReference
local mod = RegisterMod("Lovesick",1)
local json
local SaveVersion = 3
local rd

---@class SaveData
mod.SavedData = {}

--[[
    All this format of load and mod disposition is based on the eevee:reunited mod, made by Sanio.
    All credist to him.
--]]

function mod:init(j)
    Isaac.DebugString("[Lovesick] Initializing mod...")
    json = j
    rd = require("lovesick-src.RickHelper")
    require("lovesick-src.lovesickEnums")

    local callbacks = {
		"npcUpdate",            --Check
		"postUpdate",           --Check
		"postRender",           --Check
		"entityTakeDamage",     --Check
		"evaluateCache",        --Check
		"postNewLevel",			--Check
		"postNewRoom",			--Check
		"preSpawnCleanAward",	--Check
		"postEntityRemove",		--Check
		"postEntityKill",		--Check
		"postNPCDeath",			--Check
		"postPeffectUpdate",	--Check
		"postPlayerInit",		--Check
		"postPlayerRender",		--Check
		"postPlayerUpdate",		--Check
		"prePickupCollision",	--Check
		"prePlayerCollision",	--Check
		"useItem",				--Check

		--[[
		"useCard",
		"familiarInit",
		"familiarUpdate",
		"usePill",
		"inputAction",
		"postGameStarted",
		"preGameExit",
		"preUseItem",
		"postFamiliarRender",
		"postNPCInit",
		"postNPCRender",
		"preNPCCollision",
		"prePlayerCollision",
		"postPlayerRender",
		"postPickupInit",
		"postPickupUpdate",
		"postTearInit",
		"postTearUpdate",
		"preTearCollision",
		"preProjectileCollision",
		"postLaserInit",
		"postLaserUpdate",
		"postKnifeInit",
		"postKnifeUpdate",
		"preKnifeCollision",
		"postEffectInit",
		"postEffectUpdate",
		"postEffectRender",
		"postBombInit",
		"postBombUpdate",
		"postFireTear",
		"preGetCollectible",
		"preNpcUpdate",
		"postGameEnd"
        ]]
    }

    local customCallbacks = {
        "getDataInit",
    }
    
    local repentogonCallbacks = {

    }

    local callbackTypes = {
        callbacks,customCallbacks, repentogonCallbacks
    }
    mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, mod.LoadModData)
	mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.SaveModData)
	mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.SaveModData)
	mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.CreatePersistentData)

    local path = "lovesick-src.callbacks."
	local pathTypes = {
		"","custom.","repentogon."
	}

	for i, table in ipairs (callbackTypes) do
		print("CallbackTypes: "..i)
		local path = path..pathTypes[i]
		for _, fileName in ipairs (table) do 
			print(path..fileName)
			local callback = require(path..fileName) callback:init(mod)
		end
	end
    Isaac.DebugString("[Lovesick] Mod initialized succesfully")
end

function mod:SaveModData()
    if LOVESICK.ShouldSaveData == true then
        Isaac.DebugString("[Lovesick] Saving mod data...")
		rd.CopyOverTable(LOVESICK.PERSISTENT_DATA, mod.SavedData)
		mod.SavedData.SaveDataVer = SaveVersion
		mod:SaveData(json.encode(mod.SavedData))
		Isaac.DebugString("[Lovesick] Data saved!")
    end
end

---@param player EntityPlayer
function mod:CreatePersistentData(player)
    if LOVESICK.game:GetFrameCount() == 0 then
		LOVESICK.PERSISTENT_DATA.PlayerData = {}
    end
    
	local id = tostring(rd.GetPlayerId(player))

    if LOVESICK.PERSISTENT_DATA.PlayerData[id] == nil then
        LOVESICK.PERSISTENT_DATA.PlayerData[id] = {}
		rd.CopyOverTable(LOVESICK.Template_PlayerData, LOVESICK.PERSISTENT_DATA.PlayerData[id])
    end
end

---@param saveSlot integer
---@param isSlotSelected boolean
---@param rawSlot integer
function mod:LoadModData(saveSlot, isSlotSelected, rawSlot)
	if not isSlotSelected or rawSlot == 0 or not mod:HasData() then return end

	Isaac.DebugString("[Lovesick] Loading saved data for slot " .. saveSlot .. "...")
	local newData = json.decode(mod:LoadData())

	if newData.SaveDataVer ~= SaveVersion then
		local msg =
		"[Lovesick] !!SAVE DATA HAS BEEN RESET!! as result of a save data update."
		Isaac.DebugString(msg)
		print(msg)
		LOVESICK.ShouldSaveData = true
		mod:SaveModData()
	else
		rd.CopyOverTable(newData, LOVESICK.PERSISTENT_DATA)
	end
	Isaac.DebugString("[Lovesick] Finished loading saved data for slot " .. saveSlot)
end

return mod