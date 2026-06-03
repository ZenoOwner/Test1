--LEAKED BY 32e4
--Leaked at .gg/luascripts
--if you paid for this u got scammed

local leakedby32e4_Players = game:GetService("Players")
local leakedby32e4_ReplicatedStorage = game:GetService("ReplicatedStorage")
local leakedby32e4_RunService = game:GetService("RunService")
local leakedby32e4_UserInputService = game:GetService("UserInputService")
local leakedby32e4_TweenService = game:GetService("TweenService")
local leakedby32e4_StarterGui = game:GetService("StarterGui")
local leakedby32e4_Stats = game:GetService("Stats")
local leakedby32e4_VirtualInputManager = Instance.new("VirtualInputManager")

local leakedby32e4_LocalPlayer = leakedby32e4_Players.LocalPlayer
local leakedby32e4_PlayerGui = leakedby32e4_LocalPlayer:WaitForChild("PlayerGui")

-- ==================== GLOBAL VARIABLES ====================
leakedby32e4_AutoBlockEnabled = false
leakedby32e4_AutoFlashEnabled = false
leakedby32e4_AutoPotionEnabled = false
leakedby32e4_AutoSelectBestBrainrot = false
leakedby32e4_RagdollBypassEnabled = false

-- ==================== STEAL SYSTEM (Raq Logic) ====================
local leakedby32e4_stealCbCache = {}
local leakedby32e4_stealActive = false
local leakedby32e4_MIN_HOLD_TIME = 1.3
local leakedby32e4_TRIGGER_DELAY = 0.05

local leakedby32e4_ragdollCommandCache = {}
local leakedby32e4_ragdollProfileCache = {}
local leakedby32e4_ragdollCacheActivated, leakedby32e4_ragdollFireActivated, leakedby32e4_ragdollGetAdminFrames, leakedby32e4_ragdollSelf

-- ==================== ANTI-RAGDOLL SYSTEM ====================
local leakedby32e4_AntiRagdoll = { connections = {}, running = false }

leakedby32e4_AntiRagdoll.forceBackpack = function()
    if not leakedby32e4_AntiRagdoll.running then return end
    local gui = leakedby32e4_LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local backpackGui = gui:FindFirstChild("BackpackGui")
    if not backpackGui then return end
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then return end
    backpack.Visible = true
    if not backpack:FindFirstChild("ForceConnection") then
        local tag = Instance.new("BoolValue")
        tag.Name = "ForceConnection"
        tag.Parent = backpack
        backpack:GetPropertyChangedSignal("Visible"):Connect(function()
            if not leakedby32e4_AntiRagdoll.running then return end
            if not backpack.Visible then backpack.Visible = true end
        end)
    end
end

leakedby32e4_AntiRagdoll.removeRagdollConstraints = function(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")
            or d:IsA("NoCollisionConstraint")
            or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
            d:Destroy()
        end
    end
end

leakedby32e4_AntiRagdoll.resetCharacter = function(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Anchored = false
        rootPart.Velocity = Vector3.zero
    end
    if humanoid then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then
                obj.Enabled = true
            end
        end
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid.PlatformStand = false
        humanoid.Sit = false
        if humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        workspace.CurrentCamera.CameraSubject = humanoid
    end
end

leakedby32e4_AntiRagdoll.onCharacterAdded_AR = function(char)
    char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    leakedby32e4_AntiRagdoll.connections.charDescAdded = char.DescendantAdded:Connect(function(obj)
        if not leakedby32e4_AntiRagdoll.running then return end
        if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint")
            or obj:IsA("NoCollisionConstraint")
            or (obj:IsA("Attachment") and obj.Name:find("RagdollAttachment")) then
            task.defer(function()
                if not leakedby32e4_AntiRagdoll.running then return end
                if obj.Parent then obj:Destroy() end
            end)
        end
    end)
    leakedby32e4_AntiRagdoll.connections.platformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if not leakedby32e4_AntiRagdoll.running then return end
        if humanoid.PlatformStand then
            task.defer(function()
                if not leakedby32e4_AntiRagdoll.running then return end
                leakedby32e4_AntiRagdoll.resetCharacter(char)
                leakedby32e4_AntiRagdoll.removeRagdollConstraints(char)
            end)
        end
    end)
    leakedby32e4_AntiRagdoll.removeRagdollConstraints(char)
    leakedby32e4_AntiRagdoll.resetCharacter(char)
end

leakedby32e4_AntiRagdoll.enable = function()
    if leakedby32e4_AntiRagdoll.running then return end
    leakedby32e4_AntiRagdoll.running = true
    leakedby32e4_AntiRagdoll.connections.heartbeat = leakedby32e4_RunService.Heartbeat:Connect(function()
        local char = leakedby32e4_LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        local ragdolled = (s == Enum.HumanoidStateType.Physics
            or s == Enum.HumanoidStateType.Ragdoll
            or s == Enum.HumanoidStateType.FallingDown)
        local endTime = leakedby32e4_LocalPlayer:GetAttribute("RagdollEndTime")
        if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
            ragdolled = true
        end
        if ragdolled then
            pcall(function() leakedby32e4_LocalPlayer:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
            leakedby32e4_AntiRagdoll.removeRagdollConstraints(char)
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then
                    obj.Enabled = true
                end
            end
            if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            workspace.CurrentCamera.CameraSubject = hum
            root.Anchored = false
            root.Velocity = Vector3.zero
        end
    end)
    leakedby32e4_AntiRagdoll.connections.charAdded = leakedby32e4_LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        leakedby32e4_AntiRagdoll.forceBackpack()
        leakedby32e4_AntiRagdoll.onCharacterAdded_AR(char)
    end)
    if leakedby32e4_LocalPlayer.Character then leakedby32e4_AntiRagdoll.onCharacterAdded_AR(leakedby32e4_LocalPlayer.Character) end
    task.spawn(function()
        while leakedby32e4_AntiRagdoll.running do
            task.wait(0.5)
            leakedby32e4_AntiRagdoll.forceBackpack()
        end
    end)
end

leakedby32e4_AntiRagdoll.disable = function()
    leakedby32e4_AntiRagdoll.running = false
    for _, conn in pairs(leakedby32e4_AntiRagdoll.connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    leakedby32e4_AntiRagdoll.connections = {}
    pcall(function()
        local char = leakedby32e4_LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end)
end

-- ==================== HELPER FUNCTIONS ====================
local function leakedby32e4_drawClickDot(x, y)
    if not Drawing then return end
    local dot = Drawing.new("Circle")
    dot.Radius = 5
    dot.Position = Vector2.new(x, y)
    dot.Color = Color3.fromRGB(255, 80, 80)
    dot.Filled = true
    dot.Visible = true
    dot.Transparency = 0.6
    task.delay(0.25, function() dot:Remove() end)
end

local function leakedby32e4_getPlotOwnerPlayer()
    local sel = _G._FH_SelectedBrainrot
    if not sel or not sel.plotName then return nil end
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    local plot = plotsFolder:FindFirstChild(sel.plotName)
    if not plot then return nil end
    local ownerName = nil
    local sign = plot:FindFirstChild("PlotSign", true)
    if sign then
        for _, d in ipairs(sign:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text and d.Text ~= "" then
                local t = d.Text
                if not t:lower():find("empty") then
                    local m = t:match("[Bb]ase [Oo]f%s+(.+)")
                    if m then ownerName = m; break end
                    if #t > 0 and #t < 30 then ownerName = t; break end
                end
            end
        end
    end
    if not ownerName then return nil end
    for _, p in ipairs(leakedby32e4_Players:GetPlayers()) do
        if p ~= leakedby32e4_LocalPlayer and (p.Name == ownerName or p.DisplayName == ownerName) then
            return p
        end
    end
    return nil
end

local function leakedby32e4_getNearestPlayer()
    local chr = leakedby32e4_LocalPlayer and leakedby32e4_LocalPlayer.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(leakedby32e4_Players:GetPlayers()) do
        if p ~= leakedby32e4_LocalPlayer then
            local c = p.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if h then
                local dist = (h.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function leakedby32e4_blockPlayer(targetPlayer)
    if not targetPlayer then return end
    pcall(function() leakedby32e4_StarterGui:SetCore("PromptBlockPlayer", targetPlayer) end)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local x = math.floor(vp.X / 2) + math.random(-1, 1)
    local y = math.floor(vp.Y / 2 + 50) + math.random(-1, 1)

    local chr = leakedby32e4_LocalPlayer and leakedby32e4_LocalPlayer.Character
    local blockers = {}
    if chr then
        for _, t in ipairs(chr:GetChildren()) do
            if t:IsA("Tool") then
                local blocked = true
                local conn = t.Activated:Connect(function()
                    if blocked then return end
                end)
                table.insert(blockers, { conn = conn, setUnblocked = function() blocked = false end })
            end
        end
    end

    task.wait(0.04 + math.random() * 0.02)
    leakedby32e4_drawClickDot(x, y)
    pcall(function() leakedby32e4_VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1) end)
    task.wait(0.008 + math.random() * 0.008)
    pcall(function() leakedby32e4_VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1) end)

    task.delay(0.05, function()
        for _, b in ipairs(blockers) do
            b.setUnblocked()
            pcall(function() b.conn:Disconnect() end)
        end
    end)
end

local function leakedby32e4_getBlockDelay()
    local ping = 0
    pcall(function() ping = leakedby32e4_LocalPlayer:GetNetworkPing() or 0 end)
    return math.clamp(0.09 + ping, 0.09, 0.35)
end

local function leakedby32e4_triggerAutoBlock()
    if not leakedby32e4_AutoBlockEnabled then return end
    task.spawn(function()
        task.wait(leakedby32e4_getBlockDelay())
        local target = leakedby32e4_getPlotOwnerPlayer() or leakedby32e4_getNearestPlayer()
        if target then
            pcall(leakedby32e4_blockPlayer, target)
        end
    end)
end

-- ==================== STEAL HOLD FUNCTIONS (Raq Logic) ====================
local function leakedby32e4_buildStealCallbacks(prompt)
    if leakedby32e4_stealCbCache[prompt] then return leakedby32e4_stealCbCache[prompt] end
    if not getconnections then return nil end
    local data = { hold = {}, trigger = {} }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, c in ipairs(conns1) do
            if type(c.Function) == "function" then table.insert(data.hold, c.Function) end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, c in ipairs(conns2) do
            if type(c.Function) == "function" then table.insert(data.trigger, c.Function) end
        end
    end
    if #data.hold == 0 and #data.trigger == 0 then return nil end
    leakedby32e4_stealCbCache[prompt] = data
    return data
end

local function leakedby32e4_startStealHold(prompt)
    if not prompt or not prompt.Parent then return nil end
    local cb = leakedby32e4_buildStealCallbacks(prompt)
    if not cb then return nil end
    leakedby32e4_stealActive = true
    for _, fn in ipairs(cb.hold) do task.spawn(fn) end
    return {
        cb = cb,
        ragdollFireTime = tick(),
        holdBeganAt = tick(),
        holdDone = false,
    }
end

local function leakedby32e4_doHoldAndWait(ctx)
    if ctx.holdDone then return end
    for _, fn in ipairs(ctx.cb.hold) do task.spawn(fn) end
    ctx.holdBeganAt = tick()
    task.wait(leakedby32e4_MIN_HOLD_TIME)
    ctx.holdDone = true
end

local function leakedby32e4_finishStealHold(ctx)
    if not ctx then return false end
    if not ctx.holdBeganAt then leakedby32e4_doHoldAndWait(ctx) end
    local held = tick() - (ctx.holdBeganAt or tick())
    if held < leakedby32e4_MIN_HOLD_TIME then task.wait(leakedby32e4_MIN_HOLD_TIME - held) end
    task.wait(leakedby32e4_TRIGGER_DELAY)
    for _, fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
    leakedby32e4_stealActive = false
    return true
end

local function leakedby32e4_findTargetPrompt()
    local sel = _G._FH_SelectedBrainrot
    if not sel or not sel.plotName or not sel.slot then return nil end
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    local plot = plotsFolder:FindFirstChild(sel.plotName)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(tostring(sel.slot))
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    local spawn_ = base and base:FindFirstChild("Spawn")
    local pa = spawn_ and spawn_:FindFirstChild("PromptAttachment")
    local prompt = pa and pa:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = math.huge
    end
    return prompt
end

-- ==================== RAGDOLL SELF FUNCTIONS ====================
leakedby32e4_ragdollCacheActivated = function(guiObject)
    local cached = {}
    local ok, conns = pcall(getconnections, guiObject.Activated)
    if ok and type(conns) == "table" then
        for _, conn in ipairs(conns) do
            if type(conn.Function) == "function" then
                table.insert(cached, conn.Function)
            end
        end
    end
    return cached
end

leakedby32e4_ragdollFireActivated = function(cached)
    for _, fn in ipairs(cached) do task.spawn(fn) end
end

leakedby32e4_ragdollGetAdminFrames = function()
    local ap = leakedby32e4_LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
    if not ap then return nil, nil end
    local panel = ap:FindFirstChild("AdminPanel")
    if not panel then return nil, nil end
    local content = panel:FindFirstChild("Content")
    local profiles = panel:FindFirstChild("Profiles")
    if not content or not profiles then return nil, nil end
    return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
end

leakedby32e4_ragdollSelf = function()
    local commandFrame, profileFrame = leakedby32e4_ragdollGetAdminFrames()
    if not commandFrame or not profileFrame then return end
    local pName = leakedby32e4_LocalPlayer.Name
    local profileBtn = profileFrame:FindFirstChild(pName)
    local ragdollBtn = commandFrame:FindFirstChild("ragdoll")
    if not profileBtn or not ragdollBtn then return end
    if not leakedby32e4_ragdollProfileCache[pName] then
        leakedby32e4_ragdollProfileCache[pName] = leakedby32e4_ragdollCacheActivated(profileBtn)
    end
    if not leakedby32e4_ragdollCommandCache["ragdoll"] then
        leakedby32e4_ragdollCommandCache["ragdoll"] = leakedby32e4_ragdollCacheActivated(ragdollBtn)
    end
    leakedby32e4_ragdollFireActivated(leakedby32e4_ragdollCommandCache["ragdoll"])
    task.wait()
    leakedby32e4_ragdollFireActivated(leakedby32e4_ragdollProfileCache[pName])
end

-- ==================== NOTIFICATION SYSTEM ====================
local leakedby32e4_ShowToggleNotification
do
    local _activeNotifs = {}
    local NOTIF_W, NOTIF_H, NOTIF_GAP, NOTIF_PAD_X, NOTIF_PAD_Y, NOTIF_DUR = 200, 44, 6, 14, 14, 2
    local T_White = Color3.fromRGB(245, 245, 245)
    local T_Border = Color3.fromRGB(55, 75, 105)

    local function _shadowTargetY(slotIdx)
        return -(NOTIF_PAD_Y + NOTIF_H + 4 + slotIdx * (NOTIF_H + NOTIF_GAP))
    end
    local function _repoAll(tweenInfo)
        for i, e in ipairs(_activeNotifs) do
            leakedby32e4_TweenService:Create(e.shadow, tweenInfo, {
                Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(i - 1))
            }):Play()
        end
    end

    local function Corner(p, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = p
        return c
    end
    local function NStroke(p, col, th)
        local s = Instance.new("UIStroke")
        s.Color = col or T_Border
        s.Thickness = th or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = p
        return s
    end
    local function NLabel(p, txt, sz, col, font)
        local l = Instance.new("TextLabel")
        l.Text = txt or ""
        l.TextSize = sz or 13
        l.TextColor3 = col or T_White
        l.Font = font or Enum.Font.GothamMedium
        l.BackgroundTransparency = 1
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = p
        return l
    end

    leakedby32e4_ShowToggleNotification = function(toggleName, enabled)
        local guiParent = leakedby32e4_LocalPlayer:FindFirstChild("PlayerGui") and leakedby32e4_LocalPlayer.PlayerGui:FindFirstChild("CyberPVP")
        if not guiParent then return end

        local statusTxt = enabled and "Enabled" or "Disabled"
        local statusCol = enabled and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 100, 100)
        local IN_INFO = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local OUT_INFO = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local BAR_INFO = TweenInfo.new(NOTIF_DUR, Enum.EasingStyle.Linear)
        local FADE_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
        local REPO_INFO = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        local shadow = Instance.new("Frame")
        shadow.Name = "ToastShadow"
        shadow.Size = UDim2.new(0, NOTIF_W + 8, 0, NOTIF_H + 8)
        shadow.Position = UDim2.new(0, -(NOTIF_W + 32), 1, _shadowTargetY(0))
        shadow.BackgroundColor3 = Color3.fromRGB(15, 25, 35)
        shadow.BackgroundTransparency = 0.12
        shadow.BorderSizePixel = 0
        shadow.ZIndex = 99
        shadow.Parent = guiParent
        Corner(shadow, 12)

        local toast = Instance.new("Frame")
        toast.Name = "ToastNotif"
        toast.Size = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
        toast.Position = UDim2.new(0, 4, 0, 4)
        toast.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        toast.BackgroundTransparency = 1
        toast.BorderSizePixel = 0
        toast.ZIndex = 100
        toast.Parent = shadow
        Corner(toast, 10)
        local _stroke = NStroke(toast, Color3.fromRGB(65, 85, 120), 1); _stroke.Transparency = 1

        local pill = Instance.new("Frame")
        pill.Size = UDim2.new(0, 3, 0, NOTIF_H - 16)
        pill.Position = UDim2.new(0, 9, 0.5, -(NOTIF_H - 16) / 2)
        pill.BackgroundColor3 = T_White
        pill.BorderSizePixel = 0
        pill.ZIndex = 101
        pill.Parent = toast
        Corner(pill, 2)

        local nameLabel = NLabel(toast, toggleName, 11, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
        nameLabel.Size = UDim2.new(1, -24, 0, 15); nameLabel.Position = UDim2.new(0, 19, 0, 7)
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd; nameLabel.TextTransparency = 1; nameLabel.ZIndex = 101

        local statusLabel = NLabel(toast, statusTxt, 10, statusCol, Enum.Font.Gotham)
        statusLabel.Size = UDim2.new(1, -24, 0, 11); statusLabel.Position = UDim2.new(0, 19, 0, 23)
        statusLabel.TextTransparency = 1; statusLabel.ZIndex = 101

        local barTrack = Instance.new("Frame")
        barTrack.Size = UDim2.new(1, 0, 0, 2); barTrack.Position = UDim2.new(0, 0, 1, -2)
        barTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35); barTrack.BorderSizePixel = 0
        barTrack.ZIndex = 101; barTrack.Parent = toast

        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(1, 0, 1, 0); barFill.BackgroundColor3 = T_White
        barFill.BorderSizePixel = 0; barFill.ZIndex = 102; barFill.Parent = barTrack

        local entry = { shadow = shadow }
        table.insert(_activeNotifs, 1, entry)
        _repoAll(REPO_INFO)
        leakedby32e4_TweenService:Create(shadow, IN_INFO, { Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(0)) }):Play()
        leakedby32e4_TweenService:Create(toast, IN_INFO, { BackgroundTransparency = 0 }):Play()
        leakedby32e4_TweenService:Create(_stroke, IN_INFO, { Transparency = 0.3 }):Play()
        leakedby32e4_TweenService:Create(nameLabel, IN_INFO, { TextTransparency = 0 }):Play()
        leakedby32e4_TweenService:Create(statusLabel, IN_INFO, { TextTransparency = 0 }):Play()
        task.delay(0.1, function() leakedby32e4_TweenService:Create(barFill, BAR_INFO, { Size = UDim2.new(0, 0, 1, 0) }):Play() end)
        task.delay(NOTIF_DUR + 0.15, function()
            for i, e in ipairs(_activeNotifs) do if e == entry then table.remove(_activeNotifs, i); break end end
            _repoAll(REPO_INFO)
            local exitY = shadow.Position.Y.Offset
            leakedby32e4_TweenService:Create(shadow, OUT_INFO, { Position = UDim2.new(0, -(NOTIF_W + 32), 1, exitY) }):Play()
            leakedby32e4_TweenService:Create(toast, FADE_INFO, { BackgroundTransparency = 1 }):Play()
            leakedby32e4_TweenService:Create(nameLabel, FADE_INFO, { TextTransparency = 1 }):Play()
            local tw = leakedby32e4_TweenService:Create(statusLabel, FADE_INFO, { TextTransparency = 1 })
            tw:Play()
            tw.Completed:Connect(function() shadow:Destroy() end)
        end)
    end
