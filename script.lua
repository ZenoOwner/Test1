-- ══════════════════════════════════════════════
--  AETHEN HUB  |  Flash TP v0.2  |  r9qbx
--  EDIT THESE:
local DISCORD_LINK    = "discord.gg/3vQbThdQ"   -- ← your link (shown on kick + header)
local DISCORD_WEBHOOK = ""                        -- ← paste webhook URL (optional)
local GRAB_RADIUS     = 45
-- ══════════════════════════════════════════════

local Players=game:GetService("Players"); local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService"); local RS=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService"); local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui"); local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local lp=Players.LocalPlayer; local cam=workspace.CurrentCamera

-- Config save
local CFG="AethonSuite.json"
local Cfg={triggerChance=91,flashOn=false,grabOn=true,potionOn=false,lagOn=false,
    stealSpdOn=false,stealSpdVal=30,
    pos_hdr={ox=0,oy=4},pos_FP={ox=0,oy=5},pos_AP={ox=0,oy=0},
    pos_BP={ox=0,oy=0},pos_ADM={ox=0,oy=0}}
pcall(function()
    if not readfile then return end
    local raw=readfile(CFG); if not raw or raw=="" then return end
    local ok,t=pcall(HttpService.JSONDecode,HttpService,raw)
    if ok and type(t)=="table" then for k,v in pairs(t) do Cfg[k]=v end end
end)
local function save() pcall(function() if writefile then writefile(CFG,HttpService:JSONEncode(Cfg)) end end) end

-- Clean old GUIs
for _,v in ipairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:sub(1,5)=="Aeth_" or v.Name:sub(1,2)=="AS") then v:Destroy() end
end
local SG=Instance.new("ScreenGui"); SG.Name="Aeth_"..tostring(math.random(1e4,9e4))
SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Global; SG.IgnoreGuiInset=true; SG.Parent=CoreGui

-- Colors
local C={
    bg=Color3.fromRGB(4,4,8),panel=Color3.fromRGB(7,7,13),
    surf=Color3.fromRGB(13,13,22),surf2=Color3.fromRGB(20,20,34),
    bord=Color3.fromRGB(45,45,75),text=Color3.fromRGB(235,235,255),
    dim=Color3.fromRGB(110,110,140),white=Color3.new(1,1,1),
    red=Color3.fromRGB(255,55,75),grn=Color3.fromRGB(55,220,105),
    blu=Color3.fromRGB(65,135,255),acc=Color3.fromRGB(135,85,255),
    cyan=Color3.fromRGB(80,200,255),org=Color3.fromRGB(255,165,45),yel=Color3.fromRGB(255,215,35),
}

-- GUI helpers
local function co(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 7) end
local function ms(p,th,col,tr) local s=Instance.new("UIStroke",p); s.Thickness=th or 1; s.Color=col or C.bord; s.Transparency=tr or 0.35; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function lb(par,t) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextColor3=C.text; l.BorderSizePixel=0; for k,v in pairs(t) do l[k]=v end; l.Parent=par; return l end
local function mkBtn(par,text,sz,pos,bg,tc,r)
    local b=Instance.new("TextButton"); b.Size=sz; b.Position=pos; b.BackgroundColor3=bg or C.surf
    b.BackgroundTransparency=0.15; b.Text=text; b.TextColor3=tc or C.text; b.Font=Enum.Font.GothamBold
    b.TextSize=9; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=par; co(b,r or 6)
    ms(b,1,C.bord,0.4); return b
end
local function rotS(f,col)
    local s=ms(f,1.2,col,0.18)
    local g=Instance.new("UIGradient",s)
    g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(0.3,col),ColorSequenceKeypoint.new(0.6,Color3.new(0.1,0.1,0.1)),ColorSequenceKeypoint.new(1,col)}
    task.spawn(function() while s and s.Parent do g.Rotation=(g.Rotation+1.8)%360; task.wait(0.02) end end)
    return s
end
local function addParticles(parent,count,col)
    for i=1,count or 4 do
        local p=Instance.new("Frame",parent); p.BackgroundColor3=col or C.acc; p.BackgroundTransparency=0.72
        p.BorderSizePixel=0; p.ZIndex=0; local sz=math.random(2,4); p.Size=UDim2.fromOffset(sz,sz)
        local sx=math.random(); p.Position=UDim2.new(sx,0,1.05,0); co(p,5)
        task.spawn(function()
            while p and p.Parent do
                local nx=math.clamp(sx+math.random(-12,12)/100,0.02,0.98)
                TweenService:Create(p,TweenInfo.new(math.random(4,8)+math.random(),Enum.EasingStyle.Linear),{Position=UDim2.new(nx,0,-0.05,0),BackgroundTransparency=1}):Play()
                task.wait(math.random(4,8))
                if p and p.Parent then p.BackgroundTransparency=0.72; sx=math.random(); p.Position=UDim2.new(sx,0,1.05,0) end
            end
        end)
    end
end
local function mkSep(par,y,col)
    local s=Instance.new("Frame",par); s.Size=UDim2.new(1,-12,0,1); s.Position=UDim2.fromOffset(6,y)
    s.BackgroundColor3=col or C.bord; s.BackgroundTransparency=0.55; s.BorderSizePixel=0; return s
end
local function dragSave(h,f,key)
    local on,ds,sp=false,nil,nil
    h.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            on=true; ds=i.Position; sp=f.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then on=false
                    if key then Cfg[key]={ox=math.floor(f.Position.X.Offset),oy=math.floor(f.Position.Y.Offset)}; save() end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not on then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds; f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

local function mkP(defX,defY,w,h,title,ac,posKey)
    local px=(posKey and Cfg[posKey] and Cfg[posKey].ox~=0 and Cfg[posKey].ox) or defX
    local py=(posKey and Cfg[posKey] and Cfg[posKey].oy~=0 and Cfg[posKey].oy) or defY
    local f=Instance.new("Frame"); f.Size=UDim2.fromOffset(w,h); f.Position=UDim2.fromOffset(px,py)
    f.BackgroundColor3=C.panel; f.BackgroundTransparency=0.06; f.BorderSizePixel=0
    f.ClipsDescendants=true; f.Parent=SG; co(f,9); rotS(f,ac); addParticles(f,3,ac)
    local hdr=Instance.new("Frame"); hdr.Size=UDim2.new(1,0,0,24); hdr.BackgroundColor3=C.surf
    hdr.BackgroundTransparency=0.1; hdr.BorderSizePixel=0; hdr.Parent=f; co(hdr,9)
    local hflat=Instance.new("Frame",hdr); hflat.Size=UDim2.new(1,0,0,9); hflat.Position=UDim2.new(0,0,1,-9)
    hflat.BackgroundColor3=C.surf; hflat.BackgroundTransparency=0.1; hflat.BorderSizePixel=0
    local tint=Instance.new("Frame",hdr); tint.Size=UDim2.new(1,0,1,0); tint.BackgroundColor3=ac
    tint.BackgroundTransparency=0.8; tint.BorderSizePixel=0; tint.ZIndex=0
    mkSep(f,24,ac)
    if title then lb(hdr,{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-24,1,0),Text=title,TextSize=8,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text,ZIndex=3}) end
    local mb=mkBtn(hdr,"─",UDim2.fromOffset(14,11),UDim2.new(1,-17,0.5,-5.5),C.surf2,C.dim,4)
    mb.TextSize=7; mb.BackgroundTransparency=0.55; mb.ZIndex=3
    dragSave(hdr,f,posKey); return f,hdr,mb
end
local function mkF(parent,hH,cH,mb)
    local content=Instance.new("Frame"); content.Size=UDim2.new(1,0,0,cH); content.Position=UDim2.fromOffset(0,hH+1)
    content.BackgroundTransparency=1; content.BorderSizePixel=0; content.Parent=parent
    local folded=false; local fullH=parent.Size.Y.Offset
    mb.MouseButton1Click:Connect(function()
        folded=not folded; mb.Text=folded and "+" or "─"
        TweenService:Create(parent,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=UDim2.new(0,parent.Size.X.Offset,0,folded and hH+2 or fullH)}):Play()
    end)
    return content
end
local function mkPill(parent,label,yPos,onCol)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-8,0,19); row.Position=UDim2.new(0,4,0,yPos)
    row.BackgroundColor3=C.surf; row.BackgroundTransparency=0.2; row.BorderSizePixel=0; row.Parent=parent; co(row,6)
    local rs=ms(row,1,C.bord,0.5)
    local rl=lb(row,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-34,1,0),Text=label,TextSize=7,Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local track=Instance.new("Frame"); track.Size=UDim2.fromOffset(23,11); track.Position=UDim2.new(1,-26,0.5,-5.5); track.BackgroundColor3=C.surf2; track.BorderSizePixel=0; track.Parent=row; co(track,12)
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(8,8); knob.Position=UDim2.new(0,1.5,0.5,-4); knob.BackgroundColor3=C.dim; knob.BorderSizePixel=0; knob.Parent=track; co(knob,8)
    local pb=Instance.new("TextButton"); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1; pb.Text=""; pb.Parent=row
    local col=onCol or C.acc
    local function set(v)
        TweenService:Create(track,TweenInfo.new(0.12),{BackgroundColor3=v and col or C.surf2}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-9.5,0.5,-4) or UDim2.new(0,1.5,0.5,-4),BackgroundColor3=v and C.white or C.dim}):Play()
        TweenService:Create(rs,TweenInfo.new(0.12),{Color=v and col or C.bord,Transparency=v and 0.15 or 0.5}):Play()
        rl.TextColor3=v and C.text or C.dim
    end
    return pb,set
