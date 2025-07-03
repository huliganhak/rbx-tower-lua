local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/InterfaceManager.lua"))()
local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/huliganhak/rbx-tower-lua/main/Fluent/UtilsPT.lua"))()

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


do
	-------------------------------------------------------
	-- Main
	-------------------------------------------------------
	Tabs.Main:AddSection("[⚙️]Main Options")
	textFarm = Tabs.Main:AddParagraph({ Title = "", Content = ""})
	textFarm.Frame.Text = "📜 Status Porcess....! 📜"
	textFarm.Frame.TextColor3 = Color3.fromRGB(0, 170, 127)

	local selectedPlatform= Tabs.Main:AddDropdown("DropdownPlatform", {
		Title = "Select Platform",
		Values = {"lane - 1", "lane - 2", "lane - 3", "lane - 4", "lane - 5", "lane - 6", "lane - 7", "lane - 8", "lane - 9", "lane - 10", "lane - 11", "lane - 12"},
		Multi = false,
		Default = 1
	})
	selectedPlatform:OnChanged(function(Value)
		--print("DropdownWorldFarm changed:", Options.DropdownWorldFarm.Value)
	end)
	
	local roundsBoxParallel = Tabs.Main:AddInput("InputParallelCount", {
		Title = "Parallel Count",
		Default = "20",
		Placeholder = "Placeholder",
		Numeric = true, -- Only allows numbers
		Finished = false -- Only calls callback when you press enter
	})
	roundsBoxParallel:OnChanged(function()
		--print("InputRoundsFarm changed:", Options.InputRoundsFarm.Value)
	end)
	
	local roundsBoxWorks = Tabs.Main:AddInput("InputWorksCount", {
		Title = "Works Count",
		Default = "500",
		Placeholder = "Placeholder",
		Numeric = true, -- Only allows numbers
		Finished = false -- Only calls callback when you press enter
	})
	roundsBoxWorks:OnChanged(function()
		--print("InputRoundsFarm changed:", Options.InputRoundsFarm.Value)
	end)
	
	local ToggleMainUI = Tabs.Main:AddToggle("ToggleHideUI", { Title = "Hide UI Setting", Default = false})
	ToggleMainUI:OnChanged(function(Value)	
		if not initialized_UI then
			initialized_UI = true
			return -- ข้ามครั้งแรก (Fluent เรียกเอง)
		end
		
		if Value then
			Utils.ToggleMainUI(false)
		else
			Utils.ToggleMainUI(true)
		end	
	end)

	function RunLoopEnergy()
		Utils.processParallel()
	end
	local StartMain = Tabs.Main:AddButton({
		Title = "",
		Icon = false,
		Callback = function()
			local label = textFarm.Frame
			local PlatformData = Options.DropdownPlatform.Value
			local ParallelValue = tonumber(Options.InputParallelCount.Value)
			local WorksValue = tonumber(Options.InputWorksCount.Value)

			if not PlatformData then 
				label.Text = ("⚠️ กรุณาเลือก Platform ก่อนเริ่ม") 
				return
			end
			if Utils.getWorksloopRunning() then
				label.Text = ("⚠️ กำลังทำงานอยู่ กรุณาหยุดก่อนเริ่มใหม่")
				return
			end

			if not ParallelValue or ParallelValue <= 0 then
				label.Text = ("❌ จำนวนรอบไม่ถูกต้อง กรุณากรอกตัวเลขมากกว่า 0")
				return
			end	
			
			if not WorksValue or WorksValue <= 0 then
				label.Text = ("❌ จำนวนรอบไม่ถูกต้อง กรุณากรอกตัวเลขมากกว่า 0")
				return
			end	

			local PlatformValue = tonumber(PlatformData:match("%d+"))	
			if not PlatformValue then
				label.Text = "❌ ไม่สามารถแปลง Platform เป็นตัวเลขได้"
				return
			end
			
			task.spawn(function()
				label.Text =("✅ เริ่มใน " .. PlatformData)
				Utils.setWorksloopRunning(true)
				Utils.setselectedPlatform(PlatformValue)
				Utils.setroundsWorks(WorksValue)
				Utils.setroundsParallel(ParallelValue)
				RunLoopEnergy()
				label.Text =("⏹️ เสร็จสิ้นการทำงาน 💪")
			end)
		end
	})
	StartMain.Frame.Text = "Start"
	StartMain.Frame.TextColor3 = Color3.fromRGB(0, 170, 0)
	StartMain.Frame.TextSize = 14
	StartMain.Frame.Font = Enum.Font.GothamBold

	local StopMain = Tabs.Main:AddButton({
		Title = "",
		Icon = false,
		Callback = function()
			if Utils.getWorksloopRunning() then
				Utils.setWorksloopRunning(false)
				textFarm.Frame.Text = ("⏹️ หยุดการทำงานแล้ว 🧗")
			else
				textFarm.Frame.Text = ("⚠️ ยังไม่ได้เริ่มทำงาน 🧗")
			end
		end
	})
	StopMain.Frame.Text = "Stop"
	StopMain.Frame.TextColor3 = Color3.fromRGB(255, 85, 0)
	StopMain.Frame.TextSize = 14
	StopMain.Frame.Font = Enum.Font.GothamBold


	-------------------------------------------------------
	-- Character
	-------------------------------------------------------
	Tabs.Character:AddSection("[⚙️]Character Options")
	WalkSpeed  = Tabs.Character:AddSlider("SliderWalkSpeed", {
		Title = "Walk Speed",
		--Description = "This is a slider",
		Default = 16,
		Min = 1,
		Max = 15000,
		Rounding = 0
	})
	WalkSpeed:OnChanged(function(Value)
		--print("SliderWalkSpeed Changed")
		Utils.SetTargetWalkSpeed(Options.SliderWalkSpeed.Value)
	end)


	JumpPower  = Tabs.Character:AddSlider("SliderJumpPower", {
		Title = "Jump Power",
		--Description = "This is a slider",
		Default = 50,
		Min = 1,
		Max = 15000,
		Rounding = 0
	})
	JumpPower:OnChanged(function(Value)
		--print("SliderJumpPower Changed")
		Utils.SetTargetJumpPower(Options.SliderJumpPower.Value)
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
	RefreshCharacter.Frame.TextColor3 = Color3.fromRGB(0, 170, 0)
	RefreshCharacter.Frame.TextSize = 14
	RefreshCharacter.Frame.Font = Enum.Font.GothamBold

	local ToggleCharacter = Tabs.Character:AddToggle("ToggleCharacter", { Title = "Enable Character Setting", Default = false})
	ToggleCharacter:OnChanged(function(Value)
		if Value then
			Utils.SetTargetWalkSpeed(Options.SliderWalkSpeed.Value)
			Utils.SetTargetJumpPower(Options.SliderJumpPower.Value)
			Utils.StartCharacterOverride()
		else
			Utils.StopCharacterOverride()
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
	HopeServer.Frame.TextColor3 = Color3.fromRGB(0, 170, 0)
	HopeServer.Frame.TextSize = 14
	HopeServer.Frame.Font = Enum.Font.GothamBold
	
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
