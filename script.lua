-- PHANTOM FLASH & BLOCK - Phantom / r9qbx
task.spawn(function()
pcall(function()
repeat task.wait() until game:IsLoaded()

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local VIM          = game:GetService("VirtualInputManager")
local StarterGui   = game:GetService("StarterGui")
local CoreGui      = game:GetService("CoreGui")
local lp           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local isMobile     = UIS.TouchEnabled and not UIS.KeyboardEnabled

local GRAB_DIST = 5.5

local C = {
    BG    = Color3.fromRGB(7,6,12),
    CARD  = Color3.fromRGB(11,9,20),
    CARD2 = Color3.fromRGB(16,13,28),
    BORD  = Color3.fromRGB(40,30,70),
    TEXT  = Color3.fromRGB(228,220,248),
    DIM   = Color3.fromRGB(100,88,135),
    PURP  = Color3.fromRGB(155,70,240),
    PURPL = Color3.fromRGB(205,135,255),
    PURPD = Color3.fromRGB(28,12,55),
    TEAL  = Color3.fromRGB(45,210,185),
    ROSE  = Color3.fromRGB(238,60,155),
    GOLD  = Color3.fromRGB(255,195,40),
    ORG   = Color3.fromRGB(255,138,30),
    ON    = Color3.fromRGB(50,225,90),
    OFF   = Color3.fromRGB(20,18,36),
    GRAB  = Color3.fromRGB(60,235,105),
    RED   = Color3.fromRGB(255,50,75),
}

local function tw(o,p,t,s,d)
    TweenService:Create(o,TweenInfo.new(t or 0.13,s or Enum.EasingStyle.Quad,d or Enum.EasingDirection.Out),p):Play()
end
local function lp2(o,p,t)
    TweenService:Create(o,TweenInfo.new(t or 1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),p):Play()
end
local function co(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 10) return c end
local function stk(p,col,t,tr) local s=Instance.new("UIStroke",p) s.Color=col s.Thickness=t or 1 s.Transparency=tr or 0.3 return s end

local touchMoved=false local tsp=Vector2.zero
UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then touchMoved=false tsp=Vector2.new(i.Position.X,i.Position.Y) end end)
UIS.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then if(Vector2.new(i.Position.X,i.Position.Y)-tsp).Magnitude>14 then touchMoved=true end end end)
local function sc(btn,fn) btn.MouseButton1Click:Connect(function() if isMobile and touchMoved then return end fn() end) end

local function drag(f)
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

local GUI_NAME="Sys_"..tostring(math.random(10000,99999))
pcall(function() for _,v in ipairs(CoreGui:GetChildren()) do if v:IsA("ScreenGui") and v.Name:sub(1,4)=="Sys_" then v:Destroy() end end end)
local sg=Instance.new("ScreenGui") sg.Name=GUI_NAME sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999
local _=pcall(function() sg.Parent=CoreGui end) if not sg.Parent then sg.Parent=lp:WaitForChild("PlayerGui") end

-- ================================================================
-- ANTI RAGDOLL
-- ================================================================
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

-- ================================================================
-- TIMER ESP
-- ================================================================
local timerESPs={}
RunService.RenderStepped:Connect(function()
    local plots=workspace:FindFirstChild("Plots") if not plots then return end
    local function mkTESP(plot,part)
        if timerESPs[plot.Name] then pcall(function() timerESPs[plot.Name].bb:Destroy() end) end
        local bb=Instance.new("BillboardGui") bb.Size=UDim2.fromOffset(72,22) bb.StudsOffset=Vector3.new(0,9,0)
        bb.AlwaysOnTop=true bb.Adornee=part bb.MaxDistance=1500 bb.Parent=plot
        local bg2=Instance.new("Frame",bb) bg2.Size=UDim2.new(1,0,1,0) bg2.BackgroundColor3=Color3.fromRGB(7,7,12)
        bg2.BackgroundTransparency=0.15 bg2.BorderSizePixel=0 co(bg2,5)
        local s2=Instance.new("UIStroke",bg2) s2.Color=C.GOLD s2.Thickness=1.5 s2.Transparency=0.2
        local lbl=Instance.new("TextLabel",bg2) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Font=Enum.Font.GothamBold lbl.TextSize=11 lbl.TextColor3=C.GOLD
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
                if m and s then local tot=tonumber(m)*60+tonumber(s) e.lbl.TextColor3=tot<=30 and C.RED or tot<=60 and C.GOLD or C.GRAB end
            end
        else local e=timerESPs[plot.Name] if e then pcall(function() e.bb:Destroy() end) timerESPs[plot.Name]=nil end end
    end
end)

