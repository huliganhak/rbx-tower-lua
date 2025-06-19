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
local page = venyx:addPage("Farm Page", 5012544693)
local section1 = page:addSection("Section 1")
local section2 = page:addSection("Section 2")

section1:addTextbox("สถานะ", nil, function(value)
    print("สถานะ", value)
end)
section1:addTextbox("จำนวนรอบ", nil, function(value)
    print("จำนวนรอบ", value)
end)
section1:addToggle("เก็บถ้วย", nil, function(value)
    print("เก็บถ้วย", value)
end)
section1:addToggle("เก็บคริสตัล", nil, function(value)
    print("เก็บคริสตัล", value)
end)
section1:addDropdown("Dropdown", {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"}, function(text)
    print("Selected", text)
end)
section1:addButton("Start", function(value)
end)
section1:addButton("Stop", function(value)
end)

-------------------------------------------------------
-- Hatch Page
-------------------------------------------------------
local page = venyx:addPage("Farm Page", 5012544693)
local section1 = page:addSection("Section 1")
local section2 = page:addSection("Section 2")

section1:addTextbox("สถานะ", nil, function(value)
    print("สถานะ", value)
end)
section1:addTextbox("จำนวนรอบ", nil, function(value)
    print("จำนวนรอบ", value)
end)
section1:addToggle("เก็บถ้วย", nil, function(value)
    print("เก็บถ้วย", value)
end)
section1:addToggle("เก็บคริสตัล", nil, function(value)
    print("เก็บคริสตัล", value)
end)
section1:addDropdown("Dropdown", {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"}, function(text)
    print("Selected", text)
end)
section1:addButton("Start", function(value)
end)
section1:addButton("Stop", function(value)
end)

section2:addKeybind("Toggle Keybind", Enum.KeyCode.One, function()
print("Activated Keybind")
venyx:toggle()
end, function()
print("Changed Keybind")
end)
section2:addColorPicker("ColorPicker", Color3.fromRGB(50, 50, 50))
section2:addColorPicker("ColorPicker2")
section2:addSlider("Slider", 0, -100, 100, function(value)
print("Dragged", value)
end)
section2:addDropdown("Dropdown", {"Hello", "World", "Hello World", "Word", 1, 2, 3})
section2:addDropdown("Dropdown", {"Hello", "World", "Hello World", "Word", 1, 2, 3}, function(text)
print("Selected", text)
end)
section2:addButton("Button")

-------------------------------------------------------
-- Theme page
-------------------------------------------------------
local theme = venyx:addPage("Theme", 5012544693)
local colors = theme:addSection("Colors Setting")

for theme, color in pairs(themes) do -- all in one theme changer, i know, im cool
colors:addColorPicker(theme, color, function(color3)
venyx:setTheme(theme, color3)
end)
end

-------------------------------------------------------
-- load
-------------------------------------------------------
venyx:SelectPage(venyx.pages[1], true)
