#!/bin/bash

# themes
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"

# filebrowser
filebrowser --address 0.0.0.0 --port 8080 --root /