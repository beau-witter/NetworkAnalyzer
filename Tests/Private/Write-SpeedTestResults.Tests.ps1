BeforeAll {
    Import-Module 'NetworkAnalyzer'

    $Module = @{
        ModuleName = 'NetworkAnalyzer'
    }
}

Describe 'Write-SpeedTestResults' {
    BeforeAll {
        Mock "Write-Host" {$Object} @Module
    }

    Context 'CLI Output' {
        It 'returns preformatted output for Basic Mode results' -TestCases @(
            @{Results = @{Download = @{Result = @{Text = "100 mbps"}}; Upload = @{Result = @{Text = "5 mbps"}}; Ping = @{Result = @{Text = "16 ms"}}; PacketLoss = @{Result = @{Text = "0 %"}}}},
            @{Results = @{Download = @{Result = @{Text = "10 mbps"}}; Upload = @{Result = @{Text = "1 gbps"}}; Ping = @{Result = @{Text = "4.4 ms"}}; PacketLoss = @{Result = @{Text = "4 %"}}}}
        ){
            Mock "New-BurntToastNotification" @Module
            InModuleScope NetworkAnalyzer -Parameters $_ {
                $outResult = Write-SpeedTestResults -SpeedTestResults $Results -Basic
                $outResult | Should -Match "Speed Test Results"
                $outResult | Should -Match "Metric"
                $outResult | Should -Match "Measurement"
                $outResult | Should -Not -Match "Status"
                $outResult | Should -Match "Download"
                $outResult | Should -Match $Results.Download.Result.Text
                $outResult | Should -Match "Upload"
                $outResult | Should -Match $Results.Upload.Result.Text
                $outResult | Should -Match "Ping"
                $outResult | Should -Match $Results.Ping.Result.Text
                $outResult | Should -Match "Packet Loss"
                $outResult | Should -Match $Results.PacketLoss.Result.Text
            }
        }

        It 'returns preformatted output for Formatted Mode results' -TestCases @(
            @{Results = @{Download = @{Result = @{Text = "100 mbps"}; Status = @{StatusUnicode = "A"; StatusImage = ""}}; Upload = @{Result = @{Text = "5 mbps"}; Status = @{StatusUnicode = "S"; StatusImage = ""}}; Ping = @{Result = @{Text = "16 ms"}; Status = @{StatusUnicode = "D"; StatusImage = ""}}; PacketLoss = @{Result = @{Text = "0 %"}; Status = @{StatusUnicode = "F"; StatusImage = ""}}}},
            @{Results = @{Download = @{Result = @{Text = "10 mbps"}; Status = @{StatusUnicode = "Q"; StatusImage = ""}}; Upload = @{Result = @{Text = "1 gbps"}; Status = @{StatusUnicode = "W"; StatusImage = ""}}; Ping = @{Result = @{Text = "4.4 ms"}; Status = @{StatusUnicode = "E"; StatusImage = ""}}; PacketLoss = @{Result = @{Text = "4 %"}; Status = @{StatusUnicode = "R"; StatusImage = ""}}}}
        ) {
            Mock "New-BurntToastNotification" @Module
            InModuleScope NetworkAnalyzer -Parameters $_ {
                $outResult = Write-SpeedTestResults -SpeedTestResults $Results
                $outResult | Should -Match "Speed Test Results"
                $outResult | Should -Match "Metric"
                $outResult | Should -Match "Measurement"
                $outResult | Should -Match "Status"
                $outResult | Should -Match "Download"
                $outResult | Should -Match $Results.Download.Result.Text
                $outResult | Should -Match $Results.Download.Status.StatusUnicode
                $outResult | Should -Match "Upload"
                $outResult | Should -Match $Results.Upload.Result.Text
                $outResult | Should -Match $Results.Upload.Status.StatusUnicode
                $outResult | Should -Match "Ping"
                $outResult | Should -Match $Results.Ping.Result.Text
                $outResult | Should -Match $Results.Ping.Status.StatusUnicode
                $outResult | Should -Match "Packet Loss"
                $outResult | Should -Match $Results.PacketLoss.Result.Text
                $outResult | Should -Match $Results.packetLoss.Status.StatusUnicode
            }
        }
    }

    Context 'Toast Output' {
        It 'displays a notification for each result for Basic Mode results' -TestCases @(
            @{Results = @{Download = @{Result = @{Text = "100 mbps"}}; Upload = @{Result = @{Text = "5 mbps"}}; Ping = @{Result = @{Text = "16 ms"}}; PacketLoss = @{Result = @{Text = "0 %"}}}},
            @{Results = @{Download = @{Result = @{Text = "10 mbps"}}; Upload = @{Result = @{Text = "1 gbps"}}; Ping = @{Result = @{Text = "4.4 ms"}}; PacketLoss = @{Result = @{Text = "4 %"}}}}
        ) {
            Mock "Write-Host" @Module

            #Download
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "download" -and
                $Text -like "*$($Results.Download.Result.Text)*" -and
                $AppLogo -eq "None"
            } @Module -Verifiable
            
            #Upload
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "upload" -and
                $Text -like "*$($Results.Upload.Result.Text)*" -and
                $AppLogo -eq "None"
            } @Module -Verifiable

            #Ping
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "ping" -and
                $Text -like "*$($Results.Ping.Result.Text)*" -and
                $AppLogo -eq "None"
            } @Module -Verifiable

            #Packet Loss
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "packetloss" -and
                $Text -like "*$($Results.PacketLoss.Result.Text)*" -and
                $AppLogo -eq "None"
            } @Module -Verifiable

            InModuleScope NetworkAnalyzer -Parameters $_ {
                Write-SpeedTestResults -SpeedTestResults $Results -Basic
                Should -InvokeVerifiable
            }
        }

        It 'displays a notification for each result for Formatted Mode results' -TestCases @(
            @{Results = @{Download = @{Result = @{Text = "100 mbps"}; Status = @{StatusUnicode = "A"; StatusImage = "./images/check.png"}}; Upload = @{Result = @{Text = "5 mbps"}; Status = @{StatusUnicode = "S"; StatusImage = "./images/error.png"}}; Ping = @{Result = @{Text = "16 ms"}; Status = @{StatusUnicode = "D"; StatusImage = "./images/warning.png"}}; PacketLoss = @{Result = @{Text = "0 %"}; Status = @{StatusUnicode = "F"; StatusImage = "./images/check.png"}}}},
            @{Results = @{Download = @{Result = @{Text = "10 mbps"}; Status = @{StatusUnicode = "Q"; StatusImage = "./images/check.png"}}; Upload = @{Result = @{Text = "1 gbps"}; Status = @{StatusUnicode = "W"; StatusImage = "./images/error.png"}}; Ping = @{Result = @{Text = "4.4 ms"}; Status = @{StatusUnicode = "E"; StatusImage = "./images/warning.png"}}; PacketLoss = @{Result = @{Text = "4 %"}; Status = @{StatusUnicode = "R"; StatusImage = "./images/check.png"}}}}
        ) {
            Mock "Write-Host" @Module

            #Download
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "download" -and
                $Text -like "*$($Results.Download.Result.Text)*" -and
                $AppLogo -eq $Results.Download.Status.StatusImage
            } @Module -Verifiable
            
            #Upload
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "upload" -and
                $Text -like "*$($Results.Upload.Result.Text)*" -and
                $AppLogo -eq $Results.Upload.Status.StatusImage
            } @Module -Verifiable

            #Ping
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "ping" -and
                $Text -like "*$($Results.Ping.Result.Text)*" -and
                $AppLogo -eq $Results.Ping.Status.StatusImage
            } @Module -Verifiable

            #Packet Loss
            Mock "New-BurntToastNotification" -ParameterFilter {
                $UniqueIdentifier -eq "packetloss" -and
                $Text -like "*$($Results.PacketLoss.Result.Text)*" -and
                $AppLogo -eq $Results.PacketLoss.Status.StatusImage
            } @Module -Verifiable

            InModuleScope NetworkAnalyzer -Parameters $_ {
                Write-SpeedTestResults -SpeedTestResults $Results
                Should -InvokeVerifiable
            }
        }
    }

    Context 'PassThru' {
        It 'returns the result object directly to the output stream' -TestCases @(
            @{Results = @{Download = @{Result = @{Text = "100 mbps"}; Status = @{StatusUnicode = "A"; StatusImage = "./images/check.png"}}; Upload = @{Result = @{Text = "5 mbps"}; Status = @{StatusUnicode = "S"; StatusImage = "./images/error.png"}}; Ping = @{Result = @{Text = "16 ms"}; Status = @{StatusUnicode = "D"; StatusImage = "./images/warning.png"}}; PacketLoss = @{Result = @{Text = "0 %"}; Status = @{StatusUnicode = "F"; StatusImage = "./images/check.png"}}}},
            @{Results = @{Download = @{Result = @{Text = "10 mbps"}; Status = @{StatusUnicode = "Q"; StatusImage = "./images/check.png"}}; Upload = @{Result = @{Text = "1 gbps"}; Status = @{StatusUnicode = "W"; StatusImage = "./images/error.png"}}; Ping = @{Result = @{Text = "4.4 ms"}; Status = @{StatusUnicode = "E"; StatusImage = "./images/warning.png"}}; PacketLoss = @{Result = @{Text = "4 %"}; Status = @{StatusUnicode = "R"; StatusImage = "./images/check.png"}}}},
            @{Results = @{Download = @{Result = @{Text = "100 mbps"}; Status = @{StatusUnicode = "A"; StatusImage = ""}}; Upload = @{Result = @{Text = "5 mbps"}; Status = @{StatusUnicode = "S"; StatusImage = ""}}; Ping = @{Result = @{Text = "16 ms"}; Status = @{StatusUnicode = "D"; StatusImage = ""}}; PacketLoss = @{Result = @{Text = "0 %"}; Status = @{StatusUnicode = "F"; StatusImage = ""}}}},
            @{Results = @{Download = @{Result = @{Text = "10 mbps"}; Status = @{StatusUnicode = "Q"; StatusImage = ""}}; Upload = @{Result = @{Text = "1 gbps"}; Status = @{StatusUnicode = "W"; StatusImage = ""}}; Ping = @{Result = @{Text = "4.4 ms"}; Status = @{StatusUnicode = "E"; StatusImage = ""}}; PacketLoss = @{Result = @{Text = "4 %"}; Status = @{StatusUnicode = "R"; StatusImage = ""}}}}
        ) {
            InModuleScope NetworkAnalyzer -Parameters $_ {
                $outResult = Write-SpeedTestResults -SpeedTestResults $Results -NoCli -NoToast -PassThru
                $outResult | Should -BeExactly $Results
            }
        }
    }
}