local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
repeat task.wait() until LocalPlayer.Character
task.wait(0.5)

if _G.ICEHUB_Loaded then
    if _G.ICEHUB_GUI then pcall(function() _G.ICEHUB_GUI:Destroy() end) end
    if _G.ICEHUB_Connections then for _, c in pairs(_G.ICEHUB_Connections) do pcall(function() c:Disconnect() end) end end
    if _G.ICEHUB_ESP then for _, v in pairs(_G.ICEHUB_ESP) do pcall(function() v:Destroy() end) end end
end
_G.ICEHUB_Loaded = true
_G.ICEHUB_Connections = {}
_G.ICEHUB_ESP = {}

local Config = {
    SpeedBoost = false,
    WalkSpeed = false,
    HighJump = false,
    Esp = false,
    AntiRagdoll = false,
    Hitbox = false,
    SpinBot = false,
    Performance = false,
    InfiniteJump = false,
    UnwalkAnimation = false,
    AutoBat = false,
    PaintballSpammer = false,
    AntiTrap = false,
    AntiSentry = false,
    SpeedValue = 30,
    WalkValue = 59.5,
    JumpPower = 65,
    HitboxSize = 14,
    SpinSpeed = 35,
    Keybinds = {
        SpeedBoost = nil,
        WalkSpeed = nil,
        HighJump = nil,
        Esp = nil,
        AntiRagdoll = nil,
        Hitbox = nil,
        SpinBot = nil,
        Performance = nil,
        InfiniteJump = nil,
        UnwalkAnimation = nil,
        AutoBat = nil,
        PaintballSpammer = nil,
        AntiTrap = nil,
        AntiSentry = nil
    }
}

local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(28, 28, 35),
    Elevated = Color3.fromRGB(35, 35, 42),
    Primary = Color3.fromRGB(88, 101, 242),
    Secondary = Color3.fromRGB(114, 137, 218),
    Accent = Color3.fromRGB(87, 242, 135),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(185, 187, 190),
    TextTertiary = Color3.fromRGB(114, 118, 125),
    Divider = Color3.fromRGB(40, 40, 48),
    CheckOff = Color3.fromRGB(50, 50, 58),
    SliderBG = Color3.fromRGB(45, 45, 52),
    Shadow = Color3.fromRGB(0, 0, 0),
}

local HttpService = game:GetService("HttpService")
local function SaveConfig()
    local savedData = {
        Config = {},
        Keybinds = {}
    }
    
    for key, value in pairs(Config) do
        if key ~= "Keybinds" then
            savedData.Config[key] = value
        end
    end
    
    for key, value in pairs(Config.Keybinds) do
        if value then
            savedData.Keybinds[key] = value.Name
        end
    end
    
    _G.ICEHUB_SavedConfig = savedData
    
    pcall(function()
        if writefile then
            writefile("IceHub_Config.json", HttpService:JSONEncode(savedData))
        end
    end)
end
local function LoadConfig()
    local savedData = nil
    
    pcall(function()
        if readfile and isfile and isfile("IceHub_Config.json") then
            savedData = HttpService:JSONDecode(readfile("IceHub_Config.json"))
        end
    end)
    
    if not savedData and _G.ICEHUB_SavedConfig then
        savedData = _G.ICEHUB_SavedConfig
    end
    
    if savedData then
        if savedData.Config then
            for key, value in pairs(savedData.Config) do
                if Config[key] ~= nil then
                    Config[key] = value
                end
            end
        end
        
        if savedData.Keybinds then
            for key, keyName in pairs(savedData.Keybinds) do
                local keyCode = Enum.KeyCode[keyName]
                if keyCode then
                    Config.Keybinds[key] = keyCode
                end
            end
        end
    end
end

local HighJumpConnection = nil
local HighJumpBoosted = false
local JUMP_BOOST = 85
local FALL_LIMIT = -35
local FALL_SMOOTHNESS = 0.25
local function EnableHighJump()
    if HighJumpConnection then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    local jumpConn = humanoid.Jumping:Connect(function(active)
        if active and not HighJumpBoosted then
            HighJumpBoosted = true
            root.AssemblyLinearVelocity += Vector3.new(0, JUMP_BOOST, 0)
        end
    end)
    
    local landConn = humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Landed then
            HighJumpBoosted = false
        end
    end)
    
    local heartbeatConn = RunService.Heartbeat:Connect(function()
        if not root or not root.Parent then return end
        local velocity = root.AssemblyLinearVelocity
        if velocity.Y < FALL_LIMIT then
            local targetVelocity = Vector3.new(velocity.X, FALL_LIMIT, velocity.Z)
            root.AssemblyLinearVelocity = velocity:Lerp(targetVelocity, FALL_SMOOTHNESS)
        end
    end)
    
    HighJumpConnection = {jumpConn, landConn, heartbeatConn}
end
local function DisableHighJump()
    if HighJumpConnection then
        for _, conn in ipairs(HighJumpConnection) do
            pcall(function() conn:Disconnect() end)
        end
        HighJumpConnection = nil
    end
    HighJumpBoosted = false
end
local AntiRagdollActive = false
local AntiRagdollConnections = {}
local function EnableAntiRagdoll()
    if AntiRagdollActive then return end
    AntiRagdollActive = true
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    local function IsRagdollState()
        local state = humanoid:GetState()
        return state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or 
               state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.GettingUp
    end
    
    local function CleanRagdollEffects()
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") or
               (obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B")) or
               obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                obj:Destroy()
            elseif obj:IsA("Motor6D") then
                obj.Enabled = true
            end
        end
    end
    
    table.insert(AntiRagdollConnections, humanoid.StateChanged:Connect(function(_, newState)
        if IsRagdollState() then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            CleanRagdollEffects()
        end
    end))
end
local function DisableAntiRagdoll()
    AntiRagdollActive = false
    for _, conn in pairs(AntiRagdollConnections) do
        pcall(function() conn:Disconnect() end)
    end
    AntiRagdollConnections = {}
end
local PerformanceEnabled = false
local OriginalSkybox = nil
local function EnablePerformance()
    if PerformanceEnabled then return end
    PerformanceEnabled = true
    
    local lighting = game:GetService("Lighting")
    
    OriginalSkybox = lighting:FindFirstChildOfClass("Sky")
    
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 2
    lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    settings().Rendering.QualityLevel = "Level01"
    
    if OriginalSkybox then
        OriginalSkybox.Parent = nil
    end
    
    local sky = Instance.new("Sky")
    sky.Name = "ICEHUB_Sky"
    sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
    sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
    sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
    sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
    sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
    sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
    sky.StarCount = 5000
    sky.SunAngularSize = 0
    sky.MoonAngularSize = 0
    sky.Parent = lighting
    
    lighting.TimeOfDay = "00:00:00"
    lighting.Ambient = Color3.fromRGB(0, 50, 150)
    lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 100)
    lighting.ColorShift_Top = Color3.fromRGB(50, 100, 255)
    
    for _, effect in pairs(lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
           effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or
           effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
    
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 0
end
local function DisablePerformance()
    if not PerformanceEnabled then return end
    PerformanceEnabled = false
    
    local lighting = game:GetService("Lighting")
    
    local customSky = lighting:FindFirstChild("ICEHUB_Sky")
    if customSky then
        customSky:Destroy()
    end
    
    if OriginalSkybox then
        OriginalSkybox.Parent = lighting
    end
    
    lighting.TimeOfDay = "14:00:00"
    lighting.Brightness = 1
    lighting.Ambient = Color3.fromRGB(0, 0, 0)
    lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    
    for _, effect in pairs(lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
           effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or
           effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = true
        end
    end
end
local InfiniteJumpEnabled = false
local InfiniteJumpConnection = nil
local function EnableInfiniteJump()
    if InfiniteJumpConnection then return end
    InfiniteJumpEnabled = true
    InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then return end
        local state = humanoid:GetState()
        local inAir = not (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or 
                          state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Seated)
        if InfiniteJumpEnabled and inAir then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Y < 53 then 
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 53, vel.Z) end) 
            end
        end
    end)
    table.insert(_G.ICEHUB_Connections, InfiniteJumpConnection)
