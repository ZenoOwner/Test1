--[[
    NATURE DUELS  BY @Naturedev and ghost  FIXED Bugs
    Â· Theme picker   Added by @NatureDev (theme switch bug FIXED)
    Â· GUI Scale     Added by @Naturedev
    Â· Keybinds      Added By @Naturedev
    Â· Auto Config   Made By @Naturedev
    Â· Auto Grab   Fixed By @Ghost    (radius + delay settings)
    Â· Inf Jump    Fixed respawn-on-steal bug

    FIX SUMMARY:
    1. startPatrol / stopPatrol / startStealLoop / stopStealLoop moved to
       module scope so they survive GUI rebuilds on theme/scale change.
    2. globalKeybindConn / heartbeatConn / statusBarConn are disconnected
       before every rebuild, preventing duplicate listeners.
    3. ApplyTheme no longer sets _savedConfig.toggles = nil, so active
       toggles are preserved visually after a theme switch.
    4. Toggle state-setter upvalues (ssF, ssAR, ...) are always valid
       because they are module-level and reassigned inside BuildMainGUI.
    5. Inf Jump no longer forces Freefall state override during steal
       interactions, preventing accidental respawn triggers.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local UIS          = game:GetService("UserInputService")
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local player       = Players.LocalPlayer
local ParentUI     = (gethui and gethui()) or game:GetService("CoreGui")

-- ============================================================
--  THEMES
-- ============================================================
local Themes = {
    Blue = {
        bg0=Color3.fromRGB(4,6,16), bg1=Color3.fromRGB(7,12,28),
        bg2=Color3.fromRGB(10,18,40), bg3=Color3.fromRGB(16,26,56),
        ac0=Color3.fromRGB(100,180,255), ac1=Color3.fromRGB(60,140,245),
        ac2=Color3.fromRGB(30,90,200), ac3=Color3.fromRGB(14,42,110),
        acOff=Color3.fromRGB(8,20,58), border=Color3.fromRGB(50,120,240),
        borderDim=Color3.fromRGB(20,44,100), dot=Color3.fromRGB(60,130,230),
        dotBright=Color3.fromRGB(110,180,255), cyan=Color3.fromRGB(110,220,255),
        cyanDim=Color3.fromRGB(35,110,165), name="BLUE",
    },
    Green = {
        bg0=Color3.fromRGB(4,10,8), bg1=Color3.fromRGB(6,16,12),
        bg2=Color3.fromRGB(9,22,16), bg3=Color3.fromRGB(12,30,20),
        ac0=Color3.fromRGB(0,255,150), ac1=Color3.fromRGB(0,220,120),
        ac2=Color3.fromRGB(0,165,82), ac3=Color3.fromRGB(0,80,45),
        acOff=Color3.fromRGB(4,20,12), border=Color3.fromRGB(0,160,80),
        borderDim=Color3.fromRGB(8,44,28), dot=Color3.fromRGB(0,155,90),
        dotBright=Color3.fromRGB(0,235,145), cyan=Color3.fromRGB(70,255,210),
        cyanDim=Color3.fromRGB(12,110,78), name="GREEN",
    },
    Red = {
        bg0=Color3.fromRGB(16,4,4), bg1=Color3.fromRGB(24,7,7),
        bg2=Color3.fromRGB(34,10,10), bg3=Color3.fromRGB(48,14,14),
        ac0=Color3.fromRGB(255,90,90), ac1=Color3.fromRGB(230,55,55),
        ac2=Color3.fromRGB(185,28,28), ac3=Color3.fromRGB(100,14,14),
        acOff=Color3.fromRGB(38,8,8), border=Color3.fromRGB(215,45,45),
        borderDim=Color3.fromRGB(75,18,18), dot=Color3.fromRGB(195,45,45),
        dotBright=Color3.fromRGB(255,100,100), cyan=Color3.fromRGB(255,170,110),
        cyanDim=Color3.fromRGB(150,65,32), name="RED",
    },
    Dark = {
        bg0=Color3.fromRGB(4,4,6), bg1=Color3.fromRGB(8,8,12),
        bg2=Color3.fromRGB(13,13,18), bg3=Color3.fromRGB(20,20,28),
        ac0=Color3.fromRGB(200,205,220), ac1=Color3.fromRGB(155,162,182),
        ac2=Color3.fromRGB(100,107,130), ac3=Color3.fromRGB(48,52,66),
        acOff=Color3.fromRGB(16,16,24), border=Color3.fromRGB(90,97,125),
        borderDim=Color3.fromRGB(30,33,48), dot=Color3.fromRGB(78,84,112),
        dotBright=Color3.fromRGB(145,152,180), cyan=Color3.fromRGB(190,210,240),
        cyanDim=Color3.fromRGB(75,86,118), name="DARK",
    },
}
local txtPrime  = Color3.fromRGB(225,236,252)
local txtSub    = Color3.fromRGB(135,152,180)
local txtMute   = Color3.fromRGB(65,78,108)
local inactive  = Color3.fromRGB(44,54,84)
local warn      = Color3.fromRGB(255,200,60)

-- ============================================================
--  ALL GLOBAL STATE
-- ============================================================
local T                    = Themes.Dark
local currentThemeName     = "Dark"
local isMobile             = false
local guiScale             = 1.0
local patrolMode           = "none"
local floating             = false
local currentWaypoint      = 1
local heartbeatConn        = nil
local statusBarConn        = nil
local globalKeybindConn    = nil
local waitingForCountdownL = false
local waitingForCountdownR = false
local AUTO_START_DELAY     = 0.7
local batAimbotActive      = false
local batAimbotConn        = nil
local AimbotRadius         = 100
local BatAimbotSpeed       = 55
local spinActive           = false
local spinAngle            = 0
local spinSpeed            = 20
local spinAlign, spinAttachment, spinConn = nil,nil,nil
local stealSpeedActive     = false
local stealSpeedConn       = nil
local STEAL_SPEED_VALUE    = 29
local STEAL_DST            = 10
local STEAL_SPD            = 29
local antiRagdollActive    = false
local antiRagdollConn      = nil
local unwalkActive         = false
local unwalkConn           = nil
local antiFlingActive      = false
local antiFlingConn        = nil
local infJumpActive        = false
local infJumpConn          = nil
local infJumpFallConn      = nil
local stealActive          = false
local isStealing           = false
local stealLoopRunning     = false
local stealThread          = nil
local stealConn            = nil
local autoGrabActive       = false
local autoGrabConn         = nil
local AUTO_GRAB_RADIUS     = 15
local AUTO_GRAB_DELAY      = 0.3
local _wfConns             = {}
local _wfActive            = false
local tauntActive          = false
local tauntLoop            = nil
local HideKeybind          = Enum.KeyCode.RightControl
local patrolRightSpeed     = 60
local patrolLeftSpeed      = 60
local FeatureKeybinds      = {}
local MobileShortcuts      = {}
local FeatureStates        = {}

local ssF, ssAR, ssAL, ssAim, ssDr, ssAF, ssARag, ssSp, ssUw, ssSt, ssSspd, ssTnt, ssGrab, ssIJ =
    function()end, function()end, function()end, function()end, function()end,
    function()end, function()end, function()end, function()end, function()end,
    function()end, function()end, function()end, function()end

local toggleSetState = {}
local SBStatus, SBFill, sbDots, SBRadVal, SBSecVal
local isSt = false
local bindCallbacks = {}
local registeredDotSets = {}

local SlapList = {
    {1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},{5,"Diamond Slap"},
    {6,"Emerald Slap"},{7,"Ruby Slap"},{8,"Dark Matter Slap"},{9,"Flame Slap"},
    {10,"Nuclear Slap"},{11,"Galaxy Slap"},{12,"Glitched Slap"}
}

-- ============================================================
--  SCALE HELPER
-- ============================================================
local function S(v) return math.floor(v * guiScale) end

-- ============================================================
--  CONFIG
-- ============================================================
local CONFIG_FILE = "NatureDuels_config.json"

local function SaveConfig()
    if not writefile then return end
    local keybindNames = {}
    for id, kc in pairs(FeatureKeybinds) do keybindNames[id] = kc.Name end
    local data = {
        theme      = currentThemeName,
        scale      = guiScale,
        rightSpeed = patrolRightSpeed,
        leftSpeed  = patrolLeftSpeed,
        toggles    = {
            antiFling = antiFlingActive,
            antiRag   = antiRagdollActive,
            infJump   = infJumpActive,
            spinBot   = spinActive,
            unwalk    = unwalkActive,
            stealSpd  = stealSpeedActive,
            taunt     = tauntActive,
            autoGrab  = autoGrabActive,
        },
        autoGrabRadius = AUTO_GRAB_RADIUS,
        autoGrabDelay  = AUTO_GRAB_DELAY,
        stealDst       = STEAL_DST,
        stealSpd       = STEAL_SPD,
        keybinds  = keybindNames,
        shortcuts = MobileShortcuts,
    }
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end)
end

local _savedConfig = nil
local function LoadConfig()
    if not readfile then return end
    pcall(function()
        local raw = readfile(CONFIG_FILE)
        if raw and raw ~= "" then _savedConfig = HttpService:JSONDecode(raw) end
    end)
end

local function ApplyConfigToState(cfg)
    if not cfg then return end
    if cfg.theme and Themes[cfg.theme] then T = Themes[cfg.theme]; currentThemeName = cfg.theme end
    if cfg.scale then guiScale = math.clamp(cfg.scale, 0.5, 2.0) end
    if cfg.rightSpeed then patrolRightSpeed = cfg.rightSpeed end
    if cfg.leftSpeed  then patrolLeftSpeed  = cfg.leftSpeed  end
    if cfg.toggles then
        if cfg.toggles.antiFling then antiFlingActive   = cfg.toggles.antiFling end
        if cfg.toggles.antiRag   then antiRagdollActive = cfg.toggles.antiRag   end
        if cfg.toggles.infJump   then infJumpActive     = cfg.toggles.infJump   end
        if cfg.toggles.spinBot   then spinActive        = cfg.toggles.spinBot   end
        if cfg.toggles.unwalk    then unwalkActive      = cfg.toggles.unwalk    end
        if cfg.toggles.stealSpd  then stealSpeedActive  = cfg.toggles.stealSpd  end
        if cfg.toggles.taunt     then tauntActive       = cfg.toggles.taunt     end
        if cfg.toggles.autoGrab  then autoGrabActive    = cfg.toggles.autoGrab  end
    end
    if cfg.autoGrabRadius then AUTO_GRAB_RADIUS = math.clamp(cfg.autoGrabRadius, 1, 100) end
    if cfg.autoGrabDelay  then AUTO_GRAB_DELAY  = math.clamp(cfg.autoGrabDelay, 0.05, 5) end
    if cfg.stealDst       then STEAL_DST        = math.clamp(cfg.stealDst, 1, 200) end
    if cfg.stealSpd       then STEAL_SPD        = math.clamp(cfg.stealSpd, 1, 200) end
    if cfg.keybinds then
        for id, name in pairs(cfg.keybinds) do
            local ok, kc = pcall(function() return Enum.KeyCode[name] end)
            if ok and kc then FeatureKeybinds[id] = kc end
        end
    end
    if cfg.shortcuts and type(cfg.shortcuts) == "table" then MobileShortcuts = cfg.shortcuts end
end

LoadConfig()
ApplyConfigToState(_savedConfig)

-- ============================================================
--  WAYPOINTS
-- ============================================================
local rightWaypoints = {
    Vector3.new(-473.04,-6.99,29.71), Vector3.new(-483.57,-5.10,18.74),
    Vector3.new(-475.00,-6.99,26.43), Vector3.new(-474.67,-6.94,105.48),
}
local leftWaypoints = {
    Vector3.new(-472.49,-7.00,90.62), Vector3.new(-484.62,-5.10,100.37),
    Vector3.new(-475.08,-7.00,93.29), Vector3.new(-474.22,-6.96,16.18),
}

-- ============================================================
--  TWEEN
-- ============================================================
local function Tw(obj,t,props,style,dir)
    style = style or Enum.EasingStyle.Quint
    dir   = dir   or Enum.EasingDirection.Out
    pcall(function() TweenService:Create(obj,TweenInfo.new(t,style,dir),props):Play() end)
end

-- ============================================================
--  LOGIC HELPERS
-- ============================================================
local function GetChar()  return player.Character end
local function GetHum()   local c=GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot()  local c=GetChar(); return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")) end

-- ============================================================
--  DISCORD LABEL ABOVE PLAYER
-- ============================================================
local function CreateDiscordLabel()
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local existing = head:FindFirstChild("DiscordBillboard")
    if existing then existing:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DiscordBillboard"
    billboard.Size = UDim2.new(0, 400, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 2.0, 0)
    billboard.AlwaysOnTop = false
    billboard.ResetOnSpawn = false
    billboard.Parent = head

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Nature Duels"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 0.45
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 28
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextScaled = false
    titleLabel.Parent = billboard

    local dcLabel = Instance.new("TextLabel")
    dcLabel.Size = UDim2.new(1, 0, 0.5, 0)
    dcLabel.Position = UDim2.new(0, 0, 0.5, 0)
    dcLabel.BackgroundTransparency = 1
    dcLabel.Text = "discord.gg/vM4sAXSZdY"
    dcLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dcLabel.TextTransparency = 0.45
    dcLabel.Font = Enum.Font.GothamBold
    dcLabel.TextSize = 24
    dcLabel.TextXAlignment = Enum.TextXAlignment.Center
    dcLabel.TextScaled = false
    dcLabel.Parent = billboard
end

CreateDiscordLabel()
player.CharacterAdded:Connect(function()
    task.wait(1)
    CreateDiscordLabel()
end)

-- ============================================================
--  SPIN BOT / STEAL SPEED / ANTI RAGDOLL / UNWALK / ANTI FLING / INF JUMP
-- ============================================================
local function setupSpinBot()
    local hrp=GetRoot(); if not hrp then return end
    if spinAlign then pcall(function() spinAlign:Destroy() end) end
    if spinAttachment then pcall(function() spinAttachment:Destroy() end) end
    spinAttachment=Instance.new("Attachment"); spinAttachment.Parent=hrp
    spinAlign=Instance.new("AlignOrientation")
    spinAlign.Attachment0=spinAttachment
    spinAlign.Mode=Enum.OrientationAlignmentMode.OneAttachment
    spinAlign.Responsiveness=30; spinAlign.MaxTorque=math.huge
    spinAlign.RigidityEnabled=false; spinAlign.Enabled=false; spinAlign.Parent=hrp
end
local function startSpinBot()
    setupSpinBot(); if spinAlign then spinAlign.Enabled=true end
    if spinConn then spinConn:Disconnect() end
    spinConn=RunService.Heartbeat:Connect(function(dt)
        if not spinActive then return end
        if not spinAlign or not spinAlign.Parent then setupSpinBot(); if spinAlign then spinAlign.Enabled=true end return end
        spinAngle=spinAngle+spinSpeed*dt; spinAlign.CFrame=CFrame.Angles(0,spinAngle,0)
    end)
end
local function stopSpinBot()
    spinActive=false
    if spinConn then spinConn:Disconnect(); spinConn=nil end
    if spinAlign then pcall(function() spinAlign.Enabled=false end) end
end
local function startStealSpeed()
    if stealSpeedConn then stealSpeedConn:Disconnect() end
    stealSpeedConn=RunService.Heartbeat:Connect(function()
        if not stealSpeedActive then return end
        local hum=GetHum(); local root=GetRoot(); if not hum or not root then return end
        if hum.MoveDirection.Magnitude>0.1 then
            local md=hum.MoveDirection.Unit
            root.AssemblyLinearVelocity=Vector3.new(md.X*STEAL_SPEED_VALUE,root.AssemblyLinearVelocity.Y,md.Z*STEAL_SPEED_VALUE)
        end
    end)
end
local function stopStealSpeed() if stealSpeedConn then stealSpeedConn:Disconnect(); stealSpeedConn=nil end end
local function startAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect() end
    antiRagdollConn=RunService.Heartbeat:Connect(function()
        if not antiRagdollActive then return end
        local c=GetChar(); if not c then return end
        local hum=c:FindFirstChildOfClass("Humanoid"); local root=c:FindFirstChild("HumanoidRootPart")
        if hum then
            local s=hum:GetState()
            if s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject=hum end
                if root then root.Velocity=Vector3.zero; root.RotVelocity=Vector3.zero end
            end
        end
        for _,obj in ipairs(c:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
    end)
end
local function stopAntiRagdoll() if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn=nil end end
local function startUnwalk()
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn=RunService.Heartbeat:Connect(function()
        if not unwalkActive then return end
        local hum=GetHum(); if not hum then return end
        local anim=hum:FindFirstChildOfClass("Animator"); if not anim then return end
        for _,t in pairs(anim:GetPlayingAnimationTracks()) do t:Stop() end
    end)
end
local function stopUnwalk() if unwalkConn then unwalkConn:Disconnect(); unwalkConn=nil end end
local function startAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect() end
    antiFlingConn=RunService.Heartbeat:Connect(function()
        if not antiFlingActive then return end
        local root=GetRoot(); if not root then return end
        local vel=root.AssemblyLinearVelocity
        if vel.Magnitude>100 then root.AssemblyLinearVelocity=vel.Unit*100 end
    end)
end
local function stopAntiFling() if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn=nil end end

-- ============================================================
--  INF JUMP FIX
--  Root cause: the Heartbeat loop was calling ChangeState(Freefall)
--  on EVERY frame when the humanoid was in FallingDown / Ragdoll.
--  In "Steal a Brainrot" the game uses those states to signal a
--  respawn / death event.  Overriding them every frame prevented
--  the respawn from completing, leaving the character stuck, or
--  caused the game's own respawn timer to fire repeatedly.
--
--  Fix applied:
--  1. Only override FallingDown/Ragdoll once per state transition
--     (tracked with `lastOverrideState`), not on every heartbeat.
--  2. Never set AutoJumpEnabled = false globally; let the game
--     manage it â€” we only force the jump velocity ourselves.
--  3. Fall-speed clamp raised slightly (-90 â†’ gives more room)
--     and is only applied when the player is actually in Freefall,
--     not in other states the game may need intact.
-- ============================================================
local function startInfJump()
    if infJumpConn     then infJumpConn:Disconnect()     end
    if infJumpFallConn then infJumpFallConn:Disconnect() end

    -- Do NOT globally disable AutoJumpEnabled â€” it interferes with
    -- the game's respawn / platform logic.
    local jumping = false
    local lastOverrideState = nil   -- track last state we overrode

    infJumpConn = UIS.JumpRequest:Connect(function()
        if not infJumpActive then return end
        if jumping then return end
        jumping = true
        local h = GetHum(); local root = GetRoot()
        if not h or not root then jumping = false; return end
        root.AssemblyLinearVelocity = Vector3.new(
            root.AssemblyLinearVelocity.X, 50,
            root.AssemblyLinearVelocity.Z)
        h:ChangeState(Enum.HumanoidStateType.Jumping)
        task.delay(0.1, function() jumping = false end)
    end)

    infJumpFallConn = RunService.Heartbeat:Connect(function()
        if not infJumpActive then return end
        local h = GetHum(); local root = GetRoot()
        if not h or not root then return end

        -- Only cap fall speed while genuinely in Freefall â€” do NOT
        -- touch the state if the game put us in Ragdoll/FallingDown
        -- (those are used by the game for death/respawn sequences).
        local state = h:GetState()

        if state == Enum.HumanoidStateType.Freefall then
            lastOverrideState = nil   -- reset tracker; we're in a safe state
            local vel = root.AssemblyLinearVelocity
            if vel.Y < -90 then
                root.AssemblyLinearVelocity = Vector3.new(vel.X, -90, vel.Z)
            end

        elseif state == Enum.HumanoidStateType.FallingDown then
            -- Only override ONCE per FallingDown entry, not every frame.
            -- This lets the game's own respawn logic proceed if it needs to.
            if lastOverrideState ~= Enum.HumanoidStateType.FallingDown then
                lastOverrideState = Enum.HumanoidStateType.FallingDown
                h:ChangeState(Enum.HumanoidStateType.Freefall)
            end

        elseif state == Enum.HumanoidStateType.Ragdoll then
            -- Same one-shot override for Ragdoll.
            if lastOverrideState ~= Enum.HumanoidStateType.Ragdoll then
                lastOverrideState = Enum.HumanoidStateType.Ragdoll
                h:ChangeState(Enum.HumanoidStateType.Freefall)
            end

        else
            lastOverrideState = nil   -- any other state: let the game do its thing
        end
    end)
end

local function stopInfJump()
    if infJumpConn     then infJumpConn:Disconnect();     infJumpConn=nil     end
    if infJumpFallConn then infJumpFallConn:Disconnect(); infJumpFallConn=nil end
    -- Restore AutoJumpEnabled to its default (true)
    local hum = GetHum(); if hum then hum.AutoJumpEnabled = true end
end

local function getPromptPos(prompt)
    local p=prompt.Parent
    if p:IsA("BasePart") then return p.Position
    elseif p:IsA("Model") then local pp=p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart"); return pp and pp.Position
    elseif p:IsA("Attachment") then return p.WorldPosition
    else local part=p:FindFirstChildWhichIsA("BasePart",true); return part and part.Position end
end

local function firePrompt(prompt)
    if not prompt then return end
    task.spawn(function()
        pcall(function() fireproximityprompt(prompt,10000); prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd() end)
    end)
end

local function startAutoGrab()
    if autoGrabConn then pcall(task.cancel, autoGrabConn); autoGrabConn=nil end
    autoGrabConn = task.spawn(function()
        while autoGrabActive do
            pcall(function()
                local root = GetRoot()
                if root then
                    local myPos = root.Position
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            local at = obj.ActionText:lower()
                            if at == "grab" or at == "pick up" or at == "collect" or at == "take" then
                                local pos = getPromptPos(obj)
                                if pos and (myPos - pos).Magnitude <= AUTO_GRAB_RADIUS then
                                    firePrompt(obj)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(AUTO_GRAB_DELAY)
        end
    end)
end
local function stopAutoGrab()
    autoGrabActive = false
    if autoGrabConn then pcall(task.cancel, autoGrabConn); autoGrabConn = nil end
end

local function findNearestSteal()
    local root=GetRoot(); if not root then return nil end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local myPos=root.Position; local np,nd=nil,math.huge
    for _,plot in ipairs(plots:GetChildren()) do
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and obj.ActionText=="Steal" then
                local pos=getPromptPos(obj)
                if pos then local d=(myPos-pos).Magnitude; if d<=obj.MaxActivationDistance and d<nd then np=obj;nd=d end end
            end
        end
    end
    return np
end
local function findClosestStealAny()
    local root=GetRoot(); if not root then return nil,math.huge,10 end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil,math.huge,10 end
    local myPos=root.Position; local np,nd,mad=nil,math.huge,10
    for _,plot in ipairs(plots:GetChildren()) do
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and obj.ActionText=="Steal" then
                local pos=getPromptPos(obj)
                if pos then local d=(myPos-pos).Magnitude; if d<nd then np=obj;nd=d;mad=obj.MaxActivationDistance end end
            end
        end
    end
    return np,nd,mad
end

local function startWalkFling()
    _wfActive=true
    table.insert(_wfConns,RunService.Stepped:Connect(function()
        if not _wfActive then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end
            end
        end
    end))
    local co=coroutine.create(function()
        while _wfActive do
            RunService.Heartbeat:Wait(); local root=GetRoot()
            if not root then RunService.Heartbeat:Wait() continue end
            local vel=root.Velocity; root.Velocity=vel*10000+Vector3.new(0,10000,0)
            RunService.RenderStepped:Wait(); if root and root.Parent then root.Velocity=vel end
            RunService.Stepped:Wait(); if root and root.Parent then root.Velocity=vel+Vector3.new(0,0.1,0) end
        end
    end)
    coroutine.resume(co); table.insert(_wfConns,co)
end
local function stopWalkFling()
    _wfActive=false
    for _,c in ipairs(_wfConns) do
        if typeof(c)=="RBXScriptConnection" then c:Disconnect()
        elseif typeof(c)=="thread" then pcall(task.cancel,c) end
    end
    _wfConns={}
end
local function findBat()
    local c=GetChar(); if not c then return end
    local bp=player:FindFirstChildOfClass("Backpack")
    for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    for _,i in ipairs(SlapList) do local t=c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2])); if t then return t end end
