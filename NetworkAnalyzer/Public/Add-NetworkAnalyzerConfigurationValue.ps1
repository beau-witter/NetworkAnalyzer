<#
    .SYNOPSIS
        Adds a Key-Value pair to a [PsCustomObject].

    .DESCRIPTION
        Used to construct and validate a [PsCustomObject] of Key-Value
        pairs to be used directly with Start-SpeedTest or to save as
        a config file with Set-NetworkAnalyzerConfiguration for reuse.

    .PARAMETER SingleKey
        [string] name of a configuration variable whose value is of type
        [single]. Used in conjunction with SingleValue.

        Valid values are: "MaximumDownload", "MaximumUpload", "MaximumPing", "MaximumPacketLoss",
        "UpperBoundPercent", "LowerBoundPercent", "UpperDownloadThreshold", "LowerDownloadThreshold",
        "UpperUploadThreshold", "LowerUploadThreshold", "UpperPingThreshold",
        "LowerPingThreshold", "UpperPacketLossThreshold", "LowerPacketLossThreshold"

    .PARAMETER StringKey
        [string] name of a configuration variable whose value is of type
        [string]. Used in conjunction with StringValue.

        Valid values are: "ConfigFilePath"

    .PARAMETER EnumKey
        [string] name of a configuration variable whose value is of type
        [string] but only allows specific input. Used in conjunction with
        EnumValue.

        Valid values are: "Mode"

    .PARAMETER SwitchKey
        [string] name of a configuration variable whose value is of type
        [switch]. Used in conjunction with SwitchValue.

        Valid values are: "NoToast", "NoCli"

    .PARAMETER SingleValue
        [single] value to use for the specified SingleKey.

    .PARAMETER StringValue
        [string] value to use for the specified StringKey.

    .PARAMETER EnumValue
        [string] value to use for the specified EnumKey.
        For EnumKey "Mode" valid EnumValues are:
        "PercentThreshold", "AbsoluteThreshold", "Basic"

    .PARAMETER SwitchValue
        [bool] value to use for the specified SwitchKey.

    .PARAMETER InputObject
        Optional [PsCustomObject] to add the specified Key-Value
        pairs to. A new object will be used if none is specified.

    .PARAMETER Force
        [switch] that determines if values passed in are allowed
        to overwrite existing Values with the same Key name.

    .EXAMPLE
        Add-NetworkAnalyzerConfigurationValue -SingleKey "MaximumDownload" -SingleValue 100

        MaximumDownload
        ---------------
                    100

    .EXAMPLE
        Add-NetworkAnalyzerConfigurationValue -SingleKey "UpperBoundPercent" -SingleValue 0.8 |
            Add-NetworkAnalyzerConfigurationValue -SwitchKey "NoCli" -SwitchValue $true |
            Add-NetworkAnalyzerConfigurationValue -StringKey "ConfigFilePath" -StringValue "C:\config\NA.config"

        UpperBoundPercent   NoCli        ConfigFilePath
        -----------------------------------------------
                      0.8   True    C:\config\NA.config

    .EXAMPLE
        $config = [PsCustomObject]@{MaximumDownload = 10}
        Add-NetworkAnalyzerConfigurationValue -SingleKey "MaximumDownload" -SingleValue 150 -InputObject $config -Force

        MaximumDownload
        ---------------
                    150

    .NOTES
        Author: Beau Witter

    .OUTPUTS
        [PsCustomObject] of valid Key-Value pairs consisting of the following
        possible keys: "MaximumDownload", "MaximumUpload", "MaximumPing", "MaximumPacketLoss",
        "UpperBoundPercent", "LowerBoundPercent", "UpperDownloadThreshold", "LowerDownloadThreshold",
        "UpperUploadThreshold", "LowerUploadThreshold", "UpperPingThreshold",
        "LowerPingThreshold", "UpperPacketLossThreshold", "LowerPacketLossThreshold",
        "ConfigFilePath", "Mode", "NoToast", "NoCli"
