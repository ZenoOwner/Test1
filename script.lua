local plr = game.Players.LocalPlayer
local gui = plr:WaitForChild("PlayerGui")
local ts = game:GetService("TweenService")

local sg = Instance.new("ScreenGui")
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.Parent = gui

local black = Instance.new("Frame")
black.Size = UDim2.new(1,0,1,0)
black.BackgroundColor3 = Color3.fromRGB(0,0,0)
black.BackgroundTransparency = 1
black.Parent = sg

local txt = Instance.new("TextLabel")
txt.Size = UDim2.new(1,0,1,0)
txt.BackgroundTransparency = 1
txt.TextColor3 = Color3.fromRGB(255,255,255)
txt.TextTransparency = 1
txt.Font = Enum.Font.GothamBold
txt.TextScaled = true
txt.Parent = black

local tin = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tout = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function show(text)
	txt.Text = text
	ts:Create(txt, tin, {TextTransparency = 0}):Play()
	task.wait(2.2)
	ts:Create(txt, tout, {TextTransparency = 1}):Play()
	task.wait(0.9)
end

ts:Create(black, tin, {BackgroundTransparency = 0}):Play()
task.wait(0.8)

show("this file was leaked by @g83w on dc")
show("raq love thunder as hes his little kitten")
show("thats what u get dumbass")

ts:Create(black, tout, {BackgroundTransparency = 1}):Play()
task.wait(1)

sg:Destroy()

task.wait(2) 

local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local StarterGui         = game:GetService("StarterGui")
local LocalPlayer        = Players.LocalPlayer
local VirtualInputManager = Instance.new("VirtualInputManager")

local AutoBlockEnabled       = false
local AutoFlashEnabled       = false
local RagdollBypassEnabled   = false
local AutoSelectBestBrainrot = false

local __AG_stealCbCache  = {}
local __AG_stealActive   = false
local __AG_MIN_HOLD_TIME = 1.3
local __AG_TRIGGER_DELAY = 0.05

local _ragdollCommandCache = {}
local _ragdollProfileCache = {}
local _ragdollCacheActivated, _ragdollFireActivated, _ragdollGetAdminFrames, _ragdollSelf

local AntiRagdoll = { connections = {}, running = false }

AntiRagdoll.forceBackpack = function()
	if not AntiRagdoll.running then return end
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return end
	local backpackGui = gui:FindFirstChild("BackpackGui")
	if not backpackGui then return end
	local backpack = backpackGui:FindFirstChild("Backpack")
	if not backpack then return end
	backpack.Visible = true
	if not backpack:FindFirstChild("ForceConnection") then
		local tag = Instance.new("BoolValue")
		tag.Name   = "ForceConnection"
		tag.Parent = backpack
		backpack:GetPropertyChangedSignal("Visible"):Connect(function()
			if not AntiRagdoll.running then return end
			if not backpack.Visible then backpack.Visible = true end
		end)
	end
end

AntiRagdoll.removeRagdollConstraints = function(char)
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")
			or d:IsA("NoCollisionConstraint")
			or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
			d:Destroy()
		end
	end
end

AntiRagdoll.resetCharacter = function(char)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.Anchored = false
		rootPart.Velocity  = Vector3.zero
	end
	if humanoid then
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("Motor6D") and obj.Enabled == false then
				obj.Enabled = true
			end
		end
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid.PlatformStand = false
		humanoid.Sit           = false
		if humanoid.Health > 0 then
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end

AntiRagdoll.onCharacterAdded_AR = function(char)
	char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	AntiRagdoll.connections.charDescAdded = char.DescendantAdded:Connect(function(obj)
		if not AntiRagdoll.running then return end
		if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint")
			or obj:IsA("NoCollisionConstraint")
			or (obj:IsA("Attachment") and obj.Name:find("RagdollAttachment")) then
			task.defer(function()
				if not AntiRagdoll.running then return end
				if obj.Parent then obj:Destroy() end
			end)
		end
	end)
	AntiRagdoll.connections.platformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
		if not AntiRagdoll.running then return end
		if humanoid.PlatformStand then
			task.defer(function()
				if not AntiRagdoll.running then return end
				AntiRagdoll.resetCharacter(char)
				AntiRagdoll.removeRagdollConstraints(char)
			end)
		end
	end)
	AntiRagdoll.removeRagdollConstraints(char)
	AntiRagdoll.resetCharacter(char)
end

AntiRagdoll.enable = function()
	if AntiRagdoll.running then return end
	AntiRagdoll.running = true
	AntiRagdoll.connections.heartbeat = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum  = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not (hum and root) then return end
		local s = hum:GetState()
		local ragdolled = (s == Enum.HumanoidStateType.Physics
			or s == Enum.HumanoidStateType.Ragdoll
			or s == Enum.HumanoidStateType.FallingDown)
		local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
		if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
			ragdolled = true
		end
		if ragdolled then
			pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
			AntiRagdoll.removeRagdollConstraints(char)
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("Motor6D") and obj.Enabled == false then
					obj.Enabled = true
				end
			end
			if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
			workspace.CurrentCamera.CameraSubject = hum
			root.Anchored = false
			root.Velocity  = Vector3.zero
		end
	end)
	AntiRagdoll.connections.charAdded = LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(1)
		AntiRagdoll.forceBackpack()
		AntiRagdoll.onCharacterAdded_AR(char)
	end)
	if LocalPlayer.Character then AntiRagdoll.onCharacterAdded_AR(LocalPlayer.Character) end
	task.spawn(function()
		while AntiRagdoll.running do
			task.wait(0.5)
			AntiRagdoll.forceBackpack()
		end
	end)
end

AntiRagdoll.disable = function()
	AntiRagdoll.running = false
	for _, conn in pairs(AntiRagdoll.connections) do
		if conn then pcall(function() conn:Disconnect() end) end
	end
	AntiRagdoll.connections = {}
	pcall(function()
		local char = LocalPlayer.Character
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     true)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		end
	end)
end

local function drawClickDot(x, y)
	if not Drawing then return end
	local dot = Drawing.new("Circle")
	dot.Radius   = 5
	dot.Position = Vector2.new(x, y)
	dot.Color    = Color3.fromRGB(255, 80, 80)
	dot.Filled   = true
	dot.Visible  = true
	dot.Transparency = 0.6
	task.delay(0.25, function() dot:Remove() end)
end

local function getPlotOwnerPlayer()
	local sel = _G._FH_SelectedBrainrot
	if not sel or not sel.plotName then return nil end
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return nil end
	local plot = plotsFolder:FindFirstChild(sel.plotName)
	if not plot then return nil end
	local ownerName = nil
	local sign = plot:FindFirstChild("PlotSign", true)
	if sign then
		for _, d in ipairs(sign:GetDescendants()) do
			if d:IsA("TextLabel") and d.Text and d.Text ~= "" then
				local t = d.Text
				if not t:lower():find("empty") then
					local m = t:match("[Bb]ase [Oo]f%s+(.+)")
					if m then ownerName = m; break end
					if #t > 0 and #t < 30 then ownerName = t; break end
				end
			end
		end
	end
	if not ownerName then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and (p.Name == ownerName or p.DisplayName == ownerName) then
			return p
		end
	end
	return nil
end

local function getNearestPlayer()
	local chr = LocalPlayer and LocalPlayer.Character
	local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local nearest, nearestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local c = p.Character
			local h = c and c:FindFirstChild("HumanoidRootPart")
			if h then
				local dist = (h.Position - hrp.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearest     = p
				end
			end
		end
	end
	return nearest
end

local function blockPlayer(targetPlayer)
	if not targetPlayer then return end
	pcall(function() StarterGui:SetCore("PromptBlockPlayer", targetPlayer) end)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	local x  = math.floor(vp.X / 2) + math.random(-1, 1)
	local y  = math.floor(vp.Y / 2 + 50) + math.random(-1, 1)

	local chr     = LocalPlayer and LocalPlayer.Character
	local blockers = {}
	if chr then
		for _, t in ipairs(chr:GetChildren()) do
			if t:IsA("Tool") then
				local blocked = true
				local conn = t.Activated:Connect(function()
					if blocked then return end
				end)
				table.insert(blockers, { conn = conn, setUnblocked = function() blocked = false end })
			end
		end
	end

	task.wait(0.04 + math.random() * 0.02)
	drawClickDot(x, y)
	pcall(function() VirtualInputManager:SendMouseButtonEvent(x, y, 0, true,  game, 1) end)
	task.wait(0.008 + math.random() * 0.008)
	pcall(function() VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1) end)

	task.delay(0.05, function()
		for _, b in ipairs(blockers) do
			b.setUnblocked()
			pcall(function() b.conn:Disconnect() end)
		end
	end)
end

local function getBlockDelay()
	local ping = 0
	pcall(function() ping = LocalPlayer:GetNetworkPing() or 0 end)
	return math.clamp(0.09 + ping, 0.09, 0.35)
end

local function triggerAutoBlock()
	if not AutoBlockEnabled then return end
	task.spawn(function()
		task.wait(getBlockDelay())
		local target = getPlotOwnerPlayer() or getNearestPlayer()
		if target then
			pcall(blockPlayer, target)
		end
	end)
end

local function triggerTimedBlock(dist, speed)
	if not AutoBlockEnabled then return end
	local ping = 0
	pcall(function() ping = LocalPlayer:GetNetworkPing() or 0 end)
	local travelTime = dist / math.max(speed, 1)
	local preDelay   = math.max(0, travelTime - ping * 1.5)
	task.delay(preDelay, function()
		if not AutoBlockEnabled then return end
		local target = getPlotOwnerPlayer() or getNearestPlayer()
		if target then pcall(blockPlayer, target) end
	end)
end

local function __AG_buildStealCallbacks(prompt)
	if __AG_stealCbCache[prompt] then return __AG_stealCbCache[prompt] end
	if not getconnections then return nil end
	local data = { hold = {}, trigger = {} }
	local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
	if ok1 and type(conns1) == "table" then
		for _, c in ipairs(conns1) do
			if type(c.Function) == "function" then table.insert(data.hold, c.Function) end
		end
	end
	local ok2, conns2 = pcall(getconnections, prompt.Triggered)
	if ok2 and type(conns2) == "table" then
		for _, c in ipairs(conns2) do
			if type(c.Function) == "function" then table.insert(data.trigger, c.Function) end
		end
	end
	if #data.hold == 0 and #data.trigger == 0 then return nil end
	__AG_stealCbCache[prompt] = data
	return data
end

local function __AG_startStealHold(prompt)
	if not prompt or not prompt.Parent then return nil end
	local cb = __AG_buildStealCallbacks(prompt)
	if not cb then return nil end
	__AG_stealActive = true
	for _, fn in ipairs(cb.hold) do task.spawn(fn) end
	return {
		cb             = cb,
		ragdollFireTime = tick(),
		holdBeganAt    = tick(),
		holdDone       = false,
	}
