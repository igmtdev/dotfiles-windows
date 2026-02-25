$global:OS_TYPE = 'windows'
$global:IS_WINDOWS_11 = $IsWindows -or ($env:OS -eq 'Windows_NT')
