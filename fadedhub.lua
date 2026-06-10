pcall(function() setfpscap(9999) end)
if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local StarterGui          = game:GetService("StarterGui")
local Lighting            = game:GetService("Lighting")
local Debris              = game:GetService("Debris")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = Instance.new("VirtualInputManager")

local lp = Players.LocalPlayer
if not lp.Character then lp.CharacterAdded:Wait() end

local AutoBlockEnabled        = true
local AutoTPEnabled           = false
local RagdollBypassEnabled    = true
local AutoSelectBestBrainrot  = false
local AntiAdminEnabled        = true
local AutoResetBalloonEnabled = false
local AimbotEnabled           = true
local AimbotRange             = 350
local AimbotTarget            = nil
local AimbotRemote            = nil
local AutoGrabEnabled         = false
local SABAllowEnabled         = false
local isStealing              = false
local __AG_stealCbCache  = {}
local __AG_stealActive   = false
local __AG_MIN_HOLD_TIME = 1.3
local __AG_TRIGGER_DELAY = 0.04

local CONFIG_PATH = "VertxedHub_config.json"
local Config = {toggles={}, keybinds={}}

local function FH_Serialize()
	local function enc(v)
		local t=type(v)
		if t=="boolean" then return v and "true" or "false"
		elseif t=="number" then return tostring(v)
		elseif t=="string" then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"')..'"'
		elseif t=="table" then
			local p={}
			for k,val in pairs(v) do p[#p+1]='"'..tostring(k)..'":'..enc(val) end
			return "{"..table.concat(p,",").."}"
		end
		return "null"
	end
	return enc({toggles=Config.toggles,keybinds=Config.keybinds})
end
local function FH_Parse(str)
	local pos=1
	local function sk() while pos<=#str and str:sub(pos,pos):match("%s") do pos=pos+1 end end
	local pv
	local function ps()
		pos=pos+1; local s=""
		while pos<=#str do
			local c=str:sub(pos,pos)
			if c=='"' then pos=pos+1; return s end
			if c=='\\' then pos=pos+1; local e=str:sub(pos,pos); s=s..(e=='"' and '"' or e=='\\' and '\\' or e=='n' and '\n' or e)
			else s=s..c end; pos=pos+1
		end; return s
	end
	local function po()
		pos=pos+1; local t={}; sk()
		if str:sub(pos,pos)=="}" then pos=pos+1; return t end
		while true do
			sk(); local k=ps(); sk(); pos=pos+1; sk()
			t[k]=pv(); sk()
			if str:sub(pos,pos)=="}" then pos=pos+1; return t end
			pos=pos+1
		end
	end
	pv=function()
		sk(); local c=str:sub(pos,pos)
		if c=='"' then return ps()
		elseif c=='{' then return po()
		elseif c=='t' then pos=pos+4; return true
		elseif c=='f' then pos=pos+5; return false
		elseif c=='n' then pos=pos+4; return nil
		else local n=str:match("^-?%d+%.?%d*",pos); if n then pos=pos+#n; return tonumber(n) end end
	end
	local ok,r=pcall(pv); return (ok and type(r)=="table") and r or nil
end
local function FH_Save() pcall(writefile,CONFIG_PATH,FH_Serialize()) end
local function FH_Load()
	local ok,d=pcall(function() return FH_Parse(readfile(CONFIG_PATH)) end)
	if ok and type(d)=="table" then
		if type(d.toggles)=="table" then Config.toggles=d.toggles end
		if type(d.keybinds)=="table" then Config.keybinds=d.keybinds end
	end
end
FH_Load()

local AntiRagdoll={connections={},running=false}
AntiRagdoll.forceBackpack=function()
	if not AntiRagdoll.running then return end
	local gui=lp:FindFirstChild("PlayerGui"); if not gui then return end
	local bg=gui:FindFirstChild("BackpackGui"); if not bg then return end
	local bp=bg:FindFirstChild("Backpack"); if not bp then return end
	bp.Visible=true
	if not bp:FindFirstChild("ForceConnection") then
		local tag=Instance.new("BoolValue"); tag.Name="ForceConnection"; tag.Parent=bp
		bp:GetPropertyChangedSignal("Visible"):Connect(function()
			if AntiRagdoll.running and not bp.Visible then bp.Visible=true end
		end)
	end
end
AntiRagdoll.removeConstraints=function(char)
	for _,d in ipairs(char:GetDescendants()) do
		if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")
		or d:IsA("NoCollisionConstraint")
		or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then d:Destroy() end
	end
end
AntiRagdoll.resetChar=function(char)
	local hum=char:FindFirstChildOfClass("Humanoid")
	local root=char:FindFirstChild("HumanoidRootPart")
	if root then root.Anchored=false; root.Velocity=Vector3.zero end
	if hum then
		for _,o in ipairs(char:GetDescendants()) do
			if o:IsA("Motor6D") and not o.Enabled then o.Enabled=true end
		end
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		hum.PlatformStand=false; hum.Sit=false
		if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
		workspace.CurrentCamera.CameraSubject=hum
	end
end
AntiRagdoll.enable=function()
	if AntiRagdoll.running then return end
	AntiRagdoll.running=true
	AntiRagdoll.connections.hb=RunService.Heartbeat:Connect(function()
		local char=lp.Character; if not char then return end
		local hum=char:FindFirstChildOfClass("Humanoid")
		local root=char:FindFirstChild("HumanoidRootPart")
		if not (hum and root) then return end
		local s=hum:GetState()
		if s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll
		or s==Enum.HumanoidStateType.FallingDown then
			pcall(function() lp:SetAttribute("RagdollEndTime",workspace:GetServerTimeNow()) end)
			AntiRagdoll.removeConstraints(char)
			for _,o in ipairs(char:GetDescendants()) do
				if o:IsA("Motor6D") and not o.Enabled then o.Enabled=true end
			end
			if hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
			workspace.CurrentCamera.CameraSubject=hum
			root.Anchored=false; root.Velocity=Vector3.zero
		end
	end)
	AntiRagdoll.connections.ca=lp.CharacterAdded:Connect(function(char)
		task.wait(1); AntiRagdoll.forceBackpack()
		char:WaitForChild("HumanoidRootPart")
		local hum=char:WaitForChild("Humanoid")
		AntiRagdoll.connections.cda=char.DescendantAdded:Connect(function(obj)
			if not AntiRagdoll.running then return end
			if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint")
			or (obj:IsA("Attachment") and obj.Name:find("RagdollAttachment")) then
				task.defer(function() if obj.Parent then obj:Destroy() end end)
			end
		end)
		hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
			if AntiRagdoll.running and hum.PlatformStand then
				task.defer(function() AntiRagdoll.resetChar(char); AntiRagdoll.removeConstraints(char) end)
			end
		end)
		AntiRagdoll.removeConstraints(char); AntiRagdoll.resetChar(char)
	end)
	if lp.Character then
		AntiRagdoll.removeConstraints(lp.Character); AntiRagdoll.resetChar(lp.Character)
	end
	task.spawn(function()
		while AntiRagdoll.running do task.wait(0.5); AntiRagdoll.forceBackpack() end
	end)
end
AntiRagdoll.disable=function()
	AntiRagdoll.running=false
	for _,c in pairs(AntiRagdoll.connections) do pcall(function() c:Disconnect() end) end
	AntiRagdoll.connections={}
end
-- controlled by toggle only, does NOT auto-start

do
	local scaleNames={"HeadScale","BodyDepthScale","BodyHeightScale","BodyProportionScale","BodyTypeScale","BodyWidthScale"}
	local origScales={}; local origHipH=nil; local antiGummyGrace=0
	local function captureOriginals()
		local char=lp.Character; if not char then return end
		local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		origHipH=hum.HipHeight; origScales={}
		for _,n in ipairs(scaleNames) do
			local sv=hum:FindFirstChild(n); if sv then origScales[n]=sv.Value end
		end
	end
	lp.CharacterAdded:Connect(function(char)
		local hum=char:WaitForChild("Humanoid",5)
		if hum then antiGummyGrace=tick()+1.5 end
		task.wait(0.1); captureOriginals()
	end)
	task.spawn(captureOriginals)
	local _ctrlCache; local _charController; local _jumpscareMod
	local function getCtrl()
		if _ctrlCache then return _ctrlCache end
		local ps=lp:FindFirstChild("PlayerScripts")
		local pm=ps and ps:FindFirstChild("PlayerModule"); if not pm then return nil end
		local ok,m=pcall(require,pm); if not ok then return nil end
		local ok2,c=pcall(function() return m:GetControls() end)
		if ok2 and c then _ctrlCache=c end; return _ctrlCache
	end
	lp.CharacterAdded:Connect(function() _ctrlCache=nil end)
	local function tryCC()
		if _charController~=nil then return _charController end
		local ok,mod=pcall(function()
			return require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("CharacterController"))
		end)
		_charController=ok and mod or false; return _charController
	end
	local function tryJS()
		if _jumpscareMod~=nil then return _jumpscareMod end
		local ok,mod=pcall(function()
			return require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("AdminCommands"):WaitForChild("jumpscare"))
		end)
		_jumpscareMod=ok and mod or false; return _jumpscareMod
	end
	local beeBlacklist={"BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","PostEffect"}
	local function isBeeEffect(obj)
		for _,n in ipairs(beeBlacklist) do if obj:IsA(n) then return true end end; return false
	end
	local function clearBeeEffects()
		for _,v in pairs(Lighting:GetDescendants()) do if isBeeEffect(v) then pcall(function() v:Destroy() end) end end
	end
	clearBeeEffects()
	Lighting.DescendantAdded:Connect(function(obj) task.wait(); if isBeeEffect(obj) then pcall(function() obj:Destroy() end) end end)
	RunService.Heartbeat:Connect(function()
		local char=lp.Character; if not char then return end
		for _,obj in ipairs(char:GetDescendants()) do
			local nl=obj.Name:lower()
			if nl:find("bee") or nl:find("invert") or nl:find("reverse") or nl:find("confuse") then
				pcall(function() obj:Destroy() end)
			end
		end
		local hum=char:FindFirstChildOfClass("Humanoid")
		local root=char:FindFirstChild("HumanoidRootPart")
		if hum and root and hum.MoveDirection.Magnitude>0.1 then
			local md=hum.MoveDirection
			local vel=Vector3.new(root.Velocity.X,0,root.Velocity.Z)
			if vel.Magnitude>3 and md:Dot(vel.Unit)<-0.5 then
				root.Velocity=Vector3.new(md.X*16,root.Velocity.Y,md.Z*16)
			end
		end
	end)
	task.spawn(function()
		while task.wait(0.1) do
			if not AntiAdminEnabled then continue end
			local char=lp.Character; if not char then continue end
			local hum=char:FindFirstChildOfClass("Humanoid")
			local hrp=char:FindFirstChild("HumanoidRootPart")
			if not hum or not hrp then continue end
			for _,v in ipairs(char:GetDescendants()) do
				if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then v:Destroy()
				elseif v:IsA("Motor6D") then v.Enabled=true end
			end
			local ctrl=getCtrl()
			if ctrl then pcall(function() ctrl:Enable() end) end
			local cc=tryCC()
			if cc and ctrl then ctrl.moveFunction=function(p,x,z) cc:RequestMove(p,x,z) end end
			local jm=tryJS()
			if jm and jm.effects and jm.effects.Victim then jm.effects.Victim=function() end end
			local st=hum:GetState()
			if st~=Enum.HumanoidStateType.Running and st~=Enum.HumanoidStateType.Jumping
			and st~=Enum.HumanoidStateType.Freefall then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
			end
			if workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject~=hum then
				workspace.CurrentCamera.CameraSubject=hum
			end
			local re=lp:GetAttribute("RagdollEndTime") or 0
			if re>workspace:GetServerTimeNow() then hrp.Velocity=Vector3.zero; lp:SetAttribute("RagdollEndTime",0) end
			if tick()>antiGummyGrace then
				if origHipH and hum.HipHeight~=origHipH then hum.HipHeight=origHipH end
				for _,n in ipairs(scaleNames) do
					local sv=hum:FindFirstChild(n)
					if sv and origScales[n] and sv.Value~=origScales[n] then sv.Value=origScales[n] end
				end
			end
			for _,v in ipairs(char:GetChildren()) do
				if v:IsA("Model") and not v:IsA("BackpackItem") then v:Destroy() end
			end
		end
	end)
end

do
	local function findAimbotRemote()
		local net=ReplicatedStorage:FindFirstChild("Packages")
		if net then net=net:FindFirstChild("Net") end; if not net then return end
		local ch=net:GetChildren()
		for i,obj in ipairs(ch) do
			if obj.Name=="RE/UseItem" then AimbotRemote=ch[i+1]; break end
		end
	end
	local function hookAimbotTool(tool)
		tool.Activated:Connect(function()
			if not AimbotEnabled then return end
			local tgt=AimbotTarget; if not tgt or not tgt.Character then return end
			local part=tgt.Character:FindFirstChild("HumanoidRootPart") or tgt.Character:FindFirstChild("Head")
			if part and AimbotRemote then pcall(function() AimbotRemote:FireServer(part.Position,part) end) end
		end)
	end
	findAimbotRemote()
	if lp.Character then
		for _,t in ipairs(lp.Character:GetChildren()) do if t:IsA("Tool") then pcall(hookAimbotTool,t) end end
	end
	lp.CharacterAdded:Connect(function(chr)
		task.wait(0.5)
		for _,t in ipairs(chr:GetChildren()) do if t:IsA("Tool") then pcall(hookAimbotTool,t) end end
	end)
	workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("Tool") and obj:IsDescendantOf(lp.Character or {}) then
			task.wait(0.1); pcall(hookAimbotTool,obj)
		end
	end)
	RunService.Heartbeat:Connect(function()
		if not AimbotEnabled then return end
		local chr=lp and lp.Character
		local hrp=chr and chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local nearest=nil; local best=AimbotRange
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=lp and p.Character then
				local h=p.Character:FindFirstChild("HumanoidRootPart")
				if h then
					local d=(h.Position-hrp.Position).Magnitude
					if d<best then best=d; nearest=p end
				end
			end
		end
		AimbotTarget=nearest
	end)
end

do
	local SENTRY_DETECT_DIST=200
	local sentryFirstSeen={}
	local sentryTarget=nil
	local function findSentryTarget()
		local chr=lp.Character; if not chr then return nil end
		local hrp=chr:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
		local rootPos=hrp.Position; local now=tick()
		for obj in pairs(sentryFirstSeen) do if not obj.Parent then sentryFirstSeen[obj]=nil end end
		for _,obj in pairs(workspace:GetChildren()) do
			if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
				local ownerId=obj.Name:match("Sentry_(%d+)")
				if ownerId and tonumber(ownerId)==lp.UserId then continue end
				local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
				if part and (rootPos-part.Position).Magnitude<=SENTRY_DETECT_DIST then
					if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=now end
					if now-sentryFirstSeen[obj]>=3.5 then
						pcall(function()
							if obj:IsA("Model") then
								for _,p2 in ipairs(obj:GetDescendants()) do if p2:IsA("BasePart") then p2.CanCollide=false end end
							elseif obj:IsA("BasePart") then obj.CanCollide=false end
							obj:Destroy()
						end)
						sentryFirstSeen[obj]=nil
					end
				end
			end
		end
	end
	task.spawn(function()
		task.wait(1)
		for _,obj in pairs(workspace:GetChildren()) do
			if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
				local ownerId=obj.Name:match("Sentry_(%d+)")
				if not (ownerId and tonumber(ownerId)==lp.UserId) then
					sentryFirstSeen[obj]=tick()-3.5
				end
			end
		end
	end)
	workspace.DescendantAdded:Connect(function(obj)
		if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
			local ownerId=obj.Name:match("Sentry_(%d+)")
			if not (ownerId and tonumber(ownerId)==lp.UserId) then
				if not sentryFirstSeen[obj] then sentryFirstSeen[obj]=tick() end
			end
		end
	end)
	RunService.Heartbeat:Connect(function()
		findSentryTarget()
	end)
end

local amirResetRemote=nil
local amirResetCooldown=false
pcall(function()
	if not hookfunction then return end
	local origFire
	origFire=hookfunction(Instance.new("RemoteEvent").FireServer,newcclosure(function(self,...)
		if not amirResetRemote and type(self.Name)=="string" and self.Name:sub(1,3)=="RE/" then
			amirResetRemote=self
		end
		return origFire(self,...)
	end))
end)

local function doReset()
	if amirResetCooldown then return end
	if amirResetRemote then
		amirResetCooldown=true
		local oldChar=lp.Character
		task.spawn(function()
			while lp.Character==oldChar do
				pcall(function() amirResetRemote:FireServer("f888ee6e-c86d-46e1-93d7-0639d6635d42",lp,"balloon") end)
				task.wait()
			end
			amirResetCooldown=false
		end)
		return
	end
	local Net=ReplicatedStorage:WaitForChild("Packages",2) and ReplicatedStorage.Packages:WaitForChild("Net",2)
	if not Net then
		local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
		if h then h.Health=0 end; return
	end
	local remote; local ch=Net:GetChildren()
	for i=1,#ch-1 do
		if ch[i] and ch[i+1] and string.find(ch[i].Name,"Tools/Cooldown") then remote=ch[i+1]; break end
	end
	if not remote then
		local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
		if h then h.Health=0 end; return
	end
	local saved={}; local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
	if char then
		local hum=char:FindFirstChildOfClass("Humanoid")
		if hum then pcall(function() hum:UnequipTools() end) end
		for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(saved,t); t.Parent=nil end end
	end
	if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(saved,t); t.Parent=nil end end end
	lp.Character=nil; local sending=true; local lc; local fire=remote.FireServer; local thr=0
	lc=RunService.Heartbeat:Connect(function(dt)
		if not sending then if lc then lc:Disconnect(); lc=nil end; return end
		thr=thr+dt; if thr>=0.1 then thr=0
			pcall(fire,remote,"f888ee6e-c86d-46e1-93d7-0639d6635d42",lp,"balloon")
		end
		if sending and lp.Character then lp.Character=nil end
	end)
	local cn; cn=lp.CharacterAdded:Connect(function()
		sending=false; if lc then lc:Disconnect(); lc=nil end; if cn then cn:Disconnect() end
		task.spawn(function()
			local nb=lp:WaitForChild("Backpack",3)
			if nb then for _,t in ipairs(saved) do if t then t.Parent=nb end end end; saved={}
		end)
	end)
	task.delay(4,function()
		sending=false; if lc then lc:Disconnect(); lc=nil end
		local cb=lp:FindFirstChild("Backpack")
		if cb and #saved>0 then for _,t in ipairs(saved) do if t then t.Parent=cb end end; saved={} end
	end)
