-- Aethen Hub v1.1 | r9qbx
local DISCORD_LINK="discord.gg/3vQbThdQ"
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local PPS=game:GetService("ProximityPromptService")
local RS=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService")
local HttpService=game:GetService("HttpService")
local CoreGui=game:GetService("CoreGui")
local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local MPS=game:GetService("MarketplaceService")
local lp=Players.LocalPlayer
local cam=workspace.CurrentCamera

local Cfg={triggerChance=91,flashOn=false,grabOn=false,potionOn=false,stealSpdOn=false,stealSpdVal=30,
    pos_FP={ox=0,oy=5},pos_AP={ox=0,oy=0},pos_ADM={ox=0,oy=0},pos_BP={ox=0,oy=0}}
pcall(function()
    if readfile then
        local raw=readfile("AethV11.json")
        if raw and raw~="" then
            local ok,t=pcall(HttpService.JSONDecode,HttpService,raw)
            if ok and type(t)=="table" then
                for k,v in pairs(t) do Cfg[k]=v end
            end
        end
    end
end)
local function save()
    pcall(function()
        if writefile then writefile("AethV11.json",HttpService:JSONEncode(Cfg)) end
    end)
end

for _,v in ipairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:sub(1,4)=="Aeth" or v.Name:sub(1,4)=="PhFV") then
        v:Destroy()
    end
end
local SG=Instance.new("ScreenGui")
SG.Name="AethV11"
SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Global
SG.IgnoreGuiInset=true
SG.Parent=CoreGui

local T={
    bg=Color3.fromRGB(5,5,9),panel=Color3.fromRGB(7,7,13),surf=Color3.fromRGB(12,12,20),
    surf2=Color3.fromRGB(18,18,30),a1=Color3.fromRGB(225,225,240),a2=Color3.fromRGB(170,170,195),
    white=Color3.new(1,1,1),dim=Color3.fromRGB(100,100,122),str=Color3.fromRGB(150,150,178),
    red=Color3.fromRGB(255,65,65),grn=Color3.fromRGB(52,218,88),yel=Color3.fromRGB(255,200,40),
}

local function co(p,r)
    local c=Instance.new("UICorner",p)
    c.CornerRadius=UDim.new(0,r or 7)
end
local function ms(p,th,col,tr)
    local s=Instance.new("UIStroke",p)
    s.Thickness=th or 1
    s.Color=col or T.str
    s.Transparency=tr or 0.38
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return s
end
local function lb(par,props)
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold
    l.TextColor3=T.white
    l.BorderSizePixel=0
    for k,v in pairs(props) do l[k]=v end
    l.Parent=par
    return l
end
local function btn(par,text,sz,pos,bg)
    local b=Instance.new("TextButton")
    b.Size=sz
    b.Position=pos
    b.BackgroundColor3=bg or T.surf
    b.BackgroundTransparency=0.22
    b.Text=text
    b.TextColor3=T.white
    b.Font=Enum.Font.GothamBold
    b.TextSize=9
    b.BorderSizePixel=0
    b.AutoButtonColor=false
    b.Parent=par
    co(b,5)
    ms(b,1,T.str,0.44)
    return b
end
local function rotS(f,col)
    local s=ms(f,1.3,col,0.22)
    local g=Instance.new("UIGradient",s)
    g.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(0.25,Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(0.5,col or T.a1),
        ColorSequenceKeypoint.new(0.75,Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(1,Color3.new(1,1,1))
    }
    task.spawn(function()
        while s and s.Parent do
            g.Rotation=(g.Rotation+0.9)%360
            task.wait(0.016)
        end
    end)
end
local function particles(parent,count)
    for i=1,(count or 4) do
        local p=Instance.new("Frame",parent)
        p.BackgroundColor3=Color3.fromRGB(200,210,255)
        p.BackgroundTransparency=0.48
        p.BorderSizePixel=0
        p.ZIndex=0
        local sz=math.random(2,4)
        p.Size=UDim2.fromOffset(sz,sz)
        local sx=math.random()
        p.Position=UDim2.new(sx,0,1.05,0)
        co(p,5)
        task.spawn(function()
            while p and p.Parent do
                local nx=math.clamp(sx+math.random(-8,8)/100,0.02,0.98)
                TweenService:Create(p,TweenInfo.new(math.random(4,7),Enum.EasingStyle.Linear),
                    {Position=UDim2.new(nx,0,-0.05,0),BackgroundTransparency=1}):Play()
                task.wait(math.random(4,7))
                if p and p.Parent then
                    p.BackgroundTransparency=0.48
                    sx=math.random()
                    p.Position=UDim2.new(sx,0,1.05,0)
                end
            end
        end)
    end
end
local function dragSave(h,f,key)
    local on,ds,sp=false,nil,nil
    h.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            on=true
            ds=i.Position
            sp=f.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then
                    on=false
                    if key then
                        Cfg[key]={ox=math.floor(f.Position.X.Offset),oy=math.floor(f.Position.Y.Offset)}
                        save()
                    end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not on then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds
            f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end
local function mkP(defX,defY,w,h,title,ac,posKey)
    local px=(posKey and Cfg[posKey] and Cfg[posKey].ox~=0 and Cfg[posKey].ox) or defX
    local py=(posKey and Cfg[posKey] and Cfg[posKey].oy~=0 and Cfg[posKey].oy) or defY
    local f=Instance.new("Frame")
    f.Size=UDim2.fromOffset(w,h)
    f.Position=UDim2.fromOffset(px,py)
    f.BackgroundColor3=T.panel
    f.BackgroundTransparency=0.14
    f.BorderSizePixel=0
    f.ClipsDescendants=true
    f.Parent=SG
    co(f,9)
    rotS(f,ac or T.a1)
    particles(f,4)
    local hdr=Instance.new("Frame",f)
    hdr.Size=UDim2.new(1,0,0,21)
    hdr.BackgroundColor3=T.surf
    hdr.BackgroundTransparency=0.18
    hdr.BorderSizePixel=0
    co(hdr,9)
    local flat=Instance.new("Frame",hdr)
    flat.Size=UDim2.new(1,0,0,7)
    flat.Position=UDim2.new(0,0,1,-7)
    flat.BackgroundColor3=T.surf
    flat.BackgroundTransparency=0.18
    flat.BorderSizePixel=0
    local sep=Instance.new("Frame",f)
    sep.Size=UDim2.new(1,-8,0,1)
    sep.Position=UDim2.fromOffset(4,21)
    sep.BackgroundColor3=T.str
    sep.BackgroundTransparency=0.68
    sep.BorderSizePixel=0
    if title then
        lb(hdr,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-26,1,0),Text=title,
            TextSize=8,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=T.a1})
    end
    local mb=btn(hdr,"─",UDim2.fromOffset(15,13),UDim2.new(1,-18,0.5,-6.5),T.surf2)
    mb.TextSize=8
    mb.TextColor3=T.dim
    mb.BackgroundTransparency=0.6
    dragSave(hdr,f,posKey)
    return f,hdr,mb
end
local function mkF(parent,hH,cH,mb)
    local content=Instance.new("Frame")
    content.Size=UDim2.new(1,0,0,cH)
    content.Position=UDim2.fromOffset(0,hH)
    content.BackgroundTransparency=1
    content.BorderSizePixel=0
    content.Parent=parent
    local folded=false
    local fullH=parent.Size.Y.Offset
    mb.MouseButton1Click:Connect(function()
        folded=not folded
        mb.Text=folded and "+" or "─"
        TweenService:Create(parent,TweenInfo.new(0.22,Enum.EasingStyle.Quad),
            {Size=UDim2.new(0,parent.Size.X.Offset,0,folded and hH+2 or fullH)}):Play()
    end)
    return content
