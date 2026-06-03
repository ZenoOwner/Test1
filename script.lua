local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local VirtualInputManager = Instance.new("VirtualInputManager")
local __AG_stealCbCache      = {}
local __AG_stealActive       = false
local __AG_MIN_HOLD_TIME     = 1.3
local __AG_TRIGGER_DELAY     = 0.05

local AutoBlockEnabled = false

local AntiRagdoll = { connections = {}, running = false }

AntiRagdoll.forceBackpack = function()
    if not AntiRagdoll.running then return end
    local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local backpackGui = gui:FindFirstChild("BackpackGui")
    if not backpackGui then return end
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then return end
    backpack.Visible = true
    if not backpack:FindFirstChild("ForceConnection") then
        local tag = Instance.new("BoolValue")
        tag.Name   = "ForceConnection"
        tag.Parent = backpack
        backpack:GetPropertyChangedSignal("Visible"):Connect(function()
            if not AntiRagdoll.running then return end
            if not backpack.Visible then backpack.Visible = true end
        end)
    end
end

AntiRagdoll.removeRagdollConstraints = function(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")
            or d:IsA("NoCollisionConstraint")
            or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
            d:Destroy()
        end
    end
end

AntiRagdoll.resetCharacter = function(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Anchored = false
        rootPart.Velocity  = Vector3.zero
    end
    if humanoid then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then
                obj.Enabled = true
            end
        end
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid.PlatformStand = false
        humanoid.Sit           = false
        if humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        workspace.CurrentCamera.CameraSubject = humanoid
    end
end

AntiRagdoll.onCharacterAdded_AR = function(char)
    char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    AntiRagdoll.connections.charDescAdded = char.DescendantAdded:Connect(function(obj)
        if not AntiRagdoll.running then return end
        if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint")
            or obj:IsA("NoCollisionConstraint")
            or (obj:IsA("Attachment") and obj.Name:find("RagdollAttachment")) then
            task.defer(function()
                if not AntiRagdoll.running then return end
                if obj.Parent then obj:Destroy() end
            end)
        end
    end)
    AntiRagdoll.connections.platformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if not AntiRagdoll.running then return end
        if humanoid.PlatformStand then
            task.defer(function()
                if not AntiRagdoll.running then return end
                AntiRagdoll.resetCharacter(char)
                AntiRagdoll.removeRagdollConstraints(char)
            end)
        end
    end)
    AntiRagdoll.removeRagdollConstraints(char)
    AntiRagdoll.resetCharacter(char)
end

AntiRagdoll.enable = function()
    if AntiRagdoll.running then return end
    AntiRagdoll.running = true
    AntiRagdoll.connections.heartbeat = RunService.Heartbeat:Connect(function()
        local char = Players.LocalPlayer.Character
        if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        local ragdolled = (s == Enum.HumanoidStateType.Physics
            or s == Enum.HumanoidStateType.Ragdoll
            or s == Enum.HumanoidStateType.FallingDown)
        local endTime = Players.LocalPlayer:GetAttribute("RagdollEndTime")
        if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
            ragdolled = true
        end
        if ragdolled then
            pcall(function() Players.LocalPlayer:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
            AntiRagdoll.removeRagdollConstraints(char)
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then
                    obj.Enabled = true
                end
            end
            if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            workspace.CurrentCamera.CameraSubject = hum
            root.Anchored = false
            root.Velocity  = Vector3.zero
        end
    end)
    AntiRagdoll.connections.charAdded = Players.LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        AntiRagdoll.forceBackpack()
        AntiRagdoll.onCharacterAdded_AR(char)
    end)
    if Players.LocalPlayer.Character then AntiRagdoll.onCharacterAdded_AR(Players.LocalPlayer.Character) end
    task.spawn(function()
        while AntiRagdoll.running do
            task.wait(0.5)
            AntiRagdoll.forceBackpack()
        end
    end)
end

AntiRagdoll.disable = function()
    AntiRagdoll.running = false
    for _, conn in pairs(AntiRagdoll.connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    AntiRagdoll.connections = {}
    pcall(function()
        local char = Players.LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end)
end

local function drawClickDot(x, y)
    if not Drawing then return end
    local dot = Drawing.new("Circle")
    dot.Radius   = 5
    dot.Position = Vector2.new(x, y)
    dot.Color    = Color3.fromRGB(255, 80, 80)
    dot.Filled   = true
    dot.Visible  = true
    dot.Transparency = 0.6
    task.delay(0.25, function() dot:Remove() end)
end

local function getPlotOwnerPlayer()
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
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and (p.Name == ownerName or p.DisplayName == ownerName) then
            return p
        end
    end
    return nil
end

local function getNearestPlayer()
    local lp  = Players.LocalPlayer
    local chr = lp and lp.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c = p.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if h then
                local dist = (h.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest     = p
                end
            end
        end
    end
    return nearest
end

local function blockPlayer(targetPlayer)
    if not targetPlayer then return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer", targetPlayer) end)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local x  = math.floor(vp.X / 2) + math.random(-1, 1)
    local y  = math.floor(vp.Y / 2 + 50) + math.random(-1, 1)

    -- Connect a blocker on every equipped tool's Activated so the click doesn't fire it
    local lp      = Players.LocalPlayer
    local chr     = lp and lp.Character
    local blockers = {}
    if chr then
        for _, t in ipairs(chr:GetChildren()) do
            if t:IsA("Tool") then
                -- block is a flag; the connection returns early while block is true
                local blocked = true
                local conn = t.Activated:Connect(function()
                    if blocked then return end
                end)
                table.insert(blockers, { conn = conn, setUnblocked = function() blocked = false end })
            end
        end
    end

    task.wait(0.04 + math.random() * 0.02)
    drawClickDot(x, y)
    pcall(function() VirtualInputManager:SendMouseButtonEvent(x, y, 0, true,  game, 1) end)
    task.wait(0.008 + math.random() * 0.008)
    pcall(function() VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1) end)

    -- Unblock and clean up after the click is done
    task.delay(0.05, function()
        for _, b in ipairs(blockers) do
            b.setUnblocked()
            pcall(function() b.conn:Disconnect() end)
        end
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
        if target then
            pcall(blockPlayer, target)
        end
    end)
end

-- Fires block so the kick lands on the server exactly when you arrive.
-- dist  = studs to travel, speed = studs/sec
-- Higher ping â†’ fires sooner | Lower ping â†’ fires later
local function triggerTimedBlock(dist, speed)
    if not AutoBlockEnabled then return end
    local ping = 0
    pcall(function() ping = Players.LocalPlayer:GetNetworkPing() or 0 end)
    local travelTime = dist / math.max(speed, 1)
    -- Fire slightly earlier than arrival: subtract ping + an extra half-ping to
    -- account for server-side processing latency so the block lands right as you arrive.
    local preDelay   = math.max(0, travelTime - ping * 1.5)
    task.delay(preDelay, function()
        if not AutoBlockEnabled then return end
        local target = getPlotOwnerPlayer() or getNearestPlayer()
        if target then pcall(blockPlayer, target) end
    end)
end

local function __AG_buildStealCallbacks(prompt)
    if __AG_stealCbCache[prompt] then return __AG_stealCbCache[prompt] end
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
    __AG_stealCbCache[prompt] = data
    return data
end

local function __AG_startStealHold(prompt)
    if not prompt or not prompt.Parent then return nil end
    local cb = __AG_buildStealCallbacks(prompt)
    if not cb then return nil end
    __AG_stealActive = true

    for _, fn in ipairs(cb.hold) do task.spawn(fn) end
    return {
        cb             = cb,
        ragdollFireTime = tick(),
        holdBeganAt    = tick(),
        holdDone       = false,
    }
end

local function __AG_doHoldAndWait(ctx)
    if ctx.holdDone then return end
    for _, fn in ipairs(ctx.cb.hold) do task.spawn(fn) end
    ctx.holdBeganAt = tick()
    task.wait(__AG_MIN_HOLD_TIME)
    ctx.holdDone = true
end

local function __AG_finishStealHold(ctx)
    if not ctx then return false end
    if not ctx.holdBeganAt then __AG_doHoldAndWait(ctx) end
    local held = tick() - (ctx.holdBeganAt or tick())
    if held < __AG_MIN_HOLD_TIME then task.wait(__AG_MIN_HOLD_TIME - held) end
    task.wait(__AG_TRIGGER_DELAY)
    for _, fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
    __AG_stealActive = false
    return true
end

local function __AG_findTargetPrompt()
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

    local base   = podium:FindFirstChild("Base")
    local spawn  = base  and base:FindFirstChild("Spawn")
    local pa     = spawn and spawn:FindFirstChild("PromptAttachment")
    local prompt = pa    and pa:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        prompt.RequiresLineOfSight   = false
        prompt.MaxActivationDistance = math.huge
    end
    return prompt
end

local T, F, M, S
local Tween, Corner, Stroke, Padding, Label
local GUI, WIN_W, WIN_H
local Win
local Hdr, HdrFill, HdrLine, Dot, TitleLbl, VerLbl
local TabBar, TBLine, TabLayout, ContentArea
local CreateToggle, CreateSection, CreateButton, MakeScroll
local Tabs, ActiveTab, TabSwiping, TabIndex
local SLIDE_IN, SLIDE_OUT, ActivateTab, CreateTab
local ShowToggleNotification
local Banner
local setUIVisible
local _uiVisible = true

local Config = { toggles = {}, keybinds = {}, mini = {}, fastPanelPos = nil }
local configRegistry = {}
local keybindEntries = {}
local keybindBindingTarget = nil

local CONFIG_PATH = "FadedFlash_config.json"

local function FH_SerializeConfig()
    local function encodeValue(v)
        local t = type(v)
        if t == "boolean" then return v and "true" or "false"
        elseif t == "number" then return tostring(v)
        elseif t == "string" then return '"' .. v:gsub('\\','\\\\'):gsub('"','\\"') .. '"'
        elseif t == "table" then
            local parts = {}
            for k, val in pairs(v) do
                parts[#parts+1] = '"' .. tostring(k) .. '":' .. encodeValue(val)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
        return "null"
    end
    return encodeValue({ toggles = Config.toggles, keybinds = Config.keybinds, mini = Config.mini, fastPanelPos = Config.fastPanelPos })
end

local function FH_ParseConfig(str)
    local pos = 1
    local function skipWS() while pos <= #str and str:sub(pos,pos):match("%s") do pos = pos + 1 end end
    local parseValue
    local function parseString()
        pos = pos + 1
        local s = ""
        while pos <= #str do
            local c = str:sub(pos,pos)
            if c == '"' then pos = pos + 1; return s end
            if c == '\\' then
                pos = pos + 1
                local e = str:sub(pos,pos)
                s = s .. (e == '"' and '"' or e == '\\' and '\\' or e == 'n' and '\n' or e)
            else s = s .. c end
            pos = pos + 1
        end
        return s
    end
    local function parseObject()
        pos = pos + 1
        local t = {}
        skipWS()
        if str:sub(pos,pos) == "}" then pos = pos + 1; return t end
        while true do
            skipWS(); local key = parseString(); skipWS(); pos = pos + 1; skipWS()
            t[key] = parseValue(); skipWS()
            if str:sub(pos,pos) == "}" then pos = pos + 1; return t end
            pos = pos + 1
        end
    end
    parseValue = function()
        skipWS(); local c = str:sub(pos,pos)
        if c == '"' then return parseString()
        elseif c == '{' then return parseObject()
        elseif c == 't' then pos = pos + 4; return true
        elseif c == 'f' then pos = pos + 5; return false
        elseif c == 'n' then pos = pos + 4; return nil
        else local num = str:match("^-?%d+%.?%d*", pos); if num then pos = pos + #num; return tonumber(num) end end
    end
    local ok, result = pcall(parseValue)
    return (ok and type(result) == "table") and result or nil
end

local function FH_SaveConfig()
    pcall(writefile, CONFIG_PATH, FH_SerializeConfig())
end

local function FH_LoadConfig()
    local ok, data = pcall(function() return FH_ParseConfig(readfile(CONFIG_PATH)) end)
    if ok and type(data) == "table" then
        if type(data.toggles)  == "table" then Config.toggles  = data.toggles  end
        if type(data.keybinds) == "table" then Config.keybinds = data.keybinds  end
        if type(data.mini)     == "table" then Config.mini     = data.mini      end
        if type(data.fastPanelPos) == "table" then Config.fastPanelPos = data.fastPanelPos end
    end
end

local function FH_ApplyLoadedKeybinds()
    for name, kcName in pairs(Config.keybinds) do
        if configRegistry[name] and configRegistry[name].setKeyCode then
            local ok2, kc = pcall(function() return Enum.KeyCode[kcName] end)
            if ok2 and kc then configRegistry[name].setKeyCode(kc) end
        end
    end
end

FH_LoadConfig()

T = {
    BG          = Color3.fromRGB(18,  18,  18),
    Header      = Color3.fromRGB(8,   8,   8),
    Card        = Color3.fromRGB(24,  24,  24),
    CardHover   = Color3.fromRGB(32,  32,  32),
    Border      = Color3.fromRGB(45,  45,  45),
    BorderHover = Color3.fromRGB(70,  70,  70),
    White       = Color3.fromRGB(245, 245, 245),
    Dim         = Color3.fromRGB(110, 110, 110),
    TabActive   = Color3.fromRGB(245, 245, 245),
    TabInact    = Color3.fromRGB(75,  75,  75),
    TrackOn     = Color3.fromRGB(240, 240, 240),
    TrackOff    = Color3.fromRGB(45,  45,  45),
    KnobOn      = Color3.fromRGB(10,  10,  10),
    KnobOff     = Color3.fromRGB(160, 160, 160),
}
F = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
M = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
S = TweenInfo.new(0.5,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)
Tween = function(o, i, p) TweenService:Create(o, i, p):Play() end
Corner = function(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end
Stroke = function(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color           = col or T.Border
    s.Thickness       = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end
Padding = function(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    u.Parent = p
end
Label = function(p, txt, sz, col, font)
    local l = Instance.new("TextLabel")
    l.Text              = txt or ""
    l.TextSize          = sz or 13
    l.TextColor3        = col or T.White
    l.Font              = font or Enum.Font.GothamMedium
    l.BackgroundTransparency = 1
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.Parent            = p
    return l
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

pcall(function()
    if game.CoreGui:FindFirstChild("FadedFlash") then
        game.CoreGui.FadedFlash:Destroy()
    end
end)

GUI = Instance.new("ScreenGui")
GUI.Name           = "FadedFlash"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn   = false
GUI.IgnoreGuiInset = true
if not pcall(function() GUI.Parent = game.CoreGui end) then
    GUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

do
    local _activeNotifs = {}
    local NOTIF_W, NOTIF_H, NOTIF_GAP, NOTIF_PAD_X, NOTIF_PAD_Y, NOTIF_DUR = 200, 44, 6, 14, 14, 2
    local function _shadowTargetY(slotIdx)
        return -(NOTIF_PAD_Y + NOTIF_H + 4 + slotIdx * (NOTIF_H + NOTIF_GAP))
    end
    local function _repoAll(tweenInfo)
        for i, e in ipairs(_activeNotifs) do
            TweenService:Create(e.shadow, tweenInfo, {
                Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(i - 1))
            }):Play()
        end
    end
    ShowToggleNotification = function(toggleName, enabled)
        local statusTxt = enabled and "Enabled" or "Disabled"
        local statusCol = enabled and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 100, 100)
        local IN_INFO   = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local OUT_INFO  = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local BAR_INFO  = TweenInfo.new(NOTIF_DUR, Enum.EasingStyle.Linear)
        local FADE_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
        local REPO_INFO = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local shadow = Instance.new("Frame")
        shadow.Name                   = "ToastShadow"
        shadow.Size                   = UDim2.new(0, NOTIF_W + 8, 0, NOTIF_H + 8)
        shadow.Position               = UDim2.new(0, -(NOTIF_W + 32), 1, _shadowTargetY(0))
        shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        shadow.BackgroundTransparency = 0.12
        shadow.BorderSizePixel        = 0
        shadow.ZIndex                 = 99
        shadow.Parent                 = GUI
        Corner(shadow, 12)
        local toast = Instance.new("Frame")
        toast.Name                   = "ToastNotif"
        toast.Size                   = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
        toast.Position               = UDim2.new(0, 4, 0, 4)
        toast.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
        toast.BackgroundTransparency = 1
        toast.BorderSizePixel        = 0
        toast.ZIndex                 = 100
        toast.Parent                 = shadow
        Corner(toast, 10)
        local _stroke = Stroke(toast, Color3.fromRGB(55, 55, 55), 1); _stroke.Transparency = 1
        local pill = Instance.new("Frame")
        pill.Size                   = UDim2.new(0, 3, 0, NOTIF_H - 16)
        pill.Position               = UDim2.new(0, 9, 0.5, -(NOTIF_H - 16) / 2)
        pill.BackgroundColor3       = T.White
        pill.BorderSizePixel        = 0
        pill.ZIndex                 = 101
        pill.Parent                 = toast
        Corner(pill, 2)
        local nameLabel = Label(toast, toggleName, 11, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
        nameLabel.Size = UDim2.new(1, -24, 0, 15); nameLabel.Position = UDim2.new(0, 19, 0, 7)
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd; nameLabel.TextTransparency = 1; nameLabel.ZIndex = 101
        local statusLabel = Label(toast, statusTxt, 10, statusCol, Enum.Font.Gotham)
        statusLabel.Size = UDim2.new(1, -24, 0, 11); statusLabel.Position = UDim2.new(0, 19, 0, 23)
        statusLabel.TextTransparency = 1; statusLabel.ZIndex = 101
        local barTrack = Instance.new("Frame")
        barTrack.Size = UDim2.new(1, 0, 0, 2); barTrack.Position = UDim2.new(0, 0, 1, -2)
        barTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35); barTrack.BorderSizePixel = 0
        barTrack.ZIndex = 101; barTrack.Parent = toast
        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(1, 0, 1, 0); barFill.BackgroundColor3 = T.White
        barFill.BorderSizePixel = 0; barFill.ZIndex = 102; barFill.Parent = barTrack
        local entry = { shadow = shadow }
        table.insert(_activeNotifs, 1, entry)
        _repoAll(REPO_INFO)
        TweenService:Create(shadow, IN_INFO, {Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(0))}):Play()
        TweenService:Create(toast,       IN_INFO, {BackgroundTransparency = 0}):Play()
        TweenService:Create(_stroke,     IN_INFO, {Transparency = 0.3}):Play()
        TweenService:Create(nameLabel,   IN_INFO, {TextTransparency = 0}):Play()
        TweenService:Create(statusLabel, IN_INFO, {TextTransparency = 0}):Play()
        task.delay(0.1, function() TweenService:Create(barFill, BAR_INFO, {Size = UDim2.new(0, 0, 1, 0)}):Play() end)
        task.delay(NOTIF_DUR + 0.15, function()
            for i, e in ipairs(_activeNotifs) do if e == entry then table.remove(_activeNotifs, i); break end end
            _repoAll(REPO_INFO)
            local exitY = shadow.Position.Y.Offset
            TweenService:Create(shadow, OUT_INFO, {Position = UDim2.new(0, -(NOTIF_W + 32), 1, exitY)}):Play()
            TweenService:Create(toast,       FADE_INFO, {BackgroundTransparency = 1}):Play()
            TweenService:Create(nameLabel,   FADE_INFO, {TextTransparency = 1}):Play()
            local tw = TweenService:Create(statusLabel, FADE_INFO, {TextTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function() shadow:Destroy() end)
        end)
    end
end

WIN_W = isMobile and 140 or 310
WIN_H = isMobile and 200 or 400

Win = Instance.new("Frame")
Win.Name             = "Win"
Win.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
Win.AnchorPoint      = Vector2.new(0.5, 0.5)
Win.Position         = UDim2.new(0.5, 0, 0.5, 0)
Win.BackgroundColor3 = T.BG
Win.BackgroundTransparency = 0.35
Win.BorderSizePixel  = 0
Win.ZIndex           = 2
Win.Parent           = GUI
Corner(Win, 12)
local WinStroke = Instance.new("UIStroke")
WinStroke.Thickness       = 1.6
WinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
WinStroke.Color           = Color3.fromRGB(255, 255, 255)
WinStroke.Parent          = Win
local BorderGrad = Instance.new("UIGradient")
BorderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(120, 120, 120)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(120, 120, 120)),
})
BorderGrad.Rotation = 0
BorderGrad.Parent   = WinStroke
local winScale = Instance.new("UIScale")
winScale.Scale  = 1
winScale.Parent = Win

Hdr = Instance.new("Frame")
Hdr.Size             = UDim2.new(1, 0, 0, 40)
Hdr.BackgroundColor3 = T.Header
Hdr.BackgroundTransparency = 0.2
Hdr.BorderSizePixel  = 0
Hdr.ZIndex           = 5
Hdr.Parent           = Win
Corner(Hdr, 12)
Hdr.Active = true
HdrFill = Instance.new("Frame")
HdrFill.Size             = UDim2.new(1, 0, 0, 8)
HdrFill.Position         = UDim2.new(0, 0, 1, -8)
HdrFill.BackgroundColor3 = T.Header
HdrFill.BackgroundTransparency = 0.2
HdrFill.BorderSizePixel  = 0
HdrFill.ZIndex           = 5
HdrFill.Parent           = Hdr
HdrLine = Instance.new("Frame")
HdrLine.Size             = UDim2.new(1, 0, 0, 1)
HdrLine.Position         = UDim2.new(0, 0, 1, -1)
HdrLine.BackgroundColor3 = T.Border
HdrLine.BorderSizePixel  = 0
HdrLine.ZIndex           = 6
HdrLine.Parent           = Hdr
Dot = Instance.new("Frame")
Dot.Size             = UDim2.new(0, 7, 0, 7)
Dot.Position         = UDim2.new(0, 16, 0.5, -3)
Dot.BackgroundColor3 = T.White
Dot.BorderSizePixel  = 0
Dot.ZIndex           = 6
Dot.Parent           = Hdr
Corner(Dot, 4)
TitleLbl = Label(Hdr, "", 14, T.White, Enum.Font.GothamBold)
TitleLbl.RichText = true
TitleLbl.Text     = '<font color="rgb(245,245,245)">Faded</font> <font color="rgb(255,255,255)">Flash</font>'
TitleLbl.Size     = UDim2.new(0, 180, 0, 20)
TitleLbl.Position = UDim2.new(0, 30, 0.5, -10)
TitleLbl.ZIndex   = 6
VerLbl = Label(Hdr, "v1.0", 10, T.Dim, Enum.Font.Gotham)
VerLbl.Size     = UDim2.new(0, 40, 0, 14)
VerLbl.Position = UDim2.new(0, 30, 0.5, 8)
VerLbl.ZIndex   = 6

_G._FH_GUI_LOCKED = false
do
    local HBTN_H   = isMobile and 18 or 22
    local HBTN_GAP = isMobile and 4 or 6
    local PADX     = isMobile and 7 or 10

    local HdrBtns = Instance.new("Frame")
    HdrBtns.Name                   = "HdrButtons"
    HdrBtns.AnchorPoint            = Vector2.new(1, 0.5)
    HdrBtns.Position               = UDim2.new(1, -10, 0.5, 0)
    HdrBtns.Size                   = UDim2.new(0, 0, 0, HBTN_H)
    HdrBtns.AutomaticSize          = Enum.AutomaticSize.X
    HdrBtns.BackgroundTransparency = 1
    HdrBtns.ZIndex                 = 7
    HdrBtns.Parent                 = Hdr
    local hl = Instance.new("UIListLayout")
    hl.FillDirection     = Enum.FillDirection.Horizontal
    hl.VerticalAlignment = Enum.VerticalAlignment.Center
    hl.SortOrder         = Enum.SortOrder.LayoutOrder
    hl.Padding           = UDim.new(0, HBTN_GAP)
    hl.Parent            = HdrBtns

    local function styleBtn(text, order)
        local btn = Instance.new("TextButton")
        btn.Name             = "Hdr_" .. text
        btn.AutomaticSize    = Enum.AutomaticSize.X
        btn.Size             = UDim2.new(0, 0, 0, HBTN_H)
        btn.LayoutOrder      = order
        btn.BackgroundColor3 = T.Card
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        btn.Text             = text
        btn.TextSize         = isMobile and 8 or 10
        btn.Font             = Enum.Font.GothamBold
        btn.TextColor3       = T.White
        btn.ZIndex           = 8
        btn.Active           = true
        btn.Parent           = HdrBtns
        Corner(btn, 6)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft  = UDim.new(0, PADX)
        pad.PaddingRight = UDim.new(0, PADX)
        pad.Parent       = btn
        local s = Stroke(btn, T.Border, 1)
        return btn, s
    end

    do
        local lockBtn, lockStroke = styleBtn("FREE", 1)
        lockBtn.MouseEnter:Connect(function()
            if not _G._FH_GUI_LOCKED then
                Tween(lockBtn, F, {BackgroundColor3 = T.CardHover}); Tween(lockStroke, F, {Color = T.BorderHover})
            end
        end)
        lockBtn.MouseLeave:Connect(function()
            if not _G._FH_GUI_LOCKED then
                Tween(lockBtn, F, {BackgroundColor3 = T.Card}); Tween(lockStroke, F, {Color = T.Border})
            end
        end)
        lockBtn.MouseButton1Click:Connect(function()
            _G._FH_GUI_LOCKED = not _G._FH_GUI_LOCKED
            if _G._FH_GUI_LOCKED then
                lockBtn.Text = "LOCK"
                lockBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
                lockStroke.Color = Color3.fromRGB(200, 60, 60)
            else
                lockBtn.Text = "FREE"
                lockBtn.BackgroundColor3 = T.Card
                lockStroke.Color = T.Border
            end
        end)
    end

    local hdrBinds      = {}
    local hdrBindTarget = nil
    local function makeActionBtn(label, order, onClick)
        local btn, s = styleBtn(label, order)

        local configKey = "hdr_" .. label
        local entry  = { keyCode = nil, label = label, configKey = configKey }
        local _busy  = false
        local function refresh()
            if hdrBindTarget == entry then
                btn.Text = label .. " (...)"
            elseif entry.keyCode then
                btn.Text = label .. " (" .. entry.keyCode.Name .. ")"
            else
                btn.Text = label
            end
        end
        local function fire()
            _busy = true
            btn.BackgroundColor3 = T.White
            btn.TextColor3       = Color3.fromRGB(15, 15, 15)
            Tween(s, F, {Color = T.White})
            task.delay(0.16, function()
                Tween(btn, M, {BackgroundColor3 = T.Card})
                Tween(s,   M, {Color = T.Border})
                btn.TextColor3 = T.White
                _busy = false
            end)
            if onClick then task.spawn(function() pcall(onClick) end) end
        end
        btn.MouseEnter:Connect(function()
            if _busy then return end
            Tween(btn, F, {BackgroundColor3 = T.CardHover}); Tween(s, F, {Color = T.BorderHover})
        end)
        btn.MouseLeave:Connect(function()
            if _busy then return end
            Tween(btn, F, {BackgroundColor3 = T.Card}); Tween(s, F, {Color = T.Border})
        end)
        btn.MouseButton1Click:Connect(fire)
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
            if hdrBindTarget and hdrBindTarget ~= entry then
                local prev = hdrBindTarget; hdrBindTarget = nil; prev.refresh()
            end
            if hdrBindTarget == entry then hdrBindTarget = nil else hdrBindTarget = entry end
            refresh()
        end)
        entry.refresh = refresh
        entry.fire    = fire

        local savedKcName = Config.keybinds[configKey]
        if savedKcName then
            local ok2, kc = pcall(function() return Enum.KeyCode[savedKcName] end)
            if ok2 and kc then
                entry.keyCode = kc
                refresh()
            end
        end
        table.insert(hdrBinds, entry)
        return entry
    end

    _G._FH_ResetBtnEntry = makeActionBtn("RESET", 2, function()
        local LocalPlayer = Players.LocalPlayer
        local Net = ReplicatedStorage:WaitForChild("Packages", 2) and ReplicatedStorage.Packages:WaitForChild("Net", 2)
        if not Net then
            local char = LocalPlayer and LocalPlayer.Character
            local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
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
            local char = LocalPlayer and LocalPlayer.Character
            local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.Health = 0 end
            return
        end

        local savedTools = {}
        local char = LocalPlayer.Character
        local bp   = LocalPlayer:FindFirstChild("Backpack")

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

        LocalPlayer.Character = nil
        local sending = true
        local loopConnection
        local fire = remote.FireServer
        local _respawnThrottle = 0

        loopConnection = RunService.Heartbeat:Connect(function(dt)
            if not sending then
                if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
                return
            end
            _respawnThrottle = _respawnThrottle + dt
            if _respawnThrottle >= 0.1 then
                _respawnThrottle = 0
                pcall(fire, remote, "f888ee6e-c86d-46e1-93d7-0639d6635d42", LocalPlayer, "balloon")
            end
            if sending and LocalPlayer.Character then LocalPlayer.Character = nil end
        end)

        local conn
        conn = LocalPlayer.CharacterAdded:Connect(function()
            sending = false
            if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
            if conn then conn:Disconnect() end
            task.spawn(function()
                local newBp = LocalPlayer:WaitForChild("Backpack", 3)
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
            local curBp = LocalPlayer:FindFirstChild("Backpack")
            if curBp and #savedTools > 0 then
                for _, t in ipairs(savedTools) do
                    if t then t.Parent = curBp end
                end
                savedTools = {}
            end
        end)
    end)
    _G._FH_FlashBtnEntry = makeActionBtn("FLASH", 3, function()
        local lp  = Players.LocalPlayer
        local chr = lp and lp.Character
        local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local PODIUM_CFRAMES = {
            [1] = {
                [1] = {
                    hrp = CFrame.new(Vector3.new(-347.6983, -7.5033, -4.5494)),
                    cam = CFrame.new(-357.0927, 0.0048, -0.272)
                        * CFrame.Angles(-0.954463, -0.903625, -0.837019),
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
            pcall(ShowToggleNotification, "Flash: base not detected", false)
            return
        end

        local targetBase = (myBase == 1) and 2 or 1

        local podiumCFs = PODIUM_CFRAMES[targetBase]
        if not podiumCFs then return end

        local selected = _G._FH_SelectedBrainrot
        if not selected then
            pcall(ShowToggleNotification, "Flash: select an animal first", false)
            return
        end

        local slot = tonumber(selected.slot)
        if not slot then
            pcall(ShowToggleNotification, "Flash: selected animal has no slot", false)
            return
        end

        local entry = podiumCFs[slot]
        if not entry or not entry.cam then
            pcall(ShowToggleNotification, "Flash: podium " .. tostring(slot) .. " not configured yet", false)
            return
        end

        task.spawn(function()
            local currentSpeed = entry.hrpFloat and 800 or 210
            local ARRIVE_DIST  = 4
            local TIMEOUT      = 8

            local player    = Players.LocalPlayer
            local targetPos = (entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position

            local function findTool(kw)
                local c = player.Character
                local b = player:FindFirstChild("Backpack")
                if c then
                    for _, t in ipairs(c:GetChildren()) do
                        if t:IsA("Tool") and t.Name:lower():find(kw) then return t end
                    end
                end
                if b then
                    for _, t in ipairs(b:GetChildren()) do
                        if t:IsA("Tool") and t.Name:lower():find(kw) then return t end
                    end
                end
            end

            local function doEquip(tool, timeout)
                local c = player.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if not (c and h) then return end
                if tool.Parent == c then return end
                local done = false
                local cn
                cn = tool.Equipped:Connect(function()
                    done = true
                    cn:Disconnect()
                end)
                pcall(function() h:EquipTool(tool) end)
                local dl = tick() + (timeout or 1)
                while not done and tick() < dl do task.wait() end
                if cn then pcall(function() cn:Disconnect() end) end
            end

            local carpet = findTool("carpet")
            if carpet then doEquip(carpet, 1) end

            local stealCtx     = nil
            local _lateGrabSlots = {[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,
                                     [19]=true,[20]=true,[21]=true,[22]=true,[23]=true}
            if not _lateGrabSlots[slot] then
                task.spawn(function()
                    local lp2  = Players.LocalPlayer
                    local chr3 = lp2 and lp2.Character
                    local hrp3 = chr3 and chr3:FindFirstChild("HumanoidRootPart")
                    local dest = (entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
                    local dist = hrp3 and (hrp3.Position - dest).Magnitude or 0

                    -- Time from NOW until steal fires:
                    --   travel + 0.10 + 0.15 + 0.07 unequip + 0.30 equip + 0.12 steal delay
                    -- Start hold exactly 1.3s before that moment.
                    local POST_ARRIVAL = 0.10 + 0.15 + 0.07 + 0.30 + 0.12
                    local travelTime   = dist / math.max(currentSpeed, 1)
                    local timeUntilFire = travelTime + POST_ARRIVAL
                    local preDelay     = math.max(0, timeUntilFire - __AG_MIN_HOLD_TIME)
                    if preDelay > 0 then task.wait(preDelay) end
                    local targetPrompt = __AG_findTargetPrompt()
                    if targetPrompt then
                        stealCtx = __AG_startStealHold(targetPrompt)
                    end
                end)
            end

            local boostConn
            if boostConn then boostConn:Disconnect() end
            boostConn = RunService.Heartbeat:Connect(function()
                if not player.Character then return end
                local hrp      = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if not hrp or not humanoid then return end
                local diff = targetPos - hrp.Position
                if entry.hrpFloat then

                    if diff.Magnitude > ARRIVE_DIST then
                        local dir = diff.Unit
                        hrp.Velocity = Vector3.new(
                            dir.X * currentSpeed,
                            dir.Y * currentSpeed,
                            dir.Z * currentSpeed
                        )
                    else
                        hrp.Velocity = Vector3.zero
                    end
                else

                    local flat = Vector3.new(diff.X, 0, diff.Z)
                    if flat.Magnitude > ARRIVE_DIST then
                        local flatDir = flat.Unit
                        hrp.Velocity = Vector3.new(
                            flatDir.X * currentSpeed,
                            hrp.Velocity.Y,
                            flatDir.Z * currentSpeed
                        )
                    else
                        -- Within arrival radius â€” kill lateral velocity immediately
                        -- so we don't slide past the target
                        hrp.Velocity = Vector3.new(
                            0, hrp.Velocity.Y, 0)
                    end
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
                hum2       = chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if not (hrp2 and hum2) then break end
                local _now = tick()
                if _now - _lastMoveTo >= 0.1 then
                    hum2:MoveTo(targetPos)
                    _lastMoveTo = _now
                end
                if (hrp2.Position - targetPos).Magnitude < ARRIVE_DIST then break end
            until tick() > deadline

            -- Stop velocity boost BEFORE zeroing so the Heartbeat can't re-apply
            if boostConn then boostConn:Disconnect(); boostConn = nil end
            do
                local _chr = player.Character
                local _hrpS = _chr and _chr:FindFirstChild("HumanoidRootPart")
                local _humS = _chr and _chr:FindFirstChildOfClass("Humanoid")
                if _hrpS and _humS then
                    _humS:MoveTo(_hrpS.Position)   -- cancel MoveTo momentum
                    _hrpS.Velocity = Vector3.zero
                    _hrpS.Anchored = true
                    task.defer(function()
                        task.defer(function()
                            local _c2 = player.Character
                            local _h2 = _c2 and _c2:FindFirstChild("HumanoidRootPart")
                            if _h2 then
                                _h2.Velocity = Vector3.zero
                                _h2.Anchored = false
                            end
                        end)
                    end)
                end
            end

            -- For lateGrabSlots: start hold right after phase-1 stops so timing
            -- is based on the true remaining distance to the final podium position.
            if _lateGrabSlots[slot] then
                task.spawn(function()
                    local _chr3   = player.Character
                    local _hrp3   = _chr3 and _chr3:FindFirstChild("HumanoidRootPart")
                    local _finalP = entry.hrp.Position
                    local _d2     = _hrp3 and (_hrp3.Position - _finalP).Magnitude or 0
                    -- POST_ARRIVAL: time from final-phase arrival to steal trigger fire
                    local _POST2  = 0.10 + 0.15 + 0.07 + 0.30 + 0.12
                    local _pre2   = math.max(0, (_d2 / math.max(currentSpeed, 1)) + _POST2 - __AG_MIN_HOLD_TIME)
                    if _pre2 > 0 then task.wait(_pre2) end
                    local _tp = __AG_findTargetPrompt()
                    if _tp then stealCtx = __AG_startStealHold(_tp) end
                end)
            end

            if entry.hrpWalk then
                local finalPos = entry.hrp.Position

                local boostConn2
                boostConn2 = RunService.Heartbeat:Connect(function()
                    if not player.Character then return end
                    local hrp3      = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid3 = player.Character:FindFirstChildOfClass("Humanoid")
                    if not hrp3 or not humanoid3 then return end
                    local diff3 = finalPos - hrp3.Position
                    local flat3 = Vector3.new(diff3.X, 0, diff3.Z)
                    if flat3.Magnitude > ARRIVE_DIST then
                        local flatDir3 = flat3.Unit
                        hrp3.Velocity = Vector3.new(
                            flatDir3.X * currentSpeed,
                            hrp3.Velocity.Y,
                            flatDir3.Z * currentSpeed
                        )
                    else
                        hrp3.Velocity = Vector3.new(
                            0, hrp3.Velocity.Y, 0)
                    end
                end)
                chr2 = player.Character
                hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if hum2 then hum2:MoveTo(finalPos) end
                local deadline2 = tick() + TIMEOUT
                local _lastMoveTo2 = 0
                repeat
                    task.wait()
                    chr2 = player.Character
                    local hrp2b = chr2 and chr2:FindFirstChild("HumanoidRootPart")
                    hum2        = chr2 and chr2:FindFirstChildOfClass("Humanoid")
                    if not (hrp2b and hum2) then break end
                    local _now2 = tick()
                    if _now2 - _lastMoveTo2 >= 0.1 then
                        hum2:MoveTo(finalPos)
                        _lastMoveTo2 = _now2
                    end
                    if (hrp2b.Position - finalPos).Magnitude < ARRIVE_DIST then break end
                until tick() > deadline2
                boostConn2:Disconnect()
                boostConn2 = nil

                chr2 = player.Character
                hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
                local hrpStop = chr2 and chr2:FindFirstChild("HumanoidRootPart")
                if hrpStop and hum2 then
                    -- Snap directly to target so there is zero sliding on arrival
                    hrpStop.CFrame   = entry.hrp
                    hrpStop.Velocity = Vector3.zero
                    hrpStop.Anchored = true
                    task.defer(function()
                        task.defer(function()
                            local _c = player.Character
                            local _h = _c and _c:FindFirstChild("HumanoidRootPart")
                            if _h then
                                _h.Velocity = Vector3.zero
                                _h.Anchored = false
                            end
                        end)
                    end)
                end
            else
                chr2 = player.Character
                hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
                local hrpStop = chr2 and chr2:FindFirstChild("HumanoidRootPart")
                if hrpStop and hum2 then
                    -- Snap directly to target so there is zero sliding on arrival
                    hrpStop.CFrame   = entry.hrp
                    hrpStop.Velocity = Vector3.zero
                    hrpStop.Anchored = true
                    task.defer(function()
                        task.defer(function()
                            local _c = player.Character
                            local _h = _c and _c:FindFirstChild("HumanoidRootPart")
                            if _h then
                                _h.Velocity = Vector3.zero
                                _h.Anchored = false
                            end
                        end)
                    end)
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

            if (slot == 19 or slot == 20 or slot == 21 or slot == 22 or slot == 23 or slot == 24 or slot == 25 or slot == 26 or slot == 27) and hum2 then
                hum2:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            chr2 = player.Character
            hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if not (chr2 and hum2) then return end

            local flashTool = nil
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool = t; break end
                end
            end
            if not flashTool then
                for _, t in ipairs(chr2:GetChildren()) do
                    if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool = t; break end
                end
            end

            if not flashTool then
                pcall(ShowToggleNotification, "Flash: tool not found in inventory", false)
                return
            end

            -- Force unequip any currently held tool first
            pcall(function() hum2:UnequipTools() end)
            task.wait(0.07)

            -- Wait for flash tool to actually be equipped before activating
            local _flashEquipped = false
            local _flashEquipConn
            _flashEquipConn = flashTool.Equipped:Connect(function()
                _flashEquipped = true
                _flashEquipConn:Disconnect()
                _flashEquipConn = nil
            end)
            flashTool.Parent = chr2
            pcall(function() hum2:EquipTool(flashTool) end)
            local _eqDeadline = tick() + 1
            while not _flashEquipped and tick() < _eqDeadline do task.wait() end
            if _flashEquipConn then pcall(function() _flashEquipConn:Disconnect() end); _flashEquipConn = nil end

            local flashFired = false
            local flashConn
            flashConn = flashTool.Activated:Connect(function()
                flashFired = true
                if flashConn then flashConn:Disconnect(); flashConn = nil end
            end)

            pcall(function() flashTool:Activate() end)

            task.spawn(function()
                task.wait(0.08)
                if not RagdollBypassEnabled then
                    if stealCtx then
                        triggerAutoBlock()
                        __AG_finishStealHold(stealCtx)
                    elseif type(_G._sv2DoSteal) == "function" then
                        triggerAutoBlock()
                        pcall(_G._sv2DoSteal)
                    end
                end
            end)

            task.wait(0.02)
            pcall(function() flashTool:Activate() end)

            task.wait(0.08)
            if flashConn then pcall(function() flashConn:Disconnect() end); flashConn = nil end

            if hum2 then pcall(function() hum2:UnequipTools() end) end
            task.wait(0.05)
            local bp2 = player:FindFirstChild("Backpack")
            if bp2 and flashTool and flashTool.Parent ~= bp2 then
                flashTool.Parent = bp2
            end

            -- 1) Potion fires first
            local lp   = Players.LocalPlayer
            local char = lp and lp.Character
            local bp   = lp and lp:FindFirstChild("Backpack")
            if char and bp then
                local potion = bp:FindFirstChild("Body Swap Potion")
                if potion then
                    pcall(function()
                        potion.Parent = char
                        potion:Activate()
                        potion.Parent = bp
                    end)
                end
            end

            -- 2) Ragdoll fires a little after potion
            if RagdollBypassEnabled then
                task.spawn(function()
                    task.wait(0.10)
                    local _ragdollCommandCache = {}
                    local _ragdollProfileCache = {}
                    local function _ragdollCacheActivated(guiObject)
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
                    local function _ragdollFireActivated(cached)
                        for _, fn in ipairs(cached) do task.spawn(fn) end
                    end
                    local function _ragdollGetAdminFrames()
                        local ap = Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
                        if not ap then return nil, nil end
                        local panel = ap:FindFirstChild("AdminPanel")
                        if not panel then return nil, nil end
                        local content  = panel:FindFirstChild("Content")
                        local profiles = panel:FindFirstChild("Profiles")
                        if not content or not profiles then return nil, nil end
                        return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
                    end
                    local commandFrame2, profileFrame2 = _ragdollGetAdminFrames()
                    if not commandFrame2 or not profileFrame2 then return end
                    local pName2 = Players.LocalPlayer.Name
                    local profileBtn2 = profileFrame2:FindFirstChild(pName2)
                    local ragdollBtn2 = commandFrame2:FindFirstChild("ragdoll")
                    if not profileBtn2 or not ragdollBtn2 then return end
                    if not _ragdollProfileCache[pName2] then
                        _ragdollProfileCache[pName2] = _ragdollCacheActivated(profileBtn2)
                    end
                    if not _ragdollCommandCache["ragdoll"] then
                        _ragdollCommandCache["ragdoll"] = _ragdollCacheActivated(ragdollBtn2)
                    end
                    _ragdollFireActivated(_ragdollCommandCache["ragdoll"])
                    task.wait()
                    _ragdollFireActivated(_ragdollProfileCache[pName2])
                    -- Pre-block: fire block NOW so its built-in network delay (~0.09s + ping) eats up
                    -- the time waiting for the kick signal. By the time steal lands server-side, block is live.
                    triggerAutoBlock()
                    -- Fire steal the instant the target is kicked (state â†’ Ragdoll/Physics/FallingDown
                    -- or PlatformStand flips true). Falls back to 0.35s if we can't detect the signal.
                    local _kicked     = false
                    local _kickConn1, _kickConn2
                    local _tgtPlayer  = getPlotOwnerPlayer()
                    local _tgtChar    = _tgtPlayer and _tgtPlayer.Character
                    local _tgtHum     = _tgtChar and _tgtChar:FindFirstChildOfClass("Humanoid")
                    local function _onKicked()
                        if _kicked then return end
                        _kicked = true
                        if _kickConn1 then pcall(function() _kickConn1:Disconnect() end); _kickConn1 = nil end
                        if _kickConn2 then pcall(function() _kickConn2:Disconnect() end); _kickConn2 = nil end
                        -- stealCtx is built in a concurrent spawn; wait up to 3 frames for it to land
                        local _wf = 0
                        while not stealCtx and _wf < 3 do task.wait(); _wf = _wf + 1 end
                        -- Still nil? Build a fresh context from the live prompt right now
                        if not stealCtx then
                            local _fp = __AG_findTargetPrompt()
                            if _fp then stealCtx = __AG_startStealHold(_fp) end
                        end
                        if stealCtx then
                            __AG_finishStealHold(stealCtx)
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
                    -- Safety fallback: fire steal after 0.35s even if kick signal never arrives
                    task.delay(0.35, function()
                        if not _kicked then _onKicked() end
                    end)
                end)
            end

            local carpetAfter = findTool("carpet")
            if carpetAfter then doEquip(carpetAfter, 1) end

            if slot == 19 or slot == 20 or slot == 21 or slot == 22 or slot == 23 or slot == 24 or slot == 25 or slot == 26 or slot == 27 then task.wait(0.2) end
            chr2 = player.Character
            hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if chr2 and hum2 then
                local potionTool = nil
                local bp3 = player:FindFirstChild("Backpack")
                if bp3 then
                    for _, t in ipairs(bp3:GetChildren()) do
                        if t:IsA("Tool") and t.Name:lower():find("potion") then potionTool = t; break end
                    end
                end
                if not potionTool then
                    for _, t in ipairs(chr2:GetChildren()) do
                        if t:IsA("Tool") and t.Name:lower():find("potion") then potionTool = t; break end
                    end
                end
                if potionTool and RagdollBypassEnabled then
                    potionTool.Parent = chr2
                    pcall(function() hum2:EquipTool(potionTool) end)
                    task.wait(0.05)
                    pcall(function() potionTool:Activate() end)
                    task.wait(0.05)
                    pcall(function() potionTool:Activate() end)

                    task.wait(0.1)
                    if hum2 then pcall(function() hum2:UnequipTools() end) end
                    task.wait(0.05)
                    local bp4 = player:FindFirstChild("Backpack")
                    if bp4 and potionTool and potionTool.Parent ~= bp4 then
                        potionTool.Parent = bp4
                    end
                end

                local carpetFinal = findTool("carpet")
                if carpetFinal then doEquip(carpetFinal, 1) end
            end
        end)

        pcall(ShowToggleNotification, "Flash â†’ Base " .. targetBase .. " Podium " .. slot, true)
    end)


    _G._FH_BlockBtnEntry = makeActionBtn("BLOCK", 4, function()
        local target = getNearestPlayer()
        if target then
            pcall(blockPlayer, target)
            pcall(ShowToggleNotification, "Blocked: " .. target.Name, true)
        else
            pcall(ShowToggleNotification, "Block: no players nearby", false)
        end
    end)

        UserInputService.InputBegan:Connect(function(inp, gpe)
        if hdrBindTarget then
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                local t  = hdrBindTarget
                local kc = inp.KeyCode
                hdrBindTarget = nil
                if kc == Enum.KeyCode.Escape then
                    t.refresh()
                elseif kc == Enum.KeyCode.Backspace then
                    t.keyCode = nil
                    Config.keybinds[t.configKey] = nil
                    pcall(FH_SaveConfig)
                    t.refresh()
                else
                    t.keyCode = kc
                    Config.keybinds[t.configKey] = kc.Name
                    pcall(FH_SaveConfig)
                    t.refresh()
                end
            elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local t = hdrBindTarget; hdrBindTarget = nil; t.refresh()
            end
            return
        end
        if gpe then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            for _, e in ipairs(hdrBinds) do
                if e.keyCode and inp.KeyCode == e.keyCode then e.fire() end
            end
        end
    end)
end

do
    local dragging, dragStart, winStart, _dragMoved
    Hdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            _dragMoved = false
            dragStart  = inp.Position
            winStart   = Win.Position
        end
    end)
    Hdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging   = false
            _dragMoved = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = inp.Position - dragStart
            if not _dragMoved and d.Magnitude < 6 then return end
            _dragMoved = true
            local newPos = UDim2.new(
                winStart.X.Scale, winStart.X.Offset + d.X,
                winStart.Y.Scale, winStart.Y.Offset + d.Y
            )
            Win.Position = newPos
        end
    end)
end

TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1, 0, 0, 34)
TabBar.Position         = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
TabBar.BackgroundTransparency = 0.2
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 4
TabBar.Parent           = Win
TBLine = Instance.new("Frame")
TBLine.Size             = UDim2.new(1, 0, 0, 1)
TBLine.Position         = UDim2.new(0, 0, 0, 73)
TBLine.BackgroundColor3 = T.Border
TBLine.BorderSizePixel  = 0
TBLine.ZIndex           = 5
TBLine.Parent           = Win
TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection       = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
TabLayout.Padding             = UDim.new(0, 0)
TabLayout.Parent              = TabBar
local TabSizeConstraint = Instance.new("UISizeConstraint")
TabSizeConstraint.MaxSize = Vector2.new(WIN_W, 34)
TabSizeConstraint.Parent  = TabBar
ContentArea = Instance.new("Frame")
ContentArea.Size                = UDim2.new(1, 0, 1, -74)
ContentArea.Position            = UDim2.new(0, 0, 0, 74)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants    = true
ContentArea.ZIndex              = 2
ContentArea.Parent              = Win

CreateToggle = function(parent, name, desc, cb)
    local state  = (Config.toggles[name] == true)
    local hasDesc = desc and desc ~= ""
    local cardH  = hasDesc and 56 or 44
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, -16, 0, cardH)
    card.BackgroundColor3 = T.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel  = 0
    card.Parent           = parent
    Corner(card, 8)
    local cStroke = Stroke(card, T.Border, 1)
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 0, cardH - 16)
    bar.Position         = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3 = T.TrackOff
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 2
    bar.Parent           = card
    Corner(bar, 2)
    local nameY  = hasDesc and 10 or (cardH/2 - 8)
    local nameLbl = Label(card, name, isMobile and 11 or 13, T.White, Enum.Font.GothamMedium)
    nameLbl.Size     = UDim2.new(1, -108, 0, 16)
    nameLbl.Position = UDim2.new(0, 14, 0, nameY)
    nameLbl.ZIndex   = 2
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    if hasDesc then
        local descLbl = Label(card, desc, isMobile and 9 or 11, T.Dim, Enum.Font.Gotham)
        descLbl.Size     = UDim2.new(1, -108, 0, 14)
        descLbl.Position = UDim2.new(0, 14, 0, nameY + 18)
        descLbl.ZIndex   = 2
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local kbLbl = Instance.new("TextLabel")
    kbLbl.Size              = UDim2.new(0, 32, 0, 16)
    kbLbl.Position          = UDim2.new(1, -92, 0.5, -8)
    kbLbl.BackgroundTransparency = 1
    kbLbl.Text              = ""
    kbLbl.TextSize          = 10
    kbLbl.Font              = Enum.Font.GothamBold
    kbLbl.TextColor3        = T.Dim
    kbLbl.TextXAlignment    = Enum.TextXAlignment.Center
    kbLbl.ZIndex            = 3
    kbLbl.Parent            = card
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 40, 0, 22)
    track.Position         = UDim2.new(1, -52, 0.5, -11)
    track.BackgroundColor3 = T.TrackOff
    track.BorderSizePixel  = 0
    track.ZIndex           = 2
    track.Parent           = card
    Corner(track, 11)
    local tStroke = Stroke(track, T.Border, 1)
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 16, 0, 16)
    knob.Position         = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = T.KnobOff
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 3
    knob.Parent           = track
    Corner(knob, 8)
    card.MouseEnter:Connect(function()
        Tween(card,    F, {BackgroundColor3 = T.CardHover})
        Tween(cStroke, F, {Color = T.BorderHover})
    end)
    card.MouseLeave:Connect(function()
        Tween(card,    F, {BackgroundColor3 = T.Card})
        Tween(cStroke, F, {Color = T.Border})
    end)
    local btn = Instance.new("Frame")
    btn.Size                = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.ZIndex              = 4
    btn.Active              = true
    btn.Parent              = card
    local keybindEntry = { keyCode = nil }
    local function applyVisual(s)
        if s then
            knob.Size             = UDim2.new(0, 16, 0, 16)
            knob.Position         = UDim2.new(0, 21, 0.5, -8)
            knob.BackgroundColor3 = T.KnobOn
            track.BackgroundColor3 = T.TrackOn
            tStroke.Color         = T.TrackOn
            bar.BackgroundColor3  = T.White
        else
            knob.Size             = UDim2.new(0, 16, 0, 16)
            knob.Position         = UDim2.new(0, 3, 0.5, -8)
            knob.BackgroundColor3 = T.KnobOff
            track.BackgroundColor3 = T.TrackOff
            tStroke.Color         = T.Border
            bar.BackgroundColor3  = T.TrackOff
        end
    end
    local function doToggle()
        state = not state
        if state then
            Tween(knob, TweenInfo.new(0.06), {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 4, 0.5, -7)})
            task.delay(0.06, function()
                Tween(knob,    M, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 21, 0.5, -8)})
                Tween(knob,    M, {BackgroundColor3 = T.KnobOn})
                Tween(track,   M, {BackgroundColor3 = T.TrackOn})
                Tween(tStroke, M, {Color = T.TrackOn})
                Tween(bar,     M, {BackgroundColor3 = T.White})
            end)
        else
            Tween(knob, TweenInfo.new(0.06), {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 20, 0.5, -7)})
            task.delay(0.06, function()
                Tween(knob,    M, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, -8)})
                Tween(knob,    M, {BackgroundColor3 = T.KnobOff})
                Tween(track,   M, {BackgroundColor3 = T.TrackOff})
                Tween(tStroke, M, {Color = T.Border})
                Tween(bar,     M, {BackgroundColor3 = T.TrackOff})
            end)
        end
        if cb then pcall(cb, state) end
        Config.toggles[name] = state
        pcall(FH_SaveConfig)
        pcall(ShowToggleNotification, name, state)
    end
    local _btnTouchActive = false
    local _btnTouchStart  = nil
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _btnTouchActive = true
            _btnTouchStart  = inp.Position
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch) and _btnTouchActive then
            _btnTouchActive = false
            if _btnTouchStart and (inp.Position - _btnTouchStart).Magnitude < 20 then
                doToggle()
            end
            _btnTouchStart = nil
        end
    end)
    local kb2Debounce = false
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if kb2Debounce then return end
        kb2Debounce = true
        task.delay(0.2, function() kb2Debounce = false end)
        if keybindBindingTarget then
            local prev = keybindBindingTarget
            keybindBindingTarget = nil
            if prev.kbLbl == kbLbl then
                kbLbl.Text      = keybindEntry.keyCode and ("[".. keybindEntry.keyCode.Name .. "]") or ""
                kbLbl.TextColor3 = T.Dim
                return
            else
                prev.kbLbl.Text      = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
                prev.kbLbl.TextColor3 = T.Dim
            end
        end
        kbLbl.Text           = "(...)"
        kbLbl.TextColor3     = T.White
        keybindBindingTarget = { entry = keybindEntry, kbLbl = kbLbl, mode = "assign"}
    end)
    table.insert(keybindEntries, { entry = keybindEntry, fire = doToggle })
    configRegistry[name] = {
        getState   = function() return state end,
        getKeyCode = function() return keybindEntry.keyCode end,
        setKeyCode = function(kc)
            keybindEntry.keyCode = kc
            if kc then
                kbLbl.Text       = "[".. kc.Name .. "]"
                kbLbl.TextColor3 = T.Dim
                Config.keybinds[name] = kc.Name
            else
                kbLbl.Text = ""
                Config.keybinds[name] = nil
            end
            pcall(FH_SaveConfig)
        end,
        doToggle   = doToggle,
        setEnabled = function(v)
            state = v
            applyVisual(v)
            Config.toggles[name] = v
            pcall(FH_SaveConfig)
            if cb then pcall(cb, v) end
        end,
    }
    if state then
        applyVisual(true)

        task.spawn(function() pcall(cb, true) end)
    end
