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
local FarmloopRunning = false
local selectedWorld = nil
local hatchLoopRunning = false
local hatchLoopCount = 0
local teleporting = false
local isWalkingUp = false

local textFarm = nil
local textHatch = nil
local textRejoin = nil

local roundsBoxFarm = 0
local roundsBoxHatch = 0

local shouldClaimWins = false
local shouldClaimCrystal = false

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
-- 🧭 ฟังก์ชั่นของ Farm Page และ อัพเดท textFarm
-------------------------------------------------------
local function updateStatustextFarm(msg)
    textFarm.Label.Text = msg
end

local function getLocation() return selectedWorld and locationPresets[selectedWorld] end

local function teleportTo(pos)
	local char = player.Character or player.CharacterAdded:Wait()
	char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(pos)
end

local function walkTo(pos)
	local char = player.Character or player.CharacterAdded:Wait()
	char:WaitForChild("Humanoid"):MoveTo(pos)
end

local function walkUp(duration)
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChild("Humanoid")
	if not hum then return end
	local startTime = tick()
	RunService:UnbindFromRenderStep("WalkUpMove")
	RunService:BindToRenderStep("WalkUpMove", Enum.RenderPriority.Character.Value + 1, function()
		if tick() - startTime > duration or not FarmloopRunning then
			RunService:UnbindFromRenderStep("WalkUpMove")
			return
		end
		hum:Move(Vector3.new(0, 0, -1), true)
	end)
end

local function ClaimRewardWins()
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182wins"}
	game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local function ClaimRewardMagicToken()
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182MagicToken"}
	game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local function TpPosStart() local l = getLocation() if l then teleportTo(l.start) end end
local function WalkToStairs() local l = getLocation() if l then walkTo(l.stairs) end end
local function WalkUp() walkUp(3) end
local function TpPosTrophy() local l = getLocation() if l then teleportTo(l.trophy) end end
local function WalkDown() local l = getLocation() if l then walkTo(l.down) end end

local function RunLoopFarm(roundsBoxFarm)
	for i = 1, roundsBoxFarm do
		if not FarmloopRunning then break end
		
		updateStatustextFarm("🔁 รอบที่ " .. i .. "/" .. roundsBoxFarm)
		TpPosStart() task.wait(1)
		WalkToStairs() task.wait(1)
		WalkUp() task.wait(3)
		TpPosTrophy() task.wait(1)
		
		if shouldClaimWins then 
		    ClaimRewardWins() 
		    task.wait(1) 
		end	
		if shouldClaimCrystal then 
		    ClaimRewardMagicToken() 
		    task.wait(1) 
		end
		
		WalkDown() task.wait(5)
	end
	updateStatustextFarm("✅ ครบ " .. roundsBoxFarm .. " รอบแล้ว")
	FarmloopRunning = false -- จบ loop แล้วค่อย reset
end

-------------------------------------------------------
-- Farm Page
-------------------------------------------------------
local Farmpage = venyx:addPage("Farm", 5012544693)
local Farmsection1 = Farmpage:addSection("Section 1")

