#!/usr/bin/env bash
set -euo pipefail

# @describe Run jq for JSON filtering and transformation.
# Typical usage hints: extract fields (`.foo`), iterate arrays (`.items[]`), filter (`select(...)`), build new JSON (`{k: .v}`).
# Provide all jq CLI arguments via --args, including filter and optional file paths.
# @option --args! jq CLI arguments string. Example: `-r '.items[] | .name' data.json`
# @option --stdin JSON text piped to jq. Useful when no input file is available.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
jq.sh
- Purpose: JSON query/transform tool.
- Required: --args with valid jq CLI arguments.
- Optional: --stdin to provide JSON directly.
Examples:
  --args "-r '.name' user.json"
  --args "'.items[] | select(.enabled)'" --stdin '{"items":[{"enabled":true}]}'
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
    command -v jq >/dev/null 2>&1 || { echo "jq command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | jq "${parsed_args[@]}" | emit
    else
        jq "${parsed_args[@]}" | emit
    fi
}

main "$@"
