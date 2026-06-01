-- Vertex Pvp | @r9qbx | discord.gg/3JnFzfcYB
pcall(setfpscap, 9999)

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local CoreGui           = game:GetService("CoreGui")
local Lighting          = game:GetService("Lighting")
local lp                = Players.LocalPlayer
local cam               = workspace.CurrentCamera

if not lp then Players:GetPropertyChangedSignal("LocalPlayer"):Wait(); lp=Players.LocalPlayer end
pcall(function() lp:WaitForChild("PlayerGui",10) end)

for _,v in ipairs(CoreGui:GetChildren()) do
    if v.Name=="VertexPvp" then v:Destroy() end
end

-- ════════════════════════════════════════
-- THEME
-- ════════════════════════════════════════
local T = {
    BG          = Color3.fromRGB(10,10,14),
    Header      = Color3.fromRGB(6,6,10),
    Card        = Color3.fromRGB(16,16,24),
    CardHover   = Color3.fromRGB(22,22,34),
    Border      = Color3.fromRGB(35,35,55),
    BorderHover = Color3.fromRGB(60,80,180),
    White       = Color3.fromRGB(240,245,255),
    Dim         = Color3.fromRGB(90,100,130),
    TabActive   = Color3.fromRGB(240,245,255),
    TabInact    = Color3.fromRGB(65,75,105),
    TrackOn     = Color3.fromRGB(50,130,255),
    TrackOff    = Color3.fromRGB(35,35,55),
    KnobOn      = Color3.fromRGB(255,255,255),
    KnobOff     = Color3.fromRGB(120,130,160),
    Blue        = Color3.fromRGB(50,130,255),
    BlueDim     = Color3.fromRGB(30,80,180),
}

-- ════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════
local CONFIG_PATH = "VertexPvp_config.json"
local Config = { toggles={}, keybinds={}, mini={}, fastPanelPos=nil }
local configRegistry = {}
local keybindEntries = {}
local keybindBindingTarget = nil

local function FH_SerializeConfig()
    local function enc(v)
        local t=type(v)
        if t=="boolean" then return v and "true" or "false"
        elseif t=="number" then return tostring(v)
        elseif t=="string" then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"')..'"'
        elseif t=="table" then
            local p={}; for k,val in pairs(v) do p[#p+1]='"'..tostring(k)..'":'..enc(val) end
            return "{"..table.concat(p,",").."}"
        end; return "null"
    end
    return enc({toggles=Config.toggles,keybinds=Config.keybinds,mini=Config.mini,fastPanelPos=Config.fastPanelPos})
end

local function FH_ParseConfig(str)
    local pos=1
    local function sw() while pos<=#str and str:sub(pos,pos):match("%s") do pos=pos+1 end end
    local pv
    local function ps() pos=pos+1; local s="" while pos<=#str do local c=str:sub(pos,pos); if c=='"' then pos=pos+1; return s end; if c=='\\' then pos=pos+1; local e=str:sub(pos,pos); s=s..(e=='"' and '"' or e=='\\' and '\\' or e=='n' and '\n' or e) else s=s..c end; pos=pos+1 end; return s end
    local function po() pos=pos+1; local t={}; sw(); if str:sub(pos,pos)=="}" then pos=pos+1; return t end; while true do sw(); local k=ps(); sw(); pos=pos+1; sw(); t[k]=pv(); sw(); if str:sub(pos,pos)=="}" then pos=pos+1; return t end; pos=pos+1 end end
    pv=function() sw(); local c=str:sub(pos,pos); if c=='"' then return ps() elseif c=='{' then return po() elseif c=='t' then pos=pos+4; return true elseif c=='f' then pos=pos+5; return false elseif c=='n' then pos=pos+4; return nil else local n=str:match("^-?%d+%.?%d*",pos); if n then pos=pos+#n; return tonumber(n) end end end
    local ok,r=pcall(pv); return (ok and type(r)=="table") and r or nil
end

local function FH_SaveConfig()
    pcall(writefile,CONFIG_PATH,FH_SerializeConfig())
end
local function FH_LoadConfig()
    local ok,data=pcall(function() return FH_ParseConfig(readfile(CONFIG_PATH)) end)
    if ok and type(data)=="table" then
        if type(data.toggles)=="table" then Config.toggles=data.toggles end
        if type(data.keybinds)=="table" then Config.keybinds=data.keybinds end
        if type(data.mini)=="table" then Config.mini=data.mini end
        if type(data.fastPanelPos)=="table" then Config.fastPanelPos=data.fastPanelPos end
    end
end
local function FH_ApplyLoadedKeybinds()
    for name,kcName in pairs(Config.keybinds) do
        if configRegistry[name] and configRegistry[name].setKeyCode then
            local ok,kc=pcall(function() return Enum.KeyCode[kcName] end)
            if ok and kc then configRegistry[name].setKeyCode(kc) end
        end
    end
end
pcall(FH_LoadConfig)

-- ════════════════════════════════════════
-- GAME MODULES
-- ════════════════════════════════════════
local Synchronizer,AnimalsData,NumberUtils,AnimalsShared
pcall(function()
    local Packages=ReplicatedStorage:WaitForChild("Packages",8)
    local Datas=ReplicatedStorage:WaitForChild("Datas",8)
    local Utils=ReplicatedStorage:WaitForChild("Utils",8)
    local Shared=ReplicatedStorage:WaitForChild("Shared",8)
    Synchronizer=require(Packages:WaitForChild("Synchronizer"))
    AnimalsData=require(Datas:WaitForChild("Animals"))
    NumberUtils=require(Utils:WaitForChild("NumberUtils"))
    AnimalsShared=require(Shared:WaitForChild("Animals"))
end)

-- ════════════════════════════════════════
-- GUI HELPERS (exact Faded Flash)
-- ════════════════════════════════════════
local isMobile=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local F=TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local M=TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local S=TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
local function Tween(o,i,p) TweenService:Create(o,i,p):Play() end
local function Corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function Stroke(p,col,th) local s=Instance.new("UIStroke"); s.Color=col or T.Border; s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function Padding(p,t,b,l,r) local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or 0); u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0); u.Parent=p end
local function Label(p,txt,sz,col,font) local l=Instance.new("TextLabel"); l.Text=txt or ""; l.TextSize=sz or 13; l.TextColor3=col or T.White; l.Font=font or Enum.Font.GothamMedium; l.BackgroundTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=p; return l end

-- ════════════════════════════════════════
-- NOTIFICATIONS (bottom-left, small)
-- ════════════════════════════════════════
local GUI=Instance.new("ScreenGui"); GUI.Name="VertexPvp"; GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; GUI.ResetOnSpawn=false; GUI.IgnoreGuiInset=true
if not pcall(function() GUI.Parent=CoreGui end) then GUI.Parent=lp:WaitForChild("PlayerGui") end

local _activeNotifs={}
local NOTIF_W,NOTIF_H,NOTIF_GAP,NOTIF_PAD_X,NOTIF_PAD_Y,NOTIF_DUR=170,36,4,10,14,2
local function _shadowTargetY(i) return -(NOTIF_PAD_Y+NOTIF_H+4+i*(NOTIF_H+NOTIF_GAP)) end
local function _repoAll(ti) for i,e in ipairs(_activeNotifs) do TweenService:Create(e.shadow,ti,{Position=UDim2.new(0,NOTIF_PAD_X-3,1,_shadowTargetY(i-1))}):Play() end end
local function ShowToggleNotification(name,enabled)
    local statusTxt=enabled and "Enabled" or "Disabled"
    local statusCol=enabled and Color3.fromRGB(80,200,120) or Color3.fromRGB(255,80,80)
    local IN=TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
    local OUT=TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
    local BAR=TweenInfo.new(NOTIF_DUR,Enum.EasingStyle.Linear)
    local FADE=TweenInfo.new(0.2,Enum.EasingStyle.Linear)
    local REPO=TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
    local shadow=Instance.new("Frame",GUI); shadow.Size=UDim2.new(0,NOTIF_W+6,0,NOTIF_H+6); shadow.Position=UDim2.new(0,-(NOTIF_W+30),1,_shadowTargetY(0)); shadow.BackgroundColor3=Color3.fromRGB(0,0,0); shadow.BackgroundTransparency=0.15; shadow.BorderSizePixel=0; shadow.ZIndex=99; Corner(shadow,10)
    local toast=Instance.new("Frame",shadow); toast.Size=UDim2.new(0,NOTIF_W,0,NOTIF_H); toast.Position=UDim2.fromOffset(3,3); toast.BackgroundColor3=T.BG; toast.BackgroundTransparency=0; toast.BorderSizePixel=0; toast.ZIndex=100; Corner(toast,8)
    local _s=Stroke(toast,T.Blue,1); _s.Transparency=0.5
    local pill=Instance.new("Frame",toast); pill.Size=UDim2.new(0,3,0,NOTIF_H-10); pill.Position=UDim2.new(0,7,0.5,-(NOTIF_H-10)/2); pill.BackgroundColor3=T.Blue; pill.BorderSizePixel=0; pill.ZIndex=101; Corner(pill,2)
    local nl=Label(toast,name,isMobile and 9 or 10,T.White,Enum.Font.GothamBold); nl.Size=UDim2.new(1,-20,0,13); nl.Position=UDim2.new(0,16,0,5); nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.TextTransparency=1; nl.ZIndex=101
    local sl=Label(toast,statusTxt,isMobile and 8 or 9,statusCol,Enum.Font.Gotham); sl.Size=UDim2.new(1,-20,0,11); sl.Position=UDim2.new(0,16,0,19); sl.TextTransparency=1; sl.ZIndex=101
    local bt=Instance.new("Frame",toast); bt.Size=UDim2.new(1,0,0,2); bt.Position=UDim2.new(0,0,1,-2); bt.BackgroundColor3=Color3.fromRGB(25,25,40); bt.BorderSizePixel=0; bt.ZIndex=101
    local bf=Instance.new("Frame",bt); bf.Size=UDim2.new(1,0,1,0); bf.BackgroundColor3=T.Blue; bf.BorderSizePixel=0; bf.ZIndex=102
    local entry={shadow=shadow}
    table.insert(_activeNotifs,1,entry); _repoAll(REPO)
    TweenService:Create(shadow,IN,{Position=UDim2.new(0,NOTIF_PAD_X-3,1,_shadowTargetY(0))}):Play()
    TweenService:Create(toast,IN,{BackgroundTransparency=0}):Play()
    TweenService:Create(nl,IN,{TextTransparency=0}):Play()
    TweenService:Create(sl,IN,{TextTransparency=0}):Play()
    task.delay(0.1,function() TweenService:Create(bf,BAR,{Size=UDim2.new(0,0,1,0)}):Play() end)
    task.delay(NOTIF_DUR+0.1,function()
        for i,e in ipairs(_activeNotifs) do if e==entry then table.remove(_activeNotifs,i); break end end
        _repoAll(REPO)
        local ey=shadow.Position.Y.Offset
        TweenService:Create(shadow,OUT,{Position=UDim2.new(0,-(NOTIF_W+30),1,ey)}):Play()
        local tw=TweenService:Create(toast,FADE,{BackgroundTransparency=1}); tw:Play()
        tw.Completed:Connect(function() shadow:Destroy() end)
    end)
end

-- ════════════════════════════════════════
-- MAIN WINDOW
-- ════════════════════════════════════════
local WIN_W=isMobile and 320 or 340
local WIN_H=isMobile and 420 or 450
local Win=Instance.new("Frame",GUI); Win.Name="Win"; Win.Size=UDim2.new(0,WIN_W,0,WIN_H); Win.AnchorPoint=Vector2.new(0.5,0.5); Win.Position=UDim2.new(0.5,0,0.5,0); Win.BackgroundColor3=T.BG; Win.BackgroundTransparency=0.1; Win.BorderSizePixel=0; Win.ZIndex=2
Corner(Win,12)
local WinStroke=Instance.new("UIStroke",Win); WinStroke.Thickness=1.6; WinStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; WinStroke.Color=Color3.fromRGB(255,255,255)
local WinGrad=Instance.new("UIGradient",WinStroke); WinGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(30,60,180)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(200,210,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,60,180))}; WinGrad.Rotation=0
task.spawn(function() while WinStroke and WinStroke.Parent do WinGrad.Rotation=(WinGrad.Rotation+0.8)%360; task.wait(0.016) end end)
local WinScale=Instance.new("UIScale",Win); WinScale.Scale=1

-- Header
local Hdr=Instance.new("Frame",Win); Hdr.Size=UDim2.new(1,0,0,40); Hdr.BackgroundColor3=T.Header; Hdr.BackgroundTransparency=0.2; Hdr.BorderSizePixel=0; Hdr.ZIndex=5; Corner(Hdr,12); Hdr.Active=true
local HdrFill=Instance.new("Frame",Hdr); HdrFill.Size=UDim2.new(1,0,0,8); HdrFill.Position=UDim2.new(0,0,1,-8); HdrFill.BackgroundColor3=T.Header; HdrFill.BackgroundTransparency=0.2; HdrFill.BorderSizePixel=0; HdrFill.ZIndex=5
local HdrLine=Instance.new("Frame",Win); HdrLine.Size=UDim2.new(1,0,0,1); HdrLine.Position=UDim2.new(0,0,0,40); HdrLine.BackgroundColor3=T.Border; HdrLine.BorderSizePixel=0; HdrLine.ZIndex=5
local Dot=Instance.new("Frame",Hdr); Dot.Size=UDim2.new(0,7,0,7); Dot.Position=UDim2.new(0,14,0.5,-3.5); Dot.BackgroundColor3=T.Blue; Dot.BorderSizePixel=0; Dot.ZIndex=6; Corner(Dot,4)
local TitleLbl=Label(Hdr,"",14,T.White,Enum.Font.GothamBold); TitleLbl.RichText=true; TitleLbl.Text='<font color="rgb(240,245,255)">Vertex</font> <font color="rgb(50,130,255)">Pvp</font>'; TitleLbl.Size=UDim2.new(0,160,0,20); TitleLbl.Position=UDim2.new(0,28,0.5,-10); TitleLbl.ZIndex=6

