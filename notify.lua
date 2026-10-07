-- kittyware notifs
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local WIDTH = 300
local PAD = 10
local IMAGE = 44
local TITLE_FONT, TITLE_SIZE = Enum.Font.GothamSemibold, 14
local DESC_FONT, DESC_SIZE = Enum.Font.Gotham, 14

local gui = Instance.new("ScreenGui")
gui.Name = "KittyNotif"
gui.ResetOnSpawn = false
gui.DisplayOrder = 50
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local placed = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not placed or not gui.Parent then
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local list = Instance.new("Frame")
list.Name = "Container"
list.BackgroundTransparency = 1
list.Position = UDim2.new(0, 20, 0.5, -20)
list.Size = UDim2.new(0, WIDTH, 0.5, 0)
list.Parent = gui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local order = 0

local function textHeight(text, font, size, width)
	local plain = tostring(text):gsub("<[^>]->", "") -- strip rich text tags
	return TextService:GetTextSize(plain, size, font, Vector2.new(width, math.huge)).Y
end

local function label(parent, text, font, size, y, x, width, height, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.RichText = true
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.Font = font
	l.TextSize = size
	l.TextColor3 = color
	l.Text = text
	l.Position = UDim2.fromOffset(x, y)
	l.Size = UDim2.fromOffset(width, height)
	l.Parent = parent
	return l
end

local function fade(root, time)
	local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("TextLabel") then
			TweenService:Create(obj, info, {TextTransparency = 1}):Play()
		elseif obj:IsA("ImageLabel") then
			TweenService:Create(obj, info, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
		elseif obj:IsA("UIStroke") then
			TweenService:Create(obj, info, {Transparency = 1}):Play()
		elseif obj:IsA("Frame") and obj.BackgroundTransparency < 1 then
			TweenService:Create(obj, info, {BackgroundTransparency = 1}):Play()
		end
	end
end

local function Notify(props)
	props = type(props) == "table" and props or {}
	local title = props.Title
	local desc = props.Description
	local image = props.Image
	if type(image) ~= "string" or image == "" then image = nil end
	local duration = tonumber(props.Duration) or 5

	local textX = PAD + (image and IMAGE + PAD or 0)
	local textW = WIDTH - textX - PAD
	local titleH = title and textHeight(title, TITLE_FONT, TITLE_SIZE, textW) or 0
	local descH = desc and textHeight(desc, DESC_FONT, DESC_SIZE, textW) or 0
	local gap = (title and desc) and 4 or 0
	local height = math.max(PAD + titleH + gap + descH + PAD, image and IMAGE + PAD * 2 or 0)

	order += 1
	local slot = Instance.new("Frame")
	slot.BackgroundTransparency = 1
	slot.LayoutOrder = order
	slot.Size = UDim2.fromOffset(WIDTH, height)
	slot.Parent = list

	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
	card.BorderSizePixel = 0
	card.Size = UDim2.fromScale(1, 1)
	card.Position = UDim2.fromOffset(-(WIDTH + 30), 0)
	card.Parent = slot
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = card
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 64)
	stroke.Transparency = 0.3
	stroke.Parent = card

	if image then
		local pic = Instance.new("ImageLabel")
		pic.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
		pic.BorderSizePixel = 0
		pic.Image = image
		pic.ScaleType = Enum.ScaleType.Crop
		pic.Size = UDim2.fromOffset(IMAGE, IMAGE)
		pic.Position = UDim2.fromOffset(PAD, math.floor((height - IMAGE) / 2))
		pic.Parent = card
		local picCorner = Instance.new("UICorner")
		picCorner.CornerRadius = UDim.new(0, 5)
		picCorner.Parent = pic
	end

	local y = PAD
	if title then
		label(card, title, TITLE_FONT, TITLE_SIZE, y, textX, textW, titleH, Color3.fromRGB(255, 255, 255))
		y += titleH + gap
	end
	if desc then
		label(card, desc, DESC_FONT, DESC_SIZE, y, textX, textW, descH, Color3.fromRGB(200, 200, 205))
	end

	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(0, 0)}):Play()

	task.delay(duration, function()
		if not slot.Parent then return end
		fade(slot, 0.25)
		task.wait(0.25)
		TweenService:Create(slot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(WIDTH, 0)}):Play()
		task.wait(0.2)
		slot:Destroy()
	end)
end

local function Destroy()
	gui:Destroy()
end

return {Notify = Notify, Destroy = Destroy}
