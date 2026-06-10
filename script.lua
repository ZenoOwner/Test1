do
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local Sync = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
    local patched = 0

    for name, fn in pairs(Sync) do
        if typeof(fn) ~= "function" then continue end
        if isexecutorclosure(fn) then continue end

        local ok, ups = pcall(debug.getupvalues, fn)
        if not ok then continue end

        for idx, val in pairs(ups) do
            if typeof(val) == "function" and not isexecutorclosure(val) then
                local ok2, innerUps = pcall(debug.getupvalues, val)
                if ok2 then
                    local hasBoolean = false
                    for _, v in pairs(innerUps) do
                        if typeof(v) == "boolean" then
                            hasBoolean = true
                            break
                        end
                    end
                    if hasBoolean then
                        debug.setupvalue(fn, idx, newcclosure(function() end))
                        patched += 1
                    end
                end
            end
        end
    end
end


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Points = {}

local S = {
    Players = Players,
    RunService = RunService,
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = Workspace,
}

local BrainrotState = {
    allAnimalsCache = {},
    lastAnimalHash = {},
    PromptMemoryCache = {},
    Synchronizer = nil,
    AnimalsData = nil,
    AnimalsShared = nil,
    NumberUtils = nil,
}

do
    local Packages = S.ReplicatedStorage:FindFirstChild("Packages")
    local Datas = S.ReplicatedStorage:FindFirstChild("Datas")
    local Shared = S.ReplicatedStorage:FindFirstChild("Shared")
    local Utils = S.ReplicatedStorage:FindFirstChild("Utils")

    pcall(function() BrainrotState.Synchronizer = Packages and require(Packages:WaitForChild("Synchronizer")) or nil end)
    pcall(function() BrainrotState.AnimalsData = Datas and require(Datas:WaitForChild("Animals")) or nil end)
    pcall(function() BrainrotState.AnimalsShared = Shared and require(Shared:WaitForChild("Animals")) or nil end)
    pcall(function() BrainrotState.NumberUtils = Utils and require(Utils:WaitForChild("NumberUtils")) or nil end)
end

local BRAINROT_DEFAULT_PRIORITY = {
    "Strawberry Elephant", "Meowl", "Skibidi Toilet", "Headless Horseman",
    "Dragon Gingerini", "Dragon Cannelloni", "Ketupat Bros", "Hydra Dragon Cannelloni",
    "La Supreme Combinasion", "Love Love Bear", "Ginger Gerat", "Cerberus", "Capitano Moby",
    "La Casa Boo", "Burguro And Fryuro", "Spooky and Pumpky", "Cooki and Milki", "Rosey and Teddy",
    "Popcuru and Fizzuru", "Reinito Sleighito", "Fragrama and Chocrama", "Garama and Madundung",
    "Ketchuru and Musturu", "La Secret Combinasion", "Tralaledon", "Tictac Sahur", "Ketupat Kepat",
    "Tang Tang Keletang", "Orcaledon", "La Ginger Sekolah", "Los Spaghettis", "Lavadorito Spinito",
    "Swaggy Bros", "La Taco Combinasion", "Los Primos", "Chillin Chili", "Tuff Toucan", "W or L",
    "Chipso and Queso",
}

local BrainrotConfig = {
    PriorityList = nil,
    UIPosX = nil,
    UIPosY = nil,
    MinGen = 0, -- in millions, e.g. 50 = 50m/s
    TpDelay = 0.624, -- task.wait delay before TP sequence, range 0.25-1.0
}

local BRAINROT_CONFIG_FILE = "thisismadebyxi.json"

local function BrainrotLoadConfig()
    local ok, raw = pcall(function()
        if readfile and isfile and isfile(BRAINROT_CONFIG_FILE) then
            return readfile(BRAINROT_CONFIG_FILE)
        end
        return nil
    end)
    if ok and raw and raw ~= "" then
        local decOk, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if decOk and type(decoded) == "table" then
            if type(decoded.PriorityList) == "table" and #decoded.PriorityList > 0 then
                BrainrotConfig.PriorityList = decoded.PriorityList
            end
            if type(decoded.UIPosX) == "number" then BrainrotConfig.UIPosX = decoded.UIPosX end
            if type(decoded.UIPosY) == "number" then BrainrotConfig.UIPosY = decoded.UIPosY end
            if type(decoded.MinGen) == "number" then BrainrotConfig.MinGen = decoded.MinGen end
            if type(decoded.TpDelay) == "number" then BrainrotConfig.TpDelay = math.clamp(decoded.TpDelay, 0.25, 1.0) end
        end
    end
    if not BrainrotConfig.PriorityList or #BrainrotConfig.PriorityList == 0 then
        BrainrotConfig.PriorityList = table.clone(BRAINROT_DEFAULT_PRIORITY)
    end
end

local function BrainrotSaveConfig()
    pcall(function()
        if writefile then
            writefile(BRAINROT_CONFIG_FILE, HttpService:JSONEncode(BrainrotConfig))
        end
    end)
end

BrainrotLoadConfig()

local function brainrotIsMyBaseAnimal(animalData)
    if not animalData or not animalData.plot then return false end
    local plots = S.Workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    if not BrainrotState.Synchronizer then return false end
    local ok, channel = pcall(function() return BrainrotState.Synchronizer:Get(plot.Name) end)
    if not ok or not channel then return false end
    local owner = channel:Get("Owner")
    if not owner then return false end
    if typeof(owner) == "Instance" and owner:IsA("Player") then return owner.UserId == LocalPlayer.UserId end
    if typeof(owner) == "table" and owner.UserId then return owner.UserId == LocalPlayer.UserId end
    if typeof(owner) == "Instance" then return owner == LocalPlayer end
    return false
end

local function brainrotGetAnimalHash(al)
    if not al then return "" end
    local h = ""
    for slot, d in pairs(al) do
        if type(d) == "table" then h = h .. tostring(slot) .. tostring(d.Index) .. tostring(d.Mutation) end
    end
    return h
end

local function brainrotScanSinglePlot(plot)
    if not BrainrotState.Synchronizer or not BrainrotState.AnimalsData or not BrainrotState.AnimalsShared or not BrainrotState.NumberUtils then return end
    local changed = false
    pcall(function()
        local ch = BrainrotState.Synchronizer:Get(plot.Name)
        if not ch then return end
        local al = ch:Get("AnimalList")
        local hash = brainrotGetAnimalHash(al)
        if BrainrotState.lastAnimalHash[plot.Name] == hash then return end
        BrainrotState.lastAnimalHash[plot.Name] = hash
        changed = true
        for i = #BrainrotState.allAnimalsCache, 1, -1 do
            if BrainrotState.allAnimalsCache[i].plot == plot.Name then table.remove(BrainrotState.allAnimalsCache, i) end
        end
        local owner = ch:Get("Owner")
        if not owner then return end
        local ownerName = (typeof(owner) == "Instance" and owner:IsA("Player") and owner.Name)
            or (type(owner) == "table" and owner.Name)
            or "Unknown"
        if not S.Players:FindFirstChild(ownerName) then return end
        if not al then return end
        for slot, ad in pairs(al) do
            if type(ad) == "table" then
                local aName = ad.Index
                local aInfo = BrainrotState.AnimalsData[aName]
                if aInfo then
                    local mut = ad.Mutation or "None"
                    if mut == "Yin Yang" then mut = "YinYang" end
                    local gv = 0
                    pcall(function() gv = BrainrotState.AnimalsShared:GetGeneration(aName, ad.Mutation, ad.Traits, nil) end)
                    local gt = "$" .. (BrainrotState.NumberUtils and BrainrotState.NumberUtils:ToString(gv) or tostring(gv)) .. "/s"
                    table.insert(BrainrotState.allAnimalsCache, {
                        name = aInfo.DisplayName or aName,
                        genText = gt,
                        genValue = gv,
                        mutation = mut,
                        owner = ownerName,
                        plot = plot.Name,
                        slot = tostring(slot),
                        uid = plot.Name .. "_" .. tostring(slot),
                        Traits = ad.Traits,
                    })
                end
            end
        end
    end)
    if changed then
        table.sort(BrainrotState.allAnimalsCache, function(a, b) return (a.genValue or 0) > (b.genValue or 0) end)
    end
end

task.defer(function()
    local plots = S.Workspace:WaitForChild("Plots", 10)
    if not plots then return end
    local function setupPlot(plot)
        brainrotScanSinglePlot(plot)
        plot.DescendantAdded:Connect(function() task.wait(0.1) brainrotScanSinglePlot(plot) end)
        plot.DescendantRemoving:Connect(function() task.wait(0.1) brainrotScanSinglePlot(plot) end)
    end
    for _, p in ipairs(plots:GetChildren()) do setupPlot(p) end
    plots.ChildAdded:Connect(function(p) task.wait(0.5) setupPlot(p) end)
end)

