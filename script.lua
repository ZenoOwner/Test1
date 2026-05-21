-- ══════════════════════════════════════════════════════════
--  AETHON SUITE  |  by r9qbx
--  EDIT THESE:
local DISCORD_LINK    = "discord.gg/cfAsNJra"   -- shown in Flash TP panel
local DISCORD_WEBHOOK = ""                        -- paste webhook URL for steal ping
local AUTO_KICK       = true                      -- kick self after steal fires
local GRAB_RADIUS     = 45                        -- auto grab scan radius (studs)
-- ══════════════════════════════════════════════════════════

local Players=game:GetService("Players"); local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService"); local RS=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService"); local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui"); local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local lp=Players.LocalPlayer; local cam=workspace.CurrentCamera

local CFG="AethonSuite.json"
local Cfg={triggerChance=91,flashOn=false,grabOn=true,potionOn=false,stealSpdOn=false,stealSpdVal=30,
    pos_LP={ox=4,oy=48},pos_FP={ox=0,oy=5},pos_AP={ox=0,oy=0},pos_BP={ox=0,oy=0},pos_SP={ox=4,oy=0}}
pcall(function()
    if not readfile then return end
    local raw=readfile(CFG); if not raw or raw=="" then return end
    local ok,t=pcall(HttpService.JSONDecode,HttpService,raw)
    if ok and type(t)=="table" then for k,v in pairs(t) do Cfg[k]=v end end
end)
local function save() pcall(function() if writefile then writefile(CFG,HttpService:JSONEncode(Cfg)) end end) end

for _,v in ipairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:sub(1,2)=="AS" or v.Name:sub(1,3)=="Ph_" or v.Name:sub(1,2)=="PS") then v:Destroy() end
end
local SG=Instance.new("ScreenGui"); SG.Name="AS_"..tostring(math.random(1e4,9e4))
SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Global; SG.IgnoreGuiInset=true; SG.Parent=CoreGui

-- Color system
local C={
    bg=Color3.fromRGB(6,6,14),panel=Color3.fromRGB(10,10,20),
    surf=Color3.fromRGB(16,16,30),surf2=Color3.fromRGB(24,24,44),
    bord=Color3.fromRGB(44,44,72),text=Color3.fromRGB(228,228,248),
    dim=Color3.fromRGB(105,105,135),white=Color3.new(1,1,1),
    red=Color3.fromRGB(255,55,75),grn=Color3.fromRGB(55,215,110),
    blu=Color3.fromRGB(65,135,255),acc=Color3.fromRGB(135,85,255),
    org=Color3.fromRGB(255,165,45),yel=Color3.fromRGB(255,220,35),
}

local function co(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8) end
local function lb(par,t)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold
    l.TextColor3=C.text; l.BorderSizePixel=0; for k,v in pairs(t) do l[k]=v end; l.Parent=par; return l
end
local function mkBtn(par,text,sz,pos,bg,tc,r)
    local b=Instance.new("TextButton"); b.Size=sz; b.Position=pos
    b.BackgroundColor3=bg or C.surf; b.BackgroundTransparency=0.15
    b.Text=text; b.TextColor3=tc or C.text; b.Font=Enum.Font.GothamBold
    b.TextSize=9; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=par
    co(b,r or 7)
    local s=Instance.new("UIStroke",b); s.Thickness=1; s.Color=C.bord; s.Transparency=0.35; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return b,s
end
local function rotS(f,col)
    local s=Instance.new("UIStroke",f); s.Thickness=1.2; s.Color=col; s.Transparency=0.2; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local g=Instance.new("UIGradient",s)
    g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(0.3,Color3.new(0,0,0)),ColorSequenceKeypoint.new(0.6,col),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}
    task.spawn(function() while s and s.Parent do g.Rotation=(g.Rotation+1.2)%360; task.wait(0.02) end end)
end
local function mkSep(par,y,col)
    local s=Instance.new("Frame",par); s.Size=UDim2.new(1,-16,0,1); s.Position=UDim2.fromOffset(8,y)
    s.BackgroundColor3=col or C.bord; s.BackgroundTransparency=0.5; s.BorderSizePixel=0; return s
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

-- NEW PANEL BUILDER
local function mkP(defX,defY,w,h,title,icon,ac,posKey)
    local px=(posKey and Cfg[posKey] and Cfg[posKey].ox) or defX
    local py=(posKey and Cfg[posKey] and Cfg[posKey].oy) or defY
    local f=Instance.new("Frame"); f.Size=UDim2.fromOffset(w,h); f.Position=UDim2.fromOffset(px,py)
    f.BackgroundColor3=C.panel; f.BackgroundTransparency=0.06; f.BorderSizePixel=0
    f.ClipsDescendants=true; f.Parent=SG; co(f,10); rotS(f,ac)
    -- Colored header strip
    local hdr=Instance.new("Frame"); hdr.Size=UDim2.new(1,0,0,26); hdr.BackgroundColor3=C.surf
    hdr.BackgroundTransparency=0.08; hdr.BorderSizePixel=0; hdr.Parent=f; co(hdr,10)
    local hflat=Instance.new("Frame",hdr); hflat.Size=UDim2.new(1,0,0,10); hflat.Position=UDim2.new(0,0,1,-10)
    hflat.BackgroundColor3=C.surf; hflat.BackgroundTransparency=0.08; hflat.BorderSizePixel=0
    -- Accent tint in header
    local tint=Instance.new("Frame",hdr); tint.Size=UDim2.new(1,0,1,0); tint.BackgroundColor3=ac
    tint.BackgroundTransparency=0.82; tint.BorderSizePixel=0; tint.ZIndex=0
    -- Bottom separator line
    mkSep(f,26,ac)
    -- Title with icon
    if title then
        local tl=lb(hdr,{Position=UDim2.new(0,9,0,0),Size=UDim2.new(1,-28,1,0),
            Text=icon.." "..title,TextSize=8,Font=Enum.Font.GothamBlack,
            TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text}); tl.ZIndex=2
    end
    local mb,_=mkBtn(hdr,"─",UDim2.fromOffset(14,12),UDim2.new(1,-17,0.5,-6),C.surf2,C.dim,4)
    mb.TextSize=7; mb.BackgroundTransparency=0.5; mb.ZIndex=2
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

