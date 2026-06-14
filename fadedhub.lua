-- VertexHub | r9qbx discord
pcall(function() setfpscap(9999) end)
if not game:IsLoaded() then game.Loaded:Wait() end

local UIS=game:GetService("UserInputService")
local TweenSvc=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService")
local RunSvc=game:GetService("RunService")
local TeleSvc=game:GetService("TeleportService")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local CoreGui=game:GetService("CoreGui")
local HttpSvc=game:GetService("HttpService")
local Debris=game:GetService("Debris")

local lp=Players.LocalPlayer
local cam=workspace.CurrentCamera
if not lp.Character then lp.CharacterAdded:Wait() end

local CFG="VertexHub_cfg.json"
local Cfg={
    flashOn=false,autoPotionOn=false,triggerChance=91,
    speedOn=false,speedVal=27,giantSpeedVal=40,
    infiniteJump=false,autoKickOn=false,
    antiStealOn=false,antiIntruderOn=false,
    antiRagdollOn=true,antiAdminOn=true,antiSentryOn=true,antiBeeOn=true,
    aimbotOn=false,
    pos={},
}
pcall(function()
    if not readfile then return end
    local r=readfile(CFG); if not r or r=="" then return end
    local ok,t=pcall(HttpSvc.JSONDecode,HttpSvc,r)
    if ok and type(t)=="table" then for k,v in pairs(t) do Cfg[k]=v end end
end)
local function save() pcall(function() if writefile then writefile(CFG,HttpSvc:JSONEncode(Cfg)) end end) end

for _,n in ipairs({"VertexHub","TokinuHub","TokinuHelper","TokinuBoosterGUI"}) do
    for _,p in ipairs({CoreGui,lp.PlayerGui}) do local g=p:FindFirstChild(n); if g then g:Destroy() end end
end

-- CHANGED: new color scheme blue/purple
local C={
    bg=Color3.fromRGB(8,8,14),
    panel=Color3.fromRGB(12,12,20),
    surf=Color3.fromRGB(20,20,32),
    surf2=Color3.fromRGB(30,30,46),
    accent=Color3.fromRGB(80,100,255),
    accentB=Color3.fromRGB(110,130,255),
    white=Color3.fromRGB(235,235,240),
    dim=Color3.fromRGB(100,100,130),
    str=Color3.fromRGB(50,50,75),
    red=Color3.fromRGB(220,50,50),
    grn=Color3.fromRGB(52,218,88),
    gold=Color3.fromRGB(255,190,40),
    blue=Color3.fromRGB(80,160,255),
    purple=Color3.fromRGB(140,80,255),
    cyan=Color3.fromRGB(50,200,220),
}

local TI=TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local function tw(o,p) TweenSvc:Create(o,TI,p):Play() end
local function co(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p end
local function stk(p,th,col,tr)
    local s=Instance.new("UIStroke"); s.Thickness=th or 1; s.Color=col or C.str
    s.Transparency=tr or 0.4; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s
end
local function lbl(par,props)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold; l.TextColor3=C.white; l.BorderSizePixel=0
    for k,v in pairs(props) do l[k]=v end; l.Parent=par; return l
end
local function mkBtn(par,text,sz,pos,bg,tc)
    local b=Instance.new("TextButton"); b.Size=sz; b.Position=pos
    b.BackgroundColor3=bg or C.surf; b.BackgroundTransparency=0.15
    b.Text=text; b.TextColor3=tc or C.white; b.Font=Enum.Font.GothamBold
    b.TextSize=10; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=par
    co(b,8); return b
end

local function dragF(frame,hdr,key)
    local on,ds,sp=false,nil,nil
    hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            on=true; ds=i.Position; sp=frame.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then
                    on=false
                    if key then if not Cfg.pos then Cfg.pos={} end
                        Cfg.pos[key]={x=math.floor(frame.Position.X.Offset),y=math.floor(frame.Position.Y.Offset)}; save()
                    end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not on then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds; frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end
local function loadPos(key,frame)
    local p=Cfg.pos and Cfg.pos[key]; if p then frame.Position=UDim2.fromOffset(p.x,p.y) end
end

local function pillRow(parent,label,onCol)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-8,0,20)
    row.BackgroundColor3=C.surf; row.BackgroundTransparency=0.28; row.BorderSizePixel=0; row.Parent=parent; co(row,6)
    local rs=stk(row,1,C.str,0.55)
    local rl=lbl(row,{Position=UDim2.new(0,6,0,0);Size=UDim2.new(1,-38,1,0);Text=label;TextSize=8;TextColor3=C.dim;TextXAlignment=Enum.TextXAlignment.Left})
    local track=Instance.new("Frame"); track.Size=UDim2.fromOffset(25,12); track.Position=UDim2.new(1,-29,0.5,-6)
    track.BackgroundColor3=C.surf2; track.BorderSizePixel=0; track.Parent=row; co(track,12)
    local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(8,8); knob.Position=UDim2.new(0,2,0.5,-4)
    knob.BackgroundColor3=C.dim; knob.BorderSizePixel=0; knob.Parent=track; co(knob,8)
    local pb=Instance.new("TextButton"); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1; pb.Text=""; pb.Parent=row
    local col=onCol or C.accent; local isOn=false
    local function set(v) isOn=v
        TweenSvc:Create(track,TweenInfo.new(0.12),{BackgroundColor3=v and col or C.surf2}):Play()
        TweenSvc:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=v and C.white or C.dim}):Play()
        TweenSvc:Create(rs,TweenInfo.new(0.12),{Color=v and col or C.str,Transparency=v and 0.18 or 0.55}):Play()
        rl.TextColor3=v and C.white or C.dim
    end
    return pb,set,function() return isOn end
end

-- ScreenGui
local SG=Instance.new("ScreenGui"); SG.Name="VertexHub"
SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Global; SG.IgnoreGuiInset=true
if not pcall(function() SG.Parent=CoreGui end) then SG.Parent=lp:WaitForChild("PlayerGui") end

local function makePanel(name,w,h,col,defX,defY,key)
    local f=Instance.new("Frame"); f.Size=UDim2.fromOffset(w,h); f.Position=UDim2.fromOffset(defX,defY)
    f.BackgroundColor3=C.panel; f.BackgroundTransparency=0.22; f.BorderSizePixel=0; f.ClipsDescendants=true; f.Parent=SG; co(f,9)
    stk(f,1.2,col or C.str,0.35)
    local hdr=Instance.new("Frame"); hdr.Size=UDim2.new(1,0,0,20); hdr.BackgroundColor3=C.surf
    hdr.BackgroundTransparency=0.18; hdr.BorderSizePixel=0; hdr.Parent=f; co(hdr,9)
    local hf=Instance.new("Frame"); hf.Size=UDim2.new(1,0,0,6); hf.Position=UDim2.new(0,0,1,-6)
    hf.BackgroundColor3=C.surf; hf.BackgroundTransparency=0.18; hf.BorderSizePixel=0; hf.Parent=hdr
    if name then lbl(hdr,{Position=UDim2.new(0,7,0,0);Size=UDim2.new(1,-24,1,0);Text=name;TextSize=8;Font=Enum.Font.GothamBlack;TextXAlignment=Enum.TextXAlignment.Left;TextColor3=col or C.dim}) end
    local mb=mkBtn(hdr,"─",UDim2.fromOffset(14,13),UDim2.new(1,-17,0.5,-6.5),C.surf2,C.dim); mb.TextSize=8; mb.BackgroundTransparency=0.6
    local content=Instance.new("Frame"); content.Size=UDim2.new(1,0,0,h-20)
    content.Position=UDim2.fromOffset(0,20); content.BackgroundTransparency=1; content.BorderSizePixel=0; content.Parent=f
    local layout=Instance.new("UIListLayout",content); layout.Padding=UDim.new(0,4)
    layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    Instance.new("UIPadding",content).PaddingTop=UDim.new(0,4)
    local folded=false
    mb.MouseButton1Click:Connect(function()
        folded=not folded; mb.Text=folded and "+" or "─"
        TweenSvc:Create(f,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(w,folded and 20 or h)}):Play()
    end)
    if key then dragF(f,hdr,key); loadPos(key,f) end
    return f,content,hdr,mb,layout
