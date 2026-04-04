pcall(function() game:GetService("CoreGui"):FindFirstChild("PhantomSuite"):Destroy() end)

-- ============ SERVICES ============
local Players          = game:GetService("Players")
local TextChatService  = game:GetService("TextChatService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")
local VIM              = game:GetService("VirtualInputManager")
local UIS              = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local lp               = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

-- ============ COLORS ============
local C = {
    BG    = Color3.fromRGB(8,16,24),
    PANEL = Color3.fromRGB(12,22,34),
    ITEM  = Color3.fromRGB(16,30,46),
    ACC   = Color3.fromRGB(0,200,220),
    TXT   = Color3.fromRGB(200,240,255),
    DIM   = Color3.fromRGB(80,140,160),
    RED   = Color3.fromRGB(220,50,50),
    GREEN = Color3.fromRGB(50,220,100),
    PINK  = Color3.fromRGB(180,60,220),
    ORG   = Color3.fromRGB(255,150,50),
    LIME  = Color3.fromRGB(0,200,0),
}
local TRANS   = 0.18
local uiLocked = false

-- ============ HELPERS ============
local function getRoot() local c=lp.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function addCorner(i,r) local c=Instance.new("UICorner",i) c.CornerRadius=UDim.new(0,r or 8) end
local function addStroke(i,col,t,tr) local s=Instance.new("UIStroke",i) s.Color=col or C.ACC s.Thickness=t or 1.2 s.Transparency=tr or 0.2 return s end

local function makeDrag(f)
    local dg,dgs,dsp=false,nil,nil
    f.InputBegan:Connect(function(i)
        if uiLocked then return end
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true dgs=i.Position dsp=f.Position
        end
    end)
    f.InputChanged:Connect(function(i)
        if uiLocked then return end
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dgs
            f.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y)
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end
    end)
end

-- ============ AP CORE (ORIGINAL - UNTOUCHED) ============
local function sendCmd(cmd)
    task.spawn(function()
        pcall(function()
            local ch=TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
            ch:SendAsync(cmd)
        end)
    end)
end
local function fireBtn(btn)
    pcall(function() for _,c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end end)
    pcall(function() for _,c in pairs(getconnections(btn.Activated)) do c:Fire() end end)
end
local function findAdminPanel()
    return lp:WaitForChild("PlayerGui"):FindFirstChild("AdminPanel")
end
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
        local ap=findAdminPanel()
        if ap then
            for _,cmd in ipairs(cmds) do
                local pb=getPlayerBtn(ap,target)
                if pb then fireBtn(pb) task.wait(0.08) end
                local cb=getBtnByText(ap,cmd)
                if cb then fireBtn(cb) task.wait(0.08) end
            end
            if jail then
                task.wait(1.5)
                local pb=getPlayerBtn(ap,target)
                if pb then fireBtn(pb) task.wait(0.05) end
                local jb=getBtnByText(ap,"jail")
                if jb then fireBtn(jb) end
            end
        else
            local n=target.Name
            for _,cmd in ipairs(cmds) do sendCmd(";"..cmd.." "..n) task.wait(0.1) end
            if jail then task.delay(1.5,function() sendCmd(";jail "..n) end) end
        end
    end)
end
-- Mini AP uses chat directly to avoid admin panel state carryover bug
local function runSingleCmdChat(target,cmd)
    task.spawn(function()
        sendCmd(";"..cmd.." "..target.Name)
    end)
end

-- ============ ANTI RAGDOLL (from leaked source - fixes knockback) ============
local arConns={}
local function startAR()
    if arConns.anti then return end
    arConns.anti=RunService.Heartbeat:Connect(function()
        local c=lp.Character if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart")
        local h=c:FindFirstChildOfClass("Humanoid")
        if h then
            local st=h:GetState()
            if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
                h:ChangeState(Enum.HumanoidStateType.Running)
                Camera.CameraSubject=h
                if hrp then
                    hrp.AssemblyLinearVelocity=Vector3.zero
                    hrp.AssemblyAngularVelocity=Vector3.zero
                end
            end
        end
        for _,o in ipairs(c:GetDescendants()) do
            if o:IsA("Motor6D") and not o.Enabled then o.Enabled=true end
        end
    end)
end
task.spawn(function() task.wait(0.5) startAR() end)
lp.CharacterAdded:Connect(function() task.wait(0.3) if not arConns.anti then startAR() end end)

-- ============ TIMER ESP (always running) ============
local espConn=nil local espInst={}
local function startTimerESP()
    if espConn then espConn:Disconnect() espConn=nil end
    for _,v in pairs(espInst) do pcall(function() if v.bb then v.bb:Destroy() end end) end espInst={}
    local plots=workspace:FindFirstChild("Plots")
    local function makeESP(plot,part)
        if espInst[plot.Name] then pcall(function() espInst[plot.Name].bb:Destroy() end) end
        local bb=Instance.new("BillboardGui") bb.Name="PhTimerESP" bb.Size=UDim2.fromOffset(70,28)
        bb.StudsOffset=Vector3.new(0,9,0) bb.AlwaysOnTop=true bb.Adornee=part bb.MaxDistance=1500 bb.Parent=plot
        local bg=Instance.new("Frame",bb) bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(5,12,22)
        bg.BackgroundTransparency=0.2 bg.BorderSizePixel=0 addCorner(bg,6) addStroke(bg,C.ACC,1.5,0.1)
        local lbl=Instance.new("TextLabel",bg) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Font=Enum.Font.GothamBold lbl.TextSize=13 lbl.TextColor3=Color3.fromRGB(255,255,60)
        lbl.TextStrokeTransparency=0 lbl.TextStrokeColor3=Color3.new(0,0,0)
        espInst[plot.Name]={bb=bb,lbl=lbl}
    end
    espConn=RunService.RenderStepped:Connect(function()
        if not plots then plots=workspace:FindFirstChild("Plots") return end
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
                        e.lbl.TextColor3=tot<=30 and Color3.fromRGB(255,60,60) or tot<=60 and Color3.fromRGB(255,180,50) or Color3.fromRGB(255,255,60)
                    end
                end
            else
                local e=espInst[plot.Name] if e then pcall(function() e.bb:Destroy() end) espInst[plot.Name]=nil end
            end
        end
    end)
end
startTimerESP()

-- ============ INSTANT STEAL (9 stud reach) ============
local isStealing=false local stealProgress=0
local allAnimals={} local promptCache={} local stealCache={}
local autoBlockEnabled=false local autoBlockTarget=nil

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
            if pods then
                for _,pod in ipairs(pods:GetChildren()) do
                    local base=pod:FindFirstChild("Base") local spn=base and base:FindFirstChild("Spawn")
                    local att=spn and spn:FindFirstChild("PromptAttachment")
                    local wp=att and att.WorldPosition or pod:GetPivot().Position
                    table.insert(allAnimals,{plotName=plot.Name,slot=pod.Name,worldPos=wp,uid=plot.Name..pod.Name})
                end
            end
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
local function blockAndClick(target)
    if not target then return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer",target) end)
    task.wait(0.3)
    local size=workspace.CurrentCamera.ViewportSize
    for i=1,8 do
        VIM:SendMouseButtonEvent(size.X/2,size.Y/2+75,0,true,game,1) task.wait(0.02)
        VIM:SendMouseButtonEvent(size.X/2,size.Y/2+75,0,false,game,1) task.wait(0.04)
    end
end
local function execSteal(prompt)
    local data=stealCache[prompt]
    if not data or not data.ready or isStealing then return end
    data.ready=false isStealing=true stealProgress=0
    -- auto block fires 0.2s before steal completes (not on proximity)
    if autoBlockEnabled and autoBlockTarget then
        task.spawn(function() task.wait(0.2) blockAndClick(autoBlockTarget) end)
    end
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        local t0=tick() local dur=0.08
        while tick()-t0<dur do stealProgress=math.clamp((tick()-t0)/dur,0,1) task.wait() end
        stealProgress=1
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        pcall(function() fireproximityprompt(prompt,0) end)
        task.wait(0.1) data.ready=true isStealing=false stealProgress=0
    end)
end
RunService.Heartbeat:Connect(function()
    if isStealing then return end
    local hrp=getRoot() if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if not best or bd>9 then return end   -- 9 studs
    local prompt=promptCache[best.uid]
    if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt) if stealCache[prompt] then execSteal(prompt) end
end)

