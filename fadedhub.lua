-- ══════════════════════════════════════════════════════════════
--  Vertxed Hub  |  Vertex Pvp  |  discord.gg/3JnFzfcYB
--  made by r9qbx
-- ══════════════════════════════════════════════════════════════

-- FPS cap first
pcall(function() setfpscap(9999) end)

-- ── Services ──────────────────────────────────────────────────
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local StarterGui          = game:GetService("StarterGui")
local VirtualInputManager = Instance.new("VirtualInputManager")

-- ── State flags ───────────────────────────────────────────────
local AutoBlockEnabled        = false
local AutoFlashEnabled        = false
local RagdollBypassEnabled    = false
local AutoSelectBestBrainrot  = false
local AntiAdminEnabled        = false
local AutoResetBalloonEnabled = false

-- ── Auto-grab cache ───────────────────────────────────────────
local __AG_stealCbCache  = {}
local __AG_stealActive   = false
local __AG_MIN_HOLD_TIME = 1.3
local __AG_TRIGGER_DELAY = 0.05

-- ══════════════════════════════════════════════════════════════
--  ANTI RAGDOLL
-- ══════════════════════════════════════════════════════════════
local AntiRagdoll = { connections = {}, running = false }
AntiRagdoll.forceBackpack = function()
    if not AntiRagdoll.running then return end
    local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local bg = gui:FindFirstChild("BackpackGui")
    if not bg then return end
    local bp = bg:FindFirstChild("Backpack")
    if not bp then return end
    bp.Visible = true
    if not bp:FindFirstChild("ForceConnection") then
        local tag = Instance.new("BoolValue"); tag.Name = "ForceConnection"; tag.Parent = bp
        bp:GetPropertyChangedSignal("Visible"):Connect(function()
            if AntiRagdoll.running and not bp.Visible then bp.Visible = true end
        end)
    end
end
AntiRagdoll.removeConstraints = function(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")
        or d:IsA("NoCollisionConstraint")
        or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
            d:Destroy()
        end
    end
end
AntiRagdoll.resetChar = function(char)
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored = false; root.Velocity = Vector3.zero end
    if hum then
        for _, o in ipairs(char:GetDescendants()) do
            if o:IsA("Motor6D") and not o.Enabled then o.Enabled = true end
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum.PlatformStand = false; hum.Sit = false
        if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
        workspace.CurrentCamera.CameraSubject = hum
    end
end
AntiRagdoll.enable = function()
    if AntiRagdoll.running then return end
    AntiRagdoll.running = true
    AntiRagdoll.connections.hb = RunService.Heartbeat:Connect(function()
        local char = Players.LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll
        or s == Enum.HumanoidStateType.FallingDown then
            pcall(function() Players.LocalPlayer:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
            AntiRagdoll.removeConstraints(char)
            for _, o in ipairs(char:GetDescendants()) do
                if o:IsA("Motor6D") and not o.Enabled then o.Enabled = true end
            end
            if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            workspace.CurrentCamera.CameraSubject = hum
            root.Anchored = false; root.Velocity = Vector3.zero
        end
    end)
    AntiRagdoll.connections.ca = Players.LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1); AntiRagdoll.forceBackpack()
        char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        AntiRagdoll.connections.cda = char.DescendantAdded:Connect(function(obj)
            if not AntiRagdoll.running then return end
            if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint")
            or (obj:IsA("Attachment") and obj.Name:find("RagdollAttachment")) then
                task.defer(function() if obj.Parent then obj:Destroy() end end)
            end
        end)
        hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if AntiRagdoll.running and hum.PlatformStand then
                task.defer(function()
                    AntiRagdoll.resetChar(char)
                    AntiRagdoll.removeConstraints(char)
                end)
            end
        end)
        AntiRagdoll.removeConstraints(char); AntiRagdoll.resetChar(char)
    end)
    if Players.LocalPlayer.Character then
        AntiRagdoll.removeConstraints(Players.LocalPlayer.Character)
        AntiRagdoll.resetChar(Players.LocalPlayer.Character)
    end
    task.spawn(function()
        while AntiRagdoll.running do task.wait(0.5); AntiRagdoll.forceBackpack() end
    end)
end
AntiRagdoll.disable = function()
    AntiRagdoll.running = false
    for _, c in pairs(AntiRagdoll.connections) do pcall(function() c:Disconnect() end) end
    AntiRagdoll.connections = {}
end

-- ══════════════════════════════════════════════════════════════
--  SOLAR AIMBOT (background, no separate GUI)
-- ══════════════════════════════════════════════════════════════
local SolarAimbot = { enabled = false, target = nil, remote = nil, range = 350 }
do
    local function findAimbotRemote()
        local net = ReplicatedStorage:FindFirstChild("Packages")
        if net then net = net:FindFirstChild("Net") end
        if not net then return end
        local ch = net:GetChildren()
        for i, obj in ipairs(ch) do
            if obj.Name == "RE/UseItem" then SolarAimbot.remote = ch[i+1]; break end
        end
    end
    local function getNearestTarget()
        local lp = Players.LocalPlayer
        local chr = lp and lp.Character
        local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local nearest, best = nil, SolarAimbot.range
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local h = p.Character:FindFirstChild("HumanoidRootPart")
                if h then
                    local d = (h.Position - hrp.Position).Magnitude
                    if d < best then best = d; nearest = p end
                end
            end
        end
        return nearest
    end
    local function hookTool(tool)
        tool.Activated:Connect(function()
            if not SolarAimbot.enabled then return end
            local tgt = SolarAimbot.target
            if not tgt or not tgt.Character then return end
            local part = tgt.Character:FindFirstChild("HumanoidRootPart")
                or tgt.Character:FindFirstChild("Head")
            if part and SolarAimbot.remote then
                pcall(function() SolarAimbot.remote:FireServer(part.Position, part) end)
            end
        end)
    end
    findAimbotRemote()
    if Players.LocalPlayer.Character then
        for _, t in ipairs(Players.LocalPlayer.Character:GetChildren()) do
            if t:IsA("Tool") then pcall(hookTool, t) end
        end
    end
    Players.LocalPlayer.CharacterAdded:Connect(function(chr)
        task.wait(0.5)
        for _, t in ipairs(chr:GetChildren()) do
            if t:IsA("Tool") then pcall(hookTool, t) end
        end
    end)
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Tool") and obj:IsDescendantOf(Players.LocalPlayer.Character or {}) then
            task.wait(0.1); pcall(hookTool, obj)
        end
    end)
    RunService.Heartbeat:Connect(function()
        if SolarAimbot.enabled then SolarAimbot.target = getNearestTarget() end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  ANTI ADMIN PANEL (runs when AntiAdminEnabled = true)
-- ══════════════════════════════════════════════════════════════
do
    local lp = Players.LocalPlayer
    local scaleNames = {"HeadScale","BodyDepthScale","BodyHeightScale",
                        "BodyProportionScale","BodyTypeScale","BodyWidthScale"}
    local origScales, origHipH = {}, nil
    local function captureOriginals()
        local char = lp.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        origHipH = hum.HipHeight; origScales = {}
        for _, n in ipairs(scaleNames) do
            local sv = hum:FindFirstChild(n); if sv then origScales[n] = sv.Value end
        end
    end
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.1); captureOriginals()
    end)
    task.spawn(captureOriginals)
    local _ctrlCache
    local function getCtrl()
        if _ctrlCache then return _ctrlCache end
        local ps = lp:FindFirstChild("PlayerScripts")
        local pm = ps and ps:FindFirstChild("PlayerModule")
        if not pm then return nil end
        local ok, m = pcall(require, pm)
        if not ok then return nil end
        local ok2, c = pcall(function() return m:GetControls() end)
        if ok2 and c then _ctrlCache = c end
        return _ctrlCache
    end
    task.spawn(function()
        while task.wait(0.1) do
            if not AntiAdminEnabled then continue end
            local char = lp.Character; if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not (hum and hrp) then continue end
            -- destroy ragdoll constraints
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then
                    v:Destroy()
                elseif v:IsA("Motor6D") then v.Enabled = true end
            end
            -- re-enable controls
            local ctrl = getCtrl()
            if ctrl then pcall(function() ctrl:Enable() end) end
            -- force running
            local st = hum:GetState()
            if st ~= Enum.HumanoidStateType.Running and st ~= Enum.HumanoidStateType.Jumping
            and st ~= Enum.HumanoidStateType.Freefall then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end
            -- fix camera
            if workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject ~= hum then
                workspace.CurrentCamera.CameraSubject = hum
            end
            -- clear ragdoll attr
            local re = lp:GetAttribute("RagdollEndTime") or 0
            if re > workspace:GetServerTimeNow() then
                hrp.Velocity = Vector3.zero
                lp:SetAttribute("RagdollEndTime", 0)
            end
            -- restore scales (blocks tiny/giant)
            if origHipH and hum.HipHeight ~= origHipH then hum.HipHeight = origHipH end
            for _, n in ipairs(scaleNames) do
                local sv = hum:FindFirstChild(n)
                if sv and origScales[n] and sv.Value ~= origScales[n] then sv.Value = origScales[n] end
            end
            -- destroy admin-added models
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Model") and not v:IsA("BackpackItem") then v:Destroy() end
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  NOX AUTO BALLOON (replaces anti-steal)
-- ══════════════════════════════════════════════════════════════
local NoxBalloonEnabled = false
do
    local lp = Players.LocalPlayer
    local playerGui = lp:WaitForChild("PlayerGui")
    local balloonActive = {}
    local lastNoxCheck = 0

    local MultiZones = {
        {Shape='Line',   Center=Vector3.new(-345.35,-6.55, 39.19), Size=5,  Rotation=0},
        {Shape='Line',   Center=Vector3.new(-350.53,-6.55, 38.67), Size=20, Rotation=0},
        {Shape='Line',   Center=Vector3.new(-364.01,-6.55, 38.94), Size=20, Rotation=0},
        {Shape='Line',   Center=Vector3.new(-337.34,-6.55, 39.18), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-365.29,-6.95,-10.40), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-354.68,-6.95,  6.22), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-343.15,-6.53,-13.20), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-344.93,-6.95, 25.73), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-343.76,-6.95,-10.27), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-354.42,-6.95,  6.51), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-340.48,-5.32, 28.10), Size=20, Rotation=0},
        {Shape='Square', Center=Vector3.new(-361.10,-6.95, 29.42), Size=20, Rotation=0},
        {Shape='Line',   Center=Vector3.new(-354.83,27.19, 31.22), Size=20, Rotation=0},
    }

    local function inZone(pos)
        for _, z in ipairs(MultiZones) do
            local half = z.Size/2
            local dx = math.abs(pos.X - z.Center.X)
            local dz = math.abs(pos.Z - z.Center.Z)
            if z.Shape == 'Line' then
                if dx <= half and dz <= 1.5 then return true end
            elseif z.Shape == 'Square' then
                if dx <= half and dz <= half then return true end
            end
        end
        return false
    end

    local function hasStealMsg()
        for _, d in ipairs(playerGui:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text
            and d.Text:find("Someone is stealing your") then return true end
        end
        return false
    end

    local function clickBtn(btn)
        pcall(function() btn.MouseButton1Click:Fire() end)
        pcall(function() btn.Activated:Fire() end)
        if getconnections then
            pcall(function()
                for _, cx in ipairs(getconnections(btn.MouseButton1Click)) do cx:Fire() end
                for _, cx in ipairs(getconnections(btn.Activated)) do cx:Fire() end
            end)
        end
    end

    local function findAdminPanel() return playerGui:FindFirstChild("AdminPanel") end

    local function findPlayerBtn(target)
        local ap = findAdminPanel(); if not ap then return nil end
        for _, d in ipairs(ap:GetDescendants()) do
            if d:IsA("TextButton") or d:IsA("ImageButton") then
                local t = d:IsA("TextButton") and d.Text or ""
                if t == "" then
                    local lbl = d:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl then t = lbl.Text end
                end
                if t == target.DisplayName or t == target.Name
                or t:find(target.DisplayName) or t:find(target.Name) then
                    return d
                end
            end
        end
        return nil
    end

    local function getBalloonBtn()
        local ap = findAdminPanel(); if not ap then return nil end
        for _, d in ipairs(ap:GetDescendants()) do
            if d:IsA("TextButton") or d:IsA("ImageButton") then
                local t = d:IsA("TextButton") and d.Text or ""
                local tl = string.lower(t:match("^%s*(.-)%s*$") or t)
                if tl == "balloon" or tl == ":balloon" or tl == ";balloon" then return d end
            end
        end
        return nil
    end

    local function triggerBalloon(target)
        if not target or not target.Parent then return end
        local bb = getBalloonBtn(); if not bb then return end
        clickBtn(bb); task.wait(0.02)
        local pb = findPlayerBtn(target); if pb then clickBtn(pb) end
    end

    RunService.Heartbeat:Connect(function()
        if not NoxBalloonEnabled then return end
        local now = tick()
        if now - lastNoxCheck < 0.1 then return end
        lastNoxCheck = now
        local msg = hasStealMsg()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp then continue end
            local chr = p.Character; if not chr then continue end
            local hrp = chr:FindFirstChild("HumanoidRootPart") or chr:FindFirstChild("Torso")
            if not hrp then continue end
            local key = p.UserId
            local iz = inZone(hrp.Position)
            if iz and msg and not balloonActive[key] then
                balloonActive[key] = true; triggerBalloon(p)
            elseif (not iz or not msg) and balloonActive[key] then
                balloonActive[key] = nil
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(p) balloonActive[p.UserId] = nil end)
end

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function drawClickDot(x, y)
    if not Drawing then return end
    local dot = Drawing.new("Circle")
    dot.Radius = 5; dot.Position = Vector2.new(x, y)
    dot.Color = Color3.fromRGB(80, 140, 255); dot.Filled = true
    dot.Visible = true; dot.Transparency = 0.6
    task.delay(0.25, function() dot:Remove() end)
end

local function getPlotOwnerPlayer()
    local sel = _G._FH_SelectedBrainrot
    if not sel or not sel.plotName then return nil end
    local pf = workspace:FindFirstChild("Plots"); if not pf then return nil end
    local plot = pf:FindFirstChild(sel.plotName); if not plot then return nil end
    local sign = plot:FindFirstChild("PlotSign", true)
    local ownerName
    if sign then
        for _, d in ipairs(sign:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text and d.Text ~= "" and not d.Text:lower():find("empty") then
                local m = d.Text:match("[Bb]ase [Oo]f%s+(.+)")
                if m then ownerName = m; break end
                if #d.Text > 0 and #d.Text < 30 then ownerName = d.Text; break end
            end
        end
    end
    if not ownerName then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and (p.Name == ownerName or p.DisplayName == ownerName) then
            return p
        end
    end
    return nil
end

local function getNearestPlayer()
    local lp = Players.LocalPlayer
    local chr = lp and lp.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, best = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c = p.Character; local h = c and c:FindFirstChild("HumanoidRootPart")
            if h then
                local d = (h.Position - hrp.Position).Magnitude
                if d < best then best = d; nearest = p end
            end
        end
    end
    return nearest
end

local function blockPlayer(target)
    if not target then return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer", target) end)
    local cam = workspace.CurrentCamera; if not cam then return end
    local vp = cam.ViewportSize
    local x = math.floor(vp.X/2) + math.random(-1,1)
    local y = math.floor(vp.Y/2 + 50) + math.random(-1,1)
    local lp = Players.LocalPlayer; local chr = lp and lp.Character
    local blockers = {}
    if chr then
        for _, t in ipairs(chr:GetChildren()) do
            if t:IsA("Tool") then
                local blocked = true
                local conn = t.Activated:Connect(function() if blocked then return end end)
                table.insert(blockers, {conn=conn, ub=function() blocked=false end})
            end
        end
    end
    task.wait(0.04 + math.random()*0.02)
    drawClickDot(x, y)
    pcall(function() VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,1) end)
    task.wait(0.008 + math.random()*0.008)
    pcall(function() VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,1) end)
    task.delay(0.05, function()
        for _, b in ipairs(blockers) do b.ub(); pcall(function() b.conn:Disconnect() end) end
    end)
end

local function getBlockDelay()
    local ping = 0
    pcall(function() ping = Players.LocalPlayer:GetNetworkPing() or 0 end)
    return math.clamp(0.09 + ping, 0.09, 0.35)
