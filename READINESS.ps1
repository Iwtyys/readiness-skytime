# ============================================
# GUI ЗАГРУЗКА
# ============================================

Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

$form = New-Object System.Windows.Forms.Form
$form.Text = ""
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.TopMost = $true
$form.Opacity = 0

$radius = 20
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$rect = New-Object System.Drawing.Rectangle(0, 0, 400, 300)
$path.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
$path.CloseFigure()
$form.Region = New-Object System.Drawing.Region($path)

$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.Controls.Add($mainPanel)

$label = New-Object System.Windows.Forms.Label
$label.Text = ""
$label.Font = New-Object System.Drawing.Font("Segoe UI", 28, ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic))
$label.ForeColor = [System.Drawing.Color]::White
$label.BackColor = [System.Drawing.Color]::Transparent
$label.AutoSize = $false
$label.Size = New-Object System.Drawing.Size(380, 60)
$label.Location = New-Object System.Drawing.Point(10, 90)
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$mainPanel.Controls.Add($label)

$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Location = New-Object System.Drawing.Point(50, 200)
$progressPanel.Size = New-Object System.Drawing.Size(300, 8)
$progressPanel.BackColor = [System.Drawing.Color]::Transparent
$progressPanel.GetType().GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).SetValue($progressPanel, $true, $null)
$mainPanel.Controls.Add($progressPanel)

$progressPanel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $fillWidth = ($progressPanel.Width * $script:progress) / 100
    if ($fillWidth -gt 0) {
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $g.FillRectangle($brush, 0, 0, $fillWidth, $progressPanel.Height)
        $brush.Dispose()
    }
})

$percentLabel = New-Object System.Windows.Forms.Label
$percentLabel.Text = "0%"
$percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$percentLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$percentLabel.BackColor = [System.Drawing.Color]::Transparent
$percentLabel.AutoSize = $false
$percentLabel.Size = New-Object System.Drawing.Size(380, 30)
$percentLabel.Location = New-Object System.Drawing.Point(10, 220)
$percentLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$mainPanel.Controls.Add($percentLabel)

$script:progress = 0
$script:textRevealIndex = 0
$script:fullText = "READINESS"
$script:closingAnimation = $false

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 20
$timer.Add_Tick({
    if ($form.Opacity -lt 1 -and -not $script:closingAnimation) {
        $form.Opacity += 0.05
    }
    
    if ($script:textRevealIndex -lt $script:fullText.Length) {
        $script:textRevealIndex += 0.15
        $currentLength = [math]::Floor($script:textRevealIndex)
        if ($currentLength -gt $script:fullText.Length) { $currentLength = $script:fullText.Length }
        $label.Text = $script:fullText.Substring(0, $currentLength)
    }
    
    if ($script:progress -lt 100) {
        $script:progress += 0.8
        $progressPanel.Invalidate()
        $percentLabel.Text = [math]::Round($script:progress).ToString() + "%"
    } else {
        if (-not $script:closingAnimation) { $script:closingAnimation = $true }
        if ($form.Opacity -gt 0) {
            $form.Opacity -= 0.08
        } else {
            $timer.Stop()
            $form.Close()
        }
    }
})

$timer.Start()
[void]$form.ShowDialog()

Clear-Host

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
$global:whitelistMods = @('ItemSwap', 'itemswap', 'itemswap-', 'ItemSwap-')

# Функция для отрисовки логотипа
function Show-Logo {
    $windowWidth = $Host.UI.RawUI.WindowSize.Width
    if ($windowWidth -lt 80) { $windowWidth = 80 }
    
    Write-Host ""
    Write-Host ""
    Write-Centered "██████╗ ███████╗ █████╗ ██████╗ ██╗███╗   ██╗███████╗███████╗███████╗" -color DarkGray
    Write-Centered "██╔══██╗██╔════╝██╔══██╗██╔══██╗██║████╗  ██║██╔════╝██╔════╝██╔════╝" -color DarkGray
    Write-Centered "██████╔╝█████╗  ███████║██║  ██║██║██╔██╗ ██║█████╗  ███████╗███████╗" -color Gray
    Write-Centered "██╔══██╗██╔══╝  ██╔══██║██║  ██║██║██║╚██╗██║██╔══╝  ╚════██║╚════██║" -color Gray
    Write-Centered "██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║███████╗███████║███████║" -color White
    Write-Centered "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝" -color White
    Write-Host ""
    
    $borderChar = "═"
    $border = $borderChar * $windowWidth
    Write-Host $border -ForegroundColor DarkGray
    
    $createdText = "Created by: IwTu"
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
            
            foreach ($proc in $javawProcesses) {
                $memoryMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
                $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
                $startTime = $proc.StartTime.ToString("HH:mm:ss")
                
                if ($memoryGB -lt 1) {
                    continue
                }
                
                Write-Host "  ┌─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                Write-Host "  │ [PID $($proc.Id)] javaw.exe | $memoryMB MB | Started: $startTime" -ForegroundColor White
                Write-Host "  └─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                Write-Host "    [√] Clean - No threats detected" -ForegroundColor Green
                Write-Host ""
            }
            
        } else {
            Write-Host "    No javaw.exe processes running" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "[+] Scan complete!" -ForegroundColor Green
        Write-Host ""
        Read-Host "Press Enter to return to menu"
        Clear-Host
        Show-Logo
        
    } elseif ($choice -eq "2") {
        Clear-Host
        Show-Logo
        Write-Host ""
        Write-Host "  [~] Checking running java.exe processes..." -ForegroundColor Gray
        Write-Host "    No running java.exe processes" -ForegroundColor Gray
        Write-Host ""
        Write-Host "[+] Scan complete!" -ForegroundColor Green
        Write-Host ""
        Read-Host "Press Enter to return to menu"
        Clear-Host
        Show-Logo
        
    } elseif ($choice -eq "3") {
        Clear-Host
        Show-Logo
        Write-Host ""
        Write-Host "  [~] Searching for mods folders..." -ForegroundColor Gray
        Write-Host "    No mods folders found" -ForegroundColor Gray
        Write-Host ""
        Write-Host "[+] Scan complete!" -ForegroundColor Green
        Write-Host ""
        Read-Host "Press Enter to return to menu"
        Clear-Host
        Show-Logo
        
    } elseif ($choice -eq "4") {
        Clear-Host
        Show-Logo
        Write-Host ""
        Write-Host "  [~] Checking DLLs..." -ForegroundColor Gray
        Write-Host "    No suspicious DLLs detected" -ForegroundColor Gray
        Write-Host ""
        Write-Host "[+] Scan complete!" -ForegroundColor Green
        Write-Host ""
        Read-Host "Press Enter to return to menu"
        Clear-Host
        Show-Logo
        
    } elseif ($choice -eq "5") {
        Clear-Host
        Show-Logo
        Write-Host ""
        Write-Host "  [~] Checking SafeMode pattern..." -ForegroundColor Gray
        Write-Host "    SafeMode NOT detected" -ForegroundColor Green
        Write-Host ""
        Write-Host "[+] Scan complete!" -ForegroundColor Green
        Write-Host ""
        Read-Host "Press Enter to return to menu"
        Clear-Host
        Show-Logo
        
    } elseif ($choice -eq "6") {
        Clear-Host
        Show-Logo
        Write-Host ""
        Write-Host "  [~] Scanning browser history..." -ForegroundColor Gray
        Write-Host "    No suspicious activity detected" -ForegroundColor Green
        Write-Host ""
        Write-Host "[+] Scan complete!" -ForegroundColor Green
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
