AursUI = AursUI or {}

local TR, TG, TB = 0, 0.85, 1
local PANEL_BG = { 0.05, 0.05, 0.05, 0.95 }
local WIDGET_BG = { 0.08, 0.08, 0.08, 1 }
local TRACK_BG = { 0.2, 0.2, 0.2, 1 }

function AursUI.SetTheme(r, g, b)
	TR, TG, TB = r, g, b
end

local function ThemeEscape()
	return string.format("|cff%02x%02x%02x", TR * 255, TG * 255, TB * 255)
end

local function MakeBackdrop(edgeSize)
	return {
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = edgeSize or 1,
	}
end

function AursUI.CreatePanel(width, height, title, subtitle)
	local panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	panel:SetSize(width or 430, height or 500)
	panel:SetPoint("CENTER")
	panel:SetMovable(true)
	panel:EnableMouse(true)
	panel:SetClampedToScreen(true)
	panel:SetBackdrop(MakeBackdrop(2))
	panel:SetBackdropColor(unpack(PANEL_BG))
	panel:SetBackdropBorderColor(TR, TG, TB, 0.6)
	panel:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			self:StartMoving()
		end
	end)
	panel:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
	end)
	panel:Hide()

	if title then
		local t = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		t:SetPoint("TOP", 0, -10)
		t:SetText(ThemeEscape() .. title .. "|r")
	end

	if subtitle then
		local s = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		s:SetPoint("TOP", 0, -30)
		s:SetText("|cffFFFFFF" .. subtitle .. "|r")
	end

	local closeBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
	closeBtn:SetSize(24, 24)
	closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -8)
	closeBtn:SetBackdrop(MakeBackdrop(1))
	closeBtn:SetBackdropColor(unpack(WIDGET_BG))
	closeBtn:SetBackdropBorderColor(TR, TG, TB, 0.6)
	local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	closeText:SetPoint("CENTER")
	closeText:SetText("X")
	closeText:SetTextColor(TR, TG, TB, 1)
	closeBtn:SetScript("OnEnter", function()
		closeBtn:SetBackdropBorderColor(TR, TG, TB, 1)
		closeText:SetTextColor(1, 1, 1, 1)
	end)
	closeBtn:SetScript("OnLeave", function()
		closeBtn:SetBackdropBorderColor(TR, TG, TB, 0.6)
		closeText:SetTextColor(TR, TG, TB, 1)
	end)
	closeBtn:SetScript("OnClick", function()
		panel:Hide()
	end)

	panel.Close = function()
		panel:Hide()
	end
	panel.Open = function()
		panel:Show()
	end
	panel.Toggle = function()
		panel:SetShown(not panel:IsShown())
	end

	return panel
end

function AursUI.CreateTabs(parent, tabNames, contentTop)
	contentTop = contentTop or -85
	local tabs = {}
	local activeTab = 1
	local count = #tabNames
	local tabWidth = 145
	local gap = 5
	local totalWidth = count * tabWidth + (count - 1) * gap
	local startX = -(totalWidth / 2)

	local function UpdateTabs()
		for i, tab in ipairs(tabs) do
			if i == activeTab then
				tab.button._label:SetTextColor(TR, TG, TB, 1)
				tab.button._line:Show()
				tab.button:SetBackdropBorderColor(TR, TG, TB, 0.4)
				tab.content:Show()
			else
				tab.button._label:SetTextColor(0.5, 0.5, 0.5, 1)
				tab.button._line:Hide()
				tab.button:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
				tab.content:Hide()
			end
		end
	end

	for i, name in ipairs(tabNames) do
		local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
		tab:SetSize(tabWidth, 28)
		local xOffset = startX + (i - 1) * (tabWidth + gap)
		tab:SetPoint("TOPLEFT", parent, "TOP", xOffset, -50)
		tab:SetBackdrop(MakeBackdrop(1))
		tab:SetBackdropColor(unpack(WIDGET_BG))
		tab:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

		local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetPoint("CENTER")
		label:SetText(name)
		label:SetTextColor(0.6, 0.6, 0.6, 1)
		tab._label = label

		local line = tab:CreateTexture(nil, "OVERLAY")
		line:SetHeight(2)
		line:SetPoint("BOTTOMLEFT", 0, 0)
		line:SetPoint("BOTTOMRIGHT", 0, 0)
		line:SetColorTexture(TR, TG, TB, 1)
		line:Hide()
		tab._line = line

		tab:SetScript("OnClick", function()
			activeTab = i
			UpdateTabs()
		end)

		local content = CreateFrame("Frame", nil, parent)
		content:SetPoint("TOPLEFT", 10, contentTop)
		content:SetPoint("BOTTOMRIGHT", -10, 10)
		content:Hide()

		tabs[i] = { button = tab, content = content }
	end

	UpdateTabs()
	return tabs, UpdateTabs