end
local function numRow(parent,label,val,mn,mx,yPos,w,onChange)
    local IW=w-8; local row=Instance.new("Frame"); row.Size=UDim2.fromOffset(IW,19); row.Position=UDim2.fromOffset(4,yPos)
    row.BackgroundColor3=C.surf; row.BackgroundTransparency=0.2; row.BorderSizePixel=0; row.Parent=parent; co(row,5); ms(row,1,C.bord,0.5)
    lb(row,{Position=UDim2.new(0,5,0,0),Size=UDim2.new(0.5,0,1,0),Text=label,TextSize=7,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local mB=Instance.new("TextButton",row); mB.Size=UDim2.fromOffset(13,13); mB.Position=UDim2.new(0.5,2,0.5,-6.5); mB.BackgroundColor3=C.surf2; mB.Text="-"; mB.Font=Enum.Font.GothamBold; mB.TextSize=9; mB.TextColor3=C.acc; mB.BorderSizePixel=0; mB.AutoButtonColor=false; co(mB,3)
    local vB=Instance.new("TextBox",row); vB.Size=UDim2.fromOffset(24,13); vB.Position=UDim2.new(0.5,17,0.5,-6.5); vB.BackgroundColor3=C.surf2; vB.BorderSizePixel=0; vB.Text=tostring(val); vB.Font=Enum.Font.GothamBold; vB.TextSize=8; vB.TextColor3=C.acc; vB.ClearTextOnFocus=false; co(vB,3)
    local pB=Instance.new("TextButton",row); pB.Size=UDim2.fromOffset(13,13); pB.Position=UDim2.new(0.5,43,0.5,-6.5); pB.BackgroundColor3=C.surf2; pB.Text="+"; pB.Font=Enum.Font.GothamBold; pB.TextSize=9; pB.TextColor3=C.acc; pB.BorderSizePixel=0; pB.AutoButtonColor=false; co(pB,3)
    local cur=val
    local function setV(v) cur=math.clamp(math.floor(v),mn,mx); vB.Text=tostring(cur); if onChange then onChange(cur) end end
    mB.MouseButton1Click:Connect(function() setV(cur-1) end)
    pB.MouseButton1Click:Connect(function() setV(cur+1) end)
    vB.FocusLost:Connect(function() local n=tonumber(vB.Text); if n then setV(n) else vB.Text=tostring(cur) end end)
end

task.wait(0.1); local vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end

-- Guard: background systems only run once per session
if not _G._AethBG then _G._AethBG=true

    -- Anti-lag always on
    pcall(function()
        Lighting.GlobalShadows=false; Lighting.FogEnd=1e9
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("PointLight") then pcall(function() v.Enabled=false end) end
        end
    end)
    workspace.DescendantAdded:Connect(function(v)
        pcall(function() if v:IsA("ParticleEmitter") or v:IsA("PointLight") then v.Enabled=false end end)
    end)

    -- Kick on steal (watches for "you stole" in PlayerGui)
    task.spawn(function()
        local pg=lp:WaitForChild("PlayerGui")
        local function onStole() pcall(function() lp:Kick(DISCORD_LINK) end) end
        local function chk(t) return typeof(t)=="string" and t:lower():find("you stole") end
        local function watch(gui)
            gui.DescendantAdded:Connect(function(d)
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    if chk(d.Text) then onStole() end
                    d:GetPropertyChangedSignal("Text"):Connect(function() if chk(d.Text) then onStole() end end)
                end
            end)
        end
        for _,g in ipairs(pg:GetChildren()) do watch(g) end
        pg.ChildAdded:Connect(function(g) watch(g) end)
    end)

    -- Anti-ragdoll
    RunService.Heartbeat:Connect(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart"); if not (hum and root) then return end
        local s=hum:GetState()
        local rag=(s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown)
        local et=lp:GetAttribute("RagdollEndTime")
        if et and (et-workspace:GetServerTimeNow())>0 then rag=true end
        if rag then
            pcall(function() lp:SetAttribute("RagdollEndTime",workspace:GetServerTimeNow()) end)
            for _,d in ipairs(char:GetDescendants()) do
                if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then d:Destroy() end
            end
            for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
            if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            cam.CameraSubject=hum; root.Anchored=false
            root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
        end
    end)

    -- Anti-bee (improved: BindToRenderStep for highest priority, fixes inversion)
    RunService:BindToRenderStep("AethAntiBee",Enum.RenderPriority.Input.Value+1,function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart"); if not hum or not root then return end
        if not hum.AutoRotate then hum.AutoRotate=true end
        for _,obj in ipairs(root:GetChildren()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyAngularVelocity") then pcall(function() obj:Destroy() end) end
        end
        for _,obj in ipairs(char:GetDescendants()) do
            local nl=obj.Name:lower()
            if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") then pcall(function() obj:Destroy() end) end
        end
        for _,val in ipairs(char:GetChildren()) do
            if (val:IsA("BoolValue") or val:IsA("IntValue") or val:IsA("NumberValue")) then
                local nl=val.Name:lower()
                if nl:find("bee") or nl:find("invert") or nl:find("reverse") then
                    pcall(function() if val:IsA("BoolValue") then val.Value=false else val.Value=0 end end)
                end
            end
        end
        if hum.MoveDirection.Magnitude>0.1 then
            local md=hum.MoveDirection; local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
            if vel.Magnitude>1.5 and md:Dot(vel.Unit)<-0.45 then
                root.Velocity=Vector3.new(md.X*28,root.Velocity.Y,md.Z*28)
            end
        end
    end)

    -- Anti-sentry (improved: correctly identifies own sentry + beehive)
    local sentryFirstSeen={}; local sentryTarget=nil
    local function isMySentry(obj)
        local ownerId=obj.Name:match("Sentry_(%d+)") or obj.Name:match("Beehive_(%d+)")
        if ownerId and tonumber(ownerId)==lp.UserId then return true end
        local a2=obj:GetAttribute("OwnerId") or obj:GetAttribute("PlayerId") or obj:GetAttribute("Owner")
        return a2 and tonumber(tostring(a2))==lp.UserId
    end
    local function findSentryTarget()
        local char=lp.Character; if not char then return nil end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
        local rootPos=hrp.Position; local now=tick()
        for obj in pairs(sentryFirstSeen) do if not obj.Parent then sentryFirstSeen[obj]=nil end end
        for _,obj in pairs(workspace:GetChildren()) do
            if (obj.Name:find("Sentry") or obj.Name:find("Beehive")) and not obj.Name:lower():find("bullet") then
                if isMySentry(obj) then continue end
                local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and (rootPos-part.Position).Magnitude<=220 then
                    if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=now end
                    if now-sentryFirstSeen[obj]>=2.5 then return obj end
                end
            end
        end; return nil
    end
    local function attackSentry()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local weapon=(lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat"); if not weapon then return end
        if weapon.Parent==lp.Backpack then hum:EquipTool(weapon); task.wait(0.08) end
        pcall(function() weapon:Activate() end)
        for _,r in pairs(weapon:GetDescendants()) do if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end end
    end
    local function moveSentry(obj)
        local char=lp.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        for _,p2 in pairs(obj:GetDescendants()) do if p2:IsA("BasePart") then p2.CanCollide=false end end
        local cf=hrp.CFrame*CFrame.new(0,0,-6)
        if obj:IsA("BasePart") then obj.CFrame=cf elseif obj:IsA("Model") then local m=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if m then m.CFrame=cf end end
    end
    RunService.Heartbeat:Connect(function()
        if sentryTarget and sentryTarget.Parent==workspace then moveSentry(sentryTarget); attackSentry()
        else sentryTarget=findSentryTarget() end
    end)
    task.spawn(function() task.wait(1)
        for _,obj in pairs(workspace:GetChildren()) do
            if (obj.Name:find("Sentry") or obj.Name:find("Beehive")) and not isMySentry(obj) then
                sentryFirstSeen[obj]=tick()-2.5
            end
        end
    end)
end -- end _G._AethBG guard

-- Anti-bee FOV lock (always needs to run per-script for the FieldOfView)
local FOV_LOCK=70
local beeBlacklist={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect"}
for _,v in pairs(Lighting:GetDescendants()) do if ({BlurEffect=1,ColorCorrectionEffect=1,BloomEffect=1,SunRaysEffect=1,DepthOfFieldEffect=1})[v.ClassName] then pcall(function() v:Destroy() end) end end
Lighting.DescendantAdded:Connect(function(obj) task.wait(); pcall(function() if ({BlurEffect=1,ColorCorrectionEffect=1,BloomEffect=1,SunRaysEffect=1,DepthOfFieldEffect=1})[obj.ClassName] then obj:Destroy() end end) end)
RunService.RenderStepped:Connect(function() if cam.FieldOfView~=FOV_LOCK then cam.FieldOfView=FOV_LOCK end end)

-- Plot detection
local myPlotRef=nil; local stealHitbox=nil
task.spawn(function() while task.wait(1) do
    if not myPlotRef then
        local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
        for _,p in ipairs(plots:GetChildren()) do
            local sign=p:FindFirstChild("PlotSign"); if not sign then continue end
            local tl=sign:FindFirstChild("TextLabel",true); if not tl then continue end
            local t=tl.Text:lower()
            if t:find(lp.Name:lower(),1,true) or t:find(lp.DisplayName:lower(),1,true) then
                myPlotRef=p; stealHitbox=p:FindFirstChild("StealHitbox",true); break
            end
        end
    end
end end)

-- Timer ESP
local timerESPs={}; local baseAlerted=false
local ECOL_R=C.red; local ECOL_Y=C.yel; local ECOL_G=C.grn
local function showAlert()
    pcall(function() local s=Instance.new("Sound"); s.SoundId="rbxassetid://9118633772"; s.Volume=0.85; s.Parent=workspace; s:Play(); Debris:AddItem(s,5) end)
    local ag=Instance.new("ScreenGui",CoreGui); ag.Name="AethAlert"..tostring(math.random()); ag.ResetOnSpawn=false; ag.IgnoreGuiInset=true
    local af=Instance.new("Frame",ag); af.Size=UDim2.fromOffset(188,26); af.Position=UDim2.new(0.5,-94,0,-38)
    af.BackgroundColor3=C.panel; af.BackgroundTransparency=0.05; af.BorderSizePixel=0; co(af,7); ms(af,1.5,C.red,0.08)
    lb(af,{Size=UDim2.new(1,0,1,0),Text="⚠  BASE EXPIRES IN 5s!",TextSize=9,Font=Enum.Font.GothamBlack,TextColor3=C.red})
    TweenService:Create(af,TweenInfo.new(0.32,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-94,0,7)}):Play()
    task.delay(4,function() TweenService:Create(af,TweenInfo.new(0.22),{Position=UDim2.new(0.5,-94,0,-38)}):Play(); task.wait(0.25); ag:Destroy() end)
end
task.spawn(function() while task.wait(0.4) do
    local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
    for _,plot in ipairs(plots:GetChildren()) do
        local pur=plot:FindFirstChild("Purchases"); local pb2=pur and pur:FindFirstChild("PlotBlock"); local mp=pb2 and pb2:FindFirstChild("Main")
        local tl2=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
        if tl2 and mp then
            local e=timerESPs[plot.Name]
            if not e or not e.bb.Parent then
                if e then pcall(function() e.bb:Destroy() end) end
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(58,17); bb.StudsOffset=Vector3.new(0,7,0); bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
                local bgT=Instance.new("Frame",bb); bgT.Size=UDim2.new(1,0,1,0); bgT.BackgroundColor3=C.bg; bgT.BackgroundTransparency=0.2; bgT.BorderSizePixel=0; co(bgT,5)
                local stk=Instance.new("UIStroke",bgT); stk.Color=ECOL_Y; stk.Thickness=1; stk.Transparency=0.25; stk.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
                local tl=Instance.new("TextLabel",bgT); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold; tl.TextSize=9; tl.TextColor3=ECOL_Y; tl.TextStrokeTransparency=0.5; tl.TextStrokeColor3=Color3.new(0,0,0)
                timerESPs[plot.Name]={bb=bb,lbl=tl,stk=stk}; e=timerESPs[plot.Name]
            end
            e.lbl.Text=tl2.Text
            local m,s2=tl2.Text:match("(%d+):(%d+)")
            if m and s2 then
                local tot=tonumber(m)*60+tonumber(s2); local col=tot<=30 and ECOL_R or tot<=60 and ECOL_Y or ECOL_G
                e.lbl.TextColor3=col; e.stk.Color=col
                if myPlotRef and plot==myPlotRef then
                    if tot<=5 and not baseAlerted then baseAlerted=true; task.spawn(showAlert) elseif tot>5 then baseAlerted=false end
                end
            end
        else
            local e=timerESPs[plot.Name]; if e then pcall(function() e.bb:Destroy() end); timerESPs[plot.Name]=nil end
        end
    end
end end)

-- Player ESP
local ESPTAG="AE_"..tostring(math.random(1e4,9e4))
local function mkESP(plr)
    if plr==lp then return end
    local char=plr.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end
    local box=Instance.new("BoxHandleAdornment",char); box.Name=ESPTAG; box.Adornee=hrp; box.Size=Vector3.new(4,6,2); box.Color3=C.acc; box.Transparency=0.6; box.ZIndex=10; box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char); bb.Name=ESPTAG.."N"; bb.Adornee=char:FindFirstChild("Head") or hrp; bb.Size=UDim2.fromOffset(132,25); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true
    local bgE=Instance.new("Frame",bb); bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=C.bg; bgE.BackgroundTransparency=0.2; bgE.BorderSizePixel=0; co(bgE,5); ms(bgE,1,C.acc,0.25)
    lb(bgE,{Size=UDim2.new(1,0,0.56,0),BackgroundTransparency=1,Text=plr.DisplayName,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.text,TextStrokeTransparency=0.5,TextStrokeColor3=Color3.new(0,0,0)})
    lb(bgE,{Size=UDim2.new(1,0,0.44,0),Position=UDim2.new(0,0,0.56,0),BackgroundTransparency=1,Text="@"..plr.Name,Font=Enum.Font.Gotham,TextSize=7,TextColor3=C.dim})
end
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then task.defer(function() mkESP(p) end) end end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end)
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end end

-- Mine ESP
local mineESPs={}
local function addMineESP(child)
    if mineESPs[child] then return end
    local nl=child.Name:lower()
    if not (nl:find("subspace") or nl:find("mine")) then return end
    if nl:find("bullet") or nl:find("explosion") or nl:find("effect") then return end
    local part=child:IsA("BasePart") and child or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")))
    if not part then return end
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(96,28); bb.StudsOffset=Vector3.new(0,5,0); bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=workspace
    local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(14,2,2); bg.BackgroundTransparency=0.05; bg.BorderSizePixel=0; co(bg,6); ms(bg,1.5,C.red,0)
    lb(bg,{Size=UDim2.fromOffset(14,28),Position=UDim2.fromOffset(5,0),BackgroundTransparency=1,Text="⚠",Font=Enum.Font.GothamBlack,TextSize=10,TextColor3=Color3.fromRGB(255,80,80)})
    lb(bg,{Size=UDim2.new(1,-22,0,15),Position=UDim2.fromOffset(20,1),BackgroundTransparency=1,Text="SUBSPACE MINE",Font=Enum.Font.GothamBlack,TextSize=8,TextColor3=Color3.fromRGB(255,90,90),TextXAlignment=Enum.TextXAlignment.Left})
    local distL=lb(bg,{Size=UDim2.new(1,-22,0,11),Position=UDim2.fromOffset(20,14),BackgroundTransparency=1,Text="-- studs",Font=Enum.Font.Gotham,TextSize=7,TextColor3=Color3.fromRGB(180,80,80),TextXAlignment=Enum.TextXAlignment.Left})
    local dc=RunService.Heartbeat:Connect(function()
        if not bb.Parent or not part.Parent then return end
        local char=lp.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
        if root then local d=math.round((root.Position-part.Position).Magnitude); distL.Text=d.." studs"; distL.TextColor3=d<15 and C.red or d<30 and C.yel or Color3.fromRGB(160,80,80) end
    end)
    mineESPs[child]={bb=bb,dc=dc}
    child.AncestryChanged:Connect(function() if not child.Parent then pcall(function() bb:Destroy() end); pcall(function() dc:Disconnect() end); mineESPs[child]=nil end end)
end
for _,d in pairs(workspace:GetDescendants()) do addMineESP(d) end
workspace.DescendantAdded:Connect(function(d) task.defer(function() addMineESP(d) end) end)

-- Brainrot ESP
local brainrotESPCache={}; local brainrotESPEnabled=false
local function mkBrainrotESP(part)
    if not part or brainrotESPCache[part] then return end
    local oh=part:FindFirstChild("AnimalOverhead"); if not oh then return end
    local genL=oh:FindFirstChild("Generation"); local dnL=oh:FindFirstChild("DisplayName"); if not genL or not dnL then return end
    local bb=Instance.new("BillboardGui"); bb.Name="AethBrainrotESP"; bb.Adornee=part
    bb.Size=UDim2.fromOffset(130,38); bb.StudsOffset=Vector3.new(0,-2,0); bb.AlwaysOnTop=true; bb.Parent=part
    local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(5,3,14); bg.BackgroundTransparency=0.12; bg.BorderSizePixel=0; co(bg,6); ms(bg,1,C.acc,0.2)
    lb(bg,{Size=UDim2.new(1,0,0,19),BackgroundTransparency=1,Text="🧠 "..dnL.Text,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(195,150,255),TextTruncate=Enum.TextTruncate.AtEnd})
    lb(bg,{Size=UDim2.new(1,0,0,17),Position=UDim2.fromOffset(0,19),BackgroundTransparency=1,Text=genL.Text,Font=Enum.Font.Gotham,TextSize=8,TextColor3=Color3.fromRGB(150,195,255),TextTruncate=Enum.TextTruncate.AtEnd})
    brainrotESPCache[part]=bb
    part.AncestryChanged:Connect(function() if not part.Parent then pcall(function() bb:Destroy() end); brainrotESPCache[part]=nil end end)
end
local function startBrainrotESP()
    if brainrotESPEnabled then return end; brainrotESPEnabled=true
    local debris=workspace:FindFirstChild("Debris"); if not debris then return end
    for _,p in ipairs(debris:GetChildren()) do if p.Name=="FastOverheadTemplate" and p:IsA("BasePart") then mkBrainrotESP(p) end end
    debris.ChildAdded:Connect(function(p) if brainrotESPEnabled and p.Name=="FastOverheadTemplate" and p:IsA("BasePart") then task.wait(0.05); mkBrainrotESP(p) end end)
    debris.ChildRemoved:Connect(function(p) if brainrotESPCache[p] then pcall(function() brainrotESPCache[p]:Destroy() end); brainrotESPCache[p]=nil end end)
end
local function stopBrainrotESP()
    if not brainrotESPEnabled then return end; brainrotESPEnabled=false
    for _,bb in pairs(brainrotESPCache) do pcall(function() bb:Destroy() end) end; brainrotESPCache={}
end

-- Friends ESP
local friendESPCache={}; local friendESPEnabled=false
local function mkFriendESP(plot)
    if friendESPCache[plot] or not plot:IsA("Model") then return end
    local fp=plot:FindFirstChild("FriendPanel"); if not fp then return end
    local main=fp:FindFirstChild("Main"); if not main then return end
    local prompt=main:FindFirstChildOfClass("ProximityPrompt"); if not prompt then return end
    local isOpen=prompt.ObjectText=="Disallow Friends"
    local bb=Instance.new("BillboardGui"); bb.Adornee=main; bb.Size=UDim2.fromOffset(55,22); bb.StudsOffset=Vector3.new(0,5,0); bb.AlwaysOnTop=true; bb.Parent=main
    local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=isOpen and Color3.fromRGB(3,16,5) or Color3.fromRGB(16,3,3); bg.BackgroundTransparency=0.12; bg.BorderSizePixel=0; co(bg,5); ms(bg,1,isOpen and C.grn or C.red,0.22)
    lb(bg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=isOpen and "✓ OPEN" or "✕ CLOSED",TextColor3=isOpen and C.grn or C.red,Font=Enum.Font.GothamBold,TextSize=8})
    friendESPCache[plot]=bb
    plot.AncestryChanged:Connect(function() if not plot.Parent then pcall(function() bb:Destroy() end); friendESPCache[plot]=nil end end)
end
local function startFriendESP()
    if friendESPEnabled then return end; friendESPEnabled=true
    local plots=workspace:FindFirstChild("Plots"); if not plots then return end
    for _,p in ipairs(plots:GetChildren()) do mkFriendESP(p) end
    plots.ChildAdded:Connect(function(p) if friendESPEnabled then task.wait(0.5); mkFriendESP(p) end end)
end
local function stopFriendESP()
    if not friendESPEnabled then return end; friendESPEnabled=false
    for _,bb in pairs(friendESPCache) do pcall(function() bb:Destroy() end) end; friendESPCache={}
end

-- Base Xray
local xrayOn=false; local xrayOriginals={}
local function enableBaseXray()
    if xrayOn then return end; xrayOn=true
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n=obj.Name:lower()
            if n:find("floor") or n:find("wall") or n:find("base") or n:find("plot") or n:find("ceil") then
                if not xrayOriginals[obj] then xrayOriginals[obj]=obj.Transparency end
                obj.Transparency=0.72
            end
        end
    end
end
local function disableBaseXray()
    if not xrayOn then return end; xrayOn=false
    for obj,t in pairs(xrayOriginals) do pcall(function() if obj and obj.Parent then obj.Transparency=t end end) end; xrayOriginals={}
end

-- Brainrot Transparency
local brainTransOn=false; local brainTransOrig={}
local function enableBrainTrans()
    if brainTransOn then return end; brainTransOn=true
    local plots=workspace:FindFirstChild("Plots"); if not plots then return end
    for _,plot in ipairs(plots:GetChildren()) do
        local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
        for _,pod in ipairs(pods:GetChildren()) do
            for _,obj in ipairs(pod:GetDescendants()) do
                if obj:IsA("BasePart") then
                    if not brainTransOrig[obj] then brainTransOrig[obj]=obj.Transparency end
                    obj.Transparency=0.65
                end
            end
        end
    end
end
local function disableBrainTrans()
    if not brainTransOn then return end; brainTransOn=false
    for obj,t in pairs(brainTransOrig) do pcall(function() if obj and obj.Parent then obj.Transparency=t end end) end; brainTransOrig={}
end

-- Admin remote
local ADM_REMOTE=nil
task.spawn(function()
    pcall(function() if not lp.Character then lp.CharacterAdded:Wait() end end); task.wait(1.5)
    pcall(function()
        local net=RS:WaitForChild("Packages"):WaitForChild("Net"); local ch=net:GetChildren(); local n2i={}
        for i,o in ipairs(ch) do n2i[o.Name]=i end
        local a=n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
        if a and ch[a+1] then ADM_REMOTE=ch[a+1] end
    end)
end)
local ADM_UUID="f888ee6e-c86d-46e1-93d7-0639d6635d42"
local function aFire(tgt,cmd) task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,tgt,cmd) end) end) end
local ROW_CD={ragdoll=30,balloon=30,tiny=60,jail=60,rocket=120,inverse=15,morph=30}
local CMD_ICONS={ragdoll="🤸",balloon="🎈",tiny="🐜",jail="🔒",rocket="🚀"}
local rowCdEnd={}
local function fireCmd(tgt,cmd) if not ADM_REMOTE then return end; aFire(tgt,cmd); rowCdEnd[cmd]=tick()+(ROW_CD[cmd] or 30) end
-- On player click: inverse, tiny, jumpscare, rocket, morph
local CLICK_CMDS={"inverse","tiny","jumpscare","rocket","morph"}
local function fireClick(tgt)
    if not ADM_REMOTE then return end
    for _,cmd in ipairs(CLICK_CMDS) do aFire(tgt,cmd); if ROW_CD[cmd] then rowCdEnd[cmd]=tick()+ROW_CD[cmd] end end
