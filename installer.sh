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

# 1. Ask for download link
read -p "Please enter the download URL for Gurobi: " download_url

# 2. Ask for installation directory
read -p "Please enter the directory where you want to install Gurobi: " install_dir

# Create install directory if it doesn't exist
mkdir -p "$install_dir"
cd "$install_dir" || exit 1

# 3. Download the archive
echo "Downloading Gurobi..."
wget "$download_url" -O gurobi.tar.gz || { echo "Download failed!"; exit 1; }

# 4. Extract the archive
echo "Extracting Gurobi..."
tar -xzf gurobi.tar.gz || { echo "Extraction failed!"; exit 1; }

# 5. Locate the bin directory and grbgetkey
echo "Searching for 'grbgetkey'..."
grbgetkey_path=$(find . -type f -name grbgetkey | head -n 1)

if [[ -z "$grbgetkey_path" ]]; then
    echo "Could not find grbgetkey in extracted folders."
    exit 1
fi

bin_dir=$(dirname "$grbgetkey_path")
gurobi_home=$(realpath "$(dirname "$bin_dir")")
cd "$bin_dir" || { echo "Failed to enter bin directory."; exit 1; }

# 6. Run the activation tool
echo "Running the license activation tool (grbgetkey)..."
./grbgetkey || { echo "License activation failed!"; exit 1; }

# 7. Try to locate the license file automatically
echo "Searching for the generated license file (gurobi.lic)..."
license_path=$(find "$HOME" -type f -name "gurobi.lic" 2>/dev/null | head -n 1)

if [[ -z "$license_path" ]]; then
    echo "Could not find gurobi.lic file automatically."
    read -p "Please enter the full path to your gurobi.lic file: " license_path
else
    echo "Found license file at: $license_path"
fi

# 8. Export environment variables
echo "Configuring environment variables..."
{
  echo ""
  echo "# === Gurobi configuration ==="
  echo "export GRB_LICENSE_FILE=\"$license_path\""
  echo "export GUROBI_HOME=\"$gurobi_home\""
  echo "export PATH=\"\$GUROBI_HOME/bin:\$PATH\""
  echo "export LD_LIBRARY_PATH=\"\$GUROBI_HOME/lib:\$LD_LIBRARY_PATH\""
} >> ~/.bashrc

# Also apply in the current session
export GRB_LICENSE_FILE="$license_path"
export GUROBI_HOME="$gurobi_home"
export PATH="$GUROBI_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$GUROBI_HOME/lib:$LD_LIBRARY_PATH"

# 9. Clean up
echo "Cleaning up downloaded archive..."
rm -f "$install_dir/gurobi.tar.gz"

echo "✅ Installation and activation complete!"
echo "You may need to run: source ~/.bashrc"