end
local function findNearestEnemy(myHRP)
    local nearest,nearestDist,nearestTorso=nil,math.huge,nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local eh=p.Character:FindFirstChild("HumanoidRootPart")
            local torso=p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health>0 then
                local d=(eh.Position-myHRP.Position).Magnitude
                if d<nearestDist and d<=AimbotRadius then nearestDist=d;nearest=eh;nearestTorso=torso or eh end
            end
        end
    end
    return nearest,nearestDist,nearestTorso
end
local function startBatAimbot()
    if batAimbotConn then return end
    batAimbotConn=RunService.Heartbeat:Connect(function()
        local c=GetChar(); if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local bat=findBat(); if bat and bat.Parent~=c then hum:EquipTool(bat) end
        local target,_,torso=findNearestEnemy(h)
        if target and torso then
            local pred=torso.Position+(torso.AssemblyLinearVelocity*0.13)
            local dir=pred-h.Position
            if Vector3.new(dir.X,0,dir.Z).Magnitude>0 then hum.AutoRotate=true end
            if dir.Magnitude>1.5 then h.AssemblyLinearVelocity=dir.Unit*BatAimbotSpeed
            else h.AssemblyLinearVelocity=target.AssemblyLinearVelocity end
        end
    end)
end
local function stopBatAimbot() if batAimbotConn then batAimbotConn:Disconnect(); batAimbotConn=nil end end

local function isCountdownNum(text) local n=tonumber(text); return n and n>=1 and n<=5, n end
local function isTimerCountdown(label)
    if not label then return false end
    local ok,n=isCountdownNum(label.Text); return ok and n>=1 and n<=5
end
local function getCurrentSpeed()
    if patrolMode=="right" then return (currentWaypoint>=3) and 29.4 or patrolRightSpeed
    elseif patrolMode=="left" then return (currentWaypoint>=3) and 29.4 or patrolLeftSpeed end
    return 0
end
local function getCurrentWaypoints()
    if patrolMode=="right" then return rightWaypoints
    elseif patrolMode=="left" then return leftWaypoints end
    return {}
end
local function updateWalking()
    local root=GetRoot(); if not root then return end
    local vel=root.AssemblyLinearVelocity
    if floating then
        local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances={GetChar()}
        local res=workspace:Raycast(root.Position,Vector3.new(0,-50,0),rp)
        if res then
            local diff=(res.Position.Y+8)-root.Position.Y
            if math.abs(diff)>0.3 then root.AssemblyLinearVelocity=Vector3.new(vel.X,diff*15,vel.Z)
            else root.AssemblyLinearVelocity=Vector3.new(vel.X,0,vel.Z) end
        end
    end
    if patrolMode~="none" then
        local wp=getCurrentWaypoints(); local tgt=wp[currentWaypoint]; local cur=root.Position
        local tXZ=Vector3.new(tgt.X,0,tgt.Z); local cXZ=Vector3.new(cur.X,0,cur.Z); local dXZ=(tXZ-cXZ).Magnitude
        if dXZ>3 then
            local md=(tXZ-cXZ).Unit; local spd=getCurrentSpeed()
            root.AssemblyLinearVelocity=Vector3.new(md.X*spd,root.AssemblyLinearVelocity.Y,md.Z*spd)
        else
            if currentWaypoint==#wp then currentWaypoint=1; root.AssemblyLinearVelocity=Vector3.new(0,root.AssemblyLinearVelocity.Y,0)
            else currentWaypoint=currentWaypoint+1 end
        end
    end
end

-- ============================================================
--  MODULE-LEVEL startPatrol / stopPatrol
-- ============================================================
startPatrol = function(mode)
    patrolMode=mode; currentWaypoint=1
    if mode=="right" then ssAR(true); FeatureStates.autoR=true
    else ssAL(true); FeatureStates.autoL=true end
end
stopPatrol = function()
    patrolMode="none"; currentWaypoint=1; waitingForCountdownL=false; waitingForCountdownR=false
    ssAR(false); ssAL(false); FeatureStates.autoR=false; FeatureStates.autoL=false
    local root=GetRoot(); if root then root.AssemblyLinearVelocity=Vector3.new(0,root.AssemblyLinearVelocity.Y,0) end