-- NEW PILL TOGGLE BUILDER
local function mkPill(parent,label,yPos,onCol)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-8,0,20); row.Position=UDim2.new(0,4,0,yPos)
    row.BackgroundColor3=C.surf; row.BackgroundTransparency=0.2; row.BorderSizePixel=0; row.Parent=parent; co(row,6)
    local rs=Instance.new("UIStroke",row); rs.Thickness=1; rs.Color=C.bord; rs.Transparency=0.5; rs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local rl=lb(row,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-36,1,0),Text=label,TextSize=7,Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local track=Instance.new("Frame"); track.Size=UDim2.fromOffset(24,12); track.Position=UDim2.new(1,-27,0.5,-6)
    track.BackgroundColor3=C.surf2; track.BorderSizePixel=0; track.Parent=row; co(track,12)
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(8,8); knob.Position=UDim2.new(0,2,0.5,-4)
    knob.BackgroundColor3=C.dim; knob.BorderSizePixel=0; knob.Parent=track; co(knob,8)
    local pb=Instance.new("TextButton"); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1; pb.Text=""; pb.Parent=row
    local col=onCol or C.acc
    local function set(v)
        TweenService:Create(track,TweenInfo.new(0.12),{BackgroundColor3=v and col or C.surf2}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=v and C.white or C.dim}):Play()
        TweenService:Create(rs,TweenInfo.new(0.12),{Color=v and col or C.bord,Transparency=v and 0.15 or 0.5}):Play()
        rl.TextColor3=v and C.text or C.dim
    end
    return pb,set
