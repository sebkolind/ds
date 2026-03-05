# Plugins
# A small script loaded as a section
#
# Can be configured with a plugin-specific `.config/dash/plugins/{plugin_name}.sh` file.

# Sets the variable named by <result_var> to the fetched (or cached) content.
# Usage: cached_fetch <result_var> <cache_file> <cmd>
cached_fetch() {
  local result_var="$1"
  local cache_file="$2"
  local cmd="$3"

  if [[ "$D_CACHE_TTL" -gt 0 ]] && [[ -f "$cache_file" ]]; then
    local mtime
    # Either Linux or macOS modified time
    mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
    if (( $(date +%s) - mtime < D_CACHE_TTL )); then
      printf -v "$result_var" '%s' "$(cat "$cache_file")"
      return
    fi
  fi

  eval "$cmd" >"$cache_file" 2>/dev/null &
  wait $!
  printf -v "$result_var" '%s' "$(cat "$cache_file")"
}

# Load config for a plugin.
load_config() {
  local plugin_name="$1"
  local file="${CONFIG_DIR}/plugins/${plugin_name}.sh"
  if [[ -f "$file" ]]; then
    debug "Loading config for plugin: $plugin_name"
    source "$file"
  fi
}

# No plugins configured.
if [[ "${#D_PLUGINS[@]}" -eq 0 ]]; then
  echo ""
  printf "  You have no plugins configured. Available plugins:\n"
  printf "  ${BLUE}Jira${R} (jira), ${BLUE}GitHub${R} (pull-requests & review-pull-requests).\n\n"
  printf "  You can configure plugins by adding them to your ${BLUE}D_PLUGINS${R} array in your config file.\n"
  printf "  Your config file is located at: ${CONFIG_DIR}/config.sh.\n"
  return
fi

# Load plugins in parallel.

declare -a pids=()          # Array to store process IDs
declare -a output_files=()  # Array to store temp file paths

for plugin in "${D_PLUGINS[@]}"; do
  output_file=$(mktemp)
  output_files+=("$output_file")

  {
    load_config "$plugin"
    source "${DIR}/plugins/$plugin.sh"
  } > "$output_file" 2>&1 &

  pids+=($!)
done

# Wait for all plugins to finish
if [[ ${#pids[@]} -gt 0 ]]; then
  # Start spinner
  (
    trap 'exit 0' TERM  # Make spinner exit cleanly on SIGTERM
    chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    echo ""
    while true; do
      for (( i=0; i<${#chars}; i++ )); do
        printf "\r  ${DIM}${chars:$i:1} Loading...${R}"
        sleep 0.1
      done
    done
  ) &
  spinner_pid=$!

  # Cleanup function for spinner and terminal
  cleanup_and_exit() {
    # Kill spinner and plugin processes
    kill "$spinner_pid" 2>/dev/null
    for pid in "${pids[@]}"; do
      kill "$pid" 2>/dev/null
    done

    # Wait for specific processes to finish
    wait "$spinner_pid" 2>/dev/null || true
    for pid in "${pids[@]}"; do
      wait "$pid" 2>/dev/null || true
    done

    # Clean up temp files
    for output_file in "${output_files[@]}"; do
      rm -f "$output_file" 2>/dev/null
    done

    # Clear terminal output
    printf "\r\033[K"      # Clear current line (spinner)
    printf "\033[1A\033[K" # Move up one line and clear it (the empty line)

    exit 130  # Standard exit code for Ctrl-C
  }

  # Set up trap to cleanup on interrupt
  trap cleanup_and_exit INT

  for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null
  done

  # Remove trap and cleanup normally
  trap - INT
  kill "$spinner_pid" 2>/dev/null
  wait "$spinner_pid" 2>/dev/null
  printf "\r\033[K"      # Clear current line (spinner)
  printf "\033[1A\033[K" # Move up one line and clear it (the empty line)
fi

# Print all plugins in same order
for output_file in "${output_files[@]}"; do
  if [[ -s "$output_file" ]]; then
    cat "$output_file"
  fi
  rm "$output_file" # Clean up temp file
done
