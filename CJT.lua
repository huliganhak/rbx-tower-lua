local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/source.lua"))()
local venyx = library.new("Venyx", 5013109572)

-- themes
local themes = {
Background = Color3.fromRGB(24, 24, 24),
Glow = Color3.fromRGB(0, 0, 0),
Accent = Color3.fromRGB(10, 10, 10),
LightContrast = Color3.fromRGB(20, 20, 20),
DarkContrast = Color3.fromRGB(14, 14, 14),  
TextColor = Color3.fromRGB(255, 255, 255)
}

-------------------------------------------------------
-- Farm Page
-------------------------------------------------------
local page = venyx:addPage("Farm", 5012544693)
local Farmsection1 = page:addSection("Section 1")

Farmsection1:addTextbox("สถานะ", nil, function(value)
    print("สถานะ", value)
end)
Farmsection1:addTextbox("จำนวนรอบ", nil, function(value)
    print("จำนวนรอบ", value)
end)
Farmsection1:addToggle("เก็บถ้วย", nil, function(value)
    print("เก็บถ้วย", value)
end)
Farmsection1:addToggle("เก็บคริสตัล", nil, function(value)
    print("เก็บคริสตัล", value)
end)
Farmsection1:addDropdown("Please select world", {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"}, function(text)
    print("Selected", text)
end)
Farmsection1:addButton("Start", function(value)
end)
Farmsection1:addButton("Stop", function(value)
end)

-------------------------------------------------------
-- Hatch Page
-------------------------------------------------------
local page = venyx:addPage("Hatch", 5012544693)
local Hatchsection1 = page:addSection("Section 1")

Hatchsection1:addTextbox("สถานะ", nil, function(value)
    print("สถานะ", value)
end)
Hatchsection1:addTextbox("จำนวนรอบ", nil, function(value)
    print("จำนวนรอบ", value)
end)
Hatchsection1:addToggle("เก็บถ้วย", nil, function(value)
    print("เก็บถ้วย", value)
end)
Hatchsection1:addToggle("เก็บคริสตัล", nil, function(value)
    print("เก็บคริสตัล", value)
end)
Hatchsection1:addDropdown("Dropdown", {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"}, function(text)
    print("Selected", text)
end)
Hatchsection1:addButton("Start", function(value)
end)
Hatchsection1:addButton("Stop", function(value)
end)

-------------------------------------------------------
-- Rejoin Server Page
-------------------------------------------------------
local page = venyx:addPage("RejoinServer", 5012544693)
local Rejoinsection1 = page:addSection("Rejoin Server Setting")

Rejoinsection1:addWideLabel("สถานะ.....")
Rejoinsection1:addButton("Search Server", function(value)
        
end)
Rejoinsection1:addButton("Rejoin Server", function(value)
        
end)

-------------------------------------------------------
-- Theme page
-------------------------------------------------------
local theme = venyx:addPage("Theme", 5012544693)
local Themesetting = theme:addSection("Setting")
local Themecolors = theme:addSection("Colors Setting")

Themesetting:addKeybind("Toggle Keybind", Enum.KeyCode.One, function()
print("Activated Keybind")
venyx:toggle()
end, function()
print("Changed Keybind")
end)

for theme, color in pairs(themes) do -- all in one theme changer, i know, im cool
Themecolors:addColorPicker(theme, color, function(color3)
venyx:setTheme(theme, color3)
end)
end

-------------------------------------------------------
-- load
-------------------------------------------------------
venyx:SelectPage(venyx.pages[1], true)
