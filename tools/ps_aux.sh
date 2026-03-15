#!/usr/bin/env bash
set -euo pipefail

# @describe Show process list using `ps aux`.
# Useful for checking high CPU or memory usage, process owners, and command lines.
# @option --filter Filter regex to apply to `ps aux` output.
# @option --no-header Remove the header row.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
ps_aux.sh
- Purpose: process overview via `ps aux`.
- Optional: --filter for narrowing output.
- Optional: --no-header to hide first line.
Examples:
  --filter "python|node"
  --no-header
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
    local filter=""
    local no_header=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --filter)
                [[ $# -ge 2 ]] || { echo "missing value for --filter" >&2; exit 2; }
                filter="$2"
                shift 2
                ;;
            --no-header)
                no_header=true
                shift
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

    command -v ps >/dev/null 2>&1 || { echo "ps command not found in PATH." >&2; exit 127; }

    local output
    output="$(ps aux)"

    if [[ "$no_header" == "true" ]]; then
        output="$(printf '%s\n' "$output" | sed '1d')"
    fi

    if [[ -n "$filter" ]]; then
        printf '%s\n' "$output" | grep -E "$filter" | emit
    else
        printf '%s\n' "$output" | emit
    fi
}

main "$@"
