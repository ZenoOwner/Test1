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
local VirtualInputManager = Instance.new("VirtualInputManager")

local lp = Players.LocalPlayer
if not lp.Character then lp.CharacterAdded:Wait() end

local AutoBlockEnabled       = true
local AutoFlashEnabled       = true
local RagdollBypassEnabled   = true
local AutoSelectBestBrainrot = false
local AntiAdminEnabled       = true
local AutoResetBalloonEnabled = false
local AimbotEnabled          = true
local AimbotRange            = 350
local AimbotTarget           = nil
local AimbotRemote           = nil

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
AntiRagdoll.enable()

do
	local scaleNames={"HeadScale","BodyDepthScale","BodyHeightScale","BodyProportionScale","BodyTypeScale","BodyWidthScale"}
	local origScales={}; local origHipH=nil
	local antiGummyRespawnGraceUntil=0
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
		if hum then antiGummyRespawnGraceUntil=tick()+1.5 end
		task.wait(0.1); captureOriginals()
	end)
	task.spawn(captureOriginals)
	local _ctrlCache
	local function getCtrl()
		if _ctrlCache then return _ctrlCache end
		local ps=lp:FindFirstChild("PlayerScripts")
		local pm=ps and ps:FindFirstChild("PlayerModule"); if not pm then return nil end
		local ok,m=pcall(require,pm); if not ok then return nil end
		local ok2,c=pcall(function() return m:GetControls() end)
		if ok2 and c then _ctrlCache=c end; return _ctrlCache
	end
	lp.CharacterAdded:Connect(function() _ctrlCache=nil end)
	local _charController,_jumpscareMod
	local function tryCharController()
		if _charController~=nil then return _charController end
		local ok,mod=pcall(function()
			return require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("CharacterController"))
		end)
		_charController=ok and mod or false; return _charController
	end
	local function tryJumpscare()
		if _jumpscareMod~=nil then return _jumpscareMod end
		local ok,mod=pcall(function()
			return require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("AdminCommands"):WaitForChild("jumpscare"))
		end)
		_jumpscareMod=ok and mod or false; return _jumpscareMod
	end
	task.spawn(function()
		while task.wait(0.1) do
			if not AntiAdminEnabled then continue end
			local char=lp.Character; if not char then continue end
			local hum=char:FindFirstChildOfClass("Humanoid")
			local hrp=char:FindFirstChild("HumanoidRootPart")
			if not hum or not hrp then continue end
			for _,v in ipairs(char:GetDescendants()) do
				if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then
					v:Destroy()
				elseif v:IsA("Motor6D") then v.Enabled=true end
			end
			local ctrl=getCtrl()
			if ctrl then pcall(function() ctrl:Enable() end) end
			local st=hum:GetState()
			if st~=Enum.HumanoidStateType.Running and st~=Enum.HumanoidStateType.Jumping
			and st~=Enum.HumanoidStateType.Freefall then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
			end
			if workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject~=hum then
				workspace.CurrentCamera.CameraSubject=hum
			end
			local re=lp:GetAttribute("RagdollEndTime") or 0
			if re>workspace:GetServerTimeNow() then
				hrp.Velocity=Vector3.zero; lp:SetAttribute("RagdollEndTime",0)
			end
			local cc=tryCharController()
			if cc and ctrl then
				ctrl.moveFunction=function(p,x,z) cc:RequestMove(p,x,z) end
			end
			local jm=tryJumpscare()
			if jm and jm.effects and jm.effects.Victim then
				jm.effects.Victim=function() end
			end
			if tick()>antiGummyRespawnGraceUntil then
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
		if net then net=net:FindFirstChild("Net") end
		if not net then return end
		local ch=net:GetChildren()
		for i,obj in ipairs(ch) do
			if obj.Name=="RE/UseItem" then AimbotRemote=ch[i+1]; break end
		end
	end
	local function getNearestAimbotTarget()
		local chr=lp and lp.Character
		local hrp=chr and chr:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil end
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
		return nearest
	end
	local function hookAimbotTool(tool)
		tool.Activated:Connect(function()
			if not AimbotEnabled then return end
			local tgt=AimbotTarget; if not tgt or not tgt.Character then return end
			local part=tgt.Character:FindFirstChild("HumanoidRootPart") or tgt.Character:FindFirstChild("Head")
			if part and AimbotRemote then
				pcall(function() AimbotRemote:FireServer(part.Position,part) end)
			end
		end)
	end
	findAimbotRemote()
	if lp.Character then
		for _,t in ipairs(lp.Character:GetChildren()) do
			if t:IsA("Tool") then pcall(hookAimbotTool,t) end
		end
	end
	lp.CharacterAdded:Connect(function(chr)
		task.wait(0.5)
		for _,t in ipairs(chr:GetChildren()) do
			if t:IsA("Tool") then pcall(hookAimbotTool,t) end
		end
	end)
	workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("Tool") and obj:IsDescendantOf(lp.Character or {}) then
			task.wait(0.1); pcall(hookAimbotTool,obj)
		end
	end)
	RunService.Heartbeat:Connect(function()
		if AimbotEnabled then AimbotTarget=getNearestAimbotTarget() end
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
		_arbConn=ReplicatedStorage.DescendantAdded:Connect(function(obj)
			if AutoResetBalloonEnabled then bindRemote(obj) end
		end)
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
		local target=getPlotOwnerPlayer() or getNearestPlayer()
		if target then pcall(blockPlayer,target) end
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

local T={
	BG          = Color3.fromRGB(10,  10,  14),
	Header      = Color3.fromRGB(6,   6,   10),
	Card        = Color3.fromRGB(18,  18,  26),
	CardHover   = Color3.fromRGB(26,  26,  38),
	Border      = Color3.fromRGB(38,  38,  58),
	BorderHover = Color3.fromRGB(60,  80,  140),
	White       = Color3.fromRGB(225, 230, 255),
	Dim         = Color3.fromRGB(85,  85,  115),
	Accent      = Color3.fromRGB(60,  120, 255),
	AccentBright= Color3.fromRGB(100, 160, 255),
	TabActive   = Color3.fromRGB(225, 230, 255),
	TabInact    = Color3.fromRGB(55,  55,  85),
	TrackOn     = Color3.fromRGB(60,  120, 255),
	TrackOff    = Color3.fromRGB(30,  30,  48),
	KnobOn      = Color3.fromRGB(200, 220, 255),
	KnobOff     = Color3.fromRGB(75,  75,  105),
	Green       = Color3.fromRGB(52,  218, 88),
	Red         = Color3.fromRGB(255, 65,  65),
}
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
	if game.CoreGui:FindFirstChild("VertxedHub") then game.CoreGui.VertxedHub:Destroy() end
end)

local GUI=Instance.new("ScreenGui")
GUI.Name="VertxedHub"; GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn=false; GUI.IgnoreGuiInset=true
if not pcall(function() GUI.Parent=game.CoreGui end) then
	GUI.Parent=lp:WaitForChild("PlayerGui")
end

local WIN_W=isMobile and 220 or 248
local WIN_H=isMobile and 310 or 330
local HDR_H=isMobile and 50 or 56
local BIG_BTN_H=28
local BIG_BTN_TOP=HDR_H+7
local TOTAL_TOP=HDR_H+BIG_BTN_H+14
local TAB_H=26
local FULL_H=WIN_H
local FOLD_H=HDR_H+BIG_BTN_H+16

local Win=Instance.new("Frame")
Win.Name="Win"; Win.Size=UDim2.new(0,WIN_W,0,FULL_H)
Win.AnchorPoint=Vector2.new(0.5,0.5); Win.Position=UDim2.new(0.5,0,0.5,0)
Win.BackgroundColor3=T.BG; Win.BackgroundTransparency=0.06
Win.BorderSizePixel=0; Win.ZIndex=2; Win.Parent=GUI
Corner(Win,10)
local WinStroke=Instance.new("UIStroke")
WinStroke.Thickness=1.4; WinStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
WinStroke.Color=T.AccentBright; WinStroke.Parent=Win
local BorderGrad=Instance.new("UIGradient")
BorderGrad.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(30,60,160)),
	ColorSequenceKeypoint.new(0.5,Color3.fromRGB(120,180,255)),
	ColorSequenceKeypoint.new(1.0,Color3.fromRGB(30,60,160)),
})
BorderGrad.Rotation=0; BorderGrad.Parent=WinStroke
local winScale=Instance.new("UIScale"); winScale.Scale=1; winScale.Parent=Win

