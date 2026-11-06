# Turns off link power saving on wired network adapters: Green Ethernet, Power Saving Mode and
# Energy-Efficient Ethernet (Realtek/Intel driver keywords, only the ones the adapter has).
# They save a little power on desktops at the cost of link power-state changes; a gaming PC gains nothing from them.
# Interrupt Moderation, offloads and RSS are left alone (no measured CS2 difference).
# Changing them needs admin, so this asks once (UAC), and the adapter restarts: the network drops for a few seconds.
# The first run saves the old values to %LOCALAPPDATA%\cs2-config\network.original.json for -Restore.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File windows\apply-network.ps1            # turn power saving off
#   powershell -ExecutionPolicy Bypass -File windows\apply-network.ps1 -DryRun    # only show what would change
#   powershell -ExecutionPolicy Bypass -File windows\apply-network.ps1 -Restore   # back to the old values

param([switch]$DryRun, [switch]$Restore, [switch]$Elevated)

# Driver registry keywords (language-independent), set to 0 = off where the adapter has them
$keywords = [ordered]@{
    'EnableGreenEthernet' = 'Green Ethernet'
    'PowerSavingMode'     = 'Power Saving Mode'
    '*EEE'                = 'Energy-Efficient Ethernet'
    'AdvancedEEE'         = 'Advanced EEE'
}
$backupDir  = Join-Path $env:LOCALAPPDATA 'cs2-config'
$backupFile = Join-Path $backupDir 'network.original.json'

function Get-EthernetAdapters {
    # NdisPhysicalMedium 14 = 802.3 (wired Ethernet)
    Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.NdisPhysicalMedium -eq 14 }
}

# Exact keyword match: -RegistryKeyword treats '*' as a wildcard, so '*EEE' would also hit 'AdvancedEEE'.
function Get-Property($adapter, $keyword) {
    return Get-NetAdapterAdvancedProperty -Name $adapter.Name -AllProperties -ErrorAction SilentlyContinue |
        Where-Object { $_.RegistryKeyword -eq $keyword } | Select-Object -First 1
}

function Get-Value($adapter, $keyword) {
    $p = Get-Property $adapter $keyword
    if (-not $p) { return $null }
    return [pscustomobject]@{ Value = "$($p.RegistryValue)"; Valid = @($p.ValidRegistryValues) }
}

# The changes to make: on apply, every listed keyword that isn't 0 yet; on restore, the saved values.
function Get-Plan {
    $plan = @()
    if ($Restore) {
        if (-not (Test-Path $backupFile)) { return $plan }
        foreach ($s in (Get-Content $backupFile -Raw | ConvertFrom-Json)) {
            $a = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceGuid -eq $s.InterfaceGuid }
            if (-not $a) { continue }
            $cur = Get-Value $a $s.Keyword
            if ($cur -and $cur.Value -ne "$($s.Value)") {
                $plan += [pscustomobject]@{ Adapter = $a; Keyword = $s.Keyword; From = $cur.Value; To = "$($s.Value)" }
            }
        }
        return $plan
    }
    foreach ($a in Get-EthernetAdapters) {
        foreach ($k in $keywords.Keys) {
            $cur = Get-Value $a $k
            if ($cur -and $cur.Value -ne '0' -and ($cur.Valid.Count -eq 0 -or $cur.Valid -contains '0')) {
                $plan += [pscustomobject]@{ Adapter = $a; Keyword = $k; From = $cur.Value; To = '0' }
            }
        }
    }
    return $plan
}

function Format-State($v) { if ($v -eq '0') { 'off' } elseif ($v -eq '1') { 'on' } else { $v } }

$plan = @(Get-Plan)

# --- Elevated child: make the changes, restart each adapter once ---------------------------------
if ($Elevated) {
    foreach ($group in $plan | Group-Object { $_.Adapter.Name }) {
        foreach ($c in $group.Group) {
            Get-Property $c.Adapter $c.Keyword | Set-NetAdapterAdvancedProperty -RegistryValue $c.To -NoRestart -ErrorAction SilentlyContinue
        }
        Restart-NetAdapter -Name $group.Name -ErrorAction SilentlyContinue
    }
    exit 0
}

# --- Show what changes -----------------------------------------------------------------------------
if ($Restore -and -not (Test-Path $backupFile)) {
    Write-Host "  No backup found ($backupFile), nothing to restore." -ForegroundColor Yellow
    exit 0
}
if (-not $Restore -and -not (Get-EthernetAdapters)) {
    Write-Host '  No wired network adapter found, nothing to change.' -ForegroundColor Green
    exit 0
}
foreach ($c in $plan) {
    $label = if ($keywords.Contains($c.Keyword)) { $keywords[$c.Keyword] } else { $c.Keyword }
    Write-Host ("  {0}: {1,-26} {2} -> {3}" -f $c.Adapter.InterfaceDescription, $label, (Format-State $c.From), (Format-State $c.To)) -ForegroundColor Yellow
}
if ($plan.Count -eq 0) {
    if ($Restore) { Remove-Item $backupFile; Write-Host '  Old values are already back.' -ForegroundColor Green }
    else { Write-Host '  Link power saving is already off, nothing to change.' -ForegroundColor Green }
    exit 0
}
if ($DryRun) { Write-Host '  Dry run: nothing changed (needs admin when applied; the network drops for a few seconds).'; exit 0 }

# Keep the first backup: a later run would otherwise save our own values as "old".
if (-not $Restore -and -not (Test-Path $backupFile)) {
    New-Item -ItemType Directory -Force $backupDir | Out-Null
    @($plan | ForEach-Object { [pscustomobject]@{ InterfaceGuid = $_.Adapter.InterfaceGuid; Adapter = $_.Adapter.InterfaceDescription; Keyword = $_.Keyword; Value = $_.From } }) |
        ConvertTo-Json | Set-Content -Encoding utf8 $backupFile
}

# --- Apply (elevate once) ----------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host '  The network adapter restarts: the connection drops for a few seconds.'
if ($isAdmin) {
    & $PSCommandPath -Elevated -Restore:$Restore
} else {
    Write-Host '  Needs admin: confirm the Windows (UAC) prompt.'
    $psArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Elevated')
    if ($Restore) { $psArgs += '-Restore' }
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $psArgs -Wait -WindowStyle Hidden
    } catch {
        Write-Host '  Cancelled, nothing changed.' -ForegroundColor Yellow
        exit 1
    }
}

# Read back what the driver actually kept
$left = @($plan | Where-Object { (Get-Value $_.Adapter $_.Keyword).Value -ne $_.To })
if ($left.Count -gt 0) {
    foreach ($c in $left) { Write-Host "  Not changed: $($c.Adapter.InterfaceDescription) $($c.Keyword)" -ForegroundColor Red }
    exit 1
}
if ($Restore) {
    Remove-Item $backupFile
    Write-Host '  Old network adapter settings are back.' -ForegroundColor Green
} else {
    Write-Host '  Done: link power saving off. Undo with -Restore.' -ForegroundColor Green
}
exit 0
