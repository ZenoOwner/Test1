pcall(function() game:GetService("CoreGui"):FindFirstChild("PhantomAP"):Destroy() end)

-- ============ SERVICES ============
local Players          = game:GetService("Players")
local TextChatService  = game:GetService("TextChatService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")
local VIM              = game:GetService("VirtualInputService")
local UIS              = game:GetService("UserInputService")
local lp               = Players.LocalPlayer

-- ============ AP CORE (untouched) ============
local function sendCmd(cmd)
    task.spawn(function()
        pcall(function()
            local ch = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
            ch:SendAsync(cmd)
        end)
    end)
end

local function fireBtn(btn)
    pcall(function() for _,c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end end)
    pcall(function() for _,c in pairs(getconnections(btn.Activated)) do c:Fire() end end)
end

local function findAdminPanel()
    return lp:WaitForChild("PlayerGui"):FindFirstChild("AdminPanel")
end

local function getBtnByText(ap, kw)
    for _,obj in ipairs(ap:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local txt = ""
            if obj:IsA("TextButton") then txt=obj.Text:lower()
            else for _,c in ipairs(obj:GetDescendants()) do if c:IsA("TextLabel") then txt=c.Text:lower() break end end end
            if txt:find(kw:lower()) then return obj end
        end
    end
end

local function getPlayerBtn(ap, target)
    for _,obj in ipairs(ap:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local txt = ""
            if obj:IsA("TextButton") then txt=obj.Text
            else for _,c in ipairs(obj:GetDescendants()) do if c:IsA("TextLabel") then txt=c.Text break end end end
            if txt==target.Name or txt==target.DisplayName then return obj end
        end
    end
end

local function runCmds(target, cmds, jail)
    task.spawn(function()
        local ap = findAdminPanel()
        if ap then
            for _,cmd in ipairs(cmds) do
                local pb = getPlayerBtn(ap, target)
                if pb then fireBtn(pb) task.wait(0.08) end
                local cb = getBtnByText(ap, cmd)
                if cb then fireBtn(cb) task.wait(0.08) end
            end
            if jail then
                task.wait(1.5)
                local pb = getPlayerBtn(ap, target)
                if pb then fireBtn(pb) task.wait(0.05) end
                local jb = getBtnByText(ap, "jail")
                if jb then fireBtn(jb) end
            end
        else
            local n = target.Name
            for _,cmd in ipairs(cmds) do sendCmd(";"..cmd.." "..n) task.wait(0.1) end
            if jail then task.delay(1.5, function() sendCmd(";jail "..n) end) end
        end
    end)
end

-- ============ ANTI RAGDOLL (always running) ============
local function getRoot() local c=lp.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=lp.Character return c and c:FindFirstChildOfClass("Humanoid") end

local arMode="off" local arConns={} local arChar={} local arBoosting=false
local function arCache()
    local char=lp.Character if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local root=char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    arChar={character=char,humanoid=hum,root=root} return true
end
local function arRagdolled()
    if not arChar.humanoid then return false end
    local s=arChar.humanoid:GetState()
    if s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown then return true end
    local t=lp:GetAttribute("RagdollEndTime")
    return t and (t-workspace:GetServerTimeNow())>0
end
local function arExit()
    if not arChar.humanoid or not arChar.root then return end
    pcall(function() lp:SetAttribute("RagdollEndTime",workspace:GetServerTimeNow()) end)
    for _,d in ipairs(arChar.character:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
            pcall(function() d:Destroy() end)
        end
    end
    if not arBoosting then arBoosting=true arChar.humanoid.WalkSpeed=400 end
    if arChar.humanoid.Health>0 then arChar.humanoid:ChangeState(Enum.HumanoidStateType.Running) end
    arChar.root.Anchored=false
end
local function arLoop()
    while arMode=="on" do
        task.wait()
        if arRagdolled() then arExit()
        elseif arBoosting and not arRagdolled() then
            arBoosting=false
            if arChar.humanoid then arChar.humanoid.WalkSpeed=16 end
        end
    end
end
local function startAR()
    if arMode=="on" then return end
    if not arCache() then return end
    arMode="on"
    table.insert(arConns,RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera
        if cam and arChar.humanoid then cam.CameraSubject=arChar.humanoid end
    end))
    table.insert(arConns,lp.CharacterAdded:Connect(function() arBoosting=false task.wait(0.5) arCache() end))
    task.spawn(arLoop)
end
task.spawn(function() task.wait(0.5) startAR() end)
lp.CharacterAdded:Connect(function() task.wait(0.3) if arMode~="on" then startAR() else arCache() end end)

-- ============ TIMER ESP (always running) ============
local espConn=nil local espInst={}
local function startTimerESP()
    if espConn then espConn:Disconnect() espConn=nil end
    for _,v in pairs(espInst) do pcall(function() if v.bb then v.bb:Destroy() end end) end
    espInst={}
    local plots=workspace:FindFirstChild("Plots")
    local function makeESP(plot,part)
        if espInst[plot.Name] then pcall(function() espInst[plot.Name].bb:Destroy() end) end
        local bb=Instance.new("BillboardGui") bb.Name="PhTimerESP" bb.Size=UDim2.fromOffset(70,28)
        bb.StudsOffset=Vector3.new(0,9,0) bb.AlwaysOnTop=true bb.Adornee=part bb.MaxDistance=1500 bb.Parent=plot
        local bg=Instance.new("Frame",bb) bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(5,12,22)
        bg.BackgroundTransparency=0.25 bg.BorderSizePixel=0
        Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)
        local sk=Instance.new("UIStroke",bg) sk.Color=Color3.fromRGB(100,0,200) sk.Thickness=1.5
        local lbl=Instance.new("TextLabel",bg) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
        lbl.Font=Enum.Font.GothamBold lbl.TextSize=13
        lbl.TextColor3=Color3.fromRGB(255,255,60)
        lbl.TextStrokeTransparency=0 lbl.TextStrokeColor3=Color3.new(0,0,0)
        espInst[plot.Name]={bb=bb,lbl=lbl}
    end
    espConn=RunService.RenderStepped:Connect(function()
        if not plots then plots=workspace:FindFirstChild("Plots") return end
        for _,plot in ipairs(plots:GetChildren()) do
            local pur=plot:FindFirstChild("Purchases")
            local pb=pur and pur:FindFirstChild("PlotBlock")
            local mp=pb and pb:FindFirstChild("Main")
            local tl=mp and mp:FindFirstChild("BillboardGui") and mp.BillboardGui:FindFirstChild("RemainingTime")
            if tl and mp then
                local e=espInst[plot.Name]
                if not e or not e.bb.Parent then makeESP(plot,mp) e=espInst[plot.Name] end
                if e and e.lbl then
                    e.lbl.Text=tl.Text
                    local m,s=tl.Text:match("(%d+):(%d+)")
                    if m and s then
                        local tot=tonumber(m)*60+tonumber(s)
                        e.lbl.TextColor3=tot<=30 and Color3.fromRGB(255,60,60) or tot<=60 and Color3.fromRGB(255,180,50) or Color3.fromRGB(255,255,60)
                    end
                end
            else
                local e=espInst[plot.Name]
                if e then pcall(function() e.bb:Destroy() end) espInst[plot.Name]=nil end
            end
        end
    end)
end
startTimerESP()

-- ============ INSTANT STEAL (background, 25 stud reach) ============
local isStealing=false local stealProgress=0
local allAnimals={} local promptCache={} local stealCache={}
local autoBlockEnabled=false local autoBlockTarget=nil

local function isMyPlot(n)
    local pl=workspace:FindFirstChild("Plots") if not pl then return false end
    local p=pl:FindFirstChild(n) if not p then return false end
    local sign=p:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase") if yb and yb:IsA("BillboardGui") then return yb.Enabled end end
    return false
end
local function scanPlots()
    local plots=workspace:FindFirstChild("Plots") if not plots then return end
    allAnimals={}
    for _,plot in ipairs(plots:GetChildren()) do
        if not isMyPlot(plot.Name) then
            local pods=plot:FindFirstChild("AnimalPodiums")
            if pods then
                for _,pod in ipairs(pods:GetChildren()) do
                    local base=pod:FindFirstChild("Base")
                    local spn=base and base:FindFirstChild("Spawn")
                    local att=spn and spn:FindFirstChild("PromptAttachment")
                    local wp=att and att.WorldPosition or pod:GetPivot().Position
                    table.insert(allAnimals,{plotName=plot.Name,slot=pod.Name,worldPos=wp,uid=plot.Name..pod.Name})
                end
            end
        end
    end
end
task.spawn(function() while task.wait(3) do scanPlots() end end)

local function findPrompt(a)
    if promptCache[a.uid] and promptCache[a.uid].Parent then return promptCache[a.uid] end
    local plots=workspace:FindFirstChild("Plots") if not plots then return nil end
    local plot=plots:FindFirstChild(a.plotName) if not plot then return nil end
    local pods=plot:FindFirstChild("AnimalPodiums") if not pods then return nil end
    local pod=pods:FindFirstChild(a.slot) if not pod then return nil end
    local base=pod:FindFirstChild("Base")
    local spn=base and base:FindFirstChild("Spawn")
    local att=spn and spn:FindFirstChild("PromptAttachment") if not att then return nil end
    for _,p in ipairs(att:GetChildren()) do
        if p:IsA("ProximityPrompt") then promptCache[a.uid]=p return p end
    end
end
local function buildCB(prompt)
    if stealCache[prompt] then return end
    local data={hold={},trigger={},ready=true}
    local ok1,c1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(c1)=="table" then for _,c in ipairs(c1) do if type(c.Function)=="function" then table.insert(data.hold,c.Function) end end end
    local ok2,c2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(c2)=="table" then for _,c in ipairs(c2) do if type(c.Function)=="function" then table.insert(data.trigger,c.Function) end end end
    if #data.hold>0 or #data.trigger>0 then stealCache[prompt]=data end
end

local function blockPromptAndClick(target)
    if not target then return end
    pcall(function() StarterGui:SetCore("PromptBlockPlayer",target) end)
    task.wait(0.3)
    local size=workspace.CurrentCamera.ViewportSize
    for i=1,8 do
        VIM:SendMouseButtonEvent(size.X/2,size.Y/2+80,0,true,game,1) task.wait(0.02)
        VIM:SendMouseButtonEvent(size.X/2,size.Y/2+80,0,false,game,1) task.wait(0.04)
    end
end

local function execSteal(prompt)
    local data=stealCache[prompt]
    if not data or not data.ready or isStealing then return end
    data.ready=false isStealing=true stealProgress=0
    if autoBlockEnabled and autoBlockTarget then
        task.spawn(function() task.wait(0.2) blockPromptAndClick(autoBlockTarget) end)
    end
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        local t0=tick() local dur=0.08
        while tick()-t0<dur do stealProgress=math.clamp((tick()-t0)/dur,0,1) task.wait() end
        stealProgress=1
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        pcall(function() fireproximityprompt(prompt,0) end)
        task.wait(0.1)
        data.ready=true isStealing=false stealProgress=0
    end)