end

-- ==================== RESET FUNCTION (Raq Logic) ====================
local function leakedby32e4_doReset()
    local Net = leakedby32e4_ReplicatedStorage:WaitForChild("Packages", 2) and leakedby32e4_ReplicatedStorage.Packages:WaitForChild("Net", 2)
    if not Net then
        local char = leakedby32e4_LocalPlayer and leakedby32e4_LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.Health = 0 end
        return
    end

    local remote = nil
    local childs = Net:GetChildren()
    for i = 1, #childs - 1 do
        if childs[i] and childs[i + 1] and string.find(childs[i].Name, "Tools/Cooldown") then
            remote = childs[i + 1]
            break
        end
    end
    if not remote then
        local char = leakedby32e4_LocalPlayer and leakedby32e4_LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.Health = 0 end
        return
    end

    local savedTools = {}
    local char = leakedby32e4_LocalPlayer.Character
    local bp = leakedby32e4_LocalPlayer:FindFirstChild("Backpack")

    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:UnequipTools() end) end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                table.insert(savedTools, t)
                t.Parent = nil
            end
        end
    end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                table.insert(savedTools, t)
                t.Parent = nil
            end
        end
    end

    leakedby32e4_LocalPlayer.Character = nil
    local sending = true
    local loopConnection
    local fire = remote.FireServer
    local _respawnThrottle = 0

    loopConnection = leakedby32e4_RunService.Heartbeat:Connect(function(dt)
        if not sending then
            if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
            return
        end
        _respawnThrottle = _respawnThrottle + dt
        if _respawnThrottle >= 0.1 then
            _respawnThrottle = 0
            pcall(fire, remote, "f888ee6e-c86d-46e1-93d7-0639d6635d42", leakedby32e4_LocalPlayer, "balloon")
        end
        if sending and leakedby32e4_LocalPlayer.Character then leakedby32e4_LocalPlayer.Character = nil end
    end)

    local conn
    conn = leakedby32e4_LocalPlayer.CharacterAdded:Connect(function()
        sending = false
        if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
        if conn then conn:Disconnect() end
        task.spawn(function()
            local newBp = leakedby32e4_LocalPlayer:WaitForChild("Backpack", 3)
            if newBp then
                for _, t in ipairs(savedTools) do
                    if t then t.Parent = newBp end
                end
            end
            savedTools = {}
        end)
    end)

    task.delay(4, function()
        sending = false
        if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
        local curBp = leakedby32e4_LocalPlayer:FindFirstChild("Backpack")
        if curBp and #savedTools > 0 then
            for _, t in ipairs(savedTools) do
                if t then t.Parent = curBp end
            end
            savedTools = {}
        end
    end)
end

