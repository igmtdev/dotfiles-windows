function Reload-Profile {
  [CmdletBinding()]
  param()

  if ($global:DOTFILES_PWSH_ROOT) {
    $dotfilesProfile = Join-Path $global:DOTFILES_PWSH_ROOT 'profile.ps1'
    if (Test-Path -LiteralPath $dotfilesProfile) {
      . $dotfilesProfile
      Write-Output "Reloaded: $dotfilesProfile"
      return
    }
  }

  if (Test-Path -LiteralPath $PROFILE) {
    . $PROFILE
    Write-Output "Reloaded: $PROFILE"
  }
}
