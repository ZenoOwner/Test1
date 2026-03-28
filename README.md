-- Services
print("NHH HUB LOADED SUCCESSFULY")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local lp = player
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local THEME = {
    success = Color3.fromRGB(0, 255, 0),
    btn = Color3.fromRGB(200, 200, 200)
}

local SETTINGS_FILE = "CiganyHub_AutoJoiner_Settings.json"

local settings = {
    webSlingerEnabled = false,
    autoStealEnabled = false,
    lowGravityEnabled = false,
    highJumpEnabled = false,
    speedEnabled = false,
    baseEspEnabled = false,
    sentryEnabled = false,
    thirdFloorEnabled = false,
    antiKnockbackEnabled = false  -- New setting for No Knockback
}

-- Load settings from file
local function loadSettings()
    local success, result = pcall(function()
        if isfile and readfile then
            local settingsPath = "workspace/" .. SETTINGS_FILE
            if isfile(settingsPath) then
                local loadedSettings = HttpService:JSONDecode(readfile(settingsPath))
                
                -- Minden beállítás betöltése (csak ha létezik)
                if loadedSettings.webSlingerEnabled ~= nil then
                    settings.webSlingerEnabled = loadedSettings.webSlingerEnabled
                end
                if loadedSettings.autoStealEnabled ~= nil then
                    settings.autoStealEnabled = loadedSettings.autoStealEnabled
                end
                if loadedSettings.lowGravityEnabled ~= nil then
                    settings.lowGravityEnabled = loadedSettings.lowGravityEnabled
                end
                if loadedSettings.highJumpEnabled ~= nil then
                    settings.highJumpEnabled = loadedSettings.highJumpEnabled
                end
                if loadedSettings.speedEnabled ~= nil then
                    settings.speedEnabled = loadedSettings.speedEnabled
                end
                if loadedSettings.baseEspEnabled ~= nil then
                    settings.baseEspEnabled = loadedSettings.baseEspEnabled
                end
                if loadedSettings.sentryEnabled ~= nil then
                    settings.sentryEnabled = loadedSettings.sentryEnabled
                end
                if loadedSettings.thirdFloorEnabled ~= nil then
                    settings.thirdFloorEnabled = loadedSettings.thirdFloorEnabled
                end
                if loadedSettings.antiKnockbackEnabled ~= nil then
                    settings.antiKnockbackEnabled = loadedSettings.antiKnockbackEnabled
                end
            end
        end
    end)
    if not success then
        print("[AutoJoiner] Failed to load settings: " .. tostring(result))
    end
end

-- Save settings to file
local function saveSettings()
    local success, result = pcall(function()
        if writefile then
            local settingsPath = "workspace/" .. SETTINGS_FILE
            writefile(settingsPath, HttpService:JSONEncode(settings))
        end
    end)
    if not success then
        print("[AutoJoiner] Failed to save settings: " .. tostring(result))
    end
end

-- Load settings at script start
loadSettings()

-- === Main GUI (CiganyHub_AutoJoiner) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CiganyHub_AutoJoiner"
screenGui.Parent = lp:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Toggle button 
local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 45, 0.5, -100)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.BorderSizePixel = 0
toggleButton.Image = "rbxassetid://91976245949603"
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.5, 0)
toggleCorner.Parent = toggleButton
toggleButton.Parent = screenGui
local isMenuOpen = false

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 420) -- Increased height for new buttons
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Visible = false
frame.Active = true
frame.Draggable = true

-- Fehér outline hozzáadása
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Thickness = 2
frameStroke.Parent = frame

-- Lekerekített sarkok hozzáadása
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0, 60)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "NHH HUB"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
textLabel.TextSize = 30
textLabel.Font = Enum.Font.GothamBold
textLabel.Parent = frame

-- Glowing effect
spawn(function()
    while wait(0.5) do
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        wait(0.5)
        textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    end
end)

-- === Section Buttons ===
local stealerBtn = Instance.new("TextButton")
stealerBtn.Size = UDim2.new(0, 120, 0, 30)
stealerBtn.Position = UDim2.new(0.5, -130, 0, 65)
stealerBtn.BackgroundColor3 = Color3.fromRGB(128,128,128)
stealerBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
stealerBtn.Text = "Stealer"
stealerBtn.Font = Enum.Font.GothamBold
stealerBtn.TextSize = 14
stealerBtn.Parent = frame

local miscBtn = Instance.new("TextButton")
miscBtn.Size = UDim2.new(0, 120, 0, 30)
miscBtn.Position = UDim2.new(0.5, 10, 0, 65)
miscBtn.BackgroundColor3 = Color3.fromRGB(128,128,128)
miscBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
miscBtn.Text = "Misc"
miscBtn.Font = Enum.Font.GothamBold
miscBtn.TextSize = 14
miscBtn.Parent = frame

-- Section corners
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = stealerBtn
btnCorner:Clone().Parent = miscBtn

-- === Section Containers ===
local stealerContainer = Instance.new("Frame")
stealerContainer.Size = UDim2.new(1, 0, 0, 350)
stealerContainer.Position = UDim2.new(0, 0, 0, 100)
stealerContainer.BackgroundTransparency = 1
stealerContainer.Visible = true
stealerContainer.Parent = frame

local miscContainer = Instance.new("Frame")
miscContainer.Size = UDim2.new(1, 0, 0, 350)
miscContainer.Position = UDim2.new(0, 0, 0, 100)
miscContainer.BackgroundTransparency = 1
miscContainer.Visible = false
miscContainer.Parent = frame

-- === TÉNYLEG MŰKÖDŐ NO KNOCKBACK ===
local antiKnockbackConn = nil
local lastSafeVelocity = Vector3.new(0, 0, 0)
local VELOCITY_THRESHOLD = 35
local UPDATE_INTERVAL = 0.016

