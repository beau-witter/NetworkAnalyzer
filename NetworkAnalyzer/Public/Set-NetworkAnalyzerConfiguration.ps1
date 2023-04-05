<#
    .SYNOPSIS
        Saves Network Analyzer Configuration to a config file.

    .DESCRIPTION
        Saves the InputObject of Key-Values to the default, or specified,
        config file to simplify repeated use of the NetworkAnalyzer module.

    .PARAMETER InputObject
        [PsCustomObject] that contains Key-Value pairs of configurable
        variables to persist to the config file.

        Valid Keys can be seen in Add-NetworkAnalyzerConfiguration.

    .PARAMETER Path
        [string] location to save the configuration values.

    .EXAMPLE
        Set-NetworkAnalyzerConfiguration -InputObject [PsCustomObject]@{MaximumDownload = 100}

    .EXAMPLE
        $config = Add-NACV -SingleKey MaximumUpload -SingleValue 50
        $config | Set-NetworkAnalyzerConfiguration

    .EXAMPLE
        Set-NetworkAnalyzerConfiguration -InputObject [PsCustomObject]@{NoToast = $true} -Path C:\config\NA.config
    
    .NOTES
        Author: Beau Witter

    .LINK
        Add-NetworkAnalyzerConfiguration
#>
function Set-NetworkAnalyzerConfiguration {
    [Alias("Set-NAConfig", "Set-NAC")]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)][PSCustomObject] $InputObject,
        [Parameter(Mandatory = $false)][string]$Path = "$HOME/network-analyzer.config"
    )

    begin {
        if(-not (Test-Path($Path)))
        {
            New-Item -Path $Path -ItemType File
        }
        
        $configFileContents = Get-Content -Path $Path | ConvertFrom-Json
        $configFileContents ??= [PSCustomObject]@{}
    }
    process {
        $SingleKeys = "MaximumDownload", "MaximumUpload", "MaximumPing", "UpperDownloadThreshold", "LowerDownloadThreshold",
                        "UpperUploadThreshold", "LowerUploadThreshold", "UpperPingThreshold", "LowerPingThreshold"
        $PercentKeys = "MaximumPacketLoss", "UpperBoundPercent", "LowerBoundPercent", "UpperPacketLossThreshold",
                        "LowerPacketLossThreshold"
        $StringKeys = "ConfigFilePath"
        $EnumKeys = "Mode"
        $SwitchKeys = "NoToast", "NoCli"
        
        $PresentSingleKeys = $InputObject |
                            Get-Member -MemberType NoteProperty |
                            Where-Object {$_.Name -in $SingleKeys} |
                            Select-Object -ExpandProperty Name

        $PresentPercentKeys = $InputObject |
                            Get-Member -MemberType NoteProperty |
                            Where-Object {$_.Name -in $PercentKeys} |
                            Select-Object -ExpandProperty Name

        $PresentStringKeys = $InputObject |
                            Get-Member -MemberType NoteProperty |
                            Where-Object {$_.Name -in $StringKeys} |
                            Select-Object -ExpandProperty Name

        $PresentEnumKeys = $InputObject |
                           Get-Member -MemberType NoteProperty |
                           Where-Object {$_.Name -in $EnumKeys} |
                           Select-Object -ExpandProperty Name

        $PresentSwitchKeys = $InputObject |
                                Get-Member -MemberType NoteProperty |
                                Where-Object {$_.Name -in $SwitchKeys} |
                                Select-Object -ExpandProperty Name
        
        $PresentSingleKeys | ForEach-Object {
            if($null -ne ($InputObject.$_ -as [single]))
            {
                $configFileContents | Add-Member -MemberType NoteProperty -Name $_ -Value $InputObject.$_ -Force
            }
            else
            {
                Write-Warning "The Key $_ had an invalid value of $($InputObject.$_). Expected type [single]."
            }
        }

        $PresentPercentKeys | ForEach-Object {
            if(($null -ne ($InputObject.$_ -as [single])) -and ([single]$InputObject.$_ -ge 0.0 -and [single]$InputObject.$_ -le 1.0))
            {
                $configFileContents | Add-Member -MemberType NoteProperty -Name $_ -Value $InputObject.$_ -Force
            }
            else
            {
                Write-Warning "The Key $_ had an invalid value of $($InputObject.$_). Expected type [single] between 0.0 and 1.0."
            }
        }

        $PresentStringKeys | ForEach-Object {
            if($InputObject.$_ -is [string])
            {
                $configFileContents | Add-Member -MemberType NoteProperty -Name $_ -Value $InputObject.$_ -Force
            }
            else
            {
                Write-Warning "The Key $_ had an invalid value of $($InputObject.$_). Expected type [string]."
            }
        }

        $validEnums = "PercentThreshold", "AbsoluteThreshold", "Simple"
        $PresentEnumKeys | ForEach-Object {
            if($InputObject.$_ -is [string] -and $InputObject.$_ -in $validEnums)
            {
                $configFileContents | Add-Member -MemberType NoteProperty -Name $_ -Value $InputObject.$_ -Force
            }
            else
            {
                Write-Warning "The Key $_ had an invalid value of $($InputObject.$_). Expected one of the following: $validEnums"
            }
        }

        $PresentSwitchKeys | ForEach-Object {
            if($InputObject.$_ -eq $true -or $InputObject.$_ -eq $false)
            {
                # Save 'true' value
                if($InputObject.$_ -eq $true)
                {
                    $configFileContents | Add-Member -MemberType NoteProperty -Name $_ -Value $InputObject.$_ -Force
                }
                # Remove entry for 'false' value
                else
                {
                    $configFileContents.PSObject.Properties.Remove($_)
                }
            }
            else
            {
                Write-Warning "The Key $_ had an invalid value of $($InputObject.$_). Expected $true or $false."
            }
        }

        if($null -ne ($configFileContents | Get-Member -MemberType NoteProperty))
        {
            Write-Verbose "Path: $Path"
            Write-Verbose "Persisting the object: $configFileContents"
    
            $configFileContents | ConvertTo-Json | Set-Content -Path $Path
        }
    }
}