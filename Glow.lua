local addonName, TT = ...

function GetLCG()
  return LibStub and LibStub("LibCustomGlow-1.0", true)
end

local glowHandlers = {
  none = {
    show = function(frame, LCG) end,
    hide = function(frame, LCG) end,
  },
  button = {
    show = function(frame, LCG)
      local s = TTDB.glowSettings.button
      LCG.ButtonGlow_Start(frame, {s.r, s.g, s.b, 1}, s.frequency)
    end,
    hide = function(frame, LCG) LCG.ButtonGlow_Stop(frame) end,
  },
  pixel = {
    show = function(frame, LCG)
      local s = TTDB.glowSettings.pixel
      LCG.PixelGlow_Start(frame, {s.r, s.g, s.b, 1}, s.lines, s.frequency, nil, s.thickness)
    end,
    hide = function(frame, LCG) LCG.PixelGlow_Stop(frame) end,
  },
  autocast = {
    show = function(frame, LCG)
      local s = TTDB.glowSettings.autocast
      LCG.AutoCastGlow_Start(frame, {s.r, s.g, s.b, 1}, s.particles, s.frequency)
    end,
    hide = function(frame, LCG) LCG.AutoCastGlow_Stop(frame) end,
  },
}

function TT.ShowReadyGlow(frame)
  LCG = GetLCG()
  if not LCG then return end
  local handler = glowHandlers[TTDB.glowType] or glowHandlers.none
  handler.show(frame, LCG)
end

function TT.HideReadyGlow(frame)
  LCG = GetLCG()
  if not LCG then return end
  local handler = glowHandlers[TTDB.glowType] or glowHandlers.none
  handler.hide(frame, LCG)
end