-- Header buttons (FREE/LOCK, RESET, FLASH, BLOCK)
_G._FH_GUI_LOCKED=false
local HBTN_H=isMobile and 18 or 22
local HdrBtns=Instance.new("Frame",Hdr); HdrBtns.AnchorPoint=Vector2.new(1,0.5); HdrBtns.Position=UDim2.new(1,-8,0.5,0); HdrBtns.Size=UDim2.new(0,0,0,HBTN_H); HdrBtns.AutomaticSize=Enum.AutomaticSize.X; HdrBtns.BackgroundTransparency=1; HdrBtns.ZIndex=7
local hl=Instance.new("UIListLayout",HdrBtns); hl.FillDirection=Enum.FillDirection.Horizontal; hl.VerticalAlignment=Enum.VerticalAlignment.Center; hl.Padding=UDim.new(0,5)
local function styleHBtn(text,order)
    local b=Instance.new("TextButton",HdrBtns); b.Name="Hdr_"..text; b.AutomaticSize=Enum.AutomaticSize.X; b.Size=UDim2.new(0,0,0,HBTN_H); b.LayoutOrder=order; b.BackgroundColor3=T.Card; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Text=text; b.TextSize=isMobile and 8 or 10; b.Font=Enum.Font.GothamBold; b.TextColor3=T.White; b.ZIndex=8; b.Active=true; Corner(b,5); local p=Instance.new("UIPadding",b); p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8); local s=Stroke(b,T.Border,1); return b,s
end

do
    local lb,ls=styleHBtn("FREE",1)
    lb.MouseButton1Click:Connect(function()
        _G._FH_GUI_LOCKED=not _G._FH_GUI_LOCKED
        lb.Text=_G._FH_GUI_LOCKED and "LOCK" or "FREE"
        lb.BackgroundColor3=_G._FH_GUI_LOCKED and Color3.fromRGB(140,30,30) or T.Card
        ls.Color=_G._FH_GUI_LOCKED and Color3.fromRGB(200,50,50) or T.Border
    end)
end

local hdrBinds={}
local function makeActionBtn(label,order,onClick)
    local btn,s=styleHBtn(label,order)
    local entry={keyCode=nil,label=label,configKey="hdr_"..label}
    local _busy=false
    local function fire()
        if _busy then return end; _busy=true
        btn.BackgroundColor3=T.White; btn.TextColor3=Color3.fromRGB(12,12,20)
        Tween(s,F,{Color=T.White})
        task.delay(0.16,function() Tween(btn,M,{BackgroundColor3=T.Card}); Tween(s,M,{Color=T.Border}); btn.TextColor3=T.White; _busy=false end)
        if onClick then task.spawn(function() pcall(onClick) end) end
    end
    btn.MouseButton1Click:Connect(fire)
    btn.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton2 then
        if hdrBindTarget then local p=hdrBindTarget; hdrBindTarget=nil; p.refresh() end
        hdrBindTarget=entry; entry.refresh()
    end end)
    entry.refresh=function() if hdrBindTarget==entry then btn.Text=label.."(...)" elseif entry.keyCode then btn.Text=label.."("..entry.keyCode.Name..")" else btn.Text=label end end
    entry.fire=fire
    local saved=Config.keybinds[entry.configKey]; if saved then local ok,kc=pcall(function() return Enum.KeyCode[saved] end); if ok and kc then entry.keyCode=kc; entry.refresh() end end
    table.insert(hdrBinds,entry); return entry
end

-- ════════════════════════════════════════
-- ANTI-BEE (Phantom V5 exact + effects)
-- ════════════════════════════════════════
local FOV_LOCK=70
RunService.RenderStepped:Connect(function() if cam.FieldOfView~=FOV_LOCK then cam.FieldOfView=FOV_LOCK end end)
local beeFX={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","PostEffect"}
local function isBeeEffect(obj) for _,n in ipairs(beeFX) do if obj:IsA(n) then return true end end; return false end
for _,v in pairs(Lighting:GetDescendants()) do if isBeeEffect(v) then pcall(function() v:Destroy() end) end end
Lighting.DescendantAdded:Connect(function(obj) task.wait(); if isBeeEffect(obj) then pcall(function() obj:Destroy() end) end end)
local antiBeeEnabled=true
RunService.Heartbeat:Connect(function()
    if not antiBeeEnabled then return end
    local char=lp.Character; if not char then return end
    for _,obj in ipairs(char:GetDescendants()) do
        local nl=obj.Name:lower()
        if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") or nl:find("effect") then
            pcall(function() obj:Destroy() end)
        end
    end
    local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.MoveDirection.Magnitude>0.1 then
        local md=hum.MoveDirection; local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
        if vel.Magnitude>3 and md:Dot(vel.Unit)<-0.5 then root.Velocity=Vector3.new(md.X*16,root.Velocity.Y,md.Z*16) end
    end
end)

-- ════════════════════════════════════════
-- ANTI-RAGDOLL (Faded Flash exact)
-- ════════════════════════════════════════
local AntiRagdoll={connections={},running=false}
AntiRagdoll.removeRagdollConstraints=function(char)
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint") or d:IsA("NoCollisionConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then d:Destroy() end
    end
end
AntiRagdoll.resetCharacter=function(char)
    local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored=false; root.Velocity=Vector3.zero end
    if hum then
        for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        hum.PlatformStand=false; hum.Sit=false
        if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
        cam.CameraSubject=hum
    end
end
AntiRagdoll.enable=function()
    if AntiRagdoll.running then return end; AntiRagdoll.running=true
    AntiRagdoll.connections.heartbeat=RunService.Heartbeat:Connect(function()
        local char=lp.Character; if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s=hum:GetState()
        local rag=(s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown)
        local et=lp:GetAttribute("RagdollEndTime"); if et and (et-workspace:GetServerTimeNow())>0 then rag=true end
        if rag then
            pcall(function() lp:SetAttribute("RagdollEndTime",workspace:GetServerTimeNow()) end)
            AntiRagdoll.removeRagdollConstraints(char)
            for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
            if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            cam.CameraSubject=hum; root.Anchored=false; root.Velocity=Vector3.zero
        end
    end)
    if lp.Character then AntiRagdoll.resetCharacter(lp.Character) end
end
AntiRagdoll.disable=function()
    AntiRagdoll.running=false
    for _,c in pairs(AntiRagdoll.connections) do pcall(function() c:Disconnect() end) end
    AntiRagdoll.connections={}
end

-- ════════════════════════════════════════
-- ANTI-ADMIN PANEL (doc 8)
-- ════════════════════════════════════════
local AntiAdminEnabled=false
local originalScales={}; local originalHipHeight=nil
local scaleNames={"HeadScale","BodyDepthScale","BodyHeightScale","BodyProportionScale","BodyTypeScale","BodyWidthScale"}
local _ctrlCache=nil
local function captureOriginals()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    originalHipHeight=hum.HipHeight; originalScales={}
    for _,name in ipairs(scaleNames) do local sv=hum:FindFirstChild(name); if sv then originalScales[name]=sv.Value end end
end
local function getControls()
    if _ctrlCache then return _ctrlCache end
    local ps=lp:FindFirstChild("PlayerScripts"); local pm=ps and ps:FindFirstChild("PlayerModule"); if not pm then return nil end
    local ok,mod=pcall(require,pm); if not ok or not mod then return nil end
    local ok2,c=pcall(function() return mod:GetControls() end); if ok2 and c then _ctrlCache=c end; return _ctrlCache
end
lp.CharacterAdded:Connect(function(char) task.wait(0.1); captureOriginals() end)
task.spawn(captureOriginals)
task.spawn(function()
    while task.wait(0.1) do
        if not AntiAdminEnabled then continue end
        local char=lp.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then continue end
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then v:Destroy()
            elseif v:IsA("Motor6D") then v.Enabled=true end
        end
        local ctrl=getControls(); if ctrl then pcall(function() ctrl:Enable() end) end
        local st=hum:GetState()
        if st~=Enum.HumanoidStateType.Running and st~=Enum.HumanoidStateType.Jumping and st~=Enum.HumanoidStateType.Freefall then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
        if cam and cam.CameraSubject~=hum then cam.CameraSubject=hum end
        if originalHipHeight and hum.HipHeight~=originalHipHeight then hum.HipHeight=originalHipHeight end
        for _,name in ipairs(scaleNames) do
            local sv=hum:FindFirstChild(name); if sv and originalScales[name] and sv.Value~=originalScales[name] then sv.Value=originalScales[name] end
        end
        for _,v in ipairs(char:GetChildren()) do if v:IsA("Model") and not v:IsA("BackpackItem") then v:Destroy() end end
    end
end)

-- ════════════════════════════════════════
-- BLOCK SYSTEM (VIM fixed)
-- ════════════════════════════════════════
local VIM; pcall(function() VIM=game:GetService("VirtualInputManager") end)
local function getNearestPlayer()
    local chr=lp.Character; local hrp=chr and chr:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); if h then local d=(h.Position-hrp.Position).Magnitude; if d<bd then bd=d; best=p end end end
    end; return best
end
local function blockPlayer(target)
    if not target then return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer",target) end)
    -- scan for the actual Block button in PlayerGui dialogs
    task.spawn(function()
        for attempt=1,12 do
            task.wait(0.02)
            local pg=lp:FindFirstChild("PlayerGui"); if not pg then continue end
            -- deep scan for any TextButton containing "Block"
            for _,gui in ipairs(pg:GetDescendants()) do
                if gui:IsA("TextButton") then
                    local t=gui.Text:lower()
                    if t=="block" or t=="ok" or t=="confirm" then
                        local ap=gui.AbsolutePosition; local as=gui.AbsoluteSize
                        local cx=math.floor(ap.X+as.X*0.5); local cy=math.floor(ap.Y+as.Y*0.5)
                        if VIM then
                            pcall(function() VIM:SendMouseButtonEvent(cx,cy,0,true,game,1) end)
                            task.wait(0.008)
                            pcall(function() VIM:SendMouseButtonEvent(cx,cy,0,false,game,1) end)
                        end
                        pcall(function() gui:Click() end)
                        return
                    end
                end
            end
        end
        -- fallback: click at center-bottom of screen
        if VIM then
            local vp=cam.ViewportSize
            local cx=math.floor(vp.X/2); local cy=math.floor(vp.Y/2+60)
            pcall(function() VIM:SendMouseButtonEvent(cx,cy,0,true,game,1) end)
            task.wait(0.008)
            pcall(function() VIM:SendMouseButtonEvent(cx,cy,0,false,game,1) end)
        end
    end)
end
local AutoBlockEnabled=false
local function triggerAutoBlock()
    if not AutoBlockEnabled then return end
    task.spawn(function()
        local ping=0; pcall(function() ping=lp:GetNetworkPing() or 0 end)
        task.wait(math.clamp(0.08+ping,0.08,0.3))
        blockPlayer(getNearestPlayer())
    end)
end

-- ════════════════════════════════════════
-- GRAB SYSTEM (faster, EXT callbacks)
-- ════════════════════════════════════════
local __AG_stealCbCache={}; local __AG_stealActive=false
local __AG_MIN_HOLD=0.95; local __AG_TRIGGER_DELAY=0.03
local function __AG_buildStealCallbacks(prompt)
    if __AG_stealCbCache[prompt] then return __AG_stealCbCache[prompt] end
    if not getconnections then return nil end
    local data={hold={},trigger={}}
    local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end end
    local ok2,c2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(c2)=="table" then for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trigger,c.Function) end end end
    if #data.hold==0 and #data.trigger==0 then return nil end
    __AG_stealCbCache[prompt]=data; return data
end
local function __AG_startStealHold(prompt)
    if not prompt or not prompt.Parent then return nil end
    local cb=__AG_buildStealCallbacks(prompt); if not cb then return nil end
    __AG_stealActive=true
    for _,fn in ipairs(cb.hold) do task.spawn(fn) end
    return {cb=cb,holdBeganAt=tick(),holdDone=false}
end
local function __AG_finishStealHold(ctx)
    if not ctx then return false end
    local held=tick()-(ctx.holdBeganAt or tick())
    if held<__AG_MIN_HOLD then task.wait(__AG_MIN_HOLD-held) end
    task.wait(__AG_TRIGGER_DELAY)
    for _,fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
    __AG_stealActive=false; return true
end
local function __AG_findTargetPrompt()
    local sel=_G._FH_SelectedBrainrot; if not sel or not sel.plotName or not sel.slot then return nil end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    local plot=plots:FindFirstChild(sel.plotName); if not plot then return nil end
    local podiums=plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
    local podium=podiums:FindFirstChild(tostring(sel.slot)); if not podium then return nil end
    local base=podium:FindFirstChild("Base"); local spawn=base and base:FindFirstChild("Spawn")
    local pa=spawn and spawn:FindFirstChild("PromptAttachment"); local prompt=pa and pa:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then prompt.RequiresLineOfSight=false; prompt.MaxActivationDistance=math.huge end
    return prompt
end

-- ════════════════════════════════════════
-- ADMIN REMOTE
-- ════════════════════════════════════════
local ADM=nil
task.spawn(function()
    pcall(function() if not lp.Character then lp.CharacterAdded:Wait() end end); task.wait(1.5)
    pcall(function()
        local net=ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
        local ch=net:GetChildren(); local n2i={}; for i,o in ipairs(ch) do n2i[o.Name]=i end
        local a=n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]; if a and ch[a+1] then ADM=ch[a+1] end
    end)
end)
local AUUID="f888ee6e-c86d-46e1-93d7-0639d6635d42"
local function aFire(tgt,cmd) task.spawn(function() pcall(function() ADM:InvokeServer(AUUID,tgt,cmd) end) end) end

local _ragdollCommandCache={}; local _ragdollProfileCache={}
local function _ragdollCacheActivated(obj) local cached={}; local ok,conns=pcall(getconnections,obj.Activated); if ok and type(conns)=="table" then for _,c in ipairs(conns) do if type(c.Function)=="function" then table.insert(cached,c.Function) end end end; return cached end
local function _ragdollFireActivated(cached) for _,fn in ipairs(cached) do task.spawn(fn) end end
local function _ragdollGetAdminFrames()
    local ap=lp.PlayerGui:FindFirstChild("AdminPanel"); if not ap then return nil,nil end
    local panel=ap:FindFirstChild("AdminPanel"); if not panel then return nil,nil end
    local content=panel:FindFirstChild("Content"); local profiles=panel:FindFirstChild("Profiles")
    if not content or not profiles then return nil,nil end
    return content:FindFirstChild("ScrollingFrame"),profiles:FindFirstChild("ScrollingFrame")
end
local RagdollBypassEnabled=false
local function _ragdollSelf()
    local cf,pf=_ragdollGetAdminFrames(); if not cf or not pf then return end
    local pn=lp.Name; local pb=pf:FindFirstChild(pn); local rb=cf:FindFirstChild("ragdoll")
    if not pb or not rb then return end
    if not _ragdollProfileCache[pn] then _ragdollProfileCache[pn]=_ragdollCacheActivated(pb) end
    if not _ragdollCommandCache["ragdoll"] then _ragdollCommandCache["ragdoll"]=_ragdollCacheActivated(rb) end
    _ragdollFireActivated(_ragdollCommandCache["ragdoll"]); task.wait(); _ragdollFireActivated(_ragdollProfileCache[pn])
end

