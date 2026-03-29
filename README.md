local _ = (table and 10296932); -- 10296932
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer
_G.NexHubInstantStealLoaded = true
local Vector3_New = Vector3.new
local Vector3_Value = Vector3_New(-481.88, -3.79, 138.02)
local Vector3_Value_2 = Vector3_New(-481.75, -3.79, 89.18)
local Vector3_Value_3 = Vector3_New(-481.82, -3.79, 30.95)
local Vector3_Value_4 = Vector3_New(-481.75, -3.79, -17.79)
local Vector3_Value_5 = Vector3_New(-481.8, -3.79, -76.06)
local Vector3_Value_6 = Vector3_New(-481.72, -3.79, -124.7)
local Vector3_Value_7 = Vector3_New(-337.45, -3.85, -124.72)
local Vector3_Value_8 = Vector3_New(-337.37, -3.85, -76.07)
local Vector3_Value_9 = Vector3_New(-337.46, -3.79, -17.72)
local Vector3_Value_10 = Vector3_New(-337.41, -3.79, 30.92)
local Vector3_Value_11 = Vector3_New(-337.32, -3.79, 89.02)
local Vector3_Value_12 = Vector3_New(-337.27, -3.79, 137.9)
local Vector3_Value_13 = Vector3_New(-337.45, -3.79, 196.29)
local Vector3_Value_14 = Vector3_New(-337.37, -3.79, 244.91)
local Vector3_Value_15 = Vector3_New(-481.72, -3.79, 196.21)
local Vector3_Value_16 = Vector3_New(-481.76, -3.79, 244.92)
local TokinuHubGalaxy = Instance.new("ScreenGui")
TokinuHubGalaxy.Name = "TokinuHubGalaxy"
TokinuHubGalaxy.ResetOnSpawn = false
TokinuHubGalaxy.Parent = LocalPlayer:WaitForChild("PlayerGui")
local Frame = Instance.new("Frame")
local UDim2_New = UDim2.new
Frame.Size = UDim2_New(0, 290, 0, 320)
Frame.Position = UDim2_New(0, 40, 0, 60)
local Color3_FromRGB = Color3.fromRGB
Frame.BackgroundColor3 = Color3_FromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.1
Frame.Active = true
Frame.Draggable = true
Frame.Parent = TokinuHubGalaxy
local UICorner = Instance.new("UICorner")
local UDim_New = UDim.new
UICorner.CornerRadius = UDim_New(0, 14)
UICorner.Parent = Frame
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3_FromRGB(60, 60, 60)
UIStroke.Thickness = 2
UIStroke.Parent = Frame
local Frame_2 = Instance.new("Frame")
Frame_2.Size = UDim2_New(1, 0, 1, 0)
Frame_2.BackgroundTransparency = 1
Frame_2.ClipsDescendants = true
Frame_2.Parent = Frame
local Frame_3 = Instance.new("Frame")
Frame_3.Size = UDim2_New(0, 3, 0, 3)
Frame_3.Position = UDim2_New(0.3915959502220725, 0, -0.05, 0)
Frame_3.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_3.BorderSizePixel = 0
local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim_New(0, 1.5)
UICorner_2.Parent = Frame_3
Frame_3.BackgroundTransparency = 0
Frame_3.Parent = Frame_2
local Frame_4 = Instance.new("Frame")
Frame_4.Size = UDim2_New(0, 3, 0, 3)
Frame_4.Position = UDim2_New(0.011758403687615679, 0, -0.05, 0)
Frame_4.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_4.BorderSizePixel = 0
local UICorner_3 = Instance.new("UICorner")
UICorner_3.CornerRadius = UDim_New(0, 1.5)
UICorner_3.Parent = Frame_4
Frame_4.BackgroundTransparency = 0
Frame_4.Parent = Frame_2
local Frame_5 = Instance.new("Frame")
Frame_5.Size = UDim2_New(0, 2, 0, 2)
Frame_5.Position = UDim2_New(0.7449944026798135, 0, -0.05, 0)
Frame_5.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_5.BorderSizePixel = 0
local UICorner_4 = Instance.new("UICorner")
UICorner_4.CornerRadius = UDim_New(0, 1)
UICorner_4.Parent = Frame_5
Frame_5.BackgroundTransparency = 0
Frame_5.Parent = Frame_2
local Frame_6 = Instance.new("Frame")
Frame_6.Size = UDim2_New(0, 2, 0, 2)
Frame_6.Position = UDim2_New(0.15713792819990752, 0, -0.05, 0)
Frame_6.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_6.BorderSizePixel = 0
local UICorner_5 = Instance.new("UICorner")
UICorner_5.CornerRadius = UDim_New(0, 1)
UICorner_5.Parent = Frame_6
Frame_6.BackgroundTransparency = 0
Frame_6.Parent = Frame_2
local Frame_7 = Instance.new("Frame")
Frame_7.Size = UDim2_New(0, 3, 0, 3)
Frame_7.Position = UDim2_New(0.5923113108026085, 0, -0.05, 0)
Frame_7.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_7.BorderSizePixel = 0
local UICorner_6 = Instance.new("UICorner")
UICorner_6.CornerRadius = UDim_New(0, 1.5)
UICorner_6.Parent = Frame_7
Frame_7.BackgroundTransparency = 0
Frame_7.Parent = Frame_2
local Frame_8 = Instance.new("Frame")
Frame_8.Size = UDim2_New(0, 1, 0, 1)
Frame_8.Position = UDim2_New(0.15334659248143062, 0, -0.05, 0)
Frame_8.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_8.BorderSizePixel = 0
local UICorner_7 = Instance.new("UICorner")
UICorner_7.CornerRadius = UDim_New(0, 0.5)
UICorner_7.Parent = Frame_8
Frame_8.BackgroundTransparency = 0
Frame_8.Parent = Frame_2
local Frame_9 = Instance.new("Frame")
Frame_9.Size = UDim2_New(0, 2, 0, 2)
Frame_9.Position = UDim2_New(0.7852788577421553, 0, -0.05, 0)
Frame_9.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_9.BorderSizePixel = 0
local UICorner_8 = Instance.new("UICorner")
UICorner_8.CornerRadius = UDim_New(0, 1)
UICorner_8.Parent = Frame_9
Frame_9.BackgroundTransparency = 0
Frame_9.Parent = Frame_2
local Frame_10 = Instance.new("Frame")
Frame_10.Size = UDim2_New(0, 3, 0, 3)
Frame_10.Position = UDim2_New(0.37043698521672136, 0, -0.05, 0)
Frame_10.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_10.BorderSizePixel = 0
local UICorner_9 = Instance.new("UICorner")
UICorner_9.CornerRadius = UDim_New(0, 1.5)
UICorner_9.Parent = Frame_10
Frame_10.BackgroundTransparency = 0
Frame_10.Parent = Frame_2
local Frame_11 = Instance.new("Frame")
Frame_11.Size = UDim2_New(0, 2, 0, 2)
Frame_11.Position = UDim2_New(0.1097950259286395, 0, -0.05, 0)
Frame_11.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_11.BorderSizePixel = 0
local UICorner_10 = Instance.new("UICorner")
UICorner_10.CornerRadius = UDim_New(0, 1)
UICorner_10.Parent = Frame_11
Frame_11.BackgroundTransparency = 0
Frame_11.Parent = Frame_2
local Frame_12 = Instance.new("Frame")
Frame_12.Size = UDim2_New(0, 3, 0, 3)
Frame_12.Position = UDim2_New(0.6233408806447512, 0, -0.05, 0)
Frame_12.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_12.BorderSizePixel = 0
local UICorner_11 = Instance.new("UICorner")
UICorner_11.CornerRadius = UDim_New(0, 1.5)
UICorner_11.Parent = Frame_12
Frame_12.BackgroundTransparency = 0
Frame_12.Parent = Frame_2
local Frame_13 = Instance.new("Frame")
Frame_13.Size = UDim2_New(0, 1, 0, 1)
Frame_13.Position = UDim2_New(0.018677739170475806, 0, -0.05, 0)
Frame_13.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_13.BorderSizePixel = 0
local UICorner_12 = Instance.new("UICorner")
UICorner_12.CornerRadius = UDim_New(0, 0.5)
UICorner_12.Parent = Frame_13
Frame_13.BackgroundTransparency = 0
Frame_13.Parent = Frame_2
local Frame_14 = Instance.new("Frame")
Frame_14.Size = UDim2_New(0, 2, 0, 2)
Frame_14.Position = UDim2_New(0.8552393061567409, 0, -0.05, 0)
Frame_14.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_14.BorderSizePixel = 0
local UICorner_13 = Instance.new("UICorner")
UICorner_13.CornerRadius = UDim_New(0, 1)
UICorner_13.Parent = Frame_14
Frame_14.BackgroundTransparency = 0
Frame_14.Parent = Frame_2
local Frame_15 = Instance.new("Frame")
Frame_15.Size = UDim2_New(0, 1, 0, 1)
Frame_15.Position = UDim2_New(0.7210255550663837, 0, -0.05, 0)
Frame_15.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_15.BorderSizePixel = 0
local UICorner_14 = Instance.new("UICorner")
UICorner_14.CornerRadius = UDim_New(0, 0.5)
UICorner_14.Parent = Frame_15
Frame_15.BackgroundTransparency = 0
Frame_15.Parent = Frame_2
local Frame_16 = Instance.new("Frame")
Frame_16.Size = UDim2_New(0, 3, 0, 3)
Frame_16.Position = UDim2_New(0.5281794010925444, 0, -0.05, 0)
Frame_16.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_16.BorderSizePixel = 0
local UICorner_15 = Instance.new("UICorner")
UICorner_15.CornerRadius = UDim_New(0, 1.5)
UICorner_15.Parent = Frame_16
Frame_16.BackgroundTransparency = 0
Frame_16.Parent = Frame_2
local Frame_17 = Instance.new("Frame")
Frame_17.Size = UDim2_New(0, 2, 0, 2)
Frame_17.Position = UDim2_New(0.6066427963208199, 0, -0.05, 0)
Frame_17.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_17.BorderSizePixel = 0
local UICorner_16 = Instance.new("UICorner")
UICorner_16.CornerRadius = UDim_New(0, 1)
UICorner_16.Parent = Frame_17
Frame_17.BackgroundTransparency = 0
Frame_17.Parent = Frame_2
local Frame_18 = Instance.new("Frame")
Frame_18.Size = UDim2_New(0, 3, 0, 3)
Frame_18.Position = UDim2_New(0.9344961312020973, 0, -0.05, 0)
Frame_18.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_18.BorderSizePixel = 0
local UICorner_17 = Instance.new("UICorner")
UICorner_17.CornerRadius = UDim_New(0, 1.5)
UICorner_17.Parent = Frame_18
Frame_18.BackgroundTransparency = 0
Frame_18.Parent = Frame_2
local Frame_19 = Instance.new("Frame")
Frame_19.Size = UDim2_New(0, 3, 0, 3)
Frame_19.Position = UDim2_New(0.8358853406086781, 0, -0.05, 0)
Frame_19.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_19.BorderSizePixel = 0
local UICorner_18 = Instance.new("UICorner")
UICorner_18.CornerRadius = UDim_New(0, 1.5)
UICorner_18.Parent = Frame_19
Frame_19.BackgroundTransparency = 0
Frame_19.Parent = Frame_2
local Frame_20 = Instance.new("Frame")
Frame_20.Size = UDim2_New(0, 1, 0, 1)
Frame_20.Position = UDim2_New(0.0845517293464138, 0, -0.05, 0)
Frame_20.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_20.BorderSizePixel = 0
local UICorner_19 = Instance.new("UICorner")
UICorner_19.CornerRadius = UDim_New(0, 0.5)
UICorner_19.Parent = Frame_20
Frame_20.BackgroundTransparency = 0
Frame_20.Parent = Frame_2
local Frame_21 = Instance.new("Frame")
Frame_21.Size = UDim2_New(0, 1, 0, 1)
Frame_21.Position = UDim2_New(0.7647932699235869, 0, -0.05, 0)
Frame_21.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_21.BorderSizePixel = 0
local UICorner_20 = Instance.new("UICorner")
UICorner_20.CornerRadius = UDim_New(0, 0.5)
UICorner_20.Parent = Frame_21
Frame_21.BackgroundTransparency = 0
Frame_21.Parent = Frame_2
local Frame_22 = Instance.new("Frame")
Frame_22.Size = UDim2_New(0, 3, 0, 3)
Frame_22.Position = UDim2_New(0.6481668549655445, 0, -0.05, 0)
Frame_22.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_22.BorderSizePixel = 0
local UICorner_21 = Instance.new("UICorner")
UICorner_21.CornerRadius = UDim_New(0, 1.5)
UICorner_21.Parent = Frame_22
Frame_22.BackgroundTransparency = 0
Frame_22.Parent = Frame_2
local Frame_23 = Instance.new("Frame")
Frame_23.Size = UDim2_New(0, 3, 0, 3)
Frame_23.Position = UDim2_New(0.7613350005951511, 0, -0.05, 0)
Frame_23.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_23.BorderSizePixel = 0
local UICorner_22 = Instance.new("UICorner")
UICorner_22.CornerRadius = UDim_New(0, 1.5)
UICorner_22.Parent = Frame_23
Frame_23.BackgroundTransparency = 0
Frame_23.Parent = Frame_2
local Frame_24 = Instance.new("Frame")
Frame_24.Size = UDim2_New(0, 2, 0, 2)
Frame_24.Position = UDim2_New(0.060253437568659564, 0, -0.05, 0)
Frame_24.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_24.BorderSizePixel = 0
local UICorner_23 = Instance.new("UICorner")
UICorner_23.CornerRadius = UDim_New(0, 1)
UICorner_23.Parent = Frame_24
Frame_24.BackgroundTransparency = 0
Frame_24.Parent = Frame_2
local Frame_25 = Instance.new("Frame")
Frame_25.Size = UDim2_New(0, 3, 0, 3)
Frame_25.Position = UDim2_New(0.12371431330383423, 0, -0.05, 0)
Frame_25.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_25.BorderSizePixel = 0
local UICorner_24 = Instance.new("UICorner")
UICorner_24.CornerRadius = UDim_New(0, 1.5)
UICorner_24.Parent = Frame_25
Frame_25.BackgroundTransparency = 0
Frame_25.Parent = Frame_2
local Frame_26 = Instance.new("Frame")
Frame_26.Size = UDim2_New(0, 3, 0, 3)
Frame_26.Position = UDim2_New(0.267892961474857, 0, -0.05, 0)
Frame_26.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_26.BorderSizePixel = 0
local UICorner_25 = Instance.new("UICorner")
UICorner_25.CornerRadius = UDim_New(0, 1.5)
UICorner_25.Parent = Frame_26
Frame_26.BackgroundTransparency = 0
Frame_26.Parent = Frame_2
local Frame_27 = Instance.new("Frame")
Frame_27.Size = UDim2_New(0, 3, 0, 3)
Frame_27.Position = UDim2_New(0.9556834278264253, 0, -0.05, 0)
Frame_27.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_27.BorderSizePixel = 0
local UICorner_26 = Instance.new("UICorner")
UICorner_26.CornerRadius = UDim_New(0, 1.5)
UICorner_26.Parent = Frame_27
Frame_27.BackgroundTransparency = 0
Frame_27.Parent = Frame_2
local Frame_28 = Instance.new("Frame")
Frame_28.Size = UDim2_New(0, 1, 0, 1)
Frame_28.Position = UDim2_New(0.9898206847457534, 0, -0.05, 0)
Frame_28.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_28.BorderSizePixel = 0
local UICorner_27 = Instance.new("UICorner")
UICorner_27.CornerRadius = UDim_New(0, 0.5)
UICorner_27.Parent = Frame_28
Frame_28.BackgroundTransparency = 0
Frame_28.Parent = Frame_2
local Frame_29 = Instance.new("Frame")
Frame_29.Size = UDim2_New(0, 2, 0, 2)
Frame_29.Position = UDim2_New(0.1401932837037589, 0, -0.05, 0)
Frame_29.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_29.BorderSizePixel = 0
local UICorner_28 = Instance.new("UICorner")
UICorner_28.CornerRadius = UDim_New(0, 1)
UICorner_28.Parent = Frame_29
Frame_29.BackgroundTransparency = 0
Frame_29.Parent = Frame_2
local Frame_30 = Instance.new("Frame")
Frame_30.Size = UDim2_New(0, 3, 0, 3)
Frame_30.Position = UDim2_New(0.9946287908705298, 0, -0.05, 0)
Frame_30.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_30.BorderSizePixel = 0
local UICorner_29 = Instance.new("UICorner")
UICorner_29.CornerRadius = UDim_New(0, 1.5)
UICorner_29.Parent = Frame_30
Frame_30.BackgroundTransparency = 0
Frame_30.Parent = Frame_2
local Frame_31 = Instance.new("Frame")
Frame_31.Size = UDim2_New(0, 3, 0, 3)
Frame_31.Position = UDim2_New(0.23613664412234203, 0, -0.05, 0)
Frame_31.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_31.BorderSizePixel = 0
local UICorner_30 = Instance.new("UICorner")
UICorner_30.CornerRadius = UDim_New(0, 1.5)
UICorner_30.Parent = Frame_31
Frame_31.BackgroundTransparency = 0
Frame_31.Parent = Frame_2
local Frame_32 = Instance.new("Frame")
Frame_32.Size = UDim2_New(0, 1, 0, 1)
Frame_32.Position = UDim2_New(0.7929423001959038, 0, -0.05, 0)
Frame_32.BackgroundColor3 = Color3_FromRGB(255, 255, 255)
Frame_32.BorderSizePixel = 0
local UICorner_31 = Instance.new("UICorner")
UICorner_31.CornerRadius = UDim_New(0, 0.5)
UICorner_31.Parent = Frame_32
Frame_32.BackgroundTransparency = 0
Frame_32.Parent = Frame_2
local Connection
Connection = game:GetService("RunService").RenderStepped:Connect(function(DeltaTime, p2_0, p3_0, p4_0) -- args: DeltaTime_2
    local var12 = -0.05000000074505806 + 0.21 * DeltaTime
    -- 371282084.268593
    Frame_32.Position = UDim2_New(0.7928971132045873, 0, var12, 0)
    local _ = (var12 > 1.2); -- nil
    local var17 = -0.05000000074505806 + 0.31 * DeltaTime
    -- 548083076.782102
    Frame_31.Position = UDim2_New(0.2355231736311531, 0, var17, 0)
    local _ = (var17 > 1.2); -- nil
    local var22 = -0.05000000074505806 + 0.32 * DeltaTime
    -- 565763176.037178
    Frame_30.Position = UDim2_New(0.995141539524072, 0, var22, 0)
    local _ = (var22 > 1.2); -- nil
    local var27 = -0.05000000074505806 + 0.39 * DeltaTime
    -- 689523870.800067
    Frame_29.Position = UDim2_New(0.14068771535502267, 0, var27, 0)
    local _ = (var27 > 1.2); -- nil
    local var32 = -0.05000000074505806 + 0.33 * DeltaTime
    -- 583443275.296235
    Frame_28.Position = UDim2_New(0.9908061747529154, 0, var32, 0)
    local _ = (var32 > 1.2); -- nil
    local var37 = -0.05000000074505806 + 0.39 * DeltaTime
    -- 689523870.809429
    Frame_27.Position = UDim2_New(0.9561696826190124, 0, var37, 0)
    local _ = (var37 > 1.2); -- nil
    local var42 = -0.05000000074505806 + 0.33 * DeltaTime
    -- 583443275.304330
    Frame_26.Position = UDim2_New(0.2688770673208513, 0, var42, 0)
    local _ = (var42 > 1.2); -- nil
    local var47 = -0.05000000074505806 + 0.2 * DeltaTime
    -- 353601985.035453
    Frame_25.Position = UDim2_New(0.12277449838194895, 0, var47, 0)
    local _ = (var47 > 1.2); -- nil
    local var52 = -0.05000000074505806 + 0.49 * DeltaTime
    -- 866324863.343120
    Frame_24.Position = UDim2_New(0.06114595609901006, 0, var52, 0)
    local _ = (var52 > 1.2); -- nil
    local var57 = -0.05000000074505806 + 0.22 * DeltaTime
    -- 388962183.544569
    Frame_23.Position = UDim2_New(0.7622575310426004, 0, var57, 0)
    local _ = (var57 > 1.2); -- nil
    local var62 = -0.05000000074505806 + 0.31 * DeltaTime
    -- 548083076.816596
    Frame_22.Position = UDim2_New(0.6475809644001346, 0, var62, 0)
    local _ = (var62 > 1.2); -- nil
    local var67 = -0.05000000074505806 + 0.5 * DeltaTime
    -- 884004962.613746
    Frame_21.Position = UDim2_New(0.7646820200339525, 0, var67, 0)
    local _ = (var67 > 1.2); -- nil
    local var72 = -0.05000000074505806 + 0.36 * DeltaTime
    -- 636483573.087131
    Frame_20.Position = UDim2_New(0.08375624622241543, 0, var72, 0)
    local _ = (var72 > 1.2); -- nil
    local var77 = -0.05000000074505806 + 0.37 * DeltaTime
    -- 654163672.344855
    Frame_19.Position = UDim2_New(0.8361633151149427, 0, var77, 0)
    local _ = (var77 > 1.2); -- nil
    local var82 = -0.05000000074505806 + 0.26 * DeltaTime
    -- 459682580.570573
    Frame_18.Position = UDim2_New(0.9341933399945902, 0, var82, 0)
    local _ = (var82 > 1.2); -- nil
    local var87 = -0.05000000074505806 + 0.49 * DeltaTime
    -- 866324863.390635
    Frame_17.Position = UDim2_New(0.6075128718920291, 0, var87, 0)
    local _ = (var87 > 1.2); -- nil
    local var92 = -0.05000000074505806 + 0.32 * DeltaTime
    -- 565763176.096491
    Frame_16.Position = UDim2_New(0.5287421505967279, 0, var92, 0)
    local _ = (var92 > 1.2); -- nil
    local var97 = -0.05000000074505806 + 0.23 * DeltaTime
    -- 406642282.822586
    Frame_15.Position = UDim2_New(0.7217036943568261, 0, var97, 0)
    local _ = (var97 > 1.2); -- nil
    local var102 = -0.05000000074505806 + 0.35 * DeltaTime
    -- 618803473.865323
    Frame_14.Position = UDim2_New(0.8543688303413434, 0, var102, 0)
    local _ = (var102 > 1.2); -- nil
    local var107 = -0.05000000074505806 + 0.41 * DeltaTime
    -- 724884069.390823
    Frame_13.Position = UDim2_New(0.017752943962714058, 0, var107, 0)
    local _ = (var107 > 1.2); -- nil
    local var112 = -0.05000000074505806 + 0.23 * DeltaTime
    -- 406642282.832128
    Frame_12.Position = UDim2_New(0.6240120295696088, 0, var112, 0)
    local _ = (var112 > 1.2); -- nil
    local var117 = -0.05000000074505806 + 0.42 * DeltaTime
    -- 742564168.655769
    Frame_11.Position = UDim2_New(0.10982323088059961, 0, var117, 0)
    local _ = (var117 > 1.2); -- nil
    local var122 = -0.05000000074505806 + 0.47 * DeltaTime
    -- 830964664.930460
    Frame_10.Position = UDim2_New(0.37017848026733857, 0, var122, 0)
    local _ = (var122 > 1.2); -- nil
    local var127 = -0.05000000074505806 + 0.47 * DeltaTime
    -- 830964664.936289
    Frame_9.Position = UDim2_New(0.7850259758768202, 0, var127, 0)
    local _ = (var127 > 1.2); -- nil
    local var132 = -0.05000000074505806 + 0.3 * DeltaTime
    -- 530402977.622799
    Frame_8.Position = UDim2_New(0.15236511025066812, 0, var132, 0)
    local _ = (var132 > 1.2); -- nil
    local var137 = -0.05000000074505806 + 0.3 * DeltaTime
    -- 530402977.626527
    Frame_7.Position = UDim2_New(0.5913291277732109, 0, var137, 0)
    local _ = (var137 > 1.2); -- nil
    local var142 = -0.05000000074505806 + 0.42 * DeltaTime
    -- 742564168.682316
    Frame_6.Position = UDim2_New(0.1571926578941372, 0, var142, 0)
    local _ = (var142 > 1.2); -- nil
    local var147 = -0.05000000074505806 + 0.48 * DeltaTime
    -- 848644764.214317
    Frame_5.Position = UDim2_New(0.7458170944307861, 0, var147, 0)
    local _ = (var147 > 1.2); -- nil
    local var152 = -0.05000000074505806 + 0.31 * DeltaTime
    -- 548083076.892640
    Frame_4.Position = UDim2_New(0.011235792863354624, 0, var152, 0)
    local _ = (var152 > 1.2); -- nil
    local var157 = -0.05000000074505806 + 0.46 * DeltaTime
    -- 813284565.717139
    Frame_3.Position = UDim2_New(0.3906075241544038, 0, var157, 0)
    local _ = (var157 > 1.2); -- nil
end)
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2_New(1, -20, 0, 30)
TextLabel.Position = UDim2_New(0, 10, 0, 8)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "tokinu hub - not main instant steal"
TextLabel.TextColor3 = Color3_FromRGB(255, 255, 255)
local Enum_Font = Enum.Font
TextLabel.Font = Enum_Font.GothamBlack
TextLabel.TextSize = 18
local Enum_TextXAlignment = Enum.TextXAlignment
TextLabel.TextXAlignment = Enum_TextXAlignment.Center
TextLabel.Parent = Frame
local TextLabel_2 = Instance.new("TextLabel")
TextLabel_2.Size = UDim2_New(1, -20, 0, 20)
TextLabel_2.Position = UDim2_New(0, 10, 0, 40)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.Text = "ready"
TextLabel_2.TextColor3 = Color3_FromRGB(180, 180, 180)
TextLabel_2.Font = Enum_Font.Gotham
TextLabel_2.TextSize = 12
TextLabel_2.TextXAlignment = Enum_TextXAlignment.Center
TextLabel_2.Parent = Frame
local _ = task.spawn(function(p1_0)
    local Waited_For = task.wait(1);
    local Character = LocalPlayer.Character;
    if Character then -- ran, expr id 1, has an else.
        local Character_2 = LocalPlayer.Character;
    end
    local HumanoidRootPart = Character_2:FindFirstChild("HumanoidRootPart");
    if HumanoidRootPart then -- ran, expr id 2, has an else.
        local Position_61 = HumanoidRootPart.Position;
        local var161 = Position_61 - Vector3_Value;
    end
    local Magnitude = var161.Magnitude;
    local var162 = (Magnitude < math.huge); -- nil
    local Position_62 = HumanoidRootPart.Position;
    local var163 = Position_62 - Vector3_Value_2;
    local Magnitude_2 = var163.Magnitude;
    local var164 = (Magnitude_2 < math.huge); -- nil
    local Position_63 = HumanoidRootPart.Position;
    local var165 = Position_63 - Vector3_Value_3;
    local Magnitude_3 = var165.Magnitude;
    local var166 = (Magnitude_3 < math.huge); -- nil
    local Position_64 = HumanoidRootPart.Position;
    local var167 = Position_64 - Vector3_Value_4;
    local Magnitude_4 = var167.Magnitude;
    local var168 = (Magnitude_4 < math.huge); -- nil
    local Position_65 = HumanoidRootPart.Position;
    local var169 = Position_65 - Vector3_Value_5;
    local Magnitude_5 = var169.Magnitude;
    local var170 = (Magnitude_5 < math.huge); -- nil
    local Position_66 = HumanoidRootPart.Position;
    local var171 = Position_66 - Vector3_Value_6;
    local Magnitude_6 = var171.Magnitude;
    local var172 = (Magnitude_6 < math.huge); -- nil
    local Position_67 = HumanoidRootPart.Position;
    local var173 = Position_67 - Vector3_Value_7;
    local Magnitude_7 = var173.Magnitude;
    local var174 = (Magnitude_7 < math.huge); -- nil
    local Position_68 = HumanoidRootPart.Position;
    local var175 = Position_68 - Vector3_Value_8;
    local Magnitude_8 = var175.Magnitude;
    local var176 = (Magnitude_8 < math.huge); -- nil
    local Position_69 = HumanoidRootPart.Position;
    local var177 = Position_69 - Vector3_Value_9;
    local Magnitude_9 = var177.Magnitude;
    local var178 = (Magnitude_9 < math.huge); -- nil
    local Position_70 = HumanoidRootPart.Position;
    local var179 = Position_70 - Vector3_Value_10;
    local Magnitude_10 = var179.Magnitude;
    local var180 = (Magnitude_10 < math.huge); -- nil
    local Position_71 = HumanoidRootPart.Position;
    local var181 = Position_71 - Vector3_Value_11;
    local Magnitude_11 = var181.Magnitude;
    local var182 = (Magnitude_11 < math.huge); -- nil
    local Position_72 = HumanoidRootPart.Position;
    local var183 = Position_72 - Vector3_Value_12;
    local Magnitude_12 = var183.Magnitude;
    local var184 = (Magnitude_12 < math.huge); -- nil
    local Position_73 = HumanoidRootPart.Position;
    local var185 = Position_73 - Vector3_Value_13;
    local Magnitude_13 = var185.Magnitude;
    local var186 = (Magnitude_13 < math.huge); -- nil
    local Position_74 = HumanoidRootPart.Position;
    local var187 = Position_74 - Vector3_Value_14;
    local Magnitude_14 = var187.Magnitude;
    local var188 = (Magnitude_14 < math.huge); -- nil
    local Position_75 = HumanoidRootPart.Position;
    local var189 = Position_75 - Vector3_Value_15;
    local Magnitude_15 = var189.Magnitude;
    local var190 = (Magnitude_15 < math.huge); -- nil
    local Position_76 = HumanoidRootPart.Position;
    local var191 = Position_76 - Vector3_Value_16;
    local Magnitude_16 = var191.Magnitude;
    local var192 = (Magnitude_16 < math.huge); -- nil
    local Waited_For_2 = task.wait(1);
    local Character_3 = LocalPlayer.Character;
    if Character_3 then -- ran, expr id 3, has an else.
        local Character_4 = LocalPlayer.Character;
    end
    local HumanoidRootPart_2 = Character_4:FindFirstChild("HumanoidRootPart");
    if HumanoidRootPart_2 then -- ran, expr id 4, has an else.
        local Position_77 = HumanoidRootPart_2.Position;
        local var193 = Position_77 - Vector3_Value;
    end
    local Magnitude_17 = var193.Magnitude;
    local var194 = (Magnitude_17 < math.huge); -- nil
    local Position_78 = HumanoidRootPart_2.Position;
    local var195 = Position_78 - Vector3_Value_2;
    local Magnitude_18 = var195.Magnitude;
    local var196 = (Magnitude_18 < math.huge); -- nil
    local Position_79 = HumanoidRootPart_2.Position;
    local var197 = Position_79 - Vector3_Value_3;
    local Magnitude_19 = var197.Magnitude;
    local var198 = (Magnitude_19 < math.huge); -- nil
    local Position_80 = HumanoidRootPart_2.Position;
    local var199 = Position_80 - Vector3_Value_4;
    local Magnitude_20 = var199.Magnitude;
    local var200 = (Magnitude_20 < math.huge); -- nil
    local Position_81 = HumanoidRootPart_2.Position;
    local var201 = Position_81 - Vector3_Value_5;
    local Magnitude_21 = var201.Magnitude;
    local var202 = (Magnitude_21 < math.huge); -- nil
    local Position_82 = HumanoidRootPart_2.Position;
    local var203 = Position_82 - Vector3_Value_6;
    local Magnitude_22 = var203.Magnitude;
    local var204 = (Magnitude_22 < math.huge); -- nil
    local Position_83 = HumanoidRootPart_2.Position;
    local var205 = Position_83 - Vector3_Value_7;
    local Magnitude_23 = var205.Magnitude;
    local var206 = (Magnitude_23 < math.huge); -- nil
    local Position_84 = HumanoidRootPart_2.Position;
    local var207 = Position_84 - Vector3_Value_8;
    local Magnitude_24 = var207.Magnitude;
    local var208 = (Magnitude_24 < math.huge); -- nil
    local Position_85 = HumanoidRootPart_2.Position;
    local var209 = Position_85 - Vector3_Value_9;
    local Magnitude_25 = var209.Magnitude;
    local var210 = (Magnitude_25 < math.huge); -- nil
    local Position_86 = HumanoidRootPart_2.Position;
    local var211 = Position_86 - Vector3_Value_10;
    local Magnitude_26 = var211.Magnitude;
    local var212 = (Magnitude_26 < math.huge); -- nil
    local Position_87 = HumanoidRootPart_2.Position;
    local var213 = Position_87 - Vector3_Value_11;
    local Magnitude_27 = var213.Magnitude;
    local var214 = (Magnitude_27 < math.huge); -- nil
    local Position_88 = HumanoidRootPart_2.Position;
    local var215 = Position_88 - Vector3_Value_12;
    local Magnitude_28 = var215.Magnitude;
    local var216 = (Magnitude_28 < math.huge); -- nil
    local Position_89 = HumanoidRootPart_2.Position;
    local var217 = Position_89 - Vector3_Value_13;
    local Magnitude_29 = var217.Magnitude;
    local var218 = (Magnitude_29 < math.huge); -- nil
    local Position_90 = HumanoidRootPart_2.Position;
    local var219 = Position_90 - Vector3_Value_14;
    local Magnitude_30 = var219.Magnitude;
    local var220 = (Magnitude_30 < math.huge); -- nil
    local Position_91 = HumanoidRootPart_2.Position;
    local var221 = Position_91 - Vector3_Value_15;
    local Magnitude_31 = var221.Magnitude;
    local var222 = (Magnitude_31 < math.huge); -- nil
    local Position_92 = HumanoidRootPart_2.Position;
    local var223 = Position_92 - Vector3_Value_16;
    local Magnitude_32 = var223.Magnitude;
    local var224 = (Magnitude_32 < math.huge); -- nil
    local Waited_For_3 = task.wait(1);
    local Character_5 = LocalPlayer.Character;
    if Character_5 then -- ran, expr id 5, has an else.
        local Character_6 = LocalPlayer.Character;
    end
    local HumanoidRootPart_3 = Character_6:FindFirstChild("HumanoidRootPart");
    if HumanoidRootPart_3 then -- ran, expr id 6, has an else.
        local Position_93 = HumanoidRootPart_3.Position;
        local var225 = Position_93 - Vector3_Value;
    end
    local Magnitude_33 = var225.Magnitude;
    local var226 = (Magnitude_33 < math.huge); -- nil
    local Position_94 = HumanoidRootPart_3.Position;
    local var227 = Position_94 - Vector3_Value_2;
    local Magnitude_34 = var227.Magnitude;
    local var228 = (Magnitude_34 < math.huge); -- nil
    local Position_95 = HumanoidRootPart_3.Position;
    local var229 = Position_95 - Vector3_Value_3;
    local Magnitude_35 = var229.Magnitude;
    local var230 = (Magnitude_35 < math.huge); -- nil
    local Position_96 = HumanoidRootPart_3.Position;
    local var231 = Position_96 - Vector3_Value_4;
    local Magnitude_36 = var231.Magnitude;
    local var232 = (Magnitude_36 < math.huge); -- nil
    local Position_97 = HumanoidRootPart_3.Position;
    local var233 = Position_97 - Vector3_Value_5;
    local Magnitude_37 = var233.Magnitude;
    local var234 = (Magnitude_37 < math.huge); -- nil
    local Position_98 = HumanoidRootPart_3.Position;
    local var235 = Position_98 - Vector3_Value_6;
    local Magnitude_38 = var235.Magnitude;
    local var236 = (Magnitude_38 < math.huge); -- nil
    local Position_99 = HumanoidRootPart_3.Position;
    local var237 = Position_99 - Vector3_Value_7;
    local Magnitude_39 = var237.Magnitude;
    local var238 = (Magnitude_39 < math.huge); -- nil
    local Position_100 = HumanoidRootPart_3.Position;
    local var239 = Position_100 - Vector3_Value_8;
    local Magnitude_40 = var239.Magnitude;
    local var240 = (Magnitude_40 < math.huge); -- nil
    local Position_101 = HumanoidRootPart_3.Position;
    local var241 = Position_101 - Vector3_Value_9;
    local Magnitude_41 = var241.Magnitude;
    local var242 = (Magnitude_41 < math.huge); -- nil
    local Position_102 = HumanoidRootPart_3.Position;
    local var243 = Position_102 - Vector3_Value_10;
    local Magnitude_42 = var243.Magnitude;
    local var244 = (Magnitude_42 < math.huge); -- nil
    local Position_103 = HumanoidRootPart_3.Position;
    local var245 = Position_103 - Vector3_Value_11;
    local Magnitude_43 = var245.Magnitude;
    local var246 = (Magnitude_43 < math.huge); -- nil
    local Position_104 = HumanoidRootPart_3.Position;
    local var247 = Position_104 - Vector3_Value_12;
    local Magnitude_44 = var247.Magnitude;
    local var248 = (Magnitude_44 < math.huge); -- nil
    local Position_105 = HumanoidRootPart_3.Position;
    local var249 = Position_105 - Vector3_Value_13;
    local Magnitude_45 = var249.Magnitude;
    local var250 = (Magnitude_45 < math.huge); -- nil
    local Position_106 = HumanoidRootPart_3.Position;
    local var251 = Position_106 - Vector3_Value_14;
    local Magnitude_46 = var251.Magnitude;
    local var252 = (Magnitude_46 < math.huge); -- nil
    local Position_107 = HumanoidRootPart_3.Position;
    local var253 = Position_107 - Vector3_Value_15;
    local Magnitude_47 = var253.Magnitude;
    local var254 = (Magnitude_47 < math.huge); -- nil
    local Position_108 = HumanoidRootPart_3.Position;
    local var255 = Position_108 - Vector3_Value_16;
    local Magnitude_48 = var255.Magnitude;
    local var256 = (Magnitude_48 < math.huge); -- nil
    local Waited_For_4 = task.wait(1);
    local Character_7 = LocalPlayer.Character;
    if Character_7 then -- ran, expr id 7, has an else.
        local Character_8 = LocalPlayer.Character;
    end
    local HumanoidRootPart_4 = Character_8:FindFirstChild("HumanoidRootPart");
    if HumanoidRootPart_4 then -- ran, expr id 8, has an else.
        local Position_109 = HumanoidRootPart_4.Position;
        local var257 = Position_109 - Vector3_Value;
    end
    local Magnitude_49 = var257.Magnitude;
    local var258 = (Magnitude_49 < math.huge); -- nil
    local Position_110 = HumanoidRootPart_4.Position;
    local var259 = Position_110 - Vector3_Value_2;
    local Magnitude_50 = var259.Magnitude;
    local var260 = (Magnitude_50 < math.huge); -- nil
    local Position_111 = HumanoidRootPart_4.Position;
    local var261 = Position_111 - Vector3_Value_3;
    local Magnitude_51 = var261.Magnitude;
    local var262 = (Magnitude_51 < math.huge); -- nil
    local Position_112 = HumanoidRootPart_4.Position;
    local var263 = Position_112 - Vector3_Value_4;
    local Magnitude_52 = var263.Magnitude;
    local var264 = (Magnitude_52 < math.huge); -- nil
    local Position_113 = HumanoidRootPart_4.Position;
    local var265 = Position_113 - Vector3_Value_5;
    local Magnitude_53 = var265.Magnitude;
    local var266 = (Magnitude_53 < math.huge); -- nil
    local Position_114 = HumanoidRootPart_4.Position;
    local var267 = Position_114 - Vector3_Value_6;
    local Magnitude_54 = var267.Magnitude;
    local var268 = (Magnitude_54 < math.huge); -- nil
    local Position_115 = HumanoidRootPart_4.Position;
    local var269 = Position_115 - Vector3_Value_7;
    local Magnitude_55 = var269.Magnitude;
    local var270 = (Magnitude_55 < math.huge); -- nil
    local Position_116 = HumanoidRootPart_4.Position;
    local var271 = Position_116 - Vector3_Value_8;
    local Magnitude_56 = var271.Magnitude;
    local var272 = (Magnitude_56 < math.huge); -- nil
    local Position_117 = HumanoidRootPart_4.Position;
    local var273 = Position_117 - Vector3_Value_9;
    local Magnitude_57 = var273.Magnitude;
    local var274 = (Magnitude_57 < math.huge); -- nil
    local Position_118 = HumanoidRootPart_4.Position;
    local var275 = Position_118 - Vector3_Value_10;
    local Magnitude_58 = var275.Magnitude;
    local var276 = (Magnitude_58 < math.huge); -- nil
    local Position_119 = HumanoidRootPart_4.Position;
    local var277 = Position_119 - Vector3_Value_11;
    local Magnitude_59 = var277.Magnitude;
    local var278 = (Magnitude_59 < math.huge); -- nil
    local Position_120 = HumanoidRootPart_4.Position;
    local var279 = Position_120 - Vector3_Value_12;
    local Magnitude_60 = var279.Magnitude;
    local var280 = (Magnitude_60 < math.huge); -- nil
    local Position_121 = HumanoidRootPart_4.Position;
    local var281 = Position_121 - Vector3_Value_13;
    local Magnitude_61 = var281.Magnitude;
    local var282 = (Magnitude_61 < math.huge); -- nil
    local Position_122 = HumanoidRootPart_4.Position;
    local var283 = Position_122 - Vector3_Value_14;
    local Magnitude_62 = var283.Magnitude;
    local var284 = (Magnitude_62 < math.huge); -- nil
    local Position_123 = HumanoidRootPart_4.Position;
    local var285 = Position_123 - Vector3_Value_15;
    local Magnitude_63 = var285.Magnitude;
    local var286 = (Magnitude_63 < math.huge); -- nil
    local Position_124 = HumanoidRootPart_4.Position;
    local var287 = Position_124 - Vector3_Value_16;
    local Magnitude_64 = var287.Magnitude;
    local var288 = (Magnitude_64 < math.huge); -- nil
    local Waited_For_5 = task.wait(1);
    local Character_9 = LocalPlayer.Character;
    if Character_9 then -- ran, expr id 9, has an else.
        local Character_10 = LocalPlayer.Character;
    end
    local HumanoidRootPart_5 = Character_10:FindFirstChild("HumanoidRootPart");
    if HumanoidRootPart_5 then -- ran, expr id 10, has an else.
        local Position_125 = HumanoidRootPart_5.Position;
        local var289 = Position_125 - Vector3_Value;
    end
    local Magnitude_65 = var289.Magnitude;
    local var290 = (Magnitude_65 < math.huge); -- nil
    local Position_126 = HumanoidRootPart_5.Position;
    local var291 = Position_126 - Vector3_Value_2;
    local Magnitude_66 = var291.Magnitude;
    local var292 = (Magnitude_66 < math.huge); -- nil
    local Position_127 = HumanoidRootPart_5.Position;
    local var293 = Position_127 - Vector3_Value_3;
    local Magnitude_67 = var293.Magnitude;
    local var294 = (Magnitude_67 < math.huge); -- nil
    local Position_128 = HumanoidRootPart_5.Position;
    local var295 = Position_128 - Vector3_Value_4;
    local Magnitude_68 = var295.Magnitude;
    local var296 = (Magnitude_68 < math.huge); -- nil
    local Position_129 = HumanoidRootPart_5.Position;
    local var297 = Position_129 - Vector3_Value_5;
    local Magnitude_69 = var297.Magnitude;
    local var298 = (Magnitude_69 < math.huge); -- nil
    local Position_130 = HumanoidRootPart_5.Position;
    local var299 = Position_130 - Vector3_Value_6;
    local Magnitude_70 = var299.Magnitude;
    local var300 = (Magnitude_70 < math.huge); -- nil
    local Position_131 = HumanoidRootPart_5.Position;
    local var301 = Position_131 - Vector3_Value_7;
    local Magnitude_71 = var301.Magnitude;
    local var302 = (Magnitude_71 < math.huge); -- nil
    local Position_132 = HumanoidRootPart_5.Position;
    local var303 = Position_132 - Vector3_Value_8;
    local Magnitude_72 = var303.Magnitude;
    local var304 = (Magnitude_72 < math.huge); -- nil
    local Position_133 = HumanoidRootPart_5.Position;
    local var305 = Position_133 - Vector3_Value_9;
    local Magnitude_73 = var305.Magnitude;
    local var306 = (Magnitude_73 < math.huge); -- nil
    local Position_134 = HumanoidRootPart_5.Position;
    local var307 = Position_134 - Vector3_Value_10;
    local Magnitude_74 = var307.Magnitude;
    local var308 = (Magnitude_74 < math.huge); -- nil
    local Position_135 = HumanoidRootPart_5.Position;
    local var309 = Position_135 - Vector3_Value_11;
    local Magnitude_75 = var309.Magnitude;
    local var310 = (Magnitude_75 < math.huge); -- nil
    local Position_136 = HumanoidRootPart_5.Position;
    local var311 = Position_136 - Vector3_Value_12;
    local Magnitude_76 = var311.Magnitude;
    local var312 = (Magnitude_76 < math.huge); -- nil
    local Position_137 = HumanoidRootPart_5.Position;
    local var313 = Position_137 - Vector3_Value_13;
    local Magnitude_77 = var313.Magnitude;
    local var314 = (Magnitude_77 < math.huge); -- nil
    local Position_138 = HumanoidRootPart_5.Position;
    local var315 = Position_138 - Vector3_Value_14;
    local Magnitude_78 = var315.Magnitude;
    local var316 = (Magnitude_78 < math.huge); -- nil
    local Position_139 = HumanoidRootPart_5.Position;
    local var317 = Position_139 - Vector3_Value_15;
    local Magnitude_79 = var317.Magnitude;
    local var318 = (Magnitude_79 < math.huge); -- nil
    local Position_140 = HumanoidRootPart_5.Position;
    local var319 = Position_140 - Vector3_Value_16;
    local Magnitude_80 = var319.Magnitude;
    local var320 = (Magnitude_80 < math.huge); -- nil
    local Waited_For_6 = task.wait(1);
    local Character_11 = LocalPlayer.Character;
    if Character_11 then -- ran, expr id 11, has an else.
        local Character_12 = LocalPlayer.Character;
    end
    local HumanoidRootPart_6 = Character_12:FindFirstChild("HumanoidRootPart");
    if HumanoidRootPart_6 then -- ran, expr id 12, has an else.
        local Position_141 = HumanoidRootPart_6.Position;
        local var321 = Position_141 - Vector3_Value;
    end
    local Magnitude_81 = var321.Magnitude;
    local var322 = (Magnitude_81 < math.huge); -- nil
    local Position_142 = HumanoidRootPart_6.Position;
    local var323 = Position_142 - Vector3_Value_2;
    local Magnitude_82 = var323.Magnitude;
    local var324 = (Magnitude_82 < math.huge); -- nil
    local Position_143 = HumanoidRootPart_6.Position;
    local var325 = Position_143 - Vector3_Value_3;
    local Magnitude_83 = var325.Magnitude;
    local var326 = (Magnitude_83 < math.huge); -- nil
    local Position_144 = HumanoidRootPart_6.Position;
    local var327 = Position_144 - Vector3_Value_4;
    local Magnitude_84 = var327.Magnitude;
    local var328 = (Magnitude_84 < math.huge); -- nil
    local Position_145 = HumanoidRootPart_6.Position;
    local var329 = Position_145 - Vector3_Value_5;
    local Magnitude_85 = var329.Magnitude;
    local var330 = (Magnitude_85 < math.huge); -- nil
    local Position_146 = HumanoidRootPart_6.Position;
    local var331 = Position_146 - Vector3_Value_6;
    local Magnitude_86 = var331.Magnitude;
    local var332 = (Magnitude_86 < math.huge); -- nil
    local Position_147 = HumanoidRootPart_6.Position;
    local var333 = Position_147 - Vector3_Value_7;
    local Magnitude_87 = var333.Magnitude;
    local var334 = (Magnitude_87 < math.huge); -- nil
    local Position_148 = HumanoidRootPart_6.Position;
    local var335 = Position_148 - Vector3_Value_8;
    local Magnitude_88 = var335.Magnitude;
    local var336 = (Magnitude_88 < math.huge); -- nil
    local Position_149 = HumanoidRootPart_6.Position;
    local var337 = Position_149 - Vector3_Value_9;
    local Magnitude_89 = var337.Magnitude;
    local var338 = (Magnitude_89 < math.huge); -- nil
    local Position_150 = HumanoidRootPart_6.Position;
    local var339 = Position_150 - Vector3_Value_10;
    local Magnitude_90 = var339.Magnitude;
    local var340 = (Magnitude_90 < math.huge); -- nil
    local Position_151 = HumanoidRootPart_6.Position;
    local var341 = Position_151 - Vector3_Value_11;
    local Magnitude_91 = var341.Magnitude;
    local var342 = (Magnitude_91 < math.huge); -- nil
    local Position_152 = HumanoidRootPart_6.Position;
    local var343 = Position_152 - Vector3_Value_12;
    error("[internal]:659: too many operations")
end)
local Connection_2
Connection_2 = game:GetService("ProximityPromptService").PromptButtonHoldEnded:Connect(function(Prompt, PlayerWhoTriggered, p3_0, p4_0, p5_0) -- args: Prompt_2, PlayerWhoTriggered_2
    local _ = (PlayerWhoTriggered ~= LocalPlayer)
    -- true, eq id 1
end)
local TextButton = Instance.new("TextButton")
TextButton.Size = UDim2_New(0, 250, 0, 45)
TextButton.Position = UDim2_New(0.5, -125, 0, 75)
TextButton.BackgroundColor3 = Color3_FromRGB(40, 40, 40)
TextButton.BackgroundTransparency = 0.3
TextButton.Text = "set position"
TextButton.TextColor3 = Color3_FromRGB(255, 255, 255)
TextButton.Font = Enum_Font.GothamSemibold
TextButton.TextSize = 14
TextButton.TextWrapped = true
TextButton.Parent = Frame
local UICorner_32 = Instance.new("UICorner")
UICorner_32.CornerRadius = UDim_New(0, 8)
UICorner_32.Parent = TextButton
local Connection_3
Connection_3 = TextButton.MouseEnter:Connect(function() -- args: X, Y
    local TweenInfo = Env.TweenInfo
    local str = TweenService:Create(TextButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.2,
    })
    str:Play()
