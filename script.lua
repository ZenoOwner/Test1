-- Aethen Hub v0.2 | r9qbx
-- =====================================================
-- EDIT THESE:
local DISCORD_LINK = "discord.gg/3vQbThdQ"
local ADMIN_GP_ID = 0   -- Admin Commands gamepass ID (0 = auto-detect)
-- =====================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PPS        = game:GetService("ProximityPromptService")
local RS         = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui    = game:GetService("CoreGui")
local Debris     = game:GetService("Debris")
local Lighting   = game:GetService("Lighting")
local MPS        = game:GetService("MarketplaceService")
local lp         = Players.LocalPlayer
local cam        = workspace.CurrentCamera

-- Config save/load
local CFG = "AethonSuite.json"
local Cfg = {
    triggerChance = 80, flashOn = false, potionOn = false, lagOn = false,
    stealSpdOn = false, stealSpdVal = 30,
    pos_FP = {ox=0,oy=5}, pos_AP = {ox=0,oy=0},
    pos_ADM = {ox=0,oy=0}, pos_BP = {ox=0,oy=0}
}
pcall(function()
    if not readfile then return end
    local raw = readfile(CFG)
    if not raw or raw == "" then return end
    local ok, t = pcall(HttpService.JSONDecode, HttpService, raw)
    if ok and type(t) == "table" then for k,v in pairs(t) do Cfg[k]=v end end
end)
local function save()
    pcall(function()
        if writefile then writefile(CFG, HttpService:JSONEncode(Cfg)) end
    end)
end

-- Clean up old GUI instances
for _, v in ipairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:sub(1,5)=="Aeth_" or v.Name:sub(1,2)=="AS") then
        v:Destroy()
    end
end
local SG = Instance.new("ScreenGui")
SG.Name = "Aeth_" .. tostring(math.random(10000, 99999))
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
SG.IgnoreGuiInset = true
SG.Parent = CoreGui

-- Black / white color palette
local C = {
    bg    = Color3.new(0, 0, 0),
    panel = Color3.new(0, 0, 0),
    surf  = Color3.fromRGB(14, 14, 14),
    surf2 = Color3.fromRGB(24, 24, 24),
    bord  = Color3.new(1, 1, 1),
    text  = Color3.new(1, 1, 1),
    dim   = Color3.fromRGB(150, 150, 150),
    white = Color3.new(1, 1, 1),
    red   = Color3.fromRGB(255, 50, 70),
    grn   = Color3.fromRGB(50, 215, 95),
    blu   = Color3.fromRGB(60, 130, 255),
    yel   = Color3.fromRGB(255, 210, 30),
}

-- GUI helpers
local function co(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 7)
end

local function lb(par, t)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = C.white
    l.BorderSizePixel = 0
    for k, v in pairs(t) do l[k] = v end
    l.Parent = par
    return l
end

local function mkBtn(par, text, sz, pos, bg, tc, r)
    local b = Instance.new("TextButton")
    b.Size = sz
    b.Position = pos
    b.BackgroundColor3 = bg or C.surf
    b.BackgroundTransparency = 0.1
    b.Text = text
    b.TextColor3 = tc or C.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = par
    co(b, r or 5)
    local s = Instance.new("UIStroke", b)
    s.Thickness = 1
    s.Color = C.white
    s.Transparency = 0.55
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return b
end

-- Animated sloshing white border
local function addAnimBorder(frame)
    local s = Instance.new("UIStroke", frame)
    s.Thickness = 1.4
    s.Color = C.white
    s.Transparency = 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local g = Instance.new("UIGradient", s)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(0.5,  Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1,    Color3.new(1, 1, 1))
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    0),
        NumberSequenceKeypoint.new(0.25, 0.65),
        NumberSequenceKeypoint.new(0.5,  0),
        NumberSequenceKeypoint.new(0.75, 0.65),
        NumberSequenceKeypoint.new(1,    0)
    })
    task.spawn(function()
        while s and s.Parent do
            g.Rotation = (g.Rotation + 1.8) % 360
            task.wait(0.02)
        end
    end)
    return s
end

-- Floating white particles
local function addParticles(parent, count)
    count = count or 3
    for i = 1, count do
        local p = Instance.new("Frame", parent)
        p.BackgroundColor3 = C.white
        p.BackgroundTransparency = 0.55
        p.BorderSizePixel = 0
        p.ZIndex = 0
        local sz = math.random(2, 4)
        p.Size = UDim2.fromOffset(sz, sz)
        local sx = math.random()
        p.Position = UDim2.new(sx, 0, 1.05, 0)
        co(p, 5)
        task.spawn(function()
            while p and p.Parent do
                local nx = math.clamp(sx + math.random(-10, 10) / 100, 0.02, 0.98)
                TweenService:Create(p, TweenInfo.new(math.random(4, 7), Enum.EasingStyle.Linear), {
                    Position = UDim2.new(nx, 0, -0.05, 0),
                    BackgroundTransparency = 1
                }):Play()
                task.wait(math.random(4, 7))
                if p and p.Parent then
                    p.BackgroundTransparency = 0.55
                    sx = math.random()
                    p.Position = UDim2.new(sx, 0, 1.05, 0)
                end
            end
        end)
    end
end

local function dragSave(h, f, key)
    local on, ds, sp = false, nil, nil
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            on = true
            ds = i.Position
            sp = f.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    on = false
                    if key then
                        Cfg[key] = {ox = math.floor(f.Position.X.Offset), oy = math.floor(f.Position.Y.Offset)}
                        save()
                    end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not on then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ds
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

-- Panel builder
local function mkP(defX, defY, w, h, title, posKey)
    local px = (posKey and Cfg[posKey] and Cfg[posKey].ox ~= 0 and Cfg[posKey].ox) or defX
    local py = (posKey and Cfg[posKey] and Cfg[posKey].oy ~= 0 and Cfg[posKey].oy) or defY
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(w, h)
    f.Position = UDim2.fromOffset(px, py)
    f.BackgroundColor3 = C.bg
    f.BackgroundTransparency = 0.12
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = SG
    co(f, 8)
    addAnimBorder(f)
    addParticles(f, 3)
    local hdr = Instance.new("Frame", f)
    hdr.Size = UDim2.new(1, 0, 0, 22)
    hdr.BackgroundColor3 = C.surf
    hdr.BackgroundTransparency = 0.05
    hdr.BorderSizePixel = 0
    co(hdr, 8)
    local hflat = Instance.new("Frame", hdr)
    hflat.Size = UDim2.new(1, 0, 0, 8)
    hflat.Position = UDim2.new(0, 0, 1, -8)
    hflat.BackgroundColor3 = C.surf
    hflat.BackgroundTransparency = 0.05
    hflat.BorderSizePixel = 0
    local sep = Instance.new("Frame", f)
    sep.Size = UDim2.new(1, -8, 0, 1)
    sep.Position = UDim2.fromOffset(4, 22)
    sep.BackgroundColor3 = C.white
    sep.BackgroundTransparency = 0.65
    sep.BorderSizePixel = 0
    if title then
        lb(hdr, {
            Position = UDim2.new(0, 7, 0, 0),
            Size = UDim2.new(1, -22, 1, 0),
            Text = title,
            TextSize = 8,
            Font = Enum.Font.GothamBlack,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = C.white
        })
    end
    local mb = mkBtn(hdr, "-", UDim2.fromOffset(13, 11), UDim2.new(1, -16, 0.5, -5.5), C.surf2, C.dim, 4)
    mb.TextSize = 9
    mb.BackgroundTransparency = 0.5
    dragSave(hdr, f, posKey)
    return f, hdr, mb
end

local function mkPill(parent, label, yPos, onCol)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 19)
    row.Position = UDim2.new(0, 4, 0, yPos)
    row.BackgroundColor3 = C.surf
    row.BackgroundTransparency = 0.1
    row.BorderSizePixel = 0
    row.Parent = parent
    co(row, 5)
    local rs = Instance.new("UIStroke", row)
    rs.Thickness = 1
    rs.Color = C.white
    rs.Transparency = 0.6
    rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local rl = lb(row, {
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Text = label,
        TextSize = 7,
        Font = Enum.Font.GothamBold,
        TextColor3 = C.dim,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local track = Instance.new("Frame", row)
    track.Size = UDim2.fromOffset(22, 11)
    track.Position = UDim2.new(1, -25, 0.5, -5.5)
    track.BackgroundColor3 = C.surf2
    track.BorderSizePixel = 0
    co(track, 12)
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.fromOffset(8, 8)
    knob.Position = UDim2.new(0, 1.5, 0.5, -4)
    knob.BackgroundColor3 = C.dim
    knob.BorderSizePixel = 0
    co(knob, 8)
    local pb = Instance.new("TextButton", row)
    pb.Size = UDim2.new(1, 0, 1, 0)
    pb.BackgroundTransparency = 1
    pb.Text = ""
    local col = onCol or C.white
    local function set(v)
        TweenService:Create(track, TweenInfo.new(0.12), {BackgroundColor3 = v and col or C.surf2}):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = v and UDim2.new(1, -9.5, 0.5, -4) or UDim2.new(0, 1.5, 0.5, -4),
            BackgroundColor3 = v and C.bg or C.dim
        }):Play()
        TweenService:Create(rs, TweenInfo.new(0.12), {Transparency = v and 0.2 or 0.6}):Play()
        rl.TextColor3 = v and C.white or C.dim
    end
    return pb, set
end

