--[[  Phantom Flash V5  |  Made By r9qbx on discord  ]]

local Players=game:GetService("Players"); local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService"); local RS=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService"); local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui"); local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local lp=Players.LocalPlayer; local cam=workspace.CurrentCamera

local CFG="PhantomFlashV5i.json"
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
    if v:IsA("ScreenGui") and v.Name:sub(1,4)=="PhFV" then v:Destroy() end
end
local SG=Instance.new("ScreenGui"); SG.Name="PhFV5i_"..tostring(math.random(1000,9999))
SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Global; SG.IgnoreGuiInset=true; SG.Parent=CoreGui

local T={
    bg=Color3.fromRGB(5,5,8),panel=Color3.fromRGB(8,8,13),surf=Color3.fromRGB(14,14,22),surf2=Color3.fromRGB(20,20,30),
    a1=Color3.fromRGB(225,225,238),a2=Color3.fromRGB(175,175,195),white=Color3.new(1,1,1),
    dim=Color3.fromRGB(100,100,122),str=Color3.fromRGB(155,155,178),red=Color3.fromRGB(255,65,65),grn=Color3.fromRGB(52,218,88),
}
local function co(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 7); c.Parent=p end
local function ms(p,th,col,tr) local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Color=col or T.str; s.Transparency=tr or 0.38; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function lb(par,props) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextColor3=T.white; l.BorderSizePixel=0; for k,v in pairs(props) do l[k]=v end; l.Parent=par; return l end
local function btn(par,text,sz,pos,bg) local b=Instance.new("TextButton"); b.Size=sz; b.Position=pos; b.BackgroundColor3=bg or T.surf; b.BackgroundTransparency=0.22; b.Text=text; b.TextColor3=T.white; b.Font=Enum.Font.GothamBold; b.TextSize=9; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=par; co(b,5); ms(b,1,T.str,0.44); return b end
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
    f.BackgroundColor3=T.panel; f.BackgroundTransparency=0.28; f.BorderSizePixel=0; f.ClipsDescendants=true; f.Parent=SG; co(f,9); rotS(f,ac or T.a1)
    local hdr=Instance.new("Frame"); hdr.Size=UDim2.new(1,0,0,21); hdr.BackgroundColor3=T.surf; hdr.BackgroundTransparency=0.18; hdr.BorderSizePixel=0; hdr.Parent=f; co(hdr,9)
    local flat=Instance.new("Frame"); flat.Size=UDim2.new(1,0,0,7); flat.Position=UDim2.new(0,0,1,-7); flat.BackgroundColor3=T.surf; flat.BackgroundTransparency=0.18; flat.BorderSizePixel=0; flat.Parent=hdr
    if title then lb(hdr,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-26,1,0),Text=title,TextSize=8,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.a1}) end
    local mb=btn(hdr,"─",UDim2.fromOffset(15,13),UDim2.new(1,-18,0.5,-6.5),T.surf2); mb.TextSize=8; mb.TextColor3=T.dim; mb.BackgroundTransparency=0.6
    dragSave(hdr,f,posKey); return f,hdr,mb
end
local function mkF(parent,hH,cH,mb)
    local content=Instance.new("Frame"); content.Size=UDim2.new(1,0,0,cH); content.Position=UDim2.fromOffset(0,hH)
    content.BackgroundTransparency=1; content.BorderSizePixel=0; content.Parent=parent
    local folded=false; local fullH=parent.Size.Y.Offset
    mb.MouseButton1Click:Connect(function()
        folded=not folded; mb.Text=folded and "+" or "─"
        TweenService:Create(parent,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{Size=UDim2.new(0,parent.Size.X.Offset,0,folded and hH+2 or fullH)}):Play()
    end)
    return content
end
local function pillR(parent,label,yPos,onCol)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-8,0,20); row.Position=UDim2.new(0,4,0,yPos)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.28; row.BorderSizePixel=0; row.Parent=parent; co(row,6)
    local rs=ms(row,1,T.str,0.55)
    local rl=lb(row,{Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-38,1,0),Text=label,TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local track=Instance.new("Frame"); track.Size=UDim2.fromOffset(25,12); track.Position=UDim2.new(1,-29,0.5,-6); track.BackgroundColor3=T.surf2; track.BorderSizePixel=0; track.Parent=row; co(track,12)
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(8,8); knob.Position=UDim2.new(0,2,0.5,-4); knob.BackgroundColor3=T.a2; knob.BorderSizePixel=0; knob.Parent=track; co(knob,8)
    local pb=Instance.new("TextButton"); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1; pb.Text=""; pb.Parent=row
    local col=onCol or T.a1; local isOn=false
    local function set(v) isOn=v
        TweenService:Create(track,TweenInfo.new(0.12),{BackgroundColor3=v and col or T.surf2}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=v and T.white or T.a2}):Play()
        TweenService:Create(rs,TweenInfo.new(0.12),{Color=v and col or T.str,Transparency=v and 0.18 or 0.55}):Play()
        rl.TextColor3=v and T.white or T.dim
    end
    return pb,set