-- ════════════════════════════════════════
-- RESET BUTTON (Faded Flash exact)
-- ════════════════════════════════════════
local function doSelectedReset()
    local Net=pcall(function() return ReplicatedStorage.Packages.Net end) and ReplicatedStorage.Packages.Net or nil
    if not Net then
        local char=lp.Character; local hum=char and char:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.Health=0 end; return
    end
    local remote=nil; local ch=Net:GetChildren()
    for i=1,#ch-1 do if ch[i] and ch[i+1] and ch[i].Name:find("Tools/Cooldown") then remote=ch[i+1]; break end end
    if not remote then local char=lp.Character; local hum=char and char:FindFirstChildWhichIsA("Humanoid"); if hum then hum.Health=0 end; return end
    local savedTools={}; local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
    if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then pcall(function() hum:UnequipTools() end) end; for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(savedTools,t); t.Parent=nil end end end
    if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(savedTools,t); t.Parent=nil end end end
    lp.Character=nil
    local sending=true; local loopConn; local fire=remote.FireServer; local throttle=0
    loopConn=RunService.Heartbeat:Connect(function(dt)
        if not sending then if loopConn then loopConn:Disconnect(); loopConn=nil end; return end
        throttle=throttle+dt; if throttle>=0.1 then throttle=0; pcall(fire,remote,AUUID,lp,"balloon") end
        if sending and lp.Character then lp.Character=nil end
    end)
    local conn; conn=lp.CharacterAdded:Connect(function()
        sending=false; if loopConn then loopConn:Disconnect(); loopConn=nil end; if conn then conn:Disconnect() end
        task.spawn(function() local nb=lp:WaitForChild("Backpack",3); if nb then for _,t in ipairs(savedTools) do if t then t.Parent=nb end end end; savedTools={} end)
    end)
    task.delay(4,function() sending=false; if loopConn then loopConn:Disconnect(); loopConn=nil end; local cb=lp:FindFirstChild("Backpack"); if cb then for _,t in ipairs(savedTools) do if t then t.Parent=cb end end end; savedTools={} end)
end

-- ════════════════════════════════════════
-- CARPET TWEEN (fixed, speed 214)
-- ════════════════════════════════════════
local _fhCarpetActiveTween=nil
local function _cancelCarpetTween() if _fhCarpetActiveTween then _fhCarpetActiveTween=nil end end
local function _doEquip(tool,timeout)
    local char=lp.Character; local h=char and char:FindFirstChildOfClass("Humanoid"); if not (char and h) then return end
    if tool.Parent==char then return end
    local done=false; local cn; cn=tool.Equipped:Connect(function() done=true; cn:Disconnect() end)
    pcall(function() h:EquipTool(tool) end)
    local dl=tick()+(timeout or 1); while not done and tick()<dl do task.wait() end
    if cn then pcall(function() cn:Disconnect() end) end
end
local function findTool(kw)
    local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
    if char then for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
    if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
end

-- ════════════════════════════════════════
-- PODIUM CFRAMES (exact from Faded Flash)
-- ════════════════════════════════════════
local PODIUM_CFRAMES={
    [1]={
        [1]={hrp=CFrame.new(Vector3.new(-347.6983,-7.5033,-4.5494)),cam=CFrame.new(-357.0927,0.0048,-0.272)*CFrame.Angles(-0.954463,-0.903625,-0.837019)},
        [2]={hrp=CFrame.new(Vector3.new(0,0,0)),cam=nil},
        [3]={hrp=CFrame.new(Vector3.new(0,0,0)),cam=nil},
        [4]={hrp=CFrame.new(Vector3.new(0,0,0)),cam=nil},
        [5]={hrp=CFrame.new(Vector3.new(0,0,0)),cam=nil},
    },
    [2]={
        [1]={hrp=CFrame.new(Vector3.new(-331.19,-6.54,31.64)),cam=CFrame.new(-331.19,0,-10)*CFrame.Angles(-0.5,0,0)},
        [2]={hrp=CFrame.new(Vector3.new(-343.58,-6.46,19.06)),cam=CFrame.new(-357.0927,0.0048,-0.272)*CFrame.Angles(-0.824269,-0.878251,-0.693896)},
        [3]={hrp=CFrame.new(-344.09,-6.54,17.37)*CFrame.Angles(0,-1.247212,0),cam=CFrame.new(-360.1625,0.6353,3.1776)*CFrame.Angles(-0.932656,-1.049154,-0.86316)},
        [4]={hrp=CFrame.new(-342.86,-5.84,10.75)*CFrame.Angles(0,-0.982332,0),cam=CFrame.new(-356.477,-0.7795,18.8846)*CFrame.Angles(-0.510736,-0.917793,-0.418726)},
        [5]={hrp=CFrame.new(-301.15,-6.54,31.64),cam=CFrame.new(-301.15,0,50)*CFrame.Angles(-0.3,0,0)},
        [6]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-325.655,-7.5033,54.5488)*CFrame.Angles(0,-0.69115,0),cam=CFrame.new(-338.7595,-4.0265,70.3894)*CFrame.Angles(-0.126016,-0.687243,-0.080199)},
        [7]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-344.4383,-7.5033,41.8672)*CFrame.Angles(0,-1.108982,0),cam=CFrame.new(-362.8094,-4.325,51.1551)*CFrame.Angles(-0.181885,-1.095968,-0.162135)},
        [8]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-348.5228,-7.5033,48.1022)*CFrame.Angles(0,-0.939336,0),cam=CFrame.new(-363.5051,-2.5713,59.0596)*CFrame.Angles(-0.30602,-0.916511,-0.245634)},
        [9]={hrp=CFrame.new(-339.6349,-7.5033,60.4164)*CFrame.Angles(0,-0.405266,0),cam=CFrame.new(-346.7646,-3.7365,77.0351)*CFrame.Angles(-0.137335,-0.401849,-0.054002)},
        [10]={hrp=CFrame.new(-339.4453,-7.5033,61.9429)*CFrame.Angles(0,-0.29845,0),cam=CFrame.new(-342.5024,-5.2211,71.8802)*CFrame.Angles(-0.081543,-0.297517,-0.023953)},
        [11]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-331.5262,-7.5033,-47.3607)*CFrame.Angles(0,0.003141,0),cam=CFrame.new(-331.4885,-9.6045,-59.3396)*CFrame.Angles(2.851853,-0.097011,-3.140695)},
        [12]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-338.729,-7.5033,-43.4714)*CFrame.Angles(0,-1.420208,0),cam=CFrame.new(-345.1804,-9.9578,-56.8524)*CFrame.Angles(2.856299,-0.433315,3.01906)},
        [13]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-334.5183,-7.5033,-41.6819)*CFrame.Angles(0,-0.543495,0),cam=CFrame.new(-341.912,-9.959,-53.9192)*CFrame.Angles(2.831168,-0.52207,2.982964)},
        [14]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-319.8298,-7.5033,-45.1476)*CFrame.Angles(0,-0.323585,0),cam=CFrame.new(-323.983,-9.9618,-57.5315)*CFrame.Angles(2.834406,-0.309406,3.045298)},
        [15]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-317.917,-7.5033,-41.9999)*CFrame.Angles(0,-0.565487,0),cam=CFrame.new(-325.8,-9.9581,-54.4216)*CFrame.Angles(2.835549,-0.544183,2.979445)},
        [16]={hrp=CFrame.new(-338.285,-7.5033,57.204)*CFrame.Angles(0,-0.207346,0),cam=CFrame.new(-340.4345,-9.5916,67.4219)*CFrame.Angles(0.335111,-0.196113,0.067755)},
        [17]={hrp=CFrame.new(-337.9285,-7.5033,55.1757)*CFrame.Angles(0,-0.430398,0),cam=CFrame.new(-341.7441,-8.9535,63.4867)*CFrame.Angles(0.337895,-0.408747,0.138758)},
        [18]={hrp=CFrame.new(-332.1088,-7.5033,53.1675)*CFrame.Angles(0,-0.49323,0),cam=CFrame.new(-336.3932,-9.2396,61.1377)*CFrame.Angles(0.382481,-0.462609,0.177644)},
        [19]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-328.579,-3.1209,-35.0857)*CFrame.Angles(0,0.021988,0),cam=CFrame.new(-328.5137,-10.011,-45.4753)*CFrame.Angles(2.387391,-0.004579,3.137291)},
        [20]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-321.5783,-7.5033,-33.5778)*CFrame.Angles(0,0.006284,0),cam=CFrame.new(-321.5535,-10.0218,-37.5259)*CFrame.Angles(2.387391,-0.004579,3.137291)},
        [21]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-314.088,-7.5033,-32.1806)*CFrame.Angles(0,-0.006282,0),cam=CFrame.new(-314.1147,-10.0174,-36.4214)*CFrame.Angles(2.387391,-0.004579,3.137291)},
        [22]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-306.8919,-7.5033,-33.9124)*CFrame.Angles(0,-0.006284,0),cam=CFrame.new(-306.923,-10.008,-38.86)*CFrame.Angles(2.4648,-0.004898,3.137657)},
        [23]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-300.2759,-7.5033,-32.7047)*CFrame.Angles(0,-0.031416,0),cam=CFrame.new(-300.4669,-10.016,-37.044)*CFrame.Angles(2.399014,-0.032413,3.111857)},
        [24]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-330.0484,-7.5033,48.183)*CFrame.Angles(0,-0.006377,0),cam=CFrame.new(-330.1124,-10.0063,53.2779)*CFrame.Angles(0.662308,-0.00991,0.007727)},
        [25]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-325.4576,-7.5033,46.8182)*CFrame.Angles(0,-0.125663,0),cam=CFrame.new(-326.0541,-10.0104,51.5397)*CFrame.Angles(0.700033,-0.09632,0.080833)},
        [26]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-324.6721,-7.5033,47.2033)*CFrame.Angles(0,-0.40212,0),cam=CFrame.new(-326.6859,-10.0057,51.9385)*CFrame.Angles(0.698024,-0.314979,0.254268)},
        [27]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-320.4196,-7.5033,44.1)*CFrame.Angles(0,-0.571769,0),cam=CFrame.new(-322.9213,-10.0122,49.5157)*CFrame.Angles(0.876985,-0.422603,0.397417)},
    },
}

