--!strict
-- Built by Dignity for Vertex PvP
-- Version: 1.0.0
-- Built for maximum undetectability while providing requested features.
-- Note: "Undetected" status against anti-cheat systems is an ongoing effort and cannot be permanently guaranteed.

-- ==========================================
-- SERVICES
-- ==========================================
local Players           = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local Stats             = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService        = game:GetService("GuiService")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")

-- ==========================================
-- LOCAL PLAYER REFERENCES
-- ==========================================
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- SCRIPT PURGE SYSTEM
-- (Ensures only one instance of the script runs to prevent conflicts)
-- ==========================================
if _G.VertexPvP_Script_Purge then
    pcall(function() _G.VertexPvP_Script_Purge() end)
    task.wait(0.2)
end

local ActiveConnections = {} -- Table to store all active connections for easy disconnection
local thisScriptStopped = false

-- ==========================================
-- CONFIGURATION GLOBALS
-- (These are the global settings, loaded from file or default)
-- ==========================================
_G.VertexPvP_AutoResetOnBalloon  = true
_G.VertexPvP_AutoGiant           = false
_G.VertexPvP_AutoBlock           = false
_G.VertexPvP_AntiRagdoll         = true -- Default to true as it's a protection
_G.VertexPvP_AutoBalloon         = false
_G.VertexPvP_AntiAdminPanel      = true -- Default to true as it's a protection

-- ==========================================
-- SAVE / LOAD SETTINGS
-- ==========================================
local SETTINGS_FILE = "vertex_pvp_settings.json"

local function loadSettings()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if success and type(data) == "table" then return data end
    return {}
end

local function saveSettings()
    pcall(function()
        writefile(SETTINGS_FILE, HttpService:JSONEncode({
            AutoResetOnBalloon = _G.VertexPvP_AutoResetOnBalloon,
            AutoGiant          = _G.VertexPvP_AutoGiant,
            AutoBlock          = _G.VertexPvP_AutoBlock,
            AntiRagdoll        = _G.VertexPvP_AntiRagdoll,
            AutoBalloon        = _G.VertexPvP_AutoBalloon,
            AntiAdminPanel     = _G.VertexPvP_AntiAdminPanel,
        }))
    end)
end

local savedSettings = loadSettings()

-- Function to apply settings from loaded data or use defaults
local function applySetting(globalVarKey: string, defaultValue: any)
    if savedSettings[globalVarKey] ~= nil then
        _G["VertexPvP_" .. globalVarKey] = savedSettings[globalVarKey]
    else
        _G["VertexPvP_" .. globalVarKey] = defaultValue
    end
end

applySetting("AutoResetOnBalloon", true)
applySetting("AutoGiant", false)
applySetting("AutoBlock", false)
applySetting("AntiRagdoll", true)
applySetting("AutoBalloon", false)
applySetting("AntiAdminPanel", true)

-- ==========================================
-- DYNAMIC CHARACTER REFERENCES
-- ==========================================
local Character: Model
local Humanoid: Humanoid
local Root: Part
local Camera: Camera

local function updateCharacterRefs()
    Character = LocalPlayer.Character
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    Humanoid  = Character:WaitForChild("Humanoid", 5)
    Root      = Character:WaitForChild("HumanoidRootPart", 5)
    Camera    = Workspace.CurrentCamera

    if not Humanoid or not Root then
        warn("[Vertex PvP] Humanoid or HumanoidRootPart not found after character update. Retrying...")
        -- If critical parts are missing, it's safer to wait for a new character
        LocalPlayer.CharacterAdded:Wait()
        updateCharacterRefs() -- Recursive call for new character
    end
end

updateCharacterRefs()
LocalPlayer.CharacterAdded:Connect(updateCharacterRefs)

-- ==========================================
-- FLASH TP STATE
-- ==========================================
local FlashTP_StealDelay        = 1.30
local FlashTP_IsStealing        = false
local FlashTP_CurrentMovement   = nil
local FlashTP_SelectedPrompt    = nil
local FlashTP_SelectedSlotNumber= nil
local FlashTP_AutoStealEnabled  = false

-- ==========================================
-- ANTI-ADMIN PANEL LOGIC (Highly optimized & resilient)
-- ==========================================
local AA_GraceUntil = 0 -- Grace period for respawn
local AA_OriginalScales = {}
local AA_OriginalHipHeight = nil
local AA_ScaleNames = {
    "HeadScale", "BodyDepthScale", "BodyHeightScale",
    "BodyProportionScale", "BodyTypeScale", "BodyWidthScale",
}
local AA_ControlsModule = nil
local AA_CharacterControllerModule = nil
local AA_JumpscareModule = nil

-- Capture original scales and hip height once character is ready
local function captureAAOriginals()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    AA_OriginalHipHeight = hum.HipHeight
    AA_OriginalScales    = {}
    for _, name in ipairs(AA_ScaleNames) do
        local sv = hum:FindFirstChild(name)
        if sv then AA_OriginalScales[name] = sv.Value end
    end
end

-- Clear module caches on character spawn to ensure always getting fresh instances
local AACharAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    AA_GraceUntil = tick() + 1.5 -- Give it a grace period
    AA_ControlsModule          = nil
    AA_CharacterControllerModule = nil
    AA_JumpscareModule         = nil

    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum then
        task.wait(0.1) -- Small delay for properties to propagate
        captureAAOriginals()
    end
end)
table.insert(ActiveConnections, AACharAddedConn)
task.spawn(function()
    if LocalPlayer.Character then
        captureAAOriginals() -- Initial capture for already spawned character
    end
end)

-- Safely get the Controls Module
local function getAAControlsModule()
    if AA_ControlsModule then return AA_ControlsModule end
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    local playerModule  = playerScripts and playerScripts:FindFirstChild("PlayerModule")
    if not playerModule then return nil end
    local ok, mod = pcall(require, playerModule)
    if not ok or not mod then return nil end
    local _, controls = pcall(function() return mod:GetControls() end) -- Use pcall for GetControls too
    if controls then AA_ControlsModule = controls end
    return AA_ControlsModule
end

-- Acquire CharacterController module
local function getAACharacterController()
    if AA_CharacterControllerModule ~= nil then return AA_CharacterControllerModule end
    local success, module = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Controllers", 5):WaitForChild("CharacterController", 5))
    end)
    AA_CharacterControllerModule = success and module or false
    return AA_CharacterControllerModule
end

-- Acquire Jumpscare module
local function getAAJumpscareModule()
    if AA_JumpscareModule ~= nil then return AA_JumpscareModule end
    local success, module = pcall(function()
        -- Path might vary in different games, adjust if needed
        return require(ReplicatedStorage:WaitForChild("Datas", 5):WaitForChild("AdminCommands", 5):WaitForChild("jumpscare", 5))
    end)
    AA_JumpscareModule = success and module or false
    return AA_JumpscareModule
end

