#!/bin/bash

#git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
#sh ~/.vim_runtime/install_awesome_vimrc.sh

#[ -f ~/.vim_runtime/my_configs.vim ] && \
#rm ~/.vim_runtime/my_configs.vim

#cat << EOF >> $HOME/.vim_runtime/my_configs.vim
[ -f $HOME/.vimrc ] && rm -f $HOME/.vimrc
cat << EOF >> $HOME/.vimrc
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

git clone git@github.com:yuyun-chang/gitstatus.git
[ -d $HOME/.local ] || mkdir $HOME/.local
mv ./gitstatus $HOME/.local/gitstatus
cat $HOME/.local/gitstatus/bashrc.sh >> $HOME/.bashrc
exec bash
