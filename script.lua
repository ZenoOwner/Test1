local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local _G_GUIS = {}

do
    local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
    local KILL = {
        ["FunGui"]=true, ["FunHubNotify"]=true,
        ["PanelGui_Admin Panel"]=true, ["PanelGui_Fun Admin Spammer"]=true,
        ["PanelGui_Actions"]=true, ["PanelGui_Booster"]=true,
        ["PanelGui_Command Cooldowns"]=true, ["PanelGui_Defense"]=true,
        ["PanelGui_Instant Steal"]=true, ["PanelGui_Instant Steal V2"]=true,
        ["StealProgressGui"]=true, ["UI_Watermark"]=true,
        ["UnlockBaseGui"]=true, ["AllowFriendsGui"]=true,
        ["DiscordLabelGui"]=true,
    }
    for _, g in ipairs(pg:GetChildren()) do
        if KILL[g.Name] then g:Destroy() end
    end
end

local CONFIG_PATH = "FunHub_config.json"
local Config = {data = {}, dirty = false}
do
    local hs = game:GetService("HttpService")
    local ok, contents = pcall(function() return readfile(CONFIG_PATH) end)
    if ok and contents then
        local ok2, decoded = pcall(function() return hs:JSONDecode(contents) end)
        if ok2 and type(decoded) == "table" then Config.data = decoded end
    end
    function Config:get(key, default)
        local v = self.data[key]
        if v == nil then return default end
        return v
    end
    function Config:set(key, value)
        self.data[key] = value
        self.dirty = true
    end
    function Config:flush()
        if not self.dirty then return end
        self.dirty = false
        pcall(function()
            writefile(CONFIG_PATH, hs:JSONEncode(self.data))
        end)
    end
    task.spawn(function()
        while true do task.wait(2); Config:flush() end
    end)
end
_G.FunHubConfig = Config

