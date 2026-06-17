-- ==================== NOX FLASH TP COMPLETE V3 + AP SPAM + BRAINROT + SNOWFLAKE FALLING ====================
-- Full integration: Flash TP + Spam No-Kick + AP SPAM + BRAINROT TRANSPARENCY 75% + SNOWFLAKE FALLING FX
-- CrÃ©Ã©: 2026 | Fusion NOX + Lowzyx + AP SPAM + Brainrot + Snowflake FALLING Modifications
-- âœ… MODIFIÃ‰: AP PROT applique BALLOON + RAGDOLL Ã  l'activation
-- âœ… AP SPAM cible le joueur le plus proche automatiquement
-- âœ… FIX: AP PROTECT ne fonctionne que si le toggle est ACTIVÃ‰
-- âœ… INTERFACE REDESIGNÃ‰E: Nouveau style UI moderne
-- âœ… AP SPAM: TINY + ROCKET + BALLOON (3 effets uniquement)
-- âœ… NOUVEAU: BRAINROT TRANSPARENCY 75% TOGGLE
-- âœ… ALIGN TAPIS V2: Equip Carpet + TP + Unequip Carpet + Equip Flash + Camera Angle
-- âœ… FIX: FLASH TELEPORT ACTIVATION - DÃ©lai augmentÃ© + vÃ©rification Ã©quipement
-- âœ… NEW: SNOWFLAKE FALLING ANIMATION - Flocons tombent du haut vers le bas!

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local RepStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== CONFIG SYSTEM ====================
local configFile = "Nox_TP_Config.json"
local Config = {
   flashEnabled = true,
   giantEnabled = false,
   zeroGravityEnabled = false,
   alignCameraEnabled = false,
   speedBoostEnabled = false,
   triggerValue = 0.91,
   apProtEnabled = false,
   brainrotEnabled = false,
   keybinds = {
       alignCam = "C",
       apSpam = "Z",
   }
}

if isfile and isfile(configFile) then
   local success, decoded = pcall(function()
       return HttpService:JSONDecode(readfile(configFile))
   end)
   if success and decoded then
       for k, v in pairs(decoded) do
           Config[k] = v
       end
   end
end

local function saveConfig()
   if writefile then
       pcall(function()
           writefile(configFile, HttpService:JSONEncode(Config))
       end)
   end
end

-- ==================== TAPIS SYSTEM ====================
local TAPIS_X_VALUES = {-331.06, -323.77, -316.29, -308.72, -301.25, -301.46, -309.11, -316.47, -323.97, -331.33}
local TAPIS_Z_VALUES = {99.70, 130.00}

local function findClosestTapisPosition()
  local char = player.Character
  if not char then return nil end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  if not hrp then return nil end
  
  local closestX, closestZ = nil, nil
  local closestDist = math.huge
  
  for _, x in ipairs(TAPIS_X_VALUES) do
     for _, z in ipairs(TAPIS_Z_VALUES) do
        local dist = math.sqrt((x - hrp.Position.X)^2 + (z - hrp.Position.Z)^2)
        if dist < closestDist then
           closestDist = dist
           closestX = x
           closestZ = z
        end
     end
  end
  
  return closestX, closestZ
end

local function alignTapis()
  local char = player.Character
  if not char then return end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  local backpack = player:FindFirstChild("Backpack")
  if not hrp then return end
  
  local x, z = findClosestTapisPosition()
  if not x or not z then return end
  
  -- Equiper le Flying Carpet
  local flyingCarpet = char:FindFirstChild("Flying Carpet") or (backpack and backpack:FindFirstChild("Flying Carpet"))
  if flyingCarpet then
     flyingCarpet.Parent = char
     task.wait(0.15)
  end
  
  -- Teleport Ã  la position X, Z la plus proche avec Y actuel
  local currentY = hrp.Position.Y
  hrp.CFrame = CFrame.new(x, currentY, z)
  task.wait(0.1)
  
  -- Desequiper le Flying Carpet
  if flyingCarpet and flyingCarpet.Parent == char then
     flyingCarpet.Parent = backpack
     task.wait(0.1)
  end
  
  -- Equiper le Flash Teleport
  local flash = char:FindFirstChild("Flash Teleport") or (backpack and backpack:FindFirstChild("Flash Teleport"))
  if flash then
     flash.Parent = char
     task.wait(0.15)
  end
  
  -- Align camera avec angle en fonction de Z
  local camera = workspace.CurrentCamera
  if camera then
     local zPos = hrp.Position.Z
     local angleOffset = 0
     
     -- Determine l'angle en fonction de Z
     if math.abs(zPos - 99.70) < 5 then
        angleOffset = -180
     elseif math.abs(zPos - 129) < 5 then
        angleOffset = 0
     end
     
     -- Set camera type et apply angle
     camera.CameraType = Enum.CameraType.Custom
     
     local currentCF = camera.CFrame
     local pitch = math.rad(28.4)
     local yaw = math.rad(angleOffset)
     
     local direction = Vector3.new(
        math.sin(yaw) * math.cos(pitch),
        math.sin(pitch),
        math.cos(yaw) * math.cos(pitch)
     )
     
     camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
     
     if char:FindFirstChildOfClass("Humanoid") then
        camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
     end
  end
end

-- ==================== BRAINROT TRANSPARENCY SYSTEM ====================
local BRAINROT_TRANSPARENCY = 0.75
local brainrotNames = {}
local trackedParts = {}

local brainrotCore = {
   enabled = Config.brainrotEnabled or false,
}

-- GET NAMES FROM REPLICATED STORAGE (With Safety Check)
local modelsFolder = RepStorage:WaitForChild("Models", 5)
if modelsFolder then
   local animalsFolder = modelsFolder:WaitForChild("Animals", 5)
   if animalsFolder then
       for _, model in pairs(animalsFolder:GetChildren()) do
           brainrotNames[model.Name] = true
       end
   end
end

local function checkAndTrackBrainrot(obj)
   if obj:IsA("BasePart") or obj:IsA("Decal") then
       local nextParent = obj.Parent
       while nextParent and nextParent ~= workspace do
           if brainrotNames[nextParent.Name] then
               trackedParts[obj] = true
               break
           end
           nextParent = nextParent.Parent
       end
   end
end

-- Apply transparency to tracked brainrot parts
RunService.RenderStepped:Connect(function()
   for obj, _ in pairs(trackedParts) do
       if obj and obj.Parent then
           obj.LocalTransparencyModifier = brainrotCore.enabled and BRAINROT_TRANSPARENCY or 0
       else
           trackedParts[obj] = nil
       end
   end
end)

-- Scan workspace for brainrot parts
for _, obj in pairs(workspace:GetDescendants()) do checkAndTrackBrainrot(obj) end
workspace.DescendantAdded:Connect(checkAndTrackBrainrot)

-- ==================== AP PROTECTION SYSTEM ====================
local LOWZYX_EFFECTS = { "balloon", "ragdoll" }
local AP_SPAM_EFFECTS = { "tiny", "rocket", "balloon" }

local apProtCore = {
   enabled = Config.apProtEnabled or false,
   adminRemote = nil,
   lastSpamTime = {},
   protectionActive = false
}

