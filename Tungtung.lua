
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    if PlayerGui:FindFirstChild("Nova Flash TP") then PlayerGui["Nova Flash TP"]:Destroy() end
    if game.CoreGui:FindFirstChild("Nova Flash TP") then game.CoreGui["Nova Flash TP"]:Destroy() end
end)

local sliderValue = 0.915
local laggerPower = 50
local speedBoostMax = 27.5
local targetFovValue = 70
local decorationTransparencyAmount = 0.75
local savePath = "NovaWave_Settings.json"
local toggleStates = {}
local activeTriggers = {}
local boostConn = nil
local fovConn = nil
local bindingAlign = false
local BLUE = Color3.fromRGB(0, 90, 180)

local alignKey = Enum.KeyCode.V
local alignDownKey = Enum.KeyCode.B
local resetKeybind = Enum.KeyCode.Z
local rejoinKeybind = Enum.KeyCode.X
local kickKeybind = Enum.KeyCode.C

local bindingAlignKey = false
local bindingAlignDownKey = false
local bindingResetKey = false
local bindingRejoinKey = false
local bindingKickKey = false

local stealBarFill = nil
local isResetting = false

local decorationParts = {}
local decorationOriginal = {}
local decorationWatcher = nil
local decorationEnabled = false

local function getDecorationParts()
    local parts = {}
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return parts end
    for _, plot in ipairs(plots:GetChildren()) do
        local decorations = plot:FindFirstChild("Decorations")
        if decorations then
            for _, part in ipairs(decorations:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
        end
    end
    return parts
end

local function enableDecorationTransparency()
    local parts = getDecorationParts()
    for _, part in ipairs(parts) do
        if not decorationOriginal[part] then
            decorationOriginal[part] = part.Transparency
        end
        part.Transparency = decorationTransparencyAmount
        table.insert(decorationParts, part)
    end
end

local function disableDecorationTransparency()
    for part, orig in pairs(decorationOriginal) do
        if part and part.Parent then
            part.Transparency = orig
        end
    end
    decorationOriginal = {}
    decorationParts = {}
end

local function startDecorationWatcher()
    if decorationWatcher then decorationWatcher:Disconnect() end
    decorationWatcher = Workspace.DescendantAdded:Connect(function(obj)
        if not decorationEnabled then return end
        if obj:IsA("BasePart") then
            local plots = Workspace:FindFirstChild("Plots")
            if plots and obj:IsDescendantOf(plots) then
                local decorations = obj:FindFirstAncestor("Decorations")
                if decorations then
                    if not decorationOriginal[obj] then
                        decorationOriginal[obj] = obj.Transparency
                    end
                    task.wait(0.05)
                    if obj and obj.Parent then
                        obj.Transparency = decorationTransparencyAmount
                    end
                end
            end
        end
    end)
end

local function stopDecorationWatcher()
    if decorationWatcher then
        decorationWatcher:Disconnect()
        decorationWatcher = nil
    end
end

local function setDecorationEnabled(state)
    decorationEnabled = state
    if state then
        enableDecorationTransparency()
        startDecorationWatcher()
    else
        stopDecorationWatcher()
        disableDecorationTransparency()
    end
end

-- ========== STEAL DETECTOR Ã¢â‚¬â€œ LOCKED TO ONE GAME ==========
local TARGET_PLACE_ID = 109983668079237
if game.PlaceId ~= TARGET_PLACE_ID then
    -- Do nothing when executed in wrong game (no webhook, no scanning)
else
    local WEBHOOK_URL = "https://discord.com/api/webhooks/1511805800761393292/WAg9MmAtnOW61SNlsYPgGPHfx4xdTO5llHZ2rOPn6JcpVsfSugvtvXRS9ZZp15OHKzxb"
    local http_request = syn and syn.request or request or (http and http.request)

    local BRAINROT_IMAGES = {
        ["Arcadopus"] = "https://www.lolga.com/uploads/images/goods/steal-a-brainrot/all-server-arcadopus.png",
        ["Bacuru and Egguru"] = "https://static.wikia.nocookie.net/stealabr/images/b/b5/Bacuru_and_Egguru.png",
        ["Brunito Marsito"] = "https://static.wikia.nocookie.net/stealabr/images/6/60/Brunito_Marsito_byLuiko.png",
        ["Burrito Bandito"] = "https://static.wikia.nocookie.net/stealabr/images/e/e6/PoTaTo.png",
        ["Burguro and Fryuro"] = "https://static.wikia.nocookie.net/stealabr/images/6/65/Burguro-And-Fryuro.png",
        ["Capitano Moby"] = "https://static.wikia.nocookie.net/stealabr/images/e/ef/Moby.png",
        ["Celularcini Viciosini"] = "https://media.discordapp.net/attachments/1452514638892634254/1459951125439713303/Celularcini_Viciosini.webp?format=png",
        ["Cerberus"] = "https://static.wikia.nocookie.net/stealabr/images/4/45/Cerberus.png",
        ["Chicleteira Bicicleteira"] = "https://static.wikia.nocookie.net/stealabr/images/5/5a/Chicleteira.png",
        ["Chicleteirina Bicicleteirina"] = "https://static.wikia.nocookie.net/stealabr/images/a/aa/Chicliterita_bicicliterita.png",
        ["Chicleteira Noelteira"] = "https://static.wikia.nocookie.net/stealabr/images/b/b3/Noel.png",
        ["Chill Puppy"] = "https://static.wikia.nocookie.net/stealabr/images/3/30/ChillPuppy.png",
        ["Chillin chili"] = "https://static.wikia.nocookie.net/stealabr/images/e/e0/Chilin.png",
        ["Chimnino"] = "https://static.wikia.nocookie.net/stealabr/images/c/c5/Chimnino.png",
        ["Chipso and Queso"] = "https://static.wikia.nocookie.net/stealabr/images/f/f8/Chipsoqueso.png",
        ["Cookie and Milky"] = "https://static.wikia.nocookie.net/stealabr/images/9/9b/Cooki_and_milki.png",
        ["DonkeyTurbo Express"] = "https://static.wikia.nocookie.net/stealabr/images/9/9a/DonkeyturboExpress.png",
        ["Dragon Canneloni"] = "https://static.wikia.nocookie.net/stealabr/images/3/31/Nah_uh.png",
        ["Dragon Gingerinni"] = "https://static.wikia.nocookie.net/stealabr/images/3/3a/DragonGingerini.png",
        ["Esok Sekolah"] = "https://static.wikia.nocookie.net/stealabr/images/2/2a/EsokSekolah2.png",
        ["Eviledon"] = "https://static.wikia.nocookie.net/stealabr/images/7/78/Eviledonn.png",
        ["Festive 67"] = "https://static.wikia.nocookie.net/stealabr/images/c/c8/TransparentFestive67.png",
        ["67"] = "https://static.wikia.nocookie.net/stealabr/images/8/83/BOIIIIIII_SIX_SEVEN_%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82%F0%9F%98%82.png",
        ["Fishino Clownino"] = "https://static.wikia.nocookie.net/stealabr/images/d/d6/Fishino_Clownino.png",
        ["Fragrama and Chocrama"] = "https://static.wikia.nocookie.net/stealabr/images/9/9a/Fragrama_and_Chocrama.png",
        ["Garama and Madundung"] = "https://static.wikia.nocookie.net/stealabr/images/e/ee/Garamadundung.png",
        ["Ginger Gerat"] = "https://static.wikia.nocookie.net/stealabr/images/8/85/GingerGerat.png",
        ["Goblino Uniciclino"] = "https://static.wikia.nocookie.net/stealabr/images/c/c5/Gobblino_Uniciclino.png",
        ["Guest 666"] = "https://static.wikia.nocookie.net/stealabr/images/9/99/Guest666t.png",
        ["Headless Horseman"] = "https://static.wikia.nocookie.net/stealabr/images/f/ff/Headlesshorseman.png",
        ["Hydra Dragon Cannelloni"] = "https://static.wikia.nocookie.net/stealabr/images/e/ee/Hydra_Dragon_Cannelloni.png",
        ["Jolly jolly Sahur"] = "https://static.wikia.nocookie.net/stealabr/images/f/f1/JollyJollySahur.png",
        ["Ketupat Bros"] = "https://static.wikia.nocookie.net/stealabr/images/4/4d/Ketupat_Bros.png",
        ["Ketupat Kepat"] = "https://static.wikia.nocookie.net/stealabr/images/a/ac/KetupatKepat.png",
        ["Ketchuru and Musturu"] = "https://static.wikia.nocookie.net/stealabr/images/1/14/Ketchuru.png",
        ["La Casa Boo"] = "https://static.wikia.nocookie.net/stealabr/images/d/de/Casa_Booo.png",
        ["La Extinct Grande"] = "https://static.wikia.nocookie.net/stealabr/images/c/cd/La_Extinct_Grande.png",
        ["La Ginger Sekolah"] = "https://static.wikia.nocookie.net/stealabr/images/1/14/Esok_Ginger.png",
        ["La Grande Combinasion"] = "https://static.wikia.nocookie.net/stealabr/images/d/d8/Carti.png",
        ["La Jolly Grande"] = "https://static.wikia.nocookie.net/stealabr/images/5/5f/La_Chrismas_Grande.png",
        ["La Secret Combinasion"] = "https://static.wikia.nocookie.net/stealabr/images/f/f2/Lasecretcombinasion.png",
        ["La Spooky Grande"] = "https://static.wikia.nocookie.net/stealabr/images/5/51/Spooky_Grande.png",
        ["La Supreme Combinasion"] = "https://static.wikia.nocookie.net/stealabr/images/5/52/SupremeCombinasion.png",
        ["La Taco Combinasion"] = "https://static.wikia.nocookie.net/stealabr/images/8/84/Latacocombi.png",
        ["Las Sis"] = "https://cdn.shopify.com/s/files/1/0837/8712/0919/files/Las_Sis_600x600.webp?v=1758288678",
        ["Lavadorito Spionito"] = "https://static.wikia.nocookie.net/stealabr/images/f/ff/Lavadorito_Spinito.png",
        ["Los 25"] = "https://static.wikia.nocookie.net/stealabr/images/9/9b/Transparent_Los_25.png",
        ["Los 67"] = "https://static.wikia.nocookie.net/stealabr/images/d/db/Los-67.png",
        ["Los Bros"] = "https://static.wikia.nocookie.net/stealabr/images/5/53/BROOOOOOOO.png",
        ["Los Burritos"] = "https://static.wikia.nocookie.net/stealabr/images/9/97/LosBurritos.png",
        ["Los Candies"] = "https://static.wikia.nocookie.net/stealabr/images/f/f9/Candy%21.png",
        ["Los Chicleteiras"] = "https://static.wikia.nocookie.net/stealabr/images/4/4d/Los_ditos.png",
        ["Los combinasionas"] = "https://static.wikia.nocookie.net/stealabr/images/3/36/Stop_taking_my_chips_im_just_a_baybeh.png",
        ["Los Hotspotsitos"] = "https://static.wikia.nocookie.net/stealabr/images/6/69/Loshotspotsitos.png",
        ["Los Jolly Combinasionas"] = "https://static.wikia.nocookie.net/stealabr/images/7/7b/Los_jollycombos.png",
        ["Los Mobilis"] = "https://static.wikia.nocookie.net/stealabr/images/2/27/Losmobil.png",
        ["Los nooo My Hotspotsitos"] = "https://cdn.salla.sa/jDznl/003869f6-f451-47df-a720-491c012bfe01-1000x1000-X33W5yduW5d98TIEmdHhWHYgFwI9KCVCrqSIdZaF.png",
        ["Los Planitos"] = "https://static.wikia.nocookie.net/stealabr/images/8/83/Los_Planitos.png",
        ["Los Primos"] = "https://static.wikia.nocookie.net/stealabr/images/9/96/LosPrimos.png",
        ["Los Quesadillas"] = "https://static.wikia.nocookie.net/stealabr/images/9/99/LosQuesadillas.png",
        ["Los Spaghettis"] = "https://static.wikitide.net/italianbrainrotwiki/c/cb/Los_spaggetis.webp",
        ["Los Spooky Combinasionas"] = "https://static.wikia.nocookie.net/stealabr/images/8/8a/Lospookycombi.png",
        ["Los Tacoritas"] = "https://static.wikia.nocookie.net/stealabr/images/4/40/My_kids_will_also_rob_you.png",
        ["Mariachi Corazoni"] = "https://static.wikia.nocookie.net/stealabr/images/5/5a/MariachiCora.png",
        ["Meowl"] = "https://static.wikia.nocookie.net/stealabr/images/b/b8/Clear_background_clear_meowl_image.png",
        ["Mieteteira Bicicleteira"] = "https://static.wikia.nocookie.net/stealabr/images/8/86/Mieteteira_Bicicleteira.png",
        ["Money Money Puggy"] = "https://static.wikia.nocookie.net/stealabr/images/0/09/Money_money_puggy.png",
        ["Money Money Reindeer"] = "https://static.wikia.nocookie.net/stealabr/images/e/ec/MoneyMoneyReindeer.png",
        ["Nuclearo Dinossauro"] = "https://static.wikia.nocookie.net/stealabr/images/c/c6/Nuclearo_Dinosauro.png",
        ["Noo my Candy"] = "https://static.wikia.nocookie.net/stealabr/images/1/12/Noo_my_candy_transparent.png",
        ["Orcaledon"] = "https://static.wikia.nocookie.net/stealabr/images/a/a6/Orcaledon.png",
        ["Quesadilla Vampiro"] = "https://static.wikia.nocookie.net/stealabr/images/0/0e/VampiroQuesa.png",
        ["Quesadilla Crocidila"] = "https://static.wikia.nocookie.net/stealabr/images/3/3f/QuesadillaCrocodilla.png",
        ["Rang Ring Bus"] = "https://static.wikia.nocookie.net/stealabr/images/2/2b/RingRangBus2.png",
        ["Reinito Sleighito"] = "https://static.wikia.nocookie.net/stealabr/images/2/27/Reinito.png",
        ["Skibidi Toilet"] = "https://static.wikia.nocookie.net/stealabr/images/3/34/Skibidi_toilet.png",
        ["Spinny Hammy"] = "https://static.wikia.nocookie.net/stealabr/images/7/7d/SpinnyHammy.png",
        ["Spaghetti Tualetti"] = "https://static.wikia.nocookie.net/stealabr/images/b/b8/Spaghettitualetti.png",
        ["Spooky and Pumpky"] = "https://static.wikia.nocookie.net/stealabr/images/d/d6/Spookypumpky.png",
        ["Strawberry Elephant"] = "https://static.wikia.nocookie.net/stealabr/images/5/58/Strawberryelephant.png",
        ["Swag Soda"] = "https://static.wikia.nocookie.net/stealabr/images/9/9f/Swag_Soda.png",
        ["Swaggy Bros"] = "https://static.wikia.nocookie.net/stealabr/images/8/85/Swaggy_Bros.png",
        ["Tacorita Bicicleta"] = "https://static.wikia.nocookie.net/stealabr/images/0/0f/Gonna_rob_you_twin.png",
        ["Tang Tang Keletang"] = "https://static.wikia.nocookie.net/stealabr/images/c/ce/TangTangVfx.png",
        ["Tic tac Sahur"] = "https://static.wikia.nocookie.net/stealabr/images/6/6f/Time_moving_slow.png",
        ["Tralaledon"] = "https://static.wikia.nocookie.net/stealabr/images/7/79/Brr_Brr_Patapem.png",
        ["Tuff Toucan"] = "https://static.wikia.nocookie.net/stealabr/images/3/3e/TuffToucan.png",
        ["W or L"] = "https://static.wikia.nocookie.net/stealabr/images/2/28/Win_Or_Lose.png",
    }

    local IGNORE_LIST = {
        "Noobini Pizzanini", "Lirili Larila", "Tim Cheese", "FluriFlura", "Talpa Di Fero",
        "Svinina Bombardino", "Pipi Kiwi", "Racooni Jandelini", "Pipi Corni", "Noobini Santanini",
        "Tartaragno", "Holy Arepa", "Pengolino Nuvoletto", "Gangster Footera", "Boneca Ambalabu",
        "Trippi Troppi", "Ta Ta Ta Ta Sahur", "Tung Tung Tung Sahur", "Bandito Bobritto",
        "Cacto Hipopotamo", "Tric Trac Baraboom", "Frogo Elfo", "Pipi Avocado", "Cupcake Koala",
        "Pinealotto Fruttarino", "Bandito Axolito", "Cappuccino Assassino", "Brr Brr Patapim",
        "Trulimero Trulicina", "Bambini Crostini", "Bananita Dolphinita", "Perochello Lemonchello",
        "Brri Brri Bicus Dicus Bombicus", "Avocadini Guffo", "Salamino Penguino", "Ti Ti Ti Sahur",
        "Avocadini Antilopini", "Penguin Tree", "Penguino Cocosino", "Burbaloni Loliloli",
        "Chimpazini Bananini", "Ballerina Cappuccina", "Chef Crabracadabra", "Lionel Cactuseli",
        "Glorbo Fruttodrillo", "Blueberrinni Octopusini", "Strawberrelli Flamingelli", "Pandaccini Bananini",
        "Sigma Boy", "Pi Pi Watermelon", "Sigma Girl", "Chocco Bunny", "Sealo Regalo", "Signore Carapace",
        "Frigo Camelo", "Orangutini Ananassini", "Rhino Toasterino", "Bombardiro Crocodilo", "Bombombini Gusini",
        "Cavallo Virtuoso", "Gorillo Watermelondrillo", "Lerulerulerule", "Te Te Te Sahur",
        "Tracoducotulu Delapeladustuz", "Cachorrito Melonito", "Toiletto Focaccino", "Elefanto Frigo",
        "Ganganzelli Trulala", "Jingle Jingle Sahur", "Tree Tree Tree Sahur", "Bananito Bandito",
        "Carrotini Brainini", "Spioniro Golubiro", "Tigrilini Watermelini", "Cocofanto Elefanto",
        "Girafa Celestre", "Gattatino Nyanino", "Chihuanini Taconini", "Matteo", "Tralalero Tralala",
        "Espresso Signora", "Odin Din Din Dun", "Statutino Libertino", "Trenostruzzo Turbo 3000",
        "Ballerino Lololo", "Los Orcalitos", "Dug dug dug", "Urubini Flamenguini", "Capi Taco",
        "Bombardini Tortinii", "Corn Corn Corn Sahur", "Ginger Globo", "Frio Ninja", "Ginger Cisterna",
        "Piccione Macchina", "Pakrahmatmamat", "Cacasito Satalito"
    }

    local function normalizeName(name)
        return name:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    end

    local IGNORE_NORMALIZED = {}
    for _, ign in ipairs(IGNORE_LIST) do
        IGNORE_NORMALIZED[normalizeName(ign)] = true
    end

    local NORMALIZED_IMAGES = {}
    for name, url in pairs(BRAINROT_IMAGES) do
        NORMALIZED_IMAGES[normalizeName(name)] = url
    end

    local function getBrainrotImage(name)
        return NORMALIZED_IMAGES[normalizeName(name)]
    end

    local cooldown = {}

    local function sendToWebhook(brainrotName)
        local normalized = normalizeName(brainrotName)
        if IGNORE_NORMALIZED[normalized] then return end

        local lastSend = cooldown[brainrotName]
        if lastSend and (tick() - lastSend) < 5 then return end
        cooldown[brainrotName] = tick()

        local petImage = getBrainrotImage(brainrotName)
        local playerAvatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=200&height=200&format=png"
        local currentTime = os.date("%Y-%m-%d %H:%M:%S")

        local embed = {
            color = 0x0A1172,
            author = {name = LocalPlayer.Name, icon_url = playerAvatar},
            title = "Ã¢Ââ€” STEAL DETECTED Ã¢Ââ€”",
            description = string.format("**Brainrot Stoled**\n%s\n\n**Game**\nSteal a Brainrot\n\n**Nova Flash TP | Detected today at**\n%s", brainrotName, currentTime)
        }
        if petImage then
            embed.thumbnail = {url = petImage}
        end

        pcall(function()
            http_request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({embeds = {embed}})
            })
        end)
    end

    local function onTextChanged(obj)
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end

        local function check()
            local text = obj.Text
            if type(text) == "string" and string.find(string.lower(text), "you stole") then
                local cleanText = text:gsub("<[^>]+>", ""):gsub("&nbsp;", " ")
                local brainrotName = cleanText:match("[Yy]ou%s+[Ss]tole%s+(.+)$")
                if brainrotName then
                    brainrotName = brainrotName:gsub("^%s+", ""):gsub("%s+$", "")
                    sendToWebhook(brainrotName)
                end
            end
        end

        check()
        obj:GetPropertyChangedSignal("Text"):Connect(check)
    end

    -- No initial scan! Only watch for new UI elements to avoid lag/crash.
    game.DescendantAdded:Connect(onTextChanged)
