local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ตรวจสอบและสร้าง ScreenGui ถ้ายังไม่มี
local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("TeleportUI")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 🌟 ฟังก์ชันช่วยสร้าง UICorner (ทำขอบมน)
local function applyRoundedCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = instance
end

-- 🌟 ฟังก์ชันช่วยสร้างปุ่ม
local function createButton(parent, text, position, size)
	local btn = Instance.new("TextButton")
	btn.Text = text
	btn.Position = position
	btn.Size = size
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextScaled = true
	btn.AutoButtonColor = true
	btn.Parent = parent
	applyRoundedCorner(btn, 10)
	return btn
end

-- 🌟 ฟังก์ชันช่วยสร้าง TextBox
local function createTextBox(parent, placeholder, position, size, editable)
	local box = Instance.new("TextBox")
	box.PlaceholderText = placeholder or ""
	box.Position = position
	box.Size = size
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.ClearTextOnFocus = false
	box.TextEditable = editable ~= false
	box.TextWrapped = true
	box.Font = Enum.Font.Gotham
	box.TextScaled = true
	box.Parent = parent
	applyRoundedCorner(box, 10)
	return box
end

-- 🌟 Frame หลัก
local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.Size = UDim2.new(0, 300, 0, 280)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Visible = true
applyRoundedCorner(frame, 12)

-- ช่องแสดงสถานะ
local detailBox = createTextBox(frame, nil, UDim2.new(0.05, 0, 0.05, 0), UDim2.new(0.9, 0, 0.1, 0), false)
detailBox.Text = "สถานะ..."
detailBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

-- ช่องใส่จำนวนรอบ
local roundsBox = createTextBox(frame, "จำนวนรอบ", UDim2.new(0.1, 0, 0.12, 0), UDim2.new(0.8, 0, 0.15, 0), true)

-- ปุ่มเริ่มและหยุด
local startButton = createButton(frame, "เริ่ม", UDim2.new(0.1, 0, 0.35, 0), UDim2.new(0.35, 0, 0.15, 0))
local stopButton = createButton(frame, "หยุด", UDim2.new(0.55, 0, 0.35, 0), UDim2.new(0.35, 0, 0.15, 0))

-- ปุ่ม Dropdown หลัก
local dropdownMain = createButton(frame, "เลือก World", UDim2.new(0.1, 0, 0.65, 0), UDim2.new(0.8, 0, 0.15, 0))

-- กรอบรายการ Dropdown
local dropdownFrame = Instance.new("Frame", frame)
dropdownFrame.Position = UDim2.new(0.1, 0, 0.8, 0)
dropdownFrame.Size = UDim2.new(0.8, 0, 0, 0)
dropdownFrame.ClipsDescendants = true
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownFrame.BorderSizePixel = 1
dropdownFrame.Visible = false
applyRoundedCorner(dropdownFrame, 8)

-- ตัวอย่าง dropdown options
local layout = Instance.new("UIListLayout", dropdownFrame)
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local exampleWorlds = { "World1", "World2", "World3", "World4" }

for _, name in pairs(exampleWorlds) do
	local option = createButton(dropdownFrame, name, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 24))
	option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	option.Size = UDim2.new(1, 0, 0, 24)
end
