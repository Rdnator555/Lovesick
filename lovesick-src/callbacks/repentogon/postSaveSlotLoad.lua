local imgui = require("lovesick-src.misc.imguiSupport")

local postSaveSlotLoad = {}

---@param saveSlot integer
function postSaveSlotLoad:main(saveSlot, isSlotSelected, rawSlot)
	LOVESICK.LastSaveSlotLoaded = saveSlot
	imgui:OnSaveSlotLoad(saveSlot, isSlotSelected, rawSlot)
end

---@param mod ModReference
function postSaveSlotLoad:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, postSaveSlotLoad.main)
end

return postSaveSlotLoad