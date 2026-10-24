# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A CS2 (Counter-Strike 2) config repository tuned for official matchmaking: keybinds, buy scripts, network/audio/HUD settings, and null-bind movement. There is no build or test tooling; everything is Source 2 `.cfg` script.

## Key Files and Structure

- **`autoexec.cfg`**: Main config. Holds all binds, aliases, buy scripts, crosshair/viewmodel, radar/HUD, sound, network and damage-prediction settings. At the end it runs `exec movement/setup` and `exec guide/guide`, then `host_writeconfig`.
- **`movement/setup.cfg`**: Binds W/A/S/D to `+w/+a/+s/+d` and runs `movement/nulls`.
- **`movement/nulls.cfg`**: Null-bind (snap-tap style) aliases built on the analog `forwardback` / `rightleft` commands, so the last-pressed opposite key wins.
- **`video/apply-video-settings.ps1`**: Applies the README video preset by editing only the quality keys in each account's `Steam\userdata\<id>\730\local\cfg\cs2_video.txt` (backup first, refuses while CS2 runs, `-DryRun` to preview). Video settings can't be set from `autoexec.cfg`.
- **`guide/guide.cfg`**: `echo` table of every bind, printed to the console on load as confirmation.
- **`README.md`**: Public docs (binds, features, install, launch options, video settings).
- **`steam-guide/`**: Text for the Steam Community guide (title, description, body in BBCode).

## Configuration System Architecture

### Script patterns
- **Toggle aliases**: an alias rebinds itself, e.g. `mute-enemy-team_on/off`, `toggle_inspect`.
- **Hold/release**: `+name`/`-name` alias pairs run on press/release, e.g. `+bomb-drop`, `+switchw`, `+incvol`, `+custom_alt`, `+defusezoom`.
- **CAPSLOCK modifier**: `+secondaryaction` rebinds 1–5 and X/F/Z/V to buy aliases (`keyX`, `customBuy1`…); `-secondaryaction` restores the equip binds (`defX`, `def1`…). `-secondaryaction` is also run once on load so the equip binds exist even with an empty saved key file (fresh install).
- **Shared aliases**: when a bind is set both directly and from a `def*` alias, point both at the same named alias (e.g. `knife-inspect` for key 3) so CAPSLOCK release doesn't overwrite it.
- **Nested quotes don't work** in CS2 cfg (`alias x "bind y "z""` breaks). Use a helper alias instead.

### Movement
- Null binds only (`movement/nulls.cfg`). The old `exec_async` / tick-based / `sv_cheats` system and mouse_x-triggered longjump/jumpbug scripts are not part of this repo; don't re-add mouse-triggered movement.
- SPACE is plain `+jump` (CS2 gives a consistent jumpthrow on the way up); mousewheel uses `+myjump`.

## Matchmaking Constraints (2026)

- Only add settings that work in official matchmaking. Skip `sv_cheats`, server-only (`sv_*`, `mp_*`, `bot_*`), debug/visualisation and devonly cvars. Server cvars are fine only when clearly commented as "local/practice only" (e.g. `sv_clockcorrection_msecs`).
- Aug 2024: Valve blocks binds that fire multiple movement/attack inputs from one key press (classic jumpthrow, `+duck;+jump`, null binds using `+left/+right`) and may kick for them on official servers. The `forwardback`/`rightleft` null binds work around this, so treat them as a risk on official servers.
- Legacy CS:GO network cvars (`cl_interp`, `cl_interp_ratio`, `cl_updaterate`, `cl_cmdrate`) don't affect CS2. `cl_net_buffer_ticks` is the current buffering control.
- `rate` max in CS2 is 786432.
- Audio volume sliders aren't linear: the menu % is the square root of the cvar value (`snd_mvp_volume 0.2` shows 45%, `0.1` shows 32%). For a slider value of X%, set the cvar to (X/100)², e.g. 10% = `0.01`.
- Sept 2026 crosshair update: use `cl_crosshair_length`, `cl_crosshair_gap`, `cl_crosshair_thickness`, `cl_crosshaircolor_a` (pixel values). `cl_crosshaircolor`, `cl_crosshairgap` and `cl_crosshair_outlinethickness` are gone; `cl_crosshairsize/thickness/alpha` are leftovers.
- Confirmed "Unknown command" in build 10955: `cl_autowepswitch`, `cl_playerspraydisable`, `cl_join_advertise`. `cl_interp` is locked. Check new cvars against an in-game `exec autoexec` log before keeping them.
- Research cvars against 2025–2026 sources (Valve patch notes, the Valve wiki cvar list, prosettings.net, csdb.gg) before adding them; many "pro" tips online are placebo or locked.

## Common Development Tasks

1. **Testing changes**: copy files to `...\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg\`, then in the CS2 console run `exec autoexec`. Check a bind with `bind <key>`, and a cvar by typing its name.
2. **Adding binds**: add to `autoexec.cfg`, following the existing comment-header style (`// Title` + one-line description). Check the key isn't already bound (including inside `def*`/`key*` aliases).
3. **Keep docs in sync**: when binds change, update `README.md`, `guide/guide.cfg` and `steam-guide/steam_guide.txt` too.
4. **Buy scripts**: `,` CT loadout, `.` T loadout, `/` AWP, `M` vest+deagle; CAPSLOCK + 1–5 / X/F/Z/V for quick buys.

## Configuration Dependencies

- Launch options (see `README.md`) must include `+exec autoexec.cfg`.
- A fresh CS2 install resets the saved key file (`cs2_user_keys_0_slot0.vcfg`), so anything not bound directly in `autoexec.cfg` on load will be missing.
- Sensitivity is set for 1600 DPI.
