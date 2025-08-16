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

# -----------------------------
# Detect distro & install deps
# -----------------------------
install_packages() {
  if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y $COMMON_PACKAGES
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y $COMMON_PACKAGES
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm $COMMON_PACKAGES
  elif command -v zypper &>/dev/null; then
    sudo zypper install -y $COMMON_PACKAGES
  else
    echo "Unsupported distro. Install packages manually: $COMMON_PACKAGES"
  fi
}

# -----------------------------
# Clone dotfiles
# -----------------------------
setup_dotfiles() {
  if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles already cloned. Pulling latest..."
    git -C "$DOTFILES_DIR" pull
  else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi

  echo "Moving configs to $CONFIG_DIR..."
  mkdir -p "$CONFIG_DIR"
  cp -r "$DOTFILES_DIR/.config/"* "$CONFIG_DIR/"
}

# -----------------------------
# Install JetBrainsMono Nerd Font
# -----------------------------
install_font() {
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  echo "Downloading JetBrains Mono Nerd Font..."
  curl -L -o /tmp/JetBrainsMono.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  fc-cache -fv "$FONT_DIR"
}

# -----------------------------
# Install oh-my-zsh & plugins
# -----------------------------
setup_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # Plugins
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true

  echo "Copying .zshrc..."
  cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

  # Change default shell to zsh
  echo "Changing default shell zsh"
  if command -v zsh >/dev/null 2>&1; then
    echo "Changing default shell to zsh..."
    chsh -s "$(command -v zsh)" "$USER"
  else
    echo "❌ zsh not found, skipping default shell change."
  fi
}

# -----------------------------
# Install Powerlevel10k
# -----------------------------
setup_p10k() {
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" || true

  echo "Copying .p10k.zsh..."
  cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
}

install_brew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# -----------------------------
# Run everything
# -----------------------------
install_packages
install_brew
setup_dotfiles
install_font
setup_zsh
setup_p10k

echo "✅ Setup complete. Restart your terminal or run: exec zsh"

