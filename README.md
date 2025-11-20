# Mobile RPG Demo MVP

A **mobile-friendly 2D top-down RPG demo** built with **Godot 4** and **GDScript**. This MVP demonstrates a complete RPG slice with clean architecture, designed to run on both desktop and Android devices.

---

## Features

### Core Systems
- ✅ **Player Movement** - 8-direction movement with keyboard and virtual joystick support
- ✅ **Combat System** - Action combat with melee attacks
- ✅ **Enemy AI** - Slime enemies with chase and attack behaviors
- ✅ **NPC Dialogue** - Interactive dialogue system with multiple NPCs
- ✅ **Quest System** - Track and complete quests with rewards
- ✅ **Inventory System** - Collect items and use consumables
- ✅ **Save/Load System** - JSON-based save system with auto-save
- ✅ **Mobile Controls** - Virtual joystick and on-screen action buttons
- ✅ **UI Systems** - HUD, quest log, inventory, and dialogue displays

### Game Content
- **2 Areas**: Field (outdoor) and House (indoor)
- **3+ NPCs**: Village Elder (quest giver), Villager, Mysterious Figure
- **Enemies**: Slimes with loot drops
- **Quest**: "Slime Hunter" - Defeat 3 slimes for rewards
- **Items**: Health potions, slime goo, quest rewards

---

## Project Structure

```
simulator-game/
├── project.godot             # Godot project configuration
├── README.md                 # This file
│
├── scenes/                   # All scene files (.tscn)
│   ├── main_menu.tscn       # Main menu with New Game / Continue
│   ├── player/
│   │   └── player.tscn      # Player character
│   ├── npc/
│   │   └── npc.tscn         # Generic NPC
│   ├── enemy/
│   │   └── slime.tscn       # Slime enemy
│   ├── world/
│   │   ├── field.tscn       # Outdoor field area
│   │   ├── house.tscn       # Indoor house area
│   │   └── portal.tscn      # Scene transition portal
│   └── ui/
│       ├── hud.tscn         # HP/XP/Gold display
│       ├── mobile_controls.tscn
│       ├── dialogue_box.tscn
│       ├── quest_log.tscn
│       └── inventory_ui.tscn
│
├── scripts/                  # All GDScript files (.gd)
│   ├── autoload/            # Singleton autoload scripts
│   │   ├── game_manager.gd  # Central game state
│   │   ├── save_manager.gd  # Save/load system
│   │   └── dialogue_manager.gd
│   ├── player/
│   │   └── player.gd
│   ├── npc/
│   │   └── npc.gd
│   ├── enemy/
│   │   ├── enemy.gd         # Base enemy class
│   │   └── slime.gd         # Slime-specific
│   ├── world/
│   │   └── portal.gd
│   └── ui/
│       ├── hud.gd
│       ├── mobile_controls.gd
│       ├── dialogue_box.gd
│       ├── quest_log.gd
│       ├── inventory_ui.gd
│       └── main_menu.gd
│
└── data/                     # Data-driven definitions
    ├── items/
    │   └── item_definitions.gd
    ├── quests/
    │   └── quest_definitions.gd
    └── dialogues/
        └── npc_dialogues.gd
```

---

## Getting Started

### Prerequisites
- **Godot 4.x** (tested with Godot 4.3)
- For Android: Android SDK and export templates

### Opening the Project

1. **Download/Clone** this repository
2. **Open Godot 4**
3. Click **Import**
4. Navigate to this folder and select `project.godot`
5. Click **Import & Edit**

### Running in Editor

1. Press **F5** or click the **Play** button in the top-right
2. The game will start at the main menu
3. Select **"NEW GAME"** to begin

### Controls

#### Desktop (Keyboard)
- **WASD** or **Arrow Keys** - Move
- **Space** - Attack
- **E** - Interact / Talk / Continue dialogue
- **I** or **Escape** - Open quest log / menu

#### Mobile (Touch)
- **Virtual Joystick** (bottom-left) - Move
- **ATTACK** button (bottom-right) - Attack enemies
- **INTERACT** button (bottom-right) - Talk to NPCs
- **MENU** button (bottom-right) - Open quest log

---

## Gameplay Guide

### Starting the Game

1. **Main Menu** → Select "NEW GAME"
2. You spawn in the **Field** area
3. HUD shows your HP, Level, XP, and Gold

### Quest Walkthrough

1. **Talk to the Elder** (yellow NPC near the top)
   - Press **E** (or tap INTERACT)
   - He will give you the "Slime Hunter" quest

2. **Defeat 3 Slimes**
   - Slimes (green blobs) patrol the field
   - Approach and press **Space** (or tap ATTACK)
   - They will chase you and attack back!
   - Quest progress shown in quest log (press **I**)

3. **Return to Elder**
   - Once 3 slimes defeated, talk to Elder again
   - Receive rewards: XP, Gold, Items

4. **Explore the House**
   - Walk to the **purple portal** near the top-right
   - You'll teleport to the House
   - Talk to the Mysterious Figure
   - Use the portal inside to return to Field

### Inventory