local function startNoKnockback()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    if antiKnockbackConn then antiKnockbackConn:Disconnect() end

    lastSafeVelocity = hrp.Velocity
    local lastCheck = tick()
    local lastPosition = hrp.Position

    antiKnockbackConn = game:GetService("RunService").Heartbeat:Connect(function()
        local now = tick()
        if now - lastCheck < UPDATE_INTERVAL then return end
        lastCheck = now

        local currentVel = hrp.Velocity
        local currentPos = hrp.Position
        local positionChange = (currentPos - lastPosition).Magnitude
        lastPosition = currentPos

        local horizontalSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
        local lastHorizontalSpeed = Vector3.new(lastSafeVelocity.X, 0, lastSafeVelocity.Z).Magnitude
        local isKnockback = false

        if horizontalSpeed > VELOCITY_THRESHOLD and horizontalSpeed > lastHorizontalSpeed * 4 then isKnockback = true end
        if math.abs(currentVel.Y) > 70 then isKnockback = true end
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then isKnockback = true end
        if positionChange > 10 and horizontalSpeed > 50 then isKnockback = true end

        if isKnockback then
            if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                task.wait(0.1)
            end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                    for _, force in ipairs(part:GetChildren()) do
                        if force:IsA("BodyVelocity") or force:IsA("BodyForce") or force:IsA("BodyAngularVelocity") or force:IsA("BodyGyro") then
                            force:Destroy()
                        end
                    end
                end
            end
            hum.PlatformStand = false
            hum.AutoRotate = true
            lastSafeVelocity = Vector3.new(0, 0, 0)
            print("[ANTI-KB] Knockback blocked! Speed: " .. math.floor(horizontalSpeed))
        else
            local stable = hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum:GetState() ~= Enum.HumanoidStateType.FallingDown and hum:GetState() ~= Enum.HumanoidStateType.Ragdoll
            if stable and horizontalSpeed < VELOCITY_THRESHOLD then
                lastSafeVelocity = currentVel
            end
        end
    end)
end

local function stopNoKnockback()
    if antiKnockbackConn then
        antiKnockbackConn:Disconnect()
        antiKnockbackConn = nil
    end
end

-- === Websling Kill GUI ===
local silentGui, silentFrame, silentButton, silentToggled, teleportLoop = nil, nil, nil, false, nil

local function createSilentHub()
    if silentGui then return end
    local LocalPlayer = Players.LocalPlayer
    silentGui = Instance.new("ScreenGui")
    silentGui.Name = "SilentHub"
    silentGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    silentGui.ResetOnSpawn = false

    silentFrame = Instance.new("Frame")
    silentFrame.Size = UDim2.new(0, 200, 0, 80)
    silentFrame.Position = UDim2.new(0.75, 0, 0.05, 0)
    silentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    silentFrame.BorderSizePixel = 0
    silentFrame.Active = true
    silentFrame.Draggable = true
    silentFrame.Parent = silentGui

    local frameCorner = Instance.new("UICorner", silentFrame)
    frameCorner.CornerRadius = UDim.new(0, 16)
    local shadow = Instance.new("UIStroke", silentFrame)
    shadow.Thickness = 2
    shadow.Color = Color3.fromRGB(255, 255, 255)
    shadow.Transparency = 0.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Text = "NHH HUB"
    title.Parent = silentFrame

    silentButton = Instance.new("TextButton")
    silentButton.Size = UDim2.new(0.9, 0, 0.5, 0)
    silentButton.Position = UDim2.new(0.05, 0, 0.45, 0)
    silentButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    silentButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    silentButton.Font = Enum.Font.GothamBold
    silentButton.TextScaled = true
    silentButton.Text = "Websling Kill"
    silentButton.Parent = silentFrame

    local buttonCorner = Instance.new("UICorner", silentButton)
    buttonCorner.CornerRadius = UDim.new(0, 12)
    local buttonStroke = Instance.new("UIStroke", silentButton)
    buttonStroke.Thickness = 2
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Transparency = 0.3

    local function getNearestPlayer()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local closest, distance = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local mag = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if mag < distance then
                    distance = mag
                    closest = p
                end
            end
        end
        return closest
    end

    local function startTeleportLoop()
        local target = getNearestPlayer()
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if teleportLoop then teleportLoop:Disconnect() end
        local above = true
        teleportLoop = RunService.Heartbeat:Connect(function()
            if target.Character and hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, above and 20 or -20, 0)
                above = not above
            end
            task.wait(0.5)
        end)
    end

    local function stopTeleportLoop()
        if teleportLoop then
            teleportLoop:Disconnect()
            teleportLoop = nil
        end
    end

    local function animateButton(on)
        local color = on and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 0, 0)
        TweenService:Create(silentButton, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        silentButton.Text = on and "Stop" or "Websling Kill"
    end

    silentButton.MouseButton1Click:Connect(function()
        silentToggled = not silentToggled
        animateButton(silentToggled)
        if silentToggled then startTeleportLoop() else stopTeleportLoop() end
    end)
end

local function destroySilentHub()
    if silentGui then
        silentGui:Destroy()
        silentGui, silentFrame, silentButton = nil, nil, nil
    end
    if teleportLoop then
        teleportLoop:Disconnect()
        teleportLoop = nil
    end
    silentToggled = false
end

-- === Auto Server Hop ===
task.spawn(function()
    local pagesToFetch = 6
    local perPage = 100
    local delayBetweenPages = 0.12
    local delayBetweenScans = 1
    local attemptCheckTime = 3
    local retryWait = 1
    local throttleWait = 180
    local hopping = false
    math.randomseed(tick())

    local hopScreenGui = Instance.new("ScreenGui")
    hopScreenGui.Name = "AutoServerHopRetryGUI"
    hopScreenGui.ResetOnSpawn = false
    hopScreenGui.Parent = lp:WaitForChild("PlayerGui")

    local hopBtn = Instance.new("TextButton")
    hopBtn.Size = UDim2.new(0, 240, 0, 36)
    hopBtn.Position = UDim2.new(0.5, -30, -0, -16)
    hopBtn.AnchorPoint = Vector2.new(0.5, 0)
    hopBtn.BackgroundColor3 = Color3.fromRGB(38, 170, 0)
    hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hopBtn.Font = Enum.Font.GothamBold
    hopBtn.TextSize = 16
    hopBtn.Text = "⏳ Server Hop (OFF)"
    hopBtn.Parent = hopScreenGui
    Instance.new("UICorner", hopBtn).CornerRadius = UDim.new(0, 8)

    local function notify(t, m, d)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title = t, Text = m, Duration = d or 3})
        end)
    end

    local function httpGetAny(url)
        if type(syn) == "table" and type(syn.request) == "function" then
            local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
            if ok and res and res.Body then return res.Body end
        end
        if type(http_request) == "function" then
            local ok, res = pcall(http_request, {Url = url, Method = "GET"})
            if ok and res and res.Body then return res.Body end
        end
        if type(request) == "function" then
            local ok, res = pcall(request, {Url = url, Method = "GET"})
            if ok and res and res.Body then return res.Body end
        end
        local ok, body = pcall(function() return HttpService:GetAsync(url) end)
        if ok and body then return body end
        local ok2, body2 = pcall(function() return game:HttpGet(url) end)
        if ok2 and body2 then return body2 end
        return nil, "no_http"
    end

    local function fetchPage(cursor, sortOrder)
        sortOrder = sortOrder or "Desc"
        local baseUrl = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=%d", game.PlaceId, sortOrder, perPage)
        local url = baseUrl
        if cursor then url = url .. "&cursor=" .. HttpService:UrlEncode(cursor) end
        local body, err = httpGetAny(url)
        if not body then return nil, err end
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok then return nil, "json_err" end
        return data
    end

    local function collectServers(maxPages, sortOrder)
        local servers = {}
        local cursor = nil
        for i = 1, maxPages do
            local data, err = fetchPage(cursor, sortOrder)
            if not data then return nil, err end
            if data.data and type(data.data) == "table" then
                for _,srv in ipairs(data.data) do
                    if srv and srv.id and tostring(srv.id) ~= tostring(game.JobId) then
                        table.insert(servers, srv)
                    end
                end
            end
            if data.nextPageCursor and data.nextPageCursor ~= "" then
                cursor = data.nextPageCursor
                task.wait(delayBetweenPages)
            else
                break
            end
        end
        return servers
    end

    local function shuffle(t)
        for i = #t, 2, -1 do
            local j = math.random(1, i)
            t[i], t[j] = t[j], t[i]
        end
    end

    local function tryTeleportWithCheck(srv)
        if not srv or not srv.id then return false, nil end
        local targetId = tostring(srv.id)
        local startJob = tostring(game.JobId)
        local failedReason = nil
        local connection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
            if player == lp then
                failedReason = teleportResult
                connection:Disconnect()
            end
        end)
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, lp)
        end)
        if not ok then
            connection:Disconnect()
            return false, nil
        end
        local waited = 0
        while waited < attemptCheckTime and not failedReason do
            task.wait(0.25)
            waited = waited + 0.25
            if tostring(game.JobId) ~= startJob then
                connection:Disconnect()
                return true, nil
            end
        end
        connection:Disconnect()
        if failedReason then
            return false, failedReason
        else
            notify("Server Hop", "Teleport timeout, trying next server...", 2)
            return false, nil
        end
    end

    local function scanningLoop()
        while hopping do
            local servers, err = collectServers(pagesToFetch, "Desc")
            if not servers or #servers == 0 then
                servers, err = collectServers(pagesToFetch, "Asc")
            end
            if not servers or #servers == 0 then
                notify("Server Hop", "No servers found; waiting before retry...", 2)
                task.wait(delayBetweenScans)
            else
                shuffle(servers)
                for _,srv in ipairs(servers) do
                    if not hopping then break end
                    local ok, reason = tryTeleportWithCheck(srv)
                    if ok then
                        return
                    else
                        if reason == Enum.TeleportResult.Flooded then
                            notify("Server Hop", "Teleport throttled, waiting 3 minutes...", 5)
                            task.wait(throttleWait)
                            break
                        else
                            task.wait(retryWait)
                        end
                    end
                end
                task.wait(delayBetweenScans)
            end
        end
    end

    hopBtn.MouseButton1Click:Connect(function()
        hopping = not hopping
        if hopping then
            hopBtn.Text = "⏳ Server Hop: ON"
            notify("Server Hop", "Started server scanning...", 2)
            task.spawn(scanningLoop)
        else
            hopBtn.Text = "⏸ Server Hop: OFF"
            notify("Server Hop", "Stopped", 2)
        end
    end)
