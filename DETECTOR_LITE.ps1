# ============================================================================
# DETECTOR LITE - Browser & Mods Scanner (From READINESS.exe)
# ============================================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = 'Detector Lite v2.0'
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host
function Show-Logo {
    Write-Host ""
    Write-Host ""
    Write-Centered "######= #######= #####= ######= ##=###=   ##=#######=#######=#######=" -color DarkGray
    Write-Centered "##===##=##======##===##=##===##=##|####=  ##|##======##======##======" -color DarkGray
    Write-Centered "######==#####=  #######|##|  ##|##|##=##= ##|#####=  #######=#######=" -color Gray
    Write-Centered "##===##=##====  ##===##|##|  ##|##|##|=##=##|##====  =====##|=====##|" -color Gray
    Write-Centered "##|  ##|#######=##|  ##|######==##|##| =####|#######=#######|#######|" -color White
    Write-Centered "===  ==============  ========== ======  =============================" -color White
    Write-Host ""
    Write-Host ""
    Write-Centered "=======================================================" -color DarkGray
    Write-Centered "|         Created by: IwTu              v1.7.4       |" -color Gray
    Write-Centered "=======================================================" -color DarkGray
    Write-Host ""
    Write-FullLine -char "-" -color DarkGray
    Write-Host ""
}

Show-Logo

