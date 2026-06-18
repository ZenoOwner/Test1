-- DеoЬfuѕсatеd bу LеаκD | discord.gg/qteAQmfJmP

local Env = getfenv();
local C = {};
local v1 = {...};
local r1 = true;
local r2 = string.gmatch;
local function r3(...)
    error("Tamper Detected!");
    return; 
end;
local r4 = false;
local v2 = pcall(function(...)
    r4 = true;
    return; 
end);
local v3 = v2;
if v2 then
    v3 = r4;
end;
local v4 = 1;
local r5 = math.random;
local v5 = table.concat;
local function v6(...)
    while true do
        l1 = l2;
        l2 = l1;
        r3(); 
    end;
    return; 
end;
local v7 = v5;
local r6 = table and table.unpack or unpack;
local r7 = r5(3, 65);
local v8 = {
    pcall(function(...)
        return "hWkYGOvbZko1f" / (6977279 - "R2El" ^ 12462327); 
    end)
};
local v9 = v8[2];
local r8 = tonumber(r2(tostring(v9), ":(%d*):")());
for r = 1, r7 do
    r9 = r;
    r10 = math.random(1, 100);
    r11 = r5(0, 255);
    r12 = r5(1, r10);
    r13 = r5(1, 2) == 1;
    r14 = v9.gsub(v9, ":(%d*):", ":" .. tostring(r5(0, 10000)) .. ":");
    e = {
        pcall(function(...)
            if r5(1, 2) == 1 or r9 == r7 then
                r1 = r1 and r8 == tonumber(r2(tostring(({
                    pcall(function(...)
                        return "Zwq" / (11506763 - "BGKlQLP" ^ 9108916); 
                    end)
                })[2]), ":(%d*):")());
            end;
            if r13 then
                error(r14, 0);
            end;
            v1 = {};
            for D = 1, r10 do
                v1[D] = r5(0, 255); 
            end;
            v1[r12] = r11;
            return r6(v1); 
        end)
    };
    if r13 then
        r1 = r1 and (pcall(function(...)
            if r5(1, 2) == 1 or r9 == r7 then
                r1 = r1 and r8 == tonumber(r2(tostring(({
                    pcall(function(...)
                        return "Zwq" / (11506763 - "BGKlQLP" ^ 9108916); 
                    end)
                })[2]), ":(%d*):")());
            end;
            if r13 then
                error(r14, 0);
            end;
            v1 = {};
            for D = 1, r10 do
                v1[D] = r5(0, 255); 
            end;
            v1[r12] = r11;
            return r6(v1); 
        end) == false and e[2] == r14);
    end; 
