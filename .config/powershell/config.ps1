$functionsPath = Join-Path $PSScriptRoot 'functions'
if (Test-Path -LiteralPath $functionsPath) {
  Get-ChildItem -LiteralPath $functionsPath -Filter '*.ps1' -File |
    Sort-Object Name |
    ForEach-Object { . $_.FullName }
}

$confPath = Join-Path $PSScriptRoot 'conf.d'
if (Test-Path -LiteralPath $confPath) {
  Get-ChildItem -LiteralPath $confPath -Filter '*.ps1' -File |
    Sort-Object Name |
    ForEach-Object { . $_.FullName }
}
