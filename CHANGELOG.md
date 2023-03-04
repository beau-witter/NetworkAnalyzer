# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Test-IsElevated private function. Allows for better explanation for certain actions' availability.
- Restart-NetAdapter public function. Now we can restart a net adapter as a network-fixing step.
- ScriptToProcess "GoLangSetup". Ensures that both GoLang exists and is configured for our use.

### Fixed

- Ensure PSModule path is set properly for smoother testing.
- Allow for functions to have no params and still pass the module analyzer.

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