end

-- Giant Potion
local potionOn=Cfg.potionOn
local function activatePotion()
    if not potionOn then return end
    task.spawn(function() pcall(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local bp=lp:FindFirstChild("Backpack")
        local tool=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion")); if not tool then return end
        hum:EquipTool(tool); task.wait(0.08); tool:Activate()
    end) end)
end

-- Carpet + Tokinu reset
local CARPET_KW={"carpet","tapis","flying","witch","broom","sleigh","cupid","wing"}
local function equipCarpetTool()
    local char=lp.Character; if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local bp=lp:FindFirstChild("Backpack"); local found=nil
    local function chk(t) if not t:IsA("Tool") then return end; local nl=t.Name:lower(); for _,kw in ipairs(CARPET_KW) do if nl:find(kw) then found=t; return end end end
    if bp then for _,t in ipairs(bp:GetChildren()) do if not found then chk(t) end end end
    if not found then for _,t in ipairs(char:GetChildren()) do if not found then chk(t) end end end
    if found then if found.Parent~=char then found.Parent=char end; local h2=char:FindFirstChildOfClass("Humanoid"); if h2 then h2:EquipTool(found) end; return true end
    return false
end
local function doReset()
    local c=lp.Character; if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso"); if not h then return end
    local eq=equipCarpetTool(); if eq then task.wait(0.1) end
    h.CFrame=CFrame.new(0,15000,0)