end

-- ============================================================
--  MODULE-LEVEL startStealLoop / stopStealLoop
-- ============================================================
local function indicateGrab()
    isSt=true; isStealing=true
    if SBStatus then SBStatus.Text="GRAB!"; SBStatus.TextColor3=T.ac0 end
    if sbDots then for _,d in ipairs(sbDots) do d.BackgroundColor3=T.ac0; d.BackgroundTransparency=0 end end
    if SBFill then Tw(SBFill,0.1,{Size=UDim2.new(1,0,1,0)}) end
    task.delay(0.25,function() isSt=false; isStealing=false end)
end

local function stealLoopFn()
    while stealActive do
        local hum=GetHum()
        if hum and hum.WalkSpeed>=STEAL_SPD then
            local prompt=findNearestSteal()
            if prompt then
                local pos=getPromptPos(prompt); local root=GetRoot()
                local dist=root and pos and (root.Position-pos).Magnitude or math.huge
                if dist<=STEAL_DST then task.wait(0.1); firePrompt(prompt); indicateGrab() end
            end
        end
        task.wait(0.3)
    end
    stealLoopRunning=false
end

startStealLoop = function()
    if stealLoopRunning then return end
    stealLoopRunning=true; stealThread=task.spawn(stealLoopFn)
end
stopStealLoop = function()
    stealLoopRunning=false
    if stealThread then task.cancel(stealThread); stealThread=nil end
    if stealConn then stealConn:Disconnect(); stealConn=nil end
    isStealing=false; isSt=false
end

-- ============================================================
--  DRAG
-- ============================================================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos, lastInput
    local DragThreshold = 6
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false; dragStart=i.Position; startPos=frame.Position
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            lastInput=i
            if dragStart and not dragging then
                local d=i.Position-dragStart
                if math.abs(d.X)>DragThreshold or math.abs(d.Y)>DragThreshold then dragging=true end
            end
            if dragging and lastInput then
                local d=lastInput.Position-dragStart
                frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and lastInput and i==lastInput then
            local d=i.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false; dragStart=nil
        end
    end)
end

-- ============================================================
--  DOTS BACKGROUND
-- ============================================================
local function MakeDotsBackground(parent)
    local canvas=Instance.new("Frame",parent)
    canvas.Size=UDim2.new(1,0,1,0); canvas.BackgroundTransparency=1
    canvas.ZIndex=0; canvas.Name="DotsCanvas"; canvas.ClipsDescendants=true; canvas.Interactable=false
    local DOT_COUNT = isMobile and 14 or 22
    local dots={}
    for i=1,DOT_COUNT do
        local sz=math.random(2,5)
        local dot=Instance.new("Frame",canvas)
        dot.Size=UDim2.new(0,sz,0,sz)
        dot.Position=UDim2.new(math.random(0,100)/100,0,math.random(0,100)/100,0)
        dot.BackgroundColor3=(math.random()>0.5) and T.dot or T.dotBright
        dot.BackgroundTransparency=math.random(40,75)/100
        dot.BorderSizePixel=0; dot.Interactable=false
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local dirX=(math.random()-0.5)*0.0018; local dirY=(math.random()-0.5)*0.0018
        local phase=math.random(0,628)/100; local pulseS=math.random(7,15)/10
        table.insert(dots,{frame=dot,dirX=dirX,dirY=dirY,phase=phase,pulseS=pulseS,px=dot.Position.X.Scale,py=dot.Position.Y.Scale})
    end
    local t=0
    local conn=RunService.Heartbeat:Connect(function(dt)
        if not canvas.Parent then return end
        t=t+dt
        for _,d in ipairs(dots) do
            d.px=d.px+d.dirX*dt*6; d.py=d.py+d.dirY*dt*6
            if d.px>1.05 then d.px=-0.05 elseif d.px<-0.05 then d.px=1.05 end
            if d.py>1.05 then d.py=-0.05 elseif d.py<-0.05 then d.py=1.05 end
            local pulse=0.5+0.4*math.sin(t*d.pulseS+d.phase)
            d.frame.Position=UDim2.new(d.px,0,d.py,0)
            d.frame.BackgroundTransparency=0.15+pulse*0.7
        end
    end)
    canvas.AncestryChanged:Connect(function() if not canvas.Parent then pcall(function() conn:Disconnect() end) end end)
    table.insert(registeredDotSets,dots)
    return canvas,dots
end

-- ============================================================
--  BuildMainGUI forward declaration
-- ============================================================
local BuildMainGUI

-- ============================================================
--  APPLY THEME
-- ============================================================
local function ApplyTheme(name)
    T = Themes[name]; currentThemeName = name
    SaveConfig()
    task.spawn(function()
        task.wait(0.08)
        if heartbeatConn    then heartbeatConn:Disconnect();    heartbeatConn=nil    end
        if statusBarConn    then statusBarConn:Disconnect();    statusBarConn=nil    end
        if globalKeybindConn then globalKeybindConn:Disconnect(); globalKeybindConn=nil end
        pcall(function() ParentUI:FindFirstChild("NatureDuels"):Destroy() end)
        BuildMainGUI()
    end)
end

-- ============================================================
--  UI BUILDERS
-- ============================================================
local function MakeSectionLabel(parent,text)
    local wrap=Instance.new("Frame",parent)
    wrap.Size=UDim2.new(1,0,0,S(18)); wrap.BackgroundTransparency=1
    local lbl=Instance.new("TextLabel",wrap)
    lbl.Size=UDim2.new(1,-8,1,0); lbl.Position=UDim2.new(0,4,0,0)
    lbl.BackgroundTransparency=1; lbl.Text="â—† "..text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=S(isMobile and 8 or 9)
    lbl.TextColor3=T.ac1; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",wrap)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=T.ac3; line.BackgroundTransparency=0.1; line.BorderSizePixel=0
    Instance.new("UICorner",line).CornerRadius=UDim.new(1,0)
    return wrap
end

local function MakeToggle(parent,labelText,featureId)
    local BTN_H=S(isMobile and 36 or 42); local FS=S(isMobile and 10 or 11)
    local card=Instance.new("TextButton",parent)
    card.Size=UDim2.new(1,0,0,BTN_H); card.BackgroundColor3=T.bg2; card.Text=""; card.BorderSizePixel=0; card.AutoButtonColor=false
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,S(10))
    local stroke=Instance.new("UIStroke",card); stroke.Color=T.borderDim; stroke.Thickness=1; stroke.Transparency=0.35
    local acBar=Instance.new("Frame",card)
    acBar.Size=UDim2.new(0,S(3),0,BTN_H-S(12)); acBar.Position=UDim2.new(0,0,0,S(6))
    acBar.BackgroundColor3=T.ac0; acBar.BackgroundTransparency=1; acBar.BorderSizePixel=0
    Instance.new("UICorner",acBar).CornerRadius=UDim.new(1,0)
    local trackW=Instance.new("Frame",card)
    trackW.Size=UDim2.new(0,S(30),0,S(16)); trackW.Position=UDim2.new(1,-S(38),0.5,-S(8))
    trackW.BackgroundColor3=T.bg3; trackW.BorderSizePixel=0
    Instance.new("UICorner",trackW).CornerRadius=UDim.new(1,0)
    local trackS=Instance.new("UIStroke",trackW); trackS.Color=T.borderDim; trackS.Thickness=1; trackS.Transparency=0.4
    local thumb=Instance.new("Frame",trackW)
    thumb.Size=UDim2.new(0,S(10),0,S(10)); thumb.Position=UDim2.new(0,S(3),0.5,-S(5))
    thumb.BackgroundColor3=inactive; thumb.BorderSizePixel=0
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame",card)
    dot.Size=UDim2.new(0,S(4),0,S(4)); dot.Position=UDim2.new(0,S(10),0.5,-S(2))
    dot.BackgroundColor3=inactive; dot.BackgroundTransparency=0.5; dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local kbBadge=Instance.new("TextLabel",card)
    kbBadge.Size=UDim2.new(0,S(32),0,S(13)); kbBadge.Position=UDim2.new(1,-S(74),0.5,-S(7))
    kbBadge.BackgroundColor3=T.bg3; kbBadge.Text=""; kbBadge.Font=Enum.Font.GothamBold
    kbBadge.TextSize=S(7); kbBadge.TextColor3=T.ac1; kbBadge.BackgroundTransparency=1
    kbBadge.BorderSizePixel=0; kbBadge.Visible=false
    Instance.new("UICorner",kbBadge).CornerRadius=UDim.new(0,3)
    Instance.new("UIStroke",kbBadge).Color=T.borderDim
    local lbl=Instance.new("TextLabel",card)
    lbl.Name="Label"; lbl.Size=UDim2.new(1,-S(54),1,0); lbl.Position=UDim2.new(0,S(18),0,0)
    lbl.BackgroundTransparency=1; lbl.Text=labelText; lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=FS; lbl.TextColor3=txtSub; lbl.TextXAlignment=Enum.TextXAlignment.Left
    card.MouseEnter:Connect(function() Tw(card,0.12,{BackgroundColor3=T.bg3}); Tw(stroke,0.12,{Transparency=0.05,Color=T.ac2}) end)
    card.MouseLeave:Connect(function() Tw(card,0.15,{BackgroundColor3=T.bg2}); Tw(stroke,0.15,{Transparency=0.35,Color=T.borderDim}) end)
    local function updateKbBadge()
        if featureId and FeatureKeybinds[featureId] then
            kbBadge.Text=FeatureKeybinds[featureId].Name; kbBadge.BackgroundTransparency=0.3; kbBadge.Visible=true
            lbl.Size=UDim2.new(1,-S(90),1,0)
        else
            kbBadge.Visible=false; kbBadge.BackgroundTransparency=1; lbl.Size=UDim2.new(1,-S(54),1,0)
        end
    end
    updateKbBadge()
    local function SetState(on)
        Tw(acBar,0.2,{BackgroundTransparency=on and 0 or 1})
        Tw(trackW,0.2,{BackgroundColor3=on and T.ac3 or T.bg3})
        Tw(trackS,0.2,{Color=on and T.ac1 or T.borderDim,Transparency=on and 0.1 or 0.4})
        Tw(thumb,0.2,{Position=on and UDim2.new(0,S(17),0.5,-S(5)) or UDim2.new(0,S(3),0.5,-S(5)),BackgroundColor3=on and T.ac0 or inactive})
        Tw(dot,0.2,{BackgroundColor3=on and T.ac0 or inactive,BackgroundTransparency=on and 0 or 0.5})
        Tw(lbl,0.2,{TextColor3=on and txtPrime or txtSub})
        Tw(card,0.2,{BackgroundColor3=on and T.acOff or T.bg2})
        Tw(stroke,0.2,{Color=on and T.ac2 or T.borderDim,Transparency=on and 0.15 or 0.35})
    end
    return card,SetState,lbl,updateKbBadge
end

local function MakeSpeedRow(parent,labelText,defaultSpeed,onChanged)
    local ROW_H=S(isMobile and 34 or 38); local FS=S(isMobile and 9 or 10); local BSIZE=S(isMobile and 20 or 22)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,ROW_H); row.BackgroundColor3=T.bg2; row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,S(9))
    Instance.new("UIStroke",row).Color=T.borderDim
    local acB=Instance.new("Frame",row)
    acB.Size=UDim2.new(0,S(3),0,ROW_H-S(10)); acB.Position=UDim2.new(0,0,0,S(5))
    acB.BackgroundColor3=T.cyan; acB.BackgroundTransparency=0.3; acB.BorderSizePixel=0
    Instance.new("UICorner",acB).CornerRadius=UDim.new(1,0)
    local nameL=Instance.new("TextLabel",row)
    nameL.Size=UDim2.new(0.42,0,1,0); nameL.Position=UDim2.new(0,S(10),0,0)
    nameL.BackgroundTransparency=1; nameL.Text=labelText; nameL.Font=Enum.Font.GothamBold
    nameL.TextSize=FS; nameL.TextColor3=txtSub; nameL.TextXAlignment=Enum.TextXAlignment.Left
    local mBtn=Instance.new("TextButton",row)
    mBtn.Size=UDim2.new(0,BSIZE,0,BSIZE); mBtn.Position=UDim2.new(0.48,0,0.5,-BSIZE/2)
    mBtn.BackgroundColor3=T.bg3; mBtn.Text="-"; mBtn.Font=Enum.Font.GothamBold
    mBtn.TextSize=FS+S(1); mBtn.TextColor3=T.ac1; mBtn.BorderSizePixel=0; mBtn.AutoButtonColor=false
    Instance.new("UICorner",mBtn).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",mBtn).Color=T.borderDim
    local vBox=Instance.new("TextBox",row)
    vBox.Size=UDim2.new(0,S(isMobile and 36 or 40),0,BSIZE); vBox.Position=UDim2.new(0.48,BSIZE+S(3),0.5,-BSIZE/2)
    vBox.BackgroundColor3=T.bg3; vBox.BorderSizePixel=0; vBox.Text=tostring(defaultSpeed)
    vBox.Font=Enum.Font.GothamBold; vBox.TextSize=FS; vBox.TextColor3=T.ac0; vBox.ClearTextOnFocus=false
    Instance.new("UICorner",vBox).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",vBox).Color=T.ac3
    local pBtn=Instance.new("TextButton",row)
    pBtn.Size=UDim2.new(0,BSIZE,0,BSIZE); pBtn.Position=UDim2.new(0.48,BSIZE+S(isMobile and 42 or 46),0.5,-BSIZE/2)
    pBtn.BackgroundColor3=T.bg3; pBtn.Text="+"; pBtn.Font=Enum.Font.GothamBold
    pBtn.TextSize=FS+S(1); pBtn.TextColor3=T.ac1; pBtn.BorderSizePixel=0; pBtn.AutoButtonColor=false
    Instance.new("UICorner",pBtn).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",pBtn).Color=T.borderDim
    for _,btn in ipairs({mBtn,pBtn}) do
        btn.MouseEnter:Connect(function() Tw(btn,0.1,{BackgroundColor3=T.ac3,TextColor3=T.ac0}) end)
        btn.MouseLeave:Connect(function() Tw(btn,0.1,{BackgroundColor3=T.bg3,TextColor3=T.ac1}) end)
    end
    local curVal=defaultSpeed
    local function clamp(v) v=math.clamp(math.floor(v),1,500); curVal=v; vBox.Text=tostring(v); if onChanged then onChanged(v) end end
    mBtn.MouseButton1Click:Connect(function() clamp(curVal-5) end)
    pBtn.MouseButton1Click:Connect(function() clamp(curVal+5) end)
    vBox.FocusLost:Connect(function() local n=tonumber(vBox.Text); if n then clamp(n) else vBox.Text=tostring(curVal) end end)
    return row