end

UserInputService.InputBegan:Connect(function(inp, gpe)
    if keybindBindingTarget then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local kc = inp.KeyCode
            if kc == Enum.KeyCode.Escape then
                local _tgt = keybindBindingTarget
                if _tgt.entry.keyCode then
                    _tgt.kbLbl.Text      = "[".. _tgt.entry.keyCode.Name .. "]"
                    _tgt.kbLbl.TextColor3 = T.Dim
                else
                    _tgt.kbLbl.Text = ""
                end
                keybindBindingTarget = nil
            elseif kc == Enum.KeyCode.Backspace then
                local _tgt = keybindBindingTarget
                _tgt.entry.keyCode    = nil
                _tgt.kbLbl.Text       = ""
                _tgt.kbLbl.TextColor3 = T.Dim
                for tName, reg in pairs(configRegistry) do
                    if reg.getKeyCode and reg.getKeyCode() == nil then
                        Config.keybinds[tName] = nil
                    end
                end
                pcall(FH_SaveConfig)
                keybindBindingTarget = nil
            else
                local _tgt = keybindBindingTarget
                _tgt.entry.keyCode    = kc
                _tgt.kbLbl.Text       = "[".. kc.Name .. "]"
                _tgt.kbLbl.TextColor3 = T.Dim
                local matched = 0
                for tName, reg in pairs(configRegistry) do
                    local sameEntry = false
                    if reg.getKeyCode then
                        local ok, regKc = pcall(reg.getKeyCode)
                        if ok and regKc == kc then sameEntry = true end
                    end
                    if sameEntry then
                        Config.keybinds[tName] = kc.Name
                        if reg.setKeyCode then pcall(reg.setKeyCode, kc) end
                        matched = matched + 1
                    end
                end
                pcall(FH_SaveConfig)
                pcall(function()
                    ShowToggleNotification("Keybind ["..kc.Name.."] bound ("..matched..")", true)
                end)
                keybindBindingTarget = nil
            end
            return
        elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
            local prev = keybindBindingTarget
            keybindBindingTarget = nil
            if prev.entry.keyCode then
                prev.kbLbl.Text      = "[".. prev.entry.keyCode.Name .. "]"
                prev.kbLbl.TextColor3 = T.Dim
            else
                prev.kbLbl.Text = ""
            end
        end
        return
    end
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        for _, binding in ipairs(keybindEntries) do
            if binding.entry.keyCode and inp.KeyCode == binding.entry.keyCode then
                binding.fire()
            end
        end
    end
end)

