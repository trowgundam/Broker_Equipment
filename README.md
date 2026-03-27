# Broker Equipment

A World of Warcraft addon that creates a [LibDataBroker](https://github.com/tekkub/libdatabroker-1-1) (LDB) plugin for displaying and managing Equipment Manager sets.

## ⚠️ Disclaimer

**This addon was "vibe coded" - it was created with minimal effort using AI assistance.**

- I provide **zero guarantees** that this addon works correctly or won't break your game
- If you encounter issues, feel free to use an AI to fix it yourself (that's the beauty of modern development!)
- This was originally created for **personal use only** - you're welcome to use it, but don't expect enterprise-level support or quality

## Features

- Displays your currently equipped Equipment Manager set in your LDB display (e.g., Titan Panel, ChocolateBar, Bazooka)
- Shows set icon and name
- **Left-click**: Opens the Character Equipment Manager tab
- **Right-click**: Opens a dropdown menu to select and equip any available set
- **Tooltip**: Shows all available sets with status indicators:
  - Green: Currently equipped
  - Red: Has missing/unavailable items (with count)
  - White: Available to equip

## Requirements

- World of Warcraft Retail (Midnight / Interface 120001+)
- An LDB display addon (e.g., Titan Panel, ChocolateBar, Bazooka, Fortress)

## Installation

1. Download or clone this repository
2. Copy the `Broker_Equipment` folder to your WoW AddOns directory:
   - Windows: `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\`
   - Mac: `~/Library/Application Support/Blizzard/World of Warcraft/_retail_/Interface/AddOns/`
3. Restart WoW or reload UI (`/reload`)
4. Enable the addon in the character select screen or in-game addons list

## Development Setup

```bash
# Clone with submodules
git clone --recursive <repo-url>
cd Broker_Equipment

# Or initialize submodules after clone
git submodule update --init --recursive
```

## Usage

Once installed and enabled:

1. The addon will automatically display your current equipment set in your LDB bar
2. If no set is equipped, it shows "No Set" with a question mark icon
3. **Left-click** the broker to open Character frame with Equipment Manager tab
4. **Right-click** the broker to see a dropdown of all your equipment sets
5. Select a set from the dropdown to equip it

## How It Works

The addon uses WoW's native `C_EquipmentSet` API to:
- Query all equipment sets
- Check which set is currently equipped
- Handle equipment swaps
- Display missing item status

## Limitations

- Only supports Retail WoW (Classic versions may or may not work)
- Requires Equipment Manager sets (in-game feature)
- No configuration options (kept simple by design)

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Support

This is a personal project with no formal support. If you find issues:
1. Try fixing it yourself (AI tools are great for this!)
2. Fork and modify as needed
3. Don't open issues expecting fixes - this is vibe code territory

---

*Remember: in the age of AI, every bug is just an opportunity to vibe code a fix!*