-- ================================================================
-- INSTANT STEAL
-- ================================================================
local isStealing=false local barFill=nil
local allAnimals={} local pCache={} local sCache={}

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
    if pCache[a.uid] and pCache[a.uid].Parent then return pCache[a.uid] end
    local plots=workspace:FindFirstChild("Plots") if not plots then return nil end
    local plot=plots:FindFirstChild(a.plotName) if not plot then return nil end
    local pods=plot:FindFirstChild("AnimalPodiums") if not pods then return nil end
    local pod=pods:FindFirstChild(a.slot) if not pod then return nil end
    local base=pod:FindFirstChild("Base") local spn=base and base:FindFirstChild("Spawn")
    local att=spn and spn:FindFirstChild("PromptAttachment") if not att then return nil end
    for _,p in ipairs(att:GetChildren()) do if p:IsA("ProximityPrompt") then pCache[a.uid]=p return p end end
end
local function buildCB(prompt)
    if sCache[prompt] then return end
    local data={hold={},trigger={},ready=true}
    local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end end
    local ok2,c2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(c2)=="table" then for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trigger,c.Function) end end end
    sCache[prompt]=data
end
local _fpp=fireproximityprompt
local function safeFirePrompt(p) pcall(_fpp,p,0) end

local function tryGrabNow()
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if not best or bd>(GRAB_DIST+4) then return end
    local prompt=pCache[best.uid] if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt)
    local data=sCache[prompt] if not data or not data.ready or isStealing then return end
    data.ready=false isStealing=true
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        task.wait(0.05)
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        safeFirePrompt(prompt)
        task.wait(0.07) data.ready=true isStealing=false
    end)
end

local function execSteal(prompt)
    local data=sCache[prompt] if not data or not data.ready or isStealing then return end
    data.ready=false isStealing=true
    if barFill then tw(barFill,{Size=UDim2.new(0.9,0,1,0),BackgroundColor3=C.GRAB},0.04) end
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        local t0=tick() local dur=0.07
        while tick()-t0<dur do
            if barFill then barFill.Size=UDim2.new(0.9+((tick()-t0)/dur)*0.1,0,1,0) end task.wait()
        end
        if barFill then barFill.Size=UDim2.new(1,0,1,0) end
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        safeFirePrompt(prompt)
        task.wait(0.07) data.ready=true isStealing=false
        if barFill then tw(barFill,{Size=UDim2.new(0.9,0,1,0),BackgroundColor3=C.GRAB},0.07) end
    end)
end

RunService.Heartbeat:Connect(function()
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    if isStealing then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end end
    if barFill then
        if not best then barFill.Size=UDim2.new(0,0,1,0)
        else barFill.Size=UDim2.new(0.9,0,1,0) tw(barFill,{BackgroundColor3=bd<=GRAB_DIST and C.ON or C.GRAB},0.06) end
    end
    if not best or bd>GRAB_DIST then return end
    local prompt=pCache[best.uid] if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt) if sCache[prompt] then execSteal(prompt) end
end)

-- ================================================================
-- AP CORE
-- ================================================================
local function fireBtn(b)
    pcall(function() for _,c in pairs(getconnections(b.MouseButton1Click)) do c:Fire() end end)
    pcall(function() for _,c in pairs(getconnections(b.Activated)) do c:Fire() end end)
end
local function findAP() return lp:WaitForChild("PlayerGui"):FindFirstChild("AdminPanel") end
local function getKwBtn(ap,kw)
    for _,o in ipairs(ap:GetDescendants()) do
        if o:IsA("TextButton") or o:IsA("ImageButton") then
            local t="" if o:IsA("TextButton") then t=o.Text:lower() else for _,c in ipairs(o:GetDescendants()) do if c:IsA("TextLabel") then t=c.Text:lower() break end end end
            if t:find(kw:lower()) then return o end
        end
    end
