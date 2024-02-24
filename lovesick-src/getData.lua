local rd = require("lovesick-src.RickHelper")

local getData = {}

-------------
--  BOMBS  --
-------------

---@class BombData
---@field FirecrackerDamageInit integer
local BombData = {
	FirecrackerDamageInit = 5,
}

---------------
--  EFFECTS  --
---------------

---@class LoveLetterEffectData
---@field Wisps EntityFamiliar[]

---@class SleepingPillsEffectData
---@field Wisps EntityFamiliar[]

---@class TrailData
---@field TrailType TrailVariant
---@field TrailColor Color
---@field IsActive boolean
---@field TrailTimeout integer

---@alias TrailVariant
---| '"Card"' 		# For cardthrowing
---| '"Plant"' 		# For plant related throws
---| '"Toothpick"' 	# For toothpick throws
---| '""'			# Nil

---@class EffectData
---@field LoveLetter LoveLetterEffectData
---@field SleepingPills SleepingPillsEffectData
---@field Trail TrailData
local EffectData = {
	LoveLetter = {
		Wisps = {}
	},
	SleepingPills = {
		Wisps = {}
	},
	Trail = {
		TrailType ="",
		TrailColor = Color.Default,
		IsActive = true,
		TrailTimeout = 5
	}
}

--------------------
--  ALL ENTITIES  --
--------------------

---@class ColorCycleData
---@field Active boolean
---@field r integer
---@field g integer
---@field b integer
---@field rChangeNum integer
---@field gChangeNum integer
---@field bChangeNum integer
---@field curColor integer


---@class RickEntityData
---@field Heartache integer
---@field Delay integer

---@class EntityData
---@field ColorCycle ColorCycleData
---@field BaseRick RickEntityData
local entityData = {
	ColorCycle = {
		Active = false,
		r = 0,
		g = 0,
		b = 0,
		rChangeNum = 1,
		gChangeNum = 1,
		bChangeNum = 1,
		curColor = 1
	},
	BaseRick = {
		Heartache = 0,
		Delay = 0,
	}
}

-----------------
--  FAMILIARS  --
-----------------

---@class KindSoulData
---@field Kindness integer
---@field Malice integer
---@field Cooldown integer
---@field Owner EntityPlayer|nil

---@class FamiliarData
---@field KindSoul KindSoulData
local FamiliarData = {
	KindSoul = {
		Kindness = 0,
		Malice = 0,
		Cooldown = 0
	}
}

--------------
--  KNIVES  --
--------------

---@class KnifeData
local KnifeData = {
}

--------------
--  LASERS  --
--------------

---@class LaserData
local LaserData = {
}

------------
--  NPCS  --
------------

---@class Patches
---@field PatchType integer
---@field PatchNum integer

---@class MimikyuData
---@field PlayerSoul PlayerID
---@field SewnPatches Patches[]

---@class NPCData
---@field Mimikyu MimikyuData
local npcData = {
	Mimikyu = {
		PlayerSoul = "",
		SewnPatches = {
		}
	}
}

---------------
--  PICKUPS  --
---------------

---@class PickupData
---@field FadeTime integer
---@field PlayerParent EntityPlayer|nil
local PickupData = {
	FadeTime = 60
}

---------------
--  PLAYERS  --
---------------

---@class PulseData
---@field Sprite Sprite
---@field Time integer

---@class ShieldData
---@field Sprite Sprite
---@field Time integer

---@class RickData
---@field Pulse PulseData
---@field Shield ShieldData
---@field StressMax integer
---@field Stress integer
---@field ShowPulseTime integer
---@field CalmDelay integer
---@field LockShield integer
---@field FPS {Old:integer, Current:integer, New:integer}
---@field Adrenaline integer
---@field IsAdrenalineActive boolean
---@field Color Color

---@class MorphineData
---@field Time integer
---@field Debuff integer 

