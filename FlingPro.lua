-- ╔═══════════════════════════════════════╗
-- ║         FLING PRO  v1.0               ║
-- ║     Car Spin Fling System             ║
-- ╚═══════════════════════════════════════╝

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ─── AYARLAR ───────────────────────────────────────────────────────────────
local CFG = {
    CarName     = "Jeep",       -- Dropdown'dan veya buradan değiştir
    Radius      = 9,            -- Hedefin etrafında dönme yarıçapı (studs)
    MinSpeed    = 10,
    MaxSpeed    = 300,
    DefaultSpeed= 80,
}
-- ────────────────────────────────────────────────────────────────────────────

-- ─── GUI ────────────────────────────────────────────────────────────────────
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end
local function makeGrad(parent, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    g.Parent = parent
end
local function makeShadow(frame)
    local s = Instance.new("ImageLabel")
    s.Image = "rbxassetid://5028857472"
    s.ImageColor3 = Color3.fromRGB(0,0,0)
    s.ImageTransparency = 0.5
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(24,24,276,276)
    s.Size = UDim2.new(1,30,1,30)
    s.Position = UDim2.new(0,-15,0,-15)
    s.BackgroundTransparency = 1
    s.ZIndex = frame.ZIndex - 1
    s.Parent = frame
end

local SG = Instance.new("ScreenGui")
SG.Name = "FlingProUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true
SG.Parent = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or LP.PlayerGui

-- Ana kart
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 310, 0, 440)
Main.Position = UDim2.new(0.5,-155,0.5,-220)
Main.BackgroundColor3 = Color3.fromRGB(12,12,18)
Main.BorderSizePixel = 0
Main.ZIndex = 2
Main.Parent = SG
makeCorner(Main, 14)
makeShadow(Main)
makeGrad(Main,
    Color3.fromRGB(18,18,30),
    Color3.fromRGB(10,10,14),
    135)

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,52)
TopBar.BackgroundColor3 = Color3.fromRGB(220,30,30)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = Main
makeCorner(TopBar, 14)
makeGrad(TopBar,
    Color3.fromRGB(255,65,65),
    Color3.fromRGB(180,10,10),
    135)

-- topbar alt köşe fix
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1,0,0.5,0)
TopFix.Position = UDim2.new(0,0,0.5,0)
TopFix.BackgroundColor3 = Color3.fromRGB(195,10,10)
TopFix.BorderSizePixel = 0
TopFix.ZIndex = 3
TopFix.Parent = TopBar

-- İkon & başlık
local Icon = Instance.new("TextLabel")
Icon.Size = UDim2.new(0,40,1,0)
Icon.Position = UDim2.new(0,10,0,0)
Icon.BackgroundTransparency = 1
Icon.Text = "⚡"
Icon.TextSize = 22
Icon.Font = Enum.Font.GothamBold
Icon.TextColor3 = Color3.fromRGB(255,255,255)
Icon.ZIndex = 4
Icon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-110,1,0)
Title.Position = UDim2.new(0,48,0,0)
Title.BackgroundTransparency = 1
Title.Text = "FLING PRO"
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4
Title.Parent = TopBar

local VerLabel = Instance.new("TextLabel")
VerLabel.Size = UDim2.new(0,50,1,0)
VerLabel.Position = UDim2.new(1,-58,0,0)
VerLabel.BackgroundTransparency = 1
VerLabel.Text = "v1.0"
VerLabel.TextSize = 11
VerLabel.Font = Enum.Font.Gotham
VerLabel.TextColor3 = Color3.fromRGB(255,180,180)
VerLabel.TextXAlignment = Enum.TextXAlignment.Right
VerLabel.ZIndex = 4
VerLabel.Parent = TopBar

-- Kapat butonu
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-38,0.5,-14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BackgroundTransparency = 0.85
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 5
CloseBtn.Parent = TopBar
makeCorner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

-- ─── BÖLÜM BAŞLIĞI HELPER ───────────────────────────────────────────────────
local function sectionLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-30,0,16)
    l.Position = UDim2.new(0,15,0,y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = Color3.fromRGB(255,70,70)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = Main
    return l
end
local function separator(y)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1,-30,0,1)
    s.Position = UDim2.new(0,15,0,y)
    s.BackgroundColor3 = Color3.fromRGB(40,40,60)
    s.BorderSizePixel = 0
    s.ZIndex = 3
    s.Parent = Main