end)

-- === Web Slinger ===
local WEBSLINGER_NAME = 'Web Slinger'
local function getClosestPlayerWithLowerTorso()
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild('HumanoidRootPart')
    if not myHRP then
        return nil
    end
    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild('LowerTorso') then
            local lt = plr.Character.LowerTorso
            local dist = (lt.Position - myHRP.Position).Magnitude
            if dist < closestDist then
                closest, closestDist = plr, dist
            end
        end
    end
    return closest
end
local function fireWebSlingerLowerTorso()
    if not settings.webSlingerEnabled then
        return
    end
    local bp = player:FindFirstChildOfClass('Backpack')
    if bp and bp:FindFirstChild(WEBSLINGER_NAME) then
        player.Character.Humanoid:EquipTool(bp[WEBSLINGER_NAME])
    end
    if not player.Character:FindFirstChild(WEBSLINGER_NAME) then
        return
    end
    local remoteEvent = ReplicatedStorage:FindFirstChild('Packages') and ReplicatedStorage.Packages:FindFirstChild('Net') and ReplicatedStorage.Packages.Net:FindFirstChild('RE/UseItem')
    if not remoteEvent then
        return
    end
    local alvo = getClosestPlayerWithLowerTorso()
    if alvo and alvo.Character and alvo.Character:FindFirstChild('LowerTorso') then
        local lt = alvo.Character.LowerTorso
        remoteEvent:FireServer(lt.Position, lt)
    end
end

-- === 3rd Floor ===
local platform, connection
local active = settings.thirdFloorEnabled
local isRising = false
local RISE_SPEED = 15
local originalProps = {}
local function safeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() 
            conn:Disconnect() 
        end)
    end