end
local function pillR(parent,label,yPos,onCol)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-8,0,20)
    row.Position=UDim2.new(0,4,0,yPos)
    row.BackgroundColor3=T.surf
    row.BackgroundTransparency=0.28
    row.BorderSizePixel=0
    row.Parent=parent
    co(row,6)
    local rs=ms(row,1,T.str,0.55)
    local rl=lb(row,{Position=UDim2.new(0,6,0,0),Size=UDim2.new(1,-38,1,0),Text=label,
        TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
    local track=Instance.new("Frame",row)
    track.Size=UDim2.fromOffset(25,12)
    track.Position=UDim2.new(1,-29,0.5,-6)
    track.BackgroundColor3=T.surf2
    track.BorderSizePixel=0
    co(track,12)
    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.fromOffset(8,8)
    knob.Position=UDim2.new(0,2,0.5,-4)
    knob.BackgroundColor3=T.a2
    knob.BorderSizePixel=0
    co(knob,8)
    local pb=Instance.new("TextButton",row)
    pb.Size=UDim2.new(1,0,1,0)
    pb.BackgroundTransparency=1
    pb.Text=""
    local col=onCol or T.a1
    local function set(v)
        TweenService:Create(track,TweenInfo.new(0.12),{BackgroundColor3=v and col or T.surf2}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{
            Position=v and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),
            BackgroundColor3=v and T.white or T.a2}):Play()
        TweenService:Create(rs,TweenInfo.new(0.12),{Color=v and col or T.str,Transparency=v and 0.18 or 0.55}):Play()
        rl.TextColor3=v and T.white or T.dim
    end
    return pb,set
end

task.wait(0.1)
local vp=cam.ViewportSize
if vp.X==0 then vp=Vector2.new(390,844) end

local isStealing=false

-- Background systems guard
if not _G._AethBGv11 then
    _G._AethBGv11=true

    -- Kick on steal
    task.spawn(function()
        local pg=lp:WaitForChild("PlayerGui")
        local function onStole()
            pcall(function() lp:Kick(DISCORD_LINK) end)
        end
        local function chk(t)
            return typeof(t)=="string" and t:lower():find("you stole")
        end
        local function watch(gui)
            gui.DescendantAdded:Connect(function(d)
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    if chk(d.Text) then onStole() end
                    d:GetPropertyChangedSignal("Text"):Connect(function()
                        if chk(d.Text) then onStole() end
                    end)
                end
            end)
        end
        for _,g in ipairs(pg:GetChildren()) do watch(g) end
        pg.ChildAdded:Connect(function(g) watch(g) end)
    end)

    -- Anti-ragdoll
    RunService.Heartbeat:Connect(function()
        local char=lp.Character
        if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local root=char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s=hum:GetState()
        local rag=(s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown)
        local et=lp:GetAttribute("RagdollEndTime")
        if et and (et-workspace:GetServerTimeNow())>0 then rag=true end
        if rag then
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

    -- Anti-bee (FIXED: no beehive tool destruction)
    local beeBL={BlurEffect=1,ColorCorrectionEffect=1,BloomEffect=1,SunRaysEffect=1,DepthOfFieldEffect=1}
    for _,v in pairs(Lighting:GetDescendants()) do
        if beeBL[v.ClassName] then pcall(function() v:Destroy() end) end
    end
    Lighting.DescendantAdded:Connect(function(obj)
        task.wait()
        if beeBL[obj.ClassName] then pcall(function() obj:Destroy() end) end
    end)
    RunService.Heartbeat:Connect(function()
        local char=lp.Character
        if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local root=char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if not hum.AutoRotate then hum.AutoRotate=true end
        for _,obj in ipairs(root:GetChildren()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyAngularVelocity") then
                pcall(function() obj:Destroy() end)
            end
        end
        -- Only correct if very clearly inverted
        if hum.MoveDirection.Magnitude>0.1 then
            local md=hum.MoveDirection
            local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
            if vel.Magnitude>4 and md:Dot(vel.Unit)<-0.65 then
                root.Velocity=Vector3.new(md.X*16,root.Velocity.Y,md.Z*16)
            end
        end
    end)

    -- Anti-sentry v2
    local sentryFirstSeen={}
    local sentryTarget=nil
    local function isMySentry(obj)
        local id=obj.Name:match("Sentry_(%d+)") or obj.Name:match("Beehive_(%d+)") or obj.Name:match("Turret_(%d+)")
        if id and tonumber(id)==lp.UserId then return true end
        local a=obj:GetAttribute("OwnerId") or obj:GetAttribute("PlayerId") or obj:GetAttribute("Owner")
        return a and tonumber(tostring(a))==lp.UserId
    end
    local function findSentryTarget()
        if isStealing then return nil end
        local char=lp.Character
        if not char then return nil end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local rp=hrp.Position
        local now=tick()
        for obj in pairs(sentryFirstSeen) do
            if not obj.Parent then sentryFirstSeen[obj]=nil end
        end
        for _,obj in pairs(workspace:GetChildren()) do
            if (obj.Name:find("Sentry") or obj.Name:find("Beehive") or obj.Name:find("Turret")) and not obj.Name:lower():find("bullet") then
                if isMySentry(obj) then continue end
                local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                if part and (rp-part.Position).Magnitude<=220 then
                    if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=now end
                    if now-sentryFirstSeen[obj]>=3 then return obj end
                end
            end
        end
        return nil
    end
    local function moveSentry(obj)
        if isStealing then return end
        local char=lp.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local cf=hrp.CFrame*CFrame.new(0,0,-5)
        if obj:IsA("BasePart") then
            obj.CFrame=cf
        elseif obj:IsA("Model") then
            local m=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if m then m.CFrame=cf end
        end
    end
    local function attackSentry()
        if isStealing then return end
        local char=lp.Character
        if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local weapon=(lp.Backpack and lp.Backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat")
        if not weapon then return end
        if weapon.Parent==lp.Backpack then hum:EquipTool(weapon); task.wait(0.1) end
        local handle=weapon:FindFirstChild("Handle")
        if handle then handle.CanCollide=false end
        pcall(function() weapon:Activate() end)
        for _,r in pairs(weapon:GetDescendants()) do
            if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end
        end
    end
    RunService.Heartbeat:Connect(function()
        if sentryTarget and sentryTarget.Parent==workspace then
            moveSentry(sentryTarget)
            attackSentry()
        else
            sentryTarget=findSentryTarget()
        end
    end)
    task.spawn(function()
        task.wait(1)
        for _,obj in pairs(workspace:GetChildren()) do
            if (obj.Name:find("Sentry") or obj.Name:find("Beehive") or obj.Name:find("Turret")) and not obj.Name:lower():find("bullet") then
                if not isMySentry(obj) then sentryFirstSeen[obj]=tick()-3 end
            end
        end
    end)

end -- END _G._AethBGv11

-- FOV lock
local FOV_LOCK=70
RunService.RenderStepped:Connect(function()
    if cam.FieldOfView~=FOV_LOCK then cam.FieldOfView=FOV_LOCK end
end)

-- Plot detection
local myPlotRef=nil
local stealHitbox=nil
task.spawn(function()
    while true do
        task.wait(0.9)
        if not myPlotRef then
            local plots=workspace:FindFirstChild("Plots")
            if plots then
                for _,p in ipairs(plots:GetChildren()) do
                    local sign=p:FindFirstChild("PlotSign")
                    if sign then
                        local yb=sign:FindFirstChild("YourBase")
                        if yb and yb:IsA("BillboardGui") and yb.Enabled then
                            myPlotRef=p
                            stealHitbox=p:FindFirstChild("StealHitbox",true)
                            break
                        end
                        local tl=sign:FindFirstChild("TextLabel",true)
                        if tl then
                            local t=tl.Text:lower()
                            if t:find(lp.Name:lower(),1,true) or t:find(lp.DisplayName:lower(),1,true) then
                                myPlotRef=p
                                stealHitbox=p:FindFirstChild("StealHitbox",true)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function isMyPlot(plot)
    if myPlotRef and plot==myPlotRef then return true end
    local sign=plot:FindFirstChild("PlotSign")
    if not sign then return false end
    local yb=sign:FindFirstChild("YourBase")
    return yb and yb:IsA("BillboardGui") and yb.Enabled
end

-- Timer ESP
local timerESPs={}
local baseAlerted=false
task.spawn(function()
    while true do
        task.wait(0.4)
        local plots=workspace:FindFirstChild("Plots")
        if not plots then continue end
        for _,plot in ipairs(plots:GetChildren()) do
            local pur=plot:FindFirstChild("Purchases")
            local pb2=pur and pur:FindFirstChild("PlotBlock")
            local mp=pb2 and pb2:FindFirstChild("Main")
            local tl2=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
            if tl2 and mp then
                local e=timerESPs[plot.Name]
                if not e or not e.bb.Parent then
                    if e then pcall(function() e.bb:Destroy() end) end
                    local bb=Instance.new("BillboardGui")
                    bb.Size=UDim2.fromOffset(52,14)
                    bb.StudsOffset=Vector3.new(0,7,0)
                    bb.AlwaysOnTop=true
                    bb.Adornee=mp
                    bb.MaxDistance=1200
                    bb.Parent=plot
                    local bgT=Instance.new("Frame",bb)
                    bgT.Size=UDim2.new(1,0,1,0)
                    bgT.BackgroundColor3=T.bg
                    bgT.BackgroundTransparency=0.18
                    bgT.BorderSizePixel=0
                    co(bgT,4)
                    local stk=Instance.new("UIStroke",bgT)
                    stk.Color=T.yel
                    stk.Thickness=0.8
                    stk.Transparency=0.28
                    stk.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
                    local tl=Instance.new("TextLabel",bgT)
                    tl.Size=UDim2.new(1,0,1,0)
                    tl.BackgroundTransparency=1
                    tl.Font=Enum.Font.GothamBold
                    tl.TextSize=9
                    tl.TextColor3=T.yel
                    tl.TextStrokeTransparency=0.45
                    timerESPs[plot.Name]={bb=bb,lbl=tl,stk=stk}
                    e=timerESPs[plot.Name]
                end
                e.lbl.Text=tl2.Text
                local m,s2=tl2.Text:match("(%d+):(%d+)")
                if m and s2 then
                    local tot=tonumber(m)*60+tonumber(s2)
                    local col=tot<=30 and T.red or tot<=60 and T.yel or T.grn
                    e.lbl.TextColor3=col
                    e.stk.Color=col
                    if myPlotRef and plot==myPlotRef then
                        if tot<=5 and not baseAlerted then
                            baseAlerted=true
                            pcall(function()
                                local s3=Instance.new("Sound")
                                s3.SoundId="rbxassetid://9118633772"
                                s3.Volume=0.85
                                s3.Parent=workspace
                                s3:Play()
                                Debris:AddItem(s3,5)
                            end)
                        elseif tot>5 then
                            baseAlerted=false
                        end
                    end
                end
            else
                local e=timerESPs[plot.Name]
                if e then pcall(function() e.bb:Destroy() end); timerESPs[plot.Name]=nil end
            end
        end
    end
end)

-- Player ESP (SelectionBox outline)
local ESPTAG="AE_"..tostring(math.random(1000,9999))
local function mkESP(plr)
    if plr==lp then return end
    local char=plr.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp or char:FindFirstChild(ESPTAG) then return end
    local sel=Instance.new("SelectionBox",char)
    sel.Name=ESPTAG
    sel.Adornee=char
    sel.Color3=T.white
    sel.LineThickness=0.06
    sel.SurfaceTransparency=0.88
    sel.SurfaceColor3=T.white
    local bb=Instance.new("BillboardGui",char)
    bb.Name=ESPTAG.."N"
    bb.Adornee=char:FindFirstChild("Head") or hrp
    bb.Size=UDim2.fromOffset(130,36)
    bb.StudsOffset=Vector3.new(0,3.5,0)
    bb.AlwaysOnTop=true
    local bgE=Instance.new("Frame",bb)
    bgE.Size=UDim2.new(1,0,1,0)
    bgE.BackgroundColor3=T.bg
    bgE.BackgroundTransparency=0.22
    bgE.BorderSizePixel=0
    co(bgE,5)
    local se=Instance.new("UIStroke",bgE)
    se.Thickness=1
    se.Color=T.a1
    se.Transparency=0.28
    se.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(bgE,{Size=UDim2.new(1,0,0.55,0),BackgroundTransparency=1,Text=plr.DisplayName,
        Font=Enum.Font.GothamBold,TextSize=9,TextColor3=T.white,TextStrokeTransparency=0.45})
    local heldLbl=lb(bgE,{Size=UDim2.new(1,0,0.45,0),Position=UDim2.new(0,0,0.55,0),
        BackgroundTransparency=1,Text="",Font=Enum.Font.Gotham,TextSize=7,TextColor3=T.dim})
    task.spawn(function()
        while bb.Parent do
            task.wait(0.5)
            local tool=char and char:FindFirstChildOfClass("Tool")
            heldLbl.Text=tool and tool.Name or ""
        end
    end)
end
for _,p in ipairs(Players:GetPlayers()) do
    if p~=lp then task.defer(function() mkESP(p) end) end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end)
end)
for _,p in ipairs(Players:GetPlayers()) do
    if p~=lp then
        p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end)
    end
end

-- Mine ESP
local mineESPs={}
local function addMineESP(child)
    if mineESPs[child] then return end
    local nl=child.Name:lower()
    if not (nl:find("subspace") or nl:find("mine")) then return end
    if nl:find("bullet") then return end
    local part=child:IsA("BasePart") and child or (child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")))
    if not part then return end
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.fromOffset(80,20)
    bb.StudsOffset=Vector3.new(0,4,0)
    bb.AlwaysOnTop=true
    bb.Adornee=part
    bb.Parent=workspace
    local bgM=Instance.new("Frame",bb)
    bgM.Size=UDim2.new(1,0,1,0)
    bgM.BackgroundColor3=Color3.fromRGB(22,4,4)
    bgM.BackgroundTransparency=0.18
    bgM.BorderSizePixel=0
    co(bgM,4)
    local sm=Instance.new("UIStroke",bgM)
    sm.Color=T.red
    sm.Thickness=1
    sm.Transparency=0.18
    sm.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local tl=Instance.new("TextLabel",bgM)
    tl.Size=UDim2.new(1,0,1,0)
    tl.BackgroundTransparency=1
    tl.Text="MINE: "..child.Name
    tl.Font=Enum.Font.GothamBold
    tl.TextSize=9
    tl.TextColor3=T.red
    mineESPs[child]={bb=bb}
    child.AncestryChanged:Connect(function()
        if not child.Parent then
            pcall(function() bb:Destroy() end)
            mineESPs[child]=nil
        end
    end)
end
for _,d in pairs(workspace:GetDescendants()) do addMineESP(d) end
workspace.DescendantAdded:Connect(function(d) task.defer(function() addMineESP(d) end) end)

-- Brainrot ESP
local brainrotESPCache={}
local brainrotESPEnabled=false
local brainrotConns={}
local function addBrainrotESP(model,plot)
    if not model or brainrotESPCache[model] then return end
    if model.Name=="PromptAttachment" or model.Name=="" then return end
    local part=nil
    if model:IsA("Model") then
        part=model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    elseif model:IsA("BasePart") then
        part=model
    end
    if not part then return end
    local owner=""
    if plot then
        local sign=plot:FindFirstChild("PlotSign")
        if sign then
            local tl=sign:FindFirstChild("TextLabel",true)
            if tl then owner=tl.Text end
        end
    end
    local bb=Instance.new("BillboardGui")
    bb.Name="AethBrainESP"
    bb.Size=UDim2.fromOffset(112,26)
    bb.StudsOffset=Vector3.new(0,5,0)
    bb.AlwaysOnTop=true
    bb.Adornee=part
    bb.Parent=workspace
    local bg=Instance.new("Frame",bb)
    bg.Size=UDim2.new(1,0,1,0)
    bg.BackgroundColor3=T.bg
    bg.BackgroundTransparency=0.22
    bg.BorderSizePixel=0
    co(bg,5)
    local bs=Instance.new("UIStroke",bg)
    bs.Thickness=1
    bs.Color=T.a2
    bs.Transparency=0.22
    bs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(bg,{Size=UDim2.new(1,0,0,14),Position=UDim2.fromOffset(0,2),BackgroundTransparency=1,
        Text=model.Name,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=T.a1,TextTruncate=Enum.TextTruncate.AtEnd})
    if owner~="" then
        lb(bg,{Size=UDim2.new(1,-4,0,10),Position=UDim2.fromOffset(2,14),BackgroundTransparency=1,
            Text=owner,Font=Enum.Font.Gotham,TextSize=7,TextColor3=T.dim,TextTruncate=Enum.TextTruncate.AtEnd})
    end
    brainrotESPCache[model]=bb
    model.AncestryChanged:Connect(function()
        if not model.Parent then
            pcall(function() bb:Destroy() end)
            brainrotESPCache[model]=nil
        end
    end)
end
local function scanSpawn(spawn,plot)
    for _,child in ipairs(spawn:GetChildren()) do addBrainrotESP(child,plot) end
    local c=spawn.ChildAdded:Connect(function(child)
        if brainrotESPEnabled then task.defer(function() addBrainrotESP(child,plot) end) end
    end)
    table.insert(brainrotConns,c)
end
local function startBrainrotESP()
    if brainrotESPEnabled then return end
    brainrotESPEnabled=true
    local plots=workspace:FindFirstChild("Plots")
    if not plots then return end
    for _,plot in ipairs(plots:GetChildren()) do
        local pods=plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _,pod in ipairs(pods:GetChildren()) do
            local base=pod:FindFirstChild("Base")
            local spawn=base and base:FindFirstChild("Spawn")
            if spawn then scanSpawn(spawn,plot) end
        end
        local c=pods.ChildAdded:Connect(function(pod)
            if brainrotESPEnabled then
                local base=pod:FindFirstChild("Base")
                local spawn=base and base:FindFirstChild("Spawn")
                if spawn then scanSpawn(spawn,plot) end
            end
        end)
        table.insert(brainrotConns,c)
    end
end
local function stopBrainrotESP()
    if not brainrotESPEnabled then return end
    brainrotESPEnabled=false
    for _,c in ipairs(brainrotConns) do pcall(function() c:Disconnect() end) end
    brainrotConns={}
    for _,bb in pairs(brainrotESPCache) do pcall(function() bb:Destroy() end) end
    brainrotESPCache={}
end

-- Friends ESP
local friendESPCache={}
local friendESPEnabled=false
local friendConns={}
local function buildFriendBB(main,isOpen)
    local bb=Instance.new("BillboardGui")
    bb.Adornee=main
    bb.Size=UDim2.fromOffset(52,18)
    bb.StudsOffset=Vector3.new(0,5,0)
    bb.AlwaysOnTop=true
    bb.Parent=main
    local bg=Instance.new("Frame",bb)
    bg.Size=UDim2.new(1,0,1,0)
    bg.BackgroundColor3=T.bg
    bg.BackgroundTransparency=0.22
    bg.BorderSizePixel=0
    co(bg,5)
    local bs=Instance.new("UIStroke",bg)
    bs.Thickness=1
    bs.Color=isOpen and T.grn or T.red
    bs.Transparency=0.22
    bs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    lb(bg,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=isOpen and "OPEN" or "CLOSED",TextColor3=isOpen and T.grn or T.red,
        Font=Enum.Font.GothamBold,TextSize=9})
    return bb
end
local function addFriendESP(plot)
    if not plot:IsA("Model") then return end
    local fp=plot:FindFirstChild("FriendPanel")
    if not fp then return end
    local main=fp:FindFirstChild("Main")
    if not main then return end
    local prompt=main:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return end
    if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end); friendESPCache[plot]=nil end
    friendESPCache[plot]=buildFriendBB(main,prompt.ObjectText=="Disallow Friends")
    local c=prompt:GetPropertyChangedSignal("ObjectText"):Connect(function()
        if not friendESPEnabled then return end
        if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end); friendESPCache[plot]=nil end
        friendESPCache[plot]=buildFriendBB(main,prompt.ObjectText=="Disallow Friends")
    end)
    table.insert(friendConns,c)
    plot.AncestryChanged:Connect(function()
        if not plot.Parent then
            if friendESPCache[plot] then pcall(function() friendESPCache[plot]:Destroy() end) end
            friendESPCache[plot]=nil
        end
    end)