local Hdr=Instance.new("Frame")
Hdr.Name="Hdr"; Hdr.Size=UDim2.new(1,0,0,HDR_H)
Hdr.BackgroundColor3=T.Header; Hdr.BackgroundTransparency=0.05
Hdr.BorderSizePixel=0; Hdr.ZIndex=5; Hdr.Parent=Win; Hdr.Active=true
Corner(Hdr,10)
local HdrFill=Instance.new("Frame")
HdrFill.Size=UDim2.new(1,0,0,10); HdrFill.Position=UDim2.new(0,0,1,-10)
HdrFill.BackgroundColor3=T.Header; HdrFill.BackgroundTransparency=0.05
HdrFill.BorderSizePixel=0; HdrFill.ZIndex=5; HdrFill.Parent=Hdr
local HdrLine=Instance.new("Frame")
HdrLine.Size=UDim2.new(1,0,0,1); HdrLine.Position=UDim2.new(0,0,1,-1)
HdrLine.BackgroundColor3=T.Border; HdrLine.BorderSizePixel=0; HdrLine.ZIndex=6; HdrLine.Parent=Hdr

local TitleLbl=Label(Hdr,"",15,T.White,Enum.Font.GothamBold)
TitleLbl.RichText=true
TitleLbl.Text='<font color="rgb(100,160,255)">Vertex</font> <font color="rgb(225,230,255)">Pvp</font>'
TitleLbl.Size=UDim2.new(1,-70,0,18); TitleLbl.Position=UDim2.new(0,10,0,6); TitleLbl.ZIndex=6

local DiscordLbl=Label(Hdr,"discord.gg/3JnFzfcYB",isMobile and 8 or 9,T.Dim,Enum.Font.Gotham)
DiscordLbl.Size=UDim2.new(1,-70,0,12); DiscordLbl.Position=UDim2.new(0,10,0,26)
DiscordLbl.ZIndex=6; DiscordLbl.TextTruncate=Enum.TextTruncate.AtEnd

local HdrBtnRow=Instance.new("Frame")
HdrBtnRow.Size=UDim2.new(0,0,0,18); HdrBtnRow.Position=UDim2.new(1,-8,0,6)
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
	btn.Size=UDim2.new(0,22,0,18); btn.LayoutOrder=order
	btn.BackgroundColor3=T.Card; btn.BorderSizePixel=0; btn.AutoButtonColor=false
	btn.Text=txt; btn.TextSize=10; btn.Font=Enum.Font.GothamBold
	btn.TextColor3=T.Dim; btn.ZIndex=8; btn.Active=true; btn.Parent=HdrBtnRow
	Corner(btn,5)
	local s=Stroke(btn,T.Border,1)
	btn.MouseEnter:Connect(function() Tween(btn,F,{BackgroundColor3=T.CardHover}) end)
	btn.MouseLeave:Connect(function() Tween(btn,F,{BackgroundColor3=T.Card}) end)
	return btn,s
end

local lockBtn,lockStroke=makeHdrIconBtn("🔒",1)
local _guiLocked=false
lockBtn.MouseButton1Click:Connect(function()
	_guiLocked=not _guiLocked
	if _guiLocked then
		lockBtn.Text="🔓"
		Tween(lockBtn,F,{BackgroundColor3=Color3.fromRGB(120,30,30)})
		Tween(lockStroke,F,{Color=Color3.fromRGB(200,50,50)})
	else
		lockBtn.Text="🔒"
		Tween(lockBtn,F,{BackgroundColor3=T.Card})
		Tween(lockStroke,F,{Color=T.Border})
	end
end)

local foldBtn,foldStroke=makeHdrIconBtn("▼",2)
local _guiFolded=false

local closeBtn,closeStroke=makeHdrIconBtn("✕",3)
local _minimized=false
local _miniFrame=nil

local BigBtnRow=Instance.new("Frame")
BigBtnRow.Size=UDim2.new(1,-16,0,BIG_BTN_H)
BigBtnRow.Position=UDim2.new(0,8,0,BIG_BTN_TOP)
BigBtnRow.BackgroundTransparency=1; BigBtnRow.ZIndex=5; BigBtnRow.Parent=Win
local BigBtnLayout=Instance.new("UIListLayout")
BigBtnLayout.FillDirection=Enum.FillDirection.Horizontal
BigBtnLayout.VerticalAlignment=Enum.VerticalAlignment.Center
BigBtnLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
BigBtnLayout.SortOrder=Enum.SortOrder.LayoutOrder
BigBtnLayout.Padding=UDim.new(0,6); BigBtnLayout.Parent=BigBtnRow

local function makeBigBtn(txt,order,accentCol)
	local btn=Instance.new("TextButton")
	btn.Name="BigBtn_"..txt
	btn.Size=UDim2.new(0,0,0,BIG_BTN_H); btn.AutomaticSize=Enum.AutomaticSize.X
	btn.LayoutOrder=order
	btn.BackgroundColor3=T.Card; btn.BorderSizePixel=0; btn.AutoButtonColor=false
	btn.Text=txt; btn.TextSize=12; btn.Font=Enum.Font.GothamBold
	btn.TextColor3=T.White; btn.ZIndex=6; btn.Active=true; btn.Parent=BigBtnRow
	Corner(btn,7)
	local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,14); pad.Parent=btn
	local s=Stroke(btn,accentCol or T.Border,1)
	local _busy=false
	btn.MouseEnter:Connect(function()
		if _busy then return end
		Tween(btn,F,{BackgroundColor3=T.CardHover}); Tween(s,F,{Color=accentCol or T.BorderHover})
	end)
	btn.MouseLeave:Connect(function()
		if _busy then return end
		Tween(btn,F,{BackgroundColor3=T.Card}); Tween(s,F,{Color=accentCol or T.Border})
	end)
	local function flash()
		_busy=true
		Tween(btn,F,{BackgroundColor3=accentCol or T.AccentBright})
		btn.TextColor3=Color3.fromRGB(10,10,20)
		task.delay(0.18,function()
			Tween(btn,M,{BackgroundColor3=T.Card})
			btn.TextColor3=T.White; _busy=false
		end)
	end
	return btn,s,flash
end

local flashBtn,flashBtnStroke,flashBtnFlash=makeBigBtn("FLASH",1,T.AccentBright)
local blockBtn,blockBtnStroke,blockBtnFlash=makeBigBtn("BLOCK",2,Color3.fromRGB(200,60,60))
local resetBtn,resetBtnStroke,resetBtnFlash=makeBigBtn("RESET",3,Color3.fromRGB(80,80,120))

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
	local function onInputBegan(inp)
		if _guiLocked then return end
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			dragging=true; _moved=false; dragStart=inp.Position; winStart=Win.Position
		end
	end
	local function onInputEnded(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			dragging=false; _moved=false
		end
	end
	Win.InputBegan:Connect(onInputBegan)
	Win.InputEnded:Connect(onInputEnded)
	Hdr.InputBegan:Connect(onInputBegan)
	Hdr.InputEnded:Connect(onInputEnded)
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
	UserInputService.InputEnded:Connect(onInputEnded)
end

local FOLD_OUT=TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local FOLD_IN =TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.In)

