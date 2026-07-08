local addonName, TT = ...

-- Check for TinyTooltip addons --
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local tinyTooltipAddons = {
	"TinyTooltip",
	"TinyTooltip-Remake",
	"TinyTooltip_Colors",
	"TinyTooltip_Filters",
	"TinyTooltip_Options",
	"TinyTooltip_Sorting",
}

local ttConflict = false
for _, name in ipairs(tinyTooltipAddons) do
	if IsAddOnLoaded(name) then
		ttConflict = true
		C_Timer.After(2, function()
			print(
				"|cff9B77F7[Trinket Tracker]|r TinyTooltip detected, skipping /tt registration, use /trt, /tto or /trinkettracker instead"
			)
		end)
		break
	end
end
-- Might move the above to Core.lua but this works --

AursUI.SetTheme(1, 0.4, 0)

local panel = AursUI.CreatePanel(430, 500, "Trinket Tracker Options")

local tabs, UpdateTabs = AursUI.CreateTabs(panel, { "Display", "Blacklist" })

local L1 = AursUI.NewLayout(tabs[1].content, 38, -10)

onUseCheck, inCombatCheck = L1:Row({
	{
		type = "check",
		label = "Only show on-use trinkets",
		getValue = function()
			return TTDB.onlyShowOnUseTrinkets
		end,
		setValue = function(val)
			TTDB.onlyShowOnUseTrinkets = val
			TT.UpdateTrinkets()
		end,
	},
	{
		type = "check",
		label = "Only show in combat",
		getValue = function()
			return TTDB.onlyShowInCombat
		end,
		setValue = function(val)
			TTDB.onlyShowInCombat = val
			TT.UpdateTrinkets()
		end,
	},
})

L1:Space(12)
L1:Separator()
L1:Space(22)

layoutDropdown, glowDropdown = L1:Row({
	{
		type = "dropdown",
		options = {
			{ name = "Vertical", value = "vertical" },
			{ name = "Horizontal", value = "horizontal" },
		},
		getValue = function()
			return TTDB.layout
		end,
		setValue = function(val)
			TTDB.layout = val
			TT.UpdateTrinketLayout()
		end,
	},
	{
		type = "dropdown",
		options = {
			{ name = "Button", value = "button" },
			{ name = "Pixel", value = "pixel" },
			{ name = "Autocast", value = "autocast" },
			{ name = "None", value = "none" },
		},
		getValue = function()
			return TTDB.glowType
		end,
		setValue = function(val)
			for _, frame in ipairs({ TT.trinket1, TT.trinket2 }) do
				TT.HideReadyGlow(frame)
			end
			TTDB.glowType = val
		end,
	},
})
TT.InitGlowOptions(panel, L1, glowDropdown)

L1:Separator()
L1:Space(22)

local sizeSlider, gapSlider = L1:Row({
	{
		type = "slider",
		label = "Icon Size",
		width = 150,
		min = 20,
		max = 120,
		getValue = function()
			return TTDB.iconSize
		end,
		setValue = function(val)
			TTDB.iconSize = val
			if val then
				TT.UpdateSizes()
				TT.RefreshActiveGlows()
				if TT.MSQ_Group then
					TT.MSQ_Group:ReSkin()
				end
			end
		end,
	},
	{
		type = "slider",
		label = "Padding",
		width = 150,
		min = 1,
		max = 50,
		getValue = function()
			return TTDB.gap
		end,
		setValue = function(val)
			TTDB.gap = val
			if val then
				TT.UpdateTrinketLayout()
				if TT.MSQ_Group then
					TT.MSQ_Group:ReSkin()
				end
			end
		end,
	},
})

-- Tab 2

TT.InitBlacklistOptions(panel, tabs[2].content)

--

panel:SetScript("OnShow", function()
	sizeSlider.SetValue(TTDB.iconSize)
	gapSlider.SetValue(TTDB.gap)
	onUseCheck.SetChecked(TTDB.onlyShowOnUseTrinkets)
	inCombatCheck.SetChecked(TTDB.onlyShowInCombat)
	layoutDropdown.SetSelected(TTDB.layout)
	glowDropdown.SetSelected(TTDB.glowType)
	UpdateTabs()
	UpdateBlacklistDisplay()
end)

-- Slash command
SLASH_TT1 = "/trt"
SLASH_TT2 = "/trinkettracker"
if not ttConflict then
	SLASH_TT3 = "/tt"
end
SlashCmdList["TT"] = function()
	panel.Toggle()
end
