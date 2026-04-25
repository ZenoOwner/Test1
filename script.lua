-- ================================================================
-- PHANTOM HUB - Combined Script
-- Semi TP + Base Protector + AP Spam
-- Made by Phantom / r9qbx on discord
-- ================================================================
task.spawn(function()
pcall(function()
repeat task.wait() until game:IsLoaded()

local Players    = game:GetService("Players")
local TweenSvc   = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local PPS        = game:GetService("ProximityPromptService")
local RepSto     = game:GetService("ReplicatedStorage")
local TpSvc      = game:GetService("TeleportService")
local CoreGui    = game:GetService("CoreGui")
local lp         = Players.LocalPlayer
local isMobile   = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ================================================================
-- COLORS
-- ================================================================
local C = {
    BG    = Color3.fromRGB(7,6,12),
    CARD  = Color3.fromRGB(11,9,20),
    CARD2 = Color3.fromRGB(16,13,28),
    BORD  = Color3.fromRGB(42,32,72),
    TEXT  = Color3.fromRGB(228,220,248),
    DIM   = Color3.fromRGB(100,88,135),
    PURP  = Color3.fromRGB(155,70,240),
    PURPL = Color3.fromRGB(205,135,255),
    PURPD = Color3.fromRGB(28,12,55),
    TEAL  = Color3.fromRGB(45,210,185),
    ROSE  = Color3.fromRGB(238,60,155),
    GRN   = Color3.fromRGB(52,228,92),
    RED   = Color3.fromRGB(255,52,76),
    ORG   = Color3.fromRGB(255,140,32),
    GOLD  = Color3.fromRGB(255,196,42),
    OFF   = Color3.fromRGB(20,18,36),
    WHITE = Color3.new(1,1,1),
}

local function tw(o,p,t,s)
    TweenSvc:Create(o,TweenInfo.new(t or 0.13,s or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play()
end
local function lp2(o,p,t)
    TweenSvc:Create(o,TweenInfo.new(t or 2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),p):Play()
end
local function co(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 8) end
local function stk(p,col,t,tr)
    local s=Instance.new("UIStroke",p) s.Color=col s.Thickness=t or 1 s.Transparency=tr or 0.3 return s
end

local touchMoved=false local tsp=Vector2.zero
UIS.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then touchMoved=false tsp=Vector2.new(i.Position.X,i.Position.Y) end
end)
UIS.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then
        if(Vector2.new(i.Position.X,i.Position.Y)-tsp).Magnitude>14 then touchMoved=true end
    end
end)
local function sc(btn,fn)
    btn.MouseButton1Click:Connect(function() if isMobile and touchMoved then return end fn() end)
end
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
            local d=i.Position-dgs
            if d.Magnitude>5 then f.Position=UDim2.new(dsp.X.Scale,dsp.X.Offset+d.X,dsp.Y.Scale,dsp.Y.Offset+d.Y) end
        end
    end)
end

-- GUI cleanup
local GN="PhHub_"..tostring(math.random(10000,99999))
pcall(function()
    for _,v in ipairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:sub(1,6)=="PhHub_" then v:Destroy() end
    end
end)
local sg=Instance.new("ScreenGui")
sg.Name=GN sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999
local _=pcall(function() sg.Parent=CoreGui end)
if not sg.Parent then sg.Parent=lp:WaitForChild("PlayerGui") end

-- ================================================================
-- SEMI TP STATE
-- ================================================================
local semiTPOn       = false
local speedStealOn   = false
local potionOnTP     = false
local stealSpeedVal  = 29
local IsStealing     = false
local StealProg      = 0

local POS1 = Vector3.new(-352.98,-7,74.30)
local POS2 = Vector3.new(-352.98,-6.49,45.76)
local SEQ1 = {
    CFrame.new(-370.810913,-7.00000334,41.2687263,0.99984771,1.22364419e-09,0.0174523517,-6.54859778e-10,1,-3.2596418e-08,-0.0174523517,3.25800258e-08,0.99984771),
    CFrame.new(-336.355286,-5.10107088,17.2327671,-0.999883354,-2.76150569e-08,0.0152716246,-2.88224964e-08,1,-7.88441525e-08,-0.0152716246,-7.9275118e-08,-0.999883354)
}
local SEQ2 = {
    CFrame.new(-354.782867,-7.00000334,92.8209305,-0.999997616,-1.11891862e-09,-0.00218066527,-1.11958298e-09,1,3.03415071e-10,0.00218066527,3.05855785e-10,-0.999997616),
    CFrame.new(-336.942902,-5.10106993,99.3276443,0.999914348,-3.63984611e-08,0.0130875716,3.67094941e-08,1,-2.35254749e-08,-0.0130875716,2.40038975e-08,0.999914348)
}

-- ================================================================
-- PROTECTOR STATE
-- ================================================================
local _c = {
    Mode="None", BorderKick=false, AutoRejoin=false,
    MyPlot=nil, StealHitbox=nil, AdminRemote=nil,
    LastPunishTime={}, CarpetSpammed={},
}
local CARPET={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true}
local ADM="f888ee6e-c86d-46e1-93d7-0639d6635d42"

local function fA(...)
    if not _c.AdminRemote then return end
    local a={...}
    task.spawn(function() pcall(function() _c.AdminRemote:InvokeServer(unpack(a)) end) end)
end

local function doRejoin()
    pcall(function()
        TpSvc:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end)
end

local function punish(p)
    if not _c.AdminRemote or not p or p==lp then return end
    local char=p.Character if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local uid=p.UserId
    if _c.LastPunishTime[uid] and tick()-_c.LastPunishTime[uid]<2 then return end
    _c.LastPunishTime[uid]=tick()
    hrp.CFrame=CFrame.new(0,10000,0)
    fA(ADM,p,"balloon") fA(ADM,p,"ragdoll")
    if _c.AutoRejoin then
        task.delay(1.8, doRejoin)
    end
end

local function checkHB()
    local hb=_c.StealHitbox if not hb then return end
    local cf,sz=hb.CFrame,hb.Size local hx,hz=sz.X*0.5,sz.Z*0.5
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local rel=cf:PointToObjectSpace(hrp.Position)
                if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then
                    for _,item in ipairs(p.Character:GetChildren()) do
                        if CARPET[item.Name] then punish(p) break end
                    end
                end
            end
        end
    end
end

-- Find admin remote
task.spawn(function()
    if not lp.Character then lp.CharacterAdded:Wait() end
    task.wait(1.2)
    pcall(function()
        local net=RepSto:WaitForChild("Packages"):WaitForChild("Net")
        local ch=net:GetChildren() local byIdx,byName={},{}
        for i,o in ipairs(ch) do byIdx[i]=o byName[o.Name]=i end
        local ai=byName["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
        if ai then local ac=byIdx[ai+1] if ac then _c.AdminRemote=ac end end
    end)
    pcall(function()
        for _,obj in ipairs(RepSto:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                obj.OnClientEvent:Connect(function(...)
                    if _c.Mode=="None" or not _c.AdminRemote or not _c.MyPlot then return end
                    for _,a in ipairs({...}) do
                        if type(a)=="string" and a:lower():find("stealing") then
                            local mh=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                            if not mh then return end
                            local best,bd=nil,math.huge
                            for _,p in ipairs(Players:GetPlayers()) do
                                if p~=lp and p.Character then
                                    local h=p.Character:FindFirstChild("HumanoidRootPart")
                                    if h then local d=(h.Position-mh.Position).Magnitude if d<bd then bd=d best=p end end
                                end
                            end
                            if best then punish(best) end return
                        end
                    end
                end)
            end
        end
    end)
end)

-- Hook fireproximityprompt for anti-steal
task.spawn(function()
    pcall(function()
        if not (hookfunction and fireproximityprompt) then return end
        local _old=fireproximityprompt
        hookfunction(fireproximityprompt, newcclosure(function(prompt,...)
            if _c.Mode~="None" then
                local at=(prompt.ActionText or ""):lower()
                local ot=(prompt.ObjectText or ""):lower()
                if at:find("steal") or ot:find("steal") then
                    local part=prompt.Parent
                    if part and part:IsA("BasePart") then
                        local pos=part.Position local best,bd=nil,math.huge
                        for _,p in ipairs(Players:GetPlayers()) do
                            if p~=lp and p.Character then
                                local h=p.Character:FindFirstChild("HumanoidRootPart")
                                if h then local d=(h.Position-pos).Magnitude if d<bd then bd=d best=p end end
                            end
                        end
                        if best and bd<20 then punish(best) end
                    end
                    checkHB()
                end
            end
            return _old(prompt,...)
        end))
    end)
    pcall(function()
        if not (hookfunction and newcclosure) then return end
        local _oF=Instance.FireServer
        hookfunction(Instance.FireServer, newcclosure(function(self,...)
            if _c.Mode~="None" and _c.StealHitbox then checkHB() end
            return _oF(self,...)
        end))
    end)
end)

-- Plot scanner
task.spawn(function()
    while task.wait(0.6) do pcall(function()
        local plots=workspace:FindFirstChild("Plots") if not plots or _c.MyPlot then return end
        for _,p in ipairs(plots:GetChildren()) do
            local sign=p:FindFirstChild("PlotSign") if not sign then continue end
            local lbl=sign:FindFirstChild("TextLabel",true) if not lbl then continue end
            local t=lbl.Text:lower()
            if t:find(lp.Name:lower()) or t:find(lp.DisplayName:lower()) then
                _c.MyPlot=p _c.StealHitbox=p:FindFirstChild("StealHitbox",true) break
            end
        end
    end) end
end)

-- Anti Intruder heartbeat
RunService.Heartbeat:Connect(function()
    if not _c.BorderKick or not _c.StealHitbox or not _c.AdminRemote then return end
    local cf,sz=_c.StealHitbox.CFrame,_c.StealHitbox.Size
    local hx,hz=sz.X*0.5,sz.Z*0.5
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local rel=cf:PointToObjectSpace(hrp.Position)
                if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then
                    for _,item in ipairs(p.Character:GetChildren()) do
                        if CARPET[item.Name] then
                            local uid=p.UserId
                            if not _c.CarpetSpammed[uid] then
                                _c.CarpetSpammed[uid]=true
                                fA(ADM,p,"balloon") fA(ADM,p,"jumpscare") fA(ADM,p,"rocket")
                                task.delay(5,function() _c.CarpetSpammed[uid]=nil end)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ================================================================
-- ANIMAL SCANNER + STEAL
-- ================================================================
local allAnimals={} local pCache={} local sCache={}

local function isMyPlot(n)
    local pl=workspace:FindFirstChild("Plots") if not pl then return false end
    local p=pl:FindFirstChild(n) if not p then return false end
    local sign=p:FindFirstChild("PlotSign")
    if sign then
        local yb=sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled end
    end
    return false
end

local function scanAnimals()
    local plots=workspace:FindFirstChild("Plots") if not plots then return end
    allAnimals={}
    for _,plot in ipairs(plots:GetChildren()) do
        if not isMyPlot(plot.Name) then
            local pods=plot:FindFirstChild("AnimalPodiums") if not pods then continue end
            for _,pod in ipairs(pods:GetChildren()) do
                if pod:IsA("Model") and pod:FindFirstChild("Base") then
                    local wp=pod:GetPivot().Position
                    pcall(function()
                        local att=pod.Base:FindFirstChild("Spawn") and pod.Base.Spawn:FindFirstChild("PromptAttachment")
                        if att then wp=att.WorldPosition end
                    end)
                    table.insert(allAnimals,{
                        plot=plot.Name, slot=pod.Name,
                        worldPosition=wp, uid=plot.Name.."_"..pod.Name
                    })
                end
            end
        end
    end
end
task.spawn(function() while task.wait(3) do scanAnimals() end end)

local function findPrompt(a)
    if pCache[a.uid] and pCache[a.uid].Parent then return pCache[a.uid] end
    pcall(function()
        local plot=workspace.Plots:FindFirstChild(a.plot)
        local pod=plot and plot.AnimalPodiums:FindFirstChild(a.slot)
        local pr=pod and pod.Base.Spawn.PromptAttachment:FindFirstChildOfClass("ProximityPrompt")
        if pr then pCache[a.uid]=pr end
    end)
    return pCache[a.uid]
end

local function buildCB(prompt)
    if sCache[prompt] then return end
    local data={hold={},trigger={},ready=true}
    local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then
        for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end
    end
    local ok2,c2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(c2)=="table" then
        for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trigger,c.Function) end end
    end
    if #data.hold>0 or #data.trigger>0 then sCache[prompt]=data end
end

local function getHRP()
    local char=lp.Character if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getNearestAnimal()
    local hrp=getHRP() if not hrp then return nil end
    local best,dist=nil,200
    for _,a in ipairs(allAnimals) do
        local d=(hrp.Position-a.worldPosition).Magnitude
        if d<dist then dist=d best=a end
    end
    return best
end

local _fpp=fireproximityprompt
local function safeFirePrompt(p) pcall(_fpp,p,0) end

local function activatePotion()
    pcall(function()
        local bp=lp:FindFirstChild("Backpack") if not bp then return end
        local pot=bp:FindFirstChild("Giant Potion") if not pot then return end
        local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") if not hum then return end
        hum:EquipTool(pot)
        task.wait(0.03)
        pot:Activate()
    end)
end

local function doSteal(prompt, animal, seq)
    if not prompt or not prompt.Parent then return false end
    buildCB(prompt)
    local data=sCache[prompt]
    if not data or not data.ready then return false end
    data.ready=false IsStealing=true StealProg=0

    task.spawn(function()
        -- Fire hold callbacks to start steal
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        local t0=tick() local tpDone=false local dur=1.2

        while tick()-t0 < dur do
            StealProg = (tick()-t0)/dur

            -- At 73% progress, TP and activate potion
            if StealProg >= 0.73 and not tpDone then
                tpDone=true
                local hrp=getHRP()
                if hrp then
                    hrp.CFrame=seq[1]
                    task.wait(0.07)
                    hrp.CFrame=seq[2]
                    task.wait(0.15)
                    local d1=(hrp.Position-POS1).Magnitude
                    local d2=(hrp.Position-POS2).Magnitude
                    hrp.CFrame=CFrame.new(d1<d2 and POS1 or POS2)
                    -- Giant potion activates right as we land, before grab fires
                    if potionOnTP then activatePotion() end
                end
            end

            -- Speed after steal: applied per frame while stealing
            if speedStealOn then
                pcall(function()
                    local char=lp.Character if not char then return end
                    local hum=char:FindFirstChildOfClass("Humanoid")
                    local hrp2=char:FindFirstChild("HumanoidRootPart")
                    if hum and hrp2 then
                        local dir=hum.MoveDirection
                        if dir.Magnitude > 0 then
                            local vel=hrp2.AssemblyLinearVelocity
                            local spd=stealSpeedVal
                            local grounded=workspace:Raycast(hrp2.Position,Vector3.new(0,-4,0),RaycastParams.new()) ~= nil
                            local curXZ=Vector3.new(vel.X,0,vel.Z)
                            local targetXZ=dir.Unit*spd
                            local lerp=grounded and 0.35 or 0.25
                            local smoothed=curXZ:Lerp(targetXZ,lerp)
                            hrp2.AssemblyLinearVelocity=Vector3.new(smoothed.X,vel.Y,smoothed.Z)
                        end
                    end
                end)
            end

            task.wait(0.04)
        end

        StealProg=1
        -- Fire trigger callbacks (actual steal)
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        safeFirePrompt(prompt)

        task.wait(0.1)
        data.ready=true
        task.wait(0.3)
        IsStealing=false StealProg=0
    end)
    return true
end

-- Semi TP hooks
local currentEqTask=nil local isHolding=false
PPS.PromptButtonHoldBegan:Connect(function(prompt,plr)
    if plr~=lp or not semiTPOn then return end
    isHolding=true
    if currentEqTask then task.cancel(currentEqTask) end
    currentEqTask=task.spawn(function()
        task.wait(1)
        if isHolding and semiTPOn then
            pcall(function()
                local bp=lp:WaitForChild("Backpack",2)
                local carpet=bp and bp:FindFirstChild("Flying Carpet")
                local hum=lp.Character and lp.Character:FindFirstChild("Humanoid")
                if carpet and hum then hum:EquipTool(carpet) end
            end)
        end
    end)
end)
PPS.PromptButtonHoldEnded:Connect(function(prompt,plr)
    if plr~=lp then return end
    isHolding=false
    if currentEqTask then task.cancel(currentEqTask) end
end)
PPS.PromptTriggered:Connect(function(prompt,plr)
    if plr~=lp or not semiTPOn then return end
    isHolding=false
    pcall(function()
        local root=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local d1=(root.Position-POS1).Magnitude
            local d2=(root.Position-POS2).Magnitude
            root.CFrame=CFrame.new(d1<d2 and POS1 or POS2)
            if potionOnTP then activatePotion() end
        end
    end)
end)

-- ================================================================
-- AP SPAM
-- ================================================================
local function fireBtn(b)
    pcall(function() for _,c in pairs(getconnections(b.MouseButton1Click)) do c:Fire() end end)
    pcall(function() for _,c in pairs(getconnections(b.Activated)) do c:Fire() end end)
end
local function findAP() return lp:WaitForChild("PlayerGui"):FindFirstChild("AdminPanel") end
local function getKwBtn(ap,kw)
    for _,o in ipairs(ap:GetDescendants()) do
        if o:IsA("TextButton") or o:IsA("ImageButton") then
            local t=""
            if o:IsA("TextButton") then t=o.Text:lower()
            else for _,c in ipairs(o:GetDescendants()) do if c:IsA("TextLabel") then t=c.Text:lower() break end end end
            if t:find(kw:lower()) then return o end
        end
    end
end
local function getPlrBtn(ap,target)
    for _,o in ipairs(ap:GetDescendants()) do
        if o:IsA("TextButton") or o:IsA("ImageButton") then
            local t=""
            if o:IsA("TextButton") then t=o.Text
            else for _,c in ipairs(o:GetDescendants()) do if c:IsA("TextLabel") then t=c.Text break end end end
            if t==target.Name or t==target.DisplayName then return o end
        end
    end
end
local AP_CMDS={"tiny","rocket","inverse","morph","jumpscare","balloon"}
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
local function spamNearest()
    local nearest=getNearestPlayer() if not nearest then return end
    task.spawn(function()
        local ap=findAP() if not ap then return end
        for _,cmd in ipairs(AP_CMDS) do
            local pb=getPlrBtn(ap,nearest) if pb then fireBtn(pb) end
            local cb=getKwBtn(ap,cmd) if cb then fireBtn(cb) end
            local pb2=getPlrBtn(ap,nearest) if pb2 then fireBtn(pb2) end
            task.wait(0.01)
        end
    end)
end

-- ================================================================
-- CIRCLE MARKERS IN WORLD
-- ================================================================
pcall(function()
    for _,v in ipairs(workspace:GetChildren()) do
        if v.Name:sub(1,6)=="PhSTP_" then v:Destroy() end
    end
end)
local function mkCircle(pos,label,col)
    pcall(function()
        local f=Instance.new("Folder",workspace) f.Name="PhSTP_"..label
        local p=Instance.new("Part",f)
        p.Shape=Enum.PartType.Ball p.Size=Vector3.new(3,3,3)
        p.Position=pos p.Anchored=true p.CanCollide=false
        p.Transparency=0.4 p.Material=Enum.Material.Neon p.Color=col p.CastShadow=false
        local bb=Instance.new("BillboardGui",p)
        bb.Size=UDim2.fromOffset(110,28) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true
        local bg=Instance.new("Frame",bb)
        bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(8,5,16)
        bg.BackgroundTransparency=0.15 bg.BorderSizePixel=0
        co(bg,5) stk(bg,col,1.2,0.2)
        local tl=Instance.new("TextLabel",bg)
        tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1
        tl.Text=label tl.Font=Enum.Font.GothamBlack tl.TextSize=12
        tl.TextColor3=Color3.new(1,1,1) tl.TextStrokeTransparency=0.3
    end)
end
mkCircle(Vector3.new(-349.325867,-7,95.003),"TP BASE 1",Color3.fromRGB(155,70,240))
mkCircle(Vector3.new(-349.560211,-7,27.054),"TP BASE 2",Color3.fromRGB(45,210,185))

-- ================================================================
-- MAIN GUI PANEL
-- ================================================================
local panel=Instance.new("Frame",sg)
panel.Size=UDim2.fromOffset(198,0)
panel.Position=UDim2.new(0.5,-99,0.5,-130)
panel.BackgroundColor3=C.BG
panel.BackgroundTransparency=0.15
panel.BorderSizePixel=0
panel.Active=true
panel.AutomaticSize=Enum.AutomaticSize.Y
co(panel,12)

local pg=Instance.new("UIGradient",panel) pg.Rotation=118
pg.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(14,9,28)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(5,5,13))
})

