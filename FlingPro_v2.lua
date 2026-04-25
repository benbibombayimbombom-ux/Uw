-- ╔══════════════════════════════════════════╗
-- ║        FLING PRO  v2.0                   ║
-- ║  VFling Tekniği — Hızlı Fling + Return   ║
-- ╚══════════════════════════════════════════╝
--
-- NASIL ÇALIŞIR:
--   1. Araba spawn edilir, içine otururuz
--   2. Fling anında hedefin HRP'sine ışınlanır
--   3. Her Heartbeat'te koltuk hedefin üstüne gider
--      → Fizik motoru bunu dev bir velocity olarak algılar → FLING
--   4. Fling bitince orijinal konuma dönülür
-- ─────────────────────────────────────────────────────────────────

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP  = Players.LocalPlayer

-- ─── CONFIG ──────────────────────────────────────────────────────
local CFG = {
    FlingDuration = 3.5,   -- kaç saniye fling yapılsın
    PreDelay      = 0.3,   -- konuma geldikten sonra ne kadar bekle
    -- Fling anında koltuk bu ofsetlerle random titrer (daha güçlü fling)
    ShakeRange    = 4,
}
-- ─────────────────────────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════
--  GUI
-- ═══════════════════════════════════════════════════════════════
local function mkCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
end
local function mkGrad(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    g.Parent = p
end

local SG = Instance.new("ScreenGui")
SG.Name = "FlingPro2"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true
SG.Parent = (pcall(function() return game:GetService("CoreGui") end)
    and game:GetService("CoreGui")) or LP.PlayerGui

-- Kart
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(11, 11, 17)
Main.BorderSizePixel = 0
Main.ZIndex = 2
Main.Parent = SG
mkCorner(Main, 14)
mkGrad(Main, Color3.fromRGB(18,18,30), Color3.fromRGB(9,9,14), 135)

-- Top bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 50)
Top.BackgroundColor3 = Color3.fromRGB(200,25,25)
Top.BorderSizePixel = 0
Top.ZIndex = 3
Top.Parent = Main
mkCorner(Top, 14)
mkGrad(Top, Color3.fromRGB(255,60,60), Color3.fromRGB(170,10,10), 140)

-- Alt köşe fix
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0.5, 0)
TopFix.Position = UDim2.new(0, 0, 0.5, 0)
TopFix.BackgroundColor3 = Color3.fromRGB(175, 10, 10)
TopFix.BorderSizePixel = 0
TopFix.ZIndex = 3
TopFix.Parent = Top

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -100, 1, 0)
TitleLbl.Position = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⚡  FLING PRO"
TitleLbl.TextSize = 17
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 4
TitleLbl.Parent = Top

local VerLbl = Instance.new("TextLabel")
VerLbl.Size = UDim2.new(0, 40, 1, 0)
VerLbl.Position = UDim2.new(1, -80, 0, 0)
VerLbl.BackgroundTransparency = 1
VerLbl.Text = "v2.0"
VerLbl.TextSize = 11
VerLbl.Font = Enum.Font.Gotham
VerLbl.TextColor3 = Color3.fromRGB(255, 180, 180)
VerLbl.TextXAlignment = Enum.TextXAlignment.Right
VerLbl.ZIndex = 4
VerLbl.Parent = Top

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BackgroundTransparency = 0.82
CloseBtn.Text = "✕"
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 5
CloseBtn.Parent = Top
mkCorner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

-- ── yardımcılar ──────────────────────────────────────────────────
local function secLabel(txt, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -30, 0, 14)
    l.Position = UDim2.new(0, 15, 0, y)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextSize = 10
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = Color3.fromRGB(255, 65, 65)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 3
    l.Parent = Main
end
local function sep(y)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, -30, 0, 1)
    s.Position = UDim2.new(0, 15, 0, y)
    s.BackgroundColor3 = Color3.fromRGB(38, 38, 58)
    s.BorderSizePixel = 0
    s.ZIndex = 3
    s.Parent = Main
