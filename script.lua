-- Aethen Hub v0.9 | @r9qbx | discord.gg/hyZGbJP9
local Players=game:GetService("Players"); local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService"); local RS=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService"); local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui"); local Lighting=game:GetService("Lighting")
local lp=Players.LocalPlayer; local cam=workspace.CurrentCamera
local pg=lp:WaitForChild("PlayerGui")

for _,v in ipairs(pg:GetChildren()) do if v.Name=="AethenGui" then v:Destroy() end end
for _,v in ipairs(CoreGui:GetChildren()) do if v.Name=="Aeth_09" or v.Name=="PhFV" then v:Destroy() end end

-- ════════════════════════════════════════
-- PHANTOM V5 LOGIC (exact)
-- ════════════════════════════════════════
local CFG="AethenV09.json"
local Cfg={triggerChance=91,flashOn=false,grabOn=true,potionOn=false,spdOn=false,spdVal=30}
pcall(function() if not readfile then return end; local raw=readfile(CFG); if not raw or raw=="" then return end; local ok,t=pcall(HttpService.JSONDecode,HttpService,raw); if ok and type(t)=="table" then for k,v in pairs(t) do Cfg[k]=v end end end)
local function save() pcall(function() if writefile then writefile(CFG,HttpService:JSONEncode(Cfg)) end end) end

local isStealing=false; local myPlotRef=nil; local stealHitbox=nil
task.spawn(function() while true do task.wait(0.9); if not myPlotRef then local plots=workspace:FindFirstChild("Plots"); if not plots then continue end; for _,p in ipairs(plots:GetChildren()) do local sign=p:FindFirstChild("PlotSign"); if not sign then continue end; local tl=sign:FindFirstChild("TextLabel",true); if not tl then continue end; local t=tl.Text:lower(); if t:find(lp.Name:lower(),1,true) or t:find(lp.DisplayName:lower(),1,true) then myPlotRef=p; stealHitbox=p:FindFirstChild("StealHitbox",true); break end end end end end)

-- Admin remote
local ADM_REMOTE=nil
task.spawn(function() pcall(function() if not lp.Character then lp.CharacterAdded:Wait() end end); task.wait(1.5); pcall(function() local net=RS:WaitForChild("Packages"):WaitForChild("Net"); local ch=net:GetChildren(); local n2i={}; for i,o in ipairs(ch) do n2i[o.Name]=i end; local a=n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]; if a and ch[a+1] then ADM_REMOTE=ch[a+1] end end) end)
local ADM_UUID="f888ee6e-c86d-46e1-93d7-0639d6635d42"
local function aFire(tgt,cmd) task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,tgt,cmd) end) end) end
local ROW_CD={ragdoll=30,balloon=30,tiny=60,jail=60,rocket=120,inverse=60,nightvision=60,jumpscare=60,control=60,morph=60}
local rowCdEnd={}
local function fireCmd(tgt,cmd) if not ADM_REMOTE then return end; aFire(tgt,cmd); rowCdEnd[cmd]=tick()+(ROW_CD[cmd] or 30) end

-- Base protector
local CARPET={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true,["Cupid's Wings"]=true}
local antiSteal=false; local autoKick=false; local antiIntruder=false; local antiTp=false
local lastPunish={}; local carpetSpam={}; local plrPos={}; local tpCD={}
local function punish(p) if not ADM_REMOTE or not p or p==lp then return end; local uid=p.UserId; local now=tick(); if lastPunish[uid] and now-lastPunish[uid]<0.5 then return end; lastPunish[uid]=now; pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end); rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30); if autoKick then task.delay(0.05,function() lp:Kick("SAVED") end) end end
local function findThief() local sp=stealHitbox and stealHitbox.Position; if not sp then local h=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); sp=h and h.Position end; if not sp then return nil end; local best,bd=nil,math.huge; for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); if h then local d=(h.Position-sp).Magnitude; if d<bd then bd=d; best=p end end end end; return best end
local function chkHitbox() if not stealHitbox then return end; local cf,sz=stealHitbox.CFrame,stealHitbox.Size; local hx,hz=sz.X*0.5,sz.Z*0.5; for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); if not h then continue end; local rel=cf:PointToObjectSpace(h.Position); if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then for _,item in ipairs(p.Character:GetChildren()) do if CARPET[item.Name] then punish(p); break end end end end end end
pcall(function() if not hookfunction or not fireproximityprompt then return end; local old=fireproximityprompt; hookfunction(fireproximityprompt,newcclosure(function(prompt,...) if antiSteal and (prompt.ActionText or ""):lower():find("steal") then local t=findThief(); if t then punish(t) end; chkHitbox() end; return old(prompt,...) end)) end)

-- EXT callbacks
local StealCBCache={}
local function buildStealCBs(prompt) if StealCBCache[prompt] then return end; local data={hold={},trig={}}; local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan); if ok1 and type(c1)=="table" then for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end end; local ok2,c2=pcall(getconnections,prompt.Triggered); if ok2 and type(c2)=="table" then for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trig,c.Function) end end end; if #data.hold>0 or #data.trig>0 then StealCBCache[prompt]=data end end
local function fireStealCBs(prompt) local data=StealCBCache[prompt]; if not data then return end; for _,fn in ipairs(data.hold) do task.spawn(fn) end; task.wait(0.05); for _,fn in ipairs(data.trig) do task.spawn(fn) end end

-- Potion
local potionOn=Cfg.potionOn
local function activatePotion() if not potionOn then return end; task.spawn(function() pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local bp=lp:FindFirstChild("Backpack"); local tool=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion")); if not tool then return end; hum:EquipTool(tool); task.wait(0.08); tool:Activate() end) end) end

-- Irish reset (ice hub style) + Limited Hub keybind
local resetCF=CFrame.new(1000003.56,999999.69,8.17); local isResetting=false
local function doReset()
    if isResetting then return end; isResetting=true
    local c=lp.Character; if not c then isResetting=false; return end
    local h=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then isResetting=false; return end
    local carpet=lp.Backpack:FindFirstChild("Flying Carpet") or c:FindFirstChild("Flying Carpet")
    if carpet then carpet.Parent=c end
    cam.CameraType=Enum.CameraType.Scriptable
    task.delay(0.6,function() cam.CameraType=Enum.CameraType.Custom; local nc=lp.Character; if nc then local nh=nc:FindFirstChildOfClass("Humanoid"); if nh then cam.CameraSubject=nh end end end)
    h.CFrame=resetCF
    local con; con=RunService.Heartbeat:Connect(function() if not c or not c.Parent or hum.Health<=0 then con:Disconnect(); return end; h.CFrame=resetCF end)
    task.delay(1.5,function() isResetting=false end)
end

-- Flash TP (exact Phantom V5)
local flashEnabled=Cfg.flashOn; local sliderValue=Cfg.triggerChance/100; local activePrompts={}
PPS.PromptButtonHoldBegan:Connect(function(prompt)
    if not flashEnabled or prompt.ActionText~="Steal" or activePrompts[prompt] then return end
    activePrompts[prompt]=true; local fired=false
    local fireAt=os.clock()+math.max(prompt.HoldDuration,0.001)*sliderValue; local conn
    conn=RunService.Heartbeat:Connect(function()
        if fired then conn:Disconnect(); return end
        if not prompt or not prompt.Parent then conn:Disconnect(); activePrompts[prompt]=nil; return end
        if os.clock()>=fireAt then
            fired=true; conn:Disconnect(); activePrompts[prompt]=nil; isStealing=true
            local char=lp.Character; local tool=char and char:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
            task.spawn(function() RunService.Heartbeat:Wait(); activatePotion() end)
            task.spawn(function() task.wait(0.1); buildStealCBs(prompt); if StealCBCache[prompt] then fireStealCBs(prompt) end end)
            task.delay(0.9,function() isStealing=false end)
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function() if not fired then fired=true; activePrompts[prompt]=nil; conn:Disconnect() end end)
end)

-- Cam align
local cfA=CFrame.new(-322.066,-7.871,111.991)*CFrame.Angles(0.332,-0.019,0.000); local cfB=CFrame.new(-325.856,-7.866,113.027)*CFrame.Angles(0.327,3.130,0.000)
local lookA2=cfA.LookVector; local lookB2=cfB.LookVector; local desiredY=lookA2.Y
local function flatV(v) local f=Vector3.new(v.X,0,v.Z); return f.Magnitude>0 and f.Unit or f end
local function bLook(bl) local h2=flatV(bl); local fs=math.sqrt(math.max(0,1-desiredY^2)); return Vector3.new(h2.X*fs,desiredY,h2.Z*fs) end
local FLASH_NAMES={"Flash Teleport","Flash","FlashTP","Flash TP"}
local function equipFlash() pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end; for _,n in ipairs(FLASH_NAMES) do local t=char:FindFirstChild(n) or (lp.Backpack and lp.Backpack:FindFirstChild(n)); if t then if t.Parent~=char then hum:EquipTool(t) end; return end end end) end
local function alignCam() local pos=cam.CFrame.Position; local cf=flatV(cam.CFrame.LookVector); local best=cf:Dot(flatV(lookA2))>cf:Dot(flatV(lookB2)) and bLook(lookA2) or bLook(lookB2); cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=CFrame.lookAt(pos,pos+best); task.wait(); cam.CameraType=Enum.CameraType.Custom end

