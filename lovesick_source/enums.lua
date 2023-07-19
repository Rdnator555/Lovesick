local gameInit = require("lovesick_source.callbacks.new_game")

local enums = {}
enums.IsContinued = gameInit.IsContinued
enums.IsInit = gameInit.IsInit
enums.PlayerType = {
    Faithfull = Isaac.GetPlayerTypeByName("Rick"),
    Fatefull = Isaac.GetPlayerTypeByName("Rick",true),
    Snowball = Isaac.GetPlayerTypeByName("Snowball"),
}

enums.Trinket = {
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
enums.Item = {
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
enums.BaseStats = {
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
enums.ItemStats = {
    PaintKit ={
        Firedelay = 0.5,
        ShotSpeed = 0.2,
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
enums.Entities = {
    DELIRIUM_EX= {
        type = Isaac.GetEntityTypeByName("Delirium_EX"),
        variant = Isaac.GetEntityVariantByName("Delirium_EX")
    } 
}

return enums
--[[
CanFly = false ,
Damage = 0,
FireDelay = 0,
Luck = 0,
Range = 0,
ShotSpeed = 0,
Speed = 0,
TearFlags = TearFlags.TEAR_NORMAL
]]