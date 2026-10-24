# 🎮 CS2 Ultimate Competitive Configuration 

Welcome to the **optimized, well-researched, and MM ready** Counter‑Strike 2 configuration guide.✨

---

## 🖱️ Key Bindings

### 🚶 Movement & Actions

* **SPACE** – Jump Throw
* **CTRL** – Duck
* **SHIFT** – Clutch Volume Boost (Hold)
* **ALT** – Radar Scale Toggle (Hold)
* **C** – Switch Hands
* **E** – Defuse Zoom (Hold)
* **K** – AFK Movement Toggle
* **MOUSE3** – C4 Drop
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

* **TAB** – Network Stats + Scoreboard
* **T** – Toggle Voice Enable/Disable
* **N** – Toggle Crosshair Recoil
* **I** – Infinite Inspect
* **L** – Say "Get Leetify" in all chat
* **CAPSLOCK** – Toggle Buy/Equip Mode + Follow Recoil Crosshair (Hold)

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
* Muted unnecessary sounds
* Optimized voice communication settings

### 🧩 Gameplay Enhancements

* Precision jump‑throw script
* Fast bomb‑drop macro
* AFK prevention system
* Automatic clutch volume boost
* Efficient buy scripts
* Enemy team mute toggle

### 🌐 Network & Performance Tweaks

* Optimized rate settings
* Lower input latency
* Custom interp controls
* 40ms maxping limit

---

## 📥 Installation

1. Navigate to your CS2 config directory:

   * **Windows:** `C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg`
   * **Linux:** `~/.steam/steam/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg`

2. Copy `autoexec.cfg`, `guide` and `movement` folders into this folder.

3. Add the following to your **Launch Options**:

```
-novid -nojoy -fullscreen +fps_max 0 +engine_low_latency_sleep_after_client_tick true +exec autoexec.cfg
```

4. Launch CS2 and confirm the config loaded via console, you should see all available binding rendered in a table.
5. If you do not see it, type in console `exec autoexec`.

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

* **Boost Player Contrast:** ENABLED
* **V‑Sync:** DISABLED
* **NVIDIA Reflex:** ENABLED + BOOST
* **FPS In‑Game:** 0 (Unlimited)
* **FPS In Menus:** 200
* **MSAA:** 2×
* **Shadow Quality:** LOW
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