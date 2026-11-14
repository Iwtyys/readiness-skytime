Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Создаем форму
$form = New-Object System.Windows.Forms.Form
$form.Text = ""
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.TopMost = $true
$form.Opacity = 0  # Начинаем с прозрачности для fade-in эффекта

# Небольшое закругление углов
$radius = 20
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$rect = New-Object System.Drawing.Rectangle(0, 0, 400, 300)
$path.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
$path.CloseFigure()
$form.Region = New-Object System.Drawing.Region($path)

# Panel для основного фона
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.Controls.Add($mainPanel)

# Добавляем возможность перетаскивать окно
$script:isDragging = $false
$script:dragStartPoint = New-Object System.Drawing.Point(0, 0)

$mainPanel.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $true
        $script:dragStartPoint = $e.Location
    }
})

$mainPanel.Add_MouseMove({
    param($sender, $e)
    if ($script:isDragging) {
        $newLocation = $form.Location
        $newLocation.X += $e.X - $script:dragStartPoint.X
        $newLocation.Y += $e.Y - $script:dragStartPoint.Y
        $form.Location = $newLocation
    }
})

$mainPanel.Add_MouseUp({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $false
    }
})

# Label "READINESS" основной
$label = New-Object System.Windows.Forms.Label
$label.Text = ""  # Начинаем с пустого текста
$label.Font = New-Object System.Drawing.Font("Segoe UI", 28, ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic))
$label.ForeColor = [System.Drawing.Color]::White
$label.BackColor = [System.Drawing.Color]::Transparent
$label.AutoSize = $false
$label.Size = New-Object System.Drawing.Size(380, 60)
$label.Location = New-Object System.Drawing.Point(10, 90)
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

# Добавляем перетаскивание и для label
$label.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $true
        $script:dragStartPoint = New-Object System.Drawing.Point($e.X + $sender.Left, $e.Y + $sender.Top)
    }
})

$label.Add_MouseMove({
    param($sender, $e)
    if ($script:isDragging) {
        $newLocation = $form.Location
        $newLocation.X += ($e.X + $sender.Left) - $script:dragStartPoint.X
        $newLocation.Y += ($e.Y + $sender.Top) - $script:dragStartPoint.Y
        $form.Location = $newLocation
        $script:dragStartPoint = New-Object System.Drawing.Point($e.X + $sender.Left, $e.Y + $sender.Top)
    }
})

$label.Add_MouseUp({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $false
    }
})

$mainPanel.Controls.Add($label)

# Panel для кастомной полоски загрузки
$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Location = New-Object System.Drawing.Point(50, 200)
$progressPanel.Size = New-Object System.Drawing.Size(300, 8)
$progressPanel.BackColor = [System.Drawing.Color]::Transparent

# Включаем двойную буферизацию для устранения мерцания
$progressPanel.GetType().GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).SetValue($progressPanel, $true, $null)

$mainPanel.Controls.Add($progressPanel)

# Обработчик отрисовки прогресс-бара
$progressPanel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    # Рисуем белую полоску
    $fillWidth = ($progressPanel.Width * $script:progress) / 100
    if ($fillWidth -gt 0) {
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $g.FillRectangle($brush, 0, 0, $fillWidth, $progressPanel.Height)
        $brush.Dispose()
    }
})

# Label для процента загрузки (под полоской)
$percentLabel = New-Object System.Windows.Forms.Label
$percentLabel.Text = "0%"
$percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
$percentLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$percentLabel.BackColor = [System.Drawing.Color]::Transparent
$percentLabel.AutoSize = $false
$percentLabel.Size = New-Object System.Drawing.Size(380, 30)
$percentLabel.Location = New-Object System.Drawing.Point(10, 220)
$percentLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$mainPanel.Controls.Add($percentLabel)

# Переменные для анимации
$script:progress = 0
$script:textAlpha = 255
$script:textDirection = -1
$script:closingAnimation = $false
$script:textRevealIndex = 0
$script:fullText = "READINESS"

