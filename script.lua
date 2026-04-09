task.spawn(function()
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local s = isMobile and 0.65 or 1

local function waitForCharacter()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then return char end
    return Player.CharacterAdded:Wait()
end
task.spawn(function() waitForCharacter() end)
if not getgenv then getgenv = function() return _G end end

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

local ConfigFileName = "Zyphrot_Hub_Config_V3.json"
local Enabled = {
    SpeedBoost=false,AntiRagdoll=false,SpinBot=false,SpeedWhileStealing=false,AutoSteal=false,
    Unwalk=false,Optimizer=false,Galaxy=false,SpamBat=false,BatAimbot=false,GalaxySkyBright=false,
    AutoWalkEnabled=false,AutoRightEnabled=false,AutoPlayLeftEnabled=false,AutoPlayRightEnabled=false,
    InfJump=false,ESP=false,Hover=false,Stats=false,SpeedMeter=false
}
local Values = {
    BoostSpeed=30,SpinSpeed=30,StealingSpeedValue=29,STEAL_RADIUS=20,STEAL_DURATION=1.3,
    AutoLeftSpeed=59.5,AutoRightSpeed=59.5,AutoWalkReturnSpeed=30,AutoPlayReturnSpeed=30,
    AutoWalkWaitTime=1.0,AutoPlayWaitTime=1.0,AutoPlayExitDist=6.0,DEFAULT_GRAVITY=196.2,
    GalaxyGravityPercent=70,HOP_POWER=35,HOP_COOLDOWN=0.08,FOV=105.8,HoverHeight=15
}
local KEYBINDS = {
    SPEED=Enum.KeyCode.V,SPIN=Enum.KeyCode.N,GALAXY=Enum.KeyCode.M,BATAIMBOT=Enum.KeyCode.X,
    NUKE=Enum.KeyCode.Q,AUTOLEFT=Enum.KeyCode.Z,AUTORIGHT=Enum.KeyCode.C,
    AUTOPLAYLEFT=Enum.KeyCode.F10,AUTOPLAYRIGHT=Enum.KeyCode.F11,ANTIRAGDOLL=Enum.KeyCode.F1,
    SPEEDSTEAL=Enum.KeyCode.F2,AUTOSTEAL=Enum.KeyCode.F3,UNWALK=Enum.KeyCode.F4,
    OPTIMIZER=Enum.KeyCode.F5,SPAMBAT=Enum.KeyCode.F6,GALAXY_SKY=Enum.KeyCode.F7,
    INFJUMP=Enum.KeyCode.F8,ESP=Enum.KeyCode.P,HOVER=Enum.KeyCode.G,STATS=Enum.KeyCode.F9,
    SPEEDMETER=Enum.KeyCode.J
}

pcall(function()
    if readfile and isfile and isfile(ConfigFileName) then
        local data = HttpService:JSONDecode(readfile(ConfigFileName))
        if data then
            for k,v in pairs(data) do if Enabled[k]~=nil then Enabled[k]=v end end
            for k,v in pairs(data) do if Values[k]~=nil then Values[k]=v end end
            local keys={"SPEED","SPIN","GALAXY","BATAIMBOT","AUTOLEFT","AUTORIGHT","AUTOPLAYLEFT","AUTOPLAYRIGHT","ANTIRAGDOLL","SPEEDSTEAL","AUTOSTEAL","UNWALK","OPTIMIZER","SPAMBAT","GALAXY_SKY","INFJUMP","ESP","HOVER","STATS","SPEEDMETER"}
            for _,k in ipairs(keys) do if data["KEY_"..k] then KEYBINDS[k]=Enum.KeyCode[data["KEY_"..k]] end end
        end
    end
end)

local function SaveConfig()
    local data = {}
    for k,v in pairs(Enabled) do data[k]=v end
    for k,v in pairs(Values) do data[k]=v end
    local keys={"SPEED","SPIN","GALAXY","BATAIMBOT","AUTOLEFT","AUTORIGHT","AUTOPLAYLEFT","AUTOPLAYRIGHT","ANTIRAGDOLL","SPEEDSTEAL","AUTOSTEAL","UNWALK","OPTIMIZER","SPAMBAT","GALAXY_SKY","INFJUMP","ESP","HOVER","STATS","SPEEDMETER"}
    for _,k in ipairs(keys) do data["KEY_"..k]=KEYBINDS[k].Name end
    local success=false
    if writefile then pcall(function() writefile(ConfigFileName,HttpService:JSONEncode(data)) success=true end) end
    return success
end

-- ============ BACKEND ============
local Connections={} local isStealing=false local lastBatSwing=0 local BAT_SWING_COOLDOWN=0.12
local SlapList={{"Bat"},{"Slap"},{"Iron Slap"},{"Gold Slap"},{"Diamond Slap"},{"Emerald Slap"},{"Ruby Slap"},{"Dark Matter Slap"},{"Flame Slap"},{"Nuclear Slap"},{"Galaxy Slap"},{"Glitched Slap"}}
local ADMIN_KEY="78a772b6-9e1c-4827-ab8b-04a07838f298"
local REMOTE_EVENT_ID="352aad58-c786-4998-886b-3e4fa390721e"
local BALLOON_REMOTE=ReplicatedStorage:FindFirstChild(REMOTE_EVENT_ID,true)

local function INSTANT_NUKE(target)
    if not BALLOON_REMOTE or not target then return end
    for _,p in ipairs({"balloon","ragdoll","jumpscare","morph","tiny","rocket","inverse","jail"}) do BALLOON_REMOTE:FireServer(ADMIN_KEY,target,p) end
end
local function getNearestPlayer()
    local c=Player.Character if not c then return nil end
    local h=c:FindFirstChild("HumanoidRootPart") if not h then return nil end
    local nearest,dist=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=Player and p.Character then
            local oh=p.Character:FindFirstChild("HumanoidRootPart")
            if oh then local d=(h.Position-oh.Position).Magnitude if d<dist then dist=d nearest=p end end
        end
    end
    return nearest
end
local function findBat()
    local c=Player.Character if not c then return nil end
    local bp=Player:FindFirstChildOfClass("Backpack")
    for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    for _,i in ipairs(SlapList) do local t=c:FindFirstChild(i[1]) or (bp and bp:FindFirstChild(i[1])) if t then return t end end
    return nil
end
local function startSpamBat()
    if Connections.spamBat then return end
    Connections.spamBat=RunService.Heartbeat:Connect(function()
        if not Enabled.SpamBat then return end
        local c=Player.Character if not c then return end
        local bat=findBat() if not bat then return end
        if bat.Parent~=c then bat.Parent=c end
        local now=tick() if now-lastBatSwing<BAT_SWING_COOLDOWN then return end
        lastBatSwing=now pcall(function() bat:Activate() end)
    end)
end
local function stopSpamBat() if Connections.spamBat then Connections.spamBat:Disconnect() Connections.spamBat=nil end end

local spinBAV=nil
local function startSpinBot()
    local c=Player.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    if spinBAV then spinBAV:Destroy() spinBAV=nil end
    for _,v in pairs(hrp:GetChildren()) do if v.Name=="SpinBAV" then v:Destroy() end end
    spinBAV=Instance.new("BodyAngularVelocity") spinBAV.Name="SpinBAV"
    spinBAV.MaxTorque=Vector3.new(0,math.huge,0) spinBAV.AngularVelocity=Vector3.new(0,Values.SpinSpeed,0) spinBAV.Parent=hrp
end
local function stopSpinBot()
    if spinBAV then spinBAV:Destroy() spinBAV=nil end
    local c=Player.Character if c then local hrp=c:FindFirstChild("HumanoidRootPart") if hrp then for _,v in pairs(hrp:GetChildren()) do if v.Name=="SpinBAV" then v:Destroy() end end end end
end
RunService.Heartbeat:Connect(function()
    if Enabled.SpinBot and spinBAV then
        spinBAV.AngularVelocity=Player:GetAttribute("Stealing") and Vector3.new(0,0,0) or Vector3.new(0,Values.SpinSpeed,0)
    end
end)

local speedMeterConnection=nil local speedMeterGui=nil
local function toggleSpeedMeter(state)
    if speedMeterConnection then speedMeterConnection:Disconnect() speedMeterConnection=nil end
    if speedMeterGui then speedMeterGui:Destroy() speedMeterGui=nil end
    if state then
        local char=Player.Character if not char then return end
        local head=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") if not head then return end
        speedMeterGui=Instance.new("BillboardGui") speedMeterGui.Adornee=head speedMeterGui.Size=UDim2.new(0,150,0,40)
        speedMeterGui.StudsOffset=Vector3.new(0,3.5,0) speedMeterGui.AlwaysOnTop=true
        local tl=Instance.new("TextLabel",speedMeterGui) tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1
        tl.TextColor3=Color3.new(1,1,1) tl.TextStrokeTransparency=0 tl.TextStrokeColor3=Color3.new(0,0,0) tl.Font=Enum.Font.GothamBold tl.TextSize=16*s
        local ok,_=pcall(function() speedMeterGui.Parent=CoreGui end) if not ok then speedMeterGui.Parent=Player:WaitForChild("PlayerGui") end
        speedMeterConnection=RunService.Heartbeat:Connect(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp=Player.Character.HumanoidRootPart
            if speedMeterGui and tl then tl.Text="Speed: "..tostring(math.round(Vector3.new(hrp.AssemblyLinearVelocity.X,0,hrp.AssemblyLinearVelocity.Z).Magnitude)) end
        end)
    end
end

local aimbotConnection=nil local lockedTarget=nil
local AIMBOT_SPEED=60 local MELEE_OFFSET=3
local aimbotHighlight=Instance.new("Highlight") aimbotHighlight.FillColor=Color3.fromRGB(255,0,0)
aimbotHighlight.OutlineColor=Color3.fromRGB(255,255,255) aimbotHighlight.FillTransparency=0.5
pcall(function() aimbotHighlight.Parent=CoreGui end)

local function isTargetValid(tc)
    if not tc then return false end
    local hum=tc:FindFirstChildOfClass("Humanoid") local hrp=tc:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health>0 and not tc:FindFirstChildOfClass("ForceField")
end
local function getBestTarget(myHRP)
    if lockedTarget and isTargetValid(lockedTarget) then return lockedTarget:FindFirstChild("HumanoidRootPart"),lockedTarget end
    local sd=math.huge local ntc,nthrp=nil,nil
    for _,tp in ipairs(Players:GetPlayers()) do
        if tp~=Player and isTargetValid(tp.Character) then
            local thrp=tp.Character:FindFirstChild("HumanoidRootPart")
            local dist=(thrp.Position-myHRP.Position).Magnitude
            if dist<sd then sd=dist nthrp=thrp ntc=tp.Character end
        end
    end
    lockedTarget=ntc return nthrp,ntc
end
local function startBatAimbot()
    if aimbotConnection then return end
    local c=Player.Character if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart") local hum=c:FindFirstChildOfClass("Humanoid") if not h or not hum then return end
    hum.AutoRotate=false
    local att=h:FindFirstChild("AimbotAttachment") or Instance.new("Attachment",h) att.Name="AimbotAttachment"
    local align=h:FindFirstChild("AimbotAlign") or Instance.new("AlignOrientation",h)
    align.Name="AimbotAlign" align.Mode=Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0=att align.MaxTorque=math.huge align.Responsiveness=200
    aimbotConnection=RunService.Heartbeat:Connect(function()
        if not Enabled.BatAimbot then return end
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        local currHRP=Player.Character.HumanoidRootPart local currHum=Player.Character:FindFirstChildOfClass("Humanoid")
        local bat=findBat() if bat and bat.Parent~=Player.Character then currHum:EquipTool(bat) end
        local tHRP,tChar=getBestTarget(currHRP)
        if tHRP and tChar then
            aimbotHighlight.Adornee=tChar
            local tv=tHRP.AssemblyLinearVelocity local dpt=math.clamp(tv.Magnitude/150,0.05,0.2)
            local pp=tHRP.Position+(tv*dpt) local dir=(pp-currHRP.Position) local dist3=dir.Magnitude
            local tsp=dist3>0 and pp-(dir.Unit*MELEE_OFFSET) or pp
            align.CFrame=CFrame.lookAt(currHRP.Position,pp)
            local md=(tsp-currHRP.Position) local dts=md.Magnitude
            if dts>1 then currHRP.AssemblyLinearVelocity=md.Unit*AIMBOT_SPEED else currHRP.AssemblyLinearVelocity=tv end
        else lockedTarget=nil currHRP.AssemblyLinearVelocity=Vector3.new(0,0,0) aimbotHighlight.Adornee=nil end
    end)
end
local function stopBatAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection=nil end
    local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") local hum=c and c:FindFirstChildOfClass("Humanoid")
    if h then
        local att=h:FindFirstChild("AimbotAttachment") if att then att:Destroy() end
        local align=h:FindFirstChild("AimbotAlign") if align then align:Destroy() end
        h.AssemblyLinearVelocity=Vector3.new(0,0,0)
    end
    if hum then hum.AutoRotate=true end
    lockedTarget=nil aimbotHighlight.Adornee=nil
end

local galaxyVectorForce,galaxyAttachment,galaxyEnabled,hopsEnabled=nil,nil,false,false
local lastHopTime,spaceHeld,originalJumpPower=0,false,50
local function captureJumpPower()
    local c=Player.Character if c then local hum=c:FindFirstChildOfClass("Humanoid") if hum and hum.JumpPower>0 then originalJumpPower=hum.JumpPower end end
end
task.spawn(function() task.wait(1) captureJumpPower() end)
Player.CharacterAdded:Connect(function() task.wait(1) captureJumpPower() end)
local function setupGalaxyForce()
    pcall(function()
        local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") if not h then return end
        if galaxyVectorForce then galaxyVectorForce:Destroy() end if galaxyAttachment then galaxyAttachment:Destroy() end
        galaxyAttachment=Instance.new("Attachment",h) galaxyVectorForce=Instance.new("VectorForce",h)
        galaxyVectorForce.Attachment0=galaxyAttachment galaxyVectorForce.ApplyAtCenterOfMass=true
        galaxyVectorForce.RelativeTo=Enum.ActuatorRelativeTo.World galaxyVectorForce.Force=Vector3.new(0,0,0)
    end)
end
local function updateGalaxyForce()
    if not galaxyEnabled or not galaxyVectorForce then return end
    local c=Player.Character if not c then return end
    local mass=0 for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass=mass+p:GetMass() end end
    local tg=Values.DEFAULT_GRAVITY*(Values.GalaxyGravityPercent/100)
    galaxyVectorForce.Force=Vector3.new(0,mass*(Values.DEFAULT_GRAVITY-tg)*0.95,0)
end
local function adjustGalaxyJump()
    pcall(function()
        local c=Player.Character local hum=c and c:FindFirstChildOfClass("Humanoid") if not hum then return end
        if not galaxyEnabled then hum.JumpPower=originalJumpPower return end
        local ratio=math.sqrt((Values.DEFAULT_GRAVITY*(Values.GalaxyGravityPercent/100))/Values.DEFAULT_GRAVITY)
        hum.JumpPower=originalJumpPower*ratio
    end)
end
local function doMiniHop()
    if not hopsEnabled then return end
    pcall(function()
        local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") local hum=c and c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if tick()-lastHopTime<Values.HOP_COOLDOWN then return end
        lastHopTime=tick()
        if hum.FloorMaterial==Enum.Material.Air then h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,Values.HOP_POWER,h.AssemblyLinearVelocity.Z) end
    end)
