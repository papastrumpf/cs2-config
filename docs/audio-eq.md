[⬅ Back to README](../README.md)

# 🎧 Audio EQ: Louder Footsteps, Capped Gunshots

Windows-side audio processing for CS2: a **headphone correction**, a gentle **footstep EQ** and a **compressor** that lifts quiet sounds (steps, reloads, defuses) and turns loud ones (shots, HEs, flashes) down to protect your hearing.

It adds to the in-game settings this config already sets in `autoexec.cfg` and doesn't replace them: EQ Profile **Crisp** (`snd_headphone_eq 1`), Perspective Correction on, L/R Isolation (`snd_spatialize_lerp 0.5`), music off. Headphone preset included for the **Logitech G PRO X (wired)**. Any other headphones work too (step 2).

---

## ✅ Is it allowed on FACEIT and Valve servers?

Yes. Everything here works on the audio **after** CS2 has sent it to Windows, inside Windows' own audio engine (`audiodg.exe`). None of it reads game memory, injects into `cs2.exe` or changes a game file, so there's nothing for VAC or FACEIT Anti-Cheat to flag. Equalizer APO installs no driver at all. SteelSeries Sonar adds signed virtual audio devices, which FACEIT accepts. FACEIT doesn't publish an allow-list, but these tools are standard among FACEIT players and pros.

**Not allowed:** edited or replaced game sound files (VPK/`.vsnd` mods), programs that read the game to show sounds on screen ("sound ESP"), and anything that hooks into `cs2.exe`.

---

## 🎚️ Where CS2 sounds live

Valve doesn't publish a frequency map, and a footstep on metal sounds different from one on sand. These bands are the community consensus, and they match where human hearing is most sensitive (2–5 kHz):

| Band | What's there in CS2 | What to do |
|---|---|---|
| **20–60 Hz** (sub-bass) | HE, molotov and C4 explosion rumble, the boom tail of AWP/Deagle shots | **Cut** (−5 dB). No direction info lives here, only ear fatigue. |
| **60–250 Hz** (bass) | Heel thuds on hard floors, jump landings, the body of gunshots | **Leave.** The G PRO X has a hump around 150 Hz that hides footsteps. The headphone correction removes it. |
| **250 Hz–1 kHz** (low mids) | The body of most sounds | **Leave.** |
| **1–4 kHz** (upper mids) | Footstep scuffs and surface texture, reload clicks (mag out/in, bolt), defuse start, bomb beeps, scope zoom | **Boost** about +3 dB around 3 kHz. This is the footstep band. |
| **4–8 kHz** (presence) | Crunch on gravel, metal, tile and wood, shell casings. Also where Steam Audio's **up/down and front/back cues** sit | **Small, broad lift only** (+1.5 dB). Sharp boosts or cuts here confuse "above or below me?". |
| **8–20 kHz** (air) | Air, hiss | **Leave.** More only adds fatigue. |

> 💡 **Why you can't EQ gunshots away:** shots and flashes are broadband and loudest in the same 1–4 kHz band as footsteps, so cutting them cuts footsteps too. What actually hurts is the *loudness gap* between a step and a shot. That's a dynamics problem, so the fix is a compressor, not an EQ.

---

## 🧰 Software

