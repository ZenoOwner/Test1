-- ================================================================
-- PHANTOM SUITE - Made by Phantom / r9qbx
-- ================================================================

pcall(function()
    local sg2=Instance.new("ScreenGui") sg2.Name="PhantomLoader" sg2.ResetOnSpawn=false
    sg2.IgnoreGuiInset=true sg2.DisplayOrder=9999
    local ok=pcall(function() sg2.Parent=game:GetService("CoreGui") end)
    if not ok then sg2.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    local TS=game:GetService("TweenService")
    local function tw2(o,p,t) pcall(function() TS:Create(o,TweenInfo.new(t or 0.2,Enum.EasingStyle.Quad),p):Play() end) end
    local bg=Instance.new("Frame",sg2) bg.Size=UDim2.new(1,0,1,0)
    bg.BackgroundColor3=Color3.new(0,0,0) bg.BackgroundTransparency=0 bg.BorderSizePixel=0

    -- SOUNDS: parented to workspace Parts (guaranteed playback on mobile executors)
    local soundParts={}
    local function ps(id,vol)
        local p=Instance.new("Part",workspace) p.Anchored=true p.CanCollide=false p.Transparency=1
        p.Size=Vector3.new(0.1,0.1,0.1) p.Position=Vector3.new(0,0,0) p.Name="PhantomSound"
        local s=Instance.new("Sound",p) s.SoundId="rbxassetid://"..tostring(id)
        s.Volume=vol s.Looped=true s.RollOffMaxDistance=99999 s.RollOffMinDistance=99999
        pcall(function() s:Play() end)
        table.insert(soundParts,{p=p,s=s}) return s
    end
    ps(7570213552,0.8) ps(2738830850,0.5)

    local emojis={"💀","⚡","🔥","👾","☠️","💥","🚨","⚠️","🛑","👁️","💣","🔴","😱","🤖","🩸","☢️"}
    local emojiLabels={}
    for i=1,28 do
        local e=Instance.new("TextLabel",bg) e.BackgroundTransparency=1 e.Size=UDim2.fromOffset(64,64)
        e.Position=UDim2.new(math.random(0,90)/100,0,math.random(0,88)/100,0)
        e.Text=emojis[math.random(1,#emojis)] e.TextSize=math.random(38,60) e.Font=Enum.Font.GothamBlack
        e.TextColor3=Color3.new(1,0,0) e.ZIndex=2 table.insert(emojiLabels,e)
    end
    local flashing=true
    local flashColors={Color3.fromRGB(255,0,0),Color3.fromRGB(15,0,0),Color3.fromRGB(150,0,0),Color3.fromRGB(0,0,0),Color3.fromRGB(255,30,0),Color3.fromRGB(5,0,15),Color3.fromRGB(80,0,0),Color3.fromRGB(0,0,0)}
    task.spawn(function()
        while flashing do
            pcall(function()
                bg.BackgroundColor3=flashColors[math.random(1,#flashColors)]
                for _,e in ipairs(emojiLabels) do
                    e.Text=emojis[math.random(1,#emojis)]
                    local r=math.random(1,3)
                    e.TextColor3=r==1 and Color3.new(1,0,0) or r==2 and Color3.new(1,1,0) or Color3.fromRGB(255,0,100)
                    e.Position=UDim2.new(math.random(0,90)/100,0,math.random(0,88)/100,0)
                    e.TextSize=math.random(34,62)
                end
            end)
            task.wait(0.065)
        end
    end)
    local hackLbl=Instance.new("TextLabel",bg) hackLbl.Size=UDim2.new(1,0,0,90) hackLbl.Position=UDim2.new(0,0,0.5,-45)
    hackLbl.BackgroundTransparency=1 hackLbl.Text="YOU GOT HACKED" hackLbl.Font=Enum.Font.GothamBlack hackLbl.TextSize=68
    hackLbl.TextColor3=Color3.fromRGB(255,0,0) hackLbl.TextTransparency=1
    hackLbl.TextStrokeTransparency=0 hackLbl.TextStrokeColor3=Color3.fromRGB(255,200,0) hackLbl.ZIndex=3
    task.wait(2.2)
    tw2(hackLbl,{TextTransparency=0},0.22)
    task.spawn(function() for i=1,9 do task.wait(0.12) hackLbl.TextColor3=Color3.new(1,1,0) task.wait(0.09) hackLbl.TextColor3=Color3.new(1,0,0) end end)
    task.wait(1.8)
    flashing=false
    tw2(hackLbl,{TextTransparency=1},0.25)
    for _,e in ipairs(emojiLabels) do tw2(e,{TextTransparency=1},0.18) end
    task.wait(0.3)
    bg.BackgroundColor3=Color3.fromRGB(4,4,10)
    -- Fade out sirens over 3 seconds
    task.spawn(function()
        for i=1,24 do
            task.wait(0.12)
            for _,sp in ipairs(soundParts) do
                pcall(function() sp.s.Volume=math.max(0,sp.s.Volume-0.036) end)
            end
        end
        for _,sp in ipairs(soundParts) do pcall(function() sp.s:Stop() sp.p:Destroy() end) end
    end)
    -- Done sound
    pcall(function()
        local dp=Instance.new("Part",workspace) dp.Anchored=true dp.Transparency=1 dp.CanCollide=false dp.Size=Vector3.new(0.1,0.1,0.1)
        local ds=Instance.new("Sound",dp) ds.SoundId="rbxassetid://6895079813" ds.Volume=0.55
        ds.RollOffMaxDistance=99999 ds:Play()
        game:GetService("Debris"):AddItem(dp,4)
    end)
    local jkLbl=Instance.new("TextLabel",bg) jkLbl.Size=UDim2.new(1,0,0,62) jkLbl.Position=UDim2.new(0,0,0.33,-31)
    jkLbl.BackgroundTransparency=1 jkLbl.Text="Just kidding! 😂" jkLbl.Font=Enum.Font.GothamBlack jkLbl.TextSize=50
    jkLbl.TextColor3=Color3.fromRGB(120,255,70) jkLbl.TextTransparency=1 jkLbl.ZIndex=3
    local subLbl=Instance.new("TextLabel",bg) subLbl.Size=UDim2.new(1,0,0,30) subLbl.Position=UDim2.new(0,0,0.56,-15)
    subLbl.BackgroundTransparency=1 subLbl.Text="Enjoy the script  —  Made by Phantom / r9qbx"
    subLbl.Font=Enum.Font.GothamBold subLbl.TextSize=18 subLbl.TextColor3=Color3.fromRGB(35,205,255) subLbl.TextTransparency=1 subLbl.ZIndex=3
    tw2(jkLbl,{TextTransparency=0},0.4) task.wait(0.28) tw2(subLbl,{TextTransparency=0},0.4)
    task.wait(2.0)
    tw2(bg,{BackgroundTransparency=1},0.6) tw2(jkLbl,{TextTransparency=1},0.45) tw2(subLbl,{TextTransparency=1},0.45)
    task.wait(0.7) pcall(function() sg2:Destroy() end)
end)

-- ================================================================
-- MAIN SCRIPT
-- ================================================================
task.spawn(function()
local ok2,err=pcall(function()
repeat task.wait() until game:IsLoaded()

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local VIM=game:GetService("VirtualInputManager")
local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui")
local lp=Players.LocalPlayer
local Camera=workspace.CurrentCamera
local isMobile=UIS.TouchEnabled and not UIS.KeyboardEnabled

local C={
    BG=Color3.fromRGB(4,5,12),CARD=Color3.fromRGB(8,10,20),CARD2=Color3.fromRGB(12,15,28),
    TEXT=Color3.fromRGB(242,238,255),DIM=Color3.fromRGB(105,112,155),WHITE=Color3.new(1,1,1),
    AP=Color3.fromRGB(255,75,0),APD=Color3.fromRGB(40,10,0),
    MA=Color3.fromRGB(0,230,255),MAD=Color3.fromRGB(0,30,42),
    BK=Color3.fromRGB(255,30,60),BKD=Color3.fromRGB(42,5,10),
    TP=Color3.fromRGB(50,150,255),TPD=Color3.fromRGB(5,18,42),
    RS=Color3.fromRGB(255,195,0),RSD=Color3.fromRGB(42,30,0),
    ESP=Color3.fromRGB(185,80,255),ESPD=Color3.fromRGB(24,8,42),
    FR=Color3.fromRGB(255,50,180),FRD=Color3.fromRGB(42,5,28),
    GRAB=Color3.fromRGB(80,255,100),ON=Color3.fromRGB(60,240,80),OFF=Color3.fromRGB(20,22,38),
    GREEN=Color3.fromRGB(60,240,80),RED=Color3.fromRGB(255,40,55),BORD=Color3.fromRGB(35,42,80),
}

local BG_TR=0.28 local CARD_TR=0.22 local C2_TR=0.18

local function tw(o,p,t) TweenService:Create(o,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad),p):Play() end
local function co(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 8) end
local function stk(p,col,t,tr) local s=Instance.new("UIStroke",p) s.Color=col or C.BORD s.Thickness=t or 1 s.Transparency=tr or 0.3 return s end

local touchMoved=false local touchStartPos=Vector2.zero
UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then touchMoved=false touchStartPos=Vector2.new(i.Position.X,i.Position.Y) end end)
UIS.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then if(Vector2.new(i.Position.X,i.Position.Y)-touchStartPos).Magnitude>14 then touchMoved=true end end end)
local function safeClick(btn,fn) btn.MouseButton1Click:Connect(function() if isMobile and touchMoved then return end fn() end) end

local function makeDrag(f)
    local dg,dgs,dsp=false,nil,nil
    f.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true dgs=i.Position dsp=f.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)
        end
    end)
    f.InputChanged:Connect(function(i)
        if dg and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dgs if d.Magnitude>5 then f.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y) end
        end
    end)
end

pcall(function() if CoreGui:FindFirstChild("PhantomSuite") then CoreGui.PhantomSuite:Destroy() end end)
local sg=Instance.new("ScreenGui") sg.Name="PhantomSuite" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999
local _ok=pcall(function() sg.Parent=CoreGui end) if not _ok then sg.Parent=lp:WaitForChild("PlayerGui") end

local HOTKEY_FILE="PhantomHotkeys.json"
local hotkeys={AP=Enum.KeyCode.Unknown,BLOCK=Enum.KeyCode.Unknown,RESET=Enum.KeyCode.R,TP=Enum.KeyCode.T,ESP=Enum.KeyCode.Unknown,MINIAP=Enum.KeyCode.Unknown,FRIEND=Enum.KeyCode.Unknown}
pcall(function()
    if readfile and isfile and isfile(HOTKEY_FILE) then
        local d=HttpService:JSONDecode(readfile(HOTKEY_FILE))
        for k,v in pairs(d) do if hotkeys[k]~=nil then hotkeys[k]=Enum.KeyCode[v] or Enum.KeyCode.Unknown end end
    end
end)
local function saveHotkeys()
    if writefile then local d={} for k,v in pairs(hotkeys) do d[k]=v.Name end pcall(function() writefile(HOTKEY_FILE,HttpService:JSONEncode(d)) end) end
end
local waitingHotkey=nil

local function addWatermark(panel,accent)
    local wm=Instance.new("TextLabel",panel) wm.Size=UDim2.new(1,0,0,8) wm.BackgroundTransparency=1
    wm.Text="Made by Phantom / r9qbx" wm.Font=Enum.Font.Gotham wm.TextSize=6
    wm.TextColor3=accent or C.DIM wm.TextTransparency=0.48 wm.LayoutOrder=999
end

-- ====== AP CORE ======
local function fireBtn(b)
    pcall(function() for _,c in pairs(getconnections(b.MouseButton1Click)) do c:Fire() end end)
    pcall(function() for _,c in pairs(getconnections(b.Activated)) do c:Fire() end end)
end
local function findAP() return lp:WaitForChild("PlayerGui"):FindFirstChild("AdminPanel") end
local function getBtnKw(ap,kw)
    for _,o in ipairs(ap:GetDescendants()) do
        if o:IsA("TextButton") or o:IsA("ImageButton") then
            local t="" if o:IsA("TextButton") then t=o.Text:lower() else for _,c in ipairs(o:GetDescendants()) do if c:IsA("TextLabel") then t=c.Text:lower() break end end end
            if t:find(kw:lower()) then return o end
        end
    end
end
local function getPBtn(ap,target)
    for _,o in ipairs(ap:GetDescendants()) do
        if o:IsA("TextButton") or o:IsA("ImageButton") then
            local t="" if o:IsA("TextButton") then t=o.Text else for _,c in ipairs(o:GetDescendants()) do if c:IsA("TextLabel") then t=c.Text break end end end
            if t==target.Name or t==target.DisplayName then return o end
        end
    end
end
local function runCmds(target,cmds,jail)
    task.spawn(function()
        local ap=findAP() if not ap then return end
        for _,cmd in ipairs(cmds) do
            local pb=getPBtn(ap,target) if pb then fireBtn(pb) task.wait(0.08) end
            local cb=getBtnKw(ap,cmd) if cb then fireBtn(cb) task.wait(0.08) end
            local pb2=getPBtn(ap,target) if pb2 then fireBtn(pb2) task.wait(0.05) end
        end
        if jail then task.wait(1.5)
            local pb=getPBtn(ap,target) if pb then fireBtn(pb) task.wait(0.05) end
            local jb=getBtnKw(ap,"jail") if jb then fireBtn(jb) task.wait(0.05) end
            local pb2=getPBtn(ap,target) if pb2 then fireBtn(pb2) end
        end
    end)
end
local function runSingle(target,cmd)
    task.spawn(function()
        local ap=findAP() if not ap then return end
        local pb=getPBtn(ap,target) if pb then fireBtn(pb) task.wait(0.08) end
        local cb=getBtnKw(ap,cmd) if cb then fireBtn(cb) task.wait(0.08) end
        local pb2=getPBtn(ap,target) if pb2 then fireBtn(pb2) end
    end)
end

-- ====== ANTI RAGDOLL ======
RunService.Heartbeat:Connect(function()
    local c=lp.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    local h=c:FindFirstChildOfClass("Humanoid") if not h then return end
    local st=h:GetState()
    if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
        h:ChangeState(Enum.HumanoidStateType.Running) Camera.CameraSubject=h
        pcall(function() local pm=lp.PlayerScripts:FindFirstChild("PlayerModule") if pm then require(pm:FindFirstChild("ControlModule")):Enable() end end)
        if hrp then hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end
    end
    for _,o in ipairs(c:GetDescendants()) do if o:IsA("Motor6D") and not o.Enabled then o.Enabled=true end end
end)

-- ====== TIMER ESP ======
local timerESPs={}
RunService.RenderStepped:Connect(function()
    local plots=workspace:FindFirstChild("Plots") if not plots then return end
    local function mkTESP(plot,part)
        if timerESPs[plot.Name] then pcall(function() timerESPs[plot.Name].bb:Destroy() end) end
        local bb=Instance.new("BillboardGui") bb.Size=UDim2.fromOffset(72,22) bb.StudsOffset=Vector3.new(0,9,0)
        bb.AlwaysOnTop=true bb.Adornee=part bb.MaxDistance=1500 bb.Parent=plot
        local bg2=Instance.new("Frame",bb) bg2.Size=UDim2.new(1,0,1,0) bg2.BackgroundColor3=Color3.fromRGB(8,8,13)
        bg2.BackgroundTransparency=0.18 bg2.BorderSizePixel=0 co(bg2,5) stk(bg2,C.RS,1.5,0.2)
        local lbl=Instance.new("TextLabel",bg2) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Font=Enum.Font.GothamBold lbl.TextSize=11 lbl.TextColor3=C.RS
        lbl.TextStrokeTransparency=0.3 lbl.TextStrokeColor3=Color3.new(0,0,0)
        timerESPs[plot.Name]={bb=bb,lbl=lbl}
    end
    for _,plot in ipairs(plots:GetChildren()) do
        local pur=plot:FindFirstChild("Purchases") local pb2=pur and pur:FindFirstChild("PlotBlock")
        local mp=pb2 and pb2:FindFirstChild("Main")
        local tl=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
        if tl and mp then
            local e=timerESPs[plot.Name] if not e or not e.bb.Parent then mkTESP(plot,mp) e=timerESPs[plot.Name] end
            if e and e.lbl then e.lbl.Text=tl.Text
                local m,s=tl.Text:match("(%d+):(%d+)")
                if m and s then local tot=tonumber(m)*60+tonumber(s) e.lbl.TextColor3=tot<=30 and C.BK or tot<=60 and C.RS or C.GRAB end
            end
        else local e=timerESPs[plot.Name] if e then pcall(function() e.bb:Destroy() end) timerESPs[plot.Name]=nil end end
    end
end)

-- ====== PLAYER ESP ======
local playerESPOn=false local espConns={}
local function mkESP(plr)
    if plr==lp then return end
    local char=plr.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp or char:FindFirstChild("PhESP_Box") then return end
    local box=Instance.new("BoxHandleAdornment",char) box.Name="PhESP_Box" box.Adornee=hrp
    box.Size=Vector3.new(4,6,2) box.Color3=C.ESP box.Transparency=0.52 box.ZIndex=10 box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char) bb.Name="PhESP_Name" bb.Adornee=char:FindFirstChild("Head") or hrp
    bb.Size=UDim2.fromOffset(160,34) bb.StudsOffset=Vector3.new(0,3.5,0) bb.AlwaysOnTop=true
    local bg2=Instance.new("Frame",bb) bg2.Size=UDim2.new(1,0,1,0) bg2.BackgroundColor3=Color3.fromRGB(9,5,18)
    bg2.BackgroundTransparency=0.18 bg2.BorderSizePixel=0 co(bg2,5) stk(bg2,C.ESP,1.3,0.15)
    local nl=Instance.new("TextLabel",bg2) nl.Size=UDim2.new(1,0,0.6,0) nl.BackgroundTransparency=1
    nl.Text=plr.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=11 nl.TextColor3=C.ESP
    nl.TextStrokeTransparency=0.35 nl.TextStrokeColor3=Color3.new(0,0,0)
    local ul=Instance.new("TextLabel",bg2) ul.Size=UDim2.new(1,0,0.4,0) ul.Position=UDim2.new(0,0,0.6,0)
    ul.BackgroundTransparency=1 ul.Text="@"..plr.Name ul.Font=Enum.Font.Gotham ul.TextSize=8 ul.TextColor3=C.DIM
end
local function rmESP(plr) if plr.Character then local b=plr.Character:FindFirstChild("PhESP_Box") if b then b:Destroy() end local n=plr.Character:FindFirstChild("PhESP_Name") if n then n:Destroy() end end end
local function toggleESP(state)
    playerESPOn=state for _,c in ipairs(espConns) do c:Disconnect() end espConns={}
    if state then
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp then mkESP(p) end end
        table.insert(espConns,Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPOn then mkESP(p) end end) end))
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp then table.insert(espConns,p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPOn then mkESP(p) end end)) end end
    else for _,p in ipairs(Players:GetPlayers()) do rmESP(p) end end
