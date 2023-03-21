BeforeAll {
    Import-Module 'NetworkAnalyzer'
}

Describe 'Test-IsElevated' {
    It 'returns <Expected> when the process <It> elevated' -TestCases @(
        @{ ProcessValue = $true; It = 'is not'; Expected = $false},
        @{ ProcessValue = $false; It = 'is'; Expected = $true}
    ) {
        InModuleScope 'NetworkAnalyzer' -Parameters $_ {
            Mock 'Get-Process' -ModuleName 'NetworkAnalyzer' { @{Path = $ProcessValue; Handle = $ProcessValue} }
            Test-IsElevated | Should -Be $Expected
        }
    }
}