@{
    # Build dependencies
    Pester              = @{ target = 'CurrentUser'; version = 'latest' }
    PSScriptAnalyzer    = @{ target = 'CurrentUser'; version = 'latest' }
    PlatyPS             = @{ target = 'CurrentUser'; version = 'latest' }
    BurntToast          = @{ target = 'CurrentUser'; version = 'latest' }
    PowerShellGet       = @{ target = 'CurrentUser'; version = 'latest'; Parameters = @{ AllowPrerelease = $true } }
}