end

local function triggerAutoBlock()
    if not AutoBlockEnabled then return end
    task.spawn(function()
        task.wait(getBlockDelay())
        local target = getPlotOwnerPlayer() or getNearestPlayer()
        if target then pcall(blockPlayer, target) end
    end)
end

-- ── Auto-grab internals ───────────────────────────────────────
local function __AG_buildCbs(prompt)
    if __AG_stealCbCache[prompt] then return __AG_stealCbCache[prompt] end
    if not getconnections then return nil end
    local data = {hold={}, trigger={}}
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then for _, c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold, c.Function) end end end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2)=="table" then for _, c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trigger, c.Function) end end end
    if #data.hold==0 and #data.trigger==0 then return nil end
    __AG_stealCbCache[prompt] = data; return data
end

local function __AG_startHold(prompt)
    if not prompt or not prompt.Parent then return nil end
    local cb = __AG_buildCbs(prompt); if not cb then return nil end
    __AG_stealActive = true
    for _, fn in ipairs(cb.hold) do task.spawn(fn) end
    return {cb=cb, holdBeganAt=tick(), holdDone=false}
end

local function __AG_finish(ctx)
    if not ctx then return false end
    local held = tick() - (ctx.holdBeganAt or tick())
    if held < __AG_MIN_HOLD_TIME then task.wait(__AG_MIN_HOLD_TIME - held) end
    task.wait(__AG_TRIGGER_DELAY)
    for _, fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
    __AG_stealActive = false; return true
end

local function __AG_findPrompt()
    local sel = _G._FH_SelectedBrainrot
    if not sel or not sel.plotName or not sel.slot then return nil end
    local pf = workspace:FindFirstChild("Plots"); if not pf then return nil end
    local plot = pf:FindFirstChild(sel.plotName); if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
    local podium = podiums:FindFirstChild(tostring(sel.slot)); if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local pa = spawn and spawn:FindFirstChild("PromptAttachment")
    local prompt = pa and pa:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = math.huge
    end
    return prompt
end

-- ══════════════════════════════════════════════════════════════
--  THEME  (dark gray + blue + white neon)
-- ══════════════════════════════════════════════════════════════
local T = {
    BG          = Color3.fromRGB(12,  12,  16),
    Header      = Color3.fromRGB(6,   6,   10),
    Card        = Color3.fromRGB(20,  20,  28),
    CardHover   = Color3.fromRGB(28,  28,  40),
    Border      = Color3.fromRGB(40,  40,  60),
    BorderHover = Color3.fromRGB(60,  80, 140),
    White       = Color3.fromRGB(230, 235, 255),
    Dim         = Color3.fromRGB(90,  90, 120),
    Accent      = Color3.fromRGB(60, 120, 255),
    AccentBright= Color3.fromRGB(100,160,255),
    TabActive   = Color3.fromRGB(230, 235, 255),
    TabInact    = Color3.fromRGB(60,  60,  90),
    TrackOn     = Color3.fromRGB(60,  120, 255),
    TrackOff    = Color3.fromRGB(35,  35,  50),
    KnobOn      = Color3.fromRGB(200, 220, 255),
    KnobOff     = Color3.fromRGB(80,  80, 110),
}
local F = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local M = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local S = TweenInfo.new(0.5,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local function Tween(o, i, p) TweenService:Create(o,i,p):Play() end
local function Corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function Stroke(p, col, th)
    local s = Instance.new("UIStroke"); s.Color = col or T.Border
    s.Thickness = th or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end
local function Padding(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or 0)
    u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0); u.Parent=p
end
local function Label(p, txt, sz, col, font)
    local l = Instance.new("TextLabel")
    l.Text=txt or ""; l.TextSize=sz or 13; l.TextColor3=col or T.White
    l.Font=font or Enum.Font.GothamMedium; l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=p; return l
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ── Destroy old GUI ───────────────────────────────────────────
pcall(function()
    if game.CoreGui:FindFirstChild("VertxedHub") then game.CoreGui.VertxedHub:Destroy() end
end)

-- ── Screen GUI ────────────────────────────────────────────────
local GUI = Instance.new("ScreenGui")
GUI.Name = "VertxedHub"; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false; GUI.IgnoreGuiInset = true
if not pcall(function() GUI.Parent = game.CoreGui end) then
    GUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ── Notifications ─────────────────────────────────────────────
local ShowToggleNotification
do
    local _active = {}
    local NW, NH, NGAP, NPADX, NPADY, NDUR = 200, 44, 6, 14, 14, 2
    local function _sy(i) return -(NPADY + NH + 4 + i*(NH+NGAP)) end
    local function _repo(ti)
        for i, e in ipairs(_active) do
            TweenService:Create(e.shadow, ti, {Position=UDim2.new(0,NPADX-4,1,_sy(i-1))}):Play()
        end
    end
    ShowToggleNotification = function(name, enabled)
        local scol = enabled and Color3.fromRGB(100,180,255) or Color3.fromRGB(255,80,80)
        local II = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local OI = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local BI = TweenInfo.new(NDUR, Enum.EasingStyle.Linear)
        local FI = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
        local RI = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local shadow = Instance.new("Frame")
        shadow.Size=UDim2.new(0,NW+8,0,NH+8)
        shadow.Position=UDim2.new(0,-(NW+32),1,_sy(0))
        shadow.BackgroundColor3=Color3.fromRGB(0,0,0)
        shadow.BackgroundTransparency=0.12; shadow.BorderSizePixel=0; shadow.ZIndex=99; shadow.Parent=GUI
        Corner(shadow, 12)
        local toast = Instance.new("Frame")
        toast.Size=UDim2.new(0,NW,0,NH); toast.Position=UDim2.new(0,4,0,4)
        toast.BackgroundColor3=T.BG; toast.BackgroundTransparency=1
        toast.BorderSizePixel=0; toast.ZIndex=100; toast.Parent=shadow
        Corner(toast, 10)
        local _st = Stroke(toast, T.Border, 1); _st.Transparency=1
        local pill = Instance.new("Frame")
        pill.Size=UDim2.new(0,3,0,NH-16); pill.Position=UDim2.new(0,9,0.5,-(NH-16)/2)
        pill.BackgroundColor3=T.Accent; pill.BorderSizePixel=0; pill.ZIndex=101; pill.Parent=toast
        Corner(pill, 2)
        local nl = Label(toast, name, 11, T.White, Enum.Font.GothamBold)
        nl.Size=UDim2.new(1,-24,0,15); nl.Position=UDim2.new(0,19,0,7)
        nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.TextTransparency=1; nl.ZIndex=101
        local sl = Label(toast, enabled and "Enabled" or "Disabled", 10, scol, Enum.Font.Gotham)
        sl.Size=UDim2.new(1,-24,0,11); sl.Position=UDim2.new(0,19,0,23)
        sl.TextTransparency=1; sl.ZIndex=101
        local bt = Instance.new("Frame")
        bt.Size=UDim2.new(1,0,0,2); bt.Position=UDim2.new(0,0,1,-2)
        bt.BackgroundColor3=T.Card; bt.BorderSizePixel=0; bt.ZIndex=101; bt.Parent=toast
        local bf = Instance.new("Frame")
        bf.Size=UDim2.new(1,0,1,0); bf.BackgroundColor3=T.Accent
        bf.BorderSizePixel=0; bf.ZIndex=102; bf.Parent=bt
        local entry = {shadow=shadow}
        table.insert(_active, 1, entry); _repo(RI)
        TweenService:Create(shadow,II,{Position=UDim2.new(0,NPADX-4,1,_sy(0))}):Play()
        TweenService:Create(toast,II,{BackgroundTransparency=0}):Play()
        TweenService:Create(_st,II,{Transparency=0.3}):Play()
        TweenService:Create(nl,II,{TextTransparency=0}):Play()
        TweenService:Create(sl,II,{TextTransparency=0}):Play()
        task.delay(0.1, function() TweenService:Create(bf,BI,{Size=UDim2.new(0,0,1,0)}):Play() end)
        task.delay(NDUR+0.15, function()
            for i, e in ipairs(_active) do if e==entry then table.remove(_active,i); break end end
            _repo(RI)
            local ey = shadow.Position.Y.Offset
            TweenService:Create(shadow,OI,{Position=UDim2.new(0,-(NW+32),1,ey)}):Play()
            TweenService:Create(toast,FI,{BackgroundTransparency=1}):Play()
            TweenService:Create(nl,FI,{TextTransparency=1}):Play()
            local tw = TweenService:Create(sl,FI,{TextTransparency=1})
            tw:Play(); tw.Completed:Connect(function() shadow:Destroy() end)
        end)
    end
end

-- ── WIN_W / WIN_H ─────────────────────────────────────────────
local WIN_W = isMobile and 150 or 320
local WIN_H = isMobile and 210 or 420

-- ── Main Window ───────────────────────────────────────────────
local Win = Instance.new("Frame")
Win.Name="Win"; Win.Size=UDim2.new(0,WIN_W,0,WIN_H)
Win.AnchorPoint=Vector2.new(0.5,0.5); Win.Position=UDim2.new(0.5,0,0.5,0)
Win.BackgroundColor3=T.BG; Win.BackgroundTransparency=0.1
Win.BorderSizePixel=0; Win.ZIndex=2; Win.Parent=GUI
Corner(Win, 12)
local WinStroke = Instance.new("UIStroke")
WinStroke.Thickness=1.6; WinStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
WinStroke.Color=T.AccentBright; WinStroke.Parent=Win
local BorderGrad = Instance.new("UIGradient")
BorderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(30,60,160)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(120,180,255)),
    ColorSequenceKeypoint.new(1.0,  Color3.fromRGB(30,60,160)),
})
BorderGrad.Rotation=0; BorderGrad.Parent=WinStroke
local winScale = Instance.new("UIScale"); winScale.Scale=1; winScale.Parent=Win

-- ── Header ────────────────────────────────────────────────────
local Hdr = Instance.new("Frame")
Hdr.Size=UDim2.new(1,0,0,42); Hdr.BackgroundColor3=T.Header
Hdr.BackgroundTransparency=0.05; Hdr.BorderSizePixel=0; Hdr.ZIndex=5; Hdr.Parent=Win; Hdr.Active=true
Corner(Hdr, 12)
local HdrFill = Instance.new("Frame")
HdrFill.Size=UDim2.new(1,0,0,10); HdrFill.Position=UDim2.new(0,0,1,-10)
HdrFill.BackgroundColor3=T.Header; HdrFill.BackgroundTransparency=0.05
HdrFill.BorderSizePixel=0; HdrFill.ZIndex=5; HdrFill.Parent=Hdr
local HdrLine = Instance.new("Frame")
HdrLine.Size=UDim2.new(1,0,0,1); HdrLine.Position=UDim2.new(0,0,1,-1)
HdrLine.BackgroundColor3=T.Border; HdrLine.BorderSizePixel=0; HdrLine.ZIndex=6; HdrLine.Parent=Hdr

-- Discord box (super small, top left of header)
local DiscordBox = Instance.new("Frame")
DiscordBox.Size=UDim2.new(0,isMobile and 80 or 130,0,isMobile and 14 or 16)
DiscordBox.Position=UDim2.new(0,8,0,2); DiscordBox.BackgroundColor3=Color3.fromRGB(10,10,20)
DiscordBox.BackgroundTransparency=0.3; DiscordBox.BorderSizePixel=0; DiscordBox.ZIndex=7; DiscordBox.Parent=Hdr
Corner(DiscordBox, 4)
Stroke(DiscordBox, T.Border, 1)
local DiscordLbl = Label(DiscordBox, "discord.gg/3JnFzfcYB", isMobile and 6 or 8, T.Dim, Enum.Font.Gotham)
DiscordLbl.Size=UDim2.new(1,-4,1,0); DiscordLbl.Position=UDim2.new(0,2,0,0)
DiscordLbl.TextXAlignment=Enum.TextXAlignment.Left; DiscordLbl.ZIndex=8; DiscordLbl.TextTruncate=Enum.TextTruncate.AtEnd

local TitleLbl = Label(Hdr, "", 14, T.White, Enum.Font.GothamBold)
TitleLbl.RichText=true
TitleLbl.Text='<font color="rgb(100,160,255)">Vertex</font> <font color="rgb(230,235,255)">Pvp</font>'
TitleLbl.Size=UDim2.new(0,180,0,20); TitleLbl.Position=UDim2.new(0,8,0,isMobile and 16 or 18); TitleLbl.ZIndex=6

local VerLbl = Label(Hdr, "v2.0 | r9qbx", isMobile and 7 or 9, T.Dim, Enum.Font.Gotham)
VerLbl.Size=UDim2.new(0,120,0,12); VerLbl.Position=UDim2.new(0,8,1,-14); VerLbl.ZIndex=6

-- ── Config storage ────────────────────────────────────────────
local Config = {toggles={}, keybinds={}, mini={}, fastPanelPos=nil}
local configRegistry = {}
local keybindEntries = {}
local keybindBindingTarget = nil
local CONFIG_PATH = "VertxedHub_config.json"