end
local function numRow(parent,label,val,mn,mx,yPos,w,onChange)
    local IW=w-10; local row=Instance.new("Frame"); row.Size=UDim2.fromOffset(IW,20); row.Position=UDim2.fromOffset(5,yPos)
    row.BackgroundColor3=T.surf; row.BackgroundTransparency=0.28; row.BorderSizePixel=0; row.Parent=parent; co(row,5); ms(row,1,T.str,0.5)
    lb(row,{Position=UDim2.new(0,6,0,0),Size=UDim2.new(0.46,0,1,0),Text=label,TextSize=8,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local mB=Instance.new("TextButton",row); mB.Size=UDim2.fromOffset(14,14); mB.Position=UDim2.new(0.5,0,0.5,-7); mB.BackgroundColor3=T.surf2; mB.Text="-"; mB.Font=Enum.Font.GothamBold; mB.TextSize=10; mB.TextColor3=T.a1; mB.BorderSizePixel=0; mB.AutoButtonColor=false; co(mB,3)
    local vB=Instance.new("TextBox",row); vB.Size=UDim2.fromOffset(26,14); vB.Position=UDim2.new(0.5,16,0.5,-7); vB.BackgroundColor3=T.surf2; vB.BorderSizePixel=0; vB.Text=tostring(val); vB.Font=Enum.Font.GothamBold; vB.TextSize=9; vB.TextColor3=T.a1; vB.ClearTextOnFocus=false; co(vB,3)
    local pB=Instance.new("TextButton",row); pB.Size=UDim2.fromOffset(14,14); pB.Position=UDim2.new(0.5,44,0.5,-7); pB.BackgroundColor3=T.surf2; pB.Text="+"; pB.Font=Enum.Font.GothamBold; pB.TextSize=10; pB.TextColor3=T.a1; pB.BorderSizePixel=0; pB.AutoButtonColor=false; co(pB,3)
    local cur=val
    local function setV(v) cur=math.clamp(math.floor(v),mn,mx); vB.Text=tostring(cur); if onChange then onChange(cur) end end
    mB.MouseButton1Click:Connect(function() setV(cur-1) end)
    pB.MouseButton1Click:Connect(function() setV(cur+1) end)
    vB.FocusLost:Connect(function() local n=tonumber(vB.Text); if n then setV(n) else vB.Text=tostring(cur) end end)
    return row
end

task.wait(0.1); local vp=cam.ViewportSize; if vp.X==0 then vp=Vector2.new(390,844) end

local FP_W=148; local FP_CH=118; local FP_H=21+FP_CH+11
local AP_W=186; local AP_Y_DEF=5+FP_H+5
local BP_W=136; local BP_CH=5*23+6; local BP_H=21+BP_CH+11
local LP_W=130; local LP_CH=108; local LP_H=21+LP_CH+11
local SP_W=130; local SP_CH=51; local SP_H=21+SP_CH+11

if not Cfg.pos_FP or Cfg.pos_FP.ox==0 then Cfg.pos_FP={ox=math.floor(vp.X-FP_W-5),oy=5} end
if not Cfg.pos_AP or Cfg.pos_AP.ox==0 then Cfg.pos_AP={ox=math.floor(vp.X-AP_W-5),oy=AP_Y_DEF} end
if not Cfg.pos_BP or Cfg.pos_BP.ox==0 then Cfg.pos_BP={ox=math.floor(vp.X*0.5-BP_W*0.5),oy=math.floor(vp.Y*0.5-BP_H*0.5)} end
if not Cfg.pos_SP or Cfg.pos_SP.oy==0 then Cfg.pos_SP={ox=6,oy=LP_H+48+6} end

-- Watermark
local wmL=Instance.new("TextLabel",SG); wmL.Size=UDim2.fromOffset(200,22); wmL.Position=UDim2.new(0.5,-100,0.4,-11)
wmL.BackgroundTransparency=1; wmL.Text="Made by r9qbx"; wmL.Font=Enum.Font.GothamBlack; wmL.TextSize=13; wmL.TextColor3=T.a1; wmL.TextTransparency=0.96
TweenService:Create(wmL,TweenInfo.new(2.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{TextTransparency=0.52}):Play()

-- FPS + Ping
local fpsF=Instance.new("Frame",SG); fpsF.Size=UDim2.fromOffset(136,17); fpsF.Position=UDim2.new(0.5,-68,0,4)
fpsF.BackgroundColor3=T.panel; fpsF.BackgroundTransparency=0.32; fpsF.BorderSizePixel=0; co(fpsF,6); ms(fpsF,1,T.str,0.42)
local fpsLb=lb(fpsF,{Size=UDim2.new(1,0,1,0),Text="FPS --  ·  PING -- ms",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.a1})
local lastDt=1/60
task.spawn(function() while task.wait(0.7) do
    if not fpsLb.Parent then break end
    local fps=math.min(999,math.floor(1/math.max(lastDt,0.001))); local ping=0
    pcall(function() ping=math.floor(lp:GetNetworkPing()*1000) end)
    fpsLb.Text="FPS "..fps.."  ·  PING "..ping.."ms"
    fpsLb.TextColor3=fps<40 and T.red or fps<55 and Color3.fromRGB(255,190,40) or T.grn
end end)

-- Reset Panels btn y=43
local rsPnlBtn=Instance.new("TextButton",SG); rsPnlBtn.Size=UDim2.fromOffset(88,13)
rsPnlBtn.Position=UDim2.new(0.5,-44,0,43); rsPnlBtn.BackgroundColor3=T.panel; rsPnlBtn.BackgroundTransparency=0.42
rsPnlBtn.Text="Reset Panels"; rsPnlBtn.Font=Enum.Font.GothamBold; rsPnlBtn.TextSize=7; rsPnlBtn.TextColor3=T.dim
rsPnlBtn.BorderSizePixel=0; rsPnlBtn.AutoButtonColor=false; co(rsPnlBtn,4); ms(rsPnlBtn,1,T.str,0.55)

-- Timer ESP
local timerESPs={}; local myPlotRef=nil; local baseAlerted=false; local stealHitbox=nil
local ECOL_R=Color3.fromRGB(255,65,65); local ECOL_Y=Color3.fromRGB(255,190,40); local ECOL_G=Color3.fromRGB(52,218,88)
local function showAlert()
    pcall(function() local s=Instance.new("Sound"); s.SoundId="rbxassetid://9118633772"; s.Volume=0.85; s.Parent=workspace; s:Play(); Debris:AddItem(s,5) end)
    local ag=Instance.new("ScreenGui",CoreGui); ag.Name="PhAlert"; ag.ResetOnSpawn=false; ag.IgnoreGuiInset=true
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
                    if tot<=5 and not baseAlerted then baseAlerted=true; task.spawn(showAlert)
                    elseif tot>5 then baseAlerted=false end
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
local ESPTAG="PhE_"..tostring(math.random(1000,9999))
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

-- =====================================================================
-- SUBSPACE MINE ESP – event-driven, always running in background
-- Searches "Subspace Mine" objects specifically
-- =====================================================================
local mineESPs={}
local function addMineESP(child)
    if mineESPs[child] then return end
    local nl=child.Name:lower()
    if not (nl:find("subspace") or nl:find("mine")) then return end
    if nl:find("bullet") then return end
    local part=child:IsA("BasePart") and child or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")))
    if not part then return end
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(80,20); bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=workspace
    local bgM=Instance.new("Frame",bb); bgM.Size=UDim2.new(1,0,1,0); bgM.BackgroundColor3=Color3.fromRGB(6,6,10); bgM.BackgroundTransparency=0.2; bgM.BorderSizePixel=0; co(bgM,4)
    local tl=Instance.new("TextLabel",bgM); tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1; tl.Text="💣 "..child.Name; tl.Font=Enum.Font.GothamBold; tl.TextSize=9; tl.TextColor3=T.red; tl.TextStrokeTransparency=0.4; tl.TextStrokeColor3=Color3.new(0,0,0)
    mineESPs[child]={bb=bb}
    -- Auto-clean when destroyed
    child.AncestryChanged:Connect(function()
        if not child.Parent then pcall(function() bb:Destroy() end); mineESPs[child]=nil end
    end)
end
-- Initial scan + watch for new mines
for _,d in pairs(workspace:GetDescendants()) do addMineESP(d) end
workspace.DescendantAdded:Connect(function(d) task.defer(function() addMineESP(d) end) end)

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
    for _,cmd in ipairs(CLICK_CMDS) do
        aFire(tgt,cmd)
        if ROW_CD[cmd] then rowCdEnd[cmd]=tick()+ROW_CD[cmd] end
    end
end

-- =====================================================================
-- BASE PROTECTOR
-- BUG FIX: punish uses player closest to STEAL HITBOX (not to self)
-- This correctly identifies the thief even when friends are nearby
-- =====================================================================
local CARPET={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true,["Cupid's Wings"]=true}
local antiSteal=false; local autoKick=false; local antiIntruder=false; local antiTp=false
local lastPunish={}; local carpetSpam={}; local plrPos={}; local tpCD={}

local function punish(p)
    if not ADM_REMOTE or not p or p==lp then return end
    local char=p.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local uid=p.UserId; local now=tick()
    if lastPunish[uid] and now-lastPunish[uid]<0.5 then return end
    lastPunish[uid]=now
    pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)  -- instant, no task.spawn
    rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
    if autoKick then task.delay(0.05,function() lp:Kick("SAVED BY PHANTOM🫡") end) end
end

-- Find thief: player closest to the steal HITBOX (not to local player)
local function findThief()
    -- Use hitbox center if available, otherwise fallback to our position
    local searchPos=stealHitbox and stealHitbox.Position
    if not searchPos then
        local myHRP=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        searchPos=myHRP and myHRP.Position
    end
    if not searchPos then return nil end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d=(hrp.Position-searchPos).Magnitude
                if d<bd then bd=d; best=p end
            end
        end
    end
    return best
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
            local thief=findThief()
            if thief then punish(thief) end
            chkHitbox()
        end
        return old(prompt,...)
    end))
