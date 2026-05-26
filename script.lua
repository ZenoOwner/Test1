-- Aethen Hub v0.9 | @r9qbx | discord.gg/hyZGbJP9
local DISCORD="discord.gg/hyZGbJP9"
local Players=game:GetService("Players"); local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService"); local RS=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService"); local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui"); local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting"); local ContextActionService=game:GetService("ContextActionService")
local lp=Players.LocalPlayer; local cam=workspace.CurrentCamera

for _,v in ipairs(CoreGui:GetChildren()) do if v:IsA("ScreenGui") and v.Name:sub(1,5)=="Aeth_" then v:Destroy() end end
local SG=Instance.new("ScreenGui"); SG.Name="Aeth_Hub"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Global; SG.IgnoreGuiInset=true; SG.Parent=CoreGui

local T={bg=Color3.fromRGB(5,5,9),panel=Color3.fromRGB(7,7,13),surf=Color3.fromRGB(12,12,20),surf2=Color3.fromRGB(18,18,30),a1=Color3.fromRGB(225,225,240),a2=Color3.fromRGB(170,170,195),white=Color3.new(1,1,1),dim=Color3.fromRGB(100,100,122),str=Color3.fromRGB(150,150,178),red=Color3.fromRGB(255,65,65),grn=Color3.fromRGB(52,218,88),yel=Color3.fromRGB(255,200,40),pur=Color3.fromRGB(160,100,255)}

-- GUI Helpers
local function co(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 7) end
local function ms(p,th,col,tr) local s=Instance.new("UIStroke",p); s.Thickness=th or 1; s.Color=col or T.str; s.Transparency=tr or 0.38; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function lb(par,props) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextColor3=T.white; l.BorderSizePixel=0; for k,v in pairs(props) do l[k]=v end; l.Parent=par; return l end
local function btn(par,text,sz,pos,bg) local b=Instance.new("TextButton"); b.Size=sz; b.Position=pos; b.BackgroundColor3=bg or T.surf; b.BackgroundTransparency=0.22; b.Text=text; b.TextColor3=T.white; b.Font=Enum.Font.GothamBold; b.TextSize=9; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=par; co(b,5); ms(b,1,T.str,0.44); return b end
local function rotS(f,col) local s=ms(f,1.3,col,0.22); local g=Instance.new("UIGradient",s); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(0.25,Color3.new(0,0,0)),ColorSequenceKeypoint.new(0.5,col or T.a1),ColorSequenceKeypoint.new(0.75,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}; task.spawn(function() while s and s.Parent do g.Rotation=(g.Rotation+0.9)%360; task.wait(0.016) end end) end
local function particles(parent) for i=1,3 do local p=Instance.new("Frame",parent); p.BackgroundColor3=Color3.fromRGB(200,210,255); p.BackgroundTransparency=0.5; p.BorderSizePixel=0; p.ZIndex=0; local sz=math.random(2,4); p.Size=UDim2.fromOffset(sz,sz); local sx=math.random(); p.Position=UDim2.new(sx,0,1.05,0); co(p,5); task.spawn(function() while p and p.Parent do local nx=math.clamp(sx+math.random(-8,8)/100,0.02,0.98); TweenService:Create(p,TweenInfo.new(math.random(4,7),Enum.EasingStyle.Linear),{Position=UDim2.new(nx,0,-0.05,0),BackgroundTransparency=1}):Play(); task.wait(math.random(4,7)); if p and p.Parent then p.BackgroundTransparency=0.5; sx=math.random(); p.Position=UDim2.new(sx,0,1.05,0) end end end) end end
local function clamp_pos(f) local vp=cam.ViewportSize; local px=math.clamp(f.Position.X.Offset,0,vp.X-f.Size.X.Offset); local py=math.clamp(f.Position.Y.Offset,0,vp.Y-f.Size.Y.Offset); f.Position=UDim2.fromOffset(px,py) end
local function drag(h,f) local on,ds,sp=false,nil,nil; h.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=true; ds=i.Position; sp=f.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then on=false; clamp_pos(f) end end) end end); UIS.InputChanged:Connect(function(i) if not on then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-ds; f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y); clamp_pos(f) end end) end
local function mkPanel(x,y,w,h,title,col) local f=Instance.new("Frame"); f.Size=UDim2.fromOffset(w,h); f.Position=UDim2.fromOffset(x,y); f.BackgroundColor3=T.panel; f.BackgroundTransparency=0.14; f.BorderSizePixel=0; f.ClipsDescendants=true; f.Parent=SG; co(f,9); rotS(f,col or T.a1); particles(f); local hdr=Instance.new("Frame",f); hdr.Size=UDim2.new(1,0,0,22); hdr.BackgroundColor3=T.surf; hdr.BackgroundTransparency=0.18; hdr.BorderSizePixel=0; co(hdr,9); Instance.new("Frame",hdr).Size,Instance.new("Frame",hdr).BackgroundColor3=UDim2.new(1,0,0.5,0),T.surf; local sep=Instance.new("Frame",f); sep.Size=UDim2.new(1,-8,0,1); sep.Position=UDim2.fromOffset(4,22); sep.BackgroundColor3=T.str; sep.BackgroundTransparency=0.7; sep.BorderSizePixel=0; if title then lb(hdr,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-8,1,0),Text=title,TextSize=8,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.a1}) end; local content=Instance.new("Frame",f); content.Size=UDim2.new(1,0,1,-23); content.Position=UDim2.fromOffset(0,23); content.BackgroundTransparency=1; content.BorderSizePixel=0; drag(hdr,f); return f,hdr,content end
local function toggle(parent,label,y,col) local row=Instance.new("Frame"); row.Size=UDim2.new(1,-8,0,19); row.Position=UDim2.new(0,4,0,y); row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.3; row.BorderSizePixel=0; row.Parent=parent; co(row,5); local rs=ms(row,1,T.str,0.55); lb(row,{Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-32,1,0),Text=label,TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left}); local track=Instance.new("Frame",row); track.Size=UDim2.fromOffset(24,11); track.Position=UDim2.new(1,-27,0.5,-5.5); track.BackgroundColor3=T.surf2; track.BorderSizePixel=0; co(track,11); local knob=Instance.new("Frame",track); knob.Size=UDim2.fromOffset(7,7); knob.Position=UDim2.new(0,2,0.5,-3.5); knob.BackgroundColor3=T.a2; knob.BorderSizePixel=0; co(knob,7); local pb=Instance.new("TextButton",row); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1; pb.Text=""; local c2=col or T.a1; local function set(v) TweenService:Create(track,TweenInfo.new(0.1),{BackgroundColor3=v and c2 or T.surf2}):Play(); TweenService:Create(knob,TweenInfo.new(0.1),{Position=v and UDim2.new(1,-9,0.5,-3.5) or UDim2.new(0,2,0.5,-3.5),BackgroundColor3=v and T.white or T.a2}):Play(); TweenService:Create(rs,TweenInfo.new(0.1),{Color=v and c2 or T.str,Transparency=v and 0.15 or 0.55}):Play(); local rl=row:FindFirstChildOfClass("TextLabel"); if rl then rl.TextColor3=v and T.white or T.dim end end; return pb,set end
local function sBtn(par,text,x,y,w,h2,col) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(w,h2 or 18); b.Position=UDim2.fromOffset(x,y); b.BackgroundColor3=col or T.surf2; b.BackgroundTransparency=0.2; b.Text=text; b.TextColor3=T.white; b.Font=Enum.Font.GothamBold; b.TextSize=8; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=par; co(b,4); return b end

