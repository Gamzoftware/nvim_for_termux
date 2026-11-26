#!/usr/bin/env bash

set -euo pipefail
#dependencies
apt -y update
apt install -y neovim git curl unzip ripgrep build-essential \
    php composer shellcheck shfmt termux-api
#npm install
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 26
npm install -g prettier
npm install -g sql-formatter
npm install -g eslint_d
#php linter
composer global require --dev phpstan/phpstan
composer global require friendsofphp/php-cs-fixer
#sql linter
pip3 install sqlfluff

copilot_compiled_hash='062c8b030be81409d4ef0474f2329bf3f21aeb5787d4695eb28f8dde7890dc3a'
# 1. Crea la carpeta exacta donde copilot.lua busca el módulo
mkdir -p "$HOME/.local/share/nvim/copilot.lua/lsp/1.573.0/js/$copilot_compiled_hash/compiled/android/arm64/"
# 2. Descarga y extrae el paquete nativo de @parcel/watcher para Android ARM64 en un directorio temporal
mkdir -p "$HOME/tmp-watcher" && cd "$HOME/tmp-watcher" || exit 1
npm pack @parcel/watcher-android-arm64
tar -xzf parcel-watcher-android-arm64-*.tgz
# 3. Copia el archivo watcher.node a la ruta de copilot.lua
cp package/watcher.node "$HOME/.local/share/nvim/copilot.lua/lsp/1.573.0/js/$copilot_compiled_hash/compiled/android/arm64/watcher.node"
# 4. Limpia los archivos temporales
cd "$HOME" && rm -rf "$HOME/tmp-watcher"
