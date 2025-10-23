#!/usr/bin/env bash

set -e

# -----------------------------
# CONFIG
# -----------------------------
DOTFILES_REPO="https://github.com/JRobinNTA/NeoVim-configs.git"
DOTFILES_DIR="$HOME/Downloads/dotfiles"
CONFIG_DIR="$HOME/.config"

# Packages common to most setups
COMMON_PACKAGES="git curl wget zsh unzip fontconfig neovim fastfetch btop kitty cava"
BREW_PACKAGES="fzf eza yazi" # Modern tools via Homebrew

# -----------------------------
# Detect distro & install deps
# -----------------------------
install_packages() {
  echo "--- Installing base packages... ---"
  if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y $COMMON_PACKAGES
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y $COMMON_PACKAGES
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm $COMMON_PACKAGES
  elif command -v zypper &>/dev/null; then
    sudo zypper install -y $COMMON_PACKAGES
  elif [ "$(uname -s)" = "Darwin" ]; then
    echo "macOS detected, skipping system package manager."
  else
    echo "Unsupported distro. Install packages manually: $COMMON_PACKAGES"
  fi
}

# -----------------------------
# Install Homebrew (Linux or Mac)
# -----------------------------
install_brew() {
  echo "--- Setting up Homebrew... ---"
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew already installed. Updating..."
  fi

  # --- CRITICAL FIX ---
  # Find brew and add it to the current script's PATH
  local brew_path
  if [ -x "/opt/homebrew/bin/brew" ]; then
    # Apple Silicon
    brew_path="/opt/homebrew/bin/brew"
  elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    # Linux
    brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
  elif [ -x "/usr/local/bin/brew" ]; then
    # Intel Mac
    brew_path="/usr/local/bin/brew"
  else
    echo "❌ Could not find brew executable." >&2
    return 1
  fi
  
  echo "Adding brew to script's PATH..."
  eval "$($brew_path shellenv)"
}

install_brew_packages() {
  echo "--- Installing Homebrew packages... ---"
  if ! command -v brew &>/dev/null; then
     echo "❌ brew command not found. 'install_brew' might have failed." >&2
     return 1
  fi
  brew update
  brew install $BREW_PACKAGES
}

# -----------------------------
# Clone dotfiles
# -----------------------------
setup_dotfiles() {
  echo "--- Setting up dotfiles... ---"
  if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles already cloned. Pulling latest..."
    git -C "$DOTFILES_DIR" pull
  else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi

  echo "Moving configs to $CONFIG_DIR..."
  mkdir -p "$CONFIG_DIR"
  # Use cp -rT to safely copy contents of .config into ~/.config
  cp -rT "$DOTFILES_DIR/.config/" "$CONFIG_DIR/"
}

# -----------------------------
# Install JetBrainsMono Nerd Font
# -----------------------------
install_font() {
  echo "--- Installing JetBrains Mono Nerd Font... ---"
  local FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  echo "Downloading JetBrains Mono Nerd Font..."
  curl -L -o /tmp/JetBrainsMono.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  rm /tmp/JetBrainsMono.zip
  
  if command -v fc-cache &>/dev/null; then
    echo "Updating font cache..."
    fc-cache -fv
  fi
}

# Helper function for cloning/pulling plugins
clone_or_pull() {
  local repo=$1
  local dir=$2
  if [ -d "$dir" ]; then
    echo "Pulling latest changes for $(basename $dir)..."
    git -C "$dir" pull
  else
    echo "Cloning $(basename $dir)..."
    git clone "$repo" "$dir"
  fi
}

# -----------------------------
# Install oh-my-zsh & plugins
# -----------------------------
setup_zsh() {
  echo "--- Setting up Zsh... ---"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  clone_or_pull https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
  clone_or_pull https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"

  echo "Copying .zshrc..."
  cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
}

# -----------------------------
# Install Powerlevel10k
# -----------------------------
setup_p10k() {
  echo "--- Setting up Powerlevel10k... ---"
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  clone_or_pull --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

  echo "Copying .p10k.zsh..."
  cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
}

# -----------------------------
# Run everything
# -----------------------------
main() {
  install_packages
  install_brew
  install_brew_packages
  setup_dotfiles
  install_font
  setup_zsh
  setup_p10k

  echo ""
  echo "✅ Setup complete."
  echo "------------------------------------------------------------------"
  echo "‼️ ACTION REQUIRED: Change your default shell manually."
  echo "Run the following command and enter your password:"
  echo ""
  echo "  chsh -s \"$(command -v zsh)\""
  echo ""
  echo "After that, restart your terminal or run: exec zsh"
  echo "------------------------------------------------------------------"
}

main
