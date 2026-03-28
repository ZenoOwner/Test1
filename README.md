local player = game.Players.LocalPlayer
local inputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local scaleFactor = 0.68

local function antiKickHumanoid()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local lastState = Enum.HumanoidStateType.RunningNoPhysics
    local lastGroundState = true -- Track if we were grounded last frame

    runService.Heartbeat:Connect(function()
        local isGrounded = humanoid.FloorMaterial ~= Enum.Material.Air
        
        -- Only force state change if we're in an unwanted state AND not jumping
        -- And only if we were grounded last frame (to preserve mid-air movement)
        if (humanoid:GetState() == Enum.HumanoidStateType.Freefall or 
            humanoid:GetState() == Enum.HumanoidStateType.Physics) and
            humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and
            lastGroundState then
            humanoid:ChangeState(lastState)
        end
        
        lastGroundState = isGrounded
    end)

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.RunningNoPhysics or 
           newState == Enum.HumanoidStateType.Running then
            lastState = newState
        end
        
        if newState == Enum.HumanoidStateType.Seated or 
           newState == Enum.HumanoidStateType.Dead then
            humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end)
end

local languageGui = Instance.new("ScreenGui", player.PlayerGui)
languageGui.Name = "LanguageSelection"
languageGui.ResetOnSpawn = false
languageGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


local container = Instance.new("Frame")
container.Size = UDim2.new(0, 280, 0, 240)
container.Position = UDim2.new(0.5, -140, 0.5, -120)
container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
container.ZIndex = 2
container.Parent = languageGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = container


local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SELECT LANGUAGE"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.ZIndex = 3
title.Parent = container


local languages = {
    {name = "English", code = "en", color = Color3.fromRGB(52, 152, 219)}, -- Blue
    {name = "Kurdish | Ú©ÙˆØ±Ø¯ÛŒ", code = "ku", color = Color3.fromRGB(231, 76, 60)}, -- Red
    {name = "Arabic | Ø¹Ø±Ø¨ÙŠ", code = "ar", color = Color3.fromRGB(50, 50, 50)} -- Darker blue
}

local buttonHeight = 50
local buttonSpacing = 10
local startY = 60

