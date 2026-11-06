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

| Resolution | Aspect | Horizontal FOV | Optional `m_yaw` compensation (16:9 monitor) |
|---|---|---|---|
| 1920×1080 | 16:9 native | 106° | `0.022` (default) |
| 1280×960 / 1440×1080 | 4:3 stretched | 90° | `0.0165` |
| 1080×1080 | 1:1 stretched | ~74° | `0.012375` |

This config keeps `m_yaw "0.022"` on every resolution.

**Make 1080×1080:**

1. NVIDIA Control Panel → **Change resolution** → **Customize…** → **Create Custom Resolution**: 1080 × 1080, **240 Hz**. Test, then save it.
2. **Adjust desktop size and position**: Scaling **Full-screen**, Perform scaling on **GPU**, tick **Override the scaling mode set by games and programs**.
3. Monitor OSD: **Wide Mode** → **Full** (see the [monitor guide](monitor-acer-kg251q-240hz.md)).
4. In CS2 → Video: pick the **Aspect Ratio** whose list shows 1080×1080 (usually 4:3), then select it under **Resolution**.

**Compensation is optional:** stretching makes horizontal mouse movement feel faster. `m_yaw = 0.022 × render aspect ÷ (16/9)` brings the speed near the crosshair back to native 16:9, but every turn needs much more mouse movement, so it feels very slow. Most stretched players keep 0.022 and get used to the faster horizontal speed. If you want to try compensation, set the value from the table in `autoexec.cfg`.

> 💡 Ban reports about `m_yaw` so far only involve extreme values (like 9999). Values in this table are normal, but Valve has never commented on it.

## 🖱️ Mouse & keyboard

Apply the Windows part automatically (the **Full** install in `install.bat` already does it, or pick **6** for only this). CS2 can stay open. It saves your current values first, and `-Restore` puts them back. Add `-DryRun` to only see what would change.

```
powershell -ExecutionPolicy Bypass -File windows\apply-windows-input.ps1
```

* **Sensitivity:** 1600 DPI × `sensitivity 0.18` = **eDPI 288**. On another DPI, keep eDPI 288: sensitivity = 288 ÷ your DPI. `m_yaw` stays the same at any DPI (it's degrees per mouse count, so the stretch ratio doesn't depend on DPI).
* **cm/360** at 1600 DPI with this config (`m_yaw 0.022`): about **144 cm** horizontal and vertical, on any resolution. With 1:1 compensation (`m_yaw 0.012375`) horizontal would become about 257 cm, about 1.8× more mouse movement per turn.
* **Windows pointer speed:** CS2 always uses raw input, so the Windows slider and **Enhance pointer precision** do nothing in game. Keep the slider at **6/11** (the 1:1 default) and Enhance pointer precision **off** for the desktop.
* **Double-click speed:** leave it as is. It only sets when two clicks count as a desktop double-click. CS2 reads every click through raw input and has no double-click action.
* **Accessibility shortcuts (the script turns these off):** pressing SHIFT 5 times opens the Sticky Keys popup, which drops you out of fullscreen. SHIFT is the clutch-walk key, so this can happen mid-round. The script also turns off the Filter Keys (right Shift held 8 s) and Toggle Keys (Num Lock held 5 s) shortcuts. If you use one of these features yourself, it stays on; only the shortcut goes.
* **Key repeat delay/rate:** leave it as is. CS2 only reads key presses and releases, so repeat only changes typing in the console and chat.

## ⚡ Windows gaming settings

The same script (and option **6** / **Full** in `install.bat`) also sets these. `-Restore` undoes them too.

* **Game Mode:** **on**. Keeps Windows Update and background work quiet while you play.
* **Xbox Game Bar captures and background recording (Game DVR):** **off**. Background recording costs GPU time. Win+Alt+R clips stop working. Fully applies after you sign out and back in.
* **Sound → Communications:** **Do nothing**. By default Windows turns the game down by 80% while Discord or another voice app is active, which buries footsteps exactly when your team is talking. EQ and compressor for footsteps: [Audio EQ](audio-eq.md).
* **cs2.exe CPU priority:** **High**, every launch, through Windows' per-program setting (`Image File Execution Options\cs2.exe\PerfOptions`). It needs admin, so you get one UAC prompt. Expect a small gain at most. Not Realtime: that can starve mouse, keyboard and audio. Separate script, undo with `-Restore`:

  ```
  powershell -ExecutionPolicy Bypass -File windows\cs2-priority.ps1
  ```
* **Network adapter power saving:** **off** on wired adapters: Green Ethernet, Power Saving Mode and Energy-Efficient Ethernet (Realtek/Intel, whichever the adapter has). Link power saving gains a desktop nothing. Needs admin (one UAC prompt) and the adapter restarts, so the network drops for a few seconds. Interrupt Moderation, offloads and RSS stay as they are: no measured CS2 difference. Separate script, undo with `-Restore`:

  ```
  powershell -ExecutionPolicy Bypass -File windows\apply-network.ps1
  ```

Set these yourself (they can't be scripted reliably):

* **Do Not Disturb while gaming:** Settings → System → Notifications → turn on *Do Not Disturb automatically… when playing a game in full screen*, so a notification can't pull you out of fullscreen.
* **Overlays:** turn off the ones you don't use (Discord, NVIDIA, RGB software popups). In the NVIDIA app, turn off **Game Filters and Photo Mode**, which cost up to 15% FPS. An overlay over the game can stop it from using the fast fullscreen path.
* **Mouse:** polling rate **1000 Hz or higher** in the mouse software, and plug it into a rear motherboard USB port (no hubs, front panel or monitor ports).
* **Core Isolation / Memory Integrity:** costs about 5–8% FPS in 2026 tests, but it's a security feature. Your choice, not something this config changes.
* **Skip:** timer-resolution tools, HPET/`bcdedit` tweaks, MSI-mode/interrupt tweaks, Ultimate Performance power plan (Balanced is as good on a single-CCD X3D CPU). No measured CS2 benefit. Why some popular ones do nothing:
  * **Timer resolution:** CS2 sets its own (`tier0.dll` calls `ZwSetTimerResolution`), and since Windows 10 2004 timer requests are per process.
  * **MMCSS tweaks** (`SystemResponsiveness`, `Tasks\Games`, `NetworkThrottlingIndex`): CS2's game threads never join MMCSS (only SDL's audio thread does). Microsoft's docs say `SystemResponsiveness` below 10 is reset to 20 and `GPU Priority` isn't used.
  * **`Win32PrioritySeparation`:** the default `2` already means short, variable quanta with 3:1 foreground boost (the same as `0x26`), and CS2 at High priority preempts normal threads regardless.
  * **Exploit Protection off for cs2.exe:** `cs2.exe` and the engine DLLs aren't built with Control Flow Guard, so there's nothing to turn off; ASLR costs nothing at runtime.
  * **Disabling SVM/IOMMU or Memory Integrity:** FACEIT relies on VBS and IOMMU and can refuse to start without them.

**Next:** [NVIDIA profile](nvidia-profile.md) · [Monitor settings](monitor-acer-kg251q-240hz.md)
