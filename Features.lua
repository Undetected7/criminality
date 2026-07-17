local Features = {}

function Features.Update(Config, FriendsList, char, hrp, hum)
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    if not _G.fcCFrame then _G.fcCFrame = Camera.CFrame end
    if not _G.rotX then _G.rotX = 0 end
    if not _G.rotY then _G.rotY = 0 end

    -- 1. Freecam Engine
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

    -- 2. No Fall Damage
    if Config.NoFall_Enabled and hrp then
        if hrp.Velocity.Y < -30 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, -2, hrp.Velocity.Z)
        end
    end

    -- 3. Infinite Stamina
    if Config.InfStamina_Enabled and char then
        local staminaValue = char:FindFirstChild("Stamina") or char:FindFirstChild("Energy") or LocalPlayer:FindFirstChild("Stamina")
        if staminaValue and staminaValue:IsA("ValueBase") then 
            staminaValue.Value = 100 
        end
        pcall(function()
            local runScript = char:FindFirstChild("Animate") or char:FindFirstChild("Movement")
            if runScript then
                local staminaMod = runScript:FindFirstChild("Stamina") or runScript:FindFirstChild("Sprint")
                if staminaMod and staminaMod:IsA("ValueBase") then
                    staminaMod.Value = 100
                end
            end
        end)
    end

    -- 4. Auto Bhop
    if Config.Bhop_Enabled and hum and hrp then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
                task.wait(0.02)
            end
        end
    end
end

return Features
