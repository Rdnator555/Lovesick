local util = {}

---@param queue table
---@param object any
function util.QueueStore(object,queue)
    if queue[1] == nil then queue[1] = object else
        for i, v in ipairs(queue) do 
            if queue[i+1] == nil and queue[i]~= nil then queue[i+1] = object return end
        end
    end
end

---@param queue table
function util.QueueRemove(queue)
    if queue[1] == nil then return  else
        local OldFirstValue = queue[1]
        for i, v in ipairs(queue) do 
            if queue[i+1] == nil and queue[i]~= nil then queue[i] = queue[i+1] return OldFirstValue 
            else
                queue[i] = queue[i+1]
            end
        end
    end
end
--removes the player's current trinkets, gives the player the one you provided, uses the smelter, then gives the player back the original trinkets.
function util.addSmeltTrinket(player, trinket, firstTimePickingUp)
    --get the trinkets they're currently holding
    local trinket0 = player:GetTrinket(0)
    local trinket1 = player:GetTrinket(1)

    --remove them
    if trinket0 ~= 0 then
        player:TryRemoveTrinket(trinket0)
    end
    if trinket1 ~= 0 then
        player:TryRemoveTrinket(trinket1)
    end

    player:AddTrinket(trinket, firstTimePickingUp == nil and true or firstTimePickingUp) --add the trinket
    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM|UseFlag.USE_CARBATTERY) --smelt it

    --give their trinkets back
    if trinket0 ~= 0 then
        player:AddTrinket(trinket0, false)
    end
    if trinket1 ~= 0 then
        player:AddTrinket(trinket1, false)
    end
end

function util.AddTears(fireDelay, value)
    local currentTears = 30 / (fireDelay + 1)
    local newTears = currentTears + value
    
    return math.max((30 / newTears) - 1, -0.99)
end

function util.MultiplyTears(fireDelay, value)
    local currentTears = 30 / (fireDelay + 1)
    local newTears = currentTears * value
    
    return math.max((30 / newTears) - 1, -0.99)
end

function util.getPlayerIndex(playerToIndex, cache)
    if playerToIndex == nil then return nil end
    local index = tostring(playerToIndex:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CUBE_BABY):GetSeed())
    return index
end


function util.AddDummy()
    --create dummy invisible player
    local controllerIndex = Isaac.GetPlayer(0).ControllerIndex
    local lostIndex = Game():GetNumPlayers()
    Isaac.ExecuteCommand("addplayer " .. PlayerType.PLAYER_THELOST .. " " .. controllerIndex)
    local lost = Isaac.GetPlayer(lostIndex)
    lost:RemoveCollectible(CollectibleType.COLLECTIBLE_ETERNAL_D6)
    lost:GetSprite():Load("gfx/player_quickdeath.anm2", false)
    lost:GetData().lostDeathCoolDown = 1
    lost.SpriteScale = Vector(0,0)
    lost.ControlsEnabled = false
    lost.Visible = false
    lost.Parent = Isaac.GetPlayer(0)
    lost.Position = Vector(0,0)
    lost:Update()
    return lost
