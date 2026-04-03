TTDB = TTDB or {
  x = 0,
  y = 0,
  onlyShowOnUseTrinkets = true,
  onlyShowInCombat = false,
  layout = "vertical",
  iconSize = 44,
  blacklistedTrinkets = {
    190958,
    193718,
    248583,
  },
  _initialized = false,
}

if not TTDB._initialized then
  TTDB.blacklistedTrinkets = {
    190958,
    193718,
    248583,
  }
  TTDB._initialized = true
end

if TTDB.iconSize == nil then
  TTDB.iconSize = 44
end
if TTDB.blacklistedTrinkets == nil then
  TTDB.blacklistedTrinkets = {}
end

local addonName, TT = ...

-- Trinkets --

container = CreateFrame("Frame", "Trinkets", UIParent)
container:SetSize(110, 110)
container:SetPoint("CENTER", UIParent, "CENTER", TTDB.x, TTDB.y)
container:SetClampedToScreen(true)

trinket1 = CreateFrame("Frame", nil, container)
trinket1:SetSize(44, 44)
trinket1:SetPoint("TOP", container, "TOP", 0, 0)
trinket1.icon = trinket1:CreateTexture(nil, "ARTWORK")
trinket1.icon:SetAllPoints()
trinket1.cooldown = CreateFrame("Cooldown", nil, trinket1, "CooldownFrameTemplate")
trinket1.cooldown:SetAllPoints()

trinket2 = CreateFrame("Frame", nil, container)
trinket2:SetSize(44, 44)
trinket2:SetPoint("TOP", trinket1, "BOTTOM", 0, 0)
trinket2.icon = trinket2:CreateTexture(nil, "ARTWORK")
trinket2.icon:SetAllPoints()
trinket2.cooldown = CreateFrame("Cooldown", nil, trinket2, "CooldownFrameTemplate")
trinket2.cooldown:SetAllPoints()

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    UpdateLayout()
    UpdateSizes()

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
        point = 'CENTER',
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

        container:ClearAllPoints()
        container:SetPoint(TTDB.layouts[layoutName].point or "CENTER", 
        UIParent,
        TTDB.layouts[layoutName].point or "CENTER",
        TTDB.layouts[layoutName].x or 0,
        TTDB.layouts[layoutName].y or 0)
      end)
      LEM:AddFrame(container, onPositionChanged, defaultPosition)
    end
    C_Timer.After(0.5, UpdateTrinkets)
  elseif event == "PLAYER_ENTERING_WORLD" then
    UpdateLayout()
    if TT.MSQ_Group then
      TT.MSQ_Group:ReSkin()
    end
    UpdateTrinkets()
  end
end)

-- Added Masque Support (Fucks up the size)--

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
  TT.MSQ_Group:AddButton(trinket1, GetMasqueData(trinket1))
  TT.MSQ_Group:AddButton(trinket2, GetMasqueData(trinket2))
  TT.MSQ_Group:RegisterCallback(function()
    UpdateLayout()
    UpdateSizes()
  end)
end

C_Timer.After(1, function()
  print("|cff00d9ffTrinket Tracker loaded!|r|cffFFFFFF Type /tt, /trt, /tto or /trinkettracker for options|r")
end)