end
_G._FH_DoSelectedReset=doReset

do
	local _arbConns={}; local _arbBound={}; local _arbConn; local _arbLast=0
	local function bindRemote(obj)
		if not obj:IsA("RemoteEvent") then return end
		if _arbBound[obj] then return end
		local ok,conn=pcall(function()
			return obj.OnClientEvent:Connect(function(...)
				if not AutoResetBalloonEnabled then return end
				for i=1,select("#",...) do
					local a=select(i,...)
					if type(a)=="string" and a:lower():find("jump higher",1,true) then
						local now=tick(); if now-_arbLast<3 then return end; _arbLast=now; doReset(); return
					end
				end
			end)
		end)
		if ok and conn then table.insert(_arbConns,conn); _arbBound[obj]=true end
	end
	local function startARB()
		for _,c in ipairs(_arbConns) do pcall(function() c:Disconnect() end) end
		_arbConns={}; _arbBound={}
		if _arbConn then pcall(function() _arbConn:Disconnect() end); _arbConn=nil end
		_arbConn=ReplicatedStorage.DescendantAdded:Connect(function(obj) if AutoResetBalloonEnabled then bindRemote(obj) end end)
		task.spawn(function()
			for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do
				if not AutoResetBalloonEnabled then break end; bindRemote(obj)
			end
		end)
	end
	local function stopARB()
		for _,c in ipairs(_arbConns) do pcall(function() c:Disconnect() end) end
		_arbConns={}; _arbBound={}
		if _arbConn then pcall(function() _arbConn:Disconnect() end); _arbConn=nil end
	end
	_G._ARB_Start=startARB; _G._ARB_Stop=stopARB
end

local function drawClickDot(x,y)
	if not Drawing then return end
	local dot=Drawing.new("Circle")
	dot.Radius=5; dot.Position=Vector2.new(x,y)
	dot.Color=Color3.fromRGB(80,140,255); dot.Filled=true
	dot.Visible=true; dot.Transparency=0.6
	task.delay(0.25,function() dot:Remove() end)
end

local function getPlotOwnerPlayer()
	local sel=_G._FH_SelectedBrainrot
	if not sel or not sel.plotName then return nil end
	local pf=workspace:FindFirstChild("Plots"); if not pf then return nil end
	local plot=pf:FindFirstChild(sel.plotName); if not plot then return nil end
	local sign=plot:FindFirstChild("PlotSign",true); local ownerName
	if sign then
		for _,d in ipairs(sign:GetDescendants()) do
			if d:IsA("TextLabel") and d.Text and d.Text~="" and not d.Text:lower():find("empty") then
				local m=d.Text:match("[Bb]ase [Oo]f%s+(.+)")
				if m then ownerName=m; break end
				if #d.Text>0 and #d.Text<30 then ownerName=d.Text; break end
			end
		end
	end
	if not ownerName then return nil end
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=lp and (p.Name==ownerName or p.DisplayName==ownerName) then return p end
	end
	return nil
end

local function getNearestPlayer()
	local chr=lp and lp.Character
	local hrp=chr and chr:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
	local nearest=nil; local best=math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=lp then
			local c=p.Character; local h=c and c:FindFirstChild("HumanoidRootPart")
			if h then
				local d=(h.Position-hrp.Position).Magnitude
				if d<best then best=d; nearest=p end
			end
		end
	end
	return nearest
end

local function blockPlayer(target)
	if not target then return end
	pcall(function() StarterGui:SetCore("PromptBlockPlayer",target) end)
	local cam=workspace.CurrentCamera; if not cam then return end
	local vp=cam.ViewportSize
	local x=math.floor(vp.X/2)+math.random(-1,1)
	local y=math.floor(vp.Y/2+30)+math.random(-1,1)
	local chr=lp and lp.Character; local blockers={}
	if chr then
		for _,t in ipairs(chr:GetChildren()) do
			if t:IsA("Tool") then
				local blocked=true
				local conn=t.Activated:Connect(function() if blocked then return end end)
				table.insert(blockers,{conn=conn,ub=function() blocked=false end})
			end
		end
	end
	task.wait(0.03+math.random()*0.02)
	drawClickDot(x,y)
	pcall(function() VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,1) end)
	task.wait(0.006+math.random()*0.006)
	pcall(function() VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,1) end)
	task.delay(0.05,function()
		for _,b in ipairs(blockers) do b.ub(); pcall(function() b.conn:Disconnect() end) end
	end)
end

local function getBlockDelay()
	local ping=0
	pcall(function() ping=lp:GetNetworkPing() or 0 end)
	return math.clamp(0.08+ping,0.08,0.30)
end

local function triggerAutoBlock()
	if not AutoBlockEnabled then return end
	task.spawn(function()
		task.wait(getBlockDelay())
		if not AutoBlockEnabled then return end -- re-check after delay
		local target=getPlotOwnerPlayer() or getNearestPlayer()
		if target and AutoBlockEnabled then pcall(blockPlayer,target) end
	end)
end

local function __AG_buildCbs(prompt)
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

local function __AG_startHold(prompt)
	if not prompt or not prompt.Parent then return nil end
	local cb=__AG_buildCbs(prompt); if not cb then return nil end
	__AG_stealActive=true
	for _,fn in ipairs(cb.hold) do task.spawn(fn) end
	return {cb=cb,holdBeganAt=tick(),holdDone=false}
end

local function __AG_finish(ctx)
	if not ctx then return false end
	local held=tick()-(ctx.holdBeganAt or tick())
	if held<__AG_MIN_HOLD_TIME then task.wait(__AG_MIN_HOLD_TIME-held) end
	task.wait(__AG_TRIGGER_DELAY)
	for _,fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
	__AG_stealActive=false; return true
end

local function __AG_findPrompt()
	local sel=_G._FH_SelectedBrainrot
	if not sel or not sel.plotName or not sel.slot then return nil end
	local pf=workspace:FindFirstChild("Plots"); if not pf then return nil end
	local plot=pf:FindFirstChild(sel.plotName); if not plot then return nil end
	local podiums=plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
	local podium=podiums:FindFirstChild(tostring(sel.slot)); if not podium then return nil end
	local base=podium:FindFirstChild("Base")
	local spwn=base and base:FindFirstChild("Spawn")
	local pa=spwn and spwn:FindFirstChild("PromptAttachment")
	local prompt=pa and pa:FindFirstChildWhichIsA("ProximityPrompt")
	if prompt then
		prompt.RequiresLineOfSight=false
		prompt.MaxActivationDistance=math.huge
	end
	return prompt
end

-- ── HSV helpers + theme system ──────────────────────────────────────────
local _AccentH=285; local _AccentS=0.80; local _AccentV=0.92
local _AccentH2=330
local function hsvToRgb(h,s,v)
	h=h%1; if h<0 then h=h+1 end
	local i=math.floor(h*6); local f=h*6-i
	local p=v*(1-s); local q=v*(1-f*s); local t2=v*(1-(1-f)*s)
	local m=i%6
	local r,g,b
	if m==0 then r,g,b=v,t2,p
	elseif m==1 then r,g,b=q,v,p
	elseif m==2 then r,g,b=p,v,t2
	elseif m==3 then r,g,b=p,q,v
	elseif m==4 then r,g,b=t2,p,v
	else r,g,b=v,p,q end
	return Color3.new(math.clamp(r,0,1),math.clamp(g,0,1),math.clamp(b,0,1))
end
local function getAccent()       return hsvToRgb(_AccentH/360,_AccentS,_AccentV) end
local function getAccentBright()  return hsvToRgb(_AccentH/360,_AccentS*0.5,1) end
local function getAccentDim()     return hsvToRgb(_AccentH/360,_AccentS*0.4,0.55) end
local function getAccent2()       return hsvToRgb(_AccentH2/360,_AccentS*0.88,_AccentV) end
local function mixC(a,b,t) return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t) end

local T={
	BG          = Color3.fromRGB(8,   5,   12),
	Header      = Color3.fromRGB(5,   3,   9),
	Card        = Color3.fromRGB(15,  11,  22),
	CardHover   = Color3.fromRGB(24,  17,  36),
	Border      = Color3.fromRGB(52,  30,  74),
	BorderHover = Color3.fromRGB(140, 55,  185),
	White       = Color3.fromRGB(238, 228, 255),
	Dim         = Color3.fromRGB(108, 80,  140),
	Accent      = Color3.fromRGB(185, 55,  255),
	AccentBright= Color3.fromRGB(222, 130, 255),
	AccentDim   = Color3.fromRGB(95,  38,  132),
	Accent2     = Color3.fromRGB(255, 70,  175),
	TabActive   = Color3.fromRGB(238, 228, 255),
	TabInact    = Color3.fromRGB(62,  43,  88),
	TrackOn     = Color3.fromRGB(185, 55,  255),
	TrackOff    = Color3.fromRGB(28,  18,  44),
	KnobOn      = Color3.fromRGB(240, 195, 255),
	KnobOff     = Color3.fromRGB(78,  56,  105),
	Green       = Color3.fromRGB(52,  218, 88),
	Red         = Color3.fromRGB(255, 65,  65),
	Pink        = Color3.fromRGB(255, 70,  175),
}

local _themeListeners={}
local function onThemeChange(fn) table.insert(_themeListeners,fn) end
local function applyTheme()
	T.Accent=getAccent(); T.AccentBright=getAccentBright()
	T.AccentDim=getAccentDim(); T.Accent2=getAccent2(); T.Pink=T.Accent2
	T.TrackOn=T.Accent; T.KnobOn=T.AccentBright
	T.Border=mixC(Color3.fromRGB(30,18,46),T.Accent,0.30)
	T.BorderHover=mixC(T.Accent,Color3.new(1,1,1),0.22)
	T.Dim=mixC(Color3.fromRGB(55,36,72),T.AccentBright,0.30)
	T.TabInact=mixC(Color3.fromRGB(38,26,56),T.AccentDim,0.45)
	for _,fn in ipairs(_themeListeners) do pcall(fn) end
end

local F=TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local M=TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local function Tween(o,i,p) TweenService:Create(o,i,p):Play() end
local function Corner(p,r)
	local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c
end
local function Stroke(p,col,th)
	local s=Instance.new("UIStroke"); s.Color=col or T.Border
	s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s
end
local function Padding(p,t,b,l,r)
	local u=Instance.new("UIPadding")
	u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or 0)
	u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0); u.Parent=p
end
local function Label(p,txt,sz,col,font)
	local l=Instance.new("TextLabel")
	l.Text=txt or ""; l.TextSize=sz or 13; l.TextColor3=col or T.White
	l.Font=font or Enum.Font.GothamMedium; l.BackgroundTransparency=1
	l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=p; return l
end

local isMobile=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

pcall(function()
	for _,g in ipairs(game.CoreGui:GetChildren()) do
		if g.Name=="GammaHub" or g.Name=="VertxedHub" then g:Destroy() end
	end
end)

local GUI=Instance.new("ScreenGui")
GUI.Name="GammaHub"; GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn=false; GUI.IgnoreGuiInset=true
if not pcall(function() GUI.Parent=game.CoreGui end) then
	GUI.Parent=lp:WaitForChild("PlayerGui")
end

local WIN_W=isMobile and 210 or 236
local WIN_H=isMobile and 300 or 318
local HDR_H=isMobile and 48 or 54
local BIG_BTN_H=26
local BIG_BTN_TOP=HDR_H+6
local TOTAL_TOP=HDR_H+BIG_BTN_H+12
local TAB_H=24
local FULL_H=WIN_H
local FOLD_H=HDR_H+BIG_BTN_H+14

local Win=Instance.new("Frame")
Win.Name="Win"; Win.Size=UDim2.new(0,WIN_W,0,FULL_H)
Win.AnchorPoint=Vector2.new(0.5,0.5); Win.Position=UDim2.new(0.5,0,0.5,0)
Win.BackgroundColor3=T.BG; Win.BackgroundTransparency=0.03
Win.BorderSizePixel=0; Win.ZIndex=2; Win.Parent=GUI
Corner(Win,12)
local WinStroke=Instance.new("UIStroke")
WinStroke.Thickness=1.5; WinStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
WinStroke.Color=T.AccentBright; WinStroke.Parent=Win
local BorderGrad=Instance.new("UIGradient")
BorderGrad.Rotation=0; BorderGrad.Parent=WinStroke
local function refreshBorderGrad()
	BorderGrad.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,   T.Accent),
		ColorSequenceKeypoint.new(0.5, T.Accent2),
		ColorSequenceKeypoint.new(1.0, T.Accent),
	})
end
refreshBorderGrad()
onThemeChange(refreshBorderGrad)
-- left accent bar (unique visual touch)
local LeftBar=Instance.new("Frame"); LeftBar.Size=UDim2.new(0,2,1,-20)
LeftBar.Position=UDim2.new(0,0,0,10); LeftBar.BackgroundColor3=T.Accent
LeftBar.BorderSizePixel=0; LeftBar.ZIndex=3; LeftBar.Parent=Win; Corner(LeftBar,2)
local LBGrad=Instance.new("UIGradient"); LBGrad.Rotation=90; LBGrad.Parent=LeftBar
local function refreshLeftBar()
	LBGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(0.5,T.Accent2),ColorSequenceKeypoint.new(1,T.Accent)})
	LeftBar.BackgroundColor3=T.Accent
end
refreshLeftBar(); onThemeChange(refreshLeftBar)
local winScale=Instance.new("UIScale"); winScale.Scale=1; winScale.Parent=Win

local Hdr=Instance.new("Frame")
Hdr.Name="Hdr"; Hdr.Size=UDim2.new(1,0,0,HDR_H)
Hdr.BackgroundColor3=T.Header; Hdr.BackgroundTransparency=0.02
Hdr.BorderSizePixel=0; Hdr.ZIndex=5; Hdr.Parent=Win; Hdr.Active=true
Corner(Hdr,12)
local HdrFill=Instance.new("Frame")
HdrFill.Size=UDim2.new(1,0,0,12); HdrFill.Position=UDim2.new(0,0,1,-12)
HdrFill.BackgroundColor3=T.Header; HdrFill.BackgroundTransparency=0.02
HdrFill.BorderSizePixel=0; HdrFill.ZIndex=5; HdrFill.Parent=Hdr
-- glow line under header
local HdrGlow=Instance.new("Frame"); HdrGlow.Size=UDim2.new(0.65,0,0,1)
HdrGlow.Position=UDim2.new(0.175,0,1,-1); HdrGlow.BackgroundColor3=T.Accent
HdrGlow.BorderSizePixel=0; HdrGlow.ZIndex=6; HdrGlow.Parent=Hdr; Corner(HdrGlow,1)
local HGGrad=Instance.new("UIGradient"); HGGrad.Parent=HdrGlow
HGGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
onThemeChange(function() HdrGlow.BackgroundColor3=T.Accent end)

local TitleLbl=Label(Hdr,"",15,T.White,Enum.Font.GothamBold)
TitleLbl.RichText=true; TitleLbl.Size=UDim2.new(1,-72,0,18)
TitleLbl.Position=UDim2.new(0,12,0,5); TitleLbl.ZIndex=6
local function refreshTitle()
	local a=T.Accent; local b=T.Accent2
	TitleLbl.Text=('  <font color="rgb(%d,%d,%d)">Gamma</font><font color="rgb(%d,%d,%d)">Pvp</font>'):format(
		math.floor(a.R*255),math.floor(a.G*255),math.floor(a.B*255),
		math.floor(b.R*255),math.floor(b.G*255),math.floor(b.B*255))
end
refreshTitle(); onThemeChange(refreshTitle)

local DiscordLbl=Label(Hdr,".gg/gammahub",isMobile and 7 or 8,T.Dim,Enum.Font.Gotham)
DiscordLbl.Size=UDim2.new(1,-72,0,11); DiscordLbl.Position=UDim2.new(0,12,0,26)
DiscordLbl.ZIndex=6; DiscordLbl.TextTruncate=Enum.TextTruncate.AtEnd
onThemeChange(function() DiscordLbl.TextColor3=T.Dim end)

local HdrBtnRow=Instance.new("Frame")
HdrBtnRow.Size=UDim2.new(0,0,0,17); HdrBtnRow.Position=UDim2.new(1,-8,0,5)
HdrBtnRow.AnchorPoint=Vector2.new(1,0)
HdrBtnRow.AutomaticSize=Enum.AutomaticSize.X
HdrBtnRow.BackgroundTransparency=1; HdrBtnRow.ZIndex=7; HdrBtnRow.Parent=Hdr
local HdrBtnLayout=Instance.new("UIListLayout")
HdrBtnLayout.FillDirection=Enum.FillDirection.Horizontal
HdrBtnLayout.VerticalAlignment=Enum.VerticalAlignment.Center
HdrBtnLayout.SortOrder=Enum.SortOrder.LayoutOrder
HdrBtnLayout.Padding=UDim.new(0,4); HdrBtnLayout.Parent=HdrBtnRow

