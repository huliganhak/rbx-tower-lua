local Utils = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local selectedWorldFarm = nil
local FarmloopRunning = false

Utils.locationPresets = {
	World1 = { start = Vector3.new(-3.75, 5, -55), stairs = Vector3.new(-3.75, 5, -60), trophy = Vector3.new(-5, 14410, -65), down = Vector3.new(-3.75, 5, -55) },
	World2 = { start = Vector3.new(5000, 5, -60), stairs = Vector3.new(5000, 5, -65), trophy = Vector3.new(5000, 14410, -70), down = Vector3.new(5000, 5, -60) },
	World3 = { start = Vector3.new(10001, 5, -30), stairs = Vector3.new(10001, 5, -35), trophy = Vector3.new(10001, 14410, -40), down = Vector3.new(10001, 5, -30) },
	World4 = { start = Vector3.new(14998, 5, -130), stairs = Vector3.new(14998, 5, -135), trophy = Vector3.new(14998, 14410, -145), down = Vector3.new(14998, 5, -130) },
	World5 = { start = Vector3.new(20001, 5, -70), stairs = Vector3.new(20001, 5, -75), trophy = Vector3.new(20001, 14410, -80), down = Vector3.new(20001, 5, -70) },
	World6 = { start = Vector3.new(25000, 5, -35), stairs = Vector3.new(25000, 5, -40), trophy = Vector3.new(25000, 14410, -45), down = Vector3.new(25000, 5, -35) },
	World7 = { start = Vector3.new(30000, 5, -70), stairs = Vector3.new(30000, 5, -75), trophy = Vector3.new(30000, 14410, -85), down = Vector3.new(30000, 5, -70) },
	World8 = { start = Vector3.new(35000, 5, -35), stairs = Vector3.new(35000, 5, -40), trophy = Vector3.new(35000, 14410, -45), down = Vector3.new(35000, 5, -35) }
}

Utils.hatchPresets = {
	World1 = {"Egg 200", "Egg 20k", "Egg 1M"},
	World2 = {"Egg 400M", "Egg 160B", "Egg 16T"},
	World3 = {"Egg 2.50q", "Egg 1.3Q"},
	World4 = {"Egg 1.90aa", "Egg 2.9bb"},
	World5 = {"Egg 4.30cc", "Egg 6.50dd"},
	World6 = {"Egg 9.70ee", "Egg 15ff"},
	World7 = {"Egg 22gg", "Egg 2.20hh", "Egg 220hh"},
	World8 = {"Egg 44ii", "Egg 4.40jj", "Egg 440jj"}
}

function Utils.setSelectedWorldFarm(name)
	selectedWorldFarm = name
end

function Utils.setFarmloopRunning(state)
	FarmloopRunning = state
end

function Utils.getFarmloopRunning()
	return FarmloopRunning
end

-- ฟังก์ชันยูทิลิตี้
function Utils.getLocation()
	return selectedWorldFarm and Utils.locationPresets[selectedWorldFarm]
end

function Utils.teleportTo(pos)
	local char = player.Character or player.CharacterAdded:Wait()
	char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(pos)
end

function Utils.walkTo(pos)
	local char = player.Character or player.CharacterAdded:Wait()
	char:WaitForChild("Humanoid"):MoveTo(pos)
end

function Utils.walkUp(duration)
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

function Utils.ClaimRewardWins()
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182wins"}
	game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer(unpack(args))
end

function Utils.ClaimRewardMagicToken()
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182MagicToken"}
	game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer(unpack(args))
end

-- ชุดฟังก์ชันตำแหน่ง
function Utils.TpPosStart()
	local l = Utils.getLocation()
	if l then Utils.teleportTo(l.start) end
end

function Utils.WalkToStairs()
	local l = Utils.getLocation()
	if l then Utils.walkTo(l.stairs) end
end

function Utils.WalkUp()
	Utils.walkUp(3)
end

function Utils.TpPosTrophy()
	local l = Utils.getLocation()
	if l then Utils.teleportTo(l.trophy) end
end

function Utils.WalkDown()
	local l = Utils.getLocation()
	if l then Utils.walkTo(l.down) end
end

-- ฟังก์ชันที่เกี่ยวข้องกับการเล่น
function Utils.GetHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChild("Humanoid")
end

return Utils