end
local function startFriendESP()
    if friendESPEnabled then return end
    friendESPEnabled=true
    local plots=workspace:FindFirstChild("Plots")
    if not plots then return end
    for _,p in ipairs(plots:GetChildren()) do addFriendESP(p) end
    local c=plots.ChildAdded:Connect(function(p)
        if friendESPEnabled then task.wait(0.5); addFriendESP(p) end
    end)
    table.insert(friendConns,c)
end
local function stopFriendESP()
    if not friendESPEnabled then return end
    friendESPEnabled=false
    for _,c in ipairs(friendConns) do pcall(function() c:Disconnect() end) end
    friendConns={}
    for _,bb in pairs(friendESPCache) do pcall(function() bb:Destroy() end) end
    friendESPCache={}
end

-- Base Xray (LocalTransparencyModifier = client only, harder to detect)
local xrayOn=false
local xrayOrig={}
local function enableXray()
    if xrayOn then return end
    xrayOn=true
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n=obj.Name:lower()
            if n:find("floor") or n:find("wall") or n:find("base") or n:find("plot") or n:find("ceil") then
                if not xrayOrig[obj] then xrayOrig[obj]=obj.LocalTransparencyModifier end
                obj.LocalTransparencyModifier=0.72
            end
        end
    end
end
local function disableXray()
    if not xrayOn then return end
    xrayOn=false
    for obj,t in pairs(xrayOrig) do
        pcall(function() if obj and obj.Parent then obj.LocalTransparencyModifier=t end end)
    end
    xrayOrig={}
