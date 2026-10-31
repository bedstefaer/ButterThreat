# AGENTS.md

World of Warcraft addon (RPGThreat / ButterThreat) written in Lua 5.1. It turns threat-state changes on the player's target into sounds, a screen vignette, and `/emote` messages.

## Layout
- `RPGThreat.lua` – entire addon (config, throttling, event handling, slash commands `/rpgthreat`, `/rt`).
- `RPGThreat.toc` – addon manifest (interface version, file list). Any new `.lua` file must be listed here and copied in the "Create release package" step of `.github/workflows/package-release.yml` (it ships only the `.toc`, `.lua` and `Sounds/*.ogg` files).
- `Sounds/` – `.ogg` assets referenced by `CONFIG.SOUNDS` (`heartbeat`, `warning`, `aggro`).
- `tests/` – dependency-free unit tests; `tests/wow_mock.lua` mocks the WoW API and loads `RPGThreat.lua`.
- `.github/workflows/ci.yml` – lint + tests; `package-release.yml` – release zip on `v*` tags.

## Commands
- `make check` – lint and test (what CI runs).
- `make lint` – `luacheck RPGThreat.lua tests` (config in `.luacheckrc`).
- `make test` – `lua tests/run.lua`, run from the repo root (the mock loads `RPGThreat.lua` by relative path).
- Requires Lua 5.1 and `luacheck` (`luarocks install luacheck`).

## Conventions
- Target the WoW Lua 5.1 API only; no external libraries. Declare any new WoW API global in `.luacheckrc` `read_globals`.
- Keep addon logic in local functions/variables; the only intended globals are the slash-command ones.
- Threat states are integers 0–3 (safe, tension, losing control, aggro) as returned by `UnitThreatSituation`.
- `UnitClass` returns the localized name first; use the second return (class token, e.g. `"WARRIOR"`) as the key into `CONFIG.CLASS_EMOTES`.
- Unit tests cover critical logic only: state transitions, throttling, clamping, emote/sound selection, reset behavior. Add a test when changing these. Don't test UI/texture rendering details.
- Update `README.md`/`QUICKSTART.md` when user-visible behavior or commands change.
