local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local rs = game:GetService("ReplicatedStorage")
local toolsFolder = rs:WaitForChild("Tools")
local userInputService = game:GetService("UserInputService")

local screenGui = script.Parent

-- Vine Boom sound setup
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9118824621" -- vine boom sound effect asset ID
sound.Volume = 1
sound.Parent = screenGui
sound:Play()

-- ===== Create main frame for buttons =====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.5, 0)        -- 30% width, 50% height
frame.Position = UDim2.new(0.05, 0, 0.25, 0)  -- left 5%, down 25%
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Mariogui😎"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

-- Tool button info
local toolButtons = {
	{ name = "Gun", color = Color3.fromRGB(200, 50, 50) },
	{ name = "Knife", color = Color3.fromRGB(50, 200, 50) },
	{ name = "OnePunch", color = Color3.fromRGB(255, 215, 0) },
	{ name = "Sword", color = Color3.fromRGB(50, 50, 200) },
}

local buttonHeight = 55
local buttonSpacing = 15

local selectedToolName = nil -- currently selected tool

-- Function to make any tool one-shot
local function makeOneShot(tool)
	local killScript = Instance.new("Script")
	killScript.Source = [[
		local tool = script.Parent
		tool.Activated:Connect(function()
			local char = tool.Parent
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			for _, target in pairs(workspace:GetChildren()) do
				local h = target:FindFirstChild("Humanoid")
				local root = target:FindFirstChild("HumanoidRootPart")
				if h and root and target ~= char then
					if (hrp.Position - root.Position).Magnitude < 6 then
						h.Health = 0
					end
				end
			end
		end)
	]]
	killScript.Parent = tool
end

-- Give tool to player and make one-shot
local function giveTool(name)
	if not name then return end

	-- Remove old tool if exists
	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			tool:Destroy()
		end
	end

	local original = toolsFolder:FindFirstChild(name)
	if original then
		local clone = original:Clone()
		makeOneShot(clone)
		clone.Parent = backpack
		selectedToolName = name
	else
		warn("Tool not found: "..name)
	end
end

-- Create buttons and connect clicks
for i, toolData in ipairs(toolButtons) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, buttonHeight)
	btn.Position = UDim2.new(0.05, 0, 0, 50 + (i-1) * (buttonHeight + buttonSpacing))
	btn.BackgroundColor3 = toolData.color
	btn.Text = "Select " .. toolData.name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 22
	btn.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		giveTool(toolData.name)
	end)
end

-- Initially select first tool
giveTool(toolButtons[1].name)

-- === Tap anywhere to equip & activate current tool ===

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local char = player.Character
		if not char then return end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		-- Ensure tool is equipped
		local tool = backpack:FindFirstChild(selectedToolName)
		if tool then
			tool.Parent = char -- equip tool
			tool:Activate()    -- activate tool (calls Activated event)
		end
	end
end)