local function n(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if parent ~= nil then inst.Parent = parent end
    return inst
end

local function build_FunGui(_G_GUIS)
    local _R = {}
    do
    _R.FunGui = n("ScreenGui", {Name="FunGui", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    _R.Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 350, 0, 400), Position=UDim2.new(0.5, 0, 0.5, 0), AnchorPoint=Vector2.new(0.5, 0.5), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.3, Visible=false, ClipsDescendants=false, Active=false, Selectable=false}, _R.FunGui)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, _R.Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 42), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="FUNHUB V5.3", TextColor3=Color3.fromRGB(230, 235, 255), TextSize=18, Font=Enum.Font.GothamBlack, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 56, 0, 22), Position=UDim2.new(1, -10, 0.5, 0), AnchorPoint=Vector2.new(1, 0.5), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame2)
    n("UIListLayout", {Name="UIListLayout", FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0, 6), Wraps=false}, Frame3)
    _R.Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), BackgroundColor3=Color3.fromRGB(57, 64, 89), BorderSizePixel=0, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, _R.Frame4)
    local UIStroke2 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, _R.Frame4)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke2)
    _R.TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, _R.Frame4)
    _R.Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), BackgroundColor3=Color3.fromRGB(255, 255, 255), BorderSizePixel=0, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, _R.Frame5)
    local UIStroke3 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, _R.Frame5)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke3)
    _R.TextButton2 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, _R.Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -24, 0, 36), Position=UDim2.new(0, 12, 0, 48), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame)
    n("UIListLayout", {Name="UIListLayout", FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0, 8), Wraps=false}, Frame6)
    local TextButton3 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, -6, 1, 0), Position=UDim2.new(0, 0, 0, 4), BackgroundColor3=Color3.fromRGB(153, 153, 153), ClipsDescendants=false, Text="Main", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=14, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 12)}, TextButton3)
    n("UIScale", {Name="UIScale"}, TextButton3)
    local TextButton4 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, -6, 1, 0), Position=UDim2.new(0, 0, 0, 4), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Text="Visual", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=14, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 12)}, TextButton4)
    n("UIScale", {Name="UIScale"}, TextButton4)
    local TextButton5 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, -6, 1, 0), Position=UDim2.new(0, 0, 0, 4), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Text="Player", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=14, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 12)}, TextButton5)
    n("UIScale", {Name="UIScale"}, TextButton5)
    local TextButton6 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, -6, 1, 0), Position=UDim2.new(0, 0, 0, 4), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Text="Utils", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=14, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 12)}, TextButton6)
    n("UIScale", {Name="UIScale"}, TextButton6)
    _R.Frame7 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame)
    local ScrollingFrame = n("ScrollingFrame", {Name="ScrollingFrame", Size=UDim2.new(1, -24, 1, -96), Position=UDim2.new(0, 12, 0, 84), BackgroundTransparency=1, Active=false, CanvasSize=UDim2.new(0, 0, 0, 8), ScrollBarThickness=5, ScrollBarImageTransparency=0.2}, _R.Frame7)
    n("UIListLayout", {Name="UIListLayout", Wraps=false}, ScrollingFrame)
    local Frame8 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame8)
    local TextLabel2 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Instant Steal", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame8)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel2)
    local Frame9 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame8)
    local Frame10 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame9)
    local Frame11 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame10)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame11)
    local Frame12 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame11)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame12)
    local Frame13 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame12)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame13)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Instant Steal Panel", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame13)
    local Frame14 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame13)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame14)
    local Frame15 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame14)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame15)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame13)
    local Frame16 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame11)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame16)
    local Frame17 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame16)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame17)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Instant Steal Panel V2", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame17)
    local Frame18 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame17)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame18)
    local Frame19 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame18)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame19)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame17)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame10)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame10)
    local UIStroke4 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame10)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke4)
    local Frame20 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame20)
    local TextLabel5 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Stealing", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame20)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel5)
    local Frame21 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame20)
    local Frame22 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame21)
    local Frame23 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame22)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame23)
    local Frame24 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame23)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame24)
    local Frame25 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame24)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame25)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Auto Steal (Old)", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame25)
    local Frame26 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame25)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame26)
    local Frame27 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame26)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame27)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame25)
    local Frame28 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame23)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame28)
    local Frame29 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame28)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame29)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Auto Steal (New)", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame29)
    local Frame30 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame29)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame30)
    local Frame31 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame30)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame31)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame29)
    local Frame32 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame23)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame32)
    local Frame33 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame32)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame33)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Unlock Base", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame33)
    local Frame34 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame33)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame34)
    local Frame35 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame34)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame35)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame33)
    local Frame36 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame23)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame36)
    local Frame37 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame36)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame37)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Clone Devourer", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame37)
    local Frame38 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame37)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame38)
    local Frame39 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame38)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame39)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame37)
    local Frame40 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame23)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame40)
    local Frame41 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame40)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame41)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Auto Giant Potion", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame41)
    local Frame42 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame41)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame42)
    local Frame43 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame42)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame43)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame41)
    local Frame44 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame23)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame44)
    local Frame45 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame44)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame45)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Giant Potion Speed", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame45)
    local Frame46 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame45)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame46)
    local Frame47 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame46)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame47)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame45)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame22)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame22)
    local UIStroke5 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame22)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke5)
    local ScrollingFrame2 = n("ScrollingFrame", {Name="ScrollingFrame", Size=UDim2.new(1, -24, 1, -96), Position=UDim2.new(0, 12, 0, 84), BackgroundTransparency=1, Visible=false, Active=false, CanvasSize=UDim2.new(0, 0, 0, 8), ScrollBarThickness=5, ScrollBarImageTransparency=0.2}, _R.Frame7)
    n("UIListLayout", {Name="UIListLayout", Wraps=false}, ScrollingFrame2)
    local Frame48 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame2)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame48)
    local TextLabel12 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Optimizer", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame48)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel12)
    local Frame49 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame48)
    local Frame50 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame49)
    local Frame51 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame50)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame51)
    local Frame52 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame51)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame52)
    local Frame53 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame52)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame53)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="FPS Boost", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame53)
    local Frame54 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame53)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame54)
    local Frame55 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame54)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame55)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame53)
    local Frame56 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame51)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame56)
    local Frame57 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame56)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame57)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Game Stretcher", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame57)
    local Frame58 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame57)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame58)
    local Frame59 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame58)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame59)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame57)
    local Frame60 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 46), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame51)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame60)
    local Frame61 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame60)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame61)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -14, 0, 18), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Camera FOV", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame61)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 40, 0, 18), Position=UDim2.new(1, -54, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="70", TextColor3=Color3.fromRGB(140, 140, 160), TextSize=14, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame61)
    local Frame62 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -28, 0, 6), Position=UDim2.new(0, 14, 1, -10), BackgroundColor3=Color3.fromRGB(25, 32, 70), ClipsDescendants=false, Active=false, Selectable=false}, Frame61)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame62)
    local Frame63 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0.5798319578170776, 0, 1, 0), BackgroundColor3=Color3.fromRGB(40, 45, 62), ClipsDescendants=false, Active=false, Selectable=false}, Frame62)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame63)
    local Frame64 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 14, 0, 14), Position=UDim2.new(0.5798319578170776, 0, 0.5, 0), AnchorPoint=Vector2.new(0.5, 0.5), BackgroundColor3=Color3.fromRGB(210, 225, 255), ZIndex=2, ClipsDescendants=false, Active=false, Selectable=false}, Frame62)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame64)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 24), Position=UDim2.new(0, 0, 0.5, -12), BackgroundTransparency=1, ZIndex=3, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame62)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame50)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame50)
    local UIStroke6 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame50)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke6)
    local Frame65 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame2)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame65)
    local TextLabel17 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Visual", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame65)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel17)
    local Frame66 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame65)
    local Frame67 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame66)
    local Frame68 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame67)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame68)
    local Frame69 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame68)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame69)
    local Frame70 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame69)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame70)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="X-Ray", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame70)
    local Frame71 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame70)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame71)
    local Frame72 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame71)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame72)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame70)
    local Frame73 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame68)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame73)
    local Frame74 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame73)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame74)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Anti Bee", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame74)
    local Frame75 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame74)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame75)
    local Frame76 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame75)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame76)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame74)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame67)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame67)
    local UIStroke7 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame67)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke7)
    local Frame77 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame2)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame77)
    local TextLabel20 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="ESP", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame77)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel20)
    local Frame78 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame77)
    local Frame79 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame78)
    local Frame80 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame79)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame80)
    local Frame81 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame80)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame81)
    local Frame82 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame81)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame82)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Player ESP", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame82)
    local Frame83 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame82)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame83)
    local Frame84 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame83)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame84)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame82)
    local Frame85 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame80)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame85)
    local Frame86 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame85)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame86)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Brainrot ESP", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame86)
    local Frame87 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame86)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame87)
    local Frame88 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame87)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame88)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame86)
    local Frame89 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame80)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame89)
    local Frame90 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame89)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame90)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Clone ESP", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame90)
    local Frame91 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame90)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame91)
    local Frame92 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame91)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame92)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame90)
    local Frame93 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame80)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame93)
    local Frame94 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame93)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame94)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Timer ESP", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame94)
    local Frame95 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame94)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame95)
    local Frame96 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame95)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame96)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame94)
    local Frame97 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame80)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame97)
    local Frame98 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame97)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame98)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Mine ESP", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame98)
    local Frame99 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame98)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame99)
    local Frame100 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame99)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame100)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame98)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame79)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame79)
    local UIStroke8 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame79)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke8)
    local ScrollingFrame3 = n("ScrollingFrame", {Name="ScrollingFrame", Size=UDim2.new(1, -24, 1, -96), Position=UDim2.new(0, 12, 0, 84), BackgroundTransparency=1, Visible=false, Active=false, CanvasSize=UDim2.new(0, 0, 0, 8), ScrollBarThickness=5, ScrollBarImageTransparency=0.2}, _R.Frame7)
    n("UIListLayout", {Name="UIListLayout", Wraps=false}, ScrollingFrame3)
    local Frame101 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame3)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame101)
    local TextLabel26 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Movement", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame101)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel26)
    local Frame102 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame101)
    local Frame103 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame102)
    local Frame104 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame103)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame104)
    local Frame105 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame104)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame105)
    local Frame106 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame105)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame106)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Anti Ragdoll", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame106)
    local Frame107 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame106)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame107)
    local Frame108 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame107)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame108)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame106)
    local Frame109 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame104)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame109)
    local Frame110 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame109)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame110)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Booster GUI", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame110)
    local Frame111 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame110)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame111)
    local Frame112 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame111)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame112)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame110)
    local Frame113 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame104)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame113)
    local Frame114 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame113)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame114)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Grapple Speed", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame114)
    local Frame115 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame114)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame115)
    local Frame116 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame115)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame116)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame114)
    local Frame117 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame104)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame117)
    local Frame118 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame117)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame118)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Infinite Jump", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame118)
    local Frame119 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame118)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame119)
    local Frame120 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame119)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame120)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame118)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame103)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame103)
    local UIStroke9 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame103)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke9)
    local Frame121 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame3)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame121)
    local TextLabel31 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Exploit", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame121)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel31)
    local Frame122 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame121)
    _R.Frame123 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame122)
    _R.Frame124 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame123)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, _R.Frame124)
    local Frame125 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame124)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame125)
    _R.Frame126 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame125)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, _R.Frame126)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Auto Reset On Balloon", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, _R.Frame126)
    end
    do
    local Frame127 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame126)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame127)
    local Frame128 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame127)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame128)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, _R.Frame126)
    local Frame129 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame124)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame129)
    local Frame130 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame129)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame130)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Anti Turret", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame130)
    local Frame131 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame130)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame131)
    local Frame132 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame131)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame132)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame130)
    local Frame133 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame124)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame133)
    local Frame134 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame133)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame134)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Aimbot", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame134)
    local Frame135 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame134)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame135)
    local Frame136 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame135)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame136)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame134)
    local Frame137 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, _R.Frame124)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame137)
    local Frame138 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame137)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame138)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Steal On Leave/Block", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame138)
    local Frame139 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame138)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame139)
    local Frame140 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame139)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame140)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame138)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, _R.Frame123)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, _R.Frame123)
    local UIStroke10 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, _R.Frame123)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke10)
    local ScrollingFrame4 = n("ScrollingFrame", {Name="ScrollingFrame", Size=UDim2.new(1, -24, 1, -96), Position=UDim2.new(0, 12, 0, 84), BackgroundTransparency=1, Visible=false, Active=false, CanvasSize=UDim2.new(0, 0, 0, 8), ScrollBarThickness=5, ScrollBarImageTransparency=0.2}, _R.Frame7)
    n("UIListLayout", {Name="UIListLayout", Wraps=false}, ScrollingFrame4)
    local Frame141 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame4)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame141)
    local TextLabel36 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Admin Panel", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame141)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel36)
    local Frame142 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame141)
    local Frame143 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame142)
    local Frame144 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame143)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame144)
    local Frame145 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame144)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame145)
    local Frame146 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame145)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame146)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Admin Spammer", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame146)
    local Frame147 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame146)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame147)
    local Frame148 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame147)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame148)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame146)
    local Frame149 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame144)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame149)
    local Frame150 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame149)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame150)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Quick Admin Panel", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame150)
    local Frame151 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame150)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame151)
    local Frame152 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame151)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame152)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame150)
    local Frame153 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame144)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame153)
    local Frame154 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame153)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame154)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Command Cooldowns", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame154)
    local Frame155 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame154)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame155)
    local Frame156 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame155)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame156)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame154)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame143)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame143)
    local UIStroke11 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame143)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke11)
    local Frame157 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame4)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame157)
    local TextLabel40 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Protection", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame157)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel40)
    local Frame158 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame157)
    local Frame159 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame158)
    local Frame160 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame159)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame160)
    local Frame161 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame160)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame161)
    local Frame162 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame161)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame162)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Defense Panel", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame162)
    local Frame163 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame162)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame163)
    local Frame164 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame163)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame164)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame162)
    local Frame165 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame160)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame165)
    local Frame166 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame165)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame166)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Intruder Alarm", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame166)
    local Frame167 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame166)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame167)
    local Frame168 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame167)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame168)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame166)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame159)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame159)
    local UIStroke12 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame159)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke12)
    local Frame169 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame4)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame169)
    local TextLabel43 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Desync", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame169)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel43)
    local Frame170 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame169)
    local Frame171 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame170)
    local Frame172 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame171)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame172)
    local Frame173 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame172)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame173)
    local Frame174 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame173)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame174)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Reset Desync", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame174)
    local Frame175 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame174)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame175)
    local Frame176 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame175)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame176)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame174)
    local Frame177 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame172)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame177)
    local Frame178 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame177)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame178)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Unwalk (No Anim)", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame178)
    local Frame179 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame178)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame179)
    local Frame180 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame179)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame180)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame178)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame171)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame171)
    local UIStroke13 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame171)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke13)
    local Frame181 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, ScrollingFrame4)
    n("UIListLayout", {Name="UIListLayout", SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, 2), Wraps=false}, Frame181)
    local TextLabel46 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -12, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Other", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=15, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame181)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6)}, TextLabel46)
    local Frame182 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 12), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame181)
    local Frame183 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -4, 0, 12), Position=UDim2.new(0, 2, 0, 0), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.35, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame182)
    local Frame184 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 0), BackgroundTransparency=1, LayoutOrder=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame183)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame184)
    local Frame185 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame184)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame185)
    local Frame186 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame185)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame186)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Quantum Cloner", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame186)
    local Frame187 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame186)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame187)
    local Frame188 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame187)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame188)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame186)
    local Frame189 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame184)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame189)
    local Frame190 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame189)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame190)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Instant Reset (Old) <font color=\"rgb(140,140,160)\">(R)</font>", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame190)
    local Frame191 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame190)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame191)
    local Frame192 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame191)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame192)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame190)
    local Frame193 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame184)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame193)
    local Frame194 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame193)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame194)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Carpet TP (Next Base)", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame194)
    local Frame195 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame194)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame195)
    local Frame196 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame195)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame196)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame194)
    local Frame197 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame184)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame197)
    local Frame198 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame197)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame198)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Place Subspace Mine", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame198)
    local Frame199 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame198)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame199)
    local Frame200 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame199)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame200)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame198)
    local Frame201 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame184)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame201)
    local Frame202 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame201)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame202)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Allow Friends", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame202)
    local Frame203 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame202)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame203)
    local Frame204 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame203)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame204)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame202)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, -2)}, Frame183)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame183)
    local UIStroke14 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame183)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke14)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, _R.Frame)
    n("UIScale", {Name="UIScale", Scale=1e-07}, _R.Frame)
    local TextButton45 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 60, 0, 34), Position=UDim2.new(0, 15, 0, 120), BackgroundColor3=Color3.fromRGB(11, 13, 18), BackgroundTransparency=0.1, ClipsDescendants=false, Text="Fun", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=18, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, _R.FunGui)
    n("UIScale", {Name="UIScale"}, TextButton45)
    local UIStroke15 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, TextButton45)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=205.421}, UIStroke15)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 18)}, TextButton45)
    end
    _G_GUIS["FunGui"] = _R.FunGui
    _G_GUIS["FunGui:colorBtnA"] = _R.Frame4
    _G_GUIS["FunGui:colorBtnB"] = _R.Frame5
    _G_GUIS["FunGui:colorBtnAClick"] = _R.TextButton
    _G_GUIS["FunGui:colorBtnBClick"] = _R.TextButton2
    return _R
end
build_FunGui(_G_GUIS)

local function build_PanelGui_Admin_Panel(_G_GUIS)
    local _R = {}
    do
    _R.PanelGui_FunAdminSpammer = n("ScreenGui", {Name="PanelGui_Fun Admin Spammer", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 300, 0, 320), Position=UDim2.new(0.5, 174, 0.5, -163), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.1, ClipsDescendants=true, Active=true, Selectable=false}, _R.PanelGui_FunAdminSpammer)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=222.627}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundColor3=Color3.fromRGB(7, 8, 11), ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame2)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -36, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Fun Admin Spammer", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=13, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -26, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ClipsDescendants=false, Text="â€“", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton)
    local TextButton2 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -52, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ZIndex=5, ClipsDescendants=false, Text="âš™", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=14, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton2)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, -30), Position=UDim2.new(0, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame3)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="No targets found", TextColor3=Color3.fromRGB(180, 180, 180), TextSize=13, Font=Enum.Font.Gotham, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, Frame3)
    local Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 40), Position=UDim2.new(0, 0, 1, -40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame4)
    local Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame4)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame5)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame6)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Spam Closest", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame6)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame6)
    end
    _G_GUIS["PanelGui_Admin Panel"] = _R.PanelGui_FunAdminSpammer
    return _R
end
build_PanelGui_Admin_Panel(_G_GUIS)

