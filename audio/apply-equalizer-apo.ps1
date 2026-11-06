# Sets up Equalizer APO for CS2: a headphone correction, a gentle footstep EQ and the ReaComp compressor
# (docs/audio-eq.md). Equalizer APO runs inside Windows' audio engine, not in CS2, and doesn't touch any game
# file (FACEIT/VAC safe).
#
# What it does:
#   - -InstallMissing: downloads and installs what isn't there yet, one admin (UAC) prompt each:
#       Equalizer APO 1.4.2 x64 from SourceForge (SHA-256 checked; its Device Selector opens: tick your headset)
#       ReaPlugs x64 from reaper.fm (Cockos signature checked; silent)
#   - copies cs2-footsteps.txt and your headphone correction (cs2-headphones.txt) into Equalizer APO's config folder
#   - first run: backs up config.txt to config.txt.cs2-original (never overwritten), turns your old lines into
#     comments and adds a marked block with the two files and ReaComp (if installed, skip with -NoCompressor)
#   - later runs refresh the two files and add ReaComp if it's missing; anything you added yourself stays
# Equalizer APO picks up changes right away: CS2 can stay open, no reboot.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -Headphones LogitechGProX -InstallMissing   # everything
#   powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -Headphones None            # only the footstep EQ
#   powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -DryRun    # only show what would change
#   powershell -ExecutionPolicy Bypass -File audio\apply-equalizer-apo.ps1 -Restore   # put config.txt back, remove the files
# Without -Headphones it keeps the headphone file that's already there. -Headphones None also keeps a file you
# pasted yourself (from autoeq.app). -ConfigPath points it at another Equalizer APO config folder.

param(
    [ValidateSet('LogitechGProX', 'None')]
    [string]$Headphones,
    [string]$ConfigPath,
    [switch]$InstallMissing,
    [switch]$NoCompressor,
    [switch]$DryRun,
    [switch]$Restore
)

$startMarker = '# cs2-config start (audio\apply-equalizer-apo.ps1, undo with -Restore)'
$endMarker   = '# cs2-config end'
$offPrefix   = '# cs2-config off: '
$oldHeader   = '# Your previous settings, turned off so they don''t stack with the CS2 EQ (-Restore turns them back on):'
$ownHint     = '# Add your own filters below this line'
$reaComment  = '# ReaComp: threshold -24 dB, ratio 4:1, knee 6 dB, attack 3 ms, release 100 ms, Wet +6 dB (docs/audio-eq.md)'
$headphoneFiles = @{ LogitechGProX = 'headphones\logitech-g-pro-x.txt' }
$placeholder = @(
    '# Headphone correction: none yet.',
    '# Paste your headphones'' ParametricEQ.txt from https://autoeq.app (Equalizer APO format) below these lines.',
    '# The CS2 footstep layer (cs2-footsteps.txt) works without it.'
) -join "`r`n"

# Installers. Equalizer APO isn't code-signed, so its exact file is pinned by hash; ReaPlugs is signed by Cockos.
# SourceForge only redirects to the file for download tools (a browser user agent gets 403 or a web page).
$apoInstaller = @{ Name = 'Equalizer APO 1.4.2 x64'; File = 'EqualizerAPO-x64-1.4.2.exe'; SizeMB = 12
    Url = 'https://sourceforge.net/projects/equalizerapo/files/1.4.2/EqualizerAPO-x64-1.4.2.exe/download'
    Sha256 = '7403BE7427BBE1936A40DDED082829B6E217FC4F5990FEE5CBA501F0AE055AFA'; UserAgent = 'Wget/1.21.4' }
$reaInstaller = @{ Name = 'ReaPlugs 2.36 x64'; File = 'reaplugs236_x64-install.exe'; SizeMB = 1.1
    Url = 'https://www.reaper.fm/reaplugs/reaplugs236_x64-install.exe'
    Signer = 'CN=Cockos Incorporated'; UserAgent = 'Wget/1.21.4' }

$apoKey = 'HKLM:\SOFTWARE\EqualizerAPO'
$customConfigPath = [bool]$ConfigPath

function Read-Text($path) { return [IO.File]::ReadAllText($path) }
function Write-Text($path, $text) { [IO.File]::WriteAllText($path, $text, (New-Object Text.UTF8Encoding $false)) }

