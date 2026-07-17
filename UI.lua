local UI = {}

function UI.Init(Config, FriendsList)
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer

    -- База интерфейса
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Grimoire_Godmode_v15"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 560, 0, 460) -- Немного расширили под превью-модельку!
    MenuFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
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

    -- Функция создания подменю
    local function CreateSubMenu(sizeY, parent)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 180, 0, sizeY)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BorderSizePixel = 1
        Frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        Frame.Visible = false
        Frame.ZIndex = 10
        Frame.Parent = parent
        return Frame
    end

    local ESPSub = CreateSubMenu(130, MenuFrame) -- Подменю для ESP
    local FullbrightSub = CreateSubMenu(40, MenuFrame)
    local StorageSub = CreateSubMenu(100, MenuFrame)

    -- Настройка слайдера гаммы
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

    -- Быстрая функция создания суб-переключателей
    local function CreateSubToggle(name, yPos, configKey, parent, onChange)
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
            if onChange then onChange() end
        end)
    end

    -- Наполнение суб-менюшек
    CreateSubToggle("Filter: Safes", 5, "Storage_Safes", StorageSub)
    CreateSubToggle("Filter: Registers", 35, "Storage_Registers", StorageSub)
    CreateSubToggle("Filter: Loose Loot Piles", 65, "Storage_Loot", StorageSub)

    local isBindingFreecam = false
    local isBindingTrigger = false

    -- Наполнение ESP суб-меню
    local updatePreview -- Объявим ниже
    CreateSubToggle("Show Boxes", 5, "ESP_Boxes", ESPSub, function() updatePreview() end)
    CreateSubToggle("Show Names", 35, "ShowNames", ESPSub, function() updatePreview() end)
    CreateSubToggle("Show HP Bar", 65, "ShowHP", ESPSub, function() updatePreview() end)
    CreateSubToggle("Show Weapon", 95, "ShowWeapon", ESPSub, function() updatePreview() end)

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

        -- ЛКМ клик
        Button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(35, 35, 35)
            Button.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
            if onChange then onChange() end
        end)

        -- ПКМ клик для открытия суб-меню
        Button.MouseButton2Click:Connect(function()
            ESPSub.Visible = false
            StorageSub.Visible = false
            FullbrightSub.Visible = false
            
            if configKey == "ESP_Enabled" then
                ESPSub.Position = UDim2.new(0, 10, 0, yPos + 75)
                ESPSub.Visible = not ESPSub.Visible
            elseif configKey == "Fullbright_Enabled" then
                FullbrightSub.Position = UDim2.new(0, 10, 0, yPos + 75)
                FullbrightSub.Visible = not FullbrightSub.Visible
            elseif configKey == "Storage_Enabled" then
                StorageSub.Position = UDim2.new(0, 10, 0, yPos + 75)
                StorageSub.Visible = not StorageSub.Visible
            end
        end)

        -- Бинды клавиш
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

    -- Наш новый список кнопок (БЕЗ RECOIL)
    CreateToggle("ESP (RMB)", 0, "ESP_Enabled")
    CreateToggle("Enable Chams", 30, "Chams_Enabled")
    CreateToggle("2D Screen Skeletons", 60, "Skeleton_Enabled")
    CreateToggle("Storage ESP (RMB)", 90, "Storage_Enabled")
    CreateToggle("Fullbright (RMB)", 120, "Fullbright_Enabled")
    CreateToggle("Freecam (RMB)", 150, "Freecam_Enabled")
    CreateToggle("Triggerbot (RMB)", 180, "Triggerbot_Enabled")
    CreateToggle("No Fall Damage", 210, "NoFall_Enabled")
    CreateToggle("Infinite Stamina", 240, "InfStamina_Enabled")
    CreateToggle("Auto Bhop", 270, "Bhop_Enabled")

    -- СТИЛЬНАЯ 3D VIEWPORT PREVIEW ПАНЕЛЬ (В стиле CS/Roblox)
    local PreviewContainer = Instance.new("Frame")
    PreviewContainer.Size = UDim2.new(0, 180, 0, 240)
    PreviewContainer.Position = UDim2.new(0, 220, 0, 40)
    PreviewContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PreviewContainer.BorderSizePixel = 1
    PreviewContainer.BorderColor3 = Color3.fromRGB(40, 40, 40)
    PreviewContainer.Parent = MenuFrame

    local PreviewTitle = Instance.new("TextLabel")
    PreviewTitle.Size = UDim2.new(1, 0, 0, 25)
    PreviewTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PreviewTitle.Text = "ESP PREVIEW"
    PreviewTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PreviewTitle.Font = Enum.Font.Code
    PreviewTitle.Parent = PreviewContainer

    local Viewport = Instance.new("ViewportFrame")
    Viewport.Size = UDim2.new(1, 0, 1, -25)
    Viewport.Position = UDim2.new(0, 0, 0, 25)
    Viewport.BackgroundTransparency = 1
    Viewport.Parent = PreviewContainer

    -- Создаем роблокс-персонажа для превью
    local PreviewModel = Instance.new("Model")
    PreviewModel.Name = "PreviewDummy"
    PreviewModel.Parent = Viewport

    local Part = Instance.new("Part")
    Part.Size = Vector3.new(2, 2, 1)
    Part.Color = Color3.fromRGB(180, 180, 180)
    Part.Position = Vector3.new(0, 0, 0)
    Part.Anchored = true
    Part.Parent = PreviewModel
    PreviewModel.PrimaryPart = Part

    local Head = Instance.new("Part")
    Head.Size = Vector3.new(1.2, 1.2, 1.2)
    Head.Color = Color3.fromRGB(220, 170, 130)
    Head.Position = Vector3.new(0, 1.5, 0)
    Head.Shape = Enum.PartType.Ball
    Head.Anchored = true
    Head.Parent = PreviewModel

    -- Отрисовка визуала внутри превью
    local PreviewBox = Instance.new("Frame")
    PreviewBox.Size = UDim2.new(0.6, 0, 0.8, 0)
    PreviewBox.Position = UDim2.new(0.2, 0, 0.1, 0)
    PreviewBox.BackgroundTransparency = 1
    PreviewBox.BorderColor3 = Color3.fromRGB(0, 255, 100)
    PreviewBox.BorderSizePixel = 1
    PreviewBox.Visible = false
    PreviewBox.Parent = Viewport

    local PreviewName = Instance.new("TextLabel")
    PreviewName.Size = UDim2.new(1, 0, 0, 15)
    PreviewName.Position = UDim2.new(0, 0, -0.08, 0)
    PreviewName.BackgroundTransparency = 1
    PreviewName.Text = "Player_Dummy (100HP)"
    PreviewName.TextColor3 = Color3.fromRGB(0, 255, 100)
    PreviewName.Font = Enum.Font.Code
    PreviewName.TextSize = 10
    PreviewName.Visible = false
    PreviewName.Parent = PreviewBox

    local PreviewHealth = Instance.new("Frame")
    PreviewHealth.Size = UDim2.new(0, 3, 1, 0)
    PreviewHealth.Position = UDim2.new(-0.08, 0, 0, 0)
    PreviewHealth.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    PreviewHealth.BorderSizePixel = 0
    PreviewHealth.Visible = false
    PreviewHealth.Parent = PreviewBox

    local PreviewWeapon = Instance.new("TextLabel")
    PreviewWeapon.Size = UDim2.new(1, 0, 0, 15)
    PreviewWeapon.Position = UDim2.new(0, 0, 1.02, 0)
    PreviewWeapon.BackgroundTransparency = 1
    PreviewWeapon.Text = "[Deagle]"
    PreviewWeapon.TextColor3 = Color3.fromRGB(255, 255, 255)
    PreviewWeapon.Font = Enum.Font.Code
    PreviewWeapon.TextSize = 10
    PreviewWeapon.Visible = false
    PreviewWeapon.Parent = PreviewBox

    -- Камера для превью
    local PreviewCam = Instance.new("Camera")
    PreviewCam.CFrame = CFrame.new(Vector3.new(0, 0.5, 5.5), Part.Position)
    Viewport.CurrentCamera = PreviewCam
    PreviewCam.Parent = Viewport

    updatePreview = function()
        PreviewBox.Visible = Config.ESP_Enabled and Config.ESP_Boxes
        PreviewName.Visible = Config.ESP_Enabled and Config.ShowNames
        PreviewHealth.Visible = Config.ESP_Enabled and Config.ShowHP
        PreviewWeapon.Visible = Config.ESP_Enabled and Config.ShowWeapon
    end
    updatePreview()

    -- Friend Panel Setup (Сдвинули вправо, чтобы влезло превью!)
    local FriendContainer = Instance.new("Frame")
    FriendContainer.Size = UDim2.new(0, 140, 1, -45)
    FriendContainer.Position = UDim2.new(0, 410, 0, 40)
    FriendContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    FriendContainer.BorderSizePixel = 1
    FriendContainer.BorderColor3 = Color3.fromRGB(40, 40, 40)
    FriendContainer.Parent = MenuFrame

    local FriendTitle = Instance.new("TextLabel")
    FriendTitle.Size = UDim2.new(1, 0, 0, 25)
    FriendTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    FriendTitle.Text = "FRIENDS"
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
                if FriendsList[p.Name] then PButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0) PButton.Text = p.Name .. " [FR]" else PButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) PButton.Text = p.Name end
                PButton.TextColor3 = Color3.fromRGB(255,255,255) PButton.Parent = PlayerScroller
                PButton.MouseButton1Click:Connect(function() FriendsList[p.Name] = not FriendsList[p.Name] UpdateFriendMenu() end)
            end
        end
        PlayerScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            Config.MenuOpen = not Config.MenuOpen
            MenuFrame.Visible = Config.MenuOpen
            if not Config.MenuOpen then 
                FullbrightSub.Visible = false 
                StorageSub.Visible = false 
                ESPSub.Visible = false
            else 
                UpdateFriendMenu() 
            end
        end
    end)

    UpdateFriendMenu()
    Players.PlayerAdded:Connect(UpdateFriendMenu)
    Players.PlayerRemoving:Connect(UpdateFriendMenu)
end

return UI
