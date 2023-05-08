local Content = {}

function Content:AddModConfigOptions(settings,HasFixes)
    if ModConfigMenu then 
        local LoveSick = "LoveSick"
        ModConfigMenu.UpdateCategory(LoveSick, {
                Info = {"Love is in the air, or are farts?",}
            })
        --Title
            ModConfigMenu.AddText(LoveSick, "Settings", function() return "Spider Mod additional info options" end)
            -- Settings
            ModConfigMenu.AddSetting(LoveSick, "Settings", { --HideBPM
                    Type = ModConfigMenu.OptionType.BOOLEAN,
                    CurrentSetting = function()
                        return settings.HideBPM end,
                    Display = function()
                        local onOff = "False"
                        if settings.HideBPM then onOff = "True" end
                        return 'Hide BPM: ' .. onOff end,
                    OnChange = function(currentBool)
                        settings.HideBPM = currentBool
                        LOVESICK.SaveSettings() end,
                    Info = function()
                        local Text = settings.HideBPM and " " or " not "
                        local TotalText = "BPM  will" .. Text .. "be hidden withouth Spider Mod."
                        return TotalText end
                })
            ModConfigMenu.AddSetting(LoveSick, "Settings", { --AlwaysShieldNumber
                    Type = ModConfigMenu.OptionType.BOOLEAN,
                    CurrentSetting = function()
                        return settings.ShieldNumberAlways end,
                    Display = function()
                        local onOff = "False"
                        if settings.ShieldNumberAlways then onOff = "True" end
                        return 'Always Show Shield Number: ' .. onOff end,
                    OnChange = function(currentBool)
                        settings.ShieldNumberAlways = currentBool
                        LOVESICK.SaveSettings() end,
                    Info = function()
                        local Text = settings.ShieldNumberAlways and " " or " not "
                        local TotalText = "Shield number will " .. Text .. " be shown withouth Spider Mod."
                        return TotalText end
                })
    
            ModConfigMenu.AddText(LoveSick, "Settings", function() return "Timers and others" end)
    
            ModConfigMenu.AddSetting(LoveSick,"Settings", {  --TimeBPM
                    Type = ModConfigMenu.OptionType.SCROLL,
                    CurrentSetting = function()
                      return (settings.TimeBPM/5)
                    end,
                    Display = function()
                      return "Monitor time: $scroll" .. (settings.TimeBPM/5)
                    end,
                    OnChange = function(n)
                      settings.TimeBPM = 5*n
                      LOVESICK.SaveSettings() end,
                    Info = function()
                        if settings.TimeBPM == 50 then 
                        local TotalText = "The display time is infinite."
                        return TotalText
                        else
                        local Text = tostring(settings.TimeBPM) 
                        local TotalText = "The display time is of " .. Text .. " seconds."
                        return TotalText end
                        end
                })
                if HasFixes then
                    ModConfigMenu.AddText(LoveSick, "Settings", function() return "Use RICK Fixes better" end)
                else
                ModConfigMenu.AddText(LoveSick, "Settings", function() return "Megasatan No Auto Cutscene Workaround" end)
    
                ModConfigMenu.AddSetting(LoveSick, "Settings", { --HideBPM
                    Type = ModConfigMenu.OptionType.BOOLEAN,
                    CurrentSetting = function()
                        return settings.UseWorkaroundMegasatan end,
                    Display = function()
                        local onOff = "False"
                        if settings.UseWorkaroundMegasatan then onOff = "True" end
                        return 'MegaSatan Workaround: ' .. onOff end,
                    OnChange = function(currentBool)
                        settings.UseWorkaroundMegasatan = currentBool
                        LOVESICK.SaveSettings() end,
                    Info = function()
                        local Text = settings.UseWorkaroundMegasatan and " " or " not "
                        local TotalText = "MegaSatan will" .. Text .. " use the workaround for no Cutscene."
                        return TotalText end
                })
    
                ModConfigMenu.AddSetting(LoveSick,"Settings", {  --VoidProbability
                        Type = ModConfigMenu.OptionType.SCROLL,
                        CurrentSetting = function()
                          return (settings.VoidProbability/10)
                        end,
                        Display = function()
                          return "Probability of Void: $scroll" .. (settings.VoidProbability/10)
                        end,
                        OnChange = function(n)
                          settings.VoidProbability = 10*n
                          LOVESICK.SaveSettings() end,
                        Info = function()
                            local Text = tostring(settings.VoidProbability) 
                            local TotalText = "The void portal will apear a " .. Text .. "% or the times."
                            return TotalText end
                    })
                end
    end
end

return Content