end

-- Admin remote
local ADM_REMOTE=nil
task.spawn(function()
    pcall(function() if not lp.Character then lp.CharacterAdded:Wait() end end)
    task.wait(1.5)
    pcall(function()
        local net=RS:WaitForChild("Packages"):WaitForChild("Net")
        local ch=net:GetChildren()
        local n2i={}
        for i,o in ipairs(ch) do n2i[o.Name]=i end
        local a=n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
        if a and ch[a+1] then ADM_REMOTE=ch[a+1] end
    end)
end)
local ADM_UUID="f888ee6e-c86d-46e1-93d7-0639d6635d42"
local function aFire(tgt,cmd)
    task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,tgt,cmd) end) end)
end
local ROW_CD={ragdoll=30,balloon=30,tiny=60,jail=60,rocket=120}
local CMD_ICONS={ragdoll="🤸",balloon="🎈",tiny="🐜",jail="🔒",rocket="🚀"}
local rowCdEnd={}
local function fireCmd(tgt,cmd)
    if not ADM_REMOTE then return end
    aFire(tgt,cmd)
    rowCdEnd[cmd]=tick()+(ROW_CD[cmd] or 30)
end
local CLICK_CMDS={"tiny","inverse","rocket","jumpscare"}
local function fireClick(tgt)
    if not ADM_REMOTE then return end
    for _,cmd in ipairs(CLICK_CMDS) do
        aFire(tgt,cmd)
        if ROW_CD[cmd] then rowCdEnd[cmd]=tick()+ROW_CD[cmd] end
    end
end

local potionOn=Cfg.potionOn
local function activatePotion()
    if not potionOn then return end
    task.spawn(function()
        pcall(function()
            local char=lp.Character
            if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local bp=lp:FindFirstChild("Backpack")
            local tool=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion"))
            if not tool then return end
            hum:EquipTool(tool)
            task.wait(0.08)
            tool:Activate()
        end)
    end)
end

-- Irish Hub instant reset
local tpPos=CFrame.new(1000003.56,999999.69,8.17)
local function doReset()
    local c=lp.Character
    if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart")
    local hum=c:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    cam.CameraType=Enum.CameraType.Scriptable
    task.delay(0.6,function()
        local ch=lp.Character
        local hm=ch and ch:FindFirstChildOfClass("Humanoid")
        if hm then
            cam.CameraType=Enum.CameraType.Custom
            cam.CameraSubject=hm
        end
    end)
    h.CFrame=tpPos
    local con
    con=RunService.Heartbeat:Connect(function()
        if not c or not c.Parent then con:Disconnect(); return end
        if hum.Health<=0 then con:Disconnect(); return end
        h.CFrame=tpPos
    end)
end

local FLASH_NAMES={"Flash Teleport","Flash","FlashTP","Flash TP"}
local function equipFlash()
    pcall(function()
        local char=lp.Character
        if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        for _,n in ipairs(FLASH_NAMES) do
            local t=char:FindFirstChild(n) or (lp.Backpack and lp.Backpack:FindFirstChild(n))
            if t then
                if t.Parent~=char then hum:EquipTool(t) end
                return
            end
        end
    end)
end

-- Flash RF bypass
local FLASH_RF=nil
task.spawn(function()
    pcall(function()
        local net=RS:WaitForChild("Packages"):WaitForChild("Net")
        FLASH_RF=net:FindFirstChild("RF/Tools/Flash/Activate") or net:WaitForChild("RF/Tools/Flash/Activate",10)
    end)
end)

-- Remove flash effects
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local fa=RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Tools") and RS.Assets.Tools:FindFirstChild("Flash Teleport")
            if fa then
                for _,v in ipairs(fa:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
                        pcall(function() v.Enabled=false end)
                    end
                    if v:IsA("Sound") then pcall(function() v.Volume=0 end) end
                end
            end
        end)
        pcall(function()
            local char=lp.Character
            if not char then return end
            for _,n in ipairs(FLASH_NAMES) do
                local t=char:FindFirstChild(n)
                if t then
                    for _,v in ipairs(t:GetDescendants()) do
                        if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
                            pcall(function() v.Enabled=false end)
                        end
                        if v:IsA("Sound") then pcall(function() v.Volume=0 end) end
                    end
                end
            end
        end)
    end
end)

-- Cam align (Phantom Hub V5 exact)
local cfA=CFrame.new(-322.066,-7.871,111.991)*CFrame.Angles(0.332,-0.019,0.000)
local cfB=CFrame.new(-325.856,-7.866,113.027)*CFrame.Angles(0.327,3.130,0.000)
local lookA2=cfA.LookVector
local lookB2=cfB.LookVector
local desiredY=lookA2.Y
local function flattenV(v)
    local f=Vector3.new(v.X,0,v.Z)
    return f.Magnitude>0 and f.Unit or f
end
local function buildLook(bl)
    local h2=flattenV(bl)
    local fs=math.sqrt(math.max(0,1-desiredY^2))
    return Vector3.new(h2.X*fs,desiredY,h2.Z*fs)
end
local function getBestLook2()
    local cf=flattenV(cam.CFrame.LookVector)
    if cf:Dot(flattenV(lookA2))>cf:Dot(flattenV(lookB2)) then
        return buildLook(lookA2)
    else
        return buildLook(lookB2)
    end
end
local function alignCam()
    local pos=cam.CFrame.Position
    local best=getBestLook2()
    cam.CameraType=Enum.CameraType.Scriptable
    cam.CFrame=CFrame.lookAt(pos,pos+best)
    task.wait()
    cam.CameraType=Enum.CameraType.Custom
end

-- EXT callbacks (Phantom Hub V5 exact)
local StealCBCache={}
local function buildStealCBs(prompt)
    if StealCBCache[prompt] then return end
    local data={hold={},trig={}}
    local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then
        for _,c in ipairs(c1) do
            if type(c.Function)=="function" then table.insert(data.hold,c.Function) end
        end
    end
    local ok2,c2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(c2)=="table" then
        for _,c in ipairs(c2) do
            if type(c.Function)=="function" then table.insert(data.trig,c.Function) end
        end
    end
    if #data.hold>0 or #data.trig>0 then StealCBCache[prompt]=data end
end
local function fireStealCBs(prompt)
    local data=StealCBCache[prompt]
    if not data then return end
    for _,fn in ipairs(data.hold) do task.spawn(fn) end
    task.wait(0.05)
    for _,fn in ipairs(data.trig) do task.spawn(fn) end
end

-- FLASH TP: RenderStepped for prerender accuracy + RF bypass
local flashEnabled=Cfg.flashOn
local sliderValue=Cfg.triggerChance/100
local activePrompts={}
local lagOnSteal=false
PPS.PromptButtonHoldBegan:Connect(function(prompt)
    if not flashEnabled then return end
    if prompt.ActionText~="Steal" then return end
    if activePrompts[prompt] then return end
    activePrompts[prompt]=true
    local fired=false
    local fireAt=os.clock()+math.max(prompt.HoldDuration,0.001)*sliderValue
    local conn
    -- RenderStepped = fires BEFORE each frame renders = most accurate timing possible
    conn=RunService.RenderStepped:Connect(function()
        if fired then conn:Disconnect(); return end
        if not prompt or not prompt.Parent then conn:Disconnect(); activePrompts[prompt]=nil; return end
        if os.clock()>=fireAt then
            fired=true
            conn:Disconnect()
            activePrompts[prompt]=nil
            isStealing=true
            task.delay(0.9,function() isStealing=false end)
            -- Lag before flash fires
            if lagOnSteal then
                local deadline=tick()+0.05; local x=0
                while tick()<deadline do for i=1,500 do x=x+i*0.001 end end
            end
            -- Fire flash: RF bypass first, then tool activate
            if FLASH_RF then
                pcall(function() FLASH_RF:InvokeServer() end)
            else
                local char=lp.Character
                local tool=char and char:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
            -- Also try tool activated connections for RF fallback
            task.spawn(function()
                local char=lp.Character
                if char then
                    for _,n in ipairs(FLASH_NAMES) do
                        local tool=char:FindFirstChild(n)
                        if tool then
                            local ok,conns=pcall(getconnections,tool.Activated)
                            if ok and type(conns)=="table" and #conns>0 then
                                for _,c in ipairs(conns) do
                                    if c.Function then task.spawn(c.Function) end
                                end
                            end
                            break
                        end
                    end
                end
            end)
            task.spawn(function()
                RunService.Heartbeat:Wait()
                activatePotion()
            end)
            task.spawn(function()
                task.wait(0.1)
                buildStealCBs(prompt)
                if StealCBCache[prompt] then fireStealCBs(prompt) end
            end)
        end
    end)
    prompt.PromptButtonHoldEnded:Connect(function()
        if not fired then
            fired=true
            activePrompts[prompt]=nil
            conn:Disconnect()
        end
    end)
end)