local function createMainGui(languageCode)
    
    local buttonTranslations = {
        en = {
            "Speed ðŸŽï¸", 
            "v.High Speed ðŸš€", 
            "Infinite JumpðŸ¦µ", 
            "Anti die ðŸ©¸", 
            "Anti Hit ðŸ‘‹ðŸ¼", 
            "Secret Server ðŸ‘‘",
            "Base Esp ðŸ”Ž",
            "Esp brainrotðŸ¦…", 
            "Super Jump ðŸ¦˜", 
            "Player esp ðŸ‘€",
            "Auto knock âš”ï¸",
            "Auto Steal ðŸ”¥"
        },
        ku = {
            "Ø®ÛŽØ±Ø§ÛŒÛŒ ðŸŽï¸", 
            "Ø®ÛŽØ±Ø§ÛŒ Ø²ÙˆØ± ðŸš€", 
            "Ø¨Ø§Ø²Ø¯Ø§Ù†ÛŽÚ©ÛŒ Ø¨Ø¦ Ú©ÙˆØªØ§ ðŸ¦µ", 
            "Ù†Ø§Ù…Ø±ÛŒØªðŸ©¸", 
            "Ø¯Ú˜Û• Ù„ÛŽØ¯Ø§Ù† ðŸ‘‹ðŸ¼", 
            "Ø³ÛŽØ±ÙÛ•Ø±ÛŒ Ø¨Û•Ù‚Û•ÙˆÛ•Øª ðŸ‘‘",
            "Ø¨ÛŒÙ†ÛŒÙ†ÛŒ Ú©Ø§Øª ðŸ”Ž",
            "Ø¨ÛŒÙ†ÛŒÙ†ÛŒ Ø¨Ø±Û•ÛŒÙ†Ø±ÙˆØªðŸ¦…", 
            "Ø¨Ø§Ø²Ø¯Ø§Ù†ÛŒ Ø¨Û•Ø±Ø² ðŸ¦˜", 
            "Ø¨ÛŒÙ†ÛŒÙ†ÛŒ ÛŒØ§Ø±ÛŒØ²Ø§Ù† ðŸ‘€",
            "Ù„ÛŽØ¯Ø§Ù† Ø®Û†Ú©Ø§Ø± âš”ï¸",
            "Ø¯Ø²ÛŒÙ†ÛŒ Ø®ÛŽØ±Ø§ ðŸ”¥"
        },
        ar = {
            "Ø§Ù„Ø³Ø±Ø¹Ø© ðŸŽï¸", 
            "Ø³Ø±Ø¹Ø© Ø¹Ø§Ù„ÙŠØ© ðŸš€", 
            "Ù‚ÙØ² Ù„Ø§ Ù†Ù‡Ø§Ø¦ÙŠ ðŸ¦µ", 
            "Ù…Ø§ ØªÙ…ÙˆØªðŸ©¸", 
            "Ù…Ø¶Ø§Ø¯ Ù„Ù„Ø¶Ø±Ø¨ ðŸ‘‹ðŸ¼", 
            "Ø³ÙŠØ±ÙØ±Ø§Øª Ù‚ÙˆÙŠØ© ðŸ‘‘",
            "ÙƒØ´Ù ÙˆÙ‚Øª ðŸ”Ž",
            "ÙƒØ´Ù Ø¨Ø±ÙŠÙ†Ø±ÙˆØªðŸ¦…", 
            "Ø§Ù„Ù‚ÙØ² Ø§Ù„Ø¹Ø§Ù„ÙŠ ðŸ¦˜", 
            "ÙƒØ´Ù Ø§Ù„Ù„Ø§Ø¹Ø¨ÙŠÙ† ðŸ‘€",
            "ØµÙØ¹ ØªÙ„Ù‚Ø§Ø¦ÙŠ âš”ï¸",
            "Ø³Ø±Ù‚Û• ØªÙ„Ù‚Ø§Ø¦ÛŒÛ•ðŸ”¥"
        }
    }

    local buttonNames = buttonTranslations[languageCode] or buttonTranslations.en

    
    local buttonCount = #buttonNames
    local buttonHeight = math.floor(50 * scaleFactor)
    local buttonSpacing = math.floor(10 * scaleFactor)
    local headerHeight = math.floor(50 * scaleFactor)
    local footerHeight = math.floor(20 * scaleFactor)
    local instructionHeight = math.floor(18 * scaleFactor)
    local versionHeight = math.floor(10 * scaleFactor)
    local bottomMargin = math.floor(6 * scaleFactor)
    local buttonsPerRow = 2
    local rows = math.ceil(buttonCount / buttonsPerRow)
    local buttonWidth = math.floor(150 * scaleFactor)

    -- Calculate menu dimensions
    local menuWidth = (buttonWidth * buttonsPerRow) + (buttonSpacing * (buttonsPerRow + 1))
    local menuHeight = headerHeight + (rows * buttonHeight) + ((rows - 1) * buttonSpacing) + 
                      instructionHeight + footerHeight + versionHeight + bottomMargin

    local shadowWidth = menuWidth + math.floor(6 * scaleFactor)
    local shadowHeight = menuHeight + math.floor(6 * scaleFactor)

    local mainGui = Instance.new("ScreenGui", player.PlayerGui)
    mainGui.Name = "kurdhubMenu"
    mainGui.ResetOnSpawn = false
    mainGui.Enabled = true
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local shadow = Instance.new("Frame", mainGui)
    shadow.Size = UDim2.new(0, shadowWidth, 0, shadowHeight)
    shadow.Position = UDim2.new(0.5, -shadowWidth // 2, 0.5, -shadowHeight // 2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    shadow.Visible = false -- Shadow starts hidden

    local shadowCorner = Instance.new("UICorner", shadow)
    shadowCorner.CornerRadius = UDim.new(0, math.floor(18 * scaleFactor))

    local menuFrame = Instance.new("Frame", mainGui)
    menuFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    menuFrame.Position = UDim2.new(0.5, -menuWidth // 2, 0.5, -menuHeight // 2)
    menuFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    menuFrame.BorderSizePixel = 0
    menuFrame.Active = true
    menuFrame.ZIndex = 1
    menuFrame.Visible = true -- Menu starts visible

    local menuCorner = Instance.new("UICorner", menuFrame)
    menuCorner.CornerRadius = UDim.new(0, math.floor(16 * scaleFactor))

    -- Create header
    local header = Instance.new("Frame", menuFrame)
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.ZIndex = 2

    local logo = Instance.new("ImageLabel", header)
    logo.Size = UDim2.new(0, math.floor(48 * scaleFactor), 0, math.floor(48 * scaleFactor))
    logo.Position = UDim2.new(0, math.floor(8 * scaleFactor), 0, math.floor(3 * scaleFactor))
    logo.BackgroundTransparency = 1
    logo.Image = ""
    logo.ZIndex = 2

    local logoCorner = Instance.new("UICorner", logo)
    logoCorner.CornerRadius = UDim.new(1, 0)

    local titleTexts = {
        en = "   Kurd hub",
        ku = "   Kurd hub",
        ar = "   Kurd hub"
    }
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, math.floor(-70 * scaleFactor), 1, 0)
    title.Position = UDim2.new(0, math.floor(64 * scaleFactor), 0, 0)
    title.BackgroundTransparency = 1
    title.Text = titleTexts[languageCode] or titleTexts.en
    title.Font = Enum.Font.GothamBold
    title.TextSize = 36 * scaleFactor
    title.TextColor3 = Color3.fromRGB(22, 22, 22)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 2

    local toggleButton = Instance.new("TextButton", mainGui)
    toggleButton.Size = UDim2.new(0, 40, 0, 40)
    toggleButton.Position = UDim2.new(0, 500, 0.5, -20)
    toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleButton.Text = "kurdhub"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 10
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BorderSizePixel = 0
    toggleButton.ZIndex = 4

    local toggleCorner = Instance.new("UICorner", toggleButton)
    toggleCorner.CornerRadius = UDim.new(0, 8)

    -- Dragging functionality for toggle button
    local dragging, dragInput, dragStart, startPos

    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = toggleButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    toggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    inputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle menu visibility
    toggleButton.MouseButton1Click:Connect(function()
        menuFrame.Visible = not menuFrame.Visible
        shadow.Visible = menuFrame.Visible
    end)

    -- Menu drag functionality
    do
        local menuDragging, menuDragInput, menuDragStart, menuStartPos
        
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                menuDragging = true
                menuDragStart = input.Position
                menuStartPos = menuFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        menuDragging = false
                    end
                end)
            end
        end)
        
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                menuDragInput = input
            end
        end)
        
        inputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and menuDragging then
                local delta = input.Position - menuDragStart
                menuFrame.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
                shadow.Position = UDim2.new(menuFrame.Position.X.Scale, menuFrame.Position.X.Offset - 4, menuFrame.Position.Y.Scale, menuFrame.Position.Y.Offset - 4)
            end
        end)
        
        menuFrame:GetPropertyChangedSignal("Position"):Connect(function()
            shadow.Position = UDim2.new(menuFrame.Position.X.Scale, menuFrame.Position.X.Offset - 4, menuFrame.Position.Y.Scale, menuFrame.Position.Y.Offset - 4)
        end)
    end

    local buttons = {}
    for index, buttonName in ipairs(buttonNames) do
        local row = math.ceil(index / buttonsPerRow) - 1
        local col = (index - 1) % buttonsPerRow
        
        local buttonPosX = buttonSpacing + (col * (buttonWidth + buttonSpacing))
        local buttonPosY = headerHeight + buttonSpacing + (row * (buttonHeight + buttonSpacing))
        
        local buttonFrame = Instance.new("Frame", menuFrame)
        buttonFrame.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
        buttonFrame.Position = UDim2.new(0, buttonPosX, 0, buttonPosY)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        buttonFrame.BorderSizePixel = 0
        buttonFrame.ZIndex = 2
        
        local buttonFrameCorner = Instance.new("UICorner", buttonFrame)
        buttonFrameCorner.CornerRadius = UDim.new(0, math.floor(16 * scaleFactor))
        
        local button = Instance.new("TextButton", buttonFrame)
        button.Size = UDim2.new(1, -math.floor(4 * scaleFactor), 1, -math.floor(4 * scaleFactor))  -- Reduced padding
        button.Position = UDim2.new(0, math.floor(2 * scaleFactor), 0, math.floor(2 * scaleFactor))  -- Reduced padding
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = buttonName
        button.Font = Enum.Font.GothamBlack
        button.TextSize = 20 * scaleFactor  -- Slightly larger text
        button.TextColor3 = Color3.fromRGB(26, 26, 26)
        button.BorderSizePixel = 0
        button.AutoButtonColor = true
        button.ZIndex = 3
        button.TextWrapped = true  -- Ensure text wraps if needed
        
        local buttonCorner = Instance.new("UICorner", button)
        buttonCorner.CornerRadius = UDim.new(0, math.floor(12 * scaleFactor))
        
        -- Make the button highlight area larger than visible area
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = button.BackgroundColor3 == Color3.fromRGB(0, 255, 0) and 
                                     Color3.fromRGB(0, 255, 0) or Color3.fromRGB(240, 240, 240)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = button.BackgroundColor3 == Color3.fromRGB(0, 255, 0) and 
                                     Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
        end)
        
        -- Make the entire frame clickable, not just the inner button
        buttonFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                button:SetAttribute("Pressed", true)
                button.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            end
        end)
        
        buttonFrame.InputEnded:Connect(function(input)
            if button:GetAttribute("Pressed") and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
                button:SetAttribute("Pressed", false)
                if button.BackgroundColor3 ~= Color3.fromRGB(0, 255, 0) then
                    button.BackgroundColor3 = Color3.new(1, 1, 1)
                end
                -- Trigger the button click
                button:Fire("MouseButton1Click")
            end
        end)
        
        buttons[index] = button
    end

    -- Speed Boost System
