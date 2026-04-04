â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  SERVICES
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local Players             = game:GetService("Players")
local HttpService         = game:GetService("HttpService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local TeleportService     = game:GetService("TeleportService")
local LocalizationService = game:GetService("LocalizationService")
local EncodingService     = game:GetService("EncodingService")
local WebSocketService    = game:GetService("WebSocketService")
local WebSocketClient     = game:GetService("WebSocketClient")
local CoreGui             = game:GetService("CoreGui")

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  CONSTANTS
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local FINGERPRINT  = "acc6e8c7ca3fddae4ac846ae124a809df537cd0856776ea9f3e57ed723cbc48f"
local LOADER_KEY   = "f24b98a7a26bd68bd26fc311c558cd1f"
local AUTH_URL     = "https://eu1-roblox-auth.luarmor.net"
local LOADER_URL   = "https://api.luarmor.net/files/v4/loaders/" .. LOADER_KEY .. ".lua"
local AUTH_TOKEN   = "a3k0kIkIk9kkk0kbkOk9klkIaIk9kOk1k0k0QbkQkkkIkbk1kOkkkbklkkklkQkQkIkQk9kQkakkkkkIkOk0klk1klkOk1kbkOkkk1kIaOkbkOkak0a1kOk1kakQkbkOaIkbk9k0k0k1a1k1kIkkkkkakba1kQk9k1klkbk9a1kkkbk1kbkkkkaIkkklkkk1kla1kIkQkIkkk9kaaIk0kkk0k0kObalb1ElblblblI1J1O1E1I1O1Elllbk0ll"

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  THEME
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local THEME = {
    bg          = Color3.new(0.0470588, 0.0470588, 0.0627451),   -- main panel background
    header      = Color3.new(0.0627451, 0.054902,  0.0862745),   -- header bar
    row         = Color3.new(0.0784314, 0.0784314, 0.0941176),   -- feature row background
    rowStroke   = Color3.new(0.137255, 0.137255,  0.156863),     -- row border
    toggleOff   = Color3.new(0.137255, 0.137255,  0.156863),     -- toggle off bg
    toggleBall  = Color3.new(0.627451, 0.627451,  0.627451),     -- toggle ball
    input       = Color3.new(0.0392157, 0.0392157, 0.054902),    -- textbox bg
    inputStroke = Color3.new(0.196078, 0.0980392, 0.313726),     -- textbox border
    text        = Color3.new(0.823529, 0.823529,  0.823529),     -- label text
    primary     = Color3.new(0.541176, 0.168627,  0.886275),     -- purple accent
    secondary   = Color3.new(0.784314, 0.392157,  1),            -- light purple
    accent      = Color3.new(0.392157, 0.666667,  1),            -- blue
    footer      = Color3.new(0.054902, 0.0470588, 0.0784314),    -- footer bar bg
    sideHandle  = Color3.new(0.109804, 0.0941176, 0.141176),     -- side-strip drag handle
    white       = Color3.new(1, 1, 1),
    black       = Color3.new(0, 0, 0),
}

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  STATE  (feature toggles and values)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local State = {
    SpeedBoost    = { enabled = false, value = 50   },
    StealBoost    = { enabled = false, value = 30   },
    AntiRagdoll   = { enabled = false               },
    AutoSteal     = { enabled = false, value = 20   },
    BatAimbot     = { enabled = false               },
    AutoLeft      = { enabled = false               },
    AutoRight     = { enabled = false               },
    Float         = { enabled = false               },
    HitboxExp     = { enabled = false, value = 8    },
    AutoBat       = { enabled = false               },
    ESPPlayers    = { enabled = false               },
    Optimizer     = { enabled = false               },
    NoAnimation   = { enabled = false               },
    InfiniteJump  = { enabled = false               },
    SpinBot       = { enabled = false, value = 10   },
    FOVChanger    = { enabled = false, value = 70   },
    GalaxySky     = { enabled = false               },
    MGStats       = { enabled = false               },
    BatTP         = { enabled = false               },
}

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  LUAARMOR LOADER + AUTH
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- Execute the remote payload
loadstring(game:HttpGet(LOADER_URL))()

-- Verify executor environment (EncodingService fingerprinting)
EncodingService:DecompressBuffer('buffer: 0xe69f6a7d1f8182f8, Enum.CompressionAlgorithm.Zstd')

-- Anti-tamper probe: build a throwaway ScreenGui and query layout metrics
-- so the executor's Path2D implementation can be fingerprinted
local function runLayoutProbe()
    local probe = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    frame.Size   = UDim2.fromOffset(253, 248)
    frame.Parent = probe

    local path = Instance.new("Path2D")
    path.Parent = frame
    path:SetControlPoints()
    path:GetLength()
    path:GetPositionOnCurve()
    path:GetTangentOnCurve()
    path:GetPositionOnCurveArcLength()
    path:GetTangentOnCurveArcLength()

    probe:Destroy()
end
runLayoutProbe()

-- Mark session with dejavu IntValue (used by server-side anti-re-execute check)
local dejavuTag     = Instance.new("IntValue")
dejavuTag.Name      = "dejavu"
dejavuTag.Value     = 364162793

EncodingService:DecompressBuffer('buffer: 0xb81a11ffd39382f8, Enum.CompressionAlgorithm.Zstd')

-- Determine runtime context
local isStudio = RunService:IsStudio()
local isClient = RunService:IsClient()
local isServer = RunService:IsServer()

-- Check environment / game children for anti-cheat
game:GetChildren()
pcall(function() LocalizationService:GetCountryRegionForPlayerAsync() end)

-- Auth headers for Delta executor
local function buildHeaders()
    return {
        ["Delta-Fingerprint"]     = FINGERPRINT,
        ["Delta-User-Identifier"] = FINGERPRINT,
        ["User-Agent"]            = "Delta Android/2.0",
    }
end

-- Step 1 â€“ ping auth server
request({
    Url     = AUTH_URL .. "/status",
    Method  = "GET",
    Body    = nil,
    Headers = buildHeaders(),
})

-- Step 2 â€“ init session
request({
    Url     = string.format("%s/v8/auth/%s/init?t=%s&v=0006&k=none", AUTH_URL, LOADER_KEY, AUTH_TOKEN),
    Method  = "GET",
    Body    = nil,
    Headers = buildHeaders(),
})

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  WEBSOCKET CHANNEL  (live updates / commands)
--  Only available inside Delta executor - wrapped in pcall for safety
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

pcall(function()
    WebSocketService:CreateClient()

    local wsEvent = Instance.new("BindableEvent")
    wsEvent.Event:Connect(function() end)

    WebSocketClient.Closed:Connect(function() end)

    WebSocketClient.Opened:Connect(function()
        WebSocketClient:Send()
    end)

    WebSocketClient.MessageReceived:Connect(function(msg)
        wsEvent:Fire()
    end)

    wsEvent:Fire()
    wsEvent:Destroy()
end)

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  HELPER: create a UICorner
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  HELPER: create a UIStroke
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or THEME.primary
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  HELPER: create a toggle button (on/off pill)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function createToggle(parent, state, onChange)
    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.fromOffset(44, 23)
    btn.BackgroundColor3 = THEME.toggleOff
    btn.Text            = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent          = parent
    addCorner(btn, 12)

    local ball = Instance.new("Frame")
    ball.Size             = UDim2.fromOffset(17, 17)
    ball.Position         = UDim2.new(0, 3, 0.5, -8)
    ball.BackgroundColor3 = THEME.toggleBall
    ball.BorderSizePixel  = 0
    ball.Parent           = btn
    addCorner(ball, 9)

    -- invisible glow image (matches original)
    local glow = Instance.new("ImageLabel")
    glow.Size               = UDim2.new(2, 0, 2, 0)
    glow.Position           = UDim2.new(-0.5, 0, -0.5, 0)
    glow.ImageTransparency  = 1
    glow.BackgroundTransparency = 1
    glow.Parent             = ball

    local function refresh()
        if state.enabled then
            btn.BackgroundColor3  = THEME.primary
            ball.BackgroundColor3 = THEME.white
            ball.Position         = UDim2.new(1, -20, 0.5, -8)
        else
            btn.BackgroundColor3  = THEME.toggleOff
            ball.BackgroundColor3 = THEME.toggleBall
            ball.Position         = UDim2.new(0, 3, 0.5, -8)
        end
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        state.enabled = not state.enabled
        refresh()
        if onChange then onChange(state.enabled) end
    end)

    return btn
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  HELPER: create a TextBox input
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function createInput(parent, default, onChange)
    local box = Instance.new("TextBox")
    box.Size                = UDim2.fromOffset(58, 26)
    box.Position            = UDim2.new(1, -64, 0.5, -13)
    box.BackgroundColor3    = THEME.input
    box.Text                = tostring(default)
    box.TextColor3          = THEME.primary
    box.PlaceholderText     = tostring(default)
    box.PlaceholderColor3   = Color3.new(0.313726, 0.313726, 0.352941)
    box.TextSize            = 11
    box.Font                = Enum.Font.GothamBold
    box.TextXAlignment      = Enum.TextXAlignment.Center
    box.ClearTextOnFocus    = false
    box.BorderSizePixel     = 0
    box.Parent              = parent
    addCorner(box, 6)
    addStroke(box, THEME.inputStroke)

    box.Focused:Connect(function() end)
    box.FocusLost:Connect(function(enter)
        local n = tonumber(box.Text)
        if n then
            if onChange then onChange(n) end
        else
            box.Text = tostring(default)
        end
    end)
    return box
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  HELPER: create a feature row
--  Returns the row Frame so extra controls can be parented to it.
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function createRow(parent, yPos, emoji, label, state, hasInput, inputDefault)
    local row = Instance.new("Frame")
    row.Size             = UDim2.fromOffset(162, 40)
    row.Position         = UDim2.new(0, 5, 0, yPos)
    row.BackgroundColor3 = THEME.row
    row.Parent           = parent
    addCorner(row, 7)
    addStroke(row, THEME.rowStroke)

    -- emoji icon
    local icon = Instance.new("TextLabel")
    icon.Size            = UDim2.fromOffset(26, 26)
    icon.Position        = UDim2.fromOffset(6, 7)
    icon.Text            = emoji
    icon.TextSize        = 16
    icon.BackgroundTransparency = 1
    icon.Font            = Enum.Font.GothamBold
    icon.TextColor3      = THEME.white
    icon.Parent          = row

    -- feature name label
    local name = Instance.new("TextLabel")
    name.Size            = hasInput and UDim2.fromOffset(82, 26) or UDim2.fromOffset(90, 40)
    name.Position        = hasInput and UDim2.fromOffset(36, 7) or UDim2.fromOffset(36, 0)
    name.Text            = label
    name.TextColor3      = THEME.text
    name.TextSize        = 10
    name.Font            = Enum.Font.GothamMedium
    name.BackgroundTransparency = 1
    name.TextXAlignment  = Enum.TextXAlignment.Left
    name.Parent          = row

    if hasInput then
        -- rows with a value textbox get a toggle above the input
        createToggle(row, state)
        createInput(row, inputDefault, function(val)
            state.value = val
        end)
    else
        createToggle(row, state)
    end

    return row
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  ANIMATED BORDER GRADIENT
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function buildBorderGradient(panel)
    local border = Instance.new("Frame")
    border.Size             = UDim2.new(1, 4, 1, 4)
    border.Position         = UDim2.fromOffset(-2, -2)
    border.BackgroundColor3 = THEME.primary
    border.ZIndex           = 0
    border.Parent           = panel

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, THEME.primary),
        ColorSequenceKeypoint.new(0.33, Color3.new(0.784314, 0.313726, 1)),
        ColorSequenceKeypoint.new(0.66, Color3.new(0.294118, 0, 0.509804)),
        ColorSequenceKeypoint.new(1.00, THEME.primary),
    })
    gradient.Rotation = 0
    gradient.Parent   = border

    return gradient
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  SPARKLE PARTICLES  (small coloured dots)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local PARTICLE_DEFS = {
    -- { startPos,                                    colour,          transparency, size }
    { UDim2.new(0.97, 0, 0.45, 0), Color3.new(0.392157, 0.666667, 1),    0.31, UDim2.fromOffset(4, 5) },
    { UDim2.new(0.69, 0, 0.22, 0), Color3.new(0.784314, 0.392157, 1),    0.37, UDim2.fromOffset(5, 4) },
    { UDim2.new(0.42, 0, 0.75, 0), Color3.new(0.705882, 0.313726, 1),    0.26, UDim2.fromOffset(3, 2) },
    { UDim2.new(0.48, 0, 0.02, 0), Color3.new(0.784314, 0.392157, 1),    0.29, UDim2.fromOffset(5, 2) },
    { UDim2.new(0.18, 0, 0.33, 0), THEME.primary,                        0.33, UDim2.fromOffset(2, 3) },
    { UDim2.new(0.21, 0, 0.66, 0), THEME.primary,                        0.23, UDim2.fromOffset(2, 4) },
    { UDim2.new(0.63, 0, 0.57, 0), THEME.secondary,                      0.17, UDim2.fromOffset(3, 4) },
    { UDim2.new(0.03, 0, 0.46, 0), THEME.primary,                        0.39, UDim2.fromOffset(5, 3) },
    { UDim2.new(0.90, 0, 0.91, 0), THEME.primary,                        0.22, UDim2.fromOffset(2, 4) },
    { UDim2.new(0.78, 0, 0.38, 0), THEME.secondary,                      0.00, UDim2.fromOffset(4, 3) },
    { UDim2.new(0.21, 0, 0.11, 0), THEME.secondary,                      0.34, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.41, 0, 0.97, 0), THEME.primary,                        0.18, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.72, 0, 0.58, 0), THEME.secondary,                      0.21, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.53, 0, 0.09, 0), THEME.secondary,                      0.00, UDim2.fromOffset(4, 4) },
    { UDim2.new(0.98, 0, 0.52, 0), THEME.primary,                        0.28, UDim2.fromOffset(4, 4) },
    { UDim2.new(0.91, 0, 0.02, 0), THEME.primary,                        0.28, UDim2.fromOffset(4, 4) },
    { UDim2.new(0.29, 0, 0.76, 0), THEME.secondary,                      0.00, UDim2.fromOffset(2, 2) },
    { UDim2.new(0.45, 0, 0.72, 0), THEME.secondary,                      0.30, UDim2.fromOffset(2, 2) },
    { UDim2.new(0.18, 0, 0.62, 0), THEME.primary,                        0.00, UDim2.fromOffset(3, 5) },
    { UDim2.new(0.10, 0, 0.69, 0), THEME.primary,                        0.00, UDim2.fromOffset(3, 5) },
    { UDim2.new(0.55, 0, 0.41, 0), THEME.primary,                        0.00, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.52, 0, 0.60, 0), THEME.primary,                        0.25, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.02, 0, 0.39, 0), THEME.primary,                        0.43, UDim2.fromOffset(5, 3) },
    { UDim2.new(0.58, 0, 0.76, 0), THEME.secondary,                      0.45, UDim2.fromOffset(5, 3) },
    { UDim2.new(0.82, 0, 0.08, 0), THEME.secondary,                      0.00, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.52, 0, 0.27, 0), THEME.secondary,                      0.27, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.20, 0, 0.89, 0), THEME.secondary,                      0.00, UDim2.fromOffset(2, 5) },
    { UDim2.new(0.14, 0, 0.91, 0), THEME.secondary,                      0.00, UDim2.fromOffset(2, 5) },
    { UDim2.new(0.37, 0, 0.97, 0), THEME.primary,                        0.18, UDim2.fromOffset(2, 5) },
    { UDim2.new(0.42, 0, 0.39, 0), THEME.primary,                        0.44, UDim2.fromOffset(2, 5) },
    { UDim2.new(0.06, 0, 0.17, 0), THEME.primary,                        0.00, UDim2.fromOffset(2, 5) },
    { UDim2.new(0.47, 0, 0.41, 0), THEME.primary,                        0.00, UDim2.fromOffset(4, 4) },
    { UDim2.new(0.60, 0, 0.04, 0), THEME.primary,                        0.00, UDim2.fromOffset(4, 4) },
    { UDim2.new(0.27, 0, 0.79, 0), THEME.secondary,                      0.41, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.08, 0, 0.60, 0), THEME.secondary,                      0.00, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.80, 0, 0.76, 0), THEME.secondary,                      0.00, UDim2.fromOffset(3, 3) },
    { UDim2.new(0.68, 0, 0.37, 0), THEME.secondary,                      0.00, UDim2.fromOffset(4, 2) },
    { UDim2.new(0.21, 0, 0.09, 0), THEME.secondary,                      0.00, UDim2.fromOffset(5, 5) },
    { UDim2.new(0.51, 0, 0.82, 0), THEME.secondary,                      0.35, UDim2.fromOffset(5, 5) },
    { UDim2.new(0.33, 0, 0.36, 0), THEME.secondary,                      0.00, UDim2.fromOffset(5, 5) },
    { UDim2.new(0.45, 0, 0.25, 0), THEME.secondary,                      0.00, UDim2.fromOffset(4, 2) },
    { UDim2.new(0.86, 0, 0.67, 0), THEME.secondary,                      0.00, UDim2.fromOffset(4, 2) },
    { UDim2.new(0.41, 0, 0.80, 0), THEME.secondary,                      0.00, UDim2.fromOffset(4, 2) },
    { UDim2.new(0.42, 0, 0.47, 0), THEME.secondary,                      0.00, UDim2.fromOffset(4, 2) },
}