-- ==================== FLASH FUNCTION (Raq Logic - Preserved Exactly) ====================
local function leakedby32e4_doFlash()
    local lp = leakedby32e4_LocalPlayer
    local chr = lp and lp.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local PODIUM_CFRAMES = {
        [1] = {
            [1] = {
                hrp = CFrame.new(Vector3.new(-347.6983, -7.5033, -4.5494)),
                cam = CFrame.new(-357.0927, 0.0048, -0.272) * CFrame.Angles(-0.954463, -0.903625, -0.837019),
            },
            [2] = { hrp = CFrame.new(0,0,0), cam = nil },
            [3] = { hrp = CFrame.new(0,0,0), cam = nil },
            [4] = { hrp = CFrame.new(0,0,0), cam = nil },
            [5] = { hrp = CFrame.new(0,0,0), cam = nil },
        },
        [2] = {
            [1] = { hrp = CFrame.new(Vector3.new(-349.9259, -7.3841, -1.578)), cam = CFrame.new(-361.8253, 1.3324, 5.126) * CFrame.Angles(-0.824269, -0.878251, -0.693896) },
            [2] = { hrp = CFrame.new(Vector3.new(-348.4448, -7.1043, 3.3442)), cam = CFrame.new(-358.5857, -0.0841, 9.5148) * CFrame.Angles(-0.732523, -0.884924, -0.608084) },
            [3] = { hrp = CFrame.new(-346.1821, -7.2885, -1.609) * CFrame.Angles(0, -1.247212, 0), cam = CFrame.new(-360.1625, 0.6353, 3.1776) * CFrame.Angles(-0.932656, -1.049154, -0.86316) },
            [4] = { hrp = CFrame.new(-343.6695, -7.0385, 10.3377) * CFrame.Angles(0, -0.982332, 0), cam = CFrame.new(-356.477, -0.7795, 18.8846) * CFrame.Angles(-0.510736, -0.917793, -0.418726) },
            [5] = { hrp = CFrame.new(-343.7608, -7.4124, -9.7994) * CFrame.Angles(0, -1.544676, 0), cam = CFrame.new(-359.4998, -2.4726, -9.2893) * CFrame.Angles(-1.424811, -1.351549, -1.421283) },
            [6] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-325.655, -7.5033, 54.5488) * CFrame.Angles(0, -0.69115, 0), cam = CFrame.new(-338.7595, -4.0265, 70.3894) * CFrame.Angles(-0.126016, -0.687243, -0.080199) },
            [7] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-344.4383, -7.5033, 41.8672) * CFrame.Angles(0, -1.108982, 0), cam = CFrame.new(-362.8094, -4.325, 51.1551) * CFrame.Angles(-0.181885, -1.095968, -0.162135) },
            [8] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-348.5228, -7.5033, 48.1022) * CFrame.Angles(0, -0.939336, 0), cam = CFrame.new(-363.5051, -2.5713, 59.0596) * CFrame.Angles(-0.30602, -0.916511, -0.245634) },
            [9] = { hrp = CFrame.new(-339.6349, -7.5033, 60.4164) * CFrame.Angles(0, -0.405266, 0), cam = CFrame.new(-346.7646, -3.7365, 77.0351) * CFrame.Angles(-0.137335, -0.401849, -0.054002) },
            [10] = { hrp = CFrame.new(-339.4453, -7.5033, 61.9429) * CFrame.Angles(0, -0.29845, 0), cam = CFrame.new(-342.5024, -5.2211, 71.8802) * CFrame.Angles(-0.081543, -0.297517, -0.023953) },
            [11] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-331.5262, -7.5033, -47.3607) * CFrame.Angles(0, 0.003141, 0), cam = CFrame.new(-331.4885, -9.6045, -59.3396) * CFrame.Angles(2.851853, -0.097011, -3.140695) },
            [12] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-338.729, -7.5033, -43.4714) * CFrame.Angles(0, -1.420208, 0), cam = CFrame.new(-345.1804, -9.9578, -56.8524) * CFrame.Angles(2.856299, -0.433315, 3.01906) },
            [13] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-334.5183, -7.5033, -41.6819) * CFrame.Angles(0, -0.543495, 0), cam = CFrame.new(-341.912, -9.959, -53.9192) * CFrame.Angles(2.831168, -0.52207, 2.982964) },
            [14] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-319.8298, -7.5033, -45.1476) * CFrame.Angles(0, -0.323585, 0), cam = CFrame.new(-323.983, -9.9618, -57.5315) * CFrame.Angles(2.834406, -0.309406, 3.045298) },
            [15] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-317.917, -7.5033, -41.9999) * CFrame.Angles(0, -0.565487, 0), cam = CFrame.new(-325.8, -9.9581, -54.4216) * CFrame.Angles(2.835549, -0.544183, 2.979445) },
            [16] = { hrp = CFrame.new(-338.285, -7.5033, 57.204) * CFrame.Angles(0, -0.207346, 0), cam = CFrame.new(-340.4345, -9.5916, 67.4219) * CFrame.Angles(0.335111, -0.196113, 0.067755) },
            [17] = { hrp = CFrame.new(-337.9285, -7.5033, 55.1757) * CFrame.Angles(0, -0.430398, 0), cam = CFrame.new(-341.7441, -8.9535, 63.4867) * CFrame.Angles(0.337895, -0.408747, 0.138758) },
            [18] = { hrp = CFrame.new(-332.1088, -7.5033, 53.1675) * CFrame.Angles(0, -0.49323, 0), cam = CFrame.new(-336.3932, -9.2396, 61.1377) * CFrame.Angles(0.382481, -0.462609, 0.177644) },
            [19] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-328.579, -3.1209, -35.0857) * CFrame.Angles(0, 0.021988, 0), cam = CFrame.new(-328.5137, -10.011, -45.4753) * CFrame.Angles(2.387391, -0.004579, 3.137291) },
            [20] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-321.5783, -7.5033, -33.5778) * CFrame.Angles(0, 0.006284, 0), cam = CFrame.new(-321.5535, -10.0218, -37.5259) * CFrame.Angles(2.387391, -0.004579, 3.137291) },
            [21] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-314.088, -7.5033, -32.1806) * CFrame.Angles(0, -0.006282, 0), cam = CFrame.new(-314.1147, -10.0174, -36.4214) * CFrame.Angles(2.387391, -0.004579, 3.137291) },
            [22] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-306.8919, -7.5033, -33.9124) * CFrame.Angles(0, -0.006284, 0), cam = CFrame.new(-306.923, -10.008, -38.86) * CFrame.Angles(2.4648, -0.004898, 3.137657) },
            [23] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-300.2759, -7.5033, -32.7047) * CFrame.Angles(0, -0.031416, 0), cam = CFrame.new(-300.4669, -10.016, -37.044) * CFrame.Angles(2.399014, -0.032413, 3.111857) },
            [24] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-330.0484, -7.5033, 48.183) * CFrame.Angles(0, -0.006377, 0), cam = CFrame.new(-330.1124, -10.0063, 53.2779) * CFrame.Angles(0.662308, -0.00991, 0.007727) },
            [25] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-325.4576, -7.5033, 46.8182) * CFrame.Angles(0, -0.125663, 0), cam = CFrame.new(-326.0541, -10.0104, 51.5397) * CFrame.Angles(0.700033, -0.09632, 0.080833) },
            [26] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-324.6721, -7.5033, 47.2033) * CFrame.Angles(0, -0.40212, 0), cam = CFrame.new(-326.6859, -10.0057, 51.9385) * CFrame.Angles(0.698024, -0.314979, 0.254268) },
            [27] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-320.4196, -7.5033, 44.1) * CFrame.Angles(0, -0.571769, 0), cam = CFrame.new(-322.9213, -10.0122, 49.5157) * CFrame.Angles(0.876985, -0.422603, 0.397417) },
        },
    }

    local myBase = nil
    local plotsFolder = workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            if plot:IsA("Model") then
                local sign = plot:FindFirstChild("PlotSign")
                if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then
                    local ok, order = pcall(function() return plot:GetAttribute("Order") end)
                    if ok and order then myBase = tonumber(order) end
                    break
                end
            end
        end
    end

    if not myBase then
        pcall(leakedby32e4_ShowToggleNotification, "Flash: base not detected", false)
        return
    end

    local targetBase = (myBase == 1) and 2 or 1
    local podiumCFs = PODIUM_CFRAMES[targetBase]
    if not podiumCFs then return end

    local selected = _G._FH_SelectedBrainrot
    if not selected then
        pcall(leakedby32e4_ShowToggleNotification, "Flash: select an animal first", false)
        return
    end

    local slot = tonumber(selected.slot)
    if not slot then
        pcall(leakedby32e4_ShowToggleNotification, "Flash: selected animal has no slot", false)
        return
    end

    local entry = podiumCFs[slot]
    if not entry or not entry.cam then
        pcall(leakedby32e4_ShowToggleNotification, "Flash: podium " .. tostring(slot) .. " not configured yet", false)
        return
    end

    task.spawn(function()
        local currentSpeed = entry.hrpFloat and 800 or 210
        local ARRIVE_DIST = 4
        local TIMEOUT = 8

        local player = leakedby32e4_LocalPlayer
        local targetPos = (entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position

        local function findTool(kw)
            local c = player.Character
            local b = player:FindFirstChild("Backpack")
            if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
            if b then for _, t in ipairs(b:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
        end

        local function doEquip(tool, timeout)
            local c = player.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not (c and h) then return end
            if tool.Parent == c then return end
            local done = false
            local cn
            cn = tool.Equipped:Connect(function() done = true; cn:Disconnect() end)
            pcall(function() h:EquipTool(tool) end)
            local dl = tick() + (timeout or 1)
            while not done and tick() < dl do task.wait() end
            if cn then pcall(function() cn:Disconnect() end) end
        end

        local carpet = findTool("carpet")
        if carpet then doEquip(carpet, 1) end

        local stealCtx = nil
        local _lateGrabSlots = { [11]=true,[12]=true,[13]=true,[14]=true,[15]=true,
                                  [19]=true,[20]=true,[21]=true,[22]=true,[23]=true }
        if not _lateGrabSlots[slot] then
            task.spawn(function()
                local chr3 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local dest = (entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
                local dist = chr3 and (chr3.Position - dest).Magnitude or 0
                local POST_ARRIVAL = 0.10 + 0.15 + 0.07 + 0.30 + 0.12
                local travelTime = dist / math.max(currentSpeed, 1)
                local timeUntilFire = travelTime + POST_ARRIVAL
                local preDelay = math.max(0, timeUntilFire - leakedby32e4_MIN_HOLD_TIME)
                if preDelay > 0 then task.wait(preDelay) end
                local targetPrompt = leakedby32e4_findTargetPrompt()
                if targetPrompt then stealCtx = leakedby32e4_startStealHold(targetPrompt) end
            end)
        end

        local boostConn
        boostConn = leakedby32e4_RunService.Heartbeat:Connect(function()
            if not player.Character then return end
            local hrpB = player.Character:FindFirstChild("HumanoidRootPart")
            local humB = player.Character:FindFirstChildOfClass("Humanoid")
            if not hrpB or not humB then return end
            local diff = targetPos - hrpB.Position
            local flat = Vector3.new(diff.X, 0, diff.Z)
            if flat.Magnitude > ARRIVE_DIST then
                local flatDir = flat.Unit
                hrpB.Velocity = Vector3.new(flatDir.X * currentSpeed, hrpB.Velocity.Y, flatDir.Z * currentSpeed)
            else
                hrpB.Velocity = Vector3.new(0, hrpB.Velocity.Y, 0)
            end
        end)

        local chr2 = player.Character
        local hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2:MoveTo(targetPos) end

        local deadline = tick() + TIMEOUT
        local _lastMoveTo = 0
        repeat
            task.wait()
            chr2 = player.Character
            local hrp2 = chr2 and chr2:FindFirstChild("HumanoidRootPart")
            hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if not (hrp2 and hum2) then break end
            local _now = tick()
            if _now - _lastMoveTo >= 0.1 then hum2:MoveTo(targetPos); _lastMoveTo = _now end
            if (hrp2.Position - targetPos).Magnitude < ARRIVE_DIST then break end
        until tick() > deadline

        if boostConn then boostConn:Disconnect(); boostConn = nil end

        if _lateGrabSlots[slot] then
            task.spawn(function()
                local _chr3 = player.Character
                local _hrp3 = _chr3 and _chr3:FindFirstChild("HumanoidRootPart")
                local _finalP = entry.hrp.Position
                local _d2 = _hrp3 and (_hrp3.Position - _finalP).Magnitude or 0
                local _POST2 = 0.10 + 0.15 + 0.07 + 0.30 + 0.12
                local _pre2 = math.max(0, (_d2 / math.max(currentSpeed, 1)) + _POST2 - leakedby32e4_MIN_HOLD_TIME)
                if _pre2 > 0 then task.wait(_pre2) end
                local _tp = leakedby32e4_findTargetPrompt()
                if _tp then stealCtx = leakedby32e4_startStealHold(_tp) end
            end)
        end

        if entry.hrpWalk then
            local finalPos = entry.hrp.Position
            local boostConn2
            boostConn2 = leakedby32e4_RunService.Heartbeat:Connect(function()
                if not player.Character then return end
                local hrp3 = player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp3 then return end
                local diff3 = finalPos - hrp3.Position
                local flat3 = Vector3.new(diff3.X, 0, diff3.Z)
                if flat3.Magnitude > ARRIVE_DIST then
                    local fd = flat3.Unit
                    hrp3.Velocity = Vector3.new(fd.X * currentSpeed, hrp3.Velocity.Y, fd.Z * currentSpeed)
                else
                    hrp3.Velocity = Vector3.new(0, hrp3.Velocity.Y, 0)
                end
            end)
            chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if hum2 then hum2:MoveTo(finalPos) end
            local deadline2 = tick() + TIMEOUT
            local _lastMoveTo2 = 0
            repeat
                task.wait()
                chr2 = player.Character
                local hrp2b = chr2 and chr2:FindFirstChild("HumanoidRootPart")
                hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if not (hrp2b and hum2) then break end
                local _now2 = tick()
                if _now2 - _lastMoveTo2 >= 0.1 then hum2:MoveTo(finalPos); _lastMoveTo2 = _now2 end
                if (hrp2b.Position - finalPos).Magnitude < ARRIVE_DIST then break end
            until tick() > deadline2
            boostConn2:Disconnect()
            chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
            local hrpStop = chr2 and chr2:FindFirstChild("HumanoidRootPart")
            if hrpStop and hum2 then
                hrpStop.CFrame = entry.hrp; hrpStop.Velocity = Vector3.zero; hrpStop.Anchored = true
                task.defer(function() task.defer(function()
                    local _c = player.Character; local _h = _c and _c:FindFirstChild("HumanoidRootPart")
                    if _h then _h.Velocity = Vector3.zero; _h.Anchored = false end
                end) end)
            end
        else
            chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
            local hrpStop = chr2 and chr2:FindFirstChild("HumanoidRootPart")
            if hrpStop and hum2 then
                hrpStop.CFrame = entry.hrp; hrpStop.Velocity = Vector3.zero; hrpStop.Anchored = true
                task.defer(function() task.defer(function()
                    local _c = player.Character; local _h = _c and _c:FindFirstChild("HumanoidRootPart")
                    if _h then _h.Velocity = Vector3.zero; _h.Anchored = false end
                end) end)
            end
        end

        local cam = workspace.CurrentCamera
        if cam and entry.cam then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = entry.cam
            task.defer(function()
                cam.CFrame = entry.cam
                task.defer(function()
                    cam.CFrame = entry.cam
                    cam.CameraType = Enum.CameraType.Custom
                end)
            end)
        end

        local carpetMid = findTool("carpet")
        if carpetMid then doEquip(carpetMid, 1.5) end
        task.wait(0.35)

        if (slot >= 19 and slot <= 27) and hum2 then
            hum2:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
        if not (chr2 and hum2) then return end

        local flashTool = nil
        local bp = player:FindFirstChild("Backpack")
        if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool = t; break end end end
        if not flashTool then for _, t in ipairs(chr2:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool = t; break end end end

        if not flashTool then
            pcall(leakedby32e4_ShowToggleNotification, "Flash: tool not found in inventory", false)
            return
        end

        pcall(function() hum2:UnequipTools() end)
        task.wait(0.07)

        local _flashEquipped = false
        local _flashEquipConn
        _flashEquipConn = flashTool.Equipped:Connect(function()
            _flashEquipped = true; _flashEquipConn:Disconnect(); _flashEquipConn = nil
        end)
        flashTool.Parent = chr2
        pcall(function() hum2:EquipTool(flashTool) end)
        local _eqDeadline = tick() + 1
        while not _flashEquipped and tick() < _eqDeadline do task.wait() end
        if _flashEquipConn then pcall(function() _flashEquipConn:Disconnect() end) end

        pcall(function() flashTool:Activate() end)

        task.spawn(function()
            task.wait(0.08)
            if not leakedby32e4_RagdollBypassEnabled then
                if stealCtx then
                    leakedby32e4_triggerAutoBlock()
                    leakedby32e4_finishStealHold(stealCtx)
                elseif type(_G._sv2DoSteal) == "function" then
                    leakedby32e4_triggerAutoBlock()
                    pcall(_G._sv2DoSteal)
                end
            end
        end)

        task.wait(0.02)
        pcall(function() flashTool:Activate() end)
        task.wait(0.08)

        if hum2 then pcall(function() hum2:UnequipTools() end) end
        task.wait(0.05)
        local bp2 = player:FindFirstChild("Backpack")
        if bp2 and flashTool and flashTool.Parent ~= bp2 then flashTool.Parent = bp2 end

        local char3 = player.Character
        local bp3 = player:FindFirstChild("Backpack")
        if char3 and bp3 then
            local potion = bp3:FindFirstChild("Body Swap Potion")
            if potion then
                pcall(function() potion.Parent = char3; potion:Activate(); potion.Parent = bp3 end)
            end
        end

        if leakedby32e4_RagdollBypassEnabled then
            task.spawn(function()
                task.wait(0.10)
                pcall(leakedby32e4_ragdollSelf)
                leakedby32e4_triggerAutoBlock()

                local _kicked = false
                local _kickConn1, _kickConn2
                local _tgtPlayer = leakedby32e4_getPlotOwnerPlayer()
                local _tgtChar = _tgtPlayer and _tgtPlayer.Character
                local _tgtHum = _tgtChar and _tgtChar:FindFirstChildOfClass("Humanoid")
                local function _onKicked()
                    if _kicked then return end
                    _kicked = true
                    if _kickConn1 then pcall(function() _kickConn1:Disconnect() end); _kickConn1 = nil end
                    if _kickConn2 then pcall(function() _kickConn2:Disconnect() end); _kickConn2 = nil end
                    local _wf = 0
                    while not stealCtx and _wf < 3 do task.wait(); _wf = _wf + 1 end
                    if not stealCtx then
                        local _fp = leakedby32e4_findTargetPrompt()
                        if _fp then stealCtx = leakedby32e4_startStealHold(_fp) end
                    end
                    if stealCtx then
                        leakedby32e4_finishStealHold(stealCtx)
                    elseif type(_G._sv2DoSteal) == "function" then
                        pcall(_G._sv2DoSteal)
                    end
                end
                if _tgtHum then
                    _kickConn1 = _tgtHum.StateChanged:Connect(function(_, new)
                        if new == Enum.HumanoidStateType.Physics
                            or new == Enum.HumanoidStateType.Ragdoll
                            or new == Enum.HumanoidStateType.FallingDown then
                            _onKicked()
                        end
                    end)
                    _kickConn2 = _tgtHum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
                        if _tgtHum.PlatformStand then _onKicked() end
                    end)
                end
                task.delay(0.35, _onKicked)

                task.wait(0.15)
                chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
                local potionTool = player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Body Swap Potion")
                if potionTool and leakedby32e4_RagdollBypassEnabled then
                    pcall(function() hum2:UnequipTools() end)
                    task.wait(0.05)
                    potionTool.Parent = chr2
                    pcall(function() hum2:EquipTool(potionTool) end)
                    task.wait(0.12)
                    pcall(function() potionTool:Activate() end)
                    task.wait(0.05)
                    pcall(function() potionTool:Activate() end)
                    task.wait(0.1)
                    if hum2 then pcall(function() hum2:UnequipTools() end) end
                    task.wait(0.05)
                    local bp4 = player:FindFirstChild("Backpack")
                    if bp4 and potionTool and potionTool.Parent ~= bp4 then potionTool.Parent = bp4 end
                end

                local carpetFinal = findTool("carpet")
                if carpetFinal then doEquip(carpetFinal, 1) end
            end)
        end

        pcall(leakedby32e4_ShowToggleNotification, "Flash â†’ Base " .. targetBase .. " Podium " .. slot, true)
    end)
end

-- ==================== BLOCK FUNCTION ====================
local function leakedby32e4_doBlock()
    local target = leakedby32e4_getNearestPlayer()
    if target then
        pcall(leakedby32e4_blockPlayer, target)
        pcall(leakedby32e4_ShowToggleNotification, "Blocked: " .. target.Name, true)
        
        -- Auto Potion: Use Giant Potion after block (0.5s delay with mouse click)
        if leakedby32e4_AutoPotionEnabled then
            task.spawn(function()
                task.wait(0.5)
                local player = leakedby32e4_LocalPlayer
                local backpack = player:FindFirstChild("Backpack")
                local character = player.Character
                
                if not character then return end
                
                local potion = nil
                local searchNames = {"Giant Potion", "giant potion", "GIANT POTION", "Potion", "potion"}
                
                if backpack then
                    for _, name in ipairs(searchNames) do
                        potion = backpack:FindFirstChild(name)
                        if potion then break end
                    end
                end
                
                if not potion and backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:lower():find("potion") then
                            potion = tool
                            break
                        end
                    end
                end
                
                if not potion and character then
                    for _, tool in ipairs(character:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:lower():find("potion") then
                            potion = tool
                            break
                        end
                    end
                end
                
                if potion and potion:IsA("Tool") then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        if potion.Parent ~= character then
                            pcall(function() humanoid:EquipTool(potion) end)
                            task.wait(0.1)
                        end
                        
                        local mouse = player:GetMouse()
                        local mouseX = math.floor(mouse.X)
                        local mouseY = math.floor(mouse.Y)
                        
                        pcall(function() 
                            leakedby32e4_VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, true, game, 1)
                            task.wait(0.05)
                            leakedby32e4_VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, false, game, 1)
                        end)
                        
                        pcall(leakedby32e4_ShowToggleNotification, "âœ“ " .. potion.Name .. " activated!", true)
                    end
                else
                    pcall(leakedby32e4_ShowToggleNotification, "âš  Potion not found", false)
                end
            end)
        end
    else
        pcall(leakedby32e4_ShowToggleNotification, "Block: no players nearby", false)
    end
end

_G._FH_ResetBtnEntry = { fire = leakedby32e4_doReset }
_G._FH_FlashBtnEntry = { fire = leakedby32e4_doFlash }
_G._FH_BlockBtnEntry = { fire = leakedby32e4_doBlock }

-- ==================== AUTO FLASH SYSTEM ====================
do
    local _afPending = false

    local function tryAutoFlash()
        if not leakedby32e4_AutoFlashEnabled then return end
        if not _G._FH_SelectedBrainrot then
            pcall(leakedby32e4_ShowToggleNotification, "Auto Flash: no animal selected", false)
            return
        end
        if _afPending then return end
        _afPending = true

        task.spawn(function()
            pcall(leakedby32e4_ShowToggleNotification, "Auto Flash: resetting...", true)
            if _G._FH_DoSelectedReset then pcall(_G._FH_DoSelectedReset) end

            local deadline = tick() + 8
            while (not leakedby32e4_LocalPlayer.Character or not leakedby32e4_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and tick() < deadline do
                task.wait(0.1)
            end
            if not leakedby32e4_LocalPlayer.Character or not leakedby32e4_LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                _afPending = false; return
            end

            task.wait(0.15)
            if not leakedby32e4_AutoFlashEnabled then _afPending = false; return end
            if not _G._FH_SelectedBrainrot then _afPending = false; return end

            pcall(leakedby32e4_ShowToggleNotification, "Auto Flash: flashing!", true)
            if _G._FH_FlashBtnEntry then pcall(_G._FH_FlashBtnEntry.fire) end

            task.wait(3)
            _afPending = false
        end)
    end

    local _afBoundRemotes = {}
    local _afLastBalloon = 0
    local function _afBindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _afBoundRemotes[obj] then return end
        local ok, conn = pcall(function()
            return obj.OnClientEvent:Connect(function(...)
                if not leakedby32e4_AutoFlashEnabled then return end
                for i = 1, select("#", ...) do
                    local arg = select(i, ...)
                    if type(arg) == "string" and arg:lower():find("jump higher", 1, true) then
                        local now = tick()
                        if now - _afLastBalloon < 3 then return end
                        _afLastBalloon = now
                        tryAutoFlash()
                        return
                    end
                end
            end)
        end)
        if ok and conn then _afBoundRemotes[obj] = conn end
    end
    pcall(function()
        for _, obj in ipairs(leakedby32e4_ReplicatedStorage:GetDescendants()) do _afBindRemote(obj) end
        leakedby32e4_ReplicatedStorage.DescendantAdded:Connect(function(obj) _afBindRemote(obj) end)
    end)
end

-- ==================== GUI CREATION HELPERS ====================
local function leakedby32e4_create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if children then for _, child in ipairs(children) do child.Parent = inst end end
    return inst
end

-- ==================== COLORS ====================
local leakedby32e4_C = {
    accent = Color3.fromRGB(50, 120, 255),
    accentHi = Color3.fromRGB(80, 160, 255),
    deepBlue = Color3.fromRGB(10, 20, 60),
    body = Color3.fromRGB(5, 8, 18),
    panel = Color3.fromRGB(8, 12, 24),
    tabBar = Color3.fromRGB(6, 9, 20),
    card = Color3.fromRGB(14, 20, 40),
    iconBg = Color3.fromRGB(14, 24, 55),
    stroke = Color3.fromRGB(30, 50, 100),
    strokeDim = Color3.fromRGB(20, 32, 65),
    textBright = Color3.fromRGB(220, 235, 255),
    textBlue = Color3.fromRGB(100, 170, 255),
    textMute = Color3.fromRGB(80, 110, 170),
    textDim = Color3.fromRGB(50, 75, 130),
    knobOn = Color3.fromRGB(200, 225, 255),
    knobOff = Color3.fromRGB(60, 75, 110),
    trackOff = Color3.fromRGB(18, 26, 50),
}

local leakedby32e4_borderGradientSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0, leakedby32e4_C.accentHi),
    ColorSequenceKeypoint.new(0.25, leakedby32e4_C.deepBlue),
    ColorSequenceKeypoint.new(0.5, leakedby32e4_C.accent),
    ColorSequenceKeypoint.new(0.75, leakedby32e4_C.deepBlue),
    ColorSequenceKeypoint.new(1, leakedby32e4_C.accentHi),
})