-- Speed Boost System (Button 1)
local speedBoostEnabled = false
local desiredSpeed = 50
local defaultSpeed = 34

-- Function to apply speed to humanoid
local function applySpeed(humanoid)
    if not humanoid then return end
    humanoid.WalkSpeed = desiredSpeed
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if speedBoostEnabled and humanoid.WalkSpeed ~= desiredSpeed then
            humanoid.WalkSpeed = desiredSpeed
        end
    end)
end

-- Function to reset speed
local function resetSpeed(humanoid)
    if not humanoid then return end
    humanoid.WalkSpeed = defaultSpeed
end

-- Speed toggle logic
buttons[1].MouseButton1Click:Connect(function()
    speedBoostEnabled = not speedBoostEnabled

    if speedBoostEnabled then
        buttons[1].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        antiKickHumanoid()
        buttons[1].Text = (languageCode == "en" and "Speed: ON") or 
                          (languageCode == "ku" and "Ø®ÛŽØ±Ø§ÛŒÛŒ: Ú†Ø§Ù„Ø§Ú©Û•") or 
                          "Ø§Ù„Ø³Ø±Ø¹Ø©: ØªØ´ØºÙŠÙ„"
    else
        buttons[1].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        buttons[1].Text = (languageCode == "en" and "Speed: OFF") or 
                          (languageCode == "ku" and "Ø®ÛŽØ±Ø§ÛŒÛŒ: Ù†Ø§Ú†Ø§Ù„Ø§Ú©Û•") or 
                          "Ø§Ù„Ø³Ø±Ø¹Ø©: Ø¥ÙŠÙ‚Ø§Ù"
    end

    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if speedBoostEnabled then
                applySpeed(humanoid)
            else
                resetSpeed(humanoid)
            end
        end
    end
end)