end
local function numRow(parent,label,val,mn,mx,yPos,w,onChange)
    local IW=w-8; local row=Instance.new("Frame"); row.Size=UDim2.fromOffset(IW,19); row.Position=UDim2.fromOffset(4,yPos)
    row.BackgroundColor3=C.surf; row.BackgroundTransparency=0.2; row.BorderSizePixel=0; row.Parent=parent; co(row,5)
    local s2=Instance.new("UIStroke",row); s2.Thickness=1; s2.Color=C.bord; s2.Transparency=0.5; s2.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(row,{Position=UDim2.new(0,5,0,0),Size=UDim2.new(0.5,0,1,0),Text=label,TextSize=7,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local mB=Instance.new("TextButton",row); mB.Size=UDim2.fromOffset(13,13); mB.Position=UDim2.new(0.5,1,0.5,-6.5); mB.BackgroundColor3=C.surf2; mB.Text="-"; mB.Font=Enum.Font.GothamBold; mB.TextSize=9; mB.TextColor3=C.acc; mB.BorderSizePixel=0; mB.AutoButtonColor=false; co(mB,3)
    local vB=Instance.new("TextBox",row); vB.Size=UDim2.fromOffset(24,13); vB.Position=UDim2.new(0.5,16,0.5,-6.5); vB.BackgroundColor3=C.surf2; vB.BorderSizePixel=0; vB.Text=tostring(val); vB.Font=Enum.Font.GothamBold; vB.TextSize=8; vB.TextColor3=C.acc; vB.ClearTextOnFocus=false; co(vB,3)
    local pB=Instance.new("TextButton",row); pB.Size=UDim2.fromOffset(13,13); pB.Position=UDim2.new(0.5,42,0.5,-6.5); pB.BackgroundColor3=C.surf2; pB.Text="+"; pB.Font=Enum.Font.GothamBold; pB.TextSize=9; pB.TextColor3=C.acc; pB.BorderSizePixel=0; pB.AutoButtonColor=false; co(pB,3)
    local cur=val
    local function setV(v) cur=math.clamp(math.floor(v),mn,mx); vB.Text=tostring(cur); if onChange then onChange(cur) end end
    mB.MouseButton1Click:Connect(function() setV(cur-1) end)
    pB.MouseButton1Click:Connect(function() setV(cur+1) end)
    vB.FocusLost:Connect(function() local n=tonumber(vB.Text); if n then setV(n) else vB.Text=tostring(cur) end end)
end

task.wait(0.1); local vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end

local LP_W=122; local LP_CH=96; local LP_H=27+LP_CH+8
local FP_W=142; local FP_CH=116; local FP_H=27+FP_CH+8
local AP_W=178; local AP_Y_DEF=5+FP_H+4
local BP_W=126; local BP_CH=4*22+5; local BP_H=27+BP_CH+8
local SP_W=122; local SP_CH=48; local SP_H=27+SP_CH+8

if not Cfg.pos_FP or Cfg.pos_FP.ox==0 then Cfg.pos_FP={ox=math.floor(vp.X-FP_W-4),oy=5} end
if not Cfg.pos_AP or Cfg.pos_AP.ox==0 then Cfg.pos_AP={ox=math.floor(vp.X-AP_W-4),oy=AP_Y_DEF} end
if not Cfg.pos_BP or Cfg.pos_BP.ox==0 then Cfg.pos_BP={ox=math.floor(vp.X*0.5-BP_W*0.5),oy=math.floor(vp.Y*0.5-BP_H*0.5)} end
if not Cfg.pos_SP or Cfg.pos_SP.oy==0 then Cfg.pos_SP={ox=4,oy=LP_H+48+4} end

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

-- FPS + Ping bar
local fpsF=Instance.new("Frame",SG); fpsF.Size=UDim2.fromOffset(142,16); fpsF.Position=UDim2.new(0.5,-71,0,4)
fpsF.BackgroundColor3=C.panel; fpsF.BackgroundTransparency=0.1; fpsF.BorderSizePixel=0; co(fpsF,6)
local fpsS=Instance.new("UIStroke",fpsF); fpsS.Thickness=1; fpsS.Color=C.bord; fpsS.Transparency=0.3; fpsS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local fpsLb=lb(fpsF,{Size=UDim2.new(1,0,1,0),Text="⚡ FPS --   📡 -- ms",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=C.acc})
local lastDt=1/60
task.spawn(function() while task.wait(0.7) do
    if not fpsLb.Parent then break end
    local fps=math.min(999,math.floor(1/math.max(lastDt,0.001))); local ping=0
    pcall(function() ping=math.floor(lp:GetNetworkPing()*1000) end)
    fpsLb.Text="⚡ FPS "..fps.."   📡 "..ping.."ms"
    fpsLb.TextColor3=fps<40 and C.red or fps<55 and C.yel or C.grn
end end)

-- Reset Panels + floating buttons
local rsPnlBtn,_=mkBtn(SG,"◈ Reset Panels",UDim2.fromOffset(92,13),UDim2.new(0.5,-46,0,48),C.surf,C.dim,4)
rsPnlBtn.TextSize=7

local ragF=Instance.new("Frame",SG); ragF.Size=UDim2.fromOffset(86,13); ragF.Position=UDim2.new(0.5,-90,0,64)
ragF.BackgroundColor3=Color3.fromRGB(14,8,28); ragF.BackgroundTransparency=0.05; ragF.BorderSizePixel=0; co(ragF,4)
local ragS=Instance.new("UIStroke",ragF); ragS.Thickness=1; ragS.Color=C.acc; ragS.Transparency=0.3; ragS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local ragBtn=Instance.new("TextButton",ragF); ragBtn.Size=UDim2.new(1,0,1,0); ragBtn.BackgroundTransparency=1
ragBtn.Text="🤸 Ragdoll Self"; ragBtn.Font=Enum.Font.GothamBold; ragBtn.TextSize=7; ragBtn.TextColor3=Color3.fromRGB(185,150,255); ragBtn.BorderSizePixel=0; ragBtn.AutoButtonColor=false

local prF=Instance.new("Frame",SG); prF.Size=UDim2.fromOffset(86,13); prF.Position=UDim2.new(0.5,4,0,64)
prF.BackgroundColor3=Color3.fromRGB(14,8,28); prF.BackgroundTransparency=0.05; prF.BorderSizePixel=0; co(prF,4)
local prS=Instance.new("UIStroke",prF); prS.Thickness=1; prS.Color=Color3.fromRGB(90,55,195); prS.Transparency=0.3; prS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local prBtn=Instance.new("TextButton",prF); prBtn.Size=UDim2.new(1,0,1,0); prBtn.BackgroundTransparency=1
prBtn.Text="Pot + Ragdoll"; prBtn.Font=Enum.Font.GothamBold; prBtn.TextSize=7; prBtn.TextColor3=Color3.fromRGB(158,118,235); prBtn.BorderSizePixel=0; prBtn.AutoButtonColor=false

-- Timer ESP
local timerESPs={}; local myPlotRef=nil; local baseAlerted=false; local stealHitbox=nil
local ECOL_R=C.red; local ECOL_Y=C.yel; local ECOL_G=C.grn
local function showAlert()
    pcall(function() local s=Instance.new("Sound"); s.SoundId="rbxassetid://9118633772"; s.Volume=0.85; s.Parent=workspace; s:Play(); Debris:AddItem(s,5) end)
    local ag=Instance.new("ScreenGui",CoreGui); ag.Name="AethAlert"; ag.ResetOnSpawn=false; ag.IgnoreGuiInset=true
    local af=Instance.new("Frame",ag); af.Size=UDim2.fromOffset(186,26); af.Position=UDim2.new(0.5,-93,0,-36)
    af.BackgroundColor3=C.panel; af.BackgroundTransparency=0.05; af.BorderSizePixel=0; co(af,7)
    local as=Instance.new("UIStroke",af); as.Thickness=1.5; as.Color=C.red; as.Transparency=0.08; as.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(af,{Size=UDim2.new(1,0,1,0),Text="⚠  BASE EXPIRES IN 5s!",TextSize=9,Font=Enum.Font.GothamBlack,TextColor3=C.red})
    TweenService:Create(af,TweenInfo.new(0.32,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-93,0,7)}):Play()
    task.delay(4,function() TweenService:Create(af,TweenInfo.new(0.22),{Position=UDim2.new(0.5,-93,0,-36)}):Play(); task.wait(0.25); ag:Destroy() end)
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
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(56,16); bb.StudsOffset=Vector3.new(0,7,0); bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
                local bgT=Instance.new("Frame",bb); bgT.Size=UDim2.new(1,0,1,0); bgT.BackgroundColor3=C.bg; bgT.BackgroundTransparency=0.2; bgT.BorderSizePixel=0; co(bgT,5)
                local stk=Instance.new("UIStroke",bgT); stk.Color=ECOL_Y; stk.Thickness=0.9; stk.Transparency=0.25; stk.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
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
local ESPTAG="AS_"..tostring(math.random(1e4,9e4))
local function mkESP(plr)
    if plr==lp then return end
    local char=plr.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end
    local box=Instance.new("BoxHandleAdornment",char); box.Name=ESPTAG; box.Adornee=hrp; box.Size=Vector3.new(4,6,2); box.Color3=C.acc; box.Transparency=0.55; box.ZIndex=10; box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char); bb.Name=ESPTAG.."N"; bb.Adornee=char:FindFirstChild("Head") or hrp; bb.Size=UDim2.fromOffset(130,24); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true
    local bgE=Instance.new("Frame",bb); bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=C.bg; bgE.BackgroundTransparency=0.22; bgE.BorderSizePixel=0; co(bgE,5)
    local se=Instance.new("UIStroke",bgE); se.Thickness=1; se.Color=C.acc; se.Transparency=0.28; se.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(bgE,{Size=UDim2.new(1,0,0.58,0),BackgroundTransparency=1,Text=plr.DisplayName,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.text,TextStrokeTransparency=0.45,TextStrokeColor3=Color3.new(0,0,0)})
    lb(bgE,{Size=UDim2.new(1,0,0.42,0),Position=UDim2.new(0,0,0.58,0),BackgroundTransparency=1,Text="@"..plr.Name,Font=Enum.Font.Gotham,TextSize=7,TextColor3=C.dim})
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
    local stroke=Instance.new("UIStroke",bg); stroke.Color=C.red; stroke.Thickness=1.5; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(bg,{Size=UDim2.fromOffset(14,28),Position=UDim2.fromOffset(5,0),BackgroundTransparency=1,Text="⚠",Font=Enum.Font.GothamBlack,TextSize=10,TextColor3=Color3.fromRGB(255,80,80)})
    lb(bg,{Size=UDim2.new(1,-22,0,15),Position=UDim2.fromOffset(20,1),BackgroundTransparency=1,Text="SUBSPACE MINE",Font=Enum.Font.GothamBlack,TextSize=8,TextColor3=Color3.fromRGB(255,90,90),TextXAlignment=Enum.TextXAlignment.Left,TextStrokeTransparency=0.4,TextStrokeColor3=Color3.new(0,0,0)})
    local distL=lb(bg,{Size=UDim2.new(1,-22,0,11),Position=UDim2.fromOffset(20,14),BackgroundTransparency=1,Text="-- studs",Font=Enum.Font.Gotham,TextSize=7,TextColor3=Color3.fromRGB(180,80,80),TextXAlignment=Enum.TextXAlignment.Left})
    task.spawn(function()
        while bb.Parent do
            TweenService:Create(stroke,TweenInfo.new(0.55,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.72}):Play(); task.wait(0.55)
            if not bb.Parent then break end
            TweenService:Create(stroke,TweenInfo.new(0.55,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0}):Play(); task.wait(0.55)
        end
    end)
    local dc=RunService.Heartbeat:Connect(function()
        if not bb.Parent or not part.Parent then return end
        local char=lp.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local d=math.round((root.Position-part.Position).Magnitude)
            distL.Text=d.." studs away"; distL.TextColor3=d<15 and C.red or d<30 and Color3.fromRGB(220,100,80) or Color3.fromRGB(160,80,80)
        end
    end)
    mineESPs[child]={bb=bb,dc=dc}
    child.AncestryChanged:Connect(function() if not child.Parent then pcall(function() bb:Destroy() end); pcall(function() dc:Disconnect() end); mineESPs[child]=nil end end)
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
    local bgB=Instance.new("Frame",bb); bgB.Size=UDim2.new(1,0,1,0); bgB.BackgroundColor3=Color3.fromRGB(6,4,14); bgB.BackgroundTransparency=0.1; bgB.BorderSizePixel=0; co(bgB,5)
    local sb=Instance.new("UIStroke",bgB); sb.Thickness=1; sb.Color=C.acc; sb.Transparency=0.18; sb.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
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

