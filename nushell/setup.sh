#!/bin/bash

set -e

NUSHELL_ENV_BLOCK_START="# >>> shell-env nushell-env >>>"
NUSHELL_ENV_BLOCK_END="# <<< shell-env nushell-env <<<"
LEGACY_NUSHELL_ENV_BLOCK_START="# >>> bash-env-setup nushell-env >>>"
LEGACY_NUSHELL_ENV_BLOCK_END="# <<< bash-env-setup nushell-env <<<"

print_help() {
    cat <<EOF
Usage:
  bash nushell/setup.sh                # install nushell + env + vim
  bash nushell/setup.sh install        # install nushell only
  bash nushell/setup.sh env            # install Nushell env block only
  bash nushell/setup.sh vim            # install vim config only
  bash nushell/setup.sh uninstall-env  # remove the env block
  bash nushell/setup.sh [--help|-h]

Description:
  Installs Nushell plus optional env and Vim configuration.

Supported package managers:
  apt-get, dnf, yum, apk, pacman, zypper, brew

Env behavior:
  Adds a managed block to ~/.config/nushell/env.nu that prepends
  ~/.local/bin when it is not already present in PATH, sets EDITOR and
  VISUAL to vim, and sets LS_COLORS.
EOF
}

install_nushell() {
    if command -v nu >/dev/null 2>&1; then
        echo "nushell already installed: $(command -v nu) ($(nu --version 2>/dev/null))"
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
        echo "Installing nushell via apt-get..."
        $sudo apt-get update
        $sudo apt-get install -y nushell
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing nushell via dnf..."
        $sudo dnf install -y nushell
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing nushell via yum..."
        $sudo yum install -y nushell
    elif command -v apk >/dev/null 2>&1; then
        echo "Installing nushell via apk..."
        $sudo apk add nushell
    elif command -v pacman >/dev/null 2>&1; then
        echo "Installing nushell via pacman..."
        $sudo pacman -Sy --noconfirm nushell
    elif command -v zypper >/dev/null 2>&1; then
        echo "Installing nushell via zypper..."
        $sudo zypper install -y nushell
    elif command -v brew >/dev/null 2>&1; then
        echo "Installing nushell via brew..."
        brew install nushell
    else
        echo "Error: no supported package manager found (apt-get, dnf, yum, apk, pacman, zypper, brew)." >&2
        return 1
    fi

    if ! command -v nu >/dev/null 2>&1; then
        echo "Error: nushell installation completed but 'nu' is not on PATH." >&2
        return 1
    fi

    echo "nushell installed: $(command -v nu) ($(nu --version 2>/dev/null))"
}

remove_nushell_env_block() {
    local config_file="$1"

    [[ -f "${config_file}" ]] || return 0
    sed -i "/${NUSHELL_ENV_BLOCK_START}/,/${NUSHELL_ENV_BLOCK_END}/d" "${config_file}"
    sed -i "/${LEGACY_NUSHELL_ENV_BLOCK_START}/,/${LEGACY_NUSHELL_ENV_BLOCK_END}/d" "${config_file}"
}

write_nushell_env_block() {
    local config_file="$1"

    {
        echo "${NUSHELL_ENV_BLOCK_START}"
        cat <<'EOF'
let shell_env_local_bin = ($env.HOME | path join ".local" "bin")
let shell_env_path = ($env.PATH? | default [])

if not ($shell_env_path | any {|entry| $entry == $shell_env_local_bin }) {
    $env.PATH = ($shell_env_path | prepend $shell_env_local_bin)
}

$env.EDITOR = "vim"
$env.VISUAL = "vim"

if (which dircolors | is-not-empty) {
    let shell_env_dircolors = (dircolors -b | lines | first | parse "LS_COLORS='{value}';")
    if ($shell_env_dircolors | is-not-empty) {
        $env.LS_COLORS = ($shell_env_dircolors | get value | first)
    }
}

let shell_env_ls_colors_suffix = "di=38;5;37:ln=38;5;215"
let shell_env_ls_colors = ($env.LS_COLORS? | default "")

if not ($shell_env_ls_colors | str contains $shell_env_ls_colors_suffix) {
    $env.LS_COLORS = if ($shell_env_ls_colors | is-empty) {
        $shell_env_ls_colors_suffix
    } else {
        $"($shell_env_ls_colors):($shell_env_ls_colors_suffix)"
    }
}
EOF
        echo "${NUSHELL_ENV_BLOCK_END}"
    } >> "${config_file}"
}

install_nushell_env() {
    local config_dir="$HOME/.config/nushell"
    local config_file="${config_dir}/env.nu"

    mkdir -p "${config_dir}"
    touch "${config_file}"
    remove_nushell_env_block "${config_file}"
    write_nushell_env_block "${config_file}"
    echo "nushell env block installed in ${config_file}"
}

uninstall_nushell_env() {
    local config_file="$HOME/.config/nushell/env.nu"

    remove_nushell_env_block "${config_file}"
    echo "nushell env block removed from ${config_file}"
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
            install_nushell
            ;;
        env)
            install_nushell_env
            ;;
        vim)
            install_vim
            ;;
        uninstall-env)
            uninstall_nushell_env
            ;;
        all|"")
            install_nushell
            install_nushell_env
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