CreateSection = function(parent, title)
    local f = Instance.new("Frame")
    f.Size                = UDim2.new(1, -16, 0, 26)
    f.BackgroundTransparency = 1
    f.Parent              = parent
    local labelW = #title * 7 + 6
    local lbl = Label(f, title, 10, T.Dim, Enum.Font.GothamBold)
    lbl.Size             = UDim2.new(0, labelW, 1, 0)
    lbl.Position         = UDim2.new(0, 4, 0, 0)
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 2
    local line = Instance.new("Frame")
    line.Size             = UDim2.new(1, -(labelW + 14), 0, 1)
    line.Position         = UDim2.new(0, labelW + 10, 0.5, 0)
    line.BackgroundColor3 = T.Border
    line.BorderSizePixel  = 0
    line.Parent           = f
end

CreateButton = function(parent, name, desc, cb)
    local hasDesc = desc and desc ~= ""
    local cardH   = hasDesc and 56 or 44
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, -16, 0, cardH)
    card.BackgroundColor3 = T.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel  = 0
    card.Parent           = parent
    Corner(card, 8)
    local cStroke = Stroke(card, T.Border, 1)
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 0, cardH - 16)
    bar.Position         = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3 = T.TrackOff
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 2
    bar.Parent           = card
    Corner(bar, 2)
    local nameY  = hasDesc and 10 or (cardH/2 - 8)
    local nameLbl = Label(card, name, isMobile and 11 or 13, T.White, Enum.Font.GothamMedium)
    nameLbl.Size     = UDim2.new(1, -108, 0, 16)
    nameLbl.Position = UDim2.new(0, 14, 0, nameY)
    nameLbl.ZIndex   = 2
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    if hasDesc then
        local descLbl = Label(card, desc, isMobile and 9 or 11, T.Dim, Enum.Font.Gotham)
        descLbl.Size     = UDim2.new(1, -108, 0, 14)
        descLbl.Position = UDim2.new(0, 14, 0, nameY + 18)
        descLbl.ZIndex   = 2
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
    end

    local kbLbl = Instance.new("TextLabel")
    kbLbl.Size              = UDim2.new(0, 32, 0, 16)
    kbLbl.Position          = UDim2.new(1, -92, 0.5, -8)
    kbLbl.BackgroundTransparency = 1
    kbLbl.Text              = ""
    kbLbl.TextSize          = 10
    kbLbl.Font              = Enum.Font.GothamBold
    kbLbl.TextColor3        = T.Dim
    kbLbl.TextXAlignment    = Enum.TextXAlignment.Center
    kbLbl.ZIndex            = 3
    kbLbl.Parent            = card
    local runLbl = Instance.new("TextLabel")
    runLbl.Size                  = UDim2.new(0, 52, 0, 24)
    runLbl.Position              = UDim2.new(1, -60, 0.5, -12)
    runLbl.BackgroundColor3      = Color3.fromRGB(38, 38, 38)
    runLbl.BorderSizePixel       = 0
    runLbl.Text                  = "RUN"
    runLbl.TextSize              = 11
    runLbl.Font                  = Enum.Font.GothamBold
    runLbl.TextColor3            = T.White
    runLbl.TextXAlignment        = Enum.TextXAlignment.Center
    runLbl.ZIndex                = 3
    runLbl.Parent                = card
    Corner(runLbl, 7)
    local runStroke = Stroke(runLbl, T.Border, 1)
    card.MouseEnter:Connect(function()
        Tween(card,    F, {BackgroundColor3 = T.CardHover})
        Tween(cStroke, F, {Color = T.BorderHover})
        Tween(runLbl,  F, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)})
    end)
    card.MouseLeave:Connect(function()
        Tween(card,    F, {BackgroundColor3 = T.Card})
        Tween(cStroke, F, {Color = T.Border})
        Tween(runLbl,  F, {BackgroundColor3 = Color3.fromRGB(38, 38, 38)})
    end)
    local btn = Instance.new("Frame")
    btn.Size                = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.ZIndex              = 4
    btn.Active              = true
    btn.Parent              = card
    local keybindEntry = { keyCode = nil }
    local function fireButton()
        Tween(bar,       F, {BackgroundColor3 = T.White})
        Tween(runLbl,    F, {BackgroundColor3 = T.White})
        Tween(runStroke, F, {Color = T.White})
        runLbl.TextColor3 = Color3.fromRGB(20, 20, 20)
        task.spawn(function() pcall(cb) end)
        task.delay(0.35, function()
            Tween(bar,       M, {BackgroundColor3 = T.TrackOff})
            Tween(runLbl,    M, {BackgroundColor3 = Color3.fromRGB(38, 38, 38)})
            Tween(runStroke, M, {Color = T.Border})
            runLbl.TextColor3 = T.White
        end)
    end
    local debounce = false
    local _actTouchStart = nil
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if debounce then return end
            debounce = true
            fireButton()
            task.delay(0.4, function() debounce = false end)
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _actTouchStart = inp.Position
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _actTouchStart then
            local mag = (inp.Position - _actTouchStart).Magnitude
            _actTouchStart = nil
            if mag < 20 then
                if debounce then return end
                debounce = true
                fireButton()
                task.delay(0.4, function() debounce = false end)
            end
        end
    end)

    local kb2Debounce = false
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if kb2Debounce then return end
        kb2Debounce = true
        task.delay(0.2, function() kb2Debounce = false end)
        if keybindBindingTarget then
            local prev = keybindBindingTarget
            keybindBindingTarget = nil
            if prev.kbLbl == kbLbl then
                kbLbl.Text       = keybindEntry.keyCode and ("[" .. keybindEntry.keyCode.Name .. "]") or ""
                kbLbl.TextColor3 = T.Dim
                return
            else
                prev.kbLbl.Text      = prev.entry.keyCode and ("[" .. prev.entry.keyCode.Name .. "]") or ""
                prev.kbLbl.TextColor3 = T.Dim
            end
        end
        kbLbl.Text           = "(...)"
        kbLbl.TextColor3     = T.White
        keybindBindingTarget = { entry = keybindEntry, kbLbl = kbLbl, mode = "assign" }
    end)

    table.insert(keybindEntries, { entry = keybindEntry, fire = fireButton })

    configRegistry[name] = {
        getState   = function() return false end,
        getKeyCode = function() return keybindEntry.keyCode end,
        setKeyCode = function(kc)
            keybindEntry.keyCode = kc
            if kc then
                kbLbl.Text       = "[" .. kc.Name .. "]"
                kbLbl.TextColor3 = T.Dim
                Config.keybinds[name] = kc.Name
            else
                kbLbl.Text = ""
                Config.keybinds[name] = nil
            end
            pcall(FH_SaveConfig)
        end,
    }

    local savedKcName = Config.keybinds[name]
    if savedKcName then
        local ok2, kc = pcall(function() return Enum.KeyCode[savedKcName] end)
        if ok2 and kc then
            keybindEntry.keyCode = kc
            kbLbl.Text       = "[" .. kc.Name .. "]"
            kbLbl.TextColor3 = T.Dim
        end
    end