local function makeHdrIconBtn(txt,order)
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(0,20,0,17); btn.LayoutOrder=order
	btn.BackgroundColor3=T.Card; btn.BorderSizePixel=0; btn.AutoButtonColor=false
	btn.Text=txt; btn.TextSize=9; btn.Font=Enum.Font.GothamBold
	btn.TextColor3=T.Dim; btn.ZIndex=8; btn.Active=true; btn.Parent=HdrBtnRow
	Corner(btn,5)
	local s=Stroke(btn,T.Border,1)
	onThemeChange(function() if btn.BackgroundColor3==T.Card or btn.BackgroundColor3==T.CardHover then s.Color=T.Border end end)
	btn.MouseEnter:Connect(function() Tween(btn,F,{BackgroundColor3=T.CardHover}) end)
	btn.MouseLeave:Connect(function() Tween(btn,F,{BackgroundColor3=T.Card}) end)
	return btn,s
end

local lockBtn,lockStroke=makeHdrIconBtn("🔒",1)
local _guiLocked=true
lockBtn.Text="🔒"
lockBtn.BackgroundColor3=Color3.fromRGB(120,30,30)
lockStroke.Color=Color3.fromRGB(200,50,50)
lockBtn.MouseButton1Click:Connect(function()
	_guiLocked=not _guiLocked
	if _guiLocked then
		lockBtn.Text="🔒"
		Tween(lockBtn,F,{BackgroundColor3=Color3.fromRGB(120,30,30)})
		Tween(lockStroke,F,{Color=Color3.fromRGB(200,50,50)})
	else
		lockBtn.Text="🔓"
		Tween(lockBtn,F,{BackgroundColor3=T.Card})
		Tween(lockStroke,F,{Color=T.Border})
	end
end)

local foldBtn,foldStroke=makeHdrIconBtn("▼",2)
local _guiFolded=false

local closeBtn,closeStroke=makeHdrIconBtn("✕",3)
local _minimized=false; local _miniFrame=nil

local BigBtnRow=Instance.new("Frame")
BigBtnRow.Size=UDim2.new(1,-14,0,BIG_BTN_H)
BigBtnRow.Position=UDim2.new(0,7,0,BIG_BTN_TOP)
BigBtnRow.BackgroundTransparency=1; BigBtnRow.ZIndex=5; BigBtnRow.Parent=Win
local BigBtnLayout=Instance.new("UIListLayout")
BigBtnLayout.FillDirection=Enum.FillDirection.Horizontal
BigBtnLayout.VerticalAlignment=Enum.VerticalAlignment.Center
BigBtnLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
BigBtnLayout.SortOrder=Enum.SortOrder.LayoutOrder
BigBtnLayout.Padding=UDim.new(0,5); BigBtnLayout.Parent=BigBtnRow

local function makeBigBtn(txt,order,getColFn)
	local btn=Instance.new("TextButton")
	btn.Name="BigBtn_"..txt
	btn.Size=UDim2.new(0,0,0,BIG_BTN_H); btn.AutomaticSize=Enum.AutomaticSize.X
	btn.LayoutOrder=order
	btn.BackgroundColor3=T.Card; btn.BorderSizePixel=0; btn.AutoButtonColor=false
	btn.Text=txt; btn.TextSize=11; btn.Font=Enum.Font.GothamBold
	btn.TextColor3=T.White; btn.ZIndex=6; btn.Active=true; btn.Parent=BigBtnRow
	Corner(btn,6)
	local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.Parent=btn
	local s=Stroke(btn,getColFn and getColFn() or T.Accent,1)
	if getColFn then onThemeChange(function() if not btn.Active then return end; s.Color=getColFn() end) end
	local _busy=false
	btn.MouseEnter:Connect(function()
		if _busy then return end
		local c=getColFn and getColFn() or T.AccentBright
		Tween(btn,F,{BackgroundColor3=T.CardHover}); Tween(s,F,{Color=c})
	end)
	btn.MouseLeave:Connect(function()
		if _busy then return end
		local c=getColFn and getColFn() or T.Border
		Tween(btn,F,{BackgroundColor3=T.Card}); Tween(s,F,{Color=c})
	end)
	local function flash()
		_busy=true
		local c=getColFn and getColFn() or T.AccentBright
		Tween(btn,F,{BackgroundColor3=c})
		btn.TextColor3=Color3.fromRGB(8,5,14)
		task.delay(0.18,function()
			Tween(btn,M,{BackgroundColor3=T.Card})
			btn.TextColor3=T.White; _busy=false
		end)
	end
	return btn,s,flash
end

local flashBtn,flashBtnStroke,flashBtnFlash=makeBigBtn("FLASH",1,getAccent)
local blockBtn,blockBtnStroke,blockBtnFlash=makeBigBtn("BLOCK",2,getAccent2)
local resetBtn,resetBtnStroke,resetBtnFlash=makeBigBtn("RESET",3,getAccentDim)

local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,0,0,TAB_H); TabBar.Position=UDim2.new(0,0,0,TOTAL_TOP)
TabBar.BackgroundColor3=Color3.fromRGB(7,7,12); TabBar.BackgroundTransparency=0.08
TabBar.BorderSizePixel=0; TabBar.ZIndex=4; TabBar.Parent=Win
local TBLine=Instance.new("Frame")
TBLine.Size=UDim2.new(1,0,0,1); TBLine.Position=UDim2.new(0,0,0,TOTAL_TOP+TAB_H-1)
TBLine.BackgroundColor3=T.Border; TBLine.BorderSizePixel=0; TBLine.ZIndex=5; TBLine.Parent=Win
local TabLayout=Instance.new("UIListLayout")
TabLayout.FillDirection=Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment=Enum.VerticalAlignment.Center
TabLayout.Padding=UDim.new(0,0); TabLayout.Parent=TabBar
local ContentArea=Instance.new("Frame")
ContentArea.Size=UDim2.new(1,0,1,-(TOTAL_TOP+TAB_H+1))
ContentArea.Position=UDim2.new(0,0,0,TOTAL_TOP+TAB_H+1)
ContentArea.BackgroundTransparency=1; ContentArea.ClipsDescendants=true
ContentArea.ZIndex=2; ContentArea.Parent=Win

do
	local dragging=false; local dragStart=nil; local winStart=nil; local _moved=false
	local function onBegan(inp)
		if _guiLocked then return end
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			dragging=true; _moved=false; dragStart=inp.Position; winStart=Win.Position
		end
	end
	local function onEnded(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			dragging=false; _moved=false
		end
	end
	Win.InputBegan:Connect(onBegan); Win.InputEnded:Connect(onEnded)
	Hdr.InputBegan:Connect(onBegan); Hdr.InputEnded:Connect(onEnded)
	UserInputService.InputChanged:Connect(function(inp)
		if not dragging then return end
		if inp.UserInputType==Enum.UserInputType.MouseMovement
		or inp.UserInputType==Enum.UserInputType.Touch then
			if not dragStart or not winStart then return end
			local d=inp.Position-dragStart
			if not _moved and d.Magnitude<4 then return end
			_moved=true
			Win.Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,winStart.Y.Scale,winStart.Y.Offset+d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(onEnded)
end

local FOLD_OUT=TweenInfo.new(0.26,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local FOLD_IN =TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.In)

foldBtn.MouseButton1Click:Connect(function()
	_guiFolded=not _guiFolded
	local savedPos=Win.Position
	if _guiFolded then
		foldBtn.Text="▲"
		TabBar.Visible=false; ContentArea.Visible=false; TBLine.Visible=false
		local tw=TweenService:Create(Win,FOLD_IN,{Size=UDim2.new(0,WIN_W,0,FOLD_H)})
		tw:Play()
		tw.Completed:Connect(function() Win.Position=savedPos end)
	else
		foldBtn.Text="▼"
		local tw=TweenService:Create(Win,FOLD_OUT,{Size=UDim2.new(0,WIN_W,0,FULL_H)})
		tw:Play()
		Win.Position=savedPos
		task.delay(0.10,function()
			TabBar.Visible=true; ContentArea.Visible=true; TBLine.Visible=true
			Win.Position=savedPos
		end)
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	if not _minimized then
		_minimized=true; Win.Visible=false
		if _miniFrame then _miniFrame:Destroy() end
		_miniFrame=Instance.new("TextButton")
		_miniFrame.Size=UDim2.new(0,72,0,22)
		_miniFrame.Position=UDim2.new(0,8,0.5,-11)
		_miniFrame.BackgroundColor3=T.Card
		_miniFrame.BorderSizePixel=0; _miniFrame.Text="Vertex Pvp"
		_miniFrame.TextSize=9; _miniFrame.Font=Enum.Font.GothamBold
		_miniFrame.TextColor3=T.White; _miniFrame.ZIndex=50
		_miniFrame.AutoButtonColor=false; _miniFrame.Parent=GUI
		Corner(_miniFrame,6); Stroke(_miniFrame,T.AccentBright,1.2)
		local _mts
		_miniFrame.InputBegan:Connect(function(inp)
			if inp.UserInputType==Enum.UserInputType.Touch
			or inp.UserInputType==Enum.UserInputType.MouseButton1 then _mts=inp.Position end
		end)
		_miniFrame.InputEnded:Connect(function(inp)
			if (inp.UserInputType==Enum.UserInputType.Touch
			or inp.UserInputType==Enum.UserInputType.MouseButton1) and _mts then
				local mag=(inp.Position-_mts).Magnitude; _mts=nil
				if mag<20 then
					_minimized=false; Win.Visible=true
					_miniFrame:Destroy(); _miniFrame=nil
				end
			end
		end)
	end
end)

local configRegistry={}
local keybindEntries={}

local CreateToggle,CreateSection,CreateButton,MakeScroll

MakeScroll=function(parent)
	local s=Instance.new("ScrollingFrame"); s.Size=UDim2.new(1,0,1,0)
	s.BackgroundTransparency=1; s.BorderSizePixel=0; s.ScrollBarThickness=3
	s.ScrollBarImageColor3=T.Accent; s.CanvasSize=UDim2.new(0,0,0,0)
	s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.ScrollingDirection=Enum.ScrollingDirection.Y
	s.ZIndex=2; s.Parent=parent
	local l=Instance.new("UIListLayout"); l.FillDirection=Enum.FillDirection.Vertical
	l.HorizontalAlignment=Enum.HorizontalAlignment.Center; l.Padding=UDim.new(0,4); l.Parent=s
	Padding(s,7,7,5,5); return s
end

CreateSection=function(parent,title)
	local f=Instance.new("Frame"); f.Size=UDim2.new(1,-12,0,18); f.BackgroundTransparency=1; f.Parent=parent
	local lw=#title*6+6
	local lbl=Label(f,title,9,T.Dim,Enum.Font.GothamBold)
	lbl.Size=UDim2.new(0,lw,1,0); lbl.Position=UDim2.new(0,4,0,0)
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=2
	local line=Instance.new("Frame"); line.Size=UDim2.new(1,-(lw+12),0,1)
	line.Position=UDim2.new(0,lw+8,0.5,0); line.BackgroundColor3=T.Border
	line.BorderSizePixel=0; line.Parent=f
end

CreateToggle=function(parent,name,desc,cb,startState)
	local state=(startState~=nil) and startState or (Config.toggles[name]==true)
	local hasDesc=desc and desc~=""
	local cardH=hasDesc and 44 or 36
	local card=Instance.new("Frame"); card.Size=UDim2.new(1,-12,0,cardH)
	card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
	card.BorderSizePixel=0; card.Parent=parent; Corner(card,7)
	local cStroke=Stroke(card,T.Border,1)
	onThemeChange(function() if not state then cStroke.Color=T.Border end end)
	local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,2,0,cardH-14)
	bar.Position=UDim2.new(0,0,0,7); bar.BackgroundColor3=T.TrackOff
	bar.BorderSizePixel=0; bar.ZIndex=2; bar.Parent=card; Corner(bar,2)
	local nameY=hasDesc and 6 or (cardH/2-7)
	local nl=Label(card,name,isMobile and 10 or 11,T.White,Enum.Font.GothamMedium)
	nl.Size=UDim2.new(1,-54,0,14); nl.Position=UDim2.new(0,10,0,nameY)
	nl.ZIndex=2; nl.TextTruncate=Enum.TextTruncate.AtEnd
	if hasDesc then
		local dl=Label(card,desc,isMobile and 8 or 9,T.Dim,Enum.Font.Gotham)
		dl.Size=UDim2.new(1,-54,0,11); dl.Position=UDim2.new(0,10,0,nameY+15)
		dl.ZIndex=2; dl.TextTruncate=Enum.TextTruncate.AtEnd
		onThemeChange(function() dl.TextColor3=T.Dim end)
	end
	local track=Instance.new("Frame"); track.Size=UDim2.new(0,34,0,18)
	track.Position=UDim2.new(1,-42,0.5,-9); track.BackgroundColor3=T.TrackOff
	track.BorderSizePixel=0; track.ZIndex=2; track.Parent=card; Corner(track,9)
	local tStroke=Stroke(track,T.Border,1)
	local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,12,0,12)
	knob.Position=UDim2.new(0,3,0.5,-6); knob.BackgroundColor3=T.KnobOff
	knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=track; Corner(knob,6)
	card.MouseEnter:Connect(function() Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end)
	card.MouseLeave:Connect(function() Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=state and T.Accent or T.Border}) end)
	local btn=Instance.new("Frame"); btn.Size=UDim2.new(1,0,1,0)
	btn.BackgroundTransparency=1; btn.ZIndex=4; btn.Active=true; btn.Parent=card
	local keybindEntry={keyCode=nil}
	local function applyV(s)
		if s then
			knob.Position=UDim2.new(0,19,0.5,-6); knob.BackgroundColor3=T.KnobOn
			track.BackgroundColor3=T.TrackOn; tStroke.Color=T.TrackOn
			bar.BackgroundColor3=T.Accent; cStroke.Color=T.Accent
		else
			knob.Position=UDim2.new(0,3,0.5,-6); knob.BackgroundColor3=T.KnobOff
			track.BackgroundColor3=T.TrackOff; tStroke.Color=T.Border
			bar.BackgroundColor3=T.TrackOff; cStroke.Color=T.Border
		end
	end
	onThemeChange(function()
		if state then
			track.BackgroundColor3=T.TrackOn; tStroke.Color=T.TrackOn
			bar.BackgroundColor3=T.Accent; cStroke.Color=T.Accent; knob.BackgroundColor3=T.KnobOn
		else
			track.BackgroundColor3=T.TrackOff; tStroke.Color=T.Border
			bar.BackgroundColor3=T.TrackOff; cStroke.Color=T.Border; knob.BackgroundColor3=T.KnobOff
		end
	end)
	local function doToggle()
		state=not state
		if state then
			Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0,4,0.5,-5)})
			task.delay(0.06,function()
				Tween(knob,M,{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,19,0.5,-6)})
				Tween(knob,M,{BackgroundColor3=T.KnobOn}); Tween(track,M,{BackgroundColor3=T.TrackOn})
				Tween(tStroke,M,{Color=T.TrackOn}); Tween(bar,M,{BackgroundColor3=T.Accent})
				Tween(cStroke,M,{Color=T.Accent})
			end)
		else
			Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0,18,0.5,-5)})
			task.delay(0.06,function()
				Tween(knob,M,{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,3,0.5,-6)})
				Tween(knob,M,{BackgroundColor3=T.KnobOff}); Tween(track,M,{BackgroundColor3=T.TrackOff})
				Tween(tStroke,M,{Color=T.Border}); Tween(bar,M,{BackgroundColor3=T.TrackOff})
				Tween(cStroke,M,{Color=T.Border})
			end)
		end
		if cb then pcall(cb,state) end
		Config.toggles[name]=state; pcall(FH_Save)
	end
	local _bta=false; local _bts=nil
	btn.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			_bta=true; _bts=inp.Position
		end
	end)
	btn.InputEnded:Connect(function(inp)
		if (inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch) and _bta then
			_bta=false
			if _bts and (inp.Position-_bts).Magnitude<20 then doToggle() end
			_bts=nil
		end
	end)
	table.insert(keybindEntries,{entry=keybindEntry,fire=doToggle})
	configRegistry[name]={
		getState=function() return state end,
		getKeyCode=function() return keybindEntry.keyCode end,
		setKeyCode=function(kc)
			keybindEntry.keyCode=kc
			if kc then Config.keybinds[name]=kc.Name
			else Config.keybinds[name]=nil end; pcall(FH_Save)
		end,
		doToggle=doToggle,
		setEnabled=function(v)
			state=v; applyV(v); Config.toggles[name]=v; pcall(FH_Save)
			if cb then pcall(cb,v) end
		end,
	}
	if state then applyV(true); task.spawn(function() pcall(cb,true) end) end
end