-- Rotating gradient stroke
local pS=stk(panel,C.WHITE,1.4,0.5)
local sGr=Instance.new("UIGradient",pS)
sGr.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.WHITE),
    ColorSequenceKeypoint.new(0.25,Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(0.5,C.PURPL),
    ColorSequenceKeypoint.new(0.75,Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(1,C.WHITE),
})
task.spawn(function() while sGr and sGr.Parent do sGr.Rotation=(sGr.Rotation+0.6)%360 task.wait(0.016) end end)

local tA=Instance.new("Frame",panel) tA.Size=UDim2.new(1,0,0,2) tA.BackgroundColor3=C.PURP tA.BorderSizePixel=0 co(tA,12)
lp2(tA,{BackgroundColor3=C.TEAL},2.5)

-- Particles inside panel
local pCont=Instance.new("Frame",panel) pCont.Size=UDim2.new(1,0,1,0) pCont.BackgroundTransparency=1 pCont.ClipsDescendants=true pCont.ZIndex=1 co(pCont,12)
task.spawn(function()
    while panel and panel.Parent do
        local p=Instance.new("Frame",pCont)
        local sz=math.random(2,3)
        p.Size=UDim2.fromOffset(sz,sz)
        p.Position=UDim2.new(math.random(),0,1.05,0)
        p.BackgroundColor3=math.random()>0.5 and Color3.fromRGB(180,60,255) or Color3.fromRGB(45,210,185)
        p.BackgroundTransparency=0.25 p.BorderSizePixel=0 p.ZIndex=1 co(p,sz)
        TweenSvc:Create(p,TweenInfo.new(math.random(3,6),Enum.EasingStyle.Linear),{
            Position=UDim2.new(p.Position.X.Scale,0,-0.08,0),BackgroundTransparency=1
        }):Play()
        task.delay(6.5,function() pcall(function() p:Destroy() end) end)
        task.wait(0.22)
    end
end)

