#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: this script must be sourced."
    echo "Usage: source ${0} [mode]"
    exit 1
fi

PROMPT_BLOCK_START="# >>> bash-env-setup prompt >>>"
PROMPT_BLOCK_END="# <<< bash-env-setup prompt <<<"

remove_prompt_block() {
    local config_file="$1"

    sed -i "/${PROMPT_BLOCK_START}/,/${PROMPT_BLOCK_END}/d" "${config_file}"
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
}

write_prompt_block() {
    local config_file="$1"
    local prompt_file="$2"
    local host_token="$3"

    {
        echo
        echo "${PROMPT_BLOCK_START}"
        printf 'if [ -f %q ]; then\n' "${prompt_file}"
        printf '    source %q\n' "${prompt_file}"
        cat <<EOF
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1

    bash_env_setup_prompt_command() {
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

        local user_host='\\[\\e[1;32m\\]\\u@${host_token}\\[\\e[0m\\]'
        local cwd='\\[\\e[1;34m\\]\\w\\[\\e[0m\\]'
        local git='\\[\\e[1;33m\\]'
        local reset='\\[\\e[0m\\]'

        __git_ps1 "\${title}\${chroot}\${user_host} \${cwd} \${git}" "\${reset}\n\\\\\\$ "
        return \$last_status
    }

    case ";\${PROMPT_COMMAND:-};" in
        *";bash_env_setup_prompt_command;"*) ;;
        *)
            PROMPT_COMMAND="bash_env_setup_prompt_command\${PROMPT_COMMAND:+;\${PROMPT_COMMAND}}"
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
    local mode="$1"
    local script_dir local_dir prompt_file

    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local_dir="$HOME/.local"
    prompt_file="${local_dir}/git_prompt.sh"

    copy_git_prompt "${script_dir}" "${local_dir}" || return 1

    if [[ "${mode}" == "ali" ]]; then
        if [[ ${EUID} -ne 0 ]]; then
            echo "Error: Alibaba configuration must be run as root."
            return 1
        fi
        install_prompt "/etc/profile.d/alibaba_bashenv.sh" "${prompt_file}" '\H'
        return 0
    fi

    touch "$HOME/.bashrc"
    install_prompt "$HOME/.bashrc" "${prompt_file}" '\h'
}

main "$@"
