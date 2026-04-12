task.spawn(function()
repeat task.wait() until game:IsLoaded()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UIS              = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local VIM              = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui          = game:GetService("CoreGui")
local lp               = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

-- ============ COLORS (emerald/teal dark) ============
local C = {
    BG    = Color3.fromRGB(7,12,10),
    CARD  = Color3.fromRGB(12,20,17),
    CARD2 = Color3.fromRGB(18,30,25),
    BORD  = Color3.fromRGB(30,75,55),
    TEXT  = Color3.fromRGB(210,240,225),
    DIM   = Color3.fromRGB(80,130,100),
    ACC   = Color3.fromRGB(40,210,120),
    ACCDIM= Color3.fromRGB(15,70,40),
    ON    = Color3.fromRGB(40,200,110),
    OFF   = Color3.fromRGB(25,40,32),
    RED   = Color3.fromRGB(220,60,60),
    GREEN = Color3.fromRGB(50,220,100),
    GOLD  = Color3.fromRGB(255,195,60),
}

local function tw(o,p,t) TweenService:Create(o,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad),p):Play() end
local function co(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 8) end
local function stroke(p,col,t) local s=Instance.new("UIStroke",p) s.Color=col or C.BORD s.Thickness=t or 1 s.Transparency=0.2 return s end

local function makeDrag(f)
    local dg,dgs,dsp=false,nil,nil
    f.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true dgs=i.Position dsp=f.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dg=false end end)
        end
    end)
    f.InputChanged:Connect(function(i)
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dgs
            f.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y)
        end
    end)
end

-- ============ AP CORE (admin panel only, NO chat) ============
local function fireBtn(btn)
    pcall(function() for _,c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end end)
    pcall(function() for _,c in pairs(getconnections(btn.Activated)) do c:Fire() end end)
end
local function findAdminPanel() return lp:WaitForChild("PlayerGui"):FindFirstChild("AdminPanel") end
local function getBtnByText(ap,kw)
    for _,obj in ipairs(ap:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local txt=""
            if obj:IsA("TextButton") then txt=obj.Text:lower()
            else for _,c in ipairs(obj:GetDescendants()) do if c:IsA("TextLabel") then txt=c.Text:lower() break end end end
            if txt:find(kw:lower()) then return obj end
        end
    end
end
local function getPlayerBtn(ap,target)
    for _,obj in ipairs(ap:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local txt=""
            if obj:IsA("TextButton") then txt=obj.Text
            else for _,c in ipairs(obj:GetDescendants()) do if c:IsA("TextLabel") then txt=c.Text break end end end
            if txt==target.Name or txt==target.DisplayName then return obj end
        end
    end
end
local function runCmds(target,cmds,jail)
    task.spawn(function()
        local ap=findAdminPanel() if not ap then return end
        for _,cmd in ipairs(cmds) do
            local pb=getPlayerBtn(ap,target) if pb then fireBtn(pb) task.wait(0.08) end
            local cb=getBtnByText(ap,cmd) if cb then fireBtn(cb) task.wait(0.08) end
            local pb2=getPlayerBtn(ap,target) if pb2 then fireBtn(pb2) task.wait(0.05) end
        end
        if jail then
            task.wait(1.5)
            local pb=getPlayerBtn(ap,target) if pb then fireBtn(pb) task.wait(0.05) end
            local jb=getBtnByText(ap,"jail") if jb then fireBtn(jb) task.wait(0.05) end
            local pb2=getPlayerBtn(ap,target) if pb2 then fireBtn(pb2) end
        end
    end)
end
local function runSingleCmdAP(target,cmd)
    task.spawn(function()
        local ap=findAdminPanel() if not ap then return end
        local pb=getPlayerBtn(ap,target) if pb then fireBtn(pb) task.wait(0.08) end
        local cb=getBtnByText(ap,cmd) if cb then fireBtn(cb) task.wait(0.08) end
        local pb2=getPlayerBtn(ap,target) if pb2 then fireBtn(pb2) end
    end)
end

-- ============ ANTI RAGDOLL (always running) ============
RunService.Heartbeat:Connect(function()
    local c=lp.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    local h=c:FindFirstChildOfClass("Humanoid") if not h then return end
    local st=h:GetState()
    if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
        h:ChangeState(Enum.HumanoidStateType.Running) Camera.CameraSubject=h
        if hrp then hrp.AssemblyLinearVelocity=Vector3.zero hrp.AssemblyAngularVelocity=Vector3.zero end
        for _,o in ipairs(c:GetDescendants()) do if o:IsA("Motor6D") and not o.Enabled then o.Enabled=true end end
    end
end)

-- ============ TIMER ESP (always running) ============
local espInst={}
RunService.RenderStepped:Connect(function()
    local plots=workspace:FindFirstChild("Plots") if not plots then return end
    local function makeESP(plot,part)
        if espInst[plot.Name] then pcall(function() espInst[plot.Name].bb:Destroy() end) end
        local bb=Instance.new("BillboardGui") bb.Size=UDim2.fromOffset(70,24) bb.StudsOffset=Vector3.new(0,9,0)
        bb.AlwaysOnTop=true bb.Adornee=part bb.MaxDistance=1500 bb.Parent=plot
        local bg=Instance.new("Frame",bb) bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(5,14,10)
        bg.BackgroundTransparency=0.2 bg.BorderSizePixel=0 co(bg,5) stroke(bg,C.ACC,1.5)
        local lbl=Instance.new("TextLabel",bg) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Font=Enum.Font.GothamBold lbl.TextSize=12 lbl.TextColor3=C.GOLD
        lbl.TextStrokeTransparency=0 lbl.TextStrokeColor3=Color3.new(0,0,0)
        espInst[plot.Name]={bb=bb,lbl=lbl}
    end
    for _,plot in ipairs(plots:GetChildren()) do
        local pur=plot:FindFirstChild("Purchases") local pb=pur and pur:FindFirstChild("PlotBlock")
        local mp=pb and pb:FindFirstChild("Main")
        local tl=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
        if tl and mp then
            local e=espInst[plot.Name]
            if not e or not e.bb.Parent then makeESP(plot,mp) e=espInst[plot.Name] end
            if e and e.lbl then
                e.lbl.Text=tl.Text
                local m,s=tl.Text:match("(%d+):(%d+)")
                if m and s then
                    local tot=tonumber(m)*60+tonumber(s)
                    e.lbl.TextColor3=tot<=30 and C.RED or tot<=60 and C.GOLD or C.ACC
                end
            end
        else
            local e=espInst[plot.Name] if e then pcall(function() e.bb:Destroy() end) espInst[plot.Name]=nil end
        end
    end
end)

-- ============ PLAYER ESP ============
local playerESPEnabled=false
local espConns={}
local function createPlayerESP(plr)
    if plr==lp or not plr.Character then return end
    local char=plr.Character local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp or char:FindFirstChild("PhESP_Box") then return end
    local box=Instance.new("BoxHandleAdornment",char) box.Name="PhESP_Box" box.Adornee=hrp
    box.Size=Vector3.new(4,6,2) box.Color3=C.ACC box.Transparency=0.55 box.ZIndex=10 box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char) bb.Name="PhESP_Name" bb.Adornee=char:FindFirstChild("Head") or hrp
    bb.Size=UDim2.new(0,180,0,40) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true
    local lbl=Instance.new("TextLabel",bb) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
    lbl.Text=plr.DisplayName lbl.TextColor3=C.ACC lbl.Font=Enum.Font.GothamBold lbl.TextSize=14
    lbl.TextStrokeTransparency=0.4 lbl.TextStrokeColor3=Color3.new(0,0,0)
end
local function togglePlayerESP(state)
    playerESPEnabled=state
    if not state then
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local b=p.Character:FindFirstChild("PhESP_Box") if b then b:Destroy() end
                local n=p.Character:FindFirstChild("PhESP_Name") if n then n:Destroy() end
            end
        end
        for _,c in ipairs(espConns) do c:Disconnect() end espConns={}
    else
        for _,p in ipairs(Players:GetPlayers()) do createPlayerESP(p) end
        table.insert(espConns,Players.PlayerAdded:Connect(function(p)
            table.insert(espConns,p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPEnabled then createPlayerESP(p) end end))
        end))
        for _,p in ipairs(Players:GetPlayers()) do
            table.insert(espConns,p.CharacterAdded:Connect(function() task.wait(0.5) if playerESPEnabled then createPlayerESP(p) end end))
        end
    end
