--!strict
-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService        = game:GetService("GuiService")
local HttpService       = game:GetService("HttpService")
local Stats             = game:GetService("Stats")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")

-- LocalPlayer shortcuts
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- SCRIPT PURGE SYSTEM
-- (Ensures only one instance of the script runs to prevent conflicts)
-- ==========================================
if _G.Formega_Script_Purge then
    pcall(function() _G.Formega_Script_Purge() end)
    task.wait(0.2)
end

local ActiveConnections = {} -- Table to store all active connections for easy disconnection
local thisScriptStopped = false

-- ==========================================
-- CONFIGURATION GLOBALS
-- ==========================================
-- These are the shared _G variables used across the script.
-- They are initialized here, but their state is loaded/saved from settings.
_G.AutoResetOnBalloon = true
_G.AutoGiant          = false
_G.AutoBlock          = false
_G.AntiRagdoll        = false
_G.AutoBalloon        = false
_G.AP_ESP             = false
_G.AntiAdminPanel     = true -- Global toggle for the anti-admin panel

-- ==========================================
-- SAVE / LOAD SETTINGS
-- ==========================================
local SETTINGS_FILE = "hugos_script_settings.json"

local function loadSettings()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if ok and type(data) == "table" then return data end
    return {}
end

local function saveSettings()
    pcall(function()
        writefile(SETTINGS_FILE, HttpService:JSONEncode({
            AutoResetOnBalloon = _G.AutoResetOnBalloon,
            AutoGiant          = _G.AutoGiant,
            AutoBlock          = _G.AutoBlock,
            AntiRagdoll        = _G.AntiRagdoll,
            AutoBalloon        = _G.AutoBalloon,
            AP_ESP             = _G.AP_ESP,
            AntiAdminPanel     = _G.AntiAdminPanel, -- Save anti-admin setting
        }))
    end)
end

local savedSettings = loadSettings()

-- Apply loaded settings, or use default if not found
function applySetting(gVarName: string, default: any)
    if savedSettings[gVarName] ~= nil then
        _G[gVarName] = savedSettings[gVarName]
    else
        _G[gVarName] = default
    end
end

applySetting("AutoResetOnBalloon", true)
applySetting("AutoGiant", false)
applySetting("AutoBlock", false)
applySetting("AntiRagdoll", false)
applySetting("AutoBalloon", false)
applySetting("AP_ESP", false)
applySetting("AntiAdminPanel", true)

-- ==========================================
-- CURRENT CHARACTER DATA
-- ==========================================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid  = Character:WaitForChild("Humanoid")
local Root      = Character:WaitForChild("HumanoidRootPart")
local Camera    = Workspace.CurrentCamera

local autoStealEnabled  = false
local isStealing        = false
local currentMovement   = nil
local selectedPrompt    = nil
local selectedSlotNumber= nil

-- ==========================================
-- ANTI-ADMIN PANEL LOGIC
-- ==========================================
local antiGummyRespawnGraceUntil = 0
local originalScales             = {}
local originalHipHeight          = nil
local scaleNames = {
    "HeadScale", "BodyDepthScale", "BodyHeightScale",
    "BodyProportionScale", "BodyTypeScale", "BodyWidthScale",
}
local _ctrlCache = nil
local _charController, _jumpscareMod

local function captureOriginalScales()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    originalHipHeight = hum.HipHeight
    originalScales    = {}
    for _, name in ipairs(scaleNames) do
        local sv = hum:FindFirstChild(name)
        if sv then originalScales[name] = sv.Value end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    antiGummyRespawnGraceUntil = tick() + 1.5
    task.wait(0.1)
    captureOriginalScales()
end)
task.spawn(captureOriginalScales)

local function getControlsModule()
    if _ctrlCache then return _ctrlCache end
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    local pm = ps and ps:FindFirstChild("PlayerModule")
    if not pm then return nil end
    local ok, mod = pcall(require, pm)
    if not ok or not mod then return nil end
    local ok2, c = pcall(function() return mod:GetControls() end)
    if ok2 and c then _ctrlCache = c end
    return _ctrlCache
end
LocalPlayer.CharacterAdded:Connect(function() _ctrlCache = nil end)

local function _tryRequireCharController()
    if _charController ~= nil then return _charController end
    local ok, mod = pcall(function()
        return require(ReplicatedStorage
            :WaitForChild("Controllers")
            :WaitForChild("CharacterController"))
    end)
    _charController = ok and mod or false
    return _charController
end

local function _tryRequireJumpscare()
    if _jumpscareMod ~= nil then return _jumpscareMod end
    local ok, mod = pcall(function()
        return require(ReplicatedStorage
            :WaitForChild("Datas")
            :WaitForChild("AdminCommands")
            :WaitForChild("jumpscare"))
    end)
    _jumpscareMod = ok and mod or false
    return _jumpscareMod
end

-- Main anti-admin loop
task.spawn(function()
    while task.wait(0.1) do
        if not _G.AntiAdminPanel then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then continue end

        -- 1. Destroy ragdoll constraints, re-enable Motor6Ds
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then
                v:Destroy()
            elseif v:IsA("Motor6D") then
                v.Enabled = true
            end
        end

        -- 2. Re-enable controls (fixes lock/freeze)
        local ctrl = getControlsModule()
        if ctrl then pcall(function() ctrl:Enable() end) end

        -- 3. Force humanoid back to Running state
        local state = hum:GetState()
        if state ~= Enum.HumanoidStateType.Running
            and state ~= Enum.HumanoidStateType.Jumping
            and state ~= Enum.HumanoidStateType.Freefall then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end

        -- 4. Fix camera subject if hijacked
        if Workspace.CurrentCamera and Workspace.CurrentCamera.CameraSubject ~= hum then
            Workspace.CurrentCamera.CameraSubject = hum
        end

        -- 5. Clear ragdoll timer attribute
        local ragdollEnd = LocalPlayer:GetAttribute("RagdollEndTime") or 0
        if ragdollEnd > Workspace:GetServerTimeNow() then
            hrp.Velocity = Vector3.zero
            LocalPlayer:SetAttribute("RagdollEndTime", 0)
        end

        -- 6. Anti-inverse: restore moveFunction to un-inverted version
        local cc = _tryRequireCharController()
        if cc and ctrl then
            ctrl.moveFunction = function(p, x, z)
                cc:RequestMove(p, x, z)
            end
        end

        -- 7. Block jumpscare effect
        local jm = _tryRequireJumpscare()
        if jm and jm.effects and jm.effects.Victim then
            jm.effects.Victim = function() end
        end

        -- 8. Restore original body scales (blocks tiny/giant)
        if originalHipHeight and hum.HipHeight ~= originalHipHeight then
            hum.HipHeight = originalHipHeight
        end
        for _, name in ipairs(scaleNames) do
            local sv = hum:FindFirstChild(name)
            if sv and originalScales[name] and sv.Value ~= originalScales[name] then
                sv.Value = originalScales[name]
            end
        end

        -- 9. Destroy foreign model accessories added by admin commands
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Model") and not v:IsA("BackpackItem") then
                v:Destroy()
            end
        end
    end
end)

-- ==========================================
-- ANTI-RAGDOLL
-- ==========================================
local ragdollConns = {}
local lastRagdollClean = 0
local MAX_VEL = 40
local CLAMP_VEL = 25
local MAX_CLAMP = 15

local function connectAntiRagdollToChar(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root     = character:WaitForChild("HumanoidRootPart")
    local animator = humanoid:WaitForChild("Animator")
    local lastVelocity = Vector3.new(0,0,0)
    local isRag = false

    local function IsRagdollState()
        local state = humanoid:GetState()
        return state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown
            or state == Enum.HumanoidStateType.GettingUp
    end

    local function CleanRagdollEffects()
        local now = tick()
        if now - lastRagdollClean < 0.15 then return end
        lastRagdollClean = now
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint")
                or (obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B")) then
                obj:Destroy()
            elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                obj:Destroy()
            elseif obj:IsA("Motor6D") and not obj.Enabled then
                obj.Enabled = true
            end
        end
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            local animName = track.Animation and track.Animation.Name:lower() or ""
            if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") then
                track:Stop(0)
            end
        end
    end

    local function ReEnableControls()
        pcall(function()
            local controls = getControlsModule()
            if controls and not controls:GetEnabled() then
                controls:Enable()
            end
        end)
    end

    table.insert(ragdollConns, humanoid.StateChanged:Connect(function(_, newState)
        if not _G.AntiRagdoll then return end
        if IsRagdollState() then
            isRag = true
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            CleanRagdollEffects()
            Workspace.CurrentCamera.CameraSubject = humanoid
            ReEnableControls()
        else
            isRag = false
        end
    end))

    table.insert(ragdollConns, RunService.Heartbeat:Connect(function()
        if not _G.AntiRagdoll then return end
        if isRag then
            CleanRagdollEffects()
            local vel = root.AssemblyLinearVelocity
            if (vel - lastVelocity).Magnitude > MAX_VEL and vel.Magnitude > CLAMP_VEL then
                root.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, MAX_CLAMP)
            end
            lastVelocity = vel
        end
    end))

    table.insert(ragdollConns, character.DescendantAdded:Connect(function()
        if _G.AntiRagdoll and isRag then CleanRagdollEffects() end
    end))

    ReEnableControls()
    CleanRagdollEffects()
end

local function startAntiRagdoll()
    for _, conn in pairs(ragdollConns) do pcall(function() conn:Disconnect() end) end
    ragdollConns = {}
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    connectAntiRagdollToChar(c)
end

local function stopAntiRagdoll()
    for _, conn in pairs(ragdollConns) do pcall(function() conn:Disconnect() end) end
    ragdollConns = {}
end

local arCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    if not _G.AntiRagdoll then return end
    for _, conn in pairs(ragdollConns) do pcall(function() conn:Disconnect() end) end
    ragdollConns = {}
    task.spawn(function()
        connectAntiRagdollToChar(newChar)
    end)
end)
table.insert(ActiveConnections, arCharConn)

if _G.AntiRagdoll then task.spawn(startAntiRagdoll) end