local function FH_Serialize()
    local function enc(v)
        local t = type(v)
        if t=="boolean" then return v and "true" or "false"
        elseif t=="number" then return tostring(v)
        elseif t=="string" then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"')..'"'
        elseif t=="table" then
            local p={}
            for k,val in pairs(v) do p[#p+1]='"'..tostring(k)..'":'..enc(val) end
            return "{"..table.concat(p,",").."}"
        end
        return "null"
    end
    return enc({toggles=Config.toggles, keybinds=Config.keybinds})
end
local function FH_Parse(str)
    local pos=1
    local function sk() while pos<=#str and str:sub(pos,pos):match("%s") do pos=pos+1 end end
    local pv
    local function ps()
        pos=pos+1; local s=""
        while pos<=#str do
            local c=str:sub(pos,pos)
            if c=='"' then pos=pos+1; return s end
            if c=='\\' then pos=pos+1; local e=str:sub(pos,pos); s=s..(e=='"' and '"' or e=='\\' and '\\' or e=='n' and '\n' or e)
            else s=s..c end; pos=pos+1
        end; return s
    end
    local function po()
        pos=pos+1; local t={}; sk()
        if str:sub(pos,pos)=="}" then pos=pos+1; return t end
        while true do
            sk(); local k=ps(); sk(); pos=pos+1; sk()
            t[k]=pv(); sk()
            if str:sub(pos,pos)=="}" then pos=pos+1; return t end
            pos=pos+1
        end
    end
    pv=function()
        sk(); local c=str:sub(pos,pos)
        if c=='"' then return ps()
        elseif c=='{' then return po()
        elseif c=='t' then pos=pos+4; return true
        elseif c=='f' then pos=pos+5; return false
        elseif c=='n' then pos=pos+4; return nil
        else local n=str:match("^-?%d+%.?%d*",pos); if n then pos=pos+#n; return tonumber(n) end end
    end
    local ok,r = pcall(pv); return (ok and type(r)=="table") and r or nil
end
local function FH_Save() pcall(writefile, CONFIG_PATH, FH_Serialize()) end
local function FH_Load()
    local ok,d = pcall(function() return FH_Parse(readfile(CONFIG_PATH)) end)
    if ok and type(d)=="table" then
        if type(d.toggles)=="table" then Config.toggles=d.toggles end
        if type(d.keybinds)=="table" then Config.keybinds=d.keybinds end
    end
end
FH_Load()

-- ── LOCK button + drag ────────────────────────────────────────
_G._FH_GUI_LOCKED = false
do
    local HBTN_H = isMobile and 18 or 22
    local HdrBtns = Instance.new("Frame")
    HdrBtns.AnchorPoint=Vector2.new(1,0.5); HdrBtns.Position=UDim2.new(1,-8,0.5,0)
    HdrBtns.Size=UDim2.new(0,0,0,HBTN_H); HdrBtns.AutomaticSize=Enum.AutomaticSize.X
    HdrBtns.BackgroundTransparency=1; HdrBtns.ZIndex=7; HdrBtns.Parent=Hdr
    local hl=Instance.new("UIListLayout"); hl.FillDirection=Enum.FillDirection.Horizontal
    hl.VerticalAlignment=Enum.VerticalAlignment.Center; hl.SortOrder=Enum.SortOrder.LayoutOrder
    hl.Padding=UDim.new(0,5); hl.Parent=HdrBtns
    local function styleBtn(text, order)
        local btn=Instance.new("TextButton")
        btn.Name="Hdr_"..text; btn.AutomaticSize=Enum.AutomaticSize.X
        btn.Size=UDim2.new(0,0,0,HBTN_H); btn.LayoutOrder=order
        btn.BackgroundColor3=T.Card; btn.BorderSizePixel=0; btn.AutoButtonColor=false
        btn.Text=text; btn.TextSize=isMobile and 8 or 10; btn.Font=Enum.Font.GothamBold
        btn.TextColor3=T.White; btn.ZIndex=8; btn.Active=true; btn.Parent=HdrBtns
        Corner(btn,6)
        local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8); pad.Parent=btn
        return btn, Stroke(btn, T.Border, 1)
    end
    local lockBtn, lockStroke = styleBtn("🔓 FREE", 1)
    lockBtn.MouseButton1Click:Connect(function()
        _G._FH_GUI_LOCKED = not _G._FH_GUI_LOCKED
        if _G._FH_GUI_LOCKED then
            lockBtn.Text="🔒 LOCK"; lockBtn.BackgroundColor3=Color3.fromRGB(140,30,30); lockStroke.Color=Color3.fromRGB(200,50,50)
        else
            lockBtn.Text="🔓 FREE"; lockBtn.BackgroundColor3=T.Card; lockStroke.Color=T.Border
        end
    end)
    local hdrBinds = {}
    local hdrBindTarget = nil
    local function makeActionBtn(label, order, onClick)
        local btn, s = styleBtn(label, order)
        local configKey = "hdr_"..label
        local entry = {keyCode=nil, label=label, configKey=configKey}
        local _busy = false
        local function refresh()
            if hdrBindTarget==entry then btn.Text=label.." (...)"
            elseif entry.keyCode then btn.Text=label.." ("..entry.keyCode.Name..")"
            else btn.Text=label end
        end
        local function fire()
            _busy=true; btn.BackgroundColor3=T.AccentBright; btn.TextColor3=Color3.fromRGB(10,10,20)
            Tween(s,F,{Color=T.AccentBright})
            task.delay(0.16, function()
                Tween(btn,M,{BackgroundColor3=T.Card}); Tween(s,M,{Color=T.Border})
                btn.TextColor3=T.White; _busy=false
            end)
            if onClick then task.spawn(function() pcall(onClick) end) end
        end
        btn.MouseEnter:Connect(function() if not _busy then Tween(btn,F,{BackgroundColor3=T.CardHover}); Tween(s,F,{Color=T.BorderHover}) end end)
        btn.MouseLeave:Connect(function() if not _busy then Tween(btn,F,{BackgroundColor3=T.Card}); Tween(s,F,{Color=T.Border}) end end)
        btn.MouseButton1Click:Connect(fire)
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
            if hdrBindTarget and hdrBindTarget ~= entry then local p=hdrBindTarget; hdrBindTarget=nil; p.refresh() end
            if hdrBindTarget==entry then hdrBindTarget=nil else hdrBindTarget=entry end
            refresh()
        end)
        entry.refresh=refresh; entry.fire=fire
        local saved=Config.keybinds[configKey]
        if saved then
            local ok2,kc=pcall(function() return Enum.KeyCode[saved] end)
            if ok2 and kc then entry.keyCode=kc; refresh() end
        end
        table.insert(hdrBinds, entry); return entry
    end

    -- ── RESET button ─────────────────────────────────────────
    _G._FH_ResetBtnEntry = makeActionBtn("RESET", 2, function()
        local lp = Players.LocalPlayer
        local Net = ReplicatedStorage:WaitForChild("Packages",2) and ReplicatedStorage.Packages:WaitForChild("Net",2)
        if not Net then
            local h = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
            if h then h.Health=0 end; return
        end
        local remote; local ch=Net:GetChildren()
        for i=1,#ch-1 do
            if ch[i] and ch[i+1] and string.find(ch[i].Name,"Tools/Cooldown") then remote=ch[i+1]; break end
        end
        if not remote then
            local h = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
            if h then h.Health=0 end; return
        end
        local saved={}; local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        if char then
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:UnequipTools() end) end
            for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(saved,t); t.Parent=nil end end
        end
        if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(saved,t); t.Parent=nil end end end
        lp.Character=nil; local sending=true; local lc; local fire=remote.FireServer; local thr=0
        lc=RunService.Heartbeat:Connect(function(dt)
            if not sending then if lc then lc:Disconnect(); lc=nil end; return end
            thr=thr+dt; if thr>=0.1 then thr=0
                pcall(fire,remote,"f888ee6e-c86d-46e1-93d7-0639d6635d42",lp,"balloon")
            end
            if sending and lp.Character then lp.Character=nil end
        end)
        local cn; cn=lp.CharacterAdded:Connect(function()
            sending=false; if lc then lc:Disconnect(); lc=nil end; if cn then cn:Disconnect() end
            task.spawn(function()
                local nb=lp:WaitForChild("Backpack",3)
                if nb then for _,t in ipairs(saved) do if t then t.Parent=nb end end end; saved={}
            end)
        end)
        task.delay(4, function()
            sending=false; if lc then lc:Disconnect(); lc=nil end
            local cb=lp:FindFirstChild("Backpack")
            if cb and #saved>0 then for _,t in ipairs(saved) do if t then t.Parent=cb end end; saved={} end
        end)
    end)

    -- ── FLASH button ─────────────────────────────────────────
    _G._FH_FlashBtnEntry = makeActionBtn("FLASH", 3, function()
        local lp  = Players.LocalPlayer
        local chr = lp and lp.Character
        local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local PODIUM_CFRAMES = {
            [1]={[1]={hrp=CFrame.new(Vector3.new(-347.6983,-7.5033,-4.5494)),cam=CFrame.new(-357.0927,0.0048,-0.272)*CFrame.Angles(-0.954463,-0.903625,-0.837019)}},
            [2]={
                [1]={hrp=CFrame.new(Vector3.new(-349.9259,-7.3841,-1.578)),cam=CFrame.new(-361.8253,1.3324,5.126)*CFrame.Angles(-0.824269,-0.878251,-0.693896)},
                [2]={hrp=CFrame.new(Vector3.new(-348.4448,-7.1043,3.3442)),cam=CFrame.new(-358.5857,-0.0841,9.5148)*CFrame.Angles(-0.732523,-0.884924,-0.608084)},
                [3]={hrp=CFrame.new(-346.1821,-7.2885,-1.609)*CFrame.Angles(0,-1.247212,0),cam=CFrame.new(-360.1625,0.6353,3.1776)*CFrame.Angles(-0.932656,-1.049154,-0.86316)},
                [4]={hrp=CFrame.new(-343.6695,-7.0385,10.3377)*CFrame.Angles(0,-0.982332,0),cam=CFrame.new(-356.477,-0.7795,18.8846)*CFrame.Angles(-0.510736,-0.917793,-0.418726)},
                [5]={hrp=CFrame.new(-343.7608,-7.4124,-9.7994)*CFrame.Angles(0,-1.544676,0),cam=CFrame.new(-359.4998,-2.4726,-9.2893)*CFrame.Angles(-1.424811,-1.351549,-1.421283)},
                [6]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-325.655,-7.5033,54.5488)*CFrame.Angles(0,-0.69115,0),cam=CFrame.new(-338.7595,-4.0265,70.3894)*CFrame.Angles(-0.126016,-0.687243,-0.080199)},
                [7]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-344.4383,-7.5033,41.8672)*CFrame.Angles(0,-1.108982,0),cam=CFrame.new(-362.8094,-4.325,51.1551)*CFrame.Angles(-0.181885,-1.095968,-0.162135)},
                [8]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-348.5228,-7.5033,48.1022)*CFrame.Angles(0,-0.939336,0),cam=CFrame.new(-363.5051,-2.5713,59.0596)*CFrame.Angles(-0.30602,-0.916511,-0.245634)},
                [9]={hrp=CFrame.new(-339.6349,-7.5033,60.4164)*CFrame.Angles(0,-0.405266,0),cam=CFrame.new(-346.7646,-3.7365,77.0351)*CFrame.Angles(-0.137335,-0.401849,-0.054002)},
                [10]={hrp=CFrame.new(-339.4453,-7.5033,61.9429)*CFrame.Angles(0,-0.29845,0),cam=CFrame.new(-342.5024,-5.2211,71.8802)*CFrame.Angles(-0.081543,-0.297517,-0.023953)},
                [11]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-331.5262,-7.5033,-47.3607)*CFrame.Angles(0,0.003141,0),cam=CFrame.new(-331.4885,-9.6045,-59.3396)*CFrame.Angles(2.851853,-0.097011,-3.140695)},
                [12]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-338.729,-7.5033,-43.4714)*CFrame.Angles(0,-1.420208,0),cam=CFrame.new(-345.1804,-9.9578,-56.8524)*CFrame.Angles(2.856299,-0.433315,3.01906)},
                [13]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-334.5183,-7.5033,-41.6819)*CFrame.Angles(0,-0.543495,0),cam=CFrame.new(-341.912,-9.959,-53.9192)*CFrame.Angles(2.831168,-0.52207,2.982964)},
                [14]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-319.8298,-7.5033,-45.1476)*CFrame.Angles(0,-0.323585,0),cam=CFrame.new(-323.983,-9.9618,-57.5315)*CFrame.Angles(2.834406,-0.309406,3.045298)},
                [15]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-317.917,-7.5033,-41.9999)*CFrame.Angles(0,-0.565487,0),cam=CFrame.new(-325.8,-9.9581,-54.4216)*CFrame.Angles(2.835549,-0.544183,2.979445)},
                [16]={hrp=CFrame.new(-338.285,-7.5033,57.204)*CFrame.Angles(0,-0.207346,0),cam=CFrame.new(-340.4345,-9.5916,67.4219)*CFrame.Angles(0.335111,-0.196113,0.067755)},
                [17]={hrp=CFrame.new(-337.9285,-7.5033,55.1757)*CFrame.Angles(0,-0.430398,0),cam=CFrame.new(-341.7441,-8.9535,63.4867)*CFrame.Angles(0.337895,-0.408747,0.138758)},
                [18]={hrp=CFrame.new(-332.1088,-7.5033,53.1675)*CFrame.Angles(0,-0.49323,0),cam=CFrame.new(-336.3932,-9.2396,61.1377)*CFrame.Angles(0.382481,-0.462609,0.177644)},
                [19]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-328.579,-3.1209,-35.0857)*CFrame.Angles(0,0.021988,0),cam=CFrame.new(-328.5137,-10.011,-45.4753)*CFrame.Angles(2.387391,-0.004579,3.137291)},
                [20]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-321.5783,-7.5033,-33.5778)*CFrame.Angles(0,0.006284,0),cam=CFrame.new(-321.5535,-10.0218,-37.5259)*CFrame.Angles(2.387391,-0.004579,3.137291)},
                [21]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-314.088,-7.5033,-32.1806)*CFrame.Angles(0,-0.006282,0),cam=CFrame.new(-314.1147,-10.0174,-36.4214)*CFrame.Angles(2.387391,-0.004579,3.137291)},
                [22]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-306.8919,-7.5033,-33.9124)*CFrame.Angles(0,-0.006284,0),cam=CFrame.new(-306.923,-10.008,-38.86)*CFrame.Angles(2.4648,-0.004898,3.137657)},
                [23]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-300.2759,-7.5033,-32.7047)*CFrame.Angles(0,-0.031416,0),cam=CFrame.new(-300.4669,-10.016,-37.044)*CFrame.Angles(2.399014,-0.032413,3.111857)},
                [24]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-330.0484,-7.5033,48.183)*CFrame.Angles(0,-0.006377,0),cam=CFrame.new(-330.1124,-10.0063,53.2779)*CFrame.Angles(0.662308,-0.00991,0.007727)},
                [25]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-325.4576,-7.5033,46.8182)*CFrame.Angles(0,-0.125663,0),cam=CFrame.new(-326.0541,-10.0104,51.5397)*CFrame.Angles(0.700033,-0.09632,0.080833)},
                [26]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-324.6721,-7.5033,47.2033)*CFrame.Angles(0,-0.40212,0),cam=CFrame.new(-326.6859,-10.0057,51.9385)*CFrame.Angles(0.698024,-0.314979,0.254268)},
                [27]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-320.4196,-7.5033,44.1)*CFrame.Angles(0,-0.571769,0),cam=CFrame.new(-322.9213,-10.0122,49.5157)*CFrame.Angles(0.876985,-0.422603,0.397417)},
            },
        }

        local myBase
        local plotsFolder = workspace:FindFirstChild("Plots")
        if plotsFolder then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                if plot:IsA("Model") then
                    local sign = plot:FindFirstChild("PlotSign")
                    if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then
                        local ok, order = pcall(function() return plot:GetAttribute("Order") end)
                        if ok and order then myBase = tonumber(order) end; break
                    end
                end
            end
        end
        if not myBase then pcall(ShowToggleNotification,"Flash: base not detected",false); return end
        local targetBase = (myBase==1) and 2 or 1
        local podiumCFs = PODIUM_CFRAMES[targetBase]; if not podiumCFs then return end
        local selected = _G._FH_SelectedBrainrot
        if not selected then pcall(ShowToggleNotification,"Flash: select an animal first",false); return end
        local slot = tonumber(selected.slot)
        if not slot then pcall(ShowToggleNotification,"Flash: no slot",false); return end
        local entry = podiumCFs[slot]
        if not entry or not entry.cam then
            pcall(ShowToggleNotification,"Flash: podium "..tostring(slot).." not configured",false); return
        end

        task.spawn(function()
            local CARPET_SPEED = 214
            local ARRIVE_DIST  = 4
            local TIMEOUT      = 8
            local player = Players.LocalPlayer
            local targetPos = (entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position

            local function findTool(kw)
                local c=player.Character; local b=player:FindFirstChild("Backpack")
                if c then for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
                if b then for _,t in ipairs(b:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
            end
            local function doEquip(tool, timeout)
                local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
                if not (c and h) then return end
                if tool.Parent==c then return end
                local done=false; local cn
                cn=tool.Equipped:Connect(function() done=true; cn:Disconnect() end)
                pcall(function() h:EquipTool(tool) end)
                local dl=tick()+(timeout or 1)
                while not done and tick()<dl do task.wait() end
                if cn then pcall(function() cn:Disconnect() end) end
            end

            -- Equip Flying Carpet (pull out only, no activate)
            local carpet = findTool("flying carpet") or findTool("carpet")
            if carpet then
                doEquip(carpet, 1)
                -- set carpet speed to 214
                pcall(function()
                    local v = carpet:FindFirstChild("Speed") or carpet:FindFirstChild("WalkSpeed")
                    if v then v.Value = CARPET_SPEED end
                end)
            end

            local stealCtx
            local _lateSlots = {[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,
                                [19]=true,[20]=true,[21]=true,[22]=true,[23]=true}
            if not _lateSlots[slot] then
                task.spawn(function()
                    local chr3=player.Character; local hrp3=chr3 and chr3:FindFirstChild("HumanoidRootPart")
                    local dest=(entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
                    local dist=hrp3 and (hrp3.Position-dest).Magnitude or 0
                    local POST=0.10+0.15+0.07+0.30+0.12
                    local pre=math.max(0,(dist/math.max(CARPET_SPEED,1))+POST-__AG_MIN_HOLD_TIME)
                    if pre>0 then task.wait(pre) end
                    local tp=__AG_findPrompt(); if tp then stealCtx=__AG_startHold(tp) end
                end)
            end

            -- Tween movement using Heartbeat velocity
            local boostConn
            boostConn = RunService.Heartbeat:Connect(function()
                if not player.Character then return end
                local hrp2=player.Character:FindFirstChild("HumanoidRootPart")
                local hum2=player.Character:FindFirstChildOfClass("Humanoid")
                if not hrp2 or not hum2 then return end
                local diff=targetPos-hrp2.Position
                local flat=Vector3.new(diff.X,0,diff.Z)
                if flat.Magnitude>ARRIVE_DIST then
                    local dir=flat.Unit
                    hrp2.Velocity=Vector3.new(dir.X*CARPET_SPEED, hrp2.Velocity.Y, dir.Z*CARPET_SPEED)
                else
                    hrp2.Velocity=Vector3.new(0,hrp2.Velocity.Y,0)
                end
            end)

            local chr2=player.Character; local hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if hum2 then hum2:MoveTo(targetPos) end
            local dl=tick()+TIMEOUT; local _lmt=0
            repeat
                task.wait(); chr2=player.Character
                local hrp2=chr2 and chr2:FindFirstChild("HumanoidRootPart")
                hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if not (hrp2 and hum2) then break end
                if tick()-_lmt>=0.1 then hum2:MoveTo(targetPos); _lmt=tick() end
                if (hrp2.Position-targetPos).Magnitude<ARRIVE_DIST then break end
            until tick()>dl

            if boostConn then boostConn:Disconnect(); boostConn=nil end
            do
                local _c=player.Character; local _h=_c and _c:FindFirstChild("HumanoidRootPart"); local _hm=_c and _c:FindFirstChildOfClass("Humanoid")
                if _h and _hm then
                    _hm:MoveTo(_h.Position); _h.Velocity=Vector3.zero; _h.Anchored=true
                    task.defer(function() task.defer(function()
                        local _c2=player.Character; local _h2=_c2 and _c2:FindFirstChild("HumanoidRootPart")
                        if _h2 then _h2.Velocity=Vector3.zero; _h2.Anchored=false end
                    end) end)
                end
            end

            if _lateSlots[slot] then
                task.spawn(function()
                    local _chr3=player.Character; local _hrp3=_chr3 and _chr3:FindFirstChild("HumanoidRootPart")
                    local _fp=entry.hrp.Position; local _d2=_hrp3 and (_hrp3.Position-_fp).Magnitude or 0
                    local _POST2=0.10+0.15+0.07+0.30+0.12
                    local _pre2=math.max(0,(_d2/math.max(CARPET_SPEED,1))+_POST2-__AG_MIN_HOLD_TIME)
                    if _pre2>0 then task.wait(_pre2) end
                    local _tp=__AG_findPrompt(); if _tp then stealCtx=__AG_startHold(_tp) end
                end)
            end

            if entry.hrpWalk then
                local finalPos=entry.hrp.Position
                local bc2; bc2=RunService.Heartbeat:Connect(function()
                    if not player.Character then return end
                    local hrp3=player.Character:FindFirstChild("HumanoidRootPart")
                    local hum3=player.Character:FindFirstChildOfClass("Humanoid")
                    if not hrp3 or not hum3 then return end
                    local diff3=finalPos-hrp3.Position; local flat3=Vector3.new(diff3.X,0,diff3.Z)
                    if flat3.Magnitude>ARRIVE_DIST then
                        local d3=flat3.Unit; hrp3.Velocity=Vector3.new(d3.X*CARPET_SPEED,hrp3.Velocity.Y,d3.Z*CARPET_SPEED)
                    else hrp3.Velocity=Vector3.new(0,hrp3.Velocity.Y,0) end
                end)
                chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if hum2 then hum2:MoveTo(finalPos) end
                local dl2=tick()+TIMEOUT; local _lmt2=0
                repeat
                    task.wait(); chr2=player.Character
                    local hrp2b=chr2 and chr2:FindFirstChild("HumanoidRootPart")
                    hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
                    if not (hrp2b and hum2) then break end
                    if tick()-_lmt2>=0.1 then hum2:MoveTo(finalPos); _lmt2=tick() end
                    if (hrp2b.Position-finalPos).Magnitude<ARRIVE_DIST then break end
                until tick()>dl2
                bc2:Disconnect()
                chr2=player.Character; local hrpStop=chr2 and chr2:FindFirstChild("HumanoidRootPart")
                hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if hrpStop and hum2 then
                    hrpStop.CFrame=entry.hrp; hrpStop.Velocity=Vector3.zero; hrpStop.Anchored=true
                    task.defer(function() task.defer(function()
                        local _c=player.Character; local _h=_c and _c:FindFirstChild("HumanoidRootPart")
                        if _h then _h.Velocity=Vector3.zero; _h.Anchored=false end
                    end) end)
                end
            else
                chr2=player.Character; local hrpStop=chr2 and chr2:FindFirstChild("HumanoidRootPart")
                hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if hrpStop then
                    hrpStop.CFrame=entry.hrp; hrpStop.Velocity=Vector3.zero; hrpStop.Anchored=true
                    task.defer(function() task.defer(function()
                        local _c=player.Character; local _h=_c and _c:FindFirstChild("HumanoidRootPart")
                        if _h then _h.Velocity=Vector3.zero; _h.Anchored=false end
                    end) end)
                end
            end

            -- Fix camera
            local cam=workspace.CurrentCamera
            if cam and entry.cam then
                cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=entry.cam
                task.defer(function()
                    cam.CFrame=entry.cam
                    task.defer(function() cam.CFrame=entry.cam; cam.CameraType=Enum.CameraType.Custom end)
                end)
            end

            -- Re-equip carpet after arriving
            local carpetMid = findTool("flying carpet") or findTool("carpet")
            if carpetMid then doEquip(carpetMid, 1.5) end
            task.wait(0.35)

            if slot >= 19 and slot <= 27 then
                chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if hum2 then hum2:ChangeState(Enum.HumanoidStateType.Jumping) end
            end

            chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if not (chr2 and hum2) then return end

            -- Find flash tool
            local flashTool
            local bp=player:FindFirstChild("Backpack")
            if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool=t; break end end end
            if not flashTool then for _,t in ipairs(chr2:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool=t; break end end end
            if not flashTool then pcall(ShowToggleNotification,"Flash: tool not found",false); return end

            pcall(function() hum2:UnequipTools() end); task.wait(0.07)

            local _fe=false; local _fc
            _fc=flashTool.Equipped:Connect(function() _fe=true; if _fc then _fc:Disconnect(); _fc=nil end end)
            flashTool.Parent=chr2; pcall(function() hum2:EquipTool(flashTool) end)
            local _eq=tick()+1; while not _fe and tick()<_eq do task.wait() end
            if _fc then pcall(function() _fc:Disconnect() end); _fc=nil end

            pcall(function() flashTool:Activate() end)

            task.spawn(function()
                task.wait(0.08)
                if not RagdollBypassEnabled then
                    if stealCtx then triggerAutoBlock(); __AG_finish(stealCtx)
                    elseif type(_G._sv2DoSteal)=="function" then triggerAutoBlock(); pcall(_G._sv2DoSteal) end
                end
            end)
            task.wait(0.02); pcall(function() flashTool:Activate() end)
            task.wait(0.08)

            if hum2 then pcall(function() hum2:UnequipTools() end) end
            task.wait(0.05)
            local bp2=player:FindFirstChild("Backpack")
            if bp2 and flashTool and flashTool.Parent~=bp2 then flashTool.Parent=bp2 end

            -- Ragdoll bypass path
            if RagdollBypassEnabled then
                task.spawn(function()
                    task.wait(0.10)
                    local _rc,_rp = {}, {}
                    local function _rca(o) local c={}; local ok2,cs=pcall(getconnections,o.Activated); if ok2 and type(cs)=="table" then for _,cx in ipairs(cs) do if type(cx.Function)=="function" then table.insert(c,cx.Function) end end end; return c end
                    local function _rfa(c) for _,fn in ipairs(c) do task.spawn(fn) end end
                    local function _raf()
                        local ap=Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel"); if not ap then return nil,nil end
                        local panel=ap:FindFirstChild("AdminPanel"); if not panel then return nil,nil end
                        local cont=panel:FindFirstChild("Content"); local prof=panel:FindFirstChild("Profiles")
                        if not cont or not prof then return nil,nil end
                        return cont:FindFirstChild("ScrollingFrame"), prof:FindFirstChild("ScrollingFrame")
                    end
                    local cf2,pf2=_raf(); if not cf2 or not pf2 then return end
                    local pn=Players.LocalPlayer.Name
                    local pb2=pf2:FindFirstChild(pn); local rb2=cf2:FindFirstChild("ragdoll")
                    if not pb2 or not rb2 then return end
                    if not _rp[pn] then _rp[pn]=_rca(pb2) end
                    if not _rc["ragdoll"] then _rc["ragdoll"]=_rca(rb2) end
                    _rfa(_rc["ragdoll"]); task.wait(); _rfa(_rp[pn])
                    triggerAutoBlock()
                    local _kicked=false; local _kc1,_kc2
                    local _tp2=getPlotOwnerPlayer()
                    local _tc2=_tp2 and _tp2.Character
                    local _th2=_tc2 and _tc2:FindFirstChildOfClass("Humanoid")
                    local function _onK()
                        if _kicked then return end; _kicked=true
                        if _kc1 then pcall(function() _kc1:Disconnect() end); _kc1=nil end
                        if _kc2 then pcall(function() _kc2:Disconnect() end); _kc2=nil end
                        local _wf=0; while not stealCtx and _wf<3 do task.wait(); _wf=_wf+1 end
                        if not stealCtx then local _fp2=__AG_findPrompt(); if _fp2 then stealCtx=__AG_startHold(_fp2) end end
                        if stealCtx then __AG_finish(stealCtx)
                        elseif type(_G._sv2DoSteal)=="function" then pcall(_G._sv2DoSteal) end
                    end
                    if _th2 then
                        _kc1=_th2.StateChanged:Connect(function(_,new)
                            if new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll
                            or new==Enum.HumanoidStateType.FallingDown then _onK() end
                        end)
                        _kc2=_th2:GetPropertyChangedSignal("PlatformStand"):Connect(function()
                            if _th2.PlatformStand then _onK() end
                        end)
                    end
                    task.delay(0.35, function() if not _kicked then _onK() end end)
                end)
            end

            local carpetAfter = findTool("flying carpet") or findTool("carpet")
            if carpetAfter then doEquip(carpetAfter, 1) end
        end)
        pcall(ShowToggleNotification, "Flash → Base "..(((function()
            local lp=Players.LocalPlayer; local pf=workspace:FindFirstChild("Plots"); local mb
            if pf then for _,plot in ipairs(pf:GetChildren()) do
                if plot:IsA("Model") then
                    local sign=plot:FindFirstChild("PlotSign")
                    if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then
                        local ok2,o=pcall(function() return plot:GetAttribute("Order") end)
                        if ok2 and o then mb=tonumber(o) end; break
                    end
                end
            end end; return mb and ((mb==1) and 2 or 1) or "?" end)()).." Podium "..((_G._FH_SelectedBrainrot and _G._FH_SelectedBrainrot.slot) or "?"), true)
    end)

    _G._FH_BlockBtnEntry = makeActionBtn("BLOCK", 4, function()
        local t = getNearestPlayer()
        if t then pcall(blockPlayer,t); pcall(ShowToggleNotification,"Blocked: "..t.Name,true)
        else pcall(ShowToggleNotification,"Block: no players nearby",false) end
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if hdrBindTarget then
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                local t=hdrBindTarget; local kc=inp.KeyCode; hdrBindTarget=nil
                if kc==Enum.KeyCode.Escape then t.refresh()
                elseif kc==Enum.KeyCode.Backspace then t.keyCode=nil; Config.keybinds[t.configKey]=nil; pcall(FH_Save); t.refresh()
                else t.keyCode=kc; Config.keybinds[t.configKey]=kc.Name; pcall(FH_Save); t.refresh() end
            elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then
                local t=hdrBindTarget; hdrBindTarget=nil; t.refresh()
            end; return
        end
        if gpe then return end
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            for _,e in ipairs(hdrBinds) do if e.keyCode and inp.KeyCode==e.keyCode then e.fire() end end
        end
    end)
end

-- ── Drag ─────────────────────────────────────────────────────
do
    local dragging,dragStart,winStart,_moved
    Hdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; _moved=false; dragStart=inp.Position; winStart=Win.Position
        end
    end)
    Hdr.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=false; _moved=false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local d=inp.Position-dragStart
            if not _moved and d.Magnitude<6 then return end
            _moved=true
            Win.Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,winStart.Y.Scale,winStart.Y.Offset+d.Y)
        end
    end)
end

-- ── Tab bar ───────────────────────────────────────────────────
local TabBar = Instance.new("Frame")
TabBar.Size=UDim2.new(1,0,0,34); TabBar.Position=UDim2.new(0,0,0,42)
TabBar.BackgroundColor3=Color3.fromRGB(8,8,14); TabBar.BackgroundTransparency=0.1
TabBar.BorderSizePixel=0; TabBar.ZIndex=4; TabBar.Parent=Win
local TBLine = Instance.new("Frame")
TBLine.Size=UDim2.new(1,0,0,1); TBLine.Position=UDim2.new(0,0,0,75)
TBLine.BackgroundColor3=T.Border; TBLine.BorderSizePixel=0; TBLine.ZIndex=5; TBLine.Parent=Win
local TabLayout=Instance.new("UIListLayout"); TabLayout.FillDirection=Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left; TabLayout.VerticalAlignment=Enum.VerticalAlignment.Center
TabLayout.Padding=UDim.new(0,0); TabLayout.Parent=TabBar
local ContentArea=Instance.new("Frame")
ContentArea.Size=UDim2.new(1,0,1,-76); ContentArea.Position=UDim2.new(0,0,0,76)
ContentArea.BackgroundTransparency=1; ContentArea.ClipsDescendants=true; ContentArea.ZIndex=2; ContentArea.Parent=Win

-- ── UI builders ───────────────────────────────────────────────
local CreateToggle, CreateSection, CreateButton, MakeScroll

MakeScroll = function(parent)
    local s=Instance.new("ScrollingFrame"); s.Size=UDim2.new(1,0,1,0)
    s.BackgroundTransparency=1; s.BorderSizePixel=0; s.ScrollBarThickness=3
    s.ScrollBarImageColor3=T.Accent; s.CanvasSize=UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.ScrollingDirection=Enum.ScrollingDirection.Y
    s.ZIndex=2; s.Parent=parent
    local l=Instance.new("UIListLayout"); l.FillDirection=Enum.FillDirection.Vertical
    l.HorizontalAlignment=Enum.HorizontalAlignment.Center; l.Padding=UDim.new(0,6); l.Parent=s
    Padding(s,10,10,8,8); return s
end

CreateSection = function(parent, title)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-16,0,26); f.BackgroundTransparency=1; f.Parent=parent
    local lw=#title*7+6
    local lbl=Label(f,title,10,T.Dim,Enum.Font.GothamBold)
    lbl.Size=UDim2.new(0,lw,1,0); lbl.Position=UDim2.new(0,4,0,0)
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=2
    local line=Instance.new("Frame"); line.Size=UDim2.new(1,-(lw+14),0,1)
    line.Position=UDim2.new(0,lw+10,0.5,0); line.BackgroundColor3=T.Border
    line.BorderSizePixel=0; line.Parent=f
end

CreateToggle = function(parent, name, desc, cb)
    local state  = (Config.toggles[name]==true)
    local hasDesc = desc and desc~=""
    local cardH  = hasDesc and 56 or 44
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,-16,0,cardH)
    card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
    card.BorderSizePixel=0; card.Parent=parent; Corner(card,8)
    local cStroke=Stroke(card,T.Border,1)
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,3,0,cardH-16)
    bar.Position=UDim2.new(0,0,0,8); bar.BackgroundColor3=T.TrackOff; bar.BorderSizePixel=0; bar.ZIndex=2; bar.Parent=card; Corner(bar,2)
    local nameY=hasDesc and 10 or (cardH/2-8)
    local nl=Label(card,name,isMobile and 11 or 13,T.White,Enum.Font.GothamMedium)
    nl.Size=UDim2.new(1,-108,0,16); nl.Position=UDim2.new(0,14,0,nameY); nl.ZIndex=2; nl.TextTruncate=Enum.TextTruncate.AtEnd
    if hasDesc then
        local dl=Label(card,desc,isMobile and 9 or 11,T.Dim,Enum.Font.Gotham)
        dl.Size=UDim2.new(1,-108,0,14); dl.Position=UDim2.new(0,14,0,nameY+18); dl.ZIndex=2; dl.TextTruncate=Enum.TextTruncate.AtEnd
    end
    local kbLbl=Instance.new("TextLabel"); kbLbl.Size=UDim2.new(0,32,0,16)
    kbLbl.Position=UDim2.new(1,-92,0.5,-8); kbLbl.BackgroundTransparency=1; kbLbl.Text=""
    kbLbl.TextSize=10; kbLbl.Font=Enum.Font.GothamBold; kbLbl.TextColor3=T.Dim
    kbLbl.TextXAlignment=Enum.TextXAlignment.Center; kbLbl.ZIndex=3; kbLbl.Parent=card
    local track=Instance.new("Frame"); track.Size=UDim2.new(0,40,0,22)
    track.Position=UDim2.new(1,-52,0.5,-11); track.BackgroundColor3=T.TrackOff
    track.BorderSizePixel=0; track.ZIndex=2; track.Parent=card; Corner(track,11)
    local tStroke=Stroke(track,T.Border,1)
    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,16,0,16)
    knob.Position=UDim2.new(0,3,0.5,-8); knob.BackgroundColor3=T.KnobOff
    knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=track; Corner(knob,8)
    card.MouseEnter:Connect(function() Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end)
    card.MouseLeave:Connect(function() Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}) end)
    local btn=Instance.new("Frame"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.ZIndex=4; btn.Active=true; btn.Parent=card
    local keybindEntry={keyCode=nil}
    local function applyV(s)
        if s then
            knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,21,0.5,-8)
            knob.BackgroundColor3=T.KnobOn; track.BackgroundColor3=T.TrackOn; tStroke.Color=T.TrackOn; bar.BackgroundColor3=T.Accent
        else
            knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,3,0.5,-8)
            knob.BackgroundColor3=T.KnobOff; track.BackgroundColor3=T.TrackOff; tStroke.Color=T.Border; bar.BackgroundColor3=T.TrackOff
        end
    end
    local function doToggle()
        state=not state
        if state then
            Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,4,0.5,-7)})
            task.delay(0.06, function()
                Tween(knob,M,{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,21,0.5,-8)})
                Tween(knob,M,{BackgroundColor3=T.KnobOn}); Tween(track,M,{BackgroundColor3=T.TrackOn})
                Tween(tStroke,M,{Color=T.TrackOn}); Tween(bar,M,{BackgroundColor3=T.Accent})
            end)
        else
            Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,20,0.5,-7)})
            task.delay(0.06, function()
                Tween(knob,M,{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0.5,-8)})
                Tween(knob,M,{BackgroundColor3=T.KnobOff}); Tween(track,M,{BackgroundColor3=T.TrackOff})
                Tween(tStroke,M,{Color=T.Border}); Tween(bar,M,{BackgroundColor3=T.TrackOff})
            end)
        end
        if cb then pcall(cb,state) end
        Config.toggles[name]=state; pcall(FH_Save)
        pcall(ShowToggleNotification,name,state)
    end
    local _bta=false; local _bts=nil
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            _bta=true; _bts=inp.Position
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) and _bta then
            _bta=false
            if _bts and (inp.Position-_bts).Magnitude<20 then doToggle() end
            _bts=nil
        end
    end)
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType~=Enum.UserInputType.MouseButton2 then return end
        if keybindBindingTarget then
            local prev=keybindBindingTarget; keybindBindingTarget=nil
            if prev.kbLbl==kbLbl then kbLbl.Text=keybindEntry.keyCode and ("["..keybindEntry.keyCode.Name.."]") or ""; kbLbl.TextColor3=T.Dim; return
            else prev.kbLbl.Text=prev.entry.keyCode and ("["..prev.entry.keyCode.Name.."]") or ""; prev.kbLbl.TextColor3=T.Dim end
        end
        kbLbl.Text="(...)"; kbLbl.TextColor3=T.White; keybindBindingTarget={entry=keybindEntry,kbLbl=kbLbl,mode="assign"}
    end)
    table.insert(keybindEntries,{entry=keybindEntry,fire=doToggle})
    configRegistry[name]={
        getState=function() return state end,
        getKeyCode=function() return keybindEntry.keyCode end,
        setKeyCode=function(kc)
            keybindEntry.keyCode=kc
            if kc then kbLbl.Text="["..kc.Name.."]"; kbLbl.TextColor3=T.Dim; Config.keybinds[name]=kc.Name
            else kbLbl.Text=""; Config.keybinds[name]=nil end; pcall(FH_Save)
        end,
        doToggle=doToggle,
        setEnabled=function(v) state=v; applyV(v); Config.toggles[name]=v; pcall(FH_Save); if cb then pcall(cb,v) end end,
    }
    if state then applyV(true); task.spawn(function() pcall(cb,true) end) end