end

local function __AG_doHoldAndWait(ctx)
	if ctx.holdDone then return end
	for _, fn in ipairs(ctx.cb.hold) do task.spawn(fn) end
	ctx.holdBeganAt = tick()
	task.wait(__AG_MIN_HOLD_TIME)
	ctx.holdDone = true
end

local function __AG_finishStealHold(ctx)
	if not ctx then return false end
	if not ctx.holdBeganAt then __AG_doHoldAndWait(ctx) end
	local held = tick() - (ctx.holdBeganAt or tick())
	if held < __AG_MIN_HOLD_TIME then task.wait(__AG_MIN_HOLD_TIME - held) end
	task.wait(__AG_TRIGGER_DELAY)
	for _, fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
	__AG_stealActive = false
	return true
end

local function __AG_findTargetPrompt()
	local sel = _G._FH_SelectedBrainrot
	if not sel or not sel.plotName or not sel.slot then return nil end
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return nil end
	local plot = plotsFolder:FindFirstChild(sel.plotName)
	if not plot then return nil end
	local podiums = plot:FindFirstChild("AnimalPodiums")
	if not podiums then return nil end
	local podium = podiums:FindFirstChild(tostring(sel.slot))
	if not podium then return nil end
	local base   = podium:FindFirstChild("Base")
	local spawn_ = base  and base:FindFirstChild("Spawn")
	local pa     = spawn_ and spawn_:FindFirstChild("PromptAttachment")
	local prompt = pa    and pa:FindFirstChildWhichIsA("ProximityPrompt")
	if prompt then
		prompt.RequiresLineOfSight   = false
		prompt.MaxActivationDistance = math.huge
	end
	return prompt
end

_ragdollCacheActivated = function(guiObject)
	local cached = {}
	local ok, conns = pcall(getconnections, guiObject.Activated)
	if ok and type(conns) == "table" then
		for _, conn in ipairs(conns) do
			if type(conn.Function) == "function" then
				table.insert(cached, conn.Function)
			end
		end
	end
	return cached
end

_ragdollFireActivated = function(cached)
	for _, fn in ipairs(cached) do task.spawn(fn) end
end

_ragdollGetAdminFrames = function()
	local ap = LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
	if not ap then return nil, nil end
	local panel = ap:FindFirstChild("AdminPanel")
	if not panel then return nil, nil end
	local content  = panel:FindFirstChild("Content")
	local profiles = panel:FindFirstChild("Profiles")
	if not content or not profiles then return nil, nil end
	return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
end

_ragdollSelf = function()
	local commandFrame, profileFrame = _ragdollGetAdminFrames()
	if not commandFrame or not profileFrame then return end
	local pName = LocalPlayer.Name
	local profileBtn = profileFrame:FindFirstChild(pName)
	local ragdollBtn = commandFrame:FindFirstChild("ragdoll")
	if not profileBtn or not ragdollBtn then return end
	if not _ragdollProfileCache[pName] then
		_ragdollProfileCache[pName] = _ragdollCacheActivated(profileBtn)
	end
	if not _ragdollCommandCache["ragdoll"] then
		_ragdollCommandCache["ragdoll"] = _ragdollCacheActivated(ragdollBtn)
	end
	_ragdollFireActivated(_ragdollCommandCache["ragdoll"])
	task.wait()
	_ragdollFireActivated(_ragdollProfileCache[pName])
end

local ShowToggleNotification
do
	local _activeNotifs = {}
	local NOTIF_W, NOTIF_H, NOTIF_GAP, NOTIF_PAD_X, NOTIF_PAD_Y, NOTIF_DUR = 200, 44, 6, 14, 14, 2
	local T_White = Color3.fromRGB(245, 245, 245)
	local T_Border = Color3.fromRGB(45, 45, 45)

	local function _shadowTargetY(slotIdx)
		return -(NOTIF_PAD_Y + NOTIF_H + 4 + slotIdx * (NOTIF_H + NOTIF_GAP))
	end
	local function _repoAll(tweenInfo)
		for i, e in ipairs(_activeNotifs) do
			TweenService:Create(e.shadow, tweenInfo, {
				Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(i - 1))
			}):Play()
		end
	end

	local function Corner(p, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r or 8)
		c.Parent = p
		return c
	end
	local function NStroke(p, col, th)
		local s = Instance.new("UIStroke")
		s.Color           = col or T_Border
		s.Thickness       = th or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = p
		return s
	end
	local function NLabel(p, txt, sz, col, font)
		local l = Instance.new("TextLabel")
		l.Text              = txt or ""
		l.TextSize          = sz or 13
		l.TextColor3        = col or T_White
		l.Font              = font or Enum.Font.GothamMedium
		l.BackgroundTransparency = 1
		l.TextXAlignment    = Enum.TextXAlignment.Left
		l.Parent            = p
		return l
	end

	ShowToggleNotification = function(toggleName, enabled)
		local guiParent = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("RaqFlashBlock")
		if not guiParent then return end

		local statusTxt = enabled and "Enabled" or "Disabled"
		local statusCol = enabled and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 100, 100)
		local IN_INFO   = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local OUT_INFO  = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		local BAR_INFO  = TweenInfo.new(NOTIF_DUR, Enum.EasingStyle.Linear)
		local FADE_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
		local REPO_INFO = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		local shadow = Instance.new("Frame")
		shadow.Name                   = "ToastShadow"
		shadow.Size                   = UDim2.new(0, NOTIF_W + 8, 0, NOTIF_H + 8)
		shadow.Position               = UDim2.new(0, -(NOTIF_W + 32), 1, _shadowTargetY(0))
		shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
		shadow.BackgroundTransparency = 0.12
		shadow.BorderSizePixel        = 0
		shadow.ZIndex                 = 99
		shadow.Parent                 = guiParent
		Corner(shadow, 12)

		local toast = Instance.new("Frame")
		toast.Name                   = "ToastNotif"
		toast.Size                   = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
		toast.Position               = UDim2.new(0, 4, 0, 4)
		toast.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
		toast.BackgroundTransparency = 1
		toast.BorderSizePixel        = 0
		toast.ZIndex                 = 100
		toast.Parent                 = shadow
		Corner(toast, 10)
		local _stroke = NStroke(toast, Color3.fromRGB(55, 55, 55), 1); _stroke.Transparency = 1

		local pill = Instance.new("Frame")
		pill.Size             = UDim2.new(0, 3, 0, NOTIF_H - 16)
		pill.Position         = UDim2.new(0, 9, 0.5, -(NOTIF_H - 16) / 2)
		pill.BackgroundColor3 = T_White
		pill.BorderSizePixel  = 0
		pill.ZIndex           = 101
		pill.Parent           = toast
		Corner(pill, 2)

		local nameLabel = NLabel(toast, toggleName, 11, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
		nameLabel.Size = UDim2.new(1, -24, 0, 15); nameLabel.Position = UDim2.new(0, 19, 0, 7)
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd; nameLabel.TextTransparency = 1; nameLabel.ZIndex = 101

		local statusLabel = NLabel(toast, statusTxt, 10, statusCol, Enum.Font.Gotham)
		statusLabel.Size = UDim2.new(1, -24, 0, 11); statusLabel.Position = UDim2.new(0, 19, 0, 23)
		statusLabel.TextTransparency = 1; statusLabel.ZIndex = 101

		local barTrack = Instance.new("Frame")
		barTrack.Size = UDim2.new(1, 0, 0, 2); barTrack.Position = UDim2.new(0, 0, 1, -2)
		barTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35); barTrack.BorderSizePixel = 0
		barTrack.ZIndex = 101; barTrack.Parent = toast

		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.new(1, 0, 1, 0); barFill.BackgroundColor3 = T_White
		barFill.BorderSizePixel = 0; barFill.ZIndex = 102; barFill.Parent = barTrack

		local entry = { shadow = shadow }
		table.insert(_activeNotifs, 1, entry)
		_repoAll(REPO_INFO)
		TweenService:Create(shadow, IN_INFO, {Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(0))}):Play()
		TweenService:Create(toast,       IN_INFO, {BackgroundTransparency = 0}):Play()
		TweenService:Create(_stroke,     IN_INFO, {Transparency = 0.3}):Play()
		TweenService:Create(nameLabel,   IN_INFO, {TextTransparency = 0}):Play()
		TweenService:Create(statusLabel, IN_INFO, {TextTransparency = 0}):Play()
		task.delay(0.1, function() TweenService:Create(barFill, BAR_INFO, {Size = UDim2.new(0, 0, 1, 0)}):Play() end)
		task.delay(NOTIF_DUR + 0.15, function()
			for i, e in ipairs(_activeNotifs) do if e == entry then table.remove(_activeNotifs, i); break end end
			_repoAll(REPO_INFO)
			local exitY = shadow.Position.Y.Offset
			TweenService:Create(shadow, OUT_INFO, {Position = UDim2.new(0, -(NOTIF_W + 32), 1, exitY)}):Play()
			TweenService:Create(toast,       FADE_INFO, {BackgroundTransparency = 1}):Play()
			TweenService:Create(nameLabel,   FADE_INFO, {TextTransparency = 1}):Play()
			local tw = TweenService:Create(statusLabel, FADE_INFO, {TextTransparency = 1})
			tw:Play()
			tw.Completed:Connect(function() shadow:Destroy() end)
		end)
	end
end

local function doReset()
	local Net = ReplicatedStorage:WaitForChild("Packages", 2) and ReplicatedStorage.Packages:WaitForChild("Net", 2)
	if not Net then
		local char = LocalPlayer and LocalPlayer.Character
		local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.Health = 0 end
		return
	end

	local remote = nil
	local childs = Net:GetChildren()
	for i = 1, #childs - 1 do
		if childs[i] and childs[i + 1] and string.find(childs[i].Name, "Tools/Cooldown") then
			remote = childs[i + 1]
			break
		end
	end
	if not remote then
		local char = LocalPlayer and LocalPlayer.Character
		local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.Health = 0 end
		return
	end

	local savedTools = {}
	local char = LocalPlayer.Character
	local bp   = LocalPlayer:FindFirstChild("Backpack")

	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then pcall(function() hum:UnequipTools() end) end
		for _, t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") then
				table.insert(savedTools, t)
				t.Parent = nil
			end
		end
	end
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then
				table.insert(savedTools, t)
				t.Parent = nil
			end
		end
	end

	LocalPlayer.Character = nil
	local sending = true
	local loopConnection
	local fire = remote.FireServer
	local _respawnThrottle = 0

	loopConnection = RunService.Heartbeat:Connect(function(dt)
		if not sending then
			if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
			return
		end
		_respawnThrottle = _respawnThrottle + dt
		if _respawnThrottle >= 0.1 then
			_respawnThrottle = 0
			pcall(fire, remote, "f888ee6e-c86d-46e1-93d7-0639d6635d42", LocalPlayer, "balloon")
		end
		if sending and LocalPlayer.Character then LocalPlayer.Character = nil end
	end)

	local conn
	conn = LocalPlayer.CharacterAdded:Connect(function()
		sending = false
		if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
		if conn then conn:Disconnect() end
		task.spawn(function()
			local newBp = LocalPlayer:WaitForChild("Backpack", 3)
			if newBp then
				for _, t in ipairs(savedTools) do
					if t then t.Parent = newBp end
				end
			end
			savedTools = {}
		end)
	end)

	task.delay(4, function()
		sending = false
		if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
		local curBp = LocalPlayer:FindFirstChild("Backpack")
		if curBp and #savedTools > 0 then
			for _, t in ipairs(savedTools) do
				if t then t.Parent = curBp end
			end
			savedTools = {}
		end
	end)
