local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local loopRunning = false
local selectedWorld = nil

-- ตรวจสอบและสร้าง ScreenGui ถ้าไม่มี
local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("TeleportUI")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ตำแหน่งของแต่ละ World
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

-- ฟังก์ชันดึงตำแหน่งตาม world ที่เลือก
local function getLocation()
	if not selectedWorld then return nil end
	return locationPresets[selectedWorld]
end

-- ฟังก์ชันช่วยสร้าง UI element แบบง่าย
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
	local box = Instance.new("TextBox")
	box.PlaceholderText = placeholder or ""
	box.Position = position
	box.Size = size
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.ClearTextOnFocus = false
	box.TextEditable = editable ~= false -- default true
	box.TextWrapped = true
	box.Parent = parent
	return box
end

-- สร้าง UI หลัก
local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.Size = UDim2.new(0, 300, 0, 280)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = true
frame.Active = true
frame.Draggable = false -- เราจะทำ drag เอง

-- TextBox ใส่จำนวนรอบ
local roundsBox = createTextBox(frame, "จำนวนรอบ", UDim2.new(0.1, 0, 0.12, 0), UDim2.new(0.8, 0, 0.15, 0), true)
roundsBox.Text = ""

-- ปุ่ม เริ่ม กับ หยุด
local startButton = createButton(frame, "เริ่ม", UDim2.new(0.1, 0, 0.35, 0), UDim2.new(0.35, 0, 0.15, 0))
local stopButton = createButton(frame, "หยุด", UDim2.new(0.55, 0, 0.35, 0), UDim2.new(0.35, 0, 0.15, 0))

-- ปุ่ม Dropdown หลัก
local dropdownMain = createButton(frame, "เลือก World", UDim2.new(0.1, 0, 0.65, 0), UDim2.new(0.8, 0, 0.15, 0))
dropdownMain.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

-- กรอบ dropdown รายการ (ซ่อนตอนเริ่ม)
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

-- สร้างปุ่มเลือก World ใน dropdown
for name, _ in pairs(locationPresets) do
	local option = createButton(dropdownFrame, name, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 24))
	option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	option.Size = UDim2.new(1, 0, 0, 24)
	option.MouseButton1Click:Connect(function()
		selectedWorld = name
		dropdownMain.Text = selectedWorld
		dropdownFrame.Visible = false
		dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)
	end)
end

-- กล่องแสดงสถานะ
local detailBox = createTextBox(frame, nil, UDim2.new(0.05, 0, 0.05, 0), UDim2.new(0.9, 0, 0.1, 0), false)
detailBox.Text = "สถานะ..."
detailBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local function updateStatus(msg)
	detailBox.Text = msg
end

-- Toggle เปิด-ปิด dropdown
local isOpen = false
dropdownMain.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	dropdownFrame.Visible = isOpen
	if isOpen then
		dropdownFrame.Size = UDim2.new(0.8, 0, 0, 200)
	else
		dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)
	end
end)

-- Toggle แสดง UI ด้วยปุ่ม P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
		frame.Visible = not frame.Visible
	end
end)

-- Drag UI (ทำเองให้ลื่น)
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- ฟังก์ชัน Teleport และ Move

local function teleportTo(position)
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	hrp.CFrame = CFrame.new(position)
end

local function walkTo(position)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:MoveTo(position)
end

local function walkUp(duration)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local startTime = tick()
	RunService:UnbindFromRenderStep("WalkUpMove")
	RunService:BindToRenderStep("WalkUpMove", Enum.RenderPriority.Character.Value + 1, function()
		if tick() - startTime > duration or not loopRunning then
			RunService:UnbindFromRenderStep("WalkUpMove")
			return
		end
		if humanoid then
			humanoid:Move(Vector3.new(0, 0, -1), true)
		end
	end)
end

-- ฟังก์ชัน teleport/walk ตามตำแหน่งที่ตั้งไว้ใน locationPresets

local function TpPosStart()
	local loc = getLocation()
	if not loc then return end
	teleportTo(loc.start)
end

local function WalkToStairs()
	local loc = getLocation()
	if not loc then return end
	walkTo(loc.stairs)
end

local function WalkUp()
	walkUp(3)
end

local function TpPosTrophy()
	local loc = getLocation()
	if not loc then return end
	teleportTo(loc.trophy)
end

local function WalkDown()
	local loc = getLocation()
	if not loc then return end
	walkTo(loc.down)
end

-- ลูปรัน teleport/walk ตามจำนวนรอบ
local function RunLoop(rounds)
	loopRunning = true
	for i = 1, rounds do
		if not loopRunning then break end

		TpPosStart()
		task.wait(1)

		WalkToStairs()
		task.wait(1)

		WalkUp()
		task.wait(3)

		TpPosTrophy()
		task.wait(1)

		WalkDown()
		task.wait(5)
	end
	loopRunning = false
end

-- Event ปุ่ม เริ่ม
startButton.MouseButton1Click:Connect(function()
	local rounds = tonumber(roundsBox.Text)
	if not selectedWorld then
		updateStatus("⚠️ กรุณาเลือก World ก่อนเริ่ม")
		return
	end

	if rounds and rounds > 0 then
		if not loopRunning then
			task.spawn(function()
				updateStatus("✅ เริ่มรอบใน " .. selectedWorld)
				RunLoop(rounds)
				updateStatus("⏹️ เสร็จสิ้นการทำงาน")
			end)
		end
	else
		updateStatus("❌ จำนวนรอบไม่ถูกต้อง")
	end
end)

-- Event ปุ่ม หยุด
stopButton.MouseButton1Click:Connect(function()
	loopRunning = false
	updateStatus("⏹️ หยุดการทำงานแล้ว")
end)
