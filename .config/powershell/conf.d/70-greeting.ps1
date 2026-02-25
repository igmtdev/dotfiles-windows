if ($env:DOTFILES_SKIP_GREETING -eq '1') {
  return
}

if (Test-Command fastfetch) {
  & fastfetch
}