-- ==========================================
-- AUTO BALLOON (NOX HUB INTEGRATION)
-- ==========================================
local stealZones = {
    {Shape = 'Line', Center = Vector3.new(-345.35, -6.55, 39.19), Size = 5, Rotation = 0},
    {Shape = 'Line', Center = Vector3.new(-350.53, -6.55, 38.67), Size = 20, Rotation = 0},
    {Shape = 'Line', Center = Vector3.new(-364.01, -6.55, 38.94), Size = 20, Rotation = 0},
    {Shape = 'Line', Center = Vector3.new(-337.34, -6.55, 39.18), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-365.29, -6.95, -10.40), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-354.68, -6.95, 6.22), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-343.15, -6.53, -13.20), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-344.93, -6.95, 25.73), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-343.76, -6.95, -10.27), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-354.42, -6.95, 6.51), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-340.48, -5.32, 28.10), Size = 20, Rotation = 0},
    {Shape = 'Square', Center = Vector3.new(-361.10, -6.95, 29.42), Size = 20, Rotation = 0},
    {Shape = 'Line', Center = Vector3.new(-354.83, 27.19, 31.22), Size = 20, Rotation = 0},
}

local balloonedPlayers = {}
local function isInAnyZone(position)
    for _, zone in ipairs(stealZones) do
        local half = zone.Size / 2
        local dx = math.abs(position.X - zone.Center.X)
        local dz = math.abs(position.Z - zone.Center.Z)
        if zone.Shape == 'Line' then
            if dx <= half and dz <= 1.5 then return true end
        elseif zone.Shape == 'Square' then
            if dx <= half and dz <= half then return true end
        end
    end
    return false
end

