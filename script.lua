-- Aethon Suite | Made by r9qbx

local Players=game:GetService("Players"); local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService"); local RS=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService"); local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui"); local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local lp=Players.LocalPlayer; local cam=workspace.CurrentCamera

local CFG="AethonSuite.json"
local Cfg={
    triggerChance=91,flashOn=false,grabOn=true,potionOn=false,
    stealSpdOn=false,stealSpdVal=30,
    pos_LP={ox=6,oy=48},pos_FP={ox=0,oy=5},
    pos_AP={ox=0,oy=0},pos_BP={ox=0,oy=0},pos_SP={ox=6,oy=0},
}
pcall(function()
    if not readfile then return end
    local raw=readfile(CFG); if not raw or raw=="" then return end
    local ok,t=pcall(HttpService.JSONDecode,HttpService,raw)
    if ok and type(t)=="table" then for k,v in pairs(t) do Cfg[k]=v end end
end)
local function save() pcall(function() if writefile then writefile(CFG,HttpService:JSONEncode(Cfg)) end end) end

for _,v in ipairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:sub(1,2)=="AS" or v.Name:sub(1,4)=="PhFV" or v.Name:sub(1,2)=="PS") then v:Destroy() end
end
local SG=Instance.new("ScreenGui"); SG.Name="AS_"..tostring(math.random(1000,9999))
SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Global; SG.IgnoreGuiInset=true; SG.Parent=CoreGui

local T={
    bg=Color3.fromRGB(5,5,8),panel=Color3.fromRGB(8,8,13),surf=Color3.fromRGB(14,14,22),surf2=Color3.fromRGB(20,20,30),
    a1=Color3.fromRGB(225,225,238),a2=Color3.fromRGB(175,175,195),white=Color3.new(1,1,1),
    dim=Color3.fromRGB(100,100,122),str=Color3.fromRGB(155,155,178),red=Color3.fromRGB(255,65,65),grn=Color3.fromRGB(52,218,88),
    acc=Color3.fromRGB(130,100,255),
}
local function co(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=p end
local function ms(p,th,col,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Color=col or T.str; s.Transparency=tr or 0.38; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function lb(par,props) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextColor3=T.white; l.BorderSizePixel=0; for k,v in pairs(props) do l[k]=v end; l.Parent=par; return l end
local function btn(par,text,sz,pos,bg) local b=Instance.new("TextButton"); b.Size=sz; b.Position=pos; b.BackgroundColor3=bg or T.surf; b.BackgroundTransparency=0.22; b.Text=text; b.TextColor3=T.white; b.Font=Enum.Font.GothamBold; b.TextSize=9; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=par; co(b,4); ms(b,1,T.str,0.44); return b end
local function rotS(f,col) local s=ms(f,1.3,col,0.22); local g=Instance.new("UIGradient",s); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(0.25,Color3.new(0,0,0)),ColorSequenceKeypoint.new(0.5,col),ColorSequenceKeypoint.new(0.75,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}; task.spawn(function() while s and s.Parent do g.Rotation=(g.Rotation+0.9)%360; task.wait(0.016) end end) end
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
    local px=(posKey and Cfg[posKey] and Cfg[posKey].ox) or defX
    local py=(posKey and Cfg[posKey] and Cfg[posKey].oy) or defY
    local f=Instance.new("Frame"); f.Size=UDim2.fromOffset(w,h); f.Position=UDim2.fromOffset(px,py)
    f.BackgroundColor3=T.panel; f.BackgroundTransparency=0.28; f.BorderSizePixel=0; f.ClipsDescendants=true; f.Parent=SG; co(f,8); rotS(f,ac or T.a1)
    local hdr=Instance.new("Frame"); hdr.Size=UDim2.new(1,0,0,19); hdr.BackgroundColor3=T.surf; hdr.BackgroundTransparency=0.18; hdr.BorderSizePixel=0; hdr.Parent=f; co(hdr,8)
    local flat=Instance.new("Frame"); flat.Size=UDim2.new(1,0,0,6); flat.Position=UDim2.new(0,0,1,-6); flat.BackgroundColor3=T.surf; flat.BackgroundTransparency=0.18; flat.BorderSizePixel=0; flat.Parent=hdr
    if title then lb(hdr,{Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-22,1,0),Text=title,TextSize=7,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.a1}) end
    local mb=btn(hdr,"─",UDim2.fromOffset(13,11),UDim2.new(1,-16,0.5,-5.5),T.surf2); mb.TextSize=7; mb.TextColor3=T.dim; mb.BackgroundTransparency=0.6
    dragSave(hdr,f,posKey); return f,hdr,mb
end
local function mkF(parent,hH,cH,mb)
    local content=Instance.new("Frame"); content.Size=UDim2.new(1,0,0,cH); content.Position=UDim2.fromOffset(0,hH)
    content.BackgroundTransparency=1; content.BorderSizePixel=0; content.Parent=parent
    local folded=false; local fullH=parent.Size.Y.Offset
    mb.MouseButton1Click:Connect(function()
        folded=not folded; mb.Text=folded and "+" or "─"
        TweenService:Create(parent,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.new(0,parent.Size.X.Offset,0,folded and hH+2 or fullH)}):Play()
    end)
    return content
end
local function pillR(parent,label,yPos,onCol)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-6,0,18); row.Position=UDim2.new(0,3,0,yPos)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.28; row.BorderSizePixel=0; row.Parent=parent; co(row,5)
    local rs=ms(row,1,T.str,0.55)
    local rl=lb(row,{Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-34,1,0),Text=label,TextSize=7,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local track=Instance.new("Frame"); track.Size=UDim2.fromOffset(22,10); track.Position=UDim2.new(1,-25,0.5,-5); track.BackgroundColor3=T.surf2; track.BorderSizePixel=0; track.Parent=row; co(track,10)
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(7,7); knob.Position=UDim2.new(0,2,0.5,-3.5); knob.BackgroundColor3=T.a2; knob.BorderSizePixel=0; knob.Parent=track; co(knob,7)
    local pb=Instance.new("TextButton"); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1; pb.Text=""; pb.Parent=row
    local col=onCol or T.a1
    local function set(v)
        TweenService:Create(track,TweenInfo.new(0.12),{BackgroundColor3=v and col or T.surf2}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-9,0.5,-3.5) or UDim2.new(0,2,0.5,-3.5),BackgroundColor3=v and T.white or T.a2}):Play()
        TweenService:Create(rs,TweenInfo.new(0.12),{Color=v and col or T.str,Transparency=v and 0.18 or 0.55}):Play()
        rl.TextColor3=v and T.white or T.dim
    end
    return pb,set
