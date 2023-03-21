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
    [CmdletBinding(DefaultParameterSetName = "PercentThreshold")]
    param (
        [Parameter()][string] $Mode = "Basic",
        [Parameter(ParameterSetName = "PercentThreshold")][single] $MaximumDownload,
        [Parameter(ParameterSetName = "PercentThreshold")][single] $MaximumUpload,
        [Parameter(ParameterSetName = "PercentThreshold")][single] $MaximumPing,
        [Parameter(ParameterSetName = "PercentThreshold")][single] $MaximumPacketLoss,
        [Parameter(ParameterSetName = "PercentThreshold")][ValidateRange(0,1)][single] $UpperBoundPercent = 0.70,
        [Parameter(ParameterSetName = "PercentThreshold")][ValidateRange(0,1)][single] $LowerBoundPercent = 0.40,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $UpperDownloadThreshold,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $LowerDownloadThreshold,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $UpperUploadThreshold,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $LowerUploadThreshold,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $UpperPingThreshold,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $LowerPingThreshold,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $UpperPacketLossThreshold,
        [Parameter(ParameterSetName = "AbsoluteThreshold")][single] $LowerPacketLossThreshold,
        [Parameter()][string] $ConfigFilePath = "$HOME/network-analyzer.config",
        [Parameter()][switch] $NoToast,
        [Parameter()][switch] $NoCLI,
        [Parameter()][switch] $PassThru
    )

    # Read Configuration
    # Read-NetworkAnalyzerConfiguration

    if($NoToast -and $NoCLI -and (-not $PassThru))
    {
        throw "You cannot disable Toast, CLI, and PassThru output."
    }
    
    # Run Speed Test
    $speedTestResults = Measure-NetworkSpeed
    
    # Format Results
    switch($Mode) {
        "Basic" {
            $download = Format-MetricResults -RawMetricResults $speedTestResults.Download -Basic
            $upload = Format-MetricResults -RawMetricResults $speedTestResults.Upload -Basic
            $ping = Format-MetricResults -RawMetricResults $speedTestResults.MinRTT -Basic
            $packetLoss = Format-MetricResults -RawMetricResults $speedTestResults.DownloadRetrans -Basic
        }
        "PercentThreshold" {
            $download = Format-MetricResults -RawMetricResults $speedTestResults.Download -UpperThreshold ($UpperBoundPercent * $MaximumDownload) -LowerThreshold ($LowerBoundPercent * $MaximumDownload)
            $upload = Format-MetricResults -RawMetricResults $speedTestResults.Upload -UpperThreshold ($UpperBoundPercent * $MaximumUpload) -LowerThreshold ($LowerBoundPercent * $MaximumUpload)
            $ping = Format-MetricResults -RawMetricResults $speedTestResults.MinRTT -UpperThreshold ($UpperBoundPercent * $MaximumPing) -LowerThreshold ($LowerBoundPercent * $MaximumPing) -Inverse
            $packetLoss = Format-MetricResults -RawMetricResults $speedTestResults.DownloadRetrans -UpperThreshold ($UpperBoundPercent * $MaximumPacketLoss) -LowerThreshold ($LowerBoundPercent * $MaximumPacketLoss) -Inverse
        }
        "AbsoluteThreshold" {
            $download = Format-MetricResults -RawMetricResults $speedTestResults.Download -UpperThreshold $UpperDownloadThreshold -LowerThreshold $LowerDownloadThreshold
            $upload = Format-MetricResults -RawMetricResults $speedTestResults.Upload -UpperThreshold $UpperUploadThreshold -LowerThreshold $LowerUploadThreshold
            $ping = Format-MetricResults -RawMetricResults $speedTestResults.MinRTT -UpperThreshold $UpperPingThreshold -LowerThreshold $LowerPingThreshold -Inverse
            $packetLoss = Format-MetricResults -RawMetricResults $speedTestResults.DownloadRetrans -UpperThreshold $UpperPacketLossThreshold -LowerThreshold $LowerPacketLossThreshold -Inverse
        }
    }
    
    # Prepare Output
    $output = [PSCustomObject][Ordered] @{
        Download = $download
        Upload = $upload
        Ping = $ping
        PacketLoss = $packetLoss
    }

    # Write Output
    Write-SpeedTestResults -SpeedTestResults $output -PassThru:$PassThru -NoCli:$NoCLI -NoToast:$NoToast
}