#>
function Add-NetworkAnalyzerConfigurationValue {
    [Alias("Add-NAConfigValue", "Add-NACV")]
    [CmdletBinding(DefaultParameterSetName = "Single")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Single")]
        [ValidateSet("MaximumDownload", "MaximumUpload", "MaximumPing", "MaximumPacketLoss",
        "UpperBoundPercent", "LowerBoundPercent", "UpperDownloadThreshold", "LowerDownloadThreshold",
        "UpperUploadThreshold", "LowerUploadThreshold", "UpperPingThreshold",
        "LowerPingThreshold", "UpperPacketLossThreshold", "LowerPacketLossThreshold")]
        [string] $SingleKey,
        [Parameter(Mandatory = $true, ParameterSetName = "String")]
        [ValidateSet("ConfigFilePath")][string] $StringKey,
        [Parameter(Mandatory = $true, ParameterSetName = "Enum")]
        [ValidateSet("Mode")][string] $EnumKey,
        [Parameter(Mandatory = $true, ParameterSetName = "Switch")]
        [ValidateSet("NoToast", "NoCli")][string] $SwitchKey,
        [Parameter(Mandatory = $true, ParameterSetName = "Single")][single] $SingleValue,
        [Parameter(Mandatory = $true, ParameterSetName = "String")][string] $StringValue,
        [Parameter(Mandatory = $true, ParameterSetName = "Enum")]
        [ValidateSet("PercentThreshold", "AbsoluteThreshold", "Simple")][string] $EnumValue,
        [Parameter(Mandatory = $true, ParameterSetName = "Switch")][bool] $SwitchValue,
        [Parameter(Mandatory = $false, ValueFromPipeline)][ValidateNotNull()][PsCustomObject] $InputObject = [PsCustomObject]@{},
        [Parameter(Mandatory = $false)][switch] $Force
    )

    process {
        switch($PSCmdlet.ParameterSetName)
        {
            "Single" {
                if($SingleKey -in @("UpperBoundPercent", "LowerBoundPercent", "MaximumPacketLoss", "UpperPacketLossThreshold", "LowerPacketLossThreshold") -and ($SingleValue -lt 0 -or $SingleValue -gt 1))
                {
                    throw "$SingleKey can only contain values between 0.0 and 1.0 inclusive."
                }
    
                if(($null -eq ($InputObject | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -eq $SingleKey})) -or $Force)
                {
                    Write-Verbose "$SingleKey : $SingleValue added to input object."
                    $InputObject | Add-Member -MemberType NoteProperty -Name $SingleKey -Value $SingleValue -Force -PassThru
                }
                else
                {
                    Write-Error "A property with the name $SingleKey already exists. If you want to overwrite this value, use the -Force switch."
                    $InputObject
                }
            }
            "String" {
                if(($null -eq ($InputObject | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -eq $StringKey})) -or $Force)
                {
                    Write-Verbose "$StringKey : $StringValue added to input object."
                    $InputObject | Add-Member -MemberType NoteProperty -Name $StringKey -Value $StringValue -Force -PassThru
                }
                else
                {
                    Write-Error "A property with the name $StringKey already exists. If you want to overwrite this value, use the -Force switch."
                    $InputObject
                }
            }
            "Enum" {
                if(($null -eq ($InputObject | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -eq $EnumKey})) -or $Force)
                {
                    Write-Verbose "$EnumKey : $EnumValue added to input object."
                    $InputObject | Add-Member -MemberType NoteProperty -Name $EnumKey -Value $EnumValue -Force -PassThru
                }
                else
                {
                    Write-Error "A property with the name $EnumKey already exists. If you want to overwrite this value, use the -Force switch."
                    $InputObject
                }
            }
            "Switch" {
                if(($null -eq ($InputObject | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -eq $SwitchKey})) -or $Force)
                {
                    Write-Verbose "$SwitchKey : $SwitchValue added to input object."
                    $InputObject | Add-Member -MemberType NoteProperty -Name $SwitchKey -Value $SwitchValue -Force -PassThru
                }
                else
                {
                    Write-Error "A property with the name $SwitchKey already exists. If you want to overwrite this value, use the -Force switch."
                    $InputObject
                }
            }
        }
    }
}