end
local function numRow(parent,label,val,mn,mx,yPos,w,onChange)
    local IW=w-8; local row=Instance.new("Frame"); row.Size=UDim2.fromOffset(IW,18); row.Position=UDim2.fromOffset(4,yPos)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.28; row.BorderSizePixel=0; row.Parent=parent; co(row,4); ms(row,1,T.str,0.5)
    lb(row,{Position=UDim2.new(0,5,0,0),Size=UDim2.new(0.46,0,1,0),Text=label,TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local mB=Instance.new("TextButton",row); mB.Size=UDim2.fromOffset(12,12); mB.Position=UDim2.new(0.5,0,0.5,-6); mB.BackgroundColor3=T.surf2; mB.Text="-"; mB.Font=Enum.Font.GothamBold; mB.TextSize=9; mB.TextColor3=T.a1; mB.BorderSizePixel=0; mB.AutoButtonColor=false; co(mB,3)
    local vB=Instance.new("TextBox",row); vB.Size=UDim2.fromOffset(22,12); vB.Position=UDim2.new(0.5,14,0.5,-6); vB.BackgroundColor3=T.surf2; vB.BorderSizePixel=0; vB.Text=tostring(val); vB.Font=Enum.Font.GothamBold; vB.TextSize=8; vB.TextColor3=T.a1; vB.ClearTextOnFocus=false; co(vB,3)
    local pB=Instance.new("TextButton",row); pB.Size=UDim2.fromOffset(12,12); pB.Position=UDim2.new(0.5,38,0.5,-6); pB.BackgroundColor3=T.surf2; pB.Text="+"; pB.Font=Enum.Font.GothamBold; pB.TextSize=9; pB.TextColor3=T.a1; pB.BorderSizePixel=0; pB.AutoButtonColor=false; co(pB,3)
    local cur=val
    local function setV(v) cur=math.clamp(math.floor(v),mn,mx); vB.Text=tostring(cur); if onChange then onChange(cur) end end
    mB.MouseButton1Click:Connect(function() setV(cur-1) end)
    pB.MouseButton1Click:Connect(function() setV(cur+1) end)
    vB.FocusLost:Connect(function() local n=tonumber(vB.Text); if n then setV(n) else vB.Text=tostring(cur) end end)
end

task.wait(0.1); local vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end

-- Smaller panels
local LP_W=118; local LP_CH=100; local LP_H=19+LP_CH+9
local FP_W=138; local FP_CH=116; local FP_H=19+FP_CH+9
local AP_W=176; local AP_Y_DEF=5+FP_H+4
local BP_W=124; local BP_CH=4*21+4; local BP_H=19+BP_CH+9
local SP_W=118; local SP_CH=46; local SP_H=19+SP_CH+9

if not Cfg.pos_FP or Cfg.pos_FP.ox==0 then Cfg.pos_FP={ox=math.floor(vp.X-FP_W-4),oy=5} end
if not Cfg.pos_AP or Cfg.pos_AP.ox==0 then Cfg.pos_AP={ox=math.floor(vp.X-AP_W-4),oy=AP_Y_DEF} end
if not Cfg.pos_BP or Cfg.pos_BP.ox==0 then Cfg.pos_BP={ox=math.floor(vp.X*0.5-BP_W*0.5),oy=math.floor(vp.Y*0.5-BP_H*0.5)} end
if not Cfg.pos_SP or Cfg.pos_SP.oy==0 then Cfg.pos_SP={ox=4,oy=LP_H+48+4} end

-- Anti-lag always in background (silent)
pcall(function()
    Lighting.GlobalShadows=false; Lighting.FogEnd=1e9
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") then pcall(function() v.Enabled=false end) end
    end
end)
workspace.DescendantAdded:Connect(function(v)
    pcall(function()
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") then v.Enabled=false end
    end)
end)

-- Watermark
local wmL=Instance.new("TextLabel",SG); wmL.Size=UDim2.fromOffset(200,22); wmL.Position=UDim2.new(0.5,-100,0.4,-11)
wmL.BackgroundTransparency=1; wmL.Text="Made by r9qbx"; wmL.Font=Enum.Font.GothamBlack; wmL.TextSize=13; wmL.TextColor3=T.a1; wmL.TextTransparency=0.96
TweenService:Create(wmL,TweenInfo.new(2.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{TextTransparency=0.52}):Play()

-- FPS + Ping
local fpsF=Instance.new("Frame",SG); fpsF.Size=UDim2.fromOffset(128,15); fpsF.Position=UDim2.new(0.5,-64,0,4)
fpsF.BackgroundColor3=T.panel; fpsF.BackgroundTransparency=0.32; fpsF.BorderSizePixel=0; co(fpsF,5); ms(fpsF,1,T.str,0.42)
local fpsLb=lb(fpsF,{Size=UDim2.new(1,0,1,0),Text="FPS --  ·  PING -- ms",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=T.a1})
local lastDt=1/60
task.spawn(function() while task.wait(0.7) do
    if not fpsLb.Parent then break end
    local fps=math.min(999,math.floor(1/math.max(lastDt,0.001))); local ping=0
    pcall(function() ping=math.floor(lp:GetNetworkPing()*1000) end)
    fpsLb.Text="FPS "..fps.."  ·  PING "..ping.."ms"
    fpsLb.TextColor3=fps<40 and T.red or fps<55 and Color3.fromRGB(255,190,40) or T.grn
end end)

-- Reset Panels + floating buttons
local rsPnlBtn=Instance.new("TextButton",SG); rsPnlBtn.Size=UDim2.fromOffset(84,12)
rsPnlBtn.Position=UDim2.new(0.5,-42,0,48); rsPnlBtn.BackgroundColor3=T.panel; rsPnlBtn.BackgroundTransparency=0.42
rsPnlBtn.Text="Reset Panels"; rsPnlBtn.Font=Enum.Font.GothamBold; rsPnlBtn.TextSize=7; rsPnlBtn.TextColor3=T.dim
rsPnlBtn.BorderSizePixel=0; rsPnlBtn.AutoButtonColor=false; co(rsPnlBtn,3); ms(rsPnlBtn,1,T.str,0.55)

local ragF=Instance.new("Frame",SG); ragF.Size=UDim2.fromOffset(82,12); ragF.Position=UDim2.new(0.5,-86,0,63)
ragF.BackgroundColor3=Color3.fromRGB(10,6,22); ragF.BackgroundTransparency=0.1; ragF.BorderSizePixel=0; co(ragF,3); ms(ragF,1,T.acc,0.28)
local ragBtn=Instance.new("TextButton",ragF); ragBtn.Size=UDim2.new(1,0,1,0); ragBtn.BackgroundTransparency=1
ragBtn.Text="🤸 Ragdoll Self"; ragBtn.Font=Enum.Font.GothamBold; ragBtn.TextSize=7; ragBtn.TextColor3=Color3.fromRGB(180,150,255); ragBtn.BorderSizePixel=0; ragBtn.AutoButtonColor=false

local prF=Instance.new("Frame",SG); prF.Size=UDim2.fromOffset(82,12); prF.Position=UDim2.new(0.5,4,0,63)
prF.BackgroundColor3=Color3.fromRGB(10,6,22); prF.BackgroundTransparency=0.1; prF.BorderSizePixel=0; co(prF,3); ms(prF,1,Color3.fromRGB(90,60,200),0.28)
local prBtn=Instance.new("TextButton",prF); prBtn.Size=UDim2.new(1,0,1,0); prBtn.BackgroundTransparency=1
prBtn.Text="Pot + Ragdoll"; prBtn.Font=Enum.Font.GothamBold; prBtn.TextSize=7; prBtn.TextColor3=Color3.fromRGB(155,120,230); prBtn.BorderSizePixel=0; prBtn.AutoButtonColor=false

-- Timer ESP
local timerESPs={}; local myPlotRef=nil; local baseAlerted=false; local stealHitbox=nil
local ECOL_R=Color3.fromRGB(255,65,65); local ECOL_Y=Color3.fromRGB(255,190,40); local ECOL_G=Color3.fromRGB(52,218,88)
local function showAlert()
    pcall(function() local s=Instance.new("Sound"); s.SoundId="rbxassetid://9118633772"; s.Volume=0.85; s.Parent=workspace; s:Play(); Debris:AddItem(s,5) end)
    local ag=Instance.new("ScreenGui",CoreGui); ag.Name="AethAlert"; ag.ResetOnSpawn=false; ag.IgnoreGuiInset=true
    local af=Instance.new("Frame",ag); af.Size=UDim2.fromOffset(182,26); af.Position=UDim2.new(0.5,-91,0,-34)
    af.BackgroundColor3=T.panel; af.BackgroundTransparency=0.1; af.BorderSizePixel=0; co(af,7); ms(af,1.5,T.red,0.08)
    lb(af,{Size=UDim2.new(1,0,1,0),Text="⚠  BASE EXPIRES IN 5s!",TextSize=9,Font=Enum.Font.GothamBlack,TextColor3=T.red})
    TweenService:Create(af,TweenInfo.new(0.32,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-91,0,7)}):Play()
    task.delay(4,function() TweenService:Create(af,TweenInfo.new(0.22),{Position=UDim2.new(0.5,-91,0,-34)}):Play(); task.wait(0.25); ag:Destroy() end)
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
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(54,15); bb.StudsOffset=Vector3.new(0,7,0); bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
                local bgT=Instance.new("Frame",bb); bgT.Size=UDim2.new(1,0,1,0); bgT.BackgroundColor3=Color3.fromRGB(6,6,10); bgT.BackgroundTransparency=0.18; bgT.BorderSizePixel=0; co(bgT,4)
                local stk=Instance.new("UIStroke",bgT); stk.Color=ECOL_Y; stk.Thickness=0.8; stk.Transparency=0.28
                local tl=Instance.new("TextLabel",bgT); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold; tl.TextSize=9; tl.TextColor3=ECOL_Y; tl.TextStrokeTransparency=0.45; tl.TextStrokeColor3=Color3.new(0,0,0)
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
task.spawn(function() while task.wait(0.9) do
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

-- Player ESP
local ESPTAG="AS_"..tostring(math.random(1000,9999))
local function mkESP(plr)
    if plr==lp then return end
    local char=plr.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end
    local box=Instance.new("BoxHandleAdornment",char); box.Name=ESPTAG; box.Adornee=hrp; box.Size=Vector3.new(4,6,2); box.Color3=T.a1; box.Transparency=0.5; box.ZIndex=10; box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char); bb.Name=ESPTAG.."N"; bb.Adornee=char:FindFirstChild("Head") or hrp; bb.Size=UDim2.fromOffset(130,24); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true
    local bgE=Instance.new("Frame",bb); bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=Color3.fromRGB(7,7,11); bgE.BackgroundTransparency=0.22; bgE.BorderSizePixel=0; co(bgE,5); ms(bgE,1,T.a1,0.25)
    lb(bgE,{Size=UDim2.new(1,0,0.58,0),BackgroundTransparency=1,Text=plr.DisplayName,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=T.a1,TextStrokeTransparency=0.45,TextStrokeColor3=Color3.new(0,0,0)})
    lb(bgE,{Size=UDim2.new(1,0,0.42,0),Position=UDim2.new(0,0,0.58,0),BackgroundTransparency=1,Text="@"..plr.Name,Font=Enum.Font.Gotham,TextSize=7,TextColor3=T.dim})
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
    local bg=Instance.new("Frame",bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(14,2,2); bg.BackgroundTransparency=0.05; bg.BorderSizePixel=0; co(bg,6)
    local stroke=Instance.new("UIStroke",bg); stroke.Color=Color3.fromRGB(255,40,40); stroke.Thickness=1.5
    local bar=Instance.new("Frame",bg); bar.Size=UDim2.fromOffset(3,28); bar.BackgroundColor3=Color3.fromRGB(255,50,50); bar.BorderSizePixel=0; co(bar,2)
    lb(bg,{Size=UDim2.fromOffset(14,28),Position=UDim2.fromOffset(5,0),BackgroundTransparency=1,Text="⚠",Font=Enum.Font.GothamBlack,TextSize=10,TextColor3=Color3.fromRGB(255,80,80)})
    lb(bg,{Size=UDim2.new(1,-22,0,15),Position=UDim2.fromOffset(20,1),BackgroundTransparency=1,Text="SUBSPACE MINE",Font=Enum.Font.GothamBlack,TextSize=8,TextColor3=Color3.fromRGB(255,90,90),TextXAlignment=Enum.TextXAlignment.Left,TextStrokeTransparency=0.4,TextStrokeColor3=Color3.new(0,0,0)})
    local distL=lb(bg,{Size=UDim2.new(1,-22,0,11),Position=UDim2.fromOffset(20,14),BackgroundTransparency=1,Text="-- studs",Font=Enum.Font.Gotham,TextSize=7,TextColor3=Color3.fromRGB(180,80,80),TextXAlignment=Enum.TextXAlignment.Left})
    task.spawn(function()
        while bb.Parent do
            TweenService:Create(stroke,TweenInfo.new(0.55,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.72}):Play(); TweenService:Create(bar,TweenInfo.new(0.55),{BackgroundTransparency=0.5}):Play()
            task.wait(0.55); if not bb.Parent then break end
            TweenService:Create(stroke,TweenInfo.new(0.55,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0}):Play(); TweenService:Create(bar,TweenInfo.new(0.55),{BackgroundTransparency=0}):Play()
            task.wait(0.55)
        end
    end)
    local dc=RunService.Heartbeat:Connect(function()
        if not bb.Parent or not part.Parent then return end
        local char=lp.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local d=math.round((root.Position-part.Position).Magnitude)
            distL.Text=d.." studs away"
            distL.TextColor3=d<15 and Color3.fromRGB(255,60,60) or d<30 and Color3.fromRGB(220,100,80) or Color3.fromRGB(160,80,80)
        end
    end)
    mineESPs[child]={bb=bb,dc=dc}
    child.AncestryChanged:Connect(function()
        if not child.Parent then pcall(function() bb:Destroy() end); pcall(function() dc:Disconnect() end); mineESPs[child]=nil end
    end)
end
for _,d in pairs(workspace:GetDescendants()) do addMineESP(d) end
workspace.DescendantAdded:Connect(function(d) task.defer(function() addMineESP(d) end) end)

-- Brainrot ESP
local brainrotESPs={}
local function addBrainrotESP(model,plot)
    if not model or brainrotESPs[model] then return end
    if not (model:IsA("Model") or model:IsA("BasePart")) then return end
    local part=model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")) or (model:IsA("BasePart") and model)
    if not part then return end
    local ownerDisplay="?"
    if plot then local sign=plot:FindFirstChild("PlotSign"); if sign then local tl=sign:FindFirstChild("TextLabel",true); if tl then ownerDisplay=tl.Text end end end
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(120,30); bb.StudsOffset=Vector3.new(0,6,0); bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=workspace
    local bgB=Instance.new("Frame",bb); bgB.Size=UDim2.new(1,0,1,0); bgB.BackgroundColor3=Color3.fromRGB(6,4,14); bgB.BackgroundTransparency=0.1; bgB.BorderSizePixel=0; co(bgB,5); ms(bgB,1,Color3.fromRGB(140,80,255),0.15)
    lb(bgB,{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,1),BackgroundTransparency=1,Text="🧠 "..model.Name,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=Color3.fromRGB(200,150,255),TextStrokeTransparency=0.4,TextStrokeColor3=Color3.new(0,0,0),TextTruncate=Enum.TextTruncate.AtEnd})
    lb(bgB,{Size=UDim2.new(1,-4,0,12),Position=UDim2.fromOffset(2,16),BackgroundTransparency=1,Text="📍 "..ownerDisplay,Font=Enum.Font.Gotham,TextSize=7,TextColor3=Color3.fromRGB(160,120,200),TextTruncate=Enum.TextTruncate.AtEnd})
    brainrotESPs[model]={bb=bb}
    model.AncestryChanged:Connect(function() if not model.Parent then pcall(function() bb:Destroy() end); brainrotESPs[model]=nil end end)
end
local function scanPodium(pod,plot)
    local base=pod:FindFirstChild("Base"); if not base then return end
    local spawn=base:FindFirstChild("Spawn"); if not spawn then return end
    for _,child in ipairs(spawn:GetChildren()) do addBrainrotESP(child,plot) end
    spawn.ChildAdded:Connect(function(child) task.defer(function() addBrainrotESP(child,plot) end) end)
end
local function scanPlotBrainrots(plot)
    local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then return end
    for _,pod in ipairs(pods:GetChildren()) do scanPodium(pod,plot) end
    pods.ChildAdded:Connect(function(pod) task.defer(function() scanPodium(pod,plot) end) end)
end
task.spawn(function()
    local plots=workspace:FindFirstChild("Plots"); if not plots then return end
    for _,plot in ipairs(plots:GetChildren()) do scanPlotBrainrots(plot) end
    plots.ChildAdded:Connect(function(plot) task.defer(function() scanPlotBrainrots(plot) end) end)
end)

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
local ROW_CD={ragdoll=30,balloon=30,tiny=60,jail=60,rocket=120}
local CMD_ICONS={ragdoll="🤸",balloon="🎈",tiny="🐜",jail="🔒",rocket="🚀"}
local rowCdEnd={}
local function fireCmd(tgt,cmd) if not ADM_REMOTE then return end; aFire(tgt,cmd); rowCdEnd[cmd]=tick()+(ROW_CD[cmd] or 30) end
local CLICK_CMDS={"tiny","inverse","rocket","jumpscare"}
local function fireClick(tgt)
    if not ADM_REMOTE then return end
    for _,cmd in ipairs(CLICK_CMDS) do aFire(tgt,cmd); if ROW_CD[cmd] then rowCdEnd[cmd]=tick()+ROW_CD[cmd] end end
end

ragBtn.MouseButton1Click:Connect(function()
    if ADM_REMOTE then pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end); rowCdEnd["ragdoll"]=tick()+(ROW_CD["ragdoll"] or 30) end
end)
prBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local char=lp.Character
        if char then pcall(function()
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local bp=lp:FindFirstChild("Backpack")
            local pot=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion"))
            if pot then hum:EquipTool(pot); task.wait(0.1); pot:Activate() end
        end) end
        task.wait(0.5)
        if ADM_REMOTE then pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end); rowCdEnd["ragdoll"]=tick()+(ROW_CD["ragdoll"] or 30) end
    end)