end

-- ====== INSTA RESET ======
local cachedCF=nil local craftMachine=nil
local function updateCraftCache()
    craftMachine=workspace:FindFirstChild("CraftingMachine") if not craftMachine then return end
    local p=craftMachine:FindFirstChild("VFX",true) if not p then return end
    p=p:FindFirstChild("Secret",true) if not p then return end
    p=p:FindFirstChild("SoundPart",true) if p then cachedCF=p.CFrame end
end
updateCraftCache()
workspace.ChildAdded:Connect(function(c) if c.Name=="CraftingMachine" then task.defer(updateCraftCache) end end)
Players.RespawnTime=0
RunService.Heartbeat:Connect(function() if Players.RespawnTime~=0 then Players.RespawnTime=0 end end)
local resetBusy=false local resetStatusLbl=nil
local function doReset()
    if resetBusy then return end resetBusy=true
    local char=lp.Character if not char then resetBusy=false return end
    local hum=char:FindFirstChildOfClass("Humanoid") local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health<=0 then resetBusy=false return end
    if resetStatusLbl then resetStatusLbl.Text="RESETTING" resetStatusLbl.TextColor3=C.BK end
    Camera.CameraSubject=nil
    local conn; conn=lp.CharacterAdded:Connect(function(nc) conn:Disconnect() task.defer(function() local nh=nc:WaitForChild("Humanoid",1) if nh then Camera.CameraSubject=nh end end) end)
    if cachedCF then hrp.CFrame=cachedCF elseif craftMachine then updateCraftCache() if cachedCF then hrp.CFrame=cachedCF end end
    Players.RespawnTime=0 hum.Health=0 hum:ChangeState(Enum.HumanoidStateType.Dead) char:BreakJoints()
    task.wait(0.03) pcall(function() lp:LoadCharacter() end)
    task.delay(0.4,function() if resetStatusLbl then resetStatusLbl.Text="READY" resetStatusLbl.TextColor3=C.GREEN end resetBusy=false end)
