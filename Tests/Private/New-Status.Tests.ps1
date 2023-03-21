BeforeAll {
    Import-Module 'NetworkAnalyzer'
}

Describe 'New-Status' {
    It 'takes <Outcome> and returns an object with StatusUnicode <ExpectedUnicode> and StatusImage <ExpectedImagePath> Properties' -TestCases @(
        @{Outcome = "Great"; ExpectedUnicode = "✅"; ExpectedImagePath = "./images/check.png"},
        @{Outcome = "Fair"; ExpectedUnicode = "⚠️"; ExpectedImagePath = "./images/warning.png"},
        @{Outcome = "Poor"; ExpectedUnicode = "❌"; ExpectedImagePath = "./images/error.png"}
    ){
        InModuleScope NetworkAnalyzer -Parameters $_ {
            $status = New-Status -StatusOutcome $Outcome 
            $status.StatusUnicode | Should -BeExactly $ExpectedUnicode
            $status.StatusImage | Should -BeExactly $ExpectedImagePath
        }
    }
}