end

-- FPS/Ping
local fpsF=Instance.new("Frame",SG); fpsF.Size=UDim2.fromOffset(120,16)
fpsF.Position=UDim2.new(0,4,1,-22); fpsF.BackgroundColor3=C.panel; fpsF.BackgroundTransparency=0.35; fpsF.BorderSizePixel=0; co(fpsF,5)
stk(fpsF,1,C.str,0.5)
local fpsLb=lbl(fpsF,{Size=UDim2.new(1,0,1,0);Text="FPS --  ·  PING -- ms";TextSize=8;TextColor3=C.dim})
local lastDt=1/60
RunSvc.RenderStepped:Connect(function(dt) lastDt=dt end)
task.spawn(function() while task.wait(0.8) do
    if not fpsLb.Parent then break end
    local fps=math.min(999,math.floor(1/math.max(lastDt,0.001))); local ping=0
    pcall(function() ping=math.floor(lp:GetNetworkPing()*1000) end)
    fpsLb.Text="FPS "..fps.."  ·  "..ping.."ms"
    fpsLb.TextColor3=fps<40 and C.red or fps<55 and C.gold or C.grn
end end)

-- CHANGED: reset panels button now shows confirm dialog
local rsPnlBtn=mkBtn(SG,"Reset Panels",UDim2.fromOffset(80,12),UDim2.new(0.5,-40,0,4),C.panel,C.dim)
rsPnlBtn.TextSize=7; rsPnlBtn.BackgroundTransparency=0.5

-- ════════════════════════════════════════════════════════════════════
-- MAIN PANEL
-- ════════════════════════════════════════════════════════════════════
local MP_W=190
local mainF=Instance.new("Frame"); mainF.Size=UDim2.fromOffset(MP_W,0)
mainF.AutomaticSize=Enum.AutomaticSize.Y
mainF.Position=UDim2.new(0.5,-MP_W/2,0.5,-160); mainF.BackgroundColor3=C.panel
mainF.BackgroundTransparency=0.18; mainF.BorderSizePixel=0; mainF.Parent=SG; mainF.ClipsDescendants=false
co(mainF,12); stk(mainF,1.4,C.accent,0.3); loadPos("main",mainF)
local mainLayout=Instance.new("UIListLayout",mainF); mainLayout.Padding=UDim.new(0,0); mainLayout.SortOrder=Enum.SortOrder.LayoutOrder

local hdrPill=Instance.new("Frame"); hdrPill.Size=UDim2.new(1,-16,0,44); hdrPill.LayoutOrder=1
hdrPill.BackgroundColor3=C.surf; hdrPill.BackgroundTransparency=0.12; hdrPill.BorderSizePixel=0; hdrPill.Parent=mainF
Instance.new("UIPadding",hdrPill).PaddingLeft=UDim.new(0,8); co(hdrPill,12)
local titleLbl=lbl(hdrPill,{Position=UDim2.new(0,0,0,0);Size=UDim2.new(1,-46,1,0);Text="FLASH GRAB";TextSize=15;Font=Enum.Font.GothamBlack;TextColor3=C.accent;TextXAlignment=Enum.TextXAlignment.Left})
local settingsBtn=Instance.new("TextButton"); settingsBtn.Size=UDim2.fromOffset(34,34)
settingsBtn.Position=UDim2.new(1,-42,0.5,-17); settingsBtn.BackgroundColor3=C.surf2
settingsBtn.BackgroundTransparency=0.1; settingsBtn.Text="⚙"; settingsBtn.TextSize=16
settingsBtn.TextColor3=C.white; settingsBtn.Font=Enum.Font.GothamBold
settingsBtn.BorderSizePixel=0; settingsBtn.AutoButtonColor=false; settingsBtn.Parent=hdrPill; co(settingsBtn,10)
dragF(mainF,hdrPill,"main")

local mainContent=Instance.new("Frame"); mainContent.Size=UDim2.new(1,0,0,0)
mainContent.AutomaticSize=Enum.AutomaticSize.Y; mainContent.BackgroundTransparency=1
mainContent.BorderSizePixel=0; mainContent.LayoutOrder=2; mainContent.Parent=mainF
local mcLayout=Instance.new("UIListLayout",mainContent); mcLayout.Padding=UDim.new(0,5)
mcLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
local mcPad=Instance.new("UIPadding",mainContent); mcPad.PaddingLeft=UDim.new(0,8); mcPad.PaddingRight=UDim.new(0,8); mcPad.PaddingTop=UDim.new(0,6); mcPad.PaddingBottom=UDim.new(0,6)

local potBtn,potSet=pillRow(mainContent,"Auto Potion",C.accent)
local autoPotionOn=Cfg.autoPotionOn; potSet(autoPotionOn)
potBtn.MouseButton1Click:Connect(function() autoPotionOn=not autoPotionOn; Cfg.autoPotionOn=autoPotionOn; save(); potSet(autoPotionOn) end)

local akBtn,akSet=pillRow(mainContent,"Auto Kick",C.red)
local autoKickOn=Cfg.autoKickOn; akSet(autoKickOn)
akBtn.MouseButton1Click:Connect(function() autoKickOn=not autoKickOn; Cfg.autoKickOn=autoKickOn; save(); akSet(autoKickOn) end)

local alignBtn=mkBtn(mainContent,"ALIGN CAMERA",UDim2.new(1,0,0,22),UDim2.new(0,0,0,0),C.surf2,C.dim)
alignBtn.TextSize=9

local divLine=Instance.new("Frame",mainContent); divLine.Size=UDim2.new(1,0,0,1)
divLine.BackgroundColor3=C.str; divLine.BackgroundTransparency=0.7; divLine.BorderSizePixel=0

local trigLbl=lbl(mainContent,{Size=UDim2.new(1,0,0,14);Text="Trigger: "..Cfg.triggerChance.."%";TextSize=9;TextColor3=C.dim;TextXAlignment=Enum.TextXAlignment.Left})

local slWrap=Instance.new("Frame",mainContent); slWrap.Size=UDim2.new(1,0,0,16)
slWrap.BackgroundTransparency=1; slWrap.BorderSizePixel=0
local slBack=Instance.new("Frame",slWrap); slBack.Size=UDim2.new(1,0,0,6); slBack.Position=UDim2.new(0,0,0.5,-3)
slBack.BackgroundColor3=C.surf2; slBack.BorderSizePixel=0; co(slBack,3)
local slFill=Instance.new("Frame",slBack); slFill.Size=UDim2.new(Cfg.triggerChance/100,0,1,0)
slFill.BackgroundColor3=C.accent; slFill.BorderSizePixel=0; co(slFill,3)
local slDot=Instance.new("Frame",slBack); slDot.Size=UDim2.fromOffset(14,14)
slDot.AnchorPoint=Vector2.new(0.5,0.5); slDot.Position=UDim2.new(Cfg.triggerChance/100,0,0.5,0)
slDot.BackgroundColor3=C.white; slDot.BorderSizePixel=0; co(slDot,7)
stk(slDot,1.5,C.accent,0)

local sliderValue=Cfg.triggerChance/100; local manualOverride=false; local slDragging=false
local function setSlider(px)
    local rel=math.clamp((px-slBack.AbsolutePosition.X)/math.max(slBack.AbsoluteSize.X,1),0,1)
    manualOverride=true; sliderValue=rel; Cfg.triggerChance=math.floor(rel*100); save()
    slFill.Size=UDim2.new(rel,0,1,0); slDot.Position=UDim2.new(rel,0,0.5,0)
    trigLbl.Text="Trigger: "..math.floor(rel*100).."%"
end
slBack.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slDragging=true; setSlider(i.Position.X) end
end)
slDot.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slDragging=true end
end)
UIS.InputChanged:Connect(function(i)
    if slDragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setSlider(i.Position.X) end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slDragging=false end
end)

