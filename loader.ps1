# Loader script - downloads and executes READINESS_v2.ps1
param()
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$url = 'https://raw.githubusercontent.com/Iwtyys/readiness-skytime/main/READINESS_v2.ps1'

try {
    $webClient = New-Object System.Net.WebClient
    $script = $webClient.DownloadString($url)
    
    # Выполняем скрипт в новой сессии
    Invoke-Command -ScriptBlock ([scriptblock]::Create($script)) -NoNewScope
} catch {
    Write-Error "Failed to load READINESS: $_"
}