end)
local Connection_4
Connection_4 = TextButton.MouseLeave:Connect(function() -- args: X_2, Y_2
    local str_2 = TweenService:Create(TextButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.3,
    })
    str_2:Play()
end)
local Connection_5
Connection_5 = TextButton.MouseButton1Click:Connect(function(p1_0, p2_0, p3_0, p4_0, p5_0)
    local Size = TextButton.Size
    local str_3 = TweenService:Create(TextButton, TweenInfo.new(0.08), {
        Size = UDim2_New(0, 245, 0, 42.75),
    })
    str_3:Play()
    task.wait(0.08)
    local str_4 = TweenService:Create(TextButton, TweenInfo.new(0.12), {
        Size = Size,
    })
    str_4:Play()
    local _ = task.spawn(function(p1_0, p2_0, p3_0, p4_0)
        local Character_15 = LocalPlayer.Character;
        local var369 = (Character_15 and 15434487); -- 15434487
        local Character_16 = LocalPlayer.Character;
        local HumanoidRootPart_7 = Character_16:FindFirstChild("HumanoidRootPart");
        if HumanoidRootPart_7 then -- ran, expr id 13, has an else.
            local CFrame = HumanoidRootPart_7.CFrame;
            local Position_153 = CFrame.Position;
            local Color3_Value_42 = Color3_FromRGB(0, 170, 255);
            local Character_17 = LocalPlayer.Character;
            local Not_Character_17 = not Character_17;
            -- false
            local HumanoidRootPart_8 = Character_17:FindFirstChild("HumanoidRootPart");
            local Not_HumanoidRootPart_8 = not HumanoidRootPart_8;
            -- false
        end
        local Part = Instance.new("Part");
        Part.Parent = workspace;
        local Vector3_Value_17 = Vector3_New(1, 1, 1);
        Part.Size = Vector3_Value_17;
        Part.Anchored = true;
        Part.CanCollide = false;
        Part.Transparency = 1;
        local CFrame_New = CFrame.new;
        local CFrame_Value = CFrame_New(Position_153);
        Part.CFrame = CFrame_Value;
        local Attachment = Instance.new("Attachment");
        Attachment.Parent = Part;
        local HumanoidRootPart_9 = Character_17.HumanoidRootPart;
        local Attachment_2 = Instance.new("Attachment");
        Attachment_2.Parent = HumanoidRootPart_8;
        local Beam = Instance.new("Beam");
        Beam.Parent = workspace;
        Beam.Attachment0 = Attachment;
        Beam.Attachment1 = Attachment_2;
        Beam.Width0 = 0.12;
        Beam.Width1 = 0.12;
        Beam.FaceCamera = true;
        local ColorSequence_New = ColorSequence.new;
        local ColorSequence_Value = ColorSequence_New(Color3_Value_42);
        Beam.Color = ColorSequence_Value;
        TextLabel_2.Text = "set position";
    end)
end)
local TextButton_2 = Instance.new("TextButton")
TextButton_2.Size = UDim2_New(0, 250, 0, 45)
TextButton_2.Position = UDim2_New(0.5, -125, 0, 135)
TextButton_2.BackgroundColor3 = Color3_FromRGB(40, 40, 40)
TextButton_2.BackgroundTransparency = 0.3
TextButton_2.Text = "unwalk anim"
TextButton_2.TextColor3 = Color3_FromRGB(255, 255, 255)
TextButton_2.Font = Enum_Font.GothamSemibold
TextButton_2.TextSize = 14
TextButton_2.TextWrapped = true
TextButton_2.Parent = Frame
local UICorner_33 = Instance.new("UICorner")
UICorner_33.CornerRadius = UDim_New(0, 8)
UICorner_33.Parent = TextButton_2
local Connection_6
Connection_6 = TextButton_2.MouseEnter:Connect(function() -- args: X_3, Y_3
    local str_5 = TweenService:Create(TextButton_2, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.2,
    })
    str_5:Play()
