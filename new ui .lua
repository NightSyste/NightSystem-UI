local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local FlagsProxy = setmetatable({}, {
	__index = function(t, k)
		local dummy = {
			Value = false,
			Type = "Dummy",
			Set = function(self, val) self.Value = val end,
			SetValue = function(self, val) self.Value = val end,
			OnChanged = function() end,
		}
		rawset(t, k, dummy)
		return dummy
	end
})

local Library = {
	Flags = FlagsProxy,
	Options = FlagsProxy,
	Toggles = FlagsProxy,
	Windows = {},
	Notifications = {},
	ToggleKey = Enum.KeyCode.LeftControl,
	Theme = {
		NeonBorder   = Color3.fromRGB(145, 212, 248),
		CardBorder   = Color3.fromRGB(130, 192, 228),
		SubBorder    = Color3.fromRGB(112, 168, 202),
		GlassBg      = Color3.fromRGB(18, 26, 35),
		CardBg       = Color3.fromRGB(16, 24, 33),
		ControlBg    = Color3.fromRGB(38, 54, 70),
		TextWhite    = Color3.fromRGB(255, 255, 255),
		TextBright   = Color3.fromRGB(255, 255, 255),
		TextMuted    = Color3.fromRGB(190, 214, 232),
		CheckFill    = Color3.fromRGB(126, 192, 232),
		SliderFill   = Color3.fromRGB(142, 208, 246),
		CloseRed     = Color3.fromRGB(235, 70, 92),
		CloseBorder  = Color3.fromRGB(255, 120, 140),
		Transparency = 0.36,
	}
}
Library.__index = Library

local function getGuiParent()
	local okHui, hui = pcall(function()
		if gethui then
			local h = gethui()
			if h then
				local _ = h:FindFirstChild("_")
				return h
			end
		end
		return nil
	end)
	if okHui and hui then return hui end

	local okCore, core = pcall(function()
		local c = game:GetService("CoreGui")
		local _ = c:FindFirstChild("RobloxGui")
		return c
	end)
	if okCore and core then return core end

	return LocalPlayer:WaitForChild("PlayerGui")
end

local function mountScreenGui(screenGui, guiName)
	local parent = getGuiParent()
	local ok = pcall(function()
		local existing = parent:FindFirstChild(guiName)
		if existing then
			existing:Destroy()
		end
		screenGui.Parent = parent
	end)
	if not ok or not screenGui.Parent then
		local pg = LocalPlayer:WaitForChild("PlayerGui")
		pcall(function()
			local existing = pg:FindFirstChild(guiName)
			if existing then
				existing:Destroy()
			end
		end)
		screenGui.Parent = pg
	end
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Library.Theme.CardBorder
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0.25
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function addPadding(parent, top, bottom, left, right)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, top or 0)
	pad.PaddingBottom = UDim.new(0, bottom or 0)
	pad.PaddingLeft = UDim.new(0, left or 0)
	pad.PaddingRight = UDim.new(0, right or 0)
	pad.Parent = parent
	return pad
end

local function addSizeConstraint(parent, minSize, maxSize)
	local sc = Instance.new("UISizeConstraint")
	if minSize then sc.MinSize = minSize end
	if maxSize then sc.MaxSize = maxSize end
	sc.Parent = parent
	return sc
end

local function styleBrightButtonText(textObj, fontSize)
	textObj.TextColor3 = Color3.fromRGB(255, 255, 255)
	textObj.Font = Enum.Font.GothamBold
	textObj.TextSize = fontSize or 13
	textObj.TextStrokeColor3 = Color3.fromRGB(10, 18, 28)
	textObj.TextStrokeTransparency = 0.52
end

local function applyMetallicHeader(frame)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.38
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(48, 66, 84)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(78, 104, 128)),
		ColorSequenceKeypoint.new(0.56, Color3.fromRGB(150, 184, 210)),
		ColorSequenceKeypoint.new(0.78, Color3.fromRGB(88, 116, 142)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(44, 62, 80)),
	})
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.32),
		NumberSequenceKeypoint.new(0.52, 0.22),
		NumberSequenceKeypoint.new(0.56, 0.08),
		NumberSequenceKeypoint.new(1.00, 0.35),
	})
	grad.Rotation = 18
	grad.Parent = frame
	return grad
end

local function applyButtonGradient(frame, isHovered)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = isHovered and 0.12 or 0.26

	local grad = frame:FindFirstChildOfClass("UIGradient")
	if not grad then
		grad = Instance.new("UIGradient")
		grad.Rotation = 22
		grad.Parent = frame
	end

	if isHovered then
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(84, 122, 154)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(152, 206, 242)),
			ColorSequenceKeypoint.new(0.56, Color3.fromRGB(190, 232, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(74, 108, 138)),
		})
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0.00, 0.15),
			NumberSequenceKeypoint.new(0.54, 0.05),
			NumberSequenceKeypoint.new(1.00, 0.18),
		})
	else
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(52, 76, 98)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(96, 136, 168)),
			ColorSequenceKeypoint.new(0.56, Color3.fromRGB(128, 174, 208)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(44, 64, 84)),
		})
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0.00, 0.28),
			NumberSequenceKeypoint.new(0.54, 0.14),
			NumberSequenceKeypoint.new(1.00, 0.32),
		})
	end

	if not frame:FindFirstChild("TopShine") then
		local shine = Instance.new("Frame")
		shine.Name = "TopShine"
		shine.Size = UDim2.new(1, -8, 0, 1)
		shine.Position = UDim2.new(0, 4, 0, 1)
		shine.BackgroundColor3 = Color3.fromRGB(225, 246, 255)
		shine.BackgroundTransparency = 0.42
		shine.BorderSizePixel = 0
		shine.ZIndex = frame.ZIndex + 1
		shine.Parent = frame
	end

	return grad
end

local function attachButtonFX(btn, stroke)
	local btnScale = btn:FindFirstChildOfClass("UIScale")
	if not btnScale then
		btnScale = Instance.new("UIScale")
		btnScale.Scale = 1
		btnScale.Parent = btn
	end

	btn.MouseEnter:Connect(function()
		applyButtonGradient(btn, true)
		if stroke then
			tween(stroke, TweenInfo.new(0.14), {
				Transparency = 0.0,
				Color = Library.Theme.NeonBorder
			})
		end
		tween(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.015 })
	end)

	btn.MouseLeave:Connect(function()
		applyButtonGradient(btn, false)
		if stroke then
			tween(stroke, TweenInfo.new(0.16), {
				Transparency = 0.16,
				Color = Library.Theme.NeonBorder
			})
		end
		tween(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.0 })
	end)

	btn.MouseButton1Down:Connect(function()
		tween(btnScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.965 })
	end)

	btn.MouseButton1Up:Connect(function()
		tween(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.015 })
	end)
end

local function attachTouchScrollBarAndArrows(parentFrame, scrollFrame, layoutObj, railPosition, railSize, stepPixels)
	stepPixels = stepPixels or 95

	local Rail = Instance.new("Frame")
	Rail.Name = "MobileScrollRail"
	Rail.Position = railPosition
	Rail.Size = railSize
	Rail.BackgroundTransparency = 1
	Rail.ZIndex = 6
	Rail.Parent = parentFrame

	local btnHeight = 15

	local UpBtn = Instance.new("TextButton")
	UpBtn.Name = "ScrollUpBtn"
	UpBtn.Size = UDim2.new(1, 0, 0, btnHeight)
	UpBtn.Position = UDim2.new(0, 0, 0, 0)
	UpBtn.Text = "▲"
	UpBtn.AutoButtonColor = false
	UpBtn.ZIndex = 7
	UpBtn.Parent = Rail
	styleBrightButtonText(UpBtn, 9)
	addCorner(UpBtn, 4)
	local upStroke = addStroke(UpBtn, Library.Theme.NeonBorder, 1.0, 0.18)
	applyButtonGradient(UpBtn, false)
	attachButtonFX(UpBtn, upStroke)

	local DownBtn = Instance.new("TextButton")
	DownBtn.Name = "ScrollDownBtn"
	DownBtn.Size = UDim2.new(1, 0, 0, btnHeight)
	DownBtn.Position = UDim2.new(0, 0, 1, -btnHeight)
	DownBtn.Text = "▼"
	DownBtn.AutoButtonColor = false
	DownBtn.ZIndex = 7
	DownBtn.Parent = Rail
	styleBrightButtonText(DownBtn, 9)
	addCorner(DownBtn, 4)
	local downStroke = addStroke(DownBtn, Library.Theme.NeonBorder, 1.0, 0.18)
	applyButtonGradient(DownBtn, false)
	attachButtonFX(DownBtn, downStroke)

	local TrackBtn = Instance.new("TextButton")
	TrackBtn.Name = "ThickScrollTrack"
	TrackBtn.Size = UDim2.new(0, 4, 1, -(btnHeight * 2 + 6))
	TrackBtn.Position = UDim2.new(0.5, -2, 0, btnHeight + 3)
	TrackBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 42)
	TrackBtn.BackgroundTransparency = 0.52
	TrackBtn.BorderSizePixel = 0
	TrackBtn.Text = ""
	TrackBtn.AutoButtonColor = false
	TrackBtn.ZIndex = 7
	TrackBtn.Parent = Rail
	addCorner(TrackBtn, 2)
	addStroke(TrackBtn, Library.Theme.SubBorder, 1, 0.35)

	local Thumb = Instance.new("Frame")
	Thumb.Name = "ThickThumb"
	Thumb.Size = UDim2.new(1, 0, 0.35, 0)
	Thumb.Position = UDim2.new(0, 0, 0, 0)
	Thumb.BackgroundColor3 = Library.Theme.NeonBorder
	Thumb.BackgroundTransparency = 0.14
	Thumb.BorderSizePixel = 0
	Thumb.ZIndex = 8
	Thumb.Parent = TrackBtn
	addCorner(Thumb, 2)
	addStroke(Thumb, Color3.fromRGB(240, 252, 255), 1, 0.2)

	local function getMaxScroll()
		local canvasH = scrollFrame.CanvasSize.Y.Offset
		local viewH = scrollFrame.AbsoluteWindowSize.Y
		return math.max(0, canvasH - viewH)
	end

	local function updateThumbFromScroll()
		local canvasH = scrollFrame.CanvasSize.Y.Offset
		local viewH = scrollFrame.AbsoluteWindowSize.Y
		local maxScroll = math.max(0, canvasH - viewH)
		if maxScroll <= 2 then
			Thumb.Size = UDim2.new(1, 0, 1, 0)
			Thumb.Position = UDim2.new(0, 0, 0, 0)
		else
			local ratio = math.clamp(viewH / math.max(1, canvasH), 0.16, 0.92)
			local scrollPct = math.clamp(scrollFrame.CanvasPosition.Y / maxScroll, 0, 1)
			Thumb.Size = UDim2.new(1, 0, ratio, 0)
			Thumb.Position = UDim2.new(0, 0, scrollPct * (1 - ratio), 0)
		end
	end

	scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateThumbFromScroll)
	scrollFrame:GetPropertyChangedSignal("CanvasSize"):Connect(updateThumbFromScroll)
	scrollFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateThumbFromScroll)
	task.defer(updateThumbFromScroll)

	local function scrollByDelta(deltaY)
		local maxS = getMaxScroll()
		local targetY = math.clamp(scrollFrame.CanvasPosition.Y + deltaY, 0, maxS)
		tween(scrollFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, targetY)
		})
	end

	local holdingUp = false
	local holdingDown = false

	UpBtn.MouseButton1Down:Connect(function()
		holdingUp = true
		scrollByDelta(-stepPixels)
		task.spawn(function()
			task.wait(0.26)
			while holdingUp do
				scrollByDelta(-math.floor(stepPixels * 0.55))
				task.wait(0.06)
			end
		end)
	end)
	UpBtn.MouseButton1Up:Connect(function() holdingUp = false end)
	UpBtn.MouseLeave:Connect(function() holdingUp = false end)

	DownBtn.MouseButton1Down:Connect(function()
		holdingDown = true
		scrollByDelta(stepPixels)
		task.spawn(function()
			task.wait(0.26)
			while holdingDown do
				scrollByDelta(math.floor(stepPixels * 0.55))
				task.wait(0.06)
			end
		end)
	end)
	DownBtn.MouseButton1Up:Connect(function() holdingDown = false end)
	DownBtn.MouseLeave:Connect(function() holdingDown = false end)

	local draggingTrack = false
	local function setScrollFromInput(input)
		local trackTop = TrackBtn.AbsolutePosition.Y
		local trackH = math.max(1, TrackBtn.AbsoluteSize.Y)
		local pct = math.clamp((input.Position.Y - trackTop) / trackH, 0, 1)
		local maxS = getMaxScroll()
		scrollFrame.CanvasPosition = Vector2.new(0, math.floor(maxS * pct))
	end

	TrackBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingTrack = true
			setScrollFromInput(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingTrack = false
			holdingUp = false
			holdingDown = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingTrack and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setScrollFromInput(input)
		end
	end)

	return Rail
end

local function resolveKeyItem(val)
	if typeof(val) == "EnumItem" then
		return val
	elseif type(val) == "string" and val ~= "" then
		if Enum.KeyCode[val] then
			return Enum.KeyCode[val]
		elseif Enum.UserInputType[val] then
			return Enum.UserInputType[val]
		end
	end
	return nil
end

local function formatKeyName(keyItem)
	if not keyItem then return "None" end
	local name = keyItem.Name or tostring(keyItem)
	local shortNames = {
		RightShift = "RShift",
		LeftShift = "LShift",
		RightControl = "RCtrl",
		LeftControl = "LCtrl",
		RightAlt = "RAlt",
		LeftAlt = "LAlt",
		MouseButton1 = "MB1",
		MouseButton2 = "MB2",
		MouseButton3 = "MB3",
		Backspace = "Back",
		CapsLock = "Caps",
	}
	return shortNames[name] or name
