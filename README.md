# Shell Env

This directory contains scripts to configure Bash, Fish, Nushell, and Vim.

## Layout

- `bash/setup.sh`: Bash environment, prompt, and Vim setup.
- `bash/git_prompt.sh`: Git prompt helper used by Bash.
- `fish/setup.sh`: Fish installation, environment, prompt, colors, and Vim setup.
- `nushell/setup.sh`: Nushell installation, environment, prompt, and Vim setup.
- `vim_setup.sh`: shared Vim settings writer used by all shell setup scripts.

Each shell setup aligns these environment variables:

- `PATH`: prepends `~/.local/bin` when it is not already present.
- `EDITOR`: set to `vim`.
- `VISUAL`: set to `vim`.
- `LS_COLORS`: uses `dircolors` when available, then sets directories to teal and symlinks to orange for dark terminals.

All shell setup scripts write the same managed Vim settings block to `~/.vimrc`.

## Activate Changes

After running a setup script, you can activate the new shell settings in the
current terminal without opening a new one:

```bash
source ~/.bashrc
```

```fish
source ~/.config/fish/config.fish
```

```nu
source ~/.config/nushell/env.nu
```

For Vim settings, reopen Vim or run `:source ~/.vimrc` inside Vim.

## Bash

Configures Bash with a managed environment block, a prompt that shows the full path, Git status, and right-side time, plus Vim settings.

**Usage:**

This script **must be sourced** to work correctly.

```bash
source bash/setup.sh
```

This will:
1. Copy `bash/git_prompt.sh` to `~/.local/git_prompt.sh`.
2. Install a managed environment block in `~/.bashrc`.
3. Install a managed prompt block in `~/.bashrc`.
4. Source `vim_setup.sh` to write managed Vim settings to `~/.vimrc`.
5. Reload the configuration in the current shell.

## Fish

Installs [fish](https://fishshell.com/) and can write managed environment, prompt, color, and Vim configuration blocks. The prompt shows the full path, Git status, and right-side time.

```bash
bash fish/setup.sh                     # install fish + env + prompt + colors + vim (default)
bash fish/setup.sh install             # install fish only
bash fish/setup.sh env                 # install env block only
bash fish/setup.sh path                # alias for env
bash fish/setup.sh prompt              # install prompt block only
bash fish/setup.sh colors              # install color overrides only
bash fish/setup.sh vim                 # install vim block only
bash fish/setup.sh uninstall-env       # remove the env block
bash fish/setup.sh uninstall-path      # alias for uninstall-env
bash fish/setup.sh uninstall-prompt    # remove the prompt block
bash fish/setup.sh uninstall-colors    # remove the color block
```

Fish config is written to `~/.config/fish/config.fish`.

## Nushell

Installs [Nushell](https://www.nushell.sh/) and can write managed environment, prompt, and Vim configuration. The prompt shows the full path, Git status, and right-side time.

```bash
bash nushell/setup.sh                  # install nushell + env + prompt + vim (default)
bash nushell/setup.sh install          # install nushell only
bash nushell/setup.sh env              # install env block only
bash nushell/setup.sh prompt           # install prompt block only
bash nushell/setup.sh vim              # install vim block only
bash nushell/setup.sh uninstall-env    # remove the env block
bash nushell/setup.sh uninstall-prompt # remove the prompt block
```

Nushell env config is written to `~/.config/nushell/env.nu`; prompt config is written to `~/.config/nushell/config.nu`.

## Vim

Writes a managed Vim settings block to `~/.vimrc`. Shell-independent;
sourced by all shell setup scripts so a Vim config is installed regardless
of which setup script you run.

**Usage:**

```bash
bash vim_setup.sh           # write the vim block standalone
source vim_setup.sh         # expose install_vim_config in the current shell
```

Supported package managers: `apt-get`, `dnf`, `yum`, `apk`, `pacman`,
`zypper`, `brew`. `sudo` is used automatically when not running as root.
