-- Well it's the default blacklist :) (Will be updated when new trinkets comes out) [Midnight] --
local defaultBlacklist = {
  193718, -- Emerald Coach's [Dungeon]
  248583, -- Drums of Renewed Bonds [Delve]
}

local addonName, TT = ...

-- Trinkets --

TT.container = CreateFrame("Frame", "Trinkets", UIParent)
TT.container:SetSize(110, 110)
TT.container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
TT.container:SetClampedToScreen(true)

TT.trinket1 = CreateFrame("Frame", nil, TT.container)
TT.trinket1:SetSize(44, 44)
TT.trinket1:SetPoint("TOP", TT.container, "TOP", 0, 0)
TT.trinket1.icon = TT.trinket1:CreateTexture(nil, "ARTWORK")
TT.trinket1.icon:SetAllPoints()
TT.trinket1.cooldown = CreateFrame("Cooldown", nil, TT.trinket1, "CooldownFrameTemplate")
TT.trinket1.cooldown:SetAllPoints()

TT.trinket2 = CreateFrame("Frame", nil, TT.container)
TT.trinket2:SetSize(44, 44)
TT.trinket2:SetPoint("TOP", TT.trinket1, "BOTTOM", 0, 0)
TT.trinket2.icon = TT.trinket2:CreateTexture(nil, "ARTWORK")
TT.trinket2.icon:SetAllPoints()
TT.trinket2.cooldown = CreateFrame("Cooldown", nil, TT.trinket2, "CooldownFrameTemplate")
TT.trinket2.cooldown:SetAllPoints()

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
  if event == "ADDON_LOADED" and arg1 == "TrinketTracker" then
    TTDB = TTDB or {}
    TTDB.iconSize = TTDB.iconSize or 44
    TTDB.layout = TTDB.layout or "vertical"
    TTDB.onlyShowInCombat = TTDB.onlyShowInCombat or false
    TTDB.blacklistedTrinkets = TTDB.blacklistedTrinkets or {}
    if TTDB.onlyShowOnUseTrinkets == nil then
      TTDB.onlyShowOnUseTrinkets = true
    end
    TTDB.gap = TTDB.gap or 1
    self:UnregisterEvent("ADDON_LOADED")

  elseif event == "PLAYER_LOGIN" then

    -- Merge Loop
    for _, defaultID in ipairs(defaultBlacklist) do
      local found = false
      for _, userID in ipairs(TTDB.blacklistedTrinkets) do
        if userID == defaultID then
          found = true
          break
        end
      end
      if not found then
        table.insert(TTDB.blacklistedTrinkets, defaultID)
      end
    end

    -- LibEditMode --

    local LEM = LibStub('LibEditMode')

    if LEM then
      local function onPositionChanged(frame, layoutName, point, x, y)
        if not TTDB.layouts then
          TTDB.layouts = {}
        end
        if not TTDB.layouts[layoutName] then
          TTDB.layouts[layoutName] = {}
        end
        TTDB.layouts[layoutName].point = point
        TTDB.layouts[layoutName].x = x
        TTDB.layouts[layoutName].y = y
      end

      local defaultPosition = {
        point = "CENTER",
        x = 0,
        y = 0,
      }

      LEM:RegisterCallback('layout', function(layoutName)
        if not TTDB.layouts then
          TTDB.layouts = {}
        end
        if not TTDB.layouts[layoutName] then
          TTDB.layouts[layoutName] = {point = "CENTER", x = 0, y = 0}
        end

        TT.container:ClearAllPoints()
        TT.container:SetPoint(TTDB.layouts[layoutName].point or "CENTER",
        UIParent,
        TTDB.layouts[layoutName].point or "CENTER",
        TTDB.layouts[layoutName].x or 0,
        TTDB.layouts[layoutName].y or 0)
      end)
      LEM:AddFrame(TT.container, onPositionChanged, defaultPosition)
    end

  elseif event == "PLAYER_ENTERING_WORLD" then
    TT.UpdateTrinketLayout()
    TT.UpdateSizes()
    if TT.MSQ_Group then
      TT.MSQ_Group:ReSkin()
    end
    C_Timer.After(0.5, TT.UpdateTrinkets)

  elseif event == "PLAYER_EQUIPMENT_CHANGED"
    or event == "BAG_UPDATE_COOLDOWN"
    or event == "PLAYER_REGEN_ENABLED"
    or event == "PLAYER_REGEN_DISABLED" then
    TT.UpdateTrinkets()
  end
end)

-- Added Masque Support --

local function GetMasqueData(button)
  return {
    Icon = button.icon,
    Cooldown = button.cooldown,
    Border = button.border,
    Count = button.count,
  }
end

local Masque = LibStub("Masque", true)
if Masque then
  TT.MSQ_Group = Masque:Group("Trinket Tracker")
  TT.MSQ_Group:AddButton(TT.trinket1, GetMasqueData(TT.trinket1))
  TT.MSQ_Group:AddButton(TT.trinket2, GetMasqueData(TT.trinket2))
  TT.MSQ_Group:RegisterCallback(function()
    TT.UpdateTrinketLayout()
    TT.UpdateSizes()
  end)
end

C_Timer.After(1, function()
  print("|cff00d9ffTrinket Tracker loaded!|r|cffFFFFFF Type /tt, /trt or /trinkettracker for options|r")
  C_Timer.NewTicker(0.1, function()
    if TT.UpdateTrinkets then TT.UpdateTrinkets() end
  end)
end)


