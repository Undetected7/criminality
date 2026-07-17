local UI = {}

function UI.Init(Config, ChamsConfig, FriendsList)
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Grimoire_BY_UNDETECTED"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 560, 0, 440)
    MenuFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MenuFrame.BorderSizePixel = 2
    MenuFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    MenuFrame.Active = true
    MenuFrame.Draggable = true
    MenuFrame.Visible = Config.MenuOpen
    MenuFrame.ZIndex = 2
    MenuFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Text = "  GRIMOIRE.CC // BY UNDETECTED"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.ZIndex = 3
    Title.Parent = MenuFrame

    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Size = UDim2.new(0, 200, 1, -45)
    ToggleContainer.Position = UDim2.new(0, 10, 0, 40)
    ToggleContainer.BackgroundTransparency = 1
    ToggleContainer.ZIndex = 3
    ToggleContainer.Parent = MenuFrame

    local function CreateSubMenu(sizeY, parent)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 180, 0, sizeY)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BorderSizePixel = 1
        Frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        Frame.Visible = false
        Frame.ZIndex = 15
        Frame.Parent = parent
        return Frame
    end

    local ESPSub = CreateSubMenu(130, MenuFrame)
    local FullbrightSub = CreateSubMenu(90, MenuFrame)
    local StorageSub = CreateSubMenu(100, MenuFrame)
    local CameraSub = CreateSubMenu(60, MenuFrame)
    local ChamsSub = CreateSubMenu(50, MenuFrame)

    local function CloseAllSubMenus()
        ESPSub.Visible = false
        FullbrightSub.Visible = false
        StorageSub.Visible = false
        CameraSub.Visible = false
        ChamsSub.Visible = false
    end

    local function CreateSubToggle(name, yPos, configKey, parent, onChange)
        local SBtn = Instance.new("TextButton")
        SBtn.Size = UDim2.new(0.9, 0, 0, 24)
        SBtn.Position = UDim2.new(0.05, 0, 0, yPos)
        SBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(40, 40, 40)
        SBtn.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
        SBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        SBtn.Font = Enum.Font.Code
        SBtn.TextSize = 11
        SBtn.ZIndex = parent.ZIndex + 1
        SBtn.Parent = parent

        SBtn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            SBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(40, 40, 40)
            SBtn.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
            if onChange then onChange() end
        end)
    end

    CreateSubToggle("Filter: Safes", 5, "Storage_Safes", StorageSub)
    CreateSubToggle("Filter: Registers", 35, "Storage_Registers", StorageSub)
    CreateSubToggle("Filter: Loose Loot Piles", 65, "Storage_Loot", StorageSub)

    local isBindingFreecam = false
    local updatePreview

    CreateSubToggle("Show Boxes", 5, "ESP_Boxes", ESPSub, function() updatePreview() end)
    CreateSubToggle("Show Names", 35, "ShowNames", ESPSub, function() updatePreview() end)
    CreateSubToggle("Show HP Bar", 65, "ShowHP", ESPSub, function() updatePreview() end)
    CreateSubToggle("Show Weapon", 95, "ShowWeapon", ESPSub, function() updatePreview() end)

    CreateSubToggle("Ambient Color Changer", 5, "Ambient_Custom", FullbrightSub)
    CreateSubToggle("Enable 3rd Person", 5, "Camera_Override", CameraSub)

    -- Colour Picker
    local HueBar = Instance.new("TextButton")
    HueBar.Size = UDim2.new(0.9, 0, 0, 15)
    HueBar.Position = UDim2.new(0.05, 0, 0, 25)
    HueBar.Text = ""
    HueBar.ZIndex = 16
    HueBar.Parent = ChamsSub

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, Yellow or 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    })
    UIGradient.Parent = HueBar

    local HuePicker = Instance.new("Frame")
    HuePicker.Size = UDim2.new(0, 6, 1, 4)
    HuePicker.Position = UDim2.new(Config.Chams_Hue or 0, -3, 0, -2)
    HuePicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HuePicker.BorderSizePixel = 1
    HuePicker.ZIndex = 17
    HuePicker.Parent = HueBar

    local PickerTitle = Instance.new("TextLabel")
    PickerTitle.Size = UDim2.new(1, 0, 0, 15)
    PickerTitle.Position = UDim2.new(0, 0, 0, 5)
    PickerTitle.BackgroundTransparency = 1
    PickerTitle.Text = "CHAMS COLOR PICKER"
    PickerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PickerTitle.Font = Enum.Font.Code
    PickerTitle.TextSize = 10
    PickerTitle.ZIndex = 16
    PickerTitle.Parent = ChamsSub

    local choosingColor = false
    HueBar.MouseButton1Down:Connect(function() choosingColor = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then choosingColor = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if choosingColor and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = UserInputService:GetMouseLocation().X
            local barLeft = HueBar.AbsolutePosition.X
            local barWidth = HueBar.AbsoluteSize.X
            local pct = math.clamp((mouseX - barLeft) / barWidth, 0, 1)
            
            HuePicker.Position = UDim2.new(pct, -3, 0, -2)
            Config.Chams_Hue = pct
            ChamsConfig.EnemyColor = Color3.fromHSV(pct, 1, 1)
            updatePreview()
        end
    end)

    local function CreateToggle(name, yPos, configKey)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 26)
        Frame.Position = UDim2.new(0, 0, 0, yPos)
        Frame.BackgroundTransparency = 1
        Frame.ZIndex = 3
        Frame.Parent = ToggleContainer

        local hasBind = (configKey == "Freecam_Enabled" or configKey == "Camera_Override")
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(hasBind and 0.7 or 1, 0, 1, 0)
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(35, 35, 35)
        Button.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
        Button.TextColor3 = Color3.fromRGB(220, 220, 220)
        Button.Font = Enum.Font.Code
        Button.TextSize = 12
        Button.ZIndex = 4
        Button.Parent = Frame

        local BindBtn
        if hasBind then
            BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0.25, 0, 1, 0)
            BindBtn.Position = UDim2.new(0.75, 0, 0, 0)
            BindBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            local currentBind = (configKey == "Freecam_Enabled") and Config.Freecam_Bind or Config.Camera_Bind
            BindBtn.Text = currentBind and currentBind.Name or "..."
            BindBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
            BindBtn.Font = Enum.Font.Code
            BindBtn.ZIndex = 4
            BindBtn.Parent = Frame
            
            BindBtn.MouseButton1Click:Connect(function()
                _G.BindingKey = configKey
                BindBtn.Text = "..."
            end)
        end

        Button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(35, 35, 35)
            Button.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
            CloseAllSubMenus()
            updatePreview()
        end)

        Button.MouseButton2Click:Connect(function()
            local lastState = false
            if configKey == "ESP_Enabled" then lastState = ESPSub.Visible
            elseif configKey == "Fullbright_Enabled" then lastState = FullbrightSub.Visible
            elseif configKey == "Storage_Enabled" then lastState = StorageSub.Visible
            elseif configKey == "Camera_Override" then lastState = CameraSub.Visible
            elseif configKey == "Chams_Enabled" then lastState = ChamsSub.Visible end
            
            CloseAllSubMenus()
            
            if configKey == "ESP_Enabled" then ESPSub.Position = UDim2.new(0, 10, 0, yPos + 75) ESPSub.Visible = not lastState
            elseif configKey == "Fullbright_Enabled" then FullbrightSub.Position = UDim2.new(0, 10, 0, yPos + 75) FullbrightSub.Visible = not lastState
            elseif configKey == "Storage_Enabled" then StorageSub.Position = UDim2.new(0, 10, 0, yPos + 75) StorageSub.Visible = not lastState
            elseif configKey == "Camera_Override" then CameraSub.Position = UDim2.new(0, 10, 0, yPos + 75) CameraSub.Visible = not lastState
            elseif configKey == "Chams_Enabled" then ChamsSub.Position = UDim2.new(0, 10, 0, yPos + 75) ChamsSub.Visible = not lastState end
        end)

        task.spawn(function()
            while true do
                task.wait(0.5)
                if hasBind and BindBtn then
                    local b = (configKey == "Freecam_Enabled") and Config.Freecam_Bind or Config.Camera_Bind
                    BindBtn.Text = b and b.Name or "..."
                    Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(45, 120, 45) or Color3.fromRGB(35, 35, 35)
                    Button.Text = name .. (Config[configKey] and " [ON]" or " [OFF]")
                end
            end
        end)
    end

    CreateToggle("ESP (RMB)", 0, "ESP_Enabled")
    CreateToggle("Enable Chams (RMB)", 30, "Chams_Enabled")
    CreateToggle("2D Screen Skeletons", 60, "Skeleton_Enabled")
    CreateToggle("Storage ESP (RMB)", 90, "Storage_Enabled")
    CreateToggle("Fullbright (RMB)", 120, "Fullbright_Enabled")
    CreateToggle("Freecam (RMB)", 150, "Freecam_Enabled")
    CreateToggle("No Fall Damage", 180, "NoFall_Enabled")
    CreateToggle("No Post-Processing", 210, "NoPostProcessing")
    CreateToggle("3rd Person (RMB)", 240, "Camera_Override")

    -- ESP PREVIEW
    local PreviewContainer = Instance.new("Frame")
    PreviewContainer.Size = UDim2.new(0, 180, 0, 240)
    PreviewContainer.Position = UDim2.new(0, 220, 0, 40)
    PreviewContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PreviewContainer.BorderSizePixel = 1
    PreviewContainer.BorderColor3 = Color3.fromRGB(40, 40, 40)
    PreviewContainer.ZIndex = 3
    PreviewContainer.Parent = MenuFrame

    local PreviewTitle = Instance.new("TextLabel")
    PreviewTitle.Size = UDim2.new(1, 0, 0, 25)
    PreviewTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PreviewTitle.Text = "ESP PREVIEW"
    PreviewTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PreviewTitle.Font = Enum.Font.Code
    PreviewTitle.ZIndex = 4
    PreviewTitle.Parent = PreviewContainer

    local Viewport = Instance.new("ViewportFrame")
    Viewport.Size = UDim2.new(1, 0, 1, -25)
    Viewport.Position = UDim2.new(0, 0, 0, 25)
    Viewport.BackgroundTransparency = 1
    Viewport.ZIndex = 4
    Viewport.Parent = PreviewContainer

    local PreviewModel = Instance.new("Model")
    PreviewModel.Name = "R6_Dummy"
    PreviewModel.Parent = Viewport

    local partsList = {}
    local function CreatePart(name, size, pos)
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Position = pos
        p.Color = Color3.fromRGB(150, 150, 150)
        p.Material = Enum.Material.SmoothPlastic
        p.Anchored = true
        p.CanCollide = false
        p.Parent = PreviewModel
        table.insert(partsList, p)
        return p
    end

    local Torso = CreatePart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0))
    PreviewModel.PrimaryPart = Torso
    CreatePart("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 1.5, 0))
    CreatePart("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0))
    CreatePart("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0))
    CreatePart("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0))
    CreatePart("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0))

    local PreviewBox = Instance.new("Frame")
    PreviewBox.Size = UDim2.new(0, 110, 0, 180)
    PreviewBox.Position = UDim2.new(0.5, -55, 0.5, -80)
    PreviewBox.BackgroundTransparency = 1
    PreviewBox.BorderSizePixel = 1
    PreviewBox.ZIndex = 10
    PreviewBox.Visible = false
    PreviewBox.Parent = PreviewContainer

    local PreviewName = Instance.new("TextLabel")
    PreviewName.Size = UDim2.new(1, 0, 0, 15)
    PreviewName.Position = UDim2.new(0, 0, 0, -18)
    PreviewName.BackgroundTransparency = 1
    PreviewName.Text = "Player_Dummy (100HP)"
    PreviewName.Font = Enum.Font.Code
    PreviewName.TextSize = 10
    PreviewName.ZIndex = 11
    PreviewName.Visible = false
    PreviewName.Parent = PreviewBox

    local PreviewHealth = Instance.new("Frame")
    PreviewHealth.Size = UDim2.new(0, 3, 1, 0)
    PreviewHealth.Position = UDim2.new(0, -6, 0, 0)
    PreviewHealth.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    PreviewHealth.BorderSizePixel = 0
    PreviewHealth.ZIndex = 11
    PreviewHealth.Visible = false
    PreviewHealth.Parent = PreviewBox

    local PreviewWeapon = Instance.new("TextLabel")
    PreviewWeapon.Size = UDim2.new(1, 0, 0, 15)
    PreviewWeapon.Position = UDim2.new(0, 0, 1, 4)
    PreviewWeapon.BackgroundTransparency = 1
    PreviewWeapon.Text = "[KNIFE]"
    PreviewWeapon.TextColor3 = Color3.fromRGB(255, 220, 100)
    PreviewWeapon.Font = Enum.Font.Code
    PreviewWeapon.TextSize = 10
    PreviewWeapon.ZIndex = 11
    PreviewWeapon.Visible = false
    PreviewWeapon.Parent = PreviewBox

    local PreviewCam = Instance.new("Camera")
    PreviewCam.CFrame = CFrame.new(Vector3.new(0, -0.2, 5.5), Torso.Position)
    Viewport.CurrentCamera = PreviewCam
    PreviewCam.Parent = Viewport

    updatePreview = function()
        local clr = ChamsConfig.EnemyColor or Color3.fromRGB(255, 0, 128)
        PreviewBox.Visible = Config.ESP_Enabled and Config.ESP_Boxes
        PreviewBox.BorderColor3 = clr
        PreviewName.Visible = Config.ESP_Enabled and Config.ShowNames
        PreviewName.TextColor3 = clr
        PreviewHealth.Visible = Config.ESP_Enabled and Config.ShowHP
        PreviewWeapon.Visible = Config.ESP_Enabled and Config.ShowWeapon
        
        local currentColor = (Config.Chams_Enabled) and clr or Color3.fromRGB(150, 150, 150)
        local currentMat = (Config.Chams_Enabled) and Enum.Material.Neon or Enum.Material.SmoothPlastic
        for _, part in ipairs(partsList) do
            part.Color = currentColor
            part.Material = currentMat
        end
    end
    _G.UpdateMenuPreviewFunc = updatePreview
    updatePreview()

    -- ИСПРАВЛЕННЫЙ FRIENDS PANEL (БЕЗВЫЛЕТНЫЙ!)
    local FriendContainer = Instance.new("Frame")
    FriendContainer.Size = UDim2.new(0, 140, 1, -45)
    FriendContainer.Position = UDim2.new(0, 410, 0, 40)
    FriendContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    FriendContainer.BorderSizePixel = 1
    FriendContainer.BorderColor3 = Color3.fromRGB(40, 40, 40)
    FriendContainer.ZIndex = 3
    FriendContainer.Parent = MenuFrame

    local FriendTitle = Instance.new("TextLabel")
    FriendTitle.Size = UDim2.new(1, 0, 0, 25)
    FriendTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    FriendTitle.Text = "FRIENDS"
    FriendTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FriendTitle.Font = Enum.Font.Code
    FriendTitle.ZIndex = 4
    FriendTitle.Parent = FriendContainer

    local PlayerScroller = Instance.new("ScrollingFrame")
    PlayerScroller.Size = UDim2.new(1, -10, 1, -35)
    PlayerScroller.Position = UDim2.new(0, 5, 0, 30)
    PlayerScroller.BackgroundTransparency = 1
    PlayerScroller.ScrollBarThickness = 4
    PlayerScroller.ZIndex = 4
    PlayerScroller.Parent = FriendContainer

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 4)
    UIList.Parent = PlayerScroller

    local function UpdateFriendMenu()
        for _, child in pairs(PlayerScroller:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        local totalHeight = 0
        
        -- Жёсткий фикс: проверяем, что массив игроков существует и не пустой!
        local currentPlayers = Players:GetPlayers()
        if currentPlayers then
            for i = 1, #currentPlayers do
                local p = currentPlayers[i]
                -- Проверяем существование самого объекта игрока и его имени (Защита от Nil!)
                if p and p ~= LocalPlayer and p.Name then
                    totalHeight = totalHeight + 24
                    local PButton = Instance.new("TextButton")
                    PButton.Size = UDim2.new(1, -5, 0, 20)
                    PButton.Font = Enum.Font.Code
                    PButton.TextSize = 10
                    PButton.ZIndex = 5
                    
                    if FriendsList[p.Name] then 
                        PButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0) 
                        PButton.Text = p.Name .. " [FR]" 
                    else 
                        PButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
                        PButton.Text = p.Name 
                    end
                    
                    PButton.TextColor3 = Color3.fromRGB(255,255,255) 
                    PButton.Parent = PlayerScroller
                    PButton.MouseButton1Click:Connect(function() 
                        if p and p.Name then
                            FriendsList[p.Name] = not FriendsList[p.Name] 
                            UpdateFriendMenu() 
                        end
                    end)
                end
            end
        end
        PlayerScroller.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    end

    UpdateFriendMenu()
    Players.PlayerAdded:Connect(UpdateFriendMenu)
    Players.PlayerRemoving:Connect(UpdateFriendMenu)
end

return UI
