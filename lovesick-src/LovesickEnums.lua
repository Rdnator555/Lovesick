LOVESICK = LOVESICK or {}

LOVESICK.game = Game()
LOVESICK.room = LOVESICK.game:GetRoom()
LOVESICK.level = LOVESICK.game:GetLevel()
LOVESICK.persistentGameData = Isaac:GetPersistentGameData()
LOVESICK.sfx = SFXManager()
LOVESICK.shouldSaveData = false
LOVESICK.Name = "Lovesick v2"
LOVESICK.HUD = LOVESICK.game:GetHUD()
LOVESICK.debug = false

LOVESICK.RunSeededRNG = RNG()

---@class PlayerSaveData
---@field WonderLauncherWisps EntityFamiliar[]
---@field IsShiny boolean
LOVESICK.Template_PlayerData = {
	WonderLauncherWisps = {},
	IsCursed = false,
}

---@class PersistentData
---@field Settings {ClassicVoice: boolean, ForceShiny: boolean}
---@field PassiveShiny boolean
---@field PlayerData PlayerSaveData[]
---@field KecleonShop {HasVisited: boolean, CloseShop: boolean, Level: table<LevelStage, integer>, EvolutionStones: boolean, Jobs: KecleonJob[], PokeCurrency: integer}
---@field Events {CapturedFirstBoss: boolean, PokemonCaptured: integer}
LOVESICK.PERSISTENT_DATA = LOVESICK.PERSISTENT_DATA ~= nil and LOVESICK.PERSISTENT_DATA or
	{
		Settings = {
			ClassicVoice = false,
			ForceShiny = false,
		},
		PassiveShiny = true,
		PlayerData = {},
		KecleonShop = {
			HasVisited = false,
			CloseShop = false,
			Level = {
				[LevelStage.STAGE1_2] = 0,
				[LevelStage.STAGE2_2] = 0,
				[LevelStage.STAGE3_2] = 0,
			},
			EvolutionStones = false,
			Jobs = {},
			PokeCurrency = 0,
		},
		Events = {
			CapturedFirstBoss = false,
			PokemonCaptured = 0,
		},
	}


LOVESICK.LastSaveSlotLoaded = LOVESICK.LastSaveSlotLoaded or 1
LOVESICK.HasLoadedSaves = LOVESICK.HasLoadedSaves or false

---@enum LovesickAchievement
LOVESICK.Achievement = {
    BIG_FUSE_UNLOCK = Isaac.GetAchievementIdByName("Big Fuse Unlock"),
	LOCKED_HEART_UNLOCK = Isaac.GetAchievementIdByName("Locked Heart Unlock"),
	LOCKED_HEART_UPGRADE = Isaac.GetAchievementIdByName("Locked Heart Upgrade"),
	ARREST_WARRANT_UNLOCK = Isaac.GetAchievementIdByName("Arrest Warrant Unlock"),
	BIRTHDAY_CAKE_UNLOCK = Isaac.GetAchievementIdByName("Birthday Cake Unlock"),
	BOX_OF_LEFTOVERS_UNLOCK = Isaac.GetAchievementIdByName("Box of Leftovers Unlock"),
	KIND_SOUL_UNLOCK = Isaac.GetAchievementIdByName("Kind Soul Unlock"),
	LOVE_LETTER_UNLOCK = Isaac.GetAchievementIdByName("Love Letter Unlock"),
	MORPHINE_UNLOCK = Isaac.GetAchievementIdByName("Morphine Unlock"),
	NECK_GAITER_UNLOCK = Isaac.GetAchievementIdByName("Neck Gaiter Unlock"),
	PAINTING_KIT_UNLOCK = Isaac.GetAchievementIdByName("Painting Kit Unlock"),
	PAPER_ROSE_UNLOCK = Isaac.GetAchievementIdByName("Paper Rose Unlock"),
	SLEEPING_PILLS_UNLOCK = Isaac.GetAchievementIdByName("Sleeping Pills Unlock"),
	SUNSET_CLOCK_UNLOCK = Isaac.GetAchievementIdByName("Sunset Clock Unlock"),

	NUM_ACHIEVEMENTS = 14,
}