local function brainrotGetAllPets()
    local out = {}
    local minGenValue = (BrainrotConfig.MinGen or 0) * 1000000
    for _, a in ipairs(BrainrotState.allAnimalsCache) do
        if a.genValue and a.genValue >= 1 and a.genValue >= minGenValue and not brainrotIsMyBaseAnimal(a) then
            table.insert(out, a)
        end
    end
    return out
end

local function brainrotGetPetsInPriorityOrder()
    local pets = brainrotGetAllPets()
    if #pets == 0 then return {} end

    local priorityList = BrainrotConfig.PriorityList or BRAINROT_DEFAULT_PRIORITY
    local ordered = {}
    local used = {}

    for _, pname in ipairs(priorityList) do
        local best, bestIdx, bestGen = nil, nil, -math.huge
        for i, p in ipairs(pets) do
            if not used[i] and p.name == pname and p.genValue and p.genValue > bestGen then
                best = p
                bestIdx = i
                bestGen = p.genValue
            end
        end
        if best then
            table.insert(ordered, best)
            used[bestIdx] = true
        end
    end

    local rest = {}
    for i, p in ipairs(pets) do
        if not used[i] then
            table.insert(rest, p)
        end
    end
    table.sort(rest, function(a, b)
        return (a.genValue or 0) > (b.genValue or 0)
    end)
    for _, p in ipairs(rest) do
        table.insert(ordered, p)
    end

    return ordered
end

local function brainrotFindProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    -- Always do a fresh scan instead of returning cached prompt.
    -- When a priority pet is being held or stolen its prompt may be temporarily
    -- disabled; caching would cause us to skip it and fall to a lower priority.
    local cp = BrainrotState.PromptMemoryCache[animalData.uid]
    -- Only reuse cache if prompt still exists AND is enabled (not held/stolen)
    if cp and cp.Parent and cp.Enabled then return cp end
    -- Invalidate stale/disabled cache entry so we re-search below
    BrainrotState.PromptMemoryCache[animalData.uid] = nil
    local plots = S.Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end

    local ch = BrainrotState.Synchronizer and BrainrotState.Synchronizer:Get(plot.Name) or nil
    if not ch then
        local podium = podiums:FindFirstChild(animalData.slot)
        if podium then
            local base = podium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then
                local attach = spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") then
                            BrainrotState.PromptMemoryCache[animalData.uid] = p
                            return p
                        end
                    end
                end
            end
        end
    else
        local al = ch:Get("AnimalList")
        if not al then return nil end
        local brainrotName = animalData.name and animalData.name:lower() or ""
        local targetSlot = animalData.slot
        local foundPodium = nil
        for slot, ad in pairs(al) do
            if type(ad) == "table" and tostring(slot) == targetSlot then
                local aName = ad.Index
                local aInfo = BrainrotState.AnimalsData and BrainrotState.AnimalsData[aName]
                if aInfo and (aInfo.DisplayName or aName):lower() == brainrotName then
                    foundPodium = podiums:FindFirstChild(tostring(slot))
                    break
                end
            end
        end
        if not foundPodium then foundPodium = podiums:FindFirstChild(animalData.slot) end
        if not foundPodium then return nil end

        local base = foundPodium:FindFirstChild("Base")
        local spawn = base and base:FindFirstChild("Spawn")
        if not spawn then return nil end
        local attach = spawn:FindFirstChild("PromptAttachment")
        if attach then
            for _, p in ipairs(attach:GetChildren()) do
                if p:IsA("ProximityPrompt") then
                    BrainrotState.PromptMemoryCache[animalData.uid] = p
                    return p
                end
            end
        end
    end
    return nil
end

local function brainrotGetPromptPosition(prompt)
    if not prompt or not prompt.Parent then return nil end
    if prompt.Parent:IsA("BasePart") then return prompt.Parent.Position end
    if prompt.Parent:IsA("Attachment") and prompt.Parent.Parent and prompt.Parent.Parent:IsA("BasePart") then
        return prompt.Parent.Parent.Position
    end
    return nil
end

local numBases = 4
local sideOffsetX = -137
local firstLeft = Vector3.new(-341, 14, 200)
local firstRight = Vector3.new(-341, 14, 241)
local leftSpacing = -107
local rightSpacing = -107
local sideOffsetR = Vector3.new(-5.036865, -0.01, 5.19937)
local sideOffsetL = Vector3.new(-5.603241, -0.01, -4.993957)

local Bases = {}

for i = 0, numBases - 1 do
    local lPos = Vector3.new(firstLeft.X, firstLeft.Y, firstLeft.Z + leftSpacing * i)
    local rPos = Vector3.new(firstRight.X, firstRight.Y, firstRight.Z + rightSpacing * i)
    local sidePos = rPos + Vector3.new(-sideOffsetR.X, sideOffsetR.Y, sideOffsetR.Z)
    local otherSidePos = lPos + Vector3.new(-sideOffsetL.X, sideOffsetL.Y, sideOffsetL.Z)
    table.insert(Bases, { Left = lPos, Right = rPos, Side = 1, SidePos = sidePos, OtherSidePos = otherSidePos })
end

for i = 0, numBases - 1 do
    local lPos = Vector3.new(firstLeft.X + sideOffsetX, firstLeft.Y, firstLeft.Z + leftSpacing * i)
    local rPos = Vector3.new(firstRight.X + sideOffsetX, firstRight.Y, firstRight.Z + rightSpacing * i)
    local sidePos = rPos + sideOffsetR
    local otherSidePos = lPos + sideOffsetL
    table.insert(Bases, { Left = lPos, Right = rPos, Side = 2, SidePos = sidePos, OtherSidePos = otherSidePos })
end

local function getClosestBaseSide(promptPos)
    local bestIndex, bestSidePos, bestOtherSidePos = nil, nil, nil
    local bestDistToPrompt = math.huge
    
    for i, base in ipairs(Bases) do
        local dist1 = (promptPos - base.SidePos).Magnitude
        local dist2 = (promptPos - base.OtherSidePos).Magnitude
        
        if dist1 < bestDistToPrompt then
            bestDistToPrompt = dist1
            bestIndex = i
            bestSidePos = base.SidePos
            bestOtherSidePos = base.OtherSidePos
        end
        if dist2 < bestDistToPrompt then
            bestDistToPrompt = dist2
            bestIndex = i
            bestSidePos = base.OtherSidePos
            bestOtherSidePos = base.SidePos
        end
    end
    
    return bestIndex, bestSidePos, bestOtherSidePos
end

local clampMax = CFrame.new(-411.98956298828125, -5.408802032470703, 169.7320556640625).Position
local clampMin = CFrame.new(-408.99603271484375, -5.4088029861450195, -129.7340545654297).Position

local POS1_Y = 50.5

local function computePos1FromPos2(pos2, finalLookDir)
    local a = clampMin
    local b = clampMax
    local ab = b - a

    local t1 = (pos2 - a):Dot(ab) / ab:Dot(ab)
    local centerPoint = a + ab * t1

    local backPoint = centerPoint - finalLookDir.Unit * 50

    local t2 = (backPoint - a):Dot(ab) / ab:Dot(ab)
    t2 = math.clamp(t2, 0, 1)

    local abDotLook = ab:Dot(finalLookDir)
    if (t2 - t1) * abDotLook > 0 then
        t2 = t1
    end
    local finalPos1 = a + ab * t2

    return Vector3.new(finalPos1.X, POS1_Y, finalPos1.Z)
end

