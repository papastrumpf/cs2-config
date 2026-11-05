[⬅ Back to README](../README.md)

# 🎞️ Video Settings (Recommended)

Apply them automatically: close CS2, then run this from the repo folder (or pick **Video settings** in `install.bat`). It backs up your `cs2_video.txt` and only changes the quality settings below (your resolution, refresh rate and monitor stay the same). Add `-DryRun` to only see what would change.

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

## 🖥️ Display mode checklist

* **Display Mode:** **Fullscreen**, not Fullscreen Windowed. The `-fullscreen` launch option forces it, so keep it. Don't add `-windowed` or `-noborder`.
* **Fullscreen optimizations:** right-click `cs2.exe` (`game\bin\win64`) → **Properties** → **Compatibility** and **tick** **Disable fullscreen optimizations**. Most 2026 guides and pros (m0NESY) recommend it for smoother frametimes in CS2. The **Full** install in `install.bat` ticks it for you. If CS2 crashes or stutters after ticking it (reported by some AMD users), untick it again. Leave everything else on that tab unchecked (compatibility mode, run as administrator, register for restart, legacy ICC color management), and don't change the high DPI settings.

  Switch it without clicking through Properties: pick **7** in `install.bat`, or run one of these (takes effect the next time CS2 starts; no argument only shows what's ticked, `-Clear` unticks the whole tab, `-DryRun` previews):

  ```
  powershell -ExecutionPolicy Bypass -File windows\cs2-compat.ps1 -Fso Checked
  powershell -ExecutionPolicy Bypass -File windows\cs2-compat.ps1 -Fso Unchecked
  ```
* **Check it:** run [PresentMon](https://github.com/GameTechDev/PresentMon) or NVIDIA FrameView while in a match. With the box ticked, **Present Mode** reads **Hardware: Legacy Flip** (real exclusive fullscreen). *Composed Flip* means Windows is compositing the game (an overlay or a windowed mode is in the way).
* **Refresh rate:** pick **240 Hz** in the in-game **Refresh Rate** dropdown (Video → Video). CS2 has no `mat_info` command, so don't rely on guides that tell you to type it.

## ↔️ Stretched resolutions

CS2's vertical FOV is fixed (73.74°), so a narrower aspect ratio shows less to the sides and stretches the image wider on a 16:9 monitor.

| Resolution | Aspect | Horizontal FOV | `m_yaw` (16:9 monitor) |
|---|---|---|---|
| 1920×1080 | 16:9 native | 106° | `0.022` |
| 1280×960 / 1440×1080 | 4:3 stretched | 90° | `0.0165` |
| 1080×1080 | 1:1 stretched | ~74° | `0.012375` (this config) |

**Make 1080×1080:**

1. NVIDIA Control Panel → **Change resolution** → **Customize…** → **Create Custom Resolution**: 1080 × 1080, **240 Hz**. Test, then save it.
2. **Adjust desktop size and position**: Scaling **Full-screen**, Perform scaling on **GPU**, tick **Override the scaling mode set by games and programs**.
3. Monitor OSD: **Wide Mode** → **Full** (see the [monitor guide](monitor-acer-kg251q-240hz.md)).
4. In CS2 → Video: pick the **Aspect Ratio** whose list shows 1080×1080 (usually 4:3), then select it under **Resolution**.

**Why `m_yaw` changes:** stretching makes horizontal mouse movement feel faster. `m_yaw = 0.022 × render aspect ÷ (16/9)` brings the speed near the crosshair back to what it is at native 16:9. Going back to native? Set `m_yaw "0.022"` in `autoexec.cfg`.

> 💡 Ban reports about `m_yaw` so far only involve extreme values (like 9999). Values in this table are normal, but Valve has never commented on it.

## 🖱️ Mouse & keyboard

Apply the Windows part automatically (the **Full** install in `install.bat` already does it, or pick **6** for only this). CS2 can stay open. It saves your current values first, and `-Restore` puts them back. Add `-DryRun` to only see what would change.

```
powershell -ExecutionPolicy Bypass -File windows\apply-windows-input.ps1
```

* **Sensitivity:** 1600 DPI × `sensitivity 0.18` = **eDPI 288**. On another DPI, keep eDPI 288: sensitivity = 288 ÷ your DPI. `m_yaw` stays the same at any DPI (it's degrees per mouse count, so the stretch ratio doesn't depend on DPI).
* **cm/360** at 1600 DPI:
  * native (`m_yaw 0.022`): about **144 cm** horizontal and vertical.
  * 1:1 stretched (`m_yaw 0.012375`): about **257 cm horizontal**, vertical stays about 144 cm. Aim near the crosshair feels like native, but a full turn takes about 1.8× more mouse movement.
* **Windows pointer speed:** CS2 always uses raw input, so the Windows slider and **Enhance pointer precision** do nothing in game. Keep the slider at **6/11** (the 1:1 default) and Enhance pointer precision **off** for the desktop.
* **Double-click speed:** leave it as is. It only sets when two clicks count as a desktop double-click. CS2 reads every click through raw input and has no double-click action.
* **Accessibility shortcuts (the script turns these off):** pressing SHIFT 5 times opens the Sticky Keys popup, which drops you out of fullscreen. SHIFT is the clutch-walk key, so this can happen mid-round. The script also turns off the Filter Keys (right Shift held 8 s) and Toggle Keys (Num Lock held 5 s) shortcuts. If you use one of these features yourself, it stays on; only the shortcut goes.
* **Key repeat delay/rate:** leave it as is. CS2 only reads key presses and releases, so repeat only changes typing in the console and chat.

**Next:** [NVIDIA profile](nvidia-profile.md) · [Monitor settings](monitor-acer-kg251q-240hz.md)