local function setupAdminRemote()
   task.spawn(function()
       if not player.Character then player.CharacterAdded:Wait() end
       task.wait(1)
       local net = RepStorage:WaitForChild("Packages", 5):WaitForChild("Net", 5)
       if net then
           local children = net:GetChildren()
           local byName = {}
           for i, obj in ipairs(children) do byName[obj.Name] = i end
           local anchorIdx = byName["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
           if anchorIdx then
               local actual = children[anchorIdx + 1]
               if actual then
                   apProtCore.adminRemote = actual
                   print("âœ… Admin Remote trouvÃ© pour AP PROT")
               end
           end
       end
   end)
end

setupAdminRemote()

local function fireAdmin(...)
   if not apProtCore.adminRemote then return end
   local args = {...}
   task.spawn(function()
       pcall(function()
           apProtCore.adminRemote:InvokeServer(unpack(args))
       end)
   end)
end

local function applyApProtection(targetPlayer)
   if not apProtCore.enabled then return end
   if not apProtCore.adminRemote then return end
   if not targetPlayer or targetPlayer == player then return end
   local uid = targetPlayer.UserId
   if apProtCore.lastSpamTime[uid] and tick() - apProtCore.lastSpamTime[uid] < 0.5 then return end
   apProtCore.lastSpamTime[uid] = tick()
   for _, effect in ipairs(LOWZYX_EFFECTS) do
       fireAdmin("f888ee6e-c86d-46e1-93d7-0639d6635d42", targetPlayer, effect)
       task.wait(0.05)
   end
end

local function monitorStealAttempt()
   task.spawn(function()
       for _, obj in ipairs(RepStorage:GetDescendants()) do
           if obj:IsA("RemoteEvent") then
               obj.OnClientEvent:Connect(function(...)
                   if not apProtCore.enabled then return end
                   for _, a in ipairs({...}) do
                       if type(a) == "string" and a:lower():find("stealing") then
                           local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                           if not myHRP then return end
                           local best, bestDist = nil, math.huge
                           for _, p in ipairs(Players:GetPlayers()) do
                               if p ~= player then
                                   local char = p.Character
                                   if char then
                                       local hrp = char:FindFirstChild("HumanoidRootPart")
                                       if hrp then
                                           local dist = (hrp.Position - myHRP.Position).Magnitude
                                           if dist < bestDist then bestDist = dist; best = p end
                                       end
                                   end
                               end
                           end
                           if best then applyApProtection(best) end
                           return
                       end
                   end
               end)
           end
       end
   end)
end

monitorStealAttempt()

-- ==================== CREATE MAIN UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nox_TP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- ==================== GRADIENT SYSTEM ====================
local allGradients = {}
local NOX_ACCENT_KEYS = {
   ColorSequenceKeypoint.new(0,    Color3.fromRGB(45,  27,  105)),
   ColorSequenceKeypoint.new(0.2,  Color3.fromRGB(17,  153, 142)),
   ColorSequenceKeypoint.new(0.4,  Color3.fromRGB(138, 43,  226)),
   ColorSequenceKeypoint.new(0.6,  Color3.fromRGB(58,  12,  163)),
   ColorSequenceKeypoint.new(0.85, Color3.fromRGB(67,  97,  238)),
   ColorSequenceKeypoint.new(1,    Color3.fromRGB(45,  27,  105)),
}
local NOX_BG_KEYS = {
   ColorSequenceKeypoint.new(0,    Color3.fromRGB(15,  12,  41)),
   ColorSequenceKeypoint.new(0.35, Color3.fromRGB(30,  30,  63)),
   ColorSequenceKeypoint.new(0.7,  Color3.fromRGB(58,  12,  163)),
   ColorSequenceKeypoint.new(1,    Color3.fromRGB(20,  20,  50)),
}
local function addGradientToStroke(parent, thickness)
   local s = Instance.new("UIStroke")
   s.Thickness = thickness or 2
   s.Color = Color3.new(1,1,1)
   s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
   s.Parent = parent
   local g = Instance.new("UIGradient")
   g.Color = ColorSequence.new(NOX_ACCENT_KEYS)
   g.Rotation = 0; g.Parent = s
   table.insert(allGradients, g)
   return s
end
local nox_rotation = 0
RunService.RenderStepped:Connect(function(dt)
   nox_rotation = (nox_rotation + 80 * dt) % 360
   for _, g in ipairs(allGradients) do g.Rotation = nox_rotation end
end)


-- ==================== COULEURS THEME ====================
local THEME = {
   bg          = Color3.fromRGB(14, 14, 18),
   panel       = Color3.fromRGB(20, 20, 26),
   accent      = Color3.fromRGB(100, 80, 255),
   accentHover = Color3.fromRGB(120, 100, 255),
   btnOff      = Color3.fromRGB(28, 28, 36),
   btnHover    = Color3.fromRGB(38, 38, 50),
   btnOn       = Color3.fromRGB(35, 30, 60),
   toggleOff   = Color3.fromRGB(50, 50, 65),
   toggleOn    = Color3.fromRGB(100, 80, 255),
   red         = Color3.fromRGB(220, 50, 80),
   redBg       = Color3.fromRGB(40, 14, 20),
   redHover    = Color3.fromRGB(55, 20, 30),
   cyan        = Color3.fromRGB(0, 188, 212),
   cyanBg      = Color3.fromRGB(0, 50, 70),
   white       = Color3.new(1, 1, 1),
   subtext     = Color3.fromRGB(160, 155, 190),
   stroke      = Color3.fromRGB(60, 55, 90),
   strokeOn    = Color3.fromRGB(100, 80, 255),
}

-- ==================== SNOWFLAKE FALLING ANIMATION SYSTEM ====================
-- Les flocons ne tombent que sur les panels (Main et ServerPanel)
local SNOWFLAKE_SPEED = 4  -- DurÃ©e en secondes pour descendre
local SNOWFLAKE_SPAWN_DELAY = 0.3  -- DÃ©lai entre chaque flocon

local function createFallingSnowflake(container)
    local snowflake = Instance.new("TextLabel")
    snowflake.Size = UDim2.new(0, 25, 0, 25)
    snowflake.Position = UDim2.new(math.random(0, 100) / 100, 0, -0.1, 0)
    snowflake.BackgroundTransparency = 1
    snowflake.Text = "â„"
    snowflake.TextColor3 = Color3.fromRGB(150, 200, 255)
    snowflake.Font = Enum.Font.GothamBold
    snowflake.TextSize = math.random(10, 18)
    snowflake.ZIndex = 5
    snowflake.Parent = container
    snowflake.Rotation = math.random(0, 360)
    
    return snowflake
end

local function animateSnowflakeFalling(snowflake, container)
    local randomXOffset = math.random(-50, 50) / 100
    
    local tweenInfo = TweenInfo.new(
        SNOWFLAKE_SPEED,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.In
    )
    
    local tween = TweenService:Create(snowflake, tweenInfo, {
        Position = UDim2.new(math.clamp(snowflake.Position.X.Scale + randomXOffset, 0, 1), 0, 1.1, 0)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        if snowflake and snowflake.Parent then
            snowflake:Destroy()
        end
    end)
    
    local rotationConnection
    rotationConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if snowflake and snowflake.Parent then
            snowflake.Rotation = (snowflake.Rotation + 120 * deltaTime) % 360
            local progress = (snowflake.Position.Y.Offset) / container.AbsoluteSize.Y
            snowflake.TextTransparency = math.clamp(progress * 0.5, 0, 0.5)
        else
            rotationConnection:Disconnect()
        end
    end)
end

local function startSnowfallLoopForPanel(container)
    spawn(function()
        while container and container.Parent do
            local snowflake = createFallingSnowflake(container)
            animateSnowflakeFalling(snowflake, container)
            task.wait(SNOWFLAKE_SPAWN_DELAY)
        end
    end)
end

-- ==================== MAIN FRAME ====================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 108, 0, 360)
Main.Position = UDim2.new(0.5, -54, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15, 12, 41)
Main.BackgroundTransparency = 0.55
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
do
   local bgG = Instance.new("UIGradient")
   bgG.Color = ColorSequence.new(NOX_BG_KEYS); bgG.Rotation = 90; bgG.Parent = Main
   table.insert(allGradients, bgG)
end

local MainStroke = addGradientToStroke(Main, 2.5)

-- Conteneur de flocons pour le Main Panel
local mainSnowflakeContainer = Instance.new("Frame")
mainSnowflakeContainer.Name = "MainSnowflakeContainer"
mainSnowflakeContainer.Size = UDim2.new(1, 0, 1, 0)
mainSnowflakeContainer.Position = UDim2.new(0, 0, 0, 0)
mainSnowflakeContainer.BackgroundTransparency = 1
mainSnowflakeContainer.BorderSizePixel = 0
mainSnowflakeContainer.ZIndex = 1
mainSnowflakeContainer.Parent = Main

-- Lancer les flocons pour le Main Panel
startSnowfallLoopForPanel(mainSnowflakeContainer)

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 12, 41)
TitleBar.BackgroundTransparency = 1
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = Main

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

-- Accent top bar
local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(0, 0, 0, 0)
AccentBar.Position = UDim2.new(0.25, 0, 0, 0)
AccentBar.BackgroundColor3 = THEME.accent
AccentBar.BorderSizePixel = 0
AccentBar.ZIndex = 3
AccentBar.Parent = TitleBar

local AccentGrad = Instance.new("UIGradient")
AccentGrad.Color = ColorSequence.new({
   ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 80, 255)),
   ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 80, 255)),
   ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 80, 255)),
})
AccentGrad.Parent = AccentBar

Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1, 0)

-- Snowflake icon dans la barre de titre
local SnowflakeIcon = Instance.new("TextLabel")
SnowflakeIcon.Size = UDim2.new(0, 20, 0, 20)
SnowflakeIcon.Position = UDim2.new(0, 5, 0, 4)
SnowflakeIcon.BackgroundTransparency = 1
SnowflakeIcon.Text = "â„"
SnowflakeIcon.TextColor3 = Color3.fromRGB(150, 200, 255)
SnowflakeIcon.Font = Enum.Font.GothamBold
SnowflakeIcon.TextSize = 14
SnowflakeIcon.ZIndex = 4
SnowflakeIcon.Parent = TitleBar

-- Animer le flocon dans la barre
RunService.RenderStepped:Connect(function(dt)
   SnowflakeIcon.Rotation = (SnowflakeIcon.Rotation + 60 * dt) % 360
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 16)
TitleLabel.Position = UDim2.new(0, 28, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NOX FLASH V3"
TitleLabel.TextColor3 = THEME.white
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -40, 0, 12)
StatsLabel.Position = UDim2.new(0, 28, 0, 22)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 00  PING: 000ms"
StatsLabel.TextColor3 = THEME.subtext
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 7
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.ZIndex = 3
StatsLabel.Parent = TitleBar

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 22, 0, 22)
SettingsBtn.Position = UDim2.new(1, -27, 0, 8)
SettingsBtn.BackgroundColor3 = THEME.btnOff
SettingsBtn.AutoButtonColor = false
SettingsBtn.Text = "âš™"
SettingsBtn.TextColor3 = THEME.subtext
SettingsBtn.Font = Enum.Font.GothamBold
SettingsBtn.TextSize = 12
SettingsBtn.BorderSizePixel = 0
SettingsBtn.ZIndex = 3
SettingsBtn.Parent = TitleBar

Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 6)

