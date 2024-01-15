local enums = require("lovesick_source.enums")
local imguiSupport = {}

local markToUnlock = {
	[CompletionType.BOSS_RUSH] = "BossRush",
	[CompletionType.MOMS_HEART] = "MomsHeart",
	[CompletionType.HUSH] = "Hush",
	[CompletionType.ISAAC] = "Isaac",
	[CompletionType.SATAN] = "Satan",
	[CompletionType.BLUE_BABY] = "BlueBaby",
	[CompletionType.LAMB] = "Lamb",
	[CompletionType.MEGA_SATAN] = "MegaSatan",
	[CompletionType.DELIRIUM] = "Delirium",
	[CompletionType.MOTHER] = "Mother",
	[CompletionType.BEAST] = "Beast",
	[CompletionType.ULTRA_GREED] = "UltraGreed",
	[CompletionType.ULTRA_GREEDIER] = "UltraGreedier",
}

local imgui = ImGui

if imgui.ElementExists("lovesickMenu") then
	imgui.Reset()
end

imgui.CreateMenu("lovesickMenu", "LoveSick")
imgui.AddElement("lovesickMenu", "lovesickDebugMenu", ImGuiElement.MenuItem, "Debug Menu")
imgui.AddElement("lovesickMenu", "lovesickConfigMenu", ImGuiElement.MenuItem, "Config & Extras")
imgui.CreateWindow("lovesickDebugWindow", "Debug Menu")
imgui.CreateWindow("lovesickConfigWindow", "Config & Extras")
imgui.LinkWindowToElement("lovesickDebugWindow", "lovesickDebugMenu")
imgui.LinkWindowToElement("lovesickConfigWindow", "lovesickConfigMenu")

---@param difficulty number
---@param charName string
---@param isTainted boolean
function imguiSupport:UnlockManager(difficulty, charName, isTainted, charType)
	---@type PlayerType
	local  playerType
	if charType then
		playerType = charType
	else
		playerType = Isaac.GetPlayerTypeByName(charName, isTainted)
	end
	print(difficulty, charName, isTainted)
	if playerType < 0 then
		print("An error has ocurred, character doesn't exists")
		return
	else
		print(playerType)
		---@type CompletionMarks
		 local marks = Isaac.GetCompletionMarks(playerType)
		 for i,v in pairs(marks) do 
		 	if i == CompletionType.ULTRA_GREEDIER or i == "PlayerType" then goto continue end
		 	print(i,v) 
		 	print(marks[i],difficulty)
		 	marks[i]=difficulty
		 	print(marks[i])
		 	Isaac.SetCompletionMarks(marks)
		 	::continue::
		 end
		
		print("setall")
	end
end
---@param charType PlayerType
---@param mark CompletionType
---@param value integer
function imguiSupport:AchievementManager(charType,mark,value)
	if enums.AchievementInit == false then
		enums.UpdateAchievementEnums()
	end
	print("VALUES:"..charType,mark,value)
	local playerConfig = EntityConfig.GetPlayer(charType) or nil
	local charName = playerConfig:GetName() or nil
	if enums.PlayerType[charName] == nil or nil then return end
	if enums.MarksToAchievement[charType] and enums.MarksToAchievement[charType][mark] then
		local persistentGameData = Isaac.GetPersistentGameData()
		local prefix = ""
		print("OldValue:",persistentGameData:Unlocked(enums.MarksToAchievement[charType][mark]),"Whatwewant:",value>0)
		if value == 0 then
			prefix = "lock"
		end
		local command = prefix.."achievement "..enums.MarksToAchievement[charType][mark]
		Isaac.ExecuteCommand(command)
		print(command,"return:",persistentGameData:Unlocked(enums.MarksToAchievement[charType][mark]))
		print("NewValue:",persistentGameData:Unlocked(enums.MarksToAchievement[charType][mark]))
		Isaac.GetPersistentGameData()
	end
end


local marksToName = {
	[CompletionType.MOMS_HEART]		= "Mom's Heart",
	[CompletionType.ISAAC]			= "Isaac",
	[CompletionType.SATAN]			= "Satan",
	[CompletionType.BOSS_RUSH]		= "Boss Rush",
	[CompletionType.BLUE_BABY]		= "Blue Baby",
	[CompletionType.LAMB]			= "The Lamb",
	[CompletionType.MEGA_SATAN]		= "Mega Satan",
	[CompletionType.HUSH]			= "Hush",
	[CompletionType.DELIRIUM]		= "Delirium",
	[CompletionType.MOTHER]			= "Mother",
	[CompletionType.BEAST]			= "The Beast",
	[CompletionType.ULTRA_GREED]	= "Greed Mode",
	[CompletionType.ULTRA_GREEDIER]	= "Greedier Mode"
}