end

CreateButton = function(parent, name, desc, cb)
    local hasDesc=desc and desc~=""
    local cardH=hasDesc and 56 or 44
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,-16,0,cardH)
    card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
    card.BorderSizePixel=0; card.Parent=parent; Corner(card,8)
    local cStroke=Stroke(card,T.Border,1)
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,3,0,cardH-16)
    bar.Position=UDim2.new(0,0,0,8); bar.BackgroundColor3=T.TrackOff; bar.BorderSizePixel=0; bar.ZIndex=2; bar.Parent=card; Corner(bar,2)
    local nameY=hasDesc and 10 or (cardH/2-8)
    local nl2=Label(card,name,isMobile and 11 or 13,T.White,Enum.Font.GothamMedium)
    nl2.Size=UDim2.new(1,-108,0,16); nl2.Position=UDim2.new(0,14,0,nameY); nl2.ZIndex=2; nl2.TextTruncate=Enum.TextTruncate.AtEnd
    if hasDesc then
        local dl2=Label(card,desc,isMobile and 9 or 11,T.Dim,Enum.Font.Gotham)
        dl2.Size=UDim2.new(1,-108,0,14); dl2.Position=UDim2.new(0,14,0,nameY+18); dl2.ZIndex=2; dl2.TextTruncate=Enum.TextTruncate.AtEnd
    end
    local kbLbl2=Instance.new("TextLabel"); kbLbl2.Size=UDim2.new(0,32,0,16)
    kbLbl2.Position=UDim2.new(1,-92,0.5,-8); kbLbl2.BackgroundTransparency=1; kbLbl2.Text=""
    kbLbl2.TextSize=10; kbLbl2.Font=Enum.Font.GothamBold; kbLbl2.TextColor3=T.Dim
    kbLbl2.TextXAlignment=Enum.TextXAlignment.Center; kbLbl2.ZIndex=3; kbLbl2.Parent=card
    local runLbl=Instance.new("TextLabel"); runLbl.Size=UDim2.new(0,52,0,24)
    runLbl.Position=UDim2.new(1,-60,0.5,-12); runLbl.BackgroundColor3=T.Card; runLbl.BorderSizePixel=0
    runLbl.Text="RUN"; runLbl.TextSize=11; runLbl.Font=Enum.Font.GothamBold; runLbl.TextColor3=T.White
    runLbl.TextXAlignment=Enum.TextXAlignment.Center; runLbl.ZIndex=3; runLbl.Parent=card; Corner(runLbl,7)
    local runStroke=Stroke(runLbl,T.Border,1)
    card.MouseEnter:Connect(function() Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}); Tween(runLbl,F,{BackgroundColor3=T.CardHover}) end)
    card.MouseLeave:Connect(function() Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}); Tween(runLbl,F,{BackgroundColor3=T.Card}) end)
    local btn2=Instance.new("Frame"); btn2.Size=UDim2.new(1,0,1,0); btn2.BackgroundTransparency=1; btn2.ZIndex=4; btn2.Active=true; btn2.Parent=card
    local ke2={keyCode=nil}
    local function fireButton()
        Tween(bar,F,{BackgroundColor3=T.Accent}); Tween(runLbl,F,{BackgroundColor3=T.AccentBright})
        Tween(runStroke,F,{Color=T.AccentBright}); runLbl.TextColor3=Color3.fromRGB(10,10,20)
        task.spawn(function() pcall(cb) end)
        task.delay(0.35, function()
            Tween(bar,M,{BackgroundColor3=T.TrackOff}); Tween(runLbl,M,{BackgroundColor3=T.Card})
            Tween(runStroke,M,{Color=T.Border}); runLbl.TextColor3=T.White
        end)
    end
    local deb=false; local _ats2=nil
    btn2.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            if deb then return end; deb=true; fireButton(); task.delay(0.4,function() deb=false end)
        elseif inp.UserInputType==Enum.UserInputType.Touch then _ats2=inp.Position end
    end)
    btn2.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch and _ats2 then
            local m=(inp.Position-_ats2).Magnitude; _ats2=nil
            if m<20 then if deb then return end; deb=true; fireButton(); task.delay(0.4,function() deb=false end) end
        end
    end)
    table.insert(keybindEntries,{entry=ke2,fire=fireButton})
    configRegistry[name]={getState=function() return false end,getKeyCode=function() return ke2.keyCode end,setKeyCode=function(kc)
        ke2.keyCode=kc
        if kc then kbLbl2.Text="["..kc.Name.."]"; kbLbl2.TextColor3=T.Dim; Config.keybinds[name]=kc.Name
        else kbLbl2.Text=""; Config.keybinds[name]=nil end; pcall(FH_Save)
    end}
    local saved2=Config.keybinds[name]
    if saved2 then local ok2,kc=pcall(function() return Enum.KeyCode[saved2] end); if ok2 and kc then ke2.keyCode=kc; kbLbl2.Text="["..kc.Name.."]"; kbLbl2.TextColor3=T.Dim end end
