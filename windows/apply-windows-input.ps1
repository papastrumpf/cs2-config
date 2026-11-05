# Windows mouse/keyboard settings for CS2 (current user only, no admin needed, applies right away).
#   Mouse:    pointer speed 6/11 and Enhance pointer precision off. Desktop only: CS2 uses raw input,
#             this just keeps the desktop and the game feeling the same.
#   Keyboard: turns off the Sticky Keys (Shift 5x), Filter Keys (right Shift 8 s) and Toggle Keys (Num Lock 5 s)
#             shortcuts, so a popup can't knock you out of fullscreen. SHIFT is the clutch-walk key.
#             The features themselves are left as they are. Key repeat delay/rate isn't touched (no effect in game).
#   Gaming:   Game Mode on, Xbox Game Bar captures and background recording (Game DVR) off. Win+Alt+R clips stop
#             working. Fully applies after you sign out and back in.
# The first run saves your current values to %LOCALAPPDATA%\cs2-config\windows-input.original.json for -Restore.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File windows\apply-windows-input.ps1            # apply
#   powershell -ExecutionPolicy Bypass -File windows\apply-windows-input.ps1 -DryRun    # only show what would change
#   powershell -ExecutionPolicy Bypass -File windows\apply-windows-input.ps1 -Restore   # back to your old values

param([switch]$DryRun, [switch]$Restore)

