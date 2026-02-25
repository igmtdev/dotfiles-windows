# dotfiles-windows

Personal Windows 11 dotfiles for PowerShell 7, managed with a Stow-like linker script.

---

## Table of Contents

- [Features at a Glance](#features-at-a-glance)
- [Repository Structure](#repository-structure)
- [System Requirements](#system-requirements)
  - [Supported Platform](#supported-platform)
  - [Prerequisites](#prerequisites)
  - [Core Dependencies](#core-dependencies)
  - [Optional Tools](#optional-tools)
- [Setup Guide](#setup-guide)
  - [Option A: Automated Setup (Windows Stow-like)](#option-a-automated-setup-windows-stow-like)
  - [Option B: Manual Setup](#option-b-manual-setup)
- [Tool Configuration Details](#tool-configuration-details)
  - [Terminal Emulators](#terminal-emulators)
  - [PowerShell Runtime](#powershell-runtime)
  - [CLI Tools](#cli-tools)
  - [Claude Code Configuration](#claude-code-configuration)
  - [MCP Servers](#mcp-servers)
  - [Skills](#skills)
  - [Editor](#editor)
    - [VS Code](#vs-code)
      - [VS Code Settings](#vs-code-settings)
      - [VS Code Extensions](#vs-code-extensions)
      - [Enable Custom CSS](#enable-custom-css)
- [Command Reference](#command-reference)
  - [Shell Commands and Abbreviations](#shell-commands-and-abbreviations)
  - [Custom Functions](#custom-functions)
  - [Stow-like Script Commands](#stow-like-script-commands)
  - [Lazygit Keybindings](#lazygit-keybindings)
- [Customization](#customization)
  - [Local Overrides](#local-overrides)
  - [Oh My Posh Theme Customization](#oh-my-posh-theme-customization)
  - [Vesper Theme Colors](#vesper-theme-colors)
- [Updating](#updating)
  - [Pull Latest Dotfiles](#pull-latest-dotfiles)
  - [Re-link After Update](#re-link-after-update)
  - [Update Tools](#update-tools)
- [Backup and Restore](#backup-and-restore)
  - [Using the Backup Function](#using-the-backup-function)
  - [Stow-like Conflict Backups](#stow-like-conflict-backups)
  - [Restore Procedures](#restore-procedures)
- [Uninstallation](#uninstallation)
  - [Remove Managed Links](#remove-managed-links)
  - [Remove Repo Files](#remove-repo-files)
- [Troubleshooting](#troubleshooting)
  - [Symlink Creation Fails](#symlink-creation-fails)
  - [Status Shows Conflicts](#status-shows-conflicts)
  - [PowerShell Profile Not Loading](#powershell-profile-not-loading)
  - [Oh My Posh Not Found](#oh-my-posh-not-found)
  - [Bat Theme Not Found](#bat-theme-not-found)
  - [Zoxide Not Jumping Correctly](#zoxide-not-jumping-correctly)
- [Recommended Windows Apps](#recommended-windows-apps)
  - [Productivity](#productivity)
  - [Development and Terminal](#development-and-terminal)
  - [System and Utilities](#system-and-utilities)
- [License](#license)

---

## Features at a Glance

| Category           | Tools/Config                                                                                                                                                                                                                                                                                                     | Notes                       |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| Shell              | [PowerShell 7](https://learn.microsoft.com/powershell/scripting/overview?view=powershell-7.5) + modular [`conf.d`](.config/powershell/conf.d) + [`functions`](.config/powershell/functions)                                                                                                                      | Managed                     |
| Prompt             | [Oh My Posh](https://ohmyposh.dev/) + custom theme [`heyitsiveen.omp.toml`](.config/oh-my-posh/heyitsiveen.omp.toml)                                                                                                                                                                                             | Managed                     |
| Terminal           | [WezTerm](https://wezfurlong.org/wezterm/) + [Ghostty](https://ghostty.org/) with configs in [`.config/wezterm`](.config/wezterm) and [`.config/ghostty`](.config/ghostty)                                                                                                                                       | Managed                     |
| Search/Navigation  | [fzf](https://github.com/junegunn/fzf), [fd](https://github.com/sharkdp/fd), [zoxide](https://github.com/ajeetdsouza/zoxide), [ripgrep](https://github.com/BurntSushi/ripgrep)                                                                                                                                   | Managed via PowerShell init |
| CLI Enhancements   | [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [delta](https://github.com/dandavison/delta), [jq](https://jqlang.github.io/jq/), [HTTPie](https://httpie.io/), [lazygit](https://github.com/jesseduffield/lazygit), [fastfetch](https://github.com/fastfetch-cli/fastfetch) | Managed via aliases/env     |
| Deployment         | Stow-like linker [`scripts/stow.ps1`](scripts/stow.ps1) and wrapper [`scripts/install-profile.ps1`](scripts/install-profile.ps1)                                                                                                                                                                                 | Managed                     |
| Claude Integration | [`.claude.json`](.claude.json), [`.claude/CLAUDE.md`](.claude/CLAUDE.md), [`.claude/settings.json`](.claude/settings.json)                                                                                                                                                                                       | Managed                     |

---

## Repository Structure

```text
dotfiles-windows/
├── .claude/
│   ├── CLAUDE.md
│   └── settings.json
├── .claude.json
├── .config/
│   ├── bat/
│   │   ├── config
│   │   └── themes/
│   │       └── Vesper.tmTheme
│   ├── btop/
│   │   └── btop.conf
│   ├── Code/
│   │   └── zed-style.css
│   ├── ghostty/
│   │   └── config
│   ├── oh-my-posh/
│   │   └── heyitsiveen.omp.toml
│   ├── powershell/
│   │   ├── profile.ps1
│   │   ├── config.ps1
│   │   ├── conf.d/
│   │   │   ├── 00-platform.ps1
│   │   │   ├── 10-environment.ps1
│   │   │   ├── 20-paths.ps1
│   │   │   ├── 30-aliases.ps1
│   │   │   ├── 40-fzf.ps1
│   │   │   ├── 50-tools.ps1
│   │   │   ├── 60-prompt.ps1
│   │   │   └── 70-greeting.ps1
│   │   └── functions/
│   │       ├── Add-PathEntry.ps1
│   │       ├── Backup-File.ps1
│   │       ├── Reload-Profile.ps1
│   │       └── Test-Command.ps1
│   └── wezterm/
│       └── wezterm.lua
├── docs/
│   ├── ARCHITECTURE.md
│   └── COMPATIBILITY.md
├── scripts/
│   ├── install-profile.ps1
│   ├── install-tools.ps1
│   └── stow.ps1
├── .gitconfig
├── .gitignore
└── .stow-local-ignore
```

---

## System Requirements

### Supported Platform

- Windows 11
- PowerShell 7 (`pwsh`)

### Prerequisites

- Git
- winget
- PowerShell 7

### Core Dependencies

Install through `scripts/install-tools.ps1`:

- `JanDeDobbeleer.OhMyPosh`
- `wez.wezterm`
- `sharkdp.bat`
- `sharkdp.fd`
- `junegunn.fzf`
- `eza-community.eza`
- `ajeetdsouza.zoxide`
- `BurntSushi.ripgrep.MSVC`
- `dandavison.delta`
- `jqlang.jq`
- `JesseDuffield.lazygit`
- `Fastfetch-cli.Fastfetch`

### Optional Tools

- Nerd Font (recommended: JetBrainsMono Nerd Font)
- Ghostty (if installed locally)

---

## Setup Guide

Clone or place this repository anywhere you want. Commands below assume you run from repo root:

```powershell
cd "<your-path>\dotfiles-windows"
```

### Option A: Automated Setup (Windows Stow-like)

This is the primary setup path and closest equivalent to GNU Stow behavior.

#### 1. Install CLI dependencies

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\install-tools.ps1
```

#### 2. Preview link actions (dry-run)

What this does:

- Shows every target path in `$HOME` that will be linked
- Shows every existing conflicting file/folder that would be moved to backup
- Shows which links would be created
- Makes **no** filesystem changes

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\stow.ps1 -Mode dry-run
```

#### 3. Link configs into your home directory

What this does:

- Creates managed links from this repository into `$HOME`
- Backs up conflicts to `.stow-backups\<timestamp>\...`
- Writes state to `.stow-state.json`

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\stow.ps1 -Mode link
```

#### 4. Verify setup

```powershell
.\scripts\stow.ps1 -Mode status
pwsh -NoProfile -Command ". $PROFILE; 'profile loaded'"
```

#### 5. Compatibility wrapper (optional)

`install-profile.ps1` is an installer-style wrapper around `stow.ps1`.

```powershell
.\scripts\install-profile.ps1 -Mode status
.\scripts\install-profile.ps1 -Mode link
```

### Option B: Manual Setup

Use this if you do not want automated link management.

#### 1. Create target directories

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.config" | Out-Null
New-Item -ItemType Directory -Force -Path "$HOME\.config\powershell" | Out-Null
New-Item -ItemType Directory -Force -Path "$HOME\.config\oh-my-posh" | Out-Null
```

#### 2. Copy required configuration directories

```powershell
Copy-Item -Recurse -Force .\.config\powershell "$HOME\.config\powershell"
Copy-Item -Recurse -Force .\.config\oh-my-posh "$HOME\.config\oh-my-posh"
Copy-Item -Recurse -Force .\.config\bat "$HOME\.config\bat"
Copy-Item -Recurse -Force .\.config\wezterm "$HOME\.config\wezterm"
Copy-Item -Recurse -Force .\.config\ghostty "$HOME\.config\ghostty"
```

#### 3. Point PowerShell profile to repo profile (manual symlink)

```powershell
$profileDir = Split-Path -Parent $PROFILE
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
New-Item -ItemType SymbolicLink -Path $PROFILE -Target (Resolve-Path .\.config\powershell\profile.ps1) -Force
```

If symlink creation is restricted, copy the profile file instead:

```powershell
Copy-Item -Force .\.config\powershell\profile.ps1 $PROFILE
```

`profile.ps1` resolves `config.ps1` dynamically (symlink target first, then fallback paths), so both symlinked and copied profile setups load consistently.

#### 4. Restart PowerShell

Open a new `pwsh` session and confirm Oh My Posh prompt is active.

---

## Tool Configuration Details

### Terminal Emulators

#### WezTerm

- Config path: `.config/wezterm/wezterm.lua`
- Default shell: `pwsh.exe`
- Theme: Vesper

#### Ghostty

- Config path: `.config/ghostty/config`
- Shell command configured as `pwsh`

### PowerShell Runtime

PowerShell load order after linking:

1. `$PROFILE` bootstrap (`.config/powershell/profile.ps1`)
2. `config.ps1` from resolved PowerShell root (prefers profile symlink target, falls back to `$PSScriptRoot` and `$HOME\.config\powershell`)
3. `functions/*.ps1` (alphabetical)
4. `conf.d/*.ps1` (alphabetical)

Prompt startup:

- `.config/powershell/conf.d/60-prompt.ps1`
- Uses `.config/oh-my-posh/heyitsiveen.omp.toml`

### CLI Tools

Configured in `conf.d` modules:

- `bat`: theme + `cat` replacement
- `eza`: `ls/ll/la/lt/lta`
- `zoxide`: PowerShell init
- `fzf`: default options and preview variables
- `fnm`: shell init with `--use-on-cd`
- `delta`: `GIT_PAGER`
- `ripgrep`: `RIPGREP_CONFIG_PATH` if config exists

### Claude Code Configuration

| Path                    | Purpose                     |
| ----------------------- | --------------------------- |
| `.claude.json`          | MCP server config           |
| `.claude/CLAUDE.md`     | project instructions        |
| `.claude/settings.json` | Claude status line settings |

### MCP Servers

MCP (Model Context Protocol) servers extend Claude Code with external tools and data sources.  
Configuration lives in [`.claude.json`](.claude.json).

| Server            | Type          | Purpose                                    | Docs                                                                       |
| ----------------- | ------------- | ------------------------------------------ | -------------------------------------------------------------------------- |
| `context7`        | HTTP          | Up-to-date library docs and code examples  | [Docs](https://context7.com/docs/overview)                                 |
| `exa`             | HTTP          | Web research and code context              | [Docs](https://exa.ai/docs/reference/exa-mcp)                              |
| `grep`            | HTTP          | GitHub code search                         | [Docs](https://vercel.com/blog/grep-a-million-github-repositories-via-mcp) |
| `better-auth`     | HTTP          | Better Auth docs and APIs                  | [Docs](https://www.better-auth.com/docs)                                   |
| `shopify-dev-mcp` | stdio (`npx`) | Shopify API tools and schema introspection | [Docs](https://shopify.dev)                                                |

### Skills

Skills from [skills.sh](https://skills.sh) extend Claude Code with domain-specific knowledge and best practices.

#### Anthropic - [anthropics/skills](https://github.com/anthropics/skills)

```powershell
npx skills add anthropics/skills
```

| Skill              | Description                                                   |
| ------------------ | ------------------------------------------------------------- |
| `frontend-design`  | Production-grade frontend interfaces with high design quality |
| `skill-creator`    | Build new skills that extend agent capabilities               |
| `pdf`              | PDF extraction, creation, merging, splitting, and forms       |
| `docx`             | Document creation, editing, tracked changes, and analysis     |
| `xlsx`             | Spreadsheet creation, formulas, and data analysis             |
| `mcp-builder`      | Guide for creating MCP servers                                |
| `canvas-design`    | Visual art creation in PNG and PDF formats                    |
| `doc-coauthoring`  | Collaborative documentation and iterative refinement          |
| `theme-factory`    | Styling toolkit with preset themes and custom generation      |
| `brand-guidelines` | Brand colors and typography standards                         |

#### Vercel - [vercel-labs](https://github.com/vercel-labs) / [vercel](https://github.com/vercel)

```powershell
npx skills add vercel-labs/agent-skills vercel-labs/next-skills vercel/ai vercel/turborepo
```

| Skill                         | Description                                       |
| ----------------------------- | ------------------------------------------------- |
| `vercel-react-best-practices` | React/Next.js performance optimization            |
| `web-design-guidelines`       | UI code compliance with Web Interface Guidelines  |
| `vercel-react-native-skills`  | React Native and Expo mobile best practices       |
| `next-best-practices`         | Next.js conventions, RSC, data patterns, metadata |
| `ai-sdk`                      | Build AI features with Vercel AI SDK              |
| `turborepo`                   | Monorepo best practices with Turborepo            |

#### Expo - [expo/skills](https://github.com/expo/skills)

```powershell
npx skills add expo/skills
```

| Skill                  | Description                                            |
| ---------------------- | ------------------------------------------------------ |
| `building-native-ui`   | Build apps with Expo Router, styling, and navigation   |
| `native-data-fetching` | Networking, API requests, caching, and offline support |
| `expo-deployment`      | Deploy to iOS App Store and Android Play Store         |
| `expo-tailwind-setup`  | Tailwind CSS + NativeWind setup                        |
| `expo-api-routes`      | API routes in Expo Router with EAS Hosting             |

#### Better Auth - [better-auth/skills](https://github.com/better-auth/skills)

```powershell
npx skills add better-auth/skills
```

| Skill                        | Description                                  |
| ---------------------------- | -------------------------------------------- |
| `better-auth-best-practices` | Better Auth TypeScript framework integration |
| `create-auth-skill`          | Create auth layers using Better Auth         |

#### Remotion - [remotion-dev/skills](https://github.com/remotion-dev/skills)

```powershell
npx skills add remotion-dev/skills
```

| Skill                     | Description                           |
| ------------------------- | ------------------------------------- |
| `remotion-best-practices` | Video creation in React with Remotion |

#### Marketing Skills - [coreyhaines31/marketingskills](https://skills.sh/coreyhaines31/marketingskills/seo-audit)

```powershell
npx skills add coreyhaines31/marketingskills
```

| Skill       | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `seo-audit` | Audit, review, and diagnose technical and on-page SEO issues |

### Editor

#### VS Code

- **Themes**: [Vesper](https://marketplace.visualstudio.com/items?itemName=raunofreiberg.vesper) or [Ayu Mirage Zed](https://marketplace.visualstudio.com/items?itemName=enhancedjax.vscode-ayu-zed)
- **Icons**: [Symbols](https://marketplace.visualstudio.com/items?itemName=miguelsolorio.symbols)
- **Font**: JetBrains Mono NL / JetBrains Mono / Zed Mono
- **Custom CSS file**: [`.config/Code/zed-style.css`](.config/Code/zed-style.css)
- **Required extension**: [Custom CSS and JS Loader](https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-custom-css)

##### VS Code Settings

Open Command Palette (`Ctrl+Shift+P`), run **Preferences: Open User Settings (JSON)**, then merge:

```jsonc
{
  "window.commandCenter": true,
  "workbench.colorTheme": "Vesper",
  "workbench.iconTheme": "symbols",
  "editor.fontSize": 14,
  "editor.fontFamily": "'JetBrains Mono NL','JetBrains Mono','Zed Mono', monospace",
  "editor.fontLigatures": true,
  "terminal.integrated.fontLigatures": true,
  "editor.cursorStyle": "line",
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "workbench.activityBar.location": "top",
  "workbench.sideBar.location": "right",
  "breadcrumbs.enabled": true,
  "breadcrumbs.icons": false,
  "breadcrumbs.symbolPath": "off",
  "workbench.editor.showIcons": false,
  "workbench.editor.navigationControl": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[typescriptreact]": {
    "editor.defaultFormatter": "biomejs.biome",
  },
  "vscode_custom_css.imports": [
    "file:///C:/Users/<YOUR_USERNAME>/.config/Code/zed-style.css",
  ],
}
```

> **Note:** Replace `<YOUR_USERNAME>` with your actual Windows username.

##### VS Code Extensions

Install the following extensions:

- [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [Biome](https://marketplace.visualstudio.com/items?itemName=biomejs.biome)
- [Custom CSS and JS Loader](https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-custom-css)
- [Vesper](https://marketplace.visualstudio.com/items?itemName=raunofreiberg.vesper)
- [Ayu Mirage Zed](https://marketplace.visualstudio.com/items?itemName=enhancedjax.vscode-ayu-zed)
- [Symbols](https://marketplace.visualstudio.com/items?itemName=miguelsolorio.symbols)

##### Enable Custom CSS

1. Open Command Palette (`Ctrl+Shift+P`) and run **Enable Custom CSS and JS**.
2. Restart VS Code when prompted.
3. If you see "Your Code installation appears to be corrupt. Please reinstall.", choose **Don't Show Again**. This is expected with custom CSS loader.
4. Confirm the Zed-inspired breadcrumb and UI styles are applied.

---

## Command Reference

### Shell Commands and Abbreviations

#### Git commands

| Command | Expansion                   | Description         |
| ------- | --------------------------- | ------------------- |
| `g`     | `git`                       | Git shortcut        |
| `gs`    | `git status`                | working tree status |
| `ga`    | `git add`                   | stage files         |
| `gaa`   | `git add --all`             | stage all changes   |
| `gc`    | `git commit`                | commit changes      |
| `gcm`   | `git commit -m`             | commit with message |
| `gp`    | `git push`                  | push to remote      |
| `gpl`   | `git pull`                  | pull from remote    |
| `gd`    | `git diff`                  | unstaged diff       |
| `gds`   | `git diff --staged`         | staged diff         |
| `gco`   | `git checkout`              | checkout branch     |
| `gb`    | `git branch`                | branch operations   |
| `gl`    | `git log --oneline --graph` | compact log         |
| `gst`   | `git stash`                 | stash changes       |
| `gstp`  | `git stash pop`             | pop stash           |
| `lg`    | `lazygit`                   | launch lazygit      |

#### HTTPie commands

| Command | Expansion     | Description |
| ------- | ------------- | ----------- |
| `hget`  | `http GET`    | HTTP GET    |
| `hpost` | `http POST`   | HTTP POST   |
| `hput`  | `http PUT`    | HTTP PUT    |
| `hdel`  | `http DELETE` | HTTP DELETE |

#### System commands

| Command | Expansion | Description    |
| ------- | --------- | -------------- |
| `top`   | `btop`    | system monitor |
| `htop`  | `btop`    | system monitor |

#### File listing commands

| Command | Expansion                                                  | Description      |
| ------- | ---------------------------------------------------------- | ---------------- |
| `ls`    | `eza --icons --group-directories-first`                    | list files       |
| `ll`    | `eza -l --icons --git --header --group-directories-first`  | long listing     |
| `la`    | `eza -la --icons --git --header --group-directories-first` | include hidden   |
| `lt`    | `eza --tree --level=2 --icons`                             | 2-level tree     |
| `lta`   | `eza --tree --level=2 --icons -a`                          | tree with hidden |

### Custom Functions

#### `backup <file> [destination]`

Create a timestamped backup file.

```powershell
backup .\settings.json
backup .\settings.json "$HOME\backups"
```

#### `reload-profile`

Reload current PowerShell profile chain without opening a new shell.

```powershell
reload-profile
```

### Stow-like Script Commands

#### `dry-run`

Preview changes without mutation:

```powershell
.\scripts\stow.ps1 -Mode dry-run
```

#### `link`

Create managed links and backup conflicts:

```powershell
.\scripts\stow.ps1 -Mode link
```

#### `status`

Show current link state:

```powershell
.\scripts\stow.ps1 -Mode status
```

#### `unlink`

Remove only managed links:

```powershell
.\scripts\stow.ps1 -Mode unlink
```

#### `unlink` with backup restore

```powershell
.\scripts\stow.ps1 -Mode unlink -RestoreBackups
```

#### `restow`

Unlink managed targets and re-link using latest repo state:

```powershell
.\scripts\stow.ps1 -Mode restow
```

### Lazygit Keybindings

Lazygit uses its own default keymap unless you add a custom lazygit config.

Common keys:

- `q`: quit
- `P`: push
- `p`: pull
- `R`: refresh
- `?`: keybindings help
- `Space`: stage/unstage selection

For full keymap, press `?` inside lazygit.

---

## Customization

### Local Overrides

Create an override module that is not overwritten by shared configs:

```powershell
New-Item -ItemType File -Force -Path "$HOME\.config\powershell\conf.d\99-local.ps1"
```

Example:

```powershell
$env:WORK_DIR = "$HOME\projects\work"
function wcd { Set-Location $env:WORK_DIR }
```

### Oh My Posh Theme Customization

Default managed theme:

- `$HOME\.config\oh-my-posh\heyitsiveen.omp.toml`

Switch to a different theme:

1. Add theme file under `.config/oh-my-posh/`
2. Update `.config/powershell/conf.d/60-prompt.ps1`
3. Run `reload-profile`

### Vesper Theme Colors

Core palette used across terminal/prompt:

| Element       | Hex       |
| ------------- | --------- |
| Background    | `#101010` |
| Foreground    | `#FFFFFF` |
| Accent Yellow | `#FFC799` |
| Accent Green  | `#99FFE4` |
| Accent Blue   | `#B9AEDA` |
| Accent Red    | `#FF8080` |

---

## Updating

### Pull Latest Dotfiles

```powershell
git pull
```

### Re-link After Update

```powershell
.\scripts\stow.ps1 -Mode restow
```

### Update Tools

```powershell
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
```

---

## Backup and Restore

### Using the Backup Function

```powershell
backup "$HOME\.gitconfig"
```

### Stow-like Conflict Backups

When `link` finds conflicts, originals are moved to:

- `.stow-backups\<timestamp>\...`

Metadata for managed links and related backups:

- `.stow-state.json`

### Restore Procedures

Restore via script:

```powershell
.\scripts\stow.ps1 -Mode unlink -RestoreBackups
```

Manual restore:

1. Open backup directory under `.stow-backups\`
2. Move desired files back to their original `$HOME` paths

---

## Uninstallation

### Remove Managed Links

```powershell
.\scripts\stow.ps1 -Mode unlink
```

To remove links and restore backups:

```powershell
.\scripts\stow.ps1 -Mode unlink -RestoreBackups
```

### Remove Repo Files

After unlinking, delete repo and optional state artifacts:

- `.stow-state.json`
- `.stow-backups/`

---

## Troubleshooting

### Symlink Creation Fails

Symptoms:

- link step fails while creating symlinks

Fixes:

1. Enable Windows Developer Mode
2. Run shell as Administrator
3. Re-run `.\scripts\stow.ps1 -Mode link`

### Status Shows Conflicts

Symptoms:

- `status` shows `[conflict]` entries

Fixes:

1. Run `dry-run` to preview moves
2. Run `link` to auto-backup and link
3. Check `.stow-backups\` for preserved originals

### PowerShell Profile Not Loading

Check:

```powershell
.\scripts\stow.ps1 -Mode status
Test-Path $PROFILE
pwsh -NoProfile -Command ". $PROFILE; 'profile loaded'"
```

If profile target is conflict/missing, run:

```powershell
.\scripts\stow.ps1 -Mode restow
```

### Oh My Posh Not Found

```powershell
winget install --exact --id JanDeDobbeleer.OhMyPosh --source winget
reload-profile
```

### Bat Theme Not Found

```powershell
bat --list-themes
```

If `Vesper` is missing, ensure `.config/bat/themes/Vesper.tmTheme` is linked and run:

```powershell
bat cache --build
```

### Zoxide Not Jumping Correctly

Use normal directory navigation first to build history:

```powershell
zoxide query -l
```

Then test jumps:

```powershell
z <partial-folder-name>
```

---

## Recommended Windows Apps

### Productivity

| App        | Description                                        |
| ---------- | -------------------------------------------------- |
| PowerToys  | window manager, keyboard utilities, quick launcher |
| Everything | instant file indexing and search                   |
| ShareX     | screenshots, recording, and automation             |

### Development and Terminal

| App                | Description                    |
| ------------------ | ------------------------------ |
| Windows Terminal   | multi-profile terminal host    |
| WezTerm            | GPU terminal with Lua config   |
| Visual Studio Code | editor and extension ecosystem |

### System and Utilities

| App              | Description                        |
| ---------------- | ---------------------------------- |
| Process Explorer | advanced process inspection        |
| HWiNFO           | hardware telemetry and diagnostics |
| WizTree          | disk usage analysis                |

---

## License

The upstream `dotfiles` README documents this setup as MIT-licensed.  
This `dotfiles-windows` snapshot currently has no local `LICENSE` file.

If you want explicit MIT terms in this fork, add a `LICENSE` file at repo root using the standard [MIT License text](https://opensource.org/license/mit/).
