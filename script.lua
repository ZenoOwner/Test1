task.spawn(function()
repeat task.wait() until game:IsLoaded()

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local VIM=game:GetService("VirtualInputManager")
local ProximityPromptService=game:GetService("ProximityPromptService")
local CoreGui=game:GetService("CoreGui")
local lp=Players.LocalPlayer
local Camera=workspace.CurrentCamera

-- ====== COLORS ======
local C={
    BG=Color3.fromRGB(8,8,12),CARD=Color3.fromRGB(13,13,19),CARD2=Color3.fromRGB(18,18,26),
    BORD=Color3.fromRGB(38,38,56),TEXT=Color3.fromRGB(228,225,245),DIM=Color3.fromRGB(92,88,118),
    LIME=Color3.fromRGB(120,255,70),CYAN=Color3.fromRGB(35,205,255),
    CORAL=Color3.fromRGB(255,75,75),AMBER=Color3.fromRGB(255,185,25),
    ELEC=Color3.fromRGB(155,80,255),ON=Color3.fromRGB(55,215,75),
    OFF=Color3.fromRGB(28,28,42),GREEN=Color3.fromRGB(50,220,95),RED=Color3.fromRGB(220,55,55),
}
local function tw(o,p,t) TweenService:Create(o,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad),p):Play() end
local function co(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 8) end
local function stk(p,col,t) local s=Instance.new("UIStroke",p) s.Color=col or C.BORD s.Thickness=t or 1 s.Transparency=0.2 return s end
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
            local d=i.Position-dgs f.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y)
        end
    end)
end

-- ====== SCREENGUI ======
pcall(function() if CoreGui:FindFirstChild("PhantomSuite") then CoreGui.PhantomSuite:Destroy() end end)
local sg=Instance.new("ScreenGui") sg.Name="PhantomSuite" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999
local _ok=pcall(function() sg.Parent=CoreGui end) if not _ok then sg.Parent=lp:WaitForChild("PlayerGui") end

-- ====== HOTKEYS ======
local hotkeys={AP=Enum.KeyCode.Unknown,BLOCK=Enum.KeyCode.Unknown,RESET=Enum.KeyCode.R,TP=Enum.KeyCode.T,ESP=Enum.KeyCode.Unknown,MINIAP=Enum.KeyCode.Unknown}
local waitingHotkey=nil

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

-- ====== ANTI RAGDOLL + ANTI KNOCKBACK ======
RunService.Heartbeat:Connect(function()
    local c=lp.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    local h=c:FindFirstChildOfClass("Humanoid") if not h then return end
    local st=h:GetState()
    if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
        h:ChangeState(Enum.HumanoidStateType.Running)
        Camera.CameraSubject=h
        pcall(function()
            local pm=lp.PlayerScripts:FindFirstChild("PlayerModule")
            if pm then require(pm:FindFirstChild("ControlModule")):Enable() end
        end)
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
        local bg=Instance.new("Frame",bb) bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(8,8,13)
        bg.BackgroundTransparency=0.12 bg.BorderSizePixel=0 co(bg,5) stk(bg,C.AMBER,1.5)
        local lbl=Instance.new("TextLabel",bg) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Font=Enum.Font.GothamBold lbl.TextSize=11 lbl.TextColor3=C.AMBER
        lbl.TextStrokeTransparency=0.3 lbl.TextStrokeColor3=Color3.new(0,0,0)
        timerESPs[plot.Name]={bb=bb,lbl=lbl}
    end
    for _,plot in ipairs(plots:GetChildren()) do
        local pur=plot:FindFirstChild("Purchases") local pb=pur and pur:FindFirstChild("PlotBlock")
        local mp=pb and pb:FindFirstChild("Main")
        local tl=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
        if tl and mp then
            local e=timerESPs[plot.Name] if not e or not e.bb.Parent then mkTESP(plot,mp) e=timerESPs[plot.Name] end
            if e and e.lbl then
                e.lbl.Text=tl.Text
                local m,s=tl.Text:match("(%d+):(%d+)")
                if m and s then local tot=tonumber(m)*60+tonumber(s) e.lbl.TextColor3=tot<=30 and C.CORAL or tot<=60 and C.AMBER or C.LIME end
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
    box.Size=Vector3.new(4,6,2) box.Color3=C.ELEC box.Transparency=0.55 box.ZIndex=10 box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char) bb.Name="PhESP_Name" bb.Adornee=char:FindFirstChild("Head") or hrp
    bb.Size=UDim2.fromOffset(165,36) bb.StudsOffset=Vector3.new(0,3.5,0) bb.AlwaysOnTop=true
    local bg=Instance.new("Frame",bb) bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(9,7,16)
    bg.BackgroundTransparency=0.15 bg.BorderSizePixel=0 co(bg,5) stk(bg,C.ELEC,1.3)
    local nl=Instance.new("TextLabel",bg) nl.Size=UDim2.new(1,0,0.62,0) nl.BackgroundTransparency=1
    nl.Text=plr.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=11 nl.TextColor3=C.ELEC
    nl.TextStrokeTransparency=0.4 nl.TextStrokeColor3=Color3.new(0,0,0)
    local ul=Instance.new("TextLabel",bg) ul.Size=UDim2.new(1,0,0.38,0) ul.Position=UDim2.new(0,0,0.62,0)
    ul.BackgroundTransparency=1 ul.Text="@"..plr.Name ul.Font=Enum.Font.Gotham ul.TextSize=8 ul.TextColor3=C.DIM