-- Clean up old GUI
local leakedby32e4_old = leakedby32e4_PlayerGui:FindFirstChild("CyberPVP")
if leakedby32e4_old then leakedby32e4_old:Destroy() end
local leakedby32e4_oldB = leakedby32e4_PlayerGui:FindFirstChild("CyberHubBanner")
if leakedby32e4_oldB then leakedby32e4_oldB:Destroy() end

-- ==================== MAIN GUI ====================
local leakedby32e4_CyberPVP = Instance.new("ScreenGui")
leakedby32e4_CyberPVP.Name = "CyberPVP"
leakedby32e4_CyberPVP.SelectionGroup = false
leakedby32e4_CyberPVP.ResetOnSpawn = false
leakedby32e4_CyberPVP.DisplayOrder = 999
leakedby32e4_CyberPVP.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
leakedby32e4_CyberPVP.IgnoreGuiInset = false
leakedby32e4_CyberPVP.Parent = leakedby32e4_PlayerGui

local leakedby32e4_BorderFrame = Instance.new("Frame")
leakedby32e4_BorderFrame.Name = "BorderFrame"
leakedby32e4_BorderFrame.SelectionGroup = false
leakedby32e4_BorderFrame.Size = UDim2.new(0, 314, 0, 404)
leakedby32e4_BorderFrame.Position = UDim2.new(0.5, -708, 0.5, 252)
leakedby32e4_BorderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
leakedby32e4_BorderFrame.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_BorderFrame.BorderSizePixel = 0
leakedby32e4_BorderFrame.ClipsDescendants = false
leakedby32e4_BorderFrame.Active = false
leakedby32e4_BorderFrame.Selectable = false
leakedby32e4_BorderFrame.Parent = leakedby32e4_CyberPVP

local leakedby32e4_UICorner = Instance.new("UICorner")
leakedby32e4_UICorner.Name = "UICorner"
leakedby32e4_UICorner.CornerRadius = UDim.new(0, 15)
leakedby32e4_UICorner.Parent = leakedby32e4_BorderFrame

local leakedby32e4_UIGradient = Instance.new("UIGradient")
leakedby32e4_UIGradient.Name = "UIGradient"
leakedby32e4_UIGradient.Color = leakedby32e4_borderGradientSeq
leakedby32e4_UIGradient.Rotation = 308.077
leakedby32e4_UIGradient.Parent = leakedby32e4_BorderFrame

local leakedby32e4_Win = Instance.new("Frame")
leakedby32e4_Win.Name = "Win"
leakedby32e4_Win.SelectionGroup = false
leakedby32e4_Win.Size = UDim2.new(0, 310, 0, 400)
leakedby32e4_Win.Position = UDim2.new(0.5, -404, 0.5, 61)
leakedby32e4_Win.AnchorPoint = Vector2.new(0.5, 0.5)
leakedby32e4_Win.BackgroundTransparency = 1
leakedby32e4_Win.BorderSizePixel = 0
leakedby32e4_Win.ZIndex = 2
leakedby32e4_Win.ClipsDescendants = false
leakedby32e4_Win.Active = false
leakedby32e4_Win.Selectable = false
leakedby32e4_Win.Parent = leakedby32e4_CyberPVP

local leakedby32e4_Frame = Instance.new("Frame")
leakedby32e4_Frame.Name = "Frame"
leakedby32e4_Frame.SelectionGroup = false
leakedby32e4_Frame.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_Frame.BackgroundColor3 = leakedby32e4_C.body
leakedby32e4_Frame.BorderSizePixel = 0
leakedby32e4_Frame.ClipsDescendants = true
leakedby32e4_Frame.Active = false
leakedby32e4_Frame.Selectable = false
leakedby32e4_Frame.Parent = leakedby32e4_Win

local leakedby32e4_UICorner2 = Instance.new("UICorner")
leakedby32e4_UICorner2.Name = "UICorner"
leakedby32e4_UICorner2.CornerRadius = UDim.new(0, 13)
leakedby32e4_UICorner2.Parent = leakedby32e4_Frame

local leakedby32e4_Frame2 = Instance.new("Frame")
leakedby32e4_Frame2.Name = "Frame"
leakedby32e4_Frame2.SelectionGroup = false
leakedby32e4_Frame2.Size = UDim2.new(1, 0, 1, -94)
leakedby32e4_Frame2.Position = UDim2.new(0, 0, 0, 90)
leakedby32e4_Frame2.BackgroundColor3 = leakedby32e4_C.panel
leakedby32e4_Frame2.BorderSizePixel = 0
leakedby32e4_Frame2.ClipsDescendants = false
leakedby32e4_Frame2.Active = false
leakedby32e4_Frame2.Selectable = false
leakedby32e4_Frame2.Parent = leakedby32e4_Frame

local leakedby32e4_UICorner3 = Instance.new("UICorner")
leakedby32e4_UICorner3.Name = "UICorner"
leakedby32e4_UICorner3.CornerRadius = UDim.new(0, 13)
leakedby32e4_UICorner3.Parent = leakedby32e4_Frame2

local leakedby32e4_Frame3 = Instance.new("Frame")
leakedby32e4_Frame3.Name = "Frame"
leakedby32e4_Frame3.SelectionGroup = false
leakedby32e4_Frame3.Size = UDim2.new(1, 0, 0, 47)
leakedby32e4_Frame3.Position = UDim2.new(0, 0, 0, -8)
leakedby32e4_Frame3.BackgroundTransparency = 1
leakedby32e4_Frame3.BorderSizePixel = 0
leakedby32e4_Frame3.ZIndex = 3
leakedby32e4_Frame3.ClipsDescendants = false
leakedby32e4_Frame3.Active = false
leakedby32e4_Frame3.Selectable = false
leakedby32e4_Frame3.Parent = leakedby32e4_Frame

local leakedby32e4_Frame4 = Instance.new("Frame")
leakedby32e4_Frame4.Name = "Frame"
leakedby32e4_Frame4.SelectionGroup = false
leakedby32e4_Frame4.Size = UDim2.new(1, 0, 0, 1)
leakedby32e4_Frame4.Position = UDim2.new(0, 0, 1, -1)
leakedby32e4_Frame4.BackgroundColor3 = leakedby32e4_C.stroke
leakedby32e4_Frame4.BorderSizePixel = 0
leakedby32e4_Frame4.ZIndex = 4
leakedby32e4_Frame4.ClipsDescendants = false
leakedby32e4_Frame4.Active = false
leakedby32e4_Frame4.Selectable = false
leakedby32e4_Frame4.Parent = leakedby32e4_Frame3

local leakedby32e4_Frame5 = Instance.new("Frame")
leakedby32e4_Frame5.Name = "Frame"
leakedby32e4_Frame5.SelectionGroup = false
leakedby32e4_Frame5.Size = UDim2.new(0, 6, 0, 6)
leakedby32e4_Frame5.Position = UDim2.new(0, 10, 0.5, -3)
leakedby32e4_Frame5.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_Frame5.BorderSizePixel = 0
leakedby32e4_Frame5.ZIndex = 5
leakedby32e4_Frame5.ClipsDescendants = false
leakedby32e4_Frame5.Active = false
leakedby32e4_Frame5.Selectable = false
leakedby32e4_Frame5.Parent = leakedby32e4_Frame3

local leakedby32e4_UICorner4 = Instance.new("UICorner")
leakedby32e4_UICorner4.Name = "UICorner"
leakedby32e4_UICorner4.CornerRadius = UDim.new(0, 4)
leakedby32e4_UICorner4.Parent = leakedby32e4_Frame5

local leakedby32e4_Frame6 = Instance.new("Frame")
leakedby32e4_Frame6.Name = "Frame"
leakedby32e4_Frame6.SelectionGroup = false
leakedby32e4_Frame6.Size = UDim2.new(0, 12, 0, 12)
leakedby32e4_Frame6.Position = UDim2.new(0, 7, 0.5, -6)
leakedby32e4_Frame6.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_Frame6.BackgroundTransparency = 0.75
leakedby32e4_Frame6.BorderSizePixel = 0
leakedby32e4_Frame6.ZIndex = 4
leakedby32e4_Frame6.ClipsDescendants = false
leakedby32e4_Frame6.Active = false
leakedby32e4_Frame6.Selectable = false
leakedby32e4_Frame6.Parent = leakedby32e4_Frame3

local leakedby32e4_UICorner5 = Instance.new("UICorner")
leakedby32e4_UICorner5.Name = "UICorner"
leakedby32e4_UICorner5.CornerRadius = UDim.new(0, 7)
leakedby32e4_UICorner5.Parent = leakedby32e4_Frame6

local leakedby32e4_TextLabel = Instance.new("TextLabel")
leakedby32e4_TextLabel.Name = "TextLabel"
leakedby32e4_TextLabel.SelectionGroup = false
leakedby32e4_TextLabel.Size = UDim2.new(0, 39, 1, 0)
leakedby32e4_TextLabel.Position = UDim2.new(0, 24, 0, 0)
leakedby32e4_TextLabel.BackgroundTransparency = 1
leakedby32e4_TextLabel.ZIndex = 5
leakedby32e4_TextLabel.ClipsDescendants = false
leakedby32e4_TextLabel.Active = false
leakedby32e4_TextLabel.Selectable = false
leakedby32e4_TextLabel.Text = "CYBER"
leakedby32e4_TextLabel.TextColor3 = leakedby32e4_C.textBright
leakedby32e4_TextLabel.TextSize = 11
leakedby32e4_TextLabel.Font = Enum.Font.GothamBold
leakedby32e4_TextLabel.TextScaled = false
leakedby32e4_TextLabel.TextWrapped = false
leakedby32e4_TextLabel.TextXAlignment = Enum.TextXAlignment.Left
leakedby32e4_TextLabel.RichText = false
leakedby32e4_TextLabel.Parent = leakedby32e4_Frame3

local leakedby32e4_TextLabel2 = Instance.new("TextLabel")
leakedby32e4_TextLabel2.Name = "TextLabel"
leakedby32e4_TextLabel2.SelectionGroup = false
leakedby32e4_TextLabel2.Size = UDim2.new(1, -163, 1, 0)
leakedby32e4_TextLabel2.Position = UDim2.new(0, 63, 0, 0)
leakedby32e4_TextLabel2.BackgroundTransparency = 1
leakedby32e4_TextLabel2.ZIndex = 5
leakedby32e4_TextLabel2.ClipsDescendants = false
leakedby32e4_TextLabel2.Active = false
leakedby32e4_TextLabel2.Selectable = false
leakedby32e4_TextLabel2.Text = "<font color=\"rgb(50,120,255)\">PVP</font> <font color=\"rgb(80,110,170)\">|</font>  CYBER HUB"
leakedby32e4_TextLabel2.TextColor3 = leakedby32e4_C.textBright
leakedby32e4_TextLabel2.TextSize = 11
leakedby32e4_TextLabel2.Font = Enum.Font.GothamBold
leakedby32e4_TextLabel2.TextScaled = false
leakedby32e4_TextLabel2.TextWrapped = false
leakedby32e4_TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
leakedby32e4_TextLabel2.RichText = true
leakedby32e4_TextLabel2.Parent = leakedby32e4_Frame3

local leakedby32e4_TextLabel3 = Instance.new("TextLabel")
leakedby32e4_TextLabel3.Name = "TextLabel"
leakedby32e4_TextLabel3.SelectionGroup = false
leakedby32e4_TextLabel3.Size = UDim2.new(1, -163, 0, 12)
leakedby32e4_TextLabel3.Position = UDim2.new(0, 24, 1, -16)
leakedby32e4_TextLabel3.BackgroundTransparency = 1
leakedby32e4_TextLabel3.ZIndex = 5
leakedby32e4_TextLabel3.ClipsDescendants = false
leakedby32e4_TextLabel3.Active = false
leakedby32e4_TextLabel3.Selectable = false
leakedby32e4_TextLabel3.Text = "discord.gg/cyberhub"
leakedby32e4_TextLabel3.TextColor3 = leakedby32e4_C.textMute
leakedby32e4_TextLabel3.TextSize = 11
leakedby32e4_TextLabel3.Font = Enum.Font.GothamBold
leakedby32e4_TextLabel3.TextScaled = false
leakedby32e4_TextLabel3.TextWrapped = false
leakedby32e4_TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
leakedby32e4_TextLabel3.RichText = false
leakedby32e4_TextLabel3.Parent = leakedby32e4_Frame3

local function leakedby32e4_headerButton(name, txt, xOff)
    local b = Instance.new("TextButton")
    b.Name = "TextButton"
    b.SelectionGroup = false
    b.Size = UDim2.new(0, 22, 0, 22)
    b.Position = UDim2.new(1, xOff, 0.5, -11)
    b.BackgroundColor3 = leakedby32e4_C.card
    b.BorderSizePixel = 0
    b.ZIndex = 6
    b.ClipsDescendants = false
    b.Text = txt
    b.TextColor3 = leakedby32e4_C.textMute
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.TextScaled = false
    b.TextWrapped = false
    b.RichText = false
    b.AutoButtonColor = false
    b.Parent = leakedby32e4_Frame3
    local c = Instance.new("UICorner"); c.Name = "UICorner"; c.CornerRadius = UDim.new(0, 5); c.Parent = b
    local s = Instance.new("UIStroke"); s.Name = "UIStroke"; s.Color = leakedby32e4_C.stroke; s.Parent = b
    return b
end

local leakedby32e4_LockBtn = leakedby32e4_headerButton("Lock", utf8.char(0x1F513), -70)
local leakedby32e4_MinBtn = leakedby32e4_headerButton("Min", "-", -46)
local leakedby32e4_CloseBtn = leakedby32e4_headerButton("Close", "X", -22)

local leakedby32e4_Frame7 = Instance.new("Frame")
leakedby32e4_Frame7.Name = "Frame"
leakedby32e4_Frame7.SelectionGroup = false
leakedby32e4_Frame7.Size = UDim2.new(1, 0, 0, 69)
leakedby32e4_Frame7.Position = UDim2.new(0, 0, 0, 34)
leakedby32e4_Frame7.BackgroundTransparency = 1
leakedby32e4_Frame7.BorderSizePixel = 0
leakedby32e4_Frame7.ZIndex = 4
leakedby32e4_Frame7.ClipsDescendants = false
leakedby32e4_Frame7.Active = false
leakedby32e4_Frame7.Selectable = false
leakedby32e4_Frame7.Parent = leakedby32e4_Frame

local leakedby32e4_Frame8 = Instance.new("Frame")
leakedby32e4_Frame8.Name = "Frame"
leakedby32e4_Frame8.SelectionGroup = false
leakedby32e4_Frame8.Size = UDim2.new(1, 0, 0, 1)
leakedby32e4_Frame8.Position = UDim2.new(0, 0, 0, 55)
leakedby32e4_Frame8.BackgroundColor3 = leakedby32e4_C.stroke
leakedby32e4_Frame8.BorderSizePixel = 0
leakedby32e4_Frame8.ZIndex = 4
leakedby32e4_Frame8.ClipsDescendants = false
leakedby32e4_Frame8.Active = false
leakedby32e4_Frame8.Selectable = false
leakedby32e4_Frame8.Parent = leakedby32e4_Frame7

