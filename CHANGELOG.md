# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Private functions
- Test-IsElevated - Allows for better explanation for certain actions' availability.
- Format-MetricResults - Shapes the output to be consistent.
- New-NetworkMetric - Creates and returns a well defined object from the speed test results for later use.
- New-Status - Creates and returns a well defined object from a determined "outcome" of the speed test for later use.
- Write-SpeedTestResults - Outputs the SpeedTestResults based on configuration.

#### Public functions
- Restart-NetAdapter - Now we can restart a net adapter as a network-fixing step.
- Set-NetworkAnalyzerConfigurationValue - Persists the configuration for Start-SpeedTest into a file.

#### Other
- Generate-Ndt7-ClientExecutable - Creates the most up to date exe for running the speed test.

### Fixed

- Ensure PSModule path is set properly for smoother testing.
- Allow for functions to have no params and still pass the module analyzer.
- No longer measure the wrong results every time.
- Reference to Home folder is now OS agnostic.

### Changed

- Made a Tests folder that mirrors the structure of the NetworkAnalyzer folder to split functions from their tests.
- Move Scripts folder to the top level.

### Removed

- Initial template function and test have been removed now that real functions exist.

## [0.1.0] - 2023-03-01

### Added

- Publish Module package to GitHub Packages

## [0.0.1] - 2023-02-27

### Added

- GitHub workflow for testing, building, and publishing.
- Initial scaffolding based on the repo this one is forked from.
- This changelog file.
- Metadata to Module nuspec file.

[unreleased]: https://github.com/beau-witter/NetworkAnalyzer/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/beau-witter/NetworkAnalyzer/releases/tag/v0.1.0
[0.0.1]: https://github.com/beau-witter/NetworkAnalyzer/releases/tag/v0.0.1