local function computeBrainrotCarpetPoints()
    local orderedPets = brainrotGetPetsInPriorityOrder()
    if #orderedPets == 0 then return nil, nil, nil, nil end

    local top, prompt
    for _, candidate in ipairs(orderedPets) do
        local p = brainrotFindProximityPromptForAnimal(candidate)
        -- Accept the prompt even if temporarily disabled (pet being held/stolen).
        -- This keeps priority-1 locked in instead of falling to priority-2.
        if p then
            top = candidate
            prompt = p
            break
        end
    end
    if not top or not prompt then
        return nil, nil, nil, nil
    end
    local promptPos = brainrotGetPromptPosition(prompt)
    if not promptPos then return nil, nil, nil, nil end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, nil, nil end
    local playerPos = hrp.Position

    local _, sidePos, otherSidePos = getClosestBaseSide(promptPos)
    if not sidePos or not otherSidePos then return nil, nil, nil, nil end

    local pos2 = sidePos
    local lookAt = Vector3.new(otherSidePos.X, sidePos.Y, otherSidePos.Z)
    local finalLookDir = (lookAt - sidePos).Unit

    local isFirstFloor = math.abs(promptPos.Y - sidePos.Y) <= 10
    local isLower = (promptPos.Y - sidePos.Y) < -10

    local doPostCloneTP = false

    if not isFirstFloor and not isLower then
        local lookDirXZ = Vector3.new(finalLookDir.X, 0, finalLookDir.Z).Unit
        local sideDir = Vector3.new(-lookDirXZ.Z, 0, lookDirXZ.X)
        local shiftAmount = (promptPos - sidePos):Dot(sideDir)
        local alignedPos2 = sidePos + sideDir * shiftAmount

        local function distOutOfBounds(z)
            if z > clampMax.Z then return z - clampMax.Z
            elseif z < clampMin.Z then return clampMin.Z - z
            else return 0 end
        end

        if distOutOfBounds(alignedPos2.Z) > 0 then
            if distOutOfBounds(otherSidePos.Z) < distOutOfBounds(sidePos.Z) then
                pos2 = otherSidePos
                finalLookDir = (sidePos - otherSidePos).Unit
            else
                pos2 = sidePos
            end
            doPostCloneTP = true
        else
            pos2 = alignedPos2
        end
    end

    if isLower then
        doPostCloneTP = true
    end

    local pos1 = computePos1FromPos2(pos2, finalLookDir)

    if isLower then
        pos2 = pos2 - Vector3.new(0, 15, 0)
    end

    return pos1, pos2, finalLookDir, promptPos, sidePos, doPostCloneTP, isFirstFloor
end

local SaveFileName = "ifyoupaidforthisyouhavenscammed.json"

local function SavePointsToFile()
    if writefile then
        local data = {}
        for _, cf in ipairs(Points) do 
            table.insert(data, {cf:GetComponents()}) 
        end
        pcall(function() writefile(SaveFileName, HttpService:JSONEncode(data)) end)
    end
end

local function LoadPointsFromFile()
    if readfile and isfile and isfile(SaveFileName) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(SaveFileName)) end)
        if success and type(decoded) == "table" then
            for _, comps in ipairs(decoded) do 
                table.insert(Points, CFrame.new(unpack(comps))) 
            end
        end
    end
end

LoadPointsFromFile()

local antiDieConnection = nil

local function enableAntiDie()
    if antiDieConnection then pcall(function() antiDieConnection:Disconnect() end) end
    antiDieConnection = nil
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.Health = humanoid.MaxHealth
    antiDieConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function disableAntiDie()
    if antiDieConnection then
        pcall(function() antiDieConnection:Disconnect() end)
        antiDieConnection = nil
    end
end

_G.isCloning = false
local function instantClone(disableLift)
    if _G.isCloning then return end
    _G.isCloning = true
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then return end
        local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
        if not cloner then return end
        pcall(function() hum:EquipTool(cloner) end)
        task.wait(0.02)
        cloner:Activate()
        task.wait(0.02)
        
        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        for _ = 1, 100 do
            if Workspace:FindFirstChild(cloneName) then break end
            task.wait(0.05)
        end
        
        local toolsFrames = LocalPlayer.PlayerGui:FindFirstChild("ToolsFrames")
        local qcFrame = toolsFrames and toolsFrames:FindFirstChild("QuantumCloner")
        local tpButton = qcFrame and qcFrame:FindFirstChild("TeleportToClone")
        if tpButton then
            tpButton.Visible = true
            local inset = GuiService:GetGuiInset()
            local pos = tpButton.AbsolutePosition + (tpButton.AbsoluteSize / 2) + inset
            if firesignal then
                firesignal(tpButton.MouseButton1Up)
            else
                local vim = cloneref(game:GetService("VirtualInputManager"))
                local pos = tpButton.AbsolutePosition + (tpButton.AbsoluteSize / 2) + inset
                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                task.wait()
                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            end
        end
        
        if not disableLift then
            task.delay(0.2, startLiftPlate)
        end
    end)
    _G.isCloning = false
end

function startLiftPlate()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local function destroyLiftPlate()
        if _G.LiftPlateConn then
            pcall(function() _G.LiftPlateConn:Disconnect() end)
            _G.LiftPlateConn = nil
        end
        if _G.LiftPlateStealConn then
            pcall(function() _G.LiftPlateStealConn:Disconnect() end)
            _G.LiftPlateStealConn = nil
        end
        if _G.LiftPlatePart and _G.LiftPlatePart.Parent then
            pcall(function() _G.LiftPlatePart:Destroy() end)
        end
        _G.LiftPlatePart = nil
    end

    if LocalPlayer:GetAttribute("Stealing") == true then
        destroyLiftPlate()
        return
    end

    destroyLiftPlate()

    local plate = Instance.new("Part")
    plate.Name = "LiftPlate"
    plate.Anchored = true
    plate.CanCollide = true
    plate.Transparency = 0.5
    plate.Color = Color3.fromRGB(255, 0, 0)
    plate.Material = Enum.Material.Neon
    plate.Size = Vector3.new(3, 1, 3)
    plate.Parent = Workspace

    _G.LiftPlatePart = plate

    -- Place the plate right beneath the brainrot when on 3rd floor, otherwise under player
    local plateY
    local plateX = hrp.Position.X
    local plateZ = hrp.Position.Z
    if _G.LiftPlateTargetY then
        plateY = _G.LiftPlateTargetY - 8
        plateX = _G.LiftPlateTargetX or hrp.Position.X
        plateZ = _G.LiftPlateTargetZ or hrp.Position.Z
        _G.LiftPlateTargetY = nil
        _G.LiftPlateTargetX = nil
        _G.LiftPlateTargetZ = nil
    else
        plateY = hrp.Position.Y - 3.5
    end
    plate.CFrame = CFrame.new(plateX, plateY, plateZ)

    local duration = 2.5
    local startTime = tick()

    _G.LiftPlateStealConn = LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        if LocalPlayer:GetAttribute("Stealing") == true then
            task.delay(0.3, destroyLiftPlate)
        end
    end)

    _G.LiftPlateConn = RunService.Heartbeat:Connect(function()
        local now = tick()
        local elapsed = now - startTime

        if LocalPlayer:GetAttribute("Stealing") == true then
            -- Disconnect heartbeat; StealConn will destroy the plate after 0.3s
            if _G.LiftPlateConn then pcall(function() _G.LiftPlateConn:Disconnect() end) _G.LiftPlateConn = nil end
            return
        end

        if not hrp or not hrp.Parent or elapsed >= duration then
            destroyLiftPlate()
            return
        end

        -- Hold plate fixed at its spawn XZ and Y (brainrot-anchored on 3rd floor)
        plate.CFrame = CFrame.new(plateX, plateY, plateZ)
    end)
end

local function EquipTool(name)
    local char = LocalPlayer.Character
    local tool = (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild(name)) or (char and char:FindFirstChild(name))
    if tool and tool:IsA("Tool") and char then char.Humanoid:EquipTool(tool) end
end

local getDelay, getOffset, getYLevel

local function PerformFlight()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    EquipTool("Flying Carpet")
    task.wait(0.1)
    -- TP directly to the target Y level instead of floating up
    local targetY = getYLevel()
    hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z, hrp.CFrame:GetComponents())
    hrp.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.05)
    return true
end

local function RunSequence(startIndex)
    if #Points == 0 then return end
    enableAntiDie()
    if (startIndex or 1) == 1 then if not PerformFlight() then disableAntiDie() return end end
    
    local delay = getDelay()
    local offset = getOffset()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for i = (startIndex or 1), #Points do
        local targetCFrame = Points[i]
        
        hrp.CFrame = targetCFrame
        task.wait(delay)

        if (hrp.Position - targetCFrame.Position).Magnitude > 6 then
            task.wait(1)
            RunSequence(i)
            return
        end
    end
    
    disableAntiDie()
end