end

_G._FH_DoSelectedReset = doReset

local function doFlash()
	local lp  = LocalPlayer
	local chr = lp and lp.Character
	local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local PODIUM_CFRAMES = {
		[1] = {
			[1] = {
				hrp = CFrame.new(Vector3.new(-347.6983, -7.5033, -4.5494)),
				cam = CFrame.new(-357.0927, 0.0048, -0.272)
					* CFrame.Angles(-0.954463, -0.903625, -0.837019),
			},
			[2] = { hrp = CFrame.new(0,0,0), cam = nil },
			[3] = { hrp = CFrame.new(0,0,0), cam = nil },
			[4] = { hrp = CFrame.new(0,0,0), cam = nil },
			[5] = { hrp = CFrame.new(0,0,0), cam = nil },
		},
		[2] = {
			[1] = { hrp = CFrame.new(Vector3.new(-349.9259, -7.3841, -1.578)), cam = CFrame.new(-361.8253, 1.3324, 5.126) * CFrame.Angles(-0.824269, -0.878251, -0.693896) },
			[2] = { hrp = CFrame.new(Vector3.new(-348.4448, -7.1043, 3.3442)), cam = CFrame.new(-358.5857, -0.0841, 9.5148) * CFrame.Angles(-0.732523, -0.884924, -0.608084) },
			[3] = { hrp = CFrame.new(-346.1821, -7.2885, -1.609) * CFrame.Angles(0, -1.247212, 0), cam = CFrame.new(-360.1625, 0.6353, 3.1776) * CFrame.Angles(-0.932656, -1.049154, -0.86316) },
			[4] = { hrp = CFrame.new(-343.6695, -7.0385, 10.3377) * CFrame.Angles(0, -0.982332, 0), cam = CFrame.new(-356.477, -0.7795, 18.8846) * CFrame.Angles(-0.510736, -0.917793, -0.418726) },
			[5] = { hrp = CFrame.new(-343.7608, -7.4124, -9.7994) * CFrame.Angles(0, -1.544676, 0), cam = CFrame.new(-359.4998, -2.4726, -9.2893) * CFrame.Angles(-1.424811, -1.351549, -1.421283) },
			[6] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-325.655, -7.5033, 54.5488) * CFrame.Angles(0, -0.69115, 0), cam = CFrame.new(-338.7595, -4.0265, 70.3894) * CFrame.Angles(-0.126016, -0.687243, -0.080199) },
			[7] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-344.4383, -7.5033, 41.8672) * CFrame.Angles(0, -1.108982, 0), cam = CFrame.new(-362.8094, -4.325, 51.1551) * CFrame.Angles(-0.181885, -1.095968, -0.162135) },
			[8] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-348.5228, -7.5033, 48.1022) * CFrame.Angles(0, -0.939336, 0), cam = CFrame.new(-363.5051, -2.5713, 59.0596) * CFrame.Angles(-0.30602, -0.916511, -0.245634) },
			[9] = { hrp = CFrame.new(-339.6349, -7.5033, 60.4164) * CFrame.Angles(0, -0.405266, 0), cam = CFrame.new(-346.7646, -3.7365, 77.0351) * CFrame.Angles(-0.137335, -0.401849, -0.054002) },
			[10] = { hrp = CFrame.new(-339.4453, -7.5033, 61.9429) * CFrame.Angles(0, -0.29845, 0), cam = CFrame.new(-342.5024, -5.2211, 71.8802) * CFrame.Angles(-0.081543, -0.297517, -0.023953) },
			[11] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-331.5262, -7.5033, -47.3607) * CFrame.Angles(0, 0.003141, 0), cam = CFrame.new(-331.4885, -9.6045, -59.3396) * CFrame.Angles(2.851853, -0.097011, -3.140695) },
			[12] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-338.729, -7.5033, -43.4714) * CFrame.Angles(0, -1.420208, 0), cam = CFrame.new(-345.1804, -9.9578, -56.8524) * CFrame.Angles(2.856299, -0.433315, 3.01906) },
			[13] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-334.5183, -7.5033, -41.6819) * CFrame.Angles(0, -0.543495, 0), cam = CFrame.new(-341.912, -9.959, -53.9192) * CFrame.Angles(2.831168, -0.52207, 2.982964) },
			[14] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-319.8298, -7.5033, -45.1476) * CFrame.Angles(0, -0.323585, 0), cam = CFrame.new(-323.983, -9.9618, -57.5315) * CFrame.Angles(2.834406, -0.309406, 3.045298) },
			[15] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-317.917, -7.5033, -41.9999) * CFrame.Angles(0, -0.565487, 0), cam = CFrame.new(-325.8, -9.9581, -54.4216) * CFrame.Angles(2.835549, -0.544183, 2.979445) },
			[16] = { hrp = CFrame.new(-338.285, -7.5033, 57.204) * CFrame.Angles(0, -0.207346, 0), cam = CFrame.new(-340.4345, -9.5916, 67.4219) * CFrame.Angles(0.335111, -0.196113, 0.067755) },
			[17] = { hrp = CFrame.new(-337.9285, -7.5033, 55.1757) * CFrame.Angles(0, -0.430398, 0), cam = CFrame.new(-341.7441, -8.9535, 63.4867) * CFrame.Angles(0.337895, -0.408747, 0.138758) },
			[18] = { hrp = CFrame.new(-332.1088, -7.5033, 53.1675) * CFrame.Angles(0, -0.49323, 0), cam = CFrame.new(-336.3932, -9.2396, 61.1377) * CFrame.Angles(0.382481, -0.462609, 0.177644) },
			[19] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-328.579, -3.1209, -35.0857) * CFrame.Angles(0, 0.021988, 0), cam = CFrame.new(-328.5137, -10.011, -45.4753) * CFrame.Angles(2.387391, -0.004579, 3.137291) },
			[20] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-321.5783, -7.5033, -33.5778) * CFrame.Angles(0, 0.006284, 0), cam = CFrame.new(-321.5535, -10.0218, -37.5259) * CFrame.Angles(2.387391, -0.004579, 3.137291) },
			[21] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-314.088, -7.5033, -32.1806) * CFrame.Angles(0, -0.006282, 0), cam = CFrame.new(-314.1147, -10.0174, -36.4214) * CFrame.Angles(2.387391, -0.004579, 3.137291) },
			[22] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-306.8919, -7.5033, -33.9124) * CFrame.Angles(0, -0.006284, 0), cam = CFrame.new(-306.923, -10.008, -38.86) * CFrame.Angles(2.4648, -0.004898, 3.137657) },
			[23] = { hrpWalk = CFrame.new(-351.5396, -7.5033, -41.797), hrp = CFrame.new(-300.2759, -7.5033, -32.7047) * CFrame.Angles(0, -0.031416, 0), cam = CFrame.new(-300.4669, -10.016, -37.044) * CFrame.Angles(2.399014, -0.032413, 3.111857) },
			[24] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-330.0484, -7.5033, 48.183) * CFrame.Angles(0, -0.006377, 0), cam = CFrame.new(-330.1124, -10.0063, 53.2779) * CFrame.Angles(0.662308, -0.00991, 0.007727) },
			[25] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-325.4576, -7.5033, 46.8182) * CFrame.Angles(0, -0.125663, 0), cam = CFrame.new(-326.0541, -10.0104, 51.5397) * CFrame.Angles(0.700033, -0.09632, 0.080833) },
			[26] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-324.6721, -7.5033, 47.2033) * CFrame.Angles(0, -0.40212, 0), cam = CFrame.new(-326.6859, -10.0057, 51.9385) * CFrame.Angles(0.698024, -0.314979, 0.254268) },
			[27] = { hrpWalk = CFrame.new(-348.2407, -7.5033, 74.3719), hrp = CFrame.new(-320.4196, -7.5033, 44.1) * CFrame.Angles(0, -0.571769, 0), cam = CFrame.new(-322.9213, -10.0122, 49.5157) * CFrame.Angles(0.876985, -0.422603, 0.397417) },
		},
	}

	local myBase = nil
	local plotsFolder = workspace:FindFirstChild("Plots")
	if plotsFolder then
		for _, plot in ipairs(plotsFolder:GetChildren()) do
			if plot:IsA("Model") then
				local sign = plot:FindFirstChild("PlotSign")
				if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then
					local ok, order = pcall(function() return plot:GetAttribute("Order") end)
					if ok and order then myBase = tonumber(order) end
					break
				end
			end
		end
	end

	if not myBase then
		pcall(ShowToggleNotification, "Flash: base not detected", false)
		return
	end

	local targetBase = (myBase == 1) and 2 or 1
	local podiumCFs = PODIUM_CFRAMES[targetBase]
	if not podiumCFs then return end

	local selected = _G._FH_SelectedBrainrot
	if not selected then
		pcall(ShowToggleNotification, "Flash: select an animal first", false)
		return
	end

	local slot = tonumber(selected.slot)
	if not slot then
		pcall(ShowToggleNotification, "Flash: selected animal has no slot", false)
		return
	end

	local entry = podiumCFs[slot]
	if not entry or not entry.cam then
		pcall(ShowToggleNotification, "Flash: podium " .. tostring(slot) .. " not configured yet", false)
		return
	end

	task.spawn(function()
		local currentSpeed = entry.hrpFloat and 800 or 210
		local ARRIVE_DIST  = 4
		local TIMEOUT      = 8

		local player    = LocalPlayer
		local targetPos = (entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position

		local function findTool(kw)
			local c = player.Character
			local b = player:FindFirstChild("Backpack")
			if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
			if b then for _, t in ipairs(b:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find(kw) then return t end end end
		end

		local function doEquip(tool, timeout)
			local c = player.Character
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if not (c and h) then return end
			if tool.Parent == c then return end
			local done = false
			local cn
			cn = tool.Equipped:Connect(function() done = true; cn:Disconnect() end)
			pcall(function() h:EquipTool(tool) end)
			local dl = tick() + (timeout or 1)
			while not done and tick() < dl do task.wait() end
			if cn then pcall(function() cn:Disconnect() end) end
		end

		local carpet = findTool("carpet")
		if carpet then doEquip(carpet, 1) end

		local stealCtx     = nil
		local _lateGrabSlots = {[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,
								 [19]=true,[20]=true,[21]=true,[22]=true,[23]=true}
		if not _lateGrabSlots[slot] then
			task.spawn(function()
				local chr3 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local dest = (entry.hrpWalk and entry.hrpWalk.Position) or entry.hrp.Position
				local dist = chr3 and (chr3.Position - dest).Magnitude or 0
				local POST_ARRIVAL = 0.10 + 0.15 + 0.07 + 0.30 + 0.12
				local travelTime   = dist / math.max(currentSpeed, 1)
				local timeUntilFire = travelTime + POST_ARRIVAL
				local preDelay     = math.max(0, timeUntilFire - __AG_MIN_HOLD_TIME)
				if preDelay > 0 then task.wait(preDelay) end
				local targetPrompt = __AG_findTargetPrompt()
				if targetPrompt then stealCtx = __AG_startStealHold(targetPrompt) end
			end)
		end

		local boostConn
		boostConn = RunService.Heartbeat:Connect(function()
			if not player.Character then return end
			local hrpB = player.Character:FindFirstChild("HumanoidRootPart")
			local humB = player.Character:FindFirstChildOfClass("Humanoid")
			if not hrpB or not humB then return end
			local diff = targetPos - hrpB.Position
			local flat = Vector3.new(diff.X, 0, diff.Z)
			if flat.Magnitude > ARRIVE_DIST then
				local flatDir = flat.Unit
				hrpB.Velocity = Vector3.new(flatDir.X * currentSpeed, hrpB.Velocity.Y, flatDir.Z * currentSpeed)
			else
				hrpB.Velocity = Vector3.new(0, hrpB.Velocity.Y, 0)
			end
		end)

		local chr2 = player.Character
		local hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
		if hum2 then hum2:MoveTo(targetPos) end

		local deadline = tick() + TIMEOUT
		local _lastMoveTo = 0
		repeat
			task.wait()
			chr2 = player.Character
			local hrp2 = chr2 and chr2:FindFirstChild("HumanoidRootPart")
			hum2       = chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if not (hrp2 and hum2) then break end
			local _now = tick()
			if _now - _lastMoveTo >= 0.1 then hum2:MoveTo(targetPos); _lastMoveTo = _now end
			if (hrp2.Position - targetPos).Magnitude < ARRIVE_DIST then break end
		until tick() > deadline

		if boostConn then boostConn:Disconnect(); boostConn = nil end

		local function snapAndRelease(cf)
			local _chr = player.Character
			local _hrp = _chr and _chr:FindFirstChild("HumanoidRootPart")
			local _hum = _chr and _chr:FindFirstChildOfClass("Humanoid")
			if _hrp and _hum then
				_hum:MoveTo(_hrp.Position)
				_hrp.Velocity = Vector3.zero
				_hrp.Anchored = true
				task.defer(function() task.defer(function()
					local c = player.Character
					local h = c and c:FindFirstChild("HumanoidRootPart")
					if h then h.Velocity = Vector3.zero; h.Anchored = false end
				end) end)
			end
		end

		if _lateGrabSlots[slot] then
			task.spawn(function()
				local _chr3 = player.Character
				local _hrp3 = _chr3 and _chr3:FindFirstChild("HumanoidRootPart")
				local _finalP = entry.hrp.Position
				local _d2 = _hrp3 and (_hrp3.Position - _finalP).Magnitude or 0
				local _POST2 = 0.10 + 0.15 + 0.07 + 0.30 + 0.12
				local _pre2 = math.max(0, (_d2 / math.max(currentSpeed, 1)) + _POST2 - __AG_MIN_HOLD_TIME)
				if _pre2 > 0 then task.wait(_pre2) end
				local _tp = __AG_findTargetPrompt()
				if _tp then stealCtx = __AG_startStealHold(_tp) end
			end)
		end

		if entry.hrpWalk then
			local finalPos = entry.hrp.Position
			local boostConn2
			boostConn2 = RunService.Heartbeat:Connect(function()
				if not player.Character then return end
				local hrp3 = player.Character:FindFirstChild("HumanoidRootPart")
				if not hrp3 then return end
				local diff3 = finalPos - hrp3.Position
				local flat3 = Vector3.new(diff3.X, 0, diff3.Z)
				if flat3.Magnitude > ARRIVE_DIST then
					local fd = flat3.Unit
					hrp3.Velocity = Vector3.new(fd.X * currentSpeed, hrp3.Velocity.Y, fd.Z * currentSpeed)
				else
					hrp3.Velocity = Vector3.new(0, hrp3.Velocity.Y, 0)
				end
			end)
			chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
			if hum2 then hum2:MoveTo(finalPos) end
			local deadline2 = tick() + TIMEOUT
			local _lastMoveTo2 = 0
			repeat
				task.wait()
				chr2 = player.Character
				local hrp2b = chr2 and chr2:FindFirstChild("HumanoidRootPart")
				hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
				if not (hrp2b and hum2) then break end
				local _now2 = tick()
				if _now2 - _lastMoveTo2 >= 0.1 then hum2:MoveTo(finalPos); _lastMoveTo2 = _now2 end
				if (hrp2b.Position - finalPos).Magnitude < ARRIVE_DIST then break end
			until tick() > deadline2
			boostConn2:Disconnect()
			chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
			local hrpStop = chr2 and chr2:FindFirstChild("HumanoidRootPart")
			if hrpStop and hum2 then
				hrpStop.CFrame = entry.hrp; hrpStop.Velocity = Vector3.zero; hrpStop.Anchored = true
				task.defer(function() task.defer(function()
					local _c = player.Character; local _h = _c and _c:FindFirstChild("HumanoidRootPart")
					if _h then _h.Velocity = Vector3.zero; _h.Anchored = false end
				end) end)
			end
		else
			chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
			local hrpStop = chr2 and chr2:FindFirstChild("HumanoidRootPart")
			if hrpStop and hum2 then
				hrpStop.CFrame = entry.hrp; hrpStop.Velocity = Vector3.zero; hrpStop.Anchored = true
				task.defer(function() task.defer(function()
					local _c = player.Character; local _h = _c and _c:FindFirstChild("HumanoidRootPart")
					if _h then _h.Velocity = Vector3.zero; _h.Anchored = false end
				end) end)
			end
		end

		local cam = workspace.CurrentCamera
		if cam and entry.cam then
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = entry.cam
			task.defer(function()
				cam.CFrame = entry.cam
				task.defer(function()
					cam.CFrame = entry.cam
					cam.CameraType = Enum.CameraType.Custom
				end)
			end)
		end

		local carpetMid = findTool("carpet")
		if carpetMid then doEquip(carpetMid, 1.5) end
		task.wait(0.35)

		if (slot >= 19 and slot <= 27) and hum2 then
			hum2:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
		if not (chr2 and hum2) then return end

		local flashTool = nil
		local bp = player:FindFirstChild("Backpack")
		if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool = t; break end end end
		if not flashTool then for _, t in ipairs(chr2:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("flash") then flashTool = t; break end end end

		if not flashTool then
			pcall(ShowToggleNotification, "Flash: tool not found in inventory", false)
			return
		end

		pcall(function() hum2:UnequipTools() end)
		task.wait(0.07)

		local _flashEquipped = false
		local _flashEquipConn
		_flashEquipConn = flashTool.Equipped:Connect(function()
			_flashEquipped = true; _flashEquipConn:Disconnect(); _flashEquipConn = nil
		end)
		flashTool.Parent = chr2
		pcall(function() hum2:EquipTool(flashTool) end)
		local _eqDeadline = tick() + 1
		while not _flashEquipped and tick() < _eqDeadline do task.wait() end
		if _flashEquipConn then pcall(function() _flashEquipConn:Disconnect() end) end

		pcall(function() flashTool:Activate() end)

		task.spawn(function()
			task.wait(0.08)
			if not RagdollBypassEnabled then
				if stealCtx then
					triggerAutoBlock()
					__AG_finishStealHold(stealCtx)
				elseif type(_G._sv2DoSteal) == "function" then
					triggerAutoBlock()
					pcall(_G._sv2DoSteal)
				end
			end
		end)

		task.wait(0.02)
		pcall(function() flashTool:Activate() end)
		task.wait(0.08)

		if hum2 then pcall(function() hum2:UnequipTools() end) end
		task.wait(0.05)
		local bp2 = player:FindFirstChild("Backpack")
		if bp2 and flashTool and flashTool.Parent ~= bp2 then flashTool.Parent = bp2 end

		local char3 = player.Character
		local bp3   = player:FindFirstChild("Backpack")
		if char3 and bp3 then
			local potion = bp3:FindFirstChild("Body Swap Potion")
			if potion then
				pcall(function() potion.Parent = char3; potion:Activate(); potion.Parent = bp3 end)
			end
		end

		if RagdollBypassEnabled then
			task.spawn(function()
				task.wait(0.10)
				pcall(_ragdollSelf)
				triggerAutoBlock()

				local _kicked     = false
				local _kickConn1, _kickConn2
				local _tgtPlayer  = getPlotOwnerPlayer()
				local _tgtChar    = _tgtPlayer and _tgtPlayer.Character
				local _tgtHum     = _tgtChar and _tgtChar:FindFirstChildOfClass("Humanoid")
				local function _onKicked()
					if _kicked then return end
					_kicked = true
					if _kickConn1 then pcall(function() _kickConn1:Disconnect() end); _kickConn1 = nil end
					if _kickConn2 then pcall(function() _kickConn2:Disconnect() end); _kickConn2 = nil end
					local _wf = 0
					while not stealCtx and _wf < 3 do task.wait(); _wf = _wf + 1 end
					if not stealCtx then
						local _fp = __AG_findTargetPrompt()
						if _fp then stealCtx = __AG_startStealHold(_fp) end
					end
					if stealCtx then
						__AG_finishStealHold(stealCtx)
					elseif type(_G._sv2DoSteal) == "function" then
						pcall(_G._sv2DoSteal)
					end
				end
				if _tgtHum then
					_kickConn1 = _tgtHum.StateChanged:Connect(function(_, new)
						if new == Enum.HumanoidStateType.Physics
							or new == Enum.HumanoidStateType.Ragdoll
							or new == Enum.HumanoidStateType.FallingDown then
							_onKicked()
						end
					end)
					_kickConn2 = _tgtHum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
						if _tgtHum.PlatformStand then _onKicked() end
					end)
				end
				task.delay(0.35, _onKicked)

				task.wait(0.15)
				chr2 = player.Character; hum2 = chr2 and chr2:FindFirstChildOfClass("Humanoid")
				local potionTool = player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Body Swap Potion")
				if potionTool and RagdollBypassEnabled then
					pcall(function() hum2:UnequipTools() end)
					task.wait(0.05)
					potionTool.Parent = chr2
					pcall(function() hum2:EquipTool(potionTool) end)
					task.wait(0.12)
					pcall(function() potionTool:Activate() end)
					task.wait(0.05)
					pcall(function() potionTool:Activate() end)
					task.wait(0.1)
					if hum2 then pcall(function() hum2:UnequipTools() end) end
					task.wait(0.05)
					local bp4 = player:FindFirstChild("Backpack")
					if bp4 and potionTool and potionTool.Parent ~= bp4 then potionTool.Parent = bp4 end
				end

				local carpetFinal = findTool("carpet")
				if carpetFinal then doEquip(carpetFinal, 1) end
			end)
		end

		pcall(ShowToggleNotification, "Flash â†’ Base " .. targetBase .. " Podium " .. slot, true)
	end)
end

local function doBlock()
	local target = getNearestPlayer()
	if target then
		pcall(blockPlayer, target)
		pcall(ShowToggleNotification, "Blocked: " .. target.Name, true)
	else
		pcall(ShowToggleNotification, "Block: no players nearby", false)
	end
end

_G._FH_ResetBtnEntry = { fire = doReset }
_G._FH_FlashBtnEntry = { fire = doFlash }
_G._FH_BlockBtnEntry = { fire = doBlock }

do
	local _afPending = false

	local function tryAutoFlash()
		if not AutoFlashEnabled then return end
		if not _G._FH_SelectedBrainrot then
			pcall(ShowToggleNotification, "Auto Flash: no animal selected", false)
			return
		end
		if _afPending then return end
		_afPending = true

		task.spawn(function()
			pcall(ShowToggleNotification, "Auto Flash: resetting...", true)
			if _G._FH_DoSelectedReset then pcall(_G._FH_DoSelectedReset) end

			local deadline = tick() + 8
			while (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and tick() < deadline do
				task.wait(0.1)
			end
			if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				_afPending = false; return
			end

			task.wait(0.15)
			if not AutoFlashEnabled then _afPending = false; return end
			if not _G._FH_SelectedBrainrot then _afPending = false; return end

			pcall(ShowToggleNotification, "Auto Flash: flashing!", true)
			if _G._FH_FlashBtnEntry then pcall(_G._FH_FlashBtnEntry.fire) end

			task.wait(3)
			_afPending = false
		end)
	end

	local _afBoundRemotes = {}
	local _afLastBalloon  = 0
	local function _afBindRemote(obj)
		if not obj:IsA("RemoteEvent") then return end
		if _afBoundRemotes[obj] then return end
		local ok, conn = pcall(function()
			return obj.OnClientEvent:Connect(function(...)
				if not AutoFlashEnabled then return end
				for i = 1, select("#", ...) do
					local arg = select(i, ...)
					if type(arg) == "string" and arg:lower():find("jump higher", 1, true) then
						local now = tick()
						if now - _afLastBalloon < 3 then return end
						_afLastBalloon = now
						tryAutoFlash()
						return
					end
				end
			end)
		end)
		if ok and conn then _afBoundRemotes[obj] = conn end
	end
	for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do _afBindRemote(obj) end
	ReplicatedStorage.DescendantAdded:Connect(function(obj) _afBindRemote(obj) end)
end

local function create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props) do inst[k] = v end
	if children then for _, child in ipairs(children) do child.Parent = inst end end
	return inst
end

local function makeToggleRow(title, desc, callback)
	local row = create("Frame", {
		Name = title:gsub(" ", ""),
		Size = UDim2.new(1, -16, 0, 38),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = row
	create("UIStroke", { Color = Color3.fromRGB(55, 55, 55), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }).Parent = row

	local accent = create("Frame", {
		Size = UDim2.new(0, 3, 0, 28), Position = UDim2.new(0, 0, 0, 5),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderSizePixel = 0, ZIndex = 2,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = accent
	accent.Parent = row

	create("TextLabel", {
		Size = UDim2.new(1, -80, 0, 12), Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1, ZIndex = 2, Text = title,
		TextColor3 = Color3.fromRGB(245, 245, 245), TextSize = 9,
		Font = Enum.Font.GothamMedium,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}).Parent = row

	create("TextLabel", {
		Size = UDim2.new(1, -80, 0, 10), Position = UDim2.new(0, 10, 0, 18),
		BackgroundTransparency = 1, ZIndex = 2, Text = desc,
		TextColor3 = Color3.fromRGB(110, 110, 110), TextSize = 8,
		Font = Enum.Font.Gotham,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}).Parent = row

	create("TextLabel", {
		Size = UDim2.new(0, 24, 0, 12), Position = UDim2.new(1, -64, 0.5, -6),
		BackgroundTransparency = 1, ZIndex = 3, Text = "",
		TextColor3 = Color3.fromRGB(110, 110, 110), Font = Enum.Font.GothamBold,
	}).Parent = row

	local track = create("Frame", {
		Name = "Track", Size = UDim2.new(0, 28, 0, 15), Position = UDim2.new(1, -36, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderSizePixel = 0, ZIndex = 2,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 7) }).Parent = track
	create("UIStroke", { Color = Color3.fromRGB(55, 55, 55), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }).Parent = track

	local knob = create("Frame", {
		Name = "Knob", Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 2, 0.5, -5),
		BackgroundColor3 = Color3.fromRGB(160, 160, 160), BorderSizePixel = 0, ZIndex = 3,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 5) }).Parent = knob
	knob.Parent = track
	track.Parent = row

	local hitbox = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 4, Active = true,
	})
	hitbox.Parent = row

	local toggled = false
	hitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			toggled = not toggled
			local goalPos   = toggled and UDim2.new(0, 15, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
			local goalTrack = toggled and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(45, 45, 45)
			local goalKnob  = toggled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(160, 160, 160)
			local goalAccent= toggled and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(45, 45, 45)
			local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(knob, info, { Position = goalPos, BackgroundColor3 = goalKnob }):Play()
			TweenService:Create(track, info, { BackgroundColor3 = goalTrack }):Play()
			TweenService:Create(accent, info, { BackgroundColor3 = goalAccent }):Play()
			if callback then task.spawn(function() pcall(callback, toggled) end) end
			pcall(ShowToggleNotification, title, toggled)
		end
	end)

	return row
end

local function makeSectionHeader(labelText, labelWidth, lineOffset)
	local header = create("Frame", { Size = UDim2.new(1, -16, 0, 26), BackgroundTransparency = 1 })
	create("TextLabel", {
		Size = UDim2.new(0, labelWidth, 1, 0), Position = UDim2.new(0, 4, 0, 0),
		BackgroundTransparency = 1, ZIndex = 2, Text = labelText,
		TextColor3 = Color3.fromRGB(110, 110, 110), TextSize = 9,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = header
	create("Frame", {
		Size = UDim2.new(1, -(lineOffset + 4), 0, 1),
		Position = UDim2.new(0, lineOffset, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(55, 55, 55), BorderSizePixel = 0,
	}).Parent = header
	return header
end

local function makeHeaderBtn(text, order)
	local btn = create("TextButton", {
		Name = "Hdr_" .. text, Size = UDim2.new(0, 0, 0, 12),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0, ZIndex = 8,
		LayoutOrder = order, AutomaticSize = Enum.AutomaticSize.X,
		Text = text, TextColor3 = Color3.fromRGB(245, 245, 245), TextSize = 7,
		Font = Enum.Font.GothamBold, AutoButtonColor = false,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 3) }).Parent = btn
	create("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) }).Parent = btn
	local st = create("UIStroke", { Color = Color3.fromRGB(55, 55, 55), ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	st.Parent = btn
	return btn, st
end

local RaqFlashBlock = create("ScreenGui", {
	Name = "RaqFlashBlock", ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = false,
	Parent = LocalPlayer:WaitForChild("PlayerGui"),
})

local Win = create("Frame", {
	Name = "Win", Size = UDim2.new(0, 210, 0, 270),
	Position = UDim2.new(0.5, -404, 0.5, 61), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.08,
	BorderSizePixel = 0, ZIndex = 2, Parent = RaqFlashBlock,
})
create("UICorner", { CornerRadius = UDim.new(0, 14) }).Parent = Win
local winStroke = create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
winStroke.Parent = Win
local winGradient = create("UIGradient", {
	Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) }),
	Rotation = 45,
})
winGradient.Parent = Win
local winScale = create("UIScale", {})
winScale.Parent = Win

local titleBar = create("Frame", {
	Name = "TitleBar", Size = UDim2.new(1, -12, 0, 24), Position = UDim2.new(0, 6, 0, 5),
	BackgroundColor3 = Color3.fromRGB(13, 13, 13), BorderSizePixel = 0, ZIndex = 5,
})
create("UICorner", { CornerRadius = UDim.new(0, 10) }).Parent = titleBar
create("Frame", { Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8), BackgroundColor3 = Color3.fromRGB(13, 13, 13), BorderSizePixel = 0, ZIndex = 5 }).Parent = titleBar
create("TextLabel", { Size = UDim2.new(0, 80, 0, 14), Position = UDim2.new(0, 8, 0.5, -7), BackgroundTransparency = 1, ZIndex = 6, Text = "Raq Flash Block", TextColor3 = Color3.fromRGB(245, 245, 245), TextSize = 9, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left }).Parent = titleBar
create("TextLabel", { Size = UDim2.new(0, 28, 0, 10), Position = UDim2.new(1, -36, 0.5, -5), BackgroundTransparency = 1, ZIndex = 6, Text = "v1.0", TextColor3 = Color3.fromRGB(110, 110, 110), Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Right }).Parent = titleBar

local hdrBtnContainer = create("Frame", { Size = UDim2.new(0, 0, 0, 12), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, ZIndex = 7, AutomaticSize = Enum.AutomaticSize.X })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4) }).Parent = hdrBtnContainer

local function wireHeaderBtn(text, order, action)
	local btn, st = makeHeaderBtn(text, order)
	btn.Parent = hdrBtnContainer
	local _busy = false
	btn.MouseButton1Click:Connect(function()
		if _busy then return end
		_busy = true
		btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		btn.TextColor3 = Color3.fromRGB(15, 15, 15)
		TweenService:Create(st, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Color = Color3.fromRGB(245, 245, 245) }):Play()
		task.delay(0.16, function()
			TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
			TweenService:Create(st, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Color = Color3.fromRGB(55, 55, 55) }):Play()
			btn.TextColor3 = Color3.fromRGB(245, 245, 245)
			_busy = false
		end)
		if action then task.spawn(function() pcall(action) end) end
	end)
	return btn
