local Features = {}

function Features.Update(Config, FriendsList, char, hrp, hum)
    local Camera = workspace.CurrentCamera
    local Lighting = game:GetService("Lighting")
    _G.GrimoireConfig = Config

    -- 1. НАДЁЖНЫЙ КЛИЕНТСКИЙ NO POST-PROCESSING ENGINE
    if Config.NoPostProcessing then
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("ColorCorrectionEffect") then
                obj.Enabled = false
            end
        end
        pcall(function()
            local b = Camera:FindFirstChildOfClass("BlurEffect") or char:FindFirstChildOfClass("BlurEffect")
            if b then b.Enabled = false end
        end)
    end

    -- 2. Умная синхронизация угла обзора камеры 3-го лица
    if Config.Camera_Override and not Config.Freecam_Enabled then
        Camera.FieldOfView = Config.Camera_FOV
        pcall(function()
            game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = Config.Camera_Dist
        end)
    else
        pcall(function()
            game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = 12
        end)
    end

    -- 3. Полностью исправленный Freecam мотор
    if Config.Freecam_Enabled then
        Camera.CameraType = Enum.CameraType.Scriptable
        if hrp and not hrp.Anchored then hrp.Anchored = true end
        
        if not Config.MenuOpen then
            local UserInputService = game:GetService("UserInputService")
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            local delta = UserInputService:GetMouseDelta()
            _G.rotX = _G.rotX - (delta.X * 0.15)
            _G.rotY = math.clamp(_G.rotY - (delta.Y * 0.15), -89, 89)
        end
        _G.fcCFrame = CFrame.new(_G.fcCFrame.Position) * CFrame.Angles(0, math.rad(_G.rotX), 0) * CFrame.Angles(math.rad(_G.rotY), 0, 0)
        
        local moveVector = Vector3.new(0, 0, 0)
        local UIS = game:GetService("UserInputService")
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + _G.fcCFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - _G.fcCFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - _G.fcCFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + _G.fcCFrame.RightVector end
        _G.fcCFrame = _G.fcCFrame + (moveVector * Config.Freecam_Speed)
        Camera.CFrame = _G.fcCFrame
    else
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Custom
            if hrp and hrp.Anchored then hrp.Anchored = false end
        end
    end
end

return Features