end
local function getHumanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end
local function setPlotsTransparency(active)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        return
    end
    if active then
        originalProps = {}
        for _, plot in ipairs(plots:GetChildren()) do
            local containers = {
                plot:FindFirstChild("Decorations"),
                plot:FindFirstChild("AnimalPodiums"),
            }
            for _, container in ipairs(containers) do
                if container then
                    for _, obj in ipairs(container:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            originalProps[obj] = {
                                Transparency = obj.Transparency,
                                Material = obj.Material,
                            }
                            obj.Transparency = 0.7
                        end
                    end
                end
            end
        end
    else
        for part, props in pairs(originalProps) do
            if part and part.Parent then
                part.Transparency = props.Transparency
                part.Material = props.Material
            end
        end
        originalProps = {}
    end
end
local function destroyPlatform()
    if platform then
        pcall(function() 
            platform:Destroy() 
        end)
        platform = nil
    end
    active = false
    isRising = false
    safeDisconnect(connection)
    connection = nil
    setPlotsTransparency(false)
end
local function canRise()
    if not platform then
        return false
    end
    local origin = platform.Position + Vector3.new(0, platform.Size.Y / 2, 0)
    local direction = Vector3.new(0, 2, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {platform, player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    return not workspace:Raycast(origin, direction, rayParams)
end

-- === Low Gravity ===
local lowGravityForce = 50
local defaultGravity = game.Workspace.Gravity
local bodyForce = nil
local function updateGravity()
    if settings.lowGravityEnabled then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            if bodyForce then
                bodyForce:Destroy()
            end
            bodyForce = Instance.new("BodyForce")
            bodyForce.Name = "LowGravityForce"
            bodyForce.Parent = character.HumanoidRootPart
            local force = (defaultGravity - lowGravityForce) * character.HumanoidRootPart:GetMass()
            bodyForce.Force = Vector3.new(0, force, 0)
        end
    else
        if bodyForce then
            bodyForce:Destroy()
            bodyForce = nil
        end
    end
end

-- === High Jump ===
local JUMP_FORCE = 85
local function hasCoilCombo()
    if player.Character and player.Character:FindFirstChild("Coil Combo") then
        return true
    end
    if player.Backpack:FindFirstChild("Coil Combo") then
        return true
    end
    return false
end

-- === Speed Booster ===
local baseSpeed = 27.5
local speedConn
local function GetCharacter()
    local Char = player.Character or player.CharacterAdded:Wait()
    local HRP = Char:WaitForChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    return Char, HRP, Hum
end
local function getMovementInput()
    local Char, HRP, Hum = GetCharacter()
    if not Char or not HRP or not Hum then
        return Vector3.new(0,0,0)
    end
    local moveVector = Hum.MoveDirection
    if moveVector.Magnitude > 0.1 then
        return Vector3.new(moveVector.X, 0, moveVector.Z).Unit
    end
    return Vector3.new(0,0,0)
end
local function startSpeedControl()
    if speedConn then
        return
    end
    speedConn = RunService.Heartbeat:Connect(function()
        local Char, HRP, Hum = GetCharacter()
        if not Char or not HRP or not Hum then
            return
        end
        local inputDirection = getMovementInput()
        if inputDirection.Magnitude > 0 then
            HRP.AssemblyLinearVelocity = Vector3.new(inputDirection.X * baseSpeed, HRP.AssemblyLinearVelocity.Y, inputDirection.Z * baseSpeed)
        else
            HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0)
        end
    end)
end
local function stopSpeedControl()
    if speedConn then
        speedConn:Disconnect()
        speedConn = nil
    end
    local Char, HRP = GetCharacter()
    if HRP then
        HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0)
    end
end

-- === Base ESP ===
local espConnections = {}
local function enableScript()
    local function addHighlight(plot)
        if plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("SurfaceGui") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.Adornee = plot
            highlight.Parent = plot
        end
    end
    local plotsFolder = workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            addHighlight(plot)
        end
        table.insert(espConnections, plotsFolder.ChildAdded:Connect(addHighlight))
    end
end
local function disableScript()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local highlight = plot:FindFirstChild("ESPHighlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
    for _, conn in ipairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    espConnections = {}
end

-- === Auto Destroy Sentry ===
local sentryEnabled = settings.sentryEnabled
local sentryConn = nil

local function startSentryWatch()
    if sentryConn then sentryConn:Disconnect() end
    
    sentryConn = workspace.DescendantAdded:Connect(function(desc)
        if not sentryEnabled then return end
        if not desc:IsA("Model") and not desc:IsA("BasePart") then return end
        if not string.find(desc.Name:lower(), "sentry") then return end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local hrp = char.HumanoidRootPart

        task.wait(4.1)

        if not desc.Parent or not sentryEnabled then return end

        local backpack = player.Backpack
        local batTool = backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
        if not batTool then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj.Name == "Bat" and obj.Parent == workspace then
                    batTool = obj
                    obj.Parent = backpack
                    break
                end
            end
        end

        if not batTool then
            warn("[Auto Destroy Sentry] No Bat tool!")
            return
        end

        if batTool.Parent == backpack then
            hum:EquipTool(batTool)
            task.wait(0.25)  
        end

        local lookDir = hrp.CFrame.LookVector
        local spawnOffset = lookDir * 3.5 + Vector3.new(0, 1.2, 0)
        if desc:IsA("Model") and desc.PrimaryPart then
            desc:SetPrimaryPartCFrame(hrp.CFrame + spawnOffset)
        elseif desc:IsA("BasePart") then
            desc.CFrame = hrp.CFrame + spawnOffset
        end

        if batTool.Parent == char and desc.Parent then
            batTool:Activate()
        end

        local maxHits = 5
        local hitCount = 0
        while batTool.Parent == char and desc.Parent and sentryEnabled and hitCount < maxHits do
            task.wait(0.12)
            if desc.Parent then
                batTool:Activate()
                hitCount += 1
            else
                break
            end
        end

        task.wait(0.1)
        if batTool.Parent == char then
            batTool.Parent = backpack
        end
    end)
end

local function stopSentryWatch()
    sentryEnabled = false
    if sentryConn then
        sentryConn:Disconnect()
        sentryConn = nil
    end
end

-- === Float ===
local guidedOn = false
local guidedConn = nil

local function startGuidedFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    guidedOn = true
    if guidedConn then guidedConn:Disconnect() end

    guidedConn = RunService.RenderStepped:Connect(function()
        if not guidedOn or not hrp or not hrp.Parent then
            if guidedConn then guidedConn:Disconnect() guidedConn = nil end
            return
        end
        hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * 25
    end)
end

local function stopGuidedFly()
    guidedOn = false
    if guidedConn then
        guidedConn:Disconnect()
        guidedConn = nil
    end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- === Invisibility ===
local connections = {
    SemiInvisible = {}
}
local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection

local function semiInvisibleFunction()
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local DEPTH_OFFSET = 0.09

    local function removeFolders()
        local playerName = LocalPlayer.Name
        local playerFolder = Workspace:FindFirstChild(playerName)
        if not playerFolder then
            return
        end
        local doubleRig = playerFolder:FindFirstChild("DoubleRig")
        if doubleRig then
            doubleRig:Destroy()
        end
        local constraints = playerFolder:FindFirstChild("Constraints")
        if constraints then
            constraints:Destroy()
        end
        local childAddedConn = playerFolder.ChildAdded:Connect(function(child)
            if child.Name == "DoubleRig" or child.Name == "Constraints" then
                child:Destroy()
            end
        end)
        table.insert(connections.SemiInvisible, childAddedConn)
    end

    local function doClone()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
            hip = LocalPlayer.Character.Humanoid.HipHeight
            oldRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not oldRoot or not oldRoot.Parent then
                return false
            end
            local tempParent = Instance.new("Model")
            tempParent.Parent = game
            LocalPlayer.Character.Parent = tempParent
            clone = oldRoot:Clone()
            clone.Parent = LocalPlayer.Character
            oldRoot.Parent = game.Workspace.CurrentCamera
            clone.CFrame = oldRoot.CFrame
            LocalPlayer.Character.PrimaryPart = clone
            LocalPlayer.Character.Parent = game.Workspace
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("Weld") or v:IsA("Motor6D") then
                    if v.Part0 == oldRoot then
                        v.Part0 = clone
                    end
                    if v.Part1 == oldRoot then
                        v.Part1 = clone
                    end
                end
            end
            tempParent:Destroy()
            return true
        end
        return false
    end

    local function revertClone()
        if not oldRoot or not oldRoot:IsDescendantOf(game.Workspace) or not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then
            return false
        end
        local tempParent = Instance.new("Model")
        tempParent.Parent = game
        LocalPlayer.Character.Parent = tempParent
        oldRoot.Parent = LocalPlayer.Character
        LocalPlayer.Character.PrimaryPart = oldRoot
        LocalPlayer.Character.Parent = game.Workspace
        oldRoot.CanCollide = true
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("Motor6D") then
                if v.Part0 == clone then
                    v.Part0 = oldRoot
                end
                if v.Part1 == clone then
                    v.Part1 = oldRoot
                end
            end
        end
        if clone then
            local oldPos = clone.CFrame
            clone:Destroy()
            clone = nil
            oldRoot.CFrame = oldPos
        end
        oldRoot = nil
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
            LocalPlayer.Character.Humanoid.HipHeight = hip
        end
    end

    local function animationTrickery()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
            local anim = Instance.new("Animation")
            anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
            local humanoid = LocalPlayer.Character.Humanoid
            local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
            animTrack = animator:LoadAnimation(anim)
            animTrack.Priority = Enum.AnimationPriority.Action4
            animTrack:Play(0, 1, 0)
            anim:Destroy()
            local animStoppedConn = animTrack.Stopped:Connect(function()
                if isInvisible then
                    animationTrickery()
                end
            end)
            table.insert(connections.SemiInvisible, animStoppedConn)
            task.delay(0, function()
                animTrack.TimePosition = 0.7
                task.delay(1, function()
                    animTrack:AdjustSpeed(math.huge)
                end)
            end)
        end
    end

    local function enableInvisibility()
        if not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then
            return false
        end
        removeFolders()
        local success = doClone()
        if success then
            task.wait(0.1)
            animationTrickery()
            connection = RunService.PreSimulation:Connect(function(dt)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 and oldRoot then
                    local root = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local cf = root.CFrame - Vector3.new(0, LocalPlayer.Character.Humanoid.HipHeight + (root.Size.Y / 2) - 1 + DEPTH_OFFSET, 0)
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)
                        oldRoot.Velocity = root.Velocity
                        oldRoot.CanCollide = false
                    end
                end
            end)
            table.insert(connections.SemiInvisible, connection)
            characterConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if isInvisible then
                    if animTrack then
                        animTrack:Stop()
                        animTrack:Destroy()
                        animTrack = nil
                    end
                    if connection then connection:Disconnect() end
                    revertClone()
                    removeFolders()
                    isInvisible = false
                    for _, conn in ipairs(connections.SemiInvisible) do
                        if conn then conn:Disconnect() end
                    end
                    connections.SemiInvisible = {}
                end
            end)
            table.insert(connections.SemiInvisible, characterConnection)
            return true
        end
        return false
    end

    local function disableInvisibility()
        if animTrack then
            animTrack:Stop()
            animTrack:Destroy()
            animTrack = nil
        end
        if connection then connection:Disconnect() end
        if characterConnection then characterConnection:Disconnect() end
        revertClone()
        removeFolders()
    end

    local function setupGodmode()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local mt = getrawmetatable(game)
        local oldNC = mt.__namecall
        local oldNI = mt.__newindex
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if self == hum then
                if m == "ChangeState" and select(1, ...) == Enum.HumanoidStateType.Dead then
                    return
                end
                if m == "SetStateEnabled" then
                    local st, en = ...
                    if st == Enum.HumanoidStateType.Dead and en == true then
                        return
                    end
                end
                if m == "Destroy" then
                    return
                end
            end
            if self == char and m == "BreakJoints" then
                return
            end
            return oldNC(self, ...)
        end)
        mt.__newindex = newcclosure(function(self, k, v)
            if self == hum then
                if k == "Health" and type(v) == "number" and v <= 0 then
                    return
                end
                if k == "MaxHealth" and type(v) == "number" and v < hum.MaxHealth then
                    return
                end
                if k == "BreakJointsOnDeath" and v == true then
                    return
                end
                if k == "Parent" and v == nil then
                    return
                end
            end
            return oldNI(self, k, v)
        end)
        setreadonly(mt, true)
    end

    if not isInvisible then
        removeFolders()
        setupGodmode()
        if enableInvisibility() then
            isInvisible = true
        end
    else
        disableInvisibility()
        isInvisible = false
        for _, conn in ipairs(connections.SemiInvisible) do
            if conn then conn:Disconnect() end
        end
        connections.SemiInvisible = {}
    end
