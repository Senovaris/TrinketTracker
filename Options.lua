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
      print("|cff9B77F7[Trinket Tracker]|r TinyTooltip detected, skipping /tt registration, use /trt, /tto or /trinkettracker instead")
    end)
    break
  end
end
-- Might move the above to Core.lua but this works --

-- Functions for the panel --
local function CreateSlider(parent, label, xOffset, yOffset, min, max, getValue, setValue)
  local container = CreateFrame("Frame", nil, parent)
  container:SetSize(200, 40)
  container:SetPoint("TOPLEFT", xOffset, yOffset)

  local track = container:CreateTexture(nil, "BACKGROUND")
  track:SetHeight(2)
  track:SetPoint("LEFT", 8, 8)
  track:SetPoint("RIGHT", -8, 8)
  track:SetColorTexture(0.2, 0.2, 0.2, 1)

  local fill = container:CreateTexture(nil, "BORDER")
  fill:SetHeight(2)
  fill:SetPoint("LEFT", track, "LEFT", 0, 0)
  fill:SetColorTexture(0, 0.85, 1, 1)

  local thumb = CreateFrame("Button", nil, container, "BackdropTemplate")
  thumb:SetSize(10, 18)
  thumb:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  thumb:SetBackdropColor(0, 0.85, 1, 1)
  thumb:SetBackdropBorderColor(1, 1, 1, 0.4)

  local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  labelText:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 2)
  labelText:SetTextColor(0.9, 0.9, 0.9, 1)

  local valueText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  valueText:SetPoint("BOTTOMRIGHT", container, "TOPRIGHT", 0, 2)
  valueText:SetTextColor(0, 0.85, 1, 1)

  local trackWidth = 184
  local currentValue = min

  local function UpdateVisuals(val)
    local pct = (val - min) / (max - min)
    local thumbX = 8 + pct * trackWidth
    thumb:ClearAllPoints()
    thumb:SetPoint("CENTER", container, "LEFT", thumbX, 8)
    fill:SetWidth(math.max(0, pct * trackWidth))
    labelText:SetText(label .. ": |cff00d9ff" .. val .. "|r")
  end

  local function SetValue(val)
    val = math.max(min, math.min(max, math.floor(val)))
    if val == currentValue then return end
    currentValue = val
    UpdateVisuals(val)
    setValue(val)
  end

  container.SetValue = function(val)
    currentValue = math.max(min, math.min(max, math.floor(val)))
    UpdateVisuals(currentValue)
  end

  local ok, val = pcall(getValue)
  container.SetValue(ok and val or min)


  local dragging = false

  local function HandleDrag()
    if not dragging then return end
    local cursorX = GetCursorPosition() / UIParent:GetEffectiveScale()
    local left = container:GetLeft() + 8
    local pct = math.max(0, math.min(1, (cursorX - left) / trackWidth))
    SetValue(min + pct * (max - min))
  end

  thumb:SetScript("OnMouseDown", function() dragging = true end)
  thumb:SetScript("OnMouseUp",   function() dragging = false end)
  thumb:SetScript("OnUpdate",    HandleDrag)

  track:EnableMouse(true)
  track:SetScript("OnMouseDown", function()
    dragging = true
    HandleDrag()
  end)
  track:SetScript("OnMouseUp", function() dragging = false end)

  container:SetScript("OnUpdate", HandleDrag)
  return container
end

local function CreateCheckbox(parent, label, xOffset, yOffset, getValue, setValue)
  local container = CreateFrame("Button", nil, parent, "BackdropTemplate")
  container:SetSize(16, 16)
  container:SetPoint("TOPLEFT", xOffset, yOffset)
  container:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  container:SetBackdropColor(0.08, 0.08, 0.08, 1)
  container:SetBackdropBorderColor(0, 0.85, 1, 0.6)

  local check = container:CreateTexture(nil, "OVERLAY")
  check:SetPoint("CENTER")
  check:SetSize(10, 10)
  check:SetColorTexture(0, 0.85, 1, 1)
  check:Hide()

  local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  text:SetPoint("LEFT", container, "RIGHT", 6, 0)
  text:SetText(label)
  text:SetTextColor(1, 1, 1, 1)

  local checked = false
  container.SetChecked = function(val)
    checked = val
    if val then check:Show() else check:Hide() end
  end
  container.GetChecked = function() return checked end

  container:SetScript("OnClick", function()
    container.SetChecked(not checked)
    setValue(checked)
  end)

  return container