imgui.AddElement("lovesickDebugWindow", "lovesickUnlocksHeader", ImGuiElement.CollapsingHeader, "Unlocks")
imgui.AddTabBar("lovesickUnlocksHeader", "lovesickUnlocksTabBar")

for i,v in pairs(enums.PlayerType) do
	local isTainted = nil
	local characterName = i
	local tabName = "unlock" .. characterName .. "Tab"
	local tabDisplayName = characterName .. " Tab"
	print("a",v)
	local playerConfig = EntityConfig.GetPlayer(v)
	if playerConfig ~= nil then
		print("b",playerConfig)
		local playerType = v
		isTainted = playerConfig:IsTainted()
		
		imgui.AddTab("lovesickUnlocksTabBar", tabName, tabDisplayName)
		imgui.AddElement(tabName, "unlockManageButtonText_" .. characterName, ImGuiElement.Text, "Set all unlocks to:")
		imgui.AddElement(tabName, "unlockManageButtonTextSameLine_" .. characterName, ImGuiElement.SameLine, "")
		imgui.AddButton(tabName, "lockAll_" .. characterName, "Locked", function() imguiSupport:UnlockManager(0,characterName, isTainted) end)
		imgui.AddElement(tabName, "lockAllButtonTextSameLine_" .. characterName, ImGuiElement.SameLine, "")
		imgui.AddButton(tabName, "unlockAll_" .. characterName, "Normal", function() imguiSupport:UnlockManager(1,characterName, isTainted) end)
		imgui.AddElement(tabName, "unlockAllButtonTextSameLine_" .. characterName, ImGuiElement.SameLine, "")
		imgui.AddButton(tabName, "unlockAllHard_" .. characterName, "Hard", function() imguiSupport:UnlockManager(2,characterName, isTainted) end)
		imgui.AddElement(tabName, "unlockManageButtonsSeparator_" .. characterName, ImGuiElement.Separator, "")
		for mark, name in pairs(marksToName) do
			local markName = marksToName[mark]
			imgui.AddElement(tabName, "unlock" .. characterName .. "Text_" .. name, ImGuiElement.Text, markName .. ":")
			imgui.AddElement(tabName, "unlock" .. characterName .. "TextSameLine_" .. name, ImGuiElement.SameLine, "")
			imgui.AddRadioButtons(tabName, "unlock" .. characterName .. "_" .. name,
			function(i) 
				Isaac.SetCompletionMark(playerType, mark, i)
				print(i)
				imguiSupport:AchievementManager(v,mark,i) 
			end, { "Locked", "Normal", "Hard" }, 
			Isaac.GetCompletionMark(playerType, mark), true) --TODO: Since data is lodaded on mod load and not when save data is loaded, it defauts to zero. Waiting on a save slot callback.
		end
	end
end


