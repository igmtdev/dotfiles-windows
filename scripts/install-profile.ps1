[CmdletBinding()]
param(
  [Parameter()]
  [ValidateSet('link', 'unlink', 'restow', 'dry-run', 'status')]
  [string]$Mode = 'link',

  [Parameter()]
  [switch]$RestoreBackups
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$stowScript = Join-Path $PSScriptRoot 'stow.ps1'

if (-not (Test-Path -LiteralPath $stowScript)) {
  throw "stow script not found: $stowScript"
}

& $stowScript -Mode $Mode -RepoRoot $repoRoot -HomePath $HOME -RestoreBackups:$RestoreBackups