end

local FLASH_NAMES={"Flash Teleport","Flash","FlashTP","Flash TP"}
local function equipFlash()
    pcall(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        for _,n in ipairs(FLASH_NAMES) do
            local t=char:FindFirstChild(n) or (lp.Backpack and lp.Backpack:FindFirstChild(n))
            if t then if t.Parent~=char then hum:EquipTool(t) end; return end
        end
    end)
end

-- Lag self (25 quick iterations for flash accuracy, client-side only)
local function lagSelf()
    local x=0; for i=1,25000 do x=x+i*0.00001 end; return x
end

-- BASE 1 detection for AUTO ALLIGN
local BASE1_X_MIN,BASE1_X_MAX=-345,-285
local BASE1_Z_MIN,BASE1_Z_MAX=75,155
local function isInBase1()
    local char=lp.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    local p=hrp.Position; return p.X>=BASE1_X_MIN and p.X<=BASE1_X_MAX and p.Z>=BASE1_Z_MIN and p.Z<=BASE1_Z_MAX
end

local PodiumPoints={
    {pos=Vector3.new(-330.3,-4.9,94.6),camCF=CFrame.lookAt(Vector3.new(-324.852,3.376,103.738),Vector3.new(-325.155,2.826,102.959))},
    {pos=Vector3.new(-323.4,-4.9,94.0),camCF=CFrame.lookAt(Vector3.new(-316.695,3.492,102.060),Vector3.new(-317.111,2.933,101.343))},
    {pos=Vector3.new(-315.9,-4.9,94.2),camCF=CFrame.lookAt(Vector3.new(-310.255,3.690,102.906),Vector3.new(-310.581,3.115,102.156))},
    {pos=Vector3.new(-309.7,-4.9,94.2),camCF=CFrame.lookAt(Vector3.new(-302.102,3.311,101.665),Vector3.new(-302.596,2.766,100.988))},
    {pos=Vector3.new(-296.8,-5.4,93.7),camCF=CFrame.lookAt(Vector3.new(-292.982,-1.861,94.294),Vector3.new(-293.677,-2.389,93.806))},
    {pos=Vector3.new(-300.4,-5.2,129.8),camCF=CFrame.lookAt(Vector3.new(-304.365,-0.257,136.083),Vector3.new(-303.880,-0.681,135.318))},
    {pos=Vector3.new(-306.6,-5.4,128.0),camCF=CFrame.lookAt(Vector3.new(-315.538,0.977,135.225),Vector3.new(-314.824,0.579,134.649))},
    {pos=Vector3.new(-317.0,-5.1,134.5),camCF=CFrame.lookAt(Vector3.new(-312.718,-0.547,132.938),Vector3.new(-313.495,-1.113,133.215))},
    {pos=Vector3.new(-324.1,-4.9,131.7),camCF=CFrame.lookAt(Vector3.new(-320.155,0.308,136.046),Vector3.new(-320.722,-0.235,135.426))},
    {pos=Vector3.new(-336.7,-5.4,130.5),camCF=CFrame.lookAt(Vector3.new(-334.110,-2.056,136.160),Vector3.new(-334.243,-2.365,135.218))},
    {pos=Vector3.new(-329.9,13.1,93.7),camCF=CFrame.lookAt(Vector3.new(-325.140,10.148,97.954),Vector3.new(-325.575,10.727,97.264))},
    {pos=Vector3.new(-324.2,12.8,102.0),camCF=CFrame.lookAt(Vector3.new(-322.517,12.013,109.124),Vector3.new(-322.504,12.305,108.168))},
    {pos=Vector3.new(-315.9,12.8,92.8),camCF=CFrame.lookAt(Vector3.new(-308.210,20.319,93.432),Vector3.new(-308.949,19.689,93.195))},
    {pos=Vector3.new(-309.4,13.1,94.2),camCF=CFrame.lookAt(Vector3.new(-304.720,23.019,95.189),Vector3.new(-305.112,22.135,94.937))},
    {pos=Vector3.new(-299.3,12.9,93.4),camCF=CFrame.lookAt(Vector3.new(-292.952,19.006,93.712),Vector3.new(-293.701,18.397,93.450))},
    {pos=Vector3.new(-323.5,12.6,122.7),camCF=CFrame.lookAt(Vector3.new(-314.237,20.013,131.706),Vector3.new(-314.794,19.588,130.993))},
    {pos=Vector3.new(-336.7,12.6,131.6),camCF=CFrame.lookAt(Vector3.new(-334.348,15.893,136.155),Vector3.new(-334.473,15.531,135.232))},
    {pos=Vector3.new(-316.8,12.6,122.1),camCF=CFrame.lookAt(Vector3.new(-304.595,19.357,127.057),Vector3.new(-305.398,18.978,126.596))},
    {pos=Vector3.new(-334.2,29.6,93.5),camCF=CFrame.lookAt(Vector3.new(-336.907,26.898,98.850),Vector3.new(-336.341,27.477,98.263))},
    {pos=Vector3.new(-322.9,29.8,92.7),camCF=CFrame.lookAt(Vector3.new(-312.668,38.516,94.243),Vector3.new(-313.441,37.935,93.989))},
    {pos=Vector3.new(-312.9,30.0,93.9),camCF=CFrame.lookAt(Vector3.new(-305.856,41.590,96.372),Vector3.new(-306.347,40.779,96.055))},
    {pos=Vector3.new(-305.8,30.1,93.6),camCF=CFrame.lookAt(Vector3.new(-295.325,41.918,96.411),Vector3.new(-295.979,41.221,96.117))},
    {pos=Vector3.new(-299.9,30.1,93.5),camCF=CFrame.lookAt(Vector3.new(-296.349,34.097,93.014),Vector3.new(-297.064,33.456,92.736))},
    {pos=Vector3.new(-335.8,29.6,131.6),camCF=CFrame.lookAt(Vector3.new(-333.401,33.240,136.147),Vector3.new(-333.535,32.820,135.249))},
    {pos=Vector3.new(-321.3,29.8,127.1),camCF=CFrame.lookAt(Vector3.new(-311.401,30.330,130.143),Vector3.new(-312.291,30.419,129.696))},
    {pos=Vector3.new(-314.6,29.8,134.6),camCF=CFrame.lookAt(Vector3.new(-309.991,30.451,131.699),Vector3.new(-310.954,30.604,131.923))},
    {pos=Vector3.new(-306.4,29.7,127.6),camCF=CFrame.lookAt(Vector3.new(-309.658,30.589,131.997),Vector3.new(-308.840,30.687,131.430))},
}
local function getNearestPodium()
    local char=lp.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local myPos=hrp.Position; local si,ei
    if myPos.Y<5 then si,ei=1,10 elseif myPos.Y<22 then si,ei=11,18 else si,ei=19,27 end
    local nearest,minD=nil,math.huge
    for i=si,ei do local pt=PodiumPoints[i]; if pt then local d=(myPos-pt.pos).Magnitude; if d<minD then minD=d;nearest=pt end end end
    return nearest