CreateButton=function(parent,name,desc,cb)
	local hasDesc=desc and desc~=""
	local cardH=hasDesc and 46 or 36
	local card=Instance.new("Frame"); card.Size=UDim2.new(1,-12,0,cardH)
	card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
	card.BorderSizePixel=0; card.Parent=parent; Corner(card,7)
	local cStroke=Stroke(card,T.Border,1)
	local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,2,0,cardH-14)
	bar.Position=UDim2.new(0,0,0,7); bar.BackgroundColor3=T.TrackOff
	bar.BorderSizePixel=0; bar.ZIndex=2; bar.Parent=card; Corner(bar,2)
	local nameY=hasDesc and 6 or (cardH/2-7)
	local nl2=Label(card,name,isMobile and 10 or 11,T.White,Enum.Font.GothamMedium)
	nl2.Size=UDim2.new(1,-58,0,14); nl2.Position=UDim2.new(0,10,0,nameY)
	nl2.ZIndex=2; nl2.TextTruncate=Enum.TextTruncate.AtEnd
	if hasDesc then
		local dl2=Label(card,desc,isMobile and 8 or 9,T.Dim,Enum.Font.Gotham)
		dl2.Size=UDim2.new(1,-58,0,11); dl2.Position=UDim2.new(0,10,0,nameY+15)
		dl2.ZIndex=2; dl2.TextTruncate=Enum.TextTruncate.AtEnd
	end
	local runLbl=Instance.new("TextLabel"); runLbl.Size=UDim2.new(0,40,0,18)
	runLbl.Position=UDim2.new(1,-46,0.5,-9); runLbl.BackgroundColor3=T.Card
	runLbl.BorderSizePixel=0; runLbl.Text="RUN"; runLbl.TextSize=9
	runLbl.Font=Enum.Font.GothamBold; runLbl.TextColor3=T.White
	runLbl.TextXAlignment=Enum.TextXAlignment.Center; runLbl.ZIndex=3; runLbl.Parent=card; Corner(runLbl,5)
	local runStroke=Stroke(runLbl,T.Border,1)
	card.MouseEnter:Connect(function() Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}); Tween(runLbl,F,{BackgroundColor3=T.CardHover}) end)
	card.MouseLeave:Connect(function() Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}); Tween(runLbl,F,{BackgroundColor3=T.Card}) end)
	local btn2=Instance.new("Frame"); btn2.Size=UDim2.new(1,0,1,0)
	btn2.BackgroundTransparency=1; btn2.ZIndex=4; btn2.Active=true; btn2.Parent=card
	local ke2={keyCode=nil}
	local function fireButton()
		Tween(bar,F,{BackgroundColor3=T.Accent}); Tween(runLbl,F,{BackgroundColor3=T.AccentBright})
		Tween(runStroke,F,{Color=T.AccentBright}); runLbl.TextColor3=Color3.fromRGB(10,10,20)
		task.spawn(function() pcall(cb) end)
		task.delay(0.28,function()
			Tween(bar,M,{BackgroundColor3=T.TrackOff}); Tween(runLbl,M,{BackgroundColor3=T.Card})
			Tween(runStroke,M,{Color=T.Border}); runLbl.TextColor3=T.White
		end)
	end
	local deb=false; local _ats2=nil
	btn2.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 then
			if deb then return end; deb=true; fireButton(); task.delay(0.4,function() deb=false end)
		elseif inp.UserInputType==Enum.UserInputType.Touch then _ats2=inp.Position end
	end)
	btn2.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.Touch and _ats2 then
			local m=(inp.Position-_ats2).Magnitude; _ats2=nil
			if m<20 then if deb then return end; deb=true; fireButton(); task.delay(0.4,function() deb=false end) end
		end
	end)
	table.insert(keybindEntries,{entry=ke2,fire=fireButton})
	configRegistry[name]={getState=function() return false end,getKeyCode=function() return ke2.keyCode end,setKeyCode=function(kc)
		ke2.keyCode=kc
		if kc then Config.keybinds[name]=kc.Name
		else Config.keybinds[name]=nil end; pcall(FH_Save)
	end}
end

local Tabs={}; local ActiveTab=nil; local TabSwiping=false
local SLIDE_IN=TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local SLIDE_OUT=TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local function TabIndex(t) for i,v in ipairs(Tabs) do if v==t then return i end end; return 0 end
local function ActivateTab(tab)
	if ActiveTab==tab then return end; if TabSwiping then return end
	local old=ActiveTab; ActiveTab=tab
	if old then Tween(old.lbl,F,{TextColor3=T.TabInact}); Tween(old.indicator,M,{Size=UDim2.new(0,0,0,2)}) end
	Tween(tab.lbl,F,{TextColor3=T.TabActive}); Tween(tab.indicator,M,{Size=UDim2.new(0.8,0,0,2)})
	if old then
		TabSwiping=true
		local goRight=(TabIndex(tab)>TabIndex(old))
		tab.page.Position=goRight and UDim2.new(1,0,0,0) or UDim2.new(-1,0,0,0); tab.page.Visible=true
		local exitPos=goRight and UDim2.new(-1,0,0,0) or UDim2.new(1,0,0,0)
		Tween(old.page,SLIDE_OUT,{Position=exitPos})
		local tw=TweenService:Create(tab.page,SLIDE_IN,{Position=UDim2.new(0,0,0,0)})
		tw:Play(); tw.Completed:Connect(function() old.page.Visible=false; old.page.Position=UDim2.new(0,0,0,0); TabSwiping=false end)
	else tab.page.Position=UDim2.new(0,0,0,0); tab.page.Visible=true end
end
local function CreateTab(name)
	local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0.5,0,1,0)
	btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=5; btn.Parent=TabBar
	local lbl=Label(btn,name,isMobile and 8 or 9,T.TabInact,Enum.Font.GothamBold)
	lbl.Size=UDim2.new(1,-2,1,0); lbl.Position=UDim2.new(0,1,0,0)
	lbl.TextXAlignment=Enum.TextXAlignment.Center; lbl.TextWrapped=true; lbl.ZIndex=6
	local sc=Instance.new("UITextSizeConstraint"); sc.MaxTextSize=9; sc.MinTextSize=5; sc.Parent=lbl
	local ind=Instance.new("Frame"); ind.Size=UDim2.new(0,0,0,2); ind.Position=UDim2.new(0.1,0,1,-2)
	ind.BackgroundColor3=T.Accent; ind.BorderSizePixel=0; ind.ZIndex=7; ind.Parent=btn; Corner(ind,1)
	local page=Instance.new("Frame"); page.Size=UDim2.new(1,0,1,0); page.Position=UDim2.new(0,0,0,0)
	page.BackgroundTransparency=1; page.Visible=false; page.ClipsDescendants=true
	page.ZIndex=2; page.Parent=ContentArea
	local scroll=MakeScroll(page)
	local tab={btn=btn,lbl=lbl,indicator=ind,page=page,scroll=scroll}
	btn.MouseButton1Click:Connect(function() ActivateTab(tab) end)
	table.insert(Tabs,tab); return tab
end

local BrainrotsTab=CreateTab("BRAINROTS")
local SettingsTab=CreateTab("SETTINGS")

local timerESPs={}
local ECOL_R=Color3.fromRGB(255,65,65)
local ECOL_Y=Color3.fromRGB(100,180,255)
local ECOL_G=Color3.fromRGB(60,160,255)
task.spawn(function()
	while task.wait(0.5) do
		local plots=workspace:FindFirstChild("Plots"); if not plots then continue end
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
					bb.Size=UDim2.fromOffset(58,16); bb.StudsOffset=Vector3.new(0,8,0)
					bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
					local outer=Instance.new("Frame",bb)
					outer.Size=UDim2.new(1,0,1,0); outer.BackgroundColor3=T.BG
					outer.BackgroundTransparency=0.12; outer.BorderSizePixel=0; Corner(outer,5)
					local leftPill=Instance.new("Frame",outer)
					leftPill.Size=UDim2.new(0,3,0.7,0); leftPill.Position=UDim2.new(0,2,0.15,0)
					leftPill.BackgroundColor3=ECOL_Y; leftPill.BorderSizePixel=0; Corner(leftPill,2)
					local tl=Instance.new("TextLabel",outer)
					tl.Size=UDim2.new(1,-8,1,0); tl.Position=UDim2.new(0,7,0,0)
					tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold
					tl.TextSize=8; tl.TextColor3=ECOL_Y
					tl.TextXAlignment=Enum.TextXAlignment.Left
					timerESPs[plot.Name]={bb=bb,lbl=tl,pill=leftPill,outer=outer}; e=timerESPs[plot.Name]
				end
				e.lbl.Text=tl2.Text
				local m2,s2=tl2.Text:match("(%d+):(%d+)")
				if m2 and s2 then
					local tot=tonumber(m2)*60+tonumber(s2)
					local col=tot<=30 and ECOL_R or tot<=120 and ECOL_Y or ECOL_G
					e.lbl.TextColor3=col; e.pill.BackgroundColor3=col
				end
			else
				local e=timerESPs[plot.Name]
				if e then pcall(function() e.bb:Destroy() end); timerESPs[plot.Name]=nil end
			end
		end
	end
end)

local ESPTAG="VxE_"..tostring(math.random(1000,9999))
local function mkESP(plr)
	if plr==lp then return end
	local char=plr.Character; if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart")
	local head=char:FindFirstChild("Head")
	if not hrp or char:FindFirstChild(ESPTAG) then return end
	local box=Instance.new("BoxHandleAdornment",char)
	box.Name=ESPTAG; box.Adornee=hrp; box.Size=Vector3.new(3.5,5.5,1.8)
	box.Color3=T.Accent; box.Transparency=0.58; box.ZIndex=10; box.AlwaysOnTop=true
	local bb=Instance.new("BillboardGui",char)
	bb.Name=ESPTAG.."N"; bb.Adornee=head or hrp
	bb.Size=UDim2.fromOffset(88,26); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true
	local bgE=Instance.new("Frame",bb)
	bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=T.BG
	bgE.BackgroundTransparency=0.2; bgE.BorderSizePixel=0; Corner(bgE,4)
	local leftBar=Instance.new("Frame",bgE)
	leftBar.Size=UDim2.new(0,2,0.75,0); leftBar.Position=UDim2.new(0,2,0.125,0)
	leftBar.BackgroundColor3=T.Accent; leftBar.BorderSizePixel=0; Corner(leftBar,1)
	local nl=Instance.new("TextLabel",bgE)
	nl.Size=UDim2.new(1,-6,0.58,0); nl.Position=UDim2.new(0,6,0,1)
	nl.BackgroundTransparency=1; nl.Text=plr.DisplayName
	nl.Font=Enum.Font.GothamBold; nl.TextSize=8; nl.TextColor3=T.White
	nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.TextXAlignment=Enum.TextXAlignment.Left
	local sl=Instance.new("TextLabel",bgE)
	sl.Size=UDim2.new(1,-6,0.42,0); sl.Position=UDim2.new(0,6,0.58,0)
	sl.BackgroundTransparency=1; sl.Text="@"..plr.Name
	sl.Font=Enum.Font.Gotham; sl.TextSize=7; sl.TextColor3=T.Dim
	sl.TextXAlignment=Enum.TextXAlignment.Left; sl.TextTruncate=Enum.TextTruncate.AtEnd
	local apBB=Instance.new("BillboardGui",char)
	apBB.Name=ESPTAG.."AP"; apBB.Adornee=hrp
	apBB.Size=UDim2.fromOffset(28,10); apBB.StudsOffset=Vector3.new(0,-3.8,0); apBB.AlwaysOnTop=true
	local apF=Instance.new("Frame",apBB)
	apF.Size=UDim2.new(1,0,1,0); apF.BackgroundColor3=T.Card
	apF.BackgroundTransparency=0.15; apF.BorderSizePixel=0; Corner(apF,3)
	local apL=Instance.new("TextLabel",apF)
	apL.Size=UDim2.new(1,0,1,0); apL.BackgroundTransparency=1
	apL.Text="AP?"; apL.Font=Enum.Font.GothamBold; apL.TextSize=6
	apL.TextColor3=T.Dim; apL.TextXAlignment=Enum.TextXAlignment.Center
	task.spawn(function()
		task.wait(0.8)
		local hasAP=false
		pcall(function()
			local pg=lp:FindFirstChild("PlayerGui"); if not pg then return end
			local ap=pg:FindFirstChild("AdminPanel"); if not ap then return end
			local plist=ap:FindFirstChild("Profiles",true)
			if plist and plist:FindFirstChild(plr.Name) then hasAP=true end
		end)
		if hasAP then
			apF.BackgroundColor3=Color3.fromRGB(6,22,10)
			Stroke(apF,T.Green,0.8)
			apL.TextColor3=T.Green; apL.Text="AP ✓"
		else
			apF.BackgroundColor3=Color3.fromRGB(22,6,6)
			Stroke(apF,T.Red,0.8)
			apL.TextColor3=T.Red; apL.Text="AP ✗"
		end
	end)
end
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then task.defer(function() mkESP(p) end) end end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end)
for _,p in ipairs(Players:GetPlayers()) do
	if p~=lp then p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end
end

local ADM_REMOTE=nil
local ADM_UUID="f888ee6e-c86d-46e1-93d7-0639d6635d42"
task.spawn(function()
	pcall(function() if not lp.Character then lp.CharacterAdded:Wait() end end)
	task.wait(1.5)
	pcall(function()
		local net=ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
		local ch=net:GetChildren(); local n2i={}
		for i,o in ipairs(ch) do n2i[o.Name]=i end
		local a=n2i["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
		if a and ch[a+1] then ADM_REMOTE=ch[a+1] end
	end)
end)
local ROW_CD={ragdoll=30,balloon=30,tiny=60,jail=60,rocket=120}
local rowCdEnd={}
local function fpFireCmd(tgt,cmd)
	if not ADM_REMOTE then return end
	task.spawn(function() pcall(function() ADM_REMOTE:InvokeServer(ADM_UUID,tgt,cmd) end) end)
	rowCdEnd[cmd]=tick()+(ROW_CD[cmd] or 30)
end

local progressBarGui=nil
local progressFill=nil
local percentLabel=nil
local progressContainer=nil

local function ensureProgressBar()
	if progressBarGui and progressBarGui.Parent then return end
	progressBarGui=Instance.new("ScreenGui")
	progressBarGui.Name="VxProgressBar"; progressBarGui.ResetOnSpawn=false
	progressBarGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; progressBarGui.IgnoreGuiInset=true
	if not pcall(function() progressBarGui.Parent=game.CoreGui end) then
		progressBarGui.Parent=lp:WaitForChild("PlayerGui")
	end
	progressContainer=Instance.new("Frame")
	progressContainer.Size=UDim2.fromOffset(190,14)
	progressContainer.Position=UDim2.new(0.5,-95,1,-33)
	progressContainer.BackgroundColor3=Color3.fromRGB(8,8,14)
	progressContainer.BackgroundTransparency=0.12
	progressContainer.BorderSizePixel=0; Corner(progressContainer,5)
	progressContainer.Visible=false; progressContainer.Parent=progressBarGui
	Stroke(progressContainer,T.AccentBright,0.9)
	progressFill=Instance.new("Frame")
	progressFill.Size=UDim2.new(0,0,1,0)
	progressFill.BackgroundColor3=T.Accent
	progressFill.BorderSizePixel=0; Corner(progressFill,4)
	progressFill.Parent=progressContainer
	local fillGrad=Instance.new("UIGradient")
	fillGrad.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,Color3.fromRGB(60,120,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(120,200,255)),
	}); fillGrad.Parent=progressFill
	percentLabel=Instance.new("TextLabel")
	percentLabel.Size=UDim2.new(1,0,1,0)
	percentLabel.BackgroundTransparency=1
	percentLabel.Font=Enum.Font.GothamBold
	percentLabel.TextSize=8
	percentLabel.TextColor3=T.White
	percentLabel.Text="0%"
	percentLabel.TextXAlignment=Enum.TextXAlignment.Center
	percentLabel.ZIndex=2; percentLabel.Parent=progressContainer
end
ensureProgressBar()

local function updateProgressBar(p)
	if not progressFill or not percentLabel or not progressContainer then return end
	progressContainer.Visible=true
	TweenService:Create(progressFill,TweenInfo.new(0.04),{Size=UDim2.new(p,0,1,0)}):Play()
	percentLabel.Text=math.floor(p*100).."%"
	if p>=0.999 then
		progressFill.BackgroundColor3=T.Green
	elseif p>=0.95 then
		progressFill.BackgroundColor3=Color3.fromRGB(80,200,120)
	else
		progressFill.BackgroundColor3=T.Accent
	end
end
local function hideProgressBar()
	if progressContainer then progressContainer.Visible=false end
	if progressFill then progressFill.Size=UDim2.new(0,0,1,0); progressFill.BackgroundColor3=T.Accent end
	if percentLabel then percentLabel.Text="0%" end
end

local StealData={}
local STEAL_RADIUS=80
local STEAL_DURATION=1.35

local function isMyPlotByName(pn)
	local plots=workspace:FindFirstChild("Plots"); if not plots then return false end
	local plot=plots:FindFirstChild(pn); if not plot then return false end
	local sign=plot:FindFirstChild("PlotSign"); if not sign then return false end
	local yb=sign:FindFirstChild("YourBase")
	if yb and yb:IsA("BillboardGui") then return yb.Enabled==true end
	return false
end

local function getHRP()
	local c=lp.Character
	if c then return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") end
	return nil
end

local function findNearestStealPrompt()
	local hrp=getHRP(); if not hrp then return nil end
	local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
	local nearest,nd=nil,math.huge
	for _,plot in ipairs(plots:GetChildren()) do
		if isMyPlotByName(plot.Name) then continue end
		local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
		for _,pod in ipairs(pods:GetChildren()) do
			local base=pod:FindFirstChild("Base"); if not base then continue end
			local spwn=base:FindFirstChild("Spawn"); if not spwn then continue end
			local d=(spwn.Position-hrp.Position).Magnitude
			if d<=STEAL_RADIUS and d<nd then
				local att=spwn:FindFirstChild("PromptAttachment")
				if att then
					for _,p in ipairs(att:GetChildren()) do
						if p:IsA("ProximityPrompt") and p.ActionText and p.ActionText:find("Steal") then
							nearest=p; nd=d
						end
					end
				end
			end
		end
	end
	return nearest
end