end

MakeScroll = function(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size                  = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel       = 0
    s.ScrollBarThickness    = 3
    s.ScrollBarImageColor3  = Color3.fromRGB(75, 75, 75)
    s.CanvasSize            = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    s.ScrollingDirection    = Enum.ScrollingDirection.Y
    s.ZIndex                = 2
    s.Parent                = parent
    local layout = Instance.new("UIListLayout")
    layout.FillDirection       = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding             = UDim.new(0, 6)
    layout.Parent              = s
    Padding(s, 10, 10, 8, 8)
    return s
end

Tabs      = {}
ActiveTab = nil
TabSwiping = false
TabIndex = function(tab)
    for i, t in ipairs(Tabs) do
        if t == tab then return i end
    end
    return 0
end
SLIDE_IN  = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
SLIDE_OUT = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
ActivateTab = function(tab)
    if ActiveTab == tab then return end
    if TabSwiping then return end
    local oldTab = ActiveTab
    ActiveTab = tab
    if oldTab then
        Tween(oldTab.lbl,       F, {TextColor3 = T.TabInact})
        Tween(oldTab.indicator, M, {Size = UDim2.new(0, 0, 0, 2)})
    end
    Tween(tab.lbl,       F, {TextColor3 = T.TabActive})
    Tween(tab.indicator, M, {Size = UDim2.new(0.8, 0, 0, 2)})
    if oldTab then
        TabSwiping = true
        local goingRight = (TabIndex(tab) > TabIndex(oldTab))
        tab.page.Position = goingRight and UDim2.new(1, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
        tab.page.Visible  = true
        local exitPos = goingRight and UDim2.new(-1, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
        Tween(oldTab.page, SLIDE_OUT, {Position = exitPos})
        local tw = TweenService:Create(tab.page, SLIDE_IN, {Position = UDim2.new(0, 0, 0, 0)})
        tw:Play()
        tw.Completed:Connect(function()
            oldTab.page.Visible  = false
            oldTab.page.Position = UDim2.new(0, 0, 0, 0)
            TabSwiping = false
        end)
    else
        tab.page.Position = UDim2.new(0, 0, 0, 0)
        tab.page.Visible  = true
    end
end

CreateTab = function(name)
    local btn = Instance.new("TextButton")
    btn.Size                = UDim2.new(0.5, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                = ""
    btn.ZIndex              = 5
    btn.Parent              = TabBar
    local nameLbl = Label(btn, name, isMobile and 9 or 11, T.TabInact, Enum.Font.GothamBold)
    nameLbl.Size            = UDim2.new(1, -2, 1, 0)
    nameLbl.Position        = UDim2.new(0, 1, 0, 0)
    nameLbl.TextXAlignment  = Enum.TextXAlignment.Center
    nameLbl.TextWrapped     = true
    nameLbl.ZIndex          = 6
    local nameSC = Instance.new("UITextSizeConstraint")
    nameSC.MaxTextSize = isMobile and 9 or 11
    nameSC.MinTextSize = 5
    nameSC.Parent      = nameLbl
    local indicator = Instance.new("Frame")
    indicator.Size             = UDim2.new(0, 0, 0, 2)
    indicator.Position         = UDim2.new(0.1, 0, 1, -2)
    indicator.BackgroundColor3 = T.White
    indicator.BorderSizePixel  = 0
    indicator.ZIndex           = 7
    indicator.Parent           = btn
    Corner(indicator, 1)
    local page = Instance.new("Frame")
    page.Size                = UDim2.new(1, 0, 1, 0)
    page.Position            = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible             = false
    page.ClipsDescendants    = true
    page.ZIndex              = 2
    page.Parent              = ContentArea
    local scroll = MakeScroll(page)
    local tab = { btn = btn, lbl = nameLbl, indicator = indicator, page = page, scroll = scroll }
    btn.MouseButton1Click:Connect(function() ActivateTab(tab) end)
    table.insert(Tabs, tab)
    return tab
end

local BrainrotsTab = CreateTab("ALL BRAINROTS")
local UtilsTab     = CreateTab("UTILS")

do
    local RSvc       = game:GetService("RunService")
    local RS         = game:GetService("ReplicatedStorage")
    local WS         = game:GetService("Workspace")

    local AnimalsData   = _G._FH_AG_AnimalsData
    local AnimalsShared = _G._FH_AG_AnimalsShared
    local NumberUtils   = _G._FH_AG_NumberUtils
    if not AnimalsData   then pcall(function() AnimalsData   = require(RS:WaitForChild("Datas",30):WaitForChild("Animals",30)) end) end
    if not NumberUtils   then pcall(function() NumberUtils   = require(RS:WaitForChild("Utils",30):WaitForChild("NumberUtils",30)) end) end
    if not AnimalsShared then pcall(function() AnimalsShared = require(RS:WaitForChild("Shared",30):WaitForChild("Animals",30)) end) end

    local RequestData   = _G._FH_AG_SyncRemotes and _G._FH_AG_SyncRemotes.requestData
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

        local lp = Players.LocalPlayer
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
                                name         = displayName(data.Index),
                                animalIndex  = data.Index,
                                mutation     = data.Mutation,
                                traits       = data.Traits,
                                genValue     = gen,
                                genText      = "$"..fmtNum(gen).."/s",
                                plotName     = plot.Name,
                                plotOrder    = getPlotOrder(plot),
                                owner        = owner,
                                slot         = tostring(slot),
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

    local function afGetTemplate(name)
        local ok,v = pcall(function() return RS.Models.Animals[name] end)
        return ok and v or nil
    end
    local function afGetAnimFolder(name)
        local ok,v = pcall(function() return RS.Animations.Animals[name] end)
        return ok and v or nil
    end

    local _sharedAnimals = nil
    local function GetSharedAnimals()
        if not _sharedAnimals then
            local ok, result = pcall(function() return require(RS.Shared.Animals) end)
            if ok then _sharedAnimals = result end
        end
        return _sharedAnimals
    end

    local BG_COL = Color3.fromRGB(12,12,14)
    local MUT_PALETTES = {
        Gold        = {Color3.fromRGB(237,178,0),   Color3.fromRGB(237,194,86), Color3.fromRGB(215,111,1),  Color3.fromRGB(139,74,0),   Color3.fromRGB(255,164,164), Color3.fromRGB(255,244,190)},
        Diamond     = {Color3.fromRGB(37,196,254),  Color3.fromRGB(116,212,254),Color3.fromRGB(28,137,254), Color3.fromRGB(21,64,254),   Color3.fromRGB(160,162,254), Color3.fromRGB(176,255,252)},
        Bloodrot    = {Color3.fromRGB(145,0,27),    Color3.fromRGB(154,94,100), Color3.fromRGB(75,0,7),     Color3.fromRGB(72,0,2),      Color3.fromRGB(121,112,112), Color3.fromRGB(255,152,154)},
        Candy       = {Color3.fromRGB(255,105,180), Color3.fromRGB(255,182,193),Color3.fromRGB(200,50,150), Color3.fromRGB(255,20,147),  Color3.fromRGB(255,200,220), Color3.fromRGB(255,240,245)},
        Lava        = {Color3.fromRGB(200,50,0),    Color3.fromRGB(255,100,0),  Color3.fromRGB(150,20,0),   Color3.fromRGB(100,10,0),    Color3.fromRGB(255,160,0),   Color3.fromRGB(255,220,100)},
        Galaxy      = {Color3.fromRGB(60,0,120),    Color3.fromRGB(100,0,180),  Color3.fromRGB(30,0,80),    Color3.fromRGB(180,0,255),   Color3.fromRGB(80,0,160),    Color3.fromRGB(200,150,255)},
        YinYang     = {BG_COL, Color3.fromRGB(20,20,28), Color3.fromRGB(230,230,240), Color3.fromRGB(230,230,240), Color3.fromRGB(128,128,128), Color3.fromRGB(24,24,30)},
        Radioactive = {Color3.fromRGB(100,255,0),   Color3.fromRGB(150,255,50), Color3.fromRGB(50,200,0),   Color3.fromRGB(0,150,0),     Color3.fromRGB(200,255,100), Color3.fromRGB(230,255,180)},
        Cursed      = {Color3.fromRGB(255,23,23),   Color3.fromRGB(180,0,0),    Color3.fromRGB(120,0,0),    Color3.fromRGB(80,0,0),      Color3.fromRGB(255,100,100), Color3.fromRGB(255,180,180)},
        Divine      = {Color3.fromRGB(255,215,0),   Color3.fromRGB(255,255,200),Color3.fromRGB(200,160,0),  Color3.fromRGB(255,240,150), BG_COL,                      Color3.fromRGB(255,250,220)},
    }

    local function ApplyMutation(model, animalName, mutName)
        if not mutName or mutName == "None" then return end

        local sa = GetSharedAnimals()
        if sa then
            local ok = pcall(function() sa:ApplyMutation(model, animalName, mutName) end)
            if ok then return end
        end

        local ok2, mutData = pcall(function() return require(RS.Datas.Mutations) end)
        local palette = MUT_PALETTES[mutName]
        if ok2 and mutData and mutData[mutName] and mutData[mutName].Palettes then
            palette = mutData[mutName].Palettes[1] or palette
        end

        if mutName == "Rainbow" then
            model:AddTag("RainbowModel")
            return
        end

        if palette then
            local mutSurface = pcall(function() return RS.MutationSurfaces:FindFirstChild(animalName) end)
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        local mv = v.MaterialVariant
                        if mv == "Strawberry Stud Light" or mv == "Strawberry Stud Dark" then
                            v.MaterialVariant = mutName.." Strawberry Stud Light"
                            return
                        end
                        local colorIdx = tonumber(
                            v:GetAttribute(mutName.."*Color") or
                            v:GetAttribute("Color") or 1) or 1
                        colorIdx = math.clamp(colorIdx, 1, #palette)
                        local col = palette[colorIdx] or palette[1]
                        if not col then return end
                        local surfApp = v:FindFirstChildOfClass("SurfaceAppearance")
                        if surfApp then surfApp:Destroy() end
                        v.Color = col
                        if v:GetAttribute("Neon") then v.Material = Enum.Material.Neon end
                    end)
                end
            end
        end

        if mutName == "Galaxy" then
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        if (v:GetAttribute("GalaxyColor") or v:GetAttribute("Color") or 1) == 1 then
                            v.Material = Enum.Material.Neon
                        end
                        v.MaterialVariant = "Galaxy Stud"
                    end)
                end
            end
        elseif mutName == "Lava" then
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        if (v:GetAttribute("LavaColor") or v:GetAttribute("Color") or 1) == 1 then
                            v.Material = Enum.Material.Neon
                        end
                    end)
                end
            end
        elseif mutName == "YinYang" then
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        local c = v:GetAttribute("YinYangColor") or v:GetAttribute("Color") or 1
                        if c == 3 or c == 4 then v.Material = Enum.Material.Neon end
                    end)
                end
            end
        elseif mutName == "Divine" then
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        local c = v:GetAttribute("DivineColor") or v:GetAttribute("Color") or 1
                        if c == 2 then v.Material = Enum.Material.Neon end
                        if v:GetAttribute("Divine*Stud") == false then
                            v.MaterialVariant = ""
                        elseif v.MaterialVariant == "Custom Stud" or v:GetAttribute("Divine*Stud") == true or (c ~= 2 and c ~= 6) then
                            v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Divine Stud"
                        end
                    end)
                end
            end
        elseif mutName == "Radioactive" then
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        local c = v:GetAttribute("RadioactiveColor") or v:GetAttribute("Color") or 1
                        if c == 2 then v.Material = Enum.Material.Neon end
                        if v:GetAttribute("Radioactive*Stud") == false then
                            v.MaterialVariant = ""
                        elseif v.MaterialVariant == "Custom Stud" or v:GetAttribute("Radioactive*Stud") == true or (c ~= 2 and c ~= 6) then
                            v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Radioactive Stud"
                        end
                    end)
                end
            end
        elseif mutName == "Cursed" then
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        local c = v:GetAttribute("CursedColor") or v:GetAttribute("Color") or 1
                        if c == 2 then v.Material = Enum.Material.Neon end
                        if v:GetAttribute("Cursed*Stud") == false then
                            v.MaterialVariant = ""
                        elseif v.MaterialVariant == "Custom Stud" or v:GetAttribute("Cursed*Stud") == true or (c ~= 2 and c ~= 6) then
                            v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Cursed Stud"
                            v.Color = Color3.fromRGB(255, 23, 23)
                        end
                        local sa2 = v:FindFirstChildOfClass("SurfaceAppearance")
                        if sa2 then
                            if not v:GetAttribute("Cursed*IgnoreSurfaceColor") then sa2.Color = Color3.fromRGB(255,23,23) end
                            if v:GetAttribute("IgnoreSurface") then sa2:Destroy() end
                        end
                    end)
                end
            end
        elseif mutName == "Cyber" then
            for _, v in ipairs(model:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 and not v:GetAttribute("IgnoreColor") then
                    pcall(function()
                        local c = tonumber(v:GetAttribute("Cyber*Color") or v:GetAttribute("Color") or 1) or 1
                        local surfApp = v:FindFirstChildOfClass("SurfaceAppearance")
                        if v:GetAttribute("Eyes") then
                            v.Color = Color3.fromRGB(62,155,255); v.Transparency = 0.25; v.Material = Enum.Material.Neon; return
                        end
                        if c == 7 then v.Material = Enum.Material.Neon
                        elseif c == 4 then
                            v.Transparency = 0.5; v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Tech Stud"; v.Color = Color3.fromRGB(62,155,255)
                        elseif c == 3 then
                            v.Material = Enum.Material.Glass; v.Transparency = 0.5
                            if not surfApp and v.ClassName == "MeshPart" then Instance.new("SurfaceAppearance").Parent = v end
                        elseif c == 1 then
                            v.Material = Enum.Material.Glass; v.Transparency = 0.25
                            if not surfApp and v.ClassName == "MeshPart" then Instance.new("SurfaceAppearance").Parent = v end
                        end
                        surfApp = v:FindFirstChildOfClass("SurfaceAppearance")
                        if surfApp then
                            local vol = v.Size.X * v.Size.Y * v.Size.Z
                            v.Transparency = 0; v.Material = Enum.Material.Neon
                            surfApp.AlphaMode = Enum.AlphaMode.Overlay
                            surfApp.EmissiveTint = Color3.fromRGB(255,255,255)
                            if vol > 3 then
                                surfApp.Color = Color3.fromRGB(35,75,115); surfApp.EmissiveStrength = 50
                            else
                                surfApp.Color = Color3.fromRGB(0,25,30); surfApp.EmissiveStrength = 25
                            end
                        end
                    end)
                end
            end
        end

        pcall(function()
            local vfxFolder = RS.Vfx:FindFirstChild(mutName)
            local vfxInst   = model:FindFirstChild("VfxInstance")
            if vfxFolder and vfxInst then
                for _, vfx in ipairs(vfxFolder:GetChildren()) do
                    pcall(function() vfx:Clone().Parent = vfxInst end)
                end
            end
        end)
    end

    local function AttachViaRigidConstraint(clone, model)
        for _, part in ipairs(clone:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Model") then
                for _, att in ipairs(part:GetDescendants()) do
                    if att:IsA("Attachment") then
                        local target = model:FindFirstChild(att.Name, true)
                        if target and target:IsA("Attachment") then
                            local rc = Instance.new("RigidConstraint")
                            rc.Attachment0 = att
                            rc.Attachment1 = target
                            rc.Parent = part
                        end
                    end
                end
            end
        end
    end

    local function ApplyTraits(model, animalName, traitList)
        if not traitList then return end

        local list = {}
        if typeof(traitList) == "table" then
            for k, v in pairs(traitList) do
                if type(k) == "number" then table.insert(list, tostring(v))
                else table.insert(list, tostring(k)) end
            end
        end
        if #list == 0 then return end

        local sa = GetSharedAnimals()
        if sa then
            local ok = pcall(function() sa:ApplyTraits(model, animalName, list) end)
            if ok then return end
        end

        local tap       = RS.Models:FindFirstChild("TraitsPerAnimal")
        local modTraits = RS.Models:FindFirstChild("Traits")
        local vfxTraits = RS.Vfx:FindFirstChild("Traits")
        local rootPart  = model.PrimaryPart or model:FindFirstChild("RootPart")

        for _, traitName in ipairs(list) do
            pcall(function()
                local applied = false

                if tap then
                    local traitFolder = tap:FindFirstChild(traitName)
                    local traitModel  = traitFolder and traitFolder:FindFirstChild(animalName)
                    if traitModel then
                        local clone = traitModel:Clone()
                        clone.Name = "_Trait."..traitName
                        AttachViaRigidConstraint(clone, model)
                        clone.Parent = model
                        applied = true
                    end
                end

                if not applied and modTraits then
                    local traitModel = modTraits:FindFirstChild(traitName)
                    if traitModel then
                        local clone = traitModel:Clone()
                        clone.Name = "_Trait."..traitName
                        AttachViaRigidConstraint(clone, model)
                        clone.Parent = model
                        applied = true
                    end
                end

                if not applied and vfxTraits and rootPart then
                    local vfxModel = vfxTraits:FindFirstChild(traitName)
                    if vfxModel then
                        local clone = vfxModel:Clone()
                        clone.Name = "_Trait."..traitName
                        local vfxPart = clone:FindFirstChild("VfxInstance")
                        if vfxPart then
                            local att       = vfxPart:FindFirstChildOfClass("Attachment")
                            local targetAtt = att and model:FindFirstChild(att.Name, true)
                            if targetAtt then
                                local rc = Instance.new("RigidConstraint")
                                rc.Attachment0 = att; rc.Attachment1 = targetAtt; rc.Parent = vfxPart
                            else
                                local weld = Instance.new("Weld")
                                weld.Part0 = rootPart; weld.Part1 = vfxPart
                                weld.C0 = CFrame.new(0,0,0); weld.Parent = vfxPart
                            end
                        end
                        clone.Parent = model
                    end
                end
            end)
        end
    end

    local TRAIT_ICONS = {
        ["Taco"]            = "rbxassetid://89041930759464",
        ["Nyan"]            = "rbxassetid://104229924295526",
        ["Galactic"]        = "rbxassetid://99181785766598",
        ["Fireworks"]       = "rbxassetid://121100427764858",
        ["Zombie"]          = "rbxassetid://110723387483939",
        ["Claws"]           = "rbxassetid://104964195846833",
        ["Glitched"]        = "rbxassetid://121332433272976",
        ["Bubblegum"]       = "rbxassetid://100601425541874",
        ["Fire"]            = "rbxassetid://118283346037788",
        ["Wet"]             = "rbxassetid://78474194088770",
        ["Snowy"]           = "rbxassetid://83627475909869",
        ["Cometstruck"]     = "rbxassetid://127455440418221",
        ["Explosive"]       = "rbxassetid://97725744252608",
        ["Disco"]           = "rbxassetid://82620342632406",
        ["10B"]             = "rbxassetid://134655415681926",
        ["Shark Fin"]       = "rbxassetid://104985313532149",
        ["Matteo Hat"]      = "rbxassetid://115664804212096",
        ["Brazil"]          = "rbxassetid://75650816341229",
        ["Sleepy"]          = "rbxassetid://115001117876534",
        ["Lightning"]       = "rbxassetid://139729696247144",
        ["UFO"]             = "rbxassetid://110910518481052",
        ["Spider"]          = "rbxassetid://117478971325696",
        ["Strawberry"]      = "rbxassetid://84731118566493",
        ["Paint"]           = "rbxassetid://119591742504251",
        ["Skeleton"]        = "rbxassetid://89591838221335",
        ["Sombrero"]        = "rbxassetid://95128039793845",
        ["Tie"]             = "rbxassetid://103610037004911",
        ["Witch Hat"]       = "rbxassetid://123964048606874",
        ["Indonesia"]       = "rbxassetid://93350414974589",
        ["Meowl"]           = "rbxassetid://114748221761549",
        ["RIP Gravestone"]  = "rbxassetid://123115843719383",
        ["Jackolantern Pet"]= "rbxassetid://97054765273857",
        ["Santa Hat"]       = "rbxassetid://88375043733582",
        ["Reindeer Pet"]    = "rbxassetid://70894779883038",
        ["Skibidi"]         = "rbxassetid://83384385019272",
        ["26"]              = "rbxassetid://80468035315420",
        ["Rose"]            = "rbxassetid://135489065859287",
        [":3"]              = "rbxassetid://108293878529172",
        ["Chocolate"]       = "rbxassetid://81641382604997",
        ["Halo"]            = "rbxassetid://98316436141359",
        ["Lucky"]           = "rbxassetid://124098467754457",
        ["Orange Balloon"]  = "rbxassetid://83111173051279",
        ["Green Balloon"]   = "rbxassetid://75222826429094",
        ["Blue Balloon"]    = "rbxassetid://128841931686463",
        ["Red Balloon"]     = "rbxassetid://119661964026012",
        ["Pink Balloon"]    = "rbxassetid://114128099162490",
        ["Rainbow Balloon"] = "rbxassetid://112821854659961",
        ["Granny"]          = "rbxassetid://73467619616299",
        ["Bunny Ears"]      = "rbxassetid://118516289496954",
        ["Orange Egg"]      = "rbxassetid://76307362192037",
        ["Green Egg"]       = "rbxassetid://94602857440295",
        ["Blue Egg"]        = "rbxassetid://109212886335786",
        ["Pink Egg"]        = "rbxassetid://133939661230277",
        ["John Pork"]       = "rbxassetid://117176397136731",
    }

    local function createBrainrotViewport(parent, animalName, mutation, traits)
        local vp = Instance.new("ViewportFrame")
        vp.Size                   = UDim2.new(0, 120, 0, 120)
        vp.Position               = UDim2.new(0, 5, 0.5, -60)
        vp.BackgroundColor3       = Color3.fromRGB(14, 14, 18)
        vp.BackgroundTransparency = 0.05
        vp.BorderSizePixel        = 0
        vp.ZIndex                 = 4
        vp.LightDirection         = Vector3.new(-1, -2, -1)
        vp.LightColor             = Color3.fromRGB(220, 220, 255)
        vp.Ambient                = Color3.fromRGB(180, 180, 180)
        vp.Parent                 = parent
        Corner(vp, 8)
        Stroke(vp, T.Border, 1)

        local wm  = Instance.new("WorldModel"); wm.Parent = vp
        local cam = Instance.new("Camera");     cam.Parent = vp
        vp.CurrentCamera = cam

        task.spawn(function()
            local template = afGetTemplate(animalName)
            if not template then return end
            local clone = template:Clone()

            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored   = true
                    d.CanCollide = false
                end
            end

            clone.Parent = wm

            if mutation and mutation ~= "None" then
                ApplyMutation(clone, animalName, tostring(mutation))
            end

            for _, d in ipairs(wm:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored   = true
                    d.CanCollide = false
                end
            end

            local cf, size = clone:GetBoundingBox()
            local maxDim = math.max(size.X, size.Y, size.Z)

            cam.FieldOfView = 50
            local fovRad = math.rad(cam.FieldOfView / 2)
            local dist   = (maxDim / 2) / math.tan(fovRad) * 1.1

            local centerPos = cf.Position
            cam.CFrame = CFrame.new(
                centerPos + Vector3.new(0, 0, dist),
                centerPos
            )

            local animFolder = afGetAnimFolder(animalName)
            local idleAnim   = animFolder and animFolder:FindFirstChild("Idle")
            local walkAnim   = animFolder and animFolder:FindFirstChild("Walk")
            local useAnim    = idleAnim or walkAnim
            if useAnim then
                local controller = clone:FindFirstChildWhichIsA("AnimationController", true)
                                or clone:FindFirstChildWhichIsA("Humanoid", true)
                if not controller then
                    controller = Instance.new("AnimationController")
                    controller.Parent = clone
                end
                local animator = controller:FindFirstChildWhichIsA("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = controller
                end
                local ok2, track = pcall(function() return animator:LoadAnimation(useAnim) end)
                if ok2 and track then
                    track.Looped = true
                    track:Play()
                end
            end

            local angle  = 0
            local orbitR = dist
            local RSvc2  = game:GetService("RunService")
            local _vpConn
            _vpConn = RSvc2.RenderStepped:Connect(function(dt)
                if not vp.Parent then
                    _vpConn:Disconnect()
                    _vpConn = nil
                    return
                end
                angle = angle + dt * 0.6
                cam.CFrame = CFrame.new(
                    Vector3.new(
                        centerPos.X + math.sin(angle) * orbitR,
                        centerPos.Y,
                        centerPos.Z + math.cos(angle) * orbitR
                    ),
                    centerPos
                )
            end)
            vp.AncestryChanged:Connect(function()
                if _vpConn and not vp.Parent then
                    _vpConn:Disconnect()
                    _vpConn = nil
                end
            end)
        end)
        return vp
    end

    local selectedUID   = nil
    local selectedCard  = nil
    local onSelectCBs   = {}

    local function setSelected(uid, card)

        if selectedCard and selectedCard.Parent then
            Stroke(selectedCard, T.Border, 1)

        end
        selectedUID  = uid
        selectedCard = card
        _G._FH_SelectedBrainrot = uid
    end

    CreateSection(BrainrotsTab.scroll, "ANIMALS ON PLOTS")

    local cardContainer = Instance.new("Frame")
    cardContainer.Name                   = "BrainrotCards"
    cardContainer.BackgroundTransparency = 1
    cardContainer.Size                   = UDim2.new(1, -16, 0, 0)
    cardContainer.AutomaticSize          = Enum.AutomaticSize.Y
    cardContainer.BorderSizePixel        = 0
    cardContainer.Parent                 = BrainrotsTab.scroll
    local cardLayout = Instance.new("UIListLayout")
    cardLayout.FillDirection       = Enum.FillDirection.Vertical
    cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cardLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    cardLayout.Padding             = UDim.new(0, 6)
    cardLayout.Parent              = cardContainer

    local builtUIDs     = {}
    local labelUpdaters = {}

    local CARD_H = 130
    local function buildAnimalCard(rec, index)
        local uid = rec.plotName .. "_" .. rec.slot

        local card = Instance.new("Frame")
        card.Size             = UDim2.new(1, 0, 0, CARD_H)
        card.BackgroundColor3 = T.Card
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel  = 0
        card.LayoutOrder      = index
        card.Parent           = cardContainer
        Corner(card, 8)
        local cStroke = Stroke(card, T.Border, 1)

        createBrainrotViewport(card, rec.name, rec.mutation, rec.traits)

        local infoFrame = Instance.new("Frame")
        infoFrame.Size             = UDim2.new(1, -128, 1, 0)
        infoFrame.Position         = UDim2.new(0, 130, 0, 0)
        infoFrame.BackgroundTransparency = 1
        infoFrame.BorderSizePixel  = 0
        infoFrame.ZIndex           = 4
        infoFrame.Parent           = card

        local nameLbl = Label(infoFrame, rec.name, isMobile and 11 or 13, T.White, Enum.Font.GothamBold)
        nameLbl.Size           = UDim2.new(1, -8, 0, 18)
        nameLbl.Position       = UDim2.new(0, 0, 0, 10)
        nameLbl.TextTruncate   = Enum.TextTruncate.AtEnd
        nameLbl.ZIndex         = 4

        local mutText = rec.mutation and tostring(rec.mutation) or "None"
        local mutLbl  = Label(infoFrame, "Mutation: " .. mutText, isMobile and 9 or 11, T.White, Enum.Font.GothamMedium)
        mutLbl.Size     = UDim2.new(1, -8, 0, 14)
        mutLbl.Position = UDim2.new(0, 0, 0, 30)
        mutLbl.TextTruncate = Enum.TextTruncate.AtEnd
        mutLbl.ZIndex   = 4

        local genLbl = Label(infoFrame, "Gen: " .. rec.genText, isMobile and 9 or 11, Color3.fromRGB(86, 196, 128), Enum.Font.GothamBold)
        genLbl.Size     = UDim2.new(1, -8, 0, 14)
        genLbl.Position = UDim2.new(0, 0, 0, 46)
        genLbl.ZIndex   = 4

        local orderText = (rec.plotOrder or rec.plotName) .. "  â€¢  Podium #" .. rec.slot
        local podiumLbl = Label(infoFrame, orderText, isMobile and 9 or 11, T.Dim, Enum.Font.GothamMedium)
        podiumLbl.Size     = UDim2.new(1, -8, 0, 14)
        podiumLbl.Position = UDim2.new(0, 0, 0, 62)
        podiumLbl.ZIndex   = 4

        local traitList = {}
        if rec.traits and typeof(rec.traits) == "table" then
            for k, v in pairs(rec.traits) do
                if type(k) == "number" then table.insert(traitList, tostring(v))
                else table.insert(traitList, tostring(k)) end
            end
        end
        if #traitList > 0 then
            local traitsRow = Instance.new("Frame")
            traitsRow.Size             = UDim2.new(1, -8, 0, 18)
            traitsRow.Position         = UDim2.new(0, 0, 0, 78)
            traitsRow.BackgroundTransparency = 1
            traitsRow.BorderSizePixel  = 0
            traitsRow.ClipsDescendants = true
            traitsRow.ZIndex           = 4
            traitsRow.Parent           = infoFrame
            local ul = Instance.new("UIListLayout", traitsRow)
            ul.FillDirection      = Enum.FillDirection.Horizontal
            ul.VerticalAlignment  = Enum.VerticalAlignment.Center
            ul.Padding            = UDim.new(0, 2)
            for i, traitName in ipairs(traitList) do
                if i > 7 then break end
                local icon = TRAIT_ICONS[traitName]
                local img  = Instance.new("ImageLabel")
                img.Size                   = UDim2.new(0, 18, 0, 18)
                img.BackgroundTransparency = 1
                img.BorderSizePixel        = 0
                img.Image                  = icon or ""
                img.ZIndex                 = 5
                img.Parent                 = traitsRow
                if not icon then

                    local lbl2 = Label(img, traitName:sub(1,2), 6, T.Dim, Enum.Font.GothamBold)
                    lbl2.Size = UDim2.new(1,0,1,0)
                    lbl2.TextXAlignment = Enum.TextXAlignment.Center
                    lbl2.TextYAlignment = Enum.TextYAlignment.Center
                    lbl2.ZIndex = 6
                end
            end
        end

        local selBtn = Instance.new("TextButton")
        selBtn.Size             = UDim2.new(1, -8, 0, 22)
        selBtn.Position         = UDim2.new(0, 0, 1, -28)
        selBtn.BackgroundColor3 = T.Card
        selBtn.BorderSizePixel  = 0
        selBtn.Text             = "SELECT"
        selBtn.TextSize         = isMobile and 9 or 11
        selBtn.Font             = Enum.Font.GothamBold
        selBtn.TextColor3       = T.Dim
        selBtn.ZIndex           = 5
        selBtn.AutoButtonColor  = false
        selBtn.Parent           = infoFrame
        Corner(selBtn, 6)
        local selStroke = Stroke(selBtn, T.Border, 1)

        local isSelected = false
        local function applySelectedVisual(v)
            isSelected = v
            if v then
                TweenService:Create(selBtn, F, {BackgroundColor3 = T.White, TextColor3 = Color3.fromRGB(12,12,12)}):Play()
                TweenService:Create(selStroke, F, {Color = T.White}):Play()
                TweenService:Create(cStroke, F, {Color = T.White, Thickness = 2}):Play()
                selBtn.Text = "SELECT"
            else
                TweenService:Create(selBtn, F, {BackgroundColor3 = T.Card, TextColor3 = T.Dim}):Play()
                TweenService:Create(selStroke, F, {Color = T.Border}):Play()
                TweenService:Create(cStroke, F, {Color = T.Border, Thickness = 1}):Play()
                selBtn.Text = "SELECT"
            end
        end

        onSelectCBs[uid] = function(forceOff)
            if forceOff and isSelected then
                applySelectedVisual(false)
            end
        end

        local function programmaticSelect()
            if isSelected then return end
            if selectedUID and onSelectCBs[selectedUID] then
                onSelectCBs[selectedUID](true)
            end
            applySelectedVisual(true)
            selectedUID = uid
            _G._FH_SelectedBrainrot = {
                uid      = uid,
                name     = rec.name,
                mutation = rec.mutation,
                gen      = rec.genValue,
                genText  = rec.genText,
                plotName = rec.plotName,
                slot     = rec.slot,
                owner    = rec.owner,
            }
        end

        if not _G._FH_CardSelectFns then _G._FH_CardSelectFns = {} end
        _G._FH_CardSelectFns[uid] = programmaticSelect

        selBtn.MouseButton1Click:Connect(function()
            if isSelected then

                applySelectedVisual(false)
                selectedUID  = nil
                selectedCard = nil
                _G._FH_SelectedBrainrot = nil
            else

                if selectedUID and onSelectCBs[selectedUID] then
                    onSelectCBs[selectedUID](true)
                end
                applySelectedVisual(true)
                selectedUID  = uid
                _G._FH_SelectedBrainrot = {
                    uid      = uid,
                    name     = rec.name,
                    mutation = rec.mutation,
                    gen      = rec.genValue,
                    genText  = rec.genText,
                    plotName = rec.plotName,
                    slot     = rec.slot,
                    owner    = rec.owner,
                }
            end
        end)

        card.MouseEnter:Connect(function()
            if not isSelected then
                TweenService:Create(card, F, {BackgroundColor3 = T.CardHover}):Play()
                TweenService:Create(cStroke, F, {Color = T.BorderHover}):Play()
            end
        end)
        card.MouseLeave:Connect(function()
            if not isSelected then
                TweenService:Create(card, F, {BackgroundColor3 = T.Card}):Play()
                TweenService:Create(cStroke, F, {Color = T.Border}):Play()
            end
        end)

        labelUpdaters[uid] = function(newRec, newIndex)
            mutLbl.Text    = "Mutation: " .. (newRec.mutation and tostring(newRec.mutation) or "None")
            genLbl.Text    = "Gen: " .. newRec.genText
            podiumLbl.Text = (newRec.plotOrder or newRec.plotName) .. "  â€¢  Podium #" .. newRec.slot
            card.LayoutOrder = newIndex
        end

        return card
    end

    local scanning        = false

    local function doScan()
        if scanning then return end
        scanning = true

        task.spawn(function()
            local ok, results = pcall(scanAllAnimals)
            if not ok or not results then results = {} end
            _G._FH_LastAnimalScan = results

            local prevUID = selectedUID

            local seenUIDs = {}
            for _, rec in ipairs(results) do
                local uid = rec.plotName .. "_" .. rec.slot
                seenUIDs[uid] = true
            end

            for uid, _ in pairs(builtUIDs) do
                if not seenUIDs[uid] then

                    for _, c in ipairs(cardContainer:GetChildren()) do
                        if c:IsA("Frame") and c.Name == "Card_"..uid then
                            c:Destroy()
                            break
                        end
                    end
                    builtUIDs[uid]     = nil
                    labelUpdaters[uid] = nil
                    onSelectCBs[uid]   = nil
                    if selectedUID == uid then
                        selectedUID  = nil
                        selectedCard = nil
                        _G._FH_SelectedBrainrot = nil
                    end
                end
            end

            for i, rec in ipairs(results) do
                local uid = rec.plotName .. "_" .. rec.slot
                if not builtUIDs[uid] then

                    local card = buildAnimalCard(rec, i)
                    card.Name = "Card_"..uid
                    builtUIDs[uid] = true
                else

                    if labelUpdaters[uid] then
                        labelUpdaters[uid](rec, i)
                    end
                end
            end

            scanning = false
        end)
    end

    AutoSelectBestBrainrot = (Config.toggles["AutoSelectBestBrainrot"] == true)

    local function autoSelectBest()
        local results = _G._FH_LastAnimalScan
        if not results or #results == 0 then return end

        local best = results[1]
        if not best then return end
        local uid = best.plotName .. "_" .. best.slot

        if selectedUID == uid then return end

        if selectedUID and onSelectCBs[selectedUID] then
            onSelectCBs[selectedUID](true)
        end
        selectedUID = uid
        _G._FH_SelectedBrainrot = {
            uid      = uid,
            name     = best.name,
            mutation = best.mutation,
            gen      = best.genValue,
            genText  = best.genText,
            plotName = best.plotName,
            slot     = best.slot,
            owner    = best.owner,
        }

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
            if AutoSelectBestBrainrot then
                pcall(autoSelectBest)
            end
            task.wait(4.95)
        end
    end)
end

CreateSection(UtilsTab.scroll, "AUTO MODE")
do

    local AutoResetBalloonEnabled = false
    local _arbConns        = {}
    local _arbBoundRemotes = {}
    local _arbAddConn      = nil
    local _arbLastFire     = 0

    local function doSelectedReset()
        local LocalPlayer = Players.LocalPlayer
        local Net = ReplicatedStorage:WaitForChild("Packages", 2)
            and ReplicatedStorage.Packages:WaitForChild("Net", 2)
        if not Net then
            local char = LocalPlayer and LocalPlayer.Character
            local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.Health = 0 end
            return
        end
        local remote = nil
        local childs = Net:GetChildren()
        for i = 1, #childs - 1 do
            if childs[i] and childs[i + 1] and string.find(childs[i].Name, "Tools/Cooldown") then
                remote = childs[i + 1]; break
            end
        end
        if not remote then
            local char = LocalPlayer and LocalPlayer.Character
            local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.Health = 0 end
            return
        end
        local savedTools = {}
        local char = LocalPlayer.Character
        local bp   = LocalPlayer:FindFirstChild("Backpack")
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:UnequipTools() end) end
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
            end
        end
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
            end
        end
        LocalPlayer.Character = nil
        local sending = true
        local loopConnection
        local fire = remote.FireServer
        local _respawnThrottle = 0
        loopConnection = RunService.Heartbeat:Connect(function(dt)
            if not sending then
                if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
                return
            end
            _respawnThrottle = _respawnThrottle + dt
            if _respawnThrottle >= 0.016 then
                _respawnThrottle = 0
                pcall(fire, remote, "f888ee6e-c86d-46e1-93d7-0639d6635d42", LocalPlayer, "balloon")
            end
            if sending and LocalPlayer.Character then LocalPlayer.Character = nil end
        end)
        local conn
        conn = LocalPlayer.CharacterAdded:Connect(function()
            sending = false
            if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
            if conn then conn:Disconnect() end
            task.spawn(function()
                local newBp = LocalPlayer:WaitForChild("Backpack", 3)
                if newBp then
                    for _, t in ipairs(savedTools) do if t then t.Parent = newBp end end
                end
                savedTools = {}
            end)
        end)
        task.delay(4, function()
            sending = false
            if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
            local curBp = LocalPlayer:FindFirstChild("Backpack")
            if curBp and #savedTools > 0 then
                for _, t in ipairs(savedTools) do if t then t.Parent = curBp end end
                savedTools = {}
            end
        end)
    end

    _G._FH_DoSelectedReset = doSelectedReset

    local function _arbStringMatchesBalloon(s)
        if type(s) ~= "string" then return false end
        local ls = s:lower()
        return ls:find("jump higher", 1, true) ~= nil
    end
    local function _arbHandleArgs(...)
        if not AutoResetBalloonEnabled then return end
        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            if _arbStringMatchesBalloon(arg) then
                local now = tick()
                if now - _arbLastFire < 3 then return end
                _arbLastFire = now
                if AutoResetBalloonEnabled then
                    doSelectedReset()
                end
                return
            end
        end
    end
    local function _arbBindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _arbBoundRemotes[obj] then return end
        local ok, conn = pcall(function()
            return obj.OnClientEvent:Connect(_arbHandleArgs)
        end)
        if ok and conn then
            table.insert(_arbConns, conn)
            _arbBoundRemotes[obj] = true
        end
    end
    local function startAutoResetBalloon()
        for _, conn in ipairs(_arbConns) do pcall(function() conn:Disconnect() end) end
        _arbConns = {}
        _arbBoundRemotes = {}
        if _arbAddConn then pcall(function() _arbAddConn:Disconnect() end); _arbAddConn = nil end
        -- Connect DescendantAdded FIRST so no remotes are missed during the scan
        _arbAddConn = ReplicatedStorage.DescendantAdded:Connect(function(obj)
            if AutoResetBalloonEnabled then _arbBindRemote(obj) end
        end)
        -- Scan existing descendants off the main thread so toggling doesn't freeze
        task.spawn(function()
            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                if not AutoResetBalloonEnabled then break end
                _arbBindRemote(obj)
            end
        end)
    end
    local function stopAutoResetBalloon()
        for _, conn in ipairs(_arbConns) do pcall(function() conn:Disconnect() end) end
        _arbConns = {}
        _arbBoundRemotes = {}
        if _arbAddConn then pcall(function() _arbAddConn:Disconnect() end); _arbAddConn = nil end
    end

    CreateToggle(UtilsTab.scroll, "Reset when ballooned", "Auto resets if you get ballooned", function(v)
        AutoResetBalloonEnabled = v
        if v then startAutoResetBalloon() else stopAutoResetBalloon() end
    end)
end

do
    local _afPending = false

    local function tryAutoFlash()
        if not AutoFlashEnabled then return end
        if not _G._FH_SelectedBrainrot then
            pcall(ShowToggleNotification, "Auto Flash: no animal selected", false)
            return
        end
        if _afPending then return end
        _afPending = true

        task.spawn(function()
            local lp = Players.LocalPlayer

            pcall(ShowToggleNotification, "Auto Flash: resetting...", true)
            if _G._FH_DoSelectedReset then
                pcall(_G._FH_DoSelectedReset)
            end

            local deadline = tick() + 8
            while (not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart")) and tick() < deadline do
                task.wait(0.1)
            end

            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
                _afPending = false
                return
            end

            task.wait(0.15)
            if not AutoFlashEnabled then _afPending = false; return end
            if not _G._FH_SelectedBrainrot then _afPending = false; return end

            pcall(ShowToggleNotification, "Auto Flash: flashing!", true)
            if _G._FH_FlashBtnEntry then
                pcall(_G._FH_FlashBtnEntry.fire)
            end

            task.wait(3)
            _afPending = false
        end)
    end

    local _afBoundRemotes = {}
    local _afLastBalloon  = 0
    local function _afBindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _afBoundRemotes[obj] then return end
        local ok, conn = pcall(function()
            return obj.OnClientEvent:Connect(function(...)
                if not AutoFlashEnabled then return end
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
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do _afBindRemote(obj) end
    ReplicatedStorage.DescendantAdded:Connect(function(obj) _afBindRemote(obj) end)
end
do

    local AutoResetTinyEnabled = false
    local _artConns        = {}
    local _artBoundRemotes = {}
    local _artAddConn      = nil
    local _artLastFire     = 0

    local function _arbStringMatchesTiny(s)
        if type(s) ~= "string" then return false end
        local ls = s:lower()
        return ls:find("tiny for 30", 1, true) ~= nil
    end
    local function _artHandleArgs(...)
        if not AutoResetTinyEnabled then return end
        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            if _arbStringMatchesTiny(arg) then
                local now = tick()
                if now - _artLastFire < 3 then return end
                _artLastFire = now
                local LocalPlayer = Players.LocalPlayer
                local Net = ReplicatedStorage:WaitForChild("Packages", 2)
                    and ReplicatedStorage.Packages:WaitForChild("Net", 2)
                if not Net then
                    local char = LocalPlayer and LocalPlayer.Character
                    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum.Health = 0 end
                    return
                end
                local remote = nil
                local childs = Net:GetChildren()
                for i2 = 1, #childs - 1 do
                    if childs[i2] and childs[i2+1] and string.find(childs[i2].Name, "Tools/Cooldown") then
                        remote = childs[i2+1]; break
                    end
                end
                if not remote then
                    local char = LocalPlayer and LocalPlayer.Character
                    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum.Health = 0 end
                    return
                end
                local savedTools = {}
                local char = LocalPlayer.Character
                local bp   = LocalPlayer:FindFirstChild("Backpack")
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:UnequipTools() end) end
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
                    end
                end
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
                    end
                end
                LocalPlayer.Character = nil
                local sending = true
                local loopConn
                local fire = remote.FireServer
                local throttle = 0
                loopConn = RunService.Heartbeat:Connect(function(dt)
                    if not sending then
                        if loopConn then loopConn:Disconnect(); loopConn = nil end
                        return
                    end
                    throttle = throttle + dt
                    if throttle >= 0.016 then
                        throttle = 0
                        pcall(fire, remote, "f888ee6e-c86d-46e1-93d7-0639d6635d42", LocalPlayer, "balloon")
                    end
                    if sending and LocalPlayer.Character then LocalPlayer.Character = nil end
                end)
                local conn2
                conn2 = LocalPlayer.CharacterAdded:Connect(function()
                    sending = false
                    if loopConn then loopConn:Disconnect(); loopConn = nil end
                    if conn2 then conn2:Disconnect() end
                    task.spawn(function()
                        local newBp = LocalPlayer:WaitForChild("Backpack", 3)
                        if newBp then
                            for _, t in ipairs(savedTools) do if t then t.Parent = newBp end end
                        end
                        savedTools = {}
                    end)
                end)
                task.delay(4, function()
                    sending = false
                    if loopConn then loopConn:Disconnect(); loopConn = nil end
                    local curBp = LocalPlayer:FindFirstChild("Backpack")
                    if curBp and #savedTools > 0 then
                        for _, t in ipairs(savedTools) do if t then t.Parent = curBp end end
                        savedTools = {}
                    end
                end)
                return
            end
        end
    end
    local function _artBindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _artBoundRemotes[obj] then return end
        local ok, conn = pcall(function()
            return obj.OnClientEvent:Connect(_artHandleArgs)
        end)
        if ok and conn then
            table.insert(_artConns, conn)
            _artBoundRemotes[obj] = true
        end
    end
    local function startAutoResetTiny()
        for _, conn in ipairs(_artConns) do pcall(function() conn:Disconnect() end) end
        _artConns = {}
        _artBoundRemotes = {}
        if _artAddConn then pcall(function() _artAddConn:Disconnect() end); _artAddConn = nil end
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do _artBindRemote(obj) end
        _artAddConn = ReplicatedStorage.DescendantAdded:Connect(function(obj)
            if AutoResetTinyEnabled then _artBindRemote(obj) end
        end)
    end
    local function stopAutoResetTiny()
        for _, conn in ipairs(_artConns) do pcall(function() conn:Disconnect() end) end
        _artConns = {}
        _artBoundRemotes = {}
        if _artAddConn then pcall(function() _artAddConn:Disconnect() end); _artAddConn = nil end
    end

    CreateToggle(UtilsTab.scroll, "Reset when tiny", "Auto resets if you get shrunk", function(v)
        AutoResetTinyEnabled = v
        if v then startAutoResetTiny() else stopAutoResetTiny() end
    end)
end
do

    local AutoResetJailEnabled = false
    RagdollBypassEnabled = false
    _ragdollBypassLastUse = nil
    AutoFlashEnabled = false

    _ragdollCommandCache = {}
    _ragdollProfileCache = {}

    _ragdollCacheActivated = function(guiObject)
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

    _ragdollFireActivated = function(cached)
        for _, fn in ipairs(cached) do task.spawn(fn) end
    end

    _ragdollGetAdminFrames = function()
        local ap = Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
        if not ap then return nil, nil end
        local panel = ap:FindFirstChild("AdminPanel")
        if not panel then return nil, nil end
        local content  = panel:FindFirstChild("Content")
        local profiles = panel:FindFirstChild("Profiles")
        if not content or not profiles then return nil, nil end
        return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
    end

    _ragdollSelf = function()
        local commandFrame, profileFrame = _ragdollGetAdminFrames()
        if not commandFrame or not profileFrame then return end
        local pName = Players.LocalPlayer.Name
        local profileBtn = profileFrame:FindFirstChild(pName)
        local ragdollBtn = commandFrame:FindFirstChild("ragdoll")
        if not profileBtn or not ragdollBtn then return end
        if not _ragdollProfileCache[pName] then
            _ragdollProfileCache[pName] = _ragdollCacheActivated(profileBtn)
        end
        if not _ragdollCommandCache["ragdoll"] then
            _ragdollCommandCache["ragdoll"] = _ragdollCacheActivated(ragdollBtn)
        end
        _ragdollFireActivated(_ragdollCommandCache["ragdoll"])
        task.wait()
        _ragdollFireActivated(_ragdollProfileCache[pName])
    end
    local _arjConns        = {}
    local _arjBoundRemotes = {}
    local _arjAddConn      = nil
    local _arjLastFire     = 0

    local function _arbStringMatchesJail(s)
        if type(s) ~= "string" then return false end
        local ls = s:lower()
        return ls:find("trapped for", 1, true) ~= nil
    end
    local function _arjHandleArgs(...)
        if not AutoResetJailEnabled then return end
        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            if _arbStringMatchesJail(arg) then
                local now = tick()
                if now - _arjLastFire < 3 then return end
                _arjLastFire = now
                local LocalPlayer = Players.LocalPlayer
                local Net = ReplicatedStorage:WaitForChild("Packages", 2)
                    and ReplicatedStorage.Packages:WaitForChild("Net", 2)
                if not Net then
                    local char = LocalPlayer and LocalPlayer.Character
                    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum.Health = 0 end
                    return
                end
                local remote = nil
                local childs = Net:GetChildren()
                for i2 = 1, #childs - 1 do
                    if childs[i2] and childs[i2+1] and string.find(childs[i2].Name, "Tools/Cooldown") then
                        remote = childs[i2+1]; break
                    end
                end
                if not remote then
                    local char = LocalPlayer and LocalPlayer.Character
                    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum.Health = 0 end
                    return
                end
                local savedTools = {}
                local char = LocalPlayer.Character
                local bp   = LocalPlayer:FindFirstChild("Backpack")
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:UnequipTools() end) end
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
                    end
                end
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
                    end
                end
                LocalPlayer.Character = nil
                local sending = true
                local loopConn
                local fire = remote.FireServer
                local throttle = 0
                loopConn = RunService.Heartbeat:Connect(function(dt)
                    if not sending then
                        if loopConn then loopConn:Disconnect(); loopConn = nil end
                        return
                    end
                    throttle = throttle + dt
                    if throttle >= 0.016 then
                        throttle = 0
                        pcall(fire, remote, "f888ee6e-c86d-46e1-93d7-0639d6635d42", LocalPlayer, "balloon")
                    end
                    if sending and LocalPlayer.Character then LocalPlayer.Character = nil end
                end)
                local conn2
                conn2 = LocalPlayer.CharacterAdded:Connect(function()
                    sending = false
                    if loopConn then loopConn:Disconnect(); loopConn = nil end
                    if conn2 then conn2:Disconnect() end
                    task.spawn(function()
                        local newBp = LocalPlayer:WaitForChild("Backpack", 3)
                        if newBp then
                            for _, t in ipairs(savedTools) do if t then t.Parent = newBp end end
                        end
                        savedTools = {}
                    end)
                end)
                task.delay(4, function()
                    sending = false
                    if loopConn then loopConn:Disconnect(); loopConn = nil end
                    local curBp = LocalPlayer:FindFirstChild("Backpack")
                    if curBp and #savedTools > 0 then
                        for _, t in ipairs(savedTools) do if t then t.Parent = curBp end end
                        savedTools = {}
                    end
                end)
                return
            end
        end
    end
    local function _arjBindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end
        if _arjBoundRemotes[obj] then return end
        local ok, conn = pcall(function()
            return obj.OnClientEvent:Connect(_arjHandleArgs)
        end)
        if ok and conn then
            table.insert(_arjConns, conn)
            _arjBoundRemotes[obj] = true
        end
    end
    local function startAutoResetJail()
        for _, conn in ipairs(_arjConns) do pcall(function() conn:Disconnect() end) end
        _arjConns = {}
        _arjBoundRemotes = {}
        if _arjAddConn then pcall(function() _arjAddConn:Disconnect() end); _arjAddConn = nil end
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do _arjBindRemote(obj) end
        _arjAddConn = ReplicatedStorage.DescendantAdded:Connect(function(obj)
            if AutoResetJailEnabled then _arjBindRemote(obj) end
        end)
    end
    local function stopAutoResetJail()
        for _, conn in ipairs(_arjConns) do pcall(function() conn:Disconnect() end) end
        _arjConns = {}
        _arjBoundRemotes = {}
        if _arjAddConn then pcall(function() _arjAddConn:Disconnect() end); _arjAddConn = nil end
    end

    CreateToggle(UtilsTab.scroll, "Reset when jail", "Auto resets if you get jailed", function(v)
        AutoResetJailEnabled = v
        if v then startAutoResetJail() else stopAutoResetJail() end
    end)
end
do
    local AntiStealEnabled    = false
    local _asHeartbeat        = nil
    local _asCooldowns        = {}
    local _asHitboxCache      = {}
    local _asHitboxCacheTime  = {}
    local COOLDOWN            = 6
    local EXPAND              = 5
    local CACHE_TTL           = 4

    local defenseProfileCache = {}
    local defenseCommandCache = {}

    local function defenseCacheActivated(guiObject)
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
    local function defenseFireActivated(cached)
        for _, fn in ipairs(cached) do task.spawn(fn) end
    end
    local function getDefenseAdminPanel()
        local player     = Players.LocalPlayer
        local adminPanel = player.PlayerGui:FindFirstChild("AdminPanel")
        if not adminPanel then return nil, nil end
        local panel = adminPanel:FindFirstChild("AdminPanel")
        if not panel then return nil, nil end
        local content  = panel:FindFirstChild("Content")
        local profiles = panel:FindFirstChild("Profiles")
        if not content or not profiles then return nil, nil end
        return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
    end
    local function buildDefenseCache(targetPlayer)
        local commandFrame, profileFrame = getDefenseAdminPanel()
        if not commandFrame or not profileFrame then

            return false
        end
        local profileButton = profileFrame:FindFirstChild(targetPlayer.Name)
        if not profileButton then

            return false
        end
        if not defenseProfileCache[targetPlayer.Name] then
            defenseProfileCache[targetPlayer.Name] = defenseCacheActivated(profileButton)

        end
        for _, cmd in ipairs({"balloon", "ragdoll", "jail"}) do
            if not defenseCommandCache[cmd] then
                local btn = commandFrame:FindFirstChild(cmd)
                if btn then
                    defenseCommandCache[cmd] = defenseCacheActivated(btn)

                else

                end
            end
        end
        return true
    end
    local function defenseExecuteCommandsOnPlayer(targetPlayer, commandList)
        if not defenseProfileCache[targetPlayer.Name] or #defenseProfileCache[targetPlayer.Name] == 0 then
            if not buildDefenseCache(targetPlayer) then return false end
        end
        local profileConns = defenseProfileCache[targetPlayer.Name]
        for _, command in ipairs(commandList) do
            local cmdConns = defenseCommandCache[command]
            if cmdConns and #cmdConns > 0 then
                defenseFireActivated(cmdConns)
                defenseFireActivated(profileConns)
            else

            end
        end
        return true
    end

    local function getTheirHitbox(p)
        local now = tick()
        if _asHitboxCache[p.Name] and (now - (_asHitboxCacheTime[p.Name] or 0)) < CACHE_TTL then
            return _asHitboxCache[p.Name]
        end
        _asHitboxCache[p.Name] = nil
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return nil end
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign", true)
            if not sign then continue end
            for _, d in ipairs(sign:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and d.Text ~= "" then
                    local owner = d.Text:match("[Bb]ase [Oo]f%s+(.+)") or d.Text
                    owner = owner:match("^%s*(.-)%s*$")
                    if owner == p.Name or owner == p.DisplayName then
                        local hb = plot:FindFirstChild("DeliveryHitbox")
                        if hb then

                            _asHitboxCache[p.Name]     = hb
                            _asHitboxCacheTime[p.Name] = now
                            return hb
                        end
                    end
                end
            end
        end
        _asHitboxCacheTime[p.Name] = now
        return nil
    end

    local function isNearHitbox(hitbox, point)
        local lp   = hitbox.CFrame:PointToObjectSpace(point)
        local half = (hitbox.Size / 2) + Vector3.new(EXPAND, EXPAND, EXPAND)
        return math.abs(lp.X) <= half.X
           and math.abs(lp.Y) <= half.Y
           and math.abs(lp.Z) <= half.Z
    end

    local function startAntiSteal()
        if _asHeartbeat then _asHeartbeat:Disconnect(); _asHeartbeat = nil end
        _asCooldowns      = {}
        _asHitboxCache    = {}
        _asHitboxCacheTime= {}
        defenseProfileCache = {}
        defenseCommandCache = {}

        _asHeartbeat = RunService.Heartbeat:Connect(function()
            if not AntiStealEnabled then return end
            local now = tick()
            for _, p in ipairs(Players:GetPlayers()) do
                if p == Players.LocalPlayer then continue end
                if not p.Character then continue end
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local hitbox = getTheirHitbox(p)
                if not hitbox then continue end
                if not isNearHitbox(hitbox, hrp.Position) then continue end
                local last = _asCooldowns[p.Name] or 0
                if now - last < COOLDOWN then continue end
                _asCooldowns[p.Name] = now

                pcall(ShowToggleNotification, "Anti Steal: ballooning " .. p.Name, false)
                local target = p
                task.spawn(function()
                    local ok, err = pcall(defenseExecuteCommandsOnPlayer, target, {"balloon"})
                    if ok then

                    else

                    end
                end)
            end
        end)
    end

    local function stopAntiSteal()
        if _asHeartbeat then _asHeartbeat:Disconnect(); _asHeartbeat = nil end
        _asCooldowns       = {}
        _asHitboxCache     = {}
        _asHitboxCacheTime = {}

    end

    CreateToggle(UtilsTab.scroll, "Anti Steal", "Balloons players near their own DeliveryHitbox", function(v)
        AntiStealEnabled = v
        if v then startAntiSteal() else stopAntiSteal() end
    end)
end
CreateSection(UtilsTab.scroll, "GRAB")
CreateToggle(UtilsTab.scroll, "Auto Block", "Blocks the plot owner shortly after a grab starts (ping-based delay)", function(v)
    AutoBlockEnabled = v
end)

CreateSection(UtilsTab.scroll, "FLASH")
CreateToggle(UtilsTab.scroll, "Auto Flash",      "Automatically uses flash on enemies", function(v)
    AutoFlashEnabled = v
end)
CreateToggle(UtilsTab.scroll, "Ragdoll Bypass",  "Bypasses ragdoll effects on your character", function(v)
    RagdollBypassEnabled = v
end)
CreateToggle(UtilsTab.scroll, "Anti Ragdoll", "Prevents ragdoll from triggering on your character", function(v)
    if v then
        AntiRagdoll.enable()
    else
        AntiRagdoll.disable()
    end
end)

CreateSection(UtilsTab.scroll, "BRAINROT")
CreateToggle(UtilsTab.scroll, "Auto Select Best Brainrot", "Auto-selects the highest gen animal on scan", function(v)
    AutoSelectBestBrainrot = v
    Config.toggles["AutoSelectBestBrainrot"] = v
    pcall(FH_SaveConfig)
    if v and _G._FH_LastAnimalScan and #_G._FH_LastAnimalScan > 0 then
        pcall(_G._FH_AutoSelectBest)
    end
end, Config.toggles["AutoSelectBestBrainrot"] == true)

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- FAST PANEL (Quick Admin)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
do
    CreateSection(UtilsTab.scroll, "ADMIN")

    local FP = {}         -- fast panel state
    FP.win       = nil
    FP.visible   = false
    FP.minimized = false

    local FP_W          = isMobile and 340 or 420   -- wider for better visibility
    local FP_ROW_H      = isMobile and 38  or 46
    local FP_AVT_SIZE   = isMobile and 28  or 34   -- avatar thumbnail square
    local FP_BTN_SIZE   = isMobile and 26  or 30
    local FP_BTN_GAP    = 5
    local FP_PAD_L      = 5                         -- row left padding
    local FP_PAD_R      = 6                         -- row right padding
    -- layout (leftâ†’right): PAD_L | avatar | 5 | name | 4 | [5 btns] | PAD_R
    -- btn block width = 5*(BTN_SIZE+BTN_GAP)-BTN_GAP
    local FP_BTN_BLOCK  = 5 * FP_BTN_SIZE + 4 * FP_BTN_GAP
    local FP_NAME_X     = FP_PAD_L + FP_AVT_SIZE + 5
    local FP_BTNS_X_END = FP_W - 8 - FP_PAD_R     -- right edge of last button (relative to row)
    local FP_BTNS_X     = FP_BTNS_X_END - FP_BTN_BLOCK  -- left edge of first button
    local FP_NAME_W     = FP_BTNS_X - FP_NAME_X - 4

    local FP_CMDS = {
        { name = "tiny",    emoji = "ðŸ¤" },
        { name = "jail",    emoji = "ðŸ”’" },
        { name = "rocket",  emoji = "ðŸš€" },
        { name = "ragdoll", emoji = "ðŸƒ" },
        { name = "balloon", emoji = "ðŸŽˆ" },
    }

    local fpCooldownBtns    = {}
    local fpCommandCache    = {}
    local fpProfileCache    = {}
    local fpCooldownRunning = false

    for _, cmd in ipairs(FP_CMDS) do
        fpCooldownBtns[cmd.name] = {}
    end

    -- reuse the ragdoll admin frame helpers already in scope
    local function fpGetAdminFrames()
        return _ragdollGetAdminFrames()
    end

    local function fpCacheActivated(guiObj)
        local cached = {}
        local ok, conns = pcall(getconnections, guiObj.Activated)
        if ok and type(conns) == "table" then
            for _, c in ipairs(conns) do
                if type(c.Function) == "function" then
                    table.insert(cached, c.Function)
                end
            end
        end
        return cached
    end

    local function fpFireActivated(cached)
        for _, fn in ipairs(cached) do task.spawn(fn) end
    end

    local function fpGetInGameScrollFrame()
        local ok, sf = pcall(function()
            return Players.LocalPlayer.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame
        end)
        return ok and sf or nil
    end

    local function fpIsOnCooldown(cmdName)
        local sf = fpGetInGameScrollFrame()
        if not sf then return false end
        local f = sf:FindFirstChild(cmdName)
        if not f then return false end
        local t = f:FindFirstChild("Timer")
        return t and t.Visible == true or false
    end

    local function fpGetCooldownText(cmdName)
        local sf = fpGetInGameScrollFrame()
        if not sf then return nil end
        local f = sf:FindFirstChild(cmdName)
        if not f then return nil end
        local t = f and f:FindFirstChild("Timer")
        if not t or not t.Visible then return nil end
        return t.Text or ""
    end

    local function fpRunCommand(cmdName, target)
        local cmdFrame, profFrame = fpGetAdminFrames()
        if not cmdFrame or not profFrame then return end
        local profBtn = profFrame:FindFirstChild(target.Name)
        local cmdBtn  = cmdFrame:FindFirstChild(cmdName)
        if not profBtn or not cmdBtn then return end
        if not fpProfileCache[target.Name] then
            fpProfileCache[target.Name] = fpCacheActivated(profBtn)
        end
        if not fpCommandCache[cmdName] then
            fpCommandCache[cmdName] = fpCacheActivated(cmdBtn)
        end
        fpFireActivated(fpProfileCache[target.Name])
        task.wait()
        fpFireActivated(fpCommandCache[cmdName])
    end

    local function fpRunCooldownLoop()
        if fpCooldownRunning then return end
        fpCooldownRunning = true
        task.spawn(function()
            while FP.win and FP.win.Parent and FP.visible do
                for _, cmd in ipairs(FP_CMDS) do
                    local onCD   = fpIsOnCooldown(cmd.name)
                    local cdText = onCD and fpGetCooldownText(cmd.name) or nil
                    for _, entry in ipairs(fpCooldownBtns[cmd.name]) do
                        local btn, emoji = entry[1], entry[2]
                        if btn and btn.Parent then
                            if onCD and cdText then
                                btn.Text      = cdText
                                btn.TextSize  = 11
                                btn.TextColor3 = Color3.fromRGB(255, 100, 100)
                                btn.BackgroundTransparency = 0.65
                            else
                                btn.Text      = emoji
                                btn.TextSize  = isMobile and 15 or 18
                                btn.TextColor3 = T.White
                                btn.BackgroundTransparency = 0.3
                            end
                        end
                    end
                end
                task.wait(0.25)
            end
            fpCooldownRunning = false
        end)
    end

    -- â”€â”€ Dynamic height helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    local FP_MAX_ROWS  = 4          -- rows before scroll kicks in
    local FP_PAD_B     = 8          -- bottom padding
    local FP_HDR_H     = 36

    local function fpCalcHeight(rowCount)
        -- header + rows (capped) + gaps + bottom pad
        local rows   = math.min(rowCount, FP_MAX_ROWS)
        local gaps   = math.max(0, rows - 1) * 3
        return FP_HDR_H + 4 + rows * FP_ROW_H + gaps + FP_PAD_B
    end

    local function fpResizeToFit(rowCount, animate)
        if not FP.win or FP.minimized then return end
        local h  = fpCalcHeight(rowCount)
        local ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if animate then
            Tween(FP.win, ti, { Size = UDim2.new(0, FP_W, 0, h) })
        else
            FP.win.Size = UDim2.new(0, FP_W, 0, h)
        end
        -- only enable scrolling once we exceed the cap
        FP.scroll.ScrollBarThickness = (rowCount > FP_MAX_ROWS) and 3 or 0
    end

    -- â”€â”€ Build the panel window â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    local function fpBuildWindow()
        if FP.win then return end

        local HDR_H   = FP_HDR_H
        local initH   = fpCalcHeight(0)   -- start at header-only height

        local win = Instance.new("Frame")
        win.Name                   = "FadedFastPanel"
        win.Size                   = UDim2.new(0, FP_W, 0, initH)
        win.AnchorPoint            = Vector2.new(0.5, 1)
        do
            local sp = Config.fastPanelPos
            if type(sp) == "table" and sp.xs and sp.xo and sp.ys and sp.yo then
                win.Position = UDim2.new(sp.xs, sp.xo, sp.ys, sp.yo)
            else
                win.Position = UDim2.new(0.5, 0, 1, -8)
            end
        end
        win.BackgroundColor3       = T.BG
        win.BackgroundTransparency = 0.04
        win.BorderSizePixel        = 0
        win.ZIndex                 = 30
        win.Visible                = false
        win.Active                 = true
        win.Draggable              = true
        win.ClipsDescendants       = true
        win.Parent                 = GUI
        Corner(win, 10)
        -- gradient border
        local winStroke = Instance.new("UIStroke")
        winStroke.Thickness       = 2
        winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        winStroke.Color           = Color3.fromRGB(255, 255, 255)
        winStroke.Parent          = win
        local winGrad = Instance.new("UIGradient")
        winGrad.Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(130, 130, 130)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(130, 130, 130)),
        })
        winGrad.Rotation = 45
        winGrad.Parent   = winStroke

        -- header
        local hdr = Instance.new("Frame")
        hdr.Name             = "Hdr"
        hdr.Size             = UDim2.new(1, 0, 0, HDR_H)
        hdr.BackgroundColor3 = T.Header
        hdr.BorderSizePixel  = 0
        hdr.ZIndex           = 31
        hdr.Parent           = win
        Corner(hdr, 10)
        -- fill bottom-rounded corners of header
        local hdrFill = Instance.new("Frame")
        hdrFill.Size             = UDim2.new(1, 0, 0, 10)
        hdrFill.Position         = UDim2.new(0, 0, 1, -10)
        hdrFill.BackgroundColor3 = T.Header
        hdrFill.BorderSizePixel  = 0
        hdrFill.ZIndex           = 31
        hdrFill.Parent           = hdr
        -- divider line under header
        local hdrLine = Instance.new("Frame")
        hdrLine.Size             = UDim2.new(1, 0, 0, 1)
        hdrLine.Position         = UDim2.new(0, 0, 1, 0)
        hdrLine.BackgroundColor3 = T.Border
        hdrLine.BorderSizePixel  = 0
        hdrLine.ZIndex           = 32
        hdrLine.Parent           = hdr

        local titleLbl = Label(hdr, "âš¡ Fast Panel", isMobile and 12 or 15, T.White, Enum.Font.GothamBold)
        titleLbl.Size     = UDim2.new(1, -50, 1, 0)
        titleLbl.Position = UDim2.new(0, 10, 0, 0)
        titleLbl.ZIndex   = 32

        -- minimise button
        local minBtn = Instance.new("TextButton")
        minBtn.Size                = UDim2.new(0, 22, 0, 18)
        minBtn.AnchorPoint         = Vector2.new(1, 0.5)
        minBtn.Position            = UDim2.new(1, -8, 0.5, 0)
        minBtn.BackgroundColor3    = T.Card
        minBtn.BorderSizePixel     = 0
        minBtn.AutoButtonColor     = false
        minBtn.Text                = "â€”"
        minBtn.TextSize            = isMobile and 9 or 11
        minBtn.Font                = Enum.Font.GothamBold
        minBtn.TextColor3          = T.Dim
        minBtn.ZIndex              = 33
        minBtn.Parent              = hdr
        Corner(minBtn, 5)
        Stroke(minBtn, T.Border, 1)

        -- scroll list
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name                 = "FPScroll"
        scroll.Size                 = UDim2.new(1, -10, 1, -(HDR_H + 6))
        scroll.Position             = UDim2.new(0, 5, 0, HDR_H + 4)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel      = 0
        scroll.ScrollBarThickness   = 0   -- hidden until > 4 players
        scroll.ScrollBarImageColor3 = T.Dim
        scroll.CanvasSize           = UDim2.new(0, 0, 0, 0)
        scroll.ZIndex               = 31
        scroll.Parent               = win
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding             = UDim.new(0, 3)
        listLayout.SortOrder           = Enum.SortOrder.LayoutOrder
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.Parent              = scroll
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
        end)

        local noTargetLbl = Label(win, "No other players found", isMobile and 9 or 11, T.Dim, Enum.Font.GothamMedium)
        noTargetLbl.Size     = UDim2.new(1, -20, 0, 24)
        noTargetLbl.Position = UDim2.new(0, 10, 0, HDR_H + 8)
        noTargetLbl.TextXAlignment = Enum.TextXAlignment.Center
        noTargetLbl.Visible  = false
        noTargetLbl.ZIndex   = 31

        FP.win         = win
        FP.scroll      = scroll
        FP.listLayout  = listLayout
        FP.noTargetLbl = noTargetLbl
        FP.hdr         = hdr
        FP.HDR_H       = HDR_H

        -- â”€â”€ minimise toggle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        minBtn.MouseButton1Click:Connect(function()
            FP.minimized = not FP.minimized
            if FP.minimized then
                Tween(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = UDim2.new(0, FP_W, 0, HDR_H) })
                scroll.Visible      = false
                noTargetLbl.Visible = false
            else
                scroll.Visible = true
                fpRefreshPlayers()   -- fpResizeToFit called inside refresh
            end
        end)

        -- â”€â”€ drag support on header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        do
            local _drag, _dragStart, _winStart = false, nil, nil
            hdr.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    _drag      = true
                    _dragStart = inp.Position
                    _winStart  = win.Position
                end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(inp)
                if _drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local d = inp.Position - _dragStart
                    win.Position = UDim2.new(
                        _winStart.X.Scale, _winStart.X.Offset + d.X,
                        _winStart.Y.Scale, _winStart.Y.Offset + d.Y)
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    _drag = false
                    -- Save position to config
                    local p = win.Position
                    Config.fastPanelPos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
                    FH_SaveConfig()
                end
            end)
        end
    end

    -- â”€â”€ Build one player row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    local function fpMakeRow(plr, order)
        local row = Instance.new("Frame")
        row.Name                   = "FPRow_" .. plr.Name
        row.Size                   = UDim2.new(1, -6, 0, FP_ROW_H)
        row.BackgroundColor3       = T.Card
        row.BackgroundTransparency = 0.1
        row.BorderSizePixel        = 0
        row.LayoutOrder            = order
        row.ZIndex                 = 32
        row.Parent                 = FP.scroll
        Corner(row, 6)
        Stroke(row, T.Border, 1)

        -- â”€â”€ avatar thumbnail â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        local avtFrame = Instance.new("Frame")
        avtFrame.Name                   = "AvtFrame"
        avtFrame.Size                   = UDim2.new(0, FP_AVT_SIZE, 0, FP_AVT_SIZE)
        avtFrame.Position               = UDim2.new(0, FP_PAD_L, 0.5, -FP_AVT_SIZE/2)
        avtFrame.BackgroundColor3       = T.BG
        avtFrame.BackgroundTransparency = 0.4
        avtFrame.BorderSizePixel        = 0
        avtFrame.ZIndex                 = 33
        avtFrame.Parent                 = row
        Corner(avtFrame, math.floor(FP_AVT_SIZE / 2))   -- circle crop
        local avtImg = Instance.new("ImageLabel")
        avtImg.Size                   = UDim2.new(1, 0, 1, 0)
        avtImg.BackgroundTransparency = 1
        avtImg.Image                  = string.format(
            "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=48&height=48&format=png",
            plr.UserId)
        avtImg.ScaleType              = Enum.ScaleType.Crop
        avtImg.ZIndex                 = 34
        avtImg.Parent                 = avtFrame
        Corner(avtImg, math.floor(FP_AVT_SIZE / 2))

        -- â”€â”€ player name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        local displayText = plr.DisplayName
        if plr.DisplayName ~= plr.Name then
            displayText = plr.DisplayName .. " (@" .. plr.Name .. ")"
        end
        local nameLbl = Label(row, displayText, isMobile and 11 or 13, T.White, Enum.Font.GothamBold)
        nameLbl.Size          = UDim2.new(0, FP_NAME_W, 1, 0)
        nameLbl.Position      = UDim2.new(0, FP_NAME_X, 0, 0)
        nameLbl.TextTruncate  = Enum.TextTruncate.AtEnd
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex        = 33

        row.MouseEnter:Connect(function() Tween(row, F, {BackgroundColor3 = T.CardHover}) end)
        row.MouseLeave:Connect(function() Tween(row, F, {BackgroundColor3 = T.Card}) end)

        -- â”€â”€ command buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        for i, cmd in ipairs(FP_CMDS) do
            local xPos = FP_BTNS_X + (i - 1) * (FP_BTN_SIZE + FP_BTN_GAP)
            local btn = Instance.new("TextButton")
            btn.Name                   = "FPCmd_" .. cmd.name
            btn.Size                   = UDim2.new(0, FP_BTN_SIZE, 0, FP_BTN_SIZE)
            btn.Position               = UDim2.new(0, xPos, 0.5, -FP_BTN_SIZE/2)
            btn.BackgroundColor3       = T.Card
            btn.BackgroundTransparency = 0.3
            btn.Text                   = cmd.emoji
            btn.TextSize               = isMobile and 15 or 18
            btn.Font                   = Enum.Font.SourceSans
            btn.AutoButtonColor        = false
            btn.ZIndex                 = 33
            btn.Parent                 = row
            Corner(btn, 4)
            Stroke(btn, T.Border, 1)

            table.insert(fpCooldownBtns[cmd.name], { btn, cmd.emoji })

            btn.MouseEnter:Connect(function()
                if not fpIsOnCooldown(cmd.name) then
                    Tween(btn, F, {BackgroundColor3 = T.CardHover, BackgroundTransparency = 0})
                end
            end)
            btn.MouseLeave:Connect(function()
                if not fpIsOnCooldown(cmd.name) then
                    Tween(btn, F, {BackgroundColor3 = T.Card, BackgroundTransparency = 0.3})
                end
            end)

            local function fireCmd()
                if fpIsOnCooldown(cmd.name) then return end
                task.spawn(function() fpRunCommand(cmd.name, plr) end)
                Tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = T.White, BackgroundTransparency = 0})
                task.delay(0.2, function()
                    Tween(btn, F, {BackgroundColor3 = T.Card, BackgroundTransparency = 0.3})
                end)
            end

            btn.MouseButton1Click:Connect(fireCmd)
            btn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then fireCmd() end
            end)
        end

        return row
    end

    -- â”€â”€ Refresh player list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    fpRefreshPlayers = function()
        if not FP.scroll then return end
        for _, cmd in ipairs(FP_CMDS) do fpCooldownBtns[cmd.name] = {} end
        for _, ch in ipairs(FP.scroll:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        local order = 1
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                fpMakeRow(plr, order)
                order = order + 1
            end
        end
        local rowCount = order - 1
        FP.noTargetLbl.Visible = (rowCount == 0)
        fpResizeToFit(rowCount, true)
        fpRunCooldownLoop()
    end

    -- â”€â”€ Show / hide â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    local _fpPlayerAddedConn   = nil
    local _fpPlayerRemovingConn = nil

    local function fpShow(v)
        if not FP.win then fpBuildWindow() end
        FP.visible     = v
        FP.win.Visible = v
        if v then
            FP.minimized      = false
            FP.scroll.Visible = true
            fpRefreshPlayers()   -- sizes window to current player count
            -- hook player add/remove to expand/shrink live
            if not _fpPlayerAddedConn then
                _fpPlayerAddedConn = Players.PlayerAdded:Connect(function()
                    if not FP.visible then return end
                    task.wait(0.3)
                    fpRefreshPlayers()
                end)
            end
            if not _fpPlayerRemovingConn then
                _fpPlayerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
                    fpProfileCache[plr.Name] = nil
                    if not FP.visible then return end
                    task.wait(0.3)
                    fpRefreshPlayers()
                end)
            end
        else
            -- hide but keep connections alive for next open
            if FP.win then
                FP.win.Size = UDim2.new(0, FP_W, 0, fpCalcHeight(0))
            end
        end
    end

    CreateToggle(UtilsTab.scroll, "Fast Panel", "Quick admin command panel for all players", function(v)
        fpShow(v)
    end)
