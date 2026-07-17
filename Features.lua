local Features = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local fcCFrame = Camera.CFrame
local rotX, rotY = 0, 0

function Features.Update(Config, FriendsList, char, hrp, hum)
    -- 1. Freecam Engine
    if Config.Freecam_Enabled then
        Camera.CameraType = Enum.CameraType.Scriptable
        if hrp and not hrp.Anchored then hrp.Anchored = true end
        
        if not Config.MenuOpen then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            local delta = UserInputService:GetMouseDelta()
            rotX = rotX - (delta.X * 0.15)
            rotY = math.clamp(rotY - (delta.Y * 0.15), -89, 89)
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        fcCFrame = CFrame.new(fcCFrame.Position) * CFrame.Angles(0, math.rad(rotX), 0) * CFrame.Angles(math.rad(rotY), 0, 0)
        
        local moveVector = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + fcCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - fcCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - fcCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + fcCFrame.RightVector end
        fcCFrame = fcCFrame + (moveVector * Config.Freecam_Speed)
        Camera.CFrame = fcCFrame
    end

    -- 2. Triggerbot
    if Config.Triggerbot_Enabled and Config.ESP_Enabled then
        local target = Mouse.Target
        if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
            local tPlayer = Players:GetPlayerFromCharacter(target.Parent)
            if tPlayer and tPlayer ~= LocalPlayer and not FriendsList[tPlayer.Name] then
                if UserInputService:IsKeyDown(Config.Triggerbot_Bind) then
                    mouse1click() -- Встроенная функция Xeno для клика
                end
            end
        end
    end

    -- 3. No Fall
    if Config.NoFall_Enabled and Config.ESP_Enabled and hrp then
        if hrp.Velocity.Y < -35 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        end
    end

    -- 4. Infinite Stamina
    if Config.InfStamina_Enabled and Config.ESP_Enabled and char then
        local energy = char:FindFirstChild("Stamina") or char:FindFirstChild("Energy")
        if energy and energy:IsA("ValueBase") then energy.Value = 100 end
    end

    -- 5. Auto Bhop
    if Config.Bhop_Enabled and Config.ESP_Enabled and hum and hrp then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum.FloorMaterial ~= Enum.Material.Air then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end
    end

    -- 6. No Recoil
    if Config.NoRecoil_Enabled and Config.ESP_Enabled and char then
        pcall(function()
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Configuration") then
                local rec = tool.Configuration:FindFirstChild("Recoil") or tool.Configuration:FindFirstChild("Spread")
                if rec then rec.Value = 0 end
            end
        end)
    end
end

return Features
