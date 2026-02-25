function Add-PathEntry {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$PathEntry
  )

  if ([string]::IsNullOrWhiteSpace($PathEntry)) {
    return
  }

  if (-not (Test-Path -LiteralPath $PathEntry)) {
    return
  }

  $parts = $env:PATH -split ';'
  if ($parts -notcontains $PathEntry) {
    $env:PATH = "$PathEntry;$env:PATH"
  }
}
