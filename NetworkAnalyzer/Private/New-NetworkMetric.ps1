<#
    .SYNOPSIS
        Returns a new object with only Value and Unit properties.

    .DESCRIPTION
        Takes in one of the metrics from the speed test and returns an object
        that is specifically formatted for further use within the NetworkAnalyzer
        module.

    .PARAMETER Metric
        A metric from the speed test that must contain value and unit properties.

    .EXAMPLE
        $exampleSpeedTestResult = @{...; Download = @{value = 43.54563; unit = "mbps"; ...}}
        $downloadMetric = New-NetworkMetric -Metric $exampleSpeedTestResult.Download
        $downloadMetric
        
        Value = 43.54563
        Unit = mbps

    .NOTES
        Author: Beau Witter

    .OUTPUTS
        [PSCustomObject][Ordered] The output will only have Value and Unit properties.
#>
function New-NetworkMetric {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateScript({$_.value -and $_.unit})][PSCustomObject] $Metric
    )

    Write-Verbose "Creating NetworkMetric with Value $($Metric.value) and Unit $($Metric.unit)"
    [PSCustomObject][Ordered] @{
        Value = $Metric.value
        Unit = $Metric.unit
    }
}