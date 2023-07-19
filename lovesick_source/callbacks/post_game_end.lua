local save = require("lovesick_source.save_manager")
local function postGameEnd(gameOver)
    local data = save.GetData()
    --for p = 0, Game():GetNumPlayers() -1 do
    --    local player = Isaac.GetPlayer(p)
    --    if data.run.level.mimikyu and data.run.level.mimikyu[p] then
    --        Game():ShowHallucination(30, 0)
    --        local index = data.run.level.mimikyu[p].Index
    --        local roomX = index%13
    --        local roomY = math.floor(index/13) 
    --        Isaac.ExecuteCommand("rewind") --"goto ",roomX," ",roomY, 0
    --        --player.Position.X = data.run.level.mimikyu[p].Position.X 
    --        --player.Position.Y = data.run.level.mimikyu[p].Position.Y
    --    end
    --    
    --end
end

return postGameEnd