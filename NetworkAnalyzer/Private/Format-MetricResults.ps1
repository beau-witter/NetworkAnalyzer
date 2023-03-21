<#
    .SYNOPSIS
        Takes in one metric from the speed test and formats it for further use in output.

    .DESCRIPTION
        Takes one of the measured metrics from the speed test and formats the measurements
        and units for later output. Also attaches the symbols and images for the general
        status of the results for that metric for later output.

        By default, the UpperThreshold separates a "great" status and a "good status" while
        the LowerThreshold separates a "good" status and a "poor" status (bigger is better).
        Using the -Inverse switch means the LowerThreshold separates "great" and "good" and
        the UpperThreshold separates "good" and "poor" (smaller is better).

    .PARAMETER RawMetricResults
        One of the measured metrics from the speed test.
        RawMetricsResults should have two properties: Value and Unit

    .PARAMETER UpperThreshold
        The larger value that separates two status bounds.

    .PARAMETER LowerThreshold
        The smaller value that separates two status bounds.

    .PARAMETER Inverse
        If on, the RawMetricResults.Value represents smaller values as better.
        Default behavior dictates that larger values are better.

    .PARAMETER Basic
        If on, does not attempt to show any potentially derived status value
        and only returns the formatted results as they were received.

    .EXAMPLE
        $metric = [PSCustomObject]@{Value = 90; Unit = "mbps"}
        Format-MetricResults -RawMetricResults $metric -UpperThreshold 80 -LowerThreshold 40
        
        @{
            Result = @{Value = 90; Unit = "mbps"; Text = "90 mbps"}
            Status = @{StatusUnicode = "✅"; StatusImage = "./images/check.png"}
        }
    
    .EXAMPLE
        $metric = [PSCustomObject]@{Value = 40; Unit = "%"}
        Format-MetricResults -RawMetricResults $metric -UpperThreshold 10 -LowerThreshold 5 -Inverse
        
        @{
            Result = @{Value = 40; Unit = "%"; Text = "40 %"}
            Status = @{StatusUnicode = "❌"; StatusImage = "./images/error.png"}
        }

    .NOTES
        Author: Beau Witter

    .OUTPUTS
        [PSCustomObject][Ordered] with the following shape:
        [PSCustomObject][Ordered]Output
            [PSCustomObject][Ordered]Result
                [single]Value
                [string]Unit
                [string]Text
            [PSCustomObject][Ordered]Status (Optional)
                [string]StatusUnicode
                [string]StatusImage
#>
function Format-MetricResults {
    [CmdletBinding(DefaultParameterSetName = "Formatted")]
    param(
        [Parameter(Mandatory = $true)][PSCustomObject] $RawMetricResults,
        [Parameter(Mandatory = $true, ParameterSetName = "Formatted")][single] $UpperThreshold,
        [Parameter(Mandatory = $true, ParameterSetName = "Formatted")][Single] $LowerThreshold,
        [Parameter(ParameterSetName = "Formatted")][switch] $Inverse,
        [Parameter(Mandatory = $true, ParameterSetName = "Basic")][switch] $Basic
    )

    if($Basic)
    {
        return [PSCustomObject][Ordered] @{
            Result = [PSCustomObject][Ordered]@{
                Value = $RawMetricResults.Value
                Unit = $RawMetricResults.Unit
                Text = "$("{0:0.##}" -f $RawMetricResults.Value) $($RawMetricResults.Unit)"
            }
        }
    }

    Write-Verbose "Raw value: $($RawMetricResults.Value) | Upper Threshold: $UpperThreshold | LowerThreshold: $LowerThreshold"
    if(-not $Inverse)
    {
        if($RawMetricResults.Value -ge $UpperThreshold)
        {
            $outcome = "Great"
        }
        elseif($RawMetricResults.Value -lt $UpperThreshold -and $RawMetricResults.Value -ge $LowerThreshold)
        {
            $outcome = "Fair"
        }
        else
        {
            $outcome = "Poor"
        }
    }
    else
    {
        if($RawMetricResults.Value -le $LowerThreshold)
        {
            $outcome = "Great"
        }
        elseif($RawMetricResults.Value -gt $LowerThreshold -and $RawMetricResults.Value -le $UpperThreshold)
        {
            $outcome = "Fair"
        }
        else
        {
            $outcome = "Poor"
        }
    }

    [PSCustomObject][Ordered] @{
        Result = [PSCustomObject][Ordered]@{
            Value = $RawMetricResults.Value
            Unit = $RawMetricResults.Unit
            Text = "$("{0:0.##}" -f $RawMetricResults.Value) $($RawMetricResults.Unit)"
        }
        Status = New-Status -StatusOutcome $outcome
    }
}