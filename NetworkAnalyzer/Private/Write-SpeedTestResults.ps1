function Write-SpeedTestResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][PSCustomObject] $SpeedTestResults,
        [Parameter(Mandatory = $false)][switch] $PassThru,
        [Parameter(Mandatory = $false)][switch] $NoCli,
        [Parameter(Mandatory = $false)][switch] $NoToast,
        [Parameter(Mandatory = $false)][switch] $Basic
    )

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
  Download      $dlt $($download.Status.StatusUnicode)
  Upload        $ult $($upload.Status.StatusUnicode)
  Ping          $pit $($ping.Status.StatusUnicode)
  Packet Loss   $plt $($packetLoss.Status.StatusUnicode)
"@
            Write-Host $hereString
        }
    }

    if(-not $NoToast)
    {
        if($Basic)
        {
            New-BurntToastNotification -UniqueIdentifier "download" -Text "Download Results", "Speed: $($SpeedTestResults.Download.Result.Text)"
            New-BurntToastNotification -UniqueIdentifier "upload" -Text "Upload Results", "Speed: $($SpeedTestResults.Upload.Result.Text)"
            New-BurntToastNotification -UniqueIdentifier "ping" -Text "Ping Results", "Latency: $($SpeedTestResults.Ping.Result.Text)"
            New-BurntToastNotification -UniqueIdentifier "packetloss" -Text "Packet Loss Results", "Loss Percentage: $($SpeedTestResults.PacketLoss.Result.Text)"
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