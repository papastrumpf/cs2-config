# Installer: copies the config into CS2, applies the video preset, the custom font and the Windows
# settings (mouse/keyboard, Game Mode, Game DVR, cs2.exe priority), then puts the launch options on your clipboard.
# cs2.exe High priority writes to HKLM, so Full and option 6 show one admin (UAC) prompt.
# Easiest way: double-click install.bat and pick an option. Close CS2 first.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File install.ps1                 # menu: choose what to install
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Mode Full      # no menu: Full, Config, Video, ConfigVideo, Font, Windows, Fso, Audio
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Mode Full -DryRun   # only show what would happen
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Mode Fso -Fso Unchecked   # tick/untick "Disable fullscreen optimizations"
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Mode Audio -Headphones LogitechGProX   # audio EQ setup (or -Headphones None)
# Full ticks cs2.exe's "Disable fullscreen optimizations" (what most 2026 guides recommend). Option 7 switches it either way.
# Option 9 (Audio) is not part of Full: it downloads and installs Equalizer APO and ReaPlugs if they're
# missing (one admin prompt each, you tick your headset in Equalizer APO's Device Selector), writes the footstep
# EQ, headphone correction and ReaComp compressor, and sets the headset to 48 kHz.

param(
    [ValidateSet('Full', 'Config', 'Video', 'ConfigVideo', 'Font', 'Windows', 'Fso', 'Audio')]
    [string]$Mode,
    [ValidateSet('Checked', 'Unchecked')]
    [string]$Fso,
    [ValidateSet('LogitechGProX', 'None')]
    [string]$Headphones,
    [switch]$DryRun
)

$launchOptions = '-novid -nojoy -fullscreen +fps_max 0 +engine_low_latency_sleep_after_client_tick true +exec autoexec.cfg'

function Find-CS2Game {
    $steam = $null
    try { $steam = (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction Stop).SteamPath } catch {}
    if (-not $steam) { $steam = "${env:ProgramFiles(x86)}\Steam" }
    $libraries = @($steam)
    $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
    if (Test-Path $vdf) {
        foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
            $libraries += $m.Groups[1].Value -replace '\\\\', '\'
        }
    }
    foreach ($lib in $libraries | Select-Object -Unique) {
        $game = Join-Path $lib 'steamapps\common\Counter-Strike Global Offensive\game'
        if (Test-Path (Join-Path $game 'csgo')) { return $game }
    }
    return $null
}

Write-Host 'CS2 config installer' -ForegroundColor Cyan

if (-not $Mode) {
    Write-Host ''
    Write-Host '  1. Full install (config + video settings + font + Windows settings + fullscreen optimizations off)   [recommended]'
    Write-Host '  2. Config only'
    Write-Host '  3. Video settings only'
    Write-Host '  4. Config + video settings (no font)'
    Write-Host '  5. Font only'
    Write-Host '  6. Windows settings only (mouse/keyboard, Game Mode on, Game DVR off, cs2.exe High priority)'
    Write-Host '  7. cs2.exe "Disable fullscreen optimizations" only: show, tick or untick'
    Write-Host '  9. Audio EQ: installs Equalizer APO + ReaComp if missing, footstep EQ, compressor, headset at 48 kHz'
    Write-Host '  Q. Quit'
    Write-Host ''
    $modes = @{ '1' = 'Full'; '2' = 'Config'; '3' = 'Video'; '4' = 'ConfigVideo'; '5' = 'Font'; '6' = 'Windows'; '7' = 'Fso'; '9' = 'Audio' }
    do {
        $choice = (Read-Host 'Choose 1-9 (Enter = 1)').Trim()
        if ($choice -eq '') { $choice = '1' }
        if ($choice -match '^[qQ]$') { Write-Host 'Nothing installed.'; exit 0 }
    } until ($modes.ContainsKey($choice))
    $Mode = $modes[$choice]
    $interactive = $true
}

$doConfig  = $Mode -in 'Full', 'Config', 'ConfigVideo'
$doVideo   = $Mode -in 'Full', 'Video', 'ConfigVideo'
$doFont    = $Mode -in 'Full', 'Font'
$doWindows = $Mode -in 'Full', 'Windows'
$doFso     = $Mode -in 'Full', 'Fso'
$doAudio   = $Mode -eq 'Audio'
if ($Mode -eq 'Full' -and -not $Fso) { $Fso = 'Checked' }
Write-Host "`nInstalling: $Mode$(if ($DryRun) { ' (dry run)' })" -ForegroundColor Cyan

# Only the CS2 files need the game closed; Windows settings and the Compatibility tab don't
if ((Get-Process -Name cs2 -ErrorAction SilentlyContinue) -and -not $DryRun -and ($doConfig -or $doVideo -or $doFont)) {
    Write-Host 'CS2 is running. Close it and run the installer again.' -ForegroundColor Red
    exit 1
}

