# NightSystem UI Library (1:1 Frosted-Glass Edition)

Eine vollständige, moderne **Frosted-Glass 3-Spalten Roblox UI Library** im 1:1 **NightSystem**-Design mit vertikalen Sidebar-Tabs, metallischen Sektion-Headern, abgerundeten Checkboxen, Slidern mit Skalenstrichen, Dropdowns, Colorpicker, Keybinds und vollem Scrolling-Support.

## 🚀 Schnellstart (`loadstring`)

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NightSyste/NightSystem-UI/main/NightSystemUI.lua"))()

local Window = Library:MakeWindow({
    Name = "NightSystem",
    ToggleKey = Enum.KeyCode.RightShift
})

-- Tabs erstellen (MakeTab / CreateTab / AddTab werden alle unterstützt)
local EspTab      = Window:MakeTab({ Name = "ESP" })
local VisualsTab  = Window:CreateTab({ Name = "Visuals" })
local AimbotTab   = Window:MakeTab({ Name = "Aimbot" })
local SettingsTab = Window:MakeTab({ Name = "Settings" })
local LuaTab      = Window:MakeTab({ Name = "Lua Script" })

-- Spalte 1: Player ESP
local Sec1 = EspTab:AddSection({ Name = "Player ESP" })
Sec1:AddToggle({
    Name = "Enable ESP",
    Default = true,
    Flag = "EnableESP",
    Callback = function(state)
        print("Enable ESP:", state)
    end
})
Sec1:AddSlider({
    Name = "Max Distance",
    Min = 50,
    Max = 1000,
    Default = 400,
    Increment = 10,
    ValueName = "m",
    Callback = function(val)
        print("Max Distance:", val)
    end
})

-- Spalte 2: Visuals & Effects
local Sec2 = EspTab:AddSection({ Name = "Visuals & Effects" })
Sec2:AddToggle({ Name = "Chams", Default = true })
Sec2:AddColorpicker({
    Name = "Color Picker",
    Default = Color3.fromRGB(130, 215, 250),
    Callback = function(color)
        print("Neue Farbe:", color)
    end
})
Sec2:AddSlider({
    Name = "Opacity",
    Min = 10,
    Max = 100,
    Default = 68,
    Ticks = true,
    Callback = function(val)
        Window:SetOpacity(val / 100)
    end
})

-- Spalte 3: Aimbot & Misc
local Sec3 = EspTab:AddSection({ Name = "Aimbot & Misc" })
Sec3:AddToggle({ Name = "Active", Default = true })
Sec3:AddToggle({ Name = "Silent Aim", Default = false })
Sec3:AddSlider({ Name = "FOV Radius", Min = 20, Max = 500, Default = 180 })
Sec3:AddDropdown({
    Name = "Hitbox",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Callback = function(selected)
        print("Hitbox:", selected)
    end
})
Sec3:AddApplyButton({
    Name = "Apply\nSettings",
    ResetName = "Reset",
    Callback = function()
        Library:MakeNotification({
            Name = "NightSystem",
            Content = "Settings applied!",
            Time = 3
        })
    end
})
```

## ✨ Unterstützte Methoden & Aliase

| Funktion | Unterstützte Aliase |
| :--- | :--- |
| **Window** | `Library:MakeWindow(...)`, `Library:CreateWindow(...)`, `Library:Window(...)` |
| **Tab** | `Window:MakeTab(...)`, `Window:CreateTab(...)`, `Window:AddTab(...)` |
| **Section / Spalte** | `Tab:AddSection(...)`, `Tab:CreateSection(...)`, `Tab:MakeSection(...)` |
| **Toggle / Checkbox** | `:AddToggle(...)`, `:CreateToggle(...)`, `:AddCheckbox(...)` (`Style = "Checkbox"` oder `"Switch"`) |
| **Slider** | `:AddSlider(...)`, `:CreateSlider(...)`, `:MakeSlider(...)` (`Ticks = true` für Skalenstriche) |
| **Dropdown** | `:AddDropdown(...)`, `:CreateDropdown(...)`, `:MakeDropdown(...)` |
| **Button** | `:AddButton(...)`, `:CreateButton(...)`, `:AddDualButton(...)`, `:AddApplyButton(...)` |
| **Colorpicker** | `:AddColorpicker(...)`, `:CreateColorPicker(...)` |
| **Keybind** | `:AddBind(...)`, `:CreateBind(...)`, `:AddKeybind(...)` |
| **Textbox** | `:AddTextbox(...)`, `:CreateTextbox(...)`, `:CreateInput(...)` |
| **Label & Paragraph** | `:AddLabel(...)`, `:AddParagraph(...)` |
| **Notifications** | `Library:MakeNotification(...)`, `Library:Notify(...)` |