end

-- ====== INSTANT STEAL ======
local isStealing=false local stealBarFill=nil local stealBarTxt=nil
local allAnimals={} local promptCache={} local stealCache={}
local GRAB_DIST=4.5
local function isMyPlot(n)
    local pl=workspace:FindFirstChild("Plots") if not pl then return false end
    local p=pl:FindFirstChild(n) if not p then return false end
    local sign=p:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase") if yb and yb:IsA("BillboardGui") then return yb.Enabled end end
    return false
end
local function scanPlots()
    local plots=workspace:FindFirstChild("Plots") if not plots then return end allAnimals={}
    for _,plot in ipairs(plots:GetChildren()) do
        if not isMyPlot(plot.Name) then
            local pods=plot:FindFirstChild("AnimalPodiums") if not pods then continue end
            for _,pod in ipairs(pods:GetChildren()) do
                local base=pod:FindFirstChild("Base") local spn=base and base:FindFirstChild("Spawn")
                local att=spn and spn:FindFirstChild("PromptAttachment")
                local wp=att and att.WorldPosition or pod:GetPivot().Position
                table.insert(allAnimals,{plotName=plot.Name,slot=pod.Name,worldPos=wp,uid=plot.Name..pod.Name})
            end
        end
    end
end
task.spawn(function() while task.wait(2) do scanPlots() end end)
local function findPrompt(a)
    if promptCache[a.uid] and promptCache[a.uid].Parent then return promptCache[a.uid] end
    local plots=workspace:FindFirstChild("Plots") if not plots then return nil end
    local plot=plots:FindFirstChild(a.plotName) if not plot then return nil end
    local pods=plot:FindFirstChild("AnimalPodiums") if not pods then return nil end
    local pod=pods:FindFirstChild(a.slot) if not pod then return nil end
    local base=pod:FindFirstChild("Base") local spn=base and base:FindFirstChild("Spawn")
    local att=spn and spn:FindFirstChild("PromptAttachment") if not att then return nil end
    for _,p in ipairs(att:GetChildren()) do if p:IsA("ProximityPrompt") then promptCache[a.uid]=p return p end end
end
local function buildCB(prompt)
    if stealCache[prompt] then return end
    local data={hold={},trigger={},ready=true}
    local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end end
    local ok2,c2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(c2)=="table" then for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trigger,c.Function) end end end
    stealCache[prompt]=data
end
local function execSteal(prompt)
    local data=stealCache[prompt] if not data or not data.ready or isStealing then return end
    data.ready=false isStealing=true
    if stealBarFill then tw(stealBarFill,{Size=UDim2.new(0.9,0,1,0),BackgroundColor3=C.GRAB},0.04) end
    if stealBarTxt then stealBarTxt.Text="GRABBING!" end
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        local t0=tick() local dur=0.08
        while tick()-t0<dur do
            if stealBarFill then stealBarFill.Size=UDim2.new(0.9+((tick()-t0)/dur)*0.1,0,1,0) tw(stealBarFill,{BackgroundColor3=C.GREEN},0.03) end
            task.wait()
        end
        if stealBarFill then stealBarFill.Size=UDim2.new(1,0,1,0) end
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        pcall(function() fireproximityprompt(prompt,0) end)
        task.wait(0.1) data.ready=true isStealing=false
        if stealBarFill then tw(stealBarFill,{Size=UDim2.new(0.9,0,1,0),BackgroundColor3=C.GRAB},0.1) end
        if stealBarTxt then stealBarTxt.Text="READY" end
    end)
end
RunService.Heartbeat:Connect(function()
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    if isStealing then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if stealBarFill then
        if not best then stealBarFill.Size=UDim2.new(0,0,1,0) tw(stealBarFill,{BackgroundColor3=C.GRAB},0.1)
        else stealBarFill.Size=UDim2.new(0.9,0,1,0) tw(stealBarFill,{BackgroundColor3=bd<=GRAB_DIST and C.GREEN or C.GRAB},0.08) end
    end
    if stealBarTxt then
        if not best then stealBarTxt.Text="NO TARGETS"
        elseif bd<=GRAB_DIST then stealBarTxt.Text="IN RANGE!"
        else stealBarTxt.Text=string.format("%.1fm  READY",bd) end
    end
    if not best or bd>GRAB_DIST then return end
    local prompt=promptCache[best.uid]
    if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt) if stealCache[prompt] then execSteal(prompt) end
end)

-- ====== TP ZONE ======
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        local part=Instance.new("Part",workspace) part.Name="PhantomTPZone"
        part.Shape=Enum.PartType.Ball part.Size=Vector3.new(3.5,3.5,3.5)
        part.Position=Vector3.new(-364.1,-7.3,82.4)
        part.Anchored=true part.CanCollide=false part.CastShadow=false
        part.Material=Enum.Material.Neon part.Color=C.TP part.Transparency=0.45
        TweenService:Create(part,TweenInfo.new(0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=0.72}):Play()
        local bb=Instance.new("BillboardGui",part) bb.Size=UDim2.fromOffset(220,30) bb.StudsOffset=Vector3.new(0,4,0) bb.AlwaysOnTop=true
        local bg3=Instance.new("Frame",bb) bg3.Size=UDim2.new(1,0,1,0) bg3.BackgroundColor3=Color3.fromRGB(4,14,32) bg3.BackgroundTransparency=0.1 bg3.BorderSizePixel=0 co(bg3,6)
        local bs=Instance.new("UIStroke",bg3) bs.Color=C.TP bs.Thickness=1.5 bs.Transparency=0.15
        TweenService:Create(bs,TweenInfo.new(0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=0.7}):Play()
        local lbl=Instance.new("TextLabel",bg3) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Text="📍 Stand here for best Fast TP" lbl.Font=Enum.Font.GothamBold lbl.TextSize=11
        lbl.TextColor3=C.TP lbl.TextStrokeTransparency=0.35 lbl.TextStrokeColor3=Color3.new(0,0,0)
    end)