end

local function normalizeArgs(kind, a, b, c, d, e)
	if type(a) == "table" then
		return a
	end
	local cfg = { Name = tostring(a or kind) }
	if kind == "Toggle" then
		if type(b) == "boolean" then
			cfg.Default = b
			cfg.Callback = type(c) == "function" and c or nil
		elseif type(b) == "function" then
			cfg.Callback = b
		else
			cfg.Callback = type(c) == "function" and c or (type(d) == "function" and d or nil)
			if type(c) == "boolean" then cfg.Default = c end
		end
	elseif kind == "Button" then
		if type(b) == "function" then
			cfg.Callback = b
		elseif type(c) == "function" then
			cfg.Callback = c
		end
	elseif kind == "Slider" then
		if type(b) == "string" and type(c) == "number" and type(d) == "number" then
			cfg.Min = math.min(c, d)
			cfg.Max = math.max(c, d)
			cfg.Default = cfg.Min
			cfg.Callback = type(e) == "function" and e or nil
		elseif type(b) == "number" and type(c) == "number" then
			cfg.Min = math.min(b, c)
			cfg.Max = math.max(b, c)
			cfg.Default = type(d) == "number" and d or cfg.Min
			cfg.Callback = type(e) == "function" and e or (type(d) == "function" and d or nil)
		end
	elseif kind == "Dropdown" then
		if type(b) == "table" then
			cfg.Options = b
			if type(c) == "function" then
				cfg.Callback = c
			else
				cfg.Default = c
				cfg.Callback = type(d) == "function" and d or nil
			end
		elseif type(c) == "table" then
			cfg.Options = c
			cfg.Callback = type(d) == "function" and d or nil
		end
	elseif kind == "Colorpicker" then
		if typeof(b) == "Color3" then
			cfg.Default = b
			cfg.Callback = type(c) == "function" and c or nil
		elseif typeof(c) == "Color3" then
			cfg.Default = c
			cfg.Callback = type(d) == "function" and d or nil
		end
	elseif kind == "Bind" then
		if (typeof(b) == "EnumItem" or type(b) == "string") and type(c) == "function" then
			cfg.Default = b
			cfg.Callback = c
		elseif typeof(c) == "EnumItem" or type(c) == "string" then
			cfg.Default = c
			cfg.Callback = type(d) == "function" and d or nil
		elseif type(b) == "function" then
			cfg.Callback = b
		end
	elseif kind == "Textbox" then
		if type(b) == "function" then
			cfg.Callback = b
		elseif type(c) == "function" then
			cfg.Default = tostring(b or "")
			cfg.Callback = c
		elseif type(d) == "function" then
			cfg.Callback = d
		end
	end
	return cfg
end

local function registerFlag(flag, name, obj)
	if flag and flag ~= "" then
		rawset(Library.Flags, flag, obj)
	end
	if name and name ~= "" and rawget(Library.Flags, name) == nil then
		rawset(Library.Flags, name, obj)
	end
end

local NotifScreenGui = nil

function Library.MakeNotification(selfOrCfg, maybeCfg)
	local config = (selfOrCfg == Library) and maybeCfg or selfOrCfg
	config = type(config) == "table" and config or { Name = "Notification", Content = tostring(config or "") }
	local titleText = config.Name or config.Title or "NightSystem"
	local bodyText  = config.Content or config.Text or config.Description or ""
	local duration  = config.Time or config.Duration or 4

	if not NotifScreenGui or not NotifScreenGui.Parent then
		NotifScreenGui = Instance.new("ScreenGui")
		NotifScreenGui.Name = "NightSystemNotifications"
		NotifScreenGui.ResetOnSpawn = false
		NotifScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		mountScreenGui(NotifScreenGui, "NightSystemNotifications")

		local holder = Instance.new("Frame")
		holder.Name = "Holder"
		holder.Size = UDim2.new(0, 290, 1, -24)
		holder.Position = UDim2.new(1, -304, 0, 12)
		holder.BackgroundTransparency = 1
		holder.Parent = NotifScreenGui

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.Padding = UDim.new(0, 8)
		layout.Parent = holder
	end

	local holder = NotifScreenGui:FindFirstChild("Holder")
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 68)
	card.BackgroundColor3 = Library.Theme.CardBg
	card.BackgroundTransparency = 0.18
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.Parent = holder
	addCorner(card, 7)
	addStroke(card, Library.Theme.NeonBorder, 1.3, 0.15)

	local cardScale = Instance.new("UIScale")
	cardScale.Scale = 0.85
	cardScale.Parent = card
	tween(cardScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 })

	local hdr = Instance.new("Frame")
	hdr.Size = UDim2.new(1, 0, 0, 24)
	hdr.BorderSizePixel = 0
	hdr.Parent = card
	addCorner(hdr, 7)
	applyMetallicHeader(hdr)

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -16, 1, 0)
	tLbl.Position = UDim2.new(0, 10, 0, 0)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = tostring(titleText)
	styleBrightButtonText(tLbl, 13)
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Parent = hdr

	local cLbl = Instance.new("TextLabel")
	cLbl.Size = UDim2.new(1, -20, 1, -30)
	cLbl.Position = UDim2.new(0, 10, 0, 26)
	cLbl.BackgroundTransparency = 1
	cLbl.Text = tostring(bodyText)
	cLbl.TextColor3 = Library.Theme.TextMuted
	cLbl.Font = Enum.Font.Gotham
	cLbl.TextSize = 12
	cLbl.TextWrapped = true
	cLbl.TextXAlignment = Enum.TextXAlignment.Left
	cLbl.TextYAlignment = Enum.TextYAlignment.Top
	cLbl.Parent = card

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 2)
	bar.Position = UDim2.new(0, 0, 1, -2)
	bar.BackgroundColor3 = Library.Theme.NeonBorder
	bar.BorderSizePixel = 0
	bar.Parent = card

	tween(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
	task.delay(duration, function()
		if card and card.Parent then
			tween(cardScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.05 })
			tween(card, TweenInfo.new(0.22), { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) })
			task.wait(0.23)
			if card then card:Destroy() end
		end
	end)
end
Library.Notify           = Library.MakeNotification
Library.Notification     = Library.MakeNotification
Library.SendNotification = Library.MakeNotification

function Library:SetToggleKey(newKey)
	local resolved = resolveKeyItem(newKey)
	if resolved then
		self.ToggleKey = resolved
		for _, win in ipairs(self.Windows) do
			if win.SetToggleKey then
				win:SetToggleKey(resolved)
			end
		end
	end
end

function Library:Init()
	return self
end
function Library:LoadConfiguration()
	return self
end
function Library:SaveConfiguration()
	return self
end

function Library:Destroy()
	for _, win in ipairs(self.Windows) do
		if win.ScreenGui and win.ScreenGui.Parent then
			win.ScreenGui:Destroy()
		end
	end
	if NotifScreenGui and NotifScreenGui.Parent then
		NotifScreenGui:Destroy()
	end
end
Library.Unload = Library.Destroy

local BASE_WIDTH  = 860
local BASE_HEIGHT = 500

local function playPrettyLoader(screenGui, titleText, onFinished)
	local LoaderCard = Instance.new("Frame")
	LoaderCard.Name = "NightSystemLoader"
	LoaderCard.AnchorPoint = Vector2.new(0.5, 0.5)
	LoaderCard.Size = UDim2.new(0, 340, 0, 148)
	LoaderCard.Position = UDim2.new(0.5, 0, 0.5, 0)
	LoaderCard.BackgroundColor3 = Color3.fromRGB(18, 26, 36)
	LoaderCard.BackgroundTransparency = 0.28
	LoaderCard.BorderSizePixel = 0
	LoaderCard.ZIndex = 50
	LoaderCard.Parent = screenGui
	addCorner(LoaderCard, 10)
	local loaderStroke = addStroke(LoaderCard, Library.Theme.NeonBorder, 1.5, 0.08)

	local loaderScale = Instance.new("UIScale")
	loaderScale.Scale = 0.05
	loaderScale.Parent = LoaderCard

	local lGrad = Instance.new("UIGradient")
	lGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 34, 46)),
		ColorSequenceKeypoint.new(0.53, Color3.fromRGB(36, 48, 62)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(118, 145, 172)),
		ColorSequenceKeypoint.new(0.74, Color3.fromRGB(46, 62, 80)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 25, 34)),
	})
	lGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.32),
		NumberSequenceKeypoint.new(0.53, 0.28),
		NumberSequenceKeypoint.new(0.55, 0.10),
		NumberSequenceKeypoint.new(0.76, 0.24),
		NumberSequenceKeypoint.new(1.00, 0.36),
	})
	lGrad.Rotation = 68
	lGrad.Parent = LoaderCard

	local lGlow = Instance.new("Frame")
	lGlow.Size = UDim2.new(1, 8, 1, 8)
	lGlow.Position = UDim2.new(0, -4, 0, -4)
	lGlow.BackgroundTransparency = 1
	lGlow.ZIndex = 49
	lGlow.Parent = LoaderCard
	addCorner(lGlow, 13)
	addStroke(lGlow, Library.Theme.NeonBorder, 2.0, 0.65)

	for i = 1, 3 do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 9, 0, 9)
		dot.Position = UDim2.new(0, 14 + (i - 1) * 15, 0, 12)
		dot.BackgroundColor3 = Color3.fromRGB(24, 34, 46)
		dot.BackgroundTransparency = 0.72
		dot.ZIndex = 52
		dot.Parent = LoaderCard
		addCorner(dot, 5)
		addStroke(dot, Library.Theme.NeonBorder, 1, 0.25)
	end

	local SpinnerOuter = Instance.new("Frame")
	SpinnerOuter.Size = UDim2.new(0, 42, 0, 42)
	SpinnerOuter.Position = UDim2.new(0, 22, 0, 44)
	SpinnerOuter.BackgroundColor3 = Color3.fromRGB(24, 34, 46)
	SpinnerOuter.BackgroundTransparency = 0.35
	SpinnerOuter.ZIndex = 52
	SpinnerOuter.Parent = LoaderCard
	addCorner(SpinnerOuter, 21)
	local spinStroke = addStroke(SpinnerOuter, Library.Theme.NeonBorder, 2.0, 0.08)

	local spinGrad = Instance.new("UIGradient")
	spinGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.0),
		NumberSequenceKeypoint.new(0.65, 0.25),
		NumberSequenceKeypoint.new(1.00, 0.85),
	})
	spinGrad.Parent = spinStroke

	local SpinnerCore = Instance.new("TextLabel")
	SpinnerCore.Size = UDim2.new(1, 0, 1, 0)
	SpinnerCore.BackgroundTransparency = 1
	SpinnerCore.Text = "✦"
	SpinnerCore.TextColor3 = Library.Theme.NeonBorder
	SpinnerCore.Font = Enum.Font.GothamBold
	SpinnerCore.TextSize = 18
	SpinnerCore.ZIndex = 53
	SpinnerCore.Parent = SpinnerOuter

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Size = UDim2.new(1, -88, 0, 24)
	TitleLbl.Position = UDim2.new(0, 76, 0, 42)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.Text = tostring(titleText)
	styleBrightButtonText(TitleLbl, 17)
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
	TitleLbl.ZIndex = 52
	TitleLbl.Parent = LoaderCard

	local SubLbl = Instance.new("TextLabel")
	SubLbl.Size = UDim2.new(1, -88, 0, 18)
	SubLbl.Position = UDim2.new(0, 76, 0, 66)
	SubLbl.BackgroundTransparency = 1
	SubLbl.Text = "Initializing UI..."
	SubLbl.TextColor3 = Library.Theme.TextMuted
	SubLbl.Font = Enum.Font.GothamMedium
	SubLbl.TextSize = 12
	SubLbl.TextXAlignment = Enum.TextXAlignment.Left
	SubLbl.ZIndex = 52
	SubLbl.Parent = LoaderCard

	local PctLbl = Instance.new("TextLabel")
	PctLbl.Size = UDim2.new(0, 54, 0, 18)
	PctLbl.Position = UDim2.new(1, -68, 0, 96)
	PctLbl.BackgroundTransparency = 1
	PctLbl.Text = "0%"
	styleBrightButtonText(PctLbl, 12)
	PctLbl.TextXAlignment = Enum.TextXAlignment.Right
	PctLbl.ZIndex = 52
	PctLbl.Parent = LoaderCard

	local BarTrack = Instance.new("Frame")
	BarTrack.Size = UDim2.new(1, -36, 0, 8)
	BarTrack.Position = UDim2.new(0, 18, 0, 118)
	BarTrack.BackgroundColor3 = Color3.fromRGB(20, 30, 42)
	BarTrack.BackgroundTransparency = 0.45
	BarTrack.BorderSizePixel = 0
	BarTrack.ZIndex = 52
	BarTrack.Parent = LoaderCard
	addCorner(BarTrack, 4)
	addStroke(BarTrack, Library.Theme.SubBorder, 1, 0.35)

	local BarFill = Instance.new("Frame")
	BarFill.Size = UDim2.new(0, 0, 1, 0)
	BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BarFill.BorderSizePixel = 0
	BarFill.ZIndex = 53
	BarFill.Parent = BarTrack
	addCorner(BarFill, 4)
	applyButtonGradient(BarFill, true)

	local spinning = true
	task.spawn(function()
		while spinning and LoaderCard.Parent do
			spinGrad.Rotation = (spinGrad.Rotation + 14) % 360
			SpinnerCore.Rotation = (SpinnerCore.Rotation - 8) % 360
			task.wait(0.02)
		end
	end)

	tween(loaderScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 })

	task.spawn(function()
		local steps = {
			{ pct = 0.22, txt = "Initializing NightSystem Glass UI...", waitTime = 1.15 },
			{ pct = 0.54, txt = "Loading Frosted Theme & Shaders...", waitTime = 1.35 },
			{ pct = 0.85, txt = "Building Tabs & Responsive Grid...", waitTime = 1.30 },
			{ pct = 1.00, txt = "Ready!", waitTime = 1.20 },
		}
		local currentPct = 0
		for _, st in ipairs(steps) do
			SubLbl.Text = st.txt
			tween(BarFill, TweenInfo.new(st.waitTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(st.pct, 0, 1, 0)
			})
			local startP = currentPct
			local elapsed = 0
			while elapsed < st.waitTime do
				local dt = task.wait(0.02)
				elapsed = elapsed + dt
				local alpha = math.clamp(elapsed / st.waitTime, 0, 1)
				local val = math.floor((startP + (st.pct - startP) * alpha) * 100 + 0.5)
				PctLbl.Text = tostring(val) .. "%"
			end
			currentPct = st.pct
		end

		spinning = false
		local pop = tween(loaderScale, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.08 })
		pop.Completed:Connect(function()
			tween(LoaderCard, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 0.95 })
			local shrink = tween(loaderScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.01 })
			shrink.Completed:Connect(function()
				if LoaderCard then LoaderCard:Destroy() end
				if onFinished then onFinished() end
			end)
		end)
	end)
