# Environment Setup Scripts

This directory contains scripts to configure your shell prompt and Vim environment.

## Scripts

### `bash_setup.sh`

Configures the Bash shell with a Git-aware prompt and writes a managed Vim block.

**Usage:**

This script **must be sourced** to work correctly.

```bash
source bash_setup.sh
```

This will:
1. Copy `git_prompt.sh` to `~/.local/`.
2. Install a managed prompt block in your `.bashrc`.
3. Source `vim_setup.sh` to write managed Vim settings to `~/.vimrc`.
4. Reload the prompt configuration in the current shell.

### `vim_setup.sh`

Writes a managed Vim settings block to `~/.vimrc`. Shell-independent;
sourced by both `bash_setup.sh` and `fish_setup.sh` so a Vim config is
installed regardless of which setup script you run.

**Usage:**

```bash
bash vim_setup.sh           # write the vim block standalone
source vim_setup.sh         # expose install_vim_config in the current shell
```

### `fish_setup.sh`

Installs the [fish](https://fishshell.com/) shell and configures
interactive bash sessions to automatically `exec` into fish.

This script is intentionally separate from `bash_setup.sh` since fish
may not be available on every machine.

**Usage:**

```bash
bash fish_setup.sh                     # install fish + auto-enter + prompt + colors + vim (default)
bash fish_setup.sh install             # install fish only
bash fish_setup.sh autostart           # configure auto-enter only
bash fish_setup.sh prompt              # install prompt block only
bash fish_setup.sh colors              # install color overrides only
bash fish_setup.sh vim                 # install vim block only
bash fish_setup.sh uninstall-autostart # remove the auto-enter block
bash fish_setup.sh uninstall-prompt    # remove the prompt block
bash fish_setup.sh uninstall-colors    # remove the color block
```

The color block overrides fish's default syntax-highlighting and pager
colors that lean blue/cyan, so commands stay readable on dark
backgrounds (e.g. WSL Ubuntu's default theme).

Supported package managers: `apt-get`, `dnf`, `yum`, `apk`, `pacman`,
`zypper`, `brew`. `sudo` is used automatically when not running as root.

The auto-enter block in `~/.bashrc` is guarded so it:
- only runs for interactive shells,
- skips when the parent process is fish (no recursion),
- skips when `BASH_ENV_SETUP_NO_FISH` is set (escape hatch — e.g. `BASH_ENV_SETUP_NO_FISH=1 bash`),
- silently no-ops when fish is not on `PATH`.

### `git_prompt.sh`

A helper script that provides the Git status logic for the shell prompt. It is used by `bash_setup.sh`.