end

wireHeaderBtn("RESET", 1, doReset)
wireHeaderBtn("FLASH", 2, doFlash)
wireHeaderBtn("BLOCK", 3, doBlock)

hdrBtnContainer.Parent = titleBar
titleBar.Parent = Win

create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 36), BackgroundColor3 = Color3.fromRGB(55, 55, 55), BorderSizePixel = 0, ZIndex = 6 }).Parent = Win
local tabBar = create("Frame", { Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, 36), BackgroundColor3 = Color3.fromRGB(10, 10, 10), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 4 })
create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center }).Parent = tabBar

local tab1Btn = create("TextButton", { Size = UDim2.new(0, 105, 1, 0), BackgroundTransparency = 1, ZIndex = 5, Text = "" })
local tab1Label = create("TextLabel", { Size = UDim2.new(1, -2, 1, 0), Position = UDim2.new(0, 1, 0, 0), BackgroundTransparency = 1, ZIndex = 6, Text = "ALL BRAINROTS", TextColor3 = Color3.fromRGB(245, 245, 245), TextSize = 9, Font = Enum.Font.GothamBold })
tab1Label.Parent = tab1Btn
local tab1Underline = create("Frame", { Size = UDim2.new(0.8, 0, 0, 2), Position = UDim2.new(0.1, 0, 1, -2), BackgroundColor3 = Color3.fromRGB(245, 245, 245), BorderSizePixel = 0, ZIndex = 7 })
create("UICorner", { CornerRadius = UDim.new(0, 1) }).Parent = tab1Underline
tab1Underline.Parent = tab1Btn
tab1Btn.Parent = tabBar