end
RunService.Heartbeat:Connect(function()
    if isStealing then return end
    local hrp=getRoot() if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do
        local d=(hrp.Position-a.worldPos).Magnitude
        if d<bd then bd=d best=a end
    end
    if not best or bd>25 then return end
    local prompt=promptCache[best.uid]
    if not prompt or not prompt.Parent then prompt=findPrompt(best) end
    if not prompt then return end
    buildCB(prompt)
    if stealCache[prompt] then execSteal(prompt) end
end)

-- ============ PROGRESS BAR ============
local sg = Instance.new("ScreenGui")
sg.Name="PhantomAP" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=999 sg.Parent=game:GetService("CoreGui")

local grabBar=Instance.new("Frame",sg)
grabBar.Size=UDim2.fromOffset(140,16) grabBar.AnchorPoint=Vector2.new(0.5,0)
grabBar.Position=UDim2.new(0.5,0,0,6) grabBar.BackgroundColor3=Color3.fromRGB(12,10,22)
grabBar.BackgroundTransparency=0.1 grabBar.BorderSizePixel=0 grabBar.ZIndex=60
Instance.new("UICorner",grabBar).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",grabBar).Color=Color3.fromRGB(100,0,200)
local gFill=Instance.new("Frame",grabBar) gFill.Size=UDim2.new(0,0,1,0)
gFill.BackgroundColor3=Color3.fromRGB(160,0,255) gFill.BorderSizePixel=0
Instance.new("UICorner",gFill).CornerRadius=UDim.new(0,6)
local gTxt=Instance.new("TextLabel",grabBar) gTxt.Size=UDim2.new(1,0,1,0)
gTxt.BackgroundTransparency=1 gTxt.Text="GRAB" gTxt.Font=Enum.Font.GothamBold
gTxt.TextSize=8 gTxt.TextColor3=Color3.new(1,1,1) gTxt.ZIndex=61