-- ============ INSTA RESET (copied exactly from source) ============
local tw=TweenService
local LocalPlayer=lp
local COLORS_R={BG=Color3.fromRGB(6,6,6),Frame=Color3.fromRGB(16,16,16),Neon1=Color3.fromRGB(255,255,255),Neon2=Color3.fromRGB(100,100,100),Text=Color3.fromRGB(235,235,235),Dim=Color3.fromRGB(110,110,110),Green=Color3.fromRGB(80,220,120),Red=Color3.fromRGB(220,80,80)}
local function tweenR(o,p,t,style) tw:Create(o,TweenInfo.new(t or 0.25,style or Enum.EasingStyle.Quint),p):Play() end
local cachedCraftCFrame=nil local craftMachine=nil
local function updateCraftCache()
    craftMachine=Workspace:FindFirstChild("CraftingMachine")
    if craftMachine then
        local part=craftMachine:FindFirstChild("VFX",true)
        if part then part=part:FindFirstChild("Secret",true) if part then part=part:FindFirstChild("SoundPart",true) if part then cachedCraftCFrame=part.CFrame end end end
    end
end
updateCraftCache()
Workspace.ChildAdded:Connect(function(c) if c.Name=="CraftingMachine" then task.defer(updateCraftCache) end end)
Players.RespawnTime=0
RunService.Heartbeat:Connect(function() if Players.RespawnTime~=0 then Players.RespawnTime=0 end end)
local resetDebounce=false local camConnection=nil local charConnection_r=nil local cameraLocked=false
local ResetBtnRef=nil local StatusLabelRef=nil

local function doReset()
    if resetDebounce then return end resetDebounce=true
    local char=LocalPlayer.Character
    if not char then resetDebounce=false return end
    local hum=char:FindFirstChildOfClass("Humanoid") local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health<=0 then resetDebounce=false return end
    if ResetBtnRef then ResetBtnRef.Text="..." end
    if StatusLabelRef then StatusLabelRef.Text="RESETTING" StatusLabelRef.TextColor3=COLORS_R.Red end
    cameraLocked=true Camera.CameraSubject=nil
    if charConnection_r then charConnection_r:Disconnect() end
    charConnection_r=LocalPlayer.CharacterAdded:Connect(function(newChar)
        charConnection_r:Disconnect()
        cameraLocked=false Camera.CameraSubject=nil
        task.defer(function()
            local newHum=newChar:WaitForChild("Humanoid",0.5)
            if newHum then Camera.CameraSubject=newHum end
        end)
    end)
    if cachedCraftCFrame then hrp.CFrame=cachedCraftCFrame
    elseif craftMachine then updateCraftCache(); if cachedCraftCFrame then hrp.CFrame=cachedCraftCFrame end end
    Players.RespawnTime=0
    hum.Health=0
    hum:ChangeState(Enum.HumanoidStateType.Dead)
    char:BreakJoints()
    task.wait(0.03)
    pcall(function() LocalPlayer:LoadCharacter() end)
    task.delay(0.3,function()
        if ResetBtnRef then ResetBtnRef.Text="INSTA RESET" end
        if StatusLabelRef then StatusLabelRef.Text="ACTIVE" StatusLabelRef.TextColor3=COLORS_R.Green end
        resetDebounce=false
    end)
end
UIS.InputBegan:Connect(function(inp,gp) if not gp and inp.KeyCode==Enum.KeyCode.R then doReset() end end)

-- ============ CARPET ============
local carpetActive=false local carpetConns={}
local function stopCarpet() for _,c in ipairs(carpetConns) do pcall(function() c:Disconnect() end) end carpetConns={} end
local function startCarpet()
    stopCarpet()
    local hum=getHum() if not hum then return end
    local bp=lp:FindFirstChild("Backpack") if not bp then return end
    for _,t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and (t.Name:lower():find("carpet") or t.Name:lower():find("flying")) then hum:EquipTool(t) break end
    end
    table.insert(carpetConns,RunService.Heartbeat:Connect(function()
        if not carpetActive then stopCarpet() return end
        local hrp=getRoot() local hum2=getHum() if not hrp or not hum2 then return end
        local dir=hum2.MoveDirection
        if dir.Magnitude>0 then hrp.AssemblyLinearVelocity=Vector3.new(dir.X*120,hrp.AssemblyLinearVelocity.Y,dir.Z*120) end
    end))
    local net=ReplicatedStorage:FindFirstChild("Packages")
    if net then net=net:FindFirstChild("Net") end if net then net=net:FindFirstChild("RE/UseItem") end
    if net then table.insert(carpetConns,RunService.Heartbeat:Connect(function() if not carpetActive then return end pcall(function() net:FireServer(0.23450689315795897) end) end)) end
end
lp.CharacterAdded:Connect(function() if carpetActive then task.wait(0.5) startCarpet() end end)

-- ============ DESYNC ============
local desyncEnabled=false local desyncConn=nil
local function startDesync()
    if desyncConn then return end
    desyncConn=RunService.Stepped:Connect(function()
        if not desyncEnabled then return end
        local c=lp.Character if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        hrp.CFrame=hrp.CFrame
    end)
end
local function stopDesync() desyncEnabled=false if desyncConn then desyncConn:Disconnect() desyncConn=nil end end