end

-- ============ INSTA RESET (exact source) ============
local cachedCraftCFrame=nil local craftMachine=nil
local function updateCraftCache()
    craftMachine=workspace:FindFirstChild("CraftingMachine")
    if craftMachine then
        local p=craftMachine:FindFirstChild("VFX",true)
        if p then p=p:FindFirstChild("Secret",true) if p then p=p:FindFirstChild("SoundPart",true) if p then cachedCraftCFrame=p.CFrame end end end
    end
end
updateCraftCache()
workspace.ChildAdded:Connect(function(c) if c.Name=="CraftingMachine" then task.defer(updateCraftCache) end end)
Players.RespawnTime=0
RunService.Heartbeat:Connect(function() if Players.RespawnTime~=0 then Players.RespawnTime=0 end end)
local resetDebounce=false local charConn_r=nil
local ResetBtnRef=nil local StatusLblRef=nil
local function doReset()
    if resetDebounce then return end resetDebounce=true
    local char=lp.Character if not char then resetDebounce=false return end
    local hum=char:FindFirstChildOfClass("Humanoid") local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health<=0 then resetDebounce=false return end
    if ResetBtnRef then ResetBtnRef.Text="..." end
    if StatusLblRef then StatusLblRef.Text="RESETTING" StatusLblRef.TextColor3=C.RED end
    Camera.CameraSubject=nil
    if charConn_r then charConn_r:Disconnect() end
    charConn_r=lp.CharacterAdded:Connect(function(newChar)
        charConn_r:Disconnect() Camera.CameraSubject=nil
        task.defer(function() local nh=newChar:WaitForChild("Humanoid",0.5) if nh then Camera.CameraSubject=nh end end)
    end)
    if cachedCraftCFrame then hrp.CFrame=cachedCraftCFrame
    elseif craftMachine then updateCraftCache() if cachedCraftCFrame then hrp.CFrame=cachedCraftCFrame end end
    Players.RespawnTime=0 hum.Health=0 hum:ChangeState(Enum.HumanoidStateType.Dead) char:BreakJoints()
    task.wait(0.03) pcall(function() lp:LoadCharacter() end)
    task.delay(0.3,function()
        if ResetBtnRef then ResetBtnRef.Text="INSTA RESET" end
        if StatusLblRef then StatusLblRef.Text="ACTIVE" StatusLblRef.TextColor3=C.GREEN end
        resetDebounce=false
    end)
end
UIS.InputBegan:Connect(function(inp,gp) if not gp and inp.KeyCode==Enum.KeyCode.R then doReset() end end)

-- ============ INSTANT STEAL (9 stud) ============
local isStealing=false local stealProgress=0
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
            local pods=plot:FindFirstChild("AnimalPodiums")
            if pods then for _,pod in ipairs(pods:GetChildren()) do
                local base=pod:FindFirstChild("Base") local spn=base and base:FindFirstChild("Spawn")
                local att=spn and spn:FindFirstChild("PromptAttachment")
                local wp=att and att.WorldPosition or pod:GetPivot().Position
                table.insert(allAnimals,{plotName=plot.Name,slot=pod.Name,worldPos=wp,uid=plot.Name..pod.Name})
            end end
        end
    end
end
task.spawn(function() while task.wait(3) do scanPlots() end end)
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
    if #data.hold>0 or #data.trigger>0 then stealCache[prompt]=data end
end
local stealBarFill=nil
local function execSteal(prompt)
    local data=stealCache[prompt] if not data or not data.ready or isStealing then return end
    data.ready=false isStealing=true stealProgress=0
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        local t0=tick() local dur=0.08
        while tick()-t0<dur do
            stealProgress=math.clamp((tick()-t0)/dur,0,1)
            if stealBarFill then stealBarFill.Size=UDim2.new(stealProgress,0,1,0) end
            task.wait()
        end
        stealProgress=1 if stealBarFill then stealBarFill.Size=UDim2.new(1,0,1,0) end
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        pcall(function() fireproximityprompt(prompt,0) end)
        task.wait(0.08) data.ready=true isStealing=false stealProgress=0
        if stealBarFill then stealBarFill.Size=UDim2.new(0,0,1,0) end
    end)
