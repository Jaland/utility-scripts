#!/bin/bash
set -euo pipefail

# Base URL for your vLLM instance
VLLM_URL="${VLLM_URL:?Error: VLLM_URL environment variable not set}"

# The specific model to use
MODEL_NAME="${MODEL_NAME:-granite-40}"

# The chat prompt you want to send
PROMPT_TEXT="${PROMPT_TEXT:-What is the capital of France?}"

# Other parameters with defaults
MAX_TOKENS="${MAX_TOKENS:-100}"
TEMPERATURE="${TEMPERATURE:-0.7}"

# Construct the JSON payload for the chat completion request
# The 'messages' array follows the OpenAI chat format: [{"role": "user", "content": "..."}]
# 'max_tokens' and 'temperature' are common parameters you might want to adjust.
JSON_PAYLOAD=$(cat <<EOF
{
  "model": "${MODEL_NAME}",
  "messages": [
    {"role": "user", "content": "${PROMPT_TEXT}"}
  ],
  "max_tokens": 100,
  "temperature": 0.7,
  "stream": false
}
EOF
)

echo "Sending request to vLLM instance..."
echo "URL: ${VLLM_URL}/v1/chat/completions"
echo "Model: ${MODEL_NAME}"
echo "Prompt: \"${PROMPT_TEXT}\""
echo ""

# Execute the curl command
# -X POST: Specifies a POST request
# -H "Content-Type: application/json": Sets the header to indicate JSON content
# -d "${JSON_PAYLOAD}": Sends the JSON payload as the request body
# -s: Silent mode, hides progress meter
# -S: Show errors if curl fails
curl -sS \
  -X POST \
  -H "Content-Type: application/json" \
  -d "${JSON_PAYLOAD}" \
  "${VLLM_URL}/v1/chat/completions"

echo ""
echo "Request complete."