end)
local Connection_7
Connection_7 = TextButton_2.MouseLeave:Connect(function() -- args: X_4, Y_4
    local str_6 = TweenService:Create(TextButton_2, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.3,
    })
    str_6:Play()
end)
local Connection_8
Connection_8 = TextButton_2.MouseButton1Click:Connect(function(p1_0, p2_0, p3_0, p4_0, p5_0)
    local str_7 = TweenService:Create(TextButton_2, TweenInfo.new(0.08), {
        Size = UDim2_New(0, 245, 0, 42.75),
    })
    str_7:Play()
    task.wait(0.08)
    local str_8 = TweenService:Create(TextButton_2, TweenInfo.new(0.12), {
        Size = TextButton_2.Size,
    })
    str_8:Play()
    local _ = task.spawn(function()
        local Character_18 = LocalPlayer.Character;
        local Not_Character_18 = not Character_18;
        -- false
        local var370 = (Not_Character_18 and 13277831);
        local Spawned_5 = task.spawn(function(p1_0, p2_0)
            local var415 = (Character_18 and 15128622); -- 15128622
            local Animate = Character_18:FindFirstChild("Animate");
            local Not_Animate = not Animate;
            -- false
            local Walk = Animate:FindFirstChild("walk");
            local var416 = (Walk and 12488508); -- 12488508
            local WalkAnim = Walk:FindFirstChild("WalkAnim");
            if WalkAnim then -- ran, expr id 15, has an else.
                local Animation = WalkAnim:IsA("Animation");
            end
            local var417 = (Animation and 13391098);
            local Run = Animate:FindFirstChild("run");
            local var418 = (Run and 12488508); -- 12488508
            local RunAnim = Run:FindFirstChild("RunAnim");
            if RunAnim then -- ran, expr id 16, has an else.
                local Animation_2 = RunAnim:IsA("Animation");
            end
            local var419 = (Animation_2 and 13391098);
            local Humanoid = Character_18:FindFirstChildOfClass("Humanoid");
            local var420 = (Humanoid and 13444270); -- 13444270
            local Not_Humanoid = not Humanoid;
            -- false
            local GetPlayingAnimationTracks = Humanoid.GetPlayingAnimationTracks;
            local PlayingAnimationTracks = Humanoid:GetPlayingAnimationTracks();
            for i, v in ipairs(PlayingAnimationTracks) do
                if not i then -- didnt run, expr id 17, has an else.
                else
                    local Name = v.Name;
                    local Lower = Name.lower;
                    local Lower_2 = Name:lower();
                    local Find = Lower_2.find;
                    local Walk_2 = Lower_2:find("walk");
                end
                if Walk_2 then -- ran, expr id 18, has an else.
                    local Stop = v.Stop;
                    local Stop_2 = v:Stop();
                end
            end
            local Connection_13;
            Connection_13 = Character_18.DescendantAdded:Connect(function(Descendant, p2_0, p3_0) -- args: Descendant_2;
                local var423 = (Descendant and 10196994); -- 10196994
                local IsA = Descendant.IsA;
                local Animation_3 = Descendant:IsA("Animation");
                if not Animation_3 then -- didnt run, expr id 19, has an else.
                else
                    local Name_2 = Descendant.Name;
                    local Lower_3 = Name_2.lower;
                    local Lower_4 = Name_2:lower();
                end
                local Find_2 = Lower_4.find;
                local Walk_3 = Lower_4:find("walk");
                local var425 = (Walk_3 and 16642316); -- 16642316
                local AnimationId = Descendant.AnimationId;
                Descendant.AnimationId = "";
            end);
        end);
        local unwalkBtn = Env.unwalkBtn;
        unwalkBtn.Text = "restore walk";
        TextLabel_2.Text = "unwalk enabled";
    end)
end)
local TextButton_3 = Instance.new("TextButton")
TextButton_3.Size = UDim2_New(0, 250, 0, 45)
TextButton_3.Position = UDim2_New(0.5, -125, 0, 195)
TextButton_3.BackgroundColor3 = Color3_FromRGB(40, 40, 40)
TextButton_3.BackgroundTransparency = 0.3
TextButton_3.Text = "desync"
TextButton_3.TextColor3 = Color3_FromRGB(255, 255, 255)
TextButton_3.Font = Enum_Font.GothamSemibold
TextButton_3.TextSize = 14
TextButton_3.TextWrapped = true
TextButton_3.Parent = Frame
local UICorner_34 = Instance.new("UICorner")
UICorner_34.CornerRadius = UDim_New(0, 8)
UICorner_34.Parent = TextButton_3
local Connection_9
Connection_9 = TextButton_3.MouseEnter:Connect(function() -- args: X_5, Y_5
    local str_9 = TweenService:Create(TextButton_3, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.2,
    })
    str_9:Play()
