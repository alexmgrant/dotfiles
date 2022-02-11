#!/usr/bin/env bash

OMZSH="$HOME/.oh-my-zsh"

if [ ! -d "$OMZSH" ]; then
  echo 'Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo '👌 oh-my-zsh found'
fi

# Change default shell
if [$0 = "-zsh"]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh
else
  echo '👌 already using zsh'
fi

echo '🔥 erasing current config'
rm -rf $HOME/.zshrc
rm -rf $HOME/.p10k.zsh

echo '💪 install powerlevel10k'
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

echo '💽 gitconfig --global setup'
#git editor
git config --global core.editor "vim"
echo '✍ setting git default editor to vim'
#git rerere enabled
git config --global rerere.enabled true
#git log alias
echo '💄 setting prettier git lg alias'
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
git config --list | grep alias
echo '✅ done'

echo '🔗 link configs'
ln -s $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/dotfiles/.p10k.zsh $HOME/.p10k.zsh