-- Base Protector
local CARPET={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true,["Cupid's Wings"]=true}
local antiSteal=false; local autoKick=false; local antiIntruder=false; local antiTp=false
local lastPunish={}; local carpetSpam={}; local plrPos={}; local tpCD={}; local myStealPrompts={}
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
local function isPromptOnMyBase(prompt)
    if not myPlotRef then return false end
    local a=prompt.Parent
    while a and a~=workspace do if a==myPlotRef then return true end; a=a.Parent end
    return false
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
        if antiSteal and (prompt.ActionText or ""):lower():find("steal") and isPromptOnMyBase(prompt) then
            local thief=findThief(); if thief then punish(thief) end; chkHitbox()
        end
        return old(prompt,...)
    end))
end)
task.spawn(function()
    pcall(function()
        local net=RS:WaitForChild("Packages"):WaitForChild("Net",8); if not net then return end
        local grabRE=net:FindFirstChild("RE/StealService/Grab"); local successRE=net:FindFirstChild("RE/StealService/StealingSuccess")
        if grabRE then grabRE.OnClientEvent:Connect(function()
            if not antiSteal or not ADM_REMOTE or not myPlotRef then return end
            local thief=findThief(); if thief then punish(thief) end
        end) end
        if successRE then successRE.OnClientEvent:Connect(function()
            if not antiSteal or not ADM_REMOTE or not myPlotRef then return end
            local thief=findThief(); if thief then punish(thief) end
        end) end
    end)
end)

-- Potion
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

-- Carpet + reset
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
    local equipped=equipCarpetTool(); if equipped then task.wait(0.1) end
    h.CFrame=CFrame.new(0,15000,0)
end

-- Flash equip
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

-- Discord + auto kick on steal
local function onStealFired()
    if not AUTO_KICK then return end
    task.spawn(function()
        task.wait(0.45)
        if DISCORD_WEBHOOK ~= "" then
            pcall(function()
                local req=request or (syn and syn.request) or http_request
                if req then req({Url=DISCORD_WEBHOOK,Method="POST",Headers={["Content-Type"]="application/json"},Body=HttpService:JSONEncode({content="GG SON 🎯 | Aethon Suite"})}) end
            end)
        end
        lp:Kick("GG SON 🎯")
    end)
end

-- =====================================================================
-- AUTO ALLIGN — base detection
-- Base 1 (specific coords): TP to podium + align cam
-- Other bases: cam-only align (no TP)
-- =====================================================================
local BASE1_X_MIN,BASE1_X_MAX=-345,-285
local BASE1_Z_MIN,BASE1_Z_MAX=75,155
local function isInBase1()
    local char=lp.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    local p=hrp.Position
    return p.X>=BASE1_X_MIN and p.X<=BASE1_X_MAX and p.Z>=BASE1_Z_MIN and p.Z<=BASE1_Z_MAX
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
    local myPos=hrp.Position
    local startIdx,endIdx
    if myPos.Y<5 then startIdx,endIdx=1,10 elseif myPos.Y<22 then startIdx,endIdx=11,18 else startIdx,endIdx=19,27 end
    local nearest,minD=nil,math.huge
    for i=startIdx,endIdx do local pt=PodiumPoints[i]; if pt then local d=(myPos-pt.pos).Magnitude; if d<minD then minD=d;nearest=pt end end end
    return nearest
