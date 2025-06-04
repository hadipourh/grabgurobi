# GrabGurobi

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A simple script to download, install, and activate Gurobi Optimizer with all necessary environment setup on Linux.


## 🛠️ Requirements

- `bash`
- `wget`
- `tar`
- Internet access
- A valid Gurobi license key


## 📦 Installation

1. Clone this repository:

```bash
git clone https://github.com/hadipourh/grabgurobi
cd grabgurobi
```

2. Make the script executable and run it:

```bash
chmod +x install_gurobi.sh
./installer.sh
```

## 🌱 After Installation

Once installed, you can verify the environment is set up by running:

```bash
echo $GUROBI_HOME
gurobi.sh
```

If needed, manually activate the environment in your current shell:

```bash
source ~/.bashrc
```

## 📄 License

The content is licensed under the [GNU GPLv3]( https://www.gnu.org/licenses/gpl-3.0.txt).
See the [LICENSE](LICENSE) file for more details.
