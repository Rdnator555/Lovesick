

local Content = {}
function Content.Timer()
    achievement:Update()
    if preload == false then
        HeartbeatSpritePreload()
        preload = true
    end
            --MaxShieldPlayer()
    curTime = Game():GetFrameCount()
    Secs= math.floor(curTime/30)
    _120BPM = math.floor(curTime/6.00*4)
    _140BPM = math.floor(curTime/5.14*4)
    _130BPM = math.floor(curTime/5.54*4)
    _190BPM = math.floor(curTime/3.78*4)

    
    
    
    for p=0, game:GetNumPlayers()-1 do
        local number = p     
        if math.floor(Secs/10) ~= oldDecs then
            ShieldSpriteSelect(p)
            if runSave.persistent.MorphineTime[p] == nil then runSave.persistent.MorphineTime[p] = 0 else
                if runSave.persistent.MorphineTime[p] > 0 then shield[p]:Update() end
                
            end
        end
        --print(Secs,_120BPM,old120BPM)
        local player = Isaac.GetPlayer(p) 
        if newRoomDelay > 0 then newRoomDelay = math.max(0, newRoomDelay-1) end
        
        if achievement:IsFinished("Appear") then 
            idle_timer = idle_timer - 1 
            if idle_timer <= 0 or Input.IsActionPressed(ButtonAction.ACTION_ITEM , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_LEFT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_DOWN , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_UP , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_RIGHT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT , player.ControllerIndex) or
            Input.IsActionPressed(ButtonAction.ACTION_DROP , player.ControllerIndex)  then 
            idle_timer = 0 
            sfxManager:Play(SoundEffect.SOUND_MENU_NOTE_HIDE, 1,  8, false, 1)
            achievement:Play("Dissapear", false) end
        end    
        if RickValues.FPS[p] == nil then unNil(p) end
        if player:GetPlayerType() == rickId then
            LOVESICK:checkIfSpiderMod()
            --print(RickValues.FPS[p],RickValues.oldFPS[p],RickValues.newFPS[p])
            RickValues.FPS[p] = (30/(RickValues.Stress[p]/3) )
            RickValues.newFPS[p] = math.floor(curTime/RickValues.FPS[p]) 
            HeartBeat()
            --print ("Jugdor",number)
        end
        if runSave.persistent.MorphineDebuff[p] == nil then runSave.persistent.MorphineDebuff[p] = 0 end
        
        if Secs ~= oldSecs then
            --print("help2",RickValues.Stress[p]) 
            if runSave.persistent.MorphineDebuff[p] ~= nil then runSave.persistent.MorphineDebuff[p]=math.max(0,runSave.persistent.MorphineDebuff[p]-0.1)end
            if runSave.persistent.MorphineTime[p] > 0 then runSave.persistent.MorphineTime[p] = runSave.persistent.MorphineTime[p] - 1 end
            if runSave.persistent.LoveLetterShame[p] ~= (nil and 0) then runSave.persistent.LoveLetterShame[p]=math.max(0,runSave.persistent.LoveLetterShame[p]-0.1)end
            local defaultDMG
            local level = Game():GetLevel()
            local stage = level:GetStage()
            if stage >= 7 then 
                defaultDMG = 2 
            else 
                defaultDMG = 1 
            end
            if player:GetPlayerType() == rickId and RickValues.LockShield[number]~=15 and RickValues.LockShield[number]>15*defaultDMG then RickValues.LockShield[number] = math.floor(RickValues.LockShield[number] -1) 
            end
            
            if number == game:GetNumPlayers()-1 then
                oldSecs = Secs 
                --print("esto2",Secs,oldSecs)
            end 
            if player:GetPlayerType() == rickId then
                
                --Aqui ersa
                if RickValues.FPS[number]== nil then else RickValues.FPS[number] = 30/(RickValues.Stress[number]/3) end
                if RickValues.newFPS[number]== nil then else RickValues.newFPS[number] = math.floor(curTime/RickValues.FPS[number]) end
                --print(number,RickValues.FPS[number],RickValues.newFPS[number],RickValues.oldFPS[number]) 
                --print(RickValues.Stress[p],p,RickValues.StressMax[p],player.Luck, player:GetPlayerType())
                --print(p)
                if RickValues.ShowPulseTime[p] > 0 and settings.TimeBPM <50 then
                    --print("1",RickValues.ShowPulseTime[p])
                    RickValues.ShowPulseTime[p] = RickValues.ShowPulseTime[p] - 1
                    --print("2",RickValues.ShowPulseTime[p])
                end
                if RickValues.CalmDelay[p] > 0 and RickValues.LockShield[p] <= 0 then
                    RickValues.CalmDelay[p] = RickValues.CalmDelay[p] -1
                elseif RickValues.LockShield[p] == 0 and RickValues.Adrenaline[p] == false then
                    local entityStressfull = 0
                    --print("help6",RickValues.Stress[p]) 
                    for _, ent in pairs(Isaac.GetRoomEntities()) do
                        local distance = math.floor(player.Position:Distance(ent.Position))
                        if ent:IsActiveEnemy(false) then
                            if distance < 100 then
                                entityStressfull = entityStressfull +1
                                local nerves = 50*player.Damage/(distance*((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())/(player:GetSoulHearts()+player:GetEffectiveMaxHearts())))
                                local renderPos = Isaac.WorldToScreen(ent.Position)
                                --Isaac.RenderText(tostring(nerves),renderPos.X,renderPos.Y-28, 0 ,1 ,0 ,0.8)
                                RickValues.Stress[p] = math.min(RickValues.Stress[p] + nerves ,RickValues.StressMax[p])
                            end
                        elseif ent.Type == EntityType.ENTITY_PROJECTILE then
                            if distance < 100 then
                                entityStressfull = entityStressfull +1
                                local bravery = player.Damage/5
                                RickValues.Stress[p] = math.min(RickValues.Stress[p] + bravery ,RickValues.StressMax[p])
                            end
                        end
                    end
                    --print("help5",RickValues.Stress[p],1/math.abs(player.Luck),RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck) ) 

                    if RickValues.Stress[p] > RickValues.StressMax[p]/2 and entityStressfull == 0 then
                        if (RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck) ) < RickValues.StressMax[p]/2 then 
                            RickValues.Stress[p] = RickValues.StressMax[p]/2
                            --print("1")
                        else RickValues.Stress[p] = RickValues.Stress[p] - math.max(1/math.abs(player.Luck),player.Luck) 
                            --print("2")
                        end                        
                    elseif entityStressfull == 0 then
                        if (RickValues.Stress[p] + math.max(1/math.abs(player.Luck),player.Luck) ) > RickValues.StressMax[p]/2 then 
                            RickValues.Stress[p] = RickValues.StressMax[p]/2
                            --print("3")
                        else RickValues.Stress[p] = RickValues.Stress[p] + math.max(1/math.abs(player.Luck),player.Luck) 
                            --print("4",p, player.Position, player.Luck)
                        end
                    end
                    --print("help4",RickValues.Stress[p]) 

                elseif RickValues.Adrenaline[p] == true then
                    local ActiveEnemies = 0
                    for _, ent in pairs(Isaac.GetRoomEntities()) do
                        if ent:IsActiveEnemy(false) then
                            ActiveEnemies = ActiveEnemies + 1
                        end
                    end
                    if RickValues.Stress[p] > 15 then
                        RickValues.Stress[p] = RickValues.Stress[p] - 15*(((player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts())/(player:GetSoulHearts()+player:GetEffectiveMaxHearts()))/math.max(ActiveEnemies,1))
                    else
                        RickValues.Adrenaline[p] = false
                        RickValues.Tired[p] = 2
                        RickValues.Stress[p] = RickValues.Stress[p] +  RickValues.LockShield[p]*10
                        RickValues.LockShield[p] = 0
                        player:AnimateSad()
                    end
                end
                --print("esto1",Secs,oldSecs,number,game:GetNumPlayers()-1)
                  
                --print("help3",RickValues.Stress[p]) 
            
        end
            --print(runSave.persistent.MorphineTime[p])
            
                
            
            
            LOVESICK:checkIfSunsetClock()
            if runSave.level.SunsetClock == nil then 
                LOVESICK:ReloadDataNeeded() 
            elseif 
                runSave.level.SunsetClock > 0 then runSave.level.SunsetClock = runSave.level.SunsetClock -1  
                if HasSunsetClock and runSave.level.SunsetClock==0 then
                    player:UseCard(Card.CARD_SUN,UseFlag.USE_NOANIM) end
            end 
        
        end
        if _120BPM ~= old120BPM  then
            if number == game:GetNumPlayers()-1 then 
                --old120BPM = _120BPM
            end
        end    
        if _130BPM ~= old130BPM  then
            if number == game:GetNumPlayers()-1 then 
                --old120BPM = _120BPM
            end
        end   
        if _140BPM ~= old140BPM  then
            if number == game:GetNumPlayers()-1 then 
                --old120BPM = _120BPM
            end
        end   
        if _190BPM ~= old190BPM  then
            if beat[number]:GetFrame() == 6 then
                --sfxManager:Play(Isaac.GetSoundIdByName("Beat_1"), 1,  8, false, 1.1)
            end
            if beat[number]:IsFinished("Easy") then
                --beat[number]:Play("Easy",true)
            end
            beat[number]:Update()
            if number == game:GetNumPlayers()-1 then 
                --old120BPM = _120BPM
                
            end
        end   
    end
end

return Content