end
RunService.Heartbeat:Connect(function()
    if isStealing then return end
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if not best or bd>9 then return end
    local prompt=promptCache[best.uid]
    if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt) if stealCache[prompt] then execSteal(prompt) end
end)

-- ============ FAST TP (706) ============
local WAYPOINTS={
    Vector3.new(-357.30,-7.00,113.60),Vector3.new(-381.00,-7.00,-43.50),
    Vector3.new(-412.43,-6.50,102.23),Vector3.new(-411.05,-6.50,54.73),
    Vector3.new(-410.00,-6.50,-14.58),Vector3.new(-377.28,-7.00,14.31),
    Vector3.new(-345.77,-7.00,17.01), Vector3.new(-332.52,-4.79,18.41),
}
local fastTPRunning=false
local function doFastTP(onDone)
    if fastTPRunning then fastTPRunning=false return end
    local char=lp.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    fastTPRunning=true
    task.spawn(function()
        for i=1,#WAYPOINTS do
            if not fastTPRunning or lp.Character~=char then break end
            hrp.CFrame=CFrame.new(WAYPOINTS[i])
            hrp.AssemblyLinearVelocity=Vector3.zero
            hrp.AssemblyAngularVelocity=Vector3.zero
            task.wait(0.01)
        end
        fastTPRunning=false
        if onDone then onDone() end
    end)
end

-- ============ AUTO BLOCK (706) ============
local blockCD=false
local function doBlock(target)
    if blockCD then return end blockCD=true
    local tgt=target
    if not tgt then
        local myR=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not myR then blockCD=false return end
        local best,bd=nil,math.huge
        for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                if r then local d=(myR.Position-r.Position).Magnitude if d<bd then bd=d best=p end end
            end
        end
        tgt=best
    end
    if not tgt then blockCD=false return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer",tgt) end)
    task.wait(0.4)
    local vp=Camera.ViewportSize
    for i=1,2 do
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.54,0,true,game,1)  task.wait(0.02)
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.54,0,false,game,1) task.wait(0.05)
    end
    task.wait(2) blockCD=false
end

-- ============ SCREEN GUI ============
pcall(function() CoreGui:FindFirstChild("PhantomSuite"):Destroy() end)
local sg=Instance.new("ScreenGui")
sg.Name="PhantomSuite" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999
pcall(function() sg.Parent=CoreGui end)
if not sg.Parent then sg.Parent=lp:WaitForChild("PlayerGui") end

-- ============ STEAL PROGRESS BAR (top center, always visible) ============
local grabBar=Instance.new("Frame",sg) grabBar.Size=UDim2.fromOffset(160,18) grabBar.AnchorPoint=Vector2.new(0.5,0)
grabBar.Position=UDim2.new(0.5,0,0,6) grabBar.BackgroundColor3=C.CARD grabBar.BackgroundTransparency=0.1 grabBar.BorderSizePixel=0
co(grabBar,7) stroke(grabBar,C.ACC,1.2)
local gbFill=Instance.new("Frame",grabBar) gbFill.Size=UDim2.new(0,0,1,0) gbFill.BackgroundColor3=C.ACC gbFill.BorderSizePixel=0 co(gbFill,7)
stealBarFill=gbFill
local gbTxt=Instance.new("TextLabel",grabBar) gbTxt.Size=UDim2.new(1,0,1,0) gbTxt.BackgroundTransparency=1
gbTxt.Text="PHANTOM GRAB" gbTxt.Font=Enum.Font.GothamBold gbTxt.TextSize=8 gbTxt.TextColor3=C.TEXT gbTxt.ZIndex=2
RunService.Heartbeat:Connect(function()
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if isStealing then tw(gbFill,{BackgroundColor3=C.GREEN},0.05) gbTxt.Text="STEALING!"
    elseif not best then gbTxt.Text="SEARCHING" tw(gbFill,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.DIM},0.1)
    elseif bd<=9 then tw(gbFill,{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.GREEN},0.05) gbTxt.Text="STEALING!"
    elseif bd<=40 then tw(gbFill,{Size=UDim2.new(math.clamp(1-(bd-9)/31,0,1),0,1,0),BackgroundColor3=C.ACC},0.1) gbTxt.Text=math.floor(bd).."m"
    else tw(gbFill,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.DIM},0.1) gbTxt.Text=math.floor(bd).."m" end
end)

-- ============ PILL TOGGLE HELPER ============
local function makePill(parent,def)
    local pw,ph=30,16
    local pill=Instance.new("Frame",parent) pill.Size=UDim2.fromOffset(pw,ph)
    pill.BackgroundColor3=def and C.ON or C.OFF pill.BorderSizePixel=0 co(pill,ph)
    local cir=Instance.new("Frame",pill) cir.Size=UDim2.fromOffset(ph-4,ph-4)
    cir.Position=def and UDim2.new(1,-(ph-2),0.5,-(ph-4)/2) or UDim2.new(0,2,0.5,-(ph-4)/2)
    cir.BackgroundColor3=Color3.new(1,1,1) cir.BorderSizePixel=0 co(cir,ph)
    local function set(state,stroke_ref)
        tw(pill,{BackgroundColor3=state and C.ON or C.OFF},0.13)
        tw(cir,{Position=state and UDim2.new(1,-(ph-2),0.5,-(ph-4)/2) or UDim2.new(0,2,0.5,-(ph-4)/2)},0.13,Enum.EasingStyle.Back)
        if stroke_ref then tw(stroke_ref,{Color=state and C.ACC or C.BORD,Transparency=state and 0.05 or 0.25},0.13) end
    end
    return pill,set
end

