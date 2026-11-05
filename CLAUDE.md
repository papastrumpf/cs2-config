# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A CS2 (Counter-Strike 2) config repository tuned for official matchmaking: keybinds, buy scripts, network/audio/HUD settings, and null-bind movement. There is no build or test tooling; everything is Source 2 `.cfg` script.

## Key Files and Structure

- **`autoexec.cfg`**: Main config. Holds all binds, aliases, buy scripts, crosshair/viewmodel, radar/HUD, sound, network and damage-prediction settings. At the end it runs `exec movement/setup` and `exec guide/guide`, then `host_writeconfig`.
- **`movement/setup.cfg`**: Binds W/A/S/D to `+w/+a/+s/+d` and runs `movement/nulls`.
- **`movement/nulls.cfg`**: Null-bind (snap-tap style) aliases built on the analog `forwardback` / `rightleft` commands, so the last-pressed opposite key wins.
- **`video/apply-video-settings.ps1`**: Applies the `docs/video-settings.md` preset by editing only the quality keys in each account's `Steam\userdata\<id>\730\local\cfg\cs2_video.txt` (backup first, refuses while CS2 runs, `-DryRun` to preview). Video settings can't be set from `autoexec.cfg`.
- **`fonts/apply-font.ps1`** + `fonts/BarlowSemiCondensed-*.ttf` (OFL): copies the font into `game\csgo\panorama\fonts` and adds a marked block to `fonts.conf` (`<fontpattern>` + `<match>` rules that prepend Barlow for `Stratum2`/`notosans`). Backs up `fonts.conf.original`, `-Restore`, `-DryRun`. CS2's `fonts.conf` only loads files matching a `<fontpattern>`, and Stratum2 is a `.uifont`, so renaming a TTF doesn't work.
- **`docs/monitor-acer-kg251q-240hz.md`**: OSD + NVIDIA settings for the Acer KG251Q 240 Hz (KG251QDbmiipx), from its manual. FreeSync on forces Over Drive to Normal; 240 Hz needs DP or HDMI 2. OSD settings can't be scripted, it's a manual guide.
- **`nvidia/cs2-nvidia-profile.nip`**: NVIDIA Profile Inspector export for the driver's `Counter-strike 2` profile. Values are decimal (NPI parses Dword with `uint.Parse`). Keep `<ProfileName>Counter-strike 2</ProfileName>` and `<string>cs2.exe</string>`: a non-merge import resets the profile and drops any app not listed in the file. Latency and texture filtering settings are listed explicitly even at default values so one import restores everything after a reinstall. IDs that are easy to mix up: `0x10835000` (277041152) = Ultra Low Latency - Enabled and `0x0005F543` = its NVCP state; driver 621.01 rejects both (NVAPI_SETTING_NOT_FOUND), so they're not in the file. `0x10835002` (277041154) = Frame Rate Limiter FPS cap (keep 0). After an import, check the driver actually kept each setting (NVAPI `NvAPI_DRS_GetSetting` on the `Counter-strike 2` profile), since rejected IDs fail silently. Check IDs with `'0x{0:X8}' -f <decimal>` before editing. Download/import steps are in `docs/nvidia-profile.md`.
- **`install.ps1` / `install.bat`**: installer with a menu (1 Full, 2 Config, 3 Video, 4 Config + Video, 5 Font, 6 Windows, 7 Fso; `-Mode` skips the menu, `-DryRun` previews, `-Mode Fso -Fso Checked|Unchecked`). Full = Config + Video + Font + Windows + Fso Checked. Windows runs `apply-windows-input.ps1` then `cs2-priority.ps1`. Config copies `autoexec.cfg`, `movement/`, `guide/` into the CS2 cfg folder (backs up a different `autoexec.cfg`) and puts the launch options on the clipboard; Video/Font/Windows/Fso run the scripts below. Option 7 alone shows the status and asks tick/untick/leave. Only Config/Video/Font need CS2 closed.
- **`windows/apply-windows-input.ps1`**: per-user Windows input settings through `SystemParametersInfo` (applied immediately, no admin): pointer speed 10 (6/11), Enhance pointer precision off (`{0,0,0}`), and the Sticky/Filter/Toggle Keys shortcut bits (`0x4` HOTKEYACTIVE) cleared. The features themselves aren't touched. The first run saves the old values to `%LOCALAPPDATA%\cs2-config\windows-input.original.json` (never overwritten); `-Restore` applies and deletes it, `-DryRun`. Key repeat isn't touched (no effect in game). Also sets HKCU DWORDs (list `$regSettings`): `GameBar\AutoGameModeEnabled`/`AllowAutoGameMode` = 1, `GameConfigStore\GameDVR_Enabled` = 0, `GameDVR\AppCaptureEnabled`/`HistoricalCaptureEnabled` = 0; the backup stores `$null` for "not set" so `-Restore` deletes those again. Do Not Disturb while gaming isn't scripted (stored in an encoded CloudStore blob).
- **`windows/cs2-priority.ps1`**: cs2.exe High CPU priority via `HKLM\...\Image File Execution Options\cs2.exe\PerfOptions\CpuPriorityClass = 3` (never 4/Realtime). Self-elevates with one UAC prompt (`Start-Process -Verb RunAs`), then re-reads the value to report success. `-Restore` removes the value and the keys if they're empty; `-DryRun`.
- **`windows/cs2-compat.ps1`**: shows/sets the cs2.exe Compatibility tab through `HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers` (value name = cs2.exe path rebuilt with real folder case, since Steam's `SteamPath` is lowercase; data `~ FLAG ...`). `-Fso Checked|Unchecked` toggles `DISABLEDXMAXIMIZEDWINDOWEDMODE` and keeps other flags; `-Clear`; `-DryRun`; no args = status. HKLM (all users) flags are only reported. Repo default is **ticked** (most 2026 guides and pros recommend it). Full ticks it, option 7 switches it either way. If someone reports CS2 crashes or stutter after it (reported for some AMD users), untick is the fix.
- **`guide/guide.cfg`**: `echo` table of every bind, printed to the console on load as confirmation.
- **`README.md`**: Public landing page: centered header (badges + guide nav), a 2×3 Highlights HTML table, quick install (visible), binds (tables)/features/troubleshooting in collapsible `<details>` blocks, a Guides table and a centered footer. Keep a blank line after `<summary>` so the markdown inside renders. GitHub `> [!TIP]` alerts don't render inside `<details>`, use a plain `> 💡` quote there. In HTML table cells write `**Title**<br>Text` on one line (a newline after `<br>` adds a gap). Preview with `POST https://api.github.com/markdown` (`mode: gfm` for alerts, `markdown` for README line breaks).
- **`docs/`**: The longer guides, each starting with a "Back to README" link: `manual-install.md` (launch options live here), `video-settings.md`, `nvidia-profile.md`, `monitor-acer-kg251q-240hz.md`, `custom-font.md`. Link between them with relative paths, not README anchors.
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
- Confirmed "Unknown command" in build 10955: `cl_autowepswitch`, `cl_playerspraydisable`, `cl_join_advertise`. `cl_interp` is locked. `mat_info` doesn't exist in CS2 (check display mode in the video menu / PresentMon) and `-novid` does nothing. Check new cvars against an in-game `exec autoexec` log before keeping them.
- Research cvars against 2025–2026 sources (Valve patch notes, the Valve wiki cvar list, prosettings.net, csdb.gg) before adding them; many "pro" tips online are placebo or locked.

## Common Development Tasks

1. **Testing changes**: copy files to `...\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg\`, then in the CS2 console run `exec autoexec`. Check a bind with `bind <key>`, and a cvar by typing its name.
2. **Adding binds**: add to `autoexec.cfg`, following the existing comment-header style (`// Title` + one-line description). Check the key isn't already bound (including inside `def*`/`key*` aliases).
3. **Keep docs in sync**: when binds change, update `README.md`, `guide/guide.cfg` and `steam-guide/steam_guide.txt` too.
4. **Buy scripts**: `,` CT loadout, `.` T loadout, `/` AWP, `M` vest+deagle; CAPSLOCK + 1–5 / X/F/Z/V for quick buys.

## Configuration Dependencies

- Launch options (see `docs/manual-install.md`; `install.ps1` copies the same string to the clipboard) must include `+exec autoexec.cfg`.
- A fresh CS2 install resets the saved key file (`cs2_user_keys_0_slot0.vcfg`), so anything not bound directly in `autoexec.cfg` on load will be missing.
- Sensitivity is set for 1600 DPI (eDPI 288). `m_yaw` stays at the default 0.022 even on 1080x1080 stretched. The compensation formula `0.022 × render aspect ÷ 16/9` (4:3 = 0.0165, 1:1 = 0.012375) is documented as optional only. `m_pitch` stays 0.022. When it changes, update `docs/video-settings.md` and `steam-guide/steam_guide.txt` too.