end

local function MakeThemePicker(parent)
    local ROW_H=S(isMobile and 38 or 42)
    local wrap=Instance.new("Frame",parent)
    wrap.Size=UDim2.new(1,0,0,ROW_H); wrap.BackgroundColor3=T.bg2; wrap.BorderSizePixel=0
    Instance.new("UICorner",wrap).CornerRadius=UDim.new(0,S(10))
    Instance.new("UIStroke",wrap).Color=T.borderDim
    local acB=Instance.new("Frame",wrap)
    acB.Size=UDim2.new(0,S(3),0,ROW_H-S(10)); acB.Position=UDim2.new(0,0,0,S(5))
    acB.BackgroundColor3=T.ac0; acB.BackgroundTransparency=0.3; acB.BorderSizePixel=0
    Instance.new("UICorner",acB).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",wrap)
    lbl.Size=UDim2.new(0,S(50),1,0); lbl.Position=UDim2.new(0,S(12),0,0)
    lbl.BackgroundTransparency=1; lbl.Text="THEME"; lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=S(isMobile and 9 or 10); lbl.TextColor3=txtSub; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local themeList={"Blue","Green","Red","Dark"}
    local swatchColors={Blue=Color3.fromRGB(100,180,255),Green=Color3.fromRGB(0,235,145),Red=Color3.fromRGB(255,90,90),Dark=Color3.fromRGB(175,182,205)}
    local SW=S(isMobile and 30 or 36); local SH=S(isMobile and 20 or 24); local startX=S(62); local GAP=S(4)
    for i,name in ipairs(themeList) do
        local sw=Instance.new("TextButton",wrap)
        sw.Size=UDim2.new(0,SW,0,SH); sw.Position=UDim2.new(0,startX+(i-1)*(SW+GAP),0.5,-SH/2)
        sw.BackgroundColor3=swatchColors[name]; sw.BackgroundTransparency=name==currentThemeName and 0.15 or 0.35
        sw.Text=name:sub(1,2); sw.Font=Enum.Font.GothamBlack; sw.TextSize=S(7)
        sw.TextColor3=Color3.fromRGB(255,255,255); sw.BorderSizePixel=0; sw.AutoButtonColor=false
        Instance.new("UICorner",sw).CornerRadius=UDim.new(0,S(6))
        local swS=Instance.new("UIStroke",sw); swS.Color=swatchColors[name]
        swS.Thickness=name==currentThemeName and 2 or 0.5; swS.Transparency=name==currentThemeName and 0 or 0.5
        sw.MouseButton1Click:Connect(function() ApplyTheme(name) end)
        sw.MouseEnter:Connect(function() Tw(sw,0.1,{BackgroundTransparency=0.05}) end)
        sw.MouseLeave:Connect(function() sw.BackgroundTransparency=name==currentThemeName and 0.15 or 0.35 end)
    end
    return wrap
end

local function MakeScaleRow(parent)
    local ROW_H=S(isMobile and 34 or 38); local FS=S(isMobile and 9 or 10); local BSIZE=S(isMobile and 20 or 22)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,ROW_H); row.BackgroundColor3=T.bg2; row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,S(9))
    Instance.new("UIStroke",row).Color=T.borderDim
    local acB=Instance.new("Frame",row)
    acB.Size=UDim2.new(0,S(3),0,ROW_H-S(10)); acB.Position=UDim2.new(0,0,0,S(5))
    acB.BackgroundColor3=T.ac0; acB.BackgroundTransparency=0.4; acB.BorderSizePixel=0
    Instance.new("UICorner",acB).CornerRadius=UDim.new(1,0)
    local nameL=Instance.new("TextLabel",row)
    nameL.Size=UDim2.new(0.38,0,1,0); nameL.Position=UDim2.new(0,S(10),0,0)
    nameL.BackgroundTransparency=1; nameL.Text="GUI SCALE"; nameL.Font=Enum.Font.GothamBold
    nameL.TextSize=FS; nameL.TextColor3=txtSub; nameL.TextXAlignment=Enum.TextXAlignment.Left
    local mBtn=Instance.new("TextButton",row)
    mBtn.Size=UDim2.new(0,BSIZE,0,BSIZE); mBtn.Position=UDim2.new(0.44,0,0.5,-BSIZE/2)
    mBtn.BackgroundColor3=T.bg3; mBtn.Text="-"; mBtn.Font=Enum.Font.GothamBold
    mBtn.TextSize=FS+S(1); mBtn.TextColor3=T.ac1; mBtn.BorderSizePixel=0; mBtn.AutoButtonColor=false
    Instance.new("UICorner",mBtn).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",mBtn).Color=T.borderDim
    local valLbl=Instance.new("TextLabel",row)
    valLbl.Size=UDim2.new(0,S(38),0,BSIZE); valLbl.Position=UDim2.new(0.44,BSIZE+S(3),0.5,-BSIZE/2)
    valLbl.BackgroundColor3=T.bg3; valLbl.BorderSizePixel=0
    valLbl.Text=string.format("%.1f",guiScale); valLbl.Font=Enum.Font.GothamBold
    valLbl.TextSize=FS; valLbl.TextColor3=T.ac0
    Instance.new("UICorner",valLbl).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",valLbl).Color=T.ac3
    local pBtn=Instance.new("TextButton",row)
    pBtn.Size=UDim2.new(0,BSIZE,0,BSIZE); pBtn.Position=UDim2.new(0.44,BSIZE+S(isMobile and 44 or 48),0.5,-BSIZE/2)
    pBtn.BackgroundColor3=T.bg3; pBtn.Text="+"; pBtn.Font=Enum.Font.GothamBold
    pBtn.TextSize=FS+S(1); pBtn.TextColor3=T.ac1; pBtn.BorderSizePixel=0; pBtn.AutoButtonColor=false
    Instance.new("UICorner",pBtn).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",pBtn).Color=T.borderDim
    local applyBtn=Instance.new("TextButton",row)
    applyBtn.Size=UDim2.new(0,S(isMobile and 36 or 44),0,BSIZE)
    applyBtn.Position=UDim2.new(1,-S(isMobile and 40 or 50),0.5,-BSIZE/2)
    applyBtn.BackgroundColor3=T.ac3; applyBtn.Text="APPLY"; applyBtn.Font=Enum.Font.GothamBold
    applyBtn.TextSize=S(7); applyBtn.TextColor3=T.ac0; applyBtn.BorderSizePixel=0; applyBtn.AutoButtonColor=false
    Instance.new("UICorner",applyBtn).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",applyBtn).Color=T.ac2
    for _,btn in ipairs({mBtn,pBtn}) do
        btn.MouseEnter:Connect(function() Tw(btn,0.1,{BackgroundColor3=T.ac3,TextColor3=T.ac0}) end)
        btn.MouseLeave:Connect(function() Tw(btn,0.1,{BackgroundColor3=T.bg3,TextColor3=T.ac1}) end)
    end
    applyBtn.MouseEnter:Connect(function() Tw(applyBtn,0.1,{BackgroundColor3=T.ac2}) end)
    applyBtn.MouseLeave:Connect(function() Tw(applyBtn,0.1,{BackgroundColor3=T.ac3}) end)
    local pendingScale=guiScale
    local function updateVal()
        pendingScale=math.clamp(math.floor(pendingScale*10+0.5)/10,0.5,2.0)
        valLbl.Text=string.format("%.1f",pendingScale)
    end
    mBtn.MouseButton1Click:Connect(function() pendingScale=pendingScale-0.1; updateVal() end)
    pBtn.MouseButton1Click:Connect(function() pendingScale=pendingScale+0.1; updateVal() end)
    applyBtn.MouseButton1Click:Connect(function()
        guiScale=pendingScale
        SaveConfig()
        task.spawn(function()
            task.wait(0.1)
            if heartbeatConn    then heartbeatConn:Disconnect();    heartbeatConn=nil    end
            if statusBarConn    then statusBarConn:Disconnect();    statusBarConn=nil    end
            if globalKeybindConn then globalKeybindConn:Disconnect(); globalKeybindConn=nil end
            pcall(function() ParentUI:FindFirstChild("NatureDuels"):Destroy() end)
            BuildMainGUI()
        end)
    end)
    return row
end

-- ============================================================
--  KEYBIND ROW (PC only)
-- ============================================================
local function MakeKeybindRow(parent, featureId, featureLabel)
    local ROW_H=S(34); local FS=S(9)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,ROW_H); row.BackgroundColor3=T.bg2; row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,S(8))
    local rowS=Instance.new("UIStroke",row); rowS.Color=T.borderDim; rowS.Thickness=1; rowS.Transparency=0.5
    local nameLbl=Instance.new("TextLabel",row)
    nameLbl.Size=UDim2.new(0.45,0,1,0); nameLbl.Position=UDim2.new(0,S(8),0,0)
    nameLbl.BackgroundTransparency=1; nameLbl.Text=featureLabel
    nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=FS; nameLbl.TextColor3=txtSub; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    local keyBtn=Instance.new("TextButton",row)
    keyBtn.Size=UDim2.new(0,S(84),0,ROW_H-S(8)); keyBtn.Position=UDim2.new(0.45,S(4),0.5,-(ROW_H-S(8))/2)
    keyBtn.BackgroundColor3=T.bg3; keyBtn.BorderSizePixel=0
    keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=FS; keyBtn.TextColor3=T.ac1; keyBtn.AutoButtonColor=false
    local kb=FeatureKeybinds[featureId]
    keyBtn.Text=kb and ("["..kb.Name.."]") or "[ None ]"
    Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,S(5))
    local keyBtnStroke=Instance.new("UIStroke",keyBtn); keyBtnStroke.Color=T.borderDim
    local clrBtn=Instance.new("TextButton",row)
    clrBtn.Size=UDim2.new(0,S(22),0,ROW_H-S(8)); clrBtn.Position=UDim2.new(1,-S(26),0.5,-(ROW_H-S(8))/2)
    clrBtn.BackgroundColor3=T.bg3; clrBtn.Text="âœ•"; clrBtn.Font=Enum.Font.GothamBold
    clrBtn.TextSize=S(8); clrBtn.TextColor3=T.ac2; clrBtn.BorderSizePixel=0; clrBtn.AutoButtonColor=false
    Instance.new("UICorner",clrBtn).CornerRadius=UDim.new(0,S(5)); Instance.new("UIStroke",clrBtn).Color=T.borderDim
    local binding=false
    keyBtn.MouseButton1Click:Connect(function()
        if binding then return end
        binding=true; keyBtn.Text="[press key...]"; keyBtn.TextColor3=warn
        Tw(row,0.1,{BackgroundColor3=T.bg3}); Tw(rowS,0.1,{Color=T.ac1,Transparency=0.2})
        local c2; c2=UIS.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                FeatureKeybinds[featureId]=inp.KeyCode
                keyBtn.Text="["..inp.KeyCode.Name.."]"; keyBtn.TextColor3=T.ac0
                Tw(keyBtn,0.15,{BackgroundColor3=T.acOff}); Tw(keyBtnStroke,0.15,{Color=T.ac1})
                Tw(row,0.15,{BackgroundColor3=T.bg2}); Tw(rowS,0.15,{Color=T.borderDim,Transparency=0.5})
                binding=false; c2:Disconnect()
                if bindCallbacks[featureId] then bindCallbacks[featureId]() end
                SaveConfig()
            end
        end)
    end)
    clrBtn.MouseButton1Click:Connect(function()
        FeatureKeybinds[featureId]=nil; keyBtn.Text="[ None ]"; keyBtn.TextColor3=T.ac1
        Tw(keyBtn,0.15,{BackgroundColor3=T.bg3}); Tw(keyBtnStroke,0.15,{Color=T.borderDim})
        if bindCallbacks[featureId] then bindCallbacks[featureId]() end
        SaveConfig()
    end)
    keyBtn.MouseEnter:Connect(function() if not binding then Tw(keyBtn,0.1,{BackgroundColor3=T.ac3}) end end)
    keyBtn.MouseLeave:Connect(function() if not binding then Tw(keyBtn,0.1,{BackgroundColor3=T.bg3}) end end)
    clrBtn.MouseEnter:Connect(function() Tw(clrBtn,0.1,{TextColor3=T.ac0}) end)
    clrBtn.MouseLeave:Connect(function() Tw(clrBtn,0.1,{TextColor3=T.ac2}) end)
    return row
end

-- ============================================================
--  MOBILE SHORTCUTS EDITOR
-- ============================================================
local shortcutBarRef = nil
local RebuildShortcutBar = function() end