# Timer для fade-in эффекта и прогресс-бара
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 20  # Быстрее обновление для плавности
$timer.Add_Tick({
    # Fade-in эффект
    if ($form.Opacity -lt 1 -and -not $script:closingAnimation) {
        $form.Opacity += 0.05
        if ($form.Opacity -gt 1) { $form.Opacity = 1 }
    }
    
    # Анимация появления текста по буквам
    if ($script:textRevealIndex -lt $script:fullText.Length) {
        $script:textRevealIndex += 0.15
        $currentLength = [math]::Floor($script:textRevealIndex)
        if ($currentLength -gt $script:fullText.Length) {
            $currentLength = $script:fullText.Length
        }
        $label.Text = $script:fullText.Substring(0, $currentLength)
    }
    
    # Пульсация текста (начинается после полного появления)
    if ($script:textRevealIndex -ge $script:fullText.Length) {
        $script:textAlpha += ($script:textDirection * 3)
        if ($script:textAlpha -le 200) {
            $script:textAlpha = 200
            $script:textDirection = 1
        } elseif ($script:textAlpha -ge 255) {
            $script:textAlpha = 255
            $script:textDirection = -1
        }
        $label.ForeColor = [System.Drawing.Color]::FromArgb($script:textAlpha, 255, 255, 255)
    }
    
    # Обновление прогресс-бара
    if ($script:progress -lt 100) {
        $script:progress += 0.8  # Меньший шаг для плавности
        if ($script:progress -gt 100) { $script:progress = 100 }
        $progressPanel.Invalidate()
        $percentLabel.Text = [math]::Round($script:progress).ToString() + "%"
    } else {
        # Fade-out анимация при закрытии
        if (-not $script:closingAnimation) {
            $script:closingAnimation = $true
        }
        
        if ($form.Opacity -gt 0) {
            $form.Opacity -= 0.08
        } else {
            $timer.Stop()
            $form.Close()
        }
    }
})

# Запускаем таймер
$timer.Start()

# Показываем форму
[void]$form.ShowDialog()

# ============================================================================
# ПОСЛЕ ЗАГРУЗКИ - ЗАПУСКАЕМ ОСНОВНОЕ МЕНЮ
# ============================================================================

Clear-Host

# Получаем ширину окна терминала
$windowWidth = $Host.UI.RawUI.WindowSize.Width
if ($windowWidth -lt 80) { $windowWidth = 80 }  # Минимум 80 символов

# Функция для центрирования текста (немного правее)
function Write-Centered {
    param($text, $color = "White")
    $padding = [math]::Max(0, (($windowWidth - $text.Length) / 2) - 5)  # Сдвиг на 5 символов левее (было 10)
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color
}

# Функция для создания линии по всей ширине
function Write-FullLine {
    param($char = "─", $color = "Gray")
    Write-Host ($char * $windowWidth) -ForegroundColor $color
}

# Функция для создания рамки
function Write-BoxLine {
    param($text, $color = "Gray")
    $innerWidth = $windowWidth - 4  # Минус границы ║  ║
    $textPadding = $innerWidth - $text.Length
    $leftPad = 2
    $rightPad = $textPadding - $leftPad
    Write-Host "  ║" -ForegroundColor $color -NoNewline
    Write-Host (" " * $leftPad) -NoNewline
    Write-Host $text -ForegroundColor $color -NoNewline
    Write-Host (" " * $rightPad) -NoNewline
    Write-Host "║" -ForegroundColor $color
}

# Функция для отрисовки логотипа
function Show-Logo {
    Write-Host ""
    Write-Host ""
    Write-Centered "██████╗ ███████╗ █████╗ ██████╗ ██╗███╗   ██╗███████╗███████╗███████╗" -color DarkGray
    Write-Centered "██╔══██╗██╔════╝██╔══██╗██╔══██╗██║████╗  ██║██╔════╝██╔════╝██╔════╝" -color DarkGray
    Write-Centered "██████╔╝█████╗  ███████║██║  ██║██║██╔██╗ ██║█████╗  ███████╗███████╗" -color Gray
    Write-Centered "██╔══██╗██╔══╝  ██╔══██║██║  ██║██║██║╚██╗██║██╔══╝  ╚════██║╚════██║" -color Gray
    Write-Centered "██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║███████╗███████║███████║" -color White
    Write-Centered "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝" -color White
    Write-Host ""
    Write-Host ""
    Write-Centered "═══════════════════════════════════════════════════════" -color DarkGray
    Write-Centered "║         Created by: IwTu              v1.7.4       ║" -color Gray
    Write-Centered "═══════════════════════════════════════════════════════" -color DarkGray
    Write-Host ""
    Write-FullLine -char "─" -color DarkGray
    Write-Host ""
}