local function hasStealingMessage()
    for _, desc in pairs(PlayerGui:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text and string.find(desc.Text, "Someone is stealing your") then
            return true
        end
    end
    return false
end

local function findAdminPanel()
    return PlayerGui:FindFirstChild("AdminPanel")
end

local function findPlayerButton(targetPlayer)
    local adminPanel = findAdminPanel()
    if not adminPanel then return nil end
    for _, desc in pairs(adminPanel:GetDescendants()) do
        if desc:IsA("TextButton") or desc:IsA("ImageButton") then
            local t = ""
            if desc:IsA("TextButton") then t = desc.Text end
            if desc:IsA("ImageButton") then
                local lbl = desc:FindFirstChildWhichIsA("TextLabel", true)
                if lbl then t = lbl.Text end
            end
            if t and (t == targetPlayer.DisplayName or t:find(targetPlayer.DisplayName) or t == targetPlayer.Name or t:find(targetPlayer.Name)) then
                return desc
            end
        end
    end
    return nil
end

local function getCommandButtons()
    local btns = {}
    local adminPanel = findAdminPanel()
    if not adminPanel then return btns end
    for _, desc in ipairs(adminPanel:GetDescendants()) do
        if desc:IsA("TextButton") or desc:IsA("ImageButton") then
            local t = ""
            if desc:IsA("TextButton") then t = desc.Text end
            if desc:IsA("ImageButton") then
                local lbl = desc:FindFirstChildWhichIsA("TextLabel", true)
                if lbl then t = lbl.Text end
            end
            if t and (t:match("^:") or t:match("^;")) then
                table.insert(btns, {button = desc, name = t})
            end
        end
    end
    return btns
end

local function clickGUiButton(button)
    pcall(function() button.MouseButton1Click:Fire() end)
    pcall(function() button.Activated:Fire() end)
    if getconnections then
        for _, cx in pairs(getconnections(button.MouseButton1Click)) do cx:Fire() end
        for _, cx in pairs(getconnections(button.Activated)) do cx:Fire() end
    end
end

local function isExactCommand(buttonName, expectedCmdName)
    local bName = string.lower(string.match(buttonName, "^%s*(.-)%s*$") or buttonName)
    local cmdName = string.lower(expectedCmdName)
    return bName == cmdName or bName == ":"..cmdName or bName == ";"..cmdName or string.match(bName, "^[:;]?"..cmdName.."%s")
end

local function triggerBalloonOnTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Parent then return end
    if not findAdminPanel() then return end
    for _, cBtn in ipairs(getCommandButtons()) do
        if isExactCommand(cBtn.name, "balloon") then
            clickGUiButton(cBtn.button)
            task.wait(0.02)
            local pBtn = findPlayerButton(targetPlayer)
            if pBtn then clickGUiButton(pBtn) end
            break
        end
    end
end

local lastBalloonCheck = 0
RunService.Heartbeat:Connect(function()
    if not _G.AutoBalloon or thisScriptStopped then return end
    local now = tick()
    if now - lastBalloonCheck < 0.1 then return end
    lastBalloonCheck = now

    local hasMessage = hasStealingMessage()

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local character = p.Character
        if not character then continue end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("Torso")
        if not rootPart then continue end

        local targetKey = p.UserId
        local inZone = isInAnyZone(rootPart.Position)

        if inZone and hasMessage and not balloonedPlayers[targetKey] then
            balloonedPlayers[targetKey] = true
            triggerBalloonOnTarget(p)
        elseif (not inZone or not hasMessage) and balloonedPlayers[targetKey] then
            balloonedPlayers[targetKey] = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    balloonedPlayers[p.UserId] = nil
end)


-- ==========================================
-- FAST CONFIRM (for prompts like Block Player)
-- ==========================================
local function FastConfirm()
    local res = GuiService:GetScreenResolution()
    local x = res.X * 0.5
    local y = res.Y * 0.58
    for i = 1, 10 do
        if thisScriptStopped then break end
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        task.wait(0.01)
    end
end

-- ==========================================
-- GET NEAREST PLAYER
-- ==========================================
local function getNearestPlayer()
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then dist = d closest = plr end
        end
    end
    return closest
end

-- ==========================================
-- WAIT FOR STEAL PROMPT
-- ==========================================
local function waitForStealPrompt()
    -- Check existing prompts first
    for _, v in ipairs(CoreGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text and string.find(v.Text, "Steal") then return true end
    end
    local found = false
    local connection
    connection = CoreGui.DescendantAdded:Connect(function(v)
        if v:IsA("TextLabel") and v.Text and string.find(v.Text, "Steal") then found = true end
    end)
    table.insert(ActiveConnections, connection)
    while not found and not thisScriptStopped do task.wait(0.05) end
    if connection.Connected then pcall(function() connection:Disconnect() end) end -- Disconnect after finding or stopping
    return true
end

-- ==========================================
-- CHARACTER ADDED handling
-- ==========================================
local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    if currentMovement then pcall(function() currentMovement:Disconnect() end) currentMovement = nil end
    Character = newChar
    Humanoid  = newChar:WaitForChild("Humanoid")
    Root      = newChar:WaitForChild("HumanoidRootPart")
    Camera    = Workspace.CurrentCamera
    autoStealEnabled = false isStealing = false
    task.wait()
    if Root then
        local oldVelocity = Root:FindFirstChild("LinearVelocity")
        if oldVelocity then oldVelocity:Destroy() end
        local oldAttachment = Root:FindFirstChild("Attachment")
        if oldAttachment then oldAttachment:Destroy() end
    end
end)
table.insert(ActiveConnections, charAddedConn)

-- ==========================================
-- SLOTS CONFIG (Flash TP locations)
-- ==========================================
local SlotsConfig = {
    [1]  = { Positions = { Vector3.new(-345.4766,-6.0291,1.5014) }, CamOffset = Vector3.new(-354.1492,4.0350,9.3823)-Vector3.new(-345.4766,-6.0291,1.5014), CamAngles = {-0.827500,-0.640100,-0.576243} },
    [2]  = { Positions = { Vector3.new(-349.9259,-6.2791,-1.5767) }, CamOffset = Vector3.new(-363.2081,2.9403,3.3074)-Vector3.new(-349.9259,-6.2791,-1.5767), CamAngles = {-1.007271,-0.967909,-0.916433} },
    [3]  = { Positions = { Vector3.new(-349.9259,-6.2791,-1.5758) }, CamOffset = Vector3.new(-367.7556,4.3232,3.4983)-Vector3.new(-349.9259,-6.2791,-1.5758), CamAngles = {-1.062718,-1.041500,-0.997864} },
    [4]  = { Positions = { Vector3.new(-343.4199,-5.9197,10.5505) }, CamOffset = Vector3.new(-359.0885,4.0544,21.0001)-Vector3.new(-343.4199,-5.9197,10.5505), CamAngles = {-0.681953,-0.861073,-0.551998} },
    [5]  = { Positions = { Vector3.new(-343.7608,-6.3272,-9.7994) }, CamOffset = Vector3.new(-363.9226,-0.3924,-9.1459)-Vector3.new(-343.7608,-6.3272,-9.7994), CamAngles = {-1.424811,-1.351549,-1.421283} },
    [6]  = { Positions = { Vector3.new(-311.6442,-6.4281,52.8030), Vector3.new(-300.8487,-6.4281,36.7761) }, CamOffset = Vector3.new(-300.4433,6.4394,48.1955)-Vector3.new(-300.8487,-6.4281,36.7761), CamAngles = {-0.783560,0.025146,0.025045} },
    [7]  = { Positions = { Vector3.new(-344.4383,-6.4281,41.8672) }, CamOffset = Vector3.new(-362.8094,-3.2299,51.1552)-Vector3.new(-344.4383,-6.4281,41.8672), CamAngles = {-0.181885,-1.095968,-0.162135} },
    [8]  = { Positions = { Vector3.new(-348.5228,-6.4281,48.1022) }, CamOffset = Vector3.new(-369.4075,-0.1123,63.3763)-Vector3.new(-348.5228,-6.4281,48.1022), CamAngles = {-0.306020,-0.916511,-0.245634} },
    [9]  = { Positions = { Vector3.new(-339.6349,-6.4281,60.4164) }, CamOffset = Vector3.new(-349.9293,-1.6218,84.4119)-Vector3.new(-339.6349,-6.4281,60.4164), CamAngles = {-0.137335,-0.401849,-0.054002} },
    [10] = { Positions = { Vector3.new(-355.3322,-6.4281,25.3526) }, CamOffset = Vector3.new(-377.7117,8.9106,25.7208)-Vector3.new(-355.3322,-6.4281,25.3526), CamAngles = {-1.544218,-1.016502,-1.539540} },
    [11] = { Positions = { Vector3.new(-354.9932,-6.4281,-47.3879), Vector3.new(-331.5262,-6.4281,-47.3607) }, CamOffset = Vector3.new(-333.2372,-9.9613,-64.2099)-Vector3.new(-331.5262,-6.4281,-47.3607), CamAngles = {2.851853,-0.097011,3.112724} },
    [12] = { Positions = { Vector3.new(-354.9584,-6.4208,-42.6520), Vector3.new(-338.7290,-6.4281,-43.4713) }, CamOffset = Vector3.new(-346.9807,-9.9578,-60.5865)-Vector3.new(-338.7290,-6.4281,-43.4713), CamAngles = {2.856299,-0.433315,3.019061} },
    [13] = { Positions = { Vector3.new(-354.8862,-6.2793,-37.9787), Vector3.new(-334.5183,-6.4281,-41.6819) }, CamOffset = Vector3.new(-343.9747,-9.9590,-57.3332)-Vector3.new(-334.5183,-6.4281,-41.6819), CamAngles = {2.831168,-0.522070,2.982964} },
    [14] = { Positions = { Vector3.new(-351.8463,-6.5022,-37.0529), Vector3.new(-319.8298,-6.4281,-45.1476) }, CamOffset = Vector3.new(-325.1408,-9.9618,-60.9837)-Vector3.new(-319.8298,-6.4281,-45.1476), CamAngles = {2.834406,-0.309406,3.045298} },
    [15] = { Positions = { Vector3.new(-351.0894,-6.2833,-32.7751), Vector3.new(-317.9170,-6.4281,-41.9999) }, CamOffset = Vector3.new(-327.9996,-9.9581,-57.8876)-Vector3.new(-317.9170,-6.4281,-41.9999), CamAngles = {2.835549,-0.544183,2.979445} },
    [16] = { Positions = { Vector3.new(-338.2857,-6.4281,57.2060) }, CamOffset = Vector3.new(-341.5551,-9.9642,72.3530)-Vector3.new(-338.2857,-6.4281,57.2060), CamAngles = {0.320392,-0.202067,0.066497} },
    [17] = { Positions = { Vector3.new(-337.9285,-6.4281,55.1757) }, CamOffset = Vector3.new(-344.4950,-9.9637,69.4787)-Vector3.new(-337.9285,-6.4281,55.1757), CamAngles = {0.337895,-0.408747,0.138758} },
    [18] = { Positions = { Vector3.new(-332.1088,-6.4281,53.1675) }, CamOffset = Vector3.new(-338.8290,-9.9674,65.6692)-Vector3.new(-332.1088,-6.4281,53.1675), CamAngles = {0.382481,-0.462609,0.177644} },
    [19] = { Positions = { Vector3.new(-347.9923,-6.2933,-34.0232), Vector3.new(-328.5790,-6.4281,-35.0857) }, CamOffset = Vector3.new(-328.6130,-10.0174,-40.4923)-Vector3.new(-328.5790,-6.4281,-35.0857), CamAngles = {2.387391,-0.004579,3.137291}, NeedJump = true },
    [20] = { Positions = { Vector3.new(-355.0801,-6.4404,-33.2302), Vector3.new(-321.5783,-6.4281,-33.5778) }, CamOffset = Vector3.new(-321.6123,-10.0174,-38.9844)-Vector3.new(-321.5783,-6.4281,-33.5778), CamAngles = {2.387391,-0.004579,3.137291}, NeedJump = true },
    [21] = { Positions = { Vector3.new(-351.5396,-7.5033,-41.797), Vector3.new(-314.088,-7.5033,-32.1806) }, CamOffset = Vector3.new(-314.1147,-10.0174,-36.4214)-Vector3.new(-314.088,-7.5033,-32.1806), CamAngles = {2.387391,-0.004579,3.137291}, NeedJump = true },
    [22] = { Positions = { Vector3.new(-351.5396,-7.5033,-41.797), Vector3.new(-306.8919,-7.5033,-33.9124) }, CamOffset = Vector3.new(-306.923,-10.008,-38.86)-Vector3.new(-306.8919,-7.5033,-33.9124), CamAngles = {2.4648,-0.004898,3.137657}, NeedJump = true },
    [23] = { Positions = { Vector3.new(-351.5396,-7.5033,-41.797), Vector3.new(-300.2759,-7.5033,-32.7047) }, CamOffset = Vector3.new(-300.4669,-10.016,-37.044)-Vector3.new(-300.2759,-7.5033,-32.7047), CamAngles = {2.399014,-0.032413,3.111857}, NeedJump = true },
    [24] = { Positions = { Vector3.new(-348.2407,-7.5033,74.3719), Vector3.new(-330.0484,-7.5033,48.183) }, CamOffset = Vector3.new(-330.1124,-10.0063,53.2779)-Vector3.new(-330.0484,-7.5033,48.183), CamAngles = {0.662308,-0.00991,0.007727}, NeedJump = true },
    [25] = { Positions = { Vector3.new(-348.2407,-7.5033,74.3719), Vector3.new(-325.4576,-7.5033,46.8182) }, CamOffset = Vector3.new(-326.0541,-10.0104,51.5397)-Vector3.new(-325.4576,-7.5033,46.8182), CamAngles = {0.700033,-0.09632,0.080833}, NeedJump = true },
    [26] = { Positions = { Vector3.new(-348.2407,-7.5033,74.3719), Vector3.new(-324.6721,-7.5033,47.2033) }, CamOffset = Vector3.new(-326.6859,-10.0057,51.9385)-Vector3.new(-324.6721,-7.5033,47.2033), CamAngles = {0.698024,-0.314979,0.254268}, NeedJump = true },
    [27] = { Positions = { Vector3.new(-348.2407,-7.5033,74.3719), Vector3.new(-320.4196,-7.5033,44.1) }, CamOffset = Vector3.new(-322.9213,-10.0122,49.5157)-Vector3.new(-320.4196,-7.5033,44.1), CamAngles = {0.876985,-0.422603,0.397417} },
}

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================
local function findTool(name)
    if not Character then return nil end
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find(name:lower()) then return tool end
    end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find(name:lower()) then return tool end
    end
    return nil
end

local function isMyPlot(plot)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled then return true end
    end
    return false
end

local function isValidStealPrompt(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return false end
    local state      = prompt:GetAttribute("State")
    local actionText = prompt.ActionText
    if state == "Steal" or state == "Grab" or actionText == "Steal" or actionText == "Grab" then return true end
    return false
end

local function firePromptConnections(prompt, signalName)
    if not getconnections then return end
    local connections = getconnections(prompt[signalName])
    for _, conn in ipairs(connections) do
        if conn.Function then task.spawn(conn.Function) end
    end
end

local STEAL_DELAY = 1.30
local function executeSteal(prompt)
    if isStealing or not prompt or not prompt.Parent then return end
    isStealing = true
    firePromptConnections(prompt, "PromptButtonHoldBegan")
    task.wait(STEAL_DELAY)
    if prompt and prompt.Parent and prompt.Enabled and not thisScriptStopped then
        firePromptConnections(prompt, "Triggered")
    end
    isStealing = false
end

local STOP_DIST = 5
local SLOW_DIST = 20

-- ==========================================
-- PLAYER RESET FUNCTION
-- ==========================================
local function doReset()
    local lp  = LocalPlayer
    local Net = ReplicatedStorage:WaitForChild("Packages", 2):WaitForChild("Net", 2)
    local remote
    local childs = Net:GetChildren()
    for i = 1, #childs - 1 do
        if childs[i] and childs[i+1] and childs[i].Name:find("Tools/Cooldown") then
            remote = childs[i+1]; break
        end
    end
    if not remote then
        local h = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
        if h then h.Health = 0 end
        return
    end
    local savedTools = {}
    local char  = lp.Character
    local bp    = lp:FindFirstChild("Backpack")
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:UnequipTools() end) end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
        end
    end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
        end
    end
    lp.Character = nil
    local sending  = true
    local throttle = 0
    local loop
    loop = RunService.Heartbeat:Connect(function(dt)
        if thisScriptStopped then pcall(function() loop:Disconnect() end) return end
        if not sending then return end
        throttle = throttle + dt
        if throttle >= 0.1 then
            throttle = 0
            pcall(function() remote:FireServer("f888ee6e-c86d-46e1-93d7-0639d6635d42", lp, "balloon") end)
        end
        if lp.Character then lp.Character = nil end
    end)
    table.insert(ActiveConnections, loop)
    local conn
    conn = lp.CharacterAdded:Connect(function()
        sending = false
        pcall(function() loop:Disconnect() end)
        pcall(function() conn:Disconnect() end)
        task.spawn(function()
            local newBp = lp:WaitForChild("Backpack", 3)
            if newBp then for _, t in ipairs(savedTools) do if t then t.Parent = newBp end end end
        end)
    end)
    table.insert(ActiveConnections, conn)
    task.delay(4, function()
        sending = false
        pcall(function() loop:Disconnect() end)
        local curBp = lp:FindFirstChild("Backpack")
        if curBp then for _, t in ipairs(savedTools) do if t then t.Parent = curBp end end end
    end)
end

-- ==========================================
-- AUTO RESET ON BALLOON
-- ==========================================
local balloonConnection
balloonConnection = LocalPlayer:GetAttributeChangedSignal("Balloon"):Connect(function()
    if thisScriptStopped then pcall(function() balloonConnection:Disconnect() end) return end
    if _G.AutoResetOnBalloon == true and LocalPlayer:GetAttribute("Balloon") == true then doReset() end
end)
table.insert(ActiveConnections, balloonConnection)

-- ==========================================
-- START TRIP TO PET SLOT (FLASH TP)
-- ==========================================
local function startTripToPetSlot(prompt, slotNumber)
    local config          = SlotsConfig[slotNumber] or SlotsConfig[1] -- Default to slot 1 if invalid
    local targetPositions = config.Positions or { config.Position }
    local needJump        = config.NeedJump == true

    if currentMovement then pcall(function() currentMovement:Disconnect() end) currentMovement = nil end
    if not Root or not Humanoid then return end

    autoStealEnabled = true
    local speed            = 200
    local grabStartDistance= 60
    local grabStarted      = false

    local carpet = findTool("flying carpet")
    if carpet then Humanoid:UnequipTools() task.wait(0.03) Humanoid:EquipTool(carpet) end

    if Root:FindFirstChild("LinearVelocity") then Root.LinearVelocity:Destroy() end
    if Root:FindFirstChild("Attachment")     then Root.Attachment:Destroy() end

    local Attachment = Instance.new("Attachment")
    Attachment.Parent = Root

    local Velocity = Instance.new("LinearVelocity")
    Velocity.Attachment0     = Attachment
    Velocity.RelativeTo      = Enum.ActuatorRelativeTo.World
    Velocity.MaxForce        = math.huge
    Velocity.Parent          = Root

    local currentPosIndex       = 1
    local intermediatePauseActive = false

    local movementLoop
    movementLoop = RunService.Heartbeat:Connect(function()
        if thisScriptStopped or not Root or not Humanoid or not Root.Parent or Humanoid.Health <= 0 then
            pcall(function() movementLoop:Disconnect() end)
            if Velocity.Parent then Velocity:Destroy() end
            if Attachment.Parent then Attachment:Destroy() end
            return
        end
        if intermediatePauseActive then Velocity.VectorVelocity = Vector3.zero return end

        local TargetPosition = targetPositions[currentPosIndex]
        if not TargetPosition then
            pcall(function() movementLoop:Disconnect() end)
            if Velocity.Parent then Velocity:Destroy() end
            if Attachment.Parent then Attachment:Destroy() end
            return
        end

        local rootPos = Root.Position
        local dir     = Vector3.new(TargetPosition.X - rootPos.X, 0, TargetPosition.Z - rootPos.Z)
        local dist    = dir.Magnitude

        if currentPosIndex == 1 and dist <= grabStartDistance and not grabStarted then
            grabStarted = true
            task.spawn(function() executeSteal(prompt) end)
        end

        local speedMult = 1
        if dist < SLOW_DIST then speedMult = math.max(0.15, dist / SLOW_DIST) end

        if dist <= STOP_DIST then
            if currentPosIndex < #targetPositions then
                intermediatePauseActive = true
                Velocity.VectorVelocity = Vector3.zero
                Root.AssemblyLinearVelocity = Vector3.zero
                task.spawn(function()
                    currentPosIndex = currentPosIndex + 1
                    intermediatePauseActive = false
                end)
                return
            end

            Velocity.VectorVelocity = Vector3.zero
            Root.AssemblyLinearVelocity = Vector3.zero
            if Velocity.Parent then Velocity:Destroy() end
            if Attachment.Parent then Attachment:Destroy() end
            if movementLoop.Connected then pcall(function() movementLoop:Disconnect() end) end

            Root.CFrame = CFrame.new(TargetPosition)
            task.wait(0.12)
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(Root.Position + config.CamOffset) * CFrame.Angles(unpack(config.CamAngles))
            Humanoid:UnequipTools()
            task.wait(0.06)

            if needJump then
                Root.AssemblyLinearVelocity = Vector3.new(0, 55, 0)
                task.wait(0.08)
            end

            local flash = findTool("flash")
            if flash then
                Humanoid:EquipTool(flash)
                task.wait(0.08)
                flash:Activate()
            end

            task.wait(0.1)

            if _G.AutoGiant then
                local giant = findTool("giant potion")
                if giant then
                    Humanoid:EquipTool(giant) task.wait(0.08) giant:Activate()
                    task.wait(0.05) Humanoid:UnequipTools()
                end
            end

            Camera.CameraType = Enum.CameraType.Custom

            if _G.AutoBlock then
                task.spawn(function()
                    task.wait(0.13)
                    local target = getNearestPlayer()
                    if target then
                        waitForStealPrompt()
                        pcall(function() StarterGui:SetCore("PromptBlockPlayer", target) end)
                        FastConfirm()
                    end
                end)
            end

            task.spawn(function() task.wait(1.0) autoStealEnabled = false end)
            return
        end

        Velocity.VectorVelocity = Vector3.new(dir.Unit.X * speed * speedMult, 0, dir.Unit.Z * speed * speedMult)
    end)
    currentMovement = movementLoop
    table.insert(ActiveConnections, currentMovement)
end

-- ==========================================
-- UPDATE PET LIST (Brainrots tab)
-- ==========================================
local petListScrollFrame = nil -- Renamed for clarity

local function updatePetList()
    if isStealing or autoStealEnabled or thisScriptStopped or not petListScrollFrame then return end

    -- Clear existing items
    for _, child in ipairs(petListScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local tempPets = {}
    local players = Players:GetPlayers()
    local playerNames = {}
    for _, p in ipairs(players) do playerNames[p.Name] = true end

    -- Function to detect "brainrot" (stray models indicating a player being brainrotted)
    local function hasBrainrot(targetPlayer)
        if not targetPlayer.Character then return false end
        local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and not playerNames[v.Name] and not v:IsDescendantOf(targetPlayer.Character) then
                local rp = v:FindFirstChild("RootPart") or v:FindFirstChild("FakeRootPart")
                if rp and (rp.Position - root.Position).Magnitude < 8 then
                    return true
                end
            end
        end
        return false
    end


    local plotsFolder = Workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            if not isMyPlot(plot) then
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    for _, podium in ipairs(podiums:GetChildren()) do
                        local slotNumber  = tonumber(podium.Name:match("%d+")) or 1
                        local base        = podium:FindFirstChild("Base") or podium
                        local spawnPoint  = base:FindFirstChild("Spawn")
                        local attachment  = spawnPoint and spawnPoint:FindFirstChild("PromptAttachment")
                        if attachment then
                            for _, child in ipairs(attachment:GetChildren()) do
                                if child:IsA("ProximityPrompt") and isValidStealPrompt(child) then
                                    local petName = child.ObjectText or "Pet"
                                    local owner = Players:GetPlayerFromCharacter(child.Parent.Parent.Parent) or players[1] -- Simplified owner check
                                    if owner and hasBrainrot(owner) then -- Only list if the owner has brainrot
                                        table.insert(tempPets, { prompt = child, slot = slotNumber, name = petName, owner = owner.Name })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(tempPets, function(a, b) return a.slot < b.slot end)

    local C_list = {
        card   = Color3.fromRGB(14, 20, 40),
        accent = Color3.fromRGB(50, 120, 255),
        stroke = Color3.fromRGB(30, 50, 100),
        bright = Color3.fromRGB(220, 235, 255),
        mute   = Color3.fromRGB(80, 110, 170),
    }

    for _, petData in ipairs(tempPets) do
        if thisScriptStopped then break end
        local isSelected = (selectedPrompt == petData.prompt)

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 48)
        row.BackgroundColor3 = isSelected and Color3.fromRGB(10, 30, 80) or C_list.card
        row.BorderSizePixel = 0
        row.Parent = petListScrollFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local rStroke = Instance.new("UIStroke")
        rStroke.Color     = isSelected and C_list.accent or C_list.stroke
        rStroke.Thickness = isSelected and 1.5 or 1
        rStroke.Parent    = row

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text               = petData.name
        nameLabel.Size               = UDim2.new(1, -10, 0, 24)
        nameLabel.Position           = UDim2.new(0, 10, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3         = isSelected and C_list.bright or C_list.accent
        nameLabel.Font               = Enum.Font.GothamBold
        nameLabel.TextSize           = 14
        nameLabel.TextXAlignment     = Enum.TextXAlignment.Left
        nameLabel.Parent             = row

        local slotLabel = Instance.new("TextLabel")
        slotLabel.Text               = "Slot " .. petData.slot .. " (" .. petData.owner .. ")"
        slotLabel.Size               = UDim2.new(1, -10, 0, 20)
        slotLabel.Position           = UDim2.new(0, 10, 0, 22)
        slotLabel.BackgroundTransparency = 1
        slotLabel.TextColor3         = C_list.mute
        slotLabel.Font               = Enum.Font.GothamMedium
        slotLabel.TextSize           = 11
        slotLabel.TextXAlignment     = Enum.TextXAlignment.Left
        slotLabel.Parent             = row

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size               = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text               = ""
        clickBtn.BorderSizePixel    = 0
        clickBtn.Parent             = row

        local rowBtnConn = clickBtn.MouseButton1Click:Connect(function()
            if not isStealing and not autoStealEnabled then
                selectedPrompt     = petData.prompt
                selectedSlotNumber = petData.slot
                updatePetList()
            end
        end)
        table.insert(ActiveConnections, rowBtnConn)
    end

    if #tempPets == 0 then
        local emptyCard = Instance.new("Frame")
        emptyCard.Name             = "EmptyCard"
        emptyCard.Size             = UDim2.new(1, -8, 0, 120)
        emptyCard.BackgroundColor3 = C_list.card
        emptyCard.BorderSizePixel  = 0
        emptyCard.ZIndex           = 4
        emptyCard.Parent           = petListScrollFrame
        Instance.new("UICorner", emptyCard).CornerRadius = UDim.new(0, 10)
        local es = Instance.new("UIStroke"); es.Color = C_list.stroke; es.Parent = emptyCard

        local iconCircle = Instance.new("Frame")
        iconCircle.Size             = UDim2.new(0, 40, 0, 40)
        iconCircle.Position         = UDim2.new(0.5, -20, 0, 18)
        iconCircle.BackgroundColor3 = Color3.fromRGB(14, 24, 55)
        iconCircle.BorderSizePixel  = 0
        iconCircle.ZIndex           = 5
        iconCircle.Parent           = emptyCard
        Instance.new("UICorner", iconCircle).CornerRadius = UDim.new(0, 20)
        local is = Instance.new("UIStroke"); is.Color = C_list.stroke; is.Parent = iconCircle

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size               = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.ZIndex             = 6
        iconLabel.Text               = "⚡" -- Lightning bolt
        iconLabel.TextColor3         = C_list.accent
        iconLabel.TextSize           = 18
        iconLabel.Font               = Enum.Font.GothamBold
        iconLabel.Parent             = iconCircle

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size               = UDim2.new(1, -16, 0, 22)
        titleLabel.Position           = UDim2.new(0, 8, 0, 64)
        titleLabel.BackgroundTransparency = 1
        titleLabel.ZIndex             = 5
        titleLabel.Text               = "No Brainrots Found"
        titleLabel.TextColor3         = C_list.bright
        titleLabel.TextSize           = 13
        titleLabel.Font               = Enum.Font.GothamMedium
        titleLabel.Parent             = emptyCard

        local subLabel = Instance.new("TextLabel")
        subLabel.Size               = UDim2.new(1, -16, 0, 18)
        subLabel.Position           = UDim2.new(0, 8, 0, 86)
        subLabel.BackgroundTransparency = 1
        subLabel.ZIndex             = 5
        subLabel.Text               = "No players with brainrots currently detected in plots."
        subLabel.TextColor3         = C_list.mute
        subLabel.TextSize           = 11
        subLabel.Font               = Enum.Font.Gotham
        subLabel.Parent             = emptyCard
    end
end

-- ==========================================
-- GUI DESIGN CONFIGURATION
-- ==========================================
-- Remove old GUIs if they exist
for _, guiName in ipairs({"HUGO’S SCRIPT", "HugoHubBanner", "NOX_HUB"}) do
    local oldGui = PlayerGui:FindFirstChild(guiName)
    if oldGui then oldGui:Destroy() end
end

local UI_COLORS = {
    accent     = Color3.fromRGB(50, 120, 255),  -- Bright blue for highlights
    accentHi   = Color3.fromRGB(80, 160, 255),  -- Lighter blue for hover
    deepBlue   = Color3.fromRGB(10, 20, 60),    -- Dark blue for depth
    body       = Color3.fromRGB(5, 8, 18),      -- Main background dark
    panel      = Color3.fromRGB(8, 12, 24),     -- Panel darker for contrast
    tabBar     = Color3.fromRGB(6, 9, 20),      -- Tab bar color
    card       = Color3.fromRGB(14, 20, 40),    -- Card background for list items
    iconBg     = Color3.fromRGB(14, 24, 55),    -- Icon background
    stroke     = Color3.fromRGB(30, 50, 100),   -- Borders and lines
    strokeDim  = Color3.fromRGB(20, 32, 65),    -- Dimmer strokes
    textBright = Color3.fromRGB(220, 235, 255), -- Bright text
    textBlue   = Color3.fromRGB(100, 170, 255), -- Blue text for active states
    textMute   = Color3.fromRGB(80, 110, 170),  -- Muted text for descriptions
    textDim    = Color3.fromRGB(50, 75, 130),   -- Dimmer text for inactive
    knobOn     = Color3.fromRGB(200, 225, 255), -- Toggle knob when ON
    knobOff    = Color3.fromRGB(60, 75, 110),   -- Toggle knob when OFF
    trackOff   = Color3.fromRGB(18, 26, 50),    -- Toggle track when OFF
}

local borderGradientSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    UI_COLORS.accentHi),
    ColorSequenceKeypoint.new(0.25, UI_COLORS.deepBlue),
    ColorSequenceKeypoint.new(0.5,  UI_COLORS.accent),
    ColorSequenceKeypoint.new(0.75, UI_COLORS.deepBlue),
    ColorSequenceKeypoint.new(1,    UI_COLORS.accentHi),
})

