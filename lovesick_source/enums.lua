local gameInit = require("lovesick_source.callbacks.new_game")

local enums = {}
enums.IsContinued = gameInit.IsContinued
enums.IsInit = gameInit.IsInit
enums.PlayerType = 
{
    Rick = Isaac.GetPlayerTypeByName("Rick"),
    Rickb = Isaac.GetPlayerTypeByName("Rick",true),
    Snowball = Isaac.GetPlayerTypeByName("Snowball"),
}

enums.Trinket = 
{
    AimPatch = Isaac.GetTrinketIdByName("Aim Patch"),
    BlessedPatch = Isaac.GetTrinketIdByName("Blessed Patch"),
    CloverPatch = Isaac.GetTrinketIdByName("Clover Patch"),
    CursedPatch = Isaac.GetTrinketIdByName("Cursed Patch"),
    RagePatch = Isaac.GetTrinketIdByName("Rage Patch"),    
    SorrowPatch = Isaac.GetTrinketIdByName("Sorrow Patch"),
    SpeedPatch = Isaac.GetTrinketIdByName("Speed Patch"),
    VelocityPatch = Isaac.GetTrinketIdByName("Power Patch"),
    PaperRose = Isaac.GetTrinketIdByName("Paper Rose"),
    BigFuse = Isaac.GetTrinketIdByName("Big Fuse"),
    OldDrawing = Isaac.GetTrinketIdByName("Old Drawing"),
    --Buttons
}
enums.Item = 
{
    LockedHeart = Isaac.GetItemIdByName("Locked Heart"),
    Morphine = Isaac.GetItemIdByName("Morphine"),
    LoveLetter = Isaac.GetItemIdByName("Love Letter"),
    SleepingPills = Isaac.GetItemIdByName("Sleeping Pills"),
    OldMp3 = {
        Isaac.GetItemIdByName("Old MP3"),
        Isaac.GetItemIdByName(" Old MP3"),
        Isaac.GetItemIdByName("  Old MP3"),
        Isaac.GetItemIdByName("   Old MP3"),
    },
    PaintingKit = Isaac.GetItemIdByName("Painting Kit"),
    BoxOfLeftovers = Isaac.GetItemIdByName("Box of Leftovers"),
    ArrestWarrant = Isaac.GetItemIdByName("Arrest Warrant"),
    SunsetClock = Isaac.GetItemIdByName("Sunset Clock"),
    BirthdayCake = Isaac.GetItemIdByName("Birthday Cake"),
    NeckGaiter = Isaac.GetItemIdByName("Neck Gaiter"),
    KindSoul = Isaac.GetItemIdByName("Kind Soul"),
    LooseThread = Isaac.GetItemIdByName("Loose Thread"),
    SnowballTreat = Isaac.GetItemIdByName("Snowball's Treat"),
    Snowball = Isaac.GetItemIdByName("Snowball"),
    SewingMachine = Isaac.GetItemIdByName("Sewing Machine"),
    LostAndFound = Isaac.GetItemIdByName("Lost And Found"),
    RabbitFoot = Isaac.GetItemIdByName("Rabbit Foot"),
    --PinsAndNeedles,Scissors
}
enums.BaseStats = 
{
    Faithfull ={
        Damage = -2.2,
        Firedelay = 0.8,
        Range = 50,
        ShotSpeed = 0.2,
        Speed = 0.2,
        Luck = 1
    },
    Fatefull ={
        CanFly = false ,
        Damage = 1.2,
        Range = -40,        
        Luck = -1,
        ShotSpeed = -1.2,
        Speed = -0.1,
        Firedelay = -0.2,
    },
    Snowball ={
        CanFly = false ,
        Damage = -0.3,
        Firedelay = 0.3,
        Luck = -1,
        Range = 20,
        Speed = 0.1,
        TearFlags = TearFlags.TEAR_NORMAL
    }
}
enums.ItemStats = 
{
    PaintingKit ={
        Firedelay = 0.5,
        ShotSpeed = 0.2,
        TearFlagsRotating = {
            TearFlags.TEAR_GISH,
            TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP,
            TearFlags.TEAR_TURN_HORIZONTAL,
            TearFlags.TEAR_BOUNCE,
            TearFlags.TEAR_HYDROBOUNCE
        }
    },
    SunsetClock = {
        SleepMultiplier = 0.8,
        AwakeMultiplier = 1.1
    },
    NeckGaiter = {
        Damage = 0.75,
        Speed = 0.1
    },
    PaperRose = {Multiplier = 0.25}
}
enums.Entities = 
{
    DELIRIUM_EX= {
        type = Isaac.GetEntityTypeByName("Delirium_EX"),
        variant = Isaac.GetEntityVariantByName("Delirium_EX")
    } 
}