LOVESICK.CompletionTypeToAchievement = {
	Rick = {
		[CompletionType.MOMS_HEART] = LOVESICK.Achievement.BIG_FUSE_UNLOCK,
		[CompletionType.ISAAC] = LOVESICK.Achievement.LOCKED_HEART_UNLOCK,
		[CompletionType.SATAN] = LOVESICK.Achievement.NECK_GAITER_UNLOCK,
		[CompletionType.BOSS_RUSH] = LOVESICK.Achievement.PAPER_ROSE_UNLOCK,
		[CompletionType.BLUE_BABY] = LOVESICK.Achievement.LOCKED_HEART_UPGRADE,
		[CompletionType.LAMB] = LOVESICK.Achievement.PAINTING_KIT_UNLOCK,
		[CompletionType.MEGA_SATAN] = LOVESICK.Achievement.BOX_OF_LEFTOVERS_UNLOCK,
		[CompletionType.ULTRA_GREED] = LOVESICK.Achievement.KIND_SOUL_UNLOCK,
		[CompletionType.HUSH] = LOVESICK.Achievement.MORPHINE_UNLOCK,
		[CompletionType.ULTRA_GREEDIER] = LOVESICK.Achievement.LOVE_LETTER_UNLOCK,
		[CompletionType.DELIRIUM] = LOVESICK.Achievement.SUNSET_CLOCK_UNLOCK,
		[CompletionType.MOTHER] = LOVESICK.Achievement.BIRTHDAY_CAKE_UNLOCK,
		[CompletionType.BEAST] = LOVESICK.Achievement.ARREST_WARRANT_UNLOCK
	},
	Rickb = {
		--[TaintedMarksGroup.SOULSTONE] = LOVESICK.Achievement.SOUL_OF_EEVEE,
		--[TaintedMarksGroup.POLAROID_NEGATIVE] = LOVESICK.Achievement.MEGA_KEYSTONE,
		--[CompletionType.MEGA_SATAN] = LOVESICK.Achievement.VOLTORB_FLIP,
		--[CompletionType.DELIRIUM] = LOVESICK.Achievement.MALLEABLE_CRYSTAL,
		--[CompletionType.MOTHER] = LOVESICK.Achievement.TERA_SHARD_CROWN,
		--[CompletionType.BEAST] = LOVESICK.Achievement.GIGANTAFLUFF
	}
}

---@param id integer | string
function LOVESICK.GetPersistentPlayerData(id)
	return LOVESICK.PERSISTENT_DATA.PlayerData[tostring(id)]
end

LOVESICK.MarkToName = {
	[CompletionType.MOMS_HEART] = "MomsHeart",
	[CompletionType.ISAAC] = "Isaac",
	[CompletionType.SATAN] = "Satan",
	[CompletionType.BOSS_RUSH] = "BossRush",
	[CompletionType.BLUE_BABY] = "BlueBaby",
	[CompletionType.LAMB] = "Lamb",
	[CompletionType.MEGA_SATAN] = "MegaSatan",
	[CompletionType.ULTRA_GREED] = "UltraGreed",
	[CompletionType.HUSH] = "Hush",
	[CompletionType.ULTRA_GREEDIER] = "UltraGreedier",
	[CompletionType.DELIRIUM] = "Delirium",
	[CompletionType.MOTHER] = "Mother",
	[CompletionType.BEAST] = "Beast",
}

LOVESICK.NameToMark = {
	["MomsHeart"] = CompletionType.MOMS_HEART,
	["Isaac"] = CompletionType.ISAAC,
	["Satan"] = CompletionType.SATAN,
	["BossRush"] = CompletionType.BOSS_RUSH,
	["BlueBaby"] = CompletionType.BLUE_BABY,
	["Lamb"] = CompletionType.LAMB,
	["MegaSatan"] = CompletionType.MEGA_SATAN,
	["UltraGreed"] = CompletionType.ULTRA_GREED,
	["Hush"] = CompletionType.HUSH,
	["UltraGreedier"] = CompletionType.ULTRA_GREEDIER,
	["Delirium"] = CompletionType.DELIRIUM,
	["Mother"] = CompletionType.MOTHER,
	["Beast"] = CompletionType.BEAST
}

---@enum LovesickCard
LOVESICK.Card = {
	TEA = Isaac.GetCardIdByName("Tea"),
	APPPLE_JUICE = Isaac.GetCardIdByName("Great Ball"),
	ORANGE_JUICE = Isaac.GetCardIdByName("Ultra Ball"),
	ICED_TEA = Isaac.GetCardIdByName("Fire Stone"),
	ROOT_BEER = Isaac.GetCardIdByName("Thunder Stone"),
	ENERGETIC_DRINK = Isaac.GetCardIdByName("Water Stone"),
}