-- Anti-Admin main loop (Heartbeat to avoid detection from fixed 'while wait' loops)
local antiAdminLoop = RunService.Heartbeat:Connect(function()
    if not _G.VertexPvP_AntiAdminPanel or thisScriptStopped then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not hrp then return end

    -- 1. Anti-Ragdoll/Constraints (Motor6Ds for limbs, constraints for physics)
    -- Iterates through descendants to catch dynamically added constraints/attachments
    for _, instance in ipairs(char:GetDescendants()) do
        if ((instance:IsA("BallSocketConstraint") or instance:IsA("HingeConstraint")) or
            (instance:IsA("Attachment") and (instance.Name == "LeftHip" or instance.Name == "RightHip" or etc.))) then -- refine attachment names if false positives occur
            pcall(function() instance:Destroy() end)
        elseif instance:IsA("Motor6D") and not instance.Enabled then
            pcall(function() instance.Enabled = true end)
        end
    end

    -- 2. Re-enable player controls if disabled (robust pcall added)
    local controls = getAAControlsModule()
    if controls and not controls:GetEnabled() then
        pcall(function() controls:Enable() end)
    end

    -- 3. Force Humanoid state (prevents 'jail' states)
    local currentState = hum:GetState()
    if currentState ~= Enum.HumanoidStateType.Running
        and currentState ~= Enum.HumanoidStateType.Jumping
        and currentState ~= Enum.HumanoidStateType.Freefall
        and currentState ~= Enum.HumanoidStateType.Climbing
        and currentState ~= Enum.HumanoidStateType.Swimming then -- Added swimming
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end

    -- 4. Restore camera subject if hijacked (only if it's NOT the humanoid)
    if Workspace.CurrentCamera and Workspace.CurrentCamera.CameraSubject ~= hum then
        pcall(function() Workspace.CurrentCamera.CameraSubject = hum end)
    end

    -- 5. Clear 'RagdollEndTime' attribute for anti-gummy effects
    local ragdollEndTime = LocalPlayer:GetAttribute("RagdollEndTime") or 0
    if ragdollEndTime > Workspace:GetServerTimeNow() and tick() > AA_GraceUntil then
        pcall(function() hrp.Velocity = Vector3.zero end)
        pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", 0) end)
    end

    -- 6. Anti-inverse controls: restore moveFunction if hijacked
    local charController = getAACharacterController()
    if charController and controls and controls.moveFunction ~= charController.RequestMove then
        controls.moveFunction = function(p, x, z)
            charController:RequestMove(p, x, z)
        end
    end

    -- 7. Block jumpscare effects
    local jumpscareMod = getAAJumpscareModule()
    if jumpscareMod and jumpscareMod.effects and type(jumpscareMod.effects.Victim) == "function" then
        if tostring(jumpscareMod.effects.Victim) ~= "function: 0x0" then -- Simple check for the original function address
            jumpscareMod.effects.Victim = function() end
            -- Additional: Clear any active GUI related to jumpscare if known
            -- e.g., if there's a specific jumpscare ScreenGui: PlayerGui:FindFirstChild("JumpscareGUI"):Destroy()
        end
    end

    -- 8. Restore original body scales (anti-tiny/giant)
    if AA_OriginalHipHeight and hum.HipHeight ~= AA_OriginalHipHeight then
        pcall(function() hum.HipHeight = AA_OriginalHipHeight end)
    end
    for _, name in ipairs(AA_ScaleNames) do
        local sv = hum:FindFirstChild(name)
        if sv and AA_OriginalScales[name] and sv.Value ~= AA_OriginalScales[name] then
            pcall(function() sv.Value = AA_OriginalScales[name] end)
        end
    end

    -- 9. Destroy foreign models/accessories added by admin commands
    -- This is a heuristic: delete models that aren't characters or backpack items
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Model") and not v:IsA("BackpackItem") and not Players:GetPlayerFromCharacter(v) and not v:FindFirstChildOfClass("Humanoid") then
            -- Further checks can be added here, e.g., if v.Name == "ForceField" or v.Name == "AdminTool"
            pcall(function() v:Destroy() end)
        end
    end
end)
table.insert(ActiveConnections, antiAdminLoop)

-- ==========================================
-- ANTI-RAGDOLL LOGIC (Enhanced)
-- ==========================================
local AR_Connections = {}
local AR_LastCleanTime = 0
local AR_MAX_VELOCITY  = 40
local AR_CLAMP_VELOCITY= 25
local AR_MAX_CLAMP     = 15

local function connectARToCharacter(charModel)
    local hum = charModel:WaitForChild("Humanoid", 5)
    local root = charModel:WaitForChild("HumanoidRootPart", 5)
    local animator = hum:WaitForChild("Animator", 5)
    if not hum or not root or not animator then return end

    local lastVel = Vector3.new(0,0,0)
    local isInRagdollState = false

    local function checkRagdollState()
        local state = hum:GetState()
        return state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown
            or state == Enum.HumanoidStateType.GettingUp
            or state == Enum.HumanoidStateType.Seated -- Added for common "sit" jail
    end

    local function cleanRagdollEffects()
        local now = tick()
        if now - AR_LastCleanTime < 0.15 then return end
        AR_LastCleanTime = now
        for _, obj in pairs(charModel:GetDescendants()) do
            if (obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint")) then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("Attachment") and (obj.Name == "LeftHip" or obj.Name == "RightHip") then -- Common ragdoll attachments
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("Motor6D") and not obj.Enabled then
                pcall(function() obj.Enabled = true end)
            end
        end
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            local animName = track.Animation and track.Animation.Name:lower() or ""
            if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") or animName:find("sit") then
                pcall(function() track:Stop(0) end)
            end
        end
    end

    local function reEnableControls()
        pcall(function()
            local controls = getAAControlsModule()
            if controls and not controls:GetEnabled() then
                controls:Enable()
            end
        end)
    end

    table.insert(AR_Connections, hum.StateChanged:Connect(function(_, newState)
        if not _G.VertexPvP_AntiRagdoll or thisScriptStopped then return end
        if checkRagdollState() then
            isInRagdollState = true
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            cleanRagdollEffects()
            pcall(function() Workspace.CurrentCamera.CameraSubject = hum end)
            reEnableControls()
        else
            isInRagdollState = false
        end
    end))

    table.insert(AR_Connections, RunService.Heartbeat:Connect(function()
        if not _G.VertexPvP_AntiRagdoll or thisScriptStopped then return end
        if isInRagdollState then
            cleanRagdollEffects()
            local vel = root.AssemblyLinearVelocity
            -- Velocity clamping to prevent being flung too far
            if (vel - lastVel).Magnitude > AR_MAX_VELOCITY and vel.Magnitude > AR_CLAMP_VELOCITY then
                pcall(function() root.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, AR_MAX_CLAMP) end)
            end
            lastVel = vel
        end
    end))

    table.insert(AR_Connections, charModel.DescendantAdded:Connect(function()
        if _G.VertexPvP_AntiRagdoll and isInRagdollState and not thisScriptStopped then cleanRagdollEffects() end
    end))

    reEnableControls()
    cleanRagdollEffects()
end

local function startAntiRagdoll()
    for _, conn in ipairs(AR_Connections) do if conn.Connected then pcall(function() conn:Disconnect() end) end end
    AR_Connections = {}
    if LocalPlayer.Character then
        connectARToCharacter(LocalPlayer.Character)
    end
end

local function stopAntiRagdoll()
    for _, conn in ipairs(AR_Connections) do if conn.Connected then pcall(function() conn:Disconnect() end) end end
    AR_Connections = {}
end

-- Connect AR to new characters
local AR_CharAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
    if _G.VertexPvP_AntiRagdoll then
        for _, conn in ipairs(AR_Connections) do if conn.Connected then pcall(function() conn:Disconnect() end) end end
        AR_Connections = {} -- Clear old connections
        task.spawn(function() connectARToCharacter(newChar) end)
    end
end)
table.insert(ActiveConnections, AR_CharAddedConnection)

-- Start immediately if enabled by settings
if _G.VertexPvP_AntiRagdoll then task.spawn(startAntiRagdoll) end

-- ==========================================
-- AUTO BALLOON (Flipping the script functionality)
-- ==========================================
local AB_DetectionZones = {
    -- These are example zones, replace with actual game map coordinates or a more dynamic detection system if needed
    {Shape = 'Square', Center = Vector3.new(-350, -6.5, 0), Size = 50},
    {Shape = 'Line', Center = Vector3.new(-340, -6.5, 40), Size = 30},
}

local AB_BalloonedPlayers = {} -- Track players we are actively trying to balloon

local function AB_IsInAnyZone(position)
    for _, zone in ipairs(AB_DetectionZones) do
        local half = zone.Size / 2
        local dx = math.abs(position.X - zone.Center.X)
        local dz = math.abs(position.Z - zone.Center.Z)
        if zone.Shape == 'Line' then -- Line implies a long, thin zone
            if dx <= half and math.abs(position.Y - zone.Center.Y) < 5 and dz <= 1.5 then return true end
        elseif zone.Shape == 'Square' then -- Square implies a rectangular prism
            if dx <= half and math.abs(position.Y - zone.Center.Y) < 10 and dz <= half then return true end
        end
    end
    return false
end