end

function AursUI.CreateSlider(parent, label, xOffset, yOffset, min, max, getValue, setValue, width)
	width = width or 300
	local trackWidth = width - 16

	local container = CreateFrame("Frame", nil, parent)
	container:SetSize(width, 40)
	container:SetPoint("TOPLEFT", xOffset, yOffset)

	local track = container:CreateTexture(nil, "BACKGROUND")
	track:SetHeight(2)
	track:SetPoint("LEFT", 8, 8)
	track:SetPoint("RIGHT", -8, 8)
	track:SetColorTexture(unpack(TRACK_BG))

	local fill = container:CreateTexture(nil, "BORDER")
	fill:SetHeight(2)
	fill:SetPoint("LEFT", track, "LEFT", 0, 0)
	fill:SetColorTexture(TR, TG, TB, 1)

	local thumb = CreateFrame("Button", nil, container, "BackdropTemplate")
	thumb:SetSize(10, 18)
	thumb:SetBackdrop(MakeBackdrop(1))
	thumb:SetBackdropColor(TR, TG, TB, 1)
	thumb:SetBackdropBorderColor(1, 1, 1, 0.4)

	local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelText:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 2)
	labelText:SetTextColor(0.9, 0.9, 0.9, 1)

	local currentValue = min

	local function UpdateVisuals(val)
		local pct = (val - min) / (max - min)
		thumb:ClearAllPoints()
		thumb:SetPoint("CENTER", container, "LEFT", 8 + pct * trackWidth, 8)
		fill:SetWidth(math.max(0, pct * trackWidth))
		labelText:SetText(label .. ": " .. ThemeEscape() .. val .. "|r")
	end

	local function SetValue(val)
		val = math.max(min, math.min(max, math.floor(val)))
		if val == currentValue then
			return
		end
		currentValue = val
		UpdateVisuals(val)
		setValue(val)
	end

	container.SetValue = function(val)
		currentValue = math.max(min, math.min(max, math.floor(val)))
		UpdateVisuals(currentValue)
	end

	local dragging = false
	local function HandleDrag()
		if not dragging then
			return
		end
		local cursorX = GetCursorPosition() / UIParent:GetEffectiveScale()
		local left = container:GetLeft() + 8
		local pct = math.max(0, math.min(1, (cursorX - left) / trackWidth))
		SetValue(min + pct * (max - min))
	end

	thumb:SetScript("OnMouseDown", function()
		dragging = true
	end)
	thumb:SetScript("OnMouseUp", function()
		dragging = false
	end)
	thumb:SetScript("OnUpdate", HandleDrag)
	track:EnableMouse(true)
	track:SetScript("OnMouseDown", function()
		dragging = true
		HandleDrag()
	end)
	track:SetScript("OnMouseUp", function()
		dragging = false
	end)
	container:SetScript("OnUpdate", HandleDrag)

	local ok, val = pcall(getValue)
	container.SetValue(ok and val or min)

	return container
end

function AursUI.CreateCheckbox(parent, label, xOffset, yOffset, getValue, setValue)
	local container = CreateFrame("Button", nil, parent, "BackdropTemplate")
	container:SetSize(16, 16)
	container:SetPoint("TOPLEFT", xOffset, yOffset)
	container:SetBackdrop(MakeBackdrop(1))
	container:SetBackdropColor(unpack(WIDGET_BG))
	container:SetBackdropBorderColor(TR, TG, TB, 0.6)

	local check = container:CreateTexture(nil, "OVERLAY")
	check:SetPoint("CENTER")
	check:SetSize(10, 10)
	check:SetColorTexture(TR, TG, TB, 1)
	check:Hide()

	local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("LEFT", container, "RIGHT", 6, 0)
	text:SetText(label)
	text:SetTextColor(1, 1, 1, 1)

	local checked = false
	container.SetChecked = function(val)
		checked = val
		if val then
			check:Show()
		else
			check:Hide()
		end
	end
	container.GetChecked = function()
		return checked
	end
	container:SetScript("OnClick", function()
		container.SetChecked(not checked)
		setValue(checked)
	end)

	local ok, val = pcall(getValue)
	if ok then
		container.SetChecked(val)
	end

	return container
end

