# Installer: copies the config into CS2, applies the video preset and the custom font,
# then puts the launch options on your clipboard. Easiest way: double-click install.bat and pick an option.
# Close CS2 first.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File install.ps1                 # menu: choose what to install
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Mode Full      # no menu: Full, Config, Video, ConfigVideo, Font
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Mode Full -DryRun   # only show what would happen

param(
    [ValidateSet('Full', 'Config', 'Video', 'ConfigVideo', 'Font')]
    [string]$Mode,
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
    Write-Host '  1. Full install (config + video settings + font)   [recommended]'
    Write-Host '  2. Config only'
    Write-Host '  3. Video settings only'
    Write-Host '  4. Config + video settings (no font)'
    Write-Host '  5. Font only'
    Write-Host '  Q. Quit'
    Write-Host ''
    $modes = @{ '1' = 'Full'; '2' = 'Config'; '3' = 'Video'; '4' = 'ConfigVideo'; '5' = 'Font' }
    do {
        $choice = (Read-Host 'Choose 1-5 (Enter = 1)').Trim()
        if ($choice -eq '') { $choice = '1' }
        if ($choice -match '^[qQ]$') { Write-Host 'Nothing installed.'; exit 0 }
    } until ($modes.ContainsKey($choice))
    $Mode = $modes[$choice]
}

$doConfig = $Mode -in 'Full', 'Config', 'ConfigVideo'
$doVideo  = $Mode -in 'Full', 'Video', 'ConfigVideo'
$doFont   = $Mode -in 'Full', 'Font'
Write-Host "`nInstalling: $Mode$(if ($DryRun) { ' (dry run)' })" -ForegroundColor Cyan

if ((Get-Process -Name cs2 -ErrorAction SilentlyContinue) -and -not $DryRun) {
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

# Launch options live in Steam's own files, so they are pasted by hand
if ($doConfig) {
    Write-Host "`n[Launch options]" -ForegroundColor Cyan
    Write-Host "  $launchOptions"
    if (-not $DryRun) {
        try { Set-Clipboard -Value $launchOptions; Write-Host '  Copied to your clipboard.' -ForegroundColor Green } catch {}
    }
    Write-Host '  Paste them in Steam: right-click Counter-Strike 2 > Properties > General > Launch Options.'
    Write-Host "`nDone. Start CS2, press ~ and check the bind table prints with no 'Unknown command' lines." -ForegroundColor Green
} else {
    Write-Host "`nDone. Start CS2 to see the changes." -ForegroundColor Green
}
