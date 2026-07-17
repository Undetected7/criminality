local Features = {}

-- Асинхронная жесткая петля для NoFall и NoPost (Только локально!)
if _G.LoopsHooked == nil then
    _G.LoopsHooked = true
    
    -- Цикл No Fall Damage (Клиентский брейкер Crim)
    task.spawn(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        while true do
            task.wait()
            local char = LocalPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            if hrp and _G.GrimoireConfig and _G.GrimoireConfig.NoFall_Enabled then
                if hrp.Velocity.Y < -32 then
                    -- Безопасный перехват вектора падения
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 1.5, 0)
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -4, hrp.Velocity.Z)
                    task.wait(0.05)
                end
            end
        end
    end)
    
    -- Цикл No Post Processing
    task.spawn(function()
        local Lighting = game:GetService("Lighting")
        while true do
            task.wait(1)
            if _G.GrimoireConfig and _G.GrimoireConfig.NoPostProcessing then
                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("ColorCorrectionEffect") then
                        obj.Enabled = false
                    end
                end
            end
        end
    end)
end

function Features.Update(Config, FriendsList, char, hrp, hum)
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local UIS = game:GetService("UserInputService")
    _G.GrimoireConfig = Config

    -- 1. ЛЕГИТНЫЙ FLY HACK (На CFrame, без киков в Crim!)
    if Config.FlyHack_Enabled and hrp then
        local targetCFrame = hrp.CFrame
        hum.PlatformStand = true -- Персонаж зависает
        
        local moveVector = Vector3.new(0, 0, 0)
        local camCF = Camera.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCF.RightVector end
        
        -- Легитный вертикальный полёт (E/Q)
        if UIS:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector - Vector3.new(0,1,0) end
        
        targetCFrame = targetCFrame + (moveVector * Config.FlyHack_Speed * Config.FlyHack_Speed)
        hrp.CFrame = targetCFrame
        hrp.Velocity = Vector3.new(0,0,0) -- Сбрасываем физическую скорость
    else
        if hum.PlatformStand then hum.PlatformStand = false end
    end

    -- 2. Умная камера от 3-го лица
    if Config.Camera_Override and not Config.Freecam_Enabled and not Config.FlyHack_Enabled then
        Camera.FieldOfView = Config.Camera_FOV
        pcall(function()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            LocalPlayer.CameraMaxZoomDistance = Config.Camera_Dist
            LocalPlayer.CameraMinZoomDistance = 5
        end)
    end

    -- 3. ПОЧИНЕННЫЙ Freecam движок
    if Config.Freecam_Enabled then
        Camera.CameraType = Enum.CameraType.Scriptable
        if hrp and not hrp.Anchored then hrp.Anchored = true end
        
        if not Config.MenuOpen then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            local delta = UserInputService:GetMouseDelta()
            _G.rotX = _G.rotX - (delta.X * 0.15)
            _G.rotY = math.clamp(_G.rotY - (delta.Y * 0.15), -89, 89)
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        _G.fcCFrame = CFrame.new(_G.fcCFrame.Position) * CFrame.Angles(0, math.rad(_G.rotX), 0) * CFrame.Angles(math.rad(_G.rotY), 0, 0)
        
        local moveVector = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + _G.fcCFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - _G.fcCFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - _G.fcCFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector - _G.fcCFrame.RightVector end
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
