Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "READINESS"
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

# ============================================
# ПОЛНОЕ МЕНЮ ИЗ SKYTIME
# ============================================
& 'c:\ДЕТЕКТ ГОСТ\skytime.ps1'