if ($doConfig) {
    $game = Find-CS2Game
    if (-not $game) {
        Write-Host 'CS2 install not found in any Steam library.' -ForegroundColor Red
        exit 1
    }
    $cfg = Join-Path $game 'csgo\cfg'

    Write-Host "`n[Config] -> $cfg" -ForegroundColor Cyan
    $target = Join-Path $cfg 'autoexec.cfg'
    $source = Join-Path $PSScriptRoot 'autoexec.cfg'
    $differs = (Test-Path $target) -and ((Get-FileHash $target).Hash -ne (Get-FileHash $source).Hash)
    if ($DryRun) {
        if ($differs) { Write-Host '  would back up your current autoexec.cfg' }
        Write-Host '  would copy autoexec.cfg, movement\, guide\'
    } else {
        if ($differs) {
            $bak = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $target $bak
            Write-Host "  Backed up your old autoexec.cfg: $bak"
        }
        Copy-Item $source $target -Force
        Copy-Item (Join-Path $PSScriptRoot 'movement') $cfg -Recurse -Force
        Copy-Item (Join-Path $PSScriptRoot 'guide') $cfg -Recurse -Force
        Write-Host '  Copied autoexec.cfg, movement\, guide\' -ForegroundColor Green
    }
}

if ($doVideo) {
    Write-Host "`n[Video settings]" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'video\apply-video-settings.ps1') -DryRun:$DryRun
}

if ($doFont) {
    Write-Host "`n[Font]" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'fonts\apply-font.ps1') -DryRun:$DryRun
}

if ($doWindows) {
    Write-Host "`n[Windows mouse/keyboard + gaming]" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'windows\apply-windows-input.ps1') -DryRun:$DryRun
    Write-Host '  Undo later: powershell -ExecutionPolicy Bypass -File windows\apply-windows-input.ps1 -Restore'

    Write-Host "`n[cs2.exe CPU priority]" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot 'windows\cs2-priority.ps1') -DryRun:$DryRun
    Write-Host '  Undo later: powershell -ExecutionPolicy Bypass -File windows\cs2-priority.ps1 -Restore'
}

if ($doFso) {
    Write-Host "`n[cs2.exe Compatibility tab]" -ForegroundColor Cyan
    $compat = Join-Path $PSScriptRoot 'windows\cs2-compat.ps1'
    if (-not $Fso -and $interactive) {
        & $compat
        Write-Host ''
        Write-Host '  1. Tick (disables fullscreen optimizations, this config''s default)'
        Write-Host '  2. Untick (Windows default)'
        Write-Host '  Enter = leave it as it is'
        do { $pick = (Read-Host '  Choose').Trim() } until ($pick -in '', '1', '2')
        $Fso = @{ '' = $null; '1' = 'Checked'; '2' = 'Unchecked' }[$pick]
    }
    if ($Fso) { & $compat -Fso $Fso -DryRun:$DryRun }
    elseif (-not $interactive) { & $compat }
    else { Write-Host '  Left as it is.' }
}

if ($doAudio) {
    Write-Host "`n[Audio EQ (Equalizer APO)]" -ForegroundColor Cyan
    if (-not $Headphones -and $interactive) {
        Write-Host '  Headphone correction:'
        Write-Host '  1. Logitech G PRO X (wired)'
        Write-Host '  2. Other headphones (footstep EQ only, paste your own from autoeq.app later)'
        Write-Host '  Enter = keep what''s installed (none on a first install)'
        do { $pick = (Read-Host '  Choose').Trim() } until ($pick -in '', '1', '2')
        $Headphones = @{ '' = $null; '1' = 'LogitechGProX'; '2' = 'None' }[$pick]
    }
    $eqArgs = @{ DryRun = $DryRun; InstallMissing = $true }
    if ($Headphones) { $eqArgs.Headphones = $Headphones }
    $global:LASTEXITCODE = 0
    & (Join-Path $PSScriptRoot 'audio\apply-equalizer-apo.ps1') @eqArgs
    $audioOk = $LASTEXITCODE -eq 0
    if ($audioOk) {
        Write-Host '  Undo later: powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -Restore'
        Write-Host "`n[Headset format]" -ForegroundColor Cyan
        & (Join-Path $PSScriptRoot 'audio\set-device-format.ps1') -DryRun:$DryRun
        Write-Host '  Undo later: powershell -ExecutionPolicy Bypass -File audio\set-device-format.ps1 -Restore'
    }
}

# Launch options live in Steam's own files, so they are pasted by hand
if ($doConfig) {
    Write-Host "`n[Launch options]" -ForegroundColor Cyan
    Write-Host "  $launchOptions"
    if (-not $DryRun) {
        try { Set-Clipboard -Value $launchOptions; Write-Host '  Copied to your clipboard.' -ForegroundColor Green } catch {}
    }
    Write-Host '  Paste them in Steam: right-click Counter-Strike 2 > Properties > General > Launch Options.'
    Write-Host "`nDone. Start CS2, press ~ and check the bind table prints with no 'Unknown command' lines." -ForegroundColor Green
} elseif ($doWindows) {
    Write-Host "`nDone." -ForegroundColor Green
} elseif ($doFso) {
    Write-Host "`nDone. Start CS2 to use the new setting." -ForegroundColor Green
} elseif ($doAudio) {
    if ($audioOk) { Write-Host "`nDone. Restart CS2 if it's running. Settings explained in docs\audio-eq.md." -ForegroundColor Green }
    else { Write-Host "`nAudio EQ not applied, see above." -ForegroundColor Yellow }
} else {
    Write-Host "`nDone. Start CS2 to see the changes." -ForegroundColor Green
}
