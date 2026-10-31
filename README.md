# RPGThreat - Immersive Threat Tracking for World of Warcraft

## Overview

RPGThreat is a lightweight, custom addon that replaces traditional threat percentage bars and numerical displays with immersive, atmospheric feedback. It translates threat changes into:

- **Custom Audio Cues** - Heartbeat, warning, and aggro sounds
- **Fullscreen Vignettes** - Subtle orange borders for tension, heavy red for aggro
- **Character Emotes** - Class-specific roleplay messages in chat

## Features

### Threat Tiers

- **Status 0 (Safe)**: All visual cues hidden, no audio
- **Status 1 (Tension)**: Heartbeat sound + subtle orange border vignette
- **Status 2 (Losing Control)**: Warning sound + heavy red vignette + emote
- **Status 3 (Aggro)**: Aggro sound + heavy red vignette + emote

### Anti-Spam System

- Emote throttle: 2 seconds between chat messages
- Audio throttle: 0.5 seconds between sound effects
- Only triggers on actual state changes (not repeated updates)

### Class-Specific Behavior

Each class has unique emote responses:
- **Warrior**: Roars and battle cries
- **Rogue**: Stealthy reactions and panic
- **Mage**: Arcane incantations and spell focus
- **Hunter**: Pet signaling and warning shots
- **Others**: Default generic messages

### Target Filtering (Optional)

By default, processes all targets. To enable boss/elite-only filtering, uncomment the line in `ShouldProcessThreat()` function.

## Installation

1. Place the `RPGThreat` folder in `World of Warcraft/_retail_/Interface/AddOns/`
2. Create a `Sounds` subdirectory inside the addon folder
3. Add your audio files:
   - `heartbeat.ogg` - For tension/state 1
   - `warning.ogg` - For losing control/state 2
   - `aggro.ogg` - For aggro/state 3
4. Launch WoW (clean launch required for asset indexing)
5. Enable the addon in the AddOns menu

## Usage

### Slash Commands

- `/rpgthreat` or `/rt` - Show addon version and commands
- `/rpgthreat test` - Cycle through all threat states for testing
- `/rpgthreat reset` - Reset threat state

## File Structure

```
RPGThreat/
├── RPGThreat.toc    # Addon manifest
├── RPGThreat.lua    # Main logic
├── Sounds/          # Audio assets
│   ├── heartbeat.ogg
│   ├── warning.ogg
│   └── aggro.ogg
└── README.md        # This file
```

## Technical Details

### Event Hooks

- `PLAYER_TARGET_CHANGED` - Triggers when player changes target
- `UNIT_THREAT_LIST_UPDATE` - Triggers when threat list updates
- `PLAYER_LOGIN` - Initializes the addon

### API Functions Used

- `UnitThreatSituation("player", "target")` - Returns threat tier (0-3)
- `UnitClass("player")` - Returns player class for class-specific behavior
- `UnitClassification("target")` - Returns target classification (for filtering)
- `UnitName("target")` - Returns target name for emotes
- `PlaySoundFile(path, "Master")` - Plays custom audio files
- `SendChatMessage(text, "EMOTE")` - Broadcasts emote to local chat

### Frame Strata

- Vignette uses `BACKGROUND` strata to ensure it doesn't block UI interactions

## Configuration

Edit the `CONFIG` table in `RPGThreat.lua` to customize:

- `EMOTE_THROTTLE_SECONDS` - Time between emotes
- `AUDIO_THROTTLE_SECONDS` - Time between sounds
- `CLASS_EMOTES` - Add/Modify class-specific emote messages
- `SOUNDS` - Change audio file paths

## Future Enhancements

- [ ] Config UI for throttle timing
- [ ] More class-specific emotes
- [ ] Visual customization options
- [ ] Per-target settings
- [ ] Raid/party threat awareness

## Notes

- Audio files must use escaped double backslashes (`\\`) in paths
- Asset directories require a **clean client restart** for WoW to index them
- Lua changes only require `/reload` in-game
- Use `.ogg` format for best compatibility
