# Applies the recommended CS2 video preset (see README "Video Settings").
# Only quality lines in cs2_video.txt are changed; resolution, refresh rate, GPU and monitor stay as they are.
# Close CS2 first: the game rewrites cs2_video.txt when it exits.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File video\apply-video-settings.ps1           # apply
#   powershell -ExecutionPolicy Bypass -File video\apply-video-settings.ps1 -DryRun   # only show changes

param([switch]$DryRun)

$preset = [ordered]@{
    'setting.shaderquality'              = '0'  # Shader Detail: Low
    'setting.r_texturefilteringquality'  = '0'  # Texture Filtering: Bilinear
    'setting.msaa_samples'               = '2'  # MSAA: 2x
    'setting.r_csgo_cmaa_enable'         = '0'  # CMAA2: off
    'setting.videocfg_shadow_quality'    = '0'  # Shadow Quality: Low
    'setting.videocfg_dynamic_shadows'   = '1'  # Dynamic Shadows: All
    'setting.videocfg_texture_detail'    = '0'  # Model/Texture Detail: Low
    'setting.videocfg_particle_detail'   = '0'  # Particle Detail: Low
    'setting.videocfg_ao_detail'         = '0'  # Ambient Occlusion: Disabled
    'setting.videocfg_hdr_detail'        = '-1' # HDR: Quality (3 = Performance), checked in game Oct 2026
    'setting.videocfg_fsr_detail'        = '0'  # FSR: Disabled
    'setting.mat_vsync'                  = '0'  # V-Sync: Disabled
    'setting.r_low_latency'              = '2'  # NVIDIA Reflex: Enabled + Boost
}

if (Get-Process -Name cs2 -ErrorAction SilentlyContinue) {
    if (-not $DryRun) {
        Write-Host 'CS2 is running. Close it first, otherwise it overwrites these settings on exit.' -ForegroundColor Red
        exit 1
    }
    Write-Host 'CS2 is running (fine for a dry run, close it before applying).' -ForegroundColor Yellow
}

$steam = $null
try { $steam = (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction Stop).SteamPath } catch {}
if (-not $steam) { $steam = "${env:ProgramFiles(x86)}\Steam" }

$files = Get-ChildItem -Path (Join-Path $steam 'userdata') -Filter 'cs2_video.txt' -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\730\\local\\cfg\\' }
if (-not $files) {
    Write-Host "No cs2_video.txt found under $steam\userdata. Start CS2 once, then try again." -ForegroundColor Red
    exit 1
}

foreach ($file in $files) {
    Write-Host "`n$($file.FullName)" -ForegroundColor Cyan
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $changed = 0

    foreach ($key in $preset.Keys) {
        $value = $preset[$key]
        $pattern = '("' + [regex]::Escape($key) + '"\s+")([^"]*)(")'
        $match = [regex]::Match($text, $pattern)
        if ($match.Success) {
            if ($match.Groups[2].Value -ne $value) {
                Write-Host ("  {0}: {1} -> {2}" -f $key, $match.Groups[2].Value, $value)
                $text = [regex]::Replace($text, $pattern, ('${1}' + $value + '${3}'))
                $changed++
            }
        } else {
            Write-Host ("  {0}: (missing) -> {1}" -f $key, $value)
            $text = $text -replace '\}\s*$', ("`t`"$key`"`t`t`"$value`"`r`n}`r`n")
            $changed++
        }
    }

    if ($changed -eq 0) { Write-Host '  Already matches the preset.'; continue }
    if ($DryRun) { Write-Host "  Dry run: $changed change(s), file not written."; continue }

    $backup = "$($file.FullName).bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $file.FullName $backup
    [System.IO.File]::WriteAllText($file.FullName, $text)
    Write-Host "  Applied $changed change(s). Backup: $backup" -ForegroundColor Green
}
