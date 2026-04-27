# Environment Setup Scripts

This directory contains scripts to configure your shell prompt and Vim environment.

## Scripts

### `env_setup.sh`

Configures the shell environment (Bash) to include a Git-aware prompt.

**Usage:**

This script **must be sourced** to work correctly.

```bash
source env_setup.sh [mode]
```

- **Default mode:**
  ```bash
  source env_setup.sh
  ```
  This will:
  1. Copy `git_prompt.sh` to `~/.local/`.
  2. Install a managed prompt block in your `.bashrc`.
  3. Reload the prompt configuration in the current shell.

- **Alibaba mode (`ali`):**
  ```bash
  sudo source env_setup.sh ali
  ```
  *Note: This mode requires root privileges as it modifies `/etc/profile.d/alibaba_bashenv.sh`.*

### `vim_setup.sh`

Installs the [Ultimate Vim Configuration](https://github.com/amix/vimrc) (Awesome version) and applies custom settings.

**Usage:**

```bash
./vim_setup.sh
```

This will:
1. Clone or update `~/.vim_runtime`.
2. Run the `install_awesome_vimrc.sh` script.
3. Apply custom configurations to `~/.vim_runtime/my_configs.vim`.

### `fish_setup.sh`

Installs the [fish](https://fishshell.com/) shell and configures
interactive bash sessions to automatically `exec` into fish.

This script is intentionally separate from `env_setup.sh` since fish
may not be available on every machine.

**Usage:**

```bash
bash fish_setup.sh                     # install fish + configure auto-enter (default)
bash fish_setup.sh install             # install fish only
bash fish_setup.sh autostart           # configure auto-enter only
bash fish_setup.sh uninstall-autostart # remove the auto-enter block
```

Supported package managers: `apt-get`, `dnf`, `yum`, `apk`, `pacman`,
`zypper`, `brew`. `sudo` is used automatically when not running as root.

The auto-enter block in `~/.bashrc` is guarded so it:
- only runs for interactive shells,
- skips when the parent process is fish (no recursion),
- skips when `BASH_ENV_SETUP_NO_FISH` is set (escape hatch — e.g. `BASH_ENV_SETUP_NO_FISH=1 bash`),
- silently no-ops when fish is not on `PATH`.

### `git_prompt.sh`

A helper script that provides the Git status logic for the shell prompt. It is used by `env_setup.sh`.