local grabProgress=Instance.new("Frame",mainContent); grabProgress.Size=UDim2.new(1,0,0,8)
grabProgress.BackgroundColor3=C.surf2; grabProgress.BorderSizePixel=0; grabProgress.Visible=false; co(grabProgress,4)
local grabFill=Instance.new("Frame",grabProgress); grabFill.Size=UDim2.new(0,0,1,0)
grabFill.BackgroundColor3=C.accent; grabFill.BorderSizePixel=0; co(grabFill,4)

local bigBtn=mkBtn(mainContent,"FLASH GRAB",UDim2.new(1,0,0,44),UDim2.new(0,0,0,0),C.accent,C.white)
bigBtn.TextSize=15; bigBtn.Font=Enum.Font.GothamBlack

-- Settings content
local settingsContent=Instance.new("Frame"); settingsContent.Size=UDim2.new(1,0,0,0)
settingsContent.AutomaticSize=Enum.AutomaticSize.Y; settingsContent.BackgroundTransparency=1
settingsContent.BorderSizePixel=0; settingsContent.LayoutOrder=3; settingsContent.Parent=mainF
settingsContent.Visible=false
local scLayout=Instance.new("UIListLayout",settingsContent); scLayout.Padding=UDim.new(0,5)
scLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
local scPad=Instance.new("UIPadding",settingsContent); scPad.PaddingLeft=UDim.new(0,8); scPad.PaddingRight=UDim.new(0,8)
scPad.PaddingTop=UDim.new(0,6); scPad.PaddingBottom=UDim.new(0,8)

local function secLbl(txt)
    local f=Instance.new("Frame",settingsContent); f.Size=UDim2.new(1,0,0,16); f.BackgroundTransparency=1; f.BorderSizePixel=0
    lbl(f,{Size=UDim2.new(1,0,1,0);Text=txt;TextSize=8;Font=Enum.Font.GothamBlack;TextColor3=C.accent;TextXAlignment=Enum.TextXAlignment.Left})
end

secLbl("SPEED BOOST")
local spBtn,spSet=pillRow(settingsContent,"Speed Boost",C.accent)
local speedOn=Cfg.speedOn; spSet(speedOn)
local spValF=Instance.new("Frame",settingsContent); spValF.Size=UDim2.new(1,0,0,26)
spValF.BackgroundColor3=C.surf; spValF.BackgroundTransparency=0.28; spValF.BorderSizePixel=0; co(spValF,7)
lbl(spValF,{Position=UDim2.new(0,8,0,0);Size=UDim2.new(0.5,0,1,0);Text="Speed";TextSize=9;TextColor3=C.dim;TextXAlignment=Enum.TextXAlignment.Left})
local spBox=Instance.new("TextBox",spValF); spBox.Size=UDim2.new(0.45,0,0.75,0); spBox.Position=UDim2.new(0.52,0,0.125,0)
spBox.BackgroundColor3=C.surf2; spBox.BackgroundTransparency=0.2; spBox.Text=tostring(Cfg.speedVal); spBox.TextColor3=C.white
spBox.Font=Enum.Font.GothamBold; spBox.TextSize=10; spBox.ClearTextOnFocus=false; spBox.BorderSizePixel=0; co(spBox,5)

secLbl("GIANT POTION")
local gpValF=Instance.new("Frame",settingsContent); gpValF.Size=UDim2.new(1,0,0,26)
gpValF.BackgroundColor3=C.surf; gpValF.BackgroundTransparency=0.28; gpValF.BorderSizePixel=0; co(gpValF,7)
lbl(gpValF,{Position=UDim2.new(0,8,0,0);Size=UDim2.new(0.5,0,1,0);Text="Potion Spd";TextSize=9;TextColor3=C.dim;TextXAlignment=Enum.TextXAlignment.Left})
local gpBox=Instance.new("TextBox",gpValF); gpBox.Size=UDim2.new(0.45,0,0.75,0); gpBox.Position=UDim2.new(0.52,0,0.125,0)
gpBox.BackgroundColor3=C.surf2; gpBox.BackgroundTransparency=0.2; gpBox.Text=tostring(Cfg.giantSpeedVal); gpBox.TextColor3=C.white
gpBox.Font=Enum.Font.GothamBold; gpBox.TextSize=10; gpBox.ClearTextOnFocus=false; gpBox.BorderSizePixel=0; co(gpBox,5)

secLbl("MISC")
local ijBtn,ijSet=pillRow(settingsContent,"Infinite Jump",C.grn)
local ijOn=Cfg.infiniteJump; ijSet(ijOn)
local aimbotBtn,aimbotSet=pillRow(settingsContent,"Aimbot",C.blue)
local aimbotOn=Cfg.aimbotOn; aimbotSet(aimbotOn)

secLbl("PROTECTION")
local arBtn,arSet=pillRow(settingsContent,"Anti Ragdoll",C.accent)
local antiRagdollOn=Cfg.antiRagdollOn; arSet(antiRagdollOn)
local aapBtn,aapSet=pillRow(settingsContent,"Anti Admin Panel",C.accent)
local antiAdminOn=Cfg.antiAdminOn; aapSet(antiAdminOn)
local asBtn2,asSet2=pillRow(settingsContent,"Anti Sentry",C.accent)
local antiSentryOn=Cfg.antiSentryOn; asSet2(antiSentryOn)
local abBtn,abSet=pillRow(settingsContent,"Anti Beehive",C.gold)
local antiBeeOn=Cfg.antiBeeOn; abSet(antiBeeOn)

local settingsOpen=false
settingsBtn.MouseButton1Click:Connect(function()
    settingsOpen=not settingsOpen
    mainContent.Visible=not settingsOpen
    settingsContent.Visible=settingsOpen
    settingsBtn.Text=settingsOpen and "✕" or "⚙"
    titleLbl.Text=settingsOpen and "Settings" or "FLASH GRAB"
end)

-- CHANGED: speed boost toggle properly starts/stops boost
local boostConn=nil
local currentSpeed=Cfg.speedVal
local function startBoost(spd)
    if boostConn then boostConn:Disconnect(); boostConn=nil end
    boostConn=RunSvc.Heartbeat:Connect(function()
        local char=lp.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if hum.MoveDirection.Magnitude>0 then
            local d=Vector3.new(hum.MoveDirection.X,0,hum.MoveDirection.Z).Unit
            hrp.Velocity=Vector3.new(d.X*spd,hrp.Velocity.Y,d.Z*spd)
        end
    end)
end
local function stopBoost()
    if boostConn then boostConn:Disconnect(); boostConn=nil end
end

spBtn.MouseButton1Click:Connect(function()
    speedOn=not speedOn; Cfg.speedOn=speedOn; save(); spSet(speedOn)
    if speedOn then
        currentSpeed=math.clamp(tonumber(spBox.Text) or Cfg.speedVal,1,120)
        startBoost(currentSpeed)
    else
        stopBoost()
    end
end)

ijBtn.MouseButton1Click:Connect(function() ijOn=not ijOn; Cfg.infiniteJump=ijOn; save(); ijSet(ijOn) end)
aimbotBtn.MouseButton1Click:Connect(function() aimbotOn=not aimbotOn; Cfg.aimbotOn=aimbotOn; save(); aimbotSet(aimbotOn) end)
arBtn.MouseButton1Click:Connect(function() antiRagdollOn=not antiRagdollOn; Cfg.antiRagdollOn=antiRagdollOn; save(); arSet(antiRagdollOn) end)
aapBtn.MouseButton1Click:Connect(function() antiAdminOn=not antiAdminOn; Cfg.antiAdminOn=antiAdminOn; save(); aapSet(antiAdminOn) end)
asBtn2.MouseButton1Click:Connect(function() antiSentryOn=not antiSentryOn; Cfg.antiSentryOn=antiSentryOn; save(); asSet2(antiSentryOn) end)
abBtn.MouseButton1Click:Connect(function() antiBeeOn=not antiBeeOn; Cfg.antiBeeOn=antiBeeOn; save(); abSet(antiBeeOn) end)
spBox.FocusLost:Connect(function() local n=math.clamp(math.floor(tonumber(spBox.Text) or 27),1,120); spBox.Text=tostring(n); Cfg.speedVal=n; save() end)
gpBox.FocusLost:Connect(function() local n=math.clamp(math.floor(tonumber(gpBox.Text) or 40),1,120); gpBox.Text=tostring(n); Cfg.giantSpeedVal=n; save() end)