---@class PlayerData
---@field Patches Patches[]
---@field BaseRick RickData
---@field Morphine MorphineData
local PlayerData = {
	Patches = {
	},
	BaseRick = {
		Pulse = {
			Sprite = Sprite("gfx/ui/other/heartbeatsprite.anm2"),
			Time = 0,
		},
		Shield = {
			Sprite = Sprite("gfx/ui/other/Shield.anm2"),
			Time = 0,
		},
		StressMax = 240,
		Stress = 120,
		ShowPulseTime = 12,
		CalmDelay = 5,
		LockShield = 0,
		FPS = {
			Old = 0,
			Current = 0,
			New = 0
		},
		Adrenaline = 0,
		IsAdrenalineActive = false,
		Color = Color.Default
	},
	Morphine = {
		Time = 0,
		Debuff = 0
	}
}
PlayerData.BaseRick.Pulse.Sprite:Play("Low Stress", true)
PlayerData.BaseRick.Shield.Sprite:Play("1", true)
-------------------
--  PROJECTILES  --
-------------------

---@class ProjectileData
---@field IsReflected boolean
local ProjectileData = {
	IsReflected = false,
}

-------------
--  TEARS  --
-------------


---@class TearData
---@field StoredRotation integer
local tearData = {
	StoredRotation = 0,
}

-------------
--  SLOTS  --
-------------

---@class Stock
---@field Type EntityType
---@field Variant PickupVariant
---@field SubType CollectibleType | Card | PillColor
---@field Quantity integer

---@type integer
---@alias StatusInteger
---| 0	Iddle
---| 1	Working
---| 2	Dispensed
---| 3	Locked
---| 4	Out of Stock

---@class VendingData 
---@field CurrentStock Stock[]
---@field Status StatusInteger
---@field IsJammed boolean
---@field CoinsCollected integer

---@class TinkerStationData
---@field RequiredPickups Stock[]
---@field StoredPickups Stock[]
---@field DisplayedCollectible CollectibleType|nil
---@field UsesLeft integer

---@class SlotData
---@field Vending VendingData
---@field Tinker TinkerStationData
local SlotData = {
	Vending = {
		CurrentStock = {},
		Status = 0,
		IsJammed = false,
		CoinsCollected = 0
	},
	Tinker = {
		RequiredPickups = {
		},
		StoredPickups = {},
		DisplayedCollectible = CollectibleType.COLLECTIBLE_SAD_ONION,
		UsesLeft = 3
	}
}


---------------------
--  GROUPING DATA  --
---------------------

---@class ModData
---@field Entity EntityData[]
---@field Player PlayerData[]
---@field Tear TearData[]
---@field Familiar FamiliarData[]
---@field Bomb BombData[]
---@field Pickup PickupData[]
---@field Laser LaserData[]
---@field Knife KnifeData[]
---@field Projectile ProjectileData[]
---@field NPC NPCData[]
---@field Effect EffectData[]
---@field Slot SlotData[]
getData.Data = {
	Entity = {},
	Player = {},
	Tear = {},
	Familiar = {},
	Bomb = {},
	Pickup = {},
	Laser = {},
	Knife = {},
	Projectile = {},
	NPC = {},
	Effect = {},
	Slot = {}
}

---@enum ClassType
getData.ClassType = {
	ENTITY = 1,
	PLAYER = 2,
	TEAR = 3,
	FAMILIAR = 4,
	BOMB = 5,
	PICKUP = 6,
	LASER = 7,
	KNIFE = 8,
	PROJECTILE = 9,
	NPC = 10,
	EFFECT = 11,
	SLOT = 12
}

local typeToData = {
	[EntityType.ENTITY_PLAYER] = { PlayerData, getData.Data.Player },
	[EntityType.ENTITY_TEAR] = { tearData, getData.Data.Tear },
	[EntityType.ENTITY_FAMILIAR] = { FamiliarData, getData.Data.Familiar },
	[EntityType.ENTITY_BOMB] = { BombData, getData.Data.Bomb },
	[EntityType.ENTITY_PICKUP] = { PickupData, getData.Data.Pickup },
	[EntityType.ENTITY_LASER] = { LaserData, getData.Data.Laser },
	[EntityType.ENTITY_KNIFE] = { KnifeData, getData.Data.Knife },
	[EntityType.ENTITY_PROJECTILE] = { ProjectileData, getData.Data.Projectile },
	[EntityType.ENTITY_EFFECT] = { EffectData, getData.Data.Effect },
	[EntityType.ENTITY_SLOT] = { SlotData, getData.Data.Slot }
}