end

-- ─── TARGET DROPDOWN ────────────────────────────────────────────────────────
sectionLabel("› TARGET", 62)

local DropBg = Instance.new("Frame")
DropBg.Size = UDim2.new(1,-62,0,38)
DropBg.Position = UDim2.new(0,15,0,82)
DropBg.BackgroundColor3 = Color3.fromRGB(22,22,34)
DropBg.BorderSizePixel = 0
DropBg.ZIndex = 3
DropBg.Parent = Main
makeCorner(DropBg, 8)

local DropLabel = Instance.new("TextLabel")
DropLabel.Size = UDim2.new(1,-36,1,0)
DropLabel.Position = UDim2.new(0,12,0,0)
DropLabel.BackgroundTransparency = 1
DropLabel.Text = "Select player..."
DropLabel.TextSize = 13
DropLabel.Font = Enum.Font.Gotham
DropLabel.TextColor3 = Color3.fromRGB(160,160,160)
DropLabel.TextXAlignment = Enum.TextXAlignment.Left
DropLabel.ZIndex = 4
DropLabel.Parent = DropBg

local DropArrow = Instance.new("TextLabel")
DropArrow.Size = UDim2.new(0,28,1,0)
DropArrow.Position = UDim2.new(1,-30,0,0)
DropArrow.BackgroundTransparency = 1
DropArrow.Text = "▾"
DropArrow.TextSize = 16
DropArrow.Font = Enum.Font.GothamBold
DropArrow.TextColor3 = Color3.fromRGB(255,70,70)
DropArrow.ZIndex = 4
DropArrow.Parent = DropBg

-- Refresh butonu
local RefBtn = Instance.new("TextButton")
RefBtn.Size = UDim2.new(0,38,0,38)
RefBtn.Position = UDim2.new(1,-43,0,82)
RefBtn.BackgroundColor3 = Color3.fromRGB(22,22,34)
RefBtn.Text = "↺"
RefBtn.TextColor3 = Color3.fromRGB(255,70,70)
RefBtn.TextSize = 18
RefBtn.Font = Enum.Font.GothamBold
RefBtn.BorderSizePixel = 0
RefBtn.ZIndex = 4
RefBtn.Parent = Main
makeCorner(RefBtn, 8)

-- Dropdown list
local DropList = Instance.new("ScrollingFrame")
DropList.Size = UDim2.new(1,-30,0,0)
DropList.Position = UDim2.new(0,15,0,123)
DropList.BackgroundColor3 = Color3.fromRGB(16,16,26)
DropList.BorderSizePixel = 0
DropList.ScrollBarThickness = 3
DropList.ScrollBarImageColor3 = Color3.fromRGB(255,50,50)
DropList.Visible = false
DropList.ZIndex = 10
DropList.CanvasSize = UDim2.new(0,0,0,0)
DropList.Parent = Main
makeCorner(DropList, 8)

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Parent = DropList

-- ─── STATE ──────────────────────────────────────────────────────────────────
local selectedTarget = nil
local dropOpen       = false
local flingActive    = false
local flingConn      = nil
local spawnedCar     = nil
local spinAngle      = 0
local spinSpeed      = CFG.DefaultSpeed

-- ─── DROPDOWN DOLDUR ────────────────────────────────────────────────────────
local function populateDrop()
    for _, c in ipairs(DropList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,34)
            btn.BackgroundTransparency = 1
            btn.Text = "  🎯  " .. plr.Name
            btn.TextColor3 = Color3.fromRGB(210,210,210)
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 11
            btn.Name = plr.Name
            btn.Parent = DropList

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.75,
                    BackgroundColor3 = Color3.fromRGB(255,50,50)
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {
                    BackgroundTransparency = 1
                }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                selectedTarget = plr
                DropLabel.Text = "🎯  " .. plr.Name
                DropLabel.TextColor3 = Color3.fromRGB(255,110,110)
                dropOpen = false
                DropList.Visible = false
                DropArrow.Text = "▾"
                TweenService:Create(DropList, TweenInfo.new(0.15), {Size = UDim2.new(1,-30,0,0)}):Play()
            end)
            count += 1
        end
    end
    local itemH = count * 34
    DropList.CanvasSize = UDim2.new(0,0,0,itemH)
    return math.min(itemH, 136)