-- ════════════════════════════════════════
-- FLASH BUTTON (fixed: align, jump+flash for floor3, grab)
-- ════════════════════════════════════════
local _lateGrabSlots={[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,[19]=true,[20]=true,[21]=true,[22]=true,[23]=true,[24]=true,[25]=true,[26]=true,[27]=true}
local function doFlash()
    local chr=lp.Character; local hrp=chr and chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local plotsFolder=workspace:FindFirstChild("Plots")
    local myBase=nil
    if plotsFolder then
        for _,plot in ipairs(plotsFolder:GetChildren()) do
            if plot:IsA("Model") then
                local sign=plot:FindFirstChild("PlotSign")
                if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then
                    local ok,order=pcall(function() return plot:GetAttribute("Order") end)
                    if ok and order then myBase=tonumber(order) end; break
                end
            end
        end
    end
    if not myBase then pcall(ShowToggleNotification,"Flash: base not detected",false); return end
    local targetBase=(myBase==1) and 2 or 1
    local podiumCFs=PODIUM_CFRAMES[targetBase]; if not podiumCFs then return end
    local selected=_G._FH_SelectedBrainrot
    if not selected then pcall(ShowToggleNotification,"Flash: select animal first",false); return end
    local slot=tonumber(selected.slot)
    if not slot then pcall(ShowToggleNotification,"Flash: no slot",false); return end
    local entry=podiumCFs[slot]
    if not entry or not entry.hrp then pcall(ShowToggleNotification,"Flash: slot "..slot.." not configured",false); return end
    if not entry.cam then pcall(ShowToggleNotification,"Flash: slot "..slot.." cam not configured",false); return end

    task.spawn(function()
        local SPEED=_G._FH_CarpetTP_Speed or 214
        local ARRIVE=4; local TIMEOUT=10
        local player=lp; local carpet=findTool("carpet")
        if carpet then _doEquip(carpet,1) end

        -- pre-start steal hold for non-late slots
        local stealCtx=nil
        if not _lateGrabSlots[slot] then
            task.spawn(function()
                local h2=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local dest=(entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
                local dist=h2 and (h2.Position-dest).Magnitude or 0
                local POST=0.10+0.15+0.07+0.30+0.12
                local preDelay=math.max(0,(dist/math.max(SPEED,1))+POST-__AG_MIN_HOLD)
                if preDelay>0 then task.wait(preDelay) end
                local tp=__AG_findTargetPrompt(); if tp then stealCtx=__AG_startStealHold(tp) end
            end)
        end

        -- phase 1: tween to walk position (or direct position if no walk)
        local targetPos=(entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
        local boostConn
        boostConn=RunService.Heartbeat:Connect(function()
            if not player.Character then return end
            local hrp2=player.Character:FindFirstChild("HumanoidRootPart"); local hum2=player.Character:FindFirstChildOfClass("Humanoid")
            if not hrp2 or not hum2 then return end
            local diff=targetPos-hrp2.Position; local flat=Vector3.new(diff.X,0,diff.Z)
            if flat.Magnitude>ARRIVE then
                local dir=flat.Unit; hrp2.Velocity=Vector3.new(dir.X*SPEED,hrp2.Velocity.Y,dir.Z*SPEED)
                -- align character facing
                hrp2.CFrame=CFrame.new(hrp2.Position,hrp2.Position+Vector3.new(dir.X,0,dir.Z))
            else hrp2.Velocity=Vector3.new(0,hrp2.Velocity.Y,0) end
        end)

        local chr2=player.Character; local hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2:MoveTo(targetPos) end
        local deadline=tick()+TIMEOUT; local lastMT=0
        repeat task.wait()
            chr2=player.Character; local hrp2=chr2 and chr2:FindFirstChild("HumanoidRootPart"); hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if not (hrp2 and hum2) then break end
            local now=tick(); if now-lastMT>=0.1 then hum2:MoveTo(targetPos); lastMT=now end
            if (hrp2.Position-targetPos).Magnitude<ARRIVE then break end
        until tick()>deadline

        boostConn:Disconnect(); boostConn=nil
        -- stop sliding
        do local h2=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if h2 then h2.Velocity=Vector3.new(0,h2.Velocity.Y,0); h2.Anchored=true; task.defer(function() task.defer(function() local c=player.Character; local hh=c and c:FindFirstChild("HumanoidRootPart"); if hh then hh.Velocity=Vector3.zero; hh.Anchored=false end end) end) end end

        -- late grab slots: start hold after phase 1
        if _lateGrabSlots[slot] then
            task.spawn(function()
                local h2=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local finalP=entry.hrp.Position; local d2=h2 and (h2.Position-finalP).Magnitude or 0
                local POST=0.10+0.15+0.07+0.30+0.12; local pre2=math.max(0,(d2/math.max(SPEED,1))+POST-__AG_MIN_HOLD)
                if pre2>0 then task.wait(pre2) end; local tp=__AG_findTargetPrompt(); if tp then stealCtx=__AG_startStealHold(tp) end
            end)
        end

        -- phase 2: tween to final position (for walk slots)
        if entry.hrpWalk then
            local finalPos=entry.hrp.Position
            local boostConn2
            boostConn2=RunService.Heartbeat:Connect(function()
                if not player.Character then return end
                local hrp3=player.Character:FindFirstChild("HumanoidRootPart"); local hum3=player.Character:FindFirstChildOfClass("Humanoid")
                if not hrp3 or not hum3 then return end
                local diff3=finalPos-hrp3.Position; local flat3=Vector3.new(diff3.X,0,diff3.Z)
                if flat3.Magnitude>ARRIVE then local dir3=flat3.Unit; hrp3.Velocity=Vector3.new(dir3.X*SPEED,hrp3.Velocity.Y,dir3.Z*SPEED); hrp3.CFrame=CFrame.new(hrp3.Position,hrp3.Position+Vector3.new(dir3.X,0,dir3.Z))
                else hrp3.Velocity=Vector3.new(0,hrp3.Velocity.Y,0) end
            end)
            chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
            if hum2 then hum2:MoveTo(finalPos) end
            deadline=tick()+TIMEOUT; lastMT=0
            repeat task.wait()
                chr2=player.Character; local hrp3=chr2 and chr2:FindFirstChild("HumanoidRootPart"); hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
                if not (hrp3 and hum2) then break end
                local now=tick(); if now-lastMT>=0.1 then hum2:MoveTo(finalPos); lastMT=now end
                if (hrp3.Position-finalPos).Magnitude<ARRIVE then break end
            until tick()>deadline
            boostConn2:Disconnect()
            -- snap to exact CFrame
            chr2=player.Character; local hrpStop=chr2 and chr2:FindFirstChild("HumanoidRootPart")
            if hrpStop then hrpStop.CFrame=entry.hrp; hrpStop.Velocity=Vector3.zero; hrpStop.Anchored=true; task.defer(function() task.defer(function() local c=player.Character; local h=c and c:FindFirstChild("HumanoidRootPart"); if h then h.Velocity=Vector3.zero; h.Anchored=false end end) end) end
        else
            chr2=player.Character; local hrpStop=chr2 and chr2:FindFirstChild("HumanoidRootPart")
            if hrpStop then hrpStop.CFrame=entry.hrp; hrpStop.Velocity=Vector3.zero; hrpStop.Anchored=true; task.defer(function() task.defer(function() local c=player.Character; local h=c and c:FindFirstChild("HumanoidRootPart"); if h then h.Velocity=Vector3.zero; h.Anchored=false end end) end) end
        end

        -- set camera
        if entry.cam then
            cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=entry.cam
            task.defer(function() cam.CFrame=entry.cam; task.defer(function() cam.CFrame=entry.cam; cam.CameraType=Enum.CameraType.Custom end) end)
        end

        -- equip carpet midway
        local carpetMid=findTool("carpet"); if carpetMid then _doEquip(carpetMid,1.5) end
        task.wait(0.3)

        -- for floor 3 slots (jump slots): jump + IMMEDIATELY equip and fire flash tool
        local needsJump=_lateGrabSlots[slot]
        chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
        if needsJump and hum2 then hum2:ChangeState(Enum.HumanoidStateType.Jumping) end

        -- unequip carpet
        if hum2 then pcall(function() hum2:UnequipTools() end) end; task.wait(0.07)

        -- find + equip flash
        local flashTool=findTool("flash")
        if not flashTool then pcall(ShowToggleNotification,"Flash: tool not found",false); return end
        local _flashEq=false; local _feConn; _feConn=flashTool.Equipped:Connect(function() _flashEq=true; _feConn:Disconnect() end)
        flashTool.Parent=chr2; pcall(function() hum2:EquipTool(flashTool) end)
        local eqDL=tick()+1.2; while not _flashEq and tick()<eqDL do task.wait() end
        if _feConn then pcall(function() _feConn:Disconnect() end) end

        -- fire flash (for floor 3 slots, fire immediately during jump)
        pcall(function() flashTool:Activate() end)
        task.wait(0.02)
        pcall(function() flashTool:Activate() end)

        -- finish steal
        task.spawn(function()
            task.wait(0.08)
            if not RagdollBypassEnabled then
                if stealCtx then triggerAutoBlock(); __AG_finishStealHold(stealCtx)
                elseif type(_G._sv2DoSteal)=="function" then triggerAutoBlock(); pcall(_G._sv2DoSteal) end
            end
        end)

        task.wait(0.05)
        if hum2 then pcall(function() hum2:UnequipTools() end) end
        task.wait(0.05)
        local bp2=player:FindFirstChild("Backpack"); if bp2 and flashTool and flashTool.Parent~=bp2 then flashTool.Parent=bp2 end

        -- potion
        local potionTool=findTool("potion")
        if potionTool and RagdollBypassEnabled then
            potionTool.Parent=chr2; pcall(function() hum2:EquipTool(potionTool) end); task.wait(0.05)
            pcall(function() potionTool:Activate() end); task.wait(0.05); pcall(function() potionTool:Activate() end)
            task.wait(0.08); if hum2 then pcall(function() hum2:UnequipTools() end) end; task.wait(0.05)
            local bp4=player:FindFirstChild("Backpack"); if bp4 and potionTool and potionTool.Parent~=bp4 then potionTool.Parent=bp4 end
        end

        -- ragdoll bypass
        if RagdollBypassEnabled then
            task.spawn(function()
                task.wait(0.1); _ragdollSelf(); triggerAutoBlock()
                local _kicked=false; local kc1,kc2
                local tgtPlayer=nil
                if selected then
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p.Name==selected.owner or p.DisplayName==selected.owner then tgtPlayer=p; break end
                    end
                end
                local tgtChar=tgtPlayer and tgtPlayer.Character; local tgtHum=tgtChar and tgtChar:FindFirstChildOfClass("Humanoid")
                local function onKicked()
                    if _kicked then return end; _kicked=true
                    if kc1 then pcall(function() kc1:Disconnect() end) end; if kc2 then pcall(function() kc2:Disconnect() end) end
                    local wf=0; while not stealCtx and wf<3 do task.wait(); wf=wf+1 end
                    if not stealCtx then local fp=__AG_findTargetPrompt(); if fp then stealCtx=__AG_startStealHold(fp) end end
                    if stealCtx then __AG_finishStealHold(stealCtx) end
                end
                if tgtHum then
                    kc1=tgtHum.StateChanged:Connect(function(_,new) if new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll or new==Enum.HumanoidStateType.FallingDown then onKicked() end end)
                    kc2=tgtHum:GetPropertyChangedSignal("PlatformStand"):Connect(function() if tgtHum.PlatformStand then onKicked() end end)
                end
                task.delay(0.4,function() if not _kicked then onKicked() end end)
            end)
        end

        -- equip carpet after
        local carpetAfter=findTool("carpet"); if carpetAfter then _doEquip(carpetAfter,1) end
        pcall(ShowToggleNotification,"Flash → Base "..targetBase.." Podium "..slot,true)
    end)
end

-- ════════════════════════════════════════
-- HEADER BUTTONS
-- ════════════════════════════════════════
_G._FH_ResetBtnEntry=makeActionBtn("RESET",2,doSelectedReset)
_G._FH_FlashBtnEntry=makeActionBtn("FLASH",3,doFlash)
_G._FH_BlockBtnEntry=makeActionBtn("BLOCK",4,function() blockPlayer(getNearestPlayer()); pcall(ShowToggleNotification,"Block fired",true) end)

UserInputService.InputBegan:Connect(function(inp,gpe)
    if hdrBindTarget then
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            local t=hdrBindTarget; hdrBindTarget=nil
            if inp.KeyCode==Enum.KeyCode.Escape then t.refresh()
            elseif inp.KeyCode==Enum.KeyCode.Backspace then t.keyCode=nil; Config.keybinds[t.configKey]=nil; pcall(FH_SaveConfig); t.refresh()
            else t.keyCode=inp.KeyCode; Config.keybinds[t.configKey]=inp.KeyCode.Name; pcall(FH_SaveConfig); t.refresh() end
        elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then local t=hdrBindTarget; hdrBindTarget=nil; t.refresh() end; return
    end
    if gpe then return end
    if inp.UserInputType==Enum.UserInputType.Keyboard then
        for _,e in ipairs(hdrBinds) do if e.keyCode and inp.KeyCode==e.keyCode then e.fire() end end
        for _,binding in ipairs(keybindEntries) do if binding.entry.keyCode and inp.KeyCode==binding.entry.keyCode then binding.fire() end end
    end
end)

-- drag
do
    local dragging,dragStart,winStart,_moved=false,nil,nil,false
    Hdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; _moved=false; dragStart=inp.Position; winStart=Win.Position
        end
    end)
    Hdr.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false; _moved=false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local d=inp.Position-dragStart; if not _moved and d.Magnitude<6 then return end; _moved=true
            Win.Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,winStart.Y.Scale,winStart.Y.Offset+d.Y)
        end
    end)
end

-- ════════════════════════════════════════
-- TAB SYSTEM (exact Faded Flash)
-- ════════════════════════════════════════
local TabBar=Instance.new("Frame",Win); TabBar.Size=UDim2.new(1,0,0,34); TabBar.Position=UDim2.new(0,0,0,40); TabBar.BackgroundColor3=Color3.fromRGB(8,8,12); TabBar.BackgroundTransparency=0.2; TabBar.BorderSizePixel=0; TabBar.ZIndex=4
local TBLine=Instance.new("Frame",Win); TBLine.Size=UDim2.new(1,0,0,1); TBLine.Position=UDim2.new(0,0,0,74); TBLine.BackgroundColor3=T.Border; TBLine.BorderSizePixel=0; TBLine.ZIndex=5
local TabLayout=Instance.new("UIListLayout",TabBar); TabLayout.FillDirection=Enum.FillDirection.Horizontal; TabLayout.VerticalAlignment=Enum.VerticalAlignment.Center; TabLayout.Padding=UDim.new(0,0)
local ContentArea=Instance.new("Frame",Win); ContentArea.Size=UDim2.new(1,0,1,-75); ContentArea.Position=UDim2.new(0,0,0,75); ContentArea.BackgroundTransparency=1; ContentArea.ClipsDescendants=true; ContentArea.ZIndex=2

local Tabs={}; local ActiveTab=nil; local TabSwiping=false
local SLIDE_IN=TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local SLIDE_OUT=TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local function TabIndex(tab) for i,t in ipairs(Tabs) do if t==tab then return i end end; return 0 end
local function ActivateTab(tab)
    if ActiveTab==tab then return end; if TabSwiping then return end
    local old=ActiveTab; ActiveTab=tab
    if old then Tween(old.lbl,F,{TextColor3=T.TabInact}); Tween(old.indicator,M,{Size=UDim2.new(0,0,0,2)}) end
    Tween(tab.lbl,F,{TextColor3=T.TabActive}); Tween(tab.indicator,M,{Size=UDim2.new(0.8,0,0,2)})
    if old then
        TabSwiping=true; local right=(TabIndex(tab)>TabIndex(old))
        tab.page.Position=right and UDim2.new(1,0,0,0) or UDim2.new(-1,0,0,0); tab.page.Visible=true
        local exitPos=right and UDim2.new(-1,0,0,0) or UDim2.new(1,0,0,0); Tween(old.page,SLIDE_OUT,{Position=exitPos})
        local tw=TweenService:Create(tab.page,SLIDE_IN,{Position=UDim2.new(0,0,0,0)}); tw:Play()
        tw.Completed:Connect(function() old.page.Visible=false; old.page.Position=UDim2.new(0,0,0,0); TabSwiping=false end)
    else tab.page.Position=UDim2.new(0,0,0,0); tab.page.Visible=true end
end

local function MakeScroll(parent)
    local s=Instance.new("ScrollingFrame",parent); s.Size=UDim2.new(1,0,1,0); s.BackgroundTransparency=1; s.BorderSizePixel=0; s.ScrollBarThickness=3; s.ScrollBarImageColor3=Color3.fromRGB(50,80,160); s.CanvasSize=UDim2.new(0,0,0,0); s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.ScrollingDirection=Enum.ScrollingDirection.Y; s.ZIndex=2
    local layout=Instance.new("UIListLayout",s); layout.FillDirection=Enum.FillDirection.Vertical; layout.HorizontalAlignment=Enum.HorizontalAlignment.Center; layout.Padding=UDim.new(0,6)
    Padding(s,10,10,8,8); return s
end

local function CreateTab(name)
    local btn=Instance.new("TextButton",TabBar); btn.Size=UDim2.new(0.5,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=5
    local nameLbl=Label(btn,name,isMobile and 9 or 11,T.TabInact,Enum.Font.GothamBold); nameLbl.Size=UDim2.new(1,-2,1,0); nameLbl.TextXAlignment=Enum.TextXAlignment.Center; nameLbl.ZIndex=6
    local indicator=Instance.new("Frame",btn); indicator.Size=UDim2.new(0,0,0,2); indicator.Position=UDim2.new(0.1,0,1,-2); indicator.BackgroundColor3=T.Blue; indicator.BorderSizePixel=0; indicator.ZIndex=7; Corner(indicator,1)
    local page=Instance.new("Frame",ContentArea); page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=false; page.ClipsDescendants=true; page.ZIndex=2
    local scroll=MakeScroll(page)
    local tab={btn=btn,lbl=nameLbl,indicator=indicator,page=page,scroll=scroll}
    btn.MouseButton1Click:Connect(function() ActivateTab(tab) end)
    table.insert(Tabs,tab); return tab
end

local function CreateSection(parent,title)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,-16,0,26); f.BackgroundTransparency=1
    local lw=#title*7+6; local lbl=Label(f,title,10,T.Dim,Enum.Font.GothamBold); lbl.Size=UDim2.new(0,lw,1,0); lbl.Position=UDim2.new(0,4,0,0); lbl.ZIndex=2
    local line=Instance.new("Frame",f); line.Size=UDim2.new(1,-(lw+14),0,1); line.Position=UDim2.new(0,lw+10,0.5,0); line.BackgroundColor3=T.Border; line.BorderSizePixel=0
end