end

UserInputService.InputBegan:Connect(function(inp, gpe)
    if keybindBindingTarget then
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            local kc=inp.KeyCode
            if kc==Enum.KeyCode.Escape then
                local _t=keybindBindingTarget
                if _t.entry.keyCode then _t.kbLbl.Text="["..(_t.entry.keyCode.Name).."]"; _t.kbLbl.TextColor3=T.Dim
                else _t.kbLbl.Text="" end; keybindBindingTarget=nil
            elseif kc==Enum.KeyCode.Backspace then
                local _t=keybindBindingTarget; _t.entry.keyCode=nil; _t.kbLbl.Text=""; _t.kbLbl.TextColor3=T.Dim
                for tn,reg in pairs(configRegistry) do if reg.getKeyCode and reg.getKeyCode()==nil then Config.keybinds[tn]=nil end end
                pcall(FH_Save); keybindBindingTarget=nil
            else
                local _t=keybindBindingTarget; _t.entry.keyCode=kc; _t.kbLbl.Text="["..kc.Name.."]"; _t.kbLbl.TextColor3=T.Dim
                local m=0
                for tn,reg in pairs(configRegistry) do
                    local ok2,rk=pcall(reg.getKeyCode); if ok2 and rk==kc then Config.keybinds[tn]=kc.Name; if reg.setKeyCode then pcall(reg.setKeyCode,kc) end; m=m+1 end
                end
                pcall(FH_Save); pcall(ShowToggleNotification,"Keybind ["..kc.Name.."] bound ("..m..")",true); keybindBindingTarget=nil
            end; return
        elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then
            local prev=keybindBindingTarget; keybindBindingTarget=nil
            if prev.entry.keyCode then prev.kbLbl.Text="["..prev.entry.keyCode.Name.."]"; prev.kbLbl.TextColor3=T.Dim
            else prev.kbLbl.Text="" end
        end; return
    end
    if gpe then return end
    if inp.UserInputType==Enum.UserInputType.Keyboard then
        for _,b in ipairs(keybindEntries) do if b.entry.keyCode and inp.KeyCode==b.entry.keyCode then b.fire() end end
    end
end)

-- ── Tabs ─────────────────────────────────────────────────────
local Tabs, ActiveTab, TabSwiping = {}, nil, false
local SLIDE_IN  = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SLIDE_OUT = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local function TabIndex(t) for i,v in ipairs(Tabs) do if v==t then return i end end; return 0 end
local function ActivateTab(tab)
    if ActiveTab==tab then return end; if TabSwiping then return end
    local old=ActiveTab; ActiveTab=tab
    if old then Tween(old.lbl,F,{TextColor3=T.TabInact}); Tween(old.indicator,M,{Size=UDim2.new(0,0,0,2)}) end
    Tween(tab.lbl,F,{TextColor3=T.TabActive}); Tween(tab.indicator,M,{Size=UDim2.new(0.8,0,0,2)})
    if old then
        TabSwiping=true
        local goRight=(TabIndex(tab)>TabIndex(old))
        tab.page.Position=goRight and UDim2.new(1,0,0,0) or UDim2.new(-1,0,0,0); tab.page.Visible=true
        local exitPos=goRight and UDim2.new(-1,0,0,0) or UDim2.new(1,0,0,0)
        Tween(old.page,SLIDE_OUT,{Position=exitPos})
        local tw=TweenService:Create(tab.page,SLIDE_IN,{Position=UDim2.new(0,0,0,0)})
        tw:Play(); tw.Completed:Connect(function() old.page.Visible=false; old.page.Position=UDim2.new(0,0,0,0); TabSwiping=false end)
    else tab.page.Position=UDim2.new(0,0,0,0); tab.page.Visible=true end
end
local function CreateTab(name)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0.5,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=5; btn.Parent=TabBar
    local lbl=Label(btn,name,isMobile and 9 or 11,T.TabInact,Enum.Font.GothamBold)
    lbl.Size=UDim2.new(1,-2,1,0); lbl.Position=UDim2.new(0,1,0,0)
    lbl.TextXAlignment=Enum.TextXAlignment.Center; lbl.TextWrapped=true; lbl.ZIndex=6
    local sc=Instance.new("UITextSizeConstraint"); sc.MaxTextSize=isMobile and 9 or 11; sc.MinTextSize=5; sc.Parent=lbl
    local ind=Instance.new("Frame"); ind.Size=UDim2.new(0,0,0,2); ind.Position=UDim2.new(0.1,0,1,-2)
    ind.BackgroundColor3=T.Accent; ind.BorderSizePixel=0; ind.ZIndex=7; ind.Parent=btn; Corner(ind,1)
    local page=Instance.new("Frame"); page.Size=UDim2.new(1,0,1,0); page.Position=UDim2.new(0,0,0,0)
    page.BackgroundTransparency=1; page.Visible=false; page.ClipsDescendants=true; page.ZIndex=2; page.Parent=ContentArea
    local scroll=MakeScroll(page)
    local tab={btn=btn,lbl=lbl,indicator=ind,page=page,scroll=scroll}
    btn.MouseButton1Click:Connect(function() ActivateTab(tab) end)
    table.insert(Tabs,tab); return tab
end

local BrainrotsTab = CreateTab("BRAINROTS")
local SettingsTab  = CreateTab("SETTINGS")

