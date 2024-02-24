local RD= {}
local refCollectible1, refCollectible2 = CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK, CollectibleType.COLLECTIBLE_LAZARUS_RAGS
local game = Game()

---@alias PlayerID string

---@param player EntityPlayer
function RD.GetPlayerId(player)
    local refColl = refCollectible1
    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_LAZARUS2_B then
        refColl = refCollectible2
    end
    return tostring(player:GetCollectibleRNG(refColl):GetSeed())
end


--This table copying function is made by Sanio.
---@param tableCopyFrom table
---@param tableCopyTo table
function RD.CopyOverTable(tableCopyFrom, tableCopyTo)
	for variableName, value in pairs(tableCopyFrom) do
		if type(value) == "table" then
			tableCopyTo[variableName] = {}
			RD.CopyOverTable(value, tableCopyTo[variableName])
		elseif type(value) == "userdata"
			---@diagnostic disable-next-line: undefined-field
			and value.PlaybackSpeed ~= nil
		then
			---@cast value Sprite
			local filename = value:GetFilename()
			local anim = value:GetAnimation()
			local overlayAnim = value:GetOverlayAnimation()
			local isPlaying = value:IsPlaying(anim)
			local isOverlayPlaying = value:IsPlaying(overlayAnim)
			local playbackSpeed = value.PlaybackSpeed
			local sprite
			if filename ~= "" then
				sprite = Sprite(filename, true)
				if isPlaying then
					sprite:Play(anim)
				else
					sprite:SetFrame(0)
				end
				if isOverlayPlaying then
					sprite:PlayOverlay(overlayAnim)
				else
					sprite:SetOverlayFrame(0)
				end
			else
				sprite = Sprite()
			end
			sprite.PlaybackSpeed = playbackSpeed
			tableCopyTo[variableName] = sprite
		else
			tableCopyTo[variableName] = value
		end
	end
end

RD.Font = {
	Terminus = Font(),
	Tempest = Font(),
	Meat10 = Font(),
	Meat16 = Font(),
}

RD.Font.Terminus:Load("font/terminus.fnt")
RD.Font.Tempest:Load("font/pftempestasevencondensed.fnt")
RD.Font.Meat10:Load("font/teammeatfont10.fnt")
RD.Font.Meat16:Load("font/teammeatfont16bold.fnt")

function RD.HasBitFlags(flags,checkedFlags)
	return flags & checkedFlags == checkedFlags
end


---This function is from Eevee reunited mod, by Sanio
---@return table
function RD.GetAllRooms()
	local collectedRooms = {}
	local level = LOVESICK.level
	local rooms = level:GetRooms()

	for i = 0, #rooms - 1 do
		local room = rooms:Get(i)
		table.insert(collectedRooms, room)
	end
	return collectedRooms
end

---@deprecated	Use PlayerManager.GetPlayers() instead
---@return EntityPlayer[]
function RD.GetAllPlayers()
	local players = {}
	for i = 0, game:GetNumPlayers() - 1 do
		table.insert(players, Isaac.GetPlayer(i))
	end
	return players
end

return RD