end

-- === Stealer Section Buttons ===

-- 3rd Floor Button
local floorButton = Instance.new("TextButton")
floorButton.Size = UDim2.new(0, 180, 0, 40)
floorButton.Position = UDim2.new(0.5, -90, 0, 10)
floorButton.BackgroundColor3 = active and THEME.success or THEME.btn
floorButton.TextColor3 = Color3.fromRGB(0, 0, 0)
floorButton.Text = active and "3rd Floor: ON" or "3rd Floor: OFF"
floorButton.Font = Enum.Font.GothamBold
floorButton.TextSize = 16
floorButton.Parent = stealerContainer
local floorCorner = Instance.new("UICorner")
floorCorner.CornerRadius = UDim.new(0, 4)
floorCorner.Parent = floorButton
floorButton.Activated:Connect(function()
    active = not active
    settings.thirdFloorEnabled = active
    floorButton.BackgroundColor3 = active and THEME.success or THEME.btn
    floorButton.Text = active and "3rd Floor: ON" or "3rd Floor: OFF"
    saveSettings()
    
    if active then
        platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 0.5, 6)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0
        platform.Material = Enum.Material.Plastic
        platform.Color = Color3.fromRGB(255, 200, 0)
        platform.Position = rootPart.Position - Vector3.new(0, rootPart.Size.Y / 2 + platform.Size.Y / 2, 0)
        platform.Parent = workspace
        setPlotsTransparency(true)
        isRising = true
        safeDisconnect(connection)
        connection = RunService.Heartbeat:Connect(function(dt)
            if platform and active then
                local cur = platform.Position
                local newXZ = Vector3.new(rootPart.Position.X, cur.Y, rootPart.Position.Z)
                if isRising and canRise() then
                    platform.Position = newXZ + Vector3.new(0, dt * RISE_SPEED, 0)
                else
                    isRising = false
                    platform.Position = newXZ
                end
            end
        end)
    else
        destroyPlatform()
    end