local function RunCarpetSequence()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and hrp and hum) then return end

    local pos1, pos2, finalLookDir, brainrotPos, origSidePos, doPostCloneTP, isFirstFloor = computeBrainrotCarpetPoints()
    if not pos1 or not pos2 or not finalLookDir or not brainrotPos or not origSidePos then
        return
    end

    local diffY = brainrotPos.Y - origSidePos.Y
    local isHigher = (brainrotPos.Y > 18)
    local disableLift = not isHigher

    -- Lock camera to follow player rotation for the entire TP sequence
    local camera = Workspace.CurrentCamera
    local prevCameraType = camera.CameraType
    local prevFov = camera.FieldOfView
    local camConn
    camera.CameraType = Enum.CameraType.Scriptable
    camera.FieldOfView = 95
    camConn = RunService.RenderStepped:Connect(function()
        local curHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if curHrp then
            -- Place camera behind+above the player, aligned to HRP look direction
            camera.CFrame = curHrp.CFrame * CFrame.new(0, 2, 10) * CFrame.Angles(math.rad(-5), 0, 0)
            camera.FieldOfView = 95
        end
    end)
    local function stopCameraLock()
        if camConn then camConn:Disconnect(); camConn = nil end
        camera.CameraType = prevCameraType
        camera.FieldOfView = prevFov
    end

    enableAntiDie()
    task.wait(0.05)
    EquipTool("Flying Carpet")
    task.wait(0.05)

    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + finalLookDir)
    task.wait(0.05)

    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    task.wait(0.05)

    hrp.CFrame = CFrame.new(pos1, pos1 + finalLookDir)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 10, 0)

    hrp.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
    task.wait(0.1)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 10, 0)

    hrp.CFrame = CFrame.new(pos2, pos2 + finalLookDir)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 10, 0)

    task.wait(0.2)
    if isHigher then
        _G.LiftPlateTargetY = brainrotPos.Y
        _G.LiftPlateTargetX = brainrotPos.X
        _G.LiftPlateTargetZ = brainrotPos.Z
    end
    instantClone(disableLift)

    repeat task.wait() until not _G.isCloning
    task.wait(math.max(0.2, (0.1 + (LocalPlayer:GetNetworkPing() / 1000))))

    hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if doPostCloneTP or isFirstFloor then
            EquipTool("Flying Carpet")
            task.wait(0.02)
            local tpPos = Vector3.new(brainrotPos.X, hrp.Position.Y, brainrotPos.Z)
            hrp.CFrame = CFrame.new(tpPos, tpPos + finalLookDir)
        end

        if isHigher then
            if not doPostCloneTP and not isFirstFloor then
                EquipTool("Flying Carpet")
                task.wait(0.02)
            end
            if conn and conn.Connected then conn:Disconnect() end
        end
    end

    -- Spam TP to brainrot position up to 6 times
    -- 1st floor: 0.05s delay; 2nd/3rd floor: 55% slower
    local spamDelay = isFirstFloor and 0.05 or (0.05 / 0.35 * 0.815) * 1.55
    for i = 1, 6 do
        if LocalPlayer:GetAttribute("Stealing") == true then break end
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        local tpY
        if isHigher and _G.LiftPlatePart then
            -- Land character on top of the plate (plate top surface = plateY + 0.5 + HRP half-height ~3)
            tpY = _G.LiftPlatePart.Position.Y + 0.5 + 2.5
        else
            tpY = hrp.Position.Y
        end
        local tpPos = Vector3.new(brainrotPos.X, tpY, brainrotPos.Z)
        hrp.CFrame = CFrame.new(tpPos, tpPos + finalLookDir)
        task.wait(spamDelay)
    end

    disableAntiDie()
    stopCameraLock()
end

-- Tier color map: priority order is purple > blue > green > yellow
local BRAINROT_TIER_PRIORITY = { "purple", "blue", "green", "yellow" }
local BRAINROT_TIER_COLORS = {
    purple = Color3.fromRGB(160, 32, 240),
    blue   = Color3.fromRGB(32, 120, 255),
    green  = Color3.fromRGB(50, 220, 80),
    yellow = Color3.fromRGB(255, 220, 0),
}
local BRAINROT_TIER_MAP = {
    ["Strawberry Elephant"]      = "purple",
    ["Meowl"]                    = "purple",
    ["Skibidi Toilet"]           = "purple",
    ["Headless Horseman"]        = "purple",

    ["Dragon Gingerini"]         = "blue",
    ["Dragon Cannelloni"]        = "blue",
    ["Ketupat Bros"]             = "blue",
    ["Hydra Dragon Cannelloni"]  = "blue",

    ["La Supreme Combinasion"]   = "green",
    ["Love Love Bear"]           = "green",
    ["Ginger Gerat"]             = "green",
    ["Cerberus"]                 = "green",
    ["Capitano Moby"]            = "green",
    ["La Casa Boo"]              = "green",
    ["Burguro and Fryuro"]       = "green",
    ["Spooky and Pumpky"]        = "green",

    ["Cooki and Milki"]          = "yellow",
    ["Rosey and Teddy"]          = "yellow",
    ["Popcuru and Fizzuru"]      = "yellow",
    ["Reinito Sleighito"]        = "yellow",
    ["Fragrama and Chocrama"]    = "yellow",
    ["Garama and Madundung"]     = "yellow",
    ["Ketchuru and Musturu"]     = "yellow",
    ["La Secret Combinasion"]    = "yellow",
    ["Tralaledon"]               = "yellow",
    ["Tictac Sahur"]             = "yellow",
    ["Ketupat Kepat"]            = "yellow",
    ["Tang Tang Keletang"]       = "yellow",
    ["Orcaledon"]                = "yellow",
    ["La Ginger Sekolah"]        = "yellow",
    ["Los Spaghettis"]           = "yellow",
    ["Lavadorito Spinito"]       = "yellow",
    ["Swaggy Bros"]              = "yellow",
    ["La Taco Combinasion"]      = "yellow",
    ["Los Primos"]               = "yellow",
    ["Chillin Chili"]            = "yellow",
    ["Tuff Toucan"]              = "yellow",
    ["W or L"]                   = "yellow",
    ["Chipso and Queso"]         = "yellow",
}

local function getFlashColorFromCache()
    local bestTierIdx = math.huge
    for _, animal in ipairs(BrainrotState.allAnimalsCache) do
        local tier = BRAINROT_TIER_MAP[animal.name]
        if tier then
            for idx, t in ipairs(BRAINROT_TIER_PRIORITY) do
                if t == tier and idx < bestTierIdx then
                    bestTierIdx = idx
                    break
                end
            end
        end
    end
    if bestTierIdx < math.huge then
        return BRAINROT_TIER_COLORS[BRAINROT_TIER_PRIORITY[bestTierIdx]]
    end
    return Color3.new(1, 1, 1) -- fallback white
end

-- Tier sound IDs: escalating urgency from yellow (mild) to purple (most alarming)
local BRAINROT_TIER_SOUNDS = {
    purple = "rbxassetid://6042053626", -- sharp alarm / siren sting
    blue   = "rbxassetid://4612425274", -- urgent notification chime
    green  = "rbxassetid://4612425275", -- softer alert bell
    yellow = "rbxassetid://4612425272", -- gentle ping
}

local function playTierSound(tier)
    local soundId = BRAINROT_TIER_SOUNDS[tier]
    if not soundId then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.75
    sound.RollOffMaxDistance = 0
    sound.Parent = SoundService or Workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 5)
end

local function FlashWhite(duration)
    duration = duration or 0.125
    local fadeDuration = 0.15

    -- resolve tier once so sound and color are in sync
    local bestTierIdx = math.huge
    local bestTier = nil
    for _, animal in ipairs(BrainrotState.allAnimalsCache) do
        local tier = BRAINROT_TIER_MAP[animal.name]
        if tier then
            for idx, t in ipairs(BRAINROT_TIER_PRIORITY) do
                if t == tier and idx < bestTierIdx then
                    bestTierIdx = idx
                    bestTier = t
                    break
                end
            end
        end
    end
    local flashColor = bestTier and BRAINROT_TIER_COLORS[bestTier] or Color3.new(1, 1, 1)

    playTierSound(bestTier)

    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "FlashWhite"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    gui.ResetOnSpawn = false

    local glowSize = 0.14

    local edges = {
        { size = UDim2.new(1, 0, glowSize, 0),      pos = UDim2.new(0, 0, 0, 0),            gradRot = 90  }, -- top
        { size = UDim2.new(1, 0, glowSize, 0),      pos = UDim2.new(0, 0, 1 - glowSize, 0), gradRot = 270 }, -- bottom
        { size = UDim2.new(glowSize, 0, 1, 0),      pos = UDim2.new(0, 0, 0, 0),            gradRot = 0   }, -- left
        { size = UDim2.new(glowSize, 0, 1, 0),      pos = UDim2.new(1 - glowSize, 0, 0, 0), gradRot = 180 }, -- right
    }

    local frames = {}
    for _, e in ipairs(edges) do
        local f = Instance.new("Frame", gui)
        f.Size = e.size
        f.Position = e.pos
        f.BackgroundColor3 = flashColor
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0

        local grad = Instance.new("UIGradient", f)
        grad.Rotation = e.gradRot
        -- harsh at the edge (0), quickly lightens and dissolves inward
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,    0),
            NumberSequenceKeypoint.new(0.25, 0.3),
            NumberSequenceKeypoint.new(0.55, 0.7),
            NumberSequenceKeypoint.new(1,    1),
        })

        table.insert(frames, f)
    end

    local function tweenAll(targetTransp)
        local tweens = {}
        for _, f in ipairs(frames) do
            table.insert(tweens, TweenService:Create(f,
                TweenInfo.new(fadeDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = targetTransp }
            ))
        end
        for _, t in ipairs(tweens) do t:Play() end
        return tweens[1]
    end

    local tweenIn = tweenAll(0)
    tweenIn.Completed:Connect(function()
        task.wait(math.max(0, duration - fadeDuration * 2))
        local tweenOut = tweenAll(1)
        tweenOut.Completed:Connect(function()
            gui:Destroy()
        end)
    end)
