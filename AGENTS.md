# AGENTS.md - Broker_Equipment WoW Addon

## Project Overview
World of Warcraft addon creating a LibDataBroker plugin for Equipment Manager sets.
Written in Lua 5.1 (WoW's Lua), targeting Retail WoW Interface 120001.

## Build/Development Commands

Since this is a WoW addon with no build system:

```bash
# Setup
git submodule update --init --recursive

# Development workflow
git add .
git commit -m "Description"

# No tests, linting, or type checking configured
```

## Testing

Testing is done manually in-game:
1. Install addon to WoW AddOns folder
2. Log in and verify broker displays correctly
3. Test left-click opens Character Equipment tab
4. Test right-click shows equipment set dropdown

See PLAN.md for manual testing checklist.

## Code Style Guidelines

### Indentation
- Use tabs (not spaces)
- Tab size: 4 spaces visually in editor

### Naming Conventions
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `DEFAULT_ICON`)
- **Global functions**: `PascalCase` with addon prefix (e.g., `BrokerEquipment_OpenCharacterFrame`)
- **Local functions**: `camelCase` (e.g., `getCurrentEquipmentSet`)
- **Variables**: `camelCase` for locals, descriptive names
- **Events**: Use WoW event names exactly as documented

### Lua Patterns
- Use `local ADDON_NAME, ns = ...` at file start
- Prefer `local` for all variables (avoid globals)
- Use `ipairs()` for array iteration
- Check for nil returns from WoW APIs before using

### Imports/Requires
- LibStub for library access: `local ldb = LibStub("LibDataBroker-1.1")`
- No require() - WoW loads files via .toc order

### String Formatting
- Use `..` for concatenation
- Escape backslashes in paths: `"Interface\\Icons\\IconName"`
- Use color codes: `"|cFFFF0000" .. text .. "|r"` for red text

### Comments
- Use `--` for single-line comments
- Use `--[[ ... ]]` for multi-line
- Document API compatibility notes (Retail vs Classic)

### Functions
- Keep functions small and focused
- Return early on error conditions
- Document WoW API quirks in comments

### Error Handling
- Check nil returns from `C_EquipmentSet` APIs
- Provide sensible defaults (e.g., "No Set")
- Don't error() - WoW errors break the UI

## Project Structure
```
Broker_Equipment/
├── Broker_Equipment.toc    # Addon metadata
├── Broker_Equipment.lua    # Main addon logic
├── PLAN.md                 # Implementation plan
└── Libs/
    └── LibDataBroker-1.1/  # Git submodule
```

## WoW API Reference
Key APIs used:
- `C_EquipmentSet.GetEquipmentSetIDs()`
- `C_EquipmentSet.GetEquipmentSetInfo(setID)`
- `C_EquipmentSet.UseEquipmentSet(setID)`
- `LibStub("LibDataBroker-1.1")`
- `CreateFrame()`, `UIDropDownMenu_*`

## Events Handled
- `PLAYER_LOGIN` - Initialize addon
- `EQUIPMENT_SETS_CHANGED` - Sets modified
- `PLAYER_EQUIPMENT_CHANGED` - Equipment slot changed
- `EQUIPMENT_SWAP_FINISHED` - Swap completed

## Git Workflow
- Commit messages: Brief, present tense (e.g., "Fix dropdown positioning")
- Submodule: LibDataBroker-1.1 from tekkub/libdatabroker-1-1
