#!/usr/bin/env bash
set -euo pipefail

# @describe Create directories using `mkdir -p`.
# This wrapper always includes `-p` so existing directories do not fail.
# @option --args! Directory path arguments. Example: `logs/app tmp/cache`
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
mkdir.sh
- Purpose: create one or more directories safely.
- Behavior: always uses `mkdir -p`.
- Required: --args with one or more paths.
Examples:
  --args "logs"
  --args "logs/app tmp/cache"
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

    [[ -n "$args" ]] || { echo "--args is required. Use --help for usage." >&2; exit 2; }
    command -v mkdir >/dev/null 2>&1 || { echo "mkdir command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"
    mkdir -p "${parsed_args[@]}"
    printf '%s\n' "created: ${parsed_args[*]}" | emit
}

main "$@"
