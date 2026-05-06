--[[
╔══════════════════════════════════════════════════════════════════╗
║                        EMBER UI LIBRARY                         ║
║                     Version 1.0.2 | Public                      ║
║          github.com/RbxCheats/UiLib2  |  MIT License            ║
╚══════════════════════════════════════════════════════════════════╝

  Changelog 1.0.2:
    [FIX] Notification: slide-in/out animation; auto-destroys after duration
          Root cause: Tween:Wait() does not exist — fixed with t.Completed:Wait()
    [FIX] Color picker: complete layout redesign — SV square left, hue bar right,
          right panel for preview/hex/RGB. No overlapping shapes.
    [FIX] Color picker cursors: SVCursor = small circle; HueLine = thin bar.
          Zero visual ambiguity between the two pickers.
    [FIX] Hue slider: proper vertical rainbow rendered via stretch-scaled asset.
    [FIX] Slider: Thumb no longer clips. Moved to TrackWrap (parent of TrackOuter)
          so ClipsDescendants on the fill track does not affect the thumb.
    [FIX] Dropdown border: changed from harsh Theme.Border to Theme.SurfaceHover
          (lighter, cleaner look that matches the dropdown background context).
    [FIX] Theme picker: SetTheme() now applies live via ThemeListeners registry.
    [FIX] Removed MinBtn and CloseBtn. Insert key is the only toggle.
          A subtle "INSERT" key hint label replaces the button cluster.
    [FIX] Toggle animation: smooth vertical size tween (collapse/expand from top)
          instead of a barely-visible 10px position nudge.
    [FIX] Dropdown arrow: replaced unsupported Unicode "▾" (Gotham can't render
          U+25BE) with an ImageLabel using rbxassetid://6034818372, rotated 90°.

  Load via:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/RbxCheats/UiLib2/main/Library.lua"))()
]]

-- ─── SERVICES ────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ─── DESIGN TOKENS ───────────────────────────────────────────────────────────
local Theme = {
    Background      = Color3.fromHex("1e1f23"),
    Surface         = Color3.fromHex("2a2c31"),
    SurfaceHover    = Color3.fromHex("32353b"),
    SurfaceActive   = Color3.fromHex("22242a"),
    Border          = Color3.fromHex("3a3d44"),
    Accent          = Color3.fromHex("f0a64b"),
    AccentDark      = Color3.fromHex("c07a20"),
    AccentGlow      = Color3.fromHex("f0a64b"),
    TextPrimary     = Color3.fromHex("e8e9ec"),
    TextSecondary   = Color3.fromHex("9a9da6"),
    TextDisabled    = Color3.fromHex("5a5d66"),
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

-- [FIX] Live theme system: every UI instance that uses a theme colour registers
--       itself here so SetTheme() can retroactively update existing elements.
local ThemeListeners = {}
for k in pairs(Theme) do ThemeListeners[k] = {} end

local function trackTheme(key, inst, prop)
    if ThemeListeners[key] then
        table.insert(ThemeListeners[key], { inst = inst, prop = prop })
    end
end

local function applyThemeKey(key, color)
    for _, e in ipairs(ThemeListeners[key] or {}) do
        pcall(function() e.inst[e.prop] = color end)
    end
end

local Font = {
    Regular  = Enum.Font.GothamMedium,
    Bold     = Enum.Font.GothamBold,
    SemiBold = Enum.Font.GothamSemibold,
    Mono     = Enum.Font.Code,
}

local Ease = {
    Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quart,   Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.28, Enum.EasingStyle.Quart,   Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.4,  Enum.EasingStyle.Quart,   Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.38, Enum.EasingStyle.Back,    Enum.EasingDirection.Out),
}

-- ─── UTILITY ─────────────────────────────────────────────────────────────────
local Util = {}

function Util.Tween(obj, info, goal)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

function Util.Round(n, d)
    local m = 10^(d or 0)
    return math.floor(n * m + 0.5) / m
end

function Util.Clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
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
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1,2), 16) or 0,
        tonumber(hex:sub(3,4), 16) or 0,
        tonumber(hex:sub(5,6), 16) or 0
    )
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
    l.Padding             = UDim.new(0, gap or 6)
    l.FillDirection       = dir   or Enum.FillDirection.Vertical
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Left
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    return l
end

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
Ember._version = "1.0.2"
Ember._windows = {}

pcall(function()
    if CoreGui:FindFirstChild("EmberUI") then
        CoreGui.EmberUI:Destroy()
    end
end)

-- ─── SCREEN GUI ROOT ─────────────────────────────────────────────────────────
local ScreenGui = Util.New("ScreenGui", {
    Name           = "EmberUI",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder   = 999,
    Parent         = CoreGui,
})

