local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ✅ ตัวแปรควบคุม
local loopRunning = false

-- ✅ UI สร้างจาก Script
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "TeleportUI"

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

-- ✅ กด P เพื่อเปิด/ปิด UI
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
		frame.Visible = not frame.Visible
	end
end)

-- ✅ ฟังก์ชัน Teleport/Walk ต่าง ๆ (ย่อเพื่ออ่านง่าย)
local function TpPosStart()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(-3.75, 5, -55)
	end
end

local function WalkToStairs()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:MoveTo(Vector3.new(-3.75, 5, -60))
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

local function TpPosTrophy()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(-5, 14410, -65)
	end
end

local function WalkDown()
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid:MoveTo(Vector3.new(-3.75, 5, -55))
	end
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

-- ✅ เริ่มเมื่อกดปุ่ม "เริ่ม"
startButton.MouseButton1Click:Connect(function()
	local rounds = tonumber(roundsBox.Text)
	if rounds and rounds > 0 then
		if not loopRunning then
			task.spawn(function()
				RunLoop(rounds)
			end)
		end
	end
end)

-- ✅ หยุดลูปเมื่อกด "หยุด"
stopButton.MouseButton1Click:Connect(function()
	loopRunning = false
end)
