-------------------------------------------------------
-- 🔧 Services & ตัวแปรเริ่มต้น
-------------------------------------------------------
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

 -- Rejoin Server Page
local placeId = game.PlaceId
local selectedJobId = nil
local teleporting = false
local textRejoin = nil

-- Farm Page
local FarmloopRunning = false
local selectedWorldFarm = nil
local textFarm = nil
local roundsBoxFarm = 0

-- Hatch Page
local hatchLoopRunning = false
local hatchLoopCount = 0
local textHatch = nil
local roundsBoxHatch = 0
local dropdownHatch = nil
local selectedEggId = nil

-- Option Page
local shouldClaimWins = false
local shouldClaimCrystal = false
local WalkSpeed = nil
local JumpPower = nil

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

local hatchPresets = {
	World1 = {"Egg 200", "Egg 20k", "Egg 1M"},
	World2 = {"Egg 400M", "Egg 160B", "Egg 16T"},
	World3 = {"Egg 2.50q", "Egg 1.3Q"},
	World4 = {"Egg 1.90aa", "Egg 2.9bb"},
	World5 = {"Egg 4.30cc", "Egg 6.50dd"},
	World6 = {"Egg 9.70ee", "Egg 15ff"},
	World7 = {"Egg 22gg", "Egg 2.20hh", "Egg 220hh"},
	World8 = {"Egg 44ii", "Egg 4.40jj", "Egg 440jj"}
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
local function getLocation() return selectedWorldFarm and locationPresets[selectedWorldFarm] end

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
Farmsection1:addDropdown("Please select world", {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"}, function(worldText)
    selectedWorldFarm = worldText
end)
Farmsection1:addButton("Start", function(value)
	if not selectedWorldFarm then 
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
		updateStatustextFarm("✅ เริ่มรอบใน " .. selectedWorldFarm)
		RunLoopFarm(roundsBoxFarm)
		updateStatustextFarm("⏹️ เสร็จสิ้นการทำงาน")
	end)
end)
Farmsection1:addButton("Stop", function(value)
	FarmloopRunning = false
	updateStatustextFarm("⏹️ หยุดการทำงานแล้ว")
end)

-------------------------------------------------------
-- 🧭 ฟังก์ชั่นของ Option Page
-------------------------------------------------------
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChild("Humanoid")
end

-------------------------------------------------------
-- Option Page
-------------------------------------------------------
local Optionpage = venyx:addPage("Character", 5012544693)
local Optionsection1 = Optionpage:addSection("Character Options")
local Optionsection2 = Optionpage:addSection("Free Gift Options")
local Optionsection3 = Optionpage:addSection("Soin Options")

WalkSpeed = Optionsection1:addSlider("Walk Speed", 16, 0, 100, function(value)
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = value
	end
end)
JumpPower = Optionsection1:addSlider("Jump Power", 50, 0, 100, function(value)
	local hum = getHumanoid()
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = value
	end
end)
Optionsection1:addButton("Refresh", function(value)
	local hum = getHumanoid()
	if hum then
		local defaultWalkSpeed = 16
		local defaultJumpPower = 50

		-- อัปเดตค่าใน Humanoid
		hum.WalkSpeed = defaultWalkSpeed

		hum.JumpPower = defaultJumpPower
		hum.UseJumpPower = false

		-- อัปเดต UI slider
		Optionsection1:updateSlider(WalkSpeed, nil, defaultWalkSpeed, 0, 100)
		Optionsection1:updateSlider(JumpPower, nil, defaultJumpPower, 0, 100)
	end
end)
Optionsection2:addToggle("รับ Free Gift", nil, function(value)
	local remote = game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent")
	local msg = "\233\162\134\229\143\150\229\156\168\231\186\191\229\165\150\229\138\177"
	for i = 1, 12 do
	    local args = {msg, i}
	    remote:FireServer(unpack(args))
	end
end)
Optionsection3:addToggle("หมุนวงล้อ Spin", nil, function(value)
	for i = 1, 2 do
		game:GetService("ReplicatedStorage"):WaitForChild("System"):WaitForChild("SystemDailyLottery"):WaitForChild("Spin"):InvokeServer()
		task.wait(0.5)
	end
end)

-------------------------------------------------------
-- 🧭 ฟังก์ชั่นสุ่มไข่ ของ Hatch Page และ อัพเดท textHatch
-------------------------------------------------------
local function updateStatustextHatch(msg)
    textHatch.Label.Text = msg
end
local function HatchEgg(eggId)
	local args = {eggId, 3}
	game:GetService("ReplicatedStorage"):WaitForChild("Tool"):WaitForChild("DrawUp"):WaitForChild("Msg"):WaitForChild("DrawHero"):InvokeServer(unpack(args))
end
local function buildIncubatorMapAndOptions(presets)
	local map = {}
	local options = {}
	local count = 0

	for worldIndex = 1, 8 do
		local world = "World" .. worldIndex
		local eggs = presets[world]
		if eggs then
			for _, egg in ipairs(eggs) do
				count += 1
				local label = world .. " - " .. egg
				map[label] = 7000000 + count -- 👈 ใช้ ID ไข่ ตรงนี้เลย
				table.insert(options, label)
			end
		end
	end
	return map, options
end

-------------------------------------------------------
-- Hatch Page
-------------------------------------------------------
local Hatchpage = venyx:addPage("Hatch", 5012544693)
local Hatchsection1 = Hatchpage:addSection("Hatch Setting")
local incubatorMap, hatchOptions = buildIncubatorMapAndOptions(hatchPresets)

textHatch = Hatchsection1:addWideLabel("สถานะ...", Color3.fromRGB(255, 0, 0))
Hatchsection1:addTextbox("จำนวนรอบ", nil, function(value)
	local number = tonumber(value)  -- แปลงค่า value เป็น number ก่อนใช้งาน
	if number and number > 0 then
		roundsBoxHatch = number
	else
		updateStatustextFarm("❌ โปรดใส่เลขที่ถูกต้อง")
	end
end)
dropdownHatch = Hatchsection1:addDropdown("Please select Incubator", hatchOptions, function(selectedText)
	selectedEggId = incubatorMap[selectedText]
	updateStatustextHatch(selectedText .. " => ลำดับที่ " .. (selectedEggId or "❌ ไม่พบ"))
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
			HatchEgg(selectedEggId)
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

Themesetting:addKeybind("Toggle Keybind", Enum.KeyCode.KeypadPlus, function()
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
