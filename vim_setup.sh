#!/bin/bash

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

[ -f ~/.vim_runtime/my_configs.vim ] && \
rm ~/.vim_runtime/my_configs.vim

cat << EOF >> $HOME/.vim_runtime/my_configs.vim
set nu
set cursorline
set tabstop=4
set shiftwidth=4
set t_Co=256

" Color configuration
set background=dark
hi LineNr cterm=bold ctermfg=DarkGrey ctermbg=NONE
hi CursorLineNr cterm=bold ctermfg=Green ctermbg=NONE
EOF