end
local function row(y, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -30, 0, h or 36)
    f.Position = UDim2.new(0, 15, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    f.BorderSizePixel = 0
    f.ZIndex = 3
    f.Parent = Main
    mkCorner(f, 8)
    return f
end

-- ── TARGET dropdown ───────────────────────────────────────────────
secLabel("› TARGET PLAYER", 60)

local DropBg = row(78, 36)
local DropLbl = Instance.new("TextLabel")
DropLbl.Size = UDim2.new(1, -36, 1, 0)
DropLbl.Position = UDim2.new(0, 10, 0, 0)
DropLbl.BackgroundTransparency = 1
DropLbl.Text = "Select player..."
DropLbl.TextSize = 12
DropLbl.Font = Enum.Font.Gotham
DropLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
DropLbl.TextXAlignment = Enum.TextXAlignment.Left
DropLbl.ZIndex = 4
DropLbl.Parent = DropBg

local DropArr = Instance.new("TextLabel")
DropArr.Size = UDim2.new(0, 24, 1, 0)
DropArr.Position = UDim2.new(1, -28, 0, 0)
DropArr.BackgroundTransparency = 1
DropArr.Text = "▾"
DropArr.TextSize = 16
DropArr.Font = Enum.Font.GothamBold
DropArr.TextColor3 = Color3.fromRGB(255, 60, 60)
DropArr.ZIndex = 4
DropArr.Parent = DropBg

-- Refresh
local RefBtn = Instance.new("TextButton")
RefBtn.Size = UDim2.new(0, 36, 0, 36)
RefBtn.Position = UDim2.new(1, -15, 0, 78)
RefBtn.AnchorPoint = Vector2.new(1, 0)
RefBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
RefBtn.Text = "↺"
RefBtn.TextSize = 18
RefBtn.Font = Enum.Font.GothamBold
RefBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
RefBtn.BorderSizePixel = 0
RefBtn.ZIndex = 4
RefBtn.Parent = Main
mkCorner(RefBtn, 8)

DropBg.Size = UDim2.new(1, -62, 0, 36)   -- RefBtn'e yer aç

local DropList = Instance.new("ScrollingFrame")
DropList.Size = UDim2.new(1, -30, 0, 0)
DropList.Position = UDim2.new(0, 15, 0, 116)
DropList.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
DropList.BorderSizePixel = 0
DropList.ScrollBarThickness = 3
DropList.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
DropList.Visible = false
DropList.ZIndex = 10
DropList.CanvasSize = UDim2.new(0, 0, 0, 0)
DropList.Parent = Main
mkCorner(DropList, 8)
local DLL = Instance.new("UIListLayout")
DLL.SortOrder = Enum.SortOrder.Name
DLL.Parent = DropList

local selectedTarget = nil
local dropOpen       = false

local function fillDrop()
    for _, c in ipairs(DropList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local n = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundTransparency = 1
            b.Text = "  🎯  " .. plr.Name
            b.TextSize = 12
            b.Font = Enum.Font.Gotham
            b.TextColor3 = Color3.fromRGB(200, 200, 200)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.ZIndex = 11
            b.Name = plr.Name
            b.Parent = DropList
            b.MouseEnter:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.08), {
                    BackgroundTransparency = 0.78,
                    BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                }):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.08), {BackgroundTransparency = 1}):Play()
            end)
            b.MouseButton1Click:Connect(function()
                selectedTarget = plr
                DropLbl.Text = "🎯  " .. plr.Name
                DropLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
                dropOpen = false
                DropArr.Text = "▾"
                TweenService:Create(DropList, TweenInfo.new(0.15), {Size = UDim2.new(1,-30,0,0)}):Play()
                task.delay(0.15, function() DropList.Visible = false end)
            end)
            n += 1
        end
    end
    DropList.CanvasSize = UDim2.new(0, 0, 0, n * 32)
    return math.min(n * 32, 128)
