#!/bin/bash

echo "Copiando arquivos de configuração"

cp ../dotfiles/bash_aliases ~/.bash_aliases
cp ../dotfiles/bash_environment ~/.bash_environment
cp ../dotfiles/gitconfig ~/.gitconfig
cp ../dotfiles/gitignore_global ~/.gitignore_global
cp ../dotfiles/rspec ~/.rspec
cp ../dotfiles/tmux.conf ~/.tmux.conf
cp -r ../dotfiles/terminator/ ~/.config/

#colocar o codigo abaixo no bashrc acima do carregamento do bash_aliases

# Environment definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_environment, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#if [ -f ~/.bash_environment ]; then
    #. ~/.bash_environment
#fi


source ~/.bashrc