end
local function rmESP(plr)
    if plr.Character then
        local b=plr.Character:FindFirstChild("PhESP_Box") if b then b:Destroy() end
        local n=plr.Character:FindFirstChild("PhESP_Name") if n then n:Destroy() end
    end
end
local function toggleESP(state)
    playerESPOn=state
    for _,c in ipairs(espConns) do c:Disconnect() end espConns={}
    if state then
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp then mkESP(p) end end
        table.insert(espConns,Players.PlayerAdded:Connect(function(p)
            table.insert(espConns,p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPOn then mkESP(p) end end))
        end))
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp then
            table.insert(espConns,p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPOn then mkESP(p) end end))
        end end
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
    if resetStatusLbl then resetStatusLbl.Text="RESETTING" resetStatusLbl.TextColor3=C.CORAL end
    Camera.CameraSubject=nil
    local conn; conn=lp.CharacterAdded:Connect(function(nc)
        conn:Disconnect() task.defer(function() local nh=nc:WaitForChild("Humanoid",1) if nh then Camera.CameraSubject=nh end end)
    end)
    if cachedCF then hrp.CFrame=cachedCF elseif craftMachine then updateCraftCache() if cachedCF then hrp.CFrame=cachedCF end end
    Players.RespawnTime=0 hum.Health=0 hum:ChangeState(Enum.HumanoidStateType.Dead) char:BreakJoints()
    task.wait(0.03) pcall(function() lp:LoadCharacter() end)
    task.delay(0.4,function()
        if resetStatusLbl then resetStatusLbl.Text="READY" resetStatusLbl.TextColor3=C.GREEN end
        resetBusy=false
    end)
end

-- ====== INSTANT STEAL ======
local isStealing=false local stealBarFill=nil
local allAnimals={} local promptCache={} local stealCache={}
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
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        local t0=tick() local dur=0.08
        while tick()-t0<dur do
            -- 90% to 100% during execution
            if stealBarFill then stealBarFill.Size=UDim2.new(0.9+((tick()-t0)/dur)*0.1,0,1,0) end
            task.wait()
        end
        if stealBarFill then stealBarFill.Size=UDim2.new(1,0,1,0) end
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        pcall(function() fireproximityprompt(prompt,0) end)
        task.wait(0.1) data.ready=true isStealing=false
        if stealBarFill then stealBarFill.Size=UDim2.new(0,0,1,0) end
    end)
end
-- Distance bar + steal trigger
RunService.Heartbeat:Connect(function()
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    -- bar: 0-50% from 40-7 studs, snap to 90% at 6 studs
    if stealBarFill and not isStealing then
        if not best then stealBarFill.Size=UDim2.new(0,0,1,0)
        elseif bd<=6 then stealBarFill.Size=UDim2.new(0.9,0,1,0)
        elseif bd<=40 then stealBarFill.Size=UDim2.new(math.clamp(0.5*(1-(bd-6)/34),0,0.5),0,1,0)
        else stealBarFill.Size=UDim2.new(0,0,1,0) end
    end
    if isStealing or not best or bd>6 then return end
    local prompt=promptCache[best.uid]
    if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt) if stealCache[prompt] then execSteal(prompt) end
end)

-- ====== FAST TP (exact from 706) ======
local WAYPOINTS={
    Vector3.new(-357.30,-7.00,113.60),Vector3.new(-381.00,-7.00,-43.50),
    Vector3.new(-412.43,-6.50,102.23),Vector3.new(-411.05,-6.50,54.73),
    Vector3.new(-410.00,-6.50,-14.58),Vector3.new(-377.28,-7.00,14.31),
    Vector3.new(-345.77,-7.00,17.01), Vector3.new(-332.52,-4.79,18.41),
}
local fastTPRunning=false local autoBlockAfterTP=false
local tpPillSetRef=nil local tpNameLblRef=nil local tpRSRef=nil
local function fastTeleportTo(pos)
    if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local r=lp.Character.HumanoidRootPart
        r.CFrame=CFrame.new(pos) r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero
    end
end
local doBlock -- forward declare
local function doFastTP(onDone)
    if fastTPRunning then fastTPRunning=false return end
    local char=lp.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    fastTPRunning=true
    task.spawn(function()
        for i=1,#WAYPOINTS do
            if not fastTPRunning or lp.Character~=char then break end
            fastTeleportTo(WAYPOINTS[i]) task.wait(0.01)
        end
        fastTPRunning=false
        if autoBlockAfterTP then task.spawn(function() doBlock(nil) end) end
        if onDone then onDone() end
    end)
end

-- ====== AUTO BLOCK (exact from 706) ======
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
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.54,0,true,game,1) task.wait(0.02)
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.54,0,false,game,1) task.wait(0.05)
    end
    task.wait(2) blockCD=false
end
local function doBlockAll()
    task.spawn(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp then
            pcall(function() StarterGui:SetCore("PromptBlockPlayer",p) end)
            task.wait(0.4)
            local vp=Camera.ViewportSize
            VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.54,0,true,game,1) task.wait(0.02)
            VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.54,0,false,game,1) task.wait(0.3)
        end end
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
        if sRef then tw(sRef,{Color=state and accentCol or C.BORD,Transparency=state and 0.05 or 0.25},0.12) end
    end
    return pill,setV
end