end

local function toggleDrop()
    dropOpen = not dropOpen
    DropArr.Text = dropOpen and "▴" or "▾"
    local h = dropOpen and fillDrop() or 0
    DropList.Visible = true
    TweenService:Create(DropList, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1, -30, 0, h)
    }):Play()
    if not dropOpen then task.delay(0.18, function() DropList.Visible = false end) end
end

local DropBtn = Instance.new("TextButton")
DropBtn.Size = UDim2.new(1,0,1,0)
DropBtn.BackgroundTransparency = 1
DropBtn.Text = ""
DropBtn.ZIndex = 5
DropBtn.Parent = DropBg
DropBtn.MouseButton1Click:Connect(toggleDrop)

RefBtn.MouseButton1Click:Connect(function()
    fillDrop()
    TweenService:Create(RefBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
        Rotation = RefBtn.Rotation + 360
    }):Play()
end)

-- ── ARAÇ SEÇİCİ ──────────────────────────────────────────────────
sep(156)
secLabel("› VEHICLE", 166)

local carList  = {"Jeep","SportsCar","Truck","Van","Muscle"}
local carIdx   = 1
local carRow   = row(184, 34)

local CarPrev = Instance.new("TextButton")
CarPrev.Size = UDim2.new(0, 30, 1, 0)
CarPrev.BackgroundTransparency = 1
CarPrev.Text = "◂"
CarPrev.TextSize = 16
CarPrev.Font = Enum.Font.GothamBold
CarPrev.TextColor3 = Color3.fromRGB(255, 60, 60)
CarPrev.ZIndex = 4
CarPrev.Parent = carRow

local CarLbl = Instance.new("TextLabel")
CarLbl.Size = UDim2.new(1, -60, 1, 0)
CarLbl.Position = UDim2.new(0, 30, 0, 0)
CarLbl.BackgroundTransparency = 1
CarLbl.Text = carList[carIdx]
CarLbl.TextSize = 13
CarLbl.Font = Enum.Font.GothamBold
CarLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
CarLbl.ZIndex = 4
CarLbl.Parent = carRow

local CarNext = Instance.new("TextButton")
CarNext.Size = UDim2.new(0, 30, 1, 0)
CarNext.Position = UDim2.new(1, -30, 0, 0)
CarNext.BackgroundTransparency = 1
CarNext.Text = "▸"
CarNext.TextSize = 16
CarNext.Font = Enum.Font.GothamBold
CarNext.TextColor3 = Color3.fromRGB(255, 60, 60)
CarNext.ZIndex = 4
CarNext.Parent = carRow

CarPrev.MouseButton1Click:Connect(function()
    carIdx = (carIdx - 2) % #carList + 1
    CarLbl.Text = carList[carIdx]
end)
CarNext.MouseButton1Click:Connect(function()
    carIdx = carIdx % #carList + 1
    CarLbl.Text = carList[carIdx]
end)

-- ── FLING SÜRESİ ──────────────────────────────────────────────────
sep(228)
secLabel("› FLING DURATION (sn)", 238)

local durRow = row(256, 34)
local flingDur = CFG.FlingDuration

local DurDown = Instance.new("TextButton")
DurDown.Size = UDim2.new(0, 34, 1, 0)
DurDown.BackgroundTransparency = 1
DurDown.Text = "−"
DurDown.TextSize = 18
DurDown.Font = Enum.Font.GothamBold
DurDown.TextColor3 = Color3.fromRGB(255, 60, 60)
DurDown.ZIndex = 4
DurDown.Parent = durRow

