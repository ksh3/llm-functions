#!/usr/bin/env bash
set -euo pipefail

# @describe Run fd for fast file discovery by pattern.
# Typical usage hints: search by name (`pattern path`), type filtering (`-t f`/`-t d`), extension (`-e`).
# Provide all fd CLI arguments via --args.
# @option --args! fd CLI arguments string. Example: `-t f -e md README .`
# @option --stdin Input text piped to fd when applicable.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
fd.sh
- Purpose: fast and ergonomic file/path search.
- Required: --args with valid fd CLI arguments.
- Optional: --stdin for specialized usage.
Examples:
  --args "-t f 'Dockerfile' ."
  --args "-t d '^src$' ."
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
    local args=""
    local stdin_text=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --args)
                [[ $# -ge 2 ]] || { echo "missing value for --args" >&2; exit 2; }
                args="$2"
                shift 2
                ;;
            --stdin)
                [[ $# -ge 2 ]] || { echo "missing value for --stdin" >&2; exit 2; }
                stdin_text="$2"
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

    [[ -n "$args" ]] || { echo "--args is required. Use --help for usage." >&2; exit 2; }
    command -v fd >/dev/null 2>&1 || { echo "fd command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | fd "${parsed_args[@]}" | emit
    else
        fd "${parsed_args[@]}" | emit
    fi
}

main "$@"
