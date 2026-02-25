[CmdletBinding()]
param(
  [Parameter()]
  [ValidateSet('link', 'unlink', 'restow', 'dry-run', 'status')]
  [string]$Mode = 'link',

  [Parameter()]
  [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),

  [Parameter()]
  [string]$HomePath = $HOME,

  [Parameter()]
  [switch]$RestoreBackups
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-PathSafe {
  param([Parameter(Mandatory)][string]$Path)

  if (Test-Path -LiteralPath $Path) {
    return (Resolve-Path -LiteralPath $Path).Path
  }

  return [System.IO.Path]::GetFullPath($Path)
}

function Ensure-Directory {
  param([Parameter(Mandatory)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Get-LinkTargets {
  param([Parameter(Mandatory)][System.IO.FileSystemInfo]$Item)

  $targets = @()
  if ($null -ne $Item.Target) {
    if ($Item.Target -is [System.Array]) {
      $targets = @($Item.Target)
    } else {
      $targets = @($Item.Target)
    }
  }

  $resolved = @()
  foreach ($target in $targets) {
    if ([string]::IsNullOrWhiteSpace($target)) {
      continue
    }

    if ([System.IO.Path]::IsPathRooted($target)) {
      $resolved += [System.IO.Path]::GetFullPath($target)
      continue
    }

    $parent = Split-Path -Parent $Item.FullName
    $resolved += [System.IO.Path]::GetFullPath((Join-Path $parent $target))
  }

  return $resolved
}

function Test-LinkPointsToSource {
  param(
    [Parameter(Mandatory)][string]$Target,
    [Parameter(Mandatory)][string]$Source
  )

  if (-not (Test-Path -LiteralPath $Target)) {
    return $false
  }

  $item = Get-Item -LiteralPath $Target -Force
  if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) {
    return $false
  }

  $sourceFull = [System.IO.Path]::GetFullPath($Source)
  $resolvedTargets = Get-LinkTargets -Item $item
  foreach ($resolved in $resolvedTargets) {
    if ([System.StringComparer]::OrdinalIgnoreCase.Equals($resolved, $sourceFull)) {
      return $true
    }
  }

  return $false
}

function Get-BackupRelativePath {
  param(
    [Parameter(Mandatory)][string]$TargetPath,
    [Parameter(Mandatory)][string]$HomePath
  )

  $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
  $homeFull = [System.IO.Path]::GetFullPath($HomePath).TrimEnd('\')
  $homePrefix = "$homeFull\"

  if ($targetFull.StartsWith($homePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $targetFull.Substring($homePrefix.Length)
  }

  $sanitized = $targetFull -replace ':', '_' -replace '^[\\]+', '' -replace '[\\]+', '\'
  return "_external\$sanitized"
}

function Save-State {
  param(
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory)][object[]]$Entries,
    [Parameter(Mandatory)][string]$ResolvedRepoRoot,
    [Parameter(Mandatory)][string]$ResolvedHome
  )

  $state = [ordered]@{
    version     = 1
    generatedAt = (Get-Date).ToString('o')
    repoRoot    = $ResolvedRepoRoot
    home        = $ResolvedHome
    entries     = $Entries
  }

  $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $StatePath -Encoding UTF8
}

function Load-State {
  param([Parameter(Mandatory)][string]$StatePath)

  if (-not (Test-Path -LiteralPath $StatePath)) {
    return $null
  }

  return Get-Content -LiteralPath $StatePath -Raw | ConvertFrom-Json
}

function Invoke-LinkOperation {
  param(
    [Parameter(Mandatory)][object[]]$Mappings,
    [Parameter(Mandatory)][string]$ResolvedHome,
    [Parameter(Mandatory)][string]$BackupRoot,
    [Parameter(Mandatory)][string]$Timestamp,
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory)][bool]$DryRun,
    [Parameter(Mandatory)][string]$ResolvedRepoRoot
  )

  $entries = @()
  $runBackupRoot = Join-Path $BackupRoot $Timestamp

  foreach ($mapping in $Mappings) {
    $sourcePath = [System.IO.Path]::GetFullPath((Join-Path $ResolvedRepoRoot $mapping.SourceRelative))
    $targetPath = [System.IO.Path]::GetFullPath($mapping.TargetPath)

    if (-not (Test-Path -LiteralPath $sourcePath)) {
      throw "Source path not found: $sourcePath"
    }

    $parent = Split-Path -Parent $targetPath
    if ($DryRun) {
      Write-Host "[dry-run] ensure parent: $parent"
    } else {
      Ensure-Directory -Path $parent
    }

    $backupPath = $null
    $linkType = $null
    $action = 'linked'

    if (Test-LinkPointsToSource -Target $targetPath -Source $sourcePath) {
      $action = 'already-linked'
      $item = Get-Item -LiteralPath $targetPath -Force
      $linkType = if ($item.LinkType) { [string]$item.LinkType } else { 'ReparsePoint' }
      Write-Host "Already linked: $targetPath -> $sourcePath"
    } else {
      if (Test-Path -LiteralPath $targetPath) {
        $backupRelative = Get-BackupRelativePath -TargetPath $targetPath -HomePath $ResolvedHome
        $backupPath = Join-Path $runBackupRoot $backupRelative
        $backupParent = Split-Path -Parent $backupPath

        if ($DryRun) {
          Write-Host "[dry-run] backup conflict: $targetPath -> $backupPath"
        } else {
          Ensure-Directory -Path $backupParent
          Move-Item -LiteralPath $targetPath -Destination $backupPath -Force
          Write-Host "Backed up conflict: $targetPath -> $backupPath"
        }
      }

      if ($DryRun) {
        Write-Host "[dry-run] create $($mapping.Kind) link: $targetPath -> $sourcePath"
        $linkType = if ($mapping.Kind -eq 'directory') { 'SymbolicLink|JunctionFallback' } else { 'SymbolicLink' }
      } else {
        if ($mapping.Kind -eq 'directory') {
          try {
            New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
            $linkType = 'SymbolicLink'
          } catch {
            New-Item -ItemType Junction -Path $targetPath -Target $sourcePath -Force | Out-Null
            $linkType = 'Junction'
          }
        } else {
          New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
          $linkType = 'SymbolicLink'
        }

        Write-Host "Linked: $targetPath -> $sourcePath ($linkType)"
      }
    }

    $entries += [pscustomobject]@{
      name        = $mapping.Name
      kind        = $mapping.Kind
      source      = $sourcePath
      target      = $targetPath
      linkType    = $linkType
      backupPath  = $backupPath
      action      = $action
      linkedAt    = (Get-Date).ToString('o')
    }
  }

  if (-not $DryRun) {
    Save-State -StatePath $StatePath -Entries $entries -ResolvedRepoRoot $ResolvedRepoRoot -ResolvedHome $ResolvedHome
    Write-Host "State written: $StatePath"
  }
}

function Invoke-UnlinkOperation {
  param(
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory)][bool]$Restore,
    [Parameter(Mandatory)][bool]$DryRun
  )

  $state = Load-State -StatePath $StatePath
  if ($null -eq $state) {
    Write-Host "No state file found: $StatePath"
    return
  }

  $remaining = @()
  foreach ($entry in $state.entries) {
    $targetPath = [string]$entry.target
    $sourcePath = [string]$entry.source
    $removed = $false

    if (Test-Path -LiteralPath $targetPath) {
      if (Test-LinkPointsToSource -Target $targetPath -Source $sourcePath) {
        if ($DryRun) {
          Write-Host "[dry-run] remove link: $targetPath"
        } else {
          Remove-Item -LiteralPath $targetPath -Force
          Write-Host "Removed link: $targetPath"
        }
        $removed = $true
      } else {
        Write-Warning "Skipping non-managed target (not pointing to source): $targetPath"
      }
    } else {
      $removed = $true
    }

    if ($removed -and $Restore -and $entry.backupPath) {
      $backupPath = [string]$entry.backupPath
      if (Test-Path -LiteralPath $backupPath) {
        if ($DryRun) {
          Write-Host "[dry-run] restore backup: $backupPath -> $targetPath"
        } else {
          $targetParent = Split-Path -Parent $targetPath
          Ensure-Directory -Path $targetParent
          Move-Item -LiteralPath $backupPath -Destination $targetPath -Force
          Write-Host "Restored backup: $targetPath"
        }
      }
    }

    if (-not $removed) {
      $remaining += $entry
    }
  }

  if (-not $DryRun) {
    if ($remaining.Count -eq 0) {
      Remove-Item -LiteralPath $StatePath -Force
      Write-Host "State file removed: $StatePath"
    } else {
      Save-State -StatePath $StatePath -Entries $remaining -ResolvedRepoRoot ([string]$state.repoRoot) -ResolvedHome ([string]$state.home)
      Write-Warning "Some entries were not removed. State file updated."
    }
  }
}