local function MakeShortcutEditor(parent, allFeatures)
    local wrap=Instance.new("Frame",parent)
    wrap.Size=UDim2.new(1,0,0,S(0)); wrap.BackgroundTransparency=1; wrap.BorderSizePixel=0
    local WL=Instance.new("UIListLayout",wrap)
    WL.Padding=UDim.new(0,S(3)); WL.SortOrder=Enum.SortOrder.LayoutOrder
    local headerH=S(20)
    local hdr=Instance.new("TextLabel",wrap)
    hdr.Size=UDim2.new(1,0,0,headerH); hdr.LayoutOrder=0; hdr.BackgroundTransparency=1
    hdr.Text="TAP SHORTCUTS   (max 4)"; hdr.Font=Enum.Font.GothamBold
    hdr.TextSize=S(8); hdr.TextColor3=T.cyanDim; hdr.TextXAlignment=Enum.TextXAlignment.Left
    local ITEM_H=S(28); local cols=2
    local rows2=math.ceil(#allFeatures/cols)
    local gridH=rows2*ITEM_H+rows2*S(3)
    local grid=Instance.new("Frame",wrap)
    grid.Size=UDim2.new(1,0,0,gridH); grid.LayoutOrder=1; grid.BackgroundTransparency=1; grid.BorderSizePixel=0
    for i,feat in ipairs(allFeatures) do
        local col=(i-1)%cols; local row2=math.floor((i-1)/cols)
        local item=Instance.new("TextButton",grid)
        item.Size=UDim2.new(0.5,-S(2),0,ITEM_H)
        item.Position=UDim2.new(col*0.5,col==0 and 0 or S(2),0,row2*(ITEM_H+S(3)))
        local isOn=false
        for _,s in ipairs(MobileShortcuts) do if s==feat.id then isOn=true break end end
        item.BackgroundColor3=isOn and T.acOff or T.bg3; item.BorderSizePixel=0; item.AutoButtonColor=false; item.Text=""
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,S(7))
        local iS=Instance.new("UIStroke",item); iS.Color=isOn and T.ac1 or T.borderDim; iS.Thickness=1; iS.Transparency=isOn and 0.2 or 0.5
        local chk=Instance.new("TextLabel",item)
        chk.Size=UDim2.new(0,S(14),0,S(14)); chk.Position=UDim2.new(0,S(5),0.5,-S(7))
        chk.BackgroundColor3=isOn and T.ac0 or T.bg2; chk.BorderSizePixel=0
        chk.Text=isOn and "âœ“" or ""; chk.Font=Enum.Font.GothamBold; chk.TextSize=S(7); chk.TextColor3=T.bg0
        Instance.new("UICorner",chk).CornerRadius=UDim.new(0,S(3))
        local lbl2=Instance.new("TextLabel",item)
        lbl2.Size=UDim2.new(1,-S(24),1,0); lbl2.Position=UDim2.new(0,S(22),0,0)
        lbl2.BackgroundTransparency=1; lbl2.Text=feat.label; lbl2.Font=Enum.Font.GothamBold
        lbl2.TextSize=S(8); lbl2.TextColor3=isOn and txtPrime or txtSub; lbl2.TextXAlignment=Enum.TextXAlignment.Left
        item.MouseButton1Click:Connect(function()
            local idx=nil
            for j,s in ipairs(MobileShortcuts) do if s==feat.id then idx=j break end end
            if idx then table.remove(MobileShortcuts,idx); isOn=false
            else if #MobileShortcuts>=4 then return end; table.insert(MobileShortcuts,feat.id); isOn=true end
            Tw(item,0.15,{BackgroundColor3=isOn and T.acOff or T.bg3})
            Tw(iS,0.15,{Color=isOn and T.ac1 or T.borderDim,Transparency=isOn and 0.2 or 0.5})
            Tw(chk,0.15,{BackgroundColor3=isOn and T.ac0 or T.bg2})
            chk.Text=isOn and "âœ“" or ""
            Tw(lbl2,0.15,{TextColor3=isOn and txtPrime or txtSub})
            RebuildShortcutBar()
            SaveConfig()
        end)
    end
    wrap.Size=UDim2.new(1,0,0,headerH+S(3)+gridH+S(4))
    return wrap
end

