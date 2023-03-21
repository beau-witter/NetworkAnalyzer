<#
    .SYNOPSIS
        Execute NDT7-Client.exe to measure Network Speed.

    .DESCRIPTION
        Executes the bundled NDT7-Client.exe to perform a speed test
        and return back just the summary results in json format.

    .EXAMPLE
        Measure-NetworkSpeed

    .OUTPUTS
        PSCustomObject.
        Contains the following keys:
            ServerFQDN, ServerIP, ClientIP,
            DownloadUUID, Download, Upload,
            DownloadRetrans, and MinRTT
    
    .NOTES
        Author: Beau Witter
#>
function Measure-NetworkSpeed {
    [CmdletBinding()]
    param()

    New-Item -ItemType Directory -Path $HOME -Name tmp -Force | Out-Null
    Write-Host "Running Speed Test..."
    $timeResults = Measure-Command -Expression { Start-Process -FilePath "./bin/ndt7-client.exe" -ArgumentList "-format json" -NoNewWindow -Wait -RedirectStandardOutput "$HOME/tmp/speedtestresults.txt" }
    Write-Verbose "The speed test took $($timeResults.TotalSeconds) seconds."
    $results = Get-Content -Path "$HOME/tmp/speedtestresults.txt" | Select-String -Pattern 'FQDN' | ConvertFrom-JSON
    Remove-Item -Path "$HOME/tmp" -Force -Recurse
    $results
}