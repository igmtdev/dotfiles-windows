if (-not (Test-Command fzf)) {
  return
}

$env:FZF_DEFAULT_OPTS = @(
  '--color=bg+:-1,bg:-1,spinner:#FFC799,hl:#FFC799'
  '--color=fg:#b0b0b0,header:#505050,info:#FFCFA8,pointer:#FFC799'
  '--color=marker:#FFC799,fg+:#ffffff,prompt:#FFC799,hl+:#FFCFA8'
  '--height=50%'
  '--layout=reverse'
  '--border=rounded'
  '--info=inline'
  '--marker=>'
  '--pointer=>'
  '--prompt=> '
  "--bind=ctrl-/:toggle-preview"
) -join ' '

if (Test-Command fd) {
  $env:FZF_DEFAULT_COMMAND = 'fd --type file --strip-cwd-prefix --hidden --follow --exclude .git'
  $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
  $env:FZF_ALT_C_COMMAND = 'fd --type dir --strip-cwd-prefix --hidden --follow --exclude .git'
}

if (Test-Command bat) {
  $env:FZF_CTRL_T_OPTS = '--preview "bat --style=numbers --color=always --line-range :300 {}"'
} elseif (Test-Command batcat) {
  $env:FZF_CTRL_T_OPTS = '--preview "batcat --style=numbers --color=always --line-range :300 {}"'
}

if (Test-Command eza) {
  $env:FZF_ALT_C_OPTS = '--preview "eza --tree --level=2 --icons --color=always {}"'
}