local function leakedby32e4_actionButton(name, label, xPos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.SelectionGroup = false
    btn.Size = UDim2.new(0, 94, 0, 40)
    btn.Position = UDim2.new(0, xPos, 0, 8)
    btn.BackgroundColor3 = leakedby32e4_C.card
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.ClipsDescendants = false
    btn.Text = ""
    btn.TextScaled = false
    btn.TextWrapped = false
    btn.RichText = false
    btn.AutoButtonColor = false
    btn.Parent = leakedby32e4_Frame7
    local c = Instance.new("UICorner"); c.Name = "UICorner"; c.CornerRadius = UDim.new(0, 7); c.Parent = btn
    local s = Instance.new("UIStroke"); s.Name = "UIStroke"; s.Color = leakedby32e4_C.stroke; s.Parent = btn
    local top = Instance.new("Frame")
    top.Name = "Frame"; top.SelectionGroup = false
    top.Size = UDim2.new(1, -10, 0, 2); top.Position = UDim2.new(0, 5, 0, 0)
    top.BackgroundColor3 = leakedby32e4_C.stroke; top.BorderSizePixel = 0; top.ZIndex = 6
    top.Active = false; top.Selectable = false; top.Parent = btn
    local tc = Instance.new("UICorner"); tc.Name = "UICorner"; tc.CornerRadius = UDim.new(0, 1); tc.Parent = top
    local lbl = Instance.new("TextLabel")
    lbl.Name = "TextLabel"; lbl.SelectionGroup = false
    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.ZIndex = 7
    lbl.Active = false; lbl.Selectable = false
    lbl.Text = label; lbl.TextColor3 = leakedby32e4_C.textBright; lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = false; lbl.TextWrapped = false; lbl.RichText = false
    lbl.Parent = btn
    return btn, top
end

local leakedby32e4_FLASHTP, leakedby32e4_flashAccent = leakedby32e4_actionButton("FLASH TP", "FLASH TP", 8)
local leakedby32e4_BLOCK, leakedby32e4_blockAccent = leakedby32e4_actionButton("BLOCK", "BLOCK", 108)
local leakedby32e4_RESET, leakedby32e4_resetAccent = leakedby32e4_actionButton("RESET", "RESET", 208)

local leakedby32e4_Frame12 = Instance.new("Frame")
leakedby32e4_Frame12.Name = "Frame"
leakedby32e4_Frame12.SelectionGroup = false
leakedby32e4_Frame12.Size = UDim2.new(1, 0, 0, 32)
leakedby32e4_Frame12.Position = UDim2.new(0, 0, 0, 90)
leakedby32e4_Frame12.BackgroundColor3 = leakedby32e4_C.tabBar
leakedby32e4_Frame12.BorderSizePixel = 0
leakedby32e4_Frame12.ZIndex = 5
leakedby32e4_Frame12.ClipsDescendants = false
leakedby32e4_Frame12.Active = false
leakedby32e4_Frame12.Selectable = false
leakedby32e4_Frame12.Parent = leakedby32e4_Frame

local leakedby32e4_UIListLayout = Instance.new("UIListLayout")
leakedby32e4_UIListLayout.Name = "UIListLayout"
leakedby32e4_UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
leakedby32e4_UIListLayout.FillDirection = Enum.FillDirection.Horizontal
leakedby32e4_UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
leakedby32e4_UIListLayout.Wraps = false
leakedby32e4_UIListLayout.Parent = leakedby32e4_Frame12

local leakedby32e4_TextButton4 = Instance.new("TextButton")
leakedby32e4_TextButton4.Name = "TextButton"
leakedby32e4_TextButton4.SelectionGroup = false
leakedby32e4_TextButton4.Size = UDim2.new(0, 155, 1, 0)
leakedby32e4_TextButton4.BackgroundColor3 = leakedby32e4_C.tabBar
leakedby32e4_TextButton4.BorderSizePixel = 0
leakedby32e4_TextButton4.ZIndex = 5
leakedby32e4_TextButton4.LayoutOrder = 1
leakedby32e4_TextButton4.ClipsDescendants = false
leakedby32e4_TextButton4.Text = ""
leakedby32e4_TextButton4.TextScaled = false
leakedby32e4_TextButton4.TextWrapped = false
leakedby32e4_TextButton4.RichText = false
leakedby32e4_TextButton4.AutoButtonColor = false
leakedby32e4_TextButton4.Parent = leakedby32e4_Frame12

local leakedby32e4_TextLabel7 = Instance.new("TextLabel")
leakedby32e4_TextLabel7.Name = "TextLabel"
leakedby32e4_TextLabel7.SelectionGroup = false
leakedby32e4_TextLabel7.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_TextLabel7.BackgroundTransparency = 1
leakedby32e4_TextLabel7.ZIndex = 6
leakedby32e4_TextLabel7.Active = false
leakedby32e4_TextLabel7.Selectable = false
leakedby32e4_TextLabel7.Text = "Brainrots"
leakedby32e4_TextLabel7.TextColor3 = leakedby32e4_C.textBlue
leakedby32e4_TextLabel7.TextSize = 12
leakedby32e4_TextLabel7.Font = Enum.Font.GothamMedium
leakedby32e4_TextLabel7.TextScaled = false
leakedby32e4_TextLabel7.TextWrapped = false
leakedby32e4_TextLabel7.RichText = false
leakedby32e4_TextLabel7.Parent = leakedby32e4_TextButton4

local leakedby32e4_Frame13 = Instance.new("Frame")
leakedby32e4_Frame13.Name = "Frame"
leakedby32e4_Frame13.SelectionGroup = false
leakedby32e4_Frame13.Size = UDim2.new(1, -16, 0, 2)
leakedby32e4_Frame13.Position = UDim2.new(0, 8, 1, -2)
leakedby32e4_Frame13.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_Frame13.BorderSizePixel = 0
leakedby32e4_Frame13.ZIndex = 7
leakedby32e4_Frame13.ClipsDescendants = false
leakedby32e4_Frame13.Active = false
leakedby32e4_Frame13.Selectable = false
leakedby32e4_Frame13.Parent = leakedby32e4_TextButton4

local leakedby32e4_UICorner15 = Instance.new("UICorner")
leakedby32e4_UICorner15.Name = "UICorner"
leakedby32e4_UICorner15.CornerRadius = UDim.new(0, 1)
leakedby32e4_UICorner15.Parent = leakedby32e4_Frame13

local leakedby32e4_TextButton5 = Instance.new("TextButton")
leakedby32e4_TextButton5.Name = "TextButton"
leakedby32e4_TextButton5.SelectionGroup = false
leakedby32e4_TextButton5.Size = UDim2.new(0, 155, 1, 0)
leakedby32e4_TextButton5.BackgroundColor3 = leakedby32e4_C.tabBar
leakedby32e4_TextButton5.BorderSizePixel = 0
leakedby32e4_TextButton5.ZIndex = 5
leakedby32e4_TextButton5.LayoutOrder = 2
leakedby32e4_TextButton5.ClipsDescendants = false
leakedby32e4_TextButton5.Text = ""
leakedby32e4_TextButton5.TextScaled = false
leakedby32e4_TextButton5.TextWrapped = false
leakedby32e4_TextButton5.RichText = false
leakedby32e4_TextButton5.AutoButtonColor = false
leakedby32e4_TextButton5.Parent = leakedby32e4_Frame12

local leakedby32e4_TextLabel8 = Instance.new("TextLabel")
leakedby32e4_TextLabel8.Name = "TextLabel"
leakedby32e4_TextLabel8.SelectionGroup = false
leakedby32e4_TextLabel8.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_TextLabel8.BackgroundTransparency = 1
leakedby32e4_TextLabel8.ZIndex = 6
leakedby32e4_TextLabel8.Active = false
leakedby32e4_TextLabel8.Selectable = false
leakedby32e4_TextLabel8.Text = "Settings"
leakedby32e4_TextLabel8.TextColor3 = leakedby32e4_C.textDim
leakedby32e4_TextLabel8.TextSize = 12
leakedby32e4_TextLabel8.Font = Enum.Font.GothamMedium
leakedby32e4_TextLabel8.TextScaled = false
leakedby32e4_TextLabel8.TextWrapped = false
leakedby32e4_TextLabel8.RichText = false
leakedby32e4_TextLabel8.Parent = leakedby32e4_TextButton5

local leakedby32e4_Frame14 = Instance.new("Frame")
leakedby32e4_Frame14.Name = "Frame"
leakedby32e4_Frame14.SelectionGroup = false
leakedby32e4_Frame14.Size = UDim2.new(1, -16, 0, 2)
leakedby32e4_Frame14.Position = UDim2.new(0, 8, 1, -2)
leakedby32e4_Frame14.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_Frame14.BackgroundTransparency = 1
leakedby32e4_Frame14.BorderSizePixel = 0
leakedby32e4_Frame14.ZIndex = 7
leakedby32e4_Frame14.ClipsDescendants = false
leakedby32e4_Frame14.Active = false
leakedby32e4_Frame14.Selectable = false
leakedby32e4_Frame14.Parent = leakedby32e4_TextButton5

local leakedby32e4_UICorner16 = Instance.new("UICorner")
leakedby32e4_UICorner16.Name = "UICorner"
leakedby32e4_UICorner16.CornerRadius = UDim.new(0, 1)
leakedby32e4_UICorner16.Parent = leakedby32e4_Frame14

local leakedby32e4_Frame15 = Instance.new("Frame")
leakedby32e4_Frame15.Name = "Frame"
leakedby32e4_Frame15.SelectionGroup = false
leakedby32e4_Frame15.Size = UDim2.new(1, 0, 0, 1)
leakedby32e4_Frame15.Position = UDim2.new(0, 0, 0, 121)
leakedby32e4_Frame15.BackgroundColor3 = leakedby32e4_C.stroke
leakedby32e4_Frame15.BorderSizePixel = 0
leakedby32e4_Frame15.ZIndex = 6
leakedby32e4_Frame15.ClipsDescendants = false
leakedby32e4_Frame15.Active = false
leakedby32e4_Frame15.Selectable = false
leakedby32e4_Frame15.Parent = leakedby32e4_Frame

local leakedby32e4_Frame16 = Instance.new("Frame")
leakedby32e4_Frame16.Name = "Frame"
leakedby32e4_Frame16.SelectionGroup = false
leakedby32e4_Frame16.Size = UDim2.new(1, 0, 1, -126)
leakedby32e4_Frame16.Position = UDim2.new(0, 0, 0, 122)
leakedby32e4_Frame16.BackgroundTransparency = 1
leakedby32e4_Frame16.BorderSizePixel = 0
leakedby32e4_Frame16.ZIndex = 2
leakedby32e4_Frame16.ClipsDescendants = true
leakedby32e4_Frame16.Active = false
leakedby32e4_Frame16.Selectable = false
leakedby32e4_Frame16.Parent = leakedby32e4_Frame

local leakedby32e4_Frame17 = Instance.new("Frame")
leakedby32e4_Frame17.Name = "Frame"
leakedby32e4_Frame17.SelectionGroup = false
leakedby32e4_Frame17.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_Frame17.BackgroundTransparency = 1
leakedby32e4_Frame17.BorderSizePixel = 0
leakedby32e4_Frame17.ZIndex = 3
leakedby32e4_Frame17.ClipsDescendants = false
leakedby32e4_Frame17.Active = false
leakedby32e4_Frame17.Selectable = false
leakedby32e4_Frame17.Parent = leakedby32e4_Frame16

local leakedby32e4_ScrollingFrame = Instance.new("ScrollingFrame")
leakedby32e4_ScrollingFrame.Name = "ScrollingFrame"
leakedby32e4_ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_ScrollingFrame.BackgroundTransparency = 1
leakedby32e4_ScrollingFrame.BorderSizePixel = 0
leakedby32e4_ScrollingFrame.Active = false
leakedby32e4_ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
leakedby32e4_ScrollingFrame.ScrollBarThickness = 3
leakedby32e4_ScrollingFrame.ScrollBarImageColor3 = leakedby32e4_C.accent
leakedby32e4_ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
leakedby32e4_ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
leakedby32e4_ScrollingFrame.Parent = leakedby32e4_Frame17

local leakedby32e4_UIListLayout2 = Instance.new("UIListLayout")
leakedby32e4_UIListLayout2.Name = "UIListLayout"
leakedby32e4_UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
leakedby32e4_UIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
leakedby32e4_UIListLayout2.Padding = UDim.new(0, 4)
leakedby32e4_UIListLayout2.Wraps = false
leakedby32e4_UIListLayout2.Parent = leakedby32e4_ScrollingFrame

-- ==================== BRAINROT SCANNER SECTION (Blue Theme) ====================
local leakedby32e4_Frame18 = Instance.new("Frame")
leakedby32e4_Frame18.Name = "Frame"
leakedby32e4_Frame18.SelectionGroup = false
leakedby32e4_Frame18.Size = UDim2.new(1, 0, 0, 28)
leakedby32e4_Frame18.BackgroundTransparency = 1
leakedby32e4_Frame18.BorderSizePixel = 0
leakedby32e4_Frame18.ZIndex = 4
leakedby32e4_Frame18.ClipsDescendants = false
leakedby32e4_Frame18.Active = false
leakedby32e4_Frame18.Selectable = false
leakedby32e4_Frame18.Parent = leakedby32e4_ScrollingFrame

local leakedby32e4_TextLabel9 = Instance.new("TextLabel")
leakedby32e4_TextLabel9.Name = "TextLabel"
leakedby32e4_TextLabel9.SelectionGroup = false
leakedby32e4_TextLabel9.Size = UDim2.new(1, -14, 1, 0)
leakedby32e4_TextLabel9.Position = UDim2.new(0, 14, 0, 0)
leakedby32e4_TextLabel9.BackgroundTransparency = 1
leakedby32e4_TextLabel9.ZIndex = 5
leakedby32e4_TextLabel9.Active = false
leakedby32e4_TextLabel9.Selectable = false
leakedby32e4_TextLabel9.Text = "Nothing selected"
leakedby32e4_TextLabel9.TextColor3 = Color3.fromRGB(100, 200, 255)
leakedby32e4_TextLabel9.TextSize = 12
leakedby32e4_TextLabel9.Font = Enum.Font.Gotham
leakedby32e4_TextLabel9.TextScaled = false
leakedby32e4_TextLabel9.TextWrapped = false
leakedby32e4_TextLabel9.TextXAlignment = Enum.TextXAlignment.Left
leakedby32e4_TextLabel9.RichText = false
leakedby32e4_TextLabel9.Parent = leakedby32e4_Frame18

local leakedby32e4_Frame19 = Instance.new("Frame")
leakedby32e4_Frame19.Name = "Frame"
leakedby32e4_Frame19.SelectionGroup = false
leakedby32e4_Frame19.Size = UDim2.new(1, 0, 0, 120)
leakedby32e4_Frame19.BackgroundColor3 = leakedby32e4_C.card
leakedby32e4_Frame19.BorderSizePixel = 0
leakedby32e4_Frame19.ZIndex = 4
leakedby32e4_Frame19.ClipsDescendants = false
leakedby32e4_Frame19.Active = false
leakedby32e4_Frame19.Selectable = false
leakedby32e4_Frame19.Parent = leakedby32e4_ScrollingFrame

local leakedby32e4_UICorner17 = Instance.new("UICorner")
leakedby32e4_UICorner17.Name = "UICorner"
leakedby32e4_UICorner17.CornerRadius = UDim.new(0, 10)
leakedby32e4_UICorner17.Parent = leakedby32e4_Frame19

local leakedby32e4_UIStroke7 = Instance.new("UIStroke")
leakedby32e4_UIStroke7.Name = "UIStroke"
leakedby32e4_UIStroke7.Color = leakedby32e4_C.stroke
leakedby32e4_UIStroke7.Parent = leakedby32e4_Frame19

local leakedby32e4_Frame20 = Instance.new("Frame")
leakedby32e4_Frame20.Name = "Frame"
leakedby32e4_Frame20.SelectionGroup = false
leakedby32e4_Frame20.Size = UDim2.new(0, 40, 0, 40)
leakedby32e4_Frame20.Position = UDim2.new(0.5, -20, 0, 18)
leakedby32e4_Frame20.BackgroundColor3 = leakedby32e4_C.iconBg
leakedby32e4_Frame20.BorderSizePixel = 0
leakedby32e4_Frame20.ZIndex = 5
leakedby32e4_Frame20.ClipsDescendants = false
leakedby32e4_Frame20.Active = false
leakedby32e4_Frame20.Selectable = false
leakedby32e4_Frame20.Parent = leakedby32e4_Frame19

local leakedby32e4_UICorner18 = Instance.new("UICorner")
leakedby32e4_UICorner18.Name = "UICorner"
leakedby32e4_UICorner18.CornerRadius = UDim.new(0, 20)
leakedby32e4_UICorner18.Parent = leakedby32e4_Frame20

local leakedby32e4_UIStroke8 = Instance.new("UIStroke")
leakedby32e4_UIStroke8.Name = "UIStroke"
leakedby32e4_UIStroke8.Color = leakedby32e4_C.stroke
leakedby32e4_UIStroke8.Parent = leakedby32e4_Frame20

local leakedby32e4_TextLabel10 = Instance.new("TextLabel")
leakedby32e4_TextLabel10.Name = "TextLabel"
leakedby32e4_TextLabel10.SelectionGroup = false
leakedby32e4_TextLabel10.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_TextLabel10.BackgroundTransparency = 1
leakedby32e4_TextLabel10.ZIndex = 6
leakedby32e4_TextLabel10.Active = false
leakedby32e4_TextLabel10.Selectable = false
leakedby32e4_TextLabel10.Text = utf8.char(0x26A1)
leakedby32e4_TextLabel10.TextColor3 = leakedby32e4_C.accent
leakedby32e4_TextLabel10.TextSize = 18
leakedby32e4_TextLabel10.Font = Enum.Font.GothamBold
leakedby32e4_TextLabel10.TextScaled = false
leakedby32e4_TextLabel10.TextWrapped = false
leakedby32e4_TextLabel10.RichText = false
leakedby32e4_TextLabel10.Parent = leakedby32e4_Frame20

local leakedby32e4_TextLabel11 = Instance.new("TextLabel")
leakedby32e4_TextLabel11.Name = "TextLabel"
leakedby32e4_TextLabel11.SelectionGroup = false
leakedby32e4_TextLabel11.Size = UDim2.new(1, -16, 0, 22)
leakedby32e4_TextLabel11.Position = UDim2.new(0, 8, 0, 64)
leakedby32e4_TextLabel11.BackgroundTransparency = 1
leakedby32e4_TextLabel11.ZIndex = 5
leakedby32e4_TextLabel11.Active = false
leakedby32e4_TextLabel11.Selectable = false
leakedby32e4_TextLabel11.Text = "No brainrots found"
leakedby32e4_TextLabel11.TextColor3 = leakedby32e4_C.textBright
leakedby32e4_TextLabel11.TextSize = 13
leakedby32e4_TextLabel11.Font = Enum.Font.GothamMedium
leakedby32e4_TextLabel11.TextScaled = false
leakedby32e4_TextLabel11.TextWrapped = false
leakedby32e4_TextLabel11.RichText = false
leakedby32e4_TextLabel11.Parent = leakedby32e4_Frame19

local leakedby32e4_TextLabel12 = Instance.new("TextLabel")
leakedby32e4_TextLabel12.Name = "TextLabel"
leakedby32e4_TextLabel12.SelectionGroup = false
leakedby32e4_TextLabel12.Size = UDim2.new(1, -16, 0, 18)
leakedby32e4_TextLabel12.Position = UDim2.new(0, 8, 0, 86)
leakedby32e4_TextLabel12.BackgroundTransparency = 1
leakedby32e4_TextLabel12.ZIndex = 5
leakedby32e4_TextLabel12.Active = false
leakedby32e4_TextLabel12.Selectable = false
leakedby32e4_TextLabel12.Text = "No brainrots to detect for now"
leakedby32e4_TextLabel12.TextColor3 = leakedby32e4_C.textMute
leakedby32e4_TextLabel12.TextSize = 11
leakedby32e4_TextLabel12.Font = Enum.Font.Gotham
leakedby32e4_TextLabel12.TextScaled = false
leakedby32e4_TextLabel12.TextWrapped = false
leakedby32e4_TextLabel12.RichText = false
leakedby32e4_TextLabel12.Parent = leakedby32e4_Frame19

local leakedby32e4_Frame21 = Instance.new("Frame")
leakedby32e4_Frame21.Name = "Frame"
leakedby32e4_Frame21.SelectionGroup = false
leakedby32e4_Frame21.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_Frame21.Position = UDim2.new(1, 0, 0, 0)
leakedby32e4_Frame21.BackgroundTransparency = 1
leakedby32e4_Frame21.BorderSizePixel = 0
leakedby32e4_Frame21.Visible = false
leakedby32e4_Frame21.ZIndex = 3
leakedby32e4_Frame21.ClipsDescendants = false
leakedby32e4_Frame21.Active = false
leakedby32e4_Frame21.Selectable = false
leakedby32e4_Frame21.Parent = leakedby32e4_Frame16

local leakedby32e4_ScrollingFrame2 = Instance.new("ScrollingFrame")
leakedby32e4_ScrollingFrame2.Name = "ScrollingFrame"
leakedby32e4_ScrollingFrame2.Size = UDim2.new(1, 0, 1, 0)
leakedby32e4_ScrollingFrame2.BackgroundTransparency = 1
leakedby32e4_ScrollingFrame2.BorderSizePixel = 0
leakedby32e4_ScrollingFrame2.Active = false
leakedby32e4_ScrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
leakedby32e4_ScrollingFrame2.ScrollBarThickness = 3
leakedby32e4_ScrollingFrame2.ScrollBarImageColor3 = leakedby32e4_C.accent
leakedby32e4_ScrollingFrame2.ScrollingDirection = Enum.ScrollingDirection.Y
leakedby32e4_ScrollingFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
leakedby32e4_ScrollingFrame2.Parent = leakedby32e4_Frame21

local leakedby32e4_UIListLayout3 = Instance.new("UIListLayout")
leakedby32e4_UIListLayout3.Name = "UIListLayout"
leakedby32e4_UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
leakedby32e4_UIListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
leakedby32e4_UIListLayout3.Padding = UDim.new(0, 4)
leakedby32e4_UIListLayout3.Wraps = false
leakedby32e4_UIListLayout3.Parent = leakedby32e4_ScrollingFrame2

local leakedby32e4_UIPadding = Instance.new("UIPadding")
leakedby32e4_UIPadding.Name = "UIPadding"
leakedby32e4_UIPadding.PaddingTop = UDim.new(0, 10)
leakedby32e4_UIPadding.PaddingBottom = UDim.new(0, 10)
leakedby32e4_UIPadding.PaddingLeft = UDim.new(0, 8)
leakedby32e4_UIPadding.PaddingRight = UDim.new(0, 8)
leakedby32e4_UIPadding.Parent = leakedby32e4_ScrollingFrame2

-- ==================== SETTINGS SECTION ====================
local leakedby32e4_sectionOrder = 0
local function leakedby32e4_sectionHeader(text)
    leakedby32e4_sectionOrder = leakedby32e4_sectionOrder + 1
    local wrap = Instance.new("Frame")
    wrap.Name = "Frame"; wrap.SelectionGroup = false
    wrap.Size = UDim2.new(1, 0, 0, 24); wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel = 0; wrap.ZIndex = 4; wrap.LayoutOrder = leakedby32e4_sectionOrder
    wrap.Active = false; wrap.Selectable = false; wrap.Parent = leakedby32e4_ScrollingFrame2
    local line = Instance.new("Frame")
    line.Name = "Frame"; line.SelectionGroup = false
    line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = leakedby32e4_C.stroke; line.BorderSizePixel = 0; line.ZIndex = 5
    line.Active = false; line.Selectable = false; line.Parent = wrap
    local pill = Instance.new("Frame")
    pill.Name = "Frame"; pill.SelectionGroup = false
    pill.Size = UDim2.new(0, 0, 1, 0); pill.Position = UDim2.new(0.5, 0, 0, 0)
    pill.AnchorPoint = Vector2.new(0.5, 0); pill.BackgroundColor3 = leakedby32e4_C.panel
    pill.BorderSizePixel = 0; pill.ZIndex = 6; pill.AutomaticSize = Enum.AutomaticSize.X
    pill.Active = false; pill.Selectable = false; pill.Parent = wrap
    local lbl = Instance.new("TextLabel")
    lbl.Name = "TextLabel"; lbl.SelectionGroup = false
    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.ZIndex = 7
    lbl.Active = false; lbl.Selectable = false
    lbl.Text = text; lbl.TextColor3 = leakedby32e4_C.textMute; lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = false; lbl.TextWrapped = false; lbl.RichText = false
    lbl.Parent = pill
    return wrap
end

local function leakedby32e4_toggleRow(title, desc, defaultOn, onToggle)
    leakedby32e4_sectionOrder = leakedby32e4_sectionOrder + 1
    local row = Instance.new("Frame")
    row.Name = "Frame"; row.SelectionGroup = false
    row.Size = UDim2.new(1, 0, 0, 52); row.BackgroundColor3 = leakedby32e4_C.card
    row.BorderSizePixel = 0; row.ZIndex = 4; row.LayoutOrder = leakedby32e4_sectionOrder
    row.Active = false; row.Selectable = false; row.Parent = leakedby32e4_ScrollingFrame2
    local c = Instance.new("UICorner"); c.Name = "UICorner"; c.Parent = row
    local s = Instance.new("UIStroke"); s.Name = "UIStroke"; s.Color = leakedby32e4_C.stroke; s.Parent = row

    local accentBar = Instance.new("Frame")
    accentBar.Name = "Frame"; accentBar.SelectionGroup = false
    accentBar.Size = UDim2.new(0, 3, 1, -10); accentBar.Position = UDim2.new(0, 0, 0, 5)
    accentBar.BackgroundColor3 = leakedby32e4_C.accent; accentBar.BorderSizePixel = 0; accentBar.ZIndex = 5
    accentBar.Active = false; accentBar.Selectable = false; accentBar.Parent = row
    local abc = Instance.new("UICorner"); abc.Name = "UICorner"; abc.CornerRadius = UDim.new(0, 2); abc.Parent = accentBar

    local t1 = Instance.new("TextLabel")
    t1.Name = "TextLabel"; t1.SelectionGroup = false
    t1.Size = UDim2.new(1, -52, 0, 24); t1.Position = UDim2.new(0, 12, 0, 0)
    t1.BackgroundTransparency = 1; t1.ZIndex = 5; t1.Active = false; t1.Selectable = false
    t1.Text = title; t1.TextColor3 = leakedby32e4_C.textBright; t1.TextSize = 13
    t1.Font = Enum.Font.GothamMedium
    t1.TextScaled = false; t1.TextWrapped = false; t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.RichText = false; t1.Parent = row

    local t2 = Instance.new("TextLabel")
    t2.Name = "TextLabel"; t2.SelectionGroup = false
    t2.Size = UDim2.new(1, -52, 0, 20); t2.Position = UDim2.new(0, 12, 0, 22)
    t2.BackgroundTransparency = 1; t2.ZIndex = 5; t2.Active = false; t2.Selectable = false
    t2.Text = desc; t2.TextColor3 = leakedby32e4_C.textMute; t2.TextSize = 11
    t2.Font = Enum.Font.Gotham
    t2.TextScaled = false; t2.TextWrapped = true; t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.RichText = false; t2.Parent = row

    local track = Instance.new("Frame")
    track.Name = "Frame"; track.SelectionGroup = false
    track.Size = UDim2.new(0, 36, 0, 20); track.Position = UDim2.new(1, -42, 0.5, -10)
    track.BackgroundColor3 = leakedby32e4_C.accent; track.BorderSizePixel = 0; track.ZIndex = 6
    track.Active = false; track.Selectable = false; track.Parent = row
    local tc = Instance.new("UICorner"); tc.Name = "UICorner"; tc.CornerRadius = UDim.new(0, 10); tc.Parent = track
    local ts = Instance.new("UIStroke"); ts.Name = "UIStroke"; ts.Color = leakedby32e4_C.accent; ts.Parent = track

    local knob = Instance.new("Frame")
    knob.Name = "Frame"; knob.SelectionGroup = false
    knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(0, 19, 0.5, -7)
    knob.BackgroundColor3 = leakedby32e4_C.knobOn; knob.BorderSizePixel = 0; knob.ZIndex = 7
    knob.Active = false; knob.Selectable = false; knob.Parent = track
    local kc = Instance.new("UICorner"); kc.Name = "UICorner"; kc.CornerRadius = UDim.new(0, 7); kc.Parent = knob

    local hit = Instance.new("TextButton")
    hit.Name = "TextButton"; hit.SelectionGroup = false
    hit.Size = UDim2.new(1, 0, 1, 0); hit.BackgroundTransparency = 1; hit.ZIndex = 8
    hit.Text = ""; hit.TextScaled = false; hit.TextWrapped = false; hit.RichText = false
    hit.Parent = row

    local ref = { on = defaultOn == true, track = track, stroke = ts, knob = knob }
    local function render(animate)
        local info = TweenInfo.new(animate and 0.16 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if ref.on then
            leakedby32e4_TweenService:Create(track, info, { BackgroundColor3 = leakedby32e4_C.accent }):Play()
            leakedby32e4_TweenService:Create(ts, info, { Color = leakedby32e4_C.accent }):Play()
            leakedby32e4_TweenService:Create(knob, info, { Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = leakedby32e4_C.knobOn }):Play()
        else
            leakedby32e4_TweenService:Create(track, info, { BackgroundColor3 = leakedby32e4_C.trackOff }):Play()
            leakedby32e4_TweenService:Create(ts, info, { Color = leakedby32e4_C.stroke }):Play()
            leakedby32e4_TweenService:Create(knob, info, { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = leakedby32e4_C.knobOff }):Play()
        end
    end
    render(false)

    if onToggle then task.defer(function() pcall(onToggle, ref.on) end) end
    hit.MouseButton1Click:Connect(function()
        ref.on = not ref.on
        render(true)
        if onToggle then pcall(onToggle, ref.on) end
    end)
    return row, ref
end

-- Build Settings Page
leakedby32e4_sectionHeader("  WHALEHUB FEATURES  ")
leakedby32e4_toggleRow("Auto Block", "Automatically blocks target after grab", false, function(v) leakedby32e4_AutoBlockEnabled = v; pcall(leakedby32e4_ShowToggleNotification, "Auto Block", v) end)
leakedby32e4_toggleRow("Auto Flash", "Automatically flashes on enemies", false, function(v) leakedby32e4_AutoFlashEnabled = v; pcall(leakedby32e4_ShowToggleNotification, "Auto Flash", v) end)
leakedby32e4_toggleRow("Auto Potion", "Automatically uses Giant Potion after block", false, function(v) leakedby32e4_AutoPotionEnabled = v; pcall(leakedby32e4_ShowToggleNotification, "Auto Potion", v) end)

leakedby32e4_sectionHeader("  RAGDOLL PROTECTION  ")
leakedby32e4_toggleRow("Anti Ragdoll", "Prevents ragdoll effects", false, function(v) if v then leakedby32e4_AntiRagdoll.enable() else leakedby32e4_AntiRagdoll.disable() end; pcall(leakedby32e4_ShowToggleNotification, "Anti Ragdoll", v) end)
leakedby32e4_toggleRow("Ragdoll Bypass", "Bypasses ragdoll effects on your character", false, function(v) leakedby32e4_RagdollBypassEnabled = v; pcall(leakedby32e4_ShowToggleNotification, "Ragdoll Bypass", v) end)

leakedby32e4_sectionHeader("  BRAINROT  ")
leakedby32e4_toggleRow("Auto Select Best", "Auto-selects highest gen animal", false, function(v) 
    leakedby32e4_AutoSelectBestBrainrot = v
    pcall(leakedby32e4_ShowToggleNotification, "Auto Select Best", v)
    if v and _G._FH_LastAnimalScan and #_G._FH_LastAnimalScan > 0 then
        pcall(_G._FH_AutoSelectBest)
    end
end)

-- ==================== BANNER GUI ====================
local leakedby32e4_CyberHubBanner = Instance.new("ScreenGui")
leakedby32e4_CyberHubBanner.Name = "CyberHubBanner"
leakedby32e4_CyberHubBanner.SelectionGroup = false
leakedby32e4_CyberHubBanner.ResetOnSpawn = false
leakedby32e4_CyberHubBanner.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
leakedby32e4_CyberHubBanner.IgnoreGuiInset = false
leakedby32e4_CyberHubBanner.Parent = leakedby32e4_PlayerGui

local leakedby32e4_BFrame = Instance.new("Frame")
leakedby32e4_BFrame.Name = "Frame"
leakedby32e4_BFrame.SelectionGroup = false
leakedby32e4_BFrame.Size = UDim2.new(0, 302, 0, 82)
leakedby32e4_BFrame.Position = UDim2.new(0.5, -151, 0, 60)
leakedby32e4_BFrame.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_BFrame.BorderSizePixel = 0
leakedby32e4_BFrame.ClipsDescendants = false
leakedby32e4_BFrame.Active = false
leakedby32e4_BFrame.Selectable = false
leakedby32e4_BFrame.Parent = leakedby32e4_CyberHubBanner

local leakedby32e4_BUICorner = Instance.new("UICorner")
leakedby32e4_BUICorner.Name = "UICorner"
leakedby32e4_BUICorner.CornerRadius = UDim.new(0, 12)
leakedby32e4_BUICorner.Parent = leakedby32e4_BFrame

local leakedby32e4_BUIGradient = Instance.new("UIGradient")
leakedby32e4_BUIGradient.Name = "UIGradient"
leakedby32e4_BUIGradient.Color = leakedby32e4_borderGradientSeq
leakedby32e4_BUIGradient.Rotation = 224.297
leakedby32e4_BUIGradient.Parent = leakedby32e4_BFrame

local leakedby32e4_BFrame2 = Instance.new("Frame")
leakedby32e4_BFrame2.Name = "Frame"
leakedby32e4_BFrame2.SelectionGroup = false
leakedby32e4_BFrame2.Size = UDim2.new(0, 298, 0, 78)
leakedby32e4_BFrame2.Position = UDim2.new(0, 2, 0, 2)
leakedby32e4_BFrame2.BackgroundColor3 = leakedby32e4_C.panel
leakedby32e4_BFrame2.BackgroundTransparency = 0.15
leakedby32e4_BFrame2.BorderSizePixel = 0
leakedby32e4_BFrame2.ClipsDescendants = false
leakedby32e4_BFrame2.Active = false
leakedby32e4_BFrame2.Selectable = false
leakedby32e4_BFrame2.Parent = leakedby32e4_BFrame

local leakedby32e4_BUICorner2 = Instance.new("UICorner")
leakedby32e4_BUICorner2.Name = "UICorner"
leakedby32e4_BUICorner2.CornerRadius = UDim.new(0, 10)
leakedby32e4_BUICorner2.Parent = leakedby32e4_BFrame2

local leakedby32e4_BFrame3 = Instance.new("Frame")
leakedby32e4_BFrame3.Name = "Frame"
leakedby32e4_BFrame3.SelectionGroup = false
leakedby32e4_BFrame3.Size = UDim2.new(1, -20, 0, 1)
leakedby32e4_BFrame3.Position = UDim2.new(0, 10, 0, 8)
leakedby32e4_BFrame3.BackgroundColor3 = leakedby32e4_C.stroke
leakedby32e4_BFrame3.BorderSizePixel = 0
leakedby32e4_BFrame3.ClipsDescendants = false
leakedby32e4_BFrame3.Active = false
leakedby32e4_BFrame3.Selectable = false
leakedby32e4_BFrame3.Parent = leakedby32e4_BFrame2

local leakedby32e4_BFrame4 = Instance.new("Frame")
leakedby32e4_BFrame4.Name = "Frame"
leakedby32e4_BFrame4.SelectionGroup = false
leakedby32e4_BFrame4.Size = UDim2.new(0, 6, 0, 6)
leakedby32e4_BFrame4.Position = UDim2.new(0, 10, 0, 16)
leakedby32e4_BFrame4.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_BFrame4.BorderSizePixel = 0
leakedby32e4_BFrame4.ClipsDescendants = false
leakedby32e4_BFrame4.Active = false
leakedby32e4_BFrame4.Selectable = false
leakedby32e4_BFrame4.Parent = leakedby32e4_BFrame2

local leakedby32e4_BUICorner3 = Instance.new("UICorner")
leakedby32e4_BUICorner3.Name = "UICorner"
leakedby32e4_BUICorner3.Parent = leakedby32e4_BFrame4

local leakedby32e4_BFrame5 = Instance.new("Frame")
leakedby32e4_BFrame5.Name = "Frame"
leakedby32e4_BFrame5.SelectionGroup = false
leakedby32e4_BFrame5.Size = UDim2.new(0, 12, 0, 12)
leakedby32e4_BFrame5.Position = UDim2.new(0, 7, 0, 13)
leakedby32e4_BFrame5.BackgroundColor3 = leakedby32e4_C.accent
leakedby32e4_BFrame5.BackgroundTransparency = 0.75
leakedby32e4_BFrame5.BorderSizePixel = 0
leakedby32e4_BFrame5.ClipsDescendants = false
leakedby32e4_BFrame5.Active = false
leakedby32e4_BFrame5.Selectable = false
leakedby32e4_BFrame5.Parent = leakedby32e4_BFrame2

local leakedby32e4_BUICorner4 = Instance.new("UICorner")
leakedby32e4_BUICorner4.Name = "UICorner"
leakedby32e4_BUICorner4.Parent = leakedby32e4_BFrame5

local leakedby32e4_BTitle = Instance.new("TextLabel")
leakedby32e4_BTitle.Name = "TextLabel"
leakedby32e4_BTitle.SelectionGroup = false
leakedby32e4_BTitle.Size = UDim2.new(1, 0, 0, 30)
leakedby32e4_BTitle.Position = UDim2.new(0, 0, 0, 10)
leakedby32e4_BTitle.BackgroundTransparency = 1
leakedby32e4_BTitle.ClipsDescendants = false
leakedby32e4_BTitle.Active = false
leakedby32e4_BTitle.Selectable = false
leakedby32e4_BTitle.Text = "<font color=\"rgb(220,235,255)\">CYBER</font> <font color=\"rgb(50,120,255)\">HUB</font>"
leakedby32e4_BTitle.TextSize = 20
leakedby32e4_BTitle.Font = Enum.Font.GothamBold
leakedby32e4_BTitle.TextScaled = false
leakedby32e4_BTitle.TextWrapped = false
leakedby32e4_BTitle.RichText = true
leakedby32e4_BTitle.Parent = leakedby32e4_BFrame2

local leakedby32e4_BStats = Instance.new("TextLabel")
leakedby32e4_BStats.Name = "TextLabel"
leakedby32e4_BStats.SelectionGroup = false
leakedby32e4_BStats.Size = UDim2.new(1, 0, 0, 18)
leakedby32e4_BStats.Position = UDim2.new(0, 0, 0, 40)
leakedby32e4_BStats.BackgroundTransparency = 1
leakedby32e4_BStats.ClipsDescendants = false
leakedby32e4_BStats.Active = false
leakedby32e4_BStats.Selectable = false
leakedby32e4_BStats.Text = "<font color=\"rgb(50,120,255)\">FPS:</font> 60   <font color=\"rgb(50,120,255)\">PING:</font> 35ms"
leakedby32e4_BStats.TextColor3 = leakedby32e4_C.textBright
leakedby32e4_BStats.TextSize = 12
leakedby32e4_BStats.Font = Enum.Font.GothamMedium
leakedby32e4_BStats.TextScaled = false
leakedby32e4_BStats.TextWrapped = false
leakedby32e4_BStats.RichText = true
leakedby32e4_BStats.Parent = leakedby32e4_BFrame2

local leakedby32e4_BDiscord = Instance.new("TextLabel")
leakedby32e4_BDiscord.Name = "TextLabel"
leakedby32e4_BDiscord.SelectionGroup = false
leakedby32e4_BDiscord.Size = UDim2.new(1, 0, 0, 14)
leakedby32e4_BDiscord.Position = UDim2.new(0, 0, 0, 60)
leakedby32e4_BDiscord.BackgroundTransparency = 1
leakedby32e4_BDiscord.ClipsDescendants = false
leakedby32e4_BDiscord.Active = false
leakedby32e4_BDiscord.Selectable = false
leakedby32e4_BDiscord.Text = "discord.gg/cyberhub"
leakedby32e4_BDiscord.TextColor3 = leakedby32e4_C.textMute
leakedby32e4_BDiscord.TextSize = 11
leakedby32e4_BDiscord.Font = Enum.Font.Gotham
leakedby32e4_BDiscord.TextScaled = false
leakedby32e4_BDiscord.TextWrapped = false
leakedby32e4_BDiscord.RichText = false
leakedby32e4_BDiscord.Parent = leakedby32e4_BFrame2

-- Gradient animation
task.spawn(function()
    local base1, base2 = leakedby32e4_UIGradient.Rotation, leakedby32e4_BUIGradient.Rotation
    while leakedby32e4_UIGradient.Parent and leakedby32e4_BUIGradient.Parent do
        local t = os.clock()
        leakedby32e4_UIGradient.Rotation = (base1 + t * 60) % 360
        leakedby32e4_BUIGradient.Rotation = (base2 + t * 60) % 360
        leakedby32e4_RunService.RenderStepped:Wait()
    end
end)

-- ==================== WINDOW MANAGEMENT ====================
local function leakedby32e4_syncBorder()
    leakedby32e4_BorderFrame.Position = leakedby32e4_Win.Position
end

do
    local dragging, dragStart, startPos
    local function begin(input)
        dragging = true
        dragStart = input.Position
        startPos = leakedby32e4_Win.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
    leakedby32e4_Frame3.Active = true
    leakedby32e4_Frame3.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then begin(input) end
    end)
    leakedby32e4_UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            leakedby32e4_Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                     startPos.Y.Scale, startPos.Y.Offset + d.Y)
            leakedby32e4_syncBorder()
        end
    end)