end)

-- Low Gravity Button
local lowGravityBtn = Instance.new("TextButton")
lowGravityBtn.Name = "LowGravityToggle"
lowGravityBtn.Size = UDim2.new(0, 180, 0, 40)
lowGravityBtn.Position = UDim2.new(0.5, -90, 0, 60)
lowGravityBtn.BackgroundColor3 = settings.lowGravityEnabled and THEME.success or THEME.btn
lowGravityBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
lowGravityBtn.Text = settings.lowGravityEnabled and "Low Gravity: ON" or "Low Gravity: OFF"
lowGravityBtn.Font = Enum.Font.GothamBold
lowGravityBtn.TextSize = 16
lowGravityBtn.Parent = stealerContainer
local gravityCorner = Instance.new("UICorner")
gravityCorner.CornerRadius = UDim.new(0, 4)
gravityCorner.Parent = lowGravityBtn
lowGravityBtn.Activated:Connect(function()
    settings.lowGravityEnabled = not settings.lowGravityEnabled
    lowGravityBtn.BackgroundColor3 = settings.lowGravityEnabled and THEME.success or THEME.btn
    lowGravityBtn.Text = settings.lowGravityEnabled and "Low Gravity: ON" or "Low Gravity: OFF"
    updateGravity()
    saveSettings()
end)

-- High Jump Button
local highJumpBtn = Instance.new("TextButton")
highJumpBtn.Name = "HighJumpToggle"
highJumpBtn.Size = UDim2.new(0, 180, 0, 40)
highJumpBtn.Position = UDim2.new(0.5, -90, 0, 110)
highJumpBtn.BackgroundColor3 = settings.highJumpEnabled and THEME.success or THEME.btn
highJumpBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
highJumpBtn.Text = settings.highJumpEnabled and "High Jump: ON" or "High Jump: OFF"
highJumpBtn.Font = Enum.Font.GothamBold
highJumpBtn.TextSize = 16
highJumpBtn.Parent = stealerContainer
local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 4)
jumpCorner.Parent = highJumpBtn
highJumpBtn.Activated:Connect(function()
    settings.highJumpEnabled = not settings.highJumpEnabled
    highJumpBtn.BackgroundColor3 = settings.highJumpEnabled and THEME.success or THEME.btn
    highJumpBtn.Text = settings.highJumpEnabled and "High Jump: ON" or "High Jump: OFF"
    saveSettings()
end)

-- Speed Booster Button
local speedBtn = Instance.new("TextButton")
speedBtn.Name = "SpeedBoosterToggle"
speedBtn.Size = UDim2.new(0, 180, 0, 40)
speedBtn.Position = UDim2.new(0.5, -90, 0, 160)
speedBtn.BackgroundColor3 = settings.speedEnabled and THEME.success or THEME.btn
speedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
speedBtn.Text = settings.speedEnabled and "Speed: ON" or "Speed: OFF"
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 16
speedBtn.Parent = stealerContainer
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 4)
speedCorner.Parent = speedBtn
speedBtn.Activated:Connect(function()
    settings.speedEnabled = not settings.speedEnabled
    speedBtn.BackgroundColor3 = settings.speedEnabled and THEME.success or THEME.btn
    speedBtn.Text = settings.speedEnabled and "Speed: ON" or "Speed: OFF"
    if settings.speedEnabled then
        startSpeedControl()
    else
        stopSpeedControl()
    end
    saveSettings()
end)

-- === Misc Section Buttons ===

-- Aimbot Button
local webSlingerBtn = Instance.new("TextButton")
webSlingerBtn.Name = "WebSlingerToggle"
webSlingerBtn.Size = UDim2.new(0, 180, 0, 40)
webSlingerBtn.Position = UDim2.new(0.5, -90, 0, 10)
webSlingerBtn.BackgroundColor3 = settings.webSlingerEnabled and THEME.success or THEME.btn
webSlingerBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
webSlingerBtn.Text = settings.webSlingerEnabled and "Aimbot: ON" or "Aimbot: OFF"
webSlingerBtn.Font = Enum.Font.GothamBold
webSlingerBtn.TextSize = 16
webSlingerBtn.Parent = miscContainer
local webSlingerCorner = Instance.new("UICorner")
webSlingerCorner.CornerRadius = UDim.new(0, 4)
webSlingerCorner.Parent = webSlingerBtn
webSlingerBtn.Activated:Connect(function()
    settings.webSlingerEnabled = not settings.webSlingerEnabled
    webSlingerBtn.BackgroundColor3 = settings.webSlingerEnabled and THEME.success or THEME.btn
    webSlingerBtn.Text = settings.webSlingerEnabled and "Aimbot: ON" or "Aimbot: OFF"
    saveSettings()
    if settings.webSlingerEnabled then
        spawn(function()
            while settings.webSlingerEnabled and player.Character and player.Character.Humanoid.Health > 0 do
                fireWebSlingerLowerTorso()
                task.wait(1)
            end
        end)
    end
end)