-- Checks if the user has a message indicating their pet is being stolen
local function AB_HasStealingAlertMessage()
    for _, desc in pairs(PlayerGui:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text and string.find(desc.Text, "Someone is stealing your") then
            return true
        end
    end
    return false
end

-- Finds the Admin Panel GUI, if available
local function AB_FindAdminPanel()
    return PlayerGui:FindFirstChild("AdminPanel")
end

-- Finds the button for a specific player in the Admin Panel
local function AB_FindPlayerButton(targetPlayer)
    local adminPanel = AB_FindAdminPanel()
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

-- Gets all command buttons from the Admin Panel
local function AB_GetCommandButtons()
    local btns = {}
    local adminPanel = AB_FindAdminPanel()
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

-- Simulates a click on a GUI button
local function AB_ClickGUIButton(button)
    pcall(function() button.MouseButton1Click:Fire() end)
    pcall(function() button.Activated:Fire() end)
    -- Fallback for custom events/connections
    if getconnections then
        for _, cx in pairs(getconnections(button.MouseButton1Click)) do cx:Fire() end
        for _, cx in pairs(getconnections(button.Activated)) do cx:Fire() end
    end
end

-- Checks if a button name corresponds to an exact command
local function AB_IsExactCommand(buttonName, expectedCmdName)
    local bName = string.lower(string.match(buttonName, "^%s*(.-)%s*$") or buttonName)
    local cmdName = string.lower(expectedCmdName)
    return bName == cmdName or bName == ":"..cmdName or bName == ";"..cmdName or string.match(bName, "^[:;]?"..cmdName.."%s")
end

-- Triggers the "balloon" command on a target player via Admin Panel
local function AB_TriggerBalloonOnTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Parent then return end
    local adminPanel = AB_FindAdminPanel()
    if not adminPanel then return end
    for _, cBtn in ipairs(AB_GetCommandButtons()) do
        if AB_IsExactCommand(cBtn.name, "balloon") then
            AB_ClickGUIButton(cBtn.button)
            task.wait(0.02)
            local pBtn = AB_FindPlayerButton(targetPlayer)
            if pBtn then AB_ClickGUIButton(pBtn) end
            break
        end
    end
end

-- Auto Balloon main loop
local AB_LastCheck = 0
local autoBalloonLoop = RunService.Heartbeat:Connect(function()
    if not _G.VertexPvP_AutoBalloon or thisScriptStopped then return end
    local now = tick()
    if now - AB_LastCheck < 0.2 then return end -- Check every 0.2 seconds for performance
    AB_LastCheck = now

    local hasStealMessage = AB_HasStealingAlertMessage()

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end -- Don't balloon self
        local character = p.Character
        if not character then continue end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("Torso") -- Torso fallback

        if not rootPart then continue end

        local targetKey = p.UserId
        local inStealZone = AB_IsInAnyZone(rootPart.Position)

        if inStealZone and hasStealMessage and not AB_BalloonedPlayers[targetKey] then
            AB_BalloonedPlayers[targetKey] = true
            AB_TriggerBalloonOnTarget(p)
        elseif (not inStealZone or not hasStealMessage) and AB_BalloonedPlayers[targetKey] then
            AB_BalloonedPlayers[targetKey] = nil
        end
    end
end)
table.insert(ActiveConnections, autoBalloonLoop)

-- Clean up on player leaving
local AB_PlayerRemovingConn = Players.PlayerRemoving:Connect(function(pLeaving)
    AB_BalloonedPlayers[pLeaving.UserId] = nil
end)
table.insert(ActiveConnections, AB_PlayerRemovingConn)

-- ==========================================
-- FAST CONFIRM (for prompts like Block Player and other popups)
-- ==========================================
local function FastConfirm()
    local res = GuiService:GetScreenResolution()
    local x = res.X * 0.5
    local y = res.Y * 0.58 -- Typically where 'Confirm' buttons appear
    for i = 1, 10 do -- Multiple clicks to ensure it registers
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
    local hrp = Root
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
-- WAIT FOR STEAL PROMPT (using CoreGui descendant detection)
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
    if connection.Connected then pcall(function() connection:Disconnect() end) end
    return true
end

-- ==========================================
-- SLOTS CONFIG (Flash TP locations for specific game environment)
-- ==========================================
-- IMPORTANT: These coordinates are game-specific.
-- You might need to update them for new game versions or different games.
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
    -- Execute connections in a pcall to prevent errors from breaking the script
    for _, conn in ipairs(connections) do
        if conn.Function then pcall(conn.Function) end
    end
end

local function executeSteal(prompt)
    if FlashTP_IsStealing or not prompt or not prompt.Parent then return end
    FlashTP_IsStealing = true
    firePromptConnections(prompt, "PromptButtonHoldBegan")
    task.wait(FlashTP_StealDelay)
    if prompt and prompt.Parent and prompt.Enabled and not thisScriptStopped then
        firePromptConnections(prompt, "Triggered")
    end
    FlashTP_IsStealing = false
end

local FlashTP_STOP_DIST = 5
local FlashTP_SLOW_DIST = 20

-- ==========================================
-- PLAYER RESET FUNCTION (Sophisticated)
-- ==========================================
local function doReset()
    local lp  = LocalPlayer
    local Net = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("Net", 5)
    local remote -- This remote is usually for the balloon/reset
    -- Heuristic to find the correct remote, relies on naming convention
    local children = Net:GetChildren()
    for i = 1, #children - 1 do
        if children[i] and children[i+1] and children[i].Name:find("Tools/Cooldown") then
            remote = children[i+1]; break
        end
    end

    if not remote then
        -- Fallback to killing player if remote not found (less subtle)
        local h = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
        if h then pcall(function() h.Health = 0 end) end
        return
    end

    local savedTools = {}
    local char  = lp.Character
    local bp    = lp:FindFirstChild("Backpack")

    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:UnequipTools() end) end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                table.insert(savedTools, t)
                pcall(function() t.Parent = nil end) -- Detach tool to save
            end
        end
    end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                table.insert(savedTools, t)
                pcall(function() t.Parent = nil end) -- Detach tool to save
            end
        end
    end

    pcall(function() lp.Character = nil end) -- Force character removal

    local sending  = true
    local throttle = 0
    local resetLoop
    resetLoop = RunService.Heartbeat:Connect(function(dt)
        if thisScriptStopped then pcall(function() resetLoop:Disconnect() end) return end
        if not sending then return end

        throttle = throttle + dt
        if throttle >= 0.1 then -- Fire remote periodically
            throttle = 0
            pcall(function() remote:FireServer("f888ee6e-c86d-46e1-93d7-0639d6635d42", lp, "balloon") end)
        end
        if lp.Character then pcall(function() lp.Character = nil end) end -- Ensure character stays nil
    end)
    table.insert(ActiveConnections, resetLoop)

    local charAddedOnceConn -- Connect once for character respawn
    charAddedOnceConn = lp.CharacterAdded:Connect(function()
        sending = false
        pcall(function() resetLoop:Disconnect() end)
        if charAddedOnceConn.Connected then pcall(function() charAddedOnceConn:Disconnect() end) end
        task.spawn(function()
            local newBp = lp:WaitForChild("Backpack", 5)
            if newBp then for _, t in ipairs(savedTools) do if t then pcall(function() t.Parent = newBp end) end end end
        end)
    end)
    table.insert(ActiveConnections, charAddedOnceConn)

    -- Failsafe: if character doesn't respawn for some reason, stop firing
    task.delay(4, function()
        if sending then
            sending = false
            pcall(function() resetLoop:Disconnect() end)
            local curBp = lp:FindFirstChild("Backpack")
            if curBp then for _, t in ipairs(savedTools) do if t then pcall(function() t.Parent = curBp end) end end end
        end
    end)
end

-- ==========================================
-- AUTO RESET ON BALLOON
-- ==========================================
local AR_BalloonAttrChangedConn = LocalPlayer:GetAttributeChangedSignal("Balloon"):Connect(function()
    if thisScriptStopped then pcall(function() AR_BalloonAttrChangedConn:Disconnect() end) return end
    if _G.VertexPvP_AutoResetOnBalloon and LocalPlayer:GetAttribute("Balloon") == true then
        doReset()
    end
end)
table.insert(ActiveConnections, AR_BalloonAttrChangedConn)

-- ==========================================
-- START TRIP TO PET SLOT (FLASH TP)
-- ==========================================
local function startTripToPetSlot(prompt, slotNumber)
    local config          = SlotsConfig[slotNumber] or SlotsConfig[1] -- Default to slot 1 if invalid
    local targetPositions = config.Positions or { config.Position }
    local needJump        = config.NeedJump == true

    if FlashTP_CurrentMovement then pcall(function() FlashTP_CurrentMovement:Disconnect() end) FlashTP_CurrentMovement = nil end
    if not Root or not Humanoid then
        warn("[Vertex PvP] Flash TP failed: Humanoid or Root part missing.")
        FlashTP_AutoStealEnabled = false
        return
    end

    FlashTP_AutoStealEnabled = true
    local movementSpeed            = 200 -- High speed for Flash TP
    local grabStartDistance= 60

    -- Attempt to equip a flying tool if available for smoother movement
    local carpet = findTool("flying carpet") or findTool("fly")
    if carpet then
        pcall(function() Humanoid:UnequipTools() end)
        task.wait(0.03)
        pcall(function() Humanoid:EquipTool(carpet) end)
    end

    -- Clean up any existing LinearVelocity/Attachment before creating new ones
    if Root:FindFirstChildOfClass("LinearVelocity") then pcall(function() Root:FindFirstChildOfClass("LinearVelocity"):Destroy() end) end
    if Root:FindFirstChildOfClass("Attachment") then pcall(function() Root:FindFirstChildOfClass("Attachment"):Destroy() end) end

    local attachment = Instance.new("Attachment")
    attachment.Parent = Root

    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Attachment0     = attachment
    linearVelocity.RelativeTo      = Enum.ActuatorRelativeTo.World
    linearVelocity.MaxForce        = math.huge -- Uncapped force
    linearVelocity.Parent          = Root

    local currentPathSegmentIndex = 1
    local isIntermediatePauseActive = false

    local movementLoop
    movementLoop = RunService.Heartbeat:Connect(function()
        if thisScriptStopped or not Root or not Humanoid or not Root.Parent or Humanoid.Health <= 0 then
            pcall(function() movementLoop:Disconnect() end)
            if linearVelocity.Parent then pcall(function() linearVelocity:Destroy() end) end
            if attachment.Parent then pcall(function() attachment:Destroy() end) end
            FlashTP_AutoStealEnabled = false
            return
        end
        if isIntermediatePauseActive then linearVelocity.VectorVelocity = Vector3.zero return end

        local targetPosition = targetPositions[currentPathSegmentIndex]
        if not targetPosition then
            pcall(function() movementLoop:Disconnect() end)
            if linearVelocity.Parent then pcall(function() linearVelocity:Destroy() end) end
            if attachment.Parent then pcall(function() attachment:Destroy() end) end
            FlashTP_AutoStealEnabled = false
            return
        end

        local rootPos = Root.Position
        local dir     = Vector3.new(targetPosition.X - rootPos.X, 0, targetPosition.Z - rootPos.Z)
        local dist    = dir.Magnitude

        -- Trigger steal action when close to the first target point
        if currentPathSegmentIndex == 1 and dist <= grabStartDistance and not grabStarted then
            FlashTP_GrabStarted = true
            task.spawn(function() executeSteal(prompt) end)
        end

        local speedMultiplier = 1
        -- Slow down as we approach the target for precision
        if dist < FlashTP_SLOW_DIST then speedMultiplier = math.max(0.15, dist / FlashTP_SLOW_DIST) end

        if dist <= FlashTP_STOP_DIST then
            if currentPathSegmentIndex < #targetPositions then
                -- Move to next segment
                isIntermediatePauseActive = true
                linearVelocity.VectorVelocity = Vector3.zero
                pcall(function() Root.AssemblyLinearVelocity = Vector3.zero end)
                task.spawn(function()
                    task.wait(0.1) -- Small pause between segments
                    currentPathSegmentIndex += 1
                    isIntermediatePauseActive = false
                end)
                return
            end

            -- Reached final destination
            linearVelocity.VectorVelocity = Vector3.zero
            pcall(function() Root.AssemblyLinearVelocity = Vector3.zero end)
            if linearVelocity.Parent then pcall(function() linearVelocity:Destroy() end) end
            if attachment.Parent then pcall(function() attachment:Destroy() end) end
            if movementLoop.Connected then pcall(function() movementLoop:Disconnect() end) end

            pcall(function() Root.CFrame = CFrame.new(targetPosition) end) -- Final precise placement
            task.wait(0.12)

            -- Camera manipulation for dramatic effect
            pcall(function() Camera.CameraType = Enum.CameraType.Scriptable end)
            pcall(function() Camera.CFrame = CFrame.new(Root.Position + config.CamOffset) * CFrame.Angles(unpack(config.CamAngles)) end)
            pcall(function() Humanoid:UnequipTools() end)
            task.wait(0.06)

            -- Jump action if required for the slot
            if needJump then
                pcall(function() Root.AssemblyLinearVelocity = Vector3.new(0, 55, 0) end)
                task.wait(0.08)
            end

            -- Flash tool activation
            local flash = findTool("flash")
            if flash then
                pcall(function() Humanoid:EquipTool(flash) end)
                task.wait(0.08)
                pcall(function() flash:Activate() end)
            end
            task.wait(0.1)

            -- Auto Giant Potion
            if _G.VertexPvP_AutoGiant then
                local giant = findTool("giant potion")
                if giant then
                    pcall(function() Humanoid:EquipTool(giant) end)
                    task.wait(0.08)
                    pcall(function() giant:Activate() end)
                    task.wait(0.05)
                    pcall(function() Humanoid:UnequipTools() end)
                end
            end
            pcall(function() Camera.CameraType = Enum.CameraType.Custom end)

            -- Auto Block nearest player
            if _G.VertexPvP_AutoBlock then
                task.spawn(function()
                    task.wait(0.13)
                    local targetPlayer = getNearestPlayer()
                    if targetPlayer then
                        waitForStealPrompt() -- Wait for potential stealing confirmation prompt
                        pcall(function() StarterGui:SetCore("PromptBlockPlayer", targetPlayer) end)
                        FastConfirm()
                    end
                end)
            end

            task.spawn(function() task.wait(1.0) FlashTP_AutoStealEnabled = false end)
            return
        end

        linearVelocity.VectorVelocity = Vector3.new(dir.Unit.X * movementSpeed * speedMultiplier, 0, dir.Unit.Z * movementSpeed * speedMultiplier)
    end)
    FlashTP_CurrentMovement = movementLoop
    table.insert(ActiveConnections, FlashTP_CurrentMovement)