function Show-Status {
  param(
    [Parameter(Mandatory)][object[]]$Mappings,
    [Parameter(Mandatory)][string]$ResolvedRepoRoot
  )

  foreach ($mapping in $Mappings) {
    $sourcePath = [System.IO.Path]::GetFullPath((Join-Path $ResolvedRepoRoot $mapping.SourceRelative))
    $targetPath = [System.IO.Path]::GetFullPath($mapping.TargetPath)

    if (Test-LinkPointsToSource -Target $targetPath -Source $sourcePath) {
      Write-Host "[linked]  $targetPath -> $sourcePath"
      continue
    }

    if (Test-Path -LiteralPath $targetPath) {
      Write-Host "[conflict] $targetPath"
      continue
    }

    Write-Host "[missing] $targetPath"
  }
}

$resolvedRepoRoot = Resolve-PathSafe -Path $RepoRoot
$resolvedHome = Resolve-PathSafe -Path $HomePath
$statePath = Join-Path $resolvedRepoRoot '.stow-state.json'
$backupRoot = Join-Path $resolvedRepoRoot '.stow-backups'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

$mappings = @(
  @{ Name = 'gitconfig'; Kind = 'file'; SourceRelative = '.gitconfig'; TargetPath = (Join-Path $resolvedHome '.gitconfig') }
  @{ Name = 'claude-json'; Kind = 'file'; SourceRelative = '.claude.json'; TargetPath = (Join-Path $resolvedHome '.claude.json') }
  @{ Name = 'claude-dir'; Kind = 'directory'; SourceRelative = '.claude'; TargetPath = (Join-Path $resolvedHome '.claude') }
  @{ Name = 'config-bat'; Kind = 'directory'; SourceRelative = '.config\bat'; TargetPath = (Join-Path $resolvedHome '.config\bat') }
  @{ Name = 'config-btop'; Kind = 'directory'; SourceRelative = '.config\btop'; TargetPath = (Join-Path $resolvedHome '.config\btop') }
  @{ Name = 'config-code'; Kind = 'directory'; SourceRelative = '.config\Code'; TargetPath = (Join-Path $resolvedHome '.config\Code') }
  @{ Name = 'config-ghostty'; Kind = 'directory'; SourceRelative = '.config\ghostty'; TargetPath = (Join-Path $resolvedHome '.config\ghostty') }
  @{ Name = 'config-oh-my-posh'; Kind = 'directory'; SourceRelative = '.config\oh-my-posh'; TargetPath = (Join-Path $resolvedHome '.config\oh-my-posh') }
  @{ Name = 'config-powershell'; Kind = 'directory'; SourceRelative = '.config\powershell'; TargetPath = (Join-Path $resolvedHome '.config\powershell') }
  @{ Name = 'config-wezterm'; Kind = 'directory'; SourceRelative = '.config\wezterm'; TargetPath = (Join-Path $resolvedHome '.config\wezterm') }
  @{ Name = 'pwsh-profile'; Kind = 'file'; SourceRelative = '.config\powershell\profile.ps1'; TargetPath = $PROFILE }
)

switch ($Mode) {
  'status' {
    Show-Status -Mappings $mappings -ResolvedRepoRoot $resolvedRepoRoot
    break
  }
  'dry-run' {
    Invoke-LinkOperation -Mappings $mappings -ResolvedHome $resolvedHome -BackupRoot $backupRoot -Timestamp $timestamp -StatePath $statePath -DryRun $true -ResolvedRepoRoot $resolvedRepoRoot
    break
  }
  'unlink' {
    Invoke-UnlinkOperation -StatePath $statePath -Restore $RestoreBackups.IsPresent -DryRun $false
    break
  }
  'restow' {
    Invoke-UnlinkOperation -StatePath $statePath -Restore $false -DryRun $false
    Invoke-LinkOperation -Mappings $mappings -ResolvedHome $resolvedHome -BackupRoot $backupRoot -Timestamp $timestamp -StatePath $statePath -DryRun $false -ResolvedRepoRoot $resolvedRepoRoot
    break
  }
  default {
    Invoke-LinkOperation -Mappings $mappings -ResolvedHome $resolvedHome -BackupRoot $backupRoot -Timestamp $timestamp -StatePath $statePath -DryRun $false -ResolvedRepoRoot $resolvedRepoRoot
  }
}
