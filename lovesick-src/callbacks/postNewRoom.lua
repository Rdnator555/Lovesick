local rd = require("lovesick-src.RickHelper")


local postNewRoom = {}

function postNewRoom:main()
	local players = PlayerManager.GetPlayers()		--rd.GetAllPlayers()

	for _, player in ipairs(players) do
		--Per player on new room
	end
end

function postNewRoom:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom.main)
end

return postNewRoom