local DurVal = Instance.new("TextLabel")
DurVal.Size = UDim2.new(1, -68, 1, 0)
DurVal.Position = UDim2.new(0, 34, 0, 0)
DurVal.BackgroundTransparency = 1
DurVal.Text = tostring(flingDur) .. "s"
DurVal.TextSize = 13
DurVal.Font = Enum.Font.GothamBold
DurVal.TextColor3 = Color3.fromRGB(255, 255, 255)
DurVal.ZIndex = 4
DurVal.Parent = durRow

local DurUp = Instance.new("TextButton")
DurUp.Size = UDim2.new(0, 34, 1, 0)
DurUp.Position = UDim2.new(1, -34, 0, 0)
DurUp.BackgroundTransparency = 1
DurUp.Text = "+"
DurUp.TextSize = 18
DurUp.Font = Enum.Font.GothamBold
DurUp.TextColor3 = Color3.fromRGB(255, 60, 60)
DurUp.ZIndex = 4
DurUp.Parent = durRow

DurDown.MouseButton1Click:Connect(function()
    flingDur = math.max(1, flingDur - 0.5)
    DurVal.Text = tostring(flingDur) .. "s"
end)
DurUp.MouseButton1Click:Connect(function()
    flingDur = math.min(15, flingDur + 0.5)
    DurVal.Text = tostring(flingDur) .. "s"
end)

-- ── SHAKE GÜCÜ ────────────────────────────────────────────────────
sep(300)
secLabel("› FLING POWER", 310)

local powRow = row(328, 34)
local shakePow = CFG.ShakeRange

local PowDown = Instance.new("TextButton")
PowDown.Size = UDim2.new(0, 34, 1, 0)
PowDown.BackgroundTransparency = 1
PowDown.Text = "−"
PowDown.TextSize = 18
PowDown.Font = Enum.Font.GothamBold
PowDown.TextColor3 = Color3.fromRGB(255, 60, 60)
PowDown.ZIndex = 4
PowDown.Parent = powRow

local PowVal = Instance.new("TextLabel")
PowVal.Size = UDim2.new(1, -68, 1, 0)
PowVal.Position = UDim2.new(0, 34, 0, 0)
PowVal.BackgroundTransparency = 1
PowVal.Text = tostring(shakePow)
PowVal.TextSize = 13
PowVal.Font = Enum.Font.GothamBold
PowVal.TextColor3 = Color3.fromRGB(255, 255, 255)
PowVal.ZIndex = 4
PowVal.Parent = powRow

local PowUp = Instance.new("TextButton")
PowUp.Size = UDim2.new(0, 34, 1, 0)
PowUp.Position = UDim2.new(1, -34, 0, 0)
PowUp.BackgroundTransparency = 1
PowUp.Text = "+"
PowUp.TextSize = 18
PowUp.Font = Enum.Font.GothamBold
PowUp.TextColor3 = Color3.fromRGB(255, 60, 60)
PowUp.ZIndex = 4
PowUp.Parent = powRow

PowDown.MouseButton1Click:Connect(function()
    shakePow = math.max(1, shakePow - 1)
    PowVal.Text = tostring(shakePow)
end)
PowUp.MouseButton1Click:Connect(function()
    shakePow = math.min(20, shakePow + 1)
    PowVal.Text = tostring(shakePow)
end)

-- ── LAUNCH ────────────────────────────────────────────────────────
sep(372)

local LaunchBtn = Instance.new("TextButton")
LaunchBtn.Size = UDim2.new(1, -30, 0, 36)
LaunchBtn.Position = UDim2.new(0, 15, 0, 378)
LaunchBtn.BackgroundColor3 = Color3.fromRGB(200, 25, 25)
LaunchBtn.Text = "⚡  FLING"
LaunchBtn.TextSize = 15
LaunchBtn.Font = Enum.Font.GothamBold
LaunchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LaunchBtn.BorderSizePixel = 0
LaunchBtn.ZIndex = 3
LaunchBtn.Parent = Main
mkCorner(LaunchBtn, 8)
mkGrad(LaunchBtn,
    Color3.fromRGB(255,65,65),
    Color3.fromRGB(160,8,8), 135)

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -30, 0, 14)
StatusLbl.Position = UDim2.new(0, 15, 0, 420)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "● Ready"
StatusLbl.TextSize = 10
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextColor3 = Color3.fromRGB(80, 80, 100)
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.ZIndex = 3
StatusLbl.Parent = Main

