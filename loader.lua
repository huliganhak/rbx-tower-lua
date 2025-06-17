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
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local destination = Vector3.new(-3.75, 300, -100)
    humanoid:MoveTo(destination)
    humanoid.MoveToFinished:Wait()
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
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local destination = Vector3.new(-3.75, 5, -55)
    humanoid:MoveTo(destination)
    humanoid.MoveToFinished:Wait()
end

for i = 1, 5 do
    TpPosStart()
    wait(2)

    WalkToStairs()
    wait(2)

    WalkUp()
    wait(2)

    TpPosTrophy()
    wait(2)

    WalkDown()
    wait(5)
end
