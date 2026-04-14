-- ============================================================
-- NexusUI | Remastered UI Library for Roblox
-- Toggle Menu: Right Shift
-- Features: Labels, Buttons, Toggles, Sliders,
--           Dropdowns (animated), Color Pickers (HSV),
--           Watermark (animated), Draggable
-- ============================================================

local NexusUI = {}
NexusUI.__index = NexusUI

local TabBuilder = {}
TabBuilder.__index = TabBuilder

-- ── Services ──────────────────────────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

-- ── Theme ─────────────────────────────────────────────────────
local T = {
    BgDeep          = Color3.fromRGB(13,  13,  17),
    BgPanel         = Color3.fromRGB(17,  17,  22),
    BgWidget        = Color3.fromRGB(23,  23,  30),
    BgHover         = Color3.fromRGB(30,  30,  40),
    Accent          = Color3.fromRGB(99,  135, 255),
    AccentDim       = Color3.fromRGB(60,  90,  200),
    AccentGlow      = Color3.fromRGB(130, 160, 255),
    TextPrimary     = Color3.fromRGB(225, 225, 235),
    TextSecondary   = Color3.fromRGB(145, 145, 165),
    TextMuted       = Color3.fromRGB(85,  85,  105),
    Border          = Color3.fromRGB(38,  38,  52),
    BorderLight     = Color3.fromRGB(55,  55,  75),
    ToggleOff       = Color3.fromRGB(40,  40,  55),
    ToggleOn        = Color3.fromRGB(99,  135, 255),
    ToggleKnob      = Color3.fromRGB(245, 245, 255),
    SliderTrack     = Color3.fromRGB(32,  32,  44),
    SliderFill      = Color3.fromRGB(99,  135, 255),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    ScrollBar       = Color3.fromRGB(60,  60,  85),
    WmBg            = Color3.fromRGB(13,  13,  18),
    WmText          = Color3.fromRGB(200, 200, 220),
}

-- ── Layout ────────────────────────────────────────────────────
local L = {
    WinW        = 330,
    WinMinW     = 210,
    WinMinH     = 140,
    TitleH      = 32,
    TabBarH     = 28,
    Pad         = 10,
    Gap         = 5,
    BtnH        = 28,
    TogH        = 24,
    SliderH     = 44,
    LabelH      = 18,
    DropH       = 28,
    DropItemH   = 26,
    GripSz      = 14,
    Radius      = 7,
    TabRadius   = 5,
    WmH         = 26,
    WmPad       = 8,
}

-- ── Fonts ─────────────────────────────────────────────────────
local FR = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
local FS = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
local FB = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

-- ── Helpers ───────────────────────────────────────────────────
local function tw(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.13, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function rnd(r, obj)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
    return c
end

local function strk(color, thick, obj)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

-- HSV <-> RGB
local function hsvToRgb(h, s, v)
    if s == 0 then return v, v, v end
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t2 = v * (1 - (1 - f) * s)
    local r, g, b
    local m = i % 6
    if     m == 0 then r,g,b = v,t2,p
    elseif m == 1 then r,g,b = q,v,p
    elseif m == 2 then r,g,b = p,v,t2
    elseif m == 3 then r,g,b = p,q,v
    elseif m == 4 then r,g,b = t2,p,v
    elseif m == 5 then r,g,b = v,p,q
    end
    return r, g, b
end

local function rgbToHsv(r, g, b)
    local maxC = math.max(r, g, b)
    local minC = math.min(r, g, b)
    local d    = maxC - minC
    local h, s, v
    v = maxC
    s = maxC == 0 and 0 or d / maxC
    if d == 0 then
        h = 0
    elseif maxC == r then
        h = (((g - b) / d) % 6) / 6
    elseif maxC == g then
        h = ((b - r) / d + 2) / 6
    else
        h = ((r - g) / d + 4) / 6
    end
    return h, s, v
end

-- Walk up to ScreenGui
local function getScreenGui(inst)
    local cur = inst
    while cur and not cur:IsA("ScreenGui") do cur = cur.Parent end
    return cur
end

-- ── Watermark ─────────────────────────────────────────────────
local function createWatermark(screenGui, text)
    local frame = mk("Frame", {
        Name             = "Watermark",
        Size             = UDim2.new(0, 0, 0, L.WmH),
        Position         = UDim2.new(0, 12, 1, -(L.WmH + 12)),
        BackgroundColor3 = T.WmBg,
        BorderSizePixel  = 0,
        AutomaticSize    = Enum.AutomaticSize.X,
        ZIndex           = 10,
    }, screenGui)
    rnd(L.Radius - 2, frame)
    strk(T.Border, 1, frame)

    local accent = mk("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 11,
    }, frame)
    rnd(2, accent)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft  = UDim.new(0, L.WmPad + 4)
    pad.PaddingRight = UDim.new(0, L.WmPad)
    pad.Parent = frame

    mk("TextLabel", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = T.WmText,
        TextSize         = 12,
        FontFace         = FS,
        TextXAlignment   = Enum.TextXAlignment.Left,
        AutomaticSize    = Enum.AutomaticSize.X,
        ZIndex           = 11,
    }, frame)

    local hue  = 0
    local conn = RunService.Heartbeat:Connect(function(dt)
        hue = (hue + dt * 0.4) % 1
        local r, g, b = hsvToRgb(hue, 0.55, 1)
        accent.BackgroundColor3 = Color3.new(r, g, b)
    end)

    return frame, conn
end