local function setStatus(msg, col)
    StatusLbl.Text = "● " .. msg
    StatusLbl.TextColor3 = col or Color3.fromRGB(80,80,100)
end

-- ── DRAG ──────────────────────────────────────────────────────────
do
    local drag, dStart, fStart
    Top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dStart = i.Position; fStart = Main.Position
        end
    end)
    Top.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            Main.Position = UDim2.new(
                fStart.X.Scale, fStart.X.Offset + d.X,
                fStart.Y.Scale, fStart.Y.Offset + d.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--   FLING LOGİC
-- ═══════════════════════════════════════════════════════════════

local flingActive = false
local flingConn   = nil

local function getChar()
    return LP.Character
end

local function findCar()
    -- Workspace.Vehicles içinde VehicleSeat olan ilk aracı döndür
    local vFolder = workspace:FindFirstChild("Vehicles")
    if not vFolder then return nil end
    local found = nil
    for _, v in ipairs(vFolder:GetChildren()) do
        local seats = v:FindFirstChild("Seats")
        if seats and seats:FindFirstChild("VehicleSeat") then
            found = v  -- en son eklenenı al
        end
    end
    return found
end

local function getSeat(car)
    if not car then return nil end
    local seats = car:FindFirstChild("Seats")
    return seats and seats:FindFirstChild("VehicleSeat")
end

local function doSpawn()
    setStatus("Spawning " .. carList[carIdx] .. "...", Color3.fromRGB(255,200,50))
    local ok, err = pcall(function()
        local args = {"PickingCar", carList[carIdx]}
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Ca1r"):FireServer(table.unpack(args))
    end)
    if not ok then
        setStatus("Remote hatası: " .. tostring(err), Color3.fromRGB(255,70,70))
        return nil
    end
    task.wait(2.5)
    return findCar()
end

local function doSit(car)
    local seat = getSeat(car)
    if not seat then
        setStatus("Koltuk bulunamadı!", Color3.fromRGB(255,70,70))
        return false
    end
    local char = getChar()
    if not char then return false end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    hrp.CFrame = seat.CFrame * CFrame.new(0, 4, 0)
    task.wait(0.2)
    seat:Sit(hum)
    task.wait(0.3)
    setStatus("Koltukta ✓", Color3.fromRGB(100, 255, 100))
    return true
end

local function stopFling()
    flingActive = false
    if flingConn then flingConn:Disconnect(); flingConn = nil end
    LaunchBtn.Text = "⚡  FLING"
    mkGrad(LaunchBtn,
        Color3.fromRGB(255,65,65),
        Color3.fromRGB(160,8,8), 135)
end

-- ─── ANA FLING FONKSİYONU ─────────────────────────────────────────
-- VFling tekniği:
--   Her frame'de koltuğu hedefin HRP'sine rastgele ofsetle ışınlarız.
--   Fizik motoru bu dev "hızı" hedefin karakterine uygular → fling!
-- ─────────────────────────────────────────────────────────────────
local function runFling(target, car)
    local seat = getSeat(car)
    if not seat then stopFling(); return end

    flingActive = true
    LaunchBtn.Text = "■  STOP"
    mkGrad(LaunchBtn,
        Color3.fromRGB(55,55,55),
        Color3.fromRGB(25,25,25), 135)

    local t0      = tick()
    local toggle  = 1
    local pow     = shakePow

    flingConn = RunService.Heartbeat:Connect(function(dt)
        if not flingActive then return end

        -- Süre bitti mi?
        if tick() - t0 >= flingDur then
            stopFling()
            setStatus("Fling bitti!", Color3.fromRGB(255, 200, 50))
            return
        end

        -- Hedef hâlâ orada mı?
        if not (target and target.Character) then
            stopFling()
            setStatus("Hedef ayrıldı!", Color3.fromRGB(255,140,50))
            return
        end

        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP then return end

        -- ★ VFling core:
        --   Koltuk → hedefin üstüne gidiyor; her frame'de rastgele titreşim
        toggle = -toggle
        local rx = (math.random() * 2 - 1) * pow * toggle
        local rz = (math.random() * 2 - 1) * pow * toggle
        local ry = math.random() * pow * 0.5

        seat.CFrame = CFrame.new(
            tHRP.Position.X + rx,
            tHRP.Position.Y + ry,
            tHRP.Position.Z + rz
        ) * CFrame.Angles(
            math.rad(math.random(-30,30)),
            math.rad(math.random(-180,180)),
            math.rad(math.random(-30,30))
        )

        setStatus(
            string.format("Flinging: %s  [%.1fs]", target.Name, flingDur-(tick()-t0)),
            Color3.fromRGB(80, 255, 100)
        )
    end)
end

-- ─── LAUNCH BUTTON ────────────────────────────────────────────────
LaunchBtn.MouseButton1Click:Connect(function()
    if flingActive then stopFling(); return end

    if not selectedTarget then
        setStatus("Önce hedef seç!", Color3.fromRGB(255,160,50))
        for i = 1, 4 do
            LaunchBtn.Position = LaunchBtn.Position + UDim2.new(0, i%2==0 and 4 or -4, 0, 0)
            task.wait(0.05)
        end
        return
    end

    if not Players:FindFirstChild(selectedTarget.Name) then
        setStatus("Hedef oyunda yok!", Color3.fromRGB(255,70,70))
        selectedTarget = nil
        DropLbl.Text = "Select player..."
        DropLbl.TextColor3 = Color3.fromRGB(150,150,150)
        return
    end

    -- Orijinal konumu kaydet
    local origChar = getChar()
    local origCF   = origChar and origChar:FindFirstChild("HumanoidRootPart")
                    and origChar.HumanoidRootPart.CFrame
                    or CFrame.new(0, 50, 0)

    -- 1) Araç spawn et
    local car = doSpawn()
    if not car then return end

    -- 2) İçine otur
    if not doSit(car) then return end
    task.wait(0.3)

    -- 3) Hedefin yanına ışınla (araba dahil)
    local tHRP = selectedTarget.Character
                 and selectedTarget.Character:FindFirstChild("HumanoidRootPart")
    if tHRP then
        local seat = getSeat(car)
        if seat then
            seat.CFrame = CFrame.new(tHRP.Position + Vector3.new(2, 2, 0))
            task.wait(CFG.PreDelay)
        end
    end

    -- 4) FLING!
    setStatus("Flinging...", Color3.fromRGB(255, 200, 50))
    runFling(selectedTarget, car)

    -- 5) Fling bitince eski konuma dön
    task.delay(flingDur + 0.4, function()
        local ch = getChar()
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            -- Önce arabadan çık
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then hum.Sit = false end
            task.wait(0.1)
            -- Geri ışınla
            ch.HumanoidRootPart.CFrame = origCF
            setStatus("Eski konuma döndün ✓", Color3.fromRGB(100,200,255))
        end
    end)
end)

LaunchBtn.MouseEnter:Connect(function()
    if not flingActive then
        TweenService:Create(LaunchBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(255, 55, 55)
        }):Play()
    end
end)
LaunchBtn.MouseLeave:Connect(function()
    if not flingActive then
        TweenService:Create(LaunchBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(200, 25, 25)
        }):Play()
    end
end)

fillDrop()
setStatus("Ready — hedef seç ve FLING'e bas", Color3.fromRGB(80,80,100))
print("[FlingPro v2.0] Loaded. VFling tekniği aktif.")
