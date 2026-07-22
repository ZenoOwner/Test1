local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")

local lp        = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")
if not lp.Character then lp.CharacterAdded:Wait() end

pcall(function()
    if CoreGui:FindFirstChild("GrassGui") then CoreGui.GrassGui:Destroy() end
    if playerGui:FindFirstChild("GrassGui") then playerGui.GrassGui:Destroy() end
end)

local CFG = {
    autoWater  = false,
    waterRange = 20,
    buyWater   = false,
    buyNature  = false,
    targetCan  = "Good Watering Can",
    targetNature = "Small Tree",
}

local function getHRP()
    local c = lp.Character; if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function tpTo(pos)
    local hrp = getHRP(); if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0,4,0))
    task.wait(0.1)
end

local function safeFirePrompt(pp)
    if not pp or not pp.Parent then return end
    pcall(function()
        if fireproximityprompt then fireproximityprompt(pp) end
    end)
    pcall(function()
        if getconnections then
            local ok, conns = pcall(getconnections, pp.Triggered)
            if ok and conns then
                for _, c in ipairs(conns) do
                    if c.Function then pcall(c.Function) end
                end
            end
        end
    end)
end

local function clickGuiButton(btn)
    if not btn then return end
    pcall(function() btn.MouseButton1Click:Fire() end)
    pcall(function()
        if getconnections then
            local ok, conns = pcall(getconnections, btn.MouseButton1Click)
            if ok and conns then
                for _, c in ipairs(conns) do
                    if c.Function then pcall(c.Function) end
                end
            end
        end
    end)
    pcall(function() btn.Activated:Fire() end)
end

local function getDeadGrass()
    local tiles = {}
    local hrp = getHRP()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            local n = v.Name:lower()
            local col = v.Color
            local isDead = false
            if n:find("grass") or n:find("tile") or n:find("plot") or n:find("ground") or n:find("soil") or n:find("dirt") then
                if col.R > 0.35 and col.G < 0.28 and col.B < 0.18 then
                    isDead = true
                end
                if math.abs(col.R - 0.55) < 0.15 and math.abs(col.G - 0.35) < 0.15 and col.B < 0.2 then
                    isDead = true
                end
            end
            if v.BrickColor == BrickColor.new("Reddish brown") or
               v.BrickColor == BrickColor.new("Brown") or
               v.BrickColor == BrickColor.new("Dark orange") or
               v.BrickColor == BrickColor.new("Nougat") then
                if n:find("grass") or n:find("tile") or n:find("plot") or n:find("square") then
                    isDead = true
                end
            end
            if isDead then
                local pos = v.Position
                if hrp then
                    local d = (hrp.Position - pos).Magnitude
                    table.insert(tiles, {part=v, dist=d})
                else
                    table.insert(tiles, {part=v, dist=0})
                end
            end
        end
    end
    table.sort(tiles, function(a,b) return a.dist < b.dist end)
    local out = {}
    for _, t in ipairs(tiles) do table.insert(out, t.part) end
    return out
end

