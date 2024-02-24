local rd = require("lovesick-src.RickHelper")
local postNewLevel = {}

function postNewLevel:main()
	LOVESICK.room = LOVESICK.game:GetRoom()
	LOVESICK.level = LOVESICK.game:GetLevel()
	if LOVESICK.level:GetStage() == LevelStage.STAGE1_1 then return end
	
	local rooms = rd.GetAllRooms()
	--Level room related functions here
end

function postNewLevel:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewLevel.main)
end

return postNewLevel