# --- Find Equalizer APO ---------------------------------------------------------------------------
function Resolve-ApoPaths {
    $script:installPath = $null
    try { $script:installPath = (Get-ItemProperty -Path $apoKey -ErrorAction Stop).InstallPath } catch {}
    if (-not $customConfigPath) {
        $script:ConfigPath = $null
        try { $script:ConfigPath = (Get-ItemProperty -Path $apoKey -ErrorAction Stop).ConfigPath } catch {}
        if (-not $script:ConfigPath -and $script:installPath) { $script:ConfigPath = Join-Path $script:installPath 'config' }
        if (-not $script:ConfigPath) { $script:ConfigPath = Join-Path $env:ProgramFiles 'EqualizerAPO\config' }
    }
    if (-not $script:installPath) { $script:installPath = Split-Path $script:ConfigPath }
    $script:conf = Join-Path $script:ConfigPath 'config.txt'
    $script:backup = Join-Path $script:ConfigPath 'config.txt.cs2-original'
    $script:hpTarget = Join-Path $script:ConfigPath 'cs2-headphones.txt'
    $script:fsTarget = Join-Path $script:ConfigPath 'cs2-footsteps.txt'
}

# --- Download + install (-InstallMissing) ---------------------------------------------------------
function Get-Installer($spec) {
    $dir = Join-Path $env:TEMP 'cs2-config-audio'
    New-Item -ItemType Directory -Force $dir | Out-Null
    $file = Join-Path $dir $spec.File
    Write-Host "  Downloading $($spec.Name) ($($spec.SizeMB) MB) from $(([Uri]$spec.Url).Host) ..."
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -UseBasicParsing -Uri $spec.Url -OutFile $file -UserAgent $spec.UserAgent -ErrorAction Stop
    } catch {
        Write-Host "  Download failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
    if ($spec.Sha256) {
        $hash = (Get-FileHash $file -Algorithm SHA256).Hash
        if ($hash -ne $spec.Sha256) {
            Remove-Item $file -ErrorAction SilentlyContinue
            Write-Host "  $($spec.File) doesn't match the expected SHA-256, not running it." -ForegroundColor Red
            return $null
        }
    }
    if ($spec.Signer) {
        $sig = Get-AuthenticodeSignature $file
        if ($sig.Status -ne 'Valid' -or -not $sig.SignerCertificate.Subject.StartsWith($spec.Signer)) {
            Remove-Item $file -ErrorAction SilentlyContinue
            Write-Host "  $($spec.File) isn't signed by $($spec.Signer), not running it." -ForegroundColor Red
            return $null
        }
    }
    return $file
}

function Invoke-Installer($file, $name) {
    try {
        $p = Start-Process -FilePath $file -ArgumentList '/S' -Verb RunAs -Wait -PassThru -ErrorAction Stop
    } catch {
        Write-Host "  $name install cancelled (admin prompt declined)." -ForegroundColor Yellow
        return $false
    }
    Remove-Item $file -ErrorAction SilentlyContinue
    if ($p.ExitCode -ne 0) { Write-Host "  $name installer exited with code $($p.ExitCode)." -ForegroundColor Yellow }
    return $true
}

function Find-ReaComp {
    $dirs = @((Join-Path $env:ProgramFiles 'VSTPlugins'), (Join-Path $installPath 'VSTPlugins')) | Where-Object { Test-Path $_ }
    $dll = $dirs | ForEach-Object { Get-ChildItem $_ -Recurse -Filter 'reacomp-standalone.dll' -ErrorAction SilentlyContinue } | Select-Object -First 1
    if ($dll) { return $dll.FullName }
    return $null
}

# The guide's settings, stored the way the Configuration Editor saves them (normalized VST parameters):
# Thresh/Wet/Dry = linear amplitude (-24 dB = 0.0630957, +6 dB = 1.99526), Attack = ms/500, Release = ms/5000,
# Ratio = (ratio-1)/99, Knee = dB/24, "RMS size" 0 = peak. ReaComp's "Limit output" isn't a parameter.
function Get-ReaCompLine($dll) {
    return "VSTPlugin: Library `"$dll`" Thresh 0.0630957 Hipass 0 Attack 0.006 Release 0.02 Ratio 0.030303 Pre-comp 0 resvd 0 Lowpass 1 SignIn 0 AudIn 0 Dry 3.16228e-08 Wet 1.99526 AutoMkUp 0 PreviewF 0 `"RMS size`" 0 Knee 0.25 AutoRel 0 ClsAttk 1 AntiAls 0.0769231"
}

