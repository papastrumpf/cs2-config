[⬅ Back to README](../README.md)

# 🟩 NVIDIA Profile (Optional)

[`nvidia/cs2-nvidia-profile.nip`](../nvidia/cs2-nvidia-profile.nip) sets the NVIDIA driver's **Counter-strike 2** profile. It only applies to `cs2.exe`; your other games aren't touched. NVIDIA GPUs only.

Every latency and texture filtering setting is written out, even when it matches the driver default, so after a Windows or driver reinstall one import puts everything back.

| Setting | Value | Why |
|---|---|---|
| **Maximum pre-rendered frames** | 1 | Frame queue of 1 ("Low Latency Mode: On"). **NVIDIA Reflex** in game (recommended) takes over while it's on; this kicks in if you ever play with Reflex off. |
| **Frame Rate Limiter V3** (Max Frame Rate) | Off | No driver FPS cap: CS2 runs uncapped with `fps_max 0` from the launch options. |
| **Vertical Sync** | Force off | V-Sync adds input lag. Makes sure no global setting turns it on for CS2. |
| **G-SYNC** | Off | CS2 runs above your refresh rate, where G-SYNC does nothing. |
| **Preferred refresh rate** | Highest available | Fullscreen CS2 always runs at your monitor's max (e.g. 240 Hz), never 60. |
| **Texture filtering - Quality** | High performance | Small FPS gain, no visible difference with in-game bilinear filtering. |
| **Texture filtering - Anisotropic sample / filter optimization, Trilinear optimization** | On | What High performance turns on anyway (greyed out in the NVIDIA Control Panel). Written out so a reinstall restores them. |
| **Texture filtering - Negative LOD bias** | Allow (default) | Lets the game pick texture sharpness. |
| **Texture filtering - LOD Bias / Driver Controlled LOD Bias / Quality Substitution** | 0 / On / Off (defaults) | Written out for a complete restore. |
| **Anisotropic filtering** | Application-controlled (default) | CS2's own Texture Filtering setting decides (Bilinear in the [video settings](video-settings.md)). |
| **Power management mode** | Prefer maximum performance | The GPU keeps full clocks instead of slowing down in quiet moments. |
| **Shader cache size** | Unlimited | Fewer stutters after driver and game updates. |

Resizable BAR is left at the driver default: tests disagree on whether forcing it on helps CS2.

**No "Ultra" Low Latency Mode:** NVIDIA driver 621.01 rejects the old Ultra Low Latency settings (`0x10835000`, `0x0005F543`) as unknown, so they're left out. Reflex replaces Low Latency Mode in CS2 anyway.

---

## 📥 1. Download NVIDIA Profile Inspector

1. Open the [NVIDIA Profile Inspector releases](https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest) page (official GitHub repo by Orbmu2k).
2. Under **Assets**, download **`nvidiaProfileInspector.zip`** (not the "Source code" files).
3. Right-click the zip → **Extract All…** → pick a normal folder, e.g. `Documents\nvidiaProfileInspector`.

No install needed. It needs **.NET Framework 4.8** (already on Windows 10/11) and asks for **administrator rights** when it starts, because it writes to the driver's settings: click **Yes**.

## 🟢 2. Import the profile

1. Close CS2.
2. Start `nvidiaProfileInspector.exe` and click **Yes** on the admin prompt.
3. Click **Import** in the toolbar → choose **Replace imported profile(s)** → select `nvidia\cs2-nvidia-profile.nip` from this repo.
4. If the **Apply Changes** button is highlighted, click it (or press **Ctrl+S**).

You can also drag the `.nip` file onto the Profile Inspector window and pick **Replace**.

**Or from the command line** (PowerShell in the repo folder, change the path to where you extracted it):

```
& "$env:USERPROFILE\Documents\nvidiaProfileInspector\nvidiaProfileInspector.exe" -silentImport "$PWD\nvidia\cs2-nvidia-profile.nip"
```

## ✅ 3. Check it

In Profile Inspector, type **Counter-strike 2** in the profile box at the top. You should see the settings from the table above, and `cs2.exe` in the application list.

---

## ⚠️ Good to know

* **Replace** resets the CS2 profile to the file's contents, including which `.exe` files it applies to. The file lists `cs2.exe`, so that's fine. Don't remove it from the file, or the settings stop applying to the game.
* A **driver update**, or changing CS2 settings in the NVIDIA Control Panel/NVIDIA App, can reset some values: just import again.
* **Undo:** NVIDIA Control Panel → **Manage 3D settings** → **Program Settings** → **Counter-Strike 2** → **Restore**.
* Digital Vibrance isn't part of the profile. Set it in the NVIDIA Control Panel (see the [monitor guide](monitor-acer-kg251q-240hz.md#-nvidia-control-panel)).