-- ============================================================
--  MAIN GUI BUILDER
-- ============================================================
BuildMainGUI = function()
    if heartbeatConn     then heartbeatConn:Disconnect();     heartbeatConn=nil     end
    if statusBarConn     then statusBarConn:Disconnect();     statusBarConn=nil     end
    if globalKeybindConn then globalKeybindConn:Disconnect(); globalKeybindConn=nil end

    pcall(function() ParentUI:FindFirstChild("NatureDuels"):Destroy() end)
    registeredDotSets={}; bindCallbacks={}; toggleSetState={}

    local BASE_W  = isMobile and 224 or 260
    local W       = S(BASE_W)
    local PAD     = S(isMobile and 7 or 10)
    local HDR     = S(isMobile and 46 or 52)
    local GAP     = S(isMobile and 3 or 5)
    local BTN_H   = S(isMobile and 36 or 42)
    local SPD_H   = S(isMobile and 34 or 38)
    local SECT_H  = S(isMobile and 16 or 18)
    local THM_H   = S(isMobile and 38 or 42)
    local SCL_H   = S(isMobile and 34 or 38)
    local KB_ROW_H= S(34)

    local allFeatures = {
        {id="float",     label="Float"},
        {id="autoR",     label="Auto Right"},
        {id="autoL",     label="Auto Left"},
        {id="aimbot",    label="Bat Aimbot"},
        {id="dropFling", label="Drop Fling"},
        {id="antiFling", label="Anti Fling"},
        {id="antiRag",   label="Anti Ragdoll"},
        {id="infJump",   label="Inf Jump"},
        {id="spinBot",   label="Spin Bot"},
        {id="unwalk",    label="Unwalk"},
        {id="steal",     label="Auto Steal"},
        {id="stealSpd",  label="Steal Speed"},
        {id="taunt",     label="Taunt Spam"},
        {id="autoGrab",  label="Auto Grab"},
    }

    local TOGGLE_COUNT=14; local SECT_COUNT=5; local SPEED_COUNT=2
    local GRAB_ROW_H = S(isMobile and 34 or 38)
    local KEYBIND_SECTION_H=(not isMobile) and (S(18)+GAP + #allFeatures*(KB_ROW_H+GAP)+GAP) or 0
    local SHORTCUT_H=isMobile and (S(18)+GAP + S(20)+GAP + math.ceil(#allFeatures/2)*(S(28)+S(3))+S(8)) or 0
    local HIDE_KB_H=(not isMobile) and (S(34)+GAP) or 0

    local CONTENT_H=PAD*2
        +SECT_COUNT*(SECT_H+GAP)
        +TOGGLE_COUNT*(BTN_H+GAP)
        +SPEED_COUNT*(SPD_H+GAP)
        +2*(GRAB_ROW_H+GAP)
        +THM_H+GAP+SCL_H+GAP
        +KEYBIND_SECTION_H+SHORTCUT_H+HIDE_KB_H+S(20)

    local screenH=workspace.CurrentCamera.ViewportSize.Y
    local shortcutBarH=isMobile and S(42) or 0
    local FULL_H=math.min(HDR+CONTENT_H, screenH-60-shortcutBarH)

    local Screen=Instance.new("ScreenGui")
    Screen.Name="NatureDuels"; Screen.ResetOnSpawn=false
    Screen.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Screen.Parent=ParentUI

    local Main=Instance.new("Frame",Screen)
    Main.Name="Main"; Main.Size=UDim2.new(0,W,0,HDR)
    Main.Position=UDim2.new(0,S(8),0,S(50))
    Main.BackgroundColor3=T.bg0; Main.BorderSizePixel=0; Main.ClipsDescendants=true
    Instance.new("UICorner",Main).CornerRadius=UDim.new(0,S(16))
    local mainStroke=Instance.new("UIStroke",Main)
    mainStroke.Color=T.border; mainStroke.Thickness=1.2; mainStroke.Transparency=0.2
    local BG=Instance.new("UIGradient",Main)
    BG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.bg0),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,3,7))}
    BG.Rotation=135
    MakeDotsBackground(Main)

    local Header=Instance.new("Frame",Main)
    Header.Size=UDim2.new(1,0,0,HDR); Header.BackgroundColor3=T.bg1; Header.BorderSizePixel=0
    Instance.new("UICorner",Header).CornerRadius=UDim.new(0,S(16))
    local HG=Instance.new("UIGradient",Header)
    HG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.bg2),ColorSequenceKeypoint.new(1,T.bg0)}; HG.Rotation=90
    MakeDraggable(Main,Header)

    local TopLine=Instance.new("Frame",Header)
    TopLine.Size=UDim2.new(1,0,0,2); TopLine.BackgroundColor3=T.ac1; TopLine.BorderSizePixel=0
    local TLG=Instance.new("UIGradient",TopLine)
    TLG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.2,T.ac0),ColorSequenceKeypoint.new(0.8,T.ac0),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}

    local logoSz=S(isMobile and 28 or 32)
    local LogoBox=Instance.new("Frame",Header)
    LogoBox.Size=UDim2.new(0,logoSz,0,logoSz); LogoBox.Position=UDim2.new(0,S(12),0.5,-logoSz/2)
    LogoBox.BackgroundColor3=T.acOff; LogoBox.BorderSizePixel=0
    Instance.new("UICorner",LogoBox).CornerRadius=UDim.new(0,S(8))
    local LBS=Instance.new("UIStroke",LogoBox); LBS.Color=T.ac1; LBS.Thickness=1.2; LBS.Transparency=0.2
    local LogoTxt=Instance.new("TextLabel",LogoBox)
    LogoTxt.Size=UDim2.new(1,0,1,0); LogoTxt.BackgroundTransparency=1; LogoTxt.Text="ND"
    LogoTxt.Font=Enum.Font.GothamBlack; LogoTxt.TextSize=S(isMobile and 10 or 11); LogoTxt.TextColor3=T.ac0

    for i=1,4 do
        local ang=(i-1)*math.pi/2
        local cx=S(12)+logoSz/2+math.cos(ang)*(logoSz/2+S(5))
        local cy=HDR/2+math.sin(ang)*(logoSz/2+S(5))
        local cd=Instance.new("Frame",Header)
        cd.Size=UDim2.new(0,S(3),0,S(3)); cd.Position=UDim2.new(0,cx-S(1),0,cy-S(1))
        cd.BackgroundColor3=T.ac0; cd.BackgroundTransparency=0.3; cd.BorderSizePixel=0
        Instance.new("UICorner",cd).CornerRadius=UDim.new(1,0)
        local delay=i*0.2
        task.spawn(function()
            while cd.Parent do
                Tw(cd,0.8,{BackgroundTransparency=0.8},Enum.EasingStyle.Sine); task.wait(0.85+delay)
                Tw(cd,0.8,{BackgroundTransparency=0.05},Enum.EasingStyle.Sine); task.wait(0.85+delay)
            end
        end)
    end

    local xOff=S(isMobile and 48 or 54)
    local TitleLbl=Instance.new("TextLabel",Header)
    TitleLbl.Size=UDim2.new(1,-S(100),0,S(17)); TitleLbl.Position=UDim2.new(0,xOff,0,S(isMobile and 6 or 8))
    TitleLbl.BackgroundTransparency=1; TitleLbl.Text="NATURE DUELS"
    TitleLbl.Font=Enum.Font.GothamBlack; TitleLbl.TextSize=S(isMobile and 11 or 13)
    TitleLbl.TextColor3=T.ac0; TitleLbl.TextXAlignment=Enum.TextXAlignment.Left

    local SubLbl=Instance.new("TextLabel",Header)
    SubLbl.Size=UDim2.new(1,-S(100),0,S(12)); SubLbl.Position=UDim2.new(0,xOff,0,S(isMobile and 24 or 27))
    SubLbl.BackgroundTransparency=1
    SubLbl.Text=(isMobile and "MOBILE" or "PC").."  Â·  "..T.name
    SubLbl.Font=Enum.Font.Gotham; SubLbl.TextSize=S(isMobile and 8 or 9)
    SubLbl.TextColor3=txtMute; SubLbl.TextXAlignment=Enum.TextXAlignment.Left

    local MinBtn=Instance.new("TextButton",Header)
    MinBtn.Size=UDim2.new(0,S(isMobile and 24 or 28),0,S(isMobile and 24 or 28))
    MinBtn.Position=UDim2.new(1,-S(isMobile and 32 or 38),0.5,-S(isMobile and 12 or 14))
    MinBtn.BackgroundColor3=T.bg3; MinBtn.Text="âˆ’"; MinBtn.Font=Enum.Font.GothamBold
    MinBtn.TextColor3=txtSub; MinBtn.TextSize=S(isMobile and 13 or 15); MinBtn.BorderSizePixel=0; MinBtn.AutoButtonColor=false
    Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,S(7))
    Instance.new("UIStroke",MinBtn).Color=T.borderDim
    MinBtn.MouseEnter:Connect(function() Tw(MinBtn,0.12,{BackgroundColor3=T.ac3,TextColor3=T.ac0}) end)
    MinBtn.MouseLeave:Connect(function() Tw(MinBtn,0.12,{BackgroundColor3=T.bg3,TextColor3=txtSub}) end)

    local SF=Instance.new("ScrollingFrame",Main)
    SF.Name="ContentScroll"
    SF.Size=UDim2.new(1,0,1,-HDR); SF.Position=UDim2.new(0,0,0,HDR)
    SF.BackgroundTransparency=1; SF.BorderSizePixel=0
    SF.ScrollBarThickness=S(isMobile and 3 or 2); SF.ScrollBarImageColor3=T.ac2
    SF.ScrollingDirection=Enum.ScrollingDirection.Y
    SF.CanvasSize=UDim2.new(0,0,0,CONTENT_H)
    SF.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable; SF.ScrollingEnabled=true

    if isMobile then
        local touchStart=nil; local canvasStart=0
        local maxScroll=math.max(0,CONTENT_H-(FULL_H-HDR))
        SF.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then touchStart=inp.Position; canvasStart=SF.CanvasPosition.Y end
        end)
        SF.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch and touchStart then
                local dy=touchStart.Y-inp.Position.Y
                SF.CanvasPosition=Vector2.new(0,math.clamp(canvasStart+dy,0,maxScroll))
            end
        end)
        SF.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then touchStart=nil end
        end)
    end

    local Content=Instance.new("Frame",SF)
    Content.Size=UDim2.new(1,0,0,CONTENT_H); Content.BackgroundTransparency=1
    local CL=Instance.new("UIListLayout",Content)
    CL.Padding=UDim.new(0,GAP); CL.HorizontalAlignment=Enum.HorizontalAlignment.Center
    CL.VerticalAlignment=Enum.VerticalAlignment.Top; CL.SortOrder=Enum.SortOrder.LayoutOrder
    local CP=Instance.new("UIPadding",Content)
    CP.PaddingTop=UDim.new(0,PAD); CP.PaddingBottom=UDim.new(0,PAD)
    CP.PaddingLeft=UDim.new(0,PAD); CP.PaddingRight=UDim.new(0,PAD)

    local lo=0; local function A(obj) lo=lo+1; obj.LayoutOrder=lo; return obj end

    A(MakeSectionLabel(Content,"APPEARANCE"))
    A(MakeThemePicker(Content))
    A(MakeScaleRow(Content))

    A(MakeSectionLabel(Content,"MOVEMENT"))
    local bF,_ssF,_,ubF     = MakeToggle(Content,"Float",      not isMobile and "float"    or nil)
    local bAR,_ssAR,_,ubAR  = MakeToggle(Content,"Auto Right", not isMobile and "autoR"    or nil)
    ssF=_ssF; ssAR=_ssAR
    A(bF); A(bAR)
    A(MakeSpeedRow(Content,"Right Speed",patrolRightSpeed,function(v) patrolRightSpeed=v; SaveConfig() end))
    local bAL,_ssAL,_,ubAL  = MakeToggle(Content,"Auto Left",  not isMobile and "autoL"    or nil)
    ssAL=_ssAL
    A(bAL)
    A(MakeSpeedRow(Content,"Left Speed",patrolLeftSpeed,function(v) patrolLeftSpeed=v; SaveConfig() end))

    A(MakeSectionLabel(Content,"COMBAT"))
    local bAim,_ssAim,_,ubAim = MakeToggle(Content,"Bat Aimbot",  not isMobile and "aimbot"    or nil)
    local bDr,_ssDr,_,ubDr   = MakeToggle(Content,"Drop Fling",  not isMobile and "dropFling" or nil)
    ssAim=_ssAim; ssDr=_ssDr
    A(bAim); A(bDr)

    A(MakeSectionLabel(Content,"UTILITIES"))
    local bAF,_ssAF,_,ubAF         = MakeToggle(Content,"Anti Fling",   not isMobile and "antiFling" or nil)
    local bARag,_ssARag,_,ubARag   = MakeToggle(Content,"Anti Ragdoll", not isMobile and "antiRag"   or nil)
    local bIJ,_ssIJ,_,ubIJ         = MakeToggle(Content,"Inf Jump",     not isMobile and "infJump"   or nil)
    local bSp,_ssSp,_,ubSp         = MakeToggle(Content,"Spin Bot",     not isMobile and "spinBot"   or nil)
    local bUw,_ssUw,_,ubUw         = MakeToggle(Content,"Unwalk",       not isMobile and "unwalk"    or nil)
    local bSt,_ssSt,_,ubSt         = MakeToggle(Content,"Auto Steal",   not isMobile and "steal"     or nil)
    local bSspd,_ssSspd,_,ubSspd   = MakeToggle(Content,"Steal Speed",  not isMobile and "stealSpd"  or nil)
    local bTnt,_ssTnt,_,ubTnt      = MakeToggle(Content,"Taunt Spam",   not isMobile and "taunt"     or nil)
    local bGrab,_ssGrab,_,ubGrab   = MakeToggle(Content,"Auto Grab",    not isMobile and "autoGrab"  or nil)
    ssAF=_ssAF; ssARag=_ssARag; ssIJ=_ssIJ; ssSp=_ssSp; ssUw=_ssUw
    ssSt=_ssSt; ssSspd=_ssSspd; ssTnt=_ssTnt; ssGrab=_ssGrab
    A(bAF); A(bARag); A(bIJ); A(bSp); A(bUw); A(bSt); A(bSspd); A(bTnt); A(bGrab)
    A(MakeSpeedRow(Content,"Grab Radius",AUTO_GRAB_RADIUS,function(v) AUTO_GRAB_RADIUS=v; SaveConfig() end))
    A(MakeSpeedRow(Content,"Grab Delay (x100ms)",math.floor(AUTO_GRAB_DELAY*10),function(v) AUTO_GRAB_DELAY=v/10; SaveConfig() end))

    toggleSetState={
        float=ssF,autoR=ssAR,autoL=ssAL,aimbot=ssAim,dropFling=ssDr,
        antiFling=ssAF,antiRag=ssARag,infJump=ssIJ,spinBot=ssSp,unwalk=ssUw,
        steal=ssSt,stealSpd=ssSspd,taunt=ssTnt,autoGrab=ssGrab,
    }
    bindCallbacks={
        float=ubF,autoR=ubAR,autoL=ubAL,aimbot=ubAim,dropFling=ubDr,
        antiFling=ubAF,antiRag=ubARag,infJump=ubIJ,spinBot=ubSp,unwalk=ubUw,
        steal=ubSt,stealSpd=ubSspd,taunt=ubTnt,autoGrab=ubGrab,
    }
    FeatureStates={
        float=false,autoR=false,autoL=false,aimbot=false,dropFling=false,
        antiFling=false,antiRag=false,infJump=false,spinBot=false,unwalk=false,
        steal=false,stealSpd=false,taunt=false,autoGrab=false
    }

    if antiFlingActive   then FeatureStates.antiFling=true;  ssAF(true)    end
    if antiRagdollActive then FeatureStates.antiRag=true;    ssARag(true)  end
    if infJumpActive     then FeatureStates.infJump=true;    ssIJ(true)    end
    if spinActive        then FeatureStates.spinBot=true;    ssSp(true)    end
    if unwalkActive      then FeatureStates.unwalk=true;     ssUw(true)    end
    if stealSpeedActive  then FeatureStates.stealSpd=true;   ssSspd(true)  end
    if autoGrabActive    then FeatureStates.autoGrab=true;   ssGrab(true)  end
    if tauntActive       then FeatureStates.taunt=true;      ssTnt(true)   end
    if stealActive       then FeatureStates.steal=true;      ssSt(true)    end
    if floating          then FeatureStates.float=true;      ssF(true)     end
    if batAimbotActive   then FeatureStates.aimbot=true;     ssAim(true)   end
    if patrolMode=="right" then FeatureStates.autoR=true;    ssAR(true)    end
    if patrolMode=="left"  then FeatureStates.autoL=true;    ssAL(true)    end

    if _savedConfig and _savedConfig.toggles then
        local t2=_savedConfig.toggles
        if t2.antiFling  and not antiFlingActive   then antiFlingActive=true;   ssAF(true);    startAntiFling()    end
        if t2.antiRag    and not antiRagdollActive  then antiRagdollActive=true; ssARag(true);  startAntiRagdoll()  end
        if t2.infJump    and not infJumpActive      then infJumpActive=true;     ssIJ(true);    startInfJump()      end
        if t2.spinBot    and not spinActive         then spinActive=true;        ssSp(true);    startSpinBot()      end
        if t2.unwalk     and not unwalkActive       then unwalkActive=true;      ssUw(true);    startUnwalk()       end
        if t2.stealSpd   and not stealSpeedActive   then stealSpeedActive=true;  ssSspd(true);  startStealSpeed()   end
        if t2.autoGrab   and not autoGrabActive     then autoGrabActive=true;    ssGrab(true);  startAutoGrab()     end
        if t2.taunt and not tauntActive then
            tauntActive=true; ssTnt(true)
            tauntLoop=task.spawn(function()
                while tauntActive do
                    pcall(function() local ch=game:GetService("TextChatService").TextChannels:FindFirstChild("RBXGeneral"); if ch then ch:SendAsync("/nature hub") end end)
                    task.wait(0.5)
                end
            end)
        end
    end

    if not isMobile then
        A(MakeSectionLabel(Content,"KEYBINDS"))
        for _,feat in ipairs(allFeatures) do A(MakeKeybindRow(Content,feat.id,feat.label)) end
    end

    if isMobile then
        A(MakeSectionLabel(Content,"SHORTCUTS"))
        A(MakeShortcutEditor(Content,allFeatures))
    end

    if not isMobile then
        local kRow=Instance.new("Frame",Content)
        kRow.Size=UDim2.new(1,0,0,S(34)); kRow.BackgroundColor3=T.bg2; kRow.BorderSizePixel=0; A(kRow)
        Instance.new("UICorner",kRow).CornerRadius=UDim.new(0,S(10))
        Instance.new("UIStroke",kRow).Color=T.borderDim
        local KL=Instance.new("TextLabel",kRow)
        KL.Size=UDim2.new(0,S(80),1,0); KL.Position=UDim2.new(0,S(12),0,0)
        KL.BackgroundTransparency=1; KL.Text="HIDE KEY"; KL.Font=Enum.Font.Gotham; KL.TextSize=S(9)
        KL.TextColor3=txtMute; KL.TextXAlignment=Enum.TextXAlignment.Left
        local KVBtn=Instance.new("TextButton",kRow)
        KVBtn.Size=UDim2.new(0,S(120),0,S(22)); KVBtn.Position=UDim2.new(1,-S(128),0.5,-S(11))
        KVBtn.BackgroundColor3=T.bg3; KVBtn.Text="[ "..HideKeybind.Name.." ]"
        KVBtn.Font=Enum.Font.GothamBold; KVBtn.TextSize=S(9); KVBtn.TextColor3=T.ac1
        KVBtn.BorderSizePixel=0; KVBtn.AutoButtonColor=false
        Instance.new("UICorner",KVBtn).CornerRadius=UDim.new(0,S(6))
        local bindingH=false
        KVBtn.MouseButton1Click:Connect(function()
            if bindingH then return end; bindingH=true; KVBtn.Text="[press...]"; KVBtn.TextColor3=warn
            local c2; c2=UIS.InputBegan:Connect(function(inp,gpe)
                if gpe then return end
                if inp.UserInputType==Enum.UserInputType.Keyboard then
                    HideKeybind=inp.KeyCode; KVBtn.Text="[ "..inp.KeyCode.Name.." ]"
                    KVBtn.TextColor3=T.ac1; bindingH=false; c2:Disconnect()
                end
            end)
        end)
    end

    local SB_W=S(isMobile and 240 or 280); local SB_H=S(isMobile and 38 or 42)
    local StealBar=Instance.new("Frame",Screen)
    StealBar.Size=UDim2.new(0,SB_W,0,SB_H)
    StealBar.Position=UDim2.new(0.5,-SB_W/2,1,-(SB_H+(isMobile and S(52) or S(10))))
    StealBar.BackgroundColor3=T.bg1; StealBar.BorderSizePixel=0
    Instance.new("UICorner",StealBar).CornerRadius=UDim.new(0,S(13))
    local SBS=Instance.new("UIStroke",StealBar); SBS.Color=T.border; SBS.Thickness=1; SBS.Transparency=0.3
    local SBTopL=Instance.new("Frame",StealBar)
    SBTopL.Size=UDim2.new(1,0,0,isMobile and S(10) or S(4)); SBTopL.BackgroundColor3=T.ac1; SBTopL.BorderSizePixel=0
    local SBTG=Instance.new("UIGradient",SBTopL)
    SBTG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.5,T.ac0),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
    SBTopL.ZIndex=10
    MakeDraggable(StealBar, SBTopL)
    if isMobile then
        local sbDragStart, sbCanvasStart
        StealBar.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then sbDragStart=inp.Position; sbCanvasStart=StealBar.Position end
        end)
        StealBar.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch and sbDragStart then
                local dx=inp.Position.X-sbDragStart.X; local dy=inp.Position.Y-sbDragStart.Y
                StealBar.Position=UDim2.new(sbCanvasStart.X.Scale,sbCanvasStart.X.Offset+dx,sbCanvasStart.Y.Scale,sbCanvasStart.Y.Offset+dy)
            end
        end)
        StealBar.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then sbDragStart=nil end
        end)
    end
    sbDots={}
    for i=1,3 do
        local d=Instance.new("Frame",StealBar)
        d.Size=UDim2.new(0,S(5),0,S(5)); d.Position=UDim2.new(0,S(8)+(i-1)*S(9),0.5,-S(2))
        d.BackgroundColor3=inactive; d.BackgroundTransparency=0.4; d.BorderSizePixel=0
        Instance.new("UICorner",d).CornerRadius=UDim.new(1,0); table.insert(sbDots,d)
    end
    SBStatus=Instance.new("TextLabel",StealBar)
    SBStatus.Size=UDim2.new(0,S(80),0,S(14)); SBStatus.Position=UDim2.new(0,S(36),0.5,-S(7))
    SBStatus.BackgroundTransparency=1; SBStatus.Text="IDLE"; SBStatus.Font=Enum.Font.GothamBold
    SBStatus.TextSize=S(isMobile and 9 or 10); SBStatus.TextColor3=txtMute; SBStatus.TextXAlignment=Enum.TextXAlignment.Left
    local SBTrack=Instance.new("Frame",StealBar)
    SBTrack.Size=UDim2.new(1,-S(122),0,S(3)); SBTrack.Position=UDim2.new(0,S(10),1,-S(7))
    SBTrack.BackgroundColor3=T.bg3; SBTrack.BorderSizePixel=0
    Instance.new("UICorner",SBTrack).CornerRadius=UDim.new(1,0)
    SBFill=Instance.new("Frame",SBTrack)
    SBFill.Size=UDim2.new(0,0,1,0); SBFill.BackgroundColor3=T.ac1; SBFill.BorderSizePixel=0
    Instance.new("UICorner",SBFill).CornerRadius=UDim.new(1,0)
    local FLG=Instance.new("UIGradient",SBFill)
    FLG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.ac2),ColorSequenceKeypoint.new(1,T.ac0)}

    local function MakeStatControl(xOff, labelTxt, initVal, minV, maxV, step, onChange)
        local BOX_W=S(52); local BOX_H=SB_H-S(8); local FS=S(isMobile and 8 or 9)
        local box=Instance.new("Frame",StealBar)
        box.Size=UDim2.new(0,BOX_W,0,BOX_H); box.Position=UDim2.new(1,xOff,0,S(4))
        box.BackgroundColor3=T.bg3; box.BorderSizePixel=0
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,S(6))
        Instance.new("UIStroke",box).Color=T.borderDim
        local tl=Instance.new("TextLabel",box)
        tl.Size=UDim2.new(1,0,0,S(11)); tl.Position=UDim2.new(0,0,0,S(1))
        tl.BackgroundTransparency=1; tl.Text=labelTxt; tl.Font=Enum.Font.Gotham
        tl.TextSize=S(7); tl.TextColor3=txtMute
        local vl=Instance.new("TextLabel",box)
        vl.Size=UDim2.new(1,-S(22),0,S(13)); vl.Position=UDim2.new(0,0,0,S(13))
        vl.BackgroundTransparency=1; vl.Text=tostring(initVal)
        vl.Font=Enum.Font.GothamBold; vl.TextSize=FS; vl.TextColor3=T.ac0
        local mB=Instance.new("TextButton",box)
        mB.Size=UDim2.new(0,S(10),0,S(12)); mB.Position=UDim2.new(0,S(1),1,-S(14))
        mB.BackgroundColor3=T.bg2; mB.Text="-"; mB.Font=Enum.Font.GothamBold
        mB.TextSize=S(8); mB.TextColor3=T.ac1; mB.BorderSizePixel=0; mB.AutoButtonColor=false
        Instance.new("UICorner",mB).CornerRadius=UDim.new(0,S(3))
        local pB=Instance.new("TextButton",box)
        pB.Size=UDim2.new(0,S(10),0,S(12)); pB.Position=UDim2.new(1,-S(11),1,-S(14))
        pB.BackgroundColor3=T.bg2; pB.Text="+"; pB.Font=Enum.Font.GothamBold
        pB.TextSize=S(8); pB.TextColor3=T.ac1; pB.BorderSizePixel=0; pB.AutoButtonColor=false
        Instance.new("UICorner",pB).CornerRadius=UDim.new(0,S(3))
        local curVal=initVal
        local function set(v)
            curVal=math.clamp(math.floor(v),minV,maxV); vl.Text=tostring(curVal); if onChange then onChange(curVal) end
        end
        mB.MouseButton1Click:Connect(function() set(curVal-step) end)
        pB.MouseButton1Click:Connect(function() set(curVal+step) end)
        for _,b in ipairs({mB,pB}) do
            b.MouseEnter:Connect(function() Tw(b,0.1,{BackgroundColor3=T.ac3,TextColor3=T.ac0}) end)
            b.MouseLeave:Connect(function() Tw(b,0.1,{BackgroundColor3=T.bg2,TextColor3=T.ac1}) end)
        end
        return vl, set
    end
    SBRadVal = MakeStatControl(-S(110),"DST",STEAL_DST,1,200,1,function(v) STEAL_DST=v; SaveConfig() end)
    SBSecVal = MakeStatControl(-S(56),"SPD",STEAL_SPD,1,200,1,function(v) STEAL_SPD=v; SaveConfig() end)

    local dotT=0; local lastLU=0
    statusBarConn = RunService.Heartbeat:Connect(function(dt)
        dotT=dotT+dt; if isSt then return end
        local hum=GetHum()
        local now=tick()
        if stealActive then
            for i,d in ipairs(sbDots) do d.BackgroundColor3=T.ac0; d.BackgroundTransparency=0.1+0.55*math.abs(math.sin(dotT*2.8-(i-1)*0.8)) end
            local prompt,dist,maxDist=findClosestStealAny()
            local speedOk=hum and hum.WalkSpeed>=STEAL_SPD
            local inRange=prompt and dist<=STEAL_DST
            if speedOk and inRange then
                Tw(SBFill,0.1,{Size=UDim2.new(math.clamp(1-(dist/STEAL_DST),0,1),0,1,0)})
                if now-lastLU>=0.12 then lastLU=now; SBStatus.Text="STEALING"; SBStatus.TextColor3=T.ac0 end
            else
                Tw(SBFill,0.15,{Size=UDim2.new(0,0,1,0)})
                if now-lastLU>=0.3 then lastLU=now; SBStatus.Text="SCANNING"; SBStatus.TextColor3=T.cyanDim end
            end
        else
            for _,d in ipairs(sbDots) do d.BackgroundColor3=inactive; d.BackgroundTransparency=0.5 end
            Tw(SBFill,0.15,{Size=UDim2.new(0,0,1,0)})
            if now-lastLU>=0.3 then lastLU=now; SBStatus.Text="IDLE"; SBStatus.TextColor3=txtMute end
        end
    end)

    local shortcutBar=nil
    if isMobile then
        shortcutBar=Instance.new("Frame",Screen)
        shortcutBar.Name="ShortcutBar"
        shortcutBar.Size=UDim2.new(0,S(200),1,-S(20))
        shortcutBar.Position=UDim2.new(1,-S(210),0,S(10))
        shortcutBar.BackgroundTransparency=1; shortcutBar.BorderSizePixel=0
        local noScLbl=Instance.new("TextLabel",shortcutBar)
        noScLbl.Size=UDim2.new(1,0,0,S(20)); noScLbl.Position=UDim2.new(0,0,0,0)
        noScLbl.BackgroundTransparency=1; noScLbl.Text=""
        noScLbl.Font=Enum.Font.Gotham; noScLbl.TextSize=S(9); noScLbl.TextColor3=txtMute
        shortcutBarRef=shortcutBar

        local labelMap={float="Float",autoR="Auto Right",autoL="Auto Left",aimbot="Aimbot",dropFling="Drop",
            antiFling="Anti Fling",antiRag="Anti Ragdoll",infJump="Inf Jump",spinBot="Spin Bot",unwalk="Unwalk",
            steal="Steal",stealSpd="Steal Spd",taunt="Taunt",autoGrab="Auto Grab"}

        local function dispatchToggle(id)
            if id=="float" then
                floating=not floating; ssF(floating); FeatureStates.float=floating
                if not floating then local root=GetRoot(); if root then root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z) end end
            elseif id=="autoR" then if patrolMode=="right" or waitingForCountdownR then stopPatrol() else startPatrol("right") end
            elseif id=="autoL" then if patrolMode=="left" or waitingForCountdownL then stopPatrol() else startPatrol("left") end
            elseif id=="aimbot" then batAimbotActive=not batAimbotActive; ssAim(batAimbotActive); FeatureStates.aimbot=batAimbotActive; if batAimbotActive then startBatAimbot() else stopBatAimbot() end
            elseif id=="dropFling" then startWalkFling(); task.delay(0.4,stopWalkFling); ssDr(true); task.delay(0.65,function() ssDr(false) end)
            elseif id=="antiFling" then antiFlingActive=not antiFlingActive; ssAF(antiFlingActive); FeatureStates.antiFling=antiFlingActive; if antiFlingActive then startAntiFling() else stopAntiFling() end; SaveConfig()
            elseif id=="antiRag" then antiRagdollActive=not antiRagdollActive; ssARag(antiRagdollActive); FeatureStates.antiRag=antiRagdollActive; if antiRagdollActive then startAntiRagdoll() else stopAntiRagdoll() end; SaveConfig()
            elseif id=="infJump" then infJumpActive=not infJumpActive; ssIJ(infJumpActive); FeatureStates.infJump=infJumpActive; if infJumpActive then startInfJump() else stopInfJump() end; SaveConfig()
            elseif id=="spinBot" then spinActive=not spinActive; ssSp(spinActive); FeatureStates.spinBot=spinActive; if spinActive then startSpinBot() else stopSpinBot() end; SaveConfig()
            elseif id=="unwalk" then unwalkActive=not unwalkActive; ssUw(unwalkActive); FeatureStates.unwalk=unwalkActive; if unwalkActive then startUnwalk() else stopUnwalk() end; SaveConfig()
            elseif id=="steal" then stealActive=not stealActive; ssSt(stealActive); FeatureStates.steal=stealActive; if stealActive then startStealLoop() else stopStealLoop() end
            elseif id=="stealSpd" then stealSpeedActive=not stealSpeedActive; ssSspd(stealSpeedActive); FeatureStates.stealSpd=stealSpeedActive; if stealSpeedActive then startStealSpeed() else stopStealSpeed() end; SaveConfig()
            elseif id=="taunt" then
                tauntActive=not tauntActive; ssTnt(tauntActive); FeatureStates.taunt=tauntActive
                if tauntActive then tauntLoop=task.spawn(function() while tauntActive do pcall(function() local ch=game:GetService("TextChatService").TextChannels:FindFirstChild("RBXGeneral"); if ch then ch:SendAsync("/nature hub") end end); task.wait(0.5) end end)
                else if tauntLoop then task.cancel(tauntLoop); tauntLoop=nil end end; SaveConfig()
            elseif id=="autoGrab" then autoGrabActive=not autoGrabActive; ssGrab(autoGrabActive); FeatureStates.autoGrab=autoGrabActive; if autoGrabActive then startAutoGrab() else stopAutoGrab() end; SaveConfig()
            end
        end

        RebuildShortcutBar=function()
            for _,c in ipairs(shortcutBar:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            noScLbl.Visible=#MobileShortcuts==0
            local n=#MobileShortcuts; if n==0 then return end
            local BTN_W=S(200); local BTN_H2=S(62); local GAP2=S(10)
            local totalH=n*BTN_H2+(n-1)*GAP2
            local startY=(shortcutBar.AbsoluteSize.Y-totalH)/2
            for i,id in ipairs(MobileShortcuts) do
                local yp=startY+(i-1)*(BTN_H2+GAP2)
                local btn=Instance.new("TextButton",shortcutBar)
                btn.Size=UDim2.new(0,BTN_W,0,BTN_H2)
                btn.Position=UDim2.new(0,0,0,yp)
                local isOn=FeatureStates[id] or false
                btn.BackgroundColor3=Color3.fromRGB(8,8,8)
                btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.Text=""
                Instance.new("UICorner",btn).CornerRadius=UDim.new(0,S(16))
                local bS2=Instance.new("UIStroke",btn)
                bS2.Color=isOn and T.ac1 or Color3.fromRGB(90,0,200)
                bS2.Thickness=2.5; bS2.Transparency=isOn and 0 or 0.1
                local dot2=Instance.new("Frame",btn)
                dot2.Size=UDim2.new(0,S(8),0,S(8))
                dot2.Position=UDim2.new(0,S(14),0.5,-S(4))
                dot2.BackgroundColor3=isOn and T.ac0 or Color3.fromRGB(55,55,55)
                dot2.BorderSizePixel=0; Instance.new("UICorner",dot2).CornerRadius=UDim.new(1,0)
                local lbl3=Instance.new("TextLabel",btn)
                lbl3.Size=UDim2.new(1,-S(28),1,0); lbl3.Position=UDim2.new(0,S(28),0,0)
                lbl3.BackgroundTransparency=1
                lbl3.Text=labelMap[id] or id; lbl3.Font=Enum.Font.GothamBold
                lbl3.TextSize=S(15); lbl3.TextColor3=Color3.fromRGB(255,255,255)
                lbl3.TextXAlignment=Enum.TextXAlignment.Center
                btn.MouseButton1Click:Connect(function()
                    dispatchToggle(id)
                    local on2=FeatureStates[id] or false; if id=="dropFling" then on2=false end
                    Tw(bS2,0.15,{Color=on2 and T.ac1 or Color3.fromRGB(90,0,200),Transparency=on2 and 0 or 0.1})
                    Tw(dot2,0.15,{BackgroundColor3=on2 and T.ac0 or Color3.fromRGB(55,55,55)})
                end)
            end
        end
        RebuildShortcutBar()
    end

    -- BUTTON CONNECTIONS
    bF.MouseButton1Click:Connect(function()
        floating=not floating; ssF(floating); FeatureStates.float=floating
        if not floating then local root=GetRoot(); if root then root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z) end end
    end)
    bAR.MouseButton1Click:Connect(function()
        if patrolMode=="right" or waitingForCountdownR then stopPatrol(); return end
        local ok,label=pcall(function() return player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer.Label end)
        if ok and label and isTimerCountdown(label) then waitingForCountdownR=true; local l=bAR:FindFirstChild("Label"); if l then l.Text="Waiting..." end
        else startPatrol("right") end
    end)
    bAL.MouseButton1Click:Connect(function()
        if patrolMode=="left" or waitingForCountdownL then stopPatrol(); return end
        local ok,label=pcall(function() return player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer.Label end)
        if ok and label and isTimerCountdown(label) then waitingForCountdownL=true; local l=bAL:FindFirstChild("Label"); if l then l.Text="Waiting..." end
        else startPatrol("left") end
    end)
    bAim.MouseButton1Click:Connect(function()
        batAimbotActive=not batAimbotActive; ssAim(batAimbotActive); FeatureStates.aimbot=batAimbotActive
        if batAimbotActive then startBatAimbot() else stopBatAimbot() end
    end)
    bDr.MouseButton1Click:Connect(function()
        startWalkFling(); task.delay(0.4,stopWalkFling); ssDr(true); task.delay(0.65,function() ssDr(false) end)
    end)
    bAF.MouseButton1Click:Connect(function()
        antiFlingActive=not antiFlingActive; ssAF(antiFlingActive); FeatureStates.antiFling=antiFlingActive
        if antiFlingActive then startAntiFling() else stopAntiFling() end; SaveConfig()
    end)
    bARag.MouseButton1Click:Connect(function()
        antiRagdollActive=not antiRagdollActive; ssARag(antiRagdollActive); FeatureStates.antiRag=antiRagdollActive
        if antiRagdollActive then startAntiRagdoll() else stopAntiRagdoll() end; SaveConfig()
    end)
    bIJ.MouseButton1Click:Connect(function()
        infJumpActive=not infJumpActive; ssIJ(infJumpActive); FeatureStates.infJump=infJumpActive
        if infJumpActive then startInfJump() else stopInfJump() end; SaveConfig()
    end)
    bSp.MouseButton1Click:Connect(function()
        spinActive=not spinActive; ssSp(spinActive); FeatureStates.spinBot=spinActive
        if spinActive then startSpinBot() else stopSpinBot() end; SaveConfig()
    end)
    bUw.MouseButton1Click:Connect(function()
        unwalkActive=not unwalkActive; ssUw(unwalkActive); FeatureStates.unwalk=unwalkActive
        if unwalkActive then startUnwalk() else stopUnwalk() end; SaveConfig()
    end)
    bSt.MouseButton1Click:Connect(function()
        stealActive=not stealActive; ssSt(stealActive); FeatureStates.steal=stealActive
        if stealActive then startStealLoop() else stopStealLoop() end
    end)
    bSspd.MouseButton1Click:Connect(function()
        stealSpeedActive=not stealSpeedActive; ssSspd(stealSpeedActive); FeatureStates.stealSpd=stealSpeedActive
        if stealSpeedActive then startStealSpeed() else stopStealSpeed() end; SaveConfig()
    end)
    bTnt.MouseButton1Click:Connect(function()
        tauntActive=not tauntActive; ssTnt(tauntActive); FeatureStates.taunt=tauntActive
        if tauntActive then tauntLoop=task.spawn(function() while tauntActive do pcall(function() local ch=game:GetService("TextChatService").TextChannels:FindFirstChild("RBXGeneral"); if ch then ch:SendAsync("/nature hub") end end); task.wait(0.5) end end)
        else if tauntLoop then task.cancel(tauntLoop); tauntLoop=nil end end; SaveConfig()
    end)
    bGrab.MouseButton1Click:Connect(function()
        autoGrabActive=not autoGrabActive; ssGrab(autoGrabActive); FeatureStates.autoGrab=autoGrabActive
        if autoGrabActive then startAutoGrab() else stopAutoGrab() end; SaveConfig()
    end)

    if not isMobile then
        globalKeybindConn = UIS.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if inp.KeyCode==HideKeybind then
                local minimized2=Main.Size.Y.Offset<=HDR+5
                MinBtn.Text=minimized2 and "âˆ’" or "+"
                Tw(Main,0.3,{Size=UDim2.new(0,W,0,minimized2 and FULL_H or HDR)})
                return
            end
            if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            for id,kc in pairs(FeatureKeybinds) do
                if inp.KeyCode==kc then
                    if id=="float" then floating=not floating; ssF(floating); FeatureStates.float=floating; if not floating then local root=GetRoot(); if root then root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z) end end
                    elseif id=="autoR" then if patrolMode=="right" or waitingForCountdownR then stopPatrol() else startPatrol("right") end
                    elseif id=="autoL" then if patrolMode=="left" or waitingForCountdownL then stopPatrol() else startPatrol("left") end
                    elseif id=="aimbot" then batAimbotActive=not batAimbotActive; ssAim(batAimbotActive); FeatureStates.aimbot=batAimbotActive; if batAimbotActive then startBatAimbot() else stopBatAimbot() end
                    elseif id=="dropFling" then startWalkFling(); task.delay(0.4,stopWalkFling); ssDr(true); task.delay(0.65,function() ssDr(false) end)
                    elseif id=="antiFling" then antiFlingActive=not antiFlingActive; ssAF(antiFlingActive); FeatureStates.antiFling=antiFlingActive; if antiFlingActive then startAntiFling() else stopAntiFling() end; SaveConfig()
                    elseif id=="antiRag" then antiRagdollActive=not antiRagdollActive; ssARag(antiRagdollActive); FeatureStates.antiRag=antiRagdollActive; if antiRagdollActive then startAntiRagdoll() else stopAntiRagdoll() end; SaveConfig()
                    elseif id=="infJump" then infJumpActive=not infJumpActive; ssIJ(infJumpActive); FeatureStates.infJump=infJumpActive; if infJumpActive then startInfJump() else stopInfJump() end; SaveConfig()
                    elseif id=="spinBot" then spinActive=not spinActive; ssSp(spinActive); FeatureStates.spinBot=spinActive; if spinActive then startSpinBot() else stopSpinBot() end; SaveConfig()
                    elseif id=="unwalk" then unwalkActive=not unwalkActive; ssUw(unwalkActive); FeatureStates.unwalk=unwalkActive; if unwalkActive then startUnwalk() else stopUnwalk() end; SaveConfig()
                    elseif id=="steal" then stealActive=not stealActive; ssSt(stealActive); FeatureStates.steal=stealActive; if stealActive then startStealLoop() else stopStealLoop() end
                    elseif id=="stealSpd" then stealSpeedActive=not stealSpeedActive; ssSspd(stealSpeedActive); FeatureStates.stealSpd=stealSpeedActive; if stealSpeedActive then startStealSpeed() else stopStealSpeed() end; SaveConfig()
                    elseif id=="taunt" then tauntActive=not tauntActive; ssTnt(tauntActive); FeatureStates.taunt=tauntActive; if tauntActive then tauntLoop=task.spawn(function() while tauntActive do pcall(function() local ch=game:GetService("TextChatService").TextChannels:FindFirstChild("RBXGeneral"); if ch then ch:SendAsync("/nature hub") end end); task.wait(0.5) end end) else if tauntLoop then task.cancel(tauntLoop); tauntLoop=nil end end; SaveConfig()
                    elseif id=="autoGrab" then autoGrabActive=not autoGrabActive; ssGrab(autoGrabActive); FeatureStates.autoGrab=autoGrabActive; if autoGrabActive then startAutoGrab() else stopAutoGrab() end; SaveConfig()
                    end
                end
            end
        end)
    end

    local minimized=false
    Tw(Main,0.45,{Size=UDim2.new(0,W,0,FULL_H)})
    MinBtn.MouseButton1Click:Connect(function()
        minimized=not minimized; MinBtn.Text=minimized and "+" or "âˆ’"
        Tw(Main,0.3,{Size=UDim2.new(0,W,0,minimized and HDR or FULL_H)})
    end)

    local function onTextChanged(label)
        local ok,number=isCountdownNum(label.Text)
        if ok and number==1 then
            if waitingForCountdownL then task.wait(AUTO_START_DELAY); waitingForCountdownL=false; startPatrol("left") end
            if waitingForCountdownR then task.wait(AUTO_START_DELAY); waitingForCountdownR=false; startPatrol("right") end
        end
    end
    task.spawn(function()
        local ok,label=pcall(function() return player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer.Label end)
        if ok and label then onTextChanged(label); label:GetPropertyChangedSignal("Text"):Connect(function() onTextChanged(label) end) end
    end)

    player.CharacterAdded:Connect(function()
        task.wait(1)
        patrolMode="none"; currentWaypoint=1; waitingForCountdownL=false; waitingForCountdownR=false
        floating=false; batAimbotActive=false
        ssF(false); ssAR(false); ssAL(false); ssAim(false)
        FeatureStates.float=false; FeatureStates.autoR=false; FeatureStates.autoL=false; FeatureStates.aimbot=false
        stopBatAimbot()
        if antiRagdollActive then startAntiRagdoll() end
        if infJumpActive     then startInfJump()     end
        if unwalkActive      then startUnwalk()      end
        if stealSpeedActive  then startStealSpeed()  end
        if spinActive        then startSpinBot()     end
        if antiFlingActive   then startAntiFling()   end
        if stealActive       then startStealLoop()   end
        if autoGrabActive    then startAutoGrab()    end
    end)

    heartbeatConn=RunService.Heartbeat:Connect(updateWalking)
    Screen.Destroying:Connect(function()
        if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn=nil end
        if statusBarConn then statusBarConn:Disconnect(); statusBarConn=nil end
    end)

    print("[Nature Duels]: "..(isMobile and "Mobile" or "PC").." | Scale:"..guiScale.." | Theme:"..T.name)