local function numRow(parent, label, val, mn, mx, yPos, w, onChange)
    local IW = w - 8
    local row = Instance.new("Frame")
    row.Size = UDim2.fromOffset(IW, 19)
    row.Position = UDim2.fromOffset(4, yPos)
    row.BackgroundColor3 = C.surf
    row.BackgroundTransparency = 0.1
    row.BorderSizePixel = 0
    row.Parent = parent
    co(row, 5)
    local s2 = Instance.new("UIStroke", row)
    s2.Thickness = 1
    s2.Color = C.white
    s2.Transparency = 0.6
    s2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    lb(row, {
        Position = UDim2.new(0, 5, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = label,
        TextSize = 7,
        TextColor3 = C.dim,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local mB = Instance.new("TextButton", row)
    mB.Size = UDim2.fromOffset(13, 13)
    mB.Position = UDim2.new(0.5, 2, 0.5, -6.5)
    mB.BackgroundColor3 = C.surf2
    mB.Text = "-"
    mB.Font = Enum.Font.GothamBold
    mB.TextSize = 9
    mB.TextColor3 = C.white
    mB.BorderSizePixel = 0
    mB.AutoButtonColor = false
    co(mB, 3)
    local vB = Instance.new("TextBox", row)
    vB.Size = UDim2.fromOffset(24, 13)
    vB.Position = UDim2.new(0.5, 17, 0.5, -6.5)
    vB.BackgroundColor3 = C.surf2
    vB.BorderSizePixel = 0
    vB.Text = tostring(val)
    vB.Font = Enum.Font.GothamBold
    vB.TextSize = 8
    vB.TextColor3 = C.white
    vB.ClearTextOnFocus = false
    co(vB, 3)
    local pB = Instance.new("TextButton", row)
    pB.Size = UDim2.fromOffset(13, 13)
    pB.Position = UDim2.new(0.5, 43, 0.5, -6.5)
    pB.BackgroundColor3 = C.surf2
    pB.Text = "+"
    pB.Font = Enum.Font.GothamBold
    pB.TextSize = 9
    pB.TextColor3 = C.white
    pB.BorderSizePixel = 0
    pB.AutoButtonColor = false
    co(pB, 3)
    local cur = val
    local function setV(v)
        cur = math.clamp(math.floor(v), mn, mx)
        vB.Text = tostring(cur)
        if onChange then onChange(cur) end
    end
    mB.MouseButton1Click:Connect(function() setV(cur - 1) end)
    pB.MouseButton1Click:Connect(function() setV(cur + 1) end)
    vB.FocusLost:Connect(function()
        local n = tonumber(vB.Text)
        if n then setV(n) else vB.Text = tostring(cur) end
    end)
end

task.wait(0.1)
local vp = cam.ViewportSize
if vp.X == 0 then vp = Vector2.new(390, 844) end

-- =====================================================
-- BACKGROUND SYSTEMS (guarded: only run once)
-- =====================================================
if not _G._AethBGv2 then
    _G._AethBGv2 = true

    -- Anti-lag
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
                pcall(function() v.Enabled = false end)
            end
        end
    end)
    workspace.DescendantAdded:Connect(function(v)
        pcall(function()
            if v:IsA("ParticleEmitter") or v:IsA("PointLight") then v.Enabled = false end
        end)
    end)

    -- Kick on steal (watches "you stole" text appearing)
    task.spawn(function()
        local pg = lp:WaitForChild("PlayerGui")
        local function onStole()
            pcall(function() lp:Kick(DISCORD_LINK) end)
        end
        local function chk(t) return typeof(t) == "string" and t:lower():find("you stole") end
        local function watch(gui)
            gui.DescendantAdded:Connect(function(d)
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    if chk(d.Text) then onStole() end
                    d:GetPropertyChangedSignal("Text"):Connect(function()
                        if chk(d.Text) then onStole() end
                    end)
                end
            end)
        end
        for _, g in ipairs(pg:GetChildren()) do watch(g) end
        pg.ChildAdded:Connect(function(g) watch(g) end)
    end)

    -- Anti-ragdoll
    RunService.Heartbeat:Connect(function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        local rag = (s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown)
        local et = lp:GetAttribute("RagdollEndTime")
        if et and (et - workspace:GetServerTimeNow()) > 0 then rag = true end
        if rag then
            pcall(function() lp:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
                    d:Destroy()
                end
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled = true end
            end
            if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            cam.CameraSubject = hum
            root.Anchored = false
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    -- Anti-bee (BindToRenderStep = highest priority = true prerender fix)
    RunService:BindToRenderStep("AethAntiBee", Enum.RenderPriority.Input.Value + 1, function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if not hum.AutoRotate then hum.AutoRotate = true end
        for _, obj in ipairs(root:GetChildren()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyAngularVelocity") then
                pcall(function() obj:Destroy() end)
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            local nl = obj.Name:lower()
            if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") then
                pcall(function() obj:Destroy() end)
            end
        end
        for _, val in ipairs(char:GetChildren()) do
            if val:IsA("BoolValue") or val:IsA("IntValue") or val:IsA("NumberValue") then
                local nl = val.Name:lower()
                if nl:find("bee") or nl:find("invert") or nl:find("reverse") then
                    pcall(function()
                        if val:IsA("BoolValue") then val.Value = false else val.Value = 0 end
                    end)
                end
            end
        end
        if hum.MoveDirection.Magnitude > 0.1 then
            local md = hum.MoveDirection
            local vel = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
            if vel.Magnitude > 1.5 and md:Dot(vel.Unit) < -0.45 then
                root.Velocity = Vector3.new(md.X * 28, root.Velocity.Y, md.Z * 28)
            end
        end
    end)

    -- Anti-sentry (correctly skips own sentry and beehive)
    local sentryFirstSeen = {}
    local sentryTarget = nil
    local function isMySentry(obj)
        local id = obj.Name:match("Sentry_(%d+)") or obj.Name:match("Beehive_(%d+)")
        if id and tonumber(id) == lp.UserId then return true end
        local a = obj:GetAttribute("OwnerId") or obj:GetAttribute("PlayerId") or obj:GetAttribute("Owner")
        return a and tonumber(tostring(a)) == lp.UserId
    end
    local function findSentryTarget()
        local char = lp.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local rp = hrp.Position
        local now = tick()
        for obj in pairs(sentryFirstSeen) do
            if not obj.Parent then sentryFirstSeen[obj] = nil end
        end
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:find("Sentry") or obj.Name:find("Beehive")) and not obj.Name:lower():find("bullet") then
                if isMySentry(obj) then continue end
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and (rp - part.Position).Magnitude <= 220 then
                    if not sentryFirstSeen[obj] then sentryFirstSeen[obj] = now end
                    if now - sentryFirstSeen[obj] >= 2.5 then return obj end
                end
            end
        end
        return nil
    end
    local function attackSentry()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local weapon = (lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat")
        if not weapon then return end
        if weapon.Parent == lp.Backpack then hum:EquipTool(weapon); task.wait(0.08) end
        local handle = weapon:FindFirstChild("Handle")
        if handle then handle.CanCollide = false end
        pcall(function() weapon:Activate() end)
        for _, r in pairs(weapon:GetDescendants()) do
            if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end
        end
    end
    local function moveSentry(obj)
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, p2 in pairs(obj:GetDescendants()) do
            if p2:IsA("BasePart") then p2.CanCollide = false end
        end
        local cf = hrp.CFrame * CFrame.new(0, 0, -6)
        if obj:IsA("BasePart") then
            obj.CFrame = cf
        elseif obj:IsA("Model") then
            local m = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if m then m.CFrame = cf end
        end
    end
    RunService.Heartbeat:Connect(function()
        if sentryTarget and sentryTarget.Parent == workspace then
            moveSentry(sentryTarget)
            attackSentry()
        else
            sentryTarget = findSentryTarget()
        end
    end)
    task.spawn(function()
        task.wait(1)
        for _, obj in pairs(workspace:GetChildren()) do
            if (obj.Name:find("Sentry") or obj.Name:find("Beehive")) and not isMySentry(obj) then
                sentryFirstSeen[obj] = tick() - 2.5
            end
        end
    end)
end

-- Anti-bee FOV (always needed per execution)
local FOV_LOCK = 70
RunService.RenderStepped:Connect(function()
    if cam.FieldOfView ~= FOV_LOCK then cam.FieldOfView = FOV_LOCK end
end)
local beeBL = {BlurEffect=1, ColorCorrectionEffect=1, BloomEffect=1, SunRaysEffect=1, DepthOfFieldEffect=1}
for _, v in pairs(Lighting:GetDescendants()) do
    if beeBL[v.ClassName] then pcall(function() v:Destroy() end) end
end
Lighting.DescendantAdded:Connect(function(obj)
    task.wait()
    if beeBL[obj.ClassName] then pcall(function() obj:Destroy() end) end
end)

-- Plot detection (YourBase billboard = most reliable)
local myPlotRef = nil
local stealHitbox = nil
task.spawn(function()
    while true do
        task.wait(0.8)
        if not myPlotRef then
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, p in ipairs(plots:GetChildren()) do
                    local sign = p:FindFirstChild("PlotSign")
                    if sign then
                        local yourBase = sign:FindFirstChild("YourBase")
                        if yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled then
                            myPlotRef = p
                            stealHitbox = p:FindFirstChild("StealHitbox", true)
                            break
                        end
                        local tl = sign:FindFirstChild("TextLabel", true)
                        if tl then
                            local t = tl.Text:lower()
                            if t:find(lp.Name:lower(), 1, true) or t:find(lp.DisplayName:lower(), 1, true) then
                                myPlotRef = p
                                stealHitbox = p:FindFirstChild("StealHitbox", true)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Timer ESP
local timerESPs = {}
local baseAlerted = false
local function showAlert()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://9118633772"
        s.Volume = 0.85
        s.Parent = workspace
        s:Play()
        Debris:AddItem(s, 5)
    end)
    local ag = Instance.new("ScreenGui", CoreGui)
    ag.Name = "AethAlert" .. math.random()
    ag.ResetOnSpawn = false
    ag.IgnoreGuiInset = true
    local af = Instance.new("Frame", ag)
    af.Size = UDim2.fromOffset(180, 26)
    af.Position = UDim2.new(0.5, -90, 0, -38)
    af.BackgroundColor3 = C.bg
    af.BackgroundTransparency = 0.1
    af.BorderSizePixel = 0
    co(af, 7)
    addAnimBorder(af)
    lb(af, {Size = UDim2.new(1,0,1,0), Text = "BASE EXPIRES IN 5s!", TextSize = 9, Font = Enum.Font.GothamBlack, TextColor3 = C.red})
    TweenService:Create(af, TweenInfo.new(0.32, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -90, 0, 7)}):Play()
    task.delay(4, function()
        TweenService:Create(af, TweenInfo.new(0.22), {Position = UDim2.new(0.5, -90, 0, -38)}):Play()
        task.wait(0.25)
        ag:Destroy()
    end)
end
task.spawn(function()
    while true do
        task.wait(0.4)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then continue end
        for _, plot in ipairs(plots:GetChildren()) do
            local pur = plot:FindFirstChild("Purchases")
            local pb2 = pur and pur:FindFirstChild("PlotBlock")
            local mp = pb2 and pb2:FindFirstChild("Main")
            local tl2 = mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
            if tl2 and mp then
                local e = timerESPs[plot.Name]
                if not e or not e.bb.Parent then
                    if e then pcall(function() e.bb:Destroy() end) end
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.fromOffset(56, 16)
                    bb.StudsOffset = Vector3.new(0, 7, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = mp
                    bb.MaxDistance = 1200
                    bb.Parent = plot
                    local bgT = Instance.new("Frame", bb)
                    bgT.Size = UDim2.new(1, 0, 1, 0)
                    bgT.BackgroundColor3 = C.bg
                    bgT.BackgroundTransparency = 0.2
                    bgT.BorderSizePixel = 0
                    co(bgT, 5)
                    local stk = Instance.new("UIStroke", bgT)
                    stk.Color = C.yel
                    stk.Thickness = 1
                    stk.Transparency = 0.25
                    stk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    local tl = Instance.new("TextLabel", bgT)
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.Font = Enum.Font.GothamBold
                    tl.TextSize = 9
                    tl.TextColor3 = C.yel
                    tl.TextStrokeTransparency = 0.5
                    timerESPs[plot.Name] = {bb = bb, lbl = tl, stk = stk}
                    e = timerESPs[plot.Name]
                end
                e.lbl.Text = tl2.Text
                local m, s2 = tl2.Text:match("(%d+):(%d+)")
                if m and s2 then
                    local tot = tonumber(m) * 60 + tonumber(s2)
                    local col = tot <= 30 and C.red or tot <= 60 and C.yel or C.grn
                    e.lbl.TextColor3 = col
                    e.stk.Color = col
                    if myPlotRef and plot == myPlotRef then
                        if tot <= 5 and not baseAlerted then
                            baseAlerted = true
                            task.spawn(showAlert)
                        elseif tot > 5 then
                            baseAlerted = false
                        end
                    end
                end
            else
                local e = timerESPs[plot.Name]
                if e then pcall(function() e.bb:Destroy() end); timerESPs[plot.Name] = nil end
            end
        end
    end
end)

-- Player ESP
local ESPTAG = "AE_" .. tostring(math.random(10000, 99999))
local function mkESP(plr)
    if plr == lp then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or char:FindFirstChild(ESPTAG) then return end
    local box = Instance.new("BoxHandleAdornment", char)
    box.Name = ESPTAG
    box.Adornee = hrp
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = C.white
    box.Transparency = 0.6
    box.ZIndex = 10
    box.AlwaysOnTop = true
    local bb = Instance.new("BillboardGui", char)
    bb.Name = ESPTAG .. "N"
    bb.Adornee = char:FindFirstChild("Head") or hrp
    bb.Size = UDim2.fromOffset(120, 24)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    local bgE = Instance.new("Frame", bb)
    bgE.Size = UDim2.new(1, 0, 1, 0)
    bgE.BackgroundColor3 = C.bg
    bgE.BackgroundTransparency = 0.2
    bgE.BorderSizePixel = 0
    co(bgE, 5)
    local se = Instance.new("UIStroke", bgE)
    se.Thickness = 1
    se.Color = C.white
    se.Transparency = 0.3
    se.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    lb(bgE, {Size=UDim2.new(1,0,0.58,0), BackgroundTransparency=1, Text=plr.DisplayName, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.white, TextStrokeTransparency=0.5})
    lb(bgE, {Size=UDim2.new(1,0,0.42,0), Position=UDim2.new(0,0,0.58,0), BackgroundTransparency=1, Text="@"..plr.Name, Font=Enum.Font.Gotham, TextSize=7, TextColor3=C.dim})
end
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then task.defer(function() mkESP(p) end) end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end)
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then
        p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end)
    end
end

-- Mine ESP
local mineESPs = {}
local function addMineESP(child)
    if mineESPs[child] then return end
    local nl = child.Name:lower()
    if not (nl:find("subspace") or nl:find("mine")) then return end
    if nl:find("bullet") or nl:find("explosion") or nl:find("effect") then return end
    local part = child:IsA("BasePart") and child or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")))
    if not part then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(90, 25)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = part
    bb.Parent = workspace
    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = C.bg
    bg.BackgroundTransparency = 0.12
    bg.BorderSizePixel = 0
    co(bg, 6)
    local ms2 = Instance.new("UIStroke", bg)
    ms2.Thickness = 1.5
    ms2.Color = C.red
    ms2.Transparency = 0.1
    ms2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    lb(bg, {Size=UDim2.new(1,0,0,14), Position=UDim2.fromOffset(0,1), BackgroundTransparency=1, Text="SUBSPACE MINE", Font=Enum.Font.GothamBlack, TextSize=9, TextColor3=C.red})
    local distL = lb(bg, {Size=UDim2.new(1,0,0,10), Position=UDim2.fromOffset(0,14), BackgroundTransparency=1, Text="--", Font=Enum.Font.Gotham, TextSize=7, TextColor3=C.dim})
    local dc = RunService.Heartbeat:Connect(function()
        if not bb.Parent or not part.Parent then return end
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local d = math.round((root.Position - part.Position).Magnitude)
            distL.Text = d .. " studs"
            distL.TextColor3 = d < 15 and C.red or d < 30 and C.yel or C.dim
        end
    end)
    mineESPs[child] = {bb=bb, dc=dc}
    child.AncestryChanged:Connect(function()
        if not child.Parent then
            pcall(function() bb:Destroy() end)
            pcall(function() dc:Disconnect() end)
            mineESPs[child] = nil
        end
    end)
end
for _, d in pairs(workspace:GetDescendants()) do addMineESP(d) end
workspace.DescendantAdded:Connect(function(d) task.defer(function() addMineESP(d) end) end)

-- Brainrot ESP (AnimalPodiums only)
local brainrotESPCache = {}
local brainrotESPEnabled = false
local brainrotConns = {}
local function addBrainrotESP(model, plot)
    if not model or brainrotESPCache[model] then return end
    if model.Name == "PromptAttachment" or model.Name == "" then return end
    local part = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")) or (model:IsA("BasePart") and model)
    if not part then return end
    local owner = ""
    if plot then
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local tl = sign:FindFirstChild("TextLabel", true)
            if tl then owner = tl.Text end
        end
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "AethBrainrotESP"
    bb.Size = UDim2.fromOffset(105, 25)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = part
    bb.Parent = workspace
    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = C.bg
    bg.BackgroundTransparency = 0.15
    bg.BorderSizePixel = 0
    co(bg, 5)
    local bs = Instance.new("UIStroke", bg)
    bs.Thickness = 1
    bs.Color = C.white
    bs.Transparency = 0.3
    bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    lb(bg, {Size=UDim2.new(1,0,0,13), Position=UDim2.fromOffset(0,2), BackgroundTransparency=1, Text=model.Name, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.white, TextTruncate=Enum.TextTruncate.AtEnd})
    if owner ~= "" then
        lb(bg, {Size=UDim2.new(1,-4,0,10), Position=UDim2.fromOffset(2,14), BackgroundTransparency=1, Text=owner, Font=Enum.Font.Gotham, TextSize=7, TextColor3=C.dim, TextTruncate=Enum.TextTruncate.AtEnd})
    end
    brainrotESPCache[model] = bb
    model.AncestryChanged:Connect(function()
        if not model.Parent then
            pcall(function() bb:Destroy() end)
            brainrotESPCache[model] = nil
        end
    end)
end
local function scanSpawn(spawn, plot)
    for _, child in ipairs(spawn:GetChildren()) do addBrainrotESP(child, plot) end
    local c = spawn.ChildAdded:Connect(function(child)
        if brainrotESPEnabled then task.defer(function() addBrainrotESP(child, plot) end) end
    end)
    table.insert(brainrotConns, c)
end
local function startBrainrotESP()
    if brainrotESPEnabled then return end
    brainrotESPEnabled = true
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            local base = pod:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then scanSpawn(spawn, plot) end
        end
        local c = pods.ChildAdded:Connect(function(pod)
            if brainrotESPEnabled then
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then scanSpawn(spawn, plot) end
            end
        end)
        table.insert(brainrotConns, c)
    end
    local c2 = plots.ChildAdded:Connect(function(plot)
        if brainrotESPEnabled then
            task.wait(0.5)
            local pods = plot:FindFirstChild("AnimalPodiums")
            if not pods then return end
            for _, pod in ipairs(pods:GetChildren()) do
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then scanSpawn(spawn, plot) end
            end
        end
    end)
    table.insert(brainrotConns, c2)
end
local function stopBrainrotESP()
    if not brainrotESPEnabled then return end
    brainrotESPEnabled = false
    for _, c in ipairs(brainrotConns) do pcall(function() c:Disconnect() end) end
    brainrotConns = {}
    for _, bb in pairs(brainrotESPCache) do pcall(function() bb:Destroy() end) end
    brainrotESPCache = {}
end

-- Friends ESP (updates live on toggle change)
local friendESPCache = {}
local friendESPEnabled = false
local friendConns = {}
local function buildFriendBB(main, isOpen)
    local bb = Instance.new("BillboardGui")
    bb.Adornee = main
    bb.Size = UDim2.fromOffset(50, 20)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = main
    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = C.bg
    bg.BackgroundTransparency = 0.15
    bg.BorderSizePixel = 0
    co(bg, 5)
    local bs = Instance.new("UIStroke", bg)
    bs.Thickness = 1
    bs.Color = isOpen and C.grn or C.red
    bs.Transparency = 0.2
    bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    lb(bg, {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=isOpen and "OPEN" or "CLOSED", TextColor3=isOpen and C.grn or C.red, Font=Enum.Font.GothamBold, TextSize=8})
    return bb
end
local function addFriendESP(plot)
    if not plot:IsA("Model") then return end
    local fp = plot:FindFirstChild("FriendPanel")
    if not fp then return end
    local main = fp:FindFirstChild("Main")
    if not main then return end
    local prompt = main:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return end
    if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end); friendESPCache[plot] = nil end
    local isOpen = prompt.ObjectText == "Disallow Friends"
    friendESPCache[plot] = buildFriendBB(main, isOpen)
    local c = prompt:GetPropertyChangedSignal("ObjectText"):Connect(function()
        if not friendESPEnabled then return end
        if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end); friendESPCache[plot] = nil end
        friendESPCache[plot] = buildFriendBB(main, prompt.ObjectText == "Disallow Friends")
    end)
    table.insert(friendConns, c)
    plot.AncestryChanged:Connect(function()
        if not plot.Parent then
            if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end) end
            friendESPCache[plot] = nil
        end
    end)