-- ══════════════════════════════════════════════════════════════
--  BRAINROTS TAB  (animal scanner + viewport)
-- ══════════════════════════════════════════════════════════════
do
    local RS=game:GetService("ReplicatedStorage")
    local AnimalsData, AnimalsShared, NumberUtils
    pcall(function() AnimalsData   = require(RS:WaitForChild("Datas",30):WaitForChild("Animals",30)) end)
    pcall(function() NumberUtils   = require(RS:WaitForChild("Utils",30):WaitForChild("NumberUtils",30)) end)
    pcall(function() AnimalsShared = require(RS:WaitForChild("Shared",30):WaitForChild("Animals",30)) end)
    local RequestData
    pcall(function()
        local pkg=RS:WaitForChild("Packages",15):WaitForChild("Synchronizer",15)
        RequestData=pkg:FindFirstChild("RequestData")
    end)
    local PlotSyncCaches={}
    local function fmtNum(n)
        if NumberUtils and NumberUtils.ToString then local ok,s=pcall(function() return NumberUtils:ToString(n) end); if ok and s then return s end end
        return tostring(n)
    end
    local function getGen(idx,mut,traits)
        if not AnimalsShared or not AnimalsShared.GetGeneration then return 0 end
        local ok,v=pcall(function() return AnimalsShared:GetGeneration(idx,mut,traits,nil) end)
        if not ok or not v then ok,v=pcall(function() return AnimalsShared:GetGeneration(idx,mut,nil,nil) end) end
        if not ok or not v then ok,v=pcall(function() return AnimalsShared:GetGeneration(idx) end) end
        return (ok and v) or 0
    end
    local function dispName(idx)
        local info=AnimalsData and AnimalsData[idx]; return (info and info.DisplayName) or tostring(idx)
    end
    local function isMyPlot(plot)
        local sign=plot:FindFirstChild("PlotSign")
        return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled or false
    end
    local function plotOwner(plot)
        local sign=plot:FindFirstChild("PlotSign",true)
        if sign then
            for _,d in ipairs(sign:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and d.Text~="" then
                    if d.Text:lower():find("empty") then return "Empty" end
                    local m=d.Text:match("[Bb]ase [Oo]f%s+(.+)"); if m then return m end
                    if #d.Text>0 and #d.Text<30 then return d.Text end
                end
            end
        end
        local s2=plot:FindFirstChild("PlotSign")
        return (s2 and s2:FindFirstChild("YourBase") and s2.YourBase.Enabled) and "YOU" or "?"
    end
    local function getPlotOrder(plot)
        local ok,order=pcall(function() return plot:GetAttribute("Order") end)
        if ok and order then return "Base "..tostring(order) end
        return plot.Name
    end
    local function getAnimalList(plot)
        if RequestData then
            PlotSyncCaches[plot.Name]=nil
            local ok,data=pcall(function() return RequestData:InvokeServer(plot.Name) end)
            if ok and typeof(data)=="table" then
                PlotSyncCaches[plot.Name]=data
                if typeof(data.AnimalList)=="table" then return data.AnimalList end
            end
        end
        local cache=PlotSyncCaches[plot.Name]
        if cache and typeof(cache.AnimalList)=="table" then return cache.AnimalList end
        return nil
    end
    local function getMutRarity(mutName)
        if not mutName or mutName=="None" then return "Common" end
        local rarities = {
            Gold="Rare", Diamond="Epic", Bloodrot="Epic", Candy="Uncommon",
            Lava="Rare", Galaxy="Legendary", YinYang="Legendary",
            Radioactive="Rare", Cursed="Epic", Divine="Legendary", Rainbow="Legendary",
        }
        return rarities[mutName] or "Uncommon"
    end
    local function scanAll()
        local results={}
        local pf=workspace:FindFirstChild("Plots"); if not pf then return results end
        for _,plot in ipairs(pf:GetChildren()) do
            if not plot:IsA("Model") then continue end
            if isMyPlot(plot) then continue end
            pcall(function()
                local al=getAnimalList(plot); if typeof(al)~="table" then return end
                local owner=plotOwner(plot)
                for slot,data in pairs(al) do
                    pcall(function()
                        if typeof(data)=="table" and data.Index then
                            local gen=getGen(data.Index,data.Mutation,data.Traits)
                            local podiumOk
                            local podiums=plot:FindFirstChild("AnimalPodiums")
                            podiumOk=podiums and podiums:FindFirstChild(tostring(slot))~=nil
                            table.insert(results,{
                                name=dispName(data.Index), animalIndex=data.Index,
                                mutation=data.Mutation, traits=data.Traits,
                                genValue=gen, genText="$"..fmtNum(gen).."/s",
                                plotName=plot.Name, plotOrder=getPlotOrder(plot),
                                owner=owner, slot=tostring(slot), podiumExists=podiumOk,
                                rarity=getMutRarity(data.Mutation),
                            })
                        end
                    end)
                end
            end)
        end
        table.sort(results, function(a,b) return (a.genValue or 0)>(b.genValue or 0) end)
        return results
    end

    local MUT_COLS = {
        Gold=Color3.fromRGB(237,178,0), Diamond=Color3.fromRGB(37,196,254),
        Bloodrot=Color3.fromRGB(145,0,27), Candy=Color3.fromRGB(255,105,180),
        Lava=Color3.fromRGB(200,50,0), Galaxy=Color3.fromRGB(180,0,255),
        YinYang=Color3.fromRGB(200,200,200), Radioactive=Color3.fromRGB(100,255,0),
        Cursed=Color3.fromRGB(255,23,23), Divine=Color3.fromRGB(255,215,0),
        Rainbow=Color3.fromRGB(255,100,200),
    }

    CreateSection(BrainrotsTab.scroll, "ANIMALS ON PLOTS")
    local cardContainer=Instance.new("Frame"); cardContainer.Name="BrainrotCards"
    cardContainer.BackgroundTransparency=1; cardContainer.Size=UDim2.new(1,-16,0,0)
    cardContainer.AutomaticSize=Enum.AutomaticSize.Y; cardContainer.BorderSizePixel=0; cardContainer.Parent=BrainrotsTab.scroll
    local cl=Instance.new("UIListLayout"); cl.FillDirection=Enum.FillDirection.Vertical
    cl.HorizontalAlignment=Enum.HorizontalAlignment.Center; cl.SortOrder=Enum.SortOrder.LayoutOrder
    cl.Padding=UDim.new(0,6); cl.Parent=cardContainer

    local builtUIDs, labelUpdaters, onSelectCBs = {},{},{}
    local selectedUID = nil

    local CARD_H = 100
    local function buildCard(rec, index)
        local uid = rec.plotName.."_"..rec.slot
        local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,CARD_H)
        card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
        card.BorderSizePixel=0; card.LayoutOrder=index; card.Name="Card_"..uid; card.Parent=cardContainer
        Corner(card,8)
        local cStroke=Stroke(card,T.Border,1)

        -- mutation color bar on left
        local mutCol = (rec.mutation and MUT_COLS[tostring(rec.mutation)]) or T.Accent
        local mutBar=Instance.new("Frame"); mutBar.Size=UDim2.new(0,3,1,-12)
        mutBar.Position=UDim2.new(0,0,0,6); mutBar.BackgroundColor3=mutCol
        mutBar.BorderSizePixel=0; mutBar.ZIndex=2; mutBar.Parent=card; Corner(mutBar,2)

        local infoFrame=Instance.new("Frame"); infoFrame.Size=UDim2.new(1,-16,1,0)
        infoFrame.Position=UDim2.new(0,12,0,0); infoFrame.BackgroundTransparency=1
        infoFrame.BorderSizePixel=0; infoFrame.ZIndex=3; infoFrame.Parent=card

        local nl3=Label(infoFrame,rec.name,isMobile and 11 or 13,T.White,Enum.Font.GothamBold)
        nl3.Size=UDim2.new(1,-70,0,16); nl3.Position=UDim2.new(0,0,0,8); nl3.TextTruncate=Enum.TextTruncate.AtEnd; nl3.ZIndex=3

        local mutTxt=(rec.mutation and tostring(rec.mutation)~="None") and tostring(rec.mutation) or "No Mutation"
        local mutLbl2=Label(infoFrame,mutTxt,isMobile and 9 or 11,mutCol,Enum.Font.GothamMedium)
        mutLbl2.Size=UDim2.new(1,-70,0,13); mutLbl2.Position=UDim2.new(0,0,0,26); mutLbl2.TextTruncate=Enum.TextTruncate.AtEnd; mutLbl2.ZIndex=3

        local genLbl3=Label(infoFrame,"⚡ "..rec.genText,isMobile and 9 or 11,Color3.fromRGB(80,200,120),Enum.Font.GothamBold)
        genLbl3.Size=UDim2.new(1,-70,0,13); genLbl3.Position=UDim2.new(0,0,0,41); genLbl3.ZIndex=3

        local rarLbl=Label(infoFrame,rec.rarity or "",isMobile and 8 or 10,T.Dim,Enum.Font.GothamBold)
        rarLbl.Size=UDim2.new(1,-70,0,12); rarLbl.Position=UDim2.new(0,0,0,56); rarLbl.ZIndex=3

        local podLbl=Label(infoFrame,(rec.plotOrder or rec.plotName).." • #"..rec.slot,isMobile and 8 or 10,T.Dim,Enum.Font.GothamMedium)
        podLbl.Size=UDim2.new(1,-70,0,12); podLbl.Position=UDim2.new(0,0,0,70); podLbl.TextTruncate=Enum.TextTruncate.AtEnd; podLbl.ZIndex=3

        local selBtn2=Instance.new("TextButton"); selBtn2.Size=UDim2.new(0,60,0,26)
        selBtn2.Position=UDim2.new(1,-66,0.5,-13); selBtn2.BackgroundColor3=T.Card
        selBtn2.BorderSizePixel=0; selBtn2.Text="SELECT"; selBtn2.TextSize=isMobile and 9 or 11
        selBtn2.Font=Enum.Font.GothamBold; selBtn2.TextColor3=T.Dim; selBtn2.ZIndex=4
        selBtn2.AutoButtonColor=false; selBtn2.Parent=card; Corner(selBtn2,6)
        local selStroke2=Stroke(selBtn2,T.Border,1)

        local isSelected=false
        local function applySelV(v)
            isSelected=v
            if v then
                TweenService:Create(selBtn2,F,{BackgroundColor3=T.Accent,TextColor3=T.White}):Play()
                TweenService:Create(selStroke2,F,{Color=T.Accent}):Play()
                TweenService:Create(cStroke,F,{Color=T.AccentBright,Thickness=2}):Play()
            else
                TweenService:Create(selBtn2,F,{BackgroundColor3=T.Card,TextColor3=T.Dim}):Play()
                TweenService:Create(selStroke2,F,{Color=T.Border}):Play()
                TweenService:Create(cStroke,F,{Color=T.Border,Thickness=1}):Play()
            end
        end
        onSelectCBs[uid]=function(off) if off and isSelected then applySelV(false) end end
        if not _G._FH_CardSelectFns then _G._FH_CardSelectFns={} end
        _G._FH_CardSelectFns[uid]=function()
            if isSelected then return end
            if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
            applySelV(true); selectedUID=uid
            _G._FH_SelectedBrainrot={uid=uid,name=rec.name,mutation=rec.mutation,gen=rec.genValue,
                genText=rec.genText,plotName=rec.plotName,slot=rec.slot,owner=rec.owner}
        end
        selBtn2.MouseButton1Click:Connect(function()
            if isSelected then applySelV(false); selectedUID=nil; _G._FH_SelectedBrainrot=nil
            else
                if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
                applySelV(true); selectedUID=uid
                _G._FH_SelectedBrainrot={uid=uid,name=rec.name,mutation=rec.mutation,gen=rec.genValue,
                    genText=rec.genText,plotName=rec.plotName,slot=rec.slot,owner=rec.owner}
            end
        end)
        card.MouseEnter:Connect(function() if not isSelected then Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end end)
        card.MouseLeave:Connect(function() if not isSelected then Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}) end end)
        labelUpdaters[uid]=function(nr,ni)
            local mc2=(nr.mutation and MUT_COLS[tostring(nr.mutation)]) or T.Accent
            mutBar.BackgroundColor3=mc2
            mutLbl2.Text=(nr.mutation and tostring(nr.mutation)~="None") and tostring(nr.mutation) or "No Mutation"
            mutLbl2.TextColor3=mc2
            genLbl3.Text="⚡ "..nr.genText; rarLbl.Text=nr.rarity or ""
            podLbl.Text=(nr.plotOrder or nr.plotName).." • #"..nr.slot; card.LayoutOrder=ni
        end
    end

    local scanning=false
    local function doScan()
        if scanning then return end; scanning=true
        task.spawn(function()
            local ok,results=pcall(scanAll); if not ok or not results then results={} end
            _G._FH_LastAnimalScan=results
            local seen={}
            for _,rec in ipairs(results) do seen[rec.plotName.."_"..rec.slot]=true end
            for uid in pairs(builtUIDs) do
                if not seen[uid] then
                    for _,c in ipairs(cardContainer:GetChildren()) do
                        if c:IsA("Frame") and c.Name=="Card_"..uid then c:Destroy(); break end
                    end
                    builtUIDs[uid]=nil; labelUpdaters[uid]=nil; onSelectCBs[uid]=nil
                    if selectedUID==uid then selectedUID=nil; _G._FH_SelectedBrainrot=nil end
                end
            end
            for i,rec in ipairs(results) do
                local uid=rec.plotName.."_"..rec.slot
                if not builtUIDs[uid] then buildCard(rec,i); builtUIDs[uid]=true
                else if labelUpdaters[uid] then labelUpdaters[uid](rec,i) end end
            end
            scanning=false
        end)
    end

    local function autoSelectBest()
        local r=_G._FH_LastAnimalScan; if not r or #r==0 then return end
        local best=r[1]; if not best then return end
        local uid=best.plotName.."_"..best.slot
        if selectedUID==uid then return end
        if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
        selectedUID=uid
        _G._FH_SelectedBrainrot={uid=uid,name=best.name,mutation=best.mutation,gen=best.genValue,
            genText=best.genText,plotName=best.plotName,slot=best.slot,owner=best.owner}
        if _G._FH_CardSelectFns and _G._FH_CardSelectFns[uid] then pcall(_G._FH_CardSelectFns[uid]) end
    end
    _G._FH_AutoSelectBest=autoSelectBest

    task.spawn(function()
        task.wait(2)
        while true do
            doScan(); task.wait(0.05)
            if AutoSelectBestBrainrot then pcall(autoSelectBest) end
            task.wait(4.95)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  SETTINGS TAB
-- ══════════════════════════════════════════════════════════════
CreateSection(SettingsTab.scroll, "AUTO RESET")
do
    local _arbConns={},  _arbBound={}, _arbConn, _arbLast=0
    local function doReset()
        local lp=Players.LocalPlayer
        local Net=ReplicatedStorage:WaitForChild("Packages",2) and ReplicatedStorage.Packages:WaitForChild("Net",2)
        if not Net then local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid"); if h then h.Health=0 end; return end
        local remote; local ch=Net:GetChildren()
        for i=1,#ch-1 do if ch[i] and ch[i+1] and string.find(ch[i].Name,"Tools/Cooldown") then remote=ch[i+1]; break end end
        if not remote then local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid"); if h then h.Health=0 end; return end
        local saved={}; local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        if char then local hm=char:FindFirstChildOfClass("Humanoid"); if hm then pcall(function() hm:UnequipTools() end) end
            for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(saved,t); t.Parent=nil end end end
        if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(saved,t); t.Parent=nil end end end
        lp.Character=nil; local sending=true; local lc; local fire=remote.FireServer; local thr=0
        lc=RunService.Heartbeat:Connect(function(dt)
            if not sending then if lc then lc:Disconnect(); lc=nil end; return end
            thr=thr+dt; if thr>=0.016 then thr=0; pcall(fire,remote,"f888ee6e-c86d-46e1-93d7-0639d6635d42",lp,"balloon") end
            if sending and lp.Character then lp.Character=nil end
        end)
        local cn; cn=lp.CharacterAdded:Connect(function()
            sending=false; if lc then lc:Disconnect(); lc=nil end; if cn then cn:Disconnect() end
            task.spawn(function()
                local nb=lp:WaitForChild("Backpack",3)
                if nb then for _,t in ipairs(saved) do if t then t.Parent=nb end end end; saved={}
            end)
        end)
        task.delay(4, function()
            sending=false; if lc then lc:Disconnect(); lc=nil end
            local cb=lp:FindFirstChild("Backpack")
            if cb and #saved>0 then for _,t in ipairs(saved) do if t then t.Parent=cb end end; saved={} end
        end)
    end
    _G._FH_DoSelectedReset=doReset
    local function bindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _arbBound[obj] then return end
        local ok,conn=pcall(function()
            return obj.OnClientEvent:Connect(function(...)
                if not AutoResetBalloonEnabled then return end
                for i=1,select("#",...) do
                    local a=select(i,...)
                    if type(a)=="string" and a:lower():find("jump higher",1,true) then
                        local now=tick(); if now-_arbLast<3 then return end; _arbLast=now; doReset(); return
                    end
                end
            end)
        end)
        if ok and conn then table.insert(_arbConns,conn); _arbBound[obj]=true end
    end
    local function startARB()
        for _,c in ipairs(_arbConns) do pcall(function() c:Disconnect() end) end
        _arbConns={}; _arbBound={}
        if _arbConn then pcall(function() _arbConn:Disconnect() end); _arbConn=nil end
        _arbConn=ReplicatedStorage.DescendantAdded:Connect(function(obj) if AutoResetBalloonEnabled then bindRemote(obj) end end)
        task.spawn(function() for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do if not AutoResetBalloonEnabled then break end; bindRemote(obj) end end)
    end
    local function stopARB()
        for _,c in ipairs(_arbConns) do pcall(function() c:Disconnect() end) end
        _arbConns={}; _arbBound={}
        if _arbConn then pcall(function() _arbConn:Disconnect() end); _arbConn=nil end
    end
    CreateToggle(SettingsTab.scroll, "Reset on balloon", "Auto reset if ballooned", function(v) AutoResetBalloonEnabled=v; if v then startARB() else stopARB() end end)
end

do
    local _tConns={}, _tBound={}, _tConn, _tLast=0
    local function bindT(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _tBound[obj] then return end
        local ok,conn=pcall(function()
            return obj.OnClientEvent:Connect(function(...)
                local AutoResetTinyEnabled=Config.toggles["Reset when tiny"]
                if not AutoResetTinyEnabled then return end
                for i=1,select("#",...) do
                    local a=select(i,...)
                    if type(a)=="string" and a:lower():find("tiny for 30",1,true) then
                        local now=tick(); if now-_tLast<3 then return end; _tLast=now
                        if _G._FH_DoSelectedReset then _G._FH_DoSelectedReset() end; return
                    end
                end
            end)
        end)
        if ok and conn then table.insert(_tConns,conn); _tBound[obj]=true end
    end
    local function startT()
        for _,c in ipairs(_tConns) do pcall(function() c:Disconnect() end) end
        _tConns={}; _tBound={}
        if _tConn then pcall(function() _tConn:Disconnect() end); _tConn=nil end
        for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do bindT(obj) end
        _tConn=ReplicatedStorage.DescendantAdded:Connect(function(obj) bindT(obj) end)
    end
    local function stopT()
        for _,c in ipairs(_tConns) do pcall(function() c:Disconnect() end) end
        _tConns={}; _tBound={}; if _tConn then pcall(function() _tConn:Disconnect() end); _tConn=nil end
    end
    CreateToggle(SettingsTab.scroll, "Reset when tiny", "Auto reset if shrunk", function(v)
        if v then startT() else stopT() end
    end)
end

do
    local _jConns={}, _jBound={}, _jConn, _jLast=0
    local function bindJ(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _jBound[obj] then return end
        local ok,conn=pcall(function()
            return obj.OnClientEvent:Connect(function(...)
                local AutoResetJailEnabled=Config.toggles["Reset on jail"]
                if not AutoResetJailEnabled then return end
                for i=1,select("#",...) do
                    local a=select(i,...)
                    if type(a)=="string" and a:lower():find("trapped for",1,true) then
                        local now=tick(); if now-_jLast<3 then return end; _jLast=now
                        if _G._FH_DoSelectedReset then _G._FH_DoSelectedReset() end; return
                    end
                end
            end)
        end)
        if ok and conn then table.insert(_jConns,conn); _jBound[obj]=true end
    end
    local function startJ()
        for _,c in ipairs(_jConns) do pcall(function() c:Disconnect() end) end
        _jConns={}; _jBound={}
        if _jConn then pcall(function() _jConn:Disconnect() end); _jConn=nil end
        for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do bindJ(obj) end
        _jConn=ReplicatedStorage.DescendantAdded:Connect(function(obj) bindJ(obj) end)
    end
    local function stopJ()
        for _,c in ipairs(_jConns) do pcall(function() c:Disconnect() end) end
        _jConns={}; _jBound={}; if _jConn then pcall(function() _jConn:Disconnect() end); _jConn=nil end
    end
    CreateToggle(SettingsTab.scroll, "Reset on jail", "Auto reset if jailed/trapped", function(v)
        if v then startJ() else stopJ() end
    end)
end

CreateSection(SettingsTab.scroll, "GRAB")
CreateToggle(SettingsTab.scroll, "Auto Block", "Blocks plot owner after grab (ping-based)", function(v) AutoBlockEnabled=v end)

CreateSection(SettingsTab.scroll, "FLASH")
CreateToggle(SettingsTab.scroll, "Auto Flash", "Auto uses flash on balloon trigger", function(v)
    AutoFlashEnabled=v
    if v then
        -- wire balloon detection to auto flash
        local _afLast=0; local _afPending=false
        local function tryAF()
            if not AutoFlashEnabled then return end
            if not _G._FH_SelectedBrainrot then pcall(ShowToggleNotification,"Auto Flash: select animal",false); return end
            if _afPending then return end; _afPending=true
            task.spawn(function()
                local lp=Players.LocalPlayer
                pcall(ShowToggleNotification,"Auto Flash: resetting...",true)
                if _G._FH_DoSelectedReset then pcall(_G._FH_DoSelectedReset) end
                local dl=tick()+8
                while (not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart")) and tick()<dl do task.wait(0.1) end
                if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then _afPending=false; return end
                task.wait(0.15)
                if not AutoFlashEnabled then _afPending=false; return end
                pcall(ShowToggleNotification,"Auto Flash: flashing!",true)
                if _G._FH_FlashBtnEntry then pcall(_G._FH_FlashBtnEntry.fire) end
                task.wait(3); _afPending=false
            end)
        end
        for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                pcall(function()
                    obj.OnClientEvent:Connect(function(...)
                        if not AutoFlashEnabled then return end
                        for i=1,select("#",...) do
                            local a=select(i,...)
                            if type(a)=="string" and a:lower():find("jump higher",1,true) then
                                local now=tick(); if now-_afLast<3 then return end; _afLast=now; tryAF(); return
                            end
                        end
                    end)
                end)
            end
        end
    end
end)

CreateToggle(SettingsTab.scroll, "Ragdoll Bypass", "Bypasses ragdoll via admin panel", function(v)
    RagdollBypassEnabled=v
end)

CreateToggle(SettingsTab.scroll, "Anti Ragdoll", "Prevents ragdoll from triggering", function(v)
    if v then AntiRagdoll.enable() else AntiRagdoll.disable() end
end)

CreateSection(SettingsTab.scroll, "DEFENSE")
CreateToggle(SettingsTab.scroll, "NOX Auto Balloon", "Balloons thieves entering your base zones", function(v)
    NoxBalloonEnabled=v
end)

CreateSection(SettingsTab.scroll, "AIMBOT")
CreateToggle(SettingsTab.scroll, "Solar Aimbot", "Background aimbot on nearest player", function(v)
    SolarAimbot.enabled=v
end)

CreateSection(SettingsTab.scroll, "PROTECTION")
CreateToggle(SettingsTab.scroll, "Anti Admin Panel", "Blocks admin commands (tiny, jail, ragdoll, giant, inverse)", function(v)
    AntiAdminEnabled=v
end)

CreateSection(SettingsTab.scroll, "BRAINROT")
CreateToggle(SettingsTab.scroll, "Auto Select Best", "Auto selects highest gen animal", function(v)
    AutoSelectBestBrainrot=v; Config.toggles["Auto Select Best"]=v; pcall(FH_Save)
    if v and _G._FH_LastAnimalScan and #_G._FH_LastAnimalScan>0 then pcall(_G._FH_AutoSelectBest) end
end)

CreateSection(SettingsTab.scroll, "ADMIN PANEL")
do
    local FP = {win=nil,visible=false,minimized=false}
    local FP_W=isMobile and 340 or 420
    local FP_ROW_H=isMobile and 38 or 46
    local FP_AVT=isMobile and 28 or 34
    local FP_BTN=isMobile and 26 or 30
    local FP_GAP=5
    local FP_HDR_H=36
    local FP_CMDS={{name="tiny",emoji="🤏"},{name="jail",emoji="🔒"},{name="rocket",emoji="🚀"},{name="ragdoll",emoji="🏃"},{name="balloon",emoji="🎈"}}
    local fpCoolBtns={} for _,c in ipairs(FP_CMDS) do fpCoolBtns[c.name]={} end
    local fpCmdCache,fpProfCache={},{}
    local fpCoolRunning=false

    local function fpGetAdminFrames()
        local ok,ap=pcall(function() return Players.LocalPlayer.PlayerGui.AdminPanel.AdminPanel end)
        if not ok or not ap then return nil,nil end
        local cont=ap:FindFirstChild("Content"); local prof=ap:FindFirstChild("Profiles")
        if not cont or not prof then return nil,nil end
        return cont:FindFirstChild("ScrollingFrame"), prof:FindFirstChild("ScrollingFrame")
    end
    local function fpCA(obj) local c={}; local ok2,cs=pcall(getconnections,obj.Activated); if ok2 and type(cs)=="table" then for _,cx in ipairs(cs) do if type(cx.Function)=="function" then table.insert(c,cx.Function) end end end; return c end
    local function fpFA(c) for _,fn in ipairs(c) do task.spawn(fn) end end
    local function fpIsCD(cmd)
        local ok,sf=pcall(function() return Players.LocalPlayer.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame end)
        if not ok or not sf then return false end
        local f=sf:FindFirstChild(cmd); if not f then return false end
        local t=f:FindFirstChild("Timer"); return t and t.Visible or false
    end
    local function fpCDText(cmd)
        local ok,sf=pcall(function() return Players.LocalPlayer.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame end)
        if not ok or not sf then return nil end
        local f=sf:FindFirstChild(cmd); if not f then return nil end
        local t=f:FindFirstChild("Timer"); if not t or not t.Visible then return nil end
        return t.Text or ""
    end
    local function fpRun(cmdName, target)
        local cf2,pf2=fpGetAdminFrames(); if not cf2 or not pf2 then return end
        local pb=pf2:FindFirstChild(target.Name); local cb=cf2:FindFirstChild(cmdName)
        if not pb or not cb then return end
        if not fpProfCache[target.Name] then fpProfCache[target.Name]=fpCA(pb) end
        if not fpCmdCache[cmdName] then fpCmdCache[cmdName]=fpCA(cb) end
        fpFA(fpProfCache[target.Name]); task.wait(); fpFA(fpCmdCache[cmdName])
    end

    local function fpCDLoop()
        if fpCoolRunning then return end; fpCoolRunning=true
        task.spawn(function()
            while FP.win and FP.win.Parent and FP.visible do
                for _,cmd in ipairs(FP_CMDS) do
                    local onCD=fpIsCD(cmd.name); local cdTxt=onCD and fpCDText(cmd.name) or nil
                    for _,e in ipairs(fpCoolBtns[cmd.name]) do
                        local btn2,emoji=e[1],e[2]
                        if btn2 and btn2.Parent then
                            if onCD and cdTxt then btn2.Text=cdTxt; btn2.TextSize=11; btn2.TextColor3=Color3.fromRGB(255,80,80); btn2.BackgroundTransparency=0.65
                            else btn2.Text=emoji; btn2.TextSize=isMobile and 15 or 18; btn2.TextColor3=T.White; btn2.BackgroundTransparency=0.3 end
                        end
                    end
                end
                task.wait(0.25)
            end; fpCoolRunning=false
        end)
    end

    local FP_MAX_ROWS=4
    local function fpH(rows)
        local r=math.min(rows,FP_MAX_ROWS); return FP_HDR_H+4+r*FP_ROW_H+math.max(0,r-1)*3+8
    end
    local function fpResize(rows,anim)
        if not FP.win or FP.minimized then return end
        local h=fpH(rows)
        if anim then Tween(FP.win,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,FP_W,0,h)})
        else FP.win.Size=UDim2.new(0,FP_W,0,h) end
        FP.scroll.ScrollBarThickness=rows>FP_MAX_ROWS and 3 or 0
    end

    local fpRefreshPlayers

    local function fpBuild()
        if FP.win then return end
        local win=Instance.new("Frame"); win.Name="VertxFastPanel"
        win.Size=UDim2.new(0,FP_W,0,fpH(0)); win.AnchorPoint=Vector2.new(0.5,1)
        win.Position=UDim2.new(0.5,0,1,-8); win.BackgroundColor3=T.BG
        win.BackgroundTransparency=0.04; win.BorderSizePixel=0; win.ZIndex=30
        win.Visible=false; win.Active=true; win.Draggable=true; win.ClipsDescendants=true; win.Parent=GUI
        Corner(win,10)
        local ws=Instance.new("UIStroke"); ws.Thickness=2; ws.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        ws.Color=T.AccentBright; ws.Parent=win
        local wg=Instance.new("UIGradient"); wg.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(30,60,160)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(120,180,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(30,60,160)),
        }); wg.Rotation=45; wg.Parent=ws
        local hdr2=Instance.new("Frame"); hdr2.Size=UDim2.new(1,0,0,FP_HDR_H)
        hdr2.BackgroundColor3=T.Header; hdr2.BorderSizePixel=0; hdr2.ZIndex=31; hdr2.Parent=win; Corner(hdr2,10)
        local hf2=Instance.new("Frame"); hf2.Size=UDim2.new(1,0,0,10); hf2.Position=UDim2.new(0,0,1,-10)
        hf2.BackgroundColor3=T.Header; hf2.BorderSizePixel=0; hf2.ZIndex=31; hf2.Parent=hdr2
        local tl2=Label(hdr2,"⚡ Quick Panel",isMobile and 12 or 15,T.White,Enum.Font.GothamBold)
        tl2.Size=UDim2.new(1,-50,1,0); tl2.Position=UDim2.new(0,10,0,0); tl2.ZIndex=32
        local mb2=Instance.new("TextButton"); mb2.Size=UDim2.new(0,22,0,18)
        mb2.AnchorPoint=Vector2.new(1,0.5); mb2.Position=UDim2.new(1,-8,0.5,0)
        mb2.BackgroundColor3=T.Card; mb2.BorderSizePixel=0; mb2.AutoButtonColor=false
        mb2.Text="—"; mb2.TextSize=isMobile and 9 or 11; mb2.Font=Enum.Font.GothamBold
        mb2.TextColor3=T.Dim; mb2.ZIndex=33; mb2.Parent=hdr2; Corner(mb2,5); Stroke(mb2,T.Border,1)
        local scroll2=Instance.new("ScrollingFrame"); scroll2.Name="FPScroll"
        scroll2.Size=UDim2.new(1,-10,1,-(FP_HDR_H+6)); scroll2.Position=UDim2.new(0,5,0,FP_HDR_H+4)
        scroll2.BackgroundTransparency=1; scroll2.BorderSizePixel=0; scroll2.ScrollBarThickness=0
        scroll2.ScrollBarImageColor3=T.Dim; scroll2.CanvasSize=UDim2.new(0,0,0,0); scroll2.ZIndex=31; scroll2.Parent=win
        local ll2=Instance.new("UIListLayout"); ll2.Padding=UDim.new(0,3)
        ll2.SortOrder=Enum.SortOrder.LayoutOrder; ll2.HorizontalAlignment=Enum.HorizontalAlignment.Center; ll2.Parent=scroll2
        ll2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll2.CanvasSize=UDim2.new(0,0,0,ll2.AbsoluteContentSize.Y+8)
        end)
        local ntl=Label(win,"No other players",isMobile and 9 or 11,T.Dim,Enum.Font.GothamMedium)
        ntl.Size=UDim2.new(1,-20,0,24); ntl.Position=UDim2.new(0,10,0,FP_HDR_H+8)
        ntl.TextXAlignment=Enum.TextXAlignment.Center; ntl.Visible=false; ntl.ZIndex=31
        FP.win=win; FP.scroll=scroll2; FP.listLayout=ll2; FP.noTargetLbl=ntl; FP.hdr=hdr2
        mb2.MouseButton1Click:Connect(function()
            FP.minimized=not FP.minimized
            if FP.minimized then
                Tween(win,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,FP_W,0,FP_HDR_H)})
                scroll2.Visible=false; ntl.Visible=false
            else scroll2.Visible=true; fpRefreshPlayers() end
        end)
        do
            local _d,_ds,_ws=false
            hdr2.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then _d=true; _ds=inp.Position; _ws=win.Position end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if _d and inp.UserInputType==Enum.UserInputType.MouseMovement then
                    local d=inp.Position-_ds; win.Position=UDim2.new(_ws.X.Scale,_ws.X.Offset+d.X,_ws.Y.Scale,_ws.Y.Offset+d.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then _d=false end
            end)
        end
    end

    local function fpMakeRow(plr, order)
        local row=Instance.new("Frame"); row.Name="FPRow_"..plr.Name
        row.Size=UDim2.new(1,-6,0,FP_ROW_H); row.BackgroundColor3=T.Card; row.BackgroundTransparency=0.1
        row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=32; row.Parent=FP.scroll; Corner(row,6); Stroke(row,T.Border,1)
        -- avatar
        local af=Instance.new("Frame"); af.Size=UDim2.new(0,FP_AVT,0,FP_AVT)
        af.Position=UDim2.new(0,5,0.5,-FP_AVT/2); af.BackgroundColor3=T.BG; af.BackgroundTransparency=0.4
        af.BorderSizePixel=0; af.ZIndex=33; af.Parent=row; Corner(af,math.floor(FP_AVT/2))
        local ai=Instance.new("ImageLabel"); ai.Size=UDim2.new(1,0,1,0); ai.BackgroundTransparency=1
        ai.Image=("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=48&height=48&format=png"):format(plr.UserId)
        ai.ScaleType=Enum.ScaleType.Crop; ai.ZIndex=34; ai.Parent=af; Corner(ai,math.floor(FP_AVT/2))
        -- name
        local dText=plr.DisplayName~=plr.Name and plr.DisplayName.." (@"..plr.Name..")" or plr.DisplayName
        local nl4=Label(row,dText,isMobile and 11 or 13,T.White,Enum.Font.GothamBold)
        local BTN_BLOCK=5*FP_BTN+4*FP_GAP
        local NAME_X=5+FP_AVT+5; local BTNS_X=FP_W-8-BTN_BLOCK
        nl4.Size=UDim2.new(0,BTNS_X-NAME_X-4,1,0); nl4.Position=UDim2.new(0,NAME_X,0,0)
        nl4.TextTruncate=Enum.TextTruncate.AtEnd; nl4.TextXAlignment=Enum.TextXAlignment.Left; nl4.ZIndex=33
        row.MouseEnter:Connect(function() Tween(row,F,{BackgroundColor3=T.CardHover}) end)
        row.MouseLeave:Connect(function() Tween(row,F,{BackgroundColor3=T.Card}) end)
        -- cmd buttons
        for i,cmd in ipairs(FP_CMDS) do
            local xPos=BTNS_X+(i-1)*(FP_BTN+FP_GAP)
            local btn3=Instance.new("TextButton"); btn3.Name="FPCmd_"..cmd.name
            btn3.Size=UDim2.new(0,FP_BTN,0,FP_BTN); btn3.Position=UDim2.new(0,xPos,0.5,-FP_BTN/2)
            btn3.BackgroundColor3=T.Card; btn3.BackgroundTransparency=0.3
            btn3.Text=cmd.emoji; btn3.TextSize=isMobile and 15 or 18
            btn3.Font=Enum.Font.SourceSans; btn3.AutoButtonColor=false; btn3.ZIndex=33; btn3.Parent=row
            Corner(btn3,4); Stroke(btn3,T.Border,1)
            table.insert(fpCoolBtns[cmd.name],{btn3,cmd.emoji})
            btn3.MouseEnter:Connect(function() if not fpIsCD(cmd.name) then Tween(btn3,F,{BackgroundColor3=T.CardHover,BackgroundTransparency=0}) end end)
            btn3.MouseLeave:Connect(function() if not fpIsCD(cmd.name) then Tween(btn3,F,{BackgroundColor3=T.Card,BackgroundTransparency=0.3}) end end)
            local function fireCmd()
                if fpIsCD(cmd.name) then return end
                task.spawn(function() fpRun(cmd.name,plr) end)
                Tween(btn3,TweenInfo.new(0.08,Enum.EasingStyle.Quad),{BackgroundColor3=T.AccentBright,BackgroundTransparency=0})
                task.delay(0.2, function() Tween(btn3,F,{BackgroundColor3=T.Card,BackgroundTransparency=0.3}) end)
            end
            btn3.MouseButton1Click:Connect(fireCmd)
            btn3.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch then fireCmd() end end)
        end
        return row
    end

    fpRefreshPlayers = function()
        if not FP.scroll then return end
        for _,cmd in ipairs(FP_CMDS) do fpCoolBtns[cmd.name]={} end
        for _,ch in ipairs(FP.scroll:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
        local order=1
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=Players.LocalPlayer then fpMakeRow(plr,order); order=order+1 end
        end
        local rc=order-1; FP.noTargetLbl.Visible=(rc==0); fpResize(rc,true); fpCDLoop()
    end

    local _fpa, _fpr
    local function fpShow(v)
        if not FP.win then fpBuild() end
        FP.visible=v; FP.win.Visible=v
        if v then
            FP.minimized=false; FP.scroll.Visible=true; fpRefreshPlayers()
            if not _fpa then _fpa=Players.PlayerAdded:Connect(function() if not FP.visible then return end; task.wait(0.3); fpRefreshPlayers() end) end
            if not _fpr then _fpr=Players.PlayerRemoving:Connect(function(p) fpProfCache[p.Name]=nil; if not FP.visible then return end; task.wait(0.3); fpRefreshPlayers() end) end
        else if FP.win then FP.win.Size=UDim2.new(0,FP_W,0,fpH(0)) end end
    end
    CreateToggle(SettingsTab.scroll, "Quick Panel", "Fast admin command panel for all players", function(v) fpShow(v) end)
end

CreateSection(SettingsTab.scroll, "SERVER")
CreateButton(SettingsTab.scroll, "Rejoin Server", nil, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
end)
CreateButton(SettingsTab.scroll, "Save Config", "Save all toggle states to file", function()
    pcall(FH_Save); pcall(ShowToggleNotification,"Config Saved",true)
end)

-- ══════════════════════════════════════════════════════════════
--  BANNER (FPS / PING / Discord / Toggle)
-- ══════════════════════════════════════════════════════════════
local BANNER_W = WIN_W
local BANNER_H = isMobile and 30 or 44
local BW_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(30,  60, 160)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120,180, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(30,  60, 160)),
})

