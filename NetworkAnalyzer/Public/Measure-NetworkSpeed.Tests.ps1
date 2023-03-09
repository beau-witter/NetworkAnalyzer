BeforeAll {
    Import-Module 'NetworkAnalyzer'

    $module = @{
        ModuleName = 'NetworkAnalyzer'
    }
}

Describe 'Measure-NetworkSpeed' {
    BeforeAll {
        Mock 'New-Item' @module
        Mock 'Write-Host' @module
        Mock 'Start-Process' -ParameterFilter {$FilePath -like "*ndt7-client.exe"} @module -Verifiable
        Mock 'Write-Verbose' @module
        Mock 'Get-Content' @module -MockWith { "{'some': 'validjson'}"}
        Mock 'Select-String' @module -MockWith {$InputObject}
        Mock 'ConvertFrom-JSON' @module -MockWith {$InputObject}
        Mock 'Remove-Item' @module
    }

    It 'executes the speedtest and returns results' {
        $results = Measure-NetworkSpeed
        Should -InvokeVerifiable
        $results | Should -Not -BeNullOrEmpty
    }
}