-- ══════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════
function NexusUI.new(title, opts)
    opts = opts or {}
    local self       = setmetatable({}, NexusUI)
    self._title      = title or "NexusUI"
    self._tabs       = {}
    self._tabsByName = {}
    self._activeTab  = nil
    self._rendered   = false
    self._wmConn     = nil
    self._hasTabs    = false

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusUI_" .. self._title
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 999
    sg.IgnoreGuiInset = true
    if not pcall(function() sg.Parent = game:GetService("CoreGui") end) then
        sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    self._sg = sg

    -- Outer window frame — ClipsDescendants FALSE so overlay lists can escape
    local win = mk("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, L.WinW, 0, 360),
        Position         = UDim2.new(0, 90, 0, 90),
        BackgroundColor3 = T.BgPanel,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
    }, sg)
    rnd(L.Radius, win)
    strk(T.Border, 1, win)
    self._win = win

    -- Inner frame that clips all window contents (but not overlay lists)
    local inner = mk("Frame", {
        Name             = "Inner",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, win)
    rnd(L.Radius, inner)
    self._inner = inner

    -- Background gradient on inner
    local grd = Instance.new("UIGradient")
    grd.Rotation = 90
    grd.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 22)),
    }
    grd.Parent = inner

    -- Title Bar
    local titleBar = mk("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, L.TitleH),
        BackgroundColor3 = T.BgDeep,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, inner)

    mk("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.6,
        BorderSizePixel  = 0,
    }, titleBar)

    local dot = mk("Frame", {
        Size             = UDim2.new(0, 6, 0, 6),
        Position         = UDim2.new(0, 10, 0.5, -3),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
    }, titleBar)
    rnd(3, dot)

    mk("TextLabel", {
        Size             = UDim2.new(1, -32, 1, 0),
        Position         = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1,
        Text             = self._title,
        TextColor3       = T.TextPrimary,
        TextSize         = 13,
        FontFace         = FB,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, titleBar)

    -- Drag
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = win.Position
        end
    end)
    titleBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                     startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- Tab Bar
    local tabBar = mk("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, 0, 0, L.TabBarH),
        Position         = UDim2.new(0, 0, 0, L.TitleH),
        BackgroundColor3 = T.BgDeep,
        BorderSizePixel  = 0,
    }, inner)
    self._tabBar = tabBar

    mk("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
    }, tabBar)

    local tabInner = mk("Frame", {
        Name             = "TabInner",
        Size             = UDim2.new(1, 0, 1, -1),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
    }, tabBar)

    local ll = Instance.new("UIListLayout")
    ll.FillDirection     = Enum.FillDirection.Horizontal
    ll.SortOrder         = Enum.SortOrder.LayoutOrder
    ll.Padding           = UDim.new(0, 3)
    ll.VerticalAlignment = Enum.VerticalAlignment.Center
    ll.Parent = tabInner

    local tpad = Instance.new("UIPadding")
    tpad.PaddingLeft  = UDim.new(0, 6)
    tpad.PaddingRight = UDim.new(0, 6)
    tpad.Parent = tabInner
    self._tabInner = tabInner

    -- Content Area (inside inner — clips scroll frames)
    local contentTop = L.TitleH + L.TabBarH
    local content = mk("Frame", {
        Name             = "Content",
        Size             = UDim2.new(1, 0, 1, -contentTop),
        Position         = UDim2.new(0, 0, 0, contentTop),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, inner)
    self._content    = content
    self._contentTop = contentTop

    -- Resize Grip — hidden by default; only used in no-tab mode
    local grip = mk("TextButton", {
        Name             = "Grip",
        Size             = UDim2.new(0, L.GripSz, 0, L.GripSz),
        Position         = UDim2.new(1, -L.GripSz, 1, -L.GripSz),
        BackgroundColor3 = T.BgWidget,
        Text             = "",
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Visible          = false,
    }, inner)
    rnd(3, grip)
    self._grip = grip

    for row = 0, 1 do
        for col = 0, 1 do
            mk("Frame", {
                Size             = UDim2.new(0, 2, 0, 2),
                Position         = UDim2.new(0, 3 + col * 5, 0, 3 + row * 5),
                BackgroundColor3 = T.TextMuted,
                BorderSizePixel  = 0,
            }, grip)
        end
    end
    grip.MouseEnter:Connect(function() tw(grip, {BackgroundColor3 = T.AccentDim}) end)
    grip.MouseLeave:Connect(function() tw(grip, {BackgroundColor3 = T.BgWidget}) end)

    local resizing, resizeStart, resizeStartSz
    grip.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing      = true
            resizeStart   = inp.Position
            resizeStartSz = win.AbsoluteSize
        end
    end)
    grip.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - resizeStart
            win.Size = UDim2.new(0, math.max(L.WinMinW, resizeStartSz.X + d.X),
                                  0, math.max(L.WinMinH, resizeStartSz.Y + d.Y))
        end
    end)

    -- Right Shift toggle — use a solid overlay fade so only that one
    -- frame animates; all children are unaffected.
    local menuVisible = true
    local overlay = mk("Frame", {
        Name             = "ToggleOverlay",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 200,
        Visible          = false,
    }, inner)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.RightShift then
            menuVisible = not menuVisible
            if menuVisible then
                -- Fade in: show window, overlay opaque → transparent
                win.Visible = true
                overlay.Visible = true
                overlay.BackgroundTransparency = 0
                tw(overlay, {BackgroundTransparency = 1}, 0.18)
                task.delay(0.19, function() overlay.Visible = false end)
            else
                -- Fade out: overlay transparent → opaque, then hide window
                overlay.Visible = true
                overlay.BackgroundTransparency = 1
                tw(overlay, {BackgroundTransparency = 0}, 0.16)
                task.delay(0.17, function()
                    if not menuVisible then
                        win.Visible = false
                        overlay.Visible = false
                        overlay.BackgroundTransparency = 1
                    end
                end)
            end
        end
    end)

    -- Watermark
    local wmText = opts.watermark or (self._title .. "  |  v1.0")
    local wm, wmConn = createWatermark(sg, wmText)
    self._wm     = wm
    self._wmConn = wmConn

    return self
