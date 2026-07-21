local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local lp = Players.LocalPlayer
if not lp.Character then lp.CharacterAdded:Wait() end

pcall(function()
    if CoreGui:FindFirstChild("ShredGui") then CoreGui.ShredGui:Destroy() end
end)

local CFG = {
    autoShred   = false,
    autoRecycle = false,
    shredRange  = 25,
    recycleRange= 20,
}

local _shredRemote   = nil
local _recycleRemote = nil

task.spawn(function()
    pcall(function()
        local ctrl = ReplicatedStorage:FindFirstChild("Client")
        if ctrl then
            local feed = ctrl:FindFirstChild("Controllers",true)
            if feed then
                for _,v in ipairs(feed:GetDescendants()) do
                    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                        local n=v.Name:lower()
                        if n:find("paperfeed") or n:find("shred") or n:find("feed") then
                            _shredRemote=v
                        end
                        if n:find("drop") or n:find("recycle") or n:find("bin") or n:find("throw") then
                            _recycleRemote=v
                        end
                    end
                end
            end
        end
    end)
end)

local function getHRP()
    local c=lp.Character; if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function tpTo(pos)
    local hrp=getHRP(); if not hrp then return end
    hrp.CFrame=CFrame.new(pos+Vector3.new(0,3,0))
end

local function tryFireRemote(remote, ...)
    if not remote then return false end
    local ok=pcall(function()
        if remote:IsA("RemoteEvent") then remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
    end)
    return ok
end

