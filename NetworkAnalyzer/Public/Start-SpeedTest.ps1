<#
    .SYNOPSIS
        Measures your network speed and displays formatted results.

    .DESCRIPTION
        Runs the Measure-NetworkSpeed function and then takes those results
        with the paramters passed in to create a report of your current speeds.

    .PARAMETER MaximumDownload
        [single] The maximum download speed for your internet plan in mbps.

    .PARAMETER MaximumUpload
        [single] The maximum upload speed for your internet plan in mbps.
    
    .PARAMETER UpperBoundPercent
        [single] The percent of your maximum internet speeds that determines
        whether the result is "great" or "ok".

    .PARAMETER LowerBoundPercent
        [single] The percent of your maximum internet speeds that determines
        whether the result is "ok" or "poor".

    .PARAMETER NoToast
        [switch] Indicates that the output should not be displayed via Windows
        Notification (Toast).

    .PARAMETER NoCLI
        [switch] Indicates that the output should not be displayed via the CLI.

    .EXAMPLE
        Start-SpeedTest 100 100
        <#TODO: PUT EXAMPLE OUTPUT HERE>

    .OUTPUTS
        [PSCustomObject] or None. Sends the formatted results to the output stream
        unless NoCLI was selected, then nothing is returned.

    .NOTES
        Author: Beau Witter
#>
function Start-SpeedTest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][single] $MaximumDownload,
        [Parameter(Mandatory = $true)][single] $MaximumUpload,
        [Parameter()][single] $UpperBoundPercent = 70,
        [Parameter()][single] $LowerBoundPercent = 40,
        [Parameter()][switch] $NoToast,
        [Parameter()][switch] $NoCLI
    )

    if($NoToast -and $NoCLI)
    {
        throw "You cannot disable both Toast and CLI output."
    }

    Write-Verbose "Obtaining Speed Test"
    $speedTestResults = Measure-NetworkSpeed

    #TODO: Get-SpeedStatus

    $output = [PSCustomObject][Ordered] @{
        Download = [PSCustomObject][Ordered] @{
            Speed = "$("{0:0.##}" -f $speedTestResults.Download.Value) $($speedTestResults.Download.Unit)"
            Status = "" #TODO: Add download status here
        }
        Upload = [PSCustomObject][Ordered] @{
            Speed = "$("{0:0.##}" -f $speedTestResults.Upload.Value) $($speedTestResults.Upload.Unit)"
            Status = "" #TODO: Add upload status here
        }
        Ping = "$("{0:0.#}" -f $speedTestResults.MinRTT.Value) $($speedTestResults.MinRTT.Unit)" #TODO: Add way to determine ping status
        PacketLoss = "$("{0:0.##}" -f $speedTestResults.DownloadRetrans.Value)$($speedTestResults.DownloadRetrans.Unit)" #TODO: Add way to determine packet loss status
    }

    #TODO: Handle output via another function? Would make sense given I pass in the Output object and use the statuses on it to determine the output
    # if(-not $NoCLI)
    # {
    #     $output
    # }
    # if(-not $NoToast)
    # {
    #     New-BurntToastNotification -UniqueIdentifier "download" -Text "Download Results", "Speed: $downloadText`nPing: $pingText" -AppLogo $downloadIconPath
    #     New-BurntToastNotification -UniqueIdentifier "upload" -Text "Upload Results", "Speed: $uploadText" -AppLogo $uploadIconPath
    # }
}