end

-- ══════════════════════════════════════════════════════════════
-- TAB MANAGEMENT
-- ══════════════════════════════════════════════════════════════
function NexusUI:AddTab(name)
    local idx = #self._tabs + 1

    if not self._hasTabs then
        self._hasTabs      = true
        self._grip.Visible = false   -- no resize when tabs present
        self._tabBar.Visible = true
    end

    local btn = mk("TextButton", {
        Name             = "TabBtn_" .. name,
        Size             = UDim2.new(0, math.max(52, #name * 8 + 18), 0, 20),
        BackgroundColor3 = T.BgPanel,
        Text             = name,
        TextColor3       = T.TextMuted,
        TextSize         = 11,
        FontFace         = FS,
        BorderSizePixel  = 0,
        LayoutOrder      = idx,
    }, self._tabInner)
    rnd(L.TabRadius, btn)

    -- ScrollingFrame per tab
    -- ClipsDescendants FALSE: dropdown/picker overlays must not be clipped here.
    -- The actual content clipping is handled by the parent Content frame.
    local sf = mk("ScrollingFrame", {
        Name                 = "SF_" .. name,
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        Visible              = false,
        ClipsDescendants     = false,
    }, self._content)

    local sll = Instance.new("UIListLayout")
    sll.SortOrder = Enum.SortOrder.LayoutOrder
    sll.Padding   = UDim.new(0, L.Gap)
    sll.Parent    = sf

    local spad = Instance.new("UIPadding")
    spad.PaddingLeft   = UDim.new(0, L.Pad)
    spad.PaddingRight  = UDim.new(0, L.Pad)
    spad.PaddingTop    = UDim.new(0, L.Pad)
    spad.PaddingBottom = UDim.new(0, L.Pad)
    spad.Parent = sf

    local td = { name = name, items = {}, sf = sf, btn = btn }
    self._tabs[idx]        = td
    self._tabsByName[name] = td

    btn.MouseButton1Click:Connect(function() self:_switch(name) end)
    btn.MouseEnter:Connect(function()
        if self._activeTab ~= name then tw(btn, {TextColor3 = T.TextSecondary}, 0.1) end
    end)
    btn.MouseLeave:Connect(function()
        if self._activeTab ~= name then tw(btn, {TextColor3 = T.TextMuted}, 0.1) end
    end)

    if idx == 1 then self:_switch(name) end
    return self
end

function NexusUI:_switch(name)
    self._activeTab = name
    for _, td in ipairs(self._tabs) do
        local active = td.name == name
        td.sf.Visible = active
        if active then
            tw(td.btn, {BackgroundColor3 = T.BgWidget, TextColor3 = T.TextPrimary}, 0.12)
        else
            tw(td.btn, {BackgroundColor3 = T.BgPanel,  TextColor3 = T.TextMuted  }, 0.12)
        end
    end
end

function NexusUI:Tab(name)
    assert(self._tabsByName[name],
        "Tab '" .. tostring(name) .. "' not found. Use :AddTab() first.")
    return setmetatable({ _td = self._tabsByName[name], _ui = self }, TabBuilder)
end

-- ── Single-window (no-tab) mode ───────────────────────────────
local function ensureDef(self)
    if not self._tabsByName["__def"] then
        self._tabBar.Visible = false
        self._grip.Visible   = true

        local top = L.TitleH
        self._content.Position = UDim2.new(0, 0, 0, top)
        self._content.Size     = UDim2.new(1, 0, 1, -(top + L.GripSz))

        local idx = #self._tabs + 1
        local btn = mk("TextButton", {
            Size             = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text             = "",
            Visible          = false,
        }, self._tabInner)

        local sf = mk("ScrollingFrame", {
            Name                 = "SF___def",
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 3,
            ScrollBarImageColor3 = T.ScrollBar,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible              = true,
            ClipsDescendants     = false,
        }, self._content)

        local sll = Instance.new("UIListLayout")
        sll.SortOrder = Enum.SortOrder.LayoutOrder
        sll.Padding   = UDim.new(0, L.Gap)
        sll.Parent    = sf

        local spad = Instance.new("UIPadding")
        spad.PaddingLeft   = UDim.new(0, L.Pad)
        spad.PaddingRight  = UDim.new(0, L.Pad)
        spad.PaddingTop    = UDim.new(0, L.Pad)
        spad.PaddingBottom = UDim.new(0, L.Pad)
        spad.Parent = sf

        local td = { name = "__def", items = {}, sf = sf, btn = btn }
        self._tabs[idx]           = td
        self._tabsByName["__def"] = td
    end
    return self._tabsByName["__def"]
end

-- ══════════════════════════════════════════════════════════════
-- WIDGET BUILDERS
-- ══════════════════════════════════════════════════════════════

-- ── Label ─────────────────────────────────────────────────────
local function buildLabel(td, text)
    table.insert(td.items, function(parent, ord)
        mk("TextLabel", {
            Name                   = "Lbl_" .. ord,
            Size                   = UDim2.new(1, 0, 0, L.LabelH),
            BackgroundTransparency = 1,
            Text                   = text,
            TextColor3             = T.TextSecondary,
            TextSize               = 12,
            FontFace               = FR,
            TextXAlignment         = Enum.TextXAlignment.Left,
            LayoutOrder            = ord,
        }, parent)
    end)
end

-- ── Separator ─────────────────────────────────────────────────
local function buildSep(td)
    table.insert(td.items, function(parent, ord)
        mk("Frame", {
            Name             = "Sep_" .. ord,
            Size             = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Border,
            BorderSizePixel  = 0,
            LayoutOrder      = ord,
        }, parent)
    end)
end

-- ── Button ────────────────────────────────────────────────────
local function buildButton(td, label, cb)
    table.insert(td.items, function(parent, ord)
        local btn = mk("TextButton", {
            Name             = "Btn_" .. ord,
            Size             = UDim2.new(1, 0, 0, L.BtnH),
            BackgroundColor3 = T.BgWidget,
            Text             = label,
            TextColor3       = T.TextPrimary,
            TextSize         = 12,
            FontFace         = FS,
            BorderSizePixel  = 0,
            LayoutOrder      = ord,
        }, parent)
        rnd(L.Radius - 2, btn)
        strk(T.Border, 1, btn)

        btn.MouseEnter:Connect(function()
            tw(btn, {BackgroundColor3 = T.BgHover, TextColor3 = T.AccentGlow})
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundColor3 = T.BgWidget, TextColor3 = T.TextPrimary})
        end)
        btn.MouseButton1Down:Connect(function()
            tw(btn, {BackgroundColor3 = T.AccentDim}, 0.06)
        end)
        btn.MouseButton1Up:Connect(function()
            tw(btn, {BackgroundColor3 = T.BgHover}, 0.06)
            if cb then task.spawn(cb) end
        end)
    end)