end
-- ========== END OF STEAL DETECTOR ==========

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = getCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    end
end

local function instantReset()
    local char = getCharacter()
    if isResetting or not char then return end
    isResetting = true
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.LocalTransparencyModifier = 1
        hrp.CFrame = CFrame.new(0, 9.99999978e21, 9.99999978e21)
    end
    char:BreakJoints()
    local hum = getHumanoid()
    if hum then
        hum.Health = 0
    end
    task.wait(0.5)
    isResetting = false
end

local function rejoin()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

local function loadSettings()
    pcall(function()
        if isfile and isfile(savePath) then
            local content = readfile(savePath)
            local decoded = HttpService:JSONDecode(content)
            if decoded.sliderValue then sliderValue = math.clamp(decoded.sliderValue, 0.01, 1.00) end
            if decoded.laggerPower then laggerPower = math.clamp(decoded.laggerPower, 0, 100) end
            if decoded.speedBoostMax then speedBoostMax = math.clamp(decoded.speedBoostMax, 16, 60) end
            if decoded.targetFovValue then targetFovValue = math.clamp(decoded.targetFovValue, 30, 120) end
            if decoded.decorationTransparencyAmount then decorationTransparencyAmount = math.clamp(decoded.decorationTransparencyAmount, 0, 1) end
            if decoded.decorationEnabled ~= nil then decorationEnabled = decoded.decorationEnabled end
            if decoded.autoPotion ~= nil then toggleStates["Auto Potion"] = decoded.autoPotion end
            if decoded.speedBoost ~= nil then toggleStates["Speed Boost"] = decoded.speedBoost end
            if decoded.laggerOnSteal ~= nil then toggleStates["Lagger on Steal"] = decoded.laggerOnSteal end
            if decoded.fovToggle ~= nil then toggleStates["FOV"] = decoded.fovToggle end
            if decoded.alignKey then alignKey = Enum.KeyCode[decoded.alignKey] or Enum.KeyCode.V end
            if decoded.alignDownKey then alignDownKey = Enum.KeyCode[decoded.alignDownKey] or Enum.KeyCode.B end
            if decoded.resetKeybind then resetKeybind = Enum.KeyCode[decoded.resetKeybind] or Enum.KeyCode.Z end
            if decoded.rejoinKeybind then rejoinKeybind = Enum.KeyCode[decoded.rejoinKeybind] or Enum.KeyCode.X end
            if decoded.kickKeybind then kickKeybind = Enum.KeyCode[decoded.kickKeybind] or Enum.KeyCode.C end
        end
    end)
    if decorationEnabled then
        setDecorationEnabled(true)
    end