local SBStroke = Instance.new("UIStroke")
SBStroke.Thickness = 1
SBStroke.Color = THEME.stroke
SBStroke.Parent = SettingsBtn

SettingsBtn.MouseEnter:Connect(function()
   TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.btnHover, TextColor3 = THEME.white}):Play()
end)
SettingsBtn.MouseLeave:Connect(function()
   TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.btnOff, TextColor3 = THEME.subtext}):Play()
end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
       dragging = true; dragStart = input.Position; startPos = Main.Position
   end
end)
UserInputService.InputChanged:Connect(function(input)
   if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
       local delta = input.Position - dragStart
       Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
   end
end)
UserInputService.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
       dragging = false
   end
end)

-- ==================== CONTENT ====================
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -14, 1, -52)
Content.Position = UDim2.new(0, 7, 0, 46)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ZIndex = 2
Content.Parent = Main

-- ==================== NOTIFICATION SYSTEM ====================
local Notify = {}
do
   local notifGui = Instance.new("ScreenGui")
   notifGui.Name = "NoxNotify"
   notifGui.ResetOnSpawn = false
   notifGui.DisplayOrder = 1500
   notifGui.Parent = player:WaitForChild("PlayerGui")

   local holder = Instance.new("Frame")
   holder.Size = UDim2.fromOffset(220, 400)
   holder.Position = UDim2.new(0, 0, 1, -20)
   holder.AnchorPoint = Vector2.new(0, 1)
   holder.BackgroundTransparency = 1
   holder.Parent = notifGui

   local ll = Instance.new("UIListLayout")
   ll.FillDirection = Enum.FillDirection.Vertical
   ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
   ll.Padding = UDim.new(0, 6)
   ll.SortOrder = Enum.SortOrder.LayoutOrder
   ll.Parent = holder

   local pad = Instance.new("UIPadding")
   pad.PaddingLeft = UDim.new(0, 14)
   pad.PaddingBottom = UDim.new(0, 14)
   pad.Parent = holder

   local seq = 0
   function Notify.show(title, subtitle, duration)
       duration = duration or 2.5
       seq = seq + 1

       local card = Instance.new("Frame")
       card.Name = "Notif_"..seq
       card.Size = UDim2.fromOffset(0, 52)
       card.BackgroundColor3 = Color3.fromRGB(18, 8, 32)
       card.BackgroundTransparency = 0.05
       card.BorderSizePixel = 0
       card.ClipsDescendants = true
       card.LayoutOrder = seq
       card.ZIndex = 50
       card.Parent = holder
       Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

       local stroke = Instance.new("UIStroke")
       stroke.Color = Color3.fromRGB(140, 80, 255)
       stroke.Thickness = 1
       stroke.Parent = card

       local titleLbl = Instance.new("TextLabel")
       titleLbl.Size = UDim2.new(1, -16, 0, 18)
       titleLbl.Position = UDim2.fromOffset(10, 6)
       titleLbl.BackgroundTransparency = 1
       titleLbl.Text = title or ""
       titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
       titleLbl.TextSize = 12
       titleLbl.Font = Enum.Font.GothamBold
       titleLbl.TextXAlignment = Enum.TextXAlignment.Left
       titleLbl.ZIndex = 51
       titleLbl.Parent = card

       local subLbl = Instance.new("TextLabel")
       subLbl.Size = UDim2.new(1, -16, 0, 20)
       subLbl.Position = UDim2.fromOffset(10, 26)
       subLbl.BackgroundTransparency = 1
       subLbl.Text = subtitle or ""
       subLbl.TextColor3 = Color3.fromRGB(180, 160, 255)
       subLbl.TextSize = 11
       subLbl.Font = Enum.Font.Gotham
       subLbl.TextXAlignment = Enum.TextXAlignment.Left
       subLbl.ZIndex = 51
       subLbl.Parent = card

       local barBg = Instance.new("Frame")
       barBg.Size = UDim2.new(1, -20, 0, 3)
       barBg.Position = UDim2.new(0, 10, 1, -5)
       barBg.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
       barBg.BackgroundTransparency = 0.5
       barBg.BorderSizePixel = 0
       barBg.ZIndex = 52
       barBg.Parent = card
       Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

       local barFill = Instance.new("Frame")
       barFill.Size = UDim2.fromScale(1, 1)
       barFill.BackgroundColor3 = Color3.fromRGB(160, 100, 255)
       barFill.BorderSizePixel = 0
       barFill.ZIndex = 53
       barFill.Parent = barBg
       Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

       -- Slide in
       TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
           {Size = UDim2.fromOffset(190, 52)}):Play()
       -- Progress bar
       TweenService:Create(barFill, TweenInfo.new(duration, Enum.EasingStyle.Linear),
           {Size = UDim2.fromScale(0, 1)}):Play()
       -- Slide out
       task.delay(duration, function()
           TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
               {Size = UDim2.fromOffset(0, 52)}):Play()
           task.wait(0.25)
           if card and card.Parent then card:Destroy() end
       end)
   end
end

local function createToggle(yOffset, labelText, toggleVar, customColor)
   local onColor = customColor or THEME.toggleOn

   local btn = Instance.new("TextButton")
   btn.Size = UDim2.new(1, 0, 0, 22)
   btn.Position = UDim2.new(0, 0, 0, yOffset)
   btn.BackgroundColor3 = Color3.fromRGB(25, 20, 55)
   btn.BackgroundTransparency = 0.5
   btn.AutoButtonColor = false
   btn.Text = ""
   btn.BorderSizePixel = 0
   btn.ZIndex = 2
   btn.Parent = Content

   Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

   local stroke = Instance.new("UIStroke")
   stroke.Thickness = 1
   stroke.Color = THEME.stroke
   stroke.Parent = btn

   local lbl = Instance.new("TextLabel")
   lbl.Size = UDim2.new(0.65, 0, 1, 0)
   lbl.Position = UDim2.new(0, 7, 0, 0)
   lbl.BackgroundTransparency = 1
   lbl.TextColor3 = THEME.subtext
   lbl.Font = Enum.Font.GothamBold
   lbl.TextSize = 8
   lbl.TextXAlignment = Enum.TextXAlignment.Left
   lbl.TextYAlignment = Enum.TextYAlignment.Center
   lbl.ZIndex = 3
   lbl.Text = labelText
   lbl.Parent = btn

   local track = Instance.new("Frame")
   track.Size = UDim2.new(0, 28, 0, 12)
   track.Position = UDim2.new(1, -33, 0.5, -6)
   track.BackgroundColor3 = THEME.toggleOff
   track.BorderSizePixel = 0
   track.ZIndex = 3
   track.Parent = btn
   Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

   local knob = Instance.new("Frame")
   knob.Size = UDim2.new(0, 8, 0, 8)
   knob.Position = UDim2.new(0, 2, 0.5, -4)
   knob.BackgroundColor3 = THEME.subtext
   knob.BorderSizePixel = 0
   knob.ZIndex = 4
   knob.Parent = track
   Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

   local function refresh(isOn)
       if isOn then
           TweenService:Create(track, TweenInfo.new(0.25), {BackgroundColor3 = onColor}):Play()
           TweenService:Create(knob, TweenInfo.new(0.25), {Position = UDim2.new(0, 18, 0.5, -4), BackgroundColor3 = THEME.white}):Play()
           TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.btnOn}):Play()
           TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = THEME.white}):Play()
           stroke.Color = onColor
       else
           TweenService:Create(track, TweenInfo.new(0.25), {BackgroundColor3 = THEME.toggleOff}):Play()
           TweenService:Create(knob, TweenInfo.new(0.25), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = THEME.subtext}):Play()
           TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.btnOff}):Play()
           TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = THEME.subtext}):Play()
           stroke.Color = THEME.stroke
       end
   end

   refresh(_G[toggleVar])

   btn.MouseEnter:Connect(function()
       if not _G[toggleVar] then
           TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnHover}):Play()
       end
   end)
   btn.MouseLeave:Connect(function()
       if not _G[toggleVar] then
           TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff}):Play()
       end
   end)

   btn.MouseButton1Click:Connect(function()
       _G[toggleVar] = not _G[toggleVar]
       Config[toggleVar] = _G[toggleVar]
       saveConfig()
       refresh(_G[toggleVar])
       Notify.show(labelText, _G[toggleVar] and "Enabled" or "Disabled")

       if toggleVar == "zeroGravityEnabled" then
           if _G[toggleVar] then startZeroGravity() else stopZeroGravity() end
       end

       if toggleVar == "brainrotEnabled" then
           brainrotCore.enabled = _G[toggleVar]
           local status = brainrotCore.enabled and "âœ… ACTIVÃ‰E (75%)" or "âŒ DÃ‰SACTIVÃ‰E"
           print("ðŸ‘» BRAINROT " .. status)
       end
   end)

   return btn, refresh
