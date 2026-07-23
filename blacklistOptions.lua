local addonName, TT = ...

function UpdateBlacklistDisplay() end

function TT.InitBlacklistOptions(panel, tabContent)
	local L2 = AursUI.NewLayout(tabContent, 16, -10)
	L2:Space(10)

	local layoutButton = L2:Row({
		{
			type = "button",
			label = "Add",
			width = 80,
			onClick = function()
				if not TTDB then
					return
				end
				local editbox = _G["TT_BlacklistEditBox"]
				if not editbox then
					return
				end
				local input = editbox:GetText()
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
				editbox:SetText("")
				TT.UpdateTrinkets()
				TT.UpdateBlacklistDisplay()

				local itemName = C_Item.GetItemNameByID(itemID) or "Item"
				print("|cff00d9ff[Trinket Tracker]|r Added " .. itemName .. " (ID: " .. itemID .. ")")
			end,
		},
	})

	layoutButton:ClearAllPoints()
	layoutButton:SetPoint("TOPRIGHT", tabContent, "TOPRIGHT", -30, -20)

	local editbox = CreateFrame("EditBox", "TT_BlacklistEditBox", tabContent, "InputBoxTemplate")
	editbox:SetSize(250, 24)
	editbox:SetPoint("RIGHT", layoutButton, "LEFT", -10, 0)
	editbox:SetAutoFocus(false)
	editbox:SetMaxLetters(100)

	local scrollFrame = CreateFrame("ScrollFrame", nil, tabContent, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(340, 240)
	scrollFrame:SetPoint("TOPLEFT", tabContent, "TOPLEFT", 30, -65)
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(320, 1)
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
	scrollBg:SetBackdropBorderColor(1, 0.4, 0, 0.3)
	function UpdateBlacklistDisplay()
		if not TTDB or not TTDB.blacklistedTrinkets then
			return
		end

		-- Clean up existing frame objects
		if scrollChild:GetChildren() then
			for _, child in pairs({ scrollChild:GetChildren() }) do
				child:Hide()
				child:SetParent(nil)
			end
		end
		if scrollChild:GetRegions() then
			for _, region in pairs({ scrollChild:GetRegions() }) do
				if region:IsObjectType("FontString") then
					region:Hide()
					region:SetText("")
				end
			end
		end

		if #TTDB.blacklistedTrinkets == 0 then
			local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("TOP", scrollChild, "TOP", 0, -20)
			label:SetText("No trinkets blacklisted")
			label:SetTextColor(0.5, 0.5, 0.5, 1)
		else
			local yOffset = -5
			for i, itemID in ipairs(TTDB.blacklistedTrinkets) do
				C_Item.RequestLoadItemDataByID(itemID)
				local itemName = C_Item.GetItemNameByID(itemID) or "Loading..."
				local itemTexture = C_Item.GetItemIconByID(itemID) or "Interface\\Icons\\INV_Misc_QuestionMark"

				local entry = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
				entry:SetSize(315, 28)
				entry:SetPoint("TOPLEFT", 2, yOffset)
				entry:SetBackdrop({
					bgFile = "Interface\\Buttons\\WHITE8x8",
					edgeFile = "Interface\\Buttons\\WHITE8x8",
					tile = false,
					edgeSize = 1,
				})
				entry:SetBackdropColor(0.04, 0.04, 0.05, 0.8)
				entry:SetBackdropBorderColor(1, 0.4, 0, 0.2)

				local icon = entry:CreateTexture(nil, "ARTWORK")
				icon:SetSize(20, 20)
				icon:SetPoint("LEFT", 6, 0)
				icon:SetTexture(itemTexture)
				icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

				local text = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
				text:SetText(itemName .. " |cff888888(ID: " .. itemID .. ")|r")
				text:SetTextColor(1, 1, 1, 1)

				local removeBtn = AursUI.CreateButton(entry, "Remove", 0, 0, function()
					table.remove(TTDB.blacklistedTrinkets, i)
					TT.UpdateTrinkets()
					UpdateBlacklistDisplay()
					print("|cff00d9ff[Trinket Tracker]|r Removed " .. itemName)
				end)
				removeBtn:SetSize(60, 20)
				removeBtn:ClearAllPoints()
				removeBtn:SetPoint("RIGHT", entry, "RIGHT", -6, 0)

				yOffset = yOffset - 32
			end
			scrollChild:SetHeight(math.max(240, #TTDB.blacklistedTrinkets * 32 + 10))
		end
	end

	panel:HookScript("OnShow", function()
		UpdateBlacklistDisplay()
	end)

	UpdateBlacklistDisplay()
end