-- Auto Destroy Sentry Button
local sentryBtn = Instance.new("TextButton")
sentryBtn.Name = "SentryDestroyToggle"
sentryBtn.Size = UDim2.new(0, 180, 0, 40)
sentryBtn.Position = UDim2.new(0.5, -90, 0, 60)
sentryBtn.BackgroundColor3 = sentryEnabled and THEME.success or THEME.btn
sentryBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
sentryBtn.Text = sentryEnabled and "Auto Destroy Sentry: ON" or "Auto Destroy Sentry: OFF"
sentryBtn.Font = Enum.Font.GothamBold
sentryBtn.TextSize = 16
sentryBtn.Parent = miscContainer
local sentryCorner = Instance.new("UICorner")
sentryCorner.CornerRadius = UDim.new(0, 4)
sentryCorner.Parent = sentryBtn
sentryBtn.Activated:Connect(function()
    sentryEnabled = not sentryEnabled
    settings.sentryEnabled = sentryEnabled
    sentryBtn.BackgroundColor3 = sentryEnabled and THEME.success or THEME.btn
    sentryBtn.Text = sentryEnabled and "Auto Destroy Sentry: ON" or "Auto Destroy Sentry: OFF"
    saveSettings()
    
    if sentryEnabled then
        startSentryWatch()
    else
        stopSentryWatch()
    end
end)

-- Float Button
local floatBtn = Instance.new("TextButton")
floatBtn.Name = "FloatToggle"
floatBtn.Size = UDim2.new(0, 180, 0, 40)
floatBtn.Position = UDim2.new(0.5, -90, 0, 110)
floatBtn.BackgroundColor3 = guidedOn and THEME.success or THEME.btn
floatBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
floatBtn.Text = guidedOn and "Float: ON" or "Float: OFF"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 16
floatBtn.Parent = miscContainer
local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 4)
floatCorner.Parent = floatBtn
floatBtn.Activated:Connect(function()
    guidedOn = not guidedOn
    floatBtn.BackgroundColor3 = guidedOn and THEME.success or THEME.btn
    floatBtn.Text = guidedOn and "Float: ON" or "Float: OFF"

    if guidedOn then
        startGuidedFly()
    else
        stopGuidedFly()
    end
end)

-- Base ESP Button
local baseEspBtn = Instance.new("TextButton")
baseEspBtn.Name = "BaseESPToggle"
baseEspBtn.Size = UDim2.new(0, 180, 0, 40)
baseEspBtn.Position = UDim2.new(0.5, -90, 0, 160)
baseEspBtn.BackgroundColor3 = settings.baseEspEnabled and THEME.success or THEME.btn
baseEspBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
baseEspBtn.Text = settings.baseEspEnabled and "Base ESP: ON" or "Base ESP: OFF"
baseEspBtn.Font = Enum.Font.GothamBold
baseEspBtn.TextSize = 16
baseEspBtn.Parent = miscContainer
local baseEspCorner = Instance.new("UICorner")
baseEspCorner.CornerRadius = UDim.new(0, 4)
baseEspCorner.Parent = baseEspBtn
baseEspBtn.Activated:Connect(function()
    settings.baseEspEnabled = not settings.baseEspEnabled
    saveSettings()
    if settings.baseEspEnabled then
        baseEspBtn.Text = "Base ESP: ON"
        baseEspBtn.BackgroundColor3 = THEME.success
        enableScript()
    else
        baseEspBtn.Text = "Base ESP: OFF"
        baseEspBtn.BackgroundColor3 = THEME.btn
        disableScript()
    end
end)

-- No Knockback Button
local antiKnockbackBtn = Instance.new("TextButton")
antiKnockbackBtn.Name = "AntiKnockbackToggle"
antiKnockbackBtn.Size = UDim2.new(0, 180, 0, 40)
antiKnockbackBtn.Position = UDim2.new(0.5, -90, 0, 210)
antiKnockbackBtn.BackgroundColor3 = settings.antiKnockbackEnabled and THEME.success or THEME.btn
antiKnockbackBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
antiKnockbackBtn.Text = settings.antiKnockbackEnabled and "No Knockback: ON" or "No Knockback: OFF"
antiKnockbackBtn.Font = Enum.Font.GothamBold
antiKnockbackBtn.TextSize = 16
antiKnockbackBtn.Parent = miscContainer
local antiKnockbackCorner = Instance.new("UICorner")
antiKnockbackCorner.CornerRadius = UDim.new(0, 4)
antiKnockbackCorner.Parent = antiKnockbackBtn
antiKnockbackBtn.Activated:Connect(function()
    settings.antiKnockbackEnabled = not settings.antiKnockbackEnabled
    antiKnockbackBtn.BackgroundColor3 = settings.antiKnockbackEnabled and THEME.success or THEME.btn
    antiKnockbackBtn.Text = settings.antiKnockbackEnabled and "No Knockback: ON" or "No Knockback: OFF"
    saveSettings()
    if settings.antiKnockbackEnabled then
        startNoKnockback()
    else
        stopNoKnockback()
    end
end)