end

-- ==========================================
-- UPDATE PET LIST (Brainrots tab)
-- ==========================================
local petListScrollFrame = nil -- Reference to the ScrollingFrame for pet list

local function updatePetList()
    if FlashTP_IsStealing or FlashTP_AutoStealEnabled or thisScriptStopped or not petListScrollFrame then return end

    -- Clear existing items
    for _, child in ipairs(petListScrollFrame:GetChildren()) do
        if child:IsA("Frame") then pcall(function() child:Destroy() end) end
    end

    local tempPets = {}
    local playersInGame = Players:GetPlayers()
    local playerNamesMap = {}
    for _, p in ipairs(playersInGame) do playerNamesMap[p.Name] = true end

    -- Function to detect "brainrot" (stray models indicating a player being brainrotted)
    local function hasBrainrot(targetPlayer)
        -- Anti-cheat method: Check for "fake" parts or unexpected models around player
        if not targetPlayer.Character then return false end
        local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return false end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and not playerNamesMap[v.Name] and not v:IsDescendantOf(targetPlayer.Character) then
                local possibleRoot = v:FindFirstChild("RootPart") or v:FindFirstChild("FakeRootPart")
                if possibleRoot and (possibleRoot.Position - rootPart.Position).Magnitude < 8 then
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
                                    local ownerChar = child.Parent and child.Parent.Parent and child.Parent.Parent.Parent -- Heuristic for owner's character
                                    local owner = Players:GetPlayerFromCharacter(ownerChar)
                                    if owner and hasBrainrot(owner) then -- Only list if the owner exhibits "brainrot" behavior
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

    local ListColors = {
        card   = Color3.fromRGB(18, 18, 28),     -- Dark card background
        accent = Color3.fromRGB(150, 255, 200), -- Vertex-themed accent (light green/mint)
        stroke = Color3.fromRGB(40, 40, 50),     -- Dark stroke
        bright = Color3.fromRGB(240, 240, 250), -- Bright whitish text
        mute   = Color3.fromRGB(150, 150, 160), -- Muted text
    }

    for _, petData in ipairs(tempPets) do
        if thisScriptStopped then break end
        local isSelected = (FlashTP_SelectedPrompt == petData.prompt)

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 48)
        row.BackgroundColor3 = isSelected and ListColors.accent:Lerp(ListColors.card, 0.6) or ListColors.card
        row.BorderSizePixel = 0
        row.Parent = petListScrollFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local rStroke = Instance.new("UIStroke")
        rStroke.Color     = isSelected and ListColors.accent or ListColors.stroke
        rStroke.Thickness = isSelected and 1.5 or 1
        rStroke.Parent    = row

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text               = petData.name
        nameLabel.Size               = UDim2.new(1, -10, 0, 24)
        nameLabel.Position           = UDim2.new(0, 10, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3         = isSelected and ListColors.bright or ListColors.accent
        nameLabel.Font               = Enum.Font.GothamBold
        nameLabel.TextSize           = 14
        nameLabel.TextXAlignment     = Enum.TextXAlignment.Left
        nameLabel.Parent             = row

        local slotLabel = Instance.new("TextLabel")
        slotLabel.Text               = "Slot " .. petData.slot .. " (" .. petData.owner .. ")"
        slotLabel.Size               = UDim2.new(1, -10, 0, 20)
        slotLabel.Position           = UDim2.new(0, 10, 0, 22)
        slotLabel.BackgroundTransparency = 1
        slotLabel.TextColor3         = ListColors.mute
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
            if not FlashTP_IsStealing and not FlashTP_AutoStealEnabled then
                FlashTP_SelectedPrompt     = petData.prompt
                FlashTP_SelectedSlotNumber = petData.slot
                updatePetList() -- Re-render to highlight selected item
            end
        end)
        table.insert(ActiveConnections, rowBtnConn)
    end

    if #tempPets == 0 then
        -- Display "No brainrots found" message
        local emptyCard = Instance.new("Frame")
        emptyCard.Name             = "EmptyCard"
        emptyCard.Size             = UDim2.new(1, -8, 0, 120)
        emptyCard.BackgroundColor3 = ListColors.card
        emptyCard.BorderSizePixel  = 0
        emptyCard.ZIndex           = 4
        emptyCard.Parent           = petListScrollFrame
        Instance.new("UICorner", emptyCard).CornerRadius = UDim.new(0, 10)
        local es = Instance.new("UIStroke"); es.Color = ListColors.stroke; es.Parent = emptyCard

        local iconCircle = Instance.new("Frame")
        iconCircle.Size             = UDim2.new(0, 40, 0, 40)
        iconCircle.Position         = UDim2.new(0.5, -20, 0, 18)
        iconCircle.BackgroundColor3 = ListColors.card:Lerp(Color3.fromRGB(0,0,0), 0.5) -- Darker circle
        iconCircle.BorderSizePixel  = 0
        iconCircle.ZIndex           = 5
        iconCircle.Parent           = emptyCard
        Instance.new("UICorner", iconCircle).CornerRadius = UDim.new(0, 20)
        local is = Instance.new("UIStroke"); is.Color = ListColors.stroke; is.Parent = iconCircle

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size               = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.ZIndex             = 6
        iconLabel.Text               = "⚡" -- Lightning bolt
        iconLabel.TextColor3         = ListColors.accent
        iconLabel.TextSize           = 18
        iconLabel.Font               = Enum.Font.GothamBold
        iconLabel.Parent             = iconCircle

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size               = UDim2.new(1, -16, 0, 22)
        titleLabel.Position           = UDim2.new(0, 8, 0, 64)
        titleLabel.BackgroundTransparency = 1
        titleLabel.ZIndex             = 5
        titleLabel.Text               = "No Brainrots Found"
        titleLabel.TextColor3         = ListColors.bright
        titleLabel.TextSize           = 13
        titleLabel.Font               = Enum.Font.GothamBold
        titleLabel.Parent             = emptyCard

        local subLabel = Instance.new("TextLabel")
        subLabel.Size               = UDim2.new(1, -16, 0, 18)
        subLabel.Position           = UDim2.new(0, 8, 0, 86)
        subLabel.BackgroundTransparency = 1
        subLabel.ZIndex             = 5
        subLabel.Text               = "No players with brainrots currently detected in plots."
        subLabel.TextColor3         = ListColors.mute
        subLabel.TextSize           = 11
        subLabel.Font               = Enum.Font.Gotham
        subLabel.Parent             = emptyCard
    end
end