foldBtn.MouseButton1Click:Connect(function()
	_guiFolded=not _guiFolded
	if _guiFolded then
		foldBtn.Text="▲"
		TabBar.Visible=false; ContentArea.Visible=false; TBLine.Visible=false
		local curPos=Win.Position
		TweenService:Create(Win,FOLD_IN,{Size=UDim2.new(0,WIN_W,0,FOLD_H)}):Play()
		Win.Position=curPos
	else
		foldBtn.Text="▼"
		local curPos=Win.Position
		TweenService:Create(Win,FOLD_OUT,{Size=UDim2.new(0,WIN_W,0,FULL_H)}):Play()
		Win.Position=curPos
		task.delay(0.12,function()
			TabBar.Visible=true; ContentArea.Visible=true; TBLine.Visible=true
		end)
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	if not _minimized then
		_minimized=true; Win.Visible=false
		if _miniFrame then _miniFrame:Destroy() end
		_miniFrame=Instance.new("TextButton")
		_miniFrame.Size=UDim2.new(0,76,0,24)
		_miniFrame.Position=UDim2.new(0,8,0.5,-12)
		_miniFrame.BackgroundColor3=T.Card
		_miniFrame.BorderSizePixel=0; _miniFrame.Text="Vertex Pvp"
		_miniFrame.TextSize=10; _miniFrame.Font=Enum.Font.GothamBold
		_miniFrame.TextColor3=T.White; _miniFrame.ZIndex=50
		_miniFrame.AutoButtonColor=false; _miniFrame.Parent=GUI
		Corner(_miniFrame,7); Stroke(_miniFrame,T.AccentBright,1.2)
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
	l.HorizontalAlignment=Enum.HorizontalAlignment.Center; l.Padding=UDim.new(0,5); l.Parent=s
	Padding(s,8,8,6,6); return s
end

CreateSection=function(parent,title)
	local f=Instance.new("Frame"); f.Size=UDim2.new(1,-12,0,20); f.BackgroundTransparency=1; f.Parent=parent
	local lw=#title*6+6
	local lbl=Label(f,title,9,T.Dim,Enum.Font.GothamBold)
	lbl.Size=UDim2.new(0,lw,1,0); lbl.Position=UDim2.new(0,4,0,0)
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=2
	local line=Instance.new("Frame"); line.Size=UDim2.new(1,-(lw+12),0,1)
	line.Position=UDim2.new(0,lw+8,0.5,0); line.BackgroundColor3=T.Border
	line.BorderSizePixel=0; line.Parent=f
end

CreateToggle=function(parent,name,desc,cb)
	local state=(Config.toggles[name]==true)
	local hasDesc=desc and desc~=""
	local cardH=hasDesc and 48 or 38
	local card=Instance.new("Frame"); card.Size=UDim2.new(1,-12,0,cardH)
	card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
	card.BorderSizePixel=0; card.Parent=parent; Corner(card,7)
	local cStroke=Stroke(card,T.Border,1)
	local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,2,0,cardH-14)
	bar.Position=UDim2.new(0,0,0,7); bar.BackgroundColor3=T.TrackOff
	bar.BorderSizePixel=0; bar.ZIndex=2; bar.Parent=card; Corner(bar,2)
	local nameY=hasDesc and 8 or (cardH/2-7)
	local nl=Label(card,name,isMobile and 10 or 12,T.White,Enum.Font.GothamMedium)
	nl.Size=UDim2.new(1,-56,0,14); nl.Position=UDim2.new(0,10,0,nameY)
	nl.ZIndex=2; nl.TextTruncate=Enum.TextTruncate.AtEnd
	if hasDesc then
		local dl=Label(card,desc,isMobile and 8 or 10,T.Dim,Enum.Font.Gotham)
		dl.Size=UDim2.new(1,-56,0,12); dl.Position=UDim2.new(0,10,0,nameY+16)
		dl.ZIndex=2; dl.TextTruncate=Enum.TextTruncate.AtEnd
	end
	local track=Instance.new("Frame"); track.Size=UDim2.new(0,36,0,20)
	track.Position=UDim2.new(1,-44,0.5,-10); track.BackgroundColor3=T.TrackOff
	track.BorderSizePixel=0; track.ZIndex=2; track.Parent=card; Corner(track,10)
	local tStroke=Stroke(track,T.Border,1)
	local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14)
	knob.Position=UDim2.new(0,3,0.5,-7); knob.BackgroundColor3=T.KnobOff
	knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=track; Corner(knob,7)
	card.MouseEnter:Connect(function() Tween(card,F,{BackgroundColor3=T.CardHover}); Tween(cStroke,F,{Color=T.BorderHover}) end)
	card.MouseLeave:Connect(function() Tween(card,F,{BackgroundColor3=T.Card}); Tween(cStroke,F,{Color=T.Border}) end)
	local btn=Instance.new("Frame"); btn.Size=UDim2.new(1,0,1,0)
	btn.BackgroundTransparency=1; btn.ZIndex=4; btn.Active=true; btn.Parent=card
	local keybindEntry={keyCode=nil}
	local function applyV(s)
		if s then
			knob.Position=UDim2.new(0,19,0.5,-7); knob.BackgroundColor3=T.KnobOn
			track.BackgroundColor3=T.TrackOn; tStroke.Color=T.TrackOn; bar.BackgroundColor3=T.Accent
		else
			knob.Position=UDim2.new(0,3,0.5,-7); knob.BackgroundColor3=T.KnobOff
			track.BackgroundColor3=T.TrackOff; tStroke.Color=T.Border; bar.BackgroundColor3=T.TrackOff
		end
	end
	local function doToggle()
		state=not state
		if state then
			Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,4,0.5,-6)})
			task.delay(0.06,function()
				Tween(knob,M,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,19,0.5,-7)})
				Tween(knob,M,{BackgroundColor3=T.KnobOn}); Tween(track,M,{BackgroundColor3=T.TrackOn})
				Tween(tStroke,M,{Color=T.TrackOn}); Tween(bar,M,{BackgroundColor3=T.Accent})
			end)
		else
			Tween(knob,TweenInfo.new(0.06),{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,18,0.5,-6)})
			task.delay(0.06,function()
				Tween(knob,M,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,3,0.5,-7)})
				Tween(knob,M,{BackgroundColor3=T.KnobOff}); Tween(track,M,{BackgroundColor3=T.TrackOff})
				Tween(tStroke,M,{Color=T.Border}); Tween(bar,M,{BackgroundColor3=T.TrackOff})
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
	local cardH=hasDesc and 50 or 38
	local card=Instance.new("Frame"); card.Size=UDim2.new(1,-12,0,cardH)
	card.BackgroundColor3=T.Card; card.BackgroundTransparency=0.1
	card.BorderSizePixel=0; card.Parent=parent; Corner(card,7)
	local cStroke=Stroke(card,T.Border,1)
	local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,2,0,cardH-14)
	bar.Position=UDim2.new(0,0,0,7); bar.BackgroundColor3=T.TrackOff
	bar.BorderSizePixel=0; bar.ZIndex=2; bar.Parent=card; Corner(bar,2)
	local nameY=hasDesc and 8 or (cardH/2-7)
	local nl2=Label(card,name,isMobile and 10 or 12,T.White,Enum.Font.GothamMedium)
	nl2.Size=UDim2.new(1,-62,0,14); nl2.Position=UDim2.new(0,10,0,nameY)
	nl2.ZIndex=2; nl2.TextTruncate=Enum.TextTruncate.AtEnd
	if hasDesc then
		local dl2=Label(card,desc,isMobile and 8 or 10,T.Dim,Enum.Font.Gotham)
		dl2.Size=UDim2.new(1,-62,0,12); dl2.Position=UDim2.new(0,10,0,nameY+16)
		dl2.ZIndex=2; dl2.TextTruncate=Enum.TextTruncate.AtEnd
	end
	local runLbl=Instance.new("TextLabel"); runLbl.Size=UDim2.new(0,44,0,20)
	runLbl.Position=UDim2.new(1,-50,0.5,-10); runLbl.BackgroundColor3=T.Card
	runLbl.BorderSizePixel=0; runLbl.Text="RUN"; runLbl.TextSize=10
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
		task.delay(0.3,function()
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
	local lbl=Label(btn,name,isMobile and 9 or 10,T.TabInact,Enum.Font.GothamBold)
	lbl.Size=UDim2.new(1,-2,1,0); lbl.Position=UDim2.new(0,1,0,0)
	lbl.TextXAlignment=Enum.TextXAlignment.Center; lbl.TextWrapped=true; lbl.ZIndex=6
	local sc=Instance.new("UITextSizeConstraint"); sc.MaxTextSize=10; sc.MinTextSize=5; sc.Parent=lbl
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
local ECOL_Y=Color3.fromRGB(255,190,40)
local ECOL_G=T.Green
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
					bb.Size=UDim2.fromOffset(70,20); bb.StudsOffset=Vector3.new(0,9,0)
					bb.AlwaysOnTop=true; bb.Adornee=mp; bb.MaxDistance=1200; bb.Parent=plot
					local outer=Instance.new("Frame",bb)
					outer.Size=UDim2.new(1,0,1,0); outer.BackgroundColor3=T.BG
					outer.BackgroundTransparency=0.1; outer.BorderSizePixel=0; Corner(outer,6)
					local innerBar=Instance.new("Frame",outer)
					innerBar.Size=UDim2.new(1,-4,0,2); innerBar.Position=UDim2.new(0,2,1,-3)
					innerBar.BackgroundColor3=ECOL_Y; innerBar.BorderSizePixel=0; Corner(innerBar,1)
					local dot=Instance.new("Frame",outer)
					dot.Size=UDim2.new(0,5,0,5); dot.Position=UDim2.new(0,4,0.5,-3)
					dot.BackgroundColor3=ECOL_Y; dot.BorderSizePixel=0; Corner(dot,3)
					local tl=Instance.new("TextLabel",outer)
					tl.Size=UDim2.new(1,-14,1,-4); tl.Position=UDim2.new(0,11,0,0)
					tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold
					tl.TextSize=9; tl.TextColor3=ECOL_Y; tl.TextXAlignment=Enum.TextXAlignment.Left
					timerESPs[plot.Name]={bb=bb,lbl=tl,bar=innerBar,dot=dot,outer=outer}; e=timerESPs[plot.Name]
				end
				e.lbl.Text=tl2.Text
				local m2,s2=tl2.Text:match("(%d+):(%d+)")
				if m2 and s2 then
					local tot=tonumber(m2)*60+tonumber(s2)
					local col=tot<=30 and ECOL_R or tot<=60 and ECOL_Y or ECOL_G
					e.lbl.TextColor3=col; e.bar.BackgroundColor3=col; e.dot.BackgroundColor3=col
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
	local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp or char:FindFirstChild(ESPTAG) then return end
	local box=Instance.new("BoxHandleAdornment",char)
	box.Name=ESPTAG; box.Adornee=hrp; box.Size=Vector3.new(4,6,2)
	box.Color3=T.Accent; box.Transparency=0.5; box.ZIndex=10; box.AlwaysOnTop=true
	local bb=Instance.new("BillboardGui",char)
	bb.Name=ESPTAG.."N"; bb.Adornee=char:FindFirstChild("Head") or hrp
	bb.Size=UDim2.fromOffset(110,22); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
	local bgE=Instance.new("Frame",bb)
	bgE.Size=UDim2.new(1,0,1,0); bgE.BackgroundColor3=T.BG
	bgE.BackgroundTransparency=0.22; bgE.BorderSizePixel=0; Corner(bgE,4); Stroke(bgE,T.Accent,0.8)
	local nl=Instance.new("TextLabel",bgE); nl.Size=UDim2.new(1,0,0.58,0)
	nl.BackgroundTransparency=1; nl.Text=plr.DisplayName
	nl.Font=Enum.Font.GothamBold; nl.TextSize=9; nl.TextColor3=T.White
	nl.TextStrokeTransparency=0.5; nl.TextStrokeColor3=Color3.new(0,0,0)
	local sl=Instance.new("TextLabel",bgE); sl.Size=UDim2.new(1,0,0.42,0)
	sl.Position=UDim2.new(0,0,0.58,0); sl.BackgroundTransparency=1
	sl.Text="@"..plr.Name; sl.Font=Enum.Font.Gotham; sl.TextSize=7; sl.TextColor3=T.Dim
end
for _,p in ipairs(Players:GetPlayers()) do if p~=lp then task.defer(function() mkESP(p) end) end end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end)
for _,p in ipairs(Players:GetPlayers()) do
	if p~=lp then p.CharacterAdded:Connect(function() task.wait(0.5); mkESP(p) end) end