end)

-- BASE PROTECTOR (full working version with RE listeners)
local CARPET={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true,["Cupid's Wings"]=true}
local antiSteal=false; local autoKick=false; local antiIntruder=false; local antiTp=false
local lastPunish={}; local carpetSpam={}; local plrPos={}; local tpCD={}
local myStealPrompts={}
task.spawn(function() while task.wait(2) do
    myStealPrompts={}
    if myPlotRef then
        for _,obj in ipairs(myPlotRef:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.ActionText=="Steal" and obj.Enabled then table.insert(myStealPrompts,obj) end
        end
    end
end end)
local function punish(p)
    if not ADM_REMOTE or not p or p==lp then return end
    local char=p.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local uid=p.UserId; local now=tick()
    if lastPunish[uid] and now-lastPunish[uid]<0.5 then return end
    lastPunish[uid]=now
    pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)
    rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
    if autoKick then task.delay(0.05,function() lp:Kick("SAVED BY AETHON🫡") end) end
end
local function findThief()
    if #myStealPrompts>0 then
        local best,bd=nil,math.huge
        for _,prompt in ipairs(myStealPrompts) do
            if not prompt or not prompt.Parent then continue end
            local pPart=prompt.Parent
            local pPos=pPart:IsA("BasePart") and pPart.Position or (pPart:IsA("Attachment") and pPart.WorldPosition)
            if not pPos then continue end
            local maxDist=math.max(prompt.MaxActivationDistance,8)
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=lp and p.Character then
                    local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then local d=(hrp.Position-pPos).Magnitude; if d<=maxDist and d<bd then bd=d;best=p end end
                end
            end
        end
        if best then return best end
    end
    if stealHitbox then
        local hbPos=stealHitbox.Position; local best,bd=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then local d=(hrp.Position-hbPos).Magnitude; if d<bd then bd=d;best=p end end
            end
        end
        return best
    end
    return nil
