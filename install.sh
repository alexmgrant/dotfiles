#!/usr/bin/env bash

set -e
echo "HOME path: $HOME"

OMZSH="$HOME/.oh-my-zsh"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SKIP_NVIM=false
echo "SCRIPT_DIR path: $SCRIPT_DIR"

for arg in "$@"
do
  case $arg in
    --skip-nvim)
      SKIP_NVIM=true
      shift # Remove --skip-nvim from processing
      ;;
  esac
done

if command -v zsh &> /dev/null; then
    echo '👌 oh-my-zsh found'
else
  case "$OSTYPE" in
    linux*)
      sudo apt-get --assume-yes install zsh
      ;;
  esac

  case "$OSTYPE" in
    darwin*)
      brew install zsh
      ;;
  esac

  echo '👌 finito, installed zsh'
fi

# Change default shell
sudo chsh -s $(which zsh)
echo '👌 finito, changed default shell to zsh'

if [ -d "$OMZSH" ]; then
  echo '👌 oh-my-zsh found'
else
  export ZSH="$HOME/.oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo '👌 finito, installed oh-my-zsh'
fi

if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
echo '👌 finito, zsh plugins installed'


[ -f $HOME/.zshrc ] && mv -n $HOME/.zshrc $HOME/.zshrc.local
echo '👌 finito, created .zshrc.local backup'
ln -sf "$SCRIPT_DIR/.zshrc" $HOME/.zshrc
echo '👌 finito, copied .zsh config'

if [ -d $HOME/.zsh/pure ]; then
  echo '👌 pure prompt found'
else
  mkdir -p $HOME/.zsh
  git -C $HOME/.zsh/pure pull || git clone https://github.com/sindresorhus/pure.git $HOME/.zsh/pure
  echo '👌 finito, pure prompt installed'
fi

# spin setup. This needs to run before copying .gitconfig
if [ $SPIN ]; then
  SKIP_NVIM=true

  # Install Ripgrep for better code searching: `rg <string>` to search. Obeys .gitignore
  sudo apt-get --assume-yes install -y ripgrep

  # Set system generated .gitconfig to .gitconfig.local. We'll pull it in later as part
  # of our custom gitconfig. The generated gitconfig already has the right user and email,
  # since Spin knows that from login.
  [ -f $HOME/.gitconfig ] && mv -n $HOME/.gitconfig $HOME/.gitconfig.local

  echo '👌 finito, spin setup'
fi

ln -sf "$SCRIPT_DIR/.gitconfig" $HOME/.gitconfig
echo '👌 finito, copied .gitconfig'

git config --global core.editor "vim"
git config --global rerere.enabled true
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
git config --list | grep alias
echo '👌 finito, gitconfig --global setup'

setup_neovim_build() { 
  git -C neovim pull || git clone https://github.com/neovim/neovim
  cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
}

case "$OSTYPE" in
  linux*) 
    # install dependencies & build neovim
    if [ "$SKIP_NVIM" = false ]; then
      sudo apt-get --assume-yes install ninja-build gettext cmake unzip curl build-essential  
      setup_neovim_build
      cd build && cpack -G DEB && sudo dpkg -i --force-overwrite nvim-linux64.deb 
      echo '👌 finito, installed neovim'  
    fi
      ;;
  esac

  case "$OSTYPE" in
    darwin*)
      eval "$(/opt/homebrew/bin/brew shellenv)"
      BREW_EXECUTABLE=/opt/homebrew/bin/brew

      $BREW_EXECUTABLE shellenv > $HOME/.dotfile_brew_setup
      $BREW_EXECUTABLE install coreutils
    
    # install dependencies & build neovim
    if [ "$SKIP_NVIM" = false ]; then
        brew install ninja cmake gettext curl
        setup_neovim_build
        sudo make install
        echo '👌 finito, installed neovim'
    fi
      ;;
  esac

  if [ ! -d "$HOME/.config/nvim" ]; then
    mkdir $HOME/.config/nvim
  fi

  ln -sf "$SCRIPT_DIR/.vimrc" $HOME/.config/nvim/init.vim
  echo '👌 finito, copied init.vim'

# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  echo '👌 finito, installed vim-plug'

  nvim --headless +PlugInstall +qall
  echo '👌 finito, installed vim plugins with PlugInstall'

  echo "set editing-mode vi" >> $HOME/.inputrc