-- Speed (overrides potion speed too)
local stealSpdOn=Cfg.stealSpdOn
local STEAL_SPD_VAL=math.clamp(Cfg.stealSpdVal or 30,10,60)
local speedEnabled=stealSpdOn
local stealingSpeed=STEAL_SPD_VAL
RunService.Heartbeat:Connect(function()
    if not speedEnabled then return end
    local char=lp.Character
    if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if hum.MoveDirection.Magnitude>0 then
        root.Velocity=Vector3.new(hum.MoveDirection.X*stealingSpeed,root.Velocity.Y,hum.MoveDirection.Z*stealingSpeed)
    end
end)

-- Auto Grab v2 (Phantom Grab v2 exact logic)
local grabEnabled=Cfg.grabOn
local activeHolds={}
local GRAB_DIST=12
local HOLD_DUR_GRAB=1.5
local function getAllGrabPrompts()
    local result={}
    local char=lp.Character
    local root=char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
    if not root then return result end
    local plots=workspace:FindFirstChild("Plots")
    if not plots then return result end
    for _,plot in ipairs(plots:GetChildren()) do
        if isMyPlot(plot) then continue end
        local pods=plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _,pod in ipairs(pods:GetChildren()) do
            local base=pod:FindFirstChild("Base")
            if not base then continue end
            local spawn=base:FindFirstChild("Spawn")
            if not spawn then continue end
            local att=spawn:FindFirstChild("PromptAttachment")
            if not att then continue end
            for _,p in ipairs(att:GetChildren()) do
                if p:IsA("ProximityPrompt") and (p.ActionText=="Steal" or p.ActionText=="Grab") then
                    local dist=(spawn.Position-root.Position).Magnitude
                    table.insert(result,{prompt=p,dist=dist,spawn=spawn})
                end
            end
        end
    end
    return result
end
lp.CharacterAdded:Connect(function()
    for p in pairs(activeHolds) do pcall(function() p:InputHoldEnd() end) end
    activeHolds={}
    isStealing=false
end)
RunService.Heartbeat:Connect(function()
    if not grabEnabled then return end
    local char=lp.Character
    local root=char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
    if not root then return end
    local prompts=getAllGrabPrompts()
    local seen={}
    for _,entry in ipairs(prompts) do
        local p=entry.prompt
        local dist=entry.dist
        seen[p]=true
        if not activeHolds[p] then
            activeHolds[p]={startTime=os.clock(),fired=false}
            pcall(function() p.Enabled=true end)
            pcall(function() p:InputHoldBegin() end)
        end
        local data=activeHolds[p]
        if data.fired then continue end
        local progress=(os.clock()-data.startTime)/HOLD_DUR_GRAB
        if (dist<=GRAB_DIST and progress>=0.92) or progress>=1.05 then
            data.fired=true
            if not flashEnabled then
                isStealing=true
                pcall(function() fireproximityprompt(p) end)
                pcall(function() fireproximityprompt(p,10000) end)
                pcall(function()
                    local conns=getconnections(p.Triggered)
                    if conns then
                        for _,c in ipairs(conns) do
                            if c.Function then task.spawn(c.Function) end
                        end
                    end
                end)
            end
            task.spawn(function()
                task.wait(0.1)
                pcall(function() p:InputHoldEnd() end)
                activeHolds[p]=nil
                task.wait(0.3)
                isStealing=false
            end)
        end
    end
    for p,data in pairs(activeHolds) do
        if not seen[p] then
            if not data.fired then pcall(function() p:InputHoldEnd() end) end
            activeHolds[p]=nil
        end
    end
end)

-- Base Protector
local antiSteal=false
local autoKickBase=false
local lastPunish={}
local myStealPrompts={}
task.spawn(function()
    while true do
        task.wait(2)
        myStealPrompts={}
        if myPlotRef then
            for _,obj in ipairs(myPlotRef:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.ActionText=="Steal" and obj.Enabled then
                    table.insert(myStealPrompts,obj)
                end
            end
        end
    end
end)
local function punish(p)
    if not ADM_REMOTE or not p or p==lp then return end
    local uid=p.UserId
    local now=tick()
    if lastPunish[uid] and now-lastPunish[uid]<0.5 then return end
    lastPunish[uid]=now
    pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,p,"balloon") end)
    rowCdEnd["balloon"]=tick()+(ROW_CD["balloon"] or 30)
    if autoKickBase then task.delay(0.05,function() lp:Kick("SAVED BY AETHEN") end) end
end
local function findThief()
    local searchPos=stealHitbox and stealHitbox.Position
    if not searchPos then
        local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        searchPos=hrp and hrp.Position
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
local function isPromptOnMyBase(prompt)
    if not myPlotRef then return false end
    local a=prompt.Parent
    while a and a~=workspace do
        if a==myPlotRef then return true end
        a=a.Parent
    end
    return false
end
pcall(function()
    if not hookfunction or not fireproximityprompt then return end
    local old=fireproximityprompt
    hookfunction(fireproximityprompt,newcclosure(function(prompt,...)
        if antiSteal and (prompt.ActionText or ""):lower():find("steal") and isPromptOnMyBase(prompt) then
            local t=findThief()
            if t then punish(t) end
        end
        return old(prompt,...)
    end))
end)

local cmdBtnRefs={}
local lastDt=1/60
RunService.Heartbeat:Connect(function(dt)
    lastDt=dt
    local now=tick()
    for _,cmds in pairs(cmdBtnRefs) do
        for cmd,ib in pairs(cmds) do
            if ib and ib.Parent then
                local cd=rowCdEnd[cmd]
                if cd and cd>now then
                    local rem=math.ceil(cd-now)
                    local rs=tostring(rem)
                    if ib.Text~=rs then
                        ib.Text=rs; ib.TextSize=9; ib.TextColor3=T.red
                        ib.BackgroundColor3=Color3.fromRGB(65,8,8); ib.BackgroundTransparency=0.1
                    end
                else
                    local icon=CMD_ICONS[cmd] or "?"
                    if ib.Text~=icon then
                        ib.Text=icon; ib.TextSize=11; ib.TextColor3=T.a1
                        ib.BackgroundColor3=T.surf2; ib.BackgroundTransparency=0.22
                    end
                end
            end
        end
    end
end)

-- PANELS
task.wait(0.15)
vp=cam.ViewportSize
if vp.X==0 then vp=Vector2.new(390,844) end

-- Header box
local hdrW=210
local hdrH=100
local hdrF=Instance.new("Frame",SG)
hdrF.Size=UDim2.fromOffset(hdrW,hdrH)
hdrF.Position=UDim2.fromOffset(math.floor(vp.X*0.5-hdrW*0.5),4)
hdrF.BackgroundColor3=T.panel
hdrF.BackgroundTransparency=0.14
hdrF.BorderSizePixel=0
co(hdrF,9)
rotS(hdrF,T.a1)
particles(hdrF,4)
hdrF.Active=false
lb(hdrF,{Position=UDim2.fromOffset(0,5),Size=UDim2.new(1,0,0,16),
    Text="AETHEN HUB  v1.1",TextSize=11,Font=Enum.Font.GothamBlack,
    TextColor3=T.a1,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
lb(hdrF,{Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,11),
    Text="r9qbx",TextSize=7,Font=Enum.Font.Gotham,TextColor3=T.dim,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
local fpsLb=lb(hdrF,{Position=UDim2.fromOffset(0,31),Size=UDim2.new(1,0,0,11),
    Text="FPS --  PING --ms",TextSize=7,Font=Enum.Font.GothamBold,TextColor3=T.grn,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
task.spawn(function()
    while task.wait(0.7) do
        if not fpsLb.Parent then break end
        local fps=math.min(999,math.floor(1/math.max(lastDt,0.001)))
        local ping=0
        pcall(function() ping=math.floor(lp:GetNetworkPing()*1000) end)
        fpsLb.Text="FPS "..fps.."  PING "..ping.."ms"
        fpsLb.TextColor3=fps<40 and T.red or fps<55 and T.yel or T.grn
    end
end)
local function hdrBtn(text,pos,w,tc,bg2)
    local b=Instance.new("TextButton",hdrF)
    b.Size=UDim2.fromOffset(w or 60,15)
    b.Position=pos
    b.BackgroundColor3=bg2 or T.surf
    b.BackgroundTransparency=0.22
    b.Text=text
    b.TextColor3=tc or T.a1
    b.Font=Enum.Font.GothamBold
    b.TextSize=7
    b.BorderSizePixel=0
    b.AutoButtonColor=false
    co(b,4)
    ms(b,1,T.str,0.5)
    b.ZIndex=5
    return b
end
local grabHdrBtn=hdrBtn("Grab: OFF",UDim2.fromOffset(6,46),62,T.dim)
local function updGrabHdr()
    grabHdrBtn.Text=grabEnabled and "Grab: ON" or "Grab: OFF"
    grabHdrBtn.TextColor3=grabEnabled and T.grn or T.dim
    TweenService:Create(grabHdrBtn,TweenInfo.new(0.1),
        {BackgroundColor3=grabEnabled and Color3.fromRGB(8,22,12) or T.surf}):Play()
end
updGrabHdr()
grabHdrBtn.MouseButton1Click:Connect(function()
    grabEnabled=not grabEnabled; Cfg.grabOn=grabEnabled; save(); updGrabHdr()
end)
local rsPnlBtn=hdrBtn("Reset Panels",UDim2.fromOffset(72,46),68,T.dim)
local discordBtn=hdrBtn("Discord",UDim2.fromOffset(144,46),60,T.a2)
discordBtn.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard("https://"..DISCORD_LINK) end end)
    pcall(function() if openbrowser then openbrowser("https://"..DISCORD_LINK) end end)
    discordBtn.Text="Copied!"
    discordBtn.TextColor3=T.grn
    task.delay(1.5,function() discordBtn.Text="Discord"; discordBtn.TextColor3=T.a2 end)
end)
local ragBtn=hdrBtn("Ragdoll Self",UDim2.fromOffset(6,65),90,T.red,Color3.fromRGB(22,5,5))
ragBtn.MouseButton1Click:Connect(function()
    if ADM_REMOTE then
        pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end)
        rowCdEnd["ragdoll"]=tick()+(ROW_CD["ragdoll"] or 30)
    end
end)
local prBtn=hdrBtn("Pot+Rag",UDim2.fromOffset(100,65),68,Color3.fromRGB(180,130,255),Color3.fromRGB(14,8,22))
prBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local char=lp.Character
        if char then
            pcall(function()
                local hum=char:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                local bp=lp:FindFirstChild("Backpack")
                local pot=char:FindFirstChild("Giant Potion") or (bp and bp:FindFirstChild("Giant Potion"))
                if pot then hum:EquipTool(pot); task.wait(0.1); pot:Activate() end
            end)
        end
        task.wait(0.5)
        if ADM_REMOTE then
            pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,lp,"ragdoll") end)
            rowCdEnd["ragdoll"]=tick()+(ROW_CD["ragdoll"] or 30)
        end
    end)