task.wait(0.1); local vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end
local isStealing=false

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- BACKGROUND SYSTEMS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
if not _G._AethBG then
    _G._AethBG=true
    -- Anti-ragdoll
    RunService.Heartbeat:Connect(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart"); if not (hum and root) then return end
        local s=hum:GetState(); local rag=(s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown)
        if rag then
            for _,d in ipairs(char:GetDescendants()) do if d:IsA("BallSocketConstraint") then d:Destroy() end end
            for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
            if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            cam.CameraSubject=hum; root.Anchored=false; root.AssemblyLinearVelocity=Vector3.zero
        end
    end)
    -- Anti-sentry v2
    local sentryFirstSeen={}; local sentryTarget=nil
    local function isMySentry(obj) local id=obj.Name:match("Sentry_(%d+)") or obj.Name:match("Beehive_(%d+)") or obj.Name:match("Turret_(%d+)"); if id and tonumber(id)==lp.UserId then return true end; local a=obj:GetAttribute("OwnerId") or obj:GetAttribute("PlayerId") or obj:GetAttribute("Owner"); return a and tonumber(tostring(a))==lp.UserId end
    RunService.Heartbeat:Connect(function()
        if isStealing then sentryTarget=nil; return end
        local char=lp.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end; local now=tick()
        if sentryTarget and sentryTarget.Parent then
            local hum=char:FindFirstChildOfClass("Humanoid"); if hum then local weapon=(lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat"); if weapon then if weapon.Parent==lp.Backpack then hum:EquipTool(weapon) end; pcall(function() weapon:Activate() end) end end
            local m=sentryTarget:IsA("BasePart") and sentryTarget or (sentryTarget:IsA("Model") and (sentryTarget.PrimaryPart or sentryTarget:FindFirstChildWhichIsA("BasePart"))); if m then m.CFrame=hrp.CFrame*CFrame.new(0,0,-5) end
        else
            sentryTarget=nil
            for obj in pairs(sentryFirstSeen) do if not obj.Parent then sentryFirstSeen[obj]=nil end end
            for _,obj in pairs(workspace:GetChildren()) do
                if (obj.Name:find("Sentry") or obj.Name:find("Turret")) and not isMySentry(obj) then
                    local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                    if part and (hrp.Position-part.Position).Magnitude<=220 then
                        if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=now end
                        if now-sentryFirstSeen[obj]>=3 then sentryTarget=obj; break end
                    end
                end
            end
        end
    end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- PLOT / BASE DETECTION
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local myPlotRef=nil; local stealHitbox=nil
task.spawn(function()
    while true do task.wait(1)
        if not myPlotRef then
            local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
            for _,p in ipairs(plots:GetChildren()) do
                local sign=p:FindFirstChild("PlotSign"); if not sign then continue end
                local yb=sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") and yb.Enabled then myPlotRef=p; stealHitbox=p:FindFirstChild("StealHitbox",true); break end
                local tl=sign:FindFirstChild("TextLabel",true); if tl then local t=tl.Text:lower(); if t:find(lp.Name:lower(),1,true) then myPlotRef=p; stealHitbox=p:FindFirstChild("StealHitbox",true); break end end
            end
        end
    end
end)
local function isMyPlot(plot) if myPlotRef and plot==myPlotRef then return true end; local sign=plot:FindFirstChild("PlotSign"); if not sign then return false end; local yb=sign:FindFirstChild("YourBase"); return yb and yb:IsA("BillboardGui") and yb.Enabled end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- ESPs
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local ESPTAG="Aeth_"..tostring(math.random(1000,9999))
local function mkPlayerESP(plr)
    if plr==lp then return end; local char=plr.Character; if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end
    local sel=Instance.new("SelectionBox",char); sel.Name=ESPTAG; sel.Adornee=char; sel.Color3=T.white; sel.LineThickness=0.05; sel.SurfaceTransparency=0.9; sel.SurfaceColor3=T.white
    local bb=Instance.new("BillboardGui",char); bb.Name=ESPTAG.."N"; bb.Adornee=char:FindFirstChild("Head") or hrp; bb.Size=UDim2.fromOffset(120,30); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
    local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=T.bg; bg.BackgroundTransparency=0.25; bg.BorderSizePixel=0; co(bg,4); ms(bg,1,T.a1,0.3)
    lb(bg,{Size=UDim2.new(1,0,0.55,0),BackgroundTransparency=1,Text=plr.DisplayName,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=T.white})
    local heldLbl=lb(bg,{Size=UDim2.new(1,0,0.45,0),Position=UDim2.new(0,0,0.55,0),BackgroundTransparency=1,Text="",Font=Enum.Font.Gotham,TextSize=7,TextColor3=T.dim})
    task.spawn(function() while bb.Parent do task.wait(0.5); local tool=char and char:FindFirstChildOfClass("Tool"); heldLbl.Text=tool and tool.Name or "" end end)
end
local espOn=false
local function enablePlayerESP() if espOn then return end; espOn=true; for _,p in ipairs(Players:GetPlayers()) do if p~=lp then task.defer(function() mkPlayerESP(p) end) end end; Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); if espOn then mkPlayerESP(p) end end) end); for _,p in ipairs(Players:GetPlayers()) do if p~=lp then p.CharacterAdded:Connect(function() task.wait(0.5); if espOn then mkPlayerESP(p) end end) end end end
local function disablePlayerESP() espOn=false; for _,p in ipairs(Players:GetPlayers()) do if p.Character then for _,v in ipairs(p.Character:GetChildren()) do if v.Name==ESPTAG or v.Name==ESPTAG.."N" then v:Destroy() end end end end end

local timerESPs={}
local function startTimerESP()
    task.spawn(function()
        while true do task.wait(0.5)
            local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
            for _,plot in ipairs(plots:GetChildren()) do
                local pur=plot:FindFirstChild("Purchases"); local pb2=pur and pur:FindFirstChild("PlotBlock"); local mp=pb2 and pb2:FindFirstChild("Main")
                local tl2=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
                if tl2 and mp then
                    local e=timerESPs[plot.Name]
                    if not e or not e.bb.Parent then
                        if e then pcall(function() e.bb:Destroy() end) end
                        local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(50,14); bb.StudsOffset=Vector3.new(0,7,0); bb.AlwaysOnTop=true; bb.Adornee=mp; bb.Parent=plot
                        local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=T.bg; bg.BackgroundTransparency=0.2; bg.BorderSizePixel=0; co(bg,4); local stk=ms(bg,0.8,T.yel,0.3)
                        local tl=Instance.new("TextLabel",bg); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold; tl.TextSize=9; tl.TextColor3=T.yel
                        timerESPs[plot.Name]={bb=bb,lbl=tl,stk=stk}; e=timerESPs[plot.Name]
                    end
                    e.lbl.Text=tl2.Text; local m,s2=tl2.Text:match("(%d+):(%d+)"); if m and s2 then local tot=tonumber(m)*60+tonumber(s2); local col=tot<=30 and T.red or tot<=60 and T.yel or T.grn; e.lbl.TextColor3=col; e.stk.Color=col end
                end
            end
        end
    end)
end
startTimerESP()

local mineESPs={}
local function addMineESP(child) if mineESPs[child] then return end; local nl=child.Name:lower(); if not (nl:find("subspace") or nl:find("mine")) then return end; if nl:find("bullet") then return end; local part=child:IsA("BasePart") and child or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart"))); if not part then return end; local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(60,16); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=workspace; local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(22,4,4); bg.BackgroundTransparency=0.2; bg.BorderSizePixel=0; co(bg,4); ms(bg,1,T.red,0.15); local tl=Instance.new("TextLabel",bg); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Text="MINE"; tl.Font=Enum.Font.GothamBold; tl.TextSize=8; tl.TextColor3=T.red; mineESPs[child]={bb=bb}; child.AncestryChanged:Connect(function() if not child.Parent then pcall(function() bb:Destroy() end); mineESPs[child]=nil end end) end
local mineESPOn=false
local function enableMineESP() if mineESPOn then return end; mineESPOn=true; for _,d in pairs(workspace:GetDescendants()) do addMineESP(d) end; workspace.DescendantAdded:Connect(function(d) if mineESPOn then task.defer(function() addMineESP(d) end) end end) end
local function disableMineESP() mineESPOn=false; for _,e in pairs(mineESPs) do pcall(function() e.bb:Destroy() end) end; mineESPs={} end

-- Brainrot ESP
local brainESPCache={}; local brainESPOn=false; local brainConns={}
local function addBrainESP(model,plot) if not model or brainESPCache[model] or model.Name=="" then return end; local part=model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")) or (model:IsA("BasePart") and model); if not part then return end; local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(110,22); bb.StudsOffset=Vector3.new(0,5,0); bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=workspace; local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=T.bg; bg.BackgroundTransparency=0.22; bg.BorderSizePixel=0; co(bg,4); ms(bg,1,T.a2,0.22); lb(bg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=model.Name,Font=Enum.Font.GothamBold,TextSize=8,TextColor3=T.a1,TextTruncate=Enum.TextTruncate.AtEnd}); brainESPCache[model]=bb; model.AncestryChanged:Connect(function() if not model.Parent then pcall(function() bb:Destroy() end); brainESPCache[model]=nil end end) end
local function startBrainESP() if brainESPOn then return end; brainESPOn=true; local plots=workspace:FindFirstChild("Plots"); if not plots then return end; for _,plot in ipairs(plots:GetChildren()) do local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then continue end; for _,pod in ipairs(pods:GetChildren()) do local base=pod:FindFirstChild("Base"); local spawn=base and base:FindFirstChild("Spawn"); if spawn then for _,c in ipairs(spawn:GetChildren()) do addBrainESP(c,plot) end; local cn=spawn.ChildAdded:Connect(function(c) if brainESPOn then addBrainESP(c,plot) end end); table.insert(brainConns,cn) end end end end
local function stopBrainESP() brainESPOn=false; for _,c in ipairs(brainConns) do pcall(function() c:Disconnect() end) end; brainConns={}; for _,bb in pairs(brainESPCache) do pcall(function() bb:Destroy() end) end; brainESPCache={} end

