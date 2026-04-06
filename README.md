pcall(function() game:GetService("CoreGui"):FindFirstChild("PhantomSuite"):Destroy() end)

local Players          = game:GetService("Players")
local TextChatService  = game:GetService("TextChatService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")
local VIM              = game:GetService("VirtualInputManager")
local UIS              = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local lp               = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local C = {
    BG    = Color3.fromRGB(8,16,24),
    PANEL = Color3.fromRGB(12,22,34),
    ITEM  = Color3.fromRGB(16,30,46),
    ACC   = Color3.fromRGB(0,200,220),
    TXT   = Color3.fromRGB(200,240,255),
    DIM   = Color3.fromRGB(80,140,160),
    RED   = Color3.fromRGB(220,50,50),
    GREEN = Color3.fromRGB(50,220,100),
    ORG   = Color3.fromRGB(255,150,50),
    LIME  = Color3.fromRGB(0,200,0),
}
local TRANS   = 0.18
local uiLocked = false

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

-- ============ AP CORE ============
-- FIX: sequence ends on player button, not cmd button — prevents state carryover
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
                -- click player first
                local pb=getPlayerBtn(ap,target)
                if pb then fireBtn(pb) task.wait(0.08) end
                -- click cmd
                local cb=getBtnByText(ap,cmd)
                if cb then fireBtn(cb) task.wait(0.08) end
                -- click player again at end to reset state (THE FIX)
                local pb2=getPlayerBtn(ap,target)
                if pb2 then fireBtn(pb2) task.wait(0.05) end
            end
            if jail then
                task.wait(1.5)
                local pb=getPlayerBtn(ap,target)
                if pb then fireBtn(pb) task.wait(0.05) end
                local jb=getBtnByText(ap,"jail")
                if jb then fireBtn(jb) task.wait(0.05) end
                -- end on player
                local pb2=getPlayerBtn(ap,target)
                if pb2 then fireBtn(pb2) end
            end
        else
            local n=target.Name
            for _,cmd in ipairs(cmds) do sendCmd(";"..cmd.." "..n) task.wait(0.1) end
            if jail then task.delay(1.5,function() sendCmd(";jail "..n) end) end
        end
    end)
end

-- Mini AP still uses chat directly (no carryover possible)
local function runSingleCmdChat(target,cmd)
    task.spawn(function() sendCmd(";"..cmd.." "..target.Name) end)
end

-- ============ ANTI RAGDOLL (from leaked source - zeroes velocity) ============
RunService.Heartbeat:Connect(function()
    local c=lp.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    local h=c:FindFirstChildOfClass("Humanoid") if not h then return end
    local st=h:GetState()
    if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
        h:ChangeState(Enum.HumanoidStateType.Running)
        Camera.CameraSubject=h
        if hrp then
            hrp.AssemblyLinearVelocity=Vector3.zero
            hrp.AssemblyAngularVelocity=Vector3.zero
        end
    end
    if hrp then
        for _,o in ipairs(c:GetDescendants()) do
            if o:IsA("Motor6D") and not o.Enabled then o.Enabled=true end
        end
    end
end)

-- ============ TIMER ESP ============
local espConn=nil local espInst={}
local function startTimerESP()
    if espConn then espConn:Disconnect() end espInst={}
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
            local pur=plot:FindFirstChild("Purchases") local pb2=pur and pur:FindFirstChild("PlotBlock")
            local mp=pb2 and pb2:FindFirstChild("Main")
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

-- block +75 offset
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

-- manual block: just opens the UI
local function manualBlock(target)
    if not target then return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer",target) end)
end

local function execSteal(prompt)
    local data=stealCache[prompt]
    if not data or not data.ready or isStealing then return end
    data.ready=false isStealing=true stealProgress=0
    -- auto block fires 0.2s before steal, not on proximity
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
    if not best or bd>9 then return end
    local prompt=promptCache[best.uid]
    if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt) if stealCache[prompt] then execSteal(prompt) end
end)

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
    if net then table.insert(carpetConns,RunService.Heartbeat:Connect(function()
        if not carpetActive then return end pcall(function() net:FireServer(0.23450689315795897) end)
    end)) end
end
lp.CharacterAdded:Connect(function() if carpetActive then task.wait(0.5) startCarpet() end end)

-- ============ INSTA RESET (exact source logic) ============
local cachedCraftCFrame=nil local craftMachine=nil
local function updateCraftCache()
    craftMachine=workspace:FindFirstChild("CraftingMachine")
    if craftMachine then
        local part=craftMachine:FindFirstChild("VFX",true)
        if part then part=part:FindFirstChild("Secret",true)
            if part then part=part:FindFirstChild("SoundPart",true)
                if part then cachedCraftCFrame=part.CFrame end
            end
        end
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
        charConn_r:Disconnect()
        Camera.CameraSubject=nil
        task.defer(function()
            local newHum=newChar:WaitForChild("Humanoid",0.5)
            if newHum then Camera.CameraSubject=newHum end
        end)
    end)
    if cachedCraftCFrame then hrp.CFrame=cachedCraftCFrame
    elseif craftMachine then updateCraftCache() if cachedCraftCFrame then hrp.CFrame=cachedCraftCFrame end end
    Players.RespawnTime=0
    hum.Health=0 hum:ChangeState(Enum.HumanoidStateType.Dead) char:BreakJoints()
    task.wait(0.03) pcall(function() lp:LoadCharacter() end)
    task.delay(0.3,function()
        if ResetBtnRef then ResetBtnRef.Text="INSTA RESET" end
        if StatusLblRef then StatusLblRef.Text="ACTIVE" StatusLblRef.TextColor3=C.GREEN end
        resetDebounce=false
    end)
end
UIS.InputBegan:Connect(function(inp,gp) if not gp and inp.KeyCode==Enum.KeyCode.R then doReset() end end)