local function build_PanelGui_Actions(_G_GUIS)
    local _R = {}
    do
    _R.PanelGui_Actions = n("ScreenGui", {Name="PanelGui_Actions", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 220, 0, 228), Position=UDim2.new(0.5, 218, 0.5, -336), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.1, ClipsDescendants=false, Active=true, Selectable=false}, _R.PanelGui_Actions)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=196.03}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundColor3=Color3.fromRGB(7, 8, 11), ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame2)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -36, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Actions", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=13, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -52, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ClipsDescendants=false, Text="â€“", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton)
    local TextButton2 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -26, 0.5, -11), BackgroundColor3=Color3.fromRGB(14, 16, 22), ClipsDescendants=false, Text="Ã—", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton2)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, -30), Position=UDim2.new(0, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame3)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame3)
    local Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame4)
    local Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame4)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame5)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Rejoin", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame5)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame6)
    local Frame7 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame7)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Kick Self", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame7)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame7)
    local Frame8 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame8)
    local Frame9 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame8)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame9)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Ragdoll Self", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame9)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame9)
    local Frame10 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame10)
    local Frame11 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame10)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame11)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Reset Character", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame11)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame11)
    local Frame12 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame12)
    local Frame13 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame12)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame13)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Instant Reset", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame13)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame13)
    end
    _G_GUIS["PanelGui_Actions"] = _R.PanelGui_Actions
    return _R
end
build_PanelGui_Actions(_G_GUIS)

local function build_PanelGui_Booster(_G_GUIS)
    local _R = {}
    do
    _R.PanelGui_Booster = n("ScreenGui", {Name="PanelGui_Booster", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 220, 0, 124), Position=UDim2.new(0.5, 245, 0.5, 100), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.1, ClipsDescendants=false, Active=true, Selectable=false}, _R.PanelGui_Booster)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=12.251}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundColor3=Color3.fromRGB(7, 8, 11), ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame2)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -36, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Booster", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=13, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -26, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ClipsDescendants=false, Text="â€“", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, -30), Position=UDim2.new(0, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame3)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame3)
    local Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame4)
    local Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame4)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame5)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Booster", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame5)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame6)
    local Frame7 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame7)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame5)
    local Frame8 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 24), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame8)
    local Frame9 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(25, 32, 70), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame8)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame9)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0.3499999940395355, 0, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Walk Speed", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame9)
    local TextBox = n("TextBox", {Name="TextBox", SelectionGroup=false, Size=UDim2.new(0.30000001192092896, -10, 0.699999988079071, 0), Position=UDim2.new(0.699999988079071, 6, 0.15000000596046448, 0), BackgroundColor3=Color3.fromRGB(9, 10, 13), ClipsDescendants=false, Text="29", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, ClearTextOnFocus=false, MultiLine=false, RichText=false}, Frame9)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 6)}, TextBox)
    local Frame10 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 24), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame10)
    local Frame11 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(25, 32, 70), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame10)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame11)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0.3499999940395355, 0, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Jump Power", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame11)
    local TextBox2 = n("TextBox", {Name="TextBox", SelectionGroup=false, Size=UDim2.new(0.30000001192092896, -10, 0.699999988079071, 0), Position=UDim2.new(0.699999988079071, 6, 0.15000000596046448, 0), BackgroundColor3=Color3.fromRGB(9, 10, 13), ClipsDescendants=false, Text="50", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, ClearTextOnFocus=false, MultiLine=false, RichText=false}, Frame11)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 6)}, TextBox2)
    end
    _G_GUIS["PanelGui_Booster"] = _R.PanelGui_Booster
    return _R
end
build_PanelGui_Booster(_G_GUIS)

local function build_PanelGui_Command_Cooldowns(_G_GUIS)
    local _R = {}
    do
    _R.PanelGui_CommandCooldowns = n("ScreenGui", {Name="PanelGui_Command Cooldowns", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 220, 0, 278), Position=UDim2.new(0.5, -465, 0.5, 49), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.1, ClipsDescendants=false, Active=true, Selectable=false}, _R.PanelGui_CommandCooldowns)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=352.041}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundColor3=Color3.fromRGB(7, 8, 11), ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame2)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -36, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Command Cooldowns", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=13, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -26, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ClipsDescendants=false, Text="â€“", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, -30), Position=UDim2.new(0, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame3)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame3)
    local Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame4)
    local Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame4)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame5)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="rocket", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame5)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame6)
    local Frame7 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame7)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="ragdoll", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame7)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame7)
    local Frame8 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame8)
    local Frame9 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame8)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame9)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="balloon", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame9)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame9)
    local Frame10 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame10)
    local Frame11 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame10)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame11)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="inverse", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame11)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame11)
    local Frame12 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame12)
    local Frame13 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame12)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame13)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="nightvision", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame13)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame13)
    local Frame14 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame14)
    local Frame15 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame14)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame15)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="jail", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame15)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame15)
    local Frame16 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame16)
    local Frame17 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame16)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame17)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="control", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame17)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame17)
    local Frame18 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame18)
    local Frame19 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame18)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame19)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="tiny", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame19)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame19)
    local Frame20 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame20)
    local Frame21 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame20)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame21)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="jumpscare", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame21)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame21)
    local Frame22 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 20), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6), PaddingLeft=UDim.new(0, 14)}, Frame22)
    local Frame23 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame22)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame23)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="morph", TextColor3=Color3.fromRGB(250, 250, 250), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame23)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 50, 1, 0), Position=UDim2.new(1, -50, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="READY", TextColor3=Color3.fromRGB(0, 200, 0), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Right, RichText=false}, Frame23)
    end
    _G_GUIS["PanelGui_Command Cooldowns"] = _R.PanelGui_CommandCooldowns
    return _R
end
build_PanelGui_Command_Cooldowns(_G_GUIS)

local function build_PanelGui_Defense(_G_GUIS)
    local _R = {}
    do
    _R.PanelGui_FunDefense = n("ScreenGui", {Name="PanelGui_Fun Defense", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 280, 0, 128), Position=UDim2.new(0.5, -96, 0.5, 129), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.1, ClipsDescendants=false, Active=true, Selectable=false}, _R.PanelGui_FunDefense)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=155.363}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundColor3=Color3.fromRGB(7, 8, 11), ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame2)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -36, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Fun Defense", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=13, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -26, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ClipsDescendants=false, Text="â€“", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, -30), Position=UDim2.new(0, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame3)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame3)
    local Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame4)
    local Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame4)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame5)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Auto Defense", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame5)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame6)
    local Frame7 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame7)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame5)
    local Frame8 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame8)
    local Frame9 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame8)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame9)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Anti Intruder", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame9)
    local Frame10 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame9)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame10)
    local Frame11 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame10)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame11)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame9)
    local Frame12 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame12)
    local Frame13 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame12)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame13)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Spam On Reset", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame13)
    local Frame14 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame13)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame14)
    local Frame15 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(1, -20, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame14)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame15)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame13)
    end
    _G_GUIS["PanelGui_Defense"] = _R.PanelGui_FunDefense
    return _R
end
build_PanelGui_Defense(_G_GUIS)

local function build_PanelGui_Instant_Steal(_G_GUIS)
    local _R = {}
    do
    _R.PanelGui_InstantSteal = n("ScreenGui", {Name="PanelGui_Instant Steal", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 220, 0, 174), Position=UDim2.new(0.5, -329, 0.5, -164), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.1, ClipsDescendants=false, Active=true, Selectable=false}, _R.PanelGui_InstantSteal)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=244.582}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundColor3=Color3.fromRGB(7, 8, 11), ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame2)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -36, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Instant Steal", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=13, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -26, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ClipsDescendants=false, Text="â€“", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, -30), Position=UDim2.new(0, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame3)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame3)
    local Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame4)
    local Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame4)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame5)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Semi Mode", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame5)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame6)
    local Frame7 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame7)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame5)
    local Frame8 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame8)
    local Frame9 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame8)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame9)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Align (Semi)", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame9)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame9)
    local Frame10 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame10)
    local Frame11 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame10)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame11)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="TP To Brainrot (Semi)", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame11)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame11)
    local Frame12 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame12)
    local Frame13 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame12)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame13)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Full Mode", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame13)
    local Frame14 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame13)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame14)
    local Frame15 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame14)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame15)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame13)
    end
    _G_GUIS["PanelGui_Instant Steal"] = _R.PanelGui_InstantSteal
    return _R
end
build_PanelGui_Instant_Steal(_G_GUIS)

local function build_PanelGui_Instant_Steal_V2(_G_GUIS)
    local _R = {}
    do
    _R.PanelGui_InstantStealV2 = n("ScreenGui", {Name="PanelGui_Instant Steal V2", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 220, 0, 182), Position=UDim2.new(0.5, 288, 0.5, -88), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.1, ClipsDescendants=false, Active=true, Selectable=false}, _R.PanelGui_InstantStealV2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=48.619}, UIStroke)
    local Frame2 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 30), BackgroundColor3=Color3.fromRGB(7, 8, 11), ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, Frame2)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -36, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Instant Steal V2", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=13, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=false}, Frame2)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, -26, 0.5, -11), BackgroundColor3=Color3.fromRGB(11, 13, 18), ClipsDescendants=false, Text="â€“", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false, AutoButtonColor=false}, Frame2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, TextButton)
    local Frame3 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 1, -30), Position=UDim2.new(0, 0, 0, 30), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingLeft=UDim.new(0, 6), PaddingRight=UDim.new(0, 6)}, Frame3)
    n("UIListLayout", {Name="UIListLayout", Padding=UDim.new(0, 4), Wraps=false}, Frame3)
    local Frame4 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 26), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6), PaddingBottom=UDim.new(0, 6)}, Frame4)
    local Frame5 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, 0), BackgroundColor3=Color3.fromRGB(15, 20, 40), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame4)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame5)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -70, 1, 0), Position=UDim2.new(0, 14, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Giant Potion", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, RichText=true}, Frame5)
    local Frame6 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 42, 0, 22), Position=UDim2.new(1, -56, 0.5, -11), BackgroundColor3=Color3.fromRGB(17, 19, 27), ClipsDescendants=false, Active=false, Selectable=false}, Frame5)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame6)
    local Frame7 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 18, 0, 18), Position=UDim2.new(0, 2, 0.5, -9), BackgroundColor3=Color3.fromRGB(210, 225, 255), ClipsDescendants=false, Active=false, Selectable=false}, Frame6)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(1, 0)}, Frame7)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame5)
    local Frame8 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame8)
    local Frame9 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame8)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame9)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Activate (Reset)", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame9)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame9)
    local Frame10 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame10)
    local Frame11 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame10)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame11)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Execute", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame11)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame11)
    local Frame12 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, 0, 0, 34), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false}, Frame3)
    n("UIPadding", {Name="UIPadding", PaddingLeft=UDim.new(0, 6)}, Frame12)
    local Frame13 = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(1, -8, 1, -1), BackgroundColor3=Color3.fromRGB(23, 26, 36), ClipsDescendants=false, Active=false, Selectable=false}, Frame12)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame13)
    n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 1, 0), Position=UDim2.new(0, 10, 0, 0), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="Execute (Full) <font color=\"rgb(140,140,160)\">(B)</font>", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=16, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame13)
    n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(1, 0, 1, 0), BackgroundTransparency=1, ClipsDescendants=false, Text="", TextScaled=false, TextWrapped=false, RichText=false}, Frame13)
    end
    _G_GUIS["PanelGui_Instant Steal V2"] = _R.PanelGui_InstantStealV2
    return _R
