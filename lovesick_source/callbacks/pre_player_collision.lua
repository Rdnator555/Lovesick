local enums = require("lovesick_source.enums")
local util = require("lovesick_source.utility")
local PlayerType = enums.PlayerType
local Trinket = enums.Trinket
local function prePlayerCollision(_,player,collider,low)
    local data = player:GetData()
    if player:GetPlayerType()==PlayerType.Snowball then
        if collider.Type == 5 and collider.Variant == 350 and (collider.SubType ==Trinket.AimPatch or 
        collider.SubType ==Trinket.BlessedPatch or collider.SubType ==Trinket.CloverPatch or 
        collider.SubType ==Trinket.CursedPatch or collider.SubType ==Trinket.RagePatch or 
        collider.SubType ==Trinket.SorrowPatch or collider.SubType ==Trinket.SpeedPatch or 
        collider.SubType ==Trinket.VelocityPatch) then
            --print(_,player,collider,low)
            --collider.EntityCollisionClass = 0
            --collider:Remove()
            --if data.PatchQueue == nil then
            --    data.PatchQueue ={}
            --end
            --util.QueueStore(collider,data.PatchQueue)
            --return true
        end
    end
end
return prePlayerCollision