textFarm = Farmsection1:addWideLabel("สถานะ...", Color3.fromRGB(255, 0, 0))
Farmsection1:addTextbox("จำนวนรอบ", nil, function(value)
	local number = tonumber(value) -- แปลงค่า value เป็น number ก่อนใช้งาน
	if number and number > 0 then
		roundsBoxFarm = number
	else
		updateStatustextFarm("❌ โปรดใส่เลขที่ถูกต้อง")
	end
end)
Farmsection1:addToggle("เก็บถ้วย", nil, function(value)
	shouldClaimWins = value
end)
Farmsection1:addToggle("เก็บคริสตัล", nil, function(value)
	shouldClaimCrystal = value
end)
Farmsection1:addDropdown("Please select world", {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"}, function(text)
    selectedWorld = text
end)
Farmsection1:addButton("Start", function(value)
	if not selectedWorld then 
		updateStatustextFarm("⚠️ กรุณาเลือก World ก่อนเริ่ม") 
		return
	end
	if FarmloopRunning then
		updateStatustextFarm("⚠️ กำลังทำงานอยู่ กรุณาหยุดก่อนเริ่มใหม่")
		return
	end

	if not roundsBoxFarm or roundsBoxFarm <= 0 then
		updateStatustextFarm("❌ จำนวนรอบไม่ถูกต้อง กรุณากรอกตัวเลขมากกว่า 0")
		return
	end

	FarmloopRunning = true
	task.spawn(function()
		updateStatustextFarm("✅ เริ่มรอบใน " .. selectedWorld)
		RunLoopFarm(roundsBoxFarm)
		updateStatustextFarm("⏹️ เสร็จสิ้นการทำงาน")
	end)
end)
Farmsection1:addButton("Stop", function(value)
	FarmloopRunning = false
	updateStatustextFarm("⏹️ หยุดการทำงานแล้ว")
end)

-------------------------------------------------------
-- 🧭 ฟังก์ชั่นสุ่มไข่ ของ Hatch Page และ อัพเดท textHatch
-------------------------------------------------------
local function updateStatustextHatch(msg)
    textHatch.Label.Text = msg
end

local function HatchEgg()
	local args = {7000020, 3}
	game:GetService("ReplicatedStorage"):WaitForChild("Tool"):WaitForChild("DrawUp"):WaitForChild("Msg"):WaitForChild("DrawHero"):InvokeServer(unpack(args))
end

-------------------------------------------------------
-- Hatch Page
-------------------------------------------------------
local Hatchpage = venyx:addPage("Hatch", 5012544693)
local Hatchsection1 = Hatchpage:addSection("Hatch Setting")

textHatch = Hatchsection1:addWideLabel("สถานะ...", Color3.fromRGB(255, 0, 0))
Hatchsection1:addTextbox("จำนวนรอบ", nil, function(value)
	local number = tonumber(value)  -- แปลงค่า value เป็น number ก่อนใช้งาน
	if number and number > 0 then
		roundsBoxHatch = number
	else
		updateStatustextFarm("❌ โปรดใส่เลขที่ถูกต้อง")
	end
end)
Hatchsection1:addDropdown("Please select Incubator", {"Incubator1", "Incubator2", "Incubato3"}, function(text)
	print("Selected", text)
end)
Hatchsection1:addButton("Start Hatch", function(value)
	if type(roundsBoxHatch) ~= "number" or roundsBoxHatch <= 0 then
		updateStatustextHatch("❌ จำนวนรอบไม่ถูกต้อง")
		return
	end
		
	if hatchLoopRunning then 
		updateStatustextHatch("⚠️ กำลังทำงาน Start อยู่ กรุณาหยุดก่อน") 
		return 
	end

	hatchLoopRunning = true
	hatchLoopCount = 0
	task.spawn(function()
		while hatchLoopRunning and hatchLoopCount < roundsBoxHatch do
			HatchEgg()
			hatchLoopCount += 1
			updateStatustextHatch("🥚 กำลังฟักไข่ (รอบ " .. hatchLoopCount .. " / " .. roundsBoxHatch .. ")")
			task.wait(3)
		end
		hatchLoopRunning = false
		updateStatustextHatch("⏹️ ฟักไข่เสร็จสิ้น (รวม " .. hatchLoopCount .. " รอบ)")
	end)
end)
Hatchsection1:addButton("Stop Hatch", function(value)
	if hatchLoopRunning then
		hatchLoopRunning = false
		updateStatustextHatch("⏹️ หยุดฟักไข่แล้ว (รวม " .. hatchLoopCount .. " รอบ)")
		return
	end
end)

-------------------------------------------------------
-- 🧭 ฟังก์ชันดึง Job ID Server ของ Rejoin Server Page และ อัพเดท textRejoin
-------------------------------------------------------
local function updateStatusfetchServers(msg)
    textRejoin.Label.Text = msg
end

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
            updateStatusfetchServers("✅ พบ JobID: " .. selectedJobId .. " (" .. tostring(lowestPlayers) .. " คน)")
        else
            updateStatusfetchServers("⚠️ ไม่พบ server ที่เข้าได้")
        end
    else
        updateStatusfetchServers("❌ ดึงข้อมูล server ล้มเหลว: " .. tostring(response))
    end
end

-------------------------------------------------------
-- Rejoin Server Page
-------------------------------------------------------
local RejoinSerpage = venyx:addPage("RejoinServer", 5012544693)
local Rejoinsection1 = RejoinSerpage:addSection("Rejoin Server Setting")

textRejoin = Rejoinsection1:addWideLabel("สถานะ...", Color3.fromRGB(255, 0, 0))
Rejoinsection1:addButton("Search Server", function()
	fetchServersAndSelect()
end)
Rejoinsection1:addButton("Rejoin Server", function(value)
        if not selectedJobId or teleporting then
		updateStatusfetchServers("⚠️ ยังไม่มี server ที่เลือกได้")
		return
	end
	teleporting = true
	updateStatusfetchServers("⏳ กำลังย้ายไป server: " .. selectedJobId)
	TeleportService:TeleportToPlaceInstance(placeId, selectedJobId, player)
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
