# Halloween - Minetest Disguise Mod

A Minetest mod that allows players to disguise themselves as mobs and entities with dynamic abilities. Features comprehensive admin controls, per-disguise permissions, and mob-specific powers.

## Features

- **Dynamic Disguises**: Transform into any registered mob or entity
- **Admin Controls**: Global on/off switch and per-disguise permissions
- **Mob Powers**: Gain special abilities based on your disguise (fireball shooting, speed, etc.)
- **Compatible**: Works alongside skinsdb and 3d_armor using overlay entities
- **Extensible**: Easy-to-use API for other mods

## Installation

1. Clone or download this repository
2. Place the `halloween` folder in your Minetest `mods` directory
3. Enable the mod in your world settings

## File Structure

```
halloween/
├── mod.conf          # Mod metadata (already created)
├── init.lua          # Entry point (already created)
├── api.lua           # Core API and overlay entity
├── registry.lua      # Builds disguise list from mobs/entities
├── storage.lua       # Persistent storage for settings
├── effects.lua       # Mob-specific special abilities
├── commands.lua      # Chat commands and privileges
└── README.md         # This file
```

## Commands

### Player Commands
- `/halloween_list [filter]` - List available disguises
- `/halloween_disguise <id>` - Disguise as a mob/entity
- `/halloween_clear` - Remove your current disguise

### Admin Commands (require `halloween_admin` privilege)
- `/halloween_toggle on|off` - Enable/disable all disguises globally
- `/halloween_allow <id>` - Enable a specific disguise
- `/halloween_block <id>` - Disable a specific disguise

## API Usage

```lua
-- Set a player's disguise
halloween.set_disguise(player, "mobs_monster:stone_monster")

-- Clear a player's disguise  
halloween.clear_disguise(player)

-- Check if Halloween mode is enabled
if halloween.is_enabled() then
    -- do something
end

-- Register a custom effect for a disguise
halloween.effects["mobs_monster:land_guard"] = function(player, dtime)
    -- Custom ability code here
end
```

## TODO: Remaining Files

The following files need to be created. See the issues/wiki for complete code:

1. **api.lua** - Core disguise system
2. **registry.lua** - Auto-discovery of mobs/entities  
3. **storage.lua** - Settings persistence
4. **effects.lua** - Special mob abilities
5. **commands.lua** - Chat commands

## Dependencies

- **Optional**: `mobs` (Mobs Redo) - for mob disguises
- **Optional**: `default` - for fallback player model

## License

MIT License - see LICENSE file

## Credits

Created for the Minetest community with inspiration from entity_modifier and similar mods.