if speedOn then startBoost(currentSpeed) end

-- ════════════════════════════════════════════════════════════════════
-- CHANGED: ACTIONS PANEL (new, separate)
-- ════════════════════════════════════════════════════════════════════
local actF,actC=makePanel("Actions",148,72,C.purple,10,10,"actions")
local rejBtn=mkBtn(actC,"REJOIN",UDim2.new(1,-8,0,20),UDim2.new(0,0,0,0),C.surf2,C.white); rejBtn.TextSize=9
local kickBtn=mkBtn(actC,"KICK SELF",UDim2.new(1,-8,0,20),UDim2.new(0,0,0,0),C.surf2,C.red); kickBtn.TextSize=9
rejBtn.MouseButton1Click:Connect(function()
    rejBtn.Text=".."; lp:Kick("rejoining")
    task.delay(0.1,function() TeleSvc:Teleport(game.PlaceId,lp) end)
end)
kickBtn.MouseButton1Click:Connect(function() lp:Kick("kicked by r9qbx") end)

-- ════════════════════════════════════════════════════════════════════
-- CHANGED: BASE PROTECTOR PANEL (new, separate) - Defense panel removed
-- Anti Steal + Anti Intruder moved here too
-- ════════════════════════════════════════════════════════════════════
local bpF,bpC=makePanel("Base Protector",148,106,C.cyan,10,90,"baseprot")
local bpBtn,bpSet=pillRow(bpC,"Base Protector",C.cyan)
local baseProtOn=false; bpSet(baseProtOn)
bpBtn.MouseButton1Click:Connect(function() baseProtOn=not baseProtOn; bpSet(baseProtOn) end)

local antiStealOn=Cfg.antiStealOn
local antiIntruderOn=Cfg.antiIntruderOn
local asBtn,asSet=pillRow(bpC,"Anti Steal",C.red)
asSet(antiStealOn)
local aiBtn,aiSet=pillRow(bpC,"Anti Intruder",C.gold)
aiSet(antiIntruderOn)
asBtn.MouseButton1Click:Connect(function() antiStealOn=not antiStealOn; Cfg.antiStealOn=antiStealOn; save(); asSet(antiStealOn) end)
aiBtn.MouseButton1Click:Connect(function() antiIntruderOn=not antiIntruderOn; Cfg.antiIntruderOn=antiIntruderOn; save(); aiSet(antiIntruderOn) end)

-- ════════════════════════════════════════════════════════════════════
-- ADMIN PANEL (unchanged from original)
-- ════════════════════════════════════════════════════════════════════
local AP_W=186
local AP=Instance.new("Frame"); AP.Size=UDim2.fromOffset(AP_W,22)
AP.Position=UDim2.fromOffset(10,204); AP.BackgroundColor3=C.panel; AP.BackgroundTransparency=0.22
AP.BorderSizePixel=0; AP.ClipsDescendants=true; AP.Parent=SG; co(AP,9)
stk(AP,1.2,C.str,0.35); loadPos("ap",AP)

local apHdr=Instance.new("Frame"); apHdr.Size=UDim2.new(1,0,0,21); apHdr.BackgroundColor3=C.surf
apHdr.BackgroundTransparency=0.18; apHdr.BorderSizePixel=0; apHdr.Parent=AP; co(apHdr,9)
local apHf=Instance.new("Frame",apHdr); apHf.Size=UDim2.new(1,0,0,7); apHf.Position=UDim2.new(0,0,1,-7)
apHf.BackgroundColor3=C.surf; apHf.BackgroundTransparency=0.18; apHf.BorderSizePixel=0
lbl(apHdr,{Position=UDim2.new(0,7,0,0);Size=UDim2.new(1,-24,1,0);Text="Admin Panel";TextSize=8;Font=Enum.Font.GothamBlack;TextXAlignment=Enum.TextXAlignment.Left;TextColor3=C.dim})
local apMb=mkBtn(apHdr,"─",UDim2.fromOffset(14,13),UDim2.new(1,-17,0.5,-6.5),C.surf2,C.dim); apMb.TextSize=8; apMb.BackgroundTransparency=0.6
dragF(AP,apHdr,"ap")

local pScroll=Instance.new("ScrollingFrame"); pScroll.Size=UDim2.fromOffset(AP_W-8,0); pScroll.Position=UDim2.fromOffset(4,22)
pScroll.BackgroundColor3=C.bg; pScroll.BackgroundTransparency=0.65; pScroll.BorderSizePixel=0
pScroll.ScrollBarThickness=2; pScroll.ScrollBarImageColor3=C.accent; pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
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
apMb.MouseButton1Click:Connect(function()
    apFolded=not apFolded; apMb.Text=apFolded and "+" or "─"; pScroll.Visible=not apFolded
    if apFolded then TweenSvc:Create(AP,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,22)}):Play()
    else local ch=math.min(pLayout.AbsoluteContentSize.Y+4,120); TweenSvc:Create(AP,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(AP_W,22+ch+3)}):Play() end
end)

local ADM_REMOTE=nil; local ADM_UUID="f888ee6e-c86d-46e1-93d7-0639d6635d42"
local function bindAdmin()
    ADM_REMOTE=nil
    task.spawn(function()
        task.wait(1.5)
        pcall(function()
            local net=RS:WaitForChild("Packages",6):WaitForChild("Net",6); if not net then return end
            local ch=net:GetChildren(); local n2i={}
            for i,o in ipairs(ch) do n2i[o.Name]=i end
            local a=n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
            if a and ch[a+1] then ADM_REMOTE=ch[a+1] end
        end)
    end)
end
bindAdmin(); lp.CharacterAdded:Connect(function() bindAdmin() end)

local RCMDS={{cmd="ragdoll",icon="🏃"},{cmd="balloon",icon="🎈"},{cmd="tiny",icon="🐜"},{cmd="jail",icon="🔓"},{cmd="rocket",icon="🚀"}}
local ROW_CD={ragdoll=30,balloon=30,tiny=60,jail=60,rocket=120}
local rowCdEnd={}
local function aFire(tgt,cmd) task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,tgt,cmd) end) end) end
local CLICK_CMDS={"tiny","inverse","rocket","jumpscare"}
local function fireClick(tgt)
    if not ADM_REMOTE then return end
    for _,cmd in ipairs(CLICK_CMDS) do aFire(tgt,cmd); if ROW_CD[cmd] then rowCdEnd[cmd]=tick()+ROW_CD[cmd] end end
end

