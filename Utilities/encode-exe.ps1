#
# Perform base64-encoding for file
#

param (
    [string]$infile,
    [string]$outfile,
    [switch]$force = $false
 )
 
Write-Output "Option infile: $infile"
Write-Output "Option outfile: $outfile"
Write-Output "Option force: $force"

if(-not (Test-Path $infile)) {
    throw "Ensure that you have permission to the file, and that the file path is correct. Exiting..."
}

Try {
    $content = Get-Content -Path $infile -Encoding Byte 
}
Catch {
    throw "Failed to read infile. Exiting..."
}

if($content) {
    $base64 = [System.Convert]::ToBase64String($content)
} else {
    throw '$content in $null'
}

Try {
    $base64 | Out-File $outfile
}
Catch {
    throw "Failed to write outfile. Exiting..."
}