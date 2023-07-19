local deli_ex = {}

--[[
    if npc:ToNPC():IsBoss() then
        if saveData.run.persistent.BossQueue ~= nil then
            BossQueue = saveData.run.persistent.BossQueue
        end
        local bossData = {npc.Type, npc.SubType, npc.Variant,}
        local IsCustomDeliFight = false
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if ent.Type == enums.Entities.DELIRIUM_EX.type and ent.Variant == enums.Entities.DELIRIUM_EX.variant then
                IsCustomDeliFight = true
            end
        end
        if not IsCustomDeliFight and not ((npc.Type == EntityType.ENTITY_DELIRIUM) or (npc.Type == EntityType.ENTITY_ISAAC and npc.Variant == 2) or (npc.Type == EntityType.ENTITY_HUSH) or (npc.Type == EntityType.ENTITY_MEGA_SATAN) or (npc.Type == EntityType.ENTITY_MEGA_SATAN_2) or (npc.Type == EntityType.ENTITY_GIDEON) or (npc.Type == EntityType.ENTITY_MOTHER) or (npc.Type == EntityType.ENTITY_MOTHERS_SHADOW)) then
            util.QueueStore(bossData,BossQueue)
            save.EditData(BossQueue,"BossQueue")
        else
            if not npc.Type == DELIRIUM_EX_TYPE  and not npc.Variant == DELIRIUM_EX_VARIANT and not npc.Parent then
                for _, ent in pairs(Isaac.GetRoomEntities()) do
                    if ent.Type == DELIRIUM_EX_TYPE and ent.Variant == DELIRIUM_EX_VARIANT then
                        local data = ent:GetData()
                        data.defeatedFoes = data.defeatedFoes + 1
                    end
                end
            end
        end
        if dataCache.run.persistent.BossQueue == nil then
            dataCache.run.persistent.BossQueue = BossQueue
        end
        
        LOVESICK.SaveModData()
        if npc.Type == DELIRIUM_EX_TYPE and npc.Variant == DELIRIUM_EX_VARIANT and npc.SubType == 0 then
            local Deli = Isaac.Spawn(EntityType.ENTITY_DELIRIUM,0,0,npc.Position,Vector.Zero,npc)
            Deli.Parent = npc
            npc:Remove()
            Deli.HitPoints = 1
            --Deli:ToNPC().State = NpcState.STATE_DEATH
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                --print(ent.Type,ent.Variant,ent.SubType)
                if ent:IsBoss() and not ent.Type==EntityType.ENTITY_DELIRIUM then -- position = ent.Position 
                    ent:Remove()
                end
            end 
        end
        if npc.Type == EntityType.ENTITY_DELIRIUM then
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                --print(ent.Type,ent.Variant,ent.SubType)
                if ent.Type == EntityType.ENTITY_EFFECT and ent.Variant == EffectVariant.OCCULT_TARGET and ent.SubType == 20 then -- position = ent.Position 
                    ent:Remove()
                end
            end
        end
    end]]

return deli_ex