end)

-- ====== CARPET ======
local function equipCarpet()
    local char=lp.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
    for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("carpet") or t.Name:lower():find("flying")) then return end end
    local bp=lp:FindFirstChildOfClass("Backpack") if not bp then return end
    for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("carpet") or t.Name:lower():find("flying")) then hum:EquipTool(t) return end end
end

-- ====== FAST TP ======
local WAYPOINTS={Vector3.new(-362.2,-7.3,70.9),Vector3.new(-360.6,-7.3,22.6),Vector3.new(-331.8,-5.1,22.7)}
local fastTPRunning=false local autoBlockAfterTP=false
local tpPillSetRef,tpLblRef,tpRSRef=nil,nil,nil
local doBlock

local function fastTeleportTo(pos)
    if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local r=lp.Character.HumanoidRootPart
        r.CFrame=CFrame.new(pos) r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero
    end
end

local function doFastTP(onDone)
    if fastTPRunning then fastTPRunning=false return end
    local char=lp.Character if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart") if not root then return end
    equipCarpet() task.wait(0.2) fastTPRunning=true
    task.spawn(function()
        for i=1,#WAYPOINTS do
            if not fastTPRunning or lp.Character~=char then break end
            fastTeleportTo(WAYPOINTS[i]) task.wait(0.02)
        end
        fastTPRunning=false
        scanPlots() task.wait(0.15)
        local hrp2=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp2 then
            local best2,bd2=nil,math.huge
            for _,a in ipairs(allAnimals) do local d=(hrp2.Position-a.worldPos).Magnitude if d<bd2 then bd2=d best2=a end end
            if best2 and bd2<=(GRAB_DIST+3) then
                local prompt=findPrompt(best2)
                if prompt then buildCB(prompt) if stealCache[prompt] then execSteal(prompt) end end
            end
        end
        if autoBlockAfterTP then task.spawn(function() doBlock(nil) end) end
        if onDone then onDone() end
    end)
end

-- ====== AUTO BLOCK ======
local blockCD=false
doBlock=function(target)
    if blockCD then return end blockCD=true
    local tgt=target
    if not tgt then
        local myR=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not myR then blockCD=false return end
        local best,bd=nil,math.huge
        for _,p in pairs(Players:GetPlayers()) do if p~=lp and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d=(myR.Position-r.Position).Magnitude if d<bd then bd=d best=p end end
        end end tgt=best
    end
    if not tgt then blockCD=false return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer",tgt) end)
    task.wait(0.4)
    local vp=Camera.ViewportSize
    for i=1,2 do
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.565,0,true,game,1)  task.wait(0.02)
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.565,0,false,game,1) task.wait(0.05)
    end
    task.wait(2) blockCD=false
end
local function doBlockAll()
    task.spawn(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp then
            pcall(function() StarterGui:SetCore("PromptBlockPlayer",p) end)
            task.wait(0.4)
            local vp=Camera.ViewportSize
            VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.565,0,true,game,1)  task.wait(0.02)
            VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.565,0,false,game,1)  task.wait(0.3)
        end end
    end)
end

-- ====== FRIEND - FIXED COMPLETELY ======
-- Simple: 1.8s cooldown applies to BOTH on and off.
-- Fires proximity prompts on EVERY toggle (on AND off).
local friendOn=false
local friendCD=false

local function fireFriendOnce()
    task.spawn(function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and(v.ActionText:lower():find("friend") or v.ObjectText:lower():find("friend")) then
                pcall(function() fireproximityprompt(v) end) task.wait(0.05)
            end
        end
    end)
end

-- ====== GUI HELPERS ======
local function makePill(parent,def,accentCol)
    accentCol=accentCol or C.ON
    local pw,ph=28,15
    local pill=Instance.new("Frame",parent) pill.Size=UDim2.fromOffset(pw,ph)
    pill.BackgroundColor3=def and accentCol or C.OFF pill.BorderSizePixel=0 co(pill,ph)
    local cir=Instance.new("Frame",pill) cir.Size=UDim2.fromOffset(ph-4,ph-4)
    cir.Position=def and UDim2.new(1,-(ph-2),0.5,-(ph-4)/2) or UDim2.new(0,2,0.5,-(ph-4)/2)
    cir.BackgroundColor3=Color3.new(1,1,1) cir.BorderSizePixel=0 co(cir,ph)
    local function setV(state,sRef)
        tw(pill,{BackgroundColor3=state and accentCol or C.OFF},0.12)
        tw(cir,{Position=state and UDim2.new(1,-(ph-2),0.5,-(ph-4)/2) or UDim2.new(0,2,0.5,-(ph-4)/2)},0.12,Enum.EasingStyle.Back)
        if sRef then tw(sRef,{Color=state and accentCol or C.BORD,Transparency=state and 0.05 or 0.38},0.12) end
    end
    return pill,setV
end

local function makePanel(name,w,startPos,accent,darkBg)
    accent=accent or C.AP darkBg=darkBg or C.BG
    local frame=Instance.new("Frame",sg) frame.Name=name frame.Size=UDim2.fromOffset(w,0)
    frame.Position=startPos or UDim2.fromOffset(8,32)
    frame.BackgroundColor3=darkBg frame.BackgroundTransparency=BG_TR
    frame.BorderSizePixel=0 frame.Active=true frame.AutomaticSize=Enum.AutomaticSize.Y
    co(frame,11) stk(frame,accent,1.8,0.4)
    local g=Instance.new("UIGradient",frame) g.Rotation=120
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(14,17,38)),ColorSequenceKeypoint.new(1,Color3.fromRGB(4,5,14))})
    makeDrag(frame)
    local uly=Instance.new("UIListLayout",frame) uly.SortOrder=Enum.SortOrder.LayoutOrder uly.Padding=UDim.new(0,0)
    local hdr=Instance.new("Frame",frame) hdr.Size=UDim2.new(1,0,0,28)
    hdr.BackgroundColor3=accent hdr.BackgroundTransparency=0.72 hdr.BorderSizePixel=0 hdr.LayoutOrder=1 co(hdr,11)
    local hfix=Instance.new("Frame",hdr) hfix.Size=UDim2.new(1,0,0.5,0) hfix.Position=UDim2.new(0,0,0.5,0) hfix.BackgroundColor3=accent hfix.BackgroundTransparency=0.72 hfix.BorderSizePixel=0
    local hline=Instance.new("Frame",hdr) hline.Size=UDim2.new(1,0,0,2) hline.BackgroundColor3=accent hline.BorderSizePixel=0 co(hline,2)
    local tlbl=Instance.new("TextLabel",hdr) tlbl.Size=UDim2.new(1,-58,1,0) tlbl.Position=UDim2.fromOffset(10,0)
    tlbl.BackgroundTransparency=1 tlbl.Text=name tlbl.Font=Enum.Font.GothamBlack tlbl.TextSize=10 tlbl.TextColor3=C.WHITE tlbl.TextXAlignment=Enum.TextXAlignment.Left
    local hkBtn=Instance.new("TextButton",hdr) hkBtn.Size=UDim2.fromOffset(22,15) hkBtn.Position=UDim2.new(1,-43,0.5,-7)
    hkBtn.BackgroundColor3=C.CARD hkBtn.BackgroundTransparency=0.1 hkBtn.BorderSizePixel=0 hkBtn.Text="?" hkBtn.Font=Enum.Font.GothamBold hkBtn.TextSize=7 hkBtn.TextColor3=accent hkBtn.AutoButtonColor=false
    co(hkBtn,5) stk(hkBtn,accent,1,0.4)
    local xBtn=Instance.new("TextButton",hdr) xBtn.Size=UDim2.fromOffset(18,18) xBtn.Position=UDim2.new(1,-22,0.5,-9)
    xBtn.BackgroundColor3=Color3.fromRGB(50,8,8) xBtn.BackgroundTransparency=0.1 xBtn.BorderSizePixel=0
    xBtn.Text="×" xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=14 xBtn.TextColor3=C.BK xBtn.AutoButtonColor=false co(xBtn,5)
    local cnt=Instance.new("Frame",frame) cnt.Size=UDim2.new(1,0,0,0) cnt.AutomaticSize=Enum.AutomaticSize.Y cnt.BackgroundTransparency=1 cnt.BorderSizePixel=0 cnt.LayoutOrder=2
    local pad=Instance.new("UIPadding",cnt) pad.PaddingTop=UDim.new(0,5) pad.PaddingBottom=UDim.new(0,6) pad.PaddingLeft=UDim.new(0,5) pad.PaddingRight=UDim.new(0,5)
    local cly=Instance.new("UIListLayout",cnt) cly.Padding=UDim.new(0,4) cly.SortOrder=Enum.SortOrder.LayoutOrder cly.HorizontalAlignment=Enum.HorizontalAlignment.Center
    addWatermark(cnt,accent)
    return frame,cnt,xBtn,hkBtn
end