end

local function CreateDropdown(parent, xOffset, yOffset, options, getValue, setValue)
  local anchor = CreateFrame("Button", nil, parent, "BackdropTemplate")
  anchor:SetSize(160, 24)
  anchor:SetPoint("TOPLEFT", xOffset, yOffset)
  anchor:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  anchor:SetBackdropColor(0.1, 0.1, 0.1, 1)
  anchor:SetBackdropBorderColor(0, 0.85, 1, 0.6)
  local label = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", 8, 0)
  label:SetText("Select...")
  label:SetTextColor(0.9, 0.9, 0.9, 1)
  local list = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  list:SetSize(160, #options * 24)
  list:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
  list:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  list:SetBackdropColor(0.08, 0.08, 0.08, 1)
  list:SetBackdropBorderColor(0, 0.85, 1, 0.6)
  list:SetFrameLevel(parent:GetFrameLevel() + 10)
  list:Hide()
  for i, opt in ipairs(options) do
    local btn = CreateFrame("Button", nil, list)
    btn:SetSize(160, 24)
    btn:SetPoint("TOPLEFT", 0, -(i - 1) * 24)
    local btnLabel = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btnLabel:SetPoint("LEFT", 8, 0)
    btnLabel:SetText(opt.name)
    btnLabel:SetTextColor(0.9, 0.9, 0.9, 1)
    btn:SetScript("OnEnter", function()
      btnLabel:SetTextColor(0, 0.85, 1, 1)
    end)
    btn:SetScript("OnLeave", function()
      btnLabel:SetTextColor(1, 1, 1, 1)
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
  return anchor
end

local function CreateButton(parent, label, xOffset, yOffset, onClickFunc)
  local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
  btn:SetSize(80, 24)
  btn:SetPoint("TOPLEFT", xOffset, yOffset)
  btn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  btn:SetBackdropColor(0.08, 0.08, 0.08, 1)
  btn:SetBackdropBorderColor(0, 0.85, 1, 0.6)

  local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  text:SetPoint("CENTER")
  text:SetText(label)
  text:SetTextColor(0, 0.85, 1, 1)

  btn:SetScript("OnEnter", function()
    btn:SetBackdropBorderColor(0, 0.85, 1, 1)
    text:SetTextColor(1, 1, 1, 1)
  end)
  btn:SetScript("OnLeave", function()
    btn:SetBackdropBorderColor(0, 0.85, 1, 0.6)
    text:SetTextColor(0, 0.85, 1, 1)
  end)
  btn:SetScript("OnClick", onClickFunc)

  return btn
end

local function CreateColorSwatch(parent, xOffset, yOffset, getColor, setColor)
  local swatch = CreateFrame("Button", nil, parent, "BackdropTemplate")
  swatch:SetSize(24, 24)
  swatch:SetPoint("TOPLEFT", xOffset, yOffset)
  swatch:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  swatch:SetBackdropBorderColor(0, 0.85, 1, 0.6)

  local tex = swatch:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints()

  local function Refresh()
    local r, g, b = getColor()
    tex:SetColorTexture(r, g, b, 1)
  end
  Refresh()

  swatch:SetScript("OnClick", function()
    local r, g, b = getColor()
    ColorPickerFrame:SetupColorPickerAndShow({
      hasOpacity = false,
      r = r, g = g, b = b,
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

-- Panel etc etc --
local panel = CreateFrame("Frame", "TrinketTracker", UIParent, "BackdropTemplate")
panel:SetSize(450, 450)
panel:SetPoint("CENTER")
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetClampedToScreen(true)
panel:SetBackdrop({
  bgFile   = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 2,
})
panel:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
panel:SetBackdropBorderColor(0, 0.85, 1, 0.6)
panel:SetScript("OnMouseDown", function(self, button)
  if button == "LeftButton" then self:StartMoving() end
end)
panel:SetScript("OnMouseUp", function(self)
  self:StopMovingOrSizing()
end)
panel:Hide()

local mainTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
mainTitle:SetPoint("TOP", 0, -10)
mainTitle:SetText("|cff00d9ffTrinket Tracker Options|r")

local subTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
subTitle:SetPoint("TOP", 0, -30)
subTitle:SetText("|cffFFFFFF(Use Edit mode to move)|r")

local closeButton = CreateButton(panel, "X", 0, 0, function() panel:Hide() end)
closeButton:SetSize(24, 24)
closeButton:ClearAllPoints()
closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -8)

local activeTab = 1
local tabs = {}

local function CreateTabButton(parent, index, name)
  local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
  tab:SetSize(145, 28)
  if index == 1 then
    tab:SetPoint("TOPLEFT", parent, "TOP", -148, -50)
  else
    tab:SetPoint("TOPLEFT", parent, "TOP", 3, -50)
  end
  tab:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  tab:SetBackdropColor(0.08, 0.08, 0.08, 1)
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
  line:SetColorTexture(0, 0.85, 1, 1)
  line:Hide()
  tab._line = line

  tab:SetScript("OnClick", function()
    activeTab = index
    UpdateTabs()
  end)

  return tab
end

local function CreateTabContent(parent)
  local content = CreateFrame("Frame", nil, parent)
  content:SetPoint("TOPLEFT", 10, -85)
  content:SetPoint("BOTTOMRIGHT", -10, 10)
  content:Hide()
  return content
end
tabs[1] = { button = CreateTabButton(panel, 1, "Display"), content = CreateTabContent(panel) }
tabs[2] = { button = CreateTabButton(panel, 2, "Blacklist"), content = CreateTabContent(panel) }

function UpdateTabs()
  for i, tab in ipairs(tabs) do
    if i == activeTab then
      tab.button._label:SetTextColor(0, 0.85, 1, 1)
      tab.button._line:Show()
      tab.button:SetBackdropBorderColor(0, 0.85, 1, 0.4)
      tab.content:Show()
    else
      tab.button._label:SetTextColor(0.5, 0.5, 0.5, 1)
      tab.button._line:Hide()
      tab.button:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
      tab.content:Hide()
    end
  end
end

UpdateTabs()


-- Tab 1 --

local onUseCheck = CreateCheckbox(tabs[1].content, "Only show on-use trinkets", 20, -10,
function() return TTDB.onlyShowOnUseTrinkets end,
function(val) TTDB.onlyShowOnUseTrinkets = val; TT.UpdateTrinkets() end)

local inCombatCheck = CreateCheckbox(tabs[1].content, "Only show in combat", 200, -10,
function() return TTDB.onlyShowInCombat end,
function(val) TTDB.onlyShowInCombat = val; TT.UpdateTrinkets() end)

local layoutLabel = tabs[1].content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
layoutLabel:SetPoint("TOPLEFT", 20, -55)
layoutLabel:SetText("Layout")
layoutLabel:SetTextColor(0.6, 0.6, 0.6, 1)

local glowLabel = tabs[1].content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
glowLabel:SetPoint("TOPLEFT", 220, -55)
glowLabel:SetText("Ready Glow")
glowLabel:SetTextColor(0.6, 0.6, 0.6, 1)

local glowPopup

local layoutDropdown = CreateDropdown(tabs[1].content, 20, -70,
{
  { name = "Vertical",   value = "vertical" },
  { name = "Horizontal", value = "horizontal" },
},
function() return TTDB.layout end,
function(val) TTDB.layout = val; TT.UpdateTrinketLayout() end)

local glowDropdown = CreateDropdown(tabs[1].content, 220, -70,
{
  { name = "Button",   value = "button" },
  { name = "Pixel",    value = "pixel" },
  { name = "Autocast", value = "autocast" },
  { name = "None",     value = "none" },
},
function() return TTDB.glowType end,
function(val)
  for _, frame in ipairs({ TT.trinket1, TT.trinket2 }) do
    TT.HideReadyGlow(frame)
  end
  TTDB.glowType = val
end)

local sizeSlider = CreateSlider(tabs[1].content, "Icon Size", 20, -140, 20, 120,
function() return TTDB.iconSize end,
function(val) TTDB.iconSize = val
  if val then
    TT.UpdateSizes()
    TT.RefreshActiveGlows()
    if TT.MSQ_Group then
      TT.MSQ_Group:ReSkin()
    end
  end
end)

local gapSlider  = CreateSlider(tabs[1].content, "Padding", 220, -140, 1, 50,
function() return TTDB.gap end,
function(val) TTDB.gap = val
  if val then
    TT.UpdateTrinketLayout()
    if TT.MSQ_Group then
      TT.MSQ_Group:ReSkin()
    end
  end
end)

-- Option for glows -- 
glowPopup = CreateFrame("Frame", nil, panel, "BackdropTemplate")
glowPopup:SetSize(220, 260)
glowPopup:SetPoint("LEFT", panel, "RIGHT", 8, 0)
glowPopup:SetBackdrop({
  bgFile   = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 2,
})
glowPopup:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
glowPopup:SetBackdropBorderColor(0, 0.85, 1, 0.6)
glowPopup:SetFrameLevel(panel:GetFrameLevel() + 20)
glowPopup:Hide()

local popupTitle = glowPopup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
popupTitle:SetPoint("TOP", 0, -10)
popupTitle:SetTextColor(0, 0.85, 1, 1)

local popupSliders = {}

local glowActive = false

local function BuildGlowPopup()
  -- wipe previous sliders --
  for _, settings in ipairs(popupSliders) do
    settings:Hide()
    settings:SetParent(nil)
  end
  popupSliders = {}

  local type = TTDB.glowType
  local settings = TTDB.glowSettings[type]
  if not settings then glowPopup:Hide() return end

  popupTitle:SetText(type:sub(1,1):upper() .. type:sub(2) .. " Glow Settings")

  local y = -30
  local function AddSlider(label, key, min, max, isFloat)
    local popupSlider = CreateSlider(glowPopup, label, 15, y, min, max,
    function() return isFloat and math.floor(settings[key] * 100) or settings[key] end,
    function(val)
      settings[key] = isFloat and val / 100 or val
      -- refresh glow if active
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
    y = y - 55
  end

  local colorSwatch = CreateColorSwatch(glowPopup, 15, y,
  function() return settings.r, settings.g, settings.b end,
  function(r, g, b)
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
    AddSlider("Lines",     "lines",     1, 16,  false)
    AddSlider("Thickness", "thickness", 1, 12,  false)
    AddSlider("Frequency", "frequency", 1, 100, true)
  elseif type == "autocast" then
    AddSlider("Particles", "particles", 1, 40,  false)
    AddSlider("Frequency", "frequency", 1, 100, true)
  end

  -- resize popup to fit
  glowPopup:SetHeight(math.abs(y) + 20)
end


local testGlowButton = CreateButton(tabs[1].content, "Test Glow", 220, -100, function()
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
    glowPopup:SetScript("OnShow", function()
      BuildGlowPopup()
    end)
  end
end)
testGlowButton:SetSize(160, 24)

-- Tab 2 --

local blacklistInput = CreateFrame("EditBox", nil, tabs[2].content, "InputBoxTemplate")
blacklistInput:SetSize(240, 24)
blacklistInput:SetPoint("TOPLEFT", 20, -20)
blacklistInput:SetAutoFocus(false)
blacklistInput:SetMaxLetters(100)

local addButton = CreateButton(tabs[2].content, "Add", 270, -20, function()
  local input = blacklistInput:GetText()
  if not input or input == "" then
    print("|cff00d9ff[Trinket Tracker]|r Enter a valid item ID or name!")
    return
  end
  local itemID = tonumber(input)
  if not itemID then
    itemID = C_Item.GetItemInfoInstant(input)
    if not itemID then
      print("|cff00d9ff[Trinket Tracker]|r Could not find item.")
      return
    end
  end
  for _, id in ipairs(TTDB.blacklistedTrinkets) do
    if id == itemID then
      local itemName = C_Item.GetItemNameByID(itemID) or "Unknown"
      print("|cff00d9ff[Trinket Tracker]|r " .. itemName .. " is already blacklisted.")
      return
    end
  end
  table.insert(TTDB.blacklistedTrinkets, itemID)
  blacklistInput:SetText("")
  TT.UpdateTrinkets()
  UpdateBlacklistDisplay()
  local itemName = C_Item.GetItemNameByID(itemID) or "Item"
  print("|cff00d9ff[Trinket Tracker]|r Added " .. itemName .. " (ID: " .. itemID .. ")")
end)

local scrollFrame = CreateFrame("ScrollFrame", nil, tabs[2].content, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(360, 260)
scrollFrame:SetPoint("TOPLEFT", 20, -55)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(340, 1)
scrollFrame:SetScrollChild(scrollChild)

local scrollBg = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
scrollBg:SetAllPoints(scrollFrame)
scrollBg:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
scrollBg:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tile = false,
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
scrollBg:SetBackdropColor(0.02, 0.02, 0.02, 0.95)
scrollBg:SetBackdropBorderColor(0, 0.85, 1, 0.3)

function UpdateBlacklistDisplay()
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
    label:SetTextColor(0.5, 0.5, 0.5, 1)
  else
    local yOffset = -5
    for i, itemID in ipairs(TTDB.blacklistedTrinkets) do
      C_Item.RequestLoadItemDataByID(itemID)
      local itemName = C_Item.GetItemNameByID(itemID) or "Loading..."
      local itemTexture = C_Item.GetItemIconByID(itemID) or "Interface\\Icons\\INV_Misc_QuestionMark"

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
      entry:SetBackdropBorderColor(0, 0.85, 1, 0.2)

      local icon = entry:CreateTexture(nil, "ARTWORK")
      icon:SetSize(20, 20)
      icon:SetPoint("LEFT", 4, 0)
      icon:SetTexture(itemTexture)
      icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

      local text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
      text:SetText(itemName .. " |cff888888(ID: " .. itemID .. ")|r")
      text:SetTextColor(1, 1, 1, 1)

      local removeBtn = CreateButton(entry, "Remove", 0, 0, function()
        table.remove(TTDB.blacklistedTrinkets, i)
        TT.UpdateTrinkets()
        UpdateBlacklistDisplay()
        print("|cff00d9ff[Trinket Tracker]|r Removed " .. itemName)
      end)
      removeBtn:SetSize(60, 20)
      removeBtn:ClearAllPoints()
      removeBtn:SetPoint("RIGHT", entry, "RIGHT", -4, 0)

      yOffset = yOffset - 30
    end
    scrollChild:SetHeight(math.max(150, #TTDB.blacklistedTrinkets * 30 + 10))
  end
end


SLASH_TT1 = "/trt"
SLASH_TT2 = "/trinkettracker"
if not ttConflict then
  SLASH_TT3 = "/tt"
end
SlashCmdList["TT"] = function()
  panel:SetShown(not panel:IsShown())
end

panel:SetScript("OnShow", function()
  sizeSlider.SetValue(TTDB.iconSize)
  gapSlider.SetValue(TTDB.gap)
  onUseCheck.SetChecked(TTDB.onlyShowOnUseTrinkets)
  inCombatCheck.SetChecked(TTDB.onlyShowInCombat)
  layoutDropdown.SetSelected(TTDB.layout)
  glowDropdown.SetSelected(TTDB.glowType)
  UpdateBlacklistDisplay()
end)
