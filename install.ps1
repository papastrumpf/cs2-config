# One-click install: copies the config into CS2, applies the video preset and the custom font,
# then puts the launch options on your clipboard. Easiest way: double-click install.bat.
# Close CS2 first.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File install.ps1                        # install everything
#   powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun                # only show what would happen
#   powershell -ExecutionPolicy Bypass -File install.ps1 -SkipVideo -SkipFont   # config files only

param([switch]$DryRun, [switch]$SkipVideo, [switch]$SkipFont)

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

if ((Get-Process -Name cs2 -ErrorAction SilentlyContinue) -and -not $DryRun) {
    Write-Host 'CS2 is running. Close it and run the installer again.' -ForegroundColor Red
    exit 1
}

$game = Find-CS2Game
if (-not $game) {
    Write-Host 'CS2 install not found in any Steam library.' -ForegroundColor Red
    exit 1
}
$cfg = Join-Path $game 'csgo\cfg'

# 1. Config files
Write-Host "`n[1/4] Config files -> $cfg" -ForegroundColor Cyan
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

# 2. Video preset
Write-Host "`n[2/4] Video settings" -ForegroundColor Cyan
if ($SkipVideo) { Write-Host '  Skipped.' }
else { & (Join-Path $PSScriptRoot 'video\apply-video-settings.ps1') -DryRun:$DryRun }

# 3. Custom font
Write-Host "`n[3/4] Custom font" -ForegroundColor Cyan
if ($SkipFont) { Write-Host '  Skipped.' }
else { & (Join-Path $PSScriptRoot 'fonts\apply-font.ps1') -DryRun:$DryRun }

# 4. Launch options (Steam keeps them in its own files, so they are pasted by hand)
Write-Host "`n[4/4] Launch options" -ForegroundColor Cyan
Write-Host "  $launchOptions"
if (-not $DryRun) {
    try { Set-Clipboard -Value $launchOptions; Write-Host '  Copied to your clipboard.' -ForegroundColor Green } catch {}
}
Write-Host '  Paste them in Steam: right-click Counter-Strike 2 > Properties > General > Launch Options.'

Write-Host "`nDone. Start CS2, press ~ and check the bind table prints with no 'Unknown command' lines." -ForegroundColor Green