local function makeRow(parent,label,order,accent)
    accent=accent or C.AP
    local row=Instance.new("Frame",parent) row.Size=UDim2.new(1,0,0,28) row.BackgroundColor3=C.CARD2 row.BackgroundTransparency=C2_TR row.BorderSizePixel=0 row.LayoutOrder=order co(row,7)
    local rs=stk(row,C.BORD,1,0.55)
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(0.62,0,1,0) lbl.Position=UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.Font=Enum.Font.GothamBold lbl.TextSize=10 lbl.TextColor3=C.TEXT lbl.TextXAlignment=Enum.TextXAlignment.Left
    return row,rs,lbl
end

local function makeBtn(parent,txt,col,order)
    col=col or C.AP
    local r2,g2,b2=col.R*255,col.G*255,col.B*255
    local btn=Instance.new("TextButton",parent) btn.Size=UDim2.new(1,0,0,26)
    btn.BackgroundColor3=Color3.fromRGB(math.floor(r2*0.1),math.floor(g2*0.1),math.floor(b2*0.1))
    btn.BackgroundTransparency=0.08 btn.BorderSizePixel=0 btn.Text=txt btn.Font=Enum.Font.GothamBold btn.TextSize=10 btn.TextColor3=col btn.AutoButtonColor=false btn.LayoutOrder=order or 99
    co(btn,7) stk(btn,col,1.2,0.25)
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundTransparency=0},0.08) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundTransparency=0.08},0.08) end)
    return btn
end

local function makeDivider(parent,col,order)
    local d=Instance.new("Frame",parent) d.Size=UDim2.new(1,0,0,1) d.BackgroundColor3=col or C.BORD d.BackgroundTransparency=0.4 d.BorderSizePixel=0 d.LayoutOrder=order
end

local function setupHK(slotName,hkBtn,defKey)
    if hotkeys[slotName]==Enum.KeyCode.Unknown and defKey then hotkeys[slotName]=defKey end
    local function upd() if not hkBtn.Parent then return end
        local k=hotkeys[slotName] local nm=k and k.Name or "?"
        hkBtn.Text=nm=="Unknown" and "?" or nm:sub(1,3) hkBtn.TextColor3=nm=="Unknown" and C.DIM or C.RS
    end upd()
    safeClick(hkBtn,function()
        waitingHotkey=slotName hkBtn.Text="·" hkBtn.TextColor3=C.BK
        task.spawn(function() while waitingHotkey==slotName do task.wait(0.1) end upd() end)
    end)
end

local function makeReopener(txt,pos,col,openFn)
    local b=Instance.new("TextButton",sg) b.Size=UDim2.fromOffset(38,22) b.Position=pos
    b.BackgroundColor3=C.CARD b.BackgroundTransparency=0.15 b.BorderSizePixel=0 b.Text=txt b.Font=Enum.Font.GothamBlack b.TextSize=8 b.TextColor3=col b.Visible=false b.ZIndex=20
    co(b,11) stk(b,col,1.5,0.2) safeClick(b,function() b.Visible=false openFn() end) return b
end

-- ====== STEAL BAR ======
local grabBar=Instance.new("Frame",sg) grabBar.Size=UDim2.fromOffset(172,20)
grabBar.AnchorPoint=Vector2.new(0.5,0) grabBar.Position=UDim2.new(0.5,0,0,6)
grabBar.BackgroundColor3=C.BG grabBar.BackgroundTransparency=BG_TR grabBar.BorderSizePixel=0 co(grabBar,8)
local gbTop=Instance.new("Frame",grabBar) gbTop.Size=UDim2.new(1,0,0,2) gbTop.BackgroundColor3=C.GRAB gbTop.BorderSizePixel=0 co(gbTop,2)
stk(grabBar,C.GRAB,1.5,0.2)
local gbBg=Instance.new("Frame",grabBar) gbBg.Size=UDim2.new(0.9,0,0,3) gbBg.Position=UDim2.new(0.05,0,1,-5) gbBg.BackgroundColor3=C.CARD2 gbBg.BackgroundTransparency=0.15 gbBg.BorderSizePixel=0 co(gbBg,3)
local gbFill=Instance.new("Frame",gbBg) gbFill.Size=UDim2.new(0.9,0,1,0) gbFill.BackgroundColor3=C.GRAB gbFill.BorderSizePixel=0 co(gbFill,3)
stealBarFill=gbFill
local gbTxt=Instance.new("TextLabel",grabBar) gbTxt.Size=UDim2.new(1,0,0.75,0) gbTxt.BackgroundTransparency=1
gbTxt.Text="PHANTOM GRAB" gbTxt.Font=Enum.Font.GothamBold gbTxt.TextSize=8 gbTxt.TextColor3=C.GRAB gbTxt.ZIndex=2
stealBarTxt=gbTxt

-- ====== PLOT CONTROL + FRIEND ======
local plotBox=Instance.new("Frame",sg)
plotBox.Size=UDim2.fromOffset(196,60)
plotBox.AnchorPoint=Vector2.new(0.5,0) plotBox.Position=UDim2.new(0.5,0,0,32)
plotBox.BackgroundColor3=C.FRD plotBox.BackgroundTransparency=BG_TR plotBox.BorderSizePixel=0 co(plotBox,10)
local pbStroke=stk(plotBox,C.FR,2,0.3)
local pbGrad=Instance.new("UIGradient",plotBox) pbGrad.Rotation=110
pbGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(38,6,28)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,3,16))})
local pbTopLine=Instance.new("Frame",plotBox) pbTopLine.Size=UDim2.new(1,0,0,2) pbTopLine.BackgroundColor3=C.FR pbTopLine.BorderSizePixel=0 co(pbTopLine,2)
makeDrag(plotBox)

local pbHdr=Instance.new("Frame",plotBox) pbHdr.Size=UDim2.new(1,0,0,22) pbHdr.Position=UDim2.fromOffset(0,2)
pbHdr.BackgroundColor3=C.FR pbHdr.BackgroundTransparency=0.7 pbHdr.BorderSizePixel=0
local pbTitle=Instance.new("TextLabel",pbHdr) pbTitle.Size=UDim2.new(1,-34,1,0) pbTitle.Position=UDim2.fromOffset(9,0)
pbTitle.BackgroundTransparency=1 pbTitle.Text="PLOT CONTROL" pbTitle.Font=Enum.Font.GothamBlack pbTitle.TextSize=9 pbTitle.TextColor3=C.WHITE
local fbHkBtn=Instance.new("TextButton",pbHdr) fbHkBtn.Size=UDim2.fromOffset(26,16) fbHkBtn.Position=UDim2.new(1,-30,0.5,-8)
fbHkBtn.BackgroundColor3=C.FRD fbHkBtn.BackgroundTransparency=0.05 fbHkBtn.BorderSizePixel=0
fbHkBtn.Text="?" fbHkBtn.Font=Enum.Font.GothamBold fbHkBtn.TextSize=7 fbHkBtn.TextColor3=C.FR fbHkBtn.AutoButtonColor=false
co(fbHkBtn,5) stk(fbHkBtn,C.FR,1,0.35)
setupHK("FRIEND",fbHkBtn,Enum.KeyCode.Unknown)

local pbDiv=Instance.new("Frame",plotBox) pbDiv.Size=UDim2.new(0.9,0,0,1) pbDiv.Position=UDim2.new(0.05,0,0,25)
pbDiv.BackgroundColor3=C.FR pbDiv.BackgroundTransparency=0.5 pbDiv.BorderSizePixel=0

local fbSection=Instance.new("Frame",plotBox) fbSection.Size=UDim2.new(1,0,0,34) fbSection.Position=UDim2.fromOffset(0,27)
fbSection.BackgroundTransparency=1 fbSection.BorderSizePixel=0
local fbLock=Instance.new("TextLabel",fbSection) fbLock.Size=UDim2.fromOffset(26,34) fbLock.Position=UDim2.fromOffset(7,0)
fbLock.BackgroundTransparency=1 fbLock.Text="🔒" fbLock.TextSize=16 fbLock.Font=Enum.Font.GothamBlack
local fbLbl=Instance.new("TextLabel",fbSection) fbLbl.Size=UDim2.new(1,-36,1,0) fbLbl.Position=UDim2.fromOffset(32,0)
fbLbl.BackgroundTransparency=1 fbLbl.Text="Allow Friends: OFF"
fbLbl.Font=Enum.Font.GothamBlack fbLbl.TextSize=11 fbLbl.TextColor3=C.WHITE fbLbl.TextXAlignment=Enum.TextXAlignment.Center

local fbClickBtn=Instance.new("TextButton",plotBox)
fbClickBtn.Size=UDim2.new(1,-30,1,0) fbClickBtn.BackgroundTransparency=1 fbClickBtn.Text="" fbClickBtn.ZIndex=5

