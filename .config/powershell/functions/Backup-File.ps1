function Backup-File {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Path,

    [Parameter(Position = 1)]
    [string]$Destination
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "File not found: $Path"
  }

  $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
  $sourceItem = Get-Item -LiteralPath $resolvedPath
  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

  if ([string]::IsNullOrWhiteSpace($Destination)) {
    $targetDir = $sourceItem.DirectoryName
  } else {
    $targetDir = (Resolve-Path -LiteralPath $Destination -ErrorAction SilentlyContinue).Path
    if (-not $targetDir) {
      throw "Destination directory not found: $Destination"
    }
  }

  $backupPath = Join-Path $targetDir "$($sourceItem.Name).$timestamp.bak"
  Copy-Item -LiteralPath $sourceItem.FullName -Destination $backupPath -Force
  Write-Output "Backup created: $backupPath"
}
