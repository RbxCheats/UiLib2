# Ember UI Library

Ember UI Library is a Roblox UI framework for building clean in-game menus with windows, tabs, sections, and interactive controls.

## Version

Current version: 1.0.1

## Installation

Load the library with:

```lua
local Ember = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/EmberUI/main/Library.lua"))()
```

## Quick Start

```lua
local Ember = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/EmberUI/main/Library.lua"))()

local Window = Ember:CreateWindow({
    Title = "My Script",
    Subtitle = "v1.0",
    Width = 780,
    Height = 520
})

local Tab = Window:CreateTab("Home")
local Sec = Tab:CreateSection("General")

Sec:AddToggle({
    Label = "God Mode",
    Default = false,
    Callback = function(v)
        print("God Mode:", v)
    end
})

Sec:AddSlider({
    Label = "Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Callback = function(v)
        print("Speed:", v)
    end
})
```

## Main Features

- Draggable window.
- Minimize and close controls.
- Tab navigation.
- Two-column section layout.
- Auto-sized sections.
- Notifications.
- Theme overrides.
- Insert key to toggle visibility.

## Library Object

The library returns a root object named `Ember`.

### Methods

- `Ember:CreateWindow(opts)`
- `Ember:Notify(opts)`
- `Ember:SetTheme(overrides)`
- `Ember:GetTheme()`
- `Ember:GetVersion()`

### Theme Fields

The default theme includes:

- `Background`
- `Surface`
- `SurfaceHover`
- `SurfaceActive`
- `Border`
- `Accent`
- `AccentDark`
- `AccentGlow`
- `TextPrimary`
- `TextSecondary`
- `TextDisabled`
- `Success`
- `Danger`
- `SliderTrack`
- `ScrollBar`
- `ToggleOff`
- `ToggleOn`
- `DropdownBg`
- `DropdownItem`
- `DropdownHover`
- `Separator`

## CreateWindow

Creates a new main UI window.

```lua
local Window = Ember:CreateWindow({
    Title = "My Script",
    Subtitle = "v1.0",
    Width = 780,
    Height = 520
})
```

### Options

- `Title`: Window title text.
- `Subtitle`: Optional subtitle text.
- `Width`: Window width.
- `Height`: Window height.

### Behavior

- Automatically centers on screen.
- Adds title bar, tab bar, and content area.
- Includes close and minimize buttons.
- Supports dragging from the title bar.
- Press `Insert` to toggle window visibility.

## CreateTab

Creates a tab inside the window.

```lua
local Tab = Window:CreateTab("Home")
```

### Behavior

- Tabs are added to the tab bar.
- The first tab is selected automatically.
- Tab content is hidden until selected.

## CreateSection

Creates a section card inside a tab.

```lua
local Sec = Tab:CreateSection("General")
```

### Behavior

- Sections are placed in a two-column layout.
- If no column is specified, sections alternate left/right.
- Cards do not clip descendants, so dropdowns can overflow safely.

### Optional Column Argument

```lua
local LeftSec = Tab:CreateSection("Left", "left")
local RightSec = Tab:CreateSection("Right", "right")
```

## Section Controls

### AddToggle

Creates an on/off switch.

```lua
Sec:AddToggle({
    Label = "Enabled",
    Default = false,
    Callback = function(v)
        print(v)
    end
})
```

Returns a control object with:
- `Set(value)`
- `Get()`

### AddSlider

Creates a numeric slider.

```lua
Sec:AddSlider({
    Label = "Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Step = 1,
    Suffix = "",
    Callback = function(v)
        print(v)
    end
})
```

Returns a control object with:
- `Set(value)`
- `Get()`

### AddDropdown

Creates a dropdown selector.

```lua
Sec:AddDropdown({
    Label = "Mode",
    Items = {"Easy", "Normal", "Hard"},
    Default = "Normal",
    Callback = function(v)
        print(v)
    end
})
```

Returns a control object with:
- `Set(value)`
- `Get()`

### AddButton

Creates a clickable button.

```lua
Sec:AddButton({
    Label = "Run",
    SubLabel = "Executes the action",
    Style = "default",
    Callback = function()
        print("Clicked")
    end
})
```

### AddLabel

Creates a text-only label.

```lua
Sec:AddLabel({
    Text = "Status: Ready",
    Color = Color3.fromRGB(170, 170, 170)
})
```

### AddColorPicker

Creates a color picker.

```lua
Sec:AddColorPicker({
    Label = "Accent Color",
    Default = Color3.fromRGB(240, 166, 75),
    Callback = function(c)
        print(c)
    end
})
```

Returns a control object with:
- `Set(color)`
- `Get()`

### AddSeparator

Adds a thin divider line.

```lua
Sec:AddSeparator()
```

## Notification System

Show a notification with:

```lua
Ember:Notify({
    Title = "Notice",
    Message = "Action completed",
    Duration = 4,
    Type = "info"
})
```

### Notification Types

- `info`
- `success`
- `error`

## Visibility Controls

### Toggle

The UI can be shown or hidden with the Insert key.

### Minimize

The minimize button collapses the window to the title bar.

### Close

The close button destroys the UI.

## Implementation Notes

### Dragging

The title bar is draggable and moves the main root frame.

### Layout

Sections use `UIListLayout` and auto-size based on their content.

### Dropdowns

Dropdown lists are parented to `ScreenGui` so they can appear above clipping ancestors.

### Color Picker

The picker supports:
- SV square selection.
- Hue bar selection.
- Hex input.
- RGB display.

## Example Menu

```lua
local Ember = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/EmberUI/main/Library.lua"))()

local Window = Ember:CreateWindow({
    Title = "Example Menu",
    Subtitle = "Demo"
})

local Main = Window:CreateTab("Main")
local Player = Main:CreateSection("Player")
local Visual = Main:CreateSection("Visuals")

Player:AddToggle({
    Label = "Auto Farm",
    Default = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end
})

Player:AddSlider({
    Label = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Step = 1,
    Callback = function(v)
        print("Walk Speed:", v)
    end
})

Visual:AddDropdown({
    Label = "ESP Mode",
    Items = {"Box", "2D", "Tracers"},
    Default = "Box",
    Callback = function(v)
        print("ESP Mode:", v)
    end
})

Visual:AddColorPicker({
    Label = "ESP Color",
    Default = Color3.fromRGB(240, 166, 75),
    Callback = function(c)
        print("Color:", c)
    end
})
```

## Troubleshooting

### `CreateLabel` missing
Use `AddLabel` instead of `CreateLabel`.

### Dropdown clips behind other UI
This library already parents dropdowns to the `ScreenGui` to avoid clipping.

### Window does not open
Make sure the script runs in a client context and the `loadstring(game:HttpGet(...))()` call succeeds.

## License

MIT License.