end

-- ── Toggle ────────────────────────────────────────────────────
local function buildToggle(td, label, default, cb)
    local state = default == true
    table.insert(td.items, function(parent, ord)
        local row = mk("Frame", {
            Name                   = "Tog_" .. ord,
            Size                   = UDim2.new(1, 0, 0, L.TogH),
            BackgroundTransparency = 1,
            LayoutOrder            = ord,
        }, parent)

        mk("TextLabel", {
            Size                   = UDim2.new(1, -48, 1, 0),
            BackgroundTransparency = 1,
            Text                   = label,
            TextColor3             = T.TextPrimary,
            TextSize               = 12,
            FontFace               = FR,
            TextXAlignment         = Enum.TextXAlignment.Left,
        }, row)

        local tW, tH = 36, 18
        local track  = mk("Frame", {
            Size             = UDim2.new(0, tW, 0, tH),
            Position         = UDim2.new(1, -tW, 0.5, -tH / 2),
            BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
            BorderSizePixel  = 0,
        }, row)
        rnd(tH / 2, track)
        local trkStroke = strk(state and T.Accent or T.Border, 1, track)

        local kS   = tH - 4
        local kOnX = tW - kS - 2
        local knob = mk("Frame", {
            Size             = UDim2.new(0, kS, 0, kS),
            Position         = state
                               and UDim2.new(0, kOnX, 0.5, -kS / 2)
                               or  UDim2.new(0, 2,    0.5, -kS / 2),
            BackgroundColor3 = T.ToggleKnob,
            BorderSizePixel  = 0,
        }, track)
        rnd(kS / 2, knob)

        local hit = mk("TextButton", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = "",
        }, row)

        hit.MouseButton1Click:Connect(function()
            state = not state
            tw(track, {BackgroundColor3 = state and T.ToggleOn or T.ToggleOff}, 0.18)
            tw(knob, {
                Position = state
                           and UDim2.new(0, kOnX, 0.5, -kS / 2)
                           or  UDim2.new(0, 2,    0.5, -kS / 2)
            }, 0.18, Enum.EasingStyle.Back)
            tw(trkStroke, {Color = state and T.Accent or T.Border}, 0.18)
            if cb then task.spawn(cb, state) end
        end)
    end)
end