end

CreateSection(UtilsTab.scroll, "SERVER")
CreateButton(UtilsTab.scroll, "Rejoin Server", nil, function()
    local ts = game:GetService("TeleportService")
    ts:Teleport(game.PlaceId, Players.LocalPlayer)
end)

ActivateTab(BrainrotsTab)
FH_ApplyLoadedKeybinds()

local BW_SEQ = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(110, 110, 110)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(110, 110, 110)),
})

local BANNER_W = WIN_W
local BANNER_H = isMobile and 30 or 44
local logoSize = isMobile and 20 or 30
local oD1   = isMobile and 30  or 48
local oHub  = isMobile and 34  or 56
local wHub  = isMobile and 64  or 150
local oD2   = isMobile and 102 or 206
local oFps  = isMobile and 106 or 216
local wFps  = isMobile and 56  or 104
local oD3   = isMobile and 166 or 326
local oStat = isMobile and 170 or 336
local wStat = isMobile and 52  or 72
local statH = isMobile and 20  or 26

Banner = Instance.new("Frame")
Banner.Name                   = "FadedFlashBanner"
Banner.Size                   = UDim2.new(0, BANNER_W, 0, BANNER_H)
Banner.AnchorPoint            = Vector2.new(0.5, 0)
Banner.Position               = UDim2.new(0.5, 0, 0.5, WIN_H/2 + 210)
Banner.BackgroundColor3       = T.Header
Banner.BackgroundTransparency = 0.08
Banner.BorderSizePixel        = 0
Banner.ZIndex                 = 9
Banner.ClipsDescendants       = true
Banner.Parent                 = GUI
Corner(Banner, 14)
local BannerStroke = Instance.new("UIStroke")
BannerStroke.Thickness       = 1.4
BannerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BannerStroke.Color           = Color3.fromRGB(255, 255, 255)
BannerStroke.Parent          = Banner
local BannerGrad = Instance.new("UIGradient")
BannerGrad.Color    = BW_SEQ
BannerGrad.Rotation = 90
BannerGrad.Parent   = BannerStroke

