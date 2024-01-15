local util = require("lovesick_source.utility")
local save = require("lovesick_source.save_manager")
local enums = require("lovesick_source.enums")



local achievements = {}

function achievements.onInit()
	if not enums.AchievementInit then enums.UpdateAchievementEnums() end
	---@type table
	achievements.Item = {
	    ArrestWarrant   = enums.Achievements.ArrestWarrant,
	    BirthdayCake    = enums.Achievements.BirthdayCake,
	    BoxOfLeftovers  = enums.Achievements.BoxOfLeftovers,
	    KindSoul        = enums.Achievements.KindSoul,
	    LockedHeart     = enums.Achievements.LockedHeart,
	    --LooseThread     = enums.Achievements.LooseThread,
	    --LostAndFound    = enums.Achievements.LostAndFound,
	    LoveLetter      = enums.Achievements.LoveLetter,
	    Morphine        = enums.Achievements.Morphine,
	    NeckGaiter      = enums.Achievements.NeckGaiter,
	    PaintingKit     = enums.Achievements.PaintingKit,
	    --RabbitFoot      = enums.Achievements.RabbitFoot,
	    --SewingMachine   = enums.Achievements.SewingMachine,
	    SleepingPills   = enums.Achievements.SleepingPills,
	    --Snowball        = enums.Achievements.Snowball,
	    --SnowballTreat   = enums.Achievements.SnowballTreat,
	    SunsetClock     = enums.Achievements.SunsetClock
	}
	---@type table
	achievements.Trinket = {
	    PaperRose = enums.Achievements.PaperRose
	}

end

function achievements.checkUnlock(_,iscont)
	print(iscont)
	if iscont then return end
	achievements.onInit()
    local itempool = Game():GetItemPool()
	local gpd = Isaac.GetPersistentGameData()	
		for i, v in pairs(achievements.Item) do
			if not gpd:Unlocked(v) then 
				itempool:RemoveCollectible(Isaac.GetItemIdByName(i))
				print("removed ", i , "from the itempool" )
			end
		end
		
		for i, v in pairs(achievements.Trinket) do
			if not gpd:Unlocked(v) then
				itempool:RemoveTrinket(Isaac.GetTrinketIdByName(i))
				print("removed ", i , "from the trinketpool" )
			end
		end
end


--[[
local marks = Isaac.GetCompletionMarks(Isaac.GetPlayerTypeByName("Rick")) 
for i,v in pairs(marks) do 
	print(i,v)  
	marks[i]=0 
end	
print("set marks)")
Isaac.SetCompletionMarks(marks) 
for i,v in pairs(marks) do 
	print(i,v)
end	

	 Isaac.ExecuteCommand("lockachievement 674")
	 Isaac.ExecuteCommand("lockachievement 675")
	 Isaac.ExecuteCommand("lockachievement 676")
	 Isaac.ExecuteCommand("lockachievement 677")
	 Isaac.ExecuteCommand("lockachievement 678")
	 Isaac.ExecuteCommand("lockachievement 679")
	 Isaac.ExecuteCommand("lockachievement 680")
	 Isaac.ExecuteCommand("lockachievement 681")
	 Isaac.ExecuteCommand("lockachievement 682")
	 Isaac.ExecuteCommand("lockachievement 683")
	 Isaac.ExecuteCommand("lockachievement 684")
	 Isaac.ExecuteCommand("lockachievement 685")
	 Isaac.ExecuteCommand("lockachievement 686")
	--]]

return achievements

