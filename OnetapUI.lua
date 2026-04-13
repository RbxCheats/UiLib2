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
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════
local Theme = {
    Background      = Color3.fromRGB(18, 18, 20),
    BackgroundAlt   = Color3.fromRGB(23, 23, 26),
    Border          = Color3.fromRGB(40, 40, 46),
    BorderAccent    = Color3.fromRGB(220, 60, 60),

    Header          = Color3.fromRGB(13, 13, 15),
    HeaderText      = Color3.fromRGB(235, 235, 235),
    HeaderSub       = Color3.fromRGB(120, 120, 132),

    TabActive       = Color3.fromRGB(220, 60, 60),
    TabInactive     = Color3.fromRGB(30, 30, 34),
    TabHover        = Color3.fromRGB(36, 36, 41),
    TabText         = Color3.fromRGB(180, 180, 192),
    TabTextActive   = Color3.fromRGB(255, 255, 255),

    ElementBg       = Color3.fromRGB(24, 24, 28),
    ElementHover    = Color3.fromRGB(30, 30, 35),
    ElementText     = Color3.fromRGB(205, 205, 215),
    ElementTextDim  = Color3.fromRGB(95, 95, 110),

    ToggleOn        = Color3.fromRGB(220, 60, 60),
    ToggleOff       = Color3.fromRGB(48, 48, 56),
    ToggleKnob      = Color3.fromRGB(238, 238, 245),

    SliderTrack     = Color3.fromRGB(38, 38, 46),
    SliderFill      = Color3.fromRGB(220, 60, 60),
    SliderKnob      = Color3.fromRGB(238, 238, 245),

    DropdownBg      = Color3.fromRGB(19, 19, 22),
    DropdownItem    = Color3.fromRGB(24, 24, 28),
    DropdownHover   = Color3.fromRGB(33, 33, 38),
    DropdownSelected= Color3.fromRGB(220, 60, 60),

    Separator       = Color3.fromRGB(38, 38, 46),
    SeparatorAccent = Color3.fromRGB(220, 60, 60),

    ButtonText      = Color3.fromRGB(205, 205, 215),

    ScrollBar       = Color3.fromRGB(48, 48, 58),

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

local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
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

    local ScreenGui = New("ScreenGui", {
        Name           = "OnetapUI_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 100,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Root
    local Root = New("Frame", {
        Name             = "Root",
        Size             = UDim2.new(0, width, 0, height),
        Position         = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        Parent           = ScreenGui,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Root })
    New("UIStroke", { Color = Theme.Border, Thickness = 1.5, Parent = Root })

    -- Top red accent line
    local AccentLine = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.BorderAccent,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = Root,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = AccentLine })

    -- Header
    local Header = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Root,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Header })
    -- Square off the bottom corners of the header
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 8),
        Position         = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Header,
    })

    New("TextLabel", {
        Size                  = UDim2.new(0, 300, 1, 0),
        Position              = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency= 1,
        Text                  = title,
        TextColor3            = Theme.HeaderText,
        Font                  = Theme.Font,
        TextSize              = 15,
        TextXAlignment        = Enum.TextXAlignment.Left,
        ZIndex                = 3,
        Parent                = Header,
    })
    New("TextLabel", {
        Size                  = UDim2.new(0, 200, 1, 0),
        Position              = UDim2.new(0, 76, 0, 0),
        BackgroundTransparency= 1,
        Text                  = subtitle,
        TextColor3            = Theme.HeaderSub,
        Font                  = Theme.FontLight,
        TextSize              = 11,
        TextXAlignment        = Enum.TextXAlignment.Left,
        ZIndex                = 3,
        Parent                = Header,
    })

    -- Close button
    local CloseBtn = New("TextButton", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(38, 38, 44),
        Text             = "✕",
        TextColor3       = Color3.fromRGB(150, 150, 162),
        Font             = Theme.Font,
        TextSize         = 11,
        ZIndex           = 4,
        Parent           = Header,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CloseBtn })
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Theme.BorderAccent, TextColor3 = Color3.fromRGB(255,255,255) })
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Color3.fromRGB(38,38,44), TextColor3 = Color3.fromRGB(150,150,162) })
    end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Tab sidebar
    local TabBar = New("Frame", {
        Size             = UDim2.new(0, 118, 1, -46),
        Position         = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = Root,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBar })
    -- Square off top-right and right side
    New("Frame", {
        Size             = UDim2.new(0, 8, 1, 0),
        Position         = UDim2.new(1, -8, 0, 0),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel  = 0,
        Parent           = TabBar,
    })
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 8),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel  = 0,
        Parent           = TabBar,
    })

    -- Vertical divider
    New("Frame", {
        Size             = UDim2.new(0, 1, 1, -46),
        Position         = UDim2.new(0, 118, 0, 46),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = Root,
    })

    local TabList = New("Frame", {
        Size              = UDim2.new(1, 0, 0, 0),
        AutomaticSize     = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent            = TabBar,
    })
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 2),
        Parent    = TabList,
    })
    New("UIPadding", {
        PaddingTop   = UDim.new(0, 8),
        PaddingLeft  = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent       = TabList,
    })

    -- Content area
    local ContentArea = New("Frame", {
        Size             = UDim2.new(1, -120, 1, -46),
        Position         = UDim2.new(0, 120, 0, 46),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Root,
    })

    MakeDraggable(Root, Header)

    local Window = { _tabs = {}, _activeTab = nil, _gui = ScreenGui, _root = Root }

    -- ── CreateTab ──────────────────────────────────────────
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or ""

        local TabBtn = New("TextButton", {
            Size             = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.TabInactive,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 3,
            LayoutOrder      = #self._tabs + 1,
            Parent           = TabList,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabBtn })

        local Indicator = New("Frame", {
            Size                  = UDim2.new(0, 3, 0.55, 0),
            Position              = UDim2.new(0, 0, 0.225, 0),
            BackgroundColor3      = Theme.TabActive,
            BorderSizePixel       = 0,
            BackgroundTransparency= 1,
            ZIndex                = 4,
            Parent                = TabBtn,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Indicator })

        New("TextLabel", {
            Size                  = UDim2.new(1, -10, 1, 0),
            Position              = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency= 1,
            Text                  = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
            TextColor3            = Theme.TabText,
            Font                  = Theme.FontMed,
            TextSize              = 12,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 4,
            Name                  = "TabLabel",
            Parent                = TabBtn,
        })

        -- Scrollable content frame for this tab
        local TabContent = New("ScrollingFrame", {
            Name                 = tabName .. "_Content",
            Size                 = UDim2.new(1, -6, 1, -6),
            Position             = UDim2.new(0, 3, 0, 3),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 3,
            ScrollBarImageColor3 = Theme.ScrollBar,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible              = false,
            ZIndex               = 2,
            Parent               = ContentArea,
        })
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 3),
            Parent    = TabContent,
        })
        New("UIPadding", {
            PaddingTop    = UDim.new(0, 5),
            PaddingLeft   = UDim.new(0, 5),
            PaddingRight  = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 5),
            Parent        = TabContent,
        })

        local TabLabelObj = TabBtn:FindFirstChild("TabLabel")

        local function SetActive(active)
            if active then
                Tween(TabBtn,     { BackgroundColor3 = Color3.fromRGB(27, 27, 31) })
                Tween(TabLabelObj,{ TextColor3 = Theme.TabTextActive })
                Tween(Indicator,  { BackgroundTransparency = 0 })
                TabContent.Visible = true
            else
                Tween(TabBtn,     { BackgroundColor3 = Theme.TabInactive })
                Tween(TabLabelObj,{ TextColor3 = Theme.TabText })
                Tween(Indicator,  { BackgroundTransparency = 1 })
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
            for name, tab in pairs(self._tabs) do
                if name == Window._activeTab then tab._setActive(false) end
            end
            Window._activeTab = tabName
            SetActive(true)
        end)

        local Tab = { _name = tabName, _content = TabContent, _setActive = SetActive, _order = 0 }
        self._tabs[tabName] = Tab

        if not self._activeTab then
            self._activeTab = tabName
            SetActive(true)
        end

        local function NextOrder()
            Tab._order = Tab._order + 1
            return Tab._order
        end

        -- ── LABEL ─────────────────────────────────────────
        function Tab:AddLabel(text)
            local Frame = New("Frame", {
                Size                  = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency= 1,
                LayoutOrder           = NextOrder(),
                Parent                = TabContent,
            })
            local Lbl = New("TextLabel", {
                Size                  = UDim2.new(1, -4, 1, 0),
                Position              = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency= 1,
                Text                  = text,
                TextColor3            = Theme.ElementTextDim,
                Font                  = Theme.FontLight,
                TextSize              = 11,
                TextXAlignment        = Enum.TextXAlignment.Left,
                Parent                = Frame,
            })
            return {
                SetText = function(_, t) Lbl.Text = t end,
                Destroy = function() Frame:Destroy() end,
            }
        end

        -- ── SEPARATOR ─────────────────────────────────────
        -- FIX: Label background was causing a visible colored outline box.
        -- Set BackgroundTransparency = 1 on the label so it's invisible.
        function Tab:AddSeparator(labelText)
            local Frame = New("Frame", {
                Size                  = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency= 1,
                LayoutOrder           = NextOrder(),
                Parent                = TabContent,
            })

            -- Red dot
            local AccentDot = New("Frame", {
                Size             = UDim2.new(0, 4, 0, 4),
                Position         = UDim2.new(0, 2, 0.5, -2),
                BackgroundColor3 = Theme.SeparatorAccent,
                BorderSizePixel  = 0,
                Parent           = Frame,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = AccentDot })

            if labelText and labelText ~= "" then
                -- Label with TRANSPARENT background — no border/outline artifact
                New("TextLabel", {
                    Size                  = UDim2.new(0, 0, 1, 0),
                    AutomaticSize         = Enum.AutomaticSize.X,
                    Position              = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency= 1,   -- was BackgroundColor3 = Theme.Background which caused outline
                    Text                  = labelText,
                    TextColor3            = Theme.ElementTextDim,
                    Font                  = Theme.FontLight,
                    TextSize              = 10,
                    TextXAlignment        = Enum.TextXAlignment.Left,
                    ZIndex                = 2,
                    Parent                = Frame,
                })
                -- Line after the label
                New("Frame", {
                    Size             = UDim2.new(1, -90, 0, 1),
                    Position         = UDim2.new(0, 80, 0.5, 0),
                    BackgroundColor3 = Theme.Separator,
                    BorderSizePixel  = 0,
                    Parent           = Frame,
                })
            else
                -- Full-width line when no label
                New("Frame", {
                    Size             = UDim2.new(1, -10, 0, 1),
                    Position         = UDim2.new(0, 10, 0.5, 0),
                    BackgroundColor3 = Theme.Separator,
                    BorderSizePixel  = 0,
                    Parent           = Frame,
                })
            end

            return { Destroy = function() Frame:Destroy() end }
        end

        -- ── BUTTON ────────────────────────────────────────
        function Tab:AddButton(buttonConfig)
            buttonConfig = buttonConfig or {}
            local btnText  = buttonConfig.Name     or "Button"
            local callback = buttonConfig.Callback or function() end

            local Frame = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Theme.ElementBg,
                BorderSizePixel  = 0,
                LayoutOrder      = NextOrder(),
                Parent           = TabContent,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            local Btn = New("TextButton", {
                Size                  = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency= 1,
                Text                  = "",
                ZIndex                = 2,
                Parent                = Frame,
            })
            local Lbl = New("TextLabel", {
                Size                  = UDim2.new(1, -40, 1, 0),
                Position              = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency= 1,
                Text                  = btnText,
                TextColor3            = Theme.ButtonText,
                Font                  = Theme.FontMed,
                TextSize              = 12,
                TextXAlignment        = Enum.TextXAlignment.Left,
                ZIndex                = 3,
                Parent                = Frame,
            })
            local Arrow = New("TextLabel", {
                Size                  = UDim2.new(0, 20, 1, 0),
                Position              = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency= 1,
                Text                  = "›",
                TextColor3            = Theme.ElementTextDim,
                Font                  = Theme.Font,
                TextSize              = 16,
                ZIndex                = 3,
                Parent                = Frame,
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
                Tween(Frame, { BackgroundColor3 = Theme.BorderAccent }, 0.07)
                task.delay(0.08, function()
                    Tween(Frame, { BackgroundColor3 = Theme.ElementHover }, 0.12)
                end)
                pcall(callback)
            end)

            return {
                SetText = function(_, t) Lbl.Text = t end,
                Destroy = function() Frame:Destroy() end,
            }
        end

        -- ── TOGGLE ────────────────────────────────────────
        function Tab:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local toggleName = toggleConfig.Name     or "Toggle"
            local toggled    = toggleConfig.Default  or false
            local callback   = toggleConfig.Callback or function() end

            local Frame = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Theme.ElementBg,
                BorderSizePixel  = 0,
                LayoutOrder      = NextOrder(),
                Parent           = TabContent,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            New("TextLabel", {
                Size                  = UDim2.new(1, -60, 1, 0),
                Position              = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency= 1,
                Text                  = toggleName,
                TextColor3            = Theme.ElementText,
                Font                  = Theme.FontMed,
                TextSize              = 12,
                TextXAlignment        = Enum.TextXAlignment.Left,
                ZIndex                = 2,
                Parent                = Frame,
            })

            local Track = New("Frame", {
                Size             = UDim2.new(0, 34, 0, 16),
                Position         = UDim2.new(1, -44, 0.5, -8),
                BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = Frame,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

            local Knob = New("Frame", {
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = toggled
                    and UDim2.new(1, -13, 0.5, -5)
                    or  UDim2.new(0,  3,  0.5, -5),
                BackgroundColor3 = Theme.ToggleKnob,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = Track,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

            local Btn = New("TextButton", {
                Size                  = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency= 1,
                Text                  = "",
                ZIndex                = 4,
                Parent                = Frame,
            })

            local function UpdateToggle()
                if toggled then
                    Tween(Track, { BackgroundColor3 = Theme.ToggleOn })
                    Tween(Knob,  { Position = UDim2.new(1, -13, 0.5, -5) })
                else
                    Tween(Track, { BackgroundColor3 = Theme.ToggleOff })
                    Tween(Knob,  { Position = UDim2.new(0, 3, 0.5, -5) })
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
                SetValue = function(_, val) toggled = val; UpdateToggle() end,
                GetValue = function() return toggled end,
                Destroy  = function() Frame:Destroy() end,
            }
        end

        -- ── SLIDER ────────────────────────────────────────
        function Tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local sliderName = sliderConfig.Name     or "Slider"
            local minV       = sliderConfig.Min      or 0
            local maxV       = sliderConfig.Max      or 100
            local suffix     = sliderConfig.Suffix   or ""
            local callback   = sliderConfig.Callback or function() end
            local value      = math.clamp(sliderConfig.Default or minV, minV, maxV)

            local Frame = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.ElementBg,
                BorderSizePixel  = 0,
                LayoutOrder      = NextOrder(),
                Parent           = TabContent,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            -- Top row: name + value
            New("TextLabel", {
                Size                  = UDim2.new(1, -70, 0, 22),
                Position              = UDim2.new(0, 10, 0, 2),
                BackgroundTransparency= 1,
                Text                  = sliderName,
                TextColor3            = Theme.ElementText,
                Font                  = Theme.FontMed,
                TextSize              = 12,
                TextXAlignment        = Enum.TextXAlignment.Left,
                ZIndex                = 2,
                Parent                = Frame,
            })
            local ValLbl = New("TextLabel", {
                Size                  = UDim2.new(0, 60, 0, 22),
                Position              = UDim2.new(1, -64, 0, 2),
                BackgroundTransparency= 1,
                Text                  = tostring(value) .. suffix,
                TextColor3            = Theme.BorderAccent,
                Font                  = Theme.Font,
                TextSize              = 11,
                TextXAlignment        = Enum.TextXAlignment.Right,
                ZIndex                = 2,
                Parent                = Frame,
            })

            -- Track
            local TrackHolder = New("Frame", {
                Size                  = UDim2.new(1, -14, 0, 16),
                Position              = UDim2.new(0, 7, 0, 24),
                BackgroundTransparency= 1,
                ZIndex                = 2,
                Parent                = Frame,
            })
            local Track = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 4),
                Position         = UDim2.new(0, 0, 0.5, -2),
                BackgroundColor3 = Theme.SliderTrack,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = TrackHolder,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

            local pct = (value - minV) / (maxV - minV)
            local Fill = New("Frame", {
                Size             = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = Track,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

            local Knob = New("Frame", {
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = UDim2.new(pct, -5, 0.5, -5),
                BackgroundColor3 = Theme.SliderKnob,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = Track,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

            local dragging = false
            local function UpdateSlider(inputX)
                local relX = math.clamp(inputX - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                local p    = relX / Track.AbsoluteSize.X
                local v    = math.floor(minV + p * (maxV - minV) + 0.5)
                value = math.clamp(v, minV, maxV)
                local np  = (value - minV) / (maxV - minV)
                Fill.Size     = UDim2.new(np, 0, 1, 0)
                Knob.Position = UDim2.new(np, -5, 0.5, -5)
                ValLbl.Text   = tostring(value) .. suffix
                pcall(callback, value)
            end

            local InputBtn = New("TextButton", {
                Size                  = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency= 1,
                Text                  = "",
                ZIndex                = 5,
                Parent                = TrackHolder,
            })
            InputBtn.MouseButton1Down:Connect(function(x, _)
                dragging = true
                UpdateSlider(x)
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            return {
                SetValue = function(_, v)
                    value = math.clamp(v, minV, maxV)
                    local np = (value - minV) / (maxV - minV)
                    Tween(Fill, { Size = UDim2.new(np, 0, 1, 0) })
                    Tween(Knob, { Position = UDim2.new(np, -5, 0.5, -5) })
                    ValLbl.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end,
                GetValue = function() return value end,
                Destroy  = function() Frame:Destroy() end,
            }
        end

        -- ── DROPDOWN ──────────────────────────────────────
        function Tab:AddDropdown(dropConfig)
            dropConfig = dropConfig or {}
            local dropName = dropConfig.Name     or "Dropdown"
            local options  = dropConfig.Options  or {}
            local callback = dropConfig.Callback or function() end
            local selected = dropConfig.Default  or (options[1] or "None")
            local isOpen   = false

            local Wrapper = New("Frame", {
                Size                  = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency= 1,
                LayoutOrder           = NextOrder(),
                ClipsDescendants      = false,
                ZIndex                = 5,
                Parent                = TabContent,
            })

            local Frame = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Theme.ElementBg,
                BorderSizePixel  = 0,
                ZIndex           = 5,
                Parent           = Wrapper,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            New("TextLabel", {
                Size                  = UDim2.new(1, -110, 1, 0),
                Position              = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency= 1,
                Text                  = dropName,
                TextColor3            = Theme.ElementText,
                Font                  = Theme.FontMed,
                TextSize              = 12,
                TextXAlignment        = Enum.TextXAlignment.Left,
                ZIndex                = 6,
                Parent                = Frame,
            })
            local SelLbl = New("TextLabel", {
                Size                  = UDim2.new(0, 90, 1, 0),
                Position              = UDim2.new(1, -104, 0, 0),
                BackgroundTransparency= 1,
                Text                  = selected,
                TextColor3            = Theme.BorderAccent,
                Font                  = Theme.FontLight,
                TextSize              = 11,
                TextXAlignment        = Enum.TextXAlignment.Right,
                ZIndex                = 6,
                Parent                = Frame,
            })
            local Chevron = New("TextLabel", {
                Size                  = UDim2.new(0, 14, 1, 0),
                Position              = UDim2.new(1, -18, 0, 0),
                BackgroundTransparency= 1,
                Text                  = "▾",
                TextColor3            = Theme.ElementTextDim,
                Font                  = Theme.Font,
                TextSize              = 11,
                ZIndex                = 6,
                Parent                = Frame,
            })

            local Panel = New("Frame", {
                Size             = UDim2.new(1, 0, 0, #options * 26 + 4),
                Position         = UDim2.new(0, 0, 0, 34),
                BackgroundColor3 = Theme.DropdownBg,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 20,
                Parent           = Wrapper,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Panel })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Panel })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 0),
                Parent    = Panel,
            })
            New("UIPadding", {
                PaddingTop    = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft   = UDim.new(0, 2),
                PaddingRight  = UDim.new(0, 2),
                Parent        = Panel,
            })

            local function RebuildItems()
                for _, c in pairs(Panel:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local isSelected = opt == selected
                    local Item = New("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = isSelected and Theme.DropdownSelected or Theme.DropdownItem,
                        Text             = "",
                        BorderSizePixel  = 0,
                        ZIndex           = 21,
                        LayoutOrder      = i,
                        Parent           = Panel,
                    })
                    New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Item })
                    New("TextLabel", {
                        Size                  = UDim2.new(1, -12, 1, 0),
                        Position              = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency= 1,
                        Text                  = opt,
                        TextColor3            = isSelected and Color3.fromRGB(255,255,255) or Theme.ElementText,
                        Font                  = Theme.FontMed,
                        TextSize              = 11,
                        TextXAlignment        = Enum.TextXAlignment.Left,
                        ZIndex                = 22,
                        Parent                = Item,
                    })
                    Item.MouseEnter:Connect(function()
                        if not isSelected then Tween(Item, { BackgroundColor3 = Theme.DropdownHover }) end
                    end)
                    Item.MouseLeave:Connect(function()
                        if not isSelected then Tween(Item, { BackgroundColor3 = Theme.DropdownItem }) end
                    end)
                    Item.MouseButton1Click:Connect(function()
                        selected = opt
                        SelLbl.Text = selected
                        isOpen = false
                        Panel.Visible = false
                        Wrapper.Size = UDim2.new(1, 0, 0, 32)
                        Tween(Chevron, { TextColor3 = Theme.ElementTextDim })
                        RebuildItems()
                        pcall(callback, selected)
                    end)
                end
            end
            RebuildItems()

            local ToggleBtn = New("TextButton", {
                Size                  = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency= 1,
                Text                  = "",
                ZIndex                = 7,
                Parent                = Frame,
            })
            ToggleBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Panel.Visible = isOpen
                if isOpen then
                    Wrapper.Size = UDim2.new(1, 0, 0, 32 + Panel.AbsoluteSize.Y + 4)
                    Tween(Chevron, { TextColor3 = Theme.BorderAccent })
                else
                    Wrapper.Size = UDim2.new(1, 0, 0, 32)
                    Tween(Chevron, { TextColor3 = Theme.ElementTextDim })
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
                    Panel.Size = UDim2.new(1, 0, 0, #options * 26 + 4)
                    RebuildItems()
                end,
                GetValue = function() return selected end,
                SetValue = function(_, v)
                    if table.find(options, v) then
                        selected = v; SelLbl.Text = v; RebuildItems(); pcall(callback, v)
                    end
                end,
                Destroy = function() Wrapper:Destroy() end,
            }
        end

        -- ── COLOR PICKER ──────────────────────────────────
        -- FIX: Complete rewrite.
        --   1. h/s/v declared BEFORE ApplyColor references them
        --   2. SV square uses two properly layered gradient frames (white left-to-right,
        --      black top-to-bottom) that actually produce correct HSV colours
        --   3. Knob initial position calculated from actual h/s/v of the default colour
        --   4. Hue knob initial position set from h value
        --   5. Panel height increased to fit contents comfortably
        function Tab:AddColorPicker(cpConfig)
            cpConfig = cpConfig or {}
            local cpName      = cpConfig.Name     or "Color"
            local default     = cpConfig.Default  or Color3.fromRGB(220, 60, 60)
            local callback    = cpConfig.Callback or function() end
            local isOpen      = false
            local currentColor= default

            -- Declare h/s/v UP FRONT so ApplyColor can close over them
            local h, s, v = Color3.toHSV(currentColor)

            local PanelHeight = 148

            local Wrapper = New("Frame", {
                Size                  = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency= 1,
                LayoutOrder           = NextOrder(),
                ClipsDescendants      = false,
                ZIndex                = 8,
                Parent                = TabContent,
            })

            local Frame = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Theme.ElementBg,
                BorderSizePixel  = 0,
                ZIndex           = 8,
                Parent           = Wrapper,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Frame })

            New("TextLabel", {
                Size                  = UDim2.new(1, -60, 1, 0),
                Position              = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency= 1,
                Text                  = cpName,
                TextColor3            = Theme.ElementText,
                Font                  = Theme.FontMed,
                TextSize              = 12,
                TextXAlignment        = Enum.TextXAlignment.Left,
                ZIndex                = 9,
                Parent                = Frame,
            })

            local Preview = New("Frame", {
                Size             = UDim2.new(0, 20, 0, 14),
                Position         = UDim2.new(1, -30, 0.5, -7),
                BackgroundColor3 = currentColor,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = Frame,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Preview })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Preview })

            -- Panel
            local Panel = New("Frame", {
                Size             = UDim2.new(1, 0, 0, PanelHeight),
                Position         = UDim2.new(0, 0, 0, 34),
                BackgroundColor3 = Theme.DropdownBg,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 18,
                Parent           = Wrapper,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Panel })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = Panel })

            -- ── SV Square ──────────────────────────────
            -- Base: hue color (fully saturated, full value)
            local SVBase = New("Frame", {
                Size             = UDim2.new(0, 118, 0, 108),
                Position         = UDim2.new(0, 8, 0, 8),
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                BorderSizePixel  = 0,
                ZIndex           = 19,
                ClipsDescendants = true,
                Parent           = Panel,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SVBase })

            -- White overlay: transparent on right, white on left (adds white = lowers saturation)
            local SVWhiteLayer = New("Frame", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel  = 0,
                ZIndex           = 20,
                Parent           = SVBase,
            })
            New("UIGradient", {
                Color        = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),  -- left: opaque white (no saturation)
                    NumberSequenceKeypoint.new(1, 1),  -- right: transparent (full saturation)
                }),
                Rotation = 0,
                Parent   = SVWhiteLayer,
            })

            -- Black overlay: transparent on top, black on bottom (adds black = lowers value)
            local SVBlackLayer = New("Frame", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel  = 0,
                ZIndex           = 21,
                Parent           = SVBase,
            })
            New("UIGradient", {
                Color        = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0)),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),  -- top: transparent (full value)
                    NumberSequenceKeypoint.new(1, 0),  -- bottom: opaque black (zero value)
                }),
                Rotation = 90,
                Parent   = SVBlackLayer,
            })

            -- SV Knob — position from initial s/v
            local SVKnob = New("Frame", {
                Size             = UDim2.new(0, 8, 0, 8),
                Position         = UDim2.new(s, -4, 1 - v, -4),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel  = 0,
                ZIndex           = 23,
                Parent           = SVBase,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SVKnob })
            New("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1.2, Parent = SVKnob })

            -- ── Hue Bar ────────────────────────────────
            local HueBar = New("Frame", {
                Size             = UDim2.new(0, 12, 0, 108),
                Position         = UDim2.new(0, 134, 0, 8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel  = 0,
                ZIndex           = 19,
                ClipsDescendants = true,
                Parent           = Panel,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = HueBar })

            local hueSeq = {}
            for i = 0, 6 do
                table.insert(hueSeq, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
            end
            New("UIGradient", {
                Color    = ColorSequence.new(hueSeq),
                Rotation = 90,
                Parent   = HueBar,
            })

            -- Hue knob position from initial h
            local HueKnob = New("Frame", {
                Size             = UDim2.new(1, 4, 0, 4),
                Position         = UDim2.new(0, -2, h, -2),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel  = 0,
                ZIndex           = 21,
                Parent           = HueBar,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 2), Parent = HueKnob })
            New("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Parent = HueKnob })

            -- ── Hex Input ──────────────────────────────
            local HexInput = New("TextBox", {
                Size                  = UDim2.new(0, 74, 0, 20),
                Position              = UDim2.new(0, 8, 0, 122),
                BackgroundColor3      = Theme.ElementBg,
                Text                  = string.format("%02X%02X%02X",
                    math.floor(currentColor.R * 255 + 0.5),
                    math.floor(currentColor.G * 255 + 0.5),
                    math.floor(currentColor.B * 255 + 0.5)),
                TextColor3            = Theme.ElementText,
                Font                  = Theme.FontLight,
                TextSize              = 10,
                ClearTextOnFocus      = false,
                ZIndex                = 19,
                PlaceholderText       = "RRGGBB",
                Parent                = Panel,
            })
            New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = HexInput })
            New("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = HexInput })
            New("UIPadding", { PaddingLeft = UDim.new(0, 5), Parent = HexInput })

            -- ── Apply Color ────────────────────────────
            local function ApplyColor()
                currentColor = Color3.fromHSV(h, s, v)
                Preview.BackgroundColor3  = currentColor
                SVBase.BackgroundColor3   = Color3.fromHSV(h, 1, 1)  -- update hue tint
                SVKnob.Position           = UDim2.new(s, -4, 1 - v, -4)
                HueKnob.Position          = UDim2.new(0, -2, h, -2)
                HexInput.Text             = string.format("%02X%02X%02X",
                    math.floor(currentColor.R * 255 + 0.5),
                    math.floor(currentColor.G * 255 + 0.5),
                    math.floor(currentColor.B * 255 + 0.5))
                pcall(callback, currentColor)
            end

            -- ── Drag Logic ─────────────────────────────
            local draggingSV, draggingH = false, false

            local SVBtn = New("TextButton", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=24, Parent=SVBase
            })
            SVBtn.MouseButton1Down:Connect(function(x, y)
                draggingSV = true
                local r = SVBase.AbsoluteSize
                local p = SVBase.AbsolutePosition
                s = math.clamp((x - p.X) / r.X, 0, 1)
                v = 1 - math.clamp((y - p.Y) / r.Y, 0, 1)
                ApplyColor()
            end)

            local HueBtn = New("TextButton", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=24, Parent=HueBar
            })
            HueBtn.MouseButton1Down:Connect(function(_, y)
                draggingH = true
                h = math.clamp((y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                ApplyColor()
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if draggingSV then
                    local r = SVBase.AbsoluteSize
                    local p = SVBase.AbsolutePosition
                    s = math.clamp((input.Position.X - p.X) / r.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - p.Y) / r.Y, 0, 1)
                    ApplyColor()
                elseif draggingH then
                    h = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                    ApplyColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV = false
                    draggingH  = false
                end
            end)

            HexInput.FocusLost:Connect(function()
                local hex = HexInput.Text:gsub("#", ""):sub(1, 6)
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g and b then
                        currentColor = Color3.fromRGB(r, g, b)
                        h, s, v = Color3.toHSV(currentColor)
                        ApplyColor()
                    end
                end
            end)

            -- Toggle open/close
            local OpenBtn = New("TextButton", {
                Size                  = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency= 1,
                Text                  = "",
                ZIndex                = 10,
                Parent                = Frame,
            })
            OpenBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Panel.Visible = isOpen
                Wrapper.Size = UDim2.new(1, 0, 0, isOpen and 32 + PanelHeight + 4 or 32)
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
                    ApplyColor()
                    pcall(callback, c)
                end,
                Destroy = function() Wrapper:Destroy() end,
            }
        end

        return Tab
    end

    function Window:SetKeybind(key)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == key then
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