-- ============ ANTI LAG ============
local antiLagActive=false local removeAccActive=false local alDescConn=nil
local function processDesc(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") then obj.Enabled=false end
    if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1 end
    if obj:IsA("BasePart") then obj.Material=Enum.Material.Plastic obj.Reflectance=0 obj.CastShadow=false end
end
local function enableAntiLag()
    if antiLagActive then return end antiLagActive=true
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    Lighting.GlobalShadows=false Lighting.FogEnd=9e9 Lighting.Brightness=1
    Lighting.EnvironmentDiffuseScale=0 Lighting.EnvironmentSpecularScale=0
    for _,e in pairs(Lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end
    end
    for _,obj in pairs(Workspace:GetDescendants()) do pcall(processDesc,obj) end
    alDescConn=Workspace.DescendantAdded:Connect(function(obj) pcall(processDesc,obj) end)
end
local function disableAntiLag()
    antiLagActive=false if alDescConn then alDescConn:Disconnect() alDescConn=nil end
end

-- ============ FLASH TP (from 706 + Sleepyz) ============
local POS_CARPET      = Vector3.new(-332,-7,67)
local POS_FLASH_TARGET= Vector3.new(-331.8,-4.7,27.5)
local flashTPCmds = {"rocket","inverse","tiny","jumpscare","morph"} -- no balloon

local function equipTool(name)
    local c=lp.Character local bp=lp:FindFirstChild("Backpack")
    if not c or not bp then return nil end
    local t=bp:FindFirstChild(name) or c:FindFirstChild(name)
    if not t then
        for _,v in pairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(name:lower()) then t=v break end end
    end
    local hum=getHum() if t and hum then hum:EquipTool(t) end
    return t
end

local function doFlashTP()
    local c=lp.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") local hum=getHum()
    if not hrp or not hum then return end

    task.spawn(function()
        hrp.CFrame=CFrame.new(POS_CARPET)
        local carpet=equipTool("Carpet") or equipTool("Flying Carpet")
        if carpet then task.wait(0.12) end

        local flash=equipTool("Flash") or equipTool("Flash Teleport")
        if not flash then return end
        task.wait(0.05)

        hrp.CFrame=CFrame.new(POS_CARPET,Vector3.new(POS_FLASH_TARGET.X,POS_CARPET.Y,POS_FLASH_TARGET.Z))
        local dir=(POS_FLASH_TARGET-POS_CARPET).Unit
        Camera.CameraType=Enum.CameraType.Scriptable
        Camera.CFrame=CFrame.new(POS_CARPET+(-dir*8+Vector3.new(0,4,0)),POS_FLASH_TARGET)
        task.wait(0.06)

        local vp=Camera.ViewportSize local cx,cy=math.floor(vp.X/2),math.floor(vp.Y/2)
        VIM:SendMouseButtonEvent(cx,cy,0,true,game,1) task.wait(0.05)
        VIM:SendMouseButtonEvent(cx,cy,0,false,game,1)
        Camera.CameraType=Enum.CameraType.Custom

        -- Fire AP cmds immediately after TP
        task.wait(0.15)
        local target=_G.PhantomAPTarget
        if not target then
            -- find nearest
            local hrp2=getRoot() if not hrp2 then return end
            local nearest,dist=nil,math.huge
            for _,p in pairs(Players:GetPlayers()) do
                if p~=lp and p.Character then
                    local r=p.Character:FindFirstChild("HumanoidRootPart")
                    if r then local d=(hrp2.Position-r.Position).Magnitude if d<dist then dist=d nearest=p end end
                end
            end
            target=nearest
        end
        if target then runCmds(target,flashTPCmds,true) end

        -- Block nearest after TP
        task.wait(0.3)
        local tb=autoBlockTarget
        if tb then task.spawn(function() blockAndClick(tb) end) end
    end)
end

-- ============ BALLOON RESET DETECTION ============
-- When balloon inflates head, auto reset then auto flash TP
local function watchBalloon(char)
    task.spawn(function()
        local head=char:WaitForChild("Head",5) if not head then return end
        local origY=head.Size.Y
        head:GetPropertyChangedSignal("Size"):Connect(function()
            if head.Size.Y > origY*1.8 then
                -- balloon detected
                task.spawn(doReset)
                local conn; conn=lp.CharacterAdded:Connect(function()
                    conn:Disconnect()
                    task.wait(0.6)
                    task.spawn(doFlashTP)
                end)
            end
        end)
    end)
end
lp.CharacterAdded:Connect(watchBalloon)
if lp.Character then watchBalloon(lp.Character) end

-- ============ SCREEN GUI ============
local sg=Instance.new("ScreenGui")
sg.Name="PhantomSuite" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999
sg.Parent=game:GetService("CoreGui")

-- ============ ALLOW/DISALLOW BAR (top, fixed, unmovable) ============
local adBar=Instance.new("Frame",sg)
adBar.Size=UDim2.fromOffset(200,30) adBar.AnchorPoint=Vector2.new(0.5,0)
adBar.Position=UDim2.new(0.5,0,0,0) adBar.BackgroundColor3=C.BG
adBar.BackgroundTransparency=0.1 adBar.BorderSizePixel=0 adBar.ZIndex=200
addCorner(adBar,0) addStroke(adBar,C.ACC,1.2,0.2)

local adBtn=Instance.new("TextButton",adBar)
adBtn.Size=UDim2.new(1,0,1,0) adBtn.BackgroundTransparency=1
adBtn.Text="🔒  ALLOW / DISALLOW" adBtn.Font=Enum.Font.GothamBold
adBtn.TextSize=11 adBtn.TextColor3=C.ACC adBtn.BorderSizePixel=0

adBtn.MouseButton1Click:Connect(function()
    adBtn.Text="toggling..."
    pcall(function()
        game:GetService("ReplicatedStorage").Packages.Net["RE/PlotService/ToggleFriends"]:FireServer()
    end)
    task.wait(0.5)
    adBtn.Text="🔒  ALLOW / DISALLOW"
end)

-- ============ LOCK UI BUTTON (top right) ============
local lockBtn=Instance.new("TextButton",sg)
lockBtn.Size=UDim2.fromOffset(70,26) lockBtn.Position=UDim2.new(1,-76,0,2)
lockBtn.BackgroundColor3=C.BG lockBtn.BackgroundTransparency=0.1
lockBtn.Text="🔓 UNLOCK" lockBtn.Font=Enum.Font.GothamBold
lockBtn.TextSize=9 lockBtn.TextColor3=C.DIM lockBtn.BorderSizePixel=0 lockBtn.ZIndex=200
addCorner(lockBtn,6) addStroke(lockBtn,C.DIM,1,0.3)
lockBtn.MouseButton1Click:Connect(function()
    uiLocked=not uiLocked
    lockBtn.Text=uiLocked and "🔒 LOCKED" or "🔓 UNLOCK"
    lockBtn.TextColor3=uiLocked and C.RED or C.DIM
    local st=lockBtn:FindFirstChildOfClass("UIStroke")
    if st then st.Color=uiLocked and C.RED or C.DIM end
end)

-- ============ PROGRESS BAR ============
local grabBar=Instance.new("Frame",sg)
grabBar.Size=UDim2.fromOffset(150,18) grabBar.AnchorPoint=Vector2.new(0.5,0)
grabBar.Position=UDim2.new(0.5,0,0,32) grabBar.BackgroundColor3=C.BG
grabBar.BackgroundTransparency=0.1 grabBar.BorderSizePixel=0 grabBar.ZIndex=60
addCorner(grabBar,7) addStroke(grabBar,C.ACC,1.2,0.15)
local gFill=Instance.new("Frame",grabBar) gFill.Size=UDim2.new(0,0,1,0)
gFill.BackgroundColor3=C.ACC gFill.BorderSizePixel=0 addCorner(gFill,7)
local gTxt=Instance.new("TextLabel",grabBar) gTxt.Size=UDim2.new(1,0,1,0)
gTxt.BackgroundTransparency=1 gTxt.Text="GRAB" gTxt.Font=Enum.Font.GothamBold
gTxt.TextSize=9 gTxt.TextColor3=Color3.new(1,1,1) gTxt.ZIndex=61

RunService.Heartbeat:Connect(function()
    local hrp=getRoot() if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if isStealing then
        TweenService:Create(gFill,TweenInfo.new(0.05),{Size=UDim2.new(math.clamp(stealProgress,0,1),0,1,0),BackgroundColor3=C.GREEN}):Play()
        gTxt.Text="STEALING!"
    elseif not best then
        TweenService:Create(gFill,TweenInfo.new(0.1),{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.DIM}):Play()
        gTxt.Text="SEARCHING"
    elseif bd<=9 then
        TweenService:Create(gFill,TweenInfo.new(0.05),{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.GREEN}):Play()
        gTxt.Text="STEALING!"
    elseif bd<=40 then
        TweenService:Create(gFill,TweenInfo.new(0.1),{Size=UDim2.new(math.clamp(1-(bd-9)/31,0,1),0,1,0),BackgroundColor3=C.ACC}):Play()
        gTxt.Text=math.floor(bd).."m"
    else
        TweenService:Create(gFill,TweenInfo.new(0.1),{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.DIM}):Play()
        gTxt.Text=math.floor(bd).."m"
    end
end)

-- ============ HELPER: make a square panel ============
local function makeSquarePanel(w,h,title,accentCol)
    local f=Instance.new("Frame",sg)
    f.Size=UDim2.fromOffset(w,h) f.BackgroundColor3=C.BG
    f.BackgroundTransparency=TRANS f.BorderSizePixel=0 f.Visible=false f.Active=true
    addCorner(f,12) addStroke(f,accentCol or C.ACC,1.5,0.1) makeDrag(f)
    local hdr=Instance.new("Frame",f) hdr.Size=UDim2.new(1,0,0,24) hdr.BackgroundColor3=C.PANEL
    hdr.BackgroundTransparency=TRANS hdr.BorderSizePixel=0 addCorner(hdr,12)
    local hfix=Instance.new("Frame",hdr) hfix.Size=UDim2.new(1,0,0.5,0) hfix.Position=UDim2.new(0,0,0.5,0)
    hfix.BackgroundColor3=C.PANEL hfix.BackgroundTransparency=TRANS hfix.BorderSizePixel=0
    local tl=Instance.new("TextLabel",hdr) tl.Size=UDim2.new(1,-4,1,0) tl.Position=UDim2.new(0,7,0,0)
    tl.BackgroundTransparency=1 tl.Text=title tl.Font=Enum.Font.GothamBlack
    tl.TextSize=10 tl.TextColor3=accentCol or C.ACC tl.TextXAlignment=Enum.TextXAlignment.Left
    local layout=Instance.new("UIListLayout",f) layout.Padding=UDim.new(0,4)
    layout.HorizontalAlignment=Enum.HorizontalAlignment.Center layout.SortOrder=Enum.SortOrder.LayoutOrder
    local pad=Instance.new("UIPadding",f)
    pad.PaddingTop=UDim.new(0,28) pad.PaddingBottom=UDim.new(0,8) pad.PaddingLeft=UDim.new(0,6) pad.PaddingRight=UDim.new(0,6)
    return f
end

local function makeBtn(parent,text,order,col)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,0,0,28) btn.BackgroundColor3=C.ITEM
    btn.BackgroundTransparency=0.15 btn.Text=text btn.Font=Enum.Font.GothamBold
    btn.TextSize=11 btn.TextColor3=col or C.TXT btn.BorderSizePixel=0
    btn.AutoButtonColor=false btn.LayoutOrder=order
    addCorner(btn,7) addStroke(btn,col or C.ACC,1,0.4)
    return btn
end

-- ============ AP TOGGLE BUTTON (square style) ============
_G.PhantomAPTarget=nil

local toggleBtn=Instance.new("TextButton",sg)
toggleBtn.Size=UDim2.fromOffset(44,44) toggleBtn.Position=UDim2.new(0,6,0,56)
toggleBtn.BackgroundColor3=C.BG toggleBtn.BackgroundTransparency=TRANS
toggleBtn.Text="AP" toggleBtn.Font=Enum.Font.GothamBlack toggleBtn.TextSize=12
toggleBtn.TextColor3=C.ACC toggleBtn.BorderSizePixel=0
addCorner(toggleBtn,10) local tStroke=addStroke(toggleBtn,C.ACC,1.5,0.15)

-- ============ FLASH TP BUTTON (left side, below AP) ============
local flashBtn=Instance.new("TextButton",sg)
flashBtn.Size=UDim2.fromOffset(44,44) flashBtn.Position=UDim2.new(0,6,0,106)
flashBtn.BackgroundColor3=C.BG flashBtn.BackgroundTransparency=TRANS
flashBtn.Text="⚡" flashBtn.Font=Enum.Font.GothamBlack flashBtn.TextSize=16
flashBtn.TextColor3=C.ORG flashBtn.BorderSizePixel=0
addCorner(flashBtn,10) local flashStroke=addStroke(flashBtn,C.ORG,1.5,0.15)
local flashLbl=Instance.new("TextLabel",flashBtn) flashLbl.Size=UDim2.new(1,0,0.3,0)
flashLbl.Position=UDim2.new(0,0,0.7,0) flashLbl.BackgroundTransparency=1
flashLbl.Text="FLASH" flashLbl.Font=Enum.Font.GothamBold flashLbl.TextSize=6 flashLbl.TextColor3=C.DIM

-- ============ MAIN AP PANEL (original) ============
local panel=Instance.new("Frame",sg)
panel.Size=UDim2.fromOffset(155,10) panel.Position=UDim2.new(0,58,0,56)
panel.BackgroundColor3=C.BG panel.BackgroundTransparency=TRANS
panel.BorderSizePixel=0 panel.AutomaticSize=Enum.AutomaticSize.Y panel.Visible=false
addCorner(panel,12) addStroke(panel,C.ACC,1.5,0.1) makeDrag(panel)

local pLayout=Instance.new("UIListLayout",panel)
pLayout.Padding=UDim.new(0,4) pLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center pLayout.SortOrder=Enum.SortOrder.LayoutOrder
local pPad=Instance.new("UIPadding",panel)
pPad.PaddingTop=UDim.new(0,6) pPad.PaddingBottom=UDim.new(0,8) pPad.PaddingLeft=UDim.new(0,6) pPad.PaddingRight=UDim.new(0,6)

local hdr=Instance.new("TextLabel",panel)
hdr.Size=UDim2.new(1,0,0,18) hdr.BackgroundTransparency=1 hdr.Text="PHANTOM AP"
hdr.Font=Enum.Font.GothamBlack hdr.TextSize=11 hdr.TextColor3=C.ACC hdr.LayoutOrder=0

local function mkDivAP(order)
    local dv=Instance.new("Frame",panel) dv.Size=UDim2.new(1,0,0,1)
    dv.BackgroundColor3=C.ACC dv.BackgroundTransparency=0.5 dv.BorderSizePixel=0 dv.LayoutOrder=order
end
mkDivAP(1)

local scrollContainer=Instance.new("Frame",panel)
scrollContainer.Size=UDim2.new(1,0,0,120) scrollContainer.BackgroundTransparency=1
scrollContainer.LayoutOrder=2 scrollContainer.ClipsDescendants=true

local scroll=Instance.new("ScrollingFrame",scrollContainer)
scroll.Size=UDim2.new(1,0,1,0) scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
scroll.ScrollBarThickness=2 scroll.ScrollBarImageColor3=C.ACC
scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local sLayout=Instance.new("UIListLayout",scroll) sLayout.Padding=UDim.new(0,3) sLayout.SortOrder=Enum.SortOrder.LayoutOrder

local function buildCards()
    for _,c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    _G.PhantomAPTarget=nil
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame",scroll)
        card.Size=UDim2.new(1,-2,0,38) card.BackgroundColor3=C.ITEM
        card.BackgroundTransparency=0.2 card.BorderSizePixel=0 card.LayoutOrder=i
        addCorner(card,8) local cStroke=addStroke(card,Color3.fromRGB(0,60,80),1,0.5)
        local av=Instance.new("ImageLabel",card)
        av.Size=UDim2.fromOffset(28,28) av.Position=UDim2.new(0,4,0.5,-14)
        av.BackgroundColor3=C.PANEL av.BorderSizePixel=0
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        addCorner(av,14)
        local nl=Instance.new("TextLabel",card)
        nl.Size=UDim2.new(1,-38,0,16) nl.Position=UDim2.new(0,36,0,4) nl.BackgroundTransparency=1
        nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=10 nl.TextColor3=C.TXT
        nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",card)
        ul.Size=UDim2.new(1,-38,0,12) ul.Position=UDim2.new(0,36,0,20) ul.BackgroundTransparency=1
        ul.Text="@"..p.Name ul.Font=Enum.Font.Gotham ul.TextSize=8 ul.TextColor3=C.DIM
        ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local cb=Instance.new("TextButton",card)
        cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text="" cb.ZIndex=5
        cb.MouseButton1Click:Connect(function()
            _G.PhantomAPTarget=p autoBlockTarget=p
            for _,c2 in ipairs(scroll:GetChildren()) do
                if c2:IsA("Frame") then
                    c2.BackgroundColor3=C.ITEM c2.BackgroundTransparency=0.2
                    local st=c2:FindFirstChildOfClass("UIStroke") if st then st.Color=Color3.fromRGB(0,60,80) st.Transparency=0.5 end
                end
            end
            card.BackgroundColor3=Color3.fromRGB(0,40,60) card.BackgroundTransparency=0
            cStroke.Color=C.ACC cStroke.Transparency=0
        end)
    end
end

mkDivAP(3)
local selLbl=Instance.new("TextLabel",panel)
selLbl.Size=UDim2.new(1,0,0,12) selLbl.BackgroundTransparency=1 selLbl.Text="tap player to select"
selLbl.Font=Enum.Font.Gotham selLbl.TextSize=8 selLbl.TextColor3=C.DIM selLbl.LayoutOrder=4
mkDivAP(5)

local function getTarget()
    local t=_G.PhantomAPTarget if t and t.Parent then return t end
    local nearest,dist=nil,math.huge
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then for _,p in pairs(Players:GetPlayers()) do if p~=lp and p.Character then local r=p.Character:FindFirstChild("HumanoidRootPart") if r then local dd=(r.Position-hrp.Position).Magnitude if dd<dist then dist=dd nearest=p end end end end end
    return nearest
end

local function mkCmd(text,order,cmds,jail)
    local btn=Instance.new("TextButton",panel)
    btn.Size=UDim2.new(1,0,0,26) btn.BackgroundColor3=C.ITEM btn.BackgroundTransparency=0.15
    btn.Text=text btn.Font=Enum.Font.GothamBold btn.TextSize=11 btn.TextColor3=C.TXT
    btn.BorderSizePixel=0 btn.AutoButtonColor=true btn.LayoutOrder=order
    addCorner(btn,7) addStroke(btn,C.ACC,1,0.4)
    local busy=false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        local target=getTarget() if not target then return end
        busy=true btn.AutoButtonColor=false local orig=btn.Text
        btn.Text="running..." btn.TextColor3=C.ACC
        runCmds(target,cmds,jail)
        task.delay(2,function() btn.Text=orig btn.TextColor3=C.TXT btn.AutoButtonColor=true busy=false end)
    end)
