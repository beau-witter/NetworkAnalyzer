BeforeAll {
    Import-Module 'NetworkAnalyzer'
}

Describe 'Get-RandomGuid' {
    Context "Accepting input data" {
        BeforeAll {
            #region Arrange
            $inputData = 10
            #endregion
        }

        #region Act&Assert
        It "should accept input from the parameter" {
            $guids = Get-RandomGuid -Number $inputData
            $guids | Should -HaveCount $inputData
        }

        It "should accept input from the pipeline" {
            $guids = $inputData | Get-RandomGuid
            $guids | Should -HaveCount $inputData
        }
        #endregion
    }
}