#!/bin/bash

main() {
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git is not installed."
        exit 1
    fi

    local vim_runtime my_configs
    vim_runtime="$HOME/.vim_runtime"

    if [ -d "$vim_runtime" ]; then
        echo "Updating existing vim_runtime..."
        git -C "$vim_runtime" pull
    else
        echo "Cloning vim_runtime..."
        git clone --depth=1 https://github.com/amix/vimrc.git "$vim_runtime"
    fi

    sh "$vim_runtime/install_awesome_vimrc.sh"

    my_configs="$vim_runtime/my_configs.vim"

    cat <<EOF > "$my_configs"
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
