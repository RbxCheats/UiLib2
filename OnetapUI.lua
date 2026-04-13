--[[
    OnetapUI — Roblox UI Library
    Inspired by the CS:GO onetap cheat panel aesthetic
    
    LOADSTRING USAGE:
        local OnetapUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
    
    FULL USAGE EXAMPLE AT BOTTOM OF FILE
--]]

local OnetapUI = {}
OnetapUI.__index = OnetapUI

-- ══════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════
local Theme = {
    -- Window
    Background      = Color3.fromRGB(18, 18, 20),
    BackgroundAlt   = Color3.fromRGB(23, 23, 26),
    Border          = Color3.fromRGB(40, 40, 46),
    BorderAccent    = Color3.fromRGB(220, 60, 60),

    -- Header
    Header          = Color3.fromRGB(13, 13, 15),
    HeaderText      = Color3.fromRGB(235, 235, 235),
    HeaderSub       = Color3.fromRGB(130, 130, 140),

    -- Tabs
    TabActive       = Color3.fromRGB(220, 60, 60),
    TabInactive     = Color3.fromRGB(30, 30, 34),
    TabHover        = Color3.fromRGB(38, 38, 43),
    TabText         = Color3.fromRGB(200, 200, 210),
    TabTextActive   = Color3.fromRGB(255, 255, 255),

    -- Elements
    ElementBg       = Color3.fromRGB(26, 26, 30),
    ElementHover    = Color3.fromRGB(32, 32, 37),
    ElementText     = Color3.fromRGB(210, 210, 220),
    ElementTextDim  = Color3.fromRGB(100, 100, 115),

    -- Toggle
    ToggleOn        = Color3.fromRGB(220, 60, 60),
    ToggleOff       = Color3.fromRGB(50, 50, 58),
    ToggleKnob      = Color3.fromRGB(240, 240, 245),

    -- Slider
    SliderTrack     = Color3.fromRGB(40, 40, 48),
    SliderFill      = Color3.fromRGB(220, 60, 60),
    SliderKnob      = Color3.fromRGB(240, 240, 245),

    -- Dropdown
    DropdownBg      = Color3.fromRGB(20, 20, 23),
    DropdownItem    = Color3.fromRGB(26, 26, 30),
    DropdownHover   = Color3.fromRGB(35, 35, 40),
    DropdownSelected= Color3.fromRGB(220, 60, 60),

    -- Separator
    Separator       = Color3.fromRGB(40, 40, 48),
    SeparatorAccent = Color3.fromRGB(220, 60, 60),

    -- Button
    ButtonBg        = Color3.fromRGB(30, 30, 35),
    ButtonHover     = Color3.fromRGB(220, 60, 60),
    ButtonText      = Color3.fromRGB(210, 210, 220),
    ButtonTextHover = Color3.fromRGB(255, 255, 255),

    -- Scrollbar
    ScrollBar       = Color3.fromRGB(50, 50, 60),
    ScrollBarHover  = Color3.fromRGB(220, 60, 60),

    -- Font
    Font            = Enum.Font.GothamBold,
    FontMed         = Enum.Font.Gotham,
    FontLight       = Enum.Font.GothamSemibold,
}

-- ══════════════════════════════════════════════
--  UTILITY
-- ══════════════════════════════════════════════
local function Tween(obj, props, duration, style, dir)
    style    = style or Enum.EasingStyle.Quad
    dir      = dir   or Enum.EasingDirection.Out
    duration = duration or 0.15
    TweenService:Create(obj, TweenInfo.new(duration, style, dir), props):Play()
end