local IW2=16; local IH2=18; local IG2=2
local ITOT=#RCMDS*(IW2+IG2)-IG2; local CW2=AP_W-12; local CSTART=CW2-ITOT-3
local pCards={}; local cmdBtnRefs={}
local function refreshAP()
    for _,c in pairs(pCards) do pcall(function() c:Destroy() end) end; pCards={}; cmdBtnRefs={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame"); card.Name=p.Name; card.Size=UDim2.new(1,-4,0,30)
        card.BackgroundColor3=C.surf; card.BackgroundTransparency=0.26; card.BorderSizePixel=0; card.Parent=pScroll; co(card,5)
        local cs=stk(card,1,C.str,0.55)
        local cz=Instance.new("TextButton"); cz.Size=UDim2.fromOffset(CSTART,30); cz.BackgroundTransparency=1; cz.Text=""; cz.AutoButtonColor=false; cz.Parent=card
        local ava=Instance.new("ImageLabel"); ava.Size=UDim2.fromOffset(18,18); ava.Position=UDim2.new(0,3,0.5,-9); ava.BackgroundColor3=C.surf2; ava.BorderSizePixel=0; ava.Parent=card; co(ava,9)
        task.spawn(function() local ok,img=pcall(Players.GetUserThumbnailAsync,Players,p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48); if ok then ava.Image=img end end)
        lbl(card,{Position=UDim2.new(0,23,0,3);Size=UDim2.fromOffset(CSTART-26,13);Text=p.DisplayName;TextSize=9;Font=Enum.Font.GothamBold;TextColor3=C.dim;TextXAlignment=Enum.TextXAlignment.Left;TextTruncate=Enum.TextTruncate.AtEnd})
        lbl(card,{Position=UDim2.new(0,23,0,16);Size=UDim2.fromOffset(CSTART-26,10);Text="@"..p.Name;TextSize=7;Font=Enum.Font.Gotham;TextColor3=C.str;TextXAlignment=Enum.TextXAlignment.Left;TextTruncate=Enum.TextTruncate.AtEnd})
        cmdBtnRefs[p.UserId]={}
        for i,def in ipairs(RCMDS) do
            local bx=CSTART+3+(i-1)*(IW2+IG2)
            local ib=Instance.new("TextButton"); ib.Size=UDim2.fromOffset(IW2,IH2); ib.Position=UDim2.new(0,bx,0.5,-IH2/2)
            ib.BackgroundColor3=C.surf2; ib.BackgroundTransparency=0.22; ib.Text=def.icon; ib.TextSize=11; ib.TextColor3=C.dim
            ib.Font=Enum.Font.GothamBold; ib.BorderSizePixel=0; ib.AutoButtonColor=false; ib.Parent=card; co(ib,4); stk(ib,1,C.str,0.52)
            cmdBtnRefs[p.UserId][def.cmd]=ib
            local pd,dc=p,def.cmd
            ib.MouseButton1Click:Connect(function()
                if not ADM_REMOTE then return end; aFire(pd,dc); rowCdEnd[dc]=tick()+(ROW_CD[dc] or 30)
            end)
        end
        local pd=p
        cz.MouseButton1Click:Connect(function()
            for _,c2 in pairs(pCards) do local s2=c2:FindFirstChildOfClass("UIStroke"); if s2 then s2.Color=C.str;s2.Transparency=0.55 end; c2.BackgroundTransparency=0.26 end
            cs.Color=C.accent; cs.Transparency=0.1; card.BackgroundTransparency=0.1
            fireClick(pd)
        end)
        pCards[p.UserId]=card
    end
    task.defer(resAP)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshAP() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshAP() end)
lp.CharacterAdded:Connect(function() task.wait(2.5); refreshAP() end)
task.delay(2.5,refreshAP)

RunSvc.Heartbeat:Connect(function()
    local now=tick()
    for uid,cmds in pairs(cmdBtnRefs) do for cmd,ib in pairs(cmds) do
        if not ib or not ib.Parent then continue end
        local cd=rowCdEnd[cmd]
        if cd and cd>now then
            local r=tostring(math.ceil(cd-now))
            if ib.Text~=r then ib.Text=r; ib.TextSize=8; ib.TextColor3=C.red; ib.BackgroundColor3=Color3.fromRGB(40,5,5); ib.BackgroundTransparency=0.1 end
        else
            local icon; for _,d in ipairs(RCMDS) do if d.cmd==cmd then icon=d.icon; break end end
            if icon and ib.Text~=icon then ib.Text=icon; ib.TextSize=11; ib.TextColor3=C.dim; ib.BackgroundColor3=C.surf2; ib.BackgroundTransparency=0.22 end
        end
    end end
end)

-- CHANGED: Reset panels with confirm dialog
rsPnlBtn.MouseButton1Click:Connect(function()
    local dlg=Instance.new("Frame",SG)
    dlg.Size=UDim2.fromOffset(160,52); dlg.Position=UDim2.new(0.5,-80,0.5,-26)
    dlg.BackgroundColor3=C.panel; dlg.BackgroundTransparency=0.05; dlg.BorderSizePixel=0; co(dlg,10)
    stk(dlg,1.5,C.accent,0.2)
    lbl(dlg,{Position=UDim2.new(0,0,0,5);Size=UDim2.new(1,0,0,20);Text="Reset all panels?";TextSize=9;TextColor3=C.white;Font=Enum.Font.GothamBlack})
    local yb=mkBtn(dlg,"Yes",UDim2.fromOffset(62,20),UDim2.new(0,8,1,-26),C.accent,C.white); yb.TextSize=9
    local nb=mkBtn(dlg,"No",UDim2.fromOffset(62,20),UDim2.new(1,-70,1,-26),C.surf2,C.dim); nb.TextSize=9
    yb.MouseButton1Click:Connect(function()
        dlg:Destroy()
        mainF.Position=UDim2.new(0.5,-MP_W/2,0.5,-160)
        if not Cfg.pos then Cfg.pos={} end
        Cfg.pos["main"]={x=math.floor(mainF.Position.X.Offset),y=math.floor(mainF.Position.Y.Offset)}
        actF.Position=UDim2.fromOffset(10,10); Cfg.pos["actions"]={x=10,y=10}
        bpF.Position=UDim2.fromOffset(10,90); Cfg.pos["baseprot"]={x=10,y=90}
        AP.Position=UDim2.fromOffset(10,204); Cfg.pos["ap"]={x=10,y=204}
        save()
    end)
    nb.MouseButton1Click:Connect(function() dlg:Destroy() end)
end)

-- ════════════════════════════════════════════════════════════════════
-- CHANGED: FLASH GRAB - click only, holds steal prompt, fires flash at %
-- Original had PPS auto loop. Now: button click = grab sequence only
-- ════════════════════════════════════════════════════════════════════
local flashEnabled=Cfg.flashOn; local triggerBump=false; local activePrompts={}

local function getPingBase(p) if p<=30 then return 0.91 elseif p<=70 then return 0.92 elseif p<=120 then return 0.93 else return 0.94 end end
RunSvc.Heartbeat:Connect(function()
    if not manualOverride then
        local p=lp:GetNetworkPing()*1000; local base=getPingBase(p); local v=triggerBump and base+0.01 or base
        if math.abs(v-sliderValue)>0.005 then
            sliderValue=v; slFill.Size=UDim2.new(v,0,1,0); slDot.Position=UDim2.new(v,0,0.5,0); trigLbl.Text="Trigger: "..math.floor(v*100).."%"
        end
    end
end)

local StealCBs={}
local function buildCBs(prompt)
    if StealCBs[prompt] then return end
    local data={hold={},trig={}}
    if getconnections then
        pcall(function() for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end end)
        pcall(function() for _,c in ipairs(getconnections(prompt.Triggered)) do if type(c.Function)=="function" then table.insert(data.trig,c.Function) end end end)
    end
    if #data.hold>0 or #data.trig>0 then StealCBs[prompt]=data end
end
local function fireCBs(prompt)
    local d=StealCBs[prompt]; if not d then return end
    for _,fn in ipairs(d.hold) do task.spawn(fn) end
    task.wait(0.05); for _,fn in ipairs(d.trig) do task.spawn(fn) end
end

local function getPromptPos(pr)
    local p=pr.Parent
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    if p:IsA("Model") then local r=p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart"); return r and r.Position end
    local pt=p:FindFirstChildWhichIsA("BasePart",true); return pt and pt.Position
end
local function findNearestSteal()
    local char=lp.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"); if not hrp then return nil end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local myPos=hrp.Position; local nearest,nd=nil,math.huge
    for _,plot in ipairs(plots:GetChildren()) do
        local sign=plot:FindFirstChild("PlotSign")
        if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then continue end
        for _,obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and (obj.ActionText or ""):find("Steal") then
                local pos=getPromptPos(obj); if pos then
                    local d=(myPos-pos).Magnitude
                    if d<=math.max(obj.MaxActivationDistance,8) and d<nd then nearest=obj; nd=d end
                end
            end
        end
    end
    return nearest
end

local function equipFlash()
    pcall(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        for _,n in ipairs({"Flash Teleport","Flash","FlashTP","Flash TP"}) do
            local t=char:FindFirstChild(n) or (lp.Backpack and lp.Backpack:FindFirstChild(n))
            if t then if t.Parent~=char then hum:EquipTool(t) end; return end
        end
    end)
end