end
local function getPlrBtn(ap,target)
    for _,o in ipairs(ap:GetDescendants()) do
        if o:IsA("TextButton") or o:IsA("ImageButton") then
            local t="" if o:IsA("TextButton") then t=o.Text else for _,c in ipairs(o:GetDescendants()) do if c:IsA("TextLabel") then t=c.Text break end end end
            if t==target.Name or t==target.DisplayName then return o end
        end
    end
end
local AP_CMDS={"tiny","rocket","inverse","morph","jumpscare","balloon"}
local function spamAP(target)
    task.spawn(function()
        local ap=findAP() if not ap then return end
        for _,cmd in ipairs(AP_CMDS) do
            local pb=getPlrBtn(ap,target) if pb then fireBtn(pb) end
            local cb=getKwBtn(ap,cmd) if cb then fireBtn(cb) end
            local pb2=getPlrBtn(ap,target) if pb2 then fireBtn(pb2) end
            task.wait(0.01)
        end
    end)
end

-- ================================================================
-- NEAREST + BLOCK
-- ================================================================
local function getNearestPlayer()
    local myR=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") if not myR then return nil end
    local best,bd=nil,math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d=(myR.Position-r.Position).Magnitude if d<bd then bd=d best=p end end
        end
    end
    return best
end

-- Fast synchronous block — called inline so it fully completes before we move
local function doBlockFast(target)
    if not target then return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer",target) end)
    task.wait(0.18)
    local vp=Camera.ViewportSize
    for i=1,2 do
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.565,0,true,game,1)  task.wait(0.01)
        VIM:SendMouseButtonEvent(vp.X/2,vp.Y*0.565,0,false,game,1) task.wait(0.01)
    end
end

-- ================================================================
-- FRIEND PROMPTS
-- ================================================================
local _fpp2=fireproximityprompt
local function fireFriendPrompt()
    task.spawn(function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and(v.ActionText:lower():find("friend") or v.ObjectText:lower():find("friend")) then
                pcall(_fpp2,v) task.wait(0.05)
            end
        end
    end)
end

-- ================================================================
-- MAIN SEQUENCE
-- ================================================================
local autoAPOnTP=false
local running=false
local statusLbl=nil

local function setStatus(txt,col)
    if statusLbl and statusLbl.Parent then statusLbl.Text=txt statusLbl.TextColor3=col or C.DIM end
end

local function doFlashAndBlock()
    if running then return end
    local char=lp.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    running=true setStatus("Blocking...",C.ROSE)

    task.spawn(function()
        local ok,err=pcall(function()

            -- STEP 1: Pre-block fully synchronous — completes before anything moves
            local nearest=getNearestPlayer()
            if nearest then
                doBlockFast(nearest)
                -- Small delay after block click so Roblox processes the kick
                -- before we TP into their base
                setStatus("Waiting...",C.GOLD)
                task.wait(0.6) -- player gets removed in this window
            end

            -- STEP 2: Camera snap
            setStatus("Running...",C.ORG)
            Camera.CameraType=Enum.CameraType.Scriptable
            Camera.CFrame=CFrame.new(-342.018,-2.532,77.531,0.970,0.057,-0.235,0.000,0.971,0.237,0.242,-0.230,0.943)
            task.wait(0.04)
            Camera.CameraType=Enum.CameraType.Custom

            -- STEP 3: Carpet + TP (into their now-unprotected base)
            setStatus("Carpet...",C.ORG)
            local carpet=lp.Backpack:FindFirstChild("Flying Carpet") or char:FindFirstChild("Flying Carpet")
                or lp.Backpack:FindFirstChild("Carpet") or char:FindFirstChild("Carpet")
            if carpet then hum:EquipTool(carpet) end
            hrp.CFrame=CFrame.new(-340.78,-7.00,65.33)
            hrp.AssemblyLinearVelocity=Vector3.zero

            -- STEP 4: Flash
            task.wait(0.25)
            setStatus("Flash...",C.PURP)
            local flash=lp.Backpack:FindFirstChild("Flash Teleport") or char:FindFirstChild("Flash Teleport")
                or lp.Backpack:FindFirstChild("Flash") or char:FindFirstChild("Flash")