local tab2Btn = create("TextButton", { Size = UDim2.new(0, 105, 1, 0), BackgroundTransparency = 1, ZIndex = 5, Text = "" })
local tab2Label = create("TextLabel", { Size = UDim2.new(1, -2, 1, 0), Position = UDim2.new(0, 1, 0, 0), BackgroundTransparency = 1, ZIndex = 6, Text = "UTILS", TextColor3 = Color3.fromRGB(75, 75, 75), TextSize = 9, Font = Enum.Font.GothamBold })
tab2Label.Parent = tab2Btn
local tab2Underline = create("Frame", { Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.1, 0, 1, -2), BackgroundColor3 = Color3.fromRGB(245, 245, 245), BorderSizePixel = 0, ZIndex = 7 })
create("UICorner", { CornerRadius = UDim.new(0, 1) }).Parent = tab2Underline
tab2Underline.Parent = tab2Btn
tab2Btn.Parent = tabBar
tabBar.Parent = Win

create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 58), BackgroundColor3 = Color3.fromRGB(55, 55, 55), BorderSizePixel = 0, ZIndex = 5 }).Parent = Win

local contentArea = create("Frame", { Size = UDim2.new(1, 0, 1, -59), Position = UDim2.new(0, 0, 0, 59), BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = true })
contentArea.Parent = Win