end

_G.flashEnabled          = Config.flashEnabled
_G.giantEnabled          = Config.giantEnabled
_G.zeroGravityEnabled    = Config.zeroGravityEnabled
_G.alignCameraEnabled    = Config.alignCameraEnabled
_G.apProtEnabled         = Config.apProtEnabled
_G.brainrotEnabled       = Config.brainrotEnabled

-- ==================== KEYBINDS SYSTEM ====================

local yOff = 0
local SPACING = 26

createToggle(yOff,            "FLASH",      "flashEnabled")        ; yOff += SPACING
createToggle(yOff,            "GIANT",      "giantEnabled")        ; yOff += SPACING
createToggle(yOff,            "GRAVITY",    "zeroGravityEnabled")  ; yOff += SPACING

-- ALIGN CAM + KEYBINDS buttons (side by side)
local buttonsContainer = Instance.new("Frame")
buttonsContainer.Size = UDim2.new(1, 0, 0, 22)
buttonsContainer.Position = UDim2.new(0, 0, 0, yOff)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.BorderSizePixel = 0
buttonsContainer.ZIndex = 2
buttonsContainer.Parent = Content

-- ALIGN TAPIS button (left) - ModifiÃ© pour alignTapis
local alignCamBtn = Instance.new("TextButton")
alignCamBtn.Size = UDim2.new(0.5, -2, 1, 0)
alignCamBtn.Position = UDim2.new(0, 0, 0, 0)
alignCamBtn.BackgroundColor3 = THEME.btnOff
alignCamBtn.AutoButtonColor = false
alignCamBtn.Text = ""
alignCamBtn.BorderSizePixel = 0
alignCamBtn.ZIndex = 2
alignCamBtn.Parent = buttonsContainer

Instance.new("UICorner", alignCamBtn).CornerRadius = UDim.new(0, 7)

local alignStroke = Instance.new("UIStroke")
alignStroke.Thickness = 1
alignStroke.Color = THEME.stroke
alignStroke.Parent = alignCamBtn

local alignLbl = Instance.new("TextLabel")
alignLbl.Size = UDim2.new(1, 0, 1, 0)
alignLbl.Position = UDim2.new(0, 0, 0, 0)
alignLbl.BackgroundTransparency = 1
alignLbl.Text = "ALIGN"
alignLbl.TextColor3 = THEME.subtext
alignLbl.Font = Enum.Font.GothamBold
alignLbl.TextSize = 10
alignLbl.TextXAlignment = Enum.TextXAlignment.Center
alignLbl.TextYAlignment = Enum.TextYAlignment.Center
alignLbl.ZIndex = 3
alignLbl.Parent = alignCamBtn

yOff += SPACING

alignCamBtn.MouseEnter:Connect(function()
   TweenService:Create(alignCamBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.cyanBg}):Play()
   TweenService:Create(alignLbl, TweenInfo.new(0.15), {TextColor3 = THEME.cyan}):Play()
   alignStroke.Color = THEME.cyan
end)
alignCamBtn.MouseLeave:Connect(function()
   TweenService:Create(alignCamBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff}):Play()
   TweenService:Create(alignLbl, TweenInfo.new(0.15), {TextColor3 = THEME.subtext}):Play()
   alignStroke.Color = THEME.stroke
end)

alignCamBtn.MouseButton1Click:Connect(function()
   Notify.show("ALIGN TAPIS", "Ã‰quipement et TP!")
   alignTapis()
   TweenService:Create(alignCamBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 100, 150)}):Play()
   task.wait(0.3)
   TweenService:Create(alignCamBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.btnOff}):Play()
end)

-- KEYBINDS button (right)
local keybindsBtn = Instance.new("TextButton")
keybindsBtn.Size = UDim2.new(0.5, -2, 1, 0)
keybindsBtn.Position = UDim2.new(0.5, 4, 0, 0)
keybindsBtn.BackgroundColor3 = THEME.btnOff
keybindsBtn.AutoButtonColor = false
keybindsBtn.Text = ""
keybindsBtn.BorderSizePixel = 0
keybindsBtn.ZIndex = 2
keybindsBtn.Parent = buttonsContainer

Instance.new("UICorner", keybindsBtn).CornerRadius = UDim.new(0, 7)

local kbStroke = Instance.new("UIStroke")
kbStroke.Thickness = 1
kbStroke.Color = THEME.stroke
kbStroke.Parent = keybindsBtn

local kbLbl = Instance.new("TextLabel")
kbLbl.Size = UDim2.new(1, 0, 1, 0)
kbLbl.Position = UDim2.new(0, 0, 0, 0)
kbLbl.BackgroundTransparency = 1
kbLbl.Text = "KBND"
kbLbl.TextColor3 = THEME.subtext
kbLbl.Font = Enum.Font.GothamBold
kbLbl.TextSize = 10
kbLbl.TextXAlignment = Enum.TextXAlignment.Center
kbLbl.TextYAlignment = Enum.TextYAlignment.Center
kbLbl.ZIndex = 3
kbLbl.Parent = keybindsBtn

keybindsBtn.MouseEnter:Connect(function()
   TweenService:Create(keybindsBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 120)}):Play()
   TweenService:Create(kbLbl, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(150, 150, 255)}):Play()
   kbStroke.Color = Color3.fromRGB(150, 150, 255)
end)
keybindsBtn.MouseLeave:Connect(function()
   TweenService:Create(keybindsBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff}):Play()
   TweenService:Create(kbLbl, TweenInfo.new(0.15), {TextColor3 = THEME.subtext}):Play()
   kbStroke.Color = THEME.stroke
end)

keybindsBtn.MouseButton1Click:Connect(function()
   KeybindsPanel.Visible = not KeybindsPanel.Visible
end)

-- AP PROT toggle (rouge)
local apProtBtn, refreshApProt = createToggle(yOff, "AP PROT", "apProtEnabled", THEME.red)
yOff += SPACING

apProtBtn.MouseButton1Click:Connect(function()
   apProtCore.enabled = _G.apProtEnabled
   local status = apProtCore.enabled and "âœ… ACTIVÃ‰ (Balloon + Ragdoll)" or "âŒ DÃ‰SACTIVÃ‰"
   print("ðŸ›¡ï¸ AP PROT " .. status)
end)

-- ==================== AP SPAM BUTTON ====================
local function fireAdminSpam(targetPlayer, effect)
   if not apProtCore.adminRemote then return end
   if not targetPlayer or targetPlayer == player then return end
   task.spawn(function()
       pcall(function()
           apProtCore.adminRemote:InvokeServer("f888ee6e-c86d-46e1-93d7-0639d6635d42", targetPlayer, effect)
       end)
   end)
end

local function findClosestPlayer()
   local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if not myHRP then return nil end
   local closestPlayer, closestDist = nil, math.huge
   for _, p in ipairs(Players:GetPlayers()) do
       if p ~= player then
           local char = p.Character
           if char then
               local hrp = char:FindFirstChild("HumanoidRootPart")
               if hrp then
                   local d = (hrp.Position - myHRP.Position).Magnitude
                   if d < closestDist then closestDist = d; closestPlayer = p end
               end
           end
       end
   end
   return closestPlayer
end

local function spamPlayerWithAllEffects(targetPlayer)
   if not apProtCore.enabled then print("âŒ AP PROT n'est pas activÃ©!"); return end
   if not apProtCore.adminRemote then print("âŒ AdminRemote not found!"); return end
   if not targetPlayer or targetPlayer == player then return end
   for _, effect in ipairs(AP_SPAM_EFFECTS) do
       task.wait(0.1)
       fireAdminSpam(targetPlayer, effect)
   end
   print("ðŸ’¥ AP SPAM â†’ " .. targetPlayer.Name)
end

local spamBtn = Instance.new("TextButton")
spamBtn.Size = UDim2.new(1, 0, 0, 22)
spamBtn.Position = UDim2.new(0, 0, 0, yOff)
spamBtn.BackgroundColor3 = THEME.btnOff
spamBtn.AutoButtonColor = false
spamBtn.Text = ""
spamBtn.BorderSizePixel = 0
spamBtn.ZIndex = 2
spamBtn.Parent = Content

Instance.new("UICorner", spamBtn).CornerRadius = UDim.new(0, 7)

local spamStroke = Instance.new("UIStroke")
spamStroke.Thickness = 1
spamStroke.Color = THEME.stroke
spamStroke.Parent = spamBtn