-- ============ FLASH TP (from 706 source) ============
local POS_CARPET       = Vector3.new(-332,-7,67)
local POS_FLASH_TARGET = Vector3.new(-331.8,-4.7,27.5)
local FLASH_TP_WAYPOINTS = {
    Vector3.new(-357.30,-7.00,113.60), Vector3.new(-381.00,-7.00,-43.50),
    Vector3.new(-412.43,-6.50,102.23), Vector3.new(-411.05,-6.50,54.73),
    Vector3.new(-410.00,-6.50,-14.58), Vector3.new(-377.28,-7.00,14.31),
    Vector3.new(-345.77,-7.00,17.01),  Vector3.new(-332.52,-4.79,18.41),
}
local flashTPCmds={"rocket","inverse","tiny","jumpscare","morph"}

local function equipTool(name)
    local c=lp.Character local bp=lp:FindFirstChild("Backpack")
    if not c or not bp then return nil end
    local t=bp:FindFirstChild(name) or c:FindFirstChild(name)
    if not t then for _,v in pairs(bp:GetChildren()) do if v:IsA("Tool") and v.Name:lower():find(name:lower()) then t=v break end end end
    local hum=getHum() if t and hum then hum:EquipTool(t) end return t
end

local function doFlashTP()
    local c=lp.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") local hum=getHum() if not hrp or not hum then return end
    task.spawn(function()
        -- TP to carpet position
        hrp.CFrame=CFrame.new(POS_CARPET)
        hrp.AssemblyLinearVelocity=Vector3.zero
        local carpet=equipTool("Carpet") or equipTool("Flying Carpet")
        if carpet then
            local t0=tick() repeat task.wait(0.02) until c:FindFirstChild("Carpet") or c:FindFirstChild("Flying Carpet") or tick()-t0>0.8
            pcall(function() carpet:Activate() end) task.wait(0.15)
        end
        local flash=equipTool("Flash") or equipTool("Flash Teleport")
        if not flash then return end
        local t1=tick() repeat task.wait(0.02) until c:FindFirstChild("Flash") or c:FindFirstChild("Flash Teleport") or tick()-t1>1
        hrp.CFrame=CFrame.new(POS_CARPET,Vector3.new(POS_FLASH_TARGET.X,POS_CARPET.Y,POS_FLASH_TARGET.Z))
        local dir=(POS_FLASH_TARGET-POS_CARPET).Unit
        Camera.CameraType=Enum.CameraType.Scriptable
        Camera.CFrame=CFrame.new(POS_CARPET+(-dir*8+Vector3.new(0,4,0)),POS_FLASH_TARGET)
        task.wait(0.06)
        local vp=Camera.ViewportSize
        VIM:SendMouseButtonEvent(math.floor(vp.X/2),math.floor(vp.Y/2),0,true,game,1) task.wait(0.05)
        VIM:SendMouseButtonEvent(math.floor(vp.X/2),math.floor(vp.Y/2),0,false,game,1)
        Camera.CameraType=Enum.CameraType.Custom
        task.wait(0.15)
        -- AP cmds after TP
        local target=_G.PhantomAPTarget
        if not target then
            local h2=getRoot() if h2 then
                local nearest,dist=nil,math.huge
                for _,p in pairs(Players:GetPlayers()) do
                    if p~=lp and p.Character then
                        local r=p.Character:FindFirstChild("HumanoidRootPart")
                        if r then local d=(h2.Position-r.Position).Magnitude if d<dist then dist=d nearest=p end end
                    end
                end
                target=nearest
            end
        end
        if target then runCmds(target,flashTPCmds,true) end
        -- block after TP
        task.wait(0.3)
        if autoBlockTarget then task.spawn(function() blockAndClick(autoBlockTarget) end) end
    end)
end

-- Balloon reset detection
local function watchBalloon(char)
    task.spawn(function()
        local head=char:WaitForChild("Head",5) if not head then return end
        local origY=head.Size.Y
        head:GetPropertyChangedSignal("Size"):Connect(function()
            if head.Size.Y>origY*1.8 then
                task.spawn(doReset)
                local conn; conn=lp.CharacterAdded:Connect(function()
                    conn:Disconnect() task.wait(0.6) task.spawn(doFlashTP)
                end)
            end
        end)
    end)
end
lp.CharacterAdded:Connect(watchBalloon)
if lp.Character then watchBalloon(lp.Character) end

-- ============ CARPET SCAM (from 706 fast teleport) ============
local function doCarpetScam()
    local c=lp.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") local hum=getHum() if not hrp or not hum then return end
    task.spawn(function()
        -- fast TP through waypoints (copied from 706)
        for _,wp in ipairs(FLASH_TP_WAYPOINTS) do
            hrp.CFrame=CFrame.new(wp)
            hrp.AssemblyLinearVelocity=Vector3.zero
            task.wait(0.01)
        end
        -- end at carpet position
        hrp.CFrame=CFrame.new(POS_CARPET)
        hrp.AssemblyLinearVelocity=Vector3.zero
        local carpet=equipTool("Carpet") or equipTool("Flying Carpet")
        if carpet then
            local t0=tick() repeat task.wait(0.02) until c:FindFirstChild("Carpet") or c:FindFirstChild("Flying Carpet") or tick()-t0>0.8
            pcall(function() carpet:Activate() end)
        end
        -- block nearest after scam tp
        task.wait(0.2)
        if autoBlockTarget then task.spawn(function() blockAndClick(autoBlockTarget) end) end
    end)
end

-- ============ ANTI LAG ============
local antiLagActive=false local alDescConn=nil
local function processDesc(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") then obj.Enabled=false end
        if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1 end
        if obj:IsA("BasePart") then obj.Material=Enum.Material.Plastic obj.Reflectance=0 obj.CastShadow=false end
    end)