Show-Logo


while ($true) {
    Write-Host ""
    Write-Host "Select scan mode:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [1] Browser History Scanner" -ForegroundColor White
    Write-Host "  [2] Mods Analyzer" -ForegroundColor White
    Write-Host "  [3] Tools Launcher" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Exit" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "Enter choice"

if ($choice -eq "1") {
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
    


} elseif ($choice -eq "2") {
    Clear-Host
    Show-Logo
    
    Write-Host "[~] Checking for running Minecraft..." -ForegroundColor Gray
    
    $modsFolders = @()
    $activeModsPath = $null
    
    # Сначала ищем активный Minecraft
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    if ($javawProcesses) {
        foreach ($proc in $javawProcesses) {
            try {
                $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
                if ($memoryGB -lt 1) { continue }
                
                $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
                
                $modsPath = $null
                
                # Вариант 1: --gameDir в командной строке
                if ($cmdLine -match '--gameDir\s+([^\s]+)') {
                    $gameDir = $matches[1].Trim('"')
                    
                    $possiblePaths = @(
                        (Join-Path $gameDir "mods"),
                        (Join-Path $gameDir "overlay\mods")
                    )
                    
                    foreach ($path in $possiblePaths) {
                        if (Test-Path $path) {
                            $modsPath = $path
                            break
                        }
                    }
                }
                # Вариант 2: Прямой путь .minecraft
                elseif ($cmdLine -match '([A-Za-z]:[^"]*\.minecraft[^"\\]*)') {
                    $gameDir = $matches[1].Trim('"')
                    $modsPath = Join-Path $gameDir "mods"
                }
                # Вариант 3: Стандартный путь
                else {
                    $defaultPath = Join-Path $env:APPDATA ".minecraft\mods"
                    if (Test-Path $defaultPath) {
                        $modsPath = $defaultPath
                    }
                }
                
                if ($modsPath -and (Test-Path $modsPath)) {
                    $activeModsPath = $modsPath
                    break
                }
            } catch { }
        }
    }
    
    # Теперь ищем все папки mods на ПК
    Write-Host "[~] Searching for mods folders..." -ForegroundColor Gray
    
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
                $foundMods = Get-ChildItem -Path $path -Recurse -Directory -Filter "mods" -ErrorAction SilentlyContinue -Depth 3
                foreach ($modFolder in $foundMods) {
                    if (-not ($modsFolders -contains $modFolder.FullName)) {
                        $modsFolders += $modFolder.FullName
                    }
                }
                
                $jars = Get-ChildItem -Path $path -Filter "*.jar" -ErrorAction SilentlyContinue
                if ($jars.Count -gt 0 -and -not ($modsFolders -contains $path)) {
                    $modsFolders += $path
                }
            }
        }
    }
    
    # Добавляем активную папку в начало списка (если не там)
    if ($activeModsPath -and -not ($modsFolders -contains $activeModsPath)) {
        $modsFolders = @($activeModsPath) + $modsFolders
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
        
        if ($activeModsPath) {
            Write-Host "    [!] Active Minecraft detected!" -ForegroundColor Green
            Write-Host ""
        }
        
        Write-Host "    Found $($modsFolders.Count) mods folder(s):" -ForegroundColor Green
        Write-Host ""
        
        for ($i = 0; $i -lt $modsFolders.Count; $i++) {
            $prefix = "    [$($i+1)] "
            
            # Помечаем активную папку
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
        Write-Host "    [0] Custom folder" -ForegroundColor Yellow
        Write-Host ""
        
        $folderChoice = Read-Host "Select folder"
        
        # Если выбрана custom folder
        if ($folderChoice -eq "0") {
            Write-Host ""
            Write-Host "    Enter mods folder path:" -ForegroundColor Yellow
            $customPath = Read-Host "    Path"
            
            if ([string]::IsNullOrWhiteSpace($customPath)) {
                Write-Host ""
                Write-Host "    [!] Cancelled" -ForegroundColor Gray
                Start-Sleep -Seconds 1
                Clear-Host
                Show-Logo
                continue
            }
            
            if (Test-Path $customPath) {
                $testJars = Get-ChildItem -Path $customPath -Filter "*.jar" -ErrorAction SilentlyContinue
                if ($testJars.Count -gt 0) {
                    $selectedFolder = $customPath
                    Write-Host ""
                    Write-Host "    [OK] Found $($testJars.Count) JAR file(s)" -ForegroundColor Green
                } else {
                    Write-Host ""
                    Write-Host "    [!] No JAR files found!" -ForegroundColor Red
                    Start-Sleep -Seconds 2
                    Clear-Host
                    Show-Logo
                    continue
                }
            } else {
                Write-Host ""
                Write-Host "    [!] Path not found!" -ForegroundColor Red
                Start-Sleep -Seconds 2
                Clear-Host
                Show-Logo
                continue
            }
        }
        elseif ($folderChoice -match '^\d+$' -and [int]$folderChoice -gt 0 -and [int]$folderChoice -le $modsFolders.Count) {
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
                    'Quickstack','AutoTool','FeatherLauncher','Badlion',
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
                    'AutoAttack','CleanCut','InventoryControlTweaks','AutoLeave','Foodslot','AutoTool',
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
                    'PvP' = @('AutoAttack','CleanCut','InventoryControlTweaks','AutoLeave','Foodslot','Quickstack','AutoTool')
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
            
        } else {
            Write-Host ""
            Write-Host "    Invalid choice!" -ForegroundColor Red
            Start-Sleep -Seconds 1
            Clear-Host
            Show-Logo
        }
    }
    
} elseif ($choice -eq "3") {
    Clear-Host
    Show-Logo
    
    Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║                         TOOLS LAUNCHER                                  ║" -ForegroundColor Gray
    Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select tool to launch:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [1] Everything 1.5a   - Fast file search engine" -ForegroundColor White
    Write-Host "  [2] JournalTrace      - USB/File activity tracker" -ForegroundColor White
    Write-Host "  [3] System Informer   - Advanced task manager" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Back to menu" -ForegroundColor DarkGray
    Write-Host ""
    
    $toolChoice = Read-Host "Enter choice"
    
    $toolsDir = Join-Path $env:TEMP "DetectorTools"
    if (-not (Test-Path $toolsDir)) {
        New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
    }
    
    if ($toolChoice -eq "1") {
        # Everything
        Write-Host ""
        Write-Host "  [~] Everything 1.5a" -ForegroundColor Cyan
        
        $everythingPath = Join-Path $toolsDir "Everything.exe"
        $everythingInstaller = Join-Path $toolsDir "Everything-Setup.exe"
        
        if (Test-Path $everythingPath) {
            Write-Host "  [✓] Found existing installation" -ForegroundColor Green
            Write-Host "  [~] Launching Everything..." -ForegroundColor Gray
            Start-Process $everythingPath
            Write-Host "  [✓] Launched!" -ForegroundColor Green
        } else {
            Write-Host "  [!] Not found, downloading..." -ForegroundColor Yellow
            try {
                $url = "https://www.voidtools.com/Everything-1.5.0.1409a.x64-Setup.exe"
                Write-Host "  [~] Downloading from voidtools.com..." -ForegroundColor Gray
                
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($url, $everythingInstaller)
                
                Write-Host "  [✓] Downloaded!" -ForegroundColor Green
                Write-Host "  [~] Running installer..." -ForegroundColor Gray
                Write-Host ""
                Write-Host "  ⚠️  IMPORTANT: Install to default location!" -ForegroundColor Yellow
                Write-Host ""
                
                Start-Process $everythingInstaller -Wait
                
                # Проверяем установку в стандартных местах
                $possiblePaths = @(
                    "C:\Program Files\Everything\Everything.exe",
                    "C:\Program Files (x86)\Everything\Everything.exe",
                    (Join-Path $env:LOCALAPPDATA "Programs\Everything\Everything.exe")
                )
                
                $found = $false
                foreach ($path in $possiblePaths) {
                    if (Test-Path $path) {
                        Write-Host "  [✓] Installed successfully!" -ForegroundColor Green
                        Write-Host "  [~] Launching Everything..." -ForegroundColor Gray
                        Start-Process $path
                        $found = $true
                        break
                    }
                }
                
                if (-not $found) {
                    Write-Host "  [!] Installation completed but executable not found" -ForegroundColor Yellow
                    Write-Host "  [!] Please launch Everything manually" -ForegroundColor Yellow
                }
                
            } catch {
                Write-Host "  [✗] Download failed: $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Read-Host "Press Enter to continue"
        Clear-Host
        Show-Logo
        
    } elseif ($toolChoice -eq "2") {
        # JournalTrace
        Write-Host ""
        Write-Host "  [~] JournalTrace" -ForegroundColor Cyan
        
        $jtPath = Join-Path $toolsDir "JournalTrace.exe"
        
        if (Test-Path $jtPath) {
            Write-Host "  [✓] Found existing installation" -ForegroundColor Green
            Write-Host "  [~] Launching JournalTrace..." -ForegroundColor Gray
            Start-Process $jtPath
            Write-Host "  [✓] Launched!" -ForegroundColor Green
        } else {
            Write-Host "  [!] Not found, downloading..." -ForegroundColor Yellow
            try {
                $url = "https://github.com/ponei/JournalTrace/releases/download/1.0/JournalTrace.exe"
                Write-Host "  [~] Downloading from GitHub..." -ForegroundColor Gray
                
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($url, $jtPath)
                
                Write-Host "  [✓] Downloaded!" -ForegroundColor Green
                Write-Host "  [~] Launching JournalTrace..." -ForegroundColor Gray
                Start-Process $jtPath
                Write-Host "  [✓] Launched!" -ForegroundColor Green
                
            } catch {
                Write-Host "  [✗] Download failed: $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Read-Host "Press Enter to continue"
        Clear-Host
        Show-Logo
        
    } elseif ($toolChoice -eq "3") {
        # System Informer
        Write-Host ""
        Write-Host "  [~] System Informer" -ForegroundColor Cyan
        
        $siPath = Join-Path $toolsDir "SystemInformer.exe"
        $siInstaller = Join-Path $toolsDir "SystemInformer-Setup.exe"
        
        if (Test-Path $siPath) {
            Write-Host "  [✓] Found existing installation" -ForegroundColor Green
            Write-Host "  [~] Launching System Informer..." -ForegroundColor Gray
            Start-Process $siPath
            Write-Host "  [✓] Launched!" -ForegroundColor Green
        } else {
            Write-Host "  [!] Not found, downloading..." -ForegroundColor Yellow
            try {
                $url = "https://github.com/winsiderss/si-builds/releases/download/4.0.26255.346/systeminformer-build-canary-setup.exe"
                Write-Host "  [~] Downloading from GitHub..." -ForegroundColor Gray
                
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($url, $siInstaller)
                
                Write-Host "  [✓] Downloaded!" -ForegroundColor Green
                Write-Host "  [~] Running installer..." -ForegroundColor Gray
                Write-Host ""
                Write-Host "  ⚠️  IMPORTANT: Install to default location!" -ForegroundColor Yellow
                Write-Host ""
                
                Start-Process $siInstaller -Wait
                
                # Проверяем установку в стандартных местах
                $possiblePaths = @(
                    "C:\Program Files\SystemInformer\SystemInformer.exe",
                    "C:\Program Files (x86)\SystemInformer\SystemInformer.exe",
                    (Join-Path $env:LOCALAPPDATA "Programs\SystemInformer\SystemInformer.exe")
                )
                
                $found = $false
                foreach ($path in $possiblePaths) {
                    if (Test-Path $path) {
                        Write-Host "  [✓] Installed successfully!" -ForegroundColor Green
                        Write-Host "  [~] Launching System Informer..." -ForegroundColor Gray
                        Start-Process $path
                        $found = $true
                        break
                    }
                }
                
                if (-not $found) {
                    Write-Host "  [!] Installation completed but executable not found" -ForegroundColor Yellow
                    Write-Host "  [!] Please launch System Informer manually" -ForegroundColor Yellow
                }
                
            } catch {
                Write-Host "  [✗] Download failed: $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Read-Host "Press Enter to continue"
        Clear-Host
        Show-Logo
        
    } elseif ($toolChoice -eq "0") {
        Clear-Host
        Show-Logo
    } else {
        Write-Host ""
        Write-Host "  [!] Invalid choice!" -ForegroundColor Red
        Start-Sleep -Seconds 1
        Clear-Host
        Show-Logo
    }
    
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

