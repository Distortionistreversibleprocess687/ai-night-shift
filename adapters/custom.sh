#!/usr/bin/env bash
# ============================================================================
# Adapter: Custom Agent
#
# Template for adding your own CLI agent. Copy this file and implement
# the adapter_* functions for your agent.
#
# Usage:
#   1. cp adapters/custom.sh adapters/my-agent.sh
#   2. Edit the functions below
#   3. Set AGENT_ADAPTER=my-agent in config.env
# ============================================================================

AGENT_BIN="${AGENT_BIN:-my-agent}"

adapter_build_flags() {
    # Return CLI flags needed for non-interactive autonomous execution.
    # Example: echo "--non-interactive --auto-approve"
    echo ""
}

adapter_run() {
    local prompt="$1"
    local output_file="$2"
    local timeout_sec="${3:-9000}"

    local flags
    flags=$(adapter_build_flags)

    # Customize this command for your agent.
    # The key requirements:
    #   - Must accept a prompt/instruction as input
    #   - Must write output to stdout (redirected to output_file)
    #   - Must exit when done (no interactive waiting)
    #   - timeout wrapper ensures it won't hang forever

    # shellcheck disable=SC2086
    timeout "$timeout_sec" "$AGENT_BIN" $flags "$prompt" \
        > "$output_file" 2>&1
    return $?
}

adapter_check_rate_limit() {
    local output_file="$1"
    # Check if the output contains rate limit indicators.
    # Customize the patterns for your agent's error messages.
    grep -qi "rate.limit\|too many\|429\|quota" "$output_file" 2>/dev/null
}

adapter_check_completion() {
    local output_file="$1"
    local signal="${2:-NIGHT_SHIFT_COMPLETE}"
    # Check if the agent signaled that all work is done.
    grep -q "$signal" "$output_file" 2>/dev/null
}

adapter_name() {
    echo "Custom Agent"
}

adapter_verify() {
    command -v "$AGENT_BIN" &>/dev/null
}
