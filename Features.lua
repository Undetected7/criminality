local Features = {}

-- Асинхронные жесткие потоки для обхода Crim (Запускаются один раз)
if _G.LoopsHooked == nil then
    _G.LoopsHooked = true
    
    -- Цикл Infinite Stamina (Постоянно обнуляем веса и фризим стамину на клиенте)
    task.spawn(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        while true do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if char and _G.GrimoireConfig and _G.GrimoireConfig.InfStamina_Enabled then
                local st = char:FindFirstChild("Stamina") or LocalPlayer:FindFirstChild("Stamina")
                if st then st.Value = 100 end
                
                local attr = char:FindFirstChild("Attributes") or LocalPlayer:FindFirstChild("Attributes")
                if attr then
                    local w = attr:FindFirstChild("Weight") or attr:FindFirstChild("EquippedWeight")
                    if w then w.Value = 0 end
                end
            end
        end
    end)

    -- Цикл No Fall Damage (Ловим вектор критического падения)
    task.spawn(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        while true do
            task.wait()
            local char = LocalPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            if hrp and _G.GrimoireConfig and _G.GrimoireConfig.NoFall_Enabled then
                if hrp.Velocity.Y < -32 then
                    -- Создаем микро-сдвиг позиции вверх для сброса серверного счетчика высоты
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 1.5, 0)
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -4, hrp.Velocity.Z)
                    task.wait(0.05)
                end
            end
        end
    end)
end

function Features.Update(Config, FriendsList, char, hrp, hum)
    local Camera = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")

    -- Синхронизируем глобальный конфиг для асинхронных циклов
    _G.GrimoireConfig = Config

    -- Freecam Engine
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
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + _G.fcCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - _G.fcCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - _G.fcCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + _G.fcCFrame.RightVector end
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