end
local function startFriendESP()
    if friendESPEnabled then return end
    friendESPEnabled = true
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, p in ipairs(plots:GetChildren()) do addFriendESP(p) end
    local c = plots.ChildAdded:Connect(function(p)
        if friendESPEnabled then task.wait(0.5); addFriendESP(p) end
    end)
    table.insert(friendConns, c)
end
local function stopFriendESP()
    if not friendESPEnabled then return end
    friendESPEnabled = false
    for _, c in ipairs(friendConns) do pcall(function() c:Disconnect() end) end
    friendConns = {}
    for _, bb in pairs(friendESPCache) do pcall(function() bb:Destroy() end) end
    friendESPCache = {}
end

-- Base Xray
local xrayOn = false
local xrayOrig = {}
local function enableXray()
    if xrayOn then return end
    xrayOn = true
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("floor") or n:find("wall") or n:find("base") or n:find("plot") or n:find("ceil") then
                if not xrayOrig[obj] then xrayOrig[obj] = obj.Transparency end
                obj.Transparency = 0.72
            end
        end
    end
end
local function disableXray()
    if not xrayOn then return end
    xrayOn = false
    for obj, t in pairs(xrayOrig) do
        pcall(function() if obj and obj.Parent then obj.Transparency = t end end)
    end
    xrayOrig = {}