end)

pcall(function()
    for _,obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            obj.OnClientEvent:Connect(function(...)
                if not antiSteal or not ADM_REMOTE or not myPlotRef then return end
                for _,a in ipairs({...}) do
                    if type(a)=="string" and a:lower():find("stealing") then
                        -- Find player closest to steal HITBOX (fix: not closest to local player)
                        local thief=findThief()
                        if thief then punish(thief) end
                        return
                    end
                end
            end)
        end
    end
end)

-- EXT steal callbacks
local StealCBCache={}
local function buildStealCBs(prompt)
    if StealCBCache[prompt] then return end
    local data={hold={},trig={}}
    local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end end
    local ok2,c2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(c2)=="table" then for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trig,c.Function) end end end
    if #data.hold>0 or #data.trig>0 then StealCBCache[prompt]=data end
end
local function fireStealCBs(prompt)
    local data=StealCBCache[prompt]; if not data then return end
    for _,fn in ipairs(data.hold) do task.spawn(fn) end
    task.wait(0.05)
    for _,fn in ipairs(data.trig) do task.spawn(fn) end
end

-- Giant Potion: scan if tool exists = ready (no timer)
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

-- Irish Hub instant reset (doReset – copied exactly)
local tpPos=CFrame.new(1000003.56,999999.69,8.17)
local function doReset()
    local c=lp.Character; if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    cam.CameraType=Enum.CameraType.Scriptable
    task.delay(0.6,function()
        local ch=lp.Character; local hm=ch and ch:FindFirstChildOfClass("Humanoid")
        if hm then cam.CameraType=Enum.CameraType.Custom; cam.CameraSubject=hm end
    end)
    h.CFrame=tpPos
    local con
    con=RunService.Heartbeat:Connect(function()
        if not c or not c.Parent then con:Disconnect(); return end
        if hum.Health<=0 then con:Disconnect(); return end
        h.CFrame=tpPos
    end)
end

-- Flash TP: Heartbeat+pre-calc, flash → 1 frame → potion
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
            task.spawn(function() RunService.Heartbeat:Wait(); activatePotion() end)
            task.spawn(function()
                task.wait(0.1); buildStealCBs(prompt)
                if StealCBCache[prompt] then fireStealCBs(prompt) end
            end)
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function()
        if not fired then fired=true; activePrompts[prompt]=nil; conn:Disconnect() end
    end)
