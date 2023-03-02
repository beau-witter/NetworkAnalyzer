<#
    .SYNOPSIS
        Tests if the current process is elevated.

    .DESCRIPTION
        Returns true if the current process is elevated, false if the current process is not elevated.      

    .EXAMPLE
        PS> Test-IsElevated
        False

    .OUTPUTS
        bool. Whether the current process is elevated ($true) or not ($false).

    .NOTES
        Author: Beau Witter
#>
Function Test-IsElevated {
    [CmdletBinding()]
    param()

    $currentProcess = Get-Process -Id $PID
    Write-Verbose "Obtained Process with PID: $($PID)"
    Write-Verbose "Checking values for Path and Handle to determine process access level..."
    (-not $currentProcess.Path) -and (-not $currentProcess.Handle)
}