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
            
            # Запускаем основной скрипт skytime.ps1
            $scriptDir = Split-Path -Parent $PSCommandPath
            if ($scriptDir) {
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptDir\skytime.ps1`""
            }
        }
    }
})

# Запускаем таймер
$timer.Start()

# Показываем форму
[void]$form.ShowDialog()

