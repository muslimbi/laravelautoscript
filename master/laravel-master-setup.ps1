param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments)
$root = Split-Path -Parent $PSScriptRoot
& node (Join-Path $root 'scripts/platform-builder.js') @Arguments
exit $LASTEXITCODE
