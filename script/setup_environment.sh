#!/bin/bash
set -e

# --- Introduction ---
echo "--- Ruby Environment Setup Script ---"
echo "This script will set up the necessary environment to run Ruby scripts in this repository."
echo ""

# --- rbenv & ruby-build installation ---
if [ -d "$HOME/.rbenv" ]; then
  echo "rbenv is already installed. Skipping."
else
  echo "Installing rbenv..."
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
fi

if [ -d "$HOME/.rbenv/plugins/ruby-build" ]; then
  echo "ruby-build is already installed. Skipping."
else
  echo "Installing ruby-build..."
  mkdir -p "$(~/.rbenv/bin/rbenv root)"/plugins
  git clone https://github.com/rbenv/ruby-build.git "$(~/.rbenv/bin/rbenv root)"/plugins/ruby-build
fi

# --- Shell configuration ---
# Check if rbenv is already configured in .bashrc
if grep -q 'rbenv init' ~/.bashrc; then
  echo "rbenv is already configured in .bashrc. Skipping."
else
  echo "Adding rbenv configuration to .bashrc..."
  echo '' >> ~/.bashrc
  echo '# rbenv setup' >> ~/.bashrc
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  echo "IMPORTANT: Please restart your shell or run 'source ~/.bashrc' after this script completes."
fi

# --- Source rbenv for the current script session ---
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# --- Install build dependencies ---
echo "Installing build dependencies (requires sudo)..."
sudo apt-get update -y
sudo apt-get install -y libyaml-dev build-essential libssl-dev libreadline-dev zlib1g-dev

# --- Install Ruby ---
RUBY_VERSION=$(cat .ruby-version)
if rbenv versions --bare | grep -q "^${RUBY_VERSION}$"; then
  echo "Ruby version ${RUBY_VERSION} is already installed. Skipping."
else
  echo "Installing Ruby ${RUBY_VERSION}..."
  rbenv install "$RUBY_VERSION"
fi

# --- Install Bundler ---
echo "Installing Bundler..."
gem install bundler

# --- Install script-specific gems ---
echo "Installing gems required by scripts..."
gem install switchbot ruby-ambient

echo ""
echo "--- Setup Complete! ---"
echo "The Ruby environment is ready. Please restart your shell to ensure all changes are applied."