---@enum LovesickChallenge
LOVESICK.Challenge = {
	--POKEY_MANS_CRYSTAL = Isaac.GetChallengeIdByName("Pokey Mans: Crystal")
}

LOVESICK.ChallengeToAchievement = {
	--[LOVESICK.Challenge.POKEY_MANS_CRYSTAL] = LOVESICK.Achievement.POKE_STOP
}

---@enum LovesickCollectibleType
LOVESICK.CollectibleType = {
	LOCKED_HEART = Isaac.GetItemIdByName("Locked Heart"),
    MORPHINE = Isaac.GetItemIdByName("Morphine"),
    LOVE_LETTER = Isaac.GetItemIdByName("Love Letter"),
    SLEEPING_PILLS = Isaac.GetItemIdByName("Sleeping Pills"),
    OLD_MP3 = {
        Isaac.GetItemIdByName("Old MP3"),
        Isaac.GetItemIdByName(" Old MP3"),
        Isaac.GetItemIdByName("  Old MP3"),
        Isaac.GetItemIdByName("   Old MP3"),
    },
    PAINTING_KIT = Isaac.GetItemIdByName("Painting Kit"),
    Box_Of_Leftovers = Isaac.GetItemIdByName("Box of Leftovers"),
    ARREST_WARRANT = Isaac.GetItemIdByName("Arrest Warrant"),
    SUNSET_CLOCK = Isaac.GetItemIdByName("Sunset Clock"),
    BIRTHDAY_CAKE = Isaac.GetItemIdByName("Birthday Cake"),
    NECK_GAITER = Isaac.GetItemIdByName("Neck Gaiter"),
    KIND_SOUL = Isaac.GetItemIdByName("Kind Soul"),
    LOOSE_THREAD = Isaac.GetItemIdByName("Loose Thread"),
    SNOWBALL_TREAT = Isaac.GetItemIdByName("Snowball's Treat"),
    SNOWBALL = Isaac.GetItemIdByName("Snowball"),
    SEWING_MACHINE = Isaac.GetItemIdByName("Sewing Machine"),
    LOST_AND_FOUND = Isaac.GetItemIdByName("Lost And Found"),
    RABBIT_FOOT = Isaac.GetItemIdByName("Rabbit Foot"),
}

---@enum ColorCycle
LOVESICK.ColorCycle = {
	RGB = 0,
	CONTINUUM = 1,
    ENERGIZED = 2,
    ENRAGED = 3,
    BLESSED = 4,
    SACRIFICE_MARK = 5,
    MISFORTUNE = 6,
    FORTUNE = 7,
}

---@enum LovesickEffectVariant
LOVESICK.EffectVariant = {
	--CUSTOM_BRIMSTONE_SWIRL = Isaac.GetEntityVariantByName("[EV] Custom Brimstone Swirl"),
}

LOVESICK.AttackReticleSubtype = {
	BLOODY_RESONANCE = Isaac.GetEntitySubTypeByName("Bloody Resonance"),
	STAGE_LIGHTS = Isaac.GetEntitySubTypeByName("Stage Lights")
}


---@enum LovesickFamiliarVariant
LOVESICK.FamiliarVariant = {
	--LIL_EEVEE = Isaac.GetEntityVariantByName("Lil Eevee"),
}

LOVESICK.Font = {

}

LOVESICK.KnifeSubtype = {
	MUSICAL_CHORD = Isaac.GetEntitySubTypeByName("Musical CHord"),
	DADS_TOOTHPICK = Isaac.GetEntitySubTypeByName("Dad's Toothpick"),
    SANGUINE_BLADE = Isaac.GetEntitySubTypeByName("Sanguine Blade"),
}

LOVESICK.ItemPool = {
    POOL_DRINKS ={},
    POOL_MEALS  ={},
    POOL_TOYS   ={},
    POOL_PRIZES ={},
}

LOVESICK.ItemToFamiliarVariant = {
	--{ LOVESICK.CollectibleType.LIL_EEVEE,        LOVESICK.FamiliarVariant.LIL_EEVEE },
}

LOVESICK.IsFollower = {
	--[LOVESICK.FamiliarVariant.FAMILIAR] = true,
}

---@enum SongType
LOVESICK.SongType = {
	POP             = 0,
	JAZZ            = 1,
	ROCK            = 2,
	CLASIC          = 3,
	ELECTRONIC      = 4,
	METAL           = 5,
	PLACEHOLDER     = 6,
    PLACEHOLDER_2   = 7,
    REQUIEM         = 8,
	GRAND_FINALE    = 9,
	NUM_SONGS       = 10
}