end
local function startGalaxy() galaxyEnabled=true hopsEnabled=true setupGalaxyForce() adjustGalaxyJump() end
local function stopGalaxy()
    galaxyEnabled=false hopsEnabled=false
    if galaxyVectorForce then galaxyVectorForce:Destroy() galaxyVectorForce=nil end
    if galaxyAttachment then galaxyAttachment:Destroy() galaxyAttachment=nil end
    adjustGalaxyJump()
end
RunService.Heartbeat:Connect(function() if hopsEnabled and spaceHeld then doMiniHop() end if galaxyEnabled then updateGalaxyForce() end end)

local function getMovementDirection()
    local c=Player.Character local hum=c and c:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end
local function startSpeedBoost()
    if Connections.speed then return end
    Connections.speed=RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedBoost then return end
        pcall(function()
            local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") if not h then return end
            local md=getMovementDirection()
            if md.Magnitude>0.1 then h.AssemblyLinearVelocity=Vector3.new(md.X*Values.BoostSpeed,h.AssemblyLinearVelocity.Y,md.Z*Values.BoostSpeed) end
        end)
    end)
end
local function stopSpeedBoost() if Connections.speed then Connections.speed:Disconnect() Connections.speed=nil end end

local hoverTargetY=0
local function ToggleHover(state)
    local char=Player.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if state and hrp then hoverTargetY=hrp.Position.Y+Values.HoverHeight
    else if hrp then hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,-10,hrp.AssemblyLinearVelocity.Z) end end
end
RunService.Heartbeat:Connect(function()
    if Enabled.Hover then
        local char=Player.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local err=hoverTargetY-hrp.Position.Y
            hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,math.clamp(err*10,-50,50),hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

local POSITION_1=Vector3.new(-476.48,-6.28,92.73) local POSITION_2=Vector3.new(-483.12,-4.95,94.80)
local POSITION_R1=Vector3.new(-476.16,-6.52,25.62) local POSITION_R2=Vector3.new(-483.04,-5.09,23.14)
local dirL=(Vector3.new(POSITION_1.X,0,POSITION_1.Z)-Vector3.new(POSITION_2.X,0,POSITION_2.Z)).Unit
local dirR=(Vector3.new(POSITION_R1.X,0,POSITION_R1.Z)-Vector3.new(POSITION_R2.X,0,POSITION_R2.Z)).Unit
local function GET_POS_1_OUT() return POSITION_1+(dirL*Values.AutoPlayExitDist) end
local function GET_POS_R1_OUT() return POSITION_R1+(dirR*Values.AutoPlayExitDist) end

local coordESPFolder=Instance.new("Folder",workspace) coordESPFolder.Name="Zyphrot_CoordESP"
local function createCoordMarker(position,labelText,color)
    local dot=Instance.new("Part",coordESPFolder) dot.Anchored=true dot.CanCollide=false dot.CastShadow=false
    dot.Material=Enum.Material.Neon dot.Color=color dot.Shape=Enum.PartType.Ball dot.Size=Vector3.new(1,1,1) dot.Position=position dot.Transparency=0.2
    local bb=Instance.new("BillboardGui",dot) bb.AlwaysOnTop=true bb.Size=UDim2.new(0,100,0,20) bb.StudsOffset=Vector3.new(0,2,0)
    local text=Instance.new("TextLabel",bb) text.Size=UDim2.new(1,0,1,0) text.BackgroundTransparency=1 text.Text=labelText text.TextColor3=color text.Font=Enum.Font.GothamBold text.TextSize=12
end
createCoordMarker(POSITION_1,"L1",Color3.fromRGB(255,100,100)) createCoordMarker(POSITION_2,"L END",Color3.fromRGB(220,20,60))
createCoordMarker(POSITION_R1,"R1",Color3.fromRGB(255,150,50)) createCoordMarker(POSITION_R2,"R END",Color3.fromRGB(220,100,30))

local AutoWalkEnabled,AutoRightEnabled=false,false local AutoPlayLeftEnabled,AutoPlayRightEnabled=false,false
local autoWalkConnection,autoRightConnection=nil,nil local autoPlayLeftConnection,autoPlayRightConnection=nil,nil
local autoWalkPhase,autoRightPhase=1,1 local autoPlayLeftPhase,autoPlayRightPhase=1,1

local function faceCam(angleY)
    local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") if not h then return end
    local camera=workspace.CurrentCamera if not camera then return end
    if angleY==0 then camera.CFrame=CFrame.new(h.Position.X,h.Position.Y+5,h.Position.Z-12)*CFrame.Angles(math.rad(-15),0,0)
    else camera.CFrame=CFrame.new(h.Position.X,h.Position.Y+2,h.Position.Z+12)*CFrame.Angles(0,math.rad(180),0) end
end

local function makeAutoWalkOri(h)
    local wo=h:FindFirstChild("AutoWalkOri") if wo then return wo end
    local wa=Instance.new("Attachment",h) wa.Name="AutoWalkAtt"
    wo=Instance.new("AlignOrientation",h) wo.Name="AutoWalkOri"
    wo.Mode=Enum.OrientationAlignmentMode.OneAttachment wo.Attachment0=wa wo.MaxTorque=math.huge wo.Responsiveness=200
    return wo
end
local function cleanAutoWalkOri(h)
    local wo=h:FindFirstChild("AutoWalkOri") local wa=h:FindFirstChild("AutoWalkAtt")
    if wo then wo:Destroy() end if wa then wa:Destroy() end
end

local autoPlayLeftWait=false local autoPlayLeftWaitStart=0
local function startAutoPlayLeft()
    if autoPlayLeftConnection then autoPlayLeftConnection:Disconnect() end
    autoPlayLeftPhase=1 autoPlayLeftWait=false
    local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") if h then makeAutoWalkOri(h) end
    local sequence={GET_POS_1_OUT,POSITION_1,POSITION_2,POSITION_1,GET_POS_1_OUT,GET_POS_R1_OUT,POSITION_R1,POSITION_R2}
    autoPlayLeftConnection=RunService.Heartbeat:Connect(function()
        if not AutoPlayLeftEnabled then return end
        local char=Player.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local wo=hrp:FindFirstChild("AutoWalkOri")
        if autoPlayLeftWait then
            hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0)
            if tick()-autoPlayLeftWaitStart>=Values.AutoPlayWaitTime then autoPlayLeftWait=false autoPlayLeftPhase=autoPlayLeftPhase+1 end
            return
        end
        if autoPlayLeftPhase<=#sequence then
            local tp=sequence[autoPlayLeftPhase] if type(tp)=="function" then tp=tp() end
            local dist=(Vector3.new(tp.X,hrp.Position.Y,tp.Z)-hrp.Position).Magnitude
            if dist<1 then
                hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0)
                if autoPlayLeftPhase==3 then autoPlayLeftWait=true autoPlayLeftWaitStart=tick() else autoPlayLeftPhase=autoPlayLeftPhase+1 end
            else
                local fd=Vector3.new(tp.X-hrp.Position.X,0,tp.Z-hrp.Position.Z).Unit
                if wo then wo.CFrame=CFrame.lookAt(hrp.Position,Vector3.new(tp.X,hrp.Position.Y,tp.Z)) end
                local sp=(autoPlayLeftPhase>=4) and Values.AutoPlayReturnSpeed or Values.AutoLeftSpeed
                hrp.AssemblyLinearVelocity=Vector3.new(fd.X*sp,hrp.AssemblyLinearVelocity.Y,fd.Z*sp)
            end
        else
            hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0)
            AutoPlayLeftEnabled,Enabled.AutoPlayLeftEnabled=false,false
            if VisualSetters and VisualSetters.AutoPlayLeftEnabled then VisualSetters.AutoPlayLeftEnabled(false) end
            if autoPlayLeftConnection then autoPlayLeftConnection:Disconnect() autoPlayLeftConnection=nil end
            cleanAutoWalkOri(hrp) faceCam(0)
        end
    end)