end

local BR_PAD = 12
local BR_ROW_H = 28
local BR_HEADER_H = 36
local BR_BTN_H = 32
local BR_BORDER = 3
local BR_CORNER = 6

local Black = {
    bg      = Color3.fromRGB(20, 22, 28),
    bg2     = Color3.fromRGB(26, 28, 36),
    row     = Color3.fromRGB(28, 30, 38),
    rowSel  = Color3.fromRGB(36, 38, 48),
    line    = Color3.fromRGB(45, 48, 55),
    text    = Color3.fromRGB(255, 255, 255),
    dim     = Color3.fromRGB(160, 162, 170),
    teal    = Color3.fromRGB(100, 180, 255),
}

local RainbowColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 100, 255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 200, 255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 100, 255)),
})

local function addHoverAnimation(btn, baseColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = hoverColor }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = baseColor }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.05), { BackgroundTransparency = 0.2 }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0 }):Play()
    end)
end

local function getBrainrotViewportClone(petName)
    if not petName or petName == "" then return nil end
    local modelsFolder = S.ReplicatedStorage:FindFirstChild("Models")
    if not modelsFolder then return nil end
    local animalsFolder = modelsFolder:FindFirstChild("Animals")
    if not animalsFolder then return nil end
    local srcModel = animalsFolder:FindFirstChild(petName)
    if not srcModel then return nil end

    local newVp = Instance.new("ViewportFrame")
    newVp.BackgroundTransparency = 1
    newVp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    newVp.BorderSizePixel = 0
    newVp.ImageColor3 = Color3.fromRGB(255, 255, 255)
    newVp.Visible = true

    local worldModel = Instance.new("WorldModel")
    worldModel.Name = "BrainrotWorldModel"
    worldModel.Parent = newVp

    local clonedModel = srcModel:Clone()
    clonedModel.Parent = worldModel

    local animsRoot = S.ReplicatedStorage:FindFirstChild("Animations")
    local animalsAnims = animsRoot and animsRoot:FindFirstChild("Animals")
    local thisAnimFolder = animalsAnims and animalsAnims:FindFirstChild(petName)
    local idleAnim = thisAnimFolder and thisAnimFolder:FindFirstChild("Idle")

    if idleAnim and idleAnim:IsA("Animation") then
        local animator = nil
        for _, d in ipairs(clonedModel:GetDescendants()) do
            if d:IsA("Animator") then
                animator = d
                break
            end
        end
        if not animator then
            local ac = Instance.new("AnimationController")
            ac.Name = "BrainrotAnimationController"
            ac.Parent = clonedModel
            animator = Instance.new("Animator")
            animator.Parent = ac
        end
        if animator then
            local track = animator:LoadAnimation(idleAnim)
            if track then
                track.Looped = false
                local goingForward = true

                local function playDirection()
                    if goingForward then
                        track.TimePosition = 0
                        track:AdjustSpeed(1)
                    else
                        track.TimePosition = track.Length
                        track:AdjustSpeed(-1)
                    end
                    track:Play()
                end

                track.Stopped:Connect(function()
                    goingForward = not goingForward
                    playDirection()
                end)

                playDirection()
            end
        end
    end

    local cam = Instance.new("Camera")
    cam.Name = "BrainrotCamera"
    cam.Parent = newVp
    local cf, size = clonedModel:GetBoundingBox()
    
    clonedModel:PivotTo(cf * CFrame.Angles(0, math.rad(180), 0))
    cf = clonedModel:GetPivot()
    
    local maxSize = math.max(size.X, size.Y, size.Z)
    local dist = math.max(maxSize * 0.8, 1.5)
    local camPos = cf.Position + (cf.LookVector * (dist * 1.2)) + (cf.RightVector * (dist * 0.5)) + (cf.UpVector * (dist * 0.4))
    
    local targetPos = cf.Position + (cf.UpVector * (maxSize * 0.2))
    cam.CFrame = CFrame.new(camPos, targetPos)
    
    newVp.CurrentCamera = cam
    return newVp
end

