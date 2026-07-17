-- =========================================================================
--                     GRIMOIRE.CC // CONFIG MODULE (V17)
-- =========================================================================
local Color3 = Color3 or _G.Color3 or game:GetService("Players").LocalPlayer.Character and Color3
local Enum = Enum or _G.Enum

local Config = {
    MenuOpen = true,
    ESP_Enabled = false,
    ESP_Boxes = false,
    ShowNames = false,
    ShowHP = false,
    ShowWeapon = false,
    
    Chams_Enabled = false,
    Chams_Hue = 0,
    Skeleton_Enabled = false,
    Fullbright_Enabled = false,
    Fullbright_Gamma = 160,
    Ambient_Custom = false,
    NoPostProcessing = false,
    
    Storage_Enabled = false,
    Storage_Safes = true,
    Storage_Registers = true,
    Storage_Loot = true,
    
    Freecam_Enabled = false,
    Freecam_Bind = typeof(Enum) ~= "nil" and Enum.KeyCode.F or nil,
    Freecam_Speed = 1.2,
    
    Camera_Override = false,
    Camera_Bind = typeof(Enum) ~= "nil" and Enum.KeyCode.G or nil,
    Camera_FOV = 90,
    Camera_Dist = 12,
    
    FlyHack_Enabled = false, -- Новое!
    FlyHack_Bind = typeof(Enum) ~= "nil" and Enum.KeyCode.H or nil, -- Бинд на полёт
    FlyHack_Speed = 1.5,
}

local ChamsConfig = {
    EnemyColor = Color3 and Color3.fromRGB(255, 0, 128) or nil,
    FriendColor = Color3 and Color3.fromRGB(0, 255, 100) or nil,
    StorageColor = Color3 and Color3.fromRGB(255, 200, 0) or nil,
    OutlineColor = Color3 and Color3.fromRGB(255, 255, 255) or nil,
    FillTransparency = 0.5
}

local FriendsList = {}

return {Config = Config, ChamsConfig = ChamsConfig, FriendsList = FriendsList}