end

local leakedby32e4_activeTab = "brainrots"
local function leakedby32e4_setTab(tab)
    if tab == leakedby32e4_activeTab then return end
    leakedby32e4_activeTab = tab
    local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if tab == "settings" then
        leakedby32e4_Frame21.Visible = true
        leakedby32e4_Frame21.Position = UDim2.new(1, 0, 0, 0)
        leakedby32e4_TweenService:Create(leakedby32e4_Frame17, info, { Position = UDim2.new(-1, 0, 0, 0) }):Play()
        leakedby32e4_TweenService:Create(leakedby32e4_Frame21, info, { Position = UDim2.new(0, 0, 0, 0) }):Play()
        leakedby32e4_TextLabel7.TextColor3 = leakedby32e4_C.textDim
        leakedby32e4_TextLabel8.TextColor3 = leakedby32e4_C.textBlue
        leakedby32e4_TweenService:Create(leakedby32e4_Frame13, info, { BackgroundTransparency = 1 }):Play()
        leakedby32e4_TweenService:Create(leakedby32e4_Frame14, info, { BackgroundTransparency = 0 }):Play()
    else
        leakedby32e4_Frame17.Visible = true
        leakedby32e4_Frame17.Position = UDim2.new(-1, 0, 0, 0)
        leakedby32e4_TweenService:Create(leakedby32e4_Frame17, info, { Position = UDim2.new(0, 0, 0, 0) }):Play()
        leakedby32e4_TweenService:Create(leakedby32e4_Frame21, info, { Position = UDim2.new(1, 0, 0, 0) }):Play()
        leakedby32e4_TextLabel7.TextColor3 = leakedby32e4_C.textBlue
        leakedby32e4_TextLabel8.TextColor3 = leakedby32e4_C.textDim
        leakedby32e4_TweenService:Create(leakedby32e4_Frame13, info, { BackgroundTransparency = 0 }):Play()
        leakedby32e4_TweenService:Create(leakedby32e4_Frame14, info, { BackgroundTransparency = 1 }):Play()
        task.delay(0.22, function() if leakedby32e4_activeTab == "brainrots" then leakedby32e4_Frame21.Visible = false end end)
    end
