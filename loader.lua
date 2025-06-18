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
-- 📦 ตัวช่วยสร้าง UI (Button / TextBox)
-------------------------------------------------------
local function createButton(parent, text, position, size)
	local btn = Instance.new("TextButton")
	btn.Text = text
	btn.Position = position
	btn.Size = size
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = parent
	return btn
end

local function createTextBox(parent, placeholder, position, size, editable)
	local box = Instance.new()
	box.PlaceholderText = placeholder or ""
	box.Position = position
	box.Size = size
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.ClearTextOnFocus = false
	box.TextEditable = editable ~= false
	box.TextWrapped = true
	box.Parent = parent
	return box
end

-------------------------------------------------------
-- 🖥️ สร้างหน้าต่าง GUI หลัก
-------------------------------------------------------
local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("TeleportUI")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.Size = UDim2.new(0, 300, 0, 280)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = true
frame.Active = true
frame.Draggable = false

-------------------------------------------------------
-- 🔢 UI Elements (TextBox / Button)
-------------------------------------------------------
local detailBox = createTextBox(frame, nil, UDim2.new(0.05, 0, 0.05, 0), UDim2.new(0.9, 0, 0.1, 0), false)
detailBox.Text = "สถานะ..."
detailBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local roundsBox = createTextBox(frame, "จำนวนรอบ", UDim2.new(0.1, 0, 0.12, 0), UDim2.new(0.8, 0, 0.15, 0), true)

local startButton = createButton(frame, "เริ่ม", UDim2.new(0.1, 0, 0.35, 0), UDim2.new(0.35, 0, 0.15, 0))
local stopButton = createButton(frame, "หยุด", UDim2.new(0.55, 0, 0.35, 0), UDim2.new(0.35, 0, 0.15, 0))
local fetchButton = createButton(frame, "ค้นหาเซิร์ฟเวอร์", UDim2.new(0.8, 0, 0, 50), UDim2.new(0.1, 0, 0.7, 0))
local hatchButton = createButton(frame, "Hatch", UDim2.new(0.1, 0, 0.45, 0), UDim2.new(0.8, 0, 0.1, 0))
hatchButton.BackgroundColor3 = Color3.fromRGB(100, 100, 80)

local dropdownMain = createButton(frame, "เลือก World", UDim2.new(0.1, 0, 0.65, 0), UDim2.new(0.8, 0, 0.15, 0))
local dropdownFrame = Instance.new("Frame", frame)
dropdownFrame.Position = UDim2.new(0.1, 0, 0.8, 0)
dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)
dropdownFrame.ClipsDescendants = true
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownFrame.BorderSizePixel = 1
dropdownFrame.Visible = false

local layout = Instance.new("UIListLayout", dropdownFrame)
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local rejoinButton = createButton(frame, "Rejoin Server", UDim2.new(0.1, 0, 0.82, 0), UDim2.new(0.8, 0, 0.1, 0))
rejoinButton.BackgroundColor3 = Color3.fromRGB(80, 120, 80)

-------------------------------------------------------
-- 🌍 ปุ่มเลือก World ภายใน dropdown
-------------------------------------------------------
for name, _ in pairs(locationPresets) do
	local option = createButton(dropdownFrame, name, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 24))
	option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	option.MouseButton1Click:Connect(function()
		selectedWorld = name
		dropdownMain.Text = name
		dropdownFrame.Visible = false
		dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)
	end)
end

-------------------------------------------------------
-- ⌨️ Input - ปุ่มลัด Toggle / Drag UI
-------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
		frame.Visible = not frame.Visible
	end
end)

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-------------------------------------------------------
-- 🚶 ฟังก์ชัน Teleport & Move
-------------------------------------------------------
local function getLocation() return selectedWorld and locationPresets[selectedWorld] end
local function updateStatus(msg) detailBox.Text = msg end

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
		if tick() - startTime > duration or not loopRunning then
			RunService:UnbindFromRenderStep("WalkUpMove")
			return
		end
		hum:MoveTo(Vector3.new(0, 0, -1), true)
	end)
end

-------------------------------------------------------
-- 🧭 ฟังก์ชันดึง Job ID Server
-------------------------------------------------------
local function fetchServersAndSelect()
    updateStatus("⏳ กำลังดึงข้อมูล server...")

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
            updateStatus("✅ พบ server คนเล่นน้อยสุด: " .. selectedJobId .. " (" .. tostring(lowestPlayers) .. " คน)")
        else
            updateStatus("⚠️ ไม่พบ server ที่เข้าได้")
        end
    else
        updateStatus("❌ ดึงข้อมูล server ล้มเหลว: " .. tostring(response))
    end