end

local function toggleDrop()
    populateDrop()
    dropOpen = not dropOpen
    DropArrow.Text = dropOpen and "▴" or "▾"
    local targetH = dropOpen and populateDrop() or 0
    DropList.Visible = true
    TweenService:Create(DropList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1,-30,0,targetH)
    }):Play()
    if not dropOpen then
        task.delay(0.2, function() DropList.Visible = false end)
    end
end

local DropToggle = Instance.new("TextButton")
DropToggle.Size = UDim2.new(1,0,1,0)
DropToggle.BackgroundTransparency = 1
DropToggle.Text = ""
DropToggle.ZIndex = 5
DropToggle.Parent = DropBg
DropToggle.MouseButton1Click:Connect(toggleDrop)

RefBtn.MouseButton1Click:Connect(function()
    populateDrop()
    local rot = TweenService:Create(RefBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Rotation = RefBtn.Rotation + 360})
    rot:Play()
    local flash = TweenService:Create(RefBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255,220,50)})
    flash:Play()
    task.delay(0.3, function()
        TweenService:Create(RefBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,70,70)}):Play()
    end)
end)

-- ─── ARABA SEÇİMİ ───────────────────────────────────────────────────────────
separator(132)
sectionLabel("› VEHICLE", 142)

local carOptions = {"Jeep", "SportsCar", "Truck", "Van"}
local carIndex   = 1

local CarBg = Instance.new("Frame")
CarBg.Size = UDim2.new(1,-30,0,34)
CarBg.Position = UDim2.new(0,15,0,162)
CarBg.BackgroundColor3 = Color3.fromRGB(22,22,34)
CarBg.BorderSizePixel = 0
CarBg.ZIndex = 3
CarBg.Parent = Main
makeCorner(CarBg, 8)

local CarPrev = Instance.new("TextButton")
CarPrev.Size = UDim2.new(0,30,1,0)
CarPrev.BackgroundTransparency = 1
CarPrev.Text = "◂"
CarPrev.TextSize = 16
CarPrev.Font = Enum.Font.GothamBold
CarPrev.TextColor3 = Color3.fromRGB(255,70,70)
CarPrev.ZIndex = 4
CarPrev.Parent = CarBg

local CarName = Instance.new("TextLabel")
CarName.Size = UDim2.new(1,-60,1,0)
CarName.Position = UDim2.new(0,30,0,0)
CarName.BackgroundTransparency = 1
CarName.Text = carOptions[carIndex]
CarName.TextSize = 13
CarName.Font = Enum.Font.GothamBold
CarName.TextColor3 = Color3.fromRGB(220,220,220)
CarName.ZIndex = 4
CarName.Parent = CarBg

local CarNext = Instance.new("TextButton")
CarNext.Size = UDim2.new(0,30,1,0)
CarNext.Position = UDim2.new(1,-30,0,0)
CarNext.BackgroundTransparency = 1
CarNext.Text = "▸"
CarNext.TextSize = 16
CarNext.Font = Enum.Font.GothamBold
CarNext.TextColor3 = Color3.fromRGB(255,70,70)
CarNext.ZIndex = 4
CarNext.Parent = CarBg

CarPrev.MouseButton1Click:Connect(function()
    carIndex = (carIndex - 2) % #carOptions + 1
    CarName.Text = carOptions[carIndex]
    CFG.CarName = carOptions[carIndex]
end)
CarNext.MouseButton1Click:Connect(function()
    carIndex = carIndex % #carOptions + 1
    CarName.Text = carOptions[carIndex]
    CFG.CarName = carOptions[carIndex]
end)

-- ─── SPIN SPEED ─────────────────────────────────────────────────────────────
separator(206)
sectionLabel("› SPIN SPEED", 216)

