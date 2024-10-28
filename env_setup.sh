#!/bin/bash

function setup_git_prompt() {
    local config_file="$1"
    local local_dir="$2"

    # Only add git prompt configuration if it's not already present
    if ! grep -q "source \"${local_dir}/git_prompt.sh\"" "${config_file}"; then
        {
            echo "source \"${local_dir}/git_prompt.sh\""
        } >> "${config_file}"
    fi

    {
        echo "# set PS1"
        echo "GIT_PS1_SHOWDIRTYSTATE=1"
        echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[1;32m\]\u@\h\[\033[00m\] \[\033[1;34m\]\w \[\033[1;33m\]\$(__git_ps1 \"(%s)\")\[\033[00m\]\n\$ '"
    } >> "${config_file}"

    source "${config_file}"
}

function setup_vim_config() {
    [ -f "$HOME/.vimrc" ] && rm -f "$HOME/.vimrc"
    touch "$HOME/.vimrc"
    cat << 'EOF' >> "$HOME/.vimrc"
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
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 
        exit 1
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
    # Create local directory if it doesn't exist
    [ -d "${local_dir}" ] || mkdir -p "${local_dir}"
    [ -f "${local_dir}/git_prompt.sh" ] && rm -f "${local_dir}/git_prompt.sh"
    cp git_prompt.sh "${local_dir}"

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