while ($true) {
    Write-Host ""
    Write-Host "Select scan mode:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [1] Scan javaw.exe memory" -ForegroundColor White
    Write-Host "  [2] Check java.exe JAR files" -ForegroundColor White
    Write-Host "  [3] Scan mods folder" -ForegroundColor White
    Write-Host "  [4] Check suspicious DLL" -ForegroundColor White
    Write-Host "  [5] SafeMode Detection" -ForegroundColor White
    Write-Host "  [6] Browser History Scanner" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "Enter choice"

if ($choice -eq "1") {
    Clear-Host
    Show-Logo
    
    $totalFound = 0
    
    Write-Host ""
    Write-Host "  =============================================================================" -ForegroundColor Gray
    Write-Host "  |                         MEMORY SCANNER                                    |" -ForegroundColor Gray
    Write-Host "  =============================================================================" -ForegroundColor Gray
    Write-Host ""
    
    # Красивая анимация загрузки
    $barLength = 50
    Write-Host "  Initializing... " -NoNewline -ForegroundColor Gray
    for ($i = 0; $i -le $barLength; $i++) {
        $percent = [math]::Round(($i / $barLength) * 100)
        $bar = "#" * $i + "." * ($barLength - $i)
        Write-Host "`r  Initializing... [$bar] $percent%" -NoNewline -ForegroundColor Gray
        Start-Sleep -Milliseconds 30
    }
    # Очищаем строку загрузки
    Write-Host "`r$(' ' * 80)" -NoNewline
    Write-Host "`r" -NoNewline
    Write-Host ""
    Start-Sleep -Milliseconds 200
    
    Write-Host ""
    Write-Host "  [~] Scanning javaw.exe processes..." -ForegroundColor Gray
    
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    if ($javawProcesses) {
        Write-Host "    Found $($javawProcesses.Count) javaw.exe process(es)" -ForegroundColor Gray
        Write-Host ""
        
        Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public class MemScanner {
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);
    
    [DllImport("kernel32.dll")]
    public static extern bool ReadProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint dwSize, out uint lpNumberOfBytesRead);
    
    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr hObject);
    
    [DllImport("kernel32.dll")]
    public static extern int VirtualQueryEx(IntPtr hProcess, IntPtr lpAddress, out MEMORY_BASIC_INFORMATION lpBuffer, uint dwLength);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct MEMORY_BASIC_INFORMATION {
        public IntPtr BaseAddress;
        public IntPtr AllocationBase;
        public uint AllocationProtect;
        public IntPtr RegionSize;
        public uint State;
        public uint Protect;
        public uint Type;
    }
    
    public static string Scan(int pid) {
        IntPtr hProcess = OpenProcess(0x1F0FFF, false, pid);
        if (hProcess == IntPtr.Zero) return "ERROR:OpenProcess";
        
        string[] sigs = new string[] {
            "bZGqnxkxvcKXYkV]S]",
            "sXNEdnSpUdmg[I[]RKq",
            "HXEDpHbpRJCyiNK\\P",
            "Liminar-free-1.0.0",
            "doomsdayloader",
            "DoomsdayLoader",
            "doom.client",
            "doomsdayclient",
            "LiminarClient",
            "LiminarLoader",
            "LiminarGhost",
            "Killaura",
            "KillAura",
            "TriggerBot",
            "Triggerbot",
            "Xray",
            "XRay",
            "X-Ray"
        };
        
        try {
            IntPtr addr = IntPtr.Zero;
            MEMORY_BASIC_INFORMATION mbi;
            int regions = 0;
            
            while (VirtualQueryEx(hProcess, addr, out mbi, (uint)Marshal.SizeOf(typeof(MEMORY_BASIC_INFORMATION))) != 0) {
                if (mbi.State == 0x1000) {
                    long size = mbi.RegionSize.ToInt64();
                    if (size > 0 && size < 50000000) {
                        byte[] buffer = new byte[size];
                        uint bytesRead;
                        
                        if (ReadProcessMemory(hProcess, mbi.BaseAddress, buffer, (uint)size, out bytesRead)) {
                            regions++;
                            string content = Encoding.ASCII.GetString(buffer, 0, (int)bytesRead);
                            
                            foreach (string sig in sigs) {
                                if (content.Contains(sig)) {
                                    CloseHandle(hProcess);
                                    return "FOUND:" + sig;
                                }
                            }
                        }
                    }
                }
                
                long next = mbi.BaseAddress.ToInt64() + mbi.RegionSize.ToInt64();
                if (next <= mbi.BaseAddress.ToInt64() || next > 0x7FFFFFFFFFFF) break;
                addr = new IntPtr(next);
            }
            
            CloseHandle(hProcess);
            return "CLEAN:Scanned_" + regions + "_regions";
        } catch (Exception ex) {
            CloseHandle(hProcess);
            return "ERROR:" + ex.Message;
        }
    }
}
'@ -ErrorAction SilentlyContinue
        
        foreach ($proc in $javawProcesses) {
            # Получаем информацию о процессе
            $procInfo = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
            $memoryMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
            $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
            $startTime = $proc.StartTime.ToString("HH:mm:ss")
            
            # Пропускаем javaw с памятью < 1 GB
            if ($memoryGB -lt 1) {
                continue
            }
            
            Write-Host "  ┌-----------------------------------------------------------------" -ForegroundColor DarkGray
            Write-Host "  │ [PID $($proc.Id)] javaw.exe | $memoryMB MB | Started: $startTime" -ForegroundColor White
            Write-Host "  └-----------------------------------------------------------------" -ForegroundColor DarkGray
            
            # Анимация сканирования
            $spinnerFrames = @("|", "/", "-", "\")
            Write-Host "    [" -NoNewline -ForegroundColor Gray
            for ($i = 0; $i -lt 8; $i++) {
                Write-Host "$($spinnerFrames[$i % 4])" -NoNewline -ForegroundColor Gray
                Start-Sleep -Milliseconds 100
                Write-Host "`b" -NoNewline
            }
            Write-Host "√] Scanning..." -ForegroundColor Gray
            
            try {
                $result = [MemScanner]::Scan($proc.Id)
                
                Write-Host "`r                                        `r" -NoNewline
                
                if ($result -like "FOUND:*") {
                    $sig = $result.Replace("FOUND:", "")
                    Write-Host "    [!] DETECTED: $sig" -ForegroundColor Red
                    $totalFound++
                }
                elseif ($result -like "CLEAN:*") {
                    Write-Host "    [√] Clean - No threats detected" -ForegroundColor DarkGray
                }
                elseif ($result -like "ERROR:*") {
                    $err = $result.Replace("ERROR:", "")
                    Write-Host "    [?] $err" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "    [?] Scan failed" -ForegroundColor Yellow
            }
            Write-Host ""
        }
        
    } else {
        Write-Host "    No javaw.exe processes running" -ForegroundColor Gray
    }
    
    # Проверка на SafeMode - двухуровневая детекция
    Write-Host ""
    
    Write-Host ""
    if ($totalFound -eq 0) {
        Write-Host "[+] Scan complete! Nothing detected." -ForegroundColor Green
    } else {
        Write-Host "[!] Scan complete! Found $totalFound issue(s)." -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "Press Enter to return to menu"
    Clear-Host
    Show-Logo
    
} elseif ($choice -eq "2") {
    Clear-Host
    Show-Logo
    Write-Host "                   JAR File Checker Mode" -ForegroundColor Gray
    Write-Host ""
    
    $totalFound = 0
    
    Write-Host "[~] Checking running java.exe processes..." -ForegroundColor Gray
    
    $javaProcesses = Get-Process -Name java -ErrorAction SilentlyContinue
    $jarFiles = @()
    
    if ($javaProcesses) {
        Write-Host "    Found $($javaProcesses.Count) java.exe process(es)" -ForegroundColor Gray
        
        foreach ($proc in $javaProcesses) {
            try {
                $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
                
                if ($commandLine -match '\.jar') {
                    if ($commandLine -match '([A-Za-z]:[^\s]+\.jar)') {
                        $jarPath = $matches[1] -replace '"', ''
                        if (-not ($jarFiles -contains $jarPath)) {
                            $jarFiles += $jarPath
                        }
                    }
                }
            } catch { }
        }
    } else {
        Write-Host "    No running java.exe processes" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "[~] Checking recent java.exe executions..." -ForegroundColor Gray
    
    # Get recent java.exe from Windows Event Log
    try {
        $recentJava = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Shell-Core/Operational'; ID=9707} -MaxEvents 100 -ErrorAction SilentlyContinue | 
            Where-Object { $_.Message -match 'java\.exe' -and $_.Message -match '\.jar' }
        
        if ($recentJava) {
            Write-Host "    Found recent java.exe executions in Event Log" -ForegroundColor Gray
            
            foreach ($event in $recentJava) {
                if ($event.Message -match '([A-Z]:\\[^\\x00\r\n]+\.jar)') {
                    $jarPath = $matches[1]
                    if ((Test-Path $jarPath) -and (-not ($jarFiles -contains $jarPath))) {
                        $jarFiles += $jarPath
                    }
                }
            }
        }
    } catch { }
    
    # Check Prefetch directory
    Write-Host ""
    Write-Host "[~] Checking Prefetch files..." -ForegroundColor Gray
    
    
    $prefetchPath = "C:\Windows\Prefetch"
    if (Test-Path $prefetchPath) {
        try {
            $javaPrefetch = Get-ChildItem -Path $prefetchPath -Filter "JAVA*.pf" -ErrorAction SilentlyContinue | 
                Sort-Object LastWriteTime -Descending | Select-Object -First 5
            
            if ($javaPrefetch) {
                Write-Host "    Found $($javaPrefetch.Count) java Prefetch file(s)" -ForegroundColor Gray
                
                foreach ($pf in $javaPrefetch) {
                    try {
                        $content = [System.IO.File]::ReadAllBytes($pf.FullName)
                        $textUnicode = [System.Text.Encoding]::Unicode.GetString($content)
                        $textAscii = [System.Text.Encoding]::ASCII.GetString($content)
                        
                        # Try to find .jar paths
                        $allMatches = [regex]::Matches($textUnicode + $textAscii, '([A-Z]:\\[^\x00]+?\.jar)')
                        
                        foreach ($match in $allMatches) {
                            $jarPath = $match.Groups[1].Value -replace '[^\x20-\x7E]', ''
                            $jarPath = $jarPath.Trim()
                            
                            if ($jarPath -match '^[A-Z]:\\' -and $jarPath.EndsWith('.jar')) {
                                if ((Test-Path $jarPath) -and (-not ($jarFiles -contains $jarPath))) {
                                    Write-Host "      Found: $jarPath" -ForegroundColor Gray
                                    $jarFiles += $jarPath
                                }
                            }
                        }
                    } catch { }
                }
            } else {
                Write-Host "    No java Prefetch files found" -ForegroundColor Gray
            }
        } catch {
            Write-Host "    [!] Cannot access Prefetch (need admin)" -ForegroundColor Gray
        }
    }
    
    
    Write-Host ""
    Write-Host "[~] Searching recent JAR files in Downloads..." -ForegroundColor Gray
    
    $downloadsPath = Join-Path $env:USERPROFILE 'Downloads'
    if (Test-Path $downloadsPath) {
        $recentJars = Get-ChildItem -Path $downloadsPath -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-30) } | 
            Sort-Object LastWriteTime -Descending | 
            Select-Object -First 20
        
        if ($recentJars) {
            Write-Host "    Found $($recentJars.Count) recent JAR file(s)" -ForegroundColor Gray
            foreach ($jar in $recentJars) {
                if (-not ($jarFiles -contains $jar.FullName)) {
                    $jarFiles += $jar.FullName
                }
            }
        }
    }
    
    Write-Host ""
    Write-Host "[~] Scanning JAR files..." -ForegroundColor Gray
    
    if ($jarFiles.Count -gt 0) {
        Write-Host "    Found $($jarFiles.Count) JAR file(s) to check" -ForegroundColor Gray
        Write-Host ""
        
        Add-Type -Assembly System.IO.Compression.FileSystem
        
        foreach ($jarPath in $jarFiles) {
            Write-Host "    [*] Checking: $jarPath" -ForegroundColor Gray
            
            if (Test-Path $jarPath) {
                try {
                    $zip = [System.IO.Compression.ZipFile]::OpenRead($jarPath)
                    
                    $suspiciousClasses = @(
                        'net/java/c.class',
                        'net/java/l.class', 
                        'net/java/s.class',
                        'net/java/f.class'
                    )
                    
                    $foundClasses = @()
                    
                    foreach ($entry in $zip.Entries) {
                        foreach ($suspicious in $suspiciousClasses) {
                            if ($entry.FullName -eq $suspicious) {
                                $foundClasses += $suspicious
                            }
                        }
                    }
                    
                    $zip.Dispose()
                    
                    if ($foundClasses.Count -gt 0) {
                        Write-Host ""
                        Write-Host "        [!!!] CHEAT DETECTED!" -ForegroundColor Red
                        Write-Host "        Found suspicious classes:" -ForegroundColor Red
                        foreach ($cls in $foundClasses) {
                            Write-Host "          - $cls" -ForegroundColor White
                        }
                        Write-Host ""
                        $totalFound++
                    } else {
                        Write-Host "        [+] Clean" -ForegroundColor Green
                    }
                    
                } catch {
                    Write-Host "        [!] Cannot read JAR: $($_.Exception.Message)" -ForegroundColor Gray
                }
            } else {
                Write-Host "        [!] File not found" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "    No JAR files found" -ForegroundColor Gray
    }
    
    Write-Host ""
    if ($totalFound -eq 0) {
        Write-Host "[+] Scan complete! No cheats detected." -ForegroundColor Green
    } else {
        Write-Host "[!] Scan complete! Found $totalFound suspicious JAR(s)." -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "Press Enter to return to menu"
    Clear-Host
    Show-Logo
    

# ============================================================================
# EXIT
# ============================================================================

} elseif ($choice -eq "0") {
    exit
    
} else {
    Write-Host ""
    Write-Host "  Invalid choice!" -ForegroundColor Red
    Start-Sleep -Seconds 1
}

}