Window:SetKeybind(Enum.KeyCode.RightControl)

local AimbotTab = Window:CreateTab({ Name = "Aimbot", Icon = "⊕" })

AimbotTab:AddLabel("Configure aim settings below.")
AimbotTab:AddSeparator("GENERAL")

AimbotTab:AddToggle({
    Name     = "Enable Aimbot",
    Default  = false,
    Callback = function(val) print("Aimbot:", val) end,
})

AimbotTab:AddSlider({
    Name     = "FOV",
    Min      = 1,
    Max      = 360,
    Default  = 90,
    Suffix   = "°",
    Callback = function(val) print("FOV:", val) end,
})

AimbotTab:AddSlider({
    Name     = "Smoothing",
    Min      = 0,
    Max      = 100,
    Default  = 30,
    Suffix   = "%",
})

AimbotTab:AddSeparator("TARGET")

AimbotTab:AddDropdown({
    Name     = "Target Bone",
    Options  = { "Head", "Neck", "Chest", "Pelvis" },
    Default  = "Head",
    Callback = function(val) print("Bone:", val) end,
})

AimbotTab:AddSeparator()

AimbotTab:AddButton({
    Name     = "Reset Settings",
    Callback = function() print("Reset!") end,
})

local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "◈" })

VisualsTab:AddToggle({ Name = "ESP Boxes",    Default = true  })
VisualsTab:AddToggle({ Name = "ESP Tracers",  Default = false })
VisualsTab:AddSeparator("COLORS")
VisualsTab:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(220, 60, 60),
    Callback = function(color) print("Color:", color) end,
})
VisualsTab:AddColorPicker({
    Name     = "Skeleton Color",
    Default  = Color3.fromRGB(255, 255, 255),
})

local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "≡" })

MiscTab:AddLabel("Miscellaneous options")
MiscTab:AddToggle({ Name = "Fly",        Default = false })
MiscTab:AddToggle({ Name = "Speed Hack", Default = false })
MiscTab:AddSlider({ Name = "Walk Speed", Min = 16, Max = 200, Default = 16, Suffix = " ws" })
MiscTab:AddButton({ Name = "Rejoin Server", Callback = function() end })

═══════════════════════════════════════════════════════
--]]

return OnetapUI
