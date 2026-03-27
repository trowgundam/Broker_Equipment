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
local function GetCurrentEquipmentSet()
    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    if not setIDs then return nil end
    
    for _, setID in ipairs(setIDs) do
        local name, iconFileID, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
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
            local currentSetID = GetCurrentEquipmentSet()
            
            -- Add each set
            for _, setID in ipairs(setIDs) do
                local name, iconFileID, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
                local hasMissingItems = C_EquipmentSet.IsMissingEquipmentSetItem(setID)
                
                info = UIDropDownMenu_CreateInfo()
                
                -- Set name in red if missing items
                if hasMissingItems then
                    info.text = "|cFFFF0000" .. name .. "|r"
                else
                    info.text = name
                end
                
                info.icon = iconFileID
                info.checked = (currentSetID == setID)
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

-- Function to show the dropdown menu
function BrokerEquipment_ShowDropdown(parentFrame)
    UIDropDownMenu_Initialize(dropdownFrame, EquipmentSetDropDown_Initialize, "MENU")
    ToggleDropDownMenu(1, nil, dropdownFrame, parentFrame, 0, 0)
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
