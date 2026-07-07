-- leaked by Solar FOR FREE
-- this sources is free bradarrr
-- leaked at fpsl

if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() game:GetService("Players").RespawnTime = 0 end)
local privateBuild = false

local SharedState = {
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    DisableStealSpeed = nil,
    ListNeedsRedraw = true,
    AdminButtonCache = {},
    StealSpeedToggleFunc = nil,
    _ssUpdateBtn = nil,
    AdminProxBtn = nil,
    BalloonedPlayers = {},
    MobileScaleObjects = {},
    RefreshMobileScale = nil,
}

local State = {
    ProximityAPActive = false,
    carpetSpeedEnabled = false,
    xrayEnabled = false,
    floatActive = false,
    isTpMoving = false,
}

do
    local Sync = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
    local patched = 0

    for name, fn in pairs(Sync) do
        if typeof(fn) ~= "function" then continue end
        if isexecutorclosure(fn) then continue end

        local ok, ups = pcall(debug.getupvalues, fn)
        if not ok then continue end

        for idx, val in pairs(ups) do
            if typeof(val) == "function" and not isexecutorclosure(val) then
                local ok2, innerUps = pcall(debug.getupvalues, val)
                if ok2 then
                    local hasBoolean = false
                    for _, v in pairs(innerUps) do
                        if typeof(v) == "boolean" then
                            hasBoolean = true
                            break
                        end
                    end
                    if hasBoolean then
                        debug.setupvalue(fn, idx, newcclosure(function() end))
                        patched += 1
                    end
                end
            end
        end
    end
end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    TeleportService = game:GetService("TeleportService"),
}
local Players = Services.Players
local RunService = Services.RunService
local Heartbeat = RunService.Heartbeat
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local Workspace = Services.Workspace
local VirtualInputManager = Services.VirtualInputManager
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local LocalPlayer = Players.LocalPlayer
local Lighting = Services.Lighting
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function() settings().Rendering.FrameRateManager = 0 end)
pcall(function() settings().Rendering.MaxFrameRate = 0 end)

local function isPlayerCharacter(model)
    return game:GetService("Players"):GetPlayerFromCharacter(model) ~= nil
end

local function handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end

local function stripVisualsV2(obj, removeLights)
    local model = obj:FindFirstAncestorOfClass("Model")
    local isPlayer = model and isPlayerCharacter(model)

    if obj:IsA("Animator") then handleAnimator(obj) end
    if obj:IsA("Accessory") or obj:IsA("Clothing") then
        if obj:FindFirstAncestorOfClass("Model") then obj:Destroy() end
    end

    if not isPlayer then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Highlight") then
            obj.Enabled = false
        end
        if obj:IsA("Explosion") then obj:Destroy() end
        if obj:IsA("MeshPart") then obj.TextureID = "" end
        if removeLights and (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
            pcall(function()
                if obj.Parent ~= Lighting then
                    obj.Enabled = false
                    obj.Brightness = 0
                    obj.Range = 0
                    obj:Destroy()
                end
            end)
        end
    end

    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end

    if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end

task.spawn(function()
    local objs = workspace:GetDescendants()
    for i = 1, #objs do
        stripVisualsV2(objs[i], true)
        if i % 30 == 0 then task.wait() end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    task.defer(function() stripVisualsV2(obj, false) end)
end)

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or
           v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
            v:Destroy()
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 1
    end
end)

local SAFE_POLL_RATE = 0.10
local SAFE_POLL_OVERRIDE_UNTIL = 0

function _G.getSafePollRate()
    if os.clock() < SAFE_POLL_OVERRIDE_UNTIL then
        return 0.25
    end
    return SAFE_POLL_RATE
end

function _G.triggerSafePollBoost()
    SAFE_POLL_OVERRIDE_UNTIL = os.clock() + 3
end

local Decrypted
Decrypted = setmetatable({}, {
    __index = function(S, ez)
        local Netty = ReplicatedStorage.Packages.Net
        local prefix, path
        if     ez:sub(1,3) == "RE/" then prefix = "RE/";  path = ez:sub(4)
        elseif ez:sub(1,3) == "RF/" then prefix = "RF/";  path = ez:sub(4)
        else return nil end
        local Remote
        for i, v in Netty:GetChildren() do
            if v.Name == ez then
                Remote = Netty:GetChildren()[i + 1]
                break
            end
        end
        if Remote and not rawget(Decrypted, ez) then rawset(Decrypted, ez, Remote) end
        return rawget(Decrypted, ez)
    end
})
local Utility = {}
function Utility:LarpNet(F) return Decrypted[F] end
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

local FileName = "SolanaXHubConfig.json" 
local DefaultConfig = {
    Positions = {
    AdminPanel = {X = 0.1859375, Y = 0.5767123526556385},
    Settings = {X = 0.5, Y = 0.5},
    InvisPanel = {X = 0.8578125, Y = 0.17260276361454258},
    BrainrotSelection = {X = 0.02, Y = 0.35},
    MobileControls = {X = 0.9, Y = 0.4},
    MobileBtn_TP = {X = 0.5, Y = 0.4},
    MobileBtn_CL = {X = 0.5, Y = 0.4},
    MobileBtn_SP = {X = 0.5, Y = 0.4},
    MobileBtn_IV = {X = 0.5, Y = 0.4},
    MobileBtn_UI = {X = 0.5, Y = 0.4},
    QuickPanel = {X = 0.85, Y = 0.85},
    StatusHUD = {X = 0.5, Y = 0.02},
    DesyncPanel = {X = 0.85, Y = 0.4},
}, 
    TpSettings = {
        Tool           = "Flying Carpet",
        Speed          = 2, 
        TpKey          = "T",
        CloneKey       = "V",
        TpOnLoad       = false,
        MinGenForTp    = "",
        CarpetSpeedKey = "Q",
        InfiniteJump   = false,
        JumpVelocity   = 200,
        TargetHeight   = 50,
        PreCloneDelayFrontLow = 0,
        PreCloneDelayFrontHigh = 0.1,
        PreCloneDelaySide = 0,
        PostCloneDelay = 0,
    },
    DesyncEnabled = false,
    DesyncOnSteal = false,
    NoAnimation = false,
    ShowDesyncGUI = true,
    StealSpeed   = 20,
    MenuKey      = "LeftControl",
    MobileGuiScale = 0.5,
    XrayEnabled  = true,
    AntiRagdoll  = 0,
    AntiRagdollV2 = false,
    PlayerESP    = true,
    FPSBoost     = true,
    TracerEnabled = true,
    BrainrotESP = true,
    LineToBase = false,
    StealNearest = false,
    StealHighest = true,
    StealPriority = false,
    DefaultToNearest = false,
    DefaultToHighest = false,
    DefaultToPriority = false,
    UILocked     = false,
    HideAdminPanel = false,
    HideBrainrotSelection = false,
    CompactBrainrotSelection = false,
    AutoKickOnSteal = false,
    InstantSteal = false,
    InvisStealAngle = 233,
    SinkSliderValue = 5,
    AutoRecoverLagback = true,
    AutoInvisDuringSteal = false,
    InvisToggleKey = "I",
    ClickToAP = false,
    ClickToAPKeybind = "L",
    DisableClickToAPOnMoby = false,
    ProximityAP = false,
    ProximityAPKeybind = "P",
    ProximityRange = 15,
    StealSpeedKey = "C",
    ShowInvisPanel = true,
    ResetKey = "X",
    QuickPanelKey = "B",
    AutoResetOnBalloon = false,
    AntiBeeDisco = false,
    AutoDestroyTurrets = false,
    FOV = 70,
    BrightnessLevel = 0,
    SubspaceMineESP = false,
    AutoUnlockOnSteal = false,
    ShowUnlockButtonsHUD = true,
    AutoTPOnFailedSteal = false,
    KickKey = "",
    CleanErrorGUIs = false,
    ClickToAPSingleCommand = false,
    RagdollSelfKey = "",
    DuelBaseESP = true,
    AlertsEnabled = true,
    AlertSoundID = "rbxassetid://6518811702",
    DisableProximitySpamOnMoby = false,
    DisableClickToAPOnKawaifu = false,
    DisableProximitySpamOnKawaifu = false,
    HideKawaifuFromPanel = false,
    AutoStealSpeed = false,
    AutoBuy = false,
    AutoBuyRadius = 30,
    ShowAutoBuyRadius = true,
    ShowQuickPanel = true,
    RejoinKey = "",
    DarkMode = false,
    NightVisionStrength = 0,
    DarkModeNightVision = false,
    AutoTPPriority = false,
    PriorityList = {},
    StealingESP = false,
    MinGenForNearest = 0,
    SkipNonStealableBrainrots = false,
    JumpVelocity = 200,
    TpMode = "Stable",
    TeleportStyle = "Front",
    HideAdminControl = false,
    ProxTPRange = 20,
    ProxTPEnabled = false,
    MinGenForAutoTP = 0,
    AutoTPAlertSoundID = "rbxassetid://102483636290461",
    PostCloneDelay = 0,
    GlobalGuiScale = 1.0,
    NoAnimationOnSteal = false,
    ServerPositionMarker = false,
    MaxTrackedBrainrots = 10,
}

local Config = DefaultConfig

if isfile and isfile(FileName) then
    pcall(function()
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if not ok then return end
        for k, v in pairs(DefaultConfig) do
            if decoded[k] == nil then decoded[k] = v end
        end
        if decoded.TpSettings then
            for k, v in pairs(DefaultConfig.TpSettings) do
                if decoded.TpSettings[k] == nil then decoded.TpSettings[k] = v end
            end
        end
        if decoded.Positions then
            for k, v in pairs(DefaultConfig.Positions) do
                if decoded.Positions[k] == nil then decoded.Positions[k] = v end
            end
        end
                if decoded.HideAdminControl == nil then decoded.HideAdminControl = false end
        Config = decoded
                if decoded.ProxTPEnabled == nil then decoded.ProxTPEnabled = false end
        if decoded.ProxTPRange == nil then decoded.ProxTPRange = 20 end
    end)
end

Config.NoAnimation = false
noAnimationActive = false
Config.ProximityAP = false

local IS_MOBILE = isMobile()
local GlobalGuiScale = Config.GlobalGuiScale or 1.0
local MOBILE_SCALE = (IS_MOBILE and 0.75 or 1) * (GlobalGuiScale ^ 0.5)

local function playAutoTPAlert()
    if not Config.AutoTPAlertSoundID or Config.AutoTPAlertSoundID == "" then return end
    
    local soundId = Config.AutoTPAlertSoundID
    if not soundId:match("^rbxassetid://") then
        soundId = "rbxassetid://" .. soundId
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 1
    sound.PlayOnRemove = false
    sound.Parent = char
    
    pcall(function()
        sound:Play()
    end)
    
    task.spawn(function()
        task.wait(420)
        if sound then sound:Destroy() end
    end)
end

local darkModeActive = false
local nightVisionStrength = Config.NightVisionStrength or 100

originalLightingProperties = originalLightingProperties or { stored = false }
originalSkyProperties = originalSkyProperties or { stored = false }

local function enableDarkMode()
    if not Config.DarkMode then return end
    pcall(function()
        local lighting = game:GetService("Lighting")
        
        lighting.ClockTime = 0
        
        local strength = Config.NightVisionStrength or 100
        
        if strength == 0 then
            lighting.Brightness = 1
            lighting.GlobalShadows = true
            lighting.Ambient = Color3.fromRGB(127, 127, 127)
            lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            lighting.FogEnd = 100000
            lighting.FogStart = 0
        else
            lighting.Brightness = 0
            lighting.GlobalShadows = true
            
            local ambientValue = math.floor(120 * (1 - (strength / 100)))
            local ambientColor = Color3.fromRGB(ambientValue, ambientValue, ambientValue)
            lighting.Ambient = ambientColor
            lighting.OutdoorAmbient = ambientColor
            
            lighting.FogEnd = 9e9
            lighting.FogStart = 0
        end
        
        local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then atmosphere:Destroy() end
    end)
end

local function disableDarkMode()
    pcall(function()
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = 14
        lighting.Brightness = 1
        lighting.GlobalShadows = true
        lighting.Ambient = Color3.fromRGB(0, 0, 0)
        lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        lighting.FogEnd = 100000
        lighting.FogStart = 0
    end)
end

local function enforceDarkMode()
end

local function updateNightVision()
    if darkModeActive then
        enableDarkMode()
    end
end

if Config.DarkMode then
    darkModeActive = true
    nightVisionStrength = Config.NightVisionStrength or 100
    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        enableDarkMode()
    end)
end

task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    local char = LocalPlayer.Character
    while not char do
        char = LocalPlayer.CharacterAdded:Wait()
    end
    
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    local carpetName = Config.TpSettings.Tool
    
    local function tryEquipCarpet()
        local carpet = char:FindFirstChild(carpetName)
        if carpet then
            hum:EquipTool(carpet)
            return true
        end
        
        local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName)
        if carpet then
            hum:EquipTool(carpet)
            return true
        end
        
        return false
    end
    
    if not tryEquipCarpet() then
        local retries = 0
        while retries < 10 do
            task.wait(0.5)
            if tryEquipCarpet() then
                break
            end
            retries = retries + 1
        end
    end
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        local hum = newChar:WaitForChild("Humanoid", 5)
        if hum then
            local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or newChar:FindFirstChild(carpetName)
            if carpet then
                hum:EquipTool(carpet)
            end
        end
    end)
end)

local noAnimConnection = nil
local noAnimHeartbeat = nil
local wasStealing = false
local noAnimationActive = false

local function setNoAnimationOnSteal(enabled)
    if not enabled then
        setNoAnimation(false)
        return
    end
    
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    setNoAnimation(isStealing)
end

LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    if Config.NoAnimationOnSteal then
        local isStealing = LocalPlayer:GetAttribute("Stealing")
        setNoAnimation(isStealing)
    end
end)

local function watchNoAnimConfig()
    while task.wait(0.5) do
        if not Config.NoAnimationOnSteal then
            setNoAnimation(false)
        end
    end
end
task.spawn(watchNoAnimConfig)

LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    
    if isStealing and not wasStealing then
        wasStealing = true
        setNoAnimation(true)
    elseif not isStealing and wasStealing then
        wasStealing = false
        setNoAnimation(false)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    wasStealing = false
    noAnimationActive = false
    if noAnimHeartbeat then
        noAnimHeartbeat:Disconnect()
        noAnimHeartbeat = nil
    end
    if noAnimConnection then
        noAnimConnection:Disconnect()
        noAnimConnection = nil
    end
end)

local function initializeAfterRespawn()
    local char = LocalPlayer.Character
    while not char do
        char = LocalPlayer.CharacterAdded:Wait()
    end
    
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hrp or not hum then return end
    
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    if carpet then
        hum:EquipTool(carpet)
    end
    
    State.isTpMoving = false
    
    if _G.resetPlotBeam then
        pcall(_G.resetPlotBeam)
    end
    
    task.wait(1)
    if Config.LineToBase then
        pcall(createPlotBeam)
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    initializeAfterRespawn()
end)

task.spawn(function()
    task.wait(1)
    initializeAfterRespawn()
end)

local function SaveConfig()
    if writefile then
        pcall(function()
            local toSave = {}
            for k, v in pairs(Config) do 
                if k ~= "NoAnimation" then
                    toSave[k] = v 
                end
            end
            toSave.ProximityAP = false
            writefile(FileName, HttpService:JSONEncode(toSave))
        end)
    end
end

local function isMobyUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild("_moby_highlight") ~= nil
end

local HighlightName = "KaWaifu_NeonHighlight"
local function isKawaifuUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild(HighlightName) ~= nil
end

_G.InvisStealAngle = Config.InvisStealAngle
_G.SinkSliderValue = Config.SinkSliderValue
_G.AutoRecoverLagback = Config.AutoRecoverLagback
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal
_G.INVISIBLE_STEAL_KEY = Enum.KeyCode[Config.InvisToggleKey] or Enum.KeyCode.I
_G.invisibleStealEnabled = false
_G.RecoveryInProgress = false

local function getControls()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	return playerModule:GetControls()
end

local Controls = getControls()

local function rejoinGame()TeleportService:Teleport(game.PlaceId, LocalPlayer) end

local function waitUntilHeartbeat(predicate, timeoutSec)
    local t = 0
    while true do
        if predicate() then return true end
        local dt = RunService.Heartbeat:Wait()
        t = t + dt
        if timeoutSec and t >= timeoutSec then return false end
    end
end

local function walk(seconds)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local Controls = getControls()
    local lookVector = hrp.CFrame.LookVector
    Controls:Disable()
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            hum:Move(Vector3.zero, false)
            Controls:Enable()
            return
        end
        hum:Move(lookVector, false)
    end)
end

local function triggerClosestUnlock(yLevel, maxY)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local playerY = yLevel or hrp.Position.Y
    local Y_THRESHOLD = 5

    local bestPromptSameLevel = nil
    local shortestDistSameLevel = math.huge
    local bestPromptFallback = nil
    local shortestDistFallback = math.huge
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, obj in ipairs(plots:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                if maxY and part.Position.Y > maxY then
                else
                    local distance = (hrp.Position - part.Position).Magnitude
                    local yDifference = math.abs(playerY - part.Position.Y)

                    if distance < shortestDistFallback then
                        shortestDistFallback = distance
                        bestPromptFallback = obj
                    end

                    if yDifference <= Y_THRESHOLD then
                        if distance < shortestDistSameLevel then
                            shortestDistSameLevel = distance
                            bestPromptSameLevel = obj
                        end
                    end
                end
            end
        end
    end

    local targetPrompt = bestPromptSameLevel or bestPromptFallback

    if targetPrompt then
        if fireproximityprompt then
            fireproximityprompt(targetPrompt)
        else
            targetPrompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.05)
            targetPrompt:InputEnded(Enum.UserInputType.MouseButton1)
        end
    end
end

local Theme = {
    Background      = Color3.fromRGB(8, 8, 12),
    Surface         = Color3.fromRGB(12, 12, 18),
    SurfaceLight    = Color3.fromRGB(18, 18, 25),
    SurfaceHighlight= Color3.fromRGB(25, 25, 35),
    Accent1         = Color3.fromRGB(138, 43, 226),
    Accent2         = Color3.fromRGB(0, 191, 255),
    TextPrimary     = Color3.fromRGB(255, 255, 255),
    TextSecondary   = Color3.fromRGB(200, 200, 210),
    TextMuted       = Color3.fromRGB(150, 150, 160),
    Success         = Color3.fromRGB(0, 200, 150),
    Error           = Color3.fromRGB(255, 70, 90),
    Warning         = Color3.fromRGB(255, 180, 50),
}



local AnimalModels = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Animals")
local AnimalAnimations = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Animals")

local function createAnimalPreview(parent, animalName, size)
    if not AnimalModels then return nil end
    local template = AnimalModels:FindFirstChild(animalName)
    if not template then return nil end
    
    local viewport = Instance.new("ViewportFrame")
    viewport.Size = size or UDim2.new(0, 40, 0, 40)
    viewport.BackgroundTransparency = 1
    viewport.BorderSizePixel = 0
    viewport.LightColor = Color3.fromRGB(255, 255, 255)
    viewport.LightDirection = Vector3.new(-1, -2, -1)
    viewport.Ambient = Color3.fromRGB(180, 180, 180)
    viewport.Parent = parent
    
    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = viewport
    
    local clone = template:Clone()
    clone.Parent = worldModel
    
    if clone.PrimaryPart then
        clone.PrimaryPart.Anchored = true
    end
    
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CastShadow = false
            descendant.Massless = true
        end
    end
    
    local success, boundingBoxCFrame, boundingBoxSize = pcall(function()
        return clone:GetBoundingBox()
    end)
    
    if not success then
        boundingBoxCFrame = clone:GetPivot()
        boundingBoxSize = Vector3.new(4, 4, 4)
    end
    
    local maxDimension = math.max(boundingBoxSize.X, boundingBoxSize.Y, boundingBoxSize.Z)
    local fov = 50
    local distance = (maxDimension * 0.5) / math.tan(math.rad(fov * 0.5)) * 0.85
    local modelCFrame = (clone.PrimaryPart and clone.PrimaryPart.CFrame) or clone:GetPivot()
    local offset = (modelCFrame.LookVector + Vector3.new(0, 0.25, 0)).Unit
    local camera = Instance.new("Camera")
    camera.FieldOfView = fov
    camera.CFrame = CFrame.new(boundingBoxCFrame.Position + offset * (distance + maxDimension * 0.5), boundingBoxCFrame.Position)
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    
    if AnimalAnimations then
        local animalAnimFolder = AnimalAnimations:FindFirstChild(animalName)
        if animalAnimFolder then
            local idleAnim = animalAnimFolder:FindFirstChild("Idle") or animalAnimFolder:FindFirstChild("idle") or animalAnimFolder:GetChildren()[1]
            if idleAnim then
                local animationController = clone:FindFirstChildWhichIsA("AnimationController", true)
                if not animationController then
                    animationController = Instance.new("AnimationController")
                    animationController.Parent = clone
                end
                local animator = animationController:FindFirstChildOfClass("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = animationController
                end
                local track = animator:LoadAnimation(idleAnim)
                track.Looped = true
                track:Play(0)
                if track.Length > 0 then
                    track.TimePosition = os.clock() % track.Length
                end
                
                task.spawn(function()
                    while viewport.Parent do
                        task.wait(1)
                        pcall(function()
                            if track and track.Length > 0 then
                                local time = os.clock() % track.Length
                                if math.abs(time - track.TimePosition) > 0.05 then
                                    track.TimePosition = time
                                end
                            end
                        end)
                    end
                end)
            end
        end
    end
    
    return viewport
end

_G.isBindingKey = false

local function CreateNeonGradient(parent)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent1)
    }
    g.Rotation = 45
    return g
end

local function AddAnimatedBorder(frame, thickness)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = 0.3
    stroke.Color = Theme.TextPrimary
    local grad = CreateNeonGradient(stroke)
    
    task.spawn(function()
        while stroke.Parent do
            for i = 0, 360, 0.5 do
                grad.Rotation = i
                stroke.Transparency = 0.2 + math.sin(i * 0.01) * 0.2
                task.wait(0.02)
            end
        end
    end)
    return stroke
end

local function MakeText(label, isTitle)
    label.Font = Enum.Font.Gotham
    label.TextSize = (isTitle and 14 or 11) * MOBILE_SCALE
    label.TextColor3 = Theme.TextPrimary
end

local function findAdorneeGlobal(animalData)
    if not animalData then return nil end
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
    if plot then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn then return spawn end
                    return base:FindFirstChildWhichIsA("BasePart") or base
                end
            end
        end
    end
    return nil
end

local function ShowNotification(title, text)
    local existing = PlayerGui:FindFirstChild("SolanaNotif")
    if existing then existing:Destroy() end

    local NOTIF_ASSET_ID = "rbxassetid://122875574139178"
    local NOTIF_WIDTH = 340
    local NOTIF_HEIGHT = 58
    local DURATION = 3.5
    
    local sg = Instance.new("ScreenGui", PlayerGui)
    sg.Name = "SolanaNotif"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 100

    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, NOTIF_WIDTH, 0, NOTIF_HEIGHT)
    f.Position = UDim2.new(0.5, -NOTIF_WIDTH/2, 0, -200)
    f.BackgroundColor3 = Theme.Background
    f.BackgroundTransparency = 0.08
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    stroke.Color = Theme.Accent1
    local grad = Instance.new("UIGradient", stroke)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent1)
    }
    task.spawn(function()
        while stroke.Parent do
            grad.Rotation = (grad.Rotation or 0) + 1
            stroke.Transparency = 0.2 + math.sin(grad.Rotation * 0.02) * 0.2
            task.wait(0.02)
        end
    end)
    
    local logo = Instance.new("ImageLabel", f)
    logo.Size = UDim2.new(0, 42, 0, 42)
    logo.Position = UDim2.new(0, 8, 0.5, -21)
    logo.BackgroundTransparency = 1
    logo.Image = NOTIF_ASSET_ID
    logo.ScaleType = Enum.ScaleType.Fit
    
    local t1 = Instance.new("TextLabel", f)
    t1.Size = UDim2.new(1, -62, 0, 18)
    t1.Position = UDim2.new(0, 58, 0, 8)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.Font = Enum.Font.Gotham
    t1.TextSize = 11
    t1.TextColor3 = Color3.fromRGB(255, 255, 255)
    t1.TextXAlignment = Enum.TextXAlignment.Left
    
    local t2 = Instance.new("TextLabel", f)
    t2.Size = UDim2.new(1, -62, 0, 16)
    t2.Position = UDim2.new(0, 58, 0, 28)
    t2.BackgroundTransparency = 1
    t2.Text = text
    t2.Font = Enum.Font.Gotham
    t2.TextSize = 9
    t2.TextColor3 = Color3.fromRGB(180, 180, 190)
    t2.TextXAlignment = Enum.TextXAlignment.Left
    
    local progressContainer = Instance.new("Frame", f)
    progressContainer.Size = UDim2.new(1, -16, 0, 1.5)
    progressContainer.Position = UDim2.new(0, 8, 1, -5)
    progressContainer.BackgroundColor3 = Theme.Surface
    progressContainer.BackgroundTransparency = 0.5
    progressContainer.BorderSizePixel = 0
    Instance.new("UICorner", progressContainer).CornerRadius = UDim.new(1, 0)
    
    local progressBar = Instance.new("Frame", progressContainer)
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Theme.Accent1
    progressBar.BorderSizePixel = 0
    Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)
    
    TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -NOTIF_WIDTH/2, 0, 15)
    }):Play()
    
    local startTime = tick()
    local progConn
    progConn = RunService.Heartbeat:Connect(function()
        if not progressBar.Parent then progConn:Disconnect() return end
        local elapsed = tick() - startTime
        local remaining = math.max(0, 1 - (elapsed / DURATION))
        progressBar.Size = UDim2.new(remaining, 0, 1, 0)
        if remaining <= 0 then progConn:Disconnect() end
    end)
    
    task.delay(DURATION, function()
        TweenService:Create(f, TweenInfo.new(0.2), {Position = UDim2.new(0.5, -NOTIF_WIDTH/2, 0, -200)}):Play()
        task.wait(0.21)
        if progConn then progConn:Disconnect() end
        if sg.Parent then sg:Destroy() end
    end)
end

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local inBase = false
local lastOwner = nil

local function getPlotOwner(plot)
    local Packages = ReplicatedStorage:FindFirstChild("Packages")
    if Packages then
        local ok, Sync = pcall(require, Packages:WaitForChild("Synchronizer"))
        if ok and Sync then
            local ok2, channel = pcall(Sync.Get, Sync, plot.Name)
            if ok2 and channel then
                local owner = channel:Get("Owner")
                if owner then
                    if typeof(owner) == "Instance" and owner:IsA("Player") then
                        return owner.DisplayName
                    elseif type(owner) == "table" and owner.Name then
                        local player = Players:FindFirstChild(owner.Name)
                        if player then
                            return player.DisplayName
                        end
                        return owner.Name
                    end
                end
            end
        end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end
    
    local pos = hrp.Position
    local newInBase = false
    local newOwner = nil
    
    for _, plot in ipairs(plots:GetChildren()) do
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
            local cnt = 0
            
            for _, p in ipairs(podiums:GetChildren()) do
                local base = p:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                local checkPos = spawn and spawn.Position or (base and base.Position)
                if checkPos then
                    cnt = cnt + 1
                    minX = math.min(minX, checkPos.X)
                    maxX = math.max(maxX, checkPos.X)
                    minZ = math.min(minZ, checkPos.Z)
                    maxZ = math.max(maxZ, checkPos.Z)
                end
            end
            
            if cnt > 0 then
                local centerX = (minX + maxX) / 2
                local centerZ = (minZ + maxZ) / 2
                local sizeX = (maxX - minX) + 13
                local sizeZ = (maxZ - minZ) + 8
                local maxY = (cnt <= 10 and 10) or (cnt <= 18 and 25) or 40
                
                if pos.Y <= maxY and pos.Y >= -10 and 
                   math.abs(pos.X - centerX) <= sizeX/2 and 
                   math.abs(pos.Z - centerZ) <= sizeZ/2 then
                    
                    local ownerName = getPlotOwner(plot)
                    if ownerName then
                        newInBase = true
                        newOwner = ownerName
                        break
                    end
                end
            end
        end
    end
    
    if newInBase and not inBase and newOwner then
        ShowNotification("Base Entry", newOwner .. "'s Base")
    elseif not newInBase and inBase and lastOwner then
        ShowNotification("Left Base", "Exited " .. lastOwner .. "'s Base")
    elseif newInBase and inBase and newOwner and newOwner ~= lastOwner then
        ShowNotification("Base Entry", newOwner .. "'s Base")
    end
    
    inBase = newInBase
    lastOwner = newOwner
end)

_G.GetInBase = function() return inBase end
_G.GetBaseOwner = function() return lastOwner end

local function Clone()
    if _G.isCloning then return end
    _G.isCloning = true
    _G.cloneFailed = false

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        _G.isCloning = false
        return
    end

    local startInBase = _G.GetInBase and _G.GetInBase() or false
    local startBaseOwner = _G.GetBaseOwner and _G.GetBaseOwner() or nil

    local moveCancelled = false
    local moveConn
    moveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local movementKeys = {
            Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
            Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right
        }
        for _, key in ipairs(movementKeys) do
            if input.KeyCode == key then
                moveCancelled = true
                return
            end
        end
        if input.UserInputType == Enum.UserInputType.Touch then
            moveCancelled = true
        end
    end)

    local cloneError = false
    local cloner = nil
    local hum = nil

    char = LocalPlayer.Character
    if not char then
        cloneError = true
    else
        hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            cloneError = true
        else
            cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
            if not cloner then
                cloneError = true
            end
        end
    end

    if not cloneError then
        if cloner.Parent ~= char then
            local equipOk = pcall(function()
                hum:EquipTool(cloner)
                task.wait()
            end)
            if not equipOk then
                cloneError = true
            end
        end
    end

    if not cloneError then
        local activateOk = pcall(function()
            cloner:Activate()
        end)
        if not activateOk then
            cloneError = true
        end
    end

    if not cloneError then
        task.wait(0.05)
        
        local toolsFrames = LocalPlayer.PlayerGui:FindFirstChild("ToolsFrames")
        local qcFrame = toolsFrames and toolsFrames:FindFirstChild("QuantumCloner")
        local tpButton = qcFrame and qcFrame:FindFirstChild("TeleportToClone")
        
        if not tpButton then
            cloneError = true
        else
            tpButton.Visible = true
            local clickOk = pcall(function()
                if firesignal then
                    firesignal(tpButton.MouseButton1Up)
                    if _G.triggerSafePollBoost then
                        _G.triggerSafePollBoost()
                    end
                end
            end)
            if not clickOk then
                cloneError = true
            end
        end
    end

    if moveConn then
        moveConn:Disconnect()
    end

    if moveCancelled then
        _G.isCloning = false
        _G.cloneFailed = false
        return
    end

    if cloneError then
        _G.isCloning = false
        _G.cloneFailed = true
        return
    end

    local startTime = tick()
    local baseEntered = false
    local enteredBase = nil
    local heartbeatConn = nil

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if (tick() - startTime) >= 1.5 then
            if heartbeatConn then heartbeatConn:Disconnect() end
            return
        end
        local currentInBase = _G.GetInBase and _G.GetInBase() or false
        local currentOwner = _G.GetBaseOwner and _G.GetBaseOwner() or nil
        if currentInBase then
            if not startInBase or (startInBase and currentOwner ~= startBaseOwner) then
                baseEntered = true
                enteredBase = currentOwner
                if heartbeatConn then heartbeatConn:Disconnect() end
            end
        end
    end)

    while not baseEntered and (tick() - startTime) < 1.5 do
        task.wait()
    end
    if heartbeatConn then heartbeatConn:Disconnect()

    if baseEntered then
        _G.isCloning = false
        _G.cloneFailed = false
    else
        _G.cloneFailed = true
        _G.isCloning = false
        end
    end
end

local function AddMobileMinimize(frame, labelText)
    if not IS_MOBILE then return end
    if not frame or not frame.Parent then return end
    local guiParent = frame.Parent
    local header = frame:FindFirstChildWhichIsA("Frame")
    if not header then return end

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26 * MOBILE_SCALE, 0, 26 * MOBILE_SCALE)
    minimizeBtn.Position = UDim2.new(1, -30 * MOBILE_SCALE, 0, 6 * MOBILE_SCALE)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 18 * MOBILE_SCALE
    minimizeBtn.TextColor3 = Theme.TextPrimary
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8 * MOBILE_SCALE)

    local restoreBtn = Instance.new("TextButton", guiParent)
    restoreBtn.Size = UDim2.new(0, 110 * MOBILE_SCALE, 0, 34 * MOBILE_SCALE)
    restoreBtn.Position = UDim2.new(0, 10 * MOBILE_SCALE, 1, -44 * MOBILE_SCALE)
    restoreBtn.BackgroundColor3 = Theme.SurfaceHighlight
    restoreBtn.Text = "ðŸ”“ " .. (labelText or "OPEN")
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.TextSize = 12 * MOBILE_SCALE
    restoreBtn.TextColor3 = Theme.TextPrimary
    restoreBtn.Visible = false
    restoreBtn.AutoButtonColor = false
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 10 * MOBILE_SCALE)

    MakeDraggable(restoreBtn, restoreBtn)

    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        restoreBtn.Visible = true
    end)

    restoreBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        restoreBtn.Visible = false
    end)
end

local function MakeDraggable(handle, target, saveKey)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local parentSize = target.Parent.AbsoluteSize
                        Config.Positions[saveKey] = {
                            X = target.AbsolutePosition.X / parentSize.X,
                            Y = target.AbsolutePosition.Y / parentSize.Y,
                        }
                        SaveConfig()
                    end
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local State = {
    antiRagdollMode = Config.AntiRagdoll or 0,
    infiniteJumpEnabled = Config.TpSettings.InfiniteJump,
}

task.spawn(function()
    task.wait(0.5)
    local splash = Instance.new("ScreenGui")
    splash.Name = "SolanaXSplash"
    splash.ResetOnSpawn = false
    splash.DisplayOrder = 9999
    splash.Parent = PlayerGui
    
    local frame = Instance.new("Frame", splash)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 1
    
    local image = Instance.new("ImageLabel", frame)
    image.Size = UDim2.new(0, 300, 0, 300)
    image.Position = UDim2.new(0.5, -150, 0.5, -150)
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://"
    image.ImageTransparency = 1
    image.ScaleType = Enum.ScaleType.Fit
    
    local discordText = Instance.new("TextLabel", frame)
    discordText.Size = UDim2.new(0, 400, 0, 40)
    discordText.Position = UDim2.new(0.5, -200, 0.5, -70)
    discordText.BackgroundTransparency = 1
    discordText.Text = "solanax"
    discordText.TextColor3 = Theme.Accent2
    discordText.TextSize = 24
    discordText.Font = Enum.Font.GothamBold
    discordText.TextTransparency = 1
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://122875574139178"
    sound.Volume = 0.7
    sound.Parent = splash
    sound:Play()
    
    local fadeIn = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(image, fadeIn, {ImageTransparency = 0}):Play()
    TweenService:Create(discordText, fadeIn, {TextTransparency = 0}):Play()
    
    task.wait(1.4)
    
    local fadeOut = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(frame, fadeOut, {BackgroundTransparency = 1}):Play()
    TweenService:Create(image, fadeOut, {ImageTransparency = 1}):Play()
    TweenService:Create(discordText, fadeOut, {TextTransparency = 1}):Play()
    
    task.wait(3)
    splash:Destroy()
end)

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end

local function stripVisuals(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    local isPlayer = model and isPlayerCharacter(model)

    if obj:IsA("Animator") then handleAnimator(obj) end

    if obj:IsA("Accessory") or obj:IsA("Clothing") then
        if obj:FindFirstAncestorOfClass("Model") then
            obj:Destroy()
        end
    end

    if not isPlayer then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or 
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or 
           obj:IsA("Highlight") then
            obj.Enabled = false
        end
        if obj:IsA("Explosion") then
            obj:Destroy()
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end

    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end

    if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end

local Connections = {
    carpetSpeedConnection = nil,
    infiniteJumpConnection = nil,
    xrayDescConn = nil,
    antiRagdollConn = nil,
    antiRagdollV2Task = nil,
}
local UI = {
    carpetStatusLabel = nil,
    settingsGui = nil,
}
local carpetSpeedEnabled = State.carpetSpeedEnabled
local carpetSpeedConnection = Connections.carpetSpeedConnection
local _carpetStatusLabel = UI.carpetStatusLabel

local function setCarpetSpeed(enabled)
    State.carpetSpeedEnabled = enabled
    carpetSpeedEnabled = State.carpetSpeedEnabled
    if Connections.carpetSpeedConnection then Connections.carpetSpeedConnection:Disconnect(); Connections.carpetSpeedConnection = nil end
    carpetSpeedConnection = Connections.carpetSpeedConnection
    if not enabled then return end

    if SharedState.DisableStealSpeed then SharedState.DisableStealSpeed() end

    Connections.carpetSpeedConnection = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChild("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local toolName = Config.TpSettings.Tool
        local hasTool = c:FindFirstChild(toolName)
        
        if not hasTool then
            local tb = LocalPlayer.Backpack:FindFirstChild(toolName)
            if tb then hum:EquipTool(tb) end
        end

        if hasTool then
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * 140, 
                    hrp.AssemblyLinearVelocity.Y, 
                    md.Z * 140
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

local JumpData = {lastJumpTime = 0}
local infiniteJumpEnabled = State.infiniteJumpEnabled
local infiniteJumpConnection = Connections.infiniteJumpConnection

local function setInfiniteJump(enabled)
    State.infiniteJumpEnabled = enabled
    infiniteJumpEnabled = State.infiniteJumpEnabled
    Config.TpSettings.InfiniteJump = enabled
    SaveConfig()
    if Connections.infiniteJumpConnection then Connections.infiniteJumpConnection:Disconnect(); Connections.infiniteJumpConnection = nil end
    infiniteJumpConnection = Connections.infiniteJumpConnection
    if not enabled then return end

    Connections.infiniteJumpConnection = RunService.Heartbeat:Connect(function()
        if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
        local now = tick()
        if now - JumpData.lastJumpTime < 0.1 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        JumpData.lastJumpTime = now
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z)
    end)
end
if infiniteJumpEnabled then setInfiniteJump(true) end

local XrayState = {
    originalTransparency = {},
    xrayEnabled = false,
}
local originalTransparency = XrayState.originalTransparency
local xrayEnabled = XrayState.xrayEnabled

local function isBaseWall(obj)
    if not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
    return name:find("base") or parentName:find("base")
end

local function enableXray()
    XrayState.xrayEnabled = true
    xrayEnabled = XrayState.xrayEnabled
    do
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
                XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
                originalTransparency[obj] = XrayState.originalTransparency[obj]
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end
end

local xrayDescConn = Connections.xrayDescConn
local function disableXray()
    XrayState.xrayEnabled = false
    xrayEnabled = XrayState.xrayEnabled
    if Connections.xrayDescConn then Connections.xrayDescConn:Disconnect(); Connections.xrayDescConn = nil end
    xrayDescConn = Connections.xrayDescConn
    for part, val in pairs(XrayState.originalTransparency) do
        if part and part.Parent then part.LocalTransparencyModifier = val end
    end
    XrayState.originalTransparency = {}
    originalTransparency = XrayState.originalTransparency
end

if Config.XrayEnabled then
    enableXray()
    Connections.xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
        if XrayState.xrayEnabled and obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
            XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
            originalTransparency[obj] = XrayState.originalTransparency[obj]
            obj.LocalTransparencyModifier = 0.85
        end
    end)
    xrayDescConn = Connections.xrayDescConn
end

local antiRagdollMode = State.antiRagdollMode
local antiRagdollConn = Connections.antiRagdollConn

local function isRagdolled()
    local char = LocalPlayer.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local state = hum:GetState()
    local ragStates = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragStates[state] then return true end
    local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
    if endTime and (endTime - Workspace:GetServerTimeNow()) > 0 then return true end
    return false
end

local function stopAntiRagdoll()
    if Connections.antiRagdollConn then Connections.antiRagdollConn:Disconnect(); Connections.antiRagdollConn = nil end
    antiRagdollConn = Connections.antiRagdollConn
end

local function startAntiRagdoll(mode)
    stopAntiRagdoll()
    if Config.AntiRagdollV2 then
        stopAntiRagdollV2()
    end
    if mode == 0 then return end

    Connections.antiRagdollConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if isRagdolled() then
            pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", Workspace:GetServerTimeNow()) end)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hrp.AssemblyLinearVelocity = Vector3.zero
            if Workspace.CurrentCamera.CameraSubject ~= hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BallSocketConstraint") or obj.Name:find("RagdollAttachment") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

local AntiRagdollV2Data = {
    antiRagdollConns = {},
}
local antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

local cleanRagdollV2Scheduled = false
local function cleanRagdollV2(char)
    if not char then return end
    local carpetEquipped = false
    pcall(function()
        local toolName = Config.TpSettings.Tool or "Flying Carpet"
        local tool = char:FindFirstChild(toolName)
        if tool then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(hrp:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
            if not carpetEquipped then
                for _, obj in ipairs(tool:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
        end
    end)
    local descendants = char:GetDescendants()
    for _, d in ipairs(descendants) do
        if d:IsA("BallSocketConstraint") or d:IsA("NoCollisionConstraint")
            or d:IsA("HingeConstraint")
            or (d:IsA("Attachment") and (d.Name == "A" or d.Name == "B")) then
            d:Destroy()
        elseif (d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and not carpetEquipped then
            d:Destroy()
        end
    end
    for _, d in ipairs(descendants) do
        if d:IsA("Motor6D") then d.Enabled = true end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n = track.Animation and track.Animation.Name:lower() or ""
                if n:find("rag") or n:find("fall") or n:find("hurt") or n:find("down") then
                    track:Stop(0)
                end
            end
        end
    end
    task.defer(function()
        pcall(function()
            local pm = LocalPlayer:FindFirstChild("PlayerScripts")
            if pm then pm = pm:FindFirstChild("PlayerModule") end
            if pm then require(pm):GetControls():Enable() end
        end)
    end)
end

local function cleanRagdollV2Debounced(char)
    if cleanRagdollV2Scheduled then return end
    cleanRagdollV2Scheduled = true
    task.defer(function()
        cleanRagdollV2Scheduled = false
        if char and char.Parent then cleanRagdollV2(char) end
    end)
end

local function isRagdollRelatedDescendant(obj)
    if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") then return true end
    if obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B") then return true end
    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then return true end
    return false
end

local function hookAntiRagV2(char)
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hum or not hrp then return end

    local lastVel = Vector3.new(0, 0, 0)

    local c1 = hum.StateChanged:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            local carpetActive = false
            pcall(function()
                local toolName = Config.TpSettings.Tool or "Flying Carpet"
                local tool = char:FindFirstChild(toolName)
                if tool and hrp then
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                            carpetActive = true
                        end
                    end
                end
            end)
            if not carpetActive then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            cleanRagdollV2(char)
            pcall(function() Workspace.CurrentCamera.CameraSubject = hum end)
            pcall(function()
                local pm = LocalPlayer:FindFirstChild("PlayerScripts")
                if pm then pm = pm:FindFirstChild("PlayerModule") end
                if pm then require(pm):GetControls():Enable() end
            end)
        end
    end)
    table.insert(antiRagdollConns, c1)

    local c2 = char.DescendantAdded:Connect(function(desc)
        if isRagdollRelatedDescendant(desc) then
            cleanRagdollV2Debounced(char)
        end
    end)
    table.insert(antiRagdollConns, c2)

    pcall(function()
        local pkg = ReplicatedStorage:FindFirstChild("Packages")
        if pkg then
            local net = pkg:FindFirstChild("Net")
            if net then
                local applyImp = net:FindFirstChild("RE/CombatService/ApplyImpulse")
                if applyImp and applyImp:IsA("RemoteEvent") then
                    local c3 = applyImp.OnClientEvent:Connect(function()
                        local st = hum:GetState()
                        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
                            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
                            pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
                        end
                    end)
                    table.insert(antiRagdollConns, c3)
                end
            end
        end
    end)

    local c4 = RunService.Heartbeat:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            cleanRagdollV2(char)
            local vel = hrp.AssemblyLinearVelocity
            if (vel - lastVel).Magnitude > 40 and vel.Magnitude > 25 then
                hrp.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, 15)
            end
        end
        lastVel = hrp.AssemblyLinearVelocity
    end)
    table.insert(antiRagdollConns, c4)

    cleanRagdollV2(char)
end

local function stopAntiRagdollV2()
    cleanRagdollV2Scheduled = false
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
end

local function startAntiRagdollV2(enabled)
    stopAntiRagdoll()
    stopAntiRagdollV2()
    if not enabled then
        return
    end

    local char = LocalPlayer.Character
    if char then task.spawn(function() hookAntiRagV2(char) end) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.spawn(function() hookAntiRagV2(c) end)
    end)
end

if antiRagdollMode > 0 then startAntiRagdoll(antiRagdollMode) end
if Config.AntiRagdollV2 then startAntiRagdollV2(true) end

local Pathfinding = {
    lastPathCheck = {},
}

function Pathfinding:CheckCollision(origin, destination, character)
    local direction = destination - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    
    if result and result.Instance then
        if result.Instance.CanCollide == false then
            return self:CheckCollision(result.Position + (direction.Unit * 0.1), destination, character)
        end
        return true
    end
    return false
end

function Pathfinding:GetTeleportTarget(targetPart)
    if not targetPart then return nil end
    local exactPos = targetPart.Position
    local isSecondFloor = exactPos.Y > 10
    local isThirdFloor = exactPos.Y > 25
    
    if isThirdFloor then
        return Vector3.new(exactPos.X, exactPos.Y - 6.5, exactPos.Z)
    elseif isSecondFloor then
        return Vector3.new(exactPos.X, exactPos.Y - 6.5, exactPos.Z)
    else
        return exactPos
    end
end

local TeleportBeam = {
    line = nil,
    marker = nil,
}

function TeleportBeam:Init()
    local screenGui = PlayerGui:FindFirstChild("TeleportBeamGui") or Instance.new("ScreenGui", PlayerGui)
    screenGui.Name = "TeleportBeamGui"
    screenGui.ResetOnSpawn = false
    
    self.line = Instance.new("CylinderHandleAdornment")
    self.line.Transparency = 0.5
    self.line.Adornee = workspace.Terrain
    self.line.Radius = 0.15
    self.line.Parent = screenGui
    
    self.marker = Instance.new("SphereHandleAdornment")
    self.marker.Radius = 0.6
    self.marker.Transparency = 0.5
    self.marker.Adornee = workspace.Terrain
    self.marker.Parent = screenGui
end

function TeleportBeam:Update(targetPos, isClear)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and targetPos then
        self.line.Visible = true
        self.marker.Visible = true
        self.marker.CFrame = CFrame.new(targetPos)
        
        local origin = hrp.Position
        local dist = (targetPos - origin).Magnitude
        self.line.Height = dist
        self.line.CFrame = CFrame.lookAt(origin, targetPos) * CFrame.new(0, 0, -dist/2)
        
        if isClear then
            self.line.Color3 = Theme.Accent1
            self.marker.Color3 = Theme.Accent1
        else
            self.line.Color3 = Color3.fromRGB(0, 0, 0)
            self.marker.Color3 = Color3.fromRGB(0, 0, 0)
        end
    else
        self.line.Visible = false
        self.marker.Visible = false
    end
end

function TeleportBeam:Hide()
    self.line.Visible = false
    self.marker.Visible = false
end

TeleportBeam:Init()

RunService.RenderStepped:Connect(function()
    if Config.TracerEnabled and SharedState.SelectedPetData then
        local targetPart = findAdorneeGlobal(SharedState.SelectedPetData.animalData)
        if targetPart then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local teleportTarget = Pathfinding:GetTeleportTarget(targetPart)
                if teleportTarget then
                    local isClear = not Pathfinding:CheckCollision(hrp.Position, teleportTarget, char)
                    TeleportBeam:Update(teleportTarget, isClear)
                end
            end
        end
    else
        TeleportBeam:Hide()
    end
end)

local BASES_LOW = {
    [1] = Vector3.new(-460, -6, 219), [5] = Vector3.new(-355, -6, 217),
    [2] = Vector3.new(-460, -6, 111), [6] = Vector3.new(-355, -6, 113),
    [3] = Vector3.new(-460, -6, 5),   [7] = Vector3.new(-355, -6, 5),
    [4] = Vector3.new(-460, -6, -100),[8] = Vector3.new(-355, -6, -100) 
}

local BASES_FACE = {
    [1] = Vector3.new(-502.5, -6, 219), [5] = Vector3.new(-316.5, -6, 217),
    [2] = Vector3.new(-502.5, -6, 111), [6] = Vector3.new(-316.5, -6, 113),
    [3] = Vector3.new(-502.5, -6, 5),   [7] = Vector3.new(-316.5, -6, 5),
    [4] = Vector3.new(-502.5, -6, -100),[8] = Vector3.new(-316.5, -6, -100) 
}

local BASES_HIGH_FAST = {
    [1] = Vector3.new(-476.474853515625, 16.5, 220.94090270996094),
    [2] = Vector3.new(-476.5684814453125, 16.5, 113.77315521240234),
    [3] = Vector3.new(-476.8675842285156, 16.5, 6.178487777709961),
    [4] = Vector3.new(-476.6324768066406, 16.5, -101.07275390625),
    [5] = Vector3.new(-342.5367126464844, 16.5, 221.44737243652344),
    [6] = Vector3.new(-342.8604736328125, 16.5, 113.41409301757812),
    [7] = Vector3.new(-342.42108154296875, 16.5, 6.249461650848389),
    [8] = Vector3.new(-342.7937927246094, 16.5, -99.73458862304688)
}

local CLONE_POSITIONS_FLOOR = {
    Vector3.new(-476, -5.67, 221), Vector3.new(-476, -5.67, 114),
    Vector3.new(-476, -5.67, 7),   Vector3.new(-476, -5.67, -100),
    Vector3.new(-343, -5.67, -100),Vector3.new(-343, -5.67, 6),
    Vector3.new(-343, -5.67, 114), Vector3.new(-343, -5.67, 220)
}

local SIDE_TP_LOW = {
    [1] = Vector3.new(-502.5, -6, 245.67),
    [2] = Vector3.new(-502.5, -6, 138.67),
    [3] = Vector3.new(-502.5, -6, 31.67),
    [4] = Vector3.new(-502.5, -6, -74.41),
    [5] = Vector3.new(-316.5, -6, 195.5),
    [6] = Vector3.new(-316.5, -6, 88.5),
    [7] = Vector3.new(-316.5, -6, -18.5),
    [8] = Vector3.new(-316.5, -6, -125.5),
}

local SIDE_TP_HIGH = {
    [1] = Vector3.new(-502.5, 14, 245.67),
    [2] = Vector3.new(-502.5, 14, 138.67),
    [3] = Vector3.new(-502.5, 14, 31.67),
    [4] = Vector3.new(-502.5, 14, -75),
    [5] = Vector3.new(-316.5, 14, 195.5),
    [6] = Vector3.new(-316.5, 14, 88.5),
    [7] = Vector3.new(-316.5, 14, -18.5),
    [8] = Vector3.new(-316.5, 14, -125.5),
}

local TeleportData = {
    bodyController = nil,
}
local bodyController = TeleportData.bodyController
local floatActive = State.floatActive

RunService.Heartbeat:Connect(function()
    if State.floatActive and TeleportData.bodyController and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then TeleportData.bodyController.Position = Vector3.new(hrp.Position.X, TeleportData.bodyController.Position.Y, hrp.Position.Z) end
    end
end)

local function getClosestBaseIdx(pos)
    local closest, dist = 1, math.huge
    for i, basePos in pairs(BASES_LOW) do
        local d = (Vector2.new(pos.X, pos.Z) - Vector2.new(basePos.X, basePos.Z)).Magnitude
        if d < dist then dist = d; closest = i end
    end
    return closest
end

local isTpMoving = State.isTpMoving

_G._isTargetPlotUnlocked = function(plotName)
    local ok, res = pcall(function()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local targetPlot = plots:FindFirstChild(plotName)
        if not targetPlot then return false end
        local unlockFolder = targetPlot:FindFirstChild("Unlock")
        if not unlockFolder then return true end
        local unlockItems = {}
        for _, item in pairs(unlockFolder:GetChildren()) do
            local pos = nil
            if item:IsA("Model") then pcall(function() pos = item:GetPivot().Position end)
            elseif item:IsA("BasePart") then pos = item.Position end
            if pos then table.insert(unlockItems, {Object = item, Height = pos.Y}) end
        end
        table.sort(unlockItems, function(a, b) return a.Height < b.Height end)
        if #unlockItems == 0 then return true end
        local floor1Door = unlockItems[1].Object
        for _, desc in ipairs(floor1Door:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then return false end
        end
        for _, child in ipairs(floor1Door:GetChildren()) do
            if child:IsA("ProximityPrompt") and child.Enabled then return false end
        end
        return true
    end)
    return ok and res or false
end

local function getPlotOwner(plot)
    if not plot then return "Unknown" end
    
    local Packages = ReplicatedStorage:FindFirstChild("Packages")
    if Packages then
        local ok, Sync = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
        if ok and Sync then
            local ok2, channel = pcall(function() return Sync:Get(plot.Name) end)
            if ok2 and channel then
                local owner = channel:Get("Owner")
                if owner then
                    if typeof(owner) == "Instance" and owner:IsA("Player") then
                        return owner.DisplayName
                    elseif type(owner) == "table" and owner.Name then
                        local player = Players:FindFirstChild(owner.Name)
                        if player then return player.DisplayName end
                        return owner.Name
                    end
                end
            end
        end
    end
    
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
        if surfaceGui then
            local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
            if label then
                local text = label.Text
                local nickname = text:match("^(.-)'") or text
                return nickname
            end
        end
    end
    
    return "Unknown"
end

local function triggerUnlockAtCurrentLevel()
    if not Config.AutoUnlockOnSteal then return end
    
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local playerY = hrp.Position.Y
    local targetLevel = nil
    local targetY = nil
    
    if playerY > -4 and playerY <= 9.8 then
        targetLevel = 1
        targetY = -2
    elseif playerY > 9.8 and playerY <= 26.8 then
        targetLevel = 2
        targetY = 15
    elseif playerY > 26.8 then
        targetLevel = 3
        targetY = 27
    end
    
    if not targetY then return end
    
    local function findUnlockAtLevel(yLevel)
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil, nil end
        
        local closestPrompt = nil
        local closestDist = math.huge
        local closestPlot = nil
        
        for _, plot in ipairs(plots:GetChildren()) do
            local unlockFolder = plot:FindFirstChild("Unlock")
            if unlockFolder then
                for _, item in ipairs(unlockFolder:GetChildren()) do
                    local part = nil
                    local pos = nil
                    
                    if item:IsA("Model") then
                        pcall(function() pos = item:GetPivot().Position end)
                        part = item:FindFirstChildWhichIsA("BasePart", true)
                    elseif item:IsA("BasePart") then
                        pos = item.Position
                        part = item
                    end
                    
                    if pos and part and math.abs(pos.Y - yLevel) < 5 then
                        for _, desc in ipairs(part:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and desc.Enabled then
                                local dist = (hrp.Position - pos).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closestPrompt = desc
                                    closestPlot = plot
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
        
        return closestPrompt, closestPlot
    end
    
    local prompt, plot = findUnlockAtLevel(targetY)
    
    if prompt then
        local levelName = targetLevel == 1 and "Basement" or (targetLevel == 2 and "Main" or "Roof")
        local ownerName = getPlotOwner(plot)
        
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            pcall(function()
                prompt:InputBegan(Enum.UserInputType.MouseButton1)
                task.wait(0.05)
                prompt:InputEnded(Enum.UserInputType.MouseButton1)
            end)
        end 
        ShowNotification("Auto Unlock", "Unlocked " .. ownerName .. "'s " .. levelName)
    end
end

local lastStealState = false
LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    
    if isStealing and not lastStealState and Config.AutoUnlockOnSteal then
        task.wait(0.3)
        triggerUnlockAtCurrentLevel()
    end
    
    lastStealState = isStealing
end)

local function findClosestUnlockAtY(targetY)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, nil end
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil, nil, nil end
    
    local closestPrompt = nil
    local closestDist = math.huge
    local closestPlot = nil
    
    for _, plot in ipairs(plots:GetChildren()) do
        local isMyPlot = false
        local sync = require(ReplicatedStorage.Packages.Synchronizer)
        local channel = sync:Get(plot.Name)
        if channel then
            local owner = channel:Get("Owner")
            if owner then
                if (typeof(owner) == "Instance" and owner == LocalPlayer) or
                   (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId) then
                    isMyPlot = true
                end
            end
        end
        
        if isMyPlot then
            local unlockFolder = plot:FindFirstChild("Unlock")
            if unlockFolder then
                for _, item in ipairs(unlockFolder:GetChildren()) do
                    local part = nil
                    local pos = nil
                    
                    if item:IsA("Model") then
                        pcall(function() pos = item:GetPivot().Position end)
                        part = item:FindFirstChildWhichIsA("BasePart", true)
                    elseif item:IsA("BasePart") then
                        pos = item.Position
                        part = item
                    end
                    
                    if pos and part and math.abs(pos.Y - targetY) < 5 then
                        for _, desc in ipairs(part:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and desc.Enabled then
                                local dist = (hrp.Position - pos).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closestPrompt = desc
                                    closestPlot = plot
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPrompt, closestDist, closestPlot
end

LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    
    if isStealing and Config.AutoUnlockOnSteal then
        task.wait(0.5)
        enhancedAutoUnlockOnSteal()
    end
end)

local originalRunTP = runTP
runTP = function()
    originalRunTP()
        if Config.AutoUnlockOnSteal then
        task.wait(0.5)
        enhancedAutoUnlockOnSteal()
    end
end

if _G.runTP then
    local originalGlobalSnipe = _G.runTP
    _G.runTP = function()
        originalGlobalSnipe()
        if Config.AutoUnlockOnSteal then
            task.wait(0.5)
            enhancedAutoUnlockOnSteal()
        end
    end
end

task.spawn(function()
    local currentConnection = nil
    _G.AntiDieConnection = nil
    _G.AntiDieDisabled = false

    local function setupAntiDie()
        if currentConnection then
            currentConnection:Disconnect()
            currentConnection = nil
            _G.AntiDieConnection = nil
        end
        if _G.AntiDieDisabled then return end

        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        currentConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if _G.AntiDieDisabled then return end
            if humanoid.Health <= 0 then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        _G.AntiDieConnection = currentConnection
    end
    setupAntiDie()
    _G.setupAntiDie = setupAntiDie
    

    LocalPlayer.CharacterAdded:Connect(function()
        for _ = 1, 40 do
            task.wait(0.05)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                break
            end
        end
        setupAntiDie()
    end)

    task.spawn(function()
        while true do
            task.wait(0.3)
            if not _G.AntiDieDisabled then
            setupAntiDie()
            end
        end
    end)
end)

local resetting = false

local function executeReset()
    if resetting then return end
    resetting = true
    
    local oldAntiDie = _G.AntiDieDisabled
    _G.AntiDieDisabled = true
    
    if _G.AntiDieConnection then
        pcall(function() _G.AntiDieConnection:Disconnect() end)
        _G.AntiDieConnection = nil
    end
    
    local p = game:GetService("Players").LocalPlayer
    local c = p.Character
    if not c then 
        _G.AntiDieDisabled = oldAntiDie
        resetting = false
        return 
    end
    
    local h = c:FindFirstChild("HumanoidRootPart")
    local u = c:FindFirstChild("Humanoid")
    
    if not h or not u then 
        _G.AntiDieDisabled = oldAntiDie
        resetting = false
        return 
    end
    
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        end
    end
    
    local cam = workspace.CurrentCamera
    local cf = cam.CFrame
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = cf
    
    h.AssemblyLinearVelocity = Vector3.new(0, 0, 141610368)
    
    h.CFrame = h.CFrame + Vector3.new(0, 0, 1180086)
    h.CFrame = h.CFrame + Vector3.new(0, 0, 1180086)
    
    u.Health = 0
    
    for i = 1, 40 do
        h.CFrame = h.CFrame + Vector3.new(0, 0, 590043)
    end
    
    h.CFrame = h.CFrame + Vector3.new(0, 0, -20061468)
    
    task.wait(0.7)
    cam.CameraType = Enum.CameraType.Custom
    
    task.spawn(function()
        task.wait(0.7)
        _G.AntiDieDisabled = oldAntiDie
        if oldAntiDie == false and _G.setupAntiDie then
            _G.setupAntiDie()
        end
    end)
    
    resetting = false
end

_G.executeReset = executeReset

local balloonResetTriggered = false
local balloonResetCooldown = 0

task.spawn(function()
    local balloonPhrase = 'ran "balloon" on you'
    
    PlayerGui.DescendantAdded:Connect(function(desc)
        if not Config.AutoResetOnBalloon then return end
        if balloonResetTriggered then return end
        if not (desc:IsA("TextLabel") or desc:IsA("TextButton")) then return end
        
        local txt = desc.Text
        if txt and string.find(txt, balloonPhrase, 1, true) then
            balloonResetTriggered = true
            executeReset()
            task.delay(2, function()
                balloonResetTriggered = false
            end)
        end
    end)
    
    task.wait(1)
    if Config.AutoResetOnBalloon then
        for _, desc in ipairs(PlayerGui:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                local txt = desc.Text
                if txt and string.find(txt, balloonPhrase, 1, true) then
                    balloonResetTriggered = true
                    executeReset()
                    break
                end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    resetting = false
end)

task.spawn(function()
    PlayerGui.DescendantAdded:Connect(function(desc)
        if not Config.AutoKickOnSteal then return end
        if not (desc:IsA("TextLabel") or desc:IsA("TextButton")) then return end
        
        local txt = desc.Text
        if txt and string.find(txt, "You stole", 1, true) then
            game:Shutdown()
        end
    end)
end)

local tempPlatform = nil

local function createTempPlatform()
    if tempPlatform then
        pcall(function() tempPlatform:Destroy() end)
        tempPlatform = nil
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local footY = hrp.Position.Y - 3
    
    tempPlatform = Instance.new("Part")
    tempPlatform.Name = "TempPlatform"
    tempPlatform.Size = Vector3.new(8, 0.2, 8)
    tempPlatform.Position = Vector3.new(hrp.Position.X, footY - 0.75, hrp.Position.Z)
    tempPlatform.Anchored = true
    tempPlatform.CanCollide = true
    tempPlatform.Transparency = 0.5
    tempPlatform.CanTouch = false
    tempPlatform.Parent = workspace
    
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = true
        hum.JumpPower = 0
    end    
    return true
end

local function destroyTempPlatform()
    if tempPlatform and tempPlatform.Parent then
        pcall(function() tempPlatform:Destroy() end)
        tempPlatform = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.AutoRotate = true
            hum.JumpPower = 50
        end
    end
end

local function riseToY(hrp, targetY)
    if not hrp then return end
    local MAX_TIME = 3.0
    local start = os.clock()

    while hrp.Parent and hrp.Position.Y < targetY do
        local dist = targetY - hrp.Position.Y
        local speed = math.clamp(dist * 20, 280, 310)
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, speed, hrp.AssemblyLinearVelocity.Z)
        if os.clock() - start > MAX_TIME then
            break
        end
        RunService.Heartbeat:Wait()
    end

    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
end

local function runTP()
    if State.isTpMoving then return end
    if State.carpetSpeedEnabled then
        setCarpetSpeed(false)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = "OFF"
            _carpetStatusLabel.TextColor3 = Theme.Error
        end
    end
    if not SharedState.SelectedPetData then 
        return 
    end
    local targetPetData = SharedState.SelectedPetData.animalData
    if not targetPetData then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    State.isTpMoving = true
    isTpMoving = State.isTpMoving
    local Controls = getControls()
    Controls:Disable()
    local targetPart = findAdorneeGlobal(targetPetData)
    if not targetPart then 
        State.isTpMoving = false
        isTpMoving = State.isTpMoving
        Controls:Enable()
        return 
    end
    local exactPos = targetPart.Position
    local isSecondFloor = exactPos.Y > 10 and exactPos.Y <= 25
    local isThirdFloor = exactPos.Y > 25
    local offsetPos = Vector3.new(exactPos.X, exactPos.Y - 6.5, exactPos.Z)
    local teleportTarget = Pathfinding:GetTeleportTarget(targetPart)
    if not teleportTarget then 
        State.isTpMoving = false
        isTpMoving = State.isTpMoving
        Controls:Enable()
        return 
    end
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    if carpet then
        hum:EquipTool(carpet)
        task.wait()
    end
    local isUnlocked = _G._isTargetPlotUnlocked and _G._isTargetPlotUnlocked(targetPetData.plot) or false
    local function getPlotIndexFromName(plotName)
        local plotNum = tonumber(plotName)
        if plotNum and plotNum >= 1 and plotNum <= 8 then
            return plotNum
        end
        return getClosestBaseIdx(exactPos)
    end
    local plotIndex = getPlotIndexFromName(targetPetData.plot)
    local secondFloorMethod = Config.TpSettings.SecondFloorMethod or "Low"
    local offsetClear = not Pathfinding:CheckCollision(hrp.Position, offsetPos, char)
    local directClear = not Pathfinding:CheckCollision(hrp.Position, teleportTarget, char)
    TeleportBeam:Update(teleportTarget, directClear)
    if offsetClear and (isSecondFloor or isThirdFloor) then
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = CFrame.new(offsetPos)
        task.wait()
        createTempPlatform()
        local moved = false
        local floatMoveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}
            for _, k in ipairs(keys) do
                if input.KeyCode == k then moved = true; break end
            end
            if input.UserInputType == Enum.UserInputType.Touch then moved = true end
            if moved then destroyTempPlatform() end
        end)
        local timeout = 0
        while not LocalPlayer:GetAttribute("Stealing") and not moved and timeout < 200 do
            if hrp.Position.Y > targetPart.Position.Y + 5 then
                destroyTempPlatform()
                local basePos = BASES_FACE[plotIndex]
                local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                hrp.CFrame = CFrame.new(offsetPosition, basePos)
                break
            end
            timeout = timeout + 1
            task.wait(0.05)
        end
        destroyTempPlatform()
        if floatMoveConn then floatMoveConn:Disconnect() end
        State.isTpMoving = false
        Controls:Enable()
        TeleportBeam:Hide()
        return
    end
    if directClear then
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local basePos = BASES_FACE[plotIndex]
        local offsetPosition = teleportTarget + (targetPart.CFrame.LookVector * 3.5)
        hrp.CFrame = CFrame.new(offsetPosition, basePos)
        State.isTpMoving = false
        Controls:Enable()
        TeleportBeam:Hide()
        return
    end
    local currentX = hrp.Position.X
    local currentY = hrp.Position.Y
    local currentZ = hrp.Position.Z
    local isOutsideStandardXRange = currentX > -290 or currentX < -530
    if isOutsideStandardXRange then
        local possibleZValues = {165, 60, -50}
        local closestZ = nil
        local minDist = math.huge
        for _, zVal in ipairs(possibleZValues) do
            local dist = math.abs(currentZ - zVal)
            if dist < minDist then
                minDist = dist
                closestZ = zVal
            end
        end
        if closestZ then
            hrp.CFrame = CFrame.new(Vector3.new(currentX, currentY, closestZ))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            task.wait()
            currentX = hrp.Position.X
            currentY = hrp.Position.Y
            currentZ = hrp.Position.Z
            task.wait(0.1)
        end
    end
    if not (currentX > -470 and currentX < -345) then
        local distToLeft = math.abs(currentX - (-450))
        local distToRight = math.abs(currentX - (-365))
        local targetX = distToLeft < distToRight and -450 or -365
        local targetPos = Vector3.new(targetX, currentY, currentZ)
        for i = 1, 6 do
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            if (hrp.Position - targetPos).Magnitude > 3 then
                hrp.CFrame = CFrame.new(targetPos)
                task.wait(0.1)
            end
        end
        currentY = hrp.Position.Y
    end
    if Config.TeleportStyle == "Front" then
        local faceX = (plotIndex <= 4) and -1000 or 1000
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
        task.wait()
        hrp.AssemblyLinearVelocity = Vector3.zero
        if hum and hum.Parent then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait()
        end
        hrp.CFrame = CFrame.new(-410, 23, hrp.Position.Z)
        local isLowMethod = (not isSecondFloor) or (isSecondFloor and secondFloorMethod == "Low")
            task.wait(isLowMethod and 0.015 or 0.015)
            riseToY(hrp, 40)
            local function getShiftedZ(baseZ)
            local offset = 20
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return baseZ end
                
            local currentZ = hrp.Position.Z
            local leftPos = baseZ - offset
            local rightPos = baseZ + offset
                
            if math.abs(currentZ - leftPos) < math.abs(currentZ - rightPos) then
                return leftPos
            else
                return rightPos
            end
        end     
            if not isSecondFloor and not isThirdFloor then
            local basePos = BASES_LOW[plotIndex]
            local shiftedBasePos = Vector3.new(basePos.X, basePos.Y, getShiftedZ(basePos.Z))
            hrp.CFrame = CFrame.new(shiftedBasePos)
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            task.wait()
            if isUnlocked then
                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
                task.wait(0.15)
                local basePos = BASES_FACE[plotIndex]
                local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                hrp.CFrame = CFrame.new(offsetPosition, basePos)
            else
                local bestSpot = CLONE_POSITIONS_FLOOR[1]
                local minDst = math.huge
                for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
                    local d = (targetPart.Position - v).Magnitude
                    if d < minDst then
                        minDst = d
                        bestSpot = v
                    end
                end
                local shiftedClonePos = Vector3.new(bestSpot.X, bestSpot.Y, getShiftedZ(bestSpot.Z))
                task.wait(0.01)
                hrp.CFrame = CFrame.new(shiftedClonePos)
                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
                task.wait(0.05)
                walk(0.05)
                task.wait(0.13 + (Config.TpSettings.PreCloneDelayFrontLow or 0))
                _G.cloneFailed = false
                Clone()
                while _G.isCloning do task.wait() end
                if _G.cloneFailed then
                    _G.cloneFailed = false
                    State.isTpMoving = false
                    Controls:Enable()
                    TeleportBeam:Hide()
                    return
                end
                hum:EquipTool(carpet)
                task.wait(Config.TpSettings.PostCloneDelay or 0)
                local basePos = BASES_FACE[plotIndex]
                local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                hrp.CFrame = CFrame.new(offsetPosition, basePos)
            end
        elseif isSecondFloor and secondFloorMethod == "Low" then
            local basePos = BASES_LOW[plotIndex]
            local shiftedBasePos = Vector3.new(basePos.X, basePos.Y, getShiftedZ(basePos.Z))
            
            hrp.CFrame = CFrame.new(shiftedBasePos)
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            task.wait()
            if isUnlocked then
                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
                task.wait(0.15)
                local underPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 6.5, targetPart.Position.Z)
                hrp.CFrame = CFrame.new(underPos)
                task.wait()        
                createTempPlatform()
                local moved = false
                local floatMoveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                        Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}
                    for _, k in ipairs(keys) do
                        if input.KeyCode == k then moved = true; break end
                    end
                    if input.UserInputType == Enum.UserInputType.Touch then moved = true end
                    if moved then destroyTempPlatform() end
                end)
                local timeout = 0
                while not LocalPlayer:GetAttribute("Stealing") and not moved and timeout < 200 do
                    if hrp.Position.Y > targetPart.Position.Y + 5 then
                        destroyTempPlatform()
                        local basePos = BASES_FACE[plotIndex]
                        local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                        hrp.CFrame = CFrame.new(offsetPosition, basePos)
                        break
                    end
                    timeout = timeout + 1
                    task.wait(0.05)
                end
                destroyTempPlatform()
                if floatMoveConn then floatMoveConn:Disconnect() end
            else
                local bestSpot = CLONE_POSITIONS_FLOOR[1]
                local minDst = math.huge
                for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
                    local d = (targetPart.Position - v).Magnitude
                    if d < minDst then
                        minDst = d
                        bestSpot = v
                    end
                end
                local shiftedClonePos = Vector3.new(bestSpot.X, bestSpot.Y, getShiftedZ(bestSpot.Z))
                task.wait(0.01)
                hrp.CFrame = CFrame.new(shiftedClonePos)
                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
                _G.cloneFailed = false
                task.wait(0.05)
                walk(0.05)
                task.wait(0.13 + (Config.TpSettings.PreCloneDelayFrontLow or 0))
                Clone()
                while _G.isCloning do task.wait() end
                if _G.cloneFailed then
                    _G.cloneFailed = false
                    State.isTpMoving = false
                    Controls:Enable()
                    TeleportBeam:Hide()
                    return
                end
                hum:EquipTool(carpet)
                task.wait(Config.TpSettings.PostCloneDelay or 0)
                local underPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 6.5, targetPart.Position.Z)
                hrp.CFrame = CFrame.new(underPos)
                task.wait()        
                createTempPlatform()
                local moved = false
                local floatMoveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                        Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}
                    for _, k in ipairs(keys) do
                        if input.KeyCode == k then moved = true; break end
                    end
                    if input.UserInputType == Enum.UserInputType.Touch then moved = true end
                    if moved then destroyTempPlatform() end
                end)
                local timeout = 0
                while not LocalPlayer:GetAttribute("Stealing") and not moved and timeout < 200 do
                    if hrp.Position.Y > targetPart.Position.Y + 5 then
                        destroyTempPlatform()
                        local basePos = BASES_FACE[plotIndex]
                        local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                        hrp.CFrame = CFrame.new(offsetPosition, basePos)
                        break
                    end
                    timeout = timeout + 1
                    task.wait(0.05)
                end
                destroyTempPlatform()
                if floatMoveConn then floatMoveConn:Disconnect() end
            end
        else
            local targetPlot = Workspace.Plots:FindFirstChild(targetPetData.plot)
            local signPart = nil
            if targetPlot then
                local signModel = targetPlot:FindFirstChild("PlotSign")
                if signModel then
                    signPart = signModel:IsA("BasePart") and signModel or signModel:FindFirstChildWhichIsA("BasePart", true)
                end
            end
            local signCF = signPart.CFrame
            local LEFT = -signCF.RightVector
            local FORWARD = signCF.LookVector
            local BACK = -FORWARD
            local frontPoint = signPart.Position + (FORWARD * 15)
            local backPoint  = signPart.Position + (BACK * 15)
            local myPos = hrp.Position
            local distFront = (Vector3.new(frontPoint.X, 0, frontPoint.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
            local distBack  = (Vector3.new(backPoint.X,  0, backPoint.Z)  - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
            local chosen = (distFront < distBack) and frontPoint or backPoint
            local isHighFloor = isThirdFloor or (isSecondFloor and secondFloorMethod == "High")
            local targetY = isHighFloor and (signPart.Position.Y + 4) or -4.8
            local tpPos = Vector3.new(chosen.X, targetY, chosen.Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.lookAt(tpPos, tpPos + LEFT)
            hrp.AssemblyLinearVelocity = Vector3.zero
            waitUntilHeartbeat(function()
                return hrp and hrp.Parent
                    and (hrp.Position - tpPos).Magnitude <= 2
                    and hum and hum.FloorMaterial ~= Enum.Material.Air
            end, 3)
            task.wait(0.058)
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -2.5)
            walk(0.05)
            task.wait(0.065)
            _G.cloneFailed = false
            Clone()
            while _G.isCloning do task.wait() end
            if _G.cloneFailed then
                _G.cloneFailed = false
                State.isTpMoving = false
                Controls:Enable()
                TeleportBeam:Hide()
                return
            end
            hum:EquipTool(carpet)
            task.wait(Config.TpSettings.PostCloneDelay or 0)
            if isSecondFloor then
                local basePos = BASES_FACE[plotIndex]
                local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                hrp.CFrame = CFrame.new(offsetPosition, basePos)
            elseif isThirdFloor then
                local underPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 6.5, targetPart.Position.Z)
                hrp.CFrame = CFrame.new(underPos)
                task.wait()       
                createTempPlatform()
                local moved = false
                local floatMoveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                        Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}
                    for _, k in ipairs(keys) do
                        if input.KeyCode == k then moved = true; break end
                    end
                    if input.UserInputType == Enum.UserInputType.Touch then moved = true end
                    if moved then destroyTempPlatform() end
                end)
                local timeout = 0
                while not LocalPlayer:GetAttribute("Stealing") and not moved and timeout < 200 do
                    if hrp.Position.Y > targetPart.Position.Y + 5 then
                        destroyTempPlatform()
                        local basePos = BASES_FACE[plotIndex]
                        local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                        hrp.CFrame = CFrame.new(offsetPosition, basePos)
                        break
                    end
                    timeout = timeout + 1
                    task.wait(0.05)
                end
                destroyTempPlatform()
                if floatMoveConn then floatMoveConn:Disconnect() end
            end
        end
        Controls:Enable()
        State.isTpMoving = false
        TeleportBeam:Hide()
        return
    end
    
    if Config.TeleportStyle == "Side" then
        local sideZ = nil
        if plotIndex == 1 then
            sideZ = 259
        elseif plotIndex == 2 then
            sideZ = 165
        elseif plotIndex == 3 then
            sideZ = 60
        elseif plotIndex == 4 then
            sideZ = -50
        elseif plotIndex == 5 then
            sideZ = 165
        elseif plotIndex == 6 then
            sideZ = 60
        elseif plotIndex == 7 then
            sideZ = -50
        elseif plotIndex == 8 then
            sideZ = -140
        end
        local faceZ = (plotIndex <= 4) and -500 or 500
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(hrp.Position.X, hrp.Position.Y, faceZ))
        task.wait()
        local jumpPoint = Vector3.new(-410, 28, sideZ)
        hrp.CFrame = CFrame.new(jumpPoint)
        task.wait()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local targetHeight = 45
        local startTime = tick()
        while hrp.Position.Y < targetHeight and tick() - startTime < 3 do
            local dist = targetHeight - hrp.Position.Y
            local speed = math.clamp(dist * 20, 280, 310)
            hrp.AssemblyLinearVelocity = Vector3.new(0, speed, 0)
            task.wait(0.015)
        end
        local useLowSide = (not isSecondFloor and not isThirdFloor) or (isSecondFloor and secondFloorMethod == "Low")
        local sideBasePos = useLowSide and SIDE_TP_LOW[plotIndex] or SIDE_TP_HIGH[plotIndex]
        hrp.CFrame = CFrame.new(sideBasePos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(hrp.Position.X, hrp.Position.Y, faceZ))
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.17 + (Config.TpSettings.PreCloneDelaySide or 0))
        _G.cloneFailed = false
        Clone()
        while _G.isCloning do task.wait() end
        if _G.cloneFailed then
            _G.cloneFailed = false
            State.isTpMoving = false
            Controls:Enable()
            TeleportBeam:Hide()
            return
        end
        hum:EquipTool(carpet)
        task.wait(Config.TpSettings.PostCloneDelay or 0)
        
        if isSecondFloor and useLowSide then
            local underPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 6.5, targetPart.Position.Z)
            hrp.CFrame = CFrame.new(underPos)
            task.wait()       
            createTempPlatform()
            local moved = false
            local floatMoveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                local movementKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}
                for _, key in ipairs(movementKeys) do
                    if input.KeyCode == key then moved = true; break end
                end
                if input.UserInputType == Enum.UserInputType.Touch then moved = true end
                if moved then destroyTempPlatform() end
            end)
            local timeout = 0
            while not LocalPlayer:GetAttribute("Stealing") and not moved and timeout < 200 do
                if hrp.Position.Y > targetPart.Position.Y + 5 then
                    destroyTempPlatform()
                    local basePos = BASES_FACE[plotIndex]
                    local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                    hrp.CFrame = CFrame.new(offsetPosition, basePos)
                    break
                end
                timeout = timeout + 1
                task.wait(0.05)
            end
            destroyTempPlatform()
            if floatMoveConn then floatMoveConn:Disconnect() end
        elseif isSecondFloor and not useLowSide then
            local basePos = BASES_FACE[plotIndex]
            local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
            hrp.CFrame = CFrame.new(offsetPosition, basePos)
        elseif isThirdFloor then
            local underPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 6.5, targetPart.Position.Z)
            hrp.CFrame = CFrame.new(underPos)
            task.wait()       
            createTempPlatform()
            local moved = false
            local floatMoveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                local movementKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}
                for _, key in ipairs(movementKeys) do
                    if input.KeyCode == key then moved = true; break end
                end
                if input.UserInputType == Enum.UserInputType.Touch then moved = true end
                if moved then destroyTempPlatform() end
            end)
            local timeout = 0
            while not LocalPlayer:GetAttribute("Stealing") and not moved and timeout < 200 do
                if hrp.Position.Y > targetPart.Position.Y + 5 then
                    destroyTempPlatform()
                    local basePos = BASES_FACE[plotIndex]
                    local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
                    hrp.CFrame = CFrame.new(offsetPosition, basePos)
                    break
                end
                timeout = timeout + 1
                task.wait(0.05)
            end
            destroyTempPlatform()
            if floatMoveConn then floatMoveConn:Disconnect() end
        else
            local basePos = BASES_FACE[plotIndex]
            local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
            hrp.CFrame = CFrame.new(offsetPosition, basePos)
        end
        
        Controls:Enable()
        State.isTpMoving = false
        TeleportBeam:Hide()
        return
    end
end

task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local Utils = ReplicatedStorage:WaitForChild("Utils")
    
    local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils = require(Utils:WaitForChild("NumberUtils"))
    
    local isStealing = false
    local baseSnapshot = {}
    
    local baseCache = {}
    local function updateBaseCache()
        baseCache = {}
        for _, plot in ipairs(Workspace.Plots:GetChildren()) do
            local channel = Synchronizer:Get(plot.Name)
            if channel then
                local owner = channel:Get("Owner")
                if owner then
                    local ownerId = (typeof(owner) == "Instance" and owner:IsA("Player")) and owner.UserId or 
                                   (type(owner) == "table" and owner.UserId) or nil
                    baseCache[plot.Name] = {
                        plot = plot,
                        ownerId = ownerId,
                        position = plot:GetPivot().Position
                    }
                end
            end
        end
    end
    
loopTimers.baseCache = 0
Heartbeat:Connect(function(dt)
    loopTimers.baseCache = loopTimers.baseCache + dt
    if loopTimers.baseCache >= 2 then
        loopTimers.baseCache = 0
        updateBaseCache()
    end
end)
    updateBaseCache()
    
    local function GetMyPlot()
        for plotName, data in pairs(baseCache) do
            if data.ownerId == LocalPlayer.UserId then
                return data.plot
            end
        end
        return nil
    end
    
    local function GetPetsOnPlot(plot)
        local pets = {}
        if not plot then return pets end
        
        local channel = Synchronizer:Get(plot.Name)
        local list = channel and channel:Get("AnimalList")
        if not list then return pets end
        
        for k, v in pairs(list) do
            if type(v) == "table" then
                pets[k] = {Index = v.Index, Mutation = v.Mutation, Traits = v.Traits}
            end
        end
        return pets
    end

    local function directTeleportToTarget(targetPetData)
        if not targetPetData then 
            runTP()
            return
        end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        
        local targetPart = findAdorneeGlobal(targetPetData)
        if not targetPart then return end
        
        local teleportTarget = Pathfinding:GetTeleportTarget(targetPart)
        if not teleportTarget then return end
        
        local clearPath = not Pathfinding:CheckCollision(hrp.Position, teleportTarget, char)
        
        if clearPath then
            
            local carpetName = Config.TpSettings.Tool
            local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
            if carpet then 
                hum:EquipTool(carpet)
                task.wait(0.1)
            end
            
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            local targetPosition = targetPart.Position
            local isSecondFloor = targetPosition.Y > 10
            local isThirdFloor = targetPosition.Y > 25
            
            if isSecondFloor or isThirdFloor then
                
                local underPos = Vector3.new(targetPosition.X, targetPosition.Y - 6.5, targetPosition.Z)
                hrp.CFrame = CFrame.new(underPos)
                task.wait()
task.wait()        
createTempPlatform()

local moved = false
local floatMoveConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right}
    for _, k in ipairs(keys) do
        if input.KeyCode == k then moved = true; break end
    end
    if input.UserInputType == Enum.UserInputType.Touch then moved = true end
    if moved then destroyTempPlatform() end
end)

local timeout = 0
while not LocalPlayer:GetAttribute("Stealing") and not moved and timeout < 200 do
    if hrp.Position.Y > targetPart.Position.Y + 5 then
        destroyTempPlatform()
local basePos = BASES_FACE[plotIndex]
local offsetPosition = targetPart.Position + (targetPart.CFrame.LookVector * 3.5)
hrp.CFrame = CFrame.new(offsetPosition, basePos)
        break
    end
    timeout = timeout + 1
    task.wait(0.05)
end

destroyTempPlatform()
if floatMoveConn then floatMoveConn:Disconnect() end
            else
                hrp.CFrame = CFrame.new(teleportTarget)
            end
        end
    end

    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        local state = LocalPlayer:GetAttribute("Stealing")
        
        if state then
            isStealing = true
            baseSnapshot = GetPetsOnPlot(GetMyPlot())
            
            if Config.AutoUnlockOnSteal then
                task.spawn(enhancedAutoUnlockOnSteal)
            end
            
            if Config.AutoInvisDuringSteal and _G.toggleInvisibleSteal and not _G.invisibleStealEnabled then
                _G.toggleInvisibleSteal()
            end
            
        else
            if not isStealing then return end
            isStealing = false
            
            if Config.AutoInvisDuringSteal and _G.toggleInvisibleSteal and _G.invisibleStealEnabled then
                _G.toggleInvisibleSteal()
            end
            
            local currentPets = GetPetsOnPlot(GetMyPlot())
            local stoleSomething = false
            
            for slot, data in pairs(currentPets) do
                local old = baseSnapshot[slot]
                if not old or old.Index ~= data.Index or old.Mutation ~= data.Mutation then
                    stoleSomething = true
                    break
                end
            end
            
            if not stoleSomething and Config.AutoTPOnFailedSteal then
                directTeleportToTarget(targetPetData)
            end
        end
    end)
end)

task.spawn(function()
    local autoBuyActive = false
    local autoBuyTarget = nil
    local autoBuyTargetPart = nil
    local autoBuyConnection = nil

    local function findClosestPurchaseAnimal()
        local char = LocalPlayer.Character
        if not char then return nil, nil end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, nil end
        
        local closestDist = math.huge
        local closestAnimal = nil
        local closestPart = nil
        local radius = Config.AutoBuyRadius or 30
        
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText == "Purchase" then
                local part = desc.Parent
                if part:IsA("Attachment") and part.Parent then
                    part = part.Parent
                end
                
                if part:IsA("BasePart") then
                    local animal = part.Parent
                    if animal and animal:IsA("Model") then
                        local dist = (hrp.Position - part.Position).Magnitude
                        if dist <= radius and dist < closestDist then
                            closestDist = dist
                            closestAnimal = animal
                            closestPart = part
                        end
                    end
                end
            end
        end
        
        return closestAnimal, closestPart
    end

    local function isAnimalInMyBase(animal)
        if not animal then return false end
        
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return false end
        
        local hrp = animal:FindFirstChild("HumanoidRootPart") or animal:FindFirstChildWhichIsA("BasePart")
        if not hrp then return false end
        
        for _, plot in ipairs(plots:GetChildren()) do
            local plotPos = plot:GetPivot().Position
            local playerPos = hrp.Position
            
            if math.abs(playerPos.X - plotPos.X) < 23 and
               math.abs(playerPos.Z - plotPos.Z) < 25 and
               playerPos.Y > -7.10 and playerPos.Y < 44.90 then
                
                local sync = require(ReplicatedStorage.Packages.Synchronizer)
                local channel = sync:Get(plot.Name)
                if channel then
                    local owner = channel:Get("Owner")
                    if owner then
                        if (typeof(owner) == "Instance" and owner == LocalPlayer) or
                           (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId) then
                            return true
                        end
                    end
                end
            end
        end
        
        return false
    end

    local function interact()
        if not autoBuyTarget then return end
        
        for _, desc in ipairs(autoBuyTarget:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                if fireproximityprompt then
                    fireproximityprompt(desc)
                end
                break
            end
        end
    end

    local function startAutoBuy()
        if not Config.AutoBuy then return end
        
        if autoBuyActive then 
            stopAutoBuy()
            return
        end
        
        local animal, part = findClosestPurchaseAnimal()
        
        if not animal or not part then
            Config.AutoBuy = false
            SaveConfig()
            if autoBuyToggleFrame then
                autoBuyToggleFrame.BackgroundColor3 = Theme.SurfaceHighlight
                if autoBuyToggleDot then
                    autoBuyToggleDot.Position = UDim2.new(0, 2, 0.5, -9)
                end
            end
            return
        end
        
        autoBuyTarget = animal
        autoBuyTargetPart = part
        autoBuyActive = true
        
        if autoBuyToggleFrame then
            autoBuyToggleFrame.BackgroundColor3 = Theme.Success
            if autoBuyToggleDot then
                autoBuyToggleDot.Position = UDim2.new(1, -20, 0.5, -9)
            end
        end
        
        if autoBuyConnection then
            autoBuyConnection:Disconnect()
            autoBuyConnection = nil
        end
        
        autoBuyConnection = RunService.Heartbeat:Connect(function()
            if not Config.AutoBuy or not autoBuyActive then
                stopAutoBuy()
                return
            end
            
            if not autoBuyTarget or not autoBuyTarget.Parent then
                stopAutoBuy()
                return
            end
            
            if isAnimalInMyBase(autoBuyTarget) then
                stopAutoBuy()
                return
            end
            
            local newPart = autoBuyTarget:FindFirstChild("HumanoidRootPart") or 
                           autoBuyTarget:FindFirstChildWhichIsA("BasePart")
            if newPart then
                autoBuyTargetPart = newPart
            end
            
            if not autoBuyTargetPart then
                stopAutoBuy()
                return
            end
            
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local targetPos = autoBuyTargetPart.Position
                    hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + 6, targetPos.Z)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
            
            interact()
        end)
    end

    local function stopAutoBuy()
        if not autoBuyActive then return end
        
        autoBuyActive = false
        autoBuyTarget = nil
        autoBuyTargetPart = nil
        
        if autoBuyConnection then
            autoBuyConnection:Disconnect()
            autoBuyConnection = nil
        end
        
        if autoBuyToggleFrame then
            autoBuyToggleFrame.BackgroundColor3 = Theme.SurfaceHighlight
            if autoBuyToggleDot then
                autoBuyToggleDot.Position = UDim2.new(0, 2, 0.5, -9)
            end
        end
        
        Config.AutoBuy = false
        SaveConfig()
    end

    local animPlaying = false
    local tracks = {}
    local clone, oldRoot, hip, connection
    local folderConnections = {}
    local SINK_AMOUNT = 5
    local serverGhosts = {}
    local ghostEnabled = true
    local lagbackCallCount = 0
    local lagbackWindowStart = 0
    local lastLagbackTime = 0
    local errorOrbActive = false
    local errorOrb = nil
    local errorOrbConnection = nil

    local function clearErrorOrb()
        if errorOrb and errorOrb.Parent then errorOrb:Destroy() end
        errorOrb = nil; errorOrbActive = false
        if errorOrbConnection then errorOrbConnection:Disconnect(); errorOrbConnection = nil end
    end

    local function createErrorOrb()
        if errorOrbActive then return end
        errorOrbActive = true
        for _, ghost in pairs(serverGhosts) do if ghost and ghost.Parent then ghost:Destroy() end end
        serverGhosts = {}
        local sg = Instance.new("ScreenGui")
        sg.Name = "ErrorOrbGui"; sg.ResetOnSpawn = false
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0, 500, 0, 60)
        fr.Position = UDim2.new(0.5, -250, 0.3, 0)
        fr.BackgroundTransparency = 1; fr.BorderSizePixel = 0; fr.Parent = sg
        local l1 = Instance.new("TextLabel")
        l1.Size = UDim2.new(1, 0, 0.5, 0); l1.BackgroundTransparency = 1
        l1.Text = "ERROR CAUSED BY PLAYER DEATH"
        l1.TextColor3 = Color3.fromRGB(255, 0, 0)
        l1.TextStrokeTransparency = 0; l1.TextStrokeColor3 = Color3.new(0, 0, 0)
        l1.Font = Enum.Font.SourceSansBold; l1.TextScaled = true; l1.Parent = fr
        local l2 = Instance.new("TextLabel")
        l2.Size = UDim2.new(1, 0, 0.5, 0); l2.Position = UDim2.new(0, 0, 0.5, 0)
        l2.BackgroundTransparency = 1; l2.Text = "MUST RESET TO FIX ERROR"
        l2.TextColor3 = Color3.fromRGB(255, 0, 0)
        l2.TextStrokeTransparency = 0; l2.TextStrokeColor3 = Color3.new(0, 0, 0)
        l2.Font = Enum.Font.SourceSansBold; l2.TextScaled = true; l2.Parent = fr
        errorOrb = sg
    end

    local function createServerGhost(position)
        if not ghostEnabled or errorOrbActive then return end
        local now = tick()
        if now - lastLagbackTime < 0.05 then return end
        lastLagbackTime = now
        if now - lagbackWindowStart > 1 then lagbackCallCount = 0; lagbackWindowStart = now end
        lagbackCallCount = lagbackCallCount + 1
        if lagbackCallCount >= 7 then createErrorOrb(); return end
        for _, g in pairs(serverGhosts) do if g and g.Parent then g:Destroy() end end
        serverGhosts = {}
        local sg = Instance.new("ScreenGui")
        sg.Name = "LagbackNotification"; sg.ResetOnSpawn = false
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        local sl = Instance.new("TextLabel")
        sl.Size = UDim2.new(0, 500, 0, 30); sl.Position = UDim2.new(0.5, -250, 0.15, 0)
        sl.BackgroundTransparency = 1; sl.Text = ""
        sl.TextColor3 = Color3.fromRGB(255, 0, 0)
        sl.TextStrokeTransparency = 0; sl.TextStrokeColor3 = Color3.new(0, 0, 0)
        sl.Font = Enum.Font.SourceSansBold; sl.TextScaled = true; sl.Parent = sg
        local sw = Instance.new("TextLabel")
        sw.Size = UDim2.new(0, 650, 0, 25); sw.Position = UDim2.new(0.5, -325, 0.15, 32)
        sw.BackgroundTransparency = 1
        sw.Text = ""
        sw.TextColor3 = Color3.fromRGB(200, 200, 200)
        sw.TextStrokeTransparency = 0; sw.TextStrokeColor3 = Color3.new(0, 0, 0)
        sw.Font = Enum.Font.SourceSansBold; sw.TextScaled = true; sw.Parent = sg
        task.delay(1.5, function() if sg and sg.Parent then sg:Destroy() end end)
        local ghost = Instance.new("Part")
        ghost.Name = "LagbackGhost"; ghost.Shape = Enum.PartType.Ball
        ghost.Size = Vector3.new(3, 3, 3); ghost.Color = Color3.fromRGB(255, 0, 0)
        ghost.Material = Enum.Material.Glass; ghost.Transparency = 0.3
        ghost.CanCollide = false; ghost.Anchored = true; ghost.CastShadow = false
        ghost.Position = position + Vector3.new(0, 5, 0); ghost.Parent = Workspace.CurrentCamera
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 400, 0, 60); bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.AlwaysOnTop = true; bb.Parent = ghost
        local bl = Instance.new("TextLabel")
        bl.Size = UDim2.new(1, 0, 0, 25); bl.BackgroundTransparency = 1
        bl.Text = ""; bl.TextColor3 = Color3.fromRGB(255, 0, 0)
        bl.TextStrokeTransparency = 0; bl.TextStrokeColor3 = Color3.new(0, 0, 0)
        bl.Font = Enum.Font.SourceSansBold; bl.TextScaled = true; bl.Parent = bb
        local bw = Instance.new("TextLabel")
        bw.Size = UDim2.new(1, 0, 0, 25); bw.Position = UDim2.new(0, 0, 0, 25)
        bw.BackgroundTransparency = 1
        bw.Text = ""
        bw.TextColor3 = Color3.fromRGB(200, 200, 200)
        bw.TextStrokeTransparency = 0; bw.TextStrokeColor3 = Color3.new(0, 0, 0)
        bw.Font = Enum.Font.SourceSansBold; bw.TextScaled = true; bw.Parent = bb
        table.insert(serverGhosts, ghost)
    end

    local function clearAllGhosts()
        for _, ghost in pairs(serverGhosts) do pcall(function() if ghost and ghost.Parent then ghost:Destroy() end end) end
        serverGhosts = {}; clearErrorOrb(); lagbackCallCount = 0; lastLagbackTime = 0
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then for _, gui in pairs(pg:GetChildren()) do if gui.Name == "LagbackNotification" then gui:Destroy() end end end
        end)
        pcall(function() if Workspace.CurrentCamera then for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c.Name == "LagbackGhost" then c:Destroy() end end end end)
        pcall(function() for _, c in pairs(Workspace:GetDescendants()) do if c.Name == "LagbackGhost" then c:Destroy() end end end)
    end

    local function removeFolders()
        local pf = Workspace:FindFirstChild(LocalPlayer.Name)
        if not pf then return end
        local dr = pf:FindFirstChild("DoubleRig")
        if dr then
            local rr = dr:FindFirstChild("HumanoidRootPart") or dr:FindFirstChildWhichIsA("BasePart")
            if rr and ghostEnabled then createServerGhost(rr.Position) end
            dr:Destroy()
        end
        local cs = pf:FindFirstChild("Constraints")
        if cs then cs:Destroy() end
        local conn = pf.ChildAdded:Connect(function(child)
            if child.Name == "DoubleRig" then
                task.defer(function()
                    local rr = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
                    if rr and ghostEnabled then createServerGhost(rr.Position) end
                    child:Destroy()
                end)
            elseif child.Name == "Constraints" then child:Destroy() end
        end)
        table.insert(folderConnections, conn)
    end

    local function doClone()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
            hip = character.Humanoid.HipHeight
            oldRoot = character:FindFirstChild("HumanoidRootPart")
            if not oldRoot or not oldRoot.Parent then return false end
            for _, c in pairs(oldRoot:GetChildren()) do
                if c:IsA("Attachment") and (c.Name:find("Beam") or c.Name:find("Attach")) then c:Destroy() end
            end
            for _, c in pairs(oldRoot:GetChildren()) do if c:IsA("Beam") then c:Destroy() end end
            local tmp = Instance.new("Model"); tmp.Parent = game
            character.Parent = tmp
            clone = oldRoot:Clone(); clone.Parent = character
            oldRoot.Parent = Workspace.CurrentCamera
            clone.CFrame = oldRoot.CFrame; character.PrimaryPart = clone
            character.Parent = Workspace
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("Weld") or v:IsA("Motor6D") then
                    if v.Part0 == oldRoot then v.Part0 = clone end
                    if v.Part1 == oldRoot then v.Part1 = clone end
                end
            end
            tmp:Destroy(); return true
        end
        return false
    end

    local function revertClone()
        local character = LocalPlayer.Character
        if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character or character.Humanoid.Health <= 0 then return end
        local tmp = Instance.new("Model"); tmp.Parent = game
        character.Parent = tmp
        oldRoot.Parent = character; character.PrimaryPart = oldRoot
        character.Parent = Workspace; oldRoot.CanCollide = true
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("Motor6D") then
                if v.Part0 == clone then v.Part0 = oldRoot end
                if v.Part1 == clone then v.Part1 = oldRoot end
            end
        end
        if clone then local p = clone.CFrame; clone:Destroy(); clone = nil; oldRoot.CFrame = p end
        oldRoot = nil
        if character and character.Humanoid then character.Humanoid.HipHeight = hip end
        clearAllGhosts()
    end

    local function animationTrickery()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
            local anim = Instance.new("Animation")
            anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
            local humanoid = character.Humanoid
            local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
            local animTrack = animator:LoadAnimation(anim)
            animTrack.Priority = Enum.AnimationPriority.Action4
            animTrack:Play(0, 1, 0); anim:Destroy()
            table.insert(tracks, animTrack)
            animTrack.Stopped:Connect(function() if animPlaying then animationTrickery() end end)
            task.delay(0, function()
                animTrack.TimePosition = 0.7
                task.delay(0.3, function() if animTrack then animTrack:AdjustSpeed(math.huge) end end)
            end)
        end
    end

    local function turnOff()
        clearAllGhosts()
        if not animPlaying then return end
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        animPlaying = false
        _G.invisibleStealEnabled = false
        for _, t in pairs(tracks) do pcall(function() t:Stop() end) end
        tracks = {}
        if connection then connection:Disconnect(); connection = nil end
        for _, c in ipairs(folderConnections) do if c then c:Disconnect() end end
        folderConnections = {}
        revertClone()
        clearAllGhosts()
        if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
        if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
        if updateVisualState then updateVisualState(false) end
    end

    local function turnOn()
        if animPlaying then return end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        animPlaying = true
        _G.invisibleStealEnabled = true
        if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, true) end
        if updateVisualState then updateVisualState(true) end
        tracks = {}
        removeFolders()
        local success = doClone()
        if success then
            task.wait(0.05)
            animationTrickery()
            task.defer(function()
                if _G.resetBrainrotBeam then pcall(_G.resetBrainrotBeam) end
                if _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
                task.wait(0.1)
                if _G.updateBrainrotBeam then pcall(_G.updateBrainrotBeam) end
                if _G.createPlotBeam then pcall(_G.createPlotBeam) end
            end)
            local lastSetPosition = nil
            local skipFrames = 5
            connection = RunService.PreSimulation:Connect(function()
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and oldRoot then
                    local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if skipFrames > 0 then
                            skipFrames = skipFrames - 1
                            lastSetPosition = nil
                        elseif lastSetPosition and ghostEnabled then
                            local currentPos = oldRoot.Position
                            local jumpDist = (currentPos - lastSetPosition).Magnitude
                            if jumpDist > 3 and not _G.RecoveryInProgress then
                                lastSetPosition = nil
                                createServerGhost(currentPos)
                                if _G.AutoRecoverLagback and _G.toggleInvisibleSteal then
                                    _G.RecoveryInProgress = true
                                    task.spawn(function()
                                        pcall(_G.toggleInvisibleSteal); task.wait(0.5)
                                        pcall(_G.toggleInvisibleSteal); _G.RecoveryInProgress = false
                                    end)
                                end
                            end
                        end
                        if clone then clone.CanCollide = false end
                        for _, c in pairs(oldRoot:GetChildren()) do
                            if c:IsA("Attachment") or c:IsA("Beam") then c:Destroy() end
                        end
                        local rotAngle = _G.InvisStealAngle or 180
                        local sa = (_G.SinkSliderValue or 5) * 0.5
                        local cf = root.CFrame - Vector3.new(0, sa, 0)
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(rotAngle), 0, 0)
                        oldRoot.AssemblyLinearVelocity = root.AssemblyLinearVelocity
                        oldRoot.CanCollide = false
                        lastSetPosition = oldRoot.Position
                    end
                end
            end)
        end
    end

    local function handleAutoInvisOnSteal()
        local wasStealingForInvis = false
        local invisWasEnabledBefore = false
        local autoEnabledInvis = false
        
        task.wait(1)
        while task.wait(0.1) do
            if _G.AutoInvisDuringSteal == false then
                wasStealingForInvis = false
                autoEnabledInvis = false
            else
                local isStealing = LocalPlayer:GetAttribute("Stealing")
                if isStealing and not wasStealingForInvis then
                    invisWasEnabledBefore = _G.invisibleStealEnabled or false
                    if not _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                        task.delay(0.25, function()
                            if LocalPlayer:GetAttribute("Stealing") and not _G.invisibleStealEnabled then
                                pcall(_G.toggleInvisibleSteal)
                                autoEnabledInvis = true
                            end
                        end)
                    end
                end
                if not isStealing and autoEnabledInvis and _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                    pcall(_G.toggleInvisibleSteal)
                    autoEnabledInvis = false
                end
                wasStealingForInvis = isStealing
            end
        end
    end
    
    task.spawn(handleAutoInvisOnSteal)

    local stealSpeedEnabled = false
    local STEAL_SPEED = Config.StealSpeed or 25.5
    local stealConn = nil

    local function doDisableStealSpeed()
        stealSpeedEnabled = false
        if stealConn then stealConn:Disconnect(); stealConn=nil end
    end

    local function doEnableStealSpeed()
        stealSpeedEnabled = true
        if stealConn then stealConn:Disconnect(); stealConn=nil end
        stealConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * STEAL_SPEED, hrp.AssemblyLinearVelocity.Y, md.Z * STEAL_SPEED)
            end
        end)
    end

    local function toggleStealSpeed()
        if stealSpeedEnabled then
            doDisableStealSpeed()
        else
            doEnableStealSpeed()
        end
    end
    _G.toggleStealSpeed = toggleStealSpeed

    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        if not Config.AutoStealSpeed then return end
        local hasSteal = (LocalPlayer:GetAttribute("Stealing") == true)
        if hasSteal and not stealSpeedEnabled then
            doEnableStealSpeed()
        elseif not hasSteal and stealSpeedEnabled then
            doDisableStealSpeed()
        end
    end)

    task.spawn(function()
    local proxTPRing = nil
    local proxTPGlow = nil
    local proxTPActive = false
    local proxTPMonitorConnection = nil
    local carpetForceConnection = nil
    
    local function createProxTPRing()
        if proxTPRing then pcall(function() proxTPRing:Destroy() end) end
        local ring = Instance.new("Part")
        ring.Name = "ProxTPRing"
        ring.Anchored = true
        ring.CanCollide = false
        ring.Shape = Enum.PartType.Cylinder
        ring.Color = Color3.fromRGB(255, 50, 50)
        ring.Transparency = 0.4
        ring.Material = Enum.Material.Neon
        ring.CastShadow = false
        ring.Parent = workspace
        local glow = Instance.new("Part")
        glow.Name = "ProxTPGlow"
        glow.Anchored = true
        glow.CanCollide = false
        glow.Shape = Enum.PartType.Cylinder
        glow.Color = Color3.fromRGB(255, 100, 100)
        glow.Transparency = 0.7
        glow.Material = Enum.Material.Neon
        glow.CastShadow = false
        glow.Parent = ring
        return ring, glow
    end
    
    local function updateProxTPRing()
        if not proxTPActive then
            if proxTPRing then pcall(function() proxTPRing:Destroy() end) end
            proxTPRing = nil
            proxTPGlow = nil
            return
        end
        if not proxTPRing then proxTPRing, proxTPGlow = createProxTPRing() end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local radius = Config.ProxTPRange or 20
        local diameter = radius * 2
        proxTPRing.Size = Vector3.new(0.15, diameter, diameter)
        proxTPRing.CFrame = (hrp.CFrame * CFrame.new(0, -3, 0)) * CFrame.Angles(0, 0, math.rad(90))
        if proxTPGlow then
            proxTPGlow.Size = Vector3.new(0.08, diameter + 0.5, diameter + 0.5)
            proxTPGlow.CFrame = proxTPRing.CFrame
        end
        local pulse = (math.sin(tick() * 5) + 1) / 2
        proxTPRing.Color = Color3.fromRGB(255, 50 + math.floor(50 * pulse), 50 + math.floor(50 * pulse))
        if proxTPGlow then
            proxTPGlow.Color = Color3.fromRGB(255, 100 + math.floor(100 * pulse), 100 + math.floor(100 * pulse))
        end
    end
    
    local function equipCarpet()
        local carpetName = Config.TpSettings.Tool
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return false end
        local carpet = char:FindFirstChild(carpetName) or LocalPlayer.Backpack:FindFirstChild(carpetName)
        if carpet and hum then
            hum:EquipTool(carpet)
            return true
        end
        return false
    end
    
    local function startCarpetForce()
        if carpetForceConnection then carpetForceConnection:Disconnect() end
        carpetForceConnection = RunService.Heartbeat:Connect(function()
            if not proxTPActive then return end
            local carpetName = Config.TpSettings.Tool
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if not hum then return end
            local hasCarpet = char:FindFirstChild(carpetName) ~= nil
            if not hasCarpet then
                local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName)
                if carpet then
                    hum:EquipTool(carpet)
                end
            end
        end)
    end
    
    local function teleportToPodium(podium)
        if not podium or not podium.Parent then return end
        
        local base = podium:FindFirstChild("Base")
        local spawn = base and base:FindFirstChild("Spawn")
        local targetPos = spawn and spawn.Position or (base and base.Position) or podium.Position
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        equipCarpet()
        task.wait()
        
        hrp.CFrame = CFrame.new(targetPos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    
    local function startProxTP()
        if proxTPActive then return end
        proxTPActive = true
        
        equipCarpet()
        startCarpetForce()
        
        local trackedPodiums = {}
        
        proxTPMonitorConnection = RunService.Heartbeat:Connect(function()
            if not proxTPActive then return end
            updateProxTPRing()
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local playerPos = hrp.Position
            local playerY = playerPos.Y
            
            local plots = Workspace:FindFirstChild("Plots")
            if not plots then return end
            
            local closestPlot = nil
            local closestDist = Config.ProxTPRange or 20
            
            for _, plot in ipairs(plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local signPos = sign:IsA("BasePart") and sign.Position or (sign.PrimaryPart and sign.PrimaryPart.Position)
                    if signPos then
                        local dist = (playerPos - signPos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPlot = plot
                        end
                    end
                end
            end
            
            if not closestPlot then 
                for podium, data in pairs(trackedPodiums) do
                    if data.highlight then data.highlight:Destroy() end
                end
                trackedPodiums = {}
                return 
            end
            
            local podiumFolder = closestPlot:FindFirstChild("AnimalPodiums")
            if not podiumFolder then return end
            
            local cacheMap = {}
            local cache = SharedState.AllAnimalsCache
            if cache then
                for _, pet in ipairs(cache) do
                    cacheMap[pet.uid] = pet
                end
            end
            
            local currentPodiums = {}
            
            for _, podium in ipairs(podiumFolder:GetChildren()) do
                local slotNum = tonumber(podium.Name)
                if slotNum then
                    local base = podium:FindFirstChild("Base")
                    local spawn = base and base:FindFirstChild("Spawn")
                    local podiumPos = spawn and spawn.Position or (base and base.Position) or podium.Position
                    
                    local horizontalDist = (Vector2.new(playerPos.X, playerPos.Z) - Vector2.new(podiumPos.X, podiumPos.Z)).Magnitude
                    local verticalDiff = math.abs(playerY - podiumPos.Y)
                    local range = Config.ProxTPRange or 20
                    
                    if horizontalDist <= range and verticalDiff <= 8 then
                        local uid = closestPlot.Name .. "_" .. tostring(slotNum)
                        local hasAnimal = cacheMap[uid] ~= nil
                        
                        if hasAnimal then
                            currentPodiums[podium] = true
                            
                            if not trackedPodiums[podium] then
                                local highlight = Instance.new("SelectionBox")
                                highlight.Name = "ProxTPHighlight"
                                highlight.Color3 = Color3.fromRGB(255, 50, 50)
                                highlight.LineThickness = 0.05
                                highlight.Transparency = 0.3
                                highlight.Adornee = podium
                                highlight.Parent = podium
                                
                                trackedPodiums[podium] = {
                                    highlight = highlight,
                                    uid = uid,
                                    hadAnimal = true
                                }
                            else
                                trackedPodiums[podium].hadAnimal = true
                            end
                        end
                    end
                end
            end
            
            for podium, data in pairs(trackedPodiums) do
                local stillHasAnimal = cacheMap[data.uid] ~= nil
                
                if data.hadAnimal and not stillHasAnimal then
                    teleportToPodium(podium)
                    ShowNotification("Proximity TP", "Teleported to sold brainrot")
                    
                    if data.highlight then data.highlight:Destroy() end
                    trackedPodiums[podium] = nil
                else
                    data.hadAnimal = stillHasAnimal
                    
                    if not currentPodiums[podium] then
                        if data.highlight then data.highlight:Destroy() end
                        trackedPodiums[podium] = nil
                    end
                end
            end
        end)
    end
    
    local function stopProxTP()
        proxTPActive = false
        
        if proxTPMonitorConnection then
            proxTPMonitorConnection:Disconnect()
            proxTPMonitorConnection = nil
        end
        
        if carpetForceConnection then
            carpetForceConnection:Disconnect()
            carpetForceConnection = nil
        end
        
        if proxTPRing then pcall(function() proxTPRing:Destroy() end) end
        proxTPRing = nil
        proxTPGlow = nil
        
        local plots = Workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                local podiumFolder = plot:FindFirstChild("AnimalPodiums")
                if podiumFolder then
                    for _, podium in ipairs(podiumFolder:GetChildren()) do
                        local highlight = podium:FindFirstChild("ProxTPHighlight")
                        if highlight then highlight:Destroy() end
                    end
                end
            end
        end
    end

    local invisGui = Instance.new("ScreenGui")
    invisGui.Name = "SolanaInvisPanel"
    invisGui.ResetOnSpawn = false
    invisGui.Parent = PlayerGui
    invisGui.Enabled = Config.ShowInvisPanel

    local iFrame = Instance.new("Frame", invisGui)
    iFrame.Size = UDim2.new(0, 280 * MOBILE_SCALE, 0, 500 * MOBILE_SCALE)
    iFrame.Position = UDim2.new(Config.Positions.InvisPanel.X, 0, Config.Positions.InvisPanel.Y, 0)
    iFrame.BackgroundColor3 = Theme.Background
    iFrame.BackgroundTransparency = 0.08
    Instance.new("UICorner", iFrame).CornerRadius = UDim.new(0, 12 * MOBILE_SCALE)
    AddAnimatedBorder(iFrame, 1.5)

    AddMobileMinimize(iFrame, "FUNCTION")

    local iHeader = Instance.new("Frame", iFrame)
    iHeader.Size = UDim2.new(1, 0, 0, 40 * MOBILE_SCALE)
    iHeader.BackgroundTransparency = 1
    MakeDraggable(iHeader, iFrame, "InvisPanel")

    local iTitle = Instance.new("TextLabel", iHeader)
    iTitle.Size = UDim2.new(1,0,1,0)
    iTitle.Position = UDim2.new(0,0,0,0)
    iTitle.BackgroundTransparency = 1
    iTitle.Text = "Control Panel"
    MakeText(iTitle, true)
    iTitle.TextSize = 18 * MOBILE_SCALE
    iTitle.TextColor3 = Theme.TextPrimary
    iTitle.TextXAlignment = Enum.TextXAlignment.Center

    local iContainer = Instance.new("Frame", iFrame)
    iContainer.Size = UDim2.new(1, -20 * MOBILE_SCALE, 1, -45 * MOBILE_SCALE)
    iContainer.Position = UDim2.new(0, 10 * MOBILE_SCALE, 0, 40 * MOBILE_SCALE)
    iContainer.BackgroundTransparency = 1
    local iLayout = Instance.new("UIListLayout", iContainer)
    iLayout.Padding = UDim.new(0, 4 * MOBILE_SCALE)
    iLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createToggleRow(parent, text, defaultValue, callback)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 28 * MOBILE_SCALE)
        row.BackgroundTransparency = 1
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        MakeText(lbl, true)
        lbl.TextSize = 12 * MOBILE_SCALE
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local isOn = defaultValue or false
        local toggleFrame = Instance.new("Frame", row)
        toggleFrame.Size = UDim2.new(0, 44 * MOBILE_SCALE, 0, 22 * MOBILE_SCALE)
        toggleFrame.Position = UDim2.new(1, -54 * MOBILE_SCALE, 0.5, -11 * MOBILE_SCALE)
        toggleFrame.BackgroundColor3 = isOn and Theme.Success or Theme.SurfaceHighlight
        toggleFrame.BorderSizePixel = 0
        Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1,0)
        
        local toggleDot = Instance.new("Frame", toggleFrame)
        toggleDot.Size = UDim2.new(0, 18 * MOBILE_SCALE, 0, 18 * MOBILE_SCALE)
        toggleDot.Position = isOn and UDim2.new(1, -20 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE) or UDim2.new(0, 2 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE)
        toggleDot.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(1,0)
        
        local toggleBtn = Instance.new("TextButton", toggleFrame)
        toggleBtn.Size = UDim2.new(1,0,1,0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""

        toggleBtn.MouseButton1Click:Connect(function()
            isOn = not isOn
            local newPos = isOn and UDim2.new(1, -20 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE) or UDim2.new(0, 2 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE)
            local newColor = isOn and Theme.Success or Theme.SurfaceHighlight
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = newPos}):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
            if callback then
                callback(isOn)
            end
        end)

        return row, toggleFrame, toggleDot, isOn
    end

    local row1, invisToggleFrame, invisToggleDot, isInvisOn = createToggleRow(iContainer, "Toggle Invis", _G.invisibleStealEnabled or false, function(on)
        if _G.toggleInvisibleSteal then
            if on ~= _G.invisibleStealEnabled then
                pcall(_G.toggleInvisibleSteal)
            end
        end
    end)

    local row2, fixToggleFrame, fixToggleDot, isFixOn = createToggleRow(iContainer, "Auto Fix Lagback", _G.AutoRecoverLagback or false, function(on)
        _G.AutoRecoverLagback = on
        Config.AutoRecoverLagback = on
        SaveConfig()
    end)

    local row3, autoInvisToggleFrame, autoInvisToggleDot, isAutoInvisOn = createToggleRow(iContainer, "Auto Invis on Steal", Config.AutoInvisDuringSteal or false, function(on)
        Config.AutoInvisDuringSteal = on
        _G.AutoInvisDuringSteal = on
        SaveConfig()
    end)

    local row4, autoSpeedToggleFrame, autoSpeedToggleDot, isAutoSpeedOn = createToggleRow(iContainer, "Auto Steal Speed", Config.AutoStealSpeed or false, function(on)
        Config.AutoStealSpeed = on
        SaveConfig()
    end)

    local autoBuyToggleFrame, autoBuyToggleDot
    
    local row4_5, frame, dot, isOn = createToggleRow(iContainer, "Auto Buy Nearest", Config.AutoBuy or false, function(on)
        Config.AutoBuy = on
        SaveConfig()
        
        if on then
            startAutoBuy()
        else
            stopAutoBuy()
        end
    end)
    
    autoBuyToggleFrame = frame
    autoBuyToggleDot = dot

    local rowKick, kickFrame, kickDot, isKickOn = createToggleRow(iContainer, "Kick on Steal", Config.AutoKickOnSteal or false, function(on)
        Config.AutoKickOnSteal = on
        SaveConfig()
    end)

local autoGrabActive = false
local autoGrabConnection = nil
local grabCooldown = false
local stealStartTime = nil
local kickTask = nil
local controlsDisabled = false
local controlsDisableTimer = nil
local grabDisabledUntil = 0
local lastGrabTime = 0

local function disableControls(seconds)
    if controlsDisabled then return end
    local Controls = getControls()
    if not Controls then return end
    
    controlsDisabled = true
    Controls:Disable()
    
    if controlsDisableTimer then task.cancel(controlsDisableTimer) end
    controlsDisableTimer = task.delay(seconds, function()
        Controls:Enable()
        controlsDisabled = false
        controlsDisableTimer = nil
    end)
end

local function teleportToGrabPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    
    if not equipCarpet() then
        return false
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local part = prompt.Parent
    if part:IsA("Attachment") then part = part.Parent end
    if not part or not part:IsA("BasePart") then return false end
    
    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    disableControls(3)
    
    return true
end

local lastGrabFire = {}
local kickWindowActive = false
local kickWindowTimer = nil
local grabKickTask = nil

local function canFireGrab(prompt)
    local now = tick()
    
    if now - lastGrabTime < 0.1 then
        return false
    end
    
    local last = lastGrabFire[prompt]
    if last and (now - last) < 0.1 then
        return false
    end
    lastGrabFire[prompt] = now
    return true
end

local function isWithinGrabRadius(prompt)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local part = prompt.Parent
    if part:IsA("Attachment") then part = part.Parent end
    if not part or not part:IsA("BasePart") then return false end
    
    local dist = (hrp.Position - part.Position).Magnitude
    return dist <= 10
end

local function grabPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    if not prompt.Enabled then return end
    if not isWithinGrabRadius(prompt) then return end
    if not canFireGrab(prompt) then return end
    
    lastGrabTime = tick()
    
    kickWindowActive = true
    if kickWindowTimer then task.cancel(kickWindowTimer) end
    kickWindowTimer = task.delay(1, function()
        kickWindowActive = false
    end)
    
    if grabKickTask then task.cancel(grabKickTask) end
    grabKickTask = task.spawn(function()
        local startWait = tick()
        while tick() - startWait < 2 do
            local isStealing = LocalPlayer:GetAttribute("Stealing")
            if isStealing then
                task.wait(0.1)
                game:Shutdown()
                return
            end
            task.wait(0.05)
        end
        grabKickTask = nil
    end)
    
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        pcall(function()
            prompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait()
            prompt:InputEnded(Enum.UserInputType.MouseButton1)
        end)
    end
end

local scannedGrabPrompts = {}

local function scanAllGrabPrompts()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end
    
    for _, plot in ipairs(plots:GetChildren()) do
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            for _, podium in ipairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local attach = spawn:FindFirstChild("PromptAttachment")
                    if attach then
                        for _, prompt in ipairs(attach:GetChildren()) do
                            if prompt:IsA("ProximityPrompt") and prompt.ActionText == "Grab" then
                                scannedGrabPrompts[prompt] = true
                            end
                        end
                    end
                end
            end
        end
    end
end

local function startAutoGrab()
    if autoGrabActive then return end
    autoGrabActive = true
    grabCooldown = false
    stealStartTime = nil
    kickTask = nil
    grabDisabledUntil = 0
    lastGrabTime = 0
    
    scannedGrabPrompts = {}
    scanAllGrabPrompts()

    local youStoleConn
    youStoleConn = PlayerGui.DescendantAdded:Connect(function(desc)
        if not autoGrabActive then return end
        if not (desc:IsA("TextLabel") or desc:IsA("TextButton")) then return end
        
        local txt = desc.Text
        if txt and string.find(txt, "You stole", 1, true) then
            grabCooldown = true
            grabDisabledUntil = tick() + 0.28
            task.delay(0.18, function()
                grabCooldown = false
            end)
        end
    end)
            
    local promptConn
    promptConn = workspace.DescendantAdded:Connect(function(obj)
        if not autoGrabActive then return end
        if obj:IsA("ProximityPrompt") and obj.ActionText == "Grab" and obj.Enabled then
            scannedGrabPrompts[obj] = true
            
            if grabCooldown and not LocalPlayer:GetAttribute("Stealing") then
                teleportToGrabPrompt(obj)
                task.wait(0.3)
                grabPrompt(obj)
            end
        end
    end)

    autoGrabConnection = RunService.Heartbeat:Connect(function()
        if not autoGrabActive then return end
        
        local isStealing = LocalPlayer:GetAttribute("Stealing")
        
        if isStealing then
            return
        end
        
        if tick() < grabDisabledUntil then
            return
        end

        if math.random(1, 20) == 1 then
            scanAllGrabPrompts()
        end
        
        for prompt, _ in pairs(scannedGrabPrompts) do
            if prompt and prompt.Parent and prompt.Enabled then
                grabPrompt(prompt)
            else
                scannedGrabPrompts[prompt] = nil
            end
        end
    end)
    
    _G.autoGrabConnections = {youStoleConn, promptConn}
end

    local function stopAutoGrab()
        autoGrabActive = false
        grabCooldown = false
        stealStartTime = nil
        grabDisabledUntil = 0
        lastGrabTime = 0
        scannedGrabPrompts = {}
        
        if grabKickTask then
            task.cancel(grabKickTask)
            grabKickTask = nil
        end
        
        if controlsDisabled then
            local Controls = getControls()
            if Controls then Controls:Enable() end
            controlsDisabled = false
        end
        if controlsDisableTimer then
            task.cancel(controlsDisableTimer)
            controlsDisableTimer = nil
        end
        
        if kickTask then
            task.cancel(kickTask)
            kickTask = nil
        end
        
        if autoGrabConnection then
            autoGrabConnection:Disconnect()
            autoGrabConnection = nil
        end
        
        if _G.autoGrabConnections then
            for _, conn in ipairs(_G.autoGrabConnections) do
                if conn then conn:Disconnect() end
            end
            _G.autoGrabConnections = nil
        end
    end

    local rowGrab, grabFrame, grabDot, isGrabOn = createToggleRow(iContainer, "Auto Grab and Kick", false, function(on)
        if on then
            startAutoGrab()
        else
            stopAutoGrab()
        end
    end)
    
    local rowProxTP, proxTPToggleFrame, proxTPToggleDot, isProxTPOn = createToggleRow(iContainer, "Proximity TP", Config.ProxTPEnabled or false, function(on)
        Config.ProxTPEnabled = off
        SaveConfig()
        if on then
            startProxTP()
        else
            stopProxTP()
        end
    end)

    local stealSpeedRow = Instance.new("Frame", iContainer)
    stealSpeedRow.Size = UDim2.new(1, 0, 0, 45 * MOBILE_SCALE)
    stealSpeedRow.BackgroundTransparency = 1
    
    local stealSpeedLbl = Instance.new("TextLabel", stealSpeedRow)
    stealSpeedLbl.Size = UDim2.new(0.6, 0, 0, 20 * MOBILE_SCALE)
    stealSpeedLbl.Position = UDim2.new(0, 0, 0, 0)
    stealSpeedLbl.BackgroundTransparency = 1
    stealSpeedLbl.Text = "Steal Speed: " .. string.format("%.1f", STEAL_SPEED)
    MakeText(stealSpeedLbl, true)
    stealSpeedLbl.TextSize = 12 * MOBILE_SCALE
    stealSpeedLbl.TextColor3 = Theme.TextPrimary
    stealSpeedLbl.TextXAlignment = Enum.TextXAlignment.Left

    local stealSpeedVal = Instance.new("TextLabel", stealSpeedRow)
    stealSpeedVal.Size = UDim2.new(0, 50 * MOBILE_SCALE, 0, 20 * MOBILE_SCALE)
    stealSpeedVal.Position = UDim2.new(1, -60 * MOBILE_SCALE, 0, 0)
    stealSpeedVal.BackgroundTransparency = 1
    stealSpeedVal.Text = string.format("%.1f", STEAL_SPEED)
    MakeText(stealSpeedVal, true)
    stealSpeedVal.TextColor3 = Theme.Accent1
    stealSpeedVal.TextSize = 12 * MOBILE_SCALE
    stealSpeedVal.TextXAlignment = Enum.TextXAlignment.Right

    local stealSpeedSliderBg = Instance.new("Frame", stealSpeedRow)
    stealSpeedSliderBg.Size = UDim2.new(1, 0, 0, 5 * MOBILE_SCALE)
    stealSpeedSliderBg.Position = UDim2.new(0, 0, 0, 30 * MOBILE_SCALE)
    stealSpeedSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    stealSpeedSliderBg.BackgroundTransparency = 0.2
    Instance.new("UICorner", stealSpeedSliderBg).CornerRadius = UDim.new(1, 0)

    local stealSpeedFill = Instance.new("Frame", stealSpeedSliderBg)
    stealSpeedFill.BackgroundColor3 = Theme.Accent1
    stealSpeedFill.Size = UDim2.new((STEAL_SPEED - 5) / 95, 0, 1, 0)
    Instance.new("UICorner", stealSpeedFill).CornerRadius = UDim.new(1, 0)

    local stealSpeedKnob = Instance.new("Frame", stealSpeedSliderBg)
    stealSpeedKnob.Size = UDim2.new(0, 12 * MOBILE_SCALE, 0, 12 * MOBILE_SCALE)
    stealSpeedKnob.BackgroundColor3 = Theme.TextPrimary
    stealSpeedKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    stealSpeedKnob.Position = UDim2.new((STEAL_SPEED - 5) / 95, 0, 0.5, 0)
    Instance.new("UICorner", stealSpeedKnob).CornerRadius = UDim.new(1, 0)

    local stealSpeedDragging = false
    local function updateStealSpeedSlider(inputX)
        local pos = stealSpeedSliderBg.AbsolutePosition.X
        local size = stealSpeedSliderBg.AbsoluteSize.X
        local pct = math.clamp((inputX - pos) / size, 0, 1)
        local val = 5 + (pct * 95)
        val = math.floor(val * 10) / 10
        STEAL_SPEED = val
        Config.StealSpeed = val
        SaveConfig()
        stealSpeedFill.Size = UDim2.new(pct, 0, 1, 0)
        stealSpeedKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        stealSpeedLbl.Text = "Steal Speed: " .. string.format("%.1f", val)
        stealSpeedVal.Text = string.format("%.1f", val)
    end

    stealSpeedSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stealSpeedDragging = true
            updateStealSpeedSlider(input.Position.X)
        end
    end)

    stealSpeedKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stealSpeedDragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stealSpeedDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if stealSpeedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateStealSpeedSlider(input.Position.X)
        end
    end)

    local rotationRow = Instance.new("Frame", iContainer)
    rotationRow.Size = UDim2.new(1, 0, 0, 45 * MOBILE_SCALE)
    rotationRow.BackgroundTransparency = 1
    
    local rotationLbl = Instance.new("TextLabel", rotationRow)
    rotationLbl.Size = UDim2.new(0.6, 0, 0, 20 * MOBILE_SCALE)
    rotationLbl.Position = UDim2.new(0, 0, 0, 0)
    rotationLbl.BackgroundTransparency = 1
    rotationLbl.Text = "Invis Rotation: " .. Config.InvisStealAngle
    MakeText(rotationLbl, true)
    rotationLbl.TextSize = 12 * MOBILE_SCALE
    rotationLbl.TextColor3 = Theme.TextPrimary
    rotationLbl.TextXAlignment = Enum.TextXAlignment.Left

    local rotationVal = Instance.new("TextLabel", rotationRow)
    rotationVal.Size = UDim2.new(0, 50 * MOBILE_SCALE, 0, 20 * MOBILE_SCALE)
    rotationVal.Position = UDim2.new(1, -60 * MOBILE_SCALE, 0, 0)
    rotationVal.BackgroundTransparency = 1
    rotationVal.Text = tostring(Config.InvisStealAngle)
    MakeText(rotationVal, true)
    rotationVal.TextColor3 = Theme.Accent1
    rotationVal.TextSize = 12 * MOBILE_SCALE
    rotationVal.TextXAlignment = Enum.TextXAlignment.Right

    local rotationSliderBg = Instance.new("Frame", rotationRow)
    rotationSliderBg.Size = UDim2.new(1, 0, 0, 5 * MOBILE_SCALE)
    rotationSliderBg.Position = UDim2.new(0, 0, 0, 30 * MOBILE_SCALE)
    rotationSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    rotationSliderBg.BackgroundTransparency = 0.2
    Instance.new("UICorner", rotationSliderBg).CornerRadius = UDim.new(1, 0)

    local rotationFill = Instance.new("Frame", rotationSliderBg)
    rotationFill.BackgroundColor3 = Theme.Accent1
    rotationFill.Size = UDim2.new((Config.InvisStealAngle - 180) / 180, 0, 1, 0)
    Instance.new("UICorner", rotationFill).CornerRadius = UDim.new(1, 0)

    local rotationKnob = Instance.new("Frame", rotationSliderBg)
    rotationKnob.Size = UDim2.new(0, 12 * MOBILE_SCALE, 0, 12 * MOBILE_SCALE)
    rotationKnob.BackgroundColor3 = Theme.TextPrimary
    rotationKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    rotationKnob.Position = UDim2.new((Config.InvisStealAngle - 180) / 180, 0, 0.5, 0)
    Instance.new("UICorner", rotationKnob).CornerRadius = UDim.new(1, 0)

    local rotationDragging = false
    local function updateRotationSlider(inputX)
        local pos = rotationSliderBg.AbsolutePosition.X
        local size = rotationSliderBg.AbsoluteSize.X
        local pct = math.clamp((inputX - pos) / size, 0, 1)
        local val = 180 + (pct * 180)
        val = math.floor(val)
        Config.InvisStealAngle = val
        _G.InvisStealAngle = val
        SaveConfig()
        rotationFill.Size = UDim2.new(pct, 0, 1, 0)
        rotationKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        rotationLbl.Text = "Rotation: " .. val
        rotationVal.Text = tostring(val)
    end

    rotationSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            rotationDragging = true
            updateRotationSlider(input.Position.X)
        end
    end)

    rotationKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            rotationDragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            rotationDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if rotationDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateRotationSlider(input.Position.X)
        end
    end)

    local depthRow = Instance.new("Frame", iContainer)
    depthRow.Size = UDim2.new(1, 0, 0, 45 * MOBILE_SCALE)
    depthRow.BackgroundTransparency = 1
    
    local depthLbl = Instance.new("TextLabel", depthRow)
    depthLbl.Size = UDim2.new(0.6, 0, 0, 20 * MOBILE_SCALE)
    depthLbl.Position = UDim2.new(0, 0, 0, 0)
    depthLbl.BackgroundTransparency = 1
    depthLbl.Text = "Invis Depth: " .. string.format("%.1f", Config.SinkSliderValue)
    MakeText(depthLbl, true)
    depthLbl.TextSize = 12 * MOBILE_SCALE
    depthLbl.TextColor3 = Theme.TextPrimary
    depthLbl.TextXAlignment = Enum.TextXAlignment.Left

    local depthVal = Instance.new("TextLabel", depthRow)
    depthVal.Size = UDim2.new(0, 50 * MOBILE_SCALE, 0, 20 * MOBILE_SCALE)
    depthVal.Position = UDim2.new(1, -60 * MOBILE_SCALE, 0, 0)
    depthVal.BackgroundTransparency = 1
    depthVal.Text = string.format("%.1f", Config.SinkSliderValue)
    MakeText(depthVal, true)
    depthVal.TextColor3 = Theme.Accent1
    depthVal.TextSize = 12 * MOBILE_SCALE
    depthVal.TextXAlignment = Enum.TextXAlignment.Right

    local depthSliderBg = Instance.new("Frame", depthRow)
    depthSliderBg.Size = UDim2.new(1, 0, 0, 5 * MOBILE_SCALE)
    depthSliderBg.Position = UDim2.new(0, 0, 0, 30 * MOBILE_SCALE)
    depthSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    depthSliderBg.BackgroundTransparency = 0.2
    Instance.new("UICorner", depthSliderBg).CornerRadius = UDim.new(1, 0)

    local depthFill = Instance.new("Frame", depthSliderBg)
    depthFill.BackgroundColor3 = Theme.Accent1
    depthFill.Size = UDim2.new((Config.SinkSliderValue - 0.5) / 9.5, 0, 1, 0)
    Instance.new("UICorner", depthFill).CornerRadius = UDim.new(1, 0)

    local depthKnob = Instance.new("Frame", depthSliderBg)
    depthKnob.Size = UDim2.new(0, 12 * MOBILE_SCALE, 0, 12 * MOBILE_SCALE)
    depthKnob.BackgroundColor3 = Theme.TextPrimary
    depthKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    depthKnob.Position = UDim2.new((Config.SinkSliderValue - 0.5) / 9.5, 0, 0.5, 0)
    Instance.new("UICorner", depthKnob).CornerRadius = UDim.new(1, 0)

    local depthDragging = false
    local function updateDepthSlider(inputX)
        local pos = depthSliderBg.AbsolutePosition.X
        local size = depthSliderBg.AbsoluteSize.X
        local pct = math.clamp((inputX - pos) / size, 0, 1)
        local val = 0.5 + (pct * 9.5)
        val = math.floor(val * 10) / 10
        Config.SinkSliderValue = val
        _G.SinkSliderValue = val
        SaveConfig()
        depthFill.Size = UDim2.new(pct, 0, 1, 0)
        depthKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        depthLbl.Text = "Depth: " .. string.format("%.1f", val)
        depthVal.Text = string.format("%.1f", val)
    end

    depthSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            depthDragging = true
            updateDepthSlider(input.Position.X)
        end
    end)

    depthKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            depthDragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            depthDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if depthDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDepthSlider(input.Position.X)
        end
    end)
    
    local proxTPRangeRow = Instance.new("Frame", iContainer)
    proxTPRangeRow.Size = UDim2.new(1, 0, 0, 45 * MOBILE_SCALE)
    proxTPRangeRow.BackgroundTransparency = 1
    
    local proxTPRangeLbl = Instance.new("TextLabel", proxTPRangeRow)
    proxTPRangeLbl.Size = UDim2.new(0.6, 0, 0, 20 * MOBILE_SCALE)
    proxTPRangeLbl.Position = UDim2.new(0, 0, 0, 0)
    proxTPRangeLbl.BackgroundTransparency = 1
    proxTPRangeLbl.Text = "Prox TP Range: " .. (Config.ProxTPRange or 20)
    MakeText(proxTPRangeLbl, true)
    proxTPRangeLbl.TextSize = 12 * MOBILE_SCALE
    proxTPRangeLbl.TextColor3 = Theme.TextPrimary
    proxTPRangeLbl.TextXAlignment = Enum.TextXAlignment.Left

    local proxTPRangeVal = Instance.new("TextLabel", proxTPRangeRow)
    proxTPRangeVal.Size = UDim2.new(0, 50 * MOBILE_SCALE, 0, 20 * MOBILE_SCALE)
    proxTPRangeVal.Position = UDim2.new(1, -60 * MOBILE_SCALE, 0, 0)
    proxTPRangeVal.BackgroundTransparency = 1
    proxTPRangeVal.Text = tostring(Config.ProxTPRange or 20)
    MakeText(proxTPRangeVal, true)
    proxTPRangeVal.TextColor3 = Theme.Accent1
    proxTPRangeVal.TextSize = 12 * MOBILE_SCALE
    proxTPRangeVal.TextXAlignment = Enum.TextXAlignment.Right

    local proxTPRangeSliderBg = Instance.new("Frame", proxTPRangeRow)
    proxTPRangeSliderBg.Size = UDim2.new(1, 0, 0, 5 * MOBILE_SCALE)
    proxTPRangeSliderBg.Position = UDim2.new(0, 0, 0, 30 * MOBILE_SCALE)
    proxTPRangeSliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    proxTPRangeSliderBg.BackgroundTransparency = 0.2
    Instance.new("UICorner", proxTPRangeSliderBg).CornerRadius = UDim.new(1, 0)

    local proxTPRangeFill = Instance.new("Frame", proxTPRangeSliderBg)
    proxTPRangeFill.BackgroundColor3 = Theme.Accent1
    local rangeValue = (Config.ProxTPRange or 20) - 5
    proxTPRangeFill.Size = UDim2.new(rangeValue / 45, 0, 1, 0)
    Instance.new("UICorner", proxTPRangeFill).CornerRadius = UDim.new(1, 0)

    local proxTPRangeKnob = Instance.new("Frame", proxTPRangeSliderBg)
    proxTPRangeKnob.Size = UDim2.new(0, 12 * MOBILE_SCALE, 0, 12 * MOBILE_SCALE)
    proxTPRangeKnob.BackgroundColor3 = Theme.TextPrimary
    proxTPRangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    proxTPRangeKnob.Position = UDim2.new(rangeValue / 45, 0, 0.5, 0)
    Instance.new("UICorner", proxTPRangeKnob).CornerRadius = UDim.new(1, 0)

    local proxTPRangeDragging = false
    local function updateProxTPRangeSlider(inputX)
        local pos = proxTPRangeSliderBg.AbsolutePosition.X
        local size = proxTPRangeSliderBg.AbsoluteSize.X
        local pct = math.clamp((inputX - pos) / size, 0, 1)
        local val = 5 + (pct * 45)
        val = math.floor(val)
        Config.ProxTPRange = val
        SaveConfig()
        proxTPRangeFill.Size = UDim2.new(pct, 0, 1, 0)
        proxTPRangeKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        proxTPRangeLbl.Text = "Prox TP Range: " .. val
        proxTPRangeVal.Text = tostring(val)
    end

    proxTPRangeSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            proxTPRangeDragging = true
            updateProxTPRangeSlider(input.Position.X)
        end
    end)

    proxTPRangeKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            proxTPRangeDragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            proxTPRangeDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if proxTPRangeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateProxTPRangeSlider(input.Position.X)
        end
    end)

    Heartbeat:Connect(function()
        updateProxTPRing()
    end)

    local function updateVisualState(on)
        if invisToggleFrame then
            invisToggleFrame.BackgroundColor3 = on and Theme.Success or Theme.SurfaceHighlight
            invisToggleDot.Position = on and UDim2.new(1, -20 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE) or UDim2.new(0, 2 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE)
        end
    end

    _G.toggleInvisibleSteal = function()
        if animPlaying then turnOff() else turnOn() end
    end

    UserInputService.InputBegan:Connect(function(input)
        if UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == (_G.INVISIBLE_STEAL_KEY or Enum.KeyCode.I) then
            pcall(_G.toggleInvisibleSteal)
            if updateVisualState then updateVisualState(_G.invisibleStealEnabled or false) end
        end
    end)

    local function onCharacterAdded(newChar)
        clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0
        pcall(function() for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c:IsA("BasePart") and c.Name == "HumanoidRootPart" then c:Destroy() end end end)
        if oldRoot then pcall(function() oldRoot:Destroy() end); oldRoot = nil end
        if clone then pcall(function() clone:Destroy() end); clone = nil end
        animPlaying = false; _G.invisibleStealEnabled = false
        if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
        task.wait(0.2)
        local camera = Workspace.CurrentCamera
        if camera and newChar then
            local h = newChar:FindFirstChildOfClass("Humanoid")
            if h then camera.CameraSubject = h; camera.CameraType = Enum.CameraType.Custom end
        end
    end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

    local function setupDeathListener()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildOfClass("Humanoid")
            if h then h.Died:Connect(function() clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0 end) end
        end
    end
    setupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.1); setupDeathListener() end)
    end)
end)

task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas    = ReplicatedStorage:WaitForChild("Datas")
    local Shared   = ReplicatedStorage:WaitForChild("Shared")
    local Utils    = ReplicatedStorage:WaitForChild("Utils")

    local Synchronizer  = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData   = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils   = require(Utils:WaitForChild("NumberUtils"))

    local STEAL_HOLD_TIME = 1.3
    local stealReady = true
    local isStealingActive = false
    local stealBarConnection = nil

    local function createStealBar()
        local existing = PlayerGui:FindFirstChild("SolanaStealBar")
        if existing then existing:Destroy() end
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "SolanaStealBar"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999
        gui.Parent = PlayerGui
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 250, 0, 28)
        container.Position = UDim2.new(0.5, -125, 1, -110)
        container.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
        container.BackgroundTransparency = 0.08
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        container.Parent = gui
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 14)
        
        local stroke = Instance.new("UIStroke", container)
        stroke.Thickness = 1.2
        stroke.Transparency = 0.35
        stroke.Color = Color3.fromRGB(0, 200, 255)
        
        local grad = Instance.new("UIGradient", stroke)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
        })
        
        local barBg = Instance.new("Frame", container)
        barBg.Size = UDim2.new(1, -20, 0, 18)
        barBg.Position = UDim2.new(0, 10, 0.5, -9)
        barBg.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
        barBg.BorderSizePixel = 0
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
        
        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        barFill.BorderSizePixel = 0
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
        
        local percentLabel = Instance.new("TextLabel", barBg)
        percentLabel.Size = UDim2.new(1, 0, 1, 0)
        percentLabel.BackgroundTransparency = 1
        percentLabel.Text = "0%"
        percentLabel.Font = Enum.Font.GothamBold
        percentLabel.TextSize = 10
        percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        percentLabel.TextXAlignment = Enum.TextXAlignment.Center
        percentLabel.ZIndex = 2
        
        local function startStealBar()
            if isStealingActive then return end
            isStealingActive = true
            barFill.Size = UDim2.new(0, 0, 1, 0)
            percentLabel.Text = "0%"
            
            local startTime = tick()
            if stealBarConnection then stealBarConnection:Disconnect() end
            stealBarConnection = RunService.Heartbeat:Connect(function()
                if not isStealingActive then
                    if stealBarConnection then stealBarConnection:Disconnect() end
                    stealBarConnection = nil
                    return
                end
                local elapsed = tick() - startTime
                local progress = math.min(elapsed / STEAL_HOLD_TIME, 1)
                barFill.Size = UDim2.new(progress, 0, 1, 0)
                local pct = math.floor(progress * 100)
                percentLabel.Text = pct .. "%"
                
                if progress >= 1 then
                    isStealingActive = false
                    if stealBarConnection then stealBarConnection:Disconnect() end
                    stealBarConnection = nil
                    task.wait()
                    barFill.Size = UDim2.new(0, 0, 1, 0)
                    percentLabel.Text = "0%"
                end
            end)
        end
        
        local function stopStealBar()
            isStealingActive = false
            if stealBarConnection then stealBarConnection:Disconnect() end
            stealBarConnection = nil
            barFill.Size = UDim2.new(0, 0, 1, 0)
            percentLabel.Text = "0%"
        end
        
        local function animateBorder()
            local rot = 0
            while gui and gui.Parent do
                rot = rot + 1
                grad.Rotation = rot
                task.wait(0.02)
            end
        end
        task.spawn(animateBorder)
        
        local function makeDraggable(frame)
            local dragging = false
            local dragStart, startPos
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
        end
        makeDraggable(container)
        
        return {start = startStealBar, stop = stopStealBar}
    end

    local stealBar = createStealBar()

    local boxes = {
        {min = Vector3.new(-337.448303, -3.898971, -122.397758), max = Vector3.new(-328.004578, -3.898971, 242.625626)},
        {min = Vector3.new(-327.257660, -3.899109, -122.228622), max = Vector3.new(-320.600891, -3.899109, 242.612259)},
        {min = Vector3.new(-319.783386, -3.898970, -122.227089), max = Vector3.new(-312.908325, -3.898970, 242.585617)},
        {min = Vector3.new(-312.445648, -3.899108, -122.389832), max = Vector3.new(-305.489899, -3.899108, 242.456818)},
        {min = Vector3.new(-305.037048, -3.898970, -122.230743), max = Vector3.new(-293.957489, -3.898970, 242.606873)},
        {min = Vector3.new(-491.448608, -3.898972, -122.253258), max = Vector3.new(-481.811737, -3.898972, 242.615005)},
        {min = Vector3.new(-498.971069, -3.898970, -122.382767), max = Vector3.new(-491.748840, -3.898970, 242.612061)},
        {min = Vector3.new(-506.436737, -3.898972, -122.411476), max = Vector3.new(-499.318542, -3.898972, 242.615982)},
        {min = Vector3.new(-513.783569, -3.898972, -122.223297), max = Vector3.new(-506.801849, -3.898972, 242.627090)},
        {min = Vector3.new(-525.236938, -3.898972, -122.409813), max = Vector3.new(-514.265015, -3.898972, 242.608932)},
    }

    local trackedPrompts = {}
    local lastFire = {}
    local lastEnableFire = {}

    local FIRE_DEBOUNCE = 0.12
    local FIRE_BURST = 3
    local ENABLE_BURST = 25
    local ENABLE_DEBOUNCE = 0.00
    local ENABLE_COOLDOWN = 0.035
    local RADIUS_ENTER_DELAY_NORMAL = 0.0725
    local RADIUS_ENTER_DELAY_NEAREST = 0
    local RADIUS_ENTER_DELAY_TP = 0.28

    local function getHRP()
        local char = LocalPlayer.Character
        if char then return char:FindFirstChild("HumanoidRootPart") end
        return nil
    end

    local function getBoxIndex(pos)
        for i,b in ipairs(boxes) do
            if pos.X >= math.min(b.min.X,b.max.X) and pos.X <= math.max(b.min.X,b.max.X)
            and pos.Z >= math.min(b.min.Z,b.max.Z) and pos.Z <= math.max(b.min.Z,b.max.Z) then
                return i
            end
        end
        return nil
    end

    local function getPromptPosition(prompt)
        local p = prompt.Parent
        if not p then return nil end
        if p:IsA("Attachment") and p.Parent then p = p.Parent end
        if p:IsA("BasePart") then return p.Position
        elseif p:IsA("Model") then return p:GetPivot().Position end
        return nil
    end

    local function isMyOwnPlot(prompt)
        local plot = prompt:FindFirstAncestorOfClass("Model")
        if plot then
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                local parentPlot = prompt:FindFirstAncestorWhichIsA("Model")
                while parentPlot and parentPlot.Parent ~= plots do parentPlot = parentPlot.Parent end
                if parentPlot then
                    local sign = parentPlot:FindFirstChild("PlotSign")
                    if sign then
                        local gui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                        local label = gui and gui:FindFirstChildWhichIsA("TextLabel", true)
                        if label then
                            local txt = label.Text:lower()
                            if txt:find(LocalPlayer.Name:lower(), 1, true) or txt:find(LocalPlayer.DisplayName:lower(), 1, true) then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end

    local function isPromptAvailable(prompt, hrpPos)
        if not prompt or not prompt.Parent then return false end
        if not prompt.Enabled then return false end
        local pos = getPromptPosition(prompt)
        if not pos then return false end
        if isMyOwnPlot(prompt) then return false end
        return true
    end

    local function canFire(prompt, debounce)
        local t = os.clock()
        local last = lastFire[prompt]
        if last and (t - last) < debounce then return false end
        lastFire[prompt] = t
        return true
    end

    local function firePrompt(prompt, burst, debounce)
        if not prompt or not prompt.Parent then return end
        if not prompt.Enabled then return end
        if not canFire(prompt, debounce) then return end
        for i = 1, burst do
            pcall(function() fireproximityprompt(prompt, 0) end)
        end
        _G.triggerSafePollBoost()
    end

    local function trackPrompt(prompt)
        if trackedPrompts[prompt] then return end
        trackedPrompts[prompt] = true

        local function tryInstantEnableFire()
            local hrp = getHRP()
            if not hrp then return end
            local myPos = hrp.Position
            if isPromptAvailable(prompt, myPos) then
                local now = os.clock()
                local le = lastEnableFire[prompt]
                if not le or (now - le) >= ENABLE_COOLDOWN then
                    lastEnableFire[prompt] = now
                    firePrompt(prompt, ENABLE_BURST, ENABLE_DEBOUNCE)
                end
            end
        end

        task.defer(function() tryInstantEnableFire() end)
        pcall(function()
            prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
                if prompt.Enabled then tryInstantEnableFire() end
            end)
        end)
        prompt.AncestryChanged:Connect(function()
            if not prompt:IsDescendantOf(workspace) then
                trackedPrompts[prompt] = nil
                lastFire[prompt] = nil
                lastEnableFire[prompt] = nil
            end
        end)
    end

    local function scanBrainrotPrompts()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, obj in ipairs(podiums:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then trackPrompt(obj) end
                end
            end
        end
    end

    scanBrainrotPrompts()
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") and obj:FindFirstAncestor("AnimalPodiums") then trackPrompt(obj) end
    end)

    local brainrotSelectionEnabled = true
    local stealMode = Config.LastBrainrotMode or "Highest"
    local stealNearestEnabled = (stealMode == "Nearest")
    local stealHighestEnabled = (stealMode == "Highest")
    local stealPriorityEnabled = (stealMode == "Priority")
    local selectedTargetIndex = 1
    local selectedTargetUID = nil
    local allAnimalsCache = {}
    local petButtons = {}

    local PRIORITY_LIST = {}
    if Config.PriorityList and #Config.PriorityList > 0 then
        for i = 1, #Config.PriorityList do PRIORITY_LIST[i] = Config.PriorityList[i] end
    else
        PRIORITY_LIST = {
            "Headless Horseman", "Signore Carapace", "Arcadragon", "Elefanto Frigo",
            "Strawberry Elephant", "John Pork", "Antonio", "Love Love Bear", "Meowl",
            "Pancake and Syrup", "Skibidi Toilet", "Griffin", "Globa Steppa",
            "Rico Dinero", "Kalika Bros", "Tirilikalika Tirilikalako", "Dragon Gingerini",
            "Fishino Clownino", "Ginger Gerat", "La Supreme Combinasion", "Digi Narwhal",
            "Hydra Bunny", "Los Hackers", "Dug dug dug", "Bunny and Eggy",
            "Hydra Dragon Cannelloni", "Duggy Bros", "Dragon Cannelloni", "Ketupat Bros",
            "La Casa Boo", "Guest 666", "Money Money Reindeer", "Rosey and Teddy",
            "Foxini Lanternini", "Fragola La La La", "Quackini Snackini", "Los Chillis",
            "Cerberus", "Boppin Bunny", "Jolly Jolly Sahur", "Reinito Sleighito",
            "Fortunu and Cashuru", "Chillin Chili", "Los Sekolahs", "Los Amigos",
            "Gym Bros", "Spooky and Pumpky", "Cooki and Milki", "Fragrama and Chocrama",
            "Celularcini Viciosini", "Cloverat Clapat", "Tralaledon", "Money Money Bros",
            "Capitano Moby", "La Food Combinasion", "Celestial Pegasus",
            "Hopilikalika Hopilikalako", "Los Mariachis", "Cash or Card", "Sammyni Fattini",
            "Popcuru and Fizzuru", "Burguro And Fryuro", "Garama and Madundung"
        }
    end

    local function getPriorityRank(name)
        if not name then return 999 end
        for i, pName in ipairs(PRIORITY_LIST) do
            if pName:lower() == name:lower() then return i end
        end
        return 999
    end

    local function isMyBaseAnimal(animalData)
        if not animalData or not animalData.plot then return false end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(animalData.plot)
        if not plot then return false end
        local channel = Synchronizer:Get(plot.Name)
        if channel then
            local owner = channel:Get("Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then return owner.UserId == LocalPlayer.UserId end
                if typeof(owner) == "table" and owner.UserId then return owner.UserId == LocalPlayer.UserId end
            end
        end
        return false
    end

    local function formatMutationText(mutationName)
        if not mutationName or mutationName == "None" then return "" end
        return "<font color='rgb(255,255,255)'><font weight='800'>" .. mutationName .. " </font></font>"
    end

    local function hasStealPrompt(podium)
        if not podium then return false end
        local base = podium:FindFirstChild("Base")
        local spawn = base and base:FindFirstChild("Spawn")
        if spawn then
            local attach = spawn:FindFirstChild("PromptAttachment")
            if attach then
                for _, p in ipairs(attach:GetChildren()) do
                    if p:IsA("ProximityPrompt") and p.ActionText == "Steal" and p.Enabled then return true end
                end
            end
        end
        return false
    end

    local function findAdorneeGlobal(animalData)
        if not animalData then return nil end
        local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
        if plot then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                local podium = podiums:FindFirstChild(animalData.slot)
                if podium then
                    local base = podium:FindFirstChild("Base")
                    if base then
                        local spawn = base:FindFirstChild("Spawn")
                        if spawn then return spawn end
                        return base:FindFirstChildWhichIsA("BasePart") or base
                    end
                end
            end
        end
        return nil
    end

    local function getPromptForAnimal(animalData)
        if not animalData then return nil end
        local plot = Workspace.Plots:FindFirstChild(animalData.plot)
        if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return nil end
        local podium = podiums:FindFirstChild(animalData.slot)
        if not podium then return nil end
        local base = podium:FindFirstChild("Base")
        local spawn = base and base:FindFirstChild("Spawn")
        if not spawn then return nil end
        local attach = spawn:FindFirstChild("PromptAttachment")
        if not attach then return nil end
        for _, p in ipairs(attach:GetChildren()) do
            if p:IsA("ProximityPrompt") and p.Enabled and p.ActionText == "Steal" then return p end
        end
        return nil
    end

    local function get_all_pets()
        local out = {}
        for _, a in ipairs(allAnimalsCache) do
            if not isMyBaseAnimal(a) then
                table.insert(out, {petName=a.name, mpsText=a.genText, mpsValue=a.genValue,
                    owner=a.owner, plot=a.plot, slot=a.slot, uid=a.uid, mutation=a.mutation, animalData=a})
            end
        end
        if stealPriorityEnabled then
            table.sort(out, function(a, b)
                local rankA = getPriorityRank(a.petName)
                local rankB = getPriorityRank(b.petName)
                if rankA ~= rankB then return rankA < rankB end
                return a.mpsValue > b.mpsValue
            end)
        elseif stealHighestEnabled then
            table.sort(out, function(a, b) return a.mpsValue > b.mpsValue end)
        elseif stealNearestEnabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, p in ipairs(out) do
                    local targetPart = findAdorneeGlobal(p.animalData)
                    p.distance = targetPart and (hrp.Position - targetPart.Position).Magnitude or math.huge
                end
                table.sort(out, function(a, b) return (a.distance or math.huge) < (b.distance or math.huge) end)
            end
        end
        return out
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotSelectionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    screenGui.Enabled = not Config.HideBrainrotSelection

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320 * MOBILE_SCALE, 0, 380 * MOBILE_SCALE)
    frame.Position = UDim2.new(Config.Positions.BrainrotSelection.X, 0, Config.Positions.BrainrotSelection.Y, 0)
    frame.BackgroundColor3 = Theme.Background
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui

    AddMobileMinimize(frame, "BRAINROT")
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12 * MOBILE_SCALE)

    local function AddNeonBorder(frame, thickness)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Thickness = thickness or 1.5
        stroke.Transparency = 0.3
        stroke.Color = Theme.TextPrimary
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local grad = Instance.new("UIGradient", stroke)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent1),
            ColorSequenceKeypoint.new(0.5, Theme.Accent2),
            ColorSequenceKeypoint.new(1, Theme.Accent1)
        }
        grad.Rotation = 45
        task.spawn(function()
            while stroke.Parent do
                grad.Rotation = (grad.Rotation or 0) + 1
                stroke.Transparency = 0.2 + math.sin(grad.Rotation * 0.02) * 0.2
                task.wait(0.02)
            end
        end)
        return stroke
    end
    AddNeonBorder(frame, 1.5)

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1,0,0,38 * MOBILE_SCALE)
    header.BackgroundTransparency = 1
    MakeDraggable(header, frame, "BrainrotSelection")

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = IS_MOBILE and UDim2.new(0.4,0,1,0) or UDim2.new(0.5,0,1,0)
    titleLabel.Position = UDim2.new(0,12 * MOBILE_SCALE,0,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Brainrot Selection"
    MakeText(titleLabel, true)
    titleLabel.TextSize = 14 * MOBILE_SCALE
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local targetPanel = Instance.new("Frame", frame)
    targetPanel.Size = UDim2.new(1,-24 * MOBILE_SCALE,0,34 * MOBILE_SCALE)
    targetPanel.Position = UDim2.new(0,12 * MOBILE_SCALE,0,45 * MOBILE_SCALE)
    targetPanel.BackgroundColor3 = Theme.Surface
    targetPanel.BackgroundTransparency = 0.08
    targetPanel.BorderSizePixel = 0
    Instance.new("UICorner", targetPanel).CornerRadius = UDim.new(0, 8 * MOBILE_SCALE)
    AddNeonBorder(targetPanel, 1)

    local targetLabel = Instance.new("TextLabel", targetPanel)
    targetLabel.Size = UDim2.new(1,-16 * MOBILE_SCALE,1,0)
    targetLabel.Position = UDim2.new(0,8 * MOBILE_SCALE,0,0)
    targetLabel.BackgroundTransparency = 1
    MakeText(targetLabel, true)
    targetLabel.TextSize = 12 * MOBILE_SCALE
    targetLabel.TextColor3 = Theme.TextPrimary
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.TextTruncate = Enum.TextTruncate.AtEnd
    targetLabel.Text = "Loading..."

    local modeContainer = Instance.new("Frame", frame)
    modeContainer.Size = UDim2.new(1,-24 * MOBILE_SCALE,0,30 * MOBILE_SCALE)
    modeContainer.Position = UDim2.new(0,12 * MOBILE_SCALE,0,87 * MOBILE_SCALE)
    modeContainer.BackgroundTransparency = 1

    local modeButtons = {}
    local modes = {
        {name = "Nearest", enabled = stealNearestEnabled},
        {name = "Highest", enabled = stealHighestEnabled},
        {name = "Priority", enabled = stealPriorityEnabled}
    }
    for idx, mode in ipairs(modes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.32, -2, 1, -4)
        btn.Position = UDim2.new((idx-1) * 0.33, 2, 0, 2)
        btn.BackgroundColor3 = mode.enabled and Theme.Accent1 or Theme.Surface
        btn.BackgroundTransparency = 0.08
        btn.Text = mode.name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11 * MOBILE_SCALE
        btn.TextColor3 = mode.enabled and Color3.new(1,1,1) or Theme.TextPrimary
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6 * MOBILE_SCALE)
        AddNeonBorder(btn, 1)
        btn.Parent = modeContainer
        modeButtons[mode.name] = btn
        btn.MouseButton1Click:Connect(function()
            stealNearestEnabled = (mode.name == "Nearest")
            stealHighestEnabled = (mode.name == "Highest")
            stealPriorityEnabled = (mode.name == "Priority")
            Config.LastBrainrotMode = mode.name
            SaveConfig()
            for name, button in pairs(modeButtons) do
                button.BackgroundColor3 = (name == mode.name) and Theme.Accent1 or Theme.Surface
                button.TextColor3 = (name == mode.name) and Color3.new(1,1,1) or Theme.TextPrimary
            end
            local pets = get_all_pets()
            if #pets > 0 then
                selectedTargetIndex = 1
                selectedTargetUID = pets[1].uid
                SharedState.SelectedPetData = pets[1]
            end
            SharedState.ListNeedsRedraw = true
            updateUI(brainrotSelectionEnabled, pets)
        end)
    end

    local selectLabel = Instance.new("TextLabel", frame)
    selectLabel.Size = UDim2.new(0.5,0,0,16 * MOBILE_SCALE)
    selectLabel.Position = UDim2.new(0,12 * MOBILE_SCALE,0,125 * MOBILE_SCALE)
    selectLabel.BackgroundTransparency = 1
    selectLabel.Text = "Available"
    MakeText(selectLabel, true)
    selectLabel.TextSize = 10 * MOBILE_SCALE
    selectLabel.TextColor3 = Theme.TextPrimary
    selectLabel.TextXAlignment = Enum.TextXAlignment.Left

    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1,-24 * MOBILE_SCALE,1,-195 * MOBILE_SCALE)
    listFrame.Position = UDim2.new(0,12 * MOBILE_SCALE,0,145 * MOBILE_SCALE)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 3 * MOBILE_SCALE
    listFrame.ScrollBarImageColor3 = Theme.Accent1
    listFrame.CanvasSize = UDim2.new(0,0,0,0)

    local uiListLayout = Instance.new("UIListLayout", listFrame)
    uiListLayout.Padding = UDim.new(0,6 * MOBILE_SCALE)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end)

    local toggleBtnContainer = Instance.new("Frame", frame)
    toggleBtnContainer.Size = UDim2.new(1,-24 * MOBILE_SCALE,0,32 * MOBILE_SCALE)
    toggleBtnContainer.Position = UDim2.new(0,12 * MOBILE_SCALE,1,-40 * MOBILE_SCALE)
    toggleBtnContainer.BackgroundTransparency = 1

    local enableBtn = Instance.new("TextButton", toggleBtnContainer)
    enableBtn.Size = UDim2.new(1,0,1,0)
    enableBtn.BackgroundColor3 = Theme.Success
    enableBtn.Text = "Enabled"
    MakeText(enableBtn, true)
    enableBtn.TextSize = 12 * MOBILE_SCALE
    enableBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 6 * MOBILE_SCALE)

    local function executeStealWithBar(prompt)
        if not stealReady then return false end
        if not prompt or not prompt.Parent then return false end
        stealReady = false
        
        stealBar.start()
        
        task.spawn(function()
            pcall(firesignal, prompt.PromptButtonHoldBegan)
            task.wait(STEAL_HOLD_TIME)
            pcall(firesignal, prompt.Triggered)
            task.wait(0.05)
            stealReady = true
            stealBar.stop()
        end)
        return true
    end

    local inRadiusSince = nil
    local currentTargetInRadius = false

    task.spawn(function()
        while task.wait(_G.getSafePollRate()) do
            if not brainrotSelectionEnabled then
                inRadiusSince = nil
                currentTargetInRadius = false
                continue
            end
            if LocalPlayer:GetAttribute("Stealing") then
                inRadiusSince = nil
                currentTargetInRadius = false
                continue
            end

            local hrp = getHRP()
            if not hrp then continue end

            local myPos = hrp.Position
            local anyAvailable = false
            local targetPrompt = nil

            if stealNearestEnabled then
                for prompt, _ in pairs(trackedPrompts) do
                    if isPromptAvailable(prompt, myPos) then
                        anyAvailable = true
                        targetPrompt = prompt
                        break
                    end
                end
            else
                local pets = get_all_pets()
                if #pets > 0 and selectedTargetIndex <= #pets then
                    local targetPetData = pets[selectedTargetIndex]
                    if targetPetData and not isMyBaseAnimal(targetPetData.animalData) then
                        targetPrompt = getPromptForAnimal(targetPetData.animalData)
                        if targetPrompt and isPromptAvailable(targetPrompt, myPos) then
                            anyAvailable = true
                        end
                    end
                end
            end

            if anyAvailable and targetPrompt then
                if not currentTargetInRadius then
                    currentTargetInRadius = true
                    inRadiusSince = tick()
                end
                local entryDelay = RADIUS_ENTER_DELAY_NORMAL
                if stealNearestEnabled then
                    entryDelay = RADIUS_ENTER_DELAY_NEAREST
                elseif isTpMoving or State.isTpMoving then
                    entryDelay = RADIUS_ENTER_DELAY_TP
                end
                if inRadiusSince and (tick() - inRadiusSince) >= entryDelay then
                    executeStealWithBar(targetPrompt)
                end
            else
                currentTargetInRadius = false
                inRadiusSince = nil
            end
        end
    end)

    local function updateUI(enabled, allPets)
        brainrotSelectionEnabled = enabled
        enableBtn.Text = enabled and "Enabled" or "Disabled"
        enableBtn.BackgroundColor3 = enabled and Theme.Success or Theme.SurfaceHighlight

        if selectedTargetUID and allPets then
            for i, p in ipairs(allPets) do
                if p.uid == selectedTargetUID then
                    selectedTargetIndex = i
                    break
                end
            end
        end

        if SharedState.ListNeedsRedraw then
            for _, c in ipairs(listFrame:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            petButtons = {}
            if allPets and #allPets > 0 then
                for i, petData in ipairs(allPets) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1,0,0,42 * MOBILE_SCALE)
                    btn.BackgroundColor3 = (i == selectedTargetIndex) and Theme.SurfaceLight or Theme.Surface
                    btn.BackgroundTransparency = 0.08
                    btn.Text = ""
                    btn.Parent = listFrame
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6 * MOBILE_SCALE)

                    local btnBorder = AddNeonBorder(btn, 1)
                    if i == selectedTargetIndex then
                        btnBorder.Color = Theme.Accent1
                        btnBorder.Thickness = 2
                    end

                    local previewContainer = Instance.new("Frame", btn)
                    previewContainer.Size = UDim2.new(0, 32 * MOBILE_SCALE, 0, 32 * MOBILE_SCALE)
                    previewContainer.Position = UDim2.new(0, 4 * MOBILE_SCALE, 0.5, -16 * MOBILE_SCALE)
                    previewContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                    previewContainer.BackgroundTransparency = 0.3
                    previewContainer.BorderSizePixel = 0
                    previewContainer.ClipsDescendants = true
                    Instance.new("UICorner", previewContainer).CornerRadius = UDim.new(0, 5 * MOBILE_SCALE)

                    task.spawn(function()
                        local viewport = createAnimalPreview(previewContainer, petData.petName, UDim2.new(0, 30 * MOBILE_SCALE, 0, 30 * MOBILE_SCALE))
                        if viewport then
                            viewport.Position = UDim2.new(0, 1 * MOBILE_SCALE, 0, 1 * MOBILE_SCALE)
                        end
                    end)

                    local rankLabel = Instance.new("TextLabel", btn)
                    rankLabel.Size = UDim2.new(0, 30 * MOBILE_SCALE, 1, 0)
                    rankLabel.Position = UDim2.new(0, 42 * MOBILE_SCALE, 0, 0)
                    rankLabel.BackgroundTransparency = 1
                    rankLabel.Text = "#" .. i
                    MakeText(rankLabel, false)
                    rankLabel.TextSize = 10 * MOBILE_SCALE
                    rankLabel.TextColor3 = (i == selectedTargetIndex) and Theme.Accent1 or Theme.TextPrimary

                    local infoLabel = Instance.new("TextLabel", btn)
                    infoLabel.Size = UDim2.new(1,-78 * MOBILE_SCALE,0,16 * MOBILE_SCALE)
                    infoLabel.Position = UDim2.new(0,78 * MOBILE_SCALE,0,5 * MOBILE_SCALE)
                    infoLabel.BackgroundTransparency = 1
                    infoLabel.RichText = true
                    infoLabel.Text = formatMutationText(petData.mutation) .. "<font weight='500'>" .. petData.petName .. "</font>"
                    MakeText(infoLabel, false)
                    infoLabel.TextSize = 10 * MOBILE_SCALE
                    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
                    infoLabel.TextTruncate = Enum.TextTruncate.AtEnd

                    local genLabel = Instance.new("TextLabel", btn)
                    genLabel.Size = UDim2.new(1,-78 * MOBILE_SCALE,0,12 * MOBILE_SCALE)
                    genLabel.Position = UDim2.new(0,78 * MOBILE_SCALE,0,22 * MOBILE_SCALE)
                    genLabel.BackgroundTransparency = 1
                    genLabel.Text = petData.mpsText
                    MakeText(genLabel, false)
                    genLabel.TextSize = 9 * MOBILE_SCALE
                    genLabel.TextColor3 = Theme.Accent1
                    genLabel.TextXAlignment = Enum.TextXAlignment.Left

                    petButtons[i] = {button=btn, rank=rankLabel, info=infoLabel, border=btnBorder}

                    btn.MouseButton1Click:Connect(function()
                        selectedTargetIndex = i
                        selectedTargetUID = petData.uid
                        SharedState.SelectedPetData = petData
                        SharedState.ListNeedsRedraw = false
                        updateUI(brainrotSelectionEnabled, get_all_pets())
                    end)
                end
            end
            SharedState.ListNeedsRedraw = false
        end

        if selectedTargetIndex > #petButtons then selectedTargetIndex = 1 end
        for i, pb in ipairs(petButtons) do
            local sel = (i == selectedTargetIndex)
            pb.button.BackgroundColor3 = sel and Theme.SurfaceLight or Theme.Surface
            pb.rank.TextColor3 = sel and Theme.Accent1 or Theme.TextPrimary
            pb.info.TextColor3 = sel and Theme.TextPrimary or Theme.TextSecondary
            if pb.border then
                pb.border.Color = sel and Theme.Accent1 or Theme.TextPrimary
                pb.border.Thickness = sel and 2 or 1
            end
        end
        local ct = allPets and allPets[selectedTargetIndex]
        SharedState.SelectedPetData = ct
        if enabled and ct then
            targetLabel.Text = string.format("%s (%s)", ct.petName, ct.mpsText)
            targetLabel.TextColor3 = Theme.Accent1
        elseif not enabled then
            targetLabel.Text = "Disabled"
            targetLabel.TextColor3 = Theme.TextPrimary
        else
            targetLabel.Text = "Searching..."
            targetLabel.TextColor3 = Theme.TextPrimary
        end
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end

    SharedState.UpdateBrainrotSelectionUI = function()
        SharedState.ListNeedsRedraw = true
        updateUI(brainrotSelectionEnabled, get_all_pets())
    end

    enableBtn.MouseButton1Click:Connect(function()
        brainrotSelectionEnabled = not brainrotSelectionEnabled
        SharedState.ListNeedsRedraw = true
        updateUI(brainrotSelectionEnabled, get_all_pets())
    end)

    local AnimalModels = ReplicatedStorage:FindFirstChild("Models") and ReplicatedStorage.Models:FindFirstChild("Animals")
    local AnimalAnimations = ReplicatedStorage:FindFirstChild("Animations") and ReplicatedStorage.Animations:FindFirstChild("Animals")

    local function createAnimalPreview(parent, animalName, size)
        if not AnimalModels then return nil end
        local template = AnimalModels:FindFirstChild(animalName)
        if not template then return nil end
        local viewport = Instance.new("ViewportFrame")
        viewport.Size = size or UDim2.new(0, 32, 0, 32)
        viewport.BackgroundTransparency = 1
        viewport.BorderSizePixel = 0
        viewport.LightColor = Color3.fromRGB(255, 255, 255)
        viewport.LightDirection = Vector3.new(-1, -2, -1)
        viewport.Ambient = Color3.fromRGB(180, 180, 180)
        viewport.Parent = parent
        local worldModel = Instance.new("WorldModel")
        worldModel.Parent = viewport
        local clone = template:Clone()
        clone.Parent = worldModel
        if clone.PrimaryPart then clone.PrimaryPart.Anchored = true end
        for _, descendant in ipairs(clone:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Anchored = true
                descendant.CanCollide = false
                descendant.CastShadow = false
                descendant.Massless = true
            end
        end
        local success, boundingBoxCFrame, boundingBoxSize = pcall(function() return clone:GetBoundingBox() end)
        if not success then
            boundingBoxCFrame = clone:GetPivot()
            boundingBoxSize = Vector3.new(4, 4, 4)
        end
        local maxDimension = math.max(boundingBoxSize.X, boundingBoxSize.Y, boundingBoxSize.Z)
        local fov = 50
        local distance = (maxDimension * 0.5) / math.tan(math.rad(fov * 0.5)) * 0.85
        local modelCFrame = (clone.PrimaryPart and clone.PrimaryPart.CFrame) or clone:GetPivot()
        local offset = (modelCFrame.LookVector + Vector3.new(0, 0.25, 0)).Unit
        local camera = Instance.new("Camera")
        camera.FieldOfView = fov
        camera.CFrame = CFrame.new(boundingBoxCFrame.Position + offset * (distance + maxDimension * 0.5), boundingBoxCFrame.Position)
        camera.Parent = viewport
        viewport.CurrentCamera = camera
        if AnimalAnimations then
            local animalAnimFolder = AnimalAnimations:FindFirstChild(animalName)
            if animalAnimFolder then
                local idleAnim = animalAnimFolder:FindFirstChild("Idle") or animalAnimFolder:FindFirstChild("idle") or animalAnimFolder:GetChildren()[1]
                if idleAnim then
                    local animationController = clone:FindFirstChildWhichIsA("AnimationController", true)
                    if not animationController then
                        animationController = Instance.new("AnimationController")
                        animationController.Parent = clone
                    end
                    local animator = animationController:FindFirstChildOfClass("Animator")
                    if not animator then
                        animator = Instance.new("Animator", animationController)
                    end
                    local track = animator:LoadAnimation(idleAnim)
                    track.Looped = true
                    track:Play(0)
                    if track.Length > 0 then
                        track.TimePosition = os.clock() % track.Length
                    end
                    task.spawn(function()
                        while viewport.Parent do
                            task.wait(1)
                            pcall(function()
                                if track and track.Length > 0 then
                                    local time = os.clock() % track.Length
                                    if math.abs(time - track.TimePosition) > 0.05 then
                                        track.TimePosition = time
                                    end
                                end
                            end)
                        end
                    end)
                end
            end
        end
        return viewport
    end

    local function refreshAllPets()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return end
        local fullCache = {}
        for _, plot in ipairs(plots:GetChildren()) do
            local ch = Synchronizer:Get(plot.Name)
            if ch then
                local owner = ch:Get("Owner")
                if owner and Players:FindFirstChild(owner.Name) then
                    local ownerName = owner.Name or "Unknown"
                    local al = ch:Get("AnimalList")
                    if al then
                        for slot, ad in pairs(al) do
                            if type(ad) == "table" and ad.Index then
                                local shouldInclude = false
                                if SkipNonStealable then
                                    local podium = plot:FindFirstChild("AnimalPodiums") and plot.AnimalPodiums:FindFirstChild(tostring(slot))
                                    if podium and hasStealPrompt(podium) then shouldInclude = true end
                                else
                                    shouldInclude = true
                                end
                                if shouldInclude then
                                    local aInfo = AnimalsData[ad.Index]
                                    if aInfo then
                                        local mut = ad.Mutation or "None"
                                        if mut == "Yin Yang" then mut = "YinYang" end
                                        local gv = AnimalsShared:GetGeneration(aInfo.DisplayName or ad.Index, ad.Mutation, ad.Traits, nil)
                                        local gt = "$" .. NumberUtils:ToString(gv) .. "/s"
                                        table.insert(fullCache, {
                                            name = aInfo.DisplayName or ad.Index,
                                            petName = aInfo.DisplayName or ad.Index,
                                            genText = gt,
                                            genValue = gv,
                                            mutation = mut,
                                            owner = ownerName,
                                            plot = plot.Name,
                                            slot = tostring(slot),
                                            uid = plot.Name .. "_" .. tostring(slot),
                                            animalData = {
                                                name = aInfo.DisplayName or ad.Index,
                                                genText = gt,
                                                genValue = gv,
                                                mutation = mut,
                                                owner = ownerName,
                                                plot = plot.Name,
                                                slot = tostring(slot),
                                                uid = plot.Name .. "_" .. tostring(slot)
                                            }
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        local topCache = fullCache
        local changed = false
        if #topCache ~= #allAnimalsCache then changed = true
        else
            for i = 1, #topCache do
                if topCache[i].uid ~= allAnimalsCache[i].uid or topCache[i].genValue ~= allAnimalsCache[i].genValue then
                    changed = true
                    break
                end
            end
        end
        if changed then
            for i = #allAnimalsCache, 1, -1 do table.remove(allAnimalsCache, i) end
            for _, pet in ipairs(topCache) do table.insert(allAnimalsCache, pet) end
            SharedState.AllAnimalsCache = allAnimalsCache
            SharedState.ListNeedsRedraw = true
            local pets = get_all_pets()
            updateUI(brainrotSelectionEnabled, pets)
            if #pets > 0 and not SharedState.SelectedPetData then
                selectedTargetIndex = 1
                selectedTargetUID = pets[1].uid
                SharedState.SelectedPetData = pets[1]
                updateUI(brainrotSelectionEnabled, pets)
            end
        end
    end

    local refreshDebounce = false
    local function debouncedRefresh()
        if refreshDebounce then return end
        refreshDebounce = true
        task.delay(0.3, function()
            refreshDebounce = false
            pcall(refreshAllPets)
        end)
    end

    local function setupPlotListener(plot)
        pcall(refreshAllPets)
        plot.DescendantAdded:Connect(debouncedRefresh)
        plot.DescendantRemoving:Connect(debouncedRefresh)
        task.spawn(function()
            while plot.Parent do
                task.wait(5)
                pcall(refreshAllPets)
            end
        end)
    end

    local plotsFolder = Workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do setupPlotListener(plot) end
        plotsFolder.ChildAdded:Connect(function(plot) task.wait(0.5); setupPlotListener(plot) end)
    else
        task.spawn(function()
            while not Workspace:FindFirstChild("Plots") do task.wait(1) end
            local pf = Workspace:FindFirstChild("Plots")
            if pf then
                for _, plot in ipairs(pf:GetChildren()) do setupPlotListener(plot) end
                pf.ChildAdded:Connect(function(plot) task.wait(0.5); setupPlotListener(plot) end)
            end
        end)
    end
end)

if Config.TpSettings.TpOnLoad then
    task.spawn(function()
        local function createNotifPreview(parent, animalName, size)
            local AnimalModels = ReplicatedStorage:FindFirstChild("Models") and ReplicatedStorage.Models:FindFirstChild("Animals")
            if not AnimalModels then return nil end
            local template = AnimalModels:FindFirstChild(animalName)
            if not template then return nil end
            
            local viewport = Instance.new("ViewportFrame")
            viewport.Size = size or UDim2.new(0, 60, 0, 60)
            viewport.BackgroundTransparency = 1
            viewport.BorderSizePixel = 0
            viewport.LightColor = Color3.fromRGB(255, 255, 255)
            viewport.LightDirection = Vector3.new(-1, -2, -1)
            viewport.Ambient = Color3.fromRGB(200, 200, 200)
            viewport.Parent = parent
            
            local worldModel = Instance.new("WorldModel")
            worldModel.Parent = viewport
            
            local clone = template:Clone()
            clone.Parent = worldModel
            
            if clone.PrimaryPart then
                clone.PrimaryPart.Anchored = true
            end
            
            for _, descendant in ipairs(clone:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.Anchored = true
                    descendant.CanCollide = false
                    descendant.CastShadow = false
                    descendant.Massless = true
                end
            end
            
            local success, boundingBoxCFrame, boundingBoxSize = pcall(function()
                return clone:GetBoundingBox()
            end)
            
            if not success then
                boundingBoxCFrame = clone:GetPivot()
                boundingBoxSize = Vector3.new(3, 3, 3)
            end
            
            local maxDimension = math.max(boundingBoxSize.X, boundingBoxSize.Y, boundingBoxSize.Z)
            local fov = 45
            local distance = (maxDimension * 0.5) / math.tan(math.rad(fov * 0.5)) * 0.8
            local modelCFrame = (clone.PrimaryPart and clone.PrimaryPart.CFrame) or clone:GetPivot()
            local offset = (modelCFrame.LookVector + Vector3.new(0, 0.2, 0)).Unit
            local camera = Instance.new("Camera")
            camera.FieldOfView = fov
            camera.CFrame = CFrame.new(boundingBoxCFrame.Position + offset * (distance + maxDimension * 0.4), boundingBoxCFrame.Position)
            camera.Parent = viewport
            viewport.CurrentCamera = camera
            
            return viewport
        end
        
        local function showAutoTPNotification(brainrotName, genText, isInDuel, isFallback)
            local existing = PlayerGui:FindFirstChild("AutoTPNotif")
            if existing then existing:Destroy() end
            
            local NOTIF_WIDTH = 420
            local NOTIF_HEIGHT = 85
            local DURATION = 3.5
            
            local sg = Instance.new("ScreenGui", PlayerGui)
            sg.Name = "AutoTPNotif"
            sg.ResetOnSpawn = false
            sg.DisplayOrder = 102
            sg.Parent = PlayerGui
            
            local f = Instance.new("Frame", sg)
            f.Size = UDim2.new(0, NOTIF_WIDTH, 0, NOTIF_HEIGHT)
            f.Position = UDim2.new(0.5, -NOTIF_WIDTH/2, 0, -200)
            f.BackgroundColor3 = Theme.Background
            f.BackgroundTransparency = 0.08
            f.BorderSizePixel = 0
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
            
            local stroke = Instance.new("UIStroke", f)
            stroke.Thickness = 1.5
            stroke.Transparency = 0.3
            stroke.Color = Theme.Accent1
            local grad = Instance.new("UIGradient", stroke)
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Theme.Accent1),
                ColorSequenceKeypoint.new(0.5, Theme.Accent2),
                ColorSequenceKeypoint.new(1, Theme.Accent1)
            }
            task.spawn(function()
                while stroke.Parent do
                    grad.Rotation = (grad.Rotation or 0) + 1
                    stroke.Transparency = 0.2 + math.sin(grad.Rotation * 0.02) * 0.2
                    task.wait(0.02)
                end
            end)
            
            local previewContainer = Instance.new("Frame", f)
            previewContainer.Size = UDim2.new(0, 60, 0, 60)
            previewContainer.Position = UDim2.new(0, 14, 0.5, -30)
            previewContainer.BackgroundColor3 = Theme.Surface
            previewContainer.BackgroundTransparency = 0.3
            previewContainer.BorderSizePixel = 0
            previewContainer.ClipsDescendants = true
            Instance.new("UICorner", previewContainer).CornerRadius = UDim.new(0, 10)
            
            local previewStroke = Instance.new("UIStroke", previewContainer)
            previewStroke.Thickness = 1
            previewStroke.Transparency = 0.4
            previewStroke.Color = Theme.Accent1
            
            if not isFallback and brainrotName then
                task.spawn(function()
                    local viewport = createNotifPreview(previewContainer, brainrotName, UDim2.new(0, 56, 0, 56))
                    if viewport then
                        viewport.Position = UDim2.new(0, 2, 0, 2)
                    end
                end)
            else
                local imageLabel = Instance.new("ImageLabel", previewContainer)
                imageLabel.Size = UDim2.new(1, -10, 1, -10)
                imageLabel.Position = UDim2.new(0, 5, 0, 5)
                imageLabel.BackgroundTransparency = 1
                imageLabel.Image = "rbxassetid://122875574139178"
                imageLabel.ScaleType = Enum.ScaleType.Fit
            end
            
            local textContainer = Instance.new("Frame", f)
            textContainer.Size = UDim2.new(1, -92, 0, NOTIF_HEIGHT - 14)
            textContainer.Position = UDim2.new(0, 86, 0, 7)
            textContainer.BackgroundTransparency = 1
            
            if isFallback then
                local titleLabel = Instance.new("TextLabel", textContainer)
                titleLabel.Size = UDim2.new(1, 0, 0, 22)
                titleLabel.Position = UDim2.new(0, 0, 0, 8)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = "NO BRAINROTS DETECTED"
                titleLabel.Font = Enum.Font.Gotham
                titleLabel.TextSize = 12
                titleLabel.TextColor3 = Theme.TextMuted
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local msgLabel = Instance.new("TextLabel", textContainer)
                msgLabel.Size = UDim2.new(1, 0, 0, 18)
                msgLabel.Position = UDim2.new(0, 0, 0, 34)
                msgLabel.BackgroundTransparency = 1
                msgLabel.Text = "HAHAHAHA NGA JOINED LATE"
                msgLabel.Font = Enum.Font.Gotham
                msgLabel.TextSize = 10
                msgLabel.TextColor3 = Theme.TextMuted
                msgLabel.TextXAlignment = Enum.TextXAlignment.Left
            else
                local titleLabel = Instance.new("TextLabel", textContainer)
                titleLabel.Size = UDim2.new(1, 0, 0, 16)
                titleLabel.Position = UDim2.new(0, 0, 0, 0)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = "AUTO TELEPORT"
                titleLabel.Font = Enum.Font.Gotham
                titleLabel.TextSize = 9
                titleLabel.TextColor3 = Theme.TextMuted
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local nameLabel = Instance.new("TextLabel", textContainer)
                nameLabel.Size = UDim2.new(1, -70, 0, 22)
                nameLabel.Position = UDim2.new(0, 0, 0, 16)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = brainrotName or "Unknown"
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 14
                nameLabel.TextColor3 = Theme.TextPrimary
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                
                local bottomRow = Instance.new("Frame", textContainer)
                bottomRow.Size = UDim2.new(1, 0, 0, 20)
                bottomRow.Position = UDim2.new(0, 0, 0, 38)
                bottomRow.BackgroundTransparency = 1
                
                if genText then
                    local genLabel = Instance.new("TextLabel", bottomRow)
                    genLabel.Size = UDim2.new(0.5, 0, 1, 0)
                    genLabel.Position = UDim2.new(0, 0, 0, 0)
                    genLabel.BackgroundTransparency = 1
                    genLabel.Text = genText
                    genLabel.Font = Enum.Font.Gotham
                    genLabel.TextSize = 10
                    genLabel.TextColor3 = Theme.TextSecondary
                    genLabel.TextXAlignment = Enum.TextXAlignment.Left
                end
                
                local duelPill = Instance.new("Frame", bottomRow)
                duelPill.Size = UDim2.new(0, 70, 0, 18)
                duelPill.Position = UDim2.new(1, -75, 0.5, -9)
                duelPill.BackgroundColor3 = isInDuel and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(30, 100, 50)
                duelPill.BackgroundTransparency = 0.15
                duelPill.BorderSizePixel = 0
                Instance.new("UICorner", duelPill).CornerRadius = UDim.new(1, 0)
                
                local duelStroke = Instance.new("UIStroke", duelPill)
                duelStroke.Thickness = 1
                duelStroke.Transparency = 0.5
                duelStroke.Color = isInDuel and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(60, 180, 80)
                
                local duelLabel = Instance.new("TextLabel", duelPill)
                duelLabel.Size = UDim2.new(1, 0, 1, 0)
                duelLabel.BackgroundTransparency = 1
                duelLabel.Text = isInDuel and "IN DUEL" or "NOT IN DUEL"
                duelLabel.Font = Enum.Font.Gotham
                duelLabel.TextSize = 9
                duelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                duelLabel.TextXAlignment = Enum.TextXAlignment.Center
            end

            local progressContainer = Instance.new("Frame", f)
            progressContainer.Size = UDim2.new(1, -20, 0, 2)
            progressContainer.Position = UDim2.new(0, 10, 1, -7)
            progressContainer.BackgroundColor3 = Theme.Surface
            progressContainer.BackgroundTransparency = 0.5
            progressContainer.BorderSizePixel = 0
            Instance.new("UICorner", progressContainer).CornerRadius = UDim.new(1, 0)
            
            local progressBar = Instance.new("Frame", progressContainer)
            progressBar.Size = UDim2.new(1, 0, 1, 0)
            progressBar.BackgroundColor3 = Theme.Accent1
            progressBar.BorderSizePixel = 0
            Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)
            
            TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -NOTIF_WIDTH/2, 0, 20)
            }):Play()
            
            local startTime = tick()
            local progressTween = TweenService:Create(progressBar, TweenInfo.new(DURATION, Enum.EasingStyle.Linear), {
    Size = UDim2.new(0, 0, 1, 0)
})
progressTween:Play()
            
            task.delay(DURATION, function()
                if sg and sg.Parent then
                    TweenService:Create(f, TweenInfo.new(0.2), {
                        Position = UDim2.new(0.5, -NOTIF_WIDTH/2, 0, -200)
                    }):Play()
                    task.wait(0.25)
                    if progConn then progConn:Disconnect() end
                    sg:Destroy()
                end
            end)
            
            return sg
        end
        
        local waited = 0
        while (not SharedState.AllAnimalsCache or #SharedState.AllAnimalsCache == 0) and waited < 30 do
            task.wait(0.01)
            waited = waited + 1
        end
        
        if not SharedState.AllAnimalsCache or #SharedState.AllAnimalsCache == 0 then
            showAutoTPNotification(nil, nil, nil, true)
            return
        end
        
        local lastHash = nil
        local stableTriggered = false
        local scanDelay = 0.005
        local consecutiveMatches = 0
        local REQUIRED_CONSECUTIVE = 2
        
        local function getCacheHash()
            if not SharedState.AllAnimalsCache then return "" end
            local hash = ""
            for _, pet in ipairs(SharedState.AllAnimalsCache) do
                hash = hash .. pet.uid .. "|" .. tostring(pet.genValue) .. "|"
            end
            return hash
        end
            local function checkAndTeleport()
    if stableTriggered then return end
    
    local currentHash = getCacheHash()
    
    if currentHash == lastHash and lastHash ~= "" then
        consecutiveMatches = consecutiveMatches + 1
        if consecutiveMatches >= REQUIRED_CONSECUTIVE then
            stableTriggered = true
            
            local currentCache = SharedState.AllAnimalsCache or {}
            
            local availablePets = {}
            local myUserId = LocalPlayer.UserId
            local minGenThreshold = (Config.MinGenForAutoTP or 0) * 1000000
            
            for _, a in ipairs(currentCache) do
                local isMyPet = false
                
                if a.owner == LocalPlayer.Name or a.owner == LocalPlayer.DisplayName then
                    isMyPet = true
                end
                
                if not isMyPet and a.plot then
                    local plots = Workspace:FindFirstChild("Plots")
                    if plots then
                        local plot = plots:FindFirstChild(a.plot)
                        if plot then
                            local Packages = ReplicatedStorage:FindFirstChild("Packages")
                            if Packages then
                                local ok, Sync = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
                                if ok and Sync then
                                    local ok2, channel = pcall(function() return Sync:Get(plot.Name) end)
                                    if ok2 and channel then
                                        local owner = channel:Get("Owner")
                                        if owner then
                                            if (typeof(owner) == "Instance" and owner == LocalPlayer) or
                                               (typeof(owner) == "table" and owner.UserId == myUserId) then
                                                isMyPet = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                local meetsMinGen = (minGenThreshold == 0) or (a.genValue >= minGenThreshold)
                
                if not isMyPet and meetsMinGen then
                    table.insert(availablePets, a)
                end
            end
            
            if #availablePets == 0 then
                showAutoTPNotification(nil, nil, nil, true)
                return
            end
            
            local PRIORITY_LIST = {}
            if Config.PriorityList and #Config.PriorityList > 0 then
                for i = 1, #Config.PriorityList do
                    PRIORITY_LIST[i] = Config.PriorityList[i]
                end
            else
                PRIORITY_LIST = {
    "Headless Horseman",
    "Signore Carapace",
    "Arcadragon",
    "Elefanto Frigo",
    "Strawberry Elephant",
    "John Pork",
    "Antonio",
    "Love Love Bear",
    "Meowl",
    "Pancake and Syrup",
    "Skibidi Toilet",
    "Griffin",
    "Globa Steppa",
    "Rico Dinero",
    "Kalika Bros",
    "Tirilikalika Tirilikalako",
    "Dragon Gingerini",
    "Fishino Clownino",
    "Ginger Gerat",
    "La Supreme Combinasion",
    "Digi Narwhal",
    "Hydra Bunny",
    "Los Hackers",
    "Dug dug dug",
    "Bunny and Eggy",
    "Hydra Dragon Cannelloni",
    "Duggy Bros",
    "Dragon Cannelloni",
    "Ketupat Bros",
    "La Casa Boo",
    "Guest 666",
    "Money Money Reindeer",
    "Rosey and Teddy",
    "Foxini Lanternini",
    "Fragola La La La",
    "Quackini Snackini",
    "Los Chillis",
    "Cerberus",
    "Boppin Bunny",
    "Jolly Jolly Sahur",
    "Reinito Sleighito",
    "Fortunu and Cashuru",
    "Chillin Chili",
    "Los Sekolahs",
    "Los Amigos",
    "Gym Bros",
    "Spooky and Pumpky",
    "Cooki and Milki",
    "Fragrama and Chocrama",
    "Celularcini Viciosini",
    "Cloverat Clapat",
    "Tralaledon",
    "Money Money Bros",
    "Capitano Moby",
    "La Food Combinasion",
    "Celestial Pegasus",
    "Hopilikalika Hopilikalako",
    "Los Mariachis",
    "Cash or Card",
    "Sammyni Fattini",
    "Popcuru and Fizzuru",
    "Burguro And Fryuro",
    "Garama and Madundung"
}
            end
            
            local targetPet = nil
            
            for _, priorityName in ipairs(PRIORITY_LIST) do
                local searchName = priorityName:lower()
                for _, pet in ipairs(availablePets) do
                    if pet.name and pet.name:lower() == searchName then
                        targetPet = pet
                        break
                    end
                end
                if targetPet then break end
            end
            
            if not targetPet then
                table.sort(availablePets, function(a,b) return a.genValue > b.genValue end)
                targetPet = availablePets[1]
            end
            
            if targetPet then
                SharedState.SelectedPetData = targetPet
                
                local isInDuel = false
                local ownerName = targetPet.owner or "Unknown"
                local ownerPlayer = Players:FindFirstChild(ownerName)
                if ownerPlayer then
                    isInDuel = ownerPlayer:GetAttribute("__duels_block_steal") == true
                end
                
                playAutoTPAlert()
                
                showAutoTPNotification(targetPet.name, targetPet.genText, isInDuel, false)
                
                local delaySetting = Config.TpSettings.Speed or 2
                local configDelay = delaySetting == 0 and 0 or delaySetting * 0.2
                if configDelay > 0 then task.wait(configDelay) end
                
                if runTP then runTP() end
            else
                showAutoTPNotification(nil, nil, nil, true)
            end
        end
    else
        if currentHash ~= lastHash then
            consecutiveMatches = 0
        end
    end
    
    lastHash = currentHash
end
        
        while not stableTriggered do
            task.wait(scanDelay)
            pcall(checkAndTeleport)
        end
    end)
end

local function createPlotBeam()
    if not Config.LineToBase then return end
    
    local function findMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        
        local Packages = ReplicatedStorage:FindFirstChild("Packages")
        if Packages then
            local Sync = require(Packages:WaitForChild("Synchronizer"))
            
            for _, plot in ipairs(plots:GetChildren()) do
                local channel = Sync:Get(plot.Name)
                if channel then
                    local owner = channel:Get("Owner")
                    if owner then
                        if (typeof(owner) == "Instance" and owner == LocalPlayer) or
                           (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId) then
                            return plot
                        end
                    end
                end
            end
        end
        
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = label.Text
                        local expectedText = LocalPlayer.DisplayName .. "'s Base"
                        if text == expectedText then
                            return plot
                        end
                    end
                end
            end
        end
        
        return nil
    end
    
    local beamFolder = PlayerGui:FindFirstChild("BaseBeam")
    if not beamFolder then
        beamFolder = Instance.new("Folder")
        beamFolder.Name = "BaseBeam"
        beamFolder.Parent = PlayerGui
    end
    
    local line = beamFolder:FindFirstChild("BaseBeam_Line")
    if not line then
        line = Instance.new("CylinderHandleAdornment")
        line.Name = "BaseBeam_Line"
        line.Transparency = 0.3
        line.Adornee = workspace.Terrain
        line.Color3 = Theme.Accent1
        line.Radius = 0.15
        line.Parent = beamFolder
    end
    
    RunService.RenderStepped:Connect(function()
        if not Config.LineToBase then
            line.Visible = false
            return
        end
        
        local myPlot = findMyPlot()
        if not myPlot then
            line.Visible = false
            return
        end
        
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            line.Visible = false
            return
        end
        
        local plotPart = myPlot:FindFirstChild("MainRootPart") or myPlot:FindFirstChildWhichIsA("BasePart")
        if not plotPart then
            line.Visible = false
            return
        end
        
        local origin = hrp.Position
        local dest = plotPart.Position
        local dist = (dest - origin).Magnitude
        
        line.Height = dist
        line.CFrame = CFrame.lookAt(origin, dest) * CFrame.new(0, 0, -dist/2)
        line.Visible = true
    end)
end

_G.createPlotBeam = createPlotBeam

if Config.LineToBase then
    task.spawn(createPlotBeam)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.LineToBase then
        pcall(createPlotBeam)
    end
end)

task.spawn(function()
    local COOLDOWNS = {
        rocket = 120, ragdoll = 30, balloon = 30, inverse = 60,
        nightvision = 60, jail = 60, tiny = 60, jumpscare = 60, morph = 60
    }
    local ALL_COMMANDS = {
        "balloon", "inverse", "jail", "jumpscare", "morph", 
        "nightvision", "ragdoll", "rocket", "tiny"
    }

    local activeCooldowns = {} 
    SharedState.AdminButtonCache = {} 

    local adminGui = Instance.new("ScreenGui")
    adminGui.Name = "SolanaAdminPanel"
    adminGui.ResetOnSpawn = false
    adminGui.Parent = PlayerGui
    adminGui.Enabled = not Config.HideAdminPanel
    adminGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 452 * MOBILE_SCALE, 0, 0)
    mainFrame.Position = UDim2.new(Config.Positions.AdminPanel.X, 0, Config.Positions.AdminPanel.Y, 0)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = 0.92
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = adminGui
    mainFrame.ZIndex = 1

    local outerBorder = Instance.new("UIStroke", mainFrame)
    outerBorder.Thickness = 1.5 * MOBILE_SCALE
    outerBorder.Transparency = 0.5
    outerBorder.Color = Theme.TextPrimary
    
    local outerGrad = Instance.new("UIGradient", outerBorder)
    outerGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent1)
    }
    
    task.spawn(function()
        while outerBorder.Parent do
            outerGrad.Rotation = (outerGrad.Rotation or 0) + 1
            outerBorder.Transparency = 0.4 + math.sin(outerGrad.Rotation * 0.02) * 0.2
            task.wait(0.02)
        end
    end)
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10 * MOBILE_SCALE)
    
    local dragBar = Instance.new("Frame", mainFrame)
    dragBar.Size = UDim2.new(1, 0, 0, 16 * MOBILE_SCALE)
    dragBar.Position = UDim2.new(0, 0, 0, 0)
    dragBar.BackgroundColor3 = Theme.Surface
    dragBar.BackgroundTransparency = 0.4
    dragBar.BorderSizePixel = 0
    Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0, 10 * MOBILE_SCALE, 0, 10 * MOBILE_SCALE)
    
    local dragHandle = Instance.new("Frame", dragBar)
    dragHandle.Size = UDim2.new(0, 200 * MOBILE_SCALE, 0, 3 * MOBILE_SCALE)
    dragHandle.Position = UDim2.new(0.5, -100 * MOBILE_SCALE, 0.5, -1.5 * MOBILE_SCALE)
    dragHandle.BackgroundColor3 = Theme.TextPrimary
    dragHandle.BackgroundTransparency = 0.5
    dragHandle.BorderSizePixel = 0
    Instance.new("UICorner", dragHandle).CornerRadius = UDim.new(1, 0)
    
    MakeDraggable(dragBar, mainFrame, "AdminPanel")
    
    local contentContainer = Instance.new("Frame", mainFrame)
    contentContainer.Size = UDim2.new(1, -12 * MOBILE_SCALE, 1, -22 * MOBILE_SCALE)
    contentContainer.Position = UDim2.new(0, 6 * MOBILE_SCALE, 0, 20 * MOBILE_SCALE)
    contentContainer.BackgroundTransparency = 1
    
    local playerList = Instance.new("Frame", contentContainer)
    playerList.Size = UDim2.new(1, 0, 1, 0)
    playerList.Position = UDim2.new(0, 0, 0, 0)
    playerList.BackgroundTransparency = 1
    
    local listLayout = Instance.new("UIListLayout", playerList)
    listLayout.Padding = UDim.new(0, 5 * MOBILE_SCALE)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function fireClick(button)
        if button then
            if firesignal then
                firesignal(button.MouseButton1Click)
                firesignal(button.MouseButton1Down)
                firesignal(button.Activated)
            else
                local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
                local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + 58
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            end
        end
    end
    _G.fireClick = fireClick

    local function runAdminCommand(targetPlayer, commandName)
        local realAdminGui = PlayerGui:WaitForChild("AdminPanel", 5)
        if not realAdminGui then return false end
        local contentScroll = realAdminGui.AdminPanel:WaitForChild("Content"):WaitForChild("ScrollingFrame")
        local cmdBtn = contentScroll:FindFirstChild(commandName)
        if not cmdBtn then return false end
        fireClick(cmdBtn)
        task.wait(0.02)
        local profilesScroll = realAdminGui:WaitForChild("AdminPanel"):WaitForChild("Profiles"):WaitForChild("ScrollingFrame")
        local playerBtn = profilesScroll:FindFirstChild(targetPlayer.Name)
        if not playerBtn then return false end
        fireClick(playerBtn)
        return true
    end
    
    _G.runAdminCommand = runAdminCommand

    local function findPlayerPlot(player)
        local Plots = workspace:FindFirstChild("Plots")
        if not Plots then return nil end
        
        for _, plot in ipairs(Plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                local label = surfaceGui and surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                if label then
                    local text = label.Text:lower()
                    if text:find(player.DisplayName:lower(), 1, true) or text:find(player.Name:lower(), 1, true) then
                        return plot
                    end
                end
            end
        end
        return nil
    end

local function teleportToPlayerBase(targetPlayer)
    if not targetPlayer then return false end
    
    local plot = nil
    local Plots = workspace:FindFirstChild("Plots")
    if Plots then
        local dName = targetPlayer.DisplayName:lower()
        local pName = targetPlayer.Name:lower()
        
        for _, p in ipairs(Plots:GetChildren()) do
            local sign = p:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                local label = surfaceGui and surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                if label then
                    local text = label.Text:lower()
                    if text:find(dName, 1, true) or text:find(pName, 1, true) then
                        plot = p
                        break
                    end
                end
            end
        end
    end
    
    if not plot then
        return false
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    
    local plotPos = plot:GetPivot().Position
    local bestSpot = nil
    local bestDist = math.huge
    
    for _, spot in ipairs(CLONE_POSITIONS_FLOOR) do
        local dist = (spot - plotPos).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestSpot = spot
        end
    end
    
    if not bestSpot then
        return false
    end
    
    local Controls = getControls()
    Controls:Disable()
    
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    if carpet then
        hum:EquipTool(carpet)
        task.wait()
    end
    
    local currentX = hrp.Position.X
    local currentY = hrp.Position.Y
    local currentZ = hrp.Position.Z
    
    local isOutsideStandardXRange = currentX > -290 or currentX < -530
    
    if isOutsideStandardXRange then
        local possibleZValues = {165, 60, -50}
        local closestZ = nil
        local minDist = math.huge
        
        for _, zVal in ipairs(possibleZValues) do
            local dist = math.abs(currentZ - zVal)
            if dist < minDist then
                minDist = dist
                closestZ = zVal
            end
        end
        
        if closestZ then
            local newPosition = Vector3.new(currentX, currentY, closestZ)
            hrp.CFrame = CFrame.new(newPosition)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            task.wait()
            currentX = hrp.Position.X
            currentY = hrp.Position.Y
            currentZ = hrp.Position.Z
            task.wait(0.08)
        end
    end
    
    if not (currentX > -470 and currentX < -345) then
        local distToLeft = math.abs(currentX - (-450))
        local distToRight = math.abs(currentX - (-365))
        local targetX = distToLeft < distToRight and -450 or -365
        local targetPos = Vector3.new(targetX, currentY, currentZ)
        
        for i = 1, 6 do
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            if (hrp.Position - targetPos).Magnitude > 3 then
                hrp.CFrame = CFrame.new(targetPos)
                task.wait(0.05)
            end
        end
        currentY = hrp.Position.Y
    end
    
    local plotIndex = tonumber(plot.Name)
    if not plotIndex then
        plotIndex = getClosestBaseIdx(hrp.Position)
    end
    
    local faceX = (plotIndex <= 4) and -1000 or 1000
    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(faceX, hrp.Position.Y, hrp.Position.Z))
    task.wait()
    
    local point165 = Vector3.new(-410, 23, 165)
    local pointNeg50 = Vector3.new(-410, 23, -50)
    local jumpedFrom165 = (hrp.Position - point165).Magnitude <= (hrp.Position - pointNeg50).Magnitude
    local jumpPoint = jumpedFrom165 and point165 or pointNeg50
    hrp.CFrame = CFrame.new(jumpPoint)
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    local targetHeight = 40
    local startTime = tick()
    while hrp.Position.Y < targetHeight and tick() - startTime < 3 do
        local dist = targetHeight - hrp.Position.Y
        local speed = math.clamp(dist * 20, 280, 310)
        hrp.AssemblyLinearVelocity = Vector3.new(0, speed, 0)
        task.wait()
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    for i = 1, 10 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        if (hrp.Position - bestSpot).Magnitude > 3 then
            hrp.CFrame = CFrame.new(bestSpot)
            task.wait()
        end
    end
    
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local facePos = sign:IsA("BasePart") and sign.Position or (sign.PrimaryPart and sign.PrimaryPart.Position)
        if facePos then
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(facePos.X, hrp.Position.Y, facePos.Z))
        end
    end
    
    Controls:Enable()
    return true
end

    local isOnCooldown = function(cmd)
        local adminGui = PlayerGui:FindFirstChild("AdminPanel")
        if adminGui then
            local content = adminGui:FindFirstChild("AdminPanel")
            if content then
                local scrollFrame = content:FindFirstChild("Content")
                if scrollFrame then
                    local scrollingFrame = scrollFrame:FindFirstChild("ScrollingFrame")
                    if scrollingFrame then
                        local cmdButton = scrollingFrame:FindFirstChild(cmd)
                        if cmdButton then
                            local timerLabel = cmdButton:FindFirstChild("Timer")
                            if timerLabel then
                                return timerLabel.Visible
                            end
                        end
                    end
                end
            end
        end
        
        if not activeCooldowns[cmd] then return false end
        return (tick() - activeCooldowns[cmd]) < (COOLDOWNS[cmd] or 0)
    end

    local function setGlobalVisualCooldown(cmd)
        if SharedState.AdminButtonCache[cmd] then
            for _, b in ipairs(SharedState.AdminButtonCache[cmd]) do
                if b and b.Parent then
                    b.BackgroundColor3 = Theme.Error
                    task.delay(COOLDOWNS[cmd] or 5, function()
                        if b and b.Parent then
                            local hasBallooned = (cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                            b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                        end
                    end)
                end
            end
        end
    end

    local function updateBalloonButtons()
        local hasBallooned = false
        for _, _ in pairs(SharedState.BalloonedPlayers) do
            hasBallooned = true
            break
        end
        if SharedState.AdminButtonCache and SharedState.AdminButtonCache["balloon"] then
            for _, b in ipairs(SharedState.AdminButtonCache["balloon"]) do
                if b and b.Parent then
                    b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                end
            end
        end
    end

    local function triggerAll(plr)
        local count = 0
        for _, cmd in ipairs(ALL_COMMANDS) do
            if not isOnCooldown(cmd) then
                task.delay(count * 0.05, function()
                    if runAdminCommand(plr, cmd) then
                        activeCooldowns[cmd] = tick()
                        setGlobalVisualCooldown(cmd)
                        if cmd == "balloon" then
                            SharedState.BalloonedPlayers[plr.UserId] = true
                            updateBalloonButtons()
                        end
                    end
                end)
                count = count + 1
            end
        end
    end

    local function createPlayerRow(plr)
        local row = Instance.new("Frame")
        row.Name = plr.Name
        row.Size = UDim2.new(1, 0, 0, 52 * MOBILE_SCALE)
        row.BackgroundColor3 = Theme.Background
        row.BackgroundTransparency = 0.25
        row.BorderSizePixel = 0
        row.Parent = playerList
        local rowBorder = Instance.new("UIStroke", row)
        rowBorder.Thickness = 1 * MOBILE_SCALE
        rowBorder.Transparency = 0.4
        rowBorder.Color = Theme.TextPrimary
        
        local borderGrad = Instance.new("UIGradient", rowBorder)
        borderGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent1),
            ColorSequenceKeypoint.new(0.5, Theme.Accent2),
            ColorSequenceKeypoint.new(1, Theme.Accent1)
        }
        
        task.spawn(function()
            while rowBorder.Parent do
                borderGrad.Rotation = (borderGrad.Rotation or 0) + 1
                rowBorder.Transparency = 0.3 + math.sin(borderGrad.Rotation * 0.02) * 0.2
                task.wait(0.02)
            end
        end)
        
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8 * MOBILE_SCALE)
        
        row.MouseEnter:Connect(function()
            row.BackgroundTransparency = 0.1
            rowBorder.Thickness = 1.5 * MOBILE_SCALE
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundTransparency = 0.25
            rowBorder.Thickness = 1 * MOBILE_SCALE
        end)
        local spamAllHitbox = Instance.new("TextButton", row)
        spamAllHitbox.Size = UDim2.new(1, -170 * MOBILE_SCALE, 1, 0)
        spamAllHitbox.Position = UDim2.new(0, 0, 0, 0)
        spamAllHitbox.BackgroundTransparency = 1
        spamAllHitbox.Text = ""
        spamAllHitbox.ZIndex = 1
        
        spamAllHitbox.MouseButton1Click:Connect(function()
            local hasAnyAvailable = false
            for _, cmd in ipairs(ALL_COMMANDS) do
                if not isOnCooldown(cmd) then
                    hasAnyAvailable = true
                    break
                end
            end
            if hasAnyAvailable then
                triggerAll(plr)
            else
            end
        end)
        local headshot = Instance.new("ImageLabel", row)
        headshot.Size = UDim2.new(0, 36 * MOBILE_SCALE, 0, 36 * MOBILE_SCALE)
        headshot.Position = UDim2.new(0, 6 * MOBILE_SCALE, 0.5, -18 * MOBILE_SCALE)
        headshot.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
        headshot.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        Instance.new("UICorner", headshot).CornerRadius = UDim.new(1, 0)
        local headshotStroke = Instance.new("UIStroke", headshot)
        headshotStroke.Color = Theme.Accent1
        headshotStroke.Thickness = 1.5 * MOBILE_SCALE
        headshotStroke.Transparency = 0.4
        headshot.ZIndex = 2
        local dName = Instance.new("TextLabel", row)
        dName.Size = UDim2.new(0, 110 * MOBILE_SCALE, 0, 16 * MOBILE_SCALE)
        dName.Position = UDim2.new(0, 48 * MOBILE_SCALE, 0, 8 * MOBILE_SCALE)
        dName.BackgroundTransparency = 1
        dName.Text = plr.DisplayName
        MakeText(dName, true)
        dName.TextSize = 11 * MOBILE_SCALE
        dName.TextColor3 = Theme.TextPrimary
        dName.TextXAlignment = Enum.TextXAlignment.Left
        dName.ZIndex = 2
        local uName = Instance.new("TextLabel", row)
        uName.Size = UDim2.new(0, 110 * MOBILE_SCALE, 0, 14 * MOBILE_SCALE)
        uName.Position = UDim2.new(0, 48 * MOBILE_SCALE, 0, 26 * MOBILE_SCALE)
        uName.BackgroundTransparency = 1
        uName.Font = Enum.Font.Gotham
        uName.TextSize = 9 * MOBILE_SCALE
        uName.TextColor3 = Theme.TextPrimary
        uName.TextXAlignment = Enum.TextXAlignment.Left
        uName.ZIndex = 2

        task.spawn(function()
            while row.Parent do
                task.wait(0.5)
                if not plr or not plr.Parent or not Players:FindFirstChild(plr.Name) then
                    removePlayer(plr)
                    break
                end
                
                local stealing = plr:GetAttribute("Stealing")
                local nearestBrainrotName = plr:GetAttribute("StealingIndex")
                
                if stealing then
                    if nearestBrainrotName then
                        uName.Text = nearestBrainrotName
                        uName.TextColor3 = Color3.fromRGB(255, 70, 90)
                        uName.Font = Enum.Font.GothamBold
                        uName.TextSize = 9 * MOBILE_SCALE
                    else
                        uName.Text = "Stealing"
                        uName.TextColor3 = Color3.fromRGB(255, 70, 90)
                        uName.Font = Enum.Font.GothamBold
                        uName.TextSize = 9 * MOBILE_SCALE
                    end
                else
                    uName.Text = "@" .. plr.Name
                    uName.TextColor3 = Theme.TextPrimary
                    uName.Font = Enum.Font.Gotham
                    uName.TextSize = 9 * MOBILE_SCALE
                end
            end
        end)

        local btnCont = Instance.new("Frame", row)
        btnCont.Size = UDim2.new(0, 210 * MOBILE_SCALE, 1, 0)
        btnCont.Position = UDim2.new(1, -195 * MOBILE_SCALE, 0, 0)
        btnCont.BackgroundTransparency = 1
        btnCont.ZIndex = 3

        local buttonsDef = {
            {icon = "ðŸš€", cmd = "rocket"},
            {icon = "ðŸƒ", cmd = "ragdoll"},
            {icon = "ðŸ”’", cmd = "jail"},
            {icon = "ðŸŽˆ", cmd = "balloon"},
            {icon = "TP", cmd = "tp"}
        }

        for i, def in ipairs(buttonsDef) do
            local b = Instance.new("TextButton", btnCont)
            b.Size = UDim2.new(0, 28 * MOBILE_SCALE, 0, 28 * MOBILE_SCALE)
            b.Position = UDim2.new(0, (i-1)*38 * MOBILE_SCALE, 0.5, -14 * MOBILE_SCALE)
            b.AutoButtonColor = false
            b.Text = def.icon
            b.TextSize = 12 * MOBILE_SCALE
            b.TextColor3 = Theme.TextPrimary
            b.Font = Enum.Font.GothamBold
            b.Active = true
            
            if def.cmd == "tp" then
                b.Text = "TP"
                b.TextSize = 9 * MOBILE_SCALE
                b.BackgroundColor3 = Theme.SurfaceHighlight
                b.BackgroundTransparency = 0.08
            else
                local hasBallooned = SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil
                local isOnCD = isOnCooldown(def.cmd)
                b.BackgroundColor3 = (def.cmd == "balloon" and hasBallooned) or isOnCD and Theme.Error or Theme.SurfaceHighlight
                b.BackgroundTransparency = 0.08
            end
            
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6 * MOBILE_SCALE)
            
            b.MouseEnter:Connect(function()
                if def.cmd == "tp" then
                    b.BackgroundColor3 = Theme.SurfaceLight
                elseif not isOnCooldown(def.cmd) and not (def.cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil) then
                    b.BackgroundColor3 = Theme.SurfaceLight
                end
            end)
            b.MouseLeave:Connect(function()
                if def.cmd == "tp" then
                    b.BackgroundColor3 = Theme.SurfaceHighlight
                elseif not isOnCooldown(def.cmd) and not (def.cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil) then
                    b.BackgroundColor3 = Theme.SurfaceHighlight
                end
            end)
            
            if not SharedState.AdminButtonCache[def.cmd] then SharedState.AdminButtonCache[def.cmd] = {} end
            table.insert(SharedState.AdminButtonCache[def.cmd], b)

            task.spawn(function()
                while b and b.Parent do
                    task.wait(0.05)
                    if def.cmd == "tp" then
                        if b.BackgroundColor3 ~= Theme.SurfaceHighlight and b.BackgroundColor3 ~= Theme.SurfaceLight then
                            b.BackgroundColor3 = Theme.SurfaceHighlight
                        end
                    else
                        local cd = isOnCooldown(def.cmd)
                        local balloon = (def.cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                        if cd or balloon then
                            b.BackgroundColor3 = Theme.Error
                        elseif b.BackgroundColor3 ~= Theme.SurfaceHighlight then
                            b.BackgroundColor3 = Theme.SurfaceHighlight
                        end
                    end
                end
            end)

            b.MouseButton1Click:Connect(function()
                if def.cmd == "tp" then
                    teleportToPlayerBase(plr)
                else
                    if runAdminCommand(plr, def.cmd) then
                        activeCooldowns[def.cmd] = tick()
                        setGlobalVisualCooldown(def.cmd)
                        if def.cmd == "balloon" then
                            SharedState.BalloonedPlayers[plr.UserId] = true
                            for _, btn in ipairs(SharedState.AdminButtonCache["balloon"] or {}) do
                                if btn and btn.Parent then btn.BackgroundColor3 = Theme.Error end
                            end
                        end
                    else
                    end
                end
            end)
        end
        
        return row
    end

    local playerRows = {}
    local playerRowsByUserId = {}
    
    local function updateContainerSize()
        local totalHeight = (listLayout.AbsoluteContentSize.Y or 0) + 8 * MOBILE_SCALE
        mainFrame.Size = UDim2.new(0, 452 * MOBILE_SCALE, 0, totalHeight + 20 * MOBILE_SCALE)
    end
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateContainerSize()
    end)
    
    local function addPlayer(plr)
        if plr == LocalPlayer or playerRowsByUserId[plr.UserId] then return end
        if not Players:FindFirstChild(plr.Name) then return end
        if Config.HideKawaifuFromPanel and isKawaifuUser(plr) then return end
        
        if playerRows[plr] then return end
        
        local row = createPlayerRow(plr)
        playerRows[plr] = row
        playerRowsByUserId[plr.UserId] = {player = plr, row = row}
        updateContainerSize()
    end
    
    local function removePlayer(plr)
        local userId = plr and plr.UserId or nil
        local entry = userId and playerRowsByUserId[userId] or nil
        local row = entry and entry.row or playerRows[plr]
        
        if row then
            if row.Parent then
                for cmd, buttons in pairs(SharedState.AdminButtonCache) do
                    for i = #buttons, 1, -1 do
                        if buttons[i] and buttons[i].Parent == row then
                            table.remove(buttons, i)
                        end
                    end
                end
                row:Destroy()
            end
            if plr then
                playerRows[plr] = nil
            end
            if userId then
                playerRowsByUserId[userId] = nil
            end
            if SharedState.BalloonedPlayers and userId then
                SharedState.BalloonedPlayers[userId] = nil
            end
            updateContainerSize()
        end
    end

    Players.PlayerAdded:Connect(function(plr)
        task.wait(0.1)
        if plr and plr.Parent and plr ~= LocalPlayer then
            addPlayer(plr)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(plr)
        removePlayer(plr)
    end)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then 
            addPlayer(p)
        end
    end
end)

task.spawn(function()
    local function addNeonBorder(frame)
        local border = Instance.new("UIStroke", frame)
        border.Thickness = 1.5
        border.Transparency = 0.3
        border.Color = Color3.fromRGB(138, 43, 226)
        local grad = Instance.new("UIGradient", border)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 191, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        }
        task.spawn(function()
            while border.Parent do
                grad.Rotation = (grad.Rotation or 0) + 1
                border.Transparency = 0.2 + math.sin(grad.Rotation * 0.02) * 0.2
                task.wait(0.02)
            end
        end)
    end
    
    local ProximityAPActive = false
    local PROXIMITY_RANGE = Config.ProximityRange or 15
    
    local proxViz = nil
    local function updateProxRing()
        if ProximityAPActive then
            if not proxViz or not proxViz.Parent then
                proxViz = Instance.new("Part")
                proxViz.Name = "SolanaProxRing"
                proxViz.Anchored = true
                proxViz.CanCollide = false
                proxViz.Shape = Enum.PartType.Cylinder
                proxViz.Color = Color3.fromRGB(170, 0, 255)
                proxViz.Transparency = 0.65
                proxViz.CastShadow = false
                proxViz.Material = Enum.Material.Neon
                proxViz.Parent = workspace
                
                local glowRing = Instance.new("Part")
                glowRing.Name ="SolanaProxRingGlow"
                glowRing.Anchored = true
                glowRing.CanCollide = false
                glowRing.Shape = Enum.PartType.Cylinder
                glowRing.Color = Color3.fromRGB(200, 80, 255)
                glowRing.Transparency = 0.8
                glowRing.CastShadow = false
                glowRing.Material = Enum.Material.Neon
                glowRing.Parent = proxViz
            end
            
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local radius = PROXIMITY_RANGE
                local diameter = radius * 2
                
                proxViz.Size = Vector3.new(0.1, diameter, diameter)
                proxViz.CFrame = (hrp.CFrame * CFrame.new(0, -3.2, 0)) * CFrame.Angles(0, 0, math.rad(90))
                proxViz.Transparency = 0.55
                
                local glowRing = proxViz:FindFirstChild("SolanaProxRingGlow")
                if glowRing then
                    glowRing.Size = Vector3.new(0.05, diameter + 0.8, diameter + 0.8)
                    glowRing.CFrame = proxViz.CFrame
                    glowRing.Transparency = 0.75
                end
                
                local pulse = (math.sin(tick() * 4) + 1) / 2
                local pColor1 = Color3.fromRGB(140, 0, 255)
                local pColor2 = Color3.fromRGB(210, 100, 255)
                proxViz.Color = pColor1:Lerp(pColor2, pulse)
                if glowRing then
                    glowRing.Color = pColor2:Lerp(pColor1, pulse)
                end
            end
        else
            if proxViz and proxViz.Parent then
                proxViz:Destroy()
                proxViz = nil
            end
        end
    end
    
    RunService.RenderStepped:Connect(function()
        updateProxRing()
    end)
    
    local adminControlGui = Instance.new("ScreenGui")
    adminControlGui.Name = "SolanaAdminControl"
    adminControlGui.ResetOnSpawn = false
    adminControlGui.Parent = PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280 * MOBILE_SCALE, 0, 0)
    mainFrame.Position = UDim2.new(Config.Positions.AdminControl and Config.Positions.AdminControl.X or 0.02, 0, 
                                   Config.Positions.AdminControl and Config.Positions.AdminControl.Y or 0.5, 0)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = adminControlGui
    
    local function savePosition()
        local parentSize = mainFrame.Parent.AbsoluteSize
        Config.Positions.AdminControl = {
            X = mainFrame.AbsolutePosition.X / parentSize.X,
            Y = mainFrame.AbsolutePosition.Y / parentSize.Y,
        }
        SaveConfig()
    end
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12 * MOBILE_SCALE)
    local borderStroke = Instance.new("UIStroke", mainFrame)
    borderStroke.Thickness = 1.5 * MOBILE_SCALE
    borderStroke.Transparency = 0.3
    borderStroke.Color = Theme.TextPrimary
    
    local borderGrad = Instance.new("UIGradient", borderStroke)
    borderGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent1)
    }
    
    task.spawn(function()
        while borderStroke.Parent do
            borderGrad.Rotation = (borderGrad.Rotation or 0) + 1
            borderStroke.Transparency = 0.2 + math.sin(borderGrad.Rotation * 0.02) * 0.2
            task.wait(0.02)
        end
    end)
    
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 40 * MOBILE_SCALE)
    header.BackgroundTransparency = 1
    MakeDraggable(header, mainFrame, "AdminControl")
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -60 * MOBILE_SCALE, 1, 0)
    title.Position = UDim2.new(0, 15 * MOBILE_SCALE, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Admin Control"
    title.Font = Enum.Font.Gotham
    title.TextSize = 14 * MOBILE_SCALE
    title.TextColor3 = Theme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextStrokeTransparency = 1
    
    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(1, -20 * MOBILE_SCALE, 1, -48 * MOBILE_SCALE)
    content.Position = UDim2.new(0, 10 * MOBILE_SCALE, 0, 44 * MOBILE_SCALE)
    content.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8 * MOBILE_SCALE)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function createToggleRow(text, defaultValue, callback)
        local rowBtn = Instance.new("TextButton", content)
        rowBtn.Size = UDim2.new(1, 0, 0, 34 * MOBILE_SCALE)
        rowBtn.BackgroundColor3 = Theme.Surface
        rowBtn.BackgroundTransparency = 0.08
        rowBtn.BorderSizePixel = 0
        rowBtn.Text = ""
        rowBtn.AutoButtonColor = false
        Instance.new("UICorner", rowBtn).CornerRadius = UDim.new(0, 8 * MOBILE_SCALE)
        addNeonBorder(rowBtn)
        
        local lbl = Instance.new("TextLabel", rowBtn)
        lbl.Size = UDim2.new(0.65, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12 * MOBILE_SCALE, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11 * MOBILE_SCALE
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextStrokeTransparency = 1
        lbl.ZIndex = 2
        
        local isOn = defaultValue or false
        local toggleFrame = Instance.new("Frame", rowBtn)
        toggleFrame.Size = UDim2.new(0, 40 * MOBILE_SCALE, 0, 20 * MOBILE_SCALE)
        toggleFrame.Position = UDim2.new(1, -52 * MOBILE_SCALE, 0.5, -10 * MOBILE_SCALE)
        toggleFrame.BackgroundColor3 = isOn and Theme.Success or Theme.SurfaceHighlight
        toggleFrame.BorderSizePixel = 0
        toggleFrame.ZIndex = 2
        Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)
        
        local toggleDot = Instance.new("Frame", toggleFrame)
        toggleDot.Size = UDim2.new(0, 16 * MOBILE_SCALE, 0, 16 * MOBILE_SCALE)
        toggleDot.Position = isOn and UDim2.new(1, -18 * MOBILE_SCALE, 0.5, -8 * MOBILE_SCALE) or UDim2.new(0, 2 * MOBILE_SCALE, 0.5, -8 * MOBILE_SCALE)
        toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleDot.ZIndex = 3
        Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(1, 0)
        
        rowBtn.MouseButton1Click:Connect(function()
            isOn = not isOn
            local newPos = isOn and UDim2.new(1, -18 * MOBILE_SCALE, 0.5, -8 * MOBILE_SCALE) or UDim2.new(0, 2 * MOBILE_SCALE, 0.5, -8 * MOBILE_SCALE)
            local newColor = isOn and Theme.Success or Theme.SurfaceHighlight
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = newPos}):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
            callback(isOn)
        end)
        
        rowBtn.MouseEnter:Connect(function()
            rowBtn.BackgroundTransparency = 0.05
        end)
        rowBtn.MouseLeave:Connect(function()
            rowBtn.BackgroundTransparency = 0.08
        end)
        
        return rowBtn
    end
    
    local function createButtonRow(text, buttonColor, callback)
        local rowBtn = Instance.new("TextButton", content)
        rowBtn.Size = UDim2.new(1, 0, 0, 34 * MOBILE_SCALE)
        rowBtn.BackgroundColor3 = buttonColor or Theme.Accent1
        rowBtn.BackgroundTransparency = 0.08
        rowBtn.BorderSizePixel = 0
        rowBtn.Text = text
        rowBtn.Font = Enum.Font.Gotham
        rowBtn.TextSize = 11 * MOBILE_SCALE
        rowBtn.TextColor3 = Color3.new(1, 1, 1)
        rowBtn.TextStrokeTransparency = 1
        Instance.new("UICorner", rowBtn).CornerRadius = UDim.new(0, 6 * MOBILE_SCALE)
        
        rowBtn.MouseButton1Click:Connect(function()
            TweenService:Create(rowBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Success}):Play()
            task.wait(0.1)
            TweenService:Create(rowBtn, TweenInfo.new(0.1), {BackgroundColor3 = buttonColor or Theme.Accent1}):Play()
            callback()
        end)
        
        rowBtn.MouseEnter:Connect(function()
            rowBtn.BackgroundTransparency = 0.05
        end)
        rowBtn.MouseLeave:Connect(function()
            rowBtn.BackgroundTransparency = 0.08
        end)
        
        return rowBtn
    end
    
    local function createCompactSliderRow(text, min, max, default, suffix, callback)
        local row = Instance.new("Frame", content)
        row.Size = UDim2.new(1, 0, 0, 46 * MOBILE_SCALE)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0.08
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8 * MOBILE_SCALE)
        addNeonBorder(row)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 0, 18 * MOBILE_SCALE)
        lbl.Position = UDim2.new(0, 12 * MOBILE_SCALE, 0, 5 * MOBILE_SCALE)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11 * MOBILE_SCALE
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextStrokeTransparency = 1
        
        local value = default or min
        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size = UDim2.new(0, 50 * MOBILE_SCALE, 0, 18 * MOBILE_SCALE)
        valLbl.Position = UDim2.new(1, -60 * MOBILE_SCALE, 0, 5 * MOBILE_SCALE)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(value) .. (suffix or "")
        valLbl.Font = Enum.Font.Gotham
        valLbl.TextSize = 11 * MOBILE_SCALE
        valLbl.TextColor3 = Theme.Accent1
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.TextStrokeTransparency = 1
        
        local sliderBg = Instance.new("Frame", row)
        sliderBg.Size = UDim2.new(1, -24 * MOBILE_SCALE, 0, 4 * MOBILE_SCALE)
        sliderBg.Position = UDim2.new(0, 12 * MOBILE_SCALE, 0, 30 * MOBILE_SCALE)
        sliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame", sliderBg)
        fill.BackgroundColor3 = Theme.Accent1
        fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame", sliderBg)
        knob.Size = UDim2.new(0, 12 * MOBILE_SCALE, 0, 12 * MOBILE_SCALE)
        knob.BackgroundColor3 = Theme.TextPrimary
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new((value - min)/(max - min), 0, 0.5, 0)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        local function updateSlider(inputX)
        local pos = sliderBg.AbsolutePosition.X
        local size = sliderBg.AbsoluteSize.X
        local pct = math.clamp((inputX - pos) / size, 0, 1)
        value = min + (pct * (max - min))
        if math.abs(value - math.floor(value)) < 0.01 then
        value = math.floor(value)
        else
        value = math.floor(value * 10) / 10
        end
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valLbl.Text = tostring(value) .. (suffix or "")
        if callback then callback(value) end
        end
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
        
        return row
    end
    
    local clickToAPHighlight = nil
    local function createClickToAPHighlight()
        if clickToAPHighlight then return end
        clickToAPHighlight = Instance.new("Highlight")
        clickToAPHighlight.Name = "ClickToAPHighlight"
        clickToAPHighlight.FillColor = Theme.Accent1
        clickToAPHighlight.FillTransparency = 0.5
        clickToAPHighlight.OutlineColor = Theme.Accent2
        clickToAPHighlight.OutlineTransparency = 0.2
        clickToAPHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        clickToAPHighlight.Parent = game:GetService("CoreGui")
    end
    
    local function rayToCubeIntersect(rayOrigin, rayDirection, cubeCenter, cubeSize)
        local halfSize = cubeSize / 2
        local minBounds = cubeCenter - Vector3.new(halfSize, halfSize, halfSize)
        local maxBounds = cubeCenter + Vector3.new(halfSize, halfSize, halfSize)
        if rayDirection.X == 0 then rayDirection = Vector3.new(0.0001, rayDirection.Y, rayDirection.Z) end
        if rayDirection.Y == 0 then rayDirection = Vector3.new(rayDirection.X, 0.0001, rayDirection.Z) end
        if rayDirection.Z == 0 then rayDirection = Vector3.new(rayDirection.X, rayDirection.Y, 0.0001) end
        local tmin = (minBounds.X - rayOrigin.X) / rayDirection.X
        local tmax = (maxBounds.X - rayOrigin.X) / rayDirection.X
        if tmin > tmax then tmin, tmax = tmax, tmin end
        local tymin = (minBounds.Y - rayOrigin.Y) / rayDirection.Y
        local tymax = (maxBounds.Y - rayOrigin.Y) / rayDirection.Y
        if tymin > tymax then tymin, tymax = tymax, tymin end
        if tmin > tymax or tymin > tmax then return false end
        if tymin > tmin then tmin = tymin end
        if tymax < tmax then tmax = tymax end
        local tzmin = (minBounds.Z - rayOrigin.Z) / rayDirection.Z
        local tzmax = (maxBounds.Z - rayOrigin.Z) / rayDirection.Z
        if tzmin > tzmax then tzmin, tzmax = tzmax, tzmin end
        if tmin > tzmax or tzmin > tmax then return false end
        return true
    end
    
    local function getPlayerHitboxPart(player)
        local char = player.Character
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    end
    
    task.spawn(function()
        createClickToAPHighlight()
        local lastHoveredPlayer = nil
Heartbeat:Connect(function()

            if Config.ClickToAP then
                local camera = Workspace.CurrentCamera
                local mousePos = UserInputService:GetMouseLocation()
                local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                local hitboxSize = 6
                local bestPlayer = nil
                local bestDistance = math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then
                        local hitboxPart = getPlayerHitboxPart(p)
                        if hitboxPart then
                            local cubeCenter = hitboxPart.Position
                            if rayToCubeIntersect(ray.Origin, ray.Direction, cubeCenter, hitboxSize) then
                                local distance = (ray.Origin - cubeCenter).Magnitude
                                if distance < bestDistance then
                                    bestDistance = distance
                                    bestPlayer = p
                                end
                            end
                        end
                    end
                end
                if bestPlayer ~= lastHoveredPlayer then
                    if bestPlayer then clickToAPHighlight.Adornee = bestPlayer.Character
                    else clickToAPHighlight.Adornee = nil end
                    lastHoveredPlayer = bestPlayer
                end
            elseif clickToAPHighlight then
                clickToAPHighlight.Adornee = nil
            end
        end)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.ClickToAP then
            local camera = Workspace.CurrentCamera
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local hitboxSize = 6
            local bestPlayer = nil
            local bestDistance = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local hitboxPart = getPlayerHitboxPart(p)
                    if hitboxPart then
                        local cubeCenter = hitboxPart.Position
                        if rayToCubeIntersect(ray.Origin, ray.Direction, cubeCenter, hitboxSize) then
                            local distance = (ray.Origin - cubeCenter).Magnitude
                            if distance < bestDistance then
                                bestDistance = distance
                                bestPlayer = p
                            end
                        end
                    end
                end
            end
            if bestPlayer then
                task.spawn(function()
                    local cmds = {"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"}
                    for _, cmd in ipairs(cmds) do
                        if _G.runAdminCommand then _G.runAdminCommand(bestPlayer, cmd) end
                        task.wait(0.08)
                    end
                end)
            end
        end
    end)
    
    createToggleRow("Proximity AP", false, function(on)
        ProximityAPActive = on
        updateProxRing()
    end)
    
    createCompactSliderRow("Proximity Range", 5, 50, PROXIMITY_RANGE, "s", function(val)
        PROXIMITY_RANGE = val
        Config.ProximityRange = val
        SaveConfig()
        updateProxRing()
    end)
    
    createToggleRow("Click to AP", Config.ClickToAP, function(on)
        Config.ClickToAP = on
        SaveConfig()
    end)
    
    createButtonRow("Spam Owner", Theme.Accent1, function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end
        
        local nearestPlot = nil
        local nearestDist = math.huge
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            for _, plot in ipairs(Plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local signPos = sign:IsA("BasePart") and sign.Position or (sign.PrimaryPart and sign.PrimaryPart.Position)
                    if signPos then
                        local dist = (hrp.Position - signPos).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestPlot = plot
                        end
                    end
                end
            end
        end
        
        if not nearestPlot then
            return
        end
        
        local targetPlayer = nil
        local ok, ch = pcall(function() 
            local Packages = ReplicatedStorage:FindFirstChild("Packages")
            if Packages then
                local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
                return Synchronizer:Get(nearestPlot.Name)
            end
            return nil
        end)
        if ok and ch then
            local owner = ch:Get("Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then
                    targetPlayer = owner
                elseif type(owner) == "table" and owner.Name then
                    targetPlayer = Players:FindFirstChild(owner.Name)
                end
            end
        end
        
        if not targetPlayer then
            local sign = nearestPlot:FindFirstChild("PlotSign")
            local textLabel = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
            if textLabel then
                local baseText = textLabel.Text
                local nickname = baseText and baseText:match("^(.-)'") or baseText
                if nickname then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.DisplayName == nickname or p.Name == nickname then
                            targetPlayer = p
                            break
                        end
                    end
                end
            end
        end
        
        if not targetPlayer or targetPlayer == LocalPlayer then
            return
        end
        
        
        task.spawn(function()
            local cmds = {"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"}
            local cmdCount = 0
            for _, cmd in ipairs(cmds) do
                if _G.runAdminCommand then
                    local success = _G.runAdminCommand(targetPlayer, cmd)
                    if success then cmdCount = cmdCount + 1 end
                end
                task.wait(0.1)
            end
        end)
    end)
    
    createButtonRow("Spam Nearest", Theme.Accent1, function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end
        
        local nearestPlayer = nil
        local nearestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPlayer = p
                end
            end
        end
        
        if not nearestPlayer then
            return
        end
        
        
        task.spawn(function()
            local cmds = {"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"}
            for _, cmd in ipairs(cmds) do
                if _G.runAdminCommand then _G.runAdminCommand(nearestPlayer, cmd) end
                task.wait(0.1)
            end
        end)
    end)
    
local proxAPCooldown = 0
local proxAPLastTrigger = 0
local PROX_AP_INTERVAL = 0.5
local COMMAND_DELAY = 0.08

Heartbeat:Connect(function(dt)
    if not ProximityAPActive then return end
    
    proxAPCooldown = proxAPCooldown + dt
    if proxAPCooldown < PROX_AP_INTERVAL then return end
    proxAPCooldown = 0
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    local playersInRange = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
            if dist <= PROXIMITY_RANGE then
                table.insert(playersInRange, p)
            end
        end
    end
    
    if #playersInRange == 0 then return end
    
    local target = playersInRange[1]
    local cmds = {"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"}
    
    task.spawn(function()
        for _, cmd in ipairs(cmds) do
            if _G.runAdminCommand then
                _G.runAdminCommand(target, cmd)
            end
            task.wait(COMMAND_DELAY)
        end
    end)
end)
    
    local function updateFrameHeight()
        local totalHeight = layout.AbsoluteContentSize.Y + 56 * MOBILE_SCALE
        mainFrame.Size = UDim2.new(0, 280 * MOBILE_SCALE, 0, totalHeight)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateFrameHeight)
    task.defer(updateFrameHeight)
end)

task.spawn(function()
    local quickGui = Instance.new("ScreenGui")
    quickGui.Name = "SolanaQuickPanel"
    quickGui.ResetOnSpawn = false
    quickGui.Enabled = Config.ShowQuickPanel
    quickGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200 * MOBILE_SCALE, 0, 350 * MOBILE_SCALE)
    frame.Position = UDim2.new(Config.Positions.QuickPanel.X, 0, Config.Positions.QuickPanel.Y, 0)
    frame.BackgroundColor3 = Theme.Background
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = quickGui

    AddMobileMinimize(frame, "QUICK")

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12 * MOBILE_SCALE)
    AddAnimatedBorder(frame, 1.5)

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, 0, 0, 40 * MOBILE_SCALE)
    header.BackgroundTransparency = 1
    MakeDraggable(header, frame, "QuickPanel")

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Quick Panel"
    MakeText(title, true)
    title.TextSize = 18 * MOBILE_SCALE
    title.TextColor3 = Theme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Center

    local content = Instance.new("Frame", frame)
    content.Size = UDim2.new(1, -20 * MOBILE_SCALE, 1, -50 * MOBILE_SCALE)
    content.Position = UDim2.new(0, 10 * MOBILE_SCALE, 0, 45 * MOBILE_SCALE)
    content.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8 * MOBILE_SCALE)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateQuickButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35 * MOBILE_SCALE)
        btn.BackgroundColor3 = Theme.Accent1
        btn.BackgroundTransparency = 0.08
        btn.Text = text
        MakeText(btn, true)
        btn.TextSize = 12 * MOBILE_SCALE
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = content
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8 * MOBILE_SCALE)

        btn.MouseButton1Click:Connect(function()
            callback()
        end)
        return btn
    end

    CreateQuickButton("Ragdoll Self", function()
        if _G.runAdminCommand then
            _G.runAdminCommand(LocalPlayer, "ragdoll")
        end
    end)

    CreateQuickButton("Reset Character", function()
        executeReset()
    end)

    CreateQuickButton("Rejoin Server", function()
        rejoinGame()
    end)

    CreateQuickButton("Kick Game", function()
        game:Shutdown()
    end)

    CreateQuickButton("Teleport", function()
        runTP()
    end)

    CreateQuickButton("Instant Clone", function()
        Clone()
    end)

    CreateQuickButton("Carpet Speed", function()
        carpetSpeedEnabled = not carpetSpeedEnabled
        setCarpetSpeed(carpetSpeedEnabled)
    end)

    local keybindText = Instance.new("TextLabel", content)
    keybindText.Size = UDim2.new(1, 0, 0, 20 * MOBILE_SCALE)
    keybindText.BackgroundTransparency = 1
    keybindText.Text = "Keybind: " .. (Config.QuickPanelKey or "B")
    MakeText(keybindText, false)
    keybindText.TextSize = 11 * MOBILE_SCALE
    keybindText.TextColor3 = Theme.TextMuted
end)

local function CreateStatusHUD()
    local existing = PlayerGui:FindFirstChild("SolanaStatusHUD")
    if existing then existing:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SolanaStatusHUD"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    local HUD_HEIGHT = 75 * MOBILE_SCALE
    local HUD_WIDTH = 680 * MOBILE_SCALE
    local UNLOCK_HEIGHT = 52 * MOBILE_SCALE

    local mainContainer = Instance.new("Frame", gui)
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0, HUD_WIDTH, 0, HUD_HEIGHT + UNLOCK_HEIGHT)
    mainContainer.Position = UDim2.new(Config.Positions.StatusHUD.X, -HUD_WIDTH/2, Config.Positions.StatusHUD.Y, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.ClipsDescendants = false

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, HUD_WIDTH, 0, HUD_HEIGHT)
    main.Position = UDim2.new(0, 0, 0, 0)
    main.BackgroundColor3 = Theme.Background
    main.BackgroundTransparency = 0.08
    main.BorderSizePixel = 0
    main.Parent = mainContainer

    local cornerRadius = 20 * MOBILE_SCALE
    local mainCorner = Instance.new("UICorner", main)
    mainCorner.CornerRadius = UDim.new(0, cornerRadius)
    
    local mainBorder = Instance.new("UIStroke", main)
    mainBorder.Thickness = 2 * MOBILE_SCALE
    mainBorder.Transparency = 0.3
    mainBorder.Color = Theme.TextPrimary
    mainBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local mainBorderGrad = Instance.new("UIGradient", mainBorder)
    mainBorderGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent1)
    }
    
    task.spawn(function()
        while mainBorder.Parent do
            mainBorderGrad.Rotation = (mainBorderGrad.Rotation or 0) + 1
            mainBorder.Transparency = 0.2 + math.sin(mainBorderGrad.Rotation * 0.02) * 0.2
            task.wait(0.02)
        end
    end)

    local unlockContainer = Instance.new("Frame", mainContainer)
    unlockContainer.Name = "UnlockButtonsContainer"
    unlockContainer.Size = UDim2.new(0, 150 * MOBILE_SCALE, 0, 38 * MOBILE_SCALE)
    unlockContainer.Position = UDim2.new(0.5, -75 * MOBILE_SCALE, 0, HUD_HEIGHT + 8 * MOBILE_SCALE)
    unlockContainer.BackgroundTransparency = 1
    unlockContainer.Visible = Config.ShowUnlockButtonsHUD
    
    local unlockCorner = Instance.new("UICorner", unlockContainer)
    unlockCorner.CornerRadius = UDim.new(0, 10 * MOBILE_SCALE)
    
    local unlockBg = Instance.new("Frame", unlockContainer)
    unlockBg.Size = UDim2.new(1, 0, 1, 0)
    unlockBg.BackgroundColor3 = Theme.Background
    unlockBg.BackgroundTransparency = 0.08
    unlockBg.BorderSizePixel = 0
    local unlockBgCorner = Instance.new("UICorner", unlockBg)
    unlockBgCorner.CornerRadius = UDim.new(0, 10 * MOBILE_SCALE)
    
    local unlockBorder = Instance.new("UIStroke", unlockContainer)
    unlockBorder.Thickness = 1.5 * MOBILE_SCALE
    unlockBorder.Transparency = 0.4
    unlockBorder.Color = Theme.TextPrimary
    unlockBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local unlockBorderGrad = Instance.new("UIGradient", unlockBorder)
    unlockBorderGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent1)
    }
    
    task.spawn(function()
        while unlockBorder.Parent do
            unlockBorderGrad.Rotation = (unlockBorderGrad.Rotation or 0) + 1
            unlockBorder.Transparency = 0.3 + math.sin(unlockBorderGrad.Rotation * 0.02) * 0.2
            task.wait(0.02)
        end
    end)
    
    local btnSize = 32 * MOBILE_SCALE
    local btnSpacing = 12 * MOBILE_SCALE
    local totalWidth = (btnSize * 3) + (btnSpacing * 2)
    local startX = (150 * MOBILE_SCALE - totalWidth) / 2
    
    local function getPlotOwnerName(plot)
        if not plot then return "Unknown" end
        
        local Packages = ReplicatedStorage:FindFirstChild("Packages")
        if Packages then
            local ok, Sync = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
            if ok and Sync then
                local ok2, channel = pcall(function() return Sync:Get(plot.Name) end)
                if ok2 and channel then
                    local owner = channel:Get("Owner")
                    if owner then
                        if typeof(owner) == "Instance" and owner:IsA("Player") then
                            return owner.DisplayName
                        elseif type(owner) == "table" and owner.Name then
                            local player = Players:FindFirstChild(owner.Name)
                            if player then return player.DisplayName end
                            return owner.Name
                        end
                    end
                end
            end
        end
        
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
            if surfaceGui then
                local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                if label then
                    local text = label.Text
                    local nickname = text:match("^(.-)'") or text
                    return nickname
                end
            end
        end
        
        return "Unknown"
    end
    
    local function findClosestUnlockAtLevel(targetLevel)
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, nil, nil end
        
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil, nil, nil end
        
        local targetY = nil
        if targetLevel == 1 then
            targetY = -2
        elseif targetLevel == 2 then
            targetY = 15
        elseif targetLevel == 3 then
            targetY = 27
        end
        
        if not targetY then return nil, nil, nil end
        
        local closestPrompt = nil
        local closestDist = math.huge
        local closestPlot = nil
        
        for _, plot in ipairs(plots:GetChildren()) do
            local unlockFolder = plot:FindFirstChild("Unlock")
            if unlockFolder then
                for _, item in ipairs(unlockFolder:GetChildren()) do
                    local part = nil
                    local pos = nil
                    
                    if item:IsA("Model") then
                        pcall(function() pos = item:GetPivot().Position end)
                        part = item:FindFirstChildWhichIsA("BasePart", true)
                    elseif item:IsA("BasePart") then
                        pos = item.Position
                        part = item
                    end
                    
                    if pos and part then
                        if math.abs(pos.Y - targetY) < 5 then
                            for _, desc in ipairs(part:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") and desc.Enabled then
                                    local dist = (hrp.Position - pos).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestPrompt = desc
                                        closestPlot = plot
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return closestPrompt, closestDist, closestPlot
    end
    
    for i = 1, 3 do
        local btn = Instance.new("TextButton", unlockContainer)
        btn.Name = "UnlockBtn_" .. i
        btn.Size = UDim2.new(0, btnSize, 0, btnSize)
        btn.Position = UDim2.new(0, startX + ((i-1) * (btnSize + btnSpacing)), 0.5, -btnSize/2)
        btn.BackgroundColor3 = Theme.Surface
        btn.BackgroundTransparency = 0.08
        btn.Text = tostring(i)
        btn.TextSize = 14 * MOBILE_SCALE
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.Gotham
        btn.TextStrokeTransparency = 1
        btn.BorderSizePixel = 0
        btn.ZIndex = 2
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 6 * MOBILE_SCALE)
        
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Theme.Accent1
        btnStroke.Thickness = 1 * MOBILE_SCALE
        btnStroke.Transparency = 0.5
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceLight}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.2, Thickness = 1.5 * MOBILE_SCALE}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.5, Thickness = 1 * MOBILE_SCALE}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent1}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Surface}):Play()
            
            local foundPrompt, distance, foundPlot = findClosestUnlockAtLevel(i)
            
            if foundPrompt then
                local plotOwner = getPlotOwnerName(foundPlot)
                local levelName = i == 1 and "Basement" or (i == 2 and "Main" or "Roof")
                
                if fireproximityprompt then
                    fireproximityprompt(foundPrompt)
                else
                    foundPrompt:InputBegan(Enum.UserInputType.MouseButton1)
                    task.wait(0.05)
                    foundPrompt:InputEnded(Enum.UserInputType.MouseButton1)
                end
                
                ShowNotification("Unlock", levelName .. " - " .. plotOwner .. " (" .. math.floor(distance) .. "s)")
            else
                local levelName = i == 1 and "Basement" or (i == 2 and "Main" or "Roof")
            end
        end)
    end

    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -16 * MOBILE_SCALE, 1, 0)
    container.Position = UDim2.new(0, 8 * MOBILE_SCALE, 0, 0)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 5 * MOBILE_SCALE)

    local leftSection = Instance.new("Frame", container)
    leftSection.Size = UDim2.new(0, 220 * MOBILE_SCALE, 1, 0)
    leftSection.BackgroundTransparency = 1

    local leftContent = Instance.new("Frame", leftSection)
    leftContent.Size = UDim2.new(1, 0, 0, 55 * MOBILE_SCALE)
    leftContent.Position = UDim2.new(0, 0, 0.5, -27.5 * MOBILE_SCALE)
    leftContent.BackgroundTransparency = 1

    local logo = Instance.new("ImageLabel", leftContent)
    logo.Size = UDim2.new(0, 70 * MOBILE_SCALE, 0, 70 * MOBILE_SCALE)
    logo.Position = UDim2.new(0, -34 * MOBILE_SCALE, 0.5, -36.5 * MOBILE_SCALE)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://122875574139178"

    local title = Instance.new("TextLabel", leftContent)
    title.Text = "SolanaX"
    title.Font = Enum.Font.Gotham
    title.TextSize = 24 * MOBILE_SCALE
    title.TextColor3 = Theme.TextPrimary
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -45 * MOBILE_SCALE, 1, 0)
    title.Position = UDim2.new(0, 45 * MOBILE_SCALE, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.TextStrokeTransparency = 1

    local shinyGradient = Instance.new("UIGradient", title)
    shinyGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.TextPrimary),
        ColorSequenceKeypoint.new(0.3, Theme.TextPrimary),
        ColorSequenceKeypoint.new(0.45, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.55, Theme.Accent2),
        ColorSequenceKeypoint.new(0.7, Theme.TextPrimary),
        ColorSequenceKeypoint.new(1, Theme.TextPrimary)
    }
    shinyGradient.Rotation = 30

    task.spawn(function()
        while title.Parent do
            task.wait(3)
            shinyGradient.Offset = Vector2.new(-2, 0)
            local tw = TweenService:Create(
                shinyGradient,
                TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                { Offset = Vector2.new(2, 0) }
            )
            tw:Play()
            tw.Completed:Wait()
        end
    end)

    local centerSection = Instance.new("Frame", container)
    centerSection.Size = UDim2.new(0, 140 * MOBILE_SCALE, 1, 0)
    centerSection.BackgroundTransparency = 1

    local discordContainer = Instance.new("Frame", centerSection)
    discordContainer.Size = UDim2.new(1, 0, 0, 50 * MOBILE_SCALE)
    discordContainer.Position = UDim2.new(0, 0, 0.3, 0)
    discordContainer.BackgroundTransparency = 1

    local discordLink = Instance.new("TextLabel", discordContainer)
    discordLink.Size = UDim2.new(1, 0, 0, 28 * MOBILE_SCALE)
    discordLink.Position = UDim2.new(0, 0, 0, 0)
    discordLink.BackgroundTransparency = 1
    discordLink.Text = "dev by @solanausd"
    discordLink.Font = Enum.Font.Gotham
    discordLink.TextSize = 16 * MOBILE_SCALE
    discordLink.TextColor3 = Theme.Accent2
    discordLink.TextXAlignment = Enum.TextXAlignment.Center
    discordLink.TextYAlignment = Enum.TextYAlignment.Center
    discordLink.TextStrokeTransparency = 1

    local creditText = Instance.new("TextLabel", discordContainer)
    creditText.Size = UDim2.new(1, 0, 0, 22 * MOBILE_SCALE)
    creditText.Position = UDim2.new(0, 0, 0, 28 * MOBILE_SCALE)
    creditText.BackgroundTransparency = 1
    creditText.Text = "solanax"
    creditText.Font = Enum.Font.Gotham
    creditText.TextSize = 12 * MOBILE_SCALE
    creditText.TextColor3 = Theme.TextMuted
    creditText.TextXAlignment = Enum.TextXAlignment.Center
    creditText.TextYAlignment = Enum.TextYAlignment.Center
    creditText.TextStrokeTransparency = 1

    local rightSection = Instance.new("Frame", container)
    rightSection.Size = UDim2.new(0, 220 * MOBILE_SCALE, 1, 0)
    rightSection.BackgroundTransparency = 1

    local statsContainer = Instance.new("Frame", rightSection)
    statsContainer.Size = UDim2.new(1, 0, 0, 30 * MOBILE_SCALE)
    statsContainer.Position = UDim2.new(0, 0, 0.5, -15 * MOBILE_SCALE)
    statsContainer.BackgroundTransparency = 1

    local stats = Instance.new("TextLabel", statsContainer)
    stats.Size = UDim2.new(1, 0, 1, 0)
    stats.BackgroundTransparency = 1
    stats.Font = Enum.Font.Gotham
    stats.TextSize = 13 * MOBILE_SCALE
    stats.TextXAlignment = Enum.TextXAlignment.Right
    stats.TextColor3 = Theme.TextPrimary
    stats.RichText = true
    stats.TextYAlignment = Enum.TextYAlignment.Center
    stats.TextStrokeTransparency = 1

    local acc, rate, lastFps = 0, 1, 60
    RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc >= rate then
            lastFps = math.floor(1/dt)
            acc = 0
        end
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local fc = (lastFps >= 50) and "rgb(0,255,120)" or (lastFps >= 30) and "rgb(255,200,0)" or "rgb(255,70,70)"
        local pc = (ping < 100) and "rgb(0,255,120)" or (ping < 200) and "rgb(255,200,0)" or "rgb(255,70,70)"
        stats.Text = string.format(
            "<font color='rgb(180,180,190)'>FPS:</font> <font color='%s'><b>%d</b></font>  <font color='rgb(180,180,190)'>PING:</font> <font color='%s'><b>%dms</b></font>",
            fc, lastFps, pc, ping
        )
    end)

    if IS_MOBILE then
        for _, textLabel in ipairs(main:GetDescendants()) do
            if textLabel:IsA("TextLabel") then
                textLabel.TextSize = textLabel.TextSize * 0.8
            end
        end
        layout.Padding = UDim.new(0, 2 * MOBILE_SCALE)
    end

    return gui
end

CreateStatusHUD()

local function updateGlobalGuiScale(newScale)
    GlobalGuiScale = newScale
    Config.GlobalGuiScale = newScale
    SaveConfig()
    MOBILE_SCALE = (IS_MOBILE and 0.75 or 1) * GlobalGuiScale
end

local function CreateSettingsGUI()
    local existing = PlayerGui:FindFirstChild("SolanaSettingsUI")
    if existing then existing:Destroy() end

    local SETTINGS_WIDTH = 700
    local SETTINGS_HEIGHT = 550
    local LEFT_COL_WIDTH = 130
    local RIGHT_COL_WIDTH = SETTINGS_WIDTH - LEFT_COL_WIDTH - 30
    local TOP_ROW_HEIGHT = 75
    local BOTTOM_ROW_HEIGHT = SETTINGS_HEIGHT - TOP_ROW_HEIGHT - 25
    
    local settingsGui = Instance.new("ScreenGui")
    settingsGui.Name = "SolanaSettingsUI"
    settingsGui.ResetOnSpawn = false
    settingsGui.Parent = PlayerGui
    settingsGui.Enabled = false

    local sFrame = Instance.new("Frame")
    sFrame.Size = UDim2.new(0, SETTINGS_WIDTH, 0, SETTINGS_HEIGHT)
    sFrame.Position = UDim2.new(0.5, -SETTINGS_WIDTH/2, 0.5, -SETTINGS_HEIGHT/2)
    sFrame.BackgroundColor3 = Theme.Background
    sFrame.BackgroundTransparency = 0.08
    sFrame.BorderSizePixel = 0
    sFrame.Parent = settingsGui
    Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 12)
    
    local dragHeader = Instance.new("Frame", sFrame)
    dragHeader.Size = UDim2.new(1, 0, 0, 40)
    dragHeader.Position = UDim2.new(0, 0, 0, 0)
    dragHeader.BackgroundTransparency = 1
    MakeDraggable(dragHeader, sFrame, nil)
    
    local outerStroke = Instance.new("UIStroke", sFrame)
    outerStroke.Thickness = 1.5
    outerStroke.Transparency = 0.3
    outerStroke.Color = Theme.TextPrimary
    local outerGrad = Instance.new("UIGradient", outerStroke)
    outerGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent1)
    }
    task.spawn(function()
        while outerStroke.Parent do
            outerGrad.Rotation = (outerGrad.Rotation or 0) + 1
            outerStroke.Transparency = 0.2 + math.sin(outerGrad.Rotation * 0.02) * 0.2
            task.wait(0.02)
        end
    end)

    local function createBox(parent, posX, posY, width, height, borderColor)
        local box = Instance.new("Frame", parent)
        box.Size = UDim2.new(0, width, 0, height)
        box.Position = UDim2.new(0, posX, 0, posY)
        box.BackgroundColor3 = Theme.Surface
        box.BackgroundTransparency = 0.05
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
        
        local border = Instance.new("UIStroke", box)
        border.Thickness = 1
        border.Transparency = 0.4
        border.Color = borderColor or Theme.Accent1
        local grad = Instance.new("UIGradient", border)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent1),
            ColorSequenceKeypoint.new(0.5, Theme.Accent2),
            ColorSequenceKeypoint.new(1, Theme.Accent1)
        }
        task.spawn(function()
            while border.Parent do
                grad.Rotation = (grad.Rotation or 0) + 0.5
                border.Transparency = 0.3 + math.sin(grad.Rotation * 0.02) * 0.15
                task.wait(0.02)
            end
        end)
        return box
    end

    createBox(sFrame, 10, 10, SETTINGS_WIDTH - 20, TOP_ROW_HEIGHT, Theme.Accent1)
    
    createBox(sFrame, 10, TOP_ROW_HEIGHT + 20, LEFT_COL_WIDTH, BOTTOM_ROW_HEIGHT, Theme.Accent1)
    
    createBox(sFrame, LEFT_COL_WIDTH + 22, TOP_ROW_HEIGHT + 20, RIGHT_COL_WIDTH - 10, BOTTOM_ROW_HEIGHT, Theme.Accent2)

    local topBar = Instance.new("Frame", sFrame)
    topBar.Size = UDim2.new(0, SETTINGS_WIDTH - 20, 0, TOP_ROW_HEIGHT)
    topBar.Position = UDim2.new(0, 10, 0, 10)
    topBar.BackgroundTransparency = 1
    
    local solanaxText = Instance.new("TextLabel", topBar)
    solanaxText.Size = UDim2.new(0, 200, 0, 32)
    solanaxText.Position = UDim2.new(0, 15, 0, 8)
    solanaxText.BackgroundTransparency = 1
    solanaxText.Text = "SolanaX"
    solanaxText.Font = Enum.Font.GothamMedium
    solanaxText.TextSize = 28
    solanaxText.TextColor3 = Theme.TextPrimary
    solanaxText.TextXAlignment = Enum.TextXAlignment.Left
    
    local solanaxGradient = Instance.new("UIGradient", solanaxText)
    solanaxGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.TextPrimary),
        ColorSequenceKeypoint.new(0.3, Theme.TextPrimary),
        ColorSequenceKeypoint.new(0.45, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.55, Theme.Accent2),
        ColorSequenceKeypoint.new(0.7, Theme.TextPrimary),
        ColorSequenceKeypoint.new(1, Theme.TextPrimary)
    }
    solanaxGradient.Rotation = 30
    
    local devText = Instance.new("TextLabel", topBar)
    devText.Size = UDim2.new(0, 200, 0, 14)
    devText.Position = UDim2.new(0, 18, 0, 44)
    devText.BackgroundTransparency = 1
    devText.Text = "dev by @solanausd"
    devText.Font = Enum.Font.GothamMedium
    devText.TextSize = 10
    devText.TextColor3 = Theme.TextMuted
    devText.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -40, 0, 24)
    closeBtn.BackgroundColor3 = Theme.SurfaceLight
    closeBtn.BackgroundTransparency = 0.15
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() settingsGui.Enabled = false end)

    local bottomLeft = Instance.new("Frame", sFrame)
    bottomLeft.Size = UDim2.new(0, LEFT_COL_WIDTH, 0, BOTTOM_ROW_HEIGHT)
    bottomLeft.Position = UDim2.new(0, 10, 0, TOP_ROW_HEIGHT + 20)
    bottomLeft.BackgroundTransparency = 1
    
    local tabsContainer = Instance.new("ScrollingFrame", bottomLeft)
    tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.BorderSizePixel = 0
    tabsContainer.ScrollBarThickness = 4
    tabsContainer.ScrollBarImageColor3 = Theme.Accent1
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsContainer.ScrollingEnabled = false
    
    local tabsLayout = Instance.new("UIListLayout", tabsContainer)
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local TAB_ICONS = {
        Player = "rbxassetid://103463360415218",
        Performance = "rbxassetid://92299779891097",
        Display = "rbxassetid://97135987506852",
        ESP = "rbxassetid://114272003452398",
        Teleport = "rbxassetid://119588051164867",
        Stealing = "rbxassetid://118756070431273",
        Priority = "rbxassetid://124102832835519",
        Keybinds = "rbxassetid://92510862998580"
    }
    
    local tabOrder = {"Player", "Performance", "Display", "ESP", "Teleport", "Stealing", "Priority", "Keybinds"}
    local tabButtons = {}
    local contentScrolls = {}
    
    for _, tabName in ipairs(tabOrder) do
        local btn = Instance.new("TextButton", tabsContainer)
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundTransparency = 0.7
        btn.BackgroundColor3 = Theme.SurfaceLight
        btn.Text = ""
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0, 22, 0, 22)
        icon.Position = UDim2.new(0, 8, 0.5, -11)
        icon.BackgroundTransparency = 1
        icon.Image = TAB_ICONS[tabName]
        icon.ScaleType = Enum.ScaleType.Fit
        
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -36, 1, 0)
        lbl.Position = UDim2.new(0, 34, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = tabName
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        tabButtons[tabName] = btn
    end
    
    local function updateTabsScroll()
        local tabsHeight = tabsLayout.AbsoluteContentSize.Y
        local viewHeight = tabsContainer.AbsoluteSize.Y
        if tabsHeight > viewHeight then
            tabsContainer.CanvasSize = UDim2.new(0, 0, 0, tabsHeight + 10)
            tabsContainer.ScrollingEnabled = true
        else
            tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
            tabsContainer.ScrollingEnabled = false
        end
    end
    
    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabsScroll)
    tabsContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTabsScroll)
    task.defer(updateTabsScroll)

    local bottomRight = Instance.new("Frame", sFrame)
    bottomRight.Size = UDim2.new(0, RIGHT_COL_WIDTH - 10, 0, BOTTOM_ROW_HEIGHT)
    bottomRight.Position = UDim2.new(0, LEFT_COL_WIDTH + 22, 0, TOP_ROW_HEIGHT + 20)
    bottomRight.BackgroundTransparency = 1
    
    local contentScroller = Instance.new("ScrollingFrame", bottomRight)
    contentScroller.Size = UDim2.new(1, 0, 1, 0)
    contentScroller.BackgroundTransparency = 1
    contentScroller.BorderSizePixel = 0
    contentScroller.ScrollBarThickness = 4
    contentScroller.ScrollBarImageColor3 = Theme.Accent1
    contentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroller.ScrollingEnabled = false
    
    local contentLayout = Instance.new("UIListLayout", contentScroller)
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local function updateContentScroll()
        local contentHeight = contentLayout.AbsoluteContentSize.Y
        local viewHeight = contentScroller.AbsoluteSize.Y
        if contentHeight > viewHeight then
            contentScroller.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
            contentScroller.ScrollingEnabled = true
        else
            contentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
            contentScroller.ScrollingEnabled = false
        end
    end
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentScroll)
    contentScroller:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContentScroll)
    task.defer(updateContentScroll)
    
    local function addNeonBorder(frame)
        local border = Instance.new("UIStroke", frame)
        border.Thickness = 1
        border.Transparency = 0.3
        border.Color = Theme.Accent1
        local grad = Instance.new("UIGradient", border)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent1),
            ColorSequenceKeypoint.new(0.5, Theme.Accent2),
            ColorSequenceKeypoint.new(1, Theme.Accent1)
        }
        task.spawn(function()
            while border.Parent do
                grad.Rotation = (grad.Rotation or 0) + 1
                border.Transparency = 0.2 + math.sin(grad.Rotation * 0.02) * 0.2
                task.wait(0.02)
            end
        end)
        return border
    end
    
    for _, tabName in ipairs(tabOrder) do
        local scroll = Instance.new("ScrollingFrame", contentScroller)
        scroll.Name = tabName .. "Scroll"
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 0
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.ScrollingEnabled = false
        scroll.Visible = false
        
        local scrollLayout = Instance.new("UIListLayout", scroll)
        scrollLayout.Padding = UDim.new(0, 8)
        scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local function updateInnerScroll()
            local innerHeight = scrollLayout.AbsoluteContentSize.Y
            local innerViewHeight = scroll.AbsoluteSize.Y
            if innerHeight > innerViewHeight then
                scroll.CanvasSize = UDim2.new(0, 0, 0, innerHeight + 20)
                scroll.ScrollingEnabled = true
            else
                scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                scroll.ScrollingEnabled = false
            end
        end
        
        scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateInnerScroll)
        scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateInnerScroll)
        
        contentScrolls[tabName] = scroll
    end
    
    local function setActiveTab(tabName)
        for name, scroll in pairs(contentScrolls) do
            scroll.Visible = (name == tabName)
        end
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                btn.BackgroundTransparency = 0.3
                btn.BackgroundColor3 = Theme.Accent1
            else
                btn.BackgroundTransparency = 0.7
                btn.BackgroundColor3 = Theme.SurfaceLight
            end
        end
    end
    
    for tabName, tabBtn in pairs(tabButtons) do
        tabBtn.MouseButton1Click:Connect(function() setActiveTab(tabName) end)
    end
    setActiveTab("Player")
    
    local function createSectionHeader(parent, text)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -10, 0, 28)
        row.BackgroundTransparency = 1
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -20, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextColor3 = Theme.Accent1
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local line = Instance.new("Frame", row)
        line.Size = UDim2.new(1, -120, 0, 1)
        line.Position = UDim2.new(0, 120, 0.5, 0)
        line.BackgroundColor3 = Theme.Accent1
        line.BackgroundTransparency = 0.7
        
        return row
    end
    
    local function createToggleRow(parent, text, description, defaultValue, callback)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -10, 0, 52)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0.08
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        addNeonBorder(row)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.7, 0, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local descLbl = Instance.new("TextLabel", row)
        descLbl.Size = UDim2.new(0.7, 0, 0, 14)
        descLbl.Position = UDim2.new(0, 12, 0, 26)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = description
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.TextSize = 9
        descLbl.TextColor3 = Theme.TextMuted
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local isOn = defaultValue or false
        local toggleFrame = Instance.new("Frame", row)
        toggleFrame.Size = UDim2.new(0, 44, 0, 22)
        toggleFrame.Position = UDim2.new(1, -56, 0.5, -11)
        toggleFrame.BackgroundColor3 = isOn and Theme.Success or Theme.SurfaceHighlight
        Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1,0)
        
        local toggleDot = Instance.new("Frame", toggleFrame)
        toggleDot.Size = UDim2.new(0, 18, 0, 18)
        toggleDot.Position = isOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        toggleDot.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(1,0)
        
        local toggleBtn = Instance.new("TextButton", toggleFrame)
        toggleBtn.Size = UDim2.new(1,0,1,0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        
        toggleBtn.MouseButton1Click:Connect(function()
            isOn = not isOn
            local newPos = isOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            local newColor = isOn and Theme.Success or Theme.SurfaceHighlight
            TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = newPos}):Play()
            TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
            callback(isOn)
        end)
        
        return row
    end
    
    local function createSliderRow(parent, text, description, min, max, default, suffix, callback)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -10, 0, 68)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0.08
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        addNeonBorder(row)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local descLbl = Instance.new("TextLabel", row)
        descLbl.Size = UDim2.new(0.6, 0, 0, 14)
        descLbl.Position = UDim2.new(0, 12, 0, 24)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = description
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.TextSize = 9
        descLbl.TextColor3 = Theme.TextMuted
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local value = default or min
        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size = UDim2.new(0, 50, 0, 18)
        valLbl.Position = UDim2.new(1, -60, 0, 6)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(value) .. (suffix or "")
        valLbl.Font = Enum.Font.GothamMedium
        valLbl.TextSize = 12
        valLbl.TextColor3 = Theme.Accent1
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        
        local sliderBg = Instance.new("Frame", row)
        sliderBg.Size = UDim2.new(1, -24, 0, 4)
        sliderBg.Position = UDim2.new(0, 12, 0, 52)
        sliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)
        
        local fill = Instance.new("Frame", sliderBg)
        fill.BackgroundColor3 = Theme.Accent1
        fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
        
        local knob = Instance.new("Frame", sliderBg)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.BackgroundColor3 = Theme.TextPrimary
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new((value - min)/(max - min), 0, 0.5, 0)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        
        local dragging = false
        local function updateSlider(inputX)
            local pos = sliderBg.AbsolutePosition.X
            local size = sliderBg.AbsoluteSize.X
            local pct = math.clamp((inputX - pos) / size, 0, 1)
            value = min + (pct * (max - min))
            value = math.floor(value * 10) / 10
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, 0, 0.5, 0)
            valLbl.Text = tostring(value) .. (suffix or "")
            callback(value)
        end
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)
        
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
        
        return row
    end

    local function createTextBoxRow(parent, text, description, defaultValue, placeholder, callback)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -10, 0, 52)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0.08
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        addNeonBorder(row)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.5, 0, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local descLbl = Instance.new("TextLabel", row)
        descLbl.Size = UDim2.new(0.5, 0, 0, 14)
        descLbl.Position = UDim2.new(0, 12, 0, 26)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = description
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.TextSize = 9
        descLbl.TextColor3 = Theme.TextMuted
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local textBox = Instance.new("TextBox", row)
        textBox.Size = UDim2.new(0, 100, 0, 30)
        textBox.Position = UDim2.new(1, -112, 0.5, -15)
        textBox.BackgroundColor3 = Theme.SurfaceHighlight
        textBox.BackgroundTransparency = 0.08
        textBox.Text = defaultValue
        textBox.PlaceholderText = placeholder
        textBox.Font = Enum.Font.GothamMedium
        textBox.TextSize = 11
        textBox.TextColor3 = Theme.TextPrimary
        textBox.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
        
        textBox.FocusLost:Connect(function(enterPressed)
            callback(textBox.Text)
        end)
        
        return row
    end
    
    local function createDropdownRow(parent, text, description, options, default, callback)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -10, 0, 52)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0.08
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        addNeonBorder(row)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local descLbl = Instance.new("TextLabel", row)
        descLbl.Size = UDim2.new(0.6, 0, 0, 14)
        descLbl.Position = UDim2.new(0, 12, 0, 24)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = description
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.TextSize = 9
        descLbl.TextColor3 = Theme.TextMuted
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local currentIndex = 1
        for i, opt in ipairs(options) do
            if opt == default then currentIndex = i; break end
        end
        
        local dropdownBtn = Instance.new("TextButton", row)
        dropdownBtn.Size = UDim2.new(0, 120, 0, 30)
        dropdownBtn.Position = UDim2.new(1, -132, 0.5, -15)
        dropdownBtn.BackgroundColor3 = Theme.SurfaceHighlight
        dropdownBtn.BackgroundTransparency = 0.08
        dropdownBtn.Text = options[currentIndex]
        dropdownBtn.Font = Enum.Font.GothamMedium
        dropdownBtn.TextSize = 11
        dropdownBtn.TextColor3 = Theme.TextPrimary
        Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6)
        
        dropdownBtn.MouseButton1Click:Connect(function()
            currentIndex = (currentIndex % #options) + 1
            dropdownBtn.Text = options[currentIndex]
            callback(options[currentIndex])
        end)
        
        return row
    end
    
    local function createKeybindRow(parent, text, description, defaultKey, callback)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -10, 0, 52)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0.08
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        addNeonBorder(row)
        
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local descLbl = Instance.new("TextLabel", row)
        descLbl.Size = UDim2.new(0.6, 0, 0, 14)
        descLbl.Position = UDim2.new(0, 12, 0, 24)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = description
        descLbl.Font = Enum.Font.GothamMedium
        descLbl.TextSize = 9
        descLbl.TextColor3 = Theme.TextMuted
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local currentKey = defaultKey or "None"
        local keyBtn = Instance.new("TextButton", row)
        keyBtn.Size = UDim2.new(0, 80, 0, 30)
        keyBtn.Position = UDim2.new(1, -92, 0.5, -15)
        keyBtn.BackgroundColor3 = Theme.SurfaceHighlight
        keyBtn.BackgroundTransparency = 0.08
        keyBtn.Text = currentKey
        keyBtn.Font = Enum.Font.GothamMedium
        keyBtn.TextSize = 11
        keyBtn.TextColor3 = Theme.Accent1
        Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)
        
        local isCapturing = false
        keyBtn.MouseButton1Click:Connect(function()
            if isCapturing then return end
            isCapturing = true
            _G.isBindingKey = true
            local oldText = keyBtn.Text
            keyBtn.Text = "..."
            keyBtn.TextColor3 = Theme.Warning
            
            local con
            con = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    keyBtn.Text = currentKey
                    keyBtn.TextColor3 = Theme.Accent1
                    isCapturing = false
                    _G.isBindingKey = false
                    con:Disconnect()
                    callback(currentKey)
                end
            end)
            
            task.delay(5, function()
                if isCapturing then
                    keyBtn.Text = oldText
                    keyBtn.TextColor3 = Theme.Accent1
                    isCapturing = false
                    _G.isBindingKey = false
                    if con then con:Disconnect() end
                end
            end)
        end)
        
        return row
    end
    
    local playerScroll = contentScrolls["Player"]
    if playerScroll then
        createSectionHeader(playerScroll, "COMBAT")
        createToggleRow(playerScroll, "Anti-Ragdoll V1", "Prevents ragdoll effects (V1)", Config.AntiRagdoll > 0, function(val)
            if val then 
                if Config.AntiRagdollV2 then
                    return
                end
                Config.AntiRagdoll = 1
                Config.AntiRagdollV2 = false
                SaveConfig()
                startAntiRagdoll(1)
                startAntiRagdollV2(false)
            else
                Config.AntiRagdoll = 0
                SaveConfig()
                startAntiRagdoll(0)
            end
        end)
        createToggleRow(playerScroll, "Anti-Ragdoll V2", "Prevents ragdoll effects (V2 - Aggressive)", Config.AntiRagdollV2, function(val)
            if val then 
                if Config.AntiRagdoll > 0 then
                    return
                end
                Config.AntiRagdollV2 = true
                Config.AntiRagdoll = 0
                SaveConfig()
                startAntiRagdoll(0)
                startAntiRagdollV2(true)
            else
                Config.AntiRagdollV2 = false
                SaveConfig()
                startAntiRagdollV2(false)
            end
        end)
        createToggleRow(playerScroll, "Anti-Bee & Disco", "Prevents bee effects and disco lighting", Config.AntiBeeDisco or false, function(val) Config.AntiBeeDisco = val; SaveConfig(); if val then if SharedState.ANTI_BEE_DISCO and SharedState.ANTI_BEE_DISCO.Enable then SharedState.ANTI_BEE_DISCO.Enable() end else if SharedState.ANTI_BEE_DISCO and SharedState.ANTI_BEE_DISCO.Disable then SharedState.ANTI_BEE_DISCO.Disable() end end end)
        createToggleRow(playerScroll, "Infinite Jump", "Jump infinitely in the air", infiniteJumpEnabled, function(val) setInfiniteJump(val) end)
        
        createSectionHeader(playerScroll, "AUTOMATION")
        createToggleRow(playerScroll, "Reset on Balloon", "Auto reset when ballooned", Config.AutoResetOnBalloon, function(val) Config.AutoResetOnBalloon = val; SaveConfig() end)
        createToggleRow(playerScroll, "Kick on Steal", "Kick game when you steal", Config.AutoKickOnSteal, function(val) Config.AutoKickOnSteal = val; SaveConfig() end)
        createToggleRow(playerScroll, "Auto Destroy Turrets", "Automatically destroy enemy turrets", Config.AutoDestroyTurrets or false, function(val) Config.AutoDestroyTurrets = val; SaveConfig() end)
    end
    
    local perfScroll = contentScrolls["Performance"]
    if perfScroll then
        createSectionHeader(perfScroll, "PERFORMANCE")
        createToggleRow(perfScroll, "X-Ray", "See through walls", Config.XrayEnabled, function(val) Config.XrayEnabled = val; if val then enableXray() else disableXray() end; SaveConfig() end)        
        createSectionHeader(perfScroll, "VISUAL")
        createToggleRow(perfScroll, "Dark Mode", "Darken environment", Config.DarkMode or false, function(val) Config.DarkMode = val; SaveConfig(); if val then enableDarkMode() else disableDarkMode() end end)
        createSliderRow(perfScroll, "Dark Mode Intensity", "0% = Midnight only, 100% = Complete dark", 
    0, 100, Config.NightVisionStrength or 100, "%", 
    function(val) 
        Config.NightVisionStrength = val
        nightVisionStrength = val
        SaveConfig()
        if darkModeActive then 
            enableDarkMode()
        end 
    end)        createSliderRow(perfScroll, "Field of View (FOV)", "Camera field of view", 70, 120, Config.FOV or 70, "Â°", function(val)
    Config.FOV = val
    SaveConfig()
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = val
    end
end)
    end
    
    local displayScroll = contentScrolls["Display"]
    if displayScroll then
        createSectionHeader(displayScroll, "GUI VISIBILITY")
        createToggleRow(displayScroll, "Show Admin Panel", "Show/hide admin panel (player list)", not Config.HideAdminPanel, function(val) 
            Config.HideAdminPanel = not val
            SaveConfig()
            local adUI = PlayerGui:FindFirstChild("SolanaAdminPanel")
            if adUI then adUI.Enabled = val end
        end)
        createToggleRow(displayScroll, "Show Admin Control", "Show/hide admin control panel (AP buttons)", not Config.HideAdminControl, function(val) 
            Config.HideAdminControl = not val
            SaveConfig()
            local adControl = PlayerGui:FindFirstChild("SolanaAdminControl")
            if adControl then adControl.Enabled = val end
        end)
        createToggleRow(displayScroll, "Show Brainrot Selection", "Show/hide brainrot panel", not Config.HideBrainrotSelection, function(val) 
            Config.HideBrainrotSelection = not val
            SaveConfig()
            local bsUI = PlayerGui:FindFirstChild("BrainrotSelectionUI")
            if bsUI then bsUI.Enabled = val end
        end)
        createToggleRow(displayScroll, "Show Quick Panel", "Show/hide quick panel", Config.ShowQuickPanel, function(val) 
            Config.ShowQuickPanel = val
            SaveConfig()
            local quickGui = PlayerGui:FindFirstChild("SolanaQuickPanel")
            if quickGui then quickGui.Enabled = val end
        end)
        createToggleRow(displayScroll, "Show Control Panel", "Show/hide control panel (invisible steal)", Config.ShowInvisPanel, function(val)
            Config.ShowInvisPanel = val
            SaveConfig()
            local invGui = PlayerGui:FindFirstChild("SolanaInvisPanel")
            if invGui then invGui.Enabled = val end
        end)
        createToggleRow(displayScroll, "Show Desync Panel", "Show/hide desync panel", Config.ShowDesyncGUI, function(val)
            Config.ShowDesyncGUI = val
            SaveConfig()
            local desyncGui = PlayerGui:FindFirstChild("SolanaDesyncPanel")
            if desyncGui then desyncGui.Enabled = val end
        end)
        
        createSectionHeader(displayScroll, "UI SETTINGS")
        createToggleRow(displayScroll, "Lock GUI Positions", "Prevent GUI dragging", Config.UILocked or false, function(val) Config.UILocked = val; SaveConfig() end)
        createToggleRow(displayScroll, "Clean Error GUIs", "Auto clear error popups", Config.CleanErrorGUIs or false, function(val) Config.CleanErrorGUIs = val; SaveConfig() end)
        createSliderRow(displayScroll, "Global GUI Scale", "Scale all UI elements", 0.5, 1.5, Config.GlobalGuiScale or 1.0, "x", function(val)
        updateGlobalGuiScale(val)
        end)
        
        local resetRow = Instance.new("Frame", displayScroll)
        resetRow.Size = UDim2.new(1, -10, 0, 52)
        resetRow.BackgroundColor3 = Theme.Surface
        resetRow.BackgroundTransparency = 0.08
        Instance.new("UICorner", resetRow).CornerRadius = UDim.new(0, 8)
        addNeonBorder(resetRow)
        
        local resetLbl = Instance.new("TextLabel", resetRow)
        resetLbl.Size = UDim2.new(0.6, 0, 0, 18)
        resetLbl.Position = UDim2.new(0, 12, 0, 6)
        resetLbl.BackgroundTransparency = 1
        resetLbl.Text = "Reset GUI Positions"
        resetLbl.Font = Enum.Font.GothamMedium
        resetLbl.TextSize = 12
        resetLbl.TextColor3 = Theme.TextPrimary
        resetLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local resetDesc = Instance.new("TextLabel", resetRow)
        resetDesc.Size = UDim2.new(0.6, 0, 0, 14)
        resetDesc.Position = UDim2.new(0, 12, 0, 24)
        resetDesc.BackgroundTransparency = 1
        resetDesc.Text = "Reset all GUI positions to default"
        resetDesc.Font = Enum.Font.GothamMedium
        resetDesc.TextSize = 9
        resetDesc.TextColor3 = Theme.TextMuted
        resetDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local resetBtn = Instance.new("TextButton", resetRow)
        resetBtn.Size = UDim2.new(0, 70, 0, 30)
        resetBtn.Position = UDim2.new(1, -82, 0.5, -15)
        resetBtn.BackgroundColor3 = Theme.Error
        resetBtn.BackgroundTransparency = 0.08
        resetBtn.Text = "RESET"
        resetBtn.Font = Enum.Font.GothamMedium
        resetBtn.TextSize = 11
        resetBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
        
        resetBtn.MouseButton1Click:Connect(function()
            Config.Positions = DefaultConfig.Positions
            Config.MobileGuiScale = 0.65
            SaveConfig()
            if SharedState.RefreshMobileScale then SharedState.RefreshMobileScale() end
        end)
        
        if IS_MOBILE then
            createSliderRow(displayScroll, "Mobile GUI Scale", "Scale GUI on mobile", 0.3, 1.0, Config.MobileGuiScale or 0.65, "", function(val)
                Config.MobileGuiScale = val
                SaveConfig()
                if SharedState.RefreshMobileScale then SharedState.RefreshMobileScale() end
            end)
        end
    end
    
    local espScroll = contentScrolls["ESP"]
    if espScroll then
        createSectionHeader(espScroll, "ESP SETTINGS")
        createToggleRow(espScroll, "Player ESP", "Show player names above heads", Config.PlayerESP, function(val) Config.PlayerESP = val; SaveConfig() end)
        createToggleRow(espScroll, "Brainrot ESP", "Show brainrot names and values", Config.BrainrotESP, function(val) Config.BrainrotESP = val; SaveConfig() end)
        createToggleRow(espScroll, "Line ESP", "Tracer to selected target", Config.TracerEnabled, function(val) Config.TracerEnabled = val; SaveConfig() end)
        createToggleRow(espScroll, "Base ESP", "Beam to your base", Config.LineToBase, function(val) Config.LineToBase = val; SaveConfig(); if val then pcall(createPlotBeam) end end)
        createToggleRow(espScroll, "Stealing ESP", "Highlight stealing players", Config.StealingESP or false, function(val) Config.StealingESP = val; SaveConfig(); if val then startStealingESP() else stopStealingESP() end end)
        createToggleRow(espScroll, "Mine ESP", "Show subspace mines", Config.SubspaceMineESP, function(val) Config.SubspaceMineESP = val; SaveConfig() end)
    end
    
    local teleportScroll = contentScrolls["Teleport"]
    if teleportScroll then
        createSectionHeader(teleportScroll, "AUTO TP")
        createToggleRow(teleportScroll, "Auto TP on Load", "Teleport when script loads", Config.TpSettings.TpOnLoad, function(val) Config.TpSettings.TpOnLoad = val; SaveConfig() end)
        createTextBoxRow(teleportScroll, "Alert Sound ID", "Sound that plays when auto teleporting (numbers only)", Config.AutoTPAlertSoundID:gsub("rbxassetid://", "") or "89155583651513", "Asset ID", function(val)
        local cleanVal = val:gsub("%D", "")
        if cleanVal == "" then
        cleanVal = "89155583651513"
        end
        Config.AutoTPAlertSoundID = "rbxassetid://" .. cleanVal
        SaveConfig()
        end)
        createSliderRow(teleportScroll, "Teleport Delay", "Delay before teleporting", 0, 5, Config.TpSettings.Speed or 2, "", function(val) Config.TpSettings.Speed = val; SaveConfig() end)
        createSliderRow(teleportScroll, "Min Gen for Auto TP", "Minimum generation to teleport (0 = off)", 0, 100, Config.MinGenForAutoTP or 0, "M/s", function(val)
        Config.MinGenForAutoTP = val
        SaveConfig()
        end)
        
        createSectionHeader(teleportScroll, "TELEPORT SETTINGS")
        createDropdownRow(teleportScroll, "TP Tool", "Flying tool to use", {"Flying Carpet", "Cupid's Wings", "Santa's Sleigh", "Witch's Broom"}, Config.TpSettings.Tool, function(val) Config.TpSettings.Tool = val; SaveConfig() end)
        createDropdownRow(teleportScroll, "Teleport Style", "Teleport From Either the Front or Side", {"Front", "Side"}, Config.TeleportStyle or "Front", function(val) Config.TeleportStyle = val; SaveConfig() end)
        createDropdownRow(teleportScroll, "2nd Floor Method", "Either Clone in From 1st Level or 2nd Level for 2nd Floor", {"Low", "High"}, Config.TpSettings.SecondFloorMethod or "Low", function(val) Config.TpSettings.SecondFloorMethod = val; SaveConfig() end)
        createSliderRow(teleportScroll, "Post Clone Delay", "Wait time after cloning", 0, 1, Config.TpSettings.PostCloneDelay or 0, "s", function(val) Config.TpSettings.PostCloneDelay = val; SaveConfig() end)
        createSliderRow(teleportScroll, "Front Mode Low Extra Delay", "Modify to your liking", 0, 1, (Config.TpSettings.PreCloneDelayFrontLow or 0) / 0.1, "", function(val) Config.TpSettings.PreCloneDelayFrontLow = val * 0.1; SaveConfig() end, "%.0f")
        createSliderRow(teleportScroll, "Front Mode High Extra Delay", "Modify to your liking", 0, 1, (Config.TpSettings.PreCloneDelayFrontHigh or 0) / 0.1, "", function(val) Config.TpSettings.PreCloneDelayFrontHigh = val * 0.1; SaveConfig() end, "%.0f")
        createSliderRow(teleportScroll, "Side Mode Extra Delay", "Modify to your liking", 0, 1, (Config.TpSettings.PreCloneDelaySide or 0) / 0.1, "", function(val) Config.TpSettings.PreCloneDelaySide = val * 0.1; SaveConfig() end, "%.0f")
    end
    
    local stealingScroll = contentScrolls["Stealing"]
    if stealingScroll then
        createSectionHeader(stealingScroll, "STEALING SETTINGS")
        createToggleRow(stealingScroll, "Auto Unlock on Steal", "Unlock doors when stealing", Config.AutoUnlockOnSteal, function(val) Config.AutoUnlockOnSteal = val; SaveConfig() end)
        createToggleRow(stealingScroll, "Back to Brainrot on Fail", "Retarget when steal fails", Config.AutoTPOnFailedSteal, function(val) Config.AutoTPOnFailedSteal = val; SaveConfig() end)
        createToggleRow(stealingScroll, "Skip Non-Stealable Brainrots", "Only show brainrots that have a steal prompt", Config.SkipNonStealableBrainrots or false, function(val)
            Config.SkipNonStealableBrainrots = val
            SaveConfig()
            if SharedState.UpdateBrainrotSelectionUI then
                SharedState.UpdateBrainrotSelectionUI()
            end
        end)
        createTextBoxRow(stealingScroll, "Min Gen for Nearest", "Only steal pets above this value (1k, 1m, 1b, or OFF)", Config.MinGenForNearest == 0 and "OFF" or tostring(Config.MinGenForNearest), "10M, 1B, OFF", function(val) 
            local input = val:upper():gsub(",",""):gsub("%$","")
            if input == "OFF" or input == "0" or input == "" then 
                Config.MinGenForNearest = 0 
            else 
                local num = tonumber(input:match("%d+%.?%d*")) or 0
                if input:find("B") then 
                    num = num * 1000000000 
                elseif input:find("M") then 
                    num = num * 1000000 
                elseif input:find("K") then 
                    num = num * 1000 
                end
                Config.MinGenForNearest = math.floor(num)
            end
            SaveConfig()
            if SharedState.UpdateBrainrotSelectionUI then 
                SharedState.UpdateBrainrotSelectionUI() 
            end
        end)
    end
    
    local priorityScroll = contentScrolls["Priority"]
    if priorityScroll then
        local titleRow = Instance.new("Frame", priorityScroll)
        titleRow.Size = UDim2.new(1, -10, 0, 28)
        titleRow.BackgroundTransparency = 1
        
        local titleLbl = Instance.new("TextLabel", titleRow)
        titleLbl.Size = UDim2.new(1, -20, 1, 0)
        titleLbl.Position = UDim2.new(0, 8, 0, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = "PRIORITY LIST"
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextColor3 = Theme.Accent1
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local titleLine = Instance.new("Frame", titleRow)
        titleLine.Size = UDim2.new(1, -140, 0, 1)
        titleLine.Position = UDim2.new(0, 140, 0.5, 0)
        titleLine.BackgroundColor3 = Theme.Accent1
        titleLine.BackgroundTransparency = 0.7
        
        local searchRow = Instance.new("Frame", priorityScroll)
        searchRow.Size = UDim2.new(1, -10, 0, 36)
        searchRow.Position = UDim2.new(0, 5, 0, 0)
        searchRow.BackgroundColor3 = Theme.Surface
        searchRow.BackgroundTransparency = 0.08
        Instance.new("UICorner", searchRow).CornerRadius = UDim.new(0, 8)
        addNeonBorder(searchRow)
        
        local searchBox = Instance.new("TextBox", searchRow)
        searchBox.Size = UDim2.new(1, -20, 0, 16)
        searchBox.Position = UDim2.new(0, 10, 0.5, -8)
        searchBox.BackgroundTransparency = 1
        searchBox.PlaceholderText = "Search brainrots..."
        searchBox.PlaceholderColor3 = Theme.TextMuted
        searchBox.Font = Enum.Font.GothamMedium
        searchBox.TextSize = 12
        searchBox.TextColor3 = Theme.TextPrimary
        searchBox.ClearTextOnFocus = false
        searchBox.Text = ""
        
        local priorityListFrame = Instance.new("ScrollingFrame", priorityScroll)
        priorityListFrame.Size = UDim2.new(1, -10, 0, 380)
        priorityListFrame.Position = UDim2.new(0, 5, 0, 80)
        priorityListFrame.BackgroundColor3 = Theme.Surface
        priorityListFrame.BackgroundTransparency = 0.08
        priorityListFrame.BorderSizePixel = 0
        Instance.new("UICorner", priorityListFrame).CornerRadius = UDim.new(0, 8)
        addNeonBorder(priorityListFrame)
        priorityListFrame.ScrollBarThickness = 6
        priorityListFrame.ScrollBarImageColor3 = Theme.Accent1
        priorityListFrame.ScrollBarImageTransparency = 0.3
        priorityListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        priorityListFrame.ScrollingEnabled = false
        
        local priorityLayout = Instance.new("UIListLayout", priorityListFrame)
        priorityLayout.Padding = UDim.new(0, 4)
        
        local resetDefaultBtn = Instance.new("TextButton", priorityScroll)
        resetDefaultBtn.Size = UDim2.new(1, -10, 0, 38)
        resetDefaultBtn.Position = UDim2.new(0, 5, 1, -48)
        resetDefaultBtn.BackgroundColor3 = Theme.Accent1
        resetDefaultBtn.BackgroundTransparency = 0.08
        resetDefaultBtn.Text = "RESET TO DEFAULT ORDER"
        resetDefaultBtn.Font = Enum.Font.GothamBold
        resetDefaultBtn.TextSize = 11
        resetDefaultBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", resetDefaultBtn).CornerRadius = UDim.new(0, 8)
        
local DEFAULT_PRIORITY_LIST = {
    "Headless Horseman",
    "Signore Carapace",
    "Arcadragon",
    "Elefanto Frigo",
    "Strawberry Elephant",
    "John Pork",
    "Antonio",
    "Love Love Bear",
    "Meowl",
    "Pancake and Syrup",
    "Skibidi Toilet",
    "Griffin",
    "Globa Steppa",
    "Rico Dinero",
    "Kalika Bros",
    "Tirilikalika Tirilikalako",
    "Dragon Gingerini",
    "Fishino Clownino",
    "Ginger Gerat",
    "La Supreme Combinasion",
    "Digi Narwhal",
    "Hydra Bunny",
    "Los Hackers",
    "Dug dug dug",
    "Bunny and Eggy",
    "Hydra Dragon Cannelloni",
    "Duggy Bros",
    "Dragon Cannelloni",
    "Ketupat Bros",
    "La Casa Boo",
    "Guest 666",
    "Money Money Reindeer",
    "Rosey and Teddy",
    "Foxini Lanternini",
    "Fragola La La La",
    "Quackini Snackini",
    "Los Chillis",
    "Cerberus",
    "Boppin Bunny",
    "Jolly Jolly Sahur",
    "Reinito Sleighito",
    "Fortunu and Cashuru",
    "Chillin Chili",
    "Los Sekolahs",
    "Los Amigos",
    "Gym Bros",
    "Spooky and Pumpky",
    "Cooki and Milki",
    "Fragrama and Chocrama",
    "Celularcini Viciosini",
    "Cloverat Clapat",
    "Tralaledon",
    "Money Money Bros",
    "Capitano Moby",
    "La Food Combinasion",
    "Celestial Pegasus",
    "Hopilikalika Hopilikalako",
    "Los Mariachis",
    "Cash or Card",
    "Sammyni Fattini",
    "Popcuru and Fizzuru",
    "Burguro And Fryuro",
    "Garama and Madundung"
}
        
        local customPriorityList = {}
        if Config.PriorityList and #Config.PriorityList > 0 then
            for i = 1, #Config.PriorityList do
                customPriorityList[i] = Config.PriorityList[i]
            end
        else
            for i = 1, #DEFAULT_PRIORITY_LIST do
                customPriorityList[i] = DEFAULT_PRIORITY_LIST[i]
            end
        end
        
        local function autoSave()
            Config.PriorityList = {}
            for i = 1, #customPriorityList do
                Config.PriorityList[i] = customPriorityList[i]
            end
            SaveConfig()
            if SharedState.UpdateBrainrotSelectionUI then
                SharedState.ListNeedsRedraw = true
                SharedState.UpdateBrainrotSelectionUI()
            end
        end
        
        local priorityRows = {}
        local currentSearchFilter = ""
        
        local function updatePriorityListScroll()
            local totalHeight = #priorityRows * 38 + 20
            local viewHeight = priorityListFrame.AbsoluteSize.Y
            if totalHeight > viewHeight then
                priorityListFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                priorityListFrame.ScrollingEnabled = true
            else
                priorityListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                priorityListFrame.ScrollingEnabled = false
            end
        end
        
        local function refreshPriorityList()
            for _, row in ipairs(priorityRows) do
                if row and row.frame then row.frame:Destroy() end
            end
            priorityRows = {}
            
            local searchLower = currentSearchFilter:lower()
            local hasSearch = searchLower ~= ""
            
            for i, petName in ipairs(customPriorityList) do
                local matchesSearch = not hasSearch or petName:lower():find(searchLower, 1, true)
                if matchesSearch then
                    local row = Instance.new("Frame", priorityListFrame)
                    row.Size = UDim2.new(1, -16, 0, 34)
                    row.BackgroundColor3 = Theme.SurfaceHighlight
                    row.BackgroundTransparency = 0.08
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                    addNeonBorder(row)
                    
                    local rankLbl = Instance.new("TextLabel", row)
                    rankLbl.Size = UDim2.new(0, 40, 1, 0)
                    rankLbl.Position = UDim2.new(0, 5, 0, 0)
                    rankLbl.BackgroundTransparency = 1
                    rankLbl.Text = tostring(i)
                    rankLbl.Font = Enum.Font.GothamBold
                    rankLbl.TextSize = 11
                    rankLbl.TextColor3 = Theme.Accent1
                    rankLbl.TextXAlignment = Enum.TextXAlignment.Center
                    
                    local nameLbl = Instance.new("TextLabel", row)
                    nameLbl.Size = UDim2.new(1, -130, 1, 0)
                    nameLbl.Position = UDim2.new(0, 50, 0, 0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = petName
                    nameLbl.Font = Enum.Font.Gotham
                    nameLbl.TextSize = 11
                    nameLbl.TextColor3 = Theme.TextPrimary
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    
                    local btnContainer = Instance.new("Frame", row)
                    btnContainer.Size = UDim2.new(0, 70, 1, 0)
                    btnContainer.Position = UDim2.new(1, -75, 0, 0)
                    btnContainer.BackgroundTransparency = 1
                    
                    local upBtn = Instance.new("TextButton", btnContainer)
                    upBtn.Size = UDim2.new(0, 30, 0, 26)
                    upBtn.Position = UDim2.new(0, 0, 0.5, -13)
                    upBtn.BackgroundColor3 = Theme.Surface
                    upBtn.BackgroundTransparency = 0.08
                    upBtn.Text = "â†‘"
                    upBtn.Font = Enum.Font.GothamBold
                    upBtn.TextSize = 12
                    upBtn.TextColor3 = Theme.TextPrimary
                    Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 4)
                    
                    local downBtn = Instance.new("TextButton", btnContainer)
                    downBtn.Size = UDim2.new(0, 30, 0, 26)
                    downBtn.Position = UDim2.new(0, 35, 0.5, -13)
                    downBtn.BackgroundColor3 = Theme.Surface
                    downBtn.BackgroundTransparency = 0.08
                    downBtn.Text = "â†“"
                    downBtn.Font = Enum.Font.GothamBold
                    downBtn.TextSize = 12
                    downBtn.TextColor3 = Theme.TextPrimary
                    Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 4)
                    
                    local currentName = petName
                    
                    upBtn.MouseButton1Click:Connect(function()
                        local pos = nil
                        for idx, name in ipairs(customPriorityList) do
                            if name == currentName then
                                pos = idx
                                break
                            end
                        end
                        if pos and pos > 1 then
                            customPriorityList[pos], customPriorityList[pos-1] = customPriorityList[pos-1], customPriorityList[pos]
                            refreshPriorityList()
                            autoSave()
                        end
                    end)
                    
                    downBtn.MouseButton1Click:Connect(function()
                        local pos = nil
                        for idx, name in ipairs(customPriorityList) do
                            if name == currentName then
                                pos = idx
                                break
                            end
                        end
                        if pos and pos < #customPriorityList then
                            customPriorityList[pos], customPriorityList[pos+1] = customPriorityList[pos+1], customPriorityList[pos]
                            refreshPriorityList()
                            autoSave()
                        end
                    end)
                    
                    table.insert(priorityRows, {frame = row, name = petName})
                end
            end
            
            updatePriorityListScroll()
        end
        
        priorityListFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updatePriorityListScroll)
        priorityLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePriorityListScroll)
        
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            currentSearchFilter = searchBox.Text
            refreshPriorityList()
        end)
        
        resetDefaultBtn.MouseButton1Click:Connect(function()
            customPriorityList = {}
            for i = 1, #DEFAULT_PRIORITY_LIST do
                customPriorityList[i] = DEFAULT_PRIORITY_LIST[i]
            end
            refreshPriorityList()
            autoSave()
            
            TweenService:Create(resetDefaultBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Success}):Play()
            task.wait(0.2)
            TweenService:Create(resetDefaultBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent1}):Play()
        end)
        
        refreshPriorityList()
    end
    
    local keybindsScroll = contentScrolls["Keybinds"]
    if keybindsScroll then
        createSectionHeader(keybindsScroll, "MOVEMENT KEYBINDS")
        createKeybindRow(keybindsScroll, "Teleport Key", "Teleport to selected brainrot", Config.TpSettings.TpKey or "T", function(val) Config.TpSettings.TpKey = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Clone Key", "Activate Quantum Cloner", Config.TpSettings.CloneKey or "V", function(val) Config.TpSettings.CloneKey = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Carpet Speed Key", "Toggle speed boost", Config.TpSettings.CarpetSpeedKey or "Q", function(val) Config.TpSettings.CarpetSpeedKey = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Reset Key", "Reset character", Config.ResetKey or "X", function(val) Config.ResetKey = val; SaveConfig() end)
        
        createSectionHeader(keybindsScroll, "FUNCTION KEYBINDS")
        createKeybindRow(keybindsScroll, "Quick Panel Key", "Open/close quick panel", Config.QuickPanelKey or "B", function(val) Config.QuickPanelKey = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Invisible Steal Key", "Toggle invisible steal", Config.InvisToggleKey or "I", function(val) Config.InvisToggleKey = val; SaveConfig(); _G.INVISIBLE_STEAL_KEY = Enum.KeyCode[val] or Enum.KeyCode.I end)
        createKeybindRow(keybindsScroll, "Steal Speed Key", "Toggle steal speed boost", Config.StealSpeedKey or "C", function(val) Config.StealSpeedKey = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Ragdoll Self Key", "Ragdoll yourself", Config.RagdollSelfKey or "", function(val) Config.RagdollSelfKey = val; SaveConfig() end)
        
        createSectionHeader(keybindsScroll, "UI KEYBINDS")
        createKeybindRow(keybindsScroll, "Menu Key", "Open settings menu", Config.MenuKey or "LeftControl", function(val) Config.MenuKey = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Click to AP Key", "Toggle Click to AP", Config.ClickToAPKeybind or "L", function(val) Config.ClickToAPKeybind = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Proximity AP Key", "Toggle Proximity AP", Config.ProximityAPKeybind or "P", function(val) Config.ProximityAPKeybind = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Rejoin Key", "Rejoin server", Config.RejoinKey or "", function(val) Config.RejoinKey = val; SaveConfig() end)
        createKeybindRow(keybindsScroll, "Kick Key", "Kick/shutdown game", Config.KickKey or "", function(val) Config.KickKey = val; SaveConfig() end)
    end

    return settingsGui
end

UI.settingsGui = CreateSettingsGUI()

local adminControl = PlayerGui:FindFirstChild("SolanaAdminControl")
if adminControl then
    adminControl.Enabled = not Config.HideAdminControl
end

local function makeTouchFriendly(frame)
    if not IS_MOBILE then return end
    
    for _, btn in ipairs(frame:GetDescendants()) do
        if btn:IsA("TextButton") then
            btn.Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 8 * MOBILE_SCALE, btn.Size.Y.Scale, btn.Size.Y.Offset + 8 * MOBILE_SCALE)
            btn.AutoButtonColor = true
        elseif btn:IsA("TextBox") then
            btn.Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 10 * MOBILE_SCALE, btn.Size.Y.Scale, btn.Size.Y.Offset + 10 * MOBILE_SCALE)
        end
    end
    
    local scroll = frame:FindFirstChildOfClass("ScrollingFrame")
    if scroll then
        scroll.ScrollBarThickness = 8 * MOBILE_SCALE
        scroll.ElasticBehavior = Enum.ElasticBehavior.Always
    end
end

makeTouchFriendly(UI.settingsGui)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() or _G.isBindingKey then return end
    
    local function getSafeKey(keyName)
        if not keyName or keyName == "" then return nil end
        local success, result = pcall(function()
            return Enum.KeyCode[keyName]
        end)
        return success and result or nil
    end
    
    local tpKey = getSafeKey(Config.TpSettings.TpKey) or Enum.KeyCode.T
    if input.KeyCode == tpKey then
        runTP()
        return
    end
    
    local cloneKey = getSafeKey(Config.TpSettings.CloneKey) or Enum.KeyCode.V
    if input.KeyCode == cloneKey then
        Clone()
        return
    end
    
    local carpetKey = getSafeKey(Config.TpSettings.CarpetSpeedKey) or Enum.KeyCode.Q
    if input.KeyCode == carpetKey then
        carpetSpeedEnabled = not carpetSpeedEnabled
        setCarpetSpeed(carpetSpeedEnabled)
        return
    end
    
    local stealKey = getSafeKey(Config.StealSpeedKey) or Enum.KeyCode.C
    if input.KeyCode == stealKey then
        if _G.toggleStealSpeed then
            _G.toggleStealSpeed()
        end
        return
    end
    
    local resetKey = getSafeKey(Config.ResetKey) or Enum.KeyCode.X
    if input.KeyCode == resetKey then
        executeReset()
        return
    end
    
    local quickKey = getSafeKey(Config.QuickPanelKey) or Enum.KeyCode.B
    if input.KeyCode == quickKey then
        local quickGui = PlayerGui:FindFirstChild("SolanaQuickPanel")
        if quickGui then quickGui.Enabled = not quickGui.Enabled end
        return
    end
    
    local ragdollKey = getSafeKey(Config.RagdollSelfKey)
    if ragdollKey and input.KeyCode == ragdollKey then
        if _G.runAdminCommand then
            _G.runAdminCommand(LocalPlayer, "ragdoll")
        end
        return
    end
    
    local rejoinKey = getSafeKey(Config.RejoinKey)
    if rejoinKey and input.KeyCode == rejoinKey then
        rejoinGame()
        return
    end
    
    local clickKey = getSafeKey(Config.ClickToAPKeybind)
    if clickKey and input.KeyCode == clickKey then
        Config.ClickToAP = not Config.ClickToAP
        SaveConfig()
        return
    end
    
    local proxKey = getSafeKey(Config.ProximityAPKeybind)
    if proxKey and input.KeyCode == proxKey then
        State.ProximityAPActive = not State.ProximityAPActive
        return
    end
    
    local kickKey = getSafeKey(Config.KickKey)
    if kickKey and input.KeyCode == kickKey then
        game:Shutdown()
        return
    end
    
    local invisKey = getSafeKey(Config.InvisToggleKey) or Enum.KeyCode.I
    if input.KeyCode == invisKey and _G.toggleInvisibleSteal then
        _G.toggleInvisibleSteal()
        return
    end
    
    local menuKey = getSafeKey(Config.MenuKey) or Enum.KeyCode.LeftControl
    if input.KeyCode == menuKey then
        local settingsGui = PlayerGui:FindFirstChild("SolanaSettingsUI")
        if settingsGui then
            settingsGui.Enabled = not settingsGui.Enabled
        end
        return
    end
end)

task.spawn(function()
    local brainrotESPEnabled = Config.BrainrotESP
    local brainrotBillboards = {}
    local hiddenOverheads = {}
    
    local PRIORITY_LIST = {}
    if Config.PriorityList and #Config.PriorityList > 0 then
        for i = 1, #Config.PriorityList do
            PRIORITY_LIST[i] = Config.PriorityList[i]
        end
    else
        PRIORITY_LIST = {
    "Headless Horseman",
    "Signore Carapace",
    "Arcadragon",
    "Elefanto Frigo",
    "Strawberry Elephant",
    "John Pork",
    "Antonio",
    "Love Love Bear",
    "Meowl",
    "Pancake and Syrup",
    "Skibidi Toilet",
    "Griffin",
    "Globa Steppa",
    "Rico Dinero",
    "Kalika Bros",
    "Tirilikalika Tirilikalako",
    "Dragon Gingerini",
    "Fishino Clownino",
    "Ginger Gerat",
    "La Supreme Combinasion",
    "Digi Narwhal",
    "Hydra Bunny",
    "Los Hackers",
    "Dug dug dug",
    "Bunny and Eggy",
    "Hydra Dragon Cannelloni",
    "Duggy Bros",
    "Dragon Cannelloni",
    "Ketupat Bros",
    "La Casa Boo",
    "Guest 666",
    "Money Money Reindeer",
    "Rosey and Teddy",
    "Foxini Lanternini",
    "Fragola La La La",
    "Quackini Snackini",
    "Los Chillis",
    "Cerberus",
    "Boppin Bunny",
    "Jolly Jolly Sahur",
    "Reinito Sleighito",
    "Fortunu and Cashuru",
    "Chillin Chili",
    "Los Sekolahs",
    "Los Amigos",
    "Gym Bros",
    "Spooky and Pumpky",
    "Cooki and Milki",
    "Fragrama and Chocrama",
    "Celularcini Viciosini",
    "Cloverat Clapat",
    "Tralaledon",
    "Money Money Bros",
    "Capitano Moby",
    "La Food Combinasion",
    "Celestial Pegasus",
    "Hopilikalika Hopilikalako",
    "Los Mariachis",
    "Cash or Card",
    "Sammyni Fattini",
    "Popcuru and Fizzuru",
    "Burguro And Fryuro",
    "Garama and Madundung"
}
    end
    
    local priorityLower = {}
    for _, name in ipairs(PRIORITY_LIST) do
        priorityLower[name:lower()] = true
    end
    
    local function isPriorityBrainrot(name)
        if not name then return false end
        return priorityLower[name:lower()] ~= nil
    end
    
    local function getDistanceToBrainrot(animalData)
        if not animalData then return "???" end
        local targetPart = findAdorneeGlobal(animalData)
        if not targetPart then return "???" end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return "???" end
        local dist = (hrp.Position - targetPart.Position).Magnitude
        return string.format("%.0f", dist)
    end
    
    local function createBrainrotBillboard(data)
        local bb = Instance.new("BillboardGui")
        bb.Name = "BrainrotESP_" .. data.uid
        bb.Size = UDim2.new(0, 200, 0, 38)
        bb.StudsOffset = Vector3.new(0, 1.8, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = 3000
        
        local f = Instance.new("Frame", bb)
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundColor3 = Theme.Background
        f.BackgroundTransparency = 0.5
        f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local stroke = Instance.new("UIStroke", f)
        stroke.Thickness = 1
        stroke.Transparency = 0.3
        stroke.Color = Theme.Accent1
        
        local textContainer = Instance.new("Frame", f)
        textContainer.Size = UDim2.new(1, -8, 0, 38)
        textContainer.Position = UDim2.new(0, 4, 0, 0)
        textContainer.BackgroundTransparency = 1
        
        local nameLabel = Instance.new("TextLabel", textContainer)
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, -2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = data.name or data.petName or "???"
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextColor3 = Color3.fromRGB(100, 0, 180)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        
        local bottomRow = Instance.new("Frame", textContainer)
        bottomRow.Size = UDim2.new(1, 0, 0, 14)
        bottomRow.Position = UDim2.new(0, 0, 0, 24)
        bottomRow.BackgroundTransparency = 1
        
        local genLabel = Instance.new("TextLabel", bottomRow)
        genLabel.Size = UDim2.new(0.6, 0, 1, 0)
        genLabel.Position = UDim2.new(0, 0, 0, 0)
        genLabel.BackgroundTransparency = 1
        genLabel.Text = data.genText or ""
        genLabel.Font = Enum.Font.Gotham
        genLabel.TextSize = 9
        genLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        genLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local distLabel = Instance.new("TextLabel", bottomRow)
        distLabel.Size = UDim2.new(0.4, 0, 1, 0)
        distLabel.Position = UDim2.new(0.6, 0, 0, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = getDistanceToBrainrot(data) .. "s"
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 9
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        return bb, distLabel
    end
    
    local function hideDefaultOverhead(overhead)
        if overhead and overhead.Parent and not hiddenOverheads[overhead] then
            hiddenOverheads[overhead] = overhead.Enabled
            overhead.Enabled = false
        end
    end
    
    local function showDefaultOverhead(overhead)
        if overhead and hiddenOverheads[overhead] ~= nil then
            overhead.Enabled = hiddenOverheads[overhead]
            hiddenOverheads[overhead] = nil
        end
    end
    
    local function restoreAllOverheads()
        for overhead, wasEnabled in pairs(hiddenOverheads) do
            if overhead and overhead.Parent then
                overhead.Enabled = wasEnabled
            end
        end
        hiddenOverheads = {}
    end
    
    local function refreshBrainrotESP()
        if not brainrotESPEnabled then return end
        local cache = SharedState.AllAnimalsCache
        if not cache or #cache == 0 then return end
        
        local seen = {}
        for _, data in ipairs(cache) do
            if isPriorityBrainrot(data.name) then
                seen[data.uid] = true
                
                if not brainrotBillboards[data.uid] then
                    local adornee = findAdorneeGlobal(data)
                    
                    if adornee then
                        local bb, distLabel = createBrainrotBillboard(data)
                        bb.Adornee = adornee
                        bb.Parent = adornee
                        brainrotBillboards[data.uid] = {bb = bb, distLabel = distLabel}
                    end
                else
                    local entry = brainrotBillboards[data.uid]
                    if entry and entry.distLabel then
                        entry.distLabel.Text = getDistanceToBrainrot(data) .. "s"
                    end
                end
            end
        end
        
        for uid, entry in pairs(brainrotBillboards) do
            if not seen[uid] then
                if entry.bb then entry.bb:Destroy() end
                brainrotBillboards[uid] = nil
            end
        end
    end
    
task.spawn(function()
    while true do
        task.wait(0.5)
        for uid, entry in pairs(brainrotBillboards) do
            if entry and entry.distLabel then
                local data = nil
                local cache = SharedState.FullAnimalsCache or SharedState.AllAnimalsCache
                if cache then
                    for _, pet in ipairs(cache) do
                        if pet.uid == uid then
                            data = pet
                            break
                        end
                    end
                end
                if data then
                    entry.distLabel.Text = getDistanceToBrainrot(data) .. "s"
                end
            end
        end
    end
end)
    
        Heartbeat:Connect(function()
        if brainrotESPEnabled then
            local cache = SharedState.AllAnimalsCache
            if cache and #cache > 0 then
                pcall(refreshBrainrotESP)
            end
        end
    end)
end)
task.spawn(function()
    local playerESPEnabled = Config.PlayerESP
    local playerESPData = {}
    
    local function createPlayerESP(player)
        if player == LocalPlayer then return end
        
        local char = player.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "PlayerESP_Box_" .. player.UserId
        selectionBox.Adornee = char
        selectionBox.Color3 = Color3.fromRGB(138, 43, 226)
        selectionBox.LineThickness = 0.05
        selectionBox.Transparency = 0.35
        selectionBox.Parent = char
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerESP_Billboard_" .. player.UserId
        billboard.Size = UDim2.new(0, 200, 0, 35)
        billboard.StudsOffset = Vector3.new(0, 2.8, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.MaxDistance = 2000
        billboard.ResetOnSpawn = false
        billboard.Parent = char
        
        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        playerESPData[player.UserId] = {
            selectionBox = selectionBox,
            billboard = billboard,
            player = player
        }
        
        return true
    end
    
    local function removePlayerESP(player)
        local data = playerESPData[player.UserId]
        if data then
            if data.selectionBox then data.selectionBox:Destroy() end
            if data.billboard then data.billboard:Destroy() end
            playerESPData[player.UserId] = nil
        end
    end
    
    local function clearAllPlayerESP()
        for userId, data in pairs(playerESPData) do
            if data.selectionBox then data.selectionBox:Destroy() end
            if data.billboard then data.billboard:Destroy() end
        end
        playerESPData = {}
    end
    
    local function refreshPlayerESP()
        if not playerESPEnabled then
            clearAllPlayerESP()
            return
        end
        
        local currentPlayers = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                currentPlayers[player.UserId] = true
                
                if not playerESPData[player.UserId] then
                    createPlayerESP(player)
                end
            end
        end
        
        for userId, data in pairs(playerESPData) do
            if not currentPlayers[userId] then
                local player = Players:GetPlayerByUserId(userId)
                if player then
                    removePlayerESP(player)
                else
                    if data.selectionBox then data.selectionBox:Destroy() end
                    if data.billboard then data.billboard:Destroy() end
                    playerESPData[userId] = nil
                end
            end
        end
    end
    
    local function onCharacterAdded(player)
        return function(char)
            task.wait(0.5)
            if playerESPEnabled and player ~= LocalPlayer then
                local data = playerESPData[player.UserId]
                if data then
                    if data.selectionBox then data.selectionBox:Destroy() end
                    if data.billboard then data.billboard:Destroy() end
                    playerESPData[player.UserId] = nil
                end
                createPlayerESP(player)
            end
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(onCharacterAdded(player))
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(onCharacterAdded(player))
            task.wait(0.5)
            if playerESPEnabled then
                createPlayerESP(player)
            end
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removePlayerESP(player)
    end)
    
    Heartbeat:Connect(function()
        if playerESPEnabled then
            refreshPlayerESP()
        elseif not playerESPEnabled and next(playerESPData) then
            clearAllPlayerESP()
        end
    end)
end)
task.spawn(function()
    local subspaceMineESPData = {}
    local FolderName = "ToolsAdds" 

    local function getMineOwner(mineName)
        local ownerName = mineName:match("SubspaceTripmine(.+)")
        if not ownerName then return "Unknown" end 
        local foundPlayer = Players:FindFirstChild(ownerName)
        local displayName = foundPlayer and foundPlayer.DisplayName or ownerName
        return displayName
    end

    local function createMineESP(mine)
        local ownerName = getMineOwner(mine.Name)

        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ESP_Hitbox"
        selectionBox.Adornee = mine 
        selectionBox.Color3 = Color3.fromRGB(167, 142, 255)
        selectionBox.LineThickness = 0.05
        selectionBox.Parent = mine 

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESP_Label"
        billboardGui.Adornee = mine
        billboardGui.Size = UDim2.new(0, 250, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 0.5, 0)
        billboardGui.AlwaysOnTop = false 
        billboardGui.Parent = mine

        local textLabel = Instance.new("TextLabel", billboardGui)
        textLabel.Size = UDim2.new(1, 0, 1, 0) 
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ownerName .. "'s Subspace Mine"
        textLabel.TextColor3 = Color3.fromRGB(167, 142, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0 
        textLabel.Font = Enum.Font.GothamBold 
        textLabel.TextSize = 16

        return { selectionBox = selectionBox, billboardGui = billboardGui, mine = mine }
    end

    local function refreshSubspaceMineESP()
        if not Config.SubspaceMineESP then
            for i, data in pairs(subspaceMineESPData) do
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[i] = nil
            end
            return
        end

        local toolsFolder = Workspace:FindFirstChild(FolderName)
        if not toolsFolder then return end

        local currentMines = {}

        for _, obj in pairs(toolsFolder:GetChildren()) do
            if obj.Name:match("^SubspaceTripmine") and obj:IsA("BasePart") then
                currentMines[obj] = true

                if not subspaceMineESPData[obj] then
                    subspaceMineESPData[obj] = createMineESP(obj)
                end
            end
        end

        for mineObj, data in pairs(subspaceMineESPData) do
            if not currentMines[mineObj] or not mineObj.Parent then
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[mineObj] = nil
            end
        end
    end

local _mineTimer = 0
Heartbeat:Connect(function(dt)
    _mineTimer = _mineTimer + dt
    if _mineTimer >= 1.5 then
        _mineTimer = 0
        pcall(refreshSubspaceMineESP)
    end
end)
end)
SharedState.FOV_MANAGER = {
    activeCount = 0,
    conn = nil,
    forcedFOV = 70,
}
function SharedState.FOV_MANAGER:Start()
    if self.conn then return end
    self.forcedFOV = Config.FOV or 70
    self.conn = RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if cam then
            local targetFOV = Config.FOV or self.forcedFOV
            if cam.FieldOfView ~= targetFOV then
                cam.FieldOfView = targetFOV
            end
        end
    end)
end
function SharedState.FOV_MANAGER:Stop()
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end
end
function SharedState.FOV_MANAGER:Push()
    self.activeCount = self.activeCount + 1
    self:Start()
end
function SharedState.FOV_MANAGER:Pop()
    if self.activeCount > 0 then
        self.activeCount = self.activeCount - 1
    end
    if self.activeCount == 0 then
        self:Stop()
    end
end

SharedState.ANTI_BEE_DISCO = {
    running = false,
    connections = {},
    originalMoveFunction = nil,
    controlsProtected = false,
    badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true },
}
function SharedState.ANTI_BEE_DISCO.nuke(obj)
    if not obj or not obj.Parent then return end
    if SharedState.ANTI_BEE_DISCO.badLightingNames[obj.Name] then
        pcall(function() obj:Destroy() end)
    end
end
function SharedState.ANTI_BEE_DISCO.disconnectAll()
    for _, conn in ipairs(SharedState.ANTI_BEE_DISCO.connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    SharedState.ANTI_BEE_DISCO.connections = {}
end
function SharedState.ANTI_BEE_DISCO.protectControls()
    if SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerScripts = LocalPlayer.PlayerScripts
        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        if not Controls then return end
        local ab = SharedState.ANTI_BEE_DISCO
        if not ab.originalMoveFunction then ab.originalMoveFunction = Controls.moveFunction end
        local function protectedMoveFunction(self, moveVector, relativeToCamera)
            if ab.originalMoveFunction then ab.originalMoveFunction(self, moveVector, relativeToCamera) end
        end
        table.insert(ab.connections, RunService.Heartbeat:Connect(function()
            if not ab.running or not Config.AntiBeeDisco then return end
            if Controls.moveFunction ~= protectedMoveFunction then Controls.moveFunction = protectedMoveFunction end
        end))
        Controls.moveFunction = protectedMoveFunction
        ab.controlsProtected = true
    end)
end
function SharedState.ANTI_BEE_DISCO.restoreControls()
    if not SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        local ab = SharedState.ANTI_BEE_DISCO
        if Controls and ab.originalMoveFunction then
            Controls.moveFunction = ab.originalMoveFunction
            ab.controlsProtected = false
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.blockBuzzingSound()
    pcall(function()
        local beeScript = LocalPlayer.PlayerScripts:FindFirstChild("Bee", true)
        if beeScript then
            local buzzing = beeScript:FindFirstChild("Buzzing")
            if buzzing and buzzing:IsA("Sound") then buzzing:Stop(); buzzing.Volume = 0 end
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.Enable()
    local ab = SharedState.ANTI_BEE_DISCO
    if ab.running then return end
    ab.running = true
    for _, inst in ipairs(Lighting:GetDescendants()) do ab.nuke(inst) end
    table.insert(ab.connections, Lighting.DescendantAdded:Connect(function(obj)
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.nuke(obj)
    end))
    ab.protectControls()
    table.insert(ab.connections, RunService.Heartbeat:Connect(function()
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.blockBuzzingSound()
    end))
    SharedState.FOV_MANAGER:Push()
end
function SharedState.ANTI_BEE_DISCO.Disable()
    local ab = SharedState.ANTI_BEE_DISCO
    if not ab.running then return end
    ab.running = false
    ab.restoreControls()
    ab.disconnectAll()
    SharedState.FOV_MANAGER:Pop()
end

_G.ANTI_BEE_DISCO = SharedState.ANTI_BEE_DISCO

if Config.AntiBeeDisco then
    task.delay(1, function()
        if SharedState.ANTI_BEE_DISCO.Enable then 
            local oldShowNotification = ShowNotification
            ShowNotification = function() end
            SharedState.ANTI_BEE_DISCO.Enable()
            ShowNotification = oldShowNotification
        end
    end)
end

local lastFOV = Config.FOV or 70
local fovConnection = nil

local function enforceFOV()
    local camera = Workspace.CurrentCamera
    if camera and Config.FOV and camera.FieldOfView ~= Config.FOV then
        camera.FieldOfView = Config.FOV
    end
end

fovConnection = RunService.RenderStepped:Connect(enforceFOV)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local camera = Workspace.CurrentCamera
    if camera then
        task.wait()
        enforceFOV()
    end
end)

local function updateFOV(newFOV)
    Config.FOV = newFOV
    SaveConfig()
    enforceFOV()
end

SharedState.XrayData = {
    TARGET_TRANS = 0.7,
    INVISIBLE_TRANS = 1,
    ENFORCE_EVERY_FRAME = true,
    trackedObjects = {},
    trackedModels = {},
}

SharedState.XrayFunctions = {}
SharedState.XrayFunctions.nameHasClone = function(name)
    return string.find(string.lower(name), "clone", 1, true) ~= nil
end
SharedState.XrayFunctions.getTargetTransparency = function(obj)
    local xd = SharedState.XrayData
    if obj.Name == "HumanoidRootPart" then return xd.INVISIBLE_TRANS end
    return xd.TARGET_TRANS
end
SharedState.XrayFunctions.applyObject = function(obj)
    local target = SharedState.XrayFunctions.getTargetTransparency(obj)
    if obj:IsA("BasePart") then
        obj.CanCollide = false
        obj.Transparency = target
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = target
    end
end
SharedState.XrayFunctions.trackObject = function(obj)
    local xd = SharedState.XrayData
    local xf = SharedState.XrayFunctions
    if xd.trackedObjects[obj] then return end
    if not (obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture")) then return end
    xd.trackedObjects[obj] = true
    xf.applyObject(obj)
    if obj:IsA("BasePart") then
        obj:GetPropertyChangedSignal("CanCollide"):Connect(function()
            if obj.CanCollide ~= false then obj.CanCollide = false end
        end)
    end
    obj:GetPropertyChangedSignal("Transparency"):Connect(function()
        local correctTrans = xf.getTargetTransparency(obj)
        if obj.Transparency ~= correctTrans then obj.Transparency = correctTrans end
    end)
    obj.AncestryChanged:Connect(function()
        if obj.Parent == nil then xd.trackedObjects[obj] = nil end
    end)
end
SharedState.XrayFunctions.trackModel = function(model)
    local xd = SharedState.XrayData
    local xf = SharedState.XrayFunctions
    if xd.trackedModels[model] then return end
    xd.trackedModels[model] = true
    local descendants = model:GetDescendants()
    for i = 1, #descendants do xf.trackObject(descendants[i]) end
    model.DescendantAdded:Connect(function(d) xf.trackObject(d) end)
    model.AncestryChanged:Connect(function()
        if model.Parent == nil then xd.trackedModels[model] = nil end
    end)
end
SharedState.XrayFunctions.handleWorkspaceChild = function(child)
    if child.Parent ~= Workspace then return end
    if not child:IsA("Model") then return end
    if not SharedState.XrayFunctions.nameHasClone(child.Name) then return end
    SharedState.XrayFunctions.trackModel(child)
end
SharedState.XrayFunctions.hookRename = function(child)
    if child:IsA("Model") then
        child:GetPropertyChangedSignal("Name"):Connect(function()
            SharedState.XrayFunctions.handleWorkspaceChild(child)
        end)
    end
end
SharedState.XrayFunctions.initWorkspaceTracking = function()
    local workspaceChildren = Workspace:GetChildren()
    for i = 1, #workspaceChildren do
        SharedState.XrayFunctions.handleWorkspaceChild(workspaceChildren[i])
        SharedState.XrayFunctions.hookRename(workspaceChildren[i])
    end
end
SharedState.XrayFunctions.initWorkspaceTracking()
Workspace.ChildAdded:Connect(function(child)
    task.defer(function() SharedState.XrayFunctions.handleWorkspaceChild(child) end)
    SharedState.XrayFunctions.hookRename(child)
end)

if SharedState.XrayData.ENFORCE_EVERY_FRAME then
    local frameSkip = 0
    SharedState.XrayFunctions.enforceXrayFrame = function()
        local xd = SharedState.XrayData
        local xf = SharedState.XrayFunctions
        local objList = {}
        for obj in pairs(xd.trackedObjects) do table.insert(objList, obj) end
        for i = 1, #objList do
            local obj = objList[i]
            if obj.Parent == nil then
                xd.trackedObjects[obj] = nil
            else
                if obj:IsA("BasePart") and obj.CanCollide ~= false then obj.CanCollide = false end
                local target = xf.getTargetTransparency(obj)
                if obj.Transparency ~= target then obj.Transparency = target end
            end
        end
    end
    
    RunService.Heartbeat:Connect(function()
        frameSkip = frameSkip + 1
        if frameSkip % 4 == 0 then
            SharedState.XrayFunctions.enforceXrayFrame()
        end
    end)
end

SharedState.FPSFunctions = {}
SharedState.FPSFunctions.removeMeshes = function(tool)
    if not tool:IsA("Tool") then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    local descendants = handle:GetDescendants()
    for i = 1, #descendants do
        local descendant = descendants[i]
        if descendant:IsA("SpecialMesh") or descendant:IsA("Mesh") or descendant:IsA("FileMesh") then
            descendant:Destroy()
        end
    end
end
SharedState.FPSFunctions.onCharacterAdded = function(character)
    local ff = SharedState.FPSFunctions
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and Config.FPSBoost then ff.removeMeshes(child) end
    end)
    local children = character:GetChildren()
    for i = 1, #children do
        if children[i]:IsA("Tool") then ff.removeMeshes(children[i]) end
    end
end
SharedState.FPSFunctions.onPlayerAdded = function(player)
    local ff = SharedState.FPSFunctions
    player.CharacterAdded:Connect(ff.onCharacterAdded)
    if player.Character then ff.onCharacterAdded(player.Character) end
end
SharedState.FPSFunctions.initPlayerTracking = function()
    local ff = SharedState.FPSFunctions
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do ff.onPlayerAdded(allPlayers[i]) end
    Players.PlayerAdded:Connect(ff.onPlayerAdded)
end
SharedState.FPSFunctions.initPlayerTracking()

if Config.CleanErrorGUIs then
    task.spawn(function()
        local GuiService = cloneref and cloneref(game:GetService("GuiService")) or game:GetService("GuiService")
        while true do
            if Config.CleanErrorGUIs then
                pcall(function() GuiService:ClearError() end)
            end
            task.wait(0.005)
        end
    end)
end

task.spawn(function()
    local function getChar()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        return char, hrp, hum
    end

    local function hasExclamation(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BillboardGui") then
                local label = d:FindFirstChildWhichIsA("TextLabel", true)
                if label and label.Text:find("!") then
                    return true
                end
            end
        end
        return false
    end

    local function applyVisuals(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BasePart") and d ~= target then
                d.Transparency = 0.5
                d.CanCollide = false
                d.CanTouch = false
                d.CanQuery = false
            elseif d:IsA("BillboardGui") and d.Name ~= "SentryLabel" then
                d:Destroy()
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 0.5
            end
        end
        if target:IsA("BasePart") and target.Name ~= "ProxyVisual" then
            target.Transparency = 1
            target.CanCollide = false
        end
    end

    local function getClosestSentry()
        local _, hrp = getChar()
        local closest, shortestDist = nil, math.huge
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst.Name:match("^Sentry_") then
                if hasExclamation(inst) then
                    local root = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
                    if root then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = inst
                        end
                    end
                end
            end
        end
        return closest
    end

    local previousTool = nil
    
    local function unequipBatAndRestore()
        local char, hrp, hum = getChar()
        local bat = char:FindFirstChild("Bat")
        
        if bat and hum then
            hum:UnequipTools(bat)
        end
        
        if previousTool and previousTool.Parent then
            if previousTool.Parent == LocalPlayer.Backpack or previousTool.Parent == char then
                hum:EquipTool(previousTool)
            end
        end
        previousTool = nil
    end
    
    local function equipBatAndStorePrevious()
        local char, hrp, hum = getChar()
        
        local currentTool = char:FindFirstChildWhichIsA("Tool")
        if currentTool and currentTool.Name ~= "Bat" then
            previousTool = currentTool
        end
        
        local bat = LocalPlayer.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
        if bat then
            hum:EquipTool(bat)
            return true
        end
        return false
    end

    while true do
        if Config.AutoDestroyTurrets then
            if LocalPlayer:GetAttribute("Stealing") == true then
                local char = LocalPlayer.Character
                if char then
                    local bat = char:FindFirstChild("Bat")
                    local hum = char:FindFirstChild("Humanoid")
                    if bat and hum then
                        hum:UnequipTools(bat)
                    end
                end
                task.wait(0.1)
            else
                local targetSentry = getClosestSentry()
                if targetSentry then
                    if not equipBatAndStorePrevious() then
                        task.wait(0.1)
                        continue
                    end
                    
                    local char, hrp, hum = getChar()
                    local bat = char:FindFirstChild("Bat")
                    
                    if bat then
                        applyVisuals(targetSentry)
                        local offset = hrp.CFrame.LookVector * 4
                        local targetCF = CFrame.new(hrp.Position + offset, hrp.Position)
                        
                        if targetSentry:IsA("Model") then
                            targetSentry:PivotTo(targetCF)
                        elseif targetSentry:IsA("BasePart") then
                            targetSentry.CFrame = targetCF
                        end
                        
                        bat:Activate()
                        task.wait(1)
                        
                        unequipBatAndRestore()
                        
                        task.wait(0.2)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

local desyncActive = false
local noAnimationActive = false
local serverSphere = nil
local lastServerUpdate = tick()
local desyncEnabledOnce = false

local uiElements = {
    EnableButton = nil,
    StatusLabel = nil
}

local function send_hook(packet)
    if packet.PacketId == 0x1B and desyncActive then
        local data = packet.AsBuffer
        buffer.writeu32(data, 1, 0xFFFFFFFF)
        packet:SetData(data)
    end
end

local function updateDesyncUI()
    if uiElements.EnableButton and desyncActive then
        uiElements.EnableButton.Text = "âœ“ DESYNC ACTIVE"
        uiElements.EnableButton.BackgroundColor3 = Theme.Success
        uiElements.EnableButton.TextColor3 = Color3.new(1,1,1)
    elseif uiElements.EnableButton then
        uiElements.EnableButton.Text = "ENABLE DESYNC"
        uiElements.EnableButton.BackgroundColor3 = Theme.Accent1
        uiElements.EnableButton.TextColor3 = Color3.new(1,1,1)
    end
    
    if uiElements.StatusLabel then
        if desyncActive then
            uiElements.StatusLabel.Text = "ACTIVE"
            uiElements.StatusLabel.TextColor3 = Theme.Success
        else
            uiElements.StatusLabel.Text = "INACTIVE"
            uiElements.StatusLabel.TextColor3 = Theme.Error
        end
    end
end

local function setupNoAnimationOnSteal()
    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        if Config.NoAnimationOnSteal then
            local isStealing = LocalPlayer:GetAttribute("Stealing")
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum and isStealing and hum.Animator then
                for _, track in pairs(hum.Animator:GetPlayingAnimationTracks()) do
                    pcall(function() track:Stop() end)
                end
            end
        end
    end)
    
    local noAnimTimer = 0
    Heartbeat:Connect(function(dt)
        if not Config.NoAnimationOnSteal then return end
        if not LocalPlayer:GetAttribute("Stealing") then return end
        
        noAnimTimer = noAnimTimer + dt
        if noAnimTimer >= 0.1 then
            noAnimTimer = 0
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Animator then
                for _, track in pairs(hum.Animator:GetPlayingAnimationTracks()) do
                    pcall(function() track:Stop() end)
                end
            end
        end
    end)
end
setupNoAnimationOnSteal()

local serverSphere = nil
local lastServerUpdate = tick()

local function createServerSphere(hrp)
    if serverSphere then 
        pcall(function() serverSphere:Destroy() end)
        serverSphere = nil
    end
    
    if not hrp or not hrp.Parent then return end
    
    serverSphere = Instance.new("Part")
    serverSphere.Name = "ServerPosMarker"
    serverSphere.Shape = Enum.PartType.Ball
    serverSphere.Size = Vector3.new(2, 2, 2)
    serverSphere.CFrame = hrp.CFrame
    serverSphere.Anchored = true
    serverSphere.CanCollide = false
    serverSphere.Transparency = 0.2
    serverSphere.Color = Color3.fromRGB(180, 0, 255)
    serverSphere.Material = Enum.Material.SmoothPlastic
    serverSphere.Parent = workspace
    
    local pointLight = Instance.new("PointLight", serverSphere)
    pointLight.Color = Color3.fromRGB(180, 0, 255)
    pointLight.Range = 6
    pointLight.Brightness = 1
    
    local bb = Instance.new("BillboardGui", serverSphere)
    bb.Size = UDim2.new(0, 140, 0, 45)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    
    local bgFrame = Instance.new("Frame", bb)
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgFrame.BackgroundTransparency = 0.6
    Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", bgFrame)
    stroke.Color = Color3.fromRGB(180, 0, 255)
    stroke.Thickness = 1
    
    local container = Instance.new("UIListLayout", bgFrame)
    container.HorizontalAlignment = Enum.HorizontalAlignment.Center
    container.VerticalAlignment = Enum.VerticalAlignment.Center
    container.Padding = UDim.new(0, 1)
    
    local function createRow(text, isTitle)
        local lbl = Instance.new("TextLabel", bgFrame)
        lbl.Size = UDim2.new(1, 0, 0, isTitle and 16 or 12)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = isTitle and Enum.Font.GothamBold or Enum.Font.Gotham
        lbl.TextSize = isTitle and 11 or 9
        lbl.TextColor3 = isTitle and Color3.fromRGB(180, 0, 255) or Color3.fromRGB(220, 220, 220)
        return lbl
    end
    
    createRow("SERVER POS", true)
    local row2 = createRow("STUDS: 0.0", false)
    local row3 = createRow("0s AGO", false)
    
    local hrpConnection = hrp:GetPropertyChangedSignal("CFrame"):Connect(function()
        if desyncActive and serverSphere then
            serverSphere.CFrame = hrp.CFrame
            lastServerUpdate = tick()
        end
    end)
    
    task.spawn(function()
        local _sphereUITimer = 0
Heartbeat:Connect(function(dt)
    _sphereUITimer = _sphereUITimer + dt
    if _sphereUITimer >= 0.15 then
        _sphereUITimer = 0
        if serverSphere and serverSphere.Parent and hrp and hrp.Parent then
            local dist = (hrp.Position - serverSphere.Position).Magnitude
            row2.Text = string.format("STUDS: %.1f", dist)
            row3.Text = string.format("%ds AGO", math.floor(tick() - lastServerUpdate))
        end
    end
end)
    end)
end

local function setupSphereRespawn()
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        if Config.ServerPositionMarker and desyncActive then
            local hrp = newChar:FindFirstChild("HumanoidRootPart")
            if hrp then createServerSphere(hrp) end
        end
    end)
end
setupSphereRespawn()

local function startDesync()
    if desyncActive or desyncEnabledOnce then return end
    
    local success = pcall(function() 
        if raknet and raknet.add_send_hook then
            raknet.add_send_hook(send_hook)
        end
    end)
    
    if success then
        desyncActive = true
        desyncEnabledOnce = true
        lastServerUpdate = tick()
        
        if Config.ServerPositionMarker then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then createServerSphere(hrp) end
    end
        
        updateDesyncUI()
    end
end

local markerCheckTimer = 0
Heartbeat:Connect(function(dt)
    if not desyncActive then return end
    
    markerCheckTimer = markerCheckTimer + dt
    if markerCheckTimer >= 0.5 then
        markerCheckTimer = 0
        if Config.ServerPositionMarker and not serverSphere then
            createServerSphere()
        elseif not Config.ServerPositionMarker and serverSphere then
            pcall(function() serverSphere:Destroy() end)
            serverSphere = nil
        end
    end
end)

local desyncGui = Instance.new("ScreenGui", PlayerGui)
desyncGui.Name = "SolanaDesyncPanel"
desyncGui.ResetOnSpawn = false
desyncGui.Enabled = Config.ShowDesyncGUI

local mainFrame = Instance.new("Frame", desyncGui)
mainFrame.Size = UDim2.new(0, 260 * MOBILE_SCALE, 0, 230 * MOBILE_SCALE)
mainFrame.Position = UDim2.new(Config.Positions.DesyncPanel.X, 0, Config.Positions.DesyncPanel.Y, 0)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BackgroundTransparency = 0.08
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12 * MOBILE_SCALE)
AddAnimatedBorder(mainFrame, 1.5 * MOBILE_SCALE)

local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 35 * MOBILE_SCALE)
header.BackgroundTransparency = 1
MakeDraggable(header, mainFrame, "DesyncPanel")

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -50 * MOBILE_SCALE, 1, 0)
title.Position = UDim2.new(0, 12 * MOBILE_SCALE, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Desync Panel"
title.Font = Enum.Font.Gotham
title.TextSize = 14 * MOBILE_SCALE
title.TextColor3 = Theme.TextPrimary
title.TextXAlignment = Enum.TextXAlignment.Left

local statusLabel = Instance.new("TextLabel", header)
statusLabel.Size = UDim2.new(0, 70 * MOBILE_SCALE, 0, 24 * MOBILE_SCALE)
statusLabel.Position = UDim2.new(1, -78 * MOBILE_SCALE, 0.5, -12 * MOBILE_SCALE)
statusLabel.BackgroundColor3 = Theme.Surface
statusLabel.BackgroundTransparency = 0.2
statusLabel.Text = "INACTIVE"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11 * MOBILE_SCALE
statusLabel.TextColor3 = Theme.Error
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 6 * MOBILE_SCALE)
uiElements.StatusLabel = statusLabel 

local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, -20 * MOBILE_SCALE, 1, -45 * MOBILE_SCALE)
content.Position = UDim2.new(0, 10 * MOBILE_SCALE, 0, 40 * MOBILE_SCALE)
content.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 6 * MOBILE_SCALE)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggleRow(parent, text, defaultValue, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30 * MOBILE_SCALE)
    row.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12 * MOBILE_SCALE
    lbl.TextColor3 = Theme.TextPrimary
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local isOn = defaultValue or false
    local toggleFrame = Instance.new("Frame", row)
    toggleFrame.Size = UDim2.new(0, 44 * MOBILE_SCALE, 0, 22 * MOBILE_SCALE)
    toggleFrame.Position = UDim2.new(1, -54 * MOBILE_SCALE, 0.5, -11 * MOBILE_SCALE)
    toggleFrame.BackgroundColor3 = isOn and Theme.Success or Theme.SurfaceHighlight
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1,0)
    
    local toggleDot = Instance.new("Frame", toggleFrame)
    toggleDot.Size = UDim2.new(0, 18 * MOBILE_SCALE, 0, 18 * MOBILE_SCALE)
    toggleDot.Position = isOn and UDim2.new(1, -20 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE) or UDim2.new(0, 2 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE)
    toggleDot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(1,0)
    
    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Size = UDim2.new(1,0,1,0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""

    toggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(toggleDot, TweenInfo.new(0.2), {Position = isOn and UDim2.new(1, -20 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE) or UDim2.new(0, 2 * MOBILE_SCALE, 0.5, -9 * MOBILE_SCALE)}):Play()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = isOn and Theme.Success or Theme.SurfaceHighlight}):Play()
        callback(isOn)
    end)
end

local enableButton = Instance.new("TextButton", content)
enableButton.Size = UDim2.new(1, 0, 0, 38 * MOBILE_SCALE)
enableButton.BackgroundColor3 = Theme.Accent1
enableButton.BackgroundTransparency = 0.08
enableButton.Text = "ENABLE DESYNC"
enableButton.Font = Enum.Font.Gotham
enableButton.TextSize = 12 * MOBILE_SCALE
enableButton.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", enableButton).CornerRadius = UDim.new(0, 8 * MOBILE_SCALE)
uiElements.EnableButton = enableButton 

enableButton.MouseButton1Click:Connect(startDesync)

createToggleRow(content, "Desync on Steal", Config.DesyncOnSteal or false, function(on)
    Config.DesyncOnSteal = on
    SaveConfig()
end)

createToggleRow(content, "Auto Start", Config.DesyncEnabled or false, function(on)
    Config.DesyncEnabled = on
    SaveConfig()
end)

createToggleRow(content, "No Animation on Steal", Config.NoAnimationOnSteal or false, function(on)
    Config.NoAnimationOnSteal = on
    SaveConfig()
end)

createToggleRow(content, "Server Position Marker", Config.ServerPositionMarker or false, function(on)
    Config.ServerPositionMarker = on
    SaveConfig()
end)

if Config.DesyncEnabled then
    task.spawn(function()
        task.wait()
        if not desyncActive and not desyncEnabledOnce then
            startDesync()
        end
    end)
end

LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    if Config.DesyncOnSteal and isStealing and not desyncActive and not desyncEnabledOnce then
        startDesync()
    end
end)

updateDesyncUI()

task.spawn(function()
    local stealingESPEnabled = Config.StealingESP or false
    local stealingESPData = {}
    
    while not SharedState or not SharedState.AllAnimalsCache do
        task.wait(0.5)
    end
    
local function getOccupiedSlots(plot)
    local occupied = {}
    local cache = SharedState.FullAnimalsCache or SharedState.AllAnimalsCache
    if not cache then return occupied end
    
    for _, pet in ipairs(cache) do
        if pet.plot == plot.Name then
            occupied[tonumber(pet.slot)] = true
        end
    end
    return occupied
end
    
    local function getFirstEmptySlot(plot)
        local podiumFolder = plot:FindFirstChild("AnimalPodiums")
        if not podiumFolder then return nil, nil end
        
        local occupied = getOccupiedSlots(plot)
        
        local maxSlot = 0
        local slots = {}
        for _, podium in ipairs(podiumFolder:GetChildren()) do
            local slotNum = tonumber(podium.Name)
            if slotNum then
                slots[slotNum] = podium
                if slotNum > maxSlot then
                    maxSlot = slotNum
                end
            end
        end
        
        for slot = 1, maxSlot do
            if not occupied[slot] and slots[slot] then
                return slots[slot], slot
            end
        end
        
        local nextSlot = maxSlot + 1
        if slots[nextSlot] then
            return slots[nextSlot], nextSlot
        end
        
        return nil, nil
    end
    
    local function getPlayerPlot(player)
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                local label = surfaceGui and surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                if label then
                    local text = label.Text:lower()
                    if text:find(player.DisplayName:lower(), 1, true) or text:find(player.Name:lower(), 1, true) then
                        return plot
                    end
                end
            end
        end
        return nil
    end
    
    local function isAnimalFromOwnPlot(animalName, playerPlot)
        if not playerPlot or not animalName then return false end
        
        local cache = SharedState.AllAnimalsCache
        if not cache then return false end
        
        for _, pet in ipairs(cache) do
            if pet.plot == playerPlot.Name and pet.name == animalName then
                return true
            end
        end
        return false
    end
    
    local function getDistanceToBase(player)
        local plot = getPlayerPlot(player)
        if not plot then return 999 end
        
        local plotSign = plot:FindFirstChild("PlotSign")
        if not plotSign then return 999 end
        
        local basePos = Vector3.new(plotSign.Position.X, -6, plotSign.Position.Z)
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return 999 end
        
        local dist = (hrp.Position - basePos).Magnitude
        return dist
    end
    
    local function getDistanceColor(distance)
        if distance <= 50 then
            return Color3.fromRGB(255, 50, 50)
        elseif distance <= 150 then
            return Color3.fromRGB(255, 180, 0)
        else
            return Color3.fromRGB(0, 255, 100)
        end
    end
    
    local function spamPlayer(targetPlayer)
        if not targetPlayer then return end
        
        local cmds = {"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"}
        for _, cmd in ipairs(cmds) do
            if _G.runAdminCommand then
                _G.runAdminCommand(targetPlayer, cmd)
            end
            task.wait(0.05)
        end
    end
    
local function createStealingESP(player, targetPodium, animalName, mutation, generation)
    if not targetPodium then return nil end
    
    local base = targetPodium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local attachPart = spawn or base or targetPodium
    if not attachPart then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "StealingESP_" .. player.UserId
    billboard.Size = UDim2.new(0, 280, 0, 70)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 2000
    billboard.ResetOnSpawn = false
    billboard.Parent = attachPart
    
    if player ~= LocalPlayer then
        local clickDetector = Instance.new("ClickDetector", attachPart)
        clickDetector.MaxActivationDistance = 50
        clickDetector.MouseClick:Connect(function()
            spamPlayer(player)
        end)
    end
    
    local container = Instance.new("Frame", billboard)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = Theme.Background or Color3.fromRGB(8, 8, 12)
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local border = Instance.new("UIStroke", container)
    border.Thickness = 1.2
    border.Transparency = 0.3
    border.Color = Theme.Accent1 or Color3.fromRGB(138, 43, 226)
    
    local initialDistance = getDistanceToBase(player)
    local initialColor = getDistanceColor(initialDistance)
    
    local nameLabel = Instance.new("TextLabel", container)
    nameLabel.Size = UDim2.new(1, -12, 0, 18)
    nameLabel.Position = UDim2.new(0, 6, 0, 0)
    nameLabel.BackgroundTransparency = 1
    if mutation and mutation ~= "None" then
        nameLabel.Text = "(STEALING) " .. animalName .. " [" .. mutation .. "]"
    else
        nameLabel.Text = "(STEALING) " .. animalName
    end
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextColor3 = initialColor
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    local genLabel = Instance.new("TextLabel", container)
    genLabel.Size = UDim2.new(1, -12, 0, 14)
    genLabel.Position = UDim2.new(0, 6, 0, 16)
    genLabel.BackgroundTransparency = 1
    genLabel.Text = generation or "$0/s"
    genLabel.Font = Enum.Font.Gotham
    genLabel.TextSize = 10
    genLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    genLabel.TextStrokeTransparency = 0.2
    genLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    genLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local stealerLabel = Instance.new("TextLabel", container)
    stealerLabel.Size = UDim2.new(0.6, -6, 0, 14)
    stealerLabel.Position = UDim2.new(0, 6, 0, 53)
    stealerLabel.BackgroundTransparency = 1
    stealerLabel.Text = "ðŸ‘¤ " .. player.DisplayName
    stealerLabel.Font = Enum.Font.Gotham
    stealerLabel.TextSize = 9
    stealerLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
    stealerLabel.TextStrokeTransparency = 0.2
    stealerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    stealerLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local distLabel = Instance.new("TextLabel", container)
    distLabel.Size = UDim2.new(0.4, -6, 0, 14)
    distLabel.Position = UDim2.new(0.6, 0, 0, 53)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = string.format("%.0f studs", initialDistance)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 9
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0.2
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local arrowLabel = Instance.new("TextLabel", container)
    arrowLabel.Size = UDim2.new(1, 0, 0, 20)
    arrowLabel.Position = UDim2.new(0, 0, 1, -23)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = "â–¼"
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.TextSize = 20
    arrowLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrowLabel.TextStrokeTransparency = 0.2
    arrowLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    arrowLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local function updateDistance()
        local newDistance = getDistanceToBase(player)
        distLabel.Text = string.format("%.0f studs", newDistance)
        local newColor = getDistanceColor(newDistance)
        nameLabel.TextColor3 = newColor
    end
    
    return {
        billboard = billboard,
        nameLabel = nameLabel,
        genLabel = genLabel,
        distLabel = distLabel,
        arrowLabel = arrowLabel,
        updateDistance = updateDistance,
        currentPodium = targetPodium,
        player = player
    }
end
    
    local function updateStealingESP(player)
        local data = stealingESPData[player.UserId]
        
        local isStealing = player:GetAttribute("Stealing")
        local stealingIndex = player:GetAttribute("StealingIndex")
        
        if not isStealing or not stealingIndex then
            if data then
                if data.billboard then data.billboard:Destroy() end
                stealingESPData[player.UserId] = nil
            end
            return
        end
        
        local playerPlot = getPlayerPlot(player)
        if not playerPlot then return end
        if isAnimalFromOwnPlot(stealingIndex, playerPlot) then
            if data then
                if data.billboard then data.billboard:Destroy() end
                stealingESPData[player.UserId] = nil
            end
            return
        end
        
        local targetPodium, slotNumber = getFirstEmptySlot(playerPlot)
        
        if not targetPodium then
            if data and data.billboard then
                data.billboard.Visible = false
            end
            return
        end

        if data and data.updateDistance then
    data.updateDistance()
end
        
if not data then
    local mutation = "None"
    local genText = "$0/s"
local cache = SharedState.FullAnimalsCache or SharedState.AllAnimalsCache
if cache then
    for _, pet in ipairs(cache) do
            if pet.name == stealingIndex then
                mutation = pet.mutation or "None"
                genText = pet.genText or "$0/s"
                break
            end
        end
    end
    
    local newESP = createStealingESP(player, targetPodium, stealingIndex, mutation, genText)
    if newESP then
        stealingESPData[player.UserId] = newESP
        data = newESP
    else
        return
    end
end
        
        if data.currentPodium ~= targetPodium then
            if data.billboard then data.billboard:Destroy() end
            
            local newESP = createStealingESP(player, targetPodium, stealingIndex)
            if newESP then
                stealingESPData[player.UserId] = newESP
                data = newESP
            end
            return
        end
        
        local distance = getDistanceToBase(player)
        local color = getDistanceColor(distance)
        
        if data.brainrotLabel then
            data.brainrotLabel.Text = "(STEALING) " .. stealingIndex
            data.brainrotLabel.TextColor3 = color
        end
        
        if data.distLabel then
            data.distLabel.Text = "STUDS AWAY: " .. string.format("%.0f", distance)
        end
        
        if data.billboard then
            data.billboard.Visible = true
        end
    end
    
    local function clearAllStealingESP()
        for userId, data in pairs(stealingESPData) do
            if data.billboard then data.billboard:Destroy() end
        end
        stealingESPData = {}
    end
    
    Heartbeat:Connect(function()
        if not stealingESPEnabled then
            if next(stealingESPData) then
                clearAllStealingESP()
            end
            return
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(function() updateStealingESP(player) end)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        local data = stealingESPData[player.UserId]
        if data then
            if data.billboard then data.billboard:Destroy() end
            stealingESPData[player.UserId] = nil
        end
    end)
end)

_G.MOBILE_SCALE = MOBILE_SCALE

print("SolanaX leaked by Solar")
print("SolanaX source leaked at fpsl for free btw")