end

local function doCamOnlyAlign()
    -- Old cam align: just fix camera pitch/angle, NO teleport (works for any base)
    local pos=cam.CFrame.Position; local look=cam.CFrame.LookVector
    local flat=Vector3.new(look.X,0,look.Z); if flat.Magnitude<0.01 then flat=Vector3.new(0,0,-1) else flat=flat.Unit end
    -- Apply ~19° downward pitch (same as base 1 cam aligns)
    local pitch=-0.33  -- radians, matches base1 camCF pitch
    local right=flat:Cross(Vector3.new(0,1,0)).Unit
    local pitchedLook=(flat*math.cos(math.abs(pitch))+Vector3.new(0,-1,0)*math.abs(pitch)*0.9).Unit
    cam.CameraType=Enum.CameraType.Scriptable
    cam.CFrame=CFrame.lookAt(pos,pos+pitchedLook)
    task.wait()
    cam.CameraType=Enum.CameraType.Custom
    equipFlash()
end

local function doAutoAlign()
    if isInBase1() then
        local nearest=getNearestPodium(); if not nearest then return end
        local char=lp.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        equipCarpetTool(); task.wait(0.05)
        hrp.Velocity=Vector3.new(0,0,0); hrp.CFrame=CFrame.new(nearest.pos)
        task.wait(0.1)
        cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=nearest.camCF
        task.wait(); cam.CameraType=Enum.CameraType.Custom  -- restored
        equipFlash()
    else
        doCamOnlyAlign()  -- only align camera, no TP
    end
end