end

-- Brainrot Transparency
local btOn = false
local btOrig = {}
local function enableBrainTrans()
    if btOn then return end
    btOn = true
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            for _, obj in ipairs(pod:GetDescendants()) do
                if obj:IsA("BasePart") then
                    if not btOrig[obj] then btOrig[obj] = obj.Transparency end
                    obj.Transparency = 0.65
                end
            end
        end
    end
end
local function disableBrainTrans()
    if not btOn then return end
    btOn = false
    for obj, t in pairs(btOrig) do
        pcall(function() if obj and obj.Parent then obj.Transparency = t end end)
    end
    btOrig = {}
end

-- Admin remote
local ADM_REMOTE = nil
task.spawn(function()
    pcall(function() if not lp.Character then lp.CharacterAdded:Wait() end end)
    task.wait(1.5)
    pcall(function()
        local net = RS:WaitForChild("Packages"):WaitForChild("Net")
        local ch = net:GetChildren()
        local n2i = {}
        for i, o in ipairs(ch) do n2i[o.Name] = i end
        local a = n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
        if a and ch[a+1] then ADM_REMOTE = ch[a+1] end
    end)
end)
local ADM_UUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
local function aFire(tgt, cmd)
    task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID, tgt, cmd) end) end)
end
local ROW_CD = {ragdoll=30, balloon=30, tiny=60, jail=60, rocket=120}
local CMD_ICONS = {ragdoll="🤸", balloon="🎈", tiny="🐜", jail="🔒", rocket="🚀"}
local rowCdEnd = {}
local function fireCmd(tgt, cmd)
    if not ADM_REMOTE then return end
    aFire(tgt, cmd)
    rowCdEnd[cmd] = tick() + (ROW_CD[cmd] or 30)
end
local CLICK_CMDS = {"inverse", "tiny", "jumpscare", "rocket", "morph"}
local function fireClick(tgt)
    if not ADM_REMOTE then return end
    for _, cmd in ipairs(CLICK_CMDS) do
        aFire(tgt, cmd)
        if ROW_CD[cmd] then rowCdEnd[cmd] = tick() + ROW_CD[cmd] end
    end
end

-- Giant Potion
local potionOn = Cfg.potionOn
local function activatePotion()
    if not potionOn then return end
    task.spawn(function()
        pcall(function()
            local char = lp.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local bp = lp:FindFirstChild("Backpack")
            local tool = char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion"))
            if not tool then return end
            hum:EquipTool(tool)
            task.wait(0.08)
            tool:Activate()
        end)
    end)
end

-- Carpet equip (FIXED: no manual parent change = carpet stays working)
local CARPET_KW = {"carpet","tapis","flying","witch","broom","sleigh","cupid","wing"}
local function equipCarpetTool()
    local char = lp.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local bp = lp:FindFirstChild("Backpack")
    local found = nil
    local function chk(t)
        if not t:IsA("Tool") then return end
        local nl = t.Name:lower()
        for _, kw in ipairs(CARPET_KW) do if nl:find(kw) then found = t; return end end
    end
    if bp then for _, t in ipairs(bp:GetChildren()) do if not found then chk(t) end end end
    if not found then for _, t in ipairs(char:GetChildren()) do if not found then chk(t) end end end
    if found then
        hum:EquipTool(found)
        return true
    end
    return false
end
local function doReset()
    local c = lp.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
    if not h then return end
    local eq = equipCarpetTool()
    if eq then task.wait(0.1) end
    h.CFrame = CFrame.new(0, 15000, 0)
end

local FLASH_NAMES = {"Flash Teleport", "Flash", "FlashTP", "Flash TP"}
local function equipFlash()
    pcall(function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        for _, n in ipairs(FLASH_NAMES) do
            local t = char:FindFirstChild(n) or (lp.Backpack and lp.Backpack:FindFirstChild(n))
            if t then
                if t.Parent ~= char then hum:EquipTool(t) end
                return
            end
        end
    end)
end

-- Flash RF (RF/Tools/Flash/Activate = bypasses timing checks)
local FLASH_RF = nil
task.spawn(function()
    pcall(function()
        local net = RS:WaitForChild("Packages"):WaitForChild("Net")
        FLASH_RF = net:FindFirstChild("RF/Tools/Flash/Activate") or net:WaitForChild("RF/Tools/Flash/Activate", 10)
    end)
end)

-- Remove flash visual effects (reduces lag)
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local flashAsset = RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Tools") and RS.Assets.Tools:FindFirstChild("Flash Teleport")
            if flashAsset then
                for _, v in ipairs(flashAsset:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") or v:IsA("Smoke") then
                        pcall(function() v.Enabled = false end)
                    end
                    if v:IsA("Sound") then pcall(function() v.Volume = 0 end) end
                end
            end
        end)
        pcall(function()
            local char = lp.Character
            if not char then return end
            for _, n in ipairs(FLASH_NAMES) do
                local t = char:FindFirstChild(n)
                if t then
                    for _, v in ipairs(t:GetDescendants()) do
                        if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
                            pcall(function() v.Enabled = false end)
                        end
                        if v:IsA("Sound") then pcall(function() v.Volume = 0 end) end
                    end
                end
            end
        end)
    end
end)

-- Strong self-lag (50ms busy wait, actually freezes client thread)
local function lagSelf()
    local deadline = tick() + 0.05
    local x = 0
    while tick() < deadline do
        for i = 1, 500 do x = x + math.sqrt(i) * 0.001 end
    end
    return x
end

-- Auto allign (Phantom Hub cfA/cfB, FIXED B-side by Z position)
local CAM_A = CFrame.new(-322.066, -7.871, 111.991) * CFrame.Angles(0.332, -0.019, 0.000)
local CAM_B = CFrame.new(-325.856, -7.866, 113.027) * CFrame.Angles(0.327, 3.130, 0.000)
local BASE1_X_MIN, BASE1_X_MAX = -345, -285
local BASE1_Z_MIN, BASE1_Z_MAX = 75, 155
local function isInBase1()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local p = hrp.Position
    return p.X >= BASE1_X_MIN and p.X <= BASE1_X_MAX and p.Z >= BASE1_Z_MIN and p.Z <= BASE1_Z_MAX
end
local PodiumPoints = {
    {pos=Vector3.new(-330.3,-4.9,94.6)},{pos=Vector3.new(-323.4,-4.9,94.0)},{pos=Vector3.new(-315.9,-4.9,94.2)},
    {pos=Vector3.new(-309.7,-4.9,94.2)},{pos=Vector3.new(-296.8,-5.4,93.7)},{pos=Vector3.new(-300.4,-5.2,129.8)},
    {pos=Vector3.new(-306.6,-5.4,128.0)},{pos=Vector3.new(-317.0,-5.1,134.5)},{pos=Vector3.new(-324.1,-4.9,131.7)},
    {pos=Vector3.new(-336.7,-5.4,130.5)},{pos=Vector3.new(-329.9,13.1,93.7)},{pos=Vector3.new(-324.2,12.8,102.0)},
    {pos=Vector3.new(-315.9,12.8,92.8)},{pos=Vector3.new(-309.4,13.1,94.2)},{pos=Vector3.new(-299.3,12.9,93.4)},
    {pos=Vector3.new(-323.5,12.6,122.7)},{pos=Vector3.new(-336.7,12.6,131.6)},{pos=Vector3.new(-316.8,12.6,122.1)},
    {pos=Vector3.new(-334.2,29.6,93.5)},{pos=Vector3.new(-322.9,29.8,92.7)},{pos=Vector3.new(-312.9,30.0,93.9)},
    {pos=Vector3.new(-305.8,30.1,93.6)},{pos=Vector3.new(-299.9,30.1,93.5)},{pos=Vector3.new(-335.8,29.6,131.6)},
    {pos=Vector3.new(-321.3,29.8,127.1)},{pos=Vector3.new(-314.6,29.8,134.6)},{pos=Vector3.new(-306.4,29.7,127.6)}
}
local function getNearestPodium()
    local char = lp.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local myPos = hrp.Position
    local si, ei
    if myPos.Y < 5 then si, ei = 1, 10
    elseif myPos.Y < 22 then si, ei = 11, 18
    else si, ei = 19, 27 end
    local nearest, minD = nil, math.huge
    for i = si, ei do
        local pt = PodiumPoints[i]
        if pt then
            local d = (myPos - pt.pos).Magnitude
            if d < minD then minD = d; nearest = pt end
        end
    end
    return nearest