end)

-- Cam Align
local cfA=CFrame.new(-322.066,-7.871,111.991)*CFrame.Angles(0.332,-0.019,0.000)
local cfB=CFrame.new(-325.856,-7.866,113.027)*CFrame.Angles(0.327,3.130,0.000)
local lookA2=cfA.LookVector; local lookB2=cfB.LookVector; local desiredY=lookA2.Y
local function flattenV(v) local f=Vector3.new(v.X,0,v.Z); return f.Magnitude>0 and f.Unit or f end
local function buildLook(baseLook)
    local h2=flattenV(baseLook); local fs=math.sqrt(math.max(0,1-desiredY^2))
    return Vector3.new(h2.X*fs,desiredY,h2.Z*fs)
end
local function getBestLook2()
    local cf=flattenV(cam.CFrame.LookVector)
    return cf:Dot(flattenV(lookA2))>cf:Dot(flattenV(lookB2)) and buildLook(lookA2) or buildLook(lookB2)
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
local function alignCam()
    local pos=cam.CFrame.Position; local best=getBestLook2()
    cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=CFrame.lookAt(pos,pos+best)
    task.wait(); cam.CameraType=Enum.CameraType.Custom
end

-- =====================================================================
-- ANTI-RAGDOLL – always runs in background, no need to toggle
-- Uses provided code: destroys BallSocketConstraints
-- =====================================================================
local arConn=nil
local function startAntiRagdoll()
    if arConn then return end
    arConn=RunService.Heartbeat:Connect(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local root=char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s=hum:GetState()
        local ragdolled=(s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown)
        local endTime=lp:GetAttribute("RagdollEndTime")
        if endTime and (endTime-workspace:GetServerTimeNow())>0 then ragdolled=true end
        if ragdolled then
            pcall(function() lp:SetAttribute("RagdollEndTime",workspace:GetServerTimeNow()) end)
            for _,d in ipairs(char:GetDescendants()) do
                if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
                    d:Destroy()
                end
            end
            for _,obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end
            end
            if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            cam.CameraSubject=hum
            root.Anchored=false
            root.AssemblyLinearVelocity=Vector3.zero
            root.AssemblyAngularVelocity=Vector3.zero
        end
    end)
end
startAntiRagdoll()  -- always running from start, no toggle needed

-- =====================================================================
-- ANTI-SENTRY – range increased to 200 studs
-- =====================================================================
local DETECTION_DISTANCE=200; local PULL_DISTANCE=-5  -- was 60, now 200
local sentryFirstSeen={}; local sentryTarget=nil
local function getSentryWeapon()
    local char=lp.Character; if not char then return nil end
    return (lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat")
end
local function findSentryTarget()
    local char=lp.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local rootPos=hrp.Position; local now=tick()
    for obj in pairs(sentryFirstSeen) do if not obj.Parent then sentryFirstSeen[obj]=nil end end
    for _,obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local ownerId=obj.Name:match("Sentry_(%d+)")
            if ownerId and tonumber(ownerId)==lp.UserId then continue end
            local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part and (rootPos-part.Position).Magnitude<=DETECTION_DISTANCE then
                if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=now end
                if now-sentryFirstSeen[obj]>=3 then return obj end
            end
        end
    end
    return nil
end
local function moveSentry(obj)
    local char=lp.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    for _,part in pairs(obj:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
    local cf=hrp.CFrame*CFrame.new(0,0,PULL_DISTANCE)
    if obj:IsA("BasePart") then obj.CFrame=cf
    elseif obj:IsA("Model") then local main=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if main then main.CFrame=cf end end
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
    if sentryTarget and sentryTarget.Parent==workspace then
        moveSentry(sentryTarget); attackSentry()
    else
        sentryTarget=findSentryTarget()
    end
end)
task.spawn(function()
    task.wait(1)
    for _,obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local ownerId=obj.Name:match("Sentry_(%d+)")
            if not (ownerId and tonumber(ownerId)==lp.UserId) then
                sentryFirstSeen[obj]=tick()-3
            end
        end
    end
end)

-- =====================================================================
-- ANTI-BEE: visual effects clear + FOV + inverse movement fix
-- Detects if velocity is opposite to move direction and corrects it
-- =====================================================================
local FOV_LOCK=70
RunService.RenderStepped:Connect(function()
    if cam.FieldOfView~=FOV_LOCK then cam.FieldOfView=FOV_LOCK end
end)
local beeBlacklist={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","PostEffect"}
local function isBeeEffect(obj)
    for _,n in ipairs(beeBlacklist) do if obj:IsA(n) then return true end end; return false
end
local function clearBeeEffects()
    for _,v in pairs(Lighting:GetDescendants()) do if isBeeEffect(v) then pcall(function() v:Destroy() end) end end
end
clearBeeEffects()
Lighting.DescendantAdded:Connect(function(obj) task.wait(); if isBeeEffect(obj) then pcall(function() obj:Destroy() end) end end)

-- Inverse movement fix: destroy bee objects from character + correct velocity if inverted
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    -- Destroy bee-related objects added to character
    for _,obj in ipairs(char:GetDescendants()) do
        local nl=obj.Name:lower()
        if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") then
            pcall(function() obj:Destroy() end)
        end
    end
    -- Detect and correct inverse movement:
    -- If player's velocity direction is OPPOSITE to their move direction, they're inversed
    local hum=char:FindFirstChildOfClass("Humanoid")
    local root=char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.MoveDirection.Magnitude>0.1 then
        local md=hum.MoveDirection
        local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
        if vel.Magnitude>3 and md:Dot(vel.Unit)<-0.5 then
            -- Velocity is opposite to input direction = bee inversion detected, correct it
            root.Velocity=Vector3.new(md.X*16,root.Velocity.Y,md.Z*16)
        end
    end
end)

-- Silent Hub Speed
local stealSpdOn=Cfg.stealSpdOn; local STEAL_SPD_VAL=math.clamp(Cfg.stealSpdVal or 30,10,60)
local speedEnabled=stealSpdOn; local stealingSpeed=STEAL_SPD_VAL; local normalSpeed=30; local isStealing=false
local function applySpeed()
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); local humanoid=char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    local dir=humanoid.MoveDirection
    if dir.Magnitude>0 then
        local spd=isStealing and stealingSpeed or normalSpeed
        local vel=dir*spd; root.Velocity=Vector3.new(vel.X,root.Velocity.Y,vel.Z)
    end