-- Flash ghost indicator
local ghostPart=nil; local ghostBB=nil; local ghostDistL=nil; local ghostStatL=nil; local flashOnCooldown=false
local function updateFlashGhost()
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local tool=char:FindFirstChildOfClass("Tool")
    local hasFlash=tool and (function() for _,n in ipairs(FLASH_NAMES) do if tool.Name==n then return true end end return false end)()
    if not hasFlash then if ghostPart then ghostPart.Transparency=1 end; return end
    if not ghostPart then
        ghostPart=Instance.new("Part"); ghostPart.Anchored=true; ghostPart.CanCollide=false
        ghostPart.Size=Vector3.new(2.5,0.12,2.5); ghostPart.Material=Enum.Material.Neon
        ghostPart.CastShadow=false; ghostPart.Name="AethFlashGhost"; ghostPart.Parent=workspace
        ghostBB=Instance.new("BillboardGui",ghostPart); ghostBB.Size=UDim2.fromOffset(92,26)
        ghostBB.StudsOffset=Vector3.new(0,1.8,0); ghostBB.AlwaysOnTop=true
        local bg=Instance.new("Frame",ghostBB); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=C.bg; bg.BackgroundTransparency=0.12; bg.BorderSizePixel=0; co(bg,6)
        local bgS=ms(bg,1,C.cyan,0.2)
        ghostDistL=lb(bg,{Size=UDim2.new(1,0,0.55,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.cyan})
        ghostStatL=lb(bg,{Size=UDim2.new(1,0,0.45,0),Position=UDim2.new(0,0,0.55,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=7,TextColor3=C.grn,Text="READY"})
        -- Update stroke color reference
        ghostBB:SetAttribute("bgS","true")
        ghostBB.Parent=ghostPart
    end
    local lookDir=cam.CFrame.LookVector
    local flat=Vector3.new(lookDir.X,0,lookDir.Z); if flat.Magnitude<0.01 then flat=Vector3.new(0,0,-1) else flat=flat.Unit end
    local targetPos=hrp.Position+flat*50
    ghostPart.Transparency=0.35
    ghostPart.Color=flashOnCooldown and C.red or C.cyan
    ghostPart.CFrame=CFrame.new(targetPos)
    local dist=math.round((hrp.Position-targetPos).Magnitude)
    ghostDistL.Text="◈ ~"..dist.." studs"
    ghostDistL.TextColor3=flashOnCooldown and C.red or C.cyan
    ghostStatL.Text=flashOnCooldown and "⏱ CD" or "✓ READY"
    ghostStatL.TextColor3=flashOnCooldown and C.red or C.grn
    local bgS=ghostBB:FindFirstChild("Frame") and ghostBB.Frame:FindFirstChildOfClass("UIStroke")
    if bgS then bgS.Color=flashOnCooldown and C.red or C.cyan end
end
RunService.RenderStepped:Connect(function() pcall(updateFlashGhost) end)

-- Flash TP
local flashEnabled=Cfg.flashOn; local sliderValue=Cfg.triggerChance/100; local activePrompts={}
local lagOnSteal=Cfg.lagOn

PPS.PromptButtonHoldBegan:Connect(function(prompt)
    if not flashEnabled or prompt.ActionText~="Steal" or activePrompts[prompt] then return end
    activePrompts[prompt]=true; flashOnCooldown=true
    local fired=false
    local fireAt=os.clock()+math.max(prompt.HoldDuration,0.001)*sliderValue
    local conn
    conn=RunService.Heartbeat:Connect(function()
        if fired then conn:Disconnect(); return end
        if not prompt or not prompt.Parent then conn:Disconnect(); activePrompts[prompt]=nil; flashOnCooldown=false; return end
        if os.clock()>=fireAt then
            fired=true; conn:Disconnect(); activePrompts[prompt]=nil
            -- Lag self before firing (25 iterations) for timing accuracy
            if lagOnSteal then lagSelf() end
            local char=lp.Character; local tool=char and char:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
            -- EXT Triggered fires immediately (bypasses 1.3s timer = faster + more accurate)
            task.spawn(function()
                local extFired=false
                pcall(function()
                    local conns=getconnections(prompt.Triggered)
                    if conns and #conns>0 then
                        for _,c in ipairs(conns) do if c.Function then task.spawn(c.Function) end end
                        extFired=true
                    end
                end)
                if not extFired then
                    pcall(function() fireproximityprompt(prompt,10000) end)
                    pcall(function() prompt:InputHoldBegin(); task.wait(0.04); prompt:InputHoldEnd() end)
                end
            end)
            -- Potion fires only when prompt is grabbed
            task.spawn(function() activatePotion() end)
            task.delay(0.8,function() flashOnCooldown=false end)
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function()
        if not fired then fired=true; activePrompts[prompt]=nil; conn:Disconnect(); flashOnCooldown=false end
    end)
end)

-- Speed
local stealSpdOn=Cfg.stealSpdOn; local STEAL_SPD_VAL=math.clamp(Cfg.stealSpdVal or 30,10,60)
local speedEnabled=stealSpdOn; local stealingSpeed=STEAL_SPD_VAL; local isStealing=false
local function applySpeed()
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid"); if not root or not hum then return end
    local dir=hum.MoveDirection
    if dir.Magnitude>0 then local spd=isStealing and stealingSpeed or 30; root.Velocity=Vector3.new(dir.X*spd,root.Velocity.Y,dir.Z*spd) end
end

-- Auto grab (EXT → Vander, fires at 95% instantly via EXT)
local grabEnabled=Cfg.grabOn; local grabInProg=false
local function findNearestGrab()
    local char=lp.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local myPos=root.Position; local nearest,nd=nil,GRAB_RADIUS
    for _,plot in ipairs(plots:GetChildren()) do
        if myPlotRef and plot==myPlotRef then continue end
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and (obj.ActionText=="Steal" or obj.ActionText=="Grab" or obj.ActionText:lower():find("steal")) then
                local parent=obj.Parent; local wp
                if parent:IsA("BasePart") then wp=parent.Position
                elseif parent:IsA("Attachment") then wp=parent.WorldPosition
                else local p=parent:FindFirstChildWhichIsA("BasePart",true); if p then wp=p.Position end end
                if wp then local d=(myPos-wp).Magnitude; if d<nd then nearest=obj;nd=d end end
            end
        end
    end
    return nearest
end
task.spawn(function()
    while true do
        task.wait(0.28+math.random()*0.06)
        if not grabEnabled or grabInProg then continue end
        local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local nearest=findNearestGrab(); if not nearest then continue end
        grabInProg=true
        task.spawn(function()
            local fired=false
            pcall(function()
                local hc=getconnections(nearest.PromptButtonHoldBegan)
                if hc and #hc>0 then
                    for _,c in ipairs(hc) do if c.Function then task.spawn(c.Function) end end
                    task.wait(0.06)
                    local tc=getconnections(nearest.Triggered)
                    if tc and #tc>0 then for _,c in ipairs(tc) do if c.Function then task.spawn(c.Function) end end; fired=true end
                end
            end)
            if not fired then
                pcall(function() fireproximityprompt(nearest,10000) end)
                pcall(function() nearest:InputHoldBegin(); task.wait(0.04); nearest:InputHoldEnd() end)
            end
            grabInProg=false
        end)
        if potionOn then activatePotion() end
    end
end)

-- Base Protector systems
local CARPET_TBL={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true,["Cupid's Wings"]=true}
local antiSteal=false; local autoKickBase=false; local lastPunish={}
local myStealPrompts={}
task.spawn(function() while task.wait(2) do
    myStealPrompts={}
    if myPlotRef then for _,obj in ipairs(myPlotRef:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText=="Steal" and obj.Enabled then table.insert(myStealPrompts,obj) end
    end end
end end)
local ADM_REMOTE_ref=function() return ADM_REMOTE end
local function punish(p)
    if not ADM_REMOTE or not p or p==lp then return end
    local uid=p.UserId; local now=tick()
    if lastPunish[uid] and now-lastPunish[uid]<0.5 then return end
    lastPunish[uid]=now
    pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)
    rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
    if autoKickBase then task.delay(0.05,function() lp:Kick("SAVED BY AETHEN 🫡") end) end
end
local function findThief()
    if #myStealPrompts>0 then
        local best,bd=nil,math.huge
        for _,prompt in ipairs(myStealPrompts) do
            if not prompt or not prompt.Parent then continue end
            local pPart=prompt.Parent; local pPos=pPart:IsA("BasePart") and pPart.Position or (pPart:IsA("Attachment") and pPart.WorldPosition); if not pPos then continue end
            local maxDist=math.max(prompt.MaxActivationDistance,8)
            for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then local d=(hrp.Position-pPos).Magnitude; if d<=maxDist and d<bd then bd=d;best=p end end end end
        end
        if best then return best end
    end
    if stealHitbox then
        local hbPos=stealHitbox.Position; local best,bd=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then local d=(hrp.Position-hbPos).Magnitude; if d<bd then bd=d;best=p end end end end
        return best
    end
    return nil
end
local function isPromptOnMyBase(prompt)
    if not myPlotRef then return false end
    local a=prompt.Parent; while a and a~=workspace do if a==myPlotRef then return true end; a=a.Parent end; return false
end
pcall(function()
    if not hookfunction or not fireproximityprompt then return end
    local old=fireproximityprompt
    hookfunction(fireproximityprompt,newcclosure(function(prompt,...)
        if antiSteal and (prompt.ActionText or ""):lower():find("steal") and isPromptOnMyBase(prompt) then
            local thief=findThief(); if thief then punish(thief) end
        end
        return old(prompt,...)
    end))
end)
task.spawn(function()
    pcall(function()
        local net=RS:WaitForChild("Packages"):WaitForChild("Net",8); if not net then return end
        local grabRE=net:FindFirstChild("RE/StealService/Grab"); local successRE=net:FindFirstChild("RE/StealService/StealingSuccess")
        if grabRE then grabRE.OnClientEvent:Connect(function() if antiSteal and ADM_REMOTE and myPlotRef then local t=findThief(); if t then punish(t) end end end) end
        if successRE then successRE.OnClientEvent:Connect(function() if antiSteal and ADM_REMOTE and myPlotRef then local t=findThief(); if t then punish(t) end end end) end
    end)
end)

-- Heartbeat: speed + admin panel CD update
local cmdBtnRefs={}
RunService.Heartbeat:Connect(function(dt)
    lastDt=dt; local now=tick()
    if speedEnabled then applySpeed() end
    for _,cmds in pairs(cmdBtnRefs) do
        for cmd,ib in pairs(cmds) do if ib and ib.Parent then
            local cd=rowCdEnd[cmd]
            if cd and cd>now then
                local rem=math.ceil(cd-now); if ib.Text~=tostring(rem) then ib.Text=tostring(rem); ib.TextSize=8; ib.TextColor3=C.red; ib.BackgroundColor3=Color3.fromRGB(55,7,7); ib.BackgroundTransparency=0.1 end
            else
                local icon=CMD_ICONS[cmd] or "?"
                if ib.Text~=icon then ib.Text=icon; ib.TextSize=10; ib.TextColor3=C.text; ib.BackgroundColor3=C.surf2; ib.BackgroundTransparency=0.2 end
            end
        end end
    end
end)
local lastDt=1/60  -- must be declared before Heartbeat

-- ═══════════════════════════════════════════════
-- GUI PANELS
-- ═══════════════════════════════════════════════

task.wait(0.15); vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end

-- Header box (top center)
local hdrW=210; local hdrH=80
local hdrX=(Cfg.pos_hdr and Cfg.pos_hdr.ox~=0 and Cfg.pos_hdr.ox) or math.floor(vp.X*0.5-hdrW*0.5)
local hdrY=(Cfg.pos_hdr and Cfg.pos_hdr.oy~=0 and Cfg.pos_hdr.oy) or 4
local hdrF=Instance.new("Frame",SG); hdrF.Size=UDim2.fromOffset(hdrW,hdrH); hdrF.Position=UDim2.fromOffset(hdrX,hdrY)
hdrF.BackgroundColor3=C.panel; hdrF.BackgroundTransparency=0.05; hdrF.BorderSizePixel=0; co(hdrF,10)
rotS(hdrF,C.acc); addParticles(hdrF,5,C.acc)
lb(hdrF,{Position=UDim2.fromOffset(0,5),Size=UDim2.new(1,0,0,17),Text="AETHEN FLASH TP  v0.2",TextSize=10,Font=Enum.Font.GothamBlack,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
lb(hdrF,{Position=UDim2.fromOffset(0,21),Size=UDim2.new(1,0,0,12),Text="made by r9qbx - aethen hub",TextSize=7,Font=Enum.Font.Gotham,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
mkSep(hdrF,34,C.acc)
local fpsLb=lb(hdrF,{Position=UDim2.fromOffset(0,37),Size=UDim2.new(1,0,0,12),Text="⚡ FPS --   📡 -- ms",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=C.grn,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
task.spawn(function() while task.wait(0.7) do
    if not fpsLb.Parent then break end
    local fps=math.min(999,math.floor(1/math.max(lastDt,0.001))); local ping=0
    pcall(function() ping=math.floor(lp:GetNetworkPing()*1000) end)
    fpsLb.Text="⚡ FPS "..fps.."   📡 "..ping.."ms"
    fpsLb.TextColor3=fps<40 and C.red or fps<55 and C.yel or C.grn
end end)
local rsPnlBtn=mkBtn(hdrF,"⟳ Reset Panels",UDim2.fromOffset(94,14),UDim2.fromOffset(4,53),C.surf,C.dim,5)
rsPnlBtn.TextSize=7; rsPnlBtn.ZIndex=4
local grabStatusBtn=mkBtn(hdrF,"⬡ Grab: ON",UDim2.fromOffset(88,14),UDim2.fromOffset(102,53),C.surf,C.grn,5)
grabStatusBtn.TextSize=7; grabStatusBtn.ZIndex=4
local function updGrabHdr() grabStatusBtn.Text=grabEnabled and "⬡ Grab: ON" or "⬡ Grab: OFF"; grabStatusBtn.TextColor3=grabEnabled and C.grn or C.dim
    TweenService:Create(grabStatusBtn,TweenInfo.new(0.1),{BackgroundColor3=grabEnabled and Color3.fromRGB(6,18,10) or C.surf}):Play()
end
updGrabHdr(); grabStatusBtn.MouseButton1Click:Connect(function() grabEnabled=not grabEnabled; Cfg.grabOn=grabEnabled; save(); updGrabHdr() end)
dragSave(hdrF,hdrF,"pos_hdr")

-- Ragdoll Self + Pot+Ragdoll buttons (y=50 area, near header)
local ragF=Instance.new("Frame",SG); ragF.Size=UDim2.fromOffset(88,14); ragF.Position=UDim2.new(0.5,-91,0,87)
ragF.BackgroundColor3=Color3.fromRGB(10,6,22); ragF.BackgroundTransparency=0.05; ragF.BorderSizePixel=0; co(ragF,4); ms(ragF,1,C.acc,0.28)
local ragBtn=Instance.new("TextButton",ragF); ragBtn.Size=UDim2.new(1,0,1,0); ragBtn.BackgroundTransparency=1
ragBtn.Text="🤸 Ragdoll Self"; ragBtn.Font=Enum.Font.GothamBold; ragBtn.TextSize=7; ragBtn.TextColor3=Color3.fromRGB(185,150,255); ragBtn.BorderSizePixel=0; ragBtn.AutoButtonColor=false
local prF=Instance.new("Frame",SG); prF.Size=UDim2.fromOffset(88,14); prF.Position=UDim2.new(0.5,3,0,87)
prF.BackgroundColor3=Color3.fromRGB(10,6,22); prF.BackgroundTransparency=0.05; prF.BorderSizePixel=0; co(prF,4); ms(prF,1,Color3.fromRGB(90,55,195),0.28)
local prBtn=Instance.new("TextButton",prF); prBtn.Size=UDim2.new(1,0,1,0); prBtn.BackgroundTransparency=1
prBtn.Text="Pot + Ragdoll"; prBtn.Font=Enum.Font.GothamBold; prBtn.TextSize=7; prBtn.TextColor3=Color3.fromRGB(158,118,235); prBtn.BorderSizePixel=0; prBtn.AutoButtonColor=false
ragBtn.MouseButton1Click:Connect(function()
    if ADM_REMOTE then pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end); rowCdEnd["ragdoll"]=tick()+(ROW_CD["ragdoll"] or 30) end
end)
prBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local char=lp.Character
        if char then pcall(function()
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local bp=lp:FindFirstChild("Backpack"); local pot=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion"))
            if pot then hum:EquipTool(pot); task.wait(0.1); pot:Activate() end
        end) end
        task.wait(0.5)
        if ADM_REMOTE then pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end); rowCdEnd["ragdoll"]=tick()+(ROW_CD["ragdoll"] or 30) end
    end)
end)

-- ═══ FLASH TP PANEL ═══
local FP_W=148; local FP_H=280
local FP_defX=math.floor(vp.X-FP_W-4); local FP_defY=5
local FP,_,fpMin=mkP(FP_defX,FP_defY,FP_W,FP_H,"⚡ AETHENS FLASH TP",C.blu,"pos_FP")
local fpC=mkF(FP,25,FP_H-25-4,fpMin)

-- Lag on steal toggle (power auto 25, hidden)
local lagRow,lagSet=mkPill(fpC,"Lag On Steal",4,C.yel)
lagRow.MouseButton1Click:Connect(function() lagOnSteal=not lagOnSteal; lagSet(lagOnSteal); Cfg.lagOn=lagOnSteal; save() end)
if lagOnSteal then lagSet(true) end

-- Giant Potion toggle
local potRow,potSet=mkPill(fpC,"Giant Potion",27,C.acc)
potRow.MouseButton1Click:Connect(function() potionOn=not potionOn; Cfg.potionOn=potionOn; save(); potSet(potionOn) end)
if potionOn then potSet(true) end

mkSep(fpC,49,C.bord)

-- Flash TP toggle
local togRow=Instance.new("Frame"); togRow.Size=UDim2.fromOffset(FP_W-8,20); togRow.Position=UDim2.fromOffset(4,53)
togRow.BackgroundColor3=C.surf; togRow.BackgroundTransparency=0.2; togRow.BorderSizePixel=0; togRow.Parent=fpC; co(togRow,6)
local togRS=ms(togRow,1,C.bord,0.48)
local togLbl=lb(togRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-34,1,0),Text="Flash TP",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
local fpill=Instance.new("Frame"); fpill.Size=UDim2.fromOffset(23,11); fpill.Position=UDim2.new(1,-26,0.5,-5.5); fpill.BackgroundColor3=C.surf2; fpill.BorderSizePixel=0; fpill.Parent=togRow; co(fpill,12)
local fknob=Instance.new("Frame"); fknob.Size=UDim2.fromOffset(8,8); fknob.Position=UDim2.new(0,1.5,0.5,-4); fknob.BackgroundColor3=C.dim; fknob.BorderSizePixel=0; fknob.Parent=fpill; co(fknob,8)
local togB=Instance.new("TextButton"); togB.Size=UDim2.new(1,0,1,0); togB.BackgroundTransparency=1; togB.Text=""; togB.Parent=togRow
local function updFl()
    TweenService:Create(togRow,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and Color3.fromRGB(5,10,24) or C.surf,BackgroundTransparency=flashEnabled and 0.1 or 0.2}):Play()
    TweenService:Create(togRS,TweenInfo.new(0.12),{Color=flashEnabled and C.blu or C.bord,Transparency=flashEnabled and 0.18 or 0.48}):Play()
    TweenService:Create(fpill,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and C.blu or C.surf2}):Play()
    TweenService:Create(fknob,TweenInfo.new(0.12),{Position=flashEnabled and UDim2.new(1,-9.5,0.5,-4) or UDim2.new(0,1.5,0.5,-4),BackgroundColor3=flashEnabled and C.white or C.dim}):Play()
    togLbl.TextColor3=flashEnabled and C.text or C.dim
end
updFl(); togB.MouseButton1Click:Connect(function() flashEnabled=not flashEnabled; Cfg.flashOn=flashEnabled; save(); updFl() end)

lb(fpC,{Position=UDim2.fromOffset(4,77),Size=UDim2.fromOffset(FP_W-8,10),Text="Trigger: "..Cfg.triggerChance.."%",TextSize=7,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
local slBg=Instance.new("Frame"); slBg.Size=UDim2.fromOffset(FP_W-8,5); slBg.Position=UDim2.fromOffset(4,89); slBg.BackgroundColor3=C.surf; slBg.BorderSizePixel=0; slBg.Parent=fpC; co(slBg,3)
local slFill=Instance.new("Frame"); slFill.Size=UDim2.new(sliderValue,0,1,0); slFill.BackgroundColor3=C.blu; slFill.BorderSizePixel=0; slFill.Parent=slBg; co(slFill,3)
local slK=Instance.new("Frame"); slK.Size=UDim2.fromOffset(10,10); slK.AnchorPoint=Vector2.new(0.5,0.5); slK.Position=UDim2.new(sliderValue,0,0.5,0); slK.BackgroundColor3=C.white; slK.BorderSizePixel=0; slK.Parent=slBg; co(slK,5)
local slOn=false
local function setTr(pct) pct=math.clamp(pct,0,1); sliderValue=pct; Cfg.triggerChance=math.floor(pct*100); slFill.Size=UDim2.new(pct,0,1,0); slK.Position=UDim2.new(pct,0,0.5,0)
    lb(fpC,{}); for _,v in ipairs(fpC:GetChildren()) do if v:IsA("TextLabel") and v.Position==UDim2.fromOffset(4,77) then v.Text="Trigger: "..math.floor(pct*100).."%" end end end
slBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slOn=true;setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if slOn then slOn=false;save() end end end)
UIS.InputChanged:Connect(function(i) if not slOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
lb(fpC,{Position=UDim2.fromOffset(4,97),Size=UDim2.fromOffset(FP_W-8,8),Text="91% = best  ·  EXT bypass on",TextSize=6,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})

mkSep(fpC,108,C.bord)

-- EXTRAS section header
lb(fpC,{Position=UDim2.fromOffset(4,112),Size=UDim2.fromOffset(FP_W-8,11),Text="── EXTRAS ──",TextSize=7,Font=Enum.Font.GothamBlack,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center})

-- Speed
local ssB,ssSet=mkPill(fpC,"Steal Speed",126,C.grn)
ssB.MouseButton1Click:Connect(function() stealSpdOn=not stealSpdOn; isStealing=stealSpdOn; speedEnabled=stealSpdOn; ssSet(stealSpdOn); Cfg.stealSpdOn=stealSpdOn; save() end)
if stealSpdOn then ssSet(true); isStealing=true; speedEnabled=true end
numRow(fpC,"Speed",STEAL_SPD_VAL,10,60,148,FP_W,function(v) STEAL_SPD_VAL=v; stealingSpeed=v; Cfg.stealSpdVal=v; save() end)

mkSep(fpC,170,C.bord)
lb(fpC,{Position=UDim2.fromOffset(4,173),Size=UDim2.fromOffset(FP_W-8,11),Text="── VISUALS ──",TextSize=7,Font=Enum.Font.GothamBlack,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center})

-- Brainrot ESP
local brainESPB,brainESPSet=mkPill(fpC,"Brainrot ESP",187,C.acc)
brainESPB.MouseButton1Click:Connect(function() if brainrotESPEnabled then stopBrainrotESP(); brainESPSet(false) else startBrainrotESP(); brainESPSet(true) end end)

-- Friends ESP
local friendESPB,friendESPSet=mkPill(fpC,"Friends ESP",209,C.grn)
friendESPB.MouseButton1Click:Connect(function() if friendESPEnabled then stopFriendESP(); friendESPSet(false) else startFriendESP(); friendESPSet(true) end end)

-- Base Xray (with warning)
local xrayRow=Instance.new("Frame"); xrayRow.Size=UDim2.new(1,-8,0,19); xrayRow.Position=UDim2.new(0,4,0,231)
xrayRow.BackgroundColor3=C.surf; xrayRow.BackgroundTransparency=0.2; xrayRow.BorderSizePixel=0; xrayRow.Parent=fpC; co(xrayRow,6); ms(xrayRow,1,C.bord,0.5)
lb(xrayRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-34,1,0),Text="Base Xray ⚠detected",TextSize=6,Font=Enum.Font.GothamBold,TextColor3=C.red,TextXAlignment=Enum.TextXAlignment.Left})
local xrTrack=Instance.new("Frame"); xrTrack.Size=UDim2.fromOffset(23,11); xrTrack.Position=UDim2.new(1,-26,0.5,-5.5); xrTrack.BackgroundColor3=C.surf2; xrTrack.BorderSizePixel=0; xrTrack.Parent=xrayRow; co(xrTrack,12)
local xrKnob=Instance.new("Frame"); xrKnob.Size=UDim2.fromOffset(8,8); xrKnob.Position=UDim2.new(0,1.5,0.5,-4); xrKnob.BackgroundColor3=C.dim; xrKnob.BorderSizePixel=0; xrKnob.Parent=xrTrack; co(xrKnob,8)
local xrBtn=Instance.new("TextButton"); xrBtn.Size=UDim2.new(1,0,1,0); xrBtn.BackgroundTransparency=1; xrBtn.Text=""; xrBtn.Parent=xrayRow
local xrOn2=false; local function updXr(v) xrOn2=v; TweenService:Create(xrTrack,TweenInfo.new(0.12),{BackgroundColor3=v and C.red or C.surf2}):Play(); TweenService:Create(xrKnob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-9.5,0.5,-4) or UDim2.new(0,1.5,0.5,-4),BackgroundColor3=v and C.white or C.dim}):Play() end
xrBtn.MouseButton1Click:Connect(function() if xrOn2 then disableBaseXray(); updXr(false) else enableBaseXray(); updXr(true) end end)

