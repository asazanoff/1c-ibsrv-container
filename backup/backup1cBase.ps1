# Импортируйте модуль OneDrive
Import-Module OneDrive -Force
# $DebugPreference = "Continue"
$newFileName = "1Cv8-Money-" + $(Get-date -Format "dd.MM.yy-HH.mm") + ".zip"
# Путь к файлу, который вы хотите загрузить
$localFilePath = "/home/user/backup/$newFileName" # Absolute path
Function LogWrite {
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}

$settingsPath = "~/backup/settings1CBase.json"

# Путь в OneDrive, куда будет загружен файл
$settings = Get-Content -Path $settingsPath | ConvertFrom-Json
$logfile = $settings.logFilePath

# Get file settings
$dbChangedDateTime = $(Get-Item -Path $settings.originalPath).LastWriteTime
if ($dbChangedDateTime -ne $settings.dbChangedDateTime) {
    LogWrite "Uploading database"    
    # Получите код авторизации
    $authCode = Get-ODAuthentication -ClientId $settings.clientId -AppKey $settings.appKey  -RedirectURI $settings.redirectUri -RefreshToken $settings.refresh_token;
    $settings.access_token = $authCode.access_token
    Compress-Archive -Path $settings.originalPath -DestinationPath $localFilePath -CompressionLevel Optimal
    # Загрузите файл в OneDrive
    Add-ODItemLarge -AccessToken $settings.access_token -LocalFile $localFilePath -Path $settings.oneDrivePath
    Remove-Item $localFilePath
    LogWrite "Upload done. Timestamp is $dbChangedDateTime"
    $settings.dbChangedDateTime = $dbChangedDateTime
    $settings | ConvertTo-Json | Out-File $settingsPath

} else {
    LogWrite "DB did not changed since $dbChangedDateTime. Skip uploading."
}






