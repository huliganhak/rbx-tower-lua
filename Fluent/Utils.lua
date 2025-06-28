local Utils = {}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local selectedWorldFarm = nil
local FarmloopRunning = false
local FarmloopRunningOPMode = false
local selectedIncubatorHatch = nil
local HatchloopRunning = false

Utils.characterOverride = false
Utils.targetWalkSpeed = 16
Utils.targetJumpPower = 50

Utils.locationPresets = {
	World1 = { start = Vector3.new(-3.75, 5, -55), stairs = Vector3.new(-3.75, 5, -60), trophy = Vector3.new(-5, 14410, -65), down = Vector3.new(-3.75, 5, -55) },
	World2 = { start = Vector3.new(5000, 5, -60), stairs = Vector3.new(5000, 5, -65), trophy = Vector3.new(5000, 14410, -70), down = Vector3.new(5000, 5, -60) },
	World3 = { start = Vector3.new(10001, 5, -30), stairs = Vector3.new(10001, 5, -35), trophy = Vector3.new(10001, 14410, -40), down = Vector3.new(10001, 5, -30) },
	World4 = { start = Vector3.new(14998, 5, -130), stairs = Vector3.new(14998, 5, -135), trophy = Vector3.new(14998, 14410, -145), down = Vector3.new(14998, 5, -130) },
	World5 = { start = Vector3.new(20001, 5, -70), stairs = Vector3.new(20001, 5, -75), trophy = Vector3.new(20001, 14410, -80), down = Vector3.new(20001, 5, -70) },
	World6 = { start = Vector3.new(25000, 5, -35), stairs = Vector3.new(25000, 5, -40), trophy = Vector3.new(25000, 14410, -45), down = Vector3.new(25000, 5, -35) },
	World7 = { start = Vector3.new(30000, 5, -70), stairs = Vector3.new(30000, 5, -75), trophy = Vector3.new(30000, 14410, -85), down = Vector3.new(30000, 5, -70) },
	World8 = { start = Vector3.new(35000, 5, -35), stairs = Vector3.new(35000, 5, -40), trophy = Vector3.new(35000, 14410, -45), down = Vector3.new(35000, 5, -35) },
	World9 = { start = Vector3.new(40000, 5, -165), stairs = Vector3.new(40000, 5, -175), trophy = Vector3.new(40000, 14410, -185), down = Vector3.new(40000, 5, -165) }
}