local function CreateToggle(parent,name,desc,cb)
    local state=(Config.toggles[name]==true)
    local hasDesc=desc and desc~=""
    local cardH=hasDesc and 56 or 44
    local card=Instance.new("Frame",parent); card.Size=UDim2.new(1,-16,0,cardH); card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.15; card.BorderSizePixel=0; Corner(card,8)
    local cStroke=Stroke(card,T.Border,1)
    local bar=Instance.new("Frame",card); bar.Size=UDim2.new(0,3,0,cardH-16); bar.Position=UDim2.new(0,0,0,8); bar.BackgroundColor3=T.TrackOff; bar.BorderSizePixel=0; bar.ZIndex=2; Corner(bar,2)
    local nameY=hasDesc and 10 or (cardH/2-8)
    local nameLbl=Label(card,name,isMobile and 11 or 13,T.White,Enum.Font.GothamMedium); nameLbl.Size=UDim2.new(1,-108,0,16); nameLbl.Position=UDim2.new(0,14,0,nameY); nameLbl.ZIndex=2; nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
    if hasDesc then local dl=Label(card,desc,isMobile and 9 or 11,T.Dim,Enum.Font.Gotham); dl.Size=UDim2.new(1,-108,0,14); dl.Position=UDim2.new(0,14,0,nameY+18); dl.ZIndex=2; dl.TextTruncate=Enum.TextTruncate.AtEnd end
    local kbLbl=Instance.new("TextLabel",card); kbLbl.Size=UDim2.new(0,32,0,16); kbLbl.Position=UDim2.new(1,-92,0.5,-8); kbLbl.BackgroundTransparency=1; kbLbl.Text=""; kbLbl.TextSize=10; kbLbl.Font=Enum.Font.GothamBold; kbLbl.TextColor3=T.Dim; kbLbl.TextXAlignment=Enum.TextXAlignment.Center; kbLbl.ZIndex=3
    local track=Instance.new("Frame",card); track.Size=UDim2.new(0,40,0,22); track.Position=UDim2.new(1,-52,0.5,-11); track.BackgroundColor3=T.TrackOff; track.BorderSizePixel=0; track.ZIndex=2; Corner(track,11)
    local tStroke=Stroke(track,T.Border,1)
    local knob=Instance.new("Frame",track); knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,3,0.5,-8); knob.BackgroundColor3=T.KnobOff; knob.BorderSizePixel=0; knob.ZIndex=3; Corner(knob,8)
    card.MouseEnter:Connect(function() Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end)
    card.MouseLeave:Connect(function() Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}) end)
    local btn=Instance.new("Frame",card); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.ZIndex=4; btn.Active=true
    local keybindEntry={keyCode=nil}
    local function applyVisual(s)
        if s then knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,21,0.5,-8); knob.BackgroundColor3=T.KnobOn; track.BackgroundColor3=T.TrackOn; tStroke.Color=T.Blue; bar.BackgroundColor3=T.Blue
        else knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,3,0.5,-8); knob.BackgroundColor3=T.KnobOff; track.BackgroundColor3=T.TrackOff; tStroke.Color=T.Border; bar.BackgroundColor3=T.TrackOff end
    end
    local function doToggle()
        state=not state
        if state then
            Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,4,0.5,-7)}); task.delay(0.06,function()
                Tween(knob,M,{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,21,0.5,-8)}); Tween(knob,M,{BackgroundColor3=T.KnobOn}); Tween(track,M,{BackgroundColor3=T.TrackOn}); Tween(tStroke,M,{Color=T.Blue}); Tween(bar,M,{BackgroundColor3=T.Blue}) end)
        else
            Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,20,0.5,-7)}); task.delay(0.06,function()
                Tween(knob,M,{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0.5,-8)}); Tween(knob,M,{BackgroundColor3=T.KnobOff}); Tween(track,M,{BackgroundColor3=T.TrackOff}); Tween(tStroke,M,{Color=T.Border}); Tween(bar,M,{BackgroundColor3=T.TrackOff}) end)
        end
        if cb then pcall(cb,state) end; Config.toggles[name]=state; pcall(FH_SaveConfig); pcall(ShowToggleNotification,name,state)
    end
    local _ta=false; local _ts=nil
    btn.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then _ta=true; _ts=inp.Position end end)
    btn.InputEnded:Connect(function(inp) if (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) and _ta then _ta=false; if _ts and (inp.Position-_ts).Magnitude<20 then doToggle() end; _ts=nil end end)
    btn.InputBegan:Connect(function(inp) if inp.UserInputType~=Enum.UserInputType.MouseButton2 then return end
        if keybindBindingTarget then local p=keybindBindingTarget; keybindBindingTarget=nil; if p.kbLbl==kbLbl then kbLbl.Text=keybindEntry.keyCode and ("["..keybindEntry.keyCode.Name.."]") or ""; kbLbl.TextColor3=T.Dim; return else p.kbLbl.Text=p.entry.keyCode and ("["..p.entry.keyCode.Name.."]") or ""; p.kbLbl.TextColor3=T.Dim end end
        kbLbl.Text="(...)"; kbLbl.TextColor3=T.White; keybindBindingTarget={entry=keybindEntry,kbLbl=kbLbl,mode="assign"}
    end)
    table.insert(keybindEntries,{entry=keybindEntry,fire=doToggle})
    configRegistry[name]={
        getState=function() return state end,
        getKeyCode=function() return keybindEntry.keyCode end,
        setKeyCode=function(kc) keybindEntry.keyCode=kc; if kc then kbLbl.Text="["..kc.Name.."]"; kbLbl.TextColor3=T.Dim; Config.keybinds[name]=kc.Name else kbLbl.Text=""; Config.keybinds[name]=nil end; pcall(FH_SaveConfig) end,
        doToggle=doToggle,
        setEnabled=function(v) state=v; applyVisual(v); Config.toggles[name]=v; pcall(FH_SaveConfig); if cb then pcall(cb,v) end end,
    }
    if state then applyVisual(true); if cb then task.spawn(function() pcall(cb,true) end) end end
    local sk=Config.keybinds[name]; if sk then local ok,kc=pcall(function() return Enum.KeyCode[sk] end); if ok and kc then keybindEntry.keyCode=kc; kbLbl.Text="["..kc.Name.."]"; kbLbl.TextColor3=T.Dim end end
end

local function CreateButton(parent,name,desc,cb)
    local hasDesc=desc and desc~=""; local cardH=hasDesc and 56 or 44
    local card=Instance.new("Frame",parent); card.Size=UDim2.new(1,-16,0,cardH); card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.15; card.BorderSizePixel=0; Corner(card,8)
    local cStroke=Stroke(card,T.Border,1)
    local bar=Instance.new("Frame",card); bar.Size=UDim2.new(0,3,0,cardH-16); bar.Position=UDim2.new(0,0,0,8); bar.BackgroundColor3=T.TrackOff; bar.BorderSizePixel=0; bar.ZIndex=2; Corner(bar,2)
    local nameY=hasDesc and 10 or (cardH/2-8)
    local nameLbl=Label(card,name,isMobile and 11 or 13,T.White,Enum.Font.GothamMedium); nameLbl.Size=UDim2.new(1,-70,0,16); nameLbl.Position=UDim2.new(0,14,0,nameY); nameLbl.ZIndex=2; nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
    if hasDesc then local dl=Label(card,desc,isMobile and 9 or 11,T.Dim,Enum.Font.Gotham); dl.Size=UDim2.new(1,-70,0,14); dl.Position=UDim2.new(0,14,0,nameY+18); dl.ZIndex=2 end
    local kbLbl=Instance.new("TextLabel",card); kbLbl.Size=UDim2.new(0,28,0,16); kbLbl.Position=UDim2.new(1,-88,0.5,-8); kbLbl.BackgroundTransparency=1; kbLbl.Text=""; kbLbl.TextSize=10; kbLbl.Font=Enum.Font.GothamBold; kbLbl.TextColor3=T.Dim; kbLbl.TextXAlignment=Enum.TextXAlignment.Center; kbLbl.ZIndex=3
    local runLbl=Instance.new("TextLabel",card); runLbl.Size=UDim2.new(0,48,0,24); runLbl.Position=UDim2.new(1,-56,0.5,-12); runLbl.BackgroundColor3=Color3.fromRGB(20,40,80); runLbl.BorderSizePixel=0; runLbl.Text="RUN"; runLbl.TextSize=11; runLbl.Font=Enum.Font.GothamBold; runLbl.TextColor3=T.White; runLbl.TextXAlignment=Enum.TextXAlignment.Center; runLbl.ZIndex=3; Corner(runLbl,6); local rs=Stroke(runLbl,T.Blue,1)
    card.MouseEnter:Connect(function() Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end)
    card.MouseLeave:Connect(function() Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}) end)
    local btn=Instance.new("Frame",card); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.ZIndex=4; btn.Active=true
    local keybindEntry={keyCode=nil}
    local function fireButton()
        Tween(bar,F,{BackgroundColor3=T.Blue}); Tween(runLbl,F,{BackgroundColor3=T.Blue}); Tween(rs,F,{Color=T.White}); runLbl.TextColor3=T.White
        if cb then task.spawn(function() pcall(cb) end) end
        task.delay(0.3,function() Tween(bar,M,{BackgroundColor3=T.TrackOff}); Tween(runLbl,M,{BackgroundColor3=Color3.fromRGB(20,40,80)}); Tween(rs,M,{Color=T.Blue}) end)
    end
    local _deb=false; local _ats=nil
    btn.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then if _deb then return end; _deb=true; fireButton(); task.delay(0.4,function() _deb=false end) elseif inp.UserInputType==Enum.UserInputType.Touch then _ats=inp.Position end end)
    btn.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch and _ats then local m=(inp.Position-_ats).Magnitude; _ats=nil; if m<20 then if _deb then return end; _deb=true; fireButton(); task.delay(0.4,function() _deb=false end) end end end)
    btn.InputBegan:Connect(function(inp) if inp.UserInputType~=Enum.UserInputType.MouseButton2 then return end
        if keybindBindingTarget then local p=keybindBindingTarget; keybindBindingTarget=nil; if p.kbLbl==kbLbl then kbLbl.Text=keybindEntry.keyCode and ("["..keybindEntry.keyCode.Name.."]") or ""; kbLbl.TextColor3=T.Dim; return else p.kbLbl.Text=p.entry.keyCode and ("["..p.entry.keyCode.Name.."]") or ""; p.kbLbl.TextColor3=T.Dim end end
        kbLbl.Text="(...)"; kbLbl.TextColor3=T.White; keybindBindingTarget={entry=keybindEntry,kbLbl=kbLbl,mode="assign"}
    end)
    table.insert(keybindEntries,{entry=keybindEntry,fire=fireButton})
    configRegistry[name]={getState=function() return false end,getKeyCode=function() return keybindEntry.keyCode end,setKeyCode=function(kc) keybindEntry.keyCode=kc; if kc then kbLbl.Text="["..kc.Name.."]"; kbLbl.TextColor3=T.Dim; Config.keybinds[name]=kc.Name else kbLbl.Text=""; Config.keybinds[name]=nil end; pcall(FH_SaveConfig) end}
    local sk=Config.keybinds[name]; if sk then local ok,kc=pcall(function() return Enum.KeyCode[sk] end); if ok and kc then keybindEntry.keyCode=kc; kbLbl.Text="["..kc.Name.."]"; kbLbl.TextColor3=T.Dim end end
end

-- ════════════════════════════════════════
-- SCAN SYSTEM
-- ════════════════════════════════════════
local animalsByPlot={}; local myPlotName=nil; local needsUpdate=false; local lastListHash=""; local buttonCache={}
local selectedUID=nil; local onSelectCBs={}

local function fmtNum(n)
    if NumberUtils and NumberUtils.ToString then local ok,s=pcall(function() return NumberUtils:ToString(n) end); if ok and s then return s end end; return tostring(n)
end
local function getGeneration(index,mutation,traits)
    if not (AnimalsShared and AnimalsShared.GetGeneration) then return 0 end
    local ok,v=pcall(function() return AnimalsShared:GetGeneration(index,mutation,traits,nil) end); if ok and v then return v end
    local ok2,v2=pcall(function() return AnimalsShared:GetGeneration(index) end); return (ok2 and v2) or 0
end
local function displayName(index) local info=AnimalsData and AnimalsData[index]; return (info and info.DisplayName) or tostring(index) end
local function getRarity(index) local info=AnimalsData and AnimalsData[index]; return (info and info.Rarity) or "Common" end
local function isMyPlot(plot) local sign=plot:FindFirstChild("PlotSign"); return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled or false end
local function plotOwner(plot)
    local sign=plot:FindFirstChild("PlotSign",true)
    if sign then for _,d in ipairs(sign:GetDescendants()) do if d:IsA("TextLabel") and d.Text and d.Text~="" then local t=d.Text; if t:lower():find("empty") then return "Empty" end; local m=t:match("[Bb]ase [Oo]f%s+(.+)"); if m then return m end; if #t>0 and #t<30 then return t end end end end
    return "?"
end
local function getPlotOrder(plot) local ok,o=pcall(function() return plot:GetAttribute("Order") end); if ok and o then return "Base "..tostring(o) end; return plot.Name end
local RequestData; pcall(function() local pkg=ReplicatedStorage:WaitForChild("Packages",15):WaitForChild("Synchronizer",15); RequestData=pkg:FindFirstChild("RequestData") end)
local function getAnimalList(plot)
    if RequestData then local ok,data=pcall(function() return RequestData:InvokeServer(plot.Name) end); if ok and typeof(data)=="table" and typeof(data.AnimalList)=="table" then return data.AnimalList end end
    return nil
end
local function scanAllAnimals()
    local results={}; local plotsFolder=workspace:FindFirstChild("Plots"); if not plotsFolder then return results end
    for _,plot in ipairs(plotsFolder:GetChildren()) do
        if not plot:IsA("Model") then continue end; if isMyPlot(plot) then myPlotName=plot.Name; continue end
        pcall(function()
            local animalList=getAnimalList(plot); if typeof(animalList)~="table" then return end
            local owner=plotOwner(plot)
            for slot,data in pairs(animalList) do
                pcall(function()
                    if typeof(data)=="table" and data.Index then
                        local gen=getGeneration(data.Index,data.Mutation,data.Traits)
                        table.insert(results,{name=displayName(data.Index),animalIndex=data.Index,mutation=data.Mutation,traits=data.Traits,genValue=gen,genText="$"..fmtNum(gen).."/s",rarity=getRarity(data.Index),plotName=plot.Name,plotOrder=getPlotOrder(plot),owner=owner,slot=tostring(slot)})
                    end
                end)
            end
        end)
    end
    table.sort(results,function(a,b) return (a.genValue or 0)>(b.genValue or 0) end); return results
end

local scanning=false; local _lastAnimalScan={}
local function doScan()
    if scanning then return end; scanning=true
    task.spawn(function()
        local ok,results=pcall(scanAllAnimals); if not ok or not results then results={} end
        _lastAnimalScan=results; needsUpdate=true; scanning=false
    end)