-- ==========================================
-- GUI DESIGN CONFIGURATION (Vertex PvP Theme)
-- ==========================================
-- Remove old GUIs if they exist
for _, guiName in ipairs({"HUGO’S SCRIPT", "HugoHubBanner", "NOX_HUB", "HUGO_SCRIPT_GUI"}) do
    local oldGui = PlayerGui:FindFirstChild(guiName)
    if oldGui then pcall(function() oldGui:Destroy() end) end
end

-- Define Vertex PvP color palette
local VertexColors = {
    -- Base colors
    primary      = Color3.fromRGB(150, 255, 200), -- Mint green/light green (main accent color)
    secondary    = Color3.fromRGB(100, 200, 150), -- Slightly darker mint for accents
    background   = Color3.fromRGB(12, 12, 18),   -- Very dark blue/purple for overall background
    surface      = Color3.fromRGB(18, 18, 28),   -- Darker surface for panels and cards
    textLight    = Color3.fromRGB(240, 240, 250), -- Bright white/off-white text
    textDark     = Color3.fromRGB(100, 100, 110), -- Muted greyish text
    textAccent   = Color3.fromRGB(150, 255, 200), -- Text matching primary accent

    -- UI components
    stroke       = Color3.fromRGB(40, 40, 50),     -- Subtle dark stroke
    hover        = Color3.fromRGB(25, 25, 38),     -- Darker hover state for buttons
    active       = Color3.fromRGB(130, 230, 180), -- Brighter primary for active elements
    toggleOnKnb  = Color3.fromRGB(240, 240, 250), -- White knob when on
    toggleOffKnb = Color3.fromRGB(80, 80, 90),     -- Dark grey knob when off
    toggleOffTrk = Color3.fromRGB(25, 25, 38),     -- Dark track when off
}

local borderGradientSequence = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    VertexColors.active),
    ColorSequenceKeypoint.new(0.25, VertexColors.surface),
    ColorSequenceKeypoint.new(0.5,  VertexColors.primary),
    ColorSequenceKeypoint.new(0.75, VertexColors.surface),
    ColorSequenceKeypoint.new(1,    VertexColors.active),
})

-- Layout configurations based on device type
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
        winW = 280, winH = 360, -- Smaller GUI (original was 340x480)
        posX = UDim2.new(0.5, 0, 0.5, 0),
        bannerW = 272, bannerH = 70, -- Adjusted banner size
        bannerPos = UDim2.new(0.5, -136, 0, 40),
        btnW = 85, btnH = 35,
        tabH = 30, headerH = 40,
        actionXs = {8, 97, 186}, -- Adjusted for 3 buttons in smaller width
        textSize = { header = 10, btn = 11, tab = 11, title = 18, stats = 11 },
    },
    ipad = {
        winW = 250, winH = 330,
        posX = UDim2.new(0.5, 0, 0.5, 0),
        bannerW = 242, bannerH = 65,
        bannerPos = UDim2.new(0.5, -121, 0, 35),
        btnW = 75, btnH = 32,
        tabH = 28, headerH = 38,
        actionXs = {7, 86, 165},
        textSize = { header = 10, btn = 10, tab = 10, title = 16, stats = 10 },
    },
    mobile = {
        winW = 220, winH = 290,
        posX = UDim2.new(0.5, 0, 0.5, 0),
        bannerW = 212, bannerH = 60,
        bannerPos = UDim2.new(0.5, -106, 0, 30),
        btnW = 65, btnH = 30,
        tabH = 26, headerH = 36,
        actionXs = {6, 77, 148},
        textSize = { header = 9, btn = 9, tab = 9, title = 14, stats = 9 },
    },
}

local Layout = LAYOUT_PRESETS[DEVICE_TYPE]

local VERTEX_PVP_GUI = Instance.new("ScreenGui")
VERTEX_PVP_GUI.Name           = "VertexPvP_GUI"
VERTEX_PVP_GUI.SelectionGroup = false
VERTEX_PVP_GUI.ResetOnSpawn   = false
VERTEX_PVP_GUI.DisplayOrder   = 999
VERTEX_PVP_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
VERTEX_PVP_GUI.IgnoreGuiInset = false
VERTEX_PVP_GUI.Parent         = PlayerGui

-- Outer Border Frame (for gradient effect)
local BorderFrame = Instance.new("Frame")
BorderFrame.Name             = "BorderFrame"
BorderFrame.SelectionGroup   = false
BorderFrame.Size             = UDim2.new(0, Layout.winW + 4, 0, Layout.winH + 4)
BorderFrame.Position         = Layout.posX
BorderFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
BorderFrame.BackgroundColor3 = VertexColors.primary -- Initial color, gradient will override
BorderFrame.BorderSizePixel  = 0
BorderFrame.ClipsDescendants = false
BorderFrame.Active           = false
BorderFrame.Selectable       = false
BorderFrame.Parent           = VERTEX_PVP_GUI

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 8) -- Smaller radius for sleek look
BorderCorner.Parent = BorderFrame

local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color    = borderGradientSequence
BorderGradient.Rotation = 308.077
BorderGradient.Parent   = BorderFrame

-- Main Window Frame
local Window = Instance.new("Frame")
Window.Name             = "Window"
Window.SelectionGroup   = false
Window.Size             = UDim2.new(0, Layout.winW, 0, Layout.winH)
Window.Position         = Layout.posX
Window.AnchorPoint      = Vector2.new(0.5, 0.5)
Window.BackgroundTransparency = 1
Window.BorderSizePixel  = 0
Window.ZIndex           = 2
Window.ClipsDescendants = false
Window.Active           = false
Window.Selectable       = false
Window.Parent           = VERTEX_PVP_GUI

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = VertexColors.background
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.Active           = false
MainFrame.Selectable       = false
MainFrame.Parent           = Window
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6) -- Smaller radius

-- Top Header with Title and Control Buttons
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name             = "HeaderFrame"
HeaderFrame.Size             = UDim2.new(1, 0, 0, Layout.headerH)
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
HeaderLine.BackgroundColor3 = VertexColors.stroke
HeaderLine.BorderSizePixel  = 0
HeaderLine.ZIndex           = 4
HeaderLine.Parent           = HeaderFrame

local LogoCircleInner = Instance.new("Frame")
LogoCircleInner.Size             = UDim2.new(0, 6, 0, 6)
LogoCircleInner.Position         = UDim2.new(0, 8, 0.5, -3) -- Adjusted
LogoCircleInner.BackgroundColor3 = VertexColors.primary
LogoCircleInner.BorderSizePixel  = 0
LogoCircleInner.ZIndex           = 5
LogoCircleInner.Parent           = HeaderFrame
Instance.new("UICorner", LogoCircleInner).CornerRadius = UDim.new(0, 4)

local LogoCircleOuter = Instance.new("Frame")
LogoCircleOuter.Size                 = UDim2.new(0, 10, 0, 10) -- Slightly smaller
LogoCircleOuter.Position             = UDim2.new(0, 6, 0.5, -5) -- Adjusted
LogoCircleOuter.BackgroundColor3     = VertexColors.primary
LogoCircleOuter.BackgroundTransparency = 0.7
LogoCircleOuter.BorderSizePixel      = 0
LogoCircleOuter.ZIndex               = 4
LogoCircleOuter.Parent               = HeaderFrame
Instance.new("UICorner", LogoCircleOuter).CornerRadius = UDim.new(0, 5)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(0, 110, 1, 0)
TitleLabel.Position           = UDim2.new(0, 20, 0, 0) -- Adjusted
TitleLabel.BackgroundTransparency = 1
TitleLabel.ZIndex             = 5
TitleLabel.Text               = "Vertex PvP"
TitleLabel.TextColor3         = VertexColors.textLight
TitleLabel.TextSize           = Layout.textSize.header
TitleLabel.Font               = Enum.Font.GothamBold
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.Parent             = HeaderFrame

-- Subtitle label (formerly "Hugo pvp") removed for cleaner look, integrated into main title or removed.
-- If you want a subtitle, create a new TextLabel here and adjust its position dynamically.

local HEADER_BTN_SIZE = DEVICE_TYPE == "mobile" and 18 or 20
local function createHeaderButton(name: string, txt: string, xOff: number)
    local btn = Instance.new("TextButton")
    btn.Name            = name
    btn.Size            = UDim2.new(0, HEADER_BTN_SIZE, 0, HEADER_BTN_SIZE)
    btn.Position        = UDim2.new(1, xOff, 0.5, -HEADER_BTN_SIZE/2)
    btn.BackgroundColor3= VertexColors.surface
    btn.BorderSizePixel = 0
    btn.ZIndex          = 6
    btn.Text            = txt
    btn.TextColor3      = VertexColors.textDark
    btn.TextSize        = Layout.textSize.header
    btn.Font            = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent          = HeaderFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke"); stroke.Color = VertexColors.stroke; stroke.Parent = btn
    return btn
end

local HEADER_BTN_OFFSETS = DEVICE_TYPE == "mobile" and {-56, -36, -16} or {-60, -40, -20}
local LockButton  = createHeaderButton("Lock",  "🔒", HEADER_BTN_OFFSETS[1])
local MinimizeButton = createHeaderButton("Minimize",   "—",  HEADER_BTN_OFFSETS[2])
local CloseButton = createHeaderButton("Close", "X",  HEADER_BTN_OFFSETS[3])