---@type PlayerType
imguiSupport.AnyType = nil
---@type string
imguiSupport.AnyName = ""
imgui.AddTab("lovesickUnlocksTabBar", "anyCharUnlocks", "Any Character Unlock Manager")
imgui.AddElement("anyCharUnlocks", "unlockAnyIntButtonTex", ImGuiElement.Text, "Enter the character Type")
imgui.AddElement("anyCharUnlocks", "unlockAnyIntButtonTexSameLine", ImGuiElement.SameLine, "")
imgui.AddInputInteger("anyCharUnlocks", "unlockAnyManageIntInput", "", 
function(newDataValue) imguiSupport.AnyType = newDataValue 
	if newDataValue < 0 then 
		newDataValue = 0
		imgui.UpdateData("unlockAnyManageIntInput", ImGuiData.Value, newDataValue)
	end
	local playerConfig = EntityConfig.GetPlayer(newDataValue)
	if playerConfig == nil then
		newDataValue = newDataValue - 1
		imgui.UpdateData("unlockAnyManageIntInput", ImGuiData.Value, newDataValue)
		imgui.PushNotification("Error, that playertype doesn't exists",ImGuiNotificationType.ERROR)
	else
		local playerName = playerConfig:GetName()
		imguiSupport.AnyName = Isaac.GetString("Players",playerName) or playerName 
		local playerType = newDataValue
		imguiSupport.AnyType = playerType
		imgui.UpdateData("unlockAnyManageCharInput", ImGuiData.Value, playerName)
		for mark, name in pairs(marksToName) do
			local characterName = "AnyType"
			imgui.UpdateData("unlock" .. characterName .. "_" .. name, ImGuiData.Value, Isaac.GetCompletionMark(imguiSupport.AnyType, mark))
		end
	end
end)
imgui.AddElement("anyCharUnlocks", "unlockAnyCharButtonTex", ImGuiElement.Text, "or enter the character Name")
imgui.AddElement("anyCharUnlocks", "unlockAnyCharButtonTexSameLine", ImGuiElement.SameLine, "")
imgui.AddInputText("anyCharUnlocks", "unlockAnyManageCharInput", "", 
function(newDataValue) 
	imguiSupport.AnyName = Isaac.GetString("Players",newDataValue) or newDataValue 
	print(imguiSupport.AnyName)
	local playerType = Isaac.GetPlayerTypeByName(newDataValue)
	if playerType < 0 then 
		imgui.PushNotification("Error, that character name doesn't exists",ImGuiNotificationType.ERROR)
	else
		imguiSupport.AnyType = playerType
		imgui.UpdateData("unlockAnyManageIntInput", ImGuiData.Value, playerType)
		for mark, name in pairs(marksToName) do
			local characterName = "AnyType"
			local markName = marksToName[mark]
			imgui.UpdateData("unlock" .. characterName .. "_" .. name, ImGuiData.Value, Isaac.GetCompletionMark(imguiSupport.AnyType, mark))
		end
	end
end)
imgui.AddElement("anyCharUnlocks", "unlockAnyManageButtonText", ImGuiElement.Text, "Set all unlocks to:")
imgui.AddElement("anyCharUnlocks", "unlockAnyManageButtonTextSameLine1", ImGuiElement.SameLine, "")
imgui.AddButton("anyCharUnlocks", "unlockAnyManageButtonLock", "Locked", function() 
	imguiSupport:UnlockManager(0,"", false,imguiSupport.AnyType) 
	for mark, name in pairs(marksToName) do
		local characterName = "AnyType"
		imgui.UpdateData("unlock" .. characterName .. "_" .. name, ImGuiData.Value, Isaac.GetCompletionMark(imguiSupport.AnyType, mark))
	end
end)
imgui.AddElement("anyCharUnlocks", "unlockAnyManageButtonTextSameLine2", ImGuiElement.SameLine, "")
imgui.AddButton("anyCharUnlocks", "unlockAnyManageButtonNormal", "Normal", function()
	imguiSupport:UnlockManager(1,"", false, imguiSupport.AnyType) 
	for mark, name in pairs(marksToName) do
		local characterName = "AnyType"
		imgui.UpdateData("unlock" .. characterName .. "_" .. name, ImGuiData.Value, Isaac.GetCompletionMark(imguiSupport.AnyType, mark))
	end
end)
imgui.AddElement("anyCharUnlocks", "unlockAnyManageButtonTextSameLine3", ImGuiElement.SameLine, "")
imgui.AddButton("anyCharUnlocks", "unlockAnyManageButtonHard", "Hard", function() 
	imguiSupport:UnlockManager(2,"", false, imguiSupport.AnyType)
	for mark, name in pairs(marksToName) do
		local characterName = "AnyType"
		imgui.UpdateData("unlock" .. characterName .. "_" .. name, ImGuiData.Value, Isaac.GetCompletionMark(imguiSupport.AnyType, mark))
	end 
end)
imgui.AddElement("anyCharUnlocks", "unlockAnyManageButtonTextSameLine4", ImGuiElement.Separator, "")
imgui.AddElement("anyCharUnlocks", "unlockAnyManageButtonsSeparator", ImGuiElement.Separator, "")
for mark, name in pairs(marksToName) do
	local characterName = "AnyType"
	local markName = marksToName[mark]
	local defaultValue = nil
	if imguiSupport.AnyType  then defaultValue = Isaac.GetCompletionMark(imguiSupport.AnyType, mark) end
	imgui.AddElement("anyCharUnlocks", "unlock" .. characterName .. "Text_" .. name, ImGuiElement.Text, markName .. ":")
	imgui.AddElement("anyCharUnlocks", "unlock" .. characterName .. "TextSameLine_" .. name, ImGuiElement.SameLine, "")
	imgui.AddRadioButtons("anyCharUnlocks", "unlock" .. characterName .. "_" .. name,
		function(i) 
			Isaac.SetCompletionMark(imguiSupport.AnyType, mark, i)
			print(i)
			imguiSupport:AchievementManager(imguiSupport.AnyType,mark,i) 
		end, { "Locked", "Normal", "Hard" }, 
		defaultValue, true)
	end

return imguiSupport


