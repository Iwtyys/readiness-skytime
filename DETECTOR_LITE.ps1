# ============================================================================
# DETECTOR LITE - Browser & Mods Scanner
# ============================================================================

$ErrorActionPreference = "SilentlyContinue"

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $arguments = "-ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

$Host.UI.RawUI.WindowTitle = 'Detector Lite v1.0'
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# ============================================================================
# LOGO
# ============================================================================

function Show-Logo {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║                                                               ║" -ForegroundColor Cyan
    Write-Host "  ║                    DETECTOR LITE v1.0                         ║" -ForegroundColor Cyan
    Write-Host "  ║                                                               ║" -ForegroundColor Cyan
    Write-Host "  ║             Browser & Mods Cheat Detection                    ║" -ForegroundColor Cyan
    Write-Host "  ║                                                               ║" -ForegroundColor Cyan
    Write-Host "  ╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ───────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select scan mode:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Browser History Scanner" -ForegroundColor White
    Write-Host "  [2] Mods Analyzer" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ───────────────────────────────────────────────────────────────" -ForegroundColor Gray
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
    Write-Host "  ╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "  ║                  BROWSER HISTORY SCANNER                      ║" -ForegroundColor Yellow
    Write-Host "  ╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    
    $detections = @()
    
    # Ключевые слова для поиска
    $keywords = @(
        "cheat", "hack", "inject", "bypass", "cracked", "crack",
        "systemdlc", "vape", "liquidbounce", "wurst", "meteor",
        "aristois", "impact", "sigma", "flux", "jello",
        "download cheat", "minecraft hack", "free cheat"
    )
    
    # Chrome
    Write-Host "  [1/4] Checking Chrome..." -ForegroundColor Cyan
    $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
    if (Test-Path $chromePath) {
        $tempChrome = "$env:TEMP\chrome_history_temp"
        Copy-Item $chromePath $tempChrome -Force -ErrorAction SilentlyContinue
        
        try {
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempChrome")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 1000"
            $reader = $cmd.ExecuteReader()
            
            while ($reader.Read()) {
                $url = $reader["url"]
                $title = $reader["title"]
                
                foreach ($keyword in $keywords) {
                    if ($url -match $keyword -or $title -match $keyword) {
                        $detections += @{
                            Browser = "Chrome"
                            URL = $url
                            Title = $title
                            Keyword = $keyword
                        }
                        break
                    }
                }
            }
            $reader.Close()
            $conn.Close()
        } catch {
            Write-Host "      [!] Chrome database error (may be encrypted)" -ForegroundColor Yellow
        }
        
        Remove-Item $tempChrome -Force -ErrorAction SilentlyContinue
        Write-Host "      [+] Chrome checked" -ForegroundColor Green
    } else {
        Write-Host "      [-] Chrome not found" -ForegroundColor Gray
    }
    
    # Edge
    Write-Host "  [2/4] Checking Edge..." -ForegroundColor Cyan
    $edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
    if (Test-Path $edgePath) {
        $tempEdge = "$env:TEMP\edge_history_temp"
        Copy-Item $edgePath $tempEdge -Force -ErrorAction SilentlyContinue
        
        try {
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempEdge")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT url, title FROM urls ORDER BY last_visit_time DESC LIMIT 1000"
            $reader = $cmd.ExecuteReader()
            
            while ($reader.Read()) {
                $url = $reader["url"]
                $title = $reader["title"]
                
                foreach ($keyword in $keywords) {
                    if ($url -match $keyword -or $title -match $keyword) {
                        $detections += @{
                            Browser = "Edge"
                            URL = $url
                            Title = $title
                            Keyword = $keyword
                        }
                        break
                    }
                }
            }
            $reader.Close()
            $conn.Close()
        } catch {
            Write-Host "      [!] Edge database error" -ForegroundColor Yellow
        }
        
        Remove-Item $tempEdge -Force -ErrorAction SilentlyContinue
        Write-Host "      [+] Edge checked" -ForegroundColor Green
    } else {
        Write-Host "      [-] Edge not found" -ForegroundColor Gray
    }
    
    # Firefox
    Write-Host "  [3/4] Checking Firefox..." -ForegroundColor Cyan
    $firefoxPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $firefoxPath) {
        $profiles = Get-ChildItem $firefoxPath -Directory
        foreach ($profile in $profiles) {
            $placesDb = Join-Path $profile.FullName "places.sqlite"
            if (Test-Path $placesDb) {
                $tempFirefox = "$env:TEMP\firefox_places_temp"
                Copy-Item $placesDb $tempFirefox -Force -ErrorAction SilentlyContinue
                
                try {
                    $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempFirefox")
                    $conn.Open()
                    $cmd = $conn.CreateCommand()
                    $cmd.CommandText = "SELECT url, title FROM moz_places ORDER BY last_visit_date DESC LIMIT 1000"
                    $reader = $cmd.ExecuteReader()
                    
                    while ($reader.Read()) {
                        $url = $reader["url"]
                        $title = $reader["title"]
                        
                        foreach ($keyword in $keywords) {
                            if ($url -match $keyword -or $title -match $keyword) {
                                $detections += @{
                                    Browser = "Firefox"
                                    URL = $url
                                    Title = $title
                                    Keyword = $keyword
                                }
                                break
                            }
                        }
                    }
                    $reader.Close()
                    $conn.Close()
                } catch { }
                
                Remove-Item $tempFirefox -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "      [+] Firefox checked" -ForegroundColor Green
    } else {
        Write-Host "      [-] Firefox not found" -ForegroundColor Gray
    }
    
    # Opera GX
    Write-Host "  [4/4] Checking Opera GX..." -ForegroundColor Cyan
    $operaPath = "$env:APPDATA\Opera Software\Opera GX Stable\History"
    if (Test-Path $operaPath) {
        $tempOpera = "$env:TEMP\opera_history_temp"
        Copy-Item $operaPath $tempOpera -Force -ErrorAction SilentlyContinue
        
        try {
            $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempOpera")
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT url, title FROM urls ORDER BY last_visit_time DESC LIMIT 1000"
            $reader = $cmd.ExecuteReader()
            
            while ($reader.Read()) {
                $url = $reader["url"]
                $title = $reader["title"]
                
                foreach ($keyword in $keywords) {
                    if ($url -match $keyword -or $title -match $keyword) {
                        $detections += @{
                            Browser = "Opera GX"
                            URL = $url
                            Title = $title
                            Keyword = $keyword
                        }
                        break
                    }
                }
            }
            $reader.Close()
            $conn.Close()
        } catch { }
        
        Remove-Item $tempOpera -Force -ErrorAction SilentlyContinue
        Write-Host "      [+] Opera GX checked" -ForegroundColor Green
    } else {
        Write-Host "      [-] Opera GX not found" -ForegroundColor Gray
    }
    
    # Результаты
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    
    if ($detections.Count -gt 0) {
        Write-Host "  [!] DETECTED: $($detections.Count) suspicious entries!" -ForegroundColor Red
        Write-Host ""
        
        $uniqueDetections = $detections | Select-Object -First 10
        foreach ($detection in $uniqueDetections) {
            Write-Host "  → $($detection.Browser)" -ForegroundColor Yellow
            Write-Host "    Keyword: $($detection.Keyword)" -ForegroundColor Red
            Write-Host "    URL: $($detection.URL.Substring(0, [Math]::Min(60, $detection.URL.Length)))..." -ForegroundColor Gray
            Write-Host ""
        }
        
        if ($detections.Count -gt 10) {
            Write-Host "  ... and $($detections.Count - 10) more detections" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  ✓ No suspicious browser history detected" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
    
# ============================================================================
# SECTION 2: MODS ANALYZER
# ============================================================================

} elseif ($choice -eq "2") {
    Clear-Host
    Show-Logo
    
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                      MODS ANALYZER                            ║" -ForegroundColor Green
    Write-Host "  ╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    $suspiciousMods = @()
    $allMods = @()
    
    # Список путей для поиска модов
    $modsPaths = @(
        "$env:APPDATA\.minecraft\mods",
        "$env:APPDATA\.tlauncher\legacy\Minecraft\game\mods",
        "$env:APPDATA\PrismLauncher\instances"
    )
    
    Write-Host "  [*] Scanning Minecraft installations..." -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($path in $modsPaths) {
        if (Test-Path $path) {
            if ($path -like "*PrismLauncher*") {
                # Сканируем все инстансы PrismLauncher
                $instances = Get-ChildItem $path -Directory -ErrorAction SilentlyContinue
                foreach ($instance in $instances) {
                    $instanceMods = Join-Path $instance.FullName ".minecraft\mods"
                    if (Test-Path $instanceMods) {
                        $mods = Get-ChildItem $instanceMods -Filter "*.jar" -ErrorAction SilentlyContinue
                        Write-Host "  [+] Found: $($instance.Name) ($($mods.Count) mods)" -ForegroundColor Green
                        $allMods += $mods
                    }
                }
            } else {
                $mods = Get-ChildItem $path -Filter "*.jar" -ErrorAction SilentlyContinue
                $folderName = Split-Path $path -Leaf
                if ($path -like "*tlauncher*") { $folderName = "TLauncher" }
                if ($path -like "*.minecraft*") { $folderName = "Minecraft" }
                Write-Host "  [+] Found: $folderName ($($mods.Count) mods)" -ForegroundColor Green
                $allMods += $mods
            }
        }
    }
    
    Write-Host ""
    Write-Host "  [*] Analyzing $($allMods.Count) mods..." -ForegroundColor Cyan
    Write-Host ""
    
    # Анализ модов
    $cheatKeywords = @("cheat", "hack", "xray", "esp", "killaura", "fly", "speed", "reach", "nuker")
    $knownCheats = @("vape", "liquid", "wurst", "meteor", "sigma", "flux", "jello", "aristois", "impact")
    
    foreach ($mod in $allMods) {
        $isSuspicious = $false
        $reason = ""
        
        # Проверка имени
        foreach ($cheat in $knownCheats) {
            if ($mod.Name -match $cheat) {
                $isSuspicious = $true
                $reason = "Known cheat client: $cheat"
                break
            }
        }
        
        # Проверка ключевых слов
        if (-not $isSuspicious) {
            foreach ($keyword in $cheatKeywords) {
                if ($mod.Name -match $keyword) {
                    $isSuspicious = $true
                    $reason = "Suspicious keyword: $keyword"
                    break
                }
            }
        }
        
        # Проверка размера (слишком маленькие моды подозрительны)
        if (-not $isSuspicious -and $mod.Length -lt 10KB) {
            $isSuspicious = $true
            $reason = "Suspiciously small file size"
        }
        
        # Проверка обфускации (короткое имя)
        if (-not $isSuspicious -and $mod.BaseName -match '^[a-z]{1,3}$') {
            $isSuspicious = $true
            $reason = "Obfuscated name pattern"
        }
        
        if ($isSuspicious) {
            $suspiciousMods += @{
                Name = $mod.Name
                Path = $mod.DirectoryName
                Size = $mod.Length
                Reason = $reason
                Date = $mod.LastWriteTime
            }
        }
    }
    
    # Результаты
    Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    
    if ($suspiciousMods.Count -gt 0) {
        Write-Host "  [!] SUSPICIOUS MODS DETECTED: $($suspiciousMods.Count)" -ForegroundColor Red
        Write-Host ""
        
        foreach ($mod in $suspiciousMods) {
            Write-Host "  → $($mod.Name)" -ForegroundColor Red
            Write-Host "    Reason: $($mod.Reason)" -ForegroundColor Yellow
            Write-Host "    Size: $([math]::Round($mod.Size / 1KB, 2)) KB" -ForegroundColor Gray
            Write-Host "    Path: $($mod.Path)" -ForegroundColor DarkGray
            Write-Host ""
        }
    } else {
        Write-Host "  ✓ All mods appear legitimate" -ForegroundColor Green
        Write-Host "    Total mods scanned: $($allMods.Count)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    Read-Host "  Press Enter to return to menu"

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
