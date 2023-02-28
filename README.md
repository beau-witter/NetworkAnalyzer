# Network Analyzer

Powershell Module that can be used to detect internet speeds, reset net adapter, and more. 

## Build Status

[![NetworkAnalyzer CI](https://github.com/beau-witter/NetworkAnalyzer/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/beau-witter/NetworkAnalyzer/actions/workflows/main.yml)
[![latest version](https://img.shields.io/powershellgallery/v/NetworkAnalyzer.svg?label=latest+version)](https://www.powershellgallery.com/packages/NetworkAnalyzer)

## Introduction

This module is currently a solo-endeavor that contains various speed test, network resetting, nad other potential goodies that seemed interesting to have available quickly in PowerShell.

## Getting Started

Clone the repository to your local machine and look for project artifacts in the following locations:

* [NetworkAnalyzer](https://github.com/beau-witter/NetworkAnalyzer/tree/main/NetworkAnalyzer) - source code for the module itself along with tests
* [NetworkAnalyzer.build.ps1](https://github.com/beau-witter/NetworkAnalyzer/blob/main/NetworkAnalyzer.build.ps1) - build script for the module
* [NetworkAnalyzer.depend.psd1](https://github.com/beau-witter/NetworkAnalyzer/blob/main/NetworkAnalyzer.depend.psd1) - managing module dependencies with PSDepend
* build - this folder will be created during the build process and will contain the build artifacts

## Build and Test

This project uses [InvokeBuild](https://github.com/nightroman/Invoke-Build) module to automate build tasks such as running test, performing static code analysis, building the module, etc.

* To build the module, run: Invoke-Build
* To see other build options: Invoke-Build ?

## Suggested tools

* Editing - [Visual Studio Code](https://github.com/Microsoft/vscode)
* Runtime - [PowerShell Core](https://github.com/powershell)
* Build tool - [InvokeBuild](https://github.com/nightroman/Invoke-Build)
* Dependency management - [PSDepend](https://github.com/RamblingCookieMonster/PSDepend)
* Testing - [Pester](https://github.com/Pester/Pester)
* Code coverage - [Pester](https://pester.dev/docs/usage/code-coverage)
* Static code analysis - [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
