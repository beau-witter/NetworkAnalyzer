# This script can be used to generate a new ndt7-client.exe if new versions come out

if($null -eq (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -Match "Go Programming Language" })) {
    throw "Go language not detected. Install here and try again: https://go.dev/dl/"
}

if($null -eq $env:GO111MODULE) {
    Write-Verbose "Setting environment variable 'GO111MODULE' to 'on' for this process."
    [Environment]::SetEnvironmentVariable("GO111MODULE", "on")
}


$oldGoPath = $env:GOPATH
$env:GOPATH = "$env:GOPATH\ndt7-client"

if(!(Test-Path "$env:GOPATH\bin\ndt7-client.exe")) {
    Write-Verbose "Running 'go install'"
    go install github.com/m-lab/ndt7-client-go/cmd/ndt7-client@latest
}

Move-Item -Path $env:GOPATH\bin\ndt7-client.exe -Destination .\bin\ndt7-client.exe -Force

$env:GOPATH = $oldGoPath
