#!/bin/bash

#git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
#sh ~/.vim_runtime/install_awesome_vimrc.sh

#[ -f ~/.vim_runtime/my_configs.vim ] && \
#rm ~/.vim_runtime/my_configs.vim

#cat << EOF >> $HOME/.vim_runtime/my_configs.vim
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

[ -d ~/.ssh ] && rm -rf ~/.ssh
if [ -z $USER ]; then
    cp -r /workspace/.ssh ~
fi

git clone git@github.com:yuyun-chang/gitstatus.git
[ -d ~/.local ] || mkdir ~/.local
mv ./gitstatus ~/.local/gitstatus
cat ~/.local/gitstatus/bashrc.sh >> ~/.bashrc
exec bash