end
local function stopAutoPlayLeft()
    if autoPlayLeftConnection then autoPlayLeftConnection:Disconnect() autoPlayLeftConnection=nil end
    local h=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) cleanAutoWalkOri(h) end
end

local autoPlayRightWait=false local autoPlayRightWaitStart=0
local function startAutoPlayRight()
    if autoPlayRightConnection then autoPlayRightConnection:Disconnect() end
    autoPlayRightPhase=1 autoPlayRightWait=false
    local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") if h then makeAutoWalkOri(h) end
    local sequence={GET_POS_R1_OUT,POSITION_R1,POSITION_R2,POSITION_R1,GET_POS_R1_OUT,GET_POS_1_OUT,POSITION_1,POSITION_2}
    autoPlayRightConnection=RunService.Heartbeat:Connect(function()
        if not AutoPlayRightEnabled then return end
        local char=Player.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local wo=hrp:FindFirstChild("AutoWalkOri")
        if autoPlayRightWait then
            hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0)
            if tick()-autoPlayRightWaitStart>=Values.AutoPlayWaitTime then autoPlayRightWait=false autoPlayRightPhase=autoPlayRightPhase+1 end
            return
        end
        if autoPlayRightPhase<=#sequence then
            local tp=sequence[autoPlayRightPhase] if type(tp)=="function" then tp=tp() end
            local dist=(Vector3.new(tp.X,hrp.Position.Y,tp.Z)-hrp.Position).Magnitude
            if dist<1 then
                hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0)
                if autoPlayRightPhase==3 then autoPlayRightWait=true autoPlayRightWaitStart=tick() else autoPlayRightPhase=autoPlayRightPhase+1 end
            else
                local fd=Vector3.new(tp.X-hrp.Position.X,0,tp.Z-hrp.Position.Z).Unit
                if wo then wo.CFrame=CFrame.lookAt(hrp.Position,Vector3.new(tp.X,hrp.Position.Y,tp.Z)) end
                local sp=(autoPlayRightPhase>=4) and Values.AutoPlayReturnSpeed or Values.AutoRightSpeed
                hrp.AssemblyLinearVelocity=Vector3.new(fd.X*sp,hrp.AssemblyLinearVelocity.Y,fd.Z*sp)
            end
        else
            hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0)
            AutoPlayRightEnabled,Enabled.AutoPlayRightEnabled=false,false
            if VisualSetters and VisualSetters.AutoPlayRightEnabled then VisualSetters.AutoPlayRightEnabled(false) end
            if autoPlayRightConnection then autoPlayRightConnection:Disconnect() autoPlayRightConnection=nil end
            cleanAutoWalkOri(hrp) faceCam(math.rad(180))
        end
    end)
end
local function stopAutoPlayRight()
    if autoPlayRightConnection then autoPlayRightConnection:Disconnect() autoPlayRightConnection=nil end
    local h=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) cleanAutoWalkOri(h) end
end

local function startAutoWalk()
    if autoWalkConnection then autoWalkConnection:Disconnect() end
    autoWalkPhase=1 local waitStartTime=0
    local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") if h then makeAutoWalkOri(h) end
    autoWalkConnection=RunService.Heartbeat:Connect(function()
        if not AutoWalkEnabled then return end
        local c2=Player.Character local h2=c2 and c2:FindFirstChild("HumanoidRootPart") if not h2 then return end
        local wo=h2:FindFirstChild("AutoWalkOri")
        local function moveTo(pos,spd)
            local dist=(Vector3.new(pos.X,h2.Position.Y,pos.Z)-h2.Position).Magnitude
            if dist<1 then return true end
            local fd=Vector3.new(pos.X-h2.Position.X,0,pos.Z-h2.Position.Z).Unit
            if wo then wo.CFrame=CFrame.lookAt(h2.Position,Vector3.new(pos.X,h2.Position.Y,pos.Z)) end
            h2.AssemblyLinearVelocity=Vector3.new(fd.X*spd,h2.AssemblyLinearVelocity.Y,fd.Z*spd) return false
        end
        if autoWalkPhase==1 then if moveTo(POSITION_1,Values.AutoLeftSpeed) then autoWalkPhase=2 end
        elseif autoWalkPhase==2 then if moveTo(POSITION_2,Values.AutoLeftSpeed) then waitStartTime=tick() autoWalkPhase=3 h2.AssemblyLinearVelocity=Vector3.new(0,h2.AssemblyLinearVelocity.Y,0) end
        elseif autoWalkPhase==3 then h2.AssemblyLinearVelocity=Vector3.new(0,h2.AssemblyLinearVelocity.Y,0) if tick()-waitStartTime>=Values.AutoWalkWaitTime then autoWalkPhase=4 end
        elseif autoWalkPhase==4 then if moveTo(POSITION_1,Values.AutoWalkReturnSpeed) then autoWalkPhase=5 end
        elseif autoWalkPhase==5 then
            h2.AssemblyLinearVelocity=Vector3.new(0,h2.AssemblyLinearVelocity.Y,0)
            AutoWalkEnabled,Enabled.AutoWalkEnabled=false,false
            if VisualSetters and VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(false) end
            if autoWalkConnection then autoWalkConnection:Disconnect() autoWalkConnection=nil end
            cleanAutoWalkOri(h2) faceCam(0)
        end
    end)
end
local function stopAutoWalk()
    if autoWalkConnection then autoWalkConnection:Disconnect() autoWalkConnection=nil end
    local h=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) cleanAutoWalkOri(h) end
end

local function startAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() end
    autoRightPhase=1 local waitStartTime=0
    local c=Player.Character local h=c and c:FindFirstChild("HumanoidRootPart") if h then makeAutoWalkOri(h) end
    autoRightConnection=RunService.Heartbeat:Connect(function()
        if not AutoRightEnabled then return end
        local c2=Player.Character local h2=c2 and c2:FindFirstChild("HumanoidRootPart") if not h2 then return end
        local wo=h2:FindFirstChild("AutoWalkOri")
        local function moveTo(pos,spd)
            local dist=(Vector3.new(pos.X,h2.Position.Y,pos.Z)-h2.Position).Magnitude
            if dist<1 then return true end
            local fd=Vector3.new(pos.X-h2.Position.X,0,pos.Z-h2.Position.Z).Unit
            if wo then wo.CFrame=CFrame.lookAt(h2.Position,Vector3.new(pos.X,h2.Position.Y,pos.Z)) end
            h2.AssemblyLinearVelocity=Vector3.new(fd.X*spd,h2.AssemblyLinearVelocity.Y,fd.Z*spd) return false
        end
        if autoRightPhase==1 then if moveTo(POSITION_R1,Values.AutoRightSpeed) then autoRightPhase=2 end
        elseif autoRightPhase==2 then if moveTo(POSITION_R2,Values.AutoRightSpeed) then waitStartTime=tick() autoRightPhase=3 h2.AssemblyLinearVelocity=Vector3.new(0,h2.AssemblyLinearVelocity.Y,0) end
        elseif autoRightPhase==3 then h2.AssemblyLinearVelocity=Vector3.new(0,h2.AssemblyLinearVelocity.Y,0) if tick()-waitStartTime>=Values.AutoWalkWaitTime then autoRightPhase=4 end
        elseif autoRightPhase==4 then if moveTo(POSITION_R1,Values.AutoWalkReturnSpeed) then autoRightPhase=5 end
        elseif autoRightPhase==5 then
            h2.AssemblyLinearVelocity=Vector3.new(0,h2.AssemblyLinearVelocity.Y,0)
            AutoRightEnabled,Enabled.AutoRightEnabled=false,false
            if VisualSetters and VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false) end
            if autoRightConnection then autoRightConnection:Disconnect() autoRightConnection=nil end
            cleanAutoWalkOri(h2) faceCam(math.rad(180))
        end
    end)
end
local function stopAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() autoRightConnection=nil end
    local h=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if h then h.AssemblyLinearVelocity=Vector3.new(0,h.AssemblyLinearVelocity.Y,0) cleanAutoWalkOri(h) end
end

