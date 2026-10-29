Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Правильный ключ
$script:correctKey = "Jy2xqlx"
$script:keyAccepted = $false

# ============================================================================
# ФОРМА ВВОДА КЛЮЧА
# ============================================================================

$keyForm = New-Object System.Windows.Forms.Form
$keyForm.Text = ""
$keyForm.Size = New-Object System.Drawing.Size(400, 250)
$keyForm.StartPosition = "CenterScreen"
$keyForm.FormBorderStyle = "None"
$keyForm.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$keyForm.TopMost = $true
$keyForm.Opacity = 0

# Закругление углов
$radius = 20
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$rect = New-Object System.Drawing.Rectangle(0, 0, 400, 250)
$path.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
$path.CloseFigure()
$keyForm.Region = New-Object System.Drawing.Region($path)

# Panel
$keyPanel = New-Object System.Windows.Forms.Panel
$keyPanel.Dock = "Fill"
$keyPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$keyForm.Controls.Add($keyPanel)

# Перетаскивание
$script:isDragging = $false
$script:dragStartPoint = New-Object System.Drawing.Point(0, 0)

$keyPanel.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $true
        $script:dragStartPoint = $e.Location
    }
})

$keyPanel.Add_MouseMove({
    param($sender, $e)
    if ($script:isDragging) {
        $newLocation = $keyForm.Location
        $newLocation.X += $e.X - $script:dragStartPoint.X
        $newLocation.Y += $e.Y - $script:dragStartPoint.Y
        $keyForm.Location = $newLocation
    }
})

$keyPanel.Add_MouseUp({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $false
    }
})

# Заголовок "ACTIVATION"
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "ACTIVATION"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.BackColor = [System.Drawing.Color]::Transparent
$titleLabel.AutoSize = $false
$titleLabel.Size = New-Object System.Drawing.Size(380, 50)
$titleLabel.Location = New-Object System.Drawing.Point(10, 30)
$titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$keyPanel.Controls.Add($titleLabel)

# Подзаголовок
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Enter your key to continue"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$subtitleLabel.BackColor = [System.Drawing.Color]::Transparent
$subtitleLabel.AutoSize = $false
$subtitleLabel.Size = New-Object System.Drawing.Size(380, 30)
$subtitleLabel.Location = New-Object System.Drawing.Point(10, 70)
$subtitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$keyPanel.Controls.Add($subtitleLabel)

# Текстовое поле для ввода ключа
$keyTextBox = New-Object System.Windows.Forms.TextBox
$keyTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$keyTextBox.Size = New-Object System.Drawing.Size(300, 30)
$keyTextBox.Location = New-Object System.Drawing.Point(50, 120)
$keyTextBox.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$keyTextBox.ForeColor = [System.Drawing.Color]::White
$keyTextBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$keyTextBox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$keyTextBox.UseSystemPasswordChar = $true  # Показывает *** вместо текста
$keyPanel.Controls.Add($keyTextBox)

# Label для сообщений об ошибке
$errorLabel = New-Object System.Windows.Forms.Label
$errorLabel.Text = ""
$errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$errorLabel.ForeColor = [System.Drawing.Color]::Red
$errorLabel.BackColor = [System.Drawing.Color]::Transparent
$errorLabel.AutoSize = $false
$errorLabel.Size = New-Object System.Drawing.Size(380, 20)
$errorLabel.Location = New-Object System.Drawing.Point(10, 155)
$errorLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$keyPanel.Controls.Add($errorLabel)

# Кнопка "CONTINUE"
$continueButton = New-Object System.Windows.Forms.Button
$continueButton.Text = "CONTINUE"
$continueButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$continueButton.Size = New-Object System.Drawing.Size(150, 35)
$continueButton.Location = New-Object System.Drawing.Point(125, 185)
$continueButton.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$continueButton.ForeColor = [System.Drawing.Color]::White
$continueButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$continueButton.FlatAppearance.BorderSize = 0
$continueButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$keyPanel.Controls.Add($continueButton)

# Обработчик кнопки Continue
$continueButton.Add_Click({
    $enteredKey = $keyTextBox.Text.Trim()
    
    if ($enteredKey -eq $script:correctKey) {
        $script:keyAccepted = $true
        $errorLabel.Text = "✓ Key accepted!"
        $errorLabel.ForeColor = [System.Drawing.Color]::Green
        Start-Sleep -Milliseconds 500
        $keyForm.Close()
    } else {
        $errorLabel.Text = "✗ Invalid key! Access denied."
        $errorLabel.ForeColor = [System.Drawing.Color]::Red
        $keyTextBox.Text = ""
        $keyTextBox.Focus()
        
        # Тряска окна при ошибке
        $originalLocation = $keyForm.Location
        for ($i = 0; $i -lt 3; $i++) {
            $keyForm.Location = New-Object System.Drawing.Point($originalLocation.X - 10, $originalLocation.Y)
            Start-Sleep -Milliseconds 50
            $keyForm.Location = New-Object System.Drawing.Point($originalLocation.X + 10, $originalLocation.Y)
            Start-Sleep -Milliseconds 50
        }
        $keyForm.Location = $originalLocation
    }
})

# Enter для отправки
$keyTextBox.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        $continueButton.PerformClick()
    }
})

# Fade-in анимация для формы ключа
$keyFadeTimer = New-Object System.Windows.Forms.Timer
$keyFadeTimer.Interval = 20
$keyFadeTimer.Add_Tick({
    if ($keyForm.Opacity -lt 1) {
        $keyForm.Opacity += 0.05
        if ($keyForm.Opacity -ge 1) {
            $keyForm.Opacity = 1
            $keyFadeTimer.Stop()
            $keyTextBox.Focus()
        }
    }
})

$keyFadeTimer.Start()

# Показываем форму ввода ключа
[void]$keyForm.ShowDialog()

# Если ключ не принят - выход
if (-not $script:keyAccepted) {
    exit
}

# ============================================================================
# ФОРМА ЗАГРУЗКИ (ПОКАЗЫВАЕТСЯ ТОЛЬКО ПОСЛЕ ПРАВИЛЬНОГО КЛЮЧА)
# ============================================================================

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