end
build_PanelGui_Instant_Steal_V2(_G_GUIS)

local function build_AllowFriendsGui(_G_GUIS)
    local _R = {}
    do
    _R.AllowFriendsGui = n("ScreenGui", {Name="AllowFriendsGui", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=true}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 150, 0, 38), Position=UDim2.new(1, -160, 0, 5), BackgroundColor3=Color3.fromRGB(6, 6, 9), BackgroundTransparency=0.15, ClipsDescendants=false, Text="Allow/Disallow", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=18, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, _R.AllowFriendsGui)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 12)}, TextButton)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, TextButton)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=126.479}, UIStroke)
    end
    _G_GUIS["AllowFriendsGui"] = _R.AllowFriendsGui
    return _R
end
build_AllowFriendsGui(_G_GUIS)

local function build_DiscordLabelGui(_G_GUIS)
    local _R = {}
    do
    _R.DiscordLabelGui = n("ScreenGui", {Name="DiscordLabelGui", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local TextLabel = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 250, 0, 30), Position=UDim2.new(0.5, 0, 1, -65), AnchorPoint=Vector2.new(0.5, 1), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="discord.gg/funhub", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=21, TextStrokeTransparency=0.7, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, _R.DiscordLabelGui)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Offset=Vector2.new(0.506125807762146, 0)}, TextLabel)
    end
    _G_GUIS["DiscordLabelGui"] = _R.DiscordLabelGui
    return _R
end
build_DiscordLabelGui(_G_GUIS)

local function build_StealProgressGui(_G_GUIS)
    local _R = {}
    do
    _R.StealProgressGui = n("ScreenGui", {Name="StealProgressGui", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 200, 0, 12), Position=UDim2.new(0.5, -100, 0.8999999761581421, 0), BackgroundColor3=Color3.fromRGB(30, 30, 30), BorderSizePixel=0, Visible=false, ClipsDescendants=false, Active=false, Selectable=false}, _R.StealProgressGui)
    n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 0, 1, 0), BackgroundColor3=Color3.fromRGB(0, 255, 0), BorderSizePixel=0, ClipsDescendants=false, Active=false, Selectable=false}, Frame)
    end
    _G_GUIS["StealProgressGui"] = _R.StealProgressGui
    return _R
end
build_StealProgressGui(_G_GUIS)

local function build_UI_Watermark(_G_GUIS)
    local _R = {}
    do
    _R.UI_Watermark = n("ScreenGui", {Name="UI_Watermark", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 354, 0, 80), Position=UDim2.new(0.5, 0, 0.20000000298023224, 0), AnchorPoint=Vector2.new(0.5, 1), BackgroundColor3=Color3.fromRGB(25, 25, 25), BackgroundTransparency=0.2, ClipsDescendants=false, Active=false, Selectable=false}, _R.UI_Watermark)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 10)}, Frame)
    local UIStroke = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Rotation=187.038}, UIStroke)
    n("UIListLayout", {Name="UIListLayout", HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0, 2), Wraps=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 8), PaddingBottom=UDim.new(0, 8)}, Frame)
    local TextLabel = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 0, 22), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="FUNHUB V5.3", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=26, Font=Enum.Font.GothamBlack, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, Frame)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Offset=Vector2.new(-0.8670814037322998, 0)}, TextLabel)
    local TextLabel2 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(0, 0, 0, 18), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="@flow_dev - discord.gg/funhub", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=24, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 6)}, TextLabel2)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(57, 64, 89)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}), Offset=Vector2.new(-0.8670814037322998, 0)}, TextLabel2)
    local TextLabel3 = n("TextLabel", {Name="TextLabel", SelectionGroup=false, Size=UDim2.new(1, -20, 0, 18), BackgroundTransparency=1, ClipsDescendants=false, Active=false, Selectable=false, Text="<font color=\"rgb(255,255,255)\">FPS: </font><font color=\"rgb(180,180,180)\">104</font><font color=\"rgb(255,255,255)\">  PING: </font><font color=\"rgb(180,180,180)\">34ms</font>", TextColor3=Color3.fromRGB(255, 255, 255), TextSize=21, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=true}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 12)}, TextLabel3)
    end
    _G_GUIS["UI_Watermark"] = _R.UI_Watermark
    return _R
end
build_UI_Watermark(_G_GUIS)

local function build_UnlockBaseGui(_G_GUIS)
    local _R = {}
    do
    _R.UnlockBaseGui = n("ScreenGui", {Name="UnlockBaseGui", SelectionGroup=false, ResetOnSpawn=false, IgnoreGuiInset=false}, Players.LocalPlayer:WaitForChild("PlayerGui"))
    local Frame = n("Frame", {Name="Frame", SelectionGroup=false, Size=UDim2.new(0, 230, 0, 70), Position=UDim2.new(0.5, -93, 0.5, -409), BackgroundColor3=Color3.fromRGB(20, 25, 35), BackgroundTransparency=0.3, ClipsDescendants=false, Active=true, Selectable=true}, _R.UnlockBaseGui)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 18)}, Frame)
    n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(87, 126, 255), Thickness=1.5, Transparency=0.2}, Frame)
    n("UIListLayout", {Name="UIListLayout", FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0, 12), Wraps=false}, Frame)
    n("UIPadding", {Name="UIPadding", PaddingTop=UDim.new(0, 8), PaddingBottom=UDim.new(0, 8), PaddingLeft=UDim.new(0, 12), PaddingRight=UDim.new(0, 12)}, Frame)
    local TextButton = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 22, 0, 22), Position=UDim2.new(1, 6, 0.5, -11), AnchorPoint=Vector2.new(0, 0.5), BackgroundColor3=Color3.fromRGB(30, 35, 50), BackgroundTransparency=0.1, ClipsDescendants=false, Text="â†•", TextColor3=Color3.fromRGB(220, 230, 255), TextSize=14, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, Frame)
    local UIStroke2 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, TextButton)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(87, 126, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 12, 199))}), Rotation=114.517}, UIStroke2)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 6)}, TextButton)
    local TextButton2 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 50, 0, 50), BackgroundColor3=Color3.fromRGB(17, 25, 51), BackgroundTransparency=0.1, ClipsDescendants=false, Text="1", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=20, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, Frame)
    local UIStroke3 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, TextButton2)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(87, 126, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 12, 199))}), Rotation=114.517}, UIStroke3)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, TextButton2)
    local TextButton3 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 50, 0, 50), BackgroundColor3=Color3.fromRGB(17, 25, 51), BackgroundTransparency=0.1, ClipsDescendants=false, Text="2", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=20, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, Frame)
    local UIStroke4 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, TextButton3)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(87, 126, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 12, 199))}), Rotation=114.517}, UIStroke4)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, TextButton3)
    local TextButton4 = n("TextButton", {Name="TextButton", SelectionGroup=false, Size=UDim2.new(0, 50, 0, 50), BackgroundColor3=Color3.fromRGB(17, 25, 51), BackgroundTransparency=0.1, ClipsDescendants=false, Text="3", TextColor3=Color3.fromRGB(210, 225, 255), TextSize=20, Font=Enum.Font.GothamBold, FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal), TextScaled=false, TextWrapped=false, RichText=false}, Frame)
    local UIStroke5 = n("UIStroke", {Name="UIStroke", Color=Color3.fromRGB(255, 255, 255), ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, TextButton4)
    n("UIGradient", {Name="UIGradient", Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(87, 126, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 12, 199))}), Rotation=114.517}, UIStroke5)
    n("UICorner", {Name="UICorner", CornerRadius=UDim.new(0, 14)}, TextButton4)
    end
    _G_GUIS["UnlockBaseGui"] = _R.UnlockBaseGui
    return _R
end
build_UnlockBaseGui(_G_GUIS)

local function buildColorPicker()
    local LP = Players.LocalPlayer
    local screen = n("ScreenGui", {
        Name = "FunHubColorPicker",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1100,
        Enabled = false,
    }, LP:WaitForChild("PlayerGui"))
    local panel = n("Frame", {
        Name = "ColorPicker",
        Size = UDim2.fromOffset(200, 220),
        Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 200,
    }, screen)
    n("UICorner", {CornerRadius = UDim.new(0, 10)}, panel)
    local stroke = n("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}, panel)
    n("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }),
        Rotation = 90,
    }, stroke)
    n("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
    }, panel)
    n("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, panel)

    local sv = n("Frame", {
        Name = "SV",
        Size = UDim2.new(1, 0, 0, 120),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 201,
        LayoutOrder = 1,
    }, panel)
    n("UICorner", {CornerRadius = UDim.new(0, 6)}, sv)
    n("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, sv)
    local svBlack = n("Frame", {
        Name = "Black",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 202,
    }, sv)
    n("UICorner", {CornerRadius = UDim.new(0, 6)}, svBlack)
    n("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation = 90,
    }, svBlack)
    local svDot = n("Frame", {
        Name = "Dot",
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromScale(1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 203,
    }, sv)
    n("UICorner", {CornerRadius = UDim.new(1, 0)}, svDot)
    n("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5}, svDot)
    local svClick = n("TextButton", {
        Name = "Click", Size = UDim2.fromScale(1, 1), Text = "",
        BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 204,
    }, sv)

    local hue = n("Frame", {
        Name = "Hue",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 201,
        LayoutOrder = 2,
    }, panel)
    n("UICorner", {CornerRadius = UDim.new(1, 0)}, hue)
    n("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
        }),
    }, hue)
    local hueDot = n("Frame", {
        Name = "Dot",
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromScale(0, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 202,
    }, hue)
    n("UICorner", {CornerRadius = UDim.new(1, 0)}, hueDot)
    n("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5}, hueDot)
    local hueClick = n("TextButton", {
        Name = "Click", Size = UDim2.fromScale(1, 1), Text = "",
        BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 203,
    }, hue)

    local preview = n("Frame", {
        Name = "Preview",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 201,
        LayoutOrder = 3,
    }, panel)
    n("UICorner", {CornerRadius = UDim.new(0, 6)}, preview)
    local pStroke = n("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}, preview)
    n("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 64, 89)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }),
        Rotation = 90,
    }, pStroke)

    local state = {h = 0, s = 1, v = 1}
    local target = nil
    local callbacks = {}

    local function refresh()
        local col = Color3.fromHSV(state.h, state.s, state.v)
        sv.BackgroundColor3 = Color3.fromHSV(state.h, 1, 1)
        svDot.Position = UDim2.fromScale(state.s, 1 - state.v)
        hueDot.Position = UDim2.fromScale(state.h, 0.5)
        preview.BackgroundColor3 = col
        if target then
            target.BackgroundColor3 = col
            local cb = callbacks[target]
            if cb then cb(col) end
        end
    end

    local function bindDrag(area, onMove)
        local dragging = false
        area.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                onMove(input.Position)
            end
        end)
        area.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                onMove(input.Position)
            end
        end)
    end

    bindDrag(svClick, function(pos)
        local abs, size = sv.AbsolutePosition, sv.AbsoluteSize
        state.s = math.clamp((pos.X - abs.X) / size.X, 0, 1)
        state.v = 1 - math.clamp((pos.Y - abs.Y) / size.Y, 0, 1)
        refresh()
    end)
    bindDrag(hueClick, function(pos)
        local abs, size = hue.AbsolutePosition, hue.AbsoluteSize
        state.h = math.clamp((pos.X - abs.X) / size.X, 0, 1)
        refresh()
    end)

    local shield = n("TextButton", {
        Name = "Shield",
        Parent = screen,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
        ZIndex = 1,
    })
    shield.MouseButton1Click:Connect(function()
        screen.Enabled = false
        target = nil
    end)

    local picker = {}
    function picker:Toggle(btnFrame)
        if screen.Enabled and target == btnFrame then
            screen.Enabled = false
            target = nil
            return
        end
        target = btnFrame
        state.h, state.s, state.v = Color3.toHSV(btnFrame.BackgroundColor3)

        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
        local anchor = btnFrame.AbsolutePosition + Vector2.new(btnFrame.AbsoluteSize.X/2, btnFrame.AbsoluteSize.Y + 6)
        local px = math.clamp(anchor.X - 100, 8, vp.X - 208)
        local py = math.clamp(anchor.Y,        8, vp.Y - 228)
        panel.Position = UDim2.fromOffset(px, py)
        screen.Enabled = true
        refresh()
    end
    picker.Open = picker.Toggle
    function picker:OnChange(btnFrame, fn)
        callbacks[btnFrame] = fn
    end
    return picker
