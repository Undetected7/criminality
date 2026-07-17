local Features = {}

if _G.LoopsHooked == nil then
    _G.LoopsHooked = true
    
    -- Цикл перехвата и обхода триггеров высоты
    task.spawn(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        while true do
            task.wait()
            local char = LocalPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            if hrp and _G.GrimoireConfig and _G.GrimoireConfig.NoFall_Enabled then
                -- Безопасный перехват вектора критического ускорения для снижения урона
                if hrp.Velocity.Y < -35 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -5, hrp.Velocity.Z)
                end
            end
        end
    end)
end

function Features.Update(Config, FriendsList, char, hrp, hum)
    local Camera = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    _G.GrimoireConfig = Config

    -- Умное переопределение камеры от 3-го лица
    if Config.Camera_Override and not Config.Freecam_Enabled then
        Camera.FieldOfView = Config.Camera_FOV
        pcall(function()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            if LocalPlayer then
                LocalPlayer.CameraMaxZoomDistance = Config.Camera_Dist
                LocalPlayer.CameraMinZoomDistance = 5
            end
        end)
    end

    -- Стандартный Freecam движок
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
