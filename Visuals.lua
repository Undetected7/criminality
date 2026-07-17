local Visuals = {}
local PlayerVisuals = {}
local StorageVisuals = {}
local UIOverlayGui -- Наш новый ScreenGui контейнер для 2D элементов!

function Visuals.Init(Config, ChamsConfig, FriendsList)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    
    -- ФИКС: Создаем настоящий ScreenGui для отрисовки боксов и скелетов на экране!
    UIOverlayGui = Instance.new("ScreenGui")
    UIOverlayGui.Name = "Grimoire_Render_Bypass"
    UIOverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UIOverlayGui.Parent = CoreGui

    local function GetRealCharacter(player)
        if player.Character then return player.Character end
        for _, model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("Head") then
                local plr = Players:GetPlayerFromCharacter(model)
                if plr == player then return model end
            end
        end
        return nil
    end

    local function CreatePlayerESP(player)
        if player == LocalPlayer then return end
        
        --Billboard для имени (Остается сверху)
        local BBGui = Instance.new("BillboardGui")
        BBGui.Size = UDim2.new(0, 200, 0, 30)
        BBGui.StudsOffset = Vector3.new(0, 3.5, 0)
        BBGui.AlwaysOnTop = true
        BBGui.Enabled = false
        BBGui.Parent = UIOverlayGui

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, 0, 1, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Font = Enum.Font.Code
        NameLabel.TextColor3 = Color3.fromRGB(255,255,255)
        NameLabel.TextStrokeTransparency = 0
        NameLabel.Parent = BBGui

        --Billboard для оружия (ТЕПЕРЬ СДВИГАЕМ ВНИЗ, ПОД СИЛУЭТ!)
        local BBGuiWeapon = Instance.new("BillboardGui")
        BBGuiWeapon.Size = UDim2.new(0, 200, 0, 20)
        BBGuiWeapon.StudsOffset = Vector3.new(0, -3.5, 0) -- Отрицательное смещение = строго внизу!
        BBGuiWeapon.AlwaysOnTop = true
        BBGuiWeapon.Enabled = false
        BBGuiWeapon.Parent = UIOverlayGui

        local WeaponLabel = Instance.new("TextLabel")
        WeaponLabel.Size = UDim2.new(1, 0, 1, 0)
        WeaponLabel.BackgroundTransparency = 1
        WeaponLabel.Font = Enum.Font.Code
        WeaponLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
        WeaponLabel.TextStrokeTransparency = 0
        WeaponLabel.TextSize = 10
        WeaponLabel.Parent = BBGuiWeapon

        -- Рамка бокса (Теперь внутри ScreenGui!)
        local BoxFrame = Instance.new("Frame")
        BoxFrame.BackgroundTransparency = 1
        BoxFrame.BorderSizePixel = 1
        BoxFrame.BorderColor3 = ChamsConfig.EnemyColor
        BoxFrame.Visible = false
        BoxFrame.Parent = UIOverlayGui

        -- HP Bar (Внутри ScreenGui!)
        local HPBar = Instance.new("Frame")
        HPBar.BorderSizePixel = 0
        HPBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        HPBar.Visible = false
        HPBar.Parent = UIOverlayGui

        -- Круг головы скелета
        local HeadCircle = Instance.new("Frame")
        HeadCircle.Size = UDim2.new(0, 12, 0, 12)
        HeadCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        HeadCircle.BackgroundColor3 = ChamsConfig.EnemyColor
        HeadCircle.BorderSizePixel = 0
        HeadCircle.Visible = false
        HeadCircle.Parent = UIOverlayGui
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = HeadCircle

        local bonePairs = {
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
        }
        
        local Lines = {}
        for i = 1, #bonePairs do
            local LFrame = Instance.new("Frame")
            LFrame.BorderSizePixel = 0
            LFrame.BackgroundColor3 = ChamsConfig.EnemyColor
            LFrame.Visible = false
            LFrame.AnchorPoint = Vector2.new(0.5, 0)
            LFrame.Parent = UIOverlayGui
            table.insert(Lines, {Frame = LFrame, PartA = bonePairs[i][1], PartB = bonePairs[i][2]})
        end

        local NeckLine = Instance.new("Frame")
        NeckLine.BorderSizePixel = 0
        NeckLine.BackgroundColor3 = ChamsConfig.EnemyColor
        NeckLine.Visible = false
        NeckLine.AnchorPoint = Vector2.new(0.5, 0)
        NeckLine.Parent = UIOverlayGui

        local Highlight = Instance.new("Highlight")
        Highlight.Enabled = false

        PlayerVisuals[player] = {
            BBGui = BBGui, 
            BBGuiWeapon = BBGuiWeapon,
            Name = NameLabel, 
            Weapon = WeaponLabel, 
            Box = BoxFrame, 
            HP = HPBar, 
            Chams = Highlight, 
            HeadCircle = HeadCircle,
            NeckLine = NeckLine,
            Lines = Lines,
            GetChar = function() return GetRealCharacter(player) end
        }
    end

    Players.PlayerAdded:Connect(CreatePlayerESP)
    for _, p in pairs(Players:GetPlayers()) do CreatePlayerESP(p) end

    -- Safe Scanner
    local function DeepDistributedStorageScan()
        if not Config.Storage_Enabled or not Config.ESP_Enabled then 
            for obj, objs in pairs(StorageVisuals) do pcall(function() objs.BB:Destroy() objs.High:Destroy() end) StorageVisuals[obj] = nil end
            return 
        end

        local currentScan = {}
        local instances = workspace:GetDescendants()
        
        for i = 1, #instances do
            local obj = instances[i]
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local name = string.lower(obj.Name)
                local pName = obj.Parent and string.lower(obj.Parent.Name) or ""
                
                local isSafe = name:find("safe") or pName:find("safe")
                local isRegister = name:find("register") or pName:find("register") or name:find("till") or pName:find("till")
                local isLoot = name:find("trash") or pName:find("trash") or name:find("pile") or pName:find("pile")
                
                if (isSafe or isRegister or isLoot) and not name:find("atm") and not pName:find("atm") and not name:find("zone") then
                    local isOpen = false
                    if obj.Parent:FindFirstChild("Open") or obj:FindFirstChild("Open") or pName:find("broken") or name:find("broken") then isOpen = true end
                    
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and not prompt.Enabled then isOpen = true end
                    
                    local allowed = (isSafe and Config.Storage_Safes) or (isRegister and Config.Storage_Registers) or (isLoot and Config.Storage_Loot)
                    
                    if allowed and not isOpen then
                        currentScan[obj] = true
                        if not StorageVisuals[obj] then
                            local BB = Instance.new("BillboardGui")
                            BB.Size = UDim2.new(0, 130, 0, 20)
                            BB.AlwaysOnTop = true
                            BB.Enabled = true
                            BB.Parent = UIOverlayGui
                            
                            local Txt = Instance.new("TextLabel")
                            Txt.Size = UDim2.new(1, 0, 1, 0)
                            Txt.BackgroundTransparency = 1
                            Txt.TextColor3 = ChamsConfig.StorageColor
                            Txt.TextStrokeTransparency = 0
                            Txt.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                            Txt.Font = Enum.Font.Code
                            Txt.TextSize = 11
                            
                            if isSafe then Txt.Text = "🔒 [SAFE]"
                            elseif isRegister then Txt.Text = "💰 [CASH REGISTER]"
                            else Txt.Text = "📦 [LOOT PILE]" end
                            Txt.Parent = BB
                            
                            local High = Instance.new("Highlight")
                            High.FillColor = ChamsConfig.StorageColor
                            High.OutlineColor = ChamsConfig.OutlineColor
                            High.FillTransparency = ChamsConfig.FillTransparency
                            High.Enabled = true
                            High.Parent = obj
                            
                            StorageVisuals[obj] = {BB = BB, High = High, Part = obj}
                        end
                    end
                end
            end
            if i % 120 == 0 then task.wait() end
        end

        for obj, objs in pairs(StorageVisuals) do
            if not currentScan[obj] then pcall(function() objs.BB:Destroy() objs.High:Destroy() end) StorageVisuals[obj] = nil end
        end
    end

    task.spawn(function()
        while true do pcall(DeepDistributedStorageScan) task.wait(3.5) end
    end)