local LogoBox = Instance.new("Frame")
LogoBox.Size             = UDim2.new(0, logoSize, 0, logoSize)
LogoBox.Position         = UDim2.new(0, isMobile and 6 or 10, 0.5, -logoSize/2)
LogoBox.BackgroundColor3 = T.White
LogoBox.BorderSizePixel  = 0
LogoBox.ZIndex           = 10
LogoBox.Active           = isMobile
LogoBox.Parent           = Banner
Corner(LogoBox, 8)
local LogoF = Label(LogoBox, "F", isMobile and 13 or 18, Color3.fromRGB(12, 12, 12), Enum.Font.GothamBlack)
LogoF.Size           = UDim2.new(1, 0, 1, 0)
LogoF.Position       = UDim2.new(0, 0, 0, -1)
LogoF.TextXAlignment = Enum.TextXAlignment.Center
LogoF.TextYAlignment = Enum.TextYAlignment.Center
LogoF.ZIndex         = 11
if isMobile then
    local _logoTouchStart = nil
    LogoBox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            _logoTouchStart = inp.Position
        end
    end)
    LogoBox.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _logoTouchStart then
            local mag = (inp.Position - _logoTouchStart).Magnitude
            _logoTouchStart = nil
            if mag < 12 then
                Tween(LogoBox, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(180, 180, 180)})
                task.delay(0.12, function()
                    Tween(LogoBox, TweenInfo.new(0.12), {BackgroundColor3 = T.White})
                end)
                task.defer(function() setUIVisible(not _uiVisible) end)
            end
        end
    end)
