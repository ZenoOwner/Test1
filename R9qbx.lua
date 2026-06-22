pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local ProximityPromptService = game:GetService("ProximityPromptService")
    local CoreGui = game:GetService("CoreGui")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local TweenService = game:GetService("TweenService")
    local TeleportService = game:GetService("TeleportService")
    local LP = Players.LocalPlayer

    pcall(function()
        for _, name in ipairs({"FlashTPUI", "FlashTPUtils", "InternalAntiRagdoll", "ModernDashboard", "UCT_Hub", "IceHub_Protector", "HiddenUI", "FryGui"}) do
            local old = CoreGui:FindFirstChild(name)
            if old then old:Destroy() end
        end
    end)

    -- ========== INFINITE JUMP - ALWAYS ON ==========
    local infJumpEnabled = true
    local IJ_Conn = nil

    local function startInfJump()
        if IJ_Conn then IJ_Conn:Disconnect() end
        IJ_Conn = RunService.Heartbeat:Connect(function()
            if not infJumpEnabled then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end
            if root.Velocity.Y < -120 then
                root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z)
            end
            if hum.FloorMaterial == Enum.Material.Air then return end
            if not (UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.ButtonA)) then return end
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall then return end
            root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
        end)
        UIS.JumpRequest:Connect(function()
            if not infJumpEnabled then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z) end
        end)
    end
    startInfJump()

    -- ========== THIEF DETECTION (from Phantom Flash) ==========
    local myPlotRef = nil
    local stealHitbox = nil

    task.spawn(function()
        while true do
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, p in ipairs(plots:GetChildren()) do
                    local sign = p:FindFirstChild("PlotSign")
                    if sign then
                        local tl = sign:FindFirstChild("TextLabel", true)
                        if tl then
                            local t = tl.Text:lower()
                            if t:find(LP.Name:lower(), 1, true) or t:find(LP.DisplayName:lower(), 1, true) then
                                myPlotRef = p
                                stealHitbox = p:FindFirstChild("StealHitbox", true)
                                break
                            end
                        end
                    end
                end
            end
            task.wait(0.9)
        end
    end)

    local function findThief()
        local searchPos = stealHitbox and stealHitbox.Position
        if not searchPos then
            local char = LP.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then searchPos = hrp.Position end
            end
        end
        if not searchPos then return nil end
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local char = p.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - searchPos).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = p
                        end
                    end
                end
            end
        end
        return best
    end

    -- ========== SPAM SYSTEM ==========
    local commandCache = {}
    local profileCache = {}
    local spamCooldown = 0
    local SPAM_CMDS = {"tiny", "inverse", "rocket", "morph", "jumpscare"}

    local function getAdminPanel()
        local ap = LP.PlayerGui:FindFirstChild("AdminPanel")
        if not ap then return nil, nil end
        local inner = ap:FindFirstChild("AdminPanel")
        if not inner then return nil, nil end
        local content = inner:FindFirstChild("Content")
        local profiles = inner:FindFirstChild("Profiles")
        if not content or not profiles then return nil, nil end
        return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
    end

    local function getActivatedFunctions(button)
        if not button then return {} end
        local funcs = {}
        local ok, conns = pcall(getconnections, button.Activated)
        if ok and type(conns) == "table" then
            for _, conn in ipairs(conns) do
                if type(conn.Function) == "function" then
                    table.insert(funcs, conn.Function)
                end
            end
        end
        return funcs
    end

    local function fireActivated(funcs)
        for _, fn in ipairs(funcs) do
            task.spawn(fn)
        end
    end

    local function buildCache(targetPlayer)
        local commandFrame, profileFrame = getAdminPanel()
        if not commandFrame or not profileFrame then return false end
        for _, cmd in ipairs(SPAM_CMDS) do
            if not commandCache[cmd] then
                local btn = commandFrame:FindFirstChild(cmd)
                if btn then
                    commandCache[cmd] = getActivatedFunctions(btn)
                end
            end
        end
        if not profileCache[targetPlayer.Name] then
            local profileBtn = profileFrame:FindFirstChild(targetPlayer.Name)
            if profileBtn then
                profileCache[targetPlayer.Name] = getActivatedFunctions(profileBtn)
            end
        end
        return true
    end

    local function executeSpam(targetPlayer)
        if not targetPlayer then return false end
        if not profileCache[targetPlayer.Name] then
            if not buildCache(targetPlayer) then return false end
        end
        local profileFuncs = profileCache[targetPlayer.Name]
        if not profileFuncs or #profileFuncs == 0 then return false end
        for _, cmd in ipairs(SPAM_CMDS) do
            local cmdFuncs = commandCache[cmd]
            if cmdFuncs and #cmdFuncs > 0 then
                fireActivated(cmdFuncs)
                fireActivated(profileFuncs)
            end
        end
        return true
    end

    local function findNearestPlayer()
        local char = LP.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local pchar = p.Character
                if pchar then
                    local phrp = pchar:FindFirstChild("HumanoidRootPart")
                    if phrp then
                        local dist = (phrp.Position - hrp.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = p
                        end
                    end
                end
            end
        end
        return best
    end

    local function spamClosest()
        local now = tick()
        if now - spamCooldown < 0.5 then return end
        spamCooldown = now
        local target = findNearestPlayer()
        if not target then return end
        if next(commandCache) == nil then
            buildCache(target)
        end
        executeSpam(target)
    end
    _G.spamNearest = spamClosest

    -- ========== DEFENSE SYSTEM (balloon first, ragdoll after 30s) ==========
    local defenseCommandCache = {}
    local defenseProfileCache = {}
    local AutoDefenseEnabled = false
    local lastBalloonTime = 0
    local BALLOON_COOLDOWN = 30
    local lastDefenseExecute = 0

    local function getDefenseAdminPanel()
        local ap = LP.PlayerGui:FindFirstChild("AdminPanel")
        if not ap then return nil, nil end
        local inner = ap:FindFirstChild("AdminPanel")
        if not inner then return nil, nil end
        local content = inner:FindFirstChild("Content")
        local profiles = inner:FindFirstChild("Profiles")
        if not content or not profiles then return nil, nil end
        return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
    end

    local function buildDefenseCache(targetPlayer)
        local commandFrame, profileFrame = getDefenseAdminPanel()
        if not commandFrame or not profileFrame then return false end
        local profileButton = profileFrame:FindFirstChild(targetPlayer.Name)
        if not profileButton then return false end
        if not defenseProfileCache[targetPlayer.Name] then
            defenseProfileCache[targetPlayer.Name] = getActivatedFunctions(profileButton)
        end
        if not defenseCommandCache["balloon"] then
            local btn = commandFrame:FindFirstChild("balloon")
            if btn then
                defenseCommandCache["balloon"] = getActivatedFunctions(btn)
            end
        end
        if not defenseCommandCache["ragdoll"] then
            local btn = commandFrame:FindFirstChild("ragdoll")
            if btn then
                defenseCommandCache["ragdoll"] = getActivatedFunctions(btn)
            end
        end
        return true
    end

    local function executeDefense(targetPlayer)
        if not targetPlayer then return false end
        if not defenseProfileCache[targetPlayer.Name] then
            if not buildDefenseCache(targetPlayer) then return false end
        end
        local profileFuncs = defenseProfileCache[targetPlayer.Name]
        if not profileFuncs or #profileFuncs == 0 then return false end

        local now = tick()
        local cmdUsed = false

        if now - lastBalloonTime >= BALLOON_COOLDOWN then
            local balloonFuncs = defenseCommandCache["balloon"]
            if balloonFuncs and #balloonFuncs > 0 then
                fireActivated(balloonFuncs)
                fireActivated(profileFuncs)
                lastBalloonTime = now
                cmdUsed = true
            end
        end

        if not cmdUsed then
            local ragdollFuncs = defenseCommandCache["ragdoll"]
            if ragdollFuncs and #ragdollFuncs > 0 then
                fireActivated(ragdollFuncs)
                fireActivated(profileFuncs)
                cmdUsed = true
            end
        end

        return cmdUsed
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            obj.OnClientEvent:Connect(function(...)
                if not AutoDefenseEnabled then return end
                for _, arg in ipairs({...}) do
                    if type(arg) == "string" and string.find(string.lower(arg), "stealing") then
                        if (tick() - lastDefenseExecute) > 0.5 then
                            local thief = findThief()
                            if thief then
                                executeDefense(thief)
                                lastDefenseExecute = tick()
                            end
                        end
                        break
                    end
                end
            end)
        end
    end

    local function toggleAutoDefense()
        AutoDefenseEnabled = not AutoDefenseEnabled
        return AutoDefenseEnabled
    end
    _G.toggleAutoDefense = toggleAutoDefense

    -- ========== SELF-RAGDOLL FUNCTION (via AdminPanel) ==========
    local function selfRagdoll()
        pcall(function()
            local commandFrame, _ = getAdminPanel()
            if not commandFrame then return end
            local ragdollBtn = commandFrame:FindFirstChild("ragdoll")
            if ragdollBtn then
                local funcs = getActivatedFunctions(ragdollBtn)
                if funcs and #funcs > 0 then
                    fireActivated(funcs)
                    -- Also need profile button for self
                    local _, profileFrame = getAdminPanel()
                    if profileFrame then
                        local selfBtn = profileFrame:FindFirstChild(LP.Name)
                        if selfBtn then
                            local selfFuncs = getActivatedFunctions(selfBtn)
                            if selfFuncs and #selfFuncs > 0 then
                                fireActivated(selfFuncs)
                            end
                        end
                    end
                end
            end
        end)
    end

    -- ========== POTION SYSTEM ==========
    local flashEnabled = true
    local sliderValue = 0.9
    local activeTriggers = {}

    local function activatePotion()
        local char = LP.Character
        if not char then return end
        local bp = LP:FindFirstChild("Backpack")
        local potion = bp and bp:FindFirstChild("Giant Potion") or char:FindFirstChild("Giant Potion")
        if potion then
            potion.Parent = char
            pcall(function() potion:Activate() end)
            task.wait(0.05)
            if potion and potion.Parent == char then potion.Parent = bp end
            -- INSTANT SELF-RAGDOLL after potion activates
            task.spawn(selfRagdoll)
        end
    end

    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if activeTriggers[prompt] then return end
        if prompt.ActionText ~= "Steal" then return end
        activeTriggers[prompt] = true
        local start = os.clock()
        local fired = false
        local conn

        conn = RunService.PreRender:Connect(function()
            if not prompt or not prompt.Parent then
                conn:Disconnect()
                activeTriggers[prompt] = nil
                return
            end
            local progress = math.clamp((os.clock() - start) / prompt.HoldDuration, 0, 1)
            if not fired and progress >= sliderValue then
                fired = true
                conn:Disconnect()
                activeTriggers[prompt] = nil
                if flashEnabled then
                    local char = LP.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
                activatePotion()
            end
        end)

        prompt.PromptButtonHoldEnded:Connect(function()
            if not fired then conn:Disconnect(); activeTriggers[prompt] = nil end
        end)
    end)

    -- ========== SPEED SYSTEM (explicitly 31) ==========
    pcall(function()
        local speedConn = nil
        local SPEED = 31  -- explicitly set to 31

        local function startSpeed()
            if speedConn then speedConn:Disconnect() end
            speedConn = RunService.Heartbeat:Connect(function()
                local char = LP.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
                    hrp.Velocity = Vector3.new(flatDir.X * SPEED, hrp.Velocity.Y, flatDir.Z * SPEED)
                end
            end)
        end
        startSpeed()
    end)

    -- ========== ANTI-RAGDOLL ==========
    pcall(function()
        local antiRagConn = nil
        local function startAntiRagdoll()
            if antiRagConn then return end
            antiRagConn = RunService.Heartbeat:Connect(function()
                local char = LP.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if not (hum and root) then return end
                local s = hum:GetState()
                local ragdolled = (s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown)
                local endTime = LP:GetAttribute("RagdollEndTime")
                if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then ragdolled = true end
                if ragdolled then
                    pcall(function() LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
                    for _, d in ipairs(char:GetDescendants()) do
                        if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
                            d:Destroy()
                        end
                    end
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
                    end
                    if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
                    workspace.CurrentCamera.CameraSubject = hum
                    root.Anchored = false
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end)
        end
        startAntiRagdoll()
    end)

    -- ========== ANTI-BEE ==========
    pcall(function()
        local NORMAL_FOV = 70
        local function clearBeeEffects()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("bee") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then hum.Health = 0 end
                end
            end
            local blacklist = {"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","Atmosphere","PostEffect"}
            for _, v in pairs(Lighting:GetDescendants()) do
                for _, n in ipairs(blacklist) do
                    if v:IsA(n) then pcall(function() v:Destroy() end) end
                end
            end
            if workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView ~= NORMAL_FOV then
                workspace.CurrentCamera.FieldOfView = NORMAL_FOV
            end
        end
        clearBeeEffects()
        Lighting.DescendantAdded:Connect(function(obj)
            task.wait()
            local blacklist = {"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","Atmosphere","PostEffect"}
            for _, n in ipairs(blacklist) do
                if obj:IsA(n) then pcall(function() obj:Destroy() end) end
            end
        end)
        task.spawn(function()
            while true do
                clearBeeEffects()
                task.wait(1)
            end
        end)
        RunService.RenderStepped:Connect(function()
            if workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView ~= NORMAL_FOV then
                workspace.CurrentCamera.FieldOfView = NORMAL_FOV
            end
        end)
    end)

    -- ========== SENTRY SYSTEM ==========
    pcall(function()
        local DETECTION_DISTANCE = 200
        local PULL_DISTANCE = -5
        local sentryFirstSeen = {}
        local sentryTarget = nil

        local function getSentryWeapon()
            local char = LP.Character
            if not char then return nil end
            return (LP.Backpack and LP.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat")
        end

        local function findSentryTarget()
            local char = LP.Character
            if not char then return nil end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end
            local rootPos = hrp.Position
            local now = tick()
            for obj in pairs(sentryFirstSeen) do if not obj.Parent then sentryFirstSeen[obj] = nil end end
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
                    local ownerId = obj.Name:match("Sentry_(%d+)")
                    if ownerId and tonumber(ownerId) == LP.UserId then continue end
                    local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part and (rootPos - part.Position).Magnitude <= DETECTION_DISTANCE then
                        if not sentryFirstSeen[obj] then sentryFirstSeen[obj] = now end
                        if now - sentryFirstSeen[obj] >= 3 then return obj end
                    end
                end
            end
            return nil
        end

        local function moveSentry(obj)
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, part in pairs(obj:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
            local cf = hrp.CFrame * CFrame.new(0, 0, PULL_DISTANCE)
            if obj:IsA("BasePart") then obj.CFrame = cf
            elseif obj:IsA("Model") then
                local main = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if main then main.CFrame = cf end
            end
        end

        local function attackSentry()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local weapon = getSentryWeapon()
            if not weapon then return end
            if weapon.Parent == LP.Backpack then hum:EquipTool(weapon); task.wait(0.1) end
            local handle = weapon:FindFirstChild("Handle")
            if handle then handle.CanCollide = false end
            pcall(function() weapon:Activate() end)
            for _, r in pairs(weapon:GetDescendants()) do if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end end
        end

        RunService.Heartbeat:Connect(function()
            if sentryTarget and sentryTarget.Parent == Workspace then
                moveSentry(sentryTarget)
                attackSentry()
            else
                sentryTarget = findSentryTarget()
            end
        end)

        task.spawn(function()
            task.wait(1)
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
                    local ownerId = obj.Name:match("Sentry_(%d+)")
                    if not (ownerId and tonumber(ownerId) == LP.UserId) then
                        sentryFirstSeen[obj] = tick() - 3
                    end
                end
            end
        end)
    end)

    -- ========== PLAYER ESP ==========
    pcall(function()
        local espData = {}
        local function createESP(player)
            if player == LP then return end
            if espData[player] then
                for _, obj in ipairs(espData[player]) do if obj and obj.Parent then obj:Destroy() end end
                espData[player] = nil
            end
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local objects = {}
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 100)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = char
            table.insert(objects, highlight)
            local head = char:FindFirstChild("Head") or hrp
            local billboard = Instance.new("BillboardGui")
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 140, 0, 25)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = head
            local frame = Instance.new("Frame", billboard)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = Color3.fromRGB(255, 80, 80)
            label.TextSize = 12
            label.Text = player.DisplayName
            label.TextScaled = true
            table.insert(objects, billboard)
            espData[player] = objects
        end
        local function removeESP(player)
            if espData[player] then
                for _, obj in ipairs(espData[player]) do if obj and obj.Parent then obj:Destroy() end end
                espData[player] = nil
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function() task.wait(0.5); createESP(player) end)
            createESP(player)
        end)
        Players.PlayerRemoving:Connect(removeESP)
        LP.CharacterAdded:Connect(function()
            task.wait(1)
            for _, player in ipairs(Players:GetPlayers()) do if player ~= LP then createESP(player) end end
        end)
    end)

    -- ========== BASE TIMER ESP ==========
    pcall(function()
        local baseTimerInstances = {}
        local function createBaseESP(plot, mainPart)
            if baseTimerInstances[plot] then
                baseTimerInstances[plot]:Destroy()
                baseTimerInstances[plot] = nil
            end
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "BaseTimerESP"
            billboard.Size = UDim2.new(0, 60, 0, 25)
            billboard.StudsOffset = Vector3.new(0, 5, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = mainPart
            billboard.MaxDistance = 1000
            billboard.Parent = plot
            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextSize = 17
            label.Font = Enum.Font.GothamBlack
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            baseTimerInstances[plot] = billboard
            return billboard
        end
        task.spawn(function()
            while true do
                local plots = workspace:FindFirstChild("Plots")
                if plots then
                    for _, plot in ipairs(plots:GetChildren()) do
                        local purchases = plot:FindFirstChild("Purchases")
                        local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
                        local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
                        local timeLabel = mainPart and mainPart:FindFirstChild("BillboardGui") and mainPart.BillboardGui:FindFirstChild("RemainingTime")
                        if timeLabel and mainPart then
                            local bb = baseTimerInstances[plot] or createBaseESP(plot, mainPart)
                            local lbl = bb and bb:FindFirstChildWhichIsA("TextLabel")
                            if lbl then lbl.Text = timeLabel.Text end
                        else
                            if baseTimerInstances[plot] then
                                baseTimerInstances[plot]:Destroy()
                                baseTimerInstances[plot] = nil
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end)

    -- ========== MAIN GUI ==========
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "FlashTPUI"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Position = UDim2.new(0.5, -100, 0.45, -25)
    mainFrame.Size = UDim2.new(0, 200, 0, 75)
    mainFrame.Active = true
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    local glowStroke = Instance.new("UIStroke")
    glowStroke.Color = Color3.fromRGB(255, 255, 255)
    glowStroke.Thickness = 1.5
    glowStroke.Transparency = 0.2
    glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glowStroke.Parent = mainFrame

    local glowGradient = Instance.new("UIGradient")
    glowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    glowGradient.Parent = glowStroke

    task.spawn(function()
        while glowGradient and glowGradient.Parent do
            glowGradient.Rotation = (glowGradient.Rotation + 0.6) % 360
            task.wait(0.016)
        end
    end)

    pcall(function()
        local dragging, dragStart, startPos
        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end)

    local titleLb = Instance.new("TextLabel")
    titleLb.Size = UDim2.new(0.35, 0, 0, 18)
    titleLb.Position = UDim2.new(0.32, 0, 0, 1)
    titleLb.BackgroundTransparency = 1
    titleLb.Text = "Flash TP"
    titleLb.TextSize = 13
    titleLb.Font = Enum.Font.GothamBlack
    titleLb.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLb.TextXAlignment = Enum.TextXAlignment.Center
    titleLb.Parent = mainFrame

    local fpsSmall = Instance.new("TextLabel")
    fpsSmall.Size = UDim2.new(0.25, 0, 0, 12)
    fpsSmall.Position = UDim2.new(0.72, 0, 0, 2)
    fpsSmall.BackgroundTransparency = 1
    fpsSmall.Text = "FPS: 0"
    fpsSmall.TextSize = 7
    fpsSmall.Font = Enum.Font.GothamMedium
    fpsSmall.TextColor3 = Color3.fromRGB(180, 180, 200)
    fpsSmall.TextXAlignment = Enum.TextXAlignment.Left
    fpsSmall.Parent = mainFrame

    local pingSmall = Instance.new("TextLabel")
    pingSmall.Size = UDim2.new(0.25, 0, 0, 12)
    pingSmall.Position = UDim2.new(0.72, 0, 0, 14)
    pingSmall.BackgroundTransparency = 1
    pingSmall.Text = "Ping: 0 ms"
    pingSmall.TextSize = 7
    pingSmall.Font = Enum.Font.GothamMedium
    pingSmall.TextColor3 = Color3.fromRGB(180, 180, 200)
    pingSmall.TextXAlignment = Enum.TextXAlignment.Left
    pingSmall.Parent = mainFrame

    local subLb = Instance.new("TextLabel")
    subLb.Size = UDim2.new(0.6, 0, 0, 12)
    subLb.Position = UDim2.new(0.2, 0, 0, 20)
    subLb.BackgroundTransparency = 1
    subLb.Text = "Auto Flash • Potion"
    subLb.TextSize = 7
    subLb.Font = Enum.Font.GothamMedium
    subLb.TextColor3 = Color3.fromRGB(180, 180, 200)
    subLb.TextXAlignment = Enum.TextXAlignment.Center
    subLb.Parent = mainFrame

    local spamBtn = Instance.new("TextButton")
    spamBtn.Size = UDim2.new(0.25, 0, 0, 16)
    spamBtn.Position = UDim2.new(0.2, 0, 0, 34)
    spamBtn.BackgroundColor3 = Color3.fromRGB(51, 70, 168)
    spamBtn.BackgroundTransparency = 0.1
    spamBtn.BorderSizePixel = 0
    spamBtn.Text = "SPAM"
    spamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spamBtn.TextSize = 9
    spamBtn.Font = Enum.Font.GothamBold
    spamBtn.AutoButtonColor = false
    spamBtn.Parent = mainFrame
    local spamCorner = Instance.new("UICorner")
    spamCorner.CornerRadius = UDim.new(0, 5)
    spamCorner.Parent = spamBtn

    spamBtn.MouseEnter:Connect(function()
        spamBtn.BackgroundTransparency = 0
        spamBtn.BackgroundColor3 = Color3.fromRGB(62, 85, 200)
    end)
    spamBtn.MouseLeave:Connect(function()
        spamBtn.BackgroundTransparency = 0.1
        spamBtn.BackgroundColor3 = Color3.fromRGB(51, 70, 168)
    end)

    spamBtn.MouseButton1Click:Connect(function()
        if _G.spamNearest then _G.spamNearest() end
    end)

    local defBtn = Instance.new("TextButton")
    defBtn.Size = UDim2.new(0.25, 0, 0, 16)
    defBtn.Position = UDim2.new(0.55, 0, 0, 34)
    defBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    defBtn.BackgroundTransparency = 0.1
    defBtn.BorderSizePixel = 0
    defBtn.Text = "DEF OFF"
    defBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    defBtn.TextSize = 8
    defBtn.Font = Enum.Font.GothamBold
    defBtn.AutoButtonColor = false
    defBtn.Parent = mainFrame
    local defCorner = Instance.new("UICorner")
    defCorner.CornerRadius = UDim.new(0, 5)
    defCorner.Parent = defBtn

    local defenseOn = false
    defBtn.MouseButton1Click:Connect(function()
        defenseOn = not defenseOn
        if _G.toggleAutoDefense then _G.toggleAutoDefense() end
        defBtn.Text = defenseOn and "DEF ON" or "DEF OFF"
        defBtn.BackgroundColor3 = defenseOn and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
        defBtn.TextColor3 = defenseOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    end)

    task.spawn(function()
        local fCount = 0
        local fTime = tick()
        while true do
            fCount = fCount + 1
            local now = tick()
            if now - fTime >= 0.7 then
                local fps = math.min(999, math.floor(fCount / (now - fTime)))
                local ping = 0
                pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000) end)
                fpsSmall.Text = "FPS: " .. fps
                pingSmall.Text = "Ping: " .. ping .. " ms"
                if fps < 40 then fpsSmall.TextColor3 = Color3.fromRGB(255, 65, 65)
                elseif fps < 55 then fpsSmall.TextColor3 = Color3.fromRGB(255, 190, 40)
                else fpsSmall.TextColor3 = Color3.fromRGB(52, 218, 88)
                end
                if ping < 100 then pingSmall.TextColor3 = Color3.fromRGB(52, 218, 88)
                elseif ping < 200 then pingSmall.TextColor3 = Color3.fromRGB(255, 190, 40)
                else pingSmall.TextColor3 = Color3.fromRGB(255, 65, 65)
                end
                fCount = 0
                fTime = now
            end
            task.wait()
        end
    end)

    -- ========== UTILS GUI (KICK & RJ) ==========
    local utilsGui = Instance.new("ScreenGui")
    utilsGui.Name = "FlashTPUtils"
    utilsGui.ResetOnSpawn = false
    utilsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    utilsGui.Parent = CoreGui

    local utilsFrame = Instance.new("Frame")
    utilsFrame.Name = "UtilsFrame"
    utilsFrame.Position = UDim2.new(0, 10, 0, 10)
    utilsFrame.Size = UDim2.new(0, 44, 0, 44)
    utilsFrame.Active = true
    utilsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    utilsFrame.BackgroundTransparency = 0
    utilsFrame.BorderSizePixel = 0
    utilsFrame.ClipsDescendants = true
    utilsFrame.Parent = utilsGui

    local utilsCorner = Instance.new("UICorner")
    utilsCorner.CornerRadius = UDim.new(0, 8)
    utilsCorner.Parent = utilsFrame

    local utilsGlow = Instance.new("UIStroke")
    utilsGlow.Color = Color3.fromRGB(255, 255, 255)
    utilsGlow.Thickness = 1.5
    utilsGlow.Transparency = 0.2
    utilsGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    utilsGlow.Parent = utilsFrame

    local utilsGrad = Instance.new("UIGradient")
    utilsGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    utilsGrad.Parent = utilsGlow

    task.spawn(function()
        while utilsGrad and utilsGrad.Parent do
            utilsGrad.Rotation = (utilsGrad.Rotation + 0.6) % 360
            task.wait(0.016)
        end
    end)

    -- KICK button
    local kickBtn = Instance.new("TextButton")
    kickBtn.Size = UDim2.new(1, -4, 0, 16)
    kickBtn.Position = UDim2.new(0, 2, 0, 2)
    kickBtn.BackgroundColor3 = Color3.fromRGB(30, 8, 8)
    kickBtn.BackgroundTransparency = 0.1
    kickBtn.BorderSizePixel = 0
    kickBtn.Text = "KICK"
    kickBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
    kickBtn.TextSize = 8
    kickBtn.Font = Enum.Font.GothamBold
    kickBtn.AutoButtonColor = false
    kickBtn.Parent = utilsFrame
    local kickCorner = Instance.new("UICorner")
    kickCorner.CornerRadius = UDim.new(0, 4)
    kickCorner.Parent = kickBtn

    kickBtn.MouseEnter:Connect(function()
        kickBtn.BackgroundTransparency = 0
        kickBtn.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
    end)
    kickBtn.MouseLeave:Connect(function()
        kickBtn.BackgroundTransparency = 0.1
        kickBtn.BackgroundColor3 = Color3.fromRGB(30, 8, 8)
    end)

    kickBtn.MouseButton1Click:Connect(function()
        kickBtn.Text = "..."
        task.spawn(function()
            LP:Kick("du bist gut genug")
        end)
    end)

    -- REJOIN button (only Teleport)
    local rjBtn = Instance.new("TextButton")
    rjBtn.Size = UDim2.new(1, -4, 0, 16)
    rjBtn.Position = UDim2.new(0, 2, 0, 20)
    rjBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 30)
    rjBtn.BackgroundTransparency = 0.1
    rjBtn.BorderSizePixel = 0
    rjBtn.Text = "RJ"
    rjBtn.TextColor3 = Color3.fromRGB(150, 150, 255)
    rjBtn.TextSize = 8
    rjBtn.Font = Enum.Font.GothamBold
    rjBtn.AutoButtonColor = false
    rjBtn.Parent = utilsFrame
    local rjCorner = Instance.new("UICorner")
    rjCorner.CornerRadius = UDim.new(0, 4)
    rjCorner.Parent = rjBtn

    rjBtn.MouseEnter:Connect(function()
        rjBtn.BackgroundTransparency = 0
        rjBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 50)
    end)
    rjBtn.MouseLeave:Connect(function()
        rjBtn.BackgroundTransparency = 0.1
        rjBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 30)
    end)

    rjBtn.MouseButton1Click:Connect(function()
        rjBtn.Text = "..."
        task.spawn(function()
            local placeId = game.PlaceId
            pcall(function()
                TeleportService:Teleport(placeId, LP)
            end)
        end)
    end)

    print("✅ Flash TP loaded! SPAM: tiny,inverse,rocket,morph,jumpscare | DEFENSE: balloon then ragdoll after 30s | SELF-RAGDOLL ON POTION | SPEED: 31")
end)