end
local function enableAntiLag()
    if antiLagActive then return end antiLagActive=true
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    Lighting.GlobalShadows=false Lighting.FogEnd=9e9 Lighting.Brightness=1
    Lighting.EnvironmentDiffuseScale=0 Lighting.EnvironmentSpecularScale=0
    for _,e in pairs(Lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end
    end
    for _,obj in pairs(workspace:GetDescendants()) do processDesc(obj) end
    alDescConn=workspace.DescendantAdded:Connect(function(obj) processDesc(obj) end)
end
local function disableAntiLag()
    antiLagActive=false if alDescConn then alDescConn:Disconnect() alDescConn=nil end
end

-- ============ SCREEN GUI ============
local sg=Instance.new("ScreenGui")
sg.Name="PhantomSuite" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999
sg.Parent=game:GetService("CoreGui")

-- ============ GRAB PROGRESS BAR ============
local grabBar=Instance.new("Frame",sg)
grabBar.Size=UDim2.fromOffset(150,18) grabBar.AnchorPoint=Vector2.new(0.5,0)
grabBar.Position=UDim2.new(0.5,0,0,6) grabBar.BackgroundColor3=C.BG
grabBar.BackgroundTransparency=0.1 grabBar.BorderSizePixel=0 grabBar.ZIndex=60
addCorner(grabBar,7) addStroke(grabBar,C.ACC,1.2,0.15)
local gFill=Instance.new("Frame",grabBar) gFill.Size=UDim2.new(0,0,1,0)
gFill.BackgroundColor3=C.ACC gFill.BorderSizePixel=0 addCorner(gFill,7)
local gTxt=Instance.new("TextLabel",grabBar) gTxt.Size=UDim2.new(1,0,1,0)
gTxt.BackgroundTransparency=1 gTxt.Text="GRAB" gTxt.Font=Enum.Font.GothamBold gTxt.TextSize=9
gTxt.TextColor3=Color3.new(1,1,1) gTxt.ZIndex=61

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

-- ============ LOCK UI BUTTON ============
local lockBtn=Instance.new("TextButton",sg)
lockBtn.Size=UDim2.fromOffset(72,22) lockBtn.Position=UDim2.new(1,-76,0,2)
lockBtn.BackgroundColor3=C.BG lockBtn.BackgroundTransparency=0.1
lockBtn.Text="🔓 UNLOCK" lockBtn.Font=Enum.Font.GothamBold
lockBtn.TextSize=8 lockBtn.TextColor3=C.DIM lockBtn.BorderSizePixel=0 lockBtn.ZIndex=200
addCorner(lockBtn,5) addStroke(lockBtn,C.DIM,1,0.4)
lockBtn.MouseButton1Click:Connect(function()
    uiLocked=not uiLocked
    lockBtn.Text=uiLocked and "🔒 LOCKED" or "🔓 UNLOCK"
    lockBtn.TextColor3=uiLocked and C.RED or C.DIM
    local st=lockBtn:FindFirstChildOfClass("UIStroke")
    if st then st.Color=uiLocked and C.RED or C.DIM end
end)

-- ============ PANEL BUILDER ============
local function makePanel(w,title,accentCol)
    local f=Instance.new("Frame",sg)
    f.Size=UDim2.fromOffset(w,10) f.BackgroundColor3=C.BG
    f.BackgroundTransparency=TRANS f.BorderSizePixel=0 f.AutomaticSize=Enum.AutomaticSize.Y f.Visible=false f.Active=true
    addCorner(f,12) addStroke(f,accentCol or C.ACC,1.5,0.1) makeDrag(f)
    local layout=Instance.new("UIListLayout",f) layout.Padding=UDim.new(0,4)
    layout.HorizontalAlignment=Enum.HorizontalAlignment.Center layout.SortOrder=Enum.SortOrder.LayoutOrder
    local pad=Instance.new("UIPadding",f)
    pad.PaddingTop=UDim.new(0,6) pad.PaddingBottom=UDim.new(0,8) pad.PaddingLeft=UDim.new(0,6) pad.PaddingRight=UDim.new(0,6)
    local hdr=Instance.new("TextLabel",f) hdr.Size=UDim2.new(1,0,0,16) hdr.BackgroundTransparency=1
    hdr.Text=title hdr.Font=Enum.Font.GothamBlack hdr.TextSize=10 hdr.TextColor3=accentCol or C.ACC hdr.LayoutOrder=0
    local dv=Instance.new("Frame",f) dv.Size=UDim2.new(1,0,0,1)
    dv.BackgroundColor3=accentCol or C.ACC dv.BackgroundTransparency=0.5 dv.BorderSizePixel=0 dv.LayoutOrder=1
    return f
end
local function makeBtn(parent,text,order,col)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,0,0,28) btn.BackgroundColor3=C.ITEM btn.BackgroundTransparency=0.15
    btn.Text=text btn.Font=Enum.Font.GothamBold btn.TextSize=11 btn.TextColor3=col or C.TXT
    btn.BorderSizePixel=0 btn.AutoButtonColor=false btn.LayoutOrder=order
    addCorner(btn,7) addStroke(btn,col or C.ACC,1,0.4)
    return btn
end

-- ============ AP TOGGLE (square button) ============
_G.PhantomAPTarget=nil

local toggleBtn=Instance.new("TextButton",sg)
toggleBtn.Size=UDim2.fromOffset(44,44) toggleBtn.Position=UDim2.new(0,6,0,30)
toggleBtn.BackgroundColor3=C.BG toggleBtn.BackgroundTransparency=TRANS
toggleBtn.Text="AP" toggleBtn.Font=Enum.Font.GothamBlack toggleBtn.TextSize=12
toggleBtn.TextColor3=C.ACC toggleBtn.BorderSizePixel=0
addCorner(toggleBtn,10) local tStroke=addStroke(toggleBtn,C.ACC,1.5,0.15)