-- Speed persistence
game:GetService("RunService").Heartbeat:Connect(function()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if speedBoostEnabled and humanoid.WalkSpeed ~= desiredSpeed then
                humanoid.WalkSpeed = desiredSpeed
            elseif not speedBoostEnabled and humanoid.WalkSpeed ~= defaultSpeed then
                humanoid.WalkSpeed = defaultSpeed
            end
        end
    end
end)

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if speedBoostEnabled then
        applySpeed(humanoid)
    else
        resetSpeed(humanoid)
    end
end)


    -- Get All Tools Button (Button 2)
buttons[2].MouseButton1Click:Connect(function()
    -- Check if button 4 ("You do not die") is ON (green)
    if buttons[4].BackgroundColor3 ~= Color3.fromRGB(0, 255, 0) then
        -- Show notification if button 4 is OFF
        game.StarterGui:SetCore("SendNotification", {
            Title = "Warning",
            Text = "Please enable 'Anti DieðŸ©¸' first!",
            Duration = 5,
        })
    else
        -- If button 4 is ON, load the speed script
        loadstring(game:HttpGet("https://ninja68.serv00.net/krdNINJA123oki/speed"))()
    end
end)


local infiniteJumpEnabled = false
local infiniteJumpConnection = nil
local initialJumpSetupDone = false