local function getDeviceType()
    local screen = Workspace.CurrentCamera.ViewportSize
    local w, h = screen.X, screen.Y
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isMobile then
        if w >= 900 or h >= 900 then return "ipad" end
        return "mobile"
    end
    return "pc"
end

local DEVICE_TYPE = getDeviceType()

local LAYOUT_PRESETS = {
    pc = {
        winW = 340, winH = 480,
        posX = UDim2.new(0.5, 0, 0.5, 0),
        bannerW = 332, bannerH = 82, -- Adjusted for main window size
        bannerPos = UDim2.new(0.5, -151, 0, 60), -- Adjusted
        btnSize = 100, btnH = 40,
        tabH = 36, headerH = 47,
        actionXs = {8, 116, 224}, -- {8, 126, 244} when 3 tabs
        textSize = { header = 11, btn = 12, tab = 12, title = 20 },
    },
    ipad = {
        winW = 300, winH = 420,
        posX = UDim2.new(0.5, 0, 0.5, 0),
        bannerW = 292, bannerH = 76,
        bannerPos = UDim2.new(0.5, -130, 0, 50),
        btnSize = 90, btnH = 38,
        tabH = 32, headerH = 45,
        actionXs = {7, 104, 201},
        textSize = { header = 11, btn = 11, tab = 11, title = 18 },
    },
    mobile = {
        winW = 260, winH = 360,
        posX = UDim2.new(0.5, 0, 0.5, 0),
        bannerW = 252, bannerH = 70,
        bannerPos = UDim2.new(0.5, -110, 0, 40),
        btnSize = 80, btnH = 36,
        tabH = 30, headerH = 42,
        actionXs = {6, 92, 178},
        textSize = { header = 10, btn = 10, tab = 10, title = 16 },
    },
}

