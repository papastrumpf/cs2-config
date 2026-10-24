# 🎮 CS2 Ultimate Competitive Configuration 

Welcome to the **optimized, well-researched, and MM ready** Counter‑Strike 2 configuration guide.✨

---

## 🖱️ Key Bindings

### 🚶 Movement & Actions

* **SPACE** – Jump
* **CTRL** – Clutch Crouch: crouch + louder game + quieter teammate voices + brighter screen (Hold)
* **SHIFT** – Clutch Walk: walk + louder game + quieter teammate voices + brighter screen (Hold)
* **ALT** – Big Radar + Teammate Names (Hold)
* **MOUSE2** – Right Click + Follow Recoil Crosshair (Hold). Hold right + left click together when spraying so the crosshair follows your spray; tap with just left click for a static crosshair. Not for pistols: you tap them anyway, and right click toggles Glock burst and R8 alt fire. Silencers never come off (`cl_silencer_mode 0`).
* **C** – Switch Hands
* **E** – Defuse Zoom + Louder game + Quieter voices (Hold)
* **K** – AFK Movement Toggle
* **MOUSE3** – C4 Drop + "Bomb dropped" radio call
* **MOUSE4** – Player Ping
* **MOUSE5** – Voice Record
* **MWHEEL UP/DOWN** – Jump

### 🔫 Weapons & Equipment

* **Q** – Quick Weapon Switch
* **1–5** – Weapon Slots
* **3** – Pull knife / Press again to inspect
* **X** – HE Grenade / Buy HE (CapsLock Hold)
* **F** – Flashbang / Buy Flash (CapsLock Hold)
* **Z** – Smoke / Buy Smoke (CapsLock Hold)
* **V** – Molotov / Buy Molotov (CapsLock Hold)

### 💰 Buy Menu