local function buyToolIfNotOwned(toolName)
    local backpack = player:WaitForChild("Backpack")
    if not backpack:FindFirstChild(toolName) then
        local args = {toolName}
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/CoinsShopService/RequestBuy"):InvokeServer(unpack(args))
        end)
    end
end

local function unequipAllTools()
    local character = player.Character
    if not character then return end

    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = player.Backpack
        end
    end
end

local function equipTool(toolName)
    local backpack = player:WaitForChild("Backpack")
    local tool = backpack:FindFirstChild(toolName)
    if tool then
        tool.Parent = player.Character
        return true
    end
    return false
end

buttons[3].MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled

    buttons[3].BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)

    if infiniteJumpEnabled then
        antiKickHumanoid()

        if not initialJumpSetupDone then
            initialJumpSetupDone = true
            task.spawn(function()
                buyToolIfNotOwned("Speed Coil")
                task.wait(0.2)

                -- Attempt to equip up to 3 times
                for i = 1, 3 do
                    if equipTool("Speed Coil") then break end
                    task.wait(0.15)
                end

                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end

        if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
        infiniteJumpConnection = inputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    else
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
    end
end)




local godModeEnabled = false
local godModeConnections = {}
local godModeCharacterConn = nil

local function clearGodMode()
    for _, conns in pairs(godModeConnections) do
        for _, conn in ipairs(conns) do
            conn:Disconnect()
        end
    end
    godModeConnections = {}

    if godModeCharacterConn then
        godModeCharacterConn:Disconnect()
        godModeCharacterConn = nil
    end
end

local function setupGodMode(character)
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 3)
    end
    if not humanoid then return end

    local conns = {}

    table.insert(conns, humanoid.HealthChanged:Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end))

    table.insert(conns, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end))

    -- Initial heal (only once)
    humanoid.Health = humanoid.MaxHealth

    godModeConnections[character] = conns
end

buttons[4].MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    buttons[4].BackgroundColor3 = godModeEnabled and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)

    clearGodMode()

    if godModeEnabled then
        -- Setup for current character
        if player.Character then
            setupGodMode(player.Character)
        end

        -- Setup once for future spawns
        godModeCharacterConn = player.CharacterAdded:Connect(function(char)
            setupGodMode(char)
        end)
    end
end)