drag(panel)
local pL=Instance.new("UIListLayout",panel) pL.SortOrder=Enum.SortOrder.LayoutOrder pL.Padding=UDim.new(0,0)
local pP=Instance.new("UIPadding",panel)
pP.PaddingLeft=UDim.new(0,8) pP.PaddingRight=UDim.new(0,8)
pP.PaddingTop=UDim.new(0,7) pP.PaddingBottom=UDim.new(0,8)

-- ================================================================
-- HEADER
-- ================================================================
local hdrF=Instance.new("Frame",panel) hdrF.Size=UDim2.new(1,0,0,24) hdrF.BackgroundTransparency=1 hdrF.BorderSizePixel=0 hdrF.LayoutOrder=1 hdrF.ZIndex=3
local hT=Instance.new("TextLabel",hdrF) hT.Size=UDim2.new(1,-22,1,0) hT.BackgroundTransparency=1 hT.ZIndex=3
hT.Text="Phantom Hub" hT.Font=Enum.Font.GothamBlack hT.TextSize=12 hT.TextColor3=C.WHITE hT.TextXAlignment=Enum.TextXAlignment.Left
lp2(hT,{TextColor3=C.PURPL},3)
local hSub=Instance.new("TextLabel",hdrF) hSub.Size=UDim2.new(1,-22,0,8) hSub.Position=UDim2.new(0,0,1,-8) hSub.BackgroundTransparency=1 hSub.ZIndex=3
hSub.Text="Phantom / r9qbx on discord" hSub.Font=Enum.Font.Gotham hSub.TextSize=6 hSub.TextColor3=C.DIM hSub.TextXAlignment=Enum.TextXAlignment.Left

