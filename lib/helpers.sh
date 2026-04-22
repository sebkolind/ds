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

# pr_checks_label <statusCheckRollup_json>
# Echoes a pre-colored status label for the PR's CI checks.
# Buckets the rollup into: none | pending | success | failure.
# Handles both check-run entries (.status/.conclusion) and legacy commit
# statuses (.state). Invalid/empty input renders as a dim "Checks unknown".
pr_checks_label() {
  local json="$1"
  local bucket

  if [[ -z "$json" || "$json" == "null" ]]; then
    printf "${DIM}Checks unknown${R}"
    return
  fi

  bucket=$(printf '%s' "$json" | jq -r '
    if length == 0 then "none"
    elif any(.[];
      .conclusion == "FAILURE"
      or .conclusion == "TIMED_OUT"
      or .conclusion == "CANCELLED"
      or .conclusion == "STARTUP_FAILURE"
      or .state == "FAILURE"
      or .state == "ERROR"
    ) then "failure"
    elif any(.[];
      ((.status // "") != "" and (.status // "") != "COMPLETED")
      or (.state // "") == "PENDING"
      or (.state // "") == "EXPECTED"
    ) then "pending"
    else "success" end
  ' 2>/dev/null)

  case "$bucket" in
    success) printf "${GREEN}Checks passing${R}" ;;
    pending) printf "${YELLOW}Checks pending${R}" ;;
    failure) printf "${RED}Checks failing${R}" ;;
    none)    printf "${DIM}No checks${R}" ;;
    *)       printf "${DIM}Checks unknown${R}" ;;
  esac
}

# pr_review_label <reviewDecision>
# Echoes a pre-colored status label for the PR's review decision.
# reviewDecision is one of APPROVED, CHANGES_REQUESTED, REVIEW_REQUIRED,
# or empty string (no review required).
pr_review_label() {
  local decision="$1"

  case "$decision" in
    APPROVED)          printf "${GREEN}Approved${R}" ;;
    CHANGES_REQUESTED) printf "${RED}Changes requested${R}" ;;
    REVIEW_REQUIRED)   printf "${YELLOW}Review pending${R}" ;;
    "")                printf "${DIM}No review required${R}" ;;
    *)                 printf "${DIM}Review unknown${R}" ;;
  esac
}