end
task.spawn(function() task.wait(2); while true do doScan(); task.wait(5) end end)

-- ════════════════════════════════════════
-- BRAINROT TAB
-- ════════════════════════════════════════
local BrainrotsTab=CreateTab("BRAINROTS")
local SettingsTab=CreateTab("SETTINGS")
ActivateTab(BrainrotsTab)

CreateSection(BrainrotsTab.scroll,"ANIMALS")
local cardContainer=Instance.new("Frame",BrainrotsTab.scroll); cardContainer.BackgroundTransparency=1; cardContainer.Size=UDim2.new(1,-16,0,0); cardContainer.AutomaticSize=Enum.AutomaticSize.Y; cardContainer.BorderSizePixel=0
local cardLayout=Instance.new("UIListLayout",cardContainer); cardLayout.FillDirection=Enum.FillDirection.Vertical; cardLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center; cardLayout.SortOrder=Enum.SortOrder.LayoutOrder; cardLayout.Padding=UDim.new(0,6)

local CARD_H=90
local labelUpdaters={}
local function buildAnimalCard(rec,index)
    local uid=rec.plotName.."_"..rec.slot
    local card=Instance.new("Frame",cardContainer); card.Size=UDim2.new(1,0,0,CARD_H); card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.15; card.BorderSizePixel=0; card.LayoutOrder=index; Corner(card,8)
    local cStroke=Stroke(card,T.Border,1)

    -- left accent bar (blue)
    local accent=Instance.new("Frame",card); accent.Size=UDim2.new(0,3,1,-12); accent.Position=UDim2.new(0,0,0,6); accent.BackgroundColor3=T.Blue; accent.BorderSizePixel=0; Corner(accent,2)

    -- info
    local infoF=Instance.new("Frame",card); infoF.Size=UDim2.new(1,-20,1,0); infoF.Position=UDim2.fromOffset(14,0); infoF.BackgroundTransparency=1; infoF.ZIndex=3

    local nameLbl=Label(infoF,rec.name,isMobile and 12 or 14,T.White,Enum.Font.GothamBold); nameLbl.Size=UDim2.new(1,-70,0,18); nameLbl.Position=UDim2.fromOffset(0,8); nameLbl.ZIndex=3; nameLbl.TextTruncate=Enum.TextTruncate.AtEnd

    -- rarity pill
    local rarCol=Color3.fromRGB(80,150,255)
    if rec.rarity=="Legendary" then rarCol=Color3.fromRGB(255,180,0) elseif rec.rarity=="Epic" then rarCol=Color3.fromRGB(180,80,255) elseif rec.rarity=="Rare" then rarCol=Color3.fromRGB(80,200,120) end
    local rarPill=Instance.new("Frame",infoF); rarPill.Size=UDim2.new(0,0,0,14); rarPill.Position=UDim2.new(0,0,0,28); rarPill.AutomaticSize=Enum.AutomaticSize.X; rarPill.BackgroundColor3=rarCol; rarPill.BackgroundTransparency=0.6; rarPill.BorderSizePixel=0; Corner(rarPill,7); local rp=Instance.new("UIPadding",rarPill); rp.PaddingLeft=UDim.new(0,5); rp.PaddingRight=UDim.new(0,5)
    local rarLbl=Label(rarPill,rec.rarity,8,T.White,Enum.Font.GothamBold); rarLbl.Size=UDim2.new(0,0,1,0); rarLbl.AutomaticSize=Enum.AutomaticSize.X; rarLbl.TextXAlignment=Enum.TextXAlignment.Center

    local genLbl=Label(infoF,rec.genText,isMobile and 10 or 12,Color3.fromRGB(80,200,120),Enum.Font.GothamBold); genLbl.Size=UDim2.new(1,-70,0,14); genLbl.Position=UDim2.fromOffset(0,46); genLbl.ZIndex=3

    local mutText=rec.mutation and rec.mutation~="None" and rec.mutation or "No Mutation"
    local mutLbl=Label(infoF,mutText,isMobile and 9 or 10,T.Dim,Enum.Font.Gotham); mutLbl.Size=UDim2.new(1,-70,0,12); mutLbl.Position=UDim2.fromOffset(0,62); mutLbl.ZIndex=3; mutLbl.TextTruncate=Enum.TextTruncate.AtEnd

    local podLbl=Label(infoF,(rec.plotOrder or rec.plotName).." · Podium #"..rec.slot,isMobile and 8 or 9,T.Dim,Enum.Font.Gotham); podLbl.Size=UDim2.new(1,-70,0,12); podLbl.Position=UDim2.fromOffset(0,75); podLbl.ZIndex=3

    -- SELECT button
    local selBtn=Instance.new("TextButton",infoF); selBtn.Size=UDim2.new(0,58,0,22); selBtn.Position=UDim2.new(1,-60,0.5,-11); selBtn.BackgroundColor3=T.Card; selBtn.BorderSizePixel=0; selBtn.Text="SELECT"; selBtn.TextSize=9; selBtn.Font=Enum.Font.GothamBold; selBtn.TextColor3=T.Dim; selBtn.ZIndex=4; selBtn.AutoButtonColor=false; Corner(selBtn,6); local ss=Stroke(selBtn,T.Border,1)

    local isSelected=false
    local function applySelVis(v)
        isSelected=v
        if v then Tween(selBtn,F,{BackgroundColor3=T.Blue,TextColor3=T.White}); Tween(ss,F,{Color=T.White}); Tween(cStroke,F,{Color=T.Blue,Thickness=2}); accent.BackgroundColor3=T.White
        else Tween(selBtn,F,{BackgroundColor3=T.Card,TextColor3=T.Dim}); Tween(ss,F,{Color=T.Border}); Tween(cStroke,F,{Color=T.Border,Thickness=1}); accent.BackgroundColor3=T.Blue end
    end
    onSelectCBs[uid]=function(forceOff) if forceOff and isSelected then applySelVis(false) end end

    selBtn.MouseButton1Click:Connect(function()
        if isSelected then
            applySelVis(false); selectedUID=nil; _G._FH_SelectedBrainrot=nil
        else
            if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
            applySelVis(true); selectedUID=uid
            _G._FH_SelectedBrainrot={uid=uid,name=rec.name,mutation=rec.mutation,gen=rec.genValue,genText=rec.genText,plotName=rec.plotName,slot=rec.slot,owner=rec.owner}
        end
    end)
    card.MouseEnter:Connect(function() if not isSelected then Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end end)
    card.MouseLeave:Connect(function() if not isSelected then Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}) end end)

    labelUpdaters[uid]=function(newRec,newIndex)
        nameLbl.Text=newRec.name; genLbl.Text=newRec.genText; mutLbl.Text=newRec.mutation and newRec.mutation~="None" and newRec.mutation or "No Mutation"; podLbl.Text=(newRec.plotOrder or newRec.plotName).." · Podium #"..newRec.slot; card.LayoutOrder=newIndex
    end
    buttonCache[uid]=card; return card
end

local builtUIDs={}
local function buildList()
    local sorted=_lastAnimalScan; local seenUIDs={}
    for _,rec in ipairs(sorted) do seenUIDs[rec.plotName.."_"..rec.slot]=true end
    for uid in pairs(builtUIDs) do
        if not seenUIDs[uid] then local c=buttonCache[uid]; if c then c:Destroy() end; builtUIDs[uid]=nil; labelUpdaters[uid]=nil; onSelectCBs[uid]=nil; if selectedUID==uid then selectedUID=nil; _G._FH_SelectedBrainrot=nil end end
    end
    for i,rec in ipairs(sorted) do
        local uid=rec.plotName.."_"..rec.slot
        if not builtUIDs[uid] then local c=buildAnimalCard(rec,i); c.Name="Card_"..uid; builtUIDs[uid]=true
        else if labelUpdaters[uid] then labelUpdaters[uid](rec,i) end end
    end
end

task.spawn(function()
    while true do task.wait(0.5)
        if needsUpdate then
            needsUpdate=false; local cur=_lastAnimalScan
            if selectedUID then local ex=false; for _,a in ipairs(cur) do if (a.plotName.."_"..a.slot)==selectedUID then ex=true; break end end; if not ex then selectedUID=nil; _G._FH_SelectedBrainrot=nil; pcall(ShowToggleNotification,"Target Lost",false) end end
            local hash=tostring(#cur); for _,a in ipairs(cur) do hash=hash..a.plotName..a.slot end
            if hash~=lastListHash then lastListHash=hash; buildList() end
        end
    end
end)

-- ════════════════════════════════════════
-- PLAYER ESP
-- ════════════════════════════════════════
local ESPTAG="VxE_"..tostring(math.random(1000,9999)); local pEspOn=false
local function mkESP(plr)
    if plr==lp then return end; local char=plr.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end
    local box=Instance.new("BoxHandleAdornment",char); box.Name=ESPTAG; box.Adornee=hrp; box.Size=Vector3.new(4,6,2); box.Color3=T.Blue; box.Transparency=0.4; box.ZIndex=10; box.AlwaysOnTop=true
    local bb=Instance.new("BillboardGui",char); bb.Name=ESPTAG.."N"; bb.Adornee=char:FindFirstChild("Head") or hrp; bb.Size=UDim2.fromOffset(130,24); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true
    local bgE=Instance.new("Frame",bb); bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=T.BG; bgE.BackgroundTransparency=0.2; bgE.BorderSizePixel=0; Corner(bgE,5); Stroke(bgE,T.Blue,0.8)
    local dn=Label(bgE,plr.DisplayName,9,T.White,Enum.Font.GothamBold); dn.Size=UDim2.new(1,0,0.58,0)
    local un=Label(bgE,"@"..plr.Name,7,T.Dim,Enum.Font.Gotham); un.Size=UDim2.new(1,0,0.42,0); un.Position=UDim2.new(0,0,0.58,0)
end
local function enablePlayerESP()
    pEspOn=true; for _,p in ipairs(Players:GetPlayers()) do task.defer(function() mkESP(p) end) end
end
local function disablePlayerESP()
    pEspOn=false
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then for _,v in ipairs(p.Character:GetChildren()) do if v.Name==ESPTAG or v.Name==ESPTAG.."N" then v:Destroy() end end end end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); if pEspOn then mkESP(p) end end) end)
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then p.CharacterAdded:Connect(function() task.wait(0.5); if pEspOn then mkESP(p) end end) end end

-- ════════════════════════════════════════
-- TIMER ESP
-- ════════════════════════════════════════
local timerESPs={}; local timerOn=false
task.spawn(function()
    while true do task.wait(0.4)
        if not timerOn then for _,e in pairs(timerESPs) do pcall(function() e.bb:Destroy() end) end; timerESPs={}; continue end
        local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
        for _,plot in ipairs(plots:GetChildren()) do
            local pur=plot:FindFirstChild("Purchases"); local pb2=pur and pur:FindFirstChild("PlotBlock"); local mp=pb2 and pb2:FindFirstChild("Main")
            local tl2=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
            if tl2 and mp then
                local e=timerESPs[plot.Name]
                if not e or not e.bb.Parent then
                    if e then pcall(function() e.bb:Destroy() end) end
                    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(54,15); bb.StudsOffset=Vector3.new(0,7,0); bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
                    local bgT=Instance.new("Frame",bb); bgT.Size=UDim2.new(1,0,1,0); bgT.BackgroundColor3=T.BG; bgT.BackgroundTransparency=0.18; bgT.BorderSizePixel=0; Corner(bgT,4)
                    local stk=Stroke(bgT,T.Blue,0.8); local tll=Label(bgT,"",9,T.Blue,Enum.Font.GothamBold); tll.Size=UDim2.new(1,0,1,0); tll.TextXAlignment=Enum.TextXAlignment.Center
                    timerESPs[plot.Name]={bb=bb,lbl=tll,stk=stk}; e=timerESPs[plot.Name]
                end
                e.lbl.Text=tl2.Text; local m2,s2=tl2.Text:match("(%d+):(%d+)")
                if m2 and s2 then local tot=tonumber(m2)*60+tonumber(s2); local col=tot<=30 and Color3.fromRGB(255,65,65) or tot<=60 and Color3.fromRGB(255,195,40) or Color3.fromRGB(52,218,88); e.lbl.TextColor3=col; e.stk.Color=col end
            else local e=timerESPs[plot.Name]; if e then pcall(function() e.bb:Destroy() end); timerESPs[plot.Name]=nil end end
        end
    end
end)

-- ════════════════════════════════════════
-- FAST PANEL (fixed: spam all cmds per player)
-- ════════════════════════════════════════
local FP={}; local FP_W=isMobile and 280 or 320; local FP_ROW_H=isMobile and 36 or 40
local FP_CMDS={"tiny","jail","rocket","ragdoll","balloon","inverse","morph","jumpscare"}
local fpProfileCache={}; local fpCommandCache={}

local function fpGetAdminFrames() return _ragdollGetAdminFrames() end
local function fpRunAllCmds(target)
    local cf,pf=fpGetAdminFrames(); if not cf or not pf then
        -- fallback: use ADM remote
        if ADM then for _,cmd in ipairs(FP_CMDS) do aFire(target,cmd); task.wait(0.04) end end; return
    end
    local pb=pf:FindFirstChild(target.Name); if not pb then return end
    if not fpProfileCache[target.Name] then fpProfileCache[target.Name]=_ragdollCacheActivated(pb) end
    for _,cmd in ipairs(FP_CMDS) do
        if not fpCommandCache[cmd] then local cb=cf:FindFirstChild(cmd); if cb then fpCommandCache[cmd]=_ragdollCacheActivated(cb) end end
        if fpCommandCache[cmd] then _ragdollFireActivated(fpCommandCache[cmd]); task.wait(); _ragdollFireActivated(fpProfileCache[target.Name]) end
        task.wait(0.04)
    end
end

