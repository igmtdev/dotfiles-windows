if (Test-Command git) {
  function global:g { & git @args }
  function global:gs { & git status @args }
  function global:ga { & git add @args }
  function global:gaa { & git add --all @args }
  function global:gc { & git commit @args }
  function global:gcm { & git commit -m @args }
  function global:gp { & git push @args }
  function global:gpl { & git pull @args }
  function global:gd { & git diff @args }
  function global:gds { & git diff --staged @args }
  function global:gco { & git checkout @args }
  function global:gb { & git branch @args }
  function global:gl { & git log --oneline --graph @args }
  function global:gst { & git stash @args }
  function global:gstp { & git stash pop @args }
}

if (Test-Command lazygit) {
  function global:lg { & lazygit @args }
}

if (Test-Command http) {
  function global:hget { & http GET @args }
  function global:hpost { & http POST @args }
  function global:hput { & http PUT @args }
  function global:hdel { & http DELETE @args }
}

if (Test-Command btop) {
  function global:top { & btop @args }
  function global:htop { & btop @args }
}

Set-Alias -Name backup -Value Backup-File -Scope Global -Force
Set-Alias -Name reload-profile -Value Reload-Profile -Scope Global -Force