-- Clone ESP (Quantum Cloner objects)
local cloneESPs={}; local cloneESPOn=false
local function addCloneESP(obj) if cloneESPs[obj] then return end; local nl=obj.Name:lower(); if not (nl:find("quantum") or nl:find("clone") or nl:find("cloner")) then return end; local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))); if not part then return end; local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(80,16); bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=workspace; local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(4,4,22); bg.BackgroundTransparency=0.2; bg.BorderSizePixel=0; co(bg,4); ms(bg,1,T.pur,0.15); local tl=Instance.new("TextLabel",bg); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Text="CLONER"; tl.Font=Enum.Font.GothamBold; tl.TextSize=8; tl.TextColor3=T.pur; cloneESPs[obj]={bb=bb}; obj.AncestryChanged:Connect(function() if not obj.Parent then pcall(function() bb:Destroy() end); cloneESPs[obj]=nil end end) end
local function enableCloneESP() if cloneESPOn then return end; cloneESPOn=true; for _,d in pairs(workspace:GetDescendants()) do addCloneESP(d) end; workspace.DescendantAdded:Connect(function(d) if cloneESPOn then task.defer(function() addCloneESP(d) end) end end) end
local function disableCloneESP() cloneESPOn=false; for _,e in pairs(cloneESPs) do pcall(function() e.bb:Destroy() end) end; cloneESPs={} end

-- Friends ESP
local friendESPCache={}; local friendESPOn=false; local friendConns={}
local function buildFriendBB(main,isOpen) local bb=Instance.new("BillboardGui"); bb.Adornee=main; bb.Size=UDim2.fromOffset(50,16); bb.StudsOffset=Vector3.new(0,5,0); bb.AlwaysOnTop=true; bb.Parent=main; local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=T.bg; bg.BackgroundTransparency=0.22; bg.BorderSizePixel=0; co(bg,4); ms(bg,1,isOpen and T.grn or T.red,0.22); lb(bg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=isOpen and "OPEN" or "CLOSED",TextColor3=isOpen and T.grn or T.red,Font=Enum.Font.GothamBold,TextSize=8}); return bb end
local function addFriendESP(plot) if not plot:IsA("Model") then return end; local fp=plot:FindFirstChild("FriendPanel"); if not fp then return end; local main=fp:FindFirstChild("Main"); if not main then return end; local prompt=main:FindFirstChildOfClass("ProximityPrompt"); if not prompt then return end; if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end); friendESPCache[plot]=nil end; friendESPCache[plot]=buildFriendBB(main,prompt.ObjectText=="Disallow Friends"); local c=prompt:GetPropertyChangedSignal("ObjectText"):Connect(function() if not friendESPOn then return end; if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end); friendESPCache[plot]=nil end; friendESPCache[plot]=buildFriendBB(main,prompt.ObjectText=="Disallow Friends") end); table.insert(friendConns,c) end
local function enableFriendESP() if friendESPOn then return end; friendESPOn=true; local plots=workspace:FindFirstChild("Plots"); if not plots then return end; for _,p in ipairs(plots:GetChildren()) do addFriendESP(p) end; local c=plots.ChildAdded:Connect(function(p) if friendESPOn then task.wait(0.5); addFriendESP(p) end end); table.insert(friendConns,c) end
local function disableFriendESP() friendESPOn=false; for _,c in ipairs(friendConns) do pcall(function() c:Disconnect() end) end; friendConns={}; for _,bb in pairs(friendESPCache) do pcall(function() bb:Destroy() end) end; friendESPCache={} end

-- Xray (LocalTransparencyModifier)
local xrayOn=false; local xrayOrig={}
local function enableXray() if xrayOn then return end; xrayOn=true; for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") then local n=obj.Name:lower(); if n:find("floor") or n:find("wall") or n:find("base") or n:find("plot") or n:find("ceil") then if not xrayOrig[obj] then xrayOrig[obj]=obj.LocalTransparencyModifier end; obj.LocalTransparencyModifier=0.72 end end end end
local function disableXray() if not xrayOn then return end; xrayOn=false; for obj,t in pairs(xrayOrig) do pcall(function() if obj and obj.Parent then obj.LocalTransparencyModifier=t end end) end; xrayOrig={} end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- ADMIN REMOTE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local ADM_REMOTE=nil
task.spawn(function()
    pcall(function() if not lp.Character then lp.CharacterAdded:Wait() end end); task.wait(1.5)
    pcall(function() local net=RS:WaitForChild("Packages"):WaitForChild("Net"); local ch=net:GetChildren(); local n2i={}; for i,o in ipairs(ch) do n2i[o.Name]=i end; local a=n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]; if a and ch[a+1] then ADM_REMOTE=ch[a+1] end end)