local function fpBuildRow(plr,order,parent)
    local row=Instance.new("Frame",parent); row.Name="FPRow_"..plr.Name; row.Size=UDim2.new(1,-6,0,FP_ROW_H); row.BackgroundColor3=T.Card; row.BackgroundTransparency=0.1; row.BorderSizePixel=0; row.LayoutOrder=order; Corner(row,6);Stroke(row,T.Border,1)

    -- avatar
    local ava=Instance.new("ImageLabel",row); ava.Size=UDim2.fromOffset(24,24); ava.Position=UDim2.new(0,4,0.5,-12); ava.BackgroundColor3=T.Border; ava.BorderSizePixel=0; Corner(ava,12)
    task.spawn(function() local ok,img=pcall(Players.GetUserThumbnailAsync,Players,plr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48); if ok then ava.Image=img end end)

    -- name
    local dispTxt=plr.DisplayName~=plr.Name and plr.DisplayName.." (@"..plr.Name..")" or plr.Name
    local nl=Label(row,dispTxt,isMobile and 10 or 11,T.White,Enum.Font.GothamBold); nl.Size=UDim2.new(1,-88,1,0); nl.Position=UDim2.fromOffset(32,0); nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.ZIndex=2

    -- SPAM ALL button
    local spamBtn=Instance.new("TextButton",row); spamBtn.Size=UDim2.fromOffset(70,24); spamBtn.Position=UDim2.new(1,-74,0.5,-12); spamBtn.BackgroundColor3=Color3.fromRGB(20,40,90); spamBtn.BorderSizePixel=0; spamBtn.Text="SPAM ALL"; spamBtn.TextSize=9; spamBtn.Font=Enum.Font.GothamBold; spamBtn.TextColor3=T.White; spamBtn.AutoButtonColor=false; spamBtn.ZIndex=3; Corner(spamBtn,6); Stroke(spamBtn,T.Blue,1)
    local _spBusy=false
    spamBtn.MouseButton1Click:Connect(function()
        if _spBusy then return end; _spBusy=true; spamBtn.Text="..."; spamBtn.BackgroundColor3=T.Blue
        task.spawn(function() pcall(fpRunAllCmds,plr); task.wait(1); _spBusy=false; spamBtn.Text="SPAM ALL"; spamBtn.BackgroundColor3=Color3.fromRGB(20,40,90) end)
    end)
    row.MouseEnter:Connect(function() Tween(row,F,{BackgroundColor3=T.CardHover}) end)
    row.MouseLeave:Connect(function() Tween(row,F,{BackgroundColor3=T.Card}) end)
    return row
end

local fpWin=nil; local fpScroll=nil; local fpListLayout=nil; local fpVisible=false; local fpMinimized=false
local function fpRefreshPlayers()
    if not fpScroll then return end
    for _,c in ipairs(fpScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local order=1
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp then fpBuildRow(p,order,fpScroll); order=order+1 end
    end
    if fpListLayout then
        local rowCount=order-1
        local ch=math.min(rowCount*FP_ROW_H+rowCount*3+8,160)
        if fpWin then fpWin.Size=UDim2.new(0,FP_W,0,36+ch) end
        if fpScroll then fpScroll.Size=UDim2.new(1,0,0,ch) end
    end
end
local function fpBuildWindow()
    if fpWin then return end
    fpWin=Instance.new("Frame",GUI); fpWin.Name="VertexFastPanel"; fpWin.Size=UDim2.new(0,FP_W,0,36); fpWin.AnchorPoint=Vector2.new(0.5,1); fpWin.Position=UDim2.new(0.5,0,1,-8); fpWin.BackgroundColor3=T.BG; fpWin.BackgroundTransparency=0.04; fpWin.BorderSizePixel=0; fpWin.ZIndex=30; fpWin.Visible=false; fpWin.Active=true; fpWin.ClipsDescendants=true; Corner(fpWin,10)
    local fws=Instance.new("UIStroke",fpWin); fws.Thickness=1.5; fws.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; fws.Color=Color3.fromRGB(255,255,255)
    local fwg=Instance.new("UIGradient",fws); fwg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.BlueDim),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(200,210,255)),ColorSequenceKeypoint.new(1,T.BlueDim)}; fwg.Rotation=45
    local fpHdr=Instance.new("Frame",fpWin); fpHdr.Size=UDim2.new(1,0,0,32); fpHdr.BackgroundColor3=T.Header; fpHdr.BorderSizePixel=0; fpHdr.ZIndex=31; Corner(fpHdr,10)
    local fpHdrFill=Instance.new("Frame",fpHdr); fpHdrFill.Size=UDim2.new(1,0,0,10); fpHdrFill.Position=UDim2.new(0,0,1,-10); fpHdrFill.BackgroundColor3=T.Header; fpHdrFill.BorderSizePixel=0
    local fpTL=Label(fpHdr,"⚡ Fast Panel",isMobile and 11 or 13,T.White,Enum.Font.GothamBold); fpTL.Size=UDim2.new(1,-40,1,0); fpTL.Position=UDim2.fromOffset(10,0); fpTL.ZIndex=32
    local fpMin=Instance.new("TextButton",fpHdr); fpMin.Size=UDim2.fromOffset(22,16); fpMin.AnchorPoint=Vector2.new(1,0.5); fpMin.Position=UDim2.new(1,-6,0.5,0); fpMin.BackgroundColor3=T.Card; fpMin.BorderSizePixel=0; fpMin.AutoButtonColor=false; fpMin.Text="—"; fpMin.TextSize=9; fpMin.Font=Enum.Font.GothamBold; fpMin.TextColor3=T.Dim; fpMin.ZIndex=33; Corner(fpMin,4); Stroke(fpMin,T.Border,1)
    fpScroll=Instance.new("ScrollingFrame",fpWin); fpScroll.Size=UDim2.new(1,-8,0,0); fpScroll.Position=UDim2.fromOffset(4,34); fpScroll.BackgroundTransparency=1; fpScroll.BorderSizePixel=0; fpScroll.ScrollBarThickness=0; fpScroll.CanvasSize=UDim2.new(0,0,0,0); fpScroll.ZIndex=31
    fpListLayout=Instance.new("UIListLayout",fpScroll); fpListLayout.Padding=UDim.new(0,3); fpListLayout.SortOrder=Enum.SortOrder.LayoutOrder; fpListLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    fpListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() fpScroll.CanvasSize=UDim2.new(0,0,0,fpListLayout.AbsoluteContentSize.Y+6) end)
    fpMin.MouseButton1Click:Connect(function()
        fpMinimized=not fpMinimized; fpMin.Text=fpMinimized and "+" or "—"
        if fpMinimized then Tween(fpWin,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=UDim2.new(0,FP_W,0,32)}); fpScroll.Visible=false
        else fpScroll.Visible=true; fpRefreshPlayers() end
    end)
    -- drag
    do local on,ds,sp=false,nil,nil
        fpHdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then on=true; ds=i.Position; sp=fpWin.Position end end)
        UserInputService.InputChanged:Connect(function(i) if on and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-ds; fpWin.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then on=false; Config.fastPanelPos={xs=fpWin.Position.X.Scale,xo=fpWin.Position.X.Offset,ys=fpWin.Position.Y.Scale,yo=fpWin.Position.Y.Offset}; pcall(FH_SaveConfig) end end)
    end
    if Config.fastPanelPos then local sp=Config.fastPanelPos; if type(sp)=="table" and sp.xs then fpWin.Position=UDim2.new(sp.xs,sp.xo,sp.ys,sp.yo) end end
    Players.PlayerAdded:Connect(function() task.wait(0.3); if fpVisible then fpRefreshPlayers() end end)
    Players.PlayerRemoving:Connect(function(p) fpProfileCache[p.Name]=nil; task.wait(0.2); if fpVisible then fpRefreshPlayers() end end)
end
local function fpShow(v)
    fpVisible=v
    if not fpWin then fpBuildWindow() end
    fpWin.Visible=v; if v then fpMinimized=false; fpScroll.Visible=true; fpRefreshPlayers() end
end

-- ════════════════════════════════════════
-- AUTO-RESET SYSTEMS (Faded Flash exact)
-- ════════════════════════════════════════
local AutoResetBalloonEnabled=false; local _arbConns={}; local _arbBoundRemotes={}; local _arbAddConn=nil; local _arbLastFire=0
local function _arbStringMatchesBalloon(s) return type(s)=="string" and s:lower():find("jump higher",1,true)~=nil end
local function _arbHandleArgs(...)
    if not AutoResetBalloonEnabled then return end
    for i=1,select("#",...) do if _arbStringMatchesBalloon(select(i,...)) then local now=tick(); if now-_arbLastFire<3 then return end; _arbLastFire=now; doSelectedReset(); return end end
end
local function _arbBind(obj) if not obj:IsA("RemoteEvent") or _arbBoundRemotes[obj] then return end; local ok,c=pcall(function() return obj.OnClientEvent:Connect(_arbHandleArgs) end); if ok and c then table.insert(_arbConns,c); _arbBoundRemotes[obj]=true end end
local function startAutoResetBalloon() for _,c in ipairs(_arbConns) do pcall(function() c:Disconnect() end) end; _arbConns={}; _arbBoundRemotes={}; if _arbAddConn then pcall(function() _arbAddConn:Disconnect() end); _arbAddConn=nil end; _arbAddConn=ReplicatedStorage.DescendantAdded:Connect(function(obj) if AutoResetBalloonEnabled then _arbBind(obj) end end); task.spawn(function() for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do if not AutoResetBalloonEnabled then break end; _arbBind(obj) end end) end
local function stopAutoResetBalloon() for _,c in ipairs(_arbConns) do pcall(function() c:Disconnect() end) end; _arbConns={}; _arbBoundRemotes={}; if _arbAddConn then pcall(function() _arbAddConn:Disconnect() end); _arbAddConn=nil end end

local AutoResetTinyEnabled=false; local _artConns={}; local _artBoundRemotes={}; local _artAddConn=nil; local _artLastFire=0
local function _artStringMatchesTiny(s) return type(s)=="string" and s:lower():find("tiny for 30",1,true)~=nil end
local function _artHandleArgs(...)
    if not AutoResetTinyEnabled then return end
    for i=1,select("#",...) do if _artStringMatchesTiny(select(i,...)) then local now=tick(); if now-_artLastFire<3 then return end; _artLastFire=now; doSelectedReset(); return end end
end
local function _artBind(obj) if not obj:IsA("RemoteEvent") or _artBoundRemotes[obj] then return end; local ok,c=pcall(function() return obj.OnClientEvent:Connect(_artHandleArgs) end); if ok and c then table.insert(_artConns,c); _artBoundRemotes[obj]=true end end
local function startAutoResetTiny() for _,c in ipairs(_artConns) do pcall(function() c:Disconnect() end) end; _artConns={}; _artBoundRemotes={}; if _artAddConn then pcall(function() _artAddConn:Disconnect() end); _artAddConn=nil end; for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do _artBind(obj) end; _artAddConn=ReplicatedStorage.DescendantAdded:Connect(function(obj) if AutoResetTinyEnabled then _artBind(obj) end end) end
local function stopAutoResetTiny() for _,c in ipairs(_artConns) do pcall(function() c:Disconnect() end) end; _artConns={}; _artBoundRemotes={}; if _artAddConn then pcall(function() _artAddConn:Disconnect() end); _artAddConn=nil end end

local AutoResetJailEnabled=false; local _arjConns={}; local _arjBoundRemotes={}; local _arjAddConn=nil; local _arjLastFire=0
local function _arjStringMatchesJail(s) return type(s)=="string" and s:lower():find("trapped for",1,true)~=nil end
local function _arjHandleArgs(...)
    if not AutoResetJailEnabled then return end
    for i=1,select("#",...) do if _arjStringMatchesJail(select(i,...)) then local now=tick(); if now-_arjLastFire<3 then return end; _arjLastFire=now; doSelectedReset(); return end end
end
local function _arjBind(obj) if not obj:IsA("RemoteEvent") or _arjBoundRemotes[obj] then return end; local ok,c=pcall(function() return obj.OnClientEvent:Connect(_arjHandleArgs) end); if ok and c then table.insert(_arjConns,c); _arjBoundRemotes[obj]=true end end
local function startAutoResetJail() for _,c in ipairs(_arjConns) do pcall(function() c:Disconnect() end) end; _arjConns={}; _arjBoundRemotes={}; if _arjAddConn then pcall(function() _arjAddConn:Disconnect() end); _arjAddConn=nil end; for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do _arjBind(obj) end; _arjAddConn=ReplicatedStorage.DescendantAdded:Connect(function(obj) if AutoResetJailEnabled then _arjBind(obj) end end) end
local function stopAutoResetJail() for _,c in ipairs(_arjConns) do pcall(function() c:Disconnect() end) end; _arjConns={}; _arjBoundRemotes={}; if _arjAddConn then pcall(function() _arjAddConn:Disconnect() end); _arjAddConn=nil end end

