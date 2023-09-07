#!/bin/bash

<<comment
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
comment

config_file="$HOME/.bashrc"
git_version="v$(echo $(git --version) | awk '{print $3}')"
local_dir="$HOME/.local"

[ -d "${local_dir}" ] || mkdir -p "${local_dir}"

pushd .
git clone https://github.com/git/git.git /tmp/git
cd /tmp/git
git checkout "${git_version}"
mv contrib/completion/git-prompt.sh "${local_dir}"
popd
rm -rf /tmp/git

echo "source ~/.local/git-prompt.sh" >> "${config_file}"
echo "GIT_PS1_SHOWDIRTYSTATE=1" >> "${config_file}"
echo "PS1='${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\] \\[\\033[01;34m\\]\\w \\[\\033[01;33m\\]\$(__git_ps1 \"(%s)\")\\[\\033[00m\\]\\n\\$ '" >> "${config_file}"
echo >> "${config_file}"

source ${config_file}

