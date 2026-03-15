#!/usr/bin/env bash
set -euo pipefail

# @describe Run tokei for code statistics (lines, blanks, comments, language breakdown).
# Typical usage hints: target project paths, use `--sort` or `--output json` for structured output.
# Provide all tokei CLI arguments via --args.
# @option --args! tokei CLI arguments string. Example: `--output json src tests`
# @option --stdin Input text piped to tokei when applicable.
# @env LLM_OUTPUT=/dev/stdout The output path.

usage() {
    cat <<'USAGE'
tokei.sh
- Purpose: count code by language and line categories.
- Required: --args with valid tokei CLI arguments.
- Optional: --stdin if you intentionally use stdin mode.
Examples:
  --args "src"
  --args "--output json src tests"
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
    command -v tokei >/dev/null 2>&1 || { echo "tokei command not found in PATH." >&2; exit 127; }

    local -a parsed_args=()
    eval "parsed_args=($args)"

    if [[ -n "$stdin_text" ]]; then
        printf '%s' "$stdin_text" | tokei "${parsed_args[@]}" | emit
    else
        tokei "${parsed_args[@]}" | emit
    fi
}

main "$@"