-- ════════════════════════════════════════
-- AUTO FLASH
-- ════════════════════════════════════════
local AutoFlashEnabled=false; local _afPending=false; local _afBoundRemotes={}; local _afLastBalloon=0
local function tryAutoFlash()
    if not AutoFlashEnabled or not _G._FH_SelectedBrainrot then return end
    if _afPending then return end; _afPending=true
    task.spawn(function()
        pcall(ShowToggleNotification,"Auto Flash: resetting...",true); doSelectedReset()
        local deadline=tick()+8; while (not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart")) and tick()<deadline do task.wait(0.1) end
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then _afPending=false; return end
        task.wait(0.15); if not AutoFlashEnabled or not _G._FH_SelectedBrainrot then _afPending=false; return end
        pcall(ShowToggleNotification,"Auto Flash: flashing!",true); doFlash()
        task.wait(3); _afPending=false
    end)
end
local function _afBind(obj)
    if not obj:IsA("RemoteEvent") or _afBoundRemotes[obj] then return end
    local ok,c=pcall(function() return obj.OnClientEvent:Connect(function(...)
        if not AutoFlashEnabled then return end
        for i=1,select("#",...) do local arg=select(i,...); if type(arg)=="string" and arg:lower():find("jump higher",1,true) then local now=tick(); if now-_afLastBalloon<3 then return end; _afLastBalloon=now; tryAutoFlash(); return end end
    end) end)
    if ok and c then _afBoundRemotes[obj]=c end
end
for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do _afBind(obj) end
ReplicatedStorage.DescendantAdded:Connect(function(obj) _afBind(obj) end)

-- ════════════════════════════════════════
-- ANTI STEAL (hitbox detection)
-- ════════════════════════════════════════
local AntiStealEnabled=false; local _asHB=nil; local _asCDs={}; local _asCache={}; local _asCacheTime={}
local CARPET={["Flying Carpet"]=true,["Witch's Broom"]=true,["Santa's Sleigh"]=true,["Cupid's Wings"]=true}
local function getTheirHitbox(p)
    local now=tick(); if _asCache[p.Name] and now-(_asCacheTime[p.Name] or 0)<4 then return _asCache[p.Name] end
    local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
    for _,plot in ipairs(plots:GetChildren()) do
        local sign=plot:FindFirstChild("PlotSign",true); if not sign then continue end
        for _,d in ipairs(sign:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text and d.Text~="" then
                local owner=d.Text:match("[Bb]ase [Oo]f%s+(.+)") or d.Text; owner=owner:match("^%s*(.-)%s*$") or owner
                if owner==p.Name or owner==p.DisplayName then local hb=plot:FindFirstChild("DeliveryHitbox"); if hb then _asCache[p.Name]=hb; _asCacheTime[p.Name]=now; return hb end end
            end
        end
    end; _asCacheTime[p.Name]=now; return nil
end
local function startAntiSteal()
    if _asHB then _asHB:Disconnect() end; _asCDs={}; _asCache={}; _asCacheTime={}
    _asHB=RunService.Heartbeat:Connect(function()
        if not AntiStealEnabled then return end; local now=tick()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==lp or not p.Character then continue end
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local hb=getTheirHitbox(p); if not hb then continue end
            local rel=hb.CFrame:PointToObjectSpace(hrp.Position); local half=(hb.Size/2)+Vector3.new(5,5,5)
            if math.abs(rel.X)<=half.X and math.abs(rel.Y)<=half.Y and math.abs(rel.Z)<=half.Z then
                local last=_asCDs[p.Name] or 0; if now-last<6 then continue end; _asCDs[p.Name]=now
                pcall(ShowToggleNotification,"Anti Steal: "..p.Name,false)
                task.spawn(function()
                    local cf,pf=_ragdollGetAdminFrames(); if not cf or not pf then if ADM then aFire(p,"balloon") end; return end
                    local pb=pf:FindFirstChild(p.Name); local bb=cf:FindFirstChild("balloon")
                    if pb and bb then
                        local pc=_ragdollCacheActivated(pb); local bc=_ragdollCacheActivated(bb)
                        _ragdollFireActivated(bc); task.wait(); _ragdollFireActivated(pc)
                    end
                end)
            end
        end
    end)
end
local function stopAntiSteal() if _asHB then _asHB:Disconnect(); _asHB=nil end end

-- ════════════════════════════════════════
-- SETTINGS TAB
-- ════════════════════════════════════════
CreateSection(SettingsTab.scroll,"AUTO RESET")
CreateToggle(SettingsTab.scroll,"Reset when ballooned","Resets if you get ballooned",function(v) AutoResetBalloonEnabled=v; if v then startAutoResetBalloon() else stopAutoResetBalloon() end end)
CreateToggle(SettingsTab.scroll,"Reset when tiny","Resets if you get shrunk",function(v) AutoResetTinyEnabled=v; if v then startAutoResetTiny() else stopAutoResetTiny() end end)
CreateToggle(SettingsTab.scroll,"Reset when jail","Resets if you get jailed",function(v) AutoResetJailEnabled=v; if v then startAutoResetJail() else stopAutoResetJail() end end)

CreateSection(SettingsTab.scroll,"FLASH")
CreateToggle(SettingsTab.scroll,"Auto Flash","Auto flashes on balloon reset",function(v) AutoFlashEnabled=v end)
CreateToggle(SettingsTab.scroll,"Auto Block","Blocks plot owner after flash",function(v) AutoBlockEnabled=v end)
CreateToggle(SettingsTab.scroll,"Ragdoll Bypass","Ragdolls target via admin panel",function(v) RagdollBypassEnabled=v end)

CreateSection(SettingsTab.scroll,"PROTECTION")
CreateToggle(SettingsTab.scroll,"Anti Ragdoll","Prevents ragdoll on your character",function(v) if v then AntiRagdoll.enable() else AntiRagdoll.disable() end end)
CreateToggle(SettingsTab.scroll,"Anti Bee / Invert / Effects","Removes bee & invert effects",function(v) antiBeeEnabled=v end,true)
CreateToggle(SettingsTab.scroll,"Anti Admin Panel","Blocks tiny/giant/ragdoll/freeze",function(v) AntiAdminEnabled=v; if v then task.spawn(captureOriginals) end end)
CreateToggle(SettingsTab.scroll,"Anti Steal","Balloons players near your base",function(v) AntiStealEnabled=v; if v then startAntiSteal() else stopAntiSteal() end end)

CreateSection(SettingsTab.scroll,"VISUAL")
CreateToggle(SettingsTab.scroll,"Player ESP","Shows player boxes + names",function(v) if v then enablePlayerESP() else disablePlayerESP() end end)
CreateToggle(SettingsTab.scroll,"Timer ESP","Shows plot timers in world",function(v) timerOn=v end)
CreateToggle(SettingsTab.scroll,"Auto Select Best Brainrot","Selects highest gen animal",function(v)
    if v and #_lastAnimalScan>0 then
        local best=_lastAnimalScan[1]; if best then
            local uid=best.plotName.."_"..best.slot
            if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
            selectedUID=uid; _G._FH_SelectedBrainrot={uid=uid,name=best.name,mutation=best.mutation,gen=best.genValue,genText=best.genText,plotName=best.plotName,slot=best.slot,owner=best.owner}
            local c=buttonCache[uid]; if c then local s=c:FindFirstChild("UIStroke"); if s then s.Enabled=true end end
        end
    end
end)

CreateSection(SettingsTab.scroll,"PANELS")
CreateToggle(SettingsTab.scroll,"Fast Panel","Quick spam all cmds per player",function(v) fpShow(v) end)

CreateSection(SettingsTab.scroll,"SERVER")
CreateButton(SettingsTab.scroll,"Rejoin Server",nil,function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,lp) end)
end)
CreateButton(SettingsTab.scroll,"Save Config",nil,function()
    pcall(FH_SaveConfig); pcall(ShowToggleNotification,"Config Saved",true)
end)

-- ════════════════════════════════════════
-- BANNER (FPS + PING + info box)
-- ════════════════════════════════════════
local BW=WIN_W; local BH=isMobile and 28 or 38
local Banner=Instance.new("Frame",GUI); Banner.Name="VertexBanner"; Banner.Size=UDim2.new(0,BW,0,BH); Banner.AnchorPoint=Vector2.new(0.5,0); Banner.Position=UDim2.new(0.5,0,0.5,WIN_H/2+6); Banner.BackgroundColor3=T.Header; Banner.BackgroundTransparency=0.08; Banner.BorderSizePixel=0; Banner.ZIndex=9; Corner(Banner,10)
local BanStroke=Instance.new("UIStroke",Banner); BanStroke.Thickness=1.4; BanStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; BanStroke.Color=Color3.fromRGB(255,255,255)
local BanGrad=Instance.new("UIGradient",BanStroke); BanGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.BlueDim),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(180,200,255)),ColorSequenceKeypoint.new(1,T.BlueDim)}; BanGrad.Rotation=90

-- Logo box
local LogoBox=Instance.new("Frame",Banner); LogoBox.Size=UDim2.fromOffset(isMobile and 18 or 24,isMobile and 18 or 24); LogoBox.Position=UDim2.new(0,8,0.5,-(isMobile and 9 or 12)); LogoBox.BackgroundColor3=T.Blue; LogoBox.BorderSizePixel=0; LogoBox.ZIndex=10; Corner(LogoBox,6)
local LogoV=Label(LogoBox,"V",isMobile and 11 or 14,T.White,Enum.Font.GothamBlack); LogoV.Size=UDim2.new(1,0,1,0); LogoV.TextXAlignment=Enum.TextXAlignment.Center; LogoV.TextYAlignment=Enum.TextYAlignment.Center; LogoV.ZIndex=11

-- FPS/PING
local FPSLabel=Label(Banner,"FPS: --",isMobile and 9 or 11,T.White,Enum.Font.GothamBold); FPSLabel.Size=UDim2.new(0,80,0.5,0); FPSLabel.Position=UDim2.new(0,isMobile and 32 or 40,0,3); FPSLabel.ZIndex=10
local PINGLabel=Label(Banner,"PING: --ms",isMobile and 8 or 10,T.Dim,Enum.Font.Gotham); PINGLabel.Size=UDim2.new(0,80,0.5,0); PINGLabel.Position=UDim2.new(0,isMobile and 32 or 40,0.5,-2); PINGLabel.ZIndex=10

-- divider
local BDiv=Instance.new("Frame",Banner); BDiv.Size=UDim2.new(0,1,0.6,0); BDiv.Position=UDim2.new(0,isMobile and 118 or 130,0.2,0); BDiv.BackgroundColor3=T.Border; BDiv.BorderSizePixel=0

-- info box (small, discord + @r9qbx)
local InfoBox=Instance.new("Frame",Banner); InfoBox.Size=UDim2.new(0,0,0,BH-6); InfoBox.AutomaticSize=Enum.AutomaticSize.X; InfoBox.Position=UDim2.new(0,isMobile and 125 or 138,0.5,-(BH-6)/2); InfoBox.BackgroundColor3=T.Card; InfoBox.BackgroundTransparency=0.3; InfoBox.BorderSizePixel=0; InfoBox.ZIndex=10; Corner(InfoBox,6)
local IBoxPad=Instance.new("UIPadding",InfoBox); IBoxPad.PaddingLeft=UDim.new(0,7); IBoxPad.PaddingRight=UDim.new(0,7)
local InfoLayout=Instance.new("UIListLayout",InfoBox); InfoLayout.FillDirection=Enum.FillDirection.Vertical; InfoLayout.VerticalAlignment=Enum.VerticalAlignment.Center; InfoLayout.Padding=UDim.new(0,1)
local DiscLbl=Label(InfoBox,"discord.gg/3JnFzfcYB",isMobile and 7 or 8,T.Blue,Enum.Font.GothamBold); DiscLbl.Size=UDim2.new(0,0,0,isMobile and 10 or 12); DiscLbl.AutomaticSize=Enum.AutomaticSize.X; DiscLbl.ZIndex=11
local UserLbl=Label(InfoBox,"@r9qbx",isMobile and 7 or 8,T.Dim,Enum.Font.Gotham); UserLbl.Size=UDim2.new(0,0,0,isMobile and 8 or 10); UserLbl.AutomaticSize=Enum.AutomaticSize.X; UserLbl.ZIndex=11

-- mobile bar
if isMobile then
    local MBar=Instance.new("Frame",GUI); MBar.Name="VertexMobileBar"; MBar.AnchorPoint=Vector2.new(0.5,1); MBar.Position=UDim2.new(0.5,0,0.5,WIN_H/2+BH+14); MBar.Size=UDim2.new(0,WIN_W,0,32); MBar.BackgroundColor3=T.Header; MBar.BackgroundTransparency=0.08; MBar.BorderSizePixel=0; MBar.ZIndex=9; Corner(MBar,10)
    local MBStroke=Instance.new("UIStroke",MBar); MBStroke.Thickness=1.4; MBStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; MBStroke.Color=Color3.fromRGB(255,255,255)
    local MBGrad=Instance.new("UIGradient",MBStroke); MBGrad.Color=BanGrad.Color; MBGrad.Rotation=90
    local MBLayout=Instance.new("UIListLayout",MBar); MBLayout.FillDirection=Enum.FillDirection.Horizontal; MBLayout.VerticalAlignment=Enum.VerticalAlignment.Center; MBLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center; MBLayout.Padding=UDim.new(0,8)
    local MBPad=Instance.new("UIPadding",MBar); MBPad.PaddingLeft=UDim.new(0,10); MBPad.PaddingRight=UDim.new(0,10)
    local function makeMB(text,order,col,action)
        local b=Instance.new("TextButton",MBar); b.Name="MB_"..text; b.LayoutOrder=order; b.Size=UDim2.new(0,0,0,22); b.AutomaticSize=Enum.AutomaticSize.X; b.BackgroundColor3=Color3.fromRGB(16,16,26); b.BorderSizePixel=0; b.AutoButtonColor=false; b.Text=text; b.TextSize=10; b.Font=Enum.Font.GothamBold; b.TextColor3=T.White; b.ZIndex=10; b.Active=true; Corner(b,7); local s=Stroke(b,col or T.Border,1)
        local p=Instance.new("UIPadding",b); p.PaddingLeft=UDim.new(0,10); p.PaddingRight=UDim.new(0,10)
        local _ts=nil; b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then _ts=i.Position end end)
        b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch and _ts then local m=(i.Position-_ts).Magnitude; _ts=nil; if m<20 then b.BackgroundColor3=T.White; b.TextColor3=T.BG; task.delay(0.14,function() b.BackgroundColor3=Color3.fromRGB(16,16,26); b.TextColor3=T.White end); if action then task.spawn(function() pcall(action) end) end end end end)
        b.MouseButton1Click:Connect(function() if action then task.spawn(function() pcall(action) end) end end)
        return b
    end
    makeMB("RESET",1,Color3.fromRGB(200,60,60),doSelectedReset)
    makeMB("FLASH",2,T.Blue,doFlash)
    makeMB("BLOCK",3,Color3.fromRGB(60,60,200),function() blockPlayer(getNearestPlayer()) end)
end

-- ════════════════════════════════════════
-- UI SHOW/HIDE (Ctrl key)
-- ════════════════════════════════════════
local _uiVisible=true; local _uiAnimating=false
local SHOW_I=TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
local HIDE_I=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
local function setUIVisible(v)
    if _uiAnimating or v==_uiVisible then return end; _uiVisible=v; _uiAnimating=true
    if v then WinScale.Scale=0; Win.Visible=true; local tw=TweenService:Create(WinScale,SHOW_I,{Scale=1}); tw:Play(); tw.Completed:Connect(function() _uiAnimating=false end)
    else local tw=TweenService:Create(WinScale,HIDE_I,{Scale=0}); tw:Play(); tw.Completed:Connect(function() Win.Visible=false; _uiAnimating=false end) end
end
-- Logo touch to hide on mobile
if isMobile then
    local _lt=nil
    LogoBox.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then _lt=i.Position end end)
    LogoBox.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch and _lt then local m=(i.Position-_lt).Magnitude; _lt=nil; if m<12 then setUIVisible(not _uiVisible) end end end)
end
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.LeftControl or inp.KeyCode==Enum.KeyCode.RightControl then setUIVisible(not _uiVisible) end
end)

-- ════════════════════════════════════════
-- BANNER ANIMATION
-- ════════════════════════════════════════
local _fpsFrames=0; local _fpsClock=0
RunService.RenderStepped:Connect(function(dt)
    WinGrad.Rotation=(WinGrad.Rotation+dt*45)%360
    BanGrad.Rotation=(BanGrad.Rotation+dt*45)%360
    _fpsFrames=_fpsFrames+1; _fpsClock=_fpsClock+dt
    if _fpsClock>=0.5 then
        FPSLabel.Text="FPS: "..math.floor(_fpsFrames/_fpsClock)
        local ping=0; pcall(function() ping=math.floor((lp:GetNetworkPing() or 0)*1000) end)
        PINGLabel.Text="PING: "..ping.."ms"
        _fpsFrames=0; _fpsClock=0
    end
end)

-- ════════════════════════════════════════
-- APPLY SAVED KEYBINDS + INIT
-- ════════════════════════════════════════
FH_ApplyLoadedKeybinds()
print("Vertex Pvp loaded | @r9qbx | discord.gg/3JnFzfcYB")