end

local function BannerDivider(x)
    local d = Instance.new("Frame")
    d.Size             = UDim2.new(0, 1, 0, BANNER_H - 16)
    d.Position         = UDim2.new(0, x, 0.5, -(BANNER_H - 16)/2)
    d.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    d.BorderSizePixel  = 0
    d.ZIndex           = 10
    d.Parent           = Banner
end
BannerDivider(oD1); BannerDivider(oD2); BannerDivider(oD3)

local HubLabel = Label(Banner, "Faded Flash", isMobile and 10 or 13, T.White, Enum.Font.GothamBold)
HubLabel.Size           = UDim2.new(0, wHub, 1, 0)
HubLabel.Position       = UDim2.new(0, oHub, 0, 0)
HubLabel.TextXAlignment = Enum.TextXAlignment.Left
HubLabel.TextYAlignment = Enum.TextYAlignment.Center
HubLabel.ZIndex         = 10

local FPSLabel = Label(Banner, "FPS: --", isMobile and 9 or 12, T.White, Enum.Font.GothamBold)
FPSLabel.Size           = UDim2.new(0, wFps, 0.5, 0)
FPSLabel.Position       = UDim2.new(0, oFps, 0, 4)
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.ZIndex         = 10

local PINGLabel = Label(Banner, "PING: --ms", isMobile and 9 or 12, Color3.fromRGB(180, 180, 180), Enum.Font.GothamBold)
PINGLabel.Size           = UDim2.new(0, wFps, 0.5, 0)
PINGLabel.Position       = UDim2.new(0, oFps, 0.5, -4)
PINGLabel.TextXAlignment = Enum.TextXAlignment.Left
PINGLabel.ZIndex         = 10

