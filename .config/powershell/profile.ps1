$profilePath = $PSCommandPath
if (-not $profilePath -and $MyInvocation.MyCommand.Path) {
  $profilePath = $MyInvocation.MyCommand.Path
}

$candidateRoots = @()

if ($profilePath -and (Test-Path -LiteralPath $profilePath)) {
  try {
    $profileItem = Get-Item -LiteralPath $profilePath -Force
    $isReparsePoint = ($profileItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0

    if ($isReparsePoint -and $profileItem.Target) {
      foreach ($target in @($profileItem.Target)) {
        if ([string]::IsNullOrWhiteSpace([string]$target)) {
          continue
        }

        $resolvedTarget = if ([System.IO.Path]::IsPathRooted($target)) {
          [System.IO.Path]::GetFullPath($target)
        } else {
          [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $profilePath) $target))
        }

        $candidateRoots += Split-Path -Parent $resolvedTarget
      }
    }
  } catch {
    # Fall back to default candidates below.
  }
}

$candidateRoots += @(
  $PSScriptRoot
  (Join-Path $HOME '.config\powershell')
)

$candidateRoots = $candidateRoots |
  Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
  ForEach-Object { [System.IO.Path]::GetFullPath($_) } |
  Select-Object -Unique

$configPath = $candidateRoots |
  ForEach-Object { Join-Path $_ 'config.ps1' } |
  Where-Object { Test-Path -LiteralPath $_ } |
  Select-Object -First 1

if (-not $configPath) {
  Write-Warning ("PowerShell config.ps1 not found. Searched: {0}" -f ($candidateRoots -join '; '))
  return
}

$resolvedPwshRoot = Split-Path -Parent $configPath
$global:DOTFILES_PWSH_ROOT = $resolvedPwshRoot
$global:DOTFILES_WINDOWS_ROOT = Split-Path -Parent (Split-Path -Parent $resolvedPwshRoot)

. $configPath
