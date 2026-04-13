--[[
    OnetapUI — Roblox UI Library
    Inspired by the CS:GO onetap cheat panel aesthetic
    Toggle: Right Shift

    LOADSTRING:
        local OnetapUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--]]

local OnetapUI = {}
OnetapUI.__index = OnetapUI

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

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
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
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
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                        startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- ── Root (NO ClipsDescendants — it clips UIStroke and breaks the border) ──
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

    -- ── Top accent bar ──
    -- Drawn as a child Frame with its own UICorner so it rounds cleanly at the top
    -- without needing Root to clip. It's tall enough that its bottom corners
    -- are hidden behind the header frame.
    local AccentBar = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 8),   -- 8px tall — top 2px are red, rest hidden by header
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.BorderAccent,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = Root,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = AccentBar })

    -- ── Header (sits on top of AccentBar's bottom half, hiding the pill shape) ──
    local Header = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        Position         = UDim2.new(0, 0, 0, 2),   -- offset down 2px so only 2px of red shows
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = Root,
    })
    -- Header has no UICorner — its top edge just covers the lower part of AccentBar.
    -- Its bottom is squared off naturally.

    New("TextLabel", {
        Size                  = UDim2.new(0, 120, 1, 0),
        Position              = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency= 1,
        Text                  = title,
        TextColor3            = Theme.HeaderText,
        Font                  = Theme.Font,
        TextSize              = 15,
        TextXAlignment        = Enum.TextXAlignment.Left,
        ZIndex                = 5,
        Parent                = Header,
    })
    New("TextLabel", {
        Size                  = UDim2.new(0, 200, 1, 0),
        Position              = UDim2.new(0, 80, 0, 0),
        BackgroundTransparency= 1,
        Text                  = subtitle,
        TextColor3            = Theme.HeaderSub,
        Font                  = Theme.FontLight,
        TextSize              = 11,
        TextXAlignment        = Enum.TextXAlignment.Left,
        ZIndex                = 5,
        Parent                = Header,
    })

    -- ── Tab sidebar ──
    local TabBar = New("Frame", {
        Size             = UDim2.new(0, 118, 1, -48),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = Root,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBar })
    -- Square off top-right corner so it sits flush under the header
    New("Frame", {
        Size             = UDim2.new(0, 8, 0, 8),
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
        Size             = UDim2.new(0, 1, 1, -48),
        Position         = UDim2.new(0, 118, 0, 48),
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
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = TabList })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
        Parent = TabList,
    })

    -- Content area
    local ContentArea = New("Frame", {
        Size             = UDim2.new(1, -120, 1, -48),
        Position         = UDim2.new(0, 120, 0, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Root,
    })

    MakeDraggable(Root, Header)

    -- Right Shift to toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
            Root.Visible = not Root.Visible
        end
    end)

    local Window = { _tabs = {}, _activeTab = nil, _gui = ScreenGui, _root = Root }

    function Window:SetKeybind(key)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == key then Root.Visible = not Root.Visible end
        end)
    end
    function Window:Destroy() ScreenGui:Destroy() end

    -- ══════════════════════════════════════════
    --  TABS
    -- ══════════════════════════════════════════
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

        local TabLabel = New("TextLabel", {
            Name                  = "TabLabel",
            Size                  = UDim2.new(1, -10, 1, 0),
            Position              = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency= 1,
            Text                  = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
            TextColor3            = Theme.TabText,
            Font                  = Theme.FontMed,
            TextSize              = 12,
            TextXAlignment        = Enum.TextXAlignment.Left,
            ZIndex                = 4,
            Parent                = TabBtn,
        })

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
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = TabContent })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 9),
            Parent = TabContent,
        })

        local function SetActive(active)
            if active then
                Tween(TabBtn,    { BackgroundColor3 = Color3.fromRGB(27,27,31) })
                Tween(TabLabel,  { TextColor3 = Theme.TabTextActive })
                Tween(Indicator, { BackgroundTransparency = 0 })
                TabContent.Visible = true
            else
                Tween(TabBtn,    { BackgroundColor3 = Theme.TabInactive })
                Tween(TabLabel,  { TextColor3 = Theme.TabText })
                Tween(Indicator, { BackgroundTransparency = 1 })
                TabContent.Visible = false
            end
        end

        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= tabName then Tween(TabBtn, { BackgroundColor3 = Theme.TabHover }) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= tabName then Tween(TabBtn, { BackgroundColor3 = Theme.TabInactive }) end
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
        if not self._activeTab then self._activeTab = tabName; SetActive(true) end

        local function NextOrder() Tab._order = Tab._order + 1; return Tab._order end

        -- ════════════════════════════════════════
        --  ELEMENTS
        -- ════════════════════════════════════════

        -- ── LABEL ──────────────────────────────
        function Tab:AddLabel(text)
            local F = New("Frame", {
                Size = UDim2.new(1,0,0,22), BackgroundTransparency=1,
                LayoutOrder=NextOrder(), Parent=TabContent,
            })
            local L = New("TextLabel", {
                Size=UDim2.new(1,-4,1,0), Position=UDim2.new(0,4,0,0),
                BackgroundTransparency=1, Text=text, TextColor3=Theme.ElementTextDim,
                Font=Theme.FontLight, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, Parent=F,
            })
            return { SetText=function(_,t) L.Text=t end, Destroy=function() F:Destroy() end }
        end

        -- ── SEPARATOR ──────────────────────────
        function Tab:AddSeparator(labelText)
            local F = New("Frame", {
                Size=UDim2.new(1,0,0,18), BackgroundTransparency=1,
                LayoutOrder=NextOrder(), Parent=TabContent,
            })
            -- Full-width line at ZIndex 1 (behind everything)
            New("Frame", {
                Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0.5,0),
                BackgroundColor3=Theme.Separator, BorderSizePixel=0, ZIndex=1, Parent=F,
            })
            -- Red dot at ZIndex 3
            local Dot = New("Frame", {
                Size=UDim2.new(0,4,0,4), Position=UDim2.new(0,2,0.5,-2),
                BackgroundColor3=Theme.SeparatorAccent, BorderSizePixel=0, ZIndex=3, Parent=F,
            })
            New("UICorner", { CornerRadius=UDim.new(1,0), Parent=Dot })

            if labelText and labelText ~= "" then
                -- Opaque background patch behind dot+label at ZIndex 2
                -- so line appears to "start" after the label
                local Cover = New("Frame", {
                    Size=UDim2.new(0,6,1,0), Position=UDim2.new(0,0,0,0),
                    BackgroundColor3=Theme.Background, BorderSizePixel=0, ZIndex=2, Parent=F,
                })
                -- The text label at ZIndex 3 (above line and cover)
                local Lbl = New("TextLabel", {
                    Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                    Position=UDim2.new(0,12,0,0), BackgroundColor3=Theme.Background,
                    BackgroundTransparency=0,
                    Text=" " .. labelText .. " ",
                    TextColor3=Theme.ElementTextDim, Font=Theme.FontLight, TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=F,
                })
            end
            return { Destroy=function() F:Destroy() end }
        end

        -- ── BUTTON ─────────────────────────────
        function Tab:AddButton(buttonConfig)
            buttonConfig = buttonConfig or {}
            local btnText  = buttonConfig.Name     or "Button"
            local callback = buttonConfig.Callback or function() end
            local F = New("Frame", {
                Size=UDim2.new(1,0,0,32), BackgroundColor3=Theme.ElementBg, BorderSizePixel=0,
                LayoutOrder=NextOrder(), Parent=TabContent,
            })
            New("UICorner", { CornerRadius=UDim.new(0,4), Parent=F })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=F })
            local Btn = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=2, Parent=F,
            })
            local Lbl = New("TextLabel", {
                Size=UDim2.new(1,-36,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1,
                Text=btnText, TextColor3=Theme.ButtonText, Font=Theme.FontMed, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=F,
            })
            local Arrow = New("TextLabel", {
                Size=UDim2.new(0,20,1,0), Position=UDim2.new(1,-24,0,0), BackgroundTransparency=1,
                Text="›", TextColor3=Theme.ElementTextDim, Font=Theme.Font, TextSize=16, ZIndex=3, Parent=F,
            })
            Btn.MouseEnter:Connect(function()
                Tween(F,     { BackgroundColor3=Theme.ElementHover })
                Tween(Lbl,   { TextColor3=Color3.fromRGB(255,255,255) })
                Tween(Arrow, { TextColor3=Theme.BorderAccent })
            end)
            Btn.MouseLeave:Connect(function()
                Tween(F,     { BackgroundColor3=Theme.ElementBg })
                Tween(Lbl,   { TextColor3=Theme.ButtonText })
                Tween(Arrow, { TextColor3=Theme.ElementTextDim })
            end)
            Btn.MouseButton1Click:Connect(function()
                Tween(F, { BackgroundColor3=Theme.BorderAccent }, 0.07)
                task.delay(0.08, function() Tween(F, { BackgroundColor3=Theme.ElementHover }, 0.12) end)
                pcall(callback)
            end)
            return { SetText=function(_,t) Lbl.Text=t end, Destroy=function() F:Destroy() end }
        end

        -- ── TOGGLE ─────────────────────────────
        function Tab:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local name     = toggleConfig.Name     or "Toggle"
            local toggled  = toggleConfig.Default  or false
            local callback = toggleConfig.Callback or function() end
            local F = New("Frame", {
                Size=UDim2.new(1,0,0,32), BackgroundColor3=Theme.ElementBg, BorderSizePixel=0,
                LayoutOrder=NextOrder(), Parent=TabContent,
            })
            New("UICorner", { CornerRadius=UDim.new(0,4), Parent=F })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=F })
            New("TextLabel", {
                Size=UDim2.new(1,-56,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1,
                Text=name, TextColor3=Theme.ElementText, Font=Theme.FontMed, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2, Parent=F,
            })
            local Track = New("Frame", {
                Size=UDim2.new(0,34,0,16), Position=UDim2.new(1,-44,0.5,-8),
                BackgroundColor3=toggled and Theme.ToggleOn or Theme.ToggleOff, BorderSizePixel=0, ZIndex=2, Parent=F,
            })
            New("UICorner", { CornerRadius=UDim.new(1,0), Parent=Track })
            local Knob = New("Frame", {
                Size=UDim2.new(0,10,0,10),
                Position=toggled and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,3,0.5,-5),
                BackgroundColor3=Theme.ToggleKnob, BorderSizePixel=0, ZIndex=3, Parent=Track,
            })
            New("UICorner", { CornerRadius=UDim.new(1,0), Parent=Knob })
            local Btn = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=4, Parent=F,
            })
            local function Update()
                Tween(Track, { BackgroundColor3=toggled and Theme.ToggleOn or Theme.ToggleOff })
                Tween(Knob,  { Position=toggled and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,3,0.5,-5) })
                pcall(callback, toggled)
            end
            Btn.MouseButton1Click:Connect(function() toggled=not toggled; Update() end)
            Btn.MouseEnter:Connect(function() Tween(F, { BackgroundColor3=Theme.ElementHover }) end)
            Btn.MouseLeave:Connect(function() Tween(F, { BackgroundColor3=Theme.ElementBg }) end)
            return {
                SetValue=function(_,val) toggled=val; Update() end,
                GetValue=function() return toggled end,
                Destroy=function() F:Destroy() end,
            }
        end

        -- ── SLIDER ─────────────────────────────
        function Tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local name     = sliderConfig.Name     or "Slider"
            local minV     = sliderConfig.Min      or 0
            local maxV     = sliderConfig.Max      or 100
            local suffix   = sliderConfig.Suffix   or ""
            local callback = sliderConfig.Callback or function() end
            local value    = math.clamp(sliderConfig.Default or minV, minV, maxV)
            local F = New("Frame", {
                Size=UDim2.new(1,0,0,42), BackgroundColor3=Theme.ElementBg, BorderSizePixel=0,
                LayoutOrder=NextOrder(), Parent=TabContent,
            })
            New("UICorner", { CornerRadius=UDim.new(0,4), Parent=F })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=F })
            New("TextLabel", {
                Size=UDim2.new(1,-70,0,22), Position=UDim2.new(0,10,0,2), BackgroundTransparency=1,
                Text=name, TextColor3=Theme.ElementText, Font=Theme.FontMed, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2, Parent=F,
            })
            local ValLbl = New("TextLabel", {
                Size=UDim2.new(0,60,0,22), Position=UDim2.new(1,-64,0,2), BackgroundTransparency=1,
                Text=tostring(value)..suffix, TextColor3=Theme.BorderAccent,
                Font=Theme.Font, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=2, Parent=F,
            })
            local TrackHolder = New("Frame", {
                Size=UDim2.new(1,-14,0,16), Position=UDim2.new(0,7,0,24),
                BackgroundTransparency=1, ZIndex=2, Parent=F,
            })
            local Track = New("Frame", {
                Size=UDim2.new(1,0,0,4), Position=UDim2.new(0,0,0.5,-2),
                BackgroundColor3=Theme.SliderTrack, BorderSizePixel=0, ZIndex=2, Parent=TrackHolder,
            })
            New("UICorner", { CornerRadius=UDim.new(1,0), Parent=Track })
            local pct = (value-minV)/(maxV-minV)
            local Fill = New("Frame", {
                Size=UDim2.new(pct,0,1,0), BackgroundColor3=Theme.SliderFill,
                BorderSizePixel=0, ZIndex=3, Parent=Track,
            })
            New("UICorner", { CornerRadius=UDim.new(1,0), Parent=Fill })
            local Knob = New("Frame", {
                Size=UDim2.new(0,10,0,10), Position=UDim2.new(pct,-5,0.5,-5),
                BackgroundColor3=Theme.SliderKnob, BorderSizePixel=0, ZIndex=4, Parent=Track,
            })
            New("UICorner", { CornerRadius=UDim.new(1,0), Parent=Knob })
            local dragging = false
            local function UpdateSlider(screenX)
                local relX = math.clamp(screenX - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                local p    = relX / Track.AbsoluteSize.X
                value = math.clamp(math.floor(minV + p*(maxV-minV) + 0.5), minV, maxV)
                local np = (value-minV)/(maxV-minV)
                Fill.Size = UDim2.new(np,0,1,0); Knob.Position = UDim2.new(np,-5,0.5,-5)
                ValLbl.Text = tostring(value)..suffix
                pcall(callback, value)
            end
            local InputBtn = New("TextButton", {
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=5, Parent=TrackHolder,
            })
            InputBtn.MouseButton1Down:Connect(function()
                dragging = true
                UpdateSlider(UserInputService:GetMouseLocation().X)
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                    UpdateSlider(UserInputService:GetMouseLocation().X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end)
            return {
                SetValue=function(_,val)
                    value=math.clamp(val,minV,maxV)
                    local np=(value-minV)/(maxV-minV)
                    Tween(Fill,{Size=UDim2.new(np,0,1,0)}); Tween(Knob,{Position=UDim2.new(np,-5,0.5,-5)})
                    ValLbl.Text=tostring(value)..suffix; pcall(callback,value)
                end,
                GetValue=function() return value end,
                Destroy=function() F:Destroy() end,
            }
        end

        -- ── DROPDOWN ───────────────────────────
        -- Fixed: proper spacing between value label and chevron
        -- Added: animated open/close tween on panel height
        function Tab:AddDropdown(dropConfig)
            dropConfig = dropConfig or {}
            local dropName = dropConfig.Name     or "Dropdown"
            local options  = dropConfig.Options  or {}
            local callback = dropConfig.Callback or function() end
            local selected = dropConfig.Default  or (options[1] or "None")
            local isOpen   = false
            local itemH    = 26
            local panelH   = #options * itemH + 6

            local Wrapper = New("Frame", {
                Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
                LayoutOrder=NextOrder(), ClipsDescendants=false, ZIndex=5, Parent=TabContent,
            })
            local Frame = New("Frame", {
                Size=UDim2.new(1,0,0,32), BackgroundColor3=Theme.ElementBg,
                BorderSizePixel=0, ZIndex=5, Parent=Wrapper,
            })
            New("UICorner", { CornerRadius=UDim.new(0,4), Parent=Frame })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=Frame })

            -- Name label on the left
            New("TextLabel", {
                Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1,
                Text=dropName, TextColor3=Theme.ElementText, Font=Theme.FontMed, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6, Parent=Frame,
            })
            -- Chevron pinned to far right
            local Chevron = New("TextLabel", {
                Size=UDim2.new(0,16,1,0), Position=UDim2.new(1,-20,0,0), BackgroundTransparency=1,
                Text="▾", TextColor3=Theme.ElementTextDim, Font=Theme.Font, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6, Parent=Frame,
            })
            -- Selected value label sitting just left of the chevron with a clean gap
            local SelLbl = New("TextLabel", {
                Size=UDim2.new(0.5,-24,1,0), Position=UDim2.new(0.5,0,0,0), BackgroundTransparency=1,
                Text=selected, TextColor3=Theme.BorderAccent, Font=Theme.FontLight, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Right, ZIndex=6, Parent=Frame,
            })

            -- Panel — starts at Size Y=0 for animation
            local Panel = New("Frame", {
                Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,0,34),
                BackgroundColor3=Theme.DropdownBg, BorderSizePixel=0,
                ClipsDescendants=true, ZIndex=20, Parent=Wrapper,
            })
            New("UICorner", { CornerRadius=UDim.new(0,4), Parent=Panel })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=Panel })
            New("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,0), Parent=Panel })
            New("UIPadding", {
                PaddingTop=UDim.new(0,3), PaddingBottom=UDim.new(0,3),
                PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,3),
                Parent=Panel,
            })

            local function RebuildItems()
                for _, c in pairs(Panel:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local isSel = opt == selected
                    local Item = New("TextButton", {
                        Size=UDim2.new(1,0,0,itemH), BackgroundColor3=isSel and Theme.DropdownSelected or Theme.DropdownItem,
                        Text="", BorderSizePixel=0, ZIndex=21, LayoutOrder=i, Parent=Panel,
                    })
                    New("UICorner", { CornerRadius=UDim.new(0,3), Parent=Item })
                    New("TextLabel", {
                        Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,8,0,0), BackgroundTransparency=1,
                        Text=opt, TextColor3=isSel and Color3.fromRGB(255,255,255) or Theme.ElementText,
                        Font=Theme.FontMed, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left,
                        ZIndex=22, Parent=Item,
                    })
                    Item.MouseEnter:Connect(function()
                        if not isSel then Tween(Item,{BackgroundColor3=Theme.DropdownHover}) end
                    end)
                    Item.MouseLeave:Connect(function()
                        if not isSel then Tween(Item,{BackgroundColor3=Theme.DropdownItem}) end
                    end)
                    Item.MouseButton1Click:Connect(function()
                        selected = opt; SelLbl.Text = selected
                        isOpen = false
                        Tween(Panel, { Size=UDim2.new(1,0,0,0) }, 0.15)
                        task.delay(0.15, function() Panel.Visible = false end)
                        Wrapper.Size = UDim2.new(1,0,0,32)
                        Tween(Chevron, { TextColor3=Theme.ElementTextDim })
                        RebuildItems(); pcall(callback, selected)
                    end)
                end
            end
            RebuildItems()

            local ToggleBtn = New("TextButton", {
                Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, Text="", ZIndex=7, Parent=Frame,
            })
            ToggleBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    Panel.Visible = true
                    Panel.Size = UDim2.new(1,0,0,0)
                    Tween(Panel, { Size=UDim2.new(1,0,0,panelH) }, 0.18)
                    Wrapper.Size = UDim2.new(1,0,0,32 + panelH + 4)
                    Tween(Chevron, { TextColor3=Theme.BorderAccent })
                else
                    Tween(Panel, { Size=UDim2.new(1,0,0,0) }, 0.15)
                    task.delay(0.15, function() Panel.Visible = false end)
                    Wrapper.Size = UDim2.new(1,0,0,32)
                    Tween(Chevron, { TextColor3=Theme.ElementTextDim })
                end
            end)
            ToggleBtn.MouseEnter:Connect(function() Tween(Frame,{BackgroundColor3=Theme.ElementHover}) end)
            ToggleBtn.MouseLeave:Connect(function() Tween(Frame,{BackgroundColor3=Theme.ElementBg}) end)

            return {
                SetOptions=function(_,opts)
                    options=opts; panelH=#opts*itemH+6
                    if not table.find(options,selected) then selected=options[1] or "None"; SelLbl.Text=selected end
                    RebuildItems()
                end,
                GetValue=function() return selected end,
                SetValue=function(_,v)
                    if table.find(options,v) then selected=v; SelLbl.Text=v; RebuildItems(); pcall(callback,v) end
                end,
                Destroy=function() Wrapper:Destroy() end,
            }
        end

        -- ── COLOR PICKER (full rewrite) ─────────
        -- Uses RunService.RenderStepped for polling instead of InputBegan/InputChanged
        -- to avoid all coordinate system issues. Works on both click and drag.
        function Tab:AddColorPicker(cpConfig)
            cpConfig = cpConfig or {}
            local cpName      = cpConfig.Name     or "Color"
            local default     = cpConfig.Default  or Color3.fromRGB(220, 60, 60)
            local callback    = cpConfig.Callback or function() end
            local isOpen      = false
            local currentColor= default
            local h, s, v     = Color3.toHSV(currentColor)
            local PH          = 152  -- panel height

            local Wrapper = New("Frame", {
                Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
                LayoutOrder=NextOrder(), ClipsDescendants=false, ZIndex=8, Parent=TabContent,
            })
            local Frame = New("Frame", {
                Size=UDim2.new(1,0,0,32), BackgroundColor3=Theme.ElementBg,
                BorderSizePixel=0, ZIndex=8, Parent=Wrapper,
            })
            New("UICorner", { CornerRadius=UDim.new(0,4), Parent=Frame })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=Frame })
            New("TextLabel", {
                Size=UDim2.new(1,-52,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1,
                Text=cpName, TextColor3=Theme.ElementText, Font=Theme.FontMed, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9, Parent=Frame,
            })
            local Preview = New("Frame", {
                Size=UDim2.new(0,20,0,14), Position=UDim2.new(1,-30,0.5,-7),
                BackgroundColor3=currentColor, BorderSizePixel=0, ZIndex=9, Parent=Frame,
            })
            New("UICorner", { CornerRadius=UDim.new(0,3), Parent=Preview })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=Preview })

            local Panel = New("Frame", {
                Size=UDim2.new(1,0,0,PH), Position=UDim2.new(0,0,0,34),
                BackgroundColor3=Theme.DropdownBg, BorderSizePixel=0,
                Visible=false, ZIndex=18, Parent=Wrapper,
            })
            New("UICorner", { CornerRadius=UDim.new(0,4), Parent=Panel })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=Panel })

            -- SV square: base color layer
            local SVBase = New("Frame", {
                Size=UDim2.new(0,116,0,108), Position=UDim2.new(0,8,0,8),
                BackgroundColor3=Color3.fromHSV(h,1,1), BorderSizePixel=0,
                ClipsDescendants=true, ZIndex=19, Parent=Panel,
            })
            New("UICorner", { CornerRadius=UDim.new(0,3), Parent=SVBase })
            -- White left-to-right gradient (decreases saturation)
            local WhiteLayer = New("Frame", {
                Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(1,1,1),
                BorderSizePixel=0, ZIndex=20, Parent=SVBase,
            })
            New("UIGradient", {
                Transparency=NumberSequence.new({
                    NumberSequenceKeypoint.new(0,0),
                    NumberSequenceKeypoint.new(1,1),
                }),
                Rotation=0, Parent=WhiteLayer,
            })
            -- Black top-to-bottom gradient (decreases value)
            local BlackLayer = New("Frame", {
                Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(0,0,0),
                BorderSizePixel=0, ZIndex=21, Parent=SVBase,
            })
            New("UIGradient", {
                Transparency=NumberSequence.new({
                    NumberSequenceKeypoint.new(0,1),
                    NumberSequenceKeypoint.new(1,0),
                }),
                Rotation=90, Parent=BlackLayer,
            })
            -- SV Knob
            local SVKnob = New("Frame", {
                Size=UDim2.new(0,10,0,10), Position=UDim2.new(s,-5,1-v,-5),
                BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=23, Parent=SVBase,
            })
            New("UICorner", { CornerRadius=UDim.new(1,0), Parent=SVKnob })
            New("UIStroke", { Color=Color3.new(0,0,0), Thickness=1.5, Parent=SVKnob })

            -- Hue bar
            local HueBar = New("Frame", {
                Size=UDim2.new(0,14,0,108), Position=UDim2.new(0,132,0,8),
                BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
                ClipsDescendants=true, ZIndex=19, Parent=Panel,
            })
            New("UICorner", { CornerRadius=UDim.new(0,3), Parent=HueBar })
            local hueSeq = {}
            for i=0,6 do table.insert(hueSeq, ColorSequenceKeypoint.new(i/6, Color3.fromHSV(i/6,1,1))) end
            New("UIGradient", { Color=ColorSequence.new(hueSeq), Rotation=90, Parent=HueBar })
            -- Hue knob
            local HueKnob = New("Frame", {
                Size=UDim2.new(1,4,0,6), Position=UDim2.new(0,-2,h,-3),
                BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=21, Parent=HueBar,
            })
            New("UICorner", { CornerRadius=UDim.new(0,2), Parent=HueKnob })
            New("UIStroke", { Color=Color3.new(0,0,0), Thickness=1, Parent=HueKnob })

            -- Hex input
            local HexInput = New("TextBox", {
                Size=UDim2.new(0,76,0,22), Position=UDim2.new(0,8,0,124),
                BackgroundColor3=Theme.ElementBg,
                Text=string.format("%02X%02X%02X",
                    math.floor(currentColor.R*255+.5),
                    math.floor(currentColor.G*255+.5),
                    math.floor(currentColor.B*255+.5)),
                TextColor3=Theme.ElementText, Font=Theme.FontLight, TextSize=10,
                ClearTextOnFocus=false, ZIndex=19, PlaceholderText="RRGGBB", Parent=Panel,
            })
            New("UICorner", { CornerRadius=UDim.new(0,3), Parent=HexInput })
            New("UIStroke", { Color=Theme.Border, Thickness=1, Parent=HexInput })
            New("UIPadding", { PaddingLeft=UDim.new(0,6), Parent=HexInput })

            local function Sync()
                currentColor           = Color3.fromHSV(h, s, v)
                Preview.BackgroundColor3 = currentColor
                SVBase.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
                SVKnob.Position          = UDim2.new(s, -5, 1-v, -5)
                HueKnob.Position         = UDim2.new(0, -2, h, -3)
                HexInput.Text            = string.format("%02X%02X%02X",
                    math.floor(currentColor.R*255+.5),
                    math.floor(currentColor.G*255+.5),
                    math.floor(currentColor.B*255+.5))
                pcall(callback, currentColor)
            end

            -- Input state
            local holdingSV, holdingH = false, false

            -- Single InputBegan for both controls — only fires when panel is open
            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or not isOpen then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local mp = UserInputService:GetMouseLocation()
                do  -- SV square hit test
                    local p, sz = SVBase.AbsolutePosition, SVBase.AbsoluteSize
                    if mp.X >= p.X and mp.X <= p.X+sz.X and mp.Y >= p.Y and mp.Y <= p.Y+sz.Y then
                        holdingSV = true
                        s = math.clamp((mp.X - p.X) / sz.X, 0, 1)
                        v = 1 - math.clamp((mp.Y - p.Y) / sz.Y, 0, 1)
                        Sync(); return
                    end
                end
                do  -- Hue bar hit test
                    local p, sz = HueBar.AbsolutePosition, HueBar.AbsoluteSize
                    if mp.X >= p.X and mp.X <= p.X+sz.X and mp.Y >= p.Y and mp.Y <= p.Y+sz.Y then
                        holdingH = true
                        h = math.clamp((mp.Y - p.Y) / sz.Y, 0, 1)
                        Sync(); return
                    end
                end
            end)

            -- Drag continuation
            UserInputService.InputChanged:Connect(function(input)
                if not isOpen then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if not holdingSV and not holdingH then return end
                local mp = UserInputService:GetMouseLocation()
                if holdingSV then
                    local p, sz = SVBase.AbsolutePosition, SVBase.AbsoluteSize
                    s = math.clamp((mp.X - p.X) / sz.X, 0, 1)
                    v = 1 - math.clamp((mp.Y - p.Y) / sz.Y, 0, 1)
                    Sync()
                elseif holdingH then
                    local p, sz = HueBar.AbsolutePosition, HueBar.AbsoluteSize
                    h = math.clamp((mp.Y - p.Y) / sz.Y, 0, 1)
                    Sync()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    holdingSV = false; holdingH = false
                end
            end)

            HexInput.FocusLost:Connect(function()
                local hex = HexInput.Text:gsub("#",""):sub(1,6)
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2),16)
                    local g = tonumber(hex:sub(3,4),16)
                    local b = tonumber(hex:sub(5,6),16)
                    if r and g and b then
                        currentColor = Color3.fromRGB(r,g,b)
                        h,s,v = Color3.toHSV(currentColor)
                        Sync()
                    end
                end
            end)

            local OpenBtn = New("TextButton", {
                Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, Text="", ZIndex=10, Parent=Frame,
            })
            OpenBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Panel.Visible = isOpen
                Wrapper.Size = UDim2.new(1,0,0, isOpen and 32+PH+4 or 32)
            end)
            OpenBtn.MouseEnter:Connect(function() Tween(Frame,{BackgroundColor3=Theme.ElementHover}) end)
            OpenBtn.MouseLeave:Connect(function() Tween(Frame,{BackgroundColor3=Theme.ElementBg}) end)

            return {
                GetValue=function() return currentColor end,
                SetValue=function(_,c)
                    currentColor=c; h,s,v=Color3.toHSV(c); Sync()
                end,
                Destroy=function() Wrapper:Destroy() end,
            }
        end

        return Tab
    end

    return Window
