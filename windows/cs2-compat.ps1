# Shows and sets the cs2.exe Properties > Compatibility tab (current user, no admin needed).
# This config ticks "Disable fullscreen optimizations" (what most 2026 guides recommend); the Full install does it for you.
# Takes effect the next time CS2 starts. Windows stores the tab in the registry:
#   HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers  (value name = path to cs2.exe)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File windows\cs2-compat.ps1                  # show what's set, change nothing
#   powershell -ExecutionPolicy Bypass -File windows\cs2-compat.ps1 -Fso Checked     # box ticked (fullscreen optimizations disabled, this config's default)
#   powershell -ExecutionPolicy Bypass -File windows\cs2-compat.ps1 -Fso Unchecked   # box unchecked (Windows default)
#   powershell -ExecutionPolicy Bypass -File windows\cs2-compat.ps1 -Clear           # untick everything on the tab
#   add -DryRun to only show what would change

param(
    [ValidateSet('Checked', 'Unchecked')]
    [string]$Fso,
    [switch]$Clear,
    [switch]$DryRun
)

$fsoFlag = 'DISABLEDXMAXIMIZEDWINDOWEDMODE'
$layers  = 'Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'

# What each flag means on the Compatibility tab
$names = @{
    'DISABLEDXMAXIMIZEDWINDOWEDMODE' = 'Disable fullscreen optimizations'
    'RUNASADMIN'                     = 'Run this program as an administrator'
    'HIGHDPIAWARE'                   = 'High DPI override: Application'
    'DPIUNAWARE'                     = 'High DPI override: System'
    'GDIDPISCALING'                  = 'High DPI override: System (Enhanced)'
    'TRANSFORMLEGACYCOLORMANAGED'    = 'Use legacy display ICC color management'
    '256COLOR'                       = 'Reduced color mode (8-bit)'
    '16BITCOLOR'                     = 'Reduced color mode (16-bit)'
    '640X480'                        = 'Run in 640 x 480 screen resolution'
}
$compatModes = 'WIN95', 'WIN98', 'NT4SP5', 'WIN2000', 'WINXPSP2', 'WINXPSP3', 'VISTARTM', 'VISTASP1', 'VISTASP2', 'WIN7RTM', 'WIN8RTM', 'WINSRV03SP1', 'WINSRV08SP1'

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

# Value names are paths, so match them case-insensitively (Explorer may have written a different case)
function Get-Flags($root, $exe) {
    $key = "${root}:\$layers"
    if (-not (Test-Path $key)) { return $null }
    $prop = (Get-ItemProperty $key).PSObject.Properties | Where-Object { $_.Name -ieq $exe } | Select-Object -First 1
    if (-not $prop) { return $null }
    return [pscustomobject]@{ Name = $prop.Name; Flags = @(($prop.Value -split '\s+') | Where-Object { $_ -and $_ -ne '~' }) }
}

function Show-Flags($label, $flags) {
    if (-not $flags -or $flags.Count -eq 0) { Write-Host "  ${label}: nothing ticked (Windows default)"; return }
    Write-Host "  ${label}:"
    foreach ($f in $flags) {
        $u = $f.ToUpper()
        if ($names.ContainsKey($u)) { $text = $names[$u] }
        elseif ($u -in $compatModes) { $text = "Run in compatibility mode for $u" }
        else { $text = "(other flag)" }
        Write-Host ("    {0,-32} {1}" -f $f, $text)
    }
}

$game = Find-CS2Game
if (-not $game) { Write-Host 'CS2 install not found in any Steam library.' -ForegroundColor Red; exit 1 }
$exe = Join-Path $game 'bin\win64\cs2.exe'
if (-not (Test-Path $exe)) { Write-Host "cs2.exe not found: $exe" -ForegroundColor Red; exit 1 }
# Steam reports its path in lowercase: rebuild it with the real folder names, like Explorer writes it
$parts = $exe.Split('\')
$exe = $parts[0].ToUpper()
foreach ($p in $parts[1..($parts.Count - 1)]) {
    $real = Get-ChildItem -LiteralPath "$exe\" -Force | Where-Object { $_.Name -ieq $p } | Select-Object -First 1
    $exe = "$exe\$(if ($real) { $real.Name } else { $p })"
}
Write-Host $exe -ForegroundColor Cyan

$user = Get-Flags 'HKCU' $exe
$all  = Get-Flags 'HKLM' $exe
$userFlags = if ($user) { $user.Flags } else { @() }
Show-Flags 'Your account' $userFlags
if ($all) {
    Show-Flags 'All users (needs admin to change, use "Change settings for all users")' $all.Flags
}

if (-not $Fso -and -not $Clear) {
    $state = if ($userFlags -icontains $fsoFlag -or ($all -and $all.Flags -icontains $fsoFlag)) { 'CHECKED' } else { 'unchecked' }
    Write-Host "  Disable fullscreen optimizations: $state"
    exit 0
}

# Work out the new flag list
if ($Clear) {
    $new = @()
} else {
    $new = @($userFlags | Where-Object { $_ -ine $fsoFlag })
    if ($Fso -eq 'Checked') { $new += $fsoFlag }
}

$before = ($userFlags | ForEach-Object { $_.ToUpper() } | Sort-Object) -join ' '
$after  = ($new       | ForEach-Object { $_.ToUpper() } | Sort-Object) -join ' '
if ($before -eq $after) {
    Write-Host '  Already set, nothing to change.' -ForegroundColor Green
} elseif ($DryRun) {
    Write-Host "  Would change: [$before] -> [$after]"
    Write-Host '  Dry run: nothing changed.'
} else {
    $key = "HKCU:\$layers"
    $name = if ($user) { $user.Name } else { $exe }
    if ($new.Count -eq 0) {
        Remove-ItemProperty -Path $key -Name $name
    } else {
        if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
        Set-ItemProperty -Path $key -Name $name -Value ('~ ' + ($new -join ' ')) -Type String
    }
    Write-Host "  Changed: [$before] -> [$after]. Takes effect the next time CS2 starts." -ForegroundColor Green
}

if ($all -and $all.Flags.Count -gt 0) {
    Write-Host '  Note: flags set for all users still apply. Remove them on the Compatibility tab > Change settings for all users.' -ForegroundColor Yellow
}
