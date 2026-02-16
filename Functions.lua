function IsOnUseTrinket(slotID)
  local itemID = GetInventoryItemID("player", slotID)
  if not itemID then return false end

  for _, blacklistedID in ipairs(TTDB.blacklistedTrinkets) do
    if itemID == blacklistedID then
      return false
    end
  end

  local spellName, spellID = GetItemSpell(itemID)
  if spellName then
    return true
  end

  return false
end

function UpdateTrinket(frame, slotID)
  local itemTexture = GetInventoryItemTexture("player", slotID)
  if itemTexture then
    local itemID = GetInventoryItemID("player", slotID)
    if itemID then
      for _, blacklistedID in ipairs(TTDB.blacklistedTrinkets) do
        if itemID == blacklistedID then
          frame:Hide()
          return
        end
      end
    end

    if TTDB.onlyShowOnUseTrinkets then
      if not IsOnUseTrinket(slotID) then
        frame:Hide()
        return
      end
    end

    if TTDB.onlyShowInCombat and not UnitAffectingCombat("player") then
      frame:Hide()
      return
    end

    frame.icon:SetTexture(itemTexture)

    local start, duration = GetInventoryItemCooldown("player", slotID)
    if start and duration then
      frame.cooldown:SetCooldown(start, duration)
    end

    frame:Show()
  else
    frame:Hide()
  end
end

function UpdateTrinkets()
  UpdateTrinket(trinket1, 13)
  UpdateTrinket(trinket2, 14)
  UpdateTrinketLayout()
end

function UpdateSizes()
  local size = TTDB.iconSize
  trinket1:SetSize(size, size)
  trinket2:SetSize(size, size)
end


function UpdateTrinketLayout()
  local visible1 = trinket1:IsShown()
  local visible2 = trinket2:IsShown()

  if visible1 and not visible2 then
    trinket1:ClearAllPoints()
    trinket1:SetPoint("CENTER", container, "CENTER", 0, 0)
  elseif visible2 and not visible1 then
    trinket2:ClearAllPoints()
    trinket2:SetPoint("CENTER", container, "CENTER", 0, 0)
  elseif visible1 and visible2 then
    if TTDB.layout == "vertical" then
      trinket1:ClearAllPoints()
      trinket1:SetPoint("TOP", container, "TOP", 0, -5)
      trinket2:ClearAllPoints()
      trinket2:SetPoint("TOP", trinket1, "BOTTOM", 0, -5)
    else
      trinket2:ClearAllPoints()
      trinket2:SetPoint("LEFT", container, "LEFT", 5, 0)
      trinket1:ClearAllPoints()
      trinket1:SetPoint("LEFT", trinket2, "RIGHT", 5, 0)
    end
  end
end

function UpdateLayout()
  if TTDB.layout == "vertical" then
    trinket1:ClearAllPoints()
    trinket1:SetPoint("TOP", container, "TOP", 0, -5)
    trinket2:ClearAllPoints()
    trinket2:SetPoint("TOP", trinket1, "BOTTOM", 0, -5)
  else
    trinket2:ClearAllPoints()
    trinket2:SetPoint("LEFT", container, "LEFT", 5, 0)
    trinket1:ClearAllPoints()
    trinket1:SetPoint("LEFT", trinket2, "RIGHT", 5, 0)
  end
  UpdateSizes()
  UpdateTrinketLayout()
end