RunService.Heartbeat:Connect(function()
    local hrp=getRoot() if not hrp then return end
    local best,bd=nil,math.huge
    for _,a in ipairs(allAnimals) do
        local d=(hrp.Position-a.worldPos).Magnitude if d<bd then bd=d best=a end
    end
    if isStealing then
        local p=math.clamp(stealProgress,0,1)
        TweenService:Create(gFill,TweenInfo.new(0.05),{Size=UDim2.new(p,0,1,0),BackgroundColor3=Color3.fromRGB(80,220,80)}):Play()
        gTxt.Text="STEALING!"
    elseif not best then
        TweenService:Create(gFill,TweenInfo.new(0.1),{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(80,80,100)}):Play()
        gTxt.Text="SEARCHING"
    elseif bd<=25 then
        TweenService:Create(gFill,TweenInfo.new(0.05),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(80,220,80)}):Play()
        gTxt.Text="IN RANGE"
    elseif bd<=60 then
        local pct=math.clamp(1-(bd-25)/35,0,1)
        TweenService:Create(gFill,TweenInfo.new(0.1),{Size=UDim2.new(pct,0,1,0),BackgroundColor3=Color3.fromRGB(160,0,255)}):Play()
        gTxt.Text=math.floor(bd).."m"
    else
        TweenService:Create(gFill,TweenInfo.new(0.1),{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(80,80,100)}):Play()
        gTxt.Text=math.floor(bd).."m"
    end