local SpeedBg = Instance.new("Frame")
SpeedBg.Size = UDim2.new(1,-30,0,34)
SpeedBg.Position = UDim2.new(0,15,0,236)
SpeedBg.BackgroundColor3 = Color3.fromRGB(22,22,34)
SpeedBg.BorderSizePixel = 0
SpeedBg.ZIndex = 3
SpeedBg.Parent = Main
makeCorner(SpeedBg, 8)

local SpeedDown = Instance.new("TextButton")
SpeedDown.Size = UDim2.new(0,34,1,0)
SpeedDown.BackgroundTransparency = 1
SpeedDown.Text = "−"
SpeedDown.TextSize = 18
SpeedDown.Font = Enum.Font.GothamBold
SpeedDown.TextColor3 = Color3.fromRGB(255,70,70)
SpeedDown.ZIndex = 4
SpeedDown.Parent = SpeedBg

local SpeedVal = Instance.new("TextLabel")
SpeedVal.Size = UDim2.new(1,-68,1,0)
SpeedVal.Position = UDim2.new(0,34,0,0)
SpeedVal.BackgroundTransparency = 1
SpeedVal.Text = tostring(spinSpeed)
SpeedVal.TextSize = 14
SpeedVal.Font = Enum.Font.GothamBold
SpeedVal.TextColor3 = Color3.fromRGB(255,255,255)
SpeedVal.ZIndex = 4
SpeedVal.Parent = SpeedBg

local SpeedUp = Instance.new("TextButton")
SpeedUp.Size = UDim2.new(0,34,1,0)
SpeedUp.Position = UDim2.new(1,-34,0,0)
SpeedUp.BackgroundTransparency = 1
SpeedUp.Text = "+"
SpeedUp.TextSize = 18
SpeedUp.Font = Enum.Font.GothamBold
SpeedUp.TextColor3 = Color3.fromRGB(255,70,70)
SpeedUp.ZIndex = 4
SpeedUp.Parent = SpeedBg

SpeedDown.MouseButton1Click:Connect(function()
    spinSpeed = math.max(CFG.MinSpeed, spinSpeed - 10)
    SpeedVal.Text = tostring(spinSpeed)
end)
SpeedUp.MouseButton1Click:Connect(function()
    spinSpeed = math.min(CFG.MaxSpeed, spinSpeed + 10)
    SpeedVal.Text = tostring(spinSpeed)
end)

-- ─── RADIUS ─────────────────────────────────────────────────────────────────
separator(280)
sectionLabel("› ORBIT RADIUS", 290)

local RadBg = Instance.new("Frame")
RadBg.Size = UDim2.new(1,-30,0,34)
RadBg.Position = UDim2.new(0,15,0,310)
RadBg.BackgroundColor3 = Color3.fromRGB(22,22,34)
RadBg.BorderSizePixel = 0
RadBg.ZIndex = 3
RadBg.Parent = Main
makeCorner(RadBg, 8)

local RadDown = Instance.new("TextButton")
RadDown.Size = UDim2.new(0,34,1,0)
RadDown.BackgroundTransparency = 1
RadDown.Text = "−"
RadDown.TextSize = 18
RadDown.Font = Enum.Font.GothamBold
RadDown.TextColor3 = Color3.fromRGB(255,70,70)
RadDown.ZIndex = 4
RadDown.Parent = RadBg

local RadVal = Instance.new("TextLabel")
RadVal.Size = UDim2.new(1,-68,1,0)
RadVal.Position = UDim2.new(0,34,0,0)
RadVal.BackgroundTransparency = 1
RadVal.Text = tostring(CFG.Radius)
RadVal.TextSize = 14
RadVal.Font = Enum.Font.GothamBold
RadVal.TextColor3 = Color3.fromRGB(255,255,255)
RadVal.ZIndex = 4
RadVal.Parent = RadBg

local RadUp = Instance.new("TextButton")
RadUp.Size = UDim2.new(0,34,1,0)
RadUp.Position = UDim2.new(1,-34,0,0)
RadUp.BackgroundTransparency = 1
RadUp.Text = "+"
RadUp.TextSize = 18
RadUp.Font = Enum.Font.GothamBold
RadUp.TextColor3 = Color3.fromRGB(255,70,70)
RadUp.ZIndex = 4
RadUp.Parent = RadBg

