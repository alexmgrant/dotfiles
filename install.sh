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
  case $arg in
    --skip-zsh)
      SKIP_ZSH=true
      shift # Remove --skip-zsh from processing
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

cp "$SCRIPT_DIR/.gitconfig" $HOME/.gitconfig
echo '👌 finito, copied .gitconfig'

git config --global core.editor "vim"
git config --global rerere.enabled true
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
git config --list | grep alias
echo '👌 finito, gitconfig --global setup'

setup_neovim_build() { 
  git -C neovim pull || git clone https://github.com/neovim/neovim
  cd neovim
  rm -rf build # clear CMake cache
  make CMAKE_BUILD_TYPE=RelWithDebInfo
}

case "$OSTYPE" in
  linux*) 
    # set key repeat rate 
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
    gsettings set org.gnome.desktop.peripherals.keyboard delay 250

    # install dependencies & build neovim
    if [ "$SKIP_NVIM" == false ]; then
      sudo apt-get --assume-yes install ninja-build gettext cmake unzip curl build-essential  
      setup_neovim_build
      cd build && cpack -G DEB && sudo dpkg -i --force-overwrite nvim-linux64.deb 
      echo '👌 finito, installed neovim'  
    fi

    # install lazygit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin

    git config --global core.editor "nvim"
    ;;
esac

case "$OSTYPE" in
  darwin*)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    BREW_EXECUTABLE=/opt/homebrew/bin/brew

    $BREW_EXECUTABLE shellenv > $HOME/.dotfile_brew_setup
    $BREW_EXECUTABLE install coreutils

    # Faster keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 12

    # Show hidden files in finder 
    defaults write com.apple.finder AppleShowAllFiles YES

    # install dependencies & build neovim
    if [ "$SKIP_NVIM" == false ]; then
      brew install ninja cmake gettext curl
      setup_neovim_build
      sudo make install
      echo '👌 finito, installed neovim'
    fi

    # install lazygit
    brew install jesseduffield/lazygit/lazygit
    ;;
esac

if [ ! -d "$HOME/.config/nvim" ]; then
  mkdir $HOME/.config/nvim
fi

ln -sf "$SCRIPT_DIR/.luarc.json" $HOME/.config/nvim/luarc.json
ln -sf "$SCRIPT_DIR/init.lua" $HOME/.config/nvim/init.lua
echo '👌 finito, copied init.lua'

echo "set editing-mode vi" >> $HOME/.inputrc

