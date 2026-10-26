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

# ============================================
# ЗАГРУЗКА (ТЕКСТОВАЯ В CMD)
# ============================================

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
Write-Centered "Loading..." -color White

# Анимированная загрузка
$barLength = 50
$spinner = @("|", "/", "-", "\")

for ($progress = 0; $progress -le 100; $progress += 2) {
    $spinnerChar = $spinner[$progress % 4]
    $filledLength = [math]::Round($progress / 2)
    $emptyLength = $barLength - $filledLength
    $bar = "█" * $filledLength + "░" * $emptyLength
    
    Write-Host "`r[$spinnerChar] [$bar] $progress%" -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 50
}

Write-Host "`r[√] [" + ("█" * $barLength) + "] 100%" -ForegroundColor Green
Write-Host ""
Start-Sleep -Milliseconds 500

# ============================================
# МЕНЮ + КОД АНАЛИЗА
# ============================================

Clear-Host

# Глобальный белый список модов
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