-- CHANGED: big button = click to start grab sequence, NOT always-on auto loop
local grabActive=false
bigBtn.MouseButton1Click:Connect(function()
    if grabActive then return end
    tw(bigBtn,{BackgroundColor3=C.accentB})
    task.delay(0.2,function() tw(bigBtn,{BackgroundColor3=C.accent}) end)

    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return end

    pcall(equipFlash); task.wait(0.05)

    if autoPotionOn then
        local bp=lp:FindFirstChild("Backpack")
        local giant=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion"))
        if giant then giant.Parent=char; task.spawn(function() giant:Activate() end) end
    end

    local prompt=findNearestSteal()
    if not prompt then return end

    grabActive=true
    grabProgress.Visible=true
    buildCBs(prompt)

    task.spawn(function()
        local holdDur=math.max(prompt.HoldDuration,0.001)
        local trigTime=holdDur*sliderValue
        local st=tick()
        local flashFired=false

        local data=StealCBs[prompt]
        if data and #data.hold>0 then
            for _,fn in ipairs(data.hold) do task.spawn(fn) end
        else
            pcall(function()
                prompt.MaxActivationDistance=math.huge
                prompt.RequiresLineOfSight=false
                prompt:InputHoldBegin()
            end)
        end

        -- hold loop: fire flash at trigger% of hold duration
        while tick()-st < holdDur+0.15 do
            local elapsed=tick()-st
            local pct=math.clamp(elapsed/holdDur,0,1)
            TweenSvc:Create(grabFill,TweenInfo.new(0.04),{Size=UDim2.new(pct,0,1,0)}):Play()

            if not flashFired and elapsed>=trigTime then
                flashFired=true
                triggerBump=not triggerBump
                local fc=lp.Character
                if fc then
                    local tool=fc:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
            task.wait()
        end

        if data and #data.trig>0 then
            for _,fn in ipairs(data.trig) do task.spawn(fn) end
        else
            pcall(function() prompt:InputHoldEnd() end)
        end

        grabFill.Size=UDim2.new(1,0,1,0)
        task.wait(0.1)
        grabProgress.Visible=false
        grabFill.Size=UDim2.new(0,0,1,0)
        grabActive=false
    end)
end)

-- Align Camera (unchanged from original)
local cfA=CFrame.new(-322.066,-7.871,111.991)*CFrame.Angles(0.332,-0.019,0.000)
local cfB=CFrame.new(-325.856,-7.866,113.027)*CFrame.Angles(0.327,3.130,0.000)
local lookA2=cfA.LookVector; local lookB2=cfB.LookVector; local desiredY=lookA2.Y
local function flattenV(v) local f=Vector3.new(v.X,0,v.Z); return f.Magnitude>0 and f.Unit or f end
local function buildLook(bl) local h2=flattenV(bl); local fs=math.sqrt(math.max(0,1-desiredY^2)); return Vector3.new(h2.X*fs,desiredY,h2.Z*fs) end
local function getBestLook()
    local cf=flattenV(cam.CFrame.LookVector)
    return cf:Dot(flattenV(lookA2))>cf:Dot(flattenV(lookB2)) and buildLook(lookA2) or buildLook(lookB2)
end
local camBusy=false
alignBtn.MouseButton1Click:Connect(function()
    if camBusy then return end; camBusy=true
    tw(alignBtn,{BackgroundColor3=C.accent})
    pcall(equipFlash); task.wait(0.05)
    pcall(function()
        local pos=cam.CFrame.Position; local best=getBestLook()
        cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=CFrame.lookAt(pos,pos+best)
        task.wait(); cam.CameraType=Enum.CameraType.Custom
    end)
    task.delay(0.8,function() tw(alignBtn,{BackgroundColor3=C.surf2}); camBusy=false end)
end)

-- ════════════════════════════════════════════════════════════════════
-- BACKGROUND SYSTEMS
-- ════════════════════════════════════════════════════════════════════

-- CHANGED: Giant potion - ragdoll fires INSTANTLY when potion used (HipHeight changes)
lp.CharacterAdded:Connect(function(c)
    local hum=c:WaitForChild("Humanoid"); task.wait(0.3)
    local baseH=hum.HipHeight; local gpActive=false; local gpPrev=currentSpeed
    hum:GetPropertyChangedSignal("HipHeight"):Connect(function()
        if not autoPotionOn then return end
        local newH=hum.HipHeight
        if not gpActive and newH>baseH*1.4 then
            gpActive=true; gpPrev=currentSpeed
            -- CHANGED: instant ragdoll the moment giant potion activates
            if ADM_REMOTE then
                task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end) end)
            end
            local gs=math.clamp(tonumber(gpBox.Text) or 40,1,120)
            currentSpeed=gs; if speedOn then startBoost(gs) end
        elseif gpActive and newH<=baseH*1.15 then
            gpActive=false; currentSpeed=gpPrev
            if speedOn then startBoost(gpPrev) end
        end
    end)
end)

-- CHANGED: Infinite jump - no longer resets character, just reconnects the event
local jumpConn=nil
local function setupIJ(char)
    if jumpConn then jumpConn:Disconnect(); jumpConn=nil end
    local hum=char:WaitForChild("Humanoid")
    jumpConn=UIS.JumpRequest:Connect(function()
        if not ijOn then return end
        if hum.Health<=0 then return end
        local st=hum:GetState()
        if st~=Enum.HumanoidStateType.Dead and st~=Enum.HumanoidStateType.None then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
if lp.Character then task.spawn(function() pcall(setupIJ,lp.Character) end) end
lp.CharacterAdded:Connect(function(c) task.wait(0.1); pcall(setupIJ,c) end)

-- Aimbot (unchanged)
local aimbotTarget=nil; local aimbotRemote=nil
task.spawn(function()
    local net=RS:FindFirstChild("Packages"); if net then net=net:FindFirstChild("Net") end; if not net then return end
    local ch=net:GetChildren()
    for i,obj in ipairs(ch) do if obj.Name=="RE/UseItem" then aimbotRemote=ch[i+1]; break end end
end)
RunSvc.Heartbeat:Connect(function()
    if not aimbotOn then return end
    local chr=lp.Character; local hrp=chr and chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart")
            if h then local d=(h.Position-hrp.Position).Magnitude; if d<bd then bd=d; best=p end end
        end
    end
    aimbotTarget=best
end)
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Tool") and obj:IsDescendantOf(lp.Character or {}) then
        task.wait(0.1)
        obj.Activated:Connect(function()
            if not aimbotOn or not aimbotTarget or not aimbotTarget.Character then return end
            local part=aimbotTarget.Character:FindFirstChild("HumanoidRootPart")
            if part and aimbotRemote then pcall(function() aimbotRemote:FireServer(part.Position,part) end) end
        end)
    end
end)

