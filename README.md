# OnetapUI
> A sleek, onetap-inspired Roblox UI library with full loadstring support.

![Theme](https://img.shields.io/badge/theme-onetap-dc3c3c?style=flat-square)
![Lua](https://img.shields.io/badge/language-Lua-blue?style=flat-square)
![Roblox](https://img.shields.io/badge/platform-Roblox-red?style=flat-square)

---

## Table of Contents

- [Loading the Library](#loading-the-library)
- [Creating a Window](#creating-a-window)
- [Creating Tabs](#creating-tabs)
- [Elements](#elements)
  - [Label](#label)
  - [Separator](#separator)
  - [Button](#button)
  - [Toggle](#toggle)
  - [Slider](#slider)
  - [Dropdown](#dropdown)
  - [Color Picker](#color-picker)
- [Keybind (Show/Hide)](#keybind-showhide)
- [Full Example Script](#full-example-script)
- [Q & A](#q--a)

---

## Loading the Library

Paste this at the **top of your script** before anything else. Replace the URL with the raw link to your hosted `OnetapUI.lua` file (GitHub raw, Pastebin, etc.).

```lua
local OnetapUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOU/REPO/main/OnetapUI.lua"))()
```

> **Tip:** `game:HttpGet` requires **HTTP Requests** to be enabled in your executor. Most executors have this on by default.

---

## Creating a Window

The window is the root container for everything. Create it once at the top of your script.

```lua
local Window = OnetapUI:CreateWindow({
    Title    = "onetap",    -- Big header text
    Subtitle = "v1.0",      -- Smaller text next to the title
    Width    = 560,         -- Window width in pixels (default: 560)
    Height   = 420,         -- Window height in pixels (default: 420)
})
```

| Option | Type | Description |
|--------|------|-------------|
| `Title` | string | Main title shown in the header |
| `Subtitle` | string | Smaller text shown beside the title |
| `Width` | number | Width of the window (optional) |
| `Height` | number | Height of the window (optional) |

The window is **draggable** by clicking and holding the header bar.

---

## Creating Tabs

Tabs appear as buttons in the left sidebar. You can create as many as you need. The first tab created is automatically selected.

```lua
local AimbotTab = Window:CreateTab({
    Name = "Aimbot",   -- Text shown on the tab button
    Icon = "⊕",        -- Optional icon before the name (any unicode character)
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "◈",
})

local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "≡",
})
```

| Option | Type | Description |
|--------|------|-------------|
| `Name` | string | Label on the tab button |
| `Icon` | string | Unicode icon (optional) |

> All elements below are called **on a tab**, not on the window directly.

---

## Elements

### Label

A simple read-only line of dimmed text. Good for descriptions or section info.

```lua
AimbotTab:AddLabel("Configure your aim settings below.")
```

**Returned methods:**

```lua
local myLabel = AimbotTab:AddLabel("Hello")

myLabel:SetText("Updated text")  -- Change the label text at any time
myLabel:Destroy()                -- Remove the label from the UI
```

---

### Separator

A horizontal dividing line. Optionally shows a short title inline.

```lua
-- Plain line
AimbotTab:AddSeparator()

-- Line with a section title
AimbotTab:AddSeparator("GENERAL")
```

**Returned methods:**

```lua
local sep = AimbotTab:AddSeparator("SECTION")
sep:Destroy()  -- Remove the separator
```

---

### Button

A clickable row that runs a function when pressed.

```lua
AimbotTab:AddButton({
    Name     = "Reset Settings",
    Callback = function()
        print("Button was clicked!")
    end,
})
```

| Option | Type | Description |
|--------|------|-------------|
| `Name` | string | Text shown on the button |
| `Callback` | function | Called when the button is clicked |

**Returned methods:**

```lua
local btn = AimbotTab:AddButton({ Name = "Go", Callback = function() end })

btn:SetText("New Label")  -- Change button text
btn:Destroy()             -- Remove the button
```

---

### Toggle

An on/off switch. Fires its callback every time the state changes.

```lua
AimbotTab:AddToggle({
    Name     = "Enable Aimbot",
    Default  = false,               -- Starting state (true = on, false = off)
    Callback = function(value)
        print("Aimbot is now:", value)  -- value is true or false
    end,
})
```

| Option | Type | Description |
|--------|------|-------------|
| `Name` | string | Label shown next to the toggle |
| `Default` | boolean | Starting value (`false` by default) |
| `Callback` | function | Called with `true`/`false` when toggled |

**Returned methods:**

```lua
local myToggle = AimbotTab:AddToggle({ Name = "Fly", Default = false })

myToggle:SetValue(true)   -- Turn on programmatically
myToggle:GetValue()       -- Returns current state (true/false)
myToggle:Destroy()        -- Remove the toggle
```

---

### Slider

A draggable slider for numeric values between a min and max.

```lua
AimbotTab:AddSlider({
    Name     = "FOV",
    Min      = 1,
    Max      = 360,
    Default  = 90,
    Suffix   = "°",                  -- Shown after the number (optional)
    Callback = function(value)
        print("FOV set to:", value)  -- value is a whole number
    end,
})
```

| Option | Type | Description |
|--------|------|-------------|
| `Name` | string | Label shown above the slider |
| `Min` | number | Minimum value |
| `Max` | number | Maximum value |
| `Default` | number | Starting value |
| `Suffix` | string | Text appended to the value display (e.g. `"°"`, `"%"`, `" ms"`) |
| `Callback` | function | Called with the new number when dragged |

**Returned methods:**

```lua
local mySlider = AimbotTab:AddSlider({ Name = "Speed", Min = 0, Max = 100, Default = 50 })

mySlider:SetValue(75)   -- Set the slider position programmatically
mySlider:GetValue()     -- Returns the current number
mySlider:Destroy()      -- Remove the slider
```

---

### Dropdown

A collapsible list where the user picks one option.

```lua
AimbotTab:AddDropdown({
    Name     = "Target Bone",
    Options  = { "Head", "Neck", "Chest", "Pelvis" },
    Default  = "Head",
    Callback = function(selected)
        print("Selected:", selected)
    end,
})
```

| Option | Type | Description |
|--------|------|-------------|
| `Name` | string | Label shown on the left |
| `Options` | table | List of string choices |
| `Default` | string | Which option starts selected |
| `Callback` | function | Called with the chosen string when changed |

**Returned methods:**

```lua
local myDrop = AimbotTab:AddDropdown({
    Name    = "Mode",
    Options = { "Silent", "Legit", "Rage" },
    Default = "Legit",
})

myDrop:SetValue("Rage")                         -- Select an option programmatically
myDrop:GetValue()                               -- Returns the currently selected string
myDrop:SetOptions({ "Option A", "Option B" })   -- Replace the entire options list
myDrop:Destroy()                                -- Remove the dropdown
```

---

### Color Picker

A collapsible color picker with an HSV square, hue bar, and hex input.

```lua
VisualsTab:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(220, 60, 60),
    Callback = function(color)
        -- color is a Color3 value
        print("R:", color.R, "G:", color.G, "B:", color.B)
    end,
})
```

| Option | Type | Description |
|--------|------|-------------|
| `Name` | string | Label shown on the left |
| `Default` | Color3 | Starting color |
| `Callback` | function | Called with the new `Color3` whenever color changes |

**Returned methods:**

```lua
local myPicker = VisualsTab:AddColorPicker({
    Name    = "Chams Color",
    Default = Color3.fromRGB(255, 255, 255),
})

myPicker:SetValue(Color3.fromRGB(0, 255, 0))  -- Set a new color programmatically
myPicker:GetValue()                           -- Returns the current Color3
myPicker:Destroy()                            -- Remove the color picker
```

> Click the element row to **expand** the picker panel. Click again to collapse it.

---

## Keybind (Show/Hide)

Bind a key to toggle the entire UI on and off.

```lua
Window:SetKeybind(Enum.KeyCode.RightControl)
-- Press Right Ctrl in-game to show/hide the window
```

Pass any valid `Enum.KeyCode`. Common choices:

| Key | Code |
|-----|------|
| Right Control | `Enum.KeyCode.RightControl` |
| Insert | `Enum.KeyCode.Insert` |
| End | `Enum.KeyCode.End` |
| F1–F12 | `Enum.KeyCode.F1` … `Enum.KeyCode.F12` |

---

## Full Example Script

Copy-paste ready. Just swap in your hosted URL.

```lua
-- Load the library
local OnetapUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOU/REPO/main/OnetapUI.lua"))()

-- Create window
local Window = OnetapUI:CreateWindow({
    Title    = "onetap",
    Subtitle = "v1.0 | lua",
    Width    = 560,
    Height   = 420,
})

-- Toggle show/hide with Right Ctrl
Window:SetKeybind(Enum.KeyCode.RightControl)

-- ══════════════════════════════════
--  AIMBOT TAB
-- ══════════════════════════════════
local Aimbot = Window:CreateTab({ Name = "Aimbot", Icon = "⊕" })

Aimbot:AddLabel("Configure your aim settings below.")
Aimbot:AddSeparator("GENERAL")

local aimbotEnabled = Aimbot:AddToggle({
    Name     = "Enable Aimbot",
    Default  = false,
    Callback = function(v)
        print("Aimbot:", v)
    end,
})

local fovSlider = Aimbot:AddSlider({
    Name     = "FOV",
    Min      = 1,
    Max      = 360,
    Default  = 90,
    Suffix   = "°",
    Callback = function(v)
        print("FOV:", v)
    end,
})

local smoothSlider = Aimbot:AddSlider({
    Name     = "Smoothing",
    Min      = 0,
    Max      = 100,
    Default  = 30,
    Suffix   = "%",
})

Aimbot:AddSeparator("TARGET")

local boneDropdown = Aimbot:AddDropdown({
    Name     = "Target Bone",
    Options  = { "Head", "Neck", "Chest", "Pelvis" },
    Default  = "Head",
    Callback = function(v)
        print("Bone:", v)
    end,
})

Aimbot:AddSeparator()

Aimbot:AddButton({
    Name     = "Reset to Defaults",
    Callback = function()
        aimbotEnabled:SetValue(false)
        fovSlider:SetValue(90)
        smoothSlider:SetValue(30)
        boneDropdown:SetValue("Head")
        print("Settings reset.")
    end,
})

-- ══════════════════════════════════
--  VISUALS TAB
-- ══════════════════════════════════
local Visuals = Window:CreateTab({ Name = "Visuals", Icon = "◈" })

Visuals:AddSeparator("ESP")

Visuals:AddToggle({
    Name     = "ESP Boxes",
    Default  = true,
    Callback = function(v) print("Boxes:", v) end,
})

Visuals:AddToggle({
    Name     = "ESP Tracers",
    Default  = false,
    Callback = function(v) print("Tracers:", v) end,
})

Visuals:AddToggle({
    Name     = "ESP Healthbars",
    Default  = true,
})

Visuals:AddSeparator("COLORS")

Visuals:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(220, 60, 60),
    Callback = function(color)
        print("Color R:", math.floor(color.R * 255))
    end,
})

Visuals:AddColorPicker({
    Name     = "Skeleton Color",
    Default  = Color3.fromRGB(255, 255, 255),
})

-- ══════════════════════════════════
--  MISC TAB
-- ══════════════════════════════════
local Misc = Window:CreateTab({ Name = "Misc", Icon = "≡" })

Misc:AddLabel("Miscellaneous options.")
Misc:AddSeparator("MOVEMENT")

Misc:AddToggle({ Name = "Fly",        Default = false })
Misc:AddToggle({ Name = "Speed Hack", Default = false })

Misc:AddSlider({
    Name    = "Walk Speed",
    Min     = 16,
    Max     = 200,
    Default = 16,
    Suffix  = " ws",
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})

Misc:AddSlider({
    Name    = "Jump Power",
    Min     = 7,
    Max     = 200,
    Default = 50,
    Suffix  = " jp",
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end,
})

Misc:AddSeparator()

Misc:AddButton({
    Name     = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
})
```

---

## Q & A

**Q: I get an error saying `HttpGet is not a valid member`.**

A: Your executor doesn't support `game:HttpGet`. Try `game:GetService("HttpService"):GetAsync(url)` instead, or paste the library code directly into your script without loadstring.

---

**Q: The window doesn't show up when I run the script.**

A: Make sure the library loaded successfully — wrap it in a pcall to check:
```lua
local ok, OnetapUI = pcall(function()
    return loadstring(game:HttpGet("YOUR_URL"))()
end)
if not ok then warn("Failed to load OnetapUI:", OnetapUI) end
```

---

**Q: How do I hide the menu on startup?**

A: After creating your window, set the root frame invisible:
```lua
local Window = OnetapUI:CreateWindow({ ... })
-- Access internal GUI and hide it immediately
Window._root.Visible = false
Window:SetKeybind(Enum.KeyCode.RightControl) -- toggle to show
```

---

**Q: My slider/toggle callback fires when I change it with SetValue. Is that intentional?**

A: Yes — `SetValue` always fires the callback so your game logic stays in sync. If you need to change a value silently, you can temporarily disconnect your callback or use an internal flag.

---

**Q: Can I have multiple windows?**

A: Yes. Each call to `OnetapUI:CreateWindow()` creates an independent window with its own ScreenGui. You can create as many as you need.

---

**Q: How do I change an element after creating it?**

A: All elements return an object with methods. Save the return value:
```lua
local myToggle = Tab:AddToggle({ Name = "Fly", Default = false })
-- Later...
myToggle:SetValue(true)
myToggle:GetValue() -- true
myToggle:Destroy()  -- removes it
```

---

**Q: Can I add elements to a tab after I've already switched to another tab?**

A: Yes. Tab content is always present in memory. You can call `Tab:AddButton(...)` at any time from anywhere in your script.

---

**Q: The color picker only shows a preview box, not the full panel.**

A: Click the element row to expand it. Click again to collapse it. This keeps the UI compact when you're not actively picking a color.

---

**Q: How do I destroy the entire UI?**

A: Call `Window:Destroy()`. This removes the ScreenGui and everything inside it.
```lua
Window:Destroy()
```

---

**Q: What executors is this compatible with?**

A: Any executor that supports `loadstring`, `game:HttpGet`, and standard Roblox Lua APIs. This includes Synapse X, KRNL, Fluxus, Solara, Wave, and most others. If an executor lacks `loadstring` support, paste the source code directly.

---

*Made with ❤️ — onetap aesthetic for Roblox.*
