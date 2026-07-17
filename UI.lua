local UI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

function UI.Init(Config, FriendsList)
    -- База интерфейса
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Grimoire_Godmode_v15"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 440, 0, 460)
    MenuFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MenuFrame.BorderSizePixel = 2
    MenuFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    MenuFrame.Active = true
    MenuFrame.Draggable = true
    MenuFrame.Visible = Config.MenuOpen
    MenuFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Text = "  GRIMOIRE.CC // V15 UBER PACK"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.Parent = MenuFrame

    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Size = UDim2.new(0, 200, 1, -45)
    ToggleContainer.Position = UDim2.new(0, 10, 0, 40)
    ToggleContainer.BackgroundTransparency = 1
    ToggleContainer.Parent = MenuFrame

    local function CreateSubMenu(sizeY, parent)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 180, 0, sizeY)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BorderSizePixel = 1
        Frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        Frame.Visible = false
        Frame.Parent = parent
        return Frame
    end

    local FullbrightSub = CreateSubMenu(40, MenuFrame)
    local StorageSub = CreateSubMenu(100, MenuFrame)

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0.9, 0, 0, 15)
    SliderBtn.Position = UDim2.new(0.05, 0, 0.5, -7)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBtn.Text = ""
    SliderBtn.Parent = FullbrightSub

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0.6, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(45, 120, 45)
    SliderFill.Parent = SliderBtn

    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Size = UDim2.new(1, 0, 0, 15)
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Text = "GAMMA: 160"
    SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.Font = Enum.Font.Code
    SliderTitle.Parent = FullbrightSub

    local sliding = false
    SliderBtn.MouseButton1Down:Connect(function() sliding = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    local function CreateSubToggle(name, yPos, configKey, parent)
        local SBtn = Instance.new("TextButton")
        SBtn.Size = UDim2.new(0.9, 0, 0, 24)
        SBtn.Position = UDim2.new(0.05, 0, 0, yPos)
        SBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(40, 40, 40)
        SBtn.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
        SBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        SBtn.Font = Enum.Font.Code
        SBtn.Parent = parent

        SBtn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            SBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(40, 40, 40)
            SBtn.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
        end)
    end

    CreateSubToggle("Filter: Safes", 5, "Storage_Safes", StorageSub)
    CreateSubToggle("Filter: Registers", 35, "Storage_Registers", StorageSub)
    CreateSubToggle("Filter: Loose Loot Piles", 65, "Storage_Loot", StorageSub)

    local isBindingFreecam = false
    local isBindingTrigger = false

    local function CreateToggle(name, yPos, configKey)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 26)
        Frame.Position = UDim2.new(0, 0, 0, yPos)
        Frame.BackgroundTransparency = 1
        Frame.Parent = ToggleContainer

        local isKeybindField = (configKey == "Freecam_Enabled" or configKey == "Triggerbot_Enabled")
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(isKeybindField and 0.7 or 1, 0, 1, 0)
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(35, 35, 35)
        Button.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
        Button.TextColor3 = Color3.fromRGB(220, 220, 220)
        Button.Font = Enum.Font.Code
        Button.TextSize = 12
        Button.Parent = Frame

        local BindBtn
        if isKeybindField then
            BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0.25, 0, 1, 0)
            BindBtn.Position = UDim2.new(0.75, 0, 0, 0)
            BindBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            BindBtn.Text = configKey == "Freecam_Enabled" and (Config.Freecam_Bind and Config.Freecam_Bind.Name or "...") or (Config.Triggerbot_Bind and Config.Triggerbot_Bind.Name or "...")
            BindBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
            BindBtn.Font = Enum.Font.Code
            BindBtn.Parent = Frame
            
            BindBtn.MouseButton1Click:Connect(function()
                if configKey == "Freecam_Enabled" then isBindingFreecam = true else isBindingTrigger = true end
                BindBtn.Text = "..."
            end)
        end

        Button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(35, 35, 35)
            Button.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
            
            if configKey == "Freecam_Enabled" then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = Config.Freecam_Enabled end
            end
        end)

        Button.MouseButton2Click:Connect(function()
            if configKey == "Fullbright_Enabled" then
                StorageSub.Visible = false
                FullbrightSub.Position = UDim2.new(0, 10, 0, yPos + 75)
                FullbrightSub.Visible = not FullbrightSub.Visible
            elseif configKey == "Storage_Enabled" then
                FullbrightSub.Visible = false
                StorageSub.Position = UDim2.new(0, 10, 0, yPos + 75)
                StorageSub.Visible = not StorageSub.Visible
            end
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if isBindingFreecam and configKey == "Freecam_Enabled" then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    isBindingFreecam = false
                    if input.KeyCode == Enum.KeyCode.Escape then Config.Freecam_Bind = nil BindBtn.Text = "..." else Config.Freecam_Bind = input.KeyCode BindBtn.Text = input.KeyCode.Name end
                end
            elseif isBindingTrigger and configKey == "Triggerbot_Enabled" then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    isBindingTrigger = false
                    if input.KeyCode == Enum.KeyCode.Escape then Config.Triggerbot_Bind = nil BindBtn.Text = "..." else Config.Triggerbot_Bind = input.KeyCode BindBtn.Text = input.KeyCode.Name end
                end
            end
        end)
    end

    -- Friend Panel Setup
    local FriendContainer = Instance.new("Frame")
    FriendContainer.Size = UDim2.new(0, 190, 1, -45)
    FriendContainer.Position = UDim2.new(0, 220, 0, 40)
    FriendContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    FriendContainer.BorderSizePixel = 1
    FriendContainer.BorderColor3 = Color3.fromRGB(40, 40, 40)
    FriendContainer.Parent = MenuFrame

    local FriendTitle = Instance.new("TextLabel")
    FriendTitle.Size = UDim2.new(1, 0, 0, 25)
    FriendTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    FriendTitle.Text = "FRIEND MANAGER"
    FriendTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FriendTitle.Font = Enum.Font.Code
    FriendTitle.Parent = FriendContainer

    local PlayerScroller = Instance.new("ScrollingFrame")
    PlayerScroller.Size = UDim2.new(1, -10, 1, -35)
    PlayerScroller.Position = UDim2.new(0, 5, 0, 30)
    PlayerScroller.BackgroundTransparency = 1
    PlayerScroller.ScrollBarThickness = 4
    PlayerScroller.Parent = FriendContainer

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 4)
    UIList.Parent = PlayerScroller

    local function UpdateFriendMenu()
        for _, child in pairs(PlayerScroller:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        local totalHeight = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                totalHeight = totalHeight + 24
                local PButton = Instance.new("TextButton")
                PButton.Size = UDim2.new(1, -5, 0, 20)
                PButton.Font = Enum.Font.Code
                if FriendsList[p.Name] then PButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0) PButton.Text = p.Name .. " [FRIEND]" else PButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) PButton.Text = p.Name end
                PButton.TextColor3 = Color3.fromRGB(255,255,255) PButton.Parent = PlayerScroller
                PButton.MouseButton1Click:Connect(function() FriendsList[p.Name] = not FriendsList[p.Name] UpdateFriendMenu() end)
            end
        end
        PlayerScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    end

    CreateToggle("Master ESP", 0, "ESP_Enabled")
    CreateToggle("Show Names & HP", 30, "ShowNames")
    CreateToggle("Enable Chams", 60, "Chams_Enabled")
    CreateToggle("2D Screen Skeletons", 90, "Skeleton_Enabled")
    CreateToggle("Storage ESP (RMB)", 120, "Storage_Enabled")
    CreateToggle("Fullbright (RMB)", 150, "Fullbright_Enabled")
    CreateToggle("Freecam", 180, "Freecam_Enabled")
    CreateToggle("Triggerbot", 210, "Triggerbot_Enabled")
    CreateToggle("No Fall Damage", 240, "NoFall_Enabled")
    CreateToggle("Infinite Stamina", 270, "InfStamina_Enabled")
    CreateToggle("Auto Bhop", 300, "Bhop_Enabled")
    CreateToggle("Gun No Recoil", 330, "NoRecoil_Enabled")

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            Config.MenuOpen = not Config.MenuOpen
            MenuFrame.Visible = Config.MenuOpen
            if not Config.MenuOpen then FullbrightSub.Visible = false StorageSub.Visible = false else UpdateFriendMenu() end
        end
    end)

    -- Дополнительный обработчик слайдера гаммы
    game:GetService("RunService").RenderStepped:Connect(function()
        if sliding and FullbrightSub.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local relativeX = math.clamp((mousePos.X - SliderBtn.AbsolutePosition.X) / SliderBtn.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            Config.Fullbright_Gamma = math.floor(relativeX * 255)
            SliderTitle.Text = "GAMMA: " .. Config.Fullbright_Gamma
        end
    end)

    UpdateFriendMenu()
    Players.PlayerAdded:Connect(UpdateFriendMenu)
    Players.PlayerRemoving:Connect(UpdateFriendMenu)
end

return UI