end
-- NO balloon, NO ragdoll buttons. ALL without balloon
mkCmd("ALL",6,{"rocket","inverse","tiny","jumpscare","morph"},true)

-- ============ MINI AP PANEL ============
local miniPanel=Instance.new("Frame",sg)
miniPanel.Size=UDim2.fromOffset(218,10) miniPanel.Position=UDim2.new(0,222,0,56)
miniPanel.BackgroundColor3=C.BG miniPanel.BackgroundTransparency=TRANS
miniPanel.BorderSizePixel=0 miniPanel.AutomaticSize=Enum.AutomaticSize.Y miniPanel.Visible=false
addCorner(miniPanel,12) addStroke(miniPanel,C.ACC,1.5,0.1) makeDrag(miniPanel)

local mpLayout=Instance.new("UIListLayout",miniPanel)
mpLayout.Padding=UDim.new(0,3) mpLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center mpLayout.SortOrder=Enum.SortOrder.LayoutOrder
local mpPad=Instance.new("UIPadding",miniPanel)
mpPad.PaddingTop=UDim.new(0,6) mpPad.PaddingBottom=UDim.new(0,8) mpPad.PaddingLeft=UDim.new(0,5) mpPad.PaddingRight=UDim.new(0,5)

local mHdr=Instance.new("TextLabel",miniPanel)
mHdr.Size=UDim2.new(1,0,0,16) mHdr.BackgroundTransparency=1 mHdr.Text="PHANTOM MINI AP"
mHdr.Font=Enum.Font.GothamBlack mHdr.TextSize=10 mHdr.TextColor3=C.ACC mHdr.LayoutOrder=0
local mDiv=Instance.new("Frame",miniPanel) mDiv.Size=UDim2.new(1,0,0,1)
mDiv.BackgroundColor3=C.ACC mDiv.BackgroundTransparency=0.5 mDiv.BorderSizePixel=0 mDiv.LayoutOrder=1