if (-not ('Cs2Config.WinInput' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
namespace Cs2Config {
    public static class WinInput {
        [StructLayout(LayoutKind.Sequential)] struct FLAGS { public uint cbSize; public uint dwFlags; }
        [StructLayout(LayoutKind.Sequential)] struct FILTERKEYS { public uint cbSize, dwFlags, iWaitMSec, iDelayMSec, iRepeatMSec, iBounceMSec; }
        [DllImport("user32.dll", SetLastError = true)] static extern bool SystemParametersInfo(uint a, uint b, int[] p, uint w);
        [DllImport("user32.dll", SetLastError = true)] static extern bool SystemParametersInfo(uint a, uint b, ref int p, uint w);
        [DllImport("user32.dll", SetLastError = true)] static extern bool SystemParametersInfo(uint a, uint b, IntPtr p, uint w);
        [DllImport("user32.dll", SetLastError = true)] static extern bool SystemParametersInfo(uint a, uint b, ref FLAGS p, uint w);
        [DllImport("user32.dll", SetLastError = true)] static extern bool SystemParametersInfo(uint a, uint b, ref FILTERKEYS p, uint w);
        const uint Save = 0x3; // SPIF_UPDATEINIFILE | SPIF_SENDCHANGE: write to the registry and apply now
        static void Check(bool ok) { if (!ok) throw new Win32Exception(Marshal.GetLastWin32Error()); }

        // Mouse acceleration: { threshold1, threshold2, acceleration }. { 0, 0, 0 } = Enhance pointer precision off.
        public static int[] GetMouse() { var v = new int[3]; Check(SystemParametersInfo(0x03, 0, v, 0)); return v; }
        public static void SetMouse(int[] v) { Check(SystemParametersInfo(0x04, 0, v, Save)); }
        // Pointer speed 1-20, 10 = slider 6/11.
        public static int GetSpeed() { int s = 0; Check(SystemParametersInfo(0x70, 0, ref s, 0)); return s; }
        public static void SetSpeed(int s) { Check(SystemParametersInfo(0x71, 0, (IntPtr)s, Save)); }

        static uint GetFlags(uint get) { var k = new FLAGS { cbSize = 8 }; Check(SystemParametersInfo(get, 8, ref k, 0)); return k.dwFlags; }
        static void SetFlags(uint set, uint f) { var k = new FLAGS { cbSize = 8, dwFlags = f }; Check(SystemParametersInfo(set, 8, ref k, Save)); }
        public static uint GetSticky() { return GetFlags(0x3A); }
        public static void SetSticky(uint f) { SetFlags(0x3B, f); }
        public static uint GetToggle() { return GetFlags(0x34); }
        public static void SetToggle(uint f) { SetFlags(0x35, f); }
        public static uint GetFilter() { var k = new FILTERKEYS { cbSize = 24 }; Check(SystemParametersInfo(0x32, 24, ref k, 0)); return k.dwFlags; }
        public static void SetFilter(uint f) {
            var k = new FILTERKEYS { cbSize = 24 };
            Check(SystemParametersInfo(0x32, 24, ref k, 0));
            k.dwFlags = f;
            Check(SystemParametersInfo(0x33, 24, ref k, Save));
        }
    }
}
'@
}

$api        = [Cs2Config.WinInput]
$on         = 0x1  # *_ON: the feature itself is turned on
$hotkey     = 0x4  # *_HOTKEYACTIVE: the keyboard shortcut that turns it on
$backupDir  = Join-Path $env:LOCALAPPDATA 'cs2-config'
$backupFile = Join-Path $backupDir 'windows-input.original.json'

# Per-user registry DWORDs. $null in a backup means "wasn't set" (Windows default), so -Restore removes it again.
$regSettings = @(
    @{ Label = 'Game Mode';                        Path = 'HKCU:\Software\Microsoft\GameBar';                         Name = 'AutoGameModeEnabled';      Value = 1 },
    @{ Label = 'Game Mode allowed';          Path = 'HKCU:\Software\Microsoft\GameBar';                         Name = 'AllowAutoGameMode';        Value = 1 },
    @{ Label = 'Game DVR';                         Path = 'HKCU:\System\GameConfigStore';                              Name = 'GameDVR_Enabled';          Value = 0 },
    @{ Label = 'Game Bar captures';                Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'AppCaptureEnabled';        Value = 0 },
    @{ Label = 'Background recording';             Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'HistoricalCaptureEnabled'; Value = 0 }
)

function Get-RegValue($s) {
    try { return [int](Get-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction Stop).($s.Name) } catch { return $null }
}

function Get-Current {
    [pscustomobject]@{
        Speed    = $api::GetSpeed()
        Mouse    = @($api::GetMouse())
        Sticky   = $api::GetSticky()
        Filter   = $api::GetFilter()
        Toggle   = $api::GetToggle()
        Registry = @(for ($i = 0; $i -lt $regSettings.Count; $i++) { , (Get-RegValue $regSettings[$i]) })
    }
}

function Format-Speed($s) {
    if ($s -eq 1) { return '1/11' }
    if ($s % 2 -eq 0) { return "$($s / 2 + 1)/11" }
    return "$s (between slider ticks)"
}
function Format-Epp($m) { if ($m[2] -ne 0) { 'on' } else { 'off' } }
function Format-Hotkey($f) { if ($f -band $hotkey) { 'shortcut on' } else { 'shortcut off' } }

function Set-All($t) {
    $api::SetSpeed($t.Speed)
    $api::SetMouse([int[]]$t.Mouse)
    $api::SetSticky([uint32]$t.Sticky)
    $api::SetFilter([uint32]$t.Filter)
    $api::SetToggle([uint32]$t.Toggle)
    # Backups from before these settings existed have no Registry list: leave them alone then
    if ($null -eq $t.Registry) { return }
    for ($i = 0; $i -lt $regSettings.Count; $i++) {
        $s = $regSettings[$i]; $v = $t.Registry[$i]
        if ($null -eq $v) {
            Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue
        } else {
            if (-not (Test-Path $s.Path)) { New-Item -Path $s.Path -Force | Out-Null }
            New-ItemProperty -Path $s.Path -Name $s.Name -Value ([int]$v) -PropertyType DWord -Force | Out-Null
        }
    }
}

function Format-Reg($v) { if ($null -eq $v) { 'not set (Windows default)' } else { "$v" } }

function Show-Changes($from, $to) {
    $rows = @(
        @('Pointer speed',            (Format-Speed $from.Speed),    (Format-Speed $to.Speed)),
        @('Enhance pointer precision', (Format-Epp $from.Mouse),     (Format-Epp $to.Mouse)),
        @('Sticky Keys (Shift 5x)',   (Format-Hotkey $from.Sticky),  (Format-Hotkey $to.Sticky)),
        @('Filter Keys (right Shift 8 s)', (Format-Hotkey $from.Filter), (Format-Hotkey $to.Filter)),
        @('Toggle Keys (Num Lock 5 s)', (Format-Hotkey $from.Toggle), (Format-Hotkey $to.Toggle))
    )
    if ($null -ne $to.Registry) {
        for ($i = 0; $i -lt $regSettings.Count; $i++) {
            $old = if ($null -ne $from.Registry) { $from.Registry[$i] } else { $null }
            $rows += , @("$($regSettings[$i].Label) ($($regSettings[$i].Name))", (Format-Reg $old), (Format-Reg $to.Registry[$i]))
        }
    }
    $changed = 0
    foreach ($r in $rows) {
        if ($r[1] -eq $r[2]) { Write-Host ("  {0,-48} {1} (no change)" -f $r[0], $r[1]) }
        else { Write-Host ("  {0,-48} {1} -> {2}" -f $r[0], $r[1], $r[2]) -ForegroundColor Yellow; $changed++ }
    }
    return $changed
}

$current = Get-Current

if ($Restore) {
    if (-not (Test-Path $backupFile)) {
        Write-Host "  No backup found ($backupFile), nothing to restore." -ForegroundColor Yellow
        exit 0
    }
    $saved = Get-Content $backupFile -Raw | ConvertFrom-Json
    $null = Show-Changes $current $saved
    if ($DryRun) { Write-Host '  Dry run: nothing changed.'; exit 0 }
    Set-All $saved
    Remove-Item $backupFile
    Write-Host '  Your old mouse/keyboard settings are back.' -ForegroundColor Green
    exit 0
}

$target = [pscustomobject]@{
    Speed  = 10
    Mouse  = @(0, 0, 0)
    Sticky = $current.Sticky -band (-bnot $hotkey) -band 0xFFFFFFFFL
    Filter = $current.Filter -band (-bnot $hotkey) -band 0xFFFFFFFFL
    Toggle = $current.Toggle -band (-bnot $hotkey) -band 0xFFFFFFFFL
    Registry = @($regSettings | ForEach-Object { $_.Value })
}

$changed = Show-Changes $current $target
foreach ($f in @(@('Sticky Keys', $current.Sticky), @('Filter Keys', $current.Filter), @('Toggle Keys', $current.Toggle))) {
    if ($f[1] -band $on) { Write-Host "  Note: $($f[0]) itself is turned on. Left as is, only its shortcut is turned off." -ForegroundColor Yellow }
}

if ($changed -eq 0) { Write-Host '  Already set, nothing to change.' -ForegroundColor Green; exit 0 }
if ($DryRun) {
    if (-not (Test-Path $backupFile)) { Write-Host "  Would save your current values to $backupFile" }
    Write-Host '  Dry run: nothing changed.'
    exit 0
}

# Keep the first backup: a second run would otherwise overwrite your real old values with ours.
if (-not (Test-Path $backupFile)) {
    New-Item -ItemType Directory -Force $backupDir | Out-Null
    $current | ConvertTo-Json | Set-Content -Encoding utf8 $backupFile
    Write-Host "  Saved your old values: $backupFile"
}
Set-All $target
Write-Host '  Applied. Undo with -Restore.' -ForegroundColor Green