end
local function chkHitbox()
    if not stealHitbox then return end
    local cf,sz=stealHitbox.CFrame,stealHitbox.Size; local hx,hz=sz.X*0.5,sz.Z*0.5
    for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then
        local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local rel=cf:PointToObjectSpace(hrp.Position)
        if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then
            for _,item in ipairs(p.Character:GetChildren()) do if CARPET[item.Name] then punish(p); break end end
        end
    end end
end
pcall(function()
    if not hookfunction or not fireproximityprompt then return end
    local old=fireproximityprompt
    hookfunction(fireproximityprompt,newcclosure(function(prompt,...)
        if antiSteal and (prompt.ActionText or ""):lower():find("steal") then
            local thief=findThief(); if thief then punish(thief) end; chkHitbox()
        end
        return old(prompt,...)
    end))
end)
-- RE/StealService fast detection (from DEX)
task.spawn(function()
    pcall(function()
        local net=RS:WaitForChild("Packages"):WaitForChild("Net",8); if not net then return end
        local grabRE=net:FindFirstChild("RE/StealService/Grab")
        local successRE=net:FindFirstChild("RE/StealService/StealingSuccess")
        if grabRE then grabRE.OnClientEvent:Connect(function()
            if not antiSteal or not ADM_REMOTE or not myPlotRef then return end
            local thief=findThief(); if thief then punish(thief) end
        end) end
        if successRE then successRE.OnClientEvent:Connect(function()
            if not antiSteal or not ADM_REMOTE or not myPlotRef then return end
            local thief=findThief(); if thief then punish(thief) end
        end) end
    end)
    pcall(function()
        for _,obj in ipairs(RS:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                obj.OnClientEvent:Connect(function(...)
                    if not antiSteal or not ADM_REMOTE or not myPlotRef then return end
                    for _,a in ipairs({...}) do
                        if type(a)=="string" and a:lower():find("stealing") then
                            local thief=findThief(); if thief then punish(thief) end; return
                        end
                    end
                end)
            end
        end
    end)
end)

-- Giant Potion
local potionOn=Cfg.potionOn
local function isPotionReady()
    local char=lp.Character; if not char then return false end
    local bp=lp:FindFirstChild("Backpack")
    return char:FindFirstChild("Giant Potion")~=nil or (bp and bp:FindFirstChild("Giant Potion")~=nil)
end
local function activatePotion()
    if not potionOn or not isPotionReady() then return end
    task.spawn(function() pcall(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local bp=lp:FindFirstChild("Backpack")
        local tool=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion")); if not tool then return end
        hum:EquipTool(tool); task.wait(0.08); tool:Activate()
    end) end)
end

-- Carpet equip (Tokinu reset)
local CARPET_KW={"carpet","tapis","flying","witch","broom","sleigh","cupid","wing"}
local function equipCarpetTool()
    local char=lp.Character; if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local bp=lp:FindFirstChild("Backpack"); local found=nil
    local function chk(tool)
        if not tool:IsA("Tool") then return end
        local nl=tool.Name:lower()
        for _,kw in ipairs(CARPET_KW) do if nl:find(kw) then found=tool; return end end
    end
    if bp then for _,t in ipairs(bp:GetChildren()) do if not found then chk(t) end end end
    if not found then for _,t in ipairs(char:GetChildren()) do if not found then chk(t) end end end
    if found then
        if found.Parent~=char then found.Parent=char end
        hum:EquipTool(found); return true
    end
    return false
end

local function doReset()
    local c=lp.Character; if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso"); if not h then return end
    local equipped=equipCarpetTool()
    if equipped then task.wait(0.1) end
    h.CFrame=CFrame.new(0,15000,0)
end

-- Flash tool equip
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

-- =====================================================================
-- AUTO ALLIGN - 27 podium positions with cam aligns
-- Equips carpet → TPs to nearest podium → aligns cam → equips Flash
-- =====================================================================
local PodiumPoints={
    -- Floor 1 A Side
    {pos=Vector3.new(-330.3,-4.9,94.6), camCF=CFrame.lookAt(Vector3.new(-324.852,3.376,103.738),Vector3.new(-325.155,2.826,102.959))},
    {pos=Vector3.new(-323.4,-4.9,94.0), camCF=CFrame.lookAt(Vector3.new(-316.695,3.492,102.060),Vector3.new(-317.111,2.933,101.343))},
    {pos=Vector3.new(-315.9,-4.9,94.2), camCF=CFrame.lookAt(Vector3.new(-310.255,3.690,102.906),Vector3.new(-310.581,3.115,102.156))},
    {pos=Vector3.new(-309.7,-4.9,94.2), camCF=CFrame.lookAt(Vector3.new(-302.102,3.311,101.665),Vector3.new(-302.596,2.766,100.988))},
    {pos=Vector3.new(-296.8,-5.4,93.7), camCF=CFrame.lookAt(Vector3.new(-292.982,-1.861,94.294),Vector3.new(-293.677,-2.389,93.806))},
    -- Floor 1 B Side
    {pos=Vector3.new(-300.4,-5.2,129.8), camCF=CFrame.lookAt(Vector3.new(-304.365,-0.257,136.083),Vector3.new(-303.880,-0.681,135.318))},
    {pos=Vector3.new(-306.6,-5.4,128.0), camCF=CFrame.lookAt(Vector3.new(-315.538,0.977,135.225),Vector3.new(-314.824,0.579,134.649))},
    {pos=Vector3.new(-317.0,-5.1,134.5), camCF=CFrame.lookAt(Vector3.new(-312.718,-0.547,132.938),Vector3.new(-313.495,-1.113,133.215))},
    {pos=Vector3.new(-324.1,-4.9,131.7), camCF=CFrame.lookAt(Vector3.new(-320.155,0.308,136.046),Vector3.new(-320.722,-0.235,135.426))},
    {pos=Vector3.new(-336.7,-5.4,130.5), camCF=CFrame.lookAt(Vector3.new(-334.110,-2.056,136.160),Vector3.new(-334.243,-2.365,135.218))},
    -- Floor 2 A Side
    {pos=Vector3.new(-329.9,13.1,93.7), camCF=CFrame.lookAt(Vector3.new(-325.140,10.148,97.954),Vector3.new(-325.575,10.727,97.264))},
    {pos=Vector3.new(-324.2,12.8,102.0), camCF=CFrame.lookAt(Vector3.new(-322.517,12.013,109.124),Vector3.new(-322.504,12.305,108.168))},
    {pos=Vector3.new(-315.9,12.8,92.8), camCF=CFrame.lookAt(Vector3.new(-308.210,20.319,93.432),Vector3.new(-308.949,19.689,93.195))},
    {pos=Vector3.new(-309.4,13.1,94.2), camCF=CFrame.lookAt(Vector3.new(-304.720,23.019,95.189),Vector3.new(-305.112,22.135,94.937))},
    {pos=Vector3.new(-299.3,12.9,93.4), camCF=CFrame.lookAt(Vector3.new(-292.952,19.006,93.712),Vector3.new(-293.701,18.397,93.450))},
    -- Floor 2 B Side
    {pos=Vector3.new(-323.5,12.6,122.7), camCF=CFrame.lookAt(Vector3.new(-314.237,20.013,131.706),Vector3.new(-314.794,19.588,130.993))},
    {pos=Vector3.new(-336.7,12.6,131.6), camCF=CFrame.lookAt(Vector3.new(-334.348,15.893,136.155),Vector3.new(-334.473,15.531,135.232))},
    {pos=Vector3.new(-316.8,12.6,122.1), camCF=CFrame.lookAt(Vector3.new(-304.595,19.357,127.057),Vector3.new(-305.398,18.978,126.596))},
    -- Floor 3 A Side
    {pos=Vector3.new(-334.2,29.6,93.5), camCF=CFrame.lookAt(Vector3.new(-336.907,26.898,98.850),Vector3.new(-336.341,27.477,98.263))},
    {pos=Vector3.new(-322.9,29.8,92.7), camCF=CFrame.lookAt(Vector3.new(-312.668,38.516,94.243),Vector3.new(-313.441,37.935,93.989))},
    {pos=Vector3.new(-312.9,30.0,93.9), camCF=CFrame.lookAt(Vector3.new(-305.856,41.590,96.372),Vector3.new(-306.347,40.779,96.055))},
    {pos=Vector3.new(-305.8,30.1,93.6), camCF=CFrame.lookAt(Vector3.new(-295.325,41.918,96.411),Vector3.new(-295.979,41.221,96.117))},
    {pos=Vector3.new(-299.9,30.1,93.5), camCF=CFrame.lookAt(Vector3.new(-296.349,34.097,93.014),Vector3.new(-297.064,33.456,92.736))},
    -- Floor 3 B Side
    {pos=Vector3.new(-335.8,29.6,131.6), camCF=CFrame.lookAt(Vector3.new(-333.401,33.240,136.147),Vector3.new(-333.535,32.820,135.249))},
    {pos=Vector3.new(-321.3,29.8,127.1), camCF=CFrame.lookAt(Vector3.new(-311.401,30.330,130.143),Vector3.new(-312.291,30.419,129.696))},
    {pos=Vector3.new(-314.6,29.8,134.6), camCF=CFrame.lookAt(Vector3.new(-309.991,30.451,131.699),Vector3.new(-310.954,30.604,131.923))},
    {pos=Vector3.new(-306.4,29.7,127.6), camCF=CFrame.lookAt(Vector3.new(-309.658,30.589,131.997),Vector3.new(-308.840,30.687,131.430))},
}
local function getNearestPodium()
    local char=lp.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local myPos=hrp.Position; local nearest,minD=nil,math.huge
    for _,pt in ipairs(PodiumPoints) do
        local d=(myPos-pt.pos).Magnitude; if d<minD then minD=d; nearest=pt end
    end
    return nearest
end
local function doAutoAlign()
    local nearest=getNearestPodium(); if not nearest then return end
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    -- Equip carpet, TP
    equipCarpetTool(); task.wait(0.05)
    hrp.Velocity=Vector3.new(0,0,0)
    hrp.CFrame=CFrame.new(nearest.pos)
    task.wait(0.1)
    -- Align camera
    cam.CameraType=Enum.CameraType.Scriptable
    cam.CFrame=nearest.camCF
    task.wait(0.05)
    -- Equip Flash tool after TP
    equipFlash()
end

-- =====================================================================
-- SWIFTY ZERO GRAVITY (always in background)
-- Applies bodyforce to counteract gravity for stable steal position
-- =====================================================================
local function applySwiftyGrav()
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local existing=root:FindFirstChild("AethGrav"); if existing then existing:Destroy() end
    local bf=Instance.new("BodyForce",root)
    bf.Name="AethGrav"
    bf.Force=Vector3.new(0,workspace.Gravity*root.AssemblyMass,0)
end
lp.CharacterAdded:Connect(function() task.wait(1); pcall(applySwiftyGrav) end)
if lp.Character then pcall(applySwiftyGrav) end
task.spawn(function() while task.wait(4) do pcall(applySwiftyGrav) end end)

-- =====================================================================
-- SWIFTY FLASH TP (zero gravity in background + Vander steal)
-- =====================================================================
local flashEnabled=Cfg.flashOn; local sliderValue=Cfg.triggerChance/100; local activePrompts={}

PPS.PromptButtonHoldBegan:Connect(function(prompt)
    if not flashEnabled or prompt.ActionText~="Steal" or activePrompts[prompt] then return end
    activePrompts[prompt]=true
    local fired=false
    local fireAt=os.clock()+math.max(prompt.HoldDuration,0.001)*sliderValue
    local conn
    conn=RunService.Heartbeat:Connect(function()
        if fired then conn:Disconnect(); return end
        if not prompt or not prompt.Parent then conn:Disconnect(); activePrompts[prompt]=nil; return end
        if os.clock()>=fireAt then
            fired=true; conn:Disconnect(); activePrompts[prompt]=nil
            local char=lp.Character; local tool=char and char:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
            -- Vander steal immediately (swifty - zero grav makes position stable)
            task.spawn(function()
                pcall(function() fireproximityprompt(prompt,10000) end)
                pcall(function() prompt:InputHoldBegin(); task.wait(0.04); prompt:InputHoldEnd() end)
            end)
            task.spawn(function() activatePotion() end)
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function()
        if not fired then fired=true; activePrompts[prompt]=nil; conn:Disconnect() end
    end)
end)

-- Anti-ragdoll always running
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart"); if not (hum and root) then return end
    local s=hum:GetState()
    local ragdolled=(s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown)
    local endTime=lp:GetAttribute("RagdollEndTime")
    if endTime and (endTime-workspace:GetServerTimeNow())>0 then ragdolled=true end
    if ragdolled then
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

-- Anti-sentry
local DETECTION_DISTANCE=200; local PULL_DISTANCE=-5; local sentryFirstSeen={}; local sentryTarget=nil
local function getSentryWeapon() local char=lp.Character; if not char then return nil end; return (lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat") end
local function findSentryTarget()
    local char=lp.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local rootPos=hrp.Position; local now=tick()
    for obj in pairs(sentryFirstSeen) do if not obj.Parent then sentryFirstSeen[obj]=nil end end
    for _,obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local ownerId=obj.Name:match("Sentry_(%d+)"); if ownerId and tonumber(ownerId)==lp.UserId then continue end
            local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part and (rootPos-part.Position).Magnitude<=DETECTION_DISTANCE then
                if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=now end
                if now-sentryFirstSeen[obj]>=3 then return obj end
            end
        end
    end; return nil
end
local function moveSentry(obj)
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    for _,p2 in pairs(obj:GetDescendants()) do if p2:IsA("BasePart") then p2.CanCollide=false end end
    local cf=hrp.CFrame*CFrame.new(0,0,PULL_DISTANCE)
    if obj:IsA("BasePart") then obj.CFrame=cf elseif obj:IsA("Model") then local main=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if main then main.CFrame=cf end end
end
local function attackSentry()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local weapon=getSentryWeapon(); if not weapon then return end
    if weapon.Parent==lp.Backpack then hum:EquipTool(weapon); task.wait(0.1) end
    local handle=weapon:FindFirstChild("Handle"); if handle then handle.CanCollide=false end
    pcall(function() weapon:Activate() end)
    for _,r in pairs(weapon:GetDescendants()) do if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end end
end
RunService.Heartbeat:Connect(function()
    if sentryTarget and sentryTarget.Parent==workspace then moveSentry(sentryTarget); attackSentry()
    else sentryTarget=findSentryTarget() end
end)
task.spawn(function() task.wait(1)
    for _,obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local ownerId=obj.Name:match("Sentry_(%d+)")
            if not (ownerId and tonumber(ownerId)==lp.UserId) then sentryFirstSeen[obj]=tick()-3 end
        end
    end
end)

-- Anti-bee
local FOV_LOCK=70
RunService.RenderStepped:Connect(function() if cam.FieldOfView~=FOV_LOCK then cam.FieldOfView=FOV_LOCK end end)
local beeBlacklist={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","PostEffect"}
local function isBeeEffect(obj) for _,n in ipairs(beeBlacklist) do if obj:IsA(n) then return true end end return false end
local function clearBeeEffects() for _,v in pairs(Lighting:GetDescendants()) do if isBeeEffect(v) then pcall(function() v:Destroy() end) end end end
clearBeeEffects()
Lighting.DescendantAdded:Connect(function(obj) task.wait(); if isBeeEffect(obj) then pcall(function() obj:Destroy() end) end end)
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    for _,obj in ipairs(char:GetDescendants()) do
        local nl=obj.Name:lower()
        if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") then pcall(function() obj:Destroy() end) end
    end
    for _,val in ipairs(char:GetChildren()) do
        if val:IsA("BoolValue") or val:IsA("IntValue") or val:IsA("NumberValue") then
            local nl=val.Name:lower()
            if nl:find("bee") or nl:find("invert") or nl:find("reverse") then
                pcall(function() if val:IsA("BoolValue") then val.Value=false else val.Value=0 end end)
            end
        end
    end
    local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.MoveDirection.Magnitude>0.1 then
        local md=hum.MoveDirection; local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
        if vel.Magnitude>2 and md:Dot(vel.Unit)<-0.3 then root.Velocity=Vector3.new(md.X*20,root.Velocity.Y,md.Z*20) end
    end
end)

-- Speed
local stealSpdOn=Cfg.stealSpdOn; local STEAL_SPD_VAL=math.clamp(Cfg.stealSpdVal or 30,10,60)
local speedEnabled=stealSpdOn; local stealingSpeed=STEAL_SPD_VAL; local normalSpeed=30; local isStealing=false
local function applySpeed()
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); local humanoid=char:FindFirstChildOfClass("Humanoid"); if not root or not humanoid then return end
    local dir=humanoid.MoveDirection
    if dir.Magnitude>0 then local spd=isStealing and stealingSpeed or normalSpeed; local vel=dir*spd; root.Velocity=Vector3.new(vel.X,root.Velocity.Y,vel.Z) end
end

-- =====================================================================
-- VON SUPREME INSTANT GRAB (EXT getconnections method, faster fill)
-- PromptButtonHoldBegan → wait STEAL_DELAY → Triggered
-- Searches AnimalPodiums path specifically (von approach)
-- =====================================================================
local grabEnabled=Cfg.grabOn
local STEAL_DELAY=0.35  -- faster than von's 1.3s, EXT bypasses timing
local stealInProgress=false

local function fireConns(prompt,signalName)
    local ok,conns=pcall(getconnections,prompt[signalName])
    if not ok or type(conns)~="table" then return false end
    local found=false
    for _,c in ipairs(conns) do if c.Function then task.spawn(c.Function); found=true end end
    return found
end

local function getPos2(pr)
    local p=pr.Parent
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Model") then local r=p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart"); return r and r.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    local pt=p:FindFirstChildWhichIsA("BasePart",true); return pt and pt.Position
end