end

-- ============================================================
--  MODE SELECT
-- ============================================================
pcall(function() ParentUI:FindFirstChild("NatureDuels"):Destroy() end)
pcall(function() ParentUI:FindFirstChild("ND_Select"):Destroy() end)

local SelGui=Instance.new("ScreenGui")
SelGui.Name="ND_Select"; SelGui.ResetOnSpawn=false
SelGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SelGui.Parent=ParentUI

local Backdrop=Instance.new("Frame",SelGui)
Backdrop.Size=UDim2.new(1,0,1,0); Backdrop.BackgroundColor3=Color3.fromRGB(2,3,8)
Backdrop.BackgroundTransparency=0.45; Backdrop.BorderSizePixel=0

local CW,CH=310,300
local Card=Instance.new("Frame",SelGui)
Card.Size=UDim2.new(0,CW,0,0); Card.Position=UDim2.new(0.5,-CW/2,0.5,0)
Card.BackgroundColor3=T.bg0; Card.BorderSizePixel=0; Card.ClipsDescendants=true
Instance.new("UICorner",Card).CornerRadius=UDim.new(0,18)
local CS=Instance.new("UIStroke",Card); CS.Color=T.border; CS.Thickness=1.4; CS.Transparency=0.2
local CG=Instance.new("UIGradient",Card)
CG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.bg1),ColorSequenceKeypoint.new(1,T.bg0)}; CG.Rotation=135
MakeDotsBackground(Card)