RadDown.MouseButton1Click:Connect(function()
    CFG.Radius = math.max(3, CFG.Radius - 1)
    RadVal.Text = tostring(CFG.Radius)
end)
RadUp.MouseButton1Click:Connect(function()
    CFG.Radius = math.min(30, CFG.Radius + 1)
    RadVal.Text = tostring(CFG.Radius)
end)

-- ─── LAUNCH BUTONU ──────────────────────────────────────────────────────────
separator(354)

local LaunchBtn = Instance.new("TextButton")
LaunchBtn.Size = UDim2.new(1,-30,0,50)
LaunchBtn.Position = UDim2.new(0,15,0,364)
LaunchBtn.BackgroundColor3 = Color3.fromRGB(220,30,30)
LaunchBtn.Text = "⚡  LAUNCH FLING"
LaunchBtn.TextColor3 = Color3.fromRGB(255,255,255)
LaunchBtn.TextSize = 16
LaunchBtn.Font = Enum.Font.GothamBold
LaunchBtn.BorderSizePixel = 0
LaunchBtn.ZIndex = 3
LaunchBtn.Parent = Main
makeCorner(LaunchBtn, 10)
makeGrad(LaunchBtn,
    Color3.fromRGB(255,70,70),
    Color3.fromRGB(180,10,10),
    135)

-- Status bar
local StatusBar = Instance.new("TextLabel")
StatusBar.Size = UDim2.new(1,-30,0,16)
StatusBar.Position = UDim2.new(0,15,0,420)
StatusBar.BackgroundTransparency = 1
StatusBar.Text = "● Ready — select a target"
StatusBar.TextSize = 10
StatusBar.Font = Enum.Font.Gotham
StatusBar.TextColor3 = Color3.fromRGB(90,90,110)
StatusBar.TextXAlignment = Enum.TextXAlignment.Left
StatusBar.ZIndex = 3
StatusBar.Parent = Main

local function setStatus(msg, color)
    StatusBar.Text = "● " .. msg
    StatusBar.TextColor3 = color or Color3.fromRGB(90,90,110)
end

-- ─── DRAG ───────────────────────────────────────────────────────────────────
do
    local dragging, dragStart, frameStart
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            dragStart  = i.Position
            frameStart = Main.Position
        end
    end)
    TopBar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + d.X,
                frameStart.Y.Scale, frameStart.Y.Offset + d.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  FLING LOGIC
-- ═══════════════════════════════════════════════════════════════════════════

local function findOwnedCar()
    -- Araba spawn edildikten sonra Workspace.Vehicles içindeki
    -- VehicleSeat bulunan en son eklenen aracı seç
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then return nil end
    local found = nil
    for _, v in ipairs(vehicles:GetChildren()) do
        local seats = v:FindFirstChild("Seats")
        if seats and seats:FindFirstChild("VehicleSeat") then
            found = v   -- en son bulunanu al
        end
    end
    return found
end

local function spawnCar()
    setStatus("Spawning " .. CFG.CarName .. "...", Color3.fromRGB(255,200,50))
    local ok, err = pcall(function()
        local args = {"PickingCar", CFG.CarName}
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(unpack(args))
    end)
    if not ok then
        setStatus("Remote error: " .. tostring(err), Color3.fromRGB(255,80,80))
        return nil
    end
    -- Arabanın workspace'e eklenmesini bekle
    task.wait(2.5)
    return findOwnedCar()
end

local function sitInCar(car)
    if not car then return false end
    local seat = car:FindFirstChild("Seats") and car.Seats:FindFirstChild("VehicleSeat")
    if not seat then
        setStatus("VehicleSeat bulunamadı!", Color3.fromRGB(255,80,80))
        return false
    end
    local char = LP.Character
    if not char then return false end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end

    -- Koltuğun üstüne ışınla
    hrp.CFrame = seat.CFrame * CFrame.new(0, 4, 0)
    task.wait(0.15)
    seat:Sit(hum)
    task.wait(0.2)
    setStatus("Seated ✓", Color3.fromRGB(100,255,100))
    return true
end