-- ── Slider ────────────────────────────────────────────────────
local function buildSlider(td, label, min, max, default, cb)
    min     = min or 0
    max     = max or 100
    default = math.clamp(default or min, min, max)
    local value = default

    table.insert(td.items, function(parent, ord)
        local col = mk("Frame", {
            Name                   = "Sldr_" .. ord,
            Size                   = UDim2.new(1, 0, 0, L.SliderH),
            BackgroundTransparency = 1,
            LayoutOrder            = ord,
        }, parent)

        local hdr = mk("Frame", {
            Size                   = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
        }, col)

        mk("TextLabel", {
            Size                   = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = label,
            TextColor3             = T.TextPrimary,
            TextSize               = 12,
            FontFace               = FR,
            TextXAlignment         = Enum.TextXAlignment.Left,
        }, hdr)

        local valLbl = mk("TextLabel", {
            Size                   = UDim2.new(0.3, 0, 1, 0),
            Position               = UDim2.new(0.7, 0, 0, 0),
            BackgroundTransparency = 1,
            Text                   = tostring(math.floor(value)),
            TextColor3             = T.Accent,
            TextSize               = 12,
            FontFace               = FB,
            TextXAlignment         = Enum.TextXAlignment.Right,
        }, hdr)

        local trkH = 5
        local track = mk("Frame", {
            Size             = UDim2.new(1, 0, 0, trkH),
            Position         = UDim2.new(0, 0, 0, 22),
            BackgroundColor3 = T.SliderTrack,
            BorderSizePixel  = 0,
        }, col)
        rnd(trkH / 2, track)

        local pct  = (value - min) / (max - min)
        local fill = mk("Frame", {
            Size             = UDim2.new(pct, 0, 1, 0),
            BackgroundColor3 = T.SliderFill,
            BorderSizePixel  = 0,
        }, track)
        rnd(trkH / 2, fill)

        local fg = Instance.new("UIGradient")
        fg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, T.AccentDim),
            ColorSequenceKeypoint.new(1, T.AccentGlow),
        }
        fg.Parent = fill

        local kS   = 13
        local knob = mk("Frame", {
            Size             = UDim2.new(0, kS, 0, kS),
            Position         = UDim2.new(pct, -kS / 2, 0.5, -kS / 2),
            BackgroundColor3 = T.SliderKnob,
            BorderSizePixel  = 0,
            ZIndex           = 2,
        }, track)
        rnd(kS / 2, knob)
        strk(T.Accent, 1.5, knob)

        local hit = mk("TextButton", {
            Size                   = UDim2.new(1, 0, 0, 24),
            Position               = UDim2.new(0, 0, 0, 12),
            BackgroundTransparency = 1,
            Text                   = "",
            ZIndex                 = 3,
        }, col)

        local function update(x)
            local p = math.clamp(
                (x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value         = min + p * (max - min)
            valLbl.Text   = tostring(math.floor(value))
            fill.Size     = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -kS / 2, 0.5, -kS / 2)
            if cb then cb(math.floor(value)) end
        end

        local sliding = false
        hit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                update(inp.Position.X)
            end
        end)
        hit.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                update(inp.Position.X)
            end
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- DROPDOWN
-- The list frame is parented directly to the ScreenGui so it
-- is never clipped by any ScrollingFrame or ClipsDescendants
-- ancestor.  It is positioned in absolute screen coordinates
-- every time it opens.
-- ══════════════════════════════════════════════════════════════
local function buildDropdown(td, label, options, default, cb)
    local selected = default or (options and options[1]) or ""
    options = options or {}

    table.insert(td.items, function(parent, ord)
        -- Header row stays in the scroll frame
        local wrap = mk("Frame", {
            Name                   = "Drop_" .. ord,
            Size                   = UDim2.new(1, 0, 0, L.DropH),
            BackgroundTransparency = 1,
            LayoutOrder            = ord,
            ClipsDescendants       = false,
        }, parent)

        local header = mk("TextButton", {
            Size             = UDim2.new(1, 0, 0, L.DropH),
            BackgroundColor3 = T.BgWidget,
            Text             = "",
            BorderSizePixel  = 0,
            ZIndex           = 3,
        }, wrap)
        rnd(L.Radius - 2, header)
        strk(T.Border, 1, header)

        mk("TextLabel", {
            Size                   = UDim2.new(0, 80, 1, 0),
            Position               = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text                   = label .. ":",
            TextColor3             = T.TextSecondary,
            TextSize               = 11,
            FontFace               = FR,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 4,
        }, header)

        local selLbl = mk("TextLabel", {
            Size                   = UDim2.new(1, -88, 1, 0),
            Position               = UDim2.new(0, 85, 0, 0),
            BackgroundTransparency = 1,
            Text                   = selected,
            TextColor3             = T.TextPrimary,
            TextSize               = 12,
            FontFace               = FS,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ClipsDescendants       = true,
            ZIndex                 = 4,
        }, header)

        local arrow = mk("TextLabel", {
            Size                   = UDim2.new(0, 18, 1, 0),
            Position               = UDim2.new(1, -22, 0, 0),
            BackgroundTransparency = 1,
            Text                   = "▾",
            TextColor3             = T.TextMuted,
            TextSize               = 13,
            FontFace               = FS,
            ZIndex                 = 4,
        }, header)

        -- Overlay list — parented to ScreenGui, positioned absolutely
        local sg    = getScreenGui(parent)
        local listH = #options * L.DropItemH + 6

        local list = mk("Frame", {
            Name             = "DropList_" .. math.random(1e6),
            Size             = UDim2.new(0, 1, 0, 0),
            BackgroundColor3 = T.BgDeep,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
            Visible          = false,
            ZIndex           = 50,
        }, sg)
        rnd(L.Radius - 2, list)
        strk(T.BorderLight, 1, list)

        local lll = Instance.new("UIListLayout")
        lll.SortOrder = Enum.SortOrder.LayoutOrder
        lll.Parent    = list

        local lpad = Instance.new("UIPadding")
        lpad.PaddingTop    = UDim.new(0, 3)
        lpad.PaddingBottom = UDim.new(0, 3)
        lpad.PaddingLeft   = UDim.new(0, 4)
        lpad.PaddingRight  = UDim.new(0, 4)
        lpad.Parent = list

        for i, opt in ipairs(options) do
            local item = mk("TextButton", {
                Name                   = "Item_" .. i,
                Size                   = UDim2.new(1, 0, 0, L.DropItemH),
                BackgroundColor3       = T.BgWidget,
                BackgroundTransparency = 1,
                Text                   = opt,
                TextColor3             = opt == selected and T.Accent or T.TextSecondary,
                TextSize               = 12,
                FontFace               = opt == selected and FS or FR,
                TextXAlignment         = Enum.TextXAlignment.Left,
                LayoutOrder            = i,
                ZIndex                 = 51,
            }, list)
            rnd(4, item)

            local ip = Instance.new("UIPadding")
            ip.PaddingLeft = UDim.new(0, 6)
            ip.Parent = item

            item.MouseEnter:Connect(function() tw(item, {BackgroundTransparency = 0}, 0.08) end)
            item.MouseLeave:Connect(function() tw(item, {BackgroundTransparency = 1}, 0.08) end)

            item.MouseButton1Click:Connect(function()
                selected    = opt
                selLbl.Text = opt
                for _, ch in ipairs(list:GetChildren()) do
                    if ch:IsA("TextButton") then
                        local isThis = (ch.Text == selected)
                        ch.TextColor3 = isThis and T.Accent or T.TextSecondary
                        ch.FontFace   = isThis and FS or FR
                    end
                end
                tw(list,  {Size = UDim2.new(0, list.AbsoluteSize.X, 0, 0)}, 0.14, Enum.EasingStyle.Quint)
                tw(arrow, {Rotation = 0}, 0.14)
                tw(header, {BackgroundColor3 = T.BgWidget})
                task.delay(0.15, function() list.Visible = false end)
                if cb then task.spawn(cb, selected) end
            end)
        end

        local open = false

        local function openList()
            -- Re-read position every time (window may have been dragged)
            local absPos  = header.AbsolutePosition
            local absSize = header.AbsoluteSize
            local W = absSize.X
            list.Size     = UDim2.new(0, W, 0, 0)
            list.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 3)
            list.Visible  = true
            tw(list,  {Size = UDim2.new(0, W, 0, listH)}, 0.18, Enum.EasingStyle.Quint)
            tw(arrow, {Rotation = 180}, 0.15)
            tw(header, {BackgroundColor3 = T.BgHover})
        end

        local function closeList()
            tw(list,  {Size = UDim2.new(0, list.AbsoluteSize.X, 0, 0)}, 0.14, Enum.EasingStyle.Quint)
            tw(arrow, {Rotation = 0}, 0.14)
            tw(header, {BackgroundColor3 = T.BgWidget})
            task.delay(0.15, function() list.Visible = false end)
        end

        header.MouseButton1Click:Connect(function()
            open = not open
            if open then openList() else closeList() end
        end)
        header.MouseEnter:Connect(function()
            if not open then tw(header, {BackgroundColor3 = T.BgHover}) end
        end)
        header.MouseLeave:Connect(function()
            if not open then tw(header, {BackgroundColor3 = T.BgWidget}) end
        end)

        -- Close when clicking outside
        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if open and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                task.defer(function()
                    if not list.Visible then return end
                    local mp = UserInputService:GetMouseLocation()
                    local lp = list.AbsolutePosition
                    local ls = list.AbsoluteSize
                    local hp = header.AbsolutePosition
                    local hs = header.AbsoluteSize
                    local inList   = mp.X >= lp.X and mp.X <= lp.X + ls.X
                                 and mp.Y >= lp.Y and mp.Y <= lp.Y + ls.Y
                    local inHeader = mp.X >= hp.X and mp.X <= hp.X + hs.X
                                 and mp.Y >= hp.Y and mp.Y <= hp.Y + hs.Y
                    if not inList and not inHeader then
                        open = false
                        closeList()
                    end
                end)
            end
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- COLOR PICKER (HSV)
-- Same screen-space overlay approach as dropdown.
-- ══════════════════════════════════════════════════════════════
local function buildColorPicker(td, label, defaultColor, cb)
    defaultColor = defaultColor or Color3.fromRGB(255, 100, 100)
    local r0, g0, b0 = defaultColor.R, defaultColor.G, defaultColor.B
    local hue, sat, val = rgbToHsv(r0, g0, b0)
    local alpha = 1

    table.insert(td.items, function(parent, ord)
        local SV_SZ   = 140
        local BAR_W   = 16
        local GAP     = 8
        local INFO_H  = 20
        local PANEL_W = SV_SZ + GAP + BAR_W + GAP + BAR_W + 20  -- 212
        local PANEL_H = SV_SZ + GAP + INFO_H + 20

        local wrap = mk("Frame", {
            Name                   = "CP_" .. ord,
            Size                   = UDim2.new(1, 0, 0, L.DropH),
            BackgroundTransparency = 1,
            LayoutOrder            = ord,
            ClipsDescendants       = false,
        }, parent)

        local header = mk("TextButton", {
            Size             = UDim2.new(1, 0, 0, L.DropH),
            BackgroundColor3 = T.BgWidget,
            Text             = "",
            BorderSizePixel  = 0,
            ZIndex           = 3,
        }, wrap)
        rnd(L.Radius - 2, header)
        strk(T.Border, 1, header)

        mk("TextLabel", {
            Size                   = UDim2.new(0, 90, 1, 0),
            Position               = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text                   = label .. ":",
            TextColor3             = T.TextSecondary,
            TextSize               = 11,
            FontFace               = FR,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 4,
        }, header)

        local swatch = mk("Frame", {
            Size             = UDim2.new(0, 50, 0, 14),
            Position         = UDim2.new(1, -60, 0.5, -7),
            BackgroundColor3 = defaultColor,
            BorderSizePixel  = 0,
            ZIndex           = 4,
        }, header)
        rnd(3, swatch)
        strk(T.Border, 1, swatch)

        -- Overlay panel on ScreenGui
        local sg2   = getScreenGui(parent)
        local panel = mk("Frame", {
            Name             = "CPPanel_" .. math.random(1e6),
            Size             = UDim2.new(0, PANEL_W, 0, 0),
            BackgroundColor3 = T.BgDeep,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
            Visible          = false,
            ZIndex           = 50,
        }, sg2)
        rnd(L.Radius - 2, panel)
        strk(T.BorderLight, 1, panel)

        -- SV Square
        local svBox = mk("Frame", {
            Size             = UDim2.new(0, SV_SZ, 0, SV_SZ),
            Position         = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 51,
        }, panel)
        rnd(4, svBox)

        mk("ImageLabel", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image                  = "rbxassetid://4155801252",
            ImageColor3            = Color3.new(1, 1, 1),
            ZIndex                 = 52,
        }, svBox)

        mk("ImageLabel", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image                  = "rbxassetid://4155801252",
            ImageColor3            = Color3.new(0, 0, 0),
            Rotation               = 90,
            ZIndex                 = 53,
        }, svBox)

        local svCursor = mk("Frame", {
            Size             = UDim2.new(0, 10, 0, 10),
            Position         = UDim2.new(sat, -5, 1 - val, -5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 54,
        }, svBox)
        rnd(5, svCursor)
        strk(Color3.new(0, 0, 0), 1.5, svCursor)

        -- Hue Bar
        local hueX   = 10 + SV_SZ + GAP
        local hueBar = mk("Frame", {
            Size             = UDim2.new(0, BAR_W, 0, SV_SZ),
            Position         = UDim2.new(0, hueX, 0, 10),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 51,
        }, panel)
        rnd(4, hueBar)

        local hueGrad = Instance.new("UIGradient")
        hueGrad.Rotation = 270
        hueGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255, 0,   0)),
            ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0,   255, 0)),
            ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0,   255, 255)),
            ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0,   0,   255)),
            ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0,   255)),
            ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255, 0,   0)),
        }
        hueGrad.Parent = hueBar

        local hueCursor = mk("Frame", {
            Size             = UDim2.new(1, 4, 0, 4),
            Position         = UDim2.new(0, -2, hue, -2),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 55,
        }, hueBar)
        rnd(2, hueCursor)
        strk(Color3.new(0, 0, 0), 1, hueCursor)

        -- Alpha Bar
        local alphaX   = hueX + BAR_W + GAP
        local alphaBar = mk("Frame", {
            Size             = UDim2.new(0, BAR_W, 0, SV_SZ),
            Position         = UDim2.new(0, alphaX, 0, 10),
            BackgroundColor3 = Color3.fromRGB(30, 30, 40),
            BorderSizePixel  = 0,
            ZIndex           = 51,
        }, panel)
        rnd(4, alphaBar)
        strk(T.Border, 1, alphaBar)

        local alphaGradFrame = mk("Frame", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 52,
        }, alphaBar)
        rnd(4, alphaGradFrame)

        local alphaGrad = Instance.new("UIGradient")
        alphaGrad.Rotation = 270
        alphaGrad.Parent   = alphaGradFrame

        local function updateAlphaGrad()
            local cr2, cg2, cb2 = hsvToRgb(hue, sat, val)
            alphaGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(cr2, cg2, cb2)),
                ColorSequenceKeypoint.new(1, Color3.new(cr2, cg2, cb2)),
            }
            alphaGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }
        end
        updateAlphaGrad()

        local alphaCursor = mk("Frame", {
            Size             = UDim2.new(1, 4, 0, 4),
            Position         = UDim2.new(0, -2, 1 - alpha, -2),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 55,
        }, alphaBar)
        rnd(2, alphaCursor)
        strk(Color3.new(0, 0, 0), 1, alphaCursor)

        -- Hex readout
        local hexY   = 10 + SV_SZ + GAP
        local hexLbl = mk("TextLabel", {
            Size                   = UDim2.new(0, SV_SZ + GAP + BAR_W * 2 + GAP, 0, INFO_H),
            Position               = UDim2.new(0, 10, 0, hexY),
            BackgroundColor3       = T.BgWidget,
            BackgroundTransparency = 0,
            Text                   = "",
            TextColor3             = T.TextSecondary,
            TextSize               = 11,
            FontFace               = FR,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 51,
        }, panel)
        rnd(4, hexLbl)

        local hexPad = Instance.new("UIPadding")
        hexPad.PaddingLeft = UDim.new(0, 6)
        hexPad.Parent = hexLbl

        local tinySwatch = mk("Frame", {
            Size             = UDim2.new(0, 12, 0, 12),
            Position         = UDim2.new(1, -18, 0.5, -6),
            BackgroundColor3 = defaultColor,
            BorderSizePixel  = 0,
            ZIndex           = 52,
        }, hexLbl)
        rnd(3, tinySwatch)

        local function fireColor()
            local cr2, cg2, cb2 = hsvToRgb(hue, sat, val)
            local out = Color3.new(cr2, cg2, cb2)
            swatch.BackgroundColor3     = out
            tinySwatch.BackgroundColor3 = out
            svBox.BackgroundColor3      = Color3.fromHSV(hue, 1, 1)
            hexLbl.Text = string.format("  #%02X%02X%02X   α:%.2f",
                math.floor(cr2*255), math.floor(cg2*255), math.floor(cb2*255), alpha)
            updateAlphaGrad()
            if cb then task.spawn(cb, out, alpha) end
        end
        fireColor()

        -- SV drag
        local svDrag = false
        local svHit  = mk("TextButton", {
            Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=60
        }, svBox)
        local function updSV(x, y)
            local px = math.clamp((x-svBox.AbsolutePosition.X)/svBox.AbsoluteSize.X, 0, 1)
            local py = math.clamp((y-svBox.AbsolutePosition.Y)/svBox.AbsoluteSize.Y, 0, 1)
            sat=px; val=1-py
            svCursor.Position = UDim2.new(px,-5,py,-5)
            fireColor()
        end
        svHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true; updSV(i.Position.X,i.Position.Y) end end)
        svHit.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)
        UserInputService.InputChanged:Connect(function(i) if svDrag and i.UserInputType==Enum.UserInputType.MouseMovement then updSV(i.Position.X,i.Position.Y) end end)

        -- Hue drag
        local hueDrag = false
        local hueHit  = mk("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=60
        }, hueBar)
        local function updHue(y)
            local py = math.clamp((y-hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y, 0, 1)
            hue=py
            hueCursor.Position = UDim2.new(0,-2,py,-2)
            svBox.BackgroundColor3 = Color3.fromHSV(hue,1,1)
            fireColor()
        end
        hueHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true; updHue(i.Position.Y) end end)
        hueHit.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end end)
        UserInputService.InputChanged:Connect(function(i) if hueDrag and i.UserInputType==Enum.UserInputType.MouseMovement then updHue(i.Position.Y) end end)

        -- Alpha drag
        local aDrag = false
        local aHit  = mk("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=60
        }, alphaBar)
        local function updAlpha(y)
            local py = math.clamp((y-alphaBar.AbsolutePosition.Y)/alphaBar.AbsoluteSize.Y, 0, 1)
            alpha=1-py
            alphaCursor.Position = UDim2.new(0,-2,py,-2)
            fireColor()
        end
        aHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then aDrag=true; updAlpha(i.Position.Y) end end)
        aHit.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then aDrag=false end end)
        UserInputService.InputChanged:Connect(function(i) if aDrag and i.UserInputType==Enum.UserInputType.MouseMovement then updAlpha(i.Position.Y) end end)

        -- Open / Close
        local cpOpen = false

        local function openCP()
            local absPos  = header.AbsolutePosition
            local absSize = header.AbsoluteSize
            panel.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 3)
            panel.Size     = UDim2.new(0, PANEL_W, 0, 0)
            panel.Visible  = true
            tw(panel, {Size = UDim2.new(0, PANEL_W, 0, PANEL_H)}, 0.2, Enum.EasingStyle.Quint)
            tw(header, {BackgroundColor3 = T.BgHover})
        end

        local function closeCP()
            tw(panel, {Size = UDim2.new(0, PANEL_W, 0, 0)}, 0.15, Enum.EasingStyle.Quint)
            tw(header, {BackgroundColor3 = T.BgWidget})
            task.delay(0.16, function() panel.Visible = false end)
        end

        header.MouseButton1Click:Connect(function()
            cpOpen = not cpOpen
            if cpOpen then openCP() else closeCP() end
        end)
        header.MouseEnter:Connect(function()
            if not cpOpen then tw(header, {BackgroundColor3 = T.BgHover}) end
        end)
        header.MouseLeave:Connect(function()
            if not cpOpen then tw(header, {BackgroundColor3 = T.BgWidget}) end
        end)

        UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if cpOpen and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                task.defer(function()
                    if not panel.Visible then return end
                    local mp = UserInputService:GetMouseLocation()
                    local pp = panel.AbsolutePosition
                    local ps = panel.AbsoluteSize
                    local hp = header.AbsolutePosition
                    local hs = header.AbsoluteSize
                    local inP = mp.X>=pp.X and mp.X<=pp.X+ps.X and mp.Y>=pp.Y and mp.Y<=pp.Y+ps.Y
                    local inH = mp.X>=hp.X and mp.X<=hp.X+hs.X and mp.Y>=hp.Y and mp.Y<=hp.Y+hs.Y
                    if not inP and not inH then cpOpen=false; closeCP() end
                end)
            end
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- TabBuilder API
-- ══════════════════════════════════════════════════════════════
function TabBuilder:Label(text)                buildLabel(self._td, text);                    return self end
function TabBuilder:Separator()                buildSep(self._td);                            return self end
function TabBuilder:Button(l, cb)              buildButton(self._td, l, cb);                  return self end
function TabBuilder:Toggle(l, d, cb)           buildToggle(self._td, l, d, cb);               return self end
function TabBuilder:Slider(l, mn, mx, d, cb)   buildSlider(self._td, l, mn, mx, d, cb);       return self end
function TabBuilder:Dropdown(l, opts, def, cb) buildDropdown(self._td, l, opts, def, cb);     return self end
function TabBuilder:ColorPicker(l, def, cb)    buildColorPicker(self._td, l, def, cb);        return self end