end
local function DisableInfiniteJump()
    InfiniteJumpEnabled = false
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
end
local UnwalkAnimationEnabled = false
local function EnableUnwalkAnimation()
    if UnwalkAnimationEnabled then return end
    UnwalkAnimationEnabled = true
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    local conn = humanoid.AnimationPlayed:Connect(function(track)
        if UnwalkAnimationEnabled then track:Stop() end
    end)
    table.insert(_G.ICEHUB_Connections, conn)
end
local function DisableUnwalkAnimation()
    UnwalkAnimationEnabled = false
end
local AutoBatEnabled = false
local AutoBatLoopRunning = false
local AimbotEnabled = false
local AimbotConnection = nil
local AlignOri = nil
local Attach0 = nil
local function equipBat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local bat = LocalPlayer.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
    if bat and bat.Parent == LocalPlayer.Backpack then
        hum:EquipTool(bat)
    end
    return bat
end
local function getClosestTarget()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    local closest = nil
    local shortestDistance = 40
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = plr.Character.HumanoidRootPart
            local dist = (targetHrp.Position - hrp.Position).Magnitude
            if dist <= shortestDistance then
                shortestDistance = dist
                closest = targetHrp
            end
        end
    end
    return closest
end
local function startBodyAimbot()
    if AimbotConnection then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.AutoRotate = false end
    
    Attach0 = Instance.new("Attachment", hrp)
    AlignOri = Instance.new("AlignOrientation")
    AlignOri.Attachment0 = Attach0
    AlignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
    AlignOri.RigidityEnabled = true
    AlignOri.MaxTorque = math.huge
    AlignOri.Responsiveness = 200
    AlignOri.Parent = hrp
    
    AimbotConnection = RunService.RenderStepped:Connect(function()
        local target = getClosestTarget()
        if not target then return end
        local dist = (target.Position - hrp.Position).Magnitude
        if dist > 45 then return end
        local lookPos = Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z)
        AlignOri.CFrame = CFrame.lookAt(hrp.Position, lookPos)
    end)
    table.insert(_G.ICEHUB_Connections, AimbotConnection)
end
local function stopBodyAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    if AlignOri then AlignOri:Destroy() AlignOri = nil end
    if Attach0 then Attach0:Destroy() Attach0 = nil end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.AutoRotate = true end
    end
end
local function EnableAutoBat()
    if AutoBatEnabled then return end
    AutoBatEnabled = true
    task.spawn(function()
        AutoBatLoopRunning = true
        while AutoBatEnabled do
            local bat = equipBat()
            if bat then pcall(function() bat:Activate() end) end
            task.wait(0.15)
        end
        AutoBatLoopRunning = false
    end)
end
local function DisableAutoBat()
    AutoBatEnabled = false
end

local PaintballEnabled = false
local PaintballConnection = nil
local lastShot = 0
local fireDelay = 0.0
local function equipPaintballGun()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local gun = backpack and backpack:FindFirstChild("Paintball Gun")
    if hum and gun and gun.Parent ~= char then
        hum:EquipTool(gun)
    end
end
local function autoShoot()
    local char = LocalPlayer.Character
    if not char then return end
    local gun = char:FindFirstChild("Paintball Gun")
    if not gun then return end
    if tick() - lastShot < fireDelay then return end
    lastShot = tick()
    gun:Activate()
end
local function EnablePaintballSpammer()
    if PaintballConnection then return end
    PaintballEnabled = true
    PaintballConnection = RunService.Heartbeat:Connect(function()
        equipPaintballGun()
        autoShoot()
    end)
    table.insert(_G.ICEHUB_Connections, PaintballConnection)
end
local function DisablePaintballSpammer()
    PaintballEnabled = false
    if PaintballConnection then
        PaintballConnection:Disconnect()
        PaintballConnection = nil
    end
end

local AntiTrapEnabled = false
local BARRIER_OFFSET = 3
local processedTraps = {}
local function isTrapPlaced(trapModel)
    local primaryPart = trapModel.PrimaryPart or trapModel:FindFirstChildWhichIsA("BasePart")
    if primaryPart and primaryPart.Anchored then
        return true
    end
    
    for _, part in pairs(trapModel:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored then
            return true
        end
    end
    
    local parent = trapModel.Parent
    if parent == workspace then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local distance = (trapModel:GetPivot().Position - player.Character:GetPivot().Position).Magnitude
                if distance < 10 then
                    return false
                end
            end
        end
        return true
    end
    
    return false
end
local function createTrapBarrier(trapModel)
    if processedTraps[trapModel] then return end
    
    task.wait(0.5)
    
    if not isTrapPlaced(trapModel) then return end
    
    processedTraps[trapModel] = true
    
    local primaryPart = trapModel.PrimaryPart or trapModel:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return end
    
    local cf, size = trapModel:GetBoundingBox()
    
    local barrier = Instance.new("Part")
    barrier.Name = "TrapBarrier"
    barrier.Size = size + Vector3.new(BARRIER_OFFSET * 2, size.Y, BARRIER_OFFSET * 2)
    barrier.CFrame = cf
    barrier.Anchored = true
    barrier.CanCollide = true
    barrier.Transparency = 0.8
    barrier.Material = Enum.Material.ForceField
    barrier.Color = Color3.fromRGB(0, 255, 0)
    barrier.Parent = workspace
    barrier.CanQuery = false
    barrier.CanTouch = false
    
    local outline = Instance.new("SelectionBox")
    outline.Adornee = barrier
    outline.LineThickness = 0.1
    outline.Color3 = Color3.fromRGB(0, 255, 0)
    outline.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
    outline.SurfaceTransparency = 0.8
    outline.Transparency = 0
    outline.Parent = barrier
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = barrier
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.9
    highlight.OutlineTransparency = 0.3
    highlight.Parent = barrier
    
    for _, part in pairs(trapModel:GetDescendants()) do
        if part:IsA("BasePart") and part ~= barrier then
            part.CanCollide = false
            part.CanTouch = false
            part.Transparency = 1
        end
        if part:IsA("TouchTransmitter") then
            part:Destroy()
        end
        if part:IsA("Script") or part:IsA("LocalScript") then
            part:Destroy()
        end
    end
    
    trapModel.AncestryChanged:Connect(function(_, parent)
        if not parent then
            processedTraps[trapModel] = nil
            if barrier and barrier.Parent then
                barrier:Destroy()
            end
        end
    end)
end
local function findTraps(parent)
    for _, obj in pairs(parent:GetChildren()) do
        if obj:IsA("Model") and (obj.Name == "Trap" or obj.Name:lower():find("trap")) then
            if isTrapPlaced(obj) then
                createTrapBarrier(obj)
            end
        end
    end
end
local antiTrapConnection1 = nil
local antiTrapConnection2 = nil
local function EnableAntiTrap()
    if AntiTrapEnabled then return end
    AntiTrapEnabled = true
    
    task.spawn(function()
        task.wait(2)
        findTraps(workspace)
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name == "Trap" or obj.Name:lower():find("trap")) then
                if isTrapPlaced(obj) then
                    createTrapBarrier(obj)
                end
            end
        end
    end)
    
    antiTrapConnection1 = workspace.DescendantAdded:Connect(function(obj)
        if not AntiTrapEnabled then return end
        if obj:IsA("Model") and (obj.Name == "Trap" or obj.Name:lower():find("trap")) then
            task.spawn(function()
                task.wait(0.5)
                if obj.Parent and isTrapPlaced(obj) then
                    createTrapBarrier(obj)
                end
            end)
        end
    end)
    
    antiTrapConnection2 = workspace.ChildAdded:Connect(function(obj)
        if not AntiTrapEnabled then return end
        if obj:IsA("Model") and (obj.Name == "Trap" or obj.Name:lower():find("trap")) then
            task.spawn(function()
                task.wait(0.5)
                if obj.Parent and isTrapPlaced(obj) then
                    createTrapBarrier(obj)
                end
            end)
        end
    end)
    
    table.insert(_G.ICEHUB_Connections, antiTrapConnection1)
    table.insert(_G.ICEHUB_Connections, antiTrapConnection2)
