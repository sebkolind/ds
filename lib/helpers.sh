spinner() {
  local pid=$1
  local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  while kill -0 "$pid" 2>/dev/null; do
    for (( i=0; i<${#chars}; i++ )); do
      printf "\r  ${DIM}${chars:$i:1} Loading...${R}"
      sleep 0.1
    done
  done
  printf "\r\033[K"
}

section() {
  echo ""
  echo -e "  ${BOLD}${CYAN}$1${R}"
}

row() {
  printf "  ${DIM}%-14s${R} %b\n" "$1" "$2"
}

empty_state() {
  echo -e "  ${DIM}$1${R}"
}

check_dependencies() {
  local -a commands=("$@")
  for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "Missing dependency: $cmd"
      exit 1
    fi
  done
}

debug() {
  [[ "$DEV" == true ]] && printf "${BLUE}[debug]${R} ${DIM}%s${R}" "$1"
}