-- Action Buttons (Flash TP, Block, Reset)
local ActionButtonsFrame = Instance.new("Frame")
ActionButtonsFrame.Name             = "ActionButtonsFrame"
ActionButtonsFrame.Size             = UDim2.new(1, 0, 0, Layout.btnH + 16) -- Height for buttons + padding
ActionButtonsFrame.Position         = UDim2.new(0, 0, 0, Layout.headerH) -- Directly below header
ActionButtonsFrame.BackgroundTransparency = 1
ActionButtonsFrame.BorderSizePixel  = 0
ActionButtonsFrame.ZIndex           = 4
ActionButtonsFrame.Parent           = MainFrame

local ActionButtonsLine = Instance.new("Frame")
ActionButtonsLine.Size             = UDim2.new(1, 0, 0, 1)
ActionButtonsLine.Position         = UDim2.new(0, 0, 1, -1)
ActionButtonsLine.BackgroundColor3 = VertexColors.stroke
ActionButtonsLine.BorderSizePixel  = 0
ActionButtonsLine.ZIndex           = 4
ActionButtonsLine.Parent           = ActionButtonsFrame

local function createActionButton(name: string, label: string, xPos: number, btnWidth: number)
    local btn = Instance.new("TextButton")
    btn.Name            = name
    btn.Size            = UDim2.new(0, btnWidth, 0, Layout.btnH)
    btn.Position        = UDim2.new(0, xPos, 0, 8) -- 8 units of top padding
    btn.BackgroundColor3= VertexColors.surface
    btn.BorderSizePixel = 0
    btn.ZIndex          = 5
    btn.Text            = ""
    btn.AutoButtonColor = false
    btn.Parent          = ActionButtonsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = VertexColors.stroke
    local topLine = Instance.new("Frame") -- Visual accent line
    topLine.Size             = UDim2.new(1, -10, 0, 2)
    topLine.Position         = UDim2.new(0, 5, 0, 0)
    topLine.BackgroundColor3 = VertexColors.stroke
    topLine.BorderSizePixel  = 0
    topLine.ZIndex           = 6
    topLine.Parent           = btn
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(0, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex           = 7
    lbl.Text             = label
    lbl.TextColor3       = VertexColors.textLight
    lbl.TextSize         = Layout.textSize.btn
    lbl.Font             = Enum.Font.GothamBold
    lbl.Parent           = btn
    return btn, topLine
end

local FlashTPButton, FlashTPAccent = createActionButton("FlashTP", "FLASH TP", Layout.actionXs[1], Layout.btnW)
local BlockButton,   BlockAccent   = createActionButton("Block",   "BLOCK",    Layout.actionXs[2], Layout.btnW)
local ResetButton,   ResetAccent   = createActionButton("Reset",   "RESET",    Layout.actionXs[3], Layout.btnW)

-- Tab Bar (Brainrots / Settings)
local TabBarFrame = Instance.new("Frame")
TabBarFrame.Size             = UDim2.new(1, 0, 0, Layout.tabH)
TabBarFrame.Position         = UDim2.new(0, 0, 0, Layout.headerH + Layout.btnH + 16) -- Below action buttons
TabBarFrame.BackgroundColor3 = VertexColors.background
TabBarFrame.BorderSizePixel  = 0
TabBarFrame.ZIndex           = 5
TabBarFrame.Parent           = MainFrame
local TabListLayout = Instance.new("UIListLayout", TabBarFrame)
TabListLayout.SortOrder        = Enum.SortOrder.LayoutOrder
TabListLayout.FillDirection    = Enum.FillDirection.Horizontal
TabListLayout.VerticalAlignment= Enum.VerticalAlignment.Center
TabListLayout.FlexWrapping     = Enum.FlexWrapping.Wrap

local function createTabButton(name: string, text: string, layoutOrder: number, isActive: boolean)
    local btn = Instance.new("TextButton")
    btn.Name             = name
    btn.Size             = UDim2.new(0.5, 0, 1, 0) -- Two tabs, each taking 50% width
    btn.BackgroundColor3 = VertexColors.background
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
    lbl.TextColor3         = isActive and VertexColors.textAccent or VertexColors.textDark
    lbl.TextSize           = Layout.textSize.tab
    lbl.Font               = Enum.Font.GothamMedium
    lbl.Parent             = btn
    local indicator = Instance.new("Frame")
    indicator.Size             = UDim2.new(1, -16, 0, 2)
    indicator.Position         = UDim2.new(0, 8, 1, -2)
    indicator.BackgroundColor3 = VertexColors.primary
    indicator.BackgroundTransparency = isActive and 0 or 1
    indicator.BorderSizePixel  = 0
    indicator.ZIndex           = 7
    indicator.Parent           = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 1)
    return btn, lbl, indicator
end

local BrainrotsTabBtn, BrainrotsTabText, BrainrotsTabIndicator = createTabButton("BrainrotsTab", "Brainrots", 1, true)
local SettingsTabBtn,  SettingsTabText,  SettingsTabIndicator  = createTabButton("SettingsTab",  "Settings",  2, false)

local TabsBottomLine = Instance.new("Frame", TabBarFrame) -- Line below tabs, same as header separation for consistency
TabsBottomLine.Size             = UDim2.new(1, 0, 0, 1)
TabsBottomLine.Position         = UDim2.new(0, 0, 1, 0)
TabsBottomLine.BackgroundColor3 = VertexColors.stroke
TabsBottomLine.BorderSizePixel  = 0
TabsBottomLine.ZIndex           = 4


local ContentAreaFrame = Instance.new("Frame")
ContentAreaFrame.Size             = UDim2.new(1, 0, 1, -(Layout.headerH + Layout.btnH + 16 + Layout.tabH + 1)) -- Adjust height based on header, actions, and tabs
ContentAreaFrame.Position         = UDim2.new(0, 0, 0, Layout.headerH + Layout.btnH + 16 + Layout.tabH + 1)
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
PetScrollingFrame.Active                = true -- Set to active for interaction
PetScrollingFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
PetScrollingFrame.ScrollBarThickness    = 3
PetScrollingFrame.ScrollBarImageColor3  = VertexColors.secondary
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
SettingsScrollingFrame.Active                = true
SettingsScrollingFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
SettingsScrollingFrame.ScrollBarThickness    = 3
SettingsScrollingFrame.ScrollBarImageColor3  = VertexColors.secondary
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

local function createSettingsSectionHeader(text: string)
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
    line.BackgroundColor3 = VertexColors.stroke
    line.BorderSizePixel  = 0
    line.ZIndex           = 5
    local pill = Instance.new("Frame", wrap)
    pill.Size             = UDim2.new(0, 0, 1, 0)
    pill.Position         = UDim2.new(0.5, 0, 0, 0)
    pill.AnchorPoint      = Vector2.new(0.5, 0)
    pill.BackgroundColor3 = VertexColors.surface
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 6
    pill.AutomaticSize    = Enum.AutomaticSize.X
    local lbl = Instance.new("TextLabel", pill)
    lbl.Size               = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex             = 7
    lbl.Text               = "  " .. text .. "  " -- Add padding for text
    lbl.TextColor3         = VertexColors.textDark
    lbl.TextSize           = Layout.textSize.header - 2 -- Slightly smaller than header text
    lbl.Font               = Enum.Font.GothamBold
    return wrap
end