local spamLbl = Instance.new("TextLabel")
spamLbl.Size = UDim2.new(1, -14, 1, 0)
spamLbl.Position = UDim2.new(0, 0, 0, 0)
spamLbl.BackgroundTransparency = 1
spamLbl.Text = "ðŸ’¥  AP SPAM"
spamLbl.TextColor3 = THEME.subtext
spamLbl.Font = Enum.Font.GothamBold
spamLbl.TextSize = 8
spamLbl.TextXAlignment = Enum.TextXAlignment.Center
spamLbl.TextYAlignment = Enum.TextYAlignment.Center
spamLbl.ZIndex = 3
spamLbl.Parent = spamBtn

yOff += SPACING

spamBtn.MouseEnter:Connect(function()
   TweenService:Create(spamBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.redHover}):Play()
end)
spamBtn.MouseLeave:Connect(function()
   TweenService:Create(spamBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.redBg}):Play()
end)
spamBtn.MouseButton1Click:Connect(function()
   Notify.show("AP SPAM", "Executed!")
   local target = findClosestPlayer()
   if target then
       TweenService:Create(spamBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 20, 30)}):Play()
       spamPlayerWithAllEffects(target)
       task.wait(0.8)
       TweenService:Create(spamBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.redBg}):Play()
   else
       print("âŒ Aucun joueur trouvÃ©!")
   end
end)

-- ==================== STEAL BAR ====================
local StealBarBG = Instance.new("Frame")
StealBarBG.Size = UDim2.new(1, 0, 0, 6)
StealBarBG.Position = UDim2.new(0, 0, 0, yOff)
StealBarBG.BackgroundColor3 = THEME.btnOff
StealBarBG.BorderSizePixel = 0
StealBarBG.ZIndex = 2
StealBarBG.Parent = Content
Instance.new("UICorner", StealBarBG).CornerRadius = UDim.new(1, 0)

local StealFill = Instance.new("Frame")
StealFill.Name = "Fill"
StealFill.Size = UDim2.new(0, 0, 1, 0)
StealFill.BackgroundColor3 = THEME.accent
StealFill.BorderSizePixel = 0
StealFill.ZIndex = 3
StealFill.Parent = StealBarBG
Instance.new("UICorner", StealFill).CornerRadius = UDim.new(1, 0)

yOff += 12

-- Discord label
local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Size = UDim2.new(1, 0, 0, 14)
DiscordLabel.Position = UDim2.new(0, 0, 1, -16)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "discord.gg/noxhub"
DiscordLabel.TextColor3 = THEME.subtext
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.TextSize = 7
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Center
DiscordLabel.TextTransparency = 0.5
DiscordLabel.ZIndex = 2
DiscordLabel.Parent = Content

-- Resize main to fit content
Main.Size = UDim2.new(0, 108, 0, yOff + 72)

-- ==================== COMPACT SETTINGS PANEL ====================
local antiRagdollConnection = nil
local espStates = { playersEnabled=false, timerEnabled=false, antiRagdollEnabled=false }
local espConnections = {}
local baseEspInstances = {}
local espBaseThread = nil

local function startAntiRagdoll()
   if antiRagdollConnection then return end
   antiRagdollConnection = RunService.Heartbeat:Connect(function()
       if not espStates.antiRagdollEnabled then return end
       local char = player.Character; if not char then return end
       local hum = char:FindFirstChildOfClass("Humanoid")
       local root = char:FindFirstChild("HumanoidRootPart")
       if not (hum and root) then return end
       local s = hum:GetState()
       local ragdolled = (s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown)
       local endTime = player:GetAttribute("RagdollEndTime")
       if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then ragdolled = true end
       if ragdolled then
           pcall(function() player:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
           for _, d in ipairs(char:GetDescendants()) do
               if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then d:Destroy() end
           end
           for _, obj in ipairs(char:GetDescendants()) do
               if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
           end
           if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
           workspace.CurrentCamera.CameraSubject = hum
           root.Anchored = false; root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
       end
   end)
end
local function stopAntiRagdoll()
   if antiRagdollConnection then antiRagdollConnection:Disconnect(); antiRagdollConnection = nil end
end

local function createPlayerESP(plr)
   if plr == player then return end
   if not plr.Character then return end
   if plr.Character:FindFirstChild("followme@rznnq") then return end
   local char = plr.Character
   local hrp = char:FindFirstChild("HumanoidRootPart")
   local head = char:FindFirstChild("Head")
   if not (hrp and head) then return end
   local hitbox = Instance.new("BoxHandleAdornment")
   hitbox.Name = "followme@rznnq"; hitbox.Adornee = hrp
   hitbox.Size = Vector3.new(4,6,2); hitbox.Color3 = Color3.fromRGB(0, 170, 255)
   hitbox.Transparency = 0.6; hitbox.ZIndex = 10; hitbox.AlwaysOnTop = true; hitbox.Parent = char
   local billboard = Instance.new("BillboardGui")
   billboard.Name = "cpsito riko"; billboard.Adornee = head
   billboard.Size = UDim2.new(0,200,0,50); billboard.StudsOffset = Vector3.new(0,3,0)
   billboard.AlwaysOnTop = true; billboard.Parent = char
   local lbl = Instance.new("TextLabel", billboard)
   lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
   lbl.Text = plr.DisplayName or plr.Name; lbl.TextColor3 = Color3.fromRGB(0, 170, 255)
   lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true
   lbl.TextStrokeTransparency = 0.7; lbl.TextStrokeColor3 = Color3.new(0,0,0)
end
local function removePlayerESP(plr)
   if not plr.Character then return end
   local h = plr.Character:FindFirstChild("followme@rznnq"); if h then h:Destroy() end
   local g = plr.Character:FindFirstChild("cpsito riko"); if g then g:Destroy() end
end
local function enablePlayerESP()
   for _, plr in ipairs(Players:GetPlayers()) do
       if plr ~= player then
           if plr.Character then createPlayerESP(plr) end
           local c = plr.CharacterAdded:Connect(function() task.wait(0.1); if espStates.playersEnabled then createPlayerESP(plr) end end)
           table.insert(espConnections, c)
       end
   end
   local c2 = Players.PlayerAdded:Connect(function(plr)
       if plr == player then return end
       local c3 = plr.CharacterAdded:Connect(function() task.wait(0.1); if espStates.playersEnabled then createPlayerESP(plr) end end)
       table.insert(espConnections, c3)
   end)
   table.insert(espConnections, c2)
end
local function disablePlayerESP()
   for _, plr in ipairs(Players:GetPlayers()) do removePlayerESP(plr) end
   for _, c in ipairs(espConnections) do if c then c:Disconnect() end end
   espConnections = {}
end

local function enableTimerESP()
   if espBaseThread then return end
   espBaseThread = RunService.RenderStepped:Connect(function()
       if not espStates.timerEnabled then return end
       local plotsFolder = workspace:FindFirstChild("Plots"); if not plotsFolder then return end
       for _, plot in ipairs(plotsFolder:GetChildren()) do
           local purchases = plot:FindFirstChild("Purchases")
           local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
           local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
           local billboard = baseEspInstances[plot.Name]
           local timeLabel = mainPart and mainPart:FindFirstChild("BillboardGui") and mainPart.BillboardGui:FindFirstChild("RemainingTime")
           if timeLabel and mainPart then
               if not billboard then
                   billboard = Instance.new("BillboardGui")
                   billboard.Name = "rznnq"..plot.Name; billboard.Size = UDim2.new(0,50,0,25)
                   billboard.StudsOffset = Vector3.new(0,5,0); billboard.AlwaysOnTop = true
                   billboard.Adornee = mainPart; billboard.MaxDistance = 1000; billboard.Parent = plot
                   local l = Instance.new("TextLabel", billboard)
                   l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextScaled = true
                   l.Font = Enum.Font.GothamBold; l.TextColor3 = Color3.fromRGB(0, 170, 255)
                   l.TextStrokeTransparency = 0; l.TextStrokeColor3 = Color3.new(0,0,0)
                   baseEspInstances[plot.Name] = billboard
               end
               local l = billboard:FindFirstChildWhichIsA("TextLabel")
               if l then l.Text = timeLabel.Text end
           elseif billboard then
               billboard:Destroy(); baseEspInstances[plot.Name] = nil
           end
       end
   end)
end
local function disableTimerESP()
   if espBaseThread then espBaseThread:Disconnect(); espBaseThread = nil end
   for _, b in pairs(baseEspInstances) do if b then b:Destroy() end end
   baseEspInstances = {}
end

-- ==================== SETTINGS PANEL ====================
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Name = "SettingsPanel"
SettingsPanel.Size = UDim2.new(0, 200, 0, 0)
SettingsPanel.AutomaticSize = Enum.AutomaticSize.Y
SettingsPanel.Position = UDim2.new(0.5, -100, 0.5, -180)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(15, 12, 41)
SettingsPanel.BackgroundTransparency = 0.55
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 10
SettingsPanel.Parent = ScreenGui
SettingsPanel.ClipsDescendants = false

Instance.new("UICorner", SettingsPanel).CornerRadius = UDim.new(0, 14)
do
   local spG = Instance.new("UIGradient")
   spG.Color = ColorSequence.new(NOX_BG_KEYS); spG.Rotation = 90; spG.Parent = SettingsPanel
   table.insert(allGradients, spG)
end
local PanelStroke = addGradientToStroke(SettingsPanel, 1.5)

local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size = UDim2.new(1,0,0,30); PanelTitle.BackgroundColor3 = Color3.fromRGB(15,12,41)
PanelTitle.BackgroundTransparency = 1
PanelTitle.BorderSizePixel = 0; PanelTitle.Text = "SETTINGS"
PanelTitle.TextColor3 = THEME.white; PanelTitle.Font = Enum.Font.GothamBold
PanelTitle.TextSize = 10; PanelTitle.ZIndex = 10; PanelTitle.Parent = SettingsPanel
Instance.new("UICorner", PanelTitle).CornerRadius = UDim.new(0, 12)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,20,0,20); CloseBtn.Position = UDim2.new(1,-24,0,5)
CloseBtn.BackgroundColor3 = THEME.btnOff; CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "Ã—"; CloseBtn.TextColor3 = THEME.subtext
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14
CloseBtn.ZIndex = 11; CloseBtn.Parent = PanelTitle
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() SettingsPanel.Visible = false end)