end
local function DisableAntiTrap()
    AntiTrapEnabled = false
    if antiTrapConnection1 then antiTrapConnection1:Disconnect() end
    if antiTrapConnection2 then antiTrapConnection2:Disconnect() end
    
    for trapModel, _ in pairs(processedTraps) do
        local barrier = workspace:FindFirstChild("TrapBarrier")
        if barrier then barrier:Destroy() end
    end
    processedTraps = {}
end

local AntiSentryEnabled = false
local resizedBat = nil
local function getBat()
    if resizedBat and resizedBat.Parent then
        return resizedBat
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower() == "bat" then
                if tool:FindFirstChild("Handle") then
                    tool.Handle.Size = Vector3.new(1000, 1000, 1000)
                    resizedBat = tool
                    return tool
                end
            end
        end
    end
    
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower() == "bat" then
                if tool:FindFirstChild("Handle") then
                    tool.Handle.Size = Vector3.new(1000, 1000, 1000)
                    resizedBat = tool
                    return tool
                end
            end
        end
    end
    return nil
end
local function attackSentry(sentry)
    task.wait(4)
    while sentry.Parent and AntiSentryEnabled do
        local bat = getBat()
        if bat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.Health > 0 then
                LocalPlayer.Character.Humanoid:EquipTool(bat)
            end
            bat:Activate()
        end
        task.wait(0.1)
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:UnequipTools()
    end
end
local function EnableAntiSentry()
    if AntiSentryEnabled then return end
    AntiSentryEnabled = true
    
    task.spawn(function()
        while AntiSentryEnabled do
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:sub(1, 6):lower() == "sentry" then
                    if not obj.Name:find(tostring(LocalPlayer.UserId)) then
                        task.spawn(function()
                            attackSentry(obj)
                        end)
                    end
                end
            end
            task.wait(1)
        end
    end)
end
local function DisableAntiSentry()
    AntiSentryEnabled = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:UnequipTools()
    end
end
local HitboxConnection = nil
local function EnableCombinedHitbox()
    local function updateHitboxes()
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= LocalPlayer then
                local character = targetPlayer.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                        hrp.Transparency = 0.5
                        hrp.Color = Theme.Primary
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    end
                end
            end
        end
    end
    HitboxConnection = RunService.Heartbeat:Connect(updateHitboxes)
    updateHitboxes()
end
local function DisableCombinedHitbox()
    if HitboxConnection then
        HitboxConnection:Disconnect()
        HitboxConnection = nil
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= LocalPlayer then
                local character = targetPlayer.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                        hrp.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    end
end
local SpinBotConnection = nil
local function EnableSpinBot()
    local function addSpin(character)
        local hrp = character:WaitForChild("HumanoidRootPart")
        if hrp:FindFirstChild("ICEHUB_Spin") then return end
        local bav = Instance.new("BodyAngularVelocity")
        bav.Name = "ICEHUB_Spin"
        bav.AngularVelocity = Vector3.new(0, Config.SpinSpeed, 0)
        bav.MaxTorque = Vector3.new(0, 1e7, 0)
        bav.P = 1250
        bav.Parent = hrp
    end
    if LocalPlayer.Character then addSpin(LocalPlayer.Character) end
    SpinBotConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        addSpin(char)
    end)
end
local function DisableSpinBot()
    if SpinBotConnection then
        SpinBotConnection:Disconnect()
        SpinBotConnection = nil
    end
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("ICEHUB_Spin") then
            hrp.ICEHUB_Spin:Destroy()
        end
    end
end
local function CreateESP(player)
    if player == LocalPlayer then return end
    local function AddESP(char)
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ICEHUB_ESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Theme.Primary
        highlight.OutlineColor = Theme.Primary
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.Parent = char
        table.insert(_G.ICEHUB_ESP, highlight)
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ICEHUB_ESP_Text"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "discord.gg/icehub"
        textLabel.TextColor3 = Theme.Primary
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.Parent = billboard
        
        table.insert(_G.ICEHUB_ESP, billboard)
    end
    if player.Character then AddESP(player.Character) end
    player.CharacterAdded:Connect(function(char)
        if Config.Esp then AddESP(char) end
    end)
end
local function UpdateESP()
    for _, v in pairs(_G.ICEHUB_ESP) do pcall(function() v:Destroy() end) end
    _G.ICEHUB_ESP = {}
    if Config.Esp then
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
    end
end

local ParentTarget = gethui and gethui() or CoreGui
pcall(function()
    if not ParentTarget then ParentTarget = LocalPlayer:WaitForChild("PlayerGui") end
end)
if not ParentTarget then ParentTarget = LocalPlayer.PlayerGui end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IceHub_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = ParentTarget end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end
_G.ICEHUB_GUI = ScreenGui

local DingSound = Instance.new("Sound", ScreenGui)
DingSound.SoundId = "rbxassetid://3398620867"
DingSound.Volume = 0.5
DingSound:Play()
game:GetService("Debris"):AddItem(DingSound, 2)

local function AddShadow(frame)
    local shadow = Instance.new("ImageLabel", frame)
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = frame.ZIndex - 1
    return shadow
end

local SelectorFrame = Instance.new("Frame", ScreenGui)
SelectorFrame.Name = "GameModeSelector"
SelectorFrame.Size = UDim2.new(0, 420, 0, 220)
SelectorFrame.Position = UDim2.new(0.5, -210, 0.4, -110)
SelectorFrame.BackgroundColor3 = Theme.Background
SelectorFrame.BorderSizePixel = 0
SelectorFrame.Visible = true
SelectorFrame.ZIndex = 2
SelectorFrame.BackgroundTransparency = 1
local SelectorCorner = Instance.new("UICorner", SelectorFrame)
SelectorCorner.CornerRadius = UDim.new(0, 12)
AddShadow(SelectorFrame)

