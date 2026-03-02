#!/bin/bash
set -e

INSTALL_DIR="${HOME}/.local/share/dash"

if [ -d "$INSTALL_DIR" ]; then
  echo "Updating..."
  git -C "$INSTALL_DIR" pull
else
  echo "Installing..."
  git clone https://github.com/sebkolind/dash "$INSTALL_DIR"
fi

chmod +x "${INSTALL_DIR}/bin/ds"
ln -sf "${INSTALL_DIR}/bin/ds" "${HOME}/bin/ds"

echo "Done! Run 'ds' to get started."
