<#

#>
function Measure-NetworkSpeed {
    [CmdletBinding()]
    param()

    New-Item -ItemType Directory -Path ./ -Name tmp
    Write-Output "Running Speed Test..."
    $timeResults = Measure-Command -Expression { Start-Process -FilePath "./bin/ndt7-client.exe" -ArgumentList "-format json" -NoNewWindow -Wait -RedirectStandardOutput "./tmp/speedtestresults.txt" }
    Write-Verbose "The speed test took $($timeResults.TotalSeconds) seconds."
    $results = Get-Content -Path C:\Users\justc\OneDrive\Desktop\results.txt | Select-String -Pattern 'FQDN' | ConvertFrom-JSON
    Remove-Item -Path "./tmp" -Force -Recurse
    $results
}