local miniScroll=Instance.new("ScrollingFrame",miniPanel)
miniScroll.Size=UDim2.new(1,-4,0,200) miniScroll.BackgroundTransparency=1 miniScroll.BorderSizePixel=0
miniScroll.ScrollBarThickness=2 miniScroll.ScrollBarImageColor3=C.ACC
miniScroll.CanvasSize=UDim2.new(0,0,0,0) miniScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y miniScroll.LayoutOrder=2
local msLayout=Instance.new("UIListLayout",miniScroll) msLayout.Padding=UDim.new(0,3) msLayout.SortOrder=Enum.SortOrder.LayoutOrder

-- Mini AP uses CHAT directly (fixes cmd carryover bug)
local MINI_CMDS={
    {e="🎈",k="balloon",cd=29, col=Color3.fromRGB(30,50,180)},
    {e="🤸",k="ragdoll",cd=29, col=Color3.fromRGB(140,20,20)},
    {e="⛓️", k="jail",   cd=59, col=Color3.fromRGB(10,90,10)},
    {e="🚀",k="rocket", cd=119,col=Color3.fromRGB(150,70,0)},
    {e="🐜",k="tiny",   cd=59, col=Color3.fromRGB(60,0,130)},
}

local function buildMiniCards()
    for _,c in ipairs(miniScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",miniScroll)
        row.Size=UDim2.new(1,-2,0,30) row.BackgroundColor3=C.ITEM
        row.BackgroundTransparency=0.2 row.BorderSizePixel=0 row.LayoutOrder=i
        addCorner(row,7) addStroke(row,Color3.fromRGB(0,60,80),1,0.5)
        local av=Instance.new("ImageLabel",row)
        av.Size=UDim2.fromOffset(22,22) av.Position=UDim2.new(0,3,0.5,-11)
        av.BackgroundColor3=C.PANEL av.BorderSizePixel=0
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        addCorner(av,11)
        local nl=Instance.new("TextLabel",row)
        nl.Size=UDim2.new(0,42,0,13) nl.Position=UDim2.new(0,27,0,3) nl.BackgroundTransparency=1
        nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=8 nl.TextColor3=C.TXT
        nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",row)
        ul.Size=UDim2.new(0,42,0,10) ul.Position=UDim2.new(0,27,0,16) ul.BackgroundTransparency=1
        ul.Text="@"..p.Name ul.Font=Enum.Font.Gotham ul.TextSize=7 ul.TextColor3=C.DIM
        ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local xOff=72
        for _,cmd in ipairs(MINI_CMDS) do
            local btn=Instance.new("TextButton",row)
            btn.Size=UDim2.fromOffset(25,22) btn.Position=UDim2.new(0,xOff,0.5,-11)
            btn.BackgroundColor3=cmd.col btn.BackgroundTransparency=0.1 btn.BorderSizePixel=0
            btn.Text=cmd.e btn.Font=Enum.Font.GothamBold btn.TextSize=13 btn.AutoButtonColor=false
            addCorner(btn,5)
            local origCol=cmd.col local captK=cmd.k local captP=p local onCD=false local cdEnd=0
            local cdLbl=Instance.new("TextLabel",btn) cdLbl.Size=UDim2.new(1,0,1,0) cdLbl.BackgroundTransparency=1
            cdLbl.Text="" cdLbl.Font=Enum.Font.GothamBold cdLbl.TextSize=7 cdLbl.TextColor3=Color3.new(1,1,1) cdLbl.ZIndex=2
            btn.MouseButton1Click:Connect(function()
                if onCD then return end onCD=true cdEnd=tick()+cmd.cd
                btn.BackgroundColor3=C.RED btn.Text=""
                runSingleCmdChat(captP,captK)  -- chat method, no carryover bug
                task.spawn(function()
                    while tick()<cdEnd do cdLbl.Text=tostring(math.ceil(cdEnd-tick())) task.wait(0.5) end
                    if btn.Parent then btn.Text=cmd.e cdLbl.Text="" btn.BackgroundColor3=origCol end
                    onCD=false
                end)
            end)
            xOff=xOff+27
        end
    end
end

-- ============ FLASH TP PANEL ============
local flashPanel=makeSquarePanel(165,10,"⚡ PHANTOM FLASH",C.ORG)
flashPanel.AutomaticSize=Enum.AutomaticSize.Y

local fpGo=makeBtn(flashPanel,"⚡  FLASH TP + BLOCK",1,C.ORG)
fpGo.MouseButton1Click:Connect(function()
    fpGo.Text="running..." fpGo.TextColor3=Color3.fromRGB(255,200,80)
    task.spawn(doFlashTP)
    task.delay(3,function() if fpGo.Parent then fpGo.Text="⚡  FLASH TP + BLOCK" fpGo.TextColor3=C.ORG end end)
end)

-- Auto block toggle in flash panel
local abRow2=Instance.new("Frame",flashPanel) abRow2.Size=UDim2.new(1,0,0,26)
abRow2.BackgroundColor3=C.ITEM abRow2.BackgroundTransparency=0.2 abRow2.BorderSizePixel=0 abRow2.LayoutOrder=2
addCorner(abRow2,7) addStroke(abRow2,C.ORG,1,0.4)
local abL2=Instance.new("TextLabel",abRow2) abL2.Size=UDim2.new(1,-50,1,0) abL2.Position=UDim2.new(0,8,0,0)
abL2.BackgroundTransparency=1 abL2.Text="Auto Block" abL2.Font=Enum.Font.GothamBold abL2.TextSize=9 abL2.TextColor3=C.TXT abL2.TextXAlignment=Enum.TextXAlignment.Left
local abTog2=Instance.new("TextButton",abRow2) abTog2.Size=UDim2.fromOffset(40,18) abTog2.Position=UDim2.new(1,-44,0.5,-9)
abTog2.BackgroundColor3=C.ITEM abTog2.BackgroundTransparency=0.1 abTog2.Text="OFF"
abTog2.Font=Enum.Font.GothamBold abTog2.TextSize=8 abTog2.TextColor3=C.DIM abTog2.BorderSizePixel=0 abTog2.AutoButtonColor=false
addCorner(abTog2,5)
abTog2.MouseButton1Click:Connect(function()
    autoBlockEnabled=not autoBlockEnabled
    if autoBlockEnabled then abTog2.Text="ON" abTog2.BackgroundColor3=C.ACC abTog2.TextColor3=Color3.new(0,0,0)
        if _G.PhantomAPTarget then autoBlockTarget=_G.PhantomAPTarget end
    else abTog2.Text="OFF" abTog2.BackgroundColor3=C.ITEM abTog2.TextColor3=C.DIM end
end)

-- Manual block player list
local fpSelLbl=Instance.new("TextLabel",flashPanel) fpSelLbl.Size=UDim2.new(1,0,0,10) fpSelLbl.BackgroundTransparency=1
fpSelLbl.Text="tap to select + block:" fpSelLbl.Font=Enum.Font.Gotham fpSelLbl.TextSize=7 fpSelLbl.TextColor3=C.DIM fpSelLbl.LayoutOrder=3

local fpScroll=Instance.new("ScrollingFrame",flashPanel)
fpScroll.Size=UDim2.new(1,-4,0,80) fpScroll.BackgroundTransparency=1 fpScroll.BorderSizePixel=0
fpScroll.ScrollBarThickness=2 fpScroll.ScrollBarImageColor3=C.ORG
fpScroll.CanvasSize=UDim2.new(0,0,0,0) fpScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y fpScroll.LayoutOrder=4
local fpSLy=Instance.new("UIListLayout",fpScroll) fpSLy.Padding=UDim.new(0,3) fpSLy.SortOrder=Enum.SortOrder.LayoutOrder
local selectedFPRef=nil

local function buildFPList()
    for _,c in ipairs(fpScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end selectedFPRef=nil
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local row=Instance.new("Frame",fpScroll)
        row.Size=UDim2.new(1,-2,0,26) row.BackgroundColor3=C.ITEM row.BackgroundTransparency=0.2
        row.BorderSizePixel=0 row.LayoutOrder=i addCorner(row,5) addStroke(row,C.ORG,1,0.6)
        local nl=Instance.new("TextLabel",row)
        nl.Size=UDim2.new(1,-52,1,0) nl.Position=UDim2.new(0,6,0,0) nl.BackgroundTransparency=1
        nl.Text=p.DisplayName.."  @"..p.Name nl.Font=Enum.Font.GothamBold nl.TextSize=8 nl.TextColor3=C.TXT
        nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        -- block button (appears on right, always visible)
        local blk=Instance.new("TextButton",row)
        blk.Size=UDim2.fromOffset(46,18) blk.Position=UDim2.new(1,-50,0.5,-9)
        blk.BackgroundColor3=C.ITEM blk.BackgroundTransparency=0.1 blk.Text="BLOCK"
        blk.Font=Enum.Font.GothamBold blk.TextSize=8 blk.TextColor3=C.DIM
        blk.BorderSizePixel=0 blk.AutoButtonColor=false
        addCorner(blk,5) addStroke(blk,C.ORG,1,0.7)
        local cap=p
        row.InputBegan:Connect(function(inp)
            if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
            if selectedFPRef and selectedFPRef.Parent then
                selectedFPRef.BackgroundColor3=C.ITEM
                local ss=selectedFPRef:FindFirstChildOfClass("UIStroke") if ss then ss.Transparency=0.6 end
                local tb=selectedFPRef:FindFirstChild("BLOCK",true)
                if tb then tb.TextColor3=C.DIM local ss2=tb:FindFirstChildOfClass("UIStroke") if ss2 then ss2.Transparency=0.7 end end
            end
            autoBlockTarget=cap _G.PhantomAPTarget=cap selectedFPRef=row
            row.BackgroundColor3=Color3.fromRGB(40,25,10)
            local ss=row:FindFirstChildOfClass("UIStroke") if ss then ss.Transparency=0 end
            blk.TextColor3=C.ORG local ss2=blk:FindFirstChildOfClass("UIStroke") if ss2 then ss2.Transparency=0 end
        end)
        blk.MouseButton1Click:Connect(function()
            task.spawn(function() blockAndClick(cap) end)
        end)
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.5) buildFPList() end)
Players.PlayerRemoving:Connect(function(p)
    if autoBlockTarget==p then autoBlockTarget=nil end
    task.wait(0.3) buildFPList()
end)