local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll=RunService.Heartbeat:Connect(function()
        if not Enabled.AntiRagdoll then return end
        local char=Player.Character if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart") local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            local hs=hum:GetState()
            if hs==Enum.HumanoidStateType.Physics or hs==Enum.HumanoidStateType.Ragdoll or hs==Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running) workspace.CurrentCamera.CameraSubject=hum
                pcall(function() local pm=Player.PlayerScripts:FindFirstChild("PlayerModule") if pm then require(pm:FindFirstChild("ControlModule")):Enable() end end)
                if root then root.Velocity=Vector3.new(0,0,0) root.RotVelocity=Vector3.new(0,0,0) end
            end
        end
        for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and obj.Enabled==false then obj.Enabled=true end end
    end)
end
local function stopAntiRagdoll() if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect() Connections.antiRagdoll=nil end end

local function startSpeedWhileStealing()
    if Connections.speedWhileStealing then return end
    Connections.speedWhileStealing=RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedWhileStealing or not Player:GetAttribute("Stealing") then return end
        local h=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") if not h then return end
        local md=getMovementDirection()
        if md.Magnitude>0.1 then h.AssemblyLinearVelocity=Vector3.new(md.X*Values.StealingSpeedValue,h.AssemblyLinearVelocity.Y,md.Z*Values.StealingSpeedValue) end
    end)
end
local function stopSpeedWhileStealing() if Connections.speedWhileStealing then Connections.speedWhileStealing:Disconnect() end end

local radiusVisualizer=Instance.new("Part") radiusVisualizer.Shape=Enum.PartType.Cylinder radiusVisualizer.CanCollide=false
radiusVisualizer.Anchored=true radiusVisualizer.CastShadow=false radiusVisualizer.Material=Enum.Material.ForceField
radiusVisualizer.Color=Color3.fromRGB(220,20,60) radiusVisualizer.Transparency=0.5
RunService.Heartbeat:Connect(function()
    if Enabled.AutoSteal and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        if radiusVisualizer.Parent~=workspace then radiusVisualizer.Parent=workspace end
        radiusVisualizer.Size=Vector3.new(0.05,Values.STEAL_RADIUS*2,Values.STEAL_RADIUS*2)
        radiusVisualizer.CFrame=Player.Character.HumanoidRootPart.CFrame*CFrame.new(0,-2.8,0)*CFrame.Angles(0,0,math.rad(90))
    else if radiusVisualizer.Parent then radiusVisualizer.Parent=nil end end
end)

local StealData={} local StealProgress=0 local autoStealGui=nil local barFill=nil
local function createAutoStealUI()
    if autoStealGui then return end
    autoStealGui=Instance.new("ScreenGui",Player.PlayerGui) autoStealGui.Name="ZyphrotAutoStealUI" autoStealGui.ResetOnSpawn=false
    local mf=Instance.new("Frame",autoStealGui) mf.Size=UDim2.new(0,240,0,45) mf.Position=UDim2.fromScale(0.5,0.4)
    mf.BackgroundColor3=Color3.fromRGB(12,12,15) mf.Active=true MakeDraggable(mf)
    Instance.new("UICorner",mf).CornerRadius=UDim.new(0,12)
    local ms=Instance.new("UIStroke",mf) ms.Thickness=2 ms.Color=Color3.fromRGB(220,20,60)
    local title=Instance.new("TextLabel",mf) title.Size=UDim2.new(1,0,0,25) title.Position=UDim2.new(0,0,0.15,0)
    title.BackgroundTransparency=1 title.Text="ZYPHROT HUB" title.Font=Enum.Font.GothamBlack title.TextSize=14 title.TextColor3=Color3.new(1,1,1)
    local bb=Instance.new("Frame",mf) bb.Size=UDim2.new(0.9,0,0,1) bb.Position=UDim2.new(0.05,0,0.75,0) bb.BackgroundColor3=Color3.fromRGB(30,30,35)
    Instance.new("UICorner",bb).CornerRadius=UDim.new(1,0)
    barFill=Instance.new("Frame",bb) barFill.Size=UDim2.new(0,0,1,0) barFill.BackgroundColor3=Color3.fromRGB(220,20,60)
    Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)
end
local function removeAutoStealUI() if autoStealGui then autoStealGui:Destroy() autoStealGui=nil barFill=nil end end
local function isMyPlotByName(pn)
    local plots=workspace:FindFirstChild("Plots")
    local sign=plots and plots:FindFirstChild(pn) and plots[pn]:FindFirstChild("PlotSign")
    return sign and sign:FindFirstChild("YourBase") and sign.YourBase:IsA("BillboardGui") and sign.YourBase.Enabled
end
local function findNearestPrompt()
    local h=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local plots=workspace:FindFirstChild("Plots") if not h or not plots then return nil end
    local np,nd,nn=nil,math.huge,nil
    for _,plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums=plot:FindFirstChild("AnimalPodiums") if not podiums then continue end
        for _,pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local spawn=pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn")
                if spawn then
                    local dist=(spawn.Position-h.Position).Magnitude
                    if dist<nd and dist<=Values.STEAL_RADIUS then
                        local att=spawn:FindFirstChild("PromptAttachment")
                        if att then for _,ch in ipairs(att:GetChildren()) do if ch:IsA("ProximityPrompt") then np,nd,nn=ch,dist,pod.Name break end end end
                    end
                end
            end)
        end
    end
    return np,nd,nn
end
local function executeSteal(prompt,name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt]={hold={},trigger={},ready=true}
        pcall(function()
            if getconnections then
                for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(StealData[prompt].hold,c.Function) end end
                for _,c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(StealData[prompt].trigger,c.Function) end end
            end
        end)
    end
    local data=StealData[prompt] if not data.ready then return end
    data.ready=false isStealing=true
    task.spawn(function()
        for _,f in ipairs(data.hold) do task.spawn(f) end
        local startTime=tick() local duration=Values.STEAL_DURATION
        if duration>0 then
            while tick()-startTime<duration do
                if not isStealing then break end
                StealProgress=math.clamp((tick()-startTime)/duration,0,1)
                if barFill then barFill.Size=UDim2.new(StealProgress,0,1,0) end
                task.wait()
            end
        end
        StealProgress=1 if barFill then barFill.Size=UDim2.new(1,0,1,0) end
        for _,f in ipairs(data.trigger) do task.spawn(f) end
        task.wait(0.2) StealProgress=0 if barFill then barFill.Size=UDim2.new(0,0,1,0) end
        data.ready=true isStealing=false
    end)
end
local function startAutoSteal()
    if Connections.autoSteal then return end createAutoStealUI()
    Connections.autoSteal=RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local p,_,n=findNearestPrompt() if p then executeSteal(p,n) end
    end)
end
local function stopAutoSteal()
    if Connections.autoSteal then Connections.autoSteal:Disconnect() Connections.autoSteal=nil end
    isStealing=false removeAutoStealUI()
end

local savedAnimations={}
local function startUnwalk()
    local c=Player.Character local hum=c and c:FindFirstChildOfClass("Humanoid")
    if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim=c and c:FindFirstChild("Animate")
    if anim then savedAnimations.Animate=anim:Clone() anim:Destroy() end
end
local function stopUnwalk()
    local c=Player.Character
    if c and savedAnimations.Animate then savedAnimations.Animate:Clone().Parent=c savedAnimations.Animate=nil end
end

local originalTransparency,xrayEnabled={},false
local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end if getgenv then getgenv().OPTIMIZER_ACTIVE=true end
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 Lighting.GlobalShadows=false Lighting.Brightness=3 Lighting.FogEnd=9e9 end)
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy()
                elseif obj:IsA("BasePart") then obj.CastShadow=false obj.Material=Enum.Material.Plastic end
            end)
        end
    end)
    xrayEnabled=true
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj]=obj.LocalTransparencyModifier obj.LocalTransparencyModifier=0.85
            end
        end
    end)
end
local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE=false end
    if xrayEnabled then for part,value in pairs(originalTransparency) do if part then part.LocalTransparencyModifier=value end end originalTransparency,xrayEnabled={},false end
end

local originalSkybox,galaxySkyBright,galaxySkyBrightConn,galaxyBloom,galaxyCC=nil,nil,nil,nil,nil
local function enableGalaxySkyBright()
    if galaxySkyBright then return end
    originalSkybox=Lighting:FindFirstChildOfClass("Sky") if originalSkybox then originalSkybox.Parent=nil end
    galaxySkyBright=Instance.new("Sky",Lighting)
    for _,f in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do galaxySkyBright[f]="rbxassetid://1534951537" end
    galaxySkyBright.StarCount=10000 galaxySkyBright.CelestialBodiesShown=false
    galaxyBloom=Instance.new("BloomEffect",Lighting) galaxyBloom.Intensity=1.5 galaxyBloom.Size=40 galaxyBloom.Threshold=0.8
    galaxyCC=Instance.new("ColorCorrectionEffect",Lighting) galaxyCC.Saturation=0.8 galaxyCC.Contrast=0.3 galaxyCC.TintColor=Color3.fromRGB(200,150,255)
    Lighting.Ambient=Color3.fromRGB(120,60,180) Lighting.Brightness=3 Lighting.ClockTime=0
    galaxySkyBrightConn=RunService.Heartbeat:Connect(function()
        if not Enabled.GalaxySkyBright then return end
        local t=tick()*0.5 Lighting.Ambient=Color3.fromRGB(120+math.sin(t)*60,50+math.sin(t*0.8)*40,180+math.sin(t*1.2)*50)
        if galaxyBloom then galaxyBloom.Intensity=1.2+math.sin(t*2)*0.4 end
    end)
end
local function disableGalaxySkyBright()
    if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect() galaxySkyBrightConn=nil end
    if galaxySkyBright then galaxySkyBright:Destroy() galaxySkyBright=nil end
    if originalSkybox then originalSkybox.Parent=Lighting end
    if galaxyBloom then galaxyBloom:Destroy() galaxyBloom=nil end
    if galaxyCC then galaxyCC:Destroy() galaxyCC=nil end
    Lighting.Ambient=Color3.fromRGB(127,127,127) Lighting.Brightness=2 Lighting.ClockTime=14
end

local fovConnection=nil
local function updateFOV() local cam=workspace.CurrentCamera if cam and cam.FieldOfView~=Values.FOV then cam.FieldOfView=Values.FOV end end
local function hookFOV()
    if fovConnection then fovConnection:Disconnect() end
    local cam=workspace.CurrentCamera if cam then fovConnection=cam:GetPropertyChangedSignal("FieldOfView"):Connect(updateFOV) updateFOV() end
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookFOV) hookFOV()