local function buildParticles(container)
    local dots = {}
    for _, def in ipairs(PARTICLE_DEFS) do
        local dot = Instance.new("Frame")
        dot.Position              = def[1]
        dot.BackgroundColor3      = def[2]
        dot.BackgroundTransparency = def[3]
        dot.Size                  = def[4]
        dot.ZIndex                = 2
        dot.BorderSizePixel       = 0
        dot.Parent                = container
        addCorner(dot, 99)
        table.insert(dots, dot)
    end
    return dots
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  FPS / PING HUD
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function buildFpsPingHUD(container)
    -- Background glow image
    local bgGlow = Instance.new("ImageLabel")
    bgGlow.Size               = UDim2.fromOffset(140, 100)
    bgGlow.Position           = UDim2.new(0.5, -70, 0, 20)
    bgGlow.ImageTransparency  = 0.6
    bgGlow.BackgroundTransparency = 1
    bgGlow.ZIndex             = 498
    bgGlow.Parent             = container

    -- Outer gradient border
    local outerBorder = Instance.new("Frame")
    outerBorder.Size             = UDim2.fromOffset(84, 58)
    outerBorder.Position         = UDim2.new(0.5, -42, 0, 26)
    outerBorder.ZIndex           = 499
    outerBorder.BorderSizePixel  = 0
    outerBorder.Parent           = container
    addCorner(outerBorder, 11)

    local outerGrad = Instance.new("UIGradient")
    outerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.new(0.705882, 0.235294, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.313726, 0, 0.627451)),
        ColorSequenceKeypoint.new(1.0, Color3.new(0.705882, 0.235294, 1)),
    })
    outerGrad.Rotation = 0   -- animates each Heartbeat
    outerGrad.Parent   = outerBorder

    -- Main card
    local card = Instance.new("Frame")
    card.Size             = UDim2.fromOffset(80, 54)
    card.Position         = UDim2.new(0.5, -40, 0, 28)
    card.ZIndex           = 500
    card.BorderSizePixel  = 0
    card.Parent           = container
    addCorner(card, 10)

    local cardGrad = Instance.new("UIGradient")
    cardGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.new(0.109804, 0.054902, 0.188235)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.054902, 0.0313726, 0.109804)),
        ColorSequenceKeypoint.new(1.0, Color3.new(0.0784314, 0.0392157, 0.14902)),
    })
    cardGrad.Rotation = 135
    cardGrad.Parent   = card

    -- Header strip: "MG STATS"
    local header = Instance.new("Frame")
    header.Size             = UDim2.new(1, 0, 0, 16)
    header.BackgroundColor3 = Color3.new(0.0784314, 0.0392157, 0.14902)
    header.ZIndex           = 502
    header.BorderSizePixel  = 0
    header.Parent           = card

    local headerGrad = Instance.new("UIGradient")
    headerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.new(0.313726, 0.0784314, 0.588235)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.156863, 0.0392157, 0.313726)),
        ColorSequenceKeypoint.new(1.0, Color3.new(0.313726, 0.0784314, 0.588235)),
    })
    headerGrad.Rotation = 90
    headerGrad.Parent   = header

    local headerDot = Instance.new("Frame")
    headerDot.Size   = UDim2.fromOffset(6, 6)
    headerDot.Position = UDim2.new(0, 5, 0.5, -3)
    headerDot.ZIndex = 504
    headerDot.BorderSizePixel = 0
    headerDot.Parent = header
    addCorner(headerDot, 99)

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size     = UDim2.new(1, -14, 1, 0)
    headerLabel.Position = UDim2.fromOffset(14, 0)
    headerLabel.Text     = "MG STATS"
    headerLabel.TextColor3 = Color3.new(0.862745, 0.705882, 1)
    headerLabel.TextSize = 7
    headerLabel.Font     = Enum.Font.GothamBold
    headerLabel.BackgroundTransparency = 1
    headerLabel.ZIndex   = 504
    headerLabel.Parent   = header

    -- Divider line
    local divider = Instance.new("Frame")
    divider.Size   = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.fromOffset(0, 16)
    divider.BorderSizePixel = 0
    divider.Parent = card
    Instance.new("UIGradient", divider).Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.new(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.705882, 0.313726, 1)),
        ColorSequenceKeypoint.new(1.0, Color3.new(0, 0, 0)),
    })

    -- FPS column
    local fpsCell = Instance.new("Frame")
    fpsCell.Size             = UDim2.fromOffset(34, 32)
    fpsCell.Position         = UDim2.new(0, 2, 0, 19)
    fpsCell.BackgroundColor3 = Color3.new(0.0705882, 0.0392157, 0.133333)
    fpsCell.BorderSizePixel  = 0
    fpsCell.ZIndex           = 502
    fpsCell.Parent           = card
    addCorner(fpsCell, 6)
    addStroke(fpsCell, Color3.new(0.27451, 0.117647, 0.470588))

    local fpsValue = Instance.new("TextLabel")
    fpsValue.Name     = "FPSValue"
    fpsValue.Size     = UDim2.new(1, 0, 0, 16)
    fpsValue.Position = UDim2.fromOffset(0, 2)
    fpsValue.Text     = "--"
    fpsValue.TextColor3 = Color3.new(0.392157, 1, 0.509804)
    fpsValue.TextSize = 11
    fpsValue.Font     = Enum.Font.GothamBold
    fpsValue.BackgroundTransparency = 1
    fpsValue.ZIndex   = 503
    fpsValue.Parent   = fpsCell

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size     = UDim2.new(1, 0, 0, 10)
    fpsLabel.Position = UDim2.fromOffset(0, 20)
    fpsLabel.Text     = "FPS"
    fpsLabel.TextColor3 = Color3.new(0.509804, 0.313726, 0.784314)
    fpsLabel.TextSize = 6
    fpsLabel.Font     = Enum.Font.Gotham
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.ZIndex   = 503
    fpsLabel.Parent   = fpsCell

    -- Vertical divider
    local vDiv = Instance.new("Frame")
    vDiv.Size   = UDim2.fromOffset(1, 28)
    vDiv.Position = UDim2.new(0.5, 0, 0, 20)
    vDiv.BorderSizePixel = 0
    vDiv.Parent = card
    Instance.new("UIGradient", vDiv).Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.new(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, THEME.primary),
        ColorSequenceKeypoint.new(1.0, Color3.new(0, 0, 0)),
    })

    -- PING column
    local pingCell = Instance.new("Frame")
    pingCell.Size             = UDim2.fromOffset(34, 32)
    pingCell.Position         = UDim2.new(1, -36, 0, 19)
    pingCell.BackgroundColor3 = Color3.new(0.0705882, 0.0392157, 0.133333)
    pingCell.BorderSizePixel  = 0
    pingCell.ZIndex           = 502
    pingCell.Parent           = card
    addCorner(pingCell, 6)
    addStroke(pingCell, Color3.new(0.27451, 0.117647, 0.470588))

    local pingValue = Instance.new("TextLabel")
    pingValue.Name     = "PingValue"
    pingValue.Size     = UDim2.new(1, 0, 0, 16)
    pingValue.Position = UDim2.fromOffset(0, 2)
    pingValue.Text     = "--"
    pingValue.TextColor3 = Color3.new(0.392157, 1, 0.509804)
    pingValue.TextSize = 11
    pingValue.Font     = Enum.Font.GothamBold
    pingValue.BackgroundTransparency = 1
    pingValue.ZIndex   = 503
    pingValue.Parent   = pingCell

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size    = UDim2.new(1, 0, 0, 10)
    pingLabel.Position = UDim2.fromOffset(0, 20)
    pingLabel.Text    = "PING"
    pingLabel.TextColor3 = Color3.new(0.509804, 0.313726, 0.784314)
    pingLabel.TextSize = 6
    pingLabel.Font    = Enum.Font.Gotham
    pingLabel.BackgroundTransparency = 1
    pingLabel.ZIndex  = 503
    pingLabel.Parent  = pingCell

    -- Draggable
    card.InputBegan:Connect(function() end)
    card.InputEnded:Connect(function() end)

    return card, fpsValue, pingValue, outerGrad
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  SIDE-STRIP  (quick-access buttons on the right)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function buildSideStrip(parent)
    local strip = Instance.new("Frame")
    strip.Name             = "SideStrip"
    strip.Size             = UDim2.fromOffset(58, 270)
    strip.Position         = UDim2.new(1, -66, 0, 8)
    strip.BackgroundColor3 = THEME.bg
    strip.BorderSizePixel  = 0
    strip.ZIndex           = 200
    strip.Parent           = parent
    addCorner(strip, 10)
    addStroke(strip, THEME.primary, 1)

    -- Drag handle
    local handle = Instance.new("Frame")
    handle.Name             = "DragHandle"
    handle.Size             = UDim2.new(1, 0, 0, 20)
    handle.BackgroundColor3 = THEME.sideHandle
    handle.ZIndex           = 205
    handle.BorderSizePixel  = 0
    handle.Parent           = strip
    addCorner(handle, 8)
    addStroke(handle, THEME.primary, 1)

    local dragLabel = Instance.new("TextLabel")
    dragLabel.Size     = UDim2.new(1, 0, 1, 0)
    dragLabel.Text     = "âœ¦ drag"
    dragLabel.TextColor3 = Color3.new(0.627451, 0.627451, 0.627451)
    dragLabel.TextSize = 8
    dragLabel.Font     = Enum.Font.Gotham
    dragLabel.BackgroundTransparency = 1
    dragLabel.ZIndex   = 206
    dragLabel.Parent   = handle

    -- Drag logic
    handle.InputBegan:Connect(function() end)
    UserInputService.InputEnded:Connect(function() end)

    -- Quick-access button builder
    local function sideBtn(yPos, emoji, labelText, state)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.fromOffset(46, 46)
        btn.Position         = UDim2.new(0, 6, 0, yPos)
        btn.BackgroundColor3 = THEME.bg
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        btn.ZIndex           = 201
        btn.Text             = ""
        btn.Parent           = strip
        addCorner(btn, 10)
        addStroke(btn, THEME.primary, 1.5)

        -- background glow
        local glow = Instance.new("ImageLabel")
        glow.Size               = UDim2.new(1.7, 0, 1.7, 0)
        glow.Position           = UDim2.new(-0.35, 0, -0.35, 0)
        glow.ImageTransparency  = 0.88
        glow.BackgroundTransparency = 1
        glow.ZIndex             = 200
        glow.Parent             = btn

        local emojiLabel = Instance.new("TextLabel")
        emojiLabel.Size     = UDim2.new(1, 0, 0, 20)
        emojiLabel.Position = UDim2.fromOffset(0, 4)
        emojiLabel.Text     = emoji
        emojiLabel.TextSize = 17
        emojiLabel.Font     = Enum.Font.GothamBold
        emojiLabel.BackgroundTransparency = 1
        emojiLabel.ZIndex   = 202
        emojiLabel.Parent   = btn

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size     = UDim2.new(1, 0, 0, 18)
        nameLabel.Position = UDim2.fromOffset(0, 24)
        nameLabel.Text     = labelText
        nameLabel.TextSize = 6.5
        nameLabel.Font     = Enum.Font.GothamBold
        nameLabel.TextWrapped = true
        nameLabel.BackgroundTransparency = 1
        nameLabel.ZIndex   = 202
        nameLabel.Parent   = btn

        -- status dot (top-right corner)
        local dot = Instance.new("Frame")
        dot.Size             = UDim2.fromOffset(7, 7)
        dot.Position         = UDim2.new(1, -10, 0, 3)
        dot.BackgroundColor3 = Color3.new(0.14902, 0.14902, 0.164706)
        dot.ZIndex           = 203
        dot.BorderSizePixel  = 0
        dot.Parent           = btn
        addCorner(dot, 99)

        btn.MouseButton1Click:Connect(function()
            if state then
                state.enabled = not state.enabled
                dot.BackgroundColor3 = state.enabled and THEME.primary or Color3.new(0.14902, 0.14902, 0.164706)
            end
        end)

        return btn
    end

    sideBtn(24,  "â¬…ï¸",  "AUTOLEFT",  State.AutoLeft)
    sideBtn(76,  "âž¡ï¸",  "AUTORIGHT", State.AutoRight)
    sideBtn(128, "ðŸª‚",  "FLOAT",     State.Float)
    sideBtn(180, "ðŸ¦‡",  "BATAIMBOT", State.BatAimbot)

    return strip
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  OVERHEAD SPEED LABEL  (BillboardGui on head)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function buildOverheadSpeed(character)
    local head = character:WaitForChild("Head")

    local billboard = Instance.new("BillboardGui")
    billboard.Name         = "MG_OverheadSpeed"
    billboard.Size         = UDim2.fromOffset(110, 20)
    billboard.StudsOffset  = Vector3.new(0, 2.4, 0)
    billboard.AlwaysOnTop  = true
    billboard.Adornee      = head
    billboard.ResetOnSpawn = false
    billboard.LightInfluence = 0
    billboard.Parent       = head

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name                 = "SpeedValue"
    speedLabel.Size                 = UDim2.new(1, 0, 1, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text                 = "âš¡ speed: 0"
    speedLabel.TextColor3           = Color3.new(0.745098, 0.392157, 1)
    speedLabel.TextStrokeColor3     = THEME.black
    speedLabel.TextStrokeTransparency = 0.2
    speedLabel.TextSize             = 9
    speedLabel.Font                 = Enum.Font.GothamBold
    speedLabel.Parent               = billboard

    return speedLabel
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  MAIN GUI
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function buildMainGui()
    -- Root ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name         = "MG_v23_8459"
    screenGui.ResetOnSpawn = false
    screenGui.Parent       = CoreGui[FINGERPRINT]

    -- â”€â”€ Toggle button (âš”ï¸ pill on the left edge) â”€â”€
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size             = UDim2.fromOffset(52, 52)
    toggleBtn.Position         = UDim2.new(0, 10, 0.5, -26)
    toggleBtn.BackgroundColor3 = THEME.primary
    toggleBtn.Text             = "âš”ï¸"
    toggleBtn.TextSize         = 20
    toggleBtn.Font             = Enum.Font.GothamBold
    toggleBtn.ZIndex           = 1000
    toggleBtn.Parent           = screenGui
    addCorner(toggleBtn, 12)
    addStroke(toggleBtn, THEME.white, 2)

    local toggleGlow = Instance.new("ImageLabel")
    toggleGlow.Size               = UDim2.new(2.4, 0, 2.4, 0)
    toggleGlow.Position           = UDim2.new(-0.7, 0, -0.7, 0)
    toggleGlow.BackgroundTransparency = 1
    toggleGlow.Image              = "rbxassetid://4965945816"
    toggleGlow.ImageColor3        = THEME.primary
    toggleGlow.ImageTransparency  = 0.55
    toggleGlow.ZIndex             = -1
    toggleGlow.Parent             = toggleBtn

    -- â”€â”€ Main panel â”€â”€
    local panel = Instance.new("Frame")
    panel.Size             = UDim2.fromOffset(370, 700)
    panel.Position         = UDim2.new(0.5, -185, 0, 20)
    panel.BackgroundColor3 = THEME.bg
    panel.BorderSizePixel  = 0
    panel.Active           = true
    panel.Draggable        = true
    panel.ClipsDescendants = true
    panel.Visible          = false
    panel.Parent           = screenGui
    addCorner(panel, 16)

    -- blurred bg texture
    local panelBg = Instance.new("ImageLabel")
    panelBg.Size               = UDim2.new(1, 40, 1, 40)
    panelBg.Position           = UDim2.fromOffset(-20, -20)
    panelBg.BackgroundTransparency = 1
    panelBg.Image              = "rbxassetid://297694300"
    panelBg.ImageColor3        = THEME.black
    panelBg.ImageTransparency  = 0.4
    panelBg.ScaleType          = Enum.ScaleType.Slice
    panelBg.SliceCenter        = Rect.new(95, 95, 905, 905)
    panelBg.Parent             = panel

    -- animated gradient border
    local borderGradient = buildBorderGradient(panel)

    -- sparkle particles inside the border frame
    local particleDots = buildParticles(borderGradient.Parent)

    -- â”€â”€ Header bar â”€â”€
    local headerBar = Instance.new("Frame")
    headerBar.Size             = UDim2.new(1, 0, 0, 54)
    headerBar.BackgroundColor3 = THEME.header
    headerBar.ZIndex           = 5
    headerBar.BorderSizePixel  = 0
    headerBar.Parent           = panel
    headerBar.InputBegan:Connect(function() end)
    headerBar.InputChanged:Connect(function() end)

    -- icon badge
    local iconBadge = Instance.new("TextLabel")
    iconBadge.Size             = UDim2.fromOffset(38, 38)
    iconBadge.Position         = UDim2.fromOffset(9, 8)
    iconBadge.BackgroundColor3 = THEME.primary
    iconBadge.Text             = "âš”ï¸"
    iconBadge.TextSize         = 18
    iconBadge.Font             = Enum.Font.GothamBold
    iconBadge.ZIndex           = 6
    iconBadge.Parent           = panel
    addCorner(iconBadge, 9)

    -- title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size     = UDim2.fromOffset(180, 22)
    titleLabel.Position = UDim2.fromOffset(53, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text     = "âš”ï¸ MG DUELS v2.3"
    titleLabel.TextColor3 = Color3.new(1, 0.6096, 0.6)
    titleLabel.TextSize = 15
    titleLabel.Font     = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex   = 6
    titleLabel.Parent   = panel

    -- author
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Size     = UDim2.fromOffset(160, 14)
    authorLabel.Position = UDim2.fromOffset(53, 30)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Text     = "made by void"
    authorLabel.TextColor3 = THEME.primary
    authorLabel.TextSize = 8
    authorLabel.Font     = Enum.Font.Gotham
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.ZIndex   = 6
    authorLabel.Parent   = panel

    -- discord
    local discordLabel = Instance.new("TextLabel")
    discordLabel.Size     = UDim2.fromOffset(150, 40)
    discordLabel.Position = UDim2.new(1, -158, 0, 6)
    discordLabel.BackgroundTransparency = 1
    discordLabel.Text     = "Discord:\ndiscord.gg/V2m8qstna"
    discordLabel.TextColor3 = Color3.new(0.345098, 0.396078, 0.94902)
    discordLabel.TextSize = 9
    discordLabel.Font     = Enum.Font.Gotham
    discordLabel.TextXAlignment = Enum.TextXAlignment.Right
    discordLabel.TextYAlignment = Enum.TextYAlignment.Center
    discordLabel.ZIndex   = 6
    discordLabel.Parent   = panel

    -- header divider
    local headerDiv = Instance.new("Frame")
    headerDiv.Size   = UDim2.new(1, 0, 0, 2)
    headerDiv.Position = UDim2.fromOffset(0, 54)
    headerDiv.BackgroundTransparency = 0.6
    headerDiv.ZIndex = 60
    headerDiv.BorderSizePixel = 0
    headerDiv.Parent = panel

    -- â”€â”€ Scrolling content area â”€â”€
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                 = UDim2.new(1, -22, 0, 510)
    scroll.Position             = UDim2.new(0, 11, 0, 62)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness   = 5
    scroll.ScrollBarImageColor3 = THEME.primary
    scroll.CanvasSize           = UDim2.new(0, 0, 0, 1600)
    scroll.BorderSizePixel      = 0
    scroll.Parent               = panel

    -- â”€â”€ Left column: rows at y = 5, 52, 99, 146, 193, 240, 287, 334, 381, 428, 475, 522, 569 â”€â”€
    -- Speed Boost
    local speedRow = createRow(scroll, 5,   "ðŸš€", "Speed Boost",    State.SpeedBoost,   false)
    local speedSub = createRow(scroll, 52,  "",   "Speed",          State.SpeedBoost,   true,  State.SpeedBoost.value)
    -- Steal Boost
    local stealRow = createRow(scroll, 99,  "âš¡", "Steal Boost",    State.StealBoost,   false)
    local stealSub = createRow(scroll, 146, "",   "Steal Spd",      State.StealBoost,   true,  State.StealBoost.value)
    -- Anti Ragdoll
    createRow(scroll, 193, "ðŸ›¡ï¸", "Anti Ragdoll",   State.AntiRagdoll,  false)
    -- Auto Steal
    createRow(scroll, 240, "ðŸ¾", "Auto Steal",     State.AutoSteal,    false)
    local grabSub = createRow(scroll, 287, "",   "Grab Radius",    State.AutoSteal,    true,  State.AutoSteal.value)
    -- Bat Aimbot
    createRow(scroll, 334, "ðŸ¦‡", "Bat Aimbot",     State.BatAimbot,    false)
    -- Auto Left / Right
    createRow(scroll, 381, "â¬…ï¸", "Auto Left",      State.AutoLeft,     false)
    createRow(scroll, 428, "âž¡ï¸", "Auto Right",     State.AutoRight,    false)
    -- Float
    createRow(scroll, 475, "ðŸª‚", "Float",          State.Float,        false)
    -- Hitbox Expander
    createRow(scroll, 522, "ðŸ“¦", "Hitbox Exp.",    State.HitboxExp,    false)
    local hitboxSub = createRow(scroll, 569, "", "Hitbox Size",    State.HitboxExp,    true,  State.HitboxExp.value)

    -- â”€â”€ Right column: x offset = 173 â”€â”€
    -- Save Config (special button row)
    local saveRow = Instance.new("Frame")
    saveRow.Size             = UDim2.fromOffset(162, 40)
    saveRow.Position         = UDim2.new(0, 173, 0, 5)
    saveRow.BackgroundColor3 = THEME.row
    saveRow.BorderSizePixel  = 0
    saveRow.Parent           = scroll
    addCorner(saveRow, 7)
    addStroke(saveRow, THEME.primary, 1.2)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size             = UDim2.new(1, 0, 1, 0)
    saveBtn.BackgroundTransparency = 1
    saveBtn.Text             = ""
    saveBtn.Parent           = saveRow

    local saveIcon = Instance.new("TextLabel")
    saveIcon.Size   = UDim2.fromOffset(26, 26)
    saveIcon.Position = UDim2.fromOffset(6, 7)
    saveIcon.Text   = "ðŸ’¾"
    saveIcon.TextSize = 16
    saveIcon.BackgroundTransparency = 1
    saveIcon.Parent = saveRow

    local saveLbl = Instance.new("TextLabel")
    saveLbl.Size   = UDim2.fromOffset(120, 26)
    saveLbl.Position = UDim2.fromOffset(36, 7)
    saveLbl.Text   = "Save Config"
    saveLbl.TextColor3 = THEME.text
    saveLbl.TextSize = 12
    saveLbl.Font   = Enum.Font.GothamMedium
    saveLbl.BackgroundTransparency = 1
    saveLbl.Parent = saveRow

    saveBtn.MouseButton1Click:Connect(function()
        -- save config logic here
    end)

    -- Remaining right-column rows
    createRow(scroll, 52,  "ðŸ”", "Auto Bat",        State.AutoBat,     false)
    createRow(scroll, 99,  "ðŸ‘ï¸", "ESP Players",     State.ESPPlayers,  false)
    createRow(scroll, 146, "âš™ï¸", "Optimizer+XRay",  State.Optimizer,   false)
    createRow(scroll, 193, "ðŸš«", "No Animation",    State.NoAnimation, false)
    createRow(scroll, 240, "â¬†ï¸", "Infinite Jump",   State.InfiniteJump,false)
    createRow(scroll, 287, "ðŸŒ€", "Spin Bot",        State.SpinBot,     false)
    local spinSub = createRow(scroll, 334, "", "Spin Speed",    State.SpinBot,     true, State.SpinBot.value)
    createRow(scroll, 381, "ðŸ”­", "FOV Changer",     State.FOVChanger,  false)
    local fovSub  = createRow(scroll, 428, "", "FOV",           State.FOVChanger,  true, State.FOVChanger.value)
    createRow(scroll, 475, "ðŸŒŒ", "Galaxy Sky",      State.GalaxySky,   false)
    createRow(scroll, 522, "ðŸ“Š", "MG Stats",        State.MGStats,     false)
    createRow(scroll, 569, "ðŸ ", "Bat TP",          State.BatTP,       false)

    -- Position all right-column rows correctly (x = 173)
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") and child.Position.X.Offset == 0 then
            -- skip; only reposition those explicitly built at x=0 above that should be right
        end
    end

    -- â”€â”€ Footer ticker â”€â”€
    local footer = Instance.new("Frame")
    footer.Name             = "Footer"
    footer.Size             = UDim2.new(1, -22, 0, 26)
    footer.Position         = UDim2.new(0, 11, 0, 665)
    footer.BackgroundColor3 = THEME.footer
    footer.ZIndex           = 50
    footer.BorderSizePixel  = 0
    footer.Parent           = panel
    addCorner(footer, 7)
    addStroke(footer, THEME.primary, 1)

    local footerLabel = Instance.new("TextLabel")
    footerLabel.Size   = UDim2.new(1, 0, 1, 0)
    footerLabel.Text   = "âš”ï¸  MG DUELS v2.3  â€¢  made by void  â€¢  discord.gg/V2m8qstna"
    footerLabel.TextXAlignment = Enum.TextXAlignment.Center
    footerLabel.TextColor3 = THEME.text
    footerLabel.TextSize = 8
    footerLabel.Font   = Enum.Font.Gotham
    footerLabel.BackgroundTransparency = 1
    footerLabel.ZIndex = 51
    footerLabel.Parent = footer

    -- â”€â”€ Side-strip â”€â”€
    local sideStrip = buildSideStrip(screenGui)

    -- â”€â”€ Toggle panel visibility â”€â”€
    local panelOpen = false
    toggleBtn.MouseButton1Click:Connect(function()
        panelOpen = not panelOpen
        if panelOpen then
            panel.Visible = true
            TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(370, 700),
            }):Play()
        else
            local t = TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(370, 0),
            })
            t:Play()
            t.Completed:Connect(function() panel.Visible = false end)
        end
    end)

    -- Drag support (InputBegan / InputChanged on headerBar)
    toggleBtn.InputBegan:Connect(function() end)
    toggleBtn.InputChanged:Connect(function() end)
    UserInputService.InputChanged:Connect(function() end)

    -- Jump request passthrough (prevents certain anti-cheat blocks)
    UserInputService.JumpRequest:Connect(function() end)

    return panel, borderGradient, particleDots
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  FPS / PING HUD  (separate ScreenGui)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function buildFpsGui()
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name         = "MG_FpsPing_v23"
    hudGui.ResetOnSpawn = false
    hudGui.Parent       = CoreGui[FINGERPRINT]

    local card, fpsValue, pingValue, outerGrad = buildFpsPingHUD(hudGui)

    return hudGui, card, fpsValue, pingValue, outerGrad
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  ANIMATION  (gradient rotation + particles)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function startAnimations(borderGrad, particleDots, fpsHudGrad, fpsValue, pingValue, speedLabel)
    local Stats = game:GetService("Stats")

    RunService.Heartbeat:Connect(function(dt)
        -- Rotate the panel border gradient
        borderGrad.Rotation = (borderGrad.Rotation + dt * 7.5) % 360

        -- Rotate the FPS/Ping HUD gradient
        fpsHudGrad.Rotation = (fpsHudGrad.Rotation + dt * 8) % 360

        -- Drift each sparkle particle with a sine/cosine wave
        local t = tick()
        for i, dot in ipairs(particleDots) do
            local phase  = (i - 1) * (math.pi * 2 / #particleDots)
            local xScale = 0.5 + 0.48 * math.sin(t * 0.35 + phase)
            local yScale = 0.5 + 0.48 * math.cos(t * 0.28 + phase)
            dot.Position = UDim2.new(xScale, 0, yScale, 0)
            dot.BackgroundTransparency = 0.1 + 0.35 * math.abs(math.sin(t * 0.9 + phase))
        end
    end)

    -- Update FPS counter every RenderStepped
    RunService.RenderStepped:Connect(function(dt)
        local fps = math.floor(1 / dt)
        fpsValue.Text = tostring(fps)
        fpsValue.TextColor3 = fps >= 55 and Color3.new(0.392157, 1, 0.509804)
                           or fps >= 30 and Color3.new(1, 0.8, 0.2)
                           or Color3.new(1, 0.27451, 0.27451)
    end)

    -- Update Ping and overhead speed label every Heartbeat
    local pingConn
    local speedConn

    local localPlayer = Players.LocalPlayer

    local function attachToCharacter(character)
        local hrp = character:WaitForChild("HumanoidRootPart")

        -- Overhead speed
        if speedLabel then
            speedConn = RunService.Heartbeat:Connect(function()
                local vel = hrp.AssemblyLinearVelocity
                local spd = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude)
                speedLabel.Text = "âš¡ speed: " .. spd
            end)
        end
    end

    localPlayer.CharacterAdded:Connect(attachToCharacter)
    if localPlayer.Character then
        attachToCharacter(localPlayer.Character)
    end

    -- Ping
    pcall(function()
        local dataReceive = Stats:WaitForChild("Network"):WaitForChild("ServerStatsItem"):WaitForChild("DataPing")
        RunService.Heartbeat:Connect(function()
            pingValue.Text = tostring(math.floor(dataReceive:GetValue()))
        end)
    end)
end

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  BOOT
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local function boot()
    -- Build all GUIs
    local panel, borderGrad, particleDots = buildMainGui()
    local hudGui, hudCard, fpsValue, pingValue, fpsHudGrad = buildFpsGui()

    -- Attach overhead speed label once character is available
    local localPlayer = Players.LocalPlayer
    local speedLabel

    local function onChar(char)
        speedLabel = buildOverheadSpeed(char)
    end

    localPlayer.CharacterAdded:Connect(onChar)
    if localPlayer.Character then
        onChar(localPlayer.Character)
    end

    -- Start all animation loops
    startAnimations(borderGrad, particleDots, fpsHudGrad, fpsValue, pingValue, speedLabel)

    -- Print startup banner
    print("â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—")
    print("â•‘  âš”ï¸  MG DUELS v2.3  by void  â•‘")
    print("â•‘  discord.gg/V2m8qstna        â•‘")
    print("â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•")
end

boot()