end
local function doAutoAlign()
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if isInBase1() then
        local nearest = getNearestPodium()
        if nearest then
            equipCarpetTool()
            task.wait(0.05)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.CFrame = CFrame.new(nearest.pos)
            task.wait(0.1)
        end
    end
    -- Z-based side detection: A side Z<115, B side Z>=115
    local targetLook = hrp.Position.Z < 115 and CAM_A.LookVector or CAM_B.LookVector
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + targetLook)
    task.wait()
    cam.CameraType = Enum.CameraType.Custom
    equipFlash()
end

-- Flash ghost (simple neon ring)
local ghostPart = nil
local flashOnCooldown = false
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local tool = char:FindFirstChildOfClass("Tool")
        local hasFlash = false
        if tool then
            for _, n in ipairs(FLASH_NAMES) do
                if tool.Name == n then hasFlash = true; break end
            end
        end
        if not hasFlash then
            if ghostPart then ghostPart.Transparency = 1 end
            return
        end
        if not ghostPart then
            ghostPart = Instance.new("Part")
            ghostPart.Anchored = true
            ghostPart.CanCollide = false
            ghostPart.Size = Vector3.new(2.5, 0.1, 2.5)
            ghostPart.Material = Enum.Material.Neon
            ghostPart.CastShadow = false
            ghostPart.Name = "AethFlashGhost"
            ghostPart.Parent = workspace
        end
        local lookDir = cam.CFrame.LookVector
        local flat = Vector3.new(lookDir.X, 0, lookDir.Z)
        if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
        ghostPart.CFrame = CFrame.new(hrp.Position + flat * 50)
        ghostPart.Color = flashOnCooldown and C.red or C.white
        ghostPart.Transparency = flashOnCooldown and 0.6 or 0.4
    end)
end)

-- ==========================================================
-- FLASH TP (PRERENDER / RenderStepped = maximum accuracy)
-- Uses RF/Tools/Flash/Activate directly (bypasses >85% block)
-- Fires BEFORE each frame (prerender = Phantom Hub method)
-- ==========================================================
local flashEnabled = Cfg.flashOn
local sliderValue = Cfg.triggerChance / 100
local lagOnSteal = Cfg.lagOn
local function fireFlashActivate()
    local char = lp.Character
    if not char then return end
    if FLASH_RF then
        local ok = pcall(function() FLASH_RF:InvokeServer() end)
        if ok then return end
    end
    for _, n in ipairs(FLASH_NAMES) do
        local tool = char:FindFirstChild(n)
        if tool then
            local ok, conns = pcall(getconnections, tool.Activated)
            if ok and type(conns) == "table" and #conns > 0 then
                for _, c in ipairs(conns) do if c.Function then task.spawn(c.Function) end end
                return
            end
            pcall(function() tool:Activate() end)
            return
        end
    end