end)

-- ============ CARPET ============
local carpetActive=false local carpetConns={}
local function stopCarpet()
    for _,c in ipairs(carpetConns) do pcall(function() c:Disconnect() end) end carpetConns={}
end
local function startCarpet()
    stopCarpet()
    local hum=getHum() if not hum then return end
    local bp=lp:FindFirstChild("Backpack") if not bp then return end
    for _,t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and (t.Name:lower():find("carpet") or t.Name:lower():find("flying")) then hum:EquipTool(t) break end
    end
    table.insert(carpetConns,RunService.Heartbeat:Connect(function()
        if not carpetActive then stopCarpet() return end
        local hrp=getRoot() local hum2=getHum() if not hrp or not hum2 then return end
        local dir=hum2.MoveDirection
        if dir.Magnitude>0 then hrp.AssemblyLinearVelocity=Vector3.new(dir.X*120,hrp.AssemblyLinearVelocity.Y,dir.Z*120) end
    end))
    local net=ReplicatedStorage:FindFirstChild("Packages")
    if net then net=net:FindFirstChild("Net") end
    if net then net=net:FindFirstChild("RE/UseItem") end
    if net then
        table.insert(carpetConns,RunService.Heartbeat:Connect(function()
            if not carpetActive then return end
            pcall(function() net:FireServer(0.23450689315795897) end)
        end))
    end