local StatusBadge = Instance.new("Frame")
StatusBadge.Size             = UDim2.new(0, wStat, 0, statH)
StatusBadge.Position         = UDim2.new(0, oStat, 0.5, -statH/2 + 2)
StatusBadge.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
StatusBadge.BorderSizePixel  = 0
StatusBadge.ZIndex           = 10
StatusBadge.Parent           = Banner
Corner(StatusBadge, 7)
Stroke(StatusBadge, Color3.fromRGB(90, 90, 90), 1)
local StatusLbl = Label(StatusBadge, "â— LIVE", isMobile and 9 or 11, T.White, Enum.Font.GothamBold)
StatusLbl.Size           = UDim2.new(1, 0, 1, 0)
StatusLbl.TextXAlignment = Enum.TextXAlignment.Center
StatusLbl.TextYAlignment = Enum.TextYAlignment.Center
StatusLbl.ZIndex         = 11

if isMobile then
    local MB_H      = 34
    local MB_GAP    = 6
    local MB_PAD    = 8
    local MB_RADIUS = 10
    local MB_ABOVE  = 8

    local MobileBar = Instance.new("Frame")
    MobileBar.Name                   = "FadedFlashMobileBar"
    MobileBar.AnchorPoint            = Vector2.new(0.5, 1)
    MobileBar.Position               = UDim2.new(0.5, 0, 0.5, WIN_H/2 + 240 - MB_ABOVE)
    MobileBar.Size                   = UDim2.new(0, BANNER_W, 0, MB_H)
    MobileBar.BackgroundColor3       = T.Header
    MobileBar.BackgroundTransparency = 0.08
    MobileBar.BorderSizePixel        = 0
    MobileBar.ZIndex                 = 9
    MobileBar.Parent                 = GUI
    Corner(MobileBar, MB_RADIUS)
    local MBStroke = Instance.new("UIStroke")
    MBStroke.Thickness       = 1.4
    MBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MBStroke.Color           = Color3.fromRGB(255, 255, 255)
    MBStroke.Parent          = MobileBar
    local MBGrad = Instance.new("UIGradient")
    MBGrad.Color    = BW_SEQ
    MBGrad.Rotation = 90
    MBGrad.Parent   = MBStroke
    local MBLayout = Instance.new("UIListLayout")
    MBLayout.FillDirection       = Enum.FillDirection.Horizontal
    MBLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    MBLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    MBLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    MBLayout.Padding             = UDim.new(0, MB_GAP)
    MBLayout.Parent              = MobileBar
    local mbPad = Instance.new("UIPadding")
    mbPad.PaddingLeft  = UDim.new(0, MB_PAD)
    mbPad.PaddingRight = UDim.new(0, MB_PAD)
    mbPad.Parent       = MobileBar

    local function makeMobileBtn(text, order, accentCol, onFire)
        local btn = Instance.new("TextButton")
        btn.Name             = "MB_" .. text
        btn.LayoutOrder      = order
        btn.Size             = UDim2.new(0, 0, 0, 24)
        btn.AutomaticSize    = Enum.AutomaticSize.X
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        btn.Text             = text
        btn.TextSize         = 10
        btn.Font             = Enum.Font.GothamBold
        btn.TextColor3       = T.White
        btn.ZIndex           = 10
        btn.Active           = true
        btn.Parent           = MobileBar
        Corner(btn, 7)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft  = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent       = btn
        local st = Stroke(btn, accentCol or T.Border, 1)
        local _busy = false
        local _touchStart = nil
        local function _fireBtn()
            if _busy then return end
            _busy = true
            btn.BackgroundColor3 = T.White
            btn.TextColor3       = Color3.fromRGB(15, 15, 15)
            Tween(st, F, {Color = T.White})
            task.delay(0.16, function()
                Tween(btn, M, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)})
                Tween(st, M, {Color = accentCol or T.Border})
                btn.TextColor3 = T.White
                _busy = false
            end)
            if onFire then task.spawn(function() pcall(onFire) end) end
        end
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                _touchStart = inp.Position
            elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
                _fireBtn()
            end
        end)
        btn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch and _touchStart then
                local mag = (inp.Position - _touchStart).Magnitude
                _touchStart = nil
                if mag < 20 then _fireBtn() end
            end
        end)
        return btn
    end

    makeMobileBtn("RESET", 1, Color3.fromRGB(70, 70, 70), function()
        if _G._FH_ResetBtnEntry then pcall(_G._FH_ResetBtnEntry.fire) end
    end)
    makeMobileBtn("FLASH", 2, Color3.fromRGB(90, 130, 200), function()
        if _G._FH_FlashBtnEntry then pcall(_G._FH_FlashBtnEntry.fire) end
    end)
    makeMobileBtn("BLOCK", 3, Color3.fromRGB(180, 60, 60), function()
        if _G._FH_BlockBtnEntry then pcall(_G._FH_BlockBtnEntry.fire) end
    end)
end

local _uiAnimating = false
local SHOW_INFO = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HIDE_INFO = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
setUIVisible = function(v)
    if _uiAnimating or v == _uiVisible then return end
    _uiVisible   = v
    _uiAnimating = true
    if v then
        winScale.Scale = 0
        Win.Visible    = true
        local tw = TweenService:Create(winScale, SHOW_INFO, {Scale = 1})
        tw:Play()
        tw.Completed:Connect(function() _uiAnimating = false end)
    else
        local tw = TweenService:Create(winScale, HIDE_INFO, {Scale = 0})
        tw:Play()
        tw.Completed:Connect(function()
            Win.Visible  = false
            _uiAnimating = false
        end)
    end
end
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.LeftControl
    or inp.KeyCode == Enum.KeyCode.RightControl then
        setUIVisible(not _uiVisible)
    end
end)

local _fpsFrames, _fpsClock = 0, 0
RunService.RenderStepped:Connect(function(dt)
    BorderGrad.Rotation = (BorderGrad.Rotation + dt * 60) % 360
    BannerGrad.Rotation = (BannerGrad.Rotation + dt * 60) % 360
    _fpsFrames = _fpsFrames + 1
    _fpsClock  = _fpsClock + dt
    if _fpsClock >= 0.5 then
        FPSLabel.Text = "FPS: " .. math.floor(_fpsFrames / _fpsClock)
        _fpsFrames, _fpsClock = 0, 0
        local ping = 0
        pcall(function() ping = math.floor((Players.LocalPlayer:GetNetworkPing() or 0) * 1000) end)
        PINGLabel.Text = "PING: " .. ping .. "ms"
    end
end)

ShowToggleNotification("Faded Flash loaded", true)
