#!/usr/bin/env bash
set -euo pipefail

# @describe Show listening TCP sockets for a specific port using `lsof -nP -iTCP:<PORT> -sTCP:LISTEN`.
# Use this to identify which process owns a port.
# @option --port! TCP port number to inspect.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
lsof_listen.sh
- Purpose: find process listening on a TCP port.
- Required: --port
Examples:
  --port "3000"
  --port "8080"
USAGE
}

emit() {
    if [[ -n "${LLM_OUTPUT:-}" ]]; then
        cat >> "$LLM_OUTPUT"
    else
        cat
    fi
}

main() {
    local port=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --port)
                [[ $# -ge 2 ]] || { echo "missing value for --port" >&2; exit 2; }
                port="$2"
                shift 2
                ;;
            -h|--help)
                usage | emit
                exit 0
                ;;
            *)
                echo "unknown option: $1" >&2
                exit 2
                ;;
        esac
    done

    [[ -n "$port" ]] || { echo "--port is required. Use --help for usage." >&2; exit 2; }
    command -v lsof >/dev/null 2>&1 || { echo "lsof command not found in PATH." >&2; exit 127; }

    lsof -nP -iTCP:"$port" -sTCP:LISTEN | emit
}

main "$@"