local function executeSteal(prompt)
	if isStealing then return end
	if not StealData[prompt] then
		StealData[prompt]={hold={},trigger={},ready=true}
		if getconnections then
			pcall(function()
				for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
					if c.Function then table.insert(StealData[prompt].hold,c.Function) end
				end
			end)
			pcall(function()
				for _,c in ipairs(getconnections(prompt.Triggered)) do
					if c.Function then table.insert(StealData[prompt].trigger,c.Function) end
				end
			end)
		end
	end
	local data=StealData[prompt]
	if not data.ready then return end
	data.ready=false; isStealing=true

	local CLOSE_DIST=5
	local HOLD_CAP=0.95

	local function getPromptPos()
		-- walk up the tree to find any BasePart ancestor or sibling
		local obj=prompt.Parent
		while obj do
			if obj:IsA("BasePart") then return obj.Position end
			obj=obj.Parent
		end
		-- fallback: search nearby for a BasePart with a Spawn name
		local hrp2=getHRP()
		if hrp2 then return hrp2.Position end
		return nil
	end

	task.spawn(function()
		-- Phase 1: fire hold callbacks, fill bar up to 95% over STEAL_DURATION
		for _,f in ipairs(data.hold) do pcall(f) end

		local startTime=tick()
		while true do
			local elapsed=tick()-startTime
			local raw=math.clamp(elapsed/STEAL_DURATION,0,1)
			local disp=math.min(raw,HOLD_CAP)
			updateProgressBar(disp)
			if disp>=HOLD_CAP then break end
			task.wait()
		end
		-- lock bar at 95% - don't creep up
		updateProgressBar(HOLD_CAP)

		-- Phase 2: sit at 95%, poll every 0.05s for proximity
		local triggered=false
		while not triggered do
			if not prompt or not prompt.Parent then triggered=true; break end
			local hrp2=getHRP()
			local pos=getPromptPos()
			local dist=(hrp2 and pos) and (hrp2.Position-pos).Magnitude or math.huge
			if dist<=CLOSE_DIST then triggered=true end
			if not triggered then
				updateProgressBar(HOLD_CAP) -- stays exactly 95%, no creep
				task.wait(0.05)
			end
		end

		-- Phase 3: fire trigger, snap to 100%
		updateProgressBar(1)
		for _,f in ipairs(data.trigger) do pcall(f) end
		task.wait(0.05)
		-- only block if explicitly enabled right now
		if AutoBlockEnabled==true then
			local target=getPlotOwnerPlayer() or getNearestPlayer()
			if target then task.spawn(function() pcall(blockPlayer,target) end) end
		end
		task.wait(0.2)
		hideProgressBar()
		data.ready=true; isStealing=false
	end)
end

task.spawn(function()
	while true do
		if AutoGrabEnabled then
			local chr=lp.Character; local hum=chr and chr:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health>0 and not isStealing then
				local ok,prompt=pcall(findNearestStealPrompt)
				if ok and prompt then pcall(executeSteal,prompt) end
			end
		else
			hideProgressBar()
		end
		task.wait(0.25)
	end
end)

-- auto balloon removed

local SABAllowGui=nil
local function buildSABGui()
	if SABAllowGui and SABAllowGui.Parent then return end
	SABAllowGui=Instance.new("ScreenGui")
	SABAllowGui.Name="VxSAB"; SABAllowGui.ResetOnSpawn=false; SABAllowGui.IgnoreGuiInset=true
	if not pcall(function() SABAllowGui.Parent=game.CoreGui end) then
		SABAllowGui.Parent=lp:WaitForChild("PlayerGui")
	end
	local onCooldown=false; local COOLDOWN=1.8
	local function findMyPrompt()
		local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
		local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		local best,bestDist=nil,math.huge
		for _,plot in ipairs(plots:GetChildren()) do
			for _,desc in ipairs(plot:GetDescendants()) do
				if desc:IsA("ProximityPrompt") then
					local at=(desc.ActionText or ""):lower()
					local ot=(desc.ObjectText or ""):lower()
					if at:find("allow") or ot:find("allow") then
						local part=desc.Parent
						if part and part:IsA("BasePart") then
							if hrp then
								local d=(hrp.Position-part.Position).Magnitude
								if d<bestDist then bestDist=d; best=desc end
							else
								best=desc
							end
						end
					end
				end
			end
		end
		return best
	end
	local function firePrompt(p2)
		if not pcall(function() fireprompt(p2) end) then
			pcall(function()
				local ok,conns=pcall(getconnections,p2.Triggered)
				if ok and conns then for _,c in ipairs(conns) do pcall(function() c:Fire() end) end end
			end)
		end
	end
	local box=Instance.new("TextButton")
	box.Size=UDim2.fromOffset(64,20)
	box.AnchorPoint=Vector2.new(1,0)
	box.Position=UDim2.new(1,-6,0,6)
	box.BackgroundColor3=T.Dim
	box.BorderSizePixel=0
	box.Text="---"
	box.TextColor3=T.White
	box.Font=Enum.Font.GothamBold
	box.TextSize=9
	box.AutoButtonColor=false
	box.ZIndex=50; box.Parent=SABAllowGui
	Corner(box,5); Stroke(box,T.Border,1)
	local function updateBox()
		if onCooldown then return end
		local p2=findMyPrompt()
		if p2 then
			local at=(p2.ActionText or ""):lower()
			local ot=(p2.ObjectText or ""):lower()
			local isOpen=(at:find("disallow") or ot:find("disallow"))
			if isOpen then
				box.BackgroundColor3=Color3.fromRGB(22,100,38)
				box.Text="Allowed"
				box.TextColor3=T.Green
				TweenService:Create(box:FindFirstChildOfClass("UIStroke"),F,{Color=T.Green}):Play()
			else
				box.BackgroundColor3=Color3.fromRGB(100,18,18)
				box.Text="Disallowed"
				box.TextColor3=T.Red
				TweenService:Create(box:FindFirstChildOfClass("UIStroke"),F,{Color=T.Red}):Play()
			end
		else
			box.BackgroundColor3=T.Card
			box.Text="No Prompt"
			box.TextColor3=T.Dim
			TweenService:Create(box:FindFirstChildOfClass("UIStroke"),F,{Color=T.Border}):Play()
		end
	end
	local function onTap()
		if onCooldown then return end
		local p2=findMyPrompt()
		if p2 then firePrompt(p2) end
		onCooldown=true
		box.Text="..."
		box.BackgroundColor3=T.Card
		task.delay(COOLDOWN,function() onCooldown=false; updateBox() end)
	end
	box.MouseButton1Click:Connect(onTap)
	box.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.Touch then onTap() end
	end)
	updateBox()
	task.spawn(function()
		while SABAllowGui and SABAllowGui.Parent do
			task.wait(1.5); updateBox()
		end
	end)
end

local function doFlash()
	local chr=lp and lp.Character
	local hrp=chr and chr:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local PODIUM_CFRAMES={
		[1]={[1]={hrp=CFrame.new(Vector3.new(-347.6983,-7.5033,-4.5494)),cam=CFrame.new(-357.0927,0.0048,-0.272)*CFrame.Angles(-0.954463,-0.903625,-0.837019)}},
		[2]={
			[1]={hrp=CFrame.new(Vector3.new(-347.8,-7.3,30.9)),cam=CFrame.lookAt(Vector3.new(-362.618,5.041,69.248),Vector3.new(-362.268,4.784,68.347))},
			[2]={hrp=CFrame.new(Vector3.new(-345.1,-7.3,25.7)),cam=CFrame.lookAt(Vector3.new(-354.620,0.536,42.219),Vector3.new(-354.147,0.216,41.399))},
			[3]={hrp=CFrame.new(Vector3.new(-343.5,-7.3,19.4)),cam=CFrame.lookAt(Vector3.new(-356.079,0.311,33.802),Vector3.new(-355.455,0.002,33.084))},
			[4]={hrp=CFrame.new(Vector3.new(-345.2,-7.3,-12.2)),cam=CFrame.lookAt(Vector3.new(-363.864,2.027,-10.458),Vector3.new(-362.943,1.635,-10.459))},
			[5]={hrpWalk=CFrame.new(Vector3.new(-353.7,-7.3,88.4)),hrp=CFrame.new(Vector3.new(-298.9,-7.3,33.0)),cam=CFrame.lookAt(Vector3.new(-297.222,-2.262,52.903),Vector3.new(-297.217,-2.441,51.920))},
			[6]={hrpWalk=CFrame.new(Vector3.new(-347.8,-7.3,86.7)),hrp=CFrame.new(Vector3.new(-301.3,-7.3,65.2)),cam=CFrame.lookAt(Vector3.new(-299.990,0.029,84.914),Vector3.new(-299.970,-0.259,83.956))},
			[7]={hrp=CFrame.new(Vector3.new(-342.8,-6.8,25.6)),cam=CFrame.lookAt(Vector3.new(-361.553,3.228,27.267),Vector3.new(-360.645,2.809,27.271))},
			[8]={hrp=CFrame.new(Vector3.new(-342.8,-6.8,28.0)),cam=CFrame.lookAt(Vector3.new(-361.042,4.173,28.237),Vector3.new(-360.156,3.709,28.227))},
			[9]={hrp=CFrame.new(Vector3.new(-343.8,-7.2,26.4)),cam=CFrame.lookAt(Vector3.new(-361.460,4.701,26.126),Vector3.new(-360.600,4.191,26.139))},
			[10]={hrp=CFrame.new(Vector3.new(-341.0,-7.3,57.9)),cam=CFrame.lookAt(Vector3.new(-345.372,-1.632,77.674),Vector3.new(-345.081,-1.839,76.741))},
			[11]={hrp=CFrame.new(Vector3.new(-355.1,-7.0,-14.0)),cam=CFrame.lookAt(Vector3.new(-360.395,-10.007,-11.958),Vector3.new(-359.631,-9.385,-11.789))},
			[12]={hrpWalk=CFrame.new(Vector3.new(-345.9,-7.0,-30.8)),hrp=CFrame.new(Vector3.new(-337.1,-7.0,-31.5)),cam=CFrame.lookAt(Vector3.new(-341.102,-9.999,-36.639),Vector3.new(-340.600,-9.430,-35.988))},
			[13]={hrpWalk=CFrame.new(Vector3.new(-345.6,-7.0,-30.7)),hrp=CFrame.new(Vector3.new(-334.0,-7.0,-31.2)),cam=CFrame.lookAt(Vector3.new(-339.701,-9.990,-36.359),Vector3.new(-339.060,-9.486,-35.780))},
			[14]={hrpWalk=CFrame.new(Vector3.new(-349.1,-7.0,-29.7)),hrp=CFrame.new(Vector3.new(-333.3,-7.0,-30.3)),cam=CFrame.lookAt(Vector3.new(-340.516,-9.984,-34.987),Vector3.new(-339.772,-9.524,-34.502))},
			[15]={hrpWalk=CFrame.new(Vector3.new(-349.0,-7.0,-30.0)),hrp=CFrame.new(Vector3.new(-320.8,-7.0,-32.2)),cam=CFrame.lookAt(Vector3.new(-327.536,-9.982,-37.998),Vector3.new(-326.855,-9.533,-37.418))},
			[16]={hrp=CFrame.new(Vector3.new(-344.5,-7.0,54.3)),cam=CFrame.lookAt(Vector3.new(-349.080,-9.979,62.669),Vector3.new(-348.643,-9.554,61.876))},
			[17]={hrp=CFrame.new(Vector3.new(-344.3,-7.0,52.8)),cam=CFrame.lookAt(Vector3.new(-351.032,-9.974,61.205),Vector3.new(-350.456,-9.589,60.485))},
			[18]={hrp=CFrame.new(Vector3.new(-344.9,-7.0,46.8)),cam=CFrame.lookAt(Vector3.new(-353.398,-9.976,52.682),Vector3.new(-352.646,-9.578,52.157))},
			[19]={hrp=CFrame.new(Vector3.new(-350.3,-7.0,-8.7)),cam=CFrame.lookAt(Vector3.new(-354.288,-10.030,-7.189),Vector3.new(-353.637,-9.272,-7.157)),needsJump=true},
			[20]={hrpWalk=CFrame.new(Vector3.new(-349.1,-7.0,-30.0)),hrp=CFrame.new(Vector3.new(-324.7,-7.0,-27.9)),cam=CFrame.lookAt(Vector3.new(-326.771,-10.035,-31.306),Vector3.new(-326.706,-9.252,-30.687)),needsJump=true},
			[21]={hrpWalk=CFrame.new(Vector3.new(-349.0,-7.0,-31.9)),hrp=CFrame.new(Vector3.new(-314.2,-7.0,-27.7)),cam=CFrame.lookAt(Vector3.new(-316.112,-10.035,-31.212),Vector3.new(-316.079,-9.251,-30.592)),needsJump=true},
			[22]={hrpWalk=CFrame.new(Vector3.new(-349.0,-7.0,-30.1)),hrp=CFrame.new(Vector3.new(-309.1,-7.0,-28.7)),cam=CFrame.lookAt(Vector3.new(-311.065,-10.042,-31.729),Vector3.new(-311.025,-9.221,-31.160)),needsJump=true},
			[23]={hrpWalk=CFrame.new(Vector3.new(-349.0,-7.0,-23.6)),hrp=CFrame.new(Vector3.new(-302.5,-7.0,-25.9)),cam=CFrame.lookAt(Vector3.new(-305.130,-10.043,-28.340),Vector3.new(-304.963,-9.218,-27.799)),needsJump=true},
			[24]={hrpWalk=CFrame.new(Vector3.new(-344.9,-7.0,75.1)),hrp=CFrame.new(Vector3.new(-328.9,-7.0,46.0)),cam=CFrame.lookAt(Vector3.new(-327.051,-10.023,50.345),Vector3.new(-327.064,-9.303,49.651)),needsJump=true},
			[25]={hrpWalk=CFrame.new(Vector3.new(-344.9,-7.0,75.1)),hrp=CFrame.new(Vector3.new(-321.9,-7.0,46.8)),cam=CFrame.lookAt(Vector3.new(-320.148,-10.018,51.483),Vector3.new(-320.150,-9.328,50.760)),needsJump=true},
			[26]={hrpWalk=CFrame.new(Vector3.new(-344.9,-7.0,75.1)),hrp=CFrame.new(Vector3.new(-314.5,-7.0,46.9)),cam=CFrame.lookAt(Vector3.new(-312.789,-10.006,52.740),Vector3.new(-312.779,-9.391,51.952)),needsJump=true},
			[27]={hrpWalk=CFrame.new(Vector3.new(-344.9,-7.0,75.1)),hrp=CFrame.new(Vector3.new(-307.0,29.9,30.9)),cam=CFrame.lookAt(Vector3.new(-304.999,18.756,44.274),Vector3.new(-305.015,19.442,43.546)),needsJump=true,needsUp=true},
		},
	}

	local myBase
	local plotsFolder=workspace:FindFirstChild("Plots")
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
	if not myBase then return end
	local targetBase=(myBase==1) and 2 or 1
	local podiumCFs=PODIUM_CFRAMES[targetBase]; if not podiumCFs then return end
	local selected=_G._FH_SelectedBrainrot
	if not selected then return end
	local slot=tonumber(selected.slot); if not slot then return end
	local entry=podiumCFs[slot]
	if not entry or not entry.cam then return end

	task.spawn(function()
		local CARPET_SPEED=180
		local ARRIVE_DIST=3.5
		local TIMEOUT=9
		local player=Players.LocalPlayer
		local phase1Pos=(entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
		local phase2Pos=entry.hrp.Position

		local function findTool(kw)
			local c=player.Character; local b=player:FindFirstChild("Backpack")
			if c then for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
			if b then for _,t in ipairs(b:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
		end
		local function doEquip(tool,timeout)
			local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
			if not (c and h) then return end
			if tool.Parent==c then return end
			local done=false; local cn
			cn=tool.Equipped:Connect(function() done=true; cn:Disconnect() end)
			pcall(function() h:EquipTool(tool) end)
			local dl=tick()+(timeout or 0.8)
			while not done and tick()<dl do task.wait() end
			if cn then pcall(function() cn:Disconnect() end) end
		end
		local function travelTo(targetPos,timeout)
			local bc; bc=RunService.Heartbeat:Connect(function()
				if not player.Character then return end
				local h=player.Character:FindFirstChild("HumanoidRootPart")
				local hm=player.Character:FindFirstChildOfClass("Humanoid")
				if not h or not hm then return end
				local diff=targetPos-h.Position; local flat=Vector3.new(diff.X,0,diff.Z)
				if flat.Magnitude>ARRIVE_DIST then
					local dir=flat.Unit; h.Velocity=Vector3.new(dir.X*CARPET_SPEED,h.Velocity.Y,dir.Z*CARPET_SPEED)
				else h.Velocity=Vector3.new(0,h.Velocity.Y,0) end
			end)
			local chr=player.Character; local hum=chr and chr:FindFirstChildOfClass("Humanoid")
			if hum then hum:MoveTo(targetPos) end
			local dl=tick()+(timeout or TIMEOUT); local _lmt=0
			repeat
				task.wait(); chr=player.Character
				local hrp2=chr and chr:FindFirstChild("HumanoidRootPart")
				hum=chr and chr:FindFirstChildOfClass("Humanoid")
				if not (hrp2 and hum) then break end
				if tick()-_lmt>=0.1 then hum:MoveTo(targetPos); _lmt=tick() end
				if (hrp2.Position-targetPos).Magnitude<ARRIVE_DIST then break end
			until tick()>dl
			bc:Disconnect()
			local _c=player.Character; local _h=_c and _c:FindFirstChild("HumanoidRootPart")
			local _hm=_c and _c:FindFirstChildOfClass("Humanoid")
			if _h and _hm then
				_hm:MoveTo(_h.Position); _h.Velocity=Vector3.zero; _h.Anchored=true
				task.defer(function() task.defer(function()
					local c2=player.Character; local h2=c2 and c2:FindFirstChild("HumanoidRootPart")
					if h2 then h2.Velocity=Vector3.zero; h2.Anchored=false end
				end) end)
			end
		end

		local carpet=findTool("flying carpet") or findTool("carpet")
		if carpet then
			doEquip(carpet,0.8)
			pcall(function()
				local v=carpet:FindFirstChild("Speed") or carpet:FindFirstChild("WalkSpeed")
				if v then v.Value=CARPET_SPEED end
			end)
		end

		local stealCtx
		local is3rdFloor=(slot>=19 and slot<=27)
		local is2ndFloor=(slot>=11 and slot<=18)

		if not is3rdFloor and not is2ndFloor then
			task.spawn(function()
				local chr3=player.Character; local hrp3=chr3 and chr3:FindFirstChild("HumanoidRootPart")
				local dist=hrp3 and (hrp3.Position-phase1Pos).Magnitude or 0
				local POST=0.08+0.12+0.06+0.22+0.10
				local pre=math.max(0,(dist/math.max(CARPET_SPEED,1))+POST-__AG_MIN_HOLD_TIME)
				if pre>0 then task.wait(pre) end
				local tp=__AG_findPrompt(); if tp then stealCtx=__AG_startHold(tp) end
			end)
		end

		travelTo(phase1Pos,TIMEOUT)

		if entry.hrpWalk then
			if not is3rdFloor then
				task.spawn(function()
					local chr3=player.Character; local hrp3=chr3 and chr3:FindFirstChild("HumanoidRootPart")
					local dist=hrp3 and (hrp3.Position-phase2Pos).Magnitude or 0
					local POST=0.08+0.12+0.06+0.22+0.10
					local pre=math.max(0,(dist/math.max(CARPET_SPEED,1))+POST-__AG_MIN_HOLD_TIME)
					if pre>0 then task.wait(pre) end
					local tp=__AG_findPrompt(); if tp then stealCtx=__AG_startHold(tp) end
				end)
			end
			travelTo(phase2Pos,TIMEOUT)
		end

		local cam=workspace.CurrentCamera
		if cam and entry.cam then
			cam.CameraType=Enum.CameraType.Scriptable; cam.CFrame=entry.cam
			task.defer(function()
				cam.CFrame=entry.cam
				task.defer(function() cam.CFrame=entry.cam; cam.CameraType=Enum.CameraType.Custom end)
			end)
		end

		local carpetMid=findTool("flying carpet") or findTool("carpet")
		if carpetMid then doEquip(carpetMid,1.0) end

		if is3rdFloor then
			task.spawn(function()
				local chr3=player.Character; local hrp3=chr3 and chr3:FindFirstChild("HumanoidRootPart")
				local dist=hrp3 and (hrp3.Position-phase2Pos).Magnitude or 0
				local POST=0.08+0.12+0.06+0.22+0.10
				local pre=math.max(0,(dist/math.max(CARPET_SPEED,1))+POST-__AG_MIN_HOLD_TIME)
				if pre>0 then task.wait(pre) end
				local tp=__AG_findPrompt(); if tp then stealCtx=__AG_startHold(tp) end
			end)
		end

		task.wait(0.18)

		if entry.needsJump then
			local chr2=player.Character; local hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hum2 then hum2:ChangeState(Enum.HumanoidStateType.Jumping) end
			task.wait(0.08)
		end

		local chr2=player.Character; local hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
		if not (chr2 and hum2) then return end

		local flashTool
		local bp=player:FindFirstChild("Backpack")
		if bp then
			for _,t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool=t; break end
			end
		end
		if not flashTool then
			for _,t in ipairs(chr2:GetChildren()) do
				if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool=t; break end
			end
		end
		if not flashTool then return end

		pcall(function() hum2:UnequipTools() end); task.wait(0.04)

		flashTool.Parent=chr2
		local _fe=false; local _fc
		_fc=flashTool.Equipped:Connect(function() _fe=true; if _fc then _fc:Disconnect(); _fc=nil end end)
		pcall(function() hum2:EquipTool(flashTool) end)
		local _eq=tick()+1.2; while not _fe and tick()<_eq do task.wait() end
		if _fc then pcall(function() _fc:Disconnect() end); _fc=nil end

		if not _fe then
			chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hum2 then
				flashTool.Parent=chr2
				pcall(function() hum2:EquipTool(flashTool) end)
				task.wait(0.12)
			end
		end

		if entry.needsJump then
			chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hum2 then hum2:ChangeState(Enum.HumanoidStateType.Jumping) end
			task.wait(0.05)
		end

		pcall(function() flashTool:Activate() end)
		task.wait(0.012); pcall(function() flashTool:Activate() end)

		task.spawn(function()
			task.wait(0.05)
			if not RagdollBypassEnabled then
				if stealCtx then
					triggerAutoBlock(); __AG_finish(stealCtx)
				else
					local freshPrompt=__AG_findPrompt()
					if freshPrompt then
						stealCtx=__AG_startHold(freshPrompt)
						triggerAutoBlock(); __AG_finish(stealCtx)
					elseif type(_G._sv2DoSteal)=="function" then
						triggerAutoBlock(); pcall(_G._sv2DoSteal)
					end
				end
			end
		end)

		task.wait(0.05)
		if hum2 then pcall(function() hum2:UnequipTools() end) end
		task.wait(0.03)
		local bp2=player:FindFirstChild("Backpack")
		if bp2 and flashTool and flashTool.Parent~=bp2 then flashTool.Parent=bp2 end

		if RagdollBypassEnabled then
			task.spawn(function()
				task.wait(0.06)
				local char=player.Character; if not char then return end
				local hum3=char:FindFirstChildOfClass("Humanoid"); if not hum3 then return end
				local bp3=player:FindFirstChild("Backpack")
				local function findPotion()
					if char:FindFirstChild("Giant Potion") then return char:FindFirstChild("Giant Potion") end
					if bp3 then return bp3:FindFirstChild("Giant Potion") end
					return nil
				end
				local potion=findPotion()
				if potion then
					if potion.Parent~=char then
						potion.Parent=char
						pcall(function() hum3:EquipTool(potion) end)
						task.wait(0.05)
					end
					pcall(function() potion:Activate() end)
					task.wait(0.03)
					if potion.Parent~=bp3 and bp3 then potion.Parent=bp3 end
				end
				task.wait(0.03)
				local _rc={}; local _rp={}
				local function _rca(o)
					local c={}
					local ok2,cs=pcall(getconnections,o.Activated)
					if ok2 and type(cs)=="table" then for _,cx in ipairs(cs) do if type(cx.Function)=="function" then table.insert(c,cx.Function) end end end
					return c
				end
				local function _rfa(c) for _,fn in ipairs(c) do task.spawn(fn) end end
				local function _raf()
					local ap=lp.PlayerGui:FindFirstChild("AdminPanel"); if not ap then return nil,nil end
					local panel=ap:FindFirstChild("AdminPanel"); if not panel then return nil,nil end
					local cont=panel:FindFirstChild("Content"); local prof=panel:FindFirstChild("Profiles")
					if not cont or not prof then return nil,nil end
					return cont:FindFirstChild("ScrollingFrame"),prof:FindFirstChild("ScrollingFrame")
				end
				local cf2,pf2=_raf()
				if not cf2 or not pf2 then
					if stealCtx then triggerAutoBlock(); __AG_finish(stealCtx)
					else
						local fp2=__AG_findPrompt()
						if fp2 then stealCtx=__AG_startHold(fp2); triggerAutoBlock(); __AG_finish(stealCtx) end
					end
					return
				end
				local pn=lp.Name
				local pb2b=pf2:FindFirstChild(pn); local rb2=cf2:FindFirstChild("ragdoll")
				if not pb2b or not rb2 then
					if stealCtx then triggerAutoBlock(); __AG_finish(stealCtx) end; return
				end
				if not _rp[pn] then _rp[pn]=_rca(pb2b) end
				if not _rc["ragdoll"] then _rc["ragdoll"]=_rca(rb2) end
				_rfa(_rc["ragdoll"]); task.wait(); _rfa(_rp[pn])
				triggerAutoBlock()
				local _kicked=false; local _kc1,_kc2
				local _tp2=getPlotOwnerPlayer()
				local _tc2=_tp2 and _tp2.Character
				local _th2=_tc2 and _tc2:FindFirstChildOfClass("Humanoid")
				local function _onK()
					if _kicked then return end; _kicked=true
					if _kc1 then pcall(function() _kc1:Disconnect() end); _kc1=nil end
					if _kc2 then pcall(function() _kc2:Disconnect() end); _kc2=nil end
					local _wf=0; while not stealCtx and _wf<4 do task.wait(); _wf=_wf+1 end
					if not stealCtx then
						local _fp2=__AG_findPrompt()
						if _fp2 then stealCtx=__AG_startHold(_fp2) end
					end
					if stealCtx then __AG_finish(stealCtx)
					elseif type(_G._sv2DoSteal)=="function" then pcall(_G._sv2DoSteal) end
				end
				if _th2 then
					_kc1=_th2.StateChanged:Connect(function(_,new)
						if new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll
						or new==Enum.HumanoidStateType.FallingDown then _onK() end
					end)
					_kc2=_th2:GetPropertyChangedSignal("PlatformStand"):Connect(function()
						if _th2.PlatformStand then _onK() end
					end)
				end
				task.delay(0.4,function() if not _kicked then _onK() end end)
			end)
		end

		local carpetAfter=findTool("flying carpet") or findTool("carpet")
		if carpetAfter then doEquip(carpetAfter,0.7) end
	end)
end
_G._FH_FlashBtnEntry={fire=doFlash}

flashBtn.MouseButton1Click:Connect(function()
	flashBtnFlash(); task.spawn(function() pcall(doFlash) end)
end)
flashBtn.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.Touch then
		flashBtnFlash(); task.spawn(function() pcall(doFlash) end)
	end
end)

blockBtn.MouseButton1Click:Connect(function()
	blockBtnFlash()
	local t=getNearestPlayer()
	if t then pcall(blockPlayer,t) end
end)
blockBtn.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.Touch then
		blockBtnFlash()
		local t=getNearestPlayer(); if t then pcall(blockPlayer,t) end
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	resetBtnFlash(); task.spawn(function() pcall(doReset) end)
end)
resetBtn.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.Touch then
		resetBtnFlash(); task.spawn(function() pcall(doReset) end)
	end
