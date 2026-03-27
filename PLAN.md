# Broker_Equipment - Comprehensive Implementation Plan

## Overview
A World of Warcraft addon that creates a LibDataBroker (LDB) plugin to display and manage Equipment Manager sets. The addon provides a lightweight broker showing the currently equipped set with click interactions.

## Project Structure

```
Broker_Equipment/
├── .git/                       # Git repository
├── .gitmodules                 # Git submodule configuration
├── Broker_Equipment.toc        # Addon metadata
├── Broker_Equipment.lua        # Main addon logic
├── Broker_Equipment.xml        # Frame/Script definitions (if needed)
├── PLAN.md                     # This file
└── Libs/
    └── LibDataBroker-1.1/
        └── LibDataBroker-1.1.lua
```

## Technical Specifications

### Target Platform
- **Game**: World of Warcraft Retail
- **Interface Version**: 12.0.1
- **Lua Version**: 5.1 (WoW's Lua)
- **API**: C_EquipmentSet (Retail WoW API)

### Design Principles
- **Zero external dependencies** beyond embedded LibDataBroker
- **Minimal footprint** - single .toc + .lua file
- **Native Blizzard UI** - use built-in dropdowns and APIs
- **Stateless** - all data from live game state, no saved variables

## Implementation Details

### 1. Git Repository Setup

```bash
# Initialize repository
git init

# Add LibDataBroker as submodule
# Source: https://github.com/tekkub/libdatabroker-1-1
git submodule add https://github.com/tekkub/libdatabroker-1-1.git Libs/LibDataBroker-1.1

# Commit initial setup
git add .
git commit -m "Initial setup with LibDataBroker submodule"
```

### 2. Broker_Equipment.toc

```toc
## Interface: 120001
## Title: Broker Equipment
## Notes: Shows current Equipment Manager set with click actions
## Author: User
## Version: 1.0.0
## Dependencies: LibDataBroker-1.1

Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua
Broker_Equipment.lua
```

### 3. Broker_Equipment.lua - Core Components

#### Event Frame Setup
```lua
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
```

#### LDB Plugin Registration
```lua
local ldb = LibStub("LibDataBroker-1.1")
local dataObj = ldb:NewDataObject("Broker_Equipment", {
    type = "data source",
    label = "Equipment Set",
    icon = "Interface\Icons\INV_Misc_QuestionMark",
    text = "No Set",
    OnClick = OnBrokerClick,
    OnTooltipShow = OnTooltipShow,
})
```

#### Core Functions

**GetCurrentSet()**
- Query `C_EquipmentSet.GetEquipmentSetIDs()` for all set IDs
- Iterate through IDs calling `C_EquipmentSet.GetEquipmentSetInfo(id)`
- Check `isEquipped` flag for each set
- Return: setID, name, icon, isEquipped

**UpdateBrokerDisplay(setID, name, icon)**
- Update `dataObj.icon` with set icon or default "?"
- Update `dataObj.text` with set name or "No Set"
- Trigger LDB update notification

**OnBrokerClick(frame, button)**
- `button == "LeftButton"`: Open Character + Equipment tab
  - `ToggleCharacter("PaperDollFrame")`
  - `PaperDollFrame_SetSidebar(nil, 3)` for Equipment Manager tab
- `button == "RightButton"`: Show equipment set dropdown

#### Dropdown Menu Implementation

**EquipmentSetDropDownMenu()**
```lua
local menu = {
    -- Header
    { text = "Select Equipment Set", isTitle = true, notCheckable = true },
    -- Dynamic entries from C_EquipmentSet.GetEquipmentSetIDs()
    -- Each entry:
    --   text = name
    --   colorCode = missingItems and "|cFFFF0000" or nil  (red if missing)
    --   icon = setIcon
    --   func = function() C_EquipmentSet.UseEquipmentSet(setID) end
    --   checked = isEquipped
}
```

**Menu Data Logic:**
1. Get all equipment set IDs
2. For each set, get info via `C_EquipmentSet.GetEquipmentSetInfo()`
3. Check `C_EquipmentSet.IsMissingEquipmentSetItem(setID)` for missing items
4. Build menu entries with:
   - Red color (`|cFFFF0000`) if missing items
   - Checkmark if currently equipped
   - Set icon as left icon
   - Click action to equip set

#### Event Handlers

**PLAYER_LOGIN**
- Initialize addon on login
- Perform initial equipment set query
- Set up broker display

**EQUIPMENT_SETS_CHANGED**
- Equipment sets modified (created/deleted/renamed)
- Re-query current set and update display

**PLAYER_EQUIPMENT_CHANGED**
- Individual equipment slots changed
- Check if still matches current set
- Update display if needed

**EQUIPMENT_SWAP_FINISHED**
- Equipment swap operation completed
- Update broker to reflect new state

### 4. UI Interactions

**Opening Character Equipment Tab:**
```lua
-- Method 1: Direct tab switching
ToggleCharacter("PaperDollFrame")
-- Then navigate to Equipment tab
-- Equipment Manager is typically tab index 3 in Retail

-- Or use:
SetPaperDollSidebar(3)  -- Equipment Manager is sidebar 3
```

**Dropdown Menu Styling:**
- Use `UIDropDownMenu_AddButton()` for standard look
- Apply `colorCode` for red text on incomplete sets
- Use `checked` property for equipped indicator
- Set `keepShownOnClick = false` to close after selection

### 5. API Reference

**C_EquipmentSet Functions:**
- `C_EquipmentSet.GetEquipmentSetIDs()` - Returns table of set IDs
- `C_EquipmentSet.GetEquipmentSetInfo(setID)` - Returns name, iconFileID, isEquipped, numItems, numEquipped
- `C_EquipmentSet.UseEquipmentSet(setID)` - Equips a set
- `C_EquipmentSet.IsMissingEquipmentSetItem(setID)` - Returns true if set has missing items

**Events:**
- `PLAYER_LOGIN` - Initial setup
- `EQUIPMENT_SETS_CHANGED` - Sets list modified
- `PLAYER_EQUIPMENT_CHANGED` - Equipment slot changed
- `EQUIPMENT_SWAP_FINISHED` - Swap operation complete

### 6. Error Handling

**Graceful Degradation:**
- Handle nil returns from API gracefully
- Default to "No Set" state on errors
- Log errors to console for debugging

**Edge Cases:**
- No equipment sets created: Show "No Set", disable dropdown
- Set deleted while equipped: Update on EQUIPMENT_SETS_CHANGED
- Partial equipment: Still show set name, indicate missing items in dropdown

### 7. Testing Checklist

- [ ] Addon loads without errors
- [ ] Shows "No Set" with ? icon when unequipped
- [ ] Shows correct set name and icon when equipped
- [ ] Left-click opens Character frame
- [ ] Left-click navigates to Equipment Manager tab
- [ ] Right-click opens dropdown with all sets
- [ ] Missing items show red text in dropdown
- [ ] Equipped set has checkmark in dropdown
- [ ] Clicking set in dropdown equips it
- [ ] Display updates when equipment changes
- [ ] Display updates when sets are created/deleted

## Build Commands

```bash
# Initial setup
git init
git submodule add https://github.com/tekkub/libdatabroker-1-1.git Libs/LibDataBroker-1.1
git submodule update --init --recursive

# Development cycle
git add .
git commit -m "Description of changes"

# Package for distribution
# Exclude: .git/, PLAN.md, .gitmodules (optional)
# Include: .toc, .lua, Libs/
```

## Future Enhancements (Optional)

- Tooltip showing set details on hover
- Middle-click to unequip all sets
- Color-coded broker text (green for complete, red for incomplete)
- Option to show item count "SetName (14/16)"
- Support for Classic WoW versions (if needed)

---

## Implementation Status

- [ ] Git repository initialized
- [ ] LibDataBroker submodule added
- [ ] Broker_Equipment.toc created
- [ ] Broker_Equipment.lua implemented
- [ ] Testing completed