end)

-- Flash TP panel with MAIN/EXTRAS tabs
local FP_W=148
local CONT_H=160
local FP_H=21+20+CONT_H+4
local FP_defX=math.floor(vp.X-FP_W-5)
local FP_defY=5
local FP,_,fpMin=mkP(FP_defX,FP_defY,FP_W,FP_H,"Flash TP",T.a2,"pos_FP")
local fpFolded=false
local FP_fullH=FP_H
fpMin.MouseButton1Click:Connect(function()
    fpFolded=not fpFolded
    fpMin.Text=fpFolded and "+" or "─"
    TweenService:Create(FP,TweenInfo.new(0.22,Enum.EasingStyle.Quad),
        {Size=UDim2.fromOffset(FP_W,fpFolded and 23 or FP_fullH)}):Play()
end)
local tabRow=Instance.new("Frame",FP)
tabRow.Size=UDim2.fromOffset(FP_W,20)
tabRow.Position=UDim2.fromOffset(0,22)
tabRow.BackgroundColor3=T.surf2
tabRow.BackgroundTransparency=0.1
tabRow.BorderSizePixel=0
local tabMBtn=Instance.new("TextButton",tabRow)
tabMBtn.Size=UDim2.new(0.5,0,1,0)
tabMBtn.BackgroundColor3=T.a1
tabMBtn.Text="MAIN"
tabMBtn.Font=Enum.Font.GothamBlack
tabMBtn.TextSize=8
tabMBtn.TextColor3=T.bg
tabMBtn.BorderSizePixel=0
tabMBtn.AutoButtonColor=false
co(tabMBtn,0)
local tabEBtn=Instance.new("TextButton",tabRow)
tabEBtn.Size=UDim2.new(0.5,0,1,0)
tabEBtn.Position=UDim2.new(0.5,0,0,0)
tabEBtn.BackgroundColor3=T.surf2
tabEBtn.Text="EXTRAS"
tabEBtn.Font=Enum.Font.GothamBlack
tabEBtn.TextSize=8
tabEBtn.TextColor3=T.dim
tabEBtn.BorderSizePixel=0
tabEBtn.AutoButtonColor=false
co(tabEBtn,0)
local cont=Instance.new("Frame",FP)
cont.Size=UDim2.fromOffset(FP_W,CONT_H)
cont.Position=UDim2.fromOffset(0,43)
cont.BackgroundTransparency=1
cont.BorderSizePixel=0
cont.ClipsDescendants=true
local pg1=Instance.new("Frame",cont)
pg1.Size=UDim2.fromOffset(FP_W,CONT_H)
pg1.BackgroundTransparency=1
pg1.BorderSizePixel=0
local pg2=Instance.new("Frame",cont)
pg2.Size=UDim2.fromOffset(FP_W,CONT_H)
pg2.BackgroundTransparency=1
pg2.BorderSizePixel=0
pg2.Visible=false
local function setTab(isMain)
    tabMBtn.BackgroundColor3=isMain and T.a1 or T.surf2
    tabMBtn.TextColor3=isMain and T.bg or T.dim
    tabEBtn.BackgroundColor3=not isMain and T.a1 or T.surf2
    tabEBtn.TextColor3=not isMain and T.bg or T.dim
    pg1.Visible=isMain
    pg2.Visible=not isMain
end
tabMBtn.MouseButton1Click:Connect(function() setTab(true) end)
tabEBtn.MouseButton1Click:Connect(function() setTab(false) end)
setTab(true)

-- MAIN tab content
local lagRow=Instance.new("Frame",pg1)
lagRow.Size=UDim2.fromOffset(FP_W-10,21)
lagRow.Position=UDim2.fromOffset(5,4)
lagRow.BackgroundColor3=T.surf
lagRow.BackgroundTransparency=0.28
lagRow.BorderSizePixel=0
co(lagRow,6)
local lagRS=ms(lagRow,1,T.str,0.55)
local lagLbl=lb(lagRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-38,1,0),
    Text="Lag On Steal",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local lagTrack=Instance.new("Frame",lagRow)
lagTrack.Size=UDim2.fromOffset(25,12)
lagTrack.Position=UDim2.new(1,-29,0.5,-6)
lagTrack.BackgroundColor3=T.surf2
lagTrack.BorderSizePixel=0
co(lagTrack,12)
local lagKnob=Instance.new("Frame",lagTrack)
lagKnob.Size=UDim2.fromOffset(8,8)
lagKnob.Position=UDim2.new(0,2,0.5,-4)
lagKnob.BackgroundColor3=T.a2
lagKnob.BorderSizePixel=0
co(lagKnob,8)
local lagBtnR=Instance.new("TextButton",lagRow)
lagBtnR.Size=UDim2.new(1,0,1,0)
lagBtnR.BackgroundTransparency=1
lagBtnR.Text=""
local function setLag(v)
    lagOnSteal=v
    TweenService:Create(lagTrack,TweenInfo.new(0.12),{BackgroundColor3=v and T.a1 or T.surf2}):Play()
    TweenService:Create(lagKnob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=v and T.white or T.a2}):Play()
    TweenService:Create(lagRS,TweenInfo.new(0.12),{Color=v and T.a1 or T.str,Transparency=v and 0.18 or 0.55}):Play()
    lagLbl.TextColor3=v and T.white or T.dim
end
lagBtnR.MouseButton1Click:Connect(function() setLag(not lagOnSteal) end)

local potRow=Instance.new("Frame",pg1)
potRow.Size=UDim2.fromOffset(FP_W-10,21)
potRow.Position=UDim2.fromOffset(5,28)
potRow.BackgroundColor3=T.surf
potRow.BackgroundTransparency=0.28
potRow.BorderSizePixel=0
co(potRow,6)
local potRS=ms(potRow,1,T.str,0.55)
local potLbl=lb(potRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-38,1,0),
    Text="Giant Potion",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local potTrack=Instance.new("Frame",potRow)
potTrack.Size=UDim2.fromOffset(25,12)
potTrack.Position=UDim2.new(1,-29,0.5,-6)
potTrack.BackgroundColor3=T.surf2
potTrack.BorderSizePixel=0
co(potTrack,12)
local potK=Instance.new("Frame",potTrack)
potK.Size=UDim2.fromOffset(8,8)
potK.Position=UDim2.new(0,2,0.5,-4)
potK.BackgroundColor3=T.a2
potK.BorderSizePixel=0
co(potK,8)
local potBtnR=Instance.new("TextButton",potRow)
potBtnR.Size=UDim2.new(1,0,1,0)
potBtnR.BackgroundTransparency=1
potBtnR.Text=""
local function updPot()
    local c=potionOn and Color3.fromRGB(10,10,18) or T.surf
    TweenService:Create(potRow,TweenInfo.new(0.12),{BackgroundColor3=c,BackgroundTransparency=potionOn and 0.15 or 0.28}):Play()
    TweenService:Create(potRS,TweenInfo.new(0.12),{Color=potionOn and T.a1 or T.str,Transparency=potionOn and 0.18 or 0.55}):Play()
    TweenService:Create(potTrack,TweenInfo.new(0.12),{BackgroundColor3=potionOn and T.a1 or T.surf2}):Play()
    TweenService:Create(potK,TweenInfo.new(0.12),{Position=potionOn and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=potionOn and T.white or T.a2}):Play()
    potLbl.TextColor3=potionOn and T.white or T.dim
end
updPot()
potBtnR.MouseButton1Click:Connect(function() potionOn=not potionOn; Cfg.potionOn=potionOn; save(); updPot() end)

local sep1=Instance.new("Frame",pg1)
sep1.Size=UDim2.new(1,-10,0,1)
sep1.Position=UDim2.fromOffset(5,52)
sep1.BackgroundColor3=T.str
sep1.BackgroundTransparency=0.68
sep1.BorderSizePixel=0