local function createToggleRow(title: string, desc: string, globalVarKey: string)
    currentSectionOrder += 1
    local row = Instance.new("Frame")
    row.Name             = "ToggleRow_" .. globalVarKey
    row.Size             = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = VertexColors.surface
    row.BorderSizePixel  = 0
    row.ZIndex           = 4
    row.LayoutOrder      = currentSectionOrder
    row.Parent           = SettingsScrollingFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", row); stroke.Color = VertexColors.stroke

    local accentBar = Instance.new("Frame", row)
    accentBar.Size             = UDim2.new(0, 3, 1, -10)
    accentBar.Position         = UDim2.new(0, 0, 0, 5)
    accentBar.BackgroundColor3 = VertexColors.primary
    accentBar.BorderSizePixel  = 0
    accentBar.ZIndex           = 5
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

    local titleTxt = Instance.new("TextLabel", row)
    titleTxt.Size               = UDim2.new(1, -52, 0, 24)
    titleTxt.Position           = UDim2.new(0, 12, 0, 0)
    titleTxt.BackgroundTransparency = 1
    titleTxt.ZIndex             = 5
    titleTxt.Text               = title
    titleTxt.TextColor3         = VertexColors.textLight
    titleTxt.TextSize           = Layout.textSize.btn
    titleTxt.Font               = Enum.Font.GothamBold
    titleTxt.TextXAlignment     = Enum.TextXAlignment.Left

    local descTxt = Instance.new("TextLabel", row)
    descTxt.Size               = UDim2.new(1, -52, 0, 20)
    descTxt.Position           = UDim2.new(0, 12, 0, 22)
    descTxt.BackgroundTransparency = 1
    descTxt.ZIndex             = 5
    descTxt.Text               = desc
    descTxt.TextColor3         = VertexColors.textDark
    descTxt.TextSize           = Layout.textSize.tab - 2
    descTxt.Font               = Enum.Font.Gotham
    descTxt.TextWrapped        = true
    descTxt.TextXAlignment     = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(0, 36, 0, 20)
    track.Position         = UDim2.new(1, -42, 0.5, -10)
    track.BackgroundColor3 = VertexColors.primary
    track.BorderSizePixel  = 0
    track.ZIndex           = 6
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 10)
    local trackStroke = Instance.new("UIStroke", track); trackStroke.Color = VertexColors.primary

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = UDim2.new(0, 19, 0.5, -7)
    knob.BackgroundColor3 = VertexColors.toggleOnKnb
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 7
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)

    local hitArea = Instance.new("TextButton", row)
    hitArea.Size               = UDim2.new(1, 0, 1, 0)
    hitArea.BackgroundTransparency = 1
    hitArea.ZIndex             = 8
    hitArea.Text               = ""

    local currentIsOn = _G["VertexPvP_" .. globalVarKey]
    local function renderToggleUI(animate: boolean)
        local info = TweenInfo.new(animate and 0.16 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if currentIsOn then
            TweenService:Create(track, info, { BackgroundColor3 = VertexColors.primary }):Play()
            TweenService:Create(trackStroke, info, { Color = VertexColors.primary }):Play()
            TweenService:Create(knob, info, { Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = VertexColors.toggleOnKnb }):Play()
        else
            TweenService:Create(track, info, { BackgroundColor3 = VertexColors.toggleOffTrk }):Play()
            TweenService:Create(trackStroke, info, { Color = VertexColors.stroke }):Play()
            TweenService:Create(knob, info, { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = VertexColors.toggleOffKnb }):Play()
        end
    end
    renderToggleUI(false)

    hitArea.MouseButton1Click:Connect(function()
        currentIsOn = not currentIsOn
        _G["VertexPvP_" .. globalVarKey] = currentIsOn
        renderToggleUI(true)
        saveSettings()

        -- Trigger specific actions
        if globalVarKey == "AntiRagdoll" then
            if _G.VertexPvP_AntiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end
        end
    end)
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
-- Removed "AP ESP" as per previous discussion, it was not implemented logic-wise.

-- ==========================================
-- FLOATING STATS BANNER
-- ==========================================
local VertexStatsBanner = Instance.new("ScreenGui")
VertexStatsBanner.Name           = "VertexPvP_Banner"
VertexStatsBanner.SelectionGroup = false
VertexStatsBanner.ResetOnSpawn   = false
VertexStatsBanner.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
VertexStatsBanner.IgnoreGuiInset = false
VertexStatsBanner.Parent         = PlayerGui

local BannerFrame = Instance.new("Frame")
BannerFrame.Size             = UDim2.new(0, Layout.bannerW, 0, Layout.bannerH)
BannerFrame.Position         = Layout.bannerPos
BannerFrame.BackgroundColor3 = VertexColors.primary
BannerFrame.BorderSizePixel  = 0
BannerFrame.Parent           = VertexStatsBanner
Instance.new("UICorner", BannerFrame).CornerRadius = UDim.new(0, 8) -- Smaller corner radius

local BannerGradient = Instance.new("UIGradient")
BannerGradient.Color    = borderGradientSequence
BannerGradient.Rotation = 224.297
BannerGradient.Parent   = BannerFrame

local BannerInnerFrame = Instance.new("Frame")
BannerInnerFrame.Size                 = UDim2.new(0, Layout.bannerW - 4, 0, Layout.bannerH - 4)
BannerInnerFrame.Position             = UDim2.new(0, 2, 0, 2)
BannerInnerFrame.BackgroundColor3     = VertexColors.surface
BannerInnerFrame.BackgroundTransparency = 0.15
BannerInnerFrame.BorderSizePixel      = 0
BannerInnerFrame.Parent               = BannerFrame
Instance.new("UICorner", BannerInnerFrame).CornerRadius = UDim.new(0, 6) -- Smaller corner radius

local BannerTitle = Instance.new("TextLabel")
BannerTitle.Size               = UDim2.new(1, 0, 0, 30)
BannerTitle.Position           = UDim2.new(0, 0, 0, 10) -- Slightly higher
BannerTitle.BackgroundTransparency = 1
BannerTitle.Text               = string.format('<font color="#%s">Vertex</font> <font color="#%s">PvP</font>',
    VertexColors.textLight:ToHex(), -- Brighter "Vertex"
    VertexColors.primary:ToHex())   -- Primary accent "PvP"
BannerTitle.TextSize           = Layout.textSize.title
BannerTitle.Font               = Enum.Font.GothamBold
BannerTitle.RichText           = true
BannerTitle.Parent             = BannerInnerFrame

local BannerStats = Instance.new("TextLabel")
BannerStats.Size               = UDim2.new(1, 0, 0, 18)
BannerStats.Position           = UDim2.new(0, 0, 0, 38) -- Adjusted position
BannerStats.BackgroundTransparency = 1
BannerStats.Text               = string.format('<font color="#%s">FPS:</font> 60   <font color="#%s">PING:</font> 35ms',
    VertexColors.secondary:ToHex(),
    VertexColors.secondary:ToHex())
BannerStats.TextColor3         = VertexColors.textLight
BannerStats.TextSize           = Layout.textSize.stats
BannerStats.Font               = Enum.Font.GothamMedium
BannerStats.RichText           = true
BannerStats.Parent             = BannerInnerFrame

-- ==========================================
-- GRADIENT ANIMATION
-- ==========================================
task.spawn(function()
    local baseRotationMain = BorderGradient.Rotation
    local baseRotationBanner = BannerGradient.Rotation
    while Window.Parent and BannerFrame.Parent and not thisScriptStopped do
        local t = os.clock()
        -- Animate gradients for both main window border and stats banner
        pcall(function() BorderGradient.Rotation = (baseRotationMain + t * 45) % 360 end) -- Slower rotation
        pcall(function() BannerGradient.Rotation = (baseRotationBanner + t * 45) % 360 end)
        RunService.RenderStepped:Wait()
    end
end)


-- ==========================================
-- FPS / PING COUNTER
-- ==========================================
local FPS_FrameTimes = {}
local fpsPingUpdateLoop = RunService.Heartbeat:Connect(function()
    if not BannerStats.Parent or thisScriptStopped then
        if fpsPingUpdateLoop.Connected then pcall(function() fpsPingUpdateLoop:Disconnect() end) end
        return
    end

    local now = os.clock()
    table.insert(FPS_FrameTimes, now)
    while FPS_FrameTimes[1] and now - FPS_FrameTimes[1] > 1 do table.remove(FPS_FrameTimes, 1) end

    local fps = #FPS_FrameTimes
    -- More accurate FPS for low frame rates (short spikes)
    if fps < 2 and FPS_FrameTimes[1] then
        local span = os.clock() - FPS_FrameTimes[1]
        if span > 0 then fps = math.floor(#FPS_FrameTimes / span + 0.5) end
    end

    local ping = 0
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)

    pcall(function()
        BannerStats.Text = string.format(
            '<font color="#%s">FPS:</font> %d   <font color="#%s">PING:</font> %dms',
            VertexColors.secondary:ToHex(),
            fps,
            VertexColors.secondary:ToHex(),
            ping
        )
    end)
end)
table.insert(ActiveConnections, fpsPingUpdateLoop)

-- ==========================================
-- DRAG FUNCTIONALITY
-- ==========================================
local dragging = false
local dragStart = Vector2.new(0, 0)
local frameStart = Vector2.new(0, 0)

-- Function to handle drag start
local function onDragStart(input)
    if not LockButton.Text == "🔒" and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        frameStart = Window.Position
        -- Prevent input bubbling for smoother drag (optional, but good practice)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end
HeaderFrame.InputBegan:Connect(onDragStart)

-- Function to handle drag changes
local dragInputChangedConn = UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
        -- Keep BorderFrame position synced
        BorderFrame.Position = Window.Position
    end
end)
table.insert(ActiveConnections, dragInputChangedConn)

-- Function to handle drag end
local dragInputEndedConn = UserInputService.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        dragging = false
    end
end)
table.insert(ActiveConnections, dragInputEndedConn)

-- ==========================================
-- TAB SWITCHING LOGIC
-- ==========================================
local activeTabName = "brainrots"
local TAB_SWITCH_DUR = 0.2 -- Duration of tab switch animation