-- makePanel: returns frame, content, xBtn, hkBtn
local function makePanel(name,w,startPos,accent)
    accent=accent or C.LIME
    local frame=Instance.new("Frame",sg) frame.Name=name frame.Size=UDim2.fromOffset(w,0)
    frame.Position=startPos or UDim2.fromOffset(8,32) frame.BackgroundColor3=C.BG
    frame.BackgroundTransparency=0.05 frame.BorderSizePixel=0 frame.Active=true
    frame.AutomaticSize=Enum.AutomaticSize.Y
    co(frame,10) stk(frame,accent,1.5).Transparency=0.25 makeDrag(frame)
    local fly=Instance.new("UIListLayout",frame) fly.SortOrder=Enum.SortOrder.LayoutOrder fly.Padding=UDim.new(0,0)
    -- header
    local hdr=Instance.new("Frame",frame) hdr.Size=UDim2.new(1,0,0,28) hdr.BackgroundColor3=C.CARD
    hdr.BackgroundTransparency=0.05 hdr.BorderSizePixel=0 hdr.LayoutOrder=1
    -- accent line
    local al=Instance.new("Frame",hdr) al.Size=UDim2.new(1,0,0,2) al.BackgroundColor3=accent al.BorderSizePixel=0 co(al,2)
    -- dot
    local dot=Instance.new("Frame",hdr) dot.Size=UDim2.fromOffset(6,6) dot.Position=UDim2.fromOffset(9,11)
    dot.BackgroundColor3=accent dot.BorderSizePixel=0 co(dot,6)
    -- title
    local tlbl=Instance.new("TextLabel",hdr) tlbl.Size=UDim2.new(1,-52,1,0) tlbl.Position=UDim2.fromOffset(20,0)
    tlbl.BackgroundTransparency=1 tlbl.Text=name tlbl.Font=Enum.Font.GothamBlack tlbl.TextSize=10
    tlbl.TextColor3=accent tlbl.TextXAlignment=Enum.TextXAlignment.Left
    -- hotkey btn (clickable to bind)
    local hkBtn=Instance.new("TextButton",hdr) hkBtn.Size=UDim2.fromOffset(24,16) hkBtn.Position=UDim2.new(1,-46,0.5,-8)
    hkBtn.BackgroundColor3=C.CARD2 hkBtn.BackgroundTransparency=0.1 hkBtn.BorderSizePixel=0
    hkBtn.Text="?" hkBtn.Font=Enum.Font.GothamBold hkBtn.TextSize=8 hkBtn.TextColor3=C.DIM hkBtn.AutoButtonColor=false
    co(hkBtn,4) stk(hkBtn,C.BORD,1)
    -- X
    local xBtn=Instance.new("TextButton",hdr) xBtn.Size=UDim2.fromOffset(18,18) xBtn.Position=UDim2.new(1,-22,0.5,-9)
    xBtn.BackgroundColor3=Color3.fromRGB(35,10,10) xBtn.BackgroundTransparency=0.1 xBtn.BorderSizePixel=0
    xBtn.Text="×" xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=14 xBtn.TextColor3=C.CORAL xBtn.AutoButtonColor=false
    co(xBtn,4)
    -- content
    local cnt=Instance.new("Frame",frame) cnt.Size=UDim2.new(1,0,0,0) cnt.AutomaticSize=Enum.AutomaticSize.Y
    cnt.BackgroundTransparency=1 cnt.BorderSizePixel=0 cnt.LayoutOrder=2
    local pad=Instance.new("UIPadding",cnt) pad.PaddingTop=UDim.new(0,4) pad.PaddingBottom=UDim.new(0,6)
    pad.PaddingLeft=UDim.new(0,5) pad.PaddingRight=UDim.new(0,5)
    local cly=Instance.new("UIListLayout",cnt) cly.Padding=UDim.new(0,4) cly.SortOrder=Enum.SortOrder.LayoutOrder
    cly.HorizontalAlignment=Enum.HorizontalAlignment.Center
    return frame,cnt,xBtn,hkBtn
end

local function makeRow(parent,label,order,accent)
    accent=accent or C.LIME
    local row=Instance.new("Frame",parent) row.Size=UDim2.new(1,0,0,30) row.BackgroundColor3=C.CARD2
    row.BackgroundTransparency=0.1 row.BorderSizePixel=0 row.LayoutOrder=order co(row,6)
    local rs=stk(row,C.BORD,1)
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(0.6,0,1,0) lbl.Position=UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.Font=Enum.Font.GothamBold lbl.TextSize=10
    lbl.TextColor3=C.TEXT lbl.TextXAlignment=Enum.TextXAlignment.Left
    return row,rs,lbl
end

local function makeBtn(parent,txt,col,order)
    col=col or C.LIME
    local r,g,b=math.floor(col.R*255),math.floor(col.G*255),math.floor(col.B*255)
    local btn=Instance.new("TextButton",parent) btn.Size=UDim2.new(1,0,0,26)
    btn.BackgroundColor3=Color3.fromRGB(math.floor(r*0.1),math.floor(g*0.1),math.floor(b*0.1))
    btn.BackgroundTransparency=0.05 btn.BorderSizePixel=0 btn.Text=txt btn.Font=Enum.Font.GothamBold
    btn.TextSize=10 btn.TextColor3=col btn.AutoButtonColor=false btn.LayoutOrder=order or 99
    co(btn,6) stk(btn,col,1).Transparency=0.3
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundTransparency=0},0.08) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundTransparency=0.05},0.08) end)
    return btn
end

local function makeDivider(parent,col,order)
    local d=Instance.new("Frame",parent) d.Size=UDim2.new(1,0,0,1)
    d.BackgroundColor3=col or C.BORD d.BackgroundTransparency=0.55 d.BorderSizePixel=0 d.LayoutOrder=order
