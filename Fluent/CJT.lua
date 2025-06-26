local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/InterfaceManager.lua"))()
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/Utils.lua"))()

local Window = Fluent:CreateWindow({
	Title = "Fluent " .. Fluent.Version,
	SubTitle = "by dawid",
	TabWidth = 120,
	Size = UDim2.fromOffset(500, 450),
	Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "globe-2" }),
	Hatch = Window:AddTab({ Title = "Hatch Eggs", Icon = "globe-2" }),
	Character = Window:AddTab({ Title = "Character", Icon = "globe-2" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Window.TabDisplayInSection(true) -- Display the tabs Title at the top of the window true / false

local Options = Fluent.Options

-- Farm
local textFarm  = nil

-- Character
local WalkSpeed = nil
local JumpPower = nil

-- Hatch
local hatchLoopRunning = false
local hatchLoopCount = 0
local textHatch = nil
local selectedEggId = nil

do
	-------------------------------------------------------
	-- Main
	-------------------------------------------------------
	Tabs.Main:AddSection("[⚙️]Main Options")
	textFarm = Tabs.Main:AddParagraph({ Title = "", Content = ""})
	textFarm.Frame.Text = "📜 Status Porcess....! 📜"
	textFarm.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)

	local roundsBoxFarm = Tabs.Main:AddInput("InputRoundsFarm", {
		Title = "Rounds",
		Default = "5",
		Placeholder = "Placeholder",
		Numeric = true, -- Only allows numbers
		Finished = false -- Only calls callback when you press enter
	})
	roundsBoxFarm:OnChanged(function()
		print("InputRoundsFarm changed:", Options.InputRoundsFarm.Value)
	end)
	
	local ReceiveWins = Tabs.Main:AddToggle("shouldClaimWins", { Title = "Receive Trophy wins", Default = false})
	ReceiveWins:OnChanged(function()
		print("ReceiveWins changed:", Options.shouldClaimWins.Value)
	end)
	
	local ReceiveCrystal = Tabs.Main:AddToggle("shouldClaimCrystal", { Title = "Receive Enchant Crystal", Default = false})	
	ReceiveCrystal:OnChanged(function()
		print("ReceiveCrystal changed:", Options.shouldClaimCrystal.Value)
	end)
	
	local selectedWorldFarm = Tabs.Main:AddDropdown("DropdownWorldFarm", {
		Title = "Select Worlds",
		Values = {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"},
		Multi = false,
		Default = 1
	})
	selectedWorldFarm:OnChanged(function(Value)
		print("DropdownWorldFarm changed:", Options.DropdownWorldFarm.Value)
	end)
	
	function RunLoopFarm(roundsValue)
		local label = textFarm.Frame
		for i = 1, roundsValue do
			if not Utils.getFarmloopRunning() then break end

			label.Text = ("🔁 รอบที่ " .. i .. "/" .. roundsValue)
			Utils.TpPosStart() task.wait(1)
			Utils.WalkToStairs() task.wait(1)
			Utils.WalkUp() task.wait(3)
			Utils.TpPosTrophy() task.wait(1)

			if Options.shouldClaimWins.Value then 
				Utils.ClaimRewardWins() 
				task.wait(1) 
			end	
			if Options.shouldClaimCrystal.Value then 
				Utils.ClaimRewardMagicToken() 
				task.wait(1) 
			end

			Utils.WalkDown() task.wait(5)
		end
		label.Text = ("✅ ครบ " .. roundsValue .. " รอบแล้ว")
		Utils.setFarmloopRunning(false)
	end
	local StartMain = Tabs.Main:AddButton({
		Title = "",
		Icon = false,
		Callback = function()
			local label = textFarm.Frame
			local WorldValue = Options.DropdownWorldFarm.Value
			local roundsValue = tonumber(roundsBoxFarm.Value)
			
			print("WorldValue:", WorldValue)
			
			if not WorldValue then 
				label.Text = ("⚠️ กรุณาเลือก World ก่อนเริ่ม") 
				return
			end
			if Utils.getFarmloopRunning() then
				label.Text = ("⚠️ กำลังทำงานอยู่ กรุณาหยุดก่อนเริ่มใหม่")
				return
			end

			if not roundsValue or roundsValue <= 0 then
				label.Text = ("❌ จำนวนรอบไม่ถูกต้อง กรุณากรอกตัวเลขมากกว่า 0")
				return
			end	

			task.spawn(function()
				label.Text =("✅ เริ่มรอบใน " .. WorldValue)
				Utils.setFarmloopRunning(true)
				Utils.setSelectedWorldFarm(WorldValue)
				RunLoopFarm(roundsValue)
				label.Text =("⏹️ เสร็จสิ้นการทำงาน")
			end)
		end
	})
	StartMain.Frame.Text = "Start"
	StartMain.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	local StopMain = Tabs.Main:AddButton({
		Title = "",
		Icon = false,
		Callback = function()
			if Utils.getFarmloopRunning() then
				Utils.setFarmloopRunning(false)
				textFarm.Frame.Text = ("⏹️ หยุดการทำงานแล้ว")
			else
				textFarm.Frame.Text = ("⚠️ ยังไม่ได้เริ่มทำงาน")
			end
		end
	})
	StopMain.Frame.Text = "Stop"
	StopMain.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	-------------------------------------------------------
	-- Hatch Eggs
	-------------------------------------------------------
	Tabs.Hatch:AddSection("[⚙️]Hatch Eggs Options")
	textHatch = Tabs.Hatch:AddParagraph({ Title = "", Content = ""})
	textHatch.Frame.Text = "📜 Status Porcess....! 📜"
	textHatch.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)

	local roundsBoxHatch = Tabs.Hatch:AddInput("InputRoundsHatch", {
		Title = "Rounds",
		Default = "5",
		Placeholder = "Placeholder",
		Numeric = true, -- Only allows numbers
		Finished = false -- Only calls callback when you press enter
	})
	roundsBoxHatch:OnChanged(function(Value)
		print("InputRoundsHatch changed:", Options.InputRoundsHatch.Value)
	end)

	local dropdownHatch = Tabs.Hatch:AddDropdown("DropdownHatch", {
		Title = "Select Incubator",
		Values = {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"},
		Multi = false,
		Default = 1
	})
	dropdownHatch:OnChanged(function(Value)
		print("DropdownHatch changed:", Options.DropdownHatch.Value)
	end)

	local StartHatch = Tabs.Hatch:AddButton({
		Title = "",
		Icon = false,
		Callback = function()

		end
	})
	StartHatch.Frame.Text = "Start"
	StartHatch.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)

	local StopHatch = Tabs.Hatch:AddButton({
		Title = "",
		Icon = false,
		Callback = function()

		end
	})
	StopHatch.Frame.Text = "Stop"
	StopHatch.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	-------------------------------------------------------
	-- Character
	-------------------------------------------------------
	Tabs.Character:AddSection("[⚙️]Character Options")
	WalkSpeed  = Tabs.Character:AddSlider("SliderWalkSpeed", {
		Title = "Walk Speed",
		--Description = "This is a slider",
		Default = 16,
		Min = 1,
		Max = 1000,
		Rounding = 0
	})
	WalkSpeed:OnChanged(function(Value)
		local hum = Utils.GetHumanoid()
		if hum then
			hum.WalkSpeed = Value
		end
	end)
	
	JumpPower  = Tabs.Character:AddSlider("SliderJumpPower", {
		Title = "Jump Power",
		--Description = "This is a slider",
		Default = 50,
		Min = 1,
		Max = 1000,
		Rounding = 0
	})
	JumpPower:OnChanged(function(Value)
		local hum = Utils.GetHumanoid()
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = Value
		end
	end)
	
	local RefreshCharacter = Tabs.Character:AddButton({ 
		Title = "", 
		Icon = false,
		Callback = function()
			WalkSpeed:SetValue(16)
			JumpPower:SetValue(50)
		end
	})
	RefreshCharacter.Frame.Text = "Refresh value"
	RefreshCharacter.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)

	Tabs.Character:AddSection("[⚙️]Reward Options")
	local GetFreeGift = Tabs.Character:AddToggle("GetFreeGift", { Title = "Receive Gift", Default = false})
	GetFreeGift:OnChanged(function(Value)
		if Value then
			Utils.GetFreeGift()
		end
	end)
	
	local GetFreeSpin = Tabs.Character:AddToggle("GetFreeSpin", { Title = "Receive Spin", Default = false})
	GetFreeSpin:OnChanged(function(Value)
		if Value then
			Utils.GetFreeSpin()
		end
	end)
	
	Tabs.Character:AddSection("[⚙️]Hope Server")
	local HopeServer = Tabs.Character:AddButton({ 
		Title = "", 
		Icon = false,
		Callback = function()
			Utils.TeleportToRandomServer()
		end
	})
	HopeServer.Frame.Text = "Hope Server"
	HopeServer.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