local Banner = Instance.new("Frame")
Banner.Name="VertxedBanner"; Banner.Size=UDim2.new(0,BANNER_W,0,BANNER_H)
Banner.AnchorPoint=Vector2.new(0.5,0); Banner.Position=UDim2.new(0.5,0,0.5,WIN_H/2+8)
Banner.BackgroundColor3=T.Header; Banner.BackgroundTransparency=0.08; Banner.BorderSizePixel=0
Banner.ZIndex=9; Banner.ClipsDescendants=true; Banner.Parent=GUI; Corner(Banner,12)
local BanStroke=Instance.new("UIStroke"); BanStroke.Thickness=1.4; BanStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
BanStroke.Color=T.AccentBright; BanStroke.Parent=Banner
local BanGrad=Instance.new("UIGradient"); BanGrad.Color=BW_SEQ; BanGrad.Rotation=90; BanGrad.Parent=BanStroke

-- logo / toggle button
local LogoBox=Instance.new("Frame")
LogoBox.Size=UDim2.new(0,isMobile and 20 or 28,0,isMobile and 20 or 28)
LogoBox.Position=UDim2.new(0,isMobile and 5 or 8,0.5,-(isMobile and 10 or 14))
LogoBox.BackgroundColor3=T.Accent; LogoBox.BorderSizePixel=0; LogoBox.ZIndex=10; LogoBox.Active=true; LogoBox.Parent=Banner
Corner(LogoBox,6)
local LogoL=Label(LogoBox,"V",isMobile and 12 or 16,T.White,Enum.Font.GothamBlack)
LogoL.Size=UDim2.new(1,0,1,0); LogoL.TextXAlignment=Enum.TextXAlignment.Center; LogoL.TextYAlignment=Enum.TextYAlignment.Center; LogoL.ZIndex=11
if isMobile then
    local _lts
    LogoBox.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch then _lts=inp.Position end end)
    LogoBox.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch and _lts then
            local m=(inp.Position-_lts).Magnitude; _lts=nil
            if m<12 then
                Tween(LogoBox,TweenInfo.new(0.08),{BackgroundColor3=T.AccentBright})
                task.delay(0.12, function() Tween(LogoBox,TweenInfo.new(0.12),{BackgroundColor3=T.Accent}) end)
            end
        end
    end)