end

function Library.MakeWindow(selfOrConfig, maybeConfig)
	local config = (selfOrConfig == Library) and maybeConfig or selfOrConfig
	if type(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local windowTitle = config.Name or config.Title or config.LoadingTitle or "NightSystem"
	local toggleKey   = resolveKeyItem(config.ToggleKey or config.Bind) or Library.ToggleKey
	local winWidth    = config.Width or BASE_WIDTH
	local winHeight   = config.Height or BASE_HEIGHT

	local guiName = "NightSystemUI_" .. tostring(windowTitle):gsub("%W", "")

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = guiName
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mountScreenGui(ScreenGui, guiName)

	local MainWin = Instance.new("Frame")
	MainWin.Name = "MainWin"
	MainWin.AnchorPoint = Vector2.new(0.5, 0.5)
	MainWin.Size = UDim2.new(0, winWidth, 0, winHeight)
	MainWin.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainWin.BackgroundColor3 = Color3.fromRGB(16, 24, 34)
	MainWin.BackgroundTransparency = Library.Theme.Transparency
	MainWin.BorderSizePixel = 0
	MainWin.Active = true
	MainWin.Visible = false
	MainWin.Parent = ScreenGui
	addCorner(MainWin, 10)
	local MainStroke = addStroke(MainWin, Library.Theme.NeonBorder, 1.4, 0.12)

	local userScale = 1.0
	local WinScale = Instance.new("UIScale")
	WinScale.Scale = 0.02
	WinScale.Parent = MainWin

	local WinGrad = Instance.new("UIGradient")
	WinGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 30, 42)),
		ColorSequenceKeypoint.new(0.53, Color3.fromRGB(34, 46, 60)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(118, 145, 172)),
		ColorSequenceKeypoint.new(0.74, Color3.fromRGB(46, 62, 80)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16, 24, 34)),
	})
	WinGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.38),
		NumberSequenceKeypoint.new(0.53, 0.35),
		NumberSequenceKeypoint.new(0.55, 0.10),
		NumberSequenceKeypoint.new(0.76, 0.28),
		NumberSequenceKeypoint.new(1.00, 0.40),
	})
	WinGrad.Rotation = 68
	WinGrad.Parent = MainWin

	local OuterGlow = Instance.new("Frame")
	OuterGlow.Name = "OuterGlow"
	OuterGlow.Size = UDim2.new(1, 6, 1, 6)
	OuterGlow.Position = UDim2.new(0, -3, 0, -3)
	OuterGlow.BackgroundTransparency = 1
	OuterGlow.ZIndex = 0
	OuterGlow.Parent = MainWin
	addCorner(OuterGlow, 12)
	addStroke(OuterGlow, Library.Theme.NeonBorder, 2, 0.65)

	local BottomAccent = Instance.new("Frame")
	BottomAccent.Name = "BottomAccent"
	BottomAccent.Size = UDim2.new(0, 185, 0, 2)
	BottomAccent.Position = UDim2.new(0, 8, 1, 1)
	BottomAccent.BackgroundColor3 = Library.Theme.NeonBorder
	BottomAccent.BackgroundTransparency = 0.35
	BottomAccent.BorderSizePixel = 0
	BottomAccent.Parent = MainWin
	addCorner(BottomAccent, 1)

	local ContentWrap = Instance.new("Frame")
	ContentWrap.Name = "ContentWrap"
	ContentWrap.Size = UDim2.new(1, 0, 0, winHeight - 36)
	ContentWrap.Position = UDim2.new(0, 0, 0, 36)
	ContentWrap.BackgroundTransparency = 1
	ContentWrap.Parent = MainWin

	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 36)
	TitleBar.BackgroundTransparency = 1
	TitleBar.Parent = MainWin

	local TitleDivider = Instance.new("Frame")
	TitleDivider.Name = "TitleDivider"
	TitleDivider.Size = UDim2.new(1, 0, 0, 1)
	TitleDivider.Position = UDim2.new(0, 0, 1, -1)
	TitleDivider.BackgroundColor3 = Library.Theme.NeonBorder
	TitleDivider.BackgroundTransparency = 0.65
	TitleDivider.BorderSizePixel = 0
	TitleDivider.Parent = TitleBar

	for i = 1, 3 do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 10, 0, 10)
		dot.Position = UDim2.new(0, 16 + (i - 1) * 16, 0, 13)
		dot.BackgroundColor3 = Color3.fromRGB(24, 34, 46)
		dot.BackgroundTransparency = 0.75
		dot.Parent = TitleBar
		addCorner(dot, 5)
		addStroke(dot, Library.Theme.NeonBorder, 1.1, 0.25)
	end

	local TitleText = Instance.new("TextLabel")
	TitleText.Name = "TitleText"
	TitleText.Size = UDim2.new(1, -240, 1, 0)
	TitleText.Position = UDim2.new(0, 120, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = tostring(windowTitle)
	TitleText.TextColor3 = Color3.fromRGB(224, 240, 252)
	TitleText.Font = Enum.Font.GothamMedium
	TitleText.TextSize = 13
	TitleText.TextStrokeColor3 = Color3.fromRGB(10, 18, 28)
	TitleText.TextStrokeTransparency = 0.52
	TitleText.TextTruncate = Enum.TextTruncate.AtEnd
	TitleText.Parent = TitleBar

	local function createGlassControlBtn(iconText, rightOffset, isCloseBtn, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 28, 0, 22)
		btn.Position = UDim2.new(1, rightOffset, 0.5, -11)
		btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundTransparency = isCloseBtn and 0.20 or 0.32
		btn.BorderSizePixel = 0
		btn.Text = iconText
		styleBrightButtonText(btn, isCloseBtn and 13 or 12)
		btn.AutoButtonColor = false
		btn.Parent = TitleBar
		addCorner(btn, 6)

		local btnScale = Instance.new("UIScale")
		btnScale.Scale = 1
		btnScale.Parent = btn

		local grad = Instance.new("UIGradient")
		grad.Rotation = 25
		grad.Parent = btn

		local stroke = addStroke(
			btn,
			isCloseBtn and Library.Theme.CloseBorder or Library.Theme.NeonBorder,
			1.2,
			isCloseBtn and 0.10 or 0.20
		)

		local shine = Instance.new("Frame")
		shine.Size = UDim2.new(1, -8, 0, 1)
		shine.Position = UDim2.new(0, 4, 0, 1)
		shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		shine.BackgroundTransparency = 0.48
		shine.BorderSizePixel = 0
		shine.Parent = btn

		local function setVisual(hovered)
			if isCloseBtn then
				if hovered then
					grad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 105, 125)),
						ColorSequenceKeypoint.new(0.50, Color3.fromRGB(240, 62, 88)),
						ColorSequenceKeypoint.new(1.00, Color3.fromRGB(185, 32, 56)),
					})
					btn.BackgroundTransparency = 0.06
					stroke.Transparency = 0.0
					stroke.Color = Color3.fromRGB(255, 175, 190)
				else
					grad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0.00, Color3.fromRGB(210, 64, 86)),
						ColorSequenceKeypoint.new(0.50, Color3.fromRGB(168, 42, 64)),
						ColorSequenceKeypoint.new(1.00, Color3.fromRGB(125, 28, 44)),
					})
					btn.BackgroundTransparency = 0.20
					stroke.Transparency = 0.12
					stroke.Color = Library.Theme.CloseBorder
				end
			else
				if hovered then
					grad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0.00, Color3.fromRGB(108, 150, 185)),
						ColorSequenceKeypoint.new(0.50, Color3.fromRGB(165, 215, 248)),
						ColorSequenceKeypoint.new(1.00, Color3.fromRGB(82, 118, 148)),
					})
					btn.BackgroundTransparency = 0.12
					stroke.Transparency = 0.0
					stroke.Color = Library.Theme.NeonBorder
				else
					grad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0.00, Color3.fromRGB(60, 84, 108)),
						ColorSequenceKeypoint.new(0.50, Color3.fromRGB(94, 130, 160)),
						ColorSequenceKeypoint.new(1.00, Color3.fromRGB(48, 68, 88)),
					})
					btn.BackgroundTransparency = 0.32
					stroke.Transparency = 0.25
					stroke.Color = Library.Theme.CardBorder
				end
			end
		end

		setVisual(false)

		btn.MouseEnter:Connect(function()
			setVisual(true)
			tween(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.08 })
		end)
		btn.MouseLeave:Connect(function()
			setVisual(false)
			tween(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.0 })
		end)
		btn.MouseButton1Down:Connect(function()
			tween(btnScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.92 })
		end)
		btn.MouseButton1Up:Connect(function()
			tween(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.08 })
		end)
		btn.MouseButton1Click:Connect(callback)
		return btn
	end

	local isMinimized = false
	local isWindowOpen = false
	local isAnimatingWindow = false
	local currentScalePreset = 1

	local pillWidth = math.clamp(#tostring(windowTitle) * 8 + 68, 140, 260)
	local MobileOpenPill = Instance.new("TextButton")
	MobileOpenPill.Name = "MobileOpenPill"
	MobileOpenPill.AnchorPoint = Vector2.new(0.5, 0)
	MobileOpenPill.Size = UDim2.new(0, pillWidth, 0, 30)
	MobileOpenPill.Position = UDim2.new(0.5, 0, 0, 10)
	MobileOpenPill.Text = "≡ " .. tostring(windowTitle)
	MobileOpenPill.AutoButtonColor = false
	MobileOpenPill.Visible = false
	MobileOpenPill.ZIndex = 40
	MobileOpenPill.Parent = ScreenGui
	styleBrightButtonText(MobileOpenPill, 12)
	addCorner(MobileOpenPill, 15)
	local pillOpenStroke = addStroke(MobileOpenPill, Library.Theme.NeonBorder, 1.4, 0.1)
	applyButtonGradient(MobileOpenPill, false)
	attachButtonFX(MobileOpenPill, pillOpenStroke)

	local function updatePillLabel()
		if isWindowOpen then
			MobileOpenPill.Text = "✕ Close " .. tostring(windowTitle)
		else
			MobileOpenPill.Text = "≡ Open " .. tostring(windowTitle)
		end
	end

	local pillDragging = false
	local pillDragStart = nil
	local pillStartPos = nil
	local pillMoved = false

	MobileOpenPill.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pillDragging = true
			pillMoved = false
			pillDragStart = input.Position
			pillStartPos = MobileOpenPill.Position

			local endedConn
			endedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					pillDragging = false
					if endedConn then endedConn:Disconnect() end
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if pillDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - pillDragStart
			if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
				pillMoved = true
			end
			MobileOpenPill.Position = UDim2.new(
				pillStartPos.X.Scale,
				pillStartPos.X.Offset + delta.X,
				pillStartPos.Y.Scale,
				pillStartPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pillDragging = false
		end
	end)

	local function closeWindowAnimated()
		if isAnimatingWindow or not isWindowOpen then return end
		isAnimatingWindow = true
		isWindowOpen = false
		updatePillLabel()

		local expandScale = userScale * 1.085
		local step1 = tween(WinScale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = expandScale
		})
		step1.Completed:Connect(function()
			tween(MainWin, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 0.92
			})
			tween(MainStroke, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 0.95
			})
			local step2 = tween(WinScale, TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Scale = 0.01
			})
			step2.Completed:Connect(function()
				MainWin.Visible = false
				MobileOpenPill.Visible = true
				isAnimatingWindow = false
				if type(config.CloseCallback) == "function" then
					task.spawn(config.CloseCallback)
				end
			end)
		end)
	end

	local function openWindowAnimated()
		if isAnimatingWindow or isWindowOpen then return end
		isAnimatingWindow = true
		isWindowOpen = true
		updatePillLabel()
		MobileOpenPill.Visible = true

		WinScale.Scale = 0.02
		MainWin.BackgroundTransparency = 0.85
		MainStroke.Transparency = 0.85
		MainWin.Visible = true

		tween(MainWin, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = Library.Theme.Transparency
		})
		tween(MainStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.08
		})

		local popScale = userScale * 1.06
		local step1 = tween(WinScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = popScale
		})
		step1.Completed:Connect(function()
			local step2 = tween(WinScale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Scale = userScale
			})
			step2.Completed:Connect(function()
				isAnimatingWindow = false
			end)
		end)
	end

	MobileOpenPill.MouseButton1Click:Connect(function()
		if pillMoved then
			pillMoved = false
			return
		end
		if isWindowOpen then
			closeWindowAnimated()
		else
			openWindowAnimated()
		end
	end)

	playPrettyLoader(ScreenGui, windowTitle, function()
		MobileOpenPill.Visible = true
		openWindowAnimated()
	end)

	createGlassControlBtn("—", -98, false, function()
		if isAnimatingWindow then return end
		isMinimized = not isMinimized
		local halfDelta = math.floor((winHeight - 36) / 2 * userScale)
		if isMinimized then
			ContentWrap.Size = UDim2.new(1, 0, 0, winHeight - 36)
			MainWin.ClipsDescendants = true
			BottomAccent.Visible = false
			tween(MainWin, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, winWidth, 0, 36),
				Position = UDim2.new(
					MainWin.Position.X.Scale,
					MainWin.Position.X.Offset,
					MainWin.Position.Y.Scale,
					MainWin.Position.Y.Offset - halfDelta
				)
			})
		else
			local t = tween(MainWin, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, winWidth, 0, winHeight),
				Position = UDim2.new(
					MainWin.Position.X.Scale,
					MainWin.Position.X.Offset,
					MainWin.Position.Y.Scale,
					MainWin.Position.Y.Offset + halfDelta
				)
			})
			t.Completed:Connect(function()
				if not isMinimized then
					MainWin.ClipsDescendants = false
					BottomAccent.Visible = true
				end
			end)
		end
	end)

	createGlassControlBtn("□", -66, false, function()
		if isAnimatingWindow then return end
		if currentScalePreset == 1 then
			currentScalePreset = 2
			userScale = 0.82
		elseif currentScalePreset == 2 then
			currentScalePreset = 3
			userScale = 1.12
		else
			currentScalePreset = 1
			userScale = 1.0
		end
		tween(WinScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = userScale })
	end)

	createGlassControlBtn("✕", -34, true, function()
		closeWindowAnimated()
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		local isCtrl = (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl)
		if not gp and isCtrl then
			if isWindowOpen then
				closeWindowAnimated()
			else
				openWindowAnimated()
			end
		end
	end)

	do
		local dragging, dragInput, dragStart, startPos
		TitleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = MainWin.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		TitleBar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				MainWin.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	local ResizeGrip = Instance.new("TextButton")
	ResizeGrip.Name = "ResizeGrip"
	ResizeGrip.Size = UDim2.new(0, 18, 0, 18)
	ResizeGrip.Position = UDim2.new(1, -18, 1, -18)
	ResizeGrip.BackgroundTransparency = 1
	ResizeGrip.Text = "◢"
	ResizeGrip.TextColor3 = Library.Theme.SubBorder
	ResizeGrip.TextTransparency = 0.35
	ResizeGrip.Font = Enum.Font.GothamBold
	ResizeGrip.TextSize = 12
	ResizeGrip.ZIndex = 10
	ResizeGrip.Parent = ContentWrap

	do
		local resizing = false
		local resizeStartPos = nil
		local startScale = 1
		local startWidth = winWidth
		local startHeight = winHeight

		ResizeGrip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				resizeStartPos = input.Position
				startScale = userScale
				startWidth = winWidth
				startHeight = winHeight
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - resizeStartPos
				local desiredVisualW = math.clamp(startWidth * startScale + delta.X, 480, 1400)
				local desiredVisualH = math.clamp(startHeight * startScale + delta.Y, 300, 950)

				if desiredVisualW < BASE_WIDTH then
					userScale = math.clamp(desiredVisualW / BASE_WIDTH, 0.55, 1)
					WinScale.Scale = userScale
					winWidth = BASE_WIDTH
					winHeight = math.clamp(math.floor(desiredVisualH / userScale), 420, 850)
				else
					userScale = 1
					WinScale.Scale = 1
					winWidth = math.clamp(math.floor(desiredVisualW), BASE_WIDTH, 1300)
					winHeight = math.clamp(math.floor(desiredVisualH), 420, 850)
				end

				MainWin.Size = UDim2.new(0, winWidth, 0, winHeight)
				ContentWrap.Size = UDim2.new(1, 0, 0, winHeight - 36)
			end
		end)
	end

	local InnerBorderFrame = Instance.new("Frame")
	InnerBorderFrame.Name = "InnerBorderFrame"
	InnerBorderFrame.Size = UDim2.new(1, -164, 1, -12)
	InnerBorderFrame.Position = UDim2.new(0, 154, 0, 0)
	InnerBorderFrame.BackgroundColor3 = Library.Theme.GlassBg
	InnerBorderFrame.BackgroundTransparency = 0.82
	InnerBorderFrame.BorderSizePixel = 0
	InnerBorderFrame.Parent = ContentWrap
	addCorner(InnerBorderFrame, 8)
	addStroke(InnerBorderFrame, Library.Theme.NeonBorder, 1.4, 0.12)

	local InsetBorder = Instance.new("Frame")
	InsetBorder.Name = "InsetBorder"
	InsetBorder.Size = UDim2.new(1, -14, 1, -14)
	InsetBorder.Position = UDim2.new(0, 7, 0, 7)
	InsetBorder.BackgroundTransparency = 1
	InsetBorder.BorderSizePixel = 0
	InsetBorder.Parent = InnerBorderFrame
	addCorner(InsetBorder, 6)
	addStroke(InsetBorder, Library.Theme.NeonBorder, 1, 0.45)

	local function createCornerBracket(xScale, xOffset, yScale, yOffset, isTop, isLeft)
		local bracket = Instance.new("Frame")
		bracket.Name = "CornerBracket"
		bracket.Size = UDim2.new(0, 12, 0, 12)
		bracket.Position = UDim2.new(xScale, xOffset, yScale, yOffset)
		bracket.BackgroundTransparency = 1
		bracket.Parent = InnerBorderFrame

		local hLine = Instance.new("Frame")
		hLine.Size = UDim2.new(1, 0, 0, 1)
		hLine.Position = UDim2.new(0, 0, isTop and 0 or 1, isTop and 0 or -1)
		hLine.BackgroundColor3 = Library.Theme.NeonBorder
		hLine.BackgroundTransparency = 0.35
		hLine.BorderSizePixel = 0
		hLine.Parent = bracket

		local vLine = Instance.new("Frame")
		vLine.Size = UDim2.new(0, 1, 1, 0)
		vLine.Position = UDim2.new(isLeft and 0 or 1, isLeft and 0 or -1, 0, 0)
		vLine.BackgroundColor3 = Library.Theme.NeonBorder
		vLine.BackgroundTransparency = 0.35
		vLine.BorderSizePixel = 0
		vLine.Parent = bracket
	end
	createCornerBracket(0, 16, 0, 16, true, true)
	createCornerBracket(1, -28, 0, 16, true, false)
	createCornerBracket(0, 16, 1, -28, false, true)
	createCornerBracket(1, -28, 1, -28, false, false)

	local SideTabScroll = Instance.new("ScrollingFrame")
	SideTabScroll.Name = "SideTabScroll"
	SideTabScroll.Size = UDim2.new(0, 126, 1, -16)
	SideTabScroll.Position = UDim2.new(0, 8, 0, 4)
	SideTabScroll.BackgroundTransparency = 1
	SideTabScroll.BorderSizePixel = 0
	SideTabScroll.ScrollBarThickness = 0
	SideTabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	SideTabScroll.ZIndex = 3
	SideTabScroll.Parent = ContentWrap

	local SideTabLayout = Instance.new("UIListLayout")
	SideTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SideTabLayout.Padding = UDim.new(0, 6)
	SideTabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	SideTabLayout.Parent = SideTabScroll

	addPadding(SideTabScroll, 2, 4, 2, 2)

	SideTabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		SideTabScroll.CanvasSize = UDim2.new(0, 0, 0, SideTabLayout.AbsoluteContentSize.Y + 8)
	end)

	attachTouchScrollBarAndArrows(
		ContentWrap,
		SideTabScroll,
		SideTabLayout,
		UDim2.new(0, 138, 0, 4),
		UDim2.new(0, 10, 1, -16),
		85
	)

	local WindowObj = {
		ScreenGui = ScreenGui,
		MainFrame = MainWin,
		UIScale = WinScale,
		Tabs = {},
		ActiveTab = nil,
	}

	function WindowObj:SetOpacity(pct)
		pct = math.clamp(tonumber(pct) or 0.68, 0, 1)
		Library.Theme.Transparency = math.clamp(1 - pct * 0.85, 0.08, 0.78)
		MainWin.BackgroundTransparency = Library.Theme.Transparency
	end

	function WindowObj:SetScale(scale)
		userScale = math.clamp(tonumber(scale) or 1, 0.5, 1.5)
		tween(WinScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = userScale })
	end

	function WindowObj:SetToggleKey(newKey)
		local resolved = resolveKeyItem(newKey)
		if resolved then
			toggleKey = resolved
		end
	end

	function WindowObj:Toggle()
		if isWindowOpen then
			closeWindowAnimated()
		else
			openWindowAnimated()
		end
	end

	function WindowObj:Close()
		closeWindowAnimated()
	end

	function WindowObj:Open()
		openWindowAnimated()
	end

	function WindowObj:SetTitle(newTitle)
		windowTitle = tostring(newTitle)
		TitleText.Text = windowTitle
		MobileOpenPill.Size = UDim2.new(0, math.clamp(#windowTitle * 8 + 68, 140, 260), 0, 30)
		updatePillLabel()
	end

	function WindowObj:AddConstraints(minSize, maxSize, aspectRatio)
		local sc = addSizeConstraint(MainWin, minSize or Vector2.new(480, 36), maxSize or Vector2.new(1600, 1000))
		local arc = nil
		if aspectRatio then
			arc = Instance.new("UIAspectRatioConstraint")
			arc.AspectRatio = aspectRatio
			arc.Parent = MainWin
		end
		return sc, arc
	end

	function WindowObj:SelectTab(idxOrTab)
		local target = type(idxOrTab) == "number" and self.Tabs[idxOrTab] or idxOrTab
		if target then
			for _, t in ipairs(self.Tabs) do
				t._setVisual(t == target)
			end
			self.ActiveTab = target
		end
	end
	WindowObj.SwitchTab = WindowObj.SelectTab

	function WindowObj:Dialog(cfg)
		cfg = type(cfg) == "table" and cfg or { Title = "Dialog", Content = tostring(cfg or "") }
		Library:MakeNotification({
			Name = cfg.Title or cfg.Name or windowTitle,
			Content = cfg.Content or cfg.Text or "",
			Time = 5
		})
	end

	function WindowObj:Destroy()
		if ScreenGui and ScreenGui.Parent then
			ScreenGui:Destroy()
		end
	end
	WindowObj.Delete = WindowObj.Destroy

	function WindowObj.MakeTab(selfOrTabCfg, maybeTabCfg, optionalIcon)
		local tabConfig = (selfOrTabCfg == WindowObj) and maybeTabCfg or selfOrTabCfg
		if type(tabConfig) == "string" then
			tabConfig = { Name = tabConfig, Icon = optionalIcon }
		end
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or tabConfig.Title or ("Tab " .. tostring(#WindowObj.Tabs + 1))

		local tabIndex = #WindowObj.Tabs + 1

		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = tabName .. "_TabBtn"
		TabBtn.LayoutOrder = tabIndex
		TabBtn.Size = UDim2.new(1, 0, 0, 34)
		TabBtn.BorderSizePixel = 0
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.ZIndex = 4
		TabBtn.Parent = SideTabScroll
		addCorner(TabBtn, 6)

		local TabStroke = addStroke(TabBtn, Library.Theme.SubBorder, 1.1, 0.42)
		local TabGrad = Instance.new("UIGradient")
		TabGrad.Parent = TabBtn

		local TabIndicator = Instance.new("Frame")
		TabIndicator.Name = "Indicator"
		TabIndicator.Size = UDim2.new(0, 3, 1, -8)
		TabIndicator.Position = UDim2.new(0, 3, 0, 4)
		TabIndicator.BackgroundColor3 = Library.Theme.NeonBorder
		TabIndicator.BorderSizePixel = 0
		TabIndicator.Visible = false
		TabIndicator.ZIndex = 5
		TabIndicator.Parent = TabBtn
		addCorner(TabIndicator, 2)

		local TabLabel = Instance.new("TextLabel")
		TabLabel.Name = "TabLabel"
		TabLabel.Size = UDim2.new(1, -20, 1, 0)
		TabLabel.Position = UDim2.new(0, 14, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Text = tabName
		styleBrightButtonText(TabLabel, 13)
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.TextTruncate = Enum.TextTruncate.AtEnd
		TabLabel.ZIndex = 5
		TabLabel.Parent = TabBtn

		local TabPage = Instance.new("Frame")
		TabPage.Name = tabName .. "_Page"
		TabPage.Size = UDim2.new(1, -24, 1, -24)
		TabPage.Position = UDim2.new(0, 12, 0, 12)
		TabPage.BackgroundTransparency = 1
		TabPage.Visible = false
		TabPage.Parent = InnerBorderFrame

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.FillDirection = Enum.FillDirection.Horizontal
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		PageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		PageLayout.Padding = UDim.new(0, 12)
		PageLayout.Parent = TabPage

		local Columns = {}
		local defaultSubTitles = {
			[1] = tabName,
			[2] = tabName .. " — Options",
			[3] = tabName .. " — Extra",
		}

		for colIdx = 1, 3 do
			local Card = Instance.new("Frame")
			Card.Name = "Column_" .. colIdx
			Card.LayoutOrder = colIdx
			Card.Size = UDim2.new(0.3333, -8, 1, 0)
			Card.BackgroundColor3 = Library.Theme.CardBg
			Card.BackgroundTransparency = 0.68
			Card.BorderSizePixel = 0
			Card.ClipsDescendants = true
			Card.Visible = (colIdx == 1)
			Card.Parent = TabPage
			addCorner(Card, 7)
			addStroke(Card, Library.Theme.CardBorder, 1.2, 0.28)

			local Header = Instance.new("Frame")
			Header.Name = "Header"
			Header.Size = UDim2.new(1, 0, 0, 34)
			Header.BorderSizePixel = 0
			Header.Parent = Card
			addCorner(Header, 7)
			applyMetallicHeader(Header)

			local HeaderLine = Instance.new("Frame")
			HeaderLine.Size = UDim2.new(1, 0, 0, 1)
			HeaderLine.Position = UDim2.new(0, 0, 1, -1)
			HeaderLine.BackgroundColor3 = Library.Theme.NeonBorder
			HeaderLine.BackgroundTransparency = 0.35
			HeaderLine.BorderSizePixel = 0
			HeaderLine.Parent = Header

			local HeaderTitle = Instance.new("TextLabel")
			HeaderTitle.Name = "HeaderTitle"
			HeaderTitle.Size = UDim2.new(1, -24, 1, 0)
			HeaderTitle.Position = UDim2.new(0, 14, 0, 0)
			HeaderTitle.BackgroundTransparency = 1
			HeaderTitle.Text = defaultSubTitles[colIdx]
			styleBrightButtonText(HeaderTitle, 15)
			HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
			HeaderTitle.TextTruncate = Enum.TextTruncate.AtEnd
			HeaderTitle.Parent = Header

			local ColScroll = Instance.new("ScrollingFrame")
			ColScroll.Name = "ColScroll"
			ColScroll.Size = UDim2.new(1, -16, 1, -40)
			ColScroll.Position = UDim2.new(0, 2, 0, 37)
			ColScroll.BackgroundTransparency = 1
			ColScroll.BorderSizePixel = 0
			ColScroll.ScrollBarThickness = 0
			ColScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			ColScroll.Parent = Card

			local ColLayout = Instance.new("UIListLayout")
			ColLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ColLayout.Padding = UDim.new(0, 8)
			ColLayout.Parent = ColScroll

			addPadding(ColScroll, 8, 12, 10, 6)

			ColLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				ColScroll.CanvasSize = UDim2.new(0, 0, 0, ColLayout.AbsoluteContentSize.Y + 22)
			end)

			attachTouchScrollBarAndArrows(
				Card,
				ColScroll,
				ColLayout,
				UDim2.new(1, -14, 0, 38),
				UDim2.new(0, 10, 1, -43),
				95
			)

			Columns[colIdx] = {
				Card = Card,
				HeaderTitle = HeaderTitle,
				Scroll = ColScroll,
				Layout = ColLayout,
				HasCustomTitle = false,
				ItemCount = 0,
				Weight = 0,
			}
		end

		local function updateResponsiveColumns()
			local activeCols = {}
			for i = 1, 3 do
				if Columns[i].ItemCount > 0 or Columns[i].HasCustomTitle then
					Columns[i].Card.Visible = true
					table.insert(activeCols, Columns[i].Card)
				else
					Columns[i].Card.Visible = false
				end
			end

			if #activeCols == 0 then
				Columns[1].Card.Visible = true
				activeCols = { Columns[1].Card }
			end

			local count = #activeCols
			for _, card in ipairs(activeCols) do
				if count == 1 then
					card.Size = UDim2.new(1, 0, 1, 0)
				elseif count == 2 then
					card.Size = UDim2.new(0.5, -6, 1, 0)
				else
					card.Size = UDim2.new(0.3333, -8, 1, 0)
				end
			end
		end

		local function setTabVisual(isActive)
			if isActive then
				TabBtn.BackgroundColor3 = Color3.fromRGB(36, 52, 70)
				TabBtn.BackgroundTransparency = 0.22
				TabGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(92, 136, 172)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(155, 208, 246)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(68, 104, 138)),
				})
				TabStroke.Color = Library.Theme.NeonBorder
				TabStroke.Thickness = 1.4
				TabStroke.Transparency = 0.05
				TabIndicator.Visible = true
				TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				TabPage.Visible = true
			else
				TabBtn.BackgroundColor3 = Color3.fromRGB(18, 26, 36)
				TabBtn.BackgroundTransparency = 0.58
				TabGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.0, Color3.fromRGB(56, 76, 96)),
					ColorSequenceKeypoint.new(1.0, Color3.fromRGB(28, 40, 52)),
				})
				TabStroke.Color = Library.Theme.SubBorder
				TabStroke.Thickness = 1.0
				TabStroke.Transparency = 0.42
				TabIndicator.Visible = false
				TabLabel.TextColor3 = Color3.fromRGB(190, 214, 232)
				TabPage.Visible = false
			end
		end

		local currentColumnIndex = 1
		local sectionCounter = 0

		local function getShortestColumnIndex()
			local bestIdx = 1
			local bestWeight = Columns[1].Weight
			for i = 2, 3 do
				if Columns[i].Weight < bestWeight then
					bestWeight = Columns[i].Weight
					bestIdx = i
				end
			end
			return bestIdx
		end

		local function getTargetScroll(explicitCol, weightCost)
			weightCost = weightCost or 1
			local cIdx = explicitCol

			if not cIdx then
				if sectionCounter <= 1 then
					if Columns[1].Weight < 6.5 then
						cIdx = 1
					elseif Columns[2].Weight < 6.5 then
						cIdx = 2
					elseif Columns[3].Weight < 6.5 then
						cIdx = 3
					else
						cIdx = getShortestColumnIndex()
					end
				else
					cIdx = currentColumnIndex
				end
			end

			cIdx = math.clamp(tonumber(cIdx) or 1, 1, 3)
			local col = Columns[cIdx]
			col.ItemCount = col.ItemCount + 1
			col.Weight = col.Weight + weightCost
			updateResponsiveColumns()
			return col.Scroll, col.ItemCount
		end

		local function createMethodsForTarget(resolveScroll)
			local Methods = {}

			function Methods.AddToggle(selfOrA, a, b, c, d)
				local cfg = (selfOrA == Methods or type(selfOrA) == "table" and selfOrA.AddToggle)
					and normalizeArgs("Toggle", a, b, c, d)
					or normalizeArgs("Toggle", selfOrA, a, b, c)

				local name     = cfg.Name or cfg.Title or "Toggle"
				local default  = cfg.Default or cfg.CurrentValue or false
				local callback = cfg.Callback or function() end
				local flag     = cfg.Flag
				local usePill  = (cfg.Style == "Switch" or cfg.Pill == true)

				local scroll, order = resolveScroll(cfg.Column, 1)

				local RowBtn = Instance.new("TextButton")
				RowBtn.Name = name .. "_Toggle"
				RowBtn.LayoutOrder = order
				RowBtn.Size = UDim2.new(1, 0, 0, 26)
				RowBtn.BackgroundTransparency = 1
				RowBtn.Text = ""
				RowBtn.AutoButtonColor = false
				RowBtn.Parent = scroll

				local state = default
				local changedListeners = {}
				local ToggleObj = { Value = state, Type = "Toggle" }

				function ToggleObj:OnChanged(fn)
					if type(fn) == "function" then
						table.insert(changedListeners, fn)
					end
				end

				local function fireCallbacks(val)
					task.spawn(callback, val)
					for _, fn in ipairs(changedListeners) do
						task.spawn(fn, val)
					end
				end

				if usePill then
					local Lbl = Instance.new("TextLabel")
					Lbl.Size = UDim2.new(1, -44, 1, 0)
					Lbl.BackgroundTransparency = 1
					Lbl.Text = name
					Lbl.TextColor3 = Library.Theme.TextWhite
					Lbl.Font = Enum.Font.GothamMedium
					Lbl.TextSize = 14
					Lbl.TextXAlignment = Enum.TextXAlignment.Left
					Lbl.TextTruncate = Enum.TextTruncate.AtEnd
					Lbl.Parent = RowBtn

					local Pill = Instance.new("Frame")
					Pill.Size = UDim2.new(0, 36, 0, 18)
					Pill.Position = UDim2.new(1, -36, 0.5, -9)
					Pill.BorderSizePixel = 0
					Pill.Parent = RowBtn
					addCorner(Pill, 9)
					local pillStroke = addStroke(Pill, Library.Theme.NeonBorder, 1.1, 0.2)

					local Knob = Instance.new("Frame")
					Knob.Size = UDim2.new(0, 14, 0, 14)
					Knob.BorderSizePixel = 0
					Knob.Parent = Pill
					addCorner(Knob, 7)

					local function updatePill()
						if state then
							tween(Pill, nil, { BackgroundColor3 = Library.Theme.CheckFill, BackgroundTransparency = 0.12 })
							tween(Knob, nil, { Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
							pillStroke.Color = Library.Theme.NeonBorder
						else
							tween(Pill, nil, { BackgroundColor3 = Color3.fromRGB(36, 46, 58), BackgroundTransparency = 0.45 })
							tween(Knob, nil, { Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Library.Theme.TextMuted })
							pillStroke.Color = Library.Theme.SubBorder
						end
					end

					function ToggleObj:Set(val)
						state = not not val
						ToggleObj.Value = state
						updatePill()
						fireCallbacks(state)
					end
					updatePill()
				else
					local Box = Instance.new("Frame")
					Box.Size = UDim2.new(0, 20, 0, 20)
					Box.Position = UDim2.new(0, 0, 0.5, -10)
					Box.BorderSizePixel = 0
					Box.Parent = RowBtn
					addCorner(Box, 5)
					local boxStroke = addStroke(Box, Library.Theme.NeonBorder, 1.2, 0.15)

					local CheckMark = Instance.new("TextLabel")
					CheckMark.Size = UDim2.new(1, 0, 1, 0)
					CheckMark.BackgroundTransparency = 1
					CheckMark.Text = "✓"
					styleBrightButtonText(CheckMark, 14)
					CheckMark.Parent = Box

					local Lbl = Instance.new("TextLabel")
					Lbl.Size = UDim2.new(1, -30, 1, 0)
					Lbl.Position = UDim2.new(0, 30, 0, 0)
					Lbl.BackgroundTransparency = 1
					Lbl.Text = name
					Lbl.TextColor3 = Library.Theme.TextWhite
					Lbl.Font = Enum.Font.GothamMedium
					Lbl.TextSize = 14
					Lbl.TextXAlignment = Enum.TextXAlignment.Left
					Lbl.TextTruncate = Enum.TextTruncate.AtEnd
					Lbl.Parent = RowBtn

					local function updateBox()
						if state then
							tween(Box, nil, { BackgroundColor3 = Library.Theme.CheckFill, BackgroundTransparency = 0.10 })
							boxStroke.Color = Library.Theme.NeonBorder
							boxStroke.Transparency = 0.02
							CheckMark.Visible = true
						else
							tween(Box, nil, { BackgroundColor3 = Color3.fromRGB(36, 46, 58), BackgroundTransparency = 0.45 })
							boxStroke.Color = Library.Theme.SubBorder
							boxStroke.Transparency = 0.35
							CheckMark.Visible = false
						end
					end

					function ToggleObj:Set(val)
						state = not not val
						ToggleObj.Value = state
						updateBox()
						fireCallbacks(state)
					end
					updateBox()
				end

				ToggleObj.SetValue     = ToggleObj.Set
				ToggleObj.UpdateToggle = ToggleObj.Set

				RowBtn.MouseButton1Click:Connect(function()
					ToggleObj:Set(not state)
				end)

				registerFlag(flag, name, ToggleObj)
				if default then
					fireCallbacks(default)
				end
				return ToggleObj
			end
			Methods.CreateToggle = Methods.AddToggle
			Methods.MakeToggle   = Methods.AddToggle
			Methods.NewToggle    = Methods.AddToggle
			Methods.AddCheckbox  = Methods.AddToggle
			Methods.Toggle       = Methods.AddToggle
			Methods.addToggle    = Methods.AddToggle

			function Methods.AddSlider(selfOrA, a, b, c, d, e)
				local cfg = (selfOrA == Methods or type(selfOrA) == "table" and selfOrA.AddSlider)
					and normalizeArgs("Slider", a, b, c, d, e)
					or normalizeArgs("Slider", selfOrA, a, b, c, d)

				local name      = cfg.Name or cfg.Title or "Slider"
				local minVal    = cfg.Min or (cfg.Range and cfg.Range[1]) or 0
				local maxVal    = cfg.Max or (cfg.Range and cfg.Range[2]) or 100
				local increment = cfg.Increment or 1
				local default   = cfg.Default or cfg.CurrentValue or minVal
				local suffix    = cfg.ValueName or cfg.Suffix or ""
				local callback  = cfg.Callback or function() end
				local flag      = cfg.Flag
				local showTicks = (cfg.Ticks == true) or (tostring(name):lower():find("opacity") ~= nil)

				local scroll, order = resolveScroll(cfg.Column, 1.35)

				local Container = Instance.new("Frame")
				Container.Name = name .. "_Slider"
				Container.LayoutOrder = order
				Container.Size = UDim2.new(1, 0, 0, showTicks and 54 or 44)
				Container.BackgroundTransparency = 1
				Container.Parent = scroll

				local TitleLbl = Instance.new("TextLabel")
				TitleLbl.Size = UDim2.new(0.65, 0, 0, 20)
				TitleLbl.BackgroundTransparency = 1
				TitleLbl.Text = name
				TitleLbl.TextColor3 = Library.Theme.TextWhite
				TitleLbl.Font = Enum.Font.GothamMedium
				TitleLbl.TextSize = 14
				TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
				TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
				TitleLbl.Parent = Container

				local ValueLbl = Instance.new("TextLabel")
				ValueLbl.Size = UDim2.new(0.35, 0, 0, 20)
				ValueLbl.Position = UDim2.new(0.65, 0, 0, 0)
				ValueLbl.BackgroundTransparency = 1
				ValueLbl.TextColor3 = Color3.fromRGB(220, 238, 252)
				ValueLbl.Font = Enum.Font.GothamBold
				ValueLbl.TextSize = 13
				ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
				ValueLbl.Parent = Container

				local Track = Instance.new("TextButton")
				Track.Size = UDim2.new(1, 0, 0, 6)
				Track.Position = UDim2.new(0, 0, 0, 28)
				Track.BackgroundColor3 = Color3.fromRGB(38, 50, 62)
				Track.BackgroundTransparency = 0.25
				Track.BorderSizePixel = 0
				Track.Text = ""
				Track.AutoButtonColor = false
				Track.Parent = Container
				addCorner(Track, 3)
				addStroke(Track, Library.Theme.SubBorder, 1, 0.4)

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new(0, 0, 1, 0)
				Fill.BackgroundColor3 = Library.Theme.SliderFill
				Fill.BorderSizePixel = 0
				Fill.Parent = Track
				addCorner(Fill, 3)

				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.new(0, 8, 0, 18)
				Knob.Position = UDim2.new(0, -4, 0.5, -9)
				Knob.BackgroundColor3 = Color3.fromRGB(215, 240, 255)
				Knob.BorderSizePixel = 0
				Knob.Parent = Track
				addCorner(Knob, 4)
				addStroke(Knob, Color3.fromRGB(255, 255, 255), 1.2, 0.05)

				if showTicks then
					local TicksHolder = Instance.new("Frame")
					TicksHolder.Size = UDim2.new(1, 0, 0, 10)
					TicksHolder.Position = UDim2.new(0, 0, 0, 39)
					TicksHolder.BackgroundTransparency = 1
					TicksHolder.Parent = Container

					local numTicks = 24
					for t = 0, numTicks do
						local isMajor = (t % 6 == 0)
						local tick = Instance.new("Frame")
						tick.Size = UDim2.new(0, 1, 0, isMajor and 7 or 4)
						tick.Position = UDim2.new(t / numTicks, 0, 0, 0)
						tick.BackgroundColor3 = Library.Theme.SubBorder
						tick.BackgroundTransparency = isMajor and 0.25 or 0.5
						tick.BorderSizePixel = 0
						tick.Parent = TicksHolder
					end
				end

				local changedListeners = {}
				local SliderObj = { Value = default, Type = "Slider" }

				function SliderObj:OnChanged(fn)
					if type(fn) == "function" then
						table.insert(changedListeners, fn)
					end
				end

				local function roundToIncrement(val)
					local clamped = math.clamp(val, minVal, maxVal)
					local snapped = minVal + math.floor(((clamped - minVal) / increment) + 0.5) * increment
					local decimals = tostring(increment):match("%.(%d+)")
					if decimals then
						snapped = tonumber(string.format("%." .. #decimals .. "f", snapped)) or snapped
					else
						snapped = math.floor(snapped + 0.5)
					end
					return math.clamp(snapped, minVal, maxVal)
				end

				function SliderObj:Set(val)
					local finalVal = roundToIncrement(tonumber(val) or minVal)
					SliderObj.Value = finalVal
					local pct = (maxVal > minVal) and ((finalVal - minVal) / (maxVal - minVal)) or 0
					Fill.Size = UDim2.new(pct, 0, 1, 0)
					Knob.Position = UDim2.new(pct, -4, 0.5, -9)
					ValueLbl.Text = tostring(finalVal) .. (suffix ~= "" and (" " .. suffix) or "")
					task.spawn(callback, finalVal)
					for _, fn in ipairs(changedListeners) do
						task.spawn(fn, finalVal)
					end
				end
				SliderObj.SetValue     = SliderObj.Set
				SliderObj.UpdateSlider = SliderObj.Set

				local sliding = false
				local function updateFromInput(input)
					local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / math.max(1, Track.AbsoluteSize.X), 0, 1)
					local raw = minVal + (maxVal - minVal) * pct
					SliderObj:Set(raw)
				end

				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						sliding = true
						updateFromInput(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						sliding = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(input)
					end
				end)

				SliderObj:Set(default)
				registerFlag(flag, name, SliderObj)
				return SliderObj
			end
			Methods.CreateSlider = Methods.AddSlider
			Methods.MakeSlider   = Methods.AddSlider
			Methods.NewSlider    = Methods.AddSlider
			Methods.Slider       = Methods.AddSlider
			Methods.addSlider    = Methods.AddSlider

			function Methods.AddButton(selfOrA, a, b, c)
				local cfg = (selfOrA == Methods or type(selfOrA) == "table" and selfOrA.AddButton)
					and normalizeArgs("Button", a, b, c)
					or normalizeArgs("Button", selfOrA, a, b)

				local name     = cfg.Name or cfg.Title or "Button"
				local callback = cfg.Callback or function() end
				local isCircle = (cfg.Style == "Circle" or cfg.Circle == true)

				local scroll, order = resolveScroll(cfg.Column, isCircle and 2.2 or 1)

				if isCircle then
					local Holder = Instance.new("Frame")
					Holder.Name = name .. "_CircleHolder"
					Holder.LayoutOrder = order
					Holder.Size = UDim2.new(1, 0, 0, 96)
					Holder.BackgroundTransparency = 1
					Holder.Parent = scroll

					local CircleBtn = Instance.new("TextButton")
					CircleBtn.Size = UDim2.new(0, 90, 0, 90)
					CircleBtn.Position = UDim2.new(0, 14, 0.5, -45)
					CircleBtn.Text = name
					styleBrightButtonText(CircleBtn, 13)
					CircleBtn.AutoButtonColor = false
					CircleBtn.Parent = Holder
					addCorner(CircleBtn, 45)
					local cStroke = addStroke(CircleBtn, Library.Theme.NeonBorder, 1.5, 0.10)
					applyButtonGradient(CircleBtn, false)
					attachButtonFX(CircleBtn, cStroke)

					CircleBtn.MouseButton1Click:Connect(function()
						task.spawn(callback)
					end)

					if cfg.ResetName or cfg.ResetCallback then
						local ResetBtn = Instance.new("TextButton")
						ResetBtn.Size = UDim2.new(0, 76, 0, 30)
						ResetBtn.Position = UDim2.new(0, 124, 0.5, -15)
						ResetBtn.Text = cfg.ResetName or "Reset"
						styleBrightButtonText(ResetBtn, 13)
						ResetBtn.AutoButtonColor = false
						ResetBtn.Parent = Holder
						addCorner(ResetBtn, 6)
						local rStroke = addStroke(ResetBtn, Library.Theme.CardBorder, 1.2, 0.16)
						applyButtonGradient(ResetBtn, false)
						attachButtonFX(ResetBtn, rStroke)
						ResetBtn.MouseButton1Click:Connect(function()
							if cfg.ResetCallback then task.spawn(cfg.ResetCallback) end
						end)
					end
					return CircleBtn
				end

				local Btn = Instance.new("TextButton")
				Btn.Name = name .. "_Button"
				Btn.LayoutOrder = order
				Btn.Size = UDim2.new(1, 0, 0, 32)
				Btn.Text = name
				styleBrightButtonText(Btn, 13)
				Btn.TextTruncate = Enum.TextTruncate.AtEnd
				Btn.AutoButtonColor = false
				Btn.Parent = scroll
				addCorner(Btn, 7)
				local btnStroke = addStroke(Btn, Library.Theme.NeonBorder, 1.3, 0.15)
				applyButtonGradient(Btn, false)
				attachButtonFX(Btn, btnStroke)

				Btn.MouseButton1Click:Connect(function()
					task.spawn(callback)
				end)

				local BtnObj = {}
				function BtnObj:Set(newText)
					Btn.Text = tostring(newText)
				end
				BtnObj.UpdateButton = BtnObj.Set
				return BtnObj
			end
			Methods.CreateButton = Methods.AddButton
			Methods.MakeButton   = Methods.AddButton
			Methods.NewButton    = Methods.AddButton
			Methods.Button       = Methods.AddButton
			Methods.addButton    = Methods.AddButton

			function Methods:AddDualButton(cfg)
				cfg = cfg or {}
				local scroll, order = resolveScroll(cfg.Column, 1)

				local Row = Instance.new("Frame")
				Row.LayoutOrder = order
				Row.Size = UDim2.new(1, 0, 0, 32)
				Row.BackgroundTransparency = 1
				Row.Parent = scroll

				local function makeHalfBtn(txt, xScale, cb)
					local b = Instance.new("TextButton")
					b.Size = UDim2.new(0.48, 0, 1, 0)
					b.Position = UDim2.new(xScale, 0, 0, 0)
					b.Text = txt
					styleBrightButtonText(b, 13)
					b.TextTruncate = Enum.TextTruncate.AtEnd
					b.AutoButtonColor = false
					b.Parent = Row
					addCorner(b, 7)
					local st = addStroke(b, Library.Theme.NeonBorder, 1.3, 0.15)
					applyButtonGradient(b, false)
					attachButtonFX(b, st)
					b.MouseButton1Click:Connect(function()
						if cb then task.spawn(cb) end
					end)
					return b
				end

				local b1 = makeHalfBtn(cfg.Name1 or "Button 1", 0, cfg.Callback1)
				local b2 = makeHalfBtn(cfg.Name2 or "Button 2", 0.52, cfg.Callback2)
				return b1, b2
			end
			Methods.CreateDualButton = Methods.AddDualButton

			function Methods:AddApplyButton(cfg)
				cfg = cfg or {}
				cfg.Style = "Circle"
				cfg.Name = cfg.Name or "Apply\nSettings"
				cfg.ResetName = cfg.ResetName or "Reset"
				return self:AddButton(cfg)
			end
			Methods.CreateApplyButton = Methods.AddApplyButton

			function Methods.AddDropdown(selfOrA, a, b, c, d)
				local cfg = (selfOrA == Methods or type(selfOrA) == "table" and selfOrA.AddDropdown)
					and normalizeArgs("Dropdown", a, b, c, d)
					or normalizeArgs("Dropdown", selfOrA, a, b, c)

				local name     = cfg.Name or cfg.Title or "Dropdown"
				local options  = cfg.Options or cfg.List or cfg.Values or { "Option 1", "Option 2" }
				local rawDef   = cfg.Default or cfg.CurrentOption or options[1] or ""
				local default  = type(rawDef) == "table" and (rawDef[1] or "") or rawDef
				local callback = cfg.Callback or function() end
				local flag     = cfg.Flag

				local scroll, order = resolveScroll(cfg.Column, 1.5)

				local Container = Instance.new("Frame")
				Container.Name = name .. "_Dropdown"
				Container.LayoutOrder = order
				Container.Size = UDim2.new(1, 0, 0, 56)
				Container.BackgroundTransparency = 1
				Container.ClipsDescendants = true
				Container.Parent = scroll

				local TitleLbl = Instance.new("TextLabel")
				TitleLbl.Size = UDim2.new(1, 0, 0, 20)
				TitleLbl.BackgroundTransparency = 1
				TitleLbl.Text = name
				TitleLbl.TextColor3 = Library.Theme.TextWhite
				TitleLbl.Font = Enum.Font.GothamMedium
				TitleLbl.TextSize = 14
				TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
				TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
				TitleLbl.Parent = Container

				local MainBox = Instance.new("TextButton")
				MainBox.Size = UDim2.new(1, 0, 0, 32)
				MainBox.Position = UDim2.new(0, 0, 0, 24)
				MainBox.Text = ""
				MainBox.AutoButtonColor = false
				MainBox.Parent = Container
				addCorner(MainBox, 7)
				local ddStroke = addStroke(MainBox, Library.Theme.NeonBorder, 1.3, 0.15)
				applyButtonGradient(MainBox, false)
				attachButtonFX(MainBox, ddStroke)

				local SelectedLbl = Instance.new("TextLabel")
				SelectedLbl.Size = UDim2.new(1, -34, 1, 0)
				SelectedLbl.Position = UDim2.new(0, 12, 0, 0)
				SelectedLbl.BackgroundTransparency = 1
				SelectedLbl.Text = tostring(default)
				styleBrightButtonText(SelectedLbl, 13)
				SelectedLbl.TextXAlignment = Enum.TextXAlignment.Left
				SelectedLbl.TextTruncate = Enum.TextTruncate.AtEnd
				SelectedLbl.Parent = MainBox

				local ArrowLbl = Instance.new("TextLabel")
				ArrowLbl.Size = UDim2.new(0, 24, 1, 0)
				ArrowLbl.Position = UDim2.new(1, -26, 0, 0)
				ArrowLbl.BackgroundTransparency = 1
				ArrowLbl.Text = "⌄"
				styleBrightButtonText(ArrowLbl, 14)
				ArrowLbl.Parent = MainBox

				local OptionHolder = Instance.new("ScrollingFrame")
				OptionHolder.Size = UDim2.new(1, 0, 0, 100)
				OptionHolder.Position = UDim2.new(0, 0, 0, 60)
				OptionHolder.BackgroundColor3 = Color3.fromRGB(18, 26, 36)
				OptionHolder.BackgroundTransparency = 0.28
				OptionHolder.BorderSizePixel = 0
				OptionHolder.ScrollBarThickness = 5
				OptionHolder.ScrollBarImageColor3 = Library.Theme.NeonBorder
				OptionHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
				OptionHolder.Parent = Container
				addCorner(OptionHolder, 6)
				addStroke(OptionHolder, Library.Theme.SubBorder, 1, 0.25)

				local OptLayout = Instance.new("UIListLayout")
				OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
				OptLayout.Padding = UDim.new(0, 3)
				OptLayout.Parent = OptionHolder
				addPadding(OptionHolder, 4, 4, 4, 8)

				local isOpen = false
				local changedListeners = {}
				local DropdownObj = { Value = default, Options = options, Type = "Dropdown" }

				function DropdownObj:OnChanged(fn)
					if type(fn) == "function" then
						table.insert(changedListeners, fn)
					end
				end

				local function toggleOpen(state)
					isOpen = state
					local listH = math.min(#DropdownObj.Options * 27 + 8, 114)
					OptionHolder.Size = UDim2.new(1, 0, 0, listH)
					OptionHolder.CanvasSize = UDim2.new(0, 0, 0, #DropdownObj.Options * 27 + 8)
					ArrowLbl.Text = isOpen and "⌃" or "⌄"
					tween(Container, TweenInfo.new(0.18), {
						Size = UDim2.new(1, 0, 0, isOpen and (62 + listH) or 56)
					})
				end

				function DropdownObj:Set(val)
					if type(val) == "table" then val = val[1] end
					DropdownObj.Value = val
					SelectedLbl.Text = tostring(val or "")
					task.spawn(callback, val)
					for _, fn in ipairs(changedListeners) do
						task.spawn(fn, val)
					end
				end
				DropdownObj.SetValue = DropdownObj.Set

				function DropdownObj:Refresh(newOptions, clearCurrent)
					DropdownObj.Options = newOptions or {}
					for _, ch in ipairs(OptionHolder:GetChildren()) do
						if ch:IsA("TextButton") then ch:Destroy() end
					end
					for i, opt in ipairs(DropdownObj.Options) do
						local OptBtn = Instance.new("TextButton")
						OptBtn.LayoutOrder = i
						OptBtn.Size = UDim2.new(1, 0, 0, 24)
						OptBtn.BackgroundColor3 = Color3.fromRGB(48, 66, 84)
						OptBtn.BackgroundTransparency = 0.28
						OptBtn.Text = tostring(opt)
						styleBrightButtonText(OptBtn, 12)
						OptBtn.TextTruncate = Enum.TextTruncate.AtEnd
						OptBtn.AutoButtonColor = false
						OptBtn.Parent = OptionHolder
						addCorner(OptBtn, 4)

						OptBtn.MouseEnter:Connect(function()
							tween(OptBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.08, BackgroundColor3 = Color3.fromRGB(72, 102, 128) })
						end)
						OptBtn.MouseLeave:Connect(function()
							tween(OptBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.28, BackgroundColor3 = Color3.fromRGB(48, 66, 84) })
						end)

						OptBtn.MouseButton1Click:Connect(function()
							DropdownObj:Set(opt)
							toggleOpen(false)
						end)
					end
					if clearCurrent then
						SelectedLbl.Text = "..."
						DropdownObj.Value = nil
					end
				end
				DropdownObj.SetValues = DropdownObj.Refresh

				MainBox.MouseButton1Click:Connect(function()
					toggleOpen(not isOpen)
				end)

				DropdownObj:Refresh(options, false)
				if default ~= "" then
					DropdownObj:Set(default)
				end
				registerFlag(flag, name, DropdownObj)
				return DropdownObj
			end
			Methods.CreateDropdown = Methods.AddDropdown
			Methods.MakeDropdown   = Methods.AddDropdown
			Methods.NewDropdown    = Methods.AddDropdown
			Methods.Dropdown       = Methods.AddDropdown
			Methods.addDropdown    = Methods.AddDropdown

			function Methods.AddColorpicker(selfOrA, a, b, c, d)
				local cfg = (selfOrA == Methods or type(selfOrA) == "table" and selfOrA.AddColorpicker)
					and normalizeArgs("Colorpicker", a, b, c, d)
					or normalizeArgs("Colorpicker", selfOrA, a, b, c)

				local name     = cfg.Name or cfg.Title or "Color Picker"
				local default  = cfg.Default or cfg.Color or Color3.fromRGB(130, 215, 250)
				local callback = cfg.Callback or function() end
				local flag     = cfg.Flag

				local scroll, order = resolveScroll(cfg.Column, 1.2)

				local Container = Instance.new("Frame")
				Container.Name = name .. "_Colorpicker"
				Container.LayoutOrder = order
				Container.Size = UDim2.new(1, 0, 0, 32)
				Container.BackgroundTransparency = 1
				Container.ClipsDescendants = true
				Container.Parent = scroll

				local TopRow = Instance.new("Frame")
				TopRow.Size = UDim2.new(1, 0, 0, 32)
				TopRow.BackgroundTransparency = 1
				TopRow.Parent = Container

				local PickerBtn = Instance.new("TextButton")
				PickerBtn.Size = UDim2.new(0.48, 0, 1, 0)
				PickerBtn.Text = name
				styleBrightButtonText(PickerBtn, 13)
				PickerBtn.TextTruncate = Enum.TextTruncate.AtEnd
				PickerBtn.AutoButtonColor = false
				PickerBtn.Parent = TopRow
				addCorner(PickerBtn, 7)
				local pStroke = addStroke(PickerBtn, Library.Theme.NeonBorder, 1.3, 0.15)
				applyButtonGradient(PickerBtn, false)
				attachButtonFX(PickerBtn, pStroke)

				local PreviewBtn = Instance.new("TextButton")
				PreviewBtn.Size = UDim2.new(0.48, 0, 1, 0)
				PreviewBtn.Position = UDim2.new(0.52, 0, 0, 0)
				PreviewBtn.BackgroundColor3 = default
				PreviewBtn.BackgroundTransparency = 0.12
				PreviewBtn.Text = "Preview"
				styleBrightButtonText(PreviewBtn, 13)
				PreviewBtn.AutoButtonColor = false
				PreviewBtn.Parent = TopRow
				addCorner(PreviewBtn, 7)
				addStroke(PreviewBtn, Library.Theme.NeonBorder, 1.3, 0.15)

				local Drawer = Instance.new("Frame")
				Drawer.Size = UDim2.new(1, 0, 0, 74)
				Drawer.Position = UDim2.new(0, 0, 0, 36)
				Drawer.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
				Drawer.BackgroundTransparency = 0.25
				Drawer.Parent = Container
				addCorner(Drawer, 6)
				addStroke(Drawer, Library.Theme.SubBorder, 1, 0.35)

				local h, s, v = Color3.toHSV(default)
				local changedListeners = {}
				local ColorObj = { Value = default, Type = "Colorpicker" }

				function ColorObj:OnChanged(fn)
					if type(fn) == "function" then
						table.insert(changedListeners, fn)
					end
				end

				function ColorObj:Set(col)
					if typeof(col) == "Color3" then
						ColorObj.Value = col
						PreviewBtn.BackgroundColor3 = col
						task.spawn(callback, col)
						for _, fn in ipairs(changedListeners) do
							task.spawn(fn, col)
						end
					end
				end
				ColorObj.SetValue = ColorObj.Set

				local function makeChannelBar(label, yOffset, initPct, onChange)
					local lbl = Instance.new("TextLabel")
					lbl.Size = UDim2.new(0, 18, 0, 18)
					lbl.Position = UDim2.new(0, 8, 0, yOffset)
					lbl.BackgroundTransparency = 1
					lbl.Text = label
					styleBrightButtonText(lbl, 11)
					lbl.Parent = Drawer

					local trk = Instance.new("TextButton")
					trk.Size = UDim2.new(1, -38, 0, 6)
					trk.Position = UDim2.new(0, 28, 0, yOffset + 6)
					trk.BackgroundColor3 = Color3.fromRGB(38, 50, 62)
					trk.Text = ""
					trk.AutoButtonColor = false
					trk.Parent = Drawer
					addCorner(trk, 3)

					local fl = Instance.new("Frame")
					fl.Size = UDim2.new(initPct, 0, 1, 0)
					fl.BackgroundColor3 = Library.Theme.SliderFill
					fl.BorderSizePixel = 0
					fl.Parent = trk
					addCorner(fl, 3)

					local draggingBar = false
					local function upd(inp)
						local p = math.clamp((inp.Position.X - trk.AbsolutePosition.X) / math.max(1, trk.AbsoluteSize.X), 0, 1)
						fl.Size = UDim2.new(p, 0, 1, 0)
						onChange(p)
						ColorObj:Set(Color3.fromHSV(h, s, v))
					end
					trk.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							draggingBar = true
							upd(inp)
						end
					end)
					UserInputService.InputEnded:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							draggingBar = false
						end
					end)
					UserInputService.InputChanged:Connect(function(inp)
						if draggingBar and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
							upd(inp)
						end
					end)
				end

				makeChannelBar("H", 6,  h, function(p) h = p end)
				makeChannelBar("S", 28, s, function(p) s = p end)
				makeChannelBar("V", 50, v, function(p) v = p end)

				local open = false
				local function toggleDrawer()
					open = not open
					tween(Container, TweenInfo.new(0.18), {
						Size = UDim2.new(1, 0, 0, open and 114 or 32)
					})
				end

				PickerBtn.MouseButton1Click:Connect(toggleDrawer)
				PreviewBtn.MouseButton1Click:Connect(toggleDrawer)

				registerFlag(flag, name, ColorObj)
				return ColorObj
			end
			Methods.AddColorPicker    = Methods.AddColorpicker
			Methods.CreateColorpicker = Methods.AddColorpicker
			Methods.CreateColorPicker = Methods.AddColorpicker
			Methods.NewColorPicker    = Methods.AddColorpicker
			Methods.Colorpicker       = Methods.AddColorpicker
			Methods.addColorPicker    = Methods.AddColorpicker

			function Methods.AddBind(selfOrA, a, b, c, d)
				local cfg = (selfOrA == Methods or type(selfOrA) == "table" and selfOrA.AddBind)
					and normalizeArgs("Bind", a, b, c, d)
					or normalizeArgs("Bind", selfOrA, a, b, c)

				local name     = cfg.Name or cfg.Title or "Keybind"
				local default  = resolveKeyItem(cfg.Default or cfg.CurrentKeybind) or Enum.KeyCode.X
				local hold     = cfg.Hold or cfg.HoldToInteract or false
				local callback = cfg.Callback or function() end
				local flag     = cfg.Flag

				local scroll, order = resolveScroll(cfg.Column, 1)

				local Row = Instance.new("Frame")
				Row.Name = name .. "_Bind"
				Row.LayoutOrder = order
				Row.Size = UDim2.new(1, 0, 0, 30)
				Row.BackgroundTransparency = 1
				Row.Parent = scroll

				local Lbl = Instance.new("TextLabel")
				Lbl.Size = UDim2.new(1, -86, 1, 0)
				Lbl.BackgroundTransparency = 1
				Lbl.Text = name
				Lbl.TextColor3 = Library.Theme.TextWhite
				Lbl.Font = Enum.Font.GothamMedium
				Lbl.TextSize = 14
				Lbl.TextXAlignment = Enum.TextXAlignment.Left
				Lbl.TextTruncate = Enum.TextTruncate.AtEnd
				Lbl.Parent = Row

				local BindBtn = Instance.new("TextButton")
				BindBtn.Size = UDim2.new(0, 78, 0, 26)
				BindBtn.Position = UDim2.new(1, -78, 0.5, -13)
				BindBtn.Text = "[ " .. formatKeyName(default) .. " ]"
				styleBrightButtonText(BindBtn, 12)
				BindBtn.AutoButtonColor = false
				BindBtn.Parent = Row
				addCorner(BindBtn, 6)
				local bindStroke = addStroke(BindBtn, Library.Theme.NeonBorder, 1.3, 0.15)
				applyButtonGradient(BindBtn, false)
				attachButtonFX(BindBtn, bindStroke)

				local currentKey = default
				local binding = false
				local changedListeners = {}
				local BindObj = { Value = currentKey, Type = "Bind" }

				function BindObj:OnChanged(fn)
					if type(fn) == "function" then
						table.insert(changedListeners, fn)
					end
				end

				function BindObj:Get()
					return currentKey
				end

				function BindObj:Set(newKey)
					currentKey = resolveKeyItem(newKey)
					BindObj.Value = currentKey
					BindBtn.Text = "[ " .. formatKeyName(currentKey) .. " ]"
					for _, fn in ipairs(changedListeners) do
						task.spawn(fn, currentKey)
					end
				end
				BindObj.SetValue = BindObj.Set

				BindBtn.MouseButton1Click:Connect(function()
					binding = true
					BindBtn.Text = "[ ... ]"
					bindStroke.Transparency = 0.0
					bindStroke.Color = Color3.fromRGB(185, 240, 255)
				end)

				UserInputService.InputBegan:Connect(function(input, gp)
					if binding then
						if input.UserInputType == Enum.UserInputType.Keyboard then
							binding = false
							bindStroke.Transparency = 0.15
							if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
								BindObj:Set(nil)
							else
								BindObj:Set(input.KeyCode)
							end
						elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
							binding = false
							bindStroke.Transparency = 0.15
							BindObj:Set(input.UserInputType)
						end
						return
					end
					if not gp and currentKey and (input.KeyCode == currentKey or input.UserInputType == currentKey) then
						if hold then
							task.spawn(callback, true)
						else
							task.spawn(callback, currentKey)
						end
					end
				end)

				UserInputService.InputEnded:Connect(function(input, gp)
					if not gp and hold and currentKey and (input.KeyCode == currentKey or input.UserInputType == currentKey) then
						task.spawn(callback, false)
					end
				end)

				registerFlag(flag, name, BindObj)
				return BindObj
			end
			Methods.CreateBind    = Methods.AddBind
			Methods.AddKeybind    = Methods.AddBind
			Methods.CreateKeybind = Methods.AddBind
			Methods.NewKeybind    = Methods.AddBind
			Methods.Bind          = Methods.AddBind
			Methods.Keybind       = Methods.AddBind
			Methods.addKeybind    = Methods.AddBind

			function Methods.AddTextbox(selfOrA, a, b, c, d)
				local cfg = (selfOrA == Methods or type(selfOrA) == "table" and selfOrA.AddTextbox)
					and normalizeArgs("Textbox", a, b, c, d)
					or normalizeArgs("Textbox", selfOrA, a, b, c)

				local name        = cfg.Name or cfg.Title or "Input"
				local default     = cfg.Default or ""
				local placeholder = cfg.Placeholder or cfg.PlaceholderText or "Text eingeben..."
				local disappear   = cfg.TextDisappear or cfg.RemoveTextAfterFocusLost or false
				local callback    = cfg.Callback or function() end
				local flag        = cfg.Flag

				local scroll, order = resolveScroll(cfg.Column, 1.4)

				local Container = Instance.new("Frame")
				Container.Name = name .. "_Textbox"
				Container.LayoutOrder = order
				Container.Size = UDim2.new(1, 0, 0, 52)
				Container.BackgroundTransparency = 1
				Container.Parent = scroll

				local Lbl = Instance.new("TextLabel")
				Lbl.Size = UDim2.new(1, 0, 0, 18)
				Lbl.BackgroundTransparency = 1
				Lbl.Text = name
				Lbl.TextColor3 = Library.Theme.TextWhite
				Lbl.Font = Enum.Font.GothamMedium
				Lbl.TextSize = 13
				Lbl.TextXAlignment = Enum.TextXAlignment.Left
				Lbl.TextTruncate = Enum.TextTruncate.AtEnd
				Lbl.Parent = Container

				local Box = Instance.new("TextBox")
				Box.Size = UDim2.new(1, 0, 0, 28)
				Box.Position = UDim2.new(0, 0, 0, 22)
				Box.BackgroundColor3 = Color3.fromRGB(24, 34, 46)
				Box.BackgroundTransparency = 0.42
				Box.Text = tostring(default)
				Box.PlaceholderText = placeholder
				Box.PlaceholderColor3 = Library.Theme.TextMuted
				Box.TextColor3 = Library.Theme.TextWhite
				Box.Font = Enum.Font.GothamMedium
				Box.TextSize = 12
				Box.TextXAlignment = Enum.TextXAlignment.Left
				Box.ClearTextOnFocus = false
				Box.Parent = Container
				addCorner(Box, 6)
				local boxStroke = addStroke(Box, Library.Theme.SubBorder, 1.1, 0.25)
				addPadding(Box, 0, 0, 10, 10)

				local TextboxObj = { Value = default, Type = "Textbox" }

				function TextboxObj:Set(txt)
					Box.Text = tostring(txt)
					TextboxObj.Value = Box.Text
					task.spawn(callback, Box.Text)
				end
				TextboxObj.SetValue = TextboxObj.Set

				Box.Focused:Connect(function()
					boxStroke.Color = Library.Theme.NeonBorder
					boxStroke.Transparency = 0.0
				end)
				Box.FocusLost:Connect(function()
					boxStroke.Color = Library.Theme.SubBorder
					boxStroke.Transparency = 0.25
					TextboxObj.Value = Box.Text
					task.spawn(callback, Box.Text)
					if disappear then
						Box.Text = ""
					end
				end)

				registerFlag(flag, name, TextboxObj)
				return TextboxObj
			end
			Methods.CreateTextbox = Methods.AddTextbox
			Methods.CreateInput   = Methods.AddTextbox
			Methods.AddInput      = Methods.AddTextbox
			Methods.NewTextBox    = Methods.AddTextbox
			Methods.Textbox       = Methods.AddTextbox
			Methods.Input         = Methods.AddTextbox
			Methods.addTextbox    = Methods.AddTextbox

			function Methods.AddLabel(selfOrText, maybeText)
				local text = (selfOrText == Methods or type(selfOrText) == "table" and selfOrText.AddLabel) and maybeText or selfOrText
				if type(text) == "table" then text = text.Name or text.Text or text.Title or "" end
				local scroll, order = resolveScroll(nil, 0.7)

				local Lbl = Instance.new("TextLabel")
				Lbl.LayoutOrder = order
				Lbl.Size = UDim2.new(1, 0, 0, 20)
				Lbl.BackgroundTransparency = 1
				Lbl.Text = tostring(text or "")
				Lbl.TextColor3 = Library.Theme.TextWhite
				Lbl.Font = Enum.Font.GothamMedium
				Lbl.TextSize = 13
				Lbl.TextXAlignment = Enum.TextXAlignment.Left
				Lbl.TextTruncate = Enum.TextTruncate.AtEnd
				Lbl.Parent = scroll

				local LabelObj = {}
				function LabelObj:Set(newText)
					Lbl.Text = tostring(newText)
				end
				LabelObj.UpdateLabel = LabelObj.Set
				LabelObj.SetText     = LabelObj.Set
				return LabelObj
			end
			Methods.CreateLabel = Methods.AddLabel
			Methods.NewLabel    = Methods.AddLabel
			Methods.Label       = Methods.AddLabel
			Methods.addLabel    = Methods.AddLabel

			function Methods.AddParagraph(selfOrTitle, a, b)
				local title, content
				if selfOrTitle == Methods or (type(selfOrTitle) == "table" and selfOrTitle.AddParagraph) then
					title, content = a, b
				else
					title, content = selfOrTitle, a
				end
				if type(title) == "table" then
					content = title.Content or title.Text or ""
					title = title.Title or title.Name or "Info"
				end
				local scroll, order = resolveScroll(nil, 1.5)

				local Box = Instance.new("Frame")
				Box.LayoutOrder = order
				Box.Size = UDim2.new(1, 0, 0, 54)
				Box.BackgroundColor3 = Color3.fromRGB(20, 30, 42)
				Box.BackgroundTransparency = 0.52
				Box.Parent = scroll
				addCorner(Box, 6)
				addStroke(Box, Library.Theme.SubBorder, 1, 0.35)

				local T = Instance.new("TextLabel")
				T.Size = UDim2.new(1, -16, 0, 18)
				T.Position = UDim2.new(0, 8, 0, 4)
				T.BackgroundTransparency = 1
				T.Text = tostring(title or "Info")
				styleBrightButtonText(T, 13)
				T.TextXAlignment = Enum.TextXAlignment.Left
				T.TextTruncate = Enum.TextTruncate.AtEnd
				T.Parent = Box

				local C = Instance.new("TextLabel")
				C.Size = UDim2.new(1, -16, 1, -24)
				C.Position = UDim2.new(0, 8, 0, 22)
				C.BackgroundTransparency = 1
				C.Text = tostring(content or "")
				C.TextColor3 = Library.Theme.TextMuted
				C.Font = Enum.Font.Gotham
				C.TextSize = 11
				C.TextWrapped = true
				C.TextXAlignment = Enum.TextXAlignment.Left
				C.TextYAlignment = Enum.TextYAlignment.Top
				C.Parent = Box

				local ParaObj = {}
				function ParaObj:Set(newTitle, newContent)
					if type(newTitle) == "table" then
						newContent = newTitle.Content or newTitle.Text
						newTitle = newTitle.Title or newTitle.Name
					end
					if newTitle then T.Text = tostring(newTitle) end
					if newContent then C.Text = tostring(newContent) end
				end
				return ParaObj
			end
			Methods.CreateParagraph = Methods.AddParagraph
			Methods.Paragraph       = Methods.AddParagraph

			function Methods:AddDivider()
				local scroll, order = resolveScroll(nil, 0.3)
				local Div = Instance.new("Frame")
				Div.LayoutOrder = order
				Div.Size = UDim2.new(1, 0, 0, 1)
				Div.BackgroundColor3 = Library.Theme.SubBorder
				Div.BackgroundTransparency = 0.5
				Div.BorderSizePixel = 0
				Div.Parent = scroll
				return Div
			end
			Methods.CreateDivider = Methods.AddDivider
			Methods.AddSeparator  = Methods.AddDivider

			return Methods
		end

		local TabObj = createMethodsForTarget(function(explicitCol, weightCost)
			return getTargetScroll(explicitCol, weightCost)
		end)

		local function addSectionInternal(secConfig, forcedColumn)
			if type(secConfig) == "string" then
				secConfig = { Name = secConfig }
			end
			secConfig = secConfig or {}
			local secName = secConfig.Name or secConfig.Title or ("Section " .. tostring(sectionCounter + 1))

			if sectionCounter == 0 and Columns[1].ItemCount > 0 then
				sectionCounter = 1
				Columns[1].HasCustomTitle = true
			end
			sectionCounter = sectionCounter + 1
			local targetColIdx = forcedColumn or secConfig.Column
			if not targetColIdx then
				if sectionCounter <= 3 then
					targetColIdx = sectionCounter
				else
					targetColIdx = getShortestColumnIndex()
				end
			end
			targetColIdx = math.clamp(targetColIdx, 1, 3)
			currentColumnIndex = targetColIdx

			local col = Columns[targetColIdx]
			if not col.HasCustomTitle and col.ItemCount == 0 then
				col.HeaderTitle.Text = secName
				col.HasCustomTitle = true
			else
				col.ItemCount = col.ItemCount + 1
				col.Weight = col.Weight + 0.9
				local SubHdr = Instance.new("Frame")
				SubHdr.LayoutOrder = col.ItemCount
				SubHdr.Size = UDim2.new(1, 0, 0, 26)
				SubHdr.BorderSizePixel = 0
				SubHdr.Parent = col.Scroll
				addCorner(SubHdr, 5)
				applyMetallicHeader(SubHdr)
				addStroke(SubHdr, Library.Theme.SubBorder, 1, 0.35)

				local SubTxt = Instance.new("TextLabel")
				SubTxt.Size = UDim2.new(1, -16, 1, 0)
				SubTxt.Position = UDim2.new(0, 10, 0, 0)
				SubTxt.BackgroundTransparency = 1
				SubTxt.Text = secName
				styleBrightButtonText(SubTxt, 13)
				SubTxt.TextXAlignment = Enum.TextXAlignment.Left
				SubTxt.TextTruncate = Enum.TextTruncate.AtEnd
				SubTxt.Parent = SubHdr
			end

			updateResponsiveColumns()

			local SectionObj = createMethodsForTarget(function(explicitCol, weightCost)
				return getTargetScroll(explicitCol or targetColIdx, weightCost)
			end)
			return SectionObj
		end

		function TabObj.AddSection(selfOrSec, maybeSec)
			local cfg = (selfOrSec == TabObj) and maybeSec or selfOrSec
			return addSectionInternal(cfg, nil)
		end
		TabObj.CreateSection = TabObj.AddSection
		TabObj.MakeSection   = TabObj.AddSection
		TabObj.NewSection    = TabObj.AddSection
		TabObj.Section       = TabObj.AddSection
		TabObj.addSection    = TabObj.AddSection
		TabObj.AddGroupbox   = TabObj.AddSection

		function TabObj.AddLeftGroupbox(selfOrSec, maybeSec)
			local cfg = (selfOrSec == TabObj) and maybeSec or selfOrSec
			return addSectionInternal(cfg, 1)
		end
		function TabObj.AddRightGroupbox(selfOrSec, maybeSec)
			local cfg = (selfOrSec == TabObj) and maybeSec or selfOrSec
			local colIdx = (Columns[2].ItemCount <= Columns[3].ItemCount) and 2 or 3
			return addSectionInternal(cfg, colIdx)
		end

		TabObj._setVisual = setTabVisual

		TabBtn.MouseEnter:Connect(function()
			if WindowObj.ActiveTab ~= TabObj then
				tween(TabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.42 })
				tween(TabStroke, TweenInfo.new(0.12), { Transparency = 0.22, Color = Library.Theme.NeonBorder })
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if WindowObj.ActiveTab ~= TabObj then
				tween(TabBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.58 })
				tween(TabStroke, TweenInfo.new(0.12), { Transparency = 0.42, Color = Library.Theme.SubBorder })
			end
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _, t in ipairs(WindowObj.Tabs) do
				t._setVisual(t == TabObj)
			end
			WindowObj.ActiveTab = TabObj
		end)

		table.insert(WindowObj.Tabs, TabObj)
		if #WindowObj.Tabs == 1 then
			setTabVisual(true)
			WindowObj.ActiveTab = TabObj
		else
			setTabVisual(false)
		end

		return TabObj
	end

	WindowObj.CreateTab = WindowObj.MakeTab
	WindowObj.AddTab    = WindowObj.MakeTab
	WindowObj.NewTab    = WindowObj.MakeTab
	WindowObj.Tab       = WindowObj.MakeTab
	WindowObj.addPage   = WindowObj.MakeTab
	WindowObj.AddPage   = WindowObj.MakeTab

	local function getOrMakeDefaultTab()
		if #WindowObj.Tabs == 0 then
			WindowObj:MakeTab({ Name = "Main" })
		end
		return WindowObj.Tabs[1]
	end
	for _, methodName in ipairs({
		"AddSection", "CreateSection", "NewSection",
		"AddToggle", "CreateToggle", "NewToggle",
		"AddSlider", "CreateSlider", "NewSlider",
		"AddButton", "CreateButton", "NewButton",
		"AddDropdown", "CreateDropdown", "NewDropdown",
		"AddColorpicker", "CreateColorPicker", "NewColorPicker",
		"AddBind", "CreateBind", "NewKeybind", "AddKeybind", "CreateKeybind",
		"AddTextbox", "CreateInput", "NewTextBox",
		"AddLabel", "CreateLabel", "NewLabel",
		"AddParagraph", "CreateParagraph"
	}) do
		if not WindowObj[methodName] then
			WindowObj[methodName] = function(self, ...)
				local tab = getOrMakeDefaultTab()
				return tab[methodName](tab, ...)
			end
		end
	end

	table.insert(Library.Windows, WindowObj)
	return WindowObj
end

Library.CreateWindow = Library.MakeWindow
Library.Window       = Library.MakeWindow
Library.NewWindow    = Library.MakeWindow
Library.CreateLib    = Library.MakeWindow
Library.Load         = Library.MakeWindow

return Library
