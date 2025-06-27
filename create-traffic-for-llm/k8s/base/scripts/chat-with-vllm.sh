#!/bin/bash
set -euo pipefail

# Base URL for your vLLM instance
VLLM_URL="${VLLM_URL:?Error: VLLM_URL environment variable not set}"

# The specific model to use
MODEL_NAME="${MODEL_NAME:-granite-40}"

# The chat prompt you want to send
PROMPT_TEXT="${PROMPT_TEXT:-What is the capital of France?}"

# Number of times to run the request (default: 1)
NUM_REQUESTS="${NUM_REQUESTS:-1}"

# Sleep time between requests in seconds (default: 1)
SLEEP_BETWEEN_REQUESTS="${SLEEP_BETWEEN_REQUESTS:-1}"

# Other parameters with defaults
MAX_TOKENS="${MAX_TOKENS:-100}"
TEMPERATURE="${TEMPERATURE:-0.7}"

# Function to make a single request
make_request() {
    local request_num=$1
    echo "=== Request #${request_num} ==="
    echo "Sending request to vLLM instance..."
    echo "URL: ${VLLM_URL}/v1/chat/completions"
    echo "Model: ${MODEL_NAME}"
    echo "Prompt: \"${PROMPT_TEXT}\""
    echo ""

    # Construct the JSON payload
    local json_payload
    json_payload=$(cat <<EOF
{
  "model": "${MODEL_NAME}",
  "messages": [
    {"role": "user", "content": "${PROMPT_TEXT}"}
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
      "${VLLM_URL}/v1/chat/completions")
    
    # Extract and display the response in a readable format
    local model_id
    local content
    local usage
    
    # Check if content is null in the response
    if [[ $(echo "$response" | jq '.choices[0].message.content == null') == "true" ]]; then
        echo "=== Full Response (content is null) ==="
        echo "$response" | jq .
        echo ""
        return 0
    else    
      model_id=$(echo "$response" | jq -r '.id // "N/A"')
      content=$(echo "$response" | jq -r '.choices[0].message.content // "No content"' | sed 's/\n/ /g')
      usage=$(echo "$response" | jq -r '
        "Tokens: " + (.usage.prompt_tokens|tostring) + 
        " (prompt), " + 
        (.usage.completion_tokens|tostring) + 
        " (completion)"'
      )
    
      echo "=== Response ==="
      echo "ID: ${model_id}"
      echo "---"
      echo "${content}"
      echo "---"
      echo "${usage}"
      echo ""
      echo ""
      
    fi
}

# Main execution
echo "Starting ${NUM_REQUESTS} request(s) to ${VLLM_URL}"
echo "Sleeping ${SLEEP_BETWEEN_REQUESTS} second(s) between requests"
echo "========================================"
echo ""

for ((i=1; i<=NUM_REQUESTS; i++)); do
    make_request "$i"
    
    # Add delay between requests if not the last request
    if [[ "$i" -lt "$NUM_REQUESTS" && "$SLEEP_BETWEEN_REQUESTS" -gt 0 ]]; then
        echo "Waiting ${SLEEP_BETWEEN_REQUESTS} second(s) before next request..."
        sleep "$SLEEP_BETWEEN_REQUESTS"
    fi
done

echo "========================================"
echo "Completed ${NUM_REQUESTS} request(s)"