local function findWaterPrompt(part)
    if not part or not part.Parent then return nil end
    for _, v in ipairs(part:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local a = (v.ActionText or ""):lower()
            if a:find("water") or a:find("fill") or a == "" then return v end
        end
    end
    local par = part.Parent
    if par then
        for _, v in ipairs(par:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local a = (v.ActionText or ""):lower()
                if a:find("water") or a:find("fill") then return v end
            end
        end
    end
    return nil
end

local function getEquippedCan()
    local char = lp.Character; if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("watering") then return t end
    end
    local bp = lp:FindFirstChild("Backpack"); if not bp then return nil end
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("watering") then return t end
    end
    return nil
end

local function equipCan()
    local char = lp.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local bp = lp:FindFirstChild("Backpack"); if not bp then return false end
    local can = bp:FindFirstChild(CFG.targetCan) or bp:FindFirstChildWhichIsA("Tool")
    if can then hum:EquipTool(can); task.wait(0.1); return true end
    return false
end

local function waterTile(part)
    if not part or not part.Parent then return end
    local hrp = getHRP(); if not hrp then return end
    local dist = (hrp.Position - part.Position).Magnitude
    if dist > CFG.waterRange then
        tpTo(part.Position)
    end
    local pp = findWaterPrompt(part)
    if pp then safeFirePrompt(pp); return end
    local can = getEquippedCan()
    if not can then equipCan(); can = getEquippedCan() end
    if can then
        pcall(function() can:Activate() end)
        for _, r in ipairs(can:GetDescendants()) do
            if r:IsA("RemoteEvent") then pcall(function() r:FireServer(part) end) end
            if r:IsA("RemoteFunction") then pcall(function() r:InvokeServer(part) end) end
        end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local a = (v.ActionText or ""):lower()
            if a:find("water") then
                local vp = v.Parent and v.Parent:IsA("BasePart") and v.Parent.Position or nil
                if vp and (vp - part.Position).Magnitude < 5 then
                    safeFirePrompt(v); return
                end
            end
        end
    end
end

local _autoWaterConn = nil
local function stopAutoWater()
    CFG.autoWater = false
    if _autoWaterConn then _autoWaterConn:Disconnect(); _autoWaterConn = nil end
end

local function startAutoWater()
    if _autoWaterConn then return end
    CFG.autoWater = true
    task.spawn(function()
        while CFG.autoWater do
            local tiles = getDeadGrass()
            if #tiles == 0 then task.wait(2); continue end
            equipCan()
            for _, tile in ipairs(tiles) do
                if not CFG.autoWater then break end
                if not tile.Parent then continue end
                waterTile(tile)
                task.wait(0.15)
            end
            task.wait(0.5)
        end
    end)
end

local function openShop(shopName)
    pcall(function()
        local shop = workspace:FindFirstChild("Shop")
        if not shop then return end
        local itemShop = shop:FindFirstChild("ItemShop") or shop:FindFirstChild(shopName)
        if itemShop then
            for _, pp in ipairs(itemShop:GetDescendants()) do
                if pp:IsA("ProximityPrompt") then safeFirePrompt(pp); return end
            end
        end
    end)
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local a = (v.ActionText or ""):lower()
                if a:find("shop") or a:find("buy") or a:find("store") then
                    safeFirePrompt(v)
                end
            end
        end
    end)
end

local function buyWateringCan(canName)
    openShop("ItemShop")
    task.wait(0.5)
    pcall(function()
        local pg = playerGui
        for _, gui in ipairs(pg:GetChildren()) do
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local t = (v.Name or "")
                    if t == canName or t:find(canName:sub(1,6)) then
                        clickGuiButton(v); return
                    end
                    local parent = v.Parent
                    if parent and (parent.Name == canName or (parent:FindFirstChild("Title") and parent:FindFirstChild("Title").Text == canName)) then
                        clickGuiButton(v); return
                    end
                end
            end
        end
    end)
    pcall(function()
        local canModels = ReplicatedStorage:FindFirstChild("CanModels")
        if not canModels then return end
        local target = canModels:FindFirstChild(canName)
        if target then
            for _, re in ipairs(ReplicatedStorage:GetDescendants()) do
                if re:IsA("RemoteEvent") then
                    local n = re.Name:lower()
                    if n:find("buy") or n:find("purchase") or n:find("shop") then
                        pcall(function() re:FireServer(canName) end)
                        pcall(function() re:FireServer(target) end)
                    end
                end
                if re:IsA("RemoteFunction") then
                    local n = re.Name:lower()
                    if n:find("buy") or n:find("purchase") or n:find("shop") then
                        pcall(function() re:InvokeServer(canName) end)
                    end
                end
            end
        end
    end)
end

local function buyNatureItem(itemName)
    pcall(function()
        local ns = playerGui:FindFirstChild("NatureStore")
        if not ns then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local a = (v.ActionText or ""):lower()
                    if a:find("nature") or a:find("store") or a:find("plant") then
                        safeFirePrompt(v)
                        task.wait(0.4)
                        break
                    end
                end
            end
        end
        ns = playerGui:FindFirstChild("NatureStore")
        if not ns then return end
        local frame = ns:FindFirstChild("Frame") or ns:FindFirstChild("NatureShop") or ns:FindFirstChildWhichIsA("Frame")
        if not frame then return end
        local scroll = frame:FindFirstChild("ScrollingFrame") or frame:FindFirstChildWhichIsA("ScrollingFrame")
        if not scroll then return end
        local item = scroll:FindFirstChild(itemName)
        if not item then return end
        local buyBtn = item:FindFirstChild("BuyButton") or item:FindFirstChildWhichIsA("TextButton")
        if not buyBtn then
            local fr = item:FindFirstChild("Frame")
            if fr then buyBtn = fr:FindFirstChildWhichIsA("TextButton") end
        end
        if buyBtn then clickGuiButton(buyBtn) end
    end)
end

local function removeNearbyNature()
    local hrp = getHRP(); if not hrp then return end
    local REMOVE_NAMES = {"boulder","tree","pine","bush","rock","flower","plant","shrub","log","stone"}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local a = (v.ActionText or ""):lower()
            if a:find("remove") or a:find("sell") or a:find("delete") or a:find("pickup") or a:find("pick up") then
                local partPos = v.Parent and v.Parent.Position
                if partPos and (hrp.Position - partPos).Magnitude < 15 then
                    safeFirePrompt(v)
                end
            end
        end
        if (v:IsA("BasePart") or v:IsA("Model")) then
            local n = v.Name:lower()
            local isNature = false
            for _, kw in ipairs(REMOVE_NAMES) do if n:find(kw) then isNature=true; break end end
            if isNature then
                local pos = v:IsA("Model") and (v.PrimaryPart and v.PrimaryPart.Position) or v.Position
                if pos and (hrp.Position - pos).Magnitude < 15 then
                    for _, pp in ipairs(v:GetDescendants()) do
                        if pp:IsA("ProximityPrompt") then safeFirePrompt(pp) end
                    end
                end
            end
        end
    end
end

local T = {
    bg    = Color3.fromRGB(5,8,5),
    panel = Color3.fromRGB(8,12,8),
    surf  = Color3.fromRGB(12,18,12),
    surf2 = Color3.fromRGB(18,26,18),
    acc   = Color3.fromRGB(60,200,80),
    acc2  = Color3.fromRGB(40,160,55),
    white = Color3.new(1,1,1),
    dim   = Color3.fromRGB(90,110,90),
    str   = Color3.fromRGB(50,170,65),
    red   = Color3.fromRGB(255,65,65),
    grn   = Color3.fromRGB(52,218,88),
    yel   = Color3.fromRGB(255,200,50),
    blue  = Color3.fromRGB(60,150,255),
    br    = Color3.fromRGB(140,90,50),
}

local function co(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8) end
local function ms(p,th,col,tr)
    local s=Instance.new("UIStroke",p); s.Thickness=th or 1; s.Color=col or T.str
    s.Transparency=tr or 0.38; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s
end
local function lb(par,props)
    local l=Instance.new("TextLabel",par); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold; l.TextColor3=T.white; l.BorderSizePixel=0
    for k,v in pairs(props) do l[k]=v end; return l
end
local function Tw(o,d,p)
    TweenService:Create(o,TweenInfo.new(d or 0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play()
end

local sg = Instance.new("ScreenGui")
sg.Name="GrassGui"; sg.ResetOnSpawn=false; sg.DisplayOrder=999; sg.IgnoreGuiInset=true
if not pcall(function() sg.Parent=CoreGui end) then sg.Parent=playerGui end

local OpenBtn = Instance.new("TextButton",sg)
OpenBtn.Size=UDim2.fromOffset(44,44)
OpenBtn.Position=UDim2.new(0,8,0.5,-22)
OpenBtn.BackgroundColor3=T.acc2; OpenBtn.BackgroundTransparency=0.1
OpenBtn.Text="🌿"; OpenBtn.Font=Enum.Font.GothamBlack; OpenBtn.TextSize=22
OpenBtn.TextColor3=T.white; OpenBtn.BorderSizePixel=0; OpenBtn.AutoButtonColor=false
co(OpenBtn,10); ms(OpenBtn,1.5,T.acc,0.15)

local Win = Instance.new("Frame",sg)
Win.Size=UDim2.fromOffset(220,0)
Win.Position=UDim2.new(0,60,0,8)
Win.BackgroundColor3=T.panel; Win.BackgroundTransparency=0.06
Win.BorderSizePixel=0; Win.AutomaticSize=Enum.AutomaticSize.Y
Win.Active=true; Win.Visible=false
co(Win,12)

local WS = ms(Win,1.5,T.acc,0.12)
local WG = Instance.new("UIGradient",WS)
WG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(30,180,60)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(80,230,100)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(40,200,70)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(30,180,60)),
})
WG.Rotation=0
task.spawn(function()
    while Win and Win.Parent do WG.Rotation=(WG.Rotation+1.1)%360; task.wait(0.016) end
end)