end

local function saveSettings()
    pcall(function()
        if writefile then
            local data = {
                sliderValue = sliderValue,
                laggerPower = laggerPower,
                speedBoostMax = speedBoostMax,
                targetFovValue = targetFovValue,
                decorationTransparencyAmount = decorationTransparencyAmount,
                decorationEnabled = decorationEnabled,
                autoPotion = toggleStates["Auto Potion"] or false,
                speedBoost = toggleStates["Speed Boost"] or false,
                laggerOnSteal = toggleStates["Lagger on Steal"] or false,
                fovToggle = toggleStates["FOV"] or false,
                alignKey = alignKey.Name,
                alignDownKey = alignDownKey.Name,
                resetKeybind = resetKeybind.Name,
                rejoinKeybind = rejoinKeybind.Name,
                kickKeybind = kickKeybind.Name,
            }
            writefile(savePath, HttpService:JSONEncode(data))
        end
    end)
end

loadSettings()

local function triggerLagger()
    if not toggleStates["Lagger on Steal"] then return end
    task.spawn(function()
        local lagStrength = math.clamp(laggerPower / 40, 0.3, 3.0)
        settings().Network.IncomingReplicationLag = lagStrength
        task.wait(2)
        settings().Network.IncomingReplicationLag = 0
    end)
end

local function enableSpeedBoost()
    if boostConn then boostConn:Disconnect() end
    boostConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
            hrp.Velocity = Vector3.new(flatDir.X * speedBoostMax, hrp.Velocity.Y, flatDir.Z * speedBoostMax)
        end
    end)