local function setFriendBar(state)
    friendOn=state
    if state then
        tw(plotBox,{BackgroundColor3=Color3.fromRGB(4,36,10),BackgroundTransparency=BG_TR},0.18)
        pbGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(5,44,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,16,6))})
        TweenService:Create(pbStroke,TweenInfo.new(0.01),{Color=C.GREEN,Transparency=0.1}):Play()
        TweenService:Create(pbStroke,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=0.65,Color=C.GRAB}):Play()
        pbTopLine.BackgroundColor3=C.GREEN pbTitle.TextColor3=C.WHITE
        fbLbl.Text="Allow Friends: ON" fbLock.Text="🔓"
    else
        TweenService:Create(pbStroke,TweenInfo.new(0.01),{Color=C.FR,Transparency=0.3}):Play()
        tw(plotBox,{BackgroundColor3=C.FRD,BackgroundTransparency=BG_TR},0.18)
        pbGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(38,6,28)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,3,16))})
        pbTopLine.BackgroundColor3=C.FR pbTitle.TextColor3=C.WHITE
        fbLbl.Text="Allow Friends: OFF" fbLock.Text="🔒"
    end
end
setFriendBar(false)

-- FIXED: 1 click to toggle ON or OFF, fires prompts both ways, 1.8s cooldown total
safeClick(fbClickBtn,function()
    if friendCD then return end  -- cooldown blocks both directions equally
    friendCD=true
    setFriendBar(not friendOn)
    fireFriendOnce()  -- fires on BOTH on and off
    task.delay(1.8,function() friendCD=false end)
end)

-- ====== AP PANEL (left, y=100) ======
local APFr,APCnt,APX,APHk=makePanel("AP SPAM",148,UDim2.fromOffset(46,100),C.AP)
APFr.Visible=false
local APReo=makeReopener("AP",UDim2.fromOffset(46,100),C.AP,function() APFr.Visible=true end)
setupHK("AP",APHk,Enum.KeyCode.Unknown) safeClick(APX,function() APFr.Visible=false APReo.Visible=true end)
local apSFr=Instance.new("Frame",APCnt) apSFr.Size=UDim2.new(1,0,0,90) apSFr.BackgroundTransparency=1 apSFr.ClipsDescendants=true apSFr.LayoutOrder=1
local apScr=Instance.new("ScrollingFrame",apSFr) apScr.Size=UDim2.new(1,0,1,0) apScr.BackgroundTransparency=1 apScr.BorderSizePixel=0 apScr.ScrollBarThickness=2 apScr.ScrollBarImageColor3=C.AP apScr.CanvasSize=UDim2.new(0,0,0,0) apScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
local apSly=Instance.new("UIListLayout",apScr) apSly.Padding=UDim.new(0,3) apSly.SortOrder=Enum.SortOrder.LayoutOrder
local apSelLbl=Instance.new("TextLabel",APCnt) apSelLbl.Size=UDim2.new(1,0,0,9) apSelLbl.BackgroundTransparency=1 apSelLbl.Text="tap to target" apSelLbl.Font=Enum.Font.Gotham apSelLbl.TextSize=7 apSelLbl.TextColor3=C.DIM apSelLbl.LayoutOrder=2
makeDivider(APCnt,C.AP,3)
local selectedTarget=nil

