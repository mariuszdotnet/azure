#
# Install Symantec Enpoint Protection client
#

$downloadDirectory = "C:\Temp"

$storageAccoutName = "customscriptautomation"
$storageAccountKey = "/3NvuXZRMWCw6vC0xRGnIVmX/HEim7e9wbbzlGa5lJ3XV4aFvK4cMB8+S87YPOscadeT0SgV52PBB+dHdkmx2g=="
$storageAccountContainer = "sep"
$packageName = "sep-win-14.0.3752.100.exe"

$installerUri = "https://$storageAccoutName.blob.core.windows.net/$storageAccountContainer/$packageName"
$installerLocalPath = "$downloadDirectory\$packageName" 
$installerOptions = '/s'

$date = Get-Date -Format yyyyMMdd-hhmmss
$log_file = "$downloadDirectory\Install-SEP-$date.out"
Function LOG($msg) {
    Write-Output $msg | Tee-Object -FilePath $log_file -Append
}

LOG("Installing Symantec Enpoint Protection client")
LOG("storageAccoutName: $storageAccoutName")
LOG("storageAccountKey: $storageAccountKey")
LOG("storageAccountContainer: $storageAccountContainer")
LOG("packageName: $packageName")
LOG("downloadDirectory: $downloadDirectory")

# create download directory
if(-not (Test-Path $DownloadDirectory)) {
    New-Item $DownloadDirectory -ItemType Directory
}

# get ready to access private storage account and download file
$dateStr = ((Get-Date).ToUniversalTime()).ToString("R")
$stringToSign = "GET`n`n`n`n`n`n`n`n`n`n`n`nx-ms-blob-type:BlockBlob`nx-ms-date:$dateStr`nx-ms-version:2014-02-14`n"
$stringToSign += "/" + $storageAccoutName + "/" + $storageAccountContainer + "/" + $packageName

LOG("Signature string for Get Blob operation")
LOG("=======================================")
LOG($stringToSign)

[byte[]]$dataBytes = ([System.Text.Encoding]::UTF8).GetBytes($stringToSign)
$hmacSHA256 = New-Object System.Security.Cryptography.HMACSHA256
$hmacSHA256.Key = [Convert]::FromBase64String($storageAccountKey)
$signature = [Convert]::ToBase64String($hmacSHA256.ComputeHash($dataBytes))
$authHeader = "SharedKey $storageAccoutName`:$signature"

LOG("Authentication Header")
LOG("=====================")
LOG("$authHeader")

$requestHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$requestHeader.Add("Authorization", $authHeader)
$requestHeader.Add("x-ms-date", $dateStr)
$requestHeader.Add("x-ms-version", "2014-02-14")
$requestHeader.Add("x-ms-blob-type","BlockBlob")

LOG("Request Header")
LOG("==============")
LOG($requestHeader)

$response = New-Object PSObject;
$response = (Invoke-WebRequest -Uri $installerUri -Method Get -Headers $requestHeader -OutFile $installerLocalPath)

LOG("Response")
LOG("========")
LOG($response)

if(-not (Test-Path $installerLocalPath)) {
    LOG("ERR: $packageName download unsuccessful")
    exit(-1)
}

# Install package
$cmd = "Start-Process $installerLocalPath $installerOptions -Wait"
LOG("Executing: $cmd")
Invoke-Expression $cmd

exit(0)
