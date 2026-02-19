#!/bin/bash
input=$(cat)

# Extract values using jq
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
CONTEXT_PERCENT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Get current working directory (shorten home prefix to ~)
CWD="${PWD/#$HOME/~}"

# Format cost
COST_FMT=$(printf "%.4f" "$COST")

# Format context percentage
CONTEXT_FMT=$(printf "%.1f" "$CONTEXT_PERCENT")

# Format duration (convert ms to human-readable)
DURATION_SEC=$((DURATION_MS / 1000))
if [ "$DURATION_SEC" -ge 3600 ]; then
    HOURS=$((DURATION_SEC / 3600))
    MINS=$(((DURATION_SEC % 3600) / 60))
    SECS=$((DURATION_SEC % 60))
    DURATION_FMT="${HOURS}h ${MINS}m ${SECS}s"
elif [ "$DURATION_SEC" -ge 60 ]; then
    MINS=$((DURATION_SEC / 60))
    SECS=$((DURATION_SEC % 60))
    DURATION_FMT="${MINS}m ${SECS}s"
else
    DURATION_FMT="${DURATION_SEC}s"
fi

# ANSI color codes
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
ORANGE='\033[38;5;208m'
MAGENTA='\033[35m'
RESET='\033[0m'

# Use orange for context if > 70%
if (( $(echo "$CONTEXT_PERCENT > 70" | bc -l) )); then
    CTX_COLOR=$ORANGE
else
    CTX_COLOR=$YELLOW
fi

# Output status line
echo -e "${GREEN}${CWD}${RESET} | ${CYAN}[$MODEL]${RESET} ${GREEN}\$${COST_FMT}${RESET} | ${CTX_COLOR}${CONTEXT_FMT}%${RESET} ctx | ${MAGENTA}${DURATION_FMT}${RESET} | ${INPUT_TOKENS}/${OUTPUT_TOKENS} tok"
