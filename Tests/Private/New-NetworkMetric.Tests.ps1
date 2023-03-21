BeforeAll {
    Import-Module NetworkAnalyzer
}

Describe 'New-NetworkMetric' {
    It 'only takes in properly formatted objects' {
        InModuleScope NetworkAnalyzer {
            { New-NetworkMetric -Metric [PSCustomObject]@{value = 123; Incorrect = "wrong"} } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'Metric'. The property 'value' cannot be found on this object. Verify that the property exists."
        }
    }

    It 'returns an object with Value <Expected.Value> and Unit <Expected.Unit> when given an object with value <Metric.value> and unit <Metric.unit>' -TestCases @(
        @{Metric = [PSCustomObject]@{value = 99; unit = "%"}; Expected = [PSCustomObject][Ordered]@{Value = 99; Unit = "%"}}
    ) {
        InModuleScope NetworkAnalyzer -Parameters $_ {
            New-NetworkMetric -Metric $Metric | Should -BeLikeExactly $Expected
        }
    }
}