end
PPS.PromptButtonHoldBegan:Connect(function(prompt)
    if not flashEnabled or prompt.ActionText ~= "Steal" then return end
    local startTime = os.clock()
    local holdDur = math.max(prompt.HoldDuration, 0.001)
    local fired = false
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if fired then conn:Disconnect(); return end
        if not prompt or not prompt.Parent then conn:Disconnect(); return end
        if (os.clock() - startTime) / holdDur >= sliderValue then
            fired = true
            conn:Disconnect()
            flashOnCooldown = true
            task.delay(20, function() flashOnCooldown = false end)
            if lagOnSteal then lagSelf() end
            task.spawn(fireFlashActivate)
            task.spawn(function()
                task.wait(0.04)
                local extFired = false
                pcall(function()
                    local conns = getconnections(prompt.Triggered)
                    if conns and #conns > 0 then
                        for _, c in ipairs(conns) do if c.Function then task.spawn(c.Function) end end
                        extFired = true
                    end
                end)
                if not extFired then
                    pcall(function() fireproximityprompt(prompt, 10000) end)
                    pcall(function() prompt:InputHoldBegin (); task.wait(0.04); prompt:InputHoldEnd() end)
end
end)
task.spawn(function() activatePotion() end)
end
end)
prompt.PromptButtonHoldEnded:Connect(function()
if not fired then fired = true; conn:Disconnect() end
end)
end)
-- Speed
local stealSpdOn = Cfg.stealSpdOn
local STEAL_SPD_VAL = math.clamp(Cfg.stealSpdVal or 30, 10, 60)
local speedEnabled = stealSpdOn
local stealingSpeed = STEAL_SPD_VAL
local function applySpeed()
local char = lp.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
local hum = char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end
local dir = hum.MoveDirection
if dir.Magnitude > 0 then
root.Velocity = Vector3.new(dir.X * stealingSpeed, root.Velocity.Y, dir.Z * stealingSpeed)
end
end
-- Base protector
local antiSteal = false
local autoKickBase = false
local lastPunish = {}
local myStealPrompts = {}
task.spawn(function()
while true do
task.wait(2)
myStealPrompts = {}
if myPlotRef then
for _, obj in ipairs(myPlotRef:GetDescendants()) do
if obj:IsA("ProximityPrompt") and obj.ActionText == "Steal" and obj.Enabled then
table.insert(myStealPrompts, obj)
end
end
end
end
end)
local function punish(p)
if not ADM_REMOTE or not p or p == lp then return end
local uid = p.UserId
local now = tick()
if lastPunish[uid] and now - lastPunish[uid] < 0.5 then return end
lastPunish[uid] = now
pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID, p, "balloon") end)
rowCdEnd["balloon"] = tick() + (ROW_CD["balloon"] or 30)
if autoKickBase then task.delay(0.05, function() lp:Kick("SAVED BY AETHEN") end) end
end
local function findThief()
if #myStealPrompts > 0 then
local best, bd = nil, math.huge
for _, prompt in ipairs(myStealPrompts) do
if not prompt or not prompt.Parent then continue end
local pPart = prompt.Parent
local pPos = pPart:IsA("BasePart") and pPart.Position or (pPart:IsA("Attachment") and pPart.WorldPosition)
if not pPos then continue end
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hrp then
local d = (hrp.Position - pPos).Magnitude
if d <= math.max(prompt.MaxActivationDistance, 8) and d < bd then
bd = d; best = p
end
end
end
end
end
if best then return best end
end
if stealHitbox then
local hbPos = stealHitbox.Position
local best, bd = nil, math.huge
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hrp then
local d = (hrp.Position - hbPos).Magnitude
if d < bd then bd = d; best = p end
end
end
end
return best
end
return nil
end
local function isPromptOnMyBase(prompt)
if not myPlotRef then return false end
local a = prompt.Parent
while a and a ~= workspace do
if a == myPlotRef then return true end
a = a.Parent
end
return false
end
pcall(function()
if not hookfunction or not fireproximityprompt then return end
local old = fireproximityprompt
hookfunction(fireproximityprompt, newcclosure(function(prompt, ...)
if antiSteal and (prompt.ActionText or ""):lower():find("steal") and isPromptOnMyBase(prompt) then
local thief = findThief()
if thief then punish(thief) end
end
return old(prompt, ...)
end))
end)
task.spawn(function()
pcall(function()
local net = RS:WaitForChild("Packages"):WaitForChild("Net", 8)
if not net then return end
local grabRE = net:FindFirstChild("RE/StealService/Grab")
local succRE = net:FindFirstChild("RE/StealService/StealingSuccess")
if grabRE then
grabRE.OnClientEvent:Connect(function()
if antiSteal and ADM_REMOTE and myPlotRef then
local t = findThief(); if t then punish(t) end
end
end)
end
if succRE then
succRE.OnClientEvent:Connect(function()
if antiSteal and ADM_REMOTE and myPlotRef then
local t = findThief(); if t then punish(t) end
end
end)
end
end)
end)
-- ============================================================
-- ADMIN DETECTION (scans who has admin commands gamepass)
-- Uses MarketplaceService:UserOwnsGamePassAsync (read-only)
-- ============================================================
task.spawn(function()
task.wait(3)
if ADMIN_GP_ID ~= 0 then return end
pcall(function()
local shop = workspace:FindFirstChild("RobuxShop")
if shop then
for _, obj in ipairs(shop:GetDescendants()) do
if obj.Name:lower():find("admin") then
local id = obj:GetAttribute("GamepassId") or obj:GetAttribute("GamePassId") or obj:GetAttribute("ItemId")
if id and type(id) == "number" and id > 0 then
ADMIN_GP_ID = id
return
end
for _, child in ipairs(obj:GetChildren()) do
if (child:IsA("IntValue") or child:IsA("NumberValue")) and child.Value > 0 then
if child.Name:lower():find("id") or child.Name:lower():find("pass") then
ADMIN_GP_ID = child.Value
return
end
end
end
end
end
end
end)
end)
local adminScanResult = {count = 0, names = {}}
local function checkPlayerAdmin(p)
if ADMIN_GP_ID > 0 then
local ok, owns = pcall(function() return MPS:UserOwnsGamePassAsync(p.UserId, ADMIN_GP_ID) end)
if ok and owns then return true end
end
if p.Character then
for _, item in ipairs(p.Character:GetDescendants()) do
if item.Name:lower():find("admin") then return true end
end
end
for _, attr in ipairs({"Admin", "AdminLevel", "HasAdmin", "IsAdmin", "AdminCommands"}) do
if p:GetAttribute(attr) then return true end
end
return false
end
-- Heartbeat
local cmdBtnRefs = {}
local lastDt = 1/60
RunService.Heartbeat:Connect(function(dt)
lastDt = dt
local now = tick()
if speedEnabled then applySpeed() end
for _, cmds in pairs(cmdBtnRefs) do
for cmd, ib in pairs(cmds) do
if ib and ib.Parent then
local cd = rowCdEnd[cmd]
if cd and cd > now then
local rem = math.ceil(cd - now)
if ib.Text ~= tostring(rem) then
ib.Text = tostring(rem)
ib.TextSize = 7
ib.TextColor3 = C.red
ib.BackgroundColor3 = Color3.fromRGB(40, 5, 5)
ib.BackgroundTransparency = 0.08
end
else
local icon = CMD_ICONS[cmd] or "?"
if ib.Text ~= icon then
ib.Text = icon
ib.TextSize = 10
ib.TextColor3 = C.white
ib.BackgroundColor3 = C.surf2
ib.BackgroundTransparency = 0.08
end
end
end
end
end
end)
-- =====================================================
-- GUI PANELS
-- =====================================================
task.wait(0.15)
vp = cam.ViewportSize
if vp.X == 0 then vp = Vector2.new(390, 844) end
-- Header (not draggable)
local hdrW = 196
local hdrH = 66
local hdrF = Instance.new("Frame", SG)
hdrF.Size = UDim2.fromOffset(hdrW, hdrH)
hdrF.Position = UDim2.fromOffset(math.floor(vp.X * 0.5 - hdrW * 0.5), 4)
hdrF.BackgroundColor3 = C.bg
hdrF.BackgroundTransparency = 0.12
hdrF.BorderSizePixel = 0
hdrF.Active = false
co(hdrF, 8)
addAnimBorder(hdrF)
addParticles(hdrF, 3)
lb(hdrF, {Position=UDim2.fromOffset(0,5), Size=UDim2.new(1,0,0,16), Text="AETHEN FLASH TP  v0.2", TextSize=10, Font=Enum.Font.GothamBlack, TextColor3=C.white, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4})
lb(hdrF, {Position=UDim2.fromOffset(0,20), Size=UDim2.new(1,0,0,11), Text="r9qbx", TextSize=7, Font=Enum.Font.Gotham, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4})
local fpsLb = lb(hdrF, {Position=UDim2.fromOffset(0,31), Size=UDim2.new(1,0,0,11), Text="FPS --   PING -- ms", TextSize=7, Font=Enum.Font.GothamBold, TextColor3=C.grn, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4})
task.spawn(function()
while task.wait(0.7) do
if not fpsLb.Parent then break end
local fps = math.min(999, math.floor(1 / math.max(lastDt, 0.001)))
local ping = 0
pcall(function() ping = math.floor(lp:GetNetworkPing() * 1000) end)
fpsLb.Text = "FPS " .. fps .. "   PING " .. ping .. "ms"
fpsLb.TextColor3 = fps < 40 and C.red or fps < 55 and C.yel or C.grn
end
end)
local rsPnlBtn = mkBtn(hdrF, "Reset Panels", UDim2.fromOffset(88, 13), UDim2.fromOffset(4, 49), C.surf, C.dim, 4)
rsPnlBtn.TextSize = 7
rsPnlBtn.ZIndex = 5
-- Admin warning text (flashing red, below header)
local warnF = Instance.new("Frame", SG)
warnF.Size = UDim2.fromOffset(260, 18)
warnF.Position = UDim2.new(0.5, -130, 0, hdrH + 8)
warnF.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
warnF.BackgroundTransparency = 0.15
warnF.BorderSizePixel = 0
warnF.ZIndex = 10
co(warnF, 5)
addAnimBorder(warnF)
local warnLbl = lb(warnF, {
Size = UDim2.new(1, 0, 1, 0),
Text = "Scanning for admins...",
TextSize = 7,
Font = Enum.Font.GothamBlack,
TextColor3 = C.red,
ZIndex = 11
})
task.spawn(function()
while warnLbl.Parent do
TweenService:Create(warnLbl, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.75}):Play()
task.wait(0.45)
if not warnLbl.Parent then break end
TweenService:Create(warnLbl, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
task.wait(0.45)
end
end)
-- Admin scan background loop
task.spawn(function()
task.wait(4)
while true do
local found = {}
local total = #Players:GetPlayers()
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp then
task.wait(0.3)
local ok, hasAdmin = pcall(checkPlayerAdmin, p)
if ok and hasAdmin then table.insert(found, p.Name) end
end
end
adminScanResult.count = #found
adminScanResult.names = found
if #found > 0 then
warnLbl.Text = "!! " .. #found .. " ADMIN(S): " .. table.concat(found, ", ")
warnLbl.TextColor3 = C.red
warnF.Size = UDim2.fromOffset(math.min(vp.X - 20, math.max(260, #found * 70 + 80)), 18)
warnF.Position = UDim2.new(0.5, -math.floor(math.min(vp.X - 20, math.max(260, #found * 70 + 80)) / 2), 0, hdrH + 8)
else
warnLbl.Text = total .. " players in server  |  No admin found"
warnLbl.TextColor3 = C.grn
end
task.wait(28)
end
end)
-- Flash TP panel
local FP_W = 148
local CONT_H = 195
local FP_H = 22 + 22 + CONT_H + 4
local FP_defX = math.floor(vp.X - FP_W - 4)
local FP_defY = 5
local FP, _, fpMin = mkP(FP_defX, FP_defY, FP_W, FP_H, "FLASH TP", "pos_FP")
local fpFolded = false
local FP_fullH = FP_H
fpMin.MouseButton1Click:Connect(function()
fpFolded = not fpFolded
fpMin.Text = fpFolded and "+" or "-"
TweenService:Create(FP, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(FP_W, fpFolded and 24 or FP_fullH)}):Play()
end)
-- Tab bar (MAIN / EXTRAS with highlight)
local tabRow = Instance.new("Frame", FP)
tabRow.Size = UDim2.fromOffset(FP_W, 20)
tabRow.Position = UDim2.fromOffset(0, 23)
tabRow.BackgroundColor3 = C.surf2
tabRow.BackgroundTransparency = 0.05
tabRow.BorderSizePixel = 0
local tabMain = Instance.new("TextButton", tabRow)
tabMain.Size = UDim2.new(0.5, 0, 1, 0)
tabMain.BackgroundColor3 = C.white
tabMain.Text = "MAIN"
tabMain.Font = Enum.Font.GothamBlack
tabMain.TextSize = 8
tabMain.TextColor3 = C.bg
tabMain.BorderSizePixel = 0
tabMain.AutoButtonColor = false
co(tabMain, 0)
local tabExtras = Instance.new("TextButton", tabRow)
tabExtras.Size = UDim2.new(0.5, 0, 1, 0)
tabExtras.Position = UDim2.new(0.5, 0, 0, 0)
tabExtras.BackgroundColor3 = C.surf2
tabExtras.Text = "EXTRAS"
tabExtras.Font = Enum.Font.GothamBlack
tabExtras.TextSize = 8
tabExtras.TextColor3 = C.dim
tabExtras.BorderSizePixel = 0
tabExtras.AutoButtonColor = false
co(tabExtras, 0)
local tabSep = Instance.new("Frame", FP)
tabSep.Size = UDim2.new(1, -8, 0, 1)
tabSep.Position = UDim2.fromOffset(4, 43)
tabSep.BackgroundColor3 = C.white
tabSep.BackgroundTransparency = 0.65
tabSep.BorderSizePixel = 0
local cont = Instance.new("Frame", FP)
cont.Size = UDim2.fromOffset(FP_W, CONT_H)
cont.Position = UDim2.fromOffset(0, 45)
cont.BackgroundTransparency = 1
cont.BorderSizePixel = 0
cont.ClipsDescendants = true
-- Page 1: Main
local pg1 = Instance.new("Frame", cont)
pg1.Size = UDim2.fromOffset(FP_W, CONT_H)
pg1.BackgroundTransparency = 1
pg1.BorderSizePixel = 0
local lagRow, lagSet = mkPill(pg1, "Lag On Steal", 4, C.white)
if lagOnSteal then lagSet(true) end
lagRow.MouseButton1Click:Connect(function()
lagOnSteal = not lagOnSteal
lagSet(lagOnSteal)
Cfg.lagOn = lagOnSteal
save()
end)
local potRow, potSet = mkPill(pg1, "Giant Potion", 26, C.white)
if potionOn then potSet(true) end
potRow.MouseButton1Click:Connect(function()
potionOn = not potionOn
Cfg.potionOn = potionOn
save()
potSet(potionOn)
end)
local sep1p = Instance.new("Frame", pg1)
sep1p.Size = UDim2.new(1, -8, 0, 1)
sep1p.Position = UDim2.fromOffset(4, 48)
sep1p.BackgroundColor3 = C.white
sep1p.BackgroundTransparency = 0.65
sep1p.BorderSizePixel = 0
-- Flash TP toggle
local togRow = Instance.new("Frame", pg1)
togRow.Size = UDim2.fromOffset(FP_W - 8, 20)
togRow.Position = UDim2.fromOffset(4, 52)
togRow.BackgroundColor3 = C.surf
togRow.BackgroundTransparency = 0.1
togRow.BorderSizePixel = 0
co(togRow, 5)
local togRS = Instance.new("UIStroke", togRow)
togRS.Thickness = 1
togRS.Color = C.white
togRS.Transparency = 0.6
togRS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local togLbl = lb(togRow, {Position=UDim2.new(0,6,0,0), Size=UDim2.new(1,-32,1,0), Text="Flash TP", TextSize=7, Font=Enum.Font.GothamBold, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left})
local fpill = Instance.new("Frame", togRow)
fpill.Size = UDim2.fromOffset(22, 11)
fpill.Position = UDim2.new(1, -25, 0.5, -5.5)
fpill.BackgroundColor3 = C.surf2
fpill.BorderSizePixel = 0
co(fpill, 12)
local fknob = Instance.new("Frame", fpill)
fknob.Size = UDim2.fromOffset(8, 8)
fknob.Position = UDim2.new(0, 1.5, 0.5, -4)
fknob.BackgroundColor3 = C.dim
fknob.BorderSizePixel = 0
co(fknob, 8)
local togB = Instance.new("TextButton", togRow)
togB.Size = UDim2.new(1, 0, 1, 0)
togB.BackgroundTransparency = 1
togB.Text = ""
local function updFl()
TweenService:Create(togRow, TweenInfo.new(0.12), {BackgroundColor3 = flashEnabled and C.surf2 or C.surf, BackgroundTransparency = flashEnabled and 0.05 or 0.1}):Play()
TweenService:Create(togRS, TweenInfo.new(0.12), {Transparency = flashEnabled and 0.2 or 0.6}):Play()
TweenService:Create(fpill, TweenInfo.new(0.12), {BackgroundColor3 = flashEnabled and C.white or C.surf2}):Play()
TweenService:Create(fknob, TweenInfo.new(0.12), {Position = flashEnabled and UDim2.new(1,-9.5,0.5,-4) or UDim2.new(0,1.5,0.5,-4), BackgroundColor3 = flashEnabled and C.bg or C.dim}):Play()
togLbl.TextColor3 = flashEnabled and C.white or C.dim
end
updFl()
togB.MouseButton1Click:Connect(function()
flashEnabled = not flashEnabled
Cfg.flashOn = flashEnabled
save()
updFl()
end)
local trigL = lb(pg1, {Position=UDim2.fromOffset(4,76), Size=UDim2.fromOffset(FP_W-8,10), Text="Trigger: "..Cfg.triggerChance.."%", TextSize=7, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left})
local slBg = Instance.new("Frame", pg1)
slBg.Size = UDim2.fromOffset(FP_W - 8, 5)
slBg.Position = UDim2.fromOffset(4, 89)
slBg.BackgroundColor3 = C.surf2
slBg.BorderSizePixel = 0
co(slBg, 3)
local slFill = Instance.new("Frame", slBg)
slFill.Size = UDim2.new(sliderValue, 0, 1, 0)
slFill.BackgroundColor3 = C.white
slFill.BorderSizePixel = 0
co(slFill, 3)
local slK = Instance.new("Frame", slBg)
slK.Size = UDim2.fromOffset(10, 10)
slK.AnchorPoint = Vector2.new(0.5, 0.5)
slK.Position = UDim2.new(sliderValue, 0, 0.5, 0)
slK.BackgroundColor3 = C.white
slK.BorderSizePixel = 0
co(slK, 5)
local slOn = false
local function setTr(pct)
pct = math.clamp(pct, 0, 1)
sliderValue = pct
Cfg.triggerChance = math.floor(pct * 100)
slFill.Size = UDim2.new(pct, 0, 1, 0)
slK.Position = UDim2.new(pct, 0, 0.5, 0)
trigL.Text = "Trigger: " .. math.floor(pct * 100) .. "%"
end
slBg.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
slOn = true
setTr((i.Position.X - slBg.AbsolutePosition.X) / slBg.AbsoluteSize.X)
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
if slOn then slOn = false; save() end
end
end)
UIS.InputChanged:Connect(function(i)
if not slOn then return end
if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
setTr((i.Position.X - slBg.AbsolutePosition.X) / slBg.AbsoluteSize.X)
end
end)
-- Auto Allign in main page
local camBusy = false
local camBtn = mkBtn(pg1, "AUTO ALLIGN", UDim2.fromOffset(FP_W - 8, 19), UDim2.fromOffset(4, 98), C.surf, C.white, 5)
camBtn.TextSize = 8
camBtn.MouseButton1Click:Connect(function()
if camBusy then return end
camBusy = true
camBtn.Text = "Aligning..."
task.spawn(function()
pcall(doAutoAlign)
camBtn.Text = "AUTO ALLIGN"
camBusy = false
end)
end)
-- Page 2: Extras
local pg2 = Instance.new("Frame", cont)
pg2.Size = UDim2.fromOffset(FP_W, CONT_H)
pg2.BackgroundTransparency = 1
pg2.BorderSizePixel = 0
pg2.Visible = false
local function setTab(isMain)
tabMain.BackgroundColor3 = isMain and C.white or C.surf2
tabMain.TextColor3 = isMain and C.bg or C.dim
tabExtras.BackgroundColor3 = not isMain and C.white or C.surf2
tabExtras.TextColor3 = not isMain and C.bg or C.dim
pg1.Visible = isMain
pg2.Visible = not isMain
end
tabMain.MouseButton1Click:Connect(function() setTab(true) end)
tabExtras.MouseButton1Click:Connect(function() setTab(false) end)
setTab(true)
local ssB, ssSet = mkPill(pg2, "Steal Speed", 4, C.white)
ssB.MouseButton1Click:Connect(function()
stealSpdOn = not stealSpdOn
speedEnabled = stealSpdOn
ssSet(stealSpdOn)
Cfg.stealSpdOn = stealSpdOn
save()
end)
if stealSpdOn then ssSet(true); speedEnabled = true end
numRow(pg2, "Speed", STEAL_SPD_VAL, 10, 60, 26, FP_W, function(v) STEAL_SPD_VAL = v; stealingSpeed = v; Cfg.stealSpdVal = v; save() end)
local sep2p = Instance.new("Frame", pg2)
sep2p.Size = UDim2.new(1, -8, 0, 1)
sep2p.Position = UDim2.fromOffset(4, 48)
sep2p.BackgroundColor3 = C.white
sep2p.BackgroundTransparency = 0.65
sep2p.BorderSizePixel = 0
local brainESPB, brainESPSet = mkPill(pg2, "Brainrot ESP", 52, C.white)
brainESPB.MouseButton1Click:Connect(function()
if brainrotESPEnabled then stopBrainrotESP(); brainESPSet(false) else startBrainrotESP(); brainESPSet(true) end
end)
local friendESPB, friendESPSet = mkPill(pg2, "Friends ESP", 74, C.white)
friendESPB.MouseButton1Click:Connect(function()
if friendESPEnabled then stopFriendESP(); friendESPSet(false) else startFriendESP(); friendESPSet(true) end
end)
local function mkWarnPill(parent, label, warn, yPos, warnCol)
local row = Instance.new("Frame")
row.Size = UDim2.new(1, -8, 0, 19)
row.Position = UDim2.new(0, 4, 0, yPos)
row.BackgroundColor3 = C.surf
row.BackgroundTransparency = 0.1
row.BorderSizePixel = 0
row.Parent = parent
co(row, 5)
local rs2 = Instance.new("UIStroke", row)
rs2.Thickness = 1
rs2.Color = C.white
rs2.Transparency = 0.6
rs2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
lb(row, {Position=UDim2.new(0,6,0,0), Size=UDim2.new(0.55,0,1,0), Text=label, TextSize=6, Font=Enum.Font.GothamBold, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left})
lb(row, {Position=UDim2.new(0.55,0,0,0), Size=UDim2.new(0.45,-28,1,0), Text=warn, TextSize=6, Font=Enum.Font.GothamBold, TextColor3=warnCol or C.red, TextXAlignment=Enum.TextXAlignment.Right})
local track2 = Instance.new("Frame", row)
track2.Size = UDim2.fromOffset(22, 11)
track2.Position = UDim2.new(1, -25, 0.5, -5.5)
track2.BackgroundColor3 = C.surf2
track2.BorderSizePixel = 0
co(track2, 12)
local knob2 = Instance.new("Frame", track2)
knob2.Size = UDim2.fromOffset(8, 8)
knob2.Position = UDim2.new(0, 1.5, 0.5, -4)
knob2.BackgroundColor3 = C.dim
knob2.BorderSizePixel = 0
co(knob2, 8)
local pb2 = Instance.new("TextButton", row)
pb2.Size = UDim2.new(1, 0, 1, 0)
pb2.BackgroundTransparency = 1
pb2.Text = ""
local function set2(v)
TweenService:Create(track2, TweenInfo.new(0.12), {BackgroundColor3 = v and C.white or C.surf2}):Play()
TweenService:Create(knob2, TweenInfo.new(0.12), {Position = v and UDim2.new(1,-9.5,0.5,-4) or UDim2.new(0,1.5,0.5,-4), BackgroundColor3 = v and C.bg or C.dim}):Play()
end
return pb2, set2
end
local xrBtn2, xrSet = mkWarnPill(pg2, "Base Xray", "[DETECTED]", 96, C.red)
local xrOn2 = false
xrBtn2.MouseButton1Click:Connect(function()
if xrOn2 then disableXray(); xrOn2 = false; xrSet(false) else enableXray(); xrOn2 = true; xrSet(true) end
end)
local btBtn2, btSet = mkWarnPill(pg2, "Brainrot Trans", "[RISK]", 118, C.yel)
local btOn2 = false
btBtn2.MouseButton1Click:Connect(function()
if btOn2 then disableBrainTrans(); btOn2 = false; btSet(false) else enableBrainTrans(); btOn2 = true; btSet(true) end
end)
-- Aethens panel
local AP_W = 128
local AP_CH = 70
local AP_H = 22 + AP_CH + 6
local AP_defX = 4
local AP_defY = hdrH + 4 + 8
local AP, _, apMin = mkP(AP_defX, AP_defY, AP_W, AP_H, "AETHENS", "pos_AP")
local apC = Instance.new("Frame", AP)
apC.Size = UDim2.new(1, 0, 0, AP_CH)
apC.Position = UDim2.fromOffset(0, 24)
apC.BackgroundTransparency = 1
apC.BorderSizePixel = 0
local apFolded = false
apMin.MouseButton1Click:Connect(function()
apFolded = not apFolded
apMin.Text = apFolded and "+" or "-"
TweenService:Create(AP, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(AP_W, apFolded and 24 or AP_H)}):Play()
end)
local aY = 4
local function apB(text, tc, bg)
local b = mkBtn(apC, text, UDim2.fromOffset(AP_W - 8, 19), UDim2.fromOffset(4, aY), bg or C.surf, tc, 5)
b.TextSize = 8
aY = aY + 23
return b
end
local rejB = apB("Rejoin", C.white)
rejB.MouseButton1Click:Connect(function()
rejB.Text = "..."
pcall(function()
if reconnect then reconnect()
elseif syn and syn.reconnect then syn.reconnect()
else TeleportService:Teleport(game.PlaceId, lp) end
end)
end)
local kickB = apB("Kick Self", C.red, Color3.fromRGB(22, 4, 6))
kickB.MouseButton1Click:Connect(function() kickB.Text = "..."; lp:Kick(DISCORD_LINK) end)
local rstAB = apB("Instant Reset", C.red, Color3.fromRGB(22, 4, 6))
rstAB.MouseButton1Click:Connect(function() task.spawn(doReset) end)
-- Admin panel
local RCMDS = {{cmd="ragdoll",icon="🤸"},{cmd="balloon",icon="🎈"},{cmd="tiny",icon="🐜"},{cmd="jail",icon="🔒"},{cmd="rocket",icon="🚀"}}
local IW2 = 15
local IH2 = 15
local IG2 = 2
local ADM_W = 170
local ITOT = #RCMDS * (IW2 + IG2) - IG2
local CSTART = (ADM_W - 10) - ITOT - 2
local ADM_defX = math.floor(vp.X - ADM_W - 4)
local ADM_defY = FP_H + FP_defY + 4
local ADM, _, admMin = mkP(ADM_defX, ADM_defY, ADM_W, 24, "ADMIN", "pos_ADM")
local pScroll = Instance.new("ScrollingFrame", ADM)
pScroll.Size = UDim2.fromOffset(ADM_W - 6, 0)
pScroll.Position = UDim2.fromOffset(3, 22)
pScroll.BackgroundColor3 = C.bg
pScroll.BackgroundTransparency = 0.15
pScroll.BorderSizePixel = 0
pScroll.ScrollBarThickness = 2
pScroll.ScrollBarImageColor3 = C.white
pScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
pScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
co(pScroll, 4)
local pLayout = Instance.new("UIListLayout", pScroll)
pLayout.Padding = UDim.new(0, 2)
pLayout.SortOrder = Enum.SortOrder.Name
Instance.new("UIPadding", pScroll).PaddingTop = UDim.new(0, 2)
local admFolded = false
local function resADM()
if admFolded then return end
local ch = math.min(pLayout.AbsoluteContentSize.Y + 4, 110)
pScroll.Size = UDim2.fromOffset(ADM_W - 6, ch)
ADM.Size = UDim2.fromOffset(ADM_W, 22 + ch + 3)
end
pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resADM)
admMin.MouseButton1Click:Connect(function()
admFolded = not admFolded
admMin.Text = admFolded and "+" or "-"
pScroll.Visible = not admFolded
if admFolded then
TweenService:Create(ADM, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(ADM_W, 24)}):Play()
else
local ch = math.min(pLayout.AbsoluteContentSize.Y + 4, 110)
TweenService:Create(ADM, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(ADM_W, 22 + ch + 3)}):Play()
end
end)
local pCards = {}
local function refreshPlayers()
for _, c in pairs(pCards) do pcall(function() c:Destroy() end) end
pCards = {}
cmdBtnRefs = {}
for _, p in ipairs(Players:GetPlayers()) do
if p == lp then continue end
local card = Instance.new("Frame", pScroll)
card.Name = p.Name
card.Size = UDim2.new(1, -4, 0, 26)
card.BackgroundColor3 = C.surf
card.BackgroundTransparency = 0.1
card.BorderSizePixel = 0
co(card, 4)
local cs = Instance.new("UIStroke", card)
cs.Thickness = 1
cs.Color = C.white
cs.Transparency = 0.6
cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local cz = Instance.new("TextButton", card)
cz.Size = UDim2.fromOffset(CSTART, 26)
cz.BackgroundTransparency = 1
cz.Text = ""
cz.AutoButtonColor = false
local ava = Instance.new("ImageLabel", card)
ava.Size = UDim2.fromOffset(16, 16)
ava.Position = UDim2.new(0, 3, 0.5, -8)
ava.BackgroundColor3 = C.surf2
ava.BorderSizePixel = 0
co(ava, 9)
task.spawn(function()
local ok, img = pcall(Players.GetUserThumbnailAsync, Players, p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
if ok then ava.Image = img end
end)
lb(card, {Position=UDim2.new(0,21,0,2), Size=UDim2.fromOffset(CSTART-23,12), Text=p.DisplayName, TextSize=8, Font=Enum.Font.GothamBold, TextColor3=C.white, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd})
lb(card, {Position=UDim2.new(0,21,0,14), Size=UDim2.fromOffset(CSTART-23,10), Text="@"..p.Name, TextSize=6, Font=Enum.Font.Gotham, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd})
cmdBtnRefs[p.UserId] = {}
for i, def in ipairs(RCMDS) do
local bx = CSTART + 2 + (i - 1) * (IW2 + IG2)
local ib = Instance.new("TextButton", card)
ib.Size = UDim2.fromOffset(IW2, IH2)
ib.Position = UDim2.new(0, bx, 0.5, -IH2 / 2)
ib.BackgroundColor3 = C.surf2
ib.BackgroundTransparency = 0.1
ib.Text = def.icon
ib.TextSize = 10
ib.TextColor3 = C.white
ib.Font = Enum.Font.GothamBold
ib.BorderSizePixel = 0
ib.AutoButtonColor = false
co(ib, 3)
local is = Instance.new("UIStroke", ib)
is.Thickness = 1
is.Color = C.white
is.Transparency = 0.6
is.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
cmdBtnRefs[p.UserId][def.cmd] = ib
local pd = p
local dc = def.cmd
ib.MouseButton1Click:Connect(function() fireCmd(pd, dc) end)
end
local pd = p
cz.MouseButton1Click:Connect(function()
for _, c2 in pairs(pCards) do
local s2 = c2:FindFirstChildOfClass("UIStroke")
if s2 then s2.Transparency = 0.6 end
c2.BackgroundTransparency = 0.1
end
cs.Transparency = 0.1
card.BackgroundTransparency = 0.05
fireClick(pd)
end)
pCards[p.UserId] = card
end
task.defer(resADM)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshPlayers() end)
task.delay(2, refreshPlayers)
-- Base Protector
local BP_W = 112
local BP_H = 22 + 42 + 6
local BP_defX = 4
local BP_defY = math.floor(vp.Y * 0.72)
local BP, _, bpMin = mkP(BP_defX, BP_defY, BP_W, BP_H, "BASE", "pos_BP")
local bpC = Instance.new("Frame", BP)
bpC.Size = UDim2.new(1, 0, 0, 42 + 6)
bpC.Position = UDim2.fromOffset(0, 24)
bpC.BackgroundTransparency = 1
bpC.BorderSizePixel = 0
local bpFolded = false
bpMin.MouseButton1Click:Connect(function()
bpFolded = not bpFolded
bpMin.Text = bpFolded and "+" or "-"
TweenService:Create(BP, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(BP_W, bpFolded and 24 or BP_H)}):Play()
end)
local asB, asSet = mkPill(bpC, "Anti Steal", 4, C.white)
asB.MouseButton1Click:Connect(function() antiSteal = not antiSteal; asSet(antiSteal) end)
local akB, akSet = mkPill(bpC, "Auto Kick", 25, C.red)
akB.MouseButton1Click:Connect(function() autoKickBase = not autoKickBase; akSet(autoKickBase) end)
-- Reset panels
rsPnlBtn.MouseButton1Click:Connect(function()
local popup = Instance.new("Frame", SG)
popup.Size = UDim2.fromOffset(186, 60)
popup.Position = UDim2.new(0.5, -93, 0.38, -30)
popup.BackgroundColor3 = C.bg
popup.BackgroundTransparency = 0.1
popup.BorderSizePixel = 0
co(popup, 9)
addAnimBorder(popup)
lb(popup, {Size=UDim2.new(1,0,0,26), Position=UDim2.fromOffset(0,5), Text="Reset panels?", TextSize=9, Font=Enum.Font.GothamBold, TextColor3=C.white})
local yB = mkBtn(popup, "Yes", UDim2.fromOffset(78, 22), UDim2.fromOffset(10, 34), Color3.fromRGB(5, 22, 10), C.grn)
local nB = mkBtn(popup, "No", UDim2.fromOffset(78, 22), UDim2.fromOffset(98, 34), Color3.fromRGB(22, 5, 8), C.red)
nB.MouseButton1Click:Connect(function() popup:Destroy() end)
yB.MouseButton1Click:Connect(function()
local defs = {
pos_FP = {ox=FP_defX, oy=FP_defY},
pos_AP = {ox=AP_defX, oy=AP_defY},
pos_ADM = {ox=ADM_defX, oy=ADM_defY},
pos_BP = {ox=BP_defX, oy=BP_defY}
}
for k, v in pairs(defs) do Cfg[k] = v end
save()
FP.Position = UDim2.fromOffset(FP_defX, FP_defY)
AP.Position = UDim2.fromOffset(AP_defX, AP_defY)
ADM.Position = UDim2.fromOffset(ADM_defX, ADM_defY)
BP.Position = UDim2.fromOffset(BP_defX, BP_defY)
popup:Destroy()
end)
end)
print("Aethen Hub v0.2 loaded | r9qbx")
