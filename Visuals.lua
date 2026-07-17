local Visuals = {}
local PlayerVisuals = {}
local StorageVisuals = {}
local UILinesFolder

function Visuals.Init(Config, ChamsConfig, FriendsList)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local sg = LocalPlayer:WaitForChild("PlayerGui")
    
    UILinesFolder = Instance.new("Folder")
    UILinesFolder.Name = "Grimoire_Skeletons"
    UILinesFolder.Parent = sg:FindFirstChild("Grimoire_Godmode_v15") or sg

    local function CreatePlayerESP(player)
        if player == LocalPlayer then return end
        
        local BBGui = Instance.new("BillboardGui")
        BBGui.Size = UDim2.new(0, 200, 0, 50)
        BBGui.StudsOffset = Vector3.new(0, 3.5, 0)
        BBGui.AlwaysOnTop = true
        BBGui.Enabled = false
        BBGui.Parent = UILinesFolder.Parent

        local Container = Instance.new("Frame")
        Container.BackgroundTransparency = 1
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.Parent = BBGui

        local NameLabel = Instance.new("TextLabel")
        NameLabel.BackgroundTransparency = 1
        NameLabel.Size = UDim2.new(1, 0, 0, 20)
        NameLabel.Font = Enum.Font.Code
        NameLabel.TextColor3 = Color3.fromRGB(255,255,255)
        NameLabel.TextStrokeTransparency = 0
        NameLabel.Parent = Container

        local HealthOutline = Instance.new("Frame")
        HealthOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        HealthOutline.Size = UDim2.new(0, 60, 0, 6)
        HealthOutline.Position = UDim2.new(0.5, -30, 0, 22)
        HealthOutline.Parent = Container

        local HealthBar = Instance.new("Frame")
        HealthBar.BorderSizePixel = 0
        HealthBar.Size = UDim2.new(1, 0, 1, 0)
        HealthBar.Parent = HealthOutline

        local Highlight = Instance.new("Highlight")
        Highlight.Enabled = false

        local Lines = {}
        local bonePairs = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
        }
        for i = 1, #bonePairs do
            local LFrame = Instance.new("Frame")
            LFrame.BorderSizePixel = 0
            LFrame.BackgroundColor3 = ChamsConfig.EnemyColor
            LFrame.Visible = false
            LFrame.AnchorPoint = Vector2.new(0.5, 0)
            LFrame.Parent = UILinesFolder
            table.insert(Lines, {Frame = LFrame, PartA = bonePairs[i][1], PartB = bonePairs[i][2]})
        end

        PlayerVisuals[player] = {BBGui = BBGui, Name = NameLabel, Health = HealthBar, Chams = Highlight, Lines = Lines}
    end

    Players.PlayerAdded:Connect(CreatePlayerESP)
    for _, p in pairs(Players:GetPlayers()) do CreatePlayerESP(p) end

    -- Поток сканера ящиков
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
                    if obj.Parent:FindFirstChild("Open") or obj:FindFirstChild("Open") or pName:find("broken") or name:find("broken") then
                        isOpen = true
                    end
                    
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                    if prompt and not prompt.Enabled then
                        isOpen = true
                    end
                    
                    local allowed = (isSafe and Config.Storage_Safes) or (isRegister and Config.Storage_Registers) or (isLoot and Config.Storage_Loot)
                    
                    if allowed and not isOpen then
                        currentScan[obj] = true
                        if not StorageVisuals[obj] then
                            local BB = Instance.new("BillboardGui")
                            BB.Size = UDim2.new(0, 130, 0, 20)
                            BB.AlwaysOnTop = true
                            BB.Enabled = true
                            BB.Parent = UILinesFolder.Parent
                            
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
    local Camera = workspace.CurrentCamera
    
    if not _G.OriginalAmbient then _G.OriginalAmbient = Lighting.Ambient end
    if not _G.OriginalOutdoorAmbient then _G.OriginalOutdoorAmbient = Lighting.OutdoorAmbient end

    -- Настройка Fullbright
    if Config.Fullbright_Enabled then
        local g = Config.Fullbright_Gamma
        Lighting.Ambient = Color3.fromRGB(g, g, g)
        Lighting.OutdoorAmbient = Color3.fromRGB(g, g, g)
    else
        Lighting.Ambient = _G.OriginalAmbient
        Lighting.OutdoorAmbient = _G.OriginalOutdoorAmbient
    end

    -- Обновление игроков
    for player, objs in pairs(PlayerVisuals) do
        local pChar = player.Character
        local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
        local pHead = pChar and pChar:FindFirstChild("Head")

        if Config.ESP_Enabled and pHead and pHum and pHum.Health > 0 then
            local isFriend = FriendsList[player.Name]
            local targetColor = isFriend and ChamsConfig.FriendColor or ChamsConfig.EnemyColor
            
            if objs.BBGui.Adornee ~= pHead then objs.BBGui.Adornee = pHead end
            objs.BBGui.Enabled = Config.ShowNames
            if Config.ShowNames then
                objs.Name.Text = player.Name .. " (" .. math.floor(pHum.Health) .. "HP)"
                objs.Name.TextColor3 = targetColor
                local pct = math.clamp(pHum.Health / pHum.MaxHealth, 0, 1)
                objs.Health.Size = UDim2.new(pct, 0, 1, 0)
                objs.Health.BackgroundColor3 = isFriend and ChamsConfig.FriendColor or Color3.fromHSV(pct * 0.3, 1, 1)
            end

            if Config.Chams_Enabled then
                if not objs.Chams.Parent then objs.Chams.Parent = pChar end
                objs.Chams.FillColor = targetColor objs.Chams.Enabled = true
            else objs.Chams.Enabled = false end

            -- Скелеты
            if Config.Skeleton_Enabled then
                for l = 1, #objs.Lines do
                    local line = objs.Lines[l]
                    local partA = pChar:FindFirstChild(line.PartA)
                    local partB = pChar:FindFirstChild(line.PartB)
                    
                    if partA and partB then
                        local screenPosA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                        local screenPosB, onScreenB = Camera:WorldToViewportPoint(partB.Position)
                        
                        if onScreenA and onScreenB then
                            local startV = Vector2.new(screenPosA.X, screenPosA.Y)
                            local endV = Vector2.new(screenPosB.X, screenPosB.Y)
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
                for l = 1, #objs.Lines do objs.Lines[l].Frame.Visible = false end
            end
        else
            objs.BBGui.Enabled = false objs.Chams.Enabled = false
            for l = 1, #objs.Lines do objs.Lines[l].Frame.Visible = false end
        end
    end

    -- Обновление ящиков
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
