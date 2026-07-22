[CmdletBinding()]
param(
  [ValidateSet('Narrow', 'Full', 'Integration', 'LiveGemini')]
  [string]$Mode = 'Full',
  [string[]]$DartPath = @(),
  [string[]]$TestPath = @(),
  [string]$IntegrationTarget = 'integration_test/mvp_critical_journey_test.dart',
  [string]$LiveGeminiTarget = 'integration_test/live_provider_smoke_test.dart',
  [switch]$Generate
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repositoryRoot

function Invoke-Checked {
  param(
    [Parameter(Mandatory)]
    [string]$Command,
    [Parameter()]
    [string[]]$Arguments = @()
  )

  Write-Host "> $Command $($Arguments -join ' ')"
  & $Command @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $Command"
  }
}

function Get-RepositoryDartFiles {
  $sourceRoots = @('lib', 'test', 'integration_test') |
    Where-Object { Test-Path -LiteralPath $_ }

  return @(
    $sourceRoots |
      ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -File -Filter '*.dart' } |
      ForEach-Object { Resolve-Path -Relative -LiteralPath $_.FullName }
  )
}

function Invoke-AndroidJourney {
  param(
    [Parameter(Mandatory)]
    [string]$Target
  )

  $targetPath = (Resolve-Path -LiteralPath $Target).Path.Replace('\', '/')
  Push-Location 'android'
  try {
    Invoke-Checked '.\gradlew.bat' @(
      'app:connectedPreviewDebugAndroidTest',
      "-Ptarget=$targetPath"
    )
  }
  finally {
    Pop-Location
  }
}

if ($Generate) {
  Invoke-Checked 'dart' @('run', 'build_runner', 'build', '--delete-conflicting-outputs')
}

if ($Mode -eq 'Narrow') {
  if ($DartPath.Count -eq 0 -or $TestPath.Count -eq 0) {
    throw 'Narrow mode requires at least one -DartPath and one -TestPath.'
  }

  Invoke-Checked 'dart' (@('format', '--output=none', '--set-exit-if-changed') + $DartPath)
  Invoke-Checked 'flutter' (@('test') + $TestPath)
  exit 0
}

if ($Mode -eq 'LiveGemini') {
  Write-Warning 'This test makes a real Gemini request. First confirm a connected device and a successfully tested credential in the app Provider settings.'
  Invoke-AndroidJourney $LiveGeminiTarget
  exit 0
}

$dartFiles = Get-RepositoryDartFiles
if ($dartFiles.Count -eq 0) {
  throw 'No Dart source or test files were found.'
}

Invoke-Checked 'dart' (@('format', '--output=none', '--set-exit-if-changed') + $dartFiles)
Invoke-Checked 'flutter' @('analyze', '--fatal-infos', '--fatal-warnings')
Invoke-Checked 'flutter' @('test')

if ($Mode -eq 'Integration') {
  Invoke-AndroidJourney $IntegrationTarget
}