end

-- dividers
local oD1=isMobile and 30 or 44
local oD2=isMobile and 94 or 160
local oD3=isMobile and 154 or 266
local function BDiv(x)
    local d=Instance.new("Frame"); d.Size=UDim2.new(0,1,0,BANNER_H-14)
    d.Position=UDim2.new(0,x,0.5,-(BANNER_H-14)/2); d.BackgroundColor3=T.Border
    d.BorderSizePixel=0; d.ZIndex=10; d.Parent=Banner
end
BDiv(oD1); BDiv(oD2); BDiv(oD3)

local HubL=Label(Banner,"Vertex Pvp",isMobile and 9 or 12,T.White,Enum.Font.GothamBold)
HubL.Size=UDim2.new(0,isMobile and 60 or 110,1,0)
HubL.Position=UDim2.new(0,oD1+4,0,0)
HubL.TextXAlignment=Enum.TextXAlignment.Left; HubL.TextYAlignment=Enum.TextYAlignment.Center; HubL.ZIndex=10

local FPSLabel=Label(Banner,"FPS: --",isMobile and 9 or 11,T.White,Enum.Font.GothamBold)
FPSLabel.Size=UDim2.new(0,isMobile and 56 or 100,0.5,0); FPSLabel.Position=UDim2.new(0,oD2+4,0,3)
FPSLabel.TextXAlignment=Enum.TextXAlignment.Left; FPSLabel.ZIndex=10
local PINGLabel=Label(Banner,"PING: --",isMobile and 8 or 10,Color3.fromRGB(120,160,255),Enum.Font.GothamBold)
PINGLabel.Size=UDim2.new(0,isMobile and 56 or 100,0.5,0); PINGLabel.Position=UDim2.new(0,oD2+4,0.5,-2)
PINGLabel.TextXAlignment=Enum.TextXAlignment.Left; PINGLabel.ZIndex=10

local StatBadge=Instance.new("Frame")
StatBadge.Size=UDim2.new(0,isMobile and 48 or 64,0,isMobile and 18 or 22)
StatBadge.Position=UDim2.new(0,oD3+4,0.5,-(isMobile and 9 or 11))
StatBadge.BackgroundColor3=Color3.fromRGB(10,20,40); StatBadge.BorderSizePixel=0; StatBadge.ZIndex=10; StatBadge.Parent=Banner
Corner(StatBadge,6); Stroke(StatBadge,T.Accent,1)
local StatL=Label(StatBadge,"● LIVE",isMobile and 8 or 10,T.AccentBright,Enum.Font.GothamBold)
StatL.Size=UDim2.new(1,0,1,0); StatL.TextXAlignment=Enum.TextXAlignment.Center; StatL.TextYAlignment=Enum.TextYAlignment.Center; StatL.ZIndex=11

-- mobile quick bar
if isMobile then
    local MB_H=34; local MB_GAP=5; local MB_PAD=8
    local MBar=Instance.new("Frame"); MBar.Name="VertxMobileBar"
    MBar.AnchorPoint=Vector2.new(0.5,1); MBar.Position=UDim2.new(0.5,0,0.5,WIN_H/2+BANNER_H+12)
    MBar.Size=UDim2.new(0,BANNER_W,0,MB_H); MBar.BackgroundColor3=T.Header
    MBar.BackgroundTransparency=0.08; MBar.BorderSizePixel=0; MBar.ZIndex=9; MBar.Parent=GUI; Corner(MBar,10)
    local MBS=Instance.new("UIStroke"); MBS.Thickness=1.4; MBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    MBS.Color=T.AccentBright; MBS.Parent=MBar
    local MBG=Instance.new("UIGradient"); MBG.Color=BW_SEQ; MBG.Rotation=90; MBG.Parent=MBS
    local MBL=Instance.new("UIListLayout"); MBL.FillDirection=Enum.FillDirection.Horizontal
    MBL.VerticalAlignment=Enum.VerticalAlignment.Center; MBL.HorizontalAlignment=Enum.HorizontalAlignment.Center
    MBL.SortOrder=Enum.SortOrder.LayoutOrder; MBL.Padding=UDim.new(0,MB_GAP); MBL.Parent=MBar
    local mbP=Instance.new("UIPadding"); mbP.PaddingLeft=UDim.new(0,MB_PAD); mbP.PaddingRight=UDim.new(0,MB_PAD); mbP.Parent=MBar
    local function makeMB(text, order, accentCol, onFire)
        local btn4=Instance.new("TextButton"); btn4.Name="MB_"..text
        btn4.LayoutOrder=order; btn4.Size=UDim2.new(0,0,0,24); btn4.AutomaticSize=Enum.AutomaticSize.X
        btn4.BackgroundColor3=Color3.fromRGB(14,14,22); btn4.BorderSizePixel=0; btn4.AutoButtonColor=false
        btn4.Text=text; btn4.TextSize=10; btn4.Font=Enum.Font.GothamBold; btn4.TextColor3=T.White
        btn4.ZIndex=10; btn4.Active=true; btn4.Parent=MBar; Corner(btn4,7)
        local pad2=Instance.new("UIPadding"); pad2.PaddingLeft=UDim.new(0,10); pad2.PaddingRight=UDim.new(0,10); pad2.Parent=btn4
        local st2=Stroke(btn4,accentCol or T.Border,1)
        local _busy2=false; local _ts2=nil
        local function _fire()
            if _busy2 then return end; _busy2=true
            btn4.BackgroundColor3=T.AccentBright; btn4.TextColor3=Color3.fromRGB(10,10,20)
            Tween(st2,F,{Color=T.AccentBright})
            task.delay(0.16, function()
                Tween(btn4,M,{BackgroundColor3=Color3.fromRGB(14,14,22)}); Tween(st2,M,{Color=accentCol or T.Border})
                btn4.TextColor3=T.White; _busy2=false
            end)
            if onFire then task.spawn(function() pcall(onFire) end) end
        end
        btn4.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then _ts2=inp.Position
            elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then _fire() end
        end)
        btn4.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch and _ts2 then
                local m=(inp.Position-_ts2).Magnitude; _ts2=nil; if m<20 then _fire() end
            end
        end)
        return btn4
    end
    makeMB("RESET",1,T.Border,function() if _G._FH_ResetBtnEntry then pcall(_G._FH_ResetBtnEntry.fire) end end)
    makeMB("FLASH",2,T.Accent,function() if _G._FH_FlashBtnEntry then pcall(_G._FH_FlashBtnEntry.fire) end end)
    makeMB("BLOCK",3,Color3.fromRGB(180,50,50),function() if _G._FH_BlockBtnEntry then pcall(_G._FH_BlockBtnEntry.fire) end end)
end

-- ── UI show/hide (Ctrl) ───────────────────────────────────────
local _uiVisible = true
local _uiAnim = false
local SHOW_TI = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HIDE_TI = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local function setUIVisible(v)
    if _uiAnim or v==_uiVisible then return end
    _uiVisible=v; _uiAnim=true
    if v then
        winScale.Scale=0; Win.Visible=true
        local tw=TweenService:Create(winScale,SHOW_TI,{Scale=1}); tw:Play()
        tw.Completed:Connect(function() _uiAnim=false end)
    else
        local tw=TweenService:Create(winScale,HIDE_TI,{Scale=0}); tw:Play()
        tw.Completed:Connect(function() Win.Visible=false; _uiAnim=false end)
    end
end
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.LeftControl or inp.KeyCode==Enum.KeyCode.RightControl then
        setUIVisible(not _uiVisible)
    end
end)

-- ── Animate border + FPS counter ─────────────────────────────
local _fpsF, _fpsC = 0, 0
RunService.RenderStepped:Connect(function(dt)
    BorderGrad.Rotation=(BorderGrad.Rotation+dt*60)%360
    BanGrad.Rotation=(BanGrad.Rotation+dt*60)%360
    _fpsF=_fpsF+1; _fpsC=_fpsC+dt
    if _fpsC>=0.5 then
        FPSLabel.Text="FPS: "..math.floor(_fpsF/_fpsC); _fpsF=0; _fpsC=0
        local ping=0; pcall(function() ping=math.floor((Players.LocalPlayer:GetNetworkPing() or 0)*1000) end)
        PINGLabel.Text="PING: "..ping.."ms"
    end
end)

ActivateTab(BrainrotsTab)

-- Apply saved keybinds
for name, kcName in pairs(Config.keybinds) do
    if configRegistry[name] and configRegistry[name].setKeyCode then
        local ok2,kc=pcall(function() return Enum.KeyCode[kcName] end)
        if ok2 and kc then configRegistry[name].setKeyCode(kc) end
    end
end

pcall(ShowToggleNotification, "Vertxed Hub loaded | r9qbx", true)