end)
_G._FH_ResetBtnEntry={fire=function() resetBtnFlash(); task.spawn(function() pcall(doReset) end) end}
_G._FH_BlockBtnEntry={fire=function() blockBtnFlash(); local t=getNearestPlayer(); if t then pcall(blockPlayer,t) end end}

do
	local RS2=game:GetService("ReplicatedStorage")
	local AnimalsData,AnimalsShared,NumberUtils
	pcall(function() AnimalsData=require(RS2:WaitForChild("Datas",30):WaitForChild("Animals",30)) end)
	pcall(function() NumberUtils=require(RS2:WaitForChild("Utils",30):WaitForChild("NumberUtils",30)) end)
	pcall(function() AnimalsShared=require(RS2:WaitForChild("Shared",30):WaitForChild("Animals",30)) end)
	local RequestData
	pcall(function()
		local pkg=RS2:WaitForChild("Packages",15):WaitForChild("Synchronizer",15)
		RequestData=pkg:FindFirstChild("RequestData")
	end)
	local PlotSyncCaches={}
	local function fmtNum(n)
		if NumberUtils and NumberUtils.ToString then
			local ok,s=pcall(function() return NumberUtils:ToString(n) end)
			if ok and s then return s end
		end
		return tostring(n)
	end
	local function getGen(idx,mut,traits)
		if not AnimalsShared or not AnimalsShared.GetGeneration then return 0 end
		local ok,v=pcall(function() return AnimalsShared:GetGeneration(idx,mut,traits,nil) end)
		if not ok or not v then ok,v=pcall(function() return AnimalsShared:GetGeneration(idx,mut,nil,nil) end) end
		if not ok or not v then ok,v=pcall(function() return AnimalsShared:GetGeneration(idx) end) end
		return (ok and v) or 0
	end
	local function dispName(idx)
		local info=AnimalsData and AnimalsData[idx]; return (info and info.DisplayName) or tostring(idx)
	end
	local function isMyPlot(plot)
		local sign=plot:FindFirstChild("PlotSign")
		return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled or false
	end
	local function plotOwner(plot)
		local sign=plot:FindFirstChild("PlotSign",true)
		if sign then
			for _,d in ipairs(sign:GetDescendants()) do
				if d:IsA("TextLabel") and d.Text and d.Text~="" then
					if d.Text:lower():find("empty") then return "Empty" end
					local m=d.Text:match("[Bb]ase [Oo]f%s+(.+)"); if m then return m end
					if #d.Text>0 and #d.Text<30 then return d.Text end
				end
			end
		end
		local s2=plot:FindFirstChild("PlotSign")
		return (s2 and s2:FindFirstChild("YourBase") and s2.YourBase.Enabled) and "YOU" or "?"
	end
	local function getPlotOrder(plot)
		local ok,order=pcall(function() return plot:GetAttribute("Order") end)
		if ok and order then return "Base "..tostring(order) end
		return plot.Name
	end
	local function getAnimalList(plot)
		if RequestData then
			PlotSyncCaches[plot.Name]=nil
			local ok,data=pcall(function() return RequestData:InvokeServer(plot.Name) end)
			if ok and typeof(data)=="table" then
				PlotSyncCaches[plot.Name]=data
				if typeof(data.AnimalList)=="table" then return data.AnimalList end
			end
		end
		local cache=PlotSyncCaches[plot.Name]
		if cache and typeof(cache.AnimalList)=="table" then return cache.AnimalList end
		return nil
	end
	local function getMutRarity(mutName)
		if not mutName or mutName=="None" then return "Common" end
		local rarities={Gold="Rare",Diamond="Epic",Bloodrot="Epic",Candy="Uncommon",Lava="Rare",Galaxy="Legendary",YinYang="Legendary",Radioactive="Rare",Cursed="Epic",Divine="Legendary",Rainbow="Legendary"}
		return rarities[mutName] or "Uncommon"
	end
	local function scanAll()
		local results={}
		local pf=workspace:FindFirstChild("Plots"); if not pf then return results end
		for _,plot in ipairs(pf:GetChildren()) do
			if plot:IsA("Model") and not isMyPlot(plot) then
				pcall(function()
					local al=getAnimalList(plot); if typeof(al)~="table" then return end
					local owner=plotOwner(plot)
					for slot,data in pairs(al) do
						pcall(function()
							if typeof(data)=="table" and data.Index then
								local gen=getGen(data.Index,data.Mutation,data.Traits)
								local podiumOk
								local podiums=plot:FindFirstChild("AnimalPodiums")
								podiumOk=podiums and podiums:FindFirstChild(tostring(slot))~=nil
								table.insert(results,{
									name=dispName(data.Index),animalIndex=data.Index,
									mutation=data.Mutation,traits=data.Traits,
									genValue=gen,genText="$"..fmtNum(gen).."/s",
									plotName=plot.Name,plotOrder=getPlotOrder(plot),
									owner=owner,slot=tostring(slot),podiumExists=podiumOk,
									rarity=getMutRarity(data.Mutation),
									ownerName=owner,
								})
							end
						end)
					end
				end)
			end
		end
		table.sort(results,function(a,b) return (a.genValue or 0)>(b.genValue or 0) end)
		return results
	end

	local MUT_COLS={
		Gold=Color3.fromRGB(237,178,0),Diamond=Color3.fromRGB(37,196,254),
		Bloodrot=Color3.fromRGB(145,0,27),Candy=Color3.fromRGB(255,105,180),
		Lava=Color3.fromRGB(200,50,0),Galaxy=Color3.fromRGB(180,0,255),
		YinYang=Color3.fromRGB(200,200,200),Radioactive=Color3.fromRGB(100,255,0),
		Cursed=Color3.fromRGB(255,23,23),Divine=Color3.fromRGB(255,215,0),
		Rainbow=Color3.fromRGB(255,100,200),
	}

	CreateSection(BrainrotsTab.scroll,"BRAINROTS ON PLOTS")

	local noResultsLbl=Label(BrainrotsTab.scroll,"No brainrots found",10,T.Dim,Enum.Font.GothamMedium)
	noResultsLbl.Size=UDim2.new(1,-12,0,28); noResultsLbl.TextXAlignment=Enum.TextXAlignment.Center
	noResultsLbl.Visible=false

	local cardContainer=Instance.new("Frame"); cardContainer.Name="BrainrotCards"
	cardContainer.BackgroundTransparency=1; cardContainer.Size=UDim2.new(1,-12,0,0)
	cardContainer.AutomaticSize=Enum.AutomaticSize.Y; cardContainer.BorderSizePixel=0
	cardContainer.Parent=BrainrotsTab.scroll
	local cl=Instance.new("UIListLayout"); cl.FillDirection=Enum.FillDirection.Vertical
	cl.HorizontalAlignment=Enum.HorizontalAlignment.Center; cl.SortOrder=Enum.SortOrder.LayoutOrder
	cl.Padding=UDim.new(0,4); cl.Parent=cardContainer

	local builtUIDs,labelUpdaters,onSelectCBs={},{},{}
	local selectedUID=nil

	local CARD_H=isMobile and 80 or 76
	local function buildCard(rec,index)
		local uid=rec.plotName.."_"..rec.slot
		local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,CARD_H)
		card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
		card.BorderSizePixel=0; card.LayoutOrder=index; card.Name="Card_"..uid; card.Parent=cardContainer
		Corner(card,7)
		local cStroke=Stroke(card,T.Border,1)
		local mutCol=(rec.mutation and MUT_COLS[tostring(rec.mutation)]) or T.Accent
		local mutBar=Instance.new("Frame"); mutBar.Size=UDim2.new(0,2,1,-10)
		mutBar.Position=UDim2.new(0,0,0,5); mutBar.BackgroundColor3=mutCol
		mutBar.BorderSizePixel=0; mutBar.ZIndex=2; mutBar.Parent=card; Corner(mutBar,2)
		local infoFrame=Instance.new("Frame"); infoFrame.Size=UDim2.new(1,-14,1,0)
		infoFrame.Position=UDim2.new(0,10,0,0); infoFrame.BackgroundTransparency=1
		infoFrame.BorderSizePixel=0; infoFrame.ZIndex=3; infoFrame.Parent=card

		local nl3=Label(infoFrame,rec.name,isMobile and 10 or 11,T.White,Enum.Font.GothamBold)
		nl3.Size=UDim2.new(1,-48,0,13); nl3.Position=UDim2.new(0,0,0,6)
		nl3.TextTruncate=Enum.TextTruncate.AtEnd; nl3.ZIndex=3

		local mutTxt=(rec.mutation and tostring(rec.mutation)~="None") and tostring(rec.mutation) or "No Mutation"
		local mutLbl2=Label(infoFrame,mutTxt,isMobile and 8 or 9,mutCol,Enum.Font.GothamMedium)
		mutLbl2.Size=UDim2.new(1,-48,0,11); mutLbl2.Position=UDim2.new(0,0,0,21)
		mutLbl2.TextTruncate=Enum.TextTruncate.AtEnd; mutLbl2.ZIndex=3
		local genLbl3=Label(infoFrame,"⚡ "..rec.genText,isMobile and 8 or 9,T.Green,Enum.Font.GothamBold)
		genLbl3.Size=UDim2.new(1,-48,0,11); genLbl3.Position=UDim2.new(0,0,0,34); genLbl3.ZIndex=3
		local rarLbl=Label(infoFrame,rec.rarity or "",isMobile and 7 or 8,T.Dim,Enum.Font.GothamBold)
		rarLbl.Size=UDim2.new(1,-48,0,10); rarLbl.Position=UDim2.new(0,0,0,47); rarLbl.ZIndex=3
		local podLbl=Label(infoFrame,(rec.plotOrder or rec.plotName).." • #"..rec.slot,isMobile and 7 or 8,T.Dim,Enum.Font.GothamMedium)
		podLbl.Size=UDim2.new(1,-48,0,10); podLbl.Position=UDim2.new(0,0,0,58)
		podLbl.TextTruncate=Enum.TextTruncate.AtEnd; podLbl.ZIndex=3

		local selBtn2=Instance.new("TextButton"); selBtn2.Size=UDim2.new(0,42,0,18)
		selBtn2.Position=UDim2.new(1,-46,0.5,-9); selBtn2.BackgroundColor3=T.Card
		selBtn2.BorderSizePixel=0; selBtn2.Text="SEL"; selBtn2.TextSize=isMobile and 7 or 8
		selBtn2.Font=Enum.Font.GothamBold; selBtn2.TextColor3=T.Dim; selBtn2.ZIndex=4
		selBtn2.AutoButtonColor=false; selBtn2.Parent=card; Corner(selBtn2,5)
		local selStroke2=Stroke(selBtn2,T.Border,1)

		local isSelected=false
		local function applySelV(v)
			isSelected=v
			if v then
				TweenService:Create(selBtn2,F,{BackgroundColor3=T.Accent,TextColor3=T.White}):Play()
				TweenService:Create(selStroke2,F,{Color=T.Accent}):Play()
				TweenService:Create(cStroke,F,{Color=T.AccentBright,Thickness=2}):Play()
			else
				TweenService:Create(selBtn2,F,{BackgroundColor3=T.Card,TextColor3=T.Dim}):Play()
				TweenService:Create(selStroke2,F,{Color=T.Border}):Play()
				TweenService:Create(cStroke,F,{Color=T.Border,Thickness=1}):Play()
			end
		end
		onSelectCBs[uid]=function(off) if off and isSelected then applySelV(false) end end
		if not _G._FH_CardSelectFns then _G._FH_CardSelectFns={} end
		_G._FH_CardSelectFns[uid]=function()
			if isSelected then return end
			if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
			applySelV(true); selectedUID=uid
			_G._FH_SelectedBrainrot={uid=uid,name=rec.name,mutation=rec.mutation,gen=rec.genValue,
				genText=rec.genText,plotName=rec.plotName,slot=rec.slot,owner=rec.owner}
		end
		selBtn2.MouseButton1Click:Connect(function()
			if isSelected then applySelV(false); selectedUID=nil; _G._FH_SelectedBrainrot=nil
			else
				if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
				applySelV(true); selectedUID=uid
				_G._FH_SelectedBrainrot={uid=uid,name=rec.name,mutation=rec.mutation,gen=rec.genValue,
					genText=rec.genText,plotName=rec.plotName,slot=rec.slot,owner=rec.owner}
			end
		end)
		card.MouseEnter:Connect(function() if not isSelected then Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end end)
		card.MouseLeave:Connect(function() if not isSelected then Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}) end end)
		labelUpdaters[uid]=function(nr,ni)
			local mc2=(nr.mutation and MUT_COLS[tostring(nr.mutation)]) or T.Accent
			mutBar.BackgroundColor3=mc2
			mutLbl2.Text=(nr.mutation and tostring(nr.mutation)~="None") and tostring(nr.mutation) or "No Mutation"
			mutLbl2.TextColor3=mc2
			genLbl3.Text="⚡ "..nr.genText; rarLbl.Text=nr.rarity or ""
			podLbl.Text=(nr.plotOrder or nr.plotName).." • #"..nr.slot; card.LayoutOrder=ni
		end
	end

	local scanning=false
	local function doScan()
		if scanning then return end; scanning=true
		task.spawn(function()
			local ok,results=pcall(scanAll); if not ok or not results then results={} end
			_G._FH_LastAnimalScan=results
			noResultsLbl.Visible=#results==0
			local seen={}
			for _,rec in ipairs(results) do seen[rec.plotName.."_"..rec.slot]=true end
			for uid in pairs(builtUIDs) do
				if not seen[uid] then
					for _,c in ipairs(cardContainer:GetChildren()) do
						if c:IsA("Frame") and c.Name=="Card_"..uid then c:Destroy(); break end
					end
					builtUIDs[uid]=nil; labelUpdaters[uid]=nil; onSelectCBs[uid]=nil
					if selectedUID==uid then selectedUID=nil; _G._FH_SelectedBrainrot=nil end
				end
			end
			for i,rec in ipairs(results) do
				local uid=rec.plotName.."_"..rec.slot
				if not builtUIDs[uid] then buildCard(rec,i); builtUIDs[uid]=true
				else if labelUpdaters[uid] then labelUpdaters[uid](rec,i) end end
			end
			scanning=false
		end)
	end

	local function autoSelectBest()
		local r=_G._FH_LastAnimalScan; if not r or #r==0 then return end
		local best=r[1]; if not best then return end
		local uid=best.plotName.."_"..best.slot
		if selectedUID==uid then return end
		if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
		selectedUID=uid
		_G._FH_SelectedBrainrot={uid=uid,name=best.name,mutation=best.mutation,gen=best.genValue,
			genText=best.genText,plotName=best.plotName,slot=best.slot,owner=best.owner}
		if _G._FH_CardSelectFns and _G._FH_CardSelectFns[uid] then pcall(_G._FH_CardSelectFns[uid]) end
	end
	_G._FH_AutoSelectBest=autoSelectBest

	task.spawn(function()
		task.wait(2)
		while true do
			doScan(); task.wait(0.05)
			if AutoSelectBestBrainrot then pcall(autoSelectBest) end
			task.wait(4.95)
		end
	end)

	CreateSection(SettingsTab.scroll,"AUTO RESET")
	do
		local _arbConns2={}; local _arbBound2={}; local _arbConn2; local _arbLast2=0
		local _atpPending=false
		local function tryAutoTP()
			if not AutoTPEnabled then return end
			if not _G._FH_SelectedBrainrot then return end
			if _atpPending then return end; _atpPending=true
			task.spawn(function()
				pcall(doReset)
				local dl=tick()+10
				while (not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart")) and tick()<dl do task.wait(0.1) end
				if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then _atpPending=false; return end
				task.wait(0.15)
				if not AutoTPEnabled then _atpPending=false; return end
				pcall(doFlash)
				task.wait(4); _atpPending=false
			end)
		end
		local function bindRemote2(obj)
			if not obj:IsA("RemoteEvent") then return end
			if _arbBound2[obj] then return end
			local ok,conn=pcall(function()
				return obj.OnClientEvent:Connect(function(...)
					if not AutoResetBalloonEnabled and not AutoTPEnabled then return end
					for i=1,select("#",...) do
						local a=select(i,...)
						if type(a)=="string" and a:lower():find("jump higher",1,true) then
							local now=tick(); if now-_arbLast2<3 then return end; _arbLast2=now
							if AutoTPEnabled then
								tryAutoTP()
							elseif AutoResetBalloonEnabled then
								doReset()
							end
							return
						end
					end
				end)
			end)
			if ok and conn then table.insert(_arbConns2,conn); _arbBound2[obj]=true end
		end
		local function startARB2()
			for _,c in ipairs(_arbConns2) do pcall(function() c:Disconnect() end) end
			_arbConns2={}; _arbBound2={}
			if _arbConn2 then pcall(function() _arbConn2:Disconnect() end); _arbConn2=nil end
			_arbConn2=ReplicatedStorage.DescendantAdded:Connect(function(obj) bindRemote2(obj) end)
			task.spawn(function()
				for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do bindRemote2(obj) end
			end)
		end
		local function stopARB2()
			for _,c in ipairs(_arbConns2) do pcall(function() c:Disconnect() end) end
			_arbConns2={}; _arbBound2={}
			if _arbConn2 then pcall(function() _arbConn2:Disconnect() end); _arbConn2=nil end
		end
		CreateToggle(SettingsTab.scroll,"Reset on balloon","resets when u get ballooned",function(v)
			AutoResetBalloonEnabled=v
			if v then startARB2() elseif not AutoTPEnabled then stopARB2() end
		end)
		CreateToggle(SettingsTab.scroll,"Auto TP after reset","resets then auto tweens + flashes",function(v)
			AutoTPEnabled=v
			if v then startARB2() elseif not AutoResetBalloonEnabled then stopARB2() end
		end)
	end

	CreateSection(SettingsTab.scroll,"GRAB")
	CreateToggle(SettingsTab.scroll,"Auto Grab","auto grabs nearby brainrots with progress bar",function(v)
		AutoGrabEnabled=v
		if not v then hideProgressBar(); isStealing=false end
	end)
	CreateToggle(SettingsTab.scroll,"Auto Block","blocks plot owner after grab",function(v) AutoBlockEnabled=v end)

	CreateSection(SettingsTab.scroll,"FLASH")
	CreateToggle(SettingsTab.scroll,"Ragdoll Bypass","uses potion + ragdoll self to bypass",function(v)
		RagdollBypassEnabled=v
	end)
	CreateToggle(SettingsTab.scroll,"Anti Ragdoll","stops ragdoll from working on u",function(v)
		if v then AntiRagdoll.enable() else AntiRagdoll.disable() end
	end)

	CreateSection(SettingsTab.scroll,"PROTECTION")
	CreateToggle(SettingsTab.scroll,"Anti Admin Panel","blocks tiny jail ragdoll giant inverse bee",function(v)
		AntiAdminEnabled=v
	end)

	CreateSection(SettingsTab.scroll,"MISC")
	CreateToggle(SettingsTab.scroll,"Aimbot","aimbot fires when u attack nearest player",function(v)
		AimbotEnabled=v
	end,true)
	CreateToggle(SettingsTab.scroll,"Allow / Disallow","allow or disallow friends from ur base",function(v)
		SABAllowEnabled=v
		if v then buildSABGui()
		else
			if SABAllowGui and SABAllowGui.Parent then SABAllowGui:Destroy(); SABAllowGui=nil end
		end
	end)

	CreateSection(SettingsTab.scroll,"BRAINROTS")
	CreateToggle(SettingsTab.scroll,"Auto Select Best","auto picks the highest gen brainrot",function(v)
		AutoSelectBestBrainrot=v; Config.toggles["Auto Select Best"]=v; pcall(FH_Save)
		if v and _G._FH_LastAnimalScan and #_G._FH_LastAnimalScan>0 then pcall(_G._FH_AutoSelectBest) end
	end)

	CreateSection(SettingsTab.scroll,"FAST PANEL")
	do
		local FP={win=nil,visible=false,minimized=false}
		local FP_W=isMobile and 220 or 272
		local FP_ROW_H=isMobile and 28 or 32
		local FP_AVT=isMobile and 18 or 22
		local FP_BTN=isMobile and 17 or 20
		local FP_GAP=3
		local FP_HDR_H=24
		local FP_CMDS={{name="tiny",emoji="🐜"},{name="jail",emoji="🔓"},{name="rocket",emoji="🚀"},{name="ragdoll",emoji="🏃"},{name="balloon",emoji="🎈"}}
		local fpCoolBtns={}; for _,c in ipairs(FP_CMDS) do fpCoolBtns[c.name]={} end
		local fpCoolRunning=false

		local function fpIsCD(cmd)
			return rowCdEnd[cmd] and rowCdEnd[cmd]>tick()
		end
		local function fpCDText(cmd)
			if not rowCdEnd[cmd] or rowCdEnd[cmd]<=tick() then return nil end
			return tostring(math.ceil(rowCdEnd[cmd]-tick()))
		end

		local function fpCDLoop()
			if fpCoolRunning then return end; fpCoolRunning=true
			task.spawn(function()
				while FP.win and FP.win.Parent and FP.visible do
					for _,cmd in ipairs(FP_CMDS) do
						local onCD=fpIsCD(cmd.name); local cdTxt=onCD and fpCDText(cmd.name) or nil
						for _,e in ipairs(fpCoolBtns[cmd.name]) do
							local btn2,emoji=e[1],e[2]
							if btn2 and btn2.Parent then
								if onCD and cdTxt then
									btn2.Text=cdTxt; btn2.TextSize=8
									btn2.TextColor3=T.Red; btn2.BackgroundTransparency=0.55
								else
									btn2.Text=emoji; btn2.TextSize=isMobile and 11 or 13
									btn2.TextColor3=T.White; btn2.BackgroundTransparency=0.28
								end
							end
						end
					end
					task.wait(0.3)
				end; fpCoolRunning=false
			end)
		end

		local FP_MAX_ROWS=5
		local function fpH(rows)
			local r=math.min(rows,FP_MAX_ROWS)
			return FP_HDR_H+4+r*FP_ROW_H+math.max(0,r-1)*3+6
		end
		local function fpResize(rows,anim)
			if not FP.win or FP.minimized then return end
			local h=fpH(rows)
			if anim then Tween(FP.win,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,FP_W,0,h)})
			else FP.win.Size=UDim2.new(0,FP_W,0,h) end
			FP.scroll.ScrollBarThickness=rows>FP_MAX_ROWS and 3 or 0
		end

		local fpRefreshPlayers

		local function fpBuild()
			if FP.win then return end
			local win=Instance.new("Frame"); win.Name="VertxFastPanel"
			win.Size=UDim2.new(0,FP_W,0,fpH(0)); win.AnchorPoint=Vector2.new(0.5,1)
			win.Position=UDim2.new(0.5,0,1,-8); win.BackgroundColor3=T.BG
			win.BackgroundTransparency=0.04; win.BorderSizePixel=0; win.ZIndex=30
			win.Visible=false; win.Active=true; win.ClipsDescendants=true; win.Parent=GUI
			Corner(win,9)
			local ws=Instance.new("UIStroke"); ws.Thickness=1.3; ws.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
			ws.Color=T.AccentBright; ws.Parent=win
			local wg=Instance.new("UIGradient"); wg.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,Color3.fromRGB(30,60,160)),
				ColorSequenceKeypoint.new(0.5,Color3.fromRGB(120,180,255)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(30,60,160)),
			}); wg.Rotation=45; wg.Parent=ws
			local hdr2=Instance.new("Frame"); hdr2.Size=UDim2.new(1,0,0,FP_HDR_H)
			hdr2.BackgroundColor3=T.Header; hdr2.BorderSizePixel=0; hdr2.ZIndex=31; hdr2.Parent=win; Corner(hdr2,9)
			local hf2=Instance.new("Frame"); hf2.Size=UDim2.new(1,0,0,7); hf2.Position=UDim2.new(0,0,1,-7)
			hf2.BackgroundColor3=T.Header; hf2.BorderSizePixel=0; hf2.ZIndex=31; hf2.Parent=hdr2
			local tl2=Label(hdr2,"Fast Panel",isMobile and 9 or 10,T.White,Enum.Font.GothamBold)
			tl2.Size=UDim2.new(1,-40,1,0); tl2.Position=UDim2.new(0,8,0,0); tl2.ZIndex=32
			local mb2=Instance.new("TextButton"); mb2.Size=UDim2.new(0,16,0,13)
			mb2.AnchorPoint=Vector2.new(1,0.5); mb2.Position=UDim2.new(1,-5,0.5,0)
			mb2.BackgroundColor3=T.Card; mb2.BorderSizePixel=0; mb2.AutoButtonColor=false
			mb2.Text="—"; mb2.TextSize=8; mb2.Font=Enum.Font.GothamBold
			mb2.TextColor3=T.Dim; mb2.ZIndex=33; mb2.Parent=hdr2; Corner(mb2,4); Stroke(mb2,T.Border,1)
			local scroll2=Instance.new("ScrollingFrame"); scroll2.Name="FPScroll"
			scroll2.Size=UDim2.new(1,-6,1,-(FP_HDR_H+4)); scroll2.Position=UDim2.new(0,3,0,FP_HDR_H+3)
			scroll2.BackgroundTransparency=1; scroll2.BorderSizePixel=0; scroll2.ScrollBarThickness=0
			scroll2.ScrollBarImageColor3=T.Dim; scroll2.CanvasSize=UDim2.new(0,0,0,0); scroll2.ZIndex=31; scroll2.Parent=win
			local ll2=Instance.new("UIListLayout"); ll2.Padding=UDim.new(0,3)
			ll2.SortOrder=Enum.SortOrder.LayoutOrder; ll2.HorizontalAlignment=Enum.HorizontalAlignment.Center; ll2.Parent=scroll2
			ll2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scroll2.CanvasSize=UDim2.new(0,0,0,ll2.AbsoluteContentSize.Y+6)
			end)
			local ntl=Label(win,"No other players",isMobile and 8 or 9,T.Dim,Enum.Font.GothamMedium)
			ntl.Size=UDim2.new(1,-16,0,16); ntl.Position=UDim2.new(0,8,0,FP_HDR_H+6)
			ntl.TextXAlignment=Enum.TextXAlignment.Center; ntl.Visible=false; ntl.ZIndex=31
			FP.win=win; FP.scroll=scroll2; FP.listLayout=ll2; FP.noTargetLbl=ntl; FP.hdr=hdr2
			mb2.MouseButton1Click:Connect(function()
				FP.minimized=not FP.minimized
				if FP.minimized then
					Tween(win,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,FP_W,0,FP_HDR_H)})
					scroll2.Visible=false; ntl.Visible=false
				else scroll2.Visible=true; fpRefreshPlayers() end
			end)
			do
				local _fpDrag=false; local _fpDS=nil; local _fpWS=nil; local _fpMoved=false
				local function fpDB(inp) _fpDrag=true; _fpMoved=false; _fpDS=inp.Position; _fpWS=win.Position end
				local function fpDE() _fpDrag=false; _fpMoved=false end
				win.InputBegan:Connect(function(inp)
					if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then fpDB(inp) end
				end)
				win.InputEnded:Connect(function(inp)
					if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then fpDE() end
				end)
				hdr2.InputBegan:Connect(function(inp)
					if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then fpDB(inp) end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if not _fpDrag then return end
					if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
						if not _fpDS or not _fpWS then return end
						local d=inp.Position-_fpDS
						if not _fpMoved and d.Magnitude<4 then return end
						_fpMoved=true
						win.Position=UDim2.new(_fpWS.X.Scale,_fpWS.X.Offset+d.X,_fpWS.Y.Scale,_fpWS.Y.Offset+d.Y)
					end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then fpDE() end
				end)
			end
		end

		local function fpMakeRow(plr,order)
			local row=Instance.new("Frame"); row.Name="FPRow_"..plr.Name
			row.Size=UDim2.new(1,-4,0,FP_ROW_H); row.BackgroundColor3=T.Card; row.BackgroundTransparency=0.1
			row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=32; row.Parent=FP.scroll
			Corner(row,5); Stroke(row,T.Border,1)
			local af=Instance.new("Frame"); af.Size=UDim2.new(0,FP_AVT,0,FP_AVT)
			af.Position=UDim2.new(0,4,0.5,-FP_AVT/2); af.BackgroundColor3=T.BG; af.BackgroundTransparency=0.4
			af.BorderSizePixel=0; af.ZIndex=33; af.Parent=row; Corner(af,math.floor(FP_AVT/2))
			local ai=Instance.new("ImageLabel"); ai.Size=UDim2.new(1,0,1,0); ai.BackgroundTransparency=1
			ai.Image=("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=48&height=48&format=png"):format(plr.UserId)
			ai.ScaleType=Enum.ScaleType.Crop; ai.ZIndex=34; ai.Parent=af; Corner(ai,math.floor(FP_AVT/2))

			local BTN_BLOCK=5*FP_BTN+4*FP_GAP
			local NAME_X=4+FP_AVT+4
			local BTNS_X=FP_W-4-BTN_BLOCK

			local nl4=Label(row,plr.DisplayName,isMobile and 9 or 10,T.White,Enum.Font.GothamBold)
			nl4.Size=UDim2.new(0,BTNS_X-NAME_X-4,0,FP_ROW_H*0.52)
			nl4.Position=UDim2.new(0,NAME_X,0,2)
			nl4.TextTruncate=Enum.TextTruncate.AtEnd; nl4.TextXAlignment=Enum.TextXAlignment.Left; nl4.ZIndex=33

			local apRowBadge=Instance.new("TextLabel"); apRowBadge.Size=UDim2.new(0,34,0,10)
			apRowBadge.Position=UDim2.new(0,NAME_X,0.5,1); apRowBadge.BackgroundColor3=T.Card
			apRowBadge.BorderSizePixel=0; apRowBadge.Text="AP?"; apRowBadge.TextSize=7
			apRowBadge.Font=Enum.Font.GothamBold; apRowBadge.TextColor3=T.Dim
			apRowBadge.TextXAlignment=Enum.TextXAlignment.Center
			apRowBadge.ZIndex=34; apRowBadge.Parent=row; Corner(apRowBadge,3); Stroke(apRowBadge,T.Border,0.7)

			task.spawn(function()
				task.wait(0.5)
				local hasAP=false
				pcall(function()
					local pg=lp:FindFirstChild("PlayerGui"); if not pg then return end
					local ap=pg:FindFirstChild("AdminPanel"); if not ap then return end
					local plist=ap:FindFirstChild("Profiles",true)
					if plist and plist:FindFirstChild(plr.Name) then hasAP=true end
				end)
				if hasAP then
					apRowBadge.Text="AP ✓"; apRowBadge.TextColor3=T.Green
					TweenService:Create(apRowBadge,F,{BackgroundColor3=Color3.fromRGB(6,20,10)}):Play()
				else
					apRowBadge.Text="AP ✗"; apRowBadge.TextColor3=T.Red
					TweenService:Create(apRowBadge,F,{BackgroundColor3=Color3.fromRGB(20,6,6)}):Play()
				end
			end)

			row.MouseEnter:Connect(function() Tween(row,F,{BackgroundColor3=T.CardHover}) end)
			row.MouseLeave:Connect(function() Tween(row,F,{BackgroundColor3=T.Card}) end)
			for i,cmd in ipairs(FP_CMDS) do
				local xPos=BTNS_X+(i-1)*(FP_BTN+FP_GAP)
				local btn3=Instance.new("TextButton"); btn3.Name="FPCmd_"..cmd.name
				btn3.Size=UDim2.new(0,FP_BTN,0,FP_BTN); btn3.Position=UDim2.new(0,xPos,0.5,-FP_BTN/2)
				btn3.BackgroundColor3=T.Card; btn3.BackgroundTransparency=0.28
				btn3.Text=cmd.emoji; btn3.TextSize=isMobile and 11 or 13
				btn3.Font=Enum.Font.SourceSans; btn3.AutoButtonColor=false; btn3.ZIndex=33; btn3.Parent=row
				Corner(btn3,4); Stroke(btn3,T.Border,1)
				table.insert(fpCoolBtns[cmd.name],{btn3,cmd.emoji})
				btn3.MouseEnter:Connect(function() if not fpIsCD(cmd.name) then Tween(btn3,F,{BackgroundColor3=T.CardHover,BackgroundTransparency=0}) end end)
				btn3.MouseLeave:Connect(function() if not fpIsCD(cmd.name) then Tween(btn3,F,{BackgroundColor3=T.Card,BackgroundTransparency=0.28}) end end)
				local function fireCmd()
					if fpIsCD(cmd.name) then return end
					task.spawn(function() fpFireCmd(plr,cmd.name) end)
					Tween(btn3,TweenInfo.new(0.08,Enum.EasingStyle.Quad),{BackgroundColor3=T.AccentBright,BackgroundTransparency=0})
					task.delay(0.18,function() Tween(btn3,F,{BackgroundColor3=T.Card,BackgroundTransparency=0.28}) end)
				end
				btn3.MouseButton1Click:Connect(fireCmd)
				btn3.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch then fireCmd() end end)
			end
			return row
		end

		fpRefreshPlayers=function()
			if not FP.scroll then return end
			for _,cmd in ipairs(FP_CMDS) do fpCoolBtns[cmd.name]={} end
			for _,ch in ipairs(FP.scroll:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
			local order=1
			for _,plr in ipairs(Players:GetPlayers()) do
				if plr~=lp then fpMakeRow(plr,order); order=order+1 end
			end
			local rc=order-1; FP.noTargetLbl.Visible=(rc==0); fpResize(rc,true); fpCDLoop()
		end

		local _fpa,_fpr
		local function fpShow(v)
			if not FP.win then fpBuild() end
			FP.visible=v; FP.win.Visible=v
			if v then
				FP.minimized=false; FP.scroll.Visible=true; fpRefreshPlayers()
				if not _fpa then _fpa=Players.PlayerAdded:Connect(function()
					if not FP.visible then return end; task.wait(0.3); fpRefreshPlayers()
				end) end
				if not _fpr then _fpr=Players.PlayerRemoving:Connect(function()
					if not FP.visible then return end; task.wait(0.3); fpRefreshPlayers()
				end) end
			else
				if FP.win then FP.win.Size=UDim2.new(0,FP_W,0,fpH(0)) end
			end
		end
		CreateToggle(SettingsTab.scroll,"Fast Panel","quick admin command panel for all players",function(v) fpShow(v) end)
	end

	CreateSection(SettingsTab.scroll,"THEME")
	do
		local cpCard=Instance.new("Frame"); cpCard.Size=UDim2.new(1,-12,0,168)
		cpCard.BackgroundColor3=T.Card; cpCard.BackgroundTransparency=0.1
		cpCard.BorderSizePixel=0; cpCard.Parent=SettingsTab.scroll; Corner(cpCard,8)
		local cpStroke=Stroke(cpCard,T.Border,1)
		onThemeChange(function() cpStroke.Color=T.Border end)

		local previewStrip=Instance.new("Frame"); previewStrip.Size=UDim2.new(1,-12,0,10)
		previewStrip.Position=UDim2.new(0,6,0,5); previewStrip.BackgroundColor3=T.Accent
		previewStrip.BorderSizePixel=0; previewStrip.Parent=cpCard; Corner(previewStrip,4)
		local pvGrad=Instance.new("UIGradient"); pvGrad.Parent=previewStrip
		local function refreshPreview()
			pvGrad.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,   T.Accent),
				ColorSequenceKeypoint.new(0.5, T.Accent2),
				ColorSequenceKeypoint.new(1.0, T.AccentBright),
			})
		end
		refreshPreview(); onThemeChange(refreshPreview)

		local PRESETS={
			{n="Purple",  h=285,h2=325,s=80,v=92},
			{n="Pink",    h=320,h2=350,s=85,v=95},
			{n="Red",     h=0,  h2=20, s=88,v=95},
			{n="Orange",  h=26, h2=46, s=90,v=100},
			{n="Yellow",  h=50, h2=65, s=85,v=100},
			{n="Green",   h=130,h2=155,s=72,v=88},
			{n="Teal",    h=172,h2=192,s=78,v=88},
			{n="Cyan",    h=190,h2=210,s=80,v=95},
			{n="Blue",    h=218,h2=240,s=82,v=100},
			{n="Indigo",  h=248,h2=270,s=78,v=95},
			{n="Gold",    h=42, h2=60, s=88,v=100},
			{n="White",   h=0,  h2=0,  s=0, v=100},
		}

		local psScroll=Instance.new("ScrollingFrame",cpCard)
		psScroll.Size=UDim2.new(1,-12,0,34); psScroll.Position=UDim2.new(0,6,0,20)
		psScroll.BackgroundTransparency=1; psScroll.BorderSizePixel=0
		psScroll.ScrollBarThickness=2; psScroll.ScrollBarImageColor3=T.Accent
		psScroll.CanvasSize=UDim2.new(0,0,0,0); psScroll.AutomaticCanvasSize=Enum.AutomaticSize.X
		psScroll.ScrollingDirection=Enum.ScrollingDirection.X
		onThemeChange(function() psScroll.ScrollBarImageColor3=T.Accent end)
		local psLayout=Instance.new("UIListLayout",psScroll)
		psLayout.FillDirection=Enum.FillDirection.Horizontal
		psLayout.VerticalAlignment=Enum.VerticalAlignment.Center
		psLayout.Padding=UDim.new(0,4)
		local psPad=Instance.new("UIPadding",psScroll); psPad.PaddingTop=UDim.new(0,2); psPad.PaddingBottom=UDim.new(0,2)
		local selPsBtn=nil
		for _,ps in ipairs(PRESETS) do
			local col=hsvToRgb(ps.h/360,ps.s/100,ps.v/100)
			local pb=Instance.new("TextButton",psScroll)
			pb.Size=UDim2.fromOffset(0,26); pb.AutomaticSize=Enum.AutomaticSize.X
			pb.BackgroundColor3=col; pb.BorderSizePixel=0
			pb.Text=ps.n; pb.TextSize=7; pb.Font=Enum.Font.GothamBold
			pb.TextColor3=ps.s<15 and Color3.new(0.1,0.1,0.1) or Color3.new(1,1,1)
			pb.AutoButtonColor=false; Corner(pb,5)
			local ppd=Instance.new("UIPadding",pb); ppd.PaddingLeft=UDim.new(0,6); ppd.PaddingRight=UDim.new(0,6)
			local pbStk=Stroke(pb,Color3.new(1,1,1),0)
			pb.MouseButton1Click:Connect(function()
				_AccentH=ps.h; _AccentH2=ps.h2; _AccentS=ps.s/100; _AccentV=ps.v/100
				applyTheme(); refreshPreview()
				if selPsBtn then TweenService:Create(selPsBtn:FindFirstChildOfClass("UIStroke"),F,{Thickness=0}):Play() end
				selPsBtn=pb; TweenService:Create(pbStk,F,{Thickness=1.4,Color=Color3.new(1,1,1)}):Play()
			end)
		end

		local function makeSlider(yPos,labelTxt,minV,maxV,initPct,onChange)
			local row=Instance.new("Frame",cpCard)
			row.Size=UDim2.new(1,-12,0,19); row.Position=UDim2.new(0,6,0,yPos)
			row.BackgroundTransparency=1
			local ll=Label(row,labelTxt,8,T.Dim,Enum.Font.GothamBold)
			ll.Size=UDim2.new(0,20,1,0); onThemeChange(function() ll.TextColor3=T.Dim end)
			local vl=Label(row,"",8,T.White,Enum.Font.GothamBold)
			vl.Size=UDim2.new(0,28,1,0); vl.Position=UDim2.new(1,-28,0,0)
			vl.TextXAlignment=Enum.TextXAlignment.Right
			vl.Text=tostring(math.floor(minV+initPct*(maxV-minV)))
			local bg=Instance.new("Frame",row)
			bg.Size=UDim2.new(1,-52,0,5); bg.Position=UDim2.new(0,22,0.5,-2.5)
			bg.BackgroundColor3=T.TrackOff; bg.BorderSizePixel=0; Corner(bg,3)
			onThemeChange(function() bg.BackgroundColor3=T.TrackOff end)
			local fill=Instance.new("Frame",bg)
			fill.Size=UDim2.new(initPct,0,1,0); fill.BackgroundColor3=T.Accent
			fill.BorderSizePixel=0; Corner(fill,3)
			onThemeChange(function() fill.BackgroundColor3=T.Accent end)
			local knob=Instance.new("Frame",bg)
			knob.Size=UDim2.fromOffset(9,9); knob.AnchorPoint=Vector2.new(0.5,0.5)
			knob.Position=UDim2.new(initPct,0,0.5,0); knob.BackgroundColor3=T.White
			knob.BorderSizePixel=0; Corner(knob,5)
			local dragging=false
			local function setV(pct)
				pct=math.clamp(pct,0,1)
				local v=math.floor(minV+pct*(maxV-minV))
				fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0); vl.Text=tostring(v)
				onChange(v)
			end
			bg.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
					dragging=true; setV((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X)
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
					setV((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
			end)
		end

		makeSlider(60, "H1",0,360,_AccentH/360,   function(v) _AccentH=v;  applyTheme(); refreshPreview() end)
		makeSlider(83, "H2",0,360,_AccentH2/360,  function(v) _AccentH2=v; applyTheme(); refreshPreview() end)
		makeSlider(106,"S", 0,100,_AccentS,        function(v) _AccentS=v/100; applyTheme(); refreshPreview() end)
		makeSlider(129,"V", 10,100,(_AccentV-0.1)/0.9,function(v) _AccentV=v/100; applyTheme(); refreshPreview() end)
		makeSlider(148,"BG",0,30,0,                function(v)
			local b=v/100
			T.BG=Color3.fromRGB(math.floor(8+b*80),math.floor(5+b*60),math.floor(12+b*90))
			T.Header=Color3.fromRGB(math.floor(5+b*50),math.floor(3+b*40),math.floor(9+b*70))
			T.Card=Color3.fromRGB(math.floor(15+b*50),math.floor(11+b*40),math.floor(22+b*60))
			Win.BackgroundColor3=T.BG; Hdr.BackgroundColor3=T.Header; HdrFill.BackgroundColor3=T.Header
		end)
	end

	CreateSection(SettingsTab.scroll,"SERVER")
	CreateButton(SettingsTab.scroll,"Rejoin Server",nil,function()
		game:GetService("TeleportService"):Teleport(game.PlaceId,lp)
	end)
end

local _uiVisible=true; local _uiAnim=false
local SHOW_TI=TweenInfo.new(0.24,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local HIDE_TI=TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
local function setUIVisible(v)
	if _uiAnim or v==_uiVisible then return end
	_uiVisible=v; _uiAnim=true
	if v then
		winScale.Scale=0; Win.Visible=true
		local tw=TweenService:Create(winScale,SHOW_TI,{Scale=1}); tw:Play()
		tw.Completed:Connect(function() _uiAnim=false end)
	else
		local tw=TweenService:Create(winScale,HIDE_TI,{Scale=0}); tw:Play()
		tw.Completed:Connect(function() Win.Visible=false; _uiAnim=false end)
	end
end
UserInputService.InputBegan:Connect(function(inp,gpe)
	if gpe then return end
	if inp.KeyCode==Enum.KeyCode.LeftControl or inp.KeyCode==Enum.KeyCode.RightControl then
		setUIVisible(not _uiVisible)
	end
	if inp.UserInputType==Enum.UserInputType.Keyboard then
		for _,b in ipairs(keybindEntries) do
			if b.entry and b.entry.keyCode and inp.KeyCode==b.entry.keyCode then b.fire() end
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	BorderGrad.Rotation=(BorderGrad.Rotation+dt*55)%360
end)

ActivateTab(BrainrotsTab)

for name,kcName in pairs(Config.keybinds) do
	if configRegistry[name] and configRegistry[name].setKeyCode then
		local ok2,kc=pcall(function() return Enum.KeyCode[kcName] end)
		if ok2 and kc then configRegistry[name].setKeyCode(kc) end
	end
end
