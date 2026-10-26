Clear-Host

# Получаем ширину окна терминала
$windowWidth = $Host.UI.RawUI.WindowSize.Width
if ($windowWidth -lt 80) { $windowWidth = 80 }

# Функция для центрирования текста
function Write-Centered {
    param($text, $color = "White")
    $padding = [math]::Max(0, (($windowWidth - $text.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color
}

# Функция для создания линии по всей ширине
function Write-FullLine {
    param($char = "─", $color = "Gray")
    Write-Host ($char * $windowWidth) -ForegroundColor $color
}

# Глобальный белый список модов (не детектить как подозрительные)
$global:whitelistMods = @('ItemSwap', 'itemswap', 'itemswap-', 'ItemSwap-')

# Функция для отрисовки логотипа
function Show-Logo {
    # Получаем ширину окна
    $windowWidth = $Host.UI.RawUI.WindowSize.Width
    if ($windowWidth -lt 80) { $windowWidth = 80 }
    
    # Функция для центрирования текста
    function Write-Centered {
        param($text, $color = "White")
        $padding = [math]::Max(0, ($windowWidth - $text.Length) / 2)
        Write-Host (" " * $padding) -NoNewline
        Write-Host $text -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host ""
    Write-Centered "██████╗ ███████╗ █████╗ ██████╗ ██╗███╗   ██╗███████╗███████╗███████╗" -color DarkGray
    Write-Centered "██╔══██╗██╔════╝██╔══██╗██╔══██╗██║████╗  ██║██╔════╝██╔════╝██╔════╝" -color DarkGray
    Write-Centered "██████╔╝█████╗  ███████║██║  ██║██║██╔██╗ ██║█████╗  ███████╗███████╗" -color Gray
    Write-Centered "██╔══██╗██╔══╝  ██╔══██║██║  ██║██║██║╚██╗██║██╔══╝  ╚════██║╚════██║" -color Gray
    Write-Centered "██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║███████╗███████║███████║" -color White
    Write-Centered "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝" -color White
    Write-Host ""
    
    # Создаём рамку под ширину окна
    $borderChar = "═"
    $border = $borderChar * $windowWidth
    Write-Host $border -ForegroundColor DarkGray
    
    # Центрируем текст "Created by"
    $createdText = "Created by: IwTu"
    $innerPadding = [math]::Max(0, ($windowWidth - $createdText.Length - 2) / 2)
    $leftBorder = "║"
    $rightBorder = "║"
    $totalPadding = $windowWidth - $createdText.Length - 2
    $leftSpace = [math]::Floor($totalPadding / 2)
    $rightSpace = $totalPadding - $leftSpace
    
    Write-Host -NoNewline $leftBorder -ForegroundColor Gray
    Write-Host -NoNewline (" " * $leftSpace)
    Write-Host -NoNewline $createdText -ForegroundColor Gray
    Write-Host -NoNewline (" " * $rightSpace)
    Write-Host $rightBorder -ForegroundColor Gray
    
    Write-Host $border -ForegroundColor DarkGray
    Write-Host ""
}

# Очищаем экран и показываем логотип
Clear-Host
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
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║                         MEMORY SCANNER                                    ║" -ForegroundColor Gray
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    
    # Красивая анимация загрузки
    $barLength = 50
    Write-Host "  Initializing... " -NoNewline -ForegroundColor Gray
    for ($i = 0; $i -le $barLength; $i++) {
        $percent = [math]::Round(($i / $barLength) * 100)
        $bar = "█" * $i + "░" * ($barLength - $i)
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
            
            Write-Host "  ┌─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
            Write-Host "  │ [PID $($proc.Id)] javaw.exe | $memoryMB MB | Started: $startTime" -ForegroundColor White
            Write-Host "  └─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
            
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
    Write-Host "  [~] Checking for SafeMode pattern..." -ForegroundColor Gray
    
    $currentTime = Get-Date
    $recentlyClosedJavaw = @()
    $anydeskStarted = $null
    $safemodeDetected = $false
    $safemode100Confirmed = $false
    
    # Проверяем: должно быть минимум 1 javaw запущен сейчас
    $currentJavawCount = 0
    
    if ($javawProcesses) {
        $currentJavawCount = ($javawProcesses | Where-Object { 
            $memGB = [math]::Round($_.WorkingSet64 / 1GB, 2)
            $memGB -ge 1
        }).Count
    }
    
    if ($currentJavawCount -ge 1) {
        try {
            # Проверяем закрытые javaw (ищем последние 2 процесса за 15 минут)
            $endEvents = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4689} -MaxEvents 200 -ErrorAction SilentlyContinue | 
                Where-Object { $_.Message -match 'javaw\.exe' }
            
            foreach ($event in $endEvents) {
                $timeClosed = $event.TimeCreated
                $minutesAgo = ($currentTime - $timeClosed).TotalMinutes
                
                # Ищем только последние 15 минут
                if ($minutesAgo -le 15 -and $recentlyClosedJavaw.Count -lt 2) {
                    $recentlyClosedJavaw += @{
                        Time = $timeClosed
                        MinutesAgo = [math]::Round($minutesAgo, 1)
                    }
                }
            }
            
            # Проверяем запущенные javaw - ищем "старый" процесс (≥15 минут)
            $oldJavaw = $null
            $newJavaw = $null
            
            foreach ($proc in $javawProcesses) {
                $memGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
                if ($memGB -lt 1) { continue }
                
                $runtimeMinutes = ((Get-Date) - $proc.StartTime).TotalMinutes
                
                if ($runtimeMinutes -ge 15) {
                    $oldJavaw = $proc
                } elseif ($runtimeMinutes -lt 15) {
                    $newJavaw = $proc
                }
            }
            
            # Базовая детекция: javaw открыт + найдено минимум 1 закрытый процесс за последние 15 минут
            if ($recentlyClosedJavaw.Count -ge 1) {
                $safemodeDetected = $true
            }
            
            # Проверяем запуск AnyDesk (последние 10 минут)
            $anydeskEvents = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688} -MaxEvents 500 -ErrorAction SilentlyContinue | 
                Where-Object { $_.Message -match 'AnyDesk\.exe' }
            
            foreach ($event in $anydeskEvents) {
                $timeStarted = $event.TimeCreated
                $minutesAgo = ($currentTime - $timeStarted).TotalMinutes
                
                if ($minutesAgo -le 10) {
                    $anydeskStarted = @{
                        Time = $timeStarted
                        MinutesAgo = [math]::Round($minutesAgo, 1)
                    }
                    break
                }
            }
            
            # 100% ТОЧНАЯ ПРОВЕРКА SAFEMODE:
            # 1. Есть "старый" javaw (≥15 минут) ИЛИ есть "новый" javaw (<15 минут)
            # 2. javaw закрыта в последние 5 минут
            # 3. AnyDesk запущен в последние 5 минут
            # 4. Разница между закрытием javaw и запуском AnyDesk < 5 минут
            if ($recentlyClosedJavaw.Count -gt 0 -and $anydeskStarted) {
                $closedJavaw = $recentlyClosedJavaw[0]
                
                # Проверяем что есть javaw (старый ≥15 мин ИЛИ новый <15 мин)
                if (($oldJavaw -or $newJavaw) -and $closedJavaw.MinutesAgo -le 5 -and $anydeskStarted.MinutesAgo -le 5) {
                    $timeDiff = [math]::Abs(($closedJavaw.Time - $anydeskStarted.Time).TotalMinutes)
                    
                    if ($timeDiff -le 5) {
                        $safemode100Confirmed = $true
                    }
                }
            }
            
        } catch {
            # Если не удалось получить события
        }
        
        if ($safemode100Confirmed) {
            # 100% ПОДТВЕРЖДЕНИЕ SAFEMODE (БЕЗ ТАЙМЕРА)
            Write-Host ""
            Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
            Write-Host "  ║              🚨 SAFEMODE 100% CONFIRMED! 🚨                            ║" -ForegroundColor Red
            Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
            Write-Host ""
            Write-Host "  [!!!] Detected SafeMode pattern with AnyDesk:" -ForegroundColor Red
            Write-Host ""
            Write-Host "    • Current javaw.exe running: $currentJavawCount process(es)" -ForegroundColor White
            Write-Host "    • javaw.exe was recently closed" -ForegroundColor Yellow
            Write-Host "    • AnyDesk.exe was recently started" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  ⚠️  This is DEFINITIVE proof of SafeMode cheat usage!" -ForegroundColor Red
            $totalFound++
            
        } elseif ($safemodeDetected) {
            # БАЗОВАЯ ДЕТЕКЦИЯ SAFEMODE (С ТАЙМЕРОМ)
            Write-Host ""
            Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
            Write-Host "  ║                    ⚠️  SAFEMODE DETECTED ⚠️                            ║" -ForegroundColor Yellow
            Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  [!] Suspicious pattern detected:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "    • Current javaw.exe running: $currentJavawCount process(es)" -ForegroundColor White
            Write-Host "    • Recently closed javaw.exe:" -ForegroundColor Gray
            
            foreach ($closed in $recentlyClosedJavaw) {
                Write-Host "      - Closed $($closed.MinutesAgo) min ago at $($closed.Time.ToString('HH:mm:ss'))" -ForegroundColor Gray
            }
            
            Write-Host ""
            Write-Host "  This pattern may indicate SafeMode usage" -ForegroundColor Yellow
            
            if ($anydeskStarted) {
                Write-Host "  Note: AnyDesk is running but timing doesn't match 100% pattern" -ForegroundColor Gray
            }
            
            $totalFound++
            
        } else {
            Write-Host "    No suspicious activity detected" -ForegroundColor Green
        }
    } else {
        Write-Host "    No javaw.exe with sufficient memory (≥1GB) running" -ForegroundColor Gray
    }
    
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
    
} elseif ($choice -eq "3") {
    Clear-Host
    Show-Logo
    
    Write-Host "[~] Checking for running Minecraft..." -ForegroundColor Gray
    
    # Проверяем запущенный javaw с Minecraft
    $runningMinecraft = $null
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    if ($javawProcesses) {
        foreach ($proc in $javawProcesses) {
            try {
                # Проверяем память (Minecraft обычно >= 1GB)
                $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
                if ($memoryGB -lt 1) { continue }
                
                $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
                
                # Ищем разные варианты путей Minecraft
                $modsPath = $null
                
                # Вариант 1: --gameDir в командной строке
                if ($cmdLine -match '--gameDir[= ]+"?([^"]+)"?') {
                    $gameDir = $matches[1].Trim('"')
                    $modsPath = Join-Path $gameDir "mods"
                }
                # Вариант 2: Прямой путь .minecraft
                elseif ($cmdLine -match '([A-Za-z]:[^"]*\.minecraft[^"\\]*)') {
                    $gameDir = $matches[1].Trim('"')
                    $modsPath = Join-Path $gameDir "mods"
                }
                # Вариант 3: Стандартный путь по умолчанию
                else {
                    $defaultPath = Join-Path $env:APPDATA ".minecraft\mods"
                    if (Test-Path $defaultPath) {
                        $modsPath = $defaultPath
                    }
                }
                
                if ($modsPath -and (Test-Path $modsPath)) {
                    $runningMinecraft = @{
                        PID = $proc.Id
                        ModsPath = $modsPath
                        Memory = $memoryGB
                    }
                    break
                }
            } catch { }
        }
    }
    
    if ($runningMinecraft) {
        Write-Host ""
        Write-Host "    [!] Active Minecraft detected!" -ForegroundColor Green
        Write-Host "        PID: $($runningMinecraft.PID)" -ForegroundColor Gray
        Write-Host "        Memory: $($runningMinecraft.Memory) GB" -ForegroundColor Gray
        Write-Host "        Currently using mods folder:" -ForegroundColor Cyan
        Write-Host "        $($runningMinecraft.ModsPath)" -ForegroundColor White
        Write-Host ""
        Write-Host "    Scan this active instance? (Y/N)" -ForegroundColor Yellow
        $scanActive = Read-Host "    Choice"
        
        if ($scanActive -eq "Y" -or $scanActive -eq "y") {
            $selectedFolder = $runningMinecraft.ModsPath
            
            Write-Host ""
            Write-Host "[~] Scanning ACTIVE Minecraft mods: $selectedFolder" -ForegroundColor Cyan
            Write-Host ""
            
            $jarFiles = Get-ChildItem -Path $selectedFolder -Filter "*.jar" -ErrorAction SilentlyContinue
            
            if ($jarFiles.Count -eq 0) {
                Write-Host "    [!] No JAR files found in this folder" -ForegroundColor Gray
            } else {
                Write-Host "    Found $($jarFiles.Count) JAR file(s) in RUNNING Minecraft" -ForegroundColor Yellow
                Write-Host ""
                
                Add-Type -Assembly System.IO.Compression.FileSystem
                
                # Pass 1: Hash verification
                Write-Host "  [~] Verifying..." -ForegroundColor Gray
                $verifiedMods = @()
                $unknownMods = @()
                $modNames = @{}
                
                $spinnerFrames = @("|","/","-","\")
                $idx = 0
                
                foreach ($jar in $jarFiles) {
                    $idx++
                    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
                    $progress = [math]::Round(($idx / $jarFiles.Count) * 100)
                    Write-Host "`r    [$spinner] $progress%" -ForegroundColor Gray -NoNewline
                    
                    # Проверяем белый список
                    $isWhitelisted = $false
                    foreach ($wl in $global:whitelistMods) {
                        if ($jar.Name -match $wl) {
                            $isWhitelisted = $true
                            $verifiedMods += $jar
                            $modNames[$jar.Name] = "Whitelisted mod"
                            break
                        }
                    }
                    if ($isWhitelisted) { continue }
                    
                    try {
                        $hash = (Get-FileHash -Path $jar.FullName -Algorithm SHA1).Hash
                        
                        try {
                            $response = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version_file/$hash" -Method Get -ErrorAction Stop -TimeoutSec 3
                            if ($response.project_id) {
                                try {
                                    $project = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$($response.project_id)" -Method Get -ErrorAction Stop -TimeoutSec 2
                                    $modNames[$jar.Name] = $project.title
                                    $verifiedMods += $jar
                                } catch {
                                    $unknownMods += $jar
                                }
                            } else {
                                $unknownMods += $jar
                            }
                        } catch {
                            $unknownMods += $jar
                        }
                    } catch {
                        $unknownMods += $jar
                    }
                }
                
                Write-Host "`r    [✓] Analysis complete          " -ForegroundColor Green
                Write-Host ""
                
                # Показываем результаты
                if ($verifiedMods.Count -gt 0) {
                    Write-Host "  ✓ Verified mods: $($verifiedMods.Count)" -ForegroundColor Green
                    foreach ($mod in $verifiedMods) {
                        $modName = if ($modNames[$mod.Name]) { $modNames[$mod.Name] } else { "Unknown" }
                        Write-Host "    • $($mod.Name) - $modName" -ForegroundColor Gray
                    }
                    Write-Host ""
                }
                
                if ($unknownMods.Count -gt 0) {
                    Write-Host "  ⚠ Unknown/Unverified mods: $($unknownMods.Count)" -ForegroundColor Yellow
                    foreach ($mod in $unknownMods) {
                        Write-Host "    • $($mod.Name)" -ForegroundColor Yellow
                    }
                }
            }
            
            Write-Host ""
            Read-Host "Press Enter to return to menu"
            Clear-Host
            Show-Logo
            continue
        }
    }
    
    Write-Host "[~] Searching for mods folders..." -ForegroundColor Gray
    
    $modsFolders = @()
    
    # Common locations
    $searchPaths = @(
        (Join-Path $env:APPDATA '.minecraft\mods'),
        (Join-Path $env:APPDATA '.tlauncher\legacy\Minecraft\game\mods'),
        (Join-Path $env:APPDATA 'LabyMod\instances'),
        (Join-Path $env:USERPROFILE '.lunarclient\profiles'),
        (Join-Path $env:USERPROFILE '.cristalix')
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            if ((Get-Item $path).PSIsContainer) {
                # Search for mods subfolders
                $foundMods = Get-ChildItem -Path $path -Recurse -Directory -Filter "mods" -ErrorAction SilentlyContinue -Depth 3
                foreach ($modFolder in $foundMods) {
                    if (-not ($modsFolders -contains $modFolder.FullName)) {
                        $modsFolders += $modFolder.FullName
                    }
                }
                
                # Check if path itself contains .jar files
                $jars = Get-ChildItem -Path $path -Filter "*.jar" -ErrorAction SilentlyContinue
                if ($jars.Count -gt 0 -and -not ($modsFolders -contains $path)) {
                    $modsFolders += $path
                }
            }
        }
    }
    
    if ($modsFolders.Count -eq 0) {
        Write-Host ""
        Write-Host "    [!] No mods folders found!" -ForegroundColor Gray
        Write-Host ""
        Read-Host "Press Enter to return to menu"
        Clear-Host
        Show-Logo
    } else {
        Write-Host ""
        Write-Host "    Found $($modsFolders.Count) mods folder(s):" -ForegroundColor Green
        Write-Host ""
        
        for ($i = 0; $i -lt $modsFolders.Count; $i++) {
            Write-Host "    [$($i+1)] " -ForegroundColor White -NoNewline
            Write-Host $modsFolders[$i] -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "    [0] Back to menu" -ForegroundColor DarkGray
        Write-Host ""
        
        $folderChoice = Read-Host "Select folder"
        
        if ($folderChoice -match '^\d+$' -and [int]$folderChoice -gt 0 -and [int]$folderChoice -le $modsFolders.Count) {
            $selectedFolder = $modsFolders[[int]$folderChoice - 1]
            
            Write-Host ""
            Write-Host "[~] Scanning: $selectedFolder" -ForegroundColor Gray
            Write-Host ""
            
            $jarFiles = Get-ChildItem -Path $selectedFolder -Filter "*.jar" -ErrorAction SilentlyContinue
            
            if ($jarFiles.Count -eq 0) {
                Write-Host "    [!] No JAR files found in this folder" -ForegroundColor Gray
            } else {
                Write-Host "    Found $($jarFiles.Count) JAR file(s)" -ForegroundColor Gray
                Write-Host ""
                
                Add-Type -Assembly System.IO.Compression.FileSystem
                
                # Pass 1: Hash verification
                Write-Host "  [~] Verifying..." -ForegroundColor Gray
                $verifiedMods = @()
                $unknownMods = @()
                $modNames = @{}
                
                $spinnerFrames = @("|","/","-","\")
                $idx = 0
                
                foreach ($jar in $jarFiles) {
                    $idx++
                    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
                    $progress = [math]::Round(($idx / $jarFiles.Count) * 100)
                    Write-Host "`r    [$spinner] $progress%" -ForegroundColor Gray -NoNewline
                    
                    # Проверяем белый список
                    $isWhitelisted = $false
                    foreach ($wl in $global:whitelistMods) {
                        if ($jar.Name -match $wl) {
                            $isWhitelisted = $true
                            $verifiedMods += $jar.Name
                            $modNames[$jar.Name] = "Whitelisted mod"
                            break
                        }
                    }
                    if ($isWhitelisted) { continue }
                    
                    try {
                        $hash = (Get-FileHash -Path $jar.FullName -Algorithm SHA1).Hash
                        
                        try {
                            $response = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version_file/$hash" -Method Get -ErrorAction Stop -TimeoutSec 3
                            if ($response.project_id) {
                                try {
                                    $project = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$($response.project_id)" -Method Get -ErrorAction Stop -TimeoutSec 2
                                    $modNames[$jar.Name] = $project.title
                                } catch {
                                    $modNames[$jar.Name] = "Unknown Project"
                                }
                                $verifiedMods += $jar.Name
                            }
                        } catch {
                            $unknownMods += $jar.Name
                        }
                    } catch {
                        $unknownMods += $jar.Name
                    }
                }
                
                Write-Host "`r    Verified: $($verifiedMods.Count) | Unknown: $($unknownMods.Count)$(' ' * 20)" -ForegroundColor Gray
                Write-Host ""
                
                # Pass 2: Deep scanning
                Write-Host "  [~] Scanning..." -ForegroundColor Gray
                
                $suspiciousPatterns = @(
                    'AimAssist','AutoAnchor','AutoCrystal','AutoTotem','TriggerBot',
                    'Killaura','AutoClicker','AutoPot','ShieldBreaker','FakeLag',
                    'AutoDoubleHand','WalksyOptimizer','Donut','AutoWeb','MaceSwap',
                    'Liminar','LiminarClient','LiminarLoader','LiminarGhost',
                    'BlockESP','ElytraSwap','FastExp','FastXP','NoSlow','WallHack',
                    'ChestStealer','AutoSprint','AntiAFK','NoJumpDelay',
                    'ReplayMod','FlashBack','XRay','XRayMod','MobHealthBar',
                    'HealthBarPlus','Neat','Minimap','Voxelmap','Waypoints',
                    'JourneyMap','AccurateBlockPlacement','ChunkAnimator',
                    'InventoryTotem','TrueSight','ElytraAutoPilot','BetterPvP',
                    'InvMove','ChestTracker','UseTracker','AucHelper','AntiInvis',
                    'AdvancedCompass','Baritone','Fabaritone','AutoMining','AutoFish',
                    'TopkaAutoBuy','XorekAutoBuy','TopkaAutoSell','XorekAutoMyst',
                    'TopkaCasino','AutoSell','AutoCasino','DiamondGen','AutoAttack',
                    'CleanCut','InventoryControlTweaks','AutoLeave','Foodslot',
                    'Quickstack','ItemSwap','AutoTool','FeatherLauncher','Badlion',
                    'FeverVisuals','WaveVisuals','ClientCommands','Schematica',
                    'Litematica','CheatUtils','FreeCam','WorldEdit','EffortlessBuilding',
                    'Pojav','FCL','MobileEmulator'
                )
                
                $cheatStrings = @(
                    # Основные читы
                    'AutoCrystal','autocrystal','auto crystal',
                    'AutoAnchor','autoanchor','auto anchor',
                    'AutoTotem','autototem','auto totem','OffhandTotem',
                    'AimAssist','aimassist','aim assist',
                    'TriggerBot','triggerbot','trigger bot',
                    'AutoPot','autopot','auto pot',
                    'ShieldDisabler','ShieldBreaker',
                    'WalksyOptimizer','WalskyOptimizer',
                    'Doomsday','doomsdayclient',
                    'Liminar','LiminarClient','Liminar-free','LiminarLoader',
                    'LiminarGhost.fun','liminarclient',
                    'AntiAFK','AutoSprint','ChestStealer','NoJumpDelay',
                    'NoSlow','WallHack','BlockESP','ElytraSwap','FastExp',
                    'Killaura','KillAura','ClickAura','AutoClicker',
                    'AutoDoubleHand','MaceSwap','AutoWeb','FakeLag',
                    
                    # Запрещённые моды с сервера
                    'ReplayMod','FlashBack',
                    'XRay','XRayMod','X-ray',
                    'MobHealthBar','HealthBarPlus','Neat','Neat+',
                    'Minimap','Voxelmap','Waypoints','JourneyMap','Rei',
                    'AccurateBlockPlacement','ChunkAnimator','InventoryTotem',
                    'TrueSight','ElytraAutoPilot','BetterPvP','InvMove','ChestTracker',
                    'UseTracker','UseLogger','AucHelper','AntiInvis','EntityOutliner',
                    'AdvancedCompass',
                    'Baritone','Fabaritone','AutoMining','AutoFish',
                    'TopkaAutoBuy','TopkaAutoSell','XorekAutoMyst','AutoCasino',
                    'DiamondGen',
                    'AutoAttack','CleanCut','InventoryControlTweaks','AutoLeave','Foodslot','ItemSwap','AutoTool',
                    'FeatherLauncher','Badlion','FeverVisuals','WaveVisuals',
                    'ClientCommands','Schematica','Litematica','CheatUtils','FreeCam','WorldEdit','EffortlessBuilding',
                    'Pojav','FCL','MobileEmulator'
                )
                
                $suspiciousMods = @()
                $idx = 0
                
                foreach ($jar in $jarFiles) {
                    $idx++
                    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
                    $progress = [math]::Round(($idx / $jarFiles.Count) * 100)
                    Write-Host "`r[$spinner] $progress% - Scanning: $($jar.Name)$(' ' * 30)" -ForegroundColor Gray -NoNewline
                    
                    # Skip verified mods
                    if ($verifiedMods -contains $jar.Name) {
                        continue
                    }
                    
                    $foundPatterns = @()
                    $foundStrings = @()
                    $foundFullwidth = @()
                    
                    # Check filename
                    foreach ($pattern in $suspiciousPatterns) {
                        if ($jar.Name -match $pattern) {
                            $foundPatterns += $pattern
                            break
                        }
                    }
                    
                    try {
                        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
                        
                        # Check entry names
                        foreach ($entry in $zip.Entries) {
                            foreach ($pattern in $suspiciousPatterns) {
                                if ($entry.FullName -match $pattern -and -not ($foundPatterns -contains $pattern)) {
                                    $foundPatterns += $pattern
                                }
                            }
                        }
                        
                        # Check cheat classes
                        $cheatClasses = @('net/java/c.class','net/java/l.class','net/java/s.class','net/java/f.class')
                        foreach ($entry in $zip.Entries) {
                            foreach ($cls in $cheatClasses) {
                                if ($entry.FullName -eq $cls) {
                                    $foundPatterns += "CheatClass:$cls"
                                }
                            }
                        }
                        
                        # Deep scan - read ALL .class files
                        $classFiles = $zip.Entries | Where-Object { $_.FullName -match '\.class$' }
                        
                        foreach ($entry in $classFiles) {
                            try {
                                $stream = $entry.Open()
                                $ms = New-Object System.IO.MemoryStream
                                $stream.CopyTo($ms)
                                $stream.Close()
                                
                                $bytes = $ms.ToArray()
                                $ms.Dispose()
                                
                                $ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
                                $utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
                                
                                foreach ($str in $cheatStrings) {
                                    if ($ascii.Contains($str) -and -not ($foundStrings -contains $str)) {
                                        $foundStrings += $str
                                    }
                                }
                                
                                if ($utf8 -match '[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{3,}') {
                                    $matches = [regex]::Matches($utf8, '[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{3,}')
                                    foreach ($m in $matches) {
                                        if (-not ($foundFullwidth -contains $m.Value)) {
                                            $foundFullwidth += $m.Value
                                        }
                                    }
                                }
                            } catch { }
                        }
                        
                        $zip.Dispose()
                        
                        # Filter weak signals - need at least 2 findings OR 1 strong pattern
                        $totalFindings = $foundPatterns.Count + $foundStrings.Count + $foundFullwidth.Count
                        $hasStrongPattern = $false
                        
                        # Strong patterns (definite cheats)
                        $strongPatterns = @('Killaura','AutoCrystal','AutoTotem','AimAssist','TriggerBot',
                                          'Liminar','LiminarClient','Doomsday','doomsdayclient',
                                          'AutoAnchor','WalksyOptimizer','CheatClass:')
                        
                        foreach ($pattern in $foundPatterns) {
                            foreach ($strong in $strongPatterns) {
                                if ($pattern -match $strong) {
                                    $hasStrongPattern = $true
                                    break
                                }
                            }
                        }
                        
                        foreach ($str in $foundStrings) {
                            foreach ($strong in $strongPatterns) {
                                if ($str -match $strong) {
                                    $hasStrongPattern = $true
                                    break
                                }
                            }
                        }
                        
                        # Only flag if: strong pattern OR 2+ findings
                        if ($hasStrongPattern -or $totalFindings -ge 2) {
                            $suspiciousMods += @{
                                Name = $jar.Name
                                Patterns = $foundPatterns
                                Strings = $foundStrings
                                Fullwidth = $foundFullwidth
                            }
                        }
                    } catch { }
                }
                
                Write-Host "`r$(' ' * 100)`r" -NoNewline
                Write-Host "    Suspicious: $($suspiciousMods.Count)" -ForegroundColor $(if($suspiciousMods.Count -gt 0){'Red'}else{'Gray'})
                Write-Host ""
                
                # Pass 3: Bypass/injection scan
                Write-Host "  [~] Checking bypasses..." -ForegroundColor Gray
                $bypassMods = @()
                
                # Only scan suspicious mods from Pass 2
                $modsToCheck = @()
                foreach ($sm in $suspiciousMods) {
                    $modsToCheck += $jarFiles | Where-Object { $_.Name -eq $sm.Name }
                }
                
                # If no suspicious mods, scan unknown mods only
                if ($modsToCheck.Count -eq 0) {
                    foreach ($um in $unknownMods) {
                        $modsToCheck += $jarFiles | Where-Object { $_.Name -eq $um }
                    }
                }
                
                $idx = 0
                
                foreach ($jar in $modsToCheck) {
                    $idx++
                    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
                    $progress = [math]::Round(($idx / $modsToCheck.Count) * 100)
                    Write-Host "`r[$spinner] $progress% - Bypass scan: $($jar.Name)$(' ' * 30)" -ForegroundColor Magenta -NoNewline
                    
                    $flags = @()
                    
                    try {
                        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
                        
                        $nestedJars = @($zip.Entries | Where-Object { $_.FullName -match "^META-INF/jars/.+\.jar$" })
                        $outerClasses = @($zip.Entries | Where-Object { $_.FullName -match "\.class$" })
                        
                        if ($nestedJars.Count -gt 0) {
                            foreach ($nj in $nestedJars) {
                                $njName = [System.IO.Path]::GetFileName($nj.FullName)
                                if ($njName -notmatch '\d' -and $njName.Length -lt 20) {
                                    $flags += "Suspicious nested JAR: $njName"
                                }
                            }
                        }
                        
                        if ($nestedJars.Count -eq 1 -and $outerClasses.Count -lt 3) {
                            $flags += "Hollow shell - wraps another JAR"
                        }
                        
                        # Check for dangerous code
                        $classFiles = $zip.Entries | Where-Object { $_.FullName -match '\.class$' } | Select-Object -First 20
                        
                        foreach ($entry in $classFiles) {
                            try {
                                $stream = $entry.Open()
                                $ms = New-Object System.IO.MemoryStream
                                $stream.CopyTo($ms)
                                $stream.Close()
                                
                                $content = [System.Text.Encoding]::ASCII.GetString($ms.ToArray())
                                $ms.Dispose()
                                
                                if ($content -match "Runtime.*exec" -and $content -match "getRuntime") {
                                    $flags += "Runtime.exec() detected"
                                }
                                
                                if ($content -match "HttpURLConnection" -and $content -match "FileOutputStream") {
                                    $flags += "HTTP file download detected"
                                }
                            } catch { }
                        }
                        
                        $zip.Dispose()
                        
                        if ($flags.Count -gt 0) {
                            $bypassMods += @{ Name = $jar.Name; Flags = $flags }
                        }
                    } catch { }
                }
                
                Write-Host "`r$(' ' * 100)`r" -NoNewline
                Write-Host "    Bypass/Injected: $($bypassMods.Count)" -ForegroundColor $(if($bypassMods.Count -gt 0){'Red'}else{'Gray'})
                Write-Host ""
                
                # Pass 4: Obfuscation analysis
                Write-Host "  [~] Analyzing..." -ForegroundColor Gray
                $obfuscatedMods = @()
                $idx = 0
                
                foreach ($jar in $jarFiles) {
                    $idx++
                    $spinner = $spinnerFrames[$idx % $spinnerFrames.Length]
                    $progress = [math]::Round(($idx / $jarFiles.Count) * 100)
                    Write-Host "`r[$spinner] $progress% - Obfuscation scan: $($jar.Name)$(' ' * 30)" -ForegroundColor Gray -NoNewline
                    
                    $flags = @()
                    
                    try {
                        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
                        
                        $totalClass = 0
                        $numericCount = 0
                        $unicodeCount = 0
                        $singleLetterCount = 0
                        
                        foreach ($entry in $zip.Entries) {
                            if ($entry.FullName -match "\.class$") {
                                $totalClass++
                                $className = [System.IO.Path]::GetFileNameWithoutExtension(($entry.FullName -split "/")[-1])
                                
                                if ($className -match "^\d+$") { $numericCount++ }
                                if ($className -match "[^\x00-\x7F]") { $unicodeCount++ }
                                if ($className -match "^[a-zA-Z]$") { $singleLetterCount++ }
                            }
                        }
                        
                        $zip.Dispose()
                        
                        if ($totalClass -ge 5) {
                            $numPct = [math]::Round(($numericCount / $totalClass) * 100)
                            $uniPct = [math]::Round(($unicodeCount / $totalClass) * 100)
                            $s1Pct = [math]::Round(($singleLetterCount / $totalClass) * 100)
                            
                            if ($numPct -ge 20) { $flags += "Numeric class names - $numPct%" }
                            if ($uniPct -ge 10) { $flags += "Unicode class names - $uniPct%" }
                            if ($s1Pct -ge 15) { $flags += "Single-letter class names - $s1Pct%" }
                        }
                        
                        if ($flags.Count -gt 0) {
                            $obfuscatedMods += @{ Name = $jar.Name; Flags = $flags }
                        }
                    } catch { }
                }
                
                Write-Host "`r$(' ' * 100)`r" -NoNewline
                Write-Host "    Obfuscated: $($obfuscatedMods.Count)" -ForegroundColor $(if($obfuscatedMods.Count -gt 0){'Red'}else{'Gray'})
                Write-Host ""
                
                # Pass 5: JVM scan
                Write-Host "  [~] Checking JVM..." -ForegroundColor Gray
                $jvmFlags = @()
                
                $javaProc = Get-Process javaw -ErrorAction SilentlyContinue
                if (-not $javaProc) { $javaProc = Get-Process java -ErrorAction SilentlyContinue }
                
                if ($javaProc) {
                    try {
                        $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $(($javaProc | Select-Object -First 1).Id)" -ErrorAction Stop
                        $cmdLine = $wmi.CommandLine
                        
                        if ($cmdLine -match '-javaagent:') {
                            $agentMatches = [regex]::Matches($cmdLine, '-javaagent:([^\s"]+)')
                            foreach ($m in $agentMatches) {
                                $agentPath = $m.Groups[1].Value
                                $agentName = [System.IO.Path]::GetFileName($agentPath)
                                $jvmFlags += "JVM Agent: $agentName"
                            }
                        }
                    } catch { }
                }
                
                Write-Host "    JVM issues: $($jvmFlags.Count)" -ForegroundColor $(if($jvmFlags.Count -gt 0){'Red'}else{'Gray'})
                Write-Host ""
                
                # Pass 6: Forbidden mods filter
                Write-Host "  [~] Final check..." -ForegroundColor Gray
                $forbiddenMods = @()
                
                # Определяем категории запрещённых модов
                $forbiddenCategories = @{
                    'Recording' = @('ReplayMod','FlashBack')
                    'XRay' = @('XRay','XRayMod','XRayTextures','DiamondGen')
                    'Health' = @('MobHealthBar','HealthBarPlus','Neat','NeatPlus')
                    'Minimap' = @('Minimap','Voxelmap','Waypoints','JourneyMap')
                    'Mechanics' = @('AccurateBlockPlacement','ChunkAnimator','InventoryTotem','TrueSight','ElytraAutoPilot')
                    'Advantage' = @('BetterPvP','InvMove','ChestTracker','UseTracker','UseLogger','AucHelper','AntiInvis','EntityOutliner')
                    'Location' = @('AdvancedCompass')
                    'AutoMining' = @('Baritone','Fabaritone','AutoMining','AutoFish')
                    'AutoServer' = @('TopkaAutoBuy','XorekAutoBuy','TopkaAutoSell','XorekAutoMyst','TopkaCasino','AutoSell','AutoCasino')
                    'PvP' = @('AutoAttack','CleanCut','InventoryControlTweaks','AutoLeave','Foodslot','Quickstack','ItemSwap','AutoTool')
                    'Visual' = @('FeatherLauncher','BadlionClient','FeverVisuals','WaveVisuals')
                    'Cheat' = @('ClientCommands','Schematica','Litematica','CheatUtils','FreeCam','WorldEdit','EffortlessBuilding')
                    'Mobile' = @('Pojav','FCL','MobileEmulator')
                }
                
                # Ищем запрещённые моды в обнаруженных
                foreach ($modFile in $unknownMods + $verifiedMods + $suspiciousMods.Name) {
                    $modName = if ($modFile -is [string]) { $modFile } else { $modFile.Name }
                    
                    foreach ($category in $forbiddenCategories.GetEnumerator()) {
                        foreach ($forbidden in $category.Value) {
                            if ($modName -like "*$forbidden*") {
                                $forbiddenMods += @{
                                    Name = $modName
                                    Category = $category.Key
                                    Forbidden = $forbidden
                                }
                                break
                            }
                        }
                    }
                }
                
                Write-Host "    Forbidden mods: $($forbiddenMods.Count)" -ForegroundColor $(if($forbiddenMods.Count -gt 0){'Red'}else{'Gray'})
                Write-Host ""
                Write-Host ""
                
                # Details - показываем моды
                if ($verifiedMods.Count -gt 0) {
                    Write-Host "  ●  VERIFIED MODS  ($($verifiedMods.Count))" -ForegroundColor Gray
                    Write-Host "────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
                    foreach ($modFile in $verifiedMods) {
                        if ($modNames.ContainsKey($modFile)) {
                            Write-Host "  ✓ " -ForegroundColor Gray -NoNewline
                            Write-Host $modNames[$modFile] -ForegroundColor White -NoNewline
                            Write-Host " → " -ForegroundColor DarkGray -NoNewline
                            Write-Host $modFile -ForegroundColor Gray
                        } else {
                            Write-Host "  ✓ $modFile" -ForegroundColor Gray
                        }
                    }
                    Write-Host ""
                }
                
                if ($unknownMods.Count -gt 0) {
                    Write-Host "  ●  UNKNOWN MODS  ($($unknownMods.Count))" -ForegroundColor Gray
                    Write-Host "────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
                    foreach ($modFile in $unknownMods) {
                        Write-Host ""
                        Write-Host "  ╔═ ? " -ForegroundColor Gray -NoNewline
                        Write-Host $modFile -ForegroundColor White
                        Write-Host "  ╚═ Source: ?" -ForegroundColor DarkGray
                    }
                    Write-Host ""
                }
                
                if ($suspiciousMods.Count -gt 0) {
                    Write-Host "  ●  SUSPICIOUS MODS  ($($suspiciousMods.Count))" -ForegroundColor Red
                    Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
                    $idx = 1
                    foreach ($mod in $suspiciousMods) {
                        Write-Host "  [$idx] $($mod.Name)" -ForegroundColor Gray
                        
                        if ($mod.Patterns.Count -gt 0) {
                            Write-Host "      └─ Patterns: $(($mod.Patterns | Select-Object -First 5) -join ', ')" -ForegroundColor DarkRed
                        }
                        
                        if ($mod.Strings.Count -gt 0) {
                            Write-Host "      └─ Strings: $(($mod.Strings | Select-Object -First 5) -join ', ')" -ForegroundColor DarkRed
                        }
                        
                        if ($mod.Fullwidth.Count -gt 0) {
                            Write-Host "      └─ Fullwidth: $(($mod.Fullwidth | Select-Object -First 3) -join ', ')" -ForegroundColor DarkRed
                        }
                        $idx++
                    }
                    Write-Host ""
                }
                
                if ($bypassMods.Count -gt 0) {
                    Write-Host "  ●  BYPASS/INJECTED MODS  ($($bypassMods.Count))" -ForegroundColor Gray
                    Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
                    $idx = 1
                    foreach ($mod in $bypassMods) {
                        Write-Host "  [$idx] $($mod.Name)" -ForegroundColor Gray
                        foreach ($flag in $mod.Flags) {
                            Write-Host "      └─ $flag" -ForegroundColor Gray
                        }
                        $idx++
                    }
                    Write-Host ""
                }
                
                if ($obfuscatedMods.Count -gt 0) {
                    Write-Host "  ●  OBFUSCATED MODS  ($($obfuscatedMods.Count))" -ForegroundColor Gray
                    Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
                    $idx = 1
                    foreach ($mod in $obfuscatedMods) {
                        Write-Host "  [$idx] $($mod.Name)" -ForegroundColor Yellow
                        foreach ($flag in $mod.Flags) {
                            Write-Host "      └─ $flag" -ForegroundColor Gray
                        }
                        $idx++
                    }
                    Write-Host ""
                }
                
                if ($forbiddenMods.Count -gt 0) {
                    Write-Host "  ●  ЗАПРЕЩЁННЫЕ МОДЫ  ($($forbiddenMods.Count))" -ForegroundColor Red
                    Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
                    $idx = 1
                    foreach ($mod in $forbiddenMods) {
                        Write-Host "  [$idx] $($mod.Name)" -ForegroundColor Gray
                        Write-Host "      └─ Category: [$($mod.Category)]" -ForegroundColor DarkRed
                        $idx++
                    }
                    Write-Host ""
                }
                
                if ($jvmFlags.Count -gt 0) {
                    Write-Host "  ●  JVM ISSUES  ($($jvmFlags.Count))" -ForegroundColor Gray
                    Write-Host "────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
                    foreach ($flag in $jvmFlags) {
                        Write-Host "  [!] $flag" -ForegroundColor Gray
                    }
                    Write-Host ""
                }
                
                # Summary в конце
                Write-Host "📊 SUMMARY" -ForegroundColor Gray
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                Write-Host "  Total files scanned: " -ForegroundColor White -NoNewline
                Write-Host $jarFiles.Count -ForegroundColor Gray
                Write-Host "  Verified mods:       " -ForegroundColor White -NoNewline
                Write-Host $verifiedMods.Count -ForegroundColor Gray
                Write-Host "  Unknown mods:        " -ForegroundColor White -NoNewline
                Write-Host $unknownMods.Count -ForegroundColor Gray
                Write-Host "  Suspicious mods:     " -ForegroundColor White -NoNewline
                Write-Host $suspiciousMods.Count -ForegroundColor Red
                Write-Host "  Bypass/Injected:     " -ForegroundColor White -NoNewline
                Write-Host $bypassMods.Count -ForegroundColor Gray
                Write-Host "  Obfuscated mods:     " -ForegroundColor White -NoNewline
                Write-Host $obfuscatedMods.Count -ForegroundColor Gray
                Write-Host "  Forbidden mods:      " -ForegroundColor White -NoNewline
                Write-Host $forbiddenMods.Count -ForegroundColor Red
                Write-Host "  JVM issues:          " -ForegroundColor White -NoNewline
                Write-Host $jvmFlags.Count -ForegroundColor $(if($jvmFlags.Count -gt 0){'Yellow'}else{'Cyan'})
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
                Write-Host ""
                Write-Host "  ✨ Analysis complete!" -ForegroundColor Gray
                Write-Host ""
            }
            
            Write-Host ""
            Read-Host "Press Enter to return to menu"
            Clear-Host
            Show-Logo
            
        } elseif ($folderChoice -eq "0") {
            Clear-Host
            Show-Logo
        } else {
            Write-Host ""
            Write-Host "    Invalid choice!" -ForegroundColor Red
            Start-Sleep -Seconds 1
            Clear-Host
            Show-Logo
        }
    }
    
} elseif ($choice -eq "4") {
    Clear-Host
    Show-Logo
    Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║ DLL CHECK                                                               ║" -ForegroundColor Gray
    Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    
    $totalFound = 0
    
    # Прогресс бар
    $barLength = 50
    Write-Host "  Scanning DLLs... " -NoNewline -ForegroundColor Gray
    for ($i = 0; $i -le $barLength; $i++) {
        $percent = [math]::Round(($i / $barLength) * 100)
        $bar = "█" * $i + "░" * ($barLength - $i)
        Write-Host "`r  Scanning DLLs... [$bar] $percent%" -NoNewline -ForegroundColor Gray
        Start-Sleep -Milliseconds 30
    }
    Write-Host ""
    Write-Host ""
    
    $totalFound = 0
    
    # Suspicious DLLs blacklist
    $suspiciousDlls = @(
        'WLDAP32.dll',
        'wldap32.dll',
        'secur32.dll'
    )
    
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    if ($javawProcesses) {
        foreach ($proc in $javawProcesses) {
            $memoryMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
            $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
            $startTime = $proc.StartTime.ToString("HH:mm:ss")
            
            # Пропускаем javaw с памятью < 1 GB
            if ($memoryGB -lt 1) {
                continue
            }
            
            Write-Host "  ┌─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
            Write-Host "  │ [PID $($proc.Id)] javaw.exe | $memoryMB MB | Started: $startTime" -ForegroundColor Gray
            Write-Host "  └─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
            Write-Host ""
            
            $foundSuspicious = @()
            
            try {
                $modules = Get-Process -Id $proc.Id | Select-Object -ExpandProperty Modules -ErrorAction Stop
                
                foreach ($module in $modules) {
                    $dllName = $module.ModuleName
                    
                    if ($suspiciousDlls -contains $dllName) {
                        $foundSuspicious += $dllName
                    }
                }
                
                if ($foundSuspicious.Count -gt 0) {
                    Write-Host "  ├─ Status: ⚠️  FOUND (CORTEX detected)" -ForegroundColor Red
                    Write-Host "  │" -ForegroundColor Gray
                    foreach ($dll in $foundSuspicious) {
                        Write-Host "  │ • $dll" -ForegroundColor Gray
                    }
                    $totalFound++
                } else {
                    Write-Host "  ├─ Status: ✅ CLEAN" -ForegroundColor Green
                }
                
            } catch {
                Write-Host "  ├─ Status: ⚠️  Access Denied" -ForegroundColor Yellow
            }
            
            Write-Host ""
        }
        
    } else {
        Write-Host "    No javaw.exe processes running" -ForegroundColor Gray
    }
    
    Write-Host ""
    if ($totalFound -eq 0) {
        Write-Host "[+] Scan complete! No suspicious DLLs detected." -ForegroundColor Green
    } else {
        Write-Host "[!] Scan complete! Found $totalFound suspicious DLL(s)." -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "Press Enter to return to menu"
    Clear-Host
    Show-Logo
    
} elseif ($choice -eq "5") {
    Clear-Host
    Show-Logo
    
    Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║                      SAFEMODE DETECTION                                 ║" -ForegroundColor Gray
    Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    
    # Прогресс бар
    $barLength = 50
    Write-Host "  Initializing... " -NoNewline -ForegroundColor Gray
    for ($i = 0; $i -le $barLength; $i++) {
        $percent = [math]::Round(($i / $barLength) * 100)
        $bar = "█" * $i + "░" * ($barLength - $i)
        Write-Host "`r  Initializing... [$bar] $percent%" -NoNewline -ForegroundColor Gray
        Start-Sleep -Milliseconds 30
    }
    # Очищаем строку загрузки
    Write-Host "`r$(' ' * 80)" -NoNewline
    Write-Host "`r" -NoNewline
    Write-Host ""
    Write-Host ""
    
    Write-Host "  [~] Collecting javaw.exe history (last 30 minutes)..." -ForegroundColor Gray
    Write-Host ""
    
    $allJavaw = @()
    $currentTime = Get-Date
    
    # 1. Получаем активные процессы javaw.exe (только >= 1GB)
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    if ($javawProcesses) {
        foreach ($proc in $javawProcesses) {
            $memoryMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
            $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
            $startTime = $proc.StartTime
            
            # ТОЛЬКО javaw с памятью >= 1 GB
            if ($memoryGB -ge 1) {
                $allJavaw += @{
                    PID = $proc.Id
                    StartTime = $startTime
                    EndTime = $null
                    Memory = $memoryMB
                    MemoryGB = $memoryGB
                    Status = "Active"
                    TimeSinceClosed = 0
                    LastEvent = $startTime
                }
            }
        }
    }
    
    # 2. Получаем закрытые процессы javaw.exe из разных источников
    $closedCount = 0
    
    # Метод 1: Security Event Log (требует админ)
    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName='Security'
            ID=4689  # Process terminated
        } -MaxEvents 500 -ErrorAction SilentlyContinue | 
        Where-Object { $_.Message -match 'javaw\.exe' }
        
        if ($events) {
            foreach ($event in $events) {
                $exitTime = $event.TimeCreated
                $timeDiff = ($currentTime - $exitTime).TotalMinutes
                
                if ($timeDiff -le 30) {
                    $pid = $null
                    if ($event.Message -match 'Process ID:\s+0x([0-9a-fA-F]+)') {
                        $pid = [Convert]::ToInt32($matches[1], 16)
                    }
                    
                    $startTime = $null
                    try {
                        $startEvent = Get-WinEvent -FilterHashtable @{
                            LogName='Security'
                            ID=4688
                        } -MaxEvents 1000 -ErrorAction SilentlyContinue | 
                        Where-Object { 
                            $_.Message -match "javaw\.exe" -and 
                            $_.Message -match "Process ID:\s+0x$([Convert]::ToString($pid, 16))"
                        } | Select-Object -First 1
                        
                        if ($startEvent) {
                            $startTime = $startEvent.TimeCreated
                        }
                    } catch { }
                    
                    $allJavaw += @{
                        PID = $pid
                        StartTime = $startTime
                        EndTime = $exitTime
                        Memory = $null
                        MemoryGB = $null
                        Status = "Closed"
                        TimeSinceClosed = [math]::Round($timeDiff, 2)
                        LastEvent = $exitTime
                    }
                    $closedCount++
                }
            }
        }
    } catch { }
    
    # Метод 2: Application Event Log (не требует админ)
    try {
        $appEvents = Get-WinEvent -FilterHashtable @{
            LogName='Application'
        } -MaxEvents 1000 -ErrorAction SilentlyContinue | 
        Where-Object { $_.Message -match 'javaw\.exe' }
        
        if ($appEvents) {
            foreach ($event in $appEvents) {
                $eventTime = $event.TimeCreated
                $timeDiff = ($currentTime - $eventTime).TotalMinutes
                
                if ($timeDiff -le 30) {
                    $allJavaw += @{
                        PID = $null
                        StartTime = $null
                        EndTime = $eventTime
                        Memory = $null
                        MemoryGB = $null
                        Status = "Closed"
                        TimeSinceClosed = [math]::Round($timeDiff, 2)
                        LastEvent = $eventTime
                    }
                    $closedCount++
                }
            }
        }
    } catch { }
    
    # Метод 3: Prefetch анализ (работает всегда)
    $prefetchPath = "C:\Windows\Prefetch"
    if (Test-Path $prefetchPath) {
        try {
            $javaPrefetch = Get-ChildItem -Path $prefetchPath -Filter "JAVAW*.pf" -ErrorAction SilentlyContinue | 
                Where-Object { ($currentTime - $_.LastWriteTime).TotalMinutes -le 30 } |
                Sort-Object LastWriteTime -Descending
            
            if ($javaPrefetch) {
                foreach ($pf in $javaPrefetch) {
                    $lastWrite = $pf.LastWriteTime
                    $timeDiff = ($currentTime - $lastWrite).TotalMinutes
                    
                    $allJavaw += @{
                        PID = $null
                        StartTime = $null
                        EndTime = $lastWrite
                        Memory = $null
                        MemoryGB = $null
                        Status = "Closed"
                        TimeSinceClosed = [math]::Round($timeDiff, 2)
                        LastEvent = $lastWrite
                    }
                    $closedCount++
                }
            }
        } catch { }
    }
    
    if ($closedCount -gt 0) {
        Write-Host "  [+] Found $closedCount closed javaw.exe trace(s)" -ForegroundColor Green
    }
    
    
    # Убираем дубликаты по PID и времени
    $uniqueJavaw = @()
    $seenKeys = @{}
    
    foreach ($proc in $allJavaw) {
        $key = "$($proc.PID)_$($proc.LastEvent)"
        if (-not $seenKeys.ContainsKey($key)) {
            $seenKeys[$key] = $true
            $uniqueJavaw += $proc
        }
    }
    
    $allJavaw = $uniqueJavaw
    
    Write-Host "  [+] Found $($allJavaw.Count) javaw.exe process(es) (≥1GB, last 30min)" -ForegroundColor Green
    Write-Host ""
    
    # Сортируем по времени последнего события (для активных - StartTime, для закрытых - EndTime)
    $allJavaw = $allJavaw | Sort-Object -Property LastEvent -Descending
    
    # Показываем все найденные процессы
    $index = 1
    foreach ($proc in $allJavaw) {
        Write-Host "    [$index] ─────────────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host "    │ [PID $($proc.PID)] javaw.exe" -ForegroundColor White
        
        if ($proc.Status -eq "Active") {
            Write-Host "    │ Memory:  $($proc.Memory) MB ($($proc.MemoryGB) GB)" -ForegroundColor Gray
            Write-Host "    │ Started: $($proc.StartTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
            Write-Host "    │ Status:  ✅ ACTIVE" -ForegroundColor Green
        } else {
            if ($proc.StartTime) {
                Write-Host "    │ Started: $($proc.StartTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
            }
            Write-Host "    │ Closed:  $($proc.EndTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
            Write-Host "    │ Time ago: $($proc.TimeSinceClosed) minutes" -ForegroundColor Gray
            Write-Host "    │ Status:  ❌ CLOSED" -ForegroundColor Red
        }
        
        Write-Host "    └─────────────────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host ""
        $index++
    }
    
    # 3. Анализ: берем последние 2 javaw по времени
    Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║                          ANALYSIS RESULTS                               ║" -ForegroundColor Gray
    Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    
    $safemodeDetected = $false
    $suspicionLevel = 0
    
    if ($allJavaw.Count -ge 2) {
        # Берем последние 2 процесса по времени (LastEvent - самое свежее событие)
        $last2 = $allJavaw | Sort-Object -Property LastEvent -Descending | Select-Object -First 2
        
        $first = $last2[0]
        $second = $last2[1]
        
        Write-Host "  [~] Analyzing last 2 javaw processes..." -ForegroundColor Gray
        Write-Host ""
        Write-Host "    Recent Process #1:" -ForegroundColor White
        if ($first.PID) {
            Write-Host "      [PID $($first.PID)] - Status: $($first.Status)" -ForegroundColor Gray
        } else {
            Write-Host "      Status: $($first.Status)" -ForegroundColor Gray
        }
        
        if ($first.Status -eq "Active") {
            if ($first.StartTime) {
                Write-Host "      Started: $($first.StartTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
            }
        } else {
            if ($first.EndTime) {
                Write-Host "      Closed: $($first.EndTime.ToString('HH:mm:ss')) ($($first.TimeSinceClosed) min ago)" -ForegroundColor Gray
            } else {
                Write-Host "      Closed: $($first.TimeSinceClosed) min ago" -ForegroundColor Gray
            }
        }
        Write-Host ""
        
        Write-Host "    Recent Process #2:" -ForegroundColor White
        if ($second.PID) {
            Write-Host "      [PID $($second.PID)] - Status: $($second.Status)" -ForegroundColor Gray
        } else {
            Write-Host "      Status: $($second.Status)" -ForegroundColor Gray
        }
        
        if ($second.Status -eq "Active") {
            if ($second.StartTime) {
                Write-Host "      Started: $($second.StartTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
            }
        } else {
            if ($second.EndTime) {
                Write-Host "      Closed: $($second.EndTime.ToString('HH:mm:ss')) ($($second.TimeSinceClosed) min ago)" -ForegroundColor Gray
            } else {
                Write-Host "      Closed: $($second.TimeSinceClosed) min ago" -ForegroundColor Gray
            }
        }
        Write-Host ""
        
        # Проверяем условие SafeMode: один из 2-х закрыт менее 25 минут назад
        $hasClosedRecent = $false
        $closedProcess = $null
        
        if ($first.Status -eq "Closed" -and $first.TimeSinceClosed -le 25) {
            $hasClosedRecent = $true
            $closedProcess = $first
        }
        
        if ($second.Status -eq "Closed" -and $second.TimeSinceClosed -le 25) {
            $hasClosedRecent = $true
            $closedProcess = $second
        }
        
        # ГЛАВНОЕ ПРАВИЛО: если из последних 2 javaw один закрыт < 25 мин
        # НО ОБЯЗАТЕЛЬНО должен быть хотя бы 1 активный javaw сейчас
        $hasActiveNow = ($first.Status -eq "Active") -or ($second.Status -eq "Active")
        
        if ($hasClosedRecent -and $hasActiveNow) {
            $safemodeDetected = $true
            
            Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
            Write-Host "  ║                     🚨 SAFEMODE DETECTED! 🚨                           ║" -ForegroundColor Red
            Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Evidence:" -ForegroundColor Red
            Write-Host "    • Found 2 javaw.exe in last 30 minutes (>1GB)" -ForegroundColor White
            Write-Host "    • One process closed $($closedProcess.TimeSinceClosed) minutes ago" -ForegroundColor White
            Write-Host "    • One process is ACTIVE now" -ForegroundColor White
            Write-Host "    • Time window < 25 minutes = SAFEMODE pattern" -ForegroundColor White
            Write-Host ""
            
        } elseif ($hasClosedRecent -and -not $hasActiveNow) {
            # Закрыт недавно, но нет активных - не SafeMode
            Write-Host "  [ℹ️] Recent javaw activity detected" -ForegroundColor Gray
            Write-Host "      One process closed $($closedProcess.TimeSinceClosed) minutes ago" -ForegroundColor Gray
            Write-Host "      But NO active javaw running now - SafeMode NOT detected" -ForegroundColor Gray
            Write-Host ""
            
        } else {
            # Оба активны или закрыты давно
            $activeBoth = ($first.Status -eq "Active") -and ($second.Status -eq "Active")
            
            if ($activeBoth) {
                $suspicionLevel = 2
                
                Write-Host "  [⚠️] SUSPICIOUS: Two javaw.exe processes running" -ForegroundColor Yellow
                Write-Host "      This may indicate SafeMode preparation or dual-client setup" -ForegroundColor Yellow
                Write-Host ""
                
            } else {
                Write-Host "  [ℹ️] Two javaw processes found, but:" -ForegroundColor Gray
                Write-Host "      All closed processes are older than 25 minutes" -ForegroundColor Gray
                Write-Host "      SafeMode NOT detected" -ForegroundColor Gray
                Write-Host ""
            }
        }
        
    } elseif ($allJavaw.Count -eq 1) {
        Write-Host "  [ℹ️] Only 1 javaw process found" -ForegroundColor Gray
        Write-Host "      Not enough data to detect SafeMode" -ForegroundColor Gray
        Write-Host ""
        
    } else {
        Write-Host "  [ℹ️] No javaw processes found (>1GB, last 30min)" -ForegroundColor Gray
        Write-Host ""
    }
    
    # Финальная статистика
    Write-Host "  ─────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  📊 Statistics:" -ForegroundColor Gray
    Write-Host "     Total javaw found:         $($allJavaw.Count)" -ForegroundColor White
    Write-Host "     Active processes:          $(($allJavaw | Where-Object {$_.Status -eq 'Active'}).Count)" -ForegroundColor White
    Write-Host "     Closed (<30m):             $(($allJavaw | Where-Object {$_.Status -eq 'Closed'}).Count)" -ForegroundColor White
    Write-Host "     SafeMode detected:         $(if($safemodeDetected){'YES ❌'}else{'NO ✅'})" -ForegroundColor $(if($safemodeDetected){'Red'}else{'Green'})
    Write-Host "     Suspicion level:           $suspicionLevel/3" -ForegroundColor $(if($suspicionLevel -ge 2){'Yellow'}elseif($suspicionLevel -ge 1){'Gray'}else{'Green'})
    Write-Host "  ─────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Press Enter to return to menu"
    Clear-Host
    Show-Logo
    
} elseif ($choice -eq "6") {
    Clear-Host
    Show-Logo
    
    Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║                    BROWSER HISTORY SCANNER                              ║" -ForegroundColor Gray
    Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    
    # Список подозрительных сайтов
    $suspiciousSites = @(
        'deltadlc.xyz',
        'wexside.ru',
        'exploitclient.com',
        'systemdlc.com',
        'cortexclient.com',
        'mhub.fun',
        'wildclient.org',
        'nightclient.xyz',
        'nursultan.fun',
        'doomsdayclient.com',
        'fearclient.tilda.ws',
        'liminarclient.fun'
    )
    
    # Прогресс бар
    $barLength = 50
    Write-Host "  Scanning browsers... " -NoNewline -ForegroundColor Gray
    for ($i = 0; $i -le $barLength; $i++) {
        $percent = [math]::Round(($i / $barLength) * 100)
        $bar = "█" * $i + "░" * ($barLength - $i)
        Write-Host "`r  Scanning browsers... [$bar] $percent%" -NoNewline -ForegroundColor Gray
        Start-Sleep -Milliseconds 20
    }
    # Очищаем строку загрузки
    Write-Host "`r$(' ' * 80)" -NoNewline
    Write-Host "`r" -NoNewline
    Write-Host ""
    Write-Host ""
    
    $foundUrls = @{}
    $totalFound = 0
    
    # Функция для поиска URL в истории (скрытно)
    function Search-BrowserHistory {
        param($historyPath, $browserName)
        
        if (-not (Test-Path $historyPath)) {
            return
        }
        
        try {
            # Копируем файл истории (т.к. браузер может его блокировать)
            $tempHistory = "$env:TEMP\browser_history_temp.db"
            Copy-Item -Path $historyPath -Destination $tempHistory -Force -ErrorAction SilentlyContinue
            
            # Читаем SQLite базу данных истории
            Add-Type -AssemblyName System.Data
            $connection = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempHistory;Version=3;")
            $connection.Open()
            
            $command = $connection.CreateCommand()
            $command.CommandText = "SELECT url, visit_count FROM urls"
            
            $reader = $command.ExecuteReader()
            
            while ($reader.Read()) {
                $url = $reader["url"]
                $visitCount = $reader["visit_count"]
                
                foreach ($site in $suspiciousSites) {
                    if ($url -match $site) {
                        if ($foundUrls.ContainsKey($url)) {
                            $foundUrls[$url].Count += $visitCount
                            if (-not ($foundUrls[$url].Browsers -contains $browserName)) {
                                $foundUrls[$url].Browsers += @($browserName)
                            }
                        } else {
                            $foundUrls[$url] = @{
                                Count = $visitCount
                                Browsers = @($browserName)
                            }
                        }
                        $totalFound++
                        break
                    }
                }
            }
            
            $reader.Close()
            $connection.Close()
            Remove-Item -Path $tempHistory -Force -ErrorAction SilentlyContinue
            
        } catch {
            # Если SQLite не работает, используем простой текстовый поиск
            try {
                $content = Get-Content -Path $historyPath -Raw -ErrorAction SilentlyContinue
                
                foreach ($site in $suspiciousSites) {
                    $matches = [regex]::Matches($content, [regex]::Escape($site))
                    if ($matches.Count -gt 0) {
                        $url = "https://$site/"
                        if ($foundUrls.ContainsKey($url)) {
                            $foundUrls[$url].Count += $matches.Count
                            if (-not ($foundUrls[$url].Browsers -contains $browserName)) {
                                $foundUrls[$url].Browsers += @($browserName)
                            }
                        } else {
                            $foundUrls[$url] = @{
                                Count = $matches.Count
                                Browsers = @($browserName)
                            }
                        }
                        $totalFound += $matches.Count
                    }
                }
            } catch { }
        }
    }
    
    # Пути к истории браузеров
    $chromeHistory = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
    $edgeHistory = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
    $operaHistory = "$env:APPDATA\Opera Software\Opera Stable\History"
    $operaGXHistory = "$env:APPDATA\Opera Software\Opera GX Stable\History"
    $yandexHistory = "$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\History"
    $braveHistory = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\History"
    $vivaldiHistory = "$env:LOCALAPPDATA\Vivaldi\User Data\Default\History"
    $torHistory = "$env:APPDATA\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\places.sqlite"
    $firefoxProfile = "$env:APPDATA\Mozilla\Firefox\Profiles"
    
    # Сканируем Chrome
    Search-BrowserHistory -historyPath $chromeHistory -browserName "Google Chrome"
    
    # Сканируем Edge
    Search-BrowserHistory -historyPath $edgeHistory -browserName "Microsoft Edge"
    
    # Сканируем Opera
    Search-BrowserHistory -historyPath $operaHistory -browserName "Opera"
    
    # Сканируем Opera GX
    Search-BrowserHistory -historyPath $operaGXHistory -browserName "Opera GX"
    
    # Сканируем Yandex
    Search-BrowserHistory -historyPath $yandexHistory -browserName "Yandex Browser"
    
    # Сканируем Brave
    Search-BrowserHistory -historyPath $braveHistory -browserName "Brave"
    
    # Сканируем Vivaldi
    Search-BrowserHistory -historyPath $vivaldiHistory -browserName "Vivaldi"
    
    # Сканируем Tor Browser
    if (Test-Path $torHistory) {
        try {
            $tempHistory = "$env:TEMP\tor_history_temp.db"
            Copy-Item -Path $torHistory -Destination $tempHistory -Force -ErrorAction SilentlyContinue
            
            $content = Get-Content -Path $tempHistory -Raw -ErrorAction SilentlyContinue
            
            foreach ($site in $suspiciousSites) {
                $matches = [regex]::Matches($content, [regex]::Escape($site))
                if ($matches.Count -gt 0) {
                    $url = "https://$site/"
                    if ($foundUrls.ContainsKey($url)) {
                        $foundUrls[$url].Count += $matches.Count
                        if (-not ($foundUrls[$url].Browsers -contains "Tor Browser")) {
                            $foundUrls[$url].Browsers += @("Tor Browser")
                        }
                    } else {
                        $foundUrls[$url] = @{
                            Count = $matches.Count
                            Browsers = @("Tor Browser")
                        }
                    }
                    $totalFound += $matches.Count
                }
            }
            
            Remove-Item -Path $tempHistory -Force -ErrorAction SilentlyContinue
        } catch { }
    }
    
    # Сканируем Firefox (имеет несколько профилей)
    if (Test-Path $firefoxProfile) {
        $profiles = Get-ChildItem -Path $firefoxProfile -Directory -ErrorAction SilentlyContinue
        foreach ($profile in $profiles) {
            $firefoxHistory = Join-Path $profile.FullName "places.sqlite"
            if (Test-Path $firefoxHistory) {
                try {
                    $tempHistory = "$env:TEMP\firefox_history_temp.db"
                    Copy-Item -Path $firefoxHistory -Destination $tempHistory -Force -ErrorAction SilentlyContinue
                    
                    $content = Get-Content -Path $tempHistory -Raw -ErrorAction SilentlyContinue
                    
                    foreach ($site in $suspiciousSites) {
                        $matches = [regex]::Matches($content, [regex]::Escape($site))
                        if ($matches.Count -gt 0) {
                            $url = "https://$site/"
                            if ($foundUrls.ContainsKey($url)) {
                                $foundUrls[$url].Count += $matches.Count
                                if (-not ($foundUrls[$url].Browsers -contains "Firefox")) {
                                    $foundUrls[$url].Browsers += @("Firefox")
                                }
                            } else {
                                $foundUrls[$url] = @{
                                    Count = $matches.Count
                                    Browsers = @("Firefox")
                                }
                            }
                            $totalFound += $matches.Count
                        }
                    }
                    
                    Remove-Item -Path $tempHistory -Force -ErrorAction SilentlyContinue
                } catch { }
            }
        }
    }
    
    Write-Host ""
    
    # Показываем результаты
    if ($foundUrls.Count -gt 0) {
        Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "  ║                     🚨 SUSPICIOUS SITES DETECTED! 🚨                   ║" -ForegroundColor Red
        Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        
        $sortedUrls = $foundUrls.GetEnumerator() | Sort-Object -Property {$_.Value.Count} -Descending
        
        foreach ($entry in $sortedUrls) {
            Write-Host "    • $($entry.Key)" -ForegroundColor White -NoNewline
            Write-Host " - $($entry.Value.Count) visit(s)" -ForegroundColor Red
            Write-Host "      Browser(s): $($entry.Value.Browsers -join ', ')" -ForegroundColor Gray
        }
        
        Write-Host ""
        
    } else {
        Write-Host "  [✓] NO SUSPICIOUS ACTIVITY DETECTED" -ForegroundColor Green
        Write-Host ""
        Write-Host "    No visits or accounts found for known cheat websites." -ForegroundColor Gray
        Write-Host ""
    }
    
    # Статистика
    Write-Host "  ─────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  📊 Statistics:" -ForegroundColor Gray
    Write-Host "     Browsers scanned:          9 (Chrome, Edge, Opera, Opera GX, Yandex, Brave, Vivaldi, Tor, Firefox)" -ForegroundColor White
    Write-Host "     Suspicious sites visited:  $($foundUrls.Count)" -ForegroundColor $(if($foundUrls.Count -gt 0){'Red'}else{'Green'})
    Write-Host "     Total visits:              $totalFound" -ForegroundColor $(if($totalFound -gt 0){'Red'}else{'Green'})
    Write-Host "  ─────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Press Enter to return to menu"
    Clear-Host
    Show-Logo
    
} elseif ($choice -eq "0") {
    exit
    
} else {
    Write-Host ""
    Write-Host "Invalid choice!" -ForegroundColor Red
    Start-Sleep -Seconds 1
    Clear-Host
    Show-Logo
}

}




