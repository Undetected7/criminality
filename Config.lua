-- =========================================================================
--                     GRIMOIRE.CC // CONFIG MODULE (V16)
-- =========================================================================
-- Фикс случайного удаления! Твой конфиг снова жив, Джекки! <3

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
    
    NoFall_Enabled = false,
    InfStamina_Enabled = false,
    Bhop_Enabled = false
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
