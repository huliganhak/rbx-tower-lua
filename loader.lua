function TpPosStart()
	-- ย้ายไปหน้าบรรได
    local player = game.Players.LocalPlayer

    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local location = Vector3.new(-3.75, 5, -55)
        player.Character.HumanoidRootPart.CFrame = CFrame.new(location)
    end
end

function WalkToStairs()
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ตำแหน่งเป้าหมาย
local destination = Vector3.new(-3.75, 5, -60)

-- สั่งให้เดินไปตำแหน่งนั้น
humanoid:MoveTo(destination)
end

function WalkUp()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local startTime = tick()

	RunService:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, function()
		if tick() - startTime > 1 then
			RunService:UnbindFromRenderStep("move")
			return
		end

		if player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid:Move(Vector3.new(0, 0, -50), true)
			end
		end
	end)
end

function TpPosTrophy()
	-- ย้ายไปข้างบนสุด
    local player = game.Players.LocalPlayer

    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local location = Vector3.new(-5, 14410, -65)
        player.Character.HumanoidRootPart.CFrame = CFrame.new(location)
    end
end

function WalkDown()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local startTime = tick()

	RunService:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, function()
		if tick() - startTime > 5 then
			RunService:UnbindFromRenderStep("move")
			return
		end

		if player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid:Move(Vector3.new(0, 0, 50), true)
			end
		end
	end)
end

for i = 1, 5 do
    TpPosStart()
    wait(1)

    WalkToStairs()
    wait(1)

    WalkUp()
    wait(1)

    TpPosTrophy()
    wait(1)

    WalkDown()
    wait(5)
end
