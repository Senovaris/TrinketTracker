local addonName, TT = ...

-- Global/Upvalued variables for tracking state
local glowPopup
local popupSliders = {}
local glowActive = false
local popupTitle

local function BuildGlowPopup()
	-- Wipe previous sliders
	for _, settings in ipairs(popupSliders) do
		settings:Hide()
		settings:SetParent(nil)
	end
	popupSliders = {}

	local type = TTDB.glowType
	local settings = TTDB.glowSettings[type]
	if not settings or type == "none" then
		if glowPopup then
			glowPopup:Hide()
		end
		return
	end

	popupTitle:SetText(type:sub(1, 1):upper() .. type:sub(2) .. " Glow Settings")

	local y = -30
	local function AddSlider(label, key, min, max, isFloat)
		local popupSlider = AursUI.CreateSlider(glowPopup, label, 15, y, min, max, function()
			return isFloat and math.floor(settings[key] * 100) or settings[key]
		end, function(val)
			settings[key] = isFloat and val / 100 or val
			if glowActive then
				for _, frame in ipairs({ TT.trinket1, TT.trinket2 }) do
					if frame:IsShown() then
						TT.HideReadyGlow(frame)
						TT.ShowReadyGlow(frame)
					end
				end
			end
		end)
		popupSlider:SetWidth(190)
		table.insert(popupSliders, popupSlider)
		y = y - 60
	end

	local colorSwatch = AursUI.CreateColorSwatch(glowPopup, function()
		return settings.r, settings.g, settings.b
	end, function(r, g, b)
		settings.r, settings.g, settings.b = r, g, b
		if glowActive then
			for _, frame in ipairs({ TT.trinket1, TT.trinket2 }) do
				if frame:IsShown() then
					TT.HideReadyGlow(frame)
					TT.ShowReadyGlow(frame)
				end
			end
		end
	end)
	colorSwatch:ClearAllPoints()
	colorSwatch:SetPoint("TOPLEFT", glowPopup, "TOPLEFT", 15, y)

	local colorLabel = glowPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	colorLabel:SetPoint("LEFT", colorSwatch, "RIGHT", 8, 0)
	colorLabel:SetText("Color")
	colorLabel:SetTextColor(0.9, 0.9, 0.9, 1)

	table.insert(popupSliders, colorSwatch)
	table.insert(popupSliders, colorLabel)
	y = y - 55

	if type == "button" then
		AddSlider("Frequency", "frequency", 1, 100, true)
	elseif type == "pixel" then
		AddSlider("Lines", "lines", 1, 16, false)
		AddSlider("Thickness", "thickness", 1, 12, false)
		AddSlider("Frequency", "frequency", 1, 100, true)
	elseif type == "autocast" then
		AddSlider("Particles", "particles", 1, 40, false)
		AddSlider("Frequency", "frequency", 1, 100, true)
	end

	glowPopup:SetHeight(math.abs(y) + 20)
end

-- initialization function
function TT.InitGlowOptions(panel, layoutEngine)
	-- Create popup frame
	glowPopup = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	glowPopup:SetSize(220, 260)
	glowPopup:SetPoint("LEFT", panel, "RIGHT", 8, 0)
	glowPopup:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 2,
	})
	glowPopup:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
	glowPopup:SetBackdropBorderColor(1, 0.4, 0, 0.6)
	glowPopup:SetFrameLevel(panel:GetFrameLevel() + 20)
	glowPopup:Hide()

	popupTitle = glowPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	popupTitle:SetPoint("TOP", 0, -10)
	popupTitle:SetTextColor(1, 0.4, 0, 1)

	glowPopup:SetScript("OnShow", function()
		BuildGlowPopup()
	end)

	local testGlowButtonRow = layoutEngine:Row({
		{
			type = "button",
			label = "Test Glow",
			width = 160,
			onClick = function()
				glowActive = not glowActive
				for _, frame in ipairs({ TT.trinket1, TT.trinket2 }) do
					if frame:IsShown() then
						if glowActive then
							TT.ShowReadyGlow(frame)
							frame._ttReadyGlow = true
						else
							TT.HideReadyGlow(frame)
							frame._ttReadyGlow = true
						end
					end
				end
				if glowActive then
					BuildGlowPopup()
					glowPopup:Show()
				else
					glowPopup:Hide()
				end
			end,
		},
	})

	testGlowButtonRow:ClearAllPoints()
	testGlowButtonRow:SetPoint("TOPLEFT", glowDropdown, "BOTTOMLEFT", 0, -8)
end
