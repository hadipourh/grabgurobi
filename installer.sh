#!/bin/bash
# -----------------------------------------------------------------------------
# install_gurobi.sh - Gurobi Installer and License Activator
#
# Copyright (C) 2025 Hosein Hadipour
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------

echo "=== Gurobi Installer Script ==="

# Detect OS
platform=$(uname)
if [[ "$platform" == "Linux" ]]; then
    os="linux"
elif [[ "$platform" == "Darwin" ]]; then
    os="mac"
else
    echo "Unsupported OS: $platform"
    exit 1
fi

# Detect user shell
user_shell=$(basename "$SHELL")
if [[ "$user_shell" == "zsh" ]]; then
    rc_file=~/.zshrc
else
    rc_file=~/.bashrc
fi

# Ask for download URL
read -p "Please enter the download URL for Gurobi: " download_url

# Ask for installation directory
read -p "Please enter the directory where you want to install Gurobi: " install_dir
mkdir -p "$install_dir"
cd "$install_dir" || exit 1

# Download
echo "Downloading Gurobi..."
wget "$download_url" -O gurobi.tar.gz || { echo "Download failed!"; exit 1; }

# Extract
echo "Extracting Gurobi..."
tar -xzf gurobi.tar.gz || { echo "Extraction failed!"; exit 1; }

# Find grbgetkey
echo "Searching for 'grbgetkey'..."
grbgetkey_path=$(find . -type f -name grbgetkey | head -n 1)
if [[ -z "$grbgetkey_path" ]]; then
    echo "Could not find grbgetkey in extracted folders."
    exit 1
fi

# Determine paths
bin_dir=$(dirname "$grbgetkey_path")
gurobi_home=$(realpath "$(dirname "$bin_dir")")
cd "$bin_dir" || { echo "Failed to enter bin directory."; exit 1; }

# Run activation
echo "Running the license activation tool (grbgetkey)..."
./grbgetkey || { echo "License activation failed!"; exit 1; }

# Find license file
echo "Searching for the generated license file (gurobi.lic)..."
license_path=$(find "$HOME" -type f -name "gurobi.lic" 2>/dev/null | head -n 1)
if [[ -z "$license_path" ]]; then
    echo "Could not find gurobi.lic file automatically."
    read -p "Please enter the full path to your gurobi.lic file: " license_path
else
    echo "Found license file at: $license_path"
fi

# Set environment variables
echo "Configuring environment variables in $rc_file..."
{
  echo ""
  echo "# === Gurobi configuration ==="
  echo "export GRB_LICENSE_FILE=\"$license_path\""
  echo "export GUROBI_HOME=\"$gurobi_home\""
  echo "export PATH=\"\$GUROBI_HOME/bin:\$PATH\""
  if [[ "$os" == "linux" ]]; then
    echo "export LD_LIBRARY_PATH=\"\$GUROBI_HOME/lib:\$LD_LIBRARY_PATH\""
  else
    echo "export DYLD_LIBRARY_PATH=\"\$GUROBI_HOME/lib:\$DYLD_LIBRARY_PATH\""
  fi
} >> "$rc_file"

# Apply in current session
export GRB_LICENSE_FILE="$license_path"
export GUROBI_HOME="$gurobi_home"
export PATH="$GUROBI_HOME/bin:$PATH"
if [[ "$os" == "linux" ]]; then
    export LD_LIBRARY_PATH="$GUROBI_HOME/lib:$LD_LIBRARY_PATH"
else
    export DYLD_LIBRARY_PATH="$GUROBI_HOME/lib:$DYLD_LIBRARY_PATH"
fi

# Clean up
echo "Cleaning up downloaded archive..."
rm -f "$install_dir/gurobi.tar.gz"

echo "✅ Gurobi installation and activation complete!"
echo "💡 Run 'source $rc_file' or restart your terminal to apply the environment changes."