end
lp.CharacterAdded:Connect(function() if carpetActive then task.wait(0.5) startCarpet() end end)

-- ============ INSTA RESET ============
local resetDebounce=false
local function doReset()
    if resetDebounce then return end resetDebounce=true
    local char=lp.Character if not char then resetDebounce=false return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health<=0 then resetDebounce=false return end
    Players.RespawnTime=0
    hum.Health=0
    hum:ChangeState(Enum.HumanoidStateType.Dead)
    char:BreakJoints()
    task.wait(0.03)
    pcall(function() lp:LoadCharacter() end)
    task.delay(0.5,function() resetDebounce=false end)
end
UIS.InputBegan:Connect(function(inp,gp) if not gp and inp.KeyCode==Enum.KeyCode.R then doReset() end end)

-- ============ BLOCK ============
local selectedBlockTarget=nil local selectedBtnRef=nil

-- ============ AP GUI (original, untouched) ============
_G.PhantomAPTarget = nil

local toggleBtn = Instance.new("TextButton", sg)
toggleBtn.Size = UDim2.fromOffset(32, 32)
toggleBtn.Position = UDim2.new(0, 8, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(12,10,22)
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.Text = "AP"
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 10
toggleBtn.TextColor3 = Color3.fromRGB(180,140,255)
toggleBtn.BorderSizePixel = 0
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)
local tStroke = Instance.new("UIStroke", toggleBtn)
tStroke.Color = Color3.fromRGB(100,0,200)
tStroke.Thickness = 1.5

local panel = Instance.new("Frame", sg)
panel.Size = UDim2.fromOffset(155, 10)
panel.Position = UDim2.new(0, 48, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(12,10,22)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Visible = false
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)
local pStroke = Instance.new("UIStroke", panel)
pStroke.Color = Color3.fromRGB(100,0,200)
pStroke.Thickness = 1.5

local pLayout = Instance.new("UIListLayout", panel)
pLayout.Padding = UDim.new(0,4)
pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
pLayout.SortOrder = Enum.SortOrder.LayoutOrder
local pPad = Instance.new("UIPadding", panel)
pPad.PaddingTop = UDim.new(0,6) pPad.PaddingBottom = UDim.new(0,8)
pPad.PaddingLeft = UDim.new(0,6) pPad.PaddingRight = UDim.new(0,6)

local hdr = Instance.new("TextLabel", panel)
hdr.Size = UDim2.new(1,0,0,18) hdr.BackgroundTransparency = 1
hdr.Text = "PHANTOM AP" hdr.Font = Enum.Font.GothamBlack
hdr.TextSize = 11 hdr.TextColor3 = Color3.fromRGB(180,140,255)
hdr.LayoutOrder = 0

local function mkDiv(order)
    local dv = Instance.new("Frame", panel)
    dv.Size = UDim2.new(1,0,0,1) dv.BackgroundColor3 = Color3.fromRGB(80,0,160)
    dv.BackgroundTransparency = 0.5 dv.BorderSizePixel = 0 dv.LayoutOrder = order
end
mkDiv(1)

local scrollContainer = Instance.new("Frame", panel)
scrollContainer.Size = UDim2.new(1,0,0,120) scrollContainer.BackgroundTransparency = 1
scrollContainer.LayoutOrder = 2 scrollContainer.ClipsDescendants = true

