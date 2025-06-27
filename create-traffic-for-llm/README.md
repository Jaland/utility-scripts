# LLM Traffic Generator

A utility for generating traffic to vLLM instances, designed to be deployed as a Kubernetes CronJob. This tool helps with testing and monitoring LLM services by sending periodic chat completion requests.

## Features

- Sends chat completion requests to vLLM instances using the OpenAI-compatible API
- Configurable parameters (model, prompt, temperature, etc.)
- Kubernetes-native deployment using Kustomize
- Environment-specific configurations
- Easy scheduling and one-off job execution

## Prerequisites

- Kubernetes cluster
- `kubectl` configured to communicate with your cluster
- `kustomize` (included with recent `kubectl` versions)

## Directory Structure

```text
create-traffic-for-llm/
├── k8s/                   # Kubernetes deployment files
│   ├── base/              # Base kustomization
│   │   ├── cronjob.yaml   # Base CronJob definition
│   │   ├── kustomization.yaml
│   │   └── scripts/       # Scripts directory
│   │       └── chat-with-vllm.sh  # Main script for vLLM requests
│   └── overlays/
│       └── dev/           # Development environment overrides
│           ├── kustomization.yaml
│           └── patch-cronjob.yaml
└── chat-with-vllm.sh      # Legacy script location (symlinked to k8s/scripts/)
```

## Quick Start

1. Navigate to the k8s directory:

   ```bash
   cd create-traffic-for-llm/k8s
   ```

2. Review and customize the environment variables in `overlays/dev/patch-cronjob.yaml`:
   - `VLLM_URL`: Your vLLM instance URL (required)
   - `MODEL_NAME`: Model to use (default: "granite-40")
   - `PROMPT_TEXT`: The prompt to send (default: "What is the capital of France?")
   - `MAX_TOKENS`: Maximum tokens in response (default: 100)
   - `TEMPERATURE`: Sampling temperature (default: 0.7)

3. Apply the configuration:

   ```bash
   kubectl apply -k overlays/dev
   ```

## Customization

### Changing the Schedule

Edit the `spec.schedule` field in `overlays/dev/patch-cronjob.yaml` using cron syntax. For example:

```yaml
spec:
  schedule: "*/15 * * * *"  # Run every 15 minutes
```

### Running a One-time Job

To run the job immediately without waiting for the schedule:

```bash
kubectl create job --from=cronjob/chat-job chat-job-manual-$(date +%s)
```

## Monitoring

### Viewing Logs

To view logs, first find the pod name:

```bash
# Get the most recent job pod
POD_NAME=$(kubectl get pods --sort-by=.metadata.creationTimestamp -l job-name -o name | grep -v "-manual" | tail -n1)

# View logs
kubectl logs $POD_NAME
```

Or for a manual job:

```bash
# Get the most recent manual job pod
POD_NAME=$(kubectl get pods --sort-by=.metadata.creationTimestamp -l job-name -o name | grep "-manual" | tail -n1)

# View logs
kubectl logs $POD_NAME
```

## Cleanup

To remove all created resources:

```bash
kubectl delete -k overlays/dev
```

## Script Details

The main script `chat-with-vllm.sh` sends requests to a vLLM instance using the OpenAI-compatible API. It accepts the following environment variables:

- `VLLM_URL`: (Required) The base URL of your vLLM instance
- `MODEL_NAME`: The model to use (default: "granite-40")
- `PROMPT_TEXT`: The prompt to send to the model
- `MAX_TOKENS`: Maximum number of tokens to generate (default: 100)
- `TEMPERATURE`: Sampling temperature (default: 0.7)

## License

This project is licensed under the [MIT License](../LICENSE).
