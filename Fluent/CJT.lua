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
local roundsBoxFarm = 0
local selectedWorldFarm = nil
local textFarm  = nil
local ReceiveWins = false
local ReceiveCrystal = false

-- Character
local WalkSpeed = nil
local JumpPower = nil

-- Hatch
local hatchLoopRunning = false
local hatchLoopCount = 0
local textHatch = nil
local roundsBoxHatch = 0
local dropdownHatch = nil
local selectedEggId = nil

do
    -------------------------------------------------------
	-- Main
	-------------------------------------------------------
	Tabs.Main:AddSection("[⚙️]Main Options")
	textFarm = Tabs.Main:AddParagraph({ Title = "", Content = ""})
	textFarm.Frame.Text = "📜 Status Porcess....! 📜"
	textFarm.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)

	roundsBoxFarm = Tabs.Main:AddInput("InputRounds", {
		Title = "Rounds",
		Default = "5",
		Placeholder = "Placeholder",
		Numeric = true, -- Only allows numbers
		Finished = false, -- Only calls callback when you press enter
		Callback = function(Value)
			print("Input changed:", Value)
		end
	})
	
	ReceiveWins = Tabs.Main:AddToggle("shouldClaimWins", {
		Title = "Receive Trophy wins", 
		Default = false,
		Callback = function(Value)
			
		end
	})
	
	ReceiveCrystal = Tabs.Main:AddToggle("shouldClaimCrystal", {
		Title = "Receive Enchant Crystal", 
		Default = false,
		Callback = function(Value)
		
		end
	})	
	
	selectedWorldFarm = Tabs.Main:AddDropdown("DropdownWorldFarm", {
		Title = "Select Worlds",
		Values = {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"},
		Multi = false,
		Default = 1,
		Callback = function(Value)
			print("DropdownWorldFarm changed:", Value)
		end
	})
	
	function RunLoopFarm(roundsValue)
		local label = textFarm.Frame
		for i = 1, roundsValue do
			if not Utils.getFarmloopRunning() then break end

			label.Text = ("🔁 รอบที่ " .. i .. "/" .. roundsValue)
			Utils.TpPosStart() task.wait(1)
			Utils.WalkToStairs() task.wait(1)
			Utils.WalkUp() task.wait(3)
			Utils.TpPosTrophy() task.wait(1)

			if ReceiveWins then 
				Utils.ClaimRewardWins() 
				task.wait(1) 
			end	
			if ReceiveCrystal then 
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
			--print(textFarm.Frame.Text)
			--local label = textFarm.Frame -- ตัวนี้เป็น TextButton
			--label.Text = "อัปเดตแล้ว!" -- อัปเดตข้อความ
			--local location = Utils.locationPresets["World1"]
			--print(location.trophy)
			-------------------------------------------------------------

			local label = textFarm.Frame
			local WorldValue = selectedWorldFarm.Value
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

	roundsBoxHatch = Tabs.Hatch:AddInput("InputRounds", {
		Title = "Rounds",
		Default = "5",
		Placeholder = "Placeholder",
		Numeric = true, -- Only allows numbers
		Finished = false, -- Only calls callback when you press enter
		Callback = function(Value)
			print("Input changed:", Value)
		end
	})

	dropdownHatch = Tabs.Hatch:AddDropdown("DropdownWorldFarm", {
		Title = "Select Incubator",
		Values = {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8"},
		Multi = false,
		Default = 1,
		Callback = function(Value)

		end
	})

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
		
	end)
	
	local GetFreeSpin = Tabs.Character:AddToggle("GetFreeSpin", { Title = "Receive Spin", Default = false})
	GetFreeSpin:OnChanged(function(Value)
		
	end)
	
	Tabs.Character:AddSection("[⚙️]Hope Server")
	local HopeServer = Tabs.Character:AddButton({ 
		Title = "", 
		Icon = false,
		Callback = function()
			WalkSpeed:SetValue(16)
			JumpPower:SetValue(50)
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
