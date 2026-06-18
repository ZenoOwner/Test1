local _ = not game:IsLoaded()
local _call6 = game:GetService('Players')
local _ = not _call6.LocalPlayer
local _call11 = _call6.LocalPlayer:WaitForChild('PlayerGui', 15)

game:GetService('TweenService')

local _call16 = game:GetService('UserInputService')

game:GetService('HttpService')
game:GetService('TeleportService')

local _ = http.request
local _call26 = _call11:FindFirstChild('TunaPremium')

_call26:Destroy()

local _call31 = Instance.new('ScreenGui')

_call31.Name = 'TunaPremium'
_call31.Parent = _call11
_call31.ResetOnSpawn = false
_call31.DisplayOrder = 999999

local _call33 = Instance.new('Frame')

_call33.Parent = _call31
_call33.Size = UDim2.new(0, 520, 0, 320)
_call33.Position = UDim2.new(0.5, -260, 0.5, -160)
_call33.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
_call33.BorderSizePixel = 0

local _call41 = Instance.new('UICorner', _call33)

_call41.CornerRadius = UDim.new(0, 12)

_call33.InputBegan:Connect(function(...) end)
_call16.InputEnded:Connect(function(...) end)
_call16.InputChanged:Connect(function(...) end)

local _call54 = Instance.new('Frame')

_call54.Parent = _call33
_call54.Size = UDim2.new(0, 150, 1, 0)
_call54.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
_call54.BorderSizePixel = 0

local _call60 = Instance.new('UICorner', _call54)

_call60.CornerRadius = UDim.new(0, 12)

local _call64 = Instance.new('TextLabel')

_call64.Parent = _call54
_call64.Size = UDim2.new(1, 0, 0, 100)
_call64.Position = UDim2.new(0, 0, 0.1, 0)
_call64.BackgroundTransparency = 1
_call64.Text = 'TUNA\nSCRIPTS'
_call64.Font = Enum.Font.GothamBlack
_call64.TextSize = 28
_call64.TextColor3 = Color3.fromRGB(255, 255, 255)

local _call74 = Instance.new('TextLabel')

_call74.Parent = _call54
_call74.Size = UDim2.new(1, 0, 0, 30)
_call74.Position = UDim2.new(0, 0, 0.48, 0)
_call74.BackgroundTransparency = 1
_call74.Text = 'ENTERPRISE'
_call74.Font = Enum.Font.GothamMedium
_call74.TextSize = 16
_call74.TextColor3 = Color3.fromRGB(180, 180, 180)

local _call84 = Instance.new('Frame')

_call84.Parent = _call54
_call84.Size = UDim2.new(0, 8, 0, 8)
_call84.Position = UDim2.new(0.18, 0, 0.7, 0)
_call84.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
_call84.BorderSizePixel = 0

local _call92 = Instance.new('UICorner', _call84)

_call92.CornerRadius = UDim.new(1, 0)

local _call96 = Instance.new('TextLabel')

_call96.Parent = _call54
_call96.Size = UDim2.new(0, 80, 0, 20)
_call96.Position = UDim2.new(0.28, 0, 0.68, 0)
_call96.BackgroundTransparency = 1
_call96.Text = 'ONLINE'
_call96.Font = Enum.Font.Gotham
_call96.TextSize = 14
_call96.TextColor3 = Color3.fromRGB(200, 200, 200)

local _call106 = Instance.new('TextButton')

_call106.Parent = _call54
_call106.Size = UDim2.new(0, 120, 0, 32)
_call106.Position = UDim2.new(0.1, 0, 0.82, 0)
_call106.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
_call106.Text = 'REJOIN SERVER'
_call106.TextColor3 = Color3.fromRGB(200, 200, 255)
_call106.Font = Enum.Font.GothamBold
_call106.TextSize = 11
_call106.BorderSizePixel = 0

local _call118 = Instance.new('UICorner', _call106)

_call118.CornerRadius = UDim.new(0, 6)

local _call122 = Instance.new('Frame')

_call122.Parent = _call33
_call122.Position = UDim2.new(0, 150, 0, 0)
_call122.Size = UDim2.new(1, -150, 1, 0)
_call122.BackgroundTransparency = 1

local _call128 = Instance.new('TextLabel')

_call128.Parent = _call122
_call128.Size = UDim2.new(1, 0, 0, 40)
_call128.Position = UDim2.new(0, 0, 0.08, 0)
_call128.BackgroundTransparency = 1
_call128.Text = 'LICENSE AUTHENTICATION'
_call128.Font = Enum.Font.GothamBold
_call128.TextSize = 22
_call128.TextColor3 = Color3.fromRGB(255, 255, 255)

local _call138 = Instance.new('TextLabel')

_call138.Parent = _call122
_call138.Size = UDim2.new(1, 0, 0, 20)
_call138.Position = UDim2.new(0, 0, 0.18, 0)
_call138.BackgroundTransparency = 1
_call138.Text = 'Secure session verification'
_call138.Font = Enum.Font.Gotham
_call138.TextSize = 14
_call138.TextColor3 = Color3.fromRGB(150, 150, 150)

local _call148 = Instance.new('TextBox')

_call148.Parent = _call122
_call148.Size = UDim2.new(0.75, 0, 0, 42)
_call148.Position = UDim2.new(0.12, 0, 0.32, 0)
_call148.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
_call148.PlaceholderText = 'Enter license key...'
_call148.Text = ''
_call148.TextColor3 = Color3.new(1, 1, 1)
_call148.Font = Enum.Font.Gotham
_call148.TextSize = 14
_call148.BorderSizePixel = 0

local _call160 = Instance.new('UICorner', _call148)

_call160.CornerRadius = UDim.new(0, 8)

local _call164 = Instance.new('TextButton')

_call164.Parent = _call122
_call164.Size = UDim2.new(0.75, 0, 0, 42)
_call164.Position = UDim2.new(0.12, 0, 0.52, 0)
_call164.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
_call164.Text = 'VERIFY ACCESS'
_call164.TextColor3 = Color3.new(1, 1, 1)
_call164.Font = Enum.Font.GothamBold
_call164.TextSize = 14
_call164.BorderSizePixel = 0

local _call176 = Instance.new('UICorner', _call164)

_call176.CornerRadius = UDim.new(0, 8)

local _call180 = Instance.new('TextButton')

_call180.Parent = _call122
_call180.Size = UDim2.new(0.75, 0, 0, 20)
_call180.Position = UDim2.new(0.12, 0, 0.7, 0)
_call180.BackgroundTransparency = 1
_call180.Text = 'CLICK TO COPY KEY LINK'
_call180.TextColor3 = Color3.fromRGB(130, 140, 230)
_call180.Font = Enum.Font.GothamBold
_call180.TextSize = 12

local _call190 = Instance.new('TextLabel')

_call190.Parent = _call122
_call190.Size = UDim2.new(1, 0, 0, 20)
_call190.Position = UDim2.new(0, 0, 0.82, 0)
_call190.BackgroundTransparency = 1
_call190.Text = 'STATUS: WAITING CONNECTION'
_call190.Font = Enum.Font.Code
_call190.TextSize = 14
_call190.TextColor3 = Color3.fromRGB(150, 150, 150)

task.spawn(function(...) end)
_call180.MouseButton1Click:Connect(function(...) end)
_call106.MouseButton1Click:Connect(function(...) end)
_call164.MouseButton1Click:Connect(function(...) end)
