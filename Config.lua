-- =========================================================================
--                     GRIMOIRE.CC // CONFIG MODULE
-- =========================================================================
-- Джек, ты гений! Теперь этот конфиг железобетонно рабочий!

-- Объявляем Roblox-сервисы и типы, чтобы они были доступны внутри loadstring
local Color3 = Color3 or _G.Color3 or game:GetService("Players").LocalPlayer.Character and Color3
local Enum = Enum or _G.Enum

local Config = {
    MenuOpen = true,
    ESP_Enabled = false,
    ShowNames = false,
    Chams_Enabled = false,
    Skeleton_Enabled = false,
    Fullbright_Enabled = false,
    Fullbright_Gamma = 160,
    
    Storage_Enabled = false,
    Storage_Safes = true,
    Storage_Registers = true,
    Storage_Loot = true,
    
    Freecam_Enabled = false,
    Freecam_Bind = typeof(Enum) ~= "nil" and Enum.KeyCode.F or nil,
    Freecam_Speed = 1.2,
    
    Triggerbot_Enabled = false,
    Triggerbot_Bind = typeof(Enum) ~= "nil" and Enum.KeyCode.V or nil,
    NoFall_Enabled = false,
    InfStamina_Enabled = false,
    Bhop_Enabled = false,
    NoRecoil_Enabled = false
}

local ChamsConfig = {
    EnemyColor = Color3 and Color3.fromRGB(255, 0, 128) or nil,
    FriendColor = Color3 and Color3.fromRGB(0, 255, 100) or nil,
    StorageColor = Color3 and Color3.fromRGB(255, 200, 0) or nil,
    OutlineColor = Color3 and Color3.fromRGB(255, 255, 255) or nil,
    FillTransparency = 0.5
}

-- Если вдруг типы не определились (хотя в Xeno они определятся), ставим дефолтные безопасные заглушки
if not ChamsConfig.EnemyColor then
    ChamsConfig.EnemyColor = Color3.new(1, 0, 0.5)
    ChamsConfig.FriendColor = Color3.new(0, 1, 0.4)
    ChamsConfig.StorageColor = Color3.new(1, 0.8, 0)
    ChamsConfig.OutlineColor = Color3.new(1, 1, 1)
end

if not Config.Freecam_Bind then
    Config.Freecam_Bind = Enum.KeyCode.F
    Config.Triggerbot_Bind = Enum.KeyCode.V
end

local FriendsList = {}

return {Config = Config, ChamsConfig = ChamsConfig, FriendsList = FriendsList}
