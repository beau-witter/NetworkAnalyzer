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
}