#!/usr/bin/env bash

OMZSH="$HOME/.oh-my-zsh"

if [ ! -d "$OMZSH" ]; then
  echo 'Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo '👌 oh-my-zsh found'
fi

echo 'Installing zsh plugins'
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
echo '✅ done'

# Change default shell
if [$0 = "-zsh"]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh
else
  echo '👌 already using zsh'
fi

echo '🔥 erasing current config'
rm -rf $HOME/.zshrc

if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
  echo '💪 install powerlevel10k'
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
fi

echo 'gitconfig --global setup'
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

# install vim-plug
echo 'installing vim-plug'
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

echo 'installing vim plugins'
nvim --headless +PlugInstall +qall

echo "set editing-mode to vi" >> ~/.inputrc
