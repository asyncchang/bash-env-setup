#!/bin/bash

function main() {
    if ! command -v git &> /dev/null; then
        echo "Error: git is not installed."
        exit 1
    fi

    local vim_runtime="$HOME/.vim_runtime"

    if [ -d "$vim_runtime" ]; then
        echo "Updating existing vim_runtime..."
        cd "$vim_runtime" && git pull
    else
        echo "Cloning vim_runtime..."
        git clone --depth=1 https://github.com/amix/vimrc.git "$vim_runtime"
    fi

    sh "$vim_runtime/install_awesome_vimrc.sh"

    local my_configs="$vim_runtime/my_configs.vim"
    [ -f "$my_configs" ] && rm -f "$my_configs"

    cat << EOF >> "$my_configs"
set nu
set cursorline
set tabstop=4
set shiftwidth=4
set t_Co=256

" Color configuration
set background=dark
colorscheme elflord
hi LineNr cterm=bold ctermfg=DarkGrey ctermbg=NONE
hi CursorLineNr cterm=bold ctermfg=Green ctermbg=NONE
EOF

    echo "Vim setup complete."
}

main

