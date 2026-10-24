# Sets CS2's UI/HUD font to Barlow Semi Condensed (SIL Open Font License, see OFL.txt).
# Copies the fonts into game\csgo\panorama\fonts and adds a marked block to fonts.conf.
# Stratum2/Noto stay as fallback for characters Barlow doesn't have (Cyrillic, CJK).
# Close CS2 first. A CS2 update can reset fonts.conf: just run this again.
# Undo: run with -Restore, or Steam > CS2 > Properties > Installed Files > Verify integrity of game files.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File fonts\apply-font.ps1            # apply
#   powershell -ExecutionPolicy Bypass -File fonts\apply-font.ps1 -DryRun    # only show what would change
#   powershell -ExecutionPolicy Bypass -File fonts\apply-font.ps1 -Restore   # back to the default font

param([switch]$DryRun, [switch]$Restore)

$startMarker = '<!-- cs2-config font start -->'
$endMarker   = '<!-- cs2-config font end -->'

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

if (Get-Process -Name cs2 -ErrorAction SilentlyContinue) {
    if (-not $DryRun) {
        Write-Host 'CS2 is running. Close it first.' -ForegroundColor Red
        exit 1
    }
    Write-Host 'CS2 is running (fine for a dry run, close it before applying).' -ForegroundColor Yellow
}

$game = Find-CS2Game
if (-not $game) {
    Write-Host 'CS2 install not found in any Steam library.' -ForegroundColor Red
    exit 1
}
$fontsDir = Join-Path $game 'csgo\panorama\fonts'
$conf     = Join-Path $fontsDir 'fonts.conf'
$backup   = Join-Path $fontsDir 'fonts.conf.original'
$sources  = Get-ChildItem -Path $PSScriptRoot -Filter 'BarlowSemiCondensed-*.ttf'
Write-Host $fontsDir -ForegroundColor Cyan

if ($Restore) {
    $installed = Get-ChildItem -Path $fontsDir -Filter 'barlowsemicondensed-*.ttf' -ErrorAction SilentlyContinue
    if ($DryRun) {
        Write-Host "  Dry run: would restore fonts.conf and remove $(@($installed).Count) font file(s)."
        exit 0
    }
    if (Test-Path $backup) {
        Copy-Item $backup $conf -Force
        Remove-Item $backup
        Write-Host '  fonts.conf restored.'
    } else {
        Write-Host '  No backup found. Use Steam "Verify integrity of game files" to restore fonts.conf.' -ForegroundColor Yellow
    }
    $installed | Remove-Item
    Write-Host "  Removed $(@($installed).Count) font file(s). Default font is back." -ForegroundColor Green
    exit 0
}

if (-not $sources) {
    Write-Host "No BarlowSemiCondensed-*.ttf next to this script ($PSScriptRoot)." -ForegroundColor Red
    exit 1
}

$text = [System.IO.File]::ReadAllText($conf)
$nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
$alreadyApplied = $text.Contains($startMarker)

$block = @(
    "`t$startMarker",
    "`t<fontpattern>barlowsemicondensed</fontpattern>",
    "`t<match>",
    "`t`t<test name=`"family`" compare=`"contains`"><string>Stratum2</string></test>",
    "`t`t<edit name=`"family`" mode=`"prepend`" binding=`"strong`"><string>Barlow Semi Condensed</string></edit>",
    "`t</match>",
    "`t<match>",
    "`t`t<test name=`"family`" compare=`"contains`"><string>notosans</string></test>",
    "`t`t<edit name=`"family`" mode=`"prepend`" binding=`"strong`"><string>Barlow Semi Condensed</string></edit>",
    "`t</match>",
    "`t$endMarker"
) -join $nl

if ($DryRun) {
    foreach ($src in $sources) { Write-Host "  copy $($src.Name) -> $($src.Name.ToLower())" }
    if ($alreadyApplied) { Write-Host '  fonts.conf already has the font block, no change.' }
    else { Write-Host '  fonts.conf: back up to fonts.conf.original, then add the font block.' }
    Write-Host '  Dry run: nothing written.'
    exit 0
}

foreach ($src in $sources) {
    Copy-Item $src.FullName (Join-Path $fontsDir $src.Name.ToLower()) -Force
}
Write-Host "  Copied $(@($sources).Count) font file(s)."

if ($alreadyApplied) {
    Write-Host '  fonts.conf already has the font block.' -ForegroundColor Green
    exit 0
}

# fonts.conf has no block yet, so it's the game's own version: keep it as the restore point.
[System.IO.File]::WriteAllText($backup, $text)

$anchor = '<fontpattern>notomono-regular</fontpattern>'
if ($text.Contains($anchor)) {
    $text = $text.Replace($anchor, $anchor + $nl + $nl + $block)
} else {
    $text = $text.Replace('</fontconfig>', $block + $nl + $nl + '</fontconfig>')
}
[System.IO.File]::WriteAllText($conf, $text)
Write-Host '  fonts.conf updated (backup: fonts.conf.original). Start CS2 to see the new font.' -ForegroundColor Green
