#!/usr/bin/env bash

set -euo pipefail

WORKDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# 0. Install dependencies
apt -y update
apt install -y neovim git curl unzip ripgrep build-essential \
    php composer python python-pip shellcheck shfmt termux-api \
    nodejs-lts
#formatters
npm install -g prettier
npm install -g sql-formatter
#js linter
npm install -g eslint_d
#php linter
composer global require --dev phpstan/phpstan
composer global require friendsofphp/php-cs-fixer
#sql linter
pip3 install --user sqlfluff
#add .local/bin to bashrc
if [[ ! -f $HOME/.bashrc ]]; then
    echo "" >>"$HOME/.bashrc"
fi
has_local_bin_path=$(cat "$HOME/.bashrc" | while read line; do
    if [[ $line == *"export PATH="* ]]; then
        if [[ $line == *":/\$HOME/.local/bin"* ]]; then
            echo true
            break
        fi
    fi
done)
if [[ $has_local_bin_path != false ]]; then
    echo "export PATH=\"\$PATH:\$HOME/.local/bin\"" >>"$HOME/.bashrc"
fi

# 1. Inicializa plugins de nvim
if [[ -d "$HOME/.config/nvim" ]]; then
    rm -rf "$HOME/.config/nvim"
fi
ln -s "$WORKDIR" "$HOME/.config/nvim"
nohup nvim --headless "+Lazy! install" "+Lazy! update" "+Lazy! sync" &

# 2. Crea la carpeta exacta donde copilot.lua busca el módulo
echo -e "\033[0;32mdownloading copilot lsp..."
copilot_lsp_dir="$HOME/.local/share/nvim/copilot.lua/lsp"
while [[ ! -d "$copilot_lsp_dir" ]]; do
    sleep 5
done

copilot_lsp_version=$(ls "$copilot_lsp_dir" | awk -F' ' '{print $NF}' | tail -n 1)
while [[ $(ls "$copilot_lsp_dir/$copilot_lsp_version/js" | wc -l) == 0 ]]; do
    sleep 5
done

copilot_compiled_hash=$(ls "$copilot_lsp_dir/$copilot_lsp_version/js" | awk -F' ' '{print $NF}' | tail -n 1)
copilot_compiled_arm64_dir="$copilot_lsp_dir/$copilot_lsp_version/js/$copilot_compiled_hash/compiled/android/arm64/"
mkdir -p "$copilot_compiled_arm64_dir"

# 3. Descarga y extrae el paquete nativo de @parcel/watcher para Android ARM64 en un directorio temporal
mkdir -p "$HOME/tmp-watcher" && cd "$HOME/tmp-watcher" || exit 1
npm pack @parcel/watcher-android-arm64
tar -xzf parcel-watcher-android-arm64-*.tgz

# 4. Copia el archivo watcher.node a la ruta de copilot.lua
cp package/watcher.node "$copilot_compiled_arm64_dir/watcher.node"

# 5. Limpia los archivos temporales
rm -rf "$HOME/tmp-watcher" && cd "$WORKDIR" || exit 1

# 6. Ejecuta nvim
nvim -c "sleep 5" -c "Copilot auth" .

exit 0
