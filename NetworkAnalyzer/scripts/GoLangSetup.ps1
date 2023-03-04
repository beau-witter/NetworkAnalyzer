# Error if golang is not installed
if($null -eq (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -Match "Go Programming Language" })) {
    throw "Go language not detected. Install here and try again: https://go.dev/dl/"
}

if($null -eq $env:GO111MODULE) {
    Write-Verbose "Setting environment variable 'GO111MODULE' to 'on' for this process."
    [Environment]::SetEnvironmentVariable("GO111MODULE", "on")
}