end;
r1 = r1 and 0 == 0;
if r1 then
    v8 = {};
    r17 = math.floor;
    r18 = 0;
    r19 = 2;
    r20 = {};
    A = 0;
    for k = 1, 256 do
        v8[k] = k; 
    end;
    v9 = #v8 == 0;
    k = table.remove(v8, math.random(1, #v8));
    r20[k] = string.char(k - 1);
    if #v8 == 0 then
        r21 = {};
        r23 = {};
        r15 = setmetatable({}, {
            ["__index"] = r23,
            ["__metatable"] = nil
        });
        o = game;
        D = not o.IsLoaded(o);
        if D then
            D = game.Loaded;
            D.Wait(D);
        end;
        D = game;
        r24 = D.GetService(D, "Players");
        while not r24.LocalPlayer do
            task.wait(.1); 
        end;
        r25 = r24.LocalPlayer;
        o = r25;
        v2 = o.WaitForChild(o, "PlayerGui", 15);
        if not v2 then
            warn("\xe2\x9d\x8c PlayerGui failed to load in time.");
            return;
        end;
        o = game;
        r26 = o.GetService(o, "TweenService");
        v6 = game;
        T = v6.GetService(v6, "UserInputService");
        v6 = game;
        r27 = v6.GetService(v6, "HttpService");
        J = game;
        r28 = J.GetService(J, "TeleportService");
        r29 = "saved_key.txt";
        local function r30(arg1_2, ...)
            v1 = arg1_2;
            return v1.match(v1, "^%s*(.-)%s*$"); 
        end;
        local function r31(arg1_3, ...)
            r32 = arg1_3;
            if writefile then
                pcall(function(...)
                    local m = {
                        m[1],
                        31
                    };
                    writefile(C[m[1]], r32);
                    return; 
                end);
            end;
            return; 
        end;
        local function r33(arg1_4, arg2_4, ...)
            r34 = arg1_4;
            r35 = arg2_4;
            pcall(function(...)
                local m = {
                    m[1],
                    m[2],
                    86,
                    87
                };
                v7 = game.StarterGui;
                v7.SetCore(v7, "SendNotification", {
                    ["Title"] = r34,
                    ["Text"] = r35,
                    ["Duration"] = 5
                });
                return; 
            end);
            return; 
        end;
        v7 = v7;
        v7 = v7;
        v7 = v7;
        v7 = v7;
        r36 = http and http.request or (syn and syn.request or request);
        if not r36 then
            warn("\xe2\x9d\x8c Exploit does not support HTTP requests.");
            return;
        end;
        local function r37(arg1_5, ...)
            v7 = game;
            v3 = v7.GetService(v7, "RbxAnalyticsService");
            B = r27;
            v2 = r27;
            r38 = "https://key.js20042830.workers.dev/?key=" .. B.UrlEncode(B, arg1_5) .. "&hwid=" .. v2.UrlEncode(v2, v3.GetClientId(v3));
            v4 = {
                pcall(function(...)
                    return r36({
                        ["Url"] = r38,
                        ["Method"] = "GET"
                    }); 
                end)
            };
            B = v4[2];
            v4 = not pcall(function(...)
                return r36({
                    ["Url"] = r38,
                    ["Method"] = "GET"
                }); 
            end);
            v3 = v4;
            if v4 then
            end; 
        end;
        local function r39(arg1_6, ...)
            P = game.PlaceId;
            D = game.JobId;
            o = "```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(" .. tostring(P) .. ", '" .. tostring(D) .. "', game.Players.LocalPlayer)\n```AA";
            N = game;
            V = N.GetService(N, "RbxAnalyticsService");
            r40 = {
                ["embeds"] = {
                    {
                        ["title"] = "\xf0\x9f\x94\x90 Key Used",
                        ["color"] = 65280,
                        ["fields"] = {
                            {
                                ["name"] = "\xf0\x9f\x91\xa4 User",
                                ["value"] = r25.Name,
                                ["inline"] = true
                            },
                            {
                                ["name"] = "\xf0\x9f\x94\x91 Key",
                                ["value"] = "`" .. arg1_6 .. "`",
                                ["inline"] = true
                            },
                            {
                                ["name"] = "\xf0\x9f\x96\xa5\xef\xb8\x8f HWID",
                                ["value"] = "`" .. V.GetClientId(V) .. "`",
                                ["inline"] = false
                            },
                            {
                                ["name"] = "\xf0\x9f\x8e\xae Game",
                                ["value"] = "[Click to View Game](" .. ("https://www.roblox.com/games/" .. tostring(P)) .. ")\n**Place ID:** `" .. tostring(P) .. "`",
                                ["inline"] = true
                            },
                            {
                                ["name"] = "\xf0\x9f\x8c\x90 Job ID",
                                ["value"] = "`" .. tostring(D) .. "`",
                                ["inline"] = true
                            },
                            {
                                ["name"] = "\xf0\x9f\x9a\x80 Server Invite (Run to join)",
                                ["value"] = o,
                                ["inline"] = false
                            }
                        },
                        ["footer"] = {
                            ["text"] = "GentleHub Logger"
                        }
                    }
                }
            };
            r41 = {
                ["Content-Type"] = "application/json"
            };
            r42 = "https://discord.com/api/webhooks/1516752841480339537/dnrlf8NC0-BDUm_VQmzhW21iY8mHWU3EyY7_8pw2rz0AVghD_TxhHF3Bc2cVpGjm6GSa";
            pcall(function(...)
                T = r27;
                r36({
                    ["Url"] = r42,
                    ["Method"] = "POST",
                    ["Headers"] = r41,
                    ["Body"] = T.JSONEncode(T, r40)
                });
                return; 
            end);
            return; 
        end;
        local function r43(...)
            P = isfile;
            v3 = P;
            if P then
                v3 = isfile(r29);
            end;
            v7 = v7;
            if not v3 then
                warn("No saved key found.");
                return;
            end;
            v7 = not r37(r30(readfile(r29)));
            if v7 then
                warn("Invalid saved key.");
                return;
            end;
            v7 = v7;
            P = syn and syn.queue_on_teleport or (queue_on_teleport or fluxus);
            if P then
                P("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/TunaScripts/Azren/refs/heads/main/Games\"))()");
            end;
            D = r24;
            v7 = #D.GetPlayers(D) <= 1;
            if v7 then
                v7 = r28;
                v7.Teleport(v7, game.PlaceId, r25);
            else
                v7 = r28;
                v7.TeleportToPlaceInstance(v7, game.PlaceId, game.JobId, r25);
            end;
            return; 
        end;
        N = v2.FindFirstChild(v2, "TunaPremium");
        if N then
            N.Destroy(N);
        end;
        r44 = Instance.new("ScreenGui");
        r44.Name = "TunaPremium";
        r44.Parent = v2;
        r44.ResetOnSpawn = false;
        r44.DisplayOrder = 999999;
        r45 = Instance.new("Frame");
        r45.Parent = r44;
        r45.Size = UDim2.new(0, 520, 0, 320);
        r45.Position = UDim2.new(0.5, -260, 0.5, -160);
        r45.BackgroundColor3 = Color3.fromRGB(8, 8, 12);
        r45.BorderSizePixel = 0;
        Instance.new("UICorner", r45).CornerRadius = UDim.new(0, 12);
        r46 = false;
        n = r45.InputBegan;
        n.Connect(n, function(arg1_7, ...)
            v1 = arg1_7;
            if v1.UserInputType == Enum.UserInputType.MouseButton1 then
                r46 = true;
                r47 = v1.Position;
                r48 = r45.Position;
            end;
            return; 
        end);
        n = T.InputEnded;
        n.Connect(n, function(arg1_8, ...)
            if arg1_8.UserInputType == Enum.UserInputType.MouseButton1 then
                r46 = false;
            end;
            return; 
        end);
        n = T.InputChanged;
        n.Connect(n, function(arg1_9, ...)
            v1 = arg1_9;
            if r46 and v1.UserInputType == Enum.UserInputType.MouseMovement then
                P = v1.Position - r47;
                r45.Position = UDim2.new(r48.X.Scale, r48.X.Offset + P.X, r48.Y.Scale, r48.Y.Offset + P.Y);
            end;
            return; 
        end);
        Y = Instance.new("Frame");
        Y.Parent = r45;
        Y.Size = UDim2.new(0, 150, 1, 0);
        Y.BackgroundColor3 = Color3.fromRGB(14, 14, 20);
        Y.BorderSizePixel = 0;
        Instance.new("UICorner", Y).CornerRadius = UDim.new(0, 12);
        pP = Instance.new("TextLabel");
        pP.Parent = Y;
        pP.Size = UDim2.new(1, 0, 0, 100);
        pP.Position = UDim2.new(0, 0, .1, 0);
        pP.BackgroundTransparency = 1;
        pP.Text = "TUNA\nSCRIPTS";
        pP.Font = Enum.Font.GothamBlack;
        pP.TextSize = 28;
        pP.TextColor3 = Color3.fromRGB(255, 255, 255);
        WP = Instance.new("TextLabel");
        WP.Parent = Y;
        WP.Size = UDim2.new(1, 0, 0, 30);
        WP.Position = UDim2.new(0, 0, .48, 0);
        WP.BackgroundTransparency = 1;
        WP.Text = "ENTERPRISE";
        WP.Font = Enum.Font.GothamMedium;
        WP.TextSize = 16;
        WP.TextColor3 = Color3.fromRGB(180, 180, 180);
        r49 = Instance.new("Frame");
        r49.Parent = Y;
        r49.Size = UDim2.new(0, 8, 0, 8);
        r49.Position = UDim2.new(.18, 0, .7, 0);
        r49.BackgroundColor3 = Color3.fromRGB(0, 255, 120);
        r49.BorderSizePixel = 0;
        Instance.new("UICorner", r49).CornerRadius = UDim.new(1, 0);
        tP = Instance.new("TextLabel");
        tP.Parent = Y;
        tP.Size = UDim2.new(0, 80, 0, 20);
        tP.Position = UDim2.new(.28, 0, .68, 0);
        tP.BackgroundTransparency = 1;
        tP.Text = "ONLINE";
        tP.Font = Enum.Font.Gotham;
        tP.TextSize = 14;
        tP.TextColor3 = Color3.fromRGB(200, 200, 200);
        r50 = Instance.new("TextButton");
        r50.Parent = Y;
        r50.Size = UDim2.new(0, 120, 0, 32);
        r50.Position = UDim2.new(.1, 0, .82, 0);
        r50.BackgroundColor3 = Color3.fromRGB(28, 28, 40);
        r50.Text = "REJOIN SERVER";
        r50.TextColor3 = Color3.fromRGB(200, 200, 255);
        r50.Font = Enum.Font.GothamBold;
        r50.TextSize = 11;
        r50.BorderSizePixel = 0;
        Instance.new("UICorner", r50).CornerRadius = UDim.new(0, 6);
        wP = Instance.new("Frame");
        wP.Parent = r45;
        wP.Position = UDim2.new(0, 150, 0, 0);
        wP.Size = UDim2.new(1, -150, 1, 0);
        wP.BackgroundTransparency = 1;
        qP = Instance.new("TextLabel");
        qP.Parent = wP;
        qP.Size = UDim2.new(1, 0, 0, 40);
        qP.Position = UDim2.new(0, 0, .08, 0);
        qP.BackgroundTransparency = 1;
        qP.Text = "LICENSE AUTHENTICATION";
        qP.Font = Enum.Font.GothamBold;
        qP.TextSize = 22;
        qP.TextColor3 = Color3.fromRGB(255, 255, 255);
        cP = Instance.new("TextLabel");
        cP.Parent = wP;
        cP.Size = UDim2.new(1, 0, 0, 20);
        cP.Position = UDim2.new(0, 0, .18, 0);
        cP.BackgroundTransparency = 1;
        cP.Text = "Secure session verification";
        cP.Font = Enum.Font.Gotham;
        cP.TextSize = 14;
        cP.TextColor3 = Color3.fromRGB(150, 150, 150);
        r51 = Instance.new("TextBox");
        r51.Parent = wP;
        r51.Size = UDim2.new(0.75, 0, 0, 42);
        r51.Position = UDim2.new(.12, 0, .32, 0);
        r51.BackgroundColor3 = Color3.fromRGB(22, 22, 30);
        r51.PlaceholderText = "Enter license key...";
        r51.Text = "";
        r51.TextColor3 = Color3.new(1, 1, 1);
        r51.Font = Enum.Font.Gotham;
        r51.TextSize = 14;
        r51.BorderSizePixel = 0;
        Instance.new("UICorner", r51).CornerRadius = UDim.new(0, 8);
        r52 = Instance.new("TextButton");
        r52.Parent = wP;
        r52.Size = UDim2.new(0.75, 0, 0, 42);
        r52.Position = UDim2.new(.12, 0, .52, 0);
        r52.BackgroundColor3 = Color3.fromRGB(88, 101, 242);
        r52.Text = "VERIFY ACCESS";
        r52.TextColor3 = Color3.new(1, 1, 1);
        r52.Font = Enum.Font.GothamBold;
        r52.TextSize = 14;
        r52.BorderSizePixel = 0;
        Instance.new("UICorner", r52).CornerRadius = UDim.new(0, 8);
        r53 = Instance.new("TextButton");
        r53.Parent = wP;
        r53.Size = UDim2.new(0.75, 0, 0, 20);
        r53.Position = UDim2.new(.12, 0, .7, 0);
        r53.BackgroundTransparency = 1;
        r53.Text = "CLICK TO COPY KEY LINK";
        r53.TextColor3 = Color3.fromRGB(130, 140, 230);
        r53.Font = Enum.Font.GothamBold;
        r53.TextSize = 12;
        r54 = Instance.new("TextLabel");
        r54.Parent = wP;
        r54.Size = UDim2.new(1, 0, 0, 20);
        r54.Position = UDim2.new(0, 0, .82, 0);
        r54.BackgroundTransparency = 1;
        r54.Text = "STATUS: WAITING CONNECTION";
        r54.Font = Enum.Font.Code;
        r54.TextSize = 14;
        r54.TextColor3 = Color3.fromRGB(150, 150, 150);
        task.spawn(function(...)
            while true do
                v7 = r26;
                v3 = v7.Create(v7, r49, TweenInfo.new(.6), {
                    ["BackgroundTransparency"] = .7
                });
                v3.Play(v3);
                task.wait(.6);
                v7 = r26;
                v3 = v7.Create(v7, r49, TweenInfo.new(.6), {
                    ["BackgroundTransparency"] = 0
                });
                v3.Play(v3);
                task.wait(.6); 
            end;
            return; 
        end);
        BP = isfile;
        PP = BP;
        if BP then
            PP = isfile(r29);
        end;
        v7 = v7;
        if PP then
            DP = readfile(r29);
            if DP then
                PP = DP ~= "";
            end;
            v7 = DP;
            if DP then
                yP = readfile(C[O]);
                r51.Text = yP;
            end;
        end;
        PP = r53.MouseButton1Click;
        PP.Connect(PP, function(...)
            if setclipboard then
                setclipboard("https://link-target.net/1305307/gentle-key");
                r53.Text = "COPIED TO CLIPBOARD";
                r33("Copied!", "Linkvertise link copied to clipboard.");
            else
                r53.Text = "CLIPBOARD NOT SUPPORTED";
                r33("Copy Failed", "Clipboard interaction is not supported by your executor.");
            end;
            task.wait(1.5);
            r53.Text = "CLICK TO COPY KEY LINK";
            return; 
        end);
        PP = r50.MouseButton1Click;
        PP.Connect(PP, function(...)
            r50.Text = "REJOINING...";
            r43();
            return; 
        end);
        PP = r52.MouseButton1Click;
        PP.Connect(PP, function(...)
            v1 = r30(r51.Text);
            if v1 == "" then
                r54.Text = "STATUS: ENTER A KEY";
                return;
            end;
            r54.Text = "STATUS: VERIFYING...";
            r52.Text = "CHECKING...";
            task.wait(1);
            if r37(v1) then
                r54.Text = "STATUS: ACCESS GRANTED";
                r52.Text = "SUCCESS";
                r31(v1);
                r39(v1);
                task.wait(1);
                v7 = r44;
                v7.Destroy(v7);
                v7 = game;
                v7 = game;
                v7.GetService(v7, "RunService");
                v7 = game;
                v7 = game;
                r55 = v7.GetService(v7, "TweenService");
                v7 = game;
                v7.GetService(v7, "VirtualInputManager");
                v7 = game;
                r56 = v7.GetService(v7, "TeleportService");
                v7 = game;
                r57 = v7.GetService(v7, "HttpService");
                v7 = game;
                r58 = v7.GetService(v7, "CoreGui");
                r59 = v7.GetService(v7, "Players").LocalPlayer;
                v7 = getgenv().TunaUI;
                if v7 then
                    v7 = getgenv().TunaUI;
                    v7.Destroy(v7);
                end;
                r60 = {
                    ["Background"] = Color3.fromRGB(20, 20, 25),
                    ["Sidebar"] = Color3.fromRGB(15, 15, 20),
                    ["Element"] = Color3.fromRGB(30, 30, 38),
                    ["Hover"] = Color3.fromRGB(40, 40, 50),
                    ["Accent"] = Color3.fromRGB(0, 200, 255),
                    ["AccentDark"] = Color3.fromRGB(150, 50, 255),
                    ["Text"] = Color3.fromRGB(240, 240, 240),
                    ["TextDim"] = Color3.fromRGB(180, 180, 180),
                    ["ToggleOff"] = Color3.fromRGB(50, 50, 60),
                    ["ToggleOn"] = Color3.fromRGB(0, 200, 255)
                };
                r61 = Instance.new("ScreenGui");
                r61.Name = "TunaScripts_SellLemons";
                r61.ResetOnSpawn = false;
                r61.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
                v9 = r16;
                getgenv().TunaUI = r61;
                if not pcall(function(...)
                    r61.Parent = r58;
                    return; 
                end) then
                    v9 = r59;
                    r61.Parent = v9.WaitForChild(v9, "PlayerGui");
                end;
                r62 = Instance.new("Frame");
                r62.Size = UDim2.new(0, 600, 0, 400);
                r62.Position = UDim2.new(0.5, -300, 0.5, -200);
                r62.BackgroundColor3 = r60.Background;
                r62.BorderSizePixel = 0;
                r62.ClipsDescendants = true;
                v7 = r62;
                I = v7;
                r = v7;
                v7 = I;
                v7 = r15;
                v7.Parent = r62.Parent and r61 or r61;
                Instance.new("UICorner", r62).CornerRadius = UDim.new(0, 10);
                k = Instance.new("UIStroke");
                k.Color = r60.Accent;
                k.Thickness = 1;
                k.Transparency = 0.5;
                k.Parent = r62;
                r63 = Instance.new("UIGradient");
                r63.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, r60.Accent),
                    ColorSequenceKeypoint.new(0.5, r60.AccentDark),
                    ColorSequenceKeypoint.new(1, r60.Accent)
                });
                r63.Parent = k;
                task.spawn(function(...)
                    v1 = 0;
                    while task.wait(.02) do
                        v7 = (0 + 1) % 360;
                        D = r63;
                        if D then
                            v3 = r63.Parent;
                        end;
                        v7 = v7;
                        if D then
                            D = v7;
                            r63.Rotation = D;
                        else
                        end;
                        return; 
                    end; 
                end);
                v7 = r62.InputBegan;
                v7.Connect(v7, function(arg1_10, ...)
                    r68 = arg1_10;
                    D = r68.UserInputType;
                    if D == Enum.UserInputType.MouseButton1 or r68.UserInputType == Enum.UserInputType.Touch then
                        r64 = true;
                        r66 = r68.Position;
                        r67 = r62.Position;
                        D = r68.Changed;
                        D.Connect(D, function(...)
                            if r68.UserInputState == Enum.UserInputState.End then
                                r64 = false;
                            end;
                            return; 
                        end);
                    end;
                    return; 
                end);
                v7 = r62.InputChanged;
                v7.Connect(v7, function(arg1_11, ...)
                    v1 = arg1_11;
                    if v1.UserInputType == Enum.UserInputType.MouseMovement or v1.UserInputType == Enum.UserInputType.Touch then
                        v7 = arg1_11;
                        r65 = v7;
                    end;
                    return; 
                end);
                v7 = v7.GetService(v7, "UserInputService").InputChanged;
                v7.Connect(v7, function(arg1_12, ...)
                    v1 = arg1_12;
                    v3 = v1 == r65 and r64;
                    if v3 then
                        P = v1.Position - r66;
                        v7 = r55;
                        v3 = v7.Create(v7, r62, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            ["Position"] = UDim2.new(r67.X.Scale, r67.X.Offset + P.X, r67.Y.Scale, r67.Y.Offset + P.Y)
                        });
                        v3.Play(v3);
                    end;
                    return; 
                end);
                I = Instance.new("Frame");
                I.Size = UDim2.new(0, 160, 1, 0);
                I.BackgroundColor3 = r60.Sidebar;
                I.BorderSizePixel = 0;
                I.Parent = r62;
                v = Instance.new("TextLabel");
                v.Size = UDim2.new(1, 0, 0, 50);
                v.BackgroundTransparency = 1;
                v.Text = "\xf0\x9f\x90\x9f TUNA SCRIPTS";
                v.TextColor3 = r60.Text;
                v.Font = Enum.Font.GothamBlack;
                v.TextSize = 16;
                v.Parent = I;
                Instance.new("UIGradient", v).Color = r63.Color;
                r69 = Instance.new("ScrollingFrame");
                r69.Size = UDim2.new(1, 0, 1, -60);
                r69.Position = UDim2.new(0, 0, 0, 50);
                r69.BackgroundTransparency = 1;
                r69.ScrollBarThickness = 0;
                r69.AutomaticCanvasSize = Enum.AutomaticSize.Y;
                r69.CanvasSize = UDim2.new(0, 0, 0, 0);
                r69.Parent = I;
                V = Instance.new("UIListLayout");
                V.Padding = UDim.new(0, 5);
                V.HorizontalAlignment = Enum.HorizontalAlignment.Center;
                V.Parent = r69;
                r70 = Instance.new("Frame");
                r70.Size = UDim2.new(1, -160, 1, 0);
                r70.Position = UDim2.new(0, 160, 0, 0);
                r70.BackgroundTransparency = 1;
                r70.Parent = r62;
                r71 = Instance.new("TextButton");
                r71.Size = UDim2.new(0, 30, 0, 30);
                r71.Position = UDim2.new(1, -35, 0, 10);
                r71.BackgroundColor3 = r60.Element;
                r71.Text = "X";
                r71.TextColor3 = r60.TextDim;
                r71.Font = Enum.Font.GothamBold;
                r71.TextSize = 12;
                r71.Parent = r70;
                Instance.new("UICorner", r71).CornerRadius = UDim.new(0, 6);
                v7 = r71.MouseEnter;
                v7.Connect(v7, function(...)
                    v7 = r55;
                    v3 = v7.Create(v7, r71, TweenInfo.new(.2), {
                        ["BackgroundColor3"] = Color3.fromRGB(255, 60, 60),
                        ["TextColor3"] = Color3.new(1, 1, 1)
                    });
                    v3.Play(v3);
                    return; 
                end);
                v7 = r71.MouseLeave;
                v7.Connect(v7, function(...)
                    v7 = r55;
                    v3 = v7.Create(v7, r71, TweenInfo.new(.2), {
                        ["BackgroundColor3"] = r60.Element,
                        ["TextColor3"] = r60.TextDim
                    });
                    v3.Play(v3);
                    return; 
                end);
                v7 = r71.MouseButton1Click;
                v7.Connect(v7, function(...)
                    v7 = r61;
                    v7.Destroy(v7);
                    return; 
                end);
                r72 = Instance.new("Frame");
                r72.Size = UDim2.new(0, 320, 1, 0);
                r72.Position = UDim2.new(1, -330, 0, 10);
                r72.BackgroundTransparency = 1;
                r72.Parent = r61;
                F = Instance.new("UIListLayout");
                F.Padding = UDim.new(0, 10);
                F.HorizontalAlignment = Enum.HorizontalAlignment.Right;
                F.VerticalAlignment = Enum.VerticalAlignment.Top;
                F.Parent = r72;
                local function r73(arg1_13, arg2_13, arg3_13, arg4_13, ...)
                    v1 = arg1_13;
                    B = arg4_13;
                    D = arg3_13;
                    P = arg2_13;
                    r74 = Instance.new("Frame");
                    r74.Size = UDim2.new(0, 300, 0, 60);
                    r74.Position = UDim2.new(0, 320, 0, 0);
                    v7 = r74;
                    v3 = "BackgroundColor3";
                    v2 = v7;
                    v4 = B;
                    if B then
                        v7 = v7;
                        v7[r15[v6]] = B;
                        r74.BorderSizePixel = 0;
                        r74.ClipsDescendants = true;
                        r74.Parent = r72;
                        Instance.new("UICorner", r74).CornerRadius = UDim.new(0, 6);
                        v4 = Instance.new("TextLabel");
                        v4.Size = UDim2.new(1, -20, 0, 20);
                        v4.Position = UDim2.new(0, 10, 0, 10);
                        v4.BackgroundTransparency = 1;
                        v3 = arg1_13;
                        v4.Text = v3;
                        v4.TextColor3 = Color3.new(1, 1, 1);
                        v4.Font = Enum.Font.GothamBold;
                        v4.TextSize = 14;
                        v4.TextXAlignment = Enum.TextXAlignment.Left;
                        v4.Parent = r74;
                        v2 = Instance.new("TextLabel");
                        v2.Size = UDim2.new(1, -20, 0, 20);
                        v2.Position = UDim2.new(0, 10, 0, 30);
                        v2.BackgroundTransparency = 1;
                        v3 = arg2_13;
                        v2.Text = v3;
                        v2.TextColor3 = Color3.fromRGB(200, 200, 200);
                        v2.Font = Enum.Font.Gotham;
                        v2.TextSize = 12;
                        v2.TextXAlignment = Enum.TextXAlignment.Left;
                        v2.Parent = r74;
                        v7 = r55;
                        v3 = v7.Create(v7, r74, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            ["Position"] = UDim2.new(0, 0, 0, 0)
                        });
                        v3.Play(v3);
                        v7 = task.delay;
                        T = task.delay;
                        v7(arg3_13 or 3, function(...)
                            if r74 and r74.Parent then
                                v7 = r55;
                                v1 = v7.Create(v7, r74, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                                    ["Position"] = UDim2.new(0, 320, 0, 0)
                                });
                                v1.Play(v1);
                                v7 = v1.Completed;
                                v7.Connect(v7, function(...)
                                    v7 = C[o];
                                    v7.Destroy(v7);
                                    return; 
                                end);
                            end;
                            return; 
                        end);
                        return;
                    else
                        v4 = r60.Element;
                    end; 
                end;
                r75 = {};
                local function n(arg1_14, arg2_14, ...)
                    P = arg2_14;
                    r76 = arg1_14;
                    D = Instance.new("TextButton");
                    D.Size = UDim2.new(0, 140, 0, 35);
                    D.BackgroundTransparency = 1;
                    D.Text = r76;
                    v7 = "TextColor3";
                    B = v7;
                    if P then
                        o = r60.Accent;
                    end;
                    v7 = v7;
                    v7 = r16;
                    D[v7] = P or r60.TextDim;
                    D.Font = Enum.Font.GothamBold;
                    D.TextSize = 13;
                    D.Parent = r69;
                    B = Instance.new("Frame");
                    v7 = "Size";
                    O = "Size";
                    J = v7;
                    B[v7] = UDim2.new(0, 3, 0, P and 20 or 0);
                    v8 = v7;
                    A = v7;
                    B.Position = UDim2.new(0, 0, 0.5, P and -10 or 0);
                    B.BackgroundColor3 = r60.Accent;
                    B.BorderSizePixel = 0;
                    B.Parent = D;
                    Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0);
                    o = Instance.new("ScrollingFrame");
                    o.Size = UDim2.new(1, -20, 1, -50);
                    o.Position = UDim2.new(0, 10, 0, 40);
                    o.BackgroundTransparency = 1;
                    o.ScrollBarThickness = 2;
                    o.ScrollBarImageColor3 = r60.Accent;
                    o.AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    o.CanvasSize = UDim2.new(0, 0, 0, 0);
                    o.Visible = P;
                    o.Parent = r70;
                    v4 = Instance.new("UIListLayout");
                    v4.Padding = UDim.new(0, 8);
                    v4.SortOrder = Enum.SortOrder.LayoutOrder;
                    v4.Parent = o;
                    r75[r76] = {
                        ["Button"] = D,
                        ["Page"] = o,
                        ["Indicator"] = B
                    };
                    v3 = D.MouseButton1Click;
                    v3.Connect(v3, function(...)
                        v7 = pairs;
                        D = r75;
                        v1 = B[2];
                        P = B[3];
                        for P, o in v7("pairs") do
                            o.Page.Visible = P == r76;
                            v7 = r55;
                            v7 = v7;
                            v4 = v7.Create(v7, o.Button, TweenInfo.new(.3), {
                                ["TextColor3"] = P == r76 and r60.Accent or r60.TextDim
                            });
                            v4.Play(v4);
                            v7 = r55;
                            d = v7;
                            v4 = v7.Create(v7, o.Indicator, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                ["Size"] = UDim2.new(0, 3, 0, P == r76 and 20 or 0),
                                ["Position"] = UDim2.new(0, 0, 0.5, P == r76 and -10 or 0)
                            });
                            v4.Play(v4); 
                        end;
                        return; 
                    end);
                    return o; 
                end;
                local function R(arg1_15, arg2_15, ...)
                    D = Instance.new("TextLabel");
                    D.Size = UDim2.new(1, -10, 0, 25);
                    D.BackgroundTransparency = 1;
                    D.Text = "  " .. arg2_15;
                    D.TextColor3 = r60.Accent;
                    D.Font = Enum.Font.GothamBold;
                    D.TextSize = 14;
                    D.TextXAlignment = Enum.TextXAlignment.Left;
                    D.Parent = arg1_15;
                    return; 
                end;
                local function Y(arg1_16, arg2_16, ...)
                    D = Instance.new("Frame");
                    D.Size = UDim2.new(1, -10, 0, 0);
                    D.AutomaticSize = Enum.AutomaticSize.Y;
                    D.BackgroundColor3 = r60.Element;
                    D.BackgroundTransparency = 1;
                    D.BorderSizePixel = 0;
                    v3 = arg1_16;
                    D.Parent = v3;
                    B = Instance.new("TextLabel");
                    B.Size = UDim2.new(1, 0, 1, 0);
                    B.AutomaticSize = Enum.AutomaticSize.Y;
                    B.BackgroundTransparency = 1;
                    v3 = arg2_16;
                    B.Text = v3;
                    B.TextColor3 = r60.TextDim;
                    B.Font = Enum.Font.Gotham;
                    B.TextSize = 13;
                    B.TextWrapped = true;
                    B.TextXAlignment = Enum.TextXAlignment.Left;
                    B.Parent = D;
                    o = Instance.new("UIPadding");
                    o.PaddingTop = UDim.new(0, 8);
                    o.PaddingBottom = UDim.new(0, 8);
                    o.PaddingLeft = UDim.new(0, 15);
                    o.PaddingRight = UDim.new(0, 15);
                    o.Parent = D;
                    return B; 
                end;
                local function pP(arg1_17, arg2_17, arg3_17, arg4_17, ...)
                    r77 = arg4_17;
                    o = Instance.new("Frame");
                    o.Size = UDim2.new(1, -10, 0, 45);
                    o.BackgroundColor3 = r60.Element;
                    v3 = arg1_17;
                    o.Parent = v3;
                    Instance.new("UICorner", o).CornerRadius = UDim.new(0, 8);
                    v4 = Instance.new("TextLabel");
                    v4.Size = UDim2.new(1, -70, 1, 0);
                    v4.Position = UDim2.new(0, 15, 0, 0);
                    v4.BackgroundTransparency = 1;
                    v3 = arg2_17;
                    v4.Text = v3;
                    v4.TextColor3 = r60.Text;
                    v4.Font = Enum.Font.GothamMedium;
                    v4.TextSize = 14;
                    v4.TextXAlignment = Enum.TextXAlignment.Left;
                    v4.Parent = o;
                    r78 = Instance.new("TextButton");
                    r78.Size = UDim2.new(0, 44, 0, 22);
                    r78.Position = UDim2.new(1, -55, 0.5, -11);
                    v7 = r78;
                    v3 = "BackgroundColor3";
                    T = v7;
                    J = arg3_17;
                    v6 = J and r60.ToggleOn;
                    v7 = v7;
                    if J then
                        v7 = v7;
                        v7[r15[r16("\xe9;\xe5\x12\xa5\xda`\x0c\xc0v\xfa\xee\x96\xb1\xa5s", O)]] = J and r60.ToggleOn;
                        r78.Text = "";
                        r78.AutoButtonColor = false;
                        v6 = Instance.new("Frame");
                        r78.Parent = v6;
                        Instance.new("UICorner", r78).CornerRadius = UDim.new(1, 0);
                        r79 = Instance.new("Frame");
                        r79.Size = UDim2.new(0, 18, 0, 18);
                        v7 = r79;
                        k = r79;
                        v8 = v7;
                        v7.Position = UDim2.new(0, D and 24 or 2, 0.5, -9);
                        r79.BackgroundColor3 = Color3.new(1, 1, 1);
                        r79.Parent = r78;
                        Instance.new("UICorner", r79).CornerRadius = UDim.new(1, 0);
                        r80 = D;
                        v3 = r78.MouseButton1Click;
                        v3.Connect(v3, function(...)
                            v7 = not r80;
                            r80 = v7;
                            v3 = r55;
                            J = r80;
                            v6 = 11607285994781;
                            if J then
                                v6 = r60.ToggleOn;
                            end;
                            v7 = v7;
                            v1 = v3.Create(v3, r78, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                ["BackgroundColor3"] = v6 or r60.ToggleOff
                            });
                            v1.Play(v1);
                            v3 = r55;
                            J = v7;
                            O = v7;
                            v1 = v3.Create(v3, r79, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                ["Position"] = UDim2.new(0, r80 and 24 or 2, 0.5, -9)
                            });
                            v1.Play(v1);
                            r77(r80);
                            return; 
                        end);
                        return;
                    else
                        v6 = r60.ToggleOff;
                    end; 
                end;
                local function WP(arg1_18, arg2_18, arg3_18, ...)
                    r81 = Instance.new("TextButton");
                    r81.Size = UDim2.new(1, -10, 0, 40);
                    r81.BackgroundColor3 = r60.Element;
                    o = arg2_18;
                    r81.Text = o;
                    r81.TextColor3 = r60.Text;
                    r81.Font = Enum.Font.GothamMedium;
                    r81.TextSize = 14;
                    r81.AutoButtonColor = false;
                    o = arg1_18;
                    r81.Parent = o;
                    Instance.new("UICorner", r81).CornerRadius = UDim.new(0, 8);
                    v7 = r81.MouseEnter;
                    v7.Connect(v7, function(...)
                        v7 = r55;
                        v3 = v7.Create(v7, r81, TweenInfo.new(.2), {
                            ["BackgroundColor3"] = r60.Hover
                        });
                        v3.Play(v3);
                        return; 
                    end);
                    v7 = r81.MouseLeave;
                    v7.Connect(v7, function(...)
                        v7 = r55;
                        v3 = v7.Create(v7, r81, TweenInfo.new(.2), {
                            ["BackgroundColor3"] = r60.Element
                        });
                        v3.Play(v3);
                        return; 
                    end);
                    v7 = r81.MouseButton1Click;
                    v7.Connect(v7, arg3_18);
                    return; 
                end;
                local function r82(arg1_19, ...)
                    r83 = arg1_19;
                    r84 = "https://discord.gg/" .. r83;
                    v7 = setclipboard;
                    if v7 then
                        pcall(setclipboard, r84);
                    end;
                    v7 = v7;
                    v7 = v7;
                    v7 = v7;
                    r85 = syn and syn.request or (http and http.request or http_request);
                    v7 = r85;
                    if v7 then
                        task.spawn(function(...)
                            pcall(function(...)
                                T = r57;
                                k = r57;
                                r85({
                                    ["Url"] = "http://127.0.0.1:6463/rpc?v=1",
                                    ["Method"] = "POST",
                                    ["Headers"] = {
                                        ["Content-Type"] = "application/json",
                                        ["Origin"] = "https://discord.com"
                                    },
                                    ["Body"] = T.JSONEncode(T, {
                                        ["cmd"] = "INVITE_BROWSER",
                                        ["nonce"] = k.GenerateGUID(k, false),
                                        ["args"] = {
                                            ["code"] = r83
                                        }
                                    })
                                });
                                return; 
                            end);
                            return; 
                        end);
                    end;
                    v7 = v7;
                    v7 = v7;
                    r86 = openurl or (syn and syn.openurl or fluxus);
                    if r86 then
                        pcall(function(...)
                            r86(r84);
                            return; 
                        end);
                        if r73 then
                            r73("Discord", "Opening Discord...", 3, r60.Accent);
                        end;
                    else
                        if r73 then
                            r73("Discord", "Invite copied to clipboard!", 4, r60.Accent);
                        end;
                        return;
                    end; 
                end;
                local function r87(...)
                    D = workspace;
                    P = D[3];
                    D = D[1];
                    for P, o in D, ipairs(D.GetChildren(D)) do
                        B = P;
                        v4 = string.find(o.Name, "Tycoon");
                        if v4 then
                            v4 = o.FindFirstChild(o, "Owner") or o.FindFirstChild(o, "OwnerValue");
                            if v4 then
                                v7 = string.find;
                                v2 = v4.Value == r59 or v4.Value == r59.Name;
                            end;
                            if v4 then
                                return o;
                            else
                                if o.GetAttribute(o, "Owner") == r59.UserId or o.GetAttribute(o, "Owner") == r59.Name then
                                    return o;
                                else
                                    
                                end;
                            end;
                        end; 
                    end;
                    return nil; 
                end;
                local function r88(arg1_20, ...)
                    P = r59.Character;
                    if P then
                        P = r59.Character;
                        v3 = P.FindFirstChild(P, "HumanoidRootPart");
                    end;
                    if P then
                        P = arg1_20;
                        r59.Character.HumanoidRootPart.CFrame = P;
                    end;
                    return; 
                end;
                local function r89(arg1_21, ...)
                    D = v7;
                    v1 = arg1_21;
                    D = v7;
                    v4 = v1.IsA(v1, "BasePart");
                    if v4 then
                        B = arg1_21;
                    end;
                    v7 = v7;
                    P = v1.IsA(v1, "Model") and v1.PrimaryPart or (v4 or nil);
                    if P then
                        D = P.CFrame;
                    end;
                    v7 = D;
                    return P or nil; 
                end;
                local function r90(arg1_22, arg2_22, ...)
                    P = arg2_22;
                    v7 = workspace;
                    D = v7.FindFirstChild(v7, arg1_22);
                    B = D and D.FindFirstChild(D, P);
                    if B then
                        o = r89(B);
                        if o then
                            r88(o + Vector3.new(0, 3, 0));
                        end;
                    else
                        r73("Error", "Location " .. P .. " not found!", 3, Color3.fromRGB(255, 50, 50));
                    end;
                    return; 
                end;
                r91 = false;
                r92 = false;
                r93 = false;
                r94 = false;
                r95 = false;
                r96 = false;
                r97 = false;
                r98 = false;
                r99 = false;
                r100 = false;
                r101 = false;
                r102 = false;
                r103 = false;
                r104 = false;
                r105 = false;
                aP = n("Information", true);
                ZP = n("Main", false);
                JP = n("Clicks & Cash", false);
                HP = n("Dash & Depot", false);
                LP = n("Progress", false);
                OP = n("Teleports", false);
                R(ZP, "Character");
                (function(arg1_24, arg2_24, arg3_24, arg4_24, ...)
                    r106 = arg4_24;
                    o = Instance.new("Frame");
                    o.Size = UDim2.new(1, -10, 0, 45);
                    o.BackgroundColor3 = r60.Element;
                    v3 = arg1_24;
                    o.Parent = v3;
                    Instance.new("UICorner", o).CornerRadius = UDim.new(0, 8);
                    v4 = Instance.new("TextLabel");
                    v4.Size = UDim2.new(.4, 0, 1, 0);
                    v4.Position = UDim2.new(0, 15, 0, 0);
                    v4.BackgroundTransparency = 1;
                    v3 = arg2_24;
                    v4.Text = v3;
                    v4.TextColor3 = r60.Text;
                    v4.Font = Enum.Font.GothamMedium;
                    v4.TextSize = 14;
                    v4.TextXAlignment = Enum.TextXAlignment.Left;
                    v4.Parent = o;
                    r107 = Instance.new("TextBox");
                    r107.Size = UDim2.new(0.5, -15, 0, 30);
                    r107.Position = UDim2.new(0.5, 0, 0.5, -15);
                    r107.BackgroundColor3 = r60.Background;
                    v6 = arg3_24;
                    r107.PlaceholderText = v6;
                    r107.Text = "";
                    r107.TextColor3 = r60.Accent;
                    r107.Font = Enum.Font.Gotham;
                    r107.TextSize = 13;
                    r107.Parent = o;
                    Instance.new("UICorner", r107).CornerRadius = UDim.new(0, 6);
                    v7 = r107.FocusLost;
                    v7.Connect(v7, function(arg1_25, ...)
                        v1 = arg1_25;
                        if v1 then
                            if v1 then
                                r106(r107.Text);
                                r107.Text = "";
                            end;
                            return;
                        else
                            v3 = r107.Text ~= "";
                        end; 
                    end);
                    return; 
                end)(ZP, "Change Display Name", "Enter new name...", function(arg1_23, ...)
                    v1 = arg1_23;
                    P = r59.Character;
                    if not P then
                        return;
                    end;
                    D = P.FindFirstChild(P, "Humanoid");
                    B = P.FindFirstChild(P, "HumanoidRootPart");
                    if D then
                        D.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
                    end;
                    v7 = B.FindFirstChild(B, "CustomNameTag");
                    if v7 then
                        v7 = B.CustomNameTag;
                        v7.Destroy(v7);
                    end;
                    o = Instance.new("BillboardGui");
                    o.Name = "CustomNameTag";
                    o.Parent = B;
                    o.Adornee = B;
                    o.Size = UDim2.new(0, 100, 0, 50);
                    o.StudsOffset = Vector3.new(0, 2.5, 0);
                    o.AlwaysOnTop = true;
                    v4 = Instance.new("TextLabel", o);
                    v4.Size = UDim2.new(1, 0, 1, 0);
                    v4.BackgroundTransparency = 1;
                    v3 = arg1_23;
                    v4.Text = v3;
                    v4.TextColor3 = Color3.fromRGB(255, 255, 255);
                    v4.Font = Enum.Font.GothamBold;
                    v4.TextSize = 20;
                    v4.TextStrokeTransparency = 0.5;
                    r73("Name Changed", "Your overhead tag is now: " .. v1, 3, r60.Accent);
                    return; 
                end);
                R(ZP, "Tycoon Automation");
                pP(ZP, "\xf0\x9f\x8f\xaa Auto Buy", false, function(arg1_26, ...)
                    r91 = arg1_26;
                    return; 
                end);
                pP(ZP, "\xe2\x9a\x99\xef\xb8\x8f Auto Upgrade", false, function(arg1_27, ...)
                    r92 = arg1_27;
                    return; 
                end);
                r108 = false;
                pP(ZP, "Auto Raise x2 + Accept", false, function(arg1_28, ...)
                    r108 = arg1_28;
                    if r108 then
                        task.spawn(function(...)
                            while r108 do
                                r109 = r87();
                                if r109 then
                                    pcall(function(...)
                                        v7 = r109;
                                        v3 = v7.WaitForChild(v7, "Remotes");
                                        v1 = v3.WaitForChild(v3, "PhoneOffer");
                                        if not r108 then
                                            return;
                                        end;
                                        v1.FireServer(v1, "Raise");
                                        task.wait(0.5);
                                        if not r108 then
                                            return;
                                        end;
                                        v1.FireServer(v1, "Raise");
                                        task.wait(0.5);
                                        if not r108 then
                                            return;
                                        end;
                                        v1.FireServer(v1, "Accept");
                                        return; 
                                    end);
                                else
                                    warn("Could not find your Tycoon base!");
                                end;
                                task.wait(1.5); 
                            end;
                            return; 
                        end);
                    end;
                    return; 
                end);
                R(JP, "Clickers");
                pP(JP, "Main Auto Click (All)", false, function(arg1_29, ...)
                    r93 = arg1_29;
                    return; 
                end);
                R(JP, "Sewer Cash Vine");
                pP(JP, "\xf0\x9f\x8c\xb1 Auto Cash Vine (Absolute Path)", false, function(arg1_30, ...)
                    v1 = arg1_30;
                    getgenv().autoSewerVine = v1;
                    if v1 then
                        r73("Tuna Scripts V2", "Sewer Vine loop active!", 2, r60.Accent);
                        task.spawn(function(...)
                            while getgenv().autoSewerVine do
                                pcall(function(...)
                                    v7 = workspace;
                                    v1 = v7.WaitForChild(v7, "Map", 2);
                                    P = v1 and v1.WaitForChild(v1, "Sewer", 2);
                                    D = P and P.WaitForChild(P, "CashVine", 2);
                                    B = D and D.WaitForChild(D, "CashVine", 2);
                                    o = B and B.WaitForChild(B, "Use", 2);
                                    if o then
                                        v3 = o.IsA(o, "RemoteFunction");
                                    end;
                                    if o then
                                        o.InvokeServer(o);
                                    end;
                                    return; 
                                end);
                                task.wait(0.5); 
                            end;
                            return; 
                        end);
                    end;
                    return; 
                end);
                WP(JP, "Unlock Cash Vine", function(...)
                    v7 = workspace;
                    v1 = v7.WaitForChild(v7, "Map", 2);
                    P = v1 and v1.WaitForChild(v1, "Sewer", 2);
                    if P then
                        v3 = P.WaitForChild(P, "CashVine", 2);
                    end;
                    r110 = P;
                    if r110 then
                        pcall(function(...)
                            v7 = r110;
                            v1 = v7.WaitForChild(v7, "VineKey", 1);
                            if v1 then
                                v3 = v1.IsA(v1, "BasePart") and v1.CFrame and nil;
                                v7 = r110;
                                r88(v1.FindFirstChildWhichIsA(v1, "BasePart").CFrame);
                            end;
                            task.wait(.3);
                            v7 = r110;
                            P = v7.WaitForChild(v7, "CashVine", 1);
                            if P then
                                v7 = r110;
                                v3 = P.IsA(P, "BasePart") and P.CFrame and nil;
                                r88(P.FindFirstChildWhichIsA(P, "BasePart").CFrame);
                            end;
                            task.wait(.2);
                            v7 = workspace.Map.Sewer.CashVine.VineDoor.Door.Unlock;
                            v7.InvokeServer(v7);
                            r73("Success", "Teleported and unlocked!", 3, r60.Accent);
                            return; 
                        end);
                    end;
                    return; 
                end);
                R(JP, "Cash Drops");
                pP(JP, "Auto Pickup Cash", false, function(arg1_31, ...)
                    r94 = arg1_31;
                    return; 
                end);
                R(HP, "Lemon Dash");
                pP(HP, "Auto Buy Dash Upgrades", false, function(arg1_32, ...)
                    r95 = arg1_32;
                    return; 
                end);
                pP(HP, "Auto Upgrade (LD)", false, function(arg1_33, ...)
                    r96 = arg1_33;
                    return; 
                end);
                R(HP, "Lemon Depot");
                pP(HP, "Auto Buy Depot Buttons", false, function(arg1_34, ...)
                    r98 = arg1_34;
                    return; 
                end);
                pP(HP, "Auto Upgrade (LDP)", false, function(arg1_35, ...)
                    r97 = arg1_35;
                    return; 
                end);
                R(HP, "Lemon Labs");
                pP(HP, "Auto Buy Buttons (LL)", false, function(arg1_36, ...)
                    r99 = arg1_36;
                    return; 
                end);
                R(LP, "Farming");
                pP(LP, "\xf0\x9f\x8d\x8b Auto Fruit", false, function(arg1_37, ...)
                    r100 = arg1_37;
                    return; 
                end);
                pP(LP, "\xf0\x9f\xa7\xa9 Auto Lever Puller", false, function(arg1_38, ...)
                    r104 = arg1_38;
                    return; 
                end);
                pP(LP, "\xf0\x9f\xa7\xaa Auto Sewer Run", false, function(arg1_39, ...)
                    r105 = arg1_39;
                    return; 
                end);
                R(LP, "Prestige");
                pP(LP, "\xf0\x9f\x94\x84 Auto Rebirth (2x)", false, function(arg1_40, ...)
                    r101 = arg1_40;
                    return; 
                end);
                pP(LP, "\xe2\x9c\xa8 Auto Evolve (10x)", false, function(arg1_41, ...)
                    r102 = arg1_41;
                    return; 
                end);
                pP(LP, "\xe2\x9a\xa1 Auto Power Level", false, function(arg1_42, ...)
                    r103 = arg1_42;
                    if r103 then
                        startUpgradeLoop();
                    end;
                    return; 
                end);
                WP(OP, "\xf0\x9f\x8f\xb0 Instant TP to My Tycoon", function(...)
                    pcall(function(...)
                        v7 = game;
                        P = v7.GetService(v7, "Players").LocalPlayer;
                        D = P.Character;
                        if not D or not D.FindFirstChild(D, "HumanoidRootPart") then
                            r73("Error", "Character not fully loaded!", 3, Color3.fromRGB(255, 50, 50));
                            return;
                        end;
                        v7 = ipairs;
                        v2 = workspace;
                        v4 = v2[3];
                        o = v2[2];
                        v2 = "ipairs";
                        for v4, T in v7(v2.GetChildren(v2)) do
                            v6 = v4;
                            v7 = T.Name;
                            J = v7.match(v7, "^Tycoon%d+$");
                            if J then
                                J = T.FindFirstChild(T, "Owner");
                                v7 = T.GetAttribute(T, "Owner");
                                if J then
                                    T.GetAttribute(T, O[r16(k, r)]);
                                    v8 = J.Value == P or tostring(J.Value) == P.Name;
                                end;
                                v7 = v7;
                                if J or tostring(v7) == P.Name then
                                    B = T;
                                else
                                    
                                end;
                            end; 
                        end;
                        if nil then
                            o = nil.FindFirstChild(nil, "Locations");
                            if o then
                                v4 = o.FindFirstChild(o, "Spawn");
                            end;
                            v7 = v7;
                            if o then
                                if o.IsA(o, "Model") then
                                    D.PivotTo(D, o.GetPivot(o) + Vector3.new(0, 5, 0));
                                else
                                    D.PivotTo(D, o.CFrame + Vector3.new(0, 5, 0));
                                end;
                                r73("Tuna Scripts V2", "Teleported to " .. nil.Name, 2, r60.Accent);
                            else
                                r73("Error", "Spawn location not found in your Tycoon!", 3, Color3.fromRGB(255, 50, 50));
                            end;
                        else
                            r73("Error", "Could not find a claimed Tycoon!", 3, Color3.fromRGB(255, 50, 50));
                        end;
                        return; 
                    end);
                    return; 
                end);
                WP(OP, "Sewer Exit Left", function(...)
                    r90("Locations", "SewerExitLeft");
                    return; 
                end);
                WP(OP, "Sewer Exit Right", function(...)
                    r90("Locations", "SewerExitRight");
                    return; 
                end);
                WP(OP, "Void Location", function(...)
                    r90("Locations", "Void");
                    return; 
                end);
                WP(OP, "Teleport to Sewer Alien", function(...)
                    r88(CFrame.new(Vector3.new(-42, -41, 180)));
                    r73("Teleport", "Teleported to UFO", 3, r60.Accent);
                    return; 
                end);
                R(OP, "Server");
                WP(OP, "Server Hop", function(...)
                    v7 = r57;
                    v1 = game;
                    o = "data";
                    B = v7.JSONDecode(v7, v1.HttpGet(v1, "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))[o];
                    P = o[2];
                    B = o[1];
                    for D, v4 in pairs(B) do
                        o = D;
                        if v4.playing < v4.maxPlayers and v4.id ~= game.JobId then
                            v7 = r56;
                            v7.TeleportToPlaceInstance(v7, game.PlaceId, v4.id, r59);
                            break;
                        else
                            
                        end; 
                    end;
                    return; 
                end);
                iP = Instance.new("TextLabel");
                iP.Size = UDim2.new(1, -10, 0, 0);
                iP.AutomaticSize = Enum.AutomaticSize.Y;
                iP.BackgroundTransparency = 1;
                v3 = "                                 \xf0\x9f\x90\x9f Tuna Scripts V2\n\n\xf0\x9f\x9a\x80 LATEST UPDATES:\n\xe2\x80\xa2 Fixed Instant TP To Base/Tycoon\n\xe2\x80\xa2 Fixed Auto Cash Vine\n\xe2\x80\xa2 Fixed UI crashing and nil value errors\n\xe2\x80\xa2 Fixed Auto discord Link\n\n\xf0\x9f\x92\xac Join The Discord Server For More Updates And To Keep Me Motivated!\n";
                iP.Text = v3;
                iP.TextColor3 = r60.TextDim;
                iP.Font = Enum.Font.Gotham;
                iP.TextSize = 13;
                iP.TextWrapped = true;
                iP.TextXAlignment = Enum.TextXAlignment.Left;
                iP.TextYAlignment = Enum.TextYAlignment.Top;
                v3 = n("Information", true);
                iP.Parent = v3;
                jP = Instance.new("UIPadding");
                jP.PaddingBottom = UDim.new(0, 10);
                jP.Parent = iP;
                WP(aP, "\xf0\x9f\x8c\x90 Join Discord Server", function(...)
                    r82("yrVfhkvdAb");
                    return; 
                end);
                task.spawn(function(...)
                    while true do
                        task.wait(.05);
                        if r91 then
                            v1 = r87();
                            if v1 then
                                B = v1.Purchases;
                                P = B[2];
                                B = B[1];
                                for D, v4 in ipairs(B.GetDescendants(B)) do
                                    o = D;
                                    if v4.IsA(v4, "Model") and (v4.GetAttribute(v4, "Shown") == true and v4.GetAttribute(v4, "Purchased") ~= true) then
                                        r111 = v4.FindFirstChild(v4, "Purchase");
                                        T = r111;
                                        if T then
                                            T = r111;
                                            v6 = T.IsA(T, "RemoteFunction");
                                        end;
                                        if T then
                                            pcall(function(...)
                                                v7 = r111;
                                                v7.InvokeServer(v7);
                                                return; 
                                            end);
                                        end;
                                    end; 
                                end;
                            end;
                        end; 
                    end;
                    return; 
                end);
                task.spawn(function(...)
                    while true do
                        task.wait(1);
                        if r92 then
                            v1 = r87();
                            if v1 then
                                T = "\x8b\xcd\t5\x9br;\xf4\x8e";
                                v6 = r16(T, 25046825627023);
                                B = v1[r15[v6]];
                                D = B[3];
                                P = B[2];
                                B = "ipairs";
                                for D, v4 in ipairs(B.GetDescendants(B)) do
                                    r112 = v4;
                                    o = D;
                                    v6 = C[v7];
                                    T = v6.IsA(v6, "RemoteFunction");
                                    if T then
                                        v2 = C[v7].Name == "Upgrade";
                                    end;
                                    if T then
                                        pcall(function(...)
                                            for S = 1, 100 do
                                                v7 = C[v7];
                                                v7.InvokeServer(v7, v1); 
                                            end;
                                            return; 
                                        end);
                                    end; 
                                end;
                            end;
                        end; 
                    end;
                    return; 
                end);
                task.spawn(function(...)
                    while true do
                        task.wait(.2);
                        if r93 then
                            r113 = C[mP]();
                            if r113 then
                                pcall(function(...)
                                    v7 = r113;
                                    v3 = v7.WaitForChild(v7, "Remotes");
                                    v1 = v3.WaitForChild(v3, "WakeIncomeStream");
                                    v1.InvokeServer(v1, "LemonStand");
                                    task.wait(.01);
                                    v1.InvokeServer(v1, "LemonDash");
                                    task.wait(.01);
                                    v1.InvokeServer(v1, "LemonTrading");
                                    task.wait(.01);
                                    v1.InvokeServer(v1, "LemonLabs");
                                    task.wait(.01);
                                    v1.InvokeServer(v1, "LemonDepot");
                                    task.wait(.01);
                                    v1.InvokeServer(v1, "LemonRepublic");
                                    return; 
                                end);
                            end;
                        end; 
                    end;
                    return; 
                end);
                local function r114(...)
                    if r87 then
                        v1 = r87();
                        if v1 then
                            return v1;
                        end;
                    end;
                    D = workspace;
                    P = D[3];
                    v1 = D[2];
                    D = "ipairs";
                    for P, o in ipairs(D.GetChildren(D)) do
                        B = P;
                        v2 = o.Name;
                        v6 = v2.find(v2, "Tycoon");
                        v4 = v6;
                        if v6 then
                            if v4 then
                                v4 = o.FindFirstChild(o, "Owner") or o.FindFirstChild(o, "Player");
                                if v4 then
                                    if v4.Value == player or (v4.Value == player.Name or tostring(v4.Value) == player.Name) then
                                        return o;
                                    else
                                    end;
                                end;
                                if o.GetAttribute(o, "Owner") == player.Name or o.GetAttribute(o, "OwnerId") == player.UserId then
                                    return o;
                                else
                                    
                                end;
                            end;
                        else
                            v4 = o.FindFirstChild(o, "Remotes");
                        end; 
                    end;
                    return nil; 
                end;
                local function IP(...)
                    task.spawn(function(...)
                        while r93 do
                            v1 = r114();
                            P = v1 and v1.FindFirstChild(v1, "Remotes");
                            if P then
                                v3 = P.FindFirstChild(P, "WakeIncomeStream");
                            end;
                            r115 = P;
                            B = r115;
                            if B then
                                B = r115;
                                v3 = B.IsA(B, "RemoteFunction");
                            end;
                            if B then
                                v4 = LemonTargets;
                                o = ("LemonTargets")[3];
                                v4 = ("LemonTargets")[1];
                                for o, v6 in v4, ipairs(v4) do
                                    r116 = v6;
                                    v2 = o;
                                    v6 = 73;
                                    if not r15 then
                                        
                                    end; 
                                end;
                            else
                                task.wait(1);
                            end;
                            task.wait(.1); 
                        end;
                        return; 
                    end);
                    return; 
                end;
                local function bP(...)
                    task.spawn(function(...)
                        while r93 do
                            v1 = r114();
                            P = v1 and v1.FindFirstChild(v1, "Remotes");
                            if P then
                                v3 = P.FindFirstChild(P, "WakeIncomeStream");
                            end;
                            r117 = P;
                            B = r117;
                            if B then
                                B = r117;
                                v3 = B.IsA(B, "RemoteFunction");
                            end;
                            if B then
                                v4 = Fruits;
                                o = ("Fruits")[3];
                                v4 = ("Fruits")[1];
                                for o, v6 in v4, ipairs(v4) do
                                    v2 = o;
                                    r118 = v6;
                                    J = ("Buildings")[2];
                                    T = ("Buildings")[1];
                                    for A, v8 in ipairs(Buildings) do
                                        r119 = v8;
                                        O = A;
                                        v8 = 82;
                                        if not r15 then
                                            
                                        end; 
                                    end; 
                                end;
                            else
                                task.wait(1);
                            end;
                            task.wait(.1); 
                        end;
                        return; 
                    end);
                    return; 
                end;
                v7 = workspace;
                r120 = v7.WaitForChild(v7, "CashDrops", 5);
                task.spawn(function(...)
                    while true do
                        task.wait(.2);
                        if r94 and r120 then
                            v1 = r59.Character;
                            if v1 then
                                v1 = r59.Character;
                                v3 = v1.FindFirstChild(v1, "HumanoidRootPart");
                            end;
                            r121 = v1;
                            if r121 then
                                B = C[rP];
                                D = B[3];
                                P = B[2];
                                B = "ipairs";
                                for D, v4 in ipairs(B.GetChildren(B)) do
                                    r122 = v4;
                                    v4 = 68;
                                    o = D;
                                    pcall(function(...)
                                        D = r122;
                                        B = D.IsA(D, "BasePart");
                                        if B then
                                            v1 = r122;
                                        end;
                                        v7 = Env[v2];
                                        v1 = B or D.IsA(D, "Model");
                                        if v1 then
                                            firetouchinterest(r121, v1, 0);
                                            task.wait();
                                            firetouchinterest(r121, v1, 1);
                                        end;
                                        return; 
                                    end); 
                                end;
                            end;
                        end; 
                    end;
                    return; 
                end);
                task.spawn(function(...)
                    while true do
                        task.wait(0.5);
                        v1 = r87();
                        if v1 then
                            r123 = v1.FindFirstChild(v1, "Purchases");
                            if r123 then
                                if r95 then
                                    pcall(function(...)
                                        v1 = r123;
                                        v1 = v1.FindFirstChild(v1, "LemonDash") and v1.FindFirstChild(v1, "Buttons");
                                        if v1 then
                                            o = "Decor";
                                            B = o[3];
                                            D = o[2];
                                            o = "ipairs";
                                            for B, v2 in ipairs({
                                                v1.FindFirstChild(v1, "Multiplier"),
                                                v1.FindFirstChild(v1, "Other"),
                                                v1.FindFirstChild(v1, "Structure"),
                                                v1.FindFirstChild(v1, o)
                                            }) do
                                                v4 = B;
                                                if v2 then
                                                    O = v2.GetChildren;
                                                    T = O[2];
                                                    J = O[3];
                                                    for J, O in ipairs(O(v2)) do
                                                        A = J;
                                                        v8 = O.FindFirstChild(O, "Purchase");
                                                        if v8 then
                                                            v8.InvokeServer(v8, false);
                                                        end; 
                                                    end;
                                                end; 
                                            end;
                                        end;
                                        return; 
                                    end);
                                end;
                                if r96 then
                                    pcall(function(...)
                                        v7 = r123.LemonDash.LemonDash.LemonDash.Upgrade;
                                        v7.InvokeServer(v7, 1);
                                        return; 
                                    end);
                                end;
                                if r97 then
                                    pcall(function(...)
                                        v7 = r123["Lemon Depot"]["Lemon Depot"]["Lemon Depot"].Upgrade;
                                        v7.InvokeServer(v7, 1);
                                        return; 
                                    end);
                                end;
                                if r98 then
                                    pcall(function(...)
                                        v1 = r123;
                                        v1 = v1.FindFirstChild(v1, "Lemon Depot") or v1.FindFirstChild(v1, "LemonDepot");
                                        P = v1 and v1.FindFirstChild(v1, "Buttons");
                                        if P then
                                            D = P.FindFirstChild(P, "Lemon Depot") or P.FindFirstChild(P, "LemonDepot");
                                            if D then
                                                v3 = D.FindFirstChild(D, "Purchase");
                                            end;
                                            if D then
                                                v7 = D.Purchase;
                                                v7.InvokeServer(v7, false);
                                            end;
                                            v2 = "Structure";
                                            v4 = v2[3];
                                            o = v2[2];
                                            v2 = "ipairs";
                                            for v4, T in ipairs({
                                                P.FindFirstChild(P, "Decor"),
                                                P.FindFirstChild(P, "Multiplier"),
                                                P.FindFirstChild(P, "Other"),
                                                P.FindFirstChild(P, v2)
                                            }) do
                                                v6 = v4;
                                                if T then
                                                    v9 = T.GetChildren;
                                                    J = v9[1];
                                                    A = v9[2];
                                                    for O, v9 in ipairs(v9(T)) do
                                                        v8 = O;
                                                        k = v9.FindFirstChild(v9, "Purchase");
                                                        if k then
                                                            k.InvokeServer(k, false);
                                                        end; 
                                                    end;
                                                end; 
                                            end;
                                        end;
                                        return; 
                                    end);
                                end;
                                if r99 then
                                    pcall(function(...)
                                        v1 = r123;
                                        v1 = v1.FindFirstChild(v1, "Lemon Labs") or v1.FindFirstChild(v1, "LemonLabs");
                                        P = v1 and v1.FindFirstChild(v1, "Buttons");
                                        if P then
                                            v4 = "Structure";
                                            B = v4[2];
                                            o = v4[3];
                                            v4 = "ipairs";
                                            for o, v6 in ipairs({
                                                P.FindFirstChild(P, "Decor"),
                                                P.FindFirstChild(P, "Multipliers"),
                                                P.FindFirstChild(P, "Other"),
                                                P.FindFirstChild(P, v4)
                                            }) do
                                                v2 = o;
                                                if v6 then
                                                    v8 = v6.GetChildren;
                                                    A = v8[3];
                                                    J = v8[2];
                                                    for A, v8 in ipairs(v8(v6)) do
                                                        O = A;
                                                        v9 = v8.FindFirstChild(v8, "Purchase");
                                                        if v9 then
                                                            v9.InvokeServer(v9, false);
                                                        end; 
                                                    end;
                                                end; 
                                            end;
                                        end;
                                        return; 
                                    end);
                                end;
                            end;
                        end; 
                    end;
                    return; 
                end);
                r124 = {};
                local function XP(arg1_43, ...)
                    v1 = arg1_43;
                    if v1.IsA(v1, "Model") and (v1.Name == "LemonTree" and not table.find(r124, v1)) then
                        table.insert(r124, v1);
                    end;
                    return; 
                end;
                NP = workspace;
                vP = NP[3];
                sP = NP[2];
                for vP, KP in ipairs(NP.GetDescendants(NP)) do
                    XP(KP);
                    VP = vP; 
                end;
                yj[7] = 26807988629699;
                v7 = workspace.DescendantAdded;
                yj[4] = "\xca";
                v7.Connect(v7, XP);
                yj[8] = "W\x01";
                yj[2] = "\xf6";
                task.spawn(function(...)
                    while true do
                        B = r16("\xb9r\x87S", 19283263349523);
                        task[r15[B]](.1);
                        if r100 then
                            D = r124;
                            P = B[3];
                            v1 = B[2];
                            for P, o in ipairs(v3) do
                                B = P;
                                r125 = o;
                                o = 72;
                                if not r100 then
                                    
                                else
                                    if r125 and r125.Parent then
                                        pcall(function(...)
                                            v1 = r59.Character;
                                            v1 = v1 and v1.FindFirstChild(v1, "HumanoidRootPart");
                                            if v1 then
                                                P = r125;
                                                v1.CFrame = P.GetPivot(P) + Vector3.new(0, 5, 0);
                                            end;
                                            B = r125;
                                            D = B[3];
                                            B = B[1];
                                            for D, v4 in B, ipairs(B.GetDescendants(B)) do
                                                o = D;
                                                if v4.IsA(v4, "BasePart") and v4.Name == "Fruit" then
                                                    v4.CanCollide = false;
                                                    v6 = v4.FindFirstChild(v4, "ClickPart");
                                                    if v6 then
                                                        v6 = v4.ClickPart;
                                                        v2 = v6.FindFirstChildOfClass(v6, "ClickDetector");
                                                    end;
                                                    if v6 then
                                                        task.wait(.2);
                                                        fireclickdetector(v6);
                                                    end;
                                                end; 
                                            end;
                                            return; 
                                        end);
                                    end;
                                end; 
                            end;
                        end; 
                    end;
                    return; 
                end);
                yj[10] = "\xf8\xd3";
                yj[5] = 28101465174813;
                yj[3] = 25841043631873;
                yj[1] = 35053318258626;
                yj[6] = "\xd8";
                yj[9] = 33631111331116;
                yj[1] = r16(yj[2], yj[3]);
                yj[1] = r15;
                yj[2] = r16;
                yj[3] = yj[2](yj[4], yj[5]);
                yj[1] = 1000000000;
                yj[3] = r15;
                yj[4] = r16;
                yj[5] = yj[4](yj[6], yj[7]);
                yj[2] = yj[3][yj[5]];
                yj[5] = r15;
                yj[3] = 1000000000000;
                yj[6] = r16;
                yj[11] = 12200356419121;
                yj[7] = yj[6](yj[8], yj[9]);
                yj[4] = yj[5][yj[7]];
                yj[7] = r15;
                yj[8] = r16;
                yj[9] = yj[8](yj[10], yj[11]);
                yj[5] = 1e+15;
                yj[6] = yj[7][yj[9]];
                yj[7] = 1e+18;
                r126 = {
                    ["thousand"] = 1000,
                    ["million"] = 1000000,
                    ["billion"] = 1000000000,
                    ["trillion"] = 1000000000000,
                    ["quadrillion"] = 1e+15,
                    ["quintillion"] = 1e+18,
                    ["sextillion"] = 1e+21,
                    ["septillion"] = 1e+24,
                    ["octillion"] = 1e+27,
                    ["nonillion"] = 1e+30,
                    ["decillion"] = 1e+33,
                    [r15[r16("\xfd", yj[1])]] = 1000,
                    [r15[yj[1]]] = 1000000,
                    [yj[1][yj[3]]] = yj[1],
                    [yj[2]] = yj[3],
                    [yj[4]] = yj[5],
                    [yj[6]] = yj[7]
                };
                local function r127(arg1_44, ...)
                    v1 = arg1_44;
                    if not v1 then
                        return nil;
                    end;
                    v3 = tostring(v1);
                    v7 = v3.gsub(v3, ",", "");
                    v1 = v7.lower(v7);
                    P = v1.match(v1, "[%d%.]+");
                    if P then
                        D = tonumber(P);
                    end;
                    if not P then
                        return nil;
                    end;
                    B = v1.match(v1, "[%d%.%s]+([a-z]+)");
                    if B then
                        o = r126[B];
                    end;
                    if B then
                        D = P * r126[B];
                    end;
                    return P; 
                end;
                task.spawn(function(...)
                    r128 = false;
                    r129 = false;
                    while true do
                        v4 = r16("\xdb\x84\x85H", 33153423080526);
                        task[r15[v4]](0.5);
                        r130 = r87();
                        if r130 and (r101 and not r128) then
                            pcall(function(...)
                                o = ".X\x98\x0f\xed\xdb\xfdH\x1b";
                                v7 = r59;
                                v4 = 18334071546201;
                                v1 = v7.FindFirstChildOfClass(v7, r15[r16(o, v4)]);
                                if v1 then
                                    v4 = r15;
                                    v7 = r59;
                                    v3 = v1.FindFirstChild(v1, "Rebirth") and (v4.FindFirstChild(v4, "InvestorsMenu") and v4.FindFirstChild(v4, "Body"));
                                end;
                                if v1 then
                                    v2 = v1.FindFirstChild(v1, "Amount");
                                    if v2 then
                                        r127(v3.Amount.Quantity.Text);
                                    end;
                                    v7 = r59;
                                    D = v2;
                                end;
                                v7 = v7;
                                B = v7;
                                D = P or 0;
                                if v1 then
                                    o = v1.FindFirstChild(v1, "Potential");
                                    v3 = o and r127(v1.Potential.Quantity.Text);
                                    v7 = v7;
                                end;
                                if P then
                                    v6 = P >= 1;
                                    if v6 then
                                        v4 = P >= (P or 0) * 1;
                                    end;
                                    v3 = v6;
                                    v7 = v7;
                                end;
                                v7 = B;
                                if P then
                                    r128 = true;
                                    o = r130.Remotes.Rebirth;
                                    o.InvokeServer(o);
                                    task.wait(2);
                                    r128 = false;
                                end;
                                return; 
                            end);
                        end;
                        B = r130;
                        if B then
                            v4 = C[fP];
                            if v4 then
                                B = not r129;
                            end;
                            v7 = r87;
                            v3 = v4;
                        end;
                        if B then
                            pcall(function(...)
                                v7 = r59;
                                v1 = v7.FindFirstChildOfClass(v7, "PlayerGui");
                                v3 = v1 and v1.FindFirstChild(v1, "Rebirth");
                                D = v3 and tonumber(27309449802156.match(27309449802156, "[%d%.]+"));
                                if D then
                                    v3 = D >= 100;
                                end;
                                if D then
                                    r129 = true;
                                    v3 = r130.Remotes.Evolve;
                                    v3.InvokeServer(v3);
                                    task.wait(2);
                                    r129 = false;
                                end;
                                return; 
                            end);
                        end; 
                    end;
                    return; 
                end);
                v7 = game;
                r131 = v7.GetService(v7, "Players").LocalPlayer;
                r132 = false;
                r133 = {
                    "ClickFruitValue",
                    "Manage",
                    "BuyNext",
                    "WalkSpeed",
                    "UpgradeStack"
                };
                local function r134(...)
                    if r87 then
                        v1 = r87();
                        if v1 then
                            return v1;
                        end;
                    end;
                    D = workspace;
                    v1 = D[2];
                    D = D[1];
                    for P, o in ipairs(D.GetChildren(D)) do
                        B = P;
                        v2 = o.Name;
                        v6 = v2.find(v2, "Tycoon");
                        v4 = v6;
                        if v6 then
                            if v4 then
                                v4 = o.FindFirstChild(o, "Owner") or o.FindFirstChild(o, "Player");
                                if v4 then
                                    if v4.Value == r131 or (v4.Value == r131.Name or tostring(v4.Value) == r131.Name) then
                                        return o;
                                    else
                                    end;
                                end;
                                if o.GetAttribute(o, "Owner") == r131.Name or o.GetAttribute(o, "OwnerId") == r131.UserId then
                                    return o;
                                else
                                    
                                end;
                            end;
                        else
                            v4 = o.FindFirstChild(o, "Remotes");
                        end; 
                    end;
                    P = workspace;
                    v1 = P.FindFirstChild(P, "Tycoons") or P.FindFirstChild(P, "Plots");
                    if v1 then
                        v4 = v1.GetChildren;
                        B = v4[3];
                        for B, v4 in v4[1], ipairs(v4(v1)) do
                            o = B;
                            v2 = v4.FindFirstChild(v4, "Owner") or v4.FindFirstChild(v4, "Player");
                            if v2 then
                                v6 = v2.Value == r131 or v2.Value == r131.Name;
                                v7 = ipairs;
                            end;
                            if v2 then
                                return v4;
                            else
                                if v4.GetAttribute(v4, "Owner") == r131.Name or v4.GetAttribute(v4, "OwnerId") == r131.UserId then
                                    return v4;
                                else
                                    
                                end;
                            end; 
                        end;
                    end;
                    return nil; 
                end;
                local function FP(...)
                    task.spawn(function(...)
                        while r132 do
                            v3 = r134();
                            if v3 then
                                P = v1.FindFirstChild(v1, "Remotes");
                                if P then
                                    v3 = P.FindFirstChild(P, "UpgradePowerLevel");
                                end;
                                r135 = P;
                                B = r135;
                                v3 = r15;
                                if B then
                                    B = r135;
                                    v3 = B.IsA(B, "RemoteFunction");
                                end;
                                if v3 then
                                    v4 = r133;
                                    B = nil[2];
                                    o = nil[3];
                                    for o, v6 in ipairs(v3) do
                                        r136 = v6;
                                        v2 = o;
                                        v6 = 102;
                                        if not r15 then
                                            
                                        end; 
                                    end;
                                else
                                    task.wait(1);
                                end;
                                task.wait(.1);
                            else
                                task.wait(1);
                            end; 
                        end;
                        return; 
                    end);
                    return; 
                end;
                task.spawn(function(...)
                    while true do
                        task.wait(2);
                        if r104 then
                            v4 = r16("_\x04\xb0\r\xc6\xecx)4", 10765905515413);
                            v1 = r59[r15[v4]];
                            if v1 then
                                v1 = r59.Character;
                                v3 = v1.FindFirstChild(v1, "HumanoidRootPart");
                            end;
                            r137 = v1;
                            if r137 then
                                B = workspace;
                                J = "V\x8e\xf7";
                                T = r16(J, 15753946504360);
                                v7 = C[v1];
                                P = B.FindFirstChild(B, r15[T]) and B.FindFirstChild(B, "Sewer") or workspace;
                                v4 = P.GetDescendants;
                                o = {
                                    v4(P)
                                };
                                B = v4[3];
                                D = v4[2];
                                for B, v2 in ipairs(t("ipairs")) do
                                    v4 = B;
                                    r138 = v2;
                                    T = C[v7];
                                    J = T.IsA(T, "BasePart");
                                    if J then
                                        v7 = 93;
                                        v6 = C[v7].Name == "Lever" or string.find(string.lower(C[v7].Name), "lever", 1, true);
                                    end;
                                    if J then
                                        pcall(function(...)
                                            firetouchinterest(r137, C[v7], 0);
                                            firetouchinterest(r137, C[v7], 1);
                                            return; 
                                        end);
                                    end; 
                                end;
                            end;
                        end; 
                    end;
                    return; 
                end);
                task.spawn(function(...)
                    while true do
                        task.wait(10);
                        if r105 then
                            v1 = r59.Character;
                            v3 = 71;
                            if v1 then
                                v1 = r59.Character;
                                v3 = v1.FindFirstChild(v1, "HumanoidRootPart");
                            end;
                            r139 = v3;
                            P = workspace;
                            r140 = P.FindFirstChild(P, "Map") and P.FindFirstChild(P, "Sewer");
                            if r139 and r140 then
                                pcall(function(...)
                                    D = r140;
                                    v1 = D[2];
                                    P = D[3];
                                    D = "ipairs";
                                    for P, o in ipairs(D.GetDescendants(D)) do
                                        B = P;
                                        v2 = o.IsA(o, "BasePart");
                                        if v2 then
                                            v4 = string.find(string.lower(o.Name), "lever", 1, true);
                                        end;
                                        if v2 then
                                            firetouchinterest(r139, o, 0);
                                            firetouchinterest(r139, o, 1);
                                        end; 
                                    end;
                                    v7 = ipairs;
                                    o = "CashVine";
                                    v1 = o[1];
                                    P = o[2];
                                    for D, o in v7({
                                        o,
                                        "SewerAlien"
                                    }) do
                                        B = D;
                                        v7 = r140;
                                        if v7.FindFirstChild(v7, o) then
                                            A = v4.GetDescendants;
                                            T = A[3];
                                            v6 = A[2];
                                            for T, A in ipairs(A(v4)) do
                                                J = T;
                                                if A.IsA(A, "BasePart") and A.Name == "VineKey" then
                                                    firetouchinterest(r139, A, 0);
                                                    firetouchinterest(r139, A, 1);
                                                end; 
                                            end;
                                        end; 
                                    end;
                                    task.wait(.3);
                                    v7 = r140;
                                    o = r16(";\x1a\xcf\xe1\xfa@r\x1f", 28075493683985);
                                    v1 = v7.FindFirstChild(v7, r15[o]);
                                    if v1 then
                                        P = v1.FindFirstChild(v1, "VineDoor");
                                    end;
                                    if v1 then
                                        o = v1.VineDoor;
                                        v4 = {
                                            o.GetDescendants(o)
                                        };
                                        B = o[3];
                                        D = o[2];
                                        for B, v4 in ipairs(t(v4)) do
                                            o = B;
                                            if v4.IsA(v4, "BasePart") then
                                                firetouchinterest(r139, v4, 0);
                                                firetouchinterest(r139, v4, 1);
                                            end; 
                                        end;
                                    end;
                                    o = r16;
                                    task.wait(.3);
                                    if v1 then
                                        P = v1.FindFirstChild(v1, "CashVine");
                                    end;
                                    if v1 then
                                        B = v1.CashVine;
                                        r139.CFrame = B.GetPivot(B) + Vector3.new(0, 3, 0);
                                        task.wait(.2);
                                        o = v1.CashVine;
                                        v4 = {
                                            o.GetDescendants(o)
                                        };
                                        D = o[2];
                                        B = o[3];
                                        for B, v4 in ipairs(t(v4)) do
                                            o = B;
                                            if v4.IsA(v4, "BasePart") then
                                                firetouchinterest(r139, v4, 0);
                                                firetouchinterest(r139, v4, 1);
                                            end; 
                                        end;
                                    end;
                                    return; 
                                end);
                            end;
                        end; 
                    end;
                    return; 
                end);
                task.delay(2, function(...)
                    if r73 then
                        r73("Discord", "Prompting join...", 3, r60.Accent);
                    end;
                    r82("yrVfhkvdAb");
                    return; 
                end);
                r73("\xe2\x9c\x85 Tuna Scripts V2 Loaded", "Successfully migrated Sell Lemons.", 4, r60.Accent);
                r73("\xe2\x9c\x85 Tuna Scripts V2 Loaded", "Successfully migrated Sell Lemons.", 4, r60.Accent);
            else
                r54.Text = "STATUS: INVALID KEY";
                r52.Text = "FAILED";
                task.wait(2);
                r52.Text = "VERIFY ACCESS";
                r54.Text = "STATUS: WAITING CONNECTION";
            end;
            return; 
        end);
        local function PP(...)
            P = isfile;
            v3 = P;
            if P then
                v3 = isfile(r29);
            end;
            v7 = v7;
            if not v3 then
                warn("No saved key found.");
                return;
            end;
            v7 = not r37(r30(readfile(r29)));
            if v7 then
                warn("Saved key is invalid.");
                return;
            end;
            P = syn and syn.queue_on_teleport;
            v7 = v7;
            v3 = P;
            if P then
            end; 
        end;
        return;
    end;
end;
return (function(...)
    while true do
        l1 = l2;
        l2 = l1;
        r3(); 
    end;
    return; 
end)();