local minB=Instance.new("TextButton",hdrF)
minB.Size=UDim2.fromOffset(18,18) minB.Position=UDim2.new(1,-18,0,3)
minB.BackgroundColor3=C.PURPD minB.BackgroundTransparency=0.1 minB.BorderSizePixel=0
minB.Text="-" minB.Font=Enum.Font.GothamBlack minB.TextSize=13 minB.TextColor3=C.PURPL minB.AutoButtonColor=false minB.ZIndex=4
co(minB,5) stk(minB,C.PURP,1,0.4)
minB.MouseEnter:Connect(function() tw(minB,{BackgroundTransparency=0},0.1) end)
minB.MouseLeave:Connect(function() tw(minB,{BackgroundTransparency=0.1},0.1) end)

local d0=Instance.new("Frame",panel) d0.Size=UDim2.new(1,0,0,1) d0.BackgroundColor3=C.BORD d0.BackgroundTransparency=0.35 d0.BorderSizePixel=0 d0.LayoutOrder=2 d0.ZIndex=3

-- Progress bar (always visible)
local pbFr=Instance.new("Frame",panel) pbFr.Size=UDim2.new(1,0,0,13) pbFr.BackgroundColor3=C.BG pbFr.BackgroundTransparency=0.2 pbFr.BorderSizePixel=0 pbFr.LayoutOrder=3 pbFr.ZIndex=3 co(pbFr,5)
stk(pbFr,C.PURP,1,0.45)
local pbBg=Instance.new("Frame",pbFr) pbBg.Size=UDim2.new(0.9,0,0,3) pbBg.Position=UDim2.new(0.05,0,1,-4) pbBg.BackgroundColor3=C.CARD2 pbBg.BackgroundTransparency=0.1 pbBg.BorderSizePixel=0 pbBg.ZIndex=3 co(pbBg,3)
local pbFill=Instance.new("Frame",pbBg) pbFill.Size=UDim2.new(0,0,1,0) pbFill.BackgroundColor3=C.PURP pbFill.BorderSizePixel=0 pbFill.ZIndex=3 co(pbFill,3)
local pbLbl=Instance.new("TextLabel",pbFr) pbLbl.Size=UDim2.new(1,0,0.75,0) pbLbl.BackgroundTransparency=1 pbLbl.Text="IDLE" pbLbl.Font=Enum.Font.GothamBold pbLbl.TextSize=7 pbLbl.TextColor3=C.DIM pbLbl.TextXAlignment=Enum.TextXAlignment.Center pbLbl.ZIndex=4
task.spawn(function()
    while task.wait(0.04) do
        pbFill.Size=UDim2.new(math.clamp(StealProg,0,1),0,1,0)
        if IsStealing then pbLbl.Text="STEALING" pbLbl.TextColor3=C.PURPL
        else pbLbl.Text="IDLE" pbLbl.TextColor3=C.DIM end
    end
end)