local function CreateInstance(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ══════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════
function OnetapUI:CreateWindow(config)
    config = config or {}
    local title    = config.Title    or "OnetapUI"
    local subtitle = config.Subtitle or "v1.0"
    local width    = config.Width    or 560
    local height   = config.Height   or 420

    -- ScreenGui
    local ScreenGui = CreateInstance("ScreenGui", {
        Name            = "OnetapUI_" .. title,
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 100,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Root frame
    local Root = CreateInstance("Frame", {
        Name            = "Root",
        Size            = UDim2.new(0, width, 0, height),
        Position        = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3= Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants= false,
        Parent          = ScreenGui,
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Root })
    -- Outer glow / border
    CreateInstance("UIStroke", {
        Color     = Theme.Border,
        Thickness = 1.5,
        Parent    = Root,
    })
    -- Top accent line
    local AccentLine = CreateInstance("Frame", {
        Name            = "AccentLine",
        Size            = UDim2.new(1, 0, 0, 2),
        Position        = UDim2.new(0, 0, 0, 0),
        BackgroundColor3= Theme.BorderAccent,
        BorderSizePixel = 0,
        ZIndex          = 5,
        Parent          = Root,
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = AccentLine })

    -- Header
    local Header = CreateInstance("Frame", {
        Name            = "Header",
        Size            = UDim2.new(1, 0, 0, 46),
        BackgroundColor3= Theme.Header,
        BorderSizePixel = 0,
        ZIndex          = 2,
        Parent          = Root,
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Header })
    -- Fix bottom corners of header
    CreateInstance("Frame", {
        Size            = UDim2.new(1, 0, 0, 6),
        Position        = UDim2.new(0, 0, 1, -6),
        BackgroundColor3= Theme.Header,
        BorderSizePixel = 0,
        ZIndex          = 2,
        Parent          = Header,
    })

    -- Logo/Title area
    local TitleLabel = CreateInstance("TextLabel", {
        Name            = "Title",
        Size            = UDim2.new(0, 200, 1, 0),
        Position        = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text            = title,
        TextColor3      = Theme.HeaderText,
        Font            = Theme.Font,
        TextSize        = 15,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 3,
        Parent          = Header,
    })
    CreateInstance("TextLabel", {
        Name            = "Subtitle",
        Size            = UDim2.new(0, 200, 1, 0),
        Position        = UDim2.new(0, 14 + TitleLabel.TextBounds.X + 8, 0, 0),
        BackgroundTransparency = 1,
        Text            = subtitle,
        TextColor3      = Theme.HeaderSub,
        Font            = Theme.FontLight,
        TextSize        = 11,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 3,
        Parent          = Header,
    })

    -- Close button
    local CloseBtn = CreateInstance("TextButton", {
        Name            = "CloseBtn",
        Size            = UDim2.new(0, 28, 0, 28),
        Position        = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3= Color3.fromRGB(40, 40, 46),
        Text            = "✕",
        TextColor3      = Color3.fromRGB(160, 160, 170),
        Font            = Theme.Font,
        TextSize        = 12,
        ZIndex          = 4,
        Parent          = Header,
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CloseBtn })
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Theme.BorderAccent, TextColor3 = Color3.fromRGB(255,255,255) })
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Color3.fromRGB(40,40,46), TextColor3 = Color3.fromRGB(160,160,170) })
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Tab bar
    local TabBar = CreateInstance("Frame", {
        Name            = "TabBar",
        Size            = UDim2.new(0, 120, 1, -46),
        Position        = UDim2.new(0, 0, 0, 46),
        BackgroundColor3= Theme.BackgroundAlt,
        BorderSizePixel = 0,
        ClipsDescendants= true,
        Parent          = Root,
    })
    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBar })
    -- Fix right side of tab bar
    CreateInstance("Frame", {
        Size            = UDim2.new(0, 6, 1, 0),
        Position        = UDim2.new(1, -6, 0, 0),
        BackgroundColor3= Theme.BackgroundAlt,
        BorderSizePixel = 0,
        Parent          = TabBar,
    })
    -- Divider line between tab bar and content
    CreateInstance("Frame", {
        Name            = "Divider",
        Size            = UDim2.new(0, 1, 1, -46),
        Position        = UDim2.new(0, 120, 0, 46),
        BackgroundColor3= Theme.Border,
        BorderSizePixel = 0,
        Parent          = Root,
    })

    local TabList = CreateInstance("Frame", {
        Name            = "TabList",
        Size            = UDim2.new(1, 0, 0, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent          = TabBar,
    })
    CreateInstance("UIListLayout", {
        SortOrder   = Enum.SortOrder.LayoutOrder,
        Padding     = UDim.new(0, 2),
        Parent      = TabList,
    })
    CreateInstance("UIPadding", {
        PaddingTop  = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight= UDim.new(0, 6),
        Parent      = TabList,
    })

    -- Content area
    local ContentArea = CreateInstance("Frame", {
        Name            = "ContentArea",
        Size            = UDim2.new(1, -121, 1, -46),
        Position        = UDim2.new(0, 121, 0, 46),
        BackgroundTransparency = 1,
        ClipsDescendants= true,
        Parent          = Root,
    })

    MakeDraggable(Root, Header)

    -- Window object
    local Window = { _tabs = {}, _activeTab = nil, _gui = ScreenGui, _root = Root }

    -- ── CreateTab ──────────────────────────────
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or ""

        local TabBtn = CreateInstance("TextButton", {
            Name            = tabName,
            Size            = UDim2.new(1, 0, 0, 32),
            BackgroundColor3= Theme.TabInactive,
            Text            = "",
            AutoButtonColor = false,
            ZIndex          = 3,
            LayoutOrder     = #self._tabs + 1,
            Parent          = TabList,
        })
        CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabBtn })

        -- Active indicator bar
        local Indicator = CreateInstance("Frame", {
            Size            = UDim2.new(0, 3, 0.6, 0),
            Position        = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3= Theme.TabActive,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex          = 4,
            Parent          = TabBtn,
        })
        CreateInstance("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Indicator })

        local TabLabel = CreateInstance("TextLabel", {
            Size            = UDim2.new(1, -10, 1, 0),
            Position        = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text            = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
            TextColor3      = Theme.TabText,
            Font            = Theme.FontMed,
            TextSize        = 12,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 4,
            Parent          = TabBtn,
        })

        -- Content frame for this tab
        local TabContent = CreateInstance("ScrollingFrame", {
            Name                    = tabName .. "_Content",
            Size                    = UDim2.new(1, -8, 1, -8),
            Position                = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency  = 1,
            BorderSizePixel         = 0,
            ScrollBarThickness      = 3,
            ScrollBarImageColor3    = Theme.ScrollBar,
            CanvasSize              = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize     = Enum.AutomaticSize.Y,
            Visible                 = false,
            ZIndex                  = 2,
            Parent                  = ContentArea,
        })
        CreateInstance("UIListLayout", {
            SortOrder   = Enum.SortOrder.LayoutOrder,
            Padding     = UDim.new(0, 4),
            Parent      = TabContent,
        })
        CreateInstance("UIPadding", {
            PaddingTop      = UDim.new(0, 4),
            PaddingLeft     = UDim.new(0, 4),
            PaddingRight    = UDim.new(0, 4),
            PaddingBottom   = UDim.new(0, 4),
            Parent          = TabContent,
        })

        local function SetActive(active)
            if active then
                Tween(TabBtn,   { BackgroundColor3 = Color3.fromRGB(28,28,32) })
                Tween(TabLabel, { TextColor3 = Theme.TabTextActive })
                Tween(Indicator,{ BackgroundTransparency = 0 })
                TabContent.Visible = true
            else
                Tween(TabBtn,   { BackgroundColor3 = Theme.TabInactive })
                Tween(TabLabel, { TextColor3 = Theme.TabText })
                Tween(Indicator,{ BackgroundTransparency = 1 })
                TabContent.Visible = false
            end
        end

        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= tabName then
                Tween(TabBtn, { BackgroundColor3 = Theme.TabHover })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= tabName then
                Tween(TabBtn, { BackgroundColor3 = Theme.TabInactive })
            end
        end)
        TabBtn.MouseButton1Click:Connect(function()
            if Window._activeTab == tabName then return end
            -- Deactivate old
            for name, tab in pairs(self._tabs) do
                if name == Window._activeTab then
                    tab._setActive(false)
                end
            end
            Window._activeTab = tabName
            SetActive(true)
        end)

        local Tab = { _name = tabName, _content = TabContent, _setActive = SetActive, _order = 0 }
        self._tabs[tabName] = Tab

        -- Auto-activate first tab
        if not self._activeTab then
            self._activeTab = tabName
            SetActive(true)
        end

        -- ──────────────────────────────────────────
        --  ELEMENTS
        -- ──────────────────────────────────────────
        local function NextOrder()
            Tab._order = Tab._order + 1
            return Tab._order
        end

        -- ── LABEL ─────────────────────────────────
        function Tab:AddLabel(text)
            local Frame = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                LayoutOrder     = NextOrder(),
                Parent          = TabContent,
            })
            local Lbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(1, -8, 1, 0),
                Position        = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text            = text,
                TextColor3      = Theme.ElementTextDim,
                Font            = Theme.FontLight,
                TextSize        = 11,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = Frame,
            })
            return {
                SetText = function(_, t) Lbl.Text = t end,
                Destroy = function() Frame:Destroy() end,
            }
        end

        -- ── SEPARATOR ─────────────────────────────
        function Tab:AddSeparator(labelText)
            local Frame = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                LayoutOrder     = NextOrder(),
                Parent          = TabContent,
            })
            local Line = CreateInstance("Frame", {
                Size            = UDim2.new(1, -16, 0, 1),
                Position        = UDim2.new(0, 8, 0.5, 0),
                BackgroundColor3= Theme.Separator,
                BorderSizePixel = 0,
                Parent          = Frame,
            })
            local AccentDot = CreateInstance("Frame", {
                Size            = UDim2.new(0, 4, 0, 4),
                Position        = UDim2.new(0, 8, 0.5, -2),
                BackgroundColor3= Theme.SeparatorAccent,
                BorderSizePixel = 0,
                Parent          = Frame,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = AccentDot })
            if labelText and labelText ~= "" then
                local Lbl = CreateInstance("TextLabel", {
                    Size            = UDim2.new(0, 0, 1, 0),
                    AutomaticSize   = Enum.AutomaticSize.X,
                    Position        = UDim2.new(0, 20, 0, 0),
                    BackgroundColor3= Theme.Background,
                    Text            = "  " .. labelText .. "  ",
                    TextColor3      = Theme.ElementTextDim,
                    Font            = Theme.FontLight,
                    TextSize        = 10,
                    ZIndex          = 2,
                    Parent          = Frame,
                })
                CreateInstance("UIPadding", { PaddingLeft = UDim.new(0, 2), Parent = Lbl })
            end
            return { Destroy = function() Frame:Destroy() end }
        end

        -- ── BUTTON ────────────────────────────────
        function Tab:AddButton(buttonConfig)
            buttonConfig = buttonConfig or {}
            local btnText    = buttonConfig.Name     or "Button"
            local callback   = buttonConfig.Callback or function() end

            local Frame = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 34),
                BackgroundColor3= Theme.ElementBg,
                BorderSizePixel = 0,
                LayoutOrder     = NextOrder(),
                Parent          = TabContent,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            local Btn = CreateInstance("TextButton", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 2,
                Parent          = Frame,
            })
            local Lbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(1, -16, 1, 0),
                Position        = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text            = btnText,
                TextColor3      = Theme.ButtonText,
                Font            = Theme.FontMed,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = Frame,
            })
            local Arrow = CreateInstance("TextLabel", {
                Size            = UDim2.new(0, 24, 1, 0),
                Position        = UDim2.new(1, -28, 0, 0),
                BackgroundTransparency = 1,
                Text            = "›",
                TextColor3      = Theme.ElementTextDim,
                Font            = Theme.Font,
                TextSize        = 16,
                ZIndex          = 3,
                Parent          = Frame,
            })

            Btn.MouseEnter:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementHover })
                Tween(Lbl,   { TextColor3 = Color3.fromRGB(255,255,255) })
                Tween(Arrow, { TextColor3 = Theme.BorderAccent })
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementBg })
                Tween(Lbl,   { TextColor3 = Theme.ButtonText })
                Tween(Arrow, { TextColor3 = Theme.ElementTextDim })
            end)
            Btn.MouseButton1Click:Connect(function()
                -- Click flash
                Tween(Frame, { BackgroundColor3 = Theme.BorderAccent }, 0.07)
                task.delay(0.07, function()
                    Tween(Frame, { BackgroundColor3 = Theme.ElementHover }, 0.1)
                end)
                pcall(callback)
            end)

            return {
                SetText = function(_, t) Lbl.Text = t end,
                Destroy = function() Frame:Destroy() end,
            }
        end

        -- ── TOGGLE ────────────────────────────────
        function Tab:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local toggleName = toggleConfig.Name     or "Toggle"
            local default    = toggleConfig.Default  or false
            local callback   = toggleConfig.Callback or function() end

            local toggled = default

            local Frame = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 34),
                BackgroundColor3= Theme.ElementBg,
                BorderSizePixel = 0,
                LayoutOrder     = NextOrder(),
                Parent          = TabContent,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            local Lbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(1, -60, 1, 0),
                Position        = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text            = toggleName,
                TextColor3      = Theme.ElementText,
                Font            = Theme.FontMed,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 2,
                Parent          = Frame,
            })

            -- Track
            local Track = CreateInstance("Frame", {
                Size            = UDim2.new(0, 36, 0, 18),
                Position        = UDim2.new(1, -46, 0.5, -9),
                BackgroundColor3= toggled and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel = 0,
                ZIndex          = 2,
                Parent          = Frame,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

            local Knob = CreateInstance("Frame", {
                Size            = UDim2.new(0, 12, 0, 12),
                Position        = toggled
                    and UDim2.new(1, -15, 0.5, -6)
                    or  UDim2.new(0, 3,   0.5, -6),
                BackgroundColor3= Theme.ToggleKnob,
                BorderSizePixel = 0,
                ZIndex          = 3,
                Parent          = Track,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

            local Btn = CreateInstance("TextButton", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 4,
                Parent          = Frame,
            })

            local function UpdateToggle()
                if toggled then
                    Tween(Track, { BackgroundColor3 = Theme.ToggleOn })
                    Tween(Knob,  { Position = UDim2.new(1, -15, 0.5, -6) })
                else
                    Tween(Track, { BackgroundColor3 = Theme.ToggleOff })
                    Tween(Knob,  { Position = UDim2.new(0, 3, 0.5, -6) })
                end
                pcall(callback, toggled)
            end

            Btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                UpdateToggle()
            end)
            Btn.MouseEnter:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementHover })
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementBg })
            end)

            return {
                SetValue = function(_, v)
                    toggled = v
                    UpdateToggle()
                end,
                GetValue = function() return toggled end,
                Destroy  = function() Frame:Destroy() end,
            }
        end

        -- ── SLIDER ────────────────────────────────
        function Tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local sliderName = sliderConfig.Name    or "Slider"
            local min        = sliderConfig.Min     or 0
            local max        = sliderConfig.Max     or 100
            local default    = sliderConfig.Default or min
            local suffix     = sliderConfig.Suffix  or ""
            local callback   = sliderConfig.Callback or function() end

            local value = math.clamp(default, min, max)

            local Frame = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 44),
                BackgroundColor3= Theme.ElementBg,
                BorderSizePixel = 0,
                LayoutOrder     = NextOrder(),
                Parent          = TabContent,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            local TopRow = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                ZIndex          = 2,
                Parent          = Frame,
            })
            local Lbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(1, -80, 1, 0),
                Position        = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text            = sliderName,
                TextColor3      = Theme.ElementText,
                Font            = Theme.FontMed,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 3,
                Parent          = TopRow,
            })
            local ValLbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(0, 70, 1, 0),
                Position        = UDim2.new(1, -74, 0, 0),
                BackgroundTransparency = 1,
                Text            = tostring(value) .. suffix,
                TextColor3      = Theme.BorderAccent,
                Font            = Theme.Font,
                TextSize        = 11,
                TextXAlignment  = Enum.TextXAlignment.Right,
                ZIndex          = 3,
                Parent          = TopRow,
            })

            -- Track area
            local TrackArea = CreateInstance("Frame", {
                Size            = UDim2.new(1, -16, 0, 18),
                Position        = UDim2.new(0, 8, 0, 22),
                BackgroundTransparency = 1,
                ZIndex          = 2,
                Parent          = Frame,
            })
            local Track = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 4),
                Position        = UDim2.new(0, 0, 0.5, -2),
                BackgroundColor3= Theme.SliderTrack,
                BorderSizePixel = 0,
                ZIndex          = 2,
                Parent          = TrackArea,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })
            local pct = (value - min) / (max - min)
            local Fill = CreateInstance("Frame", {
                Size            = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3= Theme.SliderFill,
                BorderSizePixel = 0,
                ZIndex          = 3,
                Parent          = Track,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
            local Knob = CreateInstance("Frame", {
                Size            = UDim2.new(0, 10, 0, 10),
                Position        = UDim2.new(pct, -5, 0.5, -5),
                BackgroundColor3= Theme.SliderKnob,
                BorderSizePixel = 0,
                ZIndex          = 4,
                Parent          = Track,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

            local dragging = false
            local function Update(inputX)
                local relX = math.clamp(inputX - TrackArea.AbsolutePosition.X, 0, TrackArea.AbsoluteSize.X)
                local p    = relX / TrackArea.AbsoluteSize.X
                local v    = math.floor(min + p * (max - min) + 0.5)
                value = math.clamp(v, min, max)
                local np = (value - min) / (max - min)
                Fill.Size     = UDim2.new(np, 0, 1, 0)
                Knob.Position = UDim2.new(np, -5, 0.5, -5)
                ValLbl.Text   = tostring(value) .. suffix
                pcall(callback, value)
            end

            local InputArea = CreateInstance("TextButton", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 5,
                Parent          = TrackArea,
            })
            InputArea.MouseButton1Down:Connect(function(x, _)
                dragging = true
                Update(x)
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            return {
                SetValue = function(_, v)
                    value = math.clamp(v, min, max)
                    local np = (value - min) / (max - min)
                    Tween(Fill, { Size = UDim2.new(np, 0, 1, 0) })
                    Tween(Knob, { Position = UDim2.new(np, -5, 0.5, -5) })
                    ValLbl.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end,
                GetValue = function() return value end,
                Destroy  = function() Frame:Destroy() end,
            }
        end

        -- ── DROPDOWN ──────────────────────────────
        function Tab:AddDropdown(dropConfig)
            dropConfig = dropConfig or {}
            local dropName  = dropConfig.Name     or "Dropdown"
            local options   = dropConfig.Options  or {}
            local default   = dropConfig.Default  or (options[1] or "None")
            local callback  = dropConfig.Callback or function() end

            local selected  = default
            local isOpen    = false

            local Wrapper = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                LayoutOrder     = NextOrder(),
                ClipsDescendants= false,
                ZIndex          = 5,
                Parent          = TabContent,
            })

            local Frame = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 34),
                BackgroundColor3= Theme.ElementBg,
                BorderSizePixel = 0,
                ZIndex          = 5,
                Parent          = Wrapper,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            local Lbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(1, -80, 1, 0),
                Position        = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text            = dropName,
                TextColor3      = Theme.ElementText,
                Font            = Theme.FontMed,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 6,
                Parent          = Frame,
            })
            local SelLbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(0, 90, 1, 0),
                Position        = UDim2.new(1, -100, 0, 0),
                BackgroundTransparency = 1,
                Text            = selected,
                TextColor3      = Theme.BorderAccent,
                Font            = Theme.FontLight,
                TextSize        = 11,
                TextXAlignment  = Enum.TextXAlignment.Right,
                ZIndex          = 6,
                Parent          = Frame,
            })
            local ChevronLbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(0, 16, 1, 0),
                Position        = UDim2.new(1, -20, 0, 0),
                BackgroundTransparency = 1,
                Text            = "▾",
                TextColor3      = Theme.ElementTextDim,
                Font            = Theme.Font,
                TextSize        = 12,
                ZIndex          = 6,
                Parent          = Frame,
            })

            -- Dropdown panel
            local Panel = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, #options * 28 + 4),
                Position        = UDim2.new(0, 0, 0, 36),
                BackgroundColor3= Theme.DropdownBg,
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = 20,
                Parent          = Wrapper,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Panel })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Panel })
            CreateInstance("UIListLayout", {
                SortOrder   = Enum.SortOrder.LayoutOrder,
                Padding     = UDim.new(0, 0),
                Parent      = Panel,
            })
            CreateInstance("UIPadding", {
                PaddingTop  = UDim.new(0, 2),
                PaddingBottom= UDim.new(0, 2),
                Parent      = Panel,
            })

            local function BuildItems()
                for _, child in pairs(Panel:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local Item = CreateInstance("TextButton", {
                        Size            = UDim2.new(1, -4, 0, 26),
                        BackgroundColor3= opt == selected and Theme.DropdownSelected or Theme.DropdownItem,
                        Text            = "",
                        BorderSizePixel = 0,
                        ZIndex          = 21,
                        LayoutOrder     = i,
                        Parent          = Panel,
                    })
                    CreateInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Item })
                    CreateInstance("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = Item })
                    CreateInstance("TextLabel", {
                        Size            = UDim2.new(1, -16, 1, 0),
                        Position        = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1,
                        Text            = opt,
                        TextColor3      = opt == selected and Color3.fromRGB(255,255,255) or Theme.ElementText,
                        Font            = Theme.FontMed,
                        TextSize        = 11,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        ZIndex          = 22,
                        Parent          = Item,
                    })
                    Item.MouseEnter:Connect(function()
                        if opt ~= selected then
                            Tween(Item, { BackgroundColor3 = Theme.DropdownHover })
                        end
                    end)
                    Item.MouseLeave:Connect(function()
                        if opt ~= selected then
                            Tween(Item, { BackgroundColor3 = Theme.DropdownItem })
                        end
                    end)
                    Item.MouseButton1Click:Connect(function()
                        selected = opt
                        SelLbl.Text = selected
                        BuildItems()
                        isOpen = false
                        Panel.Visible = false
                        Tween(ChevronLbl, { TextColor3 = Theme.ElementTextDim })
                        Wrapper.Size = UDim2.new(1, 0, 0, 34)
                        pcall(callback, selected)
                    end)
                end
            end
            BuildItems()

            local ToggleBtn = CreateInstance("TextButton", {
                Size            = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 7,
                Parent          = Frame,
            })
            ToggleBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Panel.Visible = isOpen
                if isOpen then
                    Wrapper.Size = UDim2.new(1, 0, 0, 34 + Panel.AbsoluteSize.Y + 4)
                    Tween(ChevronLbl, { TextColor3 = Theme.BorderAccent })
                else
                    Wrapper.Size = UDim2.new(1, 0, 0, 34)
                    Tween(ChevronLbl, { TextColor3 = Theme.ElementTextDim })
                end
            end)
            ToggleBtn.MouseEnter:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementHover })
            end)
            ToggleBtn.MouseLeave:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementBg })
            end)

            return {
                SetOptions = function(_, opts)
                    options = opts
                    if not table.find(options, selected) then
                        selected = options[1] or "None"
                        SelLbl.Text = selected
                    end
                    Panel.Size = UDim2.new(1, 0, 0, #options * 28 + 4)
                    BuildItems()
                end,
                GetValue   = function() return selected end,
                SetValue   = function(_, v)
                    if table.find(options, v) then
                        selected = v
                        SelLbl.Text = selected
                        BuildItems()
                        pcall(callback, selected)
                    end
                end,
                Destroy    = function() Wrapper:Destroy() end,
            }
        end

        -- ── COLOR PICKER ──────────────────────────
        function Tab:AddColorPicker(cpConfig)
            cpConfig  = cpConfig  or {}
            local cpName    = cpConfig.Name     or "Color"
            local default   = cpConfig.Default  or Color3.fromRGB(220, 60, 60)
            local callback  = cpConfig.Callback or function() end

            local currentColor = default
            local isOpen       = false

            -- Outer wrapper (expands when open)
            local Wrapper = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                LayoutOrder     = NextOrder(),
                ClipsDescendants= false,
                ZIndex          = 8,
                Parent          = TabContent,
            })

            local Frame = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, 34),
                BackgroundColor3= Theme.ElementBg,
                BorderSizePixel = 0,
                ZIndex          = 8,
                Parent          = Wrapper,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            local Lbl = CreateInstance("TextLabel", {
                Size            = UDim2.new(1, -60, 1, 0),
                Position        = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text            = cpName,
                TextColor3      = Theme.ElementText,
                Font            = Theme.FontMed,
                TextSize        = 12,
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 9,
                Parent          = Frame,
            })

            local Preview = CreateInstance("Frame", {
                Size            = UDim2.new(0, 22, 0, 16),
                Position        = UDim2.new(1, -32, 0.5, -8),
                BackgroundColor3= currentColor,
                BorderSizePixel = 0,
                ZIndex          = 9,
                Parent          = Frame,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Preview })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Preview })

            -- Color panel
            local PanelHeight = 160
            local Panel = CreateInstance("Frame", {
                Size            = UDim2.new(1, 0, 0, PanelHeight),
                Position        = UDim2.new(0, 0, 0, 36),
                BackgroundColor3= Theme.DropdownBg,
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = 18,
                Parent          = Wrapper,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Panel })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Panel })

            -- SV square (saturation/value)
            local SVFrame = CreateInstance("Frame", {
                Size            = UDim2.new(0, 120, 0, 100),
                Position        = UDim2.new(0, 8, 0, 8),
                BackgroundColor3= Color3.fromHSV(0, 1, 1),
                BorderSizePixel = 0,
                ZIndex          = 19,
                ClipsDescendants= true,
                Parent          = Panel,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SVFrame })
            -- White gradient (left to right)
            local SVWhite = CreateInstance("UIGradient", {
                Color       = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                }),
                Transparency= NumberSequence.new({ NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1) }),
                Rotation    = 0,
                Parent      = SVFrame,
            })
            -- Black gradient (top to bottom)
            local SVBlack = CreateInstance("Frame", {
                Size            = UDim2.new(1,0,1,0),
                BackgroundColor3= Color3.new(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 20,
                Parent          = SVFrame,
            })
            CreateInstance("UIGradient", {
                Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) }),
                Rotation     = 90,
                Parent       = SVBlack,
            })
            local SVKnob = CreateInstance("Frame", {
                Size            = UDim2.new(0, 8, 0, 8),
                Position        = UDim2.new(1, -4, 0, -4),
                BackgroundColor3= Color3.new(1,1,1),
                BorderSizePixel = 0,
                ZIndex          = 22,
                Parent          = SVFrame,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(1,0), Parent = SVKnob })
            CreateInstance("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1, Parent = SVKnob })

            -- Hue bar
            local HueBar = CreateInstance("Frame", {
                Size            = UDim2.new(0, 12, 0, 100),
                Position        = UDim2.new(0, 136, 0, 8),
                BackgroundColor3= Color3.new(1,1,1),
                BorderSizePixel = 0,
                ZIndex          = 19,
                ClipsDescendants= true,
                Parent          = Panel,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0,3), Parent = HueBar })
            local hueColors = {}
            local hueSteps  = 6
            for i = 0, hueSteps do
                table.insert(hueColors, ColorSequenceKeypoint.new(i/hueSteps, Color3.fromHSV(i/hueSteps, 1, 1)))
            end
            CreateInstance("UIGradient", {
                Color    = ColorSequence.new(hueColors),
                Rotation = 90,
                Parent   = HueBar,
            })
            local HueKnob = CreateInstance("Frame", {
                Size            = UDim2.new(1, 4, 0, 4),
                Position        = UDim2.new(0, -2, 0, -2),
                BackgroundColor3= Color3.new(1,1,1),
                BorderSizePixel = 0,
                ZIndex          = 21,
                Parent          = HueBar,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0,2), Parent = HueKnob })
            CreateInstance("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1, Parent = HueKnob })

            -- Hex input
            local HexInput = CreateInstance("TextBox", {
                Size            = UDim2.new(0, 80, 0, 22),
                Position        = UDim2.new(0, 8, 0, 116),
                BackgroundColor3= Theme.ElementBg,
                Text            = string.format("%02X%02X%02X",
                    math.floor(currentColor.R*255+.5),
                    math.floor(currentColor.G*255+.5),
                    math.floor(currentColor.B*255+.5)
                ),
                TextColor3      = Theme.ElementText,
                Font            = Theme.FontLight,
                TextSize        = 11,
                ClearTextOnFocus= false,
                ZIndex          = 19,
                PlaceholderText = "RRGGBB",
                Parent          = Panel,
            })
            CreateInstance("UICorner", { CornerRadius = UDim.new(0,3), Parent = HexInput })
            CreateInstance("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = HexInput })
            CreateInstance("UIPadding", { PaddingLeft = UDim.new(0,6), Parent = HexInput })

            local h, s, v = Color3.toHSV(currentColor)

            local function ApplyColor()
                currentColor = Color3.fromHSV(h, s, v)
                Preview.BackgroundColor3 = currentColor
                SVFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                HexInput.Text = string.format("%02X%02X%02X",
                    math.floor(currentColor.R*255+.5),
                    math.floor(currentColor.G*255+.5),
                    math.floor(currentColor.B*255+.5)
                )
                pcall(callback, currentColor)
            end

            local draggingSV, draggingH = false, false

            -- SV drag
            local SVBtn = CreateInstance("TextButton", {
                Size  = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=23, Parent=SVFrame
            })
            SVBtn.MouseButton1Down:Connect(function(x, y)
                draggingSV = true
                local relX = math.clamp(x - SVFrame.AbsolutePosition.X, 0, SVFrame.AbsoluteSize.X)
                local relY = math.clamp(y - SVFrame.AbsolutePosition.Y, 0, SVFrame.AbsoluteSize.Y)
                s = relX / SVFrame.AbsoluteSize.X
                v = 1 - relY / SVFrame.AbsoluteSize.Y
                SVKnob.Position = UDim2.new(s, -4, 1-v, -4)
                ApplyColor()
            end)

            -- Hue drag
            local HueBtn = CreateInstance("TextButton", {
                Size  = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=23, Parent=HueBar
            })
            HueBtn.MouseButton1Down:Connect(function(_, y)
                draggingH = true
                local relY = math.clamp(y - HueBar.AbsolutePosition.Y, 0, HueBar.AbsoluteSize.Y)
                h = relY / HueBar.AbsoluteSize.Y
                HueKnob.Position = UDim2.new(0, -2, h, -2)
                ApplyColor()
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingSV then
                        local relX = math.clamp(input.Position.X - SVFrame.AbsolutePosition.X, 0, SVFrame.AbsoluteSize.X)
                        local relY = math.clamp(input.Position.Y - SVFrame.AbsolutePosition.Y, 0, SVFrame.AbsoluteSize.Y)
                        s = relX / SVFrame.AbsoluteSize.X
                        v = 1 - relY / SVFrame.AbsoluteSize.Y
                        SVKnob.Position = UDim2.new(s, -4, 1-v, -4)
                        ApplyColor()
                    elseif draggingH then
                        local relY = math.clamp(input.Position.Y - HueBar.AbsolutePosition.Y, 0, HueBar.AbsoluteSize.Y)
                        h = relY / HueBar.AbsoluteSize.Y
                        HueKnob.Position = UDim2.new(0, -2, h, -2)
                        ApplyColor()
                    end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV = false
                    draggingH  = false
                end
            end)

            HexInput.FocusLost:Connect(function()
                local hex = HexInput.Text:gsub("#",""):sub(1,6)
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g and b then
                        currentColor = Color3.fromRGB(r,g,b)
                        h,s,v = Color3.toHSV(currentColor)
                        SVKnob.Position = UDim2.new(s,-4,1-v,-4)
                        HueKnob.Position= UDim2.new(0,-2,h,-2)
                        SVFrame.BackgroundColor3 = Color3.fromHSV(h,1,1)
                        Preview.BackgroundColor3 = currentColor
                        pcall(callback, currentColor)
                    end
                end
            end)

            -- Toggle open
            local OpenBtn = CreateInstance("TextButton", {
                Size  = UDim2.new(1,0,0,34), BackgroundTransparency=1, Text="", ZIndex=10, Parent=Frame
            })
            OpenBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Panel.Visible = isOpen
                Wrapper.Size = UDim2.new(1, 0, 0, isOpen and 34 + PanelHeight + 4 or 34)
            end)
            OpenBtn.MouseEnter:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementHover })
            end)
            OpenBtn.MouseLeave:Connect(function()
                Tween(Frame, { BackgroundColor3 = Theme.ElementBg })
            end)

            return {
                GetValue = function() return currentColor end,
                SetValue = function(_, c)
                    currentColor = c
                    h, s, v = Color3.toHSV(c)
                    SVKnob.Position  = UDim2.new(s,-4,1-v,-4)
                    HueKnob.Position = UDim2.new(0,-2,h,-2)
                    SVFrame.BackgroundColor3 = Color3.fromHSV(h,1,1)
                    Preview.BackgroundColor3 = c
                    HexInput.Text = string.format("%02X%02X%02X",
                        math.floor(c.R*255+.5), math.floor(c.G*255+.5), math.floor(c.B*255+.5))
                    pcall(callback, c)
                end,
                Destroy  = function() Wrapper:Destroy() end,
            }
        end

        return Tab
    end

    -- Toggle visibility with keybind
    function Window:SetKeybind(key)
        UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == key then
                Root.Visible = not Root.Visible
            end
        end)
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