end

-------------------------------------------------------
-- 🧭 ฟังก์ชันย่อยแต่ละขั้นตอน
-------------------------------------------------------
local function TpPosStart() local l = getLocation() if l then teleportTo(l.start) end end
local function WalkToStairs() local l = getLocation() if l then walkTo(l.stairs) end end
local function WalkUp() walkUp(3) end
local function TpPosTrophy() local l = getLocation() if l then teleportTo(l.trophy) end end
local function WalkDown() local l = getLocation() if l then walkTo(l.down) end end
local function HatchEgg()
	local args = {7000020, 3}
	game:GetService("ReplicatedStorage"):WaitForChild("Tool"):WaitForChild("DrawUp"):WaitForChild("Msg"):WaitForChild("DrawHero"):InvokeServer(unpack(args))
end

-------------------------------------------------------
-- 🔁 ลูปการทำงานหลัก
-------------------------------------------------------
local function RunLoop(rounds)
	loopRunning = true
	for i = 1, rounds do
		if not loopRunning then break end
		TpPosStart() task.wait(1)
		WalkToStairs() task.wait(1)
		WalkUp() task.wait(3)
		TpPosTrophy() task.wait(1)
		WalkDown() task.wait(5)
	end
	loopRunning = false
end

-------------------------------------------------------
-- 🖱️ ปุ่มเริ่ม / หยุด / Hatch / Rejoin Server
-------------------------------------------------------

rejoinButton.MouseButton1Click:Connect(function()
	if not selectedJobId or teleporting then
		updateStatus("⚠️ ยังไม่มี server ที่เลือกได้")
		return
	end
	teleporting = true
	updateStatus("⏳ กำลังย้ายไป server: " .. selectedJobId)
	TeleportService:TeleportToPlaceInstance(placeId, selectedJobId, player)
end)

startButton.MouseButton1Click:Connect(function()
	local rounds = tonumber(roundsBox.Text)
	if not selectedWorld then updateStatus("⚠️ กรุณาเลือก World ก่อนเริ่ม") return end
	if rounds and rounds > 0 and not loopRunning then
		task.spawn(function()
			updateStatus("✅ เริ่มรอบใน " .. selectedWorld)
			RunLoop(rounds)
			updateStatus("⏹️ เสร็จสิ้นการทำงาน")
		end)
	else
		updateStatus("❌ จำนวนรอบไม่ถูกต้อง")
	end
end)

stopButton.MouseButton1Click:Connect(function()
	loopRunning = false
	updateStatus("⏹️ หยุดการทำงานแล้ว")
end)

fetchButton.MouseButton1Click:Connect(function()
	fetchServersAndSelect()
end)

hatchButton.MouseButton1Click:Connect(function()
	if hatchLoopRunning then
		hatchLoopRunning = false
		hatchButton.Text = "Hatch (OFF)"
		updateStatus("⏹️ หยุดฟักไข่แล้ว (รวม " .. hatchLoopCount .. " รอบ)")
		return
	end

	local rounds = tonumber(roundsBox.Text)
	if not rounds or rounds <= 0 then updateStatus("❌ จำนวนรอบไม่ถูกต้อง") return end
	if loopRunning then updateStatus("⚠️ กำลังทำงาน Start อยู่ กรุณาหยุดก่อน") return end

	hatchLoopRunning = true
	hatchLoopCount = 0
	hatchButton.Text = "Hatch (ON)"
	task.spawn(function()
		while hatchLoopRunning and hatchLoopCount < rounds do
			HatchEgg()
			hatchLoopCount += 1
			updateStatus("🥚 กำลังฟักไข่ (รอบ " .. hatchLoopCount .. " / " .. rounds .. ")")
			task.wait(3)
		end
		hatchLoopRunning = false
		hatchButton.Text = "Hatch (OFF)"
		updateStatus("⏹️ ฟักไข่เสร็จสิ้น (รวม " .. hatchLoopCount .. " รอบ)")
	end)
end)

-- ปุ่ม Toggle dropdown World
local isOpen = false
dropdownMain.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	dropdownFrame.Visible = isOpen
	dropdownFrame.Size = isOpen and UDim2.new(0.8, 0, 0, 200) or UDim2.new(0.8, 0, 0, 0)
end)