-- ================================================================
-- COLLAPSIBLE CONTENT
-- ================================================================
local COL_H=272
local colClip=Instance.new("Frame",panel)
colClip.Size=UDim2.new(1,0,0,COL_H) colClip.BackgroundTransparency=1 colClip.BorderSizePixel=0
colClip.ClipsDescendants=true colClip.LayoutOrder=4 colClip.ZIndex=3
local colInner=Instance.new("Frame",colClip)
colInner.Size=UDim2.new(1,0,0,COL_H) colInner.BackgroundTransparency=1 colInner.BorderSizePixel=0 colInner.ZIndex=3
local cL=Instance.new("UIListLayout",colInner) cL.SortOrder=Enum.SortOrder.LayoutOrder cL.Padding=UDim.new(0,4)
local cP=Instance.new("UIPadding",colInner) cP.PaddingTop=UDim.new(0,5)

-- Section label helper
local function mkSec(txt,order)
    local l=Instance.new("TextLabel",colInner) l.Size=UDim2.new(1,0,0,11) l.BackgroundTransparency=1 l.LayoutOrder=order l.ZIndex=4
    l.Text=txt l.Font=Enum.Font.GothamBold l.TextSize=7 l.TextColor3=C.DIM l.TextXAlignment=Enum.TextXAlignment.Left
