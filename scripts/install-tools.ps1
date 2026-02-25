[CmdletBinding()]
param()

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw 'winget is required but was not found.'
}

$packages = @(
  'Git.Git'
  'JanDeDobbeleer.OhMyPosh'
  'wez.wezterm'
  'JesseDuffield.lazygit'
  'sharkdp.bat'
  'sharkdp.fd'
  'junegunn.fzf'
  'eza-community.eza'
  'ajeetdsouza.zoxide'
  'BurntSushi.ripgrep.MSVC'
  'dandavison.delta'
  'jqlang.jq'
  'Fastfetch-cli.Fastfetch'
)

foreach ($packageId in $packages) {
  Write-Host "Installing $packageId..." -ForegroundColor Cyan
  winget install --exact --id $packageId --source winget --accept-source-agreements --accept-package-agreements --silent
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "Unable to install $packageId with winget."
  }
}