---@enum LOVESICKCallbacks
LOVESICK.ModCallbacks = {
	POST_PRAYER = "POST_PRAYER",
	POST_PERFORMANCE = "COMPLETE_KECLEON_JOB",
	POST_BLOCK = "POST_BLOCK",
}

local costumePath = "gfx/characters/"

---@enum LovesickNullCostume
LOVESICK.NullCostume = {
	--NullCostume = Isaac.GetCostumeIdByPath(costumePath .. ""),
}


LOVESICK.PickupVariant = {
    AimPatch = Isaac.GetEntityVariantByName("Aim Patch"),
    BlessedPatch = Isaac.GetEntityVariantByName("Blessed Patch"),
    CloverPatch = Isaac.GetEntityVariantByName("Clover Patch"),
    CursedPatch = Isaac.GetEntityVariantByName("Cursed Patch"),
    RagePatch = Isaac.GetEntityVariantByName("Rage Patch"),    
    SorrowPatch = Isaac.GetEntityVariantByName("Sorrow Patch"),
    SpeedPatch = Isaac.GetEntityVariantByName("Speed Patch"),
    VelocityPatch = Isaac.GetEntityVariantByName("Power Patch"),
}

LOVESICK.PatchType ={
	"AimPatch",
	"BlessedPatch",
	"CloverPatch",
	"CursedPatch",
	"RagePatch",
	"SorrowPatch",
	"SpeedPatch",
	"VelocityPatch"
}

---@enum LovesickPlayerType
LOVESICK.PlayerType = {
    Rick = Isaac.GetPlayerTypeByName("Rick"),
    Rickb = Isaac.GetPlayerTypeByName("Rick",true),
    Snowball = Isaac.GetPlayerTypeByName("Snowball"),
}

---@type table<CollectibleType, PlayerType>
LOVESICK.BirthrightToPlayerType = {
	--[LOVESICK.CollectibleType.BIRTHRIGHTHERE] = LOVESICK.PlayerType.PLAYERHERE
}

---@type table<PlayerType, boolean>
LOVESICK.IsPlayerSpiritForm = {
	[LOVESICK.PlayerType.Rickb] = true,
}

---@type table<PlayerType, boolean>
LOVESICK.IsSnowballForm = {
    [LOVESICK.PlayerType.Snowball] = true,
}

---@enum LovesickSlotVariant
LOVESICK.SlotVariant = {
	TINKER_STATION = Isaac.GetEntityVariantByName("Tinker Station"),
	VENDING_NACHINE = Isaac.GetEntityVariantByName("Vending Machine"),
	SCRAP_A_LOT = Isaac.GetEntityVariantByName("Scrap A-Lot"),
}

---@enum VendingSubType
LOVESICK.VendingSubType = {
    DRINKS = Isaac.GetEntitySubTypeByName("Vending Machine (Drinks)"),
    MEALS = Isaac.GetEntitySubTypeByName("Vending Machine (Meals)"),
    TOYS = Isaac.GetEntitySubTypeByName("Vending Machine (Toys)"),
    PRIZES = Isaac.GetEntitySubTypeByName("Vending Machine (Prizes)"),
}

---@enum LovesickBombVariant
LOVESICK.BombVariant = {
}

LOVESICK.SantuarySubType = {
	ASIA = Isaac.GetEntitySubTypeByName("Santuary (Asia)"),
	ROME = Isaac.GetEntitySubTypeByName("Santuary (Rome)"),
	CORRUPTED = Isaac.GetEntitySubTypeByName("Santuary (Corrupted)"),
	RUINS = Isaac.GetEntitySubTypeByName("Ruined Santuary"),
}

---@enum LovesickSoundEffect
LOVESICK.SoundEffect = {
	--SWIFT_FIRE = Isaac.GetSoundIdByName("Swift Fire")
}

LOVESICK.Sprite = {
	--JobMiniHUD_Normal = Sprite("gfx/ui_job_hud_icons.anm2"),
}

---@enum LovesickTrinketType
LOVESICK.TrinketType = {
	PAPER_ROSE = Isaac.GetTrinketIdByName("Paper Rose"),
    BIG_FUSE = Isaac.GetTrinketIdByName("Big Fuse"),
    OLD_DRAWING = Isaac.GetTrinketIdByName("Old Drawing"),
}

---@enum LovesickTearVariant
LOVESICK.TearVariant = {
	--WONDERCOIN = Isaac.GetEntityVariantByName("Wonder Coin Tear"),
}



return LOVESICK