end

-- Pill toggle helper
local function mkTog(label,accent,order,cb)
    local row=Instance.new("Frame",colInner)
    row.Size=UDim2.new(1,0,0,22) row.BackgroundColor3=C.CARD row.BackgroundTransparency=0.22
    row.BorderSizePixel=0 row.LayoutOrder=order row.ZIndex=3 co(row,7)
    local rs=stk(row,C.BORD,1,0.6)
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(1,-42,1,0) lbl.Position=UDim2.fromOffset(6,0) lbl.BackgroundTransparency=1
    lbl.Text=label lbl.Font=Enum.Font.GothamBold lbl.TextSize=8 lbl.TextColor3=C.DIM lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=4
    local pill=Instance.new("Frame",row) pill.Size=UDim2.fromOffset(26,13) pill.Position=UDim2.new(1,-30,0.5,-6) pill.BackgroundColor3=C.OFF pill.BorderSizePixel=0 pill.ZIndex=4 co(pill,13)
    local knob=Instance.new("Frame",pill) knob.Size=UDim2.fromOffset(9,9) knob.Position=UDim2.new(0,2,0.5,-4) knob.BackgroundColor3=C.WHITE knob.BorderSizePixel=0 knob.ZIndex=5 co(knob,9)
    local btn=Instance.new("TextButton",row) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.ZIndex=6
    local on=false
    sc(btn,function()
        on=not on
        if on then
            tw(row,{BackgroundColor3=Color3.fromRGB(12,8,28),BackgroundTransparency=0},0.13)
            tw(rs,{Color=accent,Transparency=0.15},0.13) tw(lbl,{TextColor3=C.TEXT},0.13)
            tw(pill,{BackgroundColor3=accent},0.13) tw(knob,{Position=UDim2.new(1,-11,0.5,-4)},0.13)
        else
            tw(row,{BackgroundColor3=C.CARD,BackgroundTransparency=0.22},0.13)
            tw(rs,{Color=C.BORD,Transparency=0.6},0.13) tw(lbl,{TextColor3=C.DIM},0.13)
            tw(pill,{BackgroundColor3=C.OFF},0.13) tw(knob,{Position=UDim2.new(0,2,0.5,-4)},0.13)
        end
        if cb then cb(on) end
    end)
end