-- ─── NOTIFICATION SYSTEM ─────────────────────────────────────────────────────
-- [FIX] Root cause of "does not disappear": the original code called
--       Tween:Wait() which does not exist in Roblox Luau — the coroutine never
--       continued past that line so card:Destroy() was never reached.
--       Fixed: use t.Completed:Wait() inside task.spawn, and animate with a
--       slide-in from the right (Bounce) / slide-out to the right (Medium).
local NotifHolder = Util.New("Frame", {
    Name                   = "Notifications",
    Size                   = UDim2.new(0, 300, 1, 0),
    Position               = UDim2.new(1, -316, 0, 0),
    BackgroundTransparency = 1,
    Parent                 = ScreenGui,
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
    local ntype    = opts.Type     or "info"

    local accent = Theme.Accent
    if ntype == "success" then accent = Theme.Success
    elseif ntype == "error" then accent = Theme.Danger end

    -- Card starts off-screen to the right; slides in via Bounce tween
    local card = Util.New("Frame", {
        Name             = "Notif",
        Size             = UDim2.new(1, 0, 0, 70),
        Position         = UDim2.new(1, 20, 0, 0),
        BackgroundColor3 = Theme.Surface,
        ClipsDescendants = true,
        Parent           = NotifHolder,
    })
    Util.MakeCorner(8).Parent = card
    Util.MakeStroke(accent, 1, 0.4).Parent = card

    -- Left accent bar
    Util.New("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        Parent           = card,
    })

    local inner = Util.New("Frame", {
        Size                   = UDim2.new(1, -3, 1, 0),
        Position               = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1,
        Parent                 = card,
    })
    Util.MakePadding(10, 12, 10, 12).Parent = inner
    Util.MakeListLayout(4).Parent = inner

    Util.New("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = Theme.TextPrimary,
        Font                   = Font.Bold,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = inner,
    })
    Util.New("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text                   = message,
        TextColor3             = Theme.TextSecondary,
        Font                   = Font.Regular,
        TextSize               = 12,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        Parent                 = inner,
    })

    -- Slide in
    Util.Tween(card, Ease.Bounce, { Position = UDim2.new(0, 0, 0, 0) })

    -- Wait, then slide out and destroy
    task.spawn(function()
        task.wait(duration)
        local t = Util.Tween(card, Ease.Medium, { Position = UDim2.new(1, 20, 0, 0) })
        t.Completed:Wait()
        card:Destroy()
    end)
end

-- ─── WINDOW CLASS ────────────────────────────────────────────────────────────
local Window = {}
Window.__index = Window