end

-- ====== HOTKEY SETUP ======
local function setupHK(slotName,hkBtn,defKey)
    hotkeys[slotName]=defKey or Enum.KeyCode.Unknown
    local function upd() if not hkBtn.Parent then return end
        local k=hotkeys[slotName] local nm=k and k.Name or "?"
        hkBtn.Text=nm=="Unknown" and "?" or nm:sub(1,4)
        hkBtn.TextColor3=nm=="Unknown" and C.DIM or C.AMBER
    end
    upd()
    hkBtn.MouseButton1Click:Connect(function()
        waitingHotkey=slotName hkBtn.Text="..." hkBtn.TextColor3=C.CORAL
        task.spawn(function()
            while waitingHotkey==slotName do task.wait(0.1) end upd()
        end)
    end)
end

-- ====== REOPEN BUTTONS ======
local function makeReopener(txt,pos,col,openFn)
    local b=Instance.new("TextButton",sg) b.Size=UDim2.fromOffset(32,20) b.Position=pos
    b.BackgroundColor3=C.CARD2 b.BackgroundTransparency=0.1 b.BorderSizePixel=0
    b.Text=txt b.Font=Enum.Font.GothamBlack b.TextSize=8 b.TextColor3=col b.Visible=false b.ZIndex=20
    co(b,5) stk(b,col,1) b.MouseButton1Click:Connect(function() b.Visible=false openFn() end)
    return b
end

-- ====== BUILD AP PANEL ======
local APFr,APCnt,APX,APHk=makePanel("AP SPAM",152,UDim2.fromOffset(8,32),C.LIME)
APFr.Visible=false
local APReo=makeReopener("AP",UDim2.fromOffset(8,32),C.LIME,function() APFr.Visible=true end)
APX.MouseButton1Click:Connect(function() APFr.Visible=false APReo.Visible=true end)
setupHK("AP",APHk,Enum.KeyCode.Unknown)