# --- Devices with Equalizer APO on -----------------------------------------------------------------
function Show-Devices {
    $childKey = "$apoKey\Child APOs"
    $guids = @()
    if (Test-Path $childKey) {
        $guids += Get-ChildItem $childKey -ErrorAction SilentlyContinue | ForEach-Object { $_.PSChildName }
        $guids += (Get-Item $childKey).GetValueNames() | Where-Object { $_ -match '^\{?[0-9a-fA-F-]{36}\}?$' }
    }
    $render = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
    $found = 0
    foreach ($g in $guids | Select-Object -Unique) {
        $id = '{' + $g.Trim('{', '}') + '}'
        $dev = Join-Path $render $id
        if (-not (Test-Path $dev)) { continue }   # Child APOs also lists capture devices (microphones)
        $props = Get-ItemProperty (Join-Path $dev 'Properties') -ErrorAction SilentlyContinue
        $name = $props.'{a45c254e-df1c-4efd-8020-67d146a850e0},2'
        $card = $props.'{b3f8fa53-0004-438e-9003-51a46e139bfc},6'
        $label = if ($card) { "$name ($card)" } else { "$name" }
        $state = (Get-ItemProperty $dev -ErrorAction SilentlyContinue).DeviceState
        $fx = Get-ItemProperty (Join-Path $dev 'FxProperties') -ErrorAction SilentlyContinue
        $enhOff = $fx -and $fx.'{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5' -and $fx.'{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5' -ne 0
        $found++
        if ($state -ne 1) {
            Write-Host "  Equalizer APO on: $label (not connected right now)"
        } elseif ($enhOff) {
            Write-Host "  Equalizer APO on: $label, but Windows audio enhancements are OFF for it, so the EQ is skipped." -ForegroundColor Yellow
            Write-Host '    Fix: Settings > System > Sound > this device > Audio enhancements: Device Default Effects (keep Loudness Equalization off).'
        } else {
            Write-Host "  Equalizer APO on: $label" -ForegroundColor Green
        }
    }
    if ($found -eq 0) {
        # DeviceSelector.exe since 1.4, Configurator.exe before
        $selector = @('DeviceSelector.exe', 'Configurator.exe') | ForEach-Object { Join-Path $installPath $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
        if (-not $selector) { $selector = 'Start menu > Equalizer APO > Device Selector' }
        Write-Host '  Equalizer APO isn''t enabled on any playback device yet.' -ForegroundColor Yellow
        Write-Host "    Run $selector, tick the headset you play on, then reboot."
    }
}

function Show-GHub {
    if (Get-Process -Name 'lghub*' -ErrorAction SilentlyContinue) {
        Write-Host '  G HUB (can''t be scripted): headset > Acoustics > preset "Default" (flat) > Update on-board memory,' -ForegroundColor Yellow
        Write-Host '    and leave Surround Sound unticked. Otherwise its EQ and DTS stack on top of this one.' -ForegroundColor Yellow
    }
}

Resolve-ApoPaths

# --- Restore --------------------------------------------------------------------------------------
if ($Restore) {
    if (-not (Test-Path $conf)) { Write-Host '  Equalizer APO not found, nothing to restore.' -ForegroundColor Green; exit 0 }
    $text = Read-Text $conf
    $ours = @($hpTarget, $fsTarget) | Where-Object { Test-Path $_ }
    if (-not (Test-Path $backup) -and -not $text.Contains($startMarker) -and -not $ours) {
        Write-Host '  Nothing to restore: config.txt has no cs2-config block.' -ForegroundColor Green
        exit 0
    }
    if ($DryRun) {
        if (Test-Path $backup) { Write-Host '  would put config.txt.cs2-original back as config.txt' }
        elseif ($text.Contains($startMarker)) { Write-Host '  would remove the cs2-config block from config.txt and turn your old lines back on' }
        foreach ($f in $ours) { Write-Host "  would delete $(Split-Path $f -Leaf)" }
        Write-Host '  Dry run: nothing changed.'
        exit 0
    }
    if (Test-Path $backup) {
        Copy-Item $backup $conf -Force
        Remove-Item $backup
        Write-Host '  config.txt restored from config.txt.cs2-original.'
    } elseif ($text.Contains($startMarker)) {
        $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
        $out = @(); $inBlock = $false
        foreach ($line in $text -split '\r?\n') {
            if ($line -eq $startMarker) { $inBlock = $true; continue }
            if ($inBlock) { if ($line -eq $endMarker) { $inBlock = $false }; continue }
            if ($line -like '# Add ReaComp*' -or $line -eq $ownHint -or $line -eq $oldHeader) { continue }
            if ($line.StartsWith($offPrefix)) { $line = $line.Substring($offPrefix.Length) }
            $out += $line
        }
        while ($out.Count -gt 0 -and $out[$out.Count - 1].Trim() -eq '') { $out = @($out | Select-Object -First ($out.Count - 1)) }
        Write-Text $conf (($out -join $nl) + $nl)
        Write-Host '  No backup found: removed the cs2-config block and turned your old lines back on.'
    }
    $ours | Remove-Item
    Write-Host '  Done. Equalizer APO is back to your old settings (ReaPlugs and Equalizer APO stay installed).' -ForegroundColor Green
    exit 0
}

# --- Apply ----------------------------------------------------------------------------------------
$footstepsSrc = Join-Path $PSScriptRoot 'cs2-footsteps.txt'
if (-not (Test-Path $footstepsSrc)) {
    Write-Host "  cs2-footsteps.txt not found next to this script ($PSScriptRoot)." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $conf)) {
    if (-not $InstallMissing) {
        Write-Host "  Equalizer APO not found (no config.txt in $ConfigPath)." -ForegroundColor Yellow
        Write-Host '  Install it first: https://sourceforge.net/projects/equalizerapo/ (in its Device Selector, tick the device you play on),'
        Write-Host '  or run this with -InstallMissing (installer option 9 does) to download and install it for you.'
        exit 1
    }
    if ($DryRun) {
        Write-Host "  would download $($apoInstaller.Name) ($($apoInstaller.SizeMB) MB, SHA-256 checked) and run its installer (admin prompt, tick your headset)"
        if (-not $NoCompressor -and -not (Find-ReaComp)) { Write-Host "  would download $($reaInstaller.Name) ($($reaInstaller.SizeMB) MB, Cockos signature checked) and install it silently (admin prompt)" }
        Write-Host '  would copy cs2-footsteps.txt and the headphone correction, and write the cs2-config block with ReaComp'
        Write-Host '  Dry run: nothing downloaded or written.'
        exit 0
    }
    $file = Get-Installer $apoInstaller
    if (-not $file) { exit 1 }
    Write-Host '  Installing Equalizer APO: confirm the admin prompt. When its Device Selector opens,' -ForegroundColor Cyan
    Write-Host '  tick ONLY the headset you play on under "Playback devices" and click OK.' -ForegroundColor Cyan
    if (-not (Invoke-Installer $file 'Equalizer APO')) { exit 1 }
    Resolve-ApoPaths
    if (-not (Test-Path $conf)) {
        Write-Host '  Equalizer APO still not found after the installer, stopping.' -ForegroundColor Red
        exit 1
    }
}
Write-Host "  Equalizer APO config: $ConfigPath"