-- FLASH button (below AP)
local flashBtn=Instance.new("TextButton",sg)
flashBtn.Size=UDim2.fromOffset(44,44) flashBtn.Position=UDim2.new(0,6,0,80)
flashBtn.BackgroundColor3=C.BG flashBtn.BackgroundTransparency=TRANS
flashBtn.Text="⚡" flashBtn.Font=Enum.Font.GothamBlack flashBtn.TextSize=18
flashBtn.TextColor3=C.ORG flashBtn.BorderSizePixel=0
addCorner(flashBtn,10) local flashStroke=addStroke(flashBtn,C.ORG,1.5,0.15)
local fsubLbl=Instance.new("TextLabel",flashBtn) fsubLbl.Size=UDim2.new(1,0,0.3,0)
fsubLbl.Position=UDim2.new(0,0,0.7,0) fsubLbl.BackgroundTransparency=1 fsubLbl.Text="FLASH"
fsubLbl.Font=Enum.Font.GothamBold fsubLbl.TextSize=6 fsubLbl.TextColor3=C.DIM

-- ============ MAIN AP PANEL (original) ============
local panel=Instance.new("Frame",sg)
panel.Size=UDim2.fromOffset(155,10) panel.Position=UDim2.new(0,58,0,30)
panel.BackgroundColor3=C.BG panel.BackgroundTransparency=TRANS
panel.BorderSizePixel=0 panel.AutomaticSize=Enum.AutomaticSize.Y panel.Visible=false
addCorner(panel,12) addStroke(panel,C.ACC,1.5,0.1) makeDrag(panel)

local pLayout=Instance.new("UIListLayout",panel) pLayout.Padding=UDim.new(0,4)
pLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center pLayout.SortOrder=Enum.SortOrder.LayoutOrder
local pPad=Instance.new("UIPadding",panel)
pPad.PaddingTop=UDim.new(0,6) pPad.PaddingBottom=UDim.new(0,8) pPad.PaddingLeft=UDim.new(0,6) pPad.PaddingRight=UDim.new(0,6)

local hdrLbl=Instance.new("TextLabel",panel) hdrLbl.Size=UDim2.new(1,0,0,18)
hdrLbl.BackgroundTransparency=1 hdrLbl.Text="PHANTOM AP" hdrLbl.Font=Enum.Font.GothamBlack
hdrLbl.TextSize=11 hdrLbl.TextColor3=C.ACC hdrLbl.LayoutOrder=0

local function mkDiv(order)
    local dv=Instance.new("Frame",panel) dv.Size=UDim2.new(1,0,0,1)
    dv.BackgroundColor3=C.ACC dv.BackgroundTransparency=0.5 dv.BorderSizePixel=0 dv.LayoutOrder=order
end
mkDiv(1)

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
        local av=Instance.new("ImageLabel",card) av.Size=UDim2.fromOffset(28,28) av.Position=UDim2.new(0,4,0.5,-14)
        av.BackgroundColor3=C.PANEL av.BorderSizePixel=0
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        addCorner(av,14)
        local nl=Instance.new("TextLabel",card) nl.Size=UDim2.new(1,-38,0,16) nl.Position=UDim2.new(0,36,0,4)
        nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=10 nl.TextColor3=C.TXT
        nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",card) ul.Size=UDim2.new(1,-38,0,12) ul.Position=UDim2.new(0,36,0,20)
        ul.BackgroundTransparency=1 ul.Text="@"..p.Name ul.Font=Enum.Font.Gotham ul.TextSize=8 ul.TextColor3=C.DIM
        ul.TextXAlignment=Enum.TextXAlignment.Left ul.TextTruncate=Enum.TextTruncate.AtEnd
        local cb=Instance.new("TextButton",card) cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text="" cb.ZIndex=5
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

mkDiv(3)
local selLbl=Instance.new("TextLabel",panel) selLbl.Size=UDim2.new(1,0,0,12) selLbl.BackgroundTransparency=1
selLbl.Text="tap player to select" selLbl.Font=Enum.Font.Gotham selLbl.TextSize=8 selLbl.TextColor3=C.DIM selLbl.LayoutOrder=4
mkDiv(5)

local function getTarget()
    local t=_G.PhantomAPTarget if t and t.Parent then return t end
    local nearest,dist=nil,math.huge
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then for _,p in pairs(Players:GetPlayers()) do if p~=lp and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then local dd=(r.Position-hrp.Position).Magnitude if dd<dist then dist=dd nearest=p end end
    end end end
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
mkCmd("RAGDOLL",6,{"ragdoll"},false)
mkCmd("ALL",7,{"rocket","inverse","tiny","jumpscare","morph","balloon"},true)

-- ============ MINI AP PANEL ============
local miniPanel=Instance.new("Frame",sg)
miniPanel.Size=UDim2.fromOffset(218,10) miniPanel.Position=UDim2.new(0,222,0,30)
miniPanel.BackgroundColor3=C.BG miniPanel.BackgroundTransparency=TRANS
miniPanel.BorderSizePixel=0 miniPanel.AutomaticSize=Enum.AutomaticSize.Y miniPanel.Visible=false
addCorner(miniPanel,12) addStroke(miniPanel,C.ACC,1.5,0.1) makeDrag(miniPanel)