end

--[[
════════════════════════════════════════════════
  USAGE EXAMPLE
════════════════════════════════════════════════

local OnetapUI = loadstring(game:HttpGet("YOUR_URL"))()

local Win = OnetapUI:CreateWindow({
    Title    = "onetap",
    Subtitle = "v1.0 | lua",
    Width    = 560,
    Height   = 420,
})
-- Right Shift toggles by default. Override:
-- Win:SetKeybind(Enum.KeyCode.Insert)

local Aimbot = Win:CreateTab({ Name = "Aimbot", Icon = "⊕" })
Aimbot:AddLabel("Configure aim settings below.")
Aimbot:AddSeparator("GENERAL")
Aimbot:AddToggle({ Name="Enable Aimbot", Default=false, Callback=function(v) print(v) end })
Aimbot:AddSlider({ Name="FOV", Min=1, Max=360, Default=90, Suffix="°", Callback=function(v) print(v) end })
Aimbot:AddSlider({ Name="Smoothing", Min=0, Max=100, Default=30, Suffix="%" })
Aimbot:AddSeparator("TARGET")
Aimbot:AddDropdown({ Name="Target Bone", Options={"Head","Neck","Chest","Pelvis"}, Default="Head" })
Aimbot:AddSeparator()
Aimbot:AddButton({ Name="Reset Settings", Callback=function() print("reset") end })

local Visuals = Win:CreateTab({ Name = "Visuals", Icon = "◈" })
Visuals:AddToggle({ Name="ESP Boxes",    Default=true  })
Visuals:AddToggle({ Name="ESP Tracers",  Default=false })
Visuals:AddToggle({ Name="ESP Healthbars", Default=true })
Visuals:AddSeparator("COLORS")
Visuals:AddColorPicker({ Name="ESP Color",      Default=Color3.fromRGB(220,60,60) })
Visuals:AddColorPicker({ Name="Skeleton Color", Default=Color3.fromRGB(255,255,255) })

local Misc = Win:CreateTab({ Name = "Misc", Icon = "≡" })
Misc:AddToggle({ Name="Fly",        Default=false })
Misc:AddSlider({ Name="Walk Speed", Min=16, Max=200, Default=16, Suffix=" ws" })
Misc:AddButton({ Name="Rejoin", Callback=function() end })

════════════════════════════════════════════════
--]]

return OnetapUI