local function setTab(tabName: string)
    if tabName == activeTabName then return end
    activeTabName = tabName
    local info = TweenInfo.new(TAB_SWITCH_DUR, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    if tabName == "settings" then
        SettingsContentFrame.Visible = true
        SettingsContentFrame.Position = UDim2.new(1, 0, 0, 0) -- Start off-screen right
        TweenService:Create(BrainrotsContentFrame, info, { Position = UDim2.new(-1, 0, 0, 0) }):Play()
        TweenService:Create(SettingsContentFrame, info, { Position = UDim2.new(0, 0, 0, 0) }):Play()
        BrainrotsTabText.TextColor3 = VertexColors.textDark
        SettingsTabText.TextColor3 = VertexColors.textAccent
        TweenService:Create(BrainrotsTabIndicator, info, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(SettingsTabIndicator, info, { BackgroundTransparency = 0 }):Play()
    else -- "brainrots"
        BrainrotsContentFrame.Visible = true
        BrainrotsContentFrame.Position = UDim2.new(-1, 0, 0, 0) -- Start off-screen left
        TweenService:Create(BrainrotsContentFrame, info, { Position = UDim2.new(0, 0, 0, 0) }):Play()
        TweenService:Create(SettingsContentFrame, info, { Position = UDim2.new(1, 0, 0, 0) }):Play()
        BrainrotsTabText.TextColor3 = VertexColors.textAccent
        SettingsTabText.TextColor3 = VertexColors.textDark
        TweenService:Create(BrainrotsTabIndicator, info, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(SettingsTabIndicator, info, { BackgroundTransparency = 1 }):Play()
        task.delay(TAB_SWITCH_DUR, function() if activeTabName == "brainrots" then SettingsContentFrame.Visible = false end end)
    end
end
-- Initial state for content frames
BrainrotsContentFrame.Position = UDim2.new(0, 0, 0, 0)
SettingsContentFrame.Position = UDim2.new(1, 0, 0, 0)

BrainrotsTabBtn.MouseButton1Click:Connect(function() setTab("brainrots") end)
SettingsTabBtn.MouseButton1Click:Connect(function() setTab("settings") end)

-- ==========================================
-- WINDOW CONTROL BUTTONS
-- ==========================================
local isLocked    = false
LockButton.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    LockButton.Text      = isLocked and "🔒" or "🔓" -- Change emoji
    HeaderFrame.Active   = not isLocked -- Disable dragging when locked
    LockButton.TextColor3= isLocked and VertexColors.primary or VertexColors.textDark
end)

local isMinimized = false
local fullSize    = Window.Size
local fullBorderSize = BorderFrame.Size
local MIN_WINDOW_HEIGHT   = Layout.headerH + Layout.btnH + 16 + Layout.tabH + 1 + 5 -- Header + actions + tabs bottom line + small padding
local MIN_BORDER_HEIGHT   = MIN_WINDOW_HEIGHT + 4 -- Window border thickness
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local info = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) -- Smoother tween
    if isMinimized then
        TweenService:Create(Window, info, { Size = UDim2.new(0, Layout.winW, 0, MIN_WINDOW_HEIGHT) }):Play()
        TweenService:Create(BorderFrame, info, { Size = UDim2.new(0, Layout.winW+4, 0, MIN_BORDER_HEIGHT) }):Play()
    else
        TweenService:Create(Window, info, { Size = fullSize }):Play()
        TweenService:Create(BorderFrame, info, { Size = fullBorderSize }):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local t1 = TweenService:Create(Window, info, { Size = UDim2.new(0,0,0,0) })
    local t2 = TweenService:Create(BorderFrame, info, { Size = UDim2.new(0,0,0,0) })
    t1:Play(); t2:Play()
    t1.Completed:Connect(function()
        -- Ensure all GUI elements are cleaned up
        if VERTEX_PVP_GUI.Parent then pcall(function() VERTEX_PVP_GUI:Destroy() end) end
        if VertexStatsBanner.Parent then pcall(function() VertexStatsBanner:Destroy() end) end
    end)
end)

-- ==========================================
-- HOVER EFFECTS (Centralized)
-- ==========================================
local function hookButtonHover(btn: GuiButton, normalColor: Color3, hoverColor: Color3)
    local tweenInfo = TweenInfo.new(0.12)
    local tweenInfoDown = TweenInfo.new(0.06)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tweenInfo, { BackgroundColor3 = hoverColor }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tweenInfo, { BackgroundColor3 = normalColor }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, tweenInfoDown, { BackgroundColor3 = VertexColors.background }):Play() -- Darken on click
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, tweenInfo, { BackgroundColor3 = hoverColor }):Play()
    end)
end

-- Apply hover effects to action buttons
hookButtonHover(FlashTPButton, VertexColors.surface, VertexColors.hover)
hookButtonHover(BlockButton,   VertexColors.surface, VertexColors.hover)
hookButtonHover(ResetButton,   VertexColors.surface, VertexColors.hover)

-- Apply hover effects to header control buttons
for _, b in ipairs({ LockButton, MinimizeButton, CloseButton }) do
    hookButtonHover(b, VertexColors.surface, VertexColors.hover)
end

local function flashAccentLine(line: Frame)
    -- Flash with primary color
    line.BackgroundColor3 = VertexColors.primary
    TweenService:Create(line, TweenInfo.new(0.4), { BackgroundColor3 = VertexColors.stroke }):Play()
end

-- ==========================================
-- FLASH TP BUTTON VISUAL EFFECT (Blinking)
-- ==========================================
local isFlashBlinking = false
local BLINK_COLOR_HIGH  = VertexColors.primary:Lerp(Color3.fromRGB(255, 0, 0), 0.5) -- Primary mixed with red for urgency
local BLINK_COLOR_LOW   = VertexColors.surface:Lerp(Color3.fromRGB(150, 0, 0), 0.5) -- Darker base with red hint
local BLINK_TWEEN_INFO  = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local BLINK_PERIOD = 0.3

local function startFlashBlink()
    if isFlashBlinking then return end
    isFlashBlinking = true
    task.spawn(function()
        while isFlashBlinking and not thisScriptStopped do
            TweenService:Create(FlashTPButton,     BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_HIGH }):Play()
            TweenService:Create(FlashTPAccent, BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_HIGH }):Play()
            -- If Brainrots tab is active, make its indicator blink too
            if activeTabName == "brainrots" then
                TweenService:Create(BrainrotsTabIndicator, BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_HIGH, BackgroundTransparency = 0 }):Play()
            end
            task.wait(BLINK_PERIOD)
            if not isFlashBlinking then break end
            TweenService:Create(FlashTPButton,     BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_LOW }):Play()
            TweenService:Create(FlashTPAccent, BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_LOW }):Play()
            if activeTabName == "brainrots" then
                TweenService:Create(BrainrotsTabIndicator, BLINK_TWEEN_INFO, { BackgroundColor3 = BLINK_COLOR_LOW, BackgroundTransparency = 0 }):Play()
            end
            task.wait(BLINK_PERIOD)
        end
    end)
end

local function stopFlashBlink()
    if not isFlashBlinking then return end
    isFlashBlinking = false
    TweenService:Create(FlashTPButton,     TweenInfo.new(0.2), { BackgroundColor3 = VertexColors.surface }):Play()
    TweenService:Create(FlashTPAccent, TweenInfo.new(0.2), { BackgroundColor3 = VertexColors.stroke }):Play()
    -- Restore Brainrots tab indicator if it was blinking
    TweenService:Create(BrainrotsTabIndicator, TweenInfo.new(0.2), { BackgroundColor3 = VertexColors.primary, BackgroundTransparency = 0 }):Play()
end

startFlashBlink() -- By default, Flash TP button blinks until a pet is selected

-- ==========================================
-- INTERACTIVE BUTTON EVENTS
-- ==========================================
FlashTPButton.MouseButton1Click:Connect(function()
    if FlashTP_SelectedPrompt and FlashTP_SelectedSlotNumber then
        if not FlashTP_IsStealing and not FlashTP_AutoStealEnabled then
            flashAccentLine(FlashTPAccent)
            startTripToPetSlot(FlashTP_SelectedPrompt, FlashTP_SelectedSlotNumber)
        end
    else
        warn("[Vertex PvP] No pet selected for Flash TP!")
    end
end)

BlockButton.MouseButton1Click:Connect(function()
    flashAccentLine(BlockAccent)
    local targetPlayer = getNearestPlayer()
    if not targetPlayer then
        warn("[Vertex PvP] No nearest player found to block.")
        return
    end
    waitForStealPrompt() -- Wait for potential stealing confirmation prompt
    pcall(function() StarterGui:SetCore("PromptBlockPlayer", targetPlayer) end)
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
    while task.wait(1.5) do -- Refresh pet list every 1.5 seconds
        if thisScriptStopped then break end
        if activeTabName == "brainrots" then -- Only update if on the brainrots tab for performance
            updatePetList()
            if FlashTP_SelectedPrompt and FlashTP_SelectedSlotNumber then
                stopFlashBlink()
            else
                startFlashBlink()
            end
        end
    end
end)
updatePetList() -- Initial update on script load

-- ==========================================
-- ENTRY ANIMATION
-- ==========================================
task.spawn(function()
    local targetPos = Layout.posX
    Window.Position         = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, targetPos.Y.Scale, targetPos.Y.Offset - 60) -- Start higher up
    BorderFrame.Position    = Window.Position -- Keep border synced initially
    Window.Visible = true

    TweenService:Create(Window, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = targetPos }):Play()
    local bt = TweenService:Create(BorderFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = targetPos })
    bt:Play()
    bt.Completed:Wait()
    -- After animation, ensure BorderFrame and Window position are perfectly consistent
    BorderFrame.Position = Window.Position
    -- Connect to RenderStepped to ensure border frame always follows window
    local syncBorderConn = RunService.RenderStepped:Connect(function()
        if Window.Parent and BorderFrame.Parent then
            BorderFrame.Position = Window.Position
        else
            if syncBorderConn.Connected then syncBorderConn:Disconnect() end
        end
    end)
    table.insert(ActiveConnections, syncBorderConn)
end)

-- ==========================================
-- GLOBAL SCRIPT PURGE (for stopping/re-executing the script cleanly)
-- ==========================================
_G.VertexPvP_Script_Purge = function()
    thisScriptStopped = true
    -- Disconnect all active connections
    for _, conn in ipairs(ActiveConnections) do
        if conn and conn.Connected then pcall(function() conn:Disconnect() end) end
    end
    ActiveConnections = {} -- Clear the table

    -- Stop anti-ragdoll if it was running
    stopAntiRagdoll()

    -- Destroy all created GUI elements
    if VERTEX_PVP_GUI.Parent then pcall(function() VERTEX_PVP_GUI:Destroy() end) end
    if VertexStatsBanner.Parent then pcall(function() VertexStatsBanner:Destroy() end) end

    -- Reset the global purge function to nil
    _G.VertexPvP_Script_Purge = nil
end