end

-- Instant Grab: EXT async + Vander fallback, potion instant no delay
local grabEnabled=Cfg.grabOn
local function getPos2(pr)
    local p=pr.Parent
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Model") then local r=p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart"); return r and r.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    local pt=p:FindFirstChildWhichIsA("BasePart",true); return pt and pt.Position
end
local function findNearestSteal()
    local char=lp.Character; if not char then return nil end
    local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"); if not root then return nil end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local myPos=root.Position; local nearest,nd=nil,math.huge
    for _,plot in ipairs(plots:GetChildren()) do
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and obj.ActionText=="Steal" then
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
        if grabEnabled then
            local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                local nearest=findNearestSteal()
                if nearest then
                    task.wait(0.07)
                    buildStealCBs(nearest)
                    local data=StealCBCache[nearest]
                    if data and (#data.hold>0 or #data.trig>0) then
                        task.spawn(function() fireStealCBs(nearest) end)
                    else
                        task.spawn(function() pcall(function()
                            fireproximityprompt(nearest,10000)
                            nearest:InputHoldBegin(); task.wait(0.04); nearest:InputHoldEnd()
                        end) end)
                    end
                    activatePotion()  -- instant, no delay
                end
            end
        end
        task.wait(0.3)
    end
end)

local cmdBtnRefs={}

-- Consolidated Heartbeat (speed + ANTI INTRUDER + ANTI TP + cmd timers)
RunService.Heartbeat:Connect(function(dt)
    lastDt=dt; local now=tick()
    if speedEnabled then applySpeed() end

    -- ANTI INTRUDER (balloon only, instant, balloon btn cooldown shown)
    if antiIntruder and stealHitbox and ADM_REMOTE then
        local cf,sz=stealHitbox.CFrame,stealHitbox.Size; local hx,hz=sz.X*0.5,sz.Z*0.5
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local rel=cf:PointToObjectSpace(hrp.Position)
            if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then
                for _,item in ipairs(p.Character:GetChildren()) do if CARPET[item.Name] then
                    local uid=p.UserId
                    if not carpetSpam[uid] then
                        carpetSpam[uid]=true
                        pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)
                        rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
                        if autoKick then task.delay(0.05,function() lp:Kick("SAVED BY PHANTOM🫡") end) end
                        task.delay(5,function() carpetSpam[uid]=nil end)
                    end; break
                end end
            end
        end end
    end

    -- ANTI TP (balloon only)
    if antiTp and ADM_REMOTE then
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local cur=hrp.Position; local uid=p.UserId; local last=plrPos[uid]
            if last and (cur-last).Magnitude>7 then
                for _,item in ipairs(p.Character:GetChildren()) do if CARPET[item.Name] then
                    if not tpCD[uid] or now-tpCD[uid]>3 then
                        tpCD[uid]=now
                        pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)
                        rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
                        if autoKick then task.delay(0.05,function() lp:Kick("SAVED BY PHANTOM🫡") end) end
                    end; break
                end end
            end
            plrPos[uid]=cur
        end end
    end

    -- Cmd timer display
    for _,cmds in pairs(cmdBtnRefs) do
        for cmd,ib in pairs(cmds) do if ib and ib.Parent then
            local cd=rowCdEnd[cmd]
            if cd and cd>now then
                local rem=math.ceil(cd-now); local rs=tostring(rem)
                if ib.Text~=rs then ib.Text=rs; ib.TextSize=9; ib.TextColor3=T.red; ib.BackgroundColor3=Color3.fromRGB(65,8,8); ib.BackgroundTransparency=0.1 end
            else
                local icon=CMD_ICONS[cmd] or "?"
                if ib.Text~=icon then ib.Text=icon; ib.TextSize=11; ib.TextColor3=T.a1; ib.BackgroundColor3=T.surf2; ib.BackgroundTransparency=0.22 end
            end
        end end
    end
end)

-- PANEL A: Phantom Hub
local LP,_,lpMin=mkP(6,48,LP_W,LP_H,"Phantom Hub",T.a1,"pos_LP")
local lpC=mkF(LP,21,LP_CH,lpMin); local lY=4
local function lpB(text,bg) local b=btn(lpC,text,UDim2.fromOffset(LP_W-10,21),UDim2.fromOffset(5,lY),bg); lY=lY+26; return b end

local rejB=lpB("Rejoin"); rejB.TextColor3=T.a1
do local s=rejB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.a1;s.Transparency=0.22 end end
rejB.MouseButton1Click:Connect(function() rejB.Text="..."; pcall(function() if reconnect then reconnect() elseif syn and syn.reconnect then syn.reconnect() else TeleportService:Teleport(game.PlaceId,lp) end end) end)

local kickB=lpB("Kick"); kickB.TextColor3=T.red
do local s=kickB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.red;s.Transparency=0.3 end end
kickB.MouseButton1Click:Connect(function() kickB.Text="..."; lp:Kick("r9qbx on dc for suggestions") end)

local grabB=lpB("Instant Grab: ON"); grabB.TextSize=8
local function updG() grabB.Text=grabEnabled and "Instant Grab: ON" or "Instant Grab: OFF"
    TweenService:Create(grabB,TweenInfo.new(0.1),{BackgroundColor3=grabEnabled and Color3.fromRGB(12,22,12) or T.surf}):Play()
    grabB.TextColor3=grabEnabled and T.grn or T.white end