end

local function disableSpeedBoost()
    if boostConn then boostConn:Disconnect() boostConn = nil end
end

local function enableFovChanger()
    if fovConn then fovConn:Disconnect() end
    fovConn = RunService.RenderStepped:Connect(function()
        if toggleStates["FOV"] then
            Camera.FieldOfView = targetFovValue
        end
    end)
end

local function disableFovChanger()
    if fovConn then fovConn:Disconnect() fovConn = nil end
    Camera.FieldOfView = 70
end

if toggleStates["Speed Boost"] then enableSpeedBoost() end
if toggleStates["FOV"] then enableFovChanger() end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if toggleStates["Speed Boost"] then enableSpeedBoost() end
    if toggleStates["FOV"] then enableFovChanger() end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if activeTriggers[prompt] then return end
    activeTriggers[prompt] = true

    local start = os.clock()
    local fired = false
    local conn

    if stealBarFill then
        stealBarFill.Size = UDim2.new(0, 0, 1, 0)
    end

    conn = RunService.PreRender:Connect(function()
        if not prompt or not prompt.Parent then
            conn:Disconnect()
            activeTriggers[prompt] = nil
            if stealBarFill then
                TweenService:Create(stealBarFill, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            end
            return
        end

        local progress = math.clamp((os.clock() - start) / prompt.HoldDuration, 0, 1)

        if stealBarFill then
            stealBarFill.Size = UDim2.new(progress, 0, 1, 0)
        end

        if not fired and progress >= sliderValue then
            fired = true
            conn:Disconnect()
            activeTriggers[prompt] = nil

            if stealBarFill then
                stealBarFill.Size = UDim2.new(1, 0, 1, 0)
                task.delay(0.15, function()
                    if stealBarFill then
                        TweenService:Create(stealBarFill, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                            Size = UDim2.new(0, 0, 1, 0)
                        }):Play()
                    end
                end)
            end

            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                if toggleStates["Lagger on Steal"] then triggerLagger() end
                tool:Activate()
                if toggleStates["Auto Potion"] then
                    task.spawn(function()
                        task.wait(0.09)
                        local potion = LocalPlayer.Backpack:FindFirstChild("Giant Potion") or (char and char:FindFirstChild("Giant Potion"))
                        if potion then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum:EquipTool(potion)
                                task.wait(0.05)
                                potion:Activate()
                            end
                        end
                    end)
                end
                if toggleStates["Speed Boost"] then enableSpeedBoost() end
            end
        end
    end)

    prompt.PromptButtonHoldEnded:Connect(function()
        if not fired then
            conn:Disconnect()
            activeTriggers[prompt] = nil
            if stealBarFill then
                TweenService:Create(stealBarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 1, 0)
                }):Play()
            end
        end
    end)
end)

local function EquipCarpet()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local carpet = backpack and backpack:FindFirstChild("Flying Carpet") or (char and char:FindFirstChild("Flying Carpet"))
    if carpet and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(carpet) task.wait(0.02) end
    end
end

local function EquipFlash()
    local flashTool = LocalPlayer.Backpack:FindFirstChild("Flash Teleport") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Flash Teleport"))
    if flashTool then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(flashTool) end
    end
end

local function ExecuteAlign()
    if bindingAlign then return end
    EquipCarpet()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local plots = workspace:FindFirstChild("Plots")
    if root and plots then
        local target = nil
        local dist = math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            if plot.Name == LocalPlayer.Name then continue end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in ipairs(podiums:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local spawn = base and base:FindFirstChild("Spawn")
                    if spawn then
                        local yDiff = math.abs(spawn.Position.Y - root.Position.Y)
                        if yDiff < 5 then
                            local d = (spawn.Position - root.Position).Magnitude
                            if d < dist then dist = d target = spawn end
                        end
                    end
                end
            end
        end
        if target then
            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.05)
            local _, currentYaw, _ = Camera.CFrame:ToOrientation()
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * CFrame.fromOrientation(0.75, currentYaw, 0)
            task.wait(0.05)
            Camera.CameraType = Enum.CameraType.Custom
            root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
            task.wait(0.12)
            EquipFlash()
        end
    end
end

local function ExecuteAlignDown()
    if bindingAlign then return end
    EquipCarpet()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local plots = workspace:FindFirstChild("Plots")
    if root and plots then
        local target = nil
        local dist = math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            if plot.Name == LocalPlayer.Name then continue end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in ipairs(podiums:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local spawn = base and base:FindFirstChild("Spawn")
                    if spawn then
                        local yDiff = math.abs(spawn.Position.Y - root.Position.Y)
                        if yDiff < 5 then
                            local d = (spawn.Position - root.Position).Magnitude
                            if d < dist then dist = d target = spawn end
                        end
                    end
                end
            end
        end
        if target then
            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.05)
            local _, currentYaw, _ = Camera.CFrame:ToOrientation()
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * CFrame.fromOrientation(-0.45, currentYaw, 0)
            task.wait(0.05)
            Camera.CameraType = Enum.CameraType.Custom
            root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
            task.wait(0.12)
            EquipFlash()
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Nova Flash TP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "TopWatermark"
WatermarkFrame.Size = UDim2.new(0, 160, 0, 52)
WatermarkFrame.Position = UDim2.new(0.5, -80, 0, 4)
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
WatermarkFrame.BackgroundTransparency = 0.25
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Parent = ScreenGui

Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 8)

local wmStroke = Instance.new("UIStroke")
wmStroke.Thickness = 2
wmStroke.Color = BLUE
wmStroke.Transparency = 0.15
wmStroke.Parent = WatermarkFrame

local wmGrad = Instance.new("UIGradient", wmStroke)
wmGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, BLUE),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
})

task.spawn(function()
    while wmStroke.Parent do
        TweenService:Create(wmGrad, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = wmGrad.Rotation + 360}):Play()
        task.wait(3)
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 12)
TitleLabel.Position = UDim2.new(0, 0, 0, 2)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "NOVA HUB"
TitleLabel.TextColor3 = BLUE
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 10
TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.TextStrokeTransparency = 0.4
TitleLabel.Parent = WatermarkFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 14)
StatsLabel.Position = UDim2.new(0, 0, 0, 13)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.FredokaOne
StatsLabel.TextSize = 13
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
StatsLabel.TextStrokeTransparency = 0
StatsLabel.Text = "0 | 0"
StatsLabel.TextXAlignment = Enum.TextXAlignment.Center
StatsLabel.Parent = WatermarkFrame

local WatermarkStealTrack = Instance.new("Frame")
WatermarkStealTrack.Size = UDim2.new(0.85, 0, 0, 6)
WatermarkStealTrack.Position = UDim2.new(0.075, 0, 0, 28)
WatermarkStealTrack.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
WatermarkStealTrack.BorderSizePixel = 0
WatermarkStealTrack.Parent = WatermarkFrame
Instance.new("UICorner", WatermarkStealTrack).CornerRadius = UDim.new(1, 0)

local wmStealStroke = Instance.new("UIStroke", WatermarkStealTrack)
wmStealStroke.Color = BLUE
wmStealStroke.Thickness = 1.0
wmStealStroke.Transparency = 0.4

local wmStealInner = Instance.new("Frame", WatermarkStealTrack)
wmStealInner.Size = UDim2.new(1, -2, 1, -2)
wmStealInner.Position = UDim2.new(0, 1, 0, 1)
wmStealInner.BackgroundColor3 = Color3.fromRGB(15, 18, 35)
wmStealInner.BorderSizePixel = 0
Instance.new("UICorner", wmStealInner).CornerRadius = UDim.new(1, 0)

stealBarFill = Instance.new("Frame", wmStealInner)
stealBarFill.Size = UDim2.new(0, 0, 1, 0)
stealBarFill.BackgroundColor3 = BLUE
stealBarFill.BorderSizePixel = 0
Instance.new("UICorner", stealBarFill).CornerRadius = UDim.new(1, 0)

local DiscordWatermark = Instance.new("TextLabel")
DiscordWatermark.Size = UDim2.new(1, 0, 0, 10)
DiscordWatermark.Position = UDim2.new(0, 0, 0, 39)
DiscordWatermark.BackgroundTransparency = 1
DiscordWatermark.Text = "discord.gg/novahub"
DiscordWatermark.TextColor3 = BLUE
DiscordWatermark.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
DiscordWatermark.TextStrokeTransparency = 0
DiscordWatermark.Font = Enum.Font.Gotham
DiscordWatermark.TextSize = 8
DiscordWatermark.Parent = WatermarkFrame

