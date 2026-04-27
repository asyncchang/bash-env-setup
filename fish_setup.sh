#!/bin/bash

set -e

FISH_BLOCK_START="# >>> bash-env-setup fish-autostart >>>"
FISH_BLOCK_END="# <<< bash-env-setup fish-autostart <<<"
FISH_PROMPT_BLOCK_START="# >>> bash-env-setup fish-prompt >>>"
FISH_PROMPT_BLOCK_END="# <<< bash-env-setup fish-prompt <<<"
FISH_COLORS_BLOCK_START="# >>> bash-env-setup fish-colors >>>"
FISH_COLORS_BLOCK_END="# <<< bash-env-setup fish-colors <<<"

print_help() {
    cat <<EOF
Usage:
  bash fish_setup.sh                # install fish + auto-enter + prompt + colors
  bash fish_setup.sh install        # install fish only
  bash fish_setup.sh autostart      # configure auto-enter only
  bash fish_setup.sh prompt         # install fish prompt config only
  bash fish_setup.sh colors         # install fish color overrides only
  bash fish_setup.sh uninstall-autostart
                                    # remove the auto-enter block from ~/.bashrc
  bash fish_setup.sh uninstall-prompt
                                    # remove the prompt block from ~/.config/fish/config.fish
  bash fish_setup.sh uninstall-colors
                                    # remove the color block from ~/.config/fish/config.fish
  bash fish_setup.sh [--help|-h]

Description:
  Installs the fish shell and configures interactive bash sessions to
  drop straight into fish. Both pieces are intentionally isolated from
  env_setup.sh, since fish may not be available on every machine.

Supported package managers:
  apt-get, dnf, yum, apk, pacman, zypper, brew

Auto-enter behavior:
  Adds a managed block to ~/.bashrc that exec's fish for new
  interactive shells. Skipped when:
    - shell is non-interactive
    - parent process is fish (avoids recursion)
    - BASH_ENV_SETUP_NO_FISH is set (escape hatch)
    - fish is not on PATH

Prompt behavior:
  Adds a managed block to ~/.config/fish/config.fish that defines
  fish_prompt to show user@host, the full \$PWD, git status, and
  puts the input on a new line.

Color behavior:
  Adds a managed block to ~/.config/fish/config.fish that overrides
  fish's blue/cyan-leaning syntax-highlighting and pager defaults so
  text stays readable on dark backgrounds (e.g. WSL Ubuntu's theme).
  Also overwrites LS_COLORS to match env_setup.sh: regenerates the
  base map via dircolors then sets directories teal and symlinks
  orange so they're distinguishable on dark backgrounds.
EOF
}

install_fish() {
    if command -v fish >/dev/null 2>&1; then
        echo "fish already installed: $(command -v fish) ($(fish --version 2>/dev/null))"
        return 0
    fi

    local sudo=""
    if [[ $EUID -ne 0 ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo="sudo"
        else
            echo "Error: not running as root and sudo is not available." >&2
            return 1
        fi
    fi

    if command -v apt-get >/dev/null 2>&1; then
        echo "Installing fish via apt-get..."
        $sudo apt-get update
        $sudo apt-get install -y fish
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing fish via dnf..."
        $sudo dnf install -y fish
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing fish via yum..."
        $sudo yum install -y fish
    elif command -v apk >/dev/null 2>&1; then
        echo "Installing fish via apk..."
        $sudo apk add fish
    elif command -v pacman >/dev/null 2>&1; then
        echo "Installing fish via pacman..."
        $sudo pacman -Sy --noconfirm fish
    elif command -v zypper >/dev/null 2>&1; then
        echo "Installing fish via zypper..."
        $sudo zypper install -y fish
    elif command -v brew >/dev/null 2>&1; then
        echo "Installing fish via brew..."
        brew install fish
    else
        echo "Error: no supported package manager found (apt-get, dnf, yum, apk, pacman, zypper, brew)." >&2
        return 1
    fi

    if ! command -v fish >/dev/null 2>&1; then
        echo "Error: fish installation completed but 'fish' is not on PATH." >&2
        return 1
    fi

    echo "fish installed: $(command -v fish) ($(fish --version 2>/dev/null))"
}

remove_fish_block() {
    local config_file="$1"

    [[ -f "${config_file}" ]] || return 0
    sed -i "/${FISH_BLOCK_START}/,/${FISH_BLOCK_END}/d" "${config_file}"
}

write_fish_block() {
    local config_file="$1"

    {
        echo
        echo "${FISH_BLOCK_START}"
        cat <<'EOF'
# Auto-exec fish for interactive shells. Skips when:
#  - shell is non-interactive
#  - already inside fish (parent is fish)
#  - BASH_ENV_SETUP_NO_FISH is set (escape hatch)
#  - fish isn't installed
if [[ $- == *i* ]] \
    && [[ -z "$BASH_ENV_SETUP_NO_FISH" ]] \
    && command -v fish >/dev/null 2>&1; then
    case "$(ps -o comm= -p "$PPID" 2>/dev/null)" in
        fish|*/fish) ;;
        *) exec fish ;;
    esac
fi
EOF
        echo "${FISH_BLOCK_END}"
    } >> "${config_file}"
}

install_autostart() {
    local config_file="$HOME/.bashrc"

    touch "${config_file}"
    remove_fish_block "${config_file}"
    write_fish_block "${config_file}"
    echo "fish auto-enter block installed in ${config_file}"
    echo "Open a new interactive shell to drop into fish."
    echo "Bypass with: BASH_ENV_SETUP_NO_FISH=1 bash"
}

uninstall_autostart() {
    local config_file="$HOME/.bashrc"

    remove_fish_block "${config_file}"
    echo "fish auto-enter block removed from ${config_file}"
}

remove_fish_prompt_block() {
    local config_file="$1"

    [[ -f "${config_file}" ]] || return 0
    sed -i "/${FISH_PROMPT_BLOCK_START}/,/${FISH_PROMPT_BLOCK_END}/d" "${config_file}"
}

write_fish_prompt_block() {
    local config_file="$1"

    {
        echo
        echo "${FISH_PROMPT_BLOCK_START}"
        cat <<'EOF'
# Mirror fish's default fish_prompt but show the full $PWD and put the
# input on a new line. Keeps the default colors, user@host layout, and
# vcs/status segments untouched.
function fish_prompt --description 'bash-env-setup: default prompt + full path + newline'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status

    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (prompt_hostname)
    end

    set -l color_cwd
    set -l suffix
    switch "$USER"
        case root toor
            if set -q fish_color_cwd_root
                set color_cwd $fish_color_cwd_root
            else
                set color_cwd $fish_color_cwd
            end
            set suffix '#'
        case '*'
            set color_cwd $fish_color_cwd
            set suffix '>'
    end

    set -l prompt_status (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

    echo -n -s (set_color $fish_color_user) "$USER" (set_color normal) @ (set_color $fish_color_host) $__fish_prompt_hostname (set_color normal) ' ' (set_color $color_cwd) $PWD (set_color normal) (fish_vcs_prompt) $prompt_status
    echo
    echo -n "$suffix "
end
EOF
        echo "${FISH_PROMPT_BLOCK_END}"
    } >> "${config_file}"
}

install_fish_prompt() {
    local config_dir="$HOME/.config/fish"
    local config_file="${config_dir}/config.fish"

    mkdir -p "${config_dir}"
    touch "${config_file}"
    remove_fish_prompt_block "${config_file}"
    write_fish_prompt_block "${config_file}"
    echo "fish prompt block installed in ${config_file}"
}

uninstall_fish_prompt() {
    local config_file="$HOME/.config/fish/config.fish"

    remove_fish_prompt_block "${config_file}"
    echo "fish prompt block removed from ${config_file}"
}

remove_fish_colors_block() {
    local config_file="$1"

    [[ -f "${config_file}" ]] || return 0
    sed -i "/${FISH_COLORS_BLOCK_START}/,/${FISH_COLORS_BLOCK_END}/d" "${config_file}"
}

write_fish_colors_block() {
    local config_file="$1"

    {
        echo
        echo "${FISH_COLORS_BLOCK_START}"
        cat <<'EOF'
# Override fish's default syntax-highlighting and pager colors that
# lean blue/cyan, since dark blue is hard to read on WSL Ubuntu's
# default theme. Picks colors that stay legible on dark backgrounds.
set -g fish_color_command green
set -g fish_color_keyword green
set -g fish_color_param normal
set -g fish_color_redirection yellow
set -g fish_color_operator yellow
set -g fish_color_escape brmagenta
set -g fish_color_autosuggestion brblack
set -g fish_color_selection white --bold --background=brblack
set -g fish_color_search_match bryellow --background=brblack
set -g fish_pager_color_prefix brgreen --bold
set -g fish_pager_color_progress brwhite --background=brblack
set -g fish_pager_color_selected_background --background=brblack

# Mirror env_setup.sh's bash prompt block: regenerate LS_COLORS via
# dircolors then set directories teal and symlinks orange.
if type -q dircolors
    set -gx LS_COLORS (dircolors -c | string replace -r "^setenv LS_COLORS '(.*)'\$" '$1')
end
set -gx LS_COLORS "$LS_COLORS:di=38;5;37:ln=38;5;215"
EOF
        echo "${FISH_COLORS_BLOCK_END}"
    } >> "${config_file}"
}

install_fish_colors() {
    local config_dir="$HOME/.config/fish"
    local config_file="${config_dir}/config.fish"

    mkdir -p "${config_dir}"
    touch "${config_file}"
    remove_fish_colors_block "${config_file}"
    write_fish_colors_block "${config_file}"
    echo "fish color block installed in ${config_file}"
}

uninstall_fish_colors() {
    local config_file="$HOME/.config/fish/config.fish"

    remove_fish_colors_block "${config_file}"
    echo "fish color block removed from ${config_file}"
}

main() {
    local mode="${1:-all}"

    case "${mode}" in
        -h|--help|help)
            print_help
            ;;
        install)
            install_fish
            ;;
        autostart)
            install_autostart
            ;;
        prompt)
            install_fish_prompt
            ;;
        colors)
            install_fish_colors
            ;;
        uninstall-autostart)
            uninstall_autostart
            ;;
        uninstall-prompt)
            uninstall_fish_prompt
            ;;
        uninstall-colors)
            uninstall_fish_colors
            ;;
        all|"")
            install_fish
            install_autostart
            install_fish_prompt
            install_fish_colors
            ;;
        *)
            echo "Error: unknown mode '${mode}'" >&2
            print_help >&2
            exit 1
            ;;
    esac
}

main "$@"