--[[
═══════════════════════════════════════════════════════
    USAGE EXAMPLE
═══════════════════════════════════════════════════════

local OnetapUI = loadstring(game:HttpGet("YOUR_RAW_PASTEBIN_OR_GITHUB_URL"))()

local Window = OnetapUI:CreateWindow({
    Title    = "onetap",
    Subtitle = "v1.0 | lua",
    Width    = 560,
    Height   = 420,
})

Window:SetKeybind(Enum.KeyCode.RightControl) -- toggle visibility

-- AIMBOT TAB
local AimbotTab = Window:CreateTab({ Name = "Aimbot", Icon = "⊕" })

AimbotTab:AddLabel("Aim Settings")
AimbotTab:AddSeparator("GENERAL")

AimbotTab:AddToggle({
    Name     = "Enable Aimbot",
    Default  = false,
    Callback = function(val)
        print("Aimbot:", val)
    end,
})

AimbotTab:AddSlider({
    Name     = "FOV",
    Min      = 1,
    Max      = 360,
    Default  = 90,
    Suffix   = "°",
    Callback = function(val)
        print("FOV:", val)
    end,
})

AimbotTab:AddSlider({
    Name     = "Smoothing",
    Min      = 0,
    Max      = 100,
    Default  = 30,
    Suffix   = "%",
})

AimbotTab:AddDropdown({
    Name     = "Target Bone",
    Options  = { "Head", "Neck", "Chest", "Pelvis" },
    Default  = "Head",
    Callback = function(val)
        print("Bone:", val)
    end,
})

AimbotTab:AddSeparator()

AimbotTab:AddButton({
    Name     = "Reset Settings",
    Callback = function()
        print("Reset!")
    end,
})

-- VISUALS TAB
local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "◈" })

VisualsTab:AddToggle({ Name = "ESP Boxes",     Default = true  })
VisualsTab:AddToggle({ Name = "ESP Tracers",   Default = false })
VisualsTab:AddToggle({ Name = "ESP Healthbar", Default = true  })

VisualsTab:AddSeparator("COLORS")

VisualsTab:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(220, 60, 60),
    Callback = function(color)
        print("Color:", color)
    end,
})

-- MISC TAB
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "≡" })

MiscTab:AddLabel("Miscellaneous options")
MiscTab:AddToggle({ Name = "Fly", Default = false })
MiscTab:AddToggle({ Name = "Speed Hack", Default = false })
MiscTab:AddSlider({ Name = "Walk Speed", Min = 16, Max = 200, Default = 16, Suffix = " ws" })
MiscTab:AddButton({ Name = "Rejoin Server", Callback = function() end })

═══════════════════════════════════════════════════════
--]]

return OnetapUI