local SelTopBar=Instance.new("Frame",Card)
SelTopBar.Size=UDim2.new(1,0,0,2); SelTopBar.BackgroundColor3=T.ac1; SelTopBar.BorderSizePixel=0
local STBG=Instance.new("UIGradient",SelTopBar)
STBG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.4,T.ac0),ColorSequenceKeypoint.new(0.6,T.ac0),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}

local LBig=Instance.new("Frame",Card)
LBig.Size=UDim2.new(0,48,0,48); LBig.Position=UDim2.new(0.5,-24,0,18)
LBig.BackgroundColor3=T.acOff; LBig.BorderSizePixel=0
Instance.new("UICorner",LBig).CornerRadius=UDim.new(0,12)
local LBS2=Instance.new("UIStroke",LBig); LBS2.Color=T.ac1; LBS2.Thickness=1.5; LBS2.Transparency=0.15
local LIcon=Instance.new("TextLabel",LBig)
LIcon.Size=UDim2.new(1,0,1,0); LIcon.BackgroundTransparency=1; LIcon.Text="ND"
LIcon.Font=Enum.Font.GothamBlack; LIcon.TextSize=19; LIcon.TextColor3=T.ac0

local SelTitle=Instance.new("TextLabel",Card)
SelTitle.Size=UDim2.new(1,0,0,26); SelTitle.Position=UDim2.new(0,0,0,74)
SelTitle.BackgroundTransparency=1; SelTitle.Text="NATURE DUELS"
SelTitle.Font=Enum.Font.GothamBlack; SelTitle.TextSize=22; SelTitle.TextColor3=T.ac0

local SDW=Instance.new("Frame",Card)
SDW.Size=UDim2.new(0.8,0,0,1); SDW.Position=UDim2.new(0.1,0,0,106)
SDW.BackgroundColor3=T.ac2; SDW.BackgroundTransparency=0.35; SDW.BorderSizePixel=0
Instance.new("UICorner",SDW).CornerRadius=UDim.new(1,0)

local function MakeModeCard(yPos,iconTxt,titleTxt)
    local btn=Instance.new("TextButton",Card)
    btn.Size=UDim2.new(1,-28,0,66); btn.Position=UDim2.new(0,14,0,yPos)
    btn.BackgroundColor3=T.bg2; btn.Text=""; btn.BorderSizePixel=0; btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,13)
    local bS=Instance.new("UIStroke",btn); bS.Color=T.borderDim; bS.Thickness=1.2; bS.Transparency=0.4
    local bG=Instance.new("UIGradient",btn)
    bG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.bg2),ColorSequenceKeypoint.new(1,T.bg1)}; bG.Rotation=90
    local lBar=Instance.new("Frame",btn)
    lBar.Size=UDim2.new(0,3,0.5,0); lBar.Position=UDim2.new(0,0,0.25,0)
    lBar.BackgroundColor3=T.ac0; lBar.BackgroundTransparency=0.25; lBar.BorderSizePixel=0
    Instance.new("UICorner",lBar).CornerRadius=UDim.new(1,0)
    local ic=Instance.new("Frame",btn)
    ic.Size=UDim2.new(0,40,0,40); ic.Position=UDim2.new(0,12,0.5,-20)
    ic.BackgroundColor3=T.acOff; ic.BackgroundTransparency=0.3; ic.BorderSizePixel=0
    Instance.new("UICorner",ic).CornerRadius=UDim.new(1,0)
    local icS=Instance.new("UIStroke",ic); icS.Color=T.ac1; icS.Thickness=1; icS.Transparency=0.3
    local iL=Instance.new("TextLabel",ic)
    iL.Size=UDim2.new(1,0,1,0); iL.BackgroundTransparency=1; iL.Text=iconTxt
    iL.Font=Enum.Font.GothamBlack; iL.TextSize=13; iL.TextColor3=T.ac0
    local tl=Instance.new("TextLabel",btn)
    tl.Size=UDim2.new(1,-72,1,0); tl.Position=UDim2.new(0,62,0,0)
    tl.BackgroundTransparency=1; tl.Text=titleTxt; tl.Font=Enum.Font.GothamBold
    tl.TextSize=14; tl.TextColor3=txtPrime; tl.TextXAlignment=Enum.TextXAlignment.Left
    local ar=Instance.new("TextLabel",btn)
    ar.Size=UDim2.new(0,18,1,0); ar.Position=UDim2.new(1,-22,0,0)
    ar.BackgroundTransparency=1; ar.Text="â€º"; ar.Font=Enum.Font.GothamBold
    ar.TextSize=20; ar.TextColor3=T.ac0; ar.TextTransparency=0.5
    btn.MouseEnter:Connect(function() Tw(btn,0.14,{BackgroundColor3=T.bg3}); Tw(bS,0.14,{Transparency=0.05,Color=T.ac0}); Tw(ar,0.14,{TextTransparency=0}) end)
    btn.MouseLeave:Connect(function() Tw(btn,0.14,{BackgroundColor3=T.bg2}); Tw(bS,0.14,{Transparency=0.4,Color=T.borderDim}); Tw(ar,0.14,{TextTransparency=0.5}) end)
    return btn
end

local MobileBtn=MakeModeCard(118,"MB","Mobile Mode")
local PCBtn    =MakeModeCard(196,"PC","PC Mode")

Tw(Card,0.42,{Size=UDim2.new(0,CW,0,CH),Position=UDim2.new(0.5,-CW/2,0.5,-CH/2)},Enum.EasingStyle.Back)

local function Launch(mobile)
    isMobile=mobile
    Tw(Card,0.26,{Size=UDim2.new(0,CW,0,0),Position=UDim2.new(0.5,-CW/2,0.5,0)})
    Tw(Backdrop,0.26,{BackgroundTransparency=1})
    task.delay(0.3,function() pcall(function() SelGui:Destroy() end); BuildMainGUI() end)
end

MobileBtn.MouseButton1Click:Connect(function() Launch(true) end)
PCBtn.MouseButton1Click:Connect(function() Launch(false) end)

getgenv().StopNatureDuels=function()
    pcall(function() SelGui:Destroy() end)
    pcall(function() ParentUI:FindFirstChild("NatureDuels"):Destroy() end)
    if heartbeatConn    then heartbeatConn:Disconnect()    end
    if statusBarConn    then statusBarConn:Disconnect()    end
    if globalKeybindConn then globalKeybindConn:Disconnect() end
end
