[⬅ Back to README](../README.md)

# 🖥️ Video Settings (Recommended)

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

**Next:** [NVIDIA profile](nvidia-profile.md) · [Monitor settings](monitor-acer-kg251q-240hz.md)