end)
local ADM_UUID="f888ee6e-c86d-46e1-93d7-0639d6635d42"
local function aFire(tgt,cmd) task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,tgt,cmd) end) end) end
local CMD_CD={ragdoll=30,balloon=30,nightvision=60,tiny=60,jail=60,jumpscare=60,control=60,morph=60,rocket=120,inverse=60}
local cmdCdEnd={}
local function fireCmd(tgt,cmd) if not ADM_REMOTE then return end; aFire(tgt,cmd); cmdCdEnd[cmd]=os.clock()+(CMD_CD[cmd] or 30) end
local function spamAll(tgt) for _,cmd in ipairs({"balloon","tiny","rocket","inverse","morph","jumpscare","control"}) do aFire(tgt,cmd); cmdCdEnd[cmd]=os.clock()+(CMD_CD[cmd] or 30); task.wait(0.05) end end
local function getClosestPlayer() local char=lp.Character; if not char then return nil end; local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end; local best,bd=nil,math.huge; for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); if h then local d=(h.Position-hrp.Position).Magnitude; if d<bd then bd=d; best=p end end end end; return best end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- FLASH TP
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local FLASH_NAMES={"Flash Teleport","Flash","FlashTP","Flash TP"}
local FLASH_RF=nil
task.spawn(function() pcall(function() local net=RS:WaitForChild("Packages"):WaitForChild("Net"); FLASH_RF=net:FindFirstChild("RF/Tools/Flash/Activate") or net:WaitForChild("RF/Tools/Flash/Activate",10) end) end)
task.spawn(function() while true do task.wait(0.5); pcall(function() local fa=RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Tools") and RS.Assets.Tools:FindFirstChild("Flash Teleport"); if fa then for _,v in ipairs(fa:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then pcall(function() v.Enabled=false end) end; if v:IsA("Sound") then pcall(function() v.Volume=0 end) end end end end) end end)
local function equipFlash() pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end; for _,n in ipairs(FLASH_NAMES) do local t=char:FindFirstChild(n) or (lp.Backpack and lp.Backpack:FindFirstChild(n)); if t then if t.Parent~=char then hum:EquipTool(t) end; return end end end) end
local cfA=CFrame.new(-322.066,-7.871,111.991)*CFrame.Angles(0.332,-0.019,0.000); local cfB=CFrame.new(-325.856,-7.866,113.027)*CFrame.Angles(0.327,3.130,0.000)
local lookA2=cfA.LookVector; local lookB2=cfB.LookVector; local desiredY=lookA2.Y
local function flatV(v) local f=Vector3.new(v.X,0,v.Z); return f.Magnitude>0 and f.Unit or f end
local function bLook(bl) local h2=flatV(bl); local fs=math.sqrt(math.max(0,1-desiredY^2)); return Vector3.new(h2.X*fs,desiredY,h2.Z*fs) end
local function alignCam() local pos=cam.CFrame.Position; local cf=flatV(cam.CFrame.LookVector); local best=cf:Dot(flatV(lookA2))>cf:Dot(flatV(lookB2)) and bLook(lookA2) or bLook(lookB2); cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=CFrame.lookAt(pos,pos+best); task.wait(); cam.CameraType=Enum.CameraType.Custom end
local StealCBs={}
local function buildCBs(prompt) if StealCBs[prompt] then return end; local d={hold={},trig={}}; local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan); if ok1 and type(c1)=="table" then for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(d.hold,c.Function) end end end; local ok2,c2=pcall(getconnections,prompt.Triggered); if ok2 and type(c2)=="table" then for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(d.trig,c.Function) end end end; if #d.hold>0 or #d.trig>0 then StealCBs[prompt]=d end end
local function fireCBs(prompt) local d=StealCBs[prompt]; if not d then return end; for _,fn in ipairs(d.hold) do task.spawn(fn) end; task.wait(0.05); for _,fn in ipairs(d.trig) do task.spawn(fn) end end
local flashEnabled=false; local sliderValue=0.91; local activePrompts={}; local lagOnSteal=false
PPS.PromptButtonHoldBegan:Connect(function(prompt)
    if not flashEnabled or prompt.ActionText~="Steal" or activePrompts[prompt] then return end
    activePrompts[prompt]=true; local fired=false; local fireAt=os.clock()+math.max(prompt.HoldDuration,0.001)*sliderValue; local conn
    conn=RunService.RenderStepped:Connect(function()
        if fired then conn:Disconnect(); return end
        if not prompt or not prompt.Parent then conn:Disconnect(); activePrompts[prompt]=nil; return end
        if os.clock()>=fireAt then
            fired=true; conn:Disconnect(); activePrompts[prompt]=nil; isStealing=true; task.delay(0.9,function() isStealing=false end)
            if lagOnSteal then local dl=os.clock()+0.05; local x=0; while os.clock()<dl do for i=1,800 do x=x+i end end end
            if FLASH_RF then pcall(function() FLASH_RF:InvokeServer() end) else local char=lp.Character; local tool=char and char:FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end end
            task.spawn(function() task.wait(0.1); buildCBs(prompt); if StealCBs[prompt] then fireCBs(prompt) end end)
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function() if not fired then fired=true; activePrompts[prompt]=nil; conn:Disconnect() end end)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- SPEED / JUMP / CARPET / INFINITE JUMP
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local speedEnabled=false; local stealingSpeed=30; local potionOn=false
local jumpPwrOn=false; local jumpPower=50; local infJumpOn=false; local carpetSpdOn=false; local carpetSpeed=40
local function activatePotion() task.spawn(function() pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local bp=lp:FindFirstChild("Backpack"); local tool=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion")); if not tool then return end; hum:EquipTool(tool); task.wait(0.05); tool:Activate() end) end) end
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid"); if not root or not hum then return end
    if speedEnabled and hum.MoveDirection.Magnitude>0 then root.Velocity=Vector3.new(hum.MoveDirection.X*stealingSpeed,root.Velocity.Y,hum.MoveDirection.Z*stealingSpeed) end
    if carpetSpdOn and hum.MoveDirection.Magnitude>0 then root.Velocity=Vector3.new(hum.MoveDirection.X*carpetSpeed,root.Velocity.Y,hum.MoveDirection.Z*carpetSpeed) end
    if jumpPwrOn then hum.JumpPower=jumpPower end
end)
local function equipCarpet() task.spawn(function() pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local bp=lp:FindFirstChild("Backpack"); local names={"Flying Carpet","Witch's Broom","Santa's Sleigh","Cupid's Wings"}; for _,n in ipairs(names) do local t=char:FindFirstChild(n) or (bp and bp:FindFirstChild(n)); if t then if t.Parent~=char then hum:EquipTool(t) end; return end end end) end) end
-- Infinite jump
UIS.JumpRequest:Connect(function() if infJumpOn then local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- IRISH RESET
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local tpPos=CFrame.new(1000003.56,999999.69,8.17)
local function doReset()
    local c=lp.Character; if not c then return end; local h=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid"); if not h or not hum then return end
    cam.CameraType=Enum.CameraType.Scriptable; task.delay(0.6,function() local ch=lp.Character; local hm=ch and ch:FindFirstChildOfClass("Humanoid"); if hm then cam.CameraType=Enum.CameraType.Custom; cam.CameraSubject=hm end end); h.CFrame=tpPos
    local con; con=RunService.Heartbeat:Connect(function() if not c or not c.Parent then con:Disconnect(); return end; if hum.Health<=0 then con:Disconnect(); return end; h.CFrame=tpPos end)
    -- Defense spam on reset
    task.spawn(function() task.wait(0.1); local closest=getClosestPlayer(); if closest and ADM_REMOTE then for _,cmd in ipairs({"rocket","tiny","inverse","morph","jumpscare"}) do aFire(closest,cmd); task.wait(0.05) end end end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- AUTO GRAB v2
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local grabEnabled=false; local activeHolds={}
local function getGrabPrompts() local result={}; local char=lp.Character; local root=char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")); if not root then return result end; local plots=workspace:FindFirstChild("Plots"); if not plots then return result end; for _,plot in ipairs(plots:GetChildren()) do if isMyPlot(plot) then continue end; local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then continue end; for _,pod in ipairs(pods:GetChildren()) do local base=pod:FindFirstChild("Base"); if not base then continue end; local spawn=base:FindFirstChild("Spawn"); if not spawn then continue end; local att=spawn:FindFirstChild("PromptAttachment"); if not att then continue end; for _,p in ipairs(att:GetChildren()) do if p:IsA("ProximityPrompt") and (p.ActionText=="Steal" or p.ActionText=="Grab") then table.insert(result,{prompt=p,dist=(spawn.Position-root.Position).Magnitude,spawn=spawn}) end end end end; return result end
lp.CharacterAdded:Connect(function() for p in pairs(activeHolds) do pcall(function() p:InputHoldEnd() end) end; activeHolds={}; isStealing=false end)
RunService.Heartbeat:Connect(function()
    if not grabEnabled then return end; local char=lp.Character; local root=char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")); if not root then return end
    local prompts=getGrabPrompts(); local seen={}
    for _,entry in ipairs(prompts) do
        local p=entry.prompt; local dist=entry.dist; seen[p]=true
        if not activeHolds[p] then activeHolds[p]={startTime=os.clock(),fired=false,potFired=false}; pcall(function() p.Enabled=true end); pcall(function() p:InputHoldBegin() end) end
        local data=activeHolds[p]; if data.fired then continue end
        local progress=(os.clock()-data.startTime)/1.5
        if potionOn and not data.potFired and progress>=0.78 then data.potFired=true; activatePotion() end
        if (dist<=12 and progress>=0.92) or progress>=1.05 then
            data.fired=true; isStealing=true
            if not flashEnabled then pcall(function() fireproximityprompt(p) end); pcall(function() fireproximityprompt(p,10000) end); pcall(function() local conns=getconnections(p.Triggered); if conns then for _,c in ipairs(conns) do if c.Function then task.spawn(c.Function) end end end end) end
            task.spawn(function() task.wait(0.1); pcall(function() p:InputHoldEnd() end); activeHolds[p]=nil; task.wait(0.3); isStealing=false end)
        end
    end
    for p,data in pairs(activeHolds) do if not seen[p] then if not data.fired then pcall(function() p:InputHoldEnd() end) end; activeHolds[p]=nil end end
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- BASE PROTECTOR
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local antiSteal=false; local autoKickBase=false; local antiIntruder=false; local lastPunish={}
local function punish(p) if not ADM_REMOTE or not p or p==lp then return end; local uid=p.UserId; local now=os.clock(); if lastPunish[uid] and now-lastPunish[uid]<0.5 then return end; lastPunish[uid]=now; pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end); cmdCdEnd["balloon"]=os.clock()+(CMD_CD["balloon"] or 30); if autoKickBase then task.delay(0.05,function() lp:Kick("Protected") end) end end
local function findThief() local sp=stealHitbox and stealHitbox.Position; if not sp then local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); sp=hrp and hrp.Position end; if not sp then return nil end; local best,bd=nil,math.huge; for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then local d=(hrp.Position-sp).Magnitude; if d<bd then bd=d; best=p end end end end; return best end
local function isOnMyBase(prompt) if not myPlotRef then return false end; local a=prompt.Parent; while a and a~=workspace do if a==myPlotRef then return true end; a=a.Parent end; return false end
pcall(function() if not hookfunction or not fireproximityprompt then return end; local old=fireproximityprompt; hookfunction(fireproximityprompt,newcclosure(function(prompt,...) if antiSteal and (prompt.ActionText or ""):lower():find("steal") and isOnMyBase(prompt) then local t=findThief(); if t then punish(t) end end; return old(prompt,...) end)) end)
-- Anti intruder: check base every heartbeat
local intruderConn=nil
local function startAntiIntruder()
    if intruderConn then return end
    intruderConn=RunService.Heartbeat:Connect(function()
        if not antiIntruder or not stealHitbox or not ADM_REMOTE then return end
        local cf=stealHitbox.CFrame; local sz=stealHitbox.Size; local hx=sz.X*0.5; local hz=sz.Z*0.5
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local rel=cf:PointToObjectSpace(hrp.Position)
                    if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then punish(p) end
                end
            end
        end
    end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- STEAL ON LEAVE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local stealOnLeave=false
Players.PlayerRemoving:Connect(function(p)
    if not stealOnLeave then return end
    task.spawn(function()
        local plots=workspace:FindFirstChild("Plots"); if not plots then return end
        for _,plot in ipairs(plots:GetChildren()) do
            for _,desc in ipairs(plot:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and (desc.ActionText=="Steal" or desc.ActionText=="Grab") and desc.Enabled then
                    pcall(function() fireproximityprompt(desc) end); task.wait(0.05)
                end
            end
        end
    end)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- AUTO RESET ON BALLOON (head size change)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local autoResetBalloon=false
local function watchHead(char) local head=char:FindFirstChild("Head"); if not head then return end; head:GetPropertyChangedSignal("Size"):Connect(function() if autoResetBalloon and head.Size.Y>5 then task.wait(0.1); doReset() end end) end
lp.CharacterAdded:Connect(function(char) if autoResetBalloon then task.wait(0.5); watchHead(char) end end)
if lp.Character then task.spawn(function() watchHead(lp.Character) end) end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- FPS BOOST
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local fpsBoostOn=false
local function enableFPSBoost()
    if fpsBoostOn then return end; fpsBoostOn=true
    pcall(function() Lighting.GlobalShadows=false; Lighting.FogEnd=1e9 end)
    for _,v in pairs(Lighting:GetDescendants()) do pcall(function() if v:IsA("PostEffect") then v.Enabled=false end end) end
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _,d in ipairs(p.Character:GetDescendants()) do
                pcall(function() if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("PointLight") or d:IsA("SpotLight") then d.Enabled=false end end)
                pcall(function() if d:IsA("Accessory") then d:Destroy() end end)
            end
        end
    end
    for _,v in pairs(workspace:GetDescendants()) do pcall(function() if v:IsA("ParticleEmitter") or v:IsA("PointLight") then v.Enabled=false end end) end
end
local function disableFPSBoost() fpsBoostOn=false; pcall(function() Lighting.GlobalShadows=true; Lighting.FogEnd=100000 end) end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- SOLAR AIMBOT (background)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local aimbotEnabled=false; local aimbotRemote=nil; local aimbotTarget=nil; local aimbotRange=350
task.spawn(function() pcall(function() local net=RS:WaitForChild("Packages",5); if not net then return end; net=net:FindFirstChild("Net"); if not net then return end; local ch=net:GetChildren(); for i,obj in ipairs(ch) do if obj.Name=="RE/UseItem" then aimbotRemote=ch[i+1]; break end end end) end)
local function getNearestTarget() if not lp.Character then return nil end; local myHRP=lp.Character:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end; local nearest,shortest=nil,aimbotRange; for _,pl in ipairs(Players:GetPlayers()) do if pl~=lp and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then local dist=(pl.Character.HumanoidRootPart.Position-myHRP.Position).Magnitude; if dist<shortest then shortest=dist; nearest=pl end end end; return nearest end
RunService.Heartbeat:Connect(function() if aimbotEnabled then aimbotTarget=getNearestTarget() end end)
local function fireAimbot() if not aimbotEnabled or not aimbotTarget or not aimbotTarget.Character then return end; local tPart=aimbotTarget.Character:FindFirstChild("HumanoidRootPart") or aimbotTarget.Character:FindFirstChild("Head"); if tPart and aimbotRemote then pcall(function() aimbotRemote:FireServer(tPart.Position,tPart) end) end end
local function hookAimbot(tool) tool.Activated:Connect(function() fireAimbot() end) end
lp.CharacterAdded:Connect(function(c) task.wait(0.5); for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") then hookAimbot(ch) end end end)
workspace.DescendantAdded:Connect(function(obj) if obj:IsA("Tool") and lp.Character and obj:IsDescendantOf(lp.Character) then task.wait(0.1); hookAimbot(obj) end end)
if lp.Character then for _,ch in ipairs(lp.Character:GetChildren()) do if ch:IsA("Tool") then hookAimbot(ch) end end end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- SUBSPACE MINE PLACER
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local function placeMine() task.spawn(function() pcall(function() local char=lp.Character; if not char then return end; local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end; local bp=lp:FindFirstChild("Backpack"); local mine=char:FindFirstChild("Subspace Mine") or (bp and bp:FindFirstChild("Subspace Mine")); if not mine then return end; if mine.Parent~=char then hum:EquipTool(mine) end; task.wait(0.1); mine:Activate() end) end) end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- FRIEND BASE TOGGLE (from SAB Friend GUI)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local friendToggleCooldown=false
local function findMyFriendPrompt() local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end; for _,plot in ipairs(plots:GetChildren()) do for _,v in ipairs(plot:GetDescendants()) do if (v.ClassName=="StringValue" or v.ClassName=="ObjectValue") and (tostring(v.Value)==lp.Name or tostring(v.Value)==tostring(lp.UserId) or (v.ClassName=="ObjectValue" and v.Value==lp)) then for _,desc in ipairs(plot:GetDescendants()) do if desc:IsA("ProximityPrompt") and (desc.ObjectText=="Allow Friends" or desc.ObjectText=="Disallow Friends") then return desc end end end end end; local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end; local best,bd=nil,math.huge; for _,plot in ipairs(plots:GetChildren()) do for _,desc in ipairs(plot:GetDescendants()) do if desc:IsA("ProximityPrompt") and (desc.ObjectText=="Allow Friends" or desc.ObjectText=="Disallow Friends") then local part=desc.Parent; if part:IsA("BasePart") then local d=(hrp.Position-part.Position).Magnitude; if d<bd then bd=d; best=desc end end end end end; return best end
local function fireFriendPrompt(prompt) local ok=pcall(function() fireprompt(prompt) end); if not ok then local ok2,conns=pcall(getconnections,prompt.Triggered); if ok2 and conns then for _,c in ipairs(conns) do local fnOk,fn=pcall(function() return c.Function end); if fnOk and fn~=nil then pcall(function() c:Fire() end); break end end end end end
local function getFriendBaseStatus() local p=findMyFriendPrompt(); if not p then return "?" end; return p.ObjectText=="Disallow Friends" and "OPEN" or "CLOSED" end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- FOV
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local fovValue=115; local fovLock=true
RunService.RenderStepped:Connect(function() if fovLock then cam.FieldOfView=fovValue end end)

-- CMD timer heartbeat
local cmdBtnRefs={}; local lastDt=1/60
RunService.Heartbeat:Connect(function(dt)
    lastDt=dt; local now=os.clock()
    for _,cmds in pairs(cmdBtnRefs) do for cmd,ib in pairs(cmds) do if ib and ib.Parent then local cd=cmdCdEnd[cmd]; if cd and cd>now then local rs=tostring(math.ceil(cd-now)); if ib.Text~=rs then ib.Text=rs; ib.TextColor3=T.red; ib.BackgroundColor3=Color3.fromRGB(65,8,8) end else local icon=ib:GetAttribute("icon"); if icon and ib.Text~=icon then ib.Text=icon; ib.TextColor3=T.a1; ib.BackgroundColor3=T.surf2 end end end end end
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- GUI PANELS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
task.wait(0.15); vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end
local W=160 -- standard panel width for mobile

-- â”€â”€ HEADER BOX â”€â”€
local hdrW=200; local hdrH=72
local hdrF=Instance.new("Frame",SG); hdrF.Size=UDim2.fromOffset(hdrW,hdrH); hdrF.Position=UDim2.fromOffset(math.floor(vp.X*0.5-hdrW*0.5),3); hdrF.BackgroundColor3=T.panel; hdrF.BackgroundTransparency=0.14; hdrF.BorderSizePixel=0; co(hdrF,9); rotS(hdrF,T.a1); particles(hdrF); hdrF.Active=false
lb(hdrF,{Position=UDim2.fromOffset(0,4),Size=UDim2.new(1,0,0,14),Text="Aethen Hub  v0.9",TextSize=11,Font=Enum.Font.GothamBlack,TextColor3=T.a1,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
lb(hdrF,{Position=UDim2.fromOffset(0,18),Size=UDim2.new(1,0,0,10),Text="@r9qbx  â€¢  "..DISCORD,TextSize=7,Font=Enum.Font.Gotham,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
local fpsLb=lb(hdrF,{Position=UDim2.fromOffset(0,28),Size=UDim2.new(1,0,0,10),Text="FPS --  PING --ms",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=T.grn,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
task.spawn(function() while task.wait(0.7) do if not fpsLb.Parent then break end; local fps=math.min(999,math.floor(1/math.max(lastDt,0.001))); local ping=0; pcall(function() ping=math.floor(lp:GetNetworkPing()*1000) end); fpsLb.Text="FPS "..fps.."  PING "..ping.."ms"; fpsLb.TextColor3=fps<40 and T.red or fps<55 and T.yel or T.grn end end)
local function hBtn(text,pos,w2,tc,bg2) local b=Instance.new("TextButton",hdrF); b.Size=UDim2.fromOffset(w2 or 50,13); b.Position=pos; b.BackgroundColor3=bg2 or T.surf; b.BackgroundTransparency=0.22; b.Text=text; b.TextColor3=tc or T.a1; b.Font=Enum.Font.GothamBold; b.TextSize=7; b.BorderSizePixel=0; b.AutoButtonColor=false; co(b,3); ms(b,1,T.str,0.5); b.ZIndex=5; return b end
local grabHBtn=hBtn("Grab: OFF",UDim2.fromOffset(4,40),53,T.dim)
local function updGrab() grabHBtn.Text=grabEnabled and "Grab: ON" or "Grab: OFF"; grabHBtn.TextColor3=grabEnabled and T.grn or T.dim end
updGrab(); grabHBtn.MouseButton1Click:Connect(function() grabEnabled=not grabEnabled; updGrab() end)
local resetHBtn=hBtn("Reset",UDim2.fromOffset(61,40),34,T.a2)
resetHBtn.MouseButton1Click:Connect(function() task.spawn(doReset) end)
local ragHBtn=hBtn("Rag",UDim2.fromOffset(99,40),28,T.red,Color3.fromRGB(22,5,5))
ragHBtn.MouseButton1Click:Connect(function() if ADM_REMOTE then pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end); cmdCdEnd["ragdoll"]=os.clock()+(CMD_CD["ragdoll"] or 30) end end)
local prHBtn=hBtn("Pot+Rag",UDim2.fromOffset(131,40),65,T.pur,Color3.fromRGB(14,8,22))
prHBtn.MouseButton1Click:Connect(function() task.spawn(function() activatePotion(); task.wait(0.5); if ADM_REMOTE then pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end); cmdCdEnd["ragdoll"]=os.clock()+(CMD_CD["ragdoll"] or 30) end end) end)

-- â”€â”€ FLASH TP PANEL â”€â”€
local FP,_,FPC=mkPanel(math.floor(vp.X-W-4),4,W,200,"Flash TP",T.a2); local fy=2
-- Tabs
local tRow=Instance.new("Frame",FPC); tRow.Size=UDim2.fromOffset(W,18); tRow.Position=UDim2.fromOffset(0,0); tRow.BackgroundColor3=T.surf2; tRow.BackgroundTransparency=0.1; tRow.BorderSizePixel=0
local tM=Instance.new("TextButton",tRow); tM.Size=UDim2.new(0.5,0,1,0); tM.BackgroundColor3=T.a1; tM.Text="MAIN"; tM.Font=Enum.Font.GothamBlack; tM.TextSize=7; tM.TextColor3=T.bg; tM.BorderSizePixel=0; tM.AutoButtonColor=false; co(tM,0)
local tE=Instance.new("TextButton",tRow); tE.Size=UDim2.new(0.5,0,1,0); tE.Position=UDim2.new(0.5,0,0,0); tE.BackgroundColor3=T.surf2; tE.Text="EXTRAS"; tE.Font=Enum.Font.GothamBlack; tE.TextSize=7; tE.TextColor3=T.dim; tE.BorderSizePixel=0; tE.AutoButtonColor=false; co(tE,0)
local pg1c=Instance.new("Frame",FPC); pg1c.Size=UDim2.new(1,0,1,-18); pg1c.Position=UDim2.fromOffset(0,18); pg1c.BackgroundTransparency=1; pg1c.BorderSizePixel=0
local pg2c=Instance.new("Frame",FPC); pg2c.Size=UDim2.new(1,0,1,-18); pg2c.Position=UDim2.fromOffset(0,18); pg2c.BackgroundTransparency=1; pg2c.BorderSizePixel=0; pg2c.Visible=false
local function setFPTab(m) tM.BackgroundColor3=m and T.a1 or T.surf2; tM.TextColor3=m and T.bg or T.dim; tE.BackgroundColor3=not m and T.a1 or T.surf2; tE.TextColor3=not m and T.bg or T.dim; pg1c.Visible=m; pg2c.Visible=not m end
tM.MouseButton1Click:Connect(function() setFPTab(true) end); tE.MouseButton1Click:Connect(function() setFPTab(false) end); setFPTab(true)
-- Main tab rows
local lagB,lagSet=toggle(pg1c,"Lag On Steal",2,T.a1); lagB.MouseButton1Click:Connect(function() lagOnSteal=not lagOnSteal; lagSet(lagOnSteal) end)
local potB,potSet=toggle(pg1c,"Giant Potion",23,T.grn); potB.MouseButton1Click:Connect(function() potionOn=not potionOn; potSet(potionOn) end)
local sep1=Instance.new("Frame",pg1c); sep1.Size=UDim2.new(1,-8,0,1); sep1.Position=UDim2.fromOffset(4,44); sep1.BackgroundColor3=T.str; sep1.BackgroundTransparency=0.7; sep1.BorderSizePixel=0
local flB,flSet=toggle(pg1c,"Flash TP",47,T.a1); flB.MouseButton1Click:Connect(function() flashEnabled=not flashEnabled; flSet(flashEnabled) end)
local trigLbl=lb(pg1c,{Position=UDim2.fromOffset(4,69),Size=UDim2.fromOffset(W-8,10),Text="Trigger: 91%",TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local slBg=Instance.new("Frame",pg1c); slBg.Size=UDim2.fromOffset(W-8,4); slBg.Position=UDim2.fromOffset(4,81); slBg.BackgroundColor3=T.surf; slBg.BorderSizePixel=0; co(slBg,3)
local slFill=Instance.new("Frame",slBg); slFill.Size=UDim2.new(sliderValue,0,1,0); slFill.BackgroundColor3=T.a1; slFill.BorderSizePixel=0; co(slFill,3)
local slK=Instance.new("Frame",slBg); slK.Size=UDim2.fromOffset(10,10); slK.AnchorPoint=Vector2.new(0.5,0.5); slK.Position=UDim2.new(sliderValue,0,0.5,0); slK.BackgroundColor3=T.white; slK.BorderSizePixel=0; co(slK,5)
local slOn2=false
local function setTr(pct) pct=math.clamp(pct,0,1); sliderValue=pct; slFill.Size=UDim2.new(pct,0,1,0); slK.Position=UDim2.new(pct,0,0.5,0); trigLbl.Text="Trigger: "..math.floor(pct*100).."%" end
slBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slOn2=true; setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and slOn2 then slOn2=false end end)
UIS.InputChanged:Connect(function(i) if not slOn2 then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
local camBusy2=false; local camBtnF=sBtn(pg1c,"AUTO ALLIGN",4,90,W-8,17,T.surf); camBtnF.TextColor3=T.a1
camBtnF.MouseButton1Click:Connect(function() if camBusy2 then return end; camBusy2=true; camBtnF.Text="Aligning..."; pcall(equipFlash); task.wait(0.05); pcall(alignCam); task.delay(1,function() camBtnF.Text="AUTO ALLIGN"; camBusy2=false end) end)
local rstBtnF=sBtn(pg1c,"Instant Reset",4,111,W-8,15,Color3.fromRGB(40,6,6)); rstBtnF.TextColor3=T.red
rstBtnF.MouseButton1Click:Connect(function() task.spawn(doReset) end)
-- Extras tab: FOV slider
lb(pg2c,{Position=UDim2.fromOffset(4,2),Size=UDim2.fromOffset(W-8,10),Text="FOV: 115",TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local fovLbl=pg2c:FindFirstChildOfClass("TextLabel")
local fovBg=Instance.new("Frame",pg2c); fovBg.Size=UDim2.fromOffset(W-8,4); fovBg.Position=UDim2.fromOffset(4,14); fovBg.BackgroundColor3=T.surf; fovBg.BorderSizePixel=0; co(fovBg,3)
local fovFill=Instance.new("Frame",fovBg); fovFill.Size=UDim2.new(0.5,0,1,0); fovFill.BackgroundColor3=T.a2; fovFill.BorderSizePixel=0; co(fovFill,3)
local fovK=Instance.new("Frame",fovBg); fovK.Size=UDim2.fromOffset(10,10); fovK.AnchorPoint=Vector2.new(0.5,0.5); fovK.Position=UDim2.new(0.5,0,0.5,0); fovK.BackgroundColor3=T.white; fovK.BorderSizePixel=0; co(fovK,5)
local fovSlOn=false
local function setFov(pct) pct=math.clamp(pct,0,1); fovValue=math.floor(70+pct*110); fovFill.Size=UDim2.new(pct,0,1,0); fovK.Position=UDim2.new(pct,0,0.5,0); if fovLbl then fovLbl.Text="FOV: "..fovValue end end
setFov(0.41)
fovBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fovSlOn=true; setFov((i.Position.X-fovBg.AbsolutePosition.X)/fovBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and fovSlOn then fovSlOn=false end end)
UIS.InputChanged:Connect(function(i) if not fovSlOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setFov((i.Position.X-fovBg.AbsolutePosition.X)/fovBg.AbsoluteSize.X) end end)

-- â”€â”€ VISUAL PANEL â”€â”€
local VP,_,VPC=mkPanel(4,hdrH+6,W,218,"Visuals",T.a2); local vy=2
local espB,espSet=toggle(VPC,"Player ESP",vy,T.a1); vy=vy+21; espB.MouseButton1Click:Connect(function() if espOn then disablePlayerESP(); espSet(false) else enablePlayerESP(); espSet(true) end end)
local brainB,brainSet=toggle(VPC,"Brainrot ESP",vy,T.a1); vy=vy+21; brainB.MouseButton1Click:Connect(function() if brainESPOn then stopBrainESP(); brainSet(false) else startBrainESP(); brainSet(true) end end)
local mineB,mineSet=toggle(VPC,"Mine ESP",vy,T.red); vy=vy+21; mineB.MouseButton1Click:Connect(function() if mineESPOn then disableMineESP(); mineSet(false) else enableMineESP(); mineSet(true) end end)
local cloneB,cloneSet=toggle(VPC,"Clone ESP",vy,T.pur); vy=vy+21; cloneB.MouseButton1Click:Connect(function() if cloneESPOn then disableCloneESP(); cloneSet(false) else enableCloneESP(); cloneSet(true) end end)
local frdB,frdSet=toggle(VPC,"Friends ESP",vy,T.grn); vy=vy+21; frdB.MouseButton1Click:Connect(function() if friendESPOn then disableFriendESP(); frdSet(false) else enableFriendESP(); frdSet(true) end end)
local xrB,xrSet=toggle(VPC,"Base Xray",vy,T.yel); vy=vy+21; xrB.MouseButton1Click:Connect(function() if xrayOn then disableXray(); xrSet(false) else enableXray(); xrSet(true) end end)
local sentB,sentSet=toggle(VPC,"Anti Sentry",vy,T.grn); vy=vy+21; sentSet(true)
sentB.MouseButton1Click:Connect(function() end)
local fpsB,fpsSet=toggle(VPC,"FPS Boost",vy,T.grn); vy=vy+21; fpsB.MouseButton1Click:Connect(function() if fpsBoostOn then disableFPSBoost(); fpsSet(false) else enableFPSBoost(); fpsSet(true) end end)
local aimbotB,aimbotSet=toggle(VPC,"Aimbot",vy,T.red); vy=vy+21; aimbotB.MouseButton1Click:Connect(function() aimbotEnabled=not aimbotEnabled; aimbotSet(aimbotEnabled) end)

-- â”€â”€ PLAYER PANEL â”€â”€
local PP,_,PPC=mkPanel(4,hdrH+VP.Size.Y.Offset+14,W,180,"Player",T.a1); local py2=2
local spdB,spdSet=toggle(PPC,"Speed Boost",py2,T.grn); py2=py2+21; spdB.MouseButton1Click:Connect(function() speedEnabled=not speedEnabled; spdSet(speedEnabled) end)
lb(PPC,{Position=UDim2.fromOffset(4,py2),Size=UDim2.fromOffset(W-8,9),Text="Speed: "..stealingSpeed,TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local spdNumLbl=PPC:FindFirstChildOfClass("TextLabel")
local spdSlBg=Instance.new("Frame",PPC); spdSlBg.Size=UDim2.fromOffset(W-8,4); spdSlBg.Position=UDim2.fromOffset(4,py2+11); spdSlBg.BackgroundColor3=T.surf; spdSlBg.BorderSizePixel=0; co(spdSlBg,3)
local spdSlFill=Instance.new("Frame",spdSlBg); spdSlFill.Size=UDim2.new(0.3,0,1,0); spdSlFill.BackgroundColor3=T.grn; spdSlFill.BorderSizePixel=0; co(spdSlFill,3)
local spdSlK=Instance.new("Frame",spdSlBg); spdSlK.Size=UDim2.fromOffset(10,10); spdSlK.AnchorPoint=Vector2.new(0.5,0.5); spdSlK.Position=UDim2.new(0.3,0,0.5,0); spdSlK.BackgroundColor3=T.white; spdSlK.BorderSizePixel=0; co(spdSlK,5)
local spdSlOn=false
local function setSpdSlider(pct) pct=math.clamp(pct,0,1); stealingSpeed=math.floor(10+pct*90); spdSlFill.Size=UDim2.new(pct,0,1,0); spdSlK.Position=UDim2.new(pct,0,0.5,0); if spdNumLbl then spdNumLbl.Text="Speed: "..stealingSpeed end end
spdSlBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then spdSlOn=true; setSpdSlider((i.Position.X-spdSlBg.AbsolutePosition.X)/spdSlBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and spdSlOn then spdSlOn=false end end)
UIS.InputChanged:Connect(function(i) if not spdSlOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setSpdSlider((i.Position.X-spdSlBg.AbsolutePosition.X)/spdSlBg.AbsoluteSize.X) end end)
py2=py2+37
local jpB,jpSet=toggle(PPC,"Jump Power",py2,T.a2); py2=py2+21; jpB.MouseButton1Click:Connect(function() jumpPwrOn=not jumpPwrOn; jpSet(jumpPwrOn) end)
lb(PPC,{Position=UDim2.fromOffset(4,py2),Size=UDim2.fromOffset(W-8,9),Text="Jump: "..jumpPower,TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local jpNumLbl=PPC:FindFirstChildOfClass("TextLabel")
local jpSlBg=Instance.new("Frame",PPC); jpSlBg.Size=UDim2.fromOffset(W-8,4); jpSlBg.Position=UDim2.fromOffset(4,py2+11); jpSlBg.BackgroundColor3=T.surf; jpSlBg.BorderSizePixel=0; co(jpSlBg,3)
local jpSlFill=Instance.new("Frame",jpSlBg); jpSlFill.Size=UDim2.new(0.3,0,1,0); jpSlFill.BackgroundColor3=T.a2; jpSlFill.BorderSizePixel=0; co(jpSlFill,3)
local jpSlK=Instance.new("Frame",jpSlBg); jpSlK.Size=UDim2.fromOffset(10,10); jpSlK.AnchorPoint=Vector2.new(0.5,0.5); jpSlK.Position=UDim2.new(0.3,0,0.5,0); jpSlK.BackgroundColor3=T.white; jpSlK.BorderSizePixel=0; co(jpSlK,5)
local jpSlOn=false
local function setJpSlider(pct) pct=math.clamp(pct,0,1); jumpPower=math.floor(30+pct*220); jpSlFill.Size=UDim2.new(pct,0,1,0); jpSlK.Position=UDim2.new(pct,0,0.5,0); if jpNumLbl then jpNumLbl.Text="Jump: "..jumpPower end; local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower=jumpPower end end
jpSlBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then jpSlOn=true; setJpSlider((i.Position.X-jpSlBg.AbsolutePosition.X)/jpSlBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and jpSlOn then jpSlOn=false end end)
UIS.InputChanged:Connect(function(i) if not jpSlOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setJpSlider((i.Position.X-jpSlBg.AbsolutePosition.X)/jpSlBg.AbsoluteSize.X) end end)
py2=py2+37
local ijB,ijSet=toggle(PPC,"Infinite Jump",py2,T.yel); py2=py2+21; ijB.MouseButton1Click:Connect(function() infJumpOn=not infJumpOn; ijSet(infJumpOn) end)
local carpBtn=sBtn(PPC,"Carpet Speed",4,py2,W-8,17,T.surf2); carpBtn.TextColor3=T.a1
carpBtn.MouseButton1Click:Connect(function() carpetSpdOn=not carpetSpdOn; carpBtn.BackgroundColor3=carpetSpdOn and Color3.fromRGB(8,22,8) or T.surf2; carpBtn.TextColor3=carpetSpdOn and T.grn or T.a1; if carpetSpdOn then equipCarpet() end end)

-- â”€â”€ UTILITIES PANEL â”€â”€
local UP,_,UPC=mkPanel(math.floor(vp.X-W-4),220,W,195,"Utilities",T.grn); local uy=2
local stolB,stolSet=toggle(UPC,"Steal On Leave",uy,T.a1); uy=uy+21; stolB.MouseButton1Click:Connect(function() stealOnLeave=not stealOnLeave; stolSet(stealOnLeave) end)
local arB,arSet=toggle(UPC,"Auto Reset (Balloon)",uy,T.red); uy=uy+21; arB.MouseButton1Click:Connect(function() autoResetBalloon=not autoResetBalloon; arSet(autoResetBalloon); if autoResetBalloon and lp.Character then watchHead(lp.Character) end end)
local mineBtn=sBtn(UPC,"Place Subspace Mine",4,uy,W-8,17,T.surf2); mineBtn.TextColor3=T.a1; uy=uy+21; mineBtn.MouseButton1Click:Connect(function() placeMine() end)
local sep2=Instance.new("Frame",UPC); sep2.Size=UDim2.new(1,-8,0,1); sep2.Position=UDim2.fromOffset(4,uy); sep2.BackgroundColor3=T.str; sep2.BackgroundTransparency=0.7; sep2.BorderSizePixel=0; uy=uy+5
lb(UPC,{Position=UDim2.fromOffset(4,uy),Size=UDim2.fromOffset(W-8,10),Text="Unlock Base (Floor)",TextSize=7,TextColor3=T.dim})
uy=uy+12
local floorRow=Instance.new("Frame",UPC); floorRow.Size=UDim2.fromOffset(W-8,20); floorRow.Position=UDim2.fromOffset(4,uy); floorRow.BackgroundTransparency=1; floorRow.BorderSizePixel=0; uy=uy+24
for fl=1,3 do
    local fx=(fl-1)*((W-8)/3); local fb=sBtn(floorRow,"Floor "..fl,fx,0,math.floor((W-8)/3)-2,18,T.surf2); fb.TextColor3=T.a1
    fb.MouseButton1Click:Connect(function()
        task.spawn(function() pcall(function()
            local plots=workspace:FindFirstChild("Plots"); if not plots then return end
            for _,plot in ipairs(plots:GetChildren()) do
                if isMyPlot(plot) then
                    for _,desc in ipairs(plot:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and (desc.ActionText:lower():find("unlock") or desc.ActionText:lower():find("floor "..fl) or desc.ActionText:lower():find("upgrade")) and desc.Enabled then
                            pcall(function() fireproximityprompt(desc) end)
                        end
                    end
                end
            end
        end) end)
    end)
end
local apSpamBtn=sBtn(UPC,"Quick AP Spam (Closest)",4,uy,W-8,17,Color3.fromRGB(22,8,8)); apSpamBtn.TextColor3=T.red; uy=uy+21; apSpamBtn.MouseButton1Click:Connect(function() local t=getClosestPlayer(); if t then task.spawn(function() for _,cmd in ipairs({"balloon","ragdoll","tiny","rocket","jail","jumpscare","control","inverse","morph"}) do aFire(t,cmd); cmdCdEnd[cmd]=os.clock()+(CMD_CD[cmd] or 30); task.wait(0.06) end end) end end)
local admSpamBtn=sBtn(UPC,"Admin Spammer (All Cmds)",4,uy,W-8,17,Color3.fromRGB(8,8,22)); admSpamBtn.TextColor3=T.a2; uy=uy+21; admSpamBtn.MouseButton1Click:Connect(function() local t=getClosestPlayer(); if t then task.spawn(function() spamAll(t) end) end end)

-- â”€â”€ DEFENSE PANEL â”€â”€
local DP,_,DPC=mkPanel(math.floor(vp.X-W-4),420,W,120,"Defense",T.red); local dy=2
local asB,asSet=toggle(DPC,"Auto Defense (Anti Steal)",dy,T.a1); dy=dy+21; asB.MouseButton1Click:Connect(function() antiSteal=not antiSteal; asSet(antiSteal) end)
local akB,akSet=toggle(DPC,"Auto Kick Thief",dy,T.red); dy=dy+21; akB.MouseButton1Click:Connect(function() autoKickBase=not autoKickBase; akSet(autoKickBase) end)
local aiB,aiSet=toggle(DPC,"Anti Intruder (AP)",dy,T.yel); dy=dy+21; aiB.MouseButton1Click:Connect(function() antiIntruder=not antiIntruder; aiSet(antiIntruder); if antiIntruder then startAntiIntruder() end end)
local ragOnReset=toggle(DPC,"Defense On Reset",dy,T.pur); dy=dy+21

-- â”€â”€ ADMIN PANEL â”€â”€
local RCMDS={{cmd="ragdoll",icon="ðŸ¤¸"},{cmd="balloon",icon="ðŸŽˆ"},{cmd="tiny",icon="ðŸœ"},{cmd="jail",icon="ðŸ”’"},{cmd="rocket",icon="ðŸš€"}}
local ADM_W=190; local IW2=16; local IH2=17; local IG2=2; local ITOT=#RCMDS*(IW2+IG2)-IG2; local CW2=ADM_W-12; local CSTART=CW2-ITOT-3
local ADMpan,_,admC=mkPanel(math.floor(vp.X*0.5-ADM_W*0.5),math.floor(vp.Y-200),ADM_W,24,"Admin Panel",T.a2)
local pScroll=Instance.new("ScrollingFrame",admC); pScroll.Size=UDim2.new(1,0,1,0); pScroll.BackgroundColor3=T.bg; pScroll.BackgroundTransparency=0.65; pScroll.BorderSizePixel=0; pScroll.ScrollBarThickness=2; pScroll.ScrollBarImageColor3=T.a1; pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; pScroll.CanvasSize=UDim2.new(0,0,0,0); co(pScroll,4)
local pLayout=Instance.new("UIListLayout",pScroll); pLayout.Padding=UDim.new(0,2); pLayout.SortOrder=Enum.SortOrder.Name
Instance.new("UIPadding",pScroll).PaddingTop=UDim.new(0,2)
local function resAdm() local ch=math.min(pLayout.AbsoluteContentSize.Y+4,140); pScroll.Size=UDim2.fromOffset(ADM_W-8,ch); admC.Parent.Size=UDim2.fromOffset(ADM_W,22+ch+3+23) end
pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resAdm)
local pCards={}
local function refreshPlayers()
    for _,c in pairs(pCards) do pcall(function() c:Destroy() end) end; pCards={}; cmdBtnRefs={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame",pScroll); card.Name=p.Name; card.Size=UDim2.new(1,-4,0,28); card.BackgroundColor3=T.surf; card.BackgroundTransparency=0.26; card.BorderSizePixel=0; co(card,5)
        local cs=ms(card,1,T.str,0.55)
        local cz=Instance.new("TextButton",card); cz.Size=UDim2.fromOffset(CSTART,28); cz.BackgroundTransparency=1; cz.Text=""; cz.AutoButtonColor=false
        local ava=Instance.new("ImageLabel",card); ava.Size=UDim2.fromOffset(17,17); ava.Position=UDim2.new(0,3,0.5,-8); ava.BackgroundColor3=T.surf2; ava.BorderSizePixel=0; co(ava,8)
        task.spawn(function() local ok,img=pcall(Players.GetUserThumbnailAsync,Players,p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48); if ok then ava.Image=img end end)
        lb(card,{Position=UDim2.new(0,22,0,2),Size=UDim2.fromOffset(CSTART-24,13),Text=p.DisplayName,TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.a1,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        lb(card,{Position=UDim2.new(0,22,0,14),Size=UDim2.fromOffset(CSTART-24,10),Text="@"..p.Name,TextSize=6,Font=Enum.Font.Gotham,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        cmdBtnRefs[p.UserId]={}
        for i,def in ipairs(RCMDS) do
            local bx=CSTART+3+(i-1)*(IW2+IG2)
            local ib=Instance.new("TextButton",card); ib.Size=UDim2.fromOffset(IW2,IH2); ib.Position=UDim2.new(0,bx,0.5,-IH2/2); ib.BackgroundColor3=T.surf2; ib.BackgroundTransparency=0.22; ib.Text=def.icon; ib.TextSize=10; ib.TextColor3=T.a1; ib.Font=Enum.Font.GothamBold; ib.BorderSizePixel=0; ib.AutoButtonColor=false; ib.Parent=card; co(ib,3); ms(ib,1,T.str,0.52); ib:SetAttribute("icon",def.icon)
            cmdBtnRefs[p.UserId][def.cmd]=ib
            local pd=p; local dc=def.cmd; ib.MouseButton1Click:Connect(function() fireCmd(pd,dc) end)
        end
        local pd=p
        cz.MouseButton1Click:Connect(function()
            for _,c2 in pairs(pCards) do local s2=c2:FindFirstChildOfClass("UIStroke"); if s2 then s2.Color=T.str; s2.Transparency=0.55 end; c2.BackgroundTransparency=0.26 end
            cs.Color=T.a1; cs.Transparency=0; card.BackgroundTransparency=0
            task.spawn(function() spamAll(pd) end)
        end)
        pCards[p.UserId]=card
    end
    task.defer(resAdm)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshPlayers() end)
task.delay(2,refreshPlayers)

-- â”€â”€ FRIEND BASE HUD (always visible, top right) â”€â”€
local fbHUD=Instance.new("Frame",SG); fbHUD.Size=UDim2.fromOffset(120,52); fbHUD.Position=UDim2.fromOffset(vp.X-128,20); fbHUD.BackgroundColor3=Color3.fromRGB(15,15,18); fbHUD.BackgroundTransparency=0.15; fbHUD.BorderSizePixel=0; co(fbHUD,10); ms(fbHUD,1,T.str,0.4)
local fbStatus=lb(fbHUD,{Position=UDim2.fromOffset(0,5),Size=UDim2.new(1,0,0,18),Text="Base: ?",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=T.grn,TextXAlignment=Enum.TextXAlignment.Center})
local fbBtn=Instance.new("TextButton",fbHUD); fbBtn.Size=UDim2.fromOffset(108,20); fbBtn.Position=UDim2.fromOffset(6,26); fbBtn.BackgroundColor3=T.surf2; fbBtn.Text="Toggle"; fbBtn.TextColor3=T.white; fbBtn.Font=Enum.Font.GothamBold; fbBtn.TextSize=8; fbBtn.BorderSizePixel=0; fbBtn.AutoButtonColor=false; co(fbBtn,6)
local function updateFBHUD() local st=getFriendBaseStatus(); fbStatus.Text="Base: "..st; fbStatus.TextColor3=st=="OPEN" and T.grn or st=="CLOSED" and T.red or T.yel end
task.spawn(function() while task.wait(1) do if fbHUD.Parent then updateFBHUD() end end end)
fbBtn.MouseButton1Click:Connect(function()
    if friendToggleCooldown then return end; friendToggleCooldown=true
    local prompt=findMyFriendPrompt(); if prompt then fireFriendPrompt(prompt) end
    fbBtn.Text="Wait..."; fbBtn.BackgroundColor3=T.surf
    task.delay(1.8,function() friendToggleCooldown=false; fbBtn.Text="Toggle"; fbBtn.BackgroundColor3=T.surf2; updateFBHUD() end)
end)
drag(fbHUD,fbHUD)

print("Aethen Hub v0.9 loaded | @r9qbx | "..DISCORD)
