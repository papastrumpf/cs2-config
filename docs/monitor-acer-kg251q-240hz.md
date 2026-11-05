[⬅ Back to README](../README.md)

# 🖥️ Monitor Settings: Acer KG251Q (240 Hz)

OSD settings for the **Acer KG251Q 240 Hz** (sold as **KG251QDbmiipx**, 24.5" TN, 1080p, 48–240 Hz FreeSync) tuned for CS2. The 75 Hz and 144 Hz KG251Q versions have a different menu; check your model in **OSD → Information** or the label on the back.

Monitor settings can't be applied from `autoexec.cfg` or a script: set them by hand with the buttons on the monitor (**Menu** → **Function menu**).

---

## ✅ Before you start

* **Use the DisplayPort cable.** 240 Hz only works on **DisplayPort** or **HDMI 2**. HDMI 1 tops out at 120 Hz.
* **Windows:** Settings → System → Display → Advanced display → **Refresh rate: 240 Hz**.
* **CS2:** Settings → Video → **Refresh Rate: 240 Hz** (not "Auto"/60).
* Check it: turn on **OSD → Refresh rate num** for a moment. It should show 240 in game, then turn it off again.

---

## 🎯 OSD Settings

### Gaming

| Setting | Value | Why |
|---|---|---|
| **FreeSync** | **Off** | CS2 runs well above 240 FPS uncapped (`fps_max 0`), where FreeSync does nothing. With FreeSync on, the monitor also locks Over Drive to Normal. |
| **Over Drive** | **Normal** | Sharpest motion on this panel. **Extreme** causes inverse ghosting (bright trails behind moving players), **Off** leaves visible smearing. |
| **Aim point** | **Off** | You already have a crosshair. |

### Picture

| Setting | Value | Why |
|---|---|---|
| **Brightness** | **70–90** | High enough to see into dark corners; lower it if your eyes get tired in a dark room. |
| **Contrast** | **50** (default) | Raising it blows out bright areas (sky, sunlit walls on Mirage/Dust 2). |
| **Black Boost** | **5** | Lifts dark areas (boxes, corners, shadows) so players stand out. Higher washes the image out; go 3–7 to taste. |
| **ACM** | **Off** | Dynamic contrast changes brightness on its own between scenes. |
| **Super Sharpness** | **Off** | Adds halos around edges and does nothing for a native 1080p image. |
| **Blue Light** | **Off** | Tints the image yellow. Use Windows Night light outside gaming instead. |
| **MPRT** (if your unit has it) | **Off** | Backlight strobing: less motion blur, but the screen gets much darker and it can't run with FreeSync. Try it if you like, but most players keep it off. |

### Color

| Setting | Value | Why |
|---|---|---|
| **Gamma** | **2.2** (default) | The standard Windows/CS2 value. |
| **Color Temp** | **Warm** (default) or **User** | Use User only if whites look too yellow; keep R/G/B close to each other. |
| **sRGB** | **Off** | Made for photo work; it can lock picture settings like brightness. |
| **6-axis Hue / Saturate** | **Default** | Use NVIDIA Digital Vibrance below instead, it's simpler. |

### System

| Setting | Value | Why |
|---|---|---|
| **Input** | **DisplayPort** | See above. |
| **Auto Source** | **Off** | Stops the monitor scanning other inputs when it wakes up. |
| **DP Format** | **DP 1.2** (default) | DP 1.1 doesn't have the bandwidth for 1080p 240 Hz. |
| **Wide Mode** | **Full** | Stretches 4:3 and 1:1 resolutions to fill the screen (see Stretched resolutions in [video settings](video-settings.md)). Use **Aspect** if you want black bars instead. |
| **DDC/CI** | Any | Only lets PC software change monitor settings. |
| **Quick Start Mode** | Any | Only affects how fast the monitor wakes up. |

**Save it:** if your OSD has **Mode / Gamer 1–3** profiles, save these settings to one and select it with the **Mode** button.

---

## 🟩 NVIDIA Control Panel

* **Change resolution:** Refresh rate **240 Hz**, **Use NVIDIA color settings**: Output color depth **8 bpc**, Output dynamic range **Full**.
* **Adjust desktop color settings:** **Digital Vibrance 65–100%** makes player models pop against the maps. Pros use anything in this range. At 100% strong colours (orange walls, red bricks) can flatten into one shade, so drop to ~80% if wall detail disappears. Purely visual, VAC-safe (it's a driver setting).
* **Adjust desktop size and position** (only if you play stretched, 4:3 or 1080×1080): Scaling **Full-screen**, Perform scaling on **GPU**. How to make the custom resolution and the matching `m_yaw`: Stretched resolutions in [video settings](video-settings.md).
* **3D settings for CS2** (V-Sync off, G-SYNC off, highest refresh rate, max performance, unlimited shader cache): import the [NVIDIA profile](nvidia-profile.md) instead of setting them by hand. Low Latency Mode doesn't matter with CS2's **NVIDIA Reflex** on.

---

## 🧪 Test it

* [Blur Busters UFO test](https://www.testufo.com/ghosting) at 240 Hz: compare Over Drive **Normal** and **Extreme** (turn FreeSync off first). Pick the one with no bright/coloured trail behind the UFO; on this panel that's normally **Normal**.
* [Lagom black level test](http://www.lagom.nl/lcd-test/black.php): set Black Boost so you can just see squares 3–4, without the black background turning grey.

Sources: Acer KG251QDbmiipx User's Guide (OSD and timing table, [ManualsLib](https://www.manualslib.com/manual/3191541/Acer-Kg251qdbmiipx.html)), [LaptopMedia KG251QF review](https://laptopmedia.com/review/acer-kg1-kg251qf-review-a-144hz-tn-panel-that-might-surprise-you/) (Over Drive Normal vs Extreme on the same panel family), and owner reports on the [Acer Community](https://community.acer.com/en/discussion/543008/over-drive-woes) and [Blur Busters](https://forums.blurbusters.com/viewtopic.php?t=4482&start=10) forums.
