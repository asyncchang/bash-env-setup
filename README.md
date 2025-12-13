# Environment Setup Scripts

This directory contains scripts to configure your development environment, including Git prompt integration and Vim configuration.

## Scripts

### `env_setup.sh`

Configures the shell environment (Bash) to include a Git-aware prompt and sets up a basic Vim configuration.

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
  2. Append sourcing logic to your `.bash_profile` or `.bashrc`.
  3. configure a basic `~/.vimrc`.
  4. Reload the configuration in the current shell.

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

### `git_prompt.sh`

A helper script that provides the Git status logic for the shell prompt. It is used by `env_setup.sh`.
