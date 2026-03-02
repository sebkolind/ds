case "$1" in
  --sync|-s)
    rm -f /tmp/dash_*.json
    ;;
  --update|-u)
    sh "${DIR}/install.sh"
    exit 0
    ;;
  --help|-h)
    echo "Usage: ds [options]"
    echo "  -s, --sync      Clear cache and force a fresh fetch"
    echo "  -u, --update    Update to the latest version"
    echo "  -h, --help      Show this help message"
    exit 0
    ;;
esac
