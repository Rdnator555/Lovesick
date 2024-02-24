local rd = require("lovesick-src.RickHelper")
local postRender = {}

function postRender:main()
	local renderMode = LOVESICK.room:GetRenderMode()

	if renderMode == RenderMode.RENDER_NULL
		or renderMode == RenderMode.RENDER_NORMAL
		or renderMode == RenderMode.RENDER_WATER_ABOVE
	then
		if Sewn_API then
		end
	end
end

function postRender:init(mod)
	mod:AddCallback(ModCallbacks.MC_POST_RENDER, postRender.main)
end

return postRender