end
local function doCamOnlyAlign()
    -- Other bases: just tilt camera slightly downward toward podiums, don't TP
    local pos=cam.CFrame.Position; local look=cam.CFrame.LookVector
    local flat=Vector3.new(look.X,0,look.Z); if flat.Magnitude<0.01 then flat=Vector3.new(0,0,-1) else flat=flat.Unit end
    local angled=(flat+Vector3.new(0,-0.18,0)).Unit
    cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=CFrame.lookAt(pos,pos+angled)
    task.wait(); cam.CameraType=Enum.CameraType.Custom; equipFlash()
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
        task.wait(); cam.CameraType=Enum.CameraType.Custom  -- RESTORED: cam moveable
        equipFlash()
    else
        doCamOnlyAlign()
    end
end

-- =====================================================================
-- FLASH TP — EXT Triggered callback fires instantly (bypasses 1.3s timer)
-- Fallback to Vander if EXT unavailable
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
            -- EXT Triggered fires immediately (bypasses hold timer = more accurate + faster steal)
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
            task.spawn(function() activatePotion() end)
            task.spawn(onStealFired)
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function()
        if not fired then fired=true; activePrompts[prompt]=nil; conn:Disconnect() end
    end)
end)

-- =====================================================================
-- BUILT-IN AUTO GRAB (radius 45, toggleable, EXT + Vander)
-- Replaces Irish Hub — hidden, no GUI
-- =====================================================================
local grabEnabled=Cfg.grabOn
local grabInProgress=false
local function findNearestGrab()
    local char=lp.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local myPos=root.Position; local nearest,nd=nil,GRAB_RADIUS
    for _,plot in ipairs(plots:GetChildren()) do
        if myPlotRef and plot==myPlotRef then continue end
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local at=obj.ActionText; if at~="Steal" and at~="Grab" and not at:lower():find("steal") then continue end
                local parent=obj.Parent; local worldPos
                if parent:IsA("BasePart") then worldPos=parent.Position
                elseif parent:IsA("Attachment") then worldPos=parent.WorldPosition
                else local p=parent:FindFirstChildWhichIsA("BasePart",true); if p then worldPos=p.Position end end
                if worldPos then local d=(myPos-worldPos).Magnitude; if d<nd then nearest=obj;nd=d end end
            end
        end
    end
    return nearest
end
task.spawn(function()
    while true do
        task.wait(0.28+math.random()*0.06)
        if not grabEnabled or grabInProgress then continue end
        local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local nearest=findNearestGrab(); if not nearest then continue end
        grabInProgress=true
        task.spawn(function()
            local fired=false
            pcall(function()
                local hConns=getconnections(nearest.PromptButtonHoldBegan)
                if hConns and #hConns>0 then
                    for _,c in ipairs(hConns) do if c.Function then task.spawn(c.Function) end end
                    task.wait(0.1)
                    local tConns=getconnections(nearest.Triggered)
                    if tConns and #tConns>0 then
                        for _,c in ipairs(tConns) do if c.Function then task.spawn(c.Function) end end
                        fired=true
                    end
                end
            end)
            if not fired then
                pcall(function() fireproximityprompt(nearest,10000) end)
                pcall(function() nearest:InputHoldBegin(); task.wait(0.04); nearest:InputHoldEnd() end)
            end
            grabInProgress=false
        end)
        activatePotion()
    end
end)

-- Anti-ragdoll
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

-- Anti-bee (improved: remove BodyGyros, restore AutoRotate, correct velocity)
local FOV_LOCK=70
RunService.RenderStepped:Connect(function() if cam.FieldOfView~=FOV_LOCK then cam.FieldOfView=FOV_LOCK end end)
local beeBlacklist={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","PostEffect"}
local function isBeeEffect(obj) for _,n in ipairs(beeBlacklist) do if obj:IsA(n) then return true end end return false end
for _,v in pairs(Lighting:GetDescendants()) do if isBeeEffect(v) then pcall(function() v:Destroy() end) end end
Lighting.DescendantAdded:Connect(function(obj) task.wait(); if isBeeEffect(obj) then pcall(function() obj:Destroy() end) end end)
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
    -- Remove bee-related objects/values
    for _,obj in ipairs(char:GetDescendants()) do
        local nl=obj.Name:lower()
        if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") then pcall(function() obj:Destroy() end) end
    end
    -- Remove any BodyGyros or AngularVelocity applied by bee
    if root then
        for _,obj in ipairs(root:GetChildren()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyAngularVelocity") then pcall(function() obj:Destroy() end) end
        end
    end
    -- Restore AutoRotate
    if hum and not hum.AutoRotate then hum.AutoRotate=true end
    -- Reset bee bool/int values
    for _,val in ipairs(char:GetChildren()) do
        if val:IsA("BoolValue") or val:IsA("IntValue") or val:IsA("NumberValue") then
            local nl=val.Name:lower()
            if nl:find("bee") or nl:find("invert") or nl:find("reverse") then
                pcall(function() if val:IsA("BoolValue") then val.Value=false else val.Value=0 end end)
            end
        end
    end
    -- Correct inverted velocity
    if hum and root and hum.MoveDirection.Magnitude>0.1 then
        local md=hum.MoveDirection; local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
        if vel.Magnitude>2 and md:Dot(vel.Unit)<-0.3 then root.Velocity=Vector3.new(md.X*22,root.Velocity.Y,md.Z*22) end
    end
end)

-- Speed
local stealSpdOn=Cfg.stealSpdOn; local STEAL_SPD_VAL=math.clamp(Cfg.stealSpdVal or 30,10,60)
local speedEnabled=stealSpdOn; local stealingSpeed=STEAL_SPD_VAL; local isStealing=false
local function applySpeed()
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); local humanoid=char:FindFirstChildOfClass("Humanoid"); if not root or not humanoid then return end
    local dir=humanoid.MoveDirection
    if dir.Magnitude>0 then local spd=isStealing and stealingSpeed or 30; local vel=dir*spd; root.Velocity=Vector3.new(vel.X,root.Velocity.Y,vel.Z) end
