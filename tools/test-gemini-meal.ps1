[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Analyze')]
    [ValidateNotNullOrEmpty()]
    [string]$Description,

    [Parameter(ParameterSetName = 'ListModels')]
    [switch]$ListModels,

    [Parameter(ParameterSetName = 'Analyze')]
    [ValidateSet('en', 'de')]
    [string]$Locale = 'en',

    [Parameter(ParameterSetName = 'Analyze')]
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$Model = 'gemini-3.5-flash-lite',

    [Parameter(ParameterSetName = 'Analyze')]
    [ValidateRange(1, 120)]
    [int]$TimeoutSeconds = 20
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$envPath = Join-Path $repositoryRoot '.env.local'

if (-not (Test-Path -LiteralPath $envPath -PathType Leaf)) {
    throw 'Missing .env.local. Copy .env.example to .env.local and set GEMINI_API_KEY.'
}

# Load only the required variable from the local env file. Do not print it.
$apiKey = $null
foreach ($line in Get-Content -LiteralPath $envPath) {
    if ($line -match '^\s*GEMINI_API_KEY\s*=\s*(.*?)\s*$') {
        $apiKey = $Matches[1].Trim().Trim('''', '"')
        break
    }
}

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw 'GEMINI_API_KEY is empty in .env.local.'
}

if ($ListModels) {
    try {
        $modelsEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models'
        $modelsResponse = Invoke-RestMethod `
            -Method Get `
            -Uri $modelsEndpoint `
            -Headers @{ 'x-goog-api-key' = $apiKey } `
            -TimeoutSec $TimeoutSeconds

        $modelsResponse.models |
            Select-Object name, displayName, supportedGenerationMethods |
            ConvertTo-Json -Depth 10
        return
    }
    catch {
        $details = $_.ErrorDetails.Message
        if (-not [string]::IsNullOrWhiteSpace($details)) {
            $details = $details.Replace($apiKey, '[REDACTED]')
        }
        if ([string]::IsNullOrWhiteSpace($details)) {
            $details = $_.Exception.Message
        }
        throw "Gemini model discovery failed: $details"
    }
}

$endpoint = "https://generativelanguage.googleapis.com/v1beta/models/${Model}:generateContent"
$body = @{
    system_instruction = @{
        parts = @(
            @{
                text = "Analyze the meal description for locale $Locale. Return a concise nutrition estimate as JSON with items, confidence, and totals. Use unknown for values that cannot be estimated defensibly."
            }
        )
    }
    contents = @(
        @{
            role  = 'user'
            parts = @(@{ text = $Description })
        }
    )
    generationConfig = @{
        responseMimeType = 'application/json'
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod `
        -Method Post `
        -Uri $endpoint `
        -Headers @{ 'x-goog-api-key' = $apiKey } `
        -ContentType 'application/json' `
        -Body $body `
        -TimeoutSec $TimeoutSeconds

    $response | ConvertTo-Json -Depth 20
}
catch {
    # Keep the key out of diagnostics even if a transport error includes the request.
    $message = $_.ErrorDetails.Message
    if ([string]::IsNullOrWhiteSpace($message)) {
        $message = $_.Exception.Message
    }
    $message = $message.Replace($apiKey, '[REDACTED]')
    throw "Gemini meal test failed: $message"
}
