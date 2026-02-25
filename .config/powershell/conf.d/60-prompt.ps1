if (-not (Test-Command 'oh-my-posh')) {
  return
}

$themeCandidates = @(
  (Join-Path $global:DOTFILES_WINDOWS_ROOT '.config\oh-my-posh\heyitsiveen.omp.toml')
  (Join-Path $HOME '.config\oh-my-posh\heyitsiveen.omp.toml')
) | Select-Object -Unique

$themePath = $themeCandidates |
  Where-Object { Test-Path -LiteralPath $_ } |
  Select-Object -First 1

if ($themePath) {
  & oh-my-posh init pwsh --config $themePath | Invoke-Expression
} else {
  & oh-my-posh init pwsh | Invoke-Expression
  Write-Warning 'oh-my-posh theme file not found; using default theme.'
}
