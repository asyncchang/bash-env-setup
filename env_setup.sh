#!/bin/bash

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

cat << EOF >> $HOME/.vim_runtime/my_configs.vim
set nu
set cursorline
set tabstop=4
set shiftwidth=4

" Color configuration
set background=dark
hi LineNr cterm=bold ctermfg=DarkGrey ctermbg=NONE
hi CursorLineNr cterm=bold ctermfg=Green ctermbg=NONE
EOF

pip install powerline-shell

mkdir -p ~/.config/powerline-shell && \
powerline-shell --generate-config > ~/.config/powerline-shell/config.json

rm $HOME/.config/powerline-shell/config.json
cat << EOF >> $HOME/.config/powerline-shell/config.json
{
  "segments": [
    "virtual_env",
    "username",
    "hostname",
    "cwd",
    "git",
    "hg",
    "root"
  ]
}
EOF

# paste the following snippet to bashrc
<<comment
function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
comment