-- Anti-ragdoll (exact Phantom V5)
local arConn=nil
local function startAntiRag()
    if arConn then return end
    arConn=RunService.Heartbeat:Connect(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s=hum:GetState(); local rag=(s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown)
        local et=lp:GetAttribute("RagdollEndTime"); if et and (et-workspace:GetServerTimeNow())>0 then rag=true end
        if rag then
            pcall(function() lp:SetAttribute("RagdollEndTime",workspace:GetServerTimeNow()) end)
            for _,d in ipairs(char:GetDescendants()) do if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then d:Destroy() end end
            for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
            if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            cam.CameraSubject=hum; root.Anchored=false; root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
        end
    end)
end
startAntiRag()

-- Anti-sentry v2 (Sentry + Turret + Beehive, skip during steal)
local sentryFirstSeen={}; local sentryTarget=nil
local function isMySentry(obj) local id=obj.Name:match("Sentry_(%d+)") or obj.Name:match("Turret_(%d+)") or obj.Name:match("Beehive_(%d+)"); if id and tonumber(id)==lp.UserId then return true end; local a=obj:GetAttribute("OwnerId") or obj:GetAttribute("Owner"); return a and tonumber(tostring(a))==lp.UserId end
local antiSentryOn=true
RunService.Heartbeat:Connect(function()
    if not antiSentryOn or isStealing then sentryTarget=nil; return end
    local char=lp.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local now=tick()
    if sentryTarget and sentryTarget.Parent==workspace then
        for _,part in pairs(sentryTarget:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
        local cf=hrp.CFrame*CFrame.new(0,0,-5)
        if sentryTarget:IsA("BasePart") then sentryTarget.CFrame=cf
        elseif sentryTarget:IsA("Model") then local m=sentryTarget.PrimaryPart or sentryTarget:FindFirstChildWhichIsA("BasePart"); if m then m.CFrame=cf end end
        local hum=char:FindFirstChildOfClass("Humanoid"); local weapon=(lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat")
        if hum and weapon then if weapon.Parent==lp.Backpack then hum:EquipTool(weapon) end; pcall(function() weapon:Activate() end) end
    else
        sentryTarget=nil; for obj in pairs(sentryFirstSeen) do if not obj.Parent then sentryFirstSeen[obj]=nil end end
        for _,obj in pairs(workspace:GetChildren()) do
            local nm=obj.Name; if (nm:find("Sentry") or nm:find("Turret") or nm:find("Beehive")) and not nm:lower():find("bullet") and not isMySentry(obj) then
                local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and (hrp.Position-part.Position).Magnitude<=220 then
                    if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=now end
                    if now-sentryFirstSeen[obj]>=3 then sentryTarget=obj; break end
                end
            end
        end
    end
end)

-- Anti-bee (exact Phantom V5)
local FOV_LOCK=70
RunService.RenderStepped:Connect(function() if cam.FieldOfView~=FOV_LOCK then cam.FieldOfView=FOV_LOCK end end)
local beeBlacklist={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","PostEffect"}
local function isBeeEffect(obj) for _,n in ipairs(beeBlacklist) do if obj:IsA(n) then return true end end; return false end
for _,v in pairs(Lighting:GetDescendants()) do if isBeeEffect(v) then pcall(function() v:Destroy() end) end end
Lighting.DescendantAdded:Connect(function(obj) task.wait(); if isBeeEffect(obj) then pcall(function() obj:Destroy() end) end end)
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    for _,obj in ipairs(char:GetDescendants()) do local nl=obj.Name:lower(); if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") then pcall(function() obj:Destroy() end) end end
    local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.MoveDirection.Magnitude>0.1 then local md=hum.MoveDirection; local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z); if vel.Magnitude>3 and md:Dot(vel.Unit)<-0.5 then root.Velocity=Vector3.new(md.X*16,root.Velocity.Y,md.Z*16) end end
end)

-- Speed
local speedEnabled=Cfg.spdOn; local stealingSpeed=math.clamp(Cfg.spdVal or 30,10,100)
local function applySpeed() local char=lp.Character; if not char then return end; local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid"); if not root or not hum then return end; if hum.MoveDirection.Magnitude>0 then root.Velocity=Vector3.new(hum.MoveDirection.X*stealingSpeed,root.Velocity.Y,hum.MoveDirection.Z*stealingSpeed) end end

-- Grab (exact Phantom V5)
local grabEnabled=Cfg.grabOn
local function findNearestSteal() local char=lp.Character; if not char then return nil end; local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"); if not root then return nil end; local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end; local myPos=root.Position; local nearest,nd=nil,math.huge; for _,plot in ipairs(plots:GetChildren()) do for _,obj in ipairs(plot:GetDescendants()) do if obj:IsA("ProximityPrompt") and obj.Enabled and obj.ActionText=="Steal" then local p=obj.Parent; local pos; if p:IsA("BasePart") then pos=p.Position elseif p:IsA("Model") then local r=p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart"); pos=r and r.Position end; if pos then local d=(myPos-pos).Magnitude; if d<=math.max(obj.MaxActivationDistance,8) and d<nd then nearest=obj; nd=d end end end end end; return nearest end
task.spawn(function()
    while true do
        if grabEnabled then
            local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                local nearest=findNearestSteal()
                if nearest then
                    task.wait(0.07); buildStealCBs(nearest); local data=StealCBCache[nearest]
                    if data and (#data.hold>0 or #data.trig>0) then task.spawn(function() fireStealCBs(nearest) end)
                    else task.spawn(function() pcall(function() fireproximityprompt(nearest,10000); nearest:InputHoldBegin(); task.wait(0.04); nearest:InputHoldEnd() end) end) end
                    activatePotion()
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Consolidated heartbeat
local lastDt=1/60
RunService.Heartbeat:Connect(function(dt)
    lastDt=dt; local now=tick()
    if speedEnabled then applySpeed() end
    if antiIntruder and stealHitbox and ADM_REMOTE then
        local cf,sz=stealHitbox.CFrame,stealHitbox.Size; local hx,hz=sz.X*0.5,sz.Z*0.5
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local h=p.Character:FindFirstChild("HumanoidRootPart"); if not h then continue end
                local rel=cf:PointToObjectSpace(h.Position)
                if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then
                    for _,item in ipairs(p.Character:GetChildren()) do
                        if CARPET[item.Name] then local uid=p.UserId; if not carpetSpam[uid] then carpetSpam[uid]=true; pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end); rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30); if autoKick then task.delay(0.05,function() lp:Kick("SAVED") end) end; task.delay(5,function() carpetSpam[uid]=nil end) end; break end
                    end
                end
            end
        end
    end
    if antiTp and ADM_REMOTE then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local h=p.Character:FindFirstChild("HumanoidRootPart"); if not h then continue end
                local cur=h.Position; local uid=p.UserId; local last=plrPos[uid]
                if last and (cur-last).Magnitude>7 then for _,item in ipairs(p.Character:GetChildren()) do if CARPET[item.Name] then if not tpCD[uid] or now-tpCD[uid]>3 then tpCD[uid]=now; pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end); rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30) end; break end end end
                plrPos[uid]=cur
            end
        end
    end
