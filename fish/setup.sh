#!/bin/bash

set -e

FISH_ENV_BLOCK_START="# >>> shell-env fish-env >>>"
FISH_ENV_BLOCK_END="# <<< shell-env fish-env <<<"
LEGACY_FISH_ENV_BLOCK_START="# >>> bash-env-setup fish-env >>>"
LEGACY_FISH_ENV_BLOCK_END="# <<< bash-env-setup fish-env <<<"
LEGACY_FISH_PATH_BLOCK_START="# >>> bash-env-setup fish-path >>>"
LEGACY_FISH_PATH_BLOCK_END="# <<< bash-env-setup fish-path <<<"
FISH_PROMPT_BLOCK_START="# >>> shell-env fish-prompt >>>"
FISH_PROMPT_BLOCK_END="# <<< shell-env fish-prompt <<<"
LEGACY_FISH_PROMPT_BLOCK_START="# >>> bash-env-setup fish-prompt >>>"
LEGACY_FISH_PROMPT_BLOCK_END="# <<< bash-env-setup fish-prompt <<<"
FISH_COLORS_BLOCK_START="# >>> shell-env fish-colors >>>"
FISH_COLORS_BLOCK_END="# <<< shell-env fish-colors <<<"
LEGACY_FISH_COLORS_BLOCK_START="# >>> bash-env-setup fish-colors >>>"
LEGACY_FISH_COLORS_BLOCK_END="# <<< bash-env-setup fish-colors <<<"

print_help() {
    cat <<EOF
Usage:
  bash fish/setup.sh                # install fish + env + prompt + colors + vim
  bash fish/setup.sh install        # install fish only
  bash fish/setup.sh env            # install fish env block only
  bash fish/setup.sh path           # alias for env
  bash fish/setup.sh prompt         # install fish prompt config only
  bash fish/setup.sh colors         # install fish color overrides only
  bash fish/setup.sh vim            # install vim config only
  bash fish/setup.sh uninstall-env  # remove the env block
  bash fish/setup.sh uninstall-path # alias for uninstall-env
  bash fish/setup.sh uninstall-prompt
  bash fish/setup.sh uninstall-colors
  bash fish/setup.sh [--help|-h]

Description:
  Installs the fish shell plus optional env, prompt, color, and vim config.

Supported package managers:
  apt-get, dnf, yum, apk, pacman, zypper, brew

Env behavior:
  Adds a managed block to ~/.config/fish/config.fish that prepends
  ~/.local/bin when it is not already present in PATH, sets EDITOR and
  VISUAL to vim, and sets LS_COLORS.

Prompt behavior:
  Adds a managed block to ~/.config/fish/config.fish that defines
  fish_prompt to show user@host, the full \$PWD, git status, and
  puts the input on a new line, with the current time on the right.

Color behavior:
  Adds a managed block to ~/.config/fish/config.fish that overrides
  fish's blue/cyan-leaning syntax-highlighting and pager defaults so
  text stays readable on dark backgrounds (e.g. WSL Ubuntu's theme).
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

remove_fish_prompt_block() {
    local config_file="$1"

    [[ -f "${config_file}" ]] || return 0
    sed -i "/${FISH_PROMPT_BLOCK_START}/,/${FISH_PROMPT_BLOCK_END}/d" "${config_file}"
    sed -i "/${LEGACY_FISH_PROMPT_BLOCK_START}/,/${LEGACY_FISH_PROMPT_BLOCK_END}/d" "${config_file}"
}

remove_fish_env_block() {
    local config_file="$1"

    [[ -f "${config_file}" ]] || return 0
    sed -i "/${FISH_ENV_BLOCK_START}/,/${FISH_ENV_BLOCK_END}/d" "${config_file}"
    sed -i "/${LEGACY_FISH_ENV_BLOCK_START}/,/${LEGACY_FISH_ENV_BLOCK_END}/d" "${config_file}"
    sed -i "/${LEGACY_FISH_PATH_BLOCK_START}/,/${LEGACY_FISH_PATH_BLOCK_END}/d" "${config_file}"
}

write_fish_env_block() {
    local config_file="$1"

    {
        echo "${FISH_ENV_BLOCK_START}"
        cat <<'EOF'
if not contains -- "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

set -gx EDITOR vim
set -gx VISUAL vim

if type -q dircolors
    set -gx LS_COLORS (dircolors -c | string replace -r "^setenv LS_COLORS '(.*)'\$" '$1')
end

set -l shell_env_ls_colors_suffix "di=38;5;37:ln=38;5;215"
if not string match -q "*$shell_env_ls_colors_suffix*" "$LS_COLORS"
    if test -n "$LS_COLORS"
        set -gx LS_COLORS "$LS_COLORS:$shell_env_ls_colors_suffix"
    else
        set -gx LS_COLORS "$shell_env_ls_colors_suffix"
    end
end
EOF
        echo "${FISH_ENV_BLOCK_END}"
    } >> "${config_file}"
}

install_fish_env() {
    local config_dir="$HOME/.config/fish"
    local config_file="${config_dir}/config.fish"

    mkdir -p "${config_dir}"
    touch "${config_file}"
    remove_fish_env_block "${config_file}"
    write_fish_env_block "${config_file}"
    echo "fish env block installed in ${config_file}"
}

uninstall_fish_env() {
    local config_file="$HOME/.config/fish/config.fish"

    remove_fish_env_block "${config_file}"
    echo "fish env block removed from ${config_file}"
}

write_fish_prompt_block() {
    local config_file="$1"

    {
        echo "${FISH_PROMPT_BLOCK_START}"
        cat <<'EOF'
# Mirror fish's default fish_prompt but show the full $PWD, put the
# input on a new line, and show the current time on the right.
# Keeps the default colors, user@host layout, and vcs/status segments untouched.
function fish_prompt --description 'shell-env: default prompt + full path + newline'
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

function fish_right_prompt --description 'shell-env: current time'
    echo -n (date '+%H:%M:%S')
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
    sed -i "/${LEGACY_FISH_COLORS_BLOCK_START}/,/${LEGACY_FISH_COLORS_BLOCK_END}/d" "${config_file}"
}

write_fish_colors_block() {
    local config_file="$1"

    {
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

install_vim() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=../vim_setup.sh
    source "${script_dir}/../vim_setup.sh"
    install_vim_config
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
        env|path)
            install_fish_env
            ;;
        prompt)
            install_fish_prompt
            ;;
        colors)
            install_fish_colors
            ;;
        vim)
            install_vim
            ;;
        uninstall-env|uninstall-path)
            uninstall_fish_env
            ;;
        uninstall-prompt)
            uninstall_fish_prompt
            ;;
        uninstall-colors)
            uninstall_fish_colors
            ;;
        all|"")
            install_fish
            install_fish_env
            install_fish_prompt
            install_fish_colors
            install_vim
            ;;
        *)
            echo "Error: unknown mode '${mode}'" >&2
            print_help >&2
            exit 1
            ;;
    esac
}

main "$@"
