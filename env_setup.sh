#!/bin/bash

# Ensure the script is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script must be sourced."
    echo "Usage: source ${0} [mode]"
    exit 1
fi

function setup_git_prompt() {
    local config_file="$1"
    local local_dir="$2"

    # Only add git prompt configuration if it's not already present
    if ! grep -q "source \"${local_dir}/git_prompt.sh\"" "${config_file}"; then
        {
            echo
            echo "source \"${local_dir}/git_prompt.sh\""
        } >> "${config_file}"
    fi

    if ! grep -q "GIT_PS1_SHOWDIRTYSTATE" "${config_file}"; then
        {
            echo "# set PS1"
            echo "GIT_PS1_SHOWDIRTYSTATE=1"
            echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[1;32m\]\u@\h\[\033[00m\] \[\033[1;34m\]\w \[\033[1;33m\]\$(__git_ps1 \"(%s)\")\[\033[00m\]\n\$ '"
        } >> "${config_file}"
    fi

    source "${config_file}"
}

function setup_vim_config() {
    local vimrc="$HOME/.vimrc"
    [ -f "$vimrc" ] && rm -f "$vimrc"
    touch "$vimrc"
    cat << 'EOF' >> "$vimrc"
set nu
set cursorline
set tabstop=4
set shiftwidth=4
set t_Co=256

" Color configuration
set background=dark
hi LineNr cterm=bold ctermfg=Gray ctermbg=NONE
hi CursorLineNr cterm=bold ctermfg=Green ctermbg=NONE

highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
EOF
}

function setup_alibaba_config() {
    local local_dir="$1"
    if [[ $EUID -ne 0 ]]; then
        echo "Error: Alibaba configuration must be run as root." 
        return 1
    fi

    local config_file="/etc/profile.d/alibaba_bashenv.sh"

    if ! grep -q "source \"${local_dir}/git_prompt.sh\"" "${config_file}"; then
        {
            echo "source \"${local_dir}/git_prompt.sh\""
        } >> "${config_file}"
    fi

    sed -i '/PS1/d' "${config_file}"
    {
        echo "# set PS1"
        echo "export GIT_PS1_SHOWDIRTYSTATE=1"
        echo "export PS1='\[\e[1;37m\][\[\e[m\]\[\e[1;32m\]\u\[\e[m\]\[\e[1;33m\]@\[\e[m\]\[\e[1;35m\]\H\[\e[m\] \[\e[4m\]\w\[\e[m\]\[\e[1;37m\]]\[\e[m\] \[\e[1;33m\]\$(__git_ps1 \"(%s)\")\[\e[m\]\n\$ '"
    } >> "${config_file}"

    source "${config_file}"
}

function main() {
    # Parse command line arguments
    local mode="$1"

    # Determine config file location
    local config_file
    if [[ -f "$HOME/.bash_profile" ]]; then
        config_file="$HOME/.bash_profile"
    else
        config_file="$HOME/.bashrc"
    fi

    local local_dir="$HOME/.local"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create local directory if it doesn't exist
    [ -d "${local_dir}" ] || mkdir -p "${local_dir}"
    
    # Copy git_prompt.sh if it exists in the script directory
    if [[ -f "${script_dir}/git_prompt.sh" ]]; then
        cp "${script_dir}/git_prompt.sh" "${local_dir}/git_prompt.sh"
    else
        echo "Warning: git_prompt.sh not found in ${script_dir}"
    fi

    echo "mode=$mode"
    if [[ "$mode" == "ali" ]]; then
        echo "Alibaba configuration"
        setup_alibaba_config "$local_dir"
    else
        echo "Default configuration"
        setup_git_prompt "$config_file" "$local_dir"
    fi
    setup_vim_config
}

main "$@"