-- ============ PANEL BUILDER ============
local function makePanel(title,w,posX,posY,accentCol)
    accentCol=accentCol or C.ACC
    local f=Instance.new("Frame",sg)
    f.Size=UDim2.fromOffset(w,10) f.Position=UDim2.fromOffset(posX,posY)
    f.BackgroundColor3=C.BG f.BackgroundTransparency=0.06 f.BorderSizePixel=0
    f.AutomaticSize=Enum.AutomaticSize.Y f.Active=true
    co(f,10) stroke(f,accentCol,1.5) makeDrag(f)
    -- top bar
    local topBar=Instance.new("Frame",f) topBar.Size=UDim2.new(1,0,0,28) topBar.BackgroundColor3=C.CARD topBar.BackgroundTransparency=0.05 topBar.BorderSizePixel=0
    co(topBar,10)
    local topFix=Instance.new("Frame",topBar) topFix.Size=UDim2.new(1,0,0.5,0) topFix.Position=UDim2.new(0,0,0.5,0) topFix.BackgroundColor3=C.CARD topFix.BackgroundTransparency=0.05 topFix.BorderSizePixel=0
    -- accent dot
    local dot=Instance.new("Frame",topBar) dot.Size=UDim2.fromOffset(7,7) dot.Position=UDim2.fromOffset(10,10) dot.BackgroundColor3=accentCol dot.BorderSizePixel=0 co(dot,7)
    local tlbl=Instance.new("TextLabel",topBar) tlbl.Size=UDim2.new(1,-28,1,0) tlbl.Position=UDim2.fromOffset(22,0)
    tlbl.BackgroundTransparency=1 tlbl.Text=title tlbl.Font=Enum.Font.GothamBlack tlbl.TextSize=10 tlbl.TextColor3=accentCol tlbl.TextXAlignment=Enum.TextXAlignment.Left
    -- layout
    local ly=Instance.new("UIListLayout",f) ly.Padding=UDim.new(0,4) ly.HorizontalAlignment=Enum.HorizontalAlignment.Center ly.SortOrder=Enum.SortOrder.LayoutOrder
    local pad=Instance.new("UIPadding",f) pad.PaddingTop=UDim.new(0,32) pad.PaddingBottom=UDim.new(0,7) pad.PaddingLeft=UDim.new(0,6) pad.PaddingRight=UDim.new(0,6)
    return f,ly
end