local mpLayout=Instance.new("UIListLayout",miniPanel) mpLayout.Padding=UDim.new(0,3)
mpLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center mpLayout.SortOrder=Enum.SortOrder.LayoutOrder
local mpPad=Instance.new("UIPadding",miniPanel)
mpPad.PaddingTop=UDim.new(0,6) mpPad.PaddingBottom=UDim.new(0,8) mpPad.PaddingLeft=UDim.new(0,5) mpPad.PaddingRight=UDim.new(0,5)
local mHdr=Instance.new("TextLabel",miniPanel) mHdr.Size=UDim2.new(1,0,0,16) mHdr.BackgroundTransparency=1
mHdr.Text="PHANTOM MINI AP" mHdr.Font=Enum.Font.GothamBlack mHdr.TextSize=10 mHdr.TextColor3=C.ACC mHdr.LayoutOrder=0
local mDiv2=Instance.new("Frame",miniPanel) mDiv2.Size=UDim2.new(1,0,0,1)
mDiv2.BackgroundColor3=C.ACC mDiv2.BackgroundTransparency=0.5 mDiv2.BorderSizePixel=0 mDiv2.LayoutOrder=1
local miniScroll=Instance.new("ScrollingFrame",miniPanel)
miniScroll.Size=UDim2.new(1,-4,0,200) miniScroll.BackgroundTransparency=1 miniScroll.BorderSizePixel=0
miniScroll.ScrollBarThickness=2 miniScroll.ScrollBarImageColor3=C.ACC
miniScroll.CanvasSize=UDim2.new(0,0,0,0) miniScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y miniScroll.LayoutOrder=2
local msLayout=Instance.new("UIListLayout",miniScroll) msLayout.Padding=UDim.new(0,3) msLayout.SortOrder=Enum.SortOrder.LayoutOrder

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
        row.Size=UDim2.new(1,-2,0,30) row.BackgroundColor3=C.ITEM row.BackgroundTransparency=0.2
        row.BorderSizePixel=0 row.LayoutOrder=i addCorner(row,7) addStroke(row,Color3.fromRGB(0,60,80),1,0.5)
        local av=Instance.new("ImageLabel",row) av.Size=UDim2.fromOffset(22,22) av.Position=UDim2.new(0,3,0.5,-11)
        av.BackgroundColor3=C.PANEL av.BorderSizePixel=0
        av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        addCorner(av,11)
        local nl=Instance.new("TextLabel",row) nl.Size=UDim2.new(0,42,0,13) nl.Position=UDim2.new(0,27,0,3)
        nl.BackgroundTransparency=1 nl.Text=p.DisplayName nl.Font=Enum.Font.GothamBold nl.TextSize=8 nl.TextColor3=C.TXT
        nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local ul=Instance.new("TextLabel",row) ul.Size=UDim2.new(0,42,0,10) ul.Position=UDim2.new(0,27,0,16)
        ul.BackgroundTransparency=1 ul.Text="@"..p.Name ul.Font=Enum.Font.Gotham ul.TextSize=7 ul.TextColor3=C.DIM
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
                runSingleCmdChat(captP,captK)
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
local flashPanel=makePanel(165,"⚡ PHANTOM FLASH",C.ORG)
local fpGo=makeBtn(flashPanel,"⚡  FLASH TP + BLOCK",2,C.ORG)
fpGo.MouseButton1Click:Connect(function()
    fpGo.Text="running..." fpGo.TextColor3=Color3.fromRGB(255,200,80)
    task.spawn(doFlashTP)
    task.delay(3,function() if fpGo.Parent then fpGo.Text="⚡  FLASH TP + BLOCK" fpGo.TextColor3=C.ORG end end)
end)

-- auto block toggle
local abRow=Instance.new("Frame",flashPanel) abRow.Size=UDim2.new(1,0,0,26) abRow.BackgroundColor3=C.ITEM
abRow.BackgroundTransparency=0.2 abRow.BorderSizePixel=0 abRow.LayoutOrder=3
addCorner(abRow,7) addStroke(abRow,C.ORG,1,0.4)
local abL=Instance.new("TextLabel",abRow) abL.Size=UDim2.new(1,-50,1,0) abL.Position=UDim2.new(0,8,0,0)
abL.BackgroundTransparency=1 abL.Text="Auto Block" abL.Font=Enum.Font.GothamBold abL.TextSize=9 abL.TextColor3=C.TXT abL.TextXAlignment=Enum.TextXAlignment.Left
local abTog=Instance.new("TextButton",abRow) abTog.Size=UDim2.fromOffset(40,18) abTog.Position=UDim2.new(1,-44,0.5,-9)
abTog.BackgroundColor3=C.ITEM abTog.BackgroundTransparency=0.1 abTog.Text="OFF"
abTog.Font=Enum.Font.GothamBold abTog.TextSize=8 abTog.TextColor3=C.DIM abTog.BorderSizePixel=0 abTog.AutoButtonColor=false
addCorner(abTog,5)
abTog.MouseButton1Click:Connect(function()
    autoBlockEnabled=not autoBlockEnabled
    if autoBlockEnabled then abTog.Text="ON" abTog.BackgroundColor3=C.ACC abTog.TextColor3=Color3.new(0,0,0)
        if _G.PhantomAPTarget then autoBlockTarget=_G.PhantomAPTarget end
    else abTog.Text="OFF" abTog.BackgroundColor3=C.ITEM abTog.TextColor3=C.DIM end
end)

local fpLbl2=Instance.new("TextLabel",flashPanel) fpLbl2.Size=UDim2.new(1,0,0,10) fpLbl2.BackgroundTransparency=1
fpLbl2.Text="tap player → BLOCK opens:" fpLbl2.Font=Enum.Font.Gotham fpLbl2.TextSize=7 fpLbl2.TextColor3=C.DIM fpLbl2.LayoutOrder=4

