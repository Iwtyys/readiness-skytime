Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================
# GUI МЕНЮ С ЗАКРУГЛЕНИЕМ И ПЕРЕТАСКИВАНИЕМ
# ============================================

$form = New-Object System.Windows.Forms.Form
$form.Text = "READINESS"
$form.Size = New-Object System.Drawing.Size(500, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.TopMost = $true
$form.DoubleBuffered = $true  # Двойная буферизация - БЕЗ мерцания!

# Закруглённые углы
$radius = 25
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$rect = New-Object System.Drawing.Rectangle(0, 0, 500, 600)
$path.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
$path.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
$path.CloseFigure()
$form.Region = New-Object System.Drawing.Region($path)

# Main panel
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$mainPanel.DoubleBuffered = $true
$form.Controls.Add($mainPanel)

# Переменные для перетаскивания
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

# Логотип
$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Text = "READINESS"
$logoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$logoLabel.ForeColor = [System.Drawing.Color]::White
$logoLabel.BackColor = [System.Drawing.Color]::Transparent
$logoLabel.AutoSize = $false
$logoLabel.Size = New-Object System.Drawing.Size(480, 50)
$logoLabel.Location = New-Object System.Drawing.Point(10, 15)
$logoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$mainPanel.Controls.Add($logoLabel)

# Сепаратор
$sepLabel = New-Object System.Windows.Forms.Label
$sepLabel.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
$sepLabel.Size = New-Object System.Drawing.Size(480, 1)
$sepLabel.Location = New-Object System.Drawing.Point(10, 70)
$mainPanel.Controls.Add($sepLabel)

# Меню опций
$options = @(
    @{Number=1; Title="Memory Scanner"; Desc="Scan javaw.exe processes"},
    @{Number=2; Title="JAR Checker"; Desc="Check java.exe JAR files"},
    @{Number=3; Title="Mods Scanner"; Desc="Scan mods folder"},
    @{Number=4; Title="DLL Checker"; Desc="Check suspicious DLL"},
    @{Number=5; Title="SafeMode Detection"; Desc="SafeMode detection"},
    @{Number=6; Title="Browser History"; Desc="Browser History Scanner"}
)

$yPos = 90
foreach ($opt in $options) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "[$($opt.Number)] $($opt.Title)`n$($opt.Desc)"
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $btn.FlatAppearance.BorderSize = 1
    $btn.Size = New-Object System.Drawing.Size(460, 60)
    $btn.Location = New-Object System.Drawing.Point(20, $yPos)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    # Tag для хранения номера опции
    $btn.Tag = $opt.Number
    
    # Обработчик клика
    $btn.Add_Click({
        param($sender, $e)
        $choice = $sender.Tag
        
        # Закрываем форму
        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Tag = $choice
        $form.Close()
    })
    
    # Эффект при наведении
    $btn.Add_MouseEnter({
        $btn.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    })
    
    $btn.Add_MouseLeave({
        $btn.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    })
    
    $mainPanel.Controls.Add($btn)
    $yPos += 70
}

# Кнопка Exit
$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = "[0] Exit"
$exitBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$exitBtn.ForeColor = [System.Drawing.Color]::White
$exitBtn.BackColor = [System.Drawing.Color]::FromArgb(60, 30, 30)
$exitBtn.FlatStyle = "Flat"
$exitBtn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(100, 50, 50)
$exitBtn.FlatAppearance.BorderSize = 1
$exitBtn.Size = New-Object System.Drawing.Size(460, 50)
$exitBtn.Location = New-Object System.Drawing.Point(20, 540)
$exitBtn.Cursor = [System.Windows.Forms.Cursors]::Hand

$exitBtn.Add_Click({
    $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Tag = 0
    $form.Close()
})

$exitBtn.Add_MouseEnter({
    $exitBtn.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40)
})

$exitBtn.Add_MouseLeave({
    $exitBtn.BackColor = [System.Drawing.Color]::FromArgb(60, 30, 30)
})

$mainPanel.Controls.Add($exitBtn)

# Показываем форму и возвращаем выбор
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    return $form.Tag
} else {
    return 0
}
