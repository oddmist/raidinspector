# Teräs Raid Inspector

A World of Warcraft TBC Classic addon that inspects all raid and party members for missing or incorrect enchants and gems. Built for raid leaders and officers who want to ensure their group is properly prepared before pulling.

![Interface: 20504](https://img.shields.io/badge/Interface-20504-blue) ![WoW Version: TBC Classic Anniversary](https://img.shields.io/badge/WoW-TBC%20Classic%20Anniversary-yellow)

## Features

- **Full raid scanning** — Inspects all group members' gear, enchants, and gems via a throttled queue that avoids server disconnects
- **Best-in-Slot enchant database** — Recommendations for all 9 classes and 27 spec combinations, covering head arcanums, shoulder inscriptions, leg armors, weapon enchants, and more
- **Sweat Mode** — Toggle a stricter enchant validation mode that only accepts ultimate BiS enchants (e.g., only +20 Spell Damage on caster gloves, not Blasting)
- **Gem validation** — Detects empty sockets and low quality (green) gems
- **Whisper and announce** — Send gear issues directly to individual players or post a summary to raid/party chat
- **Enchant override editor** — Customize recommendations per class/spec/slot through an in-game editor
- **Import/Export** — Share enchant override configurations with other officers via copy-paste strings
- **Per-player detail panel** — Click any player to see a slot-by-slot breakdown with item tooltips, actual vs recommended enchants, and gem socket status
- **Spec detection** — Automatically detects each player's active talent specialization, including dual spec support

## Installation

1. Download or clone this repository
2. Copy the `RaidInspector` folder into your WoW addons directory:
   ```
   World of Warcraft/_classic_/Interface/AddOns/RaidInspector/
   ```
3. Restart WoW or type `/reload` if already in-game

## Usage

### Slash Commands

| Command | Description |
|---------|-------------|
| `/ri` | Toggle the main window |
| `/ri scan` | Start scanning all group members |
| `/ri stop` | Stop an in-progress scan |
| `/ri reset` | Clear all data and start a fresh scan |
| `/ri show <name>` | Open the detail panel for a specific player |
| `/ri target` | Inspect your current target |
| `/ri whisper` | Whisper all players who have gear issues |
| `/ri whisper <name>` | Whisper a specific player about their issues |
| `/ri announce` | Post gear check results to raid/party chat |
| `/ri editor` | Toggle the enchant override editor |
| `/ri debugspec` | Toggle spec detection debug output |

### Main Window

The main window shows a scrollable list of all scanned players, sorted by issue severity:

- **Red** — Missing enchants on required slots
- **Orange** — Wrong enchants (not in the recommended list for their spec)
- **Yellow** — Missing gems or low quality gems
- **Green** — All enchants and gems look good
- **Gray** — Unscanned, offline, or timed out

**Buttons:**
- **Whisper** — Send individual whisper messages to all players with issues
- **Announce** — Post a summary to raid or party chat (shows confirmation dialog)
- **Reset** — Clear all scan data and rescan
- **Editor** — Open the enchant override editor
- **Scan / Stop** — Start or stop scanning
- **Sweat Mode** — Toggle strict BiS-only enchant validation
- **Issues Only** — Filter the list to show only players with problems

Click any player row to open their detail panel.

### Detail Panel

Shows a slot-by-slot breakdown for one player:

- **Slot** — Equipment slot name
- **Item** — Item name colored by quality (hover for tooltip)
- **Actual** — The enchant currently on the item (green = good, red = missing, orange = wrong)
- **Recommended** — What enchants are considered acceptable for their class/spec
- **Gems** — Socket status with colored indicators

Right-clicking a "wrong" enchant offers to add it to the recommended list as a custom override.

### Enchant Override Editor

Customize which enchants are considered acceptable:

1. Open with `/ri editor` or the Editor button
2. Select a class and spec from the dropdowns
3. Each row shows the default recommendation and any custom overrides
4. Use **[+]** to add an enchant by its effect ID
5. Use **[-]** to remove a custom override
6. Use **Import/Export** to share configurations with other officers

### Sweat Mode

When enabled, Sweat Mode applies a stricter set of enchant recommendations — only the absolute best enchants for each slot are accepted. This is useful for progression raiding where every stat point matters.

Key differences from normal mode:
- **Shoulders**: Only Greater (Exalted) inscriptions, no Lesser or Naxxramas alternatives
- **Legs**: Only the best leg armor/spellthread variant
- **Gloves**: Casters must have +20 Spell Damage (Blasting and Spell Strike are flagged)
- **Weapon**: School-specific enchants enforced per spec (Sunfire for fire mages, Soulfrost for warlocks, etc.)
- **Tanks**: Both threat and avoidance/EHP gear sets are recognized (e.g., Arcanum of Ferocity for threat set, Protector for avoidance set)

## Enchant Database Coverage

The addon ships with recommendations for every class and spec combination in TBC:

| Class | Specs |
|-------|-------|
| Warrior | Arms, Fury, Protection |
| Paladin | Holy, Protection, Retribution |
| Hunter | Beast Mastery, Marksmanship, Survival |
| Rogue | Assassination, Combat, Subtlety |
| Priest | Discipline, Holy, Shadow |
| Shaman | Elemental, Enhancement, Restoration |
| Mage | Arcane, Fire, Frost |
| Warlock | Affliction, Demonology, Destruction |
| Druid | Balance, Feral Combat, Restoration |

Enchant slots covered: Head, Shoulders, Chest, Legs, Feet, Wrists, Hands, Back, Main Hand, Off Hand (weapons/shields), and Ranged (hunter scopes).

## How It Works

1. **Scanning**: Uses WoW's `NotifyInspect` API with a 1.2-second throttle between requests to avoid server issues. Each inspection has a 3-second timeout before moving to the next player.

2. **Enchant detection**: Parses the enchant effect ID from each item's link (`|Hitem:itemID:enchantID:...|h`). These are SpellItemEnchantment IDs, not spell IDs.

3. **Gem detection**: Reads item tooltips via a hidden scanning tooltip to count socket lines. Checks gem quality to flag green-quality gems as low quality.

4. **Spec detection**: Reads the inspected player's talent point distribution to determine their active specialization. Supports dual spec via `GetActiveSpecGroup`.

5. **Evaluation**: Compares each player's actual enchants against the recommendation database for their class/spec. User overrides are merged with the built-in data.

## SavedVariables

All data is stored in `RaidInspectorDB`:

- **Player scan data** — Cached between sessions (cleared on reset)
- **Enchant overrides** — Custom recommendations persist across sessions
- **Sweat mode toggle** — Remembered between sessions

## License

MIT

## Author

Oddmist — [Teräs](https://www.terasguild.com) guild, TBC Classic Anniversary