UserInputService.JumpRequest:Connect(function()
    if Enabled.InfJump then
        local c=Player.Character local hrp=c and c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,50,hrp.AssemblyLinearVelocity.Z) end
    end
end)

local espConnections={}
local function createESP(plr)
    if plr==Player or not plr.Character then return end
    local char=plr.Character local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp or char:FindFirstChild("ZyphrotHitbox") then return end
    local h=Instance.new("BoxHandleAdornment",char) h.Name="ZyphrotHitbox" h.Adornee=hrp
    h.Size=Vector3.new(4,6,2) h.Color3=Color3.fromRGB(128,0,128) h.Transparency=0.6 h.ZIndex=10 h.AlwaysOnTop=true
    local b=Instance.new("BillboardGui",char) b.Name="ZyphrotName" b.Adornee=char:FindFirstChild("Head") or hrp
    b.Size=UDim2.new(0,200,0,50) b.StudsOffset=Vector3.new(0,3,0) b.AlwaysOnTop=true
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
    l.Text=plr.DisplayName l.TextColor3=Color3.fromRGB(255,0,255) l.Font=Enum.Font.GothamBold l.TextSize=14
end
local function toggleESP(state)
    if not state then
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hb=p.Character:FindFirstChild("ZyphrotHitbox") local nm=p.Character:FindFirstChild("ZyphrotName")
                if hb then hb:Destroy() end if nm then nm:Destroy() end
            end
        end
        for _,c in ipairs(espConnections) do c:Disconnect() end espConnections={}
    else
        for _,p in ipairs(Players:GetPlayers()) do
            createESP(p)
            table.insert(espConnections,p.CharacterAdded:Connect(function() task.wait(0.5) if Enabled.ESP then createESP(p) end end))
        end
        table.insert(espConnections,Players.PlayerAdded:Connect(function(p)
            table.insert(espConnections,p.CharacterAdded:Connect(function() task.wait(0.5) if Enabled.ESP then createESP(p) end end))
        end))
    end
end

local function doTPDown()
    local c=Player.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local hum=c:FindFirstChildOfClass("Humanoid") if not hum then return end
    local rp=RaycastParams.new() rp.FilterDescendantsInstances={c} rp.FilterType=Enum.RaycastFilterType.Exclude
    local hit=workspace:Raycast(hrp.Position,Vector3.new(0,-500,0),rp)
    if hit then
        hrp.CFrame=CFrame.new(hit.Position.X,hit.Position.Y+(hum.HipHeight or 2)+(hrp.Size.Y/2)+0.1,hit.Position.Z)
        hrp.AssemblyLinearVelocity=Vector3.zero
    end
end

-- ============ GUI ============
VisualSetters={} local SliderSetters={} local KeyButtons={} local waitingForKeybind=nil

local G = {
    BG    = Color3.fromRGB(10,10,12),
    CARD  = Color3.fromRGB(16,16,20),
    CARD2 = Color3.fromRGB(22,22,28),
    BORD  = Color3.fromRGB(45,45,55),
    TXT   = Color3.fromRGB(220,220,225),
    DIM   = Color3.fromRGB(100,100,115),
    ACC   = Color3.fromRGB(220,220,220),
    ON    = Color3.fromRGB(60,200,100),
    OFF   = Color3.fromRGB(40,40,50),
    RED   = Color3.fromRGB(210,60,60),
}

local guiVisible=true
local sg=Instance.new("ScreenGui")
sg.Name="ZyphrotHub_V3" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true
pcall(function() sg.Parent=CoreGui end)
if not sg.Parent then sg.Parent=Player:WaitForChild("PlayerGui") end

local function playSound(id,vol)
    pcall(function()
        local sound=Instance.new("Sound",SoundService) sound.SoundId=id sound.Volume=vol or 0.3 sound:Play()
        game:GetService("Debris"):AddItem(sound,1)
    end)
end

local function sendChat(msg)
    task.spawn(function()
        pcall(function()
            local tcs=game:GetService("TextChatService")
            local ch=tcs:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
            ch:SendAsync(msg)
        end)
    end)
end

local tauntEnabled=false

-- ============ TOP BAR ============
local topBar=Instance.new("Frame",sg)
topBar.Size=UDim2.fromOffset(136,30) topBar.Position=UDim2.new(0,8,0,8)
topBar.BackgroundColor3=G.CARD topBar.BackgroundTransparency=0.05 topBar.BorderSizePixel=0
Instance.new("UICorner",topBar).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",topBar).Color=G.BORD
local topLayout=Instance.new("UIListLayout",topBar)
topLayout.FillDirection=Enum.FillDirection.Horizontal topLayout.Padding=UDim.new(0,2) topLayout.SortOrder=Enum.SortOrder.LayoutOrder
local topPad=Instance.new("UIPadding",topBar)
topPad.PaddingLeft=UDim.new(0,4) topPad.PaddingRight=UDim.new(0,4) topPad.PaddingTop=UDim.new(0,4) topPad.PaddingBottom=UDim.new(0,4)

local zhBtn=Instance.new("TextButton",topBar)
zhBtn.Size=UDim2.fromOffset(58,22) zhBtn.BackgroundColor3=G.CARD2 zhBtn.BackgroundTransparency=0.1
zhBtn.Text="ZH" zhBtn.Font=Enum.Font.GothamBlack zhBtn.TextSize=11
zhBtn.TextColor3=G.TXT zhBtn.BorderSizePixel=0 zhBtn.LayoutOrder=1
Instance.new("UICorner",zhBtn).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",zhBtn).Color=G.BORD

local tauntBtn=Instance.new("TextButton",topBar)
tauntBtn.Size=UDim2.fromOffset(64,22) tauntBtn.BackgroundColor3=G.CARD2 tauntBtn.BackgroundTransparency=0.1
tauntBtn.Text="TAUNT OFF" tauntBtn.Font=Enum.Font.GothamBold tauntBtn.TextSize=9
tauntBtn.TextColor3=G.DIM tauntBtn.BorderSizePixel=0 tauntBtn.LayoutOrder=2
Instance.new("UICorner",tauntBtn).CornerRadius=UDim.new(0,5)
local tauntStroke=Instance.new("UIStroke",tauntBtn) tauntStroke.Color=G.BORD

zhBtn.MouseButton1Click:Connect(function()
    guiVisible=not guiVisible main.Visible=guiVisible
    playSound("rbxassetid://6895079813",0.3)
end)

tauntBtn.MouseButton1Click:Connect(function()
    tauntEnabled=not tauntEnabled
    if tauntEnabled then
        tauntBtn.Text="TAUNT ON" tauntBtn.TextColor3=G.ON tauntStroke.Color=G.ON
        task.spawn(function()
            while tauntEnabled do sendChat("Phantom better") task.wait(30) end
        end)
    else
        tauntBtn.Text="TAUNT OFF" tauntBtn.TextColor3=G.DIM tauntStroke.Color=G.BORD
    end
    playSound("rbxassetid://6895079813",0.3)
end)

-- ============ MAIN WINDOW ============
local main=Instance.new("Frame",sg)
main.Size=UDim2.fromOffset(530*s,370*s) main.Position=UDim2.new(0.5,-265*s,0.5,-185*s)
main.BackgroundColor3=G.BG main.BackgroundTransparency=0.05 main.BorderSizePixel=0 main.Active=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",main).Color=G.BORD
MakeDraggable(main)

-- SIDEBAR
local sidebar=Instance.new("Frame",main)
sidebar.Size=UDim2.fromOffset(128*s,370*s) sidebar.BackgroundColor3=G.CARD
sidebar.BackgroundTransparency=0.06 sidebar.BorderSizePixel=0
Instance.new("UICorner",sidebar).CornerRadius=UDim.new(0,12)
local sfFix=Instance.new("Frame",sidebar) sfFix.Size=UDim2.fromOffset(12*s,370*s) sfFix.Position=UDim2.new(1,-12*s,0,0)
sfFix.BackgroundColor3=G.CARD sfFix.BackgroundTransparency=0.06 sfFix.BorderSizePixel=0

local logoLbl=Instance.new("TextLabel",sidebar) logoLbl.Size=UDim2.fromOffset(128*s,42*s)
logoLbl.BackgroundTransparency=1 logoLbl.Text="ZYPHROT\nHUB" logoLbl.Font=Enum.Font.GothamBlack
logoLbl.TextSize=13*s logoLbl.TextColor3=G.TXT

local logoDiv=Instance.new("Frame",sidebar) logoDiv.Size=UDim2.fromOffset(108*s,1) logoDiv.Position=UDim2.fromOffset(10*s,44*s)
logoDiv.BackgroundColor3=G.BORD logoDiv.BorderSizePixel=0

local tabContainer=Instance.new("Frame",sidebar)
tabContainer.Size=UDim2.new(1,0,1,-(125*s)) tabContainer.Position=UDim2.fromOffset(0,48*s)
tabContainer.BackgroundTransparency=1
local tabLayout2=Instance.new("UIListLayout",tabContainer) tabLayout2.Padding=UDim.new(0,3*s)
local tabPad=Instance.new("UIPadding",tabContainer)
tabPad.PaddingLeft=UDim.new(0,6*s) tabPad.PaddingRight=UDim.new(0,6*s) tabPad.PaddingTop=UDim.new(0,4*s)

local uFrame=Instance.new("Frame",sidebar) uFrame.Size=UDim2.fromOffset(128*s,48*s)
uFrame.Position=UDim2.new(0,0,1,-48*s) uFrame.BackgroundTransparency=1
local uDivTop=Instance.new("Frame",uFrame) uDivTop.Size=UDim2.fromOffset(108*s,1) uDivTop.Position=UDim2.fromOffset(10*s,0)
uDivTop.BackgroundColor3=G.BORD uDivTop.BorderSizePixel=0
local uAv=Instance.new("ImageLabel",uFrame) uAv.Size=UDim2.fromOffset(22*s,22*s) uAv.Position=UDim2.fromOffset(8*s,13*s)
uAv.BackgroundColor3=G.CARD2 uAv.BorderSizePixel=0
uAv.Image="rbxthumb://type=AvatarHeadShot&id="..Player.UserId.."&w=150&h=150"
Instance.new("UICorner",uAv).CornerRadius=UDim.new(1,0)
local uNm=Instance.new("TextLabel",uFrame) uNm.Size=UDim2.fromOffset(88*s,14*s) uNm.Position=UDim2.fromOffset(34*s,14*s)
uNm.BackgroundTransparency=1 uNm.Text=Player.Name uNm.Font=Enum.Font.GothamBold uNm.TextSize=9*s
uNm.TextColor3=G.TXT uNm.TextXAlignment=Enum.TextXAlignment.Left uNm.TextTruncate=Enum.TextTruncate.AtEnd
local uSub=Instance.new("TextLabel",uFrame) uSub.Size=UDim2.fromOffset(88*s,12*s) uSub.Position=UDim2.fromOffset(34*s,28*s)
uSub.BackgroundTransparency=1 uSub.Text="Premium" uSub.Font=Enum.Font.GothamMedium uSub.TextSize=8*s
uSub.TextColor3=G.DIM uSub.TextXAlignment=Enum.TextXAlignment.Left