local L = LAYOUT_PRESETS[DEVICE_TYPE]

local MAIN_GUI = Instance.new("ScreenGui")
MAIN_GUI.Name           = "HUGO_SCRIPT_GUI"
MAIN_GUI.SelectionGroup = false
MAIN_GUI.ResetOnSpawn   = false
MAIN_GUI.DisplayOrder   = 999
MAIN_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MAIN_GUI.IgnoreGuiInset = false
MAIN_GUI.Parent         = PlayerGui

-- Main UI Frame (Window)
local Window = Instance.new("Frame")
Window.Name             = "Window"
Window.Size             = UDim2.new(0, L.winW, 0, L.winH)
Window.Position         = L.posX
Window.AnchorPoint      = Vector2.new(0.5, 0.5)
Window.BackgroundTransparency = 1
Window.BorderSizePixel  = 0
Window.ZIndex           = 2
Window.ClipsDescendants = false
Window.Active           = false
Window.Selectable       = false
Window.Parent           = MAIN_GUI

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = UI_COLORS.body
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.Active           = false
MainFrame.Selectable       = false
MainFrame.Parent           = Window
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 13)

-- Top Header with Title and Control Buttons
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name             = "HeaderFrame"
HeaderFrame.Size             = UDim2.new(1, 0, 0, L.headerH)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.BorderSizePixel  = 0
HeaderFrame.ZIndex           = 3
HeaderFrame.ClipsDescendants = false
HeaderFrame.Active           = true -- Make it active for dragging
HeaderFrame.Selectable       = false
HeaderFrame.Parent           = MainFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size             = UDim2.new(1, 0, 0, 1)
HeaderLine.Position         = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = UI_COLORS.stroke
HeaderLine.BorderSizePixel  = 0
HeaderLine.ZIndex           = 4
HeaderLine.Parent           = HeaderFrame

local LogoCircleInner = Instance.new("Frame")
LogoCircleInner.Size             = UDim2.new(0, 6, 0, 6)
LogoCircleInner.Position         = UDim2.new(0, 9, 0.5, -3)
LogoCircleInner.BackgroundColor3 = UI_COLORS.accent
LogoCircleInner.BorderSizePixel  = 0
LogoCircleInner.ZIndex           = 5
LogoCircleInner.Parent           = HeaderFrame
Instance.new("UICorner", LogoCircleInner).CornerRadius = UDim.new(0, 4)