# Which headphone file to write (or keep)
$hpExisting = if (Test-Path $hpTarget) { Read-Text $hpTarget } else { $null }
# A file this script wrote (placeholder or a repo correction) may be replaced; one the user pasted is kept
$knownHp = @($placeholder) + @($headphoneFiles.Values | ForEach-Object { Read-Text (Join-Path $PSScriptRoot $_) }) | ForEach-Object { $_ -replace '\r', '' }
$hpIsOurs = ($null -eq $hpExisting) -or ($knownHp -contains ($hpExisting -replace '\r', ''))
$hpNew = $null; $hpNote = $null
if ($Headphones -eq 'LogitechGProX') {
    $hpNew = Read-Text (Join-Path $PSScriptRoot $headphoneFiles.LogitechGProX)
    $hpNote = 'headphone correction: Logitech G PRO X (wired), AutoEq / crinacle'
} elseif ($Headphones -eq 'None') {
    if ($hpIsOurs) { $hpNew = $placeholder; $hpNote = 'headphone correction: none (paste yours from autoeq.app into cs2-headphones.txt)' }
    else { $hpNote = 'headphone correction: kept the one you pasted into cs2-headphones.txt' }
} elseif ($null -eq $hpExisting) {
    $hpNew = $placeholder; $hpNote = 'headphone correction: none (use -Headphones LogitechGProX, or paste yours from autoeq.app)'
} else {
    $hpNote = 'headphone correction: kept the existing cs2-headphones.txt'
}

$text = Read-Text $conf
$nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
$alreadyApplied = $text.Contains($startMarker)
$hasReaComp = $text -match '(?im)^\s*VSTPlugin:.*reacomp'
$reaDll = Find-ReaComp
$wantReaComp = -not $NoCompressor -and -not $hasReaComp

