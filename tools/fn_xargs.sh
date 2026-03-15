#!/usr/bin/env bash
set -euo pipefail

# @describe Run xargs for pipeline argument expansion.
# Typical usage hints: build command calls from stdin, use `-I {}` for placeholders, use `-0` with null-delimited input.
# Provide all xargs CLI arguments via --args.
# @option --args! xargs CLI arguments string. Example: `-I {} echo file:{}`
# @option --stdin Input text piped to xargs.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
xargs.sh
- Purpose: convert stdin items into command arguments.
- Required: --args with xargs options and target command.
- Optional: --stdin for inline items.
Examples:
  --args "-I {} echo item:{}" --stdin 'a\nb\n'
  --args "-n 1 echo" --stdin 'one two three'
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
    command -v xargs >/dev/null 2>&1 || { echo "xargs command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | xargs "${parsed_args[@]}" | emit
    else
        xargs "${parsed_args[@]}" | emit
    fi
}

main "$@"
