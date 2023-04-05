BeforeAll {
    Import-Module "NetworkAnalyzer"

    $Module = @{
        ModuleName = 'NetworkAnalyzer'
    }
}

Describe 'Set-NetworkAnalyzerConfiguration' {
    Context 'Begin' {
        It 'creates a new config file if one does not exist' {
            Mock 'New-Item' @Module -Verifiable
            Mock 'Get-Content' @Module
            Mock 'ConvertFrom-Json' @Module
            $inputObject = [PsCustomObject]@{}
            $inputObject | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/test.config"
            Should -InvokeVerifiable
        }

        It 'uses the config file at the provided path if it does exist' {
            Mock 'Test-Path' -ParameterFilter {$Path -eq "TestDrive:/test.config"} -MockWith {$true} @Module
            Mock 'New-Item' @Module
            Mock 'Get-Content' @Module
            Mock 'ConvertFrom-Json' @Module
            $inputObject = [PsCustomObject]@{}
            $inputObject | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/test.config"
            Should -Not -Invoke "New-Item" @Module
        }
    }

    Context 'Process' {
        BeforeDiscovery {
            $allKeyValuesInput = [PsCustomObject]@{
                # Single
                MaximumDownload = 100
                MaximumUpload = 99
                MaximumPing = 98
                UpperDownloadThreshold = 97
                LowerDownloadThreshold = 96
                UpperUploadThreshold = 95
                LowerUploadThreshold = 94
                UpperPingThreshold = 93
                LowerPingThreshold = 92

                # Percent
                MaximumPacketLoss = 1.0
                UpperBoundPercent = 0.9
                LowerBoundPercent = 0.8
                UpperPacketLossThreshold = 0.7
                LowerPacketLossThreshold = 0.6

                # String
                ConfigFilePath = "TestDrive:/test.config"

                # Enum
                Mode = "AbsoluteThreshold"

                # Switch
                NoToast = $true
                NoCli = $true
            }

            $maxPercentAllKeyValuesInput = [PsCustomObject]@{
                # Single
                MaximumDownload = 100
                MaximumUpload = 99
                MaximumPing = 98
                UpperDownloadThreshold = 97
                LowerDownloadThreshold = 96
                UpperUploadThreshold = 95
                LowerUploadThreshold = 94
                UpperPingThreshold = 93
                LowerPingThreshold = 92

                # Percent
                MaximumPacketLoss = 1.0
                UpperBoundPercent = 1.0
                LowerBoundPercent = 1.0
                UpperPacketLossThreshold = 1.0
                LowerPacketLossThreshold = 1.0

                # String
                ConfigFilePath = "TestDrive:/test.config"

                # Enum
                Mode = "AbsoluteThreshold"

                # Switch
                NoToast = $true
                NoCli = $true
            }

            $zeroPercentAllKeyValuesInput = [PsCustomObject]@{
                # Single
                MaximumDownload = 100
                MaximumUpload = 99
                MaximumPing = 98
                UpperDownloadThreshold = 97
                LowerDownloadThreshold = 96
                UpperUploadThreshold = 95
                LowerUploadThreshold = 94
                UpperPingThreshold = 93
                LowerPingThreshold = 92

                # Percent
                MaximumPacketLoss = 0.0
                UpperBoundPercent = 0.0
                LowerBoundPercent = 0.0
                UpperPacketLossThreshold = 0.0
                LowerPacketLossThreshold = 0.0

                # String
                ConfigFilePath = "TestDrive:/test.config"

                # Enum
                Mode = "AbsoluteThreshold"

                # Switch
                NoToast = $true
                NoCli = $true
            }

            $falseSwitchAllKeyValuesInput = [PsCustomObject]@{
                # Single
                MaximumDownload = 100
                MaximumUpload = 99
                MaximumPing = 98
                UpperDownloadThreshold = 97
                LowerDownloadThreshold = 96
                UpperUploadThreshold = 95
                LowerUploadThreshold = 94
                UpperPingThreshold = 93
                LowerPingThreshold = 92

                # Percent
                MaximumPacketLoss = 1.0
                UpperBoundPercent = 0.9
                LowerBoundPercent = 0.8
                UpperPacketLossThreshold = 0.7
                LowerPacketLossThreshold = 0.6

                # String
                ConfigFilePath = "TestDrive:/test.config"

                # Enum
                Mode = "AbsoluteThreshold"

                # Switch
                NoToast = $false
                NoCli = $false
            }
        }

        It 'correctly adds the single keys as singles' -TestCases @(
            @{InputValues = $allKeyValuesInput}
        ) {
            $singleKeys = "MaximumDownload", "MaximumUpload", "MaximumPing", "UpperDownloadThreshold", "LowerDownloadThreshold",
                            "UpperUploadThreshold", "LowerUploadThreshold", "UpperPingThreshold", "LowerPingThreshold"
            
            $InputValues | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/single_success_test.config"

            $retrieve = Get-Content -Path "TestDrive:/single_success_test.config" | ConvertFrom-Json
            $singleKeys | ForEach-Object {
                ([single]$retrieve.$_) -is [single] | Should -BeTrue
            }
        }

        It 'writes a warning if the value for a single key is the wrong type' -TestCases @(
            @{InputValue = [PsCustomObject]@{MaximumDownload = "bad"}},
            @{InputValue = [PsCustomObject]@{MaximumUpload = "bad"}},
            @{InputValue = [PsCustomObject]@{MaximumPing = "bad"}},
            @{InputValue = [PsCustomObject]@{UpperDownloadThreshold = "bad"}},
            @{InputValue = [PsCustomObject]@{LowerDownloadThreshold = "bad"}},
            @{InputValue = [PsCustomObject]@{UpperUploadThreshold = "bad"}},
            @{InputValue = [PsCustomObject]@{LowerUploadThreshold = "bad"}},
            @{InputValue = [PsCustomObject]@{UpperPingThreshold = "bad"}},
            @{InputValue = [PsCustomObject]@{LowerPingThreshold = "bad"}}
        ) {
            Mock 'Write-Warning' -ParameterFilter { $Message.Contains(($InputValue | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name))} @Module -Verifiable

            $InputValue | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/single_warning_test.config"

            $null -eq (Get-Content -Path "TestDrive:/single_warning_test.config") | Should -BeTrue
            Should -InvokeVerifiable
        }

        It 'correctly adds the percent keys as singles between 0.0 and 1.0' -TestCases @(
            @{InputValues = $allKeyValuesInput},
            @{InputValues = $maxPercentAllKeyValuesInput},
            @{InputValues = $zeroPercentAllKeyValuesInput}
        ) {
            $percentKeys = "MaximumPacketLoss", "UpperBoundPercent", "LowerBoundPercent", "UpperPacketLossThreshold", "LowerPacketLossThreshold"

            $InputValues | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/percent_success_test.config"

            $retrieve = Get-Content -Path "TestDrive:/percent_success_test.config" | ConvertFrom-Json
            $percentKeys | ForEach-Object {
                [single] $retrieveValue = $retrieve.$_ -as [single] 
                $retrieveValue -is [single] | Should -Be $true
                $retrieveValue -ge 0.0 | Should -Be $true
                $retrieveValue -le 1.0 | Should -Be $true
            }
        }

        It 'writes a warning if the value for a percent key is the wrong type or value' -TestCases @(
            @{InputValue = [PsCustomObject]@{MaximumPacketLoss = "bad"}},
            @{InputValue = [PsCustomObject]@{UpperBoundPercent = "bad"}},
            @{InputValue = [PsCustomObject]@{LowerBoundPercent = "bad"}},
            @{InputValue = [PsCustomObject]@{UpperPacketLossThreshold = "bad"}},
            @{InputValue = [PsCustomObject]@{LowerPacketLossThreshold = "bad"}},
            @{InputValue = [PsCustomObject]@{MaximumPacketLoss = -0.1}},
            @{InputValue = [PsCustomObject]@{UpperBoundPercent = -0.1}},
            @{InputValue = [PsCustomObject]@{LowerBoundPercent = -0.1}},
            @{InputValue = [PsCustomObject]@{UpperPacketLossThreshold = -0.1}},
            @{InputValue = [PsCustomObject]@{LowerPacketLossThreshold = -0.1}},
            @{InputValue = [PsCustomObject]@{MaximumPacketLoss = 1.1}},
            @{InputValue = [PsCustomObject]@{UpperBoundPercent = 1.1}},
            @{InputValue = [PsCustomObject]@{LowerBoundPercent = 1.1}},
            @{InputValue = [PsCustomObject]@{UpperPacketLossThreshold = 1.1}},
            @{InputValue = [PsCustomObject]@{LowerPacketLossThreshold = 1.1}}
        ) {
            Mock 'Write-Warning' -ParameterFilter { $Message.Contains(($InputValue | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name))} @Module -Verifiable

            $InputValue | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/percent_warning_test.config"

            $null -eq (Get-Content -Path "TestDrive:/percent_warning_test.config") | Should -BeTrue
            Should -InvokeVerifiable
        }

        It 'correctly adds the string keys as strings' -TestCases @(
            @{InputValues = $allKeyValuesInput}
        ) {
            $stringKeys = "ConfigFilePath"

            $InputValues | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/string_success_test.config"

            $retrieve = Get-Content -Path "TestDrive:/string_success_test.config" | ConvertFrom-Json
            $stringKeys | ForEach-Object {
                ([string]$retrieve.$_) -is [string] | Should -BeTrue
            }
        }

        It 'writes a warning if the value for a string key is the wrong type' -TestCases @(
            @{InputValue = [PsCustomObject]@{ConfigFilePath = @{Wrong = "value"}}}
        ) {
            Mock 'Write-Warning' -ParameterFilter { $Message.Contains(($InputValue | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name))} @Module -Verifiable

            $InputValue | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/string_warning_test.config"

            $null -eq (Get-Content -Path "TestDrive:/string_warning_test.config") | Should -BeTrue
            Should -InvokeVerifiable
        }

        It 'correctly adds the enum keys as strings' -TestCases @(
            @{InputValues = $allKeyValuesInput}
        ) {
            $enumKeys = "Mode"

            $InputValues | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/enum_success_test.config"

            $retrieve = Get-Content -Path "TestDrive:/enum_success_test.config" | ConvertFrom-Json
            $enumKeys | ForEach-Object {
                ([string]$retrieve.$_) -is [string] | Should -BeTrue
            }
        }

        It 'writes a warning if the value for an enum key is the wrong type of value' -TestCases @(
            @{InputValue = [PsCustomObject]@{Mode = "WrongValue"}},
            @{InputValue = [PsCustomObject]@{Mode = @{Wrong = "type"}}}
        ) {
            Mock 'Write-Warning' -ParameterFilter { $Message.Contains(($InputValue | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name))} @Module -Verifiable

            $InputValue | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/enum_warning_test.config"

            $null -eq (Get-Content -Path "TestDrive:/enum_warning_test.config") | Should -BeTrue
            Should -InvokeVerifiable
        }

        It 'correctly adds the switch keys as bools when true' -TestCases @(
            @{InputValues = $allKeyValuesInput}
        ) {
            $switchKeys = "NoCli", "NoToast"

            $InputValues | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/switch_success_true_test.config"

            $retrieve = Get-Content -Path "TestDrive:/switch_success_true_test.config" | ConvertFrom-Json
            $switchKeys | ForEach-Object {
                ([bool]$retrieve.$_) -is [bool] | Should -BeTrue
            }
        }

        It 'correctly does not add the switch keys when false' -TestCases @(
            @{InputValues = $falseSwitchAllKeyValuesInput}
        ) {
            $switchKeys = "NoToast", "NoCli"

            $InputValues | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/switch_success_false_test.config"

            $retrieve = Get-Content -Path "TestDrive:/switch_success_false_test.config" | ConvertFrom-Json
            $switchKeys | ForEach-Object {
                {$retrieve.$_} | Should -Throw -ExpectedMessage "The property '$_' cannot be found on this object. Verify that the property exists."
            }
        }

        It 'writes a warning if the value for a switch key is the wrong type' -TestCases @(
            @{InputValue = [PsCustomObject]@{NoToast = "wrongType"}},
            @{InputValue = [PsCustomObject]@{NoCli = "wrongType"}}
        ) {
            Mock 'Write-Warning' -ParameterFilter { $Message.Contains(($InputValue | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name))} @Module -Verifiable

            $InputValue | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/switch_warning_test.config"

            $null -eq (Get-Content -Path "TestDrive:/switch_warning_test.config") | Should -BeTrue
            Should -InvokeVerifiable
        }

        It 'does not persist anything to a file if the object is empty' {
            Mock 'ConvertTo-Json' @Module
            Mock 'Set-Content' @Module

            [PsCustomObject]@{} | Set-NetworkAnalyzerConfiguration -Path "TestDrive:/Fake_Config.config"

            Should -Invoke 'ConvertTo-Json' -Exactly -Times 0 @Module
            Should -Invoke 'Set-Content' -Exactly -Times  0 @Module
        }
    }
}