updG(); grabB.MouseButton1Click:Connect(function() grabEnabled=not grabEnabled; Cfg.grabOn=grabEnabled; save(); updG() end)

local camBusy=false; local camB=lpB("ALLIGN CAMERA"); camB.TextSize=8
camB.MouseButton1Click:Connect(function()
    if camBusy then return end; camBusy=true; camB.Text="Aligning..."
    TweenService:Create(camB,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(18,18,32)}):Play()
    pcall(equipFlash); task.wait(0.05); pcall(alignCam)
    task.delay(1,function() camB.Text="ALLIGN CAMERA"; TweenService:Create(camB,TweenInfo.new(0.12),{BackgroundColor3=T.surf}):Play(); camBusy=false end)
end)

-- PANEL B: Flash TP (divider fixed)
local FP,_,fpMin=mkP(0,5,FP_W,FP_H,"Flash TP",T.a2,"pos_FP")
local fpC=mkF(FP,21,FP_CH,fpMin)
local togRow=Instance.new("Frame"); togRow.Size=UDim2.fromOffset(FP_W-10,21); togRow.Position=UDim2.fromOffset(5,4)
togRow.BackgroundColor3=T.surf; togRow.BackgroundTransparency=0.28; togRow.BorderSizePixel=0; togRow.Parent=fpC; co(togRow,6)
local togRS=ms(togRow,1,T.str,0.55)
local togLbl=lb(togRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-42,1,0),Text="Flash TP",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local pill=Instance.new("Frame"); pill.Size=UDim2.fromOffset(25,12); pill.Position=UDim2.new(1,-29,0.5,-6); pill.BackgroundColor3=T.surf2; pill.BorderSizePixel=0; pill.Parent=togRow; co(pill,12)
local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(8,8); knob.Position=UDim2.new(0,2,0.5,-4); knob.BackgroundColor3=T.a2; knob.BorderSizePixel=0; knob.Parent=pill; co(knob,8)
local togB=Instance.new("TextButton"); togB.Size=UDim2.new(1,0,1,0); togB.BackgroundTransparency=1; togB.Text=""; togB.Parent=togRow
local function updFl()
    TweenService:Create(togRow,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and Color3.fromRGB(12,12,20) or T.surf,BackgroundTransparency=flashEnabled and 0.15 or 0.28}):Play()
    TweenService:Create(togRS,TweenInfo.new(0.12),{Color=flashEnabled and T.a1 or T.str,Transparency=flashEnabled and 0.2 or 0.55}):Play()
    TweenService:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and T.a1 or T.surf2}):Play()
    TweenService:Create(knob,TweenInfo.new(0.12),{Position=flashEnabled and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=flashEnabled and T.white or T.a2}):Play()
    togLbl.TextColor3=flashEnabled and T.white or T.dim
end
updFl(); togB.MouseButton1Click:Connect(function() flashEnabled=not flashEnabled; Cfg.flashOn=flashEnabled; save(); updFl() end)

local trigL=lb(fpC,{Position=UDim2.fromOffset(5,30),Size=UDim2.fromOffset(FP_W-10,11),Text="Trigger: "..Cfg.triggerChance.."%",TextSize=8,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local slBg=Instance.new("Frame"); slBg.Size=UDim2.fromOffset(FP_W-10,5); slBg.Position=UDim2.fromOffset(5,44); slBg.BackgroundColor3=T.surf; slBg.BorderSizePixel=0; slBg.Parent=fpC; co(slBg,3)
local slFill=Instance.new("Frame"); slFill.Size=UDim2.new(sliderValue,0,1,0); slFill.BackgroundColor3=T.a1; slFill.BorderSizePixel=0; slFill.Parent=slBg; co(slFill,3)
local slK=Instance.new("Frame"); slK.Size=UDim2.fromOffset(10,10); slK.AnchorPoint=Vector2.new(0.5,0.5); slK.Position=UDim2.new(sliderValue,0,0.5,0); slK.BackgroundColor3=T.white; slK.BorderSizePixel=0; slK.Parent=slBg; co(slK,5)
local slOn=false
local function setTr(pct) pct=math.clamp(pct,0,1); sliderValue=pct; Cfg.triggerChance=math.floor(pct*100); slFill.Size=UDim2.new(pct,0,1,0); slK.Position=UDim2.new(pct,0,0.5,0); trigL.Text="Trigger: "..math.floor(pct*100).."%" end
slBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slOn=true;setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if slOn then slOn=false;save() end end end)
UIS.InputChanged:Connect(function(i) if not slOn then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X) end end)
lb(fpC,{Position=UDim2.fromOffset(5,53),Size=UDim2.fromOffset(FP_W-10,9),Text="91% = best  |  good fps required",TextSize=7,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})

local divFP=Instance.new("Frame",fpC)  -- created directly, no FindFirstChild hack
divFP.Size=UDim2.new(1,-10,0,1); divFP.Position=UDim2.fromOffset(5,65); divFP.BackgroundColor3=T.str; divFP.BackgroundTransparency=0.72; divFP.BorderSizePixel=0