enums.Achievements = {}

---@class CharacterMarks
---@field [CompletionType.MOMS_HEART]         Achievement
---@field [CompletionType.ISAAC]              Achievement
---@field [CompletionType.SATAN]              Achievement
---@field [CompletionType.BOSS_RUSH]          Achievement
---@field [CompletionType.BLUE_BABY]          Achievement
---@field [CompletionType.LAMB]               Achievement
---@field [CompletionType.MEGA_SATAN]         Achievement
---@field [CompletionType.ULTRA_GREED]        Achievement
---@field [CompletionType.HUSH]               Achievement
---@field [CompletionType.ULTRA_GREEDIER]     Achievement
---@field [CompletionType.DELIRIUM]           Achievement
---@field [CompletionType.MOTHER]             Achievement
---@field [CompletionType.BEAST]              Achievement

---@class marksToUnlock 
---@field [PlayerType] CharacterMarks

---@type marksToUnlock
enums.MarksToAchievement = {}

enums.AchievementInit = false

function enums.UpdateAchievementEnums()
    enums.AchievementInit = true
    enums.Achievements = {
        ArrestWarrant = Isaac.GetAchievementIdByName("Arrest Warrant Unlock"),
        BirthdayCake  = Isaac.GetAchievementIdByName("Birthday Cake Unlock"),
        BoxOfLeftovers= Isaac.GetAchievementIdByName("Box of Leftovers Unlock"),
        KindSoul      = Isaac.GetAchievementIdByName("Kind Soul Unlock"),
        LockedHeart   = Isaac.GetAchievementIdByName("Locked Heart Unlock"),
        --LooseThread   = Isaac.GetAchievementIdByName(""),
        --LostAndFound  = Isaac.GetAchievementIdByName(""),
        LoveLetter    = Isaac.GetAchievementIdByName("Love Letter Unlock"),
        Morphine      = Isaac.GetAchievementIdByName("Morphine Unlock"),
        NeckGaiter    = Isaac.GetAchievementIdByName("Neck Gaiter Unlock"),
        PaintingKit   = Isaac.GetAchievementIdByName("Painting Kit Unlock"),
        PaperRose     = Isaac.GetAchievementIdByName("Paper Rose Unlock"),
        --RabbitFoot    = Isaac.GetAchievementIdByName(""),
        --SewingMachine = Isaac.GetAchievementIdByName(""),
        SleepingPills = Isaac.GetAchievementIdByName("Sleeping Pills Unlock"),
        --Snowball      = Isaac.GetAchievementIdByName(""),
        --SnowballTreat = Isaac.GetAchievementIdByName(""),
        SunsetClock   = Isaac.GetAchievementIdByName("Sunset Clock Unlock"),
    }
    enums.MarksToAchievement = 
    {
        [enums.PlayerType.Rick] = 
        {
            [CompletionType.MOMS_HEART] = enums.Achievements.LockedHeart,
            [CompletionType.ISAAC] = Isaac.GetAchievementIdByName("Locked Heart Tough Up"),
            [CompletionType.SATAN] = enums.Achievements.NeckGaiter,
            [CompletionType.BOSS_RUSH] = enums.Achievements.PaperRose,
            [CompletionType.BLUE_BABY] = nil,                               --Here the pepper x item
            [CompletionType.LAMB] = enums.Achievements.PaintingKit,
            [CompletionType.MEGA_SATAN] = enums.Achievements.BoxOfLeftovers,
            [CompletionType.ULTRA_GREED] = enums.Achievements.KindSoul,
            [CompletionType.HUSH] = enums.Achievements.Morphine,
            [CompletionType.ULTRA_GREEDIER] = enums.Achievements.LoveLetter,
            [CompletionType.DELIRIUM] = enums.Achievements.SunsetClock,
            [CompletionType.MOTHER] = enums.Achievements.BirthdayCake,
            [CompletionType.BEAST] = enums.Achievements.ArrestWarrant,
        }
    }
end


return enums
--[[


        
        
        
        
        
        
        
        
        
        
        
        

for i,v in pairs(enums.PlayerType) do
	achievements.markToUnlock[v] = {}
	local marksUnlocks = {}
	for mark,completionType in pairs(CompletionType) do
		marksUnlocks[mark] = 
	end
end

CanFly = false ,
Damage = 0,
FireDelay = 0,
Luck = 0,
Range = 0,
ShotSpeed = 0,
Speed = 0,
TearFlags = TearFlags.TEAR_NORMAL
]]