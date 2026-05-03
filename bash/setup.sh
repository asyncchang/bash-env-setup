#!/bin/bash

print_help() {
    cat <<EOF
Usage:
  source bash/setup.sh
  source bash/setup.sh [--help|-h]
  bash bash/setup.sh [--help|-h]

Description:
  Installs managed Bash environment and prompt configuration and writes managed Vim settings.

Behavior:
  - Copies git_prompt.sh to ~/.local/git_prompt.sh
  - Installs a managed env block in ~/.bashrc for PATH, EDITOR, VISUAL, and LS_COLORS
  - Installs a managed prompt block in ~/.bashrc with full path, git status, and right-side time
  - Writes managed Vim settings to ~/.vimrc
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        -h|--help|help)
            print_help
            exit 0
            ;;
    esac
    echo "Error: this script must be sourced."
    echo "Usage: source ${0}"
    exit 1
fi

BASH_ENV_BLOCK_START="# >>> shell-env bash-env >>>"
BASH_ENV_BLOCK_END="# <<< shell-env bash-env <<<"
LEGACY_BASH_ENV_BLOCK_START="# >>> bash-env-setup bash-env >>>"
LEGACY_BASH_ENV_BLOCK_END="# <<< bash-env-setup bash-env <<<"
LEGACY_PATH_BLOCK_START="# >>> bash-env-setup path >>>"
LEGACY_PATH_BLOCK_END="# <<< bash-env-setup path <<<"
PROMPT_BLOCK_START="# >>> shell-env bash-prompt >>>"
PROMPT_BLOCK_END="# <<< shell-env bash-prompt <<<"
LEGACY_PROMPT_BLOCK_START="# >>> bash-env-setup prompt >>>"
LEGACY_PROMPT_BLOCK_END="# <<< bash-env-setup prompt <<<"

remove_env_block() {
    local config_file="$1"

    sed -i "/${BASH_ENV_BLOCK_START}/,/${BASH_ENV_BLOCK_END}/d" "${config_file}"
    sed -i "/${LEGACY_BASH_ENV_BLOCK_START}/,/${LEGACY_BASH_ENV_BLOCK_END}/d" "${config_file}"
    sed -i "/${LEGACY_PATH_BLOCK_START}/,/${LEGACY_PATH_BLOCK_END}/d" "${config_file}"
}

write_env_block() {
    local config_file="$1"

    {
        echo "${BASH_ENV_BLOCK_START}"
        cat <<'EOF'
case ":${PATH}:" in
    *":${HOME}/.local/bin:"*) ;;
    *)
        export PATH="${HOME}/.local/bin${PATH:+:${PATH}}"
        ;;
esac

export EDITOR="vim"
export VISUAL="vim"

if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
fi

case ":${LS_COLORS:-}:" in
    *":di=1;38;5;51:ln=1;38;5;214:"*) ;;
    *)
        export LS_COLORS="${LS_COLORS:+${LS_COLORS}:}di=1;38;5;51:ln=1;38;5;214"
        ;;
esac
EOF
        echo "${BASH_ENV_BLOCK_END}"
    } >> "${config_file}"
}

remove_prompt_block() {
    local config_file="$1"

    sed -i "/${PROMPT_BLOCK_START}/,/${PROMPT_BLOCK_END}/d" "${config_file}"
    sed -i "/${LEGACY_PROMPT_BLOCK_START}/,/${LEGACY_PROMPT_BLOCK_END}/d" "${config_file}"
}

remove_legacy_prompt_config() {
    local config_file="$1"
    local prompt_file="$2"

    sed -i "\|source \"${prompt_file}\"|d" "${config_file}"
    sed -i '/^# set PS1$/d' "${config_file}"
    sed -i '/^GIT_PS1_SHOWDIRTYSTATE=/d' "${config_file}"
    sed -i '/^export GIT_PS1_SHOWDIRTYSTATE=/d' "${config_file}"
    sed -i '/^GIT_PS1_SHOWUNTRACKEDFILES=/d' "${config_file}"
    sed -i '/^export GIT_PS1_SHOWUNTRACKEDFILES=/d' "${config_file}"
    sed -i '/^PS1=.*__git_ps1/d' "${config_file}"
    sed -i '/^export PS1=.*__git_ps1/d' "${config_file}"
    sed -i '/^PROMPT_COMMAND=bash_env_setup_prompt_command$/d' "${config_file}"
    sed -i '/^PROMPT_COMMAND=shell_env_prompt_command$/d' "${config_file}"
}