end)
local Connection_10
Connection_10 = TextButton_3.MouseLeave:Connect(function() -- args: X_6, Y_6
    local str_10 = TweenService:Create(TextButton_3, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.3,
    })
    str_10:Play()
end)
local Connection_11
Connection_11 = TextButton_3.MouseButton1Click:Connect(function(p1_0, p2_0, p3_0, p4_0, p5_0)
    local str_11 = TweenService:Create(TextButton_3, TweenInfo.new(0.08), {
        Size = UDim2_New(0, 245, 0, 42.75),
    })
    str_11:Play()
    task.wait(0.08)
    local str_12 = TweenService:Create(TextButton_3, TweenInfo.new(0.12), {
        Size = TextButton_3.Size,
    })
    str_12:Play()
    local _ = task.spawn(function(p1_0, p2_0, p3_0)
        local Success_62, Error_Message_62 = pcall(function(...)
            local setfflag = Env.setfflag;
            local _call370 = setfflag("GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-5000");
        end) -- true
        local _call371 = setfflag("LargeReplicatorWrite5", "true");
        local _call372 = setfflag("LargeReplicatorEnabled9", "true");
        local _call373 = setfflag("AngularVelociryLimit", "360");
        local _call374 = setfflag("TimestepArbiterVelocityCriteriaThresholdTwoDt", "2147483646");
        local _call375 = setfflag("S2PhysicsSenderRate", "15000");
        local _call376 = setfflag("DisableDPIScale", "true");
        local _call377 = setfflag("MaxDataPacketPerSend", "2147483647");
        local _call378 = setfflag("ServerMaxBandwith", "52");
        local _call379 = setfflag("PhysicsSenderMaxBandwidthBps", "20000");
        local _call380 = setfflag("MaxTimestepMultiplierBuoyancy", "2147483647");
        local _call381 = setfflag("SimOwnedNOUCountThresholdMillionth", "2147483647");
        local _call382 = setfflag("MaxMissedWorldStepsRemembered", "-2147483648");
        local _call383 = setfflag("CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth", "1");
        local _call384 = setfflag("StreamJobNOUVolumeLengthCap", "2147483647");
        local _call385 = setfflag("DebugSendDistInSteps", "-2147483648");
        local _call386 = setfflag("MaxTimestepMultiplierAcceleration", "2147483647");
        local _call387 = setfflag("LargeReplicatorRead5", "true");
        local _call388 = setfflag("SimExplicitlyCappedTimestepMultiplier", "2147483646");
        local _call389 = setfflag("GameNetDontSendRedundantNumTimes", "1");
        local _call390 = setfflag("CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent", "1");
        local _call391 = setfflag("CheckPVCachedRotVelThresholdPercent", "10");
        local _call392 = setfflag("LargeReplicatorSerializeRead3", "true");
        local _call393 = setfflag("ReplicationFocusNouExtentsSizeCutoffForPauseStuds", "2147483647");
        local _call394 = setfflag("NextGenReplicatorEnabledWrite4", "true");
        local _call395 = setfflag("CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth", "1");
        local _call396 = setfflag("GameNetDontSendRedundantDeltaPositionMillionth", "1");
        local _call397 = setfflag("InterpolationFrameVelocityThresholdMillionth", "5");
        local _call398 = setfflag("StreamJobNOUVolumeCap", "2147483647");
        local _call399 = setfflag("InterpolationFrameRotVelocityThresholdMillionth", "5");
        local _call400 = setfflag("WorldStepMax", "30");
        local _call401 = setfflag("TimestepArbiterHumanoidLinearVelThreshold", "1");
        local _call402 = setfflag("InterpolationFramePositionThresholdMillionth", "5");
        local _call403 = setfflag("TimestepArbiterHumanoidTurningVelThreshold", "1");
        local _call404 = setfflag("MaxTimestepMultiplierContstraint", "2147483647");
        local _call405 = setfflag("GameNetPVHeaderLinearVelocityZeroCutoffExponent", "-5000");
        local _call406 = setfflag("CheckPVCachedVelThresholdPercent", "10");
        local _call407 = setfflag("TimestepArbiterOmegaThou", "1073741823");
        local _call408 = setfflag("MaxAcceptableUpdateDelay", "1");
        local _call409 = setfflag("LargeReplicatorSerializeWrite4", "true");
        local gethidden = Env.gethidden;
        if not gethidden then -- didnt run, expr id 14, has an else.
        else
            local _call410 = gethidden(workspace, "RejectCharacterDeletions");
        end
        local Enum_RejectCharacterDeletions = Enum.RejectCharacterDeletions;
        local Disabled = Enum_RejectCharacterDeletions.Disabled;
        local _call410_isnt_Disabled = (_call410 ~= Disabled);
        -- true, eq id 2
        local replicatesignal = Env.replicatesignal;
        local var412 = (replicatesignal and 13097231); -- 13097231
        local _call413 = replicatesignal(LocalPlayer.ConnectDiedSignalBackend);
        local RespawnTime = LocalPlayer.RespawnTime;
        local var414 = RespawnTime - 0.1;
        local Waited_For_10 = task.wait(var414);
        local _call415 = replicatesignal(LocalPlayer.Kill);
        TextLabel_2.Text = "desync applied";
        local desyncBtn = Env.desyncBtn;
        desyncBtn.Text = "desync on";
    end)
end)
local Connection_12
Connection_12 = LocalPlayer.CharacterAdded:Connect(function(Character_13, p2_0, p3_0, p4_0) -- args: Character_14
end)
local TextLabel_3 = Instance.new("TextLabel")
TextLabel_3.Size = UDim2_New(1, -20, 0, 20)
TextLabel_3.Position = UDim2_New(0, 10, 0, 290)
TextLabel_3.BackgroundTransparency = 1
TextLabel_3.Text = "discord.gg/tokinu"
TextLabel_3.TextColor3 = Color3_FromRGB(150, 150, 150)
TextLabel_3.Font = Enum_Font.Gotham
TextLabel_3.TextSize = 12
TextLabel_3.TextXAlignment = Enum_TextXAlignment.Center
TextLabel_3.Parent = Frame