local potRow=Instance.new("Frame"); potRow.Size=UDim2.fromOffset(FP_W-10,21); potRow.Position=UDim2.fromOffset(5,70)
potRow.BackgroundColor3=T.surf; potRow.BackgroundTransparency=0.28; potRow.BorderSizePixel=0; potRow.Parent=fpC; co(potRow,6)
local potRS=ms(potRow,1,T.str,0.55)
local potL=lb(potRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-42,1,0),Text="Giant Potion",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local potTrack=Instance.new("Frame"); potTrack.Size=UDim2.fromOffset(25,12); potTrack.Position=UDim2.new(1,-29,0.5,-6); potTrack.BackgroundColor3=T.surf2; potTrack.BorderSizePixel=0; potTrack.Parent=potRow; co(potTrack,12)
local potK=Instance.new("Frame"); potK.Size=UDim2.fromOffset(8,8); potK.Position=UDim2.new(0,2,0.5,-4); potK.BackgroundColor3=T.a2; potK.BorderSizePixel=0; potK.Parent=potTrack; co(potK,8)
local potB=Instance.new("TextButton"); potB.Size=UDim2.new(1,0,1,0); potB.BackgroundTransparency=1; potB.Text=""; potB.Parent=potRow
local function updPot()
    TweenService:Create(potRow,TweenInfo.new(0.12),{BackgroundColor3=potionOn and Color3.fromRGB(12,12,20) or T.surf,BackgroundTransparency=potionOn and 0.15 or 0.28}):Play()
    TweenService:Create(potRS,TweenInfo.new(0.12),{Color=potionOn and T.a1 or T.str,Transparency=potionOn and 0.2 or 0.55}):Play()
    TweenService:Create(potTrack,TweenInfo.new(0.12),{BackgroundColor3=potionOn and T.a1 or T.surf2}):Play()
    TweenService:Create(potK,TweenInfo.new(0.12),{Position=potionOn and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=potionOn and T.white or T.a2}):Play()
    potL.TextColor3=potionOn and T.white or T.dim
end
updPot(); potB.MouseButton1Click:Connect(function() potionOn=not potionOn; Cfg.potionOn=potionOn; save(); updPot() end)

local rstBtn=btn(fpC,"Instant Reset",UDim2.fromOffset(FP_W-10,17),UDim2.fromOffset(5,95),Color3.fromRGB(40,6,6))
rstBtn.TextSize=8; rstBtn.TextColor3=T.red
do local s=rstBtn:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.red;s.Transparency=0.3 end end
rstBtn.MouseButton1Click:Connect(function() task.spawn(doReset) end)

-- PANEL C: Admin
local RCMDS={{cmd="ragdoll",icon="🤸"},{cmd="balloon",icon="🎈"},{cmd="tiny",icon="🐜"},{cmd="jail",icon="🔒"},{cmd="rocket",icon="🚀"}}
local IW2=16; local IH2=18; local IG2=2; local ITOT=#RCMDS*(IW2+IG2)-IG2
local CW2=AP_W-12; local CSTART=CW2-ITOT-3
local AP,_,apMin=mkP(0,AP_Y_DEF,AP_W,24,"Admin Panel",T.a2,"pos_AP")
local pScroll=Instance.new("ScrollingFrame"); pScroll.Size=UDim2.fromOffset(AP_W-8,0); pScroll.Position=UDim2.fromOffset(4,22)
pScroll.BackgroundColor3=T.bg; pScroll.BackgroundTransparency=0.65; pScroll.BorderSizePixel=0
pScroll.ScrollBarThickness=2; pScroll.ScrollBarImageColor3=T.a1; pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
pScroll.CanvasSize=UDim2.new(0,0,0,0); pScroll.Parent=AP; co(pScroll,4)
local pLayout=Instance.new("UIListLayout"); pLayout.Padding=UDim.new(0,2); pLayout.SortOrder=Enum.SortOrder.Name; pLayout.Parent=pScroll
Instance.new("UIPadding",pScroll).PaddingTop=UDim.new(0,2)
local apFolded=false
local function resAP()
    if apFolded then return end
    local ch=math.min(pLayout.AbsoluteContentSize.Y+4,120)
    pScroll.Size=UDim2.fromOffset(AP_W-8,ch); AP.Size=UDim2.fromOffset(AP_W,22+ch+3)
end
pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resAP)
apMin.MouseButton1Click:Connect(function()
    apFolded=not apFolded; apMin.Text=apFolded and "+" or "─"; pScroll.Visible=not apFolded
    if apFolded then TweenService:Create(AP,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,24)}):Play()
    else local ch=math.min(pLayout.AbsoluteContentSize.Y+4,120); TweenService:Create(AP,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,22+ch+3)}):Play() end
