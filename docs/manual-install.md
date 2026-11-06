[⬅ Back to README](../README.md)

# 🛠️ Manual Install

Use this if you don't want to run `install.bat`, or you're on Linux.

1. Download this repo: click the green **<> Code** button → **Download ZIP**, then right-click `cs2-config-main.zip` → **Extract All…** → **Extract**.

2. Open your CS2 config directory (in Steam: right-click **Counter-Strike 2** → **Manage** → **Browse local files** → `game` → `csgo` → `cfg`):

   * **Windows:** `C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg`
   * **Linux:** `~/.steam/steam/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg`

3. Copy `autoexec.cfg`, `guide` and `movement` folders from the extracted `cs2-config-main` folder into this folder.

4. Add the following to your **Launch Options** (Steam → right-click **Counter-Strike 2** → **Properties** → **General**):

   ```
   -novid -nojoy -fullscreen +fps_max 0 +engine_low_latency_sleep_after_client_tick true +exec autoexec.cfg
   ```

5. *(Optional, Windows)* Apply the recommended [video settings](video-settings.md): close CS2, open the extracted `cs2-config-main` folder, click the File Explorer address bar, type `powershell` and press Enter, then run the command below. It backs up your video settings first and keeps your resolution and refresh rate.

   ```
   powershell -ExecutionPolicy Bypass -File video\apply-video-settings.ps1
   ```

6. *(Optional, Windows)* Apply the [custom font](custom-font.md) the same way:

   ```
   powershell -ExecutionPolicy Bypass -File fonts\apply-font.ps1
   ```

7. *(Optional, Windows)* Apply the [Windows settings](video-settings.md) (pointer precision off, pointer speed 6/11, no Sticky Keys popup, Game Mode on, Game DVR off, game audio not turned down during calls), cs2.exe High priority and network adapter power saving off (one admin prompt each). Undo any of them with `-Restore`:

   ```
   powershell -ExecutionPolicy Bypass -File windows\apply-windows-input.ps1
   powershell -ExecutionPolicy Bypass -File windows\cs2-priority.ps1
   powershell -ExecutionPolicy Bypass -File windows\apply-network.ps1
   ```

8. *(Optional, NVIDIA)* Import the [NVIDIA profile](nvidia-profile.md).

9. *(Optional, Windows)* Set up the [Audio EQ](audio-eq.md). The first command installs Equalizer APO and ReaPlugs if they're missing (tick your headset in Equalizer APO's Device Selector), the second sets the headset to 48 kHz:

   ```
   powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -Headphones LogitechGProX -InstallMissing
   powershell -ExecutionPolicy Bypass -File audio\set-device-format.ps1
   ```

10. Launch CS2 and confirm the config loaded via console: you should see all binds in a table. If you don't, type `exec autoexec` in the console.
