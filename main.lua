local mod= RegisterMod("Lovesick",1)
local Version = "2.0-DevKit"
LoveSickV2 = mod

local game = Game() local sfxManager = SFXManager() local level = Game():GetLevel() local stage = level:GetStage()

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
local achievements = require("lovesick_source.achievements")
save_manager.mod = mod
local postGameEnd = require("lovesick_source.callbacks.post_game_end")
local eid = require("lovesick_source.mod_compat.eid")  --define and import eid file
local modConfigMenu = require("lovesick_source.mod_compat.modconfigmenu")

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
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, achievements.IsItemUnlocked)

--Mod Compatibility
eid.register()
modConfigMenu(RDFIXES~=nil)


local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")

local function onTears()
    local saveData = save.GetData()
    if saveData.file.achievements == nil then saveData.file.achievements = {} end
    local unlocks = saveData.file.achievements
    --util.QueueStore("gfx/ui/achievement/achievement_Rick_1.png",unlocks)
    --save.EditData(unlocks,"Achievements")
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, onTears)

function mod:script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*[/\\])") or "./"
end
local AllUnlock = {
    true,true,true,true,true,true,true,true,true,true,true
}

--function mod:ChangeAnm2VisiblilityOfMark(path,name,table)
--    local values = {normal={0,0},deliNormal={0,128},deliHard={0,224}}
--    local layersMarks = {"21","22","23","24","25","26","27","28","29","30","31","32"} --"21", es la bg
--    print(path,name,table)
--    local file = assert(io.open(path,"r"))
--    if not file then return nil end
--    local xml = file:read"*a"
--    file:close()
--    local playerAnimation = xml:match("<Animation Name=\""..name.."\" FrameNum=\"1\" Loop=\"false\">.-</Animation>")
--    local layerAnimations = playerAnimation:match("<LayerAnimations>.-</LayerAnimations>")
--    for p = 1, #layersMarks do
--        local layerP=(layerAnimations:match("<LayerAnimation LayerId=\""..layersMarks[p].."\" Visible=\"true\">.-</LayerAnimation>"))
--        print(layerP)
--    end
--    --local file = assert(io.open("myTest2.xml", "w"))
--    --file:write(xml)
--    --file:close()
--    print(tostring(string.upper):match("-[function]"))
--      
--end


print("Lovesick Loaded, V.".. Version)