local function BrainrotOpenPriorityEditor()
    local popGui = Instance.new("ScreenGui")
    popGui.Name = "BrainrotPriorityEditor"
    popGui.ResetOnSpawn = false
    popGui.DisplayOrder = 100
    popGui.Parent = PlayerGui

    local popW, popH = 400, 580
    local borderOuterW = popW + BR_BORDER * 2
    local borderOuterH = popH + BR_BORDER * 2

    local borderFrame = Instance.new("Frame")
    borderFrame.Size = UDim2.new(0, borderOuterW, 0, borderOuterH)
    borderFrame.Position = UDim2.new(0.5, -borderOuterW/2, 0.5, -borderOuterH/2)
    borderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    borderFrame.BorderSizePixel = 0
    borderFrame.Parent = popGui

    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, BR_CORNER + 2)
    borderCorner.Parent = borderFrame

    local borderGrad = Instance.new("UIGradient")
    borderGrad.Color = RainbowColors
    borderGrad.Rotation = 0
    borderGrad.Parent = borderFrame

    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.Size = UDim2.new(1, -BR_BORDER * 2, 1, -BR_BORDER * 2)
    inner.Position = UDim2.new(0, BR_BORDER, 0, BR_BORDER)
    inner.BackgroundColor3 = Black.bg
    inner.BorderSizePixel = 0
    inner.Parent = borderFrame

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, BR_CORNER)
    innerCorner.Parent = inner

    local innerStroke = Instance.new("UIStroke")
    innerStroke.Thickness = 1.5
    innerStroke.Color = Black.line
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerStroke.Parent = inner

    local headerH = 44
    local popTitle = Instance.new("TextLabel")
    popTitle.Size = UDim2.new(1, 0, 0, headerH)
    popTitle.Position = UDim2.new(0, 0, 0, 0)
    popTitle.BackgroundTransparency = 1
    popTitle.Text = "Brainrot priority editor"
    popTitle.Font = Enum.Font.GothamBold
    popTitle.TextSize = 18
    popTitle.TextColor3 = Black.text
    popTitle.TextXAlignment = Enum.TextXAlignment.Center
    popTitle.Parent = inner

    local allNamesSet = {}
    local allNames = {}

    if BrainrotState.AnimalsData then
        for idx, info in pairs(BrainrotState.AnimalsData) do
            local dn = (type(info) == "table" and info.DisplayName) or idx
            if dn and not allNamesSet[dn] then
                allNamesSet[dn] = true
                table.insert(allNames, dn)
            end
        end
    end

    local function ensureInAll(name)
        if name and not allNamesSet[name] then
            allNamesSet[name] = true
            table.insert(allNames, name)
        end
    end

    for _, n in ipairs(BRAINROT_DEFAULT_PRIORITY) do
        ensureInAll(n)
    end
    for _, n in ipairs(BrainrotConfig.PriorityList or {}) do
        ensureInAll(n)
    end

    table.sort(allNames, function(a, b)
        return tostring(a):lower() < tostring(b):lower()
    end)

    local priorityList = table.clone(BrainrotConfig.PriorityList or BRAINROT_DEFAULT_PRIORITY)
    local prioritySet = {}
    for _, n in ipairs(priorityList) do
        prioritySet[n] = true
    end

    local BR_TAB_H = 36
    local scrollTop = headerH + BR_TAB_H + BR_PAD * 2
    local closeH = BR_BTN_H + 8
    local scrollH = popH - scrollTop - closeH - BR_PAD

    local tabs = Instance.new("Frame", inner)
    tabs.Size = UDim2.new(1, -BR_PAD*2, 0, BR_TAB_H)
    tabs.Position = UDim2.new(0, BR_PAD, 0, headerH + 4)
    tabs.BackgroundTransparency = 1

    local tabPrioBtn = Instance.new("TextButton", tabs)
    tabPrioBtn.Size = UDim2.new(0.5, -4, 1, 0)
    tabPrioBtn.Position = UDim2.new(0, 0, 0, 0)
    tabPrioBtn.BackgroundColor3 = Black.rowSel
    tabPrioBtn.Text = "Priority List"
    tabPrioBtn.Font = Enum.Font.GothamBold
    tabPrioBtn.TextSize = 14
    tabPrioBtn.TextColor3 = Black.text
    tabPrioBtn.AutoButtonColor = false
    Instance.new("UICorner", tabPrioBtn).CornerRadius = UDim.new(0, 6)
    local prioStroke = Instance.new("UIStroke", tabPrioBtn)
    prioStroke.Color = Color3.fromRGB(0, 0, 0)
    prioStroke.Thickness = 1
    addHoverAnimation(tabPrioBtn, Black.rowSel, Color3.fromRGB(48, 52, 64))

    local tabAllBtn = Instance.new("TextButton", tabs)
    tabAllBtn.Size = UDim2.new(0.5, -4, 1, 0)
    tabAllBtn.Position = UDim2.new(0.5, 4, 0, 0)
    tabAllBtn.BackgroundColor3 = Black.row
    tabAllBtn.Text = "All Brainrots"
    tabAllBtn.Font = Enum.Font.GothamBold
    tabAllBtn.TextSize = 14
    tabAllBtn.TextColor3 = Black.dim
    tabAllBtn.AutoButtonColor = false
    Instance.new("UICorner", tabAllBtn).CornerRadius = UDim.new(0, 6)
    local allStroke = Instance.new("UIStroke", tabAllBtn)
    allStroke.Color = Black.line
    allStroke.Thickness = 1
    addHoverAnimation(tabAllBtn, Black.row, Black.rowSel)

    local priorityScroll = Instance.new("ScrollingFrame", inner)
    priorityScroll.Size = UDim2.new(1, -BR_PAD*2, 0, scrollH)
    priorityScroll.Position = UDim2.new(0, BR_PAD, 0, scrollTop)
    priorityScroll.BackgroundColor3 = Black.bg2
    priorityScroll.BorderSizePixel = 0
    priorityScroll.ScrollBarThickness = 6
    priorityScroll.ScrollBarImageColor3 = Black.teal
    priorityScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    priorityScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    priorityScroll.ClipsDescendants = true
    Instance.new("UICorner", priorityScroll).CornerRadius = UDim.new(0, 8)
    local priorityStroke = Instance.new("UIStroke", priorityScroll)
    priorityStroke.Color = Black.line
    priorityStroke.Thickness = 1

    local priorityLayout = Instance.new("UIListLayout", priorityScroll)
    priorityLayout.Padding = UDim.new(0, 4)
    priorityLayout.SortOrder = Enum.SortOrder.LayoutOrder
    priorityLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local leftScroll = Instance.new("ScrollingFrame", inner)
    leftScroll.Size = UDim2.new(1, -BR_PAD*2, 0, scrollH)
    leftScroll.Position = UDim2.new(0, BR_PAD, 0, scrollTop)
    leftScroll.BackgroundColor3 = Black.bg2
    leftScroll.BorderSizePixel = 0
    leftScroll.ScrollBarThickness = 6
    leftScroll.ScrollBarImageColor3 = Black.dim
    leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    leftScroll.ClipsDescendants = true
    leftScroll.Visible = false
    Instance.new("UICorner", leftScroll).CornerRadius = UDim.new(0, 8)
    local leftStroke = Instance.new("UIStroke", leftScroll)
    leftStroke.Color = Black.line
    leftStroke.Thickness = 1

    local leftLayout = Instance.new("UIListLayout", leftScroll)
    leftLayout.Padding = UDim.new(0, 4)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    tabPrioBtn.MouseButton1Click:Connect(function()
        tabPrioBtn.BackgroundColor3 = Black.rowSel
        tabPrioBtn.TextColor3 = Black.text
        prioStroke.Color = Color3.fromRGB(0, 0, 0)
        
        tabAllBtn.BackgroundColor3 = Black.row
        tabAllBtn.TextColor3 = Black.dim
        allStroke.Color = Black.line
        
        priorityScroll.Visible = true
        leftScroll.Visible = false
    end)
    
    tabAllBtn.MouseButton1Click:Connect(function()
        tabAllBtn.BackgroundColor3 = Black.rowSel
        tabAllBtn.TextColor3 = Black.text
        allStroke.Color = Color3.fromRGB(0, 0, 0)
        
        tabPrioBtn.BackgroundColor3 = Black.row
        tabPrioBtn.TextColor3 = Black.dim
        prioStroke.Color = Black.line
        
        leftScroll.Visible = true
        priorityScroll.Visible = false
    end)

    local closeBtn = Instance.new("TextButton", inner)
    closeBtn.Size = UDim2.new(1, -BR_PAD*2, 0, BR_BTN_H)
    closeBtn.Position = UDim2.new(0, BR_PAD, 1, -BR_PAD - BR_BTN_H)
    closeBtn.BackgroundColor3 = Black.row
    closeBtn.Text = "Close"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Black.text
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", closeBtn).Color = Black.line
    addHoverAnimation(closeBtn, Black.row, Black.rowSel)

    local function savePriority()
        BrainrotConfig.PriorityList = priorityList
        BrainrotSaveConfig()
    end

    local refreshAllList, refreshPriorityList

    local function removeFromPriority(name)
        for i = #priorityList, 1, -1 do
            if priorityList[i] == name then
                table.remove(priorityList, i)
            end
        end
        prioritySet[name] = nil
        savePriority()
        refreshPriorityList()
        refreshAllList()
    end

    local function addToPriority(name)
        if prioritySet[name] then return end
        table.insert(priorityList, name)
        prioritySet[name] = true
        savePriority()
        refreshPriorityList()
        refreshAllList()
    end

    refreshAllList = function()
        for _, c in ipairs(leftScroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        for _, name in ipairs(allNames) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -8, 0, 48)
            row.BackgroundColor3 = Black.row
            row.BorderSizePixel = 0
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
            Instance.new("UIStroke", row).Color = Black.line

            local vp = getBrainrotViewportClone(name)
            local iconSz = 44
            if vp then
                vp.Name = "BrainrotIcon"
                vp.BackgroundTransparency = 0.5
                vp.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                Instance.new("UICorner", vp).CornerRadius = UDim.new(0, 4)
                vp.AnchorPoint = Vector2.new(0, 0.5)
                vp.Position = UDim2.new(0, 4, 0.5, 0)
                vp.Size = UDim2.new(0, iconSz, 0, iconSz)
                vp.Parent = row
            end

            local lblOffset = vp and (iconSz + 12) or 12
            local lblWidth = 44 + (vp and (iconSz + 8) or 8)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -lblWidth, 1, 0)
            lbl.Position = UDim2.new(0, lblOffset, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.TextColor3 = prioritySet[name] and Black.dim or Black.text

            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 40, 0, 40)
            btn.Position = UDim2.new(1, -44, 0, 4)
            btn.BackgroundColor3 = Black.rowSel
            btn.Text = prioritySet[name] and "-" or "+"
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 16
            btn.TextColor3 = prioritySet[name] and Color3.fromRGB(220, 80, 80) or Black.teal
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            addHoverAnimation(btn, Black.rowSel, Color3.fromRGB(48, 52, 64))

            btn.MouseButton1Click:Connect(function()
                if prioritySet[name] then
                    removeFromPriority(name)
                else
                    addToPriority(name)
                end
            end)

            row.Parent = leftScroll
        end
    end

    refreshPriorityList = function()
        for _, c in ipairs(priorityScroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        for i, name in ipairs(priorityList) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -8, 0, 48)
            row.BackgroundColor3 = Black.row
            row.BorderSizePixel = 0
            row.LayoutOrder = i
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
            Instance.new("UIStroke", row).Color = Black.line

            local idxLabel = Instance.new("TextLabel", row)
            idxLabel.Size = UDim2.new(0, 24, 1, 0)
            idxLabel.Position = UDim2.new(0, 4, 0, 0)
            idxLabel.BackgroundTransparency = 1
            idxLabel.Text = tostring(i)
            idxLabel.Font = Enum.Font.GothamBold
            idxLabel.TextSize = 13
            idxLabel.TextColor3 = Black.dim
            idxLabel.TextXAlignment = Enum.TextXAlignment.Center

            local vp = getBrainrotViewportClone(name)
            local iconSz = 44
            if vp then
                vp.Name = "BrainrotIcon"
                vp.BackgroundTransparency = 0.5
                vp.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                Instance.new("UICorner", vp).CornerRadius = UDim.new(0, 4)
                vp.AnchorPoint = Vector2.new(0, 0.5)
                vp.Position = UDim2.new(0, 28, 0.5, 0)
                vp.Size = UDim2.new(0, iconSz, 0, iconSz)
                vp.Parent = row
            end

            local lblOffset = vp and (28 + iconSz + 4) or 28
            local lblWidth = 114 + (vp and (iconSz + 4) or 0)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -lblWidth, 1, 0)
            lbl.Position = UDim2.new(0, lblOffset, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextColor3 = Black.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd

            local upBtn = Instance.new("TextButton", row)
            upBtn.Size = UDim2.new(0, 32, 0, 40)
            upBtn.Position = UDim2.new(1, -114, 0, 4)
            upBtn.BackgroundColor3 = Black.rowSel
            upBtn.Text = "â†‘"
            upBtn.Font = Enum.Font.GothamBold
            upBtn.TextSize = 14
            upBtn.TextColor3 = Black.teal
            upBtn.BorderSizePixel = 0
            upBtn.AutoButtonColor = false
            Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 4)
            addHoverAnimation(upBtn, Black.rowSel, Color3.fromRGB(48, 52, 64))

            local downBtn = Instance.new("TextButton", row)
            downBtn.Size = UDim2.new(0, 32, 0, 40)
            downBtn.Position = UDim2.new(1, -76, 0, 4)
            downBtn.BackgroundColor3 = Black.rowSel
            downBtn.Text = "â†“"
            downBtn.Font = Enum.Font.GothamBold
            downBtn.TextSize = 14
            downBtn.TextColor3 = Black.teal
            downBtn.BorderSizePixel = 0
            downBtn.AutoButtonColor = false
            Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 4)
            addHoverAnimation(downBtn, Black.rowSel, Color3.fromRGB(48, 52, 64))

            local remBtn = Instance.new("TextButton", row)
            remBtn.Size = UDim2.new(0, 32, 0, 40)
            remBtn.Position = UDim2.new(1, -38, 0, 4)
            remBtn.BackgroundColor3 = Black.rowSel
            remBtn.Text = "X"
            remBtn.Font = Enum.Font.GothamBold
            remBtn.TextSize = 12
            remBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
            remBtn.BorderSizePixel = 0
            remBtn.AutoButtonColor = false
            Instance.new("UICorner", remBtn).CornerRadius = UDim.new(0, 4)
            addHoverAnimation(remBtn, Black.rowSel, Color3.fromRGB(48, 52, 64))

            upBtn.MouseButton1Click:Connect(function()
                if i <= 1 then return end
                priorityList[i], priorityList[i-1] = priorityList[i-1], priorityList[i]
                savePriority()
                refreshPriorityList()
            end)

            downBtn.MouseButton1Click:Connect(function()
                if i >= #priorityList then return end
                priorityList[i], priorityList[i+1] = priorityList[i+1], priorityList[i]
                savePriority()
                refreshPriorityList()
            end)

            remBtn.MouseButton1Click:Connect(function()
                removeFromPriority(name)
            end)

            row.Parent = priorityScroll
        end
    end

    refreshPriorityList()
    refreshAllList()

    closeBtn.MouseButton1Click:Connect(function()
        popGui:Destroy()
    end)

    task.spawn(function()
        local t = 0
        while borderGrad and borderGrad.Parent do
            t = (t + 0.5) % 360
            borderGrad.Rotation = t
            RunService.Heartbeat:Wait()
        end
    end)