-- ============ PHANTOM RESET PANEL (exact source) ============
local resetGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
resetGui.Name="PhantomReset" resetGui.ResetOnSpawn=false resetGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local main_r=Instance.new("Frame",resetGui)
main_r.Size=UDim2.new(0,210,0,158) main_r.Position=UDim2.new(0.5,-105,0.5,-79)
main_r.BackgroundColor3=COLORS_R.BG main_r.BackgroundTransparency=0.02
main_r.BorderSizePixel=0 main_r.Active=true main_r.Draggable=true main_r.ClipsDescendants=true
local function corner_r(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 10) end
local function stroke_r(p,color,thick) local s=Instance.new("UIStroke",p) s.Color=color or Color3.fromRGB(40,40,40) s.Thickness=thick or 1.2 return s end
corner_r(main_r,14)
local mainStroke_r=stroke_r(main_r,COLORS_R.Neon2,1.5)
local mainGrad_r=Instance.new("UIGradient",mainStroke_r)
mainGrad_r.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,COLORS_R.Neon2),ColorSequenceKeypoint.new(0.45,COLORS_R.Neon2),ColorSequenceKeypoint.new(0.5,COLORS_R.Neon1),ColorSequenceKeypoint.new(0.55,COLORS_R.Neon2),ColorSequenceKeypoint.new(1,COLORS_R.Neon2)}
task.spawn(function() while main_r and main_r.Parent do for i=-1,1,0.012 do mainGrad_r.Offset=Vector2.new(i,0) task.wait() end end end)
local glass_r=Instance.new("Frame",main_r) glass_r.Size=UDim2.new(1,0,0.5,0) glass_r.BackgroundColor3=Color3.fromRGB(255,255,255) glass_r.BackgroundTransparency=0.96 glass_r.BorderSizePixel=0 glass_r.ZIndex=1; corner_r(glass_r,14)
for i=1,10 do
    local dot=Instance.new("Frame",main_r) dot.Size=UDim2.new(0,1.5,0,1.5) dot.Position=UDim2.new(math.random(),0,math.random(),0) dot.BackgroundColor3=COLORS_R.Neon1 dot.BackgroundTransparency=0.72 dot.BorderSizePixel=0 dot.ZIndex=2; corner_r(dot,50)
    task.spawn(function() while dot and dot.Parent do local t=math.random(7,13) tweenR(dot,{Position=UDim2.new(math.random(),0,math.random(),0)},t,Enum.EasingStyle.Sine) task.wait(t) end end)
end
local header_r=Instance.new("Frame",main_r) header_r.Size=UDim2.new(1,0,0,34) header_r.BackgroundColor3=Color3.fromRGB(12,12,12) header_r.BorderSizePixel=0 header_r.ZIndex=3; corner_r(header_r,14); stroke_r(header_r,Color3.fromRGB(26,26,26))
local accentLine_r=Instance.new("Frame",header_r) accentLine_r.Size=UDim2.new(1,0,0,1) accentLine_r.Position=UDim2.new(0,0,1,-1) accentLine_r.BackgroundColor3=Color3.fromRGB(200,200,200) accentLine_r.BorderSizePixel=0 accentLine_r.ZIndex=4
local accentGrad_r=Instance.new("UIGradient",accentLine_r) accentGrad_r.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.3,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(210,210,210)),ColorSequenceKeypoint.new(0.7,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
for i=1,3 do local dot=Instance.new("Frame",header_r) dot.Size=UDim2.new(0,6,0,6) dot.Position=UDim2.new(0,10+(i-1)*14,0.5,-3) dot.BackgroundColor3=i==1 and Color3.fromRGB(235,80,80) or i==2 and Color3.fromRGB(235,185,60) or Color3.fromRGB(80,200,100) dot.BorderSizePixel=0 dot.ZIndex=5; corner_r(dot,50) end
local closeBtn_r=Instance.new("TextButton",header_r) closeBtn_r.Size=UDim2.new(0,22,0,22) closeBtn_r.Position=UDim2.new(1,-27,0.5,-11) closeBtn_r.Text="X" closeBtn_r.BackgroundColor3=Color3.fromRGB(26,26,26) closeBtn_r.TextColor3=COLORS_R.Dim closeBtn_r.Font=Enum.Font.GothamBold closeBtn_r.TextSize=11 closeBtn_r.BorderSizePixel=0 closeBtn_r.AutoButtonColor=false closeBtn_r.ZIndex=5; corner_r(closeBtn_r,6); stroke_r(closeBtn_r,Color3.fromRGB(44,44,44))
closeBtn_r.MouseEnter:Connect(function() tweenR(closeBtn_r,{BackgroundColor3=Color3.fromRGB(170,30,30)},0.15) end)
closeBtn_r.MouseLeave:Connect(function() tweenR(closeBtn_r,{BackgroundColor3=Color3.fromRGB(26,26,26)},0.15) end)
closeBtn_r.MouseButton1Click:Connect(function()
    tweenR(main_r,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.3,Enum.EasingStyle.Quint)
    task.wait(0.32) resetGui:Destroy()
end)
local resetBtnFrame_r=Instance.new("Frame",main_r) resetBtnFrame_r.Size=UDim2.new(1,-12,0,36) resetBtnFrame_r.Position=UDim2.new(0,6,0,38) resetBtnFrame_r.BackgroundColor3=COLORS_R.Frame resetBtnFrame_r.BorderSizePixel=0; corner_r(resetBtnFrame_r,9); stroke_r(resetBtnFrame_r,Color3.fromRGB(28,28,28))
local resetBtnGrad_r=Instance.new("UIGradient",resetBtnFrame_r) resetBtnGrad_r.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(22,22,22)),ColorSequenceKeypoint.new(1,Color3.fromRGB(13,13,13))} resetBtnGrad_r.Rotation=90
local ResetBtn_r=Instance.new("TextButton",resetBtnFrame_r) ResetBtn_r.Size=UDim2.new(1,-4,1,-4) ResetBtn_r.Position=UDim2.new(0,2,0,2) ResetBtn_r.Text="INSTA RESET" ResetBtn_r.BackgroundColor3=Color3.fromRGB(30,30,30) ResetBtn_r.BackgroundTransparency=0.3 ResetBtn_r.Font=Enum.Font.GothamBold ResetBtn_r.TextSize=11 ResetBtn_r.TextColor3=COLORS_R.Neon1 ResetBtn_r.BorderSizePixel=0; corner_r(ResetBtn_r,7)
ResetBtnRef=ResetBtn_r
local statusFrame_r=Instance.new("Frame",main_r) statusFrame_r.Size=UDim2.new(1,-12,0,28) statusFrame_r.Position=UDim2.new(0,6,0,78) statusFrame_r.BackgroundColor3=COLORS_R.Frame statusFrame_r.BorderSizePixel=0; corner_r(statusFrame_r,9); stroke_r(statusFrame_r,Color3.fromRGB(28,28,28))
local StatusLabel_r=Instance.new("TextLabel",statusFrame_r) StatusLabel_r.Size=UDim2.new(1,0,1,0) StatusLabel_r.BackgroundTransparency=1 StatusLabel_r.Text="ACTIVE" StatusLabel_r.Font=Enum.Font.Gotham StatusLabel_r.TextSize=10 StatusLabel_r.TextColor3=COLORS_R.Green StatusLabel_r.TextXAlignment=Enum.TextXAlignment.Center
StatusLabelRef=StatusLabel_r
local keybindFrame_r=Instance.new("Frame",main_r) keybindFrame_r.Size=UDim2.new(1,-12,0,24) keybindFrame_r.Position=UDim2.new(0,6,0,110) keybindFrame_r.BackgroundColor3=COLORS_R.Frame keybindFrame_r.BackgroundTransparency=0.7; corner_r(keybindFrame_r,6); stroke_r(keybindFrame_r,Color3.fromRGB(28,28,28),0.8)
local keybindLabel_r=Instance.new("TextLabel",keybindFrame_r) keybindLabel_r.Size=UDim2.new(1,0,1,0) keybindLabel_r.BackgroundTransparency=1 keybindLabel_r.Text="HOTKEY: [R]" keybindLabel_r.Font=Enum.Font.Gotham keybindLabel_r.TextSize=9 keybindLabel_r.TextColor3=COLORS_R.Dim keybindLabel_r.TextXAlignment=Enum.TextXAlignment.Center
ResetBtn_r.MouseButton1Click:Connect(doReset)
main_r.Size=UDim2.new(0,0,0,0) main_r.Position=UDim2.new(0.5,0,0.5,0)
task.wait(0.15) tweenR(main_r,{Size=UDim2.new(0,210,0,158),Position=UDim2.new(0.5,-105,0.5,-79)},0.5,Enum.EasingStyle.Back)