end

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
                local rem=math.ceil(cd-now); if ib.Text~=tostring(rem) then ib.Text=tostring(rem); ib.TextSize=8; ib.TextColor3=C.red; ib.BackgroundColor3=Color3.fromRGB(60,8,8); ib.BackgroundTransparency=0.08 end
            else
                local icon=CMD_ICONS[cmd] or "?"
                if ib.Text~=icon then ib.Text=icon; ib.TextSize=10; ib.TextColor3=C.text; ib.BackgroundColor3=C.surf2; ib.BackgroundTransparency=0.2 end
            end
        end end
    end
end)

-- ═══════════════════════════════════
-- PANELS (new design)
-- ═══════════════════════════════════

-- PANEL A: Aethon Hub (purple)
local LP,_,lpMin=mkP(4,48,LP_W,LP_H,"AETHON HUB","◈",C.acc,"pos_LP")
local lpC=mkF(LP,27,LP_CH,lpMin); local lY=5
local function lpB(text,tc,bg)
    local b,bs=mkBtn(lpC,text,UDim2.fromOffset(LP_W-10,20),UDim2.fromOffset(5,lY),bg or C.surf,tc,6)
    b.TextSize=8; lY=lY+25; return b,bs
end
local rejB,_=lpB("↩  Rejoin",C.acc); rejB.MouseButton1Click:Connect(function() rejB.Text="..."; pcall(function() if reconnect then reconnect() elseif syn and syn.reconnect then syn.reconnect() else TeleportService:Teleport(game.PlaceId,lp) end end) end)
local kickB,_=lpB("✕  Kick Self",C.red,Color3.fromRGB(30,6,10))
do local s=kickB:FindFirstChildOfClass("UIStroke"); if s then s.Color=C.red;s.Transparency=0.35 end end
kickB.MouseButton1Click:Connect(function() kickB.Text="..."; lp:Kick("r9qbx on dc for suggestions") end)
local grabB,_=lpB("⬡  Auto Grab: ON",C.grn)
local function updG()
    grabB.Text=grabEnabled and "⬡  Auto Grab: ON" or "⬡  Auto Grab: OFF"
    TweenService:Create(grabB,TweenInfo.new(0.12),{BackgroundColor3=grabEnabled and Color3.fromRGB(8,22,14) or C.surf}):Play()
    grabB.TextColor3=grabEnabled and C.grn or C.dim
end
updG(); grabB.MouseButton1Click:Connect(function() grabEnabled=not grabEnabled; Cfg.grabOn=grabEnabled; save(); updG() end)
local camBusy=false; local camB,_=lpB("✦  AUTO ALLIGN",C.text)
camB.MouseButton1Click:Connect(function()
    if camBusy then return end; camBusy=true; camB.Text="Aligning..."
    task.spawn(function()
        pcall(doAutoAlign); camB.Text="✦  AUTO ALLIGN"; camBusy=false
    end)
end)

-- PANEL B: Flash TP (blue)
local FP,_,fpMin=mkP(0,5,FP_W,FP_H,"FLASH TP","⚡",C.blu,"pos_FP")
local fpC=mkF(FP,27,FP_CH,fpMin)

local togRow=Instance.new("Frame"); togRow.Size=UDim2.fromOffset(FP_W-10,20); togRow.Position=UDim2.fromOffset(5,5)
togRow.BackgroundColor3=C.surf; togRow.BackgroundTransparency=0.2; togRow.BorderSizePixel=0; togRow.Parent=fpC; co(togRow,6)
local togRS=Instance.new("UIStroke",togRow); togRS.Thickness=1; togRS.Color=C.bord; togRS.Transparency=0.45; togRS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local togLbl=lb(togRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-36,1,0),Text="Flash TP",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
local fpill=Instance.new("Frame"); fpill.Size=UDim2.fromOffset(24,12); fpill.Position=UDim2.new(1,-27,0.5,-6); fpill.BackgroundColor3=C.surf2; fpill.BorderSizePixel=0; fpill.Parent=togRow; co(fpill,12)
local fknob=Instance.new("Frame"); fknob.Size=UDim2.fromOffset(8,8); fknob.Position=UDim2.new(0,2,0.5,-4); fknob.BackgroundColor3=C.dim; fknob.BorderSizePixel=0; fknob.Parent=fpill; co(fknob,8)
local togB=Instance.new("TextButton"); togB.Size=UDim2.new(1,0,1,0); togB.BackgroundTransparency=1; togB.Text=""; togB.Parent=togRow
local function updFl()
    TweenService:Create(togRow,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and Color3.fromRGB(6,12,28) or C.surf,BackgroundTransparency=flashEnabled and 0.12 or 0.2}):Play()
    TweenService:Create(togRS,TweenInfo.new(0.12),{Color=flashEnabled and C.blu or C.bord,Transparency=flashEnabled and 0.2 or 0.45}):Play()
    TweenService:Create(fpill,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and C.blu or C.surf2}):Play()
    TweenService:Create(fknob,TweenInfo.new(0.12),{Position=flashEnabled and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=flashEnabled and C.white or C.dim}):Play()
    togLbl.TextColor3=flashEnabled and C.text or C.dim
end
updFl(); togB.MouseButton1Click:Connect(function() flashEnabled=not flashEnabled; Cfg.flashOn=flashEnabled; save(); updFl() end)