local function makeRow(parent,label,order)
    local row=Instance.new("Frame",parent) row.Size=UDim2.new(1,0,0,32) row.BackgroundColor3=C.CARD2 row.BackgroundTransparency=0.1 row.BorderSizePixel=0 row.LayoutOrder=order
    co(row,7) local rs=stroke(row,C.BORD)
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(0.6,0,1,0) lbl.Position=UDim2.fromOffset(9,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.Font=Enum.Font.GothamBold lbl.TextSize=11 lbl.TextColor3=C.TEXT lbl.TextXAlignment=Enum.TextXAlignment.Left
    return row,rs
end

-- ============ AP PANEL (left) ============
_G.PhantomTarget=nil
local APPanel,_=makePanel("PHANTOM AP",152,8,32,C.ACC)
local APScroll=Instance.new("Frame",APPanel) APScroll.Size=UDim2.new(1,0,0,90) APScroll.BackgroundTransparency=1 APScroll.ClipsDescendants=true APScroll.LayoutOrder=1
local APScrollInner=Instance.new("ScrollingFrame",APScroll) APScrollInner.Size=UDim2.new(1,0,1,0) APScrollInner.BackgroundTransparency=1 APScrollInner.BorderSizePixel=0 APScrollInner.ScrollBarThickness=2 APScrollInner.ScrollBarImageColor3=C.ACC
APScrollInner.CanvasSize=UDim2.new(0,0,0,0) APScrollInner.AutomaticCanvasSize=Enum.AutomaticSize.Y
local apSLy=Instance.new("UIListLayout",APScrollInner) apSLy.Padding=UDim.new(0,3) apSLy.SortOrder=Enum.SortOrder.LayoutOrder

local function buildPlayerCards()
    for _,c in ipairs(APScrollInner:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    _G.PhantomTarget=nil
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame",APScrollInner) card.Size=UDim2.new(1,-2,0,34) card.BackgroundColor3=C.CARD2 card.BackgroundTransparency=0.15 card.BorderSizePixel=0 card.LayoutOrder=i
        co(card,6) local cst=stroke(card,C.BORD,1)
        local av=Instance.new("ImageLabel",card) av.Size=UDim2.fromOffset(24,24) av.Position=UDim2.new(0,4,0.5,-12) av.BackgroundColor3=C.CARD av.BorderSizePixel=0
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png" co(av,12)
        local nl=Instance.new("TextLabel",card) nl.Size=UDim2.new(1,-34,0,14) nl.Position=UDim2.fromOffset(32,4) nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=9 nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",card) ul.Size=UDim2.new(1,-34,0,10) ul.Position=UDim2.fromOffset(32,18) ul.BackgroundTransparency=1 ul.Text="@"..p.Name ul.Font=Enum.Font.Gotham ul.TextSize=7 ul.TextColor3=C.DIM ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local cb=Instance.new("TextButton",card) cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text="" cb.ZIndex=5
        cb.MouseButton1Click:Connect(function()
            _G.PhantomTarget=p
            for _,c2 in ipairs(APScrollInner:GetChildren()) do
                if c2:IsA("Frame") then c2.BackgroundColor3=C.CARD2 c2.BackgroundTransparency=0.15 local st2=c2:FindFirstChildOfClass("UIStroke") if st2 then st2.Color=C.BORD st2.Transparency=0.3 end end
            end
            card.BackgroundColor3=C.ACCDIM card.BackgroundTransparency=0 cst.Color=C.ACC cst.Transparency=0
        end)
    end
end

-- divider
local apDiv=Instance.new("Frame",APPanel) apDiv.Size=UDim2.new(1,0,0,1) apDiv.BackgroundColor3=C.ACC apDiv.BackgroundTransparency=0.5 apDiv.BorderSizePixel=0 apDiv.LayoutOrder=2
local selLbl=Instance.new("TextLabel",APPanel) selLbl.Size=UDim2.new(1,0,0,10) selLbl.BackgroundTransparency=1 selLbl.Text="tap to select" selLbl.Font=Enum.Font.Gotham selLbl.TextSize=7 selLbl.TextColor3=C.DIM selLbl.LayoutOrder=3
local apDiv2=Instance.new("Frame",APPanel) apDiv2.Size=UDim2.new(1,0,0,1) apDiv2.BackgroundColor3=C.ACC apDiv2.BackgroundTransparency=0.5 apDiv2.BorderSizePixel=0 apDiv2.LayoutOrder=4

local function getTarget()
    local t=_G.PhantomTarget if t and t.Parent then return t end
    local nearest,dist=nil,math.huge
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then for _,p in pairs(Players:GetPlayers()) do if p~=lp and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then local d=(r.Position-hrp.Position).Magnitude if d<dist then dist=d nearest=p end end
    end end end
    return nearest
end

local function mkAPCmd(label,order,cmds,jail)
    local btn=Instance.new("TextButton",APPanel) btn.Size=UDim2.new(1,0,0,26) btn.BackgroundColor3=C.CARD2 btn.BackgroundTransparency=0.1
    btn.Text=label btn.Font=Enum.Font.GothamBold btn.TextSize=10 btn.TextColor3=C.TEXT btn.BorderSizePixel=0 btn.AutoButtonColor=false btn.LayoutOrder=order
    co(btn,6) stroke(btn,C.BORD)
    local busy=false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        local target=getTarget() if not target then return end
        busy=true btn.AutoButtonColor=false local orig=btn.Text
        btn.Text="running..." btn.TextColor3=C.DIM
        runCmds(target,cmds,jail)
        task.delay(2,function() btn.Text=orig btn.TextColor3=C.TEXT busy=false end)
    end)
end
mkAPCmd("RAGDOLL",5,{"ragdoll"},false)
mkAPCmd("ALL",6,{"rocket","inverse","tiny","jumpscare","morph","balloon"},true)

-- ============ MINI AP PANEL (right of AP) ============
local MiniPanel,_=makePanel("MINI AP",215,168,32,C.ACC)
local miniScroll=Instance.new("ScrollingFrame",MiniPanel) miniScroll.Size=UDim2.new(1,-4,0,130) miniScroll.BackgroundTransparency=1 miniScroll.BorderSizePixel=0 miniScroll.ScrollBarThickness=2 miniScroll.ScrollBarImageColor3=C.ACC
miniScroll.CanvasSize=UDim2.new(0,0,0,0) miniScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y miniScroll.LayoutOrder=1
local msLy=Instance.new("UIListLayout",miniScroll) msLy.Padding=UDim.new(0,3) msLy.SortOrder=Enum.SortOrder.LayoutOrder

local MINI_CMDS={
    {e="🎈",k="balloon",cd=29,col=Color3.fromRGB(40,70,200)},
    {e="🤸",k="ragdoll",cd=29,col=Color3.fromRGB(160,30,30)},
    {e="⛓️", k="jail",   cd=59,col=Color3.fromRGB(20,100,40)},
    {e="🚀",k="rocket", cd=119,col=Color3.fromRGB(160,80,10)},
    {e="🐜",k="tiny",   cd=59,col=Color3.fromRGB(70,10,140)},
}

local function buildMiniCards()
    for _,c in ipairs(miniScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",miniScroll) row.Size=UDim2.new(1,-2,0,28) row.BackgroundColor3=C.CARD2 row.BackgroundTransparency=0.15 row.BorderSizePixel=0 row.LayoutOrder=i
        co(row,6) stroke(row,C.BORD,1)
        local av=Instance.new("ImageLabel",row) av.Size=UDim2.fromOffset(20,20) av.Position=UDim2.new(0,3,0.5,-10) av.BackgroundColor3=C.CARD av.BorderSizePixel=0
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png" co(av,10)
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(0,36,0,12) nl.Position=UDim2.fromOffset(25,4) nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=7 nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",row) ul.Size=UDim2.new(0,36,0,9) ul.Position=UDim2.fromOffset(25,15) ul.BackgroundTransparency=1 ul.Text="@"..p.Name ul.Font=Enum.Font.Gotham ul.TextSize=6 ul.TextColor3=C.DIM ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local xOff=63
        for _,cmd in ipairs(MINI_CMDS) do
            local btn=Instance.new("TextButton",row) btn.Size=UDim2.fromOffset(22,20) btn.Position=UDim2.new(0,xOff,0.5,-10)
            btn.BackgroundColor3=cmd.col btn.BackgroundTransparency=0.15 btn.BorderSizePixel=0 btn.Text=cmd.e btn.Font=Enum.Font.GothamBold btn.TextSize=12 btn.AutoButtonColor=false
            co(btn,4)
            local origC=cmd.col local captK=cmd.k local captP=p local onCD=false local cdEnd=0
            local cdLbl=Instance.new("TextLabel",btn) cdLbl.Size=UDim2.new(1,0,1,0) cdLbl.BackgroundTransparency=1 cdLbl.Text="" cdLbl.Font=Enum.Font.GothamBold cdLbl.TextSize=7 cdLbl.TextColor3=Color3.new(1,1,1) cdLbl.ZIndex=2
            btn.MouseButton1Click:Connect(function()
                if onCD then return end onCD=true cdEnd=tick()+cmd.cd
                btn.BackgroundColor3=C.RED btn.Text=""
                runSingleCmdAP(captP,captK)
                task.spawn(function()
                    while tick()<cdEnd do cdLbl.Text=tostring(math.ceil(cdEnd-tick())) task.wait(0.5) end
                    if btn.Parent then btn.Text=cmd.e cdLbl.Text="" btn.BackgroundColor3=origC end
                    onCD=false
                end)
            end)
            xOff=xOff+24
        end
    end
end

-- ============ BLOCK PANEL (bottom, different color) ============
local BlkPanel,_=makePanel("MANUAL BLOCK",155,392,32,C.RED)

-- Block All button
local baBtn=Instance.new("TextButton",BlkPanel) baBtn.Size=UDim2.new(1,0,0,26) baBtn.BackgroundColor3=Color3.fromRGB(40,12,12) baBtn.BackgroundTransparency=0.1
baBtn.Text="🚫  BLOCK ALL" baBtn.Font=Enum.Font.GothamBold baBtn.TextSize=10 baBtn.TextColor3=C.RED baBtn.BorderSizePixel=0 baBtn.AutoButtonColor=false baBtn.LayoutOrder=1
co(baBtn,6) stroke(baBtn,C.RED)
baBtn.MouseButton1Click:Connect(function()
    baBtn.Text="blocking..." baBtn.TextColor3=C.DIM
    task.spawn(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp then pcall(function() StarterGui:SetCore("PromptBlockPlayer",p) end) task.wait(0.1) end end
        if baBtn.Parent then baBtn.Text="🚫  BLOCK ALL" baBtn.TextColor3=C.RED end
    end)
end)

local blkDiv=Instance.new("Frame",BlkPanel) blkDiv.Size=UDim2.new(1,0,0,1) blkDiv.BackgroundColor3=C.RED blkDiv.BackgroundTransparency=0.5 blkDiv.BorderSizePixel=0 blkDiv.LayoutOrder=2

local blkScroll=Instance.new("ScrollingFrame",BlkPanel) blkScroll.Size=UDim2.new(1,-4,0,90) blkScroll.BackgroundTransparency=1 blkScroll.BorderSizePixel=0 blkScroll.ScrollBarThickness=2 blkScroll.ScrollBarImageColor3=C.RED
blkScroll.CanvasSize=UDim2.new(0,0,0,0) blkScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y blkScroll.LayoutOrder=3
local bkLy=Instance.new("UIListLayout",blkScroll) bkLy.Padding=UDim.new(0,3) bkLy.SortOrder=Enum.SortOrder.LayoutOrder

local function buildBlockList()
    for _,c in ipairs(blkScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",blkScroll) row.Size=UDim2.new(1,-2,0,26) row.BackgroundColor3=C.CARD2 row.BackgroundTransparency=0.15 row.BorderSizePixel=0 row.LayoutOrder=i
        co(row,5) stroke(row,C.BORD)
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(1,-52,1,0) nl.Position=UDim2.fromOffset(6,0) nl.BackgroundTransparency=1 nl.Text=p.DisplayName.."  @"..p.Name nl.Font=Enum.Font.GothamBold nl.TextSize=8 nl.TextColor3=C.TEXT nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local blkBtn=Instance.new("TextButton",row) blkBtn.Size=UDim2.fromOffset(44,18) blkBtn.Position=UDim2.new(1,-48,0.5,-9) blkBtn.BackgroundColor3=Color3.fromRGB(40,12,12) blkBtn.BackgroundTransparency=0.1 blkBtn.Text="BLOCK" blkBtn.Font=Enum.Font.GothamBold blkBtn.TextSize=8 blkBtn.TextColor3=C.RED blkBtn.BorderSizePixel=0 blkBtn.AutoButtonColor=false
        co(blkBtn,4) stroke(blkBtn,C.RED)
        local cap=p
        blkBtn.MouseButton1Click:Connect(function() pcall(function() StarterGui:SetCore("PromptBlockPlayer",cap) end) end)
        local rowBtn=Instance.new("TextButton",row) rowBtn.Size=UDim2.new(1,-50,1,0) rowBtn.BackgroundTransparency=1 rowBtn.Text="" rowBtn.ZIndex=3
        rowBtn.MouseButton1Click:Connect(function() pcall(function() StarterGui:SetCore("PromptBlockPlayer",cap) end) end)
    end
end

-- ============ RESET PANEL (bottom center) ============
local RstPanel,_=makePanel("PHANTOM RESET",155,0,0,C.GOLD)
RstPanel.Position=UDim2.new(0.5,-77,1,-105)

local rstBtn=Instance.new("TextButton",RstPanel) rstBtn.Size=UDim2.new(1,0,0,28) rstBtn.BackgroundColor3=Color3.fromRGB(35,30,8) rstBtn.BackgroundTransparency=0.1
rstBtn.Text="💀  INSTA RESET" rstBtn.Font=Enum.Font.GothamBold rstBtn.TextSize=11 rstBtn.TextColor3=C.GOLD rstBtn.BorderSizePixel=0 rstBtn.AutoButtonColor=false rstBtn.LayoutOrder=1
co(rstBtn,6) stroke(rstBtn,C.GOLD)
ResetBtnRef=rstBtn
local rDiv=Instance.new("Frame",RstPanel) rDiv.Size=UDim2.new(1,0,0,1) rDiv.BackgroundColor3=C.GOLD rDiv.BackgroundTransparency=0.5 rDiv.BorderSizePixel=0 rDiv.LayoutOrder=2
local rStat=Instance.new("Frame",RstPanel) rStat.Size=UDim2.new(1,0,0,20) rStat.BackgroundColor3=C.CARD2 rStat.BackgroundTransparency=0.1 rStat.BorderSizePixel=0 rStat.LayoutOrder=3
co(rStat,5) stroke(rStat,C.BORD)
local rSLbl=Instance.new("TextLabel",rStat) rSLbl.Size=UDim2.new(0.6,0,1,0) rSLbl.BackgroundTransparency=1 rSLbl.Text="ACTIVE" rSLbl.Font=Enum.Font.GothamBold rSLbl.TextSize=9 rSLbl.TextColor3=C.GREEN rSLbl.TextXAlignment=Enum.TextXAlignment.Center
StatusLblRef=rSLbl
local rKLbl=Instance.new("TextLabel",rStat) rKLbl.Size=UDim2.new(0.4,0,1,0) rKLbl.Position=UDim2.new(0.6,0,0,0) rKLbl.BackgroundTransparency=1 rKLbl.Text="[R]" rKLbl.Font=Enum.Font.Gotham rKLbl.TextSize=8 rKLbl.TextColor3=C.DIM rKLbl.TextXAlignment=Enum.TextXAlignment.Center
rstBtn.MouseButton1Click:Connect(doReset)

-- ============ FAST TP + AUTO BLOCK PANEL (right side) ============
local TpPanel,_=makePanel("PHANTOM TP",150,0,32,C.CYAN)
TpPanel.Position=UDim2.new(1,-158,0,32)

-- fast tp row
local tpRow2,tpRS=makeRow(TpPanel,"Fast Teleport",1)
local tpPill,tpPillSet=makePill(tpRow2,false) tpPill.Position=UDim2.new(1,-38,0.5,-8)
local tpRowBtn=Instance.new("TextButton",tpRow2) tpRowBtn.Size=UDim2.new(1,0,1,0) tpRowBtn.BackgroundTransparency=1 tpRowBtn.Text=""
local tpNameLbl=tpRow2:FindFirstChildOfClass("TextLabel")
tpRowBtn.MouseButton1Click:Connect(function()
    if fastTPRunning then
        fastTPRunning=false
        tpPillSet(false,tpRS)
        if tpNameLbl then tpNameLbl.Text="Fast Teleport" end
    else
        tpPillSet(true,tpRS)
        if tpNameLbl then tpNameLbl.Text="Running..." end
        doFastTP(function()
            tpPillSet(false,tpRS)
            if tpNameLbl then tpNameLbl.Text="Fast Teleport" end
        end)
    end
end)

local tpDiv=Instance.new("Frame",TpPanel) tpDiv.Size=UDim2.new(1,0,0,1) tpDiv.BackgroundColor3=C.CYAN tpDiv.BackgroundTransparency=0.5 tpDiv.BorderSizePixel=0 tpDiv.LayoutOrder=2

-- auto block row
local blkRow2,blkRS=makeRow(TpPanel,"Auto Block",3)
local blkQuickBtn=Instance.new("TextButton",blkRow2) blkQuickBtn.Size=UDim2.fromOffset(50,20) blkQuickBtn.Position=UDim2.new(1,-54,0.5,-10)
blkQuickBtn.BackgroundColor3=C.ACCDIM blkQuickBtn.BackgroundTransparency=0.1 blkQuickBtn.Text="BLOCK" blkQuickBtn.Font=Enum.Font.GothamBold blkQuickBtn.TextSize=9 blkQuickBtn.TextColor3=C.ACC blkQuickBtn.BorderSizePixel=0 blkQuickBtn.AutoButtonColor=false
co(blkQuickBtn,5) stroke(blkQuickBtn,C.ACC)
blkQuickBtn.MouseButton1Click:Connect(function()
    blkQuickBtn.Text="..." blkQuickBtn.TextColor3=C.DIM
    task.spawn(function()
        doBlock(nil)
        blkQuickBtn.Text="BLOCK" blkQuickBtn.TextColor3=C.ACC
    end)
end)

-- player esp row
local espRow,espRS=makeRow(TpPanel,"Player ESP",4)
local espPill,espPillSet=makePill(espRow,false) espPill.Position=UDim2.new(1,-38,0.5,-8)
local espRowBtn=Instance.new("TextButton",espRow) espRowBtn.Size=UDim2.new(1,0,1,0) espRowBtn.BackgroundTransparency=1 espRowBtn.Text=""
espRowBtn.MouseButton1Click:Connect(function()
    playerESPEnabled=not playerESPEnabled
    espPillSet(playerESPEnabled,espRS)
    togglePlayerESP(playerESPEnabled)
end)

-- ============ TOGGLE BUTTONS (left side, square) ============
local function makeSquareBtn(icon,yPos,col)
    local f=Instance.new("Frame",sg) f.Size=UDim2.fromOffset(36,36) f.Position=UDim2.new(0,8,0,yPos) f.BackgroundColor3=C.CARD f.BackgroundTransparency=0.1 f.BorderSizePixel=0
    co(f,8) local fs=stroke(f,C.BORD,1.2)
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,0.7,0) b.BackgroundTransparency=1 b.Text=icon b.Font=Enum.Font.GothamBold b.TextSize=14 b.TextColor3=col or C.TEXT b.BorderSizePixel=0 b.AutoButtonColor=false
    local slbl=Instance.new("TextLabel",f) slbl.Size=UDim2.new(1,0,0.3,0) slbl.Position=UDim2.new(0,0,0.7,0) slbl.BackgroundTransparency=1 slbl.Text="" slbl.Font=Enum.Font.GothamBold slbl.TextSize=6 slbl.TextColor3=C.DIM
    return f,b,fs
end

-- AP button
local apBtnF,apBtn,apBtnS=makeSquareBtn("AP",68,C.ACC)
-- Mini AP button
local maBtnF,maBtn,maBtnS=makeSquareBtn("MA",110,C.ACC)
-- Block button
local blkBtnF,blkBtnB,blkBtnS=makeSquareBtn("BL",152,C.RED)

local apOpen=false local maOpen=false local blkOpen=false
local apPosSet=false local maPosSet=false local blkPosSet=false

local function openNearBtn(panel,btnFrame,flag)
    panel.Visible=not panel.Visible
    if panel.Visible and not flag then
        local bp=btnFrame.AbsolutePosition
        panel.Position=UDim2.fromOffset(bp.X+44,bp.Y)
    end
end

apBtn.MouseButton1Click:Connect(function()
    apOpen=not apOpen
    APPanel.Visible=apOpen MiniPanel.Visible=apOpen
    apBtnS.Color=apOpen and C.ACC or C.BORD
    if apOpen then buildPlayerCards() buildMiniCards()
        if not apPosSet then apPosSet=true
            APPanel.Position=UDim2.fromOffset(52,32)
            MiniPanel.Position=UDim2.fromOffset(168,32)
        end
    end
end)
maBtn.MouseButton1Click:Connect(function()
    apOpen=not apOpen
    APPanel.Visible=apOpen MiniPanel.Visible=apOpen
    maBtnS.Color=apOpen and C.ACC or C.BORD
    if apOpen then buildPlayerCards() buildMiniCards() end
end)
blkBtnB.MouseButton1Click:Connect(function()
    blkOpen=not blkOpen BlkPanel.Visible=blkOpen blkBtnS.Color=blkOpen and C.RED or C.BORD
    if blkOpen then buildBlockList()
        if not blkPosSet then blkPosSet=true BlkPanel.Position=UDim2.fromOffset(52,152) end
    end
end)

-- Reopen buttons for panels (small pills at fixed positions)
local function makeReopenBtn(txt,xPos,yPos,col)
    local b=Instance.new("TextButton",sg) b.Size=UDim2.fromOffset(26,22) b.Position=UDim2.fromOffset(xPos,yPos)
    b.BackgroundColor3=C.CARD b.BackgroundTransparency=0.1 b.Text=txt b.Font=Enum.Font.GothamBlack b.TextSize=9 b.TextColor3=col or C.ACC b.BorderSizePixel=0 b.Visible=false
    co(b,5) stroke(b,col or C.ACC)
    return b
end

-- AP panel close/reopen
do
    local xBtn=Instance.new("TextButton",APPanel) xBtn.Size=UDim2.fromOffset(16,16) xBtn.Position=UDim2.new(1,-20,0,6) xBtn.BackgroundColor3=C.RED xBtn.BorderSizePixel=0 xBtn.Text="×" xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=12 xBtn.TextColor3=Color3.new(1,1,1) xBtn.ZIndex=20 co(xBtn,5)
    local reop=makeReopenBtn("AP",52,32,C.ACC)
    xBtn.MouseButton1Click:Connect(function() APPanel.Visible=false MiniPanel.Visible=false reop.Visible=true apOpen=false end)
    reop.MouseButton1Click:Connect(function() reop.Visible=false APPanel.Visible=true MiniPanel.Visible=true apOpen=true buildPlayerCards() buildMiniCards() end)
end
do
    local xBtn=Instance.new("TextButton",BlkPanel) xBtn.Size=UDim2.fromOffset(16,16) xBtn.Position=UDim2.new(1,-20,0,6) xBtn.BackgroundColor3=C.RED xBtn.BorderSizePixel=0 xBtn.Text="×" xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=12 xBtn.TextColor3=Color3.new(1,1,1) xBtn.ZIndex=20 co(xBtn,5)
    local reop=makeReopenBtn("BL",52,152,C.RED)
    xBtn.MouseButton1Click:Connect(function() BlkPanel.Visible=false reop.Visible=true blkOpen=false end)
    reop.MouseButton1Click:Connect(function() reop.Visible=false BlkPanel.Visible=true blkOpen=true buildBlockList() end)
end
do
    local xBtn=Instance.new("TextButton",RstPanel) xBtn.Size=UDim2.fromOffset(16,16) xBtn.Position=UDim2.new(1,-20,0,6) xBtn.BackgroundColor3=C.RED xBtn.BorderSizePixel=0 xBtn.Text="×" xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=12 xBtn.TextColor3=Color3.new(1,1,1) xBtn.ZIndex=20 co(xBtn,5)
    local reop=Instance.new("TextButton",sg) reop.Size=UDim2.fromOffset(60,22) reop.AnchorPoint=Vector2.new(0.5,1) reop.Position=UDim2.new(0.5,0,1,-8) reop.BackgroundColor3=C.CARD reop.BackgroundTransparency=0.1 reop.Text="💀 RESET" reop.Font=Enum.Font.GothamBlack reop.TextSize=9 reop.TextColor3=C.GOLD reop.BorderSizePixel=0 reop.Visible=false co(reop,7) stroke(reop,C.GOLD)
    xBtn.MouseButton1Click:Connect(function() RstPanel.Visible=false reop.Visible=true end)
    reop.MouseButton1Click:Connect(function() reop.Visible=false RstPanel.Visible=true end)
end
do
    local xBtn=Instance.new("TextButton",TpPanel) xBtn.Size=UDim2.fromOffset(16,16) xBtn.Position=UDim2.new(1,-20,0,6) xBtn.BackgroundColor3=C.RED xBtn.BorderSizePixel=0 xBtn.Text="×" xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=12 xBtn.TextColor3=Color3.new(1,1,1) xBtn.ZIndex=20 co(xBtn,5)
    local reop=makeReopenBtn("TP",0,32,C.CYAN) reop.Position=UDim2.new(1,-36,0,32)
    xBtn.MouseButton1Click:Connect(function() TpPanel.Visible=false reop.Visible=true end)
    reop.MouseButton1Click:Connect(function() reop.Visible=false TpPanel.Visible=true end)
end

-- ============ MOBILE SHORTCUTS (right side, stacked) ============
local isMobile=UIS.TouchEnabled and not UIS.KeyboardEnabled
if isMobile then
    local function mobBtn(txt,yPos,col,cb)
        local f=Instance.new("Frame",sg) f.Size=UDim2.fromOffset(50,50) f.Position=UDim2.new(1,-58,0.5,yPos) f.BackgroundColor3=C.CARD f.BackgroundTransparency=0.1 f.BorderSizePixel=0
        co(f,10) stroke(f,col or C.BORD)
        local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=10 b.TextColor3=col or C.TEXT b.BorderSizePixel=0
        b.MouseButton1Click:Connect(cb) return f,b
    end
    local _,fastTPMob=mobBtn("FAST\nTP",-130,C.CYAN,function()
        if fastTPRunning then fastTPRunning=false return end
        doFastTP(function() end)
    end)
    local _,blkMob=mobBtn("BLOCK",-72,C.RED,function() task.spawn(function() doBlock(nil) end) end)
    local _,rstMob=mobBtn("RESET",-14,C.GOLD,function() doReset() end)
    local _,apMob=mobBtn("AP",44,C.ACC,function()
        apOpen=not apOpen APPanel.Visible=apOpen MiniPanel.Visible=apOpen
        if apOpen then buildPlayerCards() buildMiniCards() end
    end)
end

-- Player updates
Players.PlayerAdded:Connect(function()
    if apOpen then buildPlayerCards() buildMiniCards() end
    if blkOpen then buildBlockList() end
end)
Players.PlayerRemoving:Connect(function(p)
    if _G.PhantomTarget==p then _G.PhantomTarget=nil end
    if apOpen then task.wait(0.3) buildPlayerCards() buildMiniCards() end
    if blkOpen then task.wait(0.3) buildBlockList() end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not sg.Parent then break end
        local t=_G.PhantomTarget
        if t and t.Parent then selLbl.Text=t.DisplayName selLbl.TextColor3=C.ACC
        else selLbl.Text="tap to select" selLbl.TextColor3=C.DIM end
    end
end)

-- Initial state
APPanel.Visible=false MiniPanel.Visible=false BlkPanel.Visible=false
TpPanel.Visible=true RstPanel.Visible=true

end)