local togRow=Instance.new("Frame",pg1)
togRow.Size=UDim2.fromOffset(FP_W-10,21)
togRow.Position=UDim2.fromOffset(5,56)
togRow.BackgroundColor3=T.surf
togRow.BackgroundTransparency=0.28
togRow.BorderSizePixel=0
co(togRow,6)
local togRS=ms(togRow,1,T.str,0.55)
local togLbl=lb(togRow,{Position=UDim2.new(0,7,0,0),Size=UDim2.new(1,-38,1,0),
    Text="Flash TP",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local pill=Instance.new("Frame",togRow)
pill.Size=UDim2.fromOffset(25,12)
pill.Position=UDim2.new(1,-29,0.5,-6)
pill.BackgroundColor3=T.surf2
pill.BorderSizePixel=0
co(pill,12)
local knob=Instance.new("Frame",pill)
knob.Size=UDim2.fromOffset(8,8)
knob.Position=UDim2.new(0,2,0.5,-4)
knob.BackgroundColor3=T.a2
knob.BorderSizePixel=0
co(knob,8)
local togB=Instance.new("TextButton",togRow)
togB.Size=UDim2.new(1,0,1,0)
togB.BackgroundTransparency=1
togB.Text=""
local function updFl()
    local c=flashEnabled and Color3.fromRGB(10,10,18) or T.surf
    TweenService:Create(togRow,TweenInfo.new(0.12),{BackgroundColor3=c,BackgroundTransparency=flashEnabled and 0.15 or 0.28}):Play()
    TweenService:Create(togRS,TweenInfo.new(0.12),{Color=flashEnabled and T.a1 or T.str,Transparency=flashEnabled and 0.18 or 0.55}):Play()
    TweenService:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=flashEnabled and T.a1 or T.surf2}):Play()
    TweenService:Create(knob,TweenInfo.new(0.12),{Position=flashEnabled and UDim2.new(1,-10,0.5,-4) or UDim2.new(0,2,0.5,-4),BackgroundColor3=flashEnabled and T.white or T.a2}):Play()
    togLbl.TextColor3=flashEnabled and T.white or T.dim
end
updFl()
togB.MouseButton1Click:Connect(function() flashEnabled=not flashEnabled; Cfg.flashOn=flashEnabled; save(); updFl() end)

local trigL=lb(pg1,{Position=UDim2.fromOffset(5,81),Size=UDim2.fromOffset(FP_W-10,11),
    Text="Trigger: "..Cfg.triggerChance.."%",TextSize=8,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local slBg=Instance.new("Frame",pg1)
slBg.Size=UDim2.fromOffset(FP_W-10,5)
slBg.Position=UDim2.fromOffset(5,95)
slBg.BackgroundColor3=T.surf
slBg.BorderSizePixel=0
co(slBg,3)
local slFill=Instance.new("Frame",slBg)
slFill.Size=UDim2.new(sliderValue,0,1,0)
slFill.BackgroundColor3=T.a1
slFill.BorderSizePixel=0
co(slFill,3)
local slK=Instance.new("Frame",slBg)
slK.Size=UDim2.fromOffset(10,10)
slK.AnchorPoint=Vector2.new(0.5,0.5)
slK.Position=UDim2.new(sliderValue,0,0.5,0)
slK.BackgroundColor3=T.white
slK.BorderSizePixel=0
co(slK,5)
local slOn=false
local function setTr(pct)
    pct=math.clamp(pct,0,1)
    sliderValue=pct
    Cfg.triggerChance=math.floor(pct*100)
    slFill.Size=UDim2.new(pct,0,1,0)
    slK.Position=UDim2.new(pct,0,0.5,0)
    trigL.Text="Trigger: "..math.floor(pct*100).."%"
end
slBg.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        slOn=true
        setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        if slOn then slOn=false; save() end
    end
end)
UIS.InputChanged:Connect(function(i)
    if not slOn then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        setTr((i.Position.X-slBg.AbsolutePosition.X)/slBg.AbsoluteSize.X)
    end
end)

local camBusy=false
local camBtn=btn(pg1,"AUTO ALLIGN",UDim2.fromOffset(FP_W-10,19),UDim2.fromOffset(5,104),T.surf)
camBtn.TextSize=9
camBtn.TextColor3=T.a1
do
    local s=camBtn:FindFirstChildOfClass("UIStroke")
    if s then s.Color=T.a1; s.Transparency=0.28 end
end
camBtn.MouseButton1Click:Connect(function()
    if camBusy then return end
    camBusy=true
    camBtn.Text="Aligning..."
    pcall(equipFlash)
    task.wait(0.05)
    pcall(alignCam)
    task.delay(1,function() camBtn.Text="AUTO ALLIGN"; camBusy=false end)
end)

local rstBtn=btn(pg1,"Instant Reset",UDim2.fromOffset(FP_W-10,17),UDim2.fromOffset(5,127),Color3.fromRGB(40,6,6))
rstBtn.TextSize=8
rstBtn.TextColor3=T.red
do
    local s=rstBtn:FindFirstChildOfClass("UIStroke")
    if s then s.Color=T.red; s.Transparency=0.3 end
end
rstBtn.MouseButton1Click:Connect(function() task.spawn(doReset) end)

-- EXTRAS tab content
local ssB,ssSet=pillR(pg2,"Steal Speed",4,T.grn)
ssB.MouseButton1Click:Connect(function()
    stealSpdOn=not stealSpdOn
    speedEnabled=stealSpdOn
    ssSet(stealSpdOn)
    Cfg.stealSpdOn=stealSpdOn
    save()
end)
if stealSpdOn then ssSet(true); speedEnabled=true end

local speedNumRow=Instance.new("Frame",pg2)
speedNumRow.Size=UDim2.fromOffset(FP_W-10,20)
speedNumRow.Position=UDim2.fromOffset(5,26)
speedNumRow.BackgroundColor3=T.surf
speedNumRow.BackgroundTransparency=0.28
speedNumRow.BorderSizePixel=0
speedNumRow.Parent=pg2
co(speedNumRow,5)
ms(speedNumRow,1,T.str,0.5)
lb(speedNumRow,{Position=UDim2.new(0,6,0,0),Size=UDim2.new(0.46,0,1,0),Text="Speed",TextSize=8,TextColor3=T.dim,TextXAlignment=Enum.TextXAlignment.Left})
local smB=Instance.new("TextButton",speedNumRow); smB.Size=UDim2.fromOffset(14,14); smB.Position=UDim2.new(0.5,0,0.5,-7); smB.BackgroundColor3=T.surf2; smB.Text="-"; smB.Font=Enum.Font.GothamBold; smB.TextSize=10; smB.TextColor3=T.a1; smB.BorderSizePixel=0; smB.AutoButtonColor=false; co(smB,3)
local svB=Instance.new("TextBox",speedNumRow); svB.Size=UDim2.fromOffset(26,14); svB.Position=UDim2.new(0.5,16,0.5,-7); svB.BackgroundColor3=T.surf2; svB.BorderSizePixel=0; svB.Text=tostring(STEAL_SPD_VAL); svB.Font=Enum.Font.GothamBold; svB.TextSize=9; svB.TextColor3=T.a1; svB.ClearTextOnFocus=false; co(svB,3)
local spB=Instance.new("TextButton",speedNumRow); spB.Size=UDim2.fromOffset(14,14); spB.Position=UDim2.new(0.5,44,0.5,-7); spB.BackgroundColor3=T.surf2; spB.Text="+"; spB.Font=Enum.Font.GothamBold; spB.TextSize=10; spB.TextColor3=T.a1; spB.BorderSizePixel=0; spB.AutoButtonColor=false; co(spB,3)
local function setSpeedVal(v)
    STEAL_SPD_VAL=math.clamp(math.floor(v),10,60)
    stealingSpeed=STEAL_SPD_VAL
    svB.Text=tostring(STEAL_SPD_VAL)
    Cfg.stealSpdVal=STEAL_SPD_VAL
    save()
end
smB.MouseButton1Click:Connect(function() setSpeedVal(STEAL_SPD_VAL-1) end)
spB.MouseButton1Click:Connect(function() setSpeedVal(STEAL_SPD_VAL+1) end)
svB.FocusLost:Connect(function() local n=tonumber(svB.Text); if n then setSpeedVal(n) else svB.Text=tostring(STEAL_SPD_VAL) end end)

local sep2=Instance.new("Frame",pg2)
sep2.Size=UDim2.new(1,-10,0,1)
sep2.Position=UDim2.fromOffset(5,48)
sep2.BackgroundColor3=T.str
sep2.BackgroundTransparency=0.68
sep2.BorderSizePixel=0
local brainB,brainSet=pillR(pg2,"Brainrot ESP",52,T.a1)
brainB.MouseButton1Click:Connect(function()
    if brainrotESPEnabled then stopBrainrotESP(); brainSet(false) else startBrainrotESP(); brainSet(true) end
end)
local friendB,friendSet=pillR(pg2,"Friends ESP",75,T.grn)
friendB.MouseButton1Click:Connect(function()
    if friendESPEnabled then stopFriendESP(); friendSet(false) else startFriendESP(); friendSet(true) end
end)
local xrB,xrSet=pillR(pg2,"Base Xray",98,T.red)
xrB.MouseButton1Click:Connect(function()
    if xrayOn then disableXray(); xrSet(false) else enableXray(); xrSet(true) end
end)

-- Aethens panel
local AP_W2=130
local AP_CH=72
local AP_H2=21+AP_CH+6
local AP_defX=4
local AP_defY=hdrH+4+8
local APan,_,apMin=mkP(AP_defX,AP_defY,AP_W2,AP_H2,"Aethens",T.a1,"pos_AP")
local apC=mkF(APan,21,AP_CH,apMin)
local aY=4
local rejB=btn(apC,"Rejoin",UDim2.fromOffset(AP_W2-10,21),UDim2.fromOffset(5,aY),T.surf)
rejB.TextColor3=T.a1
do local s=rejB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.a1; s.Transparency=0.28 end end
aY=aY+25
rejB.MouseButton1Click:Connect(function()
    rejB.Text="..."
    pcall(function()
        if reconnect then reconnect()
        elseif syn and syn.reconnect then syn.reconnect()
        else TeleportService:Teleport(game.PlaceId,lp) end
    end)
end)
local kickB=btn(apC,"Kick Self",UDim2.fromOffset(AP_W2-10,21),UDim2.fromOffset(5,aY),Color3.fromRGB(30,6,6))
kickB.TextColor3=T.red
do local s=kickB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.red; s.Transparency=0.3 end end
aY=aY+25
kickB.MouseButton1Click:Connect(function() kickB.Text="..."; lp:Kick(DISCORD_LINK) end)
local rstAB=btn(apC,"Instant Reset",UDim2.fromOffset(AP_W2-10,21),UDim2.fromOffset(5,aY),Color3.fromRGB(30,6,6))
rstAB.TextColor3=T.red
do local s=rstAB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.red; s.Transparency=0.3 end end
rstAB.MouseButton1Click:Connect(function() task.spawn(doReset) end)

-- Admin panel
local RCMDS={{cmd="ragdoll",icon="🤸"},{cmd="balloon",icon="🎈"},{cmd="tiny",icon="🐜"},{cmd="jail",icon="🔒"},{cmd="rocket",icon="🚀"}}
local IW2=16; local IH2=18; local IG2=2; local ADM_W=186
local ITOT=#RCMDS*(IW2+IG2)-IG2; local CW2=ADM_W-12; local CSTART=CW2-ITOT-3
local ADM_defX=math.floor(vp.X-ADM_W-5)
local ADM_defY=FP_H+FP_defY+5
local ADMpan,_,admMin=mkP(ADM_defX,ADM_defY,ADM_W,24,"Admin Panel",T.a2,"pos_ADM")
local pScroll=Instance.new("ScrollingFrame",ADMpan)
pScroll.Size=UDim2.fromOffset(ADM_W-8,0)
pScroll.Position=UDim2.fromOffset(4,22)
pScroll.BackgroundColor3=T.bg
pScroll.BackgroundTransparency=0.65
pScroll.BorderSizePixel=0
pScroll.ScrollBarThickness=2
pScroll.ScrollBarImageColor3=T.a1
pScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
pScroll.CanvasSize=UDim2.new(0,0,0,0)
co(pScroll,4)
local pLayout=Instance.new("UIListLayout",pScroll)
pLayout.Padding=UDim.new(0,2)
pLayout.SortOrder=Enum.SortOrder.Name
Instance.new("UIPadding",pScroll).PaddingTop=UDim.new(0,2)
local admFolded=false
local function resADM()
    if admFolded then return end
    local ch=math.min(pLayout.AbsoluteContentSize.Y+4,120)
    pScroll.Size=UDim2.fromOffset(ADM_W-8,ch)
    ADMpan.Size=UDim2.fromOffset(ADM_W,22+ch+3)
end
pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resADM)
admMin.MouseButton1Click:Connect(function()
    admFolded=not admFolded
    admMin.Text=admFolded and "+" or "─"
    pScroll.Visible=not admFolded
    if admFolded then
        TweenService:Create(ADMpan,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(ADM_W,24)}):Play()
    else
        local ch=math.min(pLayout.AbsoluteContentSize.Y+4,120)
        TweenService:Create(ADMpan,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.fromOffset(ADM_W,22+ch+3)}):Play()
    end