local WL = Instance.new("UIListLayout",Win)
WL.Padding=UDim.new(0,0); WL.SortOrder=Enum.SortOrder.LayoutOrder

local Hdr = Instance.new("Frame",Win)
Hdr.Size=UDim2.new(1,0,0,26); Hdr.BackgroundColor3=T.surf
Hdr.BackgroundTransparency=0.05; Hdr.BorderSizePixel=0; Hdr.LayoutOrder=1; Hdr.Active=true
co(Hdr,12)
local HFix=Instance.new("Frame",Hdr); HFix.Size=UDim2.new(1,0,0,8); HFix.Position=UDim2.new(0,0,1,-8)
HFix.BackgroundColor3=T.surf; HFix.BackgroundTransparency=0.05; HFix.BorderSizePixel=0
local HL=Instance.new("Frame",Hdr); HL.Size=UDim2.new(1,0,0,1); HL.Position=UDim2.new(0,0,1,0)
HL.BackgroundColor3=T.acc; HL.BackgroundTransparency=0.4; HL.BorderSizePixel=0

lb(Hdr,{Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-40,1,0),
    Text="🌿 Grass Farm",TextSize=11,Font=Enum.Font.GothamBlack,
    TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.acc})

local CloseBtn=Instance.new("TextButton",Hdr)
CloseBtn.Size=UDim2.fromOffset(18,18); CloseBtn.Position=UDim2.new(1,-22,0.5,-9)
CloseBtn.BackgroundColor3=Color3.fromRGB(60,15,15); CloseBtn.BackgroundTransparency=0.2
CloseBtn.Text="✕"; CloseBtn.Font=Enum.Font.GothamBlack; CloseBtn.TextSize=10
CloseBtn.TextColor3=T.red; CloseBtn.BorderSizePixel=0; CloseBtn.AutoButtonColor=false
co(CloseBtn,5); ms(CloseBtn,1,T.red,0.4)
CloseBtn.MouseButton1Click:Connect(function() Win.Visible=false end)
CloseBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then Win.Visible=false end end)
OpenBtn.MouseButton1Click:Connect(function() Win.Visible=not Win.Visible end)
OpenBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then Win.Visible=not Win.Visible end end)

