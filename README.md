<div align="center">

# 🎮 CS2 Ultimate Competitive Configuration

**Optimized, well-researched and MM ready Counter‑Strike 2 config.**<br>Pro binds · clutch audio · one-key buys · low-latency video + NVIDIA presets · 1-click install

[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/papastrumpf/cs2-config?style=flat-square)](https://github.com/papastrumpf/cs2-config/commits/main)
[![Stars](https://img.shields.io/github/stars/papastrumpf/cs2-config?style=flat-square)](https://github.com/papastrumpf/cs2-config/stargazers)

**[⚡ Install](#-quick-install-windows)** · **[🛠️ Manual&nbsp;install](docs/manual-install.md)** · **[🎞️ Video](docs/video-settings.md)** · **[🟩 NVIDIA](docs/nvidia-profile.md)** · **[🖥️ Monitor](docs/monitor-acer-kg251q-240hz.md)** · **[🔤 Font](docs/custom-font.md)**

</div>

---

## ✨ Highlights

<table>
<tr>
<td width="50%" valign="top">

**🎧 Clutch mode**<br>Hold CTRL or SHIFT: louder footsteps, quieter teammates, brighter screen.

</td>
<td width="50%" valign="top">

**💸 One-key buys**<br>Hold CapsLock + 1: rifle + flash, smoke, HE and molotov in one press.

</td>
</tr>
<tr>
<td valign="top">

**💣 Bomb drop + callout**<br>MOUSE3 drops the C4 and tells your team "Bomb dropped".

</td>
<td valign="top">

**🎯 Spray-follow crosshair**<br>Hold right-click while spraying and the crosshair follows the recoil.

</td>
</tr>
<tr>
<td valign="top">

**🔇 Mute the enemy team**<br>One key (J) silences enemy voice chat, press again to undo.

</td>
<td valign="top">

**⚡ Low input lag**<br>Video preset, network tuning and an [NVIDIA driver profile](docs/nvidia-profile.md).

</td>
</tr>
</table>

---

## ⚡ Quick install (Windows)

1. **Download:** green **<> Code** button → **Download ZIP**, then right-click `cs2-config-main.zip` → **Extract All…** → **Extract**.
2. **Close CS2.**
3. **Run `install.bat`** in the extracted `cs2-config-main` folder and pick what to install:

   | Option | Installs |
   |---|---|
   | **1. Full install** *(recommended, just press Enter)* | Config + [video settings](docs/video-settings.md) + [custom font](docs/custom-font.md) |
   | **2.** Config only · **3.** Video only · **4.** Config + video · **5.** Font only | Just that part |

   It backs up anything it replaces.
4. **Launch options:** they're now on your clipboard. Paste them in Steam → right-click **Counter-Strike 2** → **Properties** → **General** → **Launch Options**.
5. **Check:** start CS2 and press `~`: you should see the bind table.
6. *(Optional, NVIDIA)* Import the [NVIDIA profile](docs/nvidia-profile.md).

> [!TIP]
> Without the menu: `install.ps1 -Mode Full` (or `Config`, `Video`, `ConfigVideo`, `Font`). Add `-DryRun` to only see what it would do. Linux or no script: [manual install](docs/manual-install.md).

---

## 📖 Reference

<details>
<summary><b>🖱️ Key Bindings</b> (click to expand)</summary>

#### 🚶 Movement & Actions

| Key | Action |
|---|---|
| **SPACE** / **MWHEEL** | Jump |
| **CTRL** | Clutch Crouch: crouch + louder game + quieter teammate voices + brighter screen (hold) |
| **SHIFT** | Clutch Walk: walk + louder game + quieter teammate voices + brighter screen (hold) |
| **ALT** | Big radar + teammate names (hold) |
| **MOUSE2** | Right click + follow-recoil crosshair (hold) ¹ |
| **C** | Switch hands |
| **E** | Defuse zoom + louder game + quieter voices (hold) |
| **K** | AFK movement toggle |
| **MOUSE3** | C4 drop + "Bomb dropped" radio call |
| **MOUSE4** | Player ping |
| **MOUSE5** | Voice record |

¹ Hold right + left click together when spraying so the crosshair follows your spray; tap with just left click for a static crosshair. Not for pistols: you tap them anyway, and right click toggles Glock burst and R8 alt fire. Silencers never come off (`cl_silencer_mode 0`).

#### 🔫 Weapons & Equipment

| Key | Action |
|---|---|
| **Q** | Quick weapon switch |
| **1–5** | Weapon slots |
| **3** | Pull knife / press again to inspect |
| **X** | HE grenade / buy HE (CapsLock hold) |
| **F** | Flashbang / buy flash (CapsLock hold) |
| **Z** | Smoke / buy smoke (CapsLock hold) |
| **V** | Molotov / buy molotov (CapsLock hold) |

#### 💰 Buy Binds

| Key | Buys |
|---|---|
| **M** | Vest + Deagle |
| **,** | Full CT loadout |
| **.** | Full T loadout |
| **/** | AWP loadout |
| **CapsLock + 1** | AK/M4 + flash + molotov + HE + smoke |
| **CapsLock + 2** | AK/M4 + 2× flash + molotov + smoke |
| **CapsLock + 3** | Vest |
| **CapsLock + 4** | Vest + helmet |
| **CapsLock + 5** | Defuser |

#### 🧰 Utility

| Key | Action |
|---|---|
| **TAB** | Scoreboard + network graphs (hold) |
| **T** | Toggle voice enable/disable |
| **N** | Toggle crosshair recoil |
| **I** | Infinite inspect |
| **J** | Toggle enemy voice mute |
| **L** | Say "Get Leetify" in all chat |
| **P** | Mic test (toggle): press P, hold MOUSE5 and talk to hear yourself, press P again to stop |
| **CAPSLOCK** | Buy/equip mode (hold) |

> 💡 **Silent reload:** hold **R** to reload without making noise (slower), since the September 2026 update. No bind needed.

</details>

<details>
<summary><b>⚙️ Configuration Features</b> (click to expand)</summary>

| Area | What's tuned |
|---|---|
| 🚀 **Performance** | Launch options for higher FPS, engine smoothness and micro-stutter fixes |
| 🌐 **Network** | Rate settings, lower input latency, 40 ms max ping for matchmaking |
| 👁️ **Visuals** | Custom crosshair, clean viewmodel, radar tuned for awareness, minimal HUD |
| 🔊 **Sound** | Competitive mix, clearer footsteps, music off, MVP music at 20%, quieter agent radio lines, audible 10-second bomb warning (10%) |
| 🧩 **Gameplay** | Fast bomb drop, AFK prevention, clutch volume boost, buy scripts, enemy team mute |

</details>

<details>
<summary><b>🛠️ Troubleshooting</b> (click to expand)</summary>

* If anything behaves strangely, load the config once in the main menu and once again inside a match. After that, everything should work smoothly (required only once).
* Still having issues? [Open an issue](https://github.com/papastrumpf/cs2-config/issues) or message me on [Steam](https://steamcommunity.com/id/_papastrumpf). Please include what isn't working and the console output after `exec autoexec` (especially any "Unknown command" lines).

</details>

---

## 📚 Guides

| Guide | What it covers |
|---|---|
| [🛠️&nbsp;Manual&nbsp;install](docs/manual-install.md) | Copy the files yourself, launch options, Linux paths |
| [🎞️&nbsp;Video&nbsp;settings](docs/video-settings.md) | In-game video preset + script that applies it |
| [🟩&nbsp;NVIDIA&nbsp;profile](docs/nvidia-profile.md) | Download Profile Inspector, import the CS2 driver profile |
| [🖥️&nbsp;Monitor&nbsp;settings](docs/monitor-acer-kg251q-240hz.md) | Over Drive, Black Boost, FreeSync for 240 Hz TN monitors |
| [🔤&nbsp;Custom&nbsp;font](docs/custom-font.md) | Clearer menu/HUD font, apply and undo |

---

<div align="center">

Built with ❤️ by [**Papa Strumpf**](https://steamcommunity.com/id/_papastrumpf) for high-level competitive play 🏆<br>Fully customizable, tweak freely. Ideas or issues? [Open an issue](https://github.com/papastrumpf/cs2-config/issues) 🙌

</div>
