#!/usr/bin/env bash
set -euo pipefail

# @describe Run ripgrep (`rg`) for fast text search.
# Typical usage hints: basic search (`pattern path`), file filtering (`-g`), line numbers (`-n`), context (`-C`).
# Provide all rg CLI arguments via --args.
# @option --args! rg CLI arguments string. Example: `-n 'TODO|FIXME' src`
# @option --stdin Input text piped to rg.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
rg.sh
- Purpose: fast recursive search.
- Required: --args with valid rg CLI arguments.
- Optional: --stdin for stream search.
Examples:
  --args "-n 'function main' src"
  --args "-n --glob '*.md' 'OpenAI' ."
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
    command -v rg >/dev/null 2>&1 || { echo "rg command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | rg "${parsed_args[@]}" | emit
    else
        rg "${parsed_args[@]}" | emit
    fi
}

main "$@"