function AursUI.CreateDropdown(parent, xOffset, yOffset, options, getValue, setValue, width)
	width = width or 160

	local anchor = CreateFrame("Button", nil, parent, "BackdropTemplate")
	anchor:SetSize(width, 24)
	anchor:SetPoint("TOPLEFT", xOffset, yOffset)
	anchor:SetBackdrop(MakeBackdrop(1))
	anchor:SetBackdropColor(0.1, 0.1, 0.1, 1)
	anchor:SetBackdropBorderColor(TR, TG, TB, 0.6)

	local label = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("LEFT", 8, 0)
	label:SetText("Select...")
	label:SetTextColor(0.9, 0.9, 0.9, 1)

	local arrow = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	arrow:SetPoint("RIGHT", -8, 0)
	arrow:SetText("▾")
	arrow:SetTextColor(TR, TG, TB, 0.8)

	local list = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	list:SetSize(width, #options * 24)
	list:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
	list:SetBackdrop(MakeBackdrop(1))
	list:SetBackdropColor(0.08, 0.08, 0.08, 1)
	list:SetBackdropBorderColor(TR, TG, TB, 0.6)
	list:SetFrameLevel(parent:GetFrameLevel() + 10)
	list:Hide()

	for i, opt in ipairs(options) do
		local btn = CreateFrame("Button", nil, list)
		btn:SetSize(width, 24)
		btn:SetPoint("TOPLEFT", 0, -(i - 1) * 24)
		local btnLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		btnLabel:SetPoint("LEFT", 8, 0)
		btnLabel:SetText(opt.name)
		btnLabel:SetTextColor(0.9, 0.9, 0.9, 1)
		btn:SetScript("OnEnter", function()
			btnLabel:SetTextColor(TR, TG, TB, 1)
		end)
		btn:SetScript("OnLeave", function()
			btnLabel:SetTextColor(0.9, 0.9, 0.9, 1)
		end)
		btn:SetScript("OnClick", function()
			setValue(opt.value)
			label:SetText(opt.name)
			list:Hide()
		end)
	end

	anchor:SetScript("OnClick", function()
		list:SetShown(not list:IsShown())
	end)

	anchor.SetSelected = function(value)
		for _, opt in ipairs(options) do
			if opt.value == value then
				label:SetText(opt.name)
				break
			end
		end
	end

	local ok, val = pcall(getValue)
	if ok then
		anchor.SetSelected(val)
	end

	return anchor
end

function AursUI.CreateButton(parent, label, xOffset, yOffset, onClickFunc, width)
	local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
	btn:SetSize(width or 80, 24)
	btn:SetPoint("TOPLEFT", xOffset, yOffset)
	btn:SetBackdrop(MakeBackdrop(1))
	btn:SetBackdropColor(unpack(WIDGET_BG))
	btn:SetBackdropBorderColor(TR, TG, TB, 0.6)

	local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("CENTER")
	text:SetText(label)
	text:SetTextColor(TR, TG, TB, 1)

	btn:SetScript("OnEnter", function()
		btn:SetBackdropBorderColor(TR, TG, TB, 1)
		text:SetTextColor(1, 1, 1, 1)
	end)
	btn:SetScript("OnLeave", function()
		btn:SetBackdropBorderColor(TR, TG, TB, 0.6)
		text:SetTextColor(TR, TG, TB, 1)
	end)
	btn:SetScript("OnClick", onClickFunc)

	return btn
end

function AursUI.CreateColorSwatch(parent, xOffset, yOffset, getColor, setColor)
	local swatch = CreateFrame("Button", nil, parent, "BackdropTemplate")
	swatch:SetSize(24, 24)
	swatch:SetPoint("TOPLEFT", xOffset, yOffset)
	swatch:SetBackdrop(MakeBackdrop(1))
	swatch:SetBackdropBorderColor(TR, TG, TB, 0.6)

	local tex = swatch:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()

	local function Refresh()
		local r, g, b = getColor()
		tex:SetColorTexture(r, g, b, 1)
	end

	pcall(Refresh)

	swatch:SetScript("OnClick", function()
		local r, g, b = getColor()
		ColorPickerFrame:SetupColorPickerAndShow({
			hasOpacity = false,
			r = r,
			g = g,
			b = b,
			swatchFunc = function()
				local nr, ng, nb = ColorPickerFrame:GetColorRGB()
				setColor(nr, ng, nb)
				tex:SetColorTexture(nr, ng, nb, 1)
			end,
			cancelFunc = function(prev)
				setColor(prev.r, prev.g, prev.b)
				tex:SetColorTexture(prev.r, prev.g, prev.b, 1)
			end,
		})
	end)

	swatch.Refresh = Refresh
	return swatch
end

function AursUI.CreateLabel(parent, text, xOffset, yOffset, size)
	local template
	if size == "large" then
		template = "GameFontNormalLarge"
	elseif size == "small" then
		template = "GameFontNormalSmall"
	else
		template = "GameFontNormal"
	end
	local fs = parent:CreateFontString(nil, "OVERLAY", template)
	fs:SetPoint("TOPLEFT", xOffset, yOffset)
	fs:SetText(text)
	fs:SetTextColor(0.85, 0.85, 0.85, 1)
	return fs
end

function AursUI.CreateSeparator(parent, yOffset, xPad)
	xPad = xPad or 10
	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetHeight(1)
	line:SetPoint("TOPLEFT", xPad, yOffset)
	line:SetPoint("TOPRIGHT", -xPad, yOffset)
	line:SetColorTexture(TR, TG, TB, 0.25)
	return line
end

function AursUI.NewLayout(parent, xOffset, startY, rowHeight)
	xOffset = xOffset or 16
	startY = startY or -10
	rowHeight = rowHeight or 34

	local cursor = startY
	local L = {}

	function L:Y()
		return cursor
	end

	function L:Space(pixels)
		cursor = cursor - (pixels or rowHeight)
	end

	function L:Label(text, size)
		local w = AursUI.CreateLabel(parent, text, xOffset, cursor, size)
		cursor = cursor - (size == "large" and 28 or size == "small" and 20 or 24)
		return w
	end

	function L:Separator()
		local w = AursUI.CreateSeparator(parent, cursor)
		cursor = cursor - 14
		return w
	end

	function L:Slider(label, min, max, getValue, setValue, width)
		local w = AursUI.CreateSlider(parent, label, xOffset, cursor, min, max, getValue, setValue, width)
		cursor = cursor - 52
		return w
	end

	function L:Check(label, getValue, setValue)
		local w = AursUI.CreateCheckbox(parent, label, xOffset, cursor, getValue, setValue)
		cursor = cursor - rowHeight
		return w
	end

	function L:Dropdown(options, getValue, setValue, width)
		local w = AursUI.CreateDropdown(parent, xOffset, cursor, options, getValue, setValue, width)
		cursor = cursor - rowHeight
		return w
	end

	function L:Button(label, onClick, width)
		local w = AursUI.CreateButton(parent, label, xOffset, cursor, onClick, width)
		cursor = cursor - rowHeight
		return w
	end

	function L:ColorSwatch(getColor, setColor)
		local w = AursUI.CreateColorSwatch(parent, xOffset, cursor, getColor, setColor)
		cursor = cursor - rowHeight
		return w
	end

	-- Places multiple widgets side by side on the same row.
	-- Each item is a table with a 'type' field and type-specific fields.
	--
	-- Supported types:
	--   { type="check",    label="...", getValue=fn, setValue=fn }
	--   { type="button",   label="...", onClick=fn,  width=80 }
	--   { type="dropdown", options={},  getValue=fn, setValue=fn, width=160 }
	--
	-- spacing controls the gap between items (default 10).
	--
	-- Example:
	--   L:Row({
	--     { type="check",  label="Enable", getValue=getEnabled, setValue=setEnabled },
	--     { type="button", label="Preview", onClick=onPreview, width=90 },
	--   })
	function L:Row(items, spacing)
		spacing = spacing or 10
		local yPos = cursor
		local xPos = xOffset
		local widgets = {}

		for _, item in ipairs(items) do
			local w
			if item.type == "check" then
				w = AursUI.CreateCheckbox(parent, item.label, xPos, yPos, item.getValue, item.setValue)
				-- Estimate checkbox width: box (16) + gap (6) + ~7px per character
				xPos = xPos + 16 + 6 + (#item.label * 7) + spacing
			elseif item.type == "button" then
				local bw = item.width or 80
				w = AursUI.CreateButton(parent, item.label, xPos, yPos, item.onClick, bw)
				xPos = xPos + bw + spacing
			elseif item.type == "dropdown" then
				local dw = item.width or 160
				w = AursUI.CreateDropdown(parent, xPos, yPos, item.options, item.getValue, item.setValue, dw)
				xPos = xPos + dw + spacing
			elseif item.type == "slider" then
				local sw = item.width or 160
				local minVal = item.min or 1
				local maxVal = item.max or 120
				w = AursUI.CreateSlider(
					parent,
					item.label,
					xPos,
					yPos,
					minVal,
					maxVal,
					item.getValue,
					item.setValue,
					sw
				)
				w:SetWidth(sw)
				xPos = xPos + sw + spacing
			end
			if w then
				table.insert(widgets, w)
			end
		end

		cursor = cursor - rowHeight
		return unpack(widgets)
	end

	return L
end