Utils.hatchPresets = {
	World1 = {"Egg 200", "Egg 20k", "Egg 1M"},
	World2 = {"Egg 400M", "Egg 160B", "Egg 16T"},
	World3 = {"Egg 2.50q", "Egg 1.3Q"},
	World4 = {"Egg 1.90aa", "Egg 2.9bb"},
	World5 = {"Egg 4.30cc", "Egg 6.50dd"},
	World6 = {"Egg 9.70ee", "Egg 15ff"},
	World7 = {"Egg 22gg", "Egg 2.20hh", "Egg 220hh"},
	World8 = {"Egg 44ii", "Egg 4.40jj", "Egg 440jj"},
	World9 = {"Egg 260kk", "Egg 21ll", "Egg 1.70mm"}
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

function Utils.setSelectedIncubatorHatch(name)
	selectedIncubatorHatch = name
end

function Utils.setHatchloopRunning(state)
	HatchloopRunning = state
end

function Utils.getHatchloopRunning()
	return HatchloopRunning
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
	--[[
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182wins"}
	game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer(unpack(args))
	]]
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182wins"}
	game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

function Utils.ClaimRewardMagicToken()
	--[[
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182MagicToken"}
	game:GetService("ReplicatedStorage").Msg.RemoteEvent:FireServer(unpack(args))
	]]
	local args = {"\233\162\134\229\143\150\230\165\188\233\161\182MagicToken"}
	game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

-- ฟังก์ชันสุ่มไข่สัตย์เลี้ยง
function Utils.HatchEgg(eggId)
	local args = {eggId, 3}
	game:GetService("ReplicatedStorage"):WaitForChild("Tool"):WaitForChild("DrawUp"):WaitForChild("Msg"):WaitForChild("DrawHero"):InvokeServer(unpack(args))
end

function Utils.BuildIncubatorMapAndOptions(presets)
	local map = {}
	local options = {}
	local count = 0

	for worldIndex = 1, 9 do
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
	return char:FindFirstChildOfClass("Humanoid")
end

function Utils.GetFreeGift()
	local remote = game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent")
	local msg = "\233\162\134\229\143\150\229\156\168\231\186\191\229\165\150\229\138\177"
	for i = 1, 12 do
		local args = {msg, i}
		remote:FireServer(unpack(args))
	end
end

function Utils.GetFreeSpin()
	for i = 1, 5 do
		game:GetService("ReplicatedStorage"):WaitForChild("System"):WaitForChild("SystemDailyLottery"):WaitForChild("Spin"):InvokeServer()
	end
end

function Utils.TeleportToRandomServer()
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	local nextCursor = nil
	local targetServer = nil

	local function ListServers(cursor)
		local fullUrl = url .. ((cursor and "&cursor=" .. cursor) or "")
		local raw = game:HttpGet(fullUrl)
		return HttpService:JSONDecode(raw)
	end

	repeat
		local servers = ListServers(nextCursor)
		local data = servers.data

		if #data > 0 then
			-- เลือกเซิร์ฟเวอร์แบบสุ่ม จาก 1 ถึง ประมาณ 1/3 ของจำนวนทั้งหมด เพื่อกระจายความหนาแน่น
			local index = math.random(1, math.max(1, math.floor(#data / 3)))
			local candidate = data[index]

			if candidate and candidate.playing < candidate.maxPlayers and candidate.id ~= game.JobId then
				targetServer = candidate
			end
		end

		nextCursor = servers.nextPageCursor
	until targetServer or not nextCursor

	if targetServer then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, game.Players.LocalPlayer)
	else
		warn("Suitable target server not found.")
	end
end

-- ฟังก์ชัน Speed และ Jump
function Utils.SetCharacterOverride(value)
	Utils.characterOverride = value
end
function Utils.SetTargetWalkSpeed(value)
	Utils.targetWalkSpeed = value
end
function Utils.SetTargetJumpPower(value)
	Utils.targetJumpPower = value
end

function Utils.StartCharacterOverride()
	if Utils.characterOverride then return end
	Utils.characterOverride = true
	task.spawn(function()
		while Utils.characterOverride do
			task.wait(0.5)
			local hum = Utils.GetHumanoid()
			if hum then
				hum.WalkSpeed = Utils.targetWalkSpeed
				hum.UseJumpPower = true
				hum.JumpPower = Utils.targetJumpPower
			end
		end
	end)
end

function Utils.StopCharacterOverride()
	Utils.characterOverride = false
	Utils.targetWalkSpeed = 16
	Utils.targetJumpPower = 50
	local hum = Utils.GetHumanoid()
	if hum then
		hum.WalkSpeed = Utils.targetWalkSpeed
		hum.UseJumpPower = false
		hum.JumpPower = Utils.targetJumpPower
	end
end

-- OP Mode New

function Utils.setFarmloopRunningOPMode(state)
	FarmloopRunningOPMode = state
end

function Utils.getFarmloopRunningOPMode()
	return FarmloopRunningOPMode
end


function Utils.OPMode()
	print("RunLoopCHTM Called")
	local args = {
		"\232\181\183\232\183\179",
		14408.80
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
	task.wait(2)

	local args = {
		"isAutoOn",
		0
	}
	game:GetService("ReplicatedStorage"):WaitForChild("ServerMsg"):WaitForChild("Setting"):InvokeServer(unpack(args))
	task.wait(2)

	local args = {
		"\232\181\183\232\183\179",
		14400.80
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
	task.wait(2)

	local args = {
		"\232\144\189\229\156\176"
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
	task.wait(2)
end


return Utils
