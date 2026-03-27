local ADDON_NAME, ns = ...

-- Create main frame for event handling
local frame = CreateFrame("Frame")

-- Get LibDataBroker
local ldb = LibStub("LibDataBroker-1.1")

-- Default icon for "No Set"
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local DEFAULT_TEXT = "No Set"

-- Create the LDB data object
local dataObj = ldb:NewDataObject("Broker_Equipment", {
	type = "data source",
	label = "Equipment Set",
	icon = DEFAULT_ICON,
	text = DEFAULT_TEXT,
	OnClick = function(self, button)
		if button == "LeftButton" then
			BrokerEquipment_OpenCharacterFrame()
		elseif button == "RightButton" then
			BrokerEquipment_ShowDropdown(self)
		end
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Equipment Set")
		tooltip:AddLine(" ")
		tooltip:AddLine("Left-click to open Equipment Manager")
		tooltip:AddLine("Right-click to select equipment set")
	end,
})

-- Function to get currently equipped set info
-- Note: In Retail WoW 12.x, GetEquipmentSetInfo returns different values
-- We need to check if the set is actually equipped by comparing item counts
local function GetCurrentEquipmentSet()
	local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
	if not setIDs then
		return nil
	end

	for _, setID in ipairs(setIDs) do
		local name, iconFileID, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
		-- isEquipped is a boolean indicating if all non-ignored slots are equipped
		if isEquipped then
			return setID, name, iconFileID
		end
	end

	return nil
end

-- Function to update broker display
local function UpdateBrokerDisplay()
	local setID, name, iconFileID = GetCurrentEquipmentSet()

	if setID then
		dataObj.icon = iconFileID or DEFAULT_ICON
		dataObj.text = name or DEFAULT_TEXT
	else
		dataObj.icon = DEFAULT_ICON
		dataObj.text = DEFAULT_TEXT
	end
end

-- Function to open Character frame to Equipment Manager tab
function BrokerEquipment_OpenCharacterFrame()
	ToggleCharacter("PaperDollFrame")
	-- PaperDollFrame sidebar index 3 is the Equipment Manager tab
	if PaperDollFrame_SetSidebar then
		PaperDollFrame_SetSidebar(nil, 3)
	end
end

-- Dropdown menu functions
local function EquipmentSetDropDown_Initialize(self, level)
	local level = level or 1

	if level == 1 then
		-- Title
		local info = UIDropDownMenu_CreateInfo()
		info.text = "Select Equipment Set"
		info.isTitle = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)

		-- Get all equipment sets
		local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
		if setIDs and #setIDs > 0 then
			-- Separator
			info = UIDropDownMenu_CreateInfo()
			info.disabled = true
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)

			-- Get current equipped set for checkmark
			local currentSetID, _, _ = GetCurrentEquipmentSet()

			-- Add each set
			for _, setID in ipairs(setIDs) do
				local name, iconFileID, _, _, _, _, _, numLost = C_EquipmentSet.GetEquipmentSetInfo(setID)
				-- numLost indicates items not available (missing from bags/bank)
				local hasMissingItems = numLost and numLost > 0

				info = UIDropDownMenu_CreateInfo()

				-- Set name in red if missing items, or green checkmark if equipped
				if currentSetID == setID then
					info.text = "|cFF00FF00" .. name .. "|r"
					info.checked = true
				elseif hasMissingItems then
					info.text = "|cFFFF0000" .. name .. "|r"
					info.checked = false
				else
					info.text = name
					info.checked = false
				end

				info.icon = iconFileID
				info.func = function()
					C_EquipmentSet.UseEquipmentSet(setID)
				end
				info.keepShownOnClick = false

				UIDropDownMenu_AddButton(info, level)
			end
		else
			-- No sets available
			info = UIDropDownMenu_CreateInfo()
			info.text = "No equipment sets available"
			info.disabled = true
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

-- Create and configure dropdown menu
local dropdownFrame = CreateFrame("Frame", "BrokerEquipmentDropDown", UIParent, "UIDropDownMenuTemplate")

-- Function to show the dropdown menu at cursor
function BrokerEquipment_ShowDropdown(clickedFrame)
	-- Get cursor position
	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	local scaledX = cursorX / scale
	local scaledY = cursorY / scale
	
	print("BrokerEquipment: Cursor at X:", scaledX, "Y:", scaledY)
	
	-- Create anchor frame at cursor
	if not BrokerEquipment_CursorAnchor then
		BrokerEquipment_CursorAnchor = CreateFrame("Frame", nil, UIParent)
		BrokerEquipment_CursorAnchor:SetWidth(10)
		BrokerEquipment_CursorAnchor:SetHeight(10)
		-- Make it visible for debugging
		local bg = BrokerEquipment_CursorAnchor:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(1, 0, 0, 0.5) -- Red, semi-transparent
	end
	
	-- Position at cursor
	BrokerEquipment_CursorAnchor:ClearAllPoints()
	BrokerEquipment_CursorAnchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", scaledX, scaledY)
	BrokerEquipment_CursorAnchor:Show()
	
	-- Debug: print where the anchor actually is
	print("  Anchor Left:", BrokerEquipment_CursorAnchor:GetLeft())
	print("  Anchor Top:", BrokerEquipment_CursorAnchor:GetTop())
	
	-- Debug: Check DropDownList1 (the actual menu frame that gets shown)
	local list = _G["DropDownList1"]
	if list then
		list:HookScript("OnShow", function(self)
			print("  === DROPDOWN LIST SHOWN ===")
			print("    List Left:", self:GetLeft())
			print("    List Top:", self:GetTop())
			
			-- Get anchor info
			local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
			if point then
				print("    List Anchor point:", point)
				print("    List Anchor relativeTo:", relativeTo and relativeTo:GetName() or "nil")
				print("    List Anchor relativePoint:", relativePoint)
				print("    List Anchor xOfs:", xOfs)
				print("    List Anchor yOfs:", yOfs)
			end
			
			-- Print all points
			for i = 1, self:GetNumPoints() do
				local p, rt, rp, xo, yo = self:GetPoint(i)
				print("    Point", i, ":", p, "relative to", rt and rt:GetName() or "nil", rp, xo, yo)
			end
		end)
	end
	
	-- Initialize and show menu relative to anchor
	UIDropDownMenu_Initialize(dropdownFrame, EquipmentSetDropDown_Initialize, "MENU")
	ToggleDropDownMenu(1, nil, dropdownFrame, BrokerEquipment_CursorAnchor, 0, 0)
	
	-- Force the menu to position correctly - ToggleDropDownMenu doesn't honor our anchor
	local ddl = _G["DropDownList1"]
	if ddl then
		print("  Forcing position to anchor location")
		ddl:ClearAllPoints()
		ddl:SetPoint("TOPLEFT", BrokerEquipment_CursorAnchor, "CENTER", 0, 0)
		print("  Set DDL point to anchor center")
		print("  DDL now at Left:", ddl:GetLeft(), "Top:", ddl:GetTop())
	end
end

-- Event handling
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		-- Initialize on login
		UpdateBrokerDisplay()
	elseif event == "EQUIPMENT_SETS_CHANGED" then
		-- Sets modified (created, deleted, renamed)
		UpdateBrokerDisplay()
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		-- Equipment slot changed
		UpdateBrokerDisplay()
	elseif event == "EQUIPMENT_SWAP_FINISHED" then
		-- Equipment swap completed
		UpdateBrokerDisplay()
	end
end)

-- Initial update
UpdateBrokerDisplay()