local function isValidStealPrompt(pr)
    if not pr or not pr.Parent or not pr.Enabled then return false end
    local at=pr.ActionText; local st=pr:GetAttribute("State")
    return at=="Steal" or at=="Grab" or at:lower():find("steal") or st=="Steal" or st=="Grab"
end

local function findNearestSteal()
    local char=lp.Character; if not char then return nil end
    local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"); if not root then return nil end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local myPos=root.Position; local nearest,nd=nil,math.huge
    for _,plot in ipairs(plots:GetChildren()) do
        if myPlotRef and plot==myPlotRef then continue end
        -- Von approach: AnimalPodiums → Base → Spawn → PromptAttachment
        local pods=plot:FindFirstChild("AnimalPodiums")
        if pods then
            for _,pod in ipairs(pods:GetChildren()) do
                local base=pod:FindFirstChild("Base")
                local spawnP=base and base:FindFirstChild("Spawn")
                local attach=spawnP and spawnP:FindFirstChild("PromptAttachment")
                if attach then
                    for _,child in ipairs(attach:GetChildren()) do
                        if child:IsA("ProximityPrompt") and isValidStealPrompt(child) then
                            local pos=attach.WorldPosition
                            local d=(myPos-pos).Magnitude
                            if d<=math.max(child.MaxActivationDistance,10) and d<nd then nearest=child;nd=d end
                        end
                    end
                end
            end
        end
        -- General fallback
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and isValidStealPrompt(obj) then
                local pos=getPos2(obj); if pos then
                    local d=(myPos-pos).Magnitude
                    if d<=math.max(obj.MaxActivationDistance,8) and d<nd then nearest=obj;nd=d end
                end
            end
        end
    end
    return nearest