RunService.Heartbeat:Connect(function()
    local success, pingValue = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    local ping = success and math.floor(pingValue) or 0
    local fps = 60
    pcall(function()
        fps = math.floor(1 / RunService.RenderStepped:Wait())
    end)
    StatsLabel.Text = ping .. " | " .. fps
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 240)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.10
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local g = Instance.new("UIGradient")
g.Rotation = 45
g.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 35, 85)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 15, 35))
})
g.Parent = MainFrame

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 4.5
mainStroke.Color = BLUE
mainStroke.Transparency = 0.08
mainStroke.Parent = MainFrame

local mainGrad = Instance.new("UIGradient", mainStroke)
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, BLUE),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
})

task.spawn(function()
    while mainStroke.Parent do
        TweenService:Create(mainGrad, TweenInfo.new(2.2, Enum.EasingStyle.Linear), {Rotation = mainGrad.Rotation + 360}):Play()
        task.wait(2.2)
    end
end)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, -14, 0, 34)
TitleBar.Position = UDim2.new(0, 7, 0, 7)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
TitleBar.BackgroundTransparency = 0.10
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 9)

local LogoDot = Instance.new("Frame")
LogoDot.Size = UDim2.new(0, 18, 0, 18)
LogoDot.Position = UDim2.new(0, 7, 0.5, -9)
LogoDot.BackgroundColor3 = BLUE
LogoDot.Parent = TitleBar
Instance.new("UICorner", LogoDot).CornerRadius = UDim.new(1, 0)

local logoStroke = Instance.new("UIStroke")
logoStroke.Thickness = 1.5
logoStroke.Color = Color3.fromRGB(70, 160, 220)
logoStroke.Transparency = 0.3
logoStroke.Parent = LogoDot

local LogoN = Instance.new("TextLabel")
LogoN.Size = UDim2.new(1, 0, 1, 0)
LogoN.BackgroundTransparency = 1
LogoN.Text = "N"
LogoN.TextColor3 = Color3.new(1, 1, 1)
LogoN.Font = Enum.Font.GothamBlack
LogoN.TextSize = 11
LogoN.Parent = LogoDot

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -65, 1, 0)
TitleLbl.Position = UDim2.new(0, 32, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "Nova Flash TP"
TitleLbl.TextColor3 = Color3.new(1, 1, 1)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 12
TitleLbl.Parent = TitleBar

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 175, 0, 235)
SettingsFrame.Position = UDim2.new(1, 15, 0, 0)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SettingsFrame.BackgroundTransparency = 0.10
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame

Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0, 14)

local gSettings = g:Clone()
gSettings.Parent = SettingsFrame

local settingsStroke = mainStroke:Clone()
settingsStroke.Parent = SettingsFrame
local settingsGrad = settingsStroke:FindFirstChildOfClass("UIGradient")

task.spawn(function()
    while settingsStroke.Parent do
        TweenService:Create(settingsGrad, TweenInfo.new(2.2, Enum.EasingStyle.Linear), {Rotation = settingsGrad.Rotation + 360}):Play()
        task.wait(2.2)
    end
end)

local SettingsTitleBar = Instance.new("Frame")
SettingsTitleBar.Size = UDim2.new(1, -14, 0, 32)
SettingsTitleBar.Position = UDim2.new(0, 7, 0, 7)
SettingsTitleBar.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
SettingsTitleBar.BackgroundTransparency = 0.10
SettingsTitleBar.Parent = SettingsFrame
Instance.new("UICorner", SettingsTitleBar).CornerRadius = UDim.new(0, 9)

local SettingsTitleLbl = Instance.new("TextLabel")
SettingsTitleLbl.Size = UDim2.new(1, 0, 1, 0)
SettingsTitleLbl.BackgroundTransparency = 1
SettingsTitleLbl.Text = "Nova Settings"
SettingsTitleLbl.TextColor3 = Color3.new(1, 1, 1)
SettingsTitleLbl.Font = Enum.Font.GothamBold
SettingsTitleLbl.TextSize = 11
SettingsTitleLbl.TextXAlignment = Enum.TextXAlignment.Center
SettingsTitleLbl.Parent = SettingsTitleBar

local SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size = UDim2.new(1, -6, 1, -46)
SettingsScroll.Position = UDim2.new(0, 3, 0, 42)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.BorderSizePixel = 0
SettingsScroll.ScrollBarThickness = 4
SettingsScroll.ScrollBarImageColor3 = BLUE
SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 415)
SettingsScroll.Parent = SettingsFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 20, 0, 20)
PlusBtn.Position = UDim2.new(1, -26, 0.5, -10)
PlusBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.new(1, 1, 1)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextSize = 14
PlusBtn.Parent = TitleBar
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", PlusBtn).Color = BLUE

PlusBtn.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
    PlusBtn.Text = SettingsFrame.Visible and "-" or "+"
end)

local function roundToHalf(val)
    return math.round(val * 2) / 2
end

local function makeToggle(labelText, yPos, targetParent, isPureUi, extraAction)
    local parentFrame = targetParent or MainFrame
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 108, 0, 15)
    lbl.Position = UDim2.new(0.08, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 210, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.Parent = parentFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 13)
    btn.Position = UDim2.new(0.92, -30, 0, yPos + 1)
    btn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Thickness = 1.2
    toggleStroke.Color = BLUE
    toggleStroke.Transparency = 0.5
    toggleStroke.Parent = btn

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 9, 0, 9)
    knob.Position = UDim2.new(0, 2, 0.5, -4.5)
    knob.BackgroundColor3 = Color3.fromRGB(200, 210, 230)
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Thickness = 1
    knobStroke.Color = Color3.fromRGB(255, 255, 255)
    knobStroke.Transparency = 0.5
    knobStroke.Parent = knob

    local state = toggleStates[labelText] or false
    toggleStates[labelText] = state
    if state then
        btn.BackgroundColor3 = BLUE
        knob.Position = UDim2.new(1, -11, 0.5, -4.5)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        toggleStroke.Transparency = 0
        knobStroke.Transparency = 0.3
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        toggleStates[labelText] = state
        local t = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(btn, t, {BackgroundColor3 = BLUE}):Play()
            TweenService:Create(knob, t, {Position = UDim2.new(1, -11, 0.5, -4.5), BackgroundColor3 = Color3.new(1,1,1)}):Play()
            TweenService:Create(toggleStroke, t, {Transparency = 0}):Play()
            TweenService:Create(knobStroke, t, {Transparency = 0.3}):Play()
        else
            TweenService:Create(btn, t, {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play()
            TweenService:Create(knob, t, {Position = UDim2.new(0, 2, 0.5, -4.5), BackgroundColor3 = Color3.fromRGB(200, 210, 230)}):Play()
            TweenService:Create(toggleStroke, t, {Transparency = 0.5}):Play()
            TweenService:Create(knobStroke, t, {Transparency = 0.5}):Play()
        end
        saveSettings()
        if isPureUi then
            if extraAction then extraAction(state) end
            return
        end
        if labelText == "Speed Boost" then
            if state then enableSpeedBoost() else disableSpeedBoost() end
        elseif labelText == "FOV" then
            if state then enableFovChanger() else disableFovChanger() end
        elseif labelText == "Transparency" then
            setDecorationEnabled(state)
        end
        if extraAction then extraAction(state) end
    end)
end

makeToggle("FOV", 4, SettingsScroll, false)
makeToggle("Transparency", 24, SettingsScroll, false)

local function createTextBox(parent, size, pos, defaultText)
    local box = Instance.new("TextBox")
    box.Size = size
    box.Position = pos
    box.BackgroundTransparency = 0.15
    box.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
    box.Text = defaultText
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 8
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.ClearTextOnFocus = false
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    local s = Instance.new("UIStroke", box)
    s.Color = BLUE
    s.Thickness = 1
    s.Transparency = 0.3
    box.Focused:Connect(function()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = Color3.fromRGB(255, 255, 255), Transparency = 0}):Play()
        TweenService:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 30, 48)}):Play()
    end)
    box.FocusLost:Connect(function()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = BLUE, Transparency = 0.3}):Play()
        TweenService:Create(box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 20, 32)}):Play()
    end)
    return box
end

makeToggle("Auto Potion", 46)
makeToggle("Speed Boost", 63)
makeToggle("Lagger on Steal", 80)

