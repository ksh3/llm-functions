#!/usr/bin/env bash
set -euo pipefail

# @describe Run wc for counting lines, words, and bytes.
# Typical usage hints: line count (`-l`), word count (`-w`), byte count (`-c`).
# Provide all wc CLI arguments via --args.
# @option --args! wc CLI arguments string. Example: `-l src/main.rs`
# @option --stdin Input text piped to wc.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
wc.sh
- Purpose: count lines/words/bytes.
- Required: --args with valid wc CLI arguments.
- Optional: --stdin for inline text.
Examples:
  --args "-l README.md"
  --args "-w" --stdin 'hello world'
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
    command -v wc >/dev/null 2>&1 || { echo "wc command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | wc "${parsed_args[@]}" | emit
    else
        wc "${parsed_args[@]}" | emit
    fi
}

main "$@"