do
    local drag,ds,dp=false
    Hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; dp=Win.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds
            Win.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
end

local TABS = {"Water","Shop","Nature"}
local tabBtns = {}; local tabFrames = {}; local activeTab = "Water"

local TabBar = Instance.new("Frame",Win)
TabBar.Size=UDim2.new(1,0,0,22); TabBar.BackgroundColor3=T.bg
TabBar.BackgroundTransparency=0.4; TabBar.BorderSizePixel=0; TabBar.LayoutOrder=2
local TBL=Instance.new("UIListLayout",TabBar); TBL.FillDirection=Enum.FillDirection.Horizontal
TBL.SortOrder=Enum.SortOrder.LayoutOrder

local ContentArea = Instance.new("Frame",Win)
ContentArea.Size=UDim2.new(1,0,0,0); ContentArea.AutomaticSize=Enum.AutomaticSize.Y
ContentArea.BackgroundTransparency=1; ContentArea.BorderSizePixel=0; ContentArea.LayoutOrder=3

local function switchTab(name)
    activeTab=name
    for n,f in pairs(tabFrames) do f.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        if n==name then b.BackgroundColor3=T.surf; b.TextColor3=T.acc
        else b.BackgroundColor3=T.bg; b.TextColor3=T.dim end
    end
end

for i,name in ipairs(TABS) do
    local b=Instance.new("TextButton",TabBar); b.LayoutOrder=i
    b.Size=UDim2.new(1/#TABS,0,1,0); b.BackgroundColor3=T.bg; b.BackgroundTransparency=0.3
    b.BorderSizePixel=0; b.AutoButtonColor=false; b.Text=name
    b.TextSize=8; b.Font=Enum.Font.GothamBold; b.TextColor3=T.dim; b.ZIndex=3
    tabBtns[name]=b

    local f=Instance.new("ScrollingFrame",ContentArea)
    f.Size=UDim2.new(1,0,0,0); f.AutomaticSize=Enum.AutomaticSize.Y
    f.BackgroundTransparency=1; f.BorderSizePixel=0; f.Visible=(name=="Water")
    f.ScrollBarThickness=2; f.ScrollBarImageColor3=T.acc
    f.CanvasSize=UDim2.new(0,0,0,0); f.AutomaticCanvasSize=Enum.AutomaticSize.Y
    tabFrames[name]=f

    local ll=Instance.new("UIListLayout",f); ll.Padding=UDim.new(0,4)
    ll.HorizontalAlignment=Enum.HorizontalAlignment.Center
    local lp2=Instance.new("UIPadding",f); lp2.PaddingTop=UDim.new(0,5)
    lp2.PaddingBottom=UDim.new(0,6); lp2.PaddingLeft=UDim.new(0,5); lp2.PaddingRight=UDim.new(0,5)

    b.MouseButton1Click:Connect(function() switchTab(name) end)
    b.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch then switchTab(name) end end)