local LogoCircleOuter = Instance.new("Frame")
LogoCircleOuter.Size                 = UDim2.new(0, 12, 0, 12)
LogoCircleOuter.Position             = UDim2.new(0, 7, 0.5, -6)
LogoCircleOuter.BackgroundColor3     = UI_COLORS.accent
LogoCircleOuter.BackgroundTransparency = 0.75
LogoCircleOuter.BorderSizePixel      = 0
LogoCircleOuter.ZIndex               = 4
LogoCircleOuter.Parent               = HeaderFrame
Instance.new("UICorner", LogoCircleOuter).CornerRadius = UDim.new(0, 7)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(0, 120, 1, 0)
TitleLabel.Position           = UDim2.new(0, 24, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.ZIndex             = 5
TitleLabel.Text               = "HUGO'S SCRIPT"
TitleLabel.TextColor3         = UI_COLORS.textBright
TitleLabel.TextSize           = L.textSize.header
TitleLabel.Font               = Enum.Font.GothamBold
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.Parent             = HeaderFrame

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size               = UDim2.new(1, -163, 1, 0)
SubtitleLabel.Position           = UDim2.new(0, 115, 0, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.ZIndex             = 5
SubtitleLabel.Text               = '<font color="rgb(50,120,255)">PVP</font>'
SubtitleLabel.TextColor3         = UI_COLORS.textBright
SubtitleLabel.TextSize           = L.textSize.header
SubtitleLabel.Font               = Enum.Font.GothamBold
SubtitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
SubtitleLabel.RichText           = true
SubtitleLabel.Parent             = HeaderFrame

local HEADER_BTN_SIZE = DEVICE_TYPE == "mobile" and 20 or 22
local function createHeaderButton(name, txt, xOff)
    local btn = Instance.new("TextButton")
    btn.Name            = name
    btn.Size            = UDim2.new(0, HEADER_BTN_SIZE, 0, HEADER_BTN_SIZE)
    btn.Position        = UDim2.new(1, xOff, 0.5, -HEADER_BTN_SIZE/2)
    btn.BackgroundColor3= UI_COLORS.card
    btn.BorderSizePixel = 0
    btn.ZIndex          = 6
    btn.Text            = txt
    btn.TextColor3      = UI_COLORS.textMute
    btn.TextSize        = L.textSize.header
    btn.Font            = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent          = HeaderFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke"); stroke.Color = UI_COLORS.stroke; stroke.Parent = btn
    return btn
end

local HEADER_BTN_OFFSETS = DEVICE_TYPE == "mobile" and {-64, -42, -20} or {-70, -46, -22}
local LockButton  = createHeaderButton("Lock",  "🔒", HEADER_BTN_OFFSETS[1])
local MinimizeButton = createHeaderButton("Minimize",   "—",  HEADER_BTN_OFFSETS[2])
local CloseButton = createHeaderButton("Close", "X",  HEADER_BTN_OFFSETS[3])

-- Action Buttons (Flash TP, Block, Reset)
local ActionButtonsFrame = Instance.new("Frame")
ActionButtonsFrame.Name             = "ActionButtonsFrame"
ActionButtonsFrame.Size             = UDim2.new(1, 0, 0, 69)
ActionButtonsFrame.Position         = UDim2.new(0, 0, 0, L.headerH - L.tabH/2) -- Position below header
ActionButtonsFrame.BackgroundTransparency = 1
ActionButtonsFrame.BorderSizePixel  = 0
ActionButtonsFrame.ZIndex           = 4
ActionButtonsFrame.Parent           = MainFrame

local ActionButtonsLine = Instance.new("Frame")
ActionButtonsLine.Size             = UDim2.new(1, 0, 0, 1)
ActionButtonsLine.Position         = UDim2.new(0, 0, 0, 55)
ActionButtonsLine.BackgroundColor3 = UI_COLORS.stroke
ActionButtonsLine.BorderSizePixel  = 0
ActionButtonsLine.ZIndex           = 4
ActionButtonsLine.Parent           = ActionButtonsFrame

local function createActionButton(name, label, xPos, btnWidth)
    local btn = Instance.new("TextButton")
    btn.Name            = name
    btn.Size            = UDim2.new(0, btnWidth, 0, L.btnH)
    btn.Position        = UDim2.new(0, xPos, 0, 8)
    btn.BackgroundColor3= UI_COLORS.card
    btn.BorderSizePixel = 0
    btn.ZIndex          = 5
    btn.Text            = ""
    btn.AutoButtonColor = false
    btn.Parent          = ActionButtonsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = UI_COLORS.stroke
    local topLine = Instance.new("Frame")
    topLine.Size             = UDim2.new(1, -10, 0, 2)
    topLine.Position         = UDim2.new(0, 5, 0, 0)
    topLine.BackgroundColor3 = UI_COLORS.stroke
    topLine.BorderSizePixel  = 0
    topLine.ZIndex           = 6
    topLine.Parent           = btn
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(0, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex           = 7
    lbl.Text             = label
    lbl.TextColor3       = UI_COLORS.textBright
    lbl.TextSize         = L.textSize.btn
    lbl.Font             = Enum.Font.GothamBold
    lbl.Parent           = btn
    return btn, topLine
end

local FlashTPButton, FlashTPAccent = createActionButton("FlashTP", "FLASH TP", L.actionXs[1], L.btnSize)
local BlockButton,   BlockAccent   = createActionButton("Block",   "BLOCK",    L.actionXs[2], L.btnSize)
local ResetButton,   ResetAccent   = createActionButton("Reset",   "RESET",    L.actionXs[3], L.btnSize)

-- Tab Bar (Brainrots / Settings)
local TabBarFrame = Instance.new("Frame")
TabBarFrame.Size             = UDim2.new(1, 0, 0, L.tabH)
TabBarFrame.Position         = UDim2.new(0, 0, 0, L.headerH + L.btnH/2 + 20) -- Position below action buttons
TabBarFrame.BackgroundColor3 = UI_COLORS.tabBar
TabBarFrame.BorderSizePixel  = 0
TabBarFrame.ZIndex           = 5
TabBarFrame.Parent           = MainFrame
local TabListLayout = Instance.new("UIListLayout", TabBarFrame)
TabListLayout.SortOrder        = Enum.SortOrder.LayoutOrder
TabListLayout.FillDirection    = Enum.FillDirection.Horizontal
TabListLayout.VerticalAlignment= Enum.VerticalAlignment.Center
TabListLayout.FlexWrapping     = Enum.FlexWrapping.Wrap -- Allow wrapping if tabs exceed width

local function createTabButton(name, text, layoutOrder, isActive)
    local btn = Instance.new("TextButton")
    btn.Name             = name
    btn.Size             = UDim2.new(0.5, 0, 1, 0) -- Adjust size to fit two buttons in width
    btn.BackgroundColor3 = UI_COLORS.tabBar
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 5
    btn.LayoutOrder      = layoutOrder
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.Parent           = TabBarFrame
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex             = 6
    lbl.Text               = text
    lbl.TextColor3         = isActive and UI_COLORS.textBlue or UI_COLORS.textDim
    lbl.TextSize           = L.textSize.tab
    lbl.Font               = Enum.Font.GothamMedium
    lbl.Parent             = btn
    local indicator = Instance.new("Frame")
    indicator.Size             = UDim2.new(1, -16, 0, 2)
    indicator.Position         = UDim2.new(0, 8, 1, -2)
    indicator.BackgroundColor3 = UI_COLORS.accent
    indicator.BackgroundTransparency = isActive and 0 or 1
    indicator.BorderSizePixel  = 0
    indicator.ZIndex           = 7
    indicator.Parent           = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 1)
    return btn, lbl, indicator
end

local BrainrotsTabBtn, BrainrotsTabText, BrainrotsTabIndicator = createTabButton("BrainrotsTab", "Brainrots", 1, true)
local SettingsTabBtn,  SettingsTabText,  SettingsTabIndicator  = createTabButton("SettingsTab",  "Settings",  2, false)

local ContentAreaFrame = Instance.new("Frame")
ContentAreaFrame.Size             = UDim2.new(1, 0, 1, - (L.headerH + L.btnH/2 + 20 + L.tabH + 5)) -- Adjust height based on header, actions, and tabs
ContentAreaFrame.Position         = UDim2.new(0, 0, 0, L.headerH + L.btnH/2 + 20 + L.tabH + 5)
ContentAreaFrame.BackgroundTransparency = 1
ContentAreaFrame.BorderSizePixel  = 0
ContentAreaFrame.ZIndex           = 2
ContentAreaFrame.ClipsDescendants = true
ContentAreaFrame.Parent           = MainFrame

-- Brainrots Tab Content
local BrainrotsContentFrame = Instance.new("Frame")
BrainrotsContentFrame.Name             = "BrainrotsContent"
BrainrotsContentFrame.Size             = UDim2.new(1, 0, 1, 0)
BrainrotsContentFrame.BackgroundTransparency = 1
BrainrotsContentFrame.BorderSizePixel  = 0
BrainrotsContentFrame.ZIndex           = 3
BrainrotsContentFrame.Parent           = ContentAreaFrame

local PetScrollingFrame = Instance.new("ScrollingFrame")
PetScrollingFrame.Name                  = "PetListScrollingFrame"
PetScrollingFrame.Size                  = UDim2.new(1, 0, 1, 0)
PetScrollingFrame.BackgroundTransparency= 1
PetScrollingFrame.BorderSizePixel       = 0
PetScrollingFrame.Active                = false
PetScrollingFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
PetScrollingFrame.ScrollBarThickness    = 3
PetScrollingFrame.ScrollBarImageColor3  = UI_COLORS.accent
PetScrollingFrame.ScrollingDirection    = Enum.ScrollingDirection.Y
PetScrollingFrame.AutomaticCanvasSize   = Enum.AutomaticSize.Y
PetScrollingFrame.Parent                = BrainrotsContentFrame

local PetListLayout = Instance.new("UIListLayout", PetScrollingFrame)
PetListLayout.SortOrder           = Enum.SortOrder.LayoutOrder
PetListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PetListLayout.Padding             = UDim.new(0, 4)

local PetListPadding = Instance.new("UIPadding", PetScrollingFrame)
PetListPadding.PaddingTop    = UDim.new(0, 6)
PetListPadding.PaddingBottom = UDim.new(0, 6)
PetListPadding.PaddingLeft   = UDim.new(0, 4)
PetListPadding.PaddingRight  = UDim.new(0, 4)

petListScrollFrame = PetScrollingFrame -- Assign to global ref

-- Settings Tab Content
local SettingsContentFrame = Instance.new("Frame")
SettingsContentFrame.Name             = "SettingsContent"
SettingsContentFrame.Size             = UDim2.new(1, 0, 1, 0)
SettingsContentFrame.Position         = UDim2.new(1, 0, 0, 0) -- Initially off-screen
SettingsContentFrame.BackgroundTransparency = 1
SettingsContentFrame.BorderSizePixel  = 0
SettingsContentFrame.Visible          = false
SettingsContentFrame.ZIndex           = 3
SettingsContentFrame.Parent           = ContentAreaFrame

local SettingsScrollingFrame = Instance.new("ScrollingFrame", SettingsContentFrame)
SettingsScrollingFrame.Size                  = UDim2.new(1, 0, 1, 0)
SettingsScrollingFrame.BackgroundTransparency= 1
SettingsScrollingFrame.BorderSizePixel       = 0
SettingsScrollingFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
SettingsScrollingFrame.ScrollBarThickness    = 3
SettingsScrollingFrame.ScrollBarImageColor3  = UI_COLORS.accent
SettingsScrollingFrame.ScrollingDirection    = Enum.ScrollingDirection.Y
SettingsScrollingFrame.AutomaticCanvasSize   = Enum.AutomaticSize.Y

local SettingsListLayout = Instance.new("UIListLayout", SettingsScrollingFrame)
SettingsListLayout.SortOrder           = Enum.SortOrder.LayoutOrder
SettingsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SettingsListLayout.Padding             = UDim.new(0, 4)

local SettingsPadding = Instance.new("UIPadding", SettingsScrollingFrame)
SettingsPadding.PaddingTop    = UDim.new(0, 10)
SettingsPadding.PaddingBottom = UDim.new(0, 10)
SettingsPadding.PaddingLeft   = UDim.new(0, 8)
SettingsPadding.PaddingRight  = UDim.new(0, 8)

-- ==========================================
-- SETTINGS TOGGLES
-- ==========================================
local currentSectionOrder = 0
local toggleRefs   = {}

local function createSettingsSectionHeader(text)
    currentSectionOrder += 1
    local wrap = Instance.new("Frame")
    wrap.Name             = "SectionHeader_" .. text:gsub(" ", "_")
    wrap.Size             = UDim2.new(1, 0, 0, 24)
    wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel  = 0
    wrap.ZIndex           = 4
    wrap.LayoutOrder      = currentSectionOrder
    wrap.Parent           = SettingsScrollingFrame
    local line = Instance.new("Frame", wrap)
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = UI_COLORS.stroke
    line.BorderSizePixel  = 0
    line.ZIndex           = 5
    local pill = Instance.new("Frame", wrap)
    pill.Size             = UDim2.new(0, 0, 1, 0)
    pill.Position         = UDim2.new(0.5, 0, 0, 0)
    pill.AnchorPoint      = Vector2.new(0.5, 0)
    pill.BackgroundColor3 = UI_COLORS.panel
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 6
    pill.AutomaticSize    = Enum.AutomaticSize.X
    local lbl = Instance.new("TextLabel", pill)
    lbl.Size               = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex             = 7
    lbl.Text               = text
    lbl.TextColor3         = UI_COLORS.textMute
    lbl.TextSize           = 10
    lbl.Font               = Enum.Font.GothamBold
    return wrap
end

local function createToggleRow(title, desc, globalVarName)
    currentSectionOrder += 1
    local row = Instance.new("Frame")
    row.Name             = "ToggleRow_" .. globalVarName
    row.Size             = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = UI_COLORS.card
    row.BorderSizePixel  = 0
    row.ZIndex           = 4
    row.LayoutOrder      = currentSectionOrder
    row.Parent           = SettingsScrollingFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", row); stroke.Color = UI_COLORS.stroke

    local accentBar = Instance.new("Frame", row)
    accentBar.Size             = UDim2.new(0, 3, 1, -10)
    accentBar.Position         = UDim2.new(0, 0, 0, 5)
    accentBar.BackgroundColor3 = UI_COLORS.accent
    accentBar.BorderSizePixel  = 0
    accentBar.ZIndex           = 5
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

    local titleTxt = Instance.new("TextLabel", row)
    titleTxt.Size               = UDim2.new(1, -52, 0, 24)
    titleTxt.Position           = UDim2.new(0, 12, 0, 0)
    titleTxt.BackgroundTransparency = 1
    titleTxt.ZIndex             = 5
    titleTxt.Text               = title
    titleTxt.TextColor3         = UI_COLORS.textBright
    titleTxt.TextSize           = 13
    titleTxt.Font               = Enum.Font.GothamMedium
    titleTxt.TextXAlignment     = Enum.TextXAlignment.Left

    local descTxt = Instance.new("TextLabel", row)
    descTxt.Size               = UDim2.new(1, -52, 0, 20)
    descTxt.Position           = UDim2.new(0, 12, 0, 22)
    descTxt.BackgroundTransparency = 1
    descTxt.ZIndex             = 5
    descTxt.Text               = desc
    descTxt.TextColor3         = UI_COLORS.textMute
    descTxt.TextSize           = 11
    descTxt.Font               = Enum.Font.Gotham
    descTxt.TextWrapped        = true
    descTxt.TextXAlignment     = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(0, 36, 0, 20)
    track.Position         = UDim2.new(1, -42, 0.5, -10)
    track.BackgroundColor3 = UI_COLORS.accent
    track.BorderSizePixel  = 0
    track.ZIndex           = 6
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 10)
    local trackStroke = Instance.new("UIStroke", track); trackStroke.Color = UI_COLORS.accent

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = UDim2.new(0, 19, 0.5, -7)
    knob.BackgroundColor3 = UI_COLORS.knobOn
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 7
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)

    local hitArea = Instance.new("TextButton", row)
    hitArea.Size               = UDim2.new(1, 0, 1, 0)
    hitArea.BackgroundTransparency = 1
    hitArea.ZIndex             = 8
    hitArea.Text               = ""

    local ref = {
        on = _G[globalVarName],
        track = track,
        trackStroke = trackStroke,
        knob = knob,
        globalVar = globalVarName
    }
    local function render(animate)
        local info = TweenInfo.new(animate and 0.16 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if ref.on then
            TweenService:Create(track, info, { BackgroundColor3 = UI_COLORS.accent }):Play()
            TweenService:Create(trackStroke,    info, { Color = UI_COLORS.accent }):Play()
            TweenService:Create(knob,  info, { Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = UI_COLORS.knobOn }):Play()
        else
            TweenService:Create(track, info, { BackgroundColor3 = UI_COLORS.trackOff }):Play()
            TweenService:Create(trackStroke,    info, { Color = UI_COLORS.stroke }):Play()
            TweenService:Create(knob,  info, { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = UI_COLORS.knobOff }):Play()
        end
    end
    render(false) -- Initial render without animation

    hitArea.MouseButton1Click:Connect(function()
        ref.on = not ref.on
        _G[globalVarName] = ref.on
        render(true)
        saveSettings()
        if globalVarName == "AntiRagdoll" then
            if _G.AntiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end
        end
    end)
    table.insert(toggleRefs, ref)
    return row
end

createSettingsSectionHeader("MAIN FEATURES")
createToggleRow("Auto Reset On Balloon", "Automatically reset your character when you get hit by a balloon.", "AutoResetOnBalloon")

createSettingsSectionHeader("FLASH TP")
createToggleRow("Auto Block on Grab", "Automatically block the nearest player after a successful grab.", "AutoBlock")
createToggleRow("Auto Giant Potion", "Automatically use a Giant Potion after Flash TP.", "AutoGiant")

createSettingsSectionHeader("PROTECTIONS")
createToggleRow("Anti-Ragdoll/Prison", "Prevents ragdoll, prison, and other movement impairing effects.", "AntiRagdoll")
createToggleRow("Anti-Admin Panel", "Protects against common admin panel commands (freeze, scale, etc.).", "AntiAdminPanel")

createSettingsSectionHeader("UTILITIES")
createToggleRow("Auto Balloon Attacker", "Automatically balloons the player who is stealing your pet.", "AutoBalloon")
-- createToggleRow("AP ESP", "Highlights players with admin commands gamepass.", "AP_ESP") -- AP ESP is not implemented logic-wise, commenting out.

-- ==========================================
-- FLOATING STATS BANNER
-- ==========================================
local StatsBannerGui = Instance.new("ScreenGui")
StatsBannerGui.Name           = "HugoHubBanner"
StatsBannerGui.SelectionGroup = false
StatsBannerGui.ResetOnSpawn   = false
StatsBannerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
StatsBannerGui.IgnoreGuiInset = false
StatsBannerGui.Parent         = PlayerGui

local BannerFrame = Instance.new("Frame")
BannerFrame.Size             = UDim2.new(0, L.bannerW, 0, L.bannerH)
BannerFrame.Position         = L.bannerPos
BannerFrame.BackgroundColor3 = UI_COLORS.accent
BannerFrame.BorderSizePixel  = 0
BannerFrame.Parent           = StatsBannerGui
Instance.new("UICorner", BannerFrame).CornerRadius = UDim.new(0, 12)

local BannerGradient = Instance.new("UIGradient")
BannerGradient.Color    = borderGradientSeq
BannerGradient.Rotation = 224.297
BannerGradient.Parent   = BannerFrame

local BannerInnerFrame = Instance.new("Frame")
BannerInnerFrame.Size                 = UDim2.new(0, L.bannerW-4, 0, L.bannerH-4)
BannerInnerFrame.Position             = UDim2.new(0, 2, 0, 2)
BannerInnerFrame.BackgroundColor3     = UI_COLORS.panel
BannerInnerFrame.BackgroundTransparency = 0.15
BannerInnerFrame.BorderSizePixel      = 0
BannerInnerFrame.Parent               = BannerFrame
Instance.new("UICorner", BannerInnerFrame).CornerRadius = UDim.new(0, 10)

local BannerTitle = Instance.new("TextLabel")
BannerTitle.Size               = UDim2.new(1, 0, 0, 30)
BannerTitle.Position           = UDim2.new(0, 0, 0, 15)
BannerTitle.BackgroundTransparency = 1
BannerTitle.Text               = string.format('<font color="rgb(%d,%d,%d)">HUGO\'S</font> <font color="rgb(%d,%d,%d)">SCRIPT</font>',
    UI_COLORS.textBright.R*255, UI_COLORS.textBright.G*255, UI_COLORS.textBright.B*255,
    UI_COLORS.accent.R*255, UI_COLORS.accent.G*255, UI_COLORS.accent.B*255)
BannerTitle.TextSize           = L.textSize.title
BannerTitle.Font               = Enum.Font.GothamBold
BannerTitle.RichText           = true
BannerTitle.Parent             = BannerInnerFrame

local BannerStats = Instance.new("TextLabel")
BannerStats.Size               = UDim2.new(1, 0, 0, 18)
BannerStats.Position           = UDim2.new(0, 0, 0, 45)
BannerStats.BackgroundTransparency = 1
BannerStats.Text               = string.format('<font color="rgb(%d,%d,%d)">FPS:</font> 60   <font color="rgb(%d,%d,%d)">PING:</font> 35ms',
    UI_COLORS.accent.R*255, UI_COLORS.accent.G*255, UI_COLORS.accent.B*255,
    UI_COLORS.accent.R*255, UI_COLORS.accent.G*255, UI_COLORS.accent.B*255)
BannerStats.TextColor3         = UI_COLORS.textBright
BannerStats.TextSize           = 12
BannerStats.Font               = Enum.Font.GothamMedium
BannerStats.RichText           = true
BannerStats.Parent             = BannerInnerFrame

-- ==========================================
-- GRADIENT ANIMATION
-- ==========================================
task.spawn(function()
    local base1 = UIGradient.Rotation
    local base2 = BannerGradient.Rotation
    while Window.Parent and BannerFrame.Parent do
        local t = os.clock()
        UIGradient.Rotation  = (base1 + t * 60) % 360
        -- No BorderFrame, so only animate main window frame borders
        if Window.Parent and Window:FindFirstChild("BorderFrame") then
            if Window.BorderFrame:FindFirstChildOfClass("UIGradient") then
               Window.BorderFrame:FindFirstChildOfClass("UIGradient").Rotation = (base1 + t * 60) % 360
            end
        end
        BannerGradient.Rotation = (base2 + t * 60) % 360
        RunService.RenderStepped:Wait()
    end
end)


-- ==========================================
-- FPS / PING COUNTER
-- ==========================================
do
    local frameTimes = {}
    local fpsConn
    fpsConn = RunService.RenderStepped:Connect(function()
        if not BannerStats.Parent or thisScriptStopped then fpsConn:Disconnect(); return end
        local now = os.clock()
        table.insert(frameTimes, now)
        while frameTimes[1] and now - frameTimes[1] > 1 do table.remove(frameTimes, 1) end
    end)
    task.spawn(function()
        while BannerStats.Parent and not thisScriptStopped do
            local fps = #frameTimes
            if fps < 2 and frameTimes[1] then
                local span = os.clock() - frameTimes[1]
                if span > 0 then fps = math.floor(#frameTimes / span + 0.5) end
            end
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
            BannerStats.Text = string.format(
                '<font color="rgb(%d,%d,%d)">FPS:</font> %d   <font color="rgb(%d,%d,%d)">PING:</font> %dms',
                UI_COLORS.accent.R*255, UI_COLORS.accent.G*255, UI_COLORS.accent.B*255,
                fps, UI_COLORS.accent.R*255, UI_COLORS.accent.G*255, UI_COLORS.accent.B*255, ping)
            task.wait(0.25)
        end
    end)
end

-- ==========================================
-- DRAG FUNCTIONALITY
-- ==========================================
local dragging = false
local dragStart = Vector2.new(0, 0)
local frameStart = Vector2.new(0, 0)

HeaderFrame.InputBegan:Connect(function(input)
    if not LockButton.Text == "🔒" and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        frameStart = Window.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        dragging = false
    end
end)

-- ==========================================
-- TAB SWITCHING
-- ==========================================
local activeTab = "brainrots"
local TAB_SWITCH_DUR = 0.22 -- Duration of tab switch animation

local function setTab(tab)
    if tab == activeTab then return end
    activeTab = tab
    local info = TweenInfo.new(TAB_SWITCH_DUR, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    if tab == "settings" then
        SettingsContentFrame.Visible = true
        SettingsContentFrame.Position = UDim2.new(1, 0, 0, 0)
        TweenService:Create(BrainrotsContentFrame, info, { Position = UDim2.new(-1, 0, 0, 0) }):Play()
        TweenService:Create(SettingsContentFrame, info, { Position = UDim2.new(0, 0, 0, 0) }):Play()
        BrainrotsTabText.TextColor3 = UI_COLORS.textDim
        SettingsTabText.TextColor3 = UI_COLORS.textBlue
        TweenService:Create(BrainrotsTabIndicator, info, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(SettingsTabIndicator, info, { BackgroundTransparency = 0 }):Play()
    else -- "brainrots"
        BrainrotsContentFrame.Visible = true
        BrainrotsContentFrame.Position = UDim2.new(-1, 0, 0, 0)
        TweenService:Create(BrainrotsContentFrame, info, { Position = UDim2.new(0, 0, 0, 0) }):Play()
        TweenService:Create(SettingsContentFrame, info, { Position = UDim2.new(1, 0, 0, 0) }):Play()
        BrainrotsTabText.TextColor3 = UI_COLORS.textBlue
        SettingsTabText.TextColor3 = UI_COLORS.textDim
        TweenService:Create(BrainrotsTabIndicator, info, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(SettingsTabIndicator, info, { BackgroundTransparency = 1 }):Play()
        task.delay(TAB_SWITCH_DUR, function() if activeTab == "brainrots" then SettingsContentFrame.Visible = false end end)
    end
end

BrainrotsTabBtn.MouseButton1Click:Connect(function() setTab("brainrots") end)
SettingsTabBtn.MouseButton1Click:Connect(function() setTab("settings") end)

-- ==========================================
-- WINDOW CONTROL BUTTONS
-- ==========================================
local isLocked    = false
LockButton.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    LockButton.Text      = isLocked and "🔒" or "🔓"
    HeaderFrame.Active   = not isLocked
    LockButton.TextColor3= isLocked and UI_COLORS.accent or UI_COLORS.textMute
end)

local isMinimized = false
local fullSize    = Window.Size
local MIN_WIN_H   = L.headerH + L.btnH/2 + 20 + L.tabH + 5 + 4
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local info = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if isMinimized then
        TweenService:Create(Window, info, { Size = UDim2.new(0, L.winW, 0, MIN_WIN_H) }):Play()
    else
        TweenService:Create(Window, info, { Size = fullSize }):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local t1 = TweenService:Create(Window, info, { Size = UDim2.new(0,0,0,0) })
    t1:Play()
    t1.Completed:Connect(function() MAIN_GUI:Destroy(); StatsBannerGui:Destroy() end)
end)

-- ==========================================
-- HOVER EFFECTS
-- ==========================================
local function hookButtonHover(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = hoverColor }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = normalColor }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), { BackgroundColor3 = UI_COLORS.deepBlue }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = hoverColor }):Play()
    end)
