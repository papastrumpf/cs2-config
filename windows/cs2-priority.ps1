# Starts cs2.exe at High CPU priority every time, through Windows' own per-program setting:
#   HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\cs2.exe\PerfOptions
#   CpuPriorityClass = 3 (High). Not Realtime: that can starve mouse/keyboard input and audio.
# Writing to HKLM needs admin, so this asks for it once (UAC). Takes effect the next time CS2 starts.
# Expect a small gain at most: CS2 is usually the only busy program anyway.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File windows\cs2-priority.ps1            # set High
#   powershell -ExecutionPolicy Bypass -File windows\cs2-priority.ps1 -DryRun    # only show what would change
#   powershell -ExecutionPolicy Bypass -File windows\cs2-priority.ps1 -Restore   # back to Windows' normal priority

param([switch]$DryRun, [switch]$Restore)

$exeKey  = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\cs2.exe'
$perfKey = "$exeKey\PerfOptions"
$names   = @{ 1 = 'Idle'; 2 = 'Normal'; 3 = 'High'; 5 = 'Below normal'; 6 = 'Above normal' }

function Get-Priority {
    try { return [int](Get-ItemProperty -Path $perfKey -Name CpuPriorityClass -ErrorAction Stop).CpuPriorityClass } catch { return $null }
}
function Format-Priority($v) {
    if ($null -eq $v) { return 'Normal (Windows default)' }
    if ($names.ContainsKey($v)) { return $names[$v] }
    return "class $v"
}

$current = Get-Priority
$want = if ($Restore) { $null } else { 3 }
Write-Host "  cs2.exe CPU priority: $(Format-Priority $current) -> $(Format-Priority $want)"

if ($current -eq $want) { Write-Host '  Already set, nothing to change.' -ForegroundColor Green; exit 0 }
if ($DryRun) { Write-Host '  Dry run: nothing changed (needs admin when applied).'; exit 0 }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host '  Needs admin: confirm the Windows (UAC) prompt.'
    $psArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    if ($Restore) { $psArgs += '-Restore' }
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $psArgs -Wait -WindowStyle Hidden
    } catch {
        Write-Host '  Cancelled, nothing changed.' -ForegroundColor Yellow
        exit 1
    }
    if ((Get-Priority) -eq $want) {
        Write-Host "  Done: $(Format-Priority $want). Takes effect the next time CS2 starts." -ForegroundColor Green
        exit 0
    }
    Write-Host '  Failed, nothing changed.' -ForegroundColor Red
    exit 1
}

if ($Restore) {
    Remove-ItemProperty -Path $perfKey -Name CpuPriorityClass -ErrorAction SilentlyContinue
    # Remove the keys too if nothing else is in them (they didn't exist before this script)
    foreach ($k in $perfKey, $exeKey) {
        if ((Test-Path $k) -and -not (Get-Item $k).GetValueNames() -and -not (Get-ChildItem $k)) { Remove-Item $k }
    }
} else {
    if (-not (Test-Path $perfKey)) { New-Item -Path $perfKey -Force | Out-Null }
    New-ItemProperty -Path $perfKey -Name CpuPriorityClass -Value 3 -PropertyType DWord -Force | Out-Null
}
Write-Host "  Done: $(Format-Priority $want). Takes effect the next time CS2 starts." -ForegroundColor Green