end

local colorPicker = buildColorPicker()

local btnA = _G_GUIS["FunGui:colorBtnA"]
local btnB = _G_GUIS["FunGui:colorBtnB"]
local clickA = _G_GUIS["FunGui:colorBtnAClick"]
local clickB = _G_GUIS["FunGui:colorBtnBClick"]
local function bindCircle(btn, click)
    if not btn or not click or not colorPicker then return end
    click.MouseButton1Click:Connect(function() colorPicker:Toggle(btn) end)
    click.ZIndex = 100
    click.Active = true
end
bindCircle(btnA, clickA)
bindCircle(btnB, clickB)

local PRIMARY_BASE   = Color3.fromRGB(57, 64, 89)
local SECONDARY_BASE = Color3.fromRGB(255, 255, 255)
local PRIMARY_40     = Color3.fromRGB(23, 26, 36)
local PRIMARY_30     = Color3.fromRGB(17, 19, 27)
local PRIMARY_12     = Color3.fromRGB(7, 8, 11)
local TAB_SELECTED   = Color3.fromRGB(153, 153, 153)

local Theme = {primary = PRIMARY_BASE, secondary = SECONDARY_BASE}
local themed = {}

local function near(a, b)
    return math.abs(a.R - b.R) < 1/255 + 1e-3
       and math.abs(a.G - b.G) < 1/255 + 1e-3
       and math.abs(a.B - b.B) < 1/255 + 1e-3
end
local function mul(c, k)
    return Color3.new(c.R * k, c.G * k, c.B * k)
end

local function registerNode(d)
    if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextBox") or d:IsA("TextLabel") then
        if near(d.BackgroundColor3, PRIMARY_BASE) then
            table.insert(themed, {kind = "bg", node = d, mult = 1.0})
        elseif near(d.BackgroundColor3, PRIMARY_40) then
            table.insert(themed, {kind = "bg", node = d, mult = 0.40})
        elseif near(d.BackgroundColor3, PRIMARY_30) then
            table.insert(themed, {kind = "bg", node = d, mult = 0.30})
        elseif near(d.BackgroundColor3, PRIMARY_12) then
            table.insert(themed, {kind = "bg", node = d, mult = 0.12})
        end
    elseif d:IsA("UIGradient") then
        local kps = d.Color.Keypoints
        local roles = {}
        local any = false
        for i, kp in ipairs(kps) do
            if near(kp.Value, PRIMARY_BASE) then roles[i] = "P"; any = true
            elseif near(kp.Value, SECONDARY_BASE) then roles[i] = "S"; any = true
            else roles[i] = nil end
        end
        if any then
            local times = {}
            local orig = {}
            for i, kp in ipairs(kps) do times[i] = kp.Time; orig[i] = kp.Value end
            table.insert(themed, {kind = "grad", node = d, times = times, roles = roles, orig = orig})
        end
    end
end

local function registerGui(gui)
    for _, d in ipairs(gui:GetDescendants()) do registerNode(d) end
end

local themeListeners = {}

local function applyTheme()
    local p, s = Theme.primary, Theme.secondary
    local p40 = mul(p, 0.40)
    local p30 = mul(p, 0.30)
    local p12 = mul(p, 0.12)
    for _, e in ipairs(themed) do
        if e.kind == "bg" then
            if e.mult == 1.0 then e.node.BackgroundColor3 = p
            elseif e.mult == 0.40 then e.node.BackgroundColor3 = p40
            elseif e.mult == 0.30 then e.node.BackgroundColor3 = p30
            elseif e.mult == 0.12 then e.node.BackgroundColor3 = p12
            end
        elseif e.kind == "grad" then
            local newKps = {}
            for i, t in ipairs(e.times) do
                local v = e.orig[i]
                if e.roles[i] == "P" then v = p
                elseif e.roles[i] == "S" then v = s end
                newKps[i] = ColorSequenceKeypoint.new(t, v)
            end
            e.node.Color = ColorSequence.new(newKps)
        end
    end
    for _, cb in ipairs(themeListeners) do pcall(cb, p, s) end
end

for name, gui in pairs(_G_GUIS) do
    if not name:find(":") and typeof(gui) == "Instance" and gui:IsA("ScreenGui") then
        registerGui(gui)
    end
end

do
    local saved = _G.FunHubConfig:get("theme", nil)
    if saved then
        if saved.primary then
            Theme.primary = Color3.new(saved.primary[1], saved.primary[2], saved.primary[3])
            if btnA then btnA.BackgroundColor3 = Theme.primary end
        end
        if saved.secondary then
            Theme.secondary = Color3.new(saved.secondary[1], saved.secondary[2], saved.secondary[3])
            if btnB then btnB.BackgroundColor3 = Theme.secondary end
        end
    end
end

local function _persistTheme()
    _G.FunHubConfig:set("theme", {
        primary = {Theme.primary.R, Theme.primary.G, Theme.primary.B},
        secondary = {Theme.secondary.R, Theme.secondary.G, Theme.secondary.B},
    })
end

if btnA then
    colorPicker:OnChange(btnA, function(c)
        Theme.primary = c
        applyTheme()
        _persistTheme()
    end)
end
if btnB then
    colorPicker:OnChange(btnB, function(c)
        Theme.secondary = c
        applyTheme()
        _persistTheme()
    end)
end

local strokeGrads, textGrads = {}, {}
for name, gui in pairs(_G_GUIS) do
    if not name:find(":") and typeof(gui) == "Instance" and gui:IsA("ScreenGui") then
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("UIGradient") then
                if d.Parent and d.Parent:IsA("UIStroke") then
                    table.insert(strokeGrads, d)
                elseif d.Parent and d.Parent:IsA("TextLabel") then
                    table.insert(textGrads, d)
                end
            end
        end
    end
end
local _lastT = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt = now - _lastT
    _lastT = now
    local rotDelta = 240 * dt
    local offDelta = 1.48 * dt
    for _, g in ipairs(strokeGrads) do
        g.Rotation = (g.Rotation + rotDelta) % 360
    end
    for _, g in ipairs(textGrads) do
        local x = g.Offset.X + offDelta
        if x > 1 then x = x - 2 end
        g.Offset = Vector2.new(x, g.Offset.Y)
    end
end)

local Notify = {}
do
    local LP = Players.LocalPlayer
    local screen = n("ScreenGui", {
        Name = "FunHubNotify", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 1500,
    }, LP:WaitForChild("PlayerGui"))
    local holder = n("Frame", {
        Name = "Holder",
        Size = UDim2.fromOffset(380, 300),
        Position = UDim2.new(0, 0, 1, -20),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
    }, screen)
    n("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, holder)
    n("UIPadding", {PaddingLeft = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)}, holder)

    local seq = 0
    function Notify.show(title, subtitle, duration)
        duration = duration or 3
        seq = seq + 1
        local theme = _G.FunHubTheme
        local p = theme and (select(1, theme.get())) or Color3.fromRGB(57,64,89)
        local s = theme and (select(2, theme.get())) or Color3.fromRGB(255,255,255)

        local card = n("Frame", {
            Name = "Notif_"..seq,
            Size = UDim2.fromOffset(0, 56),
            BackgroundColor3 = p,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            LayoutOrder = seq,
            ZIndex = 50,
        }, holder)
        n("UICorner", {CornerRadius = UDim.new(0, 12)}, card)

        local titleLbl = n("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -20, 0, 18),
            Position = UDim2.fromOffset(10, 6),
            BackgroundTransparency = 1, Text = title or "",
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 15,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 51,
        }, card)
        local titleGrad = n("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, p),
                ColorSequenceKeypoint.new(0.5, s),
                ColorSequenceKeypoint.new(1, p),
            }),
        }, titleLbl)

        n("TextLabel", {
            Name = "Sub",
            Size = UDim2.new(1, -20, 0, 24),
            Position = UDim2.fromOffset(10, 30),
            BackgroundTransparency = 1, Text = subtitle or "",
            TextColor3 = Color3.fromRGB(210,225,255), TextSize = 15,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 51,
        }, card)

        local barBg = n("Frame", {
            Name = "BarBg",
            Size = UDim2.new(1, -24, 0, 3),
            Position = UDim2.new(0, 12, 1, -6),
            BackgroundColor3 = s,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            ZIndex = 52,
        }, card)
        n("UICorner", {CornerRadius = UDim.new(1, 0)}, barBg)
        local barFill = n("Frame", {
            Name = "BarFill",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = s,
            BorderSizePixel = 0,
            ZIndex = 53,
        }, barBg)
        n("UICorner", {CornerRadius = UDim.new(1, 0)}, barFill)

        if _G.FunHubThemeListeners then
            local listener
            listener = function(np, ns)
                if not card.Parent then return end
                card.BackgroundColor3 = np
                titleGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, np),
                    ColorSequenceKeypoint.new(0.5, ns),
                    ColorSequenceKeypoint.new(1, np),
                })
                barBg.BackgroundColor3 = ns
                barFill.BackgroundColor3 = ns
            end
            table.insert(_G.FunHubThemeListeners, listener)
        end

        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = UDim2.fromOffset(148, 56)}):Play()
        TweenService:Create(barFill, TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {Size = UDim2.fromScale(0, 1)}):Play()

        task.delay(duration, function()
            TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                {Size = UDim2.fromOffset(0, 56)}):Play()
            task.wait(0.3)
            card:Destroy()
        end)
    end
