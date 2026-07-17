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
    Freecam_Bind = Enum.KeyCode.F,
    Freecam_Speed = 1.2,
    
    Triggerbot_Enabled = false,
    Triggerbot_Bind = Enum.KeyCode.V,
    NoFall_Enabled = false,
    InfStamina_Enabled = false,
    Bhop_Enabled = false,
    NoRecoil_Enabled = false
}

local ChamsConfig = {
    EnemyColor = Color3.fromRGB(255, 0, 128),
    FriendColor = Color3.fromRGB(0, 255, 100),
    StorageColor = Color3.fromRGB(255, 200, 0),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    FillTransparency = 0.5
}

local FriendsList = {}

return {Config = Config, ChamsConfig = ChamsConfig, FriendsList = FriendsList}