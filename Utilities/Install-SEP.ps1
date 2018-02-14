#
# Install Symantec Enpoint Protection client
#

$downloadDirectory = "C:\Temp"

$storageAccoutName = "autoehdnqnzkdshhq"
$storageAccountKey = "l3zRRFnmRRuBZuEbbqyU+L5X8Kmv+ZQof+w9X7C3Cmr6Ns+PMwlAF4//+XNzuz/xg2zB7/MPHEnhjhCfBSh+dg=="
$storageAccountContainer = "sep"
$packageName = "sep-win-14.0.3752.100.exe"

$installerUri = "https://$storageAccoutName.blob.core.windows.net/$storageAccountContainer/$packageName"
$installerLocalPath = "$downloadDirectory\$packageName" 
$installerOptions = '/s'

# create download directory
if(-not (Test-Path $DownloadDirectory)) {
    New-Item $DownloadDirectory -ItemType Directory
}

# get ready to access private storage account and download file
$dateStr = ((Get-Date).ToUniversalTime()).ToString("R")
$stringToSign = "GET`n`n`n`n`n`n`n`n`n`n`n`nx-ms-blob-type:BlockBlob`nx-ms-date:$dateStr`nx-ms-version:2014-02-14`n"
$stringToSign += "/" + $storageAccoutName + "/" + $storageAccountContainer + "/" + $packageName

[byte[]]$dataBytes = ([System.Text.Encoding]::UTF8).GetBytes($stringToSign)
$hmacSHA256 = New-Object System.Security.Cryptography.HMACSHA256
$hmacSHA256.Key = [Convert]::FromBase64String($storageAccountKey)
$signature = [Convert]::ToBase64String($hmacSHA256.ComputeHash($dataBytes))
$authHeader = "SharedKey $storageAccoutName`:$signature"

$requestHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$requestHeader.Add("Authorization", $authHeader)
$requestHeader.Add("x-ms-date", $dateStr)
$requestHeader.Add("x-ms-version", "2014-02-14")
$requestHeader.Add("x-ms-blob-type","BlockBlob")

# download file
Invoke-WebRequest -Uri $installerUri -Method Get -Headers $requestHeader -OutFile $installerLocalPath

# validate download
if(-not (Test-Path $installerLocalPath)) {
    exit(-1)
}

# Install package
$cmd = "Start-Process $installerLocalPath $installerOptions -Wait"
Invoke-Expression $cmd

exit(0)