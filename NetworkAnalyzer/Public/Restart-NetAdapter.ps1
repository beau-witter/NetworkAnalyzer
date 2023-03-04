<#
    .SYNOPSIS
        Resets the currently in use Net Adapter.

    .DESCRIPTION
        Finds and disables the provided Net Adapter, or most likely in use one,
        and then turns it back on. Only able to do so if in an elevated process.

    .PARAMETER NetAdapterName
        Name of the Net Adapter to restart. If none given, the Net Adapter with
        the most received bytes will be selected to restart.

    .EXAMPLE
        Restart-NetAdapter

    .EXAMPLE
        Restart-NetAdapter -NetAdapterName "Ethernet"

    .OUTPUTS
        None. This function does not return any output.

    .NOTES
        Author: Beau Witter
#>
function Restart-NetAdapter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)][string] $NetAdapterName = $null
    )

    begin {
        if(-not (Test-IsElevated))
        {
            Write-Error "Cannot perform 'Restart-NetAdapter' while not in an elevated process."
            continue
        }
    }

    process {
        if(-not $NetAdapterName)
        {
            Write-Verbose "No Net Adapter provided. Finding most likely in use Net Adapter to restart..."
            $netAdapterInUse = Get-NetAdapterStatistics | Sort-Object -Property ReceivedBytes -Descending | Select-Object -First 1
            $NetAdapterName = $netAdapterInUse.Name
        }
        
        Disable-NetAdapter -Name $NetAdapterName -Confirm:$false
        Enable-NetAdapter -Name $NetAdapterName -Confirm:$false
    }
}