local contentArea=Instance.new("Frame",main)
contentArea.Size=UDim2.new(1,-(128*s),1,0) contentArea.Position=UDim2.fromOffset(128*s,0)
contentArea.BackgroundTransparency=1 contentArea.ClipsDescendants=true

-- Stats HUD
local StatsFrame=Instance.new("Frame",sg) StatsFrame.Size=UDim2.fromOffset(105,38)
StatsFrame.Position=UDim2.new(0,8,1,-50) StatsFrame.BackgroundColor3=G.CARD StatsFrame.BackgroundTransparency=0.1
StatsFrame.BorderSizePixel=0 StatsFrame.Visible=Enabled.Stats
Instance.new("UICorner",StatsFrame).CornerRadius=UDim.new(0,7)
Instance.new("UIStroke",StatsFrame).Color=G.BORD
local fpsLbl=Instance.new("TextLabel",StatsFrame) fpsLbl.Size=UDim2.new(1,0,0.5,0) fpsLbl.BackgroundTransparency=1
fpsLbl.Text="FPS: --" fpsLbl.Font=Enum.Font.GothamBold fpsLbl.TextSize=10 fpsLbl.TextColor3=G.ON
local pingLbl=Instance.new("TextLabel",StatsFrame) pingLbl.Size=UDim2.new(1,0,0.5,0) pingLbl.Position=UDim2.new(0,0,0.5,0)
pingLbl.BackgroundTransparency=1 pingLbl.Text="PING: --" pingLbl.Font=Enum.Font.GothamBold pingLbl.TextSize=10 pingLbl.TextColor3=G.TXT
task.spawn(function()
    local fc,ft=0,tick()
    while sg.Parent do
        RunService.RenderStepped:Wait() fc=fc+1
        local now=tick() if now-ft>=0.5 then
            local fps=math.round(fc/(now-ft)) fc=0 ft=now fpsLbl.Text="FPS: "..fps
            fpsLbl.TextColor3=fps>=55 and G.ON or fps>=30 and Color3.fromRGB(255,200,50) or G.RED
        end task.wait()
    end
end)
task.spawn(function()
    while sg.Parent do
        pcall(function()
            local p=math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            pingLbl.Text="PING: "..p.."ms"
            pingLbl.TextColor3=p<80 and G.ON or p<150 and Color3.fromRGB(255,200,50) or G.RED
        end) task.wait(1)
    end
end)

local pages={} local tabBtns={} local activeTab=nil
local TAB_ICONS={["Movement"]="RUN",["Combat"]="ATK",["Automation"]="BOT",["World & Visuals"]="VIS",["Settings"]="SET"}

local function switchTab(name)
    if activeTab==name then return end activeTab=name
    for n,pg in pairs(pages) do
        pg.Visible=n==name
        if n==name then
            pg.Position=UDim2.fromOffset(18*s,8*s)
            TweenService:Create(pg,TweenInfo.new(0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(8*s,8*s)}):Play()
        end
    end
    for n,tb in pairs(tabBtns) do
        local on=n==name
        TweenService:Create(tb,TweenInfo.new(0.15),{BackgroundColor3=on and G.CARD2 or G.CARD,TextColor3=on and G.TXT or G.DIM}):Play()
        local st=tb:FindFirstChildOfClass("UIStroke") if st then TweenService:Create(st,TweenInfo.new(0.15),{Transparency=on and 0.1 or 0.7}):Play() end
    end
    playSound("rbxassetid://6895079813",0.15)
end

local function createTab(name)
    local btn=Instance.new("TextButton",tabContainer)
    btn.Size=UDim2.new(1,0,0,28*s) btn.BackgroundColor3=G.CARD btn.BackgroundTransparency=0.2
    btn.Text=TAB_ICONS[name] or name btn.Font=Enum.Font.GothamBold btn.TextSize=10*s
    btn.TextColor3=G.DIM btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6*s)
    local st=Instance.new("UIStroke",btn) st.Color=G.ACC st.Thickness=1 st.Transparency=0.7
    local pg=Instance.new("ScrollingFrame",contentArea)
    pg.Size=UDim2.new(1,-(14*s),1,-(14*s)) pg.Position=UDim2.fromOffset(8*s,8*s)
    pg.BackgroundTransparency=1 pg.ScrollBarThickness=3*s pg.ScrollBarImageColor3=G.BORD
    pg.BorderSizePixel=0 pg.Visible=false pg.CanvasSize=UDim2.new(0,0,0,0)
    local layout=Instance.new("UIListLayout",pg) layout.Padding=UDim.new(0,4*s) layout.SortOrder=Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() pg.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+16*s) end)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabBtns[name]=btn pages[name]=pg return pg
end

local function createToggle(page,labelText,enabledKey,keybindKey,callback)
    local row=Instance.new("Frame",page)
    row.Size=UDim2.new(1,0,0,34*s) row.BackgroundColor3=G.CARD row.BackgroundTransparency=0.1 row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7*s)
    local rowStroke=Instance.new("UIStroke",row) rowStroke.Color=G.BORD rowStroke.Thickness=1 rowStroke.Transparency=0.5
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(0.58,0,1,0) lbl.Position=UDim2.fromOffset(9*s,0)
    lbl.BackgroundTransparency=1 lbl.Text=labelText lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=11*s lbl.TextColor3=G.TXT lbl.TextXAlignment=Enum.TextXAlignment.Left
    local defaultOn=Enabled[enabledKey]
    local pillW,pillH=32*s,17*s
    local pill=Instance.new("Frame",row) pill.Size=UDim2.fromOffset(pillW,pillH)
    pill.Position=UDim2.new(1,-pillW-9*s,0.5,-pillH/2) pill.BackgroundColor3=defaultOn and G.ON or G.OFF
    pill.BorderSizePixel=0 Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local cir=Instance.new("Frame",pill) cir.Size=UDim2.fromOffset(pillH-4,pillH-4)
    cir.Position=defaultOn and UDim2.new(1,-(pillH-2),0.5,-(pillH-4)/2) or UDim2.new(0,2,0.5,-(pillH-4)/2)
    cir.BackgroundColor3=Color3.new(1,1,1) cir.BorderSizePixel=0 Instance.new("UICorner",cir).CornerRadius=UDim.new(1,0)
    if keybindKey then
        local kBtn=Instance.new("TextButton",row) kBtn.Size=UDim2.fromOffset(25*s,17*s)
        kBtn.Position=UDim2.new(1,-pillW-38*s,0.5,-8.5*s) kBtn.BackgroundColor3=G.CARD2 kBtn.BackgroundTransparency=0.1
        kBtn.Text=KEYBINDS[keybindKey].Name kBtn.Font=Enum.Font.GothamBold kBtn.TextSize=8*s kBtn.TextColor3=G.DIM kBtn.BorderSizePixel=0
        Instance.new("UICorner",kBtn).CornerRadius=UDim.new(0,4*s) Instance.new("UIStroke",kBtn).Color=G.BORD
        KeyButtons[keybindKey]=kBtn kBtn.MouseButton1Click:Connect(function() waitingForKeybind=keybindKey kBtn.Text="..." end)
    end
    local isOn=defaultOn
    local function setVisual(state,skipCb)
        isOn=state
        TweenService:Create(pill,TweenInfo.new(0.14),{BackgroundColor3=state and G.ON or G.OFF}):Play()
        TweenService:Create(cir,TweenInfo.new(0.14,Enum.EasingStyle.Back),{Position=state and UDim2.new(1,-(pillH-2),0.5,-(pillH-4)/2) or UDim2.new(0,2,0.5,-(pillH-4)/2)}):Play()
        TweenService:Create(rowStroke,TweenInfo.new(0.14),{Color=state and G.ACC or G.BORD,Transparency=state and 0.15 or 0.5}):Play()
        if not skipCb then callback(isOn) end
    end
    VisualSetters[enabledKey]=setVisual
    local cb=Instance.new("TextButton",row) cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text=""
    cb.MouseButton1Click:Connect(function() isOn=not isOn Enabled[enabledKey]=isOn setVisual(isOn) playSound("rbxassetid://6895079813",0.22) end)
    return setVisual
end