-- player scroll
local apSFr=Instance.new("Frame",APCnt) apSFr.Size=UDim2.new(1,0,0,95) apSFr.BackgroundTransparency=1
apSFr.ClipsDescendants=true apSFr.LayoutOrder=1
local apScr=Instance.new("ScrollingFrame",apSFr) apScr.Size=UDim2.new(1,0,1,0) apScr.BackgroundTransparency=1
apScr.BorderSizePixel=0 apScr.ScrollBarThickness=2 apScr.ScrollBarImageColor3=C.LIME
apScr.CanvasSize=UDim2.new(0,0,0,0) apScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
local apSly=Instance.new("UIListLayout",apScr) apSly.Padding=UDim.new(0,3) apSly.SortOrder=Enum.SortOrder.LayoutOrder
local apSelLbl=Instance.new("TextLabel",APCnt) apSelLbl.Size=UDim2.new(1,0,0,10) apSelLbl.BackgroundTransparency=1
apSelLbl.Text="tap to target" apSelLbl.Font=Enum.Font.Gotham apSelLbl.TextSize=7 apSelLbl.TextColor3=C.DIM apSelLbl.LayoutOrder=2
makeDivider(APCnt,C.LIME,3)
local selectedTarget=nil
local function buildAPCards()
    for _,c in ipairs(apScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    selectedTarget=nil
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame",apScr) card.Size=UDim2.new(1,-2,0,30) card.BackgroundColor3=C.CARD2
        card.BackgroundTransparency=0.15 card.BorderSizePixel=0 card.LayoutOrder=i co(card,5)
        local cst=stk(card,C.BORD,1)
        local av=Instance.new("ImageLabel",card) av.Size=UDim2.fromOffset(20,20) av.Position=UDim2.new(0,4,0.5,-10)
        av.BackgroundColor3=C.CARD av.BorderSizePixel=0 co(av,10)
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        local nl=Instance.new("TextLabel",card) nl.Size=UDim2.new(1,-28,0,13) nl.Position=UDim2.fromOffset(27,4)
        nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=8
        nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",card) ul.Size=UDim2.new(1,-28,0,10) ul.Position=UDim2.fromOffset(27,16)
        ul.BackgroundTransparency=1 ul.Text=p.Name ul.Font=Enum.Font.Gotham ul.TextSize=6
        ul.TextColor3=C.DIM ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local cb=Instance.new("TextButton",card) cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text="" cb.ZIndex=5
        local cap=p
        cb.MouseButton1Click:Connect(function()
            selectedTarget=cap
            for _,c2 in ipairs(apScr:GetChildren()) do if c2:IsA("Frame") then
                c2.BackgroundColor3=C.CARD2 c2.BackgroundTransparency=0.15
                local st2=c2:FindFirstChildOfClass("UIStroke") if st2 then st2.Color=C.BORD st2.Transparency=0.25 end
            end end
            card.BackgroundColor3=Color3.fromRGB(18,42,14) card.BackgroundTransparency=0
            cst.Color=C.LIME cst.Transparency=0.05
        end)
    end
end
local function getAPTarget()
    local t=selectedTarget if t and t.Parent then return t end
    local nearest,dist=nil,math.huge
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then for _,p in pairs(Players:GetPlayers()) do if p~=lp and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then local d=(r.Position-hrp.Position).Magnitude if d<dist then dist=d nearest=p end end
    end end end
    return nearest
end
local ragBtn=makeBtn(APCnt,"RAGDOLL",C.LIME,4)
local allBtn=makeBtn(APCnt,"ALL CMDS",C.LIME,5)
ragBtn.MouseButton1Click:Connect(function()
    local t=getAPTarget() if not t then return end ragBtn.Text="running..."
    runCmds(t,{"ragdoll"},false) task.delay(2,function() if ragBtn.Parent then ragBtn.Text="RAGDOLL" end end)
end)
allBtn.MouseButton1Click:Connect(function()
    local t=getAPTarget() if not t then return end allBtn.Text="running..."
    runCmds(t,{"rocket","inverse","tiny","jumpscare","morph","balloon"},true)
    task.delay(3,function() if allBtn.Parent then allBtn.Text="ALL CMDS" end end)
end)

-- ====== BUILD MINI AP PANEL ======
local MAFr,MACnt,MAX2,MAHk=makePanel("MINI AP",225,UDim2.fromOffset(168,32),C.CYAN)
MAFr.Visible=false
local MAReo=makeReopener("MA",UDim2.fromOffset(168,32),C.CYAN,function() MAFr.Visible=true end)
MAX2.MouseButton1Click:Connect(function() MAFr.Visible=false MAReo.Visible=true end)
setupHK("MINIAP",MAHk,Enum.KeyCode.Unknown)
local maSFr=Instance.new("Frame",MACnt) maSFr.Size=UDim2.new(1,0,0,120) maSFr.BackgroundTransparency=1
maSFr.ClipsDescendants=true maSFr.LayoutOrder=1
local maScr=Instance.new("ScrollingFrame",maSFr) maScr.Size=UDim2.new(1,0,1,0) maScr.BackgroundTransparency=1
maScr.BorderSizePixel=0 maScr.ScrollBarThickness=2 maScr.ScrollBarImageColor3=C.CYAN
maScr.CanvasSize=UDim2.new(0,0,0,0) maScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
local maSly=Instance.new("UIListLayout",maScr) maSly.Padding=UDim.new(0,3) maSly.SortOrder=Enum.SortOrder.LayoutOrder
local MINI_CMDS={
    {e="🎈",k="balloon",cd=29,col=Color3.fromRGB(55,115,255)},
    {e="🤸",k="ragdoll",cd=29,col=Color3.fromRGB(200,55,55)},
    {e="⛓",k="jail",   cd=59,col=Color3.fromRGB(35,155,55)},
    {e="🚀",k="rocket", cd=119,col=Color3.fromRGB(195,115,25)},
    {e="🐜",k="tiny",   cd=59,col=Color3.fromRGB(115,35,195)},
}
local function buildMiniCards()
    for _,c in ipairs(maScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",maScr) row.Size=UDim2.new(1,-2,0,28) row.BackgroundColor3=C.CARD2
        row.BackgroundTransparency=0.15 row.BorderSizePixel=0 row.LayoutOrder=i co(row,5) stk(row,C.BORD,1)
        local av=Instance.new("ImageLabel",row) av.Size=UDim2.fromOffset(18,18) av.Position=UDim2.new(0,3,0.5,-9)
        av.BackgroundColor3=C.CARD av.BorderSizePixel=0 co(av,9)
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(0,28,0,12) nl.Position=UDim2.fromOffset(23,3)
        nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=7
        nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",row) ul.Size=UDim2.new(0,28,0,9) ul.Position=UDim2.fromOffset(23,14)
        ul.BackgroundTransparency=1 ul.Text=p.Name ul.Font=Enum.Font.Gotham ul.TextSize=6
        ul.TextColor3=C.DIM ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local xOff=53
        for _,cmd in ipairs(MINI_CMDS) do
            local btn=Instance.new("TextButton",row) btn.Size=UDim2.fromOffset(28,20)
            btn.Position=UDim2.new(0,xOff,0.5,-10) btn.BackgroundColor3=cmd.col
            btn.BackgroundTransparency=0.18 btn.BorderSizePixel=0 btn.Text=cmd.e
            btn.Font=Enum.Font.GothamBold btn.TextSize=11 btn.AutoButtonColor=false co(btn,4)
            local cdLbl=Instance.new("TextLabel",btn) cdLbl.Size=UDim2.new(1,0,1,0) cdLbl.BackgroundTransparency=1
            cdLbl.Text="" cdLbl.Font=Enum.Font.GothamBold cdLbl.TextSize=7 cdLbl.TextColor3=Color3.new(1,1,1) cdLbl.ZIndex=2
            local onCD=false local captK=cmd.k local captP=p local captCD=cmd.cd local captCol=cmd.col
            btn.MouseButton1Click:Connect(function()
                if onCD then return end onCD=true
                local cdEnd=tick()+captCD btn.BackgroundColor3=Color3.fromRGB(40,12,12) btn.Text=""
                runSingle(captP,captK)
                task.spawn(function()
                    while tick()<cdEnd do if cdLbl.Parent then cdLbl.Text=tostring(math.ceil(cdEnd-tick())) end task.wait(0.5) end
                    if btn.Parent then btn.Text=cmd.e cdLbl.Text="" btn.BackgroundColor3=captCol end onCD=false
                end)
            end)
            xOff=xOff+30
        end
    end
end

-- ====== BLOCK PANEL ======
local BKFr,BKCnt,BKX,BKHk=makePanel("BLOCK",152,UDim2.fromOffset(8,168),C.CORAL)
BKFr.Visible=false
local BKReo=makeReopener("BL",UDim2.fromOffset(8,168),C.CORAL,function() BKFr.Visible=true end)
BKX.MouseButton1Click:Connect(function() BKFr.Visible=false BKReo.Visible=true end)
setupHK("BLOCK",BKHk,Enum.KeyCode.Unknown)
local baBtn2=makeBtn(BKCnt,"🚫 BLOCK ALL (VIM)",C.CORAL,1)
baBtn2.MouseButton1Click:Connect(function()
    baBtn2.Text="blocking..." baBtn2.TextColor3=C.DIM doBlockAll()
    task.delay(4,function() if baBtn2.Parent then baBtn2.Text="🚫 BLOCK ALL (VIM)" baBtn2.TextColor3=C.CORAL end end)
end)
makeDivider(BKCnt,C.CORAL,2)
local bkSFr=Instance.new("Frame",BKCnt) bkSFr.Size=UDim2.new(1,0,0,90) bkSFr.BackgroundTransparency=1
bkSFr.ClipsDescendants=true bkSFr.LayoutOrder=3
local bkScr=Instance.new("ScrollingFrame",bkSFr) bkScr.Size=UDim2.new(1,0,1,0) bkScr.BackgroundTransparency=1
bkScr.BorderSizePixel=0 bkScr.ScrollBarThickness=2 bkScr.ScrollBarImageColor3=C.CORAL
bkScr.CanvasSize=UDim2.new(0,0,0,0) bkScr.AutomaticCanvasSize=Enum.AutomaticSize.Y
local bkSly=Instance.new("UIListLayout",bkScr) bkSly.Padding=UDim.new(0,3) bkSly.SortOrder=Enum.SortOrder.LayoutOrder
local function buildBlockList()
    for _,c in ipairs(bkScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",bkScr) row.Size=UDim2.new(1,-2,0,26) row.BackgroundColor3=C.CARD2
        row.BackgroundTransparency=0.15 row.BorderSizePixel=0 row.LayoutOrder=i co(row,5) stk(row,C.BORD,1)
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(1,-48,1,0) nl.Position=UDim2.fromOffset(5,0)
        nl.BackgroundTransparency=1 nl.Text=p.DisplayName.." · "..p.Name nl.Font=Enum.Font.GothamBold nl.TextSize=8
        nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local bBtn=Instance.new("TextButton",row) bBtn.Size=UDim2.fromOffset(40,18) bBtn.Position=UDim2.new(1,-44,0.5,-9)
        bBtn.BackgroundColor3=Color3.fromRGB(35,10,10) bBtn.BackgroundTransparency=0.1 bBtn.BorderSizePixel=0
        bBtn.Text="BLOCK" bBtn.Font=Enum.Font.GothamBold bBtn.TextSize=8 bBtn.TextColor3=C.CORAL bBtn.AutoButtonColor=false
        co(bBtn,4) stk(bBtn,C.CORAL,1)
        local cap=p bBtn.MouseButton1Click:Connect(function()
            -- manual = just pops UI, no VIM
            pcall(function() StarterGui:SetCore("PromptBlockPlayer",cap) end)
        end)
    end
end

-- ====== RESET PANEL ======
local RSFr,RSCnt,RSX,RSHk=makePanel("RESET",148,UDim2.new(0.5,-74,1,-102),C.AMBER)
local RSReo=Instance.new("TextButton",sg) RSReo.Size=UDim2.fromOffset(60,20)
RSReo.AnchorPoint=Vector2.new(0.5,1) RSReo.Position=UDim2.new(0.5,0,1,-5)
RSReo.BackgroundColor3=C.CARD2 RSReo.BackgroundTransparency=0.1 RSReo.BorderSizePixel=0
RSReo.Text="💀 RESET" RSReo.Font=Enum.Font.GothamBlack RSReo.TextSize=9 RSReo.TextColor3=C.AMBER
RSReo.Visible=false co(RSReo,7) stk(RSReo,C.AMBER,1)
RSX.MouseButton1Click:Connect(function() RSFr.Visible=false RSReo.Visible=true end)
RSReo.MouseButton1Click:Connect(function() RSReo.Visible=false RSFr.Visible=true end)
setupHK("RESET",RSHk,Enum.KeyCode.R)
local rstBtn=makeBtn(RSCnt,"💀  INSTA RESET",C.AMBER,1)
rstBtn.MouseButton1Click:Connect(doReset)
makeDivider(RSCnt,C.AMBER,2)
local rsStatRow=Instance.new("Frame",RSCnt) rsStatRow.Size=UDim2.new(1,0,0,20)
rsStatRow.BackgroundColor3=C.CARD2 rsStatRow.BackgroundTransparency=0.1 rsStatRow.BorderSizePixel=0 rsStatRow.LayoutOrder=3
co(rsStatRow,5) stk(rsStatRow,C.BORD,1)
local rsStatLbl=Instance.new("TextLabel",rsStatRow) rsStatLbl.Size=UDim2.new(0.55,0,1,0) rsStatLbl.Position=UDim2.fromOffset(6,0)
rsStatLbl.BackgroundTransparency=1 rsStatLbl.Text="READY" rsStatLbl.Font=Enum.Font.GothamBold rsStatLbl.TextSize=9
rsStatLbl.TextColor3=C.GREEN rsStatLbl.TextXAlignment=Enum.TextXAlignment.Left
resetStatusLbl=rsStatLbl
task.spawn(function() while sg.Parent do task.wait(0.5)
    if RSHk.Parent then local k=hotkeys.RESET local nm=k and k.Name or "?"
        RSHk.Text=nm=="Unknown" and "?" or nm:sub(1,3) RSHk.TextColor3=nm=="Unknown" and C.DIM or C.AMBER
    end
end end)

-- ====== TP PANEL ======
local TPFr,TPCnt,TPX,TPHk=makePanel("FAST TP",148,UDim2.new(1,-156,0,32),C.CYAN)
local TPReo=makeReopener("TP",UDim2.new(1,-46,0,32),C.CYAN,function() TPFr.Visible=true end)
TPX.MouseButton1Click:Connect(function() TPFr.Visible=false TPReo.Visible=true end)
setupHK("TP",TPHk,Enum.KeyCode.T)

-- fast tp row
local tpRow,tpRS,tpLblR=makeRow(TPCnt,"Fast Teleport",1,C.CYAN)
local tpPill,tpPillSet=makePill(tpRow,false,C.CYAN) tpPill.Position=UDim2.new(1,-32,0.5,-7)
tpPillSetRef=tpPillSet tpNameLblRef=tpLblR tpRSRef=tpRS
local tpRowBtn=Instance.new("TextButton",tpRow) tpRowBtn.Size=UDim2.new(1,0,1,0) tpRowBtn.BackgroundTransparency=1 tpRowBtn.Text=""
tpRowBtn.MouseButton1Click:Connect(function()
    if fastTPRunning then
        fastTPRunning=false tpPillSet(false,tpRS) tpLblR.Text="Fast Teleport"
    else
        tpPillSet(true,tpRS) tpLblR.Text="Running..."
        doFastTP(function() tpPillSet(false,tpRS) tpLblR.Text="Fast Teleport" end)
    end
end)
makeDivider(TPCnt,C.CYAN,2)

-- auto block on tp row
local abRow,abRS,abLblR=makeRow(TPCnt,"Auto Block on TP",3,C.CORAL)
local abPill,abPillSet=makePill(abRow,false,C.CORAL) abPill.Position=UDim2.new(1,-32,0.5,-7)
local abRowBtn=Instance.new("TextButton",abRow) abRowBtn.Size=UDim2.new(1,0,1,0) abRowBtn.BackgroundTransparency=1 abRowBtn.Text=""
abRowBtn.MouseButton1Click:Connect(function()
    autoBlockAfterTP=not autoBlockAfterTP abPillSet(autoBlockAfterTP,abRS)
end)

-- block now btn
local blkNowBtn=makeBtn(TPCnt,"🚫  BLOCK NOW",C.CORAL,4)
blkNowBtn.MouseButton1Click:Connect(function()
    blkNowBtn.Text="blocking..." blkNowBtn.TextColor3=C.DIM
    task.spawn(function() doBlock(nil)
        if blkNowBtn.Parent then blkNowBtn.Text="🚫  BLOCK NOW" blkNowBtn.TextColor3=C.CORAL end
    end)
end)
makeDivider(TPCnt,C.ELEC,5)

-- esp row
local espRow,espRS,espLblR=makeRow(TPCnt,"Player ESP",6,C.ELEC)
local espPill,espPillSet=makePill(espRow,false,C.ELEC) espPill.Position=UDim2.new(1,-32,0.5,-7)
local espRowBtn=Instance.new("TextButton",espRow) espRowBtn.Size=UDim2.new(1,0,1,0) espRowBtn.BackgroundTransparency=1 espRowBtn.Text=""
espRowBtn.MouseButton1Click:Connect(function()
    playerESPOn=not playerESPOn espPillSet(playerESPOn,espRS) toggleESP(playerESPOn)
end)

-- ====== STEAL BAR (top center) ======
local grabBar=Instance.new("Frame",sg) grabBar.Size=UDim2.fromOffset(175,20)
grabBar.AnchorPoint=Vector2.new(0.5,0) grabBar.Position=UDim2.new(0.5,0,0,5)
grabBar.BackgroundColor3=C.CARD grabBar.BackgroundTransparency=0.08 grabBar.BorderSizePixel=0
co(grabBar,8) stk(grabBar,C.LIME,1.2)
local gbBg=Instance.new("Frame",grabBar) gbBg.Size=UDim2.new(0.92,0,0,3)
gbBg.Position=UDim2.new(0.04,0,1,-5) gbBg.BackgroundColor3=C.CARD2 gbBg.BorderSizePixel=0 co(gbBg,3)
local gbFill=Instance.new("Frame",gbBg) gbFill.Size=UDim2.new(0,0,1,0)
gbFill.BackgroundColor3=C.LIME gbFill.BorderSizePixel=0 co(gbFill,3)
stealBarFill=gbFill
local gbTxt=Instance.new("TextLabel",grabBar) gbTxt.Size=UDim2.new(1,0,0.75,0)
gbTxt.BackgroundTransparency=1 gbTxt.Text="PHANTOM GRAB" gbTxt.Font=Enum.Font.GothamBold
gbTxt.TextSize=8 gbTxt.TextColor3=C.TEXT gbTxt.ZIndex=2
RunService.RenderStepped:Connect(function()
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if isStealing then tw(gbFill,{BackgroundColor3=C.GREEN},0.05) gbTxt.Text="STEALING!"
    elseif best and bd<=6 then tw(gbFill,{BackgroundColor3=C.LIME},0.06) gbTxt.Text="IN RANGE "..math.floor(bd).."m"
    elseif best and bd<=40 then tw(gbFill,{BackgroundColor3=C.DIM},0.1) gbTxt.Text=math.floor(bd).."m"
    else gbTxt.Text="SEARCHING" end
end)

-- ====== SIDE BUTTONS (left) ======
local sideF=Instance.new("Frame",sg) sideF.Size=UDim2.fromOffset(32,0) sideF.Position=UDim2.new(0,4,0.5,-50)
sideF.BackgroundTransparency=1 sideF.AutomaticSize=Enum.AutomaticSize.Y
local sby=Instance.new("UIListLayout",sideF) sby.Padding=UDim.new(0,4)
local function sideBtn(label,col,cb)
    local f=Instance.new("Frame",sideF) f.Size=UDim2.fromOffset(32,32) f.BackgroundColor3=C.CARD
    f.BackgroundTransparency=0.08 f.BorderSizePixel=0 co(f,8) stk(f,col,1.2)
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1
    b.Text=label b.Font=Enum.Font.GothamBlack b.TextSize=10 b.TextColor3=col b.BorderSizePixel=0 b.AutoButtonColor=false
    b.MouseButton1Click:Connect(cb) return f,b
end
sideBtn("AP",C.LIME,function()
    local v=not APFr.Visible APFr.Visible=v MAFr.Visible=v
    APReo.Visible=not APFr.Visible MAReo.Visible=not MAFr.Visible
    if v then buildAPCards() buildMiniCards() end
end)
sideBtn("BL",C.CORAL,function()
    BKFr.Visible=not BKFr.Visible BKReo.Visible=not BKFr.Visible
    if BKFr.Visible then buildBlockList() end
end)
sideBtn("TP",C.CYAN,function()
    TPFr.Visible=not TPFr.Visible TPReo.Visible=not TPFr.Visible
end)

-- ====== MOBILE SHORTCUTS ======
local isMobile=UIS.TouchEnabled and not UIS.KeyboardEnabled
if isMobile then
    local function mobBtn(txt,yOff,col,cb)
        local f=Instance.new("Frame",sg) f.Size=UDim2.fromOffset(46,46)
        f.Position=UDim2.new(1,-52,0.5,yOff) f.BackgroundColor3=C.CARD f.BackgroundTransparency=0.08 f.BorderSizePixel=0
        co(f,10) stk(f,col or C.BORD,1.2)
        local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1
        b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=9 b.TextColor3=col or C.TEXT b.BorderSizePixel=0
        b.MouseButton1Click:Connect(cb)
    end
    mobBtn("FAST\nTP",-108,C.CYAN,function()
        if fastTPRunning then fastTPRunning=false tpPillSet(false,tpRS) tpLblR.Text="Fast Teleport"
        else tpPillSet(true,tpRS) tpLblR.Text="Running..."
            doFastTP(function() tpPillSet(false,tpRS) tpLblR.Text="Fast Teleport" end)
        end
    end)
    mobBtn("BLOCK",-54,C.CORAL,function() task.spawn(function() doBlock(nil) end) end)
    mobBtn("RESET",0,C.AMBER,function() doReset() end)
    mobBtn("AP",54,C.LIME,function()
        local v=not APFr.Visible APFr.Visible=v MAFr.Visible=v
        APReo.Visible=not v MAReo.Visible=not v if v then buildAPCards() buildMiniCards() end
    end)
end

-- ====== PLAYER UPDATES (dynamic) ======
local function refreshAll()
    task.wait(0.3)
    if APFr.Visible then buildAPCards() end
    if MAFr.Visible then buildMiniCards() end
    if BKFr.Visible then buildBlockList() end
    if playerESPOn then for _,p in ipairs(Players:GetPlayers()) do if p~=lp then mkESP(p) end end end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5)
        if playerESPOn then mkESP(p) end refreshAll()
    end)
    refreshAll()
end)
Players.PlayerRemoving:Connect(function(p)
    if selectedTarget==p then selectedTarget=nil end refreshAll()
end)
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then
    p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPOn then mkESP(p) end end)