local scroll = Instance.new("ScrollingFrame", scrollContainer)
scroll.Size = UDim2.new(1,0,1,0) scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0 scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(120,0,220)
scroll.CanvasSize = UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local sLayout = Instance.new("UIListLayout", scroll)
sLayout.Padding = UDim.new(0,3) sLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function buildCards()
    for _,c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    _G.PhantomAPTarget = nil
    for i,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        local card = Instance.new("Frame", scroll)
        card.Size = UDim2.new(1,-2,0,38) card.BackgroundColor3 = Color3.fromRGB(20,15,35)
        card.BackgroundTransparency = 0.2 card.BorderSizePixel = 0 card.LayoutOrder = i
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)
        local cStroke = Instance.new("UIStroke", card)
        cStroke.Color = Color3.fromRGB(60,40,90) cStroke.Thickness = 1 cStroke.Transparency = 0.5
        local av = Instance.new("ImageLabel", card)
        av.Size = UDim2.fromOffset(28,28) av.Position = UDim2.new(0,4,0.5,-14)
        av.BackgroundColor3 = Color3.fromRGB(30,25,45) av.BorderSizePixel = 0
        av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
        Instance.new("UICorner", av).CornerRadius = UDim.new(1,0)
        local nl = Instance.new("TextLabel", card)
        nl.Size = UDim2.new(1,-38,0,16) nl.Position = UDim2.new(0,36,0,4)
        nl.BackgroundTransparency = 1 nl.Text = p.DisplayName
        nl.Font = Enum.Font.GothamBold nl.TextSize = 10 nl.TextColor3 = Color3.new(1,1,1)
        nl.TextXAlignment = Enum.TextXAlignment.Left nl.TextTruncate = Enum.TextTruncate.AtEnd
        local ul = Instance.new("TextLabel", card)
        ul.Size = UDim2.new(1,-38,0,12) ul.Position = UDim2.new(0,36,0,20)
        ul.BackgroundTransparency = 1 ul.Text = "@"..p.Name
        ul.Font = Enum.Font.Gotham ul.TextSize = 8 ul.TextColor3 = Color3.fromRGB(110,110,130)
        ul.TextXAlignment = Enum.TextXAlignment.Left ul.TextTruncate = Enum.TextTruncate.AtEnd
        local clickBtn = Instance.new("TextButton", card)
        clickBtn.Size = UDim2.new(1,0,1,0) clickBtn.BackgroundTransparency = 1
        clickBtn.Text = "" clickBtn.ZIndex = 5
        clickBtn.MouseButton1Click:Connect(function()
            _G.PhantomAPTarget = p
            for _,c2 in ipairs(scroll:GetChildren()) do
                if c2:IsA("Frame") then
                    c2.BackgroundColor3 = Color3.fromRGB(20,15,35) c2.BackgroundTransparency = 0.2
                    local st = c2:FindFirstChildOfClass("UIStroke")
                    if st then st.Color=Color3.fromRGB(60,40,90) st.Transparency=0.5 end
                end
            end
            card.BackgroundColor3 = Color3.fromRGB(50,0,100) card.BackgroundTransparency = 0.0
            cStroke.Color = Color3.fromRGB(160,0,255) cStroke.Transparency = 0
        end)
    end
end

mkDiv(3)

local selLbl = Instance.new("TextLabel", panel)
selLbl.Size = UDim2.new(1,0,0,12) selLbl.BackgroundTransparency = 1
selLbl.Text = "tap player to select" selLbl.Font = Enum.Font.Gotham
selLbl.TextSize = 8 selLbl.TextColor3 = Color3.fromRGB(120,120,140)
selLbl.LayoutOrder = 4

mkDiv(5)

local function getTarget()
    local target = _G.PhantomAPTarget
    if target and target.Parent then return target end
    local nearest,dist=nil,math.huge
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                if r then local dd=(r.Position-hrp.Position).Magnitude if dd<dist then dist=dd nearest=p end end
            end
        end
    end
    return nearest
end

local function mkCmd(text, order, cmds, jail)
    local btn = Instance.new("TextButton", panel)
    btn.Size = UDim2.new(1,0,0,26) btn.BackgroundColor3 = Color3.fromRGB(25,18,42)
    btn.BackgroundTransparency = 0.15 btn.Text = text
    btn.Font = Enum.Font.GothamBold btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(200,180,255) btn.BorderSizePixel = 0
    btn.AutoButtonColor = true btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    local st = Instance.new("UIStroke", btn)
    st.Color = Color3.fromRGB(100,0,200) st.Thickness = 1 st.Transparency = 0.4
    local busy = false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        local target = getTarget() if not target then return end
        busy = true btn.AutoButtonColor = false
        local orig = btn.Text btn.Text = "running..." btn.TextColor3 = Color3.fromRGB(255,255,255)
        runCmds(target, cmds, jail)
        task.delay(2, function()
            btn.Text = orig btn.TextColor3 = Color3.fromRGB(200,180,255)
            btn.AutoButtonColor = true busy = false
        end)
    end)