write_prompt_block() {
    local config_file="$1"
    local prompt_file="$2"
    local host_token="$3"

    {
        echo "${PROMPT_BLOCK_START}"
        printf 'if [ -f %q ]; then\n' "${prompt_file}"
        printf '    source %q\n' "${prompt_file}"
        cat <<EOF
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1

    shell_env_prompt_command() {
        local last_status=\$?
        local chroot=""
        local title=""

        if [ -n "\${debian_chroot:-}" ]; then
            chroot="(\${debian_chroot}) "
        fi

        case "\$TERM" in
            xterm*|rxvt*)
                title='\\[\\e]0;\\u@${host_token}: \\w\\a\\]'
                ;;
        esac

        local user='\\[\\e[1;38;5;120m\\]\\u\\[\\e[0m\\]'
        local host='\\[\\e[1;38;5;201m\\]@${host_token}\\[\\e[0m\\]'
        local cwd='\\[\\e[1;38;5;51m\\]\\w\\[\\e[0m\\]'
        local git='\\[\\e[1;38;5;220m\\]'
        local time_color='\\[\\e[1;38;5;250m\\]'
        local reset='\\[\\e[0m\\]'
        local right_time
        local right_prompt

        right_time="\$(date +%H:%M:%S)"
        right_prompt="\\[\\e[s\\]\\[\\e[999C\\]\\[\\e[8D\\]\${time_color}\${right_time}\${reset}\\[\\e[u\\]"

        __git_ps1 "\${title}\${chroot}\${user}\${host} \${cwd}\${git}" "\${reset}\${right_prompt}\n\\\\\\$ "
        return \$last_status
    }

    case ";\${PROMPT_COMMAND:-};" in
        *";shell_env_prompt_command;"*) ;;
        *)
            PROMPT_COMMAND="shell_env_prompt_command\${PROMPT_COMMAND:+;\${PROMPT_COMMAND}}"
            ;;
    esac
fi
${PROMPT_BLOCK_END}
EOF
    } >> "${config_file}"
}

install_prompt() {
    local config_file="$1"
    local prompt_file="$2"
    local host_token="$3"

    remove_prompt_block "${config_file}"
    remove_legacy_prompt_config "${config_file}" "${prompt_file}"
    write_prompt_block "${config_file}" "${prompt_file}" "${host_token}"
    source "${config_file}"
}

install_env() {
    local config_file="$1"

    remove_env_block "${config_file}"
    write_env_block "${config_file}"
}

copy_git_prompt() {
    local source_dir="$1"
    local target_dir="$2"

    mkdir -p "${target_dir}"

    if [[ -f "${source_dir}/git_prompt.sh" ]]; then
        cp "${source_dir}/git_prompt.sh" "${target_dir}/git_prompt.sh"
        return 0
    fi

    echo "Warning: git_prompt.sh not found in ${source_dir}"
    return 1
}

main() {
    local mode="${1:-}"
    local script_dir local_dir prompt_file

    case "${mode}" in
        -h|--help|help)
            print_help
            return 0
            ;;
    esac

    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local_dir="$HOME/.local"
    prompt_file="${local_dir}/git_prompt.sh"

    copy_git_prompt "${script_dir}" "${local_dir}" || return 1

    touch "$HOME/.bashrc"
    install_env "$HOME/.bashrc"
    install_prompt "$HOME/.bashrc" "${prompt_file}" '\h'

    # shellcheck source=../vim_setup.sh
    source "${script_dir}/../vim_setup.sh"
    install_vim_config
}

main "$@"