end

function Visuals.Update(Config, ChamsConfig, FriendsList)
    local Lighting = game:GetService("Lighting")
    local GuiService = game:GetService("GuiService")
    local Camera = workspace.CurrentCamera
    local inset = GuiService:GetGuiInset()

    for player, objs in pairs(PlayerVisuals) do
        local pChar = objs.GetChar()
        local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
        local pHead = pChar and pChar:FindFirstChild("Head")
        local hrp = pChar and (pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Torso"))

        if Config.ESP_Enabled and pHead and pHum and pHum.Health > 0 and hrp then
            local isFriend = FriendsList[player.Name]
            local targetColor = isFriend and ChamsConfig.FriendColor or ChamsConfig.EnemyColor
            
            local currentWeapon = "[Unarmed]"
            if pChar then
                local tool = pChar:FindFirstChildOfClass("Tool")
                if tool then currentWeapon = "[" .. tool.Name .. "]"
                else
                    local rArm = pChar:FindFirstChild("RightHand") or pChar:FindFirstChild("Right Upper Arm")
                    local handle = rArm and rArm:FindFirstChildOfClass("Accessory") or pChar:FindFirstChildOfClass("Accessory")
                    if handle then currentWeapon = "[" .. handle.Name .. "]" end
                end
            end

            if objs.BBGui.Adornee ~= pHead then objs.BBGui.Adornee = pHead end
            if objs.BBGuiWeapon.Adornee ~= hrp then objs.BBGuiWeapon.Adornee = hrp end
            
            objs.BBGui.Enabled = Config.ShowNames
            objs.BBGuiWeapon.Enabled = Config.ShowWeapon
            
            if Config.ShowNames then
                objs.Name.Text = player.Name .. " (" .. math.floor(pHum.Health) .. "HP)"
                objs.Name.TextColor3 = targetColor
            end

            if Config.ShowWeapon then
                objs.Weapon.Text = currentWeapon
            end

            -- Отрисовка 2D Боксов ПОВЕРХ ScreenGui
            local headPos, headOnScreen = Camera:WorldToViewportPoint(pHead.Position + Vector3.new(0, 1.2, 0))
            local legPos, legOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))

            if headOnScreen and legOnScreen and Config.ESP_Boxes then
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 1.4

                objs.Box.Size = UDim2.new(0, width, 0, height)
                objs.Box.Position = UDim2.new(0, headPos.X - width/2, 0, (headPos.Y - inset.Y))
                objs.Box.BorderColor3 = targetColor
                objs.Box.Visible = true

                if Config.ShowHP then
                    local pct = math.clamp(pHum.Health / pHum.MaxHealth, 0, 1)
                    local hpHeight = height * pct
                    objs.HP.Size = UDim2.new(0, 3, 0, hpHeight)
                    objs.HP.Position = UDim2.new(0, (headPos.X - width/2) - 6, 0, (headPos.Y - inset.Y) + (height - hpHeight))
                    objs.HP.BackgroundColor3 = Color3.fromHSV(pct * 0.3, 1, 1)
                    objs.HP.Visible = true
                else objs.HP.Visible = false end
            else
                objs.Box.Visible = false
                objs.HP.Visible = false
            end

            -- Chams
            if Config.Chams_Enabled then
                if not objs.Chams.Parent then objs.Chams.Parent = pChar end
                objs.Chams.FillColor = targetColor objs.Chams.Enabled = true
            else objs.Chams.Enabled = false end

            -- Отрисовка Скелетов ПОВЕРХ ScreenGui
            if Config.Skeleton_Enabled then
                local sHeadPos, headScreen = Camera:WorldToViewportPoint(pHead.Position)
                if headScreen then
                    objs.HeadCircle.Position = UDim2.new(0, sHeadPos.X, 0, sHeadPos.Y - inset.Y)
                    objs.HeadCircle.BackgroundColor3 = targetColor
                    objs.HeadCircle.Visible = true
                else objs.HeadCircle.Visible = false end

                local torsoPart = pChar:FindFirstChild("UpperTorso") or pChar:FindFirstChild("Torso")
                if torsoPart and headScreen then
                    local sTorsoPos, torsoScreen = Camera:WorldToViewportPoint(torsoPart.Position)
                    if torsoScreen then
                        local startV = Vector2.new(sHeadPos.X, sHeadPos.Y - inset.Y)
                        local endV = Vector2.new(sTorsoPos.X, sTorsoPos.Y - inset.Y)
                        local dist = (startV - endV).Magnitude
                        local angle = math.deg(math.atan2(endV.Y - startV.Y, endV.X - startV.X))

                        objs.NeckLine.Size = UDim2.new(0, 2, 0, dist)
                        objs.NeckLine.Position = UDim2.new(0, startV.X, 0, startV.Y)
                        objs.NeckLine.Rotation = angle - 90
                        objs.NeckLine.BackgroundColor3 = targetColor
                        objs.NeckLine.Visible = true
                    else objs.NeckLine.Visible = false end
                else objs.NeckLine.Visible = false end

                for l = 1, #objs.Lines do
                    local line = objs.Lines[l]
                    local partA = pChar:FindFirstChild(line.PartA)
                    local partB = pChar:FindFirstChild(line.PartB)
                    
                    if partA and partB then
                        local screenPosA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                        local screenPosB, onScreenB = Camera:WorldToViewportPoint(partB.Position)
                        
                        if onScreenA and onScreenB then
                            local startV = Vector2.new(screenPosA.X, screenPosA.Y - inset.Y)
                            local endV = Vector2.new(screenPosB.X, screenPosB.Y - inset.Y)
                            local dist = (startV - endV).Magnitude
                            local angle = math.deg(math.atan2(endV.Y - startV.Y, endV.X - startV.X))
                            
                            line.Frame.Size = UDim2.new(0, 2, 0, dist)
                            line.Frame.Position = UDim2.new(0, startV.X, 0, startV.Y)
                            line.Frame.Rotation = angle - 90
                            line.Frame.BackgroundColor3 = targetColor
                            line.Frame.Visible = true
                        else line.Frame.Visible = false end
                    else line.Frame.Visible = false end
                end
            else
                objs.HeadCircle.Visible = false
                objs.NeckLine.Visible = false
                for l = 1, #objs.Lines do objs.Lines[l].Frame.Visible = false end
            end
        else
            objs.BBGui.Enabled = false objs.BBGuiWeapon.Enabled = false
            objs.Chams.Enabled = false objs.Box.Visible = false objs.HP.Visible = false
            objs.HeadCircle.Visible = false objs.NeckLine.Visible = false
            for l = 1, #objs.Lines do objs.Lines[l].Frame.Visible = false end
        end
    end

    if Config.Storage_Enabled and Config.ESP_Enabled then
        for obj, objs in pairs(StorageVisuals) do
            if obj and obj.Parent and objs.Part and objs.Part.Parent then
                if objs.BB.Adornee ~= objs.Part then objs.BB.Adornee = objs.Part end
                objs.BB.Enabled = true objs.High.Enabled = Config.Chams_Enabled
            else pcall(function() objs.BB:Destroy() objs.High:Destroy() end) StorageVisuals[obj] = nil end
        end
    end
end

return Visuals