buttons[5].MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://ninja68.serv00.net/krdNINJA123oki/Hi"))()
end)

buttons[6].MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://ninja67.serv00.net/Brainrot/pet"))()
end)
    -- Base ESP Logic
    local baseEspInstances = {}
    local espThread = nil
    local baseEspEnabled = false
    local ESP_CONFIG = {
        MAX_DISTANCE = 1000,
        UPDATE_INTERVAL = 0.5,
        BASE_SIZE = UDim2.new(0, 180, 0, 40),
        OFFSET = Vector3.new(0, 5, 0),
        COLORS = {
            yourPlot = Color3.fromRGB(0, 255, 0),
            locked = Color3.fromRGB(255, 255, 0),
            unlocked = Color3.fromRGB(255, 50, 50)
        }
    }

    local function findPlayerPlot()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return nil end
        
        for _, plot in plotsFolder:GetChildren() do
            local yourBase = plot:FindFirstChild("YourBase", true)
            if yourBase and yourBase:IsA("BoolValue") and yourBase.Value then
                return plot.Name
            end
        end
        return nil
    end

    local function createBaseESP(plot, mainPart)
        if baseEspInstances[plot.Name] then
            baseEspInstances[plot.Name]:Destroy()
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PlotESP_" .. plot.Name
        billboard.Size = ESP_CONFIG.BASE_SIZE
        billboard.StudsOffset = ESP_CONFIG.OFFSET
        billboard.AlwaysOnTop = true
        billboard.Adornee = mainPart
        billboard.MaxDistance = ESP_CONFIG.MAX_DISTANCE
        billboard.Parent = plot

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.8
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame

        frame.Parent = billboard
        baseEspInstances[plot.Name] = billboard

        return billboard
    end

    local function updateBaseESP()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return end
        
        local playerPlot = findPlayerPlot()

        for _, plot in plotsFolder:GetChildren() do
            local purchases = plot:FindFirstChild("Purchases")
            local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
            local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
            local billboardGui = mainPart and mainPart:FindFirstChild("BillboardGui")
            local timeLabel = billboardGui and billboardGui:FindFirstChild("RemainingTime")

            if timeLabel and mainPart then
                local billboard = baseEspInstances[plot.Name] or createBaseESP(plot, mainPart)
                local frame = billboard:FindFirstChild("Frame")
                local label = frame and frame:FindFirstChild("Label")
                local isUnlocked = (timeLabel.Text == "0s")
                
                if label then
                    label.Text = isUnlocked and "Unlocked" or ("" .. timeLabel.Text)
                    if plot.Name == playerPlot then
                        label.TextColor3 = ESP_CONFIG.COLORS.yourPlot
                    elseif isUnlocked then
                        label.TextColor3 = ESP_CONFIG.COLORS.unlocked
                    else
                        label.TextColor3 = ESP_CONFIG.COLORS.locked
                    end
                end

                local camera = workspace.CurrentCamera
                if camera and billboard.Adornee then
                    local distance = (camera.CFrame.Position - billboard.Adornee.Position).Magnitude
                    local scale = math.clamp(1 - (distance / ESP_CONFIG.MAX_DISTANCE), 0.6, 1.2)
                    billboard.Size = UDim2.new(0, ESP_CONFIG.BASE_SIZE.X.Offset * scale, 0, ESP_CONFIG.BASE_SIZE.Y.Offset * scale)
                end
            elseif baseEspInstances[plot.Name] then
                baseEspInstances[plot.Name]:Destroy()
                baseEspInstances[plot.Name] = nil
            end
        end
    end

    local function clearBaseESP()
        for _, instance in pairs(baseEspInstances) do
            instance:Destroy()
        end
        baseEspInstances = {}
    end

    -- Modified button 7 functionality (previously "Time", now "Base ESP")
    buttons[7].MouseButton1Click:Connect(function()
        baseEspEnabled = not baseEspEnabled
        
        if baseEspEnabled then
            buttons[7].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            if espThread then
                espThread:Disconnect()
            end
            espThread = runService.RenderStepped:Connect(function()
                updateBaseESP()
            end)
        else
            buttons[7].BackgroundColor3 = Color3.new(1, 1, 1)
            if espThread then
                espThread:Disconnect()
                espThread = nil
            end
            clearBaseESP()
        end
    end)

