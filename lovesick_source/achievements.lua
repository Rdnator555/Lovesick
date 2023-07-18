local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local enums = require("lovesick_source.enums")
local achievements = {}
local achievement = Sprite()
achievement:Load("gfx/ui/achievement/achievements.anm2", true)
achievements.idle_timer = 0

function achievements.render_achievement()
    local room = Game():GetRoom()
    local center = room:GetCenterPos()
    local topLeft = room:GetTopLeftPos()
    local pos = Isaac.WorldToRenderPosition(center)
    -- Adjust position depending on room size
    if (room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIV) then
        pos = Isaac.WorldToRenderPosition(Vector(center.X, topLeft.Y*2.0))
    elseif (room:GetRoomShape() == RoomShape.ROOMSHAPE_2x1 or room:GetRoomShape() == RoomShape.ROOMSHAPE_IIH) then
        pos = Isaac.WorldToRenderPosition(Vector(topLeft.X*5.5, center.Y))
    elseif (room:GetRoomShape() >= RoomShape.ROOMSHAPE_2x2) then
        pos = Isaac.WorldToRenderPosition(Vector(topLeft.X*5.5, topLeft.Y*2.0))
    end
    achievement:Render(pos, Vector(0, 0), Vector(0, 0))
end

function achievements.post_update(player,p)
    if achievement:IsFinished("Appear") then
        achievement:Play("Idle",true)
    end  
    if Game():GetNumPlayers()-1 == p then
        achievement:Update()
    end
    if Game():GetNumPlayers()-1 == p and achievement:IsPlaying("Idle") then
        achievements.idle_timer = achievements.idle_timer -1 
    end
    if achievement:IsPlaying("Idle") and (achievements.idle_timer <= 0 or Input.IsActionPressed(ButtonAction.ACTION_ITEM , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_LEFT , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_DOWN , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_UP , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_RIGHT , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT , player.ControllerIndex) or
        Input.IsActionPressed(ButtonAction.ACTION_DROP , player.ControllerIndex))  then 
        achievements.idle_timer = 0 
        SFXManager():Play(SoundEffect.SOUND_MENU_NOTE_HIDE, 1,  8, false, 1)
        achievement:Play("Dissapear", true) 
    end
    if achievement:IsFinished("Dissapear") and achievements.idle_timer == 0 then
        achievements.displayQueue()
    end
end

function achievements.obtained_achievement(sprite)
    achievement:ReplaceSpritesheet(3,sprite)
    achievement:LoadGraphics()
    achievements.idle_timer = 60
    achievement:Play("Appear", false)
    SFXManager():Play(SoundEffect.SOUND_MENU_NOTE_APPEAR, 1,  8, false, 1)
end

function achievements.displayQueue()
    local saveData = save.GetData()
    local unlocks
    if saveData.file.misc.UnlockQueue == nil then saveData.file.misc.UnlockQueue = {} end
    unlocks = saveData.file.misc.UnlockQueue
    local enemies = 0
    for i, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and entity:Exists() and not entity:HasMortalDamage() then enemies = enemies + 1 end
    end
    if (Game():GetRoom():IsClear() and enemies==0) and achievements.idle_timer <= 0 and unlocks[1] ~= nil and achievement:IsFinished(achievement:GetAnimation()) then
        achievements.obtained_achievement(util.QueueRemove(unlocks))
        save.EditData(unlocks,"Achievements")
    end
end

function achievements.IsItemUnlocked(_,pickup)
    if pickup and util.getCurrentDimension() ~= 2 then
    local data = pickup:GetData()
    local achievements = save.GetData().file.achievements 
    if data.Checked == nil and pickup.Type == EntityType.ENTITY_PICKUP then
        if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            data.Checked = true
            for p=0, util.countTableSize(enums.Item) do
            local Item,Id = util.getTableValue(enums.Item,p)
                if pickup.SubType == Id and achievements[Item] == nil then
                    util.MorphCollectible(pickup)
                end
            end
        elseif pickup.Variant == PickupVariant.PICKUP_TRINKET then
            data.Checked = true
            for p=0, util.countTableSize(enums.Trinket) do
            local Item,Id = util.getTableValue(enums.Trinket,p)
                if pickup.SubType == Id and achievements[Item] == nil then
                    util.MorphCollectible(pickup)
                end
            end
        end
    end 

    end
end

return achievements

