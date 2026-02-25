if (Test-Command bat) {
  $env:BAT_THEME = 'Vesper'
  function global:cat { & bat --paging=never @args }
} elseif (Test-Command batcat) {
  $env:BAT_THEME = 'Vesper'
  function global:cat { & batcat --paging=never @args }
}

if (Test-Command eza) {
  function global:ls { & eza --icons --group-directories-first @args }
  function global:ll { & eza -l --icons --git --header --group-directories-first @args }
  function global:la { & eza -la --icons --git --header --group-directories-first @args }
  function global:lt { & eza --tree --level=2 --icons @args }
  function global:lta { & eza --tree --level=2 --icons -a @args }
}

if (Test-Command zoxide) {
  $zoxideInit = (& zoxide init powershell 2>$null) -join [Environment]::NewLine
  if (-not [string]::IsNullOrWhiteSpace($zoxideInit)) {
    Invoke-Expression $zoxideInit
  }
}

if (Test-Command rg) {
  $rgPath = Join-Path $global:DOTFILES_WINDOWS_ROOT '.config\ripgrep\config'
  if (Test-Path -LiteralPath $rgPath) {
    $env:RIPGREP_CONFIG_PATH = $rgPath
  }
}

if (Test-Command delta) {
  $env:GIT_PAGER = 'delta'
}
