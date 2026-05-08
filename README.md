# 🔥 Ember UI Library

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.9-f0a64b?style=for-the-badge)
![Roblox](https://img.shields.io/badge/platform-Roblox-e8e9ec?style=for-the-badge)
![Lua](https://img.shields.io/badge/language-Lua-2a2c31?style=for-the-badge)

**A clean, modern, fully-featured UI library for Roblox exploit menus.**
Drag-and-drop window system · Live theme engine · 6 component types · Notification toasts

</div>

---

## Table of Contents

- [Overview](#overview)
- [Loading the Library](#loading-the-library)
- [Quick Start — Full Example](#quick-start--full-example)
- [Building the Menu](#building-the-menu)
  - [CreateWindow](#createwindow)
  - [CreateTab](#createtab)
  - [CreateSection](#createsection)
- [Components Reference](#components-reference)
  - [AddToggle](#addtoggle)
  - [AddSlider](#addslider)
  - [AddDropdown](#adddropdown)
  - [AddButton](#addbutton)
  - [AddLabel](#addlabel)
  - [AddColorPicker](#addcolorpicker)
  - [AddSeparator](#addseparator)
- [Notifications](#notifications)
- [Theme System](#theme-system)
- [Controls API (Return Values)](#controls-api-return-values)
- [Keybind](#keybind)
- [Bug Fixes & Known Issues](#bug-fixes--known-issues)
- [Troubleshooting Guide](#troubleshooting-guide)

---

## Overview

Ember is a dark-themed, orange-accented UI library designed for Roblox exploit scripts. It runs entirely inside `CoreGui` using a **single ScreenGui**, which avoids the input-bleed problems that plague dual-ScreenGui designs.

**What Ember gives you out of the box:**

- Draggable, resizable-style window with a title bar, subtitle, and tab navigation
- Two-column section layout per tab — sections auto-alternate left/right or you pin them
- Six fully interactive component types: Toggle, Slider, Dropdown, Button, Label, ColorPicker
- A live theme registry — call `SetTheme()` once and every element across all tabs updates instantly
- Toast-style notification system with success / error / info variants
- INSERT key to show/hide the window
- Smooth Quart easing on all transitions, with a Back bounce on notifications
- Shared dropdown overlay with a Modal sink that blocks all underlying input

---

## Loading the Library

Ember is loaded via `loadstring` and `HttpGet`. Paste this at the top of your script:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RbxCheats/UiLib2/main/Library.lua"))()
```

### How `loadstring` works

`game:HttpGet(url)` fetches the raw Lua source from GitHub as a string. `loadstring()` compiles that string into an executable Lua chunk and returns it as a function. The trailing `()` calls that function, which runs the library and returns the `Ember` table. You store it in `Library` (or any variable name you like).

> **Important:** `HttpGet` requires **Allow HTTP Requests** to be enabled in your executor settings. Most exploits have this on by default.

### If the library fails to load

| Symptom | Cause | Fix |
|---|---|---|
| `attempt to call nil` on the `loadstring` line | HTTP request failed — the URL returned nothing | Check your executor's HTTP setting; try the URL in a browser to confirm it's reachable |
| `Script '' Line 1` syntax error | You got an HTML error page instead of Lua (GitHub was down or URL is wrong) | Print the raw response: `print(game:HttpGet(url))` to inspect what you actually received |
| Old version still running after re-executing | Roblox caches HTTP responses in some executors | Append a dummy query string: `game:HttpGet(url .. "?v=" .. os.time())` to force a fresh fetch |
| `EmberUI` GUI already exists error | Previous run didn't fully clean up | The library auto-destroys any existing `EmberUI` on load — if it still fails, call `game:GetService("CoreGui").EmberUI:Destroy()` manually before re-executing |

### Verifying the correct version is loaded

After loading, print the version to confirm:

```lua
print("Ember version:", Library:GetVersion())
-- Should print: Ember version: 1.0.9
```

If this prints an older version number, your executor is serving a cached response. Use the cache-bust trick above.

---

## Quick Start — Full Example

This is a complete working script showing every feature in one place:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RbxCheats/UiLib2/main/Library.lua"))()

-- 1. Create the window
local Window = Library:CreateWindow({
    Title    = "My Cheat",
    Subtitle = "v1.0",
    Width    = 780,
    Height   = 520,
})

-- 2. Create a tab
local Tab = Window:CreateTab("Combat")

-- 3. Create sections inside the tab
local LeftSection  = Tab:CreateSection("Aimbot",  "left")
local RightSection = Tab:CreateSection("Visuals", "right")

-- 4. Add components
local AimbotToggle = LeftSection:AddToggle({
    Label    = "Enable Aimbot",
    Default  = false,
    Callback = function(state)
        print("Aimbot:", state)
    end,
})

local FovSlider = LeftSection:AddSlider({
    Label    = "FOV",
    Min      = 10,
    Max      = 360,
    Default  = 90,
    Suffix   = "°",
    Step     = 1,
    Callback = function(value)
        print("FOV set to:", value)
    end,
})

local TeamDropdown = RightSection:AddDropdown({
    Label    = "Target Team",
    Items    = {"All", "Enemies", "Friendlies"},
    Default  = "Enemies",
    Callback = function(selected)
        print("Target:", selected)
    end,
})

local ESPToggle = RightSection:AddToggle({
    Label   = "ESP Boxes",
    Default = true,
    Callback = function(state) end,
})

local ColorPicker = RightSection:AddColorPicker({
    Label    = "ESP Color",
    Default  = Color3.fromRGB(255, 50, 50),
    Callback = function(color)
        print("Color:", color)
    end,
})

-- 5. Send a notification
Library:Notify({
    Title   = "Loaded",
    Message = "My Cheat has been injected successfully.",
    Type    = "success",
    Duration = 5,
})
```

---

## Building the Menu

### CreateWindow

The window is the root container for everything. Create it first.

```lua
local Window = Library:CreateWindow({
    Title    = "Window Title",   -- string  — shown in the title bar
    Subtitle = "v1.0",           -- string  — shown dimmed next to the title (optional)
    Width    = 780,              -- number  — window width in pixels  (default 780)
    Height   = 520,              -- number  — window height in pixels (default 520)
})
```

- The window spawns centred on screen.
- It is **draggable** by clicking and holding the title bar.
- Press **INSERT** to toggle visibility at any time.
- The `INSERT` hint badge is shown in the top-right of the title bar.

---

### CreateTab

Tabs appear in the horizontal scrollable tab bar below the title bar. You can have as many tabs as you need — the bar scrolls horizontally if they overflow.

```lua
local Tab = Window:CreateTab("Tab Label")
```

- The first tab created is selected automatically.
- Clicking a tab animates the accent underline indicator and switches content.
- Opening a color picker on one tab then switching to another tab **automatically closes** the picker.

---

### CreateSection

Sections are cards inside a tab. Each tab has two columns. Sections alternate left/right automatically, or you can force a specific column.

```lua
-- Auto-assign (alternates left → right → left → right …)
local Section = Tab:CreateSection("Section Title")

-- Force left column
local Section = Tab:CreateSection("Section Title", "left")

-- Force right column
local Section = Tab:CreateSection("Section Title", "right")
```

- Section titles are displayed in ALL CAPS in the accent colour.
- A hairline separator runs below the title.
- The card grows vertically to fit all elements added to it.
- You can add an unlimited number of sections per tab.

---

## Components Reference

All components are methods on a **Section** object. Every component accepts an options table and returns a **control object** you can use to read or set its value programmatically.

---

### AddToggle

A sliding pill toggle switch.

```lua
local ctrl = Section:AddToggle({
    Label    = "My Toggle",   -- string   — label shown to the left
    Default  = false,         -- boolean  — starting state (default false)
    Callback = function(state)
        -- state is true or false
        print("Toggle is now:", state)
    end,
})
```

**Control methods:**

```lua
ctrl:Set(true)   -- programmatically set the toggle (does NOT fire the callback)
ctrl:Get()       -- returns current boolean state
```

**Visual:** Orange when on, dark grey when off. The knob slides smoothly between positions.

---

### AddSlider

A draggable horizontal slider with a live value readout.

```lua
local ctrl = Section:AddSlider({
    Label    = "Walk Speed",  -- string  — label shown above the slider
    Min      = 0,             -- number  — minimum value (default 0)
    Max      = 100,           -- number  — maximum value (default 100)
    Default  = 16,            -- number  — starting value (default = Min)
    Step     = 1,             -- number  — snapping increment (default 1)
    Suffix   = " studs/s",   -- string  — appended to the value display (default "")
    Callback = function(value)
        print("Speed:", value)
    end,
})
```

**Control methods:**

```lua
ctrl:Set(50)   -- set the slider to a value (clamped to Min/Max automatically)
ctrl:Get()     -- returns current number value
```

**Tips:**
- Use `Step = 0.1` for decimal precision.
- The value readout on the right updates live while dragging.
- Clicking anywhere on the track (not just the thumb) jumps to that position.

---

### AddDropdown

A pill-style button that opens a popover list when clicked.

```lua
local ctrl = Section:AddDropdown({
    Label    = "Game Mode",               -- string        — label above the button
    Items    = {"Peaceful", "Normal", "Hard"},  -- table of strings — the list options
    Default  = "Normal",                  -- string        — initially selected item
    Callback = function(selected)
        print("Selected:", selected)
    end,
})
```

**Control methods:**

```lua
ctrl:Set("Hard")   -- programmatically change the selected item
ctrl:Get()         -- returns the currently selected string
```

**How the dropdown works internally:**

Ember uses a single shared **DropSink** — a full-screen invisible `TextButton` with `Modal = true`. When a dropdown opens, the sink becomes visible and sits above all other UI at `ZIndex 200`. The `Modal` property tells Roblox to route **all** mouse input to the sink first, which means clicking outside the list (on the sink background) closes the dropdown without accidentally clicking any button beneath it. Only one dropdown can be open at a time; opening a second one automatically closes the first.

**Tips:**
- Items can be any list of strings — there is no length limit.
- If there are more than 6 items the list becomes scrollable.
- The currently selected item shows an orange accent bar on its left edge.

---

### AddButton

A clickable button. Supports three style variants and an optional subtitle.

```lua
Section:AddButton({
    Label    = "Teleport to Spawn",         -- string  — main button text
    SubLabel = "Resets your position",      -- string  — smaller text below (optional)
    Style    = "default",                   -- string  — "default" | "success" | "danger"
    Callback = function()
        print("Button clicked!")
    end,
})
```

**Style variants:**

| Style | Appearance | Use case |
|---|---|---|
| `"default"` | Dark grey with white text | General actions |
| `"success"` | Green with white text | Confirmations, safe actions |
| `"danger"` | Red with white text | Destructive or risky actions |

**Visual:** The button darkens on hover and presses in on click with a smooth tween.

> AddButton does **not** return a control object — buttons are fire-and-forget.

---

### AddLabel

A static, non-interactive text block for instructions or status text.

```lua
Section:AddLabel({
    Text  = "Aim at a player before enabling.",   -- string       — the text content
    Color = Color3.fromRGB(154, 157, 166),        -- Color3       — text colour (optional, defaults to TextSecondary)
})
```

- Text wraps automatically.
- Use labels as hints, warnings, or section descriptions.
- You can use `Color3.fromRGB()` or any `Color3` value for custom colour.

> AddLabel does **not** return a control object.

---

### AddColorPicker

An inline HSV color picker with a saturation/value square, hue bar, hex input, and RGB readout.

```lua
local ctrl = Section:AddColorPicker({
    Label    = "Highlight Color",
    Default  = Color3.fromRGB(240, 166, 75),   -- Color3  — starting color
    Callback = function(color)
        -- color is a Color3 value
        print("Hex:", string.format("#%02X%02X%02X",
            math.floor(color.R * 255),
            math.floor(color.G * 255),
            math.floor(color.B * 255)))
    end,
})
```

**Control methods:**

```lua
ctrl:Set(Color3.fromRGB(255, 0, 0))   -- set the color programmatically
ctrl:Get()                             -- returns current Color3 value
```

**How to use the picker:**

1. Click the **colour swatch** (small rectangle to the right of the label) to open/close the picker panel.
2. Click and drag inside the **large square** to change saturation (left/right) and value/brightness (up/down).
3. Click and drag the **vertical rainbow bar** to change the hue.
4. Type a 6-digit hex code into the **HEX field** and press Enter/click away to apply.
5. The **R G B** readouts update live and show 0–255 values.
6. Switching to another tab **automatically closes** any open picker.

---

### AddSeparator

A thin horizontal line to visually divide groups of elements within a section.

```lua
Section:AddSeparator()
```

No options, no return value. Use it between logical groups of toggles or sliders to add visual breathing room.

---

## Notifications

Send floating toast notifications from anywhere in your script:

```lua
Library:Notify({
    Title    = "Alert",            -- string  — bold heading
    Message  = "Something happened.",  -- string  — body text (wraps)
    Type     = "info",             -- string  — "info" | "success" | "error"
    Duration = 4,                  -- number  — seconds before auto-dismiss (default 4)
})
```

**Type variants:**

| Type | Accent colour | Use for |
|---|---|---|
| `"info"` | Orange (accent) | General messages |
| `"success"` | Green | Successful operations |
| `"error"` | Red | Errors or failures |

**Behaviour:**
- Notifications stack vertically in the bottom-right corner of the screen.
- Each one slides in with a Back bounce animation and slides out after its duration.
- Multiple notifications can be on screen simultaneously.
- They are completely separate from the main window and appear even when the window is hidden.

---

## Theme System

Ember has a live theme registry. Every UI element registers itself against a theme key. Calling `SetTheme()` instantly updates all registered elements across every tab and section without rebuilding anything.

```lua
Library:SetTheme({
    Accent     = Color3.fromHex("ff6b6b"),   -- changes accent color everywhere
    Background = Color3.fromHex("111214"),
    Surface    = Color3.fromHex("1e2024"),
})
```

**All available theme keys:**

| Key | Default | Affects |
|---|---|---|
| `Background` | `#1e1f23` | Window background |
| `Surface` | `#2a2c31` | Section cards, title bar |
| `SurfaceHover` | `#32353b` | Hovered interactive surfaces |
| `SurfaceActive` | `#22242a` | Pressed/active surfaces, dropdown pill |
| `Border` | `#3a3d44` | Card outlines, strokes |
| `Accent` | `#f0a64b` | Tab indicators, slider fill, toggle on, section headers |
| `TextPrimary` | `#e8e9ec` | Labels, slider values, element text |
| `TextSecondary` | `#9a9da6` | Inactive tab labels, dropdown label |
| `TextDisabled` | `#5a5d66` | INSERT hint, colour picker channel labels |
| `Success` | `#4caf8a` | Success notification border, success button |
| `Danger` | `#e05c5c` | Error notification border, danger button |
| `SliderTrack` | `#1a1b1f` | Slider track background |
| `ScrollBar` | `#3a3d44` | Scroll bar thumb colour |
| `ToggleOff` | `#3a3d44` | Toggle track when disabled |
| `ToggleOn` | `#f0a64b` | Toggle track when enabled (mirrors Accent) |
| `DropdownBg` | `#1c1d21` | Dropdown popover background |
| `DropdownItem` | `#1c1d21` | Dropdown row background |
| `DropdownHover` | `#2a2c31` | Dropdown row hover background |
| `Separator` | `#35383f` | Separator lines |

**Reading the current theme:**

```lua
local theme = Library:GetTheme()
print(theme.Accent)   -- Color3 value
```

> **Note:** Setting `Accent` automatically updates `ToggleOn` to match so active toggles stay consistent with the accent colour.

---

## Controls API (Return Values)

`AddToggle`, `AddSlider`, `AddDropdown`, and `AddColorPicker` all return a **control object**. Save these if you need to read or change values from outside a callback:

```lua
local speedCtrl  = Section:AddSlider({ Label="Speed", Min=0, Max=100, Default=16 })
local aimbotCtrl = Section:AddToggle({ Label="Aimbot", Default=false })
local colorCtrl  = Section:AddColorPicker({ Label="Color" })
local modeCtrl   = Section:AddDropdown({ Label="Mode", Items={"A","B","C"} })

-- Later, in a loop or another callback:
print(speedCtrl:Get())   -- 16
speedCtrl:Set(50)        -- set to 50, does NOT fire callback

aimbotCtrl:Set(true)     -- silently turn aimbot on
print(aimbotCtrl:Get())  -- true

colorCtrl:Set(Color3.fromRGB(0, 255, 128))
print(colorCtrl:Get())   -- Color3 value

modeCtrl:Set("B")
print(modeCtrl:Get())    -- "B"
```

> `:Set()` on any control **never fires the Callback**. It only updates the internal value and the visual state. If you need to fire the callback manually, call it directly.

---

## Keybind

The window toggles with the **INSERT** key by default. This is hardcoded in the library. You can add your own secondary toggle by calling `win:Toggle()`:

```lua
local Window = Library:CreateWindow({ Title = "My Menu" })

-- Toggle with a custom key (e.g. RightShift)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Window:Toggle()
    end
end)
```

---

## Bug Fixes & Known Issues

This section documents every bug found and fixed in the library, and how each was resolved.

---

### Bug 1 — `attempt to perform arithmetic (unm) on boolean` in `openDropdown`

**Error message:**
```
attempt to perform arithmetic (unm) on boolean
Stack Begin
Script '', Line 236 - function openDropdown
Script '', Line 565
Stack End
```

**Root cause:**

Inside the dropdown item builder, the label size was written as:
```lua
Size = UDim2.new(1, -isSel and 20 or 14, 1, 0)
```

Lua's unary minus operator (`-`) binds **more tightly** than `and`, so this was parsed as:
```lua
(-isSel) and 20 or 14   -- tries to negate the boolean isSel → crash
```

**Fix:**

Wrap the conditional in parentheses so it evaluates first:
```lua
Size = UDim2.new(1, -(isSel and 20 or 14), 1, 0)
```

---

### Bug 2 — Stale `DropSink.MouseButton1Click` connections accumulating

**Symptom:** After opening and closing the dropdown several times, clicking elsewhere would trigger multiple close events simultaneously, causing visual glitches and the sink staying visible.

**Root cause:**

Every call to `openDropdown()` was doing:
```lua
DropSink.MouseButton1Click:Connect(function()
    if _openClose == close then close() end
end)
```

This added a **new connection on every open**. After 10 opens, 10 handlers were firing on every click.

**Fix:**

Wire a single persistent connection at startup that delegates to whatever `_openClose` is currently set to:
```lua
-- Runs once, at the top level — never inside openDropdown()
DropSink.MouseButton1Click:Connect(function()
    if _openClose then _openClose() end
end)
```

---

### Bug 3 — `AddToggle` `regFn` mutating the global `Theme.ToggleOn`

**Symptom:** After calling `SetTheme({ Accent = ... })`, every toggle that had previously been turned on would permanently use the old colour. New toggles created after the theme change would use a mix of old and new values.

**Root cause:**

The theme registration callback was:
```lua
regFn("Accent", function(newAccent)
    Theme.ToggleOn = newAccent   -- ← mutates the global theme table
    if state then Track.BackgroundColor3 = newAccent end
end)
```

This overwrote `Theme.ToggleOn` as a side effect, causing race conditions with other toggles.

**Fix:**

Remove the mutation — just apply the colour directly to this toggle's track:
```lua
regFn("Accent", function(newAccent)
    if state then Track.BackgroundColor3 = newAccent end
end)
```

`Theme.ToggleOn` is still updated correctly inside `SetTheme()` itself.

---

### Bug 4 — Hue bar gradient rendering incorrectly

**Symptom:** The vertical hue bar in the colour picker showed a distorted or sideways rainbow.

**Root cause:**

`UIGradient.Rotation = 0` in Roblox runs the gradient **left to right** (along the X axis). The hue bar is vertical, so it needs the gradient to run **top to bottom** (along the Y axis), which requires `Rotation = 90`.

Additionally, using only 7 keypoints caused Roblox's RGB interpolation to produce washed-out, inaccurate mid-colours between hue stops.

**Fix:**

Set `Rotation = 90` and use the 7 mathematically exact HSV hue-segment keypoints:
```lua
local stops = {
    ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6, 1, 1)), -- red
    ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)), -- yellow
    ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)), -- green
    ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)), -- cyan
    ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)), -- blue
    ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)), -- magenta
    ColorSequenceKeypoint.new(6/6, Color3.fromHSV(0,   1, 1)), -- red (wrap)
}
```

> **Why not more keypoints?** Roblox's `ColorSequence` has a hard limit of **20 keypoints**. Exceeding it throws `ColorSequence.new(): table is too long`. 7 keypoints are both sufficient and well within the limit.

---

## Troubleshooting Guide

### The menu doesn't appear after executing

1. Check that your executor has **CoreGui access** — Ember parents everything to `CoreGui`. Some executors require a setting to enable this.
2. Run `print(Library)` after the loadstring line. If it prints `nil`, the HTTP request failed silently.
3. Make sure you're calling `Library:CreateWindow(...)` and assigning the result — the menu won't appear until a window is created.

---

### The menu appears but is invisible / fully transparent

Roblox can sometimes place new GUI objects behind the game's own CoreGui layers. Try setting a higher `DisplayOrder` on the ScreenGui. The library uses `999` by default which should be sufficient for most cases.

---

### Clicking components doesn't work

If clicks on buttons, toggles, or sliders aren't registering:

1. Make sure a dropdown is not open — while a dropdown is open, the full-screen sink blocks all input beneath it. Click elsewhere to close it first.
2. Check if another GUI (from the game or another script) is sitting on top. Use the Roblox Explorer in a development environment to inspect the GUI hierarchy.

---

### `attempt to index nil with 'CreateTab'` or similar

You forgot to store the return value of `CreateWindow`:

```lua
-- Wrong:
Library:CreateWindow({ Title = "Test" })
local Tab = Window:CreateTab("Tab")   -- Window is nil!

-- Correct:
local Window = Library:CreateWindow({ Title = "Test" })
local Tab = Window:CreateTab("Tab")
```

The same applies to `CreateTab` → `CreateSection` and `CreateSection` → `AddToggle` etc. Every call in the chain returns the next object — always store it.

---

### `ColorSequence.new(): table is too long`

You have added more than 20 keypoints to a `ColorSequence`. Roblox's hard cap is **20 keypoints**. This error was triggered internally during development when the hue gradient used too many stops. The library itself is fixed, but if you are building custom gradients elsewhere in your script, keep keypoint count at 20 or below.

---

### The dropdown list appears in the wrong position

The dropdown popover positions itself using `AbsolutePosition` and `AbsoluteSize` from the pill button, which are only valid **after** the element has been rendered to screen for at least one frame. If you are programmatically opening dropdowns immediately on load (before the first render), wrap the call in a `task.wait()`:

```lua
task.wait()   -- let the UI render one frame
myDropdown:Set("Option A")
```

---

### Re-executing the script causes duplicate GUIs or errors

The library destroys any existing `EmberUI` ScreenGui at the top of `Library.lua`. If you see duplicates or errors on re-execute:

1. Manually destroy the old GUI before re-running: open the executor console and run `game:GetService("CoreGui").EmberUI:Destroy()`.
2. Or add this before your loadstring:
```lua
pcall(function()
    game:GetService("CoreGui").EmberUI:Destroy()
end)
task.wait(0.1)  -- give it a moment to fully clean up
local Library = loadstring(game:HttpGet("..."))()
```

---

### Callbacks firing unexpectedly on load

Callbacks are **not fired** when you pass a `Default` value — they only fire on user interaction or when `:Set()` is not the trigger (buttons use `MouseButton1Up`). If your callback is firing on load, check that you haven't called `:Set()` after creating the element, or that another script isn't interacting with the GUI.

---

<div align="center">

Made with 🔥 by RbxCheats &nbsp;·&nbsp; Ember UI v1.0.9

</div>
