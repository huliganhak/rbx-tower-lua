local locationPresets = {
	A = {
		start = Vector3.new(-3.75, 5, -55),
		stairs = Vector3.new(-3.75, 5, -60),
		trophy = Vector3.new(-5, 14410, -65),
		down = Vector3.new(-3.75, 5, -55),
	},
	B = {
		start = Vector3.new(10, 3, 20),
		stairs = Vector3.new(10, 3, 25),
		trophy = Vector3.new(12, 15000, 22),
		down = Vector3.new(10, 3, 20),
	}
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local loopRunning = false

-- 🔧 ตรวจสอบว่ามี UI เดิมอยู่หรือไม่
local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("TeleportUI")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ✅ UI (สร้างใหม่ทุกครั้งแค่ภายใน TeleportUI)
local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.Size = UDim2.new(0, 250, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = true

local roundsBox = Instance.new("TextBox", frame)
roundsBox.PlaceholderText = "จำนวนรอบ"
roundsBox.Position = UDim2.new(0.1, 0, 0.1, 0)
roundsBox.Size = UDim2.new(0.8, 0, 0.2, 0)
roundsBox.Text = ""

local startButton = Instance.new("TextButton", frame)
startButton.Text = "เริ่ม"
startButton.Position = UDim2.new(0.1, 0, 0.4, 0)
startButton.Size = UDim2.new(0.35, 0, 0.25, 0)

local stopButton = Instance.new("TextButton", frame)
stopButton.Text = "หยุด"
stopButton.Position = UDim2.new(0.55, 0, 0.4, 0)
stopButton.Size = UDim2.new(0.35, 0, 0.25, 0)

local presetBox = Instance.new("TextBox", frame)
presetBox.PlaceholderText = "เลือกประเภท: A หรือ B"
presetBox.Position = UDim2.new(0.1, 0, 0.7, 0)
presetBox.Size = UDim2.new(0.8, 0, 0.2, 0)
presetBox.Text = ""

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
local function TpPosStart(preset)
	local pos = locationPresets[preset]?.start
	if pos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
	end
end

local function WalkToStairs(preset)
	local pos = locationPresets[preset]?.stairs
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	if pos then humanoid:MoveTo(pos) end
end

local function WalkUp()
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

local function TpPosTrophy(preset)
	local pos = locationPresets[preset]?.trophy
	if pos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
	end
end

local function WalkDown(preset)
	local pos = locationPresets[preset]?.down
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid and pos then
		humanoid:MoveTo(pos)
	end
end

-- ✅ ฟังก์ชันรันลูป
local function RunLoop(rounds, preset)
	loopRunning = true
	for i = 1, rounds do
		if not loopRunning then break end

		TpPosStart(preset)
		task.wait(1)

		WalkToStairs(preset)
		task.wait(1)

		WalkUp()
		task.wait(3)

		TpPosTrophy(preset)
		task.wait(1)

		WalkDown(preset)
		task.wait(5)
	end
end

-- ✅ เริ่มลูป
startButton.MouseButton1Click:Connect(function()
	local rounds = tonumber(roundsBox.Text)
	local preset = presetBox.Text:upper() -- แปลงให้เป็นตัวใหญ่ เช่น "A", "B"
	if rounds and rounds > 0 and locationPresets[preset] then
		if not loopRunning then
			task.spawn(function()
				RunLoop(rounds, preset)
			end)
		end
	end
end)

-- ✅ หยุดลูป
stopButton.MouseButton1Click:Connect(function()
	loopRunning = false
end)