local fpScroll=Instance.new("ScrollingFrame",flashPanel)
fpScroll.Size=UDim2.new(1,-4,0,90) fpScroll.BackgroundTransparency=1 fpScroll.BorderSizePixel=0
fpScroll.ScrollBarThickness=2 fpScroll.ScrollBarImageColor3=C.ORG
fpScroll.CanvasSize=UDim2.new(0,0,0,0) fpScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y fpScroll.LayoutOrder=5
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
        nl.Size=UDim2.new(1,-54,1,0) nl.Position=UDim2.new(0,6,0,0) nl.BackgroundTransparency=1
        nl.Text=p.DisplayName.."  @"..p.Name nl.Font=Enum.Font.GothamBold nl.TextSize=8 nl.TextColor3=C.TXT
        nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
        local blk=Instance.new("TextButton",row)
        blk.Size=UDim2.fromOffset(48,18) blk.Position=UDim2.new(1,-52,0.5,-9)
        blk.BackgroundColor3=C.ITEM blk.BackgroundTransparency=0.1 blk.Text="BLOCK"
        blk.Font=Enum.Font.GothamBold blk.TextSize=8 blk.TextColor3=C.DIM
        blk.BorderSizePixel=0 blk.AutoButtonColor=false
        addCorner(blk,5) addStroke(blk,C.ORG,1,0.7)
        local cap=p
        -- clicking row selects player
        local rowBtn=Instance.new("TextButton",row) rowBtn.Size=UDim2.new(1,-56,1,0) rowBtn.BackgroundTransparency=1 rowBtn.Text="" rowBtn.ZIndex=3
        rowBtn.MouseButton1Click:Connect(function()
            if selectedFPRef and selectedFPRef.Parent then
                selectedFPRef.BackgroundColor3=C.ITEM
                local ss=selectedFPRef:FindFirstChildOfClass("UIStroke") if ss then ss.Transparency=0.6 end
            end
            autoBlockTarget=cap _G.PhantomAPTarget=cap selectedFPRef=row
            row.BackgroundColor3=Color3.fromRGB(40,25,10)
            local ss=row:FindFirstChildOfClass("UIStroke") if ss then ss.Transparency=0 end
            blk.TextColor3=C.ORG
            local ss2=blk:FindFirstChildOfClass("UIStroke") if ss2 then ss2.Transparency=0.2 end
        end)
        -- clicking BLOCK just opens the UI (no auto click)
        blk.MouseButton1Click:Connect(function()
            manualBlock(cap)
        end)
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.5) buildFPList() end)
Players.PlayerRemoving:Connect(function(p)
    if autoBlockTarget==p then autoBlockTarget=nil end
    if _G.PhantomAPTarget==p then _G.PhantomAPTarget=nil end
    task.wait(0.3) buildFPList()
end)

-- ============ PHANTOM RESET GUI (clean cyan phantom style) ============
local resetGui=Instance.new("ScreenGui")
resetGui.Name="PhantomReset" resetGui.ResetOnSpawn=false resetGui.DisplayOrder=998
resetGui.Parent=game:GetService("CoreGui")

local rm=Instance.new("Frame",resetGui)
rm.Size=UDim2.fromOffset(200,120) rm.Position=UDim2.new(0.5,-100,1,-160)
rm.BackgroundColor3=C.BG rm.BackgroundTransparency=0.1 rm.BorderSizePixel=0
rm.Active=true rm.Draggable=true
addCorner(rm,14) addStroke(rm,C.ACC,1.5,0.1)
-- animated border glow
task.spawn(function()
    local st2=rm:FindFirstChildOfClass("UIStroke")
    if not st2 then return end
    while rm and rm.Parent do
        TweenService:Create(st2,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.55}):Play()
        task.wait(1.2)
        TweenService:Create(st2,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0}):Play()
        task.wait(1.2)
    end
end)

local rmHeader=Instance.new("Frame",rm) rmHeader.Size=UDim2.new(1,0,0,26) rmHeader.BackgroundColor3=C.PANEL
rmHeader.BackgroundTransparency=0.1 rmHeader.BorderSizePixel=0 addCorner(rmHeader,14)
local rmFix=Instance.new("Frame",rmHeader) rmFix.Size=UDim2.new(1,0,0.5,0) rmFix.Position=UDim2.new(0,0,0.5,0)
rmFix.BackgroundColor3=C.PANEL rmFix.BackgroundTransparency=0.1 rmFix.BorderSizePixel=0
local rmTitle=Instance.new("TextLabel",rmHeader) rmTitle.Size=UDim2.new(1,-4,1,0) rmTitle.Position=UDim2.new(0,8,0,0)
rmTitle.BackgroundTransparency=1 rmTitle.Text="PHANTOM RESET" rmTitle.Font=Enum.Font.GothamBlack
rmTitle.TextSize=11 rmTitle.TextColor3=C.ACC rmTitle.TextXAlignment=Enum.TextXAlignment.Left

local rmClose=Instance.new("TextButton",rmHeader) rmClose.Size=UDim2.fromOffset(20,20) rmClose.Position=UDim2.new(1,-24,0.5,-10)
rmClose.BackgroundColor3=C.RED rmClose.BorderSizePixel=0 rmClose.Text="×" rmClose.TextColor3=Color3.new(1,1,1)
rmClose.Font=Enum.Font.GothamBold rmClose.TextSize=14 addCorner(rmClose,6)
rmClose.MouseButton1Click:Connect(function() rm.Visible=false end)

local rmBtnFrame=Instance.new("Frame",rm) rmBtnFrame.Size=UDim2.new(1,-12,0,34) rmBtnFrame.Position=UDim2.new(0,6,0,32)
rmBtnFrame.BackgroundColor3=C.ITEM rmBtnFrame.BackgroundTransparency=0.1 rmBtnFrame.BorderSizePixel=0
addCorner(rmBtnFrame,9) addStroke(rmBtnFrame,C.ACC,1,0.4)

local rmBtn=Instance.new("TextButton",rmBtnFrame) rmBtn.Size=UDim2.new(1,-4,1,-4) rmBtn.Position=UDim2.new(0,2,0,2)
rmBtn.Text="INSTA RESET" rmBtn.BackgroundColor3=C.BG rmBtn.BackgroundTransparency=0.3
rmBtn.Font=Enum.Font.GothamBold rmBtn.TextSize=12 rmBtn.TextColor3=C.ACC rmBtn.BorderSizePixel=0
addCorner(rmBtn,7)
ResetBtnRef=rmBtn

