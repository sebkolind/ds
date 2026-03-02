if [ "$D_HEADER" = false ]; then
  return
fi

if [ "$D_HEADER_LOGO" = true ]; then
  echo -e "${BOLD}${MAGENTA}  ┌┬┐┌─┐┌─┐┬ ┬${R}"
  echo -e "${BOLD}${MAGENTA}   ││├─┤└─┐├─┤${R}"
  echo -e "${BOLD}${MAGENTA}  ─┴┘┴ ┴└─┘┴ ┴${R}"
  echo ""
fi


if [ "$D_HEADER_META" = true ]; then
  printf "  ${DIM}Plugins: ${#D_PLUGINS[@]}${R}\n"
fi