function Ember:CreateWindow(opts)
    opts = opts or {}
    local title    = opts.Title    or "Ember"
    local subtitle = opts.Subtitle or ""
    local width    = opts.Width    or 780
    local height   = opts.Height   or 520

    local win = setmetatable({}, Window)
    win._tabs      = {}
    win._activeTab = nil
    win._visible   = true
    win._width     = width
    win._height    = height

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

    Util.New("ImageLabel", {
        Name                   = "Shadow",
        Size                   = UDim2.new(1, 50, 1, 50),
        Position               = UDim2.new(0, -25, 0, -25),
        BackgroundTransparency = 1,
        Image                  = "rbxassetid://6014261993",
        ImageColor3            = Color3.new(0,0,0),
        ImageTransparency      = 0.5,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49,49,450,450),
        ZIndex                 = -1,
        Parent                 = Root,
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

    -- Square off bottom corners of title bar
    Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 1,
        Parent           = TitleBar,
    })

    -- Logo dot
    local LogoDot = Util.New("Frame", {
        Size             = UDim2.new(0, 8, 0, 8),
        Position         = UDim2.new(0, 18, 0.5, -4),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = TitleBar,
    })
    Util.MakeCorner(4).Parent = LogoDot

    -- Title
    local TitleLabel = Util.New("TextLabel", {
        Size                   = UDim2.new(0, 200, 1, 0),
        Position               = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = Theme.TextPrimary,
        Font                   = Font.Bold,
        TextSize               = 15,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 3,
        Parent                 = TitleBar,
    })

    if subtitle ~= "" then
        local SubLabel = Util.New("TextLabel", {
            Size                   = UDim2.new(0, 200, 1, 0),
            Position               = UDim2.new(0, 34 + 108, 0, 0),
            BackgroundTransparency = 1,
            Text                   = subtitle,
            TextColor3             = Theme.TextSecondary,
            Font                   = Font.Regular,
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 3,
            Parent                 = TitleBar,
        })
        TitleLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
            SubLabel.Position = UDim2.new(0, 34 + TitleLabel.TextBounds.X + 8, 0, 0)
        end)
    end

    -- [FIX] Removed MinBtn and CloseBtn.
    --       Replaced with a small keyboard hint so users know Insert toggles the menu.
    local KeyHint = Util.New("TextLabel", {
        Size                   = UDim2.new(0, 64, 0, 20),
        Position               = UDim2.new(1, -74, 0.5, -10),
        BackgroundColor3       = Theme.SurfaceActive,
        BackgroundTransparency = 0,
        Text                   = "INSERT",
        TextColor3             = Theme.TextDisabled,
        Font                   = Font.Mono,
        TextSize               = 10,
        ZIndex                 = 3,
        Parent                 = TitleBar,
    })
    Util.MakeCorner(4).Parent = KeyHint
    Util.MakeStroke(Theme.Border, 1, 0.4).Parent = KeyHint

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
        Size                   = UDim2.new(1, -20, 1, 0),
        Position               = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness     = 0,
        ScrollingDirection     = Enum.ScrollingDirection.X,
        CanvasSize             = UDim2.new(0, 0, 1, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.X,
        Parent                 = TabBar,
    })

    local TabLayout = Util.MakeListLayout(4, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left)
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Parent = TabBarInner

    Util.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Separator,
        BorderSizePixel  = 0,
        Parent           = TabBar,
    })

    win._tabBar    = TabBarInner
    win._tabLayout = TabLayout

    -- ── Content Area ──────────────────────────────────────────────────────────
    local ContentArea = Util.New("Frame", {
        Name                   = "ContentArea",
        Size                   = UDim2.new(1, -16, 1, -(52 + 40 + 8 + 8)),
        Position               = UDim2.new(0, 8, 0, 52 + 40 + 8),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = Root,
    })
    win._contentArea = ContentArea

    -- ── Draggable ─────────────────────────────────────────────────────────────
    Util.MakeDraggable(TitleBar, Root)

    -- ── Tab Button Creator ────────────────────────────────────────────────────
    function win:_makeTabButton(label)
        local btn = Util.New("TextButton", {
            Size                   = UDim2.new(0, 0, 1, -8),
            AutomaticSize          = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text                   = "",
            AutoButtonColor        = false,
            Parent                 = TabBarInner,
        })
        Util.MakePadding(0, 12, 0, 12).Parent = btn

        local lbl = Util.New("TextLabel", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = label,
            TextColor3             = Theme.TextSecondary,
            Font                   = Font.SemiBold,
            TextSize               = 12,
            Parent                 = btn,
        })

        local Indicator = Util.New("Frame", {
            Size                   = UDim2.new(1, -8, 0, 2),
            Position               = UDim2.new(0, 4, 1, -2),
            BackgroundColor3       = Theme.Accent,
            BorderSizePixel        = 0,
            BackgroundTransparency = 1,
            Parent                 = btn,
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

    -- ── _selectTab ────────────────────────────────────────────────────────────
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

    -- ── Toggle ────────────────────────────────────────────────────────────────
    -- [FIX] Old animation tweened Position by ±10px — nearly imperceptible and
    --       felt broken. New animation: collapse/expand Root.Size.Y smoothly so
    --       the window folds up into itself cleanly and reopens with a Quart ease.
    function win:Toggle()
        win._visible = not win._visible
        if win._visible then
            Root.Size    = UDim2.new(0, width, 0, 0)
            Root.Visible = true
            Util.Tween(Root, Ease.Medium, { Size = UDim2.new(0, width, 0, height) })
        else
            local t = Util.Tween(Root, Ease.Medium, { Size = UDim2.new(0, width, 0, 0) })
            t.Completed:Connect(function()
                if not win._visible then
                    Root.Visible = false
                    Root.Size    = UDim2.new(0, width, 0, height)
                end
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

        local scroll = Util.New("ScrollingFrame", {
            Name                   = "TabContent_"..label,
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ScrollBarThickness     = 4,
            ScrollBarImageColor3   = Theme.ScrollBar,
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            Visible                = false,
            Parent                 = ContentArea,
        })

        local ColContainer = Util.New("Frame", {
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent                 = scroll,
        })

        local ColLeft = Util.New("Frame", {
            Size                   = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 0, 0, 0),
            Parent                 = ColContainer,
        })
        Util.MakeListLayout(8).Parent = ColLeft

        local ColRight = Util.New("Frame", {
            Size                   = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position               = UDim2.new(0.5, 5, 0, 0),
            Parent                 = ColContainer,
        })
        Util.MakeListLayout(8).Parent = ColRight

        tab._scroll   = scroll
        tab._colLeft  = ColLeft
        tab._colRight = ColRight
        tab._colIdx   = 0

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
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent                 = Card,
            })
            Util.MakePadding(12, 14, 14, 14).Parent = CardInner
            Util.MakeListLayout(0).Parent = CardInner

            local Header = Util.New("Frame", {
                Size                   = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder            = 0,
                Parent                 = CardInner,
            })
            Util.New("TextLabel", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = title:upper(),
                TextColor3             = Theme.Accent,
                Font                   = Font.Bold,
                TextSize               = 11,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = Header,
            })

            Util.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Separator,
                BorderSizePixel  = 0,
                LayoutOrder      = 1,
                Parent           = CardInner,
            })

            local ElemContainer = Util.New("Frame", {
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder            = 2,
                Parent                 = CardInner,
            })
            Util.MakeListLayout(0).Parent = ElemContainer

            sec._container = ElemContainer
            sec._order     = 0

            local function makeRow(h)
                sec._order = sec._order + 1
                local row = Util.New("Frame", {
                    Size                   = UDim2.new(1, 0, 0, h or 40),
                    BackgroundTransparency = 1,
                    LayoutOrder            = sec._order,
                    Parent                 = ElemContainer,
                })
                return row
            end

            -- ── AddToggle ─────────────────────────────────────────────────────
            function sec:AddToggle(opts)
                opts = opts or {}
                local label    = opts.Label    or "Toggle"
                local default  = opts.Default ~= nil and opts.Default or false
                local callback = opts.Callback or function() end
                local state    = default

                local row = makeRow(38)

                Util.New("TextLabel", {
                    Size                   = UDim2.new(1, -56, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = label,
                    TextColor3             = Theme.TextPrimary,
                    Font                   = Font.Regular,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = row,
                })

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

                local Hit = Util.New("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = "",
                    Parent                 = row,
                    AutoButtonColor        = false,
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

                local ctrl = {}
                function ctrl:Set(v) setToggle(v, false) end
                function ctrl:Get() return state end
                return ctrl
            end

            -- ── AddSlider ─────────────────────────────────────────────────────
            -- [FIX] Original: Thumb parented to TrackOuter which had ClipsDescendants=true.
            --       At pct=0 the thumb's left half was clipped; at pct=1 the right half was.
            --       Fix: introduce TrackWrap (ClipsDescendants=false) as the parent for both
            --       TrackOuter (fill bar, clips internally for clean rounded ends) and Thumb
            --       (floats freely on top, never clipped). TrackOuter is inset 7px each side
            --       so the thumb aligns flush with the track ends at min/max.
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

                local row = makeRow(54)

                local TopRow = Util.New("Frame", {
                    Size                   = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent                 = row,
                })
                Util.New("TextLabel", {
                    Size                   = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = label,
                    TextColor3             = Theme.TextPrimary,
                    Font                   = Font.Regular,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = TopRow,
                })
                local ValLabel = Util.New("TextLabel", {
                    Size                   = UDim2.new(0.3, 0, 1, 0),
                    Position               = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = tostring(value)..suffix,
                    TextColor3             = Theme.Accent,
                    Font                   = Font.SemiBold,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Right,
                    Parent                 = TopRow,
                })

                -- Wrapper that allows thumb to overflow without clipping
                local TrackWrap = Util.New("Frame", {
                    Size                   = UDim2.new(1, 0, 0, 20),
                    Position               = UDim2.new(0, 0, 0, 26),
                    BackgroundTransparency = 1,
                    ClipsDescendants       = false,
                    Parent                 = row,
                })

                -- Actual track bar, inset 7px per side so thumb fits at edges
                local TrackOuter = Util.New("Frame", {
                    Size             = UDim2.new(1, -14, 0, 6),
                    Position         = UDim2.new(0, 7, 0.5, -3),
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    Parent           = TrackWrap,
                })
                Util.MakeCorner(3).Parent = TrackOuter

                local pct = (value - min) / (max - min)
                local Fill = Util.New("Frame", {
                    Size             = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel  = 0,
                    Parent           = TrackOuter,
                })
                Util.MakeCorner(3).Parent = Fill

                -- Thumb in TrackWrap space — never clipped
                -- Position.X: 7 (left inset) + pct * (trackWidth) aligned via AnchorPoint(0.5)
                -- Since TrackOuter is inset 7px and is (1,-14) wide, the thumb center at
                -- pct=0 should be at X=7, at pct=1 at X=width-7.
                -- In UDim2 relative to TrackWrap: UDim2.new(pct, 7 - pct*14, 0.5, 0)
                local Thumb = Util.New("Frame", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(pct, math.floor(7 - pct * 14), 0.5, 0),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel  = 0,
                    ZIndex           = 2,
                    Parent           = TrackWrap,
                })
                Util.MakeCorner(7).Parent = Thumb
                Util.MakeStroke(Color3.fromHex("888888"), 1, 0.5).Parent = Thumb

                -- Hit area covers the whole wrap + vertical padding for ease of clicking
                local Hit = Util.New("TextButton", {
                    Size                   = UDim2.new(1, 0, 1, 20),
                    Position               = UDim2.new(0, 0, 0, -10),
                    BackgroundTransparency = 1,
                    Text                   = "",
                    AutoButtonColor        = false,
                    ZIndex                 = 3,
                    Parent                 = TrackWrap,
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
                    Fill.Size      = UDim2.new(np, 0, 1, 0)
                    Thumb.Position = UDim2.new(np, math.floor(7 - np * 14), 0.5, 0)
                    ValLabel.Text  = tostring(value)..suffix
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
                    Fill.Size      = UDim2.new(np, 0, 1, 0)
                    Thumb.Position = UDim2.new(np, math.floor(7 - np * 14), 0.5, 0)
                    ValLabel.Text  = tostring(value)..suffix
                end
                function ctrl:Get() return value end
                return ctrl
            end

            -- ── AddDropdown ───────────────────────────────────────────────────
            -- [FIX] Border: was Theme.Border (hex 3a3d44, visually harsh on the dark
            --       DropdownBg). Changed to Theme.SurfaceHover (hex 32353b) which is
            --       lighter and provides a subtle, clean separation.
            -- [FIX] Arrow icon: replaced Unicode "▾" (U+25BE, unsupported by Gotham)
            --       with an ImageLabel using rbxassetid://6034818372 (a chevron/arrow),
            --       rotated 90° to face down. Tweens to 270° when open.
            function sec:AddDropdown(opts)
                opts = opts or {}
                local label    = opts.Label    or "Dropdown"
                local items    = opts.Items    or {"none"}
                local default  = opts.Default  or items[1] or "none"
                local callback = opts.Callback or function() end
                local selected = default

                local row = makeRow(62)

                Util.New("TextLabel", {
                    Size                   = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text                   = label,
                    TextColor3             = Theme.TextPrimary,
                    Font                   = Font.Regular,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = row,
                })

                local DDBtn = Util.New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    Position         = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Theme.DropdownBg,
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = row,
                })
                Util.MakeCorner(6).Parent = DDBtn
                -- [FIX] Cleaner border colour — SurfaceHover is lighter than Border
                Util.MakeStroke(Theme.SurfaceHover, 1, 0).Parent = DDBtn

                local DDLabel = Util.New("TextLabel", {
                    Size                   = UDim2.new(1, -34, 1, 0),
                    Position               = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text                   = selected,
                    TextColor3             = Theme.TextPrimary,
                    Font                   = Font.Regular,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = DDBtn,
                })

                -- [FIX] Arrow: ImageLabel with a chevron asset, Rotation=90 (pointing down).
                --       Rotates to 270 when open. Asset 6034818372 is a right-facing arrow
                --       included in Roblox's built-in icon set.
                local Arrow = Util.New("ImageLabel", {
                    Size                   = UDim2.new(0, 12, 0, 12),
                    Position               = UDim2.new(1, -22, 0.5, -6),
                    BackgroundTransparency = 1,
                    Image                  = "rbxassetid://6034818372",
                    ImageColor3            = Theme.TextSecondary,
                    Rotation               = 90,
                    Parent                 = DDBtn,
                })

                local visibleRows = math.min(#items, 6)
                local listH = visibleRows * 30

                local ListFrame = Util.New("ScrollingFrame", {
                    Size                 = UDim2.new(0, 0, 0, listH),
                    BackgroundColor3     = Theme.DropdownBg,
                    BorderSizePixel      = 0,
                    Visible              = false,
                    ZIndex               = 50,
                    ClipsDescendants     = true,
                    ScrollBarThickness   = #items > 6 and 3 or 0,
                    ScrollBarImageColor3 = Theme.ScrollBar,
                    CanvasSize           = UDim2.new(0, 0, 0, #items * 30),
                    Parent               = ScreenGui,
                })
                Util.MakeCorner(6).Parent = ListFrame
                Util.MakeStroke(Theme.SurfaceHover, 1, 0).Parent = ListFrame
                Util.MakeListLayout(0).Parent = ListFrame

                local open = false

                local function closeList()
                    open = false
                    Util.Tween(Arrow, Ease.Fast, { Rotation = 90 })
                    ListFrame.Visible = false
                end

                for _, item in ipairs(items) do
                    local ItemBtn = Util.New("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.DropdownItem,
                        Text             = "",
                        AutoButtonColor  = false,
                        ZIndex           = 51,
                        Parent           = ListFrame,
                    })
                    local ItemLbl = Util.New("TextLabel", {
                        Size                   = UDim2.new(1, -10, 1, 0),
                        Position               = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text                   = item,
                        TextColor3             = item == selected and Theme.Accent or Theme.TextPrimary,
                        Font                   = Font.Regular,
                        TextSize               = 12,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        ZIndex                 = 52,
                        Parent                 = ItemBtn,
                    })

                    ItemBtn.MouseEnter:Connect(function()
                        Util.Tween(ItemBtn, Ease.Fast, { BackgroundColor3 = Theme.DropdownHover })
                    end)
                    ItemBtn.MouseLeave:Connect(function()
                        Util.Tween(ItemBtn, Ease.Fast, { BackgroundColor3 = Theme.DropdownItem })
                    end)
                    ItemBtn.MouseButton1Click:Connect(function()
                        for _, child in ipairs(ListFrame:GetChildren()) do
                            if child:IsA("TextButton") then
                                local lbl2 = child:FindFirstChildWhichIsA("TextLabel")
                                if lbl2 then lbl2.TextColor3 = Theme.TextPrimary end
                            end
                        end
                        ItemLbl.TextColor3 = Theme.Accent
                        selected = item
                        DDLabel.Text = item
                        closeList()
                        callback(selected)
                    end)
                end

                DDBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        local absPos  = DDBtn.AbsolutePosition
                        local absSize = DDBtn.AbsoluteSize
                        ListFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                        ListFrame.Size     = UDim2.new(0, absSize.X, 0, listH)
                        Util.Tween(Arrow, Ease.Fast, { Rotation = 270 })
                        ListFrame.Visible  = true
                    else
                        closeList()
                    end
                end)

                UserInputService.InputBegan:Connect(function(i)
                    if open and i.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mp = UserInputService:GetMouseLocation()
                        local lp = ListFrame.AbsolutePosition
                        local ls = ListFrame.AbsoluteSize
                        local inList = mp.X >= lp.X and mp.X <= lp.X + ls.X
                                   and mp.Y >= lp.Y and mp.Y <= lp.Y + ls.Y
                        if not inList then closeList() end
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v) selected = v; DDLabel.Text = v end
                function ctrl:Get() return selected end
                return ctrl
            end

            -- ── AddButton ─────────────────────────────────────────────────────
            function sec:AddButton(opts)
                opts = opts or {}
                local label    = opts.Label    or "Button"
                local sublabel = opts.SubLabel or nil
                local style    = opts.Style    or "default"
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
                    Size                   = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text                   = label,
                    TextColor3             = style == "default" and Theme.TextPrimary or Color3.new(1,1,1),
                    Font                   = Font.SemiBold,
                    TextSize               = 13,
                    Parent                 = Btn,
                })
                if sublabel then
                    Util.New("TextLabel", {
                        Size                   = UDim2.new(1, 0, 0, 14),
                        BackgroundTransparency = 1,
                        Text                   = sublabel,
                        TextColor3             = style == "default" and Theme.TextSecondary or Color3.new(1,1,1),
                        Font                   = Font.Regular,
                        TextSize               = 11,
                        Parent                 = Btn,
                    })
                end

                local hoverColor = style == "default" and Theme.SurfaceHover
                               or  style == "danger"  and Color3.fromHex("c04040")
                               or  Color3.fromHex("3a8f6a")

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

            -- ── AddLabel ──────────────────────────────────────────────────────
            function sec:AddLabel(opts)
                opts = opts or {}
                local row = makeRow(28)
                Util.New("TextLabel", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = opts.Text  or "",
                    TextColor3             = opts.Color or Theme.TextSecondary,
                    Font                   = Font.Regular,
                    TextSize               = 12,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextWrapped            = true,
                    Parent                 = row,
                })
            end

            -- ── AddColorPicker ────────────────────────────────────────────────
            -- [FIX] Completely redesigned layout — three distinct, non-overlapping zones:
            --   LEFT:   SV square (saturation/value) — large, takes most width
            --   MIDDLE: Hue bar (16px wide, vertical rainbow) — drag for hue
            --   RIGHT:  Info panel (80px) — color preview swatch, hex input, RGB readouts
            --
            -- Cursors:
            --   SVCursor = small white circle (UICorner r=6 on 12x12) with dark stroke
            --   HueLine  = thin 3px horizontal white bar — clearly a position indicator,
            --              not a shape selector (eliminates "circle vs square" confusion)
            --
            -- Hue slider fix: was using the SV saturation overlay asset for hue.
            --   rbxassetid://6020299348 is the correct vertical rainbow hue gradient.
            --   ScaleType=Stretch ensures it fills the bar without tiling artifacts.
            function sec:AddColorPicker(opts)
                opts = opts or {}
                local label    = opts.Label    or "Color"
                local default  = opts.Default  or Color3.fromRGB(240, 166, 75)
                local callback = opts.Callback or function() end

                local H, S, V = Util.RGBtoHSV(default)
                local currentColor = default

                -- Swatch row (always visible)
                local row = makeRow(36)
                Util.New("TextLabel", {
                    Size                   = UDim2.new(1, -46, 1, 0),
                    BackgroundTransparency = 1,
                    Text                   = label,
                    TextColor3             = Theme.TextPrimary,
                    Font                   = Font.Regular,
                    TextSize               = 13,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = row,
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

                -- Expandable picker row (hidden until Preview clicked)
                sec._order = sec._order + 1
                local PickerRow = Util.New("Frame", {
                    Size                   = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ClipsDescendants       = false,
                    LayoutOrder            = sec._order,
                    Visible                = false,
                    Parent                 = ElemContainer,
                })

                local Panel = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 200),
                    BackgroundColor3 = Theme.SurfaceActive,
                    Parent           = PickerRow,
                })
                Util.MakeCorner(6).Parent = Panel
                Util.MakePadding(10, 10, 10, 10).Parent = Panel

                -- Dimensions (all relative to Panel interior after padding):
                -- Panel is ~(sectionWidth - 28)px wide.
                -- RightPanel = 80px, HueBar = 16px, gaps = 8px each
                -- SV = rest of width = 1 scale - (16+8+80+8) offset

                -- ── SV Square ─────────────────────────────────────────────────
                local SV = Util.New("ImageLabel", {
                    Size             = UDim2.new(1, -(16 + 8 + 80 + 8), 1, 0),
                    BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                    Image            = "rbxassetid://4155801252",  -- S/V white gradient overlay
                    ScaleType        = Enum.ScaleType.Stretch,
                    Parent           = Panel,
                })
                Util.MakeCorner(5).Parent = SV

                -- Black top-to-bottom overlay for value darkening
                Util.New("ImageLabel", {
                    Size                   = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image                  = "rbxassetid://6020299385",
                    ScaleType              = Enum.ScaleType.Stretch,
                    Parent                 = SV,
                })

                -- SVCursor: small circle, clearly a point selector
                local SVCursor = Util.New("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(S, 0, 1 - V, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                    ZIndex           = 2,
                    Parent           = SV,
                })
                Util.MakeCorner(6).Parent = SVCursor
                Util.MakeStroke(Color3.new(0, 0, 0), 1.5, 0.25).Parent = SVCursor

                -- ── Hue Bar ───────────────────────────────────────────────────
                -- Positioned 80+8=88px from right, 16px wide
                local HueBar = Util.New("ImageLabel", {
                    Size             = UDim2.new(0, 16, 1, 0),
                    Position         = UDim2.new(1, -(16 + 8 + 80), 0, 0),
                    Image            = "rbxassetid://6020299348",  -- vertical rainbow hue gradient
                    ScaleType        = Enum.ScaleType.Stretch,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent           = Panel,
                })
                Util.MakeCorner(4).Parent = HueBar

                -- HueLine: thin horizontal bar — positional indicator, not a shape
                local HueLine = Util.New("Frame", {
                    Size             = UDim2.new(1, 6, 0, 3),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(0.5, 0, H, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                    ZIndex           = 2,
                    Parent           = HueBar,
                })
                Util.MakeCorner(1).Parent = HueLine
                Util.MakeStroke(Color3.new(0, 0, 0), 1, 0.3).Parent = HueLine

                -- ── Right Panel ───────────────────────────────────────────────
                local RightPanel = Util.New("Frame", {
                    Size                   = UDim2.new(0, 80, 1, 0),
                    Position               = UDim2.new(1, -80, 0, 0),
                    BackgroundTransparency = 1,
                    Parent                 = Panel,
                })
                Util.MakeListLayout(5).Parent = RightPanel

                -- Color preview swatch
                local ColorPreview = Util.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 56),
                    BackgroundColor3 = currentColor,
                    Parent           = RightPanel,
                })
                Util.MakeCorner(5).Parent = ColorPreview

                -- HEX label
                Util.New("TextLabel", {
                    Size                   = UDim2.new(1, 0, 0, 12),
                    BackgroundTransparency = 1,
                    Text                   = "HEX",
                    TextColor3             = Theme.TextDisabled,
                    Font                   = Font.Bold,
                    TextSize               = 9,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = RightPanel,
                })

                local HexBox = Util.New("TextBox", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.DropdownBg,
                    Text             = "#"..Util.ColorToHex(currentColor),
                    TextColor3       = Theme.TextPrimary,
                    Font             = Font.Mono,
                    TextSize         = 10,
                    ClearTextOnFocus = false,
                    Parent           = RightPanel,
                })
                Util.MakeCorner(4).Parent = HexBox
                Util.MakePadding(0, 5, 0, 5).Parent = HexBox

                -- RGB readout rows
                local function makeReadout(ch, val255)
                    local f = Util.New("Frame", {
                        Size             = UDim2.new(1, 0, 0, 18),
                        BackgroundColor3 = Theme.DropdownBg,
                        Parent           = RightPanel,
                    })
                    Util.MakeCorner(3).Parent = f
                    Util.New("TextLabel", {
                        Size                   = UDim2.new(0, 12, 1, 0),
                        BackgroundTransparency = 1,
                        Text                   = ch,
                        TextColor3             = Theme.TextDisabled,
                        Font                   = Font.Bold,
                        TextSize               = 8,
                        Parent                 = f,
                    })
                    return Util.New("TextLabel", {
                        Size                   = UDim2.new(1, -12, 1, 0),
                        Position               = UDim2.new(0, 12, 0, 0),
                        BackgroundTransparency = 1,
                        Text                   = tostring(val255),
                        TextColor3             = Theme.TextPrimary,
                        Font                   = Font.Mono,
                        TextSize               = 10,
                        Parent                 = f,
                    })
                end

                local RLbl = makeReadout("R", math.floor(currentColor.R * 255))
                local GLbl = makeReadout("G", math.floor(currentColor.G * 255))
                local BLbl = makeReadout("B", math.floor(currentColor.B * 255))

                local function applyColor()
                    currentColor = Util.HSVtoRGB(H, S, V)
                    SV.BackgroundColor3           = Color3.fromHSV(H, 1, 1)
                    Preview.BackgroundColor3      = currentColor
                    ColorPreview.BackgroundColor3 = currentColor
                    HexBox.Text = "#"..Util.ColorToHex(currentColor)
                    RLbl.Text = tostring(math.floor(currentColor.R * 255))
                    GLbl.Text = tostring(math.floor(currentColor.G * 255))
                    BLbl.Text = tostring(math.floor(currentColor.B * 255))
                    callback(currentColor)
                end

                -- SV drag
                local svDrag = false
                SV.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDrag = true
                        local abs = SV.AbsolutePosition
                        local sz  = SV.AbsoluteSize
                        S = Util.Clamp((i.Position.X - abs.X) / sz.X, 0, 1)
                        V = 1 - Util.Clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
                        SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        applyColor()
                    end
                end)
                SV.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if svDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local abs = SV.AbsolutePosition
                        local sz  = SV.AbsoluteSize
                        S = Util.Clamp((i.Position.X - abs.X) / sz.X, 0, 1)
                        V = 1 - Util.Clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
                        SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        applyColor()
                    end
                end)

                -- Hue drag
                local hueDrag = false
                HueBar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDrag = true
                        local abs = HueBar.AbsolutePosition
                        local sz  = HueBar.AbsoluteSize
                        H = Util.Clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
                        HueLine.Position = UDim2.new(0.5, 0, H, 0)
                        applyColor()
                    end
                end)
                HueBar.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if hueDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local abs = HueBar.AbsolutePosition
                        local sz  = HueBar.AbsoluteSize
                        H = Util.Clamp((i.Position.Y - abs.Y) / sz.Y, 0, 1)
                        HueLine.Position = UDim2.new(0.5, 0, H, 0)
                        applyColor()
                    end
                end)

                -- Hex input
                HexBox.FocusLost:Connect(function()
                    local hex = HexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local c = Util.HexToColor(hex)
                        H, S, V = Util.RGBtoHSV(c)
                        SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        HueLine.Position  = UDim2.new(0.5, 0, H, 0)
                        applyColor()
                    end
                end)

                -- Toggle open/close
                local pickerOpen = false
                Preview.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    PickerRow.Visible = pickerOpen
                    PickerRow.Size    = UDim2.new(1, 0, 0, pickerOpen and 210 or 0)
                end)

                local ctrl = {}
                function ctrl:Set(c)
                    currentColor = c
                    H, S, V = Util.RGBtoHSV(c)
                    SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    HueLine.Position  = UDim2.new(0.5, 0, H, 0)
                    applyColor()
                end
                function ctrl:Get() return currentColor end
                return ctrl
            end

            -- ── AddSeparator ──────────────────────────────────────────────────
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
        end -- CreateSection

        return tab
    end -- CreateTab

    table.insert(Ember._windows, win)
    return win
end -- CreateWindow

-- ─── THEME API ───────────────────────────────────────────────────────────────
-- [FIX] SetTheme now propagates live via ThemeListeners so existing elements
--       update immediately — fixing the broken theme picker.
function Ember:SetTheme(overrides)
    for k, v in pairs(overrides or {}) do
        if Theme[k] ~= nil then
            Theme[k] = v
            applyThemeKey(k, v)
        end
    end
end

function Ember:GetTheme()
    local copy = {}
    for k, v in pairs(Theme) do copy[k] = v end
    return copy
end

function Ember:GetVersion()
    return Ember._version
end

-- ─── RETURN ──────────────────────────────────────────────────────────────────
return Ember