local function buildAPCards()
    for _,c in ipairs(apScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    selectedTarget=nil
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame",apScr) card.Size=UDim2.new(1,-2,0,28) card.BackgroundColor3=C.CARD2 card.BackgroundTransparency=C2_TR card.BorderSizePixel=0 card.LayoutOrder=i co(card,6)
        local cst=stk(card,C.BORD,1,0.58)
        local av=Instance.new("ImageLabel",card) av.Size=UDim2.fromOffset(18,18) av.Position=UDim2.new(0,3,0.5,-9) av.BackgroundColor3=C.CARD av.BorderSizePixel=0 co(av,9)
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        local nl=Instance.new("TextLabel",card) nl.Size=UDim2.new(1,-25,0,12) nl.Position=UDim2.fromOffset(24,3) nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=8 nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",card) ul.Size=UDim2.new(1,-25,0,9) ul.Position=UDim2.fromOffset(24,14) ul.BackgroundTransparency=1 ul.Text=p.Name ul.Font=Enum.Font.Gotham ul.TextSize=6 ul.TextColor3=C.DIM ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local cb=Instance.new("TextButton",card) cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text="" cb.ZIndex=5
        local cap=p
        safeClick(cb,function()
            selectedTarget=cap
            for _,c2 in ipairs(apScr:GetChildren()) do if c2:IsA("Frame") then c2.BackgroundColor3=C.CARD2 c2.BackgroundTransparency=C2_TR local s2=c2:FindFirstChildOfClass("UIStroke") if s2 then s2.Color=C.BORD s2.Transparency=0.58 end end end
            card.BackgroundColor3=Color3.fromRGB(44,10,4) card.BackgroundTransparency=0 cst.Color=C.AP cst.Transparency=0.05
        end)
    end
end

local function getAPTarget()
    local t=selectedTarget if t and t.Parent then return t end
    local nearest,dist=nil,math.huge
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then for _,p in pairs(Players:GetPlayers()) do if p~=lp and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart") if r then local d=(r.Position-hrp.Position).Magnitude if d<dist then dist=d nearest=p end end
    end end end
    return nearest
end

local ragBtn=makeBtn(APCnt,"RAGDOLL",C.AP,4)
local allBtn=makeBtn(APCnt,"ALL CMDS",C.AP,5)
safeClick(ragBtn,function() local t=getAPTarget() if not t then return end ragBtn.Text="..." ragBtn.TextColor3=C.DIM runCmds(t,{"ragdoll"},false) task.delay(2,function() if ragBtn.Parent then ragBtn.Text="RAGDOLL" ragBtn.TextColor3=C.AP end end) end)
safeClick(allBtn,function() local t=getAPTarget() if not t then return end allBtn.Text="..." allBtn.TextColor3=C.DIM runCmds(t,{"rocket","inverse","tiny","jumpscare","morph","balloon"},true) task.delay(3,function() if allBtn.Parent then allBtn.Text="ALL CMDS" allBtn.TextColor3=C.AP end end) end)

-- ====== MINI AP PANEL ======
local MAFr,MACnt,MAX2,MAHk=makePanel("MINI AP",218,UDim2.fromOffset(202,100),C.MA)
MAFr.Visible=false
local MAReo=makeReopener("MA",UDim2.fromOffset(202,100),C.MA,function() MAFr.Visible=true end)
setupHK("MINIAP",MAHk,Enum.KeyCode.Unknown) safeClick(MAX2,function() MAFr.Visible=false MAReo.Visible=true end)
local maSFr=Instance.new("Frame",MACnt) maSFr.Size=UDim2.new(1,0,0,118) maSFr.BackgroundTransparency=1 maSFr.ClipsDescendants=true maSFr.LayoutOrder=1
local maScr=Instance.new("ScrollingFrame",maSFr) maScr.Size=UDim2.new(1,0,1,0) maScr.BackgroundTransparency=1 maScr.BorderSizePixel=0 maScr.ScrollBarThickness=2 maScr.ScrollBarImageColor3=C.MA maScr.CanvasSize=UDim2.new(0,0,0,0) maScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
local maSly=Instance.new("UIListLayout",maScr) maSly.Padding=UDim.new(0,3) maSly.SortOrder=Enum.SortOrder.LayoutOrder
local MINI_CMDS={{e="🎈",k="balloon",cd=29,col=Color3.fromRGB(55,115,255)},{e="🤸",k="ragdoll",cd=29,col=Color3.fromRGB(220,40,40)},{e="⛓",k="jail",cd=59,col=Color3.fromRGB(25,170,60)},{e="🚀",k="rocket",cd=119,col=Color3.fromRGB(220,120,20)},{e="🐜",k="tiny",cd=59,col=Color3.fromRGB(130,30,220)}}
local function buildMiniCards()
    for _,c in ipairs(maScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",maScr) row.Size=UDim2.new(1,-2,0,26) row.BackgroundColor3=C.CARD2 row.BackgroundTransparency=C2_TR row.BorderSizePixel=0 row.LayoutOrder=i co(row,5) stk(row,C.BORD,1,0.62)
        local av=Instance.new("ImageLabel",row) av.Size=UDim2.fromOffset(17,17) av.Position=UDim2.new(0,3,0.5,-8) av.BackgroundColor3=C.CARD av.BorderSizePixel=0 co(av,8)
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(0,26,0,11) nl.Position=UDim2.fromOffset(22,2) nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=7 nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",row) ul.Size=UDim2.new(0,26,0,8) ul.Position=UDim2.fromOffset(22,13) ul.BackgroundTransparency=1 ul.Text=p.Name ul.Font=Enum.Font.Gotham ul.TextSize=6 ul.TextColor3=C.DIM ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local xOff=50
        for _,cmd in ipairs(MINI_CMDS) do
            local btn=Instance.new("TextButton",row) btn.Size=UDim2.fromOffset(30,20) btn.Position=UDim2.new(0,xOff,0.5,-10) btn.BackgroundColor3=cmd.col btn.BackgroundTransparency=0.1 btn.BorderSizePixel=0 btn.Text=cmd.e btn.Font=Enum.Font.GothamBold btn.TextSize=11 btn.AutoButtonColor=false co(btn,5)
            local cdLbl=Instance.new("TextLabel",btn) cdLbl.Size=UDim2.new(1,0,1,0) cdLbl.BackgroundTransparency=1 cdLbl.Text="" cdLbl.Font=Enum.Font.GothamBold cdLbl.TextSize=7 cdLbl.TextColor3=Color3.new(1,1,1) cdLbl.ZIndex=2
            local onCD=false local captK=cmd.k local captP=p local captCD=cmd.cd local captCol=cmd.col
            safeClick(btn,function()
                if onCD then return end onCD=true local cdEnd=tick()+captCD btn.BackgroundColor3=Color3.fromRGB(40,10,10) btn.Text=""
                runSingle(captP,captK)
                task.spawn(function() while tick()<cdEnd do if cdLbl.Parent then cdLbl.Text=tostring(math.ceil(cdEnd-tick())) end task.wait(0.5) end if btn.Parent then btn.Text=cmd.e cdLbl.Text="" btn.BackgroundColor3=captCol end onCD=false end)
            end)
            xOff=xOff+32
        end
    end
end

-- ====== BLOCK PANEL (bottom-left) ======
local BKFr,BKCnt,BKX,BKHk=makePanel("BLOCK",148,UDim2.fromOffset(46,210),C.BK)
BKFr.Visible=false
local BKReo=makeReopener("BL",UDim2.fromOffset(46,210),C.BK,function() BKFr.Visible=true end)
setupHK("BLOCK",BKHk,Enum.KeyCode.Unknown) safeClick(BKX,function() BKFr.Visible=false BKReo.Visible=true end)
local baBtn2=makeBtn(BKCnt,"🚫  BLOCK ALL",C.BK,1)
safeClick(baBtn2,function() baBtn2.Text="blocking..." baBtn2.TextColor3=C.DIM doBlockAll() task.delay(5,function() if baBtn2.Parent then baBtn2.Text="🚫  BLOCK ALL" baBtn2.TextColor3=C.BK end end) end)
makeDivider(BKCnt,C.BK,2)
local bkSFr=Instance.new("Frame",BKCnt) bkSFr.Size=UDim2.new(1,0,0,90) bkSFr.BackgroundTransparency=1 bkSFr.ClipsDescendants=true bkSFr.LayoutOrder=3
local bkScr=Instance.new("ScrollingFrame",bkSFr) bkScr.Size=UDim2.new(1,0,1,0) bkScr.BackgroundTransparency=1 bkScr.BorderSizePixel=0 bkScr.ScrollBarThickness=2 bkScr.ScrollBarImageColor3=C.BK bkScr.CanvasSize=UDim2.new(0,0,0,0) bkScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
local bkSly=Instance.new("UIListLayout",bkScr) bkSly.Padding=UDim.new(0,3) bkSly.SortOrder=Enum.SortOrder.LayoutOrder
local function buildBlockList()
    for _,c in ipairs(bkScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",bkScr) row.Size=UDim2.new(1,-2,0,24) row.BackgroundColor3=C.CARD2 row.BackgroundTransparency=C2_TR row.BorderSizePixel=0 row.LayoutOrder=i co(row,5) stk(row,C.BORD,1,0.62)
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(1,-46,1,0) nl.Position=UDim2.fromOffset(4,0) nl.BackgroundTransparency=1 nl.Text=p.DisplayName.." · "..p.Name nl.Font=Enum.Font.GothamBold nl.TextSize=7 nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local bBtn=Instance.new("TextButton",row) bBtn.Size=UDim2.fromOffset(38,17) bBtn.Position=UDim2.new(1,-41,0.5,-8) bBtn.BackgroundColor3=C.BKD bBtn.BackgroundTransparency=0.05 bBtn.BorderSizePixel=0 bBtn.Text="BLOCK" bBtn.Font=Enum.Font.GothamBold bBtn.TextSize=7 bBtn.TextColor3=C.BK bBtn.AutoButtonColor=false co(bBtn,5) stk(bBtn,C.BK,1,0.3)
        local cap=p safeClick(bBtn,function() pcall(function() StarterGui:SetCore("PromptBlockPlayer",cap) end) end)
    end
end

-- ====== TP PANEL (top right) ======
local TPFr,TPCnt,TPX,TPHk=makePanel("FAST TP",144,UDim2.new(1,-152,0,100),C.TP)
local TPReo=makeReopener("TP",UDim2.new(1,-48,0,100),C.TP,function() TPFr.Visible=true end)
setupHK("TP",TPHk,Enum.KeyCode.T) safeClick(TPX,function() TPFr.Visible=false TPReo.Visible=true end)
local tpRow,tpRS,tpLbl2=makeRow(TPCnt,"Fast Teleport",1,C.TP)
local tpPill,tpPillSet=makePill(tpRow,false,C.TP) tpPill.Position=UDim2.new(1,-30,0.5,-7)
tpPillSetRef=tpPillSet tpLblRef=tpLbl2 tpRSRef=tpRS
local tpRowBtn=Instance.new("TextButton",tpRow) tpRowBtn.Size=UDim2.new(1,0,1,0) tpRowBtn.BackgroundTransparency=1 tpRowBtn.Text=""
safeClick(tpRowBtn,function()
    if fastTPRunning then fastTPRunning=false tpPillSet(false,tpRS) tpLbl2.Text="Fast Teleport"
    else tpPillSet(true,tpRS) tpLbl2.Text="Running..."
        doFastTP(function() tpPillSet(false,tpRS) tpLbl2.Text="Fast Teleport" end)
    end
end)
makeDivider(TPCnt,C.TP,2)
local abRow,abRS,abLbl=makeRow(TPCnt,"Auto Block on TP",3,C.BK)
local abPill,abPillSet=makePill(abRow,false,C.BK) abPill.Position=UDim2.new(1,-30,0.5,-7)
local abRowBtn=Instance.new("TextButton",abRow) abRowBtn.Size=UDim2.new(1,0,1,0) abRowBtn.BackgroundTransparency=1 abRowBtn.Text=""
safeClick(abRowBtn,function() autoBlockAfterTP=not autoBlockAfterTP abPillSet(autoBlockAfterTP,abRS) end)
local blkNow=makeBtn(TPCnt,"🚫  BLOCK NOW",C.BK,4)
safeClick(blkNow,function() blkNow.Text="..." blkNow.TextColor3=C.DIM task.spawn(function() doBlock(nil) if blkNow.Parent then blkNow.Text="🚫  BLOCK NOW" blkNow.TextColor3=C.BK end end) end)
makeDivider(TPCnt,C.ESP,5)
local espRow,espRS,espLbl2=makeRow(TPCnt,"Player ESP",6,C.ESP)
local espPill,espPillSet=makePill(espRow,false,C.ESP) espPill.Position=UDim2.new(1,-30,0.5,-7)
local espRowBtn=Instance.new("TextButton",espRow) espRowBtn.Size=UDim2.new(1,0,1,0) espRowBtn.BackgroundTransparency=1 espRowBtn.Text=""
safeClick(espRowBtn,function() playerESPOn=not playerESPOn espPillSet(playerESPOn,espRS) toggleESP(playerESPOn) end)

-- ====== RESET PANEL (below TP) ======
local RSFr,RSCnt,RSX,RSHk=makePanel("RESET",144,UDim2.new(1,-152,0,100),C.RS)
setupHK("RESET",RSHk,Enum.KeyCode.R)
local RSReoBtn=makeReopener("RST",UDim2.new(1,-48,0,100),C.RS,function() RSFr.Visible=true end)
local function positionReset()
    if not TPFr.Parent or not RSFr.Parent then return end
    local tpP=TPFr.AbsolutePosition local tpS=TPFr.AbsoluteSize
    RSFr.Position=UDim2.fromOffset(tpP.X,tpP.Y+tpS.Y+5)
    RSReoBtn.Position=UDim2.fromOffset(tpP.X+tpS.X-42,tpP.Y+tpS.Y+5)
end
task.spawn(function() task.wait(0.3) positionReset() TPFr:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionReset) TPFr:GetPropertyChangedSignal("AbsolutePosition"):Connect(positionReset) end)
safeClick(RSX,function() RSFr.Visible=false RSReoBtn.Visible=true end)
local rstBtn=makeBtn(RSCnt,"💀  INSTA RESET",C.RS,1) safeClick(rstBtn,doReset)
makeDivider(RSCnt,C.RS,2)
local rsStatRow=Instance.new("Frame",RSCnt) rsStatRow.Size=UDim2.new(1,0,0,18) rsStatRow.BackgroundColor3=C.CARD2 rsStatRow.BackgroundTransparency=C2_TR rsStatRow.BorderSizePixel=0 rsStatRow.LayoutOrder=3 co(rsStatRow,6) stk(rsStatRow,C.BORD,1,0.58)
local rsStatLbl=Instance.new("TextLabel",rsStatRow) rsStatLbl.Size=UDim2.new(0.6,0,1,0) rsStatLbl.Position=UDim2.fromOffset(6,0) rsStatLbl.BackgroundTransparency=1 rsStatLbl.Text="READY" rsStatLbl.Font=Enum.Font.GothamBold rsStatLbl.TextSize=8 rsStatLbl.TextColor3=C.GREEN rsStatLbl.TextXAlignment=Enum.TextXAlignment.Left
resetStatusLbl=rsStatLbl
local rKLbl=Instance.new("TextLabel",rsStatRow) rKLbl.Size=UDim2.new(0.4,0,1,0) rKLbl.Position=UDim2.new(0.6,0,0,0) rKLbl.BackgroundTransparency=1 rKLbl.Text="[R]" rKLbl.Font=Enum.Font.Gotham rKLbl.TextSize=7 rKLbl.TextColor3=C.DIM

-- ====== HOTKEYS PANEL (center on load) ======
local SHFr,SHCnt,SHX,_=makePanel("HOTKEYS",150,UDim2.new(0.5,-75,0.5,-50),C.ESP)
SHFr.Visible=true
local shrLbl=Instance.new("TextLabel",SHCnt) shrLbl.Size=UDim2.new(1,0,0,20) shrLbl.BackgroundTransparency=1 shrLbl.Text="Set hotkeys on each panel then save." shrLbl.Font=Enum.Font.GothamMedium shrLbl.TextSize=8 shrLbl.TextColor3=C.DIM shrLbl.TextWrapped=true shrLbl.LayoutOrder=1
local saveBtn=makeBtn(SHCnt,"💾  SAVE HOTKEYS",C.ESP,2)
local closeHKBtn=makeBtn(SHCnt,"✓  Done",C.GREEN,3)
safeClick(saveBtn,function() saveHotkeys() saveBtn.Text="Saved! ✓" saveBtn.TextColor3=C.GREEN task.delay(1.5,function() if saveBtn.Parent then saveBtn.Text="💾  SAVE HOTKEYS" saveBtn.TextColor3=C.ESP end end) end)
safeClick(closeHKBtn,function() SHFr.Visible=false end) safeClick(SHX,function() SHFr.Visible=false end)

-- ====== BUTTONS: pill buttons at bottom-left ======
local btnBar=Instance.new("Frame",sg)
btnBar.Size=UDim2.fromOffset(0,36)
btnBar.Position=UDim2.new(0,6,1,-48)
btnBar.BackgroundTransparency=1 btnBar.AutomaticSize=Enum.AutomaticSize.X
btnBar.BorderSizePixel=0
local btnBarLy=Instance.new("UIListLayout",btnBar) btnBarLy.FillDirection=Enum.FillDirection.Horizontal btnBarLy.Padding=UDim.new(0,5) btnBarLy.VerticalAlignment=Enum.VerticalAlignment.Center

local function bottomBtn(label,col,cb2)
    local f=Instance.new("Frame",btnBar) f.Size=UDim2.fromOffset(42,34)
    f.BackgroundColor3=C.CARD f.BackgroundTransparency=CARD_TR f.BorderSizePixel=0 co(f,12)
    local fs2=stk(f,col,1.8,0.25)
    local dot=Instance.new("Frame",f) dot.Size=UDim2.fromOffset(4,4) dot.Position=UDim2.new(0.5,-2,0,3) dot.BackgroundColor3=col dot.BorderSizePixel=0 co(dot,4)
    TweenService:Create(dot,TweenInfo.new(0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.78}):Play()
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=label b.Font=Enum.Font.GothamBlack b.TextSize=10 b.TextColor3=col b.BorderSizePixel=0 b.AutoButtonColor=false
    b.MouseEnter:Connect(function() tw(f,{BackgroundTransparency=0},0.1) tw(fs2,{Transparency=0},0.1) end)
    b.MouseLeave:Connect(function() tw(f,{BackgroundTransparency=CARD_TR},0.1) tw(fs2,{Transparency=0.25},0.1) end)
    safeClick(b,cb2)
end

bottomBtn("AP",C.AP,function()
    local v=not APFr.Visible APFr.Visible=v MAFr.Visible=v APReo.Visible=not v MAReo.Visible=not v
    if v then buildAPCards() buildMiniCards() end
end)
bottomBtn("BL",C.BK,function()
    BKFr.Visible=not BKFr.Visible BKReo.Visible=not BKFr.Visible if BKFr.Visible then buildBlockList() end
end)
bottomBtn("TP",C.TP,function()
    TPFr.Visible=not TPFr.Visible RSFr.Visible=TPFr.Visible TPReo.Visible=not TPFr.Visible RSReoBtn.Visible=not RSFr.Visible
end)
bottomBtn("RST",C.RS,function()
    RSFr.Visible=not RSFr.Visible RSReoBtn.Visible=not RSFr.Visible
end)

-- ====== MOBILE SHORTCUTS (right side, 3 only) ======
if isMobile then
    local function mobBtn(txt,yOff,col,cb2)
        local f=Instance.new("Frame",sg) f.Size=UDim2.fromOffset(46,46) f.Position=UDim2.new(1,-52,0.5,yOff)
        f.BackgroundColor3=C.CARD f.BackgroundTransparency=CARD_TR f.BorderSizePixel=0 co(f,14) stk(f,col,1.8,0.2)
        local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=8 b.TextColor3=col b.BorderSizePixel=0
        safeClick(b,cb2)
    end
    mobBtn("FAST\nTP",-68,C.TP,function()
        if fastTPRunning then fastTPRunning=false tpPillSet(false,tpRS) tpLbl2.Text="Fast Teleport"
        else tpPillSet(true,tpRS) tpLbl2.Text="Running..." doFastTP(function() tpPillSet(false,tpRS) tpLbl2.Text="Fast Teleport" end) end
    end)
    mobBtn("BLOCK",-18,C.BK,function() task.spawn(function() doBlock(nil) end) end)
    mobBtn("RESET",32,C.RS,function() doReset() end)
end

-- ====== PLAYER LIST MANAGEMENT ======
local function doRefresh()
    if APFr.Visible then buildAPCards() end
    if MAFr.Visible then buildMiniCards() end
    if BKFr.Visible then buildBlockList() end
    if playerESPOn then for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character and not p.Character:FindFirstChild("PhESP_Box") then mkESP(p) end end end
end
local function hookPlayer(p)
    if p==lp then return end
    p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPOn then mkESP(p) end task.spawn(doRefresh) end)
    if p.Character and playerESPOn then task.spawn(function() mkESP(p) end) end
end
for _,p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(function(p) hookPlayer(p) task.wait(0.5) task.spawn(doRefresh) end)
Players.PlayerRemoving:Connect(function(p) if selectedTarget==p then selectedTarget=nil end task.spawn(function() task.wait(0.1) doRefresh() end) end)
task.spawn(function() while sg.Parent do task.wait(8) task.spawn(doRefresh) end end)

task.spawn(function()
    while sg.Parent do task.wait(0.4)
        if apSelLbl.Parent then local t=selectedTarget if t and t.Parent then apSelLbl.Text="→ "..t.DisplayName apSelLbl.TextColor3=C.AP else apSelLbl.Text="tap to target" apSelLbl.TextColor3=C.DIM end end
        if rKLbl.Parent then local k=hotkeys.RESET rKLbl.Text="[".. (k and k.Name~="Unknown" and k.Name:sub(1,3) or "?") .."]" end
    end
end)

-- ====== INPUT ======
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if UIS:GetFocusedTextBox() then return end
    if waitingHotkey then
        if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode~=Enum.KeyCode.Unknown then
            hotkeys[waitingHotkey]=inp.KeyCode waitingHotkey=nil end return
    end
    if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
    if inp.KeyCode==hotkeys.RESET then doReset() end
    if inp.KeyCode==hotkeys.TP then
        if fastTPRunning then fastTPRunning=false tpPillSet(false,tpRS) tpLbl2.Text="Fast Teleport"
        else tpPillSet(true,tpRS) tpLbl2.Text="Running..." doFastTP(function() tpPillSet(false,tpRS) tpLbl2.Text="Fast Teleport" end) end
    end
    if inp.KeyCode==hotkeys.AP then local v=not APFr.Visible APFr.Visible=v MAFr.Visible=v APReo.Visible=not v MAReo.Visible=not v if v then buildAPCards() buildMiniCards() end end
    if inp.KeyCode==hotkeys.BLOCK then BKFr.Visible=not BKFr.Visible BKReo.Visible=not BKFr.Visible if BKFr.Visible then buildBlockList() end end
    if inp.KeyCode==hotkeys.ESP then playerESPOn=not playerESPOn espPillSet(playerESPOn,espRS) toggleESP(playerESPOn) end
    if inp.KeyCode==hotkeys.FRIEND then
        if friendCD then return end
        friendCD=true
        setFriendBar(not friendOn)
        fireFriendOnce()
        task.delay(1.8,function() friendCD=false end)
    end
end)

task.spawn(function() task.wait(1) buildAPCards() buildMiniCards() buildBlockList() end)

end)
if not ok2 then warn("[PhantomSuite] Error: "..tostring(err)) end
end)
