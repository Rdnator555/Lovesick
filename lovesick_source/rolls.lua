---@class options
---@field Quality number The minimum quality of the item (0-4)
---@field AllowActives boolean Whether to allow it to reroll into active items
---@field Attempts number The number of rerolls attempted to get an item matching the requirements
---@field Invert boolean Inverts the quality check to be quality is equal to or less than the given quality

---@class PickupHelper
local module = {}
module.pool = Game():GetItemPool()
module.config = Isaac.GetItemConfig()
module.options = {
    Quality = 4,
    AllowActives = true,
    Attempts = 30,
    Invert = false
}

local collectibleVariant = PickupVariant.PICKUP_COLLECTIBLE

local function determineActive(AllowActives, itemConfig)
    return (AllowActives == nil or AllowActives == true or itemConfig.Type == ItemType.ITEM_PASSIVE)
end

local function determineQuality(MinQuality, itemConfig, invert)
    return (MinQuality == 0) or (not invert and itemConfig.Quality >= MinQuality) or (invert and itemConfig.Quality <= MinQuality)
end

---Gets an item from the current rooms' pool or from the default pool if no room is found
---@param room Room The room to get the ItemPool from
---@param AllowActives? boolean Whether to allow actives
---@param MinQuality? number The minimum quality of the item
---@param invert? boolean Inverts the quality check to be quality is equal to or less the given quality
---@param defaultPool? ItemPoolType Defaults to Golden Chest Pool
---@return boolean|CollectibleType
local function GetRoomItem(room, AllowActives, MinQuality, invert, defaultPool)
    local defaultPool = defaultPool or ItemPoolType.POOL_GOLDEN_CHEST
    local MinQuality = MinQuality or 0
    local AllowActives = AllowActives == nil and true or AllowActives

    if (not REPENTANCE) then MinQuality = 0 end

    if (AllowActives and MinQuality == 0) then return false end

    local itemType = module.pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
    itemType = itemType > -1 and itemType or defaultPool

    local attempt = 0
    local collectible = module.pool:GetCollectible(itemType)
    local itemConfig = module.config:GetCollectible(collectible)
    local active = determineActive(AllowActives, itemConfig)
    local quality = determineQuality(MinQuality, itemConfig, invert)
    while (not quality or not active) do
        if (attempt >= module.options.Attempts) then break end
        collectible = module.pool:GetCollectible(itemType)
        itemConfig = module.config:GetCollectible(collectible)
        active = determineActive(AllowActives, itemConfig)
        quality = determineQuality(MinQuality, itemConfig, invert)
        attempt = attempt + 1
    end

    return collectible
end

module.getItemFromRoomPool = GetRoomItem

---attempts to reroll an item based on options
---@param pickup EntityPickup
---@param room Room
---@return boolean|CollectibleType, string? error
function module.reroll(pickup, room)
    if (pickup == nil or pickup.Variant ~= collectibleVariant) then return false, "Not a collectible" end
    ---@type ItemConfig_Item
    local iconfig = module.config:GetCollectible(pickup.SubType)
    ---@type boolean|CollectibleType
    local collectible = false
    local shouldReroll = (not module.options.Invert and iconfig.Quality < module.options.Quality) or (module.options.Invert and iconfig.Quality > module.options.Quality)
    if not shouldReroll then return true, "Collectible already matches requirements" end
    collectible = GetRoomItem(room, module.options.AllowActives, module.options.Quality, module.options.Invert)
    if (not collectible) then return false, "Collectible already matches requirements" end
    return collectible
end

---Initializes the module with necessary variables
---@param pool? ItemPool
---@param config? ItemConfig
---@param options? options
function module.init(options, pool, config)
    module.pool = pool or Game():GetItemPool()
    module.config = config or Game():GetItemConfig()
    module.options = options or module.options
end

return module