-- Brainrot Transparency
local btRow=Instance.new("Frame"); btRow.Size=UDim2.new(1,-8,0,19); btRow.Position=UDim2.new(0,4,0,253)
btRow.BackgroundColor3=C.surf; btRow.BackgroundTransparency=0.2; btRow.BorderSizePixel=0; btRow.Parent=fpC; co(btRow,6); ms(btRow,1,C.bord,0.5)
lb(btRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-34,1,0),Text="Brainrot Trans ⚠risk",TextSize=6,Font=Enum.Font.GothamBold,TextColor3=C.yel,TextXAlignment=Enum.TextXAlignment.Left})
local btTrack=Instance.new("Frame"); btTrack.Size=UDim2.fromOffset(23,11); btTrack.Position=UDim2.new(1,-26,0.5,-5.5); btTrack.BackgroundColor3=C.surf2; btTrack.BorderSizePixel=0; btTrack.Parent=btRow; co(btTrack,12)
local btKnob=Instance.new("Frame"); btKnob.Size=UDim2.fromOffset(8,8); btKnob.Position=UDim2.new(0,1.5,0.5,-4); btKnob.BackgroundColor3=C.dim; btKnob.BorderSizePixel=0; btKnob.Parent=btTrack; co(btKnob,8)
local btBtn=Instance.new("TextButton"); btBtn.Size=UDim2.new(1,0,1,0); btBtn.BackgroundTransparency=1; btBtn.Text=""; btBtn.Parent=btRow
local btOn2=false; local function updBT(v) btOn2=v; TweenService:Create(btTrack,TweenInfo.new(0.12),{BackgroundColor3=v and C.yel or C.surf2}):Play(); TweenService:Create(btKnob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-9.5,0.5,-4) or UDim2.new(0,1.5,0.5,-4),BackgroundColor3=v and C.white or C.dim}):Play() end
btBtn.MouseButton1Click:Connect(function() if btOn2 then disableBrainTrans(); updBT(false) else enableBrainTrans(); updBT(true) end end)