end
_G.FunHubNotify = Notify

do
    local wm = _G_GUIS["UI_Watermark"]
    if wm then
        local fpsLabel
        for _, d in ipairs(wm:GetDescendants()) do
            if d:IsA("TextLabel") and d.RichText and d.Text:find("FPS:") then
                fpsLabel = d; break
            end
        end
        if fpsLabel then
            local frameCount, lastTick = 0, tick()
            local lastFps = 60
            RunService.Heartbeat:Connect(function()
                frameCount = frameCount + 1
                local now = tick()
                if now - lastTick >= 0.5 then
                    lastFps = math.floor(frameCount / (now - lastTick) + 0.5)
                    frameCount = 0; lastTick = now
                end
            end)
            task.spawn(function()
                while fpsLabel.Parent do
                    local stats = game:GetService("Stats")
                    local ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
                    fpsLabel.Text = string.format(
                        '<font color="rgb(255,255,255)">FPS: </font><font color="rgb(180,180,180)">%d</font><font color="rgb(255,255,255)">  PING: </font><font color="rgb(180,180,180)">%dms</font>',
                        lastFps, ping)
                    task.wait(0.5)
                end
            end)
        end
    end
end

do
    local LP = Players.LocalPlayer
    local screen = n("ScreenGui", {
        Name = "PanelGui_Admin Panel", ResetOnSpawn = false, IgnoreGuiInset = false,
        DisplayOrder = 1000, Enabled = false,
    }, LP:WaitForChild("PlayerGui"))
    _G_GUIS["PanelGui_Admin Panel"] = screen

    local panel = n("Frame", {
        Name = "Frame",
        Size = UDim2.fromOffset(420, 74),
        Position = UDim2.new(0.5, 87, 0.5, 234),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
    }, screen)
    n("UICorner", {CornerRadius = UDim.new(0, 14)}, panel)
    local stroke = n("UIStroke", {Color = Color3.fromRGB(255,255,255), Thickness = 1}, panel)
    n("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(57,64,89)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
        }), Rotation = 90,
    }, stroke)

    local title = n("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(7, 8, 11),
        BorderSizePixel = 0,
    }, panel)
    n("UICorner", {CornerRadius = UDim.new(0, 14)}, title)
    n("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "Admin Panel",
        TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    }, title)
    local minBtn = n("TextButton", {
        Name = "Min",
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -26, 0.5, -11),
        BackgroundColor3 = Color3.fromRGB(23, 26, 36),
        Text = "â€“", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 16,
        Font = Enum.Font.GothamBold,
    }, title)
    n("UICorner", {CornerRadius = UDim.new(1, 0)}, minBtn)

    local content = n("Frame", {
        Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
    }, panel)
    n("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, content)
    local row = n("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
    }, content)
    n("TextLabel", {
        Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = ("%s (@%s)"):format(LP.DisplayName, LP.Name),
        TextColor3 = Color3.fromRGB(220,220,220), TextSize = 13,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local btnRow = n("Frame", {
        Size = UDim2.new(0.7, 0, 1, 0), Position = UDim2.new(0.3, 0, 0, 0),
        BackgroundTransparency = 1,
    }, row)
    n("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 6),
    }, btnRow)
    for _, emoji in ipairs({"ðŸ¤","ðŸ”’","ðŸš€","ðŸ¤¸â€â™‚ï¸","ðŸŽˆ"}) do
        local b = n("TextButton", {
            Size = UDim2.fromOffset(30, 30),
            BackgroundColor3 = Color3.fromRGB(23, 26, 36),
            Text = emoji, TextColor3 = Color3.fromRGB(230,230,230), TextSize = 14,
            Font = Enum.Font.GothamBold,
        }, btnRow)
        n("UICorner", {CornerRadius = UDim.new(0, 4)}, b)
        n("UIStroke", {Color = Color3.fromRGB(255,255,255), Thickness = 1.5}, b)
    end

    _G_GUIS["__pendingDrag"] = _G_GUIS["__pendingDrag"] or {}
    table.insert(_G_GUIS["__pendingDrag"], {title, panel})
    minBtn.MouseButton1Click:Connect(function()
        content.Visible = not content.Visible
        panel.Size = content.Visible and UDim2.fromOffset(420, 74) or UDim2.fromOffset(420, 30)
        minBtn.Text = content.Visible and "â€“" or "+"
    end)
end

do
    local LP = Players.LocalPlayer
    local screen = n("ScreenGui", {
        Name = "AdminSpammerConfig", ResetOnSpawn = false, IgnoreGuiInset = false,
        DisplayOrder = 1000, Enabled = false,
    }, LP:WaitForChild("PlayerGui"))
    _G_GUIS["AdminSpammerConfig"] = screen

    local panel = n("Frame", {
        Size = UDim2.fromOffset(280, 340),
        Position = UDim2.new(0.5, 379, 0.5, 80),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
    }, screen)
    n("UICorner", {CornerRadius = UDim.new(0, 10)}, panel)
    local stk = n("UIStroke", {Color = Color3.fromRGB(255,255,255), Thickness = 1}, panel)
    n("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(57,64,89)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
        }), Rotation = 90,
    }, stk)
    local closeBtn = n("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -26, 0, 4),
        BackgroundColor3 = Color3.fromRGB(160, 40, 40),
        Text = "Ã—", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 16,
        Font = Enum.Font.GothamBold,
    }, panel)
    n("UICorner", {CornerRadius = UDim.new(1, 0)}, closeBtn)
    closeBtn.MouseButton1Click:Connect(function() screen.Enabled = false end)

    local header = n("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.fromOffset(0, 4),
        BackgroundTransparency = 1,
    }, panel)
    n("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = "Command",
        TextColor3 = Color3.fromRGB(160,160,160), TextSize = 12,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    n("TextLabel", {
        Size = UDim2.fromOffset(60, 28), Position = UDim2.new(1, -150, 0, 0),
        BackgroundTransparency = 1, Text = "Click 1",
        TextColor3 = Color3.fromRGB(255,192,67), TextSize = 12, Font = Enum.Font.GothamBold,
    }, header)
    n("TextLabel", {
        Size = UDim2.fromOffset(60, 28), Position = UDim2.new(1, -85, 0, 0),
        BackgroundTransparency = 1, Text = "Click 2",
        TextColor3 = Color3.fromRGB(159,72,72), TextSize = 12, Font = Enum.Font.GothamBold,
    }, header)

    local scroll = n("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -30), Position = UDim2.fromOffset(4, 26),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)
    n("UIListLayout", {Padding = UDim.new(0, 4)}, scroll)

    local commands = {"rocket","ragdoll","balloon","inverse","nightvision","jail","control","tiny","jumpscare","morph"}
    local saved = _G.FunHubConfig:get("spammer", {})
    local config = {}
    for _, cmd in ipairs(commands) do
        config[cmd] = saved[cmd] or 1
    end
    _G.FunHubSpammerConfig = config

    for _, cmd in ipairs(commands) do
        local row = n("Frame", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
        }, scroll)
        n("TextLabel", {
            Size = UDim2.new(1, -140, 1, 0), Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1, Text = cmd,
            TextColor3 = Color3.fromRGB(210,225,255), TextSize = 13,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local slot1 = n("TextButton", {
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.new(1, -126, 0, 3),
            BackgroundColor3 = Color3.fromRGB(40,160,40),
            Text = "âœ“", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13,
            Font = Enum.Font.GothamBold,
        }, row)
        n("UICorner", {CornerRadius = UDim.new(0, 4)}, slot1)
        local slot2 = n("TextButton", {
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.new(1, -66, 0, 3),
            BackgroundColor3 = Color3.fromRGB(40,160,40),
            Text = "âœ“", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13,
            Font = Enum.Font.GothamBold,
        }, row)
        n("UICorner", {CornerRadius = UDim.new(0, 4)}, slot2)
        local function refresh()
            if config[cmd] == 1 then
                slot1.BackgroundColor3 = Color3.fromRGB(40,160,40); slot1.Text = "âœ“"
                slot2.BackgroundColor3 = Color3.fromRGB(160,40,40); slot2.Text = "X"
            else
                slot1.BackgroundColor3 = Color3.fromRGB(160,40,40); slot1.Text = "X"
                slot2.BackgroundColor3 = Color3.fromRGB(40,160,40); slot2.Text = "âœ“"
            end
        end
        local function save()
            local s = _G.FunHubConfig:get("spammer", {})
            s[cmd] = config[cmd]
            _G.FunHubConfig:set("spammer", s)
        end
        slot1.MouseButton1Click:Connect(function() config[cmd] = 1; refresh(); save() end)
        slot2.MouseButton1Click:Connect(function() config[cmd] = 2; refresh(); save() end)
        refresh()
    end
end

do
    local LP = Players.LocalPlayer
    local sp = LP.PlayerGui:FindFirstChild("PanelGui_Fun Admin Spammer")
    if sp then _G_GUIS["PanelGui_Fun Admin Spammer"] = sp end
end

do
    local LP = Players.LocalPlayer
    local sp = LP.PlayerGui:FindFirstChild("PanelGui_Fun Admin Spammer")
    if not sp then return end
    local frame = sp:FindFirstChildOfClass("Frame")
    local title = frame and frame:FindFirstChildOfClass("Frame")
    if title then
        for _, b in ipairs(title:GetChildren()) do
            if b:IsA("TextButton") and (b.Text == "âš™" or b.Text == "âš™ï¸") then
                b.MouseButton1Click:Connect(function()
                    local cfg = LP.PlayerGui:FindFirstChild("AdminSpammerConfig")
                    if cfg then cfg.Enabled = not cfg.Enabled end
                end)
            end
        end
    end

    local frames = {}
    for _, c in ipairs(frame:GetChildren()) do
        if c:IsA("Frame") then table.insert(frames, c) end
    end
    local content = frames[2]
    if not content then return end

    local emptyLabel
    local templateRow
    for _, c in ipairs(content:GetChildren()) do
        if c:IsA("TextLabel") and c.Text:lower():find("no target") then
            emptyLabel = c
        elseif c:IsA("TextButton") and c.Size.Y.Offset == 44 then
            templateRow = c
        end
    end

    if not templateRow then
        templateRow = n("TextButton", {
            Size = UDim2.new(1, -6, 0, 44),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0.1, Text = "", AutoButtonColor = false,
        }, content)
        n("UICorner", {CornerRadius = UDim.new(0, 8)}, templateRow)
        n("UIStroke", {Color = Color3.fromRGB(255,255,255), Thickness = 0}, templateRow)
        n("ImageLabel", {
            Name = "Avatar", Size = UDim2.fromOffset(32, 32),
            Position = UDim2.new(0, 6, 0.5, -16),
            BackgroundTransparency = 1,
        }, templateRow)
        n("TextLabel", {
            Name = "DName", Size = UDim2.new(1, -50, 0, 20),
            Position = UDim2.fromOffset(44, 4),
            BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 14, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, templateRow)
        n("TextLabel", {
            Name = "UName", Size = UDim2.new(1, -50, 0, 16),
            Position = UDim2.fromOffset(44, 22),
            BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(160,160,160),
            TextSize = 12, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, templateRow)
    end
    templateRow.Visible = false

    if not content:FindFirstChildOfClass("UIListLayout") then
        n("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.Name,
        }, content)
    end

    local rowsByPlayer = {}
    _G.FunHubSelectedTarget = nil

    local function makeRow(plr)
        if plr == LP then return end
        local row = templateRow:Clone()
        row.Name = "P_"..plr.UserId
        row.Visible = true
        row.Parent = content
        local av = row:FindFirstChild("Avatar")
        if not av then
            for _, ch in ipairs(row:GetDescendants()) do
                if ch:IsA("ImageLabel") then av = ch; break end
            end
        end
        if av then
            av.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=100&h=100"):format(plr.UserId)
        end
        local labels = {}
        for _, ch in ipairs(row:GetDescendants()) do
            if ch:IsA("TextLabel") then table.insert(labels, ch) end
        end
        if labels[1] then labels[1].Text = plr.DisplayName end
        if labels[2] then labels[2].Text = "(@"..plr.Name..")" end

        local stroke = row:FindFirstChildOfClass("UIStroke")
        if not stroke then
            stroke = n("UIStroke", {
                Color = Color3.fromRGB(255, 255, 255),
                Thickness = 0,
                Transparency = 0.2,
            }, row)
        end

        local function setStroke(thick)
            stroke.Thickness = thick
        end

        if row:IsA("TextButton") then
            row.MouseEnter:Connect(function()
                if _G.FunHubSelectedTarget ~= plr then setStroke(1) end
            end)
            row.MouseLeave:Connect(function()
                if _G.FunHubSelectedTarget ~= plr then setStroke(0) end
            end)
            row.MouseButton1Click:Connect(function()
                _G.FunHubSelectedTarget = plr
                for p2, r2 in pairs(rowsByPlayer) do
                    local sk = r2:FindFirstChildOfClass("UIStroke")
                    if sk then sk.Thickness = (p2 == plr) and 1.5 or 0 end
                end
            end)
        end
        rowsByPlayer[plr] = row
    end

    local function refresh()
        if emptyLabel then
            emptyLabel.Visible = (next(rowsByPlayer) == nil)
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do makeRow(plr) end
    refresh()
    Players.PlayerAdded:Connect(function(p) makeRow(p); refresh() end)
    Players.PlayerRemoving:Connect(function(p)
        local r = rowsByPlayer[p]
        if r then r:Destroy(); rowsByPlayer[p] = nil end
        refresh()
    end)
end

_G.FunHubTheme = {
    setPrimary = function(c)
        Theme.primary = c
        if btnA then btnA.BackgroundColor3 = c end
        applyTheme()
    end,
    setSecondary = function(c)
        Theme.secondary = c
        if btnB then btnB.BackgroundColor3 = c end
        applyTheme()
    end,
    get = function() return Theme.primary, Theme.secondary end,
}
_G.FunHubThemeListeners = themeListeners

local Behavior = {}

function Behavior.makeDraggable(handle, target, saveKey)
    local dragging, dragStart, startPos
    handle.Active = true
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local positions = _G.FunHubConfig:get("positions", {})
                        positions[saveKey] = {
                            target.Position.X.Scale, target.Position.X.Offset,
                            target.Position.Y.Scale, target.Position.Y.Offset,
                        }
                        _G.FunHubConfig:set("positions", positions)
                    end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    if saveKey then
        local positions = _G.FunHubConfig:get("positions", {})
        local p = positions[saveKey]
        if p then
            target.Position = UDim2.new(p[1], p[2], p[3], p[4])
        end
    end
end

function Behavior.wireMinimize(btn, panel, contentArea)
    local originalSize = panel.Size
    local collapsedY = contentArea.Position.Y.Offset
    local minimized = false
    btn.MouseButton1Click:Connect(function()
        minimized = not minimized
        contentArea.Visible = not minimized
        if minimized then
            panel.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset,
                                   0, collapsedY)
            btn.Text = "+"
        else
            panel.Size = originalSize
            btn.Text = "â€“"
        end
    end)
end

local TOGGLE_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local _toggleStates = {}

local function _toggleColor(state)
    local theme = _G.FunHubTheme
    local p = Color3.fromRGB(57, 64, 89)
    if theme then p = (select(1, theme.get())) end
    local m = state and 0.40 or 0.30
    return Color3.new(p.R * m, p.G * m, p.B * m)
end

local TOGGLE_TO_GUI = {
    ["Instant Steal Panel"]    = "PanelGui_Instant Steal",
    ["Instant Steal Panel V2"] = "PanelGui_Instant Steal V2",
    ["Booster GUI"]            = "PanelGui_Booster",
    ["Admin Spammer"]          = "PanelGui_Fun Admin Spammer",
    ["Quick Admin Panel"]      = "PanelGui_Admin Panel",
    ["Command Cooldowns"]      = "PanelGui_Command Cooldowns",
    ["Defense Panel"]          = "PanelGui_Fun Defense",
    ["Allow Friends"]          = "AllowFriendsGui",
    ["Unlock Base"]            = "UnlockBaseGui",
}

function Behavior.wireToggle(pill)
    local knob
    for _, ch in ipairs(pill:GetChildren()) do
        if ch:IsA("Frame") and ch.Size.X.Offset > 0 and ch.Size.X.Offset < pill.Size.X.Offset then
            knob = ch; break
        end
    end
    local function findBtn(scope)
        for _, ch in ipairs(scope:GetChildren()) do
            if ch:IsA("TextButton") and ch.Text == "" and ch.BackgroundTransparency >= 0.9 then
                return ch
            end
        end
    end
    local row = pill.Parent
    local clickBtn = findBtn(pill) or (row and findBtn(row))
    if not knob or not clickBtn then return end

    local labelText
    if row then
        for _, ch in ipairs(row:GetChildren()) do
            if ch:IsA("TextLabel") and ch.Text ~= "" then labelText = ch.Text; break end
        end
    end
    local linkedGui
    if labelText then
        local target = TOGGLE_TO_GUI[labelText]
        if target then
            linkedGui = Players.LocalPlayer.PlayerGui:FindFirstChild(target)
        end
    end

    local entry = {state = false, knob = knob, pill = pill}
    _toggleStates[pill] = entry

    local function apply(animate)
        local goalBG = _toggleColor(entry.state)
        local goalPos = entry.state
            and UDim2.new(1, -20, 0.5, -9)
            or  UDim2.new(0, 2,   0.5, -9)
        if animate then
            TweenService:Create(pill, TOGGLE_TWEEN, {BackgroundColor3 = goalBG}):Play()
            TweenService:Create(knob, TOGGLE_TWEEN, {Position = goalPos}):Play()
        else
            pill.BackgroundColor3 = goalBG
            knob.Position = goalPos
        end
        if linkedGui then linkedGui.Enabled = entry.state end
    end

    local savedToggles = _G.FunHubConfig:get("toggles", {})
    if labelText then
        if savedToggles[labelText] ~= nil then entry.state = savedToggles[labelText] end
    end
    apply(false)

    local rowLabel
    if row then
        for _, c in ipairs(row:GetChildren()) do
            if c:IsA("TextLabel") and c.Text ~= "" then rowLabel = c; break end
        end
    end
    local baseLabelText = rowLabel and rowLabel.Text or labelText
    local function refreshLabel()
        if not rowLabel then return end
        local kb = _G.FunHubConfig:get("keybinds", {})
        local key = labelText and kb[labelText]
        if key then
            rowLabel.Text = baseLabelText .. ' <font color="rgb(140,140,160)">('..key..')</font>'
            rowLabel.RichText = true
        else
            rowLabel.Text = baseLabelText
        end
    end
    refreshLabel()

    local function fire()
        entry.state = not entry.state
        apply(true)
        if labelText then
            local t = _G.FunHubConfig:get("toggles", {})
            t[labelText] = entry.state
            _G.FunHubConfig:set("toggles", t)
            if _G.FunHubNotify then
                _G.FunHubNotify.show(labelText, entry.state and "On" or "Off")
            end
        end
    end
    clickBtn.MouseButton1Click:Connect(fire)

    if labelText then
        clickBtn.MouseButton2Click:Connect(function()
            if rowLabel then
                rowLabel.RichText = true
                rowLabel.Text = baseLabelText .. ' <font color="rgb(140,140,160)">(...)</font>'
            end
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                local kb = _G.FunHubConfig:get("keybinds", {})
                if input.KeyCode == Enum.KeyCode.Backspace then
                    kb[labelText] = nil
                else
                    kb[labelText] = input.KeyCode.Name
                end
                _G.FunHubConfig:set("keybinds", kb)
                refreshLabel()
            end)
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local kb = _G.FunHubConfig:get("keybinds", {})
            if kb[labelText] and input.KeyCode.Name == kb[labelText] then
                fire()
            end
        end)
    end
end

table.insert(themeListeners, function()
    for pill, e in pairs(_toggleStates) do
        if pill.Parent then
            pill.BackgroundColor3 = _toggleColor(e.state)
        end
    end
end)

local DEFAULT_ACTIONS = {
    ["Rejoin"]              = function() return "Rejoining serverâ€¦" end,
    ["Kick Self"]           = function() return "Goodbye" end,
    ["Ragdoll Self"]        = function() return "Ragdolled" end,
    ["Reset Character"]     = function() return "Reset" end,
    ["Instant Reset"]       = function() return "Instant reset" end,
    ["Execute"]             = function() return "Executed" end,
    ["Execute (Full)"]      = function() return "Executed (Full)" end,
    ["Activate (Reset)"]    = function() return "Activated" end,
    ["Spam Closest"]        = function() return "Spamming closest" end,
    ["Align (Semi)"]        = function() return "Aligned" end,
    ["TP To Brainrot (Semi)"] = function() return "Teleporting" end,
    ["Full Mode"]           = function() return "Full mode" end,
    ["Semi Mode"]           = function() return "Semi mode" end,
}

function Behavior.wirePanelActionBtn(btn, lbl)
    local baseText = lbl.Text:gsub("%s*<font[^>]*>%(.-%)</font>%s*$", "")
    local function refresh()
        local kb = _G.FunHubConfig:get("keybinds", {})
        local key = kb[baseText]
        if key then
            lbl.RichText = true
            lbl.Text = baseText .. ' <font color="rgb(140,140,160)">('..key..')</font>'
        else
            lbl.Text = baseText
        end
    end
    refresh()

    local function fire()
        local action = DEFAULT_ACTIONS[baseText]
        local msg
        if action then
            local ok, res = pcall(action)
            if ok then msg = res end
        end
        if _G.FunHubNotify then
            _G.FunHubNotify.show(baseText, msg or "Activated")
        end
    end
    btn.MouseButton1Click:Connect(fire)
    btn.MouseButton2Click:Connect(function()
            lbl.RichText = true
            lbl.Text = baseText .. ' <font color="rgb(140,140,160)">(...)</font>'
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, processed)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                local kb = _G.FunHubConfig:get("keybinds", {})
                if input.KeyCode == Enum.KeyCode.Backspace then
                    kb[baseText] = nil
                else
                    kb[baseText] = input.KeyCode.Name
                end
                _G.FunHubConfig:set("keybinds", kb)
                refresh()
            end)
        end)
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local kb = _G.FunHubConfig:get("keybinds", {})
        if kb[baseText] and input.KeyCode.Name == kb[baseText] then
            fire()
        end
    end)
