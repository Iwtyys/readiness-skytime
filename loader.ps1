# Loader script - downloads and executes READINESS_v2.ps1
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$url = 'https://raw.githubusercontent.com/Iwtyys/readiness-skytime/main/READINESS_v2.ps1'
$tempFile = [System.IO.Path]::GetTempFileName() + '.ps1'

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $tempFile)
    
    # Используем dot-sourcing вместо Invoke-Expression
    & $tempFile
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}
