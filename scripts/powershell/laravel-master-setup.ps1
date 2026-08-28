param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
$root = Resolve-Path (Join-Path $PSScriptRoot '../..')
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "[ERROR] Node.js is required to run LaravelAutoScript v2."
    exit 1
}
& node (Join-Path $root 'scripts/platform-builder.js') @Arguments
exit $LASTEXITCODE