end

function Behavior.wireRightClickBind(btn, opts)
    opts = opts or {}
    if not btn:IsA("TextButton") then return end
    local labelText = btn.Text and btn.Text:match("^%s*(.-)%s*$") or ""
    if labelText == "" then return end
    local baseText = labelText:gsub("%s*<font[^>]*>%(.-%)</font>%s*$", "")
    local function refresh()
        local kb = _G.FunHubConfig:get("keybinds", {})
        local key = kb[baseText]
        if key then
            btn.RichText = true
            btn.Text = baseText .. ' <font color="rgb(140,140,160)">('..key..')</font>'
        else
            btn.Text = baseText
        end
    end
    refresh()

    local function fire()
        local action = DEFAULT_ACTIONS[baseText]
        local msg
        if action then
            local ok, res = pcall(action)
            if ok then msg = res end
        end
        if not opts.suppressNotify and _G.FunHubNotify then
            _G.FunHubNotify.show(baseText, msg or "Activated")
        end
    end

    btn.MouseButton1Click:Connect(fire)
    btn.MouseButton2Click:Connect(function()
            btn.RichText = true
            btn.Text = baseText .. ' <font color="rgb(140,140,160)">(...)</font>'
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, processed)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                local kb = _G.FunHubConfig:get("keybinds", {})
                if input.KeyCode == Enum.KeyCode.Backspace then
                    kb[baseText] = nil
                else
                    kb[baseText] = input.KeyCode.Name
                end
                _G.FunHubConfig:set("keybinds", kb)
                refresh()
            end)
        end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local kb = _G.FunHubConfig:get("keybinds", {})
        if kb[baseText] and input.KeyCode.Name == kb[baseText] then
            fire()
        end
    end)