end

hookButtonHover(FlashTPButton, UI_COLORS.card, UI_COLORS.iconBg)
hookButtonHover(BlockButton,   UI_COLORS.card, UI_COLORS.iconBg)
hookButtonHover(ResetButton,   UI_COLORS.card, UI_COLORS.iconBg)
for _, b in ipairs({ LockButton, MinimizeButton, CloseButton }) do hookButtonHover(b, UI_COLORS.card, UI_COLORS.iconBg) end

local function flashAccentLine(line)
    line.BackgroundColor3 = UI_COLORS.accentHi
    TweenService:Create(line, TweenInfo.new(0.4), { BackgroundColor3 = UI_COLORS.stroke }):Play()
end

-- ==========================================
-- FLASH TP BUTTON VISUAL EFFECT (Blinking)
-- ==========================================
local isFlashBlinking = false
local BLINK_COLOR_HIGH  = Color3.fromRGB(255, 40, 40) -- Red color for alert
local BLINK_COLOR_LOW   = Color3.fromRGB(110, 10, 10)  -- Darker red
local BLINK_TWEEN_INFO  = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local BLINK_PERIOD = 0.3

local function startFlashBlink()
    if isFlashBlinking then return end
    isFlashBlinking = true
    task.spawn(function()
        while isFlashBlinking and not thisScriptStopped do
            TweenService:Create(FlashTPButton,     BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_HIGH }):Play()
            TweenService:Create(FlashTPAccent, BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_HIGH }):Play()
            TweenService:Create(BrainrotsTabIndicator,     BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_HIGH, BackgroundTransparency = 0 }):Play()
            task.wait(BLINK_PERIOD)
            if not isFlashBlinking then break end
            TweenService:Create(FlashTPButton,     BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_LOW }):Play()
            TweenService:Create(FlashTPAccent, BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_LOW }):Play()
            TweenService:Create(BrainrotsTabIndicator,     BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_LOW, BackgroundTransparency = 0 }):Play()
            task.wait(BLINK_PERIOD)
        end
    end)