-- Divider helper
local function mkDiv(order)
    local d=Instance.new("Frame",colInner) d.Size=UDim2.new(1,0,0,1) d.BackgroundColor3=C.BORD d.BackgroundTransparency=0.4 d.BorderSizePixel=0 d.LayoutOrder=order d.ZIndex=3
end

-- Action button helper
local function mkActBtn(txt,accent,order,fn)
    local btn=Instance.new("TextButton",colInner)
    btn.Size=UDim2.new(1,0,0,24) btn.BackgroundColor3=C.CARD2 btn.BackgroundTransparency=0.12
    btn.BorderSizePixel=0 btn.Text=txt btn.Font=Enum.Font.GothamBold btn.TextSize=9 btn.TextColor3=accent
    btn.AutoButtonColor=false btn.LayoutOrder=order btn.ZIndex=4 co(btn,7) stk(btn,accent,1.2,0.3)
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundTransparency=0,TextColor3=C.TEXT},0.1) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundTransparency=0.12,TextColor3=accent},0.1) end)
    btn.MouseButton1Down:Connect(function() tw(btn,{BackgroundColor3=Color3.fromRGB(12,8,28)},0.07) end)
    btn.MouseButton1Up:Connect(function() tw(btn,{BackgroundColor3=C.CARD2},0.1) end)
    sc(btn,fn)
    return btn
end

-- ================================================================
-- SEMI TP SECTION
-- ================================================================
mkSec("  SEMI TP",1)
mkTog("Semi TP",C.TEAL,2,function(s) semiTPOn=s end)
mkTog("Giant Potion on TP",C.GOLD,3,function(s) potionOnTP=s end)
mkTog("Speed After Steal",C.ORG,4,function(s) speedStealOn=s end)

-- Steal speed input row
local ssF=Instance.new("Frame",colInner) ssF.Size=UDim2.new(1,0,0,24) ssF.BackgroundColor3=C.CARD ssF.BackgroundTransparency=0.22 ssF.BorderSizePixel=0 ssF.LayoutOrder=5 ssF.ZIndex=3 co(ssF,7)
stk(ssF,C.BORD,1,0.6)
local ssLbl=Instance.new("TextLabel",ssF) ssLbl.Size=UDim2.new(0.58,0,1,0) ssLbl.Position=UDim2.fromOffset(6,0) ssLbl.BackgroundTransparency=1
ssLbl.Text="Steal Speed" ssLbl.Font=Enum.Font.GothamBold ssLbl.TextSize=8 ssLbl.TextColor3=C.DIM ssLbl.TextXAlignment=Enum.TextXAlignment.Left ssLbl.ZIndex=4
local ssBox=Instance.new("TextBox",ssF) ssBox.Size=UDim2.fromOffset(46,15) ssBox.Position=UDim2.new(1,-52,0.5,-7)
ssBox.BackgroundColor3=Color3.fromRGB(14,10,26) ssBox.BorderSizePixel=0 ssBox.Text="29"
ssBox.Font=Enum.Font.GothamBold ssBox.TextSize=9 ssBox.TextColor3=C.PURPL ssBox.ClearTextOnFocus=false ssBox.ZIndex=5
co(ssBox,5) stk(ssBox,C.PURP,1,0.35)
ssBox:GetPropertyChangedSignal("Text"):Connect(function()
    local v=tonumber(ssBox.Text) if v and v>0 then stealSpeedVal=v end
end)

mkDiv(6)

-- BASE 1 big label + button
local b1Title=Instance.new("TextLabel",colInner)
b1Title.Size=UDim2.new(1,0,0,18) b1Title.BackgroundTransparency=1 b1Title.LayoutOrder=7 b1Title.ZIndex=4
b1Title.Text="BASE 1" b1Title.Font=Enum.Font.GothamBlack b1Title.TextSize=13 b1Title.TextColor3=C.PURPL b1Title.TextXAlignment=Enum.TextXAlignment.Center
lp2(b1Title,{TextColor3=C.TEAL},2.2)

local btn1=Instance.new("TextButton",colInner)
btn1.Size=UDim2.new(1,0,0,24) btn1.BackgroundColor3=Color3.fromRGB(20,10,42) btn1.BackgroundTransparency=0.1
btn1.BorderSizePixel=0 btn1.Text="TP Base 1" btn1.Font=Enum.Font.GothamBold btn1.TextSize=10 btn1.TextColor3=C.PURPL
btn1.AutoButtonColor=false btn1.LayoutOrder=8 btn1.ZIndex=4
co(btn1,8) stk(btn1,C.PURP,1.3,0.22)
btn1.MouseEnter:Connect(function() tw(btn1,{BackgroundTransparency=0,TextColor3=C.TEXT},0.1) end)
btn1.MouseLeave:Connect(function() tw(btn1,{BackgroundTransparency=0.1,TextColor3=C.PURPL},0.1) end)
sc(btn1,function()
    if IsStealing then return end
    pcall(function()
        local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        local bp=lp:FindFirstChild("Backpack")
        if hum and bp then local c=bp:FindFirstChild("Flying Carpet") if c then hum:EquipTool(c) task.wait(0.05) end end
        local a=getNearestAnimal() if not a then return end
        local pr=findPrompt(a) if not pr then return end
        doSteal(pr,a,SEQ1)
    end)
end)