end

local function mkSep(parent,txt)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,13)
    f.BackgroundTransparency=1; f.BorderSizePixel=0
    lb(f,{Size=UDim2.new(1,0,1,0),Text=txt,TextSize=7,Font=Enum.Font.GothamBold,
        TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
end

local function mkTogBtn(parent,label,onCol,offCol,onToggle)
    local row=Instance.new("Frame",parent); row.Size=UDim2.new(1,0,0,24)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.15
    row.BorderSizePixel=0; co(row,7); ms(row,1,T.str,0.55)
    local state=false
    local dot=Instance.new("Frame",row); dot.Size=UDim2.fromOffset(6,6)
    dot.Position=UDim2.new(0,7,0.5,-3); dot.BackgroundColor3=offCol; dot.BorderSizePixel=0; co(dot,3)
    local lbl=lb(row,{Position=UDim2.new(0,17,0,0),Size=UDim2.new(1,-58,1,0),
        Text=label,TextSize=9,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.fromOffset(46,18); btn.Position=UDim2.new(1,-50,0.5,-9)
    btn.BackgroundColor3=offCol; btn.BackgroundTransparency=0.15
    btn.Text="OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=9
    btn.TextColor3=T.white; btn.BorderSizePixel=0; btn.AutoButtonColor=false
    co(btn,6); local bs=ms(btn,1,offCol,0.3)
    local function toggle()
        state=not state
        if state then
            btn.Text="ON"; Tw(btn,0.12,{BackgroundColor3=onCol}); bs.Color=onCol; dot.BackgroundColor3=onCol; lbl.TextColor3=T.white
        else
            btn.Text="OFF"; Tw(btn,0.12,{BackgroundColor3=offCol}); bs.Color=offCol; dot.BackgroundColor3=offCol; lbl.TextColor3=T.dim
        end
        onToggle(state)
    end
    btn.MouseButton1Click:Connect(toggle)
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then toggle() end end)
    return row
end

local function mkBtn(parent,label,col,onClick)
    local b=Instance.new("TextButton",parent); b.Size=UDim2.new(1,0,0,24)
    b.BackgroundColor3=col; b.BackgroundTransparency=0.12
    b.Text=label; b.Font=Enum.Font.GothamBold; b.TextSize=9
    b.TextColor3=T.white; b.BorderSizePixel=0; b.AutoButtonColor=false
    co(b,7); ms(b,1,col,0.35)
    b.MouseButton1Click:Connect(onClick)
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then onClick() end end)
    return b
end

local function mkDropdown(parent,label,options,default,onChange)
    local row=Instance.new("Frame",parent); row.Size=UDim2.new(1,0,0,24)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.15
    row.BorderSizePixel=0; co(row,7); ms(row,1,T.str,0.55)
    lb(row,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(0,70,1,0),
        Text=label,TextSize=8,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local idx=1; for i,v in ipairs(options) do if v==default then idx=i end end
    local valL=lb(row,{Position=UDim2.new(0,75,0,0),Size=UDim2.new(1,-100,1,0),
        Text=options[idx],TextSize=7,TextColor3=T.acc,TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd})
    local prev=Instance.new("TextButton",row); prev.Size=UDim2.fromOffset(18,18)
    prev.Position=UDim2.new(1,-42,0.5,-9); prev.BackgroundColor3=T.surf2
    prev.BackgroundTransparency=0.2; prev.Text="<"; prev.Font=Enum.Font.GothamBold; prev.TextSize=9
    prev.TextColor3=T.white; prev.BorderSizePixel=0; prev.AutoButtonColor=false; co(prev,4)
    local next2=Instance.new("TextButton",row); next2.Size=UDim2.fromOffset(18,18)
    next2.Position=UDim2.new(1,-20,0.5,-9); next2.BackgroundColor3=T.surf2
    next2.BackgroundTransparency=0.2; next2.Text=">"; next2.Font=Enum.Font.GothamBold; next2.TextSize=9
    next2.TextColor3=T.white; next2.BorderSizePixel=0; next2.AutoButtonColor=false; co(next2,4)
    local function update(n)
        idx=((n-1)%#options)+1; valL.Text=options[idx]; onChange(options[idx])
    end
    prev.MouseButton1Click:Connect(function() update(idx-1) end)
    next2.MouseButton1Click:Connect(function() update(idx+1) end)
    prev.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then update(idx-1) end end)
    next2.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then update(idx+1) end end)
    return row
end

local statusL=nil

local WT = tabFrames["Water"]
mkSep(WT,"── AUTO WATER")
mkTogBtn(WT,"Auto Water Dead Grass",T.grn,T.red,function(on)
    if on then startAutoWater() else stopAutoWater() end
end)
mkBtn(WT,"Water Once (nearest)",T.acc2,function()
    task.spawn(function()
        equipCan()
        local tiles=getDeadGrass()
        for _,t in ipairs(tiles) do
            if not t.Parent then continue end
            waterTile(t); task.wait(0.12)
        end
    end)
end)
mkSep(WT,"── INFO")
local infoRow=Instance.new("Frame",WT); infoRow.Size=UDim2.new(1,0,0,14)
infoRow.BackgroundTransparency=1; infoRow.BorderSizePixel=0
statusL=lb(infoRow,{Size=UDim2.new(1,0,1,0),Text="dead tiles: 0  can: none",TextSize=7,
    Font=Enum.Font.Gotham,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})

local CAN_LIST = {
    "Terrible Watering Can","Bad Watering Can","Ok Watering Can","Mid Watering Can",
    "Good Watering Can","Decent Watering Can","Great Watering Can","Amazing Watering Can"
}

local SHT = tabFrames["Shop"]
mkSep(SHT,"── WATERING CAN")
mkDropdown(SHT,"Can:",CAN_LIST,CFG.targetCan,function(v) CFG.targetCan=v end)
mkBtn(SHT,"Buy Selected Can",T.yel,function()
    task.spawn(function() buyWateringCan(CFG.targetCan) end)
end)
mkBtn(SHT,"Open Item Shop",T.br,function()
    openShop("ItemShop")
end)
mkSep(SHT,"── QUICK BUY CANS")
for _,can in ipairs(CAN_LIST) do
    local shortName = can:gsub(" Watering Can","")
    mkBtn(SHT,shortName,T.acc2,function()
        task.spawn(function() buyWateringCan(can) end)
    end)
end

local NATURE_LIST = {
    "Small Rock","Small Bush","Small Pine","Small Tree","Pine","Boulder","Rock","Big Tree"
}
local NT = tabFrames["Nature"]
mkSep(NT,"── NATURE STORE")
mkDropdown(NT,"Item:",NATURE_LIST,CFG.targetNature,function(v) CFG.targetNature=v end)
mkBtn(NT,"Buy Selected Item",T.grn,function()
    task.spawn(function() buyNatureItem(CFG.targetNature) end)
end)
mkBtn(NT,"Open Nature Store",T.acc2,function()
    pcall(function()
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local a=(v.ActionText or ""):lower()
                if a:find("nature") or a:find("store") or a:find("plant") or a:find("buy") then
                    safeFirePrompt(v); return
                end
            end
        end
    end)
end)
mkSep(NT,"── QUICK BUY")
for _,item in ipairs(NATURE_LIST) do
    mkBtn(NT,item,T.acc2,function()
        task.spawn(function() buyNatureItem(item) end)
    end)
end
mkSep(NT,"── REMOVE")
mkBtn(NT,"Remove Nearby Nature",T.red,function()
    task.spawn(removeNearbyNature)
end)
mkBtn(NT,"Remove All In Range",Color3.fromRGB(140,30,30),function()
    task.spawn(function()
        for _=1,5 do removeNearbyNature(); task.wait(0.3) end
    end)
end)

task.spawn(function()
    while sg and sg.Parent do
        task.wait(2)
        pcall(function()
            local tiles=getDeadGrass()
            local can=getEquippedCan()
            local canName=can and can.Name or "none"
            if statusL and statusL.Parent then
                statusL.Text="dead:"..#tiles.."  can:"..canName:sub(1,10)
                statusL.TextColor3=CFG.autoWater and T.grn or T.dim
            end
        end)
    end
end)

switchTab("Water")
