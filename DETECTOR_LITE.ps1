# ============================================================================
# DETECTOR LITE V2 - Browser & Mods Scanner (From READINESS.exe)
# ============================================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = 'Detector Lite v2.0'
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# ============================================================================
# LOGO
# ============================================================================

function Show-Logo {
    Write-Host ""
    Write-Host "  =============================================================" -ForegroundColor Cyan
    Write-Host "                                                               " -ForegroundColor Cyan
    Write-Host "                    DETECTOR LITE v2.0                         " -ForegroundColor Cyan
    Write-Host "                                                               " -ForegroundColor Cyan
    Write-Host "          Browser & Mods Cheat Detection System                " -ForegroundColor Cyan
    Write-Host "                                                               " -ForegroundColor Cyan
    Write-Host "  =============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  -------------------------------------------------------------" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select scan mode:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Browser History Scanner" -ForegroundColor White
    Write-Host "  [2] Mods Analyzer" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  -------------------------------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

# ============================================================================
# MAIN LOOP
# ============================================================================

while ($true) {
    Clear-Host
    Show-Logo
    
    $choice = Read-Host "  Enter choice"

# ============================================================================
# SECTION 1: BROWSER HISTORY SCANNER
# ============================================================================

if ($choice -eq "1") {
    Clear-Host
    Show-Logo
    
    Write-Host "  =========================================" -ForegroundColor Gray
    Write-Host "  |                    BROWSER HISTORY SCANNER                              |" -ForegroundColor Gray
    Write-Host "  =========================================" -ForegroundColor Gray
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
        $bar = "#" * $i + "." * ($barLength - $i)
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
        Write-Host "  =========================================" -ForegroundColor Red
        Write-Host "  |                     🚨 SUSPICIOUS SITES DETECTED! 🚨                   |" -ForegroundColor Red
        Write-Host "  =========================================" -ForegroundColor Red
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
    

} elseif ($choice -eq "2") {
    Clear-Host
    Show-Logo
    
    Write-Host ""
    Write-Host "  =========================================================================" -ForegroundColor Green
    Write-Host "                         MODS ANALYZER                                   " -ForegroundColor Green
    Write-Host "  =========================================================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "  [~] Searching for Minecraft installations..." -ForegroundColor Cyan
    Write-Host ""
    
    $modsFolders = @()
    $activeModsPath = $null
    
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    if ($javawProcesses) {
        foreach ($proc in $javawProcesses) {
            try {
                $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
                if ($memoryGB -lt 1) { continue }
                
                $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
                
                if ($cmdLine -match '--gameDir\s+([^\s]+)') {
                    $gameDir = $matches[1].Trim('"')
                    $modsPath = Join-Path $gameDir "mods"
                    if (Test-Path $modsPath) {
                        $activeModsPath = $modsPath
                        break
                    }
                }
            } catch { }
        }
    }
    
    $searchPaths = @(
        "$env:APPDATA\.minecraft\mods",
        "$env:APPDATA\.tlauncher\legacy\Minecraft\game\mods",
        "$env:APPDATA\PrismLauncher\instances",
        "C:\PulseVisuals\game\usermods"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            if ($path -like "*PrismLauncher*") {
                $instances = Get-ChildItem $path -Directory -ErrorAction SilentlyContinue
                foreach ($instance in $instances) {
                    $instanceMods = Join-Path $instance.FullName ".minecraft\mods"
                    if (Test-Path $instanceMods) {
                        $mods = Get-ChildItem $instanceMods -Filter "*.jar" -ErrorAction SilentlyContinue
                        if ($mods.Count -gt 0) {
                            $modsFolders += $instanceMods
                        }
                    }
                }
            } else {
                $jars = Get-ChildItem $path -Filter "*.jar" -ErrorAction SilentlyContinue
                if ($jars.Count -gt 0) {
                    $modsFolders += $path
                }
            }
        }
    }
    
    # PulseVisuals Р С•Р В±РЎР‚Р В°Р В±Р С•РЎвЂљР С”Р В° (РЎвЂљР С•Р В»РЎРЉР С”Р С• 1.21+)
    if (Test-Path "C:\PulseVisuals\game\usermods") {
        $versionFolders = Get-ChildItem "C:\PulseVisuals\game\usermods" -Directory -ErrorAction SilentlyContinue
        foreach ($versionFolder in $versionFolders) {
            if ($versionFolder.Name -ne '1.16.5') {
                $jars = Get-ChildItem $versionFolder.FullName -Filter "*.jar" -ErrorAction SilentlyContinue
                if ($jars.Count -gt 0) {
                    $modsFolders += $versionFolder.FullName
                }
            }
        }
    }
    
    if ($activeModsPath -and -not ($modsFolders -contains $activeModsPath)) {
        $modsFolders = @($activeModsPath) + $modsFolders
    }
    
    if ($modsFolders.Count -eq 0) {
        Write-Host "  [!] No mods folders found!" -ForegroundColor Gray
        Write-Host ""
        Read-Host "  Press Enter to return to menu"
    } else {
        if ($activeModsPath) {
            Write-Host "  [!] Active Minecraft detected!" -ForegroundColor Green
            Write-Host ""
        }
        
        Write-Host "  Found $($modsFolders.Count) mods folder(s):" -ForegroundColor Green
        Write-Host ""
        
        for ($i = 0; $i -lt $modsFolders.Count; $i++) {
            $prefix = "  [$($i+1)] "
            
            if ($activeModsPath -and $modsFolders[$i] -eq $activeModsPath) {
                Write-Host $prefix -ForegroundColor Cyan -NoNewline
                Write-Host "[ACTIVE] " -ForegroundColor Green -NoNewline
                Write-Host $modsFolders[$i] -ForegroundColor White
            } else {
                Write-Host $prefix -ForegroundColor White -NoNewline
                Write-Host $modsFolders[$i] -ForegroundColor Gray
            }
        }
        
        Write-Host ""
        Write-Host "  [0] Custom folder" -ForegroundColor Yellow
        Write-Host ""
        
        $folderChoice = Read-Host "  Select folder"
        
        if ([string]::IsNullOrWhiteSpace($folderChoice)) {
            continue
        }
        
        $selectedFolder = $null
        
        if ($folderChoice -eq "0") {
            $customPath = Read-Host "  Enter custom mods folder path"
            
            if ([string]::IsNullOrWhiteSpace($customPath)) {
                continue
            }
            
            if (Test-Path $customPath) {
                $testJars = Get-ChildItem -Path $customPath -Filter "*.jar" -ErrorAction SilentlyContinue
                
                if ($testJars.Count -gt 0) {
                    $selectedFolder = $customPath
                    Write-Host ""
                    Write-Host "  [OK] Found $($testJars.Count) JAR file(s)" -ForegroundColor Green
                    Write-Host ""
                } else {
                    Write-Host ""
                    Write-Host "  [!] No JAR files found!" -ForegroundColor Red
                    Write-Host ""
                    Read-Host "  Press Enter to return"
                    continue
                }
            } else {
                Write-Host ""
                Write-Host "  [!] Path not found!" -ForegroundColor Red
                Write-Host ""
                Read-Host "  Press Enter to return"
                continue
            }
        }
        elseif ($folderChoice -match '^\d+$' -and [int]$folderChoice -gt 0 -and [int]$folderChoice -le $modsFolders.Count) {
            $selectedFolder = $modsFolders[[int]$folderChoice - 1]
        }
        else {
            continue
        }
        
        if ($selectedFolder) {
            Write-Host ""
            Write-Host "  [~] Scanning: $selectedFolder" -ForegroundColor Cyan
            Write-Host ""
            
            $jarFiles = Get-ChildItem -Path $selectedFolder -Filter "*.jar" -ErrorAction SilentlyContinue
            
            if ($jarFiles.Count -eq 0) {
                Write-Host "  [!] No JAR files found" -ForegroundColor Gray
            } else {
                Write-Host "  Found $($jarFiles.Count) JAR file(s)" -ForegroundColor Gray
                Write-Host ""
                Write-Host "  [*] Starting deep analysis..." -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Checking for:" -ForegroundColor Gray
                Write-Host "    - Known cheat clients (Liminar, Doomsday, etc.)" -ForegroundColor DarkGray
                Write-Host "    - Cheat modules (AutoCrystal, Killaura, etc.)" -ForegroundColor DarkGray
                Write-Host "    - Forbidden mods (XRay, Minimap, Baritone, etc.)" -ForegroundColor DarkGray
                Write-Host "    - Obfuscated files and suspicious patterns" -ForegroundColor DarkGray
                Write-Host "    - Small file sizes (< 10KB)" -ForegroundColor DarkGray
                Write-Host ""
                
                Add-Type -Assembly System.IO.Compression.FileSystem
                
                $cheatStrings = @(
                    'AutoCrystal','AutoAnchor','AutoTotem','AimAssist','TriggerBot',
                    'Killaura','KillAura','AutoClicker','AutoPot','ShieldBreaker','FakeLag',
                    'AutoDoubleHand','MaceSwap','AutoWeb','LiminarClient','Liminar',
                    'BlockESP','ElytraSwap','NoSlow','WallHack','ChestStealer',
                    'ReplayMod','FlashBack','XRay','Minimap','Voxelmap','JourneyMap',
                    'Baritone','Schematica','Litematica','FreeCam','Freecam','WorldEdit',
                    'Pojav','FCL','MobileEmulator','Hitbox','HitBox','Reach','AntiKnockback',
                    'Velocity','Speed','Fly','Flight','NoFall','ESP','Tracers','Aimbot'
                )
                
                $suspiciousMods = @()
                $processedCount = 0
                
                Write-Host "  Scanning..." -ForegroundColor Gray
                
                foreach ($jar in $jarFiles) {
                    $processedCount++
                    $isSuspicious = $false
                    $reason = ""
                    $cheatClassesFound = @()
                    
                    foreach ($cheatString in $cheatStrings) {
                        if ($jar.Name -match $cheatString) {
                            $isSuspicious = $true
                            $reason = "Cheat pattern in filename"
                            break
                        }
                    }
                    
                    if ($jar.Length -lt 10KB) {
                        $isSuspicious = $true
                        $reason = "Very small size"
                    }
                    
                    if ($jar.BaseName -match '^[a-z]{1,3}$') {
                        $isSuspicious = $true
                        $reason = "Obfuscated filename"
                    }
                    
                    try {
                        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
                        
                        foreach ($entry in $zip.Entries) {
                            if ($entry.FullName -match '\.class$') {
                                foreach ($cheatString in $cheatStrings) {
                                    if ($entry.FullName -match $cheatString) {
                                        if (-not ($cheatClassesFound -contains $cheatString)) {
                                            $cheatClassesFound += $cheatString
                                        }
                                        if (-not $isSuspicious) {
                                            $isSuspicious = $true
                                            $reason = "Cheat classes detected"
                                        }
                                    }
                                }
                            }
                        }
                        
                        $zip.Dispose()
                    } catch { }
                    
                    if ($isSuspicious) {
                        $suspiciousMods += @{
                            Name = $jar.Name
                            Size = $jar.Length
                            Reason = $reason
                            CheatClasses = $cheatClassesFound
                        }
                    }
                }
                
                Write-Host ""
                
                Write-Host "  =======================================================================" -ForegroundColor Gray
                Write-Host ""
                
                if ($suspiciousMods.Count -gt 0) {
                    Write-Host "  [!] SUSPICIOUS MODS DETECTED: $($suspiciousMods.Count)" -ForegroundColor Red
                    Write-Host ""
                    
                    foreach ($mod in $suspiciousMods) {
                        Write-Host "  -> $($mod.Name)" -ForegroundColor Red
                        Write-Host "     $($mod.Reason)" -ForegroundColor Yellow
                        if ($mod.CheatClasses.Count -gt 0) {
                            Write-Host "     Cheat classes: $($mod.CheatClasses -join ', ')" -ForegroundColor DarkRed
                        }
                        Write-Host ""
                    }
                } else {
                    Write-Host "  [OK] All mods appear legitimate" -ForegroundColor Green
                    Write-Host "    Total mods scanned: $($jarFiles.Count)" -ForegroundColor Gray
                }
                
                Write-Host ""
                Write-Host "  =======================================================================" -ForegroundColor Gray
                Write-Host ""
            }
            
            Read-Host "  Press Enter to return to menu"
        }
    }

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