-- ðŸŽ¯ ESP Marker Toggle (Multi-Language)
local rainbowEnabled = false
local espMarkers = {}

local TargetPets = {
    "Los Tralaleritos", "La Vacca Saturno Saturnita", "Graipuss Medussi",
    "La Grande Combinasion", "Garama and Madundung", "Sammyni Spyderini",
    "Pot Hotspot", "Chimpanzini Spiderini", "Gattatino Neonino",
    "Las Tralaleritas", "Nuclearo Dinossauro", "Las Vaquitas Saturnitas",
    "Chicleteira Bicicleteira", "Los Combinasionas", "Dragon Cannelloni",
    "Agarrini la Palini", "Trenostruzzo Turbo 3000", "Unclito Samito",
    "Odin Din Din Dun", "Tralalero Tralala", "Matteo"
}

-- Language-specific button texts
local ButtonTexts = {
    en = { on = "Esp brainrotðŸ¦…", off = "Esp brainrotðŸ¦…", default = "Esp brainrotðŸ¦…" },
    ku = { on = "â€ŽØ¨ÛŒÙ†ÛŒÙ†ÛŒ Ø¨Ø±Û•ÛŒÙ†Ø±ÙˆØªðŸ¦…", off = "â€ŽØ¨ÛŒÙ†ÛŒÙ†ÛŒ Ø¨Ø±Û•ÛŒÙ†Ø±ÙˆØªðŸ¦…", default = "Ø¨ÛŒÙ†ÛŒÙ†ÛŒ Ø¨Ø±Û•ÛŒÙ†Ø±ÙˆØªðŸ¦…" },
    ar = { on = "â€ŽÙƒØ´Ù Ø¨Ø±ÙŠÙ†Ø±ÙˆØªðŸ¦…", off = "â€ŽÙƒØ´Ù Ø¨Ø±ÙŠÙ†Ø±ÙˆØªðŸ¦…", default = "â€ŽÙƒØ´Ù Ø¨Ø±ÙŠÙ†Ø±ÙˆØªðŸ¦…" }
}