-- ============ PHANTOM ANTI LAG PANEL ============
local alGui=Instance.new("ScreenGui",lp:WaitForChild("PlayerGui"))
alGui.Name="PhantomAntiLag" alGui.ResetOnSpawn=false alGui.DisplayOrder=11
local alMain=Instance.new("Frame",alGui)
alMain.Size=UDim2.new(0,200,0,130) alMain.Position=UDim2.new(0,6,0,400)
alMain.BackgroundColor3=C.BG alMain.BackgroundTransparency=0.1 alMain.BorderSizePixel=0 alMain.Active=true
addCorner(alMain,12) addStroke(alMain,C.ACC,1.5,0.1) makeDrag(alMain)
local alTitle=Instance.new("TextLabel",alMain) alTitle.Size=UDim2.new(1,-8,0,24) alTitle.Position=UDim2.new(0,6,0,4)
alTitle.BackgroundTransparency=1 alTitle.Text="⚙ PHANTOM ANTI LAG" alTitle.TextColor3=C.ACC
alTitle.Font=Enum.Font.GothamBlack alTitle.TextSize=11 alTitle.TextXAlignment=Enum.TextXAlignment.Left
local alDiv=Instance.new("Frame",alMain) alDiv.Size=UDim2.new(1,-12,0,1) alDiv.Position=UDim2.new(0,6,0,28)
alDiv.BackgroundColor3=C.ACC alDiv.BackgroundTransparency=0.5 alDiv.BorderSizePixel=0
local function alToggleRow(yPos,label,callback)
    local row=Instance.new("Frame",alMain) row.Size=UDim2.new(1,-12,0,30) row.Position=UDim2.new(0,6,0,yPos)
    row.BackgroundColor3=C.ITEM row.BackgroundTransparency=0.2 row.BorderSizePixel=0
    addCorner(row,7) addStroke(row,C.ACC,1,0.5)
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(1,-56,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.Font=Enum.Font.GothamBold lbl.TextSize=10 lbl.TextColor3=C.TXT lbl.TextXAlignment=Enum.TextXAlignment.Left
    local sw=Instance.new("Frame",row) sw.Size=UDim2.fromOffset(38,18) sw.Position=UDim2.new(1,-44,0.5,-9)
    sw.BackgroundColor3=Color3.fromRGB(30,40,30) sw.BorderSizePixel=0; addCorner(sw,9)
    local circ=Instance.new("Frame",sw) circ.Size=UDim2.fromOffset(14,14) circ.Position=UDim2.new(0,2,0.5,-7) circ.BackgroundColor3=Color3.new(0,0,0) circ.BorderSizePixel=0; addCorner(circ,7)
    local isOn=false
    local btn=Instance.new("TextButton",row) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.ZIndex=4
    btn.MouseButton1Click:Connect(function()
        isOn=not isOn
        TweenService:Create(sw,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=isOn and C.ACC or Color3.fromRGB(30,40,30)}):Play()
        TweenService:Create(circ,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Position=isOn and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if callback then callback(isOn) end
    end)
end
alToggleRow(34,"Anti Lag",function(on) if on then enableAntiLag() else disableAntiLag() end end)
alToggleRow(70,"Remove Accessories",function(on)
    removeAccActive=on
    if on then
        for _,p in pairs(Players:GetPlayers()) do if p.Character then for _,o in ipairs(p.Character:GetDescendants()) do if o:IsA("Accessory") or o:IsA("Hat") then o:Destroy() end end end end
    end
end)
local alClose=Instance.new("TextButton",alMain) alClose.Size=UDim2.fromOffset(28,28) alClose.Position=UDim2.new(1,-32,0,2)
alClose.BackgroundColor3=C.RED alClose.BorderSizePixel=0 alClose.Text="×" alClose.TextColor3=Color3.new(1,1,1)
alClose.Font=Enum.Font.GothamBold alClose.TextSize=16; addCorner(alClose,8)
local alReopen=Instance.new("TextButton",alGui) alReopen.Size=UDim2.fromOffset(38,38) alReopen.Position=UDim2.new(0,6,0,400)
alReopen.BackgroundColor3=C.ACC alReopen.BorderSizePixel=0 alReopen.Text="AL" alReopen.TextColor3=C.BG
alReopen.Font=Enum.Font.GothamBlack alReopen.TextSize=12 alReopen.Visible=false; addCorner(alReopen,10)
alClose.MouseButton1Click:Connect(function() alMain.Visible=false alReopen.Visible=true end)
alReopen.MouseButton1Click:Connect(function() alMain.Visible=true alReopen.Visible=false end)

-- ============ RIGHT SIDE SQUARE BUTTONS ============
local function makeSideSq(icon,yPos,col,sub)
    local f=Instance.new("Frame",sg)
    f.Size=UDim2.fromOffset(44,44) f.Position=UDim2.new(1,-50,0,yPos)
    f.BackgroundColor3=C.BG f.BackgroundTransparency=TRANS f.BorderSizePixel=0
    addCorner(f,10) local st=addStroke(f,col,1.2,0.2)
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,0.65,0)
    b.BackgroundTransparency=1 b.Text=icon b.Font=Enum.Font.GothamBold b.TextSize=16 b.TextColor3=C.TXT b.BorderSizePixel=0 b.AutoButtonColor=false
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,0,0.35,0) lbl.Position=UDim2.new(0,0,0.65,0)
    lbl.BackgroundTransparency=1 lbl.Text=sub lbl.Font=Enum.Font.GothamBold lbl.TextSize=6 lbl.TextColor3=C.DIM
    return f,b,st
end

-- Panels for side buttons
local carpetPanel=makeSquarePanel(150,10,"🚗 PHANTOM CARPET",C.ACC)
carpetPanel.AutomaticSize=Enum.AutomaticSize.Y
local carpetToggle=makeBtn(carpetPanel,"🚗  START CARPET",1,C.ACC)
carpetToggle.MouseButton1Click:Connect(function()
    carpetActive=not carpetActive
    if carpetActive then carpetToggle.Text="🚗  STOP CARPET" carpetToggle.TextColor3=Color3.fromRGB(80,240,255); startCarpet()
    else carpetToggle.Text="🚗  START CARPET" carpetToggle.TextColor3=C.ACC; stopCarpet() end
end)