-- Anti Ragdoll (unchanged from original)
local arConn=nil
local function startAR()
    if arConn then return end
    arConn=RunSvc.Heartbeat:Connect(function()
        if not antiRagdollOn then return end
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        local s=hum:GetState()
        local ragd=s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown
        local et=lp:GetAttribute("RagdollEndTime"); if et and (et-workspace:GetServerTimeNow())>0 then ragd=true end
        if ragd then
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
end
startAR()

-- Anti Admin Panel (unchanged from original)
local aap_origScales={}; local aap_origHipH=nil; local aap_graceUntil=0
local aap_scaleNames={"HeadScale","BodyDepthScale","BodyHeightScale","BodyProportionScale","BodyTypeScale","BodyWidthScale"}
local function aap_captureOrig()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    aap_origHipH=hum.HipHeight; aap_origScales={}
    for _,n in ipairs(aap_scaleNames) do local sv=hum:FindFirstChild(n); if sv then aap_origScales[n]=sv.Value end end
end
lp.CharacterAdded:Connect(function(c) aap_graceUntil=tick()+1.5; task.wait(0.1); aap_captureOrig() end)
task.spawn(aap_captureOrig)
local _ctrlCache; local _charController; local _jumpscareMod
local function getCtrl()
    if _ctrlCache then return _ctrlCache end
    local ps=lp:FindFirstChild("PlayerScripts"); local pm=ps and ps:FindFirstChild("PlayerModule"); if not pm then return nil end
    local ok,m=pcall(require,pm); if not ok then return nil end
    local ok2,c=pcall(function() return m:GetControls() end); if ok2 and c then _ctrlCache=c end; return _ctrlCache
end
local function tryCC()
    if _charController~=nil then return _charController end
    local ok,mod=pcall(function() return require(RS:WaitForChild("Controllers"):WaitForChild("CharacterController")) end)
    _charController=ok and mod or false; return _charController
end
local function tryJS()
    if _jumpscareMod~=nil then return _jumpscareMod end
    local ok,mod=pcall(function() return require(RS:WaitForChild("Datas"):WaitForChild("AdminCommands"):WaitForChild("jumpscare")) end)
    _jumpscareMod=ok and mod or false; return _jumpscareMod
end
lp.CharacterAdded:Connect(function() _ctrlCache=nil end)
task.spawn(function()
    while task.wait(0.1) do
        if not antiAdminOn then continue end
        local char=lp.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then continue end
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then v:Destroy()
            elseif v:IsA("Motor6D") then v.Enabled=true end
        end
        local ctrl=getCtrl(); if ctrl then pcall(function() ctrl:Enable() end) end
        local cc=tryCC(); if cc and ctrl then ctrl.moveFunction=function(p,x,z) cc:RequestMove(p,x,z) end end
        local jm=tryJS(); if jm and jm.effects and jm.effects.Victim then jm.effects.Victim=function() end end
        local st=hum:GetState()
        if st~=Enum.HumanoidStateType.Running and st~=Enum.HumanoidStateType.Jumping and st~=Enum.HumanoidStateType.Freefall then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
        if workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject~=hum then workspace.CurrentCamera.CameraSubject=hum end
        local re=lp:GetAttribute("RagdollEndTime") or 0
        if re>workspace:GetServerTimeNow() then hrp.Velocity=Vector3.zero; lp:SetAttribute("RagdollEndTime",0) end
        if tick()>aap_graceUntil then
            if aap_origHipH and hum.HipHeight~=aap_origHipH and not autoPotionOn then hum.HipHeight=aap_origHipH end
            for _,n in ipairs(aap_scaleNames) do
                local sv=hum:FindFirstChild(n)
                if sv and aap_origScales[n] and sv.Value~=aap_origScales[n] and not autoPotionOn then sv.Value=aap_origScales[n] end
            end
        end
        for _,v in ipairs(char:GetChildren()) do if v:IsA("Model") and not v:IsA("BackpackItem") then v:Destroy() end end
    end
end)

-- CHANGED: Anti Beehive fixed - only removes lighting effects + movement inversion
-- Does NOT destroy bee-named objects on character (that was breaking own beehive placement)
local beeList={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","PostEffect"}
local function isBee(o) for _,n in ipairs(beeList) do if o:IsA(n) then return true end end; return false end
local function clearBee() for _,v in pairs(Lighting:GetDescendants()) do if isBee(v) then pcall(function() v:Destroy() end) end end end
clearBee(); Lighting.DescendantAdded:Connect(function(o) task.wait(); if antiBeeOn and isBee(o) then pcall(function() o:Destroy() end) end end)
RunSvc.Heartbeat:Connect(function()
    if not antiBeeOn then return end
    local char=lp.Character; if not char then return end
    -- CHANGED: only remove invert/reverse/confuse scripts, NOT "bee" named parts
    -- (those are your own beehive structure and shouldn't be touched)
    for _,obj in ipairs(char:GetDescendants()) do
        local nl=obj.Name:lower()
        if nl:find("invert") or nl:find("reverse") or nl:find("confuse") then
            pcall(function() obj:Destroy() end)
        end
    end
    local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.MoveDirection.Magnitude>0.1 then
        local md=hum.MoveDirection; local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
        if vel.Magnitude>3 and md:Dot(vel.Unit)<-0.5 then root.Velocity=Vector3.new(md.X*16,root.Velocity.Y,md.Z*16) end
    end
end)

-- Anti Sentry (unchanged from original)
local DETECTION_DISTANCE=200; local PULL_DISTANCE=-5
local sentryFirstSeen={}; local sentryTarget=nil
local function getSentryWeapon()
    local char=lp.Character; if not char then return nil end
    return (lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat")
end
local function findSentryTarget()
    if not antiSentryOn then return nil end
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
RunSvc.Heartbeat:Connect(function()
    if not antiSentryOn then sentryTarget=nil; return end
    if sentryTarget and sentryTarget.Parent==workspace then moveSentry(sentryTarget); attackSentry()
    else sentryTarget=findSentryTarget() end
end)
task.spawn(function() task.wait(1)
    for _,obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local oid=obj.Name:match("Sentry_(%d+)"); if not (oid and tonumber(oid)==lp.UserId) then sentryFirstSeen[obj]=tick()-3 end
        end
    end
end)

-- CHANGED: Base Protector logic (from Phantom Flash V5)
-- ragdoll + balloon anyone who steps on your base steal hitbox
local myBase=nil
task.spawn(function()
    while task.wait(1) do
        if not baseProtOn then myBase=nil; continue end
        local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
        for _,p in ipairs(plots:GetChildren()) do
            local sign=p:FindFirstChild("PlotSign"); if not sign then continue end
            local tl=sign:FindFirstChild("TextLabel",true); if not tl then continue end
            local t=tl.Text:lower()
            if t:find(lp.Name:lower(),1,true) or t:find(lp.DisplayName:lower(),1,true) then
                myBase=p; break
            end
        end
    end
end)
local lastBPPunish={}
task.spawn(function()
    while task.wait(0.15) do
        if not baseProtOn or not myBase or not ADM_REMOTE then continue end
        local hitbox=myBase:FindFirstChild("StealHitbox",true)
        if not hitbox then continue end
        local cf,sz=hitbox.CFrame,hitbox.Size
        local hx,hz=sz.X*0.5,sz.Z*0.5
        for _,p in ipairs(Players:GetPlayers()) do
            if p==lp then continue end
            local char2=p.Character; if not char2 then continue end
            local hrp2=char2:FindFirstChild("HumanoidRootPart"); if not hrp2 then continue end
            local rel=cf:PointToObjectSpace(hrp2.Position)
            if math.abs(rel.X)<=hx and math.abs(rel.Z)<=hz then
                local now=tick(); local uid=p.UserId
                if not lastBPPunish[uid] or now-lastBPPunish[uid]>1.5 then
                    lastBPPunish[uid]=now
                    task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"ragdoll") end) end)
                    task.delay(0.6,function() task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end) end) end)
                end
            end
        end
    end
end)

-- Anti Steal + Anti Intruder (unchanged from original)
local stealHitbox=nil; local myPlotRef=nil
task.spawn(function()
    while task.wait(1.2) do
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
    end
end)
local carpets={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true,["Cupid's Wings"]=true}
local lastPunish={}; local lastStealPunish={}
local function punish(p)
    if not ADM_REMOTE or not p or p==lp then return end
    local uid=p.UserId; local now=tick()
    if lastPunish[uid] and now-lastPunish[uid]<0.4 then return end
    lastPunish[uid]=now
    local cmd=(lastStealPunish[uid] and now-lastStealPunish[uid]<20) and "ragdoll" or "balloon"
    lastStealPunish[uid]=now
    task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,cmd) end) end)
end
local function findThief()
    local searchPos=stealHitbox and stealHitbox.Position
    if not searchPos then local myHRP=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); searchPos=myHRP and myHRP.Position end
    if not searchPos then return nil end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then
                local d=(hrp.Position-searchPos).Magnitude; if d<bd then bd=d; best=p end
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
            for _,item in ipairs(p.Character:GetChildren()) do if carpets[item.Name] then punish(p); break end end
        end
    end end