end
--[[
function  util.dummyRemoval()
    if dummy then
        if dummy:GetSprite():IsFinished("Appear") or dummy.FrameCount > 0 then
            Game():GetHUD():AssignPlayerHUDs()
            dummy:Die()
            dummy = nil
        end
    end
end

local stats={
    CanFly = false ,
    Damage = 0,
    FireDelay = 0,
    Luck = 0,
    Range = 0,
    ShotSpeed = 0,
    Speed = 0,
    TearFlags = TearFlags.TEAR_NORMAL
}
--]]
function util.SetStats(player,cache,stats,multiplier)
    if multiplier == nil then multiplier = 1 end
    --print(player:GetPlayerType().." "..player.ControllerIndex.." ".." ",hasParent," "..player.Damage)
    if (stats.Damage and cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage + (stats.Damage*multiplier)
        --print("Damage", player.Damage, getPlayerId(player))
    end        
    if (stats.Firedelay and cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = util.AddTears(player.MaxFireDelay,(stats.Firedelay*multiplier)) 
       --print("Tears2", player.MaxFireDelay )
    end
    if (stats.ShotSpeed and cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED ) then
        player.ShotSpeed = player.ShotSpeed + (stats.ShotSpeed*multiplier)
        --print("ShotSpeed")
    end 
    if (stats.Range and cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange + (stats.Range*multiplier)
        --print("Range")
    end
    if (stats.TearFlags and cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | stats.TearFlags
        --print("TearFlags")
    end
    if (stats.CanFly and cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING) then
        player.CanFly = player.CanFly or stats.CanFly
        --print("Flying")
    end
    if (stats.Speed and cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        if player.MoveSpeed <=2 then player.MoveSpeed = math.min(2,player.MoveSpeed + (stats.Speed*multiplier))
        else player.MoveSpeed = player.MoveSpeed + (stats.Speed*multiplier) end
        --print("Speed")
    end        
    if (stats.Luck and cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + (stats.Luck*multiplier)
        --print("Luck")
    end
end


---@param item CollectibleType
---@param costume boolean
---@param new boolean
---@param player EntityPlayer
function util.addItem(item, costume, new, player)
    player:AddCollectible(item, 0, new, 0, 0)
    if costume == false then
        local itemConfig = Isaac.GetItemConfig()
        local itemConfigItem = itemConfig:GetCollectible(item)
        player:RemoveCostume(itemConfigItem)

    end
end


---@param collectible CollectibleType
---@param ignoreModifiers boolean
function util.AnyHasCollectible(collectible,ignoreModifiers)
    local HasCollectible = false
    for p = 0, Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(p)
        if player:HasCollectible(collectible,ignoreModifiers) then
            HasCollectible = true
        end
    end
    --print(HasCollectible)
    return HasCollectible
end

function util.MorphCollectible(collectibleEntity,itemType)
    if itemType == nil then
        if collectibleEntity.Variant == PickupVariant.PICKUP_COLLECTIBLE then itemType = -1 
        elseif collectibleEntity.Variant == PickupVariant.PICKUP_TRINKET then itemType = 0 end
    end
    if not collectibleEntity:ToPickup():IsShopItem() then
        collectibleEntity:ToPickup():Morph(collectibleEntity.Type, collectibleEntity.Variant, itemType, false, true, true)
    else
        collectibleEntity:ToPickup():Morph(collectibleEntity.Type, collectibleEntity.Variant, itemType, true, true, true)
    end
end

function util.countTableSize(table)
    local n = 0
    for k, v in pairs(table) do
        n = n + 1
    end
    return n
end

function util.getTableValue(table,id)
    local n=0
    for k, v in pairs(table) do
        if n == id then return k,v end
        n=n+1
    end
end

function util.getCurrentDimension() -- KingBobson: (get room dimension)
    --- get current dimension of room
    local level = Game():GetLevel()
    local roomIndex = level:GetCurrentRoomIndex()
    local currentRoomDesc = level:GetCurrentRoomDesc()
    local currentRoomHash = GetPtrHash(currentRoomDesc)
    for dimension = 0, 2 do
        local dimensionRoomDesc = level:GetRoomByIdx(roomIndex, dimension)
        local dimensionRoomHash = GetPtrHash(dimensionRoomDesc)
        if (dimensionRoomHash == currentRoomHash) then
            return dimension
        end
    end
    return nil
end

function util.PickupKill(pickup) --from epiphany mod, thanks and all credit to them of this function
    pickup.EntityCollisionClass = 0
    pickup:PlayPickupSound()
    pickup:Remove()    
    pickup.Velocity = Vector(0, 0)    
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
    effect.Timeout = pickup.Timeout
    local sprite = effect:GetSprite()
    sprite:Load(pickup:GetSprite():GetFilename(), true)
    sprite:Play("Collect", true)
    pickup:Remove()
end

return util