end)
local pCards={}
local function refreshPlayers()
    for _,c in pairs(pCards) do pcall(function() c:Destroy() end) end; pCards={}; cmdBtnRefs={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame"); card.Name=p.Name; card.Size=UDim2.new(1,-4,0,30)
        card.BackgroundColor3=T.surf; card.BackgroundTransparency=0.26; card.BorderSizePixel=0; card.Parent=pScroll; co(card,5)
        local cs=ms(card,1,T.str,0.55)
        local cz=Instance.new("TextButton"); cz.Size=UDim2.fromOffset(CSTART,30); cz.BackgroundTransparency=1; cz.Text=""; cz.AutoButtonColor=false; cz.Parent=card
        local ava=Instance.new("ImageLabel"); ava.Size=UDim2.fromOffset(18,18); ava.Position=UDim2.new(0,3,0.5,-9); ava.BackgroundColor3=T.surf2; ava.BorderSizePixel=0; ava.Parent=card; co(ava,9)
        task.spawn(function() local ok,img=pcall(Players.GetUserThumbnailAsync,Players,p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48); if ok then ava.Image=img end end)
        lb(card,{Position=UDim2.new(0,23,0,3),Size=UDim2.fromOffset(CSTART-26,13),Text=p.DisplayName,TextSize=9,Font=Enum.Font.GothamBold,TextColor3=T.a1,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        lb(card,{Position=UDim2.new(0,23,0,16),Size=UDim2.fromOffset(CSTART-26,10),Text="@"..p.Name,TextSize=7,Font=Enum.Font.Gotham,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        cmdBtnRefs[p.UserId]={}
        for i,def in ipairs(RCMDS) do
            local bx=CSTART+3+(i-1)*(IW2+IG2)
            local ib=Instance.new("TextButton"); ib.Size=UDim2.fromOffset(IW2,IH2); ib.Position=UDim2.new(0,bx,0.5,-IH2/2)
            ib.BackgroundColor3=T.surf2; ib.BackgroundTransparency=0.22; ib.Text=def.icon; ib.TextSize=11; ib.TextColor3=T.a1
            ib.Font=Enum.Font.GothamBold; ib.BorderSizePixel=0; ib.AutoButtonColor=false; ib.Parent=card; co(ib,4); ms(ib,1,T.str,0.52)
            cmdBtnRefs[p.UserId][def.cmd]=ib
            local pd=p; local dc=def.cmd
            ib.MouseButton1Click:Connect(function() fireCmd(pd,dc) end)
        end
        local pd=p
        cz.MouseButton1Click:Connect(function()
            for _,c2 in pairs(pCards) do local s2=c2:FindFirstChildOfClass("UIStroke"); if s2 then s2.Color=T.str;s2.Transparency=0.55 end; c2.BackgroundTransparency=0.26 end
            cs.Color=T.a1; cs.Transparency=0; card.BackgroundTransparency=0
            fireClick(pd)
        end)
        pCards[p.UserId]=card
    end
    task.defer(resAP)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshPlayers() end)
task.delay(2,refreshPlayers)

-- PANEL D: Base Protector (5 pills)
local BP,_,bpMin=mkP(0,0,BP_W,BP_H,"Base Protector",T.a1,"pos_BP")
local bpC=mkF(BP,21,BP_CH,bpMin); local pyy=4
local function bpRow(label,col) local pb,set=pillR(bpC,label,pyy,col); pyy=pyy+23; return pb,set end
local asB,asSet=bpRow("ANTI STEAL",T.a1); asB.MouseButton1Click:Connect(function() antiSteal=not antiSteal; asSet(antiSteal) end)
local akB,akSet=bpRow("AUTO KICK",T.red); akB.MouseButton1Click:Connect(function() autoKick=not autoKick; akSet(autoKick) end)
local aiB,aiSet=bpRow("ANTI INTRUDER",T.a2); aiB.MouseButton1Click:Connect(function() antiIntruder=not antiIntruder; aiSet(antiIntruder) end)
local atB,atSet=bpRow("ANTI TP",T.a2); atB.MouseButton1Click:Connect(function() antiTp=not antiTp; atSet(antiTp) end)
-- Anti-ragdoll always runs in background, this pill just shows status
local arB,arSet=bpRow("ANTI RAGDOLL ✓",T.grn); arSet(true)  -- always on, show as green
arB.MouseButton1Click:Connect(function()
    -- Toggle still available in case user wants to disable
    if arConn then
        arConn:Disconnect(); arConn=nil; arSet(false)
        local rl=arB.Parent:FindFirstChild("TextLabel"); -- get pill label
    else
        startAntiRagdoll(); arSet(true)
    end
end)

-- PANEL E: Speed Boost
local SP,_,spMin=mkP(6,LP_H+48+6,SP_W,SP_H,"Speed Boost",T.a1,"pos_SP")
local spC=mkF(SP,21,SP_CH,spMin); local sy=4
local ssB,ssSet=pillR(spC,"Steal Speed",sy,T.grn); sy=sy+23
ssB.MouseButton1Click:Connect(function()
    stealSpdOn=not stealSpdOn; isStealing=stealSpdOn; speedEnabled=stealSpdOn
    ssSet(stealSpdOn); Cfg.stealSpdOn=stealSpdOn; save()
end)
if stealSpdOn then ssSet(true); isStealing=true; speedEnabled=true end
numRow(spC,"Speed",STEAL_SPD_VAL,10,60,sy,SP_W,function(v) STEAL_SPD_VAL=v; stealingSpeed=v; Cfg.stealSpdVal=v; save() end)

-- Reset Panels confirm popup
rsPnlBtn.MouseButton1Click:Connect(function()
    local popup=Instance.new("Frame",SG); popup.Size=UDim2.fromOffset(188,62); popup.Position=UDim2.new(0.5,-94,0.38,-31)
    popup.BackgroundColor3=T.panel; popup.BackgroundTransparency=0.08; popup.BorderSizePixel=0; co(popup,10); ms(popup,1.5,T.a1,0.18)
    lb(popup,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,4),Text="Reset panels to defaults?",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=T.a1})
    local yesB=btn(popup,"Yes",UDim2.fromOffset(76,22),UDim2.fromOffset(10,36),Color3.fromRGB(14,40,14)); yesB.TextColor3=T.grn
    local noB=btn(popup,"No",UDim2.fromOffset(76,22),UDim2.fromOffset(102,36),Color3.fromRGB(40,8,8)); noB.TextColor3=T.red
    noB.MouseButton1Click:Connect(function() popup:Destroy() end)
    yesB.MouseButton1Click:Connect(function()
        local dfp={ox=math.floor(vp.X-FP_W-5),oy=5}
        local dap={ox=math.floor(vp.X-AP_W-5),oy=AP_Y_DEF}
        local dbp={ox=math.floor(vp.X*0.5-BP_W*0.5),oy=math.floor(vp.Y*0.5-BP_H*0.5)}
        local dsp={ox=6,oy=LP_H+48+6}
        local defs={pos_LP={ox=6,oy=48},pos_FP=dfp,pos_AP=dap,pos_BP=dbp,pos_SP=dsp}
        for k,v in pairs(defs) do Cfg[k]=v end; save()
        LP.Position=UDim2.fromOffset(6,48); FP.Position=UDim2.fromOffset(dfp.ox,dfp.oy)
        AP.Position=UDim2.fromOffset(dap.ox,dap.oy); BP.Position=UDim2.fromOffset(dbp.ox,dbp.oy)
        SP.Position=UDim2.fromOffset(dsp.ox,dsp.oy); popup:Destroy()
    end)
end)

print("Phantom Flash V5 | Made By r9qbx on discord")