end

local function stopFlashBlink()
    if not isFlashBlinking then return end
    isFlashBlinking = false
    TweenService:Create(FlashTPButton,     TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.card }):Play()
    TweenService:Create(FlashTPAccent, TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.stroke }):Play()
    TweenService:Create(BrainrotsTabIndicator,     TweenInfo.new(0.2), { BackgroundColor3 = UI_COLORS.accent, BackgroundTransparency = 0 }):Play()
end

startFlashBlink() -- Start blinking by default until a pet is selected

-- ==========================================
-- INTERACTIVE BUTTON EVENTS
-- ==========================================
FlashTPButton.MouseButton1Click:Connect(function()
    if selectedPrompt and selectedSlotNumber then
        if not isStealing and not autoStealEnabled then
            flashAccentLine(FlashTPAccent)
            startTripToPetSlot(selectedPrompt, selectedSlotNumber)
        end
    end
end)

BlockButton.MouseButton1Click:Connect(function()
    flashAccentLine(BlockAccent)
    local target = getNearestPlayer()
    if not target then return end
    waitForStealPrompt()
    pcall(function() StarterGui:SetCore("PromptBlockPlayer", target) end)
    FastConfirm()
end)

ResetButton.MouseButton1Click:Connect(function()
    flashAccentLine(ResetAccent)
    doReset()
end)

-- ==========================================
-- PETS LIST UPDATE LOOP
-- ==========================================
task.spawn(function()
    while task.wait(1.5) do
        if thisScriptStopped then break end
        if activeTab == "brainrots" then -- Only update if on the brainrots tab for performance
            updatePetList()
            if selectedPrompt and selectedSlotNumber then
                stopFlashBlink()
            else
                startFlashBlink()
            end
        end
    end
end)
updatePetList() -- Initial update

-- ==========================================
-- ENTRY ANIMATION
-- ==========================================
task.spawn(function()
    local targetPos = L.posX
    Window.Position         = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, targetPos.Y.Scale, targetPos.Y.Offset - 40)
    Window.Visible = true
    TweenService:Create(Window, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = targetPos }):Play()
end)

-- ==========================================
-- GLOBAL SCRIPT PURGE
-- (Called when the script is re-executed or external trigger)
-- ==========================================
_G.Formega_Script_Purge = function()
    thisScriptStopped = true
    stopAntiRagdoll()
    for _, conn in ipairs(ActiveConnections) do
        if conn and conn.Connected then pcall(function() conn:Disconnect() end) end
    end
    if MAIN_GUI.Parent then pcall(function() MAIN_GUI:Destroy() end) end
    if StatsBannerGui.Parent then pcall(function() StatsBannerGui:Destroy() end) end
    _G.Formega_Script_Purge = nil
end
