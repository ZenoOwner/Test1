local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local PPS               = game:GetService("ProximityPromptService")

local lp = Players.LocalPlayer
if not lp.Character then lp.CharacterAdded:Wait() end

pcall(function()
    if CoreGui:FindFirstChild("ShredGui") then CoreGui.ShredGui:Destroy() end
end)

local CFG = {
    autoShred   = false,
    autoRecycle = false,
}

local function getHRP()
    local c = lp.Character; if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function tpTo(pos)
    local hrp = getHRP(); if not hrp then return end
    hrp.CFrame = CFrame.new(pos + Vector3.new(2, 3, 2))
    task.wait(0.12)
end

local function safeFirePrompt(pp)
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(pp)
        end
    end)
    pcall(function()
        if firetouchinterest then
            local hrp = getHRP()
            if hrp then firetouchinterest(hrp, pp.Parent, 0) end
        end
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

local function tryFireRemote(remote, ...)
    if not remote then return false end
    local ok = pcall(function()
        if remote:IsA("RemoteEvent") then remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
    end)
    return ok
end

local function getAllDocs()
    local docs = {}
    local seen = {}
    local function addPart(v)
        if seen[v] then return end
        seen[v] = true
        local n = v.Name:lower()
        if n:find("shred") or n:find("pile") or n:find("ball") then return end
        table.insert(docs, v)
    end
    pcall(function()
        local d = workspace:FindFirstChild("Documents")
        if d then
            if d:IsA("BasePart") or d:IsA("MeshPart") or d:IsA("UnionOperation") or d:IsA("SpecialMesh") then
                addPart(d)
            end
            for _, v in ipairs(d:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then addPart(v) end
            end
        end
    end)
    for _, folder in ipairs({"Papers","PaperBundles","PileBundles"}) do
        pcall(function()
            local f = workspace:FindFirstChild(folder); if not f then return end
            for _, v in ipairs(f:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then addPart(v) end
            end
        end)
    end
    pcall(function()
        local rooms = workspace:FindFirstChild("Rooms"); if not rooms then return end
        for _, room in ipairs(rooms:GetChildren()) do
            local gp = room:FindFirstChild("Gameplay"); if not gp then continue end
            for _, v in ipairs(gp:GetDescendants()) do
                if (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                    local n = v.Name:lower()
                    if n:find("paper") or n:find("doc") or n:find("stack") or n:find("file") or n:find("sheet") or n:find("bundle") then
                        if not n:find("shred") then addPart(v) end
                    end
                end
            end
        end
    end)
    return docs
end

local function getShredder()
    local rooms = workspace:FindFirstChild("Rooms"); if not rooms then return nil end
    for _, room in ipairs(rooms:GetChildren()) do
        local gp = room:FindFirstChild("Gameplay"); if not gp then continue end
        local shredder = gp:FindFirstChild("Shredder"); if not shredder then continue end
        local slot = shredder:FindFirstChild("Shredder") or shredder:FindFirstChildWhichIsA("BasePart")
        if slot then return slot, shredder end
    end
    return nil, nil
end

local function getShredPrompts(shredderFolder)
    local found = {}
    if not shredderFolder then return found end
    for _, v in ipairs(shredderFolder:GetDescendants()) do
        if v:IsA("ProximityPrompt") then table.insert(found, v) end
    end
    return found
end

local function getShredPiles()
    local piles = {}
    pcall(function()
        local sp = workspace:FindFirstChild("ShredPiles"); if not sp then return end
        for _, v in ipairs(sp:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                table.insert(piles, v)
            end
        end
        for _, v in ipairs(sp:GetChildren()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                table.insert(piles, v)
            elseif v:IsA("Model") then
                local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if p then table.insert(piles, p) end
            end
        end
    end)
    return piles
end

local function getRecycleBin()
    local RECYCLE_NAMES = {
        "recycle","recyclebin","recycling","bin","trash","waste","basket",
        "wastepaper","garbage","rubbish","disposal","container"
    }
    local MESH_IDS = {
        "6031071","rbxassetid://6031071",
    }
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            local n = v.Name:lower()
            for _, kw in ipairs(RECYCLE_NAMES) do
                if n:find(kw) then return v end
            end
        end
        if v:IsA("SpecialMesh") then
            for _, id in ipairs(MESH_IDS) do
                if tostring(v.MeshId):find(id) then
                    local part = v.Parent
                    if part and (part:IsA("BasePart") or part:IsA("MeshPart")) then
                        return part
                    end
                end
            end
        end
        if v:IsA("Decal") or v:IsA("Texture") then
            local t = tostring(v.Texture):lower()
            if t:find("recycle") or t:find("recycl") then
                local p = v.Parent
                while p do
                    if p:IsA("BasePart") or p:IsA("MeshPart") then return p end
                    p = p.Parent
                end
            end
        end
        if v:IsA("ProximityPrompt") then
            local a = (v.ActionText or ""):lower()
            local o = (v.ObjectText or ""):lower()
            if a:find("recycle") or a:find("throw") or a:find("toss") or a:find("drop") or
               o:find("recycle") or o:find("bin") or o:find("basket") then
                local p = v.Parent
                while p do
                    if p:IsA("BasePart") or p:IsA("MeshPart") then return p end
                    p = p.Parent
                end
            end
        end
    end
    return nil
end

local _shredConn = nil
local _recycleConn = nil

local function stopShred()
    CFG.autoShred = false
    if _shredConn then _shredConn:Disconnect(); _shredConn = nil end
end

local function startShred()
    if _shredConn then return end
    CFG.autoShred = true
    task.spawn(function()
        while CFG.autoShred do
            local docs = getAllDocs()
            if #docs == 0 then task.wait(1); continue end
            local slot, folder = getShredder()
            if not slot then task.wait(1); continue end
            local prompts = getShredPrompts(folder)
            tpTo(slot.Position)
            for _, doc in ipairs(docs) do
                if not CFG.autoShred then break end
                if not doc.Parent then continue end
                local hrp = getHRP(); if not hrp then continue end
                local dist = (hrp.Position - doc.Position).Magnitude
                if dist > 20 then tpTo(doc.Position); task.wait(0.05) end
                pcall(function()
                    for _, pp in ipairs(doc:GetDescendants()) do
                        if pp:IsA("ProximityPrompt") then safeFirePrompt(pp) end
                    end
                    local ppInParent = doc.Parent and doc.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                    if ppInParent then safeFirePrompt(ppInParent) end
                end)
                if not doc.Parent then continue end
                pcall(function() doc.CFrame = slot.CFrame * CFrame.new(0, 1, 0) end)
                for _, pp in ipairs(prompts) do safeFirePrompt(pp) end
                task.wait(0.08)
            end
            task.wait(0.5)
        end
    end)
end

local function stopRecycle()
    CFG.autoRecycle = false
    if _recycleConn then _recycleConn:Disconnect(); _recycleConn = nil end
end

local function startRecycle()
    if _recycleConn then return end
    CFG.autoRecycle = true
    task.spawn(function()
        while CFG.autoRecycle do
            local bin = getRecycleBin()
            if not bin then task.wait(2); continue end
            local piles = getShredPiles()
            if #piles == 0 then task.wait(1); continue end
            tpTo(bin.Position)
            for _, pile in ipairs(piles) do
                if not CFG.autoRecycle then break end
                if not pile.Parent then continue end
                local hrp = getHRP(); if not hrp then continue end
                local dist = (hrp.Position - pile.Position).Magnitude
                if dist > 15 then tpTo(pile.Position); task.wait(0.05) end
                pcall(function() pile.CFrame = bin.CFrame * CFrame.new(0, 2, 0) end)
                pcall(function()
                    for _, pp in ipairs(pile:GetDescendants()) do
                        if pp:IsA("ProximityPrompt") then safeFirePrompt(pp) end
                    end
                    local par = pile.Parent
                    if par then
                        for _, pp in ipairs(par:GetDescendants()) do
                            if pp:IsA("ProximityPrompt") then safeFirePrompt(pp) end
                        end
                    end
                end)
                pcall(function()
                    for _, pp in ipairs(bin:GetDescendants()) do
                        if pp:IsA("ProximityPrompt") then safeFirePrompt(pp) end
                    end
                    local bpar = bin.Parent
                    if bpar then
                        for _, pp in ipairs(bpar:GetDescendants()) do
                            if pp:IsA("ProximityPrompt") then safeFirePrompt(pp) end
                        end
                    end
                end)
                task.wait(0.1)
            end
            task.wait(0.5)
        end
    end)
end

local T = {
    bg    = Color3.fromRGB(6,6,8),
    panel = Color3.fromRGB(10,10,14),
    surf  = Color3.fromRGB(16,16,22),
    surf2 = Color3.fromRGB(22,22,30),
    acc   = Color3.fromRGB(80,200,120),
    acc2  = Color3.fromRGB(40,160,80),
    white = Color3.new(1,1,1),
    dim   = Color3.fromRGB(90,90,110),
    str   = Color3.fromRGB(60,160,90),
    red   = Color3.fromRGB(255,65,65),
    grn   = Color3.fromRGB(52,218,88),
    blue  = Color3.fromRGB(50,130,220),
    yel   = Color3.fromRGB(255,195,50),
}

local function co(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 6) end
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
sg.Name="ShredGui"; sg.ResetOnSpawn=false; sg.DisplayOrder=999; sg.IgnoreGuiInset=true
if not pcall(function() sg.Parent=CoreGui end) then sg.Parent=lp:WaitForChild("PlayerGui") end

local Win = Instance.new("Frame",sg)
Win.Size=UDim2.fromOffset(165,0)
Win.Position=UDim2.new(0,8,0,8)
Win.BackgroundColor3=T.panel; Win.BackgroundTransparency=0.08
Win.BorderSizePixel=0; Win.AutomaticSize=Enum.AutomaticSize.Y
Win.Active=true; co(Win,10)

local WS=ms(Win,1.4,T.acc,0.15)
local WG=Instance.new("UIGradient",WS)
WG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(40,200,90)),
    ColorSequenceKeypoint.new(0.35,Color3.fromRGB(80,255,140)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(30,160,70)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(40,200,90)),
})
WG.Rotation=0
task.spawn(function()
    while Win and Win.Parent do WG.Rotation=(WG.Rotation+1.2)%360; task.wait(0.016) end
end)

local WL=Instance.new("UIListLayout",Win)
WL.Padding=UDim.new(0,0); WL.SortOrder=Enum.SortOrder.LayoutOrder

local Hdr=Instance.new("Frame",Win)
Hdr.Size=UDim2.new(1,0,0,24); Hdr.BackgroundColor3=T.surf
Hdr.BackgroundTransparency=0.05; Hdr.BorderSizePixel=0
Hdr.LayoutOrder=1; Hdr.Active=true; co(Hdr,10)
local HFix=Instance.new("Frame",Hdr); HFix.Size=UDim2.new(1,0,0,8)
HFix.Position=UDim2.new(0,0,1,-8); HFix.BackgroundColor3=T.surf
HFix.BackgroundTransparency=0.05; HFix.BorderSizePixel=0
local HL=Instance.new("Frame",Hdr); HL.Size=UDim2.new(1,0,0,1)
HL.Position=UDim2.new(0,0,1,0); HL.BackgroundColor3=T.acc
HL.BackgroundTransparency=0.4; HL.BorderSizePixel=0

lb(Hdr,{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-30,1,0),
    Text="Shred++",TextSize=10,Font=Enum.Font.GothamBlack,
    TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.acc})

local FoldBtn=Instance.new("TextButton",Hdr)
FoldBtn.Size=UDim2.fromOffset(18,16); FoldBtn.Position=UDim2.new(1,-21,0.5,-8)
FoldBtn.BackgroundColor3=T.surf2; FoldBtn.BackgroundTransparency=0.3
FoldBtn.Text="–"; FoldBtn.Font=Enum.Font.GothamBlack; FoldBtn.TextSize=11
FoldBtn.TextColor3=T.dim; FoldBtn.BorderSizePixel=0; FoldBtn.AutoButtonColor=false
co(FoldBtn,4)

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

local Body=Instance.new("Frame",Win)
Body.Size=UDim2.new(1,0,0,0); Body.BackgroundTransparency=1
Body.BorderSizePixel=0; Body.AutomaticSize=Enum.AutomaticSize.Y
Body.LayoutOrder=2
local BL=Instance.new("UIListLayout",Body)
BL.Padding=UDim.new(0,4); BL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local BP=Instance.new("UIPadding",Body)
BP.PaddingTop=UDim.new(0,5); BP.PaddingBottom=UDim.new(0,6)
BP.PaddingLeft=UDim.new(0,5); BP.PaddingRight=UDim.new(0,5)

local folded=false
FoldBtn.MouseButton1Click:Connect(function()
    folded=not folded; FoldBtn.Text=folded and "+" or "–"; Body.Visible=not folded
end)
FoldBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then
        folded=not folded; FoldBtn.Text=folded and "+" or "–"; Body.Visible=not folded
    end
end)

local function mkSep(txt)
    local f=Instance.new("Frame",Body); f.Size=UDim2.new(1,0,0,12)
    f.BackgroundTransparency=1; f.BorderSizePixel=0
    lb(f,{Size=UDim2.new(1,0,1,0),Text=txt,TextSize=7,Font=Enum.Font.GothamBold,
        TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
end

local function mkTogBtn(label, onCol, offCol, onToggle)
    local row=Instance.new("Frame",Body); row.Size=UDim2.new(1,0,0,22)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.15
    row.BorderSizePixel=0; co(row,6); ms(row,1,T.str,0.55)
    local state=false
    local dot=Instance.new("Frame",row); dot.Size=UDim2.fromOffset(6,6)
    dot.Position=UDim2.new(0,6,0.5,-3); dot.BackgroundColor3=offCol; dot.BorderSizePixel=0; co(dot,3)
    local lbl=lb(row,{Position=UDim2.new(0,16,0,0),Size=UDim2.new(1,-54,1,0),
        Text=label,TextSize=8,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.fromOffset(44,16); btn.Position=UDim2.new(1,-48,0.5,-8)
    btn.BackgroundColor3=offCol; btn.BackgroundTransparency=0.15
    btn.Text="OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=8
    btn.TextColor3=T.white; btn.BorderSizePixel=0; btn.AutoButtonColor=false
    co(btn,5); local bs=ms(btn,1,offCol,0.3)
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

local function mkBtn(label, col, onClick)
    local b=Instance.new("TextButton",Body); b.Size=UDim2.new(1,0,0,22)
    b.BackgroundColor3=col; b.BackgroundTransparency=0.12
    b.Text=label; b.Font=Enum.Font.GothamBold; b.TextSize=9
    b.TextColor3=T.white; b.BorderSizePixel=0; b.AutoButtonColor=false
    co(b,6); ms(b,1,col,0.35)
    b.MouseButton1Click:Connect(onClick)
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then onClick() end end)
    return b
end

local statusL=lb(Body,{Size=UDim2.new(1,0,0,13),
    Text="idle — ready",TextSize=7,Font=Enum.Font.Gotham,
    TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local infoL=lb(Body,{Size=UDim2.new(1,0,0,11),
    Text="docs: 0  piles: 0  bin: ?",TextSize=6,Font=Enum.Font.Gotham,
    TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})

mkSep("── SHREDDER")
mkTogBtn("Auto Shred",T.grn,T.red,function(on)
    if on then startShred() else stopShred() end
end)
mkBtn("Shred Once",T.acc2,function()
    task.spawn(function()
        statusL.Text="shredding..."; statusL.TextColor3=T.grn
        local docs=getAllDocs()
        local slot,folder=getShredder()
        if not slot then statusL.Text="no shredder found"; statusL.TextColor3=T.red; return end
        local prompts={}
        if folder then
            for _,v in ipairs(folder:GetDescendants()) do
                if v:IsA("ProximityPrompt") then table.insert(prompts,v) end
            end
        end
        tpTo(slot.Position)
        for _,doc in ipairs(docs) do
            if not doc.Parent then continue end
            pcall(function() doc.CFrame=slot.CFrame*CFrame.new(0,1,0) end)
            for _,pp in ipairs(prompts) do safeFirePrompt(pp) end
            task.wait(0.07)
        end
        statusL.Text="done — "..#docs.." docs"; statusL.TextColor3=T.grn
    end)
end)

mkSep("── RECYCLE")
mkTogBtn("Auto Recycle",T.blue,T.red,function(on)
    if on then startRecycle() else stopRecycle() end
end)
mkBtn("Recycle Once",T.blue,function()
    task.spawn(function()
        statusL.Text="recycling..."; statusL.TextColor3=T.blue
        local bin=getRecycleBin()
        if not bin then statusL.Text="no bin found"; statusL.TextColor3=T.red; return end
        local piles=getShredPiles()
        tpTo(bin.Position)
        for _,pile in ipairs(piles) do
            if not pile.Parent then continue end
            pcall(function() pile.CFrame=bin.CFrame*CFrame.new(0,2,0) end)
            pcall(function()
                for _,pp in ipairs(bin:GetDescendants()) do
                    if pp:IsA("ProximityPrompt") then safeFirePrompt(pp) end
                end
            end)
            task.wait(0.08)
        end
        statusL.Text="done — "..#piles.." piles"; statusL.TextColor3=T.blue
    end)
end)

task.spawn(function()
    while Win and Win.Parent do
        task.wait(1.5)
        pcall(function()
            local docs=getAllDocs()
            local piles=getShredPiles()
            local bin=getRecycleBin()
            infoL.Text="docs:"..#docs.."  piles:"..#piles.."  bin:"..(bin and "✓" or "✗")
            local s=""
            if CFG.autoShred and CFG.autoRecycle then s="shredding + recycling"
            elseif CFG.autoShred then s="auto shredding..."
            elseif CFG.autoRecycle then s="auto recycling..."
            else s="idle — ready" end
            statusL.Text=s
            statusL.TextColor3=CFG.autoShred or CFG.autoRecycle and T.grn or T.dim
        end)
    end
end)
