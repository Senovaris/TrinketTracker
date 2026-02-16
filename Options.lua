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
      print("|cff9B77F7[Trinket Tracker]|r TinyTooltip detected, skipping /tt registration, use /trt, /tto or /trinkettracker instead")
    end)
    break
  end
end
-- Might move the above to Core.lua but this works --

local panel = CreateFrame("Frame", "TrinketTracker", UIParent, BackdropTemplateMixin and "BackdropTemplate")
panel:SetSize(430, 450)
panel:SetPoint("CENTER")
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetClampedToScreen(true)
panel:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
panel:SetBackdropColor(0, 0, 0, 0.9)
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("|cff00d9ffTrinket Tracker Options|r")

local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
subtitle:SetPoint("TOP", 0, -30)
subtitle:SetText("|cffFFFFFF(Use Edit mode to move)|r")

local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -5)

panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

local onUseCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
onUseCheck:SetPoint("TOPLEFT", 20, -40)
onUseCheck.text = onUseCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
onUseCheck.text:SetPoint("LEFT", onUseCheck, "RIGHT", 5, 0)
onUseCheck.text:SetText("Only show On-Use Trinkets")
onUseCheck.text:SetTextColor(1, 1, 1, 1)
onUseCheck:SetChecked(TTDB.onlyShowOnUseTrinkets)
onUseCheck:SetScript("OnClick", function(self)
  TTDB.onlyShowOnUseTrinkets = self:GetChecked()
  UpdateTrinkets()
end)

local inCombatCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
inCombatCheck:SetPoint("TOP", 25, -40)
inCombatCheck.text = inCombatCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
inCombatCheck.text:SetPoint("LEFT", inCombatCheck, "RIGHT", 5, 0)
inCombatCheck.text:SetText("Only show in combat")
inCombatCheck.text:SetTextColor(1, 1, 1, 1)
inCombatCheck:SetChecked(TTDB.onlyShowInCombat)
inCombatCheck:SetScript("OnClick", function(self)
  TTDB.onlyShowInCombat = self:GetChecked()
  UpdateTrinkets()
end)

local sizeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
sizeLabel:SetPoint("TOPLEFT", 20, -80)
sizeLabel:SetText("Icon Size: " .. TTDB.iconSize)
sizeLabel:SetTextColor(1, 1, 1, 1)

local sizeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", 20, -100)
sizeSlider:SetMinMaxValues(24, 80)
sizeSlider:SetValue(TTDB.iconSize)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
sizeSlider:SetWidth(360)
sizeSlider:SetScript("OnValueChanged", function(_, value)
  TTDB.iconSize = value
  sizeLabel:SetText("Icon Size: " .. value)
  UpdateSizes()
end)

local layoutLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
layoutLabel:SetPoint("TOPLEFT", 20, -140)
layoutLabel:SetText("Layout:")
layoutLabel:SetTextColor(1, 1, 1, 1)

local layoutDropdown = CreateFrame("Frame", "TTLayoutDropdown", panel, "UIDropDownMenuTemplate")
layoutDropdown:SetPoint("TOPLEFT", 50, -130)
UIDropDownMenu_SetWidth(layoutDropdown, 100)

local function InitLayoutDropdown()
  local info = UIDropDownMenu_CreateInfo()

  info.text = "Vertical"
  info.value = "vertical"
  info.func = function()
    TTDB.layout = "vertical"
    UpdateLayout()
    UIDropDownMenu_SetText(layoutDropdown, "Vertical")
  end
  info.checked = (TTDB.layout == "vertical")
  UIDropDownMenu_AddButton(info)

  info.text = "Horizontal"
  info.value = "horizontal"
  info.func = function()
    TTDB.layout = "horizontal"
    UpdateLayout()
    UIDropDownMenu_SetText(layoutDropdown, "Horizontal")
  end
  info.checked = (TTDB.layout == "horizontal")
  UIDropDownMenu_AddButton(info)
end

UIDropDownMenu_Initialize(layoutDropdown, InitLayoutDropdown)
UIDropDownMenu_SetText(layoutDropdown, TTDB.layout == "vertical" and "Vertical" or "Horizontal")

local blacklistHeading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
blacklistHeading:SetPoint("TOPLEFT", 20, -175)
blacklistHeading:SetText("Blacklist Trinkets")
blacklistHeading:SetTextColor(1, 1, 1, 1)

local blacklistInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
blacklistInput:SetSize(200, 20)
blacklistInput:SetPoint("TOPLEFT", 20, -195)
blacklistInput:SetAutoFocus(false)
blacklistInput:SetMaxLetters(100)

local addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
addButton:SetSize(60, 22)
addButton:SetPoint("LEFT", blacklistInput, "RIGHT", 5, 0)
addButton:SetText("Add")
addButton:SetScript("OnClick", function()
  local itemID = tonumber(blacklistInput:GetText())
  if not itemID then
    print("|cff9B77F7[Trinket Tracker]|r Enter a valid number!")
    return
  end

  for _, id in ipairs(TTDB.blacklistedTrinkets) do
    if id == itemID then
      print("|cff9B77F7[Trinket Tracker]|r Already blacklisted!")
      return
    end
  end

  table.insert(TTDB.blacklistedTrinkets, itemID)
  blacklistInput:SetText("")
  UpdateTrinkets()
  print("|cff9B77F7[Trinket Tracker]|r Added!")
end)

local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(360, 230)
scrollFrame:SetPoint("TOPLEFT", 20, -215)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(340, 1)
scrollFrame:SetScrollChild(scrollChild)

local scrollBg = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
scrollBg:SetAllPoints(scrollFrame)
scrollBg:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
scrollBg:SetBackdrop({
  bgFile = "Interface\\Buttons\\White8x8",
  edgeFile = nil,
  tile = false,
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
scrollBg:SetBackdropColor(0.02, 0.02, 0.02, 0.95)
scrollBg:SetBackdropBorderColor(0.080, 0.080, 0.090, 0.95)

local function UpdateBlacklistDisplay()
  for _, child in pairs({scrollChild:GetChildren()}) do
    child:Hide()
    child:SetParent(nil)
  end

  for _, region in pairs({scrollChild:GetRegions()}) do
    if region:IsObjectType("FontString") then
      region:Hide()
      region:SetText("")
    end
  end

  if #TTDB.blacklistedTrinkets == 0 then
    local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 5, -5)
    label:SetText("No trinkets blacklisted")
    label:SetTextColor(1, 1, 1, 1)
  else
    local yOffset = -5
    for i, itemID in ipairs(TTDB.blacklistedTrinkets) do

      local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
      itemName = itemName or "Loading..."
      itemTexture = itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark"

      local entry = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
      entry:SetSize(330, 28)
      entry:SetPoint("TOPLEFT", 5, yOffset)
      entry:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
      })
      entry:SetBackdropColor(0.04, 0.04, 0.05, 0.8)
      entry:SetBackdropBorderColor(0.91, 0.91, 0.91, 1)

      local icon = entry:CreateTexture(nil, "ARTWORK")
      icon:SetSize(20, 20)
      icon:SetPoint("LEFT", 4, 0)
      icon:SetTexture(itemTexture)
      icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

      local text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
      text:SetText(itemName .. " |cff888888(ID: " .. itemID .. ")|r")
      text:SetTextColor(1, 1, 1, 1)


      local removeBtn = CreateFrame("Button", nil, entry, "UIPanelButtonTemplate")
      removeBtn:SetSize(60, 20)
      removeBtn:SetPoint("RIGHT", -4, 0)
      removeBtn:SetText("Remove")
      removeBtn:SetScript("OnClick", function()
        table.remove(TTDB.blacklistedTrinkets, i)
        UpdateTrinkets()
        UpdateBlacklistDisplay()
        print("|cff9B77F7[Trinket Tracker]|r Removed " .. itemName)
      end)
      yOffset = yOffset - 30
    end
    scrollChild:SetHeight(math.max(150, #TTDB.blacklistedTrinkets * 30 + 10))
  end
end

addButton:SetScript("OnClick", function()
  local input = blacklistInput:GetText()
  if not input or input == "" then
    print("|cff9B77F7[Trinket Tracker]|r Enter a valid number!")
    return
  end
  local itemID = tonumber(input)
  if not itemID then
    itemID = C_Item.GetItemInfoInstant(input)
    if not itemID then
      return
    end
  end

  for _, id in ipairs(TTDB.blacklistedTrinkets) do
    if id == itemID then
      local itemName = C_Item.GetItemNameByID(itemID) or "Unknown"
      print("|cffFFFFFF" .. itemName .. " (ID: " .. itemID .. ") already blacklisted|r")
      return
    end
  end

  table.insert(TTDB.blacklistedTrinkets, itemID)
  blacklistInput:SetText("")
  UpdateTrinkets()
  UpdateBlacklistDisplay()

  local itemName = C_Item.GetItemNameByID(itemID) or "Item"
  print("|cff00FFFF[Trinket Tracker]|r Added " .. itemName .. " (ID: " .. itemID .. ")!")
end)

UpdateBlacklistDisplay()
SLASH_TT1 = "/trt"
SLASH_TT2 = "/tto"
SLASH_TT3 = "/trinkettracker"
if not ttConflict then
  SLASH_TT4 = "/tt"
end
SlashCmdList["TT"] = function()
  panel:SetShown(not panel:IsShown())
end

panel:SetScript("OnShow", function()
  onUseCheck:SetChecked(TTDB.onlyShowOnUseTrinkets)
  inCombatCheck:SetChecked(TTDB.onlyShowInCombat)
  sizeSlider:SetValue(TTDB.iconSize)
  UIDropDownMenu_SetText(layoutDropdown, TTDB.layout == "vertical" and "Vertical" or "Horizontal")
  UpdateBlacklistDisplay()
end)