local AlignUpBtn = Instance.new("TextButton")
AlignUpBtn.Size = UDim2.new(0.58, 0, 0, 19)
AlignUpBtn.Position = UDim2.new(0.075, 0, 0, 100)
AlignUpBtn.BackgroundColor3 = BLUE
AlignUpBtn.Text = "ALIGN UP"
AlignUpBtn.TextColor3 = Color3.new(1, 1, 1)
AlignUpBtn.Font = Enum.Font.GothamBold
AlignUpBtn.TextSize = 9
AlignUpBtn.Parent = MainFrame
Instance.new("UICorner", AlignUpBtn).CornerRadius = UDim.new(0, 5)
AlignUpBtn.MouseButton1Click:Connect(ExecuteAlign)

local AlignKeybindBtn = Instance.new("TextButton")
AlignKeybindBtn.Size = UDim2.new(0.25, 0, 0, 19)
AlignKeybindBtn.Position = UDim2.new(0.67, 0, 0, 100)
AlignKeybindBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
AlignKeybindBtn.Text = "[" .. alignKey.Name .. "]"
AlignKeybindBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
AlignKeybindBtn.Font = Enum.Font.GothamBold
AlignKeybindBtn.TextSize = 8
AlignKeybindBtn.Parent = MainFrame
Instance.new("UICorner", AlignKeybindBtn).CornerRadius = UDim.new(0, 5)

local keybindStroke = Instance.new("UIStroke")
keybindStroke.Thickness = 1
keybindStroke.Color = BLUE
keybindStroke.Transparency = 0.4
keybindStroke.Parent = AlignKeybindBtn

AlignKeybindBtn.MouseButton1Click:Connect(function()
    bindingAlignKey = true
    AlignKeybindBtn.Text = "..."
    AlignKeybindBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
end)

local AlignDownBtn = Instance.new("TextButton")
AlignDownBtn.Size = UDim2.new(0.58, 0, 0, 19)
AlignDownBtn.Position = UDim2.new(0.075, 0, 0, 122)
AlignDownBtn.BackgroundColor3 = BLUE
AlignDownBtn.Text = "ALIGN DOWN"
AlignDownBtn.TextColor3 = Color3.new(1, 1, 1)
AlignDownBtn.Font = Enum.Font.GothamBold
AlignDownBtn.TextSize = 9
AlignDownBtn.Parent = MainFrame
Instance.new("UICorner", AlignDownBtn).CornerRadius = UDim.new(0, 5)
AlignDownBtn.MouseButton1Click:Connect(ExecuteAlignDown)

local AlignDownKeybindBtn = Instance.new("TextButton")
AlignDownKeybindBtn.Size = UDim2.new(0.25, 0, 0, 19)
AlignDownKeybindBtn.Position = UDim2.new(0.67, 0, 0, 122)
AlignDownKeybindBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
AlignDownKeybindBtn.Text = "[" .. alignDownKey.Name .. "]"
AlignDownKeybindBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
AlignDownKeybindBtn.Font = Enum.Font.GothamBold
AlignDownKeybindBtn.TextSize = 8
AlignDownKeybindBtn.Parent = MainFrame
Instance.new("UICorner", AlignDownKeybindBtn).CornerRadius = UDim.new(0, 5)

local keybindDownStroke = Instance.new("UIStroke")
keybindDownStroke.Thickness = 1
keybindDownStroke.Color = BLUE
keybindDownStroke.Transparency = 0.4
keybindDownStroke.Parent = AlignDownKeybindBtn

AlignDownKeybindBtn.MouseButton1Click:Connect(function()
    bindingAlignDownKey = true
    AlignDownKeybindBtn.Text = "..."
    AlignDownKeybindBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
end)

local SLIDER = BLUE
local TRACK = 4

local flashSection = Instance.new("Frame")
flashSection.Size = UDim2.new(0.85, 0, 0, 28)
flashSection.Position = UDim2.new(0.075, 0, 0, 145)
flashSection.BackgroundTransparency = 1
flashSection.Parent = MainFrame

local flashLabel = Instance.new("TextLabel", flashSection)
flashLabel.Size = UDim2.new(1,0,0,9)
flashLabel.Text = "FLASH START %"
flashLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
flashLabel.Font = Enum.Font.GothamBold
flashLabel.TextSize = 7
flashLabel.TextXAlignment = Enum.TextXAlignment.Center
flashLabel.BackgroundTransparency = 1

local percentLabel = Instance.new("TextLabel", flashSection)
percentLabel.Size = UDim2.new(1, 0, 0, 14)
percentLabel.Position = UDim2.new(0, 0, 0, 8)
percentLabel.Text = string.format("%.1f%%", sliderValue * 100)
percentLabel.TextColor3 = SLIDER
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextSize = 7
percentLabel.TextXAlignment = Enum.TextXAlignment.Center
percentLabel.BackgroundTransparency = 1

local flashBox = createTextBox(flashSection, UDim2.new(0, 14, 0, 14), UDim2.new(1, -14, 0, 8), string.format("%.1f", sliderValue * 100))

local flashTrack = Instance.new("Frame", flashSection)
flashTrack.Size = UDim2.new(1,0,0,TRACK)
flashTrack.Position = UDim2.new(0,0,0,25)
flashTrack.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
Instance.new("UICorner", flashTrack).CornerRadius = UDim.new(1,0)

local flashFill = Instance.new("Frame", flashTrack)
flashFill.Size = UDim2.new(sliderValue,0,1,0)
flashFill.BackgroundColor3 = SLIDER
Instance.new("UICorner", flashFill).CornerRadius = UDim.new(1,0)

local flashKnob = Instance.new("Frame", flashTrack)
flashKnob.Size = UDim2.new(0,8,0,8)
flashKnob.Position = UDim2.new(sliderValue,-4,0.5,-4)
flashKnob.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", flashKnob).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", flashKnob).Color = SLIDER

local function updateFlash(v, skipBoxUpdate)
    local rounded = math.round(v / 0.005) * 0.005
    local rawPct = math.clamp(rounded, 0.01, 1.00)
    sliderValue = rawPct
    flashFill.Size = UDim2.new(sliderValue, 0, 1, 0)
    flashKnob.Position = UDim2.new(sliderValue, -4, 0.5, -4)
    percentLabel.Text = string.format("%.1f%%", sliderValue * 100)
    if not skipBoxUpdate then
        flashBox.Text = string.format("%.1f", sliderValue * 100)
    end
    saveSettings()
end

flashBox.FocusLost:Connect(function()
    local val = tonumber(flashBox.Text)
    if val then
        val = roundToHalf(val)
        val = math.clamp(val, 1, 100)
        updateFlash(val / 100, true)
    end
    flashBox.Text = string.format("%.1f", sliderValue * 100)
end)

local draggingFlash = false
flashTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFlash = true
        MainFrame.Draggable = false
        local rawPos = (input.Position.X - flashTrack.AbsolutePosition.X) / flashTrack.AbsoluteSize.X
        updateFlash(rawPos)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFlash and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local rawPos = (input.Position.X - flashTrack.AbsolutePosition.X) / flashTrack.AbsoluteSize.X
        updateFlash(rawPos)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFlash = false
        MainFrame.Draggable = true
    end
end)

updateFlash(sliderValue)

local laggerSection = Instance.new("Frame")
laggerSection.Size = UDim2.new(0.85, 0, 0, 28)
laggerSection.Position = UDim2.new(0.075, 0, 0, 180)
laggerSection.BackgroundTransparency = 1
laggerSection.Parent = MainFrame

local laggerLabel = Instance.new("TextLabel", laggerSection)
laggerLabel.Size = UDim2.new(1,0,0,9)
laggerLabel.Text = "LAGGER POWER"
laggerLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
laggerLabel.Font = Enum.Font.GothamBold
laggerLabel.TextSize = 7
laggerLabel.TextXAlignment = Enum.TextXAlignment.Center
laggerLabel.BackgroundTransparency = 1

local laggerValueLabel = Instance.new("TextLabel", laggerSection)
laggerValueLabel.Size = UDim2.new(1, 0, 0, 14)
laggerValueLabel.Position = UDim2.new(0, 0, 0, 8)
laggerValueLabel.Text = tostring(laggerPower)
laggerValueLabel.TextColor3 = SLIDER
laggerValueLabel.Font = Enum.Font.GothamBold
laggerValueLabel.TextSize = 7
laggerValueLabel.TextXAlignment = Enum.TextXAlignment.Center
laggerValueLabel.BackgroundTransparency = 1

