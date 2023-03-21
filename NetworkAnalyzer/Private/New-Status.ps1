<#
    .SYNOPSIS
        Returns a new object with only StatusUnicode and StatusImage properties.

    .DESCRIPTION
        Takes in one of 3 possible status outcome strings and returns the matching
        unicode icon and image for that level of result.

    .PARAMETER StatusOutcome
        One of either "Great", "Fair", or "Poor" which describes the results of a metric.

    .EXAMPLE
        New-Status -StatusOutcome "Fair"
        
        StatusUnicode = "⚠️"
        StatusImage = "./images/warning.png"

    .NOTES
        Author: Beau Witter

    .OUTPUTS
        [PSCustomObject][Ordered] The output will only have the StatusUnicode and StatusImage properties.
#>

function New-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet("Great", "Fair", "Poor")] $StatusOutcome
    )

    if($StatusOutcome -eq "Great")
    {
        Write-Verbose "Great Result"
        $unicode = "✅"
        $imagePath = "./images/check.png"
    }
    elseif ($StatusOutcome -eq "Fair")
    {
        Write-Verbose "Fair Result"
        $unicode = "⚠️"
        $imagePath = "./images/warning.png"
    }
    else
    {
        Write-Verbose "Poor Result"
        $unicode = "❌"
        $imagePath = "./images/error.png"
    }

    [PSCustomObject][Ordered]@{
        StatusUnicode = $unicode
        StatusImage = $imagePath
    }
}