local trigL=lb(fpC,{Position=UDim2.fromOffset(5,30),Size=UDim2.fromOffset(FP_W-10,10),Text="Trigger: "..Cfg.triggerChance.."%",TextSize=7,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
local slBg=Instance.new("Frame"); slBg.Size=UDim2.fromOffset(FP_W-10,5); slBg.Position=UDim2.fromOffset(5,43); slBg.BackgroundColor3=C.surf; slBg.BorderSizePixel=0; slBg.Parent=fpC; co(slBg,3)
local slFill=Instance.new("Frame"); slFill.Size=UDim2.new(sliderValue,0,1,0); slFill.BackgroundColor3=C.blu; slFill.BorderSizePixel=0; slFill.Parent=slBg; co(slFill,3)
local slK=Instance.new("Frame"); slK.Size=UDim2.fromOffset(10,10); slK.AnchorPoint=Vector2.new(0.5,0.5); slK.Position=UDim2.new(sliderValue,0,0.5,0); slK.BackgroundColor3=C.white; slK.BorderSizePixel=0; slK.Parent=slBg; co(slK,5)
local slOn=false
local function setTr(pct) pct=math.clamp(pct,0,1); sliderValue=pct; Cfg.triggerChance=math.floor(pct*100); slFill.Size=UDim2.new(pct,0,1,0); slK.Position=UDim2.new(pct,0,0.5,0); trigL.Text="Trigger: "..math.floor(pct*100).."%" end
slBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slOn=true;setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if slOn then slOn=false;save() end end end)
UIS.InputChanged:Connect(function(i) if not slOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
lb(fpC,{Position=UDim2.fromOffset(5,52),Size=UDim2.fromOffset(FP_W-10,8),Text="91% = best  ·  EXT bypass active",TextSize=6,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
mkSep(fpC,62,C.bord)

local potRow=Instance.new("Frame"); potRow.Size=UDim2.fromOffset(FP_W-10,20); potRow.Position=UDim2.fromOffset(5,66)
potRow.BackgroundColor3=C.surf; potRow.BackgroundTransparency=0.2; potRow.BorderSizePixel=0; potRow.Parent=fpC; co(potRow,6)
local potRS=Instance.new("UIStroke",potRow); potRS.Thickness=1; potRS.Color=C.bord; potRS.Transparency=0.45; potRS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local potL=lb(potRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-36,1,0),Text="Giant Potion",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left})
local potTrack=Instance.new("Frame"); potTrack.Size=UDim2.fromOffset(24,12); potTrack.Position=UDim2.new(1,-27,0.5,-6); potTrack.BackgroundColor3=C.surf2; potTrack.BorderSizePixel=0; potTrack.Parent=potRow; co(potTrack,12)
local potK=Instance.new("Frame"); potK.Size=UDim2.fromOffset(8,8); potK.Position=UDim2.new(0,2,0.5,-4); potK.BackgroundColor3=C.dim; potK.BorderSizePixel=0; potK.Parent=potTrack; co(potK,8)
local potB=Instance.new("TextButton"); potB.Size=UDim2.new(1,0,1,0); potB.BackgroundTransparency=1; potB.Text=""; potB.Parent=potRow
local function updPot()
    TweenService:Create(potRow,TweenInfo.new(0.12),{BackgroundColor3=potionOn and Color3.fromRGB(6,12,28) or C.surf,BackgroundTransparency=potionOn and 0.12 or 0.2}):Play()
    TweenService:Create(potRS,TweenInfo.new(0.12),{Color=potionOn and C.blu or C.bord,Transparency=potionOn and 0.2 or 0.45}):Play()
    TweenService:Create(potTrack,TweenInfo.new(0.12),{BackgroundColor3=potionOn and C.blu or C.surf2}):Play()
    TweenService:Create(potK,TweenInfo.new(0.12),{Position=potionOn and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=potionOn and C.white or C.dim}):Play()
    potL.TextColor3=potionOn and C.text or C.dim
end
updPot(); potB.MouseButton1Click:Connect(function() potionOn=not potionOn; Cfg.potionOn=potionOn; save(); updPot() end)
local rstBtn,_=mkBtn(fpC,"↺  Instant Reset",UDim2.fromOffset(FP_W-10,18),UDim2.fromOffset(5,90),Color3.fromRGB(36,6,10),C.red,7)
rstBtn.TextSize=8; do local s=rstBtn:FindFirstChildOfClass("UIStroke"); if s then s.Color=C.red;s.Transparency=0.35 end end
rstBtn.MouseButton1Click:Connect(function() task.spawn(doReset) end)
lb(fpC,{Position=UDim2.fromOffset(5,112),Size=UDim2.fromOffset(FP_W-10,8),Text=DISCORD_LINK,TextSize=7,Font=Enum.Font.Gotham,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Center})

-- PANEL C: Admin (orange)
local RCMDS={{cmd="ragdoll",icon="🤸"},{cmd="balloon",icon="🎈"},{cmd="tiny",icon="🐜"},{cmd="jail",icon="🔒"},{cmd="rocket",icon="🚀"}}
local IW2=15; local IH2=16; local IG2=2; local ITOT=#RCMDS*(IW2+IG2)-IG2; local CW2=AP_W-10; local CSTART=CW2-ITOT-2
local AP,_,apMin=mkP(0,AP_Y_DEF,AP_W,24,"ADMIN","❖",C.org,"pos_AP")
local pScroll=Instance.new("ScrollingFrame"); pScroll.Size=UDim2.fromOffset(AP_W-6,0); pScroll.Position=UDim2.fromOffset(3,22)
pScroll.BackgroundColor3=C.bg; pScroll.BackgroundTransparency=0.65; pScroll.BorderSizePixel=0
pScroll.ScrollBarThickness=2; pScroll.ScrollBarImageColor3=C.org; pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; pScroll.CanvasSize=UDim2.new(0,0,0,0); pScroll.Parent=AP; co(pScroll,4)
local pLayout=Instance.new("UIListLayout"); pLayout.Padding=UDim.new(0,2); pLayout.SortOrder=Enum.SortOrder.Name; pLayout.Parent=pScroll
Instance.new("UIPadding",pScroll).PaddingTop=UDim.new(0,2)
local apFolded=false
local function resAP()
    if apFolded then return end
    local ch=math.min(pLayout.AbsoluteContentSize.Y+4,115)
    pScroll.Size=UDim2.fromOffset(AP_W-6,ch); AP.Size=UDim2.fromOffset(AP_W,22+ch+3)
end
pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resAP)
apMin.MouseButton1Click:Connect(function()
    apFolded=not apFolded; apMin.Text=apFolded and "+" or "─"; pScroll.Visible=not apFolded
    if apFolded then TweenService:Create(AP,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,24)}):Play()
    else local ch=math.min(pLayout.AbsoluteContentSize.Y+4,115); TweenService:Create(AP,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,22+ch+3)}):Play() end