end end

-- selected label update
task.spawn(function() while sg.Parent do task.wait(0.4)
    if apSelLbl.Parent then
        local t=selectedTarget if t and t.Parent then
            apSelLbl.Text="→ "..t.DisplayName apSelLbl.TextColor3=C.LIME
        else apSelLbl.Text="tap to target" apSelLbl.TextColor3=C.DIM end
    end
end end)

-- ====== GLOBAL INPUT ======
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if UIS:GetFocusedTextBox() then return end
    if waitingHotkey then
        if inp.KeyCode~=Enum.KeyCode.Unknown then hotkeys[waitingHotkey]=inp.KeyCode waitingHotkey=nil end return
    end
    if inp.KeyCode==hotkeys.RESET then doReset() end
    if inp.KeyCode==hotkeys.TP then
        if fastTPRunning then fastTPRunning=false tpPillSet(false,tpRS) tpLblR.Text="Fast Teleport"
        else tpPillSet(true,tpRS) tpLblR.Text="Running..."
            doFastTP(function() tpPillSet(false,tpRS) tpLblR.Text="Fast Teleport" end)
        end
    end
    if inp.KeyCode==hotkeys.AP then
        local v=not APFr.Visible APFr.Visible=v MAFr.Visible=v
        APReo.Visible=not v MAReo.Visible=not v if v then buildAPCards() buildMiniCards() end
    end
    if inp.KeyCode==hotkeys.BLOCK then
        BKFr.Visible=not BKFr.Visible BKReo.Visible=not BKFr.Visible if BKFr.Visible then buildBlockList() end
    end
    if inp.KeyCode==hotkeys.ESP then
        playerESPOn=not playerESPOn espPillSet(playerESPOn,espRS) toggleESP(playerESPOn)
    end
end)

-- initial load
task.spawn(function() task.wait(1) buildAPCards() buildMiniCards() buildBlockList() end)

end)
