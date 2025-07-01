# LLM Traffic Generator

A utility for generating traffic to vLLM instances, designed to be deployed as a Kubernetes CronJob or Helm chart. This tool helps with testing and monitoring LLM services by sending periodic chat completion requests.

## Features

- Sends chat completion requests to vLLM instances using the OpenAI-compatible API
- Configurable parameters (model, prompt, temperature, etc.)
- Kubernetes-native deployment using Helm or Kustomize
- Environment-specific configurations
- Easy scheduling and one-off job execution

## Prerequisites

- Kubernetes cluster
- `kubectl` configured to communicate with your cluster
- `helm` (version 3.x) for Helm deployment
- `kustomize` (included with recent `kubectl` versions) for Kustomize deployment

## Deployment Options

## Option 1: Helm (Recommended)

1. Add the chart repository (if applicable) or navigate to the chart directory:

   ```bash
   # If using a chart repository
   helm repo add llm-traffic-generator /path/to/chart
   
   # Or navigate to the chart directory
   cd create-traffic-for-llm/chart
   ```

2. Install the chart:

   ```bash
   # Install with default values
   helm install llm-traffic ./ -n your-namespace --create-namespace
   
   # Or customize values
   helm install llm-traffic ./ -n your-namespace -f values.yaml
   ```

3. For custom configurations, create a `custom-values.yaml` file:

   ```yaml
   # List of prompts (one will be randomly selected for each job run)
   prompts:
     - "Your first custom prompt here"
     - "Your second custom prompt here"
     - "Another prompt for variety"
   
   # Number of requests to make per job run
   numRequests: 10
   
   # Time between requests in seconds
   sleepBetweenRequests: 5
   
   # vLLM configuration
   vllm:
     url: "http://your-vllm-service.your-namespace.svc.cluster.local"
     model: "your-model-name"
   
   # CronJob schedule (every 15 minutes)
   cronjob:
     schedule: "*/15 * * * *"
   ```

   Then install with:

   ```bash
   helm install llm-traffic ./ -n your-namespace -f custom-values.yaml
   ```

## Customization

### Common Customizations

#### Prompts Configuration

```yaml
# List of prompts (one will be randomly selected for each request)
prompts:
  - "Your first custom prompt here"
  - "Your second custom prompt here"
  - "Add as many prompts as you like"

# Number of requests to make per job run
numRequests: 10

# Time between requests in seconds
sleepBetweenRequests: 2

# Maximum tokens per response
maxTokens: 150

# Sampling temperature (0.0 to 1.0)
temperature: 0.8
```

#### vLLM Configuration

```yaml
vllm:
  # URL of the vLLM service (required)
  url: "http://your-vllm-service.your-namespace.svc.cluster.local"
  # Model name to use
  model: "your-model-name"
```

#### Scheduling Configuration

```yaml
cronjob:
  # Cron schedule (every 30 minutes in this example)
  schedule: "*/30 * * * *"
  # Number of successful/failed jobs to keep in history
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 5
  # Job configuration
  backoffLimit: 2
  restartPolicy: OnFailure
```

#### Container Image

```yaml
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Running a One-time Job

```bash
# Using Helm
helm upgrade --install llm-traffic ./ -n your-namespace --set cronjob.schedule="" --set cronjob.job.enabled=true

# Or manually create a job from the CronJob
kubectl create job --from=cronjob/llm-traffic-llm-traffic-generator llm-traffic-manual-$(date +%s) -n your-namespace
```

## Monitoring

### Viewing Logs

```bash
# Get the most recent job pod
POD_NAME=$(kubectl get pods --sort-by=.metadata.creationTimestamp -l app.kubernetes.io/name=llm-traffic-generator -o name -n your-namespace | tail -n1)

# View logs
kubectl logs $POD_NAME -n your-namespace
```

### Checking Job Status

```bash
# List all jobs
kubectl get jobs -l app.kubernetes.io/name=llm-traffic-generator -n your-namespace

# Describe a specific job
kubectl describe job <job-name> -n your-namespace
```

## Cleanup

### Helm Installation
```bash
helm uninstall llm-traffic -n your-namespace
```

### Kustomize Installation
```bash
kubectl delete -k overlays/dev
```

## Directory Structure (Helm)

```text
create-traffic-for-llm/
├── chart/                  # Helm chart
│   ├── Chart.yaml          # Chart metadata
│   ├── values.yaml         # Default configuration values
│   └── templates/          # Template files
│       ├── _helpers.tpl    # Template helpers
│       ├── configmap.yaml  # Script ConfigMap
│       └── cronjob.yaml    # CronJob definition
└── k8s/                    # Legacy Kustomize files
    └── ...
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Script Details

The main script `chat-with-vllm.sh` sends requests to a vLLM instance using the OpenAI-compatible API. It accepts the following environment variables:

- `VLLM_URL`: (Required) The base URL of your vLLM instance
- `MODEL_NAME`: The model to use (default: "granite-40")
- `PROMPT_TEXT`: The prompt to send to the model
- `MAX_TOKENS`: Maximum number of tokens to generate (default: 100)
- `TEMPERATURE`: Sampling temperature (default: 0.7)

## License

This project is licensed under the [MIT License](../LICENSE).