local function getAllDocs()
    local docs={}
    pcall(function()
        local docsFolder=workspace:FindFirstChild("Documents")
        if docsFolder then
            for _,v in ipairs(docsFolder:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                    local n=v.Name:lower()
                    if n:find("paper") or n:find("doc") or n:find("stack") or n:find("file") or n:find("sheet") then
                        table.insert(docs,v)
                    end
                end
            end
            if docsFolder:IsA("BasePart") or docsFolder:IsA("MeshPart") then
                table.insert(docs,docsFolder)
            end
        end
    end)
    pcall(function()
        local papers=workspace:FindFirstChild("Papers")
        if papers then
            for _,v in ipairs(papers:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    table.insert(docs,v)
                end
            end
        end
    end)
    pcall(function()
        local pb=workspace:FindFirstChild("PaperBundles")
        if pb then
            for _,v in ipairs(pb:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    table.insert(docs,v)
                end
            end
        end
    end)
    pcall(function()
        local pile=workspace:FindFirstChild("PileBundles")
        if pile then
            for _,v in ipairs(pile:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    table.insert(docs,v)
                end
            end
        end
    end)
    pcall(function()
        local rooms=workspace:FindFirstChild("Rooms")
        if rooms then
            for _,room in ipairs(rooms:GetChildren()) do
                local gp=room:FindFirstChild("Gameplay")
                if gp then
                    for _,v in ipairs(gp:GetDescendants()) do
                        if v:IsA("BasePart") or v:IsA("MeshPart") then
                            local n=v.Name:lower()
                            if n:find("paper") or n:find("doc") or n:find("stack") or n:find("file") or n:find("sheet") or n:find("bundle") then
                                if not n:find("shred") then
                                    table.insert(docs,v)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return docs
end

local function getShredder()
    local rooms=workspace:FindFirstChild("Rooms"); if not rooms then return nil end
    for _,room in ipairs(rooms:GetChildren()) do
        local gp=room:FindFirstChild("Gameplay"); if not gp then continue end
        local shredder=gp:FindFirstChild("Shredder")
        if shredder then
            local slot=shredder:FindFirstChild("Shredder") or shredder:FindFirstChildWhichIsA("BasePart")
            if slot then return slot end
        end
    end
    return nil
end

local function getShredPiles()
    local piles={}
    pcall(function()
        local sp=workspace:FindFirstChild("ShredPiles"); if not sp then return end
        for _,v in ipairs(sp:GetChildren()) do
            local part=v:IsA("BasePart") and v or (v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")))
            if part then table.insert(piles,{obj=v,part=part}) end
        end
    end)
    return piles
end

local function getBin()
    for _,v in ipairs(workspace:GetDescendants()) do
        local n=v.Name:lower()
        if v:IsA("BasePart") and (n:find("bin") or n:find("recycle") or n:find("trash") or n:find("waste") or n:find("basket")) then
            return v
        end
    end
    return nil
end

local _shredConn=nil
local _recycleConn=nil

local function stopShred()
    CFG.autoShred=false
    if _shredConn then _shredConn:Disconnect(); _shredConn=nil end
end

local function startShred()
    if _shredConn then return end
    CFG.autoShred=true
    _shredConn=RunService.Heartbeat:Connect(function()
        if not CFG.autoShred then stopShred(); return end
        local hrp=getHRP(); if not hrp then return end
        local shredder=getShredder()
        if not shredder then return end
        local spos=shredder.Position
        local dist=(hrp.Position-spos).Magnitude
        if dist>CFG.shredRange then
            tpTo(spos+Vector3.new(2,0,2))
            task.wait(0.1)
        end
        local docs=getAllDocs()
        for _,doc in ipairs(docs) do
            if not doc.Parent then continue end
            if not CFG.autoShred then break end
            local ok=tryFireRemote(_shredRemote,doc)
            if not ok then
                pcall(function()
                    doc.CFrame=shredder.CFrame*CFrame.new(0,1,0)
                end)
            end
            pcall(function()
                for _,pp in ipairs(workspace:GetDescendants()) do
                    if pp:IsA("ProximityPrompt") and pp.ActionText:lower():find("shred") then
                        fireproximityprompt(pp)
                    end
                end
            end)
            task.wait(0.08)
        end
    end)
end

local function stopRecycle()
    CFG.autoRecycle=false
    if _recycleConn then _recycleConn:Disconnect(); _recycleConn=nil end
end

local function startRecycle()
    if _recycleConn then return end
    CFG.autoRecycle=true
    _recycleConn=RunService.Heartbeat:Connect(function()
        if not CFG.autoRecycle then stopRecycle(); return end
        local hrp=getHRP(); if not hrp then return end
        local bin=getBin()
        if not bin then return end
        local piles=getShredPiles()
        for _,p in ipairs(piles) do
            if not CFG.autoRecycle then break end
            local dist=(hrp.Position-p.part.Position).Magnitude
            if dist>CFG.recycleRange then
                tpTo(p.part.Position+Vector3.new(2,0,2))
                task.wait(0.1)
            end
            local ok=tryFireRemote(_recycleRemote,p.obj)
            if not ok then
                pcall(function()
                    p.part.CFrame=bin.CFrame*CFrame.new(0,2,0)
                end)
            end
            pcall(function()
                for _,pp in ipairs(workspace:GetDescendants()) do
                    if pp:IsA("ProximityPrompt") then
                        local a=pp.ActionText:lower()
                        if a:find("recycle") or a:find("throw") or a:find("bin") or a:find("drop") then
                            fireproximityprompt(pp)
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local T={
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

local sg=Instance.new("ScreenGui")
sg.Name="ShredGui"; sg.ResetOnSpawn=false; sg.DisplayOrder=999; sg.IgnoreGuiInset=true
if not pcall(function() sg.Parent=CoreGui end) then sg.Parent=lp:WaitForChild("PlayerGui") end

local Win=Instance.new("Frame",sg)
Win.Size=UDim2.fromOffset(170,0)
Win.Position=UDim2.new(0,8,0,8)
Win.BackgroundColor3=T.panel; Win.BackgroundTransparency=0.08
Win.BorderSizePixel=0; Win.AutomaticSize=Enum.AutomaticSize.Y
Win.Active=true; co(Win,10)

local WS=ms(Win,1.4,T.acc,0.15)
local WG=Instance.new("UIGradient",WS)
WG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(40,200,90)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(80,255,140)),
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
local HF=Instance.new("Frame",Hdr); HF.Size=UDim2.new(1,0,0,8)
HF.Position=UDim2.new(0,0,1,-8); HF.BackgroundColor3=T.surf
HF.BackgroundTransparency=0.05; HF.BorderSizePixel=0
local HL=Instance.new("Frame",Hdr); HL.Size=UDim2.new(1,0,0,1)
HL.Position=UDim2.new(0,0,1,0); HL.BackgroundColor3=T.acc
HL.BackgroundTransparency=0.5; HL.BorderSizePixel=0

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
BP.PaddingTop=UDim.new(0,6); BP.PaddingBottom=UDim.new(0,6)
BP.PaddingLeft=UDim.new(0,6); BP.PaddingRight=UDim.new(0,6)

local folded=false
FoldBtn.MouseButton1Click:Connect(function()
    folded=not folded; FoldBtn.Text=folded and "+" or "–"
    Body.Visible=not folded
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

local function mkTogBtn(label, onLabel, offLabel, onCol, offCol, onToggle)
    local row=Instance.new("Frame",Body); row.Size=UDim2.new(1,0,0,22)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.15
    row.BorderSizePixel=0; co(row,6); ms(row,1,T.str,0.55)
    local state=false

    local dot=Instance.new("Frame",row); dot.Size=UDim2.fromOffset(6,6)
    dot.Position=UDim2.new(0,6,0.5,-3); dot.BackgroundColor3=offCol or T.red
    dot.BorderSizePixel=0; co(dot,3)

    local lbl=lb(row,{Position=UDim2.new(0,16,0,0),Size=UDim2.new(1,-50,1,0),
        Text=label,TextSize=8,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})

    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.fromOffset(44,16); btn.Position=UDim2.new(1,-48,0.5,-8)
    btn.BackgroundColor3=offCol or T.red; btn.BackgroundTransparency=0.15
    btn.Text=offLabel or "OFF"; btn.Font=Enum.Font.GothamBold; btn.TextSize=8
    btn.TextColor3=T.white; btn.BorderSizePixel=0; btn.AutoButtonColor=false
    co(btn,5); local bs=ms(btn,1,offCol or T.red,0.3)

    local function toggle()
        state=not state
        if state then
            btn.Text=onLabel or "ON"; Tw(btn,0.12,{BackgroundColor3=onCol or T.grn})
            bs.Color=onCol or T.grn; dot.BackgroundColor3=onCol or T.grn
            lbl.TextColor3=T.white
        else
            btn.Text=offLabel or "OFF"; Tw(btn,0.12,{BackgroundColor3=offCol or T.red})
            bs.Color=offCol or T.red; dot.BackgroundColor3=offCol or T.red
            lbl.TextColor3=T.dim
        end
        onToggle(state)
    end
    btn.MouseButton1Click:Connect(toggle)
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then toggle() end end)
    return row, function() if state~=false then return end toggle() end
end

local function mkBtn(label, col, onClick)
    local b=Instance.new("TextButton",Body); b.Size=UDim2.new(1,0,0,22)
    b.BackgroundColor3=col or T.surf2; b.BackgroundTransparency=0.12
    b.Text=label; b.Font=Enum.Font.GothamBold; b.TextSize=9
    b.TextColor3=T.white; b.BorderSizePixel=0; b.AutoButtonColor=false
    co(b,6); ms(b,1,col or T.str,0.35)
    b.MouseButton1Click:Connect(onClick)
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then onClick() end end)
    return b
end

local function mkStatus(txt)
    local f=Instance.new("Frame",Body); f.Size=UDim2.new(1,0,0,16)
    f.BackgroundColor3=T.surf2; f.BackgroundTransparency=0.3
    f.BorderSizePixel=0; co(f,5)
    local l=lb(f,{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),
        Text=txt,TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    return f,l
end

mkSep("── SHREDDER")

mkTogBtn("Auto Shred Docs","STOP","START",T.red,T.grn,function(on)
    if on then startShred() else stopShred() end
end)

mkBtn("Shred Once (nearest)",T.acc2,function()
    local docs=getAllDocs(); if #docs==0 then return end
    local shredder=getShredder(); if not shredder then return end
    tpTo(shredder.Position+Vector3.new(2,0,2)); task.wait(0.15)
    for _,doc in ipairs(docs) do
        if not doc.Parent then continue end
        local ok=tryFireRemote(_shredRemote,doc)
        if not ok then pcall(function() doc.CFrame=shredder.CFrame*CFrame.new(0,1,0) end) end
        pcall(function()
            for _,pp in ipairs(workspace:GetDescendants()) do
                if pp:IsA("ProximityPrompt") and pp.ActionText:lower():find("shred") then
                    fireproximityprompt(pp)
                end
            end
        end)
        task.wait(0.06)
    end
end)

mkSep("── RECYCLE")

mkTogBtn("Auto Recycle Piles","STOP","START",T.red,Color3.fromRGB(50,130,220),function(on)
    if on then startRecycle() else stopRecycle() end
end)

mkBtn("Recycle Once (nearest)",Color3.fromRGB(40,100,200),function()
    local bin=getBin(); if not bin then return end
    local piles=getShredPiles(); if #piles==0 then return end
    tpTo(bin.Position+Vector3.new(2,0,2)); task.wait(0.15)
    for _,p in ipairs(piles) do
        if not p.obj.Parent then continue end
        local ok=tryFireRemote(_recycleRemote,p.obj)
        if not ok then pcall(function() p.part.CFrame=bin.CFrame*CFrame.new(0,2,0) end) end
        pcall(function()
            for _,pp in ipairs(workspace:GetDescendants()) do
                if pp:IsA("ProximityPrompt") then
                    local a=pp.ActionText:lower()
                    if a:find("recycle") or a:find("throw") or a:find("bin") or a:find("drop") then
                        fireproximityprompt(pp)
                    end
                end
            end
        end)
        task.wait(0.08)
    end
end)

mkSep("── STATUS")
local _,statusL=mkStatus("idle")

local function mkInfo(label, getVal)
    local f=Instance.new("Frame",Body); f.Size=UDim2.new(1,0,0,14)
    f.BackgroundTransparency=1; f.BorderSizePixel=0
    local l=lb(f,{Size=UDim2.new(1,0,1,0),TextSize=7,TextColor3=T.dim,
        TextXAlignment=Enum.TextXAlignment.Left,
        Text=label..": "..tostring(getVal())})
    return l, function() l.Text=label..": "..tostring(getVal()) end
end

local docL, docU = mkInfo("docs found", function()
    local docs=getAllDocs(); return #docs
end)
local pileL, pileU = mkInfo("shred piles", function()
    local piles=getShredPiles(); return #piles
end)
local remL, remU = mkInfo("remotes", function()
    local s=_shredRemote and "S✓" or "S✗"
    local r=_recycleRemote and " R✓" or " R✗"
    return s..r
end)

task.spawn(function()
    while Win and Win.Parent do
        task.wait(1.5)
        pcall(docU); pcall(pileU); pcall(remU)
        local s=""
        if CFG.autoShred and CFG.autoRecycle then s="shredding + recycling"
        elseif CFG.autoShred then s="shredding..."
        elseif CFG.autoRecycle then s="recycling..."
        else s="idle" end
        statusL.Text=s
        statusL.TextColor3=CFG.autoShred or CFG.autoRecycle and T.grn or T.dim
    end
end)