local function stopFling()
    flingActive = false
    if flingConn then flingConn:Disconnect(); flingConn = nil end
    LaunchBtn.Text = "⚡  LAUNCH FLING"
    makeGrad(LaunchBtn,
        Color3.fromRGB(255,70,70),
        Color3.fromRGB(180,10,10), 135)
    setStatus("Stopped.", Color3.fromRGB(150,80,80))
end

local function startFling(target, car)
    flingActive = true
    spinAngle   = 0
    LaunchBtn.Text = "■  STOP FLING"
    makeGrad(LaunchBtn,
        Color3.fromRGB(60,60,60),
        Color3.fromRGB(30,30,30), 135)

    flingConn = RunService.Heartbeat:Connect(function(dt)
        if not flingActive then return end

        -- Hedef kontrol
        if not (target and target.Character) then
            setStatus("Target disconnected!", Color3.fromRGB(255,140,40))
            stopFling(); return
        end
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP then return end

        -- Araç hâlâ var mı?
        if not (car and car.Parent) then
            setStatus("Car despawned!", Color3.fromRGB(255,80,80))
            stopFling(); return
        end

        -- Yörünge
        spinAngle += dt * (spinSpeed * 0.05)  -- rad/s
        local r  = CFG.Radius
        local tp = tHRP.Position
        local nx = tp.X + math.cos(spinAngle) * r
        local nz = tp.Z + math.sin(spinAngle) * r
        local ny = tp.Y + 0.5

        local targetCF = CFrame.new(Vector3.new(nx, ny, nz), tp)

        -- Arabayı hareket ettir
        if car.PrimaryPart then
            car:SetPrimaryPartCFrame(targetCF)
        else
            -- PrimaryPart yoksa koltuk üzerinden dene
            local seat = car:FindFirstChild("Seats") and car.Seats:FindFirstChild("VehicleSeat")
            if seat then seat.CFrame = targetCF end
        end

        setStatus(
            string.format("Flinging: %s  |  %.0f°", target.Name, math.deg(spinAngle) % 360),
            Color3.fromRGB(80,255,120)
        )
    end)
end

-- ─── LAUNCH BUTTON LOGIC ────────────────────────────────────────────────────
LaunchBtn.MouseButton1Click:Connect(function()
    if flingActive then stopFling(); return end

    -- Hedef seçili mi?
    if not selectedTarget then
        setStatus("Önce bir hedef seç!", Color3.fromRGB(255,160,50))
        -- Küçük shake animasyonu
        local orig = LaunchBtn.Position
        for i=1,4 do
            LaunchBtn.Position = orig + UDim2.new(0,(i%2==0 and 4 or -4),0,0)
            task.wait(0.05)
        end
        LaunchBtn.Position = orig
        return
    end

    if not Players:FindFirstChild(selectedTarget.Name) then
        setStatus("Hedef oyunda değil!", Color3.fromRGB(255,80,80))
        selectedTarget = nil
        DropLabel.Text = "Select player..."
        DropLabel.TextColor3 = Color3.fromRGB(160,160,160)
        return
    end

    -- Araç spawn
    local car = spawnCar()
    if not car then return end
    spawnedCar = car

    -- İçine otur
    local sat = sitInCar(car)
    if not sat then return end

    task.wait(0.4)

    -- Hedefin yanına ışınla (araba dahil)
    local tHRP = selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart")
    if tHRP and car.PrimaryPart then
        car:SetPrimaryPartCFrame(
            CFrame.new(tHRP.Position + Vector3.new(CFG.Radius, 1, 0))
        )
    end

    task.wait(0.3)
    setStatus("Fling başlıyor...", Color3.fromRGB(255,200,50))
    task.wait(0.2)

    -- Fling loop
    startFling(selectedTarget, car)
end)

-- Hover efekti
LaunchBtn.MouseEnter:Connect(function()
    if not flingActive then
        TweenService:Create(LaunchBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(255,60,60)
        }):Play()
    end
end)
LaunchBtn.MouseLeave:Connect(function()
    if not flingActive then
        TweenService:Create(LaunchBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(220,30,30)
        }):Play()
    end
end)

populateDrop()
setStatus("Ready — select a target", Color3.fromRGB(90,90,110))
print("[FlingPro] Loaded. Select a target and hit LAUNCH FLING.")
