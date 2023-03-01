#requires -modules InvokeBuild

<#
.SYNOPSIS
    Build script (https://github.com/nightroman/Invoke-Build)

.DESCRIPTION
    This script contains the tasks for building the 'NetworkAnalyzer' PowerShell module
#>

Param (
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ValidateSet('Debug', 'Release')]
    [String]
    $Configuration = 'Debug',
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $SourceLocation,
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $Credential
)

Set-StrictMode -Version Latest

# Synopsis: Default task
task . Clean, Build


# Install build dependencies
Enter-Build {

    # Installing PSDepend for dependency management
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Install-Module PSDepend -Force
    }
    Import-Module PSDepend

    # Installing dependencies
    Invoke-PSDepend -Force

    # Setting build script variables
    $script:moduleName = 'NetworkAnalyzer'
    $script:moduleSourcePath = Join-Path -Path $BuildRoot -ChildPath $moduleName
    $script:moduleManifestPath = Join-Path -Path $moduleSourcePath -ChildPath "$moduleName.psd1"
    $script:buildOutputPath = Join-Path -Path $BuildRoot -ChildPath 'build'

    # Setting base module version and using it if building locally
    $script:newModuleVersion = (Import-PowerShellDataFile $moduleManifestPath).ModuleVersion

    # Setting the list of functions ot be exported by module
    $script:functionsToExport = (Test-ModuleManifest $moduleManifestPath).ExportedFunctions
}

# Synopsis: Analyze the project with PSScriptAnalyzer
task Analyze {
    # Get-ChildItem parameters
    $testFiles = Get-ChildItem -Path $moduleSourcePath -Recurse -Include "*.PSSATests.*"

    $config = New-PesterConfiguration @{
        Run = @{
            Path = $testFiles
            Exit = $true
        }
        TestResult = @{
            Enabled = $true
        }
    }

    # Additional parameters on GitHub Actions runners to generate test results
    if ($env:GITHUB_WORKSPACE) {
        if (-not (Test-Path -Path $buildOutputPath -ErrorAction SilentlyContinue)) {
            New-Item -Path $buildOutputPath -ItemType Directory
        }
        $timestamp = Get-date -UFormat "%Y%m%d-%H%M%S"
        $PSVersion = $PSVersionTable.PSVersion.Major
        $testResultFile = "AnalysisResults_PS$PSVersion`_$timeStamp.xml"
        $config.TestResult.OutputPath = "$buildOutputPath\$testResultFile"
    }

    # Invoke all tests
    Invoke-Pester -Configuration $config
}

# Synopsis: Test the project with Pester tests
task Test {
    # Get-ChildItem parameters
    $testFiles = Get-ChildItem -Path $moduleSourcePath -Recurse -Include "*.Tests.*"

    # Pester parameters
    $config = New-PesterConfiguration @{
        Run = @{
            Path = $testFiles
            Exit = $true
        }
        TestResult = @{
            Enabled = $true
        }
    }

    # Additional parameters on GitHub Actions runners to generate test results
    if ($env:GITHUB_WORKSPACE) {
        if (-not (Test-Path -Path $buildOutputPath -ErrorAction SilentlyContinue)) {
            New-Item -Path $buildOutputPath -ItemType Directory
        }
        $timestamp = Get-date -UFormat "%Y%m%d-%H%M%S"
        $PSVersion = $PSVersionTable.PSVersion.Major
        $testResultFile = "TestResults_PS$PSVersion`_$timeStamp.xml"
        $Config.TestResult.OutputPath = "$buildOutputPath\$testResultFile"
    }

    # Invoke all tests
    Invoke-Pester -Configuration $config
}

# Synopsis: Generate a new module version if creating a release build
task GenerateNewModuleVersion -If ($Configuration -eq 'Release') {
    # Using the current NuGet package version from the feed as a version base when building via GitHub Actions Workflow

    # Define package repository name
    $repositoryName = $moduleName + '-repository'

    # Register a target PSRepository
    Register-PSResourceRepository -Name $repositoryName -URI $SourceLocation -Trusted

    # Define variable for existing package
    $existingPackage = $null

    try {
        # Look for the module package in the repository
        $existingPackage = Find-PSResource -Name $moduleName -Repository $repositoryName -Credential $Credential
    }
    # In no existing module package was found, the base module version defined in the script will be used
    catch {
        Write-Warning "No existing package for '$moduleName' module was found in '$repositoryName' repository!"
    }

    # If existing module package was found, try to install the module
    if ($existingPackage) {
        # Get the largest module version
        $currentModuleVersion = New-Object -TypeName 'System.Version' -ArgumentList ($existingPackage.Version)

        # Set module version base numbers
        [int]$Major = $currentModuleVersion.Major
        [int]$Minor = $currentModuleVersion.Minor
        [int]$Build = $currentModuleVersion.Build

        # Install the existing module from the repository
        Install-PSResource -Name $moduleName.ToLower() -Repository $repositoryName -Version $existingPackage.Version.ToString() -Credential $Credential

        # Get the count of exported module functions
        $existingFunctionsCount = (Get-Command -Module $moduleName | Where-Object -Property Version -EQ $existingPackage.Version | Measure-Object).Count
        # Check if new public functions were added in the current build
        [int]$sourceFunctionsCount = (Get-ChildItem -Path "$moduleSourcePath\Public\*.ps1" -Exclude "*.Tests.*" | Measure-Object).Count
        [int]$newFunctionsCount = [System.Math]::Abs($sourceFunctionsCount - $existingFunctionsCount)

        # Increase the minor number if any new public functions have been added
        if ($newFunctionsCount -gt 0) {
            [int]$Minor = $Minor + 1
            [int]$Build = 0
        }
        # If not, just increase the build number
        else {
            [int]$Build = $Build + 1
        }

        # Update the module version object
        $Script:newModuleVersion = New-Object -TypeName 'System.Version' -ArgumentList ($Major, $Minor, $Build)
    }
}