if ($DryRun) {
    Write-Host '  would copy cs2-footsteps.txt'
    Write-Host "  would set $hpNote"
    if ($alreadyApplied) { Write-Host '  config.txt already has the cs2-config block, kept.' }
    else { Write-Host '  config.txt: back up to config.txt.cs2-original, turn the current lines into comments, add the cs2-config block.' }
    if ($hasReaComp) { Write-Host '  ReaComp is already in config.txt, kept.' }
    elseif ($wantReaComp -and $reaDll) { Write-Host '  would add ReaComp with the guide''s settings' }
    elseif ($wantReaComp -and $InstallMissing) { Write-Host "  would download $($reaInstaller.Name) ($($reaInstaller.SizeMB) MB, Cockos signature checked), install it silently (admin prompt) and add ReaComp" }
    elseif ($wantReaComp) { Write-Host '  ReaComp not installed: run with -InstallMissing to add the compressor.' }
    Write-Host '  Dry run: nothing downloaded or written.'
    Show-Devices
    Show-GHub
    exit 0
}

try {
    Copy-Item $footstepsSrc $fsTarget -Force -ErrorAction Stop
    if ($null -ne $hpNew) { Write-Text $hpTarget $hpNew }
} catch [System.UnauthorizedAccessException] {
    Write-Host "  No write access to $ConfigPath. Run this from an admin PowerShell, or reinstall Equalizer APO (its installer makes this folder writable)." -ForegroundColor Red
    exit 1
} catch {
    Write-Host "  Couldn't write to $ConfigPath`: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host "  Copied cs2-footsteps.txt, $hpNote"

# ReaComp: install ReaPlugs if asked, then add the plugin line inside the block
if ($wantReaComp -and -not $reaDll -and $InstallMissing) {
    $file = Get-Installer $reaInstaller
    if ($file) {
        Write-Host '  Installing ReaPlugs: confirm the admin prompt.' -ForegroundColor Cyan
        if (Invoke-Installer $file 'ReaPlugs') { $reaDll = Find-ReaComp }
    }
}
$reaLines = @()
if ($wantReaComp -and $reaDll) { $reaLines = @($reaComment, (Get-ReaCompLine $reaDll)) }

if (-not $alreadyApplied) {
    # No block yet, so this is the user's own config: keep it as the restore point
    if (-not (Test-Path $backup)) { Write-Text $backup $text }
    $old = New-Object System.Collections.Generic.List[string]
    foreach ($line in $text -split '\r?\n') {
        if ($line.Trim() -eq '' -or $line.TrimStart().StartsWith('#')) { $old.Add($line) } else { $old.Add($offPrefix + $line) }
    }
    while ($old.Count -gt 0 -and $old[$old.Count - 1].Trim() -eq '') { $old.RemoveAt($old.Count - 1) }
    $lines = @()
    if ($old.Count -gt 0) {
        $lines += $oldHeader
        $lines += $old
        $lines += ''
    }
    $lines += $startMarker
    $lines += 'Include: cs2-headphones.txt'
    $lines += 'Include: cs2-footsteps.txt'
    $lines += $reaLines
    $lines += $endMarker
    $lines += $ownHint
    Write-Text $conf (($lines -join $nl) + $nl)
    Write-Host "  config.txt updated (backup: config.txt.cs2-original)$(if ($reaLines) { ', ReaComp added' })."
} elseif ($reaLines) {
    # Block already there: only slot ReaComp in before its end marker
    $out = foreach ($line in $text -split '\r?\n') { if ($line -eq $endMarker) { $reaLines }; $line }
    Write-Text $conf (($out -join $nl).TrimEnd() + $nl)
    Write-Host '  config.txt already had the cs2-config block: added ReaComp to it.'
} else {
    Write-Host '  config.txt already has the cs2-config block (left as it is).'
}
Write-Host '  Done. Equalizer APO applies it right away, CS2 can stay open.' -ForegroundColor Green
if ($hasReaComp -or $reaLines) { Write-Host '  ReaComp compressor: on.' -ForegroundColor Green }
elseif ($NoCompressor) { Write-Host '  ReaComp compressor: skipped (-NoCompressor).' }
else { Write-Host '  ReaComp compressor: not installed (run with -InstallMissing, installer option 9 does).' -ForegroundColor Yellow }
Show-Devices
Show-GHub