end

do
    local brGui = Instance.new("ScreenGui")
    brGui.Name = "BrainrotPrioritySmall"
    brGui.ResetOnSpawn = false
    brGui.DisplayOrder = 9
    brGui.Parent = PlayerGui

    local panelW, panelH = 280, 230
    local borderOuterW = panelW + BR_BORDER * 2
    local borderOuterH = panelH + BR_BORDER * 2

    local borderFrame = Instance.new("Frame")
    borderFrame.Size = UDim2.new(0, borderOuterW, 0, borderOuterH)
    borderFrame.Position = BrainrotConfig.UIPosX and BrainrotConfig.UIPosY and UDim2.new(0, BrainrotConfig.UIPosX, 0, BrainrotConfig.UIPosY)
        or UDim2.new(0, 24, 0, 200)
    borderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    borderFrame.BorderSizePixel = 0
    borderFrame.Parent = brGui

    local borderCorner = Instance.new("UICorner", borderFrame)
    borderCorner.CornerRadius = UDim.new(0, BR_CORNER + 2)

    local borderGrad = Instance.new("UIGradient", borderFrame)
    borderGrad.Color = RainbowColors
    borderGrad.Rotation = 0

    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.Size = UDim2.new(1, -BR_BORDER * 2, 1, -BR_BORDER * 2)
    inner.Position = UDim2.new(0, BR_BORDER, 0, BR_BORDER)
    inner.BackgroundColor3 = Black.bg
    inner.BorderSizePixel = 0
    inner.Parent = borderFrame

    local innerCorner = Instance.new("UICorner", inner)
    innerCorner.CornerRadius = UDim.new(0, BR_CORNER)

    local innerStroke = Instance.new("UIStroke", inner)
    innerStroke.Thickness = 1.5
    innerStroke.Color = Black.line
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local title = Instance.new("TextLabel", inner)
    title.Size = UDim2.new(1, 0, 0, 32)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "1k tp my ass"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Black.text
    title.TextXAlignment = Enum.TextXAlignment.Center

    local priorityBtn = Instance.new("TextButton", inner)
    priorityBtn.Size = UDim2.new(0, 140, 0, 32)
    priorityBtn.Position = UDim2.new(0.5, -70, 0, 40)
    priorityBtn.BackgroundColor3 = Black.rowSel
    priorityBtn.Text = "Edit priority"
    priorityBtn.Font = Enum.Font.GothamBold
    priorityBtn.TextSize = 13
    priorityBtn.TextColor3 = Black.teal
    priorityBtn.BorderSizePixel = 0
    priorityBtn.AutoButtonColor = false
    Instance.new("UICorner", priorityBtn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", priorityBtn).Color = Black.line
    addHoverAnimation(priorityBtn, Black.rowSel, Color3.fromRGB(48, 52, 64))

    local hint = Instance.new("TextLabel", inner)
    hint.Size = UDim2.new(1, -BR_PAD*2, 0, 32)
    hint.Position = UDim2.new(0, BR_PAD, 0, 166)
    hint.BackgroundTransparency = 1
    hint.Text = "67"
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 10
    hint.TextColor3 = Black.dim
    hint.TextXAlignment = Enum.TextXAlignment.Center
    hint.TextYAlignment = Enum.TextYAlignment.Center
    hint.TextWrapped = true

    -- Min Gen row
    local minGenLabel = Instance.new("TextLabel", inner)
    minGenLabel.Size = UDim2.new(0, 148, 0, 28)
    minGenLabel.Position = UDim2.new(0, BR_PAD, 0, 78)
    minGenLabel.BackgroundTransparency = 1
    minGenLabel.Text = "Min TP Gen (m/s):"
    minGenLabel.Font = Enum.Font.GothamBold
    minGenLabel.TextSize = 13
    minGenLabel.TextColor3 = Black.teal
    minGenLabel.TextXAlignment = Enum.TextXAlignment.Left
    minGenLabel.TextYAlignment = Enum.TextYAlignment.Center

    local minGenBox = Instance.new("TextBox", inner)
    minGenBox.Size = UDim2.new(0, 72, 0, 24)
    minGenBox.Position = UDim2.new(1, -(72 + BR_PAD), 0, 81)
    minGenBox.BackgroundColor3 = Black.rowSel
    minGenBox.BorderSizePixel = 0
    minGenBox.Text = tostring(BrainrotConfig.MinGen or 0)
    minGenBox.Font = Enum.Font.GothamBold
    minGenBox.TextSize = 13
    minGenBox.TextColor3 = Black.teal
    minGenBox.ClearTextOnFocus = false
    minGenBox.PlaceholderText = "0"
    Instance.new("UICorner", minGenBox).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", minGenBox).Color = Black.line

    minGenBox.FocusLost:Connect(function()
        local val = tonumber(minGenBox.Text)
        if val and val >= 0 then
            BrainrotConfig.MinGen = val
            minGenBox.Text = tostring(val)
        else
            minGenBox.Text = tostring(BrainrotConfig.MinGen or 0)
        end
        BrainrotSaveConfig()
    end)

    -- TP Keybind row
    if not BrainrotConfig.TpKeybind then BrainrotConfig.TpKeybind = "F" end

    local tpKeybindLabel = Instance.new("TextLabel", inner)
    tpKeybindLabel.Size = UDim2.new(0, 148, 0, 28)
    tpKeybindLabel.Position = UDim2.new(0, BR_PAD, 0, 108)
    tpKeybindLabel.BackgroundTransparency = 1
    tpKeybindLabel.Text = "TP Keybind:"
    tpKeybindLabel.Font = Enum.Font.GothamBold
    tpKeybindLabel.TextSize = 13
    tpKeybindLabel.TextColor3 = Black.teal
    tpKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    tpKeybindLabel.TextYAlignment = Enum.TextYAlignment.Center

    local tpKeybindBtn = Instance.new("TextButton", inner)
    tpKeybindBtn.Size = UDim2.new(0, 72, 0, 24)
    tpKeybindBtn.Position = UDim2.new(1, -(72 + BR_PAD), 0, 111)
    tpKeybindBtn.BackgroundColor3 = Black.rowSel
    tpKeybindBtn.BorderSizePixel = 0
    tpKeybindBtn.Text = BrainrotConfig.TpKeybind
    tpKeybindBtn.Font = Enum.Font.GothamBold
    tpKeybindBtn.TextSize = 13
    tpKeybindBtn.TextColor3 = Black.teal
    tpKeybindBtn.AutoButtonColor = false
    Instance.new("UICorner", tpKeybindBtn).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", tpKeybindBtn).Color = Black.line
    addHoverAnimation(tpKeybindBtn, Black.rowSel, Color3.fromRGB(48, 52, 64))

    local listeningForKey = false
tpKeybindBtn.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey = true
    tpKeybindBtn.Text = "..."
    tpKeybindBtn.TextColor3 = Color3.fromRGB(255, 220, 0)
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local keyName = input.KeyCode.Name
            BrainrotConfig.TpKeybind = keyName
            BrainrotSaveConfig()
            tpKeybindBtn.Text = keyName
            tpKeybindBtn.TextColor3 = Black.teal
            listeningForKey = false
            conn:Disconnect()
        end
    end)
