if (Test-Command nvim) {
  $env:EDITOR = 'nvim'
} elseif (Test-Command vim) {
  $env:EDITOR = 'vim'
} elseif (Test-Command code) {
  $env:EDITOR = 'code --wait'
} else {
  $env:EDITOR = 'notepad'
}

$env:VISUAL = $env:EDITOR
