#!/bin/bash

# Get the raw ccusage output
raw_output=$(bun x ccusage statusline)

# Parse the output to extract components
# Expected format: 🤖 Model Name | 💰 $X.XX session / $Y.YY today / $Z.ZZ block (Xh Ym left) | 🔥 temp | 🧠 context_tokens (percentage%)

# Extract model name (remove 🤖 emoji and get text before first |)
model_name=$(echo "$raw_output" | sed -E 's/^🤖 //; s/ \|.*$//')

# Extract cost information (the 💰 section)
cost_info=$(echo "$raw_output" | sed -E 's/.*💰 ([^|]+).*/\1/' | sed 's/^ *//')

# Extract context information (the 🧠 section)
context_info=$(echo "$raw_output" | sed -E 's/.*🧠 ([^|]*).*/\1/' | sed 's/^ *//')

# Parse the cost_info to separate session, today, and block costs
session_cost=$(echo "$cost_info" | sed -E 's/^([^ ]+) session.*/\1/')
today_cost=$(echo "$cost_info" | sed -E 's/.*\/ ([^ ]+) today.*/\1/')
block_cost=$(echo "$cost_info" | sed -E 's/.*\/ ([^ ]+ block \([^)]+\)).*/\1/')

# Format output as requested:
# Line 1: Model name | 🧠 context_size (percentage%)
# Line 2: $session_cost session | $today_cost today
# Line 3: $block_cost
echo "$model_name | 🧠 $context_info"
# echo "$session_cost session | $today_cost today"
# echo "$block_cost"
echo "$session_cost session