local json = require("json")



if REPENTOGON then
    local function  initGlobalModVar()
        if LOVESICK == nil then
            LOVESICK = {}
        end
        if LOVESICK.Src == nil then 
            LOVESICK.Src = {}
        end
    end
    
    local function unloadSourceCode()
        for k,v in pairs (LOVESICK.Src) do
            package.loaded[k] = nil
        end
    end
    
    local vanillaRequire = require
    local function patchedRequire(file)
        LOVESICK.Src[file] = true
        return vanillaRequire(file)
    end
    
    if package ~= nil then
        initGlobalModVar()
        unloadSourceCode()
        require = patchedRequire
    end
    
    local modInit = require("lovesick-src.LovesickInit")
    modInit:init(json)
    
    if package ~= nil then
        require = vanillaRequire
    end
else
    --require("oldmain")
end