end

local apCheckCache={}
local function checkPlayerHasAP(plr)
	if apCheckCache[plr.UserId]~=nil then return apCheckCache[plr.UserId] end
	local result=false
	pcall(function()
		local pg=plr:FindFirstChild("PlayerGui")
		if not pg then return end
		local ap=pg:FindFirstChild("AdminPanel")
		if ap then result=true; return end
	end)
	pcall(function()
		if not result then
			local pg=lp:FindFirstChild("PlayerGui")
			if not pg then return end
			local ap=pg:FindFirstChild("AdminPanel")
			if not ap then return end
			local plist=ap:FindFirstChild("Profiles",true)
			if plist and plist:FindFirstChild(plr.Name) then result=true end
		end
	end)
	apCheckCache[plr.UserId]=result
	return result
end
task.spawn(function()
	while task.wait(5) do
		apCheckCache={}
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=lp then
				pcall(function() checkPlayerHasAP(p) end)
			end
		end
	end
end)
Players.PlayerRemoving:Connect(function(p) apCheckCache[p.UserId]=nil end)

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

local function doFlash()
	local chr=lp and lp.Character
	local hrp=chr and chr:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local PODIUM_CFRAMES={
		[1]={[1]={hrp=CFrame.new(Vector3.new(-347.6983,-7.5033,-4.5494)),cam=CFrame.new(-357.0927,0.0048,-0.272)*CFrame.Angles(-0.954463,-0.903625,-0.837019)}},
		[2]={
			[1]={hrp=CFrame.new(Vector3.new(-349.9259,-7.3841,-1.578)),cam=CFrame.new(-361.8253,1.3324,5.126)*CFrame.Angles(-0.824269,-0.878251,-0.693896)},
			[2]={hrp=CFrame.new(Vector3.new(-348.4448,-7.1043,3.3442)),cam=CFrame.new(-358.5857,-0.0841,9.5148)*CFrame.Angles(-0.732523,-0.884924,-0.608084)},
			[3]={hrp=CFrame.new(-346.1821,-7.2885,-1.609)*CFrame.Angles(0,-1.247212,0),cam=CFrame.new(-360.1625,0.6353,3.1776)*CFrame.Angles(-0.932656,-1.049154,-0.86316)},
			[4]={hrp=CFrame.new(-343.6695,-7.0385,10.3377)*CFrame.Angles(0,-0.982332,0),cam=CFrame.new(-356.477,-0.7795,18.8846)*CFrame.Angles(-0.510736,-0.917793,-0.418726)},
			[5]={hrp=CFrame.new(-343.7608,-7.4124,-9.7994)*CFrame.Angles(0,-1.544676,0),cam=CFrame.new(-359.4998,-2.4726,-9.2893)*CFrame.Angles(-1.424811,-1.351549,-1.421283)},
			[6]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-325.655,-7.5033,54.5488)*CFrame.Angles(0,-0.69115,0),cam=CFrame.new(-338.7595,-4.0265,70.3894)*CFrame.Angles(-0.126016,-0.687243,-0.080199)},
			[7]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-344.4383,-7.5033,41.8672)*CFrame.Angles(0,-1.108982,0),cam=CFrame.new(-362.8094,-4.325,51.1551)*CFrame.Angles(-0.181885,-1.095968,-0.162135)},
			[8]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-348.5228,-7.5033,48.1022)*CFrame.Angles(0,-0.939336,0),cam=CFrame.new(-363.5051,-2.5713,59.0596)*CFrame.Angles(-0.30602,-0.916511,-0.245634)},
			[9]={hrp=CFrame.new(-339.6349,-7.5033,60.4164)*CFrame.Angles(0,-0.405266,0),cam=CFrame.new(-346.7646,-3.7365,77.0351)*CFrame.Angles(-0.137335,-0.401849,-0.054002)},
			[10]={hrp=CFrame.new(-339.4453,-7.5033,61.9429)*CFrame.Angles(0,-0.29845,0),cam=CFrame.new(-342.5024,-5.2211,71.8802)*CFrame.Angles(-0.081543,-0.297517,-0.023953)},
			[11]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-331.5262,-7.5033,-47.3607)*CFrame.Angles(0,0.003141,0),cam=CFrame.new(-331.4885,-9.6045,-59.3396)*CFrame.Angles(2.851853,-0.097011,-3.140695),fwdOffset=Vector3.new(0,0,-3)},
			[12]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-338.729,-7.5033,-43.4714)*CFrame.Angles(0,-1.420208,0),cam=CFrame.new(-345.1804,-9.9578,-56.8524)*CFrame.Angles(2.856299,-0.433315,3.01906),fwdOffset=Vector3.new(0,0,-3)},
			[13]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-334.5183,-7.5033,-41.6819)*CFrame.Angles(0,-0.543495,0),cam=CFrame.new(-341.912,-9.959,-53.9192)*CFrame.Angles(2.831168,-0.52207,2.982964),fwdOffset=Vector3.new(0,0,-3)},
			[14]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-319.8298,-7.5033,-45.1476)*CFrame.Angles(0,-0.323585,0),cam=CFrame.new(-323.983,-9.9618,-57.5315)*CFrame.Angles(2.834406,-0.309406,3.045298),fwdOffset=Vector3.new(0,0,-3)},
			[15]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-317.917,-7.5033,-41.9999)*CFrame.Angles(0,-0.565487,0),cam=CFrame.new(-325.8,-9.9581,-54.4216)*CFrame.Angles(2.835549,-0.544183,2.979445),fwdOffset=Vector3.new(0,0,-3)},
			[16]={hrp=CFrame.new(-338.285,-7.5033,57.204)*CFrame.Angles(0,-0.207346,0),cam=CFrame.new(-340.4345,-9.5916,67.4219)*CFrame.Angles(0.335111,-0.196113,0.067755)},
			[17]={hrp=CFrame.new(-337.9285,-7.5033,55.1757)*CFrame.Angles(0,-0.430398,0),cam=CFrame.new(-341.7441,-8.9535,63.4867)*CFrame.Angles(0.337895,-0.408747,0.138758)},
			[18]={hrp=CFrame.new(-332.1088,-7.5033,53.1675)*CFrame.Angles(0,-0.49323,0),cam=CFrame.new(-336.3932,-9.2396,61.1377)*CFrame.Angles(0.382481,-0.462609,0.177644)},
			[19]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-328.579,-3.1209,-35.0857)*CFrame.Angles(0,0.021988,0),cam=CFrame.new(-328.5137,-10.011,-45.4753)*CFrame.Angles(2.387391,-0.004579,3.137291),fwdOffset=Vector3.new(0,0,-3)},
			[20]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-321.5783,-7.5033,-33.5778)*CFrame.Angles(0,0.006284,0),cam=CFrame.new(-321.5535,-10.0218,-37.5259)*CFrame.Angles(2.387391,-0.004579,3.137291),fwdOffset=Vector3.new(0,0,-3)},
			[21]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-314.088,-7.5033,-32.1806)*CFrame.Angles(0,-0.006282,0),cam=CFrame.new(-314.1147,-10.0174,-36.4214)*CFrame.Angles(2.387391,-0.004579,3.137291),fwdOffset=Vector3.new(0,0,-3)},
			[22]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-306.8919,-7.5033,-33.9124)*CFrame.Angles(0,-0.006284,0),cam=CFrame.new(-306.923,-10.008,-38.86)*CFrame.Angles(2.4648,-0.004898,3.137657),fwdOffset=Vector3.new(0,0,-3)},
			[23]={hrpWalk=CFrame.new(-351.5396,-7.5033,-41.797),hrp=CFrame.new(-300.2759,-7.5033,-32.7047)*CFrame.Angles(0,-0.031416,0),cam=CFrame.new(-300.4669,-10.016,-37.044)*CFrame.Angles(2.399014,-0.032413,3.111857),fwdOffset=Vector3.new(0,0,-3)},
			[24]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-330.0484,-7.5033,48.183)*CFrame.Angles(0,-0.006377,0),cam=CFrame.new(-330.1124,-10.0063,53.2779)*CFrame.Angles(0.662308,-0.00991,0.007727)},
			[25]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-325.4576,-7.5033,46.8182)*CFrame.Angles(0,-0.125663,0),cam=CFrame.new(-326.0541,-10.0104,51.5397)*CFrame.Angles(0.700033,-0.09632,0.080833)},
			[26]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-324.6721,-7.5033,47.2033)*CFrame.Angles(0,-0.40212,0),cam=CFrame.new(-326.6859,-10.0057,51.9385)*CFrame.Angles(0.698024,-0.314979,0.254268)},
			[27]={hrpWalk=CFrame.new(-348.2407,-7.5033,74.3719),hrp=CFrame.new(-320.4196,-7.5033,44.1)*CFrame.Angles(0,-0.571769,0),cam=CFrame.new(-322.9213,-10.0122,49.5157)*CFrame.Angles(0.876985,-0.422603,0.397417)},
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
		local CARPET_SPEED=220
		local ARRIVE_DIST=3.5
		local TIMEOUT=8
		local player=Players.LocalPlayer
		local targetPos=(entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
		if entry.fwdOffset then
			targetPos=targetPos+entry.fwdOffset
		end

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

		local carpet=findTool("flying carpet") or findTool("carpet")
		if carpet then
			doEquip(carpet,0.8)
			pcall(function()
				local v=carpet:FindFirstChild("Speed") or carpet:FindFirstChild("WalkSpeed")
				if v then v.Value=CARPET_SPEED end
			end)
		end

		local stealCtx
		local _lateSlots={[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,[19]=true,[20]=true,[21]=true,[22]=true,[23]=true}
		if not _lateSlots[slot] then
			task.spawn(function()
				local chr3=player.Character; local hrp3=chr3 and chr3:FindFirstChild("HumanoidRootPart")
				local dest=(entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
				if entry.fwdOffset then dest=dest+entry.fwdOffset end
				local dist=hrp3 and (hrp3.Position-dest).Magnitude or 0
				local POST=0.08+0.12+0.06+0.25+0.10
				local pre=math.max(0,(dist/math.max(CARPET_SPEED,1))+POST-__AG_MIN_HOLD_TIME)
				if pre>0 then task.wait(pre) end
				local tp=__AG_findPrompt(); if tp then stealCtx=__AG_startHold(tp) end
			end)
		end

		local boostConn
		boostConn=RunService.Heartbeat:Connect(function()
			if not player.Character then return end
			local hrp2=player.Character:FindFirstChild("HumanoidRootPart")
			local hum2=player.Character:FindFirstChildOfClass("Humanoid")
			if not hrp2 or not hum2 then return end
			local diff=targetPos-hrp2.Position
			local flat=Vector3.new(diff.X,0,diff.Z)
			if flat.Magnitude>ARRIVE_DIST then
				local dir=flat.Unit
				hrp2.Velocity=Vector3.new(dir.X*CARPET_SPEED,hrp2.Velocity.Y,dir.Z*CARPET_SPEED)
			else hrp2.Velocity=Vector3.new(0,hrp2.Velocity.Y,0) end
		end)

		local chr2=player.Character; local hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
		if hum2 then hum2:MoveTo(targetPos) end
		local dl=tick()+TIMEOUT; local _lmt=0
		repeat
			task.wait(); chr2=player.Character
			local hrp2=chr2 and chr2:FindFirstChild("HumanoidRootPart")
			hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if not (hrp2 and hum2) then break end
			if tick()-_lmt>=0.1 then hum2:MoveTo(targetPos); _lmt=tick() end
			if (hrp2.Position-targetPos).Magnitude<ARRIVE_DIST then break end
		until tick()>dl

		if boostConn then boostConn:Disconnect(); boostConn=nil end
		do
			local _c=player.Character; local _h=_c and _c:FindFirstChild("HumanoidRootPart")
			local _hm=_c and _c:FindFirstChildOfClass("Humanoid")
			if _h and _hm then
				_hm:MoveTo(_h.Position); _h.Velocity=Vector3.zero; _h.Anchored=true
				task.defer(function() task.defer(function()
					local _c2=player.Character; local _h2=_c2 and _c2:FindFirstChild("HumanoidRootPart")
					if _h2 then _h2.Velocity=Vector3.zero; _h2.Anchored=false end
				end) end)
			end
		end

		if _lateSlots[slot] then
			task.spawn(function()
				local _chr3=player.Character; local _hrp3=_chr3 and _chr3:FindFirstChild("HumanoidRootPart")
				local _fp=entry.hrp.Position
				if entry.fwdOffset then _fp=_fp+entry.fwdOffset end
				local _d2=_hrp3 and (_hrp3.Position-_fp).Magnitude or 0
				local _POST2=0.08+0.12+0.06+0.25+0.10
				local _pre2=math.max(0,(_d2/math.max(CARPET_SPEED,1))+_POST2-__AG_MIN_HOLD_TIME)
				if _pre2>0 then task.wait(_pre2) end
				local _tp=__AG_findPrompt(); if _tp then stealCtx=__AG_startHold(_tp) end
			end)
		end

		if entry.hrpWalk then
			local finalPos=entry.hrp.Position
			if entry.fwdOffset then finalPos=finalPos+entry.fwdOffset end
			local bc2; bc2=RunService.Heartbeat:Connect(function()
				if not player.Character then return end
				local hrp3=player.Character:FindFirstChild("HumanoidRootPart")
				local hum3=player.Character:FindFirstChildOfClass("Humanoid")
				if not hrp3 or not hum3 then return end
				local diff3=finalPos-hrp3.Position; local flat3=Vector3.new(diff3.X,0,diff3.Z)
				if flat3.Magnitude>ARRIVE_DIST then
					local d3=flat3.Unit; hrp3.Velocity=Vector3.new(d3.X*CARPET_SPEED,hrp3.Velocity.Y,d3.Z*CARPET_SPEED)
				else hrp3.Velocity=Vector3.new(0,hrp3.Velocity.Y,0) end
			end)
			chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hum2 then hum2:MoveTo(finalPos) end
			local dl2=tick()+TIMEOUT; local _lmt2=0
			repeat
				task.wait(); chr2=player.Character
				local hrp2b=chr2 and chr2:FindFirstChild("HumanoidRootPart")
				hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
				if not (hrp2b and hum2) then break end
				if tick()-_lmt2>=0.1 then hum2:MoveTo(finalPos); _lmt2=tick() end
				if (hrp2b.Position-finalPos).Magnitude<ARRIVE_DIST then break end
			until tick()>dl2
			bc2:Disconnect()
			chr2=player.Character; local hrpStop=chr2 and chr2:FindFirstChild("HumanoidRootPart")
			hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hrpStop and hum2 then
				hrpStop.CFrame=entry.hrp*(entry.fwdOffset and CFrame.new(entry.fwdOffset) or CFrame.new())
				hrpStop.Velocity=Vector3.zero; hrpStop.Anchored=true
				task.defer(function() task.defer(function()
					local _c=player.Character; local _h=_c and _c:FindFirstChild("HumanoidRootPart")
					if _h then _h.Velocity=Vector3.zero; _h.Anchored=false end
				end) end)
			end
		else
			chr2=player.Character; local hrpStop=chr2 and chr2:FindFirstChild("HumanoidRootPart")
			hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hrpStop then
				hrpStop.CFrame=entry.hrp*(entry.fwdOffset and CFrame.new(entry.fwdOffset) or CFrame.new())
				hrpStop.Velocity=Vector3.zero; hrpStop.Anchored=true
				task.defer(function() task.defer(function()
					local _c=player.Character; local _h=_c and _c:FindFirstChild("HumanoidRootPart")
					if _h then _h.Velocity=Vector3.zero; _h.Anchored=false end
				end) end)
			end
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
		if carpetMid then doEquip(carpetMid,1.2) end
		task.wait(0.25)

		if slot>=19 and slot<=27 then
			chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hum2 then hum2:ChangeState(Enum.HumanoidStateType.Jumping) end
		end

		chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
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

		pcall(function() hum2:UnequipTools() end); task.wait(0.05)

		flashTool.Parent=chr2
		local _fe=false; local _fc
		_fc=flashTool.Equipped:Connect(function() _fe=true; if _fc then _fc:Disconnect(); _fc=nil end end)
		pcall(function() hum2:EquipTool(flashTool) end)
		local _eq=tick()+1.5; while not _fe and tick()<_eq do task.wait() end
		if _fc then pcall(function() _fc:Disconnect() end); _fc=nil end

		if not _fe then
			chr2=player.Character; hum2=chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hum2 then
				flashTool.Parent=chr2
				pcall(function() hum2:EquipTool(flashTool) end)
				task.wait(0.15)
			end
		end

		pcall(function() flashTool:Activate() end)
		task.wait(0.015); pcall(function() flashTool:Activate() end)

		task.spawn(function()
			task.wait(0.06)
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

		task.wait(0.06)
		if hum2 then pcall(function() hum2:UnequipTools() end) end
		task.wait(0.04)
		local bp2=player:FindFirstChild("Backpack")
		if bp2 and flashTool and flashTool.Parent~=bp2 then flashTool.Parent=bp2 end

		if RagdollBypassEnabled then
			task.spawn(function()
				task.wait(0.08)
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
					local pp=potion.Parent
					if pp~=char then
						potion.Parent=char
						pcall(function() hum3:EquipTool(potion) end)
						task.wait(0.06)
					end
					pcall(function() potion:Activate() end)
					task.wait(0.04)
					if potion.Parent~=bp3 and bp3 then potion.Parent=bp3 end
				end
				task.wait(0.04)
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
				local cf2,pf2=_raf(); if not cf2 or not pf2 then
					if stealCtx then triggerAutoBlock(); __AG_finish(stealCtx)
					else
						local fp2=__AG_findPrompt()
						if fp2 then stealCtx=__AG_startHold(fp2); triggerAutoBlock(); __AG_finish(stealCtx) end
					end
					return
				end
				local pn=lp.Name
				local pb2=pf2:FindFirstChild(pn); local rb2=cf2:FindFirstChild("ragdoll")
				if not pb2 or not rb2 then
					if stealCtx then triggerAutoBlock(); __AG_finish(stealCtx) end; return
				end
				if not _rp[pn] then _rp[pn]=_rca(pb2) end
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
		if carpetAfter then doEquip(carpetAfter,0.8) end
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

	local noResultsLbl=Label(BrainrotsTab.scroll,"No brainrots found",11,T.Dim,Enum.Font.GothamMedium)
	noResultsLbl.Size=UDim2.new(1,-12,0,30); noResultsLbl.TextXAlignment=Enum.TextXAlignment.Center
	noResultsLbl.Visible=false

	local cardContainer=Instance.new("Frame"); cardContainer.Name="BrainrotCards"
	cardContainer.BackgroundTransparency=1; cardContainer.Size=UDim2.new(1,-12,0,0)
	cardContainer.AutomaticSize=Enum.AutomaticSize.Y; cardContainer.BorderSizePixel=0
	cardContainer.Parent=BrainrotsTab.scroll
	local cl=Instance.new("UIListLayout"); cl.FillDirection=Enum.FillDirection.Vertical
	cl.HorizontalAlignment=Enum.HorizontalAlignment.Center; cl.SortOrder=Enum.SortOrder.LayoutOrder
	cl.Padding=UDim.new(0,5); cl.Parent=cardContainer

	local builtUIDs,labelUpdaters,onSelectCBs={},{},{}
	local selectedUID=nil

	local CARD_H=isMobile and 90 or 86
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

		local topRow=Instance.new("Frame"); topRow.Size=UDim2.new(1,0,0,16)
		topRow.Position=UDim2.new(0,0,0,6); topRow.BackgroundTransparency=1; topRow.ZIndex=3; topRow.Parent=infoFrame
		local nl3=Label(topRow,rec.name,isMobile and 10 or 12,T.White,Enum.Font.GothamBold)
		nl3.Size=UDim2.new(1,-54,1,0); nl3.Position=UDim2.new(0,0,0,0)
		nl3.TextTruncate=Enum.TextTruncate.AtEnd; nl3.ZIndex=3

		local apBadge=Instance.new("TextLabel"); apBadge.Size=UDim2.new(0,42,0,14)
		apBadge.Position=UDim2.new(1,-44,0,1); apBadge.BackgroundColor3=T.Card
		apBadge.BorderSizePixel=0; apBadge.Text="AP --"; apBadge.TextSize=8
		apBadge.Font=Enum.Font.GothamBold; apBadge.TextColor3=T.Dim
		apBadge.TextXAlignment=Enum.TextXAlignment.Center
		apBadge.ZIndex=4; apBadge.Parent=topRow; Corner(apBadge,4); Stroke(apBadge,T.Border,0.8)

		local mutTxt=(rec.mutation and tostring(rec.mutation)~="None") and tostring(rec.mutation) or "No Mutation"
		local mutLbl2=Label(infoFrame,mutTxt,isMobile and 8 or 10,mutCol,Enum.Font.GothamMedium)
		mutLbl2.Size=UDim2.new(1,-54,0,12); mutLbl2.Position=UDim2.new(0,0,0,24)
		mutLbl2.TextTruncate=Enum.TextTruncate.AtEnd; mutLbl2.ZIndex=3
		local genLbl3=Label(infoFrame,"⚡ "..rec.genText,isMobile and 8 or 10,T.Green,Enum.Font.GothamBold)
		genLbl3.Size=UDim2.new(1,-54,0,12); genLbl3.Position=UDim2.new(0,0,0,38); genLbl3.ZIndex=3
		local rarLbl=Label(infoFrame,rec.rarity or "",isMobile and 7 or 9,T.Dim,Enum.Font.GothamBold)
		rarLbl.Size=UDim2.new(1,-54,0,11); rarLbl.Position=UDim2.new(0,0,0,52); rarLbl.ZIndex=3
		local podLbl=Label(infoFrame,(rec.plotOrder or rec.plotName).." • #"..rec.slot,isMobile and 7 or 9,T.Dim,Enum.Font.GothamMedium)
		podLbl.Size=UDim2.new(1,-54,0,11); podLbl.Position=UDim2.new(0,0,0,64)
		podLbl.TextTruncate=Enum.TextTruncate.AtEnd; podLbl.ZIndex=3

		local selBtn2=Instance.new("TextButton"); selBtn2.Size=UDim2.new(0,46,0,20)
		selBtn2.Position=UDim2.new(1,-50,0.5,-10); selBtn2.BackgroundColor3=T.Card
		selBtn2.BorderSizePixel=0; selBtn2.Text="SELECT"; selBtn2.TextSize=isMobile and 7 or 8
		selBtn2.Font=Enum.Font.GothamBold; selBtn2.TextColor3=T.Dim; selBtn2.ZIndex=4
		selBtn2.AutoButtonColor=false; selBtn2.Parent=card; Corner(selBtn2,5)
		local selStroke2=Stroke(selBtn2,T.Border,1)

		task.spawn(function()
			local ownerPlr=nil
			for _,p in ipairs(Players:GetPlayers()) do
				if p~=lp and (p.Name==rec.ownerName or p.DisplayName==rec.ownerName) then
					ownerPlr=p; break
				end
			end
			if ownerPlr then
				local hasAP=checkPlayerHasAP(ownerPlr)
				if hasAP then
					apBadge.Text="AP Yes"; apBadge.TextColor3=T.Green
					TweenService:Create(apBadge,F,{BackgroundColor3=Color3.fromRGB(8,24,12)}):Play()
					pcall(function() apBadge:FindFirstChildOfClass("UIStroke").Color=T.Green end)
				else
					apBadge.Text="AP No"; apBadge.TextColor3=T.Red
					TweenService:Create(apBadge,F,{BackgroundColor3=Color3.fromRGB(24,8,8)}):Play()
					pcall(function() apBadge:FindFirstChildOfClass("UIStroke").Color=T.Red end)
				end
			end
		end)

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
		local function bindRemote(obj)
			if not obj:IsA("RemoteEvent") then return end
			pcall(function()
				obj.OnClientEvent:Connect(function(...)
					if not AutoResetBalloonEnabled then return end
					for i=1,select("#",...) do
						local a=select(i,...)
						if type(a)=="string" and a:lower():find("jump higher",1,true) then
							doReset(); return
						end
					end
				end)
			end)
		end
		local function startARB()
			for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do bindRemote(obj) end
			ReplicatedStorage.DescendantAdded:Connect(function(obj)
				if AutoResetBalloonEnabled then bindRemote(obj) end
			end)
		end
		CreateToggle(SettingsTab.scroll,"Reset on balloon","auto resets if someone balloons u",function(v)
			AutoResetBalloonEnabled=v
			if v then startARB() end
		end)
	end

	CreateSection(SettingsTab.scroll,"GRAB")
	CreateToggle(SettingsTab.scroll,"Auto Block","blocks the plot owner right after u grab",function(v) AutoBlockEnabled=v end)

	CreateSection(SettingsTab.scroll,"FLASH")
	CreateToggle(SettingsTab.scroll,"Auto Flash","auto flashes when ballooned then grabs",function(v)
		AutoFlashEnabled=v
		if v then
			local _afLast=0; local _afPending=false
			local function tryAF()
				if not AutoFlashEnabled then return end
				if not _G._FH_SelectedBrainrot then return end
				if _afPending then return end; _afPending=true
				task.spawn(function()
					if _G._FH_DoSelectedReset then pcall(_G._FH_DoSelectedReset) end
					local dl=tick()+8
					while (not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart")) and tick()<dl do task.wait(0.1) end
					if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then _afPending=false; return end
					task.wait(0.12)
					if not AutoFlashEnabled then _afPending=false; return end
					if _G._FH_FlashBtnEntry then pcall(_G._FH_FlashBtnEntry.fire) end
					task.wait(3); _afPending=false
				end)
			end
			for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do
				if obj:IsA("RemoteEvent") then
					pcall(function()
						obj.OnClientEvent:Connect(function(...)
							if not AutoFlashEnabled then return end
							for i=1,select("#",...) do
								local a=select(i,...)
								if type(a)=="string" and a:lower():find("jump higher",1,true) then
									local now=tick(); if now-_afLast<3 then return end; _afLast=now; tryAF(); return
								end
							end
						end)
					end)
				end
			end
		end
	end)

	CreateToggle(SettingsTab.scroll,"Ragdoll Bypass","uses potion + ragdoll self to bypass ragdoll",function(v)
		RagdollBypassEnabled=v
	end)

	CreateToggle(SettingsTab.scroll,"Anti Ragdoll","stops ragdoll from working on u",function(v)
		if v then AntiRagdoll.enable() else AntiRagdoll.disable() end
	end)

	CreateSection(SettingsTab.scroll,"PROTECTION")
	CreateToggle(SettingsTab.scroll,"Anti Admin Panel","blocks tiny jail ragdoll giant and inverse",function(v)
		AntiAdminEnabled=v
	end)

	CreateSection(SettingsTab.scroll,"BRAINROTS")
	CreateToggle(SettingsTab.scroll,"Auto Select Best","auto picks the highest gen brainrot",function(v)
		AutoSelectBestBrainrot=v; Config.toggles["Auto Select Best"]=v; pcall(FH_Save)
		if v and _G._FH_LastAnimalScan and #_G._FH_LastAnimalScan>0 then pcall(_G._FH_AutoSelectBest) end
	end)

	CreateSection(SettingsTab.scroll,"ADMIN PANEL")
	do
		local FP={win=nil,visible=false,minimized=false}
		local FP_W=isMobile and 320 or 400
		local FP_ROW_H=isMobile and 36 or 44
		local FP_AVT=isMobile and 26 or 32
		local FP_BTN=isMobile and 24 or 28
		local FP_GAP=4
		local FP_HDR_H=34
		local FP_CMDS={{name="tiny",emoji="🤏"},{name="jail",emoji="🔒"},{name="rocket",emoji="🚀"},{name="ragdoll",emoji="🏃"},{name="balloon",emoji="🎈"}}
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
									btn2.Text=cdTxt; btn2.TextSize=10
									btn2.TextColor3=T.Red; btn2.BackgroundTransparency=0.55
								else
									btn2.Text=emoji; btn2.TextSize=isMobile and 14 or 17
									btn2.TextColor3=T.White; btn2.BackgroundTransparency=0.28
								end
							end
						end
					end
					task.wait(0.3)
				end; fpCoolRunning=false
			end)
		end

		local FP_MAX_ROWS=4
		local function fpH(rows)
			local r=math.min(rows,FP_MAX_ROWS)
			return FP_HDR_H+4+r*FP_ROW_H+math.max(0,r-1)*3+8
		end
		local function fpResize(rows,anim)
			if not FP.win or FP.minimized then return end
			local h=fpH(rows)
			if anim then Tween(FP.win,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,FP_W,0,h)})
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
			Corner(win,10)
			local ws=Instance.new("UIStroke"); ws.Thickness=1.4; ws.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
			ws.Color=T.AccentBright; ws.Parent=win
			local wg=Instance.new("UIGradient"); wg.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,Color3.fromRGB(30,60,160)),
				ColorSequenceKeypoint.new(0.5,Color3.fromRGB(120,180,255)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(30,60,160)),
			}); wg.Rotation=45; wg.Parent=ws
			local hdr2=Instance.new("Frame"); hdr2.Size=UDim2.new(1,0,0,FP_HDR_H)
			hdr2.BackgroundColor3=T.Header; hdr2.BorderSizePixel=0; hdr2.ZIndex=31; hdr2.Parent=win; Corner(hdr2,10)
			local hf2=Instance.new("Frame"); hf2.Size=UDim2.new(1,0,0,10); hf2.Position=UDim2.new(0,0,1,-10)
			hf2.BackgroundColor3=T.Header; hf2.BorderSizePixel=0; hf2.ZIndex=31; hf2.Parent=hdr2
			local tl2=Label(hdr2,"⚡ Quick Panel",isMobile and 11 or 13,T.White,Enum.Font.GothamBold)
			tl2.Size=UDim2.new(1,-50,1,0); tl2.Position=UDim2.new(0,10,0,0); tl2.ZIndex=32
			local mb2=Instance.new("TextButton"); mb2.Size=UDim2.new(0,20,0,16)
			mb2.AnchorPoint=Vector2.new(1,0.5); mb2.Position=UDim2.new(1,-8,0.5,0)
			mb2.BackgroundColor3=T.Card; mb2.BorderSizePixel=0; mb2.AutoButtonColor=false
			mb2.Text="—"; mb2.TextSize=9; mb2.Font=Enum.Font.GothamBold
			mb2.TextColor3=T.Dim; mb2.ZIndex=33; mb2.Parent=hdr2; Corner(mb2,4); Stroke(mb2,T.Border,1)
			local scroll2=Instance.new("ScrollingFrame"); scroll2.Name="FPScroll"
			scroll2.Size=UDim2.new(1,-10,1,-(FP_HDR_H+6)); scroll2.Position=UDim2.new(0,5,0,FP_HDR_H+4)
			scroll2.BackgroundTransparency=1; scroll2.BorderSizePixel=0; scroll2.ScrollBarThickness=0
			scroll2.ScrollBarImageColor3=T.Dim; scroll2.CanvasSize=UDim2.new(0,0,0,0); scroll2.ZIndex=31; scroll2.Parent=win
			local ll2=Instance.new("UIListLayout"); ll2.Padding=UDim.new(0,3)
			ll2.SortOrder=Enum.SortOrder.LayoutOrder; ll2.HorizontalAlignment=Enum.HorizontalAlignment.Center; ll2.Parent=scroll2
			ll2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scroll2.CanvasSize=UDim2.new(0,0,0,ll2.AbsoluteContentSize.Y+8)
			end)
			local ntl=Label(win,"No other players",isMobile and 8 or 10,T.Dim,Enum.Font.GothamMedium)
			ntl.Size=UDim2.new(1,-20,0,22); ntl.Position=UDim2.new(0,10,0,FP_HDR_H+8)
			ntl.TextXAlignment=Enum.TextXAlignment.Center; ntl.Visible=false; ntl.ZIndex=31
			FP.win=win; FP.scroll=scroll2; FP.listLayout=ll2; FP.noTargetLbl=ntl; FP.hdr=hdr2
			mb2.MouseButton1Click:Connect(function()
				FP.minimized=not FP.minimized
				if FP.minimized then
					Tween(win,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,FP_W,0,FP_HDR_H)})
					scroll2.Visible=false; ntl.Visible=false
				else scroll2.Visible=true; fpRefreshPlayers() end
			end)
			do
				local _d=false; local _ds=nil; local _ws=nil
				hdr2.InputBegan:Connect(function(inp)
					if inp.UserInputType==Enum.UserInputType.MouseButton1 then _d=true; _ds=inp.Position; _ws=win.Position end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if _d and inp.UserInputType==Enum.UserInputType.MouseMovement then
						local d=inp.Position-_ds; win.Position=UDim2.new(_ws.X.Scale,_ws.X.Offset+d.X,_ws.Y.Scale,_ws.Y.Offset+d.Y)
					end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType==Enum.UserInputType.MouseButton1 then _d=false end
				end)
			end
		end

		local function fpMakeRow(plr,order)
			local row=Instance.new("Frame"); row.Name="FPRow_"..plr.Name
			row.Size=UDim2.new(1,-6,0,FP_ROW_H); row.BackgroundColor3=T.Card; row.BackgroundTransparency=0.1
			row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=32; row.Parent=FP.scroll
			Corner(row,6); Stroke(row,T.Border,1)
			local af=Instance.new("Frame"); af.Size=UDim2.new(0,FP_AVT,0,FP_AVT)
			af.Position=UDim2.new(0,5,0.5,-FP_AVT/2); af.BackgroundColor3=T.BG; af.BackgroundTransparency=0.4
			af.BorderSizePixel=0; af.ZIndex=33; af.Parent=row; Corner(af,math.floor(FP_AVT/2))
			local ai=Instance.new("ImageLabel"); ai.Size=UDim2.new(1,0,1,0); ai.BackgroundTransparency=1
			ai.Image=("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=48&height=48&format=png"):format(plr.UserId)
			ai.ScaleType=Enum.ScaleType.Crop; ai.ZIndex=34; ai.Parent=af; Corner(ai,math.floor(FP_AVT/2))
			local dText=plr.DisplayName~=plr.Name and plr.DisplayName.." (@"..plr.Name..")" or plr.DisplayName

			local BTN_BLOCK=5*FP_BTN+4*FP_GAP
			local NAME_X=5+FP_AVT+5
			local BTNS_X=FP_W-8-BTN_BLOCK

			local rowTop=Instance.new("Frame"); rowTop.Size=UDim2.new(0,BTNS_X-NAME_X-4,0,FP_ROW_H*0.56)
			rowTop.Position=UDim2.new(0,NAME_X,0,0); rowTop.BackgroundTransparency=1; rowTop.ZIndex=33; rowTop.Parent=row
			local nl4=Label(rowTop,dText,isMobile and 10 or 12,T.White,Enum.Font.GothamBold)
			nl4.Size=UDim2.new(1,0,1,0); nl4.Position=UDim2.new(0,0,0,0)
			nl4.TextTruncate=Enum.TextTruncate.AtEnd; nl4.TextXAlignment=Enum.TextXAlignment.Left; nl4.ZIndex=33

			local apRowBadge=Instance.new("TextLabel"); apRowBadge.Size=UDim2.new(0,40,0,12)
			apRowBadge.Position=UDim2.new(0,NAME_X,0.5,2); apRowBadge.BackgroundColor3=T.Card
			apRowBadge.BorderSizePixel=0; apRowBadge.Text="AP --"; apRowBadge.TextSize=8
			apRowBadge.Font=Enum.Font.GothamBold; apRowBadge.TextColor3=T.Dim
			apRowBadge.TextXAlignment=Enum.TextXAlignment.Center
			apRowBadge.ZIndex=34; apRowBadge.Parent=row; Corner(apRowBadge,3); Stroke(apRowBadge,T.Border,0.8)

			task.spawn(function()
				local hasAP=checkPlayerHasAP(plr)
				if hasAP then
					apRowBadge.Text="AP Yes"; apRowBadge.TextColor3=T.Green
					TweenService:Create(apRowBadge,F,{BackgroundColor3=Color3.fromRGB(8,24,12)}):Play()
				else
					apRowBadge.Text="AP No"; apRowBadge.TextColor3=T.Red
					TweenService:Create(apRowBadge,F,{BackgroundColor3=Color3.fromRGB(24,8,8)}):Play()
				end
			end)

			row.MouseEnter:Connect(function() Tween(row,F,{BackgroundColor3=T.CardHover}) end)
			row.MouseLeave:Connect(function() Tween(row,F,{BackgroundColor3=T.Card}) end)
			for i,cmd in ipairs(FP_CMDS) do
				local xPos=BTNS_X+(i-1)*(FP_BTN+FP_GAP)
				local btn3=Instance.new("TextButton"); btn3.Name="FPCmd_"..cmd.name
				btn3.Size=UDim2.new(0,FP_BTN,0,FP_BTN); btn3.Position=UDim2.new(0,xPos,0.5,-FP_BTN/2)
				btn3.BackgroundColor3=T.Card; btn3.BackgroundTransparency=0.28
				btn3.Text=cmd.emoji; btn3.TextSize=isMobile and 14 or 17
				btn3.Font=Enum.Font.SourceSans; btn3.AutoButtonColor=false; btn3.ZIndex=33; btn3.Parent=row
				Corner(btn3,4); Stroke(btn3,T.Border,1)
				table.insert(fpCoolBtns[cmd.name],{btn3,cmd.emoji})
				btn3.MouseEnter:Connect(function() if not fpIsCD(cmd.name) then Tween(btn3,F,{BackgroundColor3=T.CardHover,BackgroundTransparency=0}) end end)
				btn3.MouseLeave:Connect(function() if not fpIsCD(cmd.name) then Tween(btn3,F,{BackgroundColor3=T.Card,BackgroundTransparency=0.28}) end end)
				local function fireCmd()
					if fpIsCD(cmd.name) then return end
					task.spawn(function() fpFireCmd(plr,cmd.name) end)
					Tween(btn3,TweenInfo.new(0.08,Enum.EasingStyle.Quad),{BackgroundColor3=T.AccentBright,BackgroundTransparency=0})
					task.delay(0.2,function() Tween(btn3,F,{BackgroundColor3=T.Card,BackgroundTransparency=0.28}) end)
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
		CreateToggle(SettingsTab.scroll,"Quick Panel","fast admin command panel for all players",function(v) fpShow(v) end)
	end

	CreateSection(SettingsTab.scroll,"SERVER")
	CreateButton(SettingsTab.scroll,"Rejoin Server",nil,function()
		game:GetService("TeleportService"):Teleport(game.PlaceId,lp)
	end)
end

local _uiVisible=true
local _uiAnim=false
local SHOW_TI=TweenInfo.new(0.26,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local HIDE_TI=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
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