local rmStatus=Instance.new("Frame",rm) rmStatus.Size=UDim2.new(1,-12,0,24) rmStatus.Position=UDim2.new(0,6,0,72)
rmStatus.BackgroundColor3=C.ITEM rmStatus.BackgroundTransparency=0.15 rmStatus.BorderSizePixel=0
addCorner(rmStatus,8) addStroke(rmStatus,C.ACC,1,0.5)
local rmSLbl=Instance.new("TextLabel",rmStatus) rmSLbl.Size=UDim2.new(0.6,0,1,0) rmSLbl.BackgroundTransparency=1
rmSLbl.Text="ACTIVE" rmSLbl.Font=Enum.Font.GothamBold rmSLbl.TextSize=10
rmSLbl.TextColor3=C.GREEN rmSLbl.TextXAlignment=Enum.TextXAlignment.Center
StatusLblRef=rmSLbl
local rmKeyLbl=Instance.new("TextLabel",rmStatus) rmKeyLbl.Size=UDim2.new(0.4,0,1,0) rmKeyLbl.Position=UDim2.new(0.6,0,0,0)
rmKeyLbl.BackgroundTransparency=1 rmKeyLbl.Text="[R] hotkey" rmKeyLbl.Font=Enum.Font.Gotham
rmKeyLbl.TextSize=8 rmKeyLbl.TextColor3=C.DIM rmKeyLbl.TextXAlignment=Enum.TextXAlignment.Center
rmBtn.MouseButton1Click:Connect(doReset)

local rmReopen=Instance.new("TextButton",resetGui) rmReopen.Size=UDim2.fromOffset(44,22)
rmReopen.Position=UDim2.new(0.5,-22,1,-30) rmReopen.BackgroundColor3=C.ACC rmReopen.BorderSizePixel=0
rmReopen.Text="RESET" rmReopen.Font=Enum.Font.GothamBlack rmReopen.TextSize=9 rmReopen.TextColor3=C.BG
rmReopen.Visible=false addCorner(rmReopen,8)
rmClose.MouseButton1Click:Connect(function() rm.Visible=false rmReopen.Visible=true end)
rmReopen.MouseButton1Click:Connect(function() rm.Visible=true rmReopen.Visible=false end)

-- ============ PHANTOM ANTI LAG GUI ============
local alGui=Instance.new("ScreenGui")
alGui.Name="PhantomAntiLag" alGui.ResetOnSpawn=false alGui.DisplayOrder=997
alGui.Parent=game:GetService("CoreGui")

local alMain=Instance.new("Frame",alGui)
alMain.Size=UDim2.fromOffset(200,110) alMain.Position=UDim2.new(1,-210,0.5,-55)
alMain.BackgroundColor3=C.BG alMain.BackgroundTransparency=0.1 alMain.BorderSizePixel=0 alMain.Active=true
addCorner(alMain,12) addStroke(alMain,C.LIME,1.5,0.1)

local function makeDragSimple(f)
    local dg,dgs,dsp=false,nil,nil
    f.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true dgs=i.Position dsp=f.Position
        end
    end)
    f.InputChanged:Connect(function(i)
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dgs f.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y)
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end
    end)
end
makeDragSimple(alMain)

local alHdr=Instance.new("Frame",alMain) alHdr.Size=UDim2.new(1,0,0,26) alHdr.BackgroundColor3=C.PANEL
alHdr.BackgroundTransparency=0.1 alHdr.BorderSizePixel=0 addCorner(alHdr,12)
local alHdrFix=Instance.new("Frame",alHdr) alHdrFix.Size=UDim2.new(1,0,0.5,0) alHdrFix.Position=UDim2.new(0,0,0.5,0)
alHdrFix.BackgroundColor3=C.PANEL alHdrFix.BackgroundTransparency=0.1 alHdrFix.BorderSizePixel=0
local alTitleLbl=Instance.new("TextLabel",alHdr) alTitleLbl.Size=UDim2.new(1,-4,1,0) alTitleLbl.Position=UDim2.new(0,8,0,0)
alTitleLbl.BackgroundTransparency=1 alTitleLbl.Text="⚙ PHANTOM ANTI LAG"
alTitleLbl.Font=Enum.Font.GothamBlack alTitleLbl.TextSize=10 alTitleLbl.TextColor3=C.LIME alTitleLbl.TextXAlignment=Enum.TextXAlignment.Left
local alCloseBtn=Instance.new("TextButton",alHdr) alCloseBtn.Size=UDim2.fromOffset(20,20) alCloseBtn.Position=UDim2.new(1,-24,0.5,-10)
alCloseBtn.BackgroundColor3=C.RED alCloseBtn.BorderSizePixel=0 alCloseBtn.Text="×" alCloseBtn.TextColor3=Color3.new(1,1,1)
alCloseBtn.Font=Enum.Font.GothamBold alCloseBtn.TextSize=14 addCorner(alCloseBtn,6)

