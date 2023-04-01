<#
    .SYNOPSIS
        Takes the results from the speed test and sends them
        to the specified output location(s).

    .DESCRIPTION
        Takes in the formatted results of the speed test and
        then send the results any or all of the following:
        Command Line as human readable output, a group of
        toast notifications, and to the output stream as
        a PsCustomObject.

    .PARAMETER SpeedTestResults
        [PsCustomObject] the formatted speed test results that will
        be written as output.

    .PARAMETER PassThru
        [switch] if present, will send the speed test results [PsCustomObject]
        out to the output stream to be used programmatically.

    .PARAMETER NoCli
        [switch] if present, will skip printing out the human readable
        version of the output to the command line.

    .PARAMETER NoToast
        [switch] if present, will skip displaying the group of toast
        notifications version of the output.

    .PARAMETER Basic
        [switch] if present, indicates that the results do not have
        a status element to output.

    .EXAMPLE
        Write-SpeedTestResults -SpeedTestResults $result -PassThru -NoCli -NoToast -Basic

        This will only return the $result object out to the output stream for
        further use or inspection, and it doesn't include status properties.

    .EXAMPLE
        Write-SpeedTestResults -SpeedTestResults $result

        This will print human readable text of the result to the cli and pop up
        the group of toasts for the results. $result will not be sent to the
        output stream.
    
    .NOTES
        Author: Beau Witter
#>
function Write-SpeedTestResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][PSCustomObject] $SpeedTestResults,
        [Parameter(Mandatory = $false)][switch] $PassThru,
        [Parameter(Mandatory = $false)][switch] $NoCli,
        [Parameter(Mandatory = $false)][switch] $NoToast,
        [Parameter(Mandatory = $false)][switch] $Basic
    )

    Write-Verbose "PassThru? $PassThru"
    Write-Verbose "NoCli? $NoCli"
    Write-Verbose "NoToast? $NoToast"
    Write-Verbose "Basic? $Basic"

    if(-not $NoCLI)
    {
        if($Basic)
        {
            $hereString = @"
--------------------------------
-------Speed Test Results-------
--------------------------------
| Metric      | Measurement
--------------------------------
  Download        $($SpeedTestResults.Download.Result.Text)
  Upload          $($SpeedTestResults.Upload.Result.Text)
  Ping            $($SpeedTestResults.Ping.Result.Text)
  Packet Loss     $($SpeedTestResults.PacketLoss.Result.Text)
"@
            Write-Host $hereString
        }
        else
        {
            $formatConst = 15
            $dlt = $SpeedTestResults.Download.Result.Text + (" " * ($formatConst - $SpeedTestResults.Download.Result.Text.length))
            $ult = $SpeedTestResults.Upload.Result.Text + (" " * ($formatConst - $SpeedTestResults.Upload.Result.Text.length))
            $pit = $SpeedTestResults.Ping.Result.Text + (" " * ($formatConst - $SpeedTestResults.Ping.Result.Text.length))
            $plt = $SpeedTestResults.PacketLoss.Result.Text + (" " * ($formatConst - $SpeedTestResults.PacketLoss.Result.Text.length))
            $hereString = @"
---------------------------------------
----------Speed Test Results-----------
---------------------------------------
| Metric      | Measurement  | Status |
---------------------------------------
  Download      $dlt $($SpeedTestResults.Download.Status.StatusUnicode)
  Upload        $ult $($SpeedTestResults.Upload.Status.StatusUnicode)
  Ping          $pit $($SpeedTestResults.Ping.Status.StatusUnicode)
  Packet Loss   $plt $($SpeedTestResults.PacketLoss.Status.StatusUnicode)
"@
            Write-Host $hereString
        }
    }

    if(-not $NoToast)
    {
        if($Basic)
        {
            New-BurntToastNotification -UniqueIdentifier "download" -Text "Download Results", "Speed: $($SpeedTestResults.Download.Result.Text)" -AppLogo "None" 3> $null
            New-BurntToastNotification -UniqueIdentifier "upload" -Text "Upload Results", "Speed: $($SpeedTestResults.Upload.Result.Text)" -AppLogo "None" 3> $null
            New-BurntToastNotification -UniqueIdentifier "ping" -Text "Ping Results", "Latency: $($SpeedTestResults.Ping.Result.Text)" -AppLogo "None" 3> $null
            New-BurntToastNotification -UniqueIdentifier "packetloss" -Text "Packet Loss Results", "Loss Percentage: $($SpeedTestResults.PacketLoss.Result.Text)" -AppLogo "None" 3> $null
        }
        else
        {
            New-BurntToastNotification -UniqueIdentifier "download" -Text "Download Results", "Speed: $($SpeedTestResults.Download.Result.Text)" -AppLogo $SpeedTestResults.Download.Status.StatusImage
            New-BurntToastNotification -UniqueIdentifier "upload" -Text "Upload Results", "Speed: $($SpeedTestResults.Upload.Result.Text)" -AppLogo $SpeedTestResults.Upload.Status.StatusImage
            New-BurntToastNotification -UniqueIdentifier "ping" -Text "Ping Results", "Latency: $($SpeedTestResults.Ping.Result.Text)" -AppLogo $SpeedTestResults.Ping.Status.StatusImage
            New-BurntToastNotification -UniqueIdentifier "packetloss" -Text "Packet Loss Results", "Loss Percentage: $($SpeedTestResults.PacketLoss.Result.Text)" -AppLogo $SpeedTestResults.PacketLoss.Status.StatusImage
        }
    }

    if($PassThru)
    {
        $SpeedTestResults
    }
}