local function createSlider(page,labelText,minVal,maxVal,valueKey,isFloat,callback)
    local row=Instance.new("Frame",page)
    row.Size=UDim2.new(1,0,0,50*s) row.BackgroundColor3=G.CARD row.BackgroundTransparency=0.1 row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7*s) Instance.new("UIStroke",row).Color=G.BORD
    local defaultVal=Values[valueKey]
    local lbl=Instance.new("TextLabel",row) lbl.Size=UDim2.new(0.6,0,0,19*s) lbl.Position=UDim2.fromOffset(9*s,6*s)
    lbl.BackgroundTransparency=1 lbl.Text=labelText lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=10*s lbl.TextColor3=G.TXT lbl.TextXAlignment=Enum.TextXAlignment.Left
    local vBox=Instance.new("TextBox",row) vBox.Size=UDim2.fromOffset(42*s,19*s) vBox.Position=UDim2.new(1,-51*s,0,6*s)
    vBox.BackgroundColor3=G.CARD2 vBox.BackgroundTransparency=0.1 vBox.Text=tostring(defaultVal)
    vBox.Font=Enum.Font.GothamBold vBox.TextSize=10*s vBox.TextColor3=G.TXT vBox.ClearTextOnFocus=false vBox.BorderSizePixel=0
    Instance.new("UICorner",vBox).CornerRadius=UDim.new(0,4*s) Instance.new("UIStroke",vBox).Color=G.BORD
    local sbg=Instance.new("Frame",row) sbg.Size=UDim2.new(1,-18*s,0,4*s) sbg.Position=UDim2.fromOffset(9*s,34*s)
    sbg.BackgroundColor3=G.CARD2 sbg.BorderSizePixel=0 Instance.new("UICorner",sbg).CornerRadius=UDim.new(1,0)
    local pct=math.clamp((defaultVal-minVal)/(maxVal-minVal),0,1)
    local fill=Instance.new("Frame",sbg) fill.Size=UDim2.new(pct,0,1,0) fill.BackgroundColor3=G.ACC fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local thumb=Instance.new("Frame",sbg) thumb.Size=UDim2.fromOffset(11*s,11*s)
    thumb.Position=UDim2.new(pct,-5.5*s,0.5,-5.5*s) thumb.BackgroundColor3=G.TXT thumb.BorderSizePixel=0
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local drag=Instance.new("TextButton",sbg) drag.Size=UDim2.new(1,0,4,0) drag.Position=UDim2.new(0,0,-1.5,0)
    drag.BackgroundTransparency=1 drag.Text=""
    local dragging=false
    local function upd(rel)
        rel=math.clamp(rel,0,1) fill.Size=UDim2.new(rel,0,1,0) thumb.Position=UDim2.new(rel,-5.5*s,0.5,-5.5*s)
        local v=minVal+(maxVal-minVal)*rel v=isFloat and (math.floor(v*100)/100) or math.floor(v)
        vBox.Text=tostring(v) Values[valueKey]=v callback(v)
    end
    drag.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            upd((i.Position.X-sbg.AbsolutePosition.X)/sbg.AbsoluteSize.X)
        end
    end)
    vBox.FocusLost:Connect(function()
        local n=tonumber(vBox.Text) if n then
            n=math.clamp(n,minVal,maxVal) n=isFloat and (math.floor(n*100)/100) or math.floor(n)
            local r=(n-minVal)/(maxVal-minVal) fill.Size=UDim2.new(r,0,1,0) thumb.Position=UDim2.new(r,-5.5*s,0.5,-5.5*s)
            vBox.Text=tostring(n) Values[valueKey]=n callback(n)
        else vBox.Text=tostring(Values[valueKey]) end
    end)
    SliderSetters[valueKey]=function(v)
        local r=math.clamp((v-minVal)/(maxVal-minVal),0,1) fill.Size=UDim2.new(r,0,1,0) thumb.Position=UDim2.new(r,-5.5*s,0.5,-5.5*s) vBox.Text=tostring(v)
    end
end

local function createActionBtn(page,text,callback)
    local btn=Instance.new("TextButton",page)
    btn.Size=UDim2.new(1,0,0,30*s) btn.BackgroundColor3=G.CARD2 btn.BackgroundTransparency=0.1
    btn.Text=text btn.Font=Enum.Font.GothamBold btn.TextSize=11*s btn.TextColor3=G.TXT btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7*s)
    Instance.new("UIStroke",btn).Color=G.BORD
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.03}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play() end)
    btn.MouseButton1Click:Connect(function() playSound("rbxassetid://6895079813",0.22) callback(btn) end)
    return btn
end

local function createSection(page,text)
    local lbl=Instance.new("TextLabel",page) lbl.Size=UDim2.new(1,0,0,16*s)
    lbl.BackgroundTransparency=1 lbl.Text=text lbl.Font=Enum.Font.GothamBlack
    lbl.TextSize=9*s lbl.TextColor3=G.DIM lbl.TextXAlignment=Enum.TextXAlignment.Left
end

-- Create tabs
local pageMovement=createTab("Movement")
local pageCombat=createTab("Combat")
local pageAuto=createTab("Automation")
local pageVisuals=createTab("World & Visuals")
local pageSettings=createTab("Settings")
switchTab("Movement")

-- MOVEMENT
createToggle(pageMovement,"Speed Boost","SpeedBoost","SPEED",function(v) if v then startSpeedBoost() else stopSpeedBoost() end end)
createSlider(pageMovement,"Boost Speed",1,100,"BoostSpeed",true,function(v) Values.BoostSpeed=v end)
createToggle(pageMovement,"Anti Ragdoll","AntiRagdoll","ANTIRAGDOLL",function(v) if v then startAntiRagdoll() else stopAntiRagdoll() end end)
createToggle(pageMovement,"Player Hover","Hover","HOVER",function(v) ToggleHover(v) end)
createSlider(pageMovement,"Hover Height",0,100,"HoverHeight",true,function(v) Values.HoverHeight=v end)
createToggle(pageMovement,"Spin Bot","SpinBot","SPIN",function(v) if v then startSpinBot() else stopSpinBot() end end)
createSlider(pageMovement,"Spin Speed",5,100,"SpinSpeed",true,function(v) Values.SpinSpeed=v end)
createToggle(pageMovement,"Unwalk Animations","Unwalk","UNWALK",function(v) if v then startUnwalk() else stopUnwalk() end end)
createToggle(pageMovement,"Infinite Jump","InfJump","INFJUMP",function(v) end)
createActionBtn(pageMovement,"TP DOWN",function(btn)
    btn.Text="Teleporting..." btn.TextColor3=G.DIM doTPDown()
    task.delay(0.5,function() btn.Text="TP DOWN" btn.TextColor3=G.TXT end)
end)

-- COMBAT
createToggle(pageCombat,"Bat Aimbot","BatAimbot","BATAIMBOT",function(v)
    if v then startBatAimbot() else stopBatAimbot() end
end)
createToggle(pageCombat,"Spam Bat Swings","SpamBat","SPAMBAT",function(v) if v then startSpamBat() else stopSpamBat() end end)

-- AUTOMATION
createToggle(pageAuto,"Auto Steal","AutoSteal","AUTOSTEAL",function(v) if v then startAutoSteal() else stopAutoSteal() end end)
createSlider(pageAuto,"Grab Time (Secs)",0.0,5.0,"STEAL_DURATION",true,function(v) Values.STEAL_DURATION=v end)
createSlider(pageAuto,"Steal Radius",5,100,"STEAL_RADIUS",true,function(v) Values.STEAL_RADIUS=v end)
createToggle(pageAuto,"Speed While Stealing","SpeedWhileStealing","SPEEDSTEAL",function(v) if v then startSpeedWhileStealing() else stopSpeedWhileStealing() end end)
createSlider(pageAuto,"Stealing Speed",5,50,"StealingSpeedValue",true,function(v) Values.StealingSpeedValue=v end)
createSection(pageAuto,"AUTO WALK")
createToggle(pageAuto,"Auto Walk Left","AutoWalkEnabled","AUTOLEFT",function(v)
    AutoWalkEnabled,Enabled.AutoWalkEnabled=v,v if v then startAutoWalk() else stopAutoWalk() end
end)
createSlider(pageAuto,"Auto Left Speed",1,100,"AutoLeftSpeed",true,function(v) Values.AutoLeftSpeed=v end)
createToggle(pageAuto,"Auto Walk Right","AutoRightEnabled","AUTORIGHT",function(v)
    AutoRightEnabled,Enabled.AutoRightEnabled=v,v if v then startAutoRight() else stopAutoRight() end
end)
createSlider(pageAuto,"Auto Right Speed",1,100,"AutoRightSpeed",true,function(v) Values.AutoRightSpeed=v end)
createSection(pageAuto,"AUTO PLAY")
createToggle(pageAuto,"Auto Play Left","AutoPlayLeftEnabled","AUTOPLAYLEFT",function(v)
    AutoPlayLeftEnabled,Enabled.AutoPlayLeftEnabled=v,v if v then startAutoPlayLeft() else stopAutoPlayLeft() end
end)
createToggle(pageAuto,"Auto Play Right","AutoPlayRightEnabled","AUTOPLAYRIGHT",function(v)
    AutoPlayRightEnabled,Enabled.AutoPlayRightEnabled=v,v if v then startAutoPlayRight() else stopAutoPlayRight() end
end)
createSlider(pageAuto,"Base Exit Distance",0,30,"AutoPlayExitDist",false,function(v) Values.AutoPlayExitDist=v end)
createSlider(pageAuto,"Play Return Speed",1,100,"AutoPlayReturnSpeed",true,function(v) Values.AutoPlayReturnSpeed=v end)
createSlider(pageAuto,"Play Wait Time",0.0,10.0,"AutoPlayWaitTime",true,function(v) Values.AutoPlayWaitTime=v end)
createSlider(pageAuto,"Walk Return Speed",1,100,"AutoWalkReturnSpeed",true,function(v) Values.AutoWalkReturnSpeed=v end)
createSlider(pageAuto,"Walk Wait Time",0.0,10.0,"AutoWalkWaitTime",true,function(v) Values.AutoWalkWaitTime=v end)

-- VISUALS
createToggle(pageVisuals,"Speed Meter","SpeedMeter","SPEEDMETER",function(v) toggleSpeedMeter(v) end)
createToggle(pageVisuals,"ESP & Hitbox","ESP","ESP",function(v) toggleESP(v) end)
createToggle(pageVisuals,"Show FPS/Ping","Stats","STATS",function(v) StatsFrame.Visible=v end)
createSlider(pageVisuals,"Field of View",10,120,"FOV",true,function(v) Values.FOV=v updateFOV() end)
createToggle(pageVisuals,"Galaxy Mode","Galaxy","GALAXY",function(v) if v then startGalaxy() else stopGalaxy() end end)
createSlider(pageVisuals,"Gravity %",10,150,"GalaxyGravityPercent",false,function(v) Values.GalaxyGravityPercent=v if galaxyEnabled then adjustGalaxyJump() end end)
createSlider(pageVisuals,"Hop Power",10,100,"HOP_POWER",true,function(v) Values.HOP_POWER=v end)
createToggle(pageVisuals,"Galaxy Sky","GalaxySkyBright","GALAXY_SKY",function(v) if v then enableGalaxySkyBright() else disableGalaxySkyBright() end end)
createToggle(pageVisuals,"Optimizer","Optimizer","OPTIMIZER",function(v) if v then enableOptimizer() else disableOptimizer() end end)

-- SETTINGS
createActionBtn(pageSettings,"Save Config",function(btn)
    local ok=SaveConfig() btn.Text=ok and "Saved!" or "Failed!"
    btn.TextColor3=ok and G.ON or G.RED
    task.delay(2,function() btn.Text="Save Config" btn.TextColor3=G.TXT end)
end)
createActionBtn(pageSettings,"Close GUI",function() guiVisible=false main.Visible=false end)
local infoLbl=Instance.new("TextLabel",pageSettings) infoLbl.Size=UDim2.new(1,0,0,28*s)
infoLbl.BackgroundTransparency=1 infoLbl.Text="[U] toggle  |  click keybind box to rebind"
infoLbl.Font=Enum.Font.GothamMedium infoLbl.TextSize=9*s infoLbl.TextColor3=G.DIM infoLbl.TextWrapped=true