local function alToggleRow(yPos,label,callback)
    local row=Instance.new("Frame",alMain) row.Size=UDim2.new(1,-12,0,30) row.Position=UDim2.new(0,6,0,yPos)
    row.BackgroundColor3=C.ITEM row.BackgroundTransparency=0.2 row.BorderSizePixel=0
    addCorner(row,7) addStroke(row,C.LIME,1,0.5)
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(1,-56,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.Font=Enum.Font.GothamBold lbl.TextSize=10 lbl.TextColor3=C.TXT lbl.TextXAlignment=Enum.TextXAlignment.Left
    local sw=Instance.new("Frame",row) sw.Size=UDim2.fromOffset(38,18) sw.Position=UDim2.new(1,-44,0.5,-9)
    sw.BackgroundColor3=Color3.fromRGB(20,40,20) sw.BorderSizePixel=0 addCorner(sw,9)
    local circ=Instance.new("Frame",sw) circ.Size=UDim2.fromOffset(14,14) circ.Position=UDim2.new(0,2,0.5,-7)
    circ.BackgroundColor3=Color3.new(0,0,0) circ.BorderSizePixel=0 addCorner(circ,7)
    local isOn=false
    local btn=Instance.new("TextButton",row) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.ZIndex=4
    btn.MouseButton1Click:Connect(function()
        isOn=not isOn
        TweenService:Create(sw,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{BackgroundColor3=isOn and C.LIME or Color3.fromRGB(20,40,20)}):Play()
        TweenService:Create(circ,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Position=isOn and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if callback then callback(isOn) end
    end)
end
alToggleRow(32,"Anti Lag",function(on) if on then enableAntiLag() else disableAntiLag() end end)
alToggleRow(68,"Remove Accessories",function(on)
    if on then
        for _,p in pairs(Players:GetPlayers()) do if p.Character then for _,o in ipairs(p.Character:GetDescendants()) do if o:IsA("Accessory") or o:IsA("Hat") then o:Destroy() end end end end
        workspace.DescendantAdded:Connect(function(o) if on and (o:IsA("Accessory") or o:IsA("Hat")) then o:Destroy() end end)
    end
end)

local alReopenBtn=Instance.new("TextButton",alGui) alReopenBtn.Size=UDim2.fromOffset(40,40)
alReopenBtn.Position=UDim2.new(1,-46,0.5,-20) alReopenBtn.BackgroundColor3=C.LIME alReopenBtn.BorderSizePixel=0
alReopenBtn.Text="AL" alReopenBtn.Font=Enum.Font.GothamBlack alReopenBtn.TextSize=12 alReopenBtn.TextColor3=C.BG
alReopenBtn.Visible=false addCorner(alReopenBtn,10)
alCloseBtn.MouseButton1Click:Connect(function() alMain.Visible=false alReopenBtn.Visible=true end)
alReopenBtn.MouseButton1Click:Connect(function() alMain.Visible=true alReopenBtn.Visible=false end)

-- ============ RIGHT SIDE SQUARE BUTTONS ============
local function makeSideSq(icon,yPos,col,sub)
    local f=Instance.new("Frame",sg) f.Size=UDim2.fromOffset(44,44) f.Position=UDim2.new(1,-50,0,yPos)
    f.BackgroundColor3=C.BG f.BackgroundTransparency=TRANS f.BorderSizePixel=0
    addCorner(f,10) local st=addStroke(f,col,1.2,0.2)
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,0.65,0) b.BackgroundTransparency=1
    b.Text=icon b.Font=Enum.Font.GothamBold b.TextSize=16 b.TextColor3=C.TXT b.BorderSizePixel=0 b.AutoButtonColor=false
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,0,0.35,0) lbl.Position=UDim2.new(0,0,0.65,0)
    lbl.BackgroundTransparency=1 lbl.Text=sub lbl.Font=Enum.Font.GothamBold lbl.TextSize=6 lbl.TextColor3=C.DIM
    return f,b,st
end

-- Carpet panel
local carpetPanel=makePanel(150,"🚗 PHANTOM CARPET",C.ACC)
local carpetToggle=makeBtn(carpetPanel,"🚗  START CARPET",2,C.ACC)
carpetToggle.MouseButton1Click:Connect(function()
    carpetActive=not carpetActive
    if carpetActive then carpetToggle.Text="🚗  STOP CARPET" carpetToggle.TextColor3=Color3.fromRGB(80,240,255) startCarpet()
    else carpetToggle.Text="🚗  START CARPET" carpetToggle.TextColor3=C.ACC stopCarpet() end
end)

-- Carpet Scam panel
local carpetScamPanel=makePanel(158,"🎯 PHANTOM CARPET SCAM",C.ORG)
local csNote2=Instance.new("TextLabel",carpetScamPanel) csNote2.Size=UDim2.new(1,0,0,12) csNote2.BackgroundTransparency=1
csNote2.Text="Fast TP via waypoints (706 method)" csNote2.Font=Enum.Font.Gotham csNote2.TextSize=7
csNote2.TextColor3=C.DIM csNote2.LayoutOrder=2
local csGo=makeBtn(carpetScamPanel,"GO  (Carpet Scam TP)",3,C.ORG)
csGo.MouseButton1Click:Connect(function()
    csGo.Text="running..."
    task.spawn(doCarpetScam)
    task.delay(3,function() if csGo.Parent then csGo.Text="GO  (Carpet Scam TP)" end end)
end)

local s1f,s1b,s1st=makeSideSq("🚗",40,C.ACC,"CARPET")
local s2f,s2b,s2st=makeSideSq("🎯",86,C.ORG,"C.SCAM")
local s3f,s3b,s3st=makeSideSq("⚙",132,C.LIME,"ANTILAG")

local function openNearBtn(panel2,btnFrame)
    panel2.Visible=not panel2.Visible
    local bp=btnFrame.AbsolutePosition
    if panel2.Visible then
        task.defer(function()
            local pw=panel2.AbsoluteSize.X
            panel2.Position=UDim2.new(0,bp.X-pw-6,0,bp.Y)
        end)
    end
end

s1b.MouseButton1Click:Connect(function() openNearBtn(carpetPanel,s1f) end)
s2b.MouseButton1Click:Connect(function() openNearBtn(carpetScamPanel,s2f) end)
s3b.MouseButton1Click:Connect(function()
    alMain.Visible=not alMain.Visible alReopenBtn.Visible=not alMain.Visible
    s3st.Transparency=alMain.Visible and 0 or 0.2
end)

-- ============ AP + MINI AP TOGGLE LOGIC ============
local panelOpen=false local moved=false local inputStart=nil
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
        if inputStart and (i.Position-inputStart).Magnitude>6 then moved=true end
    end
end)
toggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then td2=false end
end)
toggleBtn.MouseButton1Click:Connect(function()
    if moved then return end
    panelOpen=not panelOpen panel.Visible=panelOpen miniPanel.Visible=panelOpen
    toggleBtn.TextColor3=panelOpen and C.ACC or C.DIM
    tStroke.Transparency=panelOpen and 0 or 0.15
    if panelOpen then buildCards() buildMiniCards() end
end)

-- Flash button drag+click
local flashOpen=false local fmoved=false local finputStart=nil
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
    flashOpen=not flashOpen flashPanel.Visible=flashOpen
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
        if t and t.Parent then selLbl.Text=t.DisplayName selLbl.TextColor3=C.ACC
        else selLbl.Text="tap player to select" selLbl.TextColor3=C.DIM end
    end
end)
Changes made:
AP fix — sequence now ends on player button, not cmd button. Each cmd goes: playerBtn → cmdBtn → playerBtn, resetting state so next use doesn't inherit previous selection
