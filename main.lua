local mod= RegisterMod("Lovesick",1)
local Version = "2.0-DevKit"
LoveSickV2 = mod
local modinit = false



local eid = require("lovesick_source.mod_compat.eid")  --define and import eid file
local achievements = require("lovesick_source.achievements")

local evaluateCache = require("lovesick_source.callbacks.evaluate_cache")
local postRender = require("lovesick_source.callbacks.post_render")
local postPlayerUpdate = require("lovesick_source.callbacks.post_player_update")
local postPeffectUpdate = require("lovesick_source.callbacks.post_peffect_update")
local postUpdate = require("lovesick_source.callbacks.post_update")
local prePlayerCollision = require("lovesick_source.callbacks.pre_player_collision")
local prePickupCollision = require("lovesick_source.callbacks.pre_pickup_collision")
local postPayerInit = require("lovesick_source.callbacks.post_player_init")
local useItem = require("lovesick_source.callbacks.use_item")
local entityTakeDmg = require("lovesick_source.callbacks.entity_take_dmg")
local postNPCdeath = require("lovesick_source.callbacks.post_npc_death")
local postEntityKill = require("lovesick_source.callbacks.post_entity_kill")
local onNewFloor = require("lovesick_source.callbacks.new_floor")
local onRoomClear = require("lovesick_source.callbacks.on_room_clear")
local newGame = require("lovesick_source.callbacks.new_game")
local save_manager = require("lovesick_source.save_manager")

save_manager.mod = mod
local postGameEnd = require("lovesick_source.callbacks.post_game_end")



--mod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear.MC_PRE_SPAWN_CLEAN_AWARD)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evaluateCache)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNPCdeath)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE,postPeffectUpdate,0)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate,0)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision)
--mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, prePlayerCollision)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPayerInit,0)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDmg)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, newGame.MC_POST_GAME_STARTED)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,postUpdate.MC_POST_UPDATE)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL,postEntityKill)


--Save manager setup
mod:AddCallback(ModCallbacks.MC_USE_ITEM, save_manager.RestoreModData, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, save_manager.postPlayerInit)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, save_manager.postUpdate)
mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, save_manager.modUnload)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, save_manager.postNewRoom)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, save_manager.postNewLevel)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, save_manager.preGameExit)

--Unlock Check


--local util = require("lovesick_source.utility")
--local save = require("lovesick_source.save_manager")

require("lovesick_source.mod_compat.imguiSupport")


local function onTears()
    local saveData = save.GetData()
    if saveData.file.achievements == nil then saveData.file.achievements = {} end
    local unlocks = saveData.file.achievements
    --util.QueueStore("gfx/ui/achievement/achievement_Rick_1.png",unlocks)
    --save.EditData(unlocks,"Achievements")
end
--mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, onTears)

LoveSickV2.enums = require("lovesick_source.enums")


--Mod Compatibility
eid.register()
--local modConfigMenu = require("lovesick_source.mod_compat.modconfigmenu")
--modConfigMenu(RDFIXES~=nil)


mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function(_) if not modinit then achievements.onInit(); modinit = true end end) -- this is just to make sure the mod initializes at the right time, preventing nil achievements
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function(_) if not modinit then achievements.onInit(); modinit = true end end)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, achievements.checkUnlock)




print("Lovesick Loaded, V.".. Version)