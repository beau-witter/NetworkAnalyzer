BeforeAll {
    Import-Module 'NetworkAnalyzer'
}

Describe 'Format-MetricResults' {
    Context 'Formatted Mode' {
        It 'returns status unicode <ExpectedStatus.StatusUnicode> and status image <ExpectedStatus.StatusImage> with measurement <Metric.Value>, upper threshold <UpperThreshold>, and lower threshold <LowerThreshold>' -TestCases @(
            @{Metric = @{Value = 90; Unit = "mbps"}; UpperThreshold = 70; LowerThreshold = 40; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode = "✅"; StatusImage = "./images/check.png"}},
            @{Metric = @{Value = 50; Unit = "mbps"}; UpperThreshold = 70; LowerThreshold = 40; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode ="⚠️"; StatusImage = "./images/warning.png"}},
            @{Metric = @{Value = 10; Unit = "mbps"}; UpperThreshold = 70; LowerThreshold = 40; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode ="❌"; StatusImage = "./images/error.png"}},
            @{Metric = @{Value = 70; Unit = "mbps"}; UpperThreshold = 70; LowerThreshold = 40; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode = "✅"; StatusImage = "./images/check.png"}},
            @{Metric = @{Value = 40; Unit = "mbps"}; UpperThreshold = 70; LowerThreshold = 40; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode = "⚠️"; StatusImage = "./images/warning.png"}}
        ) {
            InModuleScope NetworkAnalyzer -Parameters $_ {
                $result = Format-MetricResults -RawMetricResults $Metric -UpperThreshold $UpperThreshold -LowerThreshold $LowerThreshold
                $result.Status | Should -BeLikeExactly $ExpectedStatus
            }
        }
    
        It 'returns status unicode <ExpectedStatus.StatusUnicode> and status image <ExpectedStatus.StatusImage> with measurement <Metric.Value>, upper threshold <UpperThreshold>, lower threshold <LowerThreshold>, and the Inverse switch' -TestCases @(
            @{Metric = @{Value = 2; Unit = "%"}; UpperThreshold = 8; LowerThreshold = 4; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode = "✅"; StatusImage = "./images/check.png"}},
            @{Metric = @{Value = 5; Unit = "%"}; UpperThreshold = 8; LowerThreshold = 4; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode ="⚠️"; StatusImage = "./images/warning.png"}},
            @{Metric = @{Value = 9; Unit = "%"}; UpperThreshold = 8; LowerThreshold = 4; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode ="❌"; StatusImage = "./images/error.png"}},
            @{Metric = @{Value = 4; Unit = "%"}; UpperThreshold = 8; LowerThreshold = 4; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode = "✅"; StatusImage = "./images/check.png"}},
            @{Metric = @{Value = 8; Unit = "%"}; UpperThreshold = 8; LowerThreshold = 4; ExpectedStatus = [PSCustomObject][Ordered]@{StatusUnicode = "⚠️"; StatusImage = "./images/warning.png"}}
        ) {
            InModuleScope NetworkAnalyzer -Parameters $_ {
                $result = Format-MetricResults -RawMetricResults $Metric -UpperThreshold $UpperThreshold -LowerThreshold $LowerThreshold -Inverse
                $result.Status | Should -BeLikeExactly $ExpectedStatus
            }
        }
    
        It 'returns result <ExpectedResult.Value>, unit <ExpectedResult.Unit>, and text <ExpectedResult.Text> with measurement <Metric.Value> and unit <Metric.Unit>' -TestCases @(
            @{Metric = @{Value = 45.678; Unit = "mbps"}; ExpectedResult = [PSCustomObject][Ordered]@{Value = 45.678; Unit = "mbps"; Text = "45.68 mbps"}},
            @{Metric = @{Value = 45.500; Unit = "mbps"}; ExpectedResult = [PSCustomObject][Ordered]@{Value = 45.500; Unit = "mbps"; Text = "45.5 mbps"}},
            @{Metric = @{Value = 45.994; Unit = "mbps"}; ExpectedResult = [PSCustomObject][Ordered]@{Value = 45.994; Unit = "mbps"; Text = "45.99 mbps"}}
        ) {
            InModuleScope NetworkAnalyzer -Parameters $_ {
                $result = Format-MetricResults -RawMetricResults $Metric -UpperThreshold 100 -LowerThreshold 10
                $result.Result | Should -BeLikeExactly $ExpectedResult
            }
        }
    }

    Context 'Basic Mode' {
        It 'returns only the plain results in Basic Mode' {
            InModuleScope NetworkAnalyzer {
                $rawMetricResults = @{Value = 76.665; Unit = "mbps"}
                $expectedMetricResults = [PsCustomObject][Ordered]@{Value = 76.665; Unit = "mbps"; Text = "76.67 mbps"}

                $result = Format-MetricResults -RawMetricResults $rawMetricResults -Basic
                $result.Result | Should -BeLikeExactly $expectedMetricResults
            }
        }
    }
}