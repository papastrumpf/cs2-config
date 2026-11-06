# Sets the default playback device (your headset) to 48000 Hz, the same as Settings > System > Sound >
# device > Format. Only the sample rate changes: bit depth and channels stay as they are, and it only switches
# if the device supports 48 kHz at that bit depth. Current user, no admin needed.
# The device resets for a second when the format changes: a running game may need a restart to use it.
# The first run saves the old rate to %LOCALAPPDATA%\cs2-config\audio-format.original.json for -Restore.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File audio\set-device-format.ps1            # 48 kHz
#   powershell -ExecutionPolicy Bypass -File audio\set-device-format.ps1 -DryRun    # only show what would change
#   powershell -ExecutionPolicy Bypass -File audio\set-device-format.ps1 -Restore   # back to the old rate

param([switch]$DryRun, [switch]$Restore, [int]$SampleRate = 48000)

$backupDir  = Join-Path $env:LOCALAPPDATA 'cs2-config'
$backupFile = Join-Path $backupDir 'audio-format.original.json'

if (-not ('Cs2Config.AudioFormat' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace Cs2Config {
    // IPolicyConfig: the undocumented interface Windows' own Sound settings use to change a device's format.
    [ComImport, Guid("870af99c-171d-4f9e-af0d-e63df40c2bc9")] class PolicyConfigClient { }
    [ComImport, Guid("f8679f50-850a-41cf-9c72-430f290290c8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IPolicyConfig {
        [PreserveSig] int GetMixFormat([MarshalAs(UnmanagedType.LPWStr)] string id, out IntPtr format);
        [PreserveSig] int GetDeviceFormat([MarshalAs(UnmanagedType.LPWStr)] string id, int useDefault, out IntPtr format);
        [PreserveSig] int ResetDeviceFormat([MarshalAs(UnmanagedType.LPWStr)] string id);
        [PreserveSig] int SetDeviceFormat([MarshalAs(UnmanagedType.LPWStr)] string id, IntPtr endpointFormat, IntPtr mixFormat);
    }
    [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorCo { }
    [ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMMDeviceEnumerator {
        [PreserveSig] int EnumAudioEndpoints(int dataFlow, int stateMask, out IntPtr devices);
        [PreserveSig] int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice device);
        [PreserveSig] int GetDevice([MarshalAs(UnmanagedType.LPWStr)] string id, out IMMDevice device);
    }
    [ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMMDevice {
        [PreserveSig] int Activate(ref Guid iid, int clsCtx, IntPtr activationParams, [MarshalAs(UnmanagedType.IUnknown)] out object iface);
        [PreserveSig] int OpenPropertyStore(int access, out IntPtr store);
        [PreserveSig] int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);
    }
    [ComImport, Guid("1CB9AD4C-DBFA-4c32-B178-C2F568A703B2"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IAudioClient {
        [PreserveSig] int Initialize(int shareMode, int flags, long bufferDuration, long periodicity, IntPtr format, IntPtr sessionGuid);
        [PreserveSig] int GetBufferSize(out uint frames);
        [PreserveSig] int GetStreamLatency(out long latency);
        [PreserveSig] int GetCurrentPadding(out uint padding);
        [PreserveSig] int IsFormatSupported(int shareMode, IntPtr format, IntPtr closestMatch);
    }

    public static class AudioFormat {
        static void Check(int hr, string what) { if (hr != 0) throw new COMException(what + " failed", hr); }

        public static string DefaultRenderId() {
            var e = (IMMDeviceEnumerator)new MMDeviceEnumeratorCo();
            IMMDevice d; Check(e.GetDefaultAudioEndpoint(0, 0, out d), "GetDefaultAudioEndpoint");   // eRender, eConsole
            string id; Check(d.GetId(out id), "GetId");
            return id;
        }

        static byte[] Copy(IntPtr p) {
            int size = 18 + Marshal.ReadInt16(p, 16);   // WAVEFORMATEX + cbSize extra bytes
            var b = new byte[size]; Marshal.Copy(p, b, 0, size); Marshal.FreeCoTaskMem(p);
            return b;
        }
        public static byte[] GetDeviceFormat(string id) {
            IntPtr p; Check(((IPolicyConfig)new PolicyConfigClient()).GetDeviceFormat(id, 0, out p), "GetDeviceFormat");
            return Copy(p);
        }
        public static byte[] GetMixFormat(string id) {
            IntPtr p; Check(((IPolicyConfig)new PolicyConfigClient()).GetMixFormat(id, out p), "GetMixFormat");
            return Copy(p);
        }

        // 0 = supported, 0x88890008 = unsupported, 0x8889000E = exclusive mode not allowed (can't check)
        public static int IsSupported(string id, byte[] format) {
            var e = (IMMDeviceEnumerator)new MMDeviceEnumeratorCo();
            IMMDevice d; Check(e.GetDevice(id, out d), "GetDevice");
            var iid = new Guid("1CB9AD4C-DBFA-4c32-B178-C2F568A703B2");
            object o; Check(d.Activate(ref iid, 23, IntPtr.Zero, out o), "Activate");   // CLSCTX_ALL
            var client = (IAudioClient)o;
            IntPtr p = Marshal.AllocCoTaskMem(format.Length);
            try { Marshal.Copy(format, 0, p, format.Length); return client.IsFormatSupported(1, p, IntPtr.Zero); }   // exclusive
            finally { Marshal.FreeCoTaskMem(p); }
        }

        public static int SetFormat(string id, byte[] endpoint, byte[] mix) {
            IntPtr pe = Marshal.AllocCoTaskMem(endpoint.Length), pm = Marshal.AllocCoTaskMem(mix.Length);
            try {
                Marshal.Copy(endpoint, 0, pe, endpoint.Length); Marshal.Copy(mix, 0, pm, mix.Length);
                return ((IPolicyConfig)new PolicyConfigClient()).SetDeviceFormat(id, pe, pm);
            } finally { Marshal.FreeCoTaskMem(pe); Marshal.FreeCoTaskMem(pm); }
        }
    }
}
'@
}
$api = [Cs2Config.AudioFormat]

function Get-Rate([byte[]]$f) { return [BitConverter]::ToUInt32($f, 4) }
function Get-Bits([byte[]]$f) { return [BitConverter]::ToUInt16($f, 14) }
function Set-Rate([byte[]]$f, [int]$rate) {
    $c = [byte[]]$f.Clone()
    $blockAlign = [BitConverter]::ToUInt16($c, 12)
    [BitConverter]::GetBytes([uint32]$rate).CopyTo($c, 4)                 # nSamplesPerSec
    [BitConverter]::GetBytes([uint32]($rate * $blockAlign)).CopyTo($c, 8)  # nAvgBytesPerSec
    return , $c
}
function Get-DeviceName($id) {
    $guid = [regex]::Match($id, '\{[0-9a-fA-F-]{36}\}$').Value
    $props = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\$guid\Properties" -ErrorAction SilentlyContinue
    $name = $props.'{a45c254e-df1c-4efd-8020-67d146a850e0},2'; $card = $props.'{b3f8fa53-0004-438e-9003-51a46e139bfc},6'
    if ($card) { return "$name ($card)" }
    if ($name) { return $name }
    return $id
}

# Changes only the sample rate of a device, after checking the device supports it. Returns $true when the
# device ends up at $rate.
function Set-DeviceRate($id, [int]$rate) {
    $endpoint = $api::GetDeviceFormat($id)
    $mix = $api::GetMixFormat($id)
    $newEndpoint = Set-Rate $endpoint $rate
    $newMix = Set-Rate $mix $rate
    $hr = $api::IsSupported($id, $newEndpoint)
    if ($hr -eq [int]0x88890008) {
        Write-Host "  The device doesn't support $rate Hz at $(Get-Bits $endpoint)-bit, left as it is." -ForegroundColor Yellow
        return $false
    }
    $hr = $api::SetFormat($id, $newEndpoint, $newMix)
    if ($hr -ne 0) {
        Write-Host ("  Windows refused the format change (0x{0:X8}), left as it is." -f $hr) -ForegroundColor Yellow
        return $false
    }
    return (Get-Rate ($api::GetDeviceFormat($id))) -eq $rate
}

try {
    if ($Restore) {
        if (-not (Test-Path $backupFile)) { Write-Host "  No backup found ($backupFile), nothing to restore." -ForegroundColor Yellow; exit 0 }
        $saved = Get-Content $backupFile -Raw | ConvertFrom-Json
        $now = Get-Rate ($api::GetDeviceFormat($saved.DeviceId))
        Write-Host "  $($saved.Name): $now Hz -> $($saved.SampleRate) Hz"
        if ($DryRun) { Write-Host '  Dry run: nothing changed.'; exit 0 }
        if ($now -eq $saved.SampleRate -or (Set-DeviceRate $saved.DeviceId $saved.SampleRate)) {
            Remove-Item $backupFile
            Write-Host '  Old format is back.' -ForegroundColor Green
            exit 0
        }
        exit 1
    }

    $id = $api::DefaultRenderId()
    $name = Get-DeviceName $id
    $format = $api::GetDeviceFormat($id)
    $rate = Get-Rate $format
    Write-Host "  $name`: $(Get-Bits $format)-bit, $rate Hz -> $SampleRate Hz"
    if ($rate -eq $SampleRate) { Write-Host '  Already set, nothing to change.' -ForegroundColor Green; exit 0 }
    if ($DryRun) {
        $hr = $api::IsSupported($id, (Set-Rate $format $SampleRate))
        if ($hr -eq [int]0x88890008) { Write-Host "  The device doesn't support $SampleRate Hz at this bit depth: would leave it." -ForegroundColor Yellow }
        Write-Host '  Dry run: nothing changed.'
        exit 0
    }
    # Keep the first backup: a later run would otherwise save our own value as "old".
    if (-not (Test-Path $backupFile)) {
        New-Item -ItemType Directory -Force $backupDir | Out-Null
        [pscustomobject]@{ DeviceId = $id; Name = $name; SampleRate = $rate } | ConvertTo-Json | Set-Content -Encoding utf8 $backupFile
    }
    if (Set-DeviceRate $id $SampleRate) {
        Write-Host "  Done: $SampleRate Hz. Restart CS2 if it's running. Undo with -Restore." -ForegroundColor Green
        exit 0
    }
    exit 1
} catch {
    Write-Host "  Couldn't read or change the audio format: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '  Set it by hand: Settings > System > Sound > your headset > Format > 48000 Hz.'
    exit 1
}