TweenService:Create(SelectorFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -210, 0.4, -110)
}):Play()
local SelectorTitle = Instance.new("TextLabel", SelectorFrame)
SelectorTitle.Size = UDim2.new(1, 0, 0, 60)
SelectorTitle.Position = UDim2.new(0, 0, 0, 20)
SelectorTitle.BackgroundTransparency = 1
SelectorTitle.Text = "Select Game Mode"
SelectorTitle.TextColor3 = Theme.Text
SelectorTitle.Font = Enum.Font.GothamMedium
SelectorTitle.TextSize = 18
SelectorTitle.TextTransparency = 1
TweenService:Create(SelectorTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    TextTransparency = 0
}):Play()
local ButtonsContainer = Instance.new("Frame", SelectorFrame)
ButtonsContainer.Size = UDim2.new(1, -60, 0, 100)
ButtonsContainer.Position = UDim2.new(0, 30, 0, 100)
ButtonsContainer.BackgroundTransparency = 1
local ButtonsLayout = Instance.new("UIListLayout", ButtonsContainer)
ButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonsLayout.Padding = UDim.new(0, 20)
local BatMedusaBtn = Instance.new("TextButton", ButtonsContainer)
BatMedusaBtn.Size = UDim2.new(0, 170, 0, 90)
BatMedusaBtn.BackgroundColor3 = Theme.Surface
BatMedusaBtn.Text = ""
BatMedusaBtn.AutoButtonColor = false
BatMedusaBtn.BackgroundTransparency = 1
local BatMedusaCorner = Instance.new("UICorner", BatMedusaBtn)
BatMedusaCorner.CornerRadius = UDim.new(0, 10)
local BatMedusaStroke = Instance.new("UIStroke", BatMedusaBtn)
BatMedusaStroke.Color = Theme.Primary
BatMedusaStroke.Thickness = 2
BatMedusaStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BatMedusaStroke.Transparency = 1
local BatMedusaLabel = Instance.new("TextLabel", BatMedusaBtn)
BatMedusaLabel.Size = UDim2.new(1, 0, 1, 0)
BatMedusaLabel.BackgroundTransparency = 1
BatMedusaLabel.Text = "Bat and Medusa"
BatMedusaLabel.TextColor3 = Theme.Text
BatMedusaLabel.Font = Enum.Font.GothamBold
BatMedusaLabel.TextSize = 14
BatMedusaLabel.TextTransparency = 1
local AllGearsBtn = Instance.new("TextButton", ButtonsContainer)
AllGearsBtn.Size = UDim2.new(0, 170, 0, 90)
AllGearsBtn.BackgroundColor3 = Theme.Surface
AllGearsBtn.Text = ""
AllGearsBtn.AutoButtonColor = false
AllGearsBtn.BackgroundTransparency = 1
local AllGearsCorner = Instance.new("UICorner", AllGearsBtn)
AllGearsCorner.CornerRadius = UDim.new(0, 10)
local AllGearsStroke = Instance.new("UIStroke", AllGearsBtn)
AllGearsStroke.Color = Theme.Secondary
AllGearsStroke.Thickness = 2
AllGearsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
AllGearsStroke.Transparency = 1
local AllGearsLabel = Instance.new("TextLabel", AllGearsBtn)
AllGearsLabel.Size = UDim2.new(1, 0, 1, 0)
AllGearsLabel.BackgroundTransparency = 1
AllGearsLabel.Text = "All Gears"
AllGearsLabel.TextColor3 = Theme.Text
AllGearsLabel.Font = Enum.Font.GothamBold
AllGearsLabel.TextSize = 14
AllGearsLabel.TextTransparency = 1
task.wait(0.3)
TweenService:Create(BatMedusaBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
TweenService:Create(BatMedusaStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
TweenService:Create(BatMedusaLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
task.wait(0.1)
TweenService:Create(AllGearsBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
TweenService:Create(AllGearsStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
TweenService:Create(AllGearsLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
BatMedusaBtn.MouseEnter:Connect(function()
    TweenService:Create(BatMedusaBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Elevated}):Play()
end)
BatMedusaBtn.MouseLeave:Connect(function()
    TweenService:Create(BatMedusaBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface}):Play()
end)
AllGearsBtn.MouseEnter:Connect(function()
    TweenService:Create(AllGearsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Elevated}):Play()
end)
AllGearsBtn.MouseLeave:Connect(function()
    TweenService:Create(AllGearsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface}):Play()
end)

local function CreateMainHub(gameMode)
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainHub_" .. gameMode
    MainFrame.Size = UDim2.new(0, 580, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -290, 0.35, -210)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 2
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)
    AddShadow(MainFrame)
    
    local LeftFlicker = Instance.new("Frame", MainFrame)
    LeftFlicker.Size = UDim2.new(0, 2, 1, -24)
    LeftFlicker.Position = UDim2.new(0, 0, 0, 12)
    LeftFlicker.BackgroundColor3 = Theme.Primary
    LeftFlicker.BorderSizePixel = 0
    LeftFlicker.ZIndex = 3
    LeftFlicker.BackgroundTransparency = 0.3
    
    local RightFlicker = Instance.new("Frame", MainFrame)
    RightFlicker.Size = UDim2.new(0, 2, 1, -24)
    RightFlicker.Position = UDim2.new(1, -2, 0, 12)
    RightFlicker.BackgroundColor3 = Theme.Primary
    RightFlicker.BorderSizePixel = 0
    RightFlicker.ZIndex = 3
    RightFlicker.BackgroundTransparency = 0.3
    
    task.spawn(function()
        while MainFrame and MainFrame.Parent do
            TweenService:Create(LeftFlicker, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.1}):Play()
            TweenService:Create(RightFlicker, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.1}):Play()
            task.wait(1.5)
            
            TweenService:Create(LeftFlicker, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(RightFlicker, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5}):Play()
            task.wait(1.5)
        end
    end)
    
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Theme.Surface
    Header.BorderSizePixel = 0
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    local HeaderBottom = Instance.new("Frame", Header)
    HeaderBottom.Size = UDim2.new(1, 0, 0, 12)
    HeaderBottom.Position = UDim2.new(0, 0, 1, -12)
    HeaderBottom.BackgroundColor3 = Theme.Surface
    HeaderBottom.BorderSizePixel = 0
    local StatusDot = Instance.new("Frame", Header)
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    StatusDot.Position = UDim2.new(0, 16, 0.5, -4)
    StatusDot.BackgroundColor3 = Theme.Accent
    StatusDot.BorderSizePixel = 0
    local StatusDotCorner = Instance.new("UICorner", StatusDot)
    StatusDotCorner.CornerRadius = UDim.new(1, 0)
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.Position = UDim2.new(0, 32, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Ice Hub - " .. gameMode
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    local DiscordLink = Instance.new("TextButton", Header)
    DiscordLink.Size = UDim2.new(0, 120, 0, 24)
    DiscordLink.Position = UDim2.new(1, -260, 0.5, -12)
    DiscordLink.BackgroundColor3 = Theme.Primary
    DiscordLink.Text = "discord.gg/icehub"
    DiscordLink.TextColor3 = Theme.Text
    DiscordLink.Font = Enum.Font.Gotham
    DiscordLink.TextSize = 11
    DiscordLink.AutoButtonColor = false
    local DiscordLinkCorner = Instance.new("UICorner", DiscordLink)
    DiscordLinkCorner.CornerRadius = UDim.new(0, 6)
    DiscordLink.MouseButton1Click:Connect(function()
        setclipboard("discord.gg/icehub")
        DiscordLink.Text = "Copied!"
        task.wait(1)
        DiscordLink.Text = "discord.gg/icehub"
    end)
    DiscordLink.MouseEnter:Connect(function()
        TweenService:Create(DiscordLink, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
    end)
    DiscordLink.MouseLeave:Connect(function()
        TweenService:Create(DiscordLink, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
    end)
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "Ãƒâ€”"
    CloseBtn.TextColor3 = Theme.TextSecondary
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.TextColor3 = Theme.Text
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.TextColor3 = Theme.TextSecondary
    end)
    local Content = Instance.new("Frame", MainFrame)
    Content.Size = UDim2.new(1, 0, 1, -40)
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.BackgroundTransparency = 1
    local LeftColumn = Instance.new("Frame", Content)
    LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
    LeftColumn.Position = UDim2.new(0, 0, 0, 0)
    LeftColumn.BackgroundTransparency = 1
    local Divider = Instance.new("Frame", Content)
    Divider.Size = UDim2.new(0, 1, 1, -24)
    Divider.Position = UDim2.new(0.5, 0, 0, 12)
    Divider.BackgroundColor3 = Theme.Divider
    Divider.BorderSizePixel = 0
    local RightColumn = Instance.new("Frame", Content)
    RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
    RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
    RightColumn.BackgroundTransparency = 1
    local LeftScroll = Instance.new("ScrollingFrame", LeftColumn)
    LeftScroll.Size = UDim2.new(1, 0, 1, 0)
    LeftScroll.BackgroundTransparency = 1
    LeftScroll.BorderSizePixel = 0
    LeftScroll.ScrollBarThickness = 3
    LeftScroll.ScrollBarImageColor3 = Theme.Primary
    LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LeftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local LeftPadding = Instance.new("UIPadding", LeftScroll)
    LeftPadding.PaddingLeft = UDim.new(0, 16)
    LeftPadding.PaddingRight = UDim.new(0, 8)
    LeftPadding.PaddingTop = UDim.new(0, 12)
    LeftPadding.PaddingBottom = UDim.new(0, 12)
    local LeftLayout = Instance.new("UIListLayout", LeftScroll)
    LeftLayout.Padding = UDim.new(0, 4)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local RightScroll = Instance.new("ScrollingFrame", RightColumn)
    RightScroll.Size = UDim2.new(1, 0, 1, 0)
    RightScroll.BackgroundTransparency = 1
    RightScroll.BorderSizePixel = 0
    RightScroll.ScrollBarThickness = 3
    RightScroll.ScrollBarImageColor3 = Theme.Primary
    RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local RightPadding = Instance.new("UIPadding", RightScroll)
    RightPadding.PaddingLeft = UDim.new(0, 8)
    RightPadding.PaddingRight = UDim.new(0, 16)
    RightPadding.PaddingTop = UDim.new(0, 12)
    RightPadding.PaddingBottom = UDim.new(0, 12)
    local RightLayout = Instance.new("UIListLayout", RightScroll)
    RightLayout.Padding = UDim.new(0, 4)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    return MainFrame, LeftScroll, RightScroll
end

_G.ICEHUB_UI = _G.ICEHUB_UI or {}
local listeningBtn = nil
local function CreateSection(parent, title)
    local Section = Instance.new("Frame", parent)
    Section.Size = UDim2.new(1, 0, 0, 32)
    Section.BackgroundTransparency = 1
    
    local SectionLabel = Instance.new("TextLabel", Section)
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = title
    SectionLabel.TextColor3 = Theme.Text
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextSize = 13
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    return Section
end
local function CreateCheckbox(parent, text, configKey)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, 0, 0, 32)
    Container.BackgroundTransparency = 1
    
    local CheckCircle = Instance.new("Frame", Container)
    CheckCircle.Size = UDim2.new(0, 18, 0, 18)
    CheckCircle.Position = UDim2.new(0, 0, 0.5, -9)
    CheckCircle.BackgroundColor3 = Theme.CheckOff
    CheckCircle.BorderSizePixel = 0
    
    local CheckCorner = Instance.new("UICorner", CheckCircle)
    CheckCorner.CornerRadius = UDim.new(1, 0)
    
    local CheckInner = Instance.new("Frame", CheckCircle)
    CheckInner.Name = "Inner"
    CheckInner.Size = UDim2.new(0, 10, 0, 10)
    CheckInner.Position = UDim2.new(0.5, -5, 0.5, -5)
    CheckInner.BackgroundColor3 = Theme.Secondary
    CheckInner.BackgroundTransparency = 1
    CheckInner.BorderSizePixel = 0
    
    local CheckInnerCorner = Instance.new("UICorner", CheckInner)
    CheckInnerCorner.CornerRadius = UDim.new(1, 0)
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -100, 1, 0)
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextSecondary
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local KeybindBtn = Instance.new("TextButton", Container)
    KeybindBtn.Size = UDim2.new(0, 60, 0, 20)
    KeybindBtn.Position = UDim2.new(1, -60, 0.5, -10)
    KeybindBtn.BackgroundColor3 = Theme.SliderBG
    KeybindBtn.Text = "NONE"
    KeybindBtn.TextColor3 = Theme.TextTertiary
    KeybindBtn.Font = Enum.Font.GothamBold
    KeybindBtn.TextSize = 9
    KeybindBtn.AutoButtonColor = false
    
    local KeybindCorner = Instance.new("UICorner", KeybindBtn)
    KeybindCorner.CornerRadius = UDim.new(0, 5)
    
    local Button = Instance.new("TextButton", Container)
    Button.Size = UDim2.new(1, -70, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        if not Config[configKey] then
            TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary}):Play()
        end
    end)
    
    _G.ICEHUB_UI[configKey] = {
        Button = Button,
        CheckCircle = CheckCircle,
        CheckInner = CheckInner,
        Label = Label,
        KeybindBtn = KeybindBtn
    }
    
    return Container