-- BASE 2 big label + button
local b2Title=Instance.new("TextLabel",colInner)
b2Title.Size=UDim2.new(1,0,0,18) b2Title.BackgroundTransparency=1 b2Title.LayoutOrder=9 b2Title.ZIndex=4
b2Title.Text="BASE 2" b2Title.Font=Enum.Font.GothamBlack b2Title.TextSize=13 b2Title.TextColor3=C.TEAL b2Title.TextXAlignment=Enum.TextXAlignment.Center
lp2(b2Title,{TextColor3=C.PURPL},2.2)

local btn2=Instance.new("TextButton",colInner)
btn2.Size=UDim2.new(1,0,0,24) btn2.BackgroundColor3=Color3.fromRGB(8,22,26) btn2.BackgroundTransparency=0.1
btn2.BorderSizePixel=0 btn2.Text="TP Base 2" btn2.Font=Enum.Font.GothamBold btn2.TextSize=10 btn2.TextColor3=C.TEAL
btn2.AutoButtonColor=false btn2.LayoutOrder=10 btn2.ZIndex=4
co(btn2,8) stk(btn2,C.TEAL,1.3,0.22)
btn2.MouseEnter:Connect(function() tw(btn2,{BackgroundTransparency=0,TextColor3=C.TEXT},0.1) end)
btn2.MouseLeave:Connect(function() tw(btn2,{BackgroundTransparency=0.1,TextColor3=C.TEAL},0.1) end)
sc(btn2,function()
    if IsStealing then return end
    pcall(function()
        local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        local bp=lp:FindFirstChild("Backpack")
        if hum and bp then local c=bp:FindFirstChild("Flying Carpet") if c then hum:EquipTool(c) task.wait(0.05) end end
        local a=getNearestAnimal() if not a then return end
        local pr=findPrompt(a) if not pr then return end
        doSteal(pr,a,SEQ2)
    end)
end)

mkDiv(11)

-- ================================================================
-- PROTECTOR SECTION
-- ================================================================
mkSec("  BASE PROTECTOR",12)
mkTog("Anti Steal",C.GRN,13,function(s) _c.Mode=s and "NoKick" or "None" end)
mkTog("Anti Intruder",C.ORG,14,function(s) _c.BorderKick=s end)
mkTog("Auto Rejoin on Protect",C.ROSE,15,function(s) _c.AutoRejoin=s end)

-- Status row
local stF=Instance.new("Frame",colInner) stF.Size=UDim2.new(1,0,0,14) stF.BackgroundTransparency=1 stF.LayoutOrder=16 stF.BorderSizePixel=0 stF.ZIndex=3
local sDot=Instance.new("Frame",stF) sDot.Size=UDim2.fromOffset(6,6) sDot.Position=UDim2.new(0,0,0.5,-3) sDot.BackgroundColor3=C.RED sDot.BorderSizePixel=0 sDot.ZIndex=4 co(sDot,6)
local sLbl=Instance.new("TextLabel",stF) sLbl.Size=UDim2.new(1,-10,1,0) sLbl.Position=UDim2.fromOffset(10,0) sLbl.BackgroundTransparency=1 sLbl.ZIndex=4
sLbl.Text="Scanning..." sLbl.Font=Enum.Font.Gotham sLbl.TextSize=7 sLbl.TextColor3=C.DIM sLbl.TextXAlignment=Enum.TextXAlignment.Left
task.spawn(function()
    while task.wait(1) do
        if _c.MyPlot then sDot.BackgroundColor3=C.GRN sLbl.Text="Plot protected"
        elseif _c.AdminRemote then sDot.BackgroundColor3=C.ORG sLbl.Text="Admin ready"
        else sDot.BackgroundColor3=C.RED sLbl.Text="Searching..." end
    end
end)

mkDiv(17)

-- ================================================================
-- AP SPAM SECTION
-- ================================================================
mkSec("  AP SPAM",18)
local spamBusy=false
mkActBtn("Spam AP Nearest",C.PURPL,19,function()
    if spamBusy then return end spamBusy=true
    spamNearest()
    task.delay(2.5,function() spamBusy=false end)
end)

-- Watermark
local wm=Instance.new("TextLabel",colInner) wm.Size=UDim2.new(1,0,0,9) wm.BackgroundTransparency=1 wm.LayoutOrder=20 wm.ZIndex=4
wm.Text="Phantom / r9qbx on discord" wm.Font=Enum.Font.Gotham wm.TextSize=6 wm.TextColor3=C.DIM wm.TextTransparency=0.45 wm.TextXAlignment=Enum.TextXAlignment.Center

-- ================================================================
-- COLLAPSE
-- ================================================================
local collapsed=false
sc(minB,function()
    collapsed=not collapsed
    if collapsed then
        minB.Text="+"
        TweenSvc:Create(colClip,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,0)}):Play()
        tw(pS,{Transparency=0.7},0.2)
    else
        minB.Text="-"
        TweenSvc:Create(colClip,TweenInfo.new(0.25,Enum.EasingStyle.Back),{Size=UDim2.new(1,0,0,COL_H)}):Play()
        tw(pS,{Transparency=0.5},0.2)
    end
end)

end)
end)
