#!/bin/bash
set -e

INSTALL_DIR="${HOME}/.local/share/dash"

if [ -d "$INSTALL_DIR" ]; then
  echo "Updating..."
  git -C "$INSTALL_DIR" pull
else
  echo "Installing..."
  git clone https://github.com/sebkolind/ds "$INSTALL_DIR"
fi

chmod +x "${INSTALL_DIR}/bin/ds"
ln -sf "${INSTALL_DIR}/bin/ds" "${HOME}/bin/ds"

BOLD='\033[1m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
R='\033[0m'
printf "\n${GREEN}Done!${R} Run ${BLUE}ds${R} to get started.\n"