end

task.spawn(function()
    while true do
        if grabEnabled and not stealInProgress then
            local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                local nearest=findNearestSteal()
                if nearest then
                    stealInProgress=true
                    task.spawn(function()
                        -- Von: fire hold connections → wait → fire triggered
                        local holdFired=fireConns(nearest,"PromptButtonHoldBegan")
                        if not holdFired then
                            -- Fallback Vander
                            pcall(function() fireproximityprompt(nearest,10000) end)
                            pcall(function() nearest:InputHoldBegin() end)
                        end
                        task.wait(STEAL_DELAY)
                        if nearest and nearest.Parent and nearest.Enabled then
                            local trigFired=fireConns(nearest,"Triggered")
                            if not trigFired and not holdFired then
                                pcall(function() nearest:InputHoldEnd() end)
                            end
                        end
                        stealInProgress=false
                    end)
                    activatePotion()
                end
            end
        end
        task.wait(0.1+math.random()*0.05)
    end
end)

local cmdBtnRefs={}
RunService.Heartbeat:Connect(function(dt)
    lastDt=dt; local now=tick()
    if speedEnabled then applySpeed() end
    if antiIntruder and stealHitbox and ADM_REMOTE then
        local cf,sz=stealHitbox.CFrame,stealHitbox.Size; local hx,hz=sz.X*0.5,sz.Z*0.5
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local rel=cf:PointToObjectSpace(hrp.Position)
            if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then
                for _,item in ipairs(p.Character:GetChildren()) do if CARPET[item.Name] then
                    local uid=p.UserId
                    if not carpetSpam[uid] then
                        carpetSpam[uid]=true; pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)
                        rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
                        if autoKick then task.delay(0.05,function() lp:Kick("SAVED BY AETHON🫡") end) end
                        task.delay(5,function() carpetSpam[uid]=nil end)
                    end; break
                end end
            end
        end end
    end
    if antiTp and ADM_REMOTE then
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local cur=hrp.Position; local uid=p.UserId; local last=plrPos[uid]
            if last and (cur-last).Magnitude>7 then
                for _,item in ipairs(p.Character:GetChildren()) do if CARPET[item.Name] then
                    if not tpCD[uid] or now-tpCD[uid]>3 then
                        tpCD[uid]=now; pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)
                        rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
                        if autoKick then task.delay(0.05,function() lp:Kick("SAVED BY AETHON🫡") end) end
                    end; break
                end end
            end
            plrPos[uid]=cur
        end end
    end
    for _,cmds in pairs(cmdBtnRefs) do
        for cmd,ib in pairs(cmds) do if ib and ib.Parent then
            local cd=rowCdEnd[cmd]
            if cd and cd>now then
                local rem=math.ceil(cd-now); local rs=tostring(rem)
                if ib.Text~=rs then ib.Text=rs; ib.TextSize=8; ib.TextColor3=T.red; ib.BackgroundColor3=Color3.fromRGB(65,8,8); ib.BackgroundTransparency=0.1 end
            else
                local icon=CMD_ICONS[cmd] or "?"
                if ib.Text~=icon then ib.Text=icon; ib.TextSize=10; ib.TextColor3=T.a1; ib.BackgroundColor3=T.surf2; ib.BackgroundTransparency=0.22 end
            end
        end end
    end
end)

-- PANEL A: Aethon Hub
local LP,_,lpMin=mkP(4,48,LP_W,LP_H,"Aethon Hub",T.a1,"pos_LP")
local lpC=mkF(LP,19,LP_CH,lpMin); local lY=3
local function lpB(text,bg) local b=btn(lpC,text,UDim2.fromOffset(LP_W-8,19),UDim2.fromOffset(4,lY),bg); lY=lY+24; return b end
local rejB=lpB("Rejoin"); rejB.TextColor3=T.a1
do local s=rejB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.a1;s.Transparency=0.22 end end
rejB.MouseButton1Click:Connect(function() rejB.Text="..."; pcall(function() if reconnect then reconnect() elseif syn and syn.reconnect then syn.reconnect() else TeleportService:Teleport(game.PlaceId,lp) end end) end)
local kickB=lpB("Kick"); kickB.TextColor3=T.red
do local s=kickB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.red;s.Transparency=0.3 end end
kickB.MouseButton1Click:Connect(function() kickB.Text="..."; lp:Kick("r9qbx on dc for suggestions") end)
local grabB=lpB("Instant Grab: ON"); grabB.TextSize=7
local function updG() grabB.Text=grabEnabled and "Instant Grab: ON" or "Instant Grab: OFF"
    TweenService:Create(grabB,TweenInfo.new(0.1),{BackgroundColor3=grabEnabled and Color3.fromRGB(12,22,12) or T.surf}):Play()
    grabB.TextColor3=grabEnabled and T.grn or T.white end