-- ── Window proxies (single-window / no-tab mode) ──────────────
function NexusUI:Label(t)                buildLabel(ensureDef(self), t);                      return self end
function NexusUI:Separator()             buildSep(ensureDef(self));                           return self end
function NexusUI:Button(l, cb)           buildButton(ensureDef(self), l, cb);                 return self end
function NexusUI:Toggle(l, d, cb)        buildToggle(ensureDef(self), l, d, cb);              return self end
function NexusUI:Slider(l,mn,mx,d,cb)    buildSlider(ensureDef(self), l, mn, mx, d, cb);     return self end
function NexusUI:Dropdown(l,opts,def,cb) buildDropdown(ensureDef(self), l, opts, def, cb);   return self end
function NexusUI:ColorPicker(l,def,cb)   buildColorPicker(ensureDef(self), l, def, cb);      return self end

-- ── Render ────────────────────────────────────────────────────
function NexusUI:Render()
    assert(not self._rendered, "Render() called more than once.")
    for _, td in ipairs(self._tabs) do
        for i, fn in ipairs(td.items) do
            fn(td.sf, i)
        end
    end
    self._rendered = true
end

-- ── Visibility ────────────────────────────────────────────────
function NexusUI:Show()         self._win.Visible = true  end
function NexusUI:Hide()         self._win.Visible = false end
function NexusUI:ToggleWindow() self._win.Visible = not self._win.Visible end
function NexusUI:Destroy()
    if self._wmConn then self._wmConn:Disconnect() end
    if self._sg     then self._sg:Destroy() end
end

return NexusUI

--[[
============================================================
QUICK START
============================================================

local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/RbxCheats/UiLib2/refs/heads/main/OnetapUI.lua"
))()

local win = UI.new("MyMenu", { watermark = "MyMenu  |  v1.0" })

win:AddTab("Main")
win:AddTab("Misc")

win:Tab("Main"):Label("Controls")
win:Tab("Main"):Separator()
win:Tab("Main"):Toggle("God Mode", false, function(on) end)
win:Tab("Main"):Slider("Speed", 0, 500, 16, function(v) end)
win:Tab("Main"):Dropdown("Team", {"Red","Blue","Green"}, "Red", function(s) end)
win:Tab("Main"):ColorPicker("ESP Color", Color3.new(1,0,0), function(c, a) end)
win:Tab("Misc"):Button("Reset", function() end)

win:Render()
-- Press Right Shift to toggle

]]