end

mkCmd("BALLOON", 6, {"balloon"}, false)
mkCmd("RAGDOLL", 7, {"ragdoll"}, false)
mkCmd("ALL", 8, {"rocket","inverse","tiny","jumpscare","morph","balloon"}, true)

-- ============ EXTRA BUTTONS (carpet + block + reset) ============
mkDiv(9)

-- CARPET button
local carpetBtn = Instance.new("TextButton", panel)
carpetBtn.Size = UDim2.new(1,0,0,26) carpetBtn.BackgroundColor3 = Color3.fromRGB(18,25,42)
carpetBtn.BackgroundTransparency = 0.15 carpetBtn.Text = "🚗 CARPET: OFF"
carpetBtn.Font = Enum.Font.GothamBold carpetBtn.TextSize = 10
carpetBtn.TextColor3 = Color3.fromRGB(150,200,255) carpetBtn.BorderSizePixel = 0
carpetBtn.AutoButtonColor = false carpetBtn.LayoutOrder = 10
Instance.new("UICorner", carpetBtn).CornerRadius = UDim.new(0,7)
local carpetStroke = Instance.new("UIStroke", carpetBtn)
carpetStroke.Color = Color3.fromRGB(0,100,200) carpetStroke.Thickness = 1 carpetStroke.Transparency = 0.4

carpetBtn.MouseButton1Click:Connect(function()
    carpetActive = not carpetActive
    if carpetActive then
        carpetBtn.Text = "🚗 CARPET: ON"
        carpetBtn.BackgroundColor3 = Color3.fromRGB(10,30,60)
        carpetBtn.TextColor3 = Color3.fromRGB(80,200,255)
        carpetStroke.Color = Color3.fromRGB(0,180,255) carpetStroke.Transparency = 0
        startCarpet()
    else
        carpetBtn.Text = "🚗 CARPET: OFF"
        carpetBtn.BackgroundColor3 = Color3.fromRGB(18,25,42)
        carpetBtn.TextColor3 = Color3.fromRGB(150,200,255)
        carpetStroke.Color = Color3.fromRGB(0,100,200) carpetStroke.Transparency = 0.4
        stopCarpet()
    end
end)

-- AUTO BLOCK toggle
local abBtn = Instance.new("TextButton", panel)
abBtn.Size = UDim2.new(1,0,0,26) abBtn.BackgroundColor3 = Color3.fromRGB(25,18,42)
abBtn.BackgroundTransparency = 0.15 abBtn.Text = "🚫 AUTO BLOCK: OFF"
abBtn.Font = Enum.Font.GothamBold abBtn.TextSize = 10
abBtn.TextColor3 = Color3.fromRGB(200,150,255) abBtn.BorderSizePixel = 0
abBtn.AutoButtonColor = false abBtn.LayoutOrder = 11
Instance.new("UICorner", abBtn).CornerRadius = UDim.new(0,7)
local abStroke = Instance.new("UIStroke", abBtn)
abStroke.Color = Color3.fromRGB(100,0,200) abStroke.Thickness = 1 abStroke.Transparency = 0.4

abBtn.MouseButton1Click:Connect(function()
    autoBlockEnabled = not autoBlockEnabled
    if autoBlockEnabled then
        -- auto set target to selected player or nearest
        if _G.PhantomAPTarget then autoBlockTarget = _G.PhantomAPTarget end
        abBtn.Text = "🚫 AUTO BLOCK: ON"
        abBtn.BackgroundColor3 = Color3.fromRGB(50,0,80)
        abBtn.TextColor3 = Color3.fromRGB(220,100,255)
        abStroke.Color = Color3.fromRGB(200,0,255) abStroke.Transparency = 0
    else
        abBtn.Text = "🚫 AUTO BLOCK: OFF"
        abBtn.BackgroundColor3 = Color3.fromRGB(25,18,42)
        abBtn.TextColor3 = Color3.fromRGB(200,150,255)
        abStroke.Color = Color3.fromRGB(100,0,200) abStroke.Transparency = 0.4
    end
end)