-- Draggable
do
   local dragging, dragStart, startPos
   PanelTitle.InputBegan:Connect(function(i)
       if i.UserInputType == Enum.UserInputType.MouseButton1 then
           dragging=true; dragStart=i.Position; startPos=SettingsPanel.Position
       end
   end)
   UserInputService.InputChanged:Connect(function(i)
       if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
           local d = i.Position - dragStart
           SettingsPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
       end
   end)
   UserInputService.InputEnded:Connect(function(i)
       if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
   end)
end

-- Content avec UIListLayout
local PanelContent = Instance.new("Frame")
PanelContent.Size = UDim2.new(1,-16,0,0); PanelContent.AutomaticSize = Enum.AutomaticSize.Y
PanelContent.Position = UDim2.new(0,8,0,36)
PanelContent.BackgroundTransparency = 1; PanelContent.BorderSizePixel = 0
PanelContent.ZIndex = 10; PanelContent.Parent = SettingsPanel
local pcLL = Instance.new("UIListLayout", PanelContent)
pcLL.Padding = UDim.new(0,5); pcLL.SortOrder = Enum.SortOrder.LayoutOrder
local pcPad = Instance.new("UIPadding", PanelContent)
pcPad.PaddingBottom = UDim.new(0,8)

-- Helper toggle pour le Settings panel (style NOX)
local function makeSettingToggle(labelText, order, onToggle)
   local row = Instance.new("TextButton")
   row.Size = UDim2.new(1,0,0,22); row.LayoutOrder = order
   row.BackgroundColor3 = THEME.btnOff; row.AutoButtonColor = false
   row.Text = ""; row.BorderSizePixel = 0; row.ZIndex = 11
   row.Parent = PanelContent
   Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
   local rs = Instance.new("UIStroke", row); rs.Color = THEME.stroke; rs.Thickness = 1

   local lbl = Instance.new("TextLabel", row)
   lbl.Size = UDim2.new(0.65,0,1,0); lbl.Position = UDim2.new(0,7,0,0)
   lbl.BackgroundTransparency = 1; lbl.TextColor3 = THEME.subtext
   lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 8
   lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center
   lbl.ZIndex = 12; lbl.Text = labelText

   local track = Instance.new("Frame", row)
   track.Size = UDim2.new(0,28,0,12); track.Position = UDim2.new(1,-33,0.5,-6)
   track.BackgroundColor3 = THEME.toggleOff; track.BorderSizePixel = 0; track.ZIndex = 12
   Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

   local knob = Instance.new("Frame", track)
   knob.Size = UDim2.new(0,8,0,8); knob.Position = UDim2.new(0,2,0.5,-4)
   knob.BackgroundColor3 = THEME.subtext; knob.BorderSizePixel = 0; knob.ZIndex = 13
   Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

   local isOn = false
   local function refresh(on)
       local onColor = THEME.toggleOn
       TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = on and onColor or THEME.toggleOff}):Play()
       TweenService:Create(knob,  TweenInfo.new(0.15), {
           Position         = on and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),
           BackgroundColor3 = on and THEME.white or THEME.subtext
       }):Play()
   end

   row.MouseButton1Click:Connect(function()
       isOn = not isOn
       refresh(isOn)
       Notify.show(labelText, isOn and "Enabled" or "Disabled")
       onToggle(isOn)
   end)
end

makeSettingToggle("ESP Players",  1, function(on) espStates.playersEnabled=on;  if on then enablePlayerESP()  else disablePlayerESP()  end end)
makeSettingToggle("ESP Timer",    2, function(on) espStates.timerEnabled=on;    if on then enableTimerESP()   else disableTimerESP()   end end)
makeSettingToggle("Anti-Ragdoll", 3, function(on) espStates.antiRagdollEnabled=on; if on then startAntiRagdoll() else stopAntiRagdoll() end end)

-- âœ… AUTO KICK ON STEAL - ALWAYS ACTIVE (pas de toggle)

-- Trigger label
local TriggerLabel = Instance.new("TextLabel")
TriggerLabel.Size = UDim2.new(1, 0, 0, 16)
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Text = "TRIGGER: 91%"
TriggerLabel.TextColor3 = THEME.subtext
TriggerLabel.Font = Enum.Font.GothamBold
TriggerLabel.TextSize = 9
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
TriggerLabel.ZIndex = 10
TriggerLabel.LayoutOrder = 4
TriggerLabel.Parent = PanelContent

-- Trigger buttons (+ et -)
local TriggerButtonsContainer = Instance.new("Frame")
TriggerButtonsContainer.Size = UDim2.new(1, 0, 0, 28)
TriggerButtonsContainer.BackgroundTransparency = 1
TriggerButtonsContainer.LayoutOrder = 5
TriggerButtonsContainer.ZIndex = 10
TriggerButtonsContainer.Parent = PanelContent

local sliderValue = Config.triggerValue or 0.91

-- Minus button
local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 35, 0, 28)
minusBtn.Position = UDim2.new(0, 0, 0, 0)
minusBtn.BackgroundColor3 = THEME.btnOff
minusBtn.AutoButtonColor = false
minusBtn.Text = "âˆ’"
minusBtn.TextColor3 = THEME.subtext
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 14
minusBtn.BorderSizePixel = 0
minusBtn.ZIndex = 11
minusBtn.Parent = TriggerButtonsContainer
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", minusBtn).Color = THEME.stroke

-- Display value
local triggerDisplay = Instance.new("TextLabel")
triggerDisplay.Size = UDim2.new(1, -80, 1, 0)
triggerDisplay.Position = UDim2.new(0, 40, 0, 0)
triggerDisplay.BackgroundColor3 = THEME.btnHover
triggerDisplay.BorderSizePixel = 0
triggerDisplay.Text = math.floor(sliderValue * 100) .. "%"
triggerDisplay.TextColor3 = THEME.cyan
triggerDisplay.Font = Enum.Font.GothamBold
triggerDisplay.TextSize = 10
triggerDisplay.ZIndex = 11
triggerDisplay.Parent = TriggerButtonsContainer
Instance.new("UICorner", triggerDisplay).CornerRadius = UDim.new(0, 6)

-- Plus button
local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 35, 0, 28)
plusBtn.Position = UDim2.new(1, -35, 0, 0)
plusBtn.BackgroundColor3 = THEME.btnOff
plusBtn.AutoButtonColor = false
plusBtn.Text = "+"
plusBtn.TextColor3 = THEME.subtext
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 14
plusBtn.BorderSizePixel = 0
plusBtn.ZIndex = 11
plusBtn.Parent = TriggerButtonsContainer
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", plusBtn).Color = THEME.stroke

-- Update function
local function updateTriggerDisplay()
   triggerDisplay.Text = math.floor(sliderValue * 100) .. "%"
   TriggerLabel.Text = "TRIGGER: " .. math.floor(sliderValue * 100) .. "%"
   Config.triggerValue = sliderValue
   saveConfig()
end

-- Minus button logic
minusBtn.MouseButton1Click:Connect(function()
   sliderValue = math.max(0, sliderValue - 0.01)
   updateTriggerDisplay()
   TweenService:Create(minusBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 30, 30)}):Play()
   task.wait(0.15)
   TweenService:Create(minusBtn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.btnOff}):Play()
end)

-- Plus button logic
plusBtn.MouseButton1Click:Connect(function()
   sliderValue = math.min(1, sliderValue + 0.01)
   updateTriggerDisplay()
   TweenService:Create(plusBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 60, 30)}):Play()
   task.wait(0.15)
   TweenService:Create(plusBtn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.btnOff}):Play()
end)

-- Hover effects
minusBtn.MouseEnter:Connect(function() TweenService:Create(minusBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnHover, TextColor3 = THEME.white}):Play() end)
minusBtn.MouseLeave:Connect(function() TweenService:Create(minusBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff, TextColor3 = THEME.subtext}):Play() end)
plusBtn.MouseEnter:Connect(function() TweenService:Create(plusBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnHover, TextColor3 = THEME.white}):Play() end)
plusBtn.MouseLeave:Connect(function() TweenService:Create(plusBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff, TextColor3 = THEME.subtext}):Play() end)