-- Mobile shortcuts
local mobileShortcuts={}
if isMobile then
    local btns={
        {id="hover",   txt="Hover",  pos=UDim2.new(1,-125,0.58,-120)},
        {id="bat",     txt="Bat",    pos=UDim2.new(1,-65,0.58,-120)},
        {id="playLeft",txt="PlayL",  pos=UDim2.new(1,-125,0.58,-60)},
        {id="playRight",txt="PlayR", pos=UDim2.new(1,-65,0.58,-60)},
        {id="left",    txt="AutoL",  pos=UDim2.new(1,-125,0.58,0)},
        {id="right",   txt="AutoR",  pos=UDim2.new(1,-65,0.58,0)},
    }
    for _,bd in ipairs(btns) do
        local btn=Instance.new("TextButton",sg)
        btn.Size=UDim2.fromOffset(50,50) btn.Position=bd.pos
        btn.BackgroundColor3=G.CARD btn.BackgroundTransparency=0.08
        btn.Text=bd.txt btn.Font=Enum.Font.GothamBold btn.TextSize=10
        btn.TextColor3=G.DIM btn.BorderSizePixel=0
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
        Instance.new("UIStroke",btn).Color=G.BORD
        mobileShortcuts[bd.id]=btn
    end
    local function mobTog(id,ek,sf,stf)
        mobileShortcuts[id].MouseButton1Click:Connect(function()
            local ns=not Enabled[ek] Enabled[ek]=ns if VisualSetters[ek] then VisualSetters[ek](ns,true) end
            if ns then if sf then sf() end else if stf then stf() end end
            mobileShortcuts[id].TextColor3=ns and G.TXT or G.DIM
        end)
    end
    mobTog("hover","Hover",function() ToggleHover(true) end,function() ToggleHover(false) end)
    mobTog("bat","BatAimbot",startBatAimbot,stopBatAimbot)
    mobileShortcuts.left.MouseButton1Click:Connect(function()
        local ns=not Enabled.AutoWalkEnabled AutoWalkEnabled,Enabled.AutoWalkEnabled=ns,ns
        if VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(ns,true) end
        if ns then startAutoWalk() else stopAutoWalk() end mobileShortcuts.left.TextColor3=ns and G.TXT or G.DIM
    end)
    mobileShortcuts.right.MouseButton1Click:Connect(function()
        local ns=not Enabled.AutoRightEnabled AutoRightEnabled,Enabled.AutoRightEnabled=ns,ns
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(ns,true) end
        if ns then startAutoRight() else stopAutoRight() end mobileShortcuts.right.TextColor3=ns and G.TXT or G.DIM
    end)
    mobileShortcuts.playLeft.MouseButton1Click:Connect(function()
        local ns=not Enabled.AutoPlayLeftEnabled AutoPlayLeftEnabled,Enabled.AutoPlayLeftEnabled=ns,ns
        if VisualSetters.AutoPlayLeftEnabled then VisualSetters.AutoPlayLeftEnabled(ns,true) end
        if ns then startAutoPlayLeft() else stopAutoPlayLeft() end mobileShortcuts.playLeft.TextColor3=ns and G.TXT or G.DIM
    end)
    mobileShortcuts.playRight.MouseButton1Click:Connect(function()
        local ns=not Enabled.AutoPlayRightEnabled AutoPlayRightEnabled,Enabled.AutoPlayRightEnabled=ns,ns
        if VisualSetters.AutoPlayRightEnabled then VisualSetters.AutoPlayRightEnabled(ns,true) end
        if ns then startAutoPlayRight() else stopAutoPlayRight() end mobileShortcuts.playRight.TextColor3=ns and G.TXT or G.DIM
    end)
end

-- Startup init
task.spawn(function()
    task.wait(2)
    for k,btn in pairs(KeyButtons) do if btn and KEYBINDS[k] then btn.Text=KEYBINDS[k].Name end end
    for key,setter in pairs(VisualSetters) do if Enabled[key] then setter(true,false) else setter(false,true) end end
    for key,setter in pairs(SliderSetters) do if Values[key] then setter(Values[key]) end end
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if UserInputService:GetFocusedTextBox() then return end
    if waitingForKeybind and input.KeyCode~=Enum.KeyCode.Unknown then
        local k=input.KeyCode KEYBINDS[waitingForKeybind]=k
        if KeyButtons[waitingForKeybind] then KeyButtons[waitingForKeybind].Text=k.Name end
        waitingForKeybind=nil return
    end
    if input.KeyCode==Enum.KeyCode.U then guiVisible=not guiVisible main.Visible=guiVisible return end
    if input.KeyCode==Enum.KeyCode.Space then spaceHeld=true return end
    local function tog(ek,sf,stf)
        Enabled[ek]=not Enabled[ek] if VisualSetters[ek] then VisualSetters[ek](Enabled[ek]) end
        if Enabled[ek] then if sf then sf() end else if stf then stf() end end
    end
    if input.KeyCode==KEYBINDS.SPEED then tog("SpeedBoost",startSpeedBoost,stopSpeedBoost) end
    if input.KeyCode==KEYBINDS.SPIN then tog("SpinBot",startSpinBot,stopSpinBot) end
    if input.KeyCode==KEYBINDS.GALAXY then tog("Galaxy",startGalaxy,stopGalaxy) end
    if input.KeyCode==KEYBINDS.BATAIMBOT then tog("BatAimbot",startBatAimbot,stopBatAimbot) end
    if input.KeyCode==KEYBINDS.NUKE then local n=getNearestPlayer() if n then INSTANT_NUKE(n) end end
    if input.KeyCode==KEYBINDS.AUTOLEFT then
        AutoWalkEnabled=not AutoWalkEnabled Enabled.AutoWalkEnabled=AutoWalkEnabled
        if VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(AutoWalkEnabled) end
        if AutoWalkEnabled then startAutoWalk() else stopAutoWalk() end
    end
    if input.KeyCode==KEYBINDS.AUTORIGHT then
        AutoRightEnabled=not AutoRightEnabled Enabled.AutoRightEnabled=AutoRightEnabled
        if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(AutoRightEnabled) end
        if AutoRightEnabled then startAutoRight() else stopAutoRight() end
    end
    if input.KeyCode==KEYBINDS.AUTOPLAYLEFT then
        AutoPlayLeftEnabled=not AutoPlayLeftEnabled Enabled.AutoPlayLeftEnabled=AutoPlayLeftEnabled
        if VisualSetters.AutoPlayLeftEnabled then VisualSetters.AutoPlayLeftEnabled(AutoPlayLeftEnabled) end
        if AutoPlayLeftEnabled then startAutoPlayLeft() else stopAutoPlayLeft() end
    end
    if input.KeyCode==KEYBINDS.AUTOPLAYRIGHT then
        AutoPlayRightEnabled=not AutoPlayRightEnabled Enabled.AutoPlayRightEnabled=AutoPlayRightEnabled
        if VisualSetters.AutoPlayRightEnabled then VisualSetters.AutoPlayRightEnabled(AutoPlayRightEnabled) end
        if AutoPlayRightEnabled then startAutoPlayRight() else stopAutoPlayRight() end
    end
    if input.KeyCode==KEYBINDS.ANTIRAGDOLL then tog("AntiRagdoll",startAntiRagdoll,stopAntiRagdoll) end
    if input.KeyCode==KEYBINDS.SPEEDSTEAL then tog("SpeedWhileStealing",startSpeedWhileStealing,stopSpeedWhileStealing) end
    if input.KeyCode==KEYBINDS.AUTOSTEAL then tog("AutoSteal",startAutoSteal,stopAutoSteal) end
    if input.KeyCode==KEYBINDS.UNWALK then tog("Unwalk",startUnwalk,stopUnwalk) end
    if input.KeyCode==KEYBINDS.OPTIMIZER then tog("Optimizer",enableOptimizer,disableOptimizer) end
    if input.KeyCode==KEYBINDS.SPAMBAT then tog("SpamBat",startSpamBat,stopSpamBat) end
    if input.KeyCode==KEYBINDS.GALAXY_SKY then tog("GalaxySkyBright",enableGalaxySkyBright,disableGalaxySkyBright) end
    if input.KeyCode==KEYBINDS.INFJUMP then tog("InfJump") end
    if input.KeyCode==KEYBINDS.ESP then tog("ESP",function() toggleESP(true) end,function() toggleESP(false) end) end
    if input.KeyCode==KEYBINDS.HOVER then tog("Hover",function() ToggleHover(true) end,function() ToggleHover(false) end) end
    if input.KeyCode==KEYBINDS.SPEEDMETER then tog("SpeedMeter",function() toggleSpeedMeter(true) end,function() toggleSpeedMeter(false) end) end
    if input.KeyCode==KEYBINDS.STATS then tog("Stats") if StatsFrame then StatsFrame.Visible=Enabled.Stats end end
end)
UserInputService.InputEnded:Connect(function(input) if input.KeyCode==Enum.KeyCode.Space then spaceHeld=false end end)

Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Enabled.SpinBot then stopSpinBot() task.wait(0.1) startSpinBot() end
    if Enabled.Galaxy then setupGalaxyForce() adjustGalaxyJump() end
    if Enabled.SpamBat then stopSpamBat() task.wait(0.1) startSpamBat() end
    if Enabled.BatAimbot then stopBatAimbot() task.wait(0.1) startBatAimbot() end
    if Enabled.Unwalk then startUnwalk() end
    if Enabled.Hover then ToggleHover(true) end
    if Enabled.SpeedMeter then toggleSpeedMeter(false) task.wait(0.1) toggleSpeedMeter(true) end
    if Enabled.SpeedBoost then stopSpeedBoost() task.wait(0.1) startSpeedBoost() end
    if Enabled.SpeedWhileStealing then stopSpeedWhileStealing() task.wait(0.1) startSpeedWhileStealing() end
    if Enabled.AntiRagdoll then stopAntiRagdoll() task.wait(0.1) startAntiRagdoll() end
    if Enabled.AutoWalkEnabled then stopAutoWalk() task.wait(0.1) startAutoWalk() end
    if Enabled.AutoRightEnabled then stopAutoRight() task.wait(0.1) startAutoRight() end
    if Enabled.AutoPlayLeftEnabled then stopAutoPlayLeft() task.wait(0.1) startAutoPlayLeft() end
    if Enabled.AutoPlayRightEnabled then stopAutoPlayRight() task.wait(0.1) startAutoPlayRight() end
end)
end)