updG(); grabB.MouseButton1Click:Connect(function() grabEnabled=not grabEnabled; Cfg.grabOn=grabEnabled; save(); updG() end)
local camBusy=false; local camB=lpB("AUTO ALLIGN"); camB.TextSize=7
camB.MouseButton1Click:Connect(function()
    if camBusy then return end; camBusy=true; camB.Text="Aligning..."
    TweenService:Create(camB,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(12,12,32)}):Play()
    task.spawn(function()
        pcall(doAutoAlign)
        camB.Text="AUTO ALLIGN"; TweenService:Create(camB,TweenInfo.new(0.12),{BackgroundColor3=T.surf}):Play(); camBusy=false
    end)
end)

-- PANEL B: Flash TP
local FP,_,fpMin=mkP(0,5,FP_W,FP_H,"Flash TP",T.a2,"pos_FP")
local fpC=mkF(FP,19,FP_CH,fpMin)
local togRow=Instance.new("Frame"); togRow.Size=UDim2.fromOffset(FP_W-8,19); togRow.Position=UDim2.fromOffset(4,3)
togRow.BackgroundColor3=T.surf; togRow.BackgroundTransparency=0.28; togRow.BorderSizePixel=0; togRow.Parent=fpC; co(togRow,5)
local togRS=ms(togRow,1,T.str,0.55)
local togLbl=lb(togRow,{Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-38,1,0),Text="Swifty Flash TP",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local pill=Instance.new("Frame"); pill.Size=UDim2.fromOffset(22,10); pill.Position=UDim2.new(1,-25,0.5,-5); pill.BackgroundColor3=T.surf2; pill.BorderSizePixel=0; pill.Parent=togRow; co(pill,10)
local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(7,7); knob.Position=UDim2.new(0,2,0.5,-3.5); knob.BackgroundColor3=T.a2; knob.BorderSizePixel=0; knob.Parent=pill; co(knob,7)
local togB=Instance.new("TextButton"); togB.Size=UDim2.new(1,0,1,0); togB.BackgroundTransparency=1; togB.Text=""; togB.Parent=togRow
local function updFl()
    TweenService:Create(togRow,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and Color3.fromRGB(12,12,20) or T.surf,BackgroundTransparency=flashEnabled and 0.15 or 0.28}):Play()
    TweenService:Create(togRS,TweenInfo.new(0.12),{Color=flashEnabled and T.a1 or T.str,Transparency=flashEnabled and 0.2 or 0.55}):Play()
    TweenService:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and T.a1 or T.surf2}):Play()
    TweenService:Create(knob,TweenInfo.new(0.12),{Position=flashEnabled and UDim2.new(1,-9,0.5,-3.5) or UDim2.new(0,2,0.5,-3.5),BackgroundColor3=flashEnabled and T.white or T.a2}):Play()
    togLbl.TextColor3=flashEnabled and T.white or T.dim