-- INSTANT RESET button
local resetBtn = Instance.new("TextButton", panel)
resetBtn.Size = UDim2.new(1,0,0,26) resetBtn.BackgroundColor3 = Color3.fromRGB(40,12,12)
resetBtn.BackgroundTransparency = 0.15 resetBtn.Text = "💀 INSTA RESET  [R]"
resetBtn.Font = Enum.Font.GothamBold resetBtn.TextSize = 10
resetBtn.TextColor3 = Color3.fromRGB(255,120,120) resetBtn.BorderSizePixel = 0
resetBtn.AutoButtonColor = false resetBtn.LayoutOrder = 12
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,7)
local resetStroke = Instance.new("UIStroke", resetBtn)
resetStroke.Color = Color3.fromRGB(180,0,0) resetStroke.Thickness = 1 resetStroke.Transparency = 0.3

resetBtn.MouseButton1Click:Connect(function()
    resetBtn.Text = "resetting..."
    resetBtn.TextColor3 = Color3.fromRGB(255,200,80)
    doReset()
    task.delay(0.8, function()
        if resetBtn.Parent then
            resetBtn.Text = "💀 INSTA RESET  [R]"
            resetBtn.TextColor3 = Color3.fromRGB(255,120,120)
        end
    end)
end)

-- ============ TOGGLE OPEN/CLOSE ============
local panelOpen = false
local moved = false
local inputStart = nil

local td,tds,tsp=false,nil,nil
toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        td=true tds=i.Position tsp=toggleBtn.Position
        moved=false inputStart=i.Position
    end
end)
toggleBtn.InputChanged:Connect(function(i)
    if td and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
        local dl=i.Position-tds
        toggleBtn.Position=UDim2.new(tsp.X.Scale,tsp.X.Offset+dl.X,tsp.Y.Scale,tsp.Y.Offset+dl.Y)
        panel.Position=UDim2.new(
            toggleBtn.Position.X.Scale, toggleBtn.Position.X.Offset+40,
            toggleBtn.Position.Y.Scale, toggleBtn.Position.Y.Offset
        )
        if inputStart and (i.Position-inputStart).Magnitude>6 then moved=true end
    end
end)
toggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then td=false end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if moved then return end
    panelOpen = not panelOpen
    panel.Visible = panelOpen
    toggleBtn.TextColor3 = panelOpen and Color3.fromRGB(160,0,255) or Color3.fromRGB(180,140,255)
    tStroke.Color = panelOpen and Color3.fromRGB(160,0,255) or Color3.fromRGB(100,0,200)
    if panelOpen then buildCards() end
    -- sync auto block target when opening
    if panelOpen and _G.PhantomAPTarget then autoBlockTarget = _G.PhantomAPTarget end
end)

Players.PlayerAdded:Connect(function() if panelOpen then buildCards() end end)
Players.PlayerRemoving:Connect(function(p)
    if _G.PhantomAPTarget==p then _G.PhantomAPTarget=nil end
    if autoBlockTarget==p then autoBlockTarget=nil end
    if panelOpen then buildCards() end
end)

-- sync autoBlockTarget when player is selected
task.spawn(function()
    while task.wait(0.5) do
        if not sg.Parent then break end
        local t = _G.PhantomAPTarget
        if t and t.Parent then
            selLbl.Text = t.DisplayName
            selLbl.TextColor3 = Color3.fromRGB(160,0,255)
            if autoBlockEnabled then autoBlockTarget = t end
        else
            selLbl.Text = "tap player to select"
            selLbl.TextColor3 = Color3.fromRGB(120,120,140)
        end
    end
end)
