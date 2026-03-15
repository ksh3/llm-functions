#!/usr/bin/env bash
set -euo pipefail

# @describe Show current working directory using `pwd`.
# Pass extra pwd options via --args when needed.
# @option --args Optional pwd CLI arguments string. Example: `-P`
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
pwd.sh
- Purpose: print current directory.
- Optional: --args for pwd flags.
Examples:
  (no args)
  --args "-P"
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

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --args)
                [[ $# -ge 2 ]] || { echo "missing value for --args" >&2; exit 2; }
                args="$2"
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

    command -v pwd >/dev/null 2>&1 || { echo "pwd command not found in PATH." >&2; exit 127; }

    if [[ -n "$args" ]]; then
        local -a parsed_args=()
        eval "parsed_args=($args)"
        pwd "${parsed_args[@]}" | emit
    else
        pwd | emit
    fi
}

main "$@"