-- Carpet Scam panel
local carpetScamPanel=makeSquarePanel(155,10,"🎯 PHANTOM CARPET SCAM",C.ORG)
carpetScamPanel.AutomaticSize=Enum.AutomaticSize.Y
local csNote=Instance.new("TextLabel",carpetScamPanel) csNote.Size=UDim2.new(1,0,0,14) csNote.BackgroundTransparency=1
csNote.Text="Teleports with carpet to scam" csNote.Font=Enum.Font.Gotham csNote.TextSize=8
csNote.TextColor3=C.DIM csNote.LayoutOrder=1
local csGo=makeBtn(carpetScamPanel,"GO  (Carpet Scam TP)",2,C.ORG)
csGo.MouseButton1Click:Connect(function()
    csGo.Text="running..." task.spawn(function()
        local c=lp.Character if not c then csGo.Text="GO  (Carpet Scam TP)" return end
        local hrp=c:FindFirstChild("HumanoidRootPart") local hum=getHum() if not hrp or not hum then csGo.Text="GO  (Carpet Scam TP)" return end
        hrp.CFrame=CFrame.new(POS_CARPET)
        local carpet=equipTool("Carpet") or equipTool("Flying Carpet")
        if carpet then
            local t0=tick() repeat task.wait(0.02) until c:FindFirstChild("Carpet") or c:FindFirstChild("Flying Carpet") or tick()-t0>0.8
            pcall(function() carpet:Activate() end) task.wait(0.15)
        end
        -- block after carpet tp
        if autoBlockTarget then task.spawn(function() task.wait(0.2) blockAndClick(autoBlockTarget) end) end
        task.wait(2) csGo.Text="GO  (Carpet Scam TP)"
    end)
end)

local desyncPanel=makeSquarePanel(155,10,"⚡ PHANTOM DESYNC",C.ACC)
desyncPanel.AutomaticSize=Enum.AutomaticSize.Y
local dpNote=Instance.new("TextLabel",desyncPanel) dpNote.Size=UDim2.new(1,0,0,12) dpNote.BackgroundTransparency=1
dpNote.Text="(reset first before enabling)" dpNote.Font=Enum.Font.Gotham dpNote.TextSize=7
dpNote.TextColor3=Color3.fromRGB(255,200,80) dpNote.LayoutOrder=1
local dpToggle=makeBtn(desyncPanel,"DESYNC: OFF",2,C.DIM)
dpToggle.MouseButton1Click:Connect(function()
    desyncEnabled=not desyncEnabled
    if desyncEnabled then startDesync() dpToggle.Text="DESYNC: ON" dpToggle.TextColor3=C.ACC dpToggle.BackgroundColor3=Color3.fromRGB(0,30,50)
    else stopDesync() dpToggle.Text="DESYNC: OFF" dpToggle.TextColor3=C.DIM dpToggle.BackgroundColor3=C.ITEM end
end)
local dpUnwalk=makeBtn(desyncPanel,"UNWALK",3,C.TXT)
dpUnwalk.MouseButton1Click:Connect(function()
    local c=lp.Character if not c then return end
    local hum=c:FindFirstChildOfClass("Humanoid") local anim=hum and hum:FindFirstChildOfClass("Animator")
    if anim then for _,t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop() end end
    dpUnwalk.Text="WALKED" dpUnwalk.TextColor3=C.ACC dpUnwalk.BackgroundColor3=Color3.fromRGB(0,30,50)
end)
lp.CharacterAdded:Connect(function()
    if dpUnwalk and dpUnwalk.Parent then task.defer(function() dpUnwalk.Text="UNWALK" dpUnwalk.TextColor3=C.TXT dpUnwalk.BackgroundColor3=C.ITEM end) end
    if dpToggle and dpToggle.Parent and not desyncEnabled then task.defer(function() dpToggle.Text="DESYNC: OFF" dpToggle.TextColor3=C.DIM dpToggle.BackgroundColor3=C.ITEM end) end
end)

-- side buttons - moved higher (start at y=40)
local s1f,s1b,s1st=makeSideSq("🚗",40,C.ACC,"CARPET")
local s2f,s2b,s2st=makeSideSq("🎯",86,C.ORG,"C.SCAM")
local s3f,s3b,s3st=makeSideSq("⚡",132,C.ACC,"DESYNC")
local s4f,s4b,s4st=makeSideSq("⚙",178,C.LIME,"ANTILAG")

local function positionNearBtn(panel,btnFrame)
    local bp=btnFrame.AbsolutePosition
    panel.Position=UDim2.new(0,bp.X-panel.AbsoluteSize.X-6,0,bp.Y)
end

local function sideToggle(panel,st2,buildFn,btnFrame)
    panel.Visible=not panel.Visible
    st2.Transparency=panel.Visible and 0 or 0.2
    if panel.Visible then
        if buildFn then buildFn() end
        -- position near button
        local bp=btnFrame.AbsolutePosition
        local pw=panel.AbsoluteSize.X
        panel.Position=UDim2.new(0,bp.X-pw-6,0,bp.Y)
    end
end

s1b.MouseButton1Click:Connect(function() sideToggle(carpetPanel,s1st,nil,s1f) end)
s2b.MouseButton1Click:Connect(function() sideToggle(carpetScamPanel,s2st,nil,s2f) end)
s3b.MouseButton1Click:Connect(function() sideToggle(desyncPanel,s3st,nil,s3f) end)
s4b.MouseButton1Click:Connect(function()
    alMain.Visible=not alMain.Visible alReopen.Visible=not alMain.Visible
    s4st.Transparency=alMain.Visible and 0 or 0.2
end)

-- ============ AP + MINI AP TOGGLE ============
local panelOpen=false
local moved=false local inputStart=nil
local td2,tds2,tsp2=false,nil,nil

toggleBtn.InputBegan:Connect(function(i)
    if uiLocked then return end
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        td2=true tds2=i.Position tsp2=toggleBtn.Position moved=false inputStart=i.Position
    end
end)
toggleBtn.InputChanged:Connect(function(i)
    if uiLocked then return end
    if td2 and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local dl=i.Position-tds2
        toggleBtn.Position=UDim2.new(tsp2.X.Scale,tsp2.X.Offset+dl.X,tsp2.Y.Scale,tsp2.Y.Offset+dl.Y)
        panel.Position=UDim2.new(toggleBtn.Position.X.Scale,toggleBtn.Position.X.Offset+52,toggleBtn.Position.Y.Scale,toggleBtn.Position.Y.Offset)
        miniPanel.Position=UDim2.new(toggleBtn.Position.X.Scale,toggleBtn.Position.X.Offset+216,toggleBtn.Position.Y.Scale,toggleBtn.Position.Y.Offset)
        flashPanel.Position=UDim2.new(toggleBtn.Position.X.Scale,toggleBtn.Position.X.Offset+52,toggleBtn.Position.Y.Scale,toggleBtn.Position.Y.Offset+50)
        if inputStart and (i.Position-inputStart).Magnitude>6 then moved=true end
    end
end)
toggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then td2=false end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if moved then return end
    panelOpen=not panelOpen
    panel.Visible=panelOpen miniPanel.Visible=panelOpen
    toggleBtn.TextColor3=panelOpen and C.ACC or C.DIM
    tStroke.Transparency=panelOpen and 0 or 0.15
    if panelOpen then buildCards() buildMiniCards() end
end)

-- Flash button
local flashOpen=false
local fmoved=false local finputStart=nil
local ftd,ftds,ftsp=false,nil,nil
flashBtn.InputBegan:Connect(function(i)
    if uiLocked then return end
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        ftd=true ftds=i.Position ftsp=flashBtn.Position fmoved=false finputStart=i.Position
    end
end)
flashBtn.InputChanged:Connect(function(i)
    if uiLocked then return end
    if ftd and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local dl=i.Position-ftds
        flashBtn.Position=UDim2.new(ftsp.X.Scale,ftsp.X.Offset+dl.X,ftsp.Y.Scale,ftsp.Y.Offset+dl.Y)
        flashPanel.Position=UDim2.new(flashBtn.Position.X.Scale,flashBtn.Position.X.Offset+52,flashBtn.Position.Y.Scale,flashBtn.Position.Y.Offset)
        if finputStart and (i.Position-finputStart).Magnitude>6 then fmoved=true end
    end
end)
flashBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then ftd=false end
end)
flashBtn.MouseButton1Click:Connect(function()
    if fmoved then return end
    flashOpen=not flashOpen
    flashPanel.Visible=flashOpen
    flashStroke.Transparency=flashOpen and 0 or 0.15
    if flashOpen then
        flashPanel.Position=UDim2.new(flashBtn.Position.X.Scale,flashBtn.Position.X.Offset+52,flashBtn.Position.Y.Scale,flashBtn.Position.Y.Offset)
        buildFPList()
    end
end)

Players.PlayerAdded:Connect(function()
    if panelOpen then buildCards() buildMiniCards() end
    if flashOpen then buildFPList() end
end)
Players.PlayerRemoving:Connect(function(p)
    if _G.PhantomAPTarget==p then _G.PhantomAPTarget=nil end
    if autoBlockTarget==p then autoBlockTarget=nil end
    if panelOpen then buildCards() buildMiniCards() end
    if flashOpen then buildFPList() end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not sg.Parent then break end
        local t=_G.PhantomAPTarget
        if t and t.Parent then
            selLbl.Text=t.DisplayName selLbl.TextColor3=C.ACC
        else selLbl.Text="tap player to select" selLbl.TextColor3=C.DIM end
    end
end)