end
local function CreateSlider(parent, text, min, max, configKey, valueKey)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, 0, 0, 52)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(0.65, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextTertiary
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel", Container)
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -50, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Config[valueKey])
    ValueLabel.TextColor3 = Theme.Secondary
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderBG = Instance.new("Frame", Container)
    SliderBG.Size = UDim2.new(1, 0, 0, 5)
    SliderBG.Position = UDim2.new(0, 0, 0, 32)
    SliderBG.BackgroundColor3 = Theme.SliderBG
    SliderBG.BorderSizePixel = 0
    
    local SliderBGCorner = Instance.new("UICorner", SliderBG)
    SliderBGCorner.CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame", SliderBG)
    SliderFill.Size = UDim2.new((Config[valueKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.Secondary
    SliderFill.BorderSizePixel = 0
    
    local SliderFillCorner = Instance.new("UICorner", SliderFill)
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame", SliderBG)
    Knob.Size = UDim2.new(0, 13, 0, 13)
    Knob.Position = UDim2.new((Config[valueKey] - min) / (max - min), -6.5, 0.5, -6.5)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(1, 0)
    
    local Button = Instance.new("TextButton", SliderBG)
    Button.Size = UDim2.new(1, 20, 1, 20)
    Button.Position = UDim2.new(0, -10, 0, -10)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    
    local dragging = false
    
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        Config[valueKey] = value
        ValueLabel.Text = tostring(value)
        TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.new(pos, -6.5, 0.5, -6.5)}):Play()
    end
    
    Button.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    table.insert(_G.ICEHUB_Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    
    table.insert(_G.ICEHUB_Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end))
    
    _G.ICEHUB_UI[valueKey.."Value"] = ValueLabel
    
    return Container
end

local AutoBatPopup = Instance.new("Frame", ScreenGui)
AutoBatPopup.Name = "AutoBatPopup"
AutoBatPopup.Size = UDim2.new(0, 280, 0, 200)
AutoBatPopup.Position = UDim2.new(0.5, -140, 0.35, -100)
AutoBatPopup.BackgroundColor3 = Theme.Background
AutoBatPopup.BorderSizePixel = 0
AutoBatPopup.Visible = false
AutoBatPopup.Active = true
AutoBatPopup.Draggable = true
AutoBatPopup.ZIndex = 3
local PopupCorner = Instance.new("UICorner", AutoBatPopup)
PopupCorner.CornerRadius = UDim.new(0, 12)
AddShadow(AutoBatPopup)
local PopupHeader = Instance.new("Frame", AutoBatPopup)
PopupHeader.Size = UDim2.new(1, 0, 0, 40)
PopupHeader.BackgroundColor3 = Theme.Surface
PopupHeader.BorderSizePixel = 0
local PopupHeaderCorner = Instance.new("UICorner", PopupHeader)
PopupHeaderCorner.CornerRadius = UDim.new(0, 12)
local PopupHeaderBottom = Instance.new("Frame", PopupHeader)
PopupHeaderBottom.Size = UDim2.new(1, 0, 0, 12)
PopupHeaderBottom.Position = UDim2.new(0, 0, 1, -12)
PopupHeaderBottom.BackgroundColor3 = Theme.Surface
PopupHeaderBottom.BorderSizePixel = 0
local PopupTitle = Instance.new("TextLabel", PopupHeader)
PopupTitle.Size = UDim2.new(1, -50, 1, 0)
PopupTitle.Position = UDim2.new(0, 16, 0, 0)
PopupTitle.BackgroundTransparency = 1
PopupTitle.Text = "Auto Bat Settings"
PopupTitle.TextColor3 = Theme.Text
PopupTitle.Font = Enum.Font.GothamMedium
PopupTitle.TextSize = 14
PopupTitle.TextXAlignment = Enum.TextXAlignment.Left
local PopupCloseBtn = Instance.new("TextButton", PopupHeader)
PopupCloseBtn.Size = UDim2.new(0, 40, 0, 40)
PopupCloseBtn.Position = UDim2.new(1, -40, 0, 0)
PopupCloseBtn.BackgroundTransparency = 1
PopupCloseBtn.Text = "Ãƒâ€”"
PopupCloseBtn.TextColor3 = Theme.TextSecondary
PopupCloseBtn.Font = Enum.Font.GothamBold
PopupCloseBtn.TextSize = 20
local PopupContent = Instance.new("Frame", AutoBatPopup)
PopupContent.Size = UDim2.new(1, -32, 1, -56)
PopupContent.Position = UDim2.new(0, 16, 0, 48)
PopupContent.BackgroundTransparency = 1
local PopupLayout = Instance.new("UIListLayout", PopupContent)
PopupLayout.Padding = UDim.new(0, 8)
PopupLayout.SortOrder = Enum.SortOrder.LayoutOrder
local PopupAutoBatCheck = Instance.new("Frame", PopupContent)
PopupAutoBatCheck.Size = UDim2.new(1, 0, 0, 32)
PopupAutoBatCheck.BackgroundTransparency = 1
local PopupAutoBatCircle = Instance.new("Frame", PopupAutoBatCheck)
PopupAutoBatCircle.Size = UDim2.new(0, 18, 0, 18)
PopupAutoBatCircle.Position = UDim2.new(0, 0, 0.5, -9)
PopupAutoBatCircle.BackgroundColor3 = Theme.CheckOff
PopupAutoBatCircle.BorderSizePixel = 0
local PopupAutoBatCircleCorner = Instance.new("UICorner", PopupAutoBatCircle)
PopupAutoBatCircleCorner.CornerRadius = UDim.new(1, 0)
local PopupAutoBatInner = Instance.new("Frame", PopupAutoBatCircle)
PopupAutoBatInner.Size = UDim2.new(0, 10, 0, 10)
PopupAutoBatInner.Position = UDim2.new(0.5, -5, 0.5, -5)
PopupAutoBatInner.BackgroundColor3 = Theme.Secondary
PopupAutoBatInner.BackgroundTransparency = 1
PopupAutoBatInner.BorderSizePixel = 0
local PopupAutoBatInnerCorner = Instance.new("UICorner", PopupAutoBatInner)
PopupAutoBatInnerCorner.CornerRadius = UDim.new(1, 0)
local PopupAutoBatLabel = Instance.new("TextLabel", PopupAutoBatCheck)
PopupAutoBatLabel.Size = UDim2.new(1, -28, 1, 0)
PopupAutoBatLabel.Position = UDim2.new(0, 28, 0, 0)
PopupAutoBatLabel.BackgroundTransparency = 1
PopupAutoBatLabel.Text = "Enable Auto Bat"
PopupAutoBatLabel.TextColor3 = Theme.TextSecondary
PopupAutoBatLabel.Font = Enum.Font.Gotham
PopupAutoBatLabel.TextSize = 13
PopupAutoBatLabel.TextXAlignment = Enum.TextXAlignment.Left
local PopupAutoBatBtn = Instance.new("TextButton", PopupAutoBatCheck)
PopupAutoBatBtn.Size = UDim2.new(1, 0, 1, 0)
PopupAutoBatBtn.BackgroundTransparency = 1
PopupAutoBatBtn.Text = ""
local PopupAimbotCheck = Instance.new("Frame", PopupContent)
PopupAimbotCheck.Size = UDim2.new(1, 0, 0, 32)
PopupAimbotCheck.BackgroundTransparency = 1
local PopupAimbotCircle = Instance.new("Frame", PopupAimbotCheck)
PopupAimbotCircle.Size = UDim2.new(0, 18, 0, 18)
PopupAimbotCircle.Position = UDim2.new(0, 0, 0.5, -9)
PopupAimbotCircle.BackgroundColor3 = Theme.CheckOff
PopupAimbotCircle.BorderSizePixel = 0
local PopupAimbotCircleCorner = Instance.new("UICorner", PopupAimbotCircle)
PopupAimbotCircleCorner.CornerRadius = UDim.new(1, 0)
local PopupAimbotInner = Instance.new("Frame", PopupAimbotCircle)
PopupAimbotInner.Size = UDim2.new(0, 10, 0, 10)
PopupAimbotInner.Position = UDim2.new(0.5, -5, 0.5, -5)
PopupAimbotInner.BackgroundColor3 = Theme.Secondary
PopupAimbotInner.BackgroundTransparency = 1
PopupAimbotInner.BorderSizePixel = 0
local PopupAimbotInnerCorner = Instance.new("UICorner", PopupAimbotInner)
PopupAimbotInnerCorner.CornerRadius = UDim.new(1, 0)
local PopupAimbotLabel = Instance.new("TextLabel", PopupAimbotCheck)
PopupAimbotLabel.Size = UDim2.new(1, -28, 1, 0)
PopupAimbotLabel.Position = UDim2.new(0, 28, 0, 0)
PopupAimbotLabel.BackgroundTransparency = 1
PopupAimbotLabel.Text = "Enable Aimbot"
PopupAimbotLabel.TextColor3 = Theme.TextSecondary
PopupAimbotLabel.Font = Enum.Font.Gotham
PopupAimbotLabel.TextSize = 13
PopupAimbotLabel.TextXAlignment = Enum.TextXAlignment.Left
local PopupAimbotBtn = Instance.new("TextButton", PopupAimbotCheck)
PopupAimbotBtn.Size = UDim2.new(1, 0, 1, 0)
PopupAimbotBtn.BackgroundTransparency = 1
PopupAimbotBtn.Text = ""
local PopupInfo = Instance.new("TextLabel", PopupContent)
PopupInfo.Size = UDim2.new(1, 0, 0, 50)
PopupInfo.BackgroundTransparency = 1
PopupInfo.Text = "Hotkeys:\nR - Toggle Auto Bat\nT - Toggle Aimbot"
PopupInfo.TextColor3 = Theme.TextTertiary
PopupInfo.Font = Enum.Font.Gotham
PopupInfo.TextSize = 11
PopupInfo.TextXAlignment = Enum.TextXAlignment.Left
PopupInfo.TextYAlignment = Enum.TextYAlignment.Top
PopupCloseBtn.MouseButton1Click:Connect(function()
    AutoBatPopup.Visible = false
end)
PopupAutoBatBtn.MouseButton1Click:Connect(function()
    AutoBatEnabled = not AutoBatEnabled
    if AutoBatEnabled then
        TweenService:Create(PopupAutoBatInner, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(PopupAutoBatLabel, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        EnableAutoBat()
    else
        TweenService:Create(PopupAutoBatInner, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(PopupAutoBatLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
        DisableAutoBat()
    end
end)
PopupAimbotBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        TweenService:Create(PopupAimbotInner, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(PopupAimbotLabel, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        startBodyAimbot()
    else
        TweenService:Create(PopupAimbotInner, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(PopupAimbotLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
        stopBodyAimbot()
    end
end)
table.insert(_G.ICEHUB_Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not AutoBatPopup.Visible then return end
    if input.KeyCode == Enum.KeyCode.R then
        AutoBatEnabled = not AutoBatEnabled
        if AutoBatEnabled then
            TweenService:Create(PopupAutoBatInner, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(PopupAutoBatLabel, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            EnableAutoBat()
        else
            TweenService:Create(PopupAutoBatInner, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(PopupAutoBatLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
            DisableAutoBat()
        end
    elseif input.KeyCode == Enum.KeyCode.T then
        AimbotEnabled = not AimbotEnabled
        if AimbotEnabled then
            TweenService:Create(PopupAimbotInner, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(PopupAimbotLabel, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            startBodyAimbot()
        else
            TweenService:Create(PopupAimbotInner, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(PopupAimbotLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
            stopBodyAimbot()
        end
    end
end))

local function UpdateAll()
    local features = {"SpeedBoost", "WalkSpeed", "HighJump", "InfiniteJump", "AntiRagdoll", "SpinBot", "Performance", "Esp", "Hitbox", "UnwalkAnimation", "AutoBat", "PaintballSpammer", "AntiTrap", "AntiSentry"}
    for _, feature in ipairs(features) do
        local ui = _G.ICEHUB_UI[feature]
        if ui then
            local active = Config[feature]
            TweenService:Create(ui.CheckInner, TweenInfo.new(0.2), {BackgroundTransparency = active and 0 or 1}):Play()
            TweenService:Create(ui.Label, TweenInfo.new(0.2), {TextColor3 = active and Theme.Text or Theme.TextSecondary}):Play()
            
            if Config.Keybinds[feature] then
                ui.KeybindBtn.Text = Config.Keybinds[feature].Name
                ui.KeybindBtn.TextColor3 = Theme.Secondary
            end
        end
    end
end

local function Toggle(feature)
    if feature == "SpeedBoost" then
        Config.SpeedBoost = not Config.SpeedBoost
        if Config.SpeedBoost then Config.WalkSpeed = false end
    elseif feature == "WalkSpeed" then
        Config.WalkSpeed = not Config.WalkSpeed
        if Config.WalkSpeed then Config.SpeedBoost = false end
    elseif feature == "HighJump" then
        Config.HighJump = not Config.HighJump
        if Config.HighJump then EnableHighJump() else DisableHighJump() end
    elseif feature == "AntiRagdoll" then
        Config.AntiRagdoll = not Config.AntiRagdoll
        if Config.AntiRagdoll then EnableAntiRagdoll() else DisableAntiRagdoll() end
    elseif feature == "SpinBot" then
        Config.SpinBot = not Config.SpinBot
        if Config.SpinBot then EnableSpinBot() else DisableSpinBot() end
    elseif feature == "Esp" then
        Config.Esp = not Config.Esp
        UpdateESP()
    elseif feature == "Hitbox" then
        Config.Hitbox = not Config.Hitbox
        if Config.Hitbox then EnableCombinedHitbox() else DisableCombinedHitbox() end
    elseif feature == "Performance" then
        Config.Performance = not Config.Performance
        if Config.Performance then EnablePerformance() else DisablePerformance() end
    elseif feature == "InfiniteJump" then
        Config.InfiniteJump = not Config.InfiniteJump
        if Config.InfiniteJump then EnableInfiniteJump() else DisableInfiniteJump() end
    elseif feature == "UnwalkAnimation" then
        Config.UnwalkAnimation = not Config.UnwalkAnimation
        if Config.UnwalkAnimation then EnableUnwalkAnimation() else DisableUnwalkAnimation() end
    elseif feature == "AutoBat" then
        AutoBatPopup.Visible = not AutoBatPopup.Visible
        return
    elseif feature == "PaintballSpammer" then
        Config.PaintballSpammer = not Config.PaintballSpammer
        if Config.PaintballSpammer then EnablePaintballSpammer() else DisablePaintballSpammer() end
    elseif feature == "AntiTrap" then
        Config.AntiTrap = not Config.AntiTrap
        if Config.AntiTrap then EnableAntiTrap() else DisableAntiTrap() end
    elseif feature == "AntiSentry" then
        Config.AntiSentry = not Config.AntiSentry
        if Config.AntiSentry then EnableAntiSentry() else DisableAntiSentry() end
    end
    UpdateAll()
    SaveConfig()
end

local function SetupKeybind(btn, keyName)
    btn.MouseButton1Click:Connect(function()
        if listeningBtn then
            local oldKey = Config.Keybinds[listeningBtn.Key]
            listeningBtn.Btn.Text = oldKey and oldKey.Name or "NONE"
            listeningBtn.Btn.TextColor3 = Theme.TextTertiary
        end
        
        btn.Text = "..."
        btn.TextColor3 = Theme.Secondary
        listeningBtn = {Btn = btn, Key = keyName}
        
        TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {
            Size = UDim2.new(0, 65, 0, 22)
        }):Play()
    end)
end
table.insert(_G.ICEHUB_Connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if listeningBtn and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.Keybinds[listeningBtn.Key] = input.KeyCode
        listeningBtn.Btn.Text = input.KeyCode.Name
        listeningBtn.Btn.TextColor3 = Theme.Secondary
        
        TweenService:Create(listeningBtn.Btn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 60, 0, 20)
        }):Play()
        
        listeningBtn = nil
        SaveConfig()
        return
    end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if Config.Keybinds.SpeedBoost and input.KeyCode == Config.Keybinds.SpeedBoost then Toggle("SpeedBoost") end
        if Config.Keybinds.WalkSpeed and input.KeyCode == Config.Keybinds.WalkSpeed then Toggle("WalkSpeed") end
        if Config.Keybinds.HighJump and input.KeyCode == Config.Keybinds.HighJump then Toggle("HighJump") end
        if Config.Keybinds.InfiniteJump and input.KeyCode == Config.Keybinds.InfiniteJump then Toggle("InfiniteJump") end
        if Config.Keybinds.Esp and input.KeyCode == Config.Keybinds.Esp then Toggle("Esp") end
        if Config.Keybinds.AntiRagdoll and input.KeyCode == Config.Keybinds.AntiRagdoll then Toggle("AntiRagdoll") end
        if Config.Keybinds.Hitbox and input.KeyCode == Config.Keybinds.Hitbox then Toggle("Hitbox") end
        if Config.Keybinds.SpinBot and input.KeyCode == Config.Keybinds.SpinBot then Toggle("SpinBot") end
        if Config.Keybinds.Performance and input.KeyCode == Config.Keybinds.Performance then Toggle("Performance") end
        if Config.Keybinds.UnwalkAnimation and input.KeyCode == Config.Keybinds.UnwalkAnimation then Toggle("UnwalkAnimation") end
        if Config.Keybinds.AutoBat and input.KeyCode == Config.Keybinds.AutoBat then Toggle("AutoBat") end
        if Config.Keybinds.PaintballSpammer and input.KeyCode == Config.Keybinds.PaintballSpammer then Toggle("PaintballSpammer") end
        if Config.Keybinds.AntiTrap and input.KeyCode == Config.Keybinds.AntiTrap then Toggle("AntiTrap") end
        if Config.Keybinds.AntiSentry and input.KeyCode == Config.Keybinds.AntiSentry then Toggle("AntiSentry") end
    end
end))

table.insert(_G.ICEHUB_Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if (Config.SpeedBoost or Config.WalkSpeed) and hum.MoveDirection.Magnitude > 0.1 then
        local speed = Config.SpeedBoost and Config.SpeedValue or Config.WalkValue
        root.Velocity = Vector3.new(hum.MoveDirection.X * speed, root.Velocity.Y, hum.MoveDirection.Z * speed)
    end
end))

table.insert(_G.ICEHUB_Connections, Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end))

BatMedusaBtn.MouseButton1Click:Connect(function()
    TweenService:Create(SelectorFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -210, -0.5, 0)
    }):Play()
    task.wait(0.3)
    SelectorFrame.Visible = false
    
    local MainFrame, LeftScroll, RightScroll = CreateMainHub("Duels")
    
    CreateSection(LeftScroll, "Movement")
    CreateCheckbox(LeftScroll, "Speed Boost", "SpeedBoost")
    CreateSlider(LeftScroll, "Speed Value", 1, 100, "SpeedBoost", "SpeedValue")
    
    CreateCheckbox(LeftScroll, "Walk Speed", "WalkSpeed")
    CreateSlider(LeftScroll, "Walk Value", 1, 100, "WalkSpeed", "WalkValue")
    
    CreateCheckbox(LeftScroll, "High Jump", "HighJump")
    CreateSlider(LeftScroll, "Jump Power", 1, 100, "HighJump", "JumpPower")
    
    CreateCheckbox(LeftScroll, "Infinite Jump", "InfiniteJump")
    
    CreateSection(LeftScroll, "Protection")
    CreateCheckbox(LeftScroll, "Anti Ragdoll", "AntiRagdoll")
    CreateCheckbox(LeftScroll, "Anti Trap", "AntiTrap")
    CreateCheckbox(LeftScroll, "Anti Sentry", "AntiSentry")
    
    CreateSection(LeftScroll, "Miscellaneous")
    CreateCheckbox(LeftScroll, "Unwalk Animation", "UnwalkAnimation")
    CreateCheckbox(LeftScroll, "Performance Mode", "Performance")
    
    CreateSection(RightScroll, "Combat")
    CreateCheckbox(RightScroll, "Auto Bat", "AutoBat")
    CreateCheckbox(RightScroll, "Hitbox Expander", "Hitbox")
    CreateSlider(RightScroll, "Hitbox Size", 5, 50, "Hitbox", "HitboxSize")
    
    CreateCheckbox(RightScroll, "Spin Bot", "SpinBot")
    CreateSlider(RightScroll, "Spin Speed", 1, 100, "SpinBot", "SpinSpeed")
    
    CreateSection(RightScroll, "Visuals")
    CreateCheckbox(RightScroll, "Discord Display", "Esp")
    
    _G.ICEHUB_UI.SpeedBoost.Button.MouseButton1Click:Connect(function() Toggle("SpeedBoost") end)
    _G.ICEHUB_UI.WalkSpeed.Button.MouseButton1Click:Connect(function() Toggle("WalkSpeed") end)
    _G.ICEHUB_UI.HighJump.Button.MouseButton1Click:Connect(function() Toggle("HighJump") end)
    _G.ICEHUB_UI.InfiniteJump.Button.MouseButton1Click:Connect(function() Toggle("InfiniteJump") end)
    _G.ICEHUB_UI.AntiRagdoll.Button.MouseButton1Click:Connect(function() Toggle("AntiRagdoll") end)
    _G.ICEHUB_UI.SpinBot.Button.MouseButton1Click:Connect(function() Toggle("SpinBot") end)
    _G.ICEHUB_UI.Performance.Button.MouseButton1Click:Connect(function() Toggle("Performance") end)
    _G.ICEHUB_UI.UnwalkAnimation.Button.MouseButton1Click:Connect(function() Toggle("UnwalkAnimation") end)
    _G.ICEHUB_UI.Esp.Button.MouseButton1Click:Connect(function() Toggle("Esp") end)
    _G.ICEHUB_UI.Hitbox.Button.MouseButton1Click:Connect(function() Toggle("Hitbox") end)
    _G.ICEHUB_UI.AutoBat.Button.MouseButton1Click:Connect(function() Toggle("AutoBat") end)
    _G.ICEHUB_UI.AntiTrap.Button.MouseButton1Click:Connect(function() Toggle("AntiTrap") end)
    _G.ICEHUB_UI.AntiSentry.Button.MouseButton1Click:Connect(function() Toggle("AntiSentry") end)
    
    local features = {"SpeedBoost", "WalkSpeed", "HighJump", "InfiniteJump", "Esp", "AntiRagdoll", "Hitbox", "SpinBot", "Performance", "UnwalkAnimation", "AutoBat", "AntiTrap", "AntiSentry"}
    for _, feature in ipairs(features) do
        local ui = _G.ICEHUB_UI[feature]
        if ui then
            SetupKeybind(ui.KeybindBtn, feature)
        end
    end
    
    MainFrame.Visible = true
    MainFrame.Position = UDim2.new(0.5, -290, -0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -290, 0.35, -210)
    }):Play()
    
    DingSound:Play()
end)
AllGearsBtn.MouseButton1Click:Connect(function()
    TweenService:Create(SelectorFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -210, -0.5, 0)
    }):Play()
    task.wait(0.3)
    SelectorFrame.Visible = false
    
    local MainFrame, LeftScroll, RightScroll = CreateMainHub("All Gears")
    
    CreateSection(LeftScroll, "Movement")
    CreateCheckbox(LeftScroll, "Speed Boost", "SpeedBoost")
    CreateSlider(LeftScroll, "Speed Value", 1, 100, "SpeedBoost", "SpeedValue")
    
    CreateCheckbox(LeftScroll, "Walk Speed", "WalkSpeed")
    CreateSlider(LeftScroll, "Walk Value", 1, 100, "WalkSpeed", "WalkValue")
    
    CreateCheckbox(LeftScroll, "High Jump", "HighJump")
    CreateSlider(LeftScroll, "Jump Power", 1, 100, "HighJump", "JumpPower")
    
    CreateCheckbox(LeftScroll, "Infinite Jump", "InfiniteJump")
    
    CreateSection(LeftScroll, "Protection")
    CreateCheckbox(LeftScroll, "Anti Ragdoll", "AntiRagdoll")
    CreateCheckbox(LeftScroll, "Anti Trap", "AntiTrap")
    CreateCheckbox(LeftScroll, "Anti Sentry", "AntiSentry")
    
    CreateSection(LeftScroll, "Miscellaneous")
    CreateCheckbox(LeftScroll, "Unwalk Animation", "UnwalkAnimation")
    CreateCheckbox(LeftScroll, "Performance Mode", "Performance")
    
    CreateSection(RightScroll, "Combat")
    CreateCheckbox(RightScroll, "Auto Bat", "AutoBat")
    CreateCheckbox(RightScroll, "Paintball Spammer", "PaintballSpammer")
    CreateCheckbox(RightScroll, "Hitbox Expander", "Hitbox")
    CreateSlider(RightScroll, "Hitbox Size", 5, 50, "Hitbox", "HitboxSize")
    
    CreateCheckbox(RightScroll, "Spin Bot", "SpinBot")
    CreateSlider(RightScroll, "Spin Speed", 1, 100, "SpinBot", "SpinSpeed")
    
    CreateSection(RightScroll, "Visuals")
    CreateCheckbox(RightScroll, "Discord Display", "Esp")
    
    _G.ICEHUB_UI.SpeedBoost.Button.MouseButton1Click:Connect(function() Toggle("SpeedBoost") end)
    _G.ICEHUB_UI.WalkSpeed.Button.MouseButton1Click:Connect(function() Toggle("WalkSpeed") end)
    _G.ICEHUB_UI.HighJump.Button.MouseButton1Click:Connect(function() Toggle("HighJump") end)
    _G.ICEHUB_UI.InfiniteJump.Button.MouseButton1Click:Connect(function() Toggle("InfiniteJump") end)
    _G.ICEHUB_UI.AntiRagdoll.Button.MouseButton1Click:Connect(function() Toggle("AntiRagdoll") end)
    _G.ICEHUB_UI.SpinBot.Button.MouseButton1Click:Connect(function() Toggle("SpinBot") end)
    _G.ICEHUB_UI.Performance.Button.MouseButton1Click:Connect(function() Toggle("Performance") end)
    _G.ICEHUB_UI.UnwalkAnimation.Button.MouseButton1Click:Connect(function() Toggle("UnwalkAnimation") end)
    _G.ICEHUB_UI.Esp.Button.MouseButton1Click:Connect(function() Toggle("Esp") end)
    _G.ICEHUB_UI.Hitbox.Button.MouseButton1Click:Connect(function() Toggle("Hitbox") end)
    _G.ICEHUB_UI.AutoBat.Button.MouseButton1Click:Connect(function() Toggle("AutoBat") end)
    _G.ICEHUB_UI.PaintballSpammer.Button.MouseButton1Click:Connect(function() Toggle("PaintballSpammer") end)
    _G.ICEHUB_UI.AntiTrap.Button.MouseButton1Click:Connect(function() Toggle("AntiTrap") end)
    _G.ICEHUB_UI.AntiSentry.Button.MouseButton1Click:Connect(function() Toggle("AntiSentry") end)
    
    local features = {"SpeedBoost", "WalkSpeed", "HighJump", "InfiniteJump", "Esp", "AntiRagdoll", "Hitbox", "SpinBot", "Performance", "UnwalkAnimation", "AutoBat", "PaintballSpammer", "AntiTrap", "AntiSentry"}
    for _, feature in ipairs(features) do
        local ui = _G.ICEHUB_UI[feature]
        if ui then
            SetupKeybind(ui.KeybindBtn, feature)
        end
    end
    
    MainFrame.Visible = true
    MainFrame.Position = UDim2.new(0.5, -290, -0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -290, 0.35, -210)
    }):Play()
    
    DingSound:Play()
end)

task.wait(0.2)
LoadConfig()
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ice Hub",
        Text = "Successfully Loaded",
        Duration = 3
    })
end)
