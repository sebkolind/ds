if [ "$D_HEADER" = false ]; then
  return
fi

if [ "$D_HEADER_LOGO" = true ]; then
  echo -e "${BOLD}${MAGENTA}  ┌┬┐┌─┐${R}"
  echo -e "${BOLD}${MAGENTA}   ││└─┐${R}"
  echo -e "${BOLD}${MAGENTA}  ─┴┘└─┘${R}"
  echo ""
fi

if [ "$D_HEADER_META" = true ]; then
  meta="  "
  meta+="${DIM}Plugins:${R} ${BOLD}${CYAN}${#D_PLUGINS[@]}${R}"
  meta+="${DIM} ∙ Cache:${R} ${BOLD}${CYAN}${D_CACHE_TTL}s${R}"
  printf "${meta}\n"
fi