end
updFl(); togB.MouseButton1Click:Connect(function() flashEnabled=not flashEnabled; Cfg.flashOn=flashEnabled; save(); updFl() end)
local trigL=lb(fpC,{Position=UDim2.fromOffset(4,27),Size=UDim2.fromOffset(FP_W-8,10),Text="Trigger: "..Cfg.triggerChance.."%",TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local slBg=Instance.new("Frame"); slBg.Size=UDim2.fromOffset(FP_W-8,5); slBg.Position=UDim2.fromOffset(4,40); slBg.BackgroundColor3=T.surf; slBg.BorderSizePixel=0; slBg.Parent=fpC; co(slBg,3)
local slFill=Instance.new("Frame"); slFill.Size=UDim2.new(sliderValue,0,1,0); slFill.BackgroundColor3=T.a1; slFill.BorderSizePixel=0; slFill.Parent=slBg; co(slFill,3)
local slK=Instance.new("Frame"); slK.Size=UDim2.fromOffset(9,9); slK.AnchorPoint=Vector2.new(0.5,0.5); slK.Position=UDim2.new(sliderValue,0,0.5,0); slK.BackgroundColor3=T.white; slK.BorderSizePixel=0; slK.Parent=slBg; co(slK,5)
local slOn=false
local function setTr(pct) pct=math.clamp(pct,0,1); sliderValue=pct; Cfg.triggerChance=math.floor(pct*100); slFill.Size=UDim2.new(pct,0,1,0); slK.Position=UDim2.new(pct,0,0.5,0); trigL.Text="Trigger: "..math.floor(pct*100).."%" end
slBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slOn=true;setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if slOn then slOn=false;save() end end end)
UIS.InputChanged:Connect(function(i) if not slOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
lb(fpC,{Position=UDim2.fromOffset(4,49),Size=UDim2.fromOffset(FP_W-8,8),Text="91% = best  |  zero grav active",TextSize=6,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local divFP=Instance.new("Frame",fpC); divFP.Size=UDim2.new(1,-8,0,1); divFP.Position=UDim2.fromOffset(4,59); divFP.BackgroundColor3=T.str; divFP.BackgroundTransparency=0.72; divFP.BorderSizePixel=0
local potRow=Instance.new("Frame"); potRow.Size=UDim2.fromOffset(FP_W-8,19); potRow.Position=UDim2.fromOffset(4,62)
potRow.BackgroundColor3=T.surf; potRow.BackgroundTransparency=0.28; potRow.BorderSizePixel=0; potRow.Parent=fpC; co(potRow,5)
local potRS=ms(potRow,1,T.str,0.55)
local potL=lb(potRow,{Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-38,1,0),Text="Giant Potion",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local potTrack=Instance.new("Frame"); potTrack.Size=UDim2.fromOffset(22,10); potTrack.Position=UDim2.new(1,-25,0.5,-5); potTrack.BackgroundColor3=T.surf2; potTrack.BorderSizePixel=0; potTrack.Parent=potRow; co(potTrack,10)
local potK=Instance.new("Frame"); potK.Size=UDim2.fromOffset(7,7); potK.Position=UDim2.new(0,2,0.5,-3.5); potK.BackgroundColor3=T.a2; potK.BorderSizePixel=0; potK.Parent=potTrack; co(potK,7)
local potB=Instance.new("TextButton"); potB.Size=UDim2.new(1,0,1,0); potB.BackgroundTransparency=1; potB.Text=""; potB.Parent=potRow
local function updPot()
    TweenService:Create(potRow,TweenInfo.new(0.12),{BackgroundColor3=potionOn and Color3.fromRGB(12,12,20) or T.surf,BackgroundTransparency=potionOn and 0.15 or 0.28}):Play()
    TweenService:Create(potRS,TweenInfo.new(0.12),{Color=potionOn and T.a1 or T.str,Transparency=potionOn and 0.2 or 0.55}):Play()
    TweenService:Create(potTrack,TweenInfo.new(0.12),{BackgroundColor3=potionOn and T.a1 or T.surf2}):Play()
    TweenService:Create(potK,TweenInfo.new(0.12),{Position=potionOn and UDim2.new(1,-9,0.5,-3.5) or UDim2.new(0,2,0.5,-3.5),BackgroundColor3=potionOn and T.white or T.a2}):Play()
    potL.TextColor3=potionOn and T.white or T.dim
end
updPot(); potB.MouseButton1Click:Connect(function() potionOn=not potionOn; Cfg.potionOn=potionOn; save(); updPot() end)
local rstBtn=btn(fpC,"Instant Reset",UDim2.fromOffset(FP_W-8,16),UDim2.fromOffset(4,84),Color3.fromRGB(40,6,6))
rstBtn.TextSize=7; rstBtn.TextColor3=T.red
do local s=rstBtn:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.red;s.Transparency=0.3 end end
rstBtn.MouseButton1Click:Connect(function() task.spawn(doReset) end)
lb(fpC,{Position=UDim2.fromOffset(4,102),Size=UDim2.fromOffset(FP_W-8,8),Text="if cam breaks press reset 2×",TextSize=6,Font=Enum.Font.Gotham,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Center})

-- PANEL C: Admin
local RCMDS={{cmd="ragdoll",icon="🤸"},{cmd="balloon",icon="🎈"},{cmd="tiny",icon="🐜"},{cmd="jail",icon="🔒"},{cmd="rocket",icon="🚀"}}
local IW2=15; local IH2=16; local IG2=2; local ITOT=#RCMDS*(IW2+IG2)-IG2; local CW2=AP_W-10; local CSTART=CW2-ITOT-2
local AP,_,apMin=mkP(0,AP_Y_DEF,AP_W,22,"Admin Panel",T.a2,"pos_AP")
local pScroll=Instance.new("ScrollingFrame"); pScroll.Size=UDim2.fromOffset(AP_W-6,0); pScroll.Position=UDim2.fromOffset(3,20)
pScroll.BackgroundColor3=T.bg; pScroll.BackgroundTransparency=0.65; pScroll.BorderSizePixel=0
pScroll.ScrollBarThickness=2; pScroll.ScrollBarImageColor3=T.a1; pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; pScroll.CanvasSize=UDim2.new(0,0,0,0); pScroll.Parent=AP; co(pScroll,3)
local pLayout=Instance.new("UIListLayout"); pLayout.Padding=UDim.new(0,2); pLayout.SortOrder=Enum.SortOrder.Name; pLayout.Parent=pScroll
Instance.new("UIPadding",pScroll).PaddingTop=UDim.new(0,2)
local apFolded=false
local function resAP()
    if apFolded then return end
    local ch=math.min(pLayout.AbsoluteContentSize.Y+4,110)
    pScroll.Size=UDim2.fromOffset(AP_W-6,ch); AP.Size=UDim2.fromOffset(AP_W,20+ch+3)
end
pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resAP)
apMin.MouseButton1Click:Connect(function()
    apFolded=not apFolded; apMin.Text=apFolded and "+" or "─"; pScroll.Visible=not apFolded
    if apFolded then TweenService:Create(AP,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,22)}):Play()
    else local ch=math.min(pLayout.AbsoluteContentSize.Y+4,110); TweenService:Create(AP,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,20+ch+3)}):Play() end
end)
local pCards={}
local function refreshPlayers()
    for _,c in pairs(pCards) do pcall(function() c:Destroy() end) end; pCards={}; cmdBtnRefs={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame"); card.Name=p.Name; card.Size=UDim2.new(1,-4,0,28)
        card.BackgroundColor3=T.surf; card.BackgroundTransparency=0.26; card.BorderSizePixel=0; card.Parent=pScroll; co(card,4)
        local cs=ms(card,1,T.str,0.55)
        local cz=Instance.new("TextButton"); cz.Size=UDim2.fromOffset(CSTART,28); cz.BackgroundTransparency=1; cz.Text=""; cz.AutoButtonColor=false; cz.Parent=card
        local ava=Instance.new("ImageLabel"); ava.Size=UDim2.fromOffset(16,16); ava.Position=UDim2.new(0,3,0.5,-8); ava.BackgroundColor3=T.surf2; ava.BorderSizePixel=0; ava.Parent=card; co(ava,8)
        task.spawn(function() local ok,img=pcall(Players.GetUserThumbnailAsync,Players,p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48); if ok then ava.Image=img end end)
        lb(card,{Position=UDim2.new(0,21,0,2),Size=UDim2.fromOffset(CSTART-24,13),Text=p.DisplayName,TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.a1,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        lb(card,{Position=UDim2.new(0,21,0,14),Size=UDim2.fromOffset(CSTART-24,10),Text="@"..p.Name,TextSize=6,Font=Enum.Font.Gotham,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        cmdBtnRefs[p.UserId]={}
        for i,def in ipairs(RCMDS) do
            local bx=CSTART+2+(i-1)*(IW2+IG2)
            local ib=Instance.new("TextButton"); ib.Size=UDim2.fromOffset(IW2,IH2); ib.Position=UDim2.new(0,bx,0.5,-IH2/2)
            ib.BackgroundColor3=T.surf2; ib.BackgroundTransparency=0.22; ib.Text=def.icon; ib.TextSize=10; ib.TextColor3=T.a1
            ib.Font=Enum.Font.GothamBold; ib.BorderSizePixel=0; ib.AutoButtonColor=false; ib.Parent=card; co(ib,3); ms(ib,1,T.str,0.52)
            cmdBtnRefs[p.UserId][def.cmd]=ib
            local pd=p; local dc=def.cmd
            ib.MouseButton1Click:Connect(function() fireCmd(pd,dc) end)
        end
        local pd=p
        cz.MouseButton1Click:Connect(function()
            for _,c2 in pairs(pCards) do local s2=c2:FindFirstChildOfClass("UIStroke"); if s2 then s2.Color=T.str;s2.Transparency=0.55 end; c2.BackgroundTransparency=0.26 end
            cs.Color=T.a1; cs.Transparency=0; card.BackgroundTransparency=0; fireClick(pd)
        end)
        pCards[p.UserId]=card
    end
    task.defer(resAP)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshPlayers() end)
task.delay(2,refreshPlayers)

-- PANEL D: Base Protector
local BP,_,bpMin=mkP(0,0,BP_W,BP_H,"Base Protector",T.a1,"pos_BP")
local bpC=mkF(BP,19,BP_CH,bpMin); local pyy=3
local function bpRow(label,col) local pb,set=pillR(bpC,label,pyy,col); pyy=pyy+21; return pb,set end
local asB,asSet=bpRow("ANTI STEAL",T.a1); asB.MouseButton1Click:Connect(function() antiSteal=not antiSteal; asSet(antiSteal) end)
local akB,akSet=bpRow("AUTO KICK",T.red); akB.MouseButton1Click:Connect(function() autoKick=not autoKick; akSet(autoKick) end)
local aiB,aiSet=bpRow("ANTI INTRUDER",T.a2); aiB.MouseButton1Click:Connect(function() antiIntruder=not antiIntruder; aiSet(antiIntruder) end)
local atB,atSet=bpRow("ANTI TP",T.a2); atB.MouseButton1Click:Connect(function() antiTp=not antiTp; atSet(antiTp) end)

-- PANEL E: Speed Boost
local SP,_,spMin=mkP(4,LP_H+48+4,SP_W,SP_H,"Speed Boost",T.a1,"pos_SP")
local spC=mkF(SP,19,SP_CH,spMin); local sy=3
local ssB,ssSet=pillR(spC,"Steal Speed",sy,T.grn); sy=sy+21
ssB.MouseButton1Click:Connect(function()
    stealSpdOn=not stealSpdOn; isStealing=stealSpdOn; speedEnabled=stealSpdOn
    ssSet(stealSpdOn); Cfg.stealSpdOn=stealSpdOn; save()
end)
if stealSpdOn then ssSet(true); isStealing=true; speedEnabled=true end
numRow(spC,"Speed",STEAL_SPD_VAL,10,60,sy,SP_W,function(v) STEAL_SPD_VAL=v; stealingSpeed=v; Cfg.stealSpdVal=v; save() end)

-- Reset Panels popup
rsPnlBtn.MouseButton1Click:Connect(function()
    local popup=Instance.new("Frame",SG); popup.Size=UDim2.fromOffset(188,62); popup.Position=UDim2.new(0.5,-94,0.38,-31)
    popup.BackgroundColor3=T.panel; popup.BackgroundTransparency=0.08; popup.BorderSizePixel=0; co(popup,10); ms(popup,1.5,T.a1,0.18)
    lb(popup,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,4),Text="Reset panels to defaults?",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=T.a1})
    local yesB=btn(popup,"Yes",UDim2.fromOffset(76,22),UDim2.fromOffset(10,36),Color3.fromRGB(14,40,14)); yesB.TextColor3=T.grn
    local noB=btn(popup,"No",UDim2.fromOffset(76,22),UDim2.fromOffset(102,36),Color3.fromRGB(40,8,8)); noB.TextColor3=T.red
    noB.MouseButton1Click:Connect(function() popup:Destroy() end)
    yesB.MouseButton1Click:Connect(function()
        local dfp={ox=math.floor(vp.X-FP_W-4),oy=5}; local dap={ox=math.floor(vp.X-AP_W-4),oy=AP_Y_DEF}
        local dbp={ox=math.floor(vp.X*0.5-BP_W*0.5),oy=math.floor(vp.Y*0.5-BP_H*0.5)}; local dsp={ox=4,oy=LP_H+48+4}
        local defs={pos_LP={ox=4,oy=48},pos_FP=dfp,pos_AP=dap,pos_BP=dbp,pos_SP=dsp}
        for k,v in pairs(defs) do Cfg[k]=v end; save()
        LP.Position=UDim2.fromOffset(4,48); FP.Position=UDim2.fromOffset(dfp.ox,dfp.oy)
        AP.Position=UDim2.fromOffset(dap.ox,dap.oy); BP.Position=UDim2.fromOffset(dbp.ox,dbp.oy)
        SP.Position=UDim2.fromOffset(dsp.ox,dsp.oy); popup:Destroy()
    end)
end)

print("Aethon Suite | r9qbx")
