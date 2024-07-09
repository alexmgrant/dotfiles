#!/usr/bin/env bash

OMZSH="$HOME/.oh-my-zsh"

if [ ! -d "$OMZSH" ]; then
  echo 'Installing oh-my-zsh'
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

# Change default shell
if [$0 = "-zsh"]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh
else
  echo '👌 already using zsh'
fi

ln -sf $HOME/dotfiles/.zshrc $HOME/.zshrc
echo '👌 finito, copied .zsh config'

mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
echo '👌 finito, pure prompt installed'

#git editor
git config --global core.editor "vim"
#git rerere enabled
git config --global rerere.enabled true
#git log alias
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
git config --list | grep alias
echo '👌 finito, gitconfig --global setup'


if [ $SPIN ]; then
  # Install Ripgrep for better code searching: `rg <string>` to search. Obeys .gitignore
  sudo apt-get install -y ripgrep

  # Set system generated .gitconfig to .gitconfig.local. We'll pull it in later as part
  # of our custom gitconfig. The generated gitconfig already has the right user and email,
  # since Spin knows that from login.
  mv -n ~/.gitconfig ~/.gitconfig.local
fi
echo '👌 finito, spin setup'

cp ./.gitconfig ~/.gitconfig
echo '👌 finito, copied .gitconfig'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  flatpak install flathub io.neovim.nvim
  flatpak run io.neovim.nvim
elif [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  BREW_EXECUTABLE=/opt/homebrew/bin/brew

  $BREW_EXECUTABLE shellenv > $HOME/.dotfile_brew_setup
  $BREW_EXECUTABLE install coreutils

  brew install neovim
fi
echo '👌 finito, installed neovim'

# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo '👌 finito, installed vim-plug'

nvim --headless +PlugInstall +qall
echo '👌 finito, installed vim plugins with PlugInstall'

echo "set editing-mode vi" >> ~/.inputrc