end
pcall(function()
    if not hookfunction or not fireproximityprompt then return end
    local old=fireproximityprompt
    hookfunction(fireproximityprompt,newcclosure(function(prompt,...)
        if (antiStealOn or antiIntruderOn) and ADM_REMOTE and (prompt.ActionText or ""):lower():find("steal") then
            local thief=findThief(); if thief then punish(thief) end; chkHitbox()
        end
        return old(prompt,...)
    end))
end)
pcall(function()
    for _,obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            obj.OnClientEvent:Connect(function(...)
                if not (antiStealOn or antiIntruderOn) or not ADM_REMOTE or not myPlotRef then return end
                for _,a in ipairs({...}) do
                    if type(a)=="string" and a:lower():find("stealing") then local thief=findThief(); if thief then punish(thief) end; return end
                end
            end)
        end
    end
end)
task.spawn(function()
    while task.wait(0.12) do
        if not (antiStealOn or antiIntruderOn) or not ADM_REMOTE then continue end
        chkHitbox()
    end
end)

-- Player ESP (unchanged from original)
local ESPTAG="VxE_"..tostring(math.random(1000,9999))
local function mkESP(plr)
    if plr==lp then return end
    local char=plr.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end
    local box=Instance.new("BoxHandleAdornment",char); box.Name=ESPTAG; box.Adornee=hrp
    box.Size=Vector3.new(3.5,5.5,1.8); box.Color3=C.accent; box.Transparency=0.58; box.ZIndex=10; box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char); bb.Name=ESPTAG.."N"
    bb.Adornee=char:FindFirstChild("Head") or hrp; bb.Size=UDim2.fromOffset(90,20); bb.StudsOffset=Vector3.new(0,2.8,0); bb.AlwaysOnTop=true
    local bgE=Instance.new("Frame",bb); bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=Color3.fromRGB(10,10,12)
    bgE.BackgroundTransparency=0.25; bgE.BorderSizePixel=0; co(bgE,4); stk(bgE,0.8,C.accent,0.3)
    lbl(bgE,{Size=UDim2.new(1,0,0.58,0);Text=plr.DisplayName;Font=Enum.Font.GothamBold;TextSize=8;TextColor3=C.white;TextXAlignment=Enum.TextXAlignment.Center;TextStrokeTransparency=0.5;TextStrokeColor3=Color3.new(0,0,0)})
    lbl(bgE,{Size=UDim2.new(1,0,0.42,0);Position=UDim2.new(0,0,0.58,0);Text="@"..plr.Name;Font=Enum.Font.Gotham;TextSize=6;TextColor3=C.dim;TextXAlignment=Enum.TextXAlignment.Center})
    local apBB=Instance.new("BillboardGui",char); apBB.Name=ESPTAG.."AP"; apBB.Adornee=hrp
    apBB.Size=UDim2.fromOffset(22,9); apBB.StudsOffset=Vector3.new(0,-3.5,0); apBB.AlwaysOnTop=true
    local apF=Instance.new("Frame",apBB); apF.Size=UDim2.new(1,0,1,0); apF.BackgroundColor3=C.panel; apF.BackgroundTransparency=0.15; apF.BorderSizePixel=0; co(apF,3)
    local apL=lbl(apF,{Size=UDim2.new(1,0,1,0);Text="AP?";Font=Enum.Font.GothamBold;TextSize=6;TextColor3=C.dim;TextXAlignment=Enum.TextXAlignment.Center})
    task.spawn(function() task.wait(0.8); local hasAP=false
        pcall(function() local pg=lp:FindFirstChild("PlayerGui"); if not pg then return end; local ap=pg:FindFirstChild("AdminPanel"); if not ap then return end
            local pl=ap:FindFirstChild("Profiles",true); if pl and pl:FindFirstChild(plr.Name) then hasAP=true end end)
        if hasAP then apF.BackgroundColor3=Color3.fromRGB(6,20,10); stk(apF,0.7,C.grn,0); apL.TextColor3=C.grn; apL.Text="AP✓"
        else apF.BackgroundColor3=Color3.fromRGB(20,6,6); stk(apF,0.7,C.red,0); apL.TextColor3=C.red; apL.Text="AP✗" end
    end)
end
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then task.defer(function() mkESP(p) end) end end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end)
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end end

-- Timer ESP (unchanged from original)
local timerESPs={}; local myPlotRef2=nil; local baseAlerted=false
local ECOL_R=Color3.fromRGB(255,65,65); local ECOL_Y=Color3.fromRGB(255,190,40); local ECOL_G=Color3.fromRGB(52,218,88)
local function showAlert()
    pcall(function() local s=Instance.new("Sound"); s.SoundId="rbxassetid://9118633772"; s.Volume=0.85; s.Parent=workspace; s:Play(); Debris:AddItem(s,5) end)
    local ag=Instance.new("ScreenGui",CoreGui); ag.Name="VxAlert"; ag.ResetOnSpawn=false; ag.IgnoreGuiInset=true
    local af=Instance.new("Frame",ag); af.Size=UDim2.fromOffset(160,22); af.Position=UDim2.new(0.5,-80,0,-30)
    af.BackgroundColor3=C.panel; af.BackgroundTransparency=0.1; af.BorderSizePixel=0; co(af,6); stk(af,1.5,C.red,0.08)
    lbl(af,{Size=UDim2.new(1,0,1,0);Text="⚠  BASE EXPIRES IN 5s!";TextSize=8;Font=Enum.Font.GothamBlack;TextColor3=C.red})
    TweenSvc:Create(af,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-80,0,6)}):Play()
    task.delay(4,function() TweenSvc:Create(af,TweenInfo.new(0.2),{Position=UDim2.new(0.5,-80,0,-30)}):Play(); task.wait(0.25); ag:Destroy() end)
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
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(46,13); bb.StudsOffset=Vector3.new(0,6.5,0); bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
                local bgT=Instance.new("Frame",bb); bgT.Size=UDim2.new(1,0,1,0); bgT.BackgroundColor3=Color3.fromRGB(8,8,10); bgT.BackgroundTransparency=0.18; bgT.BorderSizePixel=0; co(bgT,4)
                local sk=Instance.new("UIStroke",bgT); sk.Color=ECOL_Y; sk.Thickness=0.7; sk.Transparency=0.28
                local tl=lbl(bgT,{Size=UDim2.new(1,0,1,0);TextSize=8;TextColor3=ECOL_Y;TextStrokeTransparency=0.5;TextStrokeColor3=Color3.new(0,0,0)})
                timerESPs[plot.Name]={bb=bb,lbl=tl,sk=sk}; e=timerESPs[plot.Name]
            end
            e.lbl.Text=tl2.Text
            local m2,s2=tl2.Text:match("(%d+):(%d+)")
            if m2 and s2 then
                local tot=tonumber(m2)*60+tonumber(s2); local col=tot<=30 and ECOL_R or tot<=60 and ECOL_Y or ECOL_G
                e.lbl.TextColor3=col; e.sk.Color=col
                if myPlotRef2 and plot==myPlotRef2 then
                    if tot<=5 and not baseAlerted then baseAlerted=true; task.spawn(showAlert) elseif tot>5 then baseAlerted=false end
                end
            end
        else local e=timerESPs[plot.Name]; if e then pcall(function() e.bb:Destroy() end); timerESPs[plot.Name]=nil end end
    end
end end)
task.spawn(function() while task.wait(0.9) do
    if not myPlotRef2 then
        local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
        for _,p in ipairs(plots:GetChildren()) do
            local sign=p:FindFirstChild("PlotSign"); if not sign then continue end
            local tl=sign:FindFirstChild("TextLabel",true); if not tl then continue end
            local t=tl.Text:lower()
            if t:find(lp.Name:lower(),1,true) or t:find(lp.DisplayName:lower(),1,true) then myPlotRef2=p; break end
        end
    end
end end)

-- Auto kick on steal text (unchanged)
local function watchObj(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    local function chk(t) if type(t)=="string" and t:lower():find("you stole") and autoKickOn then pcall(function() lp:Kick("nice steal twin") end) end end
    chk(obj.Text); obj:GetPropertyChangedSignal("Text"):Connect(function() chk(obj.Text) end)
end
local function setupWatch(gui) for _,d in ipairs(gui:GetDescendants()) do watchObj(d) end; gui.DescendantAdded:Connect(watchObj) end
for _,g in ipairs(lp.PlayerGui:GetChildren()) do setupWatch(g) end
lp.PlayerGui.ChildAdded:Connect(setupWatch)

print("VertexHub loaded | r9qbx discord")