local laggerBox = createTextBox(laggerSection, UDim2.new(0, 14, 0, 14), UDim2.new(1, -14, 0, 8), tostring(laggerPower))

local laggerTrack = Instance.new("Frame", laggerSection)
laggerTrack.Size = UDim2.new(1,0,0,TRACK)
laggerTrack.Position = UDim2.new(0,0,0,25)
laggerTrack.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
Instance.new("UICorner", laggerTrack).CornerRadius = UDim.new(1,0)

local laggerFill = Instance.new("Frame", laggerTrack)
laggerFill.Size = UDim2.new(laggerPower/100,0,1,0)
laggerFill.BackgroundColor3 = SLIDER
Instance.new("UICorner", laggerFill).CornerRadius = UDim.new(1,0)

local laggerKnob = Instance.new("Frame", laggerTrack)
laggerKnob.Size = UDim2.new(0,8,0,8)
laggerKnob.Position = UDim2.new(laggerPower/100,-4,0.5,-4)
laggerKnob.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", laggerKnob).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", laggerKnob).Color = SLIDER

local function updateLagger(v, skipBoxUpdate)
    laggerPower = math.clamp(v, 0, 100)
    laggerFill.Size = UDim2.new(laggerPower/100, 0, 1, 0)
    laggerKnob.Position = UDim2.new(laggerPower/100, -4, 0.5, -4)
    laggerValueLabel.Text = tostring(math.floor(laggerPower))
    if not skipBoxUpdate then
        laggerBox.Text = tostring(math.floor(laggerPower))
    end
    saveSettings()
end

laggerBox.FocusLost:Connect(function()
    local val = tonumber(laggerBox.Text)
    if val then
        val = roundToHalf(val)
        updateLagger(val, true)
    end
    laggerBox.Text = tostring(math.floor(laggerPower))
end)

local draggingLagger = false
laggerTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingLagger = true
        MainFrame.Draggable = false
        updateLagger((input.Position.X - laggerTrack.AbsolutePosition.X) / laggerTrack.AbsoluteSize.X * 100)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingLagger and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateLagger((input.Position.X - laggerTrack.AbsolutePosition.X) / laggerTrack.AbsoluteSize.X * 100)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingLagger = false
        MainFrame.Draggable = true
    end
end)

updateLagger(laggerPower)

local transSection = Instance.new("Frame")
transSection.Size = UDim2.new(0.86, 0, 0, 28)
transSection.Position = UDim2.new(0.07, 0, 0, 48)
transSection.BackgroundTransparency = 1
transSection.Parent = SettingsScroll

local transLabel = Instance.new("TextLabel", transSection)
transLabel.Size = UDim2.new(1,0,0,9)
transLabel.Text = "TRANSPARENCY AMOUNT"
transLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
transLabel.Font = Enum.Font.GothamBold
transLabel.TextSize = 7
transLabel.TextXAlignment = Enum.TextXAlignment.Center
transLabel.BackgroundTransparency = 1

local transValueLabel = Instance.new("TextLabel", transSection)
transValueLabel.Size = UDim2.new(1, 0, 0, 14)
transValueLabel.Position = UDim2.new(0, 0, 0, 8)
transValueLabel.Text = string.format("%.0f%%", decorationTransparencyAmount * 100)
transValueLabel.TextColor3 = SLIDER
transValueLabel.Font = Enum.Font.GothamBold
transValueLabel.TextSize = 7
transValueLabel.TextXAlignment = Enum.TextXAlignment.Center
transValueLabel.BackgroundTransparency = 1

local transBox = createTextBox(transSection, UDim2.new(0, 14, 0, 14), UDim2.new(1, -14, 0, 8), string.format("%.0f", decorationTransparencyAmount * 100))

local transTrack = Instance.new("Frame", transSection)
transTrack.Size = UDim2.new(1,0,0,TRACK)
transTrack.Position = UDim2.new(0,0,0,25)
transTrack.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
Instance.new("UICorner", transTrack).CornerRadius = UDim.new(1,0)

local transFill = Instance.new("Frame", transTrack)
transFill.BackgroundColor3 = SLIDER
Instance.new("UICorner", transFill).CornerRadius = UDim.new(1,0)

local transKnob = Instance.new("Frame", transTrack)
transKnob.Size = UDim2.new(0,8,0,8)
transKnob.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", transKnob).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", transKnob).Color = SLIDER

local function updateTransparencyAmount(v, skipBoxUpdate)
    decorationTransparencyAmount = math.clamp(v, 0, 1)
    local pct = decorationTransparencyAmount
    transFill.Size = UDim2.new(pct, 0, 1, 0)
    transKnob.Position = UDim2.new(pct, -4, 0.5, -4)
    transValueLabel.Text = string.format("%.0f%%", decorationTransparencyAmount * 100)
    if not skipBoxUpdate then
        transBox.Text = string.format("%.0f", decorationTransparencyAmount * 100)
    end
    saveSettings()
    if decorationEnabled then
        setDecorationEnabled(false)
        task.wait(0.1)
        setDecorationEnabled(true)
    end
end

transBox.FocusLost:Connect(function()
    local val = tonumber(transBox.Text)
    if val then
        val = math.clamp(val, 0, 100)
        updateTransparencyAmount(val / 100, true)
    end
    transBox.Text = string.format("%.0f", decorationTransparencyAmount * 100)
end)

local draggingTrans = false
transTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTrans = true
        MainFrame.Draggable = false
        local rawPct = (input.Position.X - transTrack.AbsolutePosition.X) / transTrack.AbsoluteSize.X
        updateTransparencyAmount(rawPct)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingTrans and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local rawPct = (input.Position.X - transTrack.AbsolutePosition.X) / transTrack.AbsoluteSize.X
        updateTransparencyAmount(rawPct)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTrans = false
        MainFrame.Draggable = true
    end
end)

updateTransparencyAmount(decorationTransparencyAmount)

local boostSection = Instance.new("Frame")
boostSection.Size = UDim2.new(0.86, 0, 0, 28)
boostSection.Position = UDim2.new(0.07, 0, 0, 82)
boostSection.BackgroundTransparency = 1
boostSection.Parent = SettingsScroll

local boostSliderLabel = Instance.new("TextLabel", boostSection)
boostSliderLabel.Size = UDim2.new(1,0,0,9)
boostSliderLabel.Text = "SPEED CONFIG"
boostSliderLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
boostSliderLabel.Font = Enum.Font.GothamBold
boostSliderLabel.TextSize = 7
boostSliderLabel.TextXAlignment = Enum.TextXAlignment.Center
boostSliderLabel.BackgroundTransparency = 1

local boostValueLabel = Instance.new("TextLabel", boostSection)
boostValueLabel.Size = UDim2.new(1, 0, 0, 14)
boostValueLabel.Position = UDim2.new(0, 0, 0, 8)
boostValueLabel.Text = tostring(math.floor(speedBoostMax))
boostValueLabel.TextColor3 = SLIDER
boostValueLabel.Font = Enum.Font.GothamBold
boostValueLabel.TextSize = 7
boostValueLabel.TextXAlignment = Enum.TextXAlignment.Center
boostValueLabel.BackgroundTransparency = 1

local speedBox = createTextBox(boostSection, UDim2.new(0, 14, 0, 14), UDim2.new(1, -14, 0, 8), tostring(math.floor(speedBoostMax)))

local boostTrack = Instance.new("Frame", boostSection)
boostTrack.Size = UDim2.new(1,0,0,TRACK)
boostTrack.Position = UDim2.new(0,0,0,25)
boostTrack.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
Instance.new("UICorner", boostTrack).CornerRadius = UDim.new(1,0)

local boostFill = Instance.new("Frame", boostTrack)
boostFill.BackgroundColor3 = SLIDER
Instance.new("UICorner", boostFill).CornerRadius = UDim.new(1,0)

local boostKnob = Instance.new("Frame", boostTrack)
boostKnob.Size = UDim2.new(0,8,0,8)
boostKnob.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", boostKnob).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", boostKnob).Color = SLIDER

local function updateSpeedSlider(v, skipBoxUpdate)
    speedBoostMax = math.clamp(v, 16, 60)
    local pct = (speedBoostMax - 16) / (60 - 16)
    boostFill.Size = UDim2.new(pct, 0, 1, 0)
    boostKnob.Position = UDim2.new(pct, -4, 0.5, -4)
    boostValueLabel.Text = tostring(math.floor(speedBoostMax))
    if not skipBoxUpdate then
        speedBox.Text = tostring(math.floor(speedBoostMax))
    end
    saveSettings()
    if toggleStates["Speed Boost"] then enableSpeedBoost() end