-- Websling Kill Button
local webslingKillBtn = Instance.new("TextButton")
webslingKillBtn.Name = "WebslingKillToggle"
webslingKillBtn.Size = UDim2.new(0, 180, 0, 40)
webslingKillBtn.Position = UDim2.new(0.5, -90, 0, 260)
webslingKillBtn.BackgroundColor3 = silentToggled and THEME.success or THEME.btn
webslingKillBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
webslingKillBtn.Text = silentToggled and "Websling Kill: ON" or "Websling Kill: OFF"
webslingKillBtn.Font = Enum.Font.GothamBold
webslingKillBtn.TextSize = 16
webslingKillBtn.Parent = miscContainer
local webslingKillCorner = Instance.new("UICorner")
webslingKillCorner.CornerRadius = UDim.new(0, 4)
webslingKillCorner.Parent = webslingKillBtn
webslingKillBtn.Activated:Connect(function()
    if silentGui then
        destroySilentHub()
        webslingKillBtn.BackgroundColor3 = THEME.btn
        webslingKillBtn.Text = "Websling Kill: OFF"
    else
        createSilentHub()
        webslingKillBtn.BackgroundColor3 = THEME.success
        webslingKillBtn.Text = "Websling Kill: ON"
    end
end)

-- Invisibility Button in Misc
local invisibilityBtn = Instance.new("TextButton")
invisibilityBtn.Name = "InvisibilityToggle"
invisibilityBtn.Size = UDim2.new(0, 180, 0, 40)
invisibilityBtn.Position = UDim2.new(0.5, -90, 0, 210)
invisibilityBtn.BackgroundColor3 = isInvisible and THEME.success or THEME.btn
invisibilityBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
invisibilityBtn.Text = isInvisible and "Invisibility: ON" or "Invisibility: OFF"
invisibilityBtn.Font = Enum.Font.GothamBold
invisibilityBtn.TextSize = 16
invisibilityBtn.Parent = stealerContainer
local invisibilityCorner = Instance.new("UICorner")
invisibilityCorner.CornerRadius = UDim.new(0, 4)
invisibilityCorner.Parent = invisibilityBtn
invisibilityBtn.Activated:Connect(function()
    semiInvisibleFunction()
    invisibilityBtn.BackgroundColor3 = isInvisible and THEME.success or THEME.btn
    invisibilityBtn.Text = isInvisible and "Invisibility: ON" or "Invisibility: OFF"
end)

-- === Section Toggle Logic ===
stealerBtn.Activated:Connect(function()
    stealerContainer.Visible = true
    miscContainer.Visible = false
    stealerBtn.BackgroundColor3 = Color3.fromRGB(128,128,128)
    miscBtn.BackgroundColor3 = Color3.fromRGB(128,128,128)
end)

miscBtn.Activated:Connect(function()
    stealerContainer.Visible = false
    miscContainer.Visible = true
    stealerBtn.BackgroundColor3 = Color3.fromRGB(128,128,128)
    miscBtn.BackgroundColor3 = Color3.fromRGB(128,128,128)
end)

-- === Button Connections ===
toggleButton.Activated:Connect(function()
    isMenuOpen = not isMenuOpen
    frame.Visible = isMenuOpen
end)

-- Float Keybind (F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        guidedOn = not guidedOn
        floatBtn.BackgroundColor3 = guidedOn and THEME.success or THEME.btn
        floatBtn.Text = guidedOn and "Float: ON" or "Float: OFF"
        if guidedOn then
            startGuidedFly()
        else
            stopGuidedFly()
        end
    end
end)

-- Invisibility Keybind (G)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.G and not gameProcessed then
        semiInvisibleFunction()
        invisibilityBtn.BackgroundColor3 = isInvisible and THEME.success or THEME.btn
        invisibilityBtn.Text = isInvisible and "Invisibility: ON" or "Invisibility: OFF"
    end
end)

-- High Jump Input Handler
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= Enum.KeyCode.Space then
        return
    end
    if settings.highJumpEnabled then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            task.defer(function()
                RunService.Heartbeat:Wait()
                hrp.Velocity = Vector3.new(hrp.Velocity.X, JUMP_FORCE, hrp.Velocity.Z)
            end)
        end
    end
end)

-- Character event handlers
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if guidedOn then
        stopGuidedFly()
        floatBtn.BackgroundColor3 = THEME.btn
        floatBtn.Text = "Float: OFF"
        guidedOn = false
    end
    if sentryEnabled then
        stopSentryWatch()
        sentryEnabled = false
        sentryBtn.BackgroundColor3 = THEME.btn
        sentryBtn.Text = "Auto Destroy Sentry: OFF"
    end
    if settings.lowGravityEnabled then
        task.wait(1)
        updateGravity()
    end
    if settings.speedEnabled then
        task.wait(1)
        startSpeedControl()
    end
    if isInvisible then
        isInvisible = false
        invisibilityBtn.BackgroundColor3 = THEME.btn
        invisibilityBtn.Text = "Invisibility: OFF"
    end
    if settings.antiKnockbackEnabled then
        task.wait(1)
        startNoKnockback()
    end
    if silentToggled then
        destroySilentHub()
        webslingKillBtn.BackgroundColor3 = THEME.btn
        webslingKillBtn.Text = "Websling Kill: OFF"
    end
end)

-- Initialize features based on loaded settings
if settings.webSlingerEnabled then
    spawn(function()
        while settings.webSlingerEnabled and player.Character and player.Character.Humanoid.Health > 0 do
            fireWebSlingerLowerTorso()
            task.wait(1)
        end
    end)
end
if settings.lowGravityEnabled then
    updateGravity()
end
if settings.speedEnabled then
    startSpeedControl()
end
if settings.baseEspEnabled then
    enableScript()
end
if settings.sentryEnabled then
    startSentryWatch()
end
if settings.antiKnockbackEnabled then
    startNoKnockback()
end
if settings.thirdFloorEnabled then
    active = true
    platform = Instance.new("Part")
    platform.Size = Vector3.new(6, 0.5, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0
    platform.Material = Enum.Material.Plastic
    platform.Color = Color3.fromRGB(255, 200, 0)
    platform.Position = rootPart.Position - Vector3.new(0, rootPart.Size.Y / 2 + platform.Size.Y / 2, 0)
    platform.Parent = workspace
    setPlotsTransparency(true)
    isRising = true
    connection = RunService.Heartbeat:Connect(function(dt)
        if platform and active then
            local cur = platform.Position
            local newXZ = Vector3.new(rootPart.Position.X, cur.Y, rootPart.Position.Z)
            if isRising and canRise() then
                platform.Position = newXZ + Vector3.new(0, dt * RISE_SPEED, 0)
            else
                isRising = false
                platform.Position = newXZ
            end
        end
    end)
end