* **M** – Buy Vest + Deagle
* **,** – Full CT Loadout (CT)
* **.** – Full T Loadout (T)
* **/** – AWP Loadout

#### ⌨️ CapsLock Hold – Quick Buy System

* **1** – AK/M4 + Flash + Molotov + HE + Smoke
* **2** – AK/M4 + 2× Flash + Molotov + Smoke
* **3** – Vest
* **4** – Vest + Helmet
* **5** – Defuser

### 🧰 Utility

* **TAB** – Scoreboard + Network Graphs (Hold)
* **T** – Toggle Voice Enable/Disable
* **N** – Toggle Crosshair Recoil
* **I** – Infinite Inspect
* **J** – Toggle Enemy Voice Mute
* **L** – Say "Get Leetify" in all chat
* **P** – Mic Test (Toggle). Check your mic works before a match: press P, hold MOUSE5 and talk, and you hear yourself. Press P again to turn it off.
* **CAPSLOCK** – Buy/Equip Mode (Hold)

---

## ⚙️ Configuration Features

### 🚀 Performance Optimization

* Tweaked launch parameters for higher FPS
* Network settings tuned for low latency
* Engine‑level smoothness improvements
* Micro‑stutter reduction enabled

### 👁️ Visual Improvements

* Custom crosshair setup
* Clean viewmodel for clarity
* Radar optimized for awareness
* Minimalistic HUD for competitive focus

### 🔊 Sound Enhancements

* Balanced mixer for competitive soundscapes
* Clearer footstep audio
* Muted unnecessary sounds (music and bomb/hostage music off, MVP music at 20%, quieter agent radio lines)
* Audible 10‑second bomb warning (10%) as a timing cue
* Optimized voice communication settings

### 🧩 Gameplay Enhancements

* Fast bomb‑drop macro
* AFK prevention system
* Automatic clutch volume boost
* Efficient buy scripts
* Enemy team mute toggle

### 🌐 Network & Performance Tweaks

* Optimized rate settings
* Lower input latency
* 40ms maxping limit

---

## 📥 Installation

### ⚡ Quick install (Windows)

1. Download this repo: click the green **<> Code** button → **Download ZIP**, then right-click `cs2-config-main.zip` → **Extract All…** → **Extract**.
2. Close CS2.
3. Open the extracted `cs2-config-main` folder and double-click **`install.bat`**. It copies the config into CS2, applies the [video settings](#️-video-settings-recommended) and the [custom font](#-custom-font-optional), and backs up anything it replaces.
4. The launch options are now on your clipboard: paste them in Steam → right-click **Counter-Strike 2** → **Properties** → **General** → **Launch Options**.
5. Start CS2 and press `~`: you should see the bind table.

To skip parts, run `install.ps1 -SkipVideo` and/or `-SkipFont` from PowerShell. Add `-DryRun` to only see what it would do.

### 🛠️ Manual install

1. Download this repo: click the green **<> Code** button → **Download ZIP**, then right-click `cs2-config-main.zip` → **Extract All…** → **Extract**.

2. Open your CS2 config directory (in Steam: right-click **Counter-Strike 2** → **Manage** → **Browse local files** → `game` → `csgo` → `cfg`):

   * **Windows:** `C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg`
   * **Linux:** `~/.steam/steam/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg`

3. Copy `autoexec.cfg`, `guide` and `movement` folders from the extracted `cs2-config-main` folder into this folder.

4. Add the following to your **Launch Options** (Steam → right-click **Counter-Strike 2** → **Properties** → **General**):

```
-novid -nojoy -fullscreen +fps_max 0 +engine_low_latency_sleep_after_client_tick true +exec autoexec.cfg
```

5. *(Optional, Windows)* Apply the recommended video settings: close CS2, open the extracted `cs2-config-main` folder, click the File Explorer address bar, type `powershell` and press Enter, then run the command below. It backs up your video settings first and keeps your resolution and refresh rate. See [Video Settings](#️-video-settings-recommended).

```
powershell -ExecutionPolicy Bypass -File video\apply-video-settings.ps1
```

6. *(Optional, Windows)* Apply the [custom font](#-custom-font-optional) the same way:

```
powershell -ExecutionPolicy Bypass -File fonts\apply-font.ps1
```

7. Launch CS2 and confirm the config loaded via console, you should see all available binding rendered in a table.
8. If you do not see it, type in console `exec autoexec`.

---

## 🔤 Custom Font (Optional)

Swaps CS2's menu and HUD font for **Barlow Semi Condensed**: as narrow as the original, so it fits, but with clearer numbers and letters. Characters it doesn't have (Cyrillic, Asian) still use the original fonts.

* Apply: `powershell -ExecutionPolicy Bypass -File fonts\apply-font.ps1` (CS2 closed), or let `install.bat` do it.
* Undo: run it with `-Restore`, or Steam → CS2 → **Properties** → **Installed Files** → **Verify integrity of game files**.
* A CS2 update can reset the font: just run it again.
* Font changes only touch font files, not gameplay. The community considers them VAC-safe, but Valve has never officially said so.
* Font: [Barlow](https://github.com/jpt/barlow), SIL Open Font License (`fonts/OFL.txt`).

---

## 💡 Tips

* **Silent reload:** hold **R** to reload without making noise (slower), since the September 2026 update. No bind needed.

---

## 📝 Notes

* Built with love by [**Papa Strumpf**](https://steamcommunity.com/id/_papastrumpf) ❤️
* Designed for high‑level competitive play 🏆
* Includes numerous QoL improvements
* Fully customizable – tweak freely!

---

## 🔧 Support

For issues, ideas, or improvements, feel free to open an issue in the repository. 🙌

---

# 🖥️ Video Settings (Recommended)

Apply them automatically: close CS2, then run this from the repo folder. It backs up your `cs2_video.txt` and only changes the quality settings below (your resolution, refresh rate and monitor stay the same). Add `-DryRun` to only see what would change.

```
powershell -ExecutionPolicy Bypass -File video\apply-video-settings.ps1
```

* **Boost Player Contrast:** ENABLED
* **V‑Sync:** DISABLED
* **NVIDIA Reflex:** ENABLED + BOOST
* **FPS In‑Game:** 0 (Unlimited)
* **FPS In Menus:** 200
* **MSAA:** 2×
* **Shadow Quality:** VERY HIGH
* **Dynamic Shadows:** ALL
* **Model/Texture Detail:** LOW
* **Texture Filtering:** BILINEAR
* **Shader Detail:** LOW
* **Particle Detail:** LOW
* **Ambient Occlusion:** DISABLED
* **HDR:** QUALITY
* **FSR:** DISABLED (Highest Quality)

---

## 🛠️ Troubleshooting

* If anything behaves strangely, load the config once in the main menu and once again inside a match. After that, everything should work smoothly. ✔️ (required only once)
* Still having issues? Report them so I can fix it: [open an issue](https://github.com/papastrumpf/cs2-config/issues) or message me on [Steam](https://steamcommunity.com/id/_papastrumpf). Please include what isn't working and the console output after `exec autoexec` (especially any "Unknown command" lines). 🙏