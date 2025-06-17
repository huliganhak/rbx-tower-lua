local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local loopRunning = false
local selectedWorld = nil

-- 🔧 ตรวจสอบว่ามี UI เดิมอยู่หรือไม่
local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("TeleportUI")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local locationPresets = {
	World1 = {
		start = Vector3.new(-3.75, 5, -55),
		stairs = Vector3.new(-3.75, 5, -60),
		trophy = Vector3.new(-5, 14410, -65),
		down = Vector3.new(-3.75, 5, -55),
	},
	World2 = {
		start = Vector3.new(5000, 5, -60),
		stairs = Vector3.new(5000, 5, -65),
		trophy = Vector3.new(5000, 14410, -70),
		down = Vector3.new(5000, 5, -60),
	},
	World3 = {
		start = Vector3.new(10001, 5, -30),
		stairs = Vector3.new(10001, 5, -35),
		trophy = Vector3.new(10001, 14410, -40),
		down = Vector3.new(10001, 5, -30),
	},
	World4 = {
		start = Vector3.new(14998, 5, -130),
		stairs = Vector3.new(14998, 5, -135),
		trophy = Vector3.new(14998, 14410, -145),
		down = Vector3.new(14998, 5, -130),
	},
	World5 = {
		start = Vector3.new(20001, 5, -70),
		stairs = Vector3.new(20001, 5, -75),
		trophy = Vector3.new(20001, 14410, -80),
		down = Vector3.new(20001, 5, -70),
	},
	World6 = {
		start = Vector3.new(25000, 5, -35),
		stairs = Vector3.new(25000, 5, -40),
		trophy = Vector3.new(25000, 14410, -45),
		down = Vector3.new(25000, 5, -35),
	},
	World7 = {
		start = Vector3.new(30000, 5, -70),
		stairs = Vector3.new(30000, 5, -75),
		trophy = Vector3.new(30000, 14410, -85),
		down = Vector3.new(30000, 5, -70),
	},
	World8 = {
		start = Vector3.new(35000, 5, -35),
		stairs = Vector3.new(35000, 5, -40),
		trophy = Vector3.new(35000, 14410, -45),
		down = Vector3.new(35000, 5, -35),
	}
}

local function getLocation()
	if not selectedWorld then return nil end
	return locationPresets[selectedWorld]
end

-- ✅ UI (สร้างใหม่ทุกครั้งแค่ภายใน TeleportUI)
local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.Size = UDim2.new(0, 300, 0, 250)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = true

local roundsBox = Instance.new("TextBox", frame)
roundsBox.PlaceholderText = "จำนวนรอบ"
roundsBox.Position = UDim2.new(0.1, 0, 0.17, 0)
roundsBox.Size = UDim2.new(0.8, 0, 0.15, 0)
roundsBox.Text = ""

local startButton = Instance.new("TextButton", frame)
startButton.Text = "เริ่ม"
startButton.Position = UDim2.new(0.1, 0, 0.35, 0)
startButton.Size = UDim2.new(0.35, 0, 0.25, 0)

local stopButton = Instance.new("TextButton", frame)
stopButton.Text = "หยุด"
stopButton.Position = UDim2.new(0.55, 0, 0.35, 0)
stopButton.Size = UDim2.new(0.35, 0, 0.25, 0)

-- 🔽 ปุ่มหลักของ Dropdown
local dropdownMain = Instance.new("TextButton", frame)
dropdownMain.Position = UDim2.new(0.1, 0, 0.65, 0)
dropdownMain.Size = UDim2.new(0.8, 0, 0.15, 0)
dropdownMain.Text = "เลือก World"
dropdownMain.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
dropdownMain.TextColor3 = Color3.new(1, 1, 1)

-- 🔽 กล่องรายการที่ซ่อนอยู่
local dropdownFrame = Instance.new("Frame", frame)
dropdownFrame.Position = UDim2.new(0.1, 0, 0.8, 0)
dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)
dropdownFrame.ClipsDescendants = true
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownFrame.BorderSizePixel = 1
dropdownFrame.Visible = false

local layout = Instance.new("UIListLayout", dropdownFrame)
layout.Padding = UDim.new(0, 2)

-- 🔘 สร้างตัวเลือก
for name, _ in pairs(locationPresets) do
	local option = Instance.new("TextButton")
	option.Size = UDim2.new(1, 0, 0, 24)
	option.Text = name
	option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	option.TextColor3 = Color3.new(1, 1, 1)
	option.Parent = dropdownFrame

	option.MouseButton1Click:Connect(function()
		selectedWorld = name
		dropdownMain.Text = selectedWorld
		dropdownFrame.Visible = false
		dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)
	end)
end

local detailBox = Instance.new("TextBox", frame)
detailBox.Position = UDim2.new(0.05, 0, 0.05, 0)
detailBox.Size = UDim2.new(0.9, 0, 0.1, 0)
detailBox.Text = "สถานะ..."
detailBox.ClearTextOnFocus = false
detailBox.TextEditable = false
detailBox.TextWrapped = true
detailBox.TextColor3 = Color3.new(1, 1, 1)
detailBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local function updateStatus(msg)
	detailBox.Text = msg
end

-- ⬇️ Toggle dropdown visibility
local isOpen = false
dropdownMain.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	dropdownFrame.Visible = isOpen
	if isOpen then
		dropdownFrame.Size = UDim2.new(0.8, 0, 0, 200) -- เปิด
	else
		dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0) -- ปิด
	end
end)

-- ✅ ปุ่ม P toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
		frame.Visible = not frame.Visible
	end
end)

-- ✅ Drag UI
local dragging = false
local dragInput, dragStart, startPos

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

-- ✅ ฟังก์ชัน Teleport/Walk ต่าง ๆ (ย่อเพื่ออ่านง่าย)
local function TpPosStart()
	local loc = getLocation()
	if not loc then return end
	
	if not selectedWorld then return end
	local pos = locationPresets[selectedWorld].start
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	hrp.CFrame = CFrame.new(pos)
end

local function WalkToStairs()
	local loc = getLocation()
	if not loc then return end
	
	if not selectedWorld then return end
	local pos = locationPresets[selectedWorld].stairs
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:MoveTo(pos)
end

local function WalkUp()
	local loc = getLocation()
	if not loc then return end
	
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local moveDuration = 3
	local startTime = tick()

	RunService:UnbindFromRenderStep("WalkUpMove")
	RunService:BindToRenderStep("WalkUpMove", Enum.RenderPriority.Character.Value + 1, function()
		if tick() - startTime > moveDuration or not loopRunning then
			RunService:UnbindFromRenderStep("WalkUpMove")
			return
		end
		if humanoid then
			humanoid:Move(Vector3.new(0, 0, -1), true)
		end
	end)
end

local function TpPosTrophy()
	local loc = getLocation()
	if not loc then return end
	
	if not selectedWorld then return end
	local pos = locationPresets[selectedWorld].trophy
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	hrp.CFrame = CFrame.new(pos)
end

local function WalkDown()
	local loc = getLocation()
	if not loc then return end
	
	if not selectedWorld then return end
	local pos = locationPresets[selectedWorld].down
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:MoveTo(pos)
end

-- ✅ ฟังก์ชันรันลูป
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
end

-- ✅ เริ่มลูป
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

-- ✅ หยุดลูป
stopButton.MouseButton1Click:Connect(function()
	loopRunning = false
	updateStatus("⏹️ หยุดการทำงานแล้ว")
end)
