#!/bin/bash

set -e

FISH_BLOCK_START="# >>> bash-env-setup fish-autostart >>>"
FISH_BLOCK_END="# <<< bash-env-setup fish-autostart <<<"

print_help() {
    cat <<EOF
Usage:
  bash fish_setup.sh                # install fish + configure auto-enter
  bash fish_setup.sh install        # install fish only
  bash fish_setup.sh autostart      # configure auto-enter only
  bash fish_setup.sh uninstall-autostart
                                    # remove the auto-enter block from ~/.bashrc
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
        uninstall-autostart)
            uninstall_autostart
            ;;
        all|"")
            install_fish
            install_autostart
            ;;
        *)
            echo "Error: unknown mode '${mode}'" >&2
            print_help >&2
            exit 1
            ;;
    esac
}

main "$@"
