BeforeAll {
    Import-Module 'NetworkAnalyzer'

    $Module = @{
        ModuleName = 'NetworkAnalyzer'
    }
}

Describe 'Add-NetworkAnalyzerConfigurationValue' {
    Context 'Single ParameterSet' {
        It 'throws an error when a percent value is outside the allowed range' -TestCases @(
            @{Key = "UpperBoundPercent"; Value = -0.01},
            @{Key = "UpperBoundPercent"; Value = 1.01},
            @{Key = "LowerBoundPercent"; Value = -0.01},
            @{Key = "LowerBoundPercent"; Value = 1.01},
            @{Key = "MaximumPacketLoss"; Value = -0.01},
            @{Key = "MaximumPacketLoss"; Value = 1.01},
            @{Key = "UpperPacketLossThreshold"; Value = -0.01},
            @{Key = "UpperPacketLossThreshold"; Value = 1.01},
            @{Key = "LowerPacketLossThreshold"; Value = -0.01},
            @{Key = "LowerPacketLossThreshold"; Value = 1.01}
        ) {
            {Add-NetworkAnalyzerConfigurationValue -SingleKey $Key -SingleValue $Value} | Should -Throw -ExpectedMessage "$Key can only contain values between 0.0 and 1.0 inclusive."
        }

        It 'writes an error if the provided key already exists on the input object without force' -TestCases @(
            @{Key = "MaximumDownload"; Value = 100; InputObject = [PsCustomObject]@{MaximumDownload = 50}},
            @{Key = "MaximumUpload"; Value = 100; InputObject = [PsCustomObject]@{MaximumUpload = 50}},
            @{Key = "MaximumPing"; Value = 100; InputObject = [PsCustomObject]@{MaximumPing = 50}},
            @{Key = "MaximumPacketLoss"; Value = 0.5; InputObject = [PsCustomObject]@{MaximumPacketLoss = 0.3}},
            @{Key = "UpperBoundPercent"; Value = 0.5; InputObject = [PsCustomObject]@{UpperBoundPercent = 0.3}},
            @{Key = "LowerBoundPercent"; Value = 0.5; InputObject = [PsCustomObject]@{LowerBoundPercent = 0.3}},
            @{Key = "UpperDownloadThreshold"; Value = 100; InputObject = [PsCustomObject]@{UpperDownloadThreshold = 50}},
            @{Key = "LowerDownloadThreshold"; Value = 100; InputObject = [PsCustomObject]@{LowerDownloadThreshold = 50}},
            @{Key = "UpperUploadThreshold"; Value = 100; InputObject = [PsCustomObject]@{UpperUploadThreshold = 50}},
            @{Key = "LowerUploadThreshold"; Value = 100; InputObject = [PsCustomObject]@{LowerUploadThreshold = 50}},
            @{Key = "UpperPingThreshold"; Value = 100; InputObject = [PsCustomObject]@{UpperPingThreshold = 50}},
            @{Key = "LowerPingThreshold"; Value = 100; InputObject = [PsCustomObject]@{LowerPingThreshold = 50}},
            @{Key = "UpperPacketLossThreshold"; Value = 0.5; InputObject = [PsCustomObject]@{UpperPacketLossThreshold = 0.3}},
            @{Key = "LowerPacketLossThreshold"; Value = 0.5; InputObject = [PsCustomObject]@{LowerPacketLossThreshold = 0.3}}
        ) {
            Mock 'Write-Error' -ParameterFilter { $Message.Contains($Key) } @Module -Verifiable
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -SingleKey $Key -SingleValue $Value
            $outObject | Should -BeExactly $InputObject
            Should -InvokeVerifiable
        }

        It 'adds the key and value to the object if it does not already exist on the input object' -TestCases @(
            @{Key = "MaximumDownload"; Value = 100; Expected = [PsCustomObject]@{MaximumDownload = 100}},
            @{Key = "MaximumUpload"; Value = 100; Expected = [PsCustomObject]@{MaximumUpload = 100}},
            @{Key = "MaximumPing"; Value = 100; Expected = [PsCustomObject]@{MaximumPing = 100}},
            @{Key = "MaximumPacketLoss"; Value = 0.5; Expected = [PsCustomObject]@{MaximumPacketLoss = 0.5}},
            @{Key = "UpperBoundPercent"; Value = 0.5; Expected = [PsCustomObject]@{UpperBoundPercent = 0.5}},
            @{Key = "LowerBoundPercent"; Value = 0.5; Expected = [PsCustomObject]@{LowerBoundPercent = 0.5}},
            @{Key = "UpperDownloadThreshold"; Value = 100; Expected = [PsCustomObject]@{UpperDownloadThreshold = 100}},
            @{Key = "LowerDownloadThreshold"; Value = 100; Expected = [PsCustomObject]@{LowerDownloadThreshold = 100}},
            @{Key = "UpperUploadThreshold"; Value = 100; Expected = [PsCustomObject]@{UpperUploadThreshold = 100}},
            @{Key = "LowerUploadThreshold"; Value = 100; Expected = [PsCustomObject]@{LowerUploadThreshold = 100}},
            @{Key = "UpperPingThreshold"; Value = 100; Expected = [PsCustomObject]@{UpperPingThreshold = 100}},
            @{Key = "LowerPingThreshold"; Value = 100; Expected = [PsCustomObject]@{LowerPingThreshold = 100}},
            @{Key = "UpperPacketLossThreshold"; Value = 0.5; Expected = [PsCustomObject]@{UpperPacketLossThreshold = 0.5}},
            @{Key = "LowerPacketLossThreshold"; Value = 0.5; Expected = [PsCustomObject]@{LowerPacketLossThreshold = 0.5}}
        ) {
            $outObject = Add-NetworkAnalyzerConfigurationValue -SingleKey $Key -SingleValue $Value
            $outObject | Should -BeLikeExactly $Expected
        }

        It 'adds the key and value to the object if it already exists on the input object with the -force switch' -TestCases @(
            @{Key = "MaximumDownload"; Value = 100; InputObject = [PsCustomObject]@{MaximumDownload = 50}; Expected = [PsCustomObject]@{MaximumDownload = 100}},
            @{Key = "MaximumUpload"; Value = 100; InputObject = [PsCustomObject]@{MaximumUpload = 50}; Expected = [PsCustomObject]@{MaximumUpload = 100}},
            @{Key = "MaximumPing"; Value = 100; InputObject = [PsCustomObject]@{MaximumPing = 50}; Expected = [PsCustomObject]@{MaximumPing = 100}},
            @{Key = "MaximumPacketLoss"; Value = 0.5; InputObject = [PsCustomObject]@{MaximumPacketLoss = 0.3}; Expected = [PsCustomObject]@{MaximumPacketLoss = 0.5}},
            @{Key = "UpperBoundPercent"; Value = 0.5; InputObject = [PsCustomObject]@{UpperBoundPercent = 0.3}; Expected = [PsCustomObject]@{UpperBoundPercent = 0.5}},
            @{Key = "LowerBoundPercent"; Value = 0.5; InputObject = [PsCustomObject]@{LowerBoundPercent = 0.3}; Expected = [PsCustomObject]@{LowerBoundPercent = 0.5}},
            @{Key = "UpperDownloadThreshold"; Value = 100; InputObject = [PsCustomObject]@{UpperDownloadThreshold = 50}; Expected = [PsCustomObject]@{UpperDownloadThreshold = 100}},
            @{Key = "LowerDownloadThreshold"; Value = 100; InputObject = [PsCustomObject]@{LowerDownloadThreshold = 50}; Expected = [PsCustomObject]@{LowerDownloadThreshold = 100}},
            @{Key = "UpperUploadThreshold"; Value = 100; InputObject = [PsCustomObject]@{UpperUploadThreshold = 50}; Expected = [PsCustomObject]@{UpperUploadThreshold = 100}},
            @{Key = "LowerUploadThreshold"; Value = 100; InputObject = [PsCustomObject]@{LowerUploadThreshold = 50}; Expected = [PsCustomObject]@{LowerUploadThreshold = 100}},
            @{Key = "UpperPingThreshold"; Value = 100; InputObject = [PsCustomObject]@{UpperPingThreshold = 50}; Expected = [PsCustomObject]@{UpperPingThreshold = 100}},
            @{Key = "LowerPingThreshold"; Value = 100; InputObject = [PsCustomObject]@{LowerPingThreshold = 50}; Expected = [PsCustomObject]@{LowerPingThreshold = 100}},
            @{Key = "UpperPacketLossThreshold"; Value = 0.5; InputObject = [PsCustomObject]@{UpperPacketLossThreshold = 0.3}; Expected = [PsCustomObject]@{UpperPacketLossThreshold = 0.5}},
            @{Key = "LowerPacketLossThreshold"; Value = 0.5; InputObject = [PsCustomObject]@{LowerPacketLossThreshold = 0.3}; Expected = [PsCustomObject]@{LowerPacketLossThreshold = 0.5}}
        ) {
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -SingleKey $Key -SingleValue $Value -Force
            $outObject | Should -BeLikeExactly $Expected
        }
    }

    Context 'String ParameterSet' {
        It 'writes an error if the provided key already exists on the input object without force' -TestCases @(
            @{Key = "ConfigFilePath"; Value = "C:\Some\File\Path"; InputObject = [PsCustomObject]@{ConfigFilePath = "D:\Some\Other\Path"}}
        ) {
            Mock 'Write-Error' -ParameterFilter { $Message.Contains($Key) } @Module -Verifiable
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -StringKey $Key -StringValue $Value
            $outObject | Should -BeExactly $InputObject
            Should -InvokeVerifiable
        }

        It 'adds the key and value to the object if it does not already exist on the input object' -TestCases @(
            @{Key = "ConfigFilePath"; Value = "C:\Some\File\Path"; Expected = [PsCustomObject]@{ConfigFilePath = "C:\Some\File\Path"}}
        ) {
            $outObject = Add-NetworkAnalyzerConfigurationValue -StringKey $Key -StringValue $Value
            $outObject | Should -BeLikeExactly $Expected
        }

        It 'adds the key and value to the object if it already exists on the input object with the -force switch' -TestCases @(
            @{Key = "ConfigFilePath"; Value = "C:\Some\File\Path"; InputObject = [PsCustomObject]@{ConfigFilePath = "D:\Some\Other\Path"}; Expected = [PsCustomObject]@{ConfigFilePath = "C:\Some\File\Path"}}
        ) {
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -StringKey $Key -StringValue $Value -Force
            $outObject | Should -BeLikeExactly $Expected
        }
    }

    Context 'Enum ParameterSet' {
        It 'writes an error if the provided key already exists on the input object without force' -TestCases @(
            @{Key = "Mode"; Value = "PercentThreshold"; InputObject = [PsCustomObject]@{Mode = "AbsoluteThreshold"}}
        ) {
            Mock 'Write-Error' -ParameterFilter { $Message.Contains($Key) } @Module -Verifiable
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -EnumKey $Key -EnumValue $Value
            $outObject | Should -BeExactly $InputObject
            Should -InvokeVerifiable
        }

        It 'adds the key and value to the object if it does not already exist on the input object' -TestCases @(
            @{Key = "Mode"; Value = "PercentThreshold"; Expected = [PsCustomObject]@{Mode = "PercentThreshold"}}
        ) {
            $outObject = Add-NetworkAnalyzerConfigurationValue -EnumKey $Key -EnumValue $Value
            $outObject | Should -BeLikeExactly $Expected
        }

        It 'adds the key and value to the object if it already exists on the input object with the -force switch' -TestCases @(
            @{Key = "Mode"; Value = "PercentThreshold"; InputObject = [PsCustomObject]@{Mode = "AbsoluteThreshold"}; Expected = [PsCustomObject]@{Mode = "PercentThreshold"}}
        ) {
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -EnumKey $Key -EnumValue $Value -Force
            $outObject | Should -BeLikeExactly $Expected
        }
    }

    Context 'Switch ParameterSet' {
        It 'writes an error if the provided key already exists on the input object without force' -TestCases @(
            @{Key = "NoToast"; Value = $false; InputObject = [PsCustomObject]@{NoToast = $true}},
            @{Key = "NoCli"; Value = $true; InputObject = [PsCustomObject]@{NoCli = $false}}
        ) {
            Mock 'Write-Error' -ParameterFilter { $Message.Contains($Key) } @Module -Verifiable
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -SwitchKey $Key -SwitchValue $Value
            $outObject | Should -BeExactly $InputObject
            Should -InvokeVerifiable
        }

        It 'adds the key and value to the object if it does not already exist on the input object' -TestCases @(
            @{Key = "NoToast"; Value = $false; Expected = [PsCustomObject]@{NoToast = $false}},
            @{Key = "NoCli"; Value = $true; Expected = [PsCustomObject]@{NoCli = $true}}
        )  {
            $outObject = Add-NetworkAnalyzerConfigurationValue -SwitchKey $Key -SwitchValue $Value
            $outObject | Should -BeLikeExactly $Expected
        }

        It 'adds the key and value to the object if it already exists on the input object with the -force switch' -TestCases @(
            @{Key = "NoToast"; Value = $false; InputObject = [PsCustomObject]@{NoToast = $true}; Expected = [PsCustomObject]@{NoToast = $false}},
            @{Key = "NoCli"; Value = $true; InputObject = [PsCustomObject]@{NoCli = $false}; Expected = [PsCustomObject]@{NoCli = $true}}
        ) {
            $outObject = $InputObject | Add-NetworkAnalyzerConfigurationValue -SwitchKey $Key -SwitchValue $Value -Force
            $outObject | Should -BeLikeExactly $Expected
        }
    }
}