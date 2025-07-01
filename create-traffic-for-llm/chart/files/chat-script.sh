#!/bin/bash
set -euo pipefail

# Base URL for your vLLM instance
VLLM_URL="${VLLM_URL:?Error: VLLM_URL environment variable not set}"

# The specific model to use
MODEL_NAME="${MODEL_NAME:-granite-40}"

# Parse the prompts JSON array into a bash array
IFS=$'\n' read -r -d '' -a PROMPTS < <(echo "$PROMPTS_JSON" | jq -r '.[]' && printf '\0')

# Number of times to run the request (default: 1)
NUM_REQUESTS="${NUM_REQUESTS:-1}"

# Sleep time between requests in seconds (default: 1)
SLEEP_BETWEEN_REQUESTS="${SLEEP_BETWEEN_REQUESTS:-1}"

# Other parameters with defaults
MAX_TOKENS="${MAX_TOKENS:-100}"
TEMPERATURE="${TEMPERATURE:-0.7}"

# Function to get a random prompt from the array
get_random_prompt() {
    local num_prompts=${#PROMPTS[@]}
    local random_index=$((RANDOM % num_prompts))
    echo "${PROMPTS[$random_index]}"
}

# Function to escape JSON strings
escape_json() {
    local str="$1"
    # Escape backslashes first, then quotes
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    echo "$str"
}

# Function to make a single request
make_request() {
    local request_num=$1
    local prompt_text
    prompt_text=$(get_random_prompt)
    local escaped_prompt
    escaped_prompt=$(escape_json "$prompt_text")
    
    echo "=== Request #${request_num} ==="
    echo "Sending request to vLLM instance..."
    echo "URL: ${VLLM_URL}/v1/chat/completions"
    echo "Model: ${MODEL_NAME}"
    echo "Prompt: \"${prompt_text}\""
    echo ""

    # Construct the JSON payload
    local json_payload
    json_payload=$(cat <<EOF
{
  "model": "${MODEL_NAME}",
  "messages": [
    {"role": "user", "content": "${escaped_prompt}"}
  ],
  "max_tokens": ${MAX_TOKENS},
  "temperature": ${TEMPERATURE},
  "stream": false
}
EOF
    )

    # Make the request and format the output
    local response
    response=$(curl -sS \
        -X POST \
        -H "Content-Type: application/json" \
        -d "${json_payload}" \
        "${VLLM_URL}/v1/chat/completions" | jq -r '.choices[0].message.content' 2>/dev/null || echo "Error: Failed to get response")

    echo "Response:"
    echo "${response}"
    echo ""
}

# Main execution
echo "Starting ${NUM_REQUESTS} request(s) to ${VLLM_URL}"
echo "Using ${#PROMPTS[@]} different prompts"
echo "Sleeping ${SLEEP_BETWEEN_REQUESTS} second(s) between requests"
echo "========================================"

for ((i=1; i<=NUM_REQUESTS; i++)); do
    make_request $i
    
    # Don't sleep after the last request
    if [ $i -lt $NUM_REQUESTS ]; then
        sleep $SLEEP_BETWEEN_REQUESTS
    fi
done

echo "========================================"
echo "Completed ${NUM_REQUESTS} request(s)"
