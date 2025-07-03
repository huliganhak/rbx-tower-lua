local Utils = {}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local placeId = game.PlaceId  
local selectedPlatform = nil
local roundsBoxWorks = 0
local roundsBoxParallel = 0
local WorksloopRunning = false

Utils.characterOverride = false
Utils.targetWalkSpeed = 16
Utils.targetJumpPower = 50


function Utils.setselectedPlatform(PlatformId)
	selectedPlatform = PlatformId
end

function Utils.setroundsWorks(ValueWorks)
	roundsBoxWorks = ValueWorks
end

function Utils.setroundsParallel(ValueParallel)
	roundsBoxParallel = ValueParallel
end

function Utils.setWorksloopRunning(state)
	WorksloopRunning = state
end

function Utils.getWorksloopRunning()
	return WorksloopRunning
end

-- ฟังก์ชันยูทิลิตี้
function Utils.WorksLoopPT()
	local args = {
		buffer.fromstring("\028"),
		buffer.fromstring("\254\002\000\006\005Power\001" .. string.char(selectedPlatform))
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Warp"):WaitForChild("Index"):WaitForChild("Event"):WaitForChild("Reliable"):FireServer(unpack(args))
end

function Utils.repeatLoop(index)
	-- print("เริ่มทำงาน", index)
	for j = 1, roundsBoxWorks do
		if not WorksloopRunning then 
			return 
		end
		
		Utils.WorksLoopPT()
		task.wait(0.1)
	end
	-- print("เสร็จแล้ว", index)
end

function Utils.processParallel()
	for i = 1, roundsBoxParallel do
		task.spawn(function()
			Utils.repeatLoop(i)
		end)
	end
end

function Utils.ToggleMainUI(state)
	local mainUI = player:WaitForChild("PlayerGui"):WaitForChild("MainUI")
	if mainUI and mainUI:IsA("ScreenGui") then
		mainUI.Enabled = state
	else
		warn("❌ ไม่พบ MainUI ใน PlayerGui หรือไม่ใช่ ScreenGui")
	end
end

-- ฟังก์ชันย้าย server
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
function Utils.GetHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChildOfClass("Humanoid")
end

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


return Utils