end)
local pCards={}
local function refreshPlayers()
    for _,c in pairs(pCards) do pcall(function() c:Destroy() end) end; pCards={}; cmdBtnRefs={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame"); card.Name=p.Name; card.Size=UDim2.new(1,-4,0,28)
        card.BackgroundColor3=C.surf; card.BackgroundTransparency=0.22; card.BorderSizePixel=0; card.Parent=pScroll; co(card,5)
        local cs=Instance.new("UIStroke",card); cs.Thickness=1; cs.Color=C.bord; cs.Transparency=0.55; cs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local cz=Instance.new("TextButton"); cz.Size=UDim2.fromOffset(CSTART,28); cz.BackgroundTransparency=1; cz.Text=""; cz.AutoButtonColor=false; cz.Parent=card
        local ava=Instance.new("ImageLabel"); ava.Size=UDim2.fromOffset(17,17); ava.Position=UDim2.new(0,3,0.5,-8.5); ava.BackgroundColor3=C.surf2; ava.BorderSizePixel=0; ava.Parent=card; co(ava,9)
        task.spawn(function() local ok,img=pcall(Players.GetUserThumbnailAsync,Players,p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48); if ok then ava.Image=img end end)
        lb(card,{Position=UDim2.new(0,22,0,2),Size=UDim2.fromOffset(CSTART-25,13),Text=p.DisplayName,TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        lb(card,{Position=UDim2.new(0,22,0,15),Size=UDim2.fromOffset(CSTART-25,10),Text="@"..p.Name,TextSize=6,Font=Enum.Font.Gotham,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        cmdBtnRefs[p.UserId]={}
        for i,def in ipairs(RCMDS) do
            local bx=CSTART+2+(i-1)*(IW2+IG2)
            local ib=Instance.new("TextButton"); ib.Size=UDim2.fromOffset(IW2,IH2); ib.Position=UDim2.new(0,bx,0.5,-IH2/2)
            ib.BackgroundColor3=C.surf2; ib.BackgroundTransparency=0.18; ib.Text=def.icon; ib.TextSize=10; ib.TextColor3=C.text
            ib.Font=Enum.Font.GothamBold; ib.BorderSizePixel=0; ib.AutoButtonColor=false; ib.Parent=card; co(ib,4)
            local is=Instance.new("UIStroke",ib); is.Thickness=1; is.Color=C.bord; is.Transparency=0.5; is.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            cmdBtnRefs[p.UserId][def.cmd]=ib
            local pd=p; local dc=def.cmd
            ib.MouseButton1Click:Connect(function() fireCmd(pd,dc) end)
        end
        local pd=p
        cz.MouseButton1Click:Connect(function()
            for _,c2 in pairs(pCards) do local s2=c2:FindFirstChildOfClass("UIStroke"); if s2 then s2.Color=C.bord;s2.Transparency=0.55 end; c2.BackgroundTransparency=0.22 end
            cs.Color=C.org; cs.Transparency=0.1; card.BackgroundTransparency=0.08; fireClick(pd)
        end)
        pCards[p.UserId]=card
    end
    task.defer(resAP)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshPlayers() end)
task.delay(2,refreshPlayers)

-- PANEL D: Base Protector (red)
local BP,_,bpMin=mkP(0,0,BP_W,BP_H,"BASE PROTECTOR","◆",C.red,"pos_BP")
local bpC=mkF(BP,27,BP_CH,bpMin); local pyy=5
local function bpRow(label,col) local pb,set=mkPill(bpC,label,pyy,col); pyy=pyy+22; return pb,set end
local asB,asSet=bpRow("ANTI STEAL",C.text); asB.MouseButton1Click:Connect(function() antiSteal=not antiSteal; asSet(antiSteal) end)
local akB,akSet=bpRow("AUTO KICK",C.red); akB.MouseButton1Click:Connect(function() autoKick=not autoKick; akSet(autoKick) end)
local aiB,aiSet=bpRow("ANTI INTRUDER",C.org); aiB.MouseButton1Click:Connect(function() antiIntruder=not antiIntruder; aiSet(antiIntruder) end)
local atB,atSet=bpRow("ANTI TP",C.yel); atB.MouseButton1Click:Connect(function() antiTp=not antiTp; atSet(antiTp) end)

-- PANEL E: Speed (green)
local SP,_,spMin=mkP(4,LP_H+48+4,SP_W,SP_H,"SPEED","►",C.grn,"pos_SP")
local spC=mkF(SP,27,SP_CH,spMin); local sy=5
local ssB,ssSet=mkPill(spC,"Steal Speed",sy,C.grn); sy=sy+22
ssB.MouseButton1Click:Connect(function()
    stealSpdOn=not stealSpdOn; isStealing=stealSpdOn; speedEnabled=stealSpdOn
    ssSet(stealSpdOn); Cfg.stealSpdOn=stealSpdOn; save()
end)
if stealSpdOn then ssSet(true); isStealing=true; speedEnabled=true end
numRow(spC,"Speed",STEAL_SPD_VAL,10,60,sy,SP_W,function(v) STEAL_SPD_VAL=v; stealingSpeed=v; Cfg.stealSpdVal=v; save() end)

-- Reset popup
rsPnlBtn.MouseButton1Click:Connect(function()
    local popup=Instance.new("Frame",SG); popup.Size=UDim2.fromOffset(192,66); popup.Position=UDim2.new(0.5,-96,0.38,-33)
    popup.BackgroundColor3=C.panel; popup.BackgroundTransparency=0.05; popup.BorderSizePixel=0; co(popup,10)
    local ps=Instance.new("UIStroke",popup); ps.Thickness=1.2; ps.Color=C.acc; ps.Transparency=0.2; ps.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(popup,{Size=UDim2.new(1,0,0,28),Position=UDim2.fromOffset(0,5),Text="Reset panels to defaults?",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.text})
    local yesB,_=mkBtn(popup,"Yes",UDim2.fromOffset(80,22),UDim2.fromOffset(12,38),Color3.fromRGB(10,36,14),C.grn)
    local noB,_=mkBtn(popup,"No",UDim2.fromOffset(80,22),UDim2.fromOffset(100,38),Color3.fromRGB(36,8,10),C.red)
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