end

function Behavior.wireAllToggles(root)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("Frame") then
            local corner = d:FindFirstChildOfClass("UICorner")
            if corner and corner.CornerRadius == UDim.new(1, 0)
                and d.Size.X.Offset >= 30 and d.Size.X.Offset <= 60
                and d.Size.Y.Offset >= 16 and d.Size.Y.Offset <= 28 then
                local hasKnob = false
                for _, k in ipairs(d:GetChildren()) do
                    if k:IsA("Frame") then
                        local kc = k:FindFirstChildOfClass("UICorner")
                        if kc and kc.CornerRadius == UDim.new(1, 0) then
                            hasKnob = true; break
                        end
                    end
                end
                if hasKnob then Behavior.wireToggle(d) end
            end
        end
    end
end

function Behavior.wirePanel(screenGui)
    local panel = screenGui:FindFirstChildOfClass("Frame")
    if not panel then return end

    local titleBar, contentArea
    for _, ch in ipairs(panel:GetChildren()) do
        if ch:IsA("Frame") then
            if not titleBar then titleBar = ch
            elseif not contentArea then contentArea = ch end
        end
    end
    if titleBar then
        Behavior.makeDraggable(titleBar, panel, screenGui.Name)

        for _, ch in ipairs(titleBar:GetChildren()) do
            if ch:IsA("TextButton") then
                local t = ch.Text
                if t == "-" or t == "â€“" or t == "â€”" then
                    if contentArea then
                        Behavior.wireMinimize(ch, panel, contentArea)
                    end
                    break
                end
            end
        end
    end

    for _, d in ipairs(panel:GetDescendants()) do
        if d:IsA("Frame") then
            local corner = d:FindFirstChildOfClass("UICorner")
            if corner and corner.CornerRadius == UDim.new(1, 0)
                and d.Size.X.Offset >= 30 and d.Size.X.Offset <= 60
                and d.Size.Y.Offset >= 16 and d.Size.Y.Offset <= 28 then
                local hasKnob = false
                for _, k in ipairs(d:GetChildren()) do
                    if k:IsA("Frame") then
                        local kc = k:FindFirstChildOfClass("UICorner")
                        if kc and kc.CornerRadius == UDim.new(1, 0) then
                            hasKnob = true; break
                        end
                    end
                end
                if hasKnob then Behavior.wireToggle(d) end
            end
        end
    end

    if contentArea then
        for _, d in ipairs(contentArea:GetDescendants()) do
            if d:IsA("TextButton") then
                local t = d.Text

                if d.Name:sub(1, 2) == "P_" or (not d.Visible) then

                elseif t == "" then

                    local hasToggle = false
                    for _, sib in ipairs(d.Parent:GetChildren()) do
                        if sib:IsA("Frame") and sib.Size.X.Offset == 42
                            and sib.Size.Y.Offset == 22 then
                            local cn = sib:FindFirstChildOfClass("UICorner")
                            if cn and cn.CornerRadius == UDim.new(1, 0) then
                                hasToggle = true; break
                            end
                        end
                    end
                    if not hasToggle then
                        for _, sib in ipairs(d.Parent:GetChildren()) do
                            if sib:IsA("TextLabel") and sib.Text ~= "" then
                                Behavior.wirePanelActionBtn(d, sib)
                                break
                            end
                        end
                    end
                elseif t ~= "â€“" and t ~= "+" and t ~= "Ã—" and t ~= "X" and t ~= "âœ“"
                    and t ~= "âš™" and t ~= "âš™ï¸" then
                    Behavior.wireRightClickBind(d)
                end
            end
        end
    end
end

for name, gui in pairs(_G_GUIS) do
    if not name:find(":") and typeof(gui) == "Instance" and gui:IsA("ScreenGui") then
        gui.DisplayOrder = math.max(gui.DisplayOrder, 1000)
    end
end

if _G_GUIS["__pendingDrag"] then
    for _, pair in ipairs(_G_GUIS["__pendingDrag"]) do
        Behavior.makeDraggable(pair[1], pair[2])
    end
    _G_GUIS["__pendingDrag"] = nil
end

for name, gui in pairs(_G_GUIS) do
    if not name:find(":") and typeof(gui) == "Instance" and gui:IsA("ScreenGui") then
        if name ~= "FunGui" then
            Behavior.wirePanel(gui)
        else
            Behavior.wireAllToggles(gui)

            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextButton") and d.Text ~= ""
                    and d:FindFirstAncestorOfClass("ScrollingFrame") then
                    Behavior.wireRightClickBind(d)
                end
            end
        end
    end
end

do
    local funGui = _G_GUIS["FunGui"]
    if funGui then
        local mainFrame = funGui:FindFirstChildOfClass("Frame")
        local funBtn
        for _, ch in ipairs(funGui:GetChildren()) do
            if ch:IsA("TextButton") and ch.Text == "Fun" then funBtn = ch end
        end

        if mainFrame then

            local scale
            for _, ch in ipairs(mainFrame:GetChildren()) do
                if ch:IsA("UIScale") then scale = ch end
            end
            mainFrame.Visible = true
            if scale then scale.Scale = 1e-07 end

            local header = mainFrame:FindFirstChildOfClass("Frame")
            if header then Behavior.makeDraggable(header, mainFrame) end

            local panelOpen = false
            local function setPanelOpen(v)
                panelOpen = v
                local goal = {Scale = panelOpen and 1 or 1e-07}
                TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Quad), goal):Play()
            end
            if funBtn and scale then
                Behavior.makeDraggable(funBtn, funBtn)
                funBtn.MouseButton1Click:Connect(function()
                    setPanelOpen(not panelOpen)
                end)
            end
            if scale then
                UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if input.KeyCode == Enum.KeyCode.LeftControl
                        or input.KeyCode == Enum.KeyCode.RightControl then
                        setPanelOpen(not panelOpen)
                    end
                end)
            end

            local tabRow, pagesContainer
            for _, ch in ipairs(mainFrame:GetChildren()) do
                if ch:IsA("Frame") and ch:FindFirstChildOfClass("UIListLayout")
                    and ch.Size.Y.Offset == 36 then
                    tabRow = ch
                end
            end

            for _, ch in ipairs(mainFrame:GetChildren()) do
                if ch:IsA("Frame") and not ch:FindFirstChildOfClass("UIListLayout") then
                    local sfCount = 0
                    for _, p in ipairs(ch:GetChildren()) do
                        if p:IsA("ScrollingFrame") then sfCount = sfCount + 1 end
                    end
                    if sfCount >= 2 then pagesContainer = ch; break end
                end
            end

            local pages = {}
            if pagesContainer then
                for _, p in ipairs(pagesContainer:GetChildren()) do
                    if p:IsA("ScrollingFrame") then table.insert(pages, p) end
                end
            end

            for _, page in ipairs(pages) do
                page.AutomaticCanvasSize = Enum.AutomaticSize.Y
                page.ScrollBarThickness = 4
                for _, d in ipairs(page:GetDescendants()) do

                    if d:IsA("Frame") and d.Size.Y.Scale == 0 and d.Size.Y.Offset <= 30 then
                        local safe = true
                        for _, c in ipairs(d:GetChildren()) do
                            if c:IsA("GuiObject") and c.Size.Y.Scale > 0 then
                                safe = false; break
                            end
                        end
                        if safe then
                            d.AutomaticSize = Enum.AutomaticSize.Y
                        end
                    end
                end
            end

            if tabRow then
                local tabs = {}
                for _, b in ipairs(tabRow:GetChildren()) do
                    if b:IsA("TextButton") then

                        b.Size = UDim2.new(0, 75, 1, 0)
                        b.Position = UDim2.new(0, 0, 0, 4)
                        table.insert(tabs, b)
                    end
                end
                local currentIdx = 1
                local function paintTabs()
                    local theme = _G.FunHubTheme
                    local p, s
                    if theme then p, s = theme.get() end
                    p = p or Color3.fromRGB(57, 64, 89)
                    s = s or Color3.fromRGB(255, 255, 255)
                    local unsel = Color3.new(p.R * 0.40, p.G * 0.40, p.B * 0.40)
                    local sel   = Color3.new(s.R * 0.60, s.G * 0.60, s.B * 0.60)
                    for i, b in ipairs(tabs) do
                        b.BackgroundColor3 = (i == currentIdx) and sel or unsel
                    end
                end
                local function selectTab(idx)
                    currentIdx = idx
                    for i, p2 in ipairs(pages) do p2.Visible = (i == idx) end
                    paintTabs()
                end

                if _G.FunHubThemeListeners then
                    table.insert(_G.FunHubThemeListeners, paintTabs)
                end
                for i, b in ipairs(tabs) do
                    b.MouseButton1Click:Connect(function() selectTab(i) end)
                end
                selectTab(1)
            end
        end
    end
end

_G.FunHubGUIs = _G_GUIS
_G.FunHubColorPicker = colorPicker
