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
    
    Write-Host ""
    Write-Host "  =========================================================================" -ForegroundColor Yellow
    Write-Host "                    BROWSER HISTORY SCANNER                              " -ForegroundColor Yellow
    Write-Host "  =========================================================================" -ForegroundColor Yellow
    Write-Host ""
    
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
        'liminarclient.fun',
        'vapeclient.net',
        'liquidbounce.net',
        'wurstclient.net',
        'meteorclient.com'
    )
    
    Write-Host "  [*] Starting browser scan..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Checking browsers:" -ForegroundColor Gray
    Write-Host "    - Google Chrome" -ForegroundColor DarkGray
    Write-Host "    - Microsoft Edge" -ForegroundColor DarkGray
    Write-Host "    - Opera / Opera GX" -ForegroundColor DarkGray
    Write-Host "    - Yandex Browser" -ForegroundColor DarkGray
    Write-Host "    - Brave / Vivaldi" -ForegroundColor DarkGray
    Write-Host "    - Firefox (all profiles)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Searching for:" -ForegroundColor Gray
    Write-Host "    - systemdlc.com, deltadlc.xyz, wexside.ru" -ForegroundColor DarkGray
    Write-Host "    - mhub.fun, cortexclient.com, wildclient.org" -ForegroundColor DarkGray
    Write-Host "    - liquidbounce.net, wurstclient.net, meteorclient.com" -ForegroundColor DarkGray
    Write-Host "    - and more cheat sites..." -ForegroundColor DarkGray
    Write-Host ""
    
    $foundUrls = @{}
    $totalFound = 0
    
    function Search-BrowserHistory {
        param($historyPath, $browserName)
        
        if (-not (Test-Path $historyPath)) {
            return
        }
        
        try {
            $tempHistory = "$env:TEMP\browser_history_temp.db"
            Copy-Item -Path $historyPath -Destination $tempHistory -Force -ErrorAction SilentlyContinue
            
            Add-Type -AssemblyName System.Data
            $connection = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempHistory;Version=3;")
            $connection.Open()
            
            $command = $connection.CreateCommand()
            $command.CommandText = "SELECT url, visit_count FROM urls"
            
            $reader = $command.ExecuteReader()
            
            while ($reader.Read()) {
                $url = $reader["url"]
                $visitCount = $reader["visit_count"]
                
                foreach ($site in $script:suspiciousSites) {
                    if ($url -match $site) {
                        if ($script:foundUrls.ContainsKey($url)) {
                            $script:foundUrls[$url].Count += $visitCount
                            if (-not ($script:foundUrls[$url].Browsers -contains $browserName)) {
                                $script:foundUrls[$url].Browsers += @($browserName)
                            }
                        } else {
                            $script:foundUrls[$url] = @{
                                Count = $visitCount
                                Browsers = @($browserName)
                            }
                        }
                        $script:totalFound++
                        break
                    }
                }
            }
            
            $reader.Close()
            $connection.Close()
            Remove-Item -Path $tempHistory -Force -ErrorAction SilentlyContinue
            
        } catch {
            try {
                $content = Get-Content -Path $historyPath -Raw -ErrorAction SilentlyContinue
                
                foreach ($site in $script:suspiciousSites) {
                    $matches = [regex]::Matches($content, [regex]::Escape($site))
                    if ($matches.Count -gt 0) {
                        $url = "https://$site/"
                        if ($script:foundUrls.ContainsKey($url)) {
                            $script:foundUrls[$url].Count += $matches.Count
                            if (-not ($script:foundUrls[$url].Browsers -contains $browserName)) {
                                $script:foundUrls[$url].Browsers += @($browserName)
                            }
                        } else {
                            $script:foundUrls[$url] = @{
                                Count = $matches.Count
                                Browsers = @($browserName)
                            }
                        }
                        $script:totalFound += $matches.Count
                    }
                }
            } catch { }
        }
    }
    
    $chromeHistory = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
    $edgeHistory = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
    $operaHistory = "$env:APPDATA\Opera Software\Opera Stable\History"
    $operaGXHistory = "$env:APPDATA\Opera Software\Opera GX Stable\History"
    $yandexHistory = "$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\History"
    $braveHistory = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\History"
    $vivaldiHistory = "$env:LOCALAPPDATA\Vivaldi\User Data\Default\History"
    $firefoxProfile = "$env:APPDATA\Mozilla\Firefox\Profiles"
    
    Write-Host "  [~] Scanning Chrome..." -ForegroundColor Gray
    Search-BrowserHistory -historyPath $chromeHistory -browserName "Google Chrome"
    
    Write-Host "  [~] Scanning Edge..." -ForegroundColor Gray
    Search-BrowserHistory -historyPath $edgeHistory -browserName "Microsoft Edge"
    
    Write-Host "  [~] Scanning Opera..." -ForegroundColor Gray
    Search-BrowserHistory -historyPath $operaHistory -browserName "Opera"
    Search-BrowserHistory -historyPath $operaGXHistory -browserName "Opera GX"
    
    Write-Host "  [~] Scanning Yandex..." -ForegroundColor Gray
    Search-BrowserHistory -historyPath $yandexHistory -browserName "Yandex Browser"
    
    Write-Host "  [~] Scanning Brave/Vivaldi..." -ForegroundColor Gray
    Search-BrowserHistory -historyPath $braveHistory -browserName "Brave"
    Search-BrowserHistory -historyPath $vivaldiHistory -browserName "Vivaldi"
    
    # Firefox (РЅРµСЃРєРѕР»СЊРєРѕ РїСЂРѕС„РёР»РµР№)
    Write-Host "  [~] Scanning Firefox..." -ForegroundColor Gray
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
    
    if ($foundUrls.Count -gt 0) {
        Write-Host "  =========================================================================" -ForegroundColor Red
        Write-Host "                     SUSPICIOUS SITES DETECTED!                          " -ForegroundColor Red
        Write-Host "  =========================================================================" -ForegroundColor Red
        Write-Host ""
        
        $sortedUrls = $foundUrls.GetEnumerator() | Sort-Object -Property {$_.Value.Count} -Descending
        
        foreach ($entry in $sortedUrls) {
            Write-Host "    - $($entry.Key)" -ForegroundColor White -NoNewline
            Write-Host " - $($entry.Value.Count) visit(s)" -ForegroundColor Red
            Write-Host "      Browser(s): $($entry.Value.Browsers -join ', ')" -ForegroundColor Gray
        }
        
        Write-Host ""
        
    } else {
        Write-Host "  [OK] NO SUSPICIOUS ACTIVITY DETECTED" -ForegroundColor Green
        Write-Host ""
        Write-Host "    No visits found for known cheat websites." -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host ""
    Write-Host "  =======================================================================" -ForegroundColor Gray
    Write-Host ""
    Read-Host "  Press Enter to return to menu"

# ============================================================================
# SECTION 2: MODS ANALYZER
# ============================================================================

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
    
    # PulseVisuals РѕР±СЂР°Р±РѕС‚РєР° (С‚РѕР»СЊРєРѕ 1.21+)
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
                
                foreach ($jar in $jarFiles) {
                    $processedCount++
                    Write-Host "  [$processedCount/$($jarFiles.Count)] Analyzing: $($jar.Name)" -ForegroundColor Gray
                    
                    $isSuspicious = $false
                    $reason = ""
                    $detailsFound = @()
                    
                    # Check filename
                    Write-Host "    -> Checking filename..." -ForegroundColor DarkGray
                    foreach ($cheatString in $cheatStrings) {
                        if ($jar.Name -match $cheatString) {
                            $isSuspicious = $true
                            $reason = "Suspicious pattern in name: $cheatString"
                            $detailsFound += "Pattern: $cheatString"
                            Write-Host "      [!] Found pattern: $cheatString" -ForegroundColor Yellow
                            break
                        }
                    }
                    
                    # Check file size
                    if (-not $isSuspicious) {
                        Write-Host "    -> Checking file size..." -ForegroundColor DarkGray
                        if ($jar.Length -lt 10KB) {
                            $isSuspicious = $true
                            $reason = "Suspiciously small file size ($([math]::Round($jar.Length / 1KB, 2)) KB)"
                            $detailsFound += "Very small size"
                            Write-Host "      [!] Suspicious size: $([math]::Round($jar.Length / 1KB, 2)) KB" -ForegroundColor Yellow
                        }
                    }
                    
                    # Check obfuscation
                    if (-not $isSuspicious) {
                        Write-Host "    -> Checking for obfuscation..." -ForegroundColor DarkGray
                        if ($jar.BaseName -match '^[a-z]{1,3}$') {
                            $isSuspicious = $true
                            $reason = "Obfuscated name pattern (short random name)"
                            $detailsFound += "Obfuscated name"
                            Write-Host "      [!] Obfuscated name detected" -ForegroundColor Yellow
                        }
                    }
                    
                    # Deep scan inside JAR
                    Write-Host "    -> Scanning JAR internal classes..." -ForegroundColor DarkGray
                    try {
                        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
                        
                        $classCount = 0
                        $foundCheatClasses = @()
                        
                        foreach ($entry in $zip.Entries) {
                            if ($entry.FullName -match '\.class$') {
                                $classCount++
                                
                                # Check for cheat class names
                                foreach ($cheatString in $cheatStrings) {
                                    if ($entry.FullName -match $cheatString) {
                                        $foundCheatClasses += "$cheatString in $($entry.FullName)"
                                        if (-not $isSuspicious) {
                                            $isSuspicious = $true
                                            $reason = "Cheat classes found inside JAR"
                                        }
                                    }
                                }
                            }
                        }
                        
                        Write-Host "      Total classes: $classCount" -ForegroundColor DarkGray
                        
                        if ($foundCheatClasses.Count -gt 0) {
                            Write-Host "      [!] FOUND $($foundCheatClasses.Count) CHEAT CLASSES:" -ForegroundColor Red
                            foreach ($cls in $foundCheatClasses) {
                                Write-Host "        - $cls" -ForegroundColor Red
                                $detailsFound += $cls
                            }
                        }
                        
                        $zip.Dispose()
                    } catch {
                        Write-Host "      Could not scan JAR internals" -ForegroundColor DarkGray
                    }
                    
                    if ($isSuspicious) {
                        Write-Host "    [SUSPICIOUS] Added to report" -ForegroundColor Red
                        $suspiciousMods += @{
                            Name = $jar.Name
                            Size = $jar.Length
                            Reason = $reason
                            Details = $detailsFound
                        }
                    } else {
                        Write-Host "    [OK] Looks legitimate" -ForegroundColor Green
                    }
                    Write-Host ""
                }
                
                Write-Host "  =======================================================================" -ForegroundColor Gray
                Write-Host ""
                
                if ($suspiciousMods.Count -gt 0) {
                    Write-Host "  [!] SUSPICIOUS MODS DETECTED: $($suspiciousMods.Count)" -ForegroundColor Red
                    Write-Host ""
                    
                    foreach ($mod in $suspiciousMods) {
                        Write-Host "  -> $($mod.Name)" -ForegroundColor Red
                        Write-Host "    Reason: $($mod.Reason)" -ForegroundColor Yellow
                        Write-Host "    Size: $([math]::Round($mod.Size / 1KB, 2)) KB" -ForegroundColor Gray
                        if ($mod.Details) {
                            Write-Host "    Details found:" -ForegroundColor Yellow
                            foreach ($detail in $mod.Details) {
                                Write-Host "      - $detail" -ForegroundColor DarkYellow
                            }
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