local page1 = create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = true, Visible = true })
local scroll1 = create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(75, 75, 75), ScrollingDirection = Enum.ScrollingDirection.Y, AutomaticCanvasSize = Enum.AutomaticSize.Y })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6) }).Parent = scroll1
create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }).Parent = scroll1
local s1h1 = makeSectionHeader("ANIMALS ON PLOTS", 118, 128)
s1h1.LayoutOrder = 1
s1h1.Parent = scroll1
local animalsContainer = create("Frame", { Size = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2 })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6) }).Parent = animalsContainer
animalsContainer.Parent = scroll1
scroll1.Parent = page1
page1.Parent = contentArea

do
	local RS = ReplicatedStorage
	local WS = workspace

	local AnimalsData   = _G._FH_AG_AnimalsData
	local AnimalsShared = _G._FH_AG_AnimalsShared
	local NumberUtils   = _G._FH_AG_NumberUtils
	if not AnimalsData   then pcall(function() AnimalsData   = require(RS:WaitForChild("Datas",30):WaitForChild("Animals",30)) end) end
	if not NumberUtils   then pcall(function() NumberUtils   = require(RS:WaitForChild("Utils",30):WaitForChild("NumberUtils",30)) end) end
	if not AnimalsShared then pcall(function() AnimalsShared = require(RS:WaitForChild("Shared",30):WaitForChild("Animals",30)) end) end

	local RequestData = _G._FH_AG_SyncRemotes and _G._FH_AG_SyncRemotes.requestData
	if not RequestData then
		pcall(function()
			local pkg = RS:WaitForChild("Packages",15):WaitForChild("Synchronizer",15)
			RequestData = pkg:FindFirstChild("RequestData")
		end)
	end
	local PlotSyncCaches = (_G._FH_AG_PlotSync and _G._FH_AG_PlotSync.caches) or {}

	local function fmtNum(n)
		if NumberUtils and NumberUtils.ToString then
			local ok,s = pcall(function() return NumberUtils:ToString(n) end)
			if ok and s then return s end
		end
		return tostring(n)
	end
	local function getGeneration(index, mutation, traits)
		if not (AnimalsShared and AnimalsShared.GetGeneration) then return 0 end
		local ok,v = pcall(function() return AnimalsShared:GetGeneration(index,mutation,traits,nil) end)
		if not ok or not v then ok,v = pcall(function() return AnimalsShared:GetGeneration(index,mutation,nil,nil) end) end
		if not ok or not v then ok,v = pcall(function() return AnimalsShared:GetGeneration(index) end) end
		return (ok and v) or 0
	end
	local function displayName(index)
		local info = AnimalsData and AnimalsData[index]
		return (info and info.DisplayName) or tostring(index)
	end
	local function isMyPlot(plot)
		local sign = plot:FindFirstChild("PlotSign")
		return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled or false
	end
	local function plotOwner(plot)
		local sign = plot:FindFirstChild("PlotSign",true)
		if sign then
			for _,d in ipairs(sign:GetDescendants()) do
				if d:IsA("TextLabel") and d.Text and d.Text ~= "" then
					local t = d.Text
					if t:lower():find("empty") then return "Empty" end
					local m = t:match("[Bb]ase [Oo]f%s+(.+)")
					if m then return m end
					if #t > 0 and #t < 30 then return t end
				end
			end
		end
		local s2 = plot:FindFirstChild("PlotSign")
		return (s2 and s2:FindFirstChild("YourBase") and s2.YourBase.Enabled) and "YOU" or "?"
	end
	local function getPodiumExists(plot, slot)
		local podiums = plot:FindFirstChild("AnimalPodiums")
		return podiums and podiums:FindFirstChild(tostring(slot)) ~= nil
	end
	local function getPlotOrder(plot)
		local order = pcall(function() return plot:GetAttribute("Order") end) and plot:GetAttribute("Order")
		if order then return "Base " .. tostring(order) end
		local lp = LocalPlayer
		if lp then
			local ok, v = pcall(function() return lp:GetAttribute(plot.Name .. "_Order") end)
			if ok and v then return "Base " .. tostring(v) end
			local ok2, v2 = pcall(function() return lp:GetAttribute("Order") end)
			if ok2 and v2 then return "Base " .. tostring(v2) end
		end
		return plot.Name
	end
	local function getAnimalList(plot)
		if RequestData then
			PlotSyncCaches[plot.Name] = nil
			local ok, data = pcall(function() return RequestData:InvokeServer(plot.Name) end)
			if ok and typeof(data) == "table" then
				PlotSyncCaches[plot.Name] = data
				if typeof(data.AnimalList) == "table" then return data.AnimalList end
			end
		end
		local cache = PlotSyncCaches[plot.Name]
		if cache and typeof(cache.AnimalList) == "table" then return cache.AnimalList end
		return nil
	end

	local function scanAllAnimals()
		local results = {}
		local plotsFolder = WS:FindFirstChild("Plots")
		if not plotsFolder then return results end
		for _, plot in ipairs(plotsFolder:GetChildren()) do
			if not plot:IsA("Model") then continue end
			if isMyPlot(plot) then continue end
			pcall(function()
				local animalList = getAnimalList(plot)
				if typeof(animalList) ~= "table" then return end
				local owner = plotOwner(plot)
				for slot, data in pairs(animalList) do
					pcall(function()
						if typeof(data)=="table" and data.Index then
							local podiumExists = getPodiumExists(plot, slot)
							local gen = getGeneration(data.Index, data.Mutation, data.Traits)
							table.insert(results, {
								name         = displayName(data.Index),
								animalIndex  = data.Index,
								mutation     = data.Mutation,
								traits       = data.Traits,
								genValue     = gen,
								genText      = "$"..fmtNum(gen).."/s",
								plotName     = plot.Name,
								plotOrder    = getPlotOrder(plot),
								owner        = owner,
								slot         = tostring(slot),
								podiumExists = podiumExists,
							})
						end
					end)
				end
			end)
		end
		table.sort(results, function(a,b) return (a.genValue or 0)>(b.genValue or 0) end)
		return results
	end

	local function afGetTemplate(name)
		local ok,v = pcall(function() return RS.Models.Animals[name] end)
		return ok and v or nil
	end
	local function afGetAnimFolder(name)
		local ok,v = pcall(function() return RS.Animations.Animals[name] end)
		return ok and v or nil
	end

	local _sharedAnimals = nil
	local function GetSharedAnimals()
		if not _sharedAnimals then
			local ok, result = pcall(function() return require(RS.Shared.Animals) end)
			if ok then _sharedAnimals = result end
		end
		return _sharedAnimals
	end

	local BG_COL = Color3.fromRGB(12,12,14)
	local MUT_PALETTES = {
		Gold        = {Color3.fromRGB(237,178,0),   Color3.fromRGB(237,194,86), Color3.fromRGB(215,111,1),  Color3.fromRGB(139,74,0),   Color3.fromRGB(255,164,164), Color3.fromRGB(255,244,190)},
		Diamond     = {Color3.fromRGB(37,196,254),  Color3.fromRGB(116,212,254),Color3.fromRGB(28,137,254), Color3.fromRGB(21,64,254),   Color3.fromRGB(160,162,254), Color3.fromRGB(176,255,252)},
		Bloodrot    = {Color3.fromRGB(145,0,27),    Color3.fromRGB(154,94,100), Color3.fromRGB(75,0,7),     Color3.fromRGB(72,0,2),      Color3.fromRGB(121,112,112), Color3.fromRGB(255,152,154)},
		Candy       = {Color3.fromRGB(255,105,180), Color3.fromRGB(255,182,193),Color3.fromRGB(200,50,150), Color3.fromRGB(255,20,147),  Color3.fromRGB(255,200,220), Color3.fromRGB(255,240,245)},
		Lava        = {Color3.fromRGB(200,50,0),    Color3.fromRGB(255,100,0),  Color3.fromRGB(150,20,0),   Color3.fromRGB(100,10,0),    Color3.fromRGB(255,160,0),   Color3.fromRGB(255,220,100)},
		Galaxy      = {Color3.fromRGB(60,0,120),    Color3.fromRGB(100,0,180),  Color3.fromRGB(30,0,80),    Color3.fromRGB(180,0,255),   Color3.fromRGB(80,0,160),    Color3.fromRGB(200,150,255)},
		YinYang     = {BG_COL, Color3.fromRGB(20,20,28), Color3.fromRGB(230,230,240), Color3.fromRGB(230,230,240), Color3.fromRGB(128,128,128), Color3.fromRGB(24,24,30)},
		Radioactive = {Color3.fromRGB(100,255,0),   Color3.fromRGB(150,255,50), Color3.fromRGB(50,200,0),   Color3.fromRGB(0,150,0),     Color3.fromRGB(200,255,100), Color3.fromRGB(230,255,180)},
		Cursed      = {Color3.fromRGB(255,23,23),   Color3.fromRGB(180,0,0),    Color3.fromRGB(120,0,0),    Color3.fromRGB(80,0,0),      Color3.fromRGB(255,100,100), Color3.fromRGB(255,180,180)},
		Divine      = {Color3.fromRGB(255,215,0),   Color3.fromRGB(255,255,200),Color3.fromRGB(200,160,0),  Color3.fromRGB(255,240,150), BG_COL,                      Color3.fromRGB(255,250,220)},
	}

	local function ApplyMutation(model, animalName, mutName)
		if not mutName or mutName == "None" then return end
		local sa = GetSharedAnimals()
		if sa then
			local ok = pcall(function() sa:ApplyMutation(model, animalName, mutName) end)
			if ok then return end
		end
		if mutName == "Rainbow" then
			model:AddTag("RainbowModel")
			return
		end
		local palette = MUT_PALETTES[mutName]
		if palette then
			for _, v in ipairs(model:GetDescendants()) do
				if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
					pcall(function()
						local colorIdx = tonumber(v:GetAttribute(mutName.."*Color") or v:GetAttribute("Color") or 1) or 1
						colorIdx = math.clamp(colorIdx, 1, #palette)
						local col = palette[colorIdx] or palette[1]
						if not col then return end
						local surfApp = v:FindFirstChildOfClass("SurfaceAppearance")
						if surfApp then surfApp:Destroy() end
						v.Color = col
						if v:GetAttribute("Neon") then v.Material = Enum.Material.Neon end
					end)
				end
			end
		end
	end

	local TRAIT_ICONS = {
		["Taco"]="rbxassetid://89041930759464",["Nyan"]="rbxassetid://104229924295526",
		["Galactic"]="rbxassetid://99181785766598",["Fireworks"]="rbxassetid://121100427764858",
		["Zombie"]="rbxassetid://110723387483939",["Claws"]="rbxassetid://104964195846833",
		["Glitched"]="rbxassetid://121332433272976",["Bubblegum"]="rbxassetid://100601425541874",
		["Fire"]="rbxassetid://118283346037788",["Wet"]="rbxassetid://78474194088770",
		["Snowy"]="rbxassetid://83627475909869",["Cometstruck"]="rbxassetid://127455440418221",
		["Explosive"]="rbxassetid://97725744252608",["Disco"]="rbxassetid://82620342632406",
		["10B"]="rbxassetid://134655415681926",["Shark Fin"]="rbxassetid://104985313532149",
		["Matteo Hat"]="rbxassetid://115664804212096",["Brazil"]="rbxassetid://75650816341229",
		["Sleepy"]="rbxassetid://115001117876534",["Lightning"]="rbxassetid://139729696247144",
		["UFO"]="rbxassetid://110910518481052",["Spider"]="rbxassetid://117478971325696",
		["Strawberry"]="rbxassetid://84731118566493",["Paint"]="rbxassetid://119591742504251",
		["Skeleton"]="rbxassetid://89591838221335",["Sombrero"]="rbxassetid://95128039793845",
		["Tie"]="rbxassetid://103610037004911",["Witch Hat"]="rbxassetid://123964048606874",
		["Indonesia"]="rbxassetid://93350414974589",["Meowl"]="rbxassetid://114748221761549",
		["RIP Gravestone"]="rbxassetid://123115843719383",["Jackolantern Pet"]="rbxassetid://97054765273857",
		["Santa Hat"]="rbxassetid://88375043733582",["Reindeer Pet"]="rbxassetid://70894779883038",
		["Skibidi"]="rbxassetid://83384385019272",["26"]="rbxassetid://80468035315420",
		["Rose"]="rbxassetid://135489065859287",[":3"]="rbxassetid://108293878529172",
		["Chocolate"]="rbxassetid://81641382604997",["Halo"]="rbxassetid://98316436141359",
		["Lucky"]="rbxassetid://124098467754457",["Orange Balloon"]="rbxassetid://83111173051279",
		["Green Balloon"]="rbxassetid://75222826429094",["Blue Balloon"]="rbxassetid://128841931686463",
		["Red Balloon"]="rbxassetid://119661964026012",["Pink Balloon"]="rbxassetid://114128099162490",
		["Rainbow Balloon"]="rbxassetid://112821854659961",["Granny"]="rbxassetid://73467619616299",
		["Bunny Ears"]="rbxassetid://118516289496954",["Orange Egg"]="rbxassetid://76307362192037",
		["Green Egg"]="rbxassetid://94602857440295",["Blue Egg"]="rbxassetid://109212886335786",
		["Pink Egg"]="rbxassetid://133939661230277",["John Pork"]="rbxassetid://117176397136731",
	}

	local function createBrainrotViewport(parent, animalName, mutation)
		local vp = Instance.new("ViewportFrame")
		vp.Size                   = UDim2.new(0, 46, 0, 46)
		vp.Position               = UDim2.new(0, 5, 0.5, -23)
		vp.BackgroundColor3       = Color3.fromRGB(14, 14, 18)
		vp.BackgroundTransparency = 0.05
		vp.BorderSizePixel        = 0
		vp.ZIndex                 = 4
		vp.LightDirection         = Vector3.new(-1, -2, -1)
		vp.LightColor             = Color3.fromRGB(220, 220, 255)
		vp.Ambient                = Color3.fromRGB(180, 180, 180)
		vp.Parent                 = parent
		create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = vp
		create("UIStroke", { Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }).Parent = vp

		local wm  = Instance.new("WorldModel"); wm.Parent = vp
		local cam = Instance.new("Camera"); cam.Parent = vp
		vp.CurrentCamera = cam

		task.spawn(function()
			local template = afGetTemplate(animalName)
			if not template then return end
			local clone = template:Clone()
			for _, d in ipairs(clone:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
			end
			clone.Parent = wm
			if mutation and mutation ~= "None" then
				ApplyMutation(clone, animalName, tostring(mutation))
			end
			for _, d in ipairs(wm:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
			end
			local cf, size = clone:GetBoundingBox()
			local maxDim = math.max(size.X, size.Y, size.Z)
			cam.FieldOfView = 50
			local fovRad = math.rad(cam.FieldOfView / 2)
			local dist = (maxDim / 2) / math.tan(fovRad) * 1.1
			local centerPos = cf.Position
			cam.CFrame = CFrame.new(centerPos + Vector3.new(0, 0, dist), centerPos)
			local animFolder = afGetAnimFolder(animalName)
			local idleAnim = animFolder and animFolder:FindFirstChild("Idle")
			local walkAnim = animFolder and animFolder:FindFirstChild("Walk")
			local useAnim = idleAnim or walkAnim
			if useAnim then
				local controller = clone:FindFirstChildWhichIsA("AnimationController", true) or clone:FindFirstChildWhichIsA("Humanoid", true)
				if not controller then controller = Instance.new("AnimationController"); controller.Parent = clone end
				local animator = controller:FindFirstChildWhichIsA("Animator")
				if not animator then animator = Instance.new("Animator"); animator.Parent = controller end
				local ok2, track = pcall(function() return animator:LoadAnimation(useAnim) end)
				if ok2 and track then track.Looped = true; track:Play() end
			end
			local angle = 0
			local orbitR = dist
			local _vpConn
			_vpConn = RunService.RenderStepped:Connect(function(dt)
				if not vp.Parent then _vpConn:Disconnect(); _vpConn = nil; return end
				angle = angle + dt * 0.6
				cam.CFrame = CFrame.new(
					Vector3.new(centerPos.X + math.sin(angle) * orbitR, centerPos.Y, centerPos.Z + math.cos(angle) * orbitR),
					centerPos
				)
			end)
			vp.AncestryChanged:Connect(function()
				if _vpConn and not vp.Parent then _vpConn:Disconnect(); _vpConn = nil end
			end)
		end)
		return vp
	end

	local selectedUID   = nil
	local onSelectCBs   = {}
	local builtUIDs     = {}
	local labelUpdaters = {}

	local function buildAnimalCard(rec, index)
		local uid = rec.plotName .. "_" .. rec.slot

		local card = create("Frame", {
			Name = "Card_" .. uid,
			Size = UDim2.new(1, 0, 0, 68),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			LayoutOrder = index,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = card
		local cStroke = create("UIStroke", { Color = Color3.fromRGB(55, 55, 55), ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		cStroke.Parent = card

		local accent = create("Frame", {
			Size = UDim2.new(0, 3, 0, 52), Position = UDim2.new(0, 0, 0, 8),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderSizePixel = 0, ZIndex = 2,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = accent
		accent.Parent = card

		local nameLbl = create("TextLabel", {
			Size = UDim2.new(1, -80, 0, 14), Position = UDim2.new(0, 10, 0, 7),
			BackgroundTransparency = 1, ZIndex = 4, Text = rec.name,
			TextColor3 = Color3.fromRGB(245, 245, 245), TextSize = 10,
			Font = Enum.Font.GothamBold,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		nameLbl.Parent = card

		local mutText = "Mut: " .. (rec.mutation and tostring(rec.mutation) or "None")
		local mutLbl = create("TextLabel", {
			Size = UDim2.new(1, -80, 0, 12), Position = UDim2.new(0, 10, 0, 22),
			BackgroundTransparency = 1, ZIndex = 4, Text = mutText,
			TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 8,
			Font = Enum.Font.GothamMedium,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		mutLbl.Parent = card

		local genLbl = create("TextLabel", {
			Size = UDim2.new(1, -80, 0, 12), Position = UDim2.new(0, 10, 0, 35),
			BackgroundTransparency = 1, ZIndex = 4, Text = "Gen: " .. rec.genText,
			TextColor3 = Color3.fromRGB(86, 196, 128), TextSize = 8,
			Font = Enum.Font.GothamBold,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		genLbl.Parent = card

		local orderText = (rec.plotOrder or rec.plotName) .. "  Â·  Slot #" .. rec.slot
		local podiumLbl = create("TextLabel", {
			Size = UDim2.new(1, -80, 0, 10), Position = UDim2.new(0, 10, 0, 49),
			BackgroundTransparency = 1, ZIndex = 4, Text = orderText,
			TextColor3 = Color3.fromRGB(90, 90, 90), TextSize = 7,
			Font = Enum.Font.Gotham,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		podiumLbl.Parent = card

		local selBtn = create("TextButton", {
			Size = UDim2.new(0, 48, 0, 20),
			Position = UDim2.new(1, -56, 0.5, -10),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			BorderSizePixel = 0, ZIndex = 5,
			Text = "SELECT", TextSize = 7,
			TextColor3 = Color3.fromRGB(130, 130, 130),
			Font = Enum.Font.GothamBold,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			AutoButtonColor = false,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 5) }).Parent = selBtn
		local selStroke = create("UIStroke", { Color = Color3.fromRGB(55, 55, 55), ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		selStroke.Parent = selBtn
		selBtn.Parent = card

		local isSelected = false
		local tweenF = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local function applySelectedVisual(v)
			isSelected = v
			if v then
				TweenService:Create(selBtn, tweenF, { BackgroundColor3 = Color3.fromRGB(245, 245, 245) }):Play()
				TweenService:Create(selStroke, tweenF, { Color = Color3.fromRGB(245, 245, 245) }):Play()
				TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(245, 245, 245) }):Play()
				TweenService:Create(accent, tweenF, { BackgroundColor3 = Color3.fromRGB(245, 245, 245) }):Play()
				selBtn.TextColor3 = Color3.fromRGB(12, 12, 12)
				selBtn.Text = "SELECTED"
			else
				TweenService:Create(selBtn, tweenF, { BackgroundColor3 = Color3.fromRGB(35, 35, 35) }):Play()
				TweenService:Create(selStroke, tweenF, { Color = Color3.fromRGB(55, 55, 55) }):Play()
				TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(55, 55, 55) }):Play()
				TweenService:Create(accent, tweenF, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
				selBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
				selBtn.Text = "SELECT"
			end
		end

		onSelectCBs[uid] = function(forceOff)
			if forceOff and isSelected then applySelectedVisual(false) end
		end

		local function programmaticSelect()
			if isSelected then return end
			if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
			applySelectedVisual(true)
			selectedUID = uid
			_G._FH_SelectedBrainrot = {
				uid = uid, name = rec.name, mutation = rec.mutation,
				gen = rec.genValue, genText = rec.genText,
				plotName = rec.plotName, slot = rec.slot, owner = rec.owner,
			}
		end

		if not _G._FH_CardSelectFns then _G._FH_CardSelectFns = {} end
		_G._FH_CardSelectFns[uid] = programmaticSelect

		selBtn.MouseButton1Click:Connect(function()
			if isSelected then
				applySelectedVisual(false)
				selectedUID = nil
				_G._FH_SelectedBrainrot = nil
			else
				if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
				applySelectedVisual(true)
				selectedUID = uid
				_G._FH_SelectedBrainrot = {
					uid = uid, name = rec.name, mutation = rec.mutation,
					gen = rec.genValue, genText = rec.genText,
					plotName = rec.plotName, slot = rec.slot, owner = rec.owner,
				}
			end
		end)
		selBtn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.Touch then
				selBtn.MouseButton1Click:Fire()
			end
		end)

		card.MouseEnter:Connect(function()
			if not isSelected then
				TweenService:Create(card, tweenF, { BackgroundColor3 = Color3.fromRGB(32, 32, 32) }):Play()
				TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(70, 70, 70) }):Play()
			end
		end)
		card.MouseLeave:Connect(function()
			if not isSelected then
				TweenService:Create(card, tweenF, { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
				TweenService:Create(cStroke, tweenF, { Color = Color3.fromRGB(55, 55, 55) }):Play()
			end
		end)

		labelUpdaters[uid] = function(newRec, newIndex)
			mutLbl.Text    = "Mut: " .. (newRec.mutation and tostring(newRec.mutation) or "None")
			genLbl.Text    = "Gen: " .. newRec.genText
			podiumLbl.Text = (newRec.plotOrder or newRec.plotName) .. "  Â·  Slot #" .. newRec.slot
			card.LayoutOrder = newIndex
		end

		return card
	end

	local scanning = false

	local function doScan()
		if scanning then return end
		scanning = true
		task.spawn(function()
			local ok, results = pcall(scanAllAnimals)
			if not ok or not results then results = {} end
			_G._FH_LastAnimalScan = results

			local seenUIDs = {}
			for _, rec in ipairs(results) do
				seenUIDs[rec.plotName .. "_" .. rec.slot] = true
			end

			for uid, _ in pairs(builtUIDs) do
				if not seenUIDs[uid] then
					for _, c in ipairs(animalsContainer:GetChildren()) do
						if c:IsA("Frame") and c.Name == "Card_"..uid then c:Destroy(); break end
					end
					builtUIDs[uid] = nil
					labelUpdaters[uid] = nil
					onSelectCBs[uid] = nil
					if selectedUID == uid then
						selectedUID = nil
						_G._FH_SelectedBrainrot = nil
					end
				end
			end

			for i, rec in ipairs(results) do
				local uid = rec.plotName .. "_" .. rec.slot
				if not builtUIDs[uid] then
					local card = buildAnimalCard(rec, i)
					card.Parent = animalsContainer
					builtUIDs[uid] = true
				else
					if labelUpdaters[uid] then labelUpdaters[uid](rec, i) end
				end
			end

			scanning = false
		end)
	end

	local function autoSelectBest()
		local results = _G._FH_LastAnimalScan
		if not results or #results == 0 then return end
		local best = results[1]
		if not best then return end
		local uid = best.plotName .. "_" .. best.slot
		if selectedUID == uid then return end
		if selectedUID and onSelectCBs[selectedUID] then onSelectCBs[selectedUID](true) end
		selectedUID = uid
		_G._FH_SelectedBrainrot = {
			uid = uid, name = best.name, mutation = best.mutation,
			gen = best.genValue, genText = best.genText,
			plotName = best.plotName, slot = best.slot, owner = best.owner,
		}
		if _G._FH_CardSelectFns and _G._FH_CardSelectFns[uid] then
			pcall(_G._FH_CardSelectFns[uid])
		end
	end
	_G._FH_AutoSelectBest = autoSelectBest

	task.spawn(function()
		task.wait(2)
		while true do
			doScan()
			task.wait(0.05)
			if AutoSelectBestBrainrot then pcall(autoSelectBest) end
			task.wait(4.95)
		end
	end)
end

local page2 = create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ZIndex = 2, ClipsDescendants = true })
local scroll2 = create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(75, 75, 75), ScrollingDirection = Enum.ScrollingDirection.Y, AutomaticCanvasSize = Enum.AutomaticSize.Y })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6) }).Parent = scroll2
create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }).Parent = scroll2

local s2h1 = makeSectionHeader("GRAB", 34, 44)
s2h1.LayoutOrder = 1
s2h1.Parent = scroll2
local t1 = makeToggleRow("Auto Block", "Blocks the plot owner after grab (ping-based)", function(v)
	AutoBlockEnabled = v
end)
t1.LayoutOrder = 2
t1.Parent = scroll2

local s2h2 = makeSectionHeader("FLASH", 41, 51)
s2h2.LayoutOrder = 3
s2h2.Parent = scroll2
local t2 = makeToggleRow("Auto Flash", "Automatically uses flash on enemies", function(v)
	AutoFlashEnabled = v
end)
t2.LayoutOrder = 4
t2.Parent = scroll2
local t3 = makeToggleRow("Ragdoll Bypass", "Bypasses ragdoll effects on your character", function(v)
	RagdollBypassEnabled = v
end)
t3.LayoutOrder = 5
t3.Parent = scroll2
local t4 = makeToggleRow("Anti Ragdoll", "Prevents ragdoll from triggering", function(v)
	if v then AntiRagdoll.enable() else AntiRagdoll.disable() end
end)
t4.LayoutOrder = 6
t4.Parent = scroll2

local s2h3 = makeSectionHeader("BRAINROT", 62, 72)
s2h3.LayoutOrder = 7
s2h3.Parent = scroll2
local t5 = makeToggleRow("Auto Select Best Brainrot", "Auto-selects the highest gen animal on scan", function(v)
	AutoSelectBestBrainrot = v
	if v and _G._FH_LastAnimalScan and #_G._FH_LastAnimalScan > 0 then
		pcall(_G._FH_AutoSelectBest)
	end
end)
t5.LayoutOrder = 8
t5.Parent = scroll2

scroll2.Parent = page2
page2.Parent = contentArea

local RaqBtn = create("TextButton", {
	Name = "RaqBtn", Size = UDim2.new(0, 34, 0, 34),
	Position = UDim2.new(0.5, -131, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, ZIndex = 20,
	Text = "RAQ", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 9,
	Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = RaqFlashBlock,
})
create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = RaqBtn
create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }).Parent = RaqBtn

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function switchTab(tabIndex)
	local isTab1 = (tabIndex == 1)
	page1.Visible = isTab1; page2.Visible = not isTab1
	TweenService:Create(tab1Underline, tweenInfo, { Size = isTab1 and UDim2.new(0.8, 0, 0, 2) or UDim2.new(0, 0, 0, 2) }):Play()
	TweenService:Create(tab2Underline, tweenInfo, { Size = isTab1 and UDim2.new(0, 0, 0, 2) or UDim2.new(0.8, 0, 0, 2) }):Play()
	TweenService:Create(tab1Label, tweenInfo, { TextColor3 = isTab1 and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(75, 75, 75) }):Play()
	TweenService:Create(tab2Label, tweenInfo, { TextColor3 = isTab1 and Color3.fromRGB(75, 75, 75) or Color3.fromRGB(245, 245, 245) }):Play()
end

tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)

local winVisible = true
RaqBtn.MouseButton1Click:Connect(function()
	winVisible = not winVisible
	if winVisible then
		Win.Visible = true
		TweenService:Create(winScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	else
		local t = TweenService:Create(winScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
		t:Play()
		t.Completed:Connect(function() if not winVisible then Win.Visible = false end end)
	end
end)

task.spawn(function()
	while true do
		winGradient.Rotation = (winGradient.Rotation + 1) % 360
		task.wait(0.03)
	end
end)

do
	local dragging, dragStart, startPos = false, nil, nil
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = Win.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

UserInputService.InputBegan:Connect(function(inp, gpe)
	if gpe then return end
	if inp.KeyCode == Enum.KeyCode.LeftControl or inp.KeyCode == Enum.KeyCode.RightControl then
		winVisible = not winVisible
		if winVisible then
			Win.Visible = true
			TweenService:Create(winScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		else
			local t = TweenService:Create(winScale, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
			t:Play()
			t.Completed:Connect(function() if not winVisible then Win.Visible = false end end)
		end
	end
end)

winScale.Scale = 0
task.wait(0.1)
TweenService:Create(winScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

pcall(ShowToggleNotification, "Raq Flash Block loaded", true)