TriggerLabel.Text = "TRIGGER: " .. math.floor(sliderValue * 100) .. "%"

-- ==================== TRANSPARENCY TOGGLE ====================
local TransparencyBtn = Instance.new("TextButton")
TransparencyBtn.Size = UDim2.new(1, 0, 0, 24)
TransparencyBtn.Position = UDim2.new(0, 0, 0, 48)
TransparencyBtn.BackgroundColor3 = THEME.btnOff
TransparencyBtn.AutoButtonColor = false
TransparencyBtn.Text = ""
TransparencyBtn.BorderSizePixel = 0
TransparencyBtn.ZIndex = 10
TransparencyBtn.Parent = PanelContent

Instance.new("UICorner", TransparencyBtn).CornerRadius = UDim.new(0, 6)

local TransStroke = Instance.new("UIStroke")
TransStroke.Thickness = 1
TransStroke.Color = THEME.stroke
TransStroke.Parent = TransparencyBtn

local TransLabel = Instance.new("TextLabel")
TransLabel.Size = UDim2.new(0.65, 0, 1, 0)
TransLabel.Position = UDim2.new(0, 7, 0, 0)
TransLabel.BackgroundTransparency = 1
TransLabel.TextColor3 = THEME.subtext
TransLabel.Font = Enum.Font.GothamBold
TransLabel.TextSize = 8
TransLabel.TextXAlignment = Enum.TextXAlignment.Left
TransLabel.TextYAlignment = Enum.TextYAlignment.Center
TransLabel.ZIndex = 11
TransLabel.Text = "TRANSPARENCY"
TransLabel.Parent = TransparencyBtn

local TransTrack = Instance.new("Frame")
TransTrack.Size = UDim2.new(0, 28, 0, 12)
TransTrack.Position = UDim2.new(1, -33, 0.5, -6)
TransTrack.BackgroundColor3 = THEME.toggleOff
TransTrack.BorderSizePixel = 0
TransTrack.ZIndex = 11
TransTrack.Parent = TransparencyBtn
Instance.new("UICorner", TransTrack).CornerRadius = UDim.new(1, 0)

local TransKnob = Instance.new("Frame")
TransKnob.Size = UDim2.new(0, 9, 0, 9)
TransKnob.Position = UDim2.new(0, 2, 0.5, -4.5)
TransKnob.BackgroundColor3 = THEME.subtext
TransKnob.BorderSizePixel = 0
TransKnob.ZIndex = 12
TransKnob.Parent = TransTrack
Instance.new("UICorner", TransKnob).CornerRadius = UDim.new(1, 0)

local function refreshTransparency(isOn)
   if isOn then
       TweenService:Create(TransTrack, TweenInfo.new(0.25), {BackgroundColor3 = THEME.cyan}):Play()
       TweenService:Create(TransKnob, TweenInfo.new(0.25), {Position = UDim2.new(0, 17, 0.5, -4.5), BackgroundColor3 = THEME.white}):Play()
       TweenService:Create(TransparencyBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.btnOn}):Play()
       TweenService:Create(TransLabel, TweenInfo.new(0.2), {TextColor3 = THEME.white}):Play()
       TransStroke.Color = THEME.cyan
   else
       TweenService:Create(TransTrack, TweenInfo.new(0.25), {BackgroundColor3 = THEME.toggleOff}):Play()
       TweenService:Create(TransKnob, TweenInfo.new(0.25), {Position = UDim2.new(0, 2, 0.5, -4.5), BackgroundColor3 = THEME.subtext}):Play()
       TweenService:Create(TransparencyBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.btnOff}):Play()
       TweenService:Create(TransLabel, TweenInfo.new(0.2), {TextColor3 = THEME.subtext}):Play()
       TransStroke.Color = THEME.stroke
   end
end

refreshTransparency(_G.brainrotEnabled)

TransparencyBtn.MouseEnter:Connect(function()
   if not _G.brainrotEnabled then
       TweenService:Create(TransparencyBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnHover}):Play()
   end
end)
TransparencyBtn.MouseLeave:Connect(function()
   if not _G.brainrotEnabled then
       TweenService:Create(TransparencyBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff}):Play()
   end
end)

TransparencyBtn.MouseButton1Click:Connect(function()
   _G.brainrotEnabled = not _G.brainrotEnabled
   Config.brainrotEnabled = _G.brainrotEnabled
   saveConfig()
   refreshTransparency(_G.brainrotEnabled)
   brainrotCore.enabled = _G.brainrotEnabled
   local status = brainrotCore.enabled and "âœ… ACTIVÃ‰E (75%)" or "âŒ DÃ‰SACTIVÃ‰E"
   print("ðŸ‘» TRANSPARENCY " .. status)
end)

-- Reset button
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(1, 0, 0, 22)
ResetBtn.Position = UDim2.new(0, 0, 0, 78)
ResetBtn.BackgroundColor3 = THEME.btnOff
ResetBtn.BorderSizePixel = 0
ResetBtn.Text = "RESET CONFIG"
ResetBtn.TextColor3 = THEME.subtext
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 8
ResetBtn.ZIndex = 10
ResetBtn.Parent = PanelContent
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", ResetBtn).Color = THEME.stroke

ResetBtn.MouseEnter:Connect(function() TweenService:Create(ResetBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnHover, TextColor3 = THEME.white}):Play() end)
ResetBtn.MouseLeave:Connect(function() TweenService:Create(ResetBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff, TextColor3 = THEME.subtext}):Play() end)

ResetBtn.MouseButton1Click:Connect(function()
   Config = { flashEnabled=true, giantEnabled=false, zeroGravityEnabled=false,
              alignCameraEnabled=false, triggerValue=0.91, apProtEnabled=false, brainrotEnabled=false, keybinds = Config.keybinds }
   saveConfig()
   sliderValue = 0.91
   triggerDisplay.Text = "91%"
   TriggerLabel.Text = "TRIGGER: 91%"
   _G.brainrotEnabled = false
   refreshTransparency(false)
   brainrotCore.enabled = false
   print("âœ… Config reset!")
end)

SettingsBtn.MouseButton1Click:Connect(function()
   SettingsPanel.Visible = not SettingsPanel.Visible
   TriggerLabel.Text = string.format("TRIGGER: %.1f%%", sliderValue * 100)
end)

-- ==================== FPS + PING ====================
local lastFPS, frameCount, lastTime = 0, 0, tick()
RunService.RenderStepped:Connect(function()
   frameCount += 1
   if tick() - lastTime >= 1 then
       lastFPS = frameCount; frameCount = 0; lastTime = tick()
   end
end)
RunService.Heartbeat:Connect(function()
   local ping = math.floor(player:GetNetworkPing() * 1000)
   StatsLabel.Text = string.format("FPS: %02d  PING: %03dms", lastFPS, ping)
end)

-- ==================== ZERO GRAVITY ====================
local GRAVITY_MULTIPLIER = 0.15
local originalGravity = workspace.Gravity
local counterForce = (1 - GRAVITY_MULTIPLIER) * originalGravity * 0.65
local zeroGravityConnection = nil

local function applyLowGravity()
   if not _G.zeroGravityEnabled then return end
   local character = player.Character
   if not character then return end
   local root = character:FindFirstChild("HumanoidRootPart")
   if not root then return end
   local velocity = root.AssemblyLinearVelocity
   root.AssemblyLinearVelocity = Vector3.new(velocity.X, velocity.Y + counterForce * 0.016, velocity.Z)
end

function startZeroGravity()
   if zeroGravityConnection then zeroGravityConnection:Disconnect() end
   zeroGravityConnection = RunService.Heartbeat:Connect(applyLowGravity)
end

function stopZeroGravity()
   if zeroGravityConnection then zeroGravityConnection:Disconnect(); zeroGravityConnection = nil end
end

if _G.zeroGravityEnabled then startZeroGravity() end

player.CharacterAdded:Connect(function()
   task.wait(0.8)
   if _G.zeroGravityEnabled then startZeroGravity() end
end)


-- ==================== TRIGGER SYSTEM ====================
local manualOverride = true
local triggerBump = false
local activeTriggers = {}

