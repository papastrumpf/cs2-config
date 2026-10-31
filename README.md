# 🎮 CS2 Ultimate Competitive Configuration 

Welcome to the **optimized, well-researched, and MM ready** Counter‑Strike 2 configuration guide.✨

**Guides:** [⚡ Quick install](#-quick-install-windows) · [🛠️ Manual install](docs/manual-install.md) · [🖥️ Video settings](docs/video-settings.md) · [🟩 NVIDIA profile](docs/nvidia-profile.md) · [🖥️ Monitor settings](docs/monitor-acer-kg251q-240hz.md) · [🔤 Custom font](docs/custom-font.md)

Click a ▶ section below to expand it.

---

## ⚡ Quick install (Windows)

1. Download this repo: click the green **<> Code** button → **Download ZIP**, then right-click `cs2-config-main.zip` → **Extract All…** → **Extract**.
2. Close CS2.
3. Open the extracted `cs2-config-main` folder, double-click **`install.bat`** and pick what to install:
   * **1. Full install**: config + [video settings](docs/video-settings.md) + [custom font](docs/custom-font.md) (recommended, just press Enter)
   * **2.** Config only · **3.** Video settings only · **4.** Config + video settings · **5.** Font only

   It backs up anything it replaces.
4. If you installed the config, the launch options are now on your clipboard: paste them in Steam → right-click **Counter-Strike 2** → **Properties** → **General** → **Launch Options**.
5. Start CS2 and press `~`: you should see the bind table.
6. *(Optional, NVIDIA)* Import the [NVIDIA profile](docs/nvidia-profile.md) with NVIDIA Profile Inspector.

Without the menu: `install.ps1 -Mode Full` (or `Config`, `Video`, `ConfigVideo`, `Font`). Add `-DryRun` to only see what it would do. Linux or no script: [manual install](docs/manual-install.md).

---

<details>
<summary><b>🖱️ Key Bindings</b></summary>

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

### 💡 Tips

* **Silent reload:** hold **R** to reload without making noise (slower), since the September 2026 update. No bind needed.

</details>

<details>
<summary><b>⚙️ Configuration Features</b></summary>

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

</details>

<details>
<summary><b>🛠️ Troubleshooting</b></summary>

* If anything behaves strangely, load the config once in the main menu and once again inside a match. After that, everything should work smoothly. ✔️ (required only once)
* Still having issues? Report them so I can fix it: [open an issue](https://github.com/papastrumpf/cs2-config/issues) or message me on [Steam](https://steamcommunity.com/id/_papastrumpf). Please include what isn't working and the console output after `exec autoexec` (especially any "Unknown command" lines). 🙏

</details>

---

## 📚 More Guides

| Guide | What it covers |
|---|---|
| [🛠️ Manual install](docs/manual-install.md) | Copying the files yourself, launch options, Linux paths |
| [🖥️ Video settings](docs/video-settings.md) | Recommended in-game video settings + script that applies them |
| [🟩 NVIDIA profile](docs/nvidia-profile.md) | Download NVIDIA Profile Inspector and import the CS2 driver profile |
| [🖥️ Monitor settings](docs/monitor-acer-kg251q-240hz.md) | OSD settings (Over Drive, Black Boost, FreeSync) for the Acer KG251Q 240 Hz, most apply to any 240 Hz TN |
| [🔤 Custom font](docs/custom-font.md) | Barlow Semi Condensed menu/HUD font, apply and undo |

---

## 📝 Notes

* Built with love by [**Papa Strumpf**](https://steamcommunity.com/id/_papastrumpf) ❤️
* Designed for high‑level competitive play 🏆
* Includes numerous QoL improvements
* Fully customizable – tweak freely!

For issues, ideas, or improvements, feel free to open an issue in the repository. 🙌
