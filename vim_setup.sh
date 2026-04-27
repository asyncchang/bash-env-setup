#!/bin/bash

VIM_BLOCK_START="\" >>> bash-env-setup vim >>>"
VIM_BLOCK_END="\" <<< bash-env-setup vim <<<"

vim_print_help() {
    cat <<EOF
Usage:
  bash vim_setup.sh [--help|-h]
  source vim_setup.sh   # to expose install_vim_config in current shell

Description:
  Writes a managed Vim settings block to ~/.vimrc. Shell-independent;
  used by both bash_setup.sh and fish_setup.sh.
EOF
}

remove_vim_block() {
    local config_file="$1"

    [[ -f "${config_file}" ]] || return 0
    sed -i "/${VIM_BLOCK_START}/,/${VIM_BLOCK_END}/d" "${config_file}"
}

write_vim_block() {
    local config_file="$1"

    touch "${config_file}"

    {
        echo "${VIM_BLOCK_START}"
        cat <<'EOF'
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
        echo "${VIM_BLOCK_END}"
    } >> "${config_file}"
}

install_vim_config() {
    local vimrc

    vimrc="$HOME/.vimrc"

    remove_vim_block "${vimrc}"
    write_vim_block "${vimrc}"
    echo "vim block installed in ${vimrc}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        -h|--help|help)
            vim_print_help
            exit 0
            ;;
        "")
            install_vim_config
            ;;
        *)
            echo "Error: unknown mode '${1}'" >&2
            vim_print_help >&2
            exit 1
            ;;
    esac
fi