end

leakedby32e4_Frame17.Position = UDim2.new(0, 0, 0, 0)
leakedby32e4_TextButton4.MouseButton1Click:Connect(function() leakedby32e4_setTab("brainrots") end)
leakedby32e4_TextButton5.MouseButton1Click:Connect(function() leakedby32e4_setTab("settings") end)

local leakedby32e4_locked = false
leakedby32e4_LockBtn.MouseButton1Click:Connect(function()
    leakedby32e4_locked = not leakedby32e4_locked
    leakedby32e4_LockBtn.Text = leakedby32e4_locked and utf8.char(0x1F512) or utf8.char(0x1F513)
    leakedby32e4_Frame3.Active = not leakedby32e4_locked
    leakedby32e4_LockBtn.TextColor3 = leakedby32e4_locked and leakedby32e4_C.accent or leakedby32e4_C.textMute
end)

local leakedby32e4_minimised = false
local leakedby32e4_fullSize = leakedby32e4_Win.Size
local leakedby32e4_fullBorder = leakedby32e4_BorderFrame.Size

local MIN_WIN_H = 88
local MIN_BORDER_H = MIN_WIN_H + 4
leakedby32e4_MinBtn.MouseButton1Click:Connect(function()
    leakedby32e4_minimised = not leakedby32e4_minimised
    leakedby32e4_MinBtn.Text = leakedby32e4_minimised and "+" or "-"
    local info = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if leakedby32e4_minimised then
        leakedby32e4_TweenService:Create(leakedby32e4_Win, info, { Size = UDim2.new(0, 310, 0, MIN_WIN_H) }):Play()
        leakedby32e4_TweenService:Create(leakedby32e4_BorderFrame, info, { Size = UDim2.new(0, 314, 0, MIN_BORDER_H) }):Play()
    else
        leakedby32e4_TweenService:Create(leakedby32e4_Win, info, { Size = leakedby32e4_fullSize }):Play()
        leakedby32e4_TweenService:Create(leakedby32e4_BorderFrame, info, { Size = leakedby32e4_fullBorder }):Play()
    end
end)

leakedby32e4_CloseBtn.MouseButton1Click:Connect(function()
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local t1 = leakedby32e4_TweenService:Create(leakedby32e4_Win, info, { Size = UDim2.new(0, 0, 0, 0) })
    local t2 = leakedby32e4_TweenService:Create(leakedby32e4_BorderFrame, info, { Size = UDim2.new(0, 0, 0, 0) })
    t1:Play(); t2:Play()
    t1.Completed:Connect(function() leakedby32e4_CyberPVP:Destroy() end)
end)

local function leakedby32e4_hookButton(btn, normal, hover)
    btn.MouseEnter:Connect(function()
        leakedby32e4_TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = hover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        leakedby32e4_TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = normal }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        leakedby32e4_TweenService:Create(btn, TweenInfo.new(0.06), { BackgroundColor3 = leakedby32e4_C.deepBlue }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        leakedby32e4_TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = hover }):Play()
    end)
end
leakedby32e4_hookButton(leakedby32e4_FLASHTP, leakedby32e4_C.card, leakedby32e4_C.iconBg)
leakedby32e4_hookButton(leakedby32e4_BLOCK, leakedby32e4_C.card, leakedby32e4_C.iconBg)
leakedby32e4_hookButton(leakedby32e4_RESET, leakedby32e4_C.card, leakedby32e4_C.iconBg)
for _, b in ipairs({ leakedby32e4_LockBtn, leakedby32e4_MinBtn, leakedby32e4_CloseBtn }) do leakedby32e4_hookButton(b, leakedby32e4_C.card, leakedby32e4_C.iconBg) end

local function leakedby32e4_flashBar(bar)
    bar.BackgroundColor3 = leakedby32e4_C.accentHi
    leakedby32e4_TweenService:Create(bar, TweenInfo.new(0.4), { BackgroundColor3 = leakedby32e4_C.stroke }):Play()
end
leakedby32e4_FLASHTP.MouseButton1Click:Connect(function() pcall(leakedby32e4_doFlash); leakedby32e4_flashBar(leakedby32e4_flashAccent) end)
leakedby32e4_BLOCK.MouseButton1Click:Connect(function() pcall(leakedby32e4_doBlock); leakedby32e4_flashBar(leakedby32e4_blockAccent) end)
leakedby32e4_RESET.MouseButton1Click:Connect(function() pcall(leakedby32e4_doReset); leakedby32e4_flashBar(leakedby32e4_resetAccent) end)

