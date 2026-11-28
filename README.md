# nvim_for_termux
Neovim configuration for the Termux app

## Compatible languages:
- Bash
- PHP
- Python
- Dart
- JavaScript
- SQL

## Requirements:
- Termux app

[![image](https://thumb.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/3840px-Google_Play_Store_badge_EN.svg.png?utm_source=es.wikipedia.org&utm_campaign=index&utm_content=thumbnail)](https://play.google.com/store/apps/details?id=com.termux)

## Install:
1. Open the Termux app.

2. Clone or download this project.

[Descargar ultima version: ![GitHub Release](https://img.shields.io/github/v/release/gamzoftware/nvim_for_termux?style=for-the-badge&label=stable&labelColor=gray&color=green)](https://github.com/Gamzoftware/nvim_for_termux/archive/refs/heads/stable.zip)
[Notas de la version](https://github.com/Gamzoftware/nvim_for_termux/releases/latest/)


```bash
git clone https://github.com/Gamzoftware/nvim_for_termux.git
```

3. Run the install script.

```bash
cd nvim_for_termux && ./install.sh
```

## Use Neovim:

✓ Open an example file.

```bash
nvim example.sh
```

✓ Set the script content.

```bash
# example.sh
#!/usr/bin/env bash

echo "hello world!"
```

✓ Write the changes.

```nvim
:w!
```

✓ Use `space + t + t` to open the integrated terminal.

```bash
# Neovim terminal
chmod +x ./example.sh
./example.sh
```