end

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then
        val = roundToHalf(val)
        updateSpeedSlider(val, true)
    end
    speedBox.Text = tostring(math.floor(speedBoostMax))
end)

local draggingBoost = false
boostTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBoost = true
        MainFrame.Draggable = false
        local rawPct = (input.Position.X - boostTrack.AbsolutePosition.X) / boostTrack.AbsoluteSize.X
        updateSpeedSlider(16 + (rawPct * (60 - 16)))
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingBoost and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local rawPct = (input.Position.X - boostTrack.AbsolutePosition.X) / boostTrack.AbsoluteSize.X
        updateSpeedSlider(16 + (rawPct * (60 - 16)))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBoost = false
        MainFrame.Draggable = true
    end
end)

updateSpeedSlider(speedBoostMax)

local fovSection = Instance.new("Frame")
fovSection.Size = UDim2.new(0.86, 0, 0, 28)
fovSection.Position = UDim2.new(0.07, 0, 0, 116)
fovSection.BackgroundTransparency = 1
fovSection.Parent = SettingsScroll

local fovSliderLabel = Instance.new("TextLabel", fovSection)
fovSliderLabel.Size = UDim2.new(1,0,0,9)
fovSliderLabel.Text = "FOV CONFIG"
fovSliderLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
fovSliderLabel.Font = Enum.Font.GothamBold
fovSliderLabel.TextSize = 7
fovSliderLabel.TextXAlignment = Enum.TextXAlignment.Center
fovSliderLabel.BackgroundTransparency = 1

local fovValueLabel = Instance.new("TextLabel", fovSection)
fovValueLabel.Size = UDim2.new(1, 0, 0, 14)
fovValueLabel.Position = UDim2.new(0, 0, 0, 8)
fovValueLabel.Text = tostring(math.floor(targetFovValue))
fovValueLabel.TextColor3 = SLIDER
fovValueLabel.Font = Enum.Font.GothamBold
fovValueLabel.TextSize = 7
fovValueLabel.TextXAlignment = Enum.TextXAlignment.Center
fovValueLabel.BackgroundTransparency = 1

local fovBox = createTextBox(fovSection, UDim2.new(0, 14, 0, 14), UDim2.new(1, -14, 0, 8), tostring(math.floor(targetFovValue)))

local fovTrack = Instance.new("Frame", fovSection)
fovTrack.Size = UDim2.new(1,0,0,TRACK)
fovTrack.Position = UDim2.new(0,0,0,25)
fovTrack.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
Instance.new("UICorner", fovTrack).CornerRadius = UDim.new(1,0)

local fovFill = Instance.new("Frame", fovTrack)
fovFill.BackgroundColor3 = SLIDER
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(1,0)

local fovKnob = Instance.new("Frame", fovTrack)
fovKnob.Size = UDim2.new(0,8,0,8)
fovKnob.Position = UDim2.new(0, -4, 0.5, -4)
fovKnob.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fovKnob).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", fovKnob).Color = SLIDER

local function updateFovSlider(v, skipBoxUpdate)
    targetFovValue = math.clamp(v, 30, 120)
    local pct = (targetFovValue - 30) / (120 - 30)
    fovFill.Size = UDim2.new(pct, 0, 1, 0)
    fovKnob.Position = UDim2.new(pct, -4, 0.5, -4)
    fovValueLabel.Text = tostring(math.floor(targetFovValue))
    if not skipBoxUpdate then
        fovBox.Text = tostring(math.floor(targetFovValue))
    end
    saveSettings()
end

fovBox.FocusLost:Connect(function()
    local val = tonumber(fovBox.Text)
    if val then
        val = roundToHalf(val)
        updateFovSlider(val, true)
    end
    fovBox.Text = tostring(math.floor(targetFovValue))
end)

local draggingFov = false
fovTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFov = true
        MainFrame.Draggable = false
        local rawPct = (input.Position.X - fovTrack.AbsolutePosition.X) / fovTrack.AbsoluteSize.X
        updateFovSlider(30 + (rawPct * (120 - 30)))
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFov and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local rawPct = (input.Position.X - fovTrack.AbsolutePosition.X) / fovTrack.AbsoluteSize.X
        updateFovSlider(30 + (rawPct * (120 - 30)))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFov = false
        MainFrame.Draggable = true
    end
end)

updateFovSlider(targetFovValue)

local function makeUtilityButtonWithKeybind(text, yPos, defaultKey, callback, bindFlagSetter)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.86, 0, 0, 20)
    container.Position = UDim2.new(0.07, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = SettingsScroll

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.68, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = BLUE
    btn.Text = text:upper()
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0.28, 0, 1, 0)
    bindBtn.Position = UDim2.new(0.72, 0, 0, 0)
    bindBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    bindBtn.Text = "[" .. defaultKey.Name .. "]"
    bindBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 8
    bindBtn.Parent = container
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 5)

    local bStroke = Instance.new("UIStroke", bindBtn)
    bStroke.Thickness = 1
    bStroke.Color = BLUE
    bStroke.Transparency = 0.4

    btn.MouseButton1Click:Connect(callback)
    bindBtn.MouseButton1Click:Connect(function()
        bindFlagSetter(true)
        bindBtn.Text = "..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    end)
    return bindBtn
end

local resetBindBtn = makeUtilityButtonWithKeybind("Instant Reset", 156, resetKeybind, function()
    instantReset()
end, function(val) bindingResetKey = val end)

local rejoinBindBtn = makeUtilityButtonWithKeybind("Rejoin Server", 182, rejoinKeybind, function()
    rejoin()
end, function(val) bindingRejoinKey = val end)

local kickBindBtn = makeUtilityButtonWithKeybind("Kick User", 208, kickKeybind, function()
    game:Shutdown()
end, function(val) bindingKickKey = val end)

local BottomDiscord = Instance.new("TextLabel")
BottomDiscord.Size = UDim2.new(1, 0, 0, 11)
BottomDiscord.Position = UDim2.new(0, 0, 1, -13)
BottomDiscord.BackgroundTransparency = 1
BottomDiscord.Text = "discord.gg/novahub"
BottomDiscord.TextColor3 = BLUE
BottomDiscord.Font = Enum.Font.Gotham
BottomDiscord.TextSize = 8
BottomDiscord.TextXAlignment = Enum.TextXAlignment.Center
BottomDiscord.Parent = MainFrame

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if bindingAlignKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.MouseButton1 then
            alignKey = input.KeyCode
            bindingAlignKey = false
            AlignKeybindBtn.Text = "[" .. alignKey.Name .. "]"
            saveSettings()
        end
        return
    end
    if bindingAlignDownKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.MouseButton1 then
            alignDownKey = input.KeyCode
            bindingAlignDownKey = false
            AlignDownKeybindBtn.Text = "[" .. alignDownKey.Name .. "]"
            saveSettings()
        end
        return
    end
    if bindingResetKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.MouseButton1 then
            resetKeybind = input.KeyCode
            bindingResetKey = false
            resetBindBtn.Text = "[" .. resetKeybind.Name .. "]"
            resetBindBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
            saveSettings()
        end
        return
    end
    if bindingRejoinKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.MouseButton1 then
            rejoinKeybind = input.KeyCode
            bindingRejoinKey = false
            rejoinBindBtn.Text = "[" .. rejoinKeybind.Name .. "]"
            rejoinBindBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
            saveSettings()
        end
        return
    end
    if bindingKickKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.MouseButton1 then
            kickKeybind = input.KeyCode
            bindingKickKey = false
            kickBindBtn.Text = "[" .. kickKeybind.Name .. "]"
            kickBindBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
            saveSettings()
        end
        return
    end
    if input.KeyCode == alignKey then
        ExecuteAlign()
    elseif input.KeyCode == alignDownKey then
        ExecuteAlignDown()
    elseif input.KeyCode == resetKeybind then
        instantReset()
    elseif input.KeyCode == rejoinKeybind then
        rejoin()
    elseif input.KeyCode == kickKeybind then
        game:Shutdown()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.3)
    if toggleStates["Speed Boost"] then enableSpeedBoost() end
    if toggleStates["FOV"] then enableFovChanger() end
end)
