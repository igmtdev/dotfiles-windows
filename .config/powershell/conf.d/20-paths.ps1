Add-PathEntry (Join-Path $HOME '.local\bin')

$env:BUN_INSTALL = Join-Path $HOME '.bun'
Add-PathEntry (Join-Path $env:BUN_INSTALL 'bin')

if (Test-Command fnm) {
  $fnmInit = (& fnm env --use-on-cd --shell powershell 2>$null) -join [Environment]::NewLine
  if (-not [string]::IsNullOrWhiteSpace($fnmInit)) {
    Invoke-Expression $fnmInit
  }
}
