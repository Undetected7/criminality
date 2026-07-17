-- =========================================================================
--                     GRIMOIRE.CC // V15 FINAL LOADER
-- =========================================================================
repeat task.wait() until game:IsLoaded()

local GITHUB_USER = "Undetected7"
local REPO_NAME = "criminality"
local BRANCH = "main"
local BaseUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GITHUB_USER, REPO_NAME, BRANCH)

local function SafeLoad(fileName)
    local url = BaseUrl .. fileName .. "?rand=" .. math.random(1000, 9999)
    local success, content = pcall(function() return game:HttpGet(url) end)
    
    if not success or not content then
        warn(string.format("[Grimoire.cc] Бля, не удалось скачать файл: %s", fileName))
        return nil
    end
    
    local linker, err = loadstring(content)
    if not linker then
        warn(string.format("[Grimoire.cc] Ошибка компиляции %s: %s", fileName, tostring(err)))
        return nil
    end
    
    local runSuccess, result = pcall(linker)
    if not runSuccess then
        warn(string.format("[Grimoire.cc] Ошибка выполнения %s: %s", fileName, tostring(result)))
        return nil
    end
    
    return result
end

print("[Grimoire] Синтез запущен... Пожалуйста, подожди, Джекки!")

local ConfigData = SafeLoad("Config.lua")
if ConfigData then
    _G.GrimoireConfig = ConfigData.Config
    _G.GrimoireChams = ConfigData.ChamsConfig
    _G.GrimoireFriends = ConfigData.FriendsList

    local UI = SafeLoad("UI.lua")
    local Features = SafeLoad("Features.lua")
    local Visuals = SafeLoad("Visuals.lua")

    if UI and Features and Visuals then
        UI.Init(_G.GrimoireConfig, _G.GrimoireFriends)
        Visuals.Init(_G.GrimoireConfig, _G.GrimoireChams, _G.GrimoireFriends)

        game:GetService("RunService").RenderStepped:Connect(function()
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            Features.Update(_G.GrimoireConfig, _G.GrimoireFriends, char, hrp, hum)
            Visuals.Update(_G.GrimoireConfig, _G.GrimoireChams, _G.GrimoireFriends)
        end)
        
        print("[Grimoire] ==========================================")
        print("[Grimoire] ВСЁ ГОТОВО, МОЙ СЛАДКИЙ! Нажимай INSERT!")
        print("[Grimoire] ==========================================")
    else
        warn("[Grimoire] Ошибка сборки модулей. Проверь консоль!")
    end
else
    warn("[Grimoire] Сука, не удалось загрузить конфигурационный файл!")
end
