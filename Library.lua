--[[
╔══════════════════════════════════════════════════════════════════╗
║                        EMBER UI LIBRARY                         ║
║                     Version 1.0.0 | Public                      ║
║          github.com/USERNAME/EmberUI  |  MIT License            ║
╚══════════════════════════════════════════════════════════════════╝

  Load via:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/EmberUI/main/Library.lua"))()

  Quick Start:
    local Ember = loadstring(...)()
    local Window = Ember:CreateWindow({ Title = "My Script", Subtitle = "v1.0" })
    local Tab    = Window:CreateTab("Home")
    local Sec    = Tab:CreateSection("General")
    Sec:AddToggle({ Label = "God Mode", Default = false, Callback = function(v) print(v) end })
    Sec:AddSlider({ Label = "Speed",    Min = 0, Max = 100, Default = 16, Callback = function(v) print(v) end })
]]

-- ─── SERVICES ────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ─── DESIGN TOKENS ───────────────────────────────────────────────────────────
local Theme = {
    Background      = Color3.fromHex("1e1f23"),  -- deep charcoal
    Surface         = Color3.fromHex("2a2c31"),  -- panel containers
    SurfaceHover    = Color3.fromHex("32353b"),  -- hovered panels
    SurfaceActive   = Color3.fromHex("22242a"),  -- pressed / inset
    Border          = Color3.fromHex("3a3d44"),  -- subtle borders
    Accent          = Color3.fromHex("f0a64b"),  -- warm orange
    AccentDark      = Color3.fromHex("c07a20"),  -- darker accent
    AccentGlow      = Color3.fromHex("f0a64b"),  -- glow colour
    TextPrimary     = Color3.fromHex("e8e9ec"),  -- main text
    TextSecondary   = Color3.fromHex("9a9da6"),  -- dimmed text
    TextDisabled    = Color3.fromHex("5a5d66"),  -- disabled
    Success         = Color3.fromHex("4caf8a"),
    Danger          = Color3.fromHex("e05c5c"),
    SliderTrack     = Color3.fromHex("1a1b1f"),
    ScrollBar       = Color3.fromHex("3a3d44"),
    ToggleOff       = Color3.fromHex("3a3d44"),
    ToggleOn        = Color3.fromHex("f0a64b"),
    DropdownBg      = Color3.fromHex("22242a"),
    DropdownItem    = Color3.fromHex("2a2c31"),
    DropdownHover   = Color3.fromHex("34373e"),
    Separator       = Color3.fromHex("35383f"),
}

local Font = {
    Regular  = Enum.Font.GothamMedium,
    Bold     = Enum.Font.GothamBold,
    SemiBold = Enum.Font.GothamSemibold,
    Mono     = Enum.Font.Code,
}

