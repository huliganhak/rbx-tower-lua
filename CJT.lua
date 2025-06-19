-------------------------------------------------------
-- 🔧 Services & ตัวแปรเริ่มต้น
-------------------------------------------------------
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local placeId = game.PlaceId
local selectedJobId = nil
local loopRunning = false
local selectedWorld = nil
local hatchLoopRunning = false
local hatchLoopCount = 0
local teleporting = false
local isWalkingUp = false

-------------------------------------------------------
-- 🗺️ Preset ตำแหน่งของแต่ละ World
-------------------------------------------------------
local locationPresets = {
	World1 = { start = Vector3.new(-3.75, 5, -55), stairs = Vector3.new(-3.75, 5, -60), trophy = Vector3.new(-5, 14410, -65), down = Vector3.new(-3.75, 5, -55) },
	World2 = { start = Vector3.new(5000, 5, -60), stairs = Vector3.new(5000, 5, -65), trophy = Vector3.new(5000, 14410, -70), down = Vector3.new(5000, 5, -60) },
	World3 = { start = Vector3.new(10001, 5, -30), stairs = Vector3.new(10001, 5, -35), trophy = Vector3.new(10001, 14410, -40), down = Vector3.new(10001, 5, -30) },
	World4 = { start = Vector3.new(14998, 5, -130), stairs = Vector3.new(14998, 5, -135), trophy = Vector3.new(14998, 14410, -145), down = Vector3.new(14998, 5, -130) },
	World5 = { start = Vector3.new(20001, 5, -70), stairs = Vector3.new(20001, 5, -75), trophy = Vector3.new(20001, 14410, -80), down = Vector3.new(20001, 5, -70) },
	World6 = { start = Vector3.new(25000, 5, -35), stairs = Vector3.new(25000, 5, -40), trophy = Vector3.new(25000, 14410, -45), down = Vector3.new(25000, 5, -35) },
	World7 = { start = Vector3.new(30000, 5, -70), stairs = Vector3.new(30000, 5, -75), trophy = Vector3.new(30000, 14410, -85), down = Vector3.new(30000, 5, -70) },
	World8 = { start = Vector3.new(35000, 5, -35), stairs = Vector3.new(35000, 5, -40), trophy = Vector3.new(35000, 14410, -45), down = Vector3.new(35000, 5, -35) }
}

-------------------------------------------------------
-- UI 
-------------------------------------------------------
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
local Farmpage = venyx:addPage("Farm", 5012544693)
local Farmsection1 = Farmpage:addSection("Section 1")

Farmsection1:addWideLabel("สถานะ...", Color3.fromRGB(255, 0, 0))
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
local Hatchpage = venyx:addPage("Hatch", 5012544693)
local Hatchsection1 = Hatchpage:addSection("Section 1")

Hatchsection1:addWideLabel("สถานะ...", Color3.fromRGB(255, 0, 0))
Hatchsection1:addTextbox("จำนวนรอบ", nil, function(value)
    print("จำนวนรอบ", value)
end)
Hatchsection1:addDropdown("Please select Incubator", {"Incubator1", "Incubator2", "Incubato3"}, function(text)
    print("Selected", text)
end)
Hatchsection1:addButton("Start", function(value)
end)
Hatchsection1:addButton("Stop", function(value)
end)

-------------------------------------------------------
-- Rejoin Server Page
-------------------------------------------------------
local RejoinSerpage = venyx:addPage("RejoinServer", 5012544693)
local Rejoinsection1 = RejoinSerpage:addSection("Rejoin Server Setting")

local textRejoin = Rejoinsection1:addWideLabel("สถานะ...", Color3.fromRGB(255, 0, 0))
Rejoinsection1:addButton("Search Server", function()
	updateStatusfetchServers("⏳ กำลังดึงข้อมูล server...")
	print("Rejoin Button Click")
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

-------------------------------------------------------
-- 🧭 ฟังก์ชันดึง Job ID Server
-------------------------------------------------------
local function updateStatusfetchServers(msg) textRejoin.Label.Text = msg end
local function fetchServersAndSelect()
    updateStatusfetchServers("⏳ กำลังดึงข้อมูล server...")

    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local req = (syn and syn.request) or (http and http.request) or request

    local success, response = pcall(function()
        return req({
            Url = url,
            Method = "GET"
        })
    end)

    if success and response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        selectedJobId = nil

        local lowestPlayers = math.huge -- เริ่มจากจำนวนมากๆ
        for _, server in ipairs(data.data) do
            if server.playing < lowestPlayers then
                lowestPlayers = server.playing
                selectedJobId = server.id
                -- ถ้าเจอ server 0 คน ก็เลือกเลย ไม่ต้องหาอีก
                if lowestPlayers == 0 then
                    break
                end
            end
        end

        if selectedJobId then
            updateStatusfetchServers("✅ พบ server คนเล่นน้อยสุด: " .. selectedJobId .. " (" .. tostring(lowestPlayers) .. " คน)")
        else
            updateStatusfetchServers("⚠️ ไม่พบ server ที่เข้าได้")
        end
    else
        updateStatusfetchServers("❌ ดึงข้อมูล server ล้มเหลว: " .. tostring(response))
    end
end