# Synopsis: Generate list of functions to be exported by module
task GenerateListOfFunctionsToExport {
    # Set exported functions by finding functions exported by *.psm1 file via Export-ModuleMember
    $params = @{
        Force    = $true
        Passthru = $true
        Name     = (Resolve-Path (Get-ChildItem -Path $moduleSourcePath -Filter '*.psm1')).Path
    }
    $PowerShell = [Powershell]::Create()
    [void]$PowerShell.AddScript(
        {
            Param ($Force, $Passthru, $Name)
            $module = Import-Module -Name $Name -PassThru:$Passthru -Force:$Force
            $module | Where-Object { $_.Path -notin $module.Scripts }
        }
    ).AddParameters($Params)
    $module = $PowerShell.Invoke()
    $Script:functionsToExport = $module.ExportedFunctions.Keys
}

# Synopsis: Update the module manifest with module version and functions to export
task UpdateModuleManifest GenerateNewModuleVersion, GenerateListOfFunctionsToExport, {
    # Update-ModuleManifest parameters
    $Params = @{
        Path              = $moduleManifestPath
        ModuleVersion     = $newModuleVersion
        FunctionsToExport = $functionsToExport
    }

    # Update the manifest file
    Update-ModuleManifest @Params
}

# Synopsis: Build the project
task Build UpdateModuleManifest, {
    # Warning on local builds
    if ($Configuration -eq 'Debug') {
        Write-Warning "Creating a debug build. Use it for test purpose only!"
    }

    # Create versioned output folder
    $moduleOutputPath = Join-Path -Path $buildOutputPath -ChildPath $moduleName -AdditionalChildPath $newModuleVersion
    if (-not (Test-Path $moduleOutputPath)) {
        New-Item -Path $moduleOutputPath -ItemType Directory
    }

    # Copy-Item parameters
    $Params = @{
        Path        = "$moduleSourcePath\*"
        Destination = $moduleOutputPath
        Exclude     = "*.Tests.*", "*.PSSATests.*"
        Recurse     = $true
        Force       = $true
    }

    # Copy module files to the target build folder
    Copy-Item @Params
}

# Synopsis: Verify the code coverage by tests
task CodeCoverage {
    $files = Get-ChildItem $moduleSourcePath -Dir -Force -Recurse |
                Where-Object {$_.FullName -notLike '*build*' -and $_.FullName -notLike '*.git*'} |
                Get-ChildItem -File -Force -Include '*.ps1' -Exclude '*.Tests.ps1' |
                Select-Object -ExpandProperty FullName

    $config = New-PesterConfiguration @{
        Run = @{
            Path     = $moduleSourcePath
            PassThru = $true
        }
        Output = @{
            Verbosity = 'Normal'
        }
        CodeCoverage = @{
            Enabled               = $true
            Path                  = $files
            CoveragePercentTarget = 60
        }
    }

    # Additional parameters on GitHub Actions runners to generate code coverage report
    if ($env:GITHUB_WORKSPACE) {
        if (-not (Test-Path -Path $buildOutputPath -ErrorAction SilentlyContinue)) {
            New-Item -Path $buildOutputPath -ItemType Directory
        }
        $timestamp = Get-date -UFormat "%Y%m%d-%H%M%S"
        $PSVersion = $PSVersionTable.PSVersion.Major
        $testResultFile = "CodeCoverageResults_PS$PSVersion`_$timeStamp.xml"
        $config.CodeCoverage.OutputPath = "$buildOutputPath\$testResultFile"
    }

    $result = Invoke-Pester -Configuration $config

    # Fail the task if the code coverage results are not acceptable
    if ( $result.CodeCoverage.CoveragePercent -lt $result.CodeCoverage.CoveragePercentTarget) {
        throw "The overall code coverage by Pester tests is $("0:0.##" -f $result.CodeCoverage.CoveragePercent)% `
                which is less than quality gate of $($result.CodeCoverage.CoveragePercentTarget)%. `
                Pester ModuleVersion is: $((Get-Module -Name Pester -ListAvailable).ModuleVersion)."
    }
}

# Synopsis: Clean up the target build directory
task Clean {
    if (Test-Path $buildOutputPath) {
        Remove-Item -Path $buildOutputPath -Recurse
    }
}