RunService.Heartbeat:Connect(function()
   if not manualOverride then
       sliderValue = triggerBump and 0.925 or 0.91
   end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
   if not _G.flashEnabled and not _G.giantEnabled then return end
   if activeTriggers[prompt] then return end
   activeTriggers[prompt] = true
   local startTime = os.clock()
   local fired = false
   StealFill.Size = UDim2.new(0, 0, 1, 0)

   local connection
   connection = RunService.PreRender:Connect(function()
       if not prompt or not prompt.Parent then
           connection:Disconnect(); activeTriggers[prompt] = nil; return
       end
       local progress = math.clamp((os.clock() - startTime) / prompt.HoldDuration, 0, 1)
       StealFill.Size = UDim2.new(progress, 0, 1, 0)

       if not fired and progress >= sliderValue then
           fired = true
           connection:Disconnect()
           activeTriggers[prompt] = nil
           triggerBump = not triggerBump

           local char = player.Character
           if not char then return end
           local backpack = player:FindFirstChild("Backpack")

           if _G.flashEnabled then
               local flash = char:FindFirstChild("Flash Teleport") or (backpack and backpack:FindFirstChild("Flash Teleport"))
               if flash then flash.Parent = char; task.spawn(function() flash:Activate(); task.wait(0.08) end) end
           end
           if _G.giantEnabled then
               local giant = char:FindFirstChild("Giant Potion") or (backpack and backpack:FindFirstChild("Giant Potion"))
               if giant then giant.Parent = char; task.spawn(function() giant:Activate() end) end
           end

           task.delay(0.25, function()
               TweenService:Create(StealFill, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {Size = UDim2.new(0,0,1,0)}):Play()
           end)
       end
   end)

   prompt.PromptButtonHoldEnded:Connect(function()
       if not fired then
           connection:Disconnect(); activeTriggers[prompt] = nil
           TweenService:Create(StealFill, TweenInfo.new(0.3), {Size = UDim2.new(0,0,1,0)}):Play()
       end
   end)
end)

-- ==================== KICK STEAL ====================
local STEAL_KEYWORD = "you stole"
local STEAL_KICK_MSG = "Auto Kicked - Post your steal in discord.gg/noxhub"

local function hasStealText(text)
   return typeof(text) == "string" and string.find(string.lower(text), STEAL_KEYWORD) ~= nil
end
local function kickOnSteal()
   pcall(function() player:Kick(STEAL_KICK_MSG) end)
end
local function watchObject(obj)
   if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
       if hasStealText(obj.Text) then kickOnSteal(); return end
       obj:GetPropertyChangedSignal("Text"):Connect(function()
           if hasStealText(obj.Text) then kickOnSteal() end
       end)
   end
end
local function setupGuiWatcher(gui)
   gui.DescendantAdded:Connect(function(desc) watchObject(desc) end)
end
local function scanAll(parent)
   for _, obj in ipairs(parent:GetDescendants()) do watchObject(obj) end
end

for _, gui in ipairs(playerGui:GetChildren()) do setupGuiWatcher(gui) end
playerGui.ChildAdded:Connect(function(gui) setupGuiWatcher(gui); scanAll(gui) end)
scanAll(playerGui)

-- ==================== SERVER PANEL ====================
local ServerPanel = Instance.new("Frame")
ServerPanel.Name = "ServerPanel"
ServerPanel.Size = UDim2.new(0, 160, 0, 95)
ServerPanel.Position = UDim2.new(0, 20, 0, 20)
ServerPanel.BackgroundColor3 = Color3.fromRGB(15, 12, 41)
ServerPanel.BackgroundTransparency = 0.55
ServerPanel.BorderSizePixel = 0
ServerPanel.ZIndex = 4
ServerPanel.Parent = ScreenGui

Instance.new("UICorner", ServerPanel).CornerRadius = UDim.new(0, 14)

-- Ajouter gradient comme le Main panel
do
   local srvBgG = Instance.new("UIGradient")
   srvBgG.Color = ColorSequence.new(NOX_BG_KEYS); srvBgG.Rotation = 90; srvBgG.Parent = ServerPanel
   table.insert(allGradients, srvBgG)
end

local SrvStroke = addGradientToStroke(ServerPanel, 2.5)

-- Conteneur de flocons pour le ServerPanel
local serverSnowflakeContainer = Instance.new("Frame")
serverSnowflakeContainer.Name = "ServerSnowflakeContainer"
serverSnowflakeContainer.Size = UDim2.new(1, 0, 1, 0)
serverSnowflakeContainer.Position = UDim2.new(0, 0, 0, 0)
serverSnowflakeContainer.BackgroundTransparency = 1
serverSnowflakeContainer.BorderSizePixel = 0
serverSnowflakeContainer.ZIndex = 1
serverSnowflakeContainer.Parent = ServerPanel

-- Lancer les flocons pour le ServerPanel
startSnowfallLoopForPanel(serverSnowflakeContainer)

local SrvTitleBar = Instance.new("Frame")
SrvTitleBar.Size = UDim2.new(1, 0, 0, 36)
SrvTitleBar.BackgroundColor3 = Color3.fromRGB(15, 12, 41)
SrvTitleBar.BackgroundTransparency = 1
SrvTitleBar.BorderSizePixel = 0
SrvTitleBar.ZIndex = 2
SrvTitleBar.Parent = ServerPanel
Instance.new("UICorner", SrvTitleBar).CornerRadius = UDim.new(0, 14)

local SrvAccent = Instance.new("Frame")
SrvAccent.Size = UDim2.new(0.5, 0, 0, 2)
SrvAccent.Position = UDim2.new(0.25, 0, 0, 0)
SrvAccent.BackgroundColor3 = THEME.accent
SrvAccent.BorderSizePixel = 0
SrvAccent.ZIndex = 3
SrvAccent.Parent = SrvTitleBar
Instance.new("UICorner", SrvAccent).CornerRadius = UDim.new(1, 0)

local SrvTitleLabel = Instance.new("TextLabel")
SrvTitleLabel.Size = UDim2.new(1, -10, 1, 0)
SrvTitleLabel.Position = UDim2.new(0, 10, 0, 0)
SrvTitleLabel.BackgroundTransparency = 1
SrvTitleLabel.Text = "SERVER"
SrvTitleLabel.TextColor3 = THEME.white
SrvTitleLabel.Font = Enum.Font.GothamBold
SrvTitleLabel.TextSize = 11
SrvTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SrvTitleLabel.ZIndex = 2
SrvTitleLabel.Parent = SrvTitleBar

-- Server drag
local sDrag, sDragStart, sStartPos = false, nil, nil
SrvTitleBar.InputBegan:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
       sDrag = true; sDragStart = input.Position; sStartPos = ServerPanel.Position
   end
end)
UserInputService.InputChanged:Connect(function(input)
   if sDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
       local d = input.Position - sDragStart
       ServerPanel.Position = UDim2.new(sStartPos.X.Scale, sStartPos.X.Offset + d.X, sStartPos.Y.Scale, sStartPos.Y.Offset + d.Y)
   end
end)
UserInputService.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sDrag = false end
end)

local SrvContent = Instance.new("Frame")
SrvContent.Size = UDim2.new(1, -14, 1, -44)
SrvContent.Position = UDim2.new(0, 7, 0, 40)
SrvContent.BackgroundTransparency = 1
SrvContent.BorderSizePixel = 0
SrvContent.ZIndex = 2
SrvContent.Parent = ServerPanel

local function createServerBtn(yOff, txt, cb)
   local b = Instance.new("TextButton")
   b.Size = UDim2.new(1, 0, 0, 26)
   b.Position = UDim2.new(0, 0, 0, yOff)
   b.BackgroundColor3 = THEME.btnOff
   b.AutoButtonColor = false
   b.Text = txt
   b.TextColor3 = THEME.subtext
   b.Font = Enum.Font.GothamBold
   b.TextSize = 10
   b.BorderSizePixel = 0
   b.ZIndex = 2
   b.Parent = SrvContent
   Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
   local s = Instance.new("UIStroke"); s.Thickness = 1; s.Color = THEME.stroke; s.Parent = b
   b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnHover, TextColor3 = THEME.white}):Play() end)
   b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = THEME.btnOff, TextColor3 = THEME.subtext}):Play() end)
   b.MouseButton1Click:Connect(cb)
end

createServerBtn(0,  "REJOIN",    function() TeleportService:Teleport(game.PlaceId, player) end)
createServerBtn(32, "KICK SELF", function() player:Kick("You have been kicked from the game.") end)

-- ==================== INIT ====================
print("âœ… NOX FLASH TP V3 COMPLETE - NOUVELLE INTERFACE CHARGÃ‰E")
print("âœ… FUSION: FLASH TP + GIANT + GRAVITY + STEAL TRACKER + BRAINROT 75%")
print("âœ… AP PROTECTION SYSTEM - BALLOON + RAGDOLL")
print("âœ… AP SPAM BUTTON - TINY + ROCKET + BALLOON")
print("âœ… BRAINROT TOGGLE - 75% TRANSPARENCY")
print("âœ… SERVER PANEL CHARGÃ‰")
print("âœ… ALIGN TAPIS V2 - CARPET + TP + FLASH + CAMERA ANGLE (-180 ou 0)")
print("âœ… FIX: FLASH TELEPORT ACTIVATION CORRIGÃ‰E - DÃ©lai 0.2s + vÃ©rification Ã©quipement")
print("â„ï¸  SNOWFLAKE FALLING ANIMATION - Flocons qui tombent du haut vers le bas!")
print("ðŸŽ® NOX Hub V3 MERGED - UI RedesignÃ©e (ThÃ¨me Violet/Sombre + CYAN BRAINROT + SNOWFLAKE FALLING FX)")