| Tool | Free | What it does | Use it? |
|---|---|---|---|
| **[Equalizer APO](https://sourceforge.net/projects/equalizerapo/)** (1.4.2+) | ✅ open source | System-wide parametric EQ inside the Windows audio engine. No added latency (IIR filters). Loads VST plugins. | ✅ **The EQ** |
| **ReaComp** ([ReaPlugs x64](https://www.reaper.fm/reaplugs/)) | ✅ | Compressor with Threshold, Ratio, Knee, Attack, Release and make-up gain. Runs inside Equalizer APO. | ✅ **The compressor** |
| **[SteelSeries Sonar](https://steelseries.com/gg/sonar)** (in SteelSeries GG) | ✅ | Virtual devices, parametric EQ, CS2 pro presets, "Smart Volume" | All-in-one GUI alternative. Heavier (GG keeps running) and no attack/release control. Use it **or** Equalizer APO, not both. |
| **Sound Lock** | ✅ | Caps the output volume | Limiter only: caps peaks but doesn't lift footsteps. |
| **Loudness Equalization** (Windows) | built in | Automatic compressor in the device's enhancements | **Off** with this setup. No controls, and it "pumps": footsteps fade in and out after every shot. |

**How it fits together** (no game files involved):

```
CS2 → Windows audio engine → Equalizer APO: headphone correction → footstep EQ → ReaComp → headset
```

---

## 🔧 Windows and G HUB settings

Windows: **Settings → System → Sound →** your headset.

| Setting | Value | Why |
|---|---|---|
| **Format** | **48000 Hz** (24 bit if offered, the G PRO X adapter only has 16) | The common gaming choice. Avoids extra resampling. Installer option 9 sets 48 kHz and keeps your bit depth. |
| **Spatial sound** | **Off** | CS2 already does 3D audio (Steam Audio HRTF). Windows Sonic or Dolby Atmos on top blurs positions. |
| **Audio enhancements** | **Device Default Effects** (on) | **Off skips Equalizer APO completely.** The script warns you if it's off. |
| **Loudness Equalization, Bass Boost, Virtual Surround** (Realtek etc.) | **Off** | A second compressor or EQ stacks with this one. |
| **Communications** (Sound → More sound settings) | **Do nothing** | Windows turns the game down by 80% while Discord is active. Installer option 6 sets this. |

**Logitech G HUB** (only if the G PRO X runs through its USB adapter). Set these by hand: G HUB keeps them in its own database and writes the EQ into the adapter itself, so no script can change them.

| Setting | Value | Why |
|---|---|---|
| **Surround Sound** (DTS Headphone:X 2.0) | **Off** (unticked) | Virtual surround on top of CS2's HRTF wrecks direction cues. |
| **Equalizer** | Preset **Default** (all bands 0), then **Update on-board memory (DAC)** | The correction comes from Equalizer APO. Two EQs stack, and the adapter keeps playing its stored EQ whenever G HUB isn't running. |
| **Blue VO!CE** | Any | Only affects your mic. |

**USB adapter or 3.5 mm?** Both work. Equalizer APO just has to be on the device you play on: the **PRO X** device for the USB adapter, or your motherboard output (e.g. Realtek) for the 3.5 mm jack. If the EQ doesn't kick in on the USB adapter, open the Equalizer APO **Device Selector**, tick **Troubleshooting options** for that device, try the SFX/EFX install option and reboot.

---

## 🚀 Setup

1. **Run `install.bat` → 9** and pick **1** (Logitech G PRO X) or **2** (other headphones). It does everything else:
   * **Equalizer APO** missing? It downloads 1.4.2 x64 from SourceForge, checks the file's SHA-256 (the installer isn't code-signed) and starts the installer: confirm the admin prompt. When the **Device Selector** opens, tick **only the headset you play on** under Playback devices and click OK. That's the one click Equalizer APO doesn't let a script do. If the test shows a yellow **!** under Pre-mix and a green check under Post-mix, that's fine: all of this runs post-mix.
   * Copies [`cs2-footsteps.txt`](../audio/cs2-footsteps.txt) and the [headphone correction](../audio/headphones/logitech-g-pro-x.txt) into `C:\Program Files\EqualizerAPO\config`, backs up `config.txt` and includes both files.
   * **ReaPlugs** missing? It downloads it from reaper.fm, checks the Cockos signature and installs it silently (one admin prompt). Then it adds **ReaComp** with the settings below.
   * Sets your **default playback device to 48 kHz** (bit depth unchanged, only if the device supports it).
   * Reminds you of the two G HUB settings above if G HUB is running.

   CS2 can stay open, but restart it afterwards so it picks up the new format. Or run the scripts directly:
   ```
   powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -Headphones LogitechGProX -InstallMissing
   powershell -ExecutionPolicy Bypass -File audio\set-device-format.ps1
   ```
   **Other headphones:** on [autoeq.app](https://autoeq.app) pick your model, choose **Equalizer APO ParametricEQ**, download, and paste the text into `config\cs2-headphones.txt`. No measurement for your model? Skip it, the footstep EQ works on its own. No compressor wanted: add `-NoCompressor`.
2. **G HUB** (G PRO X on the USB adapter): set the two settings from the table above by hand.
3. **Set your volume:** the EQ preamps lower everything by up to 10 dB so nothing clips. ReaComp's make-up gain brings most of that back. Throw an HE at your feet in a practice match: it should be loud but never painful. Turn the Windows volume down until it isn't.

> 💡 **Tweaking ReaComp:** open **Equalizer APO Configuration Editor**, click **Open panel** on the ReaComp line, change values and save (**Ctrl+S**). The editor's analysis panel shows a peak gain of about +6 dB in red. That's normal: it measures with a quiet test signal, which gets the full Wet make-up gain. Loud sounds get compressed first.

> 💡 The two EQ layers look like this together: −5 dB below 40 Hz, the G PRO X's 150 Hz hump removed, +3 dB around 3 kHz and a gentle lift up to 8 kHz. The Configuration Editor shows the curve.

---

## 🗜️ Compressor settings (ReaComp)

Option 9 writes these. The table explains each one, in case you want to tune them.

| Setting | Value | Why |
|---|---|---|
| **Threshold** | **−24 dB** (tune it) | Only sounds above this get turned down. Tune it with the gain-reduction meter: gunshots and HEs should show **6–10 dB** of reduction, footsteps **none**. |
| **Ratio** | **4:1** | Above the threshold, every 4 dB in comes out as 1 dB. |
| **Knee** | **6 dB** | Eases into compression instead of grabbing hard at the threshold. |
| **Attack** | **3 ms** | Fast enough to catch the crack of a shot or flash before it hits your ears at full level. |
| **Release** | **100 ms** | Recovers fast enough to hear a step right after a shot. Much faster distorts, much slower leaves everything muffled after every shot. |
| **Pre-comp** | **0 ms** | Look-ahead delays **all** audio by this amount. 0 = no added latency. |
| **RMS size** | **0 ms** (peak) | Reacts to the peak of a shot, not its average. |
| **Wet** | **+6 dB** | Make-up gain: everything below the threshold (footsteps, reloads) comes out 6 dB louder. |
| **Auto make-up gain** | **Off** | Its automatic boost is too big for game audio. Wet sets it instead. |
| **Limit output** | Doesn't matter | It doesn't stick in Equalizer APO: it isn't a plugin parameter, so ReaComp always loads with it off. You don't need it for the cap: digital audio can't go above full scale, so your volume setting already sets the maximum loudness. At worst a very loud peak clips for a moment. If nearby HEs crackle, set Wet to +3 dB. |

What it does, as an example: a footstep at −40 dB stays below the threshold and comes out at −34 dB (+6). An HE at −10 dB comes out at about −14.5 dB. The gap between them shrinks from 30 dB to about 20 dB.

> ⚠️ **Don't overdo it.** CS2 tells distance mostly by loudness. A ratio above 4:1 or more than +6 dB Wet makes far steps sound close. If you start misjudging distances, go to 3:1 or Wet +3 dB.

> 💡 The clutch keys in this config (hold SHIFT, CTRL or E) raise `volume` from 0.5 to 1.0, which is +6 dB going into the compressor. That still works, and the compressor turns those louder peaks down too.

---

## 🧪 Test it

* **A/B:** in the Configuration Editor, each block has a **power** button. Toggle the `Include` lines or ReaComp on and off while a demo or practice match plays.
* **Footsteps through floors:** on **Nuke** or **Vertigo** (practice with bots, or a demo of your own match), listen to steps above and below you. You should hear clearly which floor they're on. If up/down gets worse, the 4–8 kHz lift is too strong for your ears: set the `5500 Hz` filter in `cs2-footsteps.txt` to +0.5 dB.
* **Peaks:** throw an HE or flash next to you and watch ReaComp's meter. Expect 6–10 dB of gain reduction, then adjust the Threshold.

---

## ↩️ Undo

* EQ files and `config.txt`: `powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -Restore` (puts back your old `config.txt`, so the ReaComp line goes too).
* Headset format: `powershell -ExecutionPolicy Bypass -File audio\set-device-format.ps1 -Restore`.
* Everything: uninstall Equalizer APO and ReaPlugs (Settings → Apps), reboot.
* G HUB: pick your old preset under **Custom** and update the on-board memory again.
* Communications setting: `windows\apply-windows-input.ps1 -Restore`.

Sources: G PRO X correction from [AutoEq](https://github.com/jaakkopasanen/AutoEq/tree/master/results/crinacle/GRAS%2043AG-7%20over-ear/Logitech%20G%20Pro%20X) (crinacle, GRAS 43AG-7). Equalizer APO's [project page](https://sourceforge.net/projects/equalizerapo/) and source (config path, VST loading, enhancements check). The [Cockos ReaComp wiki](https://www.cockos.com/wiki/index.php/ReaComp). Footstep bands: [bo3.gg](https://bo3.gg/articles/how-to-make-footsteps-louder-in-cs2), [CenterPoint Gaming](https://www.centerpointgaming.com/best-audio-settings-cs2.html), [The Global Gaming](https://theglobalgaming.com/cs/how-to-make-footsteps-louder). [FACEIT Anti-Cheat overview](https://support.faceit.com/hc/en-us/articles/9394666828188-What-is-FACEIT-Anti-cheat-and-how-does-it-work).