end)
local pCards={}
local function refreshPlayers()
    for _,c in pairs(pCards) do pcall(function() c:Destroy() end) end
    pCards={}
    cmdBtnRefs={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card=Instance.new("Frame",pScroll)
        card.Name=p.Name
        card.Size=UDim2.new(1,-4,0,30)
        card.BackgroundColor3=T.surf
        card.BackgroundTransparency=0.26
        card.BorderSizePixel=0
        co(card,5)
        local cs=ms(card,1,T.str,0.55)
        local cz=Instance.new("TextButton",card)
        cz.Size=UDim2.fromOffset(CSTART,30)
        cz.BackgroundTransparency=1
        cz.Text=""
        cz.AutoButtonColor=false
        local ava=Instance.new("ImageLabel",card)
        ava.Size=UDim2.fromOffset(18,18)
        ava.Position=UDim2.new(0,3,0.5,-9)
        ava.BackgroundColor3=T.surf2
        ava.BorderSizePixel=0
        co(ava,9)
        task.spawn(function()
            local ok,img=pcall(Players.GetUserThumbnailAsync,Players,p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
            if ok then ava.Image=img end
        end)
        lb(card,{Position=UDim2.new(0,23,0,3),Size=UDim2.fromOffset(CSTART-26,13),
            Text=p.DisplayName,TextSize=9,Font=Enum.Font.GothamBold,TextColor3=T.a1,
            TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        lb(card,{Position=UDim2.new(0,23,0,16),Size=UDim2.fromOffset(CSTART-26,10),
            Text="@"..p.Name,TextSize=7,Font=Enum.Font.Gotham,TextColor3=T.dim,
            TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        cmdBtnRefs[p.UserId]={}
        for i,def in ipairs(RCMDS) do
            local bx=CSTART+3+(i-1)*(IW2+IG2)
            local ib=Instance.new("TextButton",card)
            ib.Size=UDim2.fromOffset(IW2,IH2)
            ib.Position=UDim2.new(0,bx,0.5,-IH2/2)
            ib.BackgroundColor3=T.surf2
            ib.BackgroundTransparency=0.22
            ib.Text=def.icon
            ib.TextSize=11
            ib.TextColor3=T.a1
            ib.Font=Enum.Font.GothamBold
            ib.BorderSizePixel=0
            ib.AutoButtonColor=false
            ib.Parent=card
            co(ib,4)
            ms(ib,1,T.str,0.52)
            cmdBtnRefs[p.UserId][def.cmd]=ib
            local pd=p; local dc=def.cmd
            ib.MouseButton1Click:Connect(function() fireCmd(pd,dc) end)
        end
        local pd=p
        cz.MouseButton1Click:Connect(function()
            for _,c2 in pairs(pCards) do
                local s2=c2:FindFirstChildOfClass("UIStroke")
                if s2 then s2.Color=T.str; s2.Transparency=0.55 end
                c2.BackgroundTransparency=0.26
            end
            cs.Color=T.a1; cs.Transparency=0; card.BackgroundTransparency=0
            fireClick(pd)
        end)
        pCards[p.UserId]=card
    end
    task.defer(resADM)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshPlayers() end)
task.delay(2,refreshPlayers)

-- Base Protector panel
local BP_W=136
local BP_CH=3*23+6
local BP_H=21+BP_CH+6
local BP_defX=math.floor(vp.X*0.5-BP_W*0.5)
local BP_defY=math.floor(vp.Y*0.5-BP_H*0.5)
local BPpan,_,bpMin=mkP(BP_defX,BP_defY,BP_W,BP_H,"Base Protector",T.a1,"pos_BP")
local bpC=mkF(BPpan,21,BP_CH+6,bpMin)
local asB,asSet=pillR(bpC,"Anti Steal",4,T.a1)
asB.MouseButton1Click:Connect(function() antiSteal=not antiSteal; asSet(antiSteal) end)
local akB,akSet=pillR(bpC,"Auto Kick",27,T.red)
akB.MouseButton1Click:Connect(function() autoKickBase=not autoKickBase; akSet(autoKickBase) end)
local arB,arSet=pillR(bpC,"Anti Ragdoll",50,T.grn)
arSet(true)
arB.MouseButton1Click:Connect(function() end)

-- Reset panels popup
rsPnlBtn.ZIndex=5
rsPnlBtn.MouseButton1Click:Connect(function()
    local popup=Instance.new("Frame",SG)
    popup.Size=UDim2.fromOffset(188,62)
    popup.Position=UDim2.new(0.5,-94,0.38,-31)
    popup.BackgroundColor3=T.panel
    popup.BackgroundTransparency=0.08
    popup.BorderSizePixel=0
    co(popup,10)
    ms(popup,1.5,T.a1,0.18)
    lb(popup,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,4),
        Text="Reset panels?",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=T.a1})
    local yesB=btn(popup,"Yes",UDim2.fromOffset(76,22),UDim2.fromOffset(10,36),Color3.fromRGB(10,32,10))
    yesB.TextColor3=T.grn
    do local s=yesB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.grn; s.Transparency=0.3 end end
    local noB=btn(popup,"No",UDim2.fromOffset(76,22),UDim2.fromOffset(102,36),Color3.fromRGB(32,8,8))
    noB.TextColor3=T.red
    do local s=noB:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.red; s.Transparency=0.3 end end
    noB.MouseButton1Click:Connect(function() popup:Destroy() end)
    yesB.MouseButton1Click:Connect(function()
        local defs={
            pos_FP={ox=FP_defX,oy=FP_defY},pos_AP={ox=AP_defX,oy=AP_defY},
            pos_ADM={ox=ADM_defX,oy=ADM_defY},pos_BP={ox=BP_defX,oy=BP_defY}
        }
        for k,v in pairs(defs) do Cfg[k]=v end
        save()
        FP.Position=UDim2.fromOffset(FP_defX,FP_defY)
        APan.Position=UDim2.fromOffset(AP_defX,AP_defY)
        ADMpan.Position=UDim2.fromOffset(ADM_defX,ADM_defY)
        BPpan.Position=UDim2.fromOffset(BP_defX,BP_defY)
        popup:Destroy()
    end)
end)

print("Aethen Hub v1.1 | r9qbx | loaded")