-- ==================== FPS/PING DISPLAY ====================
do
    local frameTimes = {}
    local fpsConn
    fpsConn = leakedby32e4_RunService.RenderStepped:Connect(function()
        if not leakedby32e4_BStats.Parent then
            fpsConn:Disconnect()
            return
        end
        local now = os.clock()
        table.insert(frameTimes, now)

        while frameTimes[1] and now - frameTimes[1] > 1 do
            table.remove(frameTimes, 1)
        end
    end)

    task.spawn(function()
        while leakedby32e4_BStats.Parent do
            local fps = #frameTimes

            if fps < 2 and frameTimes[1] then
                local span = os.clock() - frameTimes[1]
                if span > 0 then fps = math.floor(#frameTimes / span + 0.5) end
            end

            local ping = 0
            pcall(function()
                ping = math.floor(leakedby32e4_Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)

            leakedby32e4_BStats.Text = string.format(
                "<font color=\"rgb(50,120,255)\">FPS:</font> %d   <font color=\"rgb(50,120,255)\">PING:</font> %dms",
                fps, ping)
            task.wait(0.25)
        end
    end)
end

-- ==================== BRAINROT SCANNER (Blue Theme Cards) ====================
do
    local RS = leakedby32e4_ReplicatedStorage
    local WS = workspace

    local AnimalsData = _G._FH_AG_AnimalsData
    local AnimalsShared = _G._FH_AG_AnimalsShared
    local NumberUtils = _G._FH_AG_NumberUtils
    if not AnimalsData then pcall(function() AnimalsData = require(RS:WaitForChild("Datas",30):WaitForChild("Animals",30)) end) end
    if not NumberUtils then pcall(function() NumberUtils = require(RS:WaitForChild("Utils",30):WaitForChild("NumberUtils",30)) end) end
    if not AnimalsShared then pcall(function() AnimalsShared = require(RS:WaitForChild("Shared",30):WaitForChild("Animals",30)) end) end

    local RequestData = _G._FH_AG_SyncRemotes and _G._FH_AG_SyncRemotes.requestData
    if not RequestData then
        pcall(function()
            local pkg = RS:WaitForChild("Packages",15):WaitForChild("Synchronizer",15)
            RequestData = pkg:FindFirstChild("RequestData")
        end)
    end
    local PlotSyncCaches = (_G._FH_AG_PlotSync and _G._FH_AG_PlotSync.caches) or {}

    local function fmtNum(n)
        if NumberUtils and NumberUtils.ToString then
            local ok,s = pcall(function() return NumberUtils:ToString(n) end)
            if ok and s then return s end
        end
        return tostring(n)
    end
    local function getGeneration(index, mutation, traits)
        if not (AnimalsShared and AnimalsShared.GetGeneration) then return 0 end
        local ok,v = pcall(function() return AnimalsShared:GetGeneration(index,mutation,traits,nil) end)
        if not ok or not v then ok,v = pcall(function() return AnimalsShared:GetGeneration(index,mutation,nil,nil) end) end
        if not ok or not v then ok,v = pcall(function() return AnimalsShared:GetGeneration(index) end) end
        return (ok and v) or 0
    end
    local function displayName(index)
        local info = AnimalsData and AnimalsData[index]
        return (info and info.DisplayName) or tostring(index)
    end
    local function isMyPlot(plot)
        local sign = plot:FindFirstChild("PlotSign")
        return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled or false
    end
    local function plotOwner(plot)
        local sign = plot:FindFirstChild("PlotSign",true)
        if sign then
            for _,d in ipairs(sign:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and d.Text ~= "" then
                    local t = d.Text
                    if t:lower():find("empty") then return "Empty" end
                    local m = t:match("[Bb]ase [Oo]f%s+(.+)")
                    if m then return m end
                    if #t > 0 and #t < 30 then return t end
                end
            end
        end
        local s2 = plot:FindFirstChild("PlotSign")
        return (s2 and s2:FindFirstChild("YourBase") and s2.YourBase.Enabled) and "YOU" or "?"
    end
    local function getPodiumExists(plot, slot)
        local podiums = plot:FindFirstChild("AnimalPodiums")
        return podiums and podiums:FindFirstChild(tostring(slot)) ~= nil
    end
    local function getPlotOrder(plot)
        local order = pcall(function() return plot:GetAttribute("Order") end) and plot:GetAttribute("Order")
        if order then return "Base " .. tostring(order) end
        local lp = leakedby32e4_LocalPlayer
        if lp then
            local ok, v = pcall(function() return lp:GetAttribute(plot.Name .. "_Order") end)
            if ok and v then return "Base " .. tostring(v) end
            local ok2, v2 = pcall(function() return lp:GetAttribute("Order") end)
            if ok2 and v2 then return "Base " .. tostring(v2) end
        end
        return plot.Name
    end
    local function getAnimalList(plot)
        if RequestData then
            PlotSyncCaches[plot.Name] = nil
            local ok, data = pcall(function() return RequestData:InvokeServer(plot.Name) end)
            if ok and typeof(data) == "table" then
                PlotSyncCaches[plot.Name] = data
                if typeof(data.AnimalList) == "table" then return data.AnimalList end
            end
        end
        local cache = PlotSyncCaches[plot.Name]
        if cache and typeof(cache.AnimalList) == "table" then return cache.AnimalList end
        return nil
    end

    local function scanAllAnimals()
        local results = {}
        local plotsFolder = WS:FindFirstChild("Plots")
        if not plotsFolder then return results end
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            if not plot:IsA("Model") then continue end
            if isMyPlot(plot) then continue end
            pcall(function()
                local animalList = getAnimalList(plot)
                if typeof(animalList) ~= "table" then return end
                local owner = plotOwner(plot)
                for slot, data in pairs(animalList) do
                    pcall(function()
                        if typeof(data)=="table" and data.Index then
                            local podiumExists = getPodiumExists(plot, slot)
                            local gen = getGeneration(data.Index, data.Mutation, data.Traits)
                            table.insert(results, {
                                name = displayName(data.Index),
                                animalIndex = data.Index,
                                mutation = data.Mutation,
                                traits = data.Traits,
                                genValue = gen,
                                genText = "$"..fmtNum(gen).."/s",
                                plotName = plot.Name,
                                plotOrder = getPlotOrder(plot),
                                owner = owner,
                                slot = tostring(slot),
                                podiumExists = podiumExists,
                            })
                        end
                    end)
                end
            end)
        end
        table.sort(results, function(a,b) return (a.genValue or 0)>(b.genValue or 0) end)
        return results
    end

    local selectedUID = nil
    local onSelectCBs = {}
    local builtUIDs = {}
    local labelUpdaters = {}
    local animalsContainer = leakedby32e4_ScrollingFrame

    -- Blue themed card builder
    local function buildAnimalCard(rec, index)
        local uid = rec.plotName .. "_" .. rec.slot

        local card = leakedby32e4_create("Frame", {
            Name = "Card_" .. uid,
            Size = UDim2.new(1, 0, 0, 68),
            BackgroundColor3 = Color3.fromRGB(14, 20, 40),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            LayoutOrder = index,
        })
        leakedby32e4_create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = card
        local cStroke = leakedby32e4_create("UIStroke", { Color = Color3.fromRGB(30, 50, 100), ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
        cStroke.Parent = card

        local accent = leakedby32e4_create("Frame", {
            Size = UDim2.new(0, 4, 0, 52), Position = UDim2.new(0, 0, 0, 8),
            BackgroundColor3 = Color3.fromRGB(50, 120, 255), BorderSizePixel = 0, ZIndex = 2,
        })
        leakedby32e4_create("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = accent
        accent.Parent = card

        local nameLbl = leakedby32e4_create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 14), Position = UDim2.new(0, 12, 0, 7),
            BackgroundTransparency = 1, ZIndex = 4, Text = rec.name,
            TextColor3 = Color3.fromRGB(220, 235, 255), TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        nameLbl.Parent = card

        local mutText = "Mut: " .. (rec.mutation and tostring(rec.mutation) or "None")
        local mutLbl = leakedby32e4_create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 12), Position = UDim2.new(0, 12, 0, 22),
            BackgroundTransparency = 1, ZIndex = 4, Text = mutText,
            TextColor3 = Color3.fromRGB(100, 170, 255), TextSize = 8,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        mutLbl.Parent = card

        local genLbl = leakedby32e4_create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 12), Position = UDim2.new(0, 12, 0, 35),
            BackgroundTransparency = 1, ZIndex = 4, Text = "Gen: " .. rec.genText,
            TextColor3 = Color3.fromRGB(86, 196, 128), TextSize = 8,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        genLbl.Parent = card

        local orderText = (rec.plotOrder or rec.plotName) .. "  Â·  Slot #" .. rec.slot
        local podiumLbl = leakedby32e4_create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 10), Position = UDim2.new(0, 12, 0, 49),
            BackgroundTransparency = 1, ZIndex = 4, Text = orderText,
            TextColor3 = Color3.fromRGB(80, 110, 170), TextSize = 7,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        podiumLbl.Parent = card

        local selBtn = leakedby32e4_create("TextButton", {
            Size = UDim2.new(0, 48, 0, 20),
            Position = UDim2.new(1, -56, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(14, 24, 55),
            BorderSizePixel = 0, ZIndex = 5,
            Text = "SELECT", TextSize = 7,
            TextColor3 = Color3.fromRGB(100, 170, 255),
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
        })
        leakedby32e4_create("UICorner", { CornerRadius = UDim.new(0, 5) }).Parent = selBtn
        local selStroke = leakedby32e4_create("UIStroke", { Color = Color3.fromRGB(30, 50, 100), ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
        selStroke.Parent = selBtn
        selBtn.Parent = card

        local isSelected = false
        local tweenF = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local function applySelectedVisual(v)
            isSelected = v
            if v then
                leakedby32e4_TweenService:Create(selBtn, tweenF, { BackgroundColor3 = Color3.fromRGB(50, 120, 255) }):Play()
                leakedby32e4_TweenService:Create(selStroke, tweenF, { Color = Color3.fromRGB(50, 120, 255) }):Play()
                leakedby32e4_TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(50, 120, 255) }):Play()
                leakedby32e4_TweenService:Create(accent, tweenF, { BackgroundColor3 = Color3.fromRGB(80, 160, 255) }):Play()
                leakedby32e4_TweenService:Create(card, tweenF, { BackgroundColor3 = Color3.fromRGB(20, 28, 50) }):Play()
                selBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
                selBtn.Text = "SELECTED"
            else
                leakedby32e4_TweenService:Create(selBtn, tweenF, { BackgroundColor3 = Color3.fromRGB(14, 24, 55) }):Play()
                leakedby32e4_TweenService:Create(selStroke, tweenF, { Color = Color3.fromRGB(30, 50, 100) }):Play()
                leakedby32e4_TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(30, 50, 100) }):Play()
                leakedby32e4_TweenService:Create(accent, tweenF, { BackgroundColor3 = Color3.fromRGB(50, 120, 255) }):Play()
                leakedby32e4_TweenService:Create(card, tweenF, { BackgroundColor3 = Color3.fromRGB(14, 20, 40) }):Play()
                selBtn.TextColor3 = Color3.fromRGB(100, 170, 255)
                selBtn.Text = "SELECT"
            end
        end

        onSelectCBs[uid] = function(forceOff)
            if forceOff and isSelected then applySelectedVisual(false) end
        end

        local function programmaticSelect()
            if isSelected then return end
            if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
            applySelectedVisual(true)
            selectedUID = uid
            _G._FH_SelectedBrainrot = {
                uid = uid, name = rec.name, mutation = rec.mutation,
                gen = rec.genValue, genText = rec.genText,
                plotName = rec.plotName, slot = rec.slot, owner = rec.owner,
            }
            leakedby32e4_TextLabel9.Text = "Selected: " .. rec.name .. " (Gen: " .. rec.genText .. ")"
        end

        if not _G._FH_CardSelectFns then _G._FH_CardSelectFns = {} end
        _G._FH_CardSelectFns[uid] = programmaticSelect

        selBtn.MouseButton1Click:Connect(function()
            if isSelected then
                applySelectedVisual(false)
                selectedUID = nil
                _G._FH_SelectedBrainrot = nil
                leakedby32e4_TextLabel9.Text = "Nothing selected"
            else
                if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
                applySelectedVisual(true)
                selectedUID = uid
                _G._FH_SelectedBrainrot = {
                    uid = uid, name = rec.name, mutation = rec.mutation,
                    gen = rec.genValue, genText = rec.genText,
                    plotName = rec.plotName, slot = rec.slot, owner = rec.owner,
                }
                leakedby32e4_TextLabel9.Text = "Selected: " .. rec.name .. " (Gen: " .. rec.genText .. ")"
            end
        end)

        card.MouseEnter:Connect(function()
            if not isSelected then
                leakedby32e4_TweenService:Create(card, tweenF, { BackgroundColor3 = Color3.fromRGB(18, 26, 48) }):Play()
                leakedby32e4_TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(40, 65, 130) }):Play()
            end
        end)
        card.MouseLeave:Connect(function()
            if not isSelected then
                leakedby32e4_TweenService:Create(card, tweenF, { BackgroundColor3 = Color3.fromRGB(14, 20, 40) }):Play()
                leakedby32e4_TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(30, 50, 100) }):Play()
            end
        end)

        labelUpdaters[uid] = function(newRec, newIndex)
            mutLbl.Text = "Mut: " .. (newRec.mutation and tostring(newRec.mutation) or "None")
            genLbl.Text = "Gen: " .. newRec.genText
            podiumLbl.Text = (newRec.plotOrder or newRec.plotName) .. "  Â·  Slot #" .. newRec.slot
            card.LayoutOrder = newIndex
        end

        return card
    end

    local scanning = false

    local function doScan()
        if scanning then return end
        scanning = true
        task.spawn(function()
            local ok, results = pcall(scanAllAnimals)
            if not ok or not results then results = {} end
            _G._FH_LastAnimalScan = results

            local seenUIDs = {}
            for _, rec in ipairs(results) do
                seenUIDs[rec.plotName .. "_" .. rec.slot] = true
            end

            for uid, _ in pairs(builtUIDs) do
                if not seenUIDs[uid] then
                    for _, c in ipairs(animalsContainer:GetChildren()) do
                        if c:IsA("Frame") and c.Name == "Card_"..uid then c:Destroy(); break end
                    end
                    builtUIDs[uid] = nil
                    labelUpdaters[uid] = nil
                    onSelectCBs[uid] = nil
                    if selectedUID == uid then
                        selectedUID = nil
                        _G._FH_SelectedBrainrot = nil
                        leakedby32e4_TextLabel9.Text = "Nothing selected"
                    end
                end
            end

            for i, rec in ipairs(results) do
                local uid = rec.plotName .. "_" .. rec.slot
                if not builtUIDs[uid] then
                    local card = buildAnimalCard(rec, i)
                    card.Parent = animalsContainer
                    builtUIDs[uid] = true
                else
                    if labelUpdaters[uid] then labelUpdaters[uid](rec, i) end
                end
            end

            if #results == 0 then
                leakedby32e4_Frame19.Visible = true
            else
                leakedby32e4_Frame19.Visible = false
            end

            scanning = false
        end)
    end

    local function autoSelectBest()
        local results = _G._FH_LastAnimalScan
        if not results or #results == 0 then return end
        local best = results[1]
        if not best then return end
        local uid = best.plotName .. "_" .. best.slot
        if selectedUID == uid then return end
        if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
        selectedUID = uid
        _G._FH_SelectedBrainrot = {
            uid = uid, name = best.name, mutation = best.mutation,
            gen = best.genValue, genText = best.genText,
            plotName = best.plotName, slot = best.slot, owner = best.owner,
        }
        leakedby32e4_TextLabel9.Text = "Selected: " .. best.name .. " (Gen: " .. best.genText .. ")"
        if _G._FH_CardSelectFns and _G._FH_CardSelectFns[uid] then
            pcall(_G._FH_CardSelectFns[uid])
        end
    end
    _G._FH_AutoSelectBest = autoSelectBest

    task.spawn(function()
        task.wait(2)
        while true do
            doScan()
            task.wait(0.05)
            if leakedby32e4_AutoSelectBestBrainrot then pcall(autoSelectBest) end
            task.wait(4.95)
        end
    end)
end

-- ==================== FINAL SETUP ====================
task.spawn(function()
    local target = leakedby32e4_Win.Position
    leakedby32e4_Win.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset)
    leakedby32e4_BorderFrame.Position = leakedby32e4_Win.Position
    leakedby32e4_Win.Visible = true
    leakedby32e4_TweenService:Create(leakedby32e4_Win, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = target }):Play()
    local bt = leakedby32e4_TweenService:Create(leakedby32e4_BorderFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = target })
    bt:Play()
    bt.Completed:Wait()
    leakedby32e4_RunService.RenderStepped:Connect(leakedby32e4_syncBorder)
end)

pcall(leakedby32e4_ShowToggleNotification, "Whalehub V1 Loaded", true)
