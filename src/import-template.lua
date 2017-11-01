--[[
	Install script generated by rbxpacker {{VERSION}}.
]]

local source = [=[{{SOURCE}}]=]
local collapseEnabled = {{COLLAPSE}}

local Selection = game:GetService("Selection")
local HttpService = game:GetService("HttpService")

local decoded = HttpService:JSONDecode(source)
local selected = nil
local connections = {}

local function makeLeaf(name, contents)
	local basename, extension = name:match("^(.*)%.(.-)$")

	if extension == "lua" then
		local created = Instance.new("ModuleScript")
		created.Name = basename
		created.Source = contents

		return created
	else
		local created = Instance.new("StringValue")
		created.Name = basename
		created.Value = contents

		return created
	end
end

local function import(root, path, contents)
	local location = root

	for key, piece in ipairs(path) do
		local newLocation = location:FindFirstChild(piece)

		if not newLocation then
			local instance
			if key == #path then
				instance = makeLeaf(piece, contents)
			else
				instance = Instance.new("Folder")
				instance.Name = piece
			end

			instance.Parent = location
			newLocation = instance
		end

		location = newLocation
	end

	return location
end

local function collapseFolder(folder, newRoot)
	newRoot.Parent = folder.Parent
	newRoot.Name = folder.Name

	for _, child in ipairs(folder:GetChildren()) do
		child.Parent = newRoot
	end

	folder:Destroy()

	return newRoot
end

local function tryCollapse(root)
	if root:FindFirstChild("init") then
		root = collapseFolder(root, root:FindFirstChild("init"))
	end

	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("Folder") then
			tryCollapse(child)
		end
	end
end

local ui = Instance.new("ScreenGui")
ui.Name = "rbxpacker"
ui.Parent = game:GetService("CoreGui")

local function install(root)
	for _, file in ipairs(decoded.files) do
		import(root, file.path, file.contents)
	end

	if collapseEnabled then
		tryCollapse(root)
	end
end

local function removeInstaller()
	ui:Destroy()

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}
end

do
	local uiRoot = Instance.new("Frame")
	uiRoot.Size = UDim2.new(0, 400, 0, 180)
	uiRoot.Position = UDim2.new(0.5, 0, 0.5, 0)
	uiRoot.AnchorPoint = Vector2.new(0.5, 0.5)
	uiRoot.BackgroundColor3 = Color3.new(1, 1, 1)
	uiRoot.BorderSizePixel = 0
	uiRoot.Active = true
	uiRoot.Parent = ui

	local title = Instance.new("TextLabel")
	title.Text = "Installing {{NAME}} to:"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 26
	title.Size = UDim2.new(1, 0, 0, 36)
	title.BackgroundTransparency = 1
	title.Parent = uiRoot

	local path = Instance.new("TextLabel")
	path.Text = selected and selected:GetFullName() or ""
	path.Font = Enum.Font.SourceSansBold
	path.TextSize = 18
	path.TextWrapped = true
	path.Size = UDim2.new(1, 0, 0, 64)
	path.Position = UDim2.new(0, 0, 0, 36)
	path.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
	path.TextColor3 = Color3.new(1, 1, 1)
	path.BorderSizePixel = 0
	path.Parent = uiRoot

	local yesButton = Instance.new("TextButton")
	yesButton.Text = "Install"
	yesButton.Font = Enum.Font.SourceSansBold
	yesButton.TextSize = 24
	yesButton.Size = UDim2.new(0, 120, 0, 50)
	yesButton.Position = UDim2.new(0, 16, 1, -16)
	yesButton.AnchorPoint = Vector2.new(0, 1)
	yesButton.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
	yesButton.Parent = uiRoot

	local noButton = Instance.new("TextButton")
	noButton.Text = "Cancel"
	noButton.Font = Enum.Font.SourceSansBold
	noButton.TextSize = 24
	noButton.Size = UDim2.new(0, 120, 0, 50)
	noButton.Position = UDim2.new(1, -16, 1, -16)
	noButton.AnchorPoint = Vector2.new(1, 1)
	noButton.BackgroundColor3 = Color3.new(0.75, 0.75, 0.75)
	noButton.TextColor3 = Color3.new(0, 0, 0)
	noButton.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
	noButton.Parent = uiRoot

	local function setSelected(object)
		selected = object

		if object then
			path.Text = object:GetFullName()
			path.TextColor3 = Color3.new(1, 1, 1)
			yesButton.BackgroundColor3 = Color3.new(0.7, 0.86, 1)
			yesButton.TextColor3 = Color3.new(0, 0, 0)
			yesButton.AutoButtonColor = true
		else
			path.Text = "Select an object in Explorer to install into"
			path.TextColor3 = Color3.new(1, 0.2, 0.4)
			yesButton.BackgroundColor3 = Color3.new(0.7, 0.7, 0.7)
			yesButton.TextColor3 = Color3.new(0.4, 0.4, 0.4)
			yesButton.AutoButtonColor = false
		end
	end

	setSelected(Selection:Get()[1])

	local connection = Selection.SelectionChanged:Connect(function()
		setSelected(Selection:Get()[1])
	end)
	table.insert(connections, connection)

	yesButton.MouseButton1Click:Connect(function()
		if not selected then
			warn("Please select an object in explorer.")
			return
		end

		pcall(install, selected)
		removeInstaller()
	end)

	noButton.MouseButton1Click:Connect(function()
		removeInstaller()
	end)
end