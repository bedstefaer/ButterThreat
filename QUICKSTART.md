# Quick Start - RPGThreat

## 1. Install the Addon

### Option A: Manual Install (Development)
```
Copy the RPGThreat folder to:
World of Warcraft/_retail_/Interface/AddOns/
```

### Option B: Download Release (When Available)
1. Go to GitHub Releases
2. Download the latest `.zip` file
3. Extract to your AddOns folder

## 2. Add Sound Files

Place these files in `RPGThreat/Sounds/`:
- `heartbeat.ogg` - Plays when threat is rising (Status 1)
- `warning.ogg` - Plays when losing control (Status 2)
- `aggro.ogg` - Plays when you pull aggro (Status 3)

## 3. Launch WoW

**Important**: Do a **clean launch** (fully exit WoW, then restart) so the client indexes the sound files.

## 4. Enable Addon

In-game: Open AddOns menu and enable **RPGThreat**.

## 5. Test It

Type `/rpgthreat test` to cycle through all threat states.

## 6. Slash Commands

- `/rpgthreat` or `/rt` - Show help
- `/rpgthreat test` - Test all threat states
- `/rpgthreat reset` - Reset state

## 7. Customize (Optional)

Edit `RPGThreat.lua` to:
- Change throttle timings in the `CONFIG` table
- Add more class-specific emotes
- Enable boss/elite-only filtering (uncomment in `ShouldProcessThreat`)

After changes: Type `/reload` in-game.
