#!/bin/bash

config_file=""
if [[ -f "$HOME/.bash_profile" ]]; then
    config_file="$HOME/.bash_profile"
else
    config_file="$HOME/.bashrc"
fi

local_dir="$HOME/.local"

[ -d "${local_dir}" ] || mkdir -p "${local_dir}"

if ! grep -q "source ~/.local/git_prompt.sh" "${config_file}"; then
    cp git_prompt.sh "${local_dir}"

    echo >> "${config_file}"
    echo "source ~/.local/git_prompt.sh" >> "${config_file}"
    echo "GIT_PS1_SHOWDIRTYSTATE=1" >> "${config_file}"
    echo "PS1='${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\] \\[\\033[01;34m\\]\\w \\[\\033[01;33m\\]\$(__git_ps1 \"(%s)\")\\[\\033[00m\\]\\n\\$ '" >> "${config_file}"
    echo >> "${config_file}"
fi
source ${config_file}

cat << EOF >> $HOME/.vimrc
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