end)
    -- TP Delay slider row
    local tpDelayMin, tpDelayMax = 0.25, 1.0
    local tpDelayLabel = Instance.new("TextLabel", inner)
    tpDelayLabel.Size = UDim2.new(0, 148, 0, 24)
    tpDelayLabel.Position = UDim2.new(0, BR_PAD, 0, 142)
    tpDelayLabel.BackgroundTransparency = 1
    tpDelayLabel.Text = "TP Delay (ms):"
    tpDelayLabel.Font = Enum.Font.GothamBold
    tpDelayLabel.TextSize = 13
    tpDelayLabel.TextColor3 = Black.teal
    tpDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
    tpDelayLabel.TextYAlignment = Enum.TextYAlignment.Center

    local tpDelayValLabel = Instance.new("TextLabel", inner)
    tpDelayValLabel.Size = UDim2.new(0, 56, 0, 24)
    tpDelayValLabel.Position = UDim2.new(1, -(56 + BR_PAD), 0, 142)
    tpDelayValLabel.BackgroundTransparency = 1
    tpDelayValLabel.Font = Enum.Font.GothamBold
    tpDelayValLabel.TextSize = 13
    tpDelayValLabel.TextColor3 = Black.teal
    tpDelayValLabel.TextXAlignment = Enum.TextXAlignment.Right
    tpDelayValLabel.TextYAlignment = Enum.TextYAlignment.Center
    tpDelayValLabel.Text = string.format("%.2fms", BrainrotConfig.TpDelay or 0.624)

    -- Slider track
    local sliderTrack = Instance.new("Frame", inner)
    sliderTrack.Size = UDim2.new(1, -BR_PAD * 2, 0, 8)
    sliderTrack.Position = UDim2.new(0, BR_PAD, 0, 170)
    sliderTrack.BackgroundColor3 = Black.rowSel
    sliderTrack.BorderSizePixel = 0
    Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", sliderTrack).Color = Black.line

    local sliderFill = Instance.new("Frame", sliderTrack)
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Black.teal
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)

    local sliderKnob = Instance.new("Frame", sliderTrack)
    sliderKnob.Size = UDim2.new(0, 14, 0, 14)
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
    sliderKnob.BackgroundColor3 = Black.teal
    sliderKnob.BorderSizePixel = 0
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

    local function tpDelaySetValue(val)
        val = math.clamp(val, tpDelayMin, tpDelayMax)
        val = math.floor(val * 100 + 0.5) / 100  -- round to 2 decimal places
        BrainrotConfig.TpDelay = val
        tpDelayValLabel.Text = string.format("%.2fms", val)
        local t = (val - tpDelayMin) / (tpDelayMax - tpDelayMin)
        sliderFill.Size = UDim2.new(t, 0, 1, 0)
        sliderKnob.Position = UDim2.new(t, 0, 0.5, 0)
        BrainrotSaveConfig()
    end

    -- Set initial slider position
    tpDelaySetValue(BrainrotConfig.TpDelay or 0.624)

    local sliderDragging = false
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        sliderDragging = true
        local relX = input.Position.X - sliderTrack.AbsolutePosition.X
        local t = math.clamp(relX / sliderTrack.AbsoluteSize.X, 0, 1)
        tpDelaySetValue(tpDelayMin + t * (tpDelayMax - tpDelayMin))
    end)
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        sliderDragging = true
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not sliderDragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local relX = input.Position.X - sliderTrack.AbsolutePosition.X
        local t = math.clamp(relX / sliderTrack.AbsoluteSize.X, 0, 1)
        tpDelaySetValue(tpDelayMin + t * (tpDelayMax - tpDelayMin))
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)

    local dragHandle = Instance.new("TextButton", inner)
    dragHandle.Size = UDim2.new(1, 0, 0, 40)
    dragHandle.Position = UDim2.new(0, 0, 0, 0)
    dragHandle.BackgroundTransparency = 1
    dragHandle.Text = ""
    dragHandle.AutoButtonColor = false

    local dragging = false
    local dragStartPos, dragStartMouse

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = true
        dragStartMouse = input.Position
        dragStartPos = borderFrame.AbsolutePosition
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - dragStartMouse
        borderFrame.Position = UDim2.new(0, dragStartPos.X + delta.X, 0, dragStartPos.Y + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            local pos = borderFrame.AbsolutePosition
            BrainrotConfig.UIPosX = math.floor(pos.X)
            BrainrotConfig.UIPosY = math.floor(pos.Y)
            BrainrotSaveConfig()
        end
    end)

    priorityBtn.MouseButton1Click:Connect(BrainrotOpenPriorityEditor)

    task.spawn(function()
        local t = 0
        while borderGrad and borderGrad.Parent do
            t = (t + 0.5) % 360
            borderGrad.Rotation = t
            RunService.Heartbeat:Wait()
        end
    end)
end

getDelay = function() return 0.05 end
getOffset = function() return 0 end
getYLevel = function() return 36.6 end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.F then
            RunCarpetSequence()
        end
    end
end)

local targetIconPosition = UDim2.new(0.5, 0, 0.5, 0)

local function iconAtTarget(icon)
    local p = icon.Position
    return p.X.Scale == 0.5 and p.X.Offset == 0 and p.Y.Scale == 0.5 and p.Y.Offset == 0
end

local function iconReady(icon)
    if not icon.Visible then return false end
    if icon:IsA("GuiButton") and not icon.Active then return false end
    return iconAtTarget(icon)
end

task.spawn(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart", 5)

    local topbarStandard = PlayerGui:WaitForChild("TopbarStandard", 120)
    if not topbarStandard then return end
    local holders = topbarStandard:WaitForChild("Holders", 120)
    if not holders then return end

    local leftCenter = PlayerGui:WaitForChild("LeftCenter", 120)
    local inner = leftCenter:WaitForChild("LeftCenter", 120)
    local buttons = inner:WaitForChild("Buttons", 120)
    if not buttons then return end
    local indexFrame = buttons:WaitForChild("Index", 120)
    if not indexFrame then return end
    local icon = indexFrame:WaitForChild("Icon", 120)
    if not icon then return end

    local anyChanged = Instance.new("BindableEvent")
    icon:GetPropertyChangedSignal("Position"):Connect(function() anyChanged:Fire() end)
    icon:GetPropertyChangedSignal("Visible"):Connect(function() anyChanged:Fire() end)
    if icon:IsA("GuiButton") then
        icon:GetPropertyChangedSignal("Active"):Connect(function() anyChanged:Fire() end)
    end
    while icon.Parent and not iconReady(icon) do
        anyChanged.Event:Wait()
    end
    if not icon.Parent then return end

    task.wait(BrainrotConfig.TpDelay or 0.624)
    task.spawn(FlashWhite, 1.085)

    -- Try RunCarpetSequence immediately; if no brainrot found, keep retrying for up to 5s
    local deadline = tick() + 5
    repeat
        local pos1 = computeBrainrotCarpetPoints()
        if pos1 then
            RunCarpetSequence()
            break
        end
        task.wait(0.1)
    until tick() >= deadline
end)
