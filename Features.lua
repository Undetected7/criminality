local Features = {}

function Features.Update(Config, FriendsList, char, hrp, hum)
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    -- Инициализируем переменные движения
    if not _G.fcCFrame then _G.fcCFrame = Camera.CFrame end
    if not _G.rotX then _G.rotX = 0 end
    if not _G.rotY then _G.rotY = 0 end

    -- 1. Исправленный Freecam
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

    -- 2. Triggerbot (ИСПРАВЛЕННЫЙ)
    if Config.Triggerbot_Enabled and Config.ESP_Enabled then
        local target = Mouse.Target
        if target and target.Parent then
            local targetChar = target.Parent:IsA("Model") and target.Parent or target.Parent.Parent
            local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
            if targetHum and targetHum.Health > 0 then
                local tPlayer = Players:GetPlayerFromCharacter(targetChar)
                if tPlayer and tPlayer ~= LocalPlayer and not FriendsList[tPlayer.Name] then
                    if UserInputService:IsKeyDown(Config.Triggerbot_Bind) then
                        mouse1click()
                    end
                end
            end
        end
    end

    -- 3. No Fall Damage (ИСПРАВЛЕННЫЙ)
    if Config.NoFall_Enabled and hrp then
        if hrp.Velocity.Y < -35 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, -5, hrp.Velocity.Z) -- Плавно гасим скорость вместо резкого нуля
        end
    end

    -- 4. Infinite Stamina (ИСПРАВЛЕННЫЙ)
    if Config.InfStamina_Enabled and char then
        -- Находим скрытые значения стамины в Criminality (они часто лежат в Character или PlayerGui)
        local stamina = char:FindFirstChild("Stamina") or char:FindFirstChild("Energy") or LocalPlayer:FindFirstChild("Stamina")
        if stamina and stamina:IsA("ValueBase") then 
            stamina.Value = 100 
        end
    end

    -- 5. Auto Bhop (ИСПРАВЛЕННЫЙ)
    if Config.Bhop_Enabled and hum and hrp then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
                task.wait(0.01) -- Микро-задержка для обхода анти-спама прыжков
            end
        end
    end
end

return Features