- Press **I** → Opens Quest Log (or Inventory in full version)
- Use **Health Potions** to restore HP
- Slimes drop **Slime Goo** and **Gold Coins**

### Save/Load

- Game **auto-saves** when transitioning between areas
- Manual save: Return to main menu, progress is saved
- **Continue** button on main menu loads your last save

---

## Architecture Highlights

### Signal-Based Communication
- `GameManager` emits signals when stats change
- UI layers listen and update automatically
- Decouples game logic from UI

### Autoload Singletons
- `GameManager` - Centralized game state
- `SaveManager` - Save/load operations
- `DialogueManager` - Dialogue orchestration

### Data-Driven Design
- Items, quests, and dialogues defined in data files
- Easy to add new content without code changes
- See `data/items/item_definitions.gd` for examples

### Clean Separation
- **Scripts** separated by functionality (player, enemy, ui, etc.)
- **Scenes** modular and reusable
- **Data** externalized for easy modification

---

## Mobile Export (Android)

### Prerequisites
1. Install **Android Build Templates** in Godot
2. Set up **Android SDK** path in Editor Settings
3. Download **Godot export templates** for your version

### Export Steps

1. **Project** → **Export**
2. Add **Android** preset
3. Configure:
   - **Package Name**: `com.yourname.rpgdemo`
   - **Min SDK**: 21
   - **Target SDK**: 33
4. **Export Project** → Select output `.apk` location
5. Install APK on Android device or emulator

### Mobile Testing
- **Android Emulator** recommended for testing
- Virtual controls automatically visible
- Portrait mode: 1080x1920 resolution

---

## Extending the Game

### Adding New Items

Edit `data/items/item_definitions.gd`:

```gdscript
"new_item": {
    "id": "new_item",
    "name": "New Item",
    "description": "Does something cool",
    "type": "consumable",
    "heal_amount": 50,
    "stackable": true
}
```

### Adding New Quests

Edit `data/quests/quest_definitions.gd`:

```gdscript
"new_quest": {
    "id": "new_quest",
    "title": "Quest Title",
    "objectives": [
        {"key": "enemies_killed", "target": 5, "type": "kill"}
    ],
    "rewards": {"xp": 150, "gold": 75, "items": ["new_item"]}
}
```

### Adding New Enemies

1. Duplicate `scenes/enemy/slime.tscn`
2. Create new script extending `enemy.gd`
3. Customize stats in `_ready()`:

```gdscript
func _ready() -> void:
    super._ready()
    max_health = 50
    damage = 15
    enemy_type = "goblin"
```

### Creating New Areas

1. Duplicate `scenes/world/field.tscn`
2. Modify terrain, walls, NPCs, enemies
3. Add **Portal** nodes with:
   - `target_scene`: Path to destination scene
   - `spawn_position`: Where player appears

---

## Known Limitations (MVP Scope)

- **Placeholder Graphics**: Using colored squares/circles
- **No Equipment System**: Items are consumables only
- **Limited Quests**: Only kill-type quests implemented
- **No Sound/Music**: Silent gameplay
- **Simple AI**: Enemies have basic chase/attack behavior
- **No Minimap**: Navigation is visual only

---

## Performance Optimization

The game is optimized for mobile:
- **Mobile rendering** mode in project settings
- **Simple 2D graphics** (low GPU usage)
- **Efficient collision detection** using layers
- **Minimal particle effects** (none in MVP)

---

## Troubleshooting

### Game won't run
- Ensure you're using **Godot 4.x** (not 3.x)
- Check console for missing resource errors

### Virtual joystick not working
- Touch input requires **actual touch device** or emulator
- Desktop testing: use keyboard controls

### Save file not loading
- Check `user://` directory (varies by platform)
- Delete `savegame.json` to reset

### Enemies not spawning
- Check `scenes/world/field.tscn` - ensure Slime nodes exist
- Verify collision layers (Enemy = layer 4, Player = layer 2)

---

## Development Roadmap (Post-MVP)

Future enhancements:
- **Graphics**: Custom sprites and tilesets
- **Sound**: Background music and SFX
- **More Content**: Additional areas, quests, NPCs, enemies
- **Equipment System**: Weapons and armor with stats
- **Skills/Magic**: Special abilities
- **Shop System**: Buy/sell items with gold
- **Boss Battles**: Unique challenging enemies
- **Achievements**: Track player progress

---

## Technical Details

- **Engine**: Godot 4.3
- **Language**: GDScript
- **Target Platforms**: Desktop (Windows/Mac/Linux), Android
- **Resolution**: 1080x1920 (mobile portrait)
- **Physics**: 2D rigid body and kinematic
- **Save Format**: JSON in user data directory

---

## Credits

Built with Godot Engine (https://godotengine.org)

---

## License

This is a demo project. Feel free to use, modify, and extend for your own projects.

---

## Support

For issues or questions:
1. Check **Godot Documentation**: https://docs.godotengine.org
2. Review code comments in scripts
3. Test in Godot editor's debugger

---

**Have fun exploring and extending this RPG demo!** 🎮