lb(fpC,{Position=UDim2.fromOffset(4,274),Size=UDim2.fromOffset(FP_W-8,9),Text=DISCORD_LINK,TextSize=7,Font=Enum.Font.Gotham,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center})

-- ═══ AETHENS PANEL ═══
local AP_W=130; local AP_CH=96; local AP_H=25+AP_CH+8
local AP_defX=4; local AP_defY=hdrH+4+87+16+4
local AP,_,apMin=mkP(AP_defX,AP_defY,AP_W,AP_H,"◈ AETHENS",C.acc,"pos_AP")
local apC=mkF(AP,25,AP_CH,apMin); local aY=4
local function apB(text,tc,bg)
    local b=mkBtn(apC,text,UDim2.fromOffset(AP_W-8,20),UDim2.fromOffset(4,aY),bg or C.surf,tc,6); b.TextSize=8; aY=aY+24; return b
end
local rejB=apB("↩ Rejoin",C.acc); rejB.MouseButton1Click:Connect(function() rejB.Text="..."; pcall(function() if reconnect then reconnect() elseif syn and syn.reconnect then syn.reconnect() else TeleportService:Teleport(game.PlaceId,lp) end end) end)
local kickB=apB("✕ Kick Self",C.red,Color3.fromRGB(26,5,8)); kickB.MouseButton1Click:Connect(function() kickB.Text="..."; lp:Kick(DISCORD_LINK) end)
local rstB=apB("↺ Instant Reset",C.red,Color3.fromRGB(26,5,8)); rstB.MouseButton1Click:Connect(function() task.spawn(doReset) end)
local camBusy=false; local camB=apB("✦ AUTO ALLIGN",C.text)
camB.MouseButton1Click:Connect(function()
    if camBusy then return end; camBusy=true; camB.Text="Aligning..."
    task.spawn(function() pcall(doAutoAlign); camB.Text="✦ AUTO ALLIGN"; camBusy=false end)
end)

-- ═══ ADMIN PANEL ═══
local RCMDS={{cmd="ragdoll",icon="🤸"},{cmd="balloon",icon="🎈"},{cmd="tiny",icon="🐜"},{cmd="jail",icon="🔒"},{cmd="rocket",icon="🚀"}}
local IW2=15; local IH2=16; local IG2=2; local ADM_W=178; local ITOT=#RCMDS*(IW2+IG2)-IG2; local CSTART=(ADM_W-10)-ITOT-2
local ADM_defX=math.floor(vp.X-ADM_W-4); local ADM_defY=FP_H+FP_defY+4
local ADM,_,admMin=mkP(ADM_defX,ADM_defY,ADM_W,24,"❖ ADMIN",C.org,"pos_ADM")
local pScroll=Instance.new("ScrollingFrame"); pScroll.Size=UDim2.fromOffset(ADM_W-6,0); pScroll.Position=UDim2.fromOffset(3,22)
pScroll.BackgroundColor3=C.bg; pScroll.BackgroundTransparency=0.65; pScroll.BorderSizePixel=0
pScroll.ScrollBarThickness=2; pScroll.ScrollBarImageColor3=C.org; pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; pScroll.CanvasSize=UDim2.new(0,0,0,0); pScroll.Parent=ADM; co(pScroll,4)
local pLayout=Instance.new("UIListLayout"); pLayout.Padding=UDim.new(0,2); pLayout.SortOrder=Enum.SortOrder.Name; pLayout.Parent=pScroll
Instance.new("UIPadding",pScroll).PaddingTop=UDim.new(0,2)
local admFolded=false
local function resADM()
    if admFolded then return end; local ch=math.min(pLayout.AbsoluteContentSize.Y+4,115)
    pScroll.Size=UDim2.fromOffset(ADM_W-6,ch); ADM.Size=UDim2.fromOffset(ADM_W,22+ch+3)
end
pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resADM)
admMin.MouseButton1Click:Connect(function()
    admFolded=not admFolded; admMin.Text=admFolded and "+" or "─"; pScroll.Visible=not admFolded
    if admFolded then TweenService:Create(ADM,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(ADM_W,24)}):Play()
    else local ch=math.min(pLayout.AbsoluteContentSize.Y+4,115); TweenService:Create(ADM,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(ADM_W,22+ch+3)}):Play() end
end)
local pCards={}
local function refreshPlayers()
    for _,c in pairs(pCards) do pcall(function() c:Destroy() end) end; pCards={}; cmdBtnRefs={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame"); card.Name=p.Name; card.Size=UDim2.new(1,-4,0,28)
        card.BackgroundColor3=C.surf; card.BackgroundTransparency=0.2; card.BorderSizePixel=0; card.Parent=pScroll; co(card,5)
        local cs=ms(card,1,C.bord,0.55)
        local cz=Instance.new("TextButton"); cz.Size=UDim2.fromOffset(CSTART,28); cz.BackgroundTransparency=1; cz.Text=""; cz.AutoButtonColor=false; cz.Parent=card
        local ava=Instance.new("ImageLabel"); ava.Size=UDim2.fromOffset(17,17); ava.Position=UDim2.new(0,3,0.5,-8.5); ava.BackgroundColor3=C.surf2; ava.BorderSizePixel=0; ava.Parent=card; co(ava,9)
        task.spawn(function() local ok,img=pcall(Players.GetUserThumbnailAsync,Players,p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48); if ok then ava.Image=img end end)
        lb(card,{Position=UDim2.new(0,22,0,2),Size=UDim2.fromOffset(CSTART-25,13),Text=p.DisplayName,TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        lb(card,{Position=UDim2.new(0,22,0,15),Size=UDim2.fromOffset(CSTART-25,10),Text="@"..p.Name,TextSize=6,Font=Enum.Font.Gotham,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        cmdBtnRefs[p.UserId]={}
        for i,def in ipairs(RCMDS) do
            local bx=CSTART+2+(i-1)*(IW2+IG2)
            local ib=Instance.new("TextButton"); ib.Size=UDim2.fromOffset(IW2,IH2); ib.Position=UDim2.new(0,bx,0.5,-IH2/2)
            ib.BackgroundColor3=C.surf2; ib.BackgroundTransparency=0.2; ib.Text=def.icon; ib.TextSize=10; ib.TextColor3=C.text
            ib.Font=Enum.Font.GothamBold; ib.BorderSizePixel=0; ib.AutoButtonColor=false; ib.Parent=card; co(ib,4); ms(ib,1,C.bord,0.5)
            cmdBtnRefs[p.UserId][def.cmd]=ib
            local pd=p; local dc=def.cmd
            ib.MouseButton1Click:Connect(function() fireCmd(pd,dc) end)
        end
        local pd=p
        cz.MouseButton1Click:Connect(function()
            for _,c2 in pairs(pCards) do local s2=c2:FindFirstChildOfClass("UIStroke"); if s2 then s2.Color=C.bord;s2.Transparency=0.55 end; c2.BackgroundTransparency=0.2 end
            cs.Color=C.org; cs.Transparency=0.08; card.BackgroundTransparency=0.08; fireClick(pd)
        end)
        pCards[p.UserId]=card
    end
    task.defer(resADM)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshPlayers() end)
task.delay(2,refreshPlayers)

-- ═══ BASE PROTECTOR (super small) ═══
local BP_W=120; local BP_H=25+40+6
local BP_defX=4; local BP_defY=math.floor(vp.Y*0.7)
local BP,_,bpMin=mkP(BP_defX,BP_defY,BP_W,BP_H,"◆ BASE",C.red,"pos_BP")
local bpC=mkF(BP,25,40+6,bpMin)
local asB,asSet=mkPill(bpC,"Anti Steal",4,C.text); asB.MouseButton1Click:Connect(function() antiSteal=not antiSteal; asSet(antiSteal) end)
local akB,akSet=mkPill(bpC,"Auto Kick",24,C.red); akB.MouseButton1Click:Connect(function() autoKickBase=not autoKickBase; akSet(autoKickBase) end)

-- ═══ Reset panels logic ═══
local allPanels={
    {f=FP,key="pos_FP",dX=FP_defX,dY=FP_defY},
    {f=AP,key="pos_AP",dX=AP_defX,dY=AP_defY},
    {f=ADM,key="pos_ADM",dX=ADM_defX,dY=ADM_defY},
    {f=BP,key="pos_BP",dX=BP_defX,dY=BP_defY},
    {f=hdrF,key="pos_hdr",dX=hdrX,dY=hdrY},
}
rsPnlBtn.MouseButton1Click:Connect(function()
    local popup=Instance.new("Frame",SG); popup.Size=UDim2.fromOffset(192,64); popup.Position=UDim2.new(0.5,-96,0.38,-32)
    popup.BackgroundColor3=C.panel; popup.BackgroundTransparency=0.05; popup.BorderSizePixel=0; co(popup,10)
    ms(popup,1.2,C.acc,0.18)
    lb(popup,{Size=UDim2.new(1,0,0,28),Position=UDim2.fromOffset(0,5),Text="Reset panels to defaults?",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.text})
    local yB=mkBtn(popup,"Yes",UDim2.fromOffset(80,22),UDim2.fromOffset(12,38),Color3.fromRGB(8,30,12),C.grn)
    local nB=mkBtn(popup,"No",UDim2.fromOffset(80,22),UDim2.fromOffset(100,38),Color3.fromRGB(30,6,8),C.red)
    nB.MouseButton1Click:Connect(function() popup:Destroy() end)
    yB.MouseButton1Click:Connect(function()
        for _,pd in ipairs(allPanels) do
            pd.f.Position=UDim2.fromOffset(pd.dX,pd.dY)
            Cfg[pd.key]={ox=pd.dX,oy=pd.dY}
        end; save(); popup:Destroy()
    end)
end)

print("Aethen Hub v0.2 | r9qbx")
