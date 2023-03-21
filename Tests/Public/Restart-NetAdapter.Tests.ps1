BeforeAll {
    Import-Module 'NetworkAnalyzer'

    $module = @{
        ModuleName = 'NetworkAnalyzer'
    }
}

Describe 'Restart-NetAdapter' {
    BeforeAll {
        Mock 'Disable-NetAdapter' @module -Verifiable
        Mock 'Enable-NetAdapter' @module -Verifiable

    }
    It 'writes to the error stream when not elevated' {
        Mock 'Test-IsElevated' {$false} @module -Verifiable
        Mock 'Write-Error' @module -Verifiable

        Restart-NetAdapter
        Should -InvokeVerifiable
    }

    It 'restarts the found NetAdapter when none is given' {
        Mock 'Test-IsElevated' {$true} @module -Verifiable
        Mock 'Write-Error' @module
        Mock 'Get-NetAdapterStatistics' {@{Name = "Fake"}} @module -Verifiable
        
        Restart-NetAdapter
        Should -InvokeVerifiable
        Should -Invoke 'Write-Error' -Times 0 -Exactly @module
    }
}