-- Add a BillboardGui with ðŸŽ¯ to the pet
local function addTargetMarker(pet)
    if pet:FindFirstChild("ðŸŽ¯ESP") then return end

    local root = pet:FindFirstChildWhichIsA("HumanoidRootPart") or pet:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ðŸŽ¯ESP"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 30, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = pet

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "ðŸŽ¯"
    label.TextColor3 = Color3.new(1, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    table.insert(espMarkers, billboard)
end

-- Remove all ðŸŽ¯ markers
local function clearAllMarkers()
    for _, gui in ipairs(espMarkers) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    espMarkers = {}
end

-- Scan and apply once
local function scanOnceForTargets()
    for _, pet in ipairs(workspace:GetDescendants()) do
        if pet:IsA("Model") and not pet:FindFirstChild("ðŸŽ¯ESP") then
            for _, target in ipairs(TargetPets) do
                if string.find(pet.Name:lower(), target:lower()) then
                    addTargetMarker(pet)
                    break
                end
            end
        end
    end
end

-- Button click logic
buttons[8].MouseButton1Click:Connect(function()
    rainbowEnabled = not rainbowEnabled

    local currentLang = "en"
    if YourLanguageSystem and YourLanguageSystem.currentLanguage then
        currentLang = YourLanguageSystem.currentLanguage
    end

    if rainbowEnabled then
        buttons[8].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        buttons[8].Text = ButtonTexts[currentLang].on
        scanOnceForTargets()
    else
        buttons[8].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        buttons[8].Text = ButtonTexts[currentLang].off
        clearAllMarkers()
    end
end)

-- Init button text
local function initButton()
    local currentLang = "en"
    if YourLanguageSystem and YourLanguageSystem.currentLanguage then
        currentLang = YourLanguageSystem.currentLanguage
    end
    buttons[8].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    buttons[8].Text = ButtonTexts[currentLang].default
end

initButton()

local superJumpEnabled = false
local jumpPowerConnection = nil
local characterConnection = nil

buttons[9].MouseButton1Click:Connect(function()
    superJumpEnabled = not superJumpEnabled

    buttons[9].BackgroundColor3 = superJumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)

    local function applyJumpPower(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = superJumpEnabled and 110 or 50 -- 110 = high but safe
            humanoid.AutoJumpEnabled = true
        end
    end

    -- Set immediately on current character
    if player.Character then
        applyJumpPower(player.Character)
    end

    -- On respawn
    if characterConnection then characterConnection:Disconnect() end
    characterConnection = player.CharacterAdded:Connect(applyJumpPower)

    -- Disable listener when OFF
    if not superJumpEnabled then
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
                humanoid.AutoJumpEnabled = true
            end
        end
    end
end)

local espEnabled = false
local espBoxes = {}

-- Function to create a simple box ESP
local function createSimpleEsp(character)
    if not character or espBoxes[character] then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Create a box for the entire character
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "SimpleESPBox"
    box.Adornee = rootPart
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = Vector3.new(4, 6, 4) -- Adjust size as needed
    box.Transparency = 0.4 -- 50% visible
    box.Color3 = Color3.fromRGB(0, 255, 0) -- Green color
    box.Parent = rootPart
    
    espBoxes[character] = box
end

-- Function to clear all ESP boxes
local function clearAllEsp()
    for character, box in pairs(espBoxes) do
        if box and box.Parent then
            box:Destroy()
        end
    end
    espBoxes = {}
end

-- Function to update ESP for all players
local function updateEsp()
    clearAllEsp()
    if not espEnabled then return end
    
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            createSimpleEsp(player.Character)
        end
    end
end

-- Button 10 click handler (ONLY place where ESP gets toggled)
buttons[10].MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    
    if espEnabled then
        buttons[10].BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green when on
        -- Only setup event listeners when first turned on
        game:GetService("Players").PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if espEnabled then -- Check if still enabled
                    createSimpleEsp(character)
                end
            end)
        end)
        
        game:GetService("Players").PlayerRemoving:Connect(function(player)
            if player.Character and espBoxes[player.Character] then
                espBoxes[player.Character]:Destroy()
                espBoxes[player.Character] = nil
            end
        end)
        
        updateEsp()
    else
        buttons[10].BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White when off
        clearAllEsp()
    end
end)



    buttons[11].MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://ninja68.serv00.net/krdNINJA123oki/Aura.txt", true))()
    end)

    buttons[12].MouseButton1Click:Connect(function()
        loadstring(game:HttpGet("https://ninja68.serv00.net/krdNINJA123oki/AutoSteal.txt", true))()
    end)
end

-- Sound effect
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://170765130"
clickSound.Volume = 0.5
clickSound.Parent = container

for i, lang in ipairs(languages) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, buttonHeight)
    button.Position = UDim2.new(0.1, 0, 0, startY + (i-1)*(buttonHeight + buttonSpacing))
    button.BackgroundColor3 = lang.color
    button.Text = lang.name
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.AutoButtonColor = false
    button.ZIndex = 3
    button.Parent = container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = 0.2
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0
    end)
    
    button.MouseButton1Click:Connect(function()
        -- Play click sound
        clickSound:Play()
        
        -- Small animation
        local originalSize = button.Size
        button.Size = UDim2.new(0.75, 0, 0, 45)
        wait(0.1)
        button.Size = originalSize
        
        -- Close menu and create main GUI
        wait(0.2)
        languageGui:Destroy()
        createMainGui(lang.code)
    end)
end