end)

-- ════════════════════════════════════════
-- FUN HUB V5.3 GUI (Aethen Edition)
-- ════════════════════════════════════════
task.wait(0.1); local vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end

local function n(cls,props,par) local o=Instance.new(cls); for k,v in pairs(props) do o[k]=v end; if par then o.Parent=par end; return o end
local function co(p,r) n("UICorner",{CornerRadius=UDim.new(0,r or 8)},p) end
local function addStroke(p,th,col,tr) local s=n("UIStroke",{Thickness=th or 1,Color=col or Color3.fromRGB(60,60,80),Transparency=tr or 0.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p); return s end

local SG=n("ScreenGui",{Name="AethenGui",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true},pg)

-- Main 350x400 window
local MF=n("Frame",{Name="MainFrame",Size=UDim2.fromOffset(350,400),Position=UDim2.new(0.5,-175,0.5,-200),BackgroundColor3=Color3.fromRGB(18,18,24),BorderSizePixel=0,Visible=false,Active=true,ClipsDescendants=true},SG)
co(MF,14); local MFScale=n("UIScale",{Scale=1e-7},MF)
local MFStroke=n("UIStroke",{Thickness=1.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=Color3.fromRGB(255,255,255)},MF)
local MFGrad=n("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(220,220,255)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(100,100,140)),ColorSequenceKeypoint.new(1,Color3.fromRGB(220,220,255))},Rotation=45},MFStroke)
task.spawn(function() while MFStroke and MFStroke.Parent do MFGrad.Rotation=(MFGrad.Rotation+0.8)%360; task.wait(0.016) end end)

-- Title bar
local TBar=n("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(12,12,18),BorderSizePixel=0},MF); co(TBar,14)
n("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=Color3.fromRGB(12,12,18),BorderSizePixel=0},TBar)
n("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text="AETHEN HUB  v0.9",Font=Enum.Font.GothamBlack,TextSize=14,TextColor3=Color3.fromRGB(225,225,245),TextXAlignment=Enum.TextXAlignment.Left},TBar)
n("TextLabel",{Size=UDim2.new(1,-10,0,11),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,Text="@r9qbx  |  discord.gg/hyZGbJP9",Font=Enum.Font.Gotham,TextSize=8,TextColor3=Color3.fromRGB(90,90,115),TextXAlignment=Enum.TextXAlignment.Left},TBar)

-- Drag
do local on,ds,sp=false,nil,nil; TBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=true; ds=i.Position; sp=MF.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then on=false end end) end end); UIS.InputChanged:Connect(function(i) if not on then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-ds; MF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end) end

-- Tab bar
local TabBar=n("Frame",{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,38),BackgroundColor3=Color3.fromRGB(10,10,16),BorderSizePixel=0},MF)
local tabNames={"Main","Visual","Player","Utils"}
local tabBtns={}; local tabW=350/#tabNames
for i,tname in ipairs(tabNames) do
    local tb=n("TextButton",{Size=UDim2.fromOffset(tabW,26),Position=UDim2.fromOffset((i-1)*tabW,0),BackgroundColor3=i==1 and Color3.fromRGB(22,22,34) or Color3.fromRGB(10,10,16),BackgroundTransparency=0,Text=tname,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=i==1 and Color3.fromRGB(220,220,245) or Color3.fromRGB(80,80,105),BorderSizePixel=0,AutoButtonColor=false},TabBar)
    tabBtns[i]=tb
end

-- Content area
local CA=n("Frame",{Size=UDim2.new(1,0,1,-64),Position=UDim2.fromOffset(0,64),BackgroundTransparency=1,BorderSizePixel=0},MF)

-- Build scrolling frames for each tab
local tabs={}
for i=1,4 do
    local sf=n("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Color3.fromRGB(80,80,110),AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),Visible=i==1},CA)
    n("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},sf)
    n("UIPadding",{PaddingTop=UDim.new(0,6),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},sf)
    tabs[i]=sf
end

-- Tab switching
for i,tb in ipairs(tabBtns) do
    tb.MouseButton1Click:Connect(function()
        for j,t in ipairs(tabs) do t.Visible=j==i end
        for j,b in ipairs(tabBtns) do b.BackgroundColor3=j==i and Color3.fromRGB(22,22,34) or Color3.fromRGB(10,10,16); b.TextColor3=j==i and Color3.fromRGB(220,220,245) or Color3.fromRGB(80,80,105) end
    end)
end

-- Open / close button "Aethen"
local openBtn=n("TextButton",{Name="AethenOpen",Size=UDim2.fromOffset(60,28),Position=UDim2.fromOffset(8,math.floor(vp.Y*0.5)),BackgroundColor3=Color3.fromRGB(12,12,20),BorderSizePixel=0,Text="Aethen",Font=Enum.Font.GothamBlack,TextSize=10,TextColor3=Color3.fromRGB(200,200,230),AutoButtonColor=false,ZIndex=10},SG)
co(openBtn,8); addStroke(openBtn,1.2,Color3.fromRGB(160,160,200),0.25)
-- Drag open button, clamp to screen
do local on,ds,sp=false,nil,nil; openBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=true; ds=i.Position; sp=openBtn.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then on=false end end) end end); UIS.InputChanged:Connect(function(i) if not on then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-ds; local nx=math.clamp(sp.X.Offset+d.X,0,vp.X-64); local ny=math.clamp(sp.Y.Offset+d.Y,0,vp.Y-30); openBtn.Position=UDim2.fromOffset(nx,ny) end end) end

local guiOpen=false
local function openAnim(show)
    guiOpen=show
    if show then MF.Visible=true; TweenService:Create(MFScale,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
    else TweenService:Create(MFScale,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=1e-7}):Play(); task.delay(0.2,function() MF.Visible=false end) end
    openBtn.Text=show and "Close" or "Aethen"; openBtn.TextColor3=show and Color3.fromRGB(255,80,80) or Color3.fromRGB(200,200,230)
end
openBtn.MouseButton1Click:Connect(function() openAnim(not guiOpen) end)

-- ── GUI HELPERS ──
local function section(tab,title)
    local f=n("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=#tab:GetChildren()+1},tab)
    n("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=title:upper(),Font=Enum.Font.GothamBlack,TextSize=8,TextColor3=Color3.fromRGB(80,80,110),TextXAlignment=Enum.TextXAlignment.Left},f)
    local ln=n("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=Color3.fromRGB(30,30,46),BorderSizePixel=0},f)
end

local function togRow(tab,label,onCol,defOn)
    onCol=onCol or Color3.fromRGB(80,200,120)
    local row=n("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.fromRGB(14,14,22),BorderSizePixel=0,LayoutOrder=#tab:GetChildren()+1},tab)
    co(row,8); addStroke(row,1,Color3.fromRGB(28,28,44),0.0)
    n("TextLabel",{Size=UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=defOn and Color3.fromRGB(220,220,240) or Color3.fromRGB(120,120,145),TextXAlignment=Enum.TextXAlignment.Left},row)
    local track=n("Frame",{Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-52,0.5,-11),BackgroundColor3=defOn and onCol or Color3.fromRGB(28,28,40),BorderSizePixel=0},row); co(track,11)
    local knob=n("Frame",{Size=UDim2.fromOffset(18,18),Position=defOn and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),BackgroundColor3=Color3.fromRGB(240,240,255),BorderSizePixel=0},track); co(knob,9)
    local pb=n("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false},row)
    local isOn=defOn or false
    local lbl=row:FindFirstChildOfClass("TextLabel")
    local function set(v) isOn=v; TweenService:Create(track,TweenInfo.new(0.12),{BackgroundColor3=v and onCol or Color3.fromRGB(28,28,40)}):Play(); TweenService:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play(); if lbl then lbl.TextColor3=v and Color3.fromRGB(220,220,240) or Color3.fromRGB(120,120,145) end end
    if defOn then set(true) end
    return pb,set,function() return isOn end
end

local function actionRow(tab,label,col)
    local row=n("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.fromRGB(14,14,22),BorderSizePixel=0,LayoutOrder=#tab:GetChildren()+1},tab)
    co(row,8); addStroke(row,1,Color3.fromRGB(28,28,44),0.0)
    local pb=n("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false},row)
    n("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=col or Color3.fromRGB(200,200,225),TextXAlignment=Enum.TextXAlignment.Left},row)
    n("TextLabel",{Size=UDim2.fromOffset(14,32),Position=UDim2.new(1,-18,0,0),BackgroundTransparency=1,Text=">",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(60,60,90)},row)
    pb.MouseButton1Down:Connect(function() TweenService:Create(row,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(20,20,30)}):Play() end)
    pb.MouseButton1Up:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(14,14,22)}):Play() end)
    return pb
end

local function sliderRow(tab,label,mn,mx,def,onChange)
    local row=n("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=Color3.fromRGB(14,14,22),BorderSizePixel=0,LayoutOrder=#tab:GetChildren()+1},tab)
    co(row,8); addStroke(row,1,Color3.fromRGB(28,28,44),0.0)
    local valLbl=n("TextLabel",{Size=UDim2.new(1,-10,0,18),Position=UDim2.fromOffset(10,3),BackgroundTransparency=1,Text=label..": "..def,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(160,160,190),TextXAlignment=Enum.TextXAlignment.Left},row)
    local track=n("Frame",{Size=UDim2.new(1,-16,0,4),Position=UDim2.fromOffset(8,26),BackgroundColor3=Color3.fromRGB(28,28,44),BorderSizePixel=0},row); co(track,2)
    local fill=n("Frame",{Size=UDim2.new((def-mn)/(mx-mn),0,1,0),BackgroundColor3=Color3.fromRGB(140,100,255),BorderSizePixel=0},track); co(fill,2)
    local kn=n("Frame",{Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new((def-mn)/(mx-mn),0,0.5,0),BackgroundColor3=Color3.fromRGB(240,240,255),BorderSizePixel=0},track); co(kn,6)
    local slOn=false
    local function setV(pct) pct=math.clamp(pct,0,1); local v=math.floor(mn+pct*(mx-mn)); fill.Size=UDim2.new(pct,0,1,0); kn.Position=UDim2.new(pct,0,0.5,0); valLbl.Text=label..": "..v; if onChange then onChange(v) end end
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slOn=true; setV((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X) end end)
    UIS.InputEnded:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and slOn then slOn=false end end)
    UIS.InputChanged:Connect(function(i) if not slOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setV((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X) end end)
end

-- ════ POPUP PANELS ════
local function makePopup(w,h,title)
    local pf=n("Frame",{Size=UDim2.fromOffset(w,h),Position=UDim2.new(0.5,-w/2,0.5,-h/2),BackgroundColor3=Color3.fromRGB(12,12,20),BorderSizePixel=0,Visible=false,ZIndex=20},SG)
    co(pf,12); addStroke(pf,1.5,Color3.fromRGB(80,80,120),0.2)
    local hdr=n("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,ZIndex=21},pf); co(hdr,12)
    n("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,ZIndex=21},hdr)
    n("TextLabel",{Size=UDim2.new(1,-40,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamBlack,TextSize=10,TextColor3=Color3.fromRGB(200,200,230),ZIndex=22,TextXAlignment=Enum.TextXAlignment.Left},hdr)
    local closeB=n("TextButton",{Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,-30,0.5,-13),BackgroundColor3=Color3.fromRGB(50,8,8),BorderSizePixel=0,Text="X",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(255,80,80),AutoButtonColor=false,ZIndex=22},hdr); co(closeB,6)
    closeB.MouseButton1Click:Connect(function() pf.Visible=false end)
    local c=n("Frame",{Size=UDim2.new(1,0,1,-30),Position=UDim2.fromOffset(0,30),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=20},pf)
    do local on,ds,sp=false,nil,nil; hdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=true; ds=i.Position; sp=pf.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then on=false end end) end end); UIS.InputChanged:Connect(function(i) if not on then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-ds; pf.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end) end
    return pf,c
end

-- Actions panel
local actPop,actC=makePopup(220,168,"Actions")
local function actBtn(text,y,col) local b=n("TextButton",{Size=UDim2.fromOffset(200,30),Position=UDim2.fromOffset(10,y),BackgroundColor3=col or Color3.fromRGB(20,20,32),BorderSizePixel=0,Text=text,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(210,210,230),AutoButtonColor=false,ZIndex=21},actC); co(b,8); return b end
local rejB=actBtn("Rejoin",8); local kickB=actBtn("Kick Self",44,Color3.fromRGB(35,8,8)); kickB.TextColor3=Color3.fromRGB(255,80,80); local ragB=actBtn("Ragdoll Self",80); local rstB=actBtn("Instant Reset",116,Color3.fromRGB(10,10,36)); rstB.TextColor3=Color3.fromRGB(140,140,255)
rejB.MouseButton1Click:Connect(function() rejB.Text="..."; pcall(function() if reconnect then reconnect() elseif syn and syn.reconnect then syn.reconnect() else TeleportService:Teleport(game.PlaceId,lp) end end) end)
kickB.MouseButton1Click:Connect(function() lp:Kick("Aethen Hub") end)
ragB.MouseButton1Click:Connect(function() if ADM_REMOTE then pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end) end end)
rstB.MouseButton1Click:Connect(function() task.spawn(doReset) end)

-- Booster panel
local bstPop,bstC=makePopup(220,120,"Booster")
local bstOn=false
local bstToggle=n("TextButton",{Size=UDim2.fromOffset(200,30),Position=UDim2.fromOffset(10,6),BackgroundColor3=Color3.fromRGB(20,20,32),BorderSizePixel=0,Text="Booster: OFF",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(255,100,100),AutoButtonColor=false,ZIndex=21},bstC); co(bstToggle,8)
local wsRow=n("Frame",{Size=UDim2.fromOffset(200,30),Position=UDim2.fromOffset(10,42),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,ZIndex=21},bstC); co(wsRow,8)
n("TextLabel",{Size=UDim2.fromOffset(70,30),BackgroundTransparency=1,Text="WalkSpeed",Font=Enum.Font.Gotham,TextSize=9,TextColor3=Color3.fromRGB(140,140,170),ZIndex=22,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(8,0)},wsRow)
local wsTB=n("TextBox",{Size=UDim2.fromOffset(60,22),Position=UDim2.new(1,-68,0.5,-11),BackgroundColor3=Color3.fromRGB(22,22,36),BorderSizePixel=0,Text="30",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(200,200,230),ClearTextOnFocus=false,ZIndex=22},wsRow); co(wsTB,5)
local jpRow=n("Frame",{Size=UDim2.fromOffset(200,30),Position=UDim2.fromOffset(10,78),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,ZIndex=21},bstC); co(jpRow,8)
n("TextLabel",{Size=UDim2.fromOffset(70,30),BackgroundTransparency=1,Text="JumpPower",Font=Enum.Font.Gotham,TextSize=9,TextColor3=Color3.fromRGB(140,140,170),ZIndex=22,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(8,0)},jpRow)
local jpTB=n("TextBox",{Size=UDim2.fromOffset(60,22),Position=UDim2.new(1,-68,0.5,-11),BackgroundColor3=Color3.fromRGB(22,22,36),BorderSizePixel=0,Text="50",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(200,200,230),ClearTextOnFocus=false,ZIndex=22},jpRow); co(jpTB,5)
bstToggle.MouseButton1Click:Connect(function()
    bstOn=not bstOn; bstToggle.Text=bstOn and "Booster: ON" or "Booster: OFF"; bstToggle.TextColor3=bstOn and Color3.fromRGB(80,220,120) or Color3.fromRGB(255,100,100)
    RunService.Heartbeat:Connect(function() if not bstOn then return end; local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local ws=tonumber(wsTB.Text); local jp=tonumber(jpTB.Text); if ws then hum.WalkSpeed=ws end; if jp then hum.JumpPower=jp end end)
end)

-- Defense panel
local defPop,defC=makePopup(240,100,"Defense")
local spamReset=false
local defTogPB,defSet=togRow(defC,"Auto Defense (Anti Steal)",Color3.fromRGB(80,200,120))
defTogPB.MouseButton1Click:Connect(function() antiSteal=not antiSteal; defSet(antiSteal) end)
local srTogPB,srSet=togRow(defC,"Spam On Reset",Color3.fromRGB(255,140,40))
srTogPB.MouseButton1Click:Connect(function() spamReset=not spamReset; srSet(spamReset) end)

-- Command cooldowns panel
local cdPop,cdC=makePopup(220,290,"Command Cooldowns")
local cdCmds={"rocket","balloon","ragdoll","inverse","nightvision","jail","control","tiny","jumpscare","morph"}
local cdLabels={}
for i,cmd in ipairs(cdCmds) do
    local row=n("Frame",{Size=UDim2.fromOffset(200,22),Position=UDim2.fromOffset(10,(i-1)*26+6),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,ZIndex=21},cdC); co(row,6)
    n("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,Text=cmd,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(160,160,190),ZIndex=22,TextXAlignment=Enum.TextXAlignment.Left},row)
    local st=n("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.6,0,0,0),BackgroundTransparency=1,Text="READY",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(80,210,100),ZIndex=22,TextXAlignment=Enum.TextXAlignment.Right},row)
    cdLabels[cmd]=st
end
task.spawn(function() while true do task.wait(0.5); local now=tick(); for cmd,lbl in pairs(cdLabels) do if lbl and lbl.Parent then local cd=rowCdEnd[cmd]; if cd and cd>now then lbl.Text=tostring(math.ceil(cd-now)).."s"; lbl.TextColor3=Color3.fromRGB(255,80,80) else lbl.Text="READY"; lbl.TextColor3=Color3.fromRGB(80,210,100) end end end end end)

-- Admin spammer panel (closest player)
local admSPop,admSC=makePopup(240,240,"Admin Spammer")
local spamScroll=n("ScrollingFrame",{Size=UDim2.fromOffset(220,170),Position=UDim2.fromOffset(10,6),BackgroundColor3=Color3.fromRGB(10,10,18),BorderSizePixel=0,ScrollBarThickness=2,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(0,0,0,0),ZIndex=21},admSC); co(spamScroll,6)
n("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.Name},spamScroll)
local spamClosestB=n("TextButton",{Size=UDim2.fromOffset(220,28),Position=UDim2.fromOffset(10,180),BackgroundColor3=Color3.fromRGB(35,8,8),BorderSizePixel=0,Text="Spam Closest Player",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(255,80,80),AutoButtonColor=false,ZIndex=21},admSC); co(spamClosestB,8)
local spamCards={}
local function refreshSpamList()
    for _,c in pairs(spamCards) do pcall(function() c:Destroy() end) end; spamCards={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=n("Frame",{Name=p.Name,Size=UDim2.new(1,-4,0,32),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,ZIndex=22},spamScroll); co(card,6)
        n("TextLabel",{Size=UDim2.new(1,0,0.55,0),Position=UDim2.fromOffset(8,2),BackgroundTransparency=1,Text=p.DisplayName,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(200,200,225),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=23},card)
        n("TextLabel",{Size=UDim2.new(1,0,0.45,0),Position=UDim2.new(0,8,0.55,0),BackgroundTransparency=1,Text="@"..p.Name,Font=Enum.Font.Gotham,TextSize=7,TextColor3=Color3.fromRGB(80,80,110),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=23},card)
        local pb=n("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=24},card)
        local pd=p; pb.MouseButton1Click:Connect(function() for _,cmd in ipairs({"balloon","tiny","rocket","inverse","jumpscare","morph"}) do aFire(pd,cmd); rowCdEnd[cmd]=tick()+(ROW_CD[cmd] or 30); task.wait(0.05) end end)
        spamCards[p.UserId]=card
    end
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshSpamList() end); Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshSpamList() end); task.delay(2,refreshSpamList)
spamClosestB.MouseButton1Click:Connect(function()
    local char=lp.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); if h then local d=(h.Position-hrp.Position).Magnitude; if d<bd then bd=d; best=p end end end end
    if best then for _,cmd in ipairs({"balloon","tiny","rocket","inverse","jumpscare","morph"}) do aFire(best,cmd); rowCdEnd[cmd]=tick()+(ROW_CD[cmd] or 30); task.wait(0.05) end end
end)

-- Flash TP panel (popup)
local flashPop,flashC=makePopup(230,130,"Flash TP Settings")
local ftRow=n("Frame",{Size=UDim2.fromOffset(210,22),Position=UDim2.fromOffset(10,6),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,ZIndex=21},flashC); co(ftRow,7)
n("TextLabel",{Size=UDim2.new(1,-50,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,Text="Flash TP",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=flashEnabled and Color3.fromRGB(220,220,245) or Color3.fromRGB(120,120,145),ZIndex=22,TextXAlignment=Enum.TextXAlignment.Left},ftRow)
local ftTrack=n("Frame",{Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-46,0.5,-11),BackgroundColor3=flashEnabled and Color3.fromRGB(80,200,120) or Color3.fromRGB(28,28,40),BorderSizePixel=0,ZIndex=22},ftRow); co(ftTrack,11)
local ftKnob=n("Frame",{Size=UDim2.fromOffset(18,18),Position=flashEnabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),BackgroundColor3=Color3.fromRGB(240,240,255),BorderSizePixel=0,ZIndex=23},ftTrack); co(ftKnob,9)
local ftB=n("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=23},ftRow)
local function updFl(v) flashEnabled=v; TweenService:Create(ftTrack,TweenInfo.new(0.12),{BackgroundColor3=v and Color3.fromRGB(80,200,120) or Color3.fromRGB(28,28,40)}):Play(); TweenService:Create(ftKnob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play(); Cfg.flashOn=v; save() end
ftB.MouseButton1Click:Connect(function() updFl(not flashEnabled) end)
local trgLbl=n("TextLabel",{Size=UDim2.fromOffset(210,12),Position=UDim2.fromOffset(10,34),BackgroundTransparency=1,Text="Trigger: "..math.floor(sliderValue*100).."%",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(140,140,180),ZIndex=21,TextXAlignment=Enum.TextXAlignment.Left},flashC)
local slBg=n("Frame",{Size=UDim2.fromOffset(210,5),Position=UDim2.fromOffset(10,50),BackgroundColor3=Color3.fromRGB(22,22,36),BorderSizePixel=0,ZIndex=21},flashC); co(slBg,3)
local slFill=n("Frame",{Size=UDim2.new(sliderValue,0,1,0),BackgroundColor3=Color3.fromRGB(140,100,255),BorderSizePixel=0,ZIndex=22},slBg); co(slFill,3)
local slKn=n("Frame",{Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(sliderValue,0,0.5,0),BackgroundColor3=Color3.fromRGB(240,240,255),BorderSizePixel=0,ZIndex=23},slBg); co(slKn,6)
local slOn=false
local function setTr(pct) pct=math.clamp(pct,0,1); sliderValue=pct; Cfg.triggerChance=math.floor(pct*100); slFill.Size=UDim2.new(pct,0,1,0); slKn.Position=UDim2.new(pct,0,0.5,0); trgLbl.Text="Trigger: "..math.floor(pct*100).."%" end
slBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slOn=true; setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and slOn then slOn=false; save() end end)
UIS.InputChanged:Connect(function(i) if not slOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
local camBusy=false; local alignB=n("TextButton",{Size=UDim2.fromOffset(210,26),Position=UDim2.fromOffset(10,62),BackgroundColor3=Color3.fromRGB(16,16,26),BorderSizePixel=0,Text="Align Camera",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(180,180,220),AutoButtonColor=false,ZIndex=21},flashC); co(alignB,8)
alignB.MouseButton1Click:Connect(function() if camBusy then return end; camBusy=true; alignB.Text="Aligning..."; pcall(equipFlash); task.wait(0.05); pcall(alignCam); task.delay(1,function() alignB.Text="Align Camera"; camBusy=false end) end)
n("TextLabel",{Size=UDim2.fromOffset(210,14),Position=UDim2.fromOffset(10,96),BackgroundTransparency=1,Text="91% is best. Requires good FPS.",Font=Enum.Font.Gotham,TextSize=8,TextColor3=Color3.fromRGB(70,70,100),ZIndex=21,TextXAlignment=Enum.TextXAlignment.Left},flashC)

-- ════ LIMITED HUB KEYBIND (Ice Hub / Irish Reset style) ════
local boundKey=Enum.KeyCode.Q; local kbListening=false
local kbFrame=n("Frame",{Size=UDim2.fromOffset(180,46),Position=UDim2.fromOffset(8,math.floor(vp.Y*0.5)+36),BackgroundColor3=Color3.fromRGB(12,12,20),BorderSizePixel=0,ZIndex=15},SG)
co(kbFrame,10); addStroke(kbFrame,1.2,Color3.fromRGB(80,80,140),0.25)
n("TextLabel",{Size=UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text="Limited Hub",Font=Enum.Font.GothamBlack,TextSize=11,TextColor3=Color3.fromRGB(200,200,235),ZIndex=16,TextXAlignment=Enum.TextXAlignment.Left},kbFrame)
n("TextLabel",{Size=UDim2.new(1,-10,0,12),Position=UDim2.new(0,10,1,-15),BackgroundTransparency=1,Text="Instant Reset (RClick to rebind)",Font=Enum.Font.Gotham,TextSize=7,TextColor3=Color3.fromRGB(70,70,100),ZIndex=16,TextXAlignment=Enum.TextXAlignment.Left},kbFrame)
local kbBtn=n("TextButton",{Size=UDim2.fromOffset(44,34),Position=UDim2.new(1,-50,0.5,-17),BackgroundColor3=Color3.fromRGB(38,38,55),BorderSizePixel=0,Text="Q",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.fromRGB(255,215,0),AutoButtonColor=false,ZIndex=17},kbFrame); co(kbBtn,8)
local function flashKB() TweenService:Create(kbBtn,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(0,180,80)}):Play(); task.delay(0.35,function() TweenService:Create(kbBtn,TweenInfo.new(0.25),{BackgroundColor3=Color3.fromRGB(38,38,55)}):Play() end) end
kbBtn.MouseButton1Click:Connect(function() flashKB(); task.spawn(doReset) end)
kbBtn.MouseButton2Click:Connect(function() kbListening=true; kbBtn.Text="..." end)
UIS.InputBegan:Connect(function(input,gpe)
    if kbListening and input.UserInputType==Enum.UserInputType.Keyboard then
        kbListening=false; boundKey=input.KeyCode; kbBtn.Text=boundKey.Name; return
    end
    if not gpe and input.KeyCode==boundKey then flashKB(); task.spawn(doReset) end
end)
-- Drag keybind frame
do local on,ds,sp=false,nil,nil; kbFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=true; ds=i.Position; sp=kbFrame.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then on=false end end) end end); UIS.InputChanged:Connect(function(i) if not on then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-ds; kbFrame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end) end

-- ════ TAB 1: MAIN ════
section(tabs[1],"Auto Grab")
local agPB,agSet=togRow(tabs[1],"Auto Grab (New)",Color3.fromRGB(80,200,120),grabEnabled)
agPB.MouseButton1Click:Connect(function() grabEnabled=not grabEnabled; Cfg.grabOn=grabEnabled; save(); agSet(grabEnabled) end)
local agOldPB,agOldSet=togRow(tabs[1],"Auto Grab (Old - not working)",Color3.fromRGB(100,100,140))
local flashRowPB=actionRow(tabs[1],"Flash TP Settings","  >"); flashRowPB.MouseButton1Click:Connect(function() flashPop.Visible=not flashPop.Visible end)
section(tabs[1],"Potions")
local potPB,potSet=togRow(tabs[1],"Auto Giant Potion",Color3.fromRGB(255,160,40),potionOn)
potPB.MouseButton1Click:Connect(function() potionOn=not potionOn; Cfg.potionOn=potionOn; save(); potSet(potionOn) end)
local gpsOn=false; local gpsPB,gpsSet=togRow(tabs[1],"Giant Potion Speed",Color3.fromRGB(255,160,40))
gpsPB.MouseButton1Click:Connect(function() gpsOn=not gpsOn; gpsSet(gpsOn) end)
section(tabs[1],"Base")
local function unlockFloor(fl)
    task.spawn(function() pcall(function() local plots=workspace:FindFirstChild("Plots"); if not plots then return end; for _,plot in ipairs(plots:GetChildren()) do local sign=plot:FindFirstChild("PlotSign"); if not sign then continue end; local tl=sign:FindFirstChild("TextLabel",true); if not tl then continue end; if tl.Text:lower():find(lp.Name:lower(),1,true) then for _,desc in ipairs(plot:GetDescendants()) do if desc:IsA("ProximityPrompt") and desc.Enabled and (desc.ActionText:lower():find("unlock") or desc.ActionText:lower():find("floor "..fl) or desc.ActionText:lower():find("upgrade")) then pcall(function() fireproximityprompt(desc) end) end end end end end) end)
end
local ubFlRow=n("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.fromRGB(14,14,22),BorderSizePixel=0,LayoutOrder=#tabs[1]:GetChildren()+1},tabs[1]); co(ubFlRow,8)
n("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text="Unlock Base",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(160,160,185),TextXAlignment=Enum.TextXAlignment.Left},ubFlRow)
for fl=1,3 do local fb=n("TextButton",{Size=UDim2.fromOffset(42,22),Position=UDim2.new(0.42+(fl-1)*0.18,0,0.5,-11),BackgroundColor3=Color3.fromRGB(22,22,38),BorderSizePixel=0,Text="Floor "..fl,Font=Enum.Font.GothamBold,TextSize=8,TextColor3=Color3.fromRGB(160,160,210),AutoButtonColor=false},ubFlRow); co(fb,6); local f=fl; fb.MouseButton1Click:Connect(function() unlockFloor(f) end) end

-- ════ TAB 2: VISUAL ════
section(tabs[2],"Optimizer")
local fpsOn=true; local fpsPB,fpsSet=togRow(tabs[2],"FPS Boost",Color3.fromRGB(80,200,120),true)
fpsPB.MouseButton1Click:Connect(function() fpsOn=not fpsOn; fpsSet(fpsOn)
    if fpsOn then
        pcall(function() Lighting.GlobalShadows=false end)
        for _,v in pairs(Lighting:GetDescendants()) do pcall(function() if v:IsA("PostEffect") then v.Enabled=false end end) end
        for _,p in ipairs(Players:GetPlayers()) do if p.Character then for _,d in ipairs(p.Character:GetDescendants()) do pcall(function() if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then d.Enabled=false end end) end end end
    else pcall(function() Lighting.GlobalShadows=true end) end
end)
local gsOn=false; local gsPB,gsSet=togRow(tabs[2],"Game Stretcher",Color3.fromRGB(140,100,255))
gsPB.MouseButton1Click:Connect(function() gsOn=not gsOn; gsSet(gsOn); FOV_LOCK=gsOn and 115 or 70 end)
sliderRow(tabs[2],"Camera FOV",70,180,70,function(v) FOV_LOCK=v end)

section(tabs[2],"Visual")
local antiBeeOn=true; local abPB,abSet=togRow(tabs[2],"Anti Bee",Color3.fromRGB(255,200,40),true)
abPB.MouseButton1Click:Connect(function() antiBeeOn=not antiBeeOn; abSet(antiBeeOn) end)
local xrOn=false; local xrPB,xrSet=togRow(tabs[2],"X-Ray (Bases/Brainrots)",Color3.fromRGB(80,200,255))
xrPB.MouseButton1Click:Connect(function() xrOn=not xrOn; xrSet(xrOn)
    for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") then local nm=obj.Name:lower(); if nm:find("floor") or nm:find("wall") or nm:find("base") or nm:find("plot") then pcall(function() obj.LocalTransparencyModifier=xrOn and 0.72 or 0 end) end end end
end)

section(tabs[2],"ESP")
local pEspPB,pEspSet=togRow(tabs[2],"Player ESP",Color3.fromRGB(200,200,255))
local ESPTAG="AeE_"..tostring(math.random(1000,9999))
local function mkESP(plr) if plr==lp then return end; local char=plr.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end; local box=Instance.new("BoxHandleAdornment",char); box.Name=ESPTAG; box.Adornee=hrp; box.Size=Vector3.new(4,6,2); box.Color3=Color3.fromRGB(200,200,255); box.Transparency=0.5; box.ZIndex=10; box.AlwaysOnTop=true; local bb=Instance.new("BillboardGui",char); bb.Name=ESPTAG.."N"; bb.Adornee=char:FindFirstChild("Head") or hrp; bb.Size=UDim2.fromOffset(130,24); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true; local bgE=Instance.new("Frame",bb); bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=Color3.fromRGB(5,5,10); bgE.BackgroundTransparency=0.22; bgE.BorderSizePixel=0; local c2=Instance.new("UICorner",bgE); c2.CornerRadius=UDim.new(0,5); addStroke(bgE,1,Color3.fromRGB(180,180,255),0.25); n("TextLabel",{Size=UDim2.new(1,0,0.58,0),BackgroundTransparency=1,Text=plr.DisplayName,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(200,200,255)},bgE); n("TextLabel",{Size=UDim2.new(1,0,0.42,0),Position=UDim2.new(0,0,0.58,0),BackgroundTransparency=1,Text="@"..plr.Name,Font=Enum.Font.Gotham,TextSize=7,TextColor3=Color3.fromRGB(100,100,130)},bgE) end
local espActive=false
pEspPB.MouseButton1Click:Connect(function() espActive=not espActive; pEspSet(espActive); if espActive then for _,p in ipairs(Players:GetPlayers()) do task.defer(function() mkESP(p) end) end else for _,p in ipairs(Players:GetPlayers()) do if p.Character then for _,v in ipairs(p.Character:GetChildren()) do if v.Name==ESPTAG or v.Name==ESPTAG.."N" then v:Destroy() end end end end end end)
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); if espActive then mkESP(p) end end) end)

local brainESP=false; local brainPB,brainSet=togRow(tabs[2],"Brainrot ESP",Color3.fromRGB(255,180,80))
brainPB.MouseButton1Click:Connect(function() brainESP=not brainESP; brainSet(brainESP) end)

local mineESP2=false; local minePB,mineSet=togRow(tabs[2],"Mine ESP",Color3.fromRGB(255,80,80))
minePB.MouseButton1Click:Connect(function() mineESP2=not mineESP2; mineSet(mineESP2) end)

local cloneESP=false; local clonePB,cloneSet=togRow(tabs[2],"Clone ESP (Quantum Cloner)",Color3.fromRGB(180,80,255))
clonePB.MouseButton1Click:Connect(function() cloneESP=not cloneESP; cloneSet(cloneESP) end)

local timerESP=true; local timerPB,timerSet=togRow(tabs[2],"Timer ESP",Color3.fromRGB(255,220,40),true)
timerPB.MouseButton1Click:Connect(function() timerESP=not timerESP; timerSet(timerESP) end)

-- Timer ESP background loop
local timerESPs={}
task.spawn(function()
    while true do task.wait(0.4)
        if not timerESP then for _,e in pairs(timerESPs) do pcall(function() e.bb:Destroy() end) end; timerESPs={}; continue end
        local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
        for _,plot in ipairs(plots:GetChildren()) do
            local pur=plot:FindFirstChild("Purchases"); local pb2=pur and pur:FindFirstChild("PlotBlock"); local mp=pb2 and pb2:FindFirstChild("Main")
            local tl2=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
            if tl2 and mp then
                local e=timerESPs[plot.Name]
                if not e or not e.bb.Parent then
                    if e then pcall(function() e.bb:Destroy() end) end
                    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(54,15); bb.StudsOffset=Vector3.new(0,7,0); bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
                    local bgT=Instance.new("Frame",bb); bgT.Size=UDim2.new(1,0,1,0); bgT.BackgroundColor3=Color3.fromRGB(6,6,10); bgT.BackgroundTransparency=0.18; bgT.BorderSizePixel=0; local c3=Instance.new("UICorner",bgT); c3.CornerRadius=UDim.new(0,4)
                    local stk=Instance.new("UIStroke",bgT); stk.Color=Color3.fromRGB(255,195,40); stk.Thickness=0.8; stk.Transparency=0.28
                    local tll=Instance.new("TextLabel",bgT); tll.Size=UDim2.new(1,0,1,0); tll.BackgroundTransparency=1; tll.Font=Enum.Font.GothamBold; tll.TextSize=9; tll.TextColor3=Color3.fromRGB(255,195,40)
                    timerESPs[plot.Name]={bb=bb,lbl=tll,stk=stk}; e=timerESPs[plot.Name]
                end
                e.lbl.Text=tl2.Text; local m2,s2=tl2.Text:match("(%d+):(%d+)"); if m2 and s2 then local tot=tonumber(m2)*60+tonumber(s2); local col=tot<=30 and Color3.fromRGB(255,65,65) or tot<=60 and Color3.fromRGB(255,195,40) or Color3.fromRGB(52,218,88); e.lbl.TextColor3=col; e.stk.Color=col end
            end
        end
    end
end)

-- ════ TAB 3: PLAYER ════
section(tabs[3],"Movement")
local arPB,arSet2=togRow(tabs[3],"Anti Ragdoll",Color3.fromRGB(80,200,120),true)
arPB.MouseButton1Click:Connect(function() if arConn then arConn:Disconnect(); arConn=nil; arSet2(false) else startAntiRag(); arSet2(true) end end)
local bstRowPB=actionRow(tabs[3],"Booster GUI  (Walk/Jump)"); bstRowPB.MouseButton1Click:Connect(function() bstPop.Visible=not bstPop.Visible end)
local carpetOn=false; local carpetPB,carpetSet=togRow(tabs[3],"Carpet Speed",Color3.fromRGB(255,160,40))
carpetPB.MouseButton1Click:Connect(function() carpetOn=not carpetOn; carpetSet(carpetOn)
    if carpetOn then task.spawn(function() pcall(function() local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local bp=lp:FindFirstChild("Backpack"); local names={"Flying Carpet","Witch's Broom","Santa's Sleigh","Cupid's Wings"}; for _,nm in ipairs(names) do local t=char:FindFirstChild(nm) or (bp and bp:FindFirstChild(nm)); if t then if t.Parent~=char then hum:EquipTool(t) end; return end end end) end) end
end)
local infJumpOn=false; local ijPB,ijSet=togRow(tabs[3],"Infinite Jump",Color3.fromRGB(140,100,255))
ijPB.MouseButton1Click:Connect(function() infJumpOn=not infJumpOn; ijSet(infJumpOn) end)
UIS.JumpRequest:Connect(function() if infJumpOn then local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
sliderRow(tabs[3],"Steal Speed",10,100,30,function(v) stealingSpeed=v; Cfg.spdVal=v; save() end)

section(tabs[3],"Exploit")
local arBalloonOn=false; local arBPB,arBSet=togRow(tabs[3],"Auto Reset On Balloon",Color3.fromRGB(255,80,80))
arBPB.MouseButton1Click:Connect(function() arBalloonOn=not arBalloonOn; arBSet(arBalloonOn) end)
local function watchHead(char) local head=char:FindFirstChild("Head"); if not head then return end; head:GetPropertyChangedSignal("Size"):Connect(function() if arBalloonOn and head.Size.Y>5 then task.wait(0.1); task.spawn(doReset) end end) end
lp.CharacterAdded:Connect(function(char) task.wait(0.5); watchHead(char) end); if lp.Character then task.spawn(function() watchHead(lp.Character) end) end

local atPB,atSet2=togRow(tabs[3],"Anti Turret / Sentry",Color3.fromRGB(80,200,120),true)
atPB.MouseButton1Click:Connect(function() antiSentryOn=not antiSentryOn; atSet2(antiSentryOn) end)

local solOn=false; local solPB,solSet=togRow(tabs[3],"Aimbot (Solar)",Color3.fromRGB(255,80,80))
local solRemote=nil; task.spawn(function() pcall(function() local net=RS:WaitForChild("Packages",5); if not net then return end; net=net:FindFirstChild("Net"); if not net then return end; for _,obj in ipairs(net:GetChildren()) do if obj.Name=="RE/UseItem" then solRemote=net:GetChildren()[_+1]; break end end end) end)
solPB.MouseButton1Click:Connect(function() solOn=not solOn; solSet(solOn) end)
RunService.Heartbeat:Connect(function() if not solOn or not solRemote then return end; local char=lp.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local best,bd=nil,350; for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); if h then local d=(h.Position-hrp.Position).Magnitude; if d<bd then bd=d; best=p end end end end; if best and best.Character then local h=best.Character:FindFirstChild("HumanoidRootPart"); if h then pcall(function() solRemote:FireServer(h.Position,h) end) end end end)

local stolOn=false; local stolPB,stolSet=togRow(tabs[3],"Steal On Leave",Color3.fromRGB(255,140,40))
stolPB.MouseButton1Click:Connect(function() stolOn=not stolOn; stolSet(stolOn) end)
Players.PlayerRemoving:Connect(function() if not stolOn then return end; task.spawn(function() local plots=workspace:FindFirstChild("Plots"); if not plots then return end; for _,plot in ipairs(plots:GetChildren()) do for _,desc in ipairs(plot:GetDescendants()) do if desc:IsA("ProximityPrompt") and (desc.ActionText=="Steal") and desc.Enabled then pcall(function() fireproximityprompt(desc) end) end end end end) end)

local mineBtn=actionRow(tabs[3],"Place Subspace Mine")
mineBtn.MouseButton1Click:Connect(function() task.spawn(function() pcall(function() local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local bp=lp:FindFirstChild("Backpack"); local mine=char:FindFirstChild("Subspace Mine") or (bp and bp:FindFirstChild("Subspace Mine")); if not mine then return end; if mine.Parent~=char then hum:EquipTool(mine) end; task.wait(0.1); mine:Activate() end) end) end)

-- Carpet speed heartbeat
RunService.Heartbeat:Connect(function() if not carpetOn then return end; local char=lp.Character; if not char then return end; local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid"); if not root or not hum then return end; if hum.MoveDirection.Magnitude>0 then root.Velocity=Vector3.new(hum.MoveDirection.X*50,root.Velocity.Y,hum.MoveDirection.Z*50) end end)
-- Speed heartbeat
RunService.Heartbeat:Connect(function() if not speedEnabled then return end; applySpeed() end)

-- ════ TAB 4: UTILS ════
section(tabs[4],"Admin Panel")
local apRowPB=actionRow(tabs[4],"Quick Admin Panel"); apRowPB.MouseButton1Click:Connect(function() admSPop.Visible=not admSPop.Visible end)
local cdRowPB=actionRow(tabs[4],"Command Cooldowns"); cdRowPB.MouseButton1Click:Connect(function() cdPop.Visible=not cdPop.Visible end)

section(tabs[4],"Protection")
local defRowPB=actionRow(tabs[4],"Defense Panel"); defRowPB.MouseButton1Click:Connect(function() defPop.Visible=not defPop.Visible end)
local asU,asUSet=togRow(tabs[4],"Anti Steal",Color3.fromRGB(80,200,120)); asU.MouseButton1Click:Connect(function() antiSteal=not antiSteal; asUSet(antiSteal) end)
local aiU,aiUSet=togRow(tabs[4],"Anti Intruder",Color3.fromRGB(255,160,40)); aiU.MouseButton1Click:Connect(function() antiIntruder=not antiIntruder; aiUSet(antiIntruder) end)
local akU,akUSet=togRow(tabs[4],"Auto Kick",Color3.fromRGB(255,80,80)); akU.MouseButton1Click:Connect(function() autoKick=not autoKick; akUSet(autoKick) end)
local atpU,atpUSet=togRow(tabs[4],"Anti TP",Color3.fromRGB(255,140,40)); atpU.MouseButton1Click:Connect(function() antiTp=not antiTp; atpUSet(antiTp) end)

section(tabs[4],"Other")
local actRowPB=actionRow(tabs[4],"Actions Panel"); actRowPB.MouseButton1Click:Connect(function() actPop.Visible=not actPop.Visible end)
local allowPB=actionRow(tabs[4],"Allow/Disallow Friends")
allowPB.MouseButton1Click:Connect(function()
    task.spawn(function() pcall(function() local plots=workspace:FindFirstChild("Plots"); if not plots then return end; for _,plot in ipairs(plots:GetChildren()) do local sign=plot:FindFirstChild("PlotSign"); if not sign then continue end; local tl=sign:FindFirstChild("TextLabel",true); if not tl then continue end; if tl.Text:lower():find(lp.Name:lower(),1,true) then for _,desc in ipairs(plot:GetDescendants()) do if desc:IsA("ProximityPrompt") and (desc.ObjectText=="Allow Friends" or desc.ObjectText=="Disallow Friends") then pcall(function() fireprompt(desc) end) end end end end end) end)
end)
local qcPB=actionRow(tabs[4],"Quantum Cloner ESP"); qcPB.MouseButton1Click:Connect(function() cloneESP=not cloneESP; cloneSet(cloneESP) end)
local lhPB=actionRow(tabs[4],"Limited Hub (Instant Reset)",Color3.fromRGB(180,180,255)); lhPB.MouseButton1Click:Connect(function() task.spawn(doReset) end)
local mineU=actionRow(tabs[4],"Place Subspace Mine"); mineU.MouseButton1Click:Connect(function() task.spawn(function() pcall(function() local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local bp=lp:FindFirstChild("Backpack"); local mine=char:FindFirstChild("Subspace Mine") or (bp and bp:FindFirstChild("Subspace Mine")); if not mine then return end; if mine.Parent~=char then hum:EquipTool(mine) end; task.wait(0.1); mine:Activate() end) end) end)

print("Aethen Hub v0.9  |  @r9qbx  |  discord.gg/hyZGbJP9")