local Ease = {
    Fast     = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Medium   = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow     = TweenInfo.new(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Bounce   = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    Spring   = TweenInfo.new(0.5,  Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

-- ─── UTILITY ─────────────────────────────────────────────────────────────────
local Util = {}

function Util.Tween(obj, info, goal)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

function Util.Lerp(a, b, t) return a + (b - a) * t end

function Util.Round(n, d)
    local m = 10^(d or 0)
    return math.floor(n * m + 0.5) / m
end

function Util.Clamp(v, min, max) return math.max(min, math.min(max, v)) end

function Util.Map(v, in_min, in_max, out_min, out_max)
    return (v - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
end

function Util.HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if     i == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    elseif i == 5 then r,g,b = v,p,q
    end
    return Color3.new(r, g, b)
end

function Util.RGBtoHSV(c)
    local r, g, b = c.R, c.G, c.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local d   = max - min
    local h, s, v = 0, 0, max
    if max ~= 0 then s = d / max end
    if max ~= min then
        if     max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, s, v
end

function Util.ColorToHex(c)
    return string.format("%02X%02X%02X",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end

function Util.HexToColor(hex)
    hex = hex:gsub("#","")
    local r = tonumber(hex:sub(1,2), 16) or 0
    local g = tonumber(hex:sub(3,4), 16) or 0
    local b = tonumber(hex:sub(5,6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

function Util.New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            if typeof(inst[k]) == "RBXScriptSignal" then
                inst[k]:Connect(v)
            else
                inst[k] = v
            end
        end
    end
    for _, child in ipairs(children or {}) do
        if child then child.Parent = inst end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

function Util.MakeCorner(radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end

function Util.MakePadding(top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    return p
end

function Util.MakeStroke(color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color or Theme.Border
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0
    return s
end

function Util.MakeListLayout(gap, dir, align)
    local l = Instance.new("UIListLayout")
    l.Padding          = UDim.new(0, gap or 6)
    l.FillDirection    = dir   or Enum.FillDirection.Vertical
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Left
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    return l
end

function Util.MakeGridLayout(cellSize, cellPadding, cols)
    local g = Instance.new("UIGridLayout")
    g.CellSize            = cellSize    or UDim2.new(0.5, -6, 0, 1)
    g.CellPaddingH        = UDim.new(0, cellPadding or 8)
    g.CellPaddingV        = UDim.new(0, cellPadding or 8)
    g.FillDirection        = Enum.FillDirection.Horizontal
    g.HorizontalAlignment  = Enum.HorizontalAlignment.Left
    g.VerticalAlignment    = Enum.VerticalAlignment.Top
    g.SortOrder            = Enum.SortOrder.LayoutOrder
    return g
end

-- Auto-resize a Frame to match its UIListLayout content
function Util.AutoSize(frame, layout, pad)
    pad = pad or 0
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + pad)
    end)
    frame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + pad)
end

-- Drag logic
function Util.MakeDraggable(handle, target)
    local dragging, start, origin = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start  = i.Position
            origin = target.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - start
            target.Position = UDim2.new(
                origin.X.Scale, origin.X.Offset + delta.X,
                origin.Y.Scale, origin.Y.Offset + delta.Y
            )
        end
    end)
end

-- ─── EMBER LIBRARY ROOT ───────────────────────────────────────────────────────
local Ember = {}
Ember.__index = Ember
Ember._version = "1.0.0"
Ember._windows  = {}

-- Destroy existing GUI on re-inject
pcall(function()
    if CoreGui:FindFirstChild("EmberUI") then
        CoreGui.EmberUI:Destroy()
    end
end)

-- ─── SCREEN GUI ROOT ─────────────────────────────────────────────────────────
local ScreenGui = Util.New("ScreenGui", {
    Name            = "EmberUI",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset  = true,
    DisplayOrder    = 999,
    Parent          = CoreGui,
})

-- ─── NOTIFICATION SYSTEM ──────────────────────────────────────────────────────
local NotifHolder = Util.New("Frame", {
    Name              = "Notifications",
    Size              = UDim2.new(0, 300, 1, 0),
    Position          = UDim2.new(1, -310, 0, 0),
    BackgroundTransparency = 1,
    Parent            = ScreenGui,
})
local notifLayout = Util.MakeListLayout(8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Parent = NotifHolder
Util.MakePadding(0, 0, 16, 0).Parent = NotifHolder

function Ember:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type     or "info"  -- "info" | "success" | "error"

    local accent = Theme.Accent
    if ntype == "success" then accent = Theme.Success
    elseif ntype == "error" then accent = Theme.Danger end

    local card = Util.New("Frame", {
        Name              = "Notif",
        Size              = UDim2.new(1, 0, 0, 70),
        BackgroundColor3  = Theme.Surface,
        BackgroundTransparency = 1,
        ClipsDescendants  = true,
        Parent            = NotifHolder,
    })
    Util.MakeCorner(8).Parent = card
    Util.MakeStroke(accent, 1, 0.5).Parent = card

    -- accent bar
    Util.New("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Parent           = card,
    })

    local inner = Util.New("Frame", {
        Size             = UDim2.new(1, -3, 1, 0),
        Position         = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1,
        Parent           = card,
    })
    Util.MakePadding(10, 12, 10, 12).Parent = inner
    local ll = Util.MakeListLayout(4)
    ll.Parent = inner

    Util.New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.TextPrimary,
        Font             = Font.Bold,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = inner,
    })
    Util.New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text             = message,
        TextColor3       = Theme.TextSecondary,
        Font             = Font.Regular,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Parent           = inner,
    })

    -- animate in
    Util.Tween(card, Ease.Medium, { BackgroundTransparency = 0 })

    task.delay(duration, function()
        Util.Tween(card, Ease.Medium, { BackgroundTransparency = 1 }):Wait()
        card:Destroy()
    end)
end

-- ─── WINDOW CLASS ─────────────────────────────────────────────────────────────
local Window = {}
Window.__index = Window

function Ember:CreateWindow(opts)
    opts = opts or {}
    local title    = opts.Title    or "Ember"
    local subtitle = opts.Subtitle or ""
    local width    = opts.Width    or 780
    local height   = opts.Height   or 520
    local tabs_def = opts.Tabs     or {"Home","Settings","Players","Visuals","Advanced","Config"}

    local win = setmetatable({}, Window)
    win._tabs       = {}
    win._activeTab  = nil
    win._visible    = true

    -- ── Root Frame ────────────────────────────────────────────────────────────
    local Root = Util.New("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, width, 0, height),
        Position         = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        Parent           = ScreenGui,
    })
    Util.MakeCorner(10).Parent = Root
    Util.MakeStroke(Theme.Border, 1).Parent = Root

    -- shadow
    local Shadow = Util.New("ImageLabel", {
        Name              = "Shadow",
        Size              = UDim2.new(1, 50, 1, 50),
        Position          = UDim2.new(0, -25, 0, -25),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Color3.new(0,0,0),
        ImageTransparency = 0.5,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49,49,450,450),
        ZIndex            = -1,
        Parent            = Root,
    })

    win._root = Root

    -- ── Title Bar ─────────────────────────────────────────────────────────────
    local TitleBar = Util.New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Root,
    })
    Util.MakeCorner(10).Parent = TitleBar

    -- square bottom corners on titlebar
    Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 1,
        Parent           = TitleBar,
    })

    -- Logo dot accent
    local LogoDot = Util.New("Frame", {
        Size             = UDim2.new(0, 8, 0, 8),
        Position         = UDim2.new(0, 18, 0.5, -4),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = TitleBar,
    })
    Util.MakeCorner(4).Parent = LogoDot

    Util.New("TextLabel", {
        Size             = UDim2.new(0, 160, 1, 0),
        Position         = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.TextPrimary,
        Font             = Font.Bold,
        TextSize         = 15,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 3,
        Parent           = TitleBar,
    })

    if subtitle ~= "" then
        Util.New("TextLabel", {
            Size             = UDim2.new(0, 160, 1, 0),
            Position         = UDim2.new(0, 34+100, 0, 0),
            BackgroundTransparency = 1,
            Text             = subtitle,
            TextColor3       = Theme.TextSecondary,
            Font             = Font.Regular,
            TextSize         = 11,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 3,
            Parent           = TitleBar,
        })
    end

    -- Close button
    local CloseBtn = Util.New("TextButton", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -40, 0.5, -14),
        BackgroundColor3 = Color3.fromHex("3a3d44"),
        Text             = "✕",
        TextColor3       = Theme.TextSecondary,
        Font             = Font.Bold,
        TextSize         = 12,
        ZIndex           = 4,
        Parent           = TitleBar,
        AutoButtonColor  = false,
    })
    Util.MakeCorner(6).Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function()
        Util.Tween(CloseBtn, Ease.Fast, { BackgroundColor3 = Theme.Danger, TextColor3 = Color3.new(1,1,1) })
    end)
    CloseBtn.MouseLeave:Connect(function()
        Util.Tween(CloseBtn, Ease.Fast, { BackgroundColor3 = Color3.fromHex("3a3d44"), TextColor3 = Theme.TextSecondary })
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        win:Toggle()
    end)

    -- Minimize button
    local MinBtn = Util.New("TextButton", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -74, 0.5, -14),
        BackgroundColor3 = Color3.fromHex("3a3d44"),
        Text             = "─",
        TextColor3       = Theme.TextSecondary,
        Font             = Font.Bold,
        TextSize         = 10,
        ZIndex           = 4,
        Parent           = TitleBar,
        AutoButtonColor  = false,
    })
    Util.MakeCorner(6).Parent = MinBtn

    MinBtn.MouseEnter:Connect(function()
        Util.Tween(MinBtn, Ease.Fast, { BackgroundColor3 = Theme.SurfaceHover })
    end)
    MinBtn.MouseLeave:Connect(function()
        Util.Tween(MinBtn, Ease.Fast, { BackgroundColor3 = Color3.fromHex("3a3d44") })
    end)

    -- ── Tab Navigation Bar ────────────────────────────────────────────────────
    local TabBar = Util.New("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, 0, 0, 40),
        Position         = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Root,
    })

    local TabBarInner = Util.New("ScrollingFrame", {
        Size             = UDim2.new(1, -20, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 0,
        ScrollingDirection    = Enum.ScrollingDirection.X,
        CanvasSize        = UDim2.new(0, 0, 1, 0),
        AutomaticCanvasSize   = Enum.AutomaticSize.X,
        Parent           = TabBar,
    })

    local TabLayout = Util.MakeListLayout(4, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left)
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Parent = TabBarInner

    -- thin separator below tab bar
    Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel  = 0,
        Parent           = TabBar,
    })

    win._tabBar     = TabBarInner
    win._tabLayout  = TabLayout

    -- ── Content Area ──────────────────────────────────────────────────────────
    local ContentArea = Util.New("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -16, 1, -(52 + 40 + 8 + 8)),
        Position         = UDim2.new(0, 8, 0, 52 + 40 + 8),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Root,
    })
    win._contentArea = ContentArea

    -- ── Draggable ─────────────────────────────────────────────────────────────
    Util.MakeDraggable(TitleBar, Root)

    -- ── Tab Button Creator (internal) ──────────────────────────────────────────
    function win:_makeTabButton(label)
        local btn = Util.New("TextButton", {
            Size             = UDim2.new(0, 0, 1, -8),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text             = "",
            AutoButtonColor  = false,
            Parent           = TabBarInner,
        })
        Util.MakePadding(0, 12, 0, 12).Parent = btn

        local lbl = Util.New("TextLabel", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = label,
            TextColor3       = Theme.TextSecondary,
            Font             = Font.SemiBold,
            TextSize         = 12,
            Parent           = btn,
        })

        -- underline indicator
        local Indicator = Util.New("Frame", {
            Size             = UDim2.new(1, -8, 0, 2),
            Position         = UDim2.new(0, 4, 1, -2),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            BackgroundTransparency = 1,
            Parent           = btn,
        })
        Util.MakeCorner(2).Parent = Indicator

        btn.MouseEnter:Connect(function()
            if self._activeTab and self._activeTab._label ~= label then
                Util.Tween(lbl, Ease.Fast, { TextColor3 = Theme.TextPrimary })
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._activeTab and self._activeTab._label ~= label then
                Util.Tween(lbl, Ease.Fast, { TextColor3 = Theme.TextSecondary })
            end
        end)

        return btn, lbl, Indicator
    end

    -- ── CreateTab ─────────────────────────────────────────────────────────────
    function win:CreateTab(label)
        local tab = {}
        tab._label    = label
        tab._sections = {}
        tab._win      = self

        local btn, lbl, indicator = self:_makeTabButton(label)
        tab._btn       = btn
        tab._lbl       = lbl
        tab._indicator = indicator

        -- Scroll frame for sections grid
        local scroll = Util.New("ScrollingFrame", {
            Name              = "TabContent_"..label,
            Size              = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel   = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.ScrollBar,
            CanvasSize         = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible            = false,
            Parent             = ContentArea,
        })

        local grid = Util.MakeGridLayout(
            UDim2.new(0.5, -5, 0, 0),
            10
        )
        grid.AutomaticSize = Enum.AutomaticSize.Y
        grid.FillDirectionMaxCells = 2
        grid.Parent = scroll

        -- auto height for grid cells isn't native, we use a different approach:
        -- Each column is a VFrame. We'll use two column frames instead of grid.
        grid:Destroy()

        -- Two-column layout using two VFrames
        local ColContainer = Util.New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = scroll,
        })

        local ColLeft = Util.New("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Parent = ColContainer,
        })
        local ColLeftLayout = Util.MakeListLayout(8)
        ColLeftLayout.Parent = ColLeft

        local ColRight = Util.New("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 5, 0, 0),
            Parent = ColContainer,
        })
        local ColRightLayout = Util.MakeListLayout(8)
        ColRightLayout.Parent = ColRight

        tab._scroll   = scroll
        tab._colLeft  = ColLeft
        tab._colRight = ColRight
        tab._colIdx   = 0  -- tracks which column gets next section

        btn.MouseButton1Click:Connect(function()
            self:_selectTab(tab)
        end)

        table.insert(self._tabs, tab)

        if #self._tabs == 1 then
            self:_selectTab(tab)
        end

        -- ── CreateSection ─────────────────────────────────────────────────────
        function tab:CreateSection(title, column)
            local sec = {}
            sec._tab = self

            -- decide column (auto-alternate or forced)
            local useLeft
            if column == "left" then
                useLeft = true
            elseif column == "right" then
                useLeft = false
            else
                self._colIdx = self._colIdx + 1
                useLeft = (self._colIdx % 2 == 1)
            end

            local parent = useLeft and self._colLeft or self._colRight

            -- Card
            local Card = Util.New("Frame", {
                Name             = "Section_"..title,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                Parent           = parent,
            })
            Util.MakeCorner(8).Parent = Card
            Util.MakeStroke(Theme.Border, 1).Parent = Card

            local CardInner = Util.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent           = Card,
            })
            Util.MakePadding(12, 14, 14, 14).Parent = CardInner

            local CardLayout = Util.MakeListLayout(0)
            CardLayout.Parent = CardInner

            -- Section Header
            local Header = Util.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder      = 0,
                Parent           = CardInner,
            })

            Util.New("TextLabel", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = title:upper(),
                TextColor3       = Theme.Accent,
                Font             = Font.Bold,
                TextSize         = 11,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = Header,
            })

            -- divider
            local Divider = Util.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Separator,
                BorderSizePixel  = 0,
                LayoutOrder      = 1,
                Parent           = CardInner,
            })

            -- Elements container
            local ElemContainer = Util.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder      = 2,
                Parent           = CardInner,
            })
            local ElemLayout = Util.MakeListLayout(0)
            ElemLayout.Parent = ElemContainer

            sec._container = ElemContainer
            sec._layout    = ElemLayout
            sec._order     = 0

            -- ── Shared row builder ──────────────────────────────────────────
            local function makeRow(h)
                sec._order = sec._order + 1
                local row = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, h or 40),
                    BackgroundTransparency = 1,
                    LayoutOrder      = sec._order,
                    Parent           = ElemContainer,
                })
                Util.MakePadding(0, 0, 0, 0).Parent = row
                return row
            end

            -- ── AddToggle ──────────────────────────────────────────────────
            function sec:AddToggle(opts)
                opts = opts or {}
                local label    = opts.Label    or "Toggle"
                local default  = opts.Default  ~= nil and opts.Default or false
                local tooltip  = opts.Tooltip  or nil
                local callback = opts.Callback or function() end
                local state    = default

                local row = makeRow(38)

                Util.New("TextLabel", {
                    Size             = UDim2.new(1, -56, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Font.Regular,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                -- Toggle track
                local Track = Util.New("Frame", {
                    Size             = UDim2.new(0, 36, 0, 20),
                    Position         = UDim2.new(1, -44, 0.5, -10),
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                    BorderSizePixel  = 0,
                    Parent           = row,
                })
                Util.MakeCorner(10).Parent = Track

                local Knob = Util.New("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = UDim2.new(0, state and 18 or 3, 0.5, -7),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel  = 0,
                    Parent           = Track,
                })
                Util.MakeCorner(7).Parent = Knob

                -- Hitbox
                local Hit = Util.New("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = "",
                    Parent           = row,
                    AutoButtonColor  = false,
                })

                local function setToggle(val, fire)
                    state = val
                    Util.Tween(Track, Ease.Fast, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff })
                    Util.Tween(Knob,  Ease.Fast, { Position = UDim2.new(0, state and 18 or 3, 0.5, -7) })
                    if fire then callback(state) end
                end

                Hit.MouseButton1Click:Connect(function()
                    setToggle(not state, true)
                end)

                local ctrl = { _state = state }
                function ctrl:Set(v) setToggle(v, false) end
                function ctrl:Get() return state end
                return ctrl
            end

            -- ── AddSlider ──────────────────────────────────────────────────
            function sec:AddSlider(opts)
                opts = opts or {}
                local label    = opts.Label    or "Slider"
                local min      = opts.Min      or 0
                local max      = opts.Max      or 100
                local default  = opts.Default  or min
                local suffix   = opts.Suffix   or ""
                local step     = opts.Step     or 1
                local callback = opts.Callback or function() end
                local value    = Util.Clamp(default, min, max)

                local row = makeRow(52)

                -- label + value display
                local TopRow = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent           = row,
                })
                Util.New("TextLabel", {
                    Size             = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Font.Regular,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = TopRow,
                })
                local ValLabel = Util.New("TextLabel", {
                    Size             = UDim2.new(0.3, 0, 1, 0),
                    Position         = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = tostring(value) .. suffix,
                    TextColor3       = Theme.Accent,
                    Font             = Font.SemiBold,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Right,
                    Parent           = TopRow,
                })

                -- Track
                local TrackOuter = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 14),
                    Position         = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel  = 0,
                    Parent           = row,
                    ClipsDescendants = true,
                })
                Util.MakeCorner(7).Parent = TrackOuter

                local pct = (value - min) / (max - min)
                local Fill = Util.New("Frame", {
                    Size             = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel  = 0,
                    Parent           = TrackOuter,
                })
                Util.MakeCorner(7).Parent = Fill

                -- Thumb
                local Thumb = Util.New("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    Position         = UDim2.new(pct, -7, 0, 0),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel  = 0,
                    Parent           = TrackOuter,
                })
                Util.MakeCorner(7).Parent = Thumb

                local Hit = Util.New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 40),
                    Position         = UDim2.new(0, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = row,
                })

                local dragging = false

                local function updateSlider(inputX)
                    local abs = TrackOuter.AbsolutePosition.X
                    local sz  = TrackOuter.AbsoluteSize.X
                    local p   = Util.Clamp((inputX - abs) / sz, 0, 1)
                    local raw = p * (max - min) + min
                    value = Util.Round(raw / step) * step
                    value = Util.Clamp(value, min, max)
                    local np = (value - min) / (max - min)
                    Fill.Size  = UDim2.new(np, 0, 1, 0)
                    Thumb.Position = UDim2.new(np, -7, 0, 0)
                    ValLabel.Text = tostring(value) .. suffix
                    callback(value)
                end

                Hit.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(i.Position.X)
                    end
                end)
                Hit.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(i.Position.X)
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v)
                    value = Util.Clamp(v, min, max)
                    local np = (value - min) / (max - min)
                    Fill.Size = UDim2.new(np, 0, 1, 0)
                    Thumb.Position = UDim2.new(np, -7, 0, 0)
                    ValLabel.Text = tostring(value) .. suffix
                end
                function ctrl:Get() return value end
                return ctrl
            end

            -- ── AddDropdown ────────────────────────────────────────────────
            function sec:AddDropdown(opts)
                opts = opts or {}
                local label    = opts.Label    or "Dropdown"
                local items    = opts.Items    or {"none"}
                local default  = opts.Default  or items[1] or "none"
                local callback = opts.Callback or function() end
                local selected = default

                local row = makeRow(62)

                Util.New("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Font.Regular,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                -- Dropdown button
                local DDBtn = Util.New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    Position         = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Theme.DropdownBg,
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = row,
                })
                Util.MakeCorner(6).Parent = DDBtn
                Util.MakeStroke(Theme.Border, 1).Parent = DDBtn

                local DDLabel = Util.New("TextLabel", {
                    Size             = UDim2.new(1, -30, 1, 0),
                    Position         = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = selected,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Font.Regular,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = DDBtn,
                })

                local Arrow = Util.New("TextLabel", {
                    Size             = UDim2.new(0, 20, 1, 0),
                    Position         = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = "▾",
                    TextColor3       = Theme.TextSecondary,
                    Font             = Font.Regular,
                    TextSize         = 14,
                    Parent           = DDBtn,
                })

                -- Dropdown list (shown above/below)
                local ListFrame = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    Position         = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Theme.DropdownBg,
                    BorderSizePixel  = 0,
                    Visible          = false,
                    ZIndex           = 10,
                    ClipsDescendants = true,
                    Parent           = DDBtn,
                })
                Util.MakeCorner(6).Parent = ListFrame
                Util.MakeStroke(Theme.Border, 1).Parent = ListFrame

                local ListLayout = Util.MakeListLayout(0)
                ListLayout.Parent = ListFrame

                local function closeList()
                    Util.Tween(Arrow, Ease.Fast, { Rotation = 0 })
                    ListFrame.Visible = false
                end

                for _, item in ipairs(items) do
                    local ItemBtn = Util.New("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.DropdownItem,
                        Text             = "",
                        AutoButtonColor  = false,
                        ZIndex           = 11,
                        Parent           = ListFrame,
                    })
                    Util.New("TextLabel", {
                        Size             = UDim2.new(1, 0, 1, 0),
                        Position         = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text             = item,
                        TextColor3       = item == selected and Theme.Accent or Theme.TextPrimary,
                        Font             = Font.Regular,
                        TextSize         = 12,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                        ZIndex           = 12,
                        Parent           = ItemBtn,
                    })

                    ItemBtn.MouseEnter:Connect(function()
                        Util.Tween(ItemBtn, Ease.Fast, { BackgroundColor3 = Theme.DropdownHover })
                    end)
                    ItemBtn.MouseLeave:Connect(function()
                        Util.Tween(ItemBtn, Ease.Fast, { BackgroundColor3 = Theme.DropdownItem })
                    end)
                    ItemBtn.MouseButton1Click:Connect(function()
                        selected = item
                        DDLabel.Text = item
                        closeList()
                        callback(selected)
                    end)
                end

                -- Resize list to fit items
                local listH = #items * 30
                ListFrame.Size = UDim2.new(1, 0, 0, listH)

                local open = false
                DDBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        Util.Tween(Arrow, Ease.Fast, { Rotation = 180 })
                        ListFrame.Visible = true
                    else
                        closeList()
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v)
                    selected = v
                    DDLabel.Text = v
                end
                function ctrl:Get() return selected end
                return ctrl
            end

            -- ── AddButton ──────────────────────────────────────────────────
            function sec:AddButton(opts)
                opts = opts or {}
                local label    = opts.Label    or "Button"
                local sublabel = opts.SubLabel or nil
                local style    = opts.Style    or "default"  -- "default" | "danger" | "success"
                local callback = opts.Callback or function() end

                local h = sublabel and 52 or 40
                local row = makeRow(h)

                local btnColor = style == "danger"  and Theme.Danger
                             or  style == "success" and Theme.Success
                             or  Theme.Surface

                local Btn = Util.New("TextButton", {
                    Size             = UDim2.new(1, 0, 1, -4),
                    Position         = UDim2.new(0, 0, 0, 2),
                    BackgroundColor3 = btnColor,
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = row,
                })
                Util.MakeCorner(6).Parent = Btn
                Util.MakeStroke(style == "default" and Theme.Border or btnColor, 1).Parent = Btn

                local BtnLayout = Util.MakeListLayout(2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)
                BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                BtnLayout.Parent = Btn

                Util.New("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = style == "default" and Theme.TextPrimary or Color3.new(1,1,1),
                    Font             = Font.SemiBold,
                    TextSize         = 13,
                    Parent           = Btn,
                })

                if sublabel then
                    Util.New("TextLabel", {
                        Size             = UDim2.new(1, 0, 0, 14),
                        BackgroundTransparency = 1,
                        Text             = sublabel,
                        TextColor3       = style == "default" and Theme.TextSecondary or Color3.new(1,1,1),
                        Font             = Font.Regular,
                        TextSize         = 11,
                        Parent           = Btn,
                    })
                end

                local hoverColor = style == "default" and Theme.SurfaceHover
                                or style == "danger"  and Color3.fromHex("c04040")
                                or Color3.fromHex("3a8f6a")

                Btn.MouseEnter:Connect(function()
                    Util.Tween(Btn, Ease.Fast, { BackgroundColor3 = hoverColor })
                end)
                Btn.MouseLeave:Connect(function()
                    Util.Tween(Btn, Ease.Fast, { BackgroundColor3 = btnColor })
                end)
                Btn.MouseButton1Down:Connect(function()
                    Util.Tween(Btn, Ease.Fast, { BackgroundColor3 = Theme.SurfaceActive })
                end)
                Btn.MouseButton1Up:Connect(function()
                    Util.Tween(Btn, Ease.Fast, { BackgroundColor3 = hoverColor })
                    callback()
                end)
            end

            -- ── AddLabel ───────────────────────────────────────────────────
            function sec:AddLabel(opts)
                opts = opts or {}
                local text  = opts.Text  or ""
                local color = opts.Color or Theme.TextSecondary

                local row = makeRow(28)
                Util.New("TextLabel", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = text,
                    TextColor3       = color,
                    Font             = Font.Regular,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    Parent           = row,
                })
            end

            -- ── AddColorPicker ─────────────────────────────────────────────
            function sec:AddColorPicker(opts)
                opts = opts or {}
                local label    = opts.Label    or "Color"
                local default  = opts.Default  or Color3.fromRGB(240, 166, 75)
                local callback = opts.Callback or function() end

                local H, S, V = Util.RGBtoHSV(default)
                local currentColor = default

                -- Preview row
                local row = makeRow(36)

                Util.New("TextLabel", {
                    Size             = UDim2.new(1, -46, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = Theme.TextPrimary,
                    Font             = Font.Regular,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                local Preview = Util.New("TextButton", {
                    Size             = UDim2.new(0, 36, 0, 24),
                    Position         = UDim2.new(1, -40, 0.5, -12),
                    BackgroundColor3 = default,
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = row,
                })
                Util.MakeCorner(4).Parent = Preview
                Util.MakeStroke(Theme.Border, 1).Parent = Preview

                -- Picker panel (expanded below)
                sec._order = sec._order + 1
                local PickerRow = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    LayoutOrder      = sec._order,
                    Visible          = false,
                    Parent           = ElemContainer,
                })

                local PickerPanel = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 180),
                    BackgroundColor3 = Theme.SurfaceActive,
                    Parent           = PickerRow,
                })
                Util.MakeCorner(6).Parent = PickerPanel
                Util.MakePadding(10, 10, 10, 10).Parent = PickerPanel

                -- SV Square
                local SVSquare = Util.New("ImageLabel", {
                    Size             = UDim2.new(1, -110, 1, 0),
                    BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                    Image            = "rbxassetid://4155801252",  -- SV gradient asset
                    Parent           = PickerPanel,
                })
                Util.MakeCorner(4).Parent = SVSquare

                -- White gradient (left)
                local SVWhite = Util.New("ImageLabel", {
                    Size  = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://6020299385",
                    BackgroundTransparency = 1,
                    Parent = SVSquare,
                })
                -- Black gradient (bottom)
                local SVBlack = Util.New("ImageLabel", {
                    Size  = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://6020299401",
                    BackgroundTransparency = 1,
                    Parent = SVSquare,
                })

                -- SV Cursor
                local SVCursor = Util.New("Frame", {
                    Size             = UDim2.new(0, 10, 0, 10),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(S, 0, 1-V, 0),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel  = 0,
                    Parent           = SVSquare,
                })
                Util.MakeCorner(5).Parent = SVCursor
                Util.MakeStroke(Color3.new(0,0,0), 1, 0.3).Parent = SVCursor

                -- Hue bar
                local HueBar = Util.New("ImageLabel", {
                    Size             = UDim2.new(0, 16, 1, 0),
                    Position         = UDim2.new(1, -100, 0, 0),
                    Image            = "rbxassetid://6020299348",  -- hue spectrum
                    BackgroundColor3 = Color3.new(1,1,1),
                    Parent           = PickerPanel,
                })
                Util.MakeCorner(4).Parent = HueBar

                local HueCursor = Util.New("Frame", {
                    Size             = UDim2.new(1, 4, 0, 4),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(0.5, 0, H, 0),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel  = 0,
                    Parent           = HueBar,
                })
                Util.MakeCorner(2).Parent = HueCursor

                -- Color preview + hex
                local RightPanel = Util.New("Frame", {
                    Size             = UDim2.new(0, 78, 1, 0),
                    Position         = UDim2.new(1, -78, 0, 0),
                    BackgroundTransparency = 1,
                    Parent           = PickerPanel,
                })
                local RightLayout = Util.MakeListLayout(8)
                RightLayout.Parent = RightPanel

                local ColorPreview = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = currentColor,
                    Parent           = RightPanel,
                })
                Util.MakeCorner(6).Parent = ColorPreview

                local HexBox = Util.New("TextBox", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.DropdownBg,
                    Text             = "#"..Util.ColorToHex(currentColor),
                    TextColor3       = Theme.TextPrimary,
                    Font             = Font.Mono,
                    TextSize         = 11,
                    ClearTextOnFocus = false,
                    Parent           = RightPanel,
                })
                Util.MakeCorner(4).Parent = HexBox
                Util.MakePadding(0, 6, 0, 6).Parent = HexBox

                -- RGB labels
                local function makeRGB(c, ch)
                    local f = Util.New("Frame", {
                        Size             = UDim2.new(1, 0, 0, 22),
                        BackgroundColor3 = Theme.DropdownBg,
                        Parent           = RightPanel,
                    })
                    Util.MakeCorner(4).Parent = f
                    Util.New("TextLabel", {
                        Size             = UDim2.new(0, 14, 1, 0),
                        BackgroundTransparency = 1,
                        Text             = ch,
                        TextColor3       = Theme.TextSecondary,
                        Font             = Font.Bold,
                        TextSize         = 10,
                        Parent           = f,
                    })
                    local box = Util.New("TextLabel", {
                        Size             = UDim2.new(1, -14, 1, 0),
                        Position         = UDim2.new(0, 14, 0, 0),
                        BackgroundTransparency = 1,
                        Text             = tostring(math.floor(c * 255)),
                        TextColor3       = Theme.TextPrimary,
                        Font             = Font.Mono,
                        TextSize         = 11,
                        Parent           = f,
                    })
                    return box
                end

                local RLabel = makeRGB(currentColor.R, "R")
                local GLabel = makeRGB(currentColor.G, "G")
                local BLabel = makeRGB(currentColor.B, "B")

                local function applyColor()
                    currentColor = Util.HSVtoRGB(H, S, V)
                    SVSquare.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    Preview.BackgroundColor3  = currentColor
                    ColorPreview.BackgroundColor3 = currentColor
                    HexBox.Text  = "#"..Util.ColorToHex(currentColor)
                    RLabel.Text  = tostring(math.floor(currentColor.R * 255))
                    GLabel.Text  = tostring(math.floor(currentColor.G * 255))
                    BLabel.Text  = tostring(math.floor(currentColor.B * 255))
                    callback(currentColor)
                end

                -- SV drag
                local svDrag = false
                SVSquare.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDrag = true
                    end
                end)
                SVSquare.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if svDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local abs  = SVSquare.AbsolutePosition
                        local sz   = SVSquare.AbsoluteSize
                        S = Util.Clamp((i.Position.X - abs.X) / sz.X, 0, 1)
                        V = 1 - Util.Clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
                        SVCursor.Position = UDim2.new(S, 0, 1-V, 0)
                        applyColor()
                    end
                end)

                -- Hue drag
                local hueDrag = false
                HueBar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end
                end)
                HueBar.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if hueDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local abs = HueBar.AbsolutePosition
                        local sz  = HueBar.AbsoluteSize
                        H = Util.Clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
                        HueCursor.Position = UDim2.new(0.5, 0, H, 0)
                        applyColor()
                    end
                end)

                -- Hex input
                HexBox.FocusLost:Connect(function()
                    local hex = HexBox.Text:gsub("#","")
                    if #hex == 6 then
                        local c = Util.HexToColor(hex)
                        H, S, V = Util.RGBtoHSV(c)
                        SVCursor.Position = UDim2.new(S, 0, 1-V, 0)
                        HueCursor.Position = UDim2.new(0.5, 0, H, 0)
                        applyColor()
                    end
                end)

                -- Toggle picker open/close
                local pickerOpen = false
                Preview.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    PickerRow.Visible = pickerOpen
                    if pickerOpen then
                        PickerRow.Size = UDim2.new(1, 0, 0, 190)
                    end
                end)

                local ctrl = {}
                function ctrl:Set(c)
                    currentColor = c
                    H, S, V = Util.RGBtoHSV(c)
                    SVCursor.Position = UDim2.new(S, 0, 1-V, 0)
                    HueCursor.Position = UDim2.new(0.5, 0, H, 0)
                    applyColor()
                end
                function ctrl:Get() return currentColor end
                return ctrl
            end

            -- ── AddSeparator ───────────────────────────────────────────────
            function sec:AddSeparator()
                sec._order = sec._order + 1
                Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Separator,
                    BorderSizePixel  = 0,
                    LayoutOrder      = sec._order,
                    Parent           = ElemContainer,
                })
            end

            table.insert(self._sections, sec)
            return sec
        end

        return tab
    end

    -- ── _selectTab (internal) ─────────────────────────────────────────────────
    function win:_selectTab(tab)
        for _, t in ipairs(self._tabs) do
            t._scroll.Visible = false
            Util.Tween(t._lbl,       Ease.Fast, { TextColor3 = Theme.TextSecondary })
            Util.Tween(t._indicator, Ease.Fast, { BackgroundTransparency = 1 })
        end
        tab._scroll.Visible = true
        Util.Tween(tab._lbl,       Ease.Fast, { TextColor3 = Theme.Accent })
        Util.Tween(tab._indicator, Ease.Fast, { BackgroundTransparency = 0 })
        self._activeTab = tab
    end

    -- ── Toggle visibility ─────────────────────────────────────────────────────
    function win:Toggle()
        win._visible = not win._visible
        if win._visible then
            Root.Visible = true
            Util.Tween(Root, Ease.Medium, { BackgroundTransparency = 0 })
        else
            local t = Util.Tween(Root, Ease.Medium, { BackgroundTransparency = 1 })
            t.Completed:Connect(function()
                Root.Visible = false
            end)
        end
    end

    function win:SetVisible(v)
        win._visible = v
        Root.Visible = v
    end

    -- Insert key toggle
    UserInputService.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == Enum.KeyCode.Insert then
            win:Toggle()
        end
    end)

    -- Build default tabs if provided in opts
    if opts.Tabs then
        for _, tabLabel in ipairs(tabs_def) do
            -- only create if tabs_def were custom-specified
        end
    end

    table.insert(Ember._windows, win)
    return win
end

-- ─── GLOBAL TOGGLE ────────────────────────────────────────────────────────────
function Ember:SetTheme(overrides)
    for k, v in pairs(overrides or {}) do
        if Theme[k] then
            Theme[k] = v
        end
    end
end

function Ember:GetTheme()
    return Theme
end

function Ember:GetVersion()
    return Ember._version
end

-- ─── RETURN ───────────────────────────────────────────────────────────────────
return Ember