# Label для версии "v1.7.4 beta"
$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "v1.7.4 beta"
$versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$versionLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$versionLabel.BackColor = [System.Drawing.Color]::Transparent
$versionLabel.AutoSize = $false
$versionLabel.Size = New-Object System.Drawing.Size(380, 25)
$versionLabel.Location = New-Object System.Drawing.Point(10, 145)
$versionLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$mainPanel.Controls.Add($versionLabel)

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
    Write-Centered "║         Created by: IwTu          v1.7.4 beta     ║" -color Gray
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
    Write-Host "  [1] Scan javaw.exe memory (beta)" -ForegroundColor White
    Write-Host "  [2] Scan mods folder" -ForegroundColor White
    Write-Host "  [3] SafeMode Detection (beta)" -ForegroundColor White
    Write-Host "  [4] Browser History Scanner" -ForegroundColor White
    Write-Host "  [5] Cheat Detect (beta)" -ForegroundColor White
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
    Write-Host "  [~] Scanning javaw.exe and pulse_launcher.exe processes..." -ForegroundColor Gray
    
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    $pulseProcesses = Get-Process -Name pulse_launcher -ErrorAction SilentlyContinue
    
    # Объединяем оба процесса
    $allProcesses = @()
    if ($javawProcesses) { $allProcesses += $javawProcesses }
    if ($pulseProcesses) { $allProcesses += $pulseProcesses }
    
    if ($allProcesses.Count -gt 0) {
        Write-Host "    Found $($allProcesses.Count) process(es) (javaw: $($javawProcesses.Count), pulse: $($pulseProcesses.Count))" -ForegroundColor Gray
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
        
        foreach ($proc in $allProcesses) {
            # Получаем информацию о процессе
            $processName = $proc.ProcessName
            $displayName = if ($processName -eq "pulse_launcher") { "pulse_launcher.exe" } else { "javaw.exe" }
            $procInfo = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
            $memoryMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
            $memoryGB = [math]::Round($proc.WorkingSet64 / 1GB, 2)
            $startTime = $proc.StartTime.ToString("HH:mm:ss")
            
            # Пропускаем javaw с памятью < 1 GB
            if ($memoryGB -lt 1) {
                continue
            }
            
            Write-Host "  ┌─────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
            Write-Host "  │ [PID $($proc.Id)] $displayName | $memoryMB MB | Started: $startTime" -ForegroundColor White
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
        Write-Host "    No javaw.exe or pulse_launcher.exe processes running" -ForegroundColor Gray
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
        (Join-Path $env:USERPROFILE '.cristalix'),
        'C:\PulseVisuals\game\usermods'
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            # Специальная обработка для PulseVisuals
            if ($path -eq 'C:\PulseVisuals\game\usermods') {
                $versionFolders = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue
                foreach ($versionFolder in $versionFolders) {
                    # Пропускаем 1.16.5
                    if ($versionFolder.Name -eq '1.16.5') {
                        continue
                    }
                    
                    $jars = Get-ChildItem -Path $versionFolder.FullName -Filter "*.jar" -ErrorAction SilentlyContinue
                    if ($jars.Count -gt 0) {
                        if (-not ($modsFolders -contains $versionFolder.FullName)) {
                            $modsFolders += $versionFolder.FullName
                        }
                    }
                }
                continue
            }
            
            # Обычная обработка для других путей
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
        Write-Host "    [0] Custom folder (другая папка)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "    Press Enter to return to menu" -ForegroundColor DarkGray
        Write-Host ""
        
        $folderChoice = Read-Host "Select folder"
        
        # Если пустой ввод (Enter) - возврат в меню
        if ([string]::IsNullOrWhiteSpace($folderChoice)) {
            Clear-Host
            Show-Logo
            continue
        }
        
        # Проверка на кастомную папку [0]
        if ($folderChoice -eq "0") {
            Write-Host ""
            Write-Host "    Enter custom mods folder path:" -ForegroundColor Yellow
            Write-Host ""
            $customPath = Read-Host "    Path"
            
            # Если пустой ввод - возврат в меню
            if ([string]::IsNullOrWhiteSpace($customPath)) {
                Clear-Host
                Show-Logo
                continue
            }
            
            # Проверяем существует ли путь
            if (Test-Path $customPath) {
                # Проверяем есть ли там JAR файлы
                $testJars = Get-ChildItem -Path $customPath -Filter "*.jar" -ErrorAction SilentlyContinue
                
                if ($testJars.Count -gt 0) {
                    $selectedFolder = $customPath
                    Write-Host ""
                    Write-Host "    [✓] Found $($testJars.Count) JAR file(s) in custom folder" -ForegroundColor Green
                    Write-Host ""
                } else {
                    Write-Host ""
                    Write-Host "    [!] No JAR files found in this folder!" -ForegroundColor Red
                    Write-Host ""
                    Read-Host "Press Enter to return"
                    Clear-Host
                    Show-Logo
                    continue
                }
            } else {
                Write-Host ""
                Write-Host "    [!] Path not found: $customPath" -ForegroundColor Red
                Write-Host ""
                Read-Host "Press Enter to return"
                Clear-Host
                Show-Logo
                continue
            }
        }
        elseif ($folderChoice -match '^\d+$' -and [int]$folderChoice -gt 0 -and [int]$folderChoice -le $modsFolders.Count) {
            $selectedFolder = $modsFolders[[int]$folderChoice - 1]
        }
        else {
            Clear-Host
            Show-Logo
            continue
        }
        
        # Общий блок сканирования для выбранной папки
        if ($selectedFolder) {
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
                    'BlockESP','ElytraSwap','FastXP','NoSlow','WallHack',
                    'ChestStealer','AntiAFK','NoJumpDelay',
                    'ReplayMod','FlashBack','XRay','XRayMod','MobHealthBar',
                    'HealthBarPlus','Neat','Minimap','Voxelmap',
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
                    'AntiAFK','ChestStealer','NoJumpDelay',
                    'NoSlow','WallHack','BlockESP','ElytraSwap',
                    'Killaura','KillAura','ClickAura','AutoClicker',
                    'AutoDoubleHand','MaceSwap','AutoWeb','FakeLag',
                    
                    # Запрещённые моды с сервера
                    'ReplayMod','FlashBack',
                    'XRay','XRayMod','X-ray',
                    'MobHealthBar','HealthBarPlus','Neat','Neat+',
                    'Minimap','Voxelmap','JourneyMap','Rei',
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
                    'Minimap' = @('Minimap','Voxelmap','JourneyMap')
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
        }  # Закрываем if ($selectedFolder)
    }
    
} elseif ($choice -eq "3") {
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
    Write-Host ""
    Write-Host ""
    
    Write-Host "  [~] Collecting javaw.exe history (last 30 minutes)..." -ForegroundColor Gray
    Write-Host ""
    
    $allJavaw = @()
    $currentTime = Get-Date
    
    # 1. Получаем активные процессы javaw.exe (только >= 1GB)
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    if ($javawProcesses.Count -gt 0) {
        foreach ($proc in $javawProcesses) {
            $processName = $proc.ProcessName
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
            
            if ($javaPrefetch.Count -gt 0) {
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
    
} elseif ($choice -eq "4") {
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
    
    # Проверка сохраненных аккаунтов (Login Data)
    Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║                    SAVED ACCOUNTS CHECK                                 ║" -ForegroundColor Gray
    Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [~] Checking for saved accounts on cheat sites..." -ForegroundColor Gray
    Write-Host ""
    
    # Проверяем все запущенные браузеры
    $runningBrowsers = @()
    $browserProcesses = @(
        @{Name="chrome"; Display="Chrome"},
        @{Name="msedge"; Display="Edge"},
        @{Name="opera"; Display="Opera"},
        @{Name="yandex"; Display="Yandex"},
        @{Name="brave"; Display="Brave"},
        @{Name="vivaldi"; Display="Vivaldi"},
        @{Name="firefox"; Display="Firefox"}
    )
    
    foreach ($browser in $browserProcesses) {
        $proc = Get-Process -Name $browser.Name -ErrorAction SilentlyContinue
        if ($proc) {
            $runningBrowsers += $browser.Display
        }
    }
    
    if ($runningBrowsers.Count -gt 0) {
        Write-Host "  ⚠️  Running browsers detected: $($runningBrowsers -join ', ')" -ForegroundColor Yellow
        Write-Host "     Login Data files may be locked." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     Close all browsers for accurate results? (Y/N): " -NoNewline -ForegroundColor Yellow
        $response = Read-Host
        
        if ($response -eq 'Y' -or $response -eq 'y') {
            Write-Host "     Closing browsers..." -ForegroundColor Gray
            
            foreach ($browser in $browserProcesses) {
                Stop-Process -Name $browser.Name -Force -ErrorAction SilentlyContinue
            }
            
            Start-Sleep -Seconds 2
            Write-Host "     Browsers closed." -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host "     Continuing with limited access..." -ForegroundColor Yellow
            Write-Host ""
        }
    }
    
    $foundAccounts = @{}
    $script:totalAccounts = 0
    
    # Функция для проверки Login Data (с обходом блокировки)
    function Check-SavedLogins {
        param($loginDataPath, $browserName)
        
        if (-not (Test-Path $loginDataPath)) {
            return
        }
        
        $tempLoginData = Join-Path $env:TEMP "login_check_$(Get-Random).db"
        
        try {
            # Метод 1: Стандартное копирование
            Copy-Item -Path $loginDataPath -Destination $tempLoginData -Force -ErrorAction Stop
            Start-Sleep -Milliseconds 200
            
        } catch {
            # Метод 2: Чтение через FileStream (обход блокировки)
            try {
                $fileStream = [System.IO.File]::Open($loginDataPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                $fileBytes = New-Object byte[] $fileStream.Length
                $fileStream.Read($fileBytes, 0, $fileStream.Length) | Out-Null
                $fileStream.Close()
                
                [System.IO.File]::WriteAllBytes($tempLoginData, $fileBytes)
                Start-Sleep -Milliseconds 100
                
            } catch {
                # Метод 3: Сырое чтение (последняя попытка)
                try {
                    $bytes = [System.IO.File]::ReadAllBytes($loginDataPath)
                    $rawText = [System.Text.Encoding]::UTF8.GetString($bytes)
                    
                    foreach ($site in $suspiciousSites) {
                        if ($rawText -match [regex]::Escape($site)) {
                            if (-not $foundAccounts.ContainsKey($site)) {
                                $foundAccounts[$site] = @{
                                    Browsers = @()
                                    Usernames = @()
                                }
                            }
                            
                            if (-not ($foundAccounts[$site].Browsers -contains $browserName)) {
                                $foundAccounts[$site].Browsers += $browserName
                                $script:totalAccounts++
                            }
                        }
                    }
                    return
                } catch {
                    return
                }
            }
        }
        
        # Если файл скопирован успешно - читаем через SQLite
        if (Test-Path $tempLoginData) {
            try {
                $connectionString = "Data Source=$tempLoginData;Version=3;Read Only=True;"
                $connection = New-Object System.Data.SQLite.SQLiteConnection($connectionString)
                $connection.Open()
                
                $command = $connection.CreateCommand()
                $command.CommandText = "SELECT origin_url, username_value FROM logins WHERE origin_url IS NOT NULL"
                
                $reader = $command.ExecuteReader()
                
                while ($reader.Read()) {
                    try {
                        $originUrl = $reader["origin_url"].ToString()
                        $username = $reader["username_value"].ToString()
                        
                        foreach ($site in $suspiciousSites) {
                            if ($originUrl -match [regex]::Escape($site)) {
                                if (-not $foundAccounts.ContainsKey($site)) {
                                    $foundAccounts[$site] = @{
                                        Browsers = @()
                                        Usernames = @()
                                    }
                                }
                                
                                if (-not ($foundAccounts[$site].Browsers -contains $browserName)) {
                                    $foundAccounts[$site].Browsers += $browserName
                                }
                                
                                if ($username -and $username.Length -gt 0) {
                                    $maskedUsername = if ($username.Length -gt 3) {
                                        $username.Substring(0, 3) + "***"
                                    } else {
                                        "***"
                                    }
                                    
                                    if (-not ($foundAccounts[$site].Usernames -contains $maskedUsername)) {
                                        $foundAccounts[$site].Usernames += $maskedUsername
                                    }
                                }
                                
                                $script:totalAccounts++
                                break
                            }
                        }
                    } catch {
                        continue
                    }
                }
                
                $reader.Close()
                $connection.Close()
                
            } catch {
                # SQLite не сработал - пробуем сырое чтение временного файла
                try {
                    $bytes = [System.IO.File]::ReadAllBytes($tempLoginData)
                    $rawText = [System.Text.Encoding]::UTF8.GetString($bytes)
                    
                    foreach ($site in $suspiciousSites) {
                        if ($rawText -match [regex]::Escape($site)) {
                            if (-not $foundAccounts.ContainsKey($site)) {
                                $foundAccounts[$site] = @{
                                    Browsers = @()
                                    Usernames = @()
                                }
                            }
                            
                            if (-not ($foundAccounts[$site].Browsers -contains $browserName)) {
                                $foundAccounts[$site].Browsers += $browserName
                                $script:totalAccounts++
                            }
                        }
                    }
                } catch {
                    # Игнорируем
                }
            }
            
            # Удаляем временный файл
            Start-Sleep -Milliseconds 100
            Remove-Item -Path $tempLoginData -Force -ErrorAction SilentlyContinue
        }
    }
    
    # Пути к Login Data
    $chromeLoginData = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
    $edgeLoginData = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"
    $operaLoginData = "$env:APPDATA\Opera Software\Opera Stable\Default\Login Data"
    $operaGXLoginData = "$env:APPDATA\Opera Software\Opera GX Stable\Default\Login Data"
    $yandexLoginData = "$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\Ya Passman Data"
    $braveLoginData = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
    $vivaldiLoginData = "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Login Data"
    
    Write-Host "  [~] Scanning browsers for saved accounts..." -ForegroundColor Gray
    Write-Host ""
    
    $scannedCount = 0
    $installedBrowsers = @()
    
    # Проверяем какие браузеры установлены
    if (Test-Path $chromeLoginData) { $installedBrowsers += "Chrome"; $scannedCount++ }
    if (Test-Path $edgeLoginData) { $installedBrowsers += "Edge"; $scannedCount++ }
    if (Test-Path $operaLoginData) { $installedBrowsers += "Opera"; $scannedCount++ }
    if (Test-Path $operaGXLoginData) { $installedBrowsers += "Opera GX"; $scannedCount++ }
    if (Test-Path $yandexLoginData) { $installedBrowsers += "Yandex"; $scannedCount++ }
    if (Test-Path $braveLoginData) { $installedBrowsers += "Brave"; $scannedCount++ }
    if (Test-Path $vivaldiLoginData) { $installedBrowsers += "Vivaldi"; $scannedCount++ }
    
    # Firefox проверка
    $firefoxProfilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $firefoxProfilesPath) {
        $firefoxProfiles = Get-ChildItem -Path $firefoxProfilesPath -Directory
        foreach ($profile in $firefoxProfiles) {
            if (Test-Path (Join-Path $profile.FullName "logins.json")) {
                $installedBrowsers += "Firefox"
                $scannedCount++
                break
            }
        }
    }
    
    Write-Host "  Found $scannedCount browser(s): $($installedBrowsers -join ', ')" -ForegroundColor Gray
    Write-Host ""
    
    # Проверяем каждый браузер
    Check-SavedLogins -loginDataPath $chromeLoginData -browserName "Google Chrome"
    Check-SavedLogins -loginDataPath $edgeLoginData -browserName "Microsoft Edge"
    Check-SavedLogins -loginDataPath $operaLoginData -browserName "Opera"
    Check-SavedLogins -loginDataPath $operaGXLoginData -browserName "Opera GX"
    Check-SavedLogins -loginDataPath $yandexLoginData -browserName "Yandex Browser"
    Check-SavedLogins -loginDataPath $braveLoginData -browserName "Brave"
    Check-SavedLogins -loginDataPath $vivaldiLoginData -browserName "Vivaldi"
    
    # Firefox - использует logins.json вместо Login Data
    $firefoxProfilesPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $firefoxProfilesPath) {
        $firefoxProfiles = Get-ChildItem -Path $firefoxProfilesPath -Directory
        foreach ($profile in $firefoxProfiles) {
            $firefoxLoginsPath = Join-Path $profile.FullName "logins.json"
            if (Test-Path $firefoxLoginsPath) {
                try {
                    $firefoxLogins = Get-Content -Path $firefoxLoginsPath -Raw | ConvertFrom-Json
                    
                    foreach ($login in $firefoxLogins.logins) {
                        $hostname = $login.hostname
                        
                        foreach ($site in $suspiciousSites) {
                            if ($hostname -match [regex]::Escape($site)) {
                                if (-not $foundAccounts.ContainsKey($site)) {
                                    $foundAccounts[$site] = @{
                                        Browsers = @()
                                        Usernames = @()
                                    }
                                }
                                
                                if (-not ($foundAccounts[$site].Browsers -contains "Firefox")) {
                                    $foundAccounts[$site].Browsers += "Firefox"
                                }
                                
                                if ($login.encryptedUsername) {
                                    $foundAccounts[$site].Usernames += "***"
                                }
                                
                                $script:totalAccounts++
                                break
                            }
                        }
                    }
                } catch {
                    # Игнорируем ошибки чтения Firefox
                }
                break
            }
        }
    }
    
    # Показываем результаты проверки аккаунтов
    if ($foundAccounts.Count -gt 0) {
        Write-Host "  ╔═════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "  ║                     🚨 SAVED ACCOUNTS FOUND! 🚨                        ║" -ForegroundColor Red
        Write-Host "  ╚═════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        
        foreach ($entry in $foundAccounts.GetEnumerator()) {
            Write-Host "    • $($entry.Key)" -ForegroundColor White -NoNewline
            Write-Host " - Account detected" -ForegroundColor Red
            Write-Host "      Browser(s): $($entry.Value.Browsers -join ', ')" -ForegroundColor Gray
            
            if ($entry.Value.Usernames.Count -gt 0) {
                Write-Host "      Username(s): $($entry.Value.Usernames -join ', ')" -ForegroundColor DarkGray
            }
        }
        
        Write-Host ""
        
    } else {
        Write-Host "  [✓] NO SAVED ACCOUNTS FOUND" -ForegroundColor Green
        Write-Host ""
        Write-Host "    No saved logins for cheat websites detected." -ForegroundColor Gray
        Write-Host ""
    }
    
    # Статистика
    Write-Host "  ─────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  📊 Statistics:" -ForegroundColor Gray
    Write-Host "     Browsers scanned:          9 (Chrome, Edge, Opera, Opera GX, Yandex, Brave, Vivaldi, Tor, Firefox)" -ForegroundColor White
    Write-Host "     Suspicious sites visited:  $($foundUrls.Count)" -ForegroundColor $(if($foundUrls.Count -gt 0){'Red'}else{'Green'})
    Write-Host "     Total visits:              $totalFound" -ForegroundColor $(if($totalFound -gt 0){'Red'}else{'Green'})
    Write-Host "     Saved accounts found:      $($foundAccounts.Count)" -ForegroundColor $(if($foundAccounts.Count -gt 0){'Red'}else{'Green'})
    Write-Host "  ─────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Press Enter to return to menu"
    Clear-Host
    Show-Logo
    
} elseif ($choice -eq "5") {
    Clear-Host
    Show-Logo
    
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
    Write-Host "  ║                         CHEAT DETECT                                      ║" -ForegroundColor Gray
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select cheat to detect:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    [1] SystemDLC" -ForegroundColor White
    Write-Host "    [2] Liminar" -ForegroundColor White
    Write-Host ""
    Write-Host "    [0] Back to main menu" -ForegroundColor DarkGray
    Write-Host ""
    
    $cheatChoice = Read-Host "Enter choice"
    
    if ($cheatChoice -eq "1") {
        # SystemDLC Detection (код который уже есть)
        Clear-Host
        Show-Logo
        
        Write-Host ""
        Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
        Write-Host "  ║                    CHEAT DETECT: SystemDLC                                ║" -ForegroundColor Gray
        Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
        Write-Host ""
        
        $detectionScore = 0
        $maxScore = 115
        $evidenceFound = @()
        
        Write-Host "  [~] Analyzing system for SystemDLC indicators..." -ForegroundColor Gray
        Write-Host ""
    
    # =====================================================================
    # ПРОВЕРКА 1: IDLE.EXE рядом с ПОСЛЕДНИМ javaw.exe (+25%)
    # =====================================================================
    Write-Host "  [1/5] Checking for suspicious processes (idle + javaw)..." -ForegroundColor Gray
    
    $javawProcesses = Get-Process -Name javaw -ErrorAction SilentlyContinue
    
    # Находим ПОСЛЕДНИЙ (самый новый) javaw процесс
    $lastJavaw = $null
    if ($javawProcesses) {
        if ($javawProcesses.Count -gt 1) {
            # Сортируем по StartTime и берем последний
            $lastJavaw = $javawProcesses | Sort-Object StartTime -Descending | Select-Object -First 1
            Write-Host "    [~] Found $($javawProcesses.Count) javaw processes, checking latest one (PID: $($lastJavaw.Id))" -ForegroundColor Gray
        } else {
            $lastJavaw = $javawProcesses
            Write-Host "    [~] Found 1 javaw process (PID: $($lastJavaw.Id))" -ForegroundColor Gray
        }
    }
    
    $idleRunning = Get-Process -Name idle -ErrorAction SilentlyContinue
    $pythonRunning = Get-Process -Name python, pythonw -ErrorAction SilentlyContinue
    
    # Проверка одновременного запуска с ПОСЛЕДНИМ javaw
    if ($lastJavaw -and ($idleRunning -or $pythonRunning)) {
        $javawStartTime = $lastJavaw.StartTime
        
        # Проверяем что Python/idle запущены ПОСЛЕ или примерно в то же время что javaw
        $suspiciousProcesses = @()
        
        if ($idleRunning) {
            foreach ($idle in $idleRunning) {
                $timeDiff = ($idle.StartTime - $javawStartTime).TotalMinutes
                # Если idle запущен в пределах ±60 минут от javaw
                if ([Math]::Abs($timeDiff) -le 60) {
                    $suspiciousProcesses += @{Name="idle.exe"; PID=$idle.Id; TimeDiff=$timeDiff}
                }
            }
        }
        
        if ($pythonRunning) {
            foreach ($py in $pythonRunning) {
                $timeDiff = ($py.StartTime - $javawStartTime).TotalMinutes
                if ([Math]::Abs($timeDiff) -le 60) {
                    $suspiciousProcesses += @{Name="$($py.Name).exe"; PID=$py.Id; TimeDiff=$timeDiff}
                }
            }
        }
        
        if ($suspiciousProcesses.Count -gt 0) {
            $detectionScore += 25
            Write-Host "    [!] DETECTED: Suspicious processes running near latest javaw.exe" -ForegroundColor Red
            Write-Host "        Latest javaw started: $($javawStartTime.ToString('HH:mm:ss'))" -ForegroundColor Yellow
            
            foreach ($proc in $suspiciousProcesses) {
                $diffText = if ($proc.TimeDiff -gt 0) {
                    "$([Math]::Round($proc.TimeDiff, 1)) min AFTER"
                } else {
                    "$([Math]::Abs([Math]::Round($proc.TimeDiff, 1))) min BEFORE"
                }
                Write-Host "        • $($proc.Name) (PID $($proc.PID)): $diffText javaw" -ForegroundColor Yellow
                $evidenceFound += "$($proc.Name) running $diffText javaw.exe"
            }
            
            Write-Host "        SystemDLC: $detectionScore%" -ForegroundColor Red
        } else {
            Write-Host "    [✓] Python/IDLE processes found but outside suspicious time window" -ForegroundColor Green
        }
    } else {
        if (-not $lastJavaw) {
            Write-Host "    [✓] No javaw.exe process running" -ForegroundColor Green
        } else {
            Write-Host "    [✓] No suspicious process combination detected" -ForegroundColor Green
        }
    }
    
    # Дополнительная проверка: Prefetch файлы (если процессы не найдены, но были недавно)
    if ($detectionScore -eq 0) {
        Write-Host ""
        Write-Host "    [~] Checking Prefetch for recent activity..." -ForegroundColor Gray
        
        try {
            $javawPrefetch = Get-ChildItem "C:\Windows\Prefetch" -Filter "JAVAW*.pf" -ErrorAction SilentlyContinue | 
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
            
            if ($javawPrefetch) {
                $javawLastTime = $javawPrefetch.LastWriteTime
                
                $pythonPrefetch = Get-ChildItem "C:\Windows\Prefetch" -Filter "PYTHON*.pf" -ErrorAction SilentlyContinue | 
                    Where-Object { 
                        $timeDiff = ($_.LastWriteTime - $javawLastTime).TotalMinutes
                        [Math]::Abs($timeDiff) -le 60
                    }
                
                $idlePrefetch = Get-ChildItem "C:\Windows\Prefetch" -Filter "IDLE*.pf" -ErrorAction SilentlyContinue | 
                    Where-Object { 
                        $timeDiff = ($_.LastWriteTime - $javawLastTime).TotalMinutes
                        [Math]::Abs($timeDiff) -le 60
                    }
                
                $pythonwPrefetch = Get-ChildItem "C:\Windows\Prefetch" -Filter "PYTHONW*.pf" -ErrorAction SilentlyContinue | 
                    Where-Object { 
                        $timeDiff = ($_.LastWriteTime - $javawLastTime).TotalMinutes
                        [Math]::Abs($timeDiff) -le 60
                    }
                
                if ($pythonPrefetch -or $idlePrefetch -or $pythonwPrefetch) {
                    $detectionScore += 15
                    Write-Host "    [!] DETECTED: Python/IDLE ran within 1 hour of javaw (Prefetch evidence)" -ForegroundColor Red
                    Write-Host "        Last javaw: $($javawLastTime.ToString('HH:mm:ss dd.MM.yyyy'))" -ForegroundColor Yellow
                    
                    if ($pythonPrefetch) {
                        $pythonTime = ($pythonPrefetch | Select-Object -First 1).LastWriteTime
                        $diff = [Math]::Round(($pythonTime - $javawLastTime).TotalMinutes, 1)
                        Write-Host "        python.exe: $diff minutes apart" -ForegroundColor Yellow
                    }
                    if ($pythonwPrefetch) {
                        $pythonwTime = ($pythonwPrefetch | Select-Object -First 1).LastWriteTime
                        $diff = [Math]::Round(($pythonwTime - $javawLastTime).TotalMinutes, 1)
                        Write-Host "        pythonw.exe: $diff minutes apart" -ForegroundColor Yellow
                    }
                    if ($idlePrefetch) {
                        $idleTime = ($idlePrefetch | Select-Object -First 1).LastWriteTime
                        $diff = [Math]::Round(($idleTime - $javawLastTime).TotalMinutes, 1)
                        Write-Host "        idle.exe: $diff minutes apart" -ForegroundColor Yellow
                    }
                    
                    $evidenceFound += "Python/IDLE executed within 1 hour of javaw (Prefetch)"
                    Write-Host "        SystemDLC: $detectionScore%" -ForegroundColor Red
                }
            }
        } catch { }
    }
    
    Write-Host ""
    
    # =====================================================================
    # ПРОВЕРКА 2: systemdlc.com в истории браузера (+25%)
    # =====================================================================
    Write-Host "  [2/4] Checking browser history for systemdlc.com..." -ForegroundColor Gray
    
    $foundInBrowser = $false
    $browsersWithSite = @()
    
    $browserPaths = @(
        @{Name="Chrome"; Path="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"},
        @{Name="Edge"; Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"},
        @{Name="Opera"; Path="$env:APPDATA\Opera Software\Opera Stable\Default\History"},
        @{Name="Opera GX"; Path="$env:APPDATA\Opera Software\Opera GX Stable\Default\History"},
        @{Name="Yandex"; Path="$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\History"},
        @{Name="Brave"; Path="$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\History"}
    )
    
    foreach ($browser in $browserPaths) {
        if (Test-Path $browser.Path) {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($browser.Path)
                $text = [System.Text.Encoding]::UTF8.GetString($bytes)
                
                if ($text -match 'systemdlc') {
                    $foundInBrowser = $true
                    $browsersWithSite += $browser.Name
                }
            } catch {
                # Файл заблокирован, пробуем через FileStream
                try {
                    $fileStream = [System.IO.File]::Open($browser.Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                    $fileBytes = New-Object byte[] $fileStream.Length
                    $fileStream.Read($fileBytes, 0, $fileStream.Length) | Out-Null
                    $fileStream.Close()
                    
                    $text = [System.Text.Encoding]::UTF8.GetString($fileBytes)
                    
                    if ($text -match 'systemdlc') {
                        $foundInBrowser = $true
                        $browsersWithSite += $browser.Name
                    }
                } catch { }
            }
        }
    }
    
    if ($foundInBrowser) {
        $detectionScore += 25
        Write-Host "    [!] DETECTED: systemdlc.com in browser history [$($browsersWithSite -join ', ')]" -ForegroundColor Red
        Write-Host "        SystemDLC: $detectionScore%" -ForegroundColor Red
        $evidenceFound += "systemdlc.com in browser history ($($browsersWithSite -join ', '))"
    } else {
        Write-Host "    [✓] No systemdlc.com visits found" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # =====================================================================
    # ПРОВЕРКА 3: Сохраненный аккаунт на systemdlc.com (+25%)
    # =====================================================================
    Write-Host "  [3/4] Checking for saved systemdlc.com account..." -ForegroundColor Gray
    
    $accountFound = $false
    $accountBrowsers = @()
    
    $loginDataPaths = @(
        @{Name="Chrome"; Path="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"},
        @{Name="Edge"; Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data"},
        @{Name="Opera"; Path="$env:APPDATA\Opera Software\Opera Stable\Default\Login Data"},
        @{Name="Opera GX"; Path="$env:APPDATA\Opera Software\Opera GX Stable\Default\Login Data"},
        @{Name="Yandex"; Path="$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\Ya Passman Data"},
        @{Name="Brave"; Path="$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Login Data"}
    )
    
    foreach ($browser in $loginDataPaths) {
        if (Test-Path $browser.Path) {
            try {
                $tempFile = Join-Path $env:TEMP "login_temp_$(Get-Random).db"
                
                # Пробуем скопировать
                try {
                    Copy-Item -Path $browser.Path -Destination $tempFile -Force -ErrorAction Stop
                } catch {
                    # Используем FileStream для обхода блокировки
                    $fileStream = [System.IO.File]::Open($browser.Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                    $fileBytes = New-Object byte[] $fileStream.Length
                    $fileStream.Read($fileBytes, 0, $fileStream.Length) | Out-Null
                    $fileStream.Close()
                    [System.IO.File]::WriteAllBytes($tempFile, $fileBytes)
                }
                
                Start-Sleep -Milliseconds 100
                
                # Читаем через SQLite
                try {
                    $connection = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$tempFile;Version=3;Read Only=True;")
                    $connection.Open()
                    
                    $command = $connection.CreateCommand()
                    $command.CommandText = "SELECT origin_url FROM logins WHERE origin_url LIKE '%systemdlc%'"
                    
                    $reader = $command.ExecuteReader()
                    
                    if ($reader.Read()) {
                        $accountFound = $true
                        $accountBrowsers += $browser.Name
                    }
                    
                    $reader.Close()
                    $connection.Close()
                } catch {
                    # SQLite не сработал, пробуем сырое чтение
                    $bytes = [System.IO.File]::ReadAllBytes($tempFile)
                    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
                    
                    if ($text -match 'systemdlc') {
                        $accountFound = $true
                        $accountBrowsers += $browser.Name
                    }
                }
                
                Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
            } catch { }
        }
    }
    
    if ($accountFound) {
        $detectionScore += 25
        Write-Host "    [!] DETECTED: Saved account for systemdlc.com [$($accountBrowsers -join ', ')]" -ForegroundColor Red
        Write-Host "        SystemDLC: $detectionScore%" -ForegroundColor Red
        $evidenceFound += "Saved login credentials for systemdlc.com"
    } else {
        Write-Host "    [✓] No saved accounts found" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # =====================================================================
    # ПРОВЕРКА 4: Поиск файлов с [SELF_MAP] (+25%)
    # =====================================================================
    Write-Host "  [4/4] Searching for [SELF_MAP] files..." -ForegroundColor Gray
    Write-Host "    [~] Criteria: Modified in last 30 days, size 2-40 MB, contains [SELF_MAP]" -ForegroundColor Gray
    
    $selfMapFound = $false
    $selfMapFiles = @()
    
    try {
        $searchPaths = @(
            "$env:USERPROFILE\Downloads",
            "$env:USERPROFILE\Documents",
            "$env:USERPROFILE\Desktop",
            "$env:LOCALAPPDATA",
            "$env:APPDATA",
            "$env:TEMP"
        )
        
        foreach ($path in $searchPaths) {
            if (Test-Path $path) {
                try {
                    Write-Host "    [~] Scanning $path..." -ForegroundColor Gray
                    
                    # Ищем файлы: младше 30 дней, размер 2-40 MB (ограничиваем глубину поиска)
                    $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue -Depth 3 |
                        Where-Object {
                            $_.LastWriteTime -gt (Get-Date).AddDays(-30) -and
                            $_.Length -ge 2MB -and
                            $_.Length -le 40MB
                        } | Select-Object -First 100
                    
                    foreach ($file in $files) {
                        try {
                            # Читаем файл порциями для поиска [SELF_MAP]
                            $stream = [System.IO.File]::OpenRead($file.FullName)
                            $found = $false
                            $chunkSize = 512KB
                            $maxChunks = 5  # Максимум 2.5 MB проверяем
                            
                            for ($i = 0; $i -lt $maxChunks -and $stream.Position -lt $stream.Length; $i++) {
                                $bufferSize = [Math]::Min($chunkSize, $stream.Length - $stream.Position)
                                $buffer = New-Object byte[] $bufferSize
                                $stream.Read($buffer, 0, $buffer.Length) | Out-Null
                                
                                # Проверяем UTF8
                                $text = [System.Text.Encoding]::UTF8.GetString($buffer)
                                if ($text -match '\[SELF_MAP\]') {
                                    $found = $true
                                    break
                                }
                                
                                # Проверяем ASCII если UTF8 не нашёл
                                $text = [System.Text.Encoding]::ASCII.GetString($buffer)
                                if ($text -match '\[SELF_MAP\]') {
                                    $found = $true
                                    break
                                }
                            }
                            
                            $stream.Close()
                            
                            if ($found) {
                                $selfMapFound = $true
                                $selfMapFiles += @{
                                    Name = $file.Name
                                    Path = $file.FullName
                                    Size = [math]::Round($file.Length / 1MB, 2)
                                    Modified = $file.LastWriteTime
                                }
                            }
                        } catch {
                            # Закрываем stream в случае ошибки
                            if ($stream) { $stream.Close() }
                        }
                    }
                } catch { }
            }
        }
        
        if ($selfMapFound) {
            $detectionScore += 25
            Write-Host ""
            Write-Host "    [!] DETECTED: Found $($selfMapFiles.Count) file(s) with [SELF_MAP]" -ForegroundColor Red
            Write-Host "        SystemDLC: $detectionScore%" -ForegroundColor Red
            
            foreach ($file in $selfMapFiles) {
                Write-Host ""
                Write-Host "        📁 File: $($file.Name)" -ForegroundColor Yellow
                Write-Host "           Path: $($file.Path)" -ForegroundColor Gray
                Write-Host "           Size: $($file.Size) MB" -ForegroundColor Gray
                Write-Host "           Modified: $($file.Modified.ToString('dd.MM.yyyy HH:mm:ss'))" -ForegroundColor Gray
            }
            
            $evidenceFound += "[SELF_MAP] files found: $($selfMapFiles.Count)"
        } else {
            Write-Host "    [✓] No [SELF_MAP] files found" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "    [?] Could not complete [SELF_MAP] search" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "  ═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    
    # =====================================================================
    # ФИНАЛЬНЫЙ РЕЗУЛЬТАТ
    # =====================================================================
    
    $color = "Green"
    $statusIcon = "✓"
    $statusText = "CLEAN"
    $riskLevel = "LOW"
    
    if ($detectionScore -ge 75) {
        $color = "Red"
        $statusIcon = "✗"
        $statusText = "VERY HIGH PROBABILITY"
        $riskLevel = "CRITICAL"
    } elseif ($detectionScore -ge 50) {
        $color = "Red"
        $statusIcon = "!"
        $statusText = "HIGH PROBABILITY"
        $riskLevel = "HIGH"
    } elseif ($detectionScore -ge 25) {
        $color = "Yellow"
        $statusIcon = "!"
        $statusText = "SUSPICIOUS"
        $riskLevel = "MEDIUM"
    }
    
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor $color
    Write-Host "  ║                      DETECTION RESULT                                     ║" -ForegroundColor $color
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor $color
    Write-Host ""
    Write-Host "  [$statusIcon] SystemDLC Detection Score: $detectionScore% / $maxScore%" -ForegroundColor $color
    Write-Host "  Status: $statusText" -ForegroundColor $color
    Write-Host "  Risk Level: $riskLevel" -ForegroundColor $color
    Write-Host ""
    
    if ($evidenceFound.Count -gt 0) {
        Write-Host "  📋 Evidence Found:" -ForegroundColor Yellow
        foreach ($evidence in $evidenceFound) {
            Write-Host "    • $evidence" -ForegroundColor White
        }
        Write-Host ""
    }
    
    # Рекомендации
    if ($detectionScore -ge 50) {
        Write-Host "  ⚠️  WARNING:" -ForegroundColor Red
        Write-Host "    High probability of SystemDLC usage detected!" -ForegroundColor Red
        Write-Host "    Multiple indicators suggest the player may be using this cheat." -ForegroundColor Yellow
        Write-Host ""
    } elseif ($detectionScore -ge 25) {
        Write-Host "  ⚠️  CAUTION:" -ForegroundColor Yellow
        Write-Host "    Some suspicious indicators detected." -ForegroundColor Yellow
        Write-Host "    Further investigation recommended." -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "  ═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Press Enter to return to menu"
    Clear-Host
    Show-Logo
    
    } elseif ($cheatChoice -eq "2") {
        # Liminar Detection
        Clear-Host
        Show-Logo
        
        Write-Host ""
        Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Gray
        Write-Host "  ║                      CHEAT DETECT: Liminar                                ║" -ForegroundColor Gray
        Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Gray
        Write-Host ""
        
        Write-Host "  [~] Searching for Liminar evidence..." -ForegroundColor Gray
        Write-Host ""
        
        $liminarDetected = $false
        $backupJsonFiles = @()
        
        # Ищем backup.json только в конкретных папках
        Write-Host "  [1/1] Searching for backup.json files (last 30 days)..." -ForegroundColor Gray
        Write-Host ""
        
        $searchPaths = @(
            "$env:USERPROFILE",
            "$env:LOCALAPPDATA",
            "$env:APPDATA",
            "$env:LOCALAPPDATA\..\LocalLow\uTorrent\configs"
        )
        
        $suspiciousKeywords = @(
            'aimassist',
            'triggerbot', 
            'airstack',
            'airstak',
            'killaura',
            'velocity',
            'antiknockback',
            'reach',
            'autoclicker'
        )
        
        foreach ($path in $searchPaths) {
            $resolvedPath = [System.IO.Path]::GetFullPath($path)
            
            if (Test-Path $resolvedPath) {
                try {
                    Write-Host "    [~] Scanning $resolvedPath..." -ForegroundColor Gray
                    
                    # Ищем backup.json только в корне папки (не рекурсивно)
                    $backupFile = Join-Path $resolvedPath "backup.json"
                    
                    if (Test-Path $backupFile) {
                        $file = Get-Item $backupFile
                        
                        # Проверяем что файл младше 30 дней
                        if ($file.LastWriteTime -gt (Get-Date).AddDays(-30)) {
                            try {
                                $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
                                
                                $foundKeywords = @()
                                foreach ($keyword in $suspiciousKeywords) {
                                    if ($content -match $keyword) {
                                        $foundKeywords += $keyword
                                    }
                                }
                                
                                if ($foundKeywords.Count -gt 0) {
                                    $backupJsonFiles += @{
                                        Path = $file.FullName
                                        LastModified = $file.LastWriteTime
                                        Keywords = $foundKeywords
                                    }
                                }
                            } catch { }
                        }
                    }
                } catch { }
            }
        }
        
        Write-Host ""
        Write-Host "  ═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Gray
        Write-Host ""
        
        if ($backupJsonFiles.Count -gt 0) {
            $liminarDetected = $true
            
            Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
            Write-Host "  ║                          🚨 BAN! LIMINAR DETECTED! 🚨                     ║" -ForegroundColor Red
            Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Found $($backupJsonFiles.Count) backup.json file(s) with cheat signatures:" -ForegroundColor Red
            Write-Host ""
            
            foreach ($file in $backupJsonFiles) {
                Write-Host "    📁 File: $($file.Path)" -ForegroundColor White
                Write-Host "       Last modified: $($file.LastModified.ToString('dd.MM.yyyy HH:mm:ss'))" -ForegroundColor Gray
                Write-Host "       Detected keywords: $($file.Keywords -join ', ')" -ForegroundColor Yellow
                Write-Host ""
            }
            
            Write-Host "  ═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Red
            Write-Host ""
            Write-Host "  ⚠️  VERDICT: INSTANT BAN!" -ForegroundColor Red
            Write-Host ""
            Write-Host "     Reason: Found Liminar cheat configuration files" -ForegroundColor Red
            Write-Host "     Evidence: backup.json with cheat modules detected" -ForegroundColor Red
            Write-Host "     Files age: Less than 30 days old" -ForegroundColor Red
            Write-Host ""
            Write-Host "  ═══════════════════════════════════════════════════════════════════════════" -ForegroundColor Red
            
        } else {
            Write-Host "  ╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "  ║                              ✓ CLEAN                                      ║" -ForegroundColor Green
            Write-Host "  ╚═══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            Write-Host "  [✓] No Liminar evidence found" -ForegroundColor Green
            Write-Host ""
            Write-Host "     No backup.json files with cheat signatures detected" -ForegroundColor Gray
            Write-Host ""
        }
        
        Write-Host ""
        Read-Host "Press Enter to return to menu"
        Clear-Host
        Show-Logo
        
    } elseif ($cheatChoice -eq "0") {
        # Возврат в главное меню - ничего не делаем, цикл while покажет меню сам
    } else {
        # Неверный выбор
        Write-Host ""
        Write-Host "    Invalid choice!" -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
    
    # После выхода из Cheat Detect очищаем экран и показываем лого
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