-----------------
--  FUNCTIONS  --
-----------------

---@param ent Entity
function getData:GetID(ent)
	---@type string | integer
	if not ent then
		error("Who the fk ate the entity!", 3)
	end
	local id = tostring(GetPtrHash(ent))
	if ent:ToPlayer() then
		local player = ent:ToPlayer()
		---@cast player EntityPlayer
		id = rd.GetPlayerId(player)
	elseif ent:ToFamiliar() then
		local familiar = ent:ToFamiliar()
		---@cast familiar EntityFamiliar
		id = tostring(familiar.InitSeed)
	end
	return id
end

---I know it looks dumb but it's the only way for VSCode to be convenient about returning the right set of data
---Purely for easier time auto-filling, which will save a lot of time
---By Sanio
---@param ent Entity
function getData:GetEntityData(ent)
	local id = self:GetID(ent)
	return self.Data.Entity[id]
end

---@param player EntityPlayer
function getData:GetPlayerData(player)
	local id = self:GetID(player)
	return self.Data.Player[id]
end

---@param tear EntityTear
function getData:GetTearData(tear)
	local id = self:GetID(tear)
	return self.Data.Tear[id]
end

---@param familiar EntityFamiliar
function getData:GetFamiliarData(familiar)
	local id = self:GetID(familiar)
	return self.Data.Familiar[id]
end

---@param bomb EntityBomb
function getData:GetBombData(bomb)
	local id = self:GetID(bomb)
	return self.Data.Bomb[id]
end

---@param pickup EntityPickup
function getData:GetPickupData(pickup)
	local id = self:GetID(pickup)
	return self.Data.Pickup[id]
end

---@param laser EntityLaser
function getData:GetLaserData(laser)
	local id = self:GetID(laser)
	return self.Data.Laser[id]
end

---@param knife EntityKnife
function getData:GetKnifeData(knife)
	local id = self:GetID(knife)
	return self.Data.Knife[id]
end

---@param proj EntityProjectile
function getData:GetProjectileData(proj)
	local id = self:GetID(proj)
	return self.Data.Projectile[id]
end

---@param npc EntityNPC
function getData:GetNPCData(npc)
	local id = self:GetID(npc)
	return self.Data.NPC[id]
end

---@param effect EntityEffect
function getData:GetEffectData(effect)
	local id = self:GetID(effect)
	return self.Data.Effect[id]
end


---@param slot EntitySlot
function getData:GetSlotData(slot)
	local id = self:GetID(slot)
	return self.Data.Slot[id]
end

---@param ent Entity
function getData:InitData(ent)
	local validEffects = {
		[EffectVariant.SPRITE_TRAIL] = true,
	}
	if ent:ToEffect() and not validEffects[ent.Variant] then return end

	local id = self:GetID(ent)
	local typeTable = typeToData[ent.Type]
	local dataTable = {}

	if typeTable then
		rd.CopyOverTable(typeTable[1], dataTable)
		typeTable[2][id] = dataTable
	elseif ent:ToNPC() then
		rd.CopyOverTable(npcData, dataTable)
		self.Data.NPC[id] = dataTable
	end
	local entTable = {}
	rd.CopyOverTable(entityData, entTable)
	self.Data.Entity[id] = entTable
end

---@param entType EntityType
---@param id string
---@param wasNPC? boolean
function getData:RemoveData(entType, id, wasNPC)
	local typeTable = typeToData[entType]

	if typeTable then
		typeTable[2][id] = nil
	elseif wasNPC and self.Data.NPC[id] then
		self.Data.NPC[id] = nil
	elseif self.Data.Entity[id] then
		self.